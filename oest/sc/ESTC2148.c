/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
  nom de l'application          : Calcul de DAC
  nom du source                 : ESTC2148.c
  date de creation              : 26/07/2010
auteur                        : D.GATIBELZA
squelette de base             : batch
------------------------------------------------------------------------------
description :   ESTVIE19177 V10 Mettre en place un calcul spécial de DAC
pour Köln automatic DAC calculation taking into account the financing commission,
the technical result, the interest on deposit
------------------------------------------------------------------------------
historique des modifications :
---------------
[001] R.CASSIS 13/10/2010 :spot:19177 - Generation mouvement de Libération des CNA Consos. - V101
[002] Florent  06/09/2011 :spot:22460 corrections gestion des taux de TFAMCNA
[003] Florent  19/12/2011 :spot:22315 corrections gestion des libérations
[004] Prajakta 25/06/2013 :Phase1B migration code changes for warning removal
[005] 13/09/2014 ABJ  spot:25773    Correction du DETTRNCOD pour les 1193
[006] 14/10/2014 ABJ  spot:25773    Correction des Sprintfs
[006] 14/10/2014 ABJ  spot:25773    Suppression du Gaap 5
[007] 03/06/2015 DFI  spot:28472    EST41 Automatic Calculation (pas de calcul DAC auto)
[008] 12/03/2019 RAF  spot:70045:   add mounth in ruptur
==============================================================================*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>
#include "ESTC2148.h"



char champs[10]="";      /** Added for Phase1b migration **/
T_LIFDRI_ALL Kbd_LifDri[MAX_LIFDRI];

/*==============================================================================
objet :     point d'entree du programme
retour:     En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
	int i = 0; /* Added for Phase1b Migration */	

	// Initialisation des signaux
	InitSig();
	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Recuperation des parametres */
	strcpy(Ksz_DateJour,psz_GetCharArgv(1));
	strcpy(Ksz_AnneeBilan,psz_GetCharArgv(2));
	strcpy(Ksz_MoisBilan,psz_GetCharArgv(3));

	// Ouverture des fichiers en entrée
	if (n_OpenFileAppl("ESTC2148_I5","rb", &FichierTLIFDRI_I5))
		ExitPgm ( ERR_XX , "" );
	// ouverture des fichiers en sortie
	if (n_OpenFileAppl("ESTC2148_O1","wt", &Fichier_O1) == ERR)
		ExitPgm ( ERR_XX , "" );
	if (n_OpenFileAppl("ESTC2148_O2","wt", &Fichier_O2) == ERR)
		ExitPgm ( ERR_XX , "" );

	for(i=ACCEPT;i<=RETRO;i++) /* Updated for Phase1b Migration */
	{
		ligne_SDAC1[i] = 0.0;
		ligne_SDAC2[i] = 0.0;

		ligne_IDAC1[i] = 0.0;
		ligne_IDAC2[i] = 0.0;

		SDAC_prec[i] = &ligne_SDAC1[i];
		SDAC_cur[i]  = &ligne_SDAC2[i];

		IDAC_prec[i] = &ligne_IDAC1[i];
		IDAC_cur[i]  = &ligne_IDAC2[i];

		strcpy(sz_DETTRNCOD[i],""); //[005]
	}

	memset(&AE,0,sizeof(AE));
	memset(&INT,0,sizeof(INT));

	RESTEC.nb_acmtrs = 0;

	n_ChargerTLIFDRI();

	// Initialisation
	if ( n_InitTACCPAR(&bd_RuptTACCPAR) )
		ExitPgm ( ERR_XX , "" );
	if ( n_InitPERIMETRE(&bd_RuptPERIMETRE) )
		ExitPgm ( ERR_XX , "" );
	if ( n_InitTFAMCNA_I4(&bd_RuptTFAMCNA_I4) )
		ExitPgm ( ERR_XX , "" );
	if ( n_InitLIFEST_I2(&bd_RuptLIFEST_I2) )
		ExitPgm ( ERR_XX , "" );

	// lancement du traitement du fichier
	if ( n_ProcessingRuptureVar (&bd_RuptTACCPAR) == ERR )
		ExitPgm ( ERR_XX , "" );
	if ( n_ProcessingRuptureVar (&bd_RuptPERIMETRE) == ERR )
		ExitPgm ( ERR_XX , "" );

	// Fermeture fichier
	if (n_CloseFileAppl ("ESTC2148_I1",&(bd_RuptPERIMETRE.pf_InputFil)))
		ExitPgm ( ERR_XX , "" );
	if (n_CloseFileAppl ("ESTC2148_I2",&(bd_RuptLIFEST_I2.pf_InputFil)))
		ExitPgm ( ERR_XX , "" );
	if (n_CloseFileAppl ("ESTC2148_I3",&(bd_RuptTACCPAR.pf_InputFil)))
		ExitPgm ( ERR_XX , "" );
	if (n_CloseFileAppl ("ESTC2148_I4",&(bd_RuptTFAMCNA_I4.pf_InputFil)))
		ExitPgm ( ERR_XX , "" );
	if (n_CloseFileAppl ("ESTC2148_I5",&FichierTLIFDRI_I5))
		ExitPgm ( ERR_XX , "" );
	if (n_CloseFileAppl ("ESTC2148_O1",&Fichier_O1))
		ExitPgm ( ERR_XX , "" );
	if (n_CloseFileAppl ("ESTC2148_O2",&Fichier_O2))
		ExitPgm ( ERR_XX , "" );
	if (n_EndPgm () == ERR)
		ExitPgm ( ERR_XX , "" );

	exit(OK) ;
}

/*==============================================================================
objet :     Initialisation du fichier
retour:     OK
==============================================================================*/
int n_InitTACCPAR(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FONCTION("n_InitTACCPAR");

	memset( pbd_Rupt,0,sizeof(T_RUPTURE_VAR) ) ;

	// ouverture du fichier esclave
	n_OpenFileAppl ("ESTC2148_I3","rt",&(pbd_Rupt->pf_InputFil));

	pbd_Rupt->n_NbRupture           = 0  ;
	pbd_Rupt->n_ActionLigne         = n_ActionLigneTACCPAR;
	pbd_Rupt->c_Separ   = '~' ;

	RETURN_VAL(OK);
}



/*==============================================================================
objet : fonction lancee pour chaque ligne du perimetre
retour: OK ---> traitement correctement effectue
ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneTACCPAR( char **ptb_InRecTACCPAR )
{
	char sz_dettrs[9]= "";
	char DETT[9]="";
	char DETR[6]="";

	int i = 0; /* Added for Phase1b Migration */
	DEBUT_FONCTION("n_ActionLigneTACCPAR");

	// Chargement du Tableau des Résultats Techniques
	n_ChargerTABLEAU_TACCPAR(ptb_InRecTACCPAR, ACC_RESFIN_B, &RESTEC);


	for(i=ACCEPT;i<=RETRO;i++) /* Updated for Phase1b Migration */	 
	{
		strcpy( sz_dettrs, n_RechercheTACCPAR(ptb_InRecTACCPAR, i, ACC_DETTRS_CF));
		sz_dettrs[8]= 0;
		if(strcmp(sz_dettrs,"") != 0)
		{
			sprintf(DETT, "%s", sz_dettrs+1);           // On ne conserve pas le premier caractère du poste ( sera recalculé plus loin en fonction de la LOB )
			DETT[8]=0;
			strcpy( sz_DETTRS[i],DETT);
			strcpy( sz_RETCOD[i], n_RechercheTACCPAR(ptb_InRecTACCPAR, i, ACC_RETCOD_CT));
			strcpy( sz_ADJSIG[i], n_RechercheTACCPAR(ptb_InRecTACCPAR, i, ACC_ADJSIG_B));
			strcpy( sz_SPIMOD[i], n_RechercheTACCPAR(ptb_InRecTACCPAR, i, ACC_SPIMOD_CT));
			strcpy( sz_ADJCOD[i], n_RechercheTACCPAR(ptb_InRecTACCPAR, i, ACC_ADJCOD_CT));
			sprintf( DETR,"%s",sz_dettrs+2);
			DETR[5]=0;
			strcpy( sz_DETTRNCOD[i], DETR);
		}
	}

	RETURN_VAL(OK);
}



