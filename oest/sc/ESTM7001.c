
/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTM7001.c
révision                      : $Revision: 1.2 $
date de creation              : 19/10/1999
auteur                        : J. Ribot
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   TRAITEMENT DES TRANSFERTS DE PORTEFEUILLE  - partie GT -
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27 09 2002    J RIBOT        ajout parametre DATE BILAN
    19/08/2003    R Cassis       ajout date bilan et annee bilan et modification des
                                 periodes année, mois, jour a partir de ces parametres
          31/12/2003    R Cassis       suppression restriction sur TRSTYP_CT = 2 - on prend tout maintenant
                                       et correction probleme de gestion sans rupture
          21/01/2004    R Cassis       maj ESTM7001 : Ajout création fichier en sortie contenant les données
                                       estimation avec filiale emettrice
                                       (dans la cas ou l'année bilan = celle du parametre) et
                                       on inverse le montant.
    20/02/2006    M.DJELLOULI    MOD005 - Flag FORCEBILAN Forcé Bilan à à 31/12/N-1 (1=Oui par Défaut / 0= Bilan N préservé)
    27/04/2007    J. Ribot       MOD006 - SPOT TRV14131 suppression test sur date TRFCROSSREF
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
    14/05/2009   R. Cassis       :spot:17397  V108 - Si sinistre non trouve, maintenant on met null a la place, il sera transféré et sort en anomalie.
[09] 27/06/2014 R. Cassis :spot:25036 Modifie compteur du NB_DETTRS_MAX (triplé)
[XX] 06/04/2014 JBG :spot:25773 Modify void main declaration to int main
[XX] 09/10/2014 JBG :spot:25773  suppress warning: unused variables
[12] 05/02/2016 Florent   :spot:29066 on utilise le struct.h
[13] 05/05/2021 SA   :Spira :96135 Change NB_DETTRS_MAX from 30000 to 40000
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include "struct.h"
#include "ESTM7001.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define NB_TRF_MAX    20000 /* Le nombre max de postes est fixe a 20000 */
#define NB_CLM_MAX    20000 /* Le nombre max de postes est fixe a 20000 */
#define NB_DETTRS_MAX 40000 /* Le nombre max de postes est fixe a 40000 [003] */

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE    *Kp_OutputFilGt ;   /* pointeur sur le fichier de sortie GT */
FILE    *Kp_OutputFilGtEst ;    /* pointeur sur le fichier de sortie GT EStimation */
FILE    *Kp_InputFilTrf ;   /* pointeur sur le fichier en entree T_TRFCROSSREF */
FILE    *Kp_InputFilTclm ;    /* pointeur sur le fichier en entree T_TCLMCROSSREF */
FILE    *Kp_InputFilDettrs ;    /* pointeur sur le fichier en entree T_DETTRS */
FILE    *Kp_OutputFilCtrNotFound; /* pointeur sur le fichier des contrats non trouves */
FILE    *Kp_OutputFilClmNotFound; /* pointeur sur le fichier des sinistres non trouves */
FILE    *Kp_OutputFilRetExclus;   /* pointeur sur le fichier des contrats retros non traites */
T_RUPTURE_VAR bd_RuptGt ;     /* variable de gestion de la rupture sur le GT */

T_TRFCROSSREF Ktbd_Trf[NB_TRF_MAX] ;
int   Kn_NbLigTrf = 0 ; /* nombre de lignes du tableau Ktbd_Trf */
T_TCLMCROSSREF  Ktbd_Tclm[NB_CLM_MAX] ;
int   Kn_NbLigTclm = 0 ; /* nombre de lignes du tableau Ktbd_Tclm */
T_DETTRS        Ktbd_Dettrs[NB_DETTRS_MAX] ;
int   Kn_NbLigDettrs = 0 ; /* nombre de lignes du tableau Ktbd_Dettrs */
char    Ksz_Annee[5]  ;

int n_InitGt      ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneGt   ( char **pbd_InRec_Cur ) ;

int n_InitRecond    ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneRecond   ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncRecond ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


int n_Processing (T_RUPTURE_VAR *);
int n_ChargerTRF( );
int n_RechCtr( char *sz_ctr );
int n_ChargerTCLM( );
int n_RechClm( int  n_clm, int n_ssd );
int n_ChargerDETTRS( );
int n_RechTrn( char *sz_trn );

int     n_parm_BALSHEY_NF;
char    sz_parm_BLCSHT_D[8];
unsigned char c_parm_ESTIM_B;       /* 0/1 - si = 1 -> Postes estimations sont pris en compte */
char    sz_NotFound_CTR_NF[10] = ""; /* zone travail pour Contrats non trouves */
int     n_NotFound_CLM_NF;    /* zone travail pour sinistres non trouves */
unsigned char   c_NotFound_SSD_CF = 0;  /* zone travail pour sinistres/filiales non trouves */
char    sz_AMT_M[19];     /* zone travail pour montants a inverser */
char    sz_RETAMT_M[19];    /* zone travail pour montants a inverser */
char    sz_RETINTAMT_M[19];   /* zone travail pour montants a inverser */
char    sz_sav_AMT_M[19];   /* pointeur adresse de sauvegarde pour montants a inverser */
char    sz_sav_RETAMT_M[19];    /* pointeur adresse de sauvegarde pour montants a inverser */
char    sz_sav_RETINTAMT_M[19];   /* pointeur adresse de sauvegarde pour montants a inverser */
char    sz_Exclus_RETCTR_NF[10] = ""; /* zone travail pour Contrats Retro non traites */
int     n_parm_FORCEBILAN;    /* MOD005 - Flag FORCEBILAN Forcé Bilan à à 31/12/N-1 (1=Oui par Défaut / 0= Bilan N préservé) */
int     n_parm_QTRLIM_NF;
int     n_parm_TRANSF_ESB;    /* flag transfert etablissement (1=Oui / 0=Non par defaut) */
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

  strcpy(sz_parm_BLCSHT_D, psz_GetCharArgv(1)) ;
  n_parm_BALSHEY_NF = atoi(psz_GetCharArgv(2)) ;
  c_parm_ESTIM_B = atoi(psz_GetCharArgv(3)) ;
  n_parm_FORCEBILAN = atoi(psz_GetCharArgv(4)) ;
  n_parm_QTRLIM_NF = atoi(psz_GetCharArgv(5)) ;
  n_parm_TRANSF_ESB = atoi(psz_GetCharArgv(6)) ;

  /* ouverture du fichier en entree TRF */
  if ( n_OpenFileAppl ( "ESTM7001_I2", "rb", &Kp_InputFilTrf ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en entree TCLM */
  if ( n_OpenFileAppl ( "ESTM7001_I3", "rb", &Kp_InputFilTclm ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en entree TDETTRS */
  if ( n_OpenFileAppl ( "ESTM7001_I4", "rb", &Kp_InputFilDettrs ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie des transferts */
  if ( n_OpenFileAppl ( "ESTM7001_O1", "wt", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie des donnees en entree Estimees */
  if ( n_OpenFileAppl ( "ESTM7001_O2", "wt", &Kp_OutputFilGtEst ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie des contrats non trouves */
  if ( n_OpenFileAppl ( "ESTM7001_O3", "wt", &Kp_OutputFilCtrNotFound ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie des sinistres non trouves */
  if ( n_OpenFileAppl ( "ESTM7001_O4", "wt", &Kp_OutputFilClmNotFound ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie des contrats retro non traites */
  if ( n_OpenFileAppl ( "ESTM7001_O5", "wt", &Kp_OutputFilRetExclus ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGt */
  if ( n_InitGt( &bd_RuptGt ) )
    ExitPgm( ERR_XX , "" ) ;

  printf("chargment des tables\n");

  /* Chargement des postes en memoire */
  if ( (Kn_NbLigTrf = n_ChargerTRF( )) == -1 )
    ExitPgm( ERR_XX , "" ) ;
  Kn_NbLigTclm = n_ChargerTCLM( );
  Kn_NbLigDettrs = n_ChargerDETTRS( );

  /* Lancement du traitement sans rupture */
  if ( n_Processing( &bd_RuptGt ) == ERR)
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7001_I1", &( bd_RuptGt.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7001_I2", &Kp_InputFilTrf ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7001_I3", &Kp_InputFilTclm ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7001_I4", &Kp_InputFilDettrs ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7001_O1", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7001_O2", &Kp_OutputFilGtEst ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7001_O3", &Kp_OutputFilCtrNotFound ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7001_O4", &Kp_OutputFilClmNotFound ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7001_O5", &Kp_OutputFilRetExclus ) == ERR )
    ExitPgm( ERR_XX , "" );

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
int n_InitGt(T_RUPTURE_VAR  *pbd_Rupt)
{

  DEBUT_FCT( "n_InitGt" ) ;

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  /* ouverture du fichier maitre GT */
  if ( n_OpenFileAppl( "ESTM7001_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    RETURN_VAL(  ERR ) ;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneGt ;
  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}

/*=============================================================================
objet :
  fonction d'appel a la boucle de traitement.
        lors de la sortie de la boucle impression dans fichier compte rendu.
        Ce programmme ne gere pas de rupture, un traitement sera lance a chaque
        ligne.
retour :
  ERR si on a rencontre un probleme.
=============================================================================*/
int n_Processing(T_RUPTURE_VAR *Kbd_ruptFIC_IN)
{
  int n_Resultat;

  DEBUT_FCT("n_Processing");

  n_Resultat = n_ProcessingRuptureVar (Kbd_ruptFIC_IN);

  return (n_Resultat);
}

/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGt( char **ptb_InRec_Cur )
{

  char sz_ACCESB[5], sz_DESTACCESB[5], sz_DESTSSD[5], sz_DESTCLM[20];
  char sz_Balshamj[10];
  int  n_indctr;
  int  n_indclm;
  int  n_indtrn;
  char sz_BLCSHT_D_DAY[3];
  char sz_an[5];
  char sz_mois[3];
  char sz_jour[3];
  int  i;

  DEBUT_FCT( "n_ActionLigneGt" ) ;

  /* Contrats retros exclus  */
  if ((ptb_InRec_Cur[GT_TRNCOD_CF][0] != '1') &&
      (ptb_InRec_Cur[GT_TRNCOD_CF][0] != '3'))
  {
    if (strcmp(sz_Exclus_RETCTR_NF, ptb_InRec_Cur[GT_RETCTR_NF]) != 0)
    {
      fprintf ( Kp_OutputFilRetExclus, "%s\n", ptb_InRec_Cur[GT_CTR_NF] );
      strcpy (sz_Exclus_RETCTR_NF, ptb_InRec_Cur[GT_RETCTR_NF]);
    }
    return (OK);
  }

  /* recherche du contrat */

  i = n_RechCtr(ptb_InRec_Cur[GT_CTR_NF]);
  n_indctr = i;

  if (n_indctr < 0)
  {
    if (strcmp(sz_NotFound_CTR_NF, ptb_InRec_Cur[GT_CTR_NF]) != 0)
    {
      fprintf ( Kp_OutputFilCtrNotFound, "%s\n", ptb_InRec_Cur[GT_CTR_NF] );
      strcpy (sz_NotFound_CTR_NF, ptb_InRec_Cur[GT_CTR_NF]);
    }
    return (OK);
  }

  /* recherche du sinistre */

  n_indclm = n_RechClm(atoi(ptb_InRec_Cur[GT_CLM_NF]), atoi(ptb_InRec_Cur[GT_SSD_CF]));

  if ((n_indclm < 0) && (n_indclm != -10))
  {
    fprintf ( Kp_OutputFilClmNotFound, "%s~%s~%s\n",
              ptb_InRec_Cur[GT_CTR_NF],                    //  V108 - on stocke également le contrat
              ptb_InRec_Cur[GT_CLM_NF],
              ptb_InRec_Cur[GT_SSD_CF] );
    n_NotFound_CLM_NF = atoi(ptb_InRec_Cur[GT_CLM_NF]);
    c_NotFound_SSD_CF = atoi(ptb_InRec_Cur[GT_SSD_CF]);
    if (n_indclm != -1)
    {
      return (OK);    /* Si sinistre non trouve, on met null - V108 */
    }
  }

  /* recherche du poste comptable */
  i = n_RechTrn(ptb_InRec_Cur[GT_TRNCOD_CF]);
  n_indtrn = i;

  if (n_indtrn < 0)
  {
    return (OK);
  }
  /* formatage date bilan ssaammjj */
  sprintf(sz_Balshamj, "%4d%02d%02d",
          atoi(ptb_InRec_Cur[GT_BALSHEY_NF]),
          atoi(ptb_InRec_Cur[GT_BALSHRMTH_NF]),
          atoi(ptb_InRec_Cur[GT_BALSHRDAY_NF]));

  if ((ptb_InRec_Cur[GT_TRNCOD_CF][0] == '1'   ||
       ptb_InRec_Cur[GT_TRNCOD_CF][0] == '3' ) &&
      (ptb_InRec_Cur[GT_TRNCOD_CF][1] == '1'   ||
       ptb_InRec_Cur[GT_TRNCOD_CF][1] == '2'   ||
       ptb_InRec_Cur[GT_TRNCOD_CF][1] == '3' ) &&
      (ptb_InRec_Cur[GT_TRNCOD_CF][7] == '0'   ||
       ptb_InRec_Cur[GT_TRNCOD_CF][7] == '1' ))
  {

    sprintf(sz_ACCESB, "%d", Ktbd_Trf[n_indctr].ACCESB_CF);
    sprintf(sz_DESTSSD, "%d", Ktbd_Trf[n_indctr].DESTSSD_CF);
    sprintf(sz_DESTACCESB, "%d", Ktbd_Trf[n_indctr].DESTACCESB_CF);
////   TRANSFERT ETABLISSEMENT   /////////
    if ( n_parm_TRANSF_ESB == 1 )
    {

      if ((Ktbd_Dettrs[n_indtrn].TRSTYP_CT == 3 ) &&
          (atoi(ptb_InRec_Cur[GT_BALSHEY_NF]) == n_parm_BALSHEY_NF) &&
          (ptb_InRec_Cur[GT_TRNCOD_CF][6] != '1') &&
          (ptb_InRec_Cur[GT_TRNCOD_CF][7] != '1'))
      {
        strncpy(sz_an, sz_parm_BLCSHT_D, 4);
        sz_an[4] = '\0';
        ptb_InRec_Cur[GT_BALSHEY_NF] = sz_an ;
        sprintf(sz_mois, "%2.2s", sz_parm_BLCSHT_D + 4);
        ptb_InRec_Cur[GT_BALSHRMTH_NF] = sz_mois ;
        sprintf(sz_jour, "%d", atoi(strncpy(sz_BLCSHT_D_DAY, sz_parm_BLCSHT_D + 6, 2)));
        ptb_InRec_Cur[GT_BALSHRDAY_NF] = sz_jour ;

        sprintf(sz_sav_AMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_AMT_M]));
        sprintf(sz_sav_RETAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETAMT_M]));
        sprintf(sz_sav_RETINTAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]));

        if ((double)atof(ptb_InRec_Cur[GT_AMT_M]) != 0.0)
        {
          sprintf(sz_AMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_AMT_M]) * -1);
          ptb_InRec_Cur[GT_AMT_M] = sz_AMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETAMT_M]) != 0.0)
        {
          sprintf(sz_RETAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETAMT_M]) * -1);
          ptb_InRec_Cur[GT_RETAMT_M] = sz_RETAMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]) != 0.0)
        {
          sprintf(sz_RETINTAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]) * -1);
          ptb_InRec_Cur[GT_RETINTAMT_M] = sz_RETINTAMT_M;
        }

        /* reconduction du GT en sortie */
        n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 );

        /* restaure adresses pour la suite */
        if ((double)atof(ptb_InRec_Cur[GT_AMT_M]) != 0.0)
        {
          ptb_InRec_Cur[GT_AMT_M] = sz_sav_AMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETAMT_M]) != 0.0)
        {
          ptb_InRec_Cur[GT_RETAMT_M] = sz_sav_RETAMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]) != 0.0)
        {
          ptb_InRec_Cur[GT_RETINTAMT_M] = sz_sav_RETINTAMT_M;
        }

        ptb_InRec_Cur[GT_ESB_CF] = sz_DESTACCESB;

        if (n_indclm == -1)
        {
          strcpy(ptb_InRec_Cur[GT_CLM_NF], "");         /* Si sinistre non trouve, on met null - V108 */
        }

        /* reconduction du GT en sortie */
        n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 );

      }
