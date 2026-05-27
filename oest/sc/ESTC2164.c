/*==============================================================================
nom de l'application          : Creation des complements previsionnels
nom du source                 : ESTCLiberation.c
revision                      : $Revision: 1.25 $
date de creation              : 12/03/2014
auteur                        : A. Ben Jeddou
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Creation du fichier des Liberations.


------------------------------------------------------------------------------
[001] 20/06/2014 JBG :spot:25773 - Modify DETTRNCOD control
[002] 27/06/2014 JBG :spot:25773 - Amounts format modified and calls suppress
[003] 09/07/2014 ABJ :spot:25773 Modification of init_SubTrsAssoLigne()
[004] 10/07/2014 ABJ :spot:25773  correction du type du montant ( double au lieu de float)
[005] 21/07/2014 ABJ :spot:25773  Modification du DETRNCOD et Exercice lorsqu on a une constite sans liberation.
[006] 24/07/2014 ABJ :spot:25773  Calcul des liberations pour les Claim Reserve deposits (Ending).
[007] 28/08/2014 ABJ :spot:25773  Ecrasement des mauvaises liberations par des liberations montant =0
[008] 30/09/2014  ABJ :spot:25773   Traitement des constit et liberation sur les 1010  et 1140
[009] 03/10/2014 ABJ :spot:25773  Changement de la Cre_date
[010] 14/10/2014 ABJ :spot:25773  Ajout du mois bilan
[011] 14/10/2014 ABJ :spot:25773  Correction de l exercice pour 10260 et 12500
[012] 16/10/2014 ABJ :spot:25773  Verification de l existance des postes ( sinon ecriture dans le fichier Log)
[013] 23/02/2015 PME :spot:28341  Correction de la procedure n_ActionPereSansFils
[014] 25/02/2015 PME :spot:28341  Correction taille sz_Mnt insuffisante dans n_ActionPereSansFils
[015] 18/03/2015 PME :spot:28341  Correction de l'initialisation des chaines de caracteres
[016] 20/11/2015 SBE :spot:29253  Ajout calcul libération analytique
[017] 07/03/2016 SAS :spot:30250  MAJ calcul libération analytiques après modification du paramétrage
[018] 15/02/2019 RAF :spot:70045  REQ.L.02.05: Evolution quarterly
[019] 20/02/2019 BEL :spot:81896  Corriger le probleme de calcul en boucle des liberations
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE				*Kp_PrevFile;		// pointeur sur les previsions
FILE				*Kp_LibFile;		// pointeur sur les Liberations
FILE				*Kp_OutLibFile;		// pointeur sur les complements pour les traites cribles
FILE				*Kp_OutLogFile;		// [012]
FILE				*Kp_SubTRSFile;
FILE				*Kp_SubTRSAssoFile;	// pointeur sur les pilotages

T_RUPTURE_VAR		bd_RuptPrev;		// gestion rupture sur pilotage
T_RUPTURE_SYNC_VAR	bd_RuptLib;			// gestion rupture sur prev

T_SUBTRS			SubtrsLigne;
T_SUBTRSASSO		SubTrsAssoLigne;

char				Ksz_DateJour[11];	// Date de traitement
char				DETTRNCOD[6] = "";
int					Annee_courant;
int					Mois_bilan;			//[010]
int					Acy_min;
int					exercice;
int					writen = 0;

// Function Prev (fater file)
int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLignePrev(char **pbd_InRec_Cur);
int n_IsRPrev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrev(char **ptb_InRec_Cur);

// Function Liberation (child file)
int n_InitLib(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncLib (char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneLib(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionPereSansFils(char **ptb_InRec);
int n_ActionFilsSansPere(char **ptb_InRec);

void init_SubTrsAssoLigne();

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{
	// Init signal
	InitSig();

	if (n_BeginPgm(argc, argv) == ERR)
	  ExitPgm ( ERR_XX , "" );

	// Open output file
	if (n_OpenFileAppl("ESTC2164_O1", "wt", &Kp_OutLibFile) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2164_O2", "wt", &Kp_OutLogFile) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2164_I3", "rb", &Kp_SubTRSFile) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2164_I4", "rb", &Kp_SubTRSAssoFile) == ERR)
		ExitPgm(ERR_XX, "");

	n_ChargerTsubTRS(Kp_SubTRSFile);
	n_ChargerTsubTRSAsso(Kp_SubTRSAssoFile);

	strcpy(Ksz_DateJour, psz_GetCharArgv(1));
	Annee_courant = n_GetIntArgv(2);
	Mois_bilan = n_GetIntArgv(3);
	Acy_min = n_GetIntArgv(4);

	// Init Prev struct
	if (n_InitPrev(&bd_RuptPrev))
		ExitPgm (ERR_XX, "");

	// Init Lib struct
	if (n_InitLib(&bd_RuptLib))
		ExitPgm(ERR_XX, "");

	// Start of file processing
	if (n_ProcessingRuptureVar(&bd_RuptPrev) == ERR)
		ExitPgm(ERR_XX, "");

	// Close file
	if (n_CloseFileAppl("ESTC2164_I1", &(bd_RuptPrev.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl ("ESTC2164_I2", &(bd_RuptLib.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl ("ESTC2164_I3", &Kp_SubTRSFile) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2164_I4", &Kp_SubTRSAssoFile) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2164_O1", &Kp_OutLibFile) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2164_O2", &Kp_OutLogFile) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_EndPgm() == ERR)
	  ExitPgm(ERR_XX, "");
	exit(0);
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.
retour :    0
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitPrev");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	if (n_OpenFileAppl("ESTC2164_I1", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_IsRPrev;
	pbd_Rupt->n_ActionLigne = n_ActionLignePrev;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(0);
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK
==============================================================================*/
int n_InitLib(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitLib");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR)) ;
	// ouverture du fichier esclave
	n_OpenFileAppl("ESTC2164_I2", "rt", &(pbd_Rupt->pf_InputFil));
	pbd_Rupt->n_NbRupture = 0;
	pbd_Rupt->ConditionEndSync = n_ConditionSyncLib;
	pbd_Rupt->n_ActionLigne = n_ActionLigneLib;
	pbd_Rupt->n_PereSansFils = n_ActionPereSansFils;
	pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPere;
	pbd_Rupt->c_Separ = '~' ;
	RETURN_VAL(OK);
}