/*=============================================================================
objet : Chargement du tableau TACCPAR
=============================================================================*/
int n_ChargerTABLEAU_TACCPAR( char **ptb_InRecTACCPAR, int ACC_POSITION_B, T_POSTE_ACCPAR *posteACCPAR )
{
	if(atoi(ptb_InRecTACCPAR[ACC_POSITION_B])==1)
	{
		strcpy(posteACCPAR->acmtrs[posteACCPAR->nb_acmtrs], ptb_InRecTACCPAR[ACC_ACMTRS_NT]);
		posteACCPAR->nb_acmtrs++;
	}

	return(0);
}

/*=============================================================================
objet : Recherche le DETTRS du poste de regroupement
=============================================================================*/
char *n_RechercheTACCPAR( char **ptb_InRecTACCPAR, int ACC_RET, int ACC_CHAMPS )
{
	/*char champs[10]="";*/ /** Commented for Phase1b migration **/

	if(atoi(ptb_InRecTACCPAR[ACC_ACMTRS_NT])==IDAC_ACMTRS[ACC_RET])
	{
		strcpy(champs, ptb_InRecTACCPAR[ACC_CHAMPS]);
		return(champs);
	}
	else return ("");    	
}


/*==============================================================================
objet :     Initialisation du maitre
retour:     OK
==============================================================================*/
int n_InitPERIMETRE(T_RUPTURE_VAR  *pbd_Rupt)
{

	DEBUT_FONCTION("n_InitPERIMETRE");

	memset( pbd_Rupt,0,sizeof(T_RUPTURE_VAR) ) ;

	// ouverture du fichier esclave
	n_OpenFileAppl ("ESTC2148_I1","rt",&(pbd_Rupt->pf_InputFil));

	pbd_Rupt->n_ActionLigne         = n_ActionLigne_PERIMETRE;

	pbd_Rupt->n_NbRupture           = 1;
	// Rupture sur CONTRAT/SECTION
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRupture_PERIMETRE_0;
	pbd_Rupt->n_ActionFirst[0]      = n_ActionRuptureFirst_PERIMETRE_0;
	pbd_Rupt->n_ActionLast[0]       = n_ActionRuptureLast_PERIMETRE_0;

	pbd_Rupt->c_Separ       = '~' ;

	RETURN_VAL(OK);
}



/*=============================================================================
objet : fonction de detection de rupture sur CONTRAT/SECTION
retour: 0 ===> pas de rupture
1 ===> rupture
=============================================================================*/
int n_ConditionRupture_PERIMETRE_0(char **pbd_InRecPREC, char **pbd_InRecCUR)
{
	int ret=0;

	DEBUT_FONCTION("n_ConditionRupture_PERIMETRE_0");

	if( (ret = strcmp(pbd_InRecPREC[PER_CTR_NF],   pbd_InRecCUR[PER_CTR_NF])     )   != 0 )           RETURN_VAL(ret);
	if( (ret = strcmp(pbd_InRecPREC[PER_SEC_NF],   pbd_InRecCUR[PER_SEC_NF])     )   != 0 )           RETURN_VAL(ret);

	RETURN_VAL(ret);
}