// si ARCSTATGTA bilan GT < bilan en cours
      if  (atoi(ptb_InRec_Cur[GT_BALSHEY_NF]) < n_parm_BALSHEY_NF)
      {

        sprintf(sz_sav_AMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_AMT_M]));
        sprintf(sz_sav_RETAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETAMT_M]));
        sprintf(sz_sav_RETINTAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]));

        if ((double)atof(ptb_InRec_Cur[GT_AMT_M]) != 0.0)
        {
          sprintf(sz_AMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_AMT_M]) * -1);
          ptb_InRec_Cur[GT_AMT_M] = sz_AMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETAMT_M]) != 0.0)
        {
          sprintf(sz_RETAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETAMT_M]) * -1);
          ptb_InRec_Cur[GT_RETAMT_M] = sz_RETAMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]) != 0.0)
        {
          sprintf(sz_RETINTAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]) * -1);
          ptb_InRec_Cur[GT_RETINTAMT_M] = sz_RETINTAMT_M;
        }

        /* reconduction du GT en sortie */
        n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 );

        /* restaure adresses pour la suite */
        if ((double)atof(ptb_InRec_Cur[GT_AMT_M]) != 0.0)
        {
          ptb_InRec_Cur[GT_AMT_M] = sz_sav_AMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETAMT_M]) != 0.0)
        {
          ptb_InRec_Cur[GT_RETAMT_M] = sz_sav_RETAMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]) != 0.0)
        {
          ptb_InRec_Cur[GT_RETINTAMT_M] = sz_sav_RETINTAMT_M;
        }

        ptb_InRec_Cur[GT_ESB_CF] = sz_DESTACCESB;

        if (n_indclm == -1)
        {
          strcpy(ptb_InRec_Cur[GT_CLM_NF], "");         /* Si sinistre non trouve, on met null - V108 */
        }

        /* reconduction du GT en sortie */
        n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 );

      }

      return (OK);
    }

