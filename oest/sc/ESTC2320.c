/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Estimation - Rapprochement retrocession
nom du source                 : ESTC2320.c
revision                      : $Revision:   1.0  $
date de creation              : 10/10/97
auteur                        : CGI (Claire Soulier) 
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Synchronisation du fichier des mouvements retro a 100% comptabilises
        TACCTRAA avec le perimetre retrocession - Elimination des mouvements
	pour lesquels le perimetre ne participe pas - Elimination des postes
        provisions -

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
int n_InitPER(T_RUPTURE_VAR  *);
int n_InitTACCTRAA(T_RUPTURE_SYNC_VAR  *);
int n_ActionLigneTACCTRAA(char **,char**);
int n_ConditionSyncTACCTRAA(char **,char **);
int n_ActionLignePER(char **);
int n_IsRuptTACCTRAA(char **pbd_InRec, char **pbd_InRec_Cur);
int n_ActionFirstRuptTACCTRAA(char **pbd_InRecOwner, char **pbd_InRecChild);

/*----------------------*/
/* variables de travail */
/*----------------------*/
static BOOL Kb_Rappro;
short Kc_Provision;
static FILE *Kp_Dettrs;
static FILE *Kp_Out;

static T_RUPTURE_VAR   Kbd_RuptPER;       
static T_RUPTURE_SYNC_VAR  Kbd_RuptTACCTRAA;  

static BOOL Kb_ReturnStatus=0; /* statut de retour du programme */   

/*==============================================================================
objet :
   point d'entre du programme

retour :
   En cas de problme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2320_O1","wt",&Kp_Out) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2320_I3","rb",&Kp_Dettrs) == ERR )
                ExitPgm ( ERR_XX , "" );

	/* Initialisation de la variable Kbd_RuptPER  */
	if ( n_InitPER(&Kbd_RuptPER)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptTACCTRAA */
	if ( n_InitTACCTRAA(&Kbd_RuptTACCTRAA)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar(&Kbd_RuptPER) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2320_O1",&Kp_Out)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2320_I1",&(Kbd_RuptPER.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2320_I2",&(Kbd_RuptTACCTRAA.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2320_I3",&Kp_Dettrs)==ERR )
                ExitPgm ( ERR_XX , "" );
        
	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(Kb_ReturnStatus) ;

}


/*==============================================================================
objet :
    fonction d'initialisation de la variable de gestion de rupture du fichier
    maitre.

retour :
	0K ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
int n_InitPER(T_RUPTURE_VAR  *pbd_RuptPER)
{
	memset(pbd_RuptPER,0,sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESTC2320_I1","rt",&(pbd_RuptPER->pf_InputFil))==ERR)
		return ERR;

	pbd_RuptPER->n_NbRupture =0;    
	pbd_RuptPER->n_ActionLigne     = n_ActionLignePER;

        pbd_RuptPER->c_Separ=SEPARATEUR;

	return OK ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree 
==============================================================================*/
int n_InitTACCTRAA(T_RUPTURE_SYNC_VAR  *pbd_RuptTACCTRAA)
{

	memset( pbd_RuptTACCTRAA,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC2320_I2","rt",&(pbd_RuptTACCTRAA->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptTACCTRAA->n_NbRupture =1;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptTACCTRAA->ConditionEndSync	= n_ConditionSyncTACCTRAA;

	/* fonction du test de rupture de niveau 1 */
	pbd_RuptTACCTRAA->n_ConditionRupture[0] = n_IsRuptTACCTRAA ;

	/* fonction lancee en rupture premiere */
	pbd_RuptTACCTRAA->n_ActionFirst[0] = n_ActionFirstRuptTACCTRAA ;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptTACCTRAA->n_ActionLigne   	= n_ActionLigneTACCTRAA;
	
        pbd_RuptTACCTRAA->c_Separ=SEPARATEUR;

	return OK ;
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne du fichier fils
        qui synchronise

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneTACCTRAA(
	char *tpsz_ReadBufferPER[] ,
	char *tpsz_ReadBufferTACCTRAA[]
)
{
    char MsgAno[400];

        DEBUT_FCT("n_ActionLigneTACCTRAA");
	if
	(
	  (
              ( atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF])==5)
           || (atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF])==6)
           || (atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF])==7)
           || (atoi(tpsz_ReadBufferPER[PER_RETCTRCAT_CF])==8)
          )
