/*==============================================================================
 Nom de l'application          : RETRO
 Nom du source                 : ESTC1063.c
 Revision                      : 
 Date de creation              : 04/10/2012
 Auteur                        : Roger Cassis
 References des specifications : concu a partir du RETM0532
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
  :spot:24041 - Prog affectation retro interne
  Maj du montant de rétro interne par jointure avec le fichier contenant la part placée en interne.

  On a ds le fichier en entrée, soit des mvts 100%, soit des mvts à la part.
  On appareille sur RETCTR, RTY, RETSEC, PLC.

  Fichier I1:
  Lorsque PLC_NT = 0 :
    PLA_RETSIGSHA_TOT_R contient taux de placement global cumulé sur RETCTR, RTY, RETSEC de plc valides ou résiliés
    PLA_RETSIGSHA_INT_R contient taux de placement interne  cumulé sur RETCTR, RTY, RETSEC
    PLA_RETSIGSHA_QOT_R contient la part que représente les plcs internes / tx global :     RETSIGSHA_INT_R/RETSIGSHA_TOT_R

  Lorsque ds le fichier esclave, on appareille sur les 4 clés, on multiplie le montant 100% du maitre par le taux de plc en rétro interne
  pour obtenir le montant de rétro interne.

  Lorsque PLC_NT est renseigné: ce ne sont que les plc internes valides ou résiliés. On reconduit simplement.
  Lorsqu'il y a appareillage, on met à jour les montants de rétro interne en applicant la part.

  Lorsqu'il n'y a pas appareillage, cela veut dire qu'il n'y a pas du tout de rétro interne sur RETCTR,RTY, RETSEC on reconduit.

------------------------------------------------------------------------------
 Historique des modifications :

==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>

/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC1063.h"

typedef struct {
	char       RETCTR_NF[10];
	int        RETSEC_NF;
	int        RTY_NF;
	char       PLC_NT[10];
	double     RETSIGSHA_TOT_R;
	double     RETSIGSHA_INT_R;
	double     RETSIGSHA_QOT_R;
	char       RTO_NF[10];
	int        NBLIGNES;
} T_FPLATXCUM;


T_RUPTURE_VAR Kbd_ruptFPLATXCUM;
T_RUPTURE_SYNC_VAR Kbd_ruptGTSIIPIVOT;

int n_RecherchePlacement    (char **);
int n_IsR1FPLATXCUM         (char **, char **);
int n_ActionFirstFPLATXCUM  (char **);
int n_ActionLastFPLATXCUM   (char **);
int n_InitFPLATXCUM         (T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneFPLATXCUM  (char **pbd_InRec_Cur);

T_FPLATXCUM platxcum[10000];
int nb_platxcum=0;

int n_InitSyncGTSIIPIVOT         (T_RUPTURE_SYNC_VAR *);
int n_ConditionSyncGTSIIPIVOT    (char **, char **);
int n_InitGTSIIPIVOT             (T_RUPTURE_SYNC_VAR  *);
int n_ActionLigneSyncGTSIIPIVOT  (char **, char **);
int n_ActionFsPGTSIIPIVOT        (char **);

FILE *Kp_OutputFileGTSIIPIVOT;


/*==============================================================================
 Objet :    Point d'entree du programme
 Parametre(s) :
    int argc    : Nombre d'arguments sur la ligne de commande;
    char **argv : parametres
 Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
	// Initialisation des signaux
	InitSig ();
	
	if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "");
	
	// Initialisation des variables de gestion de ruptures
	if (n_InitFPLATXCUM(&Kbd_ruptFPLATXCUM)) ExitPgm(ERR_XX, "");
	if (n_InitGTSIIPIVOT(&Kbd_ruptGTSIIPIVOT)) ExitPgm(ERR_XX, "");
	
	// Ouverture des fichiers binaires et des fichiers de sortie
	if (n_OpenFileAppl("ESTC1063_O1", "wt", &Kp_OutputFileGTSIIPIVOT) == ERR) ExitPgm(ERR_XX, "");
	
	// Lancement du traitement du fichier Maitre
	if (n_ProcessingRuptureVar(&Kbd_ruptFPLATXCUM) == ERR) ExitPgm(ERR_XX, "");
	
	// Fermeture des fichiers ouverts
	if (n_CloseFileAppl("ESTC1063_I1", &(Kbd_ruptFPLATXCUM.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC1063_I2", &(Kbd_ruptGTSIIPIVOT.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC1063_O1", &Kp_OutputFileGTSIIPIVOT)) ExitPgm(ERR_XX, "");
	
	if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

	exit(OK);
}


/*==============================================================================
 Objet :    Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_VAR
 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitFPLATXCUM(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitFPLATXCUM" );

	memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));
	
	if (n_OpenFileAppl("ESTC1063_I1","rt", &(pbd_Rupt->pf_InputFil)))
		return ERR;
	
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1FPLATXCUM;
	pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstFPLATXCUM;
	pbd_Rupt->n_ActionLigne         = n_ActionLigneFPLATXCUM;
	pbd_Rupt->n_ActionLast[0]       = n_ActionLastFPLATXCUM;
	pbd_Rupt->c_Separ = '~';

	return OK;
}


/*==============================================================================
objet :     fonction de test de rupture de niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1FPLATXCUM(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsR1FPLATXCUM");
	
	if (strcmp(ptb_InRec[PLA_RETCTR_NF],ptb_InRec_Cur[PLA_RETCTR_NF])!=0)       RETURN_VAL(1);
	if (strcmp(ptb_InRec[PLA_RTY_NF],ptb_InRec_Cur[PLA_RTY_NF])!=0)             RETURN_VAL(1);
	if (strcmp(ptb_InRec[PLA_RETSEC_NF],ptb_InRec_Cur[PLA_RETSEC_NF])!=0)       RETURN_VAL(1);

	RETURN_VAL (0);
}


//==============================================================================
// Objet :    A chaque rupture première sur CONTRAT/EXERCICE/SECTION   de rétro
//==============================================================================
int n_ActionFirstFPLATXCUM(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionFirstFPLATXCUM");
	int i = 0;/* Added for Phase1b Migration */ 
	// Initialisation
	for(i=0;i<10000;i++)  /* Updated for Phase1b Migration */
	{
		memset(platxcum[i].RETCTR_NF, 0, sizeof(platxcum[i].RETCTR_NF));
		platxcum[i].RETSEC_NF=0;
		platxcum[i].RTY_NF=0;
		memset(platxcum[i].PLC_NT, 0, sizeof(platxcum[i].PLC_NT));
		platxcum[i].RETSIGSHA_TOT_R=0;
		platxcum[i].RETSIGSHA_INT_R=0;
		platxcum[i].RETSIGSHA_QOT_R=0;
		memset(platxcum[i].RTO_NF, 0, sizeof(platxcum[i].RTO_NF));
		platxcum[i].NBLIGNES=0;
	}
	nb_platxcum=0;
	return OK;
}