//////////////   FIN TRANSFERT ETABLISSEMENT ///////////////
    if (n_indclm != -10 && n_indclm != -1)
    {
      sprintf(sz_DESTCLM, "%d", Ktbd_Tclm[n_indclm].DESTCLM_NF);
      ptb_InRec_Cur[GT_CLM_NF] = sz_DESTCLM;
    }
    ptb_InRec_Cur[GT_ESB_CF] = sz_DESTACCESB;
    ptb_InRec_Cur[GT_SSD_CF] = sz_DESTSSD;
    ptb_InRec_Cur[GT_CTR_NF] = Ktbd_Trf[n_indctr].DESTCTR_NF;
    /*  si poste comptable = Provision et année bilan = bilan courant et poste ouverture bilan
       on ecrit pas en sortie */
    if ((Ktbd_Dettrs[n_indtrn].TRSTYP_CT == 3 ) &&
        (atoi(ptb_InRec_Cur[GT_BALSHEY_NF]) == n_parm_BALSHEY_NF) &&
        ((ptb_InRec_Cur[GT_TRNCOD_CF][6] == '1') ||
         (ptb_InRec_Cur[GT_TRNCOD_CF][7] == '1')))
    {
      return (OK);
    }

    /*  si poste comptable different de Provision etposte cedante et année bilan = bilan courant et ouverture bilan
        et mois <= au mois trimestre et force bilan = 1
       on change les periodes par la BLCSHT_D du parm */
    if ((Ktbd_Dettrs[n_indtrn].TRSTYP_CT != 3 ) &&
        (atoi(ptb_InRec_Cur[GT_BALSHEY_NF]) == n_parm_BALSHEY_NF) &&     /* modif jr 29 09 02 == 1999 */

        (atoi(ptb_InRec_Cur[GT_BALSHRMTH_NF]) <= n_parm_QTRLIM_NF))     /* MOD006 */
    {
      if (n_parm_FORCEBILAN == 1)        // MOD005
      {
        sprintf(sz_an, "%d", n_parm_BALSHEY_NF - 1);
        ptb_InRec_Cur[GT_BALSHEY_NF] = sz_an ;
        sprintf(sz_mois, "%d", 12);
        ptb_InRec_Cur[GT_BALSHRMTH_NF] = sz_mois ;
        sprintf(sz_jour, "%d", 31);
        ptb_InRec_Cur[GT_BALSHRDAY_NF] = sz_jour ;
      }
    }
    /*  si poste comptable different de Provision etposte cedante et année bilan = bilan courant et ouverture bilan
        et mois > au mois trimestre et force bilan = 1
       on change les periodes par la BLCSHT_D du parm */
    if ((Ktbd_Dettrs[n_indtrn].TRSTYP_CT != 3 ) &&
        (atoi(ptb_InRec_Cur[GT_BALSHEY_NF]) == n_parm_BALSHEY_NF) &&     /* modif jr 29 09 02 == 1999 */
        (atoi(ptb_InRec_Cur[GT_BALSHRMTH_NF]) > n_parm_QTRLIM_NF))     /* MOD006 */
    {
      if (n_parm_FORCEBILAN == 1)        // MOD005
      {
        strncpy(sz_an, sz_parm_BLCSHT_D, 4);
        sz_an[4] = '\0';
        ptb_InRec_Cur[GT_BALSHEY_NF] = sz_an ;
        sprintf(sz_mois, "%2.2s", sz_parm_BLCSHT_D + 4);
        ptb_InRec_Cur[GT_BALSHRMTH_NF] = sz_mois ;
        sprintf(sz_jour, "%d", atoi(strncpy(sz_BLCSHT_D_DAY, sz_parm_BLCSHT_D + 6, 2)));
        ptb_InRec_Cur[GT_BALSHRDAY_NF] = sz_jour ;
      }
    }

    /*  si poste comptable = Provision et année bilan = bilan courant et poste cloture bilan
       on change les periodes par la BLCSHT_D du parm */
    if ((Ktbd_Dettrs[n_indtrn].TRSTYP_CT == 3 ) &&
        (atoi(ptb_InRec_Cur[GT_BALSHEY_NF]) == n_parm_BALSHEY_NF) &&
        (ptb_InRec_Cur[GT_TRNCOD_CF][6] != '1') &&
        (ptb_InRec_Cur[GT_TRNCOD_CF][7] != '1'))
    {
      strncpy(sz_an, sz_parm_BLCSHT_D, 4);
      sz_an[4] = '\0';
      ptb_InRec_Cur[GT_BALSHEY_NF] = sz_an ;
      sprintf(sz_mois, "%2.2s", sz_parm_BLCSHT_D + 4);
      ptb_InRec_Cur[GT_BALSHRMTH_NF] = sz_mois ;
      sprintf(sz_jour, "%d", atoi(strncpy(sz_BLCSHT_D_DAY, sz_parm_BLCSHT_D + 6, 2)));
      ptb_InRec_Cur[GT_BALSHRDAY_NF] = sz_jour ;
    }

    /* reconduction du GT en sortie */
    n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

    return (OK);
  }
  else
  {
    /* Ajout instructions pour gérer maintenant les postes Estimations  - R. Cassis - 07/01/2004 */
    /* Et generer un fichier des donnees en entree avce montant inverse - R. Cassis - 21/01/2004 */
    if (c_parm_ESTIM_B == 1)
    {
      if (atoi(ptb_InRec_Cur[GT_BALSHEY_NF]) == n_parm_BALSHEY_NF)
      {
        /* sauvegarde valeurs */
        sprintf(sz_sav_AMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_AMT_M]));
        sprintf(sz_sav_RETAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETAMT_M]));
        sprintf(sz_sav_RETINTAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]));

        if ((double)atof(ptb_InRec_Cur[GT_AMT_M]) != 0.0)
        {
          sprintf(sz_AMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_AMT_M]) * -1);
          ptb_InRec_Cur[GT_AMT_M] = sz_AMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETAMT_M]) != 0.0)
        {
          sprintf(sz_RETAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETAMT_M]) * -1);
          ptb_InRec_Cur[GT_RETAMT_M] = sz_RETAMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]) != 0.0)
        {
          sprintf(sz_RETINTAMT_M, "%.3f", (double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]) * -1);
          ptb_InRec_Cur[GT_RETINTAMT_M] = sz_RETINTAMT_M;
        }

        /* reconduction du GT en sortie */
        n_WriteCols( Kp_OutputFilGtEst, ptb_InRec_Cur, SEPARATEUR, 0 );

        /* restaure adresses pour la suite */
        if ((double)atof(ptb_InRec_Cur[GT_AMT_M]) != 0.0)
        {
          ptb_InRec_Cur[GT_AMT_M] = sz_sav_AMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETAMT_M]) != 0.0)
        {
          ptb_InRec_Cur[GT_RETAMT_M] = sz_sav_RETAMT_M;
        }
        if ((double)atof(ptb_InRec_Cur[GT_RETINTAMT_M]) != 0.0)
        {
          ptb_InRec_Cur[GT_RETINTAMT_M] = sz_sav_RETINTAMT_M;
        }
      }

      sprintf(sz_ACCESB, "%d", Ktbd_Trf[n_indctr].ACCESB_CF);
      sprintf(sz_DESTSSD, "%d", Ktbd_Trf[n_indctr].DESTSSD_CF);
      sprintf(sz_DESTACCESB, "%d", Ktbd_Trf[n_indctr].DESTACCESB_CF);

      if (n_indclm != -10)
      {
        sprintf(sz_DESTCLM, "%d", Ktbd_Tclm[n_indclm].DESTCLM_NF);
        ptb_InRec_Cur[GT_CLM_NF] = sz_DESTCLM;
      }

      ptb_InRec_Cur[GT_ESB_CF] = sz_DESTACCESB;
      ptb_InRec_Cur[GT_SSD_CF] = sz_DESTSSD;
      ptb_InRec_Cur[GT_CTR_NF] = Ktbd_Trf[n_indctr].DESTCTR_NF;
      /* reconduction du GT en sortie */
      n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 );

      return (OK);
    }
    return (OK);
  }
}


