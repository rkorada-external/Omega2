/*==============================================================================
Nom de l'application          : Filtre du fichier XADPERICASE pour eliminer les
                                affaires en retrocession interne
Nom du source                 : ESTM1005B.c
Revision                      : $Revision: 1.2 $
Date de creation              : 12/10/2019/
Auteur                        : M.NAJI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Filtre du fichier XADPERICASE pour eliminer les affaires en retrocession
  interne
  En entree : fichier DTSTATGTAAF Enrechi
  En sortie : fichier DSUMGTAA, IADPERICASE, IADPERIPRM, PERICASESNEM, DSUMGTAASNEM, _DSUMGTAAREC
------------------------------------------------------------------------------
historique des modifications : 
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    25/03/2004    M. DJELLOULI  Modification sur POSTES 10301 & 10311 - MOD01
    30/08/2004    M. DJELLOULI  SPOT 10422 - Modification des Date D'effet, Date d'échéance,    MOD02
                                            Durée des Polices, et Taux de Polices,
                                            pour LOB = '04' et SSD_CF = 2, 3, 12     ...           ...            ...              ...
    21/04/2005    M.DJELLOULI  SPOT 11416 - MOD03
                                          Pour charger Omega SAR, plutôt que de ne prendre que les provisions de clôture sur
                                          le bilan sauf les ouvertures on prend également les ouvertures pour les postes suivants :
                                          10321, 10331, 10341, 10351, 14201, 42181, 42411, 42891, 45101.

    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[XX] 06/04/2014 JBG :spot:25773 Modify void main declaration to int main
[XX] 19/02/2015 F Maragnes :spot:28305 Ajout  Determination des sous code de regroupement pour distinguer les comptes complets/incomplet, sinistre paye/a payer
[07] 05/02/2016  Florent   :spot:29066 enlever le define du GT
[08] 18/12/2019  M.NAJI    : Optimisation en enlevant les fichier binaire
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE    		*Kp_OutputFilPerPrmd ; 

int n_ActionLignePerPrmd(  char **ptb_InRecOwner ) ;

#define PERPRMD_PER_EGPCUR_CF 	11
#define PERPRMD_PRMDUECUR_RATE  13
#define PERPRMD_PER_RATE      	14 

/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	   (T_RUPTURE_VAR  *pbd_Rupture);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);
int n_ActionLigneGt(  char **ptb_InRecOwner ) ;

double d_GetTaux(
        char* sz_RateOrig, /* Cours d'origine */
        char* sz_RateDest  /* Cours destination */
        );

