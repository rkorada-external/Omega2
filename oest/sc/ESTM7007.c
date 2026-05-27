/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTM7007.c
révision                      : $Revision: 1.2 $
date de creation              : 07/02/2007
auteur                        : J. Ribot
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   TRAITEMENT DES TRANSFERTS DE PORTEFEUILLE  - partie GT - transformation postes
    ouvertures de provisions en entrees et retraits portefeuille  (SPOT13720)
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
    20/03/2009   R. Cassis   :spot:16765 -> V102 : Ecriture uniquement des records dans la condition QTRLIM
                                         On met QTRLIM/BALSHEY_NF dans mois debut-fin, année de compte
    17/11/2009   R. Cassis   :spot:18415 -> V103 : Copie reconduction emetteur en date 01/01 puis annulation 02/01 pour contrats Vie parm VIE_B
    04/02/2009   R. Cassis   :spot:18937 -> V104 : Si Transfert Etablissement et Vie, on ne fait pas la reconduction ci-dessus - ajout parametre TRANSFESB
                                                   Si filiale et etablissement differents de ceux de la trfcrossref, on ne traite pas le mouvement
[05] 27/06/2014 R. Cassis :spot:25036 Modifie compteur du NB_DETTRS_MAX (triplé)
[XX] 06/04/2014 JBG :spot:25773 Modify void main declaration to int main
[XX] 09/10/2014 JBG  :spot:25773  suppress warning: unused variables
[06] 04/09/2015 Roger Cassis  :spot:29223 - Incrementation compteurs max et Initialisation de variables en global
[07] 05/02/2016 Florent   :spot:29066 on utilise le struct.h
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include "struct.h"
#include "ESTM7007.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

#define NB_TRF_MAX    50000	/* Le nombre max de postes est fixe a 50000 [006] */
#define NB_CLM_MAX    100000	/* Le nombre max de postes est fixe a 100000 [006] */
#define NB_DETTRS_MAX 50000	/* Le nombre max de postes est fixe a 50000 [005] [006] */
#define NB_PTF_MAX    20000	/* Le nombre max de postes est fixe a 20000 [006] */
#define NB_CTPE_MAX   20000	/* Le nombre max de postes est fixe a 20000 [006] */

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE    *Kp_OutputFilGt ;   /* pointeur sur le fichier de sortie GT */
FILE    *Kp_InputFilTrf ;   /* pointeur sur le fichier en entree T_TRFCROSSREF */
FILE    *Kp_InputFilTclm ;    /* pointeur sur le fichier en entree T_TCLMCROSSREF */
FILE    *Kp_InputFilDettrs ;    /* pointeur sur le fichier en entree T_DETTRS */
FILE    *Kp_InputFilPtf ;   /* pointeur sur le fichier en entree T_PTF */
FILE    *Kp_InputFilCtpe ;    /* pointeur sur le fichier en entree T_CTPE */
T_RUPTURE_VAR bd_RuptGt ;     /* variable de gestion de la rupture sur le GT */

T_TRFCROSSREF Ktbd_Trf[NB_TRF_MAX] ;
int   Kn_NbLigTrf = 0 ; /* nombre de lignes du tableau Ktbd_Trf */
T_TCLMCROSSREF  Ktbd_Tclm[NB_CLM_MAX] ;
int   Kn_NbLigTclm = 0 ; /* nombre de lignes du tableau Ktbd_Tclm */
T_DETTRS        Ktbd_Dettrs[NB_DETTRS_MAX] ;
int   Kn_NbLigDettrs = 0 ; /* nombre de lignes du tableau Ktbd_Dettrs */
T_PTF       Ktbd_Ptf[NB_PTF_MAX] ;
int   Kn_NbLigPtf = 0 ; /* nombre de lignes du tableau Ktbd_Ptf */
T_CTPE        Ktbd_Ctpe[NB_CTPE_MAX] ;
int   Kn_NbLigCtpe = 0 ; /* nombre de lignes du tableau Ktbd_Ctpe */
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
int n_ChargerPTF( );
int n_RechPtf( char *sz_pt );
int n_ChargerCTPE( );
int n_RechCtpe(int n_essd, int eesb, int rssd, int resb);

