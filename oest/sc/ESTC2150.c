/*==============================================================================
nom de l'application          : Epuration des previsions du bilan en cours et ouverture du bilan suivant
nom du source                 : ESTC2150.c
revision                      : $Revision: 1.2 $
date de creation              : 18/09/1997
auteur                        : P. LOUVEAU
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :

------------------------------------------------------------------------------
historique des modifications :
[00] <jj/mm/aaaa>   <auteur>    <description de la modification>
[01] 04/06/2003 G. BUISSON Dans les fichiers TLIFEST et TLIFDRI on garde la date de creation et le user de creation origine
[02] 06/02/2004 G. BUISSON Les depots doivent etre geres en type 2 la liberation se fait dans le meme exercice que la constitution
[03] 11/05/2006 J. Ribot   on garde la 1ere prevision et la derniere meme si a zero (SPOT11243)
[04] 27/03/2008 J. Ribot   SPOT 15219 ASE15 : recompilation des programmes C
[05] 08/12/2008 J. Ribot   SPOT 16585 le max de tlifdri passe de 15000 à 50000
[06] 19/01/2012 Florent    :spot22315 corrections gestion des libérations
[07] 27/11/2012 R. Cassis  :spot:24525  Agrandissement tableau Pilot
[08] 29/10/2013 R. Cassis  :spot:25427  Changement secondes dans date maj pour tri avec suppression du doublon dans le ESTC2040
[09] 17/11/2014 R. Cassis  :spot:27864  OM 2B - Manage warnings
[10] 14/10/2015 R. Cassis  :spot:29514  Evol sur les changements de postes Tlifest
                                        Refonte du traitement d'epuration TLIFDRI - plus de chargement en memoire
[11] 14/02/2020 L. Wernert :spot:73774 Ajout du traitement des ouvertures trimestrielles
[12] 18/11/2020 B. LAGHA   :spot:90055 Ajout du trimestre dans la cle des ouverture TLIFDRID (trimestrielles)
==============================================================================*/
/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <stdio.h>
#include <estserv.h>
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
// [10]
#define PRECOURT_CTR_NF 0
#define PRECOURT_END_NT 1
#define PRECOURT_SEC_NF 2
#define PRECOURT_UWY_NF 3
#define PRECOURT_UW_NT 4
#define PRECOURT_CRE_D 5
#define PRECOURT_BALSHEY_NF 6
#define PRECOURT_BALSHTMTH_NF 7
#define PRECOURT_ACY_NF 8
#define PRECOURT_GAAP_NT 9       
#define PRECOURT_DETTRNCOD_CF 10 
#define PRECOURT_ACM_NF 11       
#define PRECOURT_PRS_CF 12       
#define PRECOURT_ACMTRS_NT 13    
#define PRECOURT_SSD_CF 14       
#define PRECOURT_CUR_CF 15       
#define PRECOURT_ESTMNT_M 16     
#define PRECOURT_INDSUP_B 17     
#define PRECOURT_ORICOD_LS 18    
#define PRECOURT_CREUSR_CF 19    
#define PRECOURT_LSTUPD_D 20     
#define PRECOURT_LSTUPDUSR_CF 21 
#define PRECOURT_ORICTR_NF 22
#define PRECOURT_ORISEC_NF 23
#define PRECOURT_ORIUWY_NF 24
#define PRECOURT_GAAPDIFF_M 25
#define PRECOURT_PROPAGATION_B 26
#define PRECOURT_CALCULATED_B 27
#define PRECOURT_BATCH_B 28
#define PRECOURT_NBCOL 29

#define PRE_BATCH_B 51

/*----------------------------------*/


/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE            *Kp_PrevInFil;          /* pointeur sur les previsions en entree */
FILE            *Kp_PrevOutFil;         /* pointeur sur les previsions en sortie */
FILE            *Kp_PilotInFil;         /* pointeur sur les pilotages en entree  */
FILE            *Kp_PilotOutFil;        /* pointeur sur les pilotages en sortie  */
FILE            *Kp_SubTRSAssoFile;     /* pointeur sur les pilotages */ // [10]