/**************************************************************************/
/*** Objet : Filtrage du fichier XADPERICASE			***/
/***									***/
/*** Nom : main		     						***/
/***									***/
/*** Parametres:							***/
/***	i argc : nombre de parametres					***/
/***	i argv : tableau de pointeurs sur les parametres		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int main(
   int argc,
   char *argv[]
)
{
   T_RUPTURE_VAR bd_Rupture;

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTC1005B_O1", "wt", &Kp_OutputFilPerPrmd) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }
  


/* Initialisation de la structure de rupture */
   if (n_InitRupture(&bd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(&bd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC1005B_I1", &(bd_Rupture.pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC1005B_O1", &Kp_OutputFilPerPrmd) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

  
   exit(OK);
}




/**************************************************************************/
/*** Objet : initialisation de la structure de rupture			***/
/***									***/
/*** Nom : n_InitRupture     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Rupture : pointeur sur la structure de rupture		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitRupture(
   T_RUPTURE_VAR *pbd_Rupt
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

   
    /* ouverture du fichier esclave Primes et sinistres ultimes */
  if ( n_OpenFileAppl( "ESTC1005B_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    RETURN_VAL (ERR )  ;

  /* nombre de rupture a gerer sur le fichier de travail */
  pbd_Rupt->n_NbRupture = 0 ;

  pbd_Rupt->n_ActionLigne = n_ActionLignePerPrmd ;

  pbd_Rupt->c_Separ = '~' ;


   RETURN_VAL(OK);
}



/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerPrmd( char **ptb_InRecOwner ) /* adresse de la ligne de l'esclave */
{
  double d_PrmDue ;
  double d_Ratio ;
  char sz_PrmDueAmt[30] ; /* zone de travail: montant de prime */
  char sz_EgpCur[4] ; /* zone de travail: devise aliment */
  char  MsgAno[300] ; /* message d'anomalie */

  DEBUT_FCT( "n_ActionLignePerPrmd" ) ;

  /* conversion en devise aliment */

  /* sauvegarde de la ligne courante */
  d_PrmDue = atof( ptb_InRecOwner[PERPRMD_PRMDUE_M] ) ;
  strcpy( sz_EgpCur, ptb_InRecOwner[PERPRMD_PRMDUECUR_CF] ) ;

  ptb_InRecOwner[PERPRMD_PRMDUE_M] = sz_PrmDueAmt ;
  ptb_InRecOwner[PERPRMD_PRMDUECUR_CF] = sz_EgpCur ;

  /* conversion si la devise de prime est differente de la devise aliment */
  if ( strcmp( ptb_InRecOwner[PERPRMD_PRMDUECUR_CF], ptb_InRecOwner[PERPRMD_PER_EGPCUR_CF] ) != 0 )
  {
    /*d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRecChild[PERPRMD_SSD_CF] ),
                         ( atoi( ptb_InRecChild[PERPRMD_UWY_NF] ) - 1 ), ptb_InRecChild[PERPRMD_PRMDUECUR_CF],
                         ptb_InRecOwner[PER_EGPCUR_CF] ) ; */
	d_Ratio = strcmp(ptb_InRecOwner[PERPRMD_PER_EGPCUR_CF],ptb_InRecOwner[PERPRMD_PRMDUECUR_CF]) == 0 ? 1 :  d_GetTaux(
																			ptb_InRecOwner[PERPRMD_PER_RATE], 
																			ptb_InRecOwner[PERPRMD_PRMDUECUR_RATE]  
																			);

    /* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
    if ( d_Ratio < 0 )
    {
      sprintf( MsgAno, "The rates of premium currency ( %s ) and EGPI currency ( %s ) aren't known for the provision premium perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
               ptb_InRecOwner[PERPRMD_PRMDUECUR_CF],
               ptb_InRecOwner[PERPRMD_PER_EGPCUR_CF],
               ptb_InRecOwner[PERPRMD_CTR_NF],
               ptb_InRecOwner[PERPRMD_END_NT],
               ptb_InRecOwner[PERPRMD_SEC_NF],
               ptb_InRecOwner[PERPRMD_UWY_NF],
               ptb_InRecOwner[PERPRMD_UW_NT] ) ;
      n_WriteAno( MsgAno ) ;

      /* montant positionne a zero */
      d_PrmDue = 0 ;
    }
    else  d_PrmDue *= d_Ratio ;

    strcpy( sz_EgpCur, ptb_InRecOwner[PERPRMD_PER_EGPCUR_CF] ) ;
  }

  sprintf( sz_PrmDueAmt, "%-.3f", d_PrmDue ) ;

  /* ecriture en sortie */
  n_WriteCols( Kp_OutputFilPerPrmd, ptb_InRecOwner, '~', 0 ) ;

  RETURN_VAL( OK ) ;
}



/*==============================================================================
objet :
   Traitement d'une ligne, r¦sultat du SELECT de la proc. ps_UTCTLIB_Example_out

retour :
        retourne le cours de la devise d'origine sur le cours de la devise
        destination.
        si la devise destination est nulle la fonction retourne le cours de
        la devise d'origine
        elle retourne une valeur negative ou nulle en cas de probleme
==============================================================================*/
double d_GetTaux(
        char* sz_RateOrig, /* Cours d'origine */
        char* sz_RateDest  /* Cours destination */
        )
{
// [010]p

    DEBUT_FCT ( "d_GetTaux" );

    if( *sz_RateOrig == 0 || atof(sz_RateOrig) <= 0)
        RETURN_VAL ( (double)(-1));
    if( *sz_RateDest == 0 || atof(sz_RateDest) <= 0)
        RETURN_VAL ( (double)(-1));

  RETURN_VAL(  atof(sz_RateDest)/atof(sz_RateOrig));
}




