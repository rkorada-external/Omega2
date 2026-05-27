/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC2321.c
revision                      : $Revision: 1.2 $
date de creation              : 10/1997
auteur                        : KUHNA
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   CALCUL DES ECARTS

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define FIC100_SSD_CF       0
#define FIC100_ESB_CF       1
#define FIC100_BALSHEY_NF   2
#define FIC100_BALSHRMTH_NF 3
#define FIC100_BALSHRDAY_NF 4
#define FIC100_CTR_NF       5
#define FIC100_END_NT       6
#define FIC100_SEC_NF       7
#define FIC100_UWY_NF       8
#define FIC100_UW_NT        9
#define FIC100_CUR_CF       10
#define FIC100_AMT_M        11
#define FIC100_RETCTR_NF    12
#define FIC100_RETEND_NT    13
#define FIC100_RETSEC_NF    14
#define FIC100_RTY_NF       15
#define FIC100_RETUW_NT     16
#define FIC100_RETCUR_CF    17
#define FIC100_RETAMT_M     18
#define FIC100_ACCTRTCUR_R  19

#define MAX_TPLAC 1000

#define MAX_TCURCVSNBIS 150000  /* nombre maxi de lignes de bret..tcurcvsn */

typedef struct{
               int PLC_NT;
               unsigned char ORICUR_B;
               double RETSIGSHA_R;
              } T_PLAC;

typedef struct {
char         ACPCUR_CF[4];
unsigned char      SSD_CF;
char         RETCTR_NF[10];
short     RTY_NF;
int          PLC_NT;
char         ACCCUR_CF[4];
} T_CURCVSNBIS;


/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 	*Kp_OutputFil; /* pointeur sur le fichier de travail en sortie */
FILE 	*Kp_InputFilExc ; /* pointeur sur le fichier des cours */
FILE    *Kp_CurcvsnIndx; /* pointeur sur Tcurcvsn */

T_RUPTURE_VAR bd_RuptFic100; 	/* variable de gestion de la rupture */

T_RUPTURE_SYNC_VAR bd_RuptPlc; 	/* variable de gestion de la synchronisation */

T_PLAC   TPLAC[MAX_TPLAC];

double 	Kd_EcartPlc ;	/* ecart placement */
double  Kd_EcartChange;	/* ecart change */
double  Kd_PlcGlob ;	/* placement global */

                              /* booleen indicateur de ligne a ecrire
                                   1 -> ligne a ecrire
                                   0 -> sinon */
unsigned char Kc_AEcrire = 1;
short	Kn_AnneeCours ;	/* annee bilan -> parametre */

static int Kb_TPLACDepass;
static int Kn_TPLAC;
static BOOL Kb_ReturnStatus=0; /* statut de retour du programme */