/*==============================================================================
objet : fonction de test de rupture niveau 1 sur
        Contrat/Section/Exercice/Annee de compte
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsRPrev(char **ptb_InRec, char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsRPrev");
	if (strcmp(ptb_InRec[PRE_CTR_NF], ptb_InRec_Cur[PRE_CTR_NF]) != 0)
		RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_SEC_NF], ptb_InRec_Cur[PRE_SEC_NF]) != 0)
		RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_ACY_NF], ptb_InRec_Cur[PRE_ACY_NF]) != 0)
		RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_ESTMTH_NF], ptb_InRec_Cur[PRE_ESTMTH_NF]) != 0) // [018]
		RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_UWY_NF], ptb_InRec_Cur[PRE_UWY_NF]) != 0)
		RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != 0)
		RETURN_VAL(1);
	if (strcmp(ptb_InRec[PRE_GAAP_NF], ptb_InRec_Cur[PRE_GAAP_NF]) != 0)
		RETURN_VAL(1);
	RETURN_VAL (0);
}

/*==============================================================================
objet :
	fonction de test de synchro
retour :
	0		---> pbd_InRecOwner = pbd_InRecChild (egalite de rubriques a synchroniser)
	> 0		---> pbd_InRecOwne> > pbd_InRecChild
	< 0		---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncLib (char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */ )
{
	int  ret;
	int  reslt = 0;
	int	 mounth = atoi(pbd_InRecOwner[PRE_ESTMTH_NF]);
	char ACMTRS[5] = "";

	DEBUT_FCT("n_ConditionSyncMvt");
	exercice = atoi(pbd_InRecOwner[PRE_UWY_NF]);
	if (mounth == 12 || mounth == 13)
		exercice += i_LiberationExeP1(atoi(pbd_InRecOwner[PRE_ACMTRS_NT]), atoi(pbd_InRecOwner[PRE_ACCADMTYP_CT]));
	init_SubTrsAssoLigne();
	sprintf(DETTRNCOD, "%s", pbd_InRecOwner[PRE_DETTRNCOD_CF]);
	DETTRNCOD[5] = 0;
	reslt = n_FindTsubTRSAsso(&SubTrsAssoLigne, 1, 1, DETTRNCOD);
	if (reslt != -1)
	{
		sprintf(DETTRNCOD, "%s", SubTrsAssoLigne.DETTRNCOD2_CF);
	}
	else
	{
		if (DETTRNCOD[2] != '9')
			DETTRNCOD[2]++;
		DETTRNCOD[5] = 0;
	}
	// Ajout de ACMTRS a la condition de Rupture [019]
	// Calcul de l ACMTRS de liberation 
	sprintf(ACMTRS, "%s", pbd_InRecOwner[PRE_ACMTRS_NT]);
	ACMTRS[4] = 0;
	if (ACMTRS[3] == '3')
	{	ACMTRS[3] = '4';}
	// Modifier l'ordre des tests de la cle de repture [019]
	if ((ret = strcmp(pbd_InRecOwner[PRE_CTR_NF], pbd_InRecChild[PRE_CTR_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRecOwner[PRE_SEC_NF], pbd_InRecChild[PRE_SEC_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = ((atoi(pbd_InRecOwner[PRE_ACY_NF]) + 1) - atoi(pbd_InRecChild[PRE_ACY_NF]))) !=0)
		RETURN_VAL (ret); // [019] Retourner la difference a la place de '1' (Un)
	if ((ret = strcmp(pbd_InRecOwner[PRE_ESTMTH_NF], pbd_InRecChild[PRE_ESTMTH_NF])) != 0) // [018]
		RETURN_VAL(ret);
	if ((ret = strcmp(ACMTRS, pbd_InRecChild[PRE_ACMTRS_NT])) != 0)
		RETURN_VAL (ret); // [019] Ajouter ACMTRS a la condition
	if ( (ret = strcmp(DETTRNCOD, pbd_InRecChild[PRE_DETTRNCOD_CF])) != 0 )
		RETURN_VAL (ret);
	//Ajout de l exercice
	if ((ret = (exercice - atoi(pbd_InRecChild[PRE_UWY_NF]))) != 0)
		RETURN_VAL (ret); // [019] Retourner la difference a la place de '1' (Un)
	if ( (ret = strcmp(pbd_InRecOwner[PRE_GAAP_NF], pbd_InRecChild[PRE_GAAP_NF])) != 0 )
		RETURN_VAL (ret);
	RETURN_VAL (0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionLignePrev");

  writen = 0;

  memset(&SubtrsLigne, 0, sizeof(T_SUBTRS));
  sprintf(DETTRNCOD, "%s", "");
  exercice = 0;
  n_FindTsubTRS(&SubtrsLigne, ptb_InRec_Cur[PRE_DETTRNCOD_CF]);
  //if ( (((SubtrsLigne.TRSTYPE_CT == 3) || (SubtrsLigne.TRSTYPE_CT == 4 )) && (ptb_InRec_Cur[PRE_ACMTRS_NT][3] == '3')) //[006]
  //   || (((SubtrsLigne.TRSTYPE_CT == 6) || (SubtrsLigne.TRSTYPE_CT == 5)) &&                                           //[016]
  //          (ptb_InRec_Cur[PRE_ACMTRS_NT][3] == '3')))                                                                  //[017] 
	if (SubtrsLigne.TRSTYPE_CT >= 3 && SubtrsLigne.TRSTYPE_CT <= 6 && ptb_InRec_Cur[PRE_ACMTRS_NT][3] == '3') //[006]
  {
    n_ProcessingRuptureSyncVar (&bd_RuptLib, ptb_InRec_Cur);
  }
  RETURN_VAL (0);
}

/*==============================================================================
objet : fonction lancee pour chaque ligne des previsions synchronisee
        avec les Liberations
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneLib(
  char **ptb_InRecOwner ,         /* adresse de la ligne du maitre */
  char **ptb_InRecChild)          /* adresse de la ligne de l'esclave */
{
	char	dACy[5];
	char	dMth[3];
	char	dUwy[5];
	char	sz_Mnt[40];
	int		annee_compte;
	int		mounth;
	double	montant;
	int		j;
	char	sz_Mth[3];      // [015]
	char	sz_Datelong[22];
	char	*psz_lignePRE[PRE_NBCOL + 1];
	char	*psz_ligneLib[PRE_NBCOL + 1];

	strcpy(sz_Mth, "XX");  // [015]
	if (writen == 0)
	{
		for (j = 0; j < PRE_NBCOL; j++)
		{
			psz_lignePRE[j] = ptb_InRecOwner[j];
			psz_ligneLib[j] = ptb_InRecChild[j];
		}
		psz_lignePRE[PRE_NBCOL] = 0;
		psz_ligneLib[PRE_NBCOL] = 0;
		psz_lignePRE[PRE_BATCH_B] = "1";
		psz_lignePRE[PRE_ADJCOD_CT] = "0";
		psz_ligneLib[PRE_ADJCOD_CT] = "0";
		// start [018]
		mounth = atoi(psz_lignePRE[PRE_ESTMTH_NF]);
		annee_compte = atoi(psz_lignePRE[PRE_ACY_NF]);
		if (mounth == 12)
		{
			mounth = 3;
			annee_compte += 1;
		}
		else if (mounth == 13)
			annee_compte += 1;
		else
			mounth += 3;
		sprintf(dMth, "%d", mounth);
		dMth[3] = 0;
		sprintf(psz_lignePRE[PRE_ESTMTH_NF], "%s", dMth);
		// end [018]
		sprintf(dACy, "%d", annee_compte);
		dACy[4] = 0;
		sprintf(psz_lignePRE[PRE_ACY_NF], "%s", dACy);
		sprintf(dUwy, "%d", exercice);
		dUwy[4] = 0;
		strcpy(psz_lignePRE[PRE_UWY_NF], dUwy);
		montant = atof(psz_lignePRE[PRE_ESTMNT_M]) * (-1);
		memset(sz_Mnt, 0, 40);
		sprintf(sz_Mnt, "%.3lf", montant);
		psz_lignePRE[PRE_ESTMNT_M] = sz_Mnt;
		sprintf(sz_Datelong, "%s 23:59:55", Ksz_DateJour);
		psz_lignePRE[PRE_CRE_D] = sz_Datelong;
		psz_lignePRE[PRE_LSTUPD_D] = sz_Datelong;
		psz_lignePRE[PRE_LSTUPDUSR_CF] = "dbo";
		sprintf(psz_lignePRE[PRE_DETTRNCOD_CF], "%s", DETTRNCOD);
		//sprintf(psz_lignePRE[PRE_BALSHTMTH_NF],"%d",Mois_bilan);  //[010]
		sprintf(sz_Mth, "%d", Mois_bilan); //[010]
		psz_lignePRE[PRE_BALSHTMTH_NF] = sz_Mth;
		if (psz_lignePRE[PRE_ACMTRS_NT][3] == '3')
			psz_lignePRE[PRE_ACMTRS_NT][3] = '4';
		writen = 1;
		if ( montant != atof(psz_ligneLib[PRE_ESTMNT_M]))
		{
			n_WriteCols(Kp_OutLibFile, psz_lignePRE, '~', 0);
		}
		else   /*on prends la ligne LifestLib */
		{
			n_WriteCols(Kp_OutLibFile, psz_ligneLib, '~', 0);
		}
	}
	RETURN_VAL (OK);
}

/*==============================================================================
objet :
        fonction lancee quand le fichier prevision participe seul

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionPereSansFils(char **ptb_InRec)
{
	char	sz_ACy[5];
	char	sz_Uwy[5];
	char	sz_Mnt[40];          // [014]
	char	sz_Mth[3];           // [015]
	char	dMth[3];
	int		mounth;
	char	sz_Datelong[20];     // [013]
	char	sz_User[4];          // [013] [015]
	char	sz_Batch[2];         // [013] [015]
	char	sz_AdjCod[2];        // [013] [015]
	int		annee_compte;
	double	montant;
	int		j;
	int		reslt = 0;
	char	*psz_ligne[PRE_NBCOL + 1];

	strcpy(sz_Mth, "XX");       // [015]
	strcpy(sz_User, "dbo");     // [015]
	strcpy(sz_Batch, "1");      // [015]
	strcpy(sz_AdjCod, "0");     // [015]
	for (j = 0; j < PRE_NBCOL; j++)
	{
		psz_ligne[j] = ptb_InRec[j];
	}
	mounth = atoi(psz_ligne[PRE_ESTMTH_NF]);
	psz_ligne[PRE_NBCOL] = 0;
	psz_ligne[PRE_BATCH_B] = sz_Batch;  // [013]
	psz_ligne[PRE_ADJCOD_CT] = sz_AdjCod;  // [013]
	exercice = atoi(psz_ligne[PRE_UWY_NF]);
	if (mounth == 12 || mounth == 13)
		exercice += i_LiberationExeP1( atoi(psz_ligne[PRE_ACMTRS_NT]) , atoi(psz_ligne[PRE_ACCADMTYP_CT]) );
	init_SubTrsAssoLigne();
	sprintf(DETTRNCOD, "%s", psz_ligne[PRE_DETTRNCOD_CF]);
	DETTRNCOD[5] = 0;
	reslt = n_FindTsubTRSAsso(&SubTrsAssoLigne, 1, 1, DETTRNCOD);
	if (reslt != (-1))
	{
		sprintf(DETTRNCOD, "%s", SubTrsAssoLigne.DETTRNCOD2_CF);
	}
	else
	{
		if (DETTRNCOD[2] != '9')
			DETTRNCOD[2]++;
		DETTRNCOD[5] = 0;
	}
	//[012]
	memset(&SubtrsLigne, 0, sizeof(T_SUBTRS));
	reslt = n_FindTsubTRS(&SubtrsLigne, DETTRNCOD);
	psz_ligne[PRE_DETTRNCOD_CF] = DETTRNCOD;  // [013]
	if (reslt == (-1))
	{
		n_WriteCols(Kp_OutLogFile, psz_ligne, '~', 0);
		RETURN_VAL (OK);
	}
	//[012]
	/* L annee de compte +1 */
	// start [018]
	mounth = atoi(psz_ligne[PRE_ESTMTH_NF]);
	annee_compte = atoi(psz_ligne[PRE_ACY_NF]);
	if (mounth == 12)
	{
		mounth = 3;
		annee_compte += 1;
	}
	else if (mounth == 13)
		annee_compte += 1;
	else
		mounth += 3;
	sprintf(dMth, "%d", mounth);
	dMth[3] = 0;
	sprintf(psz_ligne[PRE_ESTMTH_NF], "%s", dMth);
	// end [018]
	sprintf(sz_ACy, "%d", annee_compte);
	psz_ligne[PRE_ACY_NF] = sz_ACy;  // [013]
	/* Le Montant change de signe */
	montant = atof(psz_ligne[PRE_ESTMNT_M]) * (-1);
	memset(sz_Mnt, 0, 40);
	sprintf(sz_Mnt, "%.3lf", montant);
	psz_ligne[PRE_ESTMNT_M] = sz_Mnt;
	/* modification eventuelle de l'exercice */
	sprintf(sz_Uwy, "%d", exercice);
	psz_ligne[PRE_UWY_NF] = sz_Uwy;  // [013]
	/* L'ACMTRS se transforme en liberation */
	if ( psz_ligne[PRE_ACMTRS_NT][3] == '3')
		psz_ligne[PRE_ACMTRS_NT][3] = '4';
	sprintf(sz_Datelong, "%s 23:59:56", Ksz_DateJour);  // [013]
	psz_ligne[PRE_CRE_D] = sz_Datelong;                 // [013]
	psz_ligne[PRE_LSTUPD_D] = sz_Datelong;              // [013]
	psz_ligne[PRE_LSTUPDUSR_CF] = sz_User;              // [013]
	//sprintf(psz_ligne[PRE_BALSHTMTH_NF],"%d",Mois_bilan);  //[010]
	sprintf(sz_Mth, "%d", Mois_bilan); //[010]
	psz_ligne[PRE_BALSHTMTH_NF] = sz_Mth;
	n_WriteCols(Kp_OutLibFile, psz_ligne, '~', 0);
	writen = 1;
	RETURN_VAL (OK);
}
/*==============================================================================
objet :
        fonction lancee quand le fichier prevision participe seul

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPere(char **ptb_InRec)
{
	/* L annee de compte +1 */
	if (atoi(ptb_InRec[PRE_ACY_NF]) == (Annee_courant - Acy_min))
	{
		n_WriteCols(Kp_OutLibFile, ptb_InRec, '~', 0);
	}
	RETURN_VAL (OK);
}

/*==========================================================================
     Objet :    Initialisation de la structure TRSASSO

     Nom:       init_SubTrsAssoLigne

     Parametres:


     Retour:    0
===========================================================================*/
//[003]
void init_SubTrsAssoLigne()
{
	strcpy(SubTrsAssoLigne.ASSOTYP_CT, "");
	SubTrsAssoLigne.CTX_NT = 0;
	strcpy (SubTrsAssoLigne.DETTRNCOD1_CF, "");
	strcpy(SubTrsAssoLigne.CTX_LL, "");
	strcpy (SubTrsAssoLigne.DETTRNCOD2_CF, "");
	strcpy (SubTrsAssoLigne.DETTRNCOD3_CF, "");
	SubTrsAssoLigne.GUI_B = 0;
	SubTrsAssoLigne.ACMTRS_NT = 0;
	strcpy(SubTrsAssoLigne.CRE_D, "");
	strcpy(SubTrsAssoLigne.CREUSR_CF, "");
	strcpy(SubTrsAssoLigne.LSTUPD_D, "");
	strcpy(SubTrsAssoLigne.LSTUPDUSR_CF, "");
}
