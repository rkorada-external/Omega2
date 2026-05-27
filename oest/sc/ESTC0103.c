/*==============================================================================
Nom de l'application          : Perimetre au niveau CASEX et CAS
Nom du source                 : ESTC0103.c
Revision                      : $Revision: 1.2 $
Date de creation              : 19/08/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Dans le fichier perimetre, mise a jour des champs qui n'ont pu l'etre lors
   de leur descente en ensembliste et sortie des perimetres au niveau CASEX et
   CAS en dommage et vie. Pour l'inventaire un perimetre dommage et vie est
   genere au niveau CASEX.
   Les conversions montants assiette de prime, chargement effectif et portee
   en devise aliment.
   Le perimetre est trie au niveau contrat/avenant/section/exercice/
   numero d'ordre
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    09/09/1998    M.HA-THUC   	Ce programme n'est plus appele en segmentation.
				De plus, les conversions des montants assiette
				de primes, chargement effectif et portee en
				devise aliment sont effectuees.
				Anciennement, elles etaient realisees dans
				l'inventaire dommages.

      02/10/2003     J Ribot  affectation ESTSEC_NF  hors SOREMA (liftrttyp_cf not = "B3"
      21/10/2003     J Ribot  affectation ESTSEC_NF  hors SOREMA (liftrttyp_cf not = "B3" pour filiale 4
      14/11/2003     j Ribot  affectation CNATYP_CT  sur filiale = 14
      27/03/2008     J. Ribot SPOT 15219  ASE15 : recompilation des programmes C
[005] 11/03/2016     DFI      SPOT 30195 Time shift : correction calcul date expiration
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"
#include "estserv.h"


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 	*Kp_OutputFileDomCASEX; /* Pointeur sur le perimetre dommage au niveau CASEX */
FILE 	*Kp_OutputFileVieCASEX; /* Pointeur sur le perimetre vie au niveau CASEX */
FILE 	*Kp_InputFilExc ; 	/* pointeur sur le fichier en entree des cours de change */

T_RUPTURE_VAR *pbd_Rupture;     /* Pointeur sur la structure de la rupture */

char Ksz_INC_D[9]; 		/* Date d'effet du premier exercice et du premier numero d'ordre */
char Ksz_NbreMois[25];          /* Difference en nombre de mois */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture          (T_RUPTURE_VAR  *pbd_Rupture);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);


/**************************************************************************/
/*** Objet : rupture sur le fichier perimetre				***/
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
   pbd_Rupture=malloc(sizeof(T_RUPTURE_VAR));

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* ouverture du fichier en entree des cours de change FCURQUOT */
   if ( n_OpenFileAppl ( "ESTC0103_I2","rb",&Kp_InputFilExc ) == ERR )
	ExitPgm( ERR_XX , "" ) ;

/* Ouverture du fichier de sortie dommage au niveau CASEX */
   if (n_OpenFileAppl("ESTC0103_O1", "wt", &Kp_OutputFileDomCASEX) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplDomCASEX");
   }

/* Ouverture du fichier de sortie vie au niveau CASEX */
   if (n_OpenFileAppl("ESTC0103_O2", "wt", &Kp_OutputFileVieCASEX) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplVieCASEX");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC0103_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0103_O1", &Kp_OutputFileDomCASEX) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0103_O2", &Kp_OutputFileVieCASEX) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if ( n_CloseFileAppl( "ESTC0103_I2", &Kp_InputFilExc ) == ERR )
	ExitPgm( ERR_XX , "" ) ;

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);

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
   T_RUPTURE_VAR *pbd_Rupture
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

