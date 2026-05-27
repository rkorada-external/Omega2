/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC2315.c
r�vision                      : $Revision: 1.2 $
date de cr�ation              : 23/09/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   FILTRE SUR LA RETRO INTERNE - BASCULEMENT DE LA RETROCESSION VERS L'ACCEPTATION
DE LA SSD_CF RETROCESSIONNAIRE

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    20/05/2003     - HV        - Ajout filtre sur poste comptable IBNR2 Canada : 24494132 et 25494132
                                : On ne les envois pas en r�tro interne
    11/09/2003     - JR        - passe table MAX_SSDACTR  a 20000
    27/03/2008     J.Ribot     SPOT 15219  ASE15 : recompilation des programmes C
_________________
MODIFICATION    [004]
Auteur:         D.GATIBELZA
Date:           22/07/2008
Version:        8.1
Description:    ESTDOM15823 Echange interne  agrandissement d'un tableau en memoire pour charger les r�f�rences internes
                passage de MAX_SSDACTR 20000 � : MAX_SSDACTR 50000
_________________
MODIFICATION    [005]
Auteur:         JF VDV
Date:           08/10/2012
Version:
Description:    [24327] Echange interne agrandissement du tableau en memoire pour charger les r�f�rences internes
                passage de MAX_SSDACTR 50 000 � : MAX_SSDACTR 500 000 + augmentation de la taille du compteur  Kn_SsdActr_Nbp
[06] 21/11/2012 Roger Cassis    :spot:24041 Ajout de + de PATTERNSII_ANNEES colonnes si typetrt = GT_SII
[07] 11/09/2014 Cyrille DESPRET :spot:25036 Retro Pending : Poste retard transforme en poste estime uniquement pour Solvency II et plus pour le reste
[08] 05/03/2015 Franck Maragnes :spot:28104 Ajout des postes de surcommission
[09] 18/06/2015 Roger Cassis    :spot:26391 On complete les colonnes au format GT
[10] 02/12/2015 Florent         :spot:29615 convertion du PATTYP pour l'acceptation
[11] 06/06/2016 Florent         :spot:30543 on passe � 65 ann�es
[12] 26/08/2016 MBO             :spot:31117:pas de spira: ajout de colonne en plus TRN_NT, SPEENNAT_CT, EVT_NF, REVT_NF
[13] 29/08/2016 MBO             :spot:31117:pas de spira: correction du probleme "(null)" dans le fichier de sortie
[14] 03/09/2018 Charles Socie : EXT-IFRS17-903121  REQ 10.02 Cash flow: more detailed granularity ( split between variable and fixed premiums)
[16] 19/05/2020 Charles Socie   :spira:82584 add buffer for better execution time
[17] 26/08/2020 HR SPIRA 82685  :struct.h
[18] 27/05/2021 L. DOAN    	:spira 91532 recompilation des programmes C
[19] 04/06/2021 MZM             :spira:96833  Modification type de variable ANO TNR NB Postes DETTRS
[20] 26/10/2021 Charles Socie   :spira:99702 add norme as new facultative input
[21] 03/12/2024 DAD   :spira:112470 RAP IADSI/IALKI cashflows on internal assumed
[22] 16/07/2025 M.NAJI  : US 5559 SERQS - RA/SAP interface -Phase 1 , update MAX_SSDACTR

==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
//#include "structA.h"
#include "struct.h"
#include "estserv.h"
#include "ESTC3001A.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* d�finition des constantes et macros priv�es */
/*---------------------------------------------*/
#define MAX_SSDACTR 400000       //[24327] 500000              /*  DOM  22/07/2008 ancien = 50000  */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  *Kp_OutputFilGt ;   /* pointeur sur le fichier de sortie GT */
FILE  *Kp_OutputFilGt2 ;  /* pointeur sur le fichier de sortie GT correspondant � la ligne d'origine */
FILE  *Kp_InputFilDetTrs ;  /* pointeur sur le fichier en entree des postes comptables */
FILE  *Kp_InputFilSsdActr ; /* pointeur sur le fichier des correspondances retro vers acceptation */