int     n_parm_BALSHEY_NF;
char    sz_parm_BLCSHT_D[9];
unsigned char c_parm_ESTIM_B;       /* 0/1 - si = 1 -> Postes estimations sont pris en compte */
char  sz_AMT_M[19];       /* zone travail pour montants a inverser */
char  sz_RETAMT_M[19];      /* zone travail pour montants a inverser */
char  sz_RETINTAMT_M[19];   /* zone travail pour montants a inverser */
char  sz_sav_AMT_M[19];     /* pointeur adresse de sauvegarde pour montants a inverser */
char  sz_sav_RETAMT_M[19];    /* pointeur adresse de sauvegarde pour montants a inverser */
char  sz_sav_RETINTAMT_M[19]; /* pointeur adresse de sauvegarde pour montants a inverser */
int   n_parm_FORCEBILAN;    /* MOD005 - Flag FORCEBILAN Forcé Bilan à à 31/12/N-1 (1=Oui par Défaut / 0= Bilan N préservé) */
int   n_parm_VIE_B;       /* V103 - Flag Vie si = 1 -> gestion contrats Vie, si = 0 -> gestion contrats non Vie */
int   n_parm_TRANSFESB_B;   /* V104 - Flag Transfert Etablissement si = 1 -> transfert Etablissement, si = 0 -> transfert filiale */
int   n_parm_QTRLIM_NF;
char  sz_CTR_NF[10] = "";   /* zone travail pour test rupture Contrats */