/*==============================================================================
 Objet :    Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneFPLATXCUM(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLigneFPLATXCUM");

	strcpy(platxcum[nb_platxcum].RETCTR_NF, ptb_InRec_Cur[PLA_RETCTR_NF]);
	platxcum[nb_platxcum].RETSEC_NF = atoi(ptb_InRec_Cur[PLA_RETSEC_NF]);
	platxcum[nb_platxcum].RTY_NF = atoi(ptb_InRec_Cur[PLA_RTY_NF]);
	strcpy(platxcum[nb_platxcum].PLC_NT, ptb_InRec_Cur[PLA_PLC_NT]);
	platxcum[nb_platxcum].RETSIGSHA_TOT_R = atof(ptb_InRec_Cur[PLA_RETSIGSHA_TOT_R]);
	platxcum[nb_platxcum].RETSIGSHA_INT_R = atof(ptb_InRec_Cur[PLA_RETSIGSHA_INT_R]);
	platxcum[nb_platxcum].RETSIGSHA_QOT_R = atof(ptb_InRec_Cur[PLA_RETSIGSHA_QOT_R]);
	strcpy(platxcum[nb_platxcum].RTO_NF, ptb_InRec_Cur[PLA_RTO_NF]);
	platxcum[nb_platxcum].NBLIGNES = atoi(ptb_InRec_Cur[PLA_NBLIGNES]);
	nb_platxcum++;
    
	return OK;
}


//==============================================================================
// Objet :    En rupture Dernière sur CONTRAT/EXERCICE/SECTION   de rétro
//==============================================================================
int n_ActionLastFPLATXCUM(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLastFPLATXCUM");

	n_ProcessingRuptureSyncVar(&Kbd_ruptGTSIIPIVOT, ptb_InRec_Cur);

	return OK;
}


/*==============================================================================
 Objet :    Initialisation de la variable de gestion de synchronisation (Esclave)
 Parametre(s) : Pointeur sur une structure T_RUPTURE_SYNC_VAR
 Retour :       En cas de probleme retourne ERR
                sinon retourne OK
==============================================================================*/
int n_InitGTSIIPIVOT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitGTSIIPIVOT");

	memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));
	
	if (n_OpenFileAppl("ESTC1063_I2","rt", &(pbd_Rupt->pf_InputFil)))
		return ERR;
	
	pbd_Rupt->n_NbRupture = 0;
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGTSIIPIVOT;
	pbd_Rupt->n_FilsSansPere   = n_ActionFsPGTSIIPIVOT;
	pbd_Rupt->n_ActionLigne    = n_ActionLigneSyncGTSIIPIVOT;
	pbd_Rupt->c_Separ = '~';

	return OK;
}


