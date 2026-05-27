/*==============================================================================
nom de l'application          : Modification des calculs de commission
nom du source                 : ESTC1012.c
revision                      : $Revision:   1.0  $
date de creation              : 11/02/2016
auteur                        : Dch 
references des specifications : EST08c3

------------------------------------------------------------------------------

historique des modifications :
 ID 	<jj/mm/aaaa>	<auteur>	<description de la modification>
[01]	 16/02/2016		-=Dch=- 	 :spot:30167
[02]	 15/11/2016		  PGA		 Refonte programe pour Spira 50815, 47946, 47759
[03]	 11/01/2017		  PGA		 SPIRA:58601 ajout pericase pour obtenir le parametrage par défaut des contrat sans ligne.
[04]	 23/01/2017		  PGA		 SPIRA:58601 on considaire qu'une ligne n'existe pas si son montant est compris entre -1 et 1 exclu
[05]     11/05/2018    M.NAJI                    SPIRA:61503  Calculation of Taxes (using a new "Based On" field added on TRT)
[06]   11/12/2018   Spira:73841; Ecart INT/IN2 sur les postes 11312102 et 11312106 [IN:073841]  
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <estserv.h>
#include "struct.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

typedef struct {
		double 	Montant_EPP;
		double 	Montant_RPP;
		double 	Comm_EPP;
		double 	Comm_RPP; 
		double 	Taxes_EPP;   //[05]
		double 	Taxes_RPP;   //[05]
		char	Devise[4];
} t_sortie;

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

#define MNT_EPP 0b00001000
#define COM_EPP 0b00000100
#define MNT_RPP 0b00000010
#define COM_RPP 0b00000001

#define TAX_EPP  0b00100000   //[05]
#define TAX_RPP  0b01000000   //[05]

/*----------------------*/
/* variables de travail */
/*----------------------*/


FILE            	*Kp_InCur;			/* pointeur sur les taux devise */     
FILE            	*Kp_OutFile;		/* pointeur sur les dernieres comm en sortie */

T_RUPTURE_VAR    	bd_RuptGT;             /* gestion rupture sur les comm */
T_RUPTURE_SYNC_VAR  bd_SyncPericase;       /* gestion Syncro entre Gt et Pericase */

char 				sentinel;
t_sortie 			cols_sortie;

/*------------------------*/
/* Prototype des fonction */
/*------------------------*/

