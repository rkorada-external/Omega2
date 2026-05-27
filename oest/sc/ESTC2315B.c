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
[14] 03/09/2018 Charles Socie   : EXT-IFRS17-903121  REQ 10.02 Cash flow: more detailed granularity ( split between variable and fixed premiums)
[15] 22/04/2020 M.NAJI			:SPIRA 86220 optimisation ESPD3620, pas besoin de faire des synchro avec EST_FPLC, EST_FSSDACTR,EST_FDETTRS
				le DLDSIIGTAR est enrechi avant avec un jointure SYNCSORT avec les colonne :
						PLA_SSDRTO_B
						SSD_ACTR_SSD_CF
						SSD_ACTR_RTOSSD_CF
						SSD_ACTR_CTR_NF
						SSD_ACTR_END_NT
						SSD_ACTR_SEC_NF
						SSD_ACTR_UWY_NF
						SSD_ACTR_UW_NT
						SSD_ACTR_CLISSD_NF
[16] HR SPIRA 82685 : struct.h
[17] 16/07/2025 M.NAJI  : US 5559 SERQS - RA/SAP interface -Phase 1 , update MAX_SSDACTR

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
FILE  *Kp_OutputFilGt2_RI;  /* pointeur sur le fichier de sortie GT correspondant � la ligne d'origine */

T_RUPTURE_VAR       bd_RuptGtrr ;   /* variable de gestion de la rupture sur le GTRr */
T_RUPTURE_SYNC_VAR  bd_RuptPlc ;    /* variable de gestion de la synchronisation avec le fichier des placements */


char Ksz_cloprd[9]; /* date de valeur de l'inventaire en cours (parametre du programme) */
char Ksz_dbclo_d[9];  /* date d'arrete (parametre du programme) */
char Ksz_cre_d[9];  /* date de traitement (parametre du programme) */