/*==============================================================================
 Objet :    Fonction de test de synchronisation avec la Maitre
 Parametre(s) :
   Pointeur sur la ligne du maitre
   Pointeur sur la ligne de l'esclave
 Retour :
   0 --> Pas de synchro
   1--> Situation de synchro
==============================================================================*/
int n_ConditionSyncGTSIIPIVOT(char **ptb_InRecPLATXCUM, char **ptb_InRecChild)
{
	DEBUT_FCT("n_ConditionSyncGTSIIPIVOT");

	int ret;

	// Modele de test de synchronisation :
	if ((ret = strcmp(ptb_InRecPLATXCUM[PLA_RETCTR_NF],       ptb_InRecChild[GTSII2_RETCTR_NF]))  != 0)  return(ret);
	if ((ret = strcmp(ptb_InRecPLATXCUM[PLA_RTY_NF],          ptb_InRecChild[GTSII2_RTY_NF]))  != 0)  return(ret);
	if ((ret = (atoi(ptb_InRecPLATXCUM[PLA_RETSEC_NF]) - atoi(ptb_InRecChild[GTSII2_RETSEC_NF]))) != 0)  return(ret);

	if (( ret = n_RecherchePlacement(ptb_InRecChild)) !=0)                                             return(ret);
	
	return 0;
}