T_RUPTURE_VAR       bd_RuptGtrr ;   /* variable de gestion de la rupture sur le GTRr */
T_RUPTURE_SYNC_VAR  bd_RuptPlc ;    /* variable de gestion de la synchronisation avec le fichier des placements */
T_DETTRS Ktbd_DetTrs[MAX_TDETTRS] ;     /* tableau des postes comptables */

int  Kn_DetTrs_Nbp ; //[19] short Kn_DetTrs_Nbp ;     /* compteur du nombre de postes du tableau Ktbd_DetTrs */

extern int Ksz_Argc ;

T_SSDACTR Ktbd_SsdActr[MAX_SSDACTR] ;   /* tableau des correspondances retro vers acceptation */
int Kn_SsdActr_Nbp ;      /* compteur du nombre de postes du tableau Ktbd_SsdActr */ // [24327] short Kn_SsdActr_Nbp
int Buffer = 0;

char Ksz_cloprd[9]; /* date de valeur de l'inventaire en cours (parametre du programme) */
char Ksz_dbclo_d[9];  /* date d'arrete (parametre du programme) */
char Ksz_cre_d[9];  /* date de traitement (parametre du programme) */
char Ksz_typetrt_ct[7];  /* PATTYP_CT de traitement : GT_STD / GT_SII */
char Ksz_norme_cf[5]; 
char Kc_PLA_SSDRTO_B;
char Kc_PLA_RETOVRCOM_B;