/*	  || (((n_type= n_TypePoste(tpsz_ReadBufferTACCTRAA[TACCTRAA_TRNCOD_CF],Kp_Dettrs)) != 3) && (n_type != 0)) */
          || ( (Kc_Provision != 3) && (Kc_Provision != 0) )
	)
          {
	     if (Kb_Rappro == TRUE)
		{
                 if (atof(tpsz_ReadBufferTACCTRAA[TACCTRAA_CED_M]) != 0.)
                 {
                        /* ecriture en sortie d'un enregistrement */
                      /*****************************************************************/
                      /*              Evol FGR du 13/10/2000                           */
                      /*     Dans le cas ou le TRNCOD_CF est egal a 21120000           */
                      /*     et que ACCTRTCUR_R est a 0 , aucun ecart de placement     */
                      /*                 ne doit etre calcule                          */
                      /*     La ligne n'est donc pas ecrite en sortie                  */
                      /*****************************************************************/
 
                      if ( 
                              ( strcmp ( tpsz_ReadBufferTACCTRAA[TACCTRAA_TRNCOD_CF] , "21120000" ) != 0 )   
                           || ( atof( tpsz_ReadBufferTACCTRAA[TACCTRAA_ACCTRTCUR_R]) !=0 )
                         )
                      {
             
                         fprintf(Kp_Out,"%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%s~%.3lf~%s~%s~%s~%s~%s~%s~%.3lf~%s\n",
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_SSD_CF], 
                         tpsz_ReadBufferPER[PER_ACCESB_CF], 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_BLCSHT_D], 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_BLCSHT_D]+4, 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_BLCSHT_D]+6, 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_CTR_NF], 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_END_NT], 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_SEC_NF], 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_UWY_NF], 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_UW_NT], 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_ACPCUR_CF], 
                         (-1) * atof(tpsz_ReadBufferTACCTRAA[TACCTRAA_CED_M]), 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_RETCTR_NF], 
                         "0", /* RETEND_NT */
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_RETSEC_NF], 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_RTY_NF], 
                         "1",  /* RETUW_NT */
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_CNVCUR_CF], 
                         (-1) * atof(tpsz_ReadBufferTACCTRAA[TACCTRAA_CNVAMT_M]), 
                         tpsz_ReadBufferTACCTRAA[TACCTRAA_ACCTRTCUR_R]);
                      }
                    }  /* fin du if montant non nul */

                    else /* montant acceptation nul */
                    {
                     if (atof(tpsz_ReadBufferTACCTRAA[TACCTRAA_CNVAMT_M]) != 0.)
                     {
                         /* si le montant acceptation est nul et le montant */
                         /* retro non nul on genere une anomalie */

                        sprintf(MsgAno,"The acceptance amount (equal to zero) and retrocession amount (not equal to zero) are not compatible for the record:\nCTR=%s, END=%s, SEC=%s, UWY=%s, UW=%s, \nRETCTR=%s, RETSEC=%s, RTY=%s,\nACPCUR=%s, CNVCUR=%s, TRNCOD=%s",
                           tpsz_ReadBufferTACCTRAA[TACCTRAA_CTR_NF],
                           tpsz_ReadBufferTACCTRAA[TACCTRAA_END_NT],
                           tpsz_ReadBufferTACCTRAA[TACCTRAA_SEC_NF],
                           tpsz_ReadBufferTACCTRAA[TACCTRAA_UWY_NF],
                           tpsz_ReadBufferTACCTRAA[TACCTRAA_UW_NT],
                           tpsz_ReadBufferTACCTRAA[TACCTRAA_RETCTR_NF],
                           tpsz_ReadBufferTACCTRAA[TACCTRAA_RETSEC_NF],
                           tpsz_ReadBufferTACCTRAA[TACCTRAA_RTY_NF],
                           tpsz_ReadBufferTACCTRAA[TACCTRAA_ACPCUR_CF],
                           tpsz_ReadBufferTACCTRAA[TACCTRAA_CNVCUR_CF],
                           tpsz_ReadBufferTACCTRAA[TACCTRAA_TRNCOD_CF]);

                        n_WriteAno(MsgAno);
                       Kb_ReturnStatus=1; 
                     }
                    } /* fin du else */
		} /* fin du poste rappro */
          }  /* fin du premier if */

   RETURN_VAL(OK);
}