/*=============================================================================
objet : fonction lancee en rupture première sur CONTRAT/SECTION
retour: OK
=============================================================================*/
int n_ActionRuptureFirst_PERIMETRE_0(char **ptb_InRecPERIM)
{
	int i;

	DEBUT_FONCTION("n_ActionRuptureFirst_PERIMETRE_0");

	// Nouveau contrat/section : initialisation.
	*SDAC_prec[ACCEPTouRETRO]=0.0;
	*SDAC_cur [ACCEPTouRETRO]=0.0;
	*IDAC_prec[ACCEPTouRETRO]=0.0;
	*IDAC_cur [ACCEPTouRETRO]=0.0;


	for( i=0; i<nbCtrSecUwy; i++)
	{
		strcpy(STR_CNATYP[i].CTR_NF, "");
		STR_CNATYP[i].SEC_NF = 0;
		STR_CNATYP[i].UWY_NF = 0;
		STR_CNATYP[i].CNATYP = 0;
	}
	nbCtrSecUwy=0;

	// Le premier exercice du Contrat/Section
	UWY_NF_premier=atoi(ptb_InRecPERIM[PER_UWY_NF]);

	nbSECSTS_RESIL=0;

	return(OK);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du perimetre
==============================================================================*/
int n_ActionLigne_PERIMETRE( char **ptb_InRecPERIM )
{
	DEBUT_FONCTION("n_ActionLigne_PERIMETRE");

	strcpy(STR_CNATYP[nbCtrSecUwy].CTR_NF, ptb_InRecPERIM[PER_CTR_NF]);
	STR_CNATYP[nbCtrSecUwy].SEC_NF = atoi(ptb_InRecPERIM[PER_SEC_NF]);
	STR_CNATYP[nbCtrSecUwy].UWY_NF = atoi(ptb_InRecPERIM[PER_UWY_NF]);
	STR_CNATYP[nbCtrSecUwy].CNATYP = atoi(ptb_InRecPERIM[PER_CNATYP_CT]);
	nbCtrSecUwy++;

	if( atoi(ptb_InRecPERIM[PER_SECSTS_CT]) == 19)
	{
		strcpy(T_SECSTS_RESIL[nbSECSTS_RESIL].CTR_NF, ptb_InRecPERIM[PER_CTR_NF]);
		strcpy(T_SECSTS_RESIL[nbSECSTS_RESIL].UWY_NF, ptb_InRecPERIM[PER_UWY_NF]);
		strcpy(T_SECSTS_RESIL[nbSECSTS_RESIL].UW_NT,  ptb_InRecPERIM[PER_UW_NT] );
		strcpy(T_SECSTS_RESIL[nbSECSTS_RESIL].END_NT, ptb_InRecPERIM[PER_END_NT]);
		strcpy(T_SECSTS_RESIL[nbSECSTS_RESIL].SEC_NF, ptb_InRecPERIM[PER_SEC_NF]);
		nbSECSTS_RESIL++;
	}

	RETURN_VAL(OK);
}


/*=============================================================================
objet : fonction lancee en rupture derniere sur CONTRAT/SECTION
retour: OK
=============================================================================*/
int n_ActionRuptureLast_PERIMETRE_0(char **ptb_InRecPERIM)
{
	DEBUT_FONCTION("n_ActionRuptureLast_PERIMETRE_0");

	// Le dernier exercice du Contrat/Section
	UWY_NF_dernier=atoi(ptb_InRecPERIM[PER_UWY_NF]);


	nb_UWY_TFAMCNA_AE =0;
	nb_UWY_TFAMCNA_INT=0;
	memset(&AE,0,sizeof(AE));
	memset(&INT,0,sizeof(AE));

	n_ProcessingRuptureSyncVar (&bd_RuptTFAMCNA_I4, ptb_InRecPERIM) ;

	// On ne crée des DAC que s'il existe des taux pour le contrat/section
	if( nb_UWY_TFAMCNA_AE != 0 && nb_UWY_TFAMCNA_INT != 0 )
		n_ProcessingRuptureSyncVar (&bd_RuptLIFEST_I2,  ptb_InRecPERIM) ;

	return(OK);
}



/*==============================================================================
objet :     Initialisation du fichier
retour:     OK
==============================================================================*/
int n_InitTFAMCNA_I4(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
	DEBUT_FONCTION("n_InitTFAMCNA_I4");

	memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	// ouverture du fichier esclave
	if ( n_OpenFileAppl ("ESTC2148_I4","rt",&(pbd_Rupt->pf_InputFil)))
		ExitPgm ( ERR_XX , "" );

	// fonction du test de la ligne du maitre avec l'esclave
	pbd_Rupt->ConditionEndSync      = n_ConditionSyncPERIMETRE_TFAMCNA;
	pbd_Rupt->n_ActionLigne         = n_ActionLigneTFAMCNA_I4;

	pbd_Rupt->n_NbRupture           = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRupture_TFAMCNA_I4_0;
	pbd_Rupt->n_ActionLast[0]       = n_ActionRuptureLast_TFAMCNA_I4_0;
	pbd_Rupt->c_Separ   = '~' ; 

	RETURN_VAL(OK);
}



/*==============================================================================
objet : fonction de test de synchro
retour: 0       ---> ptb_InRecPERIM = pbd_InRecGT    ( egalite de rubriques a synchroniser)
> 0     ---> ptb_InRecPERIM > pbd_InRecGT
< 0     ---> ptb_InRecPERIM < pbd_InRecGT
==============================================================================*/
int n_ConditionSyncPERIMETRE_TFAMCNA( char **ptb_InRecPERIM, char **ptb_InRecTFAMCNA )
{
	int ret=0;

	DEBUT_FONCTION("n_ConditionSyncPERIMETRE_TFAMCNA");

	if( (ret = strcmp(ptb_InRecPERIM[PER_CTR_NF],   ptb_InRecTFAMCNA[CNA_CTR_NF])     )   != 0 )
		RETURN_VAL(ret);
	if( (ret = atoi(ptb_InRecPERIM[PER_SEC_NF]) -   atoi(ptb_InRecTFAMCNA[CNA_SEC_NF]))   != 0 )
		RETURN_VAL(ret);

	RETURN_VAL(0);
}


/*=============================================================================
objet : fonction de detection de rupture sur CONTRAT/SECTION/EXERCICE
retour: 0 ===> pas de rupture
1 ===> rupture
=============================================================================*/
int n_ConditionRupture_TFAMCNA_I4_0(char **pbd_InRecPREC, char **pbd_InRecCUR)
{
	int ret=0;

	DEBUT_FONCTION("n_ConditionRupture_TFAMCNA_I4_0");

	if( (ret = strcmp(pbd_InRecPREC[CNA_CTR_NF],   pbd_InRecCUR[CNA_CTR_NF])     )   != 0 )
		RETURN_VAL(ret);
	if( (ret = strcmp(pbd_InRecPREC[CNA_SEC_NF],   pbd_InRecCUR[CNA_SEC_NF])     )   != 0 )
		RETURN_VAL(ret);
	if( (ret = strcmp(pbd_InRecPREC[CNA_UWY_NF],   pbd_InRecCUR[CNA_UWY_NF])     )   != 0 )
		RETURN_VAL(ret);

	RETURN_VAL(ret);
}



/*==============================================================================
objet : fonction lancee pour chaque ligne du perimetre
retour: OK ---> traitement correctement effectue
ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneTFAMCNA_I4( char **ptb_InRecPERIM, char **ptb_InRecTFAMCNA )
{
	DEBUT_FONCTION("n_ActionLigneTFAMCNA_I4");

	n_ChargerTABLEAU_TFAMCNA(ptb_InRecTFAMCNA, CNA_ADMEXP_R,   &AE[nb_UWY_TFAMCNA_AE]);
	n_ChargerTABLEAU_TFAMCNA(ptb_InRecTFAMCNA, CNA_CNACONSO_R, &INT[nb_UWY_TFAMCNA_INT]);

	RETURN_VAL(OK);
}


/*=============================================================================
objet : fonction lancee en rupture derniere sur CONTRAT/SECTION/EXERCICE
retour: OK
=============================================================================*/
int n_ActionRuptureLast_TFAMCNA_I4_0( char **ptb_InRecPERIM, char **ptb_InRecTFAMCNA )
{
	DEBUT_FONCTION("n_ActionRuptureLast_TFAMCNA_I4_0");

	nb_UWY_TFAMCNA_AE++;
	nb_UWY_TFAMCNA_INT++;

	return(OK);
}



/*==============================================================================
objet : Chargement du tableau pour un CTR/SEC/UWY donné
==============================================================================*/
int n_ChargerTABLEAU_TFAMCNA( char **ptb_InRecTFAMCNA, int CNA_POSITION_R, T_FAMCNA *TxFAMCNA )
{
	DEBUT_FONCTION("n_ChargerTABLEAU_TFAMCNA");

	TxFAMCNA->uwy_nf=atoi(ptb_InRecTFAMCNA[CNA_UWY_NF]);
	TxFAMCNA->acy_nf[TxFAMCNA->nb_taux]=atoi(ptb_InRecTFAMCNA[CNA_ACY_NF]);
	TxFAMCNA->tx[TxFAMCNA->nb_taux]=(double)atof(ptb_InRecTFAMCNA[CNA_POSITION_R]);
	TxFAMCNA->nb_taux++;

	return(0);
}

/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier GT.
retour: OK
==============================================================================*/
int n_InitLIFEST_I2(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FONCTION("n_InitLIFEST_I2");

	memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

	if ( n_OpenFileAppl ("ESTC2148_I2","rt",&(pbd_Rupt->pf_InputFil)))
		ExitPgm ( ERR_XX , "" );

	pbd_Rupt->n_NbRupture = 2;

	// fonction du test de la ligne du maitre avec l'esclave
	pbd_Rupt->ConditionEndSync      = n_ConditionSyncPERIMETRE_LIFEST;
	pbd_Rupt->n_ActionLigne         = n_ActionLigneLIFEST_I2 ;
	// Rupture CONTRAT/SECTION/UWY
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRupture_LIFEST_I2_0;
	pbd_Rupt->n_ActionFirst[0]      = n_ActionRuptureFirst_LIFEST_I2_0;
	// Rupture CONTRAT/SECTION/UWY/ACY
	pbd_Rupt->n_ConditionRupture[1] = n_ConditionRupture_LIFEST_I2;
	pbd_Rupt->n_ActionFirst[1]      = n_ActionRuptureFirst_LIFEST_I2;
	pbd_Rupt->n_ActionLast[1]       = n_ActionRuptureLast_LIFEST_I2;

	pbd_Rupt->c_Separ               = '~' ;

	RETURN_VAL(OK);
}

/*==============================================================================
objet : fonction de test de synchro
retour: 0       ---> ptb_InRecPERIM = pbd_InRecGT    ( egalite de rubriques a synchroniser)
> 0     ---> ptb_InRecPERIM > pbd_InRecGT
< 0     ---> ptb_InRecPERIM < pbd_InRecGT
==============================================================================*/
int n_ConditionSyncPERIMETRE_LIFEST( char **ptb_InRecPERIM, char **ptb_InRecLIFEST_I2 )
{
	int ret=0;
	DEBUT_FONCTION("n_ConditionSyncPERIMETRE_LIFEST");

	if( (ret = strcmp(ptb_InRecPERIM[PER_CTR_NF],   ptb_InRecLIFEST_I2[PRE_CTR_NF])     )   != 0 )
		RETURN_VAL(ret);
	if( (ret = atoi(ptb_InRecPERIM[PER_SEC_NF]) -   atoi(ptb_InRecLIFEST_I2[PRE_SEC_NF]))   != 0 )
		RETURN_VAL(ret);

	RETURN_VAL(0);
}

/*=============================================================================
objet : fonction de detection de rupture sur CONTRAT/SECTION/ACY/UWY
retour: 0 ===> pas de rupture
1 ===> rupture
=============================================================================*/
int n_ConditionRupture_LIFEST_I2(char **pbd_InRecPREC, char **pbd_InRecCUR)
{
	int ret=0;

	DEBUT_FONCTION("n_ConditionRupture_LIFEST_I2");

	if( (ret = strcmp(pbd_InRecPREC[PRE_CTR_NF],   pbd_InRecCUR[PRE_CTR_NF])     )   != 0 )
		RETURN_VAL(ret);
	if( (ret = atoi(pbd_InRecPREC[PRE_SEC_NF]) -   atoi(pbd_InRecCUR[PRE_SEC_NF]))   != 0 )
		RETURN_VAL(ret);
	if( (ret = atoi(pbd_InRecPREC[PRE_UWY_NF]) -   atoi(pbd_InRecCUR[PRE_UWY_NF]))   != 0 )
		RETURN_VAL(ret);
	if( (ret = atoi(pbd_InRecPREC[PRE_ACY_NF]) -   atoi(pbd_InRecCUR[PRE_ACY_NF]))   != 0 )
		RETURN_VAL(ret);
	if( (ret = atoi(pbd_InRecPREC[PRE_ESTMTH_NF]) -   atoi(pbd_InRecCUR[PRE_ESTMTH_NF]))   != 0 ) // [008]
		RETURN_VAL(ret);

	return (0);
}

/*=============================================================================
objet : fonction de detection de rupture sur CONTRAT/SECTION/UWY
retour: 0 ===> pas de rupture
1 ===> rupture
=============================================================================*/
int n_ConditionRupture_LIFEST_I2_0(char **pbd_InRecPREC, char **pbd_InRecCUR)
{
	int ret=0;

	DEBUT_FONCTION("n_ConditionRupture_LIFEST_I2_0");

	if( (ret = strcmp(pbd_InRecPREC[PRE_CTR_NF],   pbd_InRecCUR[PRE_CTR_NF])     )   != 0 )
		RETURN_VAL(ret);
	if( (ret = atoi(pbd_InRecPREC[PRE_SEC_NF]) -   atoi(pbd_InRecCUR[PRE_SEC_NF]))   != 0 )
		RETURN_VAL(ret);
	if( (ret = atoi(pbd_InRecPREC[PRE_UWY_NF]) -   atoi(pbd_InRecCUR[PRE_UWY_NF]))   != 0 )
		RETURN_VAL(ret);

	return (0);
}

/*=============================================================================
objet : fonction lancee en rupture premiere sur CONTRAT/SECTION/UWY
retour: OK
=============================================================================*/
int n_ActionRuptureFirst_LIFEST_I2_0(char **ptb_InRecPERIM, char **ptb_InRecLIFEST_I2)
{
	int AT=0;

	DEBUT_FONCTION("n_ActionRuptureFirst_LIFEST_I2_0");

	// On ne calcule les CNA que pour les contrats non automatiques (A ou E) en CNA AUTO
	if( ptb_InRecPERIM[PER_ESTCRB_CT][0] == 'A' || ptb_InRecPERIM[PER_ESTCRB_CT][0] == 'E' || RechercheCNATYP(ptb_InRecLIFEST_I2) != 5 ) // [007]
		RETURN_VAL(OK);

	// Type Comptable
	AT=atoi(ptb_InRecPERIM[PER_ACCADMTYP_CT]);

	ACCEPTouRETRO=RETRO;
	if ( ptb_InRecLIFEST_I2[PRE_ACMTRS_NT][0]=='1'  || ptb_InRecLIFEST_I2[PRE_ACMTRS_NT][0]=='3' ) 
		ACCEPTouRETRO=ACCEPT; // a faire evoluer Abir
	else
		ACCEPTouRETRO=RETRO;	

	if(AT!=1 || ( AT==1 && atoi(ptb_InRecLIFEST_I2[PRE_UWY_NF]) != atoi(ptb_InRecLIFEST_I2[PRE_ACY_NF])) )
	{
		*SDAC_prec[ACCEPTouRETRO]=0.0;
		*SDAC_cur [ACCEPTouRETRO]=0.0;

		*IDAC_prec[ACCEPTouRETRO]=0.0;
		*IDAC_cur [ACCEPTouRETRO]=0.0;
	}

	return(OK);
}



/*=============================================================================
objet : fonction lancee en rupture premiere sur CONTRAT/SECTION/UWY/ACY
retour: OK
=============================================================================*/
int n_ActionRuptureFirst_LIFEST_I2(char **ptb_InRecPERIM, char **ptb_InRecLIFEST_I2)
{
	double *tmp_DAC[2];
	int AT=0;

	DEBUT_FONCTION("n_ActionRuptureFirst_LIFEST_I2");

	// On ne calcule les CNA que pour les contrats non automatiques (A ou E) en CNA AUTO
	if( ptb_InRecPERIM[PER_ESTCRB_CT][0] == 'A' || ptb_InRecPERIM[PER_ESTCRB_CT][0] == 'E' || RechercheCNATYP(ptb_InRecLIFEST_I2) != 5 ) // [007]
		RETURN_VAL(OK);

	// Type Comptable
	AT=atoi(ptb_InRecPERIM[PER_ACCADMTYP_CT]);

	if(AT!=1 || ( AT==1 && atoi(ptb_InRecLIFEST_I2[PRE_UWY_NF]) == atoi(ptb_InRecLIFEST_I2[PRE_ACY_NF])) )
	{
		tmp_DAC[ACCEPTouRETRO]=SDAC_prec[ACCEPTouRETRO];        // je sauvegarde l'adresse du SDAC de l'année de compte précédente dans tmpDAC
		SDAC_prec[ACCEPTouRETRO]=SDAC_cur[ACCEPTouRETRO];       // Réaffecte l'adresse du SDAC précédent
		SDAC_cur[ACCEPTouRETRO]=tmp_DAC[ACCEPTouRETRO];         // le switch des adresses courantes et précédentes est terminé
		*SDAC_cur[ACCEPTouRETRO]=0.0;                           // je peux réinitialiser le SDAC courant

		tmp_DAC[ACCEPTouRETRO]=IDAC_prec[ACCEPTouRETRO];        // je sauvegarde l'adresse du IDAC de l'année de compte précédente dans tmpDAC
		IDAC_prec[ACCEPTouRETRO]=IDAC_cur[ACCEPTouRETRO];       // Réaffecte l'adresse du IDAC précédent
		IDAC_cur[ACCEPTouRETRO]=tmp_DAC[ACCEPTouRETRO];         // le switch des adresses courantes et précédentes est terminé
		*IDAC_cur[ACCEPTouRETRO]=0.0;                           // je peux réinitialiser le SDAC courant

		WP[ACCEPTouRETRO]=0.0;
		PC[ACCEPTouRETRO]=0.0;
	}
	TFR=0.0;

	return(OK);
}



/*==============================================================================
objet : fonction lancee pour chaque ligne du fichier LIFEST
( qui synchronise avec le périmetre )
retour: OK ---> traitement correctement effectue
ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneLIFEST_I2( char **ptb_InRecPERIM, char **ptb_InRecLIFEST_I2 )
{
	int AT=0;

	DEBUT_FONCTION("n_ActionLigneLIFEST_I2");

	// On ne calcule les CNA que pour les contrats non automatiques (A ou E) en CNA AUTO
	if( ptb_InRecPERIM[PER_ESTCRB_CT][0] == 'A' || ptb_InRecPERIM[PER_ESTCRB_CT][0] == 'E' || RechercheCNATYP(ptb_InRecLIFEST_I2) != 5 ) // [007]
		RETURN_VAL(OK);

	// -----------
	// ACCEPTATION

	// Type Comptable
	AT=atoi(ptb_InRecPERIM[PER_ACCADMTYP_CT]);

	if(AT!=1 || ( AT==1 && atoi(ptb_InRecLIFEST_I2[PRE_UWY_NF]) == atoi(ptb_InRecLIFEST_I2[PRE_ACY_NF])) )
	{
		// si poste SDAC ( 1183 )
		if( atoi(ptb_InRecLIFEST_I2[PRE_ACMTRS_NT]) == SDAC_ACMTRS[ACCEPT] )
		{
			//on cumule tous les DAC de l'année de compte
			*(SDAC_cur[ACCEPT])+=atof(ptb_InRecLIFEST_I2[PRE_ESTMNT_M]);
		}

			// si poste IDAC ( 1193 )
		if( atoi(ptb_InRecLIFEST_I2[PRE_ACMTRS_NT]) == IDAC_ACMTRS[ACCEPT] )
		{
			//on cumule tous les DAC de l'année de compte
			*(IDAC_cur[ACCEPT])+=atof(ptb_InRecLIFEST_I2[PRE_ESTMNT_M]);
		}

		// si poste prime ( 1010 )
		if( strcmp(ptb_InRecLIFEST_I2[PRE_ACMTRS_NT], "1010" ) == 0 )
		{
			//on cumule les PRIMES sur l'année de compte en cours
			WP[ACCEPT]+=atof(ptb_InRecLIFEST_I2[PRE_ESTMNT_M]);
		}

		// si poste PC ( 1160 )
		if( strcmp(ptb_InRecLIFEST_I2[PRE_ACMTRS_NT], PC_ACCEPT ) == 0 )
		{
			//on cumule les PRIMES sur l'année de compte en cours
			PC[ACCEPT]+=atof(ptb_InRecLIFEST_I2[PRE_ESTMNT_M]);
		}

		// ------------
		// RETROCESSION

		// si poste SDAC ( 2183 )
		if( atoi(ptb_InRecLIFEST_I2[PRE_ACMTRS_NT]) == SDAC_ACMTRS[RETRO] )
		{
			//on cumule tous les DAC de l'année de compte
			(*SDAC_cur[RETRO])+=atof(ptb_InRecLIFEST_I2[PRE_ESTMNT_M]);
		}

		// si poste IDAC ( 2193 )
		if( atoi(ptb_InRecLIFEST_I2[PRE_ACMTRS_NT]) == IDAC_ACMTRS[RETRO] )
		{
			//on cumule tous les DAC de l'année de compte
			*(IDAC_cur[RETRO])+=atof(ptb_InRecLIFEST_I2[PRE_ESTMNT_M]);
		}

		// si poste prime ( 2010 )
		if( strcmp(ptb_InRecLIFEST_I2[PRE_ACMTRS_NT], "2010" ) == 0 )
		{
			//on cumule les PRIMES sur l'année de compte en cours
			WP[RETRO]+=atof(ptb_InRecLIFEST_I2[PRE_ESTMNT_M]);
		}

		// si poste PC ( 2160 )
		if( strcmp(ptb_InRecLIFEST_I2[PRE_ACMTRS_NT], PC_RETRO ) == 0 )
		{
			//on cumule les PRIMES sur l'année de compte en cours
			PC[RETRO]+=atof(ptb_InRecLIFEST_I2[PRE_ESTMNT_M]);
		}

		// si on est sur une ligne Resultat Technique:
		if( n_isPOSTE_ACCPAR(ptb_InRecLIFEST_I2[PRE_ACMTRS_NT], &RESTEC ) )
		{
			// TFR = Résultat technique de l'année de compte.
			// on cumule le Résultat technique sur l'année de compte en cours
			TFR+=atof(ptb_InRecLIFEST_I2[PRE_ESTMNT_M]);
		}
	}

	RETURN_VAL(OK);
}



/*=============================================================================
objet : fonction lancee en rupture derniere sur CONTRAT/SECTION/ACY/ESTMTH/UWY
retour: OK
=============================================================================*/
int n_ActionRuptureLast_LIFEST_I2(char **ptb_InRecPERIM, char **ptb_InRecLIFEST_I2)
{
	int cur_UWY_NF=0;
	int cur_ACY_NF=0;
	int libUWY_NF=0;
	int libACY_NF=0;
	int UWY_debut=0;
	int UWY_fin=0;
	int ACY_debut=0;
	int AT=0;							// Type comptable
	int A=0;							// Premiere annee en estimation -1
	int T=0;							// T = Dernier exercice = Annee bilan + 2
	int LAC=0;							// Dernier annee de compte avec compte complet
	int FUY=0;							// First UWY (exercice)
	int LUY=0;							// Last UWY (exercice)
	double d_INT=0;
	double d_AE=0;
	double d_IDAC=0;
	static int premier=0;
	char sz_DAC_DETTRS[9]="";
	char sz_DAC_DETTRS_LIB[9]="";		// V101
	char sz_DAC_DETTRNCOD_LIB[6]="";
	char sz_trav1[2]="";				// V101
	int d_trav1=0;
	int d_trn=0;						// V101
	char sz_IDAC[50];
	char sz_libUWY_NF[50];
	char sz_libACY_NF[50];
	char sz_Oricod_ls[11]="";
	char sz_DBO[4]="";
	char sz_gap[2]="";
	char* psz_ligne[PRE_NBCOL+1];
	int j =0;


	for (j=0;j<PRE_NBCOL;j++)
	{
		psz_ligne[j]=(char*) malloc( sizeof(char)*25 );
		sprintf(psz_ligne[j],"%s"," ");
		sprintf(psz_ligne[j],"%s",ptb_InRecLIFEST_I2[j]);
	}
	psz_ligne[PRE_NBCOL]=0;

	DEBUT_FONCTION("n_ActionRuptureLast_LIFEST_I2");

	// On ne calcule les CNA que pour les contrats non automatiques (A ou E) en CNA AUTO
	if( ptb_InRecPERIM[PER_ESTCRB_CT][0] == 'A' || ptb_InRecPERIM[PER_ESTCRB_CT][0] == 'E' || RechercheCNATYP(ptb_InRecLIFEST_I2) != 5 ) // [007]
		RETURN_VAL(OK);

	// Resilie ou non
	Resilie=n_isRESILIE(ptb_InRecLIFEST_I2);

	// Type Comptable
	AT=atoi(ptb_InRecPERIM[PER_ACCADMTYP_CT]);

	// A = Premiere annee en estimation -1          ( = Annee Bilan - 5 )
	A=atoi(ptb_InRecLIFEST_I2[PRE_BALSHEY_NF])-5;

	// T = Derniere annee de compte en estimation   ( = Annee Bilan + 2 )
	T=atoi(ptb_InRecLIFEST_I2[PRE_BALSHEY_NF])+LIF_ACY_MAX ; // modified by abir

	// LAC = Dernier annee de compte avec compte complet
	LAC=n_ACY_DernierCompteComplet(ptb_InRecLIFEST_I2[PRE_CTR_NF]);

	// FUY = Premier Exercice
	FUY=UWY_NF_premier;

	// LUY = Dernier Exercice
	LUY=UWY_NF_dernier;

	cur_UWY_NF=atoi(ptb_InRecLIFEST_I2[PRE_UWY_NF]);
	cur_ACY_NF=atoi(ptb_InRecLIFEST_I2[PRE_ACY_NF]);

	// exercice et annee de compte de liberation
	if(cur_ACY_NF<T)
	{
		libUWY_NF = cur_UWY_NF + i_LiberationExeP1(IDAC_ACMTRS_LIB[ACCEPTouRETRO],AT); //[003]
		libACY_NF = cur_ACY_NF+1;
	}

	switch ( AT )
	{
		case 1:
			// on est forcement sur du : non resilie
			ACY_debut=max( A, LAC==0 ? FUY : LAC+1 );
			UWY_debut=ACY_debut;

			if(cur_UWY_NF==cur_ACY_NF)
				UWY_fin=cur_ACY_NF;
			break;
		case 4:
			// on est forcement sur du : resilie
			ACY_debut=max( A, (LAC+1>LUY) ? LAC+1 : LUY );
			UWY_debut=LUY;

			if(cur_UWY_NF==UWY_debut)
				UWY_fin=LUY;
			break;
		case 2:
			// on est sur du : resilie
			if(Resilie)
			{
				ACY_debut=max( A, (LAC+1>LUY) ? LAC+1 : LUY );

				// Exercice commence a FUY jusqu'a LUY ( tant qu'il ne depasse pas l'annee de compte en cours )
				UWY_debut=FUY;
				UWY_fin=cur_ACY_NF;
			}
			// on est sur du : non résilié
			else
			{
				ACY_debut=max( A, ( (LAC==0) ? FUY : LAC+1 ) ); //[002]

				// Exercice commence à FUY jusqu'à T ( tant qu'il ne dépasse pas l'année de compte en cours )
				UWY_debut=FUY;
				UWY_fin=cur_ACY_NF;
			}
			break;
	}
	// si l'annee de compte en cours est plus grand que le dernier compte complet ( ou U si pas de compte complet )
	if(cur_UWY_NF >= UWY_debut  && cur_UWY_NF <= UWY_fin)
	{
		if(cur_ACY_NF >= ACY_debut	&& cur_ACY_NF <= T)
		{
			d_AE  = n_TauxFamcna(AE,  nb_UWY_TFAMCNA_AE,  cur_UWY_NF, cur_ACY_NF);
			d_INT = n_TauxFamcna(INT, nb_UWY_TFAMCNA_INT, cur_UWY_NF, cur_ACY_NF);

			// On teste s'il y a un "Profit commission"
			if(PC[ACCEPTouRETRO] == 0.0)
			{
				*IDAC_cur[ACCEPTouRETRO]=( (*IDAC_prec[ACCEPTouRETRO] + *SDAC_prec[ACCEPTouRETRO])  * (1.0 + d_INT) ) +
				(d_AE * WP[ACCEPTouRETRO]) -
				TFR -
				*SDAC_cur[ACCEPTouRETRO];
			}
			else
			{
				*IDAC_cur[ACCEPTouRETRO]=-*SDAC_cur[ACCEPTouRETRO];
			}

			// On teste la LOB pour afficher le bon poste DETTRS
			if(atoi(ptb_InRecLIFEST_I2[PRE_LOB_CF]) == 30)
			{
				sprintf(sz_DAC_DETTRS, "%d%s", ACCEPTouRETRO==ACCEPT?3:4, sz_DETTRS[ACCEPTouRETRO]); 
			}
			if(atoi(ptb_InRecLIFEST_I2[PRE_LOB_CF]) == 31)
			{
				sprintf(sz_DAC_DETTRS, "%d%s", ACCEPTouRETRO==ACCEPT?1:2, sz_DETTRS[ACCEPTouRETRO]);
			}
			sz_DAC_DETTRS[8]=0;	
			// On genere la liberation cna conso  - V101
			strncpy(&(sz_trav1[0]),&(sz_DETTRS[0][3]),1);
			sz_trav1[1]='\0';
			d_trav1=atoi(sz_trav1)+1;
			sprintf(sz_trav1, "%d", d_trav1);
			strncpy(&(sz_DAC_DETTRS_LIB[0]),&(sz_DAC_DETTRS[0]),1);
			strncpy(&(sz_DAC_DETTRS_LIB[1]),&(sz_DETTRS[0][0]),3);
			strncpy(&(sz_DAC_DETTRS_LIB[4]),&(sz_trav1[0]),1);
			strncpy(&(sz_DAC_DETTRS_LIB[5]),&(sz_DETTRS[0][4]),3);
			sz_DAC_DETTRS_LIB[8]=0;

			//    printf("sz_DAC_DETTRS_LIB = %s\n", sz_DAC_DETTRS_LIB);

			d_IDAC=*IDAC_cur[ACCEPTouRETRO];
			if(ACCEPTouRETRO==RETRO)
			{
				d_IDAC=-(*IDAC_cur[ACCEPTouRETRO]);
			}
			d_trn = atoi(sz_DETTRNCOD[ACCEPTouRETRO]);

			d_trn  = 100+ d_trn ;
			sprintf(sz_DAC_DETTRNCOD_LIB, "%d", d_trn);

			sz_DAC_DETTRNCOD_LIB[5]=0;    
			sprintf(sz_Oricod_ls,"%s","CNA AUTO 5");
			sz_Oricod_ls[10]=0;
			sprintf(sz_DBO,"%s","DBO");
			sz_DBO[3]=0;

			sprintf(psz_ligne[PRE_ORICOD_LS],"%s","");
			sprintf(psz_ligne[PRE_CREUSR_CF],"%s","");

			sprintf(psz_ligne[PRE_UWY_NF],"%d",cur_UWY_NF);
			sprintf(psz_ligne[PRE_ACY_NF],"%d",cur_ACY_NF);

			//	strcpy(ptb_InRecLIFEST_I2[PRE_CRE_D],strcat(Ksz_DateJour," 23:59:50")); // Ajout 03012014
			sprintf(Ksz_DateJour_Mod,"%s%s",Ksz_DateJour," 23:59:50");
			Ksz_DateJour_Mod[18]=0;
			strcpy(psz_ligne[PRE_CRE_D],Ksz_DateJour_Mod);

			//strcpy(psz_ligne[PRE_BATCH_B],sz_batch); // Ajout 08/01/2014 pour prise en compte nouveau champ PRE_BATCH_B dans la structure LIFEST
			sprintf(psz_ligne[PRE_BATCH_B],"%s","1");
			//strcpy(psz_ligne[PRE_BALSHEY_NF],Ksz_AnneeBilan);
			sprintf(psz_ligne[PRE_BALSHEY_NF],"%s",Ksz_AnneeBilan);
			//strcpy(psz_ligne[PRE_BALSHTMTH_NF],Ksz_MoisBilan);
			sprintf(psz_ligne[PRE_BALSHTMTH_NF],"%s",Ksz_MoisBilan);
			memset(sz_IDAC,0, sizeof (sz_IDAC));
			sprintf(sz_IDAC,"%15.3lf",d_IDAC);
			sprintf(psz_ligne[PRE_ESTMNT_M],"%s",sz_IDAC);

			sprintf(sz_gap,"%s","2");
			sz_gap[1]=0;
			sprintf(psz_ligne[PRE_GAAP_NF],"%s",sz_gap);


			//strcpy(psz_ligne[PRE_ADJCOD_CT],sz_ADJCOD[ACCEPTouRETRO]);
			sprintf(psz_ligne[PRE_ADJCOD_CT],"%s",sz_ADJCOD[ACCEPTouRETRO]);
			//strcpy(psz_ligne[PRE_RETCOD_CT],sz_RETCOD[ACCEPTouRETRO]);
			sprintf(psz_ligne[PRE_RETCOD_CT],"%s",sz_RETCOD[ACCEPTouRETRO]);
			sprintf(psz_ligne[PRE_ACMTRS_NT],"%d",IDAC_ACMTRS[ACCEPTouRETRO]);
			//

			//strcpy(psz_ligne[PRE_DETTRNCOD_CF],sz_DETTRNCOD[ACCEPTouRETRO]);
			sprintf(psz_ligne[PRE_DETTRNCOD_CF],"%s",sz_DETTRNCOD[ACCEPTouRETRO]); //[005]
			//strcpy(psz_ligne[PRE_ACCRET_B],sz_ADJSIG[ACCEPTouRETRO]);
			sprintf(psz_ligne[PRE_ACCRET_B],"%s",sz_ADJSIG[ACCEPTouRETRO]);
			sprintf(psz_ligne[PRE_ORICOD_LS],"%s",sz_Oricod_ls);
			sprintf(psz_ligne[PRE_CREUSR_CF],"%s",sz_DBO); 
			sprintf(psz_ligne[PRE_LSTUPD_D],"%s",Ksz_DateJour_Mod);
			sprintf(psz_ligne[PRE_LSTUPDUSR_CF],"%s",sz_DBO);
			//strcpy(psz_ligne[PRE_CNATYP_CT],ptb_InRecPERIM[PER_CNATYP_CT]);
			sprintf(psz_ligne[PRE_CNATYP_CT],"%s",ptb_InRecPERIM[PER_CNATYP_CT]);
			sprintf(psz_ligne[PRE_DETTRS_CF],"%s",sz_DAC_DETTRS); 
			psz_ligne[PRE_NBCOL]=0;

			n_WriteCols(Fichier_O1,psz_ligne, '~', 0); // Ajout 03012014

			// Liberation
			if(libACY_NF!=0)
			{
				sprintf(sz_libUWY_NF,"%d",libUWY_NF); // Ajout 03012014
				strcpy(psz_ligne[PRE_UWY_NF],sz_libUWY_NF);
				sprintf(sz_libACY_NF,"%d",libACY_NF);
				strcpy(psz_ligne[PRE_ACY_NF],sz_libACY_NF);
				sprintf(Ksz_DateJour_Mod,"%s%s",Ksz_DateJour," 23:59:50");
				Ksz_DateJour_Mod[18]=0;
				sprintf(psz_ligne[PRE_CRE_D],"%s",Ksz_DateJour_Mod);
				sprintf(sz_gap,"%s","2");
				sz_gap[1]=0;
				sprintf(psz_ligne[PRE_GAAP_NF],"%s",sz_gap); 
				sprintf(psz_ligne[PRE_ACMTRS_NT],"%d",IDAC_ACMTRS_LIB[ACCEPTouRETRO]);
				//strcpy(psz_ligne[PRE_BATCH_B],sz_batch); // Ajout 08/01/2014 pour prise en compte nouveau champ PRE_BATCH_B dans la structure LIFEST
				sprintf(psz_ligne[PRE_BATCH_B],"%s","1");
				sprintf(psz_ligne[PRE_BALSHEY_NF],"%s",Ksz_AnneeBilan);
				sprintf(psz_ligne[PRE_BALSHTMTH_NF],"%s",Ksz_MoisBilan);
				memset(sz_IDAC,0,sizeof(sz_IDAC));
				sprintf(sz_IDAC,"%15.3lf",-d_IDAC);
				sprintf(psz_ligne[PRE_ESTMNT_M],"%s",sz_IDAC);
				//strcpy(psz_ligne[PRE_ADJCOD_CT],sz_ADJCOD[ACCEPTouRETRO]);
				sprintf(psz_ligne[PRE_ADJCOD_CT],"%s",sz_ADJCOD[ACCEPTouRETRO]);
				//strcpy(psz_ligne[PRE_RETCOD_CT],sz_RETCOD[ACCEPTouRETRO]);
				sprintf(psz_ligne[PRE_RETCOD_CT],"%s",sz_RETCOD[ACCEPTouRETRO]);
				sprintf(psz_ligne[PRE_DETTRS_CF],"%s",sz_DAC_DETTRS_LIB);

				//abir
				sprintf(psz_ligne[PRE_DETTRNCOD_CF],"%s",sz_DAC_DETTRNCOD_LIB);
				//strcpy(psz_ligne[PRE_ACCRET_B],sz_ADJSIG[ACCEPTouRETRO]);
				sprintf(psz_ligne[PRE_ACCRET_B],"%s",sz_ADJSIG[ACCEPTouRETRO]);
				sprintf(psz_ligne[PRE_ORICOD_LS],"%s",sz_Oricod_ls);
				sprintf(psz_ligne[PRE_CREUSR_CF],"%s",sz_DBO);
				sprintf(psz_ligne[PRE_LSTUPD_D],"%s",Ksz_DateJour_Mod);
				sprintf(psz_ligne[PRE_LSTUPDUSR_CF],"%s",sz_DBO); 
				//strcpy(psz_ligne[PRE_CNATYP_CT],ptb_InRecPERIM[PER_CNATYP_CT]);
				sprintf(psz_ligne[PRE_CNATYP_CT],"%s",ptb_InRecPERIM[PER_CNATYP_CT]);

				psz_ligne[PRE_NBCOL]=0;

				n_WriteCols(Fichier_O1,psz_ligne, '~', 0); // Ajout 03012014
			}

			if(premier==0)
			{
				premier=1;
				fprintf(Fichier_O2, "CTR~SEC~UWY~BALSHEY~BALMTH~ACY_NF~ACMTRS~ACCADMTYP~IDAC_cur~IDAC_prec~SDAC_prec~INT~AE~WP~TFR~SDAC_cur~Resilie~AT~A~T~LAC~FUY~LUY~LOB~TRNCOD~PROFIT_COM\n");
			}

			//                    0  1  2  3  4  5  6  7 8   9    10  11  12  13  14  15 16 17 18 19 20 21 22 23    24   25
			fprintf(Fichier_O2, "%s~%s~%s~%s~%s~%s~%d~%s~%15.3lf~%lf~%lf~%lf~%lf~%lf~%lf~%lf~%d~%d~%d~%d~%d~%d~%d~%s~%s~%15.3lf\n",
						ptb_InRecLIFEST_I2[PRE_CTR_NF],             //  0
						ptb_InRecLIFEST_I2[PRE_SEC_NF],             //  1
						ptb_InRecLIFEST_I2[PRE_UWY_NF],             //  2
						Ksz_AnneeBilan,                             //  3 BALSHEY_NF
						Ksz_MoisBilan,                              //  4 BALSHTMTH_NF
						ptb_InRecLIFEST_I2[PRE_ACY_NF],             //  5 ACY_NF
						IDAC_ACMTRS[ACCEPTouRETRO],                 //  6
						ptb_InRecLIFEST_I2[PRE_ACCADMTYP_CT],       //  7
						d_IDAC,                                     //  8
						*IDAC_prec[ACCEPTouRETRO],                  //  9
						*SDAC_prec[ACCEPTouRETRO],                  // 10
						d_INT,                                      // 11
						d_AE,                                       // 12
						WP[ACCEPTouRETRO],                          // 13
						TFR,                                        // 14
						*SDAC_cur[ACCEPTouRETRO],                   // 15
						Resilie,                                    // 16
						AT,                                         // 17
						A,                                          // 18
						T,                                          // 19
						LAC,                                        // 20
						FUY,                                        // 21
						LUY,                                        // 22
						ptb_InRecLIFEST_I2[PRE_LOB_CF],             // 23
						sz_DAC_DETTRS,     
						//  ptb_InRecLIFEST_I2[PRE_DETTRNCOD_CF] ,                      // 24
						//   ptb_InRecLIFEST_I2[PRE_GAAP_NF],
						PC[ACCEPTouRETRO]);                         // 25 PROFIT_COMMISSION

			// Libération
			if(libACY_NF!=0)
			{
				//                    0  1  2  3  4  5  6  7       8   9  10  11  12  13  14  15 16 17 18 19 20 21 22 23 24      25
				fprintf(Fichier_O2, "%s~%s~%d~%s~%s~%d~%d~%s~%15.3lf~%lf~%lf~%lf~%lf~%lf~%lf~%lf~%d~%d~%d~%d~%d~%d~%d~%s~%s~%15.3lf\n",
							ptb_InRecLIFEST_I2[PRE_CTR_NF],             //  0
							ptb_InRecLIFEST_I2[PRE_SEC_NF],             //  1
							libUWY_NF,                                  //  2
							Ksz_AnneeBilan,                             //  3 BALSHEY_NF
							Ksz_MoisBilan,                              //  4 BALSHTMTH_NF
							libACY_NF,                                  //  5 ACY_NF
							IDAC_ACMTRS_LIB[ACCEPTouRETRO],             //  6
							ptb_InRecLIFEST_I2[PRE_ACCADMTYP_CT],       //  7
							-d_IDAC,                                    //  8
							*IDAC_prec[ACCEPTouRETRO],                  //  9
							*SDAC_prec[ACCEPTouRETRO],                  // 10
							d_INT,                                      // 11
							d_AE,                                       // 12
							WP[ACCEPTouRETRO],                          // 13
							TFR,                                        // 14
							*SDAC_cur[ACCEPTouRETRO],                   // 15
							Resilie,                                    // 16
							AT,                                         // 17
							A,                                          // 18
							T,                                          // 19
							LAC,                                        // 20
							FUY,                                        // 21
							LUY,                                        // 22
							ptb_InRecLIFEST_I2[PRE_LOB_CF],             // 23
							sz_DAC_DETTRS_LIB,
							//   ptb_InRecLIFEST_I2[PRE_DETTRNCOD_CF] ,                          // 24  -- V101
							//  ptb_InRecLIFEST_I2[PRE_GAAP_NF],
							PC[ACCEPTouRETRO]);                         // 25 PROFIT_COMMISSION
			}

		}
	}

	RETURN_VAL(OK);
}



/*=============================================================================
objet : retourne l'année de compte du dernier compte complet
Si pas trouvé, retourne U-1
=============================================================================*/
int n_ACY_DernierCompteComplet(char *CTR)
{
	int i;
	int n_acy=0;

	DEBUT_FONCTION("n_ACY_DernierCompteComplet");

	// Recherche du dernier compte complet
	// recherche dans le tableau des comptes complets le dernier pour le contrat/section.
	for(i=curs_TLIFDRI;i<nb_TLIFDRI;i++)
	{
		if(strcmp(CTR, Kbd_LifDri[i].CTR_NF) == 0)
		{
			if(n_acy<Kbd_LifDri[i].ACY_NF)
			{
				curs_TLIFDRI=i;
				n_acy=Kbd_LifDri[i].ACY_NF;
			}
		}

		if(strcmp(CTR, Kbd_LifDri[i].CTR_NF) < 0)
		{
			break;
		}
	}
	return n_acy;
}



/*=============================================================================
objet : Retour 1 si le poste est trouvé dans TACCPAR
=============================================================================*/
int n_isPOSTE_ACCPAR(char *ACMTRS, T_POSTE_ACCPAR *posteACCPAR )
{
	int isposte=0;
	int i=0;

	DEBUT_FONCTION("n_isPOSTE_ACCPAR");

	// On cherche si ACMTRS appartient à un ACMTRS de ACCPAR
	for(i=0;i<posteACCPAR->nb_acmtrs;i++)
	{
		if( strcmp(ACMTRS, posteACCPAR->acmtrs[i])== 0)
		{
			isposte=1;
		}
	}
	return isposte;
}

/*==============================================================================
objet:  Lit le fichier binaire LIFDRI et les met en memoire
==============================================================================*/
int n_ChargerTLIFDRI()
{
	int n_EOF = 0;
	T_LIFDRI_ALL bd_Lu;
	char MsgAno[300];

	DEBUT_FONCTION("n_ChargerTLIFDRI");


	memset(&bd_Lu,0,sizeof(bd_Lu));

	// Tant que la fin de fichier n'est pas atteinte,...
	while ( n_EOF == 0 )
	{
		// lecture d'une ligne dans le fichier.
		if ( fread( &bd_Lu, sizeof(T_LIFDRI_ALL), 1, FichierTLIFDRI_I5) !=1 )
			n_EOF = 1;  // Fin de fichier, mise a jour du flag
		else
		{
			// Ecriture dans log si depassement du tableau
			if ( nb_TLIFDRI  >= MAX_LIFDRI)
			{
				sprintf(MsgAno,"The number of Driving records  (/CTR %s /SEC %d /UWY %d) overflows the program's storage capacity",
							bd_Lu.CTR_NF,
							bd_Lu.SEC_NF,
							bd_Lu.UWY_NF);
				n_WriteAno(MsgAno);
				RETURN_VAL(0);
			}

			if ( (int)bd_Lu.COMACC_B == 1 )
			{
				// Enregistrement ecrit dans le tableau
				Kbd_LifDri[nb_TLIFDRI] = bd_Lu;
			}
			nb_TLIFDRI++;
		}
	}

	RETURN_VAL (0);
}




/*==============================================================================
objet : retourne le taux trouvé dans TFAMCNA

==============================================================================*/
double n_TauxFamcna(T_FAMCNA *TxFAMCNA, int nb_UWY_TFAMCNA, int cur_UWY_NF, int cur_ACY_NF)
{
	double tx=0.0;
	int trouve=1;
	int i = 0 ; /* Added for Phase1b Migration */	
	int j = 0;  /* Added for Phase1b Migration */
	DEBUT_FONCTION("n_TauxFamcna");

	// On parcourt tous les exercices de la table des taux du plus grand au plus petit
	for (i=nb_UWY_TFAMCNA-1 ; i>=0 ; i--)  /* Updated for Phase1b Migration */	 
	{
		// quand les exercices de la table des taux deviennent < à l'exercice courant
		if(TxFAMCNA[i].uwy_nf<=cur_UWY_NF)
		{
			//[002] On parcourt toutes les lignes de l'exercice du tableau (de l'année de compte la plus petite à la plus grande
			for (j=0 ; j < TxFAMCNA[i].nb_taux ; j++)  /* Updated for Phase1b Migration */	 
			{
				// toutes les années de compte de l'exercice sont déjà chargées en mémoire,
				//[002] si l'année de compte en cours est <= à celle de TFAMCNA ou c'est la dernière année de compte de TFAMCNA
				if(cur_ACY_NF<=TxFAMCNA[i].acy_nf[j] || j == TxFAMCNA[i].nb_taux - 1)
				{
					// Au premier taux trouvé : on l'enregistre
					tx=TxFAMCNA[i].tx[j];

					trouve=1;
					// et on sort
					break;
				}
			}
			if(trouve!=0)
				break;
		}
	}

	return tx;
}



/*==============================================================================
objet : retourne 1 si le CTR/SEC/UWY/UW/END/ACY est résilié
==============================================================================*/
int n_isRESILIE(char **ptb_InRecLIFEST_I2)
{
	int resil=0;
	int i = 0;  /* Added for Phase1b Migration */

	for(i=0; i<nbSECSTS_RESIL; i++)  /* Updated for Phase1b Migration */	 
	{
		if( strcmp(T_SECSTS_RESIL[i].CTR_NF, ptb_InRecLIFEST_I2[PRE_CTR_NF])    == 0    &&
			strcmp(T_SECSTS_RESIL[i].UWY_NF, ptb_InRecLIFEST_I2[PRE_UWY_NF])    == 0    &&
			strcmp(T_SECSTS_RESIL[i].UW_NT,  ptb_InRecLIFEST_I2[PRE_UW_NT] )    == 0    &&
			strcmp(T_SECSTS_RESIL[i].END_NT, ptb_InRecLIFEST_I2[PRE_END_NT])    == 0    &&
			strcmp(T_SECSTS_RESIL[i].SEC_NF, ptb_InRecLIFEST_I2[PRE_SEC_NF])    == 0    )
			resil=1;
	}

	return resil;
}



/*==============================================================================
objet : retourne le CNATYP du CTRONAT/SECTION/EXERCICE
==============================================================================*/
int RechercheCNATYP(char **ptb_InRecLIFEST_I2)
{
	int cnatyp=0;
	int i;

	for(i=0; i<nbCtrSecUwy; i++)
	{
		if( strcmp(ptb_InRecLIFEST_I2[PRE_CTR_NF], STR_CNATYP[i].CTR_NF )    == 0    &&
				atoi(ptb_InRecLIFEST_I2[PRE_SEC_NF]) == STR_CNATYP[i].SEC_NF             &&
				atoi(ptb_InRecLIFEST_I2[PRE_UWY_NF]) == STR_CNATYP[i].UWY_NF )
			cnatyp=STR_CNATYP[i].CNATYP;
	}

	return cnatyp;
}



/*==============================================================================
objet : Recherche si le poste appartient au code de regroupement
retour: 1   appartient
0   non
==============================================================================*/
void DEBUT_FONCTION(char *fonction)
{
	DEBUT_FCT(fonction);
}