/* Ouverture du fichier maitre ESTPERICASE */
   if (n_OpenFileAppl("ESTC0103_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=0;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier maitre	***/
/***									***/
/*** Nom : n_ActionLigneRupture						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneRupture(char *ptsz_LigneCour[])
{
   	static char sz_ValeurNull[] = ""; /* Chaine de valeur nulle */
   	static char sz_Valeur0[] = "0"; /* Chaine de valeur 0 */
   	static char sz_Valeur1[] = "1"; /* Chaine de valeur 1 */
   	static char sz_Valeur2[] = "2"; /* Chaine de valeur 2 */
   	static char sz_Valeur3[] = "3"; /* Chaine de valeur 3 */
   	static char sz_Valeur4[] = "4"; /* Chaine de valeur 4 */
  	//static char sz_Valeur12[] = "12"; /* Chaine de valeur 12 */   [005] correction warning
   	//static char sz_Valeur10[] = "1.0"; /* Chaine de valeur 1.0 */ [005] correction warning

	double d_Ratio ; 	/* ratio: cours assiette de prime/cours aliment */
	double d_SbjPrmAmt ; 	/* variable de travail: montant assiette de prime */
	double d_EffLoaAmt ; 	/* variable de travail: montant de chargement effectif */
	double d_LayCapAmt ;	/* variable de travail: montant de portee */
	char sz_SbjPrmAmt[30] ;	/* zone de travail: montant assiette de prime */
	char sz_EffLoaAmt[30] ;	/* zone de travail: montant de chargement effectif */
	char sz_LayCapAmt[30] ;	/* zone de travail: montant de portee */

	char	MsgAno[300] ; /* message d'anomalie */

	char sz_Annee[5];
   	char sz_Mois[3];


   	DEBUT_FCT("n_ActionLigneRupture") ;

	/*****************************************************************/
	/*****************************************************************/
	/**  ATTENTION - toutes modifs ou evol concernant la mise 	**/
	/**  a jour des champs du perimetre doivent etre repercutees 	**/
	/**  dans le programme ESTC0108.c du job ESCD0001.cmd. Le prog	**/
	/**  ESTC0108.c met a jour les memes champs pour le perimetre	**/
	/**  SADPERICASE descendu pour la segmentation.			**/
	/*****************************************************************/
	/*****************************************************************/

	/*****************************************/
	/* 1ere partie - MAJ des Champs calcules */
	/*****************************************/

	/* Traitement specifique pour les traites */
	/******************************************/
   	if (*ptsz_LigneCour[PER_CTRNAT_CT] == 'N')
	{

		/* Affectation du champ CTRNAT_CT */
		/**********************************/
      		if ( strcmp(ptsz_LigneCour[PER_NAT_CF], "30") < 0 )
		{
			*ptsz_LigneCour[PER_CTRNAT_CT] = 'P' ;
  		}

		/* Affectation du champ SBJPRM_M */
		/*********************************/
     		if ( *ptsz_LigneCour[PER_SBJPRM_M] == '\0'  )
		{
        		ptsz_LigneCour[PER_SBJPRM_M] = ptsz_LigneCour[PER_CLECUTPER_NB];
      		}

      		if ( (*ptsz_LigneCour[PER_ADMMODPRM_CT] == 'A') && (atoi(ptsz_LigneCour[PER_SBJCPTDEF_B]) == 1) )
		{
        		ptsz_LigneCour[PER_SBJPRM_M] = ptsz_LigneCour[PER_ORICUR_B];
      		}
      		ptsz_LigneCour[PER_CLECUTPER_NB] = sz_ValeurNull;
      		ptsz_LigneCour[PER_ORICUR_B] = sz_ValeurNull;
	}

	/* Affectation du champ CTRRET_B */
	/*********************************/
   	if (*ptsz_LigneCour[PER_CTRRET_B] == '\0')
	{
      		ptsz_LigneCour[PER_CTRRET_B] = sz_Valeur0 ;
   	}
   	else
	{
      		ptsz_LigneCour[PER_CTRRET_B] = sz_Valeur1 ;
   	}

	/* Affectation du champ EXP_D */
	/******************************/
	// [005] uniquement pour les LOB 30 et 31, on n'ecrase plus la date d'expiration du contrat par celle de resiliation de la section 
  if (atoi(ptsz_LigneCour[PER_SECSTS_CT]) == 19 && *ptsz_LigneCour[PER_CTRNAT_CT] != 'F' && atoi(ptsz_LigneCour[PER_LOB_CF]) != 30 && atoi(ptsz_LigneCour[PER_LOB_CF]) != 31)
	{
    ptsz_LigneCour[PER_EXP_D] = ptsz_LigneCour[PER_RETCTRCAT_CF] ;
 	}
  else
	{
    /* Ajout : suppression d'un jour a SCOEXP_D */
	  /********************************************/
    if (*ptsz_LigneCour[PER_CTRNAT_CT] != 'F')
 	    n_AddDays(ptsz_LigneCour[PER_EXP_D], 1, '-', ptsz_LigneCour[PER_EXP_D]);
  } 


  ptsz_LigneCour[PER_RETCTRCAT_CF] = sz_ValeurNull;

	/* Affectation du champ SCOEGP_M */
	/*********************************/
	if (*ptsz_LigneCour[PER_SCOEGP_M] == '\0' )
	{
      		ptsz_LigneCour[PER_SCOEGP_M] = ptsz_LigneCour[PER_CLECUTPER_B];
   	}

   	ptsz_LigneCour[PER_CLECUTPER_B] = sz_ValeurNull;

	/* Affectation du champ ESTSEC_NF */
	/**********************************/
   	if (strcmp(ptsz_LigneCour[PER_LOB_CF], "30") == 0)
	{
      		ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur1;
   	}

   	if (strcmp(ptsz_LigneCour[PER_LOB_CF], "31") == 0)
	{
      		ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur2;
   	}



	/* AJOUT JR 02/10/2003  affectation ESTSEC_NF  hors SOREMA (liftrttyp_cf not = "B3"  */
	/*************************************************************************************/
/*if (strcmp(ptsz_LigneCour[PER_LIFTRTTYP_CF], "B3") != 0) */

/* ajout jr 21/10/2003 sur filiale = 4 */
if (strcmp(ptsz_LigneCour[PER_LIFTRTTYP_CF], "B3") != 0)
 {

   if (strcmp(ptsz_LigneCour[PER_SSD_CF], "4") == 0)
  {

   	if ((strcmp(ptsz_LigneCour[PER_LOB_CF], "30") == 0) && ( strcmp(ptsz_LigneCour[PER_NAT_CF], "30") < 0 ))

      		ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur1;

    if ((strcmp(ptsz_LigneCour[PER_LOB_CF], "31") == 0) && ( strcmp(ptsz_LigneCour[PER_NAT_CF], "30") < 0 ))

      		ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur2;

   	if ((strcmp(ptsz_LigneCour[PER_LOB_CF], "30") == 0) && ( strcmp(ptsz_LigneCour[PER_NAT_CF], "29") > 0 ))

      		ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur3;

    if ((strcmp(ptsz_LigneCour[PER_LOB_CF], "31") == 0) && ( strcmp(ptsz_LigneCour[PER_NAT_CF], "29") > 0 ))

      		ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur4;

    }
  }

	/* FIN AJOUT JR 02/10/2003  affectation ESTSEC_NF  hors SOREMA  */


	/* AJOUT JR 14/11/2003  affectation CNATYP_CT [005] correction warning */
/* ajout jr 14/11/2003 sur filiale = 14 */
   if (strcmp(ptsz_LigneCour[PER_SSD_CF], "14") == 0)
  {

         		ptsz_LigneCour[PER_CNATYP_CT] = sz_Valeur3;
   }

	/****************************************/
	/* Modifs du 30/06/98 - M.HA-THUC       */
	/* Affectation particuliere de          */
	/* ERNPRMADM_CT si Non prop             */
	/****************************************/
   	if ( *ptsz_LigneCour[PER_CTRNAT_CT] == 'N' )
   	{
      		if ( *ptsz_LigneCour[PER_ACCADMTYP_CT] == '2' )
	  		ptsz_LigneCour[PER_ERNPRMADM_B] = sz_Valeur1 ;

      		if ( *ptsz_LigneCour[PER_ACCADMTYP_CT] == '3' )
	  		ptsz_LigneCour[PER_ERNPRMADM_B] = sz_Valeur0 ;
   	}


	/********************************************************/
	/* 2eme partie - uniquement pour le perimetre dommage	*/
	/* Conversions en devise aliment et calcul du decalage	*/
	/********************************************************/

	if ( (strcmp(ptsz_LigneCour[PER_LOB_CF], "30")) && (strcmp(ptsz_LigneCour[PER_LOB_CF], "31")))
	{
		/* affectation des montants assiette de prime, chargement effectif et portee */
		d_SbjPrmAmt = atof( ptsz_LigneCour[PER_SBJPRM_M] ) ;
		d_EffLoaAmt = atof( ptsz_LigneCour[PER_PRMEFFLOA_M] ) ;
		d_LayCapAmt = atof( ptsz_LigneCour[PER_LAYCAP_M] ) ;

		ptsz_LigneCour[PER_SBJPRM_M] = sz_SbjPrmAmt ;
		ptsz_LigneCour[PER_PRMEFFLOA_M] = sz_EffLoaAmt ;
		ptsz_LigneCour[PER_LAYCAP_M] = sz_LayCapAmt ;

		/* conversion du montant de l'assiette de prime en devise aliment */
		if ( *ptsz_LigneCour[PER_CTRNAT_CT] == 'N' && strcmp( ptsz_LigneCour[PER_SBJPRMCUR_CF], ptsz_LigneCour[PER_EGPCUR_CF] ) != 0 )
		{
			d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptsz_LigneCour[PER_SSD_CF] ),
				( atoi( ptsz_LigneCour[PER_UWY_NF] ) - 1 ), ptsz_LigneCour[PER_SBJPRMCUR_CF],
				ptsz_LigneCour[PER_EGPCUR_CF] ) ;

			/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
			if ( d_Ratio < 0 )
			{
			sprintf( MsgAno, "The rates of EGPI currency ( %s ) and subject premium currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
				ptsz_LigneCour[PER_EGPCUR_CF], ptsz_LigneCour[PER_SBJPRMCUR_CF],
				ptsz_LigneCour[PER_CTR_NF],  ptsz_LigneCour[PER_END_NT],
				ptsz_LigneCour[PER_SEC_NF],  ptsz_LigneCour[PER_UWY_NF],
				ptsz_LigneCour[PER_UW_NT] ) ;
			n_WriteAno( MsgAno ) ;

			/* montant de l'assiette de prime positionne a zero */
			d_SbjPrmAmt = 0 ;
			}
			else	d_SbjPrmAmt *= d_Ratio ;

			/* conversion du montant de chargement effectif en devise aliment */
			if ( atoi( ptsz_LigneCour[PER_SUPLOATYP_CT] ) == 3 && d_Ratio < 0 )
				d_EffLoaAmt = 0 ;

			if ( atoi( ptsz_LigneCour[PER_SUPLOATYP_CT] ) == 3 && d_Ratio >= 0 )
				d_EffLoaAmt *= d_Ratio ;
		}

		/* conversion du montant de portee en devise aliment */
		if ( *ptsz_LigneCour[PER_CTRNAT_CT] == 'N' && strcmp( ptsz_LigneCour[PER_LIACUR_CF], ptsz_LigneCour[PER_EGPCUR_CF] ) != 0 )
		{
			d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptsz_LigneCour[PER_SSD_CF] ),
				( atoi( ptsz_LigneCour[PER_UWY_NF] ) - 1 ), ptsz_LigneCour[PER_LIACUR_CF],
				ptsz_LigneCour[PER_EGPCUR_CF] ) ;

			/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
			if ( d_Ratio < 0 )
			{
				sprintf( MsgAno, "The rates of EGPI currency ( %s ) and Layer capacity currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
					ptsz_LigneCour[PER_EGPCUR_CF], ptsz_LigneCour[PER_SBJPRMCUR_CF],
					ptsz_LigneCour[PER_CTR_NF],  ptsz_LigneCour[PER_END_NT],
					ptsz_LigneCour[PER_SEC_NF],  ptsz_LigneCour[PER_UWY_NF],
					ptsz_LigneCour[PER_UW_NT] ) ;
				n_WriteAno( MsgAno ) ;

				/* montants positionnes a zero */
				d_LayCapAmt = 0 ;
			}
			else	d_LayCapAmt *= d_Ratio ;
		}

		sprintf( sz_SbjPrmAmt, "%-.3f", d_SbjPrmAmt ) ;
		sprintf( sz_EffLoaAmt, "%-.3f", d_EffLoaAmt ) ;
		sprintf( sz_LayCapAmt, "%-.3f", d_LayCapAmt ) ;

		/* Calcul du decallage */
		/***********************/
		if (*ptsz_LigneCour[PER_CTRNAT_CT] != 'F')
		{
      			sz_Annee[0] = ptsz_LigneCour[PER_EXP_D][0];
      			sz_Annee[1] = ptsz_LigneCour[PER_EXP_D][1];
      			sz_Annee[2] = ptsz_LigneCour[PER_EXP_D][2];
      			sz_Annee[3] = ptsz_LigneCour[PER_EXP_D][3];
      			sz_Annee[4] = '\0';
      			sz_Mois[0] = ptsz_LigneCour[PER_EXP_D][4];
      			sz_Mois[1] = ptsz_LigneCour[PER_EXP_D][5];
      			sz_Mois[2] = '\0';

      			sprintf(Ksz_NbreMois, "%d", - n_DureeEnMois(atoi(ptsz_LigneCour[PER_UWY_NF]), 12, atoi(sz_Annee), atoi(sz_Mois)));
   		}
   		else
		{
      			*Ksz_NbreMois = '\0';
   		}

   		ptsz_LigneCour[PER_DIFMTH_NF] = Ksz_NbreMois;

		/* Ecriture en sortie du perimetre dommage */
		/*******************************************/
      		n_WriteCols(Kp_OutputFileDomCASEX, ptsz_LigneCour, '~', 0);
	}
	if ( strcmp(ptsz_LigneCour[PER_LOB_CF], "30")==0 || strcmp(ptsz_LigneCour[PER_LOB_CF], "31")==0)
	{
		/* Ecriture en sortie perimetre vie */
		/************************************/
      		n_WriteCols(Kp_OutputFileVieCASEX, ptsz_LigneCour, '~', 0);
   	}


   	RETURN_VAL(OK);
}