T_RUPTURE_VAR   bd_RuptPrev;            /* gestion rupture sur Prev */
int             Kn_annee;               /* annee d'inventaire */
int             Kn_NbLigPilot;          /* Nombre de lignes dans le fichier pilotage */
char            date_traitement[9];
char            date_cre[20];

char			ksz_quarter[2];

fpos_t K_pos;
T_SUBTRSASSO Kbd_SubTRSASSO[10000];
T_SUBTRSASSO SubTrsAssoLigne;

int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt) ;
int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrev(char **ptb_InRec_Cur); // SPOT 11243
int n_ActionLastRuptPrev(char **ptb_InRec_Cur);
int n_ActionLignePrev(char **pbd_InRec_Cur);
void init_SubTrsAssoLigne();

CS_CHAR             CTR_actuel[10] = "";
CS_TINYINT          END_actuel = 0;
CS_TINYINT          SEC_actuel = 0;
CS_SMALLINT         ACY_actuel = -1;
CS_TINYINT          ACM_actuel = 0;     // [12]

int n_TraitePilot();
int n_TraitePilotQ();
int n_EcritReformat (char **ptb_Ligne);

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
        InitSig () ;

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Recuperation de l'annee d'inventaire */
        Kn_annee = atoi(psz_GetCharArgv(1));

        /* Recuperation de la date de traitement */
        strcpy(date_traitement, psz_GetCharArgv(2));
        
        strcpy(ksz_quarter, psz_GetCharArgv(3));

        /* Ouverture des fichiers en sortie */
        if ( n_OpenFileAppl ("ESTC2150_O1","wt",&Kp_PrevOutFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2150_O2","wt",&Kp_PilotOutFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2150_I3","rb",&Kp_SubTRSAssoFile) == ERR )  // [10]
                ExitPgm ( ERR_XX , "" );  

        n_ChargerTsubTRSAsso(Kp_SubTRSAssoFile);  // [10]

        /* Initialisation de la varible bd_RuptPrev */
        if ( n_InitPrev(&bd_RuptPrev) )
                ExitPgm ( ERR_XX , "" );

        /* modif O.Arik:29/05/2001 on sort en cas de dep. de memoire*/
        /* Chargement en memoire du fichier pilotage */
        if (ksz_quarter[0] == '0'){
        	if (n_TraitePilot() == ERR)
	        	ExitPgm(ERR_XX , "");
        } else {
        	if (n_TraitePilotQ() == ERR)
	        	ExitPgm(ERR_XX , "");
        }
        /* Epuration du fichier pilotage */
//        n_EpurerPilot();

        /* Lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPrev) == ERR )
               ExitPgm ( ERR_XX , "" );

        /* Fermeture fichier */
        if (n_CloseFileAppl ("ESTC2150_I1",&(bd_RuptPrev.pf_InputFil)))
               ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2150_I2",&Kp_PilotInFil))
               ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2150_I3",&Kp_SubTRSAssoFile) == ERR)  // [10]
               ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2150_O1",&Kp_PrevOutFil))
               ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2150_O2",&Kp_PilotOutFil))
               ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
               ExitPgm ( ERR_XX , "" );

        return(OK);
}



/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        0
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPrev");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2150_I1","rt",&(pbd_Rupt->pf_InputFil)))
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 1 ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;
        pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRuptPrev;  // [10]
        pbd_Rupt->n_ActionLast[0]       = n_ActionLastRuptPrev;

        pbd_Rupt->n_ActionLigne         = n_ActionLignePrev ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (0);
}