/*==============================================================================
 Objet :    Fonction lancee pour chaque ligne synchronisee avec le Maitre
 Parametre(s) :
   Pointeur sur la ligne courante
 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneSyncGTSIIPIVOT(char **ptb_InRecPLATXCUM, char **ptb_InRecChild)
{
	DEBUT_FCT("n_ActionLigneSyncGTSIIPIVOT");

	char Ksz_WPREMIUM_M[23];
	char Ksz_WCHARGES_M[23];
	char Ksz_WCLAIM_M[23];
	char Ksz_SCOEGP_M[23];
	char Ksz_FPREMIUM_M[23];
	char Ksz_PRCO_M[23];
	char Ksz_PRCI_M[23];
	char Ksz_PRMRESD_M[23];
	char Ksz_PRMRESB_M[23];
	double d_WPREMIUM_M;
	double d_WCHARGES_M;
	double d_WCLAIM_M;
	double d_SCOEGP_M;
	double d_FPREMIUM_M;
	double d_PRCO_M;
	double d_PRCI_M;
	double d_PRMRESD_M;
	double d_PRMRESB_M;
	int i=0;

	if ( atoi(ptb_InRecChild[GTSII2_PLC_NT]) == 0)
	{
		// Un seul placement
		if ( atoi(ptb_InRecPLATXCUM[PLA_NBLIGNES]) <= 2     &&
		     atof(ptb_InRecPLATXCUM[PLA_RETSIGSHA_QOT_R]) == 1.0 )
		{
			ptb_InRecChild[GTSII2_PLC_NT]=platxcum[1].PLC_NT;
			ptb_InRecChild[GTSII2_RTO_NF]=platxcum[1].RTO_NF;
			n_WriteCols(Kp_OutputFileGTSIIPIVOT, ptb_InRecChild, '~', 0);
		}
		else
		{
			//memorisation montant avant écrasement.
			d_WPREMIUM_M  =(double)atof(ptb_InRecChild[GTSII2_WPREMIUM_M]);
			d_WCHARGES_M  =(double)atof(ptb_InRecChild[GTSII2_WCHARGES_M]);
			d_WCLAIM_M    =(double)atof(ptb_InRecChild[GTSII2_WCLAIM_M]);
			d_SCOEGP_M    =(double)atof(ptb_InRecChild[GTSII2_SCOEGP_M]);
			d_FPREMIUM_M  =(double)atof(ptb_InRecChild[GTSII2_FPREMIUM_M]);
			d_PRCO_M      =(double)atof(ptb_InRecChild[GTSII2_PRCO_M]);
			d_PRCI_M      =(double)atof(ptb_InRecChild[GTSII2_PRCI_M]);
			d_PRMRESD_M   =(double)atof(ptb_InRecChild[GTSII2_PRMRESD_M]);
			d_PRMRESB_M   =(double)atof(ptb_InRecChild[GTSII2_PRMRESB_M]);
			
			for(i=0;i<nb_platxcum;i++)
			{
//if (strcmp(ptb_InRecChild[GTSII2_RETCTR_NF], "17P000002") == 0)
// printf("retctr1 = %s - %s - %-.3lf - %-.3lf\n", ptb_InRecChild[GTSII2_RETCTR_NF], ptb_InRecChild[GTSII2_RTY_NF], platxcum[i].RETSIGSHA_QOT_R, d_WPREMIUM_M);
				sprintf(Ksz_WPREMIUM_M, "%-.3lf", d_WPREMIUM_M  * platxcum[i].RETSIGSHA_QOT_R);
				sprintf(Ksz_WCHARGES_M, "%-.3lf", d_WCHARGES_M  * platxcum[i].RETSIGSHA_QOT_R);
				sprintf(Ksz_WCLAIM_M, "%-.3lf",   d_WCLAIM_M    * platxcum[i].RETSIGSHA_QOT_R);
				sprintf(Ksz_SCOEGP_M, "%-.3lf",   d_SCOEGP_M    * platxcum[i].RETSIGSHA_QOT_R);
				sprintf(Ksz_FPREMIUM_M, "%-.3lf", d_FPREMIUM_M  * platxcum[i].RETSIGSHA_QOT_R);
				sprintf(Ksz_PRCO_M, "%-.3lf",     d_PRCO_M      * platxcum[i].RETSIGSHA_QOT_R);
				sprintf(Ksz_PRCI_M, "%-.3lf",     d_PRCI_M      * platxcum[i].RETSIGSHA_QOT_R);
				sprintf(Ksz_PRMRESD_M, "%-.3lf",  d_PRMRESD_M   * platxcum[i].RETSIGSHA_QOT_R);
				sprintf(Ksz_PRMRESB_M, "%-.3lf",  d_PRMRESB_M   * platxcum[i].RETSIGSHA_QOT_R);
				ptb_InRecChild[GTSII2_PLC_NT]=platxcum[i].PLC_NT;
				ptb_InRecChild[GTSII2_RTO_NF]=platxcum[i].RTO_NF;
//if (strcmp(ptb_InRecChild[GTSII2_RETCTR_NF], "17P000002") == 0)
// printf("retctr2 = %s - %s - %s - %-.3lf\n", ptb_InRecChild[GTSII2_RETCTR_NF], ptb_InRecChild[GTSII2_RTY_NF], Ksz_WPREMIUM_M, d_trav);
				// au moins 1 montant != 0
				if ( d_WPREMIUM_M !=0 || d_WCHARGES_M != 0 || d_WCLAIM_M != 0 || d_SCOEGP_M != 0 || d_FPREMIUM_M != 0 ||
				     d_FPREMIUM_M != 0 || d_PRCO_M != 0 || d_PRCI_M != 0 || d_PRMRESD_M != 0 || d_PRMRESB_M )
					n_WriteCols(Kp_OutputFileGTSIIPIVOT, ptb_InRecChild, '~', 0);
			}
		}
	}
	else
	{
		ptb_InRecChild[GTSII2_RTO_NF]=platxcum[1].RTO_NF;
		n_WriteCols(Kp_OutputFileGTSIIPIVOT, ptb_InRecChild, '~', 0);
	}

	return OK;
}


/*==============================================================================
 Objet :    Fonction lancee pour chaque ligne du fils non synchronisee avec le pere
 Parametre(s) :
   Pointeur sur la ligne courante (Esclave)
 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_RecherchePlacement(char **ptb_InRecChild)
{
	int trouve = -1;
	int i=0;
	
	for(i=0;i<nb_platxcum;i++)
	{
    	if ( strcmp(ptb_InRecChild[GTSII2_RETCTR_NF] , platxcum[i].RETCTR_NF)==0   &&
		     atoi(ptb_InRecChild[GTSII2_RTY_NF]) == platxcum[i].RTY_NF          &&
		     atoi(ptb_InRecChild[GTSII2_RETSEC_NF]) == platxcum[i].RETSEC_NF       &&
		     atoi(ptb_InRecChild[GTSII2_PLC_NT])    == atoi(platxcum[i].PLC_NT)    )
    	{
			trouve=0;
			break;
		}
	}

//  return trouve;
	return 0;
}


/*==============================================================================
 Objet :    Fonction lancee pour chaque ligne du fils non synchronisee avec le pere
 Parametre(s) :
   Pointeur sur la ligne courante (Esclave)
 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionFsPGTSIIPIVOT(char **ptb_InRecChild)
{
	DEBUT_FCT("n_ActionFsPGTSIIPIVOT");

	n_WriteCols(Kp_OutputFileGTSIIPIVOT, ptb_InRecChild, '~', 0);

	return OK;
}