int n_InitGtrr ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Gtrr (char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLigneGtrr ( char **pbd_InRec_Cur ) ;

// colonnes enrichies 
#define PLAC_SSDRTO_B  			124
#define PLAC_RETOVRCOM_B 		125
#define SSD_ACTR_SSD_CF      	126
#define SSD_ACTR_CTR_NF      	127
#define SSD_ACTR_UWY_NF      	128
#define SSD_ACTR_UW_NT       	129
#define SSD_ACTR_SEC_NF      	130
#define SSD_ACTR_END_NT      	131
#define SSD_ACTR_CLISSD_NF   	132
#define SSD_ACTR_RTOSSD_CF		133

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
 

  /* ouverture du fichier en sortie GT */
  if ( n_OpenFileAppl ( "ESTC2315B_O1", "wt", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en sortie GT */
  if ( n_OpenFileAppl ( "ESTC2315B_O2", "wt", &Kp_OutputFilGt2 ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en sortie GT RI*/
  if ( n_OpenFileAppl ( "ESTC2315B_O3", "wt", &Kp_OutputFilGt2_RI ) == ERR )
    ExitPgm( ERR_XX , "" ) ;


  /* Initialisation de la variable bd_RuptGtrr */
  if ( n_InitGtrr( &bd_RuptGtrr ) )
    ExitPgm( ERR_XX , "" ) ;


  /* lancement du traitement du fichier GTRr */
  if ( n_ProcessingRuptureVar( &bd_RuptGtrr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2315B_I1", &( bd_RuptGtrr.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2315B_O1", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2315B_O2", &Kp_OutputFilGt2 ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC2315B_O3", &Kp_OutputFilGt2_RI ) == ERR )
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
  if ( n_OpenFileAppl( "ESTC2315B_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    return ERR ;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 0 ;


  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGtrr ;

  pbd_Rupt->c_Separ = SEPARATEUR ;

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
  int  k ;
  double d_retamt = 0;
  double d_amount = 0;
  static char sz_amount[25];  /* Chaine contenant d_amount */
  double d_totaux = 0;
  static char sz_totaux[25];  /* Chaine contenant d_amount */
  double d_acmamt = 0;
  static char sz_acmamt[25];  /* Chaine contenant d_amount */
  char sz_AN_FIN[TAILLE_PATTERNSII_TAUX];   // [006]
  char sz_CodeRetro[3] ;   /* variable de travail : PATTYP_CT de Retro : mettre 'RI' si l'enregistrement participe aux echanges internes, sinon mettre 'R' */
  char* psz_PATTYP_CT; //sauvegarde de pointeur
  
  char  MsgAno[300] ;

  DEBUT_FCT( "n_ActionLigneGtr" ) ;
  
  memset( sz_AN_FIN, 0, sizeof(sz_AN_FIN) );
  strcpy( sz_CodeRetro, "R" ) ;
  
	/* traitement principal */
  /* filtre sur 2eme caractere du TRNCOD >3 */
  if ( *ptb_InRec_Cur[PLAC_SSDRTO_B] == '1' && fabs(atof(ptb_InRec_Cur[GT_RETAMT_M])) >= 0.001 )
  {
    /* si la recherche dans TSSDACTR n'aboutit pas, generation
    d'une anomalie et pas d'ecriture en sortie */
    if ( *ptb_InRec_Cur[SSD_ACTR_SSD_CF] == 0 )
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


      d_retamt = -1 * atof(ptb_InRec_Cur[GT_RETAMT_M]);
      strcpy( sz_CodeRetro, "RI" ) ;

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

        //fprintf( Kp_OutputFilGt, "%d~~%s~%s~%s~%s~~%s~%d~%d~%d~%d~%s~%s~%s~%s~%s~%s~%-.3lf~%d~~%d~A~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%d~%d~%s~%s~%s~%-.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s%s~%s~%s~%s~%s~%d~%s~%s~%s~%s\n",  //[009]
		fprintf( Kp_OutputFilGt, "%d~~%s~%s~%s~%s~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%d~~%d~A~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%d~%d~%s~%s~%s~%-.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",  //[009]//[12]
                 SSD_ACTR_RTOSSD_CF,
                 ptb_InRec_Cur[GT_BALSHEY_NF],
                 ptb_InRec_Cur[GT_BALSHRMTH_NF],
                 ptb_InRec_Cur[GT_BALSHRDAY_NF],
                 "",
                 ptb_InRec_Cur[SSD_ACTR_CTR_NF],
                 ptb_InRec_Cur[SSD_ACTR_END_NT],
                 ptb_InRec_Cur[SSD_ACTR_SEC_NF],
                 ptb_InRec_Cur[SSD_ACTR_UWY_NF],
                 ptb_InRec_Cur[SSD_ACTR_UW_NT],
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
                 ptb_InRec_Cur[SSD_ACTR_CLISSD_NF],
                 Ksz_cloprd,
                 Ksz_dbclo_d,
                 Ksz_cre_d,
                 ptb_InRec_Cur[GT_SSD_CF],
                 ptb_InRec_Cur[GT_TRN_NT],   //[12] [13]
                 ptb_InRec_Cur[GT_SPEENTNAT_CT],  //[12] [13]
                 ptb_InRec_Cur[GT_EVT_NF],      //[12] [13]
                 ptb_InRec_Cur[GT_REVT_NF],    //[12] [13]
 		         ptb_InRec_Cur[123]);//[14]
     }
	 /* ecriture dans le Fichier de travail Traites*/
//	 ptb_InRec_Cur[GTSII3_TYP_CT] = sz_CodeRetro;
     /* ecriture dans le Fichier de travail Traites*/
//	 ptb_InRec_Cur[PLAC_SSDRTO_B] = 0; //ne pas reconduire les colonnes enrichies 
//	 n_WriteCols(Kp_OutputFilGt2_RI, ptb_InRec_Cur, '~', 0);
  
    }
  }
  /* ecriture dans le Fichier de travail Traites*/
  ptb_InRec_Cur[GTSII3_TYP_CT] = sz_CodeRetro;
    /* ecriture dans le Fichier de travail Traites*/
  ptb_InRec_Cur[PLAC_SSDRTO_B] = 0; //ne pas reconduire les colonnes enrichies 
  n_WriteCols(Kp_OutputFilGt2, ptb_InRec_Cur, '~', 0);
  
  RETURN_VAL( OK ) ;
}