/*==============================================================================
object
  Lit le fichier binaire des contrats et les charge en memoire

==============================================================================*/
int n_ChargerTRF( )
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerTRF");

  while ( fread( &Ktbd_Trf[i], sizeof( T_TRFCROSSREF ), 1, Kp_InputFilTrf ) == 1 )
  {
    i += 1 ;
    if ( i == NB_TRF_MAX )
    {
      printf( " max TRF atteint=20000 " );
      return (-1 )  ;
    }
  }

  RETURN_VAL( i );
}


/*==============================================================================
objet:
  Lit le fichier binaire des sinistre et les charge en memoire

==============================================================================*/
int n_ChargerTCLM( )
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerTCLM");

  while ( fread( &Ktbd_Tclm[i], sizeof( T_TCLMCROSSREF ), 1, Kp_InputFilTclm ) == 1 )
  {
    i += 1 ;
    if ( i == NB_CLM_MAX )
    {
      printf( " max CLM atteint=20000 " );
      return (-1 )  ;
    }
  }

  RETURN_VAL( i );
}


/*==============================================================================
objet:
  Lit le fichier binaire des postes comptable et les charge en memoire

==============================================================================*/
int n_ChargerDETTRS( )
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerDETTRS");

  while ( fread( &Ktbd_Dettrs[i], sizeof( T_DETTRS ), 1, Kp_InputFilDettrs ) == 1 )
  {
    i += 1 ;
    if ( i == NB_DETTRS_MAX )
    {
      printf( " max DETTRS atteint=40000 " );
      return (-1 );
    }
  }

  RETURN_VAL( i );
}