/*==============================================================================
objet :
        fonction de test de rupture de niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Prev(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Prev");

        if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_END_NT],ptb_InRec_Cur[PRE_END_NT])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_UW_NT],ptb_InRec_Cur[PRE_UW_NT])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_ACY_NF],ptb_InRec_Cur[PRE_ACY_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_ACMTRS_NT],ptb_InRec_Cur[PRE_ACMTRS_NT])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF],ptb_InRec_Cur[PRE_DETTRNCOD_CF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_GAAP_NF],ptb_InRec_Cur[PRE_GAAP_NF])!=0)
                RETURN_VAL(1);

        RETURN_VAL (0);
}


/*==============================================================================
objet :
	fonction lancee a la rupture premiere de niveau 1
        retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRuptPrev(char **ptb_InRec_Cur)
{
fgetpos(Kp_PrevOutFil,&K_pos);

//n_EcritReformat (ptb_InRec_Cur);

  return OK;
}

// FIN SPOT 11243


/*==============================================================================
objet : Fonction lancee a chaque rupture derniere
==============================================================================*/
int n_ActionLastRuptPrev (char **ptb_InRec_Cur)
{
	int poste;
	int annee_compte;
	char sz_montant_orig[18];
	char sz_montant_inv[18];
	char sz_Balshey[5];
	char sz_Acy[5];
	char sz_Uwy[5];
	char sz_Acmtrs[10];
	char sz_DateInit[40] ;
	int resltC;  // Resultat test Constitution
	int resltL;  // Resultat test Liberation
	char sz_dettrncod1[6];
	char sz_dettrncod2[6];

	DEBUT_FCT("n_ActionLastRuptPrev");
	
	memset( sz_DateInit, 0, sizeof(sz_DateInit) );
	memset( sz_montant_orig, 0, sizeof(sz_montant_orig) );
	memset( sz_montant_inv, 0, sizeof(sz_montant_inv) );

	poste = atoi(ptb_InRec_Cur[PRE_ACMTRS_NT]);
	annee_compte = atoi(ptb_InRec_Cur[PRE_ACY_NF]);

//if (strcmp(ptb_InRec_Cur[PRE_CTR_NF],"04T002680") == 0 && atoi(ptb_InRec_Cur[PRE_UWY_NF]) == 2017)
//printf("	2b 01yav - PRE_BALSHEY_NF = %s - PRE_CRE_D = %s - PRE_ACMTRS_NT = %s - PRE_ESTMNT_M %s\n",ptb_InRec_Cur[PRE_BALSHEY_NF],ptb_InRec_Cur[PRE_CRE_D],ptb_InRec_Cur[PRE_ACMTRS_NT],ptb_InRec_Cur[PRE_ESTMNT_M]);

	/* Derniere position des previsions (via CRE_D) */
	if ( atoi(ptb_InRec_Cur[PRE_BALSHEY_NF]) == Kn_annee )
	{
		if ( strcmp(date_cre,  ptb_InRec_Cur[PRE_CRE_D]) == 0)
		{
			fsetpos(Kp_PrevOutFil,&K_pos);
		}

		if ( annee_compte >= (Kn_annee-4) && annee_compte < (Kn_annee+5) )  // [10] incrementation de kn_annee de -3 a -4 et de +3 a +5
		{
			sprintf (sz_montant_orig,"%.3lf",atof(ptb_InRec_Cur[PRE_ESTMNT_M]));
			sprintf (sz_montant_inv,"%.3lf",atof(ptb_InRec_Cur[PRE_ESTMNT_M]) * (-1) );

			// Si retro, on inverse systematiquement le montant
			if (atoi(ptb_InRec_Cur[PRE_ACMTRS_NT]) > 2000)
			{
				sprintf (sz_montant_inv,"%.3lf",atof(ptb_InRec_Cur[PRE_ESTMNT_M]));
				sprintf (sz_montant_orig,"%.3lf",atof(ptb_InRec_Cur[PRE_ESTMNT_M]) * (-1) );
				ptb_InRec_Cur[PRE_ESTMNT_M] = sz_montant_orig;
			}

			sprintf (sz_Balshey, "%d", (Kn_annee+1));
			ptb_InRec_Cur[PRE_BALSHEY_NF] = sz_Balshey;
			ptb_InRec_Cur[PRE_BALSHTMTH_NF] = "1";
			ptb_InRec_Cur[PRE_LSTUPDUSR_CF] = "dbo";

			// Reconduction sur annee bilan suivante
			sprintf(sz_DateInit,"%d0101 00:00:01",Kn_annee+1);  // [08]
			ptb_InRec_Cur[PRE_LSTUPD_D] = sz_DateInit;
			
			// On ecrit la reconduction
			n_EcritReformat(ptb_InRec_Cur);

			// On teste si poste est une Liberation car dans ce cas, on ne fait plus rien
			init_SubTrsAssoLigne();
			resltL=n_FindTsubTRSAssoCons(1,1,ptb_InRec_Cur[PRE_DETTRNCOD_CF]);

//if (strcmp(ptb_InRec_Cur[PRE_CTR_NF],"04T007205") == 0 )
//printf(" resltL = %d - code = %s\n",resltL,ptb_InRec_Cur[PRE_DETTRNCOD_CF]);

			if (annee_compte == Kn_annee+4 && resltL == -1)
			{ 
				// C'est pas une liberation
				sprintf (sz_Acy,"%d",atoi(ptb_InRec_Cur[PRE_ACY_NF])+1);
				ptb_InRec_Cur[PRE_ACY_NF] = sz_Acy;

				// On teste si poste est une Constitution
				init_SubTrsAssoLigne();
				sprintf(sz_dettrncod1,"%s",ptb_InRec_Cur[PRE_DETTRNCOD_CF]);
				sz_dettrncod1[5]=0;	
				resltC=n_FindTsubTRSAsso(&SubTrsAssoLigne,1,1,sz_dettrncod1);
				if (resltC == (-1))
				{ 
					// cas poste non constitution
					sprintf(sz_DateInit,"%d0101 00:00:03",Kn_annee+1);  // [08]
					ptb_InRec_Cur[PRE_LSTUPD_D] = sz_DateInit;
					ptb_InRec_Cur[PRE_ESTMNT_M] = sz_montant_orig;

					// On incremente l'exercice selon le type comptable
					if ( atoi(ptb_InRec_Cur[PRE_ACCADMTYP_CT]) == 1 || 
						 (atoi(ptb_InRec_Cur[PRE_ACCADMTYP_CT]) == 3 && strncmp(ptb_InRec_Cur[PRE_ACMTRS_NT]+1,"2",1) != 0))  // poste non sinistre
					{
						sprintf(sz_Uwy, "%d", atoi(ptb_InRec_Cur[PRE_UWY_NF])+1);
						ptb_InRec_Cur[PRE_UWY_NF] = sz_Uwy;
					} 
				}
				else
				{
					// cas poste constitution
					// On reconduit sur acy+1
					sprintf(sz_DateInit,"%d0101 00:00:04",Kn_annee+1);  // [08]
					ptb_InRec_Cur[PRE_LSTUPD_D] = sz_DateInit;

					// On incremente l'exercice selon le type comptable
					sprintf(sz_Uwy, "%d", atoi(ptb_InRec_Cur[PRE_UWY_NF]) + i_LiberationExeP1(poste,atoi(ptb_InRec_Cur[PRE_ACCADMTYP_CT])));
					ptb_InRec_Cur[PRE_UWY_NF] = sz_Uwy;

					n_EcritReformat(ptb_InRec_Cur);

					// on genere la liberation
					sprintf(sz_dettrncod2,"%s",SubTrsAssoLigne.DETTRNCOD2_CF);
					sz_dettrncod2[5]=0;
					sprintf(ptb_InRec_Cur[PRE_DETTRNCOD_CF],"%s",sz_dettrncod2);
					
					// On change l'ACMTRS sauf pour poste x9xx
					if (strncmp(ptb_InRec_Cur[PRE_ACMTRS_NT]+1,"9",1) != 0)
					{
						sprintf (sz_Acmtrs,"%d",atoi(ptb_InRec_Cur[PRE_ACMTRS_NT]) + 1);
						ptb_InRec_Cur[PRE_ACMTRS_NT] = sz_Acmtrs;
					}
					sprintf(sz_DateInit,"%d0101 00:00:02",Kn_annee+1);  // [08]
					ptb_InRec_Cur[PRE_LSTUPD_D] = sz_DateInit;
					ptb_InRec_Cur[PRE_ESTMNT_M] = sz_montant_inv;
				}					
				n_EcritReformat(ptb_InRec_Cur);
			}                  
		}
	}
	RETURN_VAL (0);
}