int n_InitGT(T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1GT(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLigneGT(char **pbd_InRec_Cur);
int n_ActionLigneFirst(char **pbd_InRec_Cur);
int n_ActionLigneLast(char **pbd_InRec_Cur);

int n_InitPericase(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ConditionSyncPericase(char **pbd_InRecGT, char **pbd_InRecPericase);
int n_PericaseSansGT(char **pbd_InRecPericase);


int d_getMnt(char masque, char **ligneGT);


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
        /* Initialisation des signaux */
        InitSig();

		memset(&cols_sortie , 0, sizeof(t_sortie));

        if (n_BeginPgm(argc  ,argv) == ERR)
                ExitPgm(ERR_XX , "ERROR à la récupération des paramètre");

        /* Ouverture des fichiers */
        if (n_OpenFileAppl("ESTC1012_I3","rt",&Kp_InCur) == ERR)
                ExitPgm(ERR_XX , "ESTC1012_I3 can't be open");

        if (n_OpenFileAppl("ESTC1012_O1","wt",&Kp_OutFile) == ERR)
                ExitPgm(ERR_XX , "ESTC1012_O1 can't be open");

        /* Initialisation de la varible bd_RuptGT */
        if (n_InitGT(&bd_RuptGT))
                ExitPgm(ERR_XX , "bd_RuptGT initialisation failed");

		if (n_InitPericase(&bd_SyncPericase))
                ExitPgm(ERR_XX , "bd_SyncPericase initialisation failed");

        /* Lancement du traitement du fichier */
        if (n_ProcessingRuptureVar(&bd_RuptGT) == ERR)
                ExitPgm(ERR_XX , "");

        /* Fermeture fichier */
        if (n_CloseFileAppl("ESTC1012_I1",&(bd_RuptGT.pf_InputFil)) == ERR)
                ExitPgm(ERR_XX , "ESTC1012_I1 can't be close");

        if (n_CloseFileAppl("ESTC1012_I2",&(bd_SyncPericase.pf_InputFil)) == ERR)
                ExitPgm(ERR_XX , "ESTC1012_I2 can't be close");

        if (n_CloseFileAppl("ESTC1012_I3",&Kp_InCur) == ERR)
                ExitPgm(ERR_XX , "ESTC1012_I3 can't be close");

        if (n_CloseFileAppl("ESTC1012_O1",&Kp_OutFile) == ERR)
                ExitPgm(ERR_XX , "ESTC1012_O1 can't be close");

        if (n_EndPgm() == ERR)
                ExitPgm(ERR_XX , "ERROR en sortie de programme");
 
        exit(0);
}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du 
        fichier maitre.
retour :
        0
==============================================================================*/
int n_InitGT(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitGT");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if (n_OpenFileAppl("ESTC1012_I1","rt",&(pbd_Rupt->pf_InputFil)))
                RETURN_VAL(ERR);

        pbd_Rupt->n_NbRupture 			= 1;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1GT;
        pbd_Rupt->n_ActionFirst[0] 		= n_ActionLigneFirst;
        pbd_Rupt->n_ActionLast[0] 		= n_ActionLigneLast;

        pbd_Rupt->n_ActionLigne 		= n_ActionLigneGT;

        pbd_Rupt->c_Separ				= '~';

        RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction de test de rupture niveau 1 sur
                Contrat/Section/Exercice

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1GT(char **ptb_InRec,char **ptb_InRec_Cur)
{
	int ret = 0;

    DEBUT_FCT("n_IsR1GT");
	
	if ((ret = strcmp(ptb_InRec[GT_CTR_NF], ptb_InRec_Cur[GT_CTR_NF])) != 0) return ret;
	if ((ret = strcmp(ptb_InRec[GT_END_NT], ptb_InRec_Cur[GT_END_NT])) != 0) return ret;
	if ((ret = strcmp(ptb_InRec[GT_SEC_NF], ptb_InRec_Cur[GT_SEC_NF])) != 0) return ret;
	if ((ret = strcmp(ptb_InRec[GT_UWY_NF], ptb_InRec_Cur[GT_UWY_NF])) != 0) return ret;
	if ((ret = strcmp(ptb_InRec[GT_UW_NT],	ptb_InRec_Cur[GT_UW_NT]))  != 0) return ret;
	
	RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du fichier des previsions

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre

		Récupération des informations compta
		L'information sur la compta est dans le fichier CURGTA.
		Lidée est de créer un programme qui parcourt ce fichier CURGTA pour identifier pour chaque contrat/section/exercice  
		Condition 1 : pas de ligne sur le poste 11300XX0 pour un Contrat/Section/Exercice(EPP)
		Condition 2 : pas de ligne sur le poste 11301XX0 pour un Contrat/Section/Exercice(RPP)
		Condition 3 : on trouve une ligne sur le poste 11300XX0 mais pas de ligne sur 11310000(EPP)
		Condition 4 : on trouve une ligne sur le poste 11301XX0 mais pas de ligne sur 11310100(RPP)
		Condition 5 : on trouve une ligne sur le poste 11300XX0 et une ligne sur 11310000(EPP)
		Condition 6 : on trouve une ligne sur le poste 11301XX0 et une ligne sur 11310100(RPP)
//[05] start
		Condition 7 : on trouve une ligne sur le poste 11301XX0 mais pas de ligne sur 11312000(IPP taxes)
		Condition 8 : on trouve une ligne sur le poste 11301XX0 mais pas de ligne sur 11312100(OPP taxes)
		Condition 9 : on trouve une ligne sur le poste 11301XX0 et une ligne sur 11312000(IPP taxes)
		Condition 10: on trouve une ligne sur le poste 11301XX0 et une ligne sur 11312100(OPP taxes)
//[05] end
		En sortie de ce nouveau programme(ESTC1012.c), créer un fichier temporaire au format :
		Contrat / Section / Exercice / Condition / Montant EPP/RPP / Montant commission EPP/RPP/Devise.

==============================================================================*/
int n_ActionLigneGT(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLigneGT");


    if (n_ProcessingRuptureSyncVar(&bd_SyncPericase, ptb_InRec_Cur) == ERR)
        RETURN_VAL(ERR);

	// vérification des postes de commissions 11310000 et 11310100
	if (strcmp(ptb_InRec_Cur[GT_TRNCOD_CF], "11310000") ==0)												// EPP
		d_getMnt(COM_EPP, ptb_InRec_Cur);


	if (strcmp(ptb_InRec_Cur[GT_TRNCOD_CF], "11310100") ==0)												// RPP
		d_getMnt(COM_RPP, ptb_InRec_Cur);
//[05] start
	// vérification des postes de taxes 11312000 et 11312100
	if ((strcmp(ptb_InRec_Cur[GT_TRNCOD_CF], "11312000") == 0))	// TAX_EPP 
		d_getMnt(TAX_EPP, ptb_InRec_Cur);

	if ((strcmp(ptb_InRec_Cur[GT_TRNCOD_CF], "11312100") == 0))	// TAX_RPP 
	{ 
		d_getMnt(TAX_RPP, ptb_InRec_Cur);
		
	}
//[05] end	
	// autre que les commissions
	if ((strncmp(ptb_InRec_Cur[GT_TRNCOD_CF], "11300", 5) == 0) && (ptb_InRec_Cur[GT_TRNCOD_CF][7] == '0'))	// EPP 
		d_getMnt(MNT_EPP, ptb_InRec_Cur);

	if ((strncmp(ptb_InRec_Cur[GT_TRNCOD_CF], "11301", 5) == 0) && ptb_InRec_Cur[GT_TRNCOD_CF][7] == '0')	// RPP
		d_getMnt(MNT_RPP, ptb_InRec_Cur);

	



    RETURN_VAL(OK);
}

/*==============================================================================
[04]
objet :
        fonction lancee pour chaque ligne du fichier des previsions

retour :
        0 ----> traitement correctement effectue

==============================================================================*/

int d_getMnt(char masque, char **ligneGT)
{
	double	taux_devise = 0.0;
	char 	MsgAno[250] = {'\0'};
	
	
	if ((taux_devise = d_GetTaux(Kp_InCur, atoi(ligneGT[GT_SSD_CF]), atoi(ligneGT[GT_BALSHEY_NF]), ligneGT[GT_CUR_CF], cols_sortie.Devise)) == -1)
	{
		sprintf(MsgAno, "d_GetTaux failed for SSD = %s, BALSHEY = %s, ORICUR = %s, DESTCUR = %s (impacted contract %s)\n",
		ligneGT[GT_SSD_CF], ligneGT[GT_BALSHEY_NF], ligneGT[GT_CUR_CF], cols_sortie.Devise, ligneGT[GT_CTR_NF]);
        n_WriteAno(MsgAno);
		RETURN_VAL(ERR);
	}


	switch (masque)
	{
		case COM_EPP:
						cols_sortie.Comm_EPP 	+= atof(ligneGT[GT_AMT_M]) * taux_devise;
						// on considère qu'une ligne existe si sont montant cumule n'est pas compris entre -1 et 1 exclu
						if (fabs(cols_sortie.Comm_EPP) > 1)
							sentinel |= masque;
						else
						// si le cumul montant est compris entre -1 et 1 exclu alors on abaisse notre bit à zero	
							sentinel &= ~masque;
						break;

		case COM_RPP:
						cols_sortie.Comm_RPP 	+= atof(ligneGT[GT_AMT_M]) * taux_devise;
						if (fabs(cols_sortie.Comm_RPP) > 1)
							sentinel |= masque;
						else
							sentinel &= ~masque;
						break;

		case MNT_EPP:
						cols_sortie.Montant_EPP += atof(ligneGT[GT_AMT_M]) * taux_devise;
						if (fabs(cols_sortie.Montant_EPP) > 1)
							sentinel |= masque;
						else
							sentinel &= ~masque;
						break;

		case MNT_RPP:
						cols_sortie.Montant_RPP += atof(ligneGT[GT_AMT_M]) * taux_devise;
						if (fabs(cols_sortie.Montant_RPP) > 1)
							sentinel |= masque;
						else
							sentinel &= ~masque;
						break;
//[05] start
		case TAX_EPP:
						cols_sortie.Taxes_EPP += atof(ligneGT[GT_AMT_M]) * taux_devise;
						// on considère qu'une ligne existe si sont montant cumule n'est pas compris entre -1 et 1 exclu
						if (fabs(cols_sortie.Taxes_EPP) > 1)
							sentinel |= masque;
						else
							// si le cumul montant est compris entre -1 et 1 exclu alors on abaisse notre bit à zero	
							sentinel &= ~masque;
						break;

		case TAX_RPP:
						cols_sortie.Taxes_RPP += atof(ligneGT[GT_AMT_M]) * taux_devise;
						if (fabs(cols_sortie.Taxes_RPP) > 1)
							sentinel |= masque;
						else
							sentinel &= ~masque;
						break;
//[05] end
		default:
						sprintf(MsgAno, "d_getMnt failed bad masque used %d\n",
						masque);
        				n_WriteAno(MsgAno);
						RETURN_VAL(ERR);
						break;
	}

	RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du fichier des previsions

retour :
        0 ----> traitement correctement effectue

==============================================================================*/

int n_ActionLigneFirst(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLigneFirst");

	// réinitialisation des variable global
    sentinel = 0b00000000;
	memset(&cols_sortie , 0, sizeof(t_sortie));
	//cols_sortie.Devise = strdup(ptb_InRec_Cur[GT_CUR_CF]);
	strcpy(cols_sortie.Devise,ptb_InRec_Cur[GT_CUR_CF]);

    RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du fichier des previsions

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre

		Récupération des informations compta
		L'information sur la compta est dans le fichier CURGTA.
		Lidée est de créer un programme qui parcourt ce fichier CURGTA pour identifier pour chaque contrat/section/exercice  
		Condition 1 : pas de ligne sur le poste 11300XX0 pour un Contrat/Section/Exercice(EPP)
		Condition 2 : pas de ligne sur le poste 11301XX0 pour un Contrat/Section/Exercice(RPP)
		Condition 3 : on trouve une ligne sur le poste 11300XX0 mais pas de ligne sur 11310000(EPP)
		Condition 4 : on trouve une ligne sur le poste 11301XX0 mais pas de ligne sur 11310100(RPP)
		Condition 5 : on trouve une ligne sur le poste 11300XX0 et une ligne sur 11310000(EPP)
		Condition 6 : on trouve une ligne sur le poste 11301XX0 et une ligne sur 11310100(RPP)
//[05] start
		Condition 7 : on trouve une ligne sur le poste 11301XX0 mais pas de ligne sur 11312000(IPP taxes)
		Condition 8 : on trouve une ligne sur le poste 11301XX0 mais pas de ligne sur 11312100(OPP taxes)
		Condition 9 : on trouve une ligne sur le poste 11301XX0 et une ligne sur 11312000(IPP taxes)
		Condition 10: on trouve une ligne sur le poste 11301XX0 et une ligne sur 11312100(OPP taxes)
//[05] end
		En sortie de ce nouveau programme(ESTC1012.c), cr?r un fichier temporaire au format :
		Contrat / Section / Exercice / Condition / Montant EPP/RPP / Montant commission EPP/RPP/Devise.

==============================================================================*/

int n_ActionLigneLast(char **ptb_InRec_Cur)
{
	char 	Condition_EPP[3]; 		//[06]
	char  Condition_RPP[3];     //[06]
  char 	Condition_Tax_EPP[3]; //[06]
	char 	Condition_Tax_RPP[3]; //[06]

  // [06] Initialisation des variables
  
  strcpy(Condition_EPP, "");
  strcpy(Condition_RPP, "");
  strcpy(Condition_Tax_EPP, "");
  strcpy(Condition_Tax_RPP, "");    

    DEBUT_FCT("n_ActionLigneLast");

	if ((sentinel & MNT_EPP) == 0)			//Pas de ligne 11300XX0 
		strcpy(Condition_EPP, "1");
	else if ((sentinel & COM_EPP) == 0)		//poste 11300xx0 mais pas de comm EPP 11310000
		strcpy(Condition_EPP, "3");
	else									//poste 11300xx0 et comm EPP 11310000
		strcpy(Condition_EPP, "5");

	if ((sentinel & MNT_RPP) == 0)			//Pas de ligne 11301XX0
		strcpy(Condition_RPP, "2");
	else if ((sentinel & COM_RPP) == 0)		//poste 11301xx0 mais pas de comm RPP 11310100
		strcpy(Condition_RPP,"4");
	else									//poste 11301xx0 et comm RPP 11310100
		strcpy(Condition_RPP, "6");

//[05] start
	if ((sentinel & MNT_EPP) == 0)			//Pas de ligne 11300XX0 
		strcpy(Condition_Tax_EPP, "1");
	else if ((sentinel & TAX_EPP) == 0)		//poste 11301xx0 mais pas de tax IPP 11312000
		strcpy(Condition_Tax_EPP, "7");
	else									//poste 11300xx0 et tax OPP 11311200
		strcpy(Condition_Tax_EPP, "9"); //[06]

	if ((sentinel & MNT_RPP) == 0)			//Pas de ligne 11301XX0
		strcpy(Condition_Tax_RPP, "2");
	else if ((sentinel & TAX_RPP) == 0)		//poste 11301XX0 mais pas de tax IPP 11312100
		strcpy(Condition_Tax_RPP, "8");
	else									//poste 11301XX0 et tax OPP 11312100
		strcpy(Condition_Tax_RPP, "10");
//[05] end


	fprintf(Kp_OutFile ,
 	"%s~%s~%s~%s~%s~%s~%s~%s~%s~%f~%f~%f~%f~%f~%f~%s\n",
									 ptb_InRec_Cur[GT_CTR_NF],
									 ptb_InRec_Cur[GT_END_NT],
									 ptb_InRec_Cur[GT_SEC_NF] ,
									 ptb_InRec_Cur[GT_UWY_NF],
									 ptb_InRec_Cur[GT_UW_NT],
									 Condition_EPP,
									 Condition_RPP,
									 Condition_Tax_EPP, //[05]
									 Condition_Tax_RPP,//[05]
									 cols_sortie.Montant_EPP,
									 cols_sortie.Montant_RPP,
									 cols_sortie.Comm_EPP,
									 cols_sortie.Comm_RPP,
									 cols_sortie.Taxes_EPP,//[05]
									 cols_sortie.Taxes_RPP,//[05]
									 cols_sortie.Devise);
	//free(cols_sortie.Devise);
    RETURN_VAL(OK);
}

/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec
  l'esclave « Montants de primes et charges »

retour :
  OK
==============================================================================*/
int n_InitPericase(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitPericase");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTC1012_I2", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync 	= n_ConditionSyncPericase;
  pbd_Rupt->n_FilsSansPere		= n_PericaseSansGT;
  pbd_Rupt->c_Separ 			= '~';

  RETURN_VAL(OK);
}

/*==============================================================================
param
  pbd_InRecGT 		-> Fichier père
  pbd_InRecPericase -> Fichier Fils

objet :
  fonction de test de synchronisation

==============================================================================*/
int n_ConditionSyncPericase(char **pbd_InRecGT, char **pbd_InRecPericase)
{
  int ret = 0;

  DEBUT_FCT("n_ConditionSyncPericase");

  if ((ret = strcmp(pbd_InRecGT[GT_CTR_NF], pbd_InRecPericase[PER_CTR_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGT[GT_END_NT], pbd_InRecPericase[PER_END_NT])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGT[GT_SEC_NF], pbd_InRecPericase[PER_SEC_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGT[GT_UWY_NF], pbd_InRecPericase[PER_UWY_NF])) != 0) return ret;
  if ((ret = strcmp(pbd_InRecGT[GT_UW_NT] , pbd_InRecPericase[PER_UW_NT]))  != 0) return ret;

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du fichier des previsions

retour :
        0 ----> traitement correctement effectue
 
		Condition 1 : pas de ligne sur le poste 11300XX0 pour un Contrat/Section/Exercice(EPP)
		Condition 2 : pas de ligne sur le poste 11301XX0 pour un Contrat/Section/Exercice(RPP)
==============================================================================*/
int n_PericaseSansGT(char **pbd_InRecPericase)
{
  	
  	DEBUT_FCT("n_ConditionSyncPericase");

	fprintf(Kp_OutFile ,"%s~%s~%s~%s~%s~%d~%d~%d~%d~%s~%s~%s~%s~%s~%s~%s\n",
						pbd_InRecPericase[PER_CTR_NF],
						pbd_InRecPericase[PER_END_NT],
						pbd_InRecPericase[PER_SEC_NF] ,
						pbd_InRecPericase[PER_UWY_NF],
						pbd_InRecPericase[PER_UW_NT],
						1,										// valeur de parametrage EPP par defaut
						2,										// valeur de parametrage RPP par defaut
//[05] start
						1,										// valeur de parametrage EPP par defaut
						2,										// valeur de parametrage RPP par defaut
						"", 									// pas de montant car pas de ligne renseigné
						"", 									// pas de montant car pas de ligne renseigné
//[05] end
						"", 									// pas de montant car pas de ligne renseigné
						"", 									// pas de montant car pas de ligne renseigné
						"", 									// pas de montant car pas de ligne renseigné
						"", 									// pas de montant car pas de ligne renseigné
						"");									// pas de devise  car pas de ligne renseigné (s'il la devise disparait en sorti de l'ESTC1018 sur les poste 11310[10]0[62] renseigner la devise avec le PER_EGPCUR_CF)

  RETURN_VAL(OK);
}
 