int n_InitFic100( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Fic100( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_IsR2Fic100( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt1Fic100( char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt2Fic100( char **pbd_InRec_Cur ) ;
int n_ActionLigneFic100( char **pbd_InRec_Cur ) ;
int n_ActionLastRupt2Fic100( char **pbd_InRec_Cur ) ;

int n_InitPlc( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePlc( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPlc( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionPereSansFilsPlc(char **ptb_InRec);

int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );

int n_ProcessingRuptureVar(
  T_RUPTURE_VAR       *pbd_Rupt);

static int StockeLignePlac(char ** tpsz_ReadBufferPLC) ;

static char *sz_GetCurcvsnIndx(
        FILE* pf,               /* Discripteur du fichier des cours */
        char *sz_acpcur,        /* Cours d'origine */
        char c_ssd,             /* filiale */
         char *sz_retctr,       /* contrat */
        short s_rty,            /* Exercice */
         int   n_plc                    /* placement */
        );



/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc,char *argv[])
{
  /* Initialisation des signaux */
  InitSig () ;

  if ( n_BeginPgm ( argc, argv ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* recuperation des parametres */
  Kn_AnneeCours = n_GetIntArgv( 1 ) ;

  /* ouverture du fichier de travail en sortie */
  if ( n_OpenFileAppl ( "ESTC2321_O1","wt",&Kp_OutputFil) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en entree des cours de change FCURQUOT */
  if ( n_OpenFileAppl ( "ESTC2321_I3","rb",&Kp_InputFilExc ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture de TCURCVSN */
  if ( n_OpenFileAppl ("ESTC2321_I4","rb",&Kp_CurcvsnIndx) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la variable bd_RuptFic100 */
  if ( n_InitFic100( &bd_RuptFic100 ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptPlc */
  if ( n_InitPlc( &bd_RuptPlc ) )
    ExitPgm( ERR_XX , "" ) ;

  /* lancement du traitement du fichier GTRr */
  if ( n_ProcessingRuptureVar( &bd_RuptFic100 ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2321_I1", &( bd_RuptFic100.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2321_I2", &( bd_RuptPlc.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;


  if ( n_CloseFileAppl( "ESTC2321_I3", &Kp_InputFilExc ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl ("ESTC2321_I4",&Kp_CurcvsnIndx)==ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTC2321_O1", &Kp_OutputFil) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_EndPgm() == ERR )
    ExitPgm( ERR_XX , "" );

  exit(Kb_ReturnStatus) ;
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitFic100(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitFic100" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier maitre Fic100 */
  if ( n_OpenFileAppl( "ESTC2321_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    return ERR ;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 2 ;

  /* fonction du test de rupture de niveau 1 */
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Fic100 ;

  /* fonction du test de rupture de niveau 2 */
  pbd_Rupt->n_ConditionRupture[1] = n_IsR2Fic100 ;

  /* fonction lancee en rupture premiere de niveau 1 */
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt1Fic100 ;

  /* fonction lancee en rupture premiere de niveau 2 */
  pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRupt2Fic100 ;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_ActionLigne = n_ActionLigneFic100 ;

  /* Fonction lancee en rupture derniere de niveau 2 */
  pbd_Rupt->n_ActionLast[1] = n_ActionLastRupt2Fic100 ;

  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1Fic100(
	char **ptb_InRec ,  /* adresse de la ligne en avance */
	char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1Fic100" ) ;

  if ((ret = strcmp(ptb_InRec[FIC100_RETCTR_NF],ptb_InRec_Cur[FIC100_RETCTR_NF]))!= 0)
    return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_RETEND_NT], ptb_InRec_Cur[FIC100_RETEND_NT] ) ) != 0 )
    return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_RETSEC_NF], ptb_InRec_Cur[FIC100_RETSEC_NF] ) ) != 0 )
    return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_RTY_NF], ptb_InRec_Cur[FIC100_RTY_NF] ) ) != 0 )
     return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_RETUW_NT], ptb_InRec_Cur[FIC100_RETUW_NT] ) ) != 0 )
     return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 2

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR2Fic100(
	char **ptb_InRec ,  /* adresse de la ligne en avance */
	char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR2Fic100" ) ;


  if ( ( ret = strcmp( ptb_InRec[FIC100_RETCTR_NF], ptb_InRec_Cur[FIC100_RETCTR_NF] ) ) != 0 )
    return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_RETEND_NT], ptb_InRec_Cur[FIC100_RETEND_NT] ) ) != 0 )
    return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_RETSEC_NF], ptb_InRec_Cur[FIC100_RETSEC_NF] ) ) != 0 )
    return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_RTY_NF], ptb_InRec_Cur[FIC100_RTY_NF] ) ) != 0 )
     return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_RETUW_NT], ptb_InRec_Cur[FIC100_RETUW_NT] ) ) != 0 )
     return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_SSD_CF], ptb_InRec_Cur[FIC100_SSD_CF] ) ) != 0 )
    return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_ESB_CF], ptb_InRec_Cur[FIC100_ESB_CF] ) ) != 0 )
    return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_CTR_NF], ptb_InRec_Cur[FIC100_CTR_NF] ) ) != 0 )
    return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_END_NT], ptb_InRec_Cur[FIC100_END_NT] ) ) != 0 )
     return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_SEC_NF], ptb_InRec_Cur[FIC100_SEC_NF] ) ) != 0 )
     return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_UWY_NF], ptb_InRec_Cur[FIC100_UWY_NF] ) ) != 0 )
     return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_UW_NT], ptb_InRec_Cur[FIC100_UW_NT] ) ) != 0 )
     return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_RETCUR_CF], ptb_InRec_Cur[FIC100_RETCUR_CF] ) ) != 0 )
     return ret ;

  if ( ( ret = strcmp( ptb_InRec[FIC100_CUR_CF], ptb_InRec_Cur[FIC100_CUR_CF] ) ) != 0 )
     return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 1

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt1Fic100( char **pbd_InRec_Cur  )
{
  DEBUT_FCT( "n_ActionFirstRupt1Fic100" ) ;

     Kb_TPLACDepass=0;
     Kn_TPLAC=0;

  /* synchronisation avec le fichier placements */
  n_ProcessingRuptureSyncVar( &bd_RuptPlc, pbd_InRec_Cur ) ;

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 2

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt2Fic100( char **pbd_InRec_Cur  )
{
       int p;
       static char *p1;
  DEBUT_FCT( "n_ActionFirstRupt2Fic100" ) ;

  /* initialisation des placements globaux */
  Kd_PlcGlob = 0 ;

  /* initialisation des ecarts placement et change */
  Kd_EcartPlc = 0 ;
  Kd_EcartChange= 0 ;

          /*------------------------------*/
          /* Calcul de la monnaies retro  */
          /*------------------------------*/
     if ( (Kb_TPLACDepass == 0) && (Kn_TPLAC != 0) )
     {
        for (p=0; p < Kn_TPLAC; p++)
        {
           if (TPLAC[p].ORICUR_B == 1)
           {
              /* la devise retrocession est identique a la devise originale */
              Kd_PlcGlob += TPLAC[p].RETSIGSHA_R;
           }
           else
           {
              p1=sz_GetCurcvsnIndx( Kp_CurcvsnIndx,
                                    pbd_InRec_Cur[FIC100_CUR_CF],
                                    (unsigned char) atoi(pbd_InRec_Cur[FIC100_SSD_CF]),
                                    pbd_InRec_Cur[FIC100_RETCTR_NF],
                                    (short) atoi(pbd_InRec_Cur[FIC100_RTY_NF]),
                                    TPLAC[p].PLC_NT) ;
              if ( strcmp(pbd_InRec_Cur[FIC100_RETCUR_CF], p1)== 0 )
              {
                 Kd_PlcGlob += TPLAC[p].RETSIGSHA_R;
              }
           }
        }
     }

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFic100( char **ptb_InRec_Cur )
{
  char	MsgAno[300] ;

  double d_PartPlacGlob,   /* Part placee globale */
         d_CoursEnvCpt,    /* Cours de change d'envoi de compte */
         d_CoursInv,       /* Cours de change inventaire */
         d_MtAcc,          /* Montant acceptation */
         d_MtRetro;        /* Montant retrocession */


  DEBUT_FCT( "n_ActionLigneFic100" ) ;

   /****************************************************************/
  /* Calcul des cours de change d'envoi de compte et d'inventaire */
  /****************************************************************/

  d_MtAcc = atof(ptb_InRec_Cur[FIC100_AMT_M]);
  d_MtRetro = atof(ptb_InRec_Cur[FIC100_RETAMT_M]);

  if (d_MtAcc == 0) /* Calcul du cours de change d'envoi de compte impossible */
    {                  /* Division par 0 */
       sprintf(MsgAno,"The retroceded amount is nul");
       n_WriteAno(MsgAno);
       Kc_AEcrire = 0; /* Ligne a ne pas ecrire */
       return OK;      /* sortie de fonction */
    }

  d_PartPlacGlob = atof(ptb_InRec_Cur[FIC100_ACCTRTCUR_R]);
  d_CoursEnvCpt  = d_MtRetro / d_MtAcc;

  d_CoursInv = d_GetTaux( Kp_InputFilExc,
                         (char) atoi( ptb_InRec_Cur[FIC100_SSD_CF] ),
			 Kn_AnneeCours,
                         ptb_InRec_Cur[FIC100_CUR_CF],
                         ptb_InRec_Cur[FIC100_RETCUR_CF] ) ;


/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
  if ( d_CoursInv < 0 )
    {
	sprintf( MsgAno, "The rate of acceptance currency ( %s ) or the rate of retrocession currency ( %s ) for the year %s isn't known for the contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s - SSD %s ) \n",
	   ptb_InRec_Cur[FIC100_CUR_CF],
           ptb_InRec_Cur[FIC100_RETCUR_CF],
           ptb_InRec_Cur[FIC100_BALSHEY_NF],
	   ptb_InRec_Cur[FIC100_CTR_NF],
           ptb_InRec_Cur[FIC100_END_NT],
           ptb_InRec_Cur[FIC100_SEC_NF],
	   ptb_InRec_Cur[FIC100_UWY_NF],
           ptb_InRec_Cur[FIC100_UW_NT],
           ptb_InRec_Cur[FIC100_SSD_CF] ) ;

      n_WriteAno( MsgAno ) ;
      Kc_AEcrire = 0; /* Ligne a ne pas ecrire */

      return OK;
    }


  /***********************************/
  /* Calcul des cumuls des ecarts    */
  /***********************************/
  Kd_EcartPlc += (d_MtRetro *  (d_PartPlacGlob - Kd_PlcGlob));
  Kd_EcartChange+= (d_MtAcc * Kd_PlcGlob * (d_CoursEnvCpt - d_CoursInv));


  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 2

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRupt2Fic100( char **ptb_InRec_Cur  )
{
  char *(pc_Ligne_Frapp[FRAPP_FIN + 1]);
  char sz_EcartPlc[50],
       sz_EcartChange[50];
  int n_i;

  DEBUT_FCT( "n_ActionLastRupt2Fic100" ) ;

  if (Kc_AEcrire == 1)
    {
      /* Initialisation de la ligne en sortie */
      for (n_i = FRAPP_SSD_CF ; n_i < FRAPP_FIN ; n_i ++)
        pc_Ligne_Frapp[n_i] = "";

      /* ecriture d'une ligne en sortie dans le fichier de travail */
      /* Alimentation de la cle */
      pc_Ligne_Frapp[FRAPP_SSD_CF] = ptb_InRec_Cur[FIC100_SSD_CF];
      pc_Ligne_Frapp[FRAPP_ESB_CF] = ptb_InRec_Cur[FIC100_ESB_CF];
      pc_Ligne_Frapp[FRAPP_CTR_NF] = ptb_InRec_Cur[FIC100_CTR_NF];
      pc_Ligne_Frapp[FRAPP_END_NT] = ptb_InRec_Cur[FIC100_END_NT];
      pc_Ligne_Frapp[FRAPP_SEC_NF] = ptb_InRec_Cur[FIC100_SEC_NF];
      pc_Ligne_Frapp[FRAPP_UWY_NF] = ptb_InRec_Cur[FIC100_UWY_NF];
      pc_Ligne_Frapp[FRAPP_UW_NT] = ptb_InRec_Cur[FIC100_UW_NT];
      pc_Ligne_Frapp[FRAPP_RETCTR_NF] = ptb_InRec_Cur[FIC100_RETCTR_NF];
      pc_Ligne_Frapp[FRAPP_RETEND_NT] = ptb_InRec_Cur[FIC100_RETEND_NT];
      pc_Ligne_Frapp[FRAPP_RETSEC_NF] = ptb_InRec_Cur[FIC100_RETSEC_NF];
      pc_Ligne_Frapp[FRAPP_RTY_NF] = ptb_InRec_Cur[FIC100_RTY_NF];
      pc_Ligne_Frapp[FRAPP_RETUW_NT] = ptb_InRec_Cur[FIC100_RETUW_NT];
      pc_Ligne_Frapp[FRAPP_RETCUR_CF] = ptb_InRec_Cur[FIC100_RETCUR_CF];

      /* Conversion de type des Ecarts */
      sprintf(sz_EcartPlc,"%-.3lf",Kd_EcartPlc);
      sprintf(sz_EcartChange,"%-.3lf",Kd_EcartChange);

      pc_Ligne_Frapp[FRAPP_AMT4_M] = sz_EcartPlc;
      pc_Ligne_Frapp[FRAPP_AMT5_M] = sz_EcartChange;

      pc_Ligne_Frapp[FRAPP_FIN] = 0;

      /* Ecriture de la ligne */
      n_WriteCols(Kp_OutputFil,pc_Ligne_Frapp,SEPARATEUR,0);

      /* Remise a 0 ecrire est vrai */
    }
  else  Kc_AEcrire = 1;

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Fic100 »
	avec l’esclave « fichier des placements »

retour :
	OK
==============================================================================*/
int n_InitPlc( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
  DEBUT_FCT( "n_InitPlc" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTC2321_I2","rt",&( pbd_Rupt->pf_InputFil)) == ERR)
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncPlc ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLignePlc ;

  /* fonction action pere sans fils */
  pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsPlc;

  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPlc(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncPlc" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[FIC100_RETCTR_NF], pbd_InRecChild[PLA_RETCTR_NF] ) ) != 0 )
   return ret ;

  if ( ( ret = strcmp( pbd_InRecOwner[FIC100_RETEND_NT], pbd_InRecChild[PLA_RETEND_NT] ) ) != 0 )
   return ret ;

  if ( ( ret = strcmp( pbd_InRecOwner[FIC100_RETSEC_NF], pbd_InRecChild[PLA_RETSEC_NF] ) ) != 0 )
   return ret ;

  if ( ( ret = strcmp( pbd_InRecOwner[FIC100_RTY_NF], pbd_InRecChild[PLA_RTY_NF] ) ) != 0 )
   return ret ;

  if ( ( ret = strcmp( pbd_InRecOwner[FIC100_RETUW_NT], pbd_InRecChild[PLA_RETUW_NT] ) ) != 0 )
   return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlc(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
        char MsgAno[300];

	DEBUT_FCT( "n_ActionLignePlc" ) ;

   if (Kb_TPLACDepass == 0)
   {
       if (Kn_TPLAC < MAX_TPLAC)
       {
         StockeLignePlac(ptb_InRecChild);
         Kn_TPLAC++;
       }
       else
       {
        sprintf(MsgAno,"The number of records in PLACEMENT file for contract (/RETCTR %s /RETEND %s /RETSEC %s /RTY %s /RETUW %s) overflows the program's storage capacity\n",
                      ptb_InRecChild[PLA_RETCTR_NF],
                      ptb_InRecChild[PLA_RETEND_NT],
                      ptb_InRecChild[PLA_RETSEC_NF],
                      ptb_InRecChild[PLA_RTY_NF],
                      ptb_InRecChild[PLA_RETUW_NT]);

        n_WriteAno(MsgAno);
        Kb_TPLACDepass=1;
        Kb_ReturnStatus=1;
       }
    }


	RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
	fonction lancee quand l'esclave n'a pas de maitre

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionPereSansFilsPlc(
	char **ptb_InRecOwner ) /* adresse de la ligne du maitre */
{
  char	MsgAno[300] ;

  DEBUT_FCT( "n_ActionPereSansFilsPlc" ) ;

  /* positionnement par defaut du placement global */
  Kd_PlcGlob = 0;

  /* generation d'une anomalie */
  sprintf( MsgAno, "The retro contract ( RETCTR %s - RETEND %s - RETSEC %s - RTY %s - RETUW %s ) doesn't exist in the placement file \n",
	  ptb_InRecOwner[FIC100_RETCTR_NF],
          ptb_InRecOwner[FIC100_RETEND_NT],
          ptb_InRecOwner[FIC100_RETSEC_NF],
	  ptb_InRecOwner[FIC100_RTY_NF],
          ptb_InRecOwner[FIC100_RETUW_NT] ) ;

  n_WriteAno( MsgAno ) ;

  RETURN_VAL( OK ) ;
}

/*==================================================================
objet : Stocker une ligne du fichier placements lu en entree
        dans le tableau TPLAC.
====================================================================*/

static int StockeLignePlac(char ** ptb_InRecChild)
{
        DEBUT_FCT ("StockeLignePlac") ;
  TPLAC[Kn_TPLAC].PLC_NT=atoi(ptb_InRecChild[PLA_PLC_NT]);
  TPLAC[Kn_TPLAC].ORICUR_B=(unsigned char) atoi(ptb_InRecChild[PLA_ORICUR_B]);
  TPLAC[Kn_TPLAC].RETSIGSHA_R=atof(ptb_InRecChild[PLA_RETSIGSHA_R]);
        RETURN_VAL(OK);
}

/*============================================================================
objet :
   Lancement du traitement destine a ramener des lignes de la base.

retour :
 CS_SUCCEED
 CS_FAIL
==============================================================================*/
static char *sz_GetCurcvsnIndx(
 FILE* pf,	  /* Discripteur du fichier des cours */
 char *sz_acpcur, /* Cours d'origine */
 char c_ssd,	  /* filiale */
 char *sz_retctr, /* contrat */
 short s_rty,	  /* Exercice */
 int   n_plc	  /* placement */
 )
{
  static char b_First = TRUE ;
  static T_INDXCURQUOT *pKbd_Adr;
  static T_CURCVSN *pKbd_curcvsn;
  T_INDXCURQUOT  bd_AdrTampon ;
  static int Kn_MaxCoursDevise ;
  static int k = 0 ;

  static char sz_Vide[4] = "   " ;
  char *sz_acccur_cf ;
  int i, j;
  int   n_position=-1;
  char  b_SsdTrouve = 0;
  char  b_RetctrRtyTrouve = 0;
  char  b_PlcTrouve = 0;
  char  b_PlcNulTrouve = 0;
  static int  n_DebutData = MAX_DEVISE*sizeof(T_INDXCURQUOT)    ;

  DEBUT_FCT ("sz_GetCurcvsnIndx");

  if(b_First)
  {
    b_First = FALSE;
    if(fseek(pf,0,SEEK_SET)==-1L)
    {   RETURN_VAL (NULL) ;}
    else
{
    while (fread (&bd_AdrTampon, sizeof(T_INDXCURQUOT), 1, pf) > 0 && bd_AdrTampon.n_Nbr != 0 )
    {
    k++;
    Kn_MaxCoursDevise = max( bd_AdrTampon.n_Nbr, Kn_MaxCoursDevise );
    }


/* allocation de la memoire pour les deux structures */

   pKbd_curcvsn = malloc (sizeof(T_CURCVSN) * Kn_MaxCoursDevise);

   pKbd_Adr = malloc (sizeof(T_INDXCURQUOT) * k);

/* remplissage de la structure des adresses */

   fseek(pf, 0, SEEK_SET);

   fread(pKbd_Adr,  sizeof(T_INDXCURQUOT) , k, pf);

}
}
  sz_acccur_cf = sz_Vide ;

  for(i=0;i<k; i++)
  {
        if(strcmp(pKbd_Adr[i].sz_cur,sz_acpcur)==0)
        {
                if(fseek( pf,
                        pKbd_Adr[i].l_Pos*sizeof(T_CURCVSN)+n_DebutData,
                        SEEK_SET)==-1L)
                {
                        RETURN_VAL(NULL);
                }
                else
                {
                        if( fread(pKbd_curcvsn,sizeof(T_CURCVSN),pKbd_Adr[i].n_Nbr,pf)> 0 )
                        {
                                for(j=0;j<pKbd_Adr[i].n_Nbr ; j++ )
                                {
                                        if (c_ssd == pKbd_curcvsn[j].SSD_CF)
                                        {
                                            b_SsdTrouve=1;
                                            if ( (strcmp(pKbd_curcvsn[j].RETCTR_NF,"         ")==0) && pKbd_curcvsn[j].RTY_NF == 0
)
                                            {
                                                n_position = j;
                                                continue ;
                                            }
                                            if ( (strcmp(sz_retctr, pKbd_curcvsn[j].RETCTR_NF) == 0) &&
                                                 (s_rty == pKbd_curcvsn[j].RTY_NF)      )
                                            {
                                                b_RetctrRtyTrouve=1;
                                                if (pKbd_curcvsn[j].PLC_NT == 0)
                                                {
                                                   n_position = j;
                                                   b_PlcNulTrouve=1;
                                                }
                                                if (n_plc == pKbd_curcvsn[j].PLC_NT)
                                                {
                                                    b_PlcTrouve=1;
                                                    n_position = j;
                                                    break;
                                                }
                                            }
                                            if  (strcmp(sz_retctr, pKbd_curcvsn[j].RETCTR_NF) < 0)  break;
                                        }

                                }


                                if ((n_position < 0) || (b_SsdTrouve == 0) )
                                        {RETURN_VAL(sz_Vide);}
                                else
                                   { RETURN_VAL (pKbd_curcvsn[n_position].ACCCUR_CF);}


                        }
                        else { RETURN_VAL(sz_Vide) ; }
                }
        }
  }

  RETURN_VAL(sz_Vide);
}