/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour : 0 ----> traitement correctement effectue
         ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionLignePrev");

        RETURN_VAL (0);
}


/*==============================================================================
objet :
        Affiche une structure de type T_LIFDRI_ALL
==============================================================================*/
void affiche (T_LIFDRI_ALL *bd_Lu)
{
  printf("ctr=|%s|   sec=|%d|  uwy=|%d|   acy=|%d|   cre=|%s| \n",
                bd_Lu->CTR_NF, bd_Lu->SEC_NF, bd_Lu->UWY_NF,
                bd_Lu->ACY_NF, bd_Lu->CRE_D );
}


/*==========================================================================
     Objet :    Copie le contenu du fichier en entree dans un tableau
     Nom:       n_TraitePilot
     Parametres:
                Le pointeur du fichier
                Le tableau de structures
     Retour:    0
===========================================================================*/
int n_TraitePilot()
{
	int n_EOF = 0;
	char sz_DateInit[40] ;
	T_LIFDRI_ALL bd_Lu;

	DEBUT_FCT("n_TraitePilot");

	if ( n_OpenFileAppl ("ESTC2150_I2","rb",&Kp_PilotInFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Tant que la fin de fichier n'est pas atteinte,... */
	while ( n_EOF == 0 )
	{
		/* ... lecture d'une ligne dans le fichier. */
		if ( fread(&bd_Lu,sizeof(T_LIFDRI_ALL),1,Kp_PilotInFil) <= 0 )
			/* Fin de fichier, mise a jour du flag */
			n_EOF = 1;
		else 
		{
			// Non pas de chargement en memoire - traitement du record directement

			if ( (strcmp(CTR_actuel, bd_Lu.CTR_NF) != 0) ||
			            (END_actuel != bd_Lu.END_NT) ||
			            (SEC_actuel != bd_Lu.SEC_NF) ||
			            (ACY_actuel != bd_Lu.ACY_NF) )
			{
				/* Cas d'une rupture derniere sur CTR/END/SEC/ACY (CRE_D max) */
				/* sauvegarde position */
				strcpy(CTR_actuel, bd_Lu.CTR_NF);
				SEC_actuel = bd_Lu.SEC_NF;
				END_actuel = bd_Lu.END_NT;
				ACY_actuel = bd_Lu.ACY_NF;
				
				if ( bd_Lu.BALSHEY_NF == Kn_annee )
				{
					/* ecriture pilotage : report ligne pour bilan en cours */
					fwrite(&bd_Lu, sizeof(T_LIFDRI_ALL), 1, Kp_PilotOutFil);
				
					if ( bd_Lu.ACY_NF > (Kn_annee-4) )
					{
						/* ecriture pilotage : report ligne pour nouvelle annee bilan*/
						bd_Lu.BALSHEY_NF = Kn_annee+1;
						bd_Lu.BALSHTMTH_NF = 1;
						sprintf(sz_DateInit,"%d0101 00:00:00",Kn_annee+1);
						strcpy(bd_Lu.LSTUPD_D,sz_DateInit);
						strcpy(bd_Lu.LSTUPDUSR_CF,"dbo");
				   	
						fwrite(&bd_Lu, sizeof(T_LIFDRI_ALL), 1, Kp_PilotOutFil);
				                  
                 /* affiche (&bd_Lu);*/
					}
				}
			}
		}
	}
	RETURN_VAL (0);
}


/*==========================================================================
     Objet :    Copie le contenu du fichier en entree dans un tableau (quarterly
     Nom:       n_TraitePilotQ
     Parametres:
                Le pointeur du fichier
                Le tableau de structures
     Retour:    0
===========================================================================*/
int n_TraitePilotQ()
{
	int n_EOF = 0;
	char sz_DateInit[40] ;
	T_LIFDRI_ALL_QUARTER bd_Lu;

	DEBUT_FCT("n_TraitePilotQ");

	if ( n_OpenFileAppl ("ESTC2150_I2","rb",&Kp_PilotInFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Tant que la fin de fichier n'est pas atteinte,... */
	while ( n_EOF == 0 )
	{
		/* ... lecture d'une ligne dans le fichier. */
		if ( fread(&bd_Lu,sizeof(T_LIFDRI_ALL_QUARTER),1,Kp_PilotInFil) <= 0 )
			/* Fin de fichier, mise a jour du flag */
			n_EOF = 1;
		else 
		{
			// Non pas de chargement en memoire - traitement du record directement

			if ( (strcmp(CTR_actuel, bd_Lu.CTR_NF) != 0) ||
			            (END_actuel != bd_Lu.END_NT) ||
			            (SEC_actuel != bd_Lu.SEC_NF) ||
			            (ACY_actuel != bd_Lu.ACY_NF) ||
			            (ACM_actuel != bd_Lu.ACM_NF) ) //[12]
			{
				/* Cas d'une rupture derniere sur CTR/END/SEC/ACY (CRE_D max) */
				/* sauvegarde position */
				strcpy(CTR_actuel, bd_Lu.CTR_NF);
				SEC_actuel = bd_Lu.SEC_NF;
				END_actuel = bd_Lu.END_NT;
				ACY_actuel = bd_Lu.ACY_NF;
				ACM_actuel = bd_Lu.ACM_NF; //[12]
				
				if ( bd_Lu.BALSHEY_NF == Kn_annee )
				{
					/* ecriture pilotage : report ligne pour bilan en cours */
					fwrite(&bd_Lu, sizeof(T_LIFDRI_ALL_QUARTER), 1, Kp_PilotOutFil);
				
					if ( bd_Lu.ACY_NF > (Kn_annee-4) )
					{
						/* ecriture pilotage : report ligne pour nouvelle annee bilan*/
						bd_Lu.BALSHEY_NF = Kn_annee+1;
						bd_Lu.BALSHTMTH_NF = 1;
						sprintf(sz_DateInit,"%d0101 00:00:00",Kn_annee+1);
						strcpy(bd_Lu.LSTUPD_D,sz_DateInit);
						strcpy(bd_Lu.LSTUPDUSR_CF,"dbo");
				   	
						fwrite(&bd_Lu, sizeof(T_LIFDRI_ALL_QUARTER), 1, Kp_PilotOutFil);
				                  
                 /* affiche (&bd_Lu);*/
					}
				}
			}
		}
	}
	RETURN_VAL (0);
}

/*==========================================================================
	Objet :    Reformatage du fichier previsions
	Nom:       n_EcritReformat
	Parametres: Le pointeur de la ligne
	Retour: 0
===========================================================================*/
int n_EcritReformat (char **ptb_Ligne)
{
	char *(ptb_LigneCourt[PRECOURT_NBCOL + 1]);
	int   n_i;
	
	for (n_i = 0 ; n_i < PRECOURT_NBCOL ; n_i++)
		ptb_LigneCourt[n_i] = "";
	
	strcpy(date_cre,ptb_Ligne[PRE_CRE_D]);
	ptb_LigneCourt[PRECOURT_CTR_NF] = ptb_Ligne[PRE_CTR_NF];
	ptb_LigneCourt[PRECOURT_END_NT] = ptb_Ligne[PRE_END_NT];
	ptb_LigneCourt[PRECOURT_SEC_NF] = ptb_Ligne[PRE_SEC_NF];
	ptb_LigneCourt[PRECOURT_UWY_NF] = ptb_Ligne[PRE_UWY_NF];
	ptb_LigneCourt[PRECOURT_UW_NT] = ptb_Ligne[PRE_UW_NT];
	ptb_LigneCourt[PRECOURT_CRE_D] = ptb_Ligne[PRE_CRE_D];
	ptb_LigneCourt[PRECOURT_BALSHEY_NF] = ptb_Ligne[PRE_BALSHEY_NF];
	ptb_LigneCourt[PRECOURT_BALSHTMTH_NF] = ptb_Ligne[PRE_BALSHTMTH_NF];
	ptb_LigneCourt[PRECOURT_ACY_NF] = ptb_Ligne[PRE_ACY_NF];
	ptb_LigneCourt[PRECOURT_GAAP_NT] = ptb_Ligne[PRE_GAAP_NF];
	ptb_LigneCourt[PRECOURT_DETTRNCOD_CF] = ptb_Ligne[PRE_DETTRNCOD_CF];
	ptb_LigneCourt[PRECOURT_ACM_NF] = ptb_Ligne[PRE_ESTMTH_NF];
	ptb_LigneCourt[PRECOURT_PRS_CF] = ptb_Ligne[PRE_PRS_CF];
	ptb_LigneCourt[PRECOURT_ACMTRS_NT] = ptb_Ligne[PRE_ACMTRS_NT];
	ptb_LigneCourt[PRECOURT_SSD_CF] = ptb_Ligne[PRE_SSD_CF];
	ptb_LigneCourt[PRECOURT_CUR_CF] = ptb_Ligne[PRE_CUR_CF];
	ptb_LigneCourt[PRECOURT_ESTMNT_M] = ptb_Ligne[PRE_ESTMNT_M];
	ptb_LigneCourt[PRECOURT_INDSUP_B] = ptb_Ligne[PRE_INDSUP_B];
	ptb_LigneCourt[PRECOURT_ORICOD_LS] = "Initialisation";
	ptb_LigneCourt[PRECOURT_CREUSR_CF] = ptb_Ligne[PRE_CREUSR_CF];
	ptb_LigneCourt[PRECOURT_LSTUPD_D] = ptb_Ligne[PRE_LSTUPD_D];
	ptb_LigneCourt[PRECOURT_LSTUPDUSR_CF] = ptb_Ligne[PRE_LSTUPDUSR_CF];
	ptb_LigneCourt[PRECOURT_ORICTR_NF] = ptb_Ligne[PRE_ORICTR_NF];
	ptb_LigneCourt[PRECOURT_ORISEC_NF] = ptb_Ligne[PRE_ORISEC_NF];
	ptb_LigneCourt[PRECOURT_ORIUWY_NF] = ptb_Ligne[PRE_ORIUWY_NF];
	ptb_LigneCourt[PRECOURT_GAAPDIFF_M] = ptb_Ligne[PRE_GAAPDIFF_M];
	ptb_LigneCourt[PRECOURT_PROPAGATION_B] = ptb_Ligne[PRE_PROPAGATION_B];
	ptb_LigneCourt[PRECOURT_CALCULATED_B] = "0";  // ptb_Ligne[PRE_SPIMOD_CT]; on met 0 pour l'instant
	ptb_LigneCourt[PRECOURT_BATCH_B] = "1";  // ptb_Ligne[PRE_BATCH_B]; On met 1 pour l'instant 
	ptb_LigneCourt[PRECOURT_NBCOL] = 0;
	n_WriteCols (Kp_PrevOutFil,ptb_LigneCourt,'~',0);

	return OK;
}

// [10]
/*==========================================================================
     Objet :    Initialisation de la structure TRSASSO

     Nom:       init_SubTrsAssoLigne

     Parametres:
               

     Retour:    0
===========================================================================*/
//[003]
void init_SubTrsAssoLigne()
{
	strcpy(SubTrsAssoLigne.ASSOTYP_CT,"");
	SubTrsAssoLigne.CTX_NT=0;
	strcpy (SubTrsAssoLigne.DETTRNCOD1_CF,"");
	strcpy(SubTrsAssoLigne.CTX_LL,"");
	strcpy (SubTrsAssoLigne.DETTRNCOD2_CF,"");
	strcpy (SubTrsAssoLigne.DETTRNCOD3_CF,"");
	SubTrsAssoLigne.GUI_B=0;
	SubTrsAssoLigne.ACMTRS_NT=0;
	strcpy(SubTrsAssoLigne.CRE_D,"");
	strcpy(SubTrsAssoLigne.CREUSR_CF,"");
	strcpy(SubTrsAssoLigne.LSTUPD_D,"");
	strcpy(SubTrsAssoLigne.LSTUPDUSR_CF,"");
}

/*==========================================================================
     Objet :    Recuperer le code détail (contre partie) d'un poste donné (pour un DETTRNCOD)
     à partir de la structure T_SUBTRSASSO grace a l association et le context

     Nom:       n_ReturnDett

     Parametres:
                pointeur sur stucture TRSASSO
                Association
                context
                DETTRNCOD lib

     Retour:    DETTRNCOD/-1
===========================================================================*/
int n_ReturnDett(int Asso, int contx, char *DETRNCOD)
{
  int i;

  for (i = 0; i < sizeof(T_SUBTRSASSO); i++)
  { if ((Asso == atoi(Kbd_SubTRSASSO[i].ASSOTYP_CT)) && (contx == Kbd_SubTRSASSO[i].CTX_NT) && ((strcmp(DETRNCOD, Kbd_SubTRSASSO[i].DETTRNCOD2_CF) == 0)))
    {
      return atoi(Kbd_SubTRSASSO[i].DETTRNCOD1_CF);
    }
  }
  return -1 ;
}