/*==============================================================================
objet :
  fonction de recherche du contrat
retour :
  0   ---> Pas de rupture
  < 0     ---> On n'est pas arrive au bloc synchrone
  > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechCtr(char *sz_ctr)
{
  int i;

  DEBUT_FCT("n_RechCtr");

  for ( i = 0; i <  Kn_NbLigTrf ; i++ )
  {
    if ( strcmp( sz_ctr, Ktbd_Trf[i].CTR_NF ) == 0) RETURN_VAL(i);
  }

  RETURN_VAL(-1);
}


/*==============================================================================
objet :
  fonction de recherche du sinistre
retour :
  0   ---> Pas de rupture
  < 0     ---> On n'est pas arrive au bloc synchrone
  > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechClm(int n_clm, int n_ssd)
{
  int i;

  DEBUT_FCT("n_RechClm");

  if (n_clm == 0)
    RETURN_VAL(-10);

  for ( i = 0; i <  Kn_NbLigTclm ; i++ )
  {
    if (( n_clm == Ktbd_Tclm[i].CLM_NF ) &&
        ( n_ssd == Ktbd_Tclm[i].SSD_CF ))  RETURN_VAL(i);
  }

  RETURN_VAL(-1);
}


/*==============================================================================
objet :
  fonction de recherche du trncod
retour :
  0   ---> Pas de rupture
  < 0     ---> On n'est pas arrive au bloc synchrone
  > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechTrn(char *sz_trn)
{
  int i;

  DEBUT_FCT("n_RechTrn");

  for ( i = 0; i <  Kn_NbLigDettrs ; i++ )
  {
    if ( strcmp( sz_trn, Ktbd_Dettrs[i].DETTRS_CF ) == 0) RETURN_VAL(i);
  }

  RETURN_VAL(-1);
}