//[006]
int  n_indctr;
int  n_indclm;
int  n_indtrn;
int  n_indptf;
int  n_indctpe;
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
  n_parm_FORCEBILAN = atoi(psz_GetCharArgv(4)) ;  /* MOD005 */
  n_parm_QTRLIM_NF = atoi(psz_GetCharArgv(5)) ;
  n_parm_VIE_B = atoi(psz_GetCharArgv(6)) ;     /*  V103  */
  n_parm_TRANSFESB_B = atoi(psz_GetCharArgv(7)) ;     /*  V104  */

  /* ouverture du fichier en entree TRF */
  if ( n_OpenFileAppl ( "ESTM7007_I2", "rb", &Kp_InputFilTrf ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en entree TCLM */
  if ( n_OpenFileAppl ( "ESTM7007_I3", "rb", &Kp_InputFilTclm ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en entree TDETTRS */
  if ( n_OpenFileAppl ( "ESTM7007_I4", "rb", &Kp_InputFilDettrs ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en entree PTF */
  if ( n_OpenFileAppl ( "ESTM7007_I5", "rb", &Kp_InputFilPtf ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en entree CTPE */
  if ( n_OpenFileAppl ( "ESTM7007_I6", "rb", &Kp_InputFilCtpe ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier de sortie des transferts */
  if ( n_OpenFileAppl ( "ESTM7007_O1", "wt", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGt */
  if ( n_InitGt( &bd_RuptGt ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Chargement des ptf en memoire */
  if ( (Kn_NbLigTrf = n_ChargerTRF( )) == -1 )
    ExitPgm( ERR_XX , "" ) ;
  Kn_NbLigTclm = n_ChargerTCLM( );
  if ( (Kn_NbLigDettrs = n_ChargerDETTRS( )) == -1 )
    ExitPgm( ERR_XX , "" ) ;
  Kn_NbLigPtf = n_ChargerPTF( );
  Kn_NbLigCtpe = n_ChargerCTPE( );

  /* Lancement du traitement sans rupture */
  if ( n_Processing( &bd_RuptGt ) == ERR)
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7007_I1", &( bd_RuptGt.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7007_I2", &Kp_InputFilTrf ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7007_I3", &Kp_InputFilTclm ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7007_I4", &Kp_InputFilDettrs ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7007_I5", &Kp_InputFilPtf ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7007_I6", &Kp_InputFilCtpe ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7007_O1", &Kp_OutputFilGt ) == ERR )
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
  if ( n_OpenFileAppl( "ESTM7007_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
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

  char sz_an[5];
  char sz_mois[3];
  char sz_jour[3];
  int  i;
  char sz_ACCESB[5], sz_DESTACCESB[5], sz_DESTSSD[5], sz_DESTCLM[20];
  char sz_BALSHEY_NF[5];        // V102 on met année de compte/mois debut-fin- = Année bilan/mois limite
  char sz_SCOMTH_NF[3];         // V102 on met année de compte/mois debut-fin- = Année bilan/mois limite


  DEBUT_FCT( "n_ActionLigneGt" ) ;

  /* Contrats retros exclus  */
  if ((ptb_InRec_Cur[GT_TRNCOD_CF][0] != '1') &&
      (ptb_InRec_Cur[GT_TRNCOD_CF][0] != '3'))
  {
    return (OK);
  }

  /* recherche du contrat */
  if (strcmp(sz_CTR_NF, ptb_InRec_Cur[GT_CTR_NF]) != 0)
  {
    strcpy (sz_CTR_NF, ptb_InRec_Cur[GT_CTR_NF]);
    i = n_RechCtr(ptb_InRec_Cur[GT_CTR_NF]);
    n_indctr = i;
  }

  if (n_indctr < 0)
  {
    printf("contrat non trouve  %d   %s   %s \n", n_indctr, ptb_InRec_Cur[GT_CTR_NF], sz_CTR_NF   );
    return (OK);
  }

  /* recherche du poste ouvertures provisions */
  i = n_RechPtf(ptb_InRec_Cur[GT_TRNCOD_CF]);
  n_indptf = i;

  if (n_indptf < 0)
  {

    return (OK);
  }

  /* recherche du sinistre */
  n_indclm = n_RechClm(atoi(ptb_InRec_Cur[GT_CLM_NF]), atoi(ptb_InRec_Cur[GT_SSD_CF]));

  if ((n_indclm < 0) && (n_indclm != -10))
  {
    //  return (OK);
  }
  /* recherche du poste comptable */
  i = n_RechTrn(ptb_InRec_Cur[GT_TRNCOD_CF]);
  n_indtrn = i;

  if (n_indtrn < 0)
  {
    return (OK);
  }

  /* recherche du poste contre partie */

  i = n_RechCtpe(Ktbd_Trf[n_indctr].SSD_CF, Ktbd_Trf[n_indctr].ACCESB_CF, Ktbd_Trf[n_indctr].DESTSSD_CF, Ktbd_Trf[n_indctr].DESTACCESB_CF);
  n_indctpe = i;

  if (n_indctpe < 0)
  {
    printf("Mouvement non traité car poste contre partie non trouve\n");
    printf("contrat %s %d %d %d %d \n", ptb_InRec_Cur[GT_CTR_NF],
           Ktbd_Trf[n_indctr].SSD_CF,
           Ktbd_Trf[n_indctr].ACCESB_CF,
           Ktbd_Trf[n_indctr].DESTSSD_CF,
           Ktbd_Trf[n_indctr].DESTACCESB_CF);
    return (OK);
  }

// V104

  if (atoi(ptb_InRec_Cur[GT_ESB_CF]) != Ktbd_Trf[n_indctr].ACCESB_CF || atoi(ptb_InRec_Cur[GT_SSD_CF]) != Ktbd_Trf[n_indctr].SSD_CF )
  {
    printf("Mouvement non traité car Filiale/Etablissement differents de ceux la tcrossref\n");
    printf("contrat %s %s %s %d %d \n", ptb_InRec_Cur[GT_CTR_NF],
           ptb_InRec_Cur[GT_SSD_CF],
           ptb_InRec_Cur[GT_ESB_CF],
           Ktbd_Trf[n_indctr].DESTSSD_CF,
           Ktbd_Trf[n_indctr].DESTACCESB_CF);
    return (OK);
  }

  /*  si poste comptable = Provision
     on ecrit pas en sortie */

  if ((Ktbd_Dettrs[n_indtrn].TRSTYP_CT == 3 ) &&
      ((ptb_InRec_Cur[GT_TRNCOD_CF][6] == '1') ||
       (ptb_InRec_Cur[GT_TRNCOD_CF][7] == '1')))
  {
    printf("poste comptable = Provision  ");
    printf("contrat %s  ", ptb_InRec_Cur[GT_CTR_NF]);
    printf("poste %s\n", ptb_InRec_Cur[GT_TRNCOD_CF]);
    return (OK);
  }

  sprintf(sz_ACCESB, "%d", Ktbd_Trf[n_indctr].ACCESB_CF);
  sprintf(sz_DESTSSD, "%d", Ktbd_Trf[n_indctr].DESTSSD_CF);
  sprintf(sz_DESTACCESB, "%d", Ktbd_Trf[n_indctr].DESTACCESB_CF);
  ptb_InRec_Cur[GT_ESB_CF] = sz_DESTACCESB;
  ptb_InRec_Cur[GT_SSD_CF] = sz_DESTSSD;
  ptb_InRec_Cur[GT_CTR_NF] = Ktbd_Trf[n_indctr].DESTCTR_NF;

//  V103 - Copie reconduction emetteur en date 01/01 puis annulation au 02/01 pour postes vie reconduction 3......2 du 1er janvier
  if (((ptb_InRec_Cur[GT_TRNCOD_CF][0] == '1') || (ptb_InRec_Cur[GT_TRNCOD_CF][0] == '3')) &&
      (ptb_InRec_Cur[GT_TRNCOD_CF][1] != '7') && (ptb_InRec_Cur[GT_TRNCOD_CF][7] == '2') &&
      (atoi(ptb_InRec_Cur[GT_BALSHRMTH_NF]) == 1) && (atoi(ptb_InRec_Cur[GT_BALSHRDAY_NF]) == 1) && (n_parm_VIE_B == 1) &&
      (n_parm_TRANSFESB_B == 0))           // V104 - pour transfert filiale uniquement
  {
    /* reconduction du GT en sortie */
    n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

    /* On annule les montants et on met le jour a 2 */
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
    strncpy(sz_jour, "2", 2);
    sz_jour[2] = '\0';
    ptb_InRec_Cur[GT_BALSHRDAY_NF] = sz_jour ;

    /* annulation du GT en sortie */
    n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

    /* On restaure les montants et le jour */
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
    strncpy(sz_jour, "1", 2);
    sz_jour[2] = '\0';
    ptb_InRec_Cur[GT_BALSHRDAY_NF] = sz_jour ;
  }

  ptb_InRec_Cur[GT_TRNCOD_CF] = Ktbd_Ptf[n_indptf].POSTETOIN;                 // poste entree portefeuille
  ptb_InRec_Cur[GT_DBLTRNCOD_CF ] = Ktbd_Ctpe[n_indctpe].POSTECP;           // poste contre partie entree portefeuille

  if (n_indclm != -10)
  {
    sprintf(sz_DESTCLM, "%d", Ktbd_Tclm[n_indclm].DESTCLM_NF);
    ptb_InRec_Cur[GT_CLM_NF] = sz_DESTCLM;
  }

//  CLOTURES CEDANTES
  if ((atoi(ptb_InRec_Cur[GT_BALSHEY_NF]) == n_parm_BALSHEY_NF) &&
      (atoi(ptb_InRec_Cur[GT_BALSHRMTH_NF]) <= n_parm_QTRLIM_NF))
  {
    sz_an[4] = '\0';
    strncpy(sz_mois, sz_parm_BLCSHT_D + 4, 2);
    sz_mois[2] = '\0';
    strncpy(sz_jour, sz_parm_BLCSHT_D + 6, 2);
    sz_jour[2] = '\0';
    strncpy(sz_an, sz_parm_BLCSHT_D, 4);
    ptb_InRec_Cur[GT_BALSHEY_NF] = sz_an ;
    ptb_InRec_Cur[GT_BALSHRMTH_NF] = sz_mois ;
    ptb_InRec_Cur[GT_BALSHRDAY_NF] = sz_jour ;
// V102 on met année de compte/mois debut-fin- = Année bilan/mois limite uniquement pour la Non-Vie
    if (n_parm_VIE_B != 1)
    {
      sprintf(sz_BALSHEY_NF, "%d", n_parm_BALSHEY_NF);
      ptb_InRec_Cur[GT_ACY_NF] = sz_BALSHEY_NF;
      sprintf(sz_SCOMTH_NF, "%d", n_parm_QTRLIM_NF);
      ptb_InRec_Cur[GT_SCOSTRMTH_NF] = sz_SCOMTH_NF;
      sprintf(sz_SCOMTH_NF, "%d", n_parm_QTRLIM_NF);
      ptb_InRec_Cur[GT_SCOENDMTH_NF] = sz_SCOMTH_NF;
    }

// V102 les mouvements se font que pour la condition validee - deplacement de ce code a l'interieur du if
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
    n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 ) ;
  }
  return (OK);
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
      printf( " max TRF atteint=30000 " );
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
      printf( " max CLM atteint=10000 " );
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
      printf( " max DETTRS atteint=10000 " );
      return (-1 );
    }
  }

  RETURN_VAL( i );
}

/*==============================================================================
objet:
  Lit le fichier binaire des postes comptable et les charge en memoire

==============================================================================*/
int n_ChargerPTF( )
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerPTF");

  while ( fread( &Ktbd_Ptf[i], sizeof( T_PTF ), 1, Kp_InputFilPtf ) == 1 )
  {
    i += 1 ;
    if ( i == NB_PTF_MAX )
    {
      printf( " max PTF atteint=10000 " );
      return (-1 );
    }
  }

  RETURN_VAL( i );
}

/*==============================================================================
objet:
  Lit le fichier binaire des postes comptable et les charge en memoire

==============================================================================*/
int n_ChargerCTPE( )
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerCTPE");

  while ( fread( &Ktbd_Ctpe[i], sizeof( T_CTPE ), 1, Kp_InputFilCtpe ) == 1 )
  {
    i += 1 ;
    if ( i == NB_CTPE_MAX )
    {
      printf( " max CTPE atteint=10000 " );
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


/*==============================================================================
objet :
  fonction de recherche du trncod
retour :
  0   ---> Pas de rupture
  < 0     ---> On n'est pas arrive au bloc synchrone
  > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPtf(char *sz_ptf)
{
  int i;

  DEBUT_FCT("n_RechPtf");

  for ( i = 0; i <  Kn_NbLigPtf ; i++ )
  {
    if ( strcmp( sz_ptf, Ktbd_Ptf[i].POSTEFROM ) == 0) RETURN_VAL(i);
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
int n_RechCtpe(int n_essd, int n_eesb, int n_rssd, int n_resb)
{
  int i;

  DEBUT_FCT("n_RechCtpe");

  for ( i = 0; i <  Kn_NbLigCtpe ; i++ )
  {

    if (( n_essd == Ktbd_Ctpe[i].ESSD_CF ) &&
        ( n_eesb == Ktbd_Ctpe[i].EESB_CF ) &&
        ( n_rssd == Ktbd_Ctpe[i].RSSD_CF ) &&
        ( n_resb == Ktbd_Ctpe[i].RESB_CF )) RETURN_VAL(i);
  }

  RETURN_VAL(-1);
}