/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0       ---> pbd_InRecOwner = pbd_InRecChild 
	> 0   	---> pbd_InRecOwner > pbd_InRecChild 
	< 0   	---> pbd_InRecOwner < pbd_InRecChild 
==============================================================================*/
int n_ConditionSyncTACCTRAA(
	char *tpsz_ReadBufferPER[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferTACCTRAA[] )    /* adresse de la ligne de l'esclave */
{

	int ret 
        DEBUT_FCT("n_ConditionSyncTACCTRAA");

        if((ret = strcmp(tpsz_ReadBufferPER[PER_CTR_NF],tpsz_ReadBufferTACCTRAA[TACCTRAA_RETCTR_NF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferPER[PER_SEC_NF],tpsz_ReadBufferTACCTRAA[TACCTRAA_RETSEC_NF]))!=0)
           RETURN_VAL (ret);
                
        if ((ret = strcmp(tpsz_ReadBufferPER[PER_UWY_NF],tpsz_ReadBufferTACCTRAA[TACCTRAA_RTY_NF]))!=0)
           RETURN_VAL (ret);
        
        RETURN_VAL(0);
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement pere                     */
/*--------------------------------------------------------------------------*/
int  n_ActionLignePER(char *tpsz_ReadBufferPER[])
{
     /* lancement de la 1ere synchro */
     if ( n_ProcessingRuptureSyncVar(&Kbd_RuptTACCTRAA,tpsz_ReadBufferPER) == ERR)
           return ERR;
     
        return OK;  
}

/*==============================================================================
objet :
	fonction de test de rupture sur l esclave

retour :
	0       ---> pbd_InRecOwner = pbd_InRecChild 
	> 0   	---> pbd_InRecOwner > pbd_InRecChild 
	< 0   	---> pbd_InRecOwner < pbd_InRecChild 
==============================================================================*/
int n_IsRuptTACCTRAA(
        char **ptb_InRec ,  /* adresse de la ligne en avance */
        char **ptb_InRec_Cur  ) /* adresse de la ligne courante */

{
	int ret ;
        DEBUT_FCT("n_IsRuptTACCTRAA");

        if((ret = strcmp(ptb_InRec[TACCTRAA_RETCTR_NF],ptb_InRec_Cur[TACCTRAA_RETCTR_NF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(ptb_InRec[TACCTRAA_RETSEC_NF],ptb_InRec_Cur[TACCTRAA_RETSEC_NF]))!=0)
           RETURN_VAL (ret);
                
        if ((ret = strcmp(ptb_InRec[TACCTRAA_RTY_NF],ptb_InRec_Cur[TACCTRAA_RTY_NF]))!=0)
           RETURN_VAL (ret);
        
        if ((ret = strcmp(ptb_InRec[TACCTRAA_TRNCOD_CF],ptb_InRec_Cur[TACCTRAA_TRNCOD_CF]))!=0)
           RETURN_VAL (ret);
        
        RETURN_VAL(0);
}

/*==============================================================================
objet :
        fonction lancee en rupture premiere

retour :        OK ---> traitement correctement effectue
                ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptTACCTRAA( char **pbd_InRecOwner,
			       char **pbd_InRecChild  )
{
        char    MsgAno[300] ;   /* message d'anomalie */

        DEBUT_FCT( "n_ActionFirstRupt1Gtar" ) ;

        /* initialisation indicateur de rapprochement */
        Kb_Rappro = b_PosteRappro( pbd_InRecChild[TACCTRAA_TRNCOD_CF], Kp_Dettrs ) ;

        /* initialisation indicateur que l on a pas un poste de provision*/
        Kc_Provision = n_TypePoste(pbd_InRecChild[TACCTRAA_TRNCOD_CF],Kp_Dettrs) ;


     /*------------------------------------------------------------*/
     /* si le type de poste renvoye par la fonction n_TypePoste    */
     /* est 0 , ca signifie que                                    */
     /* le poste passe en parametre n'a pas ete trouve dans DETTRS */
     /* et dans ce cas une anomalie est generee                    */
     /*------------------------------------------------------------*/

      if (Kc_Provision== 0)
      {
         sprintf(MsgAno,"The transaction code %s could not be found in table TDETTRS",pbd_InRecChild[TACCTRAA_TRNCOD_CF]);
         n_WriteAno(MsgAno);
      }


	RETURN_VAL ( OK ) ;
}