int n_InitGtrr ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Gtrr (char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptGtrr ( char **ptb_InRec_Cur);
int n_ActionLigneGtrr ( char **pbd_InRec_Cur ) ;

int n_InitPlc ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePlc ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPlc ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_ProcessingRuptureSyncVar (  T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **ptb_InRecOwner );
int n_ChargerSSDACTR( void ) ;
int n_RechercheSSDACTR( char *RetCtr, short Rty, long Plc, unsigned char RetSec ) ;

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
  printf("--->  parametre 0 \n");
  /* Initialisation des signaux */
  InitSig () ;

  printf("--->  parametre 1 \n");

  if ( n_BeginPgm ( argc, argv ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Recuperation des parametres du programme */
  /* periode courante */
  printf("--->  parametre 2 \n");
  strcpy(Ksz_cloprd, psz_GetCharArgv(1));
  /* date d'arrete */
  printf("--->  parametre %s\n", Ksz_cloprd);
  strcpy(Ksz_dbclo_d, psz_GetCharArgv(2));
  /* date de traitement */
  strcpy(Ksz_cre_d, psz_GetCharArgv(3));
  /* PATTYP_CT de donnees [006] */
  printf("--->  parametre %s\n", Ksz_cre_d);
  strcpy(Ksz_typetrt_ct, psz_GetCharArgv(4));
  printf("--->  parametre %s\n", Ksz_typetrt_ct);
  
  if (Ksz_Argc == 5)
  { 
	  strcpy(Ksz_norme_cf, psz_GetCharArgv(5));
  }
  else{
	  strcpy(Ksz_norme_cf, "EBS");
  }
  printf("--->  parametre %s\n", Ksz_norme_cf);
  /* ouverture du fichier binaire en entree des correspondances retro vers acceptation */
  if ( n_OpenFileAppl ( "ESTC2315A_I3", "rb", &Kp_InputFilSsdActr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier binaire en entree des postes comptables */
  if ( n_OpenFileAppl ( "ESTC2315A_I4", "rb", &Kp_InputFilDetTrs ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en sortie GT */
  if ( n_OpenFileAppl ( "ESTC2315A_O1", "wt", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en sortie GT */
  if ( n_OpenFileAppl ( "ESTC2315A_O2", "wt", &Kp_OutputFilGt2 ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGtrr */
  if ( n_InitGtrr( &bd_RuptGtrr ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptPlc */
  if ( n_InitPlc( &bd_RuptPlc ) )
    ExitPgm( ERR_XX , "" ) ;

  /* chargement de la table TDETTRS en memoire */
  Kn_DetTrs_Nbp = n_LoadTDETTRS( Kp_InputFilDetTrs, Ktbd_DetTrs ) ;

  /* chargement de la table TSSDACTR en memoire */
  Kn_SsdActr_Nbp = n_ChargerSSDACTR( ) ;
  if ( Kn_SsdActr_Nbp >= MAX_SSDACTR )
    ExitPgm( ERR_XX , "Taille tableau TSSDACTR insuffisante " ) ;

  /* lancement du traitement du fichier GTRr */
  if ( n_ProcessingRuptureVar( &bd_RuptGtrr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2315A_I1", &( bd_RuptGtrr.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2315A_I2", &( bd_RuptPlc.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2315A_I3", &Kp_InputFilSsdActr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2315A_I4", &Kp_InputFilDetTrs ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2315A_O1", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2315A_O2", &Kp_OutputFilGt2 ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_EndPgm() == ERR )
    ExitPgm( ERR_XX , "" );

  exit( OK ) ;
}


/*==============================================================================
objet :
  fonction d'initialisation de la variable de gestion de rupture du fichier
  maitre.

retour :
  0K
==============================================================================*/
int n_InitGtrr(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitGtrr" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier maitre GTRr */
  if ( n_OpenFileAppl( "ESTC2315A_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    return ERR ;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 1 ;

  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Gtrr;
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptGtrr;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGtrr ;

  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Gtrr(char **ptb_InRec, char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR1PER");

  if ((strcmp(ptb_InRec[GT_RETCTR_NF], ptb_InRec_Cur[GT_RETCTR_NF]) != 0) ||
      (strcmp(ptb_InRec[GT_RETSEC_NF], ptb_InRec_Cur[GT_RETSEC_NF]) != 0) ||
      (strcmp(ptb_InRec[GT_RTY_NF], ptb_InRec_Cur[GT_RTY_NF]) != 0) ||
      (strcmp(ptb_InRec[GT_PLC_NT], ptb_InRec_Cur[GT_PLC_NT]) != 0))
    RETURN_VAL(1);

  RETURN_VAL (0);
}

/*==============================================================================
objet :
  Fonction lancee a chaque rupture premiere sur RETCTR_NF/RETSEC_NF/RTY_NF/PLC_NT

==============================================================================*/
int n_ActionFirstRuptGtrr ( char **ptb_InRec_Cur)
{
  DEBUT_FCT( "n_ActionFirstRuptGtrr" ) ;

  Kc_PLA_SSDRTO_B = '0';
  Kc_PLA_RETOVRCOM_B = '0';

  /* synchronisation avec le fichier des placements */
  n_ProcessingRuptureSyncVar( &bd_RuptPlc, ptb_InRec_Cur ) ;

  RETURN_VAL( OK ) ;

}
/*==============================================================================
objet :
  fonction lancee pour chaque ligne
PER
retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtrr( char **ptb_InRec_Cur )
{
  int i, j, k ;
  double d_retamt = 0;
  double d_amount = 0;
  static char sz_amount[25];  /* Chaine contenant d_amount */
  double d_totaux = 0;
  static char sz_totaux[25];  /* Chaine contenant d_amount */
  double d_acmamt = 0;
  static char sz_acmamt[25];  /* Chaine contenant d_amount */
  char sz_TrnCodAccpt[9] ; /* variable de travail : poste comptable retrocession */
  char sz_AN_FIN[TAILLE_PATTERNSII_TAUX];   // [006]
  char sz_CodeRetro[3] ;   /* variable de travail : PATTYP_CT de Retro : mettre 'RI' si l'enregistrement participe aux echanges internes, sinon mettre 'R' */
  char* psz_PATTYP_CT; //sauvegarde de pointeur
  
  char  MsgAno[300] ;

  DEBUT_FCT( "n_ActionLigneGtr" ) ;
  
  memset( sz_AN_FIN, 0, sizeof(sz_AN_FIN) );
  strcpy( sz_CodeRetro, "R" ) ;
  
	/* traitement principal */
  /* filtre sur 2eme caractere du TRNCOD >3 */
  if ( Kc_PLA_SSDRTO_B == '1' && ( (fabs(atof(ptb_InRec_Cur[GT_RETAMT_M])) >= 0.001 && strncmp(Ksz_norme_cf,"EBS",3) == 0 ) 
	  || ((fabs(atof(ptb_InRec_Cur[GTSII3_TOTAUX_M])) >= 0.001 || fabs(atof(ptb_InRec_Cur[GTSII3_ACMAMT_MC])) >= 0.001) && strncmp(Ksz_norme_cf,"EBS",3) != 0 ) )
       &&  (ptb_InRec_Cur[GT_TRNCOD_CF][1] != '7')  &&  (ptb_InRec_Cur[GT_TRNCOD_CF][1] != '9')
       &&  (ptb_InRec_Cur[GT_TRNCOD_CF][1] != 'S')  &&  (ptb_InRec_Cur[GT_TRNCOD_CF][1] != 'C')
       &&  (ptb_InRec_Cur[GT_TRNCOD_CF][1] != 'O')  &&  (ptb_InRec_Cur[GT_TRNCOD_CF][1] != 'R')
       &&  (ptb_InRec_Cur[GT_TRNCOD_CF][1] != 'I')  &&  (ptb_InRec_Cur[GT_TRNCOD_CF][1] != 'T')
       &&  (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) != 24494132 )
       &&  (atoi( ptb_InRec_Cur[GT_TRNCOD_CF] ) != 25494132 ))
  {
    /* recherche de la correspondance dans la table TSSDACTR */

    i = n_RechercheSSDACTR( ptb_InRec_Cur[GT_RETCTR_NF], atoi( ptb_InRec_Cur[GT_RTY_NF] ),
                            atol( ptb_InRec_Cur[GT_PLC_NT] ), (char) atoi( ptb_InRec_Cur[GT_RETSEC_NF] ) ) ;

    /* si la recherche dans TSSDACTR n'aboutit pas, generation
    d'une anomalie et pas d'ecriture en sortie */
    if ( i == -1 )
    {
      sprintf( MsgAno, "the research in BRET..TSSDACTR failed for the contract ( RETCTR_NF %s - RTY_NF %s - RETSEC_NF %s - RETUW_NT %s - PLC_NT %s ) \n",
               ptb_InRec_Cur[GT_RETCTR_NF],
               ptb_InRec_Cur[GT_RTY_NF],
               ptb_InRec_Cur[GT_RETSEC_NF],
               ptb_InRec_Cur[GT_RETUW_NT],
               ptb_InRec_Cur[GT_PLC_NT] ) ;

      n_WriteAno( MsgAno ) ;
    }
    else
    {
      /* calcul du poste acceptation a partir du poste retrocession */
      strcpy( sz_TrnCodAccpt, ptb_InRec_Cur[GT_TRNCOD_CF] ) ;

      /* [006] Poste retard transforme en poste estime uniquement pour EBS */
      if ( strcmp(Ksz_typetrt_ct, "GT_SII") == 0 )
      {
        if ( sz_TrnCodAccpt[7] == '4' )
          sz_TrnCodAccpt[7] = '2' ; /* suffixe force a 2 */
      }

      /* transformation des L0 en liberations variables
         valable jusqu a la fin du bilan 1999           */

      /* Cas de la surcommission */

      if ( strncmp( sz_TrnCodAccpt, "2112110", 7 ) == 0 || strncmp( sz_TrnCodAccpt, "2412110", 7 ) == 0 )
      {
        if ( Kc_PLA_RETOVRCOM_B == '1' )
        {
          if ( strncmp( sz_TrnCodAccpt, "2112110", 7 ) == 0 )
            strncpy( sz_TrnCodAccpt, "1112100", 7 ) ;
          else
            strncpy( sz_TrnCodAccpt, "1412100", 7 ) ;

        }
        else
        {
          if ( strncmp( sz_TrnCodAccpt, "2112110", 7 ) == 0 )
            strncpy( sz_TrnCodAccpt, "1112120", 7 ) ;
          else
            strncpy( sz_TrnCodAccpt, "1412120", 7 ) ;
        }
      }
      else
      {
        /* Le poste est-t-il dans TDETTRS */
        j = n_GetPosDettrs(sz_TrnCodAccpt, Ktbd_DetTrs, Kn_DetTrs_Nbp);

        /* si la recherche dans TDETTRS n'aboutit pas, generation
           d'une anomalie et pas d'ecriture en sortie */
        if ((j != -1) && (b_IsBlankOrEmpty( Ktbd_DetTrs[j].RETTRSCOD_CF) == FALSE))
          strcpy( sz_TrnCodAccpt, Ktbd_DetTrs[j].RETTRSCOD_CF ) ;
        else
        {
          /* Prefixe retrocession change en prefixe acceptation */
          if ( sz_TrnCodAccpt[0] == '2' )
            sz_TrnCodAccpt[0] = '1' ;/* prefixe 2, force a 1 */
          if ( sz_TrnCodAccpt[0] == '4' )
            sz_TrnCodAccpt[0] = '3' ;/* prefixe 4, force a 3 */
        }
      }

      d_retamt = -1 * atof(ptb_InRec_Cur[GT_RETAMT_M]);
      strcpy( sz_CodeRetro, "RI" ) ;

      /* ecriture en sortie dans le GT standard ou GT_SII [006] */
      if ( strcmp(Ksz_typetrt_ct, "GT_SII") != 0 )
      {
        //fprintf( Kp_OutputFilGt, "%d~~%s~%s~%s~%s~~%s~%d~%d~%d~%d~%s~%s~%s~%s~%s~%s~%-.3lf~%d~~%d~A~~~~~~~~~~~~~~~~~~%s~%s~%s~%s\n",
        fprintf( Kp_OutputFilGt, "%d~~%s~%s~%s~%s~~%s~%d~%d~%d~%d~%s~%s~%s~%s~%s~%s~%-.3lf~%d~~%d~A~~~~~~~~~~~~~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",//[12]
                 Ktbd_SsdActr[i].RTOSSD_CF,
                 ptb_InRec_Cur[GT_BALSHEY_NF],
                 ptb_InRec_Cur[GT_BALSHRMTH_NF],
                 ptb_InRec_Cur[GT_BALSHRDAY_NF],
                 sz_TrnCodAccpt,
                 Ktbd_SsdActr[i].CTR_NF,
                 Ktbd_SsdActr[i].END_NT,
                 Ktbd_SsdActr[i].SEC_NF,
                 Ktbd_SsdActr[i].UWY_NF,
                 Ktbd_SsdActr[i].UW_NT,
                 ptb_InRec_Cur[GT_RETOCCYEA_NF],
                 ptb_InRec_Cur[GT_RETACY_NF],
                 ptb_InRec_Cur[GT_RETSCOSTRMTH_NF],
                 ptb_InRec_Cur[GT_RETSCOENDMTH_NF],
                 ptb_InRec_Cur[GT_RCL_NF],
                 ptb_InRec_Cur[GT_RETCUR_CF],
                 d_retamt,
                 Ktbd_SsdActr[i].CLISSD_NF,
                 Ktbd_SsdActr[i].CLISSD_NF ,
                 Ksz_cloprd,
                 Ksz_dbclo_d,
                 Ksz_cre_d,
                 ptb_InRec_Cur[GT_SSD_CF],
                 ptb_InRec_Cur[GT_TRN_NT] == NULL ? "" : ptb_InRec_Cur[GT_TRN_NT],   //[12] [13]
                 ptb_InRec_Cur[GT_SPEENTNAT_CT] == NULL ? "" : ptb_InRec_Cur[GT_SPEENTNAT_CT],  //[12] [13]
                 ptb_InRec_Cur[GT_EVT_NF] == NULL ? "" : ptb_InRec_Cur[GT_EVT_NF],      //[12] [13]
                 ptb_InRec_Cur[GT_REVT_NF] == NULL ? "" : ptb_InRec_Cur[GT_REVT_NF],    //[12] [13]
     	 	     ptb_InRec_Cur[123]);//[14]
       }
      else
      {
        // [006]
        strcpy(sz_AN_FIN, "");

        for ( k = GTSII3_AN1_M; k <= GTSII3_AN_FIN_M; k++ )
        {
          strcat(sz_AN_FIN, "~");
          d_amount = -1 * atof(ptb_InRec_Cur[k]);
          sprintf(sz_amount,  "%-.3lf", d_amount);
          strcat(sz_AN_FIN, sz_amount);
        }

        d_acmamt = -1 * atof(ptb_InRec_Cur[GTSII3_ACMAMT_MC]);
        sprintf(sz_acmamt,  "%-.3lf", d_acmamt);
        d_totaux = -1 * atof(ptb_InRec_Cur[GTSII3_TOTAUX_M]);
        sprintf(sz_totaux,  "%-.3lf", d_totaux);

        //on modifie le PATTYP uniqument pour cette �criture;
        psz_PATTYP_CT = ptb_InRec_Cur[GTSII3_PATTYP_CT];
        if (strncmp(ptb_InRec_Cur[GTSII3_PATTYP_CT], "PRRET", 5) == 0)
          psz_PATTYP_CT = "PRACC";
        if (strncmp(ptb_InRec_Cur[GTSII3_PATTYP_CT], "CLRET", 5) == 0)
          psz_PATTYP_CT = "CLACC";
        if (strncmp(ptb_InRec_Cur[GTSII3_PATTYP_CT], "ICRET", 5) == 0)
          psz_PATTYP_CT = "ICACC";
	  
      // [21] - 112470
	    if (strncmp(ptb_InRec_Cur[GTSII3_PATCAT_CT], "RAD", 3) == 0 || strncmp(ptb_InRec_Cur[GTSII3_PATCAT_CT], "RAP", 3) == 0 ){
        if(strncmp(ptb_InRec_Cur[GTSII3_PATTYP_CT], "IRDSI", 5) == 0 ){
          psz_PATTYP_CT = "IADSI";
        }
        else if ( strncmp(ptb_InRec_Cur[GTSII3_PATTYP_CT], "IRLKI", 5) == 0){
          psz_PATTYP_CT = "IALKI";
        }
	    }

        //fprintf( Kp_OutputFilGt, "%d~~%s~%s~%s~%s~~%s~%d~%d~%d~%d~%s~%s~%s~%s~%s~%s~%-.3lf~%d~~%d~A~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%d~%d~%s~%s~%s~%-.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s%s~%s~%s~%s~%s~%d~%s~%s~%s~%s\n",  //[009]
      fprintf( Kp_OutputFilGt, "%d~~%s~%s~%s~%s~~%s~%d~%d~%d~%d~%s~%s~%s~%s~%s~%s~%-.3lf~%d~~%d~A~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%d~%d~%s~%s~%s~%-.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s%s~%s~%s~%s~%s~%d~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",  //[009]//[12]
                 Ktbd_SsdActr[i].RTOSSD_CF,
                 ptb_InRec_Cur[GT_BALSHEY_NF],
                 ptb_InRec_Cur[GT_BALSHRMTH_NF],
                 ptb_InRec_Cur[GT_BALSHRDAY_NF],
                 sz_TrnCodAccpt,
                 Ktbd_SsdActr[i].CTR_NF,
                 Ktbd_SsdActr[i].END_NT,
                 Ktbd_SsdActr[i].SEC_NF,
                 Ktbd_SsdActr[i].UWY_NF,
                 Ktbd_SsdActr[i].UW_NT,
                 ptb_InRec_Cur[GT_RETOCCYEA_NF],
                 ptb_InRec_Cur[GT_RETACY_NF],
                 ptb_InRec_Cur[GT_RETSCOSTRMTH_NF],
                 ptb_InRec_Cur[GT_RETSCOENDMTH_NF],
                 ptb_InRec_Cur[GT_RCL_NF],
                 ptb_InRec_Cur[GT_RETCUR_CF],
                 d_retamt,
                 atoi(ptb_InRec_Cur[GTSII3_PLC_NT]),
                 atoi(ptb_InRec_Cur[GTSII3_RTO_NF]),
                 ptb_InRec_Cur[GT_RETCTR_NF],           //[009]
                 ptb_InRec_Cur[GT_RETEND_NT],           //[009]
                 ptb_InRec_Cur[GT_RETSEC_NF],           //[009]
                 ptb_InRec_Cur[GT_RTY_NF],              //[009]
                 ptb_InRec_Cur[GT_RETUW_NT],            //[009]
                 ptb_InRec_Cur[GT_RETOCCYEA_NF],        //[009]
                 ptb_InRec_Cur[GT_RETACY_NF],           //[009]
                 ptb_InRec_Cur[GT_RETSCOSTRMTH_NF],     //[009]
                 ptb_InRec_Cur[GT_RETSCOENDMTH_NF],     //[009]
                 ptb_InRec_Cur[GT_RCL_NF],              //[009]
                 ptb_InRec_Cur[GT_RETCUR_CF],           //[009]
                 d_retamt,                              //[009]
                 atoi(ptb_InRec_Cur[GTSII3_PLC_NT]),    //[009]
                 atoi(ptb_InRec_Cur[GTSII3_RTO_NF]),    //[009]
                 ptb_InRec_Cur[GTSII3_INT_NF],
                 ptb_InRec_Cur[GTSII3_RETPAY_NF],       //[009]
                 ptb_InRec_Cur[GTSII3_RETKEY_CF],       //[009]
                 d_retamt,
                 ptb_InRec_Cur[GTSII3_ACMTRS_NT],
                 sz_acmamt,
                 ptb_InRec_Cur[GTSII3_ACMCUR_CF],
                 ptb_InRec_Cur[GTSII3_PRS_CF],
                 ptb_InRec_Cur[GTSII3_SEG_NF],
                 ptb_InRec_Cur[GTSII3_LOB_CF],
                 ptb_InRec_Cur[GTSII3_NAT_CF],
                 "AI",
                 ptb_InRec_Cur[GTSII3_NORME_CF],
                 ptb_InRec_Cur[GTSII3_RATING_CF],
                 ptb_InRec_Cur[GTSII3_PATCAT_CT],
                 psz_PATTYP_CT,
                 ptb_InRec_Cur[GTSII3_PATTERN_ID],
                 sz_AN_FIN,
                 ptb_InRec_Cur[GTSII3_COEF_LOB],
                 ptb_InRec_Cur[GTSII3_DSCCUR_CF],
                 ptb_InRec_Cur[GTSII3_COMMENT],
                 sz_totaux,
                 Ktbd_SsdActr[i].CLISSD_NF,
                 Ksz_cloprd,
                 Ksz_dbclo_d,
                 Ksz_cre_d,
                 ptb_InRec_Cur[GT_SSD_CF],
                 ptb_InRec_Cur[GT_TRN_NT] == NULL ? "" : ptb_InRec_Cur[GT_TRN_NT],   //[12] [13]
                 ptb_InRec_Cur[GT_SPEENTNAT_CT] == NULL ? "" : ptb_InRec_Cur[GT_SPEENTNAT_CT],  //[12] [13]
                 ptb_InRec_Cur[GT_EVT_NF] == NULL ? "" : ptb_InRec_Cur[GT_EVT_NF],      //[12] [13]
                 ptb_InRec_Cur[GT_REVT_NF] == NULL ? "" : ptb_InRec_Cur[GT_REVT_NF],    //[12] [13]
 		         ptb_InRec_Cur[123]);//[14]
     }
    }
  }
  /* ecriture de la ligne d'origine avec report du code "RI" si l'enregistrement a particip� aux echanges internes, "R" sinon */
  if ( strcmp(Ksz_typetrt_ct, "GT_SII") == 0 )
  {
    ptb_InRec_Cur[GTSII3_TYP_CT] = sz_CodeRetro;
    /* ecriture dans le Fichier de travail Traites*/
    n_WriteCols(Kp_OutputFilGt2, ptb_InRec_Cur, '~', 0);
  }
  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre � GTRr �
  avec l�esclave � fichier des placements �

retour :
  OK
==============================================================================*/
int n_InitPlc( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
  DEBUT_FCT( "n_InitPlc" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC2315A_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 0 ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncPlc ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLignePlc ;

  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalit� de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPlc(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncPlc" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[GT_RETCTR_NF], pbd_InRecChild[PLA_RETCTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[GT_RETSEC_NF], pbd_InRecChild[PLA_RETSEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[GT_RTY_NF], pbd_InRecChild[PLA_RTY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[GT_PLC_NT], pbd_InRecChild[PLA_PLC_NT] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlc(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */

{

  DEBUT_FCT( "n_ActionLignePlc" ) ;

  Kc_PLA_SSDRTO_B = *ptb_InRecChild[PLA_SSDRTO_B];

  Kc_PLA_RETOVRCOM_B = *ptb_InRecChild[PLA_RETOVRCOM_B];

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de chargement du fichier binaire des correspondances retro vers
acceptation

retour :  le nombre d'enregistrements charges dans le tableau

==============================================================================*/
int n_ChargerSSDACTR( void )
{
  DEBUT_FCT( "n_ChargerSSDACTR" ) ;

  RETURN_VAL( fread( Ktbd_SsdActr, sizeof( T_SSDACTR ), MAX_SSDACTR, Kp_InputFilSsdActr ) ) ;
}


/*==============================================================================
objet :
  fonction de recherche des correspondances retro vers acceptation

retour :  le numero de poste dans le tableau si la fonction a trouve
    sinon -1
==============================================================================*/
int n_RechercheSSDACTR( char *RetCtr, short Rty, long Plc, unsigned char RetSec )
{
  int i, ret1, ret2, ret3, ret4;

  if(Buffer != 0){
    ret1 = strcmp( RetCtr, Ktbd_SsdActr[Buffer].RETCTR_NF ) ;
    if ( ret1 == 0 )
    {
      ret2 = Rty - Ktbd_SsdActr[Buffer].RTY_NF ;
      if ( ret2 == 0 )
      {
        ret3 = Plc - Ktbd_SsdActr[Buffer].PLC_NT ;
        if ( ret3 == 0 )
        {
          ret4 = RetSec - Ktbd_SsdActr[Buffer].RETSEC_NF ;
          if ( ret4 == 0 ){
            return ( Buffer ) ;
		        }
		      }
	      }
	    }
    }

  for ( i = 0; i < Kn_SsdActr_Nbp; i++ )
  {
	ret1 = strcmp( RetCtr, Ktbd_SsdActr[i].RETCTR_NF ) ;
	if ( ret1 == 0 )
	{
	  ret2 = Rty - Ktbd_SsdActr[i].RTY_NF ;
	  if ( ret2 == 0 )
	  {
		ret3 = Plc - Ktbd_SsdActr[i].PLC_NT ;
		if ( ret3 == 0 )
		{
		  ret4 = RetSec - Ktbd_SsdActr[i].RETSEC_NF ;
		  if ( ret4 == 0 ){
			Buffer = i;
			return ( i ) ;
		  }
		  else if ( ret4 < 0 ) return ( -1 ) ;
		}
		else if ( ret3 < 0 ) return ( -1 ) ;
	  }
	  else if ( ret2 < 0 ) return ( -1 ) ;
	}
	else if ( ret1 < 0 ) return ( -1 ) ;
  }

  return ( -1 ) ;
}
