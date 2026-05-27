/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTF0003.c
revision                      : $Revision: 1.1.1.1 $
date de creation              : 02/04/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
  CONTROLE DE DOUBLONS ET DE COHERENCES SUR LE FICHIER EN ENTREE ISSUE
DE L'IBNR TOOL, POUR CHARGEMENT DE TSEGEST

------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa><auteur> <description de la modification>
 21/06/1999 Yves B.  Le champ SEG_NF ne doit pas depasser 8 caracteres
                     sauf a new york (10 caracteres)
 27/03/2008 J. Ribot SPOT 15219  ASE15 : recompilation des programmes C
 21/06/2012 -=Dch=-  spot:233937: Solvency ajout
 08/10/2012 Florent  spot:24041: correction n_EcrireAnoFormat
 06/04/2014 JBG      :spot:25773 Modify void main declaration to int main
 01/06/2015 Florent  :spot:28694 Segmentation VIE
 11/05/2017 Florent :spira:58025 ajout de la version de la segmentation
 05/10/2018 Charles :MOD01 - IFRS17 - REQ 3.5
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
/* definition du caractere separateur */
#define SEPARATEUR '~'

/* definition de la position des champs du fichier en entree */
#define SEGEST_VRS_NF   0
#define SEGEST_SSD_CF   1
#define SEGEST_SEGTYP_CT 2
#define SEGEST_SEG_NF   3
#define SEGEST_UWY_NF   4
#define SEGEST_SEG_LL   5
#define SEGEST_CUR_CF   6
#define SEGEST_SEGNAT_CT  7
#define SEGEST_CTRRET_B   8
#define SEGEST_PRMAMT_M   9
#define SEGEST_CLMAMT_M   10
#define SEGEST_LOSRAT_R   11
#define SEGEST_AMORAT_CT  12
#define SEGEST_ACY_NF 13


/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE    *Kp_OutputFilAno ;  /* pointeur sur le fichier de sortie des anomalies */

T_RUPTURE_VAR   bd_RuptSegEst ;   /* variable de gestion de la rupture sur le fichier en entree */

char  Ksz_Usr[5] ;      /* parametre correspondant au code utilisateur */
char  Ksz_SegEst_Typ[2] ;   /* parametre correspondant au type du fichier entree */
char  Ksz_Date[30] ;      /* parametre correspondant a la date de traitement */
char  Ksz_LogTyp[2] ;     /* parametre correspondant au type de message */
char  Ksz_Format_Msg[50] ;    /* parametre correspondant au message d'ano pour les formats */
char  Ksz_Dupkey_Msg[50] ;    /* parametre correspondant au message d'ano pour les doublons */
char  Ksz_Row_Msg[20] ;   /* parametre */
char  Ksz_Col_Msg[20] ;   /* parametre */
char  Ksz_Nbenr_Msg[50] ;   /* parametre correspondant au message d'ano pour le nombre de champs */
char  Ksz_SegTyp_ct[2];


int Kn_Doublons ;     /* nombre de doublons sur la cle de rupture */
int Kn_NbrChampsAno ;   /* nombre d'anomalies sur le nombre de champs par ligne */
int Kn_SsdAno ;     /* nombre d'anomalies sur le champs SSD_CF */
int Kn_SegtypAno ;      /* nombre d'anomalies sur le champs SEGTYP_CT */
int Kn_SegAno ;       /* nombre d'anomalies sur le champs SEG_NF */
int Kn_UwyAno ;     /* nombre d'anomalies sur le champs UWY_NF */
int Kn_SegllAno ;     /* nombre d'anomalies sur le champs SEG_LL */
int Kn_CurAno ;     /* nombre d'anomalies sur le champs CUR_CF */
int Kn_SegnatAno ;      /* nombre d'anomalies sur le champs SEGNAT_CT */
int Kn_CtrretAno ;      /* nombre d'anomalies sur le champs CTRRET_B */
int Kn_PrmamtAno ;      /* nombre d'anomalies sur le champs PRMAMT_M */
int Kn_ClmamtAno ;      /* nombre d'anomalies sur le champs CLMAMT_M */
int Kn_LosratAno ;      /* nombre d'anomalies sur le champs LOSRAT_R */
int Kn_AmoratAno ;      /* nombre d'anomalies sur le champs AMORAT_CT */
int Kn_SegTypTraitAno;  /* nombre d'anomalie sur le type de segment */
int Kn_AcyAno ;         /* nombre d'anomalies sur le champs ACY_NF */
char Kc_Vie;            /* Si Y VIE , N dommage */

short Ks_LigneCourVide ;    /* variable correspondant a l'indication "ligne courante vide ?" */
short Ks_LigneSuivVide ;    /* variable correspondant a l'indication "ligne suivante vide ?" */

int n_InitSegEst    ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1SegEst    ( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptSegEst ( char **pbd_InRec_Cur ) ;
int n_ActionLigneSegEst   ( char **pbd_InRec_Cur ) ;
int n_ActionLastRuptSegEst  ( char **pbd_InRec_Cur ) ;

int n_IsInteger( char *sz_Champs ) ;
int n_IsNumeric( char *sz_Champs, int n_ent, int n_dec ) ;
int n_EcrireAnoFormat( int Col, int NbrAno ) ;
int n_EcrireAnoNbrChamps( int NbrAno ) ;
int n_NbrChamps( char **pbd_InRec_Cur ) ;


//ajout d'un tableau d'anomalie par colonne  -=Dch=-
char * Tbl_ANO[]= { "Subsidary issue", //0
          "Segment Type issue",        //1
          "Segment  issue",            //2
          "uwy issue",                 //3
          "Segment caption issue",     //4
          "Currency issue",            //5
          "Nat of segment issue",      //6
          "Retro Treaty issue",        //7
          "Premium Amount issue",      //8
          "Claim Amount issue",        //9
          "Loss Ratio issue",          //10
          "Amorat issue"  ,            //11
          "SegTyp parameter issue",    //12
          "acy issue"                  //13
          };

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
  /* Initialisation des signaux */
  InitSig () ;

  if ( n_BeginPgm ( argc, argv ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* recuperation des arguments passes au programme */
  strcpy( Ksz_Usr, psz_GetCharArgv( 1 ) ) ;
  strcpy( Ksz_SegEst_Typ, psz_GetCharArgv( 2 ) ) ;
  strcpy( Ksz_Date, psz_GetCharArgv( 3 ) ) ;
  strcpy( Ksz_LogTyp, psz_GetCharArgv( 4 ) ) ;
  strcpy( Ksz_Format_Msg, psz_GetCharArgv( 5 ) ) ;
  strcpy( Ksz_Dupkey_Msg, psz_GetCharArgv( 6 ) ) ;
  strcpy( Ksz_Row_Msg, psz_GetCharArgv( 7 ) ) ;
  strcpy( Ksz_Col_Msg, psz_GetCharArgv( 8 ) ) ;
  strcpy( Ksz_Nbenr_Msg, psz_GetCharArgv( 9 ) ) ;
  strcpy( Ksz_SegTyp_ct, psz_GetCharArgv( 10 ) ) ;
  Kc_Vie = *psz_GetCharArgv(11);

  /* ouverture du fichier de sortie des anomalies */
  if ( n_OpenFileAppl ( "ESTF0003_O1","wt",&Kp_OutputFilAno ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptSegEst */
  if ( n_InitSegEst( &bd_RuptSegEst ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation des compteurs d'anomalies sur les formats */
  Kn_SsdAno = 0 ;
  Kn_SegtypAno = 0 ;
  Kn_SegAno = 0 ;
  Kn_UwyAno = 0 ;
  Kn_SegllAno = 0 ;
  Kn_CurAno = 0 ;
  Kn_SegnatAno = 0 ;
  Kn_CtrretAno = 0 ;
  Kn_PrmamtAno = 0 ;
  Kn_ClmamtAno = 0 ;
  Kn_LosratAno = 0 ;
  Kn_AmoratAno = 0 ;
  Kn_NbrChampsAno = 0 ;
  Kn_SegTypTraitAno =0;
  Kn_AcyAno = 0 ;

  /* initialisation des variables "ligne vide ?" */
  Ks_LigneCourVide = 0 ;
  Ks_LigneSuivVide = 0 ;

  /* lancement du traitement */
  if ( n_ProcessingRuptureVar( &bd_RuptSegEst ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Ecriture en sortie du fichier des anomalies ( formats incorrects ) */
  if ( Kn_NbrChampsAno != 0 )
    n_EcrireAnoNbrChamps( Kn_NbrChampsAno ) ;

  if ( Kn_SsdAno != 0 )
    n_EcrireAnoFormat( 0, Kn_SsdAno ) ;

  if ( Kn_SegtypAno != 0 )
    n_EcrireAnoFormat( 1, Kn_SegtypAno ) ;

  if ( Kn_SegAno != 0 )
    n_EcrireAnoFormat( 2, Kn_SegAno ) ;

  if ( Kn_UwyAno != 0 )
    n_EcrireAnoFormat( 3, Kn_UwyAno ) ;

  if ( Kn_SegllAno != 0 )
    n_EcrireAnoFormat( 4, Kn_SegllAno ) ;

  if ( Kn_CurAno != 0 )
    n_EcrireAnoFormat( 5, Kn_CurAno ) ;

  if ( Kn_SegnatAno != 0 )
    n_EcrireAnoFormat( 6, Kn_SegnatAno ) ;

  if ( Kn_CtrretAno != 0 )
    n_EcrireAnoFormat( 7, Kn_CtrretAno ) ;

  if ( Kn_PrmamtAno != 0 )
    n_EcrireAnoFormat( 8, Kn_PrmamtAno ) ;

  if ( Kn_ClmamtAno != 0 )
    n_EcrireAnoFormat( 9, Kn_ClmamtAno ) ;

  if ( Kn_LosratAno != 0 )
    n_EcrireAnoFormat( 10, Kn_LosratAno ) ;

  if ( Kn_AmoratAno != 0 )
    n_EcrireAnoFormat( 11, Kn_AmoratAno ) ;

  if (Kn_SegTypTraitAno !=0)
    n_EcrireAnoFormat( 12, Kn_SegTypTraitAno ) ;

  if ( Kn_AcyAno != 0 )
    n_EcrireAnoFormat( 13, Kn_AcyAno ) ;

  if ( n_CloseFileAppl( "ESTF0003_I1", &( bd_RuptSegEst.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTF0003_O1", &Kp_OutputFilAno ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_EndPgm() == ERR )
    ExitPgm( ERR_XX , "" );

  exit(OK) ;
}


/*==============================================================================
objet :
  fonction d'initialisation de la variable de gestion de rupture du fichier
  maitre.

retour :
  0K
==============================================================================*/
int n_InitSegEst(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitSegEst" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier */
  if ( n_OpenFileAppl( "ESTF0003_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    return ERR ;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 1 ;

  /* fonction du test de rupture de niveau 1 */
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1SegEst ;

  /* Fonction lancee en rupture premiere */
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptSegEst ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneSegEst ;

  /* Fonction lancee en rupture derniere */
  pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptSegEst ;

  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de rupture de niveau 1

retour :
  0  ---> pas de rupture
  sinon     ---> rupture
==============================================================================*/
int n_IsR1SegEst(
  char **pbd_InRec ,  /* adresse de la ligne en avance */
  char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
  int ret ;

  DEBUT_FCT( "n_IsR1SegEst" ) ;

  /* la ligne courante est-elle vide ? */
  if ( pbd_InRec_Cur[0][0] == '\r' )
  {
    Ks_LigneCourVide = 1 ;
    RETURN_VAL( 1 ) ;
  }
  else
    Ks_LigneCourVide = 0 ;

  /* la ligne suivante est-elle vide ? */
  if ( pbd_InRec[0][0] == '\r' )
  {
    Ks_LigneSuivVide = 1 ;
    RETURN_VAL( 1 ) ;
  }
  else
    Ks_LigneSuivVide = 0 ;

  if ( ( ret = strcmp( pbd_InRec[SEGEST_VRS_NF], pbd_InRec_Cur[SEGEST_VRS_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[SEGEST_SSD_CF], pbd_InRec_Cur[SEGEST_SSD_CF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[SEGEST_SEGTYP_CT], pbd_InRec_Cur[SEGEST_SEGTYP_CT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[SEGEST_SEG_NF], pbd_InRec_Cur[SEGEST_SEG_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[SEGEST_UWY_NF], pbd_InRec_Cur[SEGEST_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRec[SEGEST_ACY_NF], pbd_InRec_Cur[SEGEST_ACY_NF] ) ) != 0 ) return ret ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction lancee en rupture premiere

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptSegEst( char **ptb_InRec_Cur )
{
  DEBUT_FCT( "n_ActionFirstRuptSegEst" ) ;

  /* si la ligne est vide, on sort sans traitement */
  if ( Ks_LigneCourVide == 1 )
  {
    RETURN_VAL( OK ) ;
  }

  /* initialisation des compteurs de doublons */
  Kn_Doublons = 0 ;

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneSegEst( char **ptb_InRec_Cur )
{
  char *p_EoL ;
  int  i_anoUWY=0;

  DEBUT_FCT( "n_ActionLigneSegEst" ) ;

  /* si la ligne courante est vide, on sort sans traitement */
  if ( Ks_LigneCourVide == 1 )
  {
    RETURN_VAL( OK ) ;
  }

  /* On ecrase le caractere de fin de ligne par un zero */
  p_EoL = memchr( ptb_InRec_Cur[0], '\r', MAX_LINESIZE ) ;
  if ( p_EoL != NULL )
    *p_EoL = 0 ;

  /* Calcul du nombre de doublons sur la cle de rupture */
  Kn_Doublons += 1 ;

  /* Verification du nombre de champs */
  if ( n_NbrChamps( ptb_InRec_Cur ) == FALSE )
  {
    Kn_NbrChampsAno += 1 ;

    /* on sort directement sans faire les tests suivants */
    RETURN_VAL( OK ) ;
  }

  /* Controle du champs SSD_CF: int et obligatoire */
  if ( *ptb_InRec_Cur[SEGEST_SSD_CF] == 0 || n_IsInteger( ptb_InRec_Cur[SEGEST_SSD_CF] ) == FALSE )
    Kn_SsdAno += 1 ;

  /* Controle du champs SEGTYP_CT: char(1) et obligatoire */
  if ( *ptb_InRec_Cur[SEGEST_SEGTYP_CT] == 0 ||  strlen( ptb_InRec_Cur[SEGEST_SEGTYP_CT] ) != 1 )
    Kn_SegtypAno += 1 ;

        /* Controle du champs SEG_NF: char(8) est obligatoire -- sauf NY : 10 caracteres */
        if ( atoi(ptb_InRec_Cur[SEGEST_SSD_CF]) == 10)
             {
              if ( *ptb_InRec_Cur[SEGEST_SEG_NF] == 0 || strlen( ptb_InRec_Cur[SEGEST_SEG_NF] ) <= 0 || strlen( ptb_InRec_Cur[SEGEST_SEG_NF] ) > 10 )
                Kn_SegAno += 1 ;
             }
        else  if ( *ptb_InRec_Cur[SEGEST_SEG_NF] == 0 || strlen( ptb_InRec_Cur[SEGEST_SEG_NF] ) <= 0 || strlen( ptb_InRec_Cur[SEGEST_SEG_NF] ) > 8 )
                Kn_SegAno += 1 ;

  /* Controle du champs UWY_NF: int et obligatoire */
  if ( *ptb_InRec_Cur[SEGEST_UWY_NF] == 0 || n_IsInteger( ptb_InRec_Cur[SEGEST_UWY_NF] ) == FALSE )
  {
    Kn_UwyAno += 1 ;
    i_anoUWY = 1;
  }

  /* Controle du champs SEG_LL: varchar(64) et obligatoire */
  if ( *ptb_InRec_Cur[SEGEST_SEG_LL] == 0 || strlen( ptb_InRec_Cur[SEGEST_SEG_LL] ) > 64 )
    Kn_SegllAno += 1 ;

  /* Controle du champs CUR_CF: char(3) et obligatoire */
  if ( *ptb_InRec_Cur[SEGEST_CUR_CF] == 0 || strlen( ptb_InRec_Cur[SEGEST_CUR_CF] ) != 3 )
    Kn_CurAno += 1 ;

  /* Controle du champs SEGNAT_CT: char(1) et obligatoire */
  if ( *ptb_InRec_Cur[SEGEST_SEGNAT_CT] == 0 || strlen( ptb_InRec_Cur[SEGEST_SEGNAT_CT] ) != 1 )
    Kn_SegnatAno += 1 ;

  /* Controle du champs CTRRET_B: booleen et obligatoire */
  if ( *ptb_InRec_Cur[SEGEST_CTRRET_B] == 0 || ( *ptb_InRec_Cur[SEGEST_CTRRET_B] != '0' && *ptb_InRec_Cur[SEGEST_CTRRET_B] != '1' ) )
    Kn_CtrretAno += 1 ;

  /* Controle du champs PRMAMT_M: decimal(18.3) et facultatif */
  if ( n_IsNumeric( ptb_InRec_Cur[SEGEST_PRMAMT_M], 15, 3 ) == FALSE )
    Kn_PrmamtAno += 1 ;

  /* Controle du champs CLMAMT_M: decimal(18.3) et facultatif */
  if ( n_IsNumeric( ptb_InRec_Cur[SEGEST_CLMAMT_M], 15, 3 ) == FALSE )
    Kn_ClmamtAno += 1 ;

  /* Controle du champs LOSRAT_R: decimal(9.8) et facultatif */
  if ( n_IsNumeric( ptb_InRec_Cur[SEGEST_LOSRAT_R], 1, 8 ) == FALSE )
    Kn_LosratAno += 1 ;

  /* Controle du champs AMORAT_CT: char(1) et facultatif */
  if ( strlen( ptb_InRec_Cur[SEGEST_AMORAT_CT] ) != 1 )
    Kn_AmoratAno += 1 ;

  /* MOD01*/
  if (strncmp(Ksz_SegTyp_ct, "A", strlen(Ksz_SegTyp_ct)) ==0){
           if (strncmp(ptb_InRec_Cur[SEGEST_SEGTYP_CT], Ksz_SegTyp_ct, strlen(ptb_InRec_Cur[SEGEST_SEGTYP_CT]))!=0)
                   if (strncmp(ptb_InRec_Cur[SEGEST_SEGTYP_CT], "V", strlen(ptb_InRec_Cur[SEGEST_SEGTYP_CT]))!=0)
                     Kn_SegTypTraitAno +=1;
					 
  }else{
		if (strncmp(Ksz_SegTyp_ct, "T", strlen(Ksz_SegTyp_ct)) ==0){
			if (strncmp(ptb_InRec_Cur[SEGEST_SEGTYP_CT], Ksz_SegTyp_ct, strlen(ptb_InRec_Cur[SEGEST_SEGTYP_CT]))!=0)
                   if (strncmp(ptb_InRec_Cur[SEGEST_SEGTYP_CT], "W", strlen(ptb_InRec_Cur[SEGEST_SEGTYP_CT]))!=0)
                     Kn_SegTypTraitAno +=1;
					 
		}else{
			if (strncmp(Ksz_SegTyp_ct, "U", strlen(Ksz_SegTyp_ct)) ==0){
				if (strncmp(ptb_InRec_Cur[SEGEST_SEGTYP_CT], Ksz_SegTyp_ct, strlen(ptb_InRec_Cur[SEGEST_SEGTYP_CT]))!=0)
					if (strncmp(ptb_InRec_Cur[SEGEST_SEGTYP_CT], "X", strlen(ptb_InRec_Cur[SEGEST_SEGTYP_CT]))!=0)
						Kn_SegTypTraitAno +=1;
						
			}else{
				if (strncmp(ptb_InRec_Cur[SEGEST_SEGTYP_CT], Ksz_SegTyp_ct, strlen(ptb_InRec_Cur[SEGEST_SEGTYP_CT]))!=0)
							Kn_SegTypTraitAno +=1;
							
			}
		}
  }
  /* MOD01*/
  	  
  /* Controle du champs ACY_NF: int et obligatoire */
  if ( *ptb_InRec_Cur[SEGEST_ACY_NF] == 0 || n_IsInteger( ptb_InRec_Cur[SEGEST_ACY_NF] ) == FALSE )
    {
    Kn_AcyAno += 1 ;
    fprintf( Kp_OutputFilAno, "%s~%s~%s : %d %s %s/%s/%s/%s/%s~%s\n",
      Ksz_Usr,
      Ksz_LogTyp,
      Ksz_SegEst_Typ,
      0,
      "ACY_NF absente",
      ptb_InRec_Cur[SEGEST_SSD_CF],
      ptb_InRec_Cur[SEGEST_SEGTYP_CT],
      ptb_InRec_Cur[SEGEST_SEG_NF],
      ptb_InRec_Cur[SEGEST_UWY_NF],
      ptb_InRec_Cur[SEGEST_ACY_NF],
      Ksz_Date ) ;
     }
  else if ( (Kc_Vie == 'Y' && i_anoUWY == 0 && atoi(ptb_InRec_Cur[SEGEST_ACY_NF]) < atoi(ptb_InRec_Cur[SEGEST_UWY_NF]))
            || (Kc_Vie == 'N' && *ptb_InRec_Cur[SEGEST_ACY_NF]!= '0') )
{
    Kn_AcyAno += 1 ;
    fprintf( Kp_OutputFilAno, "%s~%s~%s : %d %s %s/%s/%s/%s/%s/%s~%s\n",
      Ksz_Usr,
      Ksz_LogTyp,
      Ksz_SegEst_Typ,
      0,
      "ACY_NF < UWY_NF",
      ptb_InRec_Cur[SEGEST_VRS_NF],
      ptb_InRec_Cur[SEGEST_SSD_CF],
      ptb_InRec_Cur[SEGEST_SEGTYP_CT],
      ptb_InRec_Cur[SEGEST_SEG_NF],
      ptb_InRec_Cur[SEGEST_UWY_NF],
      ptb_InRec_Cur[SEGEST_ACY_NF],
      Ksz_Date ) ;
     }

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  fonction lancee en rupture derniere

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptSegEst( char **ptb_InRec_Cur )
{
  DEBUT_FCT( "n_ActionLastRuptSegEst" ) ;

  /* si la ligne est vide, on sort sans traitement */
  if ( Ks_LigneCourVide == 1 )
  {
    RETURN_VAL( OK ) ;
  }

  /* Ecriture en sortie du fichier des anomalies ( doublons sur la cle ) */
  if ( Kn_Doublons > 1 )
    fprintf( Kp_OutputFilAno, "%s~%s~%s : %d %s %s/%s/%s/%s/%s/%s~%s\n",
      Ksz_Usr,
      Ksz_LogTyp,
      Ksz_SegEst_Typ,
      Kn_Doublons,
      Ksz_Dupkey_Msg,
      ptb_InRec_Cur[SEGEST_VRS_NF],
      ptb_InRec_Cur[SEGEST_SSD_CF],
      ptb_InRec_Cur[SEGEST_SEGTYP_CT],
      ptb_InRec_Cur[SEGEST_SEG_NF],
      ptb_InRec_Cur[SEGEST_UWY_NF],
      ptb_InRec_Cur[SEGEST_ACY_NF],
      Ksz_Date ) ;

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
  fonction de controle d'un champs numerique

retour :  TRUE ---> le champs est de type numerique
    FALSE --> le champs n'est pas de type numerique
==============================================================================*/
int n_IsInteger( char *sz_Champs )
{
  int i ;

  for( i = 0; sz_Champs[i] != 0;  i++ )
  {
    if ( sz_Champs[i] > '9' || sz_Champs[i] < '0' )
      return( FALSE ) ;
  }

  return( TRUE ) ;
}


/*==============================================================================
objet :
  fonction de controle d'un champs de type decimal(18.3)

arguments:
  - champs a verifier
  - longueur maxi de la partie entiere
  - longueur maxi de la partie decimal

retour :  TRUE ---> le champs est de type decimal(18.3)
    FALSE --> le champs n'est pas de type decimal(18.3)
==============================================================================*/
int n_IsNumeric( char *sz_Champs, int n_ent, int n_dec )
{
  int i ;
  int n_PointLu = FALSE ;
  int n_LgEntiere = 0 ;
  int n_LgDec = 0 ;

  /* 1er cas: le premier caractere est un signe ( '+' ou '-' ) */
  if ( sz_Champs[0] == '+' || sz_Champs[0] == '-' )
  {
    for( i = 1; sz_Champs[i] != 0;  i++ )
    {
      if ( sz_Champs[i] == '.' )
      {
        if ( n_PointLu == TRUE )
          return( FALSE ) ;
        else  n_PointLu = TRUE ;
      }
      else
      {
        /* test sur la numericite du caractere */
        if ( sz_Champs[i] > '9' || sz_Champs[i] < '0' )
          return( FALSE ) ;
        else
        {
          if ( n_PointLu == TRUE )
            n_LgDec += 1 ;
          else  n_LgEntiere += 1 ;
        }
      }
    }
  }

  /* 2eme cas: le premier caractere n'est pas un signe ( '+' ou '-' ) */
  else
  {
    for( i = 0; sz_Champs[i] != 0;  i++ )
    {
      if ( sz_Champs[i] == '.' )
      {
        if ( n_PointLu == TRUE )
          return( FALSE ) ;
        else  n_PointLu = TRUE ;
      }
      else
      {
        /* test sur la numericite du caractere */
        if ( sz_Champs[i] > '9' || sz_Champs[i] < '0' )
          return( FALSE ) ;
        else
        {
          if ( n_PointLu == TRUE )
            n_LgDec += 1 ;
          else  n_LgEntiere += 1 ;
        }
      }
    }
  }

  /* test sur la longueur de la partie entiere */
  if ( n_LgEntiere > n_ent )
    return( FALSE ) ;

  /* test sur la longueur de la partie decimale */
  if ( n_LgDec > n_dec )
    return( FALSE ) ;

  return( TRUE ) ;
}


/*==============================================================================
objet :
  fonction d'ecriture dans le fichier des anomalies ( message d'anomalie
sur la colonne passee en argument

retour :  0
==============================================================================*/
int n_EcrireAnoFormat( int Col, int NbrAno )
{
  /* Ecriture en sortie du fichier des anomalies */
  fprintf( Kp_OutputFilAno, "%s~%s~%s : %s %d : %d %s %s~%s\n",
    Ksz_Usr,
    Ksz_LogTyp,
    Ksz_SegEst_Typ,
    Ksz_Col_Msg,
    Col,
    NbrAno,
    Ksz_Format_Msg,
    Tbl_ANO[Col],
    Ksz_Date) ;

  return( 0 ) ;
}

/*==============================================================================
objet :
  fonction d'ecriture dans le fichier des anomalies liees au nombre
de champs de l'enregistrement

retour :  0
==============================================================================*/
int n_EcrireAnoNbrChamps( int NbrAno )
{
  /* Ecriture en sortie du fichier des anomalies */
  fprintf( Kp_OutputFilAno, "%s~%s~%s : %d %s~%s\n",
    Ksz_Usr,
    Ksz_LogTyp,
    Ksz_SegEst_Typ,
    NbrAno,
    Ksz_Nbenr_Msg,
    Ksz_Date ) ;

  return( 0 ) ;
}


/*==============================================================================
objet :
  fonction de verification du nombre de champs de la ligne courante

retour :  TRUE si le nombre de champs est 12
    FALSE si different
==============================================================================*/
int n_NbrChamps( char **pbd_InRec_Cur )
{

  /* test sur le dernier champs */
  if ( pbd_InRec_Cur[SEGEST_ACY_NF] == NULL )
    return( FALSE ) ;
  else
  {
    /* test sur le suivant */
    if ( pbd_InRec_Cur[SEGEST_ACY_NF + 1] == NULL )
      return( TRUE ) ;
    else  return( FALSE ) ;
  }
}
