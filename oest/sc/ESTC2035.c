/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Actualisation des previsions annuelles
nom du source                 : ESTC2035.c
revision                      : $Revision: 1.5 $
date de creation              : 17/10/1997
auteur                        : P.LOUVEAU
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :



------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	25/02/1999		ANB			modification de la gestion des résiliations pour
								les type 1 et 3 : avant on mettait juste la
								libération dans le dernier exercice maintenant
								on met toutes les prévisions
	13/12/1999		ANB			prise en compte de la rétrocession dans la gestion
								des résiliations
	04/06/2003		J. RIBOT		prise en compte du CNATYP_CT
    29/04/2008    ASE15 : recompilation des programmes C
_________________
MODIFICATION    [004]
Auteur:         D.GATIBELZA
Date:           14/05/2008
Version:        8
Description:    ESTVIE15401 Agrandissement d'un tableau en mémoire
                agrandissement de NB_MAX_PILOT => 4000 
_________________
MODIFICATION    [006]
Auteur:         D.GATIBELZA
Date:           09/11/2010
Version:        10.1
Description:    ESTVIE20655 Agrandissement d'un tableau en mémoire:
                NB_MAX_PILOT 40000 => 100000
[007] 08/02/2013 R. Cassis :spot:24826 Ajout exeptions de postes                

_________________
MODIFICATION    [008]
Auteur:         P. PEZOUT
Date:           26/06/2013
Version:        13
SPOT            :spot:25324  limiter le rechargement de tlifest/tlifdri aux seules lignes crees par l'inventaire
Description:    on souhaite ecrire toutes les lignes de Prevision en entrée dans le fichier de Prevision en sortie
                en cas d'erreur sur la ligne Prevision lue, generer une nouvelle Prevision avec les valeurs corrigées
                Cette nouvelle ligne aura dans la date de creation CRE_D = date du jour + une heure spécifique 23:59:04
                Toutes les lignes ayant la date du jour et une heure >= 23:59:00 seront rechargees en base dans TLIFEST
                
                la clodat est passée en parametre, elle permettra de définir Ksz_Balshey = annee(CLODAT_D) et Ksz_Balshtmth = mois (CLODAT_D)
                il faut passer un deuxième argument au programme, avec la date du traitement pour alimenter Ksz_DateJour
                définir une variable heure Ksz_HeureTrait="23:59:04"
                définir une variable libelle sz_lib_oricod = 'UPDATE BATCH 2035'
                définir une variable libelle sz_lib_oricod_Err = 'ERROR'
                
                on va mettre ici coimme heure 23:59:04 pour que le tri s'opere de la maniere suivante :           
                pgm				JOB			STEP	LIB						HEURE			COMMENT
                ESTC2035	ESID2031	75	CTRL					23:59:04	CORRECTIONS
                ESTC2020	ESID2021	20	RETRO INTERNE	23:59:05	RETRO INTERNE
                ESTC2038	ESID2031	190	ARRETE STAT		23:59:10	CAS GENERAL
                ESTC2038	ESID2031	190	ARRETE STAT		23:59:11	CONSTITUTION NON VIE
                ESTC2038	ESID2031	190	ARRETE STAT		23:59:12	LIBERATIONS
                ESTC2038	ESID2031	190	ARRETE STAT		23:59:13	GT SANS PREV AFFAIRES TERMIN2ES
                ESTC2038	ESID2031	190	ARRETE STAT		23:59:14	GT SANS PREV
                ESTC2135	ESID2032	335	RETRO AUTO		23:59:15	RETRO AUTO
                ESTC2148	ESID2033	100	CNA AUTO 5		23:59:50	CNA AUTO
                ESTC7610	ESID1530	10	Estimates seuil calculation		
_________________
MODIFICATION    [009]
Auteur:         P. PEZOUT
Date:           26/06/2013
Version:        13
SPOT            :spot:25324  limiter le rechargement de tlifest/tlifdri aux seules lignes crees par l'inventaire
Description:    traitement du code retour sur le taux de conversion
                creer un numero erreur A_ErrTaux
[014] 03/03/2014 R. Cassis :spot:25427 - Corrections techniques                
[015] 11/03/2014 -=Dch=-  :spot:25427 - Corrections techniques

________________
MODIFICATION    [010]
Auteur:         S. BEHAGUE
Date:           07/03/2014
Version:        14
SPOT            
Description:    Modifications Omega 2B. Tri des postes analytiques.
                Prise en compte d'un nouveau format LIFDRI_ALL
[001] 14/10/2014 ABJ  spot:25773  Ajout des lib 1010 et 1140 au fichier de liberation
_________________
[011] 16/03/2015 SAS  spot : 28465 chargement des contrats convertis dans la grille. Ligne ajoutée: 1241
[012] 26/03/2015 SAS  spot : 28512 changement de la devise des postes analytics la SGLA02
[013] 10/04/2015 DAF  spot : 28613 changement des postes retenus par les controles des types comptable 3 et 5
[014] 02/06/2015 TLA  spot : 28559 Modification des fonctions n_RechPilot et n_RechPilotPerimetre pour optimiser ESTC2035.c
[002] 03/06/2015 ABJ  spot:28850  Ajouter les postes X52X au postes non Primes
[015] 03/06/2015 RBE  spot:29380  Ajouter le filtre sur les terminés comptables Retro
[016] 23/03/2016 SBE  spot:30374  Spira 44985/41107 - Mise dans le fichier d'erreur des lignes où UWY_NF > ACY_NF, quelque soit le type comptable
[017] 16/05/2018 SBE  spira:61671 Omega to SAP June simulation. Creation des postes prefixe 1 sur des sections Vie
[018] 13/02/2019 RAF  REQ.L.02.05: Evolution quarterly 
[019] 02/02/2021 SBE  spira:101411: The batch doesn't work properly to correct the wrong Propagation of Analytic Tcodes for acc. Type 3 - Copy
[020] 24/09/2025 MZM  BU 7084: NB_MAX_PILOT 200000 => 300000 in struct.h
=============================================================================================================================


-------------------------------------------------- */
/* inclusion des interfaces des composants importes
--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"
#include <time.h>


#define DEBUG 1

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
/*#define NB_MAX_PILOT    100000  //[006] /[005]*/

/* OMEGA2 B  : on va garder les define de struct.h 
#define PRE_UWGRP_CF        36  // ajout 12/01/98
#define PRE_CNATYP_CT       37  // ajout 04/06/03 */

FILE    *Kp_PilotIFil,  /* pointeur sur le fichier pilotage en entree */
        *Kp_PilotOFil,  /* pointeur sur le fichier pilotage en sortie */
        *Kp_AnoFil,     /* pointeur sur le fichier anomalies en sortie */
        *Kp_Prev1Fil,   /* pointeur sur le fichier previsions en sortie */
        *Kp_Prev2Fil,   /* pointeur sur le fichier previsions en sortie */
        *Kp_Prev3Fil,   /* pointeur sur le fichier previsions en sortie */
        *Kp_Prev4Fil,   /* pointeur sur le fichier previsions en sortie */
        *Kp_Prev5Fil,   /* pointeur sur le fichier previsions en sortie */
        *Kp_CoursFil,   /* Fichier des cours devise en entree */
        *Kp_PrevAnaFil, /* pointeur sur le fichier previsions analytiques en sortie */
        *Kp_PrevLibFil, /* pointeur sur le fichier des liberations en sortie */
        *Kp_SubTRSFil,  /* pointeur sur le fichier subtrs */
        *Kp_ErrUpdBatchfil;  /* pointeur sur le fichier Err update batch 2035 */

T_RUPTURE_VAR bd_RuptPrev; /* gestion rupture sur previsions */
T_RUPTURE_SYNC_VAR bd_RuptPerim; /* gestion synchro perimetre-previsions */


int n_InitPerim (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePerim  (char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPerim(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePrevision(char **pbd_InRec_Cur);
int n_IsR1Prevision(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrevision(char **ptb_InRec_Cur);
int n_IsR1PrevisionEx(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrevisionEx(char **ptb_InRec_Cur);
int n_IsR1PrevisionGaap(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrevisionGaap(char **ptb_InRec_Cur);

int n_ActionPereSansFils(char **ptb_InRec);
int n_ActionFilsSansPere(char **ptb_InRec);

int n_RechPilot (char **ptb_struct,int CTR_NF ,int SEC_NF,int *index); /* [014]*/
int n_RechPilotPerimetre (char **ptb_struct,int CTR_NF ,int SEC_NF, int UWY_NF, int *index1); /* [014]*/
int n_ReconduirePilotagePerimetre (char **ptb_InRec_Cur);

int n_ChargerPilot();
int n_ReconduirePrevision (char **ptb_InRec_Cur);
void init_SubTrsLigne();  //[012]

int     Kn_DernierEx;           /* Dernier exercice du perimetre */
BOOL    Kb_Resilie;             /* TRUE si cas de traite eteint ou resilie */
int     Kn_TypeComptable,       /* Type comptable du perimetre */
        Kn_annee,                /* annee en cours pour conversion au dernier cours */
        Kn_etat,
        Kn_etatRet;
char    Kc_crible,              /* Code crible stocke sur rupture */
        Ksz_date[11],                   /* Date en parametre */
        Ksz_UWGRP_CF[10],       /* Unite de souscription ecrite en ano */
        Ksz_devise[4],                  /* Devise principale stockee */
        Ksz_nature[3],          /* nature du perimetre */
        Ksz_lob[4],                /* lob du perimetre */
        Ksz_uwgrp[10],          /* AJOUT 12/01/98 */
        Ksz_esb[3];          /* AJOUT 21/01/98 */

char 	Ksz_accadmtyp[3],   /* ajout le 29/01/98 : variables qui */
	    Ksz_accsts[5],      /* servent a stocker les infos du */
	    Ksz_ced[10],        /* perimetre que l'on reconduit dans */
	    Ksz_brk[10],       /* les previsions en sortie */
	    Ksz_pay[10],
	    Ksz_ganpayord[10],
	    Ksz_lifdrityp[5],
	    Ksz_cnatyp[2];     /* ajout le 04/06/03 JR */     /*  modif pour ASE15 SPOT15219 */
char    Ksz_Ctr_Prec[10]="00T000000";
	
char Ksz_crible[2];      /*  modif pour ASE15 SPOT15219 */
int     Kb_rupt1,       /* 1 si rupture de niveau 1, 0 sinon */
        Kb_rupt2,       /* 1 si rupture de niveau 2, 0 sinon */
        Kb_SyncPeri;
int Kn_SyncPilot = 0; 
int Kn_SyncPilotSav = 0; 

char   Kc_typCtr[4]="MMM";

T_LIFDRI_ALL Kbd_PILOT[NB_MAX_PILOT];                /* Fichier pilotage charge en memoire */
int     Kn_NbLigPilot;                  /* Nombre de lignes dans le fichier pilotage */

T_SUBTRS     SubTrsLigne;				/* Structure retour de SubTRS */

/***************** [008] et [009] *********/
// Constante 
#define HEURE_TRAITEMENT 	"23:59:05"
#define LIBELLE_ORICOD   	"UPDATEBATCH 2035"
#define LIBELLE_ERR_ORICOD  "ERR"
#define A_ErrTaux 			16
#define DBO 				"dbo"
// fonctions 
char * Left(char * str, int pos);
char * FormattedDate(char * date2format, char* buffer);
void copy_string(char *target, char *source); 

// Variables
char Ksz_Balshey[5] , /* paramètre d'entrée de CLODAT  					*/
	 Ksz_DateJour[11], /* parametre d'entrée de date de traitment (CRE_D) 	*/
	 Ksz_Balshtmth[3],
	 sz_formated_cred[22],
	 sz_new_cre[22];   /* tampon utilisé pour récupérer la date formatée */
	 char sz_batch[2] = "1"; // Ajout 08/01/2014 pour prise en compte nouveau champ PRE_BATCH_B dans la structure LIFEST
char tmp[22];


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
        char sz_date[11];
		char sz_mois[2];
		int mois ;
		char sz_tmp[20];
		
		// initialisation de variables à 0
		memset(sz_new_cre,0, sizeof(sz_new_cre));
		memset(Ksz_Balshey, 0 , sizeof(Ksz_Balshey));
		memset(Ksz_Balshtmth, 0 , sizeof(Ksz_Balshtmth));
		memset(sz_mois, 0 , sizeof(sz_mois));
        memset(sz_tmp, 0, sizeof(sz_tmp));
		memset(sz_formated_cred, 0, sizeof(sz_formated_cred));
		memset(Ksz_nature , 0 , sizeof(Ksz_nature));
		memset(Ksz_ced, 0, sizeof(Ksz_ced));
		memset(Ksz_brk, 0, sizeof(Ksz_brk));
		memset(Ksz_pay, 0, sizeof(Ksz_pay));
		memset(Ksz_accadmtyp, 0 , sizeof(Ksz_accadmtyp));

        /* Initialisation des signaux */
        InitSig () ;

        if ( n_BeginPgm (argc  ,argv) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Recuperation de la date de traitement */
        strcpy(Ksz_date,psz_GetCharArgv(1));
		strcpy(sz_date,Ksz_date);
        sz_date[4]=0;
		Kn_annee = atoi(sz_date);
  		
		// Récupération de clodat (annee et mois)
		strcpy(Ksz_Balshey, sz_date); 
		strncpy(sz_mois, Ksz_date+4,2);
		sz_mois[2]=0;
		mois = atoi(sz_mois);
		sprintf(Ksz_Balshtmth,"%d",mois);

		// initialisation de la variable utilisée pour les valeurs en défaut
		sprintf(sz_tmp, "%s %s", psz_GetCharArgv(2), HEURE_TRAITEMENT);
		strcpy (sz_formated_cred, sz_tmp);// on sauvegarde le format pour l'utiliser par la suite 
		
//        strncpy(sz_new_cre, FormattedDate(sz_tmp), 20);
		FormattedDate(sz_tmp, sz_new_cre);
        /* ouverture des fichiers */
        if ( n_OpenFileAppl ("ESTC2035_O1","wb",&Kp_PilotOFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_O2","wt",&Kp_Prev1Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_O3","wt",&Kp_AnoFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_O4","wt",&Kp_Prev2Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_O5","wt",&Kp_Prev3Fil) == ERR )
                ExitPgm ( ERR_XX , "" );
                
        if ( n_OpenFileAppl ("ESTC2035_O6","wt",&Kp_Prev4Fil) == ERR )
                ExitPgm ( ERR_XX , "" );
                
        if ( n_OpenFileAppl ("ESTC2035_O7","wt",&Kp_Prev5Fil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_O8","wt",&Kp_PrevAnaFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_O9","wt",&Kp_PrevLibFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_O10","wt",&Kp_ErrUpdBatchfil) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2035_I4","rb",&Kp_CoursFil) == ERR )
                ExitPgm ( ERR_XX , "" );


                /* Initialisation de la varible bd_RuptPrev */
        if ( n_InitPrev(&bd_RuptPrev) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptPerim */
        if ( n_InitPerim(&bd_RuptPerim) )
                ExitPgm ( ERR_XX , "" );

        /* Chargement en memoire du fichier pilotage */
        /* modif O.Arik:29/05/2001 on sort en cas de dep. de memoire*/
        if(n_ChargerPilot () == ERR )
                        ExitPgm( ERR_XX , "" ) ;

    	// Chargement fichier T_SUBTRS
    	if (n_OpenFileAppl ("ESTC2035_I5","rb",&Kp_SubTRSFil) == ERR )
                		ExitPgm ( ERR_XX , "" );
    	if ( n_ChargerTsubTRS(Kp_SubTRSFil) == ERR ) 						ExitPgm( ERR_XX , "" ); 
		
		// initialisation de la structure retour
		init_SubTrsLigne(); //[012]
		
        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPrev) == ERR )
                ExitPgm ( ERR_XX , "" );

                /* Fermeture des fichiers */
        if (n_CloseFileAppl("ESTC2035_I1",&(bd_RuptPrev.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_I2",&(bd_RuptPerim.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_I3",&Kp_PilotIFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_I4",&Kp_CoursFil))
                ExitPgm ( ERR_XX , "" );
                
        if (n_CloseFileAppl ("ESTC2035_I5",&Kp_SubTRSFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O1",&Kp_PilotOFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O2",&Kp_Prev1Fil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O3",&Kp_AnoFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O4",&Kp_Prev2Fil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O5",&Kp_Prev3Fil))
                ExitPgm ( ERR_XX , "" );
                
        if (n_CloseFileAppl ("ESTC2035_O6",&Kp_Prev4Fil))
                ExitPgm ( ERR_XX , "" );
                
        if (n_CloseFileAppl ("ESTC2035_O7",&Kp_Prev5Fil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O8",&Kp_PrevAnaFil))
                ExitPgm ( ERR_XX , "" );                

        if (n_CloseFileAppl ("ESTC2035_O9",&Kp_PrevLibFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2035_O10",&Kp_ErrUpdBatchfil))
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        //exit(OK) ;
        return(OK);

}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        OK
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPrev");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2035_I1","rt",&(pbd_Rupt->pf_InputFil))== ERR)
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 3  ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prevision;
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPrevision;
        pbd_Rupt->n_ConditionRupture[1] = n_IsR1PrevisionEx;
        pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRuptPrevisionEx;
        pbd_Rupt->n_ConditionRupture[2] = n_IsR1PrevisionGaap;
        pbd_Rupt->n_ActionFirst[2] = n_ActionFirstRuptPrevisionGaap;
        
        pbd_Rupt->n_ActionLigne = n_ActionLignePrevision ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave Perim

retour :
        OK
==============================================================================*/
int n_InitPerim(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPerim");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC2035_I2","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncPerim ;
        /* fonction d'actions si le perimetre ne participe pas */
        pbd_Rupt->n_PereSansFils      = n_ActionPereSansFils;
        /* fonction d'actions si pas de lignes dans les prévisions */
        pbd_Rupt->n_FilsSansPere      = n_ActionFilsSansPere;
        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLignePerim ;

        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL (OK);
}


/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1Prevision(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Prevision");

        Kb_rupt1=0;
			
        if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)
                RETURN_VAL(1);
        RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction de test de rupture du niveau 2

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1PrevisionEx(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1PrevisionEx");

        /* Rupture seconde initialisee */
        Kb_rupt2=0;

        if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)
                RETURN_VAL(1);
        RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 3

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1PrevisionGaap(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1PrevisionEx");

        /* Rupture seconde initialisee */
        Kb_rupt2=0;

        if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_ACY_NF],ptb_InRec_Cur[PRE_ACY_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PRE_ESTMTH_NF],ptb_InRec_Cur[PRE_ESTMTH_NF])!=0) // [018]
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
        fonction de test de rupture du niveau 1

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwner > pbd_InRecChild
        < 0     ---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPerim(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncPerim");

        if( (ret = strcmp(pbd_InRecOwner[PRE_CTR_NF],pbd_InRecChild[PER_CTR_NF])) != 0 )
                RETURN_VAL (ret);
        if( (ret = strcmp(pbd_InRecOwner[PRE_SEC_NF],pbd_InRecChild[PER_SEC_NF])) != 0 )
                RETURN_VAL (ret);
        if( (ret = strcmp(pbd_InRecOwner[PRE_UWY_NF],pbd_InRecChild[PER_UWY_NF])) != 0 )
                RETURN_VAL (ret);

        RETURN_VAL (0);
}


/**************************************************************************/
/*** Objet:     Recherche une ligne du tableau de structures ou les     ***/
/***            champs correspondent aux parametres en entree.          ***/
/***                                                                    ***/
/*** Nom:       n_RechPilot                                             ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***            La ligne du tableau contenant les valeurs recherchees   ***/
/***            Le nombre de lignes du tableau ou s'effectue la         ***/
/***            recherche                                               ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***            Le numero de la ligne du tableau si il est  trouvé      ***/
/***            -1 si non trouve                                        ***/
/*** Auteur :  T.LAIDI                                                                     ***/
/**************************************************************************/
int n_RechPilot (char **ptb_struct,int CTR_NF ,int SEC_NF,int *index) /*[014]*/
{
  int   i;   /* indice dans le tableau parcouru */
  int debut =0 ;
  debut = *index;
  DEBUT_FCT("n_RechPilot");


  for(i=debut;i<Kn_NbLigPilot;i++)
    {
        if (strcmp(ptb_struct[CTR_NF], Kbd_PILOT[i].CTR_NF)==0 &&
            atoi(ptb_struct[SEC_NF])== Kbd_PILOT[i].SEC_NF  )
        {

            return i ;
        }
        if(strcmp(ptb_struct[CTR_NF], Kbd_PILOT[i].CTR_NF) < 0)
        {
        	return -1 ;
        }
    }

    return -1 ;
}

/**************************************************************************/
/*** Objet:     Recherche une ligne du tableau de structures ou les     ***/
/***            champs correspondent aux parametres en entree.          ***/
/***                                                                    ***/
/*** Nom:       n_RechPilotPerimetre                                             ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***            En entrée on a la structure perimetre                   ***/
/***            Le nombre de lignes du tableau ou s'effectue la         ***/
/***            recherche                                               ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***            Le numero de la ligne du tableau si trouve              ***/
/***            -1 si non trouve                                        ***/
/*** Auteur :    T.LAIDI                                                                      ***/
/**************************************************************************/
int n_RechPilotPerimetre (char **ptb_struct,int CTR_NF ,int SEC_NF, int UWY_NF, int *index1) /*[014]*/
{
  int   i;   /* indice dans le tableau parcouru */
  int debut =0 ;
  debut = *index1;
  DEBUT_FCT("n_RechPilotPerimetre");


  for(i=debut;i<Kn_NbLigPilot;i++)
    {
        if (strcmp(ptb_struct[CTR_NF], Kbd_PILOT[i].CTR_NF)==0 && atoi(ptb_struct[SEC_NF])== Kbd_PILOT[i].SEC_NF &&  atoi(ptb_struct[UWY_NF])==Kbd_PILOT[i].UWY_NF )
         {

            return i ;
         }
        if(strcmp(ptb_struct[CTR_NF], Kbd_PILOT[i].CTR_NF) < 0)
        {
        	return -1 ;
        }
    }

    return -1 ;
}

/*==============================================================================
objet :
        fonction d'ecriture dans le fichier d'anomalie

retour :
        OK ---> traitement correctement effectue
==============================================================================*/
int n_EcrireAno (int n_ano, char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_EcrireAno");

        fprintf(Kp_AnoFil,"%d~%s~%s~%s~%s~%s~%s~%s~%s\n",
                                n_ano,
                                Ksz_UWGRP_CF,
                                ptb_InRec_Cur[PRE_CTR_NF],
                                ptb_InRec_Cur[PRE_SEC_NF],
                                ptb_InRec_Cur[PRE_UWY_NF],
                                ptb_InRec_Cur[PRE_ACY_NF],
                                ptb_InRec_Cur[PRE_ACMTRS_NT],
                                ptb_InRec_Cur[PRE_CUR_CF],
                                ptb_InRec_Cur[PRE_SSD_CF]
                                );  

        RETURN_VAL (0);
}


/**************************************************************************/
/***                                                                    ***/
/*** Objet :    Copie le contenu du fichier en entree dans un tableau   ***/
/***                                                                    ***/
/*** Nom:       n_ChargerPilot                                          ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***            Le pointeur du fichier                                  ***/
/***            Le tableau de structures                                ***/
/***                                                                    ***/
/*** Retour:                                                            ***/
/***            0                                                       ***/
/***                                                                ***/
/**************************************************************************/
int n_ChargerPilot()
{
        int n_EOF = 0;
        T_LIFDRI_ALL bd_Lu;
        char MsgAno[300];

        DEBUT_FCT("n_ChargerPilot");

        if ( n_OpenFileAppl ("ESTC2035_I3","rb",&Kp_PilotIFil) == ERR )
                ExitPgm ( ERR_XX , "" );


        Kn_NbLigPilot=0;
        /* Tant que la fin de fichier n'est pas atteinte,... */
        while ( n_EOF == 0 )
        {
                /* ... lecture d'une ligne dans le fichier. */
                if ( fread(&bd_Lu,sizeof(T_LIFDRI_ALL),1,Kp_PilotIFil) <= 0 )
                        /* Fin de fichier, mise a jour du flag */
                        n_EOF = 1;
                else {
                        /* Ecriture dans log si depassement du tableau */
                        if ( Kn_NbLigPilot >= NB_MAX_PILOT) {
                                sprintf(MsgAno,"The number of Driving records  (/CTR %s /SEC %d /UWY %d) overflows the program's storage capacity",
                                        bd_Lu.CTR_NF,
                                        bd_Lu.SEC_NF,
                                        bd_Lu.UWY_NF);
                                n_WriteAno(MsgAno);
                                RETURN_VAL(ERR);
                        }

                        /* Enregistrement ecrit dans le tableau */
                        Kbd_PILOT[Kn_NbLigPilot++] = bd_Lu;
                        /* affiche (&bd_Lu);*/
                }
        }

        RETURN_VAL (0);
}


/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere sur contrat/section
==============================================================================*/
int n_ActionFirstRuptPrevision ( char **ptb_InRec_Cur)
{

    DEBUT_FCT("n_ActionFirstRuptPrevision");

    //printf("Rupt 1 CTR/SEC %s/%s\n",     ptb_InRec_Cur[PRE_CTR_NF], ptb_InRec_Cur[PRE_SEC_NF]);

    /* Initialisation du code crible */
    //  Kc_crible = ' ';
    Kc_crible = 'O';

    if ( strcmp(Ksz_Ctr_Prec,ptb_InRec_Cur[PRE_CTR_NF]) != 0 )
    {
        // SBE 07/05/2014 Reinitialisation de la devise par défaut. Si ligne non trouvée dans périmetre. Pour ne pas avoir la devise du contrat précédent
        strcpy(Ksz_devise,ptb_InRec_Cur[PRE_CUR_CF]);
        // SBE 07/05/2014 Reinitialisation du Kn_etat. Si ligne non trouvée dans périmetre. Pour ne pas avoir le Kn_etat du contrat précédent
        Kn_etat = 0;
        Kn_etatRet = 0;
        strcpy(Kc_typCtr, "MMM");
        strcpy(Ksz_Ctr_Prec,ptb_InRec_Cur[PRE_CTR_NF]);
    }

    /* Initialisation de UWGRP_CF si le perimetre ne participe pas */
    //strcpy(Ksz_UWGRP_CF,"absente");
    strcpy(Ksz_UWGRP_CF , "absente");
    
    Kb_rupt1 = 1;
    
    RETURN_VAL(OK);
}



/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere sur exercice
==============================================================================*/
int n_ActionFirstRuptPrevisionEx ( char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionFirstRuptPrevisionEx");

       /* 
		printf("Rupt 2 CTR/SEC/EX %s/%s/%s\n",   ptb_InRec_Cur[PRE_CTR_NF],
                                                 ptb_InRec_Cur[PRE_SEC_NF],
                                                 ptb_InRec_Cur[PRE_UWY_NF]);

        Kb_rupt2=1;
*/
        /* Synchronisation du fichier perimetre pour cette ligne */
        n_ProcessingRuptureSyncVar (&bd_RuptPerim, ptb_InRec_Cur);

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere CTR/SEC/UWY/ACY/ACMTRS/TRNCOD/GAAP
==============================================================================*/
int n_ActionFirstRuptPrevisionGaap ( char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstRuptPrevisionEx");

    if ( Kb_SyncPeri == 0 )
    {
        n_WriteCols(Kp_Prev5Fil,ptb_InRec_Cur,SEPARATEUR,0);
    }
    RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du perimetre synchronisee
        avec les previsions

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerim(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
        int Kn_status, Kn_status1 ;

        DEBUT_FCT("n_ActionLignePerim");

        Kb_SyncPeri = 1;

		memset(Ksz_accadmtyp , 0 , sizeof(Ksz_accadmtyp));
		memset(Ksz_accsts , 0 , sizeof(Ksz_accsts));
		memset(Ksz_ced , 0 , sizeof(Ksz_ced));
		memset(Ksz_lob , 0 , sizeof(Ksz_lob));
		memset(Ksz_brk , 0 , sizeof(Ksz_brk));
		memset(Ksz_pay, 0 , sizeof(Ksz_pay));
		memset(Ksz_ganpayord , 0 , sizeof(Ksz_ganpayord));
		memset(Ksz_lifdrityp , 0 , sizeof(Ksz_lifdrityp));
		memset(Ksz_UWGRP_CF , 0 , sizeof(Ksz_UWGRP_CF));
		memset(Ksz_devise, 0, sizeof(Ksz_devise));
		memset(Ksz_nature , 0 , sizeof(Ksz_nature));
		memset(Ksz_esb , 0 , sizeof(Ksz_esb));
		memset(Ksz_uwgrp , 0 , sizeof(Ksz_uwgrp));
		memset(Kc_typCtr, 0 , sizeof(Ksz_uwgrp));

        Kn_DernierEx            = atoi(ptb_InRecChild[PER_UWY_NF]);
        Kn_TypeComptable        = atoi(ptb_InRecChild[PER_ACCADMTYP_CT]);
        Kn_status               = atoi(ptb_InRecChild[PER_SECSTS_CT]);
	      Kn_status1                = atoi(ptb_InRecChild[PER_CTRSTS_CT]);
        Kn_etat                 = atoi(ptb_InRecChild[PER_SECACCSTS_CT]);

        Kn_etatRet              = atoi(ptb_InRecChild[PER_TERCTR_B]);
        strcpy(Kc_typCtr, ptb_InRecChild[PER_CTRTYP_CT]);

        /* Modif Anb le 13/12/99 */
		/* Prise en compte de la rétrocession */

		/*if ( (Kn_status==18) || (Kn_status==19) )
                Kb_Resilie = TRUE;
        else    Kb_Resilie = FALSE;*/

		if ( Kn_status==19 )
        	Kb_Resilie = TRUE;
        else
			if ( (Kn_status ==0 ) & (Kn_status1==19) )
				Kb_Resilie = TRUE;
			else
				Kb_Resilie = FALSE;

        /* Memorisation, traitement devise */
		// remise a zero des champs avant copie
		//memset(Ksz_devise, 0, sizeof(Ksz_devise));
		//memset(Ksz_UWGRP_CF, 0, sizeof(Ksz_UWGRP_CF));

        strcpy(Ksz_devise,ptb_InRecChild[PER_PCPCUR_CF]);
        strcpy(Ksz_UWGRP_CF,ptb_InRecChild[PER_UWGRP_CF]);
        //copy_string(Ksz_devise,ptb_InRecChild[PER_PCPCUR_CF]);
        //copy_string(Ksz_UWGRP_CF,ptb_InRecChild[PER_UWGRP_CF]);

        /* Memorisation du code crible et de l'etat */
        Kc_crible = ptb_InRecChild[PER_ESTCRB_CT][0];
//        printf( "    ptb_InRecChild[PER_ESTCRB_CT] = %s; Kc_crible = %c \n ", ptb_InRecChild[PER_ESTCRB_CT] , Kc_crible);
//          strcpy(Kc_crible,ptb_InRecChild[PER_ESTCRB_CT][0];

        /* Memorisation de l'etablissement */
		strcpy(Ksz_esb, ptb_InRecChild[PER_ACCESB_CF]);
		strcpy(Ksz_nature,ptb_InRecChild[PER_NAT_CF]);
		strcpy(Ksz_lob , ptb_InRecChild[PER_LOB_CF]);
		strcpy(Ksz_uwgrp,ptb_InRecChild[PER_UWGRP_CF]);
		strcpy(Ksz_accadmtyp,ptb_InRecChild[PER_ACCADMTYP_CT]);
		strcpy(Ksz_ced,ptb_InRecChild[PER_CED_NF]);
		strcpy(Ksz_brk,ptb_InRecChild[PER_PRD_NF]);
		strcpy(Ksz_pay,ptb_InRecChild[PER_GENPRMPAY_NF]);
		strcpy(Ksz_ganpayord,ptb_InRecChild[PER_GANPAYORD_NT]);
		strcpy(Ksz_lifdrityp,ptb_InRecChild[PER_LIFTRTTYP_CF]);        
        
        //copy_string ( Ksz_esb, ptb_InRecChild[PER_ACCESB_CF]);

        //copy_string ( Ksz_nature, ptb_InRecChild[PER_NAT_CF]);
        //copy_string ( Ksz_lob, ptb_InRecChild[PER_LOB_CF]);
        //copy_string ( Ksz_uwgrp, ptb_InRecChild[PER_UWGRP_CF]);

/*        copy_string ( Ksz_accsts, ptb_InRecChild[PER_ACCSTS_CT]);*/
        //copy_string ( Ksz_accadmtyp, ptb_InRecChild[PER_ACCADMTYP_CT]);
        //copy_string ( Ksz_ced, ptb_InRecChild[PER_CED_NF]);
        //copy_string ( Ksz_brk, ptb_InRecChild[PER_PRD_NF]);
        //copy_string ( Ksz_pay, ptb_InRecChild[PER_GENPRMPAY_NF]);
        //copy_string ( Ksz_ganpayord, ptb_InRecChild[PER_GANPAYORD_NT]);
        //copy_string ( Ksz_lifdrityp, ptb_InRecChild[PER_LIFTRTTYP_CF]);


        /* JR 04/06/03 type calcul CNA */
        /* Memorisation du type calcul CNA */
        //copy_string ( Ksz_cnatyp, ptb_InRecChild[PER_CNATYP_CT]);
        strcpy( Ksz_cnatyp, ptb_InRecChild[PER_CNATYP_CT]);

//          printf( "  2:  ptb_InRecChild[PER_ESTCRB_CT] = %s; Kc_crible = %c \n ", ptb_InRecChild[PER_ESTCRB_CT] , Kc_crible);
        RETURN_VAL (OK);
}


/*==============================================================================
objet :
        fonction d'action si le perimetre n'existe pas
retour :
        OK ---> traitement correctement effectue
==============================================================================*/
int n_ActionPereSansFils(char **ptb_InRec)
{

    DEBUT_FCT("n_ActionPereSansFils");
    
    Kb_SyncPeri = 0;

    RETURN_VAL (OK);
}

/*==============================================================================
objet :
        fonction d'action si les prévisions n'existent pas
        On recopie les infos nécessaire dans structure prévisions de travail depuis les infos périmetre
retour :
        OK ---> traitement correctement effectue
==============================================================================*/
int n_ActionFilsSansPere(char **ptb_InRec)
{
    DEBUT_FCT("n_ActionFilsSansPere");

    n_ReconduirePilotagePerimetre(ptb_InRec);
    
    RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction d'ecriture d'un enregistrement LIFDRI depuis la structure Perimetre
retour :
        OK ---> traitement correctement effectue
        ------>
==============================================================================*/
int n_ReconduirePilotagePerimetre (char **ptb_InRec_Cur)
{
       // static int Kn_SyncPilot = 0;
        DEBUT_FCT("n_ReconduirePilotagePerimetre");

        /* reconduction de tous les LIFDRI correspondant au contrat/section */
        if (Kc_crible!='N')
        {
             /* Synchronisation du Pilotage pour cette ligne */
/*             printf("reconduction LIFDRI %s %s \n",
                                ptb_InRec_Cur[PRE_CTR_NF],
                                ptb_InRec_Cur[PRE_SEC_NF]):
  */
             while ((Kn_SyncPilot = n_RechPilotPerimetre(ptb_InRec_Cur,PER_CTR_NF,PER_SEC_NF,PER_UWY_NF,&Kn_SyncPilot))!=-1) { /* [014]*/
                                Kbd_PILOT[Kn_SyncPilot].UPD_NF=' ';
                                fwrite(&Kbd_PILOT[Kn_SyncPilot],
                                sizeof(T_LIFDRI_ALL),1,Kp_PilotOFil);
                                Kn_SyncPilot++ ;
                                Kn_SyncPilotSav = Kn_SyncPilot;

                        }
        } /* fin reconduction LIFDRI */

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction d'ecriture d'un enregistrement LIFDRI
retour :
        OK ---> traitement correctement effectue
==============================================================================*/
int n_ReconduirePilotage ( char **ptb_InRec_Cur)
{
        //static int Kn_SyncPilot = 0;

        DEBUT_FCT("n_ReconduirePilotage");
        /* reconduction de tous les LIFDRI correspondant au contrat/section */
        if (Kc_crible!='N')
        {
             /* Synchronisation du Pilotage pour cette ligne */
/*             printf("reconduction LIFDRI %s %s \n",
                                ptb_InRec_Cur[PRE_CTR_NF],
                                ptb_InRec_Cur[PRE_SEC_NF]);
  */
             Kn_SyncPilot=Kn_SyncPilotSav;
             //printf("Kn_SyncPilotSav :%d\n",Kn_SyncPilotSav);
             while ((Kn_SyncPilot = n_RechPilot(ptb_InRec_Cur,PRE_CTR_NF,PRE_SEC_NF,&Kn_SyncPilot))!=-1) { /*[014]*/
                                Kbd_PILOT[Kn_SyncPilot].UPD_NF=' ';
                                fwrite(&Kbd_PILOT[Kn_SyncPilot],
                                sizeof(T_LIFDRI_ALL),1,Kp_PilotOFil);
                                Kn_SyncPilot++ ;

                        }
        } /* fin reconduction LIFDRI */

        RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction d'ecriture d'une prevision dans le fichier adequat
retour :
        OK ---> traitement correctement effectue
==============================================================================*/
int n_ReconduirePrevision ( char **ptb_InRec_Cur)
{
	
    DEBUT_FCT("n_ReconduirePrevision");

	
	//[001]
//	if ( (ptb_InRec_Cur[PRE_ACMTRS_NT][3] == '4' ) || ((strcmp(ptb_InRec_Cur[PRE_DETTRNCOD_CF], "10360")==0) || (strcmp(ptb_InRec_Cur[PRE_DETTRNCOD_CF], "12600")==0)))
//	{
//		// on met de cote les liberations
//		n_WriteCols(Kp_PrevLibFil,ptb_InRec_Cur,SEPARATEUR,0);
//		RETURN_VAL (OK);
//	}

	if ( (ptb_InRec_Cur[PRE_ACMTRS_NT][3] == '4' ) )
	{ 
		// on met de cote les liberations
		n_WriteCols(Kp_PrevLibFil,ptb_InRec_Cur,SEPARATEUR,0);
		RETURN_VAL (OK);
	}
	
    if (Kn_etat==9 || ( strcmp(Kc_typCtr, "RET") == 0 && Kn_etatRet == 1 ) )
   	{
         ptb_InRec_Cur[PRE_ACCSTS_CT] = "9"; //[016] 
	    n_WriteCols(Kp_Prev3Fil,ptb_InRec_Cur,SEPARATEUR,0); //abir

    	RETURN_VAL (OK);
    }
    if   (atoi(ptb_InRec_Cur[PRE_ACY_NF]) <= Kn_annee)
	{
	    // Ajout ORICOD_LS = "TP si ORICOD_LS vide
	    if ( strcmp(ptb_InRec_Cur[PRE_ORICOD_LS],"") == 0)
	    {
	        ptb_InRec_Cur[PRE_ORICOD_LS]="TP";
	    }

	    n_WriteCols(Kp_Prev1Fil,ptb_InRec_Cur,SEPARATEUR,0);
        RETURN_VAL (OK);
    }

    n_WriteCols(Kp_Prev2Fil,ptb_InRec_Cur,SEPARATEUR,0);

    RETURN_VAL (OK);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrevision( char **ptb_InRec_Cur)
{
	double d_taux,d_montant;
	int exercice, annee_compte;
	//int n_liberation; 
	int n_poste;
    int result =0;
	//int b_Type5_Prime = FALSE; //  [013]
	char sz_montant[80];
	char sz_vide[4] ;
	char sz_annee_exe[5];
	char tmp[17];	
	

	DEBUT_FCT("n_ActionLignePrevision");

    /* printf("ActionLignePrevision...\n");  */

	annee_compte  = atoi(ptb_InRec_Cur[PRE_ACY_NF]);
	exercice      = atoi(ptb_InRec_Cur[PRE_UWY_NF]);
    memset(sz_vide , 0 , sizeof(sz_vide));
	memset(sz_annee_exe,0,sizeof(sz_annee_exe));

    sprintf(sz_annee_exe,"%d",  Kn_DernierEx);
    
	/* Suppression des non crible */
	if (Kc_crible == 'N') 
		{
			n_WriteCols(Kp_Prev4Fil,ptb_InRec_Cur,SEPARATEUR,0);
			RETURN_VAL (OK);
			
	  }
	/* Reconduction des pilotage en rupture 1ere sur contrat/section */
	/*if (Kb_rupt1 == 1) n_ReconduirePilotage (ptb_InRec_Cur); */
	if(b_IsRupture(&bd_RuptPrev,F1) == TRUE) n_ReconduirePilotage (ptb_InRec_Cur);
	
	/* Renseignement de la nature et de la LoB */

	ptb_InRec_Cur[PRE_NAT_CF] = sz_vide ;
	ptb_InRec_Cur[PRE_NAT_CF]=  Ksz_nature ;
	ptb_InRec_Cur[PRE_LOB_CF] = Ksz_lob;
	/*if (strlen(Ksz_nature)) 
	{
		ptb_InRec_Cur[PRE_NAT_CF]=  Ksz_nature ;
	}

	if (strlen(Ksz_lob) )
	{
	   ptb_InRec_Cur[PRE_LOB_CF] = Ksz_lob;
	}*/
	
	/* AJOUT 12/01/98 : ajout du champ UWGRP_CF dans les previsions */
	ptb_InRec_Cur[PRE_UWGRP_CF]= sz_vide;
	//if (strlen(Ksz_uwgrp))
	//{
		ptb_InRec_Cur[PRE_UWGRP_CF] = Ksz_uwgrp;
	//}

/* ptb_InRec_Cur[PRE_UWGRP_CF+1] = 0;
                              mis en commentaire jr suite a ajout colonne CNATYP_CT */

	/* AJOUT JR 04/06/03 : ajout du champ CNATYP_CT dans les previsions   */
	ptb_InRec_Cur[PRE_CNATYP_CT]= sz_vide;
	//if(strlen(Ksz_cnatyp))
		ptb_InRec_Cur[PRE_CNATYP_CT] =  Ksz_cnatyp;


/*        ptb_InRec_Cur[PRE_CNATYP_CT+1] = 0;  */

	/* AJOUT 20/01/98 : renseignement du code crible dans les previsions */
	
	Ksz_crible[0]= Kc_crible;
	Ksz_crible[1] = '\0';
	ptb_InRec_Cur[PRE_ESTCRB_CT] = Ksz_crible;


//04T005259~0~1~2011~1~2011
/*
     if ((strcmp(ptb_InRec_Cur[PRE_CTR_NF], "04T001957")==0) && (strcmp(ptb_InRec_Cur[PRE_UWY_NF] , "2002") ==0))
		{
				 printf("%s;  %s; %s; %s;%s;  %s; %s; %s;%s;  %s; %s; %s;%s;  %s; %s; %s;%s;  %s;\n",
				 ptb_InRec_Cur[1],
				 ptb_InRec_Cur[2],
				 ptb_InRec_Cur[3],
				 ptb_InRec_Cur[4],
				 ptb_InRec_Cur[5],
				 ptb_InRec_Cur[6],

				 ptb_InRec_Cur[7],
				 ptb_InRec_Cur[8],
				 ptb_InRec_Cur[9],
				 ptb_InRec_Cur[10],
				 ptb_InRec_Cur[11],
				 ptb_InRec_Cur[12],
				 ptb_InRec_Cur[13],
				 ptb_InRec_Cur[14],
				 ptb_InRec_Cur[15],
				 ptb_InRec_Cur[16],
				 ptb_InRec_Cur[17],
				 ptb_InRec_Cur[18]
				 
				 );
				printf("     \n");
		}		
       
	
*/
	/* AJOUT 21/01/98 : renseignement de l'etablissement dans les previsions */
	ptb_InRec_Cur[PRE_ESB_CF] = Ksz_esb;
	
	/* Ajout 29/01/98 : renseignement dans les previsions de */
	/* diverses infos provenant du perimetre */
/*        ptb_InRec_Cur[PRE_ACCSTS_CT] = Ksz_accsts;*/
	ptb_InRec_Cur[PRE_ACCADMTYP_CT] = Ksz_accadmtyp;
	ptb_InRec_Cur[PRE_CED_NF] = Ksz_ced;
	ptb_InRec_Cur[PRE_BRK_NF] = Ksz_brk;
	ptb_InRec_Cur[PRE_PAY_NF]  =Ksz_pay ;
	ptb_InRec_Cur[PRE_GANPAYORD_NT] = Ksz_ganpayord;
	ptb_InRec_Cur[PRE_LIFTRTTYP_CF] = Ksz_lifdrityp ;


	/* Conversion devise si difference */
	if (strcmp(ptb_InRec_Cur[PRE_CUR_CF],Ksz_devise)!=0)
	{
//            printf("Conversion %s => %s\t", ptb_InRec_Cur[PRE_CUR_CF], Ksz_devise); 
		/*if (Kb_rupt2) n_EcrireAno(A_ChmtDev,ptb_InRec_Cur);*/
		if(b_IsRupture(&bd_RuptPrev,F2) == FALSE) n_EcrireAno(A_ChmtDev,ptb_InRec_Cur);
    if (Kn_etat==9 || ( strcmp(Kc_typCtr, "RET") == 0 && Kn_etatRet == 1 ) )
		{
			n_ReconduirePrevision (ptb_InRec_Cur);
		}

		d_taux = d_GetTaux(Kp_CoursFil,(char)atoi(ptb_InRec_Cur[PRE_SSD_CF]),
		                    (short)Kn_annee,ptb_InRec_Cur[PRE_CUR_CF],Ksz_devise);

        result = n_FindTsubTRS(&SubTrsLigne,ptb_InRec_Cur[PRE_DETTRNCOD_CF]);
    
     		/* [009] */
		if (( d_taux != -1 ) && 
        (SubTrsLigne.TRSINPUTTYPE_CT==1))  // [012] quand le montant est changé dans les analytiques
		{                      //  
			d_montant = atof(ptb_InRec_Cur[PRE_ESTMNT_M]) * d_taux;
//			 	printf("Montant %s %lf\n", ptb_InRec_Cur[PRE_ESTMNT_M], d_montant); 
		sprintf(sz_montant,"%.3lf",d_montant);
		ptb_InRec_Cur[PRE_ESTMNT_M] = sz_montant;
		ptb_InRec_Cur[PRE_CUR_CF]  = Ksz_devise;
		ptb_InRec_Cur[PRE_LSTUPD_D] = sz_new_cre;
		//on remplacel le 23:59:04 par 23:59:05 
		if (ptb_InRec_Cur[PRE_LSTUPD_D][strlen(ptb_InRec_Cur[PRE_LSTUPD_D]) -1] =='M')
		{
			ptb_InRec_Cur[PRE_LSTUPD_D][ strlen(sz_new_cre)- 3 ] = '5';
		}
		else 
			ptb_InRec_Cur[PRE_LSTUPD_D][ strlen(sz_new_cre)- 2 ] = '5';

        //le batch charge la ligne dans le TLIFEST
        strcpy(ptb_InRec_Cur[PRE_BATCH_B],sz_batch); //[011]

		}

		else
			n_EcrireAno(A_ErrTaux,ptb_InRec_Cur);
			
	}

    if (Kn_etat==9 || ( strcmp(Kc_typCtr, "RET") == 0 && Kn_etatRet == 1 ) )
	{
		n_ReconduirePrevision (ptb_InRec_Cur);
		RETURN_VAL(OK);
	}
	/* Cas du type 1 */ /*   save modif jr 12/11/2003 */
//        if (Kn_TypeComptable == 1) {
//                if ( annee_compte > exercice )
//                {
//	                /*if (Kb_rupt2==1) n_EcrireAno(A_Type1,ptb_InRec_Cur); */
//	                if(b_IsRupture(&bd_RuptPrev,F2) == TRUE) n_EcrireAno(A_Type1,ptb_InRec_Cur);


//                    RETURN_VAL(OK);
//                }
//                else
//				{
//                	n_ReconduirePrevision (ptb_InRec_Cur);
//                	RETURN_VAL(OK);
//                }
//        }          /* fin save 12/11/2003
//Début [016]
	    if ( strcmp(ptb_InRec_Cur[PRE_UWY_NF], ptb_InRec_Cur[PRE_ACY_NF]) > 0)
	    {
	        n_WriteCols(Kp_ErrUpdBatchfil,ptb_InRec_Cur,SEPARATEUR,0);
	        RETURN_VAL(OK);
	    }
//fin [016]


	/* Cas du type 1 */
	if ((Kn_TypeComptable == 1) &&
	    ((atoi(ptb_InRec_Cur[PRE_ACMTRS_NT])%1000 == 303) ||
	     (atoi(ptb_InRec_Cur[PRE_ACMTRS_NT])%1000 == 304) ||
	     (atoi(ptb_InRec_Cur[PRE_ACMTRS_NT])%1000 == 323) ||
	     (atoi(ptb_InRec_Cur[PRE_ACMTRS_NT])%1000 == 324)))
	{
		n_ReconduirePrevision (ptb_InRec_Cur);
		RETURN_VAL(OK);
	}
	
	if (Kn_TypeComptable == 1) 
	{
		if ( annee_compte != exercice )
		{
			
			if(b_IsRupture(&bd_RuptPrev,F2) == TRUE) n_EcrireAno(A_Type1,ptb_InRec_Cur);
			/* [008] */
			memset(tmp,0, sizeof(tmp)); 

			// on copie ERR si cela n'est pas déjà dans le libellé, sinon on conserve le libellé tel que
			if(strncmp(ptb_InRec_Cur[PRE_ORICOD_LS], "ERR", 3)!=0)	
			{
				strcpy(tmp , "ERR ");
				strncat(tmp,ptb_InRec_Cur[PRE_ORICOD_LS],12);
				ptb_InRec_Cur[PRE_ORICOD_LS] = tmp; //LIBELLE_ERR_ORICOD;
			}
		    //n_ReconduirePrevision (ptb_InRec_Cur);
		    ptb_InRec_Cur[PRE_UWY_NF]=ptb_InRec_Cur[PRE_ACY_NF];
		    ptb_InRec_Cur[PRE_BALSHEY_NF]=Ksz_Balshey;
		    ptb_InRec_Cur[PRE_BALSHTMTH_NF]=Ksz_Balshtmth ;
		    //ptb_InRec_Cur[PRE_CRE_D]=sz_formated_cred;
		    strcpy(ptb_InRec_Cur[PRE_BATCH_B],sz_batch); // Ajout 08/01/2014 pour prise en compte nouveau champ PRE_BATCH_B dans la structure LIFEST
	        ptb_InRec_Cur[PRE_INDSUP_B]= "0";
		    //copy_string(ptb_InRec_Cur[PRE_ORICOD_LS] , LIBELLE_ORICOD);
		    //copy_string(ptb_InRec_Cur[PRE_LSTUPD_D], sz_new_cre) ;
		    ptb_InRec_Cur[PRE_LSTUPD_D]= sz_new_cre ;

		    ptb_InRec_Cur[PRE_LSTUPDUSR_CF]= DBO;
		    
		    
		    //############Ecrire cette ligne dans un fichier anomalies
		    //n_ReconduirePrevision (ptb_InRec_Cur);
		    n_WriteCols(Kp_ErrUpdBatchfil,ptb_InRec_Cur,SEPARATEUR,0);
			
			RETURN_VAL(OK);
		}
		else
		{
			n_ReconduirePrevision (ptb_InRec_Cur);
			RETURN_VAL(OK);
		}
	}
	
	/* Cas du type 2 */
	if (Kn_TypeComptable == 2)
	{
		if ( (exercice>Kn_DernierEx) && (Kb_Resilie==TRUE) )
		{
		   /*if (Kb_rupt2==1) n_EcrireAno(A_Type2,ptb_InRec_Cur); */
		   if(b_IsRupture(&bd_RuptPrev,F2) == TRUE) n_EcrireAno(A_Type2,ptb_InRec_Cur);

			/* [008] */

			memset(tmp,0, sizeof(tmp)); 

			// on copie ERR si cela n'est pas déjà dans le libellé, sinon on conserve le libellé tel que
			if(strncmp(ptb_InRec_Cur[PRE_ORICOD_LS], "ERR", 3)!=0)	
			{
				strcpy(tmp , "ERR ");
				strncat(tmp,ptb_InRec_Cur[PRE_ORICOD_LS],12);
				ptb_InRec_Cur[PRE_ORICOD_LS] = tmp; //LIBELLE_ERR_ORICOD;
			}

			//n_ReconduirePrevision (ptb_InRec_Cur);

			//sprintf(ptb_InRec_Cur[PRE_UWY_NF], "%d", Kn_DernierEx);
			ptb_InRec_Cur[PRE_UWY_NF] = sz_annee_exe;

			ptb_InRec_Cur[PRE_BALSHEY_NF]=Ksz_Balshey;
			ptb_InRec_Cur[PRE_BALSHTMTH_NF]=Ksz_Balshtmth;
			//ptb_InRec_Cur[PRE_CRE_D]=sz_formated_cred;
			strcpy(ptb_InRec_Cur[PRE_BATCH_B],sz_batch); // Ajout 08/01/2014 pour prise en compte nouveau champ PRE_BATCH_B dans la structure LIFEST
			ptb_InRec_Cur[PRE_INDSUP_B] ="0";
			ptb_InRec_Cur[PRE_ORICOD_LS] = LIBELLE_ORICOD;  // mettre 'UPD BATCH 2035' 
			ptb_InRec_Cur[PRE_LSTUPD_D] = sz_new_cre;
			ptb_InRec_Cur[PRE_LSTUPDUSR_CF]= DBO;
		    
		    //############Ecrire cette ligne dans un fichier anomalies
			//n_ReconduirePrevision (ptb_InRec_Cur);
			n_WriteCols(Kp_ErrUpdBatchfil,ptb_InRec_Cur,SEPARATEUR,0);
		}
		else
			n_ReconduirePrevision (ptb_InRec_Cur);
		RETURN_VAL(OK);
	}
	
	/* Cas du type 3 */
	if (Kn_TypeComptable == 3) 
	{
		n_poste = ( atoi(ptb_InRec_Cur[PRE_ACMTRS_NT]) / 100 ) % 10;
		/* si type comptable 3, Ac>exercice et poste prime, ecrire une anomalie et pas de prevision */
		
		if ( annee_compte > exercice && n_poste!=2 &&                 // [013]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1160") != 0 &&     // [007]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1903") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1913") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1923") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1933") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1943") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1963") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1303") != 0 &&     // [007]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1323") != 0 &&     // [007]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1340") != 0 &&     // [007]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1011") != 0 &&     // [013]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2160") != 0 &&     // [007]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2903") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2913") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2923") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2933") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2943") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2963") != 0 &&     // [019]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2303") != 0 &&     // [007]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2323") != 0 &&     // [007]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2340") != 0 &&     // [007]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1523") != 0 &&     // [002]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2523") != 0 &&     // [002]
		     strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2011") != 0 )      // [013]
		{
	
			/* if (Kb_rupt2==1) n_EcrireAno(A_Type3,ptb_InRec_Cur); */
			if(b_IsRupture(&bd_RuptPrev,F2) == TRUE) n_EcrireAno(A_Type3,ptb_InRec_Cur);

			/* [008] */
			memset(tmp,0, sizeof(tmp)); 

			// on copie ERR si cela n'est pas déjà dans le libellé, sinon on conserve le libellé tel que
			if(strncmp(ptb_InRec_Cur[PRE_ORICOD_LS], "ERR", 3)!=0)	
			{
				strcpy(tmp , "ERR ");
				strncat(tmp,ptb_InRec_Cur[PRE_ORICOD_LS],12);
				ptb_InRec_Cur[PRE_ORICOD_LS] = tmp; //LIBELLE_ERR_ORICOD;
			}

			//n_ReconduirePrevision (ptb_InRec_Cur);
			ptb_InRec_Cur[PRE_UWY_NF]=ptb_InRec_Cur[PRE_ACY_NF];

			ptb_InRec_Cur[PRE_BALSHEY_NF]=Ksz_Balshey;
			ptb_InRec_Cur[PRE_BALSHTMTH_NF] = Ksz_Balshtmth;
			//ptb_InRec_Cur[PRE_CRE_D] = sz_formated_cred;
			strcpy(ptb_InRec_Cur[PRE_BATCH_B],sz_batch); // Ajout 08/01/2014 pour prise en compte nouveau champ PRE_BATCH_B dans la structure LIFEST
			ptb_InRec_Cur[PRE_INDSUP_B]= "0";
			ptb_InRec_Cur[PRE_ORICOD_LS] = LIBELLE_ORICOD;  // mettre 'UPD BATCH 2035' 
			ptb_InRec_Cur[PRE_LSTUPD_D] = sz_new_cre;
			ptb_InRec_Cur[PRE_LSTUPDUSR_CF]= DBO;

		    //############Ecrire cette ligne dans un fichier anomalies
			//n_ReconduirePrevision (ptb_InRec_Cur);
			n_WriteCols(Kp_ErrUpdBatchfil,ptb_InRec_Cur,SEPARATEUR,0);
		}
		else
			n_ReconduirePrevision (ptb_InRec_Cur);
		RETURN_VAL(OK);
	}
	
	/* Cas des types 4 et 5 */
	if ( (Kn_TypeComptable == 4) || (Kn_TypeComptable == 5) ) // [013]
	{
		if ( (exercice > Kn_DernierEx) && (Kb_Resilie==TRUE) )
		{
			
			if(b_IsRupture(&bd_RuptPrev,F2) == TRUE)  n_EcrireAno(A_Type45,ptb_InRec_Cur);

			memset(tmp,0, sizeof(tmp)); 

			// on copie ERR si cela n'est pas déjà dans le libellé, sinon on conserve le libellé tel que
			if(strncmp(ptb_InRec_Cur[PRE_ORICOD_LS], "ERR", 3)!=0)	
			{
				strcpy(tmp , "ERR ");
				strncat(tmp,ptb_InRec_Cur[PRE_ORICOD_LS],12);
				ptb_InRec_Cur[PRE_ORICOD_LS] = tmp; //LIBELLE_ERR_ORICOD;
			}

			ptb_InRec_Cur[PRE_UWY_NF] = sz_annee_exe;

			ptb_InRec_Cur[PRE_BALSHEY_NF]=Ksz_Balshey;
			ptb_InRec_Cur[PRE_BALSHTMTH_NF]=Ksz_Balshtmth;
			strcpy(ptb_InRec_Cur[PRE_BATCH_B],sz_batch); // Ajout 08/01/2014 pour prise en compte nouveau champ PRE_BATCH_B dans la structure LIFEST
			ptb_InRec_Cur[PRE_INDSUP_B] ="0";
			ptb_InRec_Cur[PRE_ORICOD_LS] = LIBELLE_ORICOD;  // mettre 'UPD BATCH 2035' 
			ptb_InRec_Cur[PRE_LSTUPD_D] = sz_new_cre;
			ptb_InRec_Cur[PRE_LSTUPDUSR_CF]= DBO;

			//############Ecrire cette ligne dans un fichier anomalies
			n_WriteCols(Kp_ErrUpdBatchfil,ptb_InRec_Cur,SEPARATEUR,0);
		}
		else
		{
			n_ReconduirePrevision (ptb_InRec_Cur);
		}
		RETURN_VAL(OK);
	}
		
	RETURN_VAL(OK);
}


/*==========================================================================
     Objet :    Initialisation de la structure TRS

     Nom:       init_SubTrsLigne

     Parametres:
               

     Retour:    0
===========================================================================*/
void init_SubTrsLigne() //[012]
{
      
          strcpy(SubTrsLigne.DETTRNCOD_CF, "");
          strcpy(SubTrsLigne.SUBTRS_GL,"");
					strcpy(SubTrsLigne.SUBTRS_GS,"");
					strcpy(SubTrsLigne.SUBTRSEXP_D,""); 
					strcpy(SubTrsLigne.SUBTRSINC_D,"");
					SubTrsLigne.CMT_NT =0;
					SubTrsLigne.TRSINPUTTYPE_CT = 0;
					SubTrsLigne.TRSNATURE_CT = 0 ;
					strcpy(SubTrsLigne.LOGSIG_CT,"");
					strcpy(SubTrsLigne.LOB_CF,"");
					SubTrsLigne.TRSTYPE_CT = 0; 
					SubTrsLigne.TRSPURERETRO_B = 0;
					SubTrsLigne.DACTYPE_B   = 0;
					SubTrsLigne.COMPLEMENT_B = 0;
					SubTrsLigne.NEWBALSHEETPROPAG_B = 0;
					SubTrsLigne.CELLPROTECEXC_B = 0;
                            
}

/*
	Fonction permettant le formattage d'une valeur dans une colonne

*/
char * FormattedDate(char * date2format, char* buffer)
{


//struct tm
//{
//    int tm_sec;       /* secondes (0,59) */
//    int tm_min;       /* minutes (0,59) */
//    int tm_hour;      /* heures depuis minuit (0,23) */
//    int tm_mday;      /* jour du mois (0,31) */
//    int tm_mon;       /* mois depuis janvier (0,11) */
//    int tm_year;      /* années écoulées depuis 1900 */
//    int tm_wday;      /* jour depuis dimanche (0,6) */
//    int tm_tm_yday;   /* jour depuis le 1er janvier (0,365) */
//    int tm_isdst;
//};

  // date fournie : "20130625 23:59:04"
  // en sortie    :  "Jun 25 2013 23:59:04" 	
  time_t rawtime;
  struct tm * timeinfo;

  time(&rawtime);
  timeinfo=localtime( &rawtime);
//  memset(timeinfo,0, sizeof(timeinfo)); 
  timeinfo->tm_sec= atoi(date2format+15);
  timeinfo->tm_min= atoi(Left(date2format+12,2));
  timeinfo->tm_hour= atoi(Left(date2format+9,2)); 
  timeinfo->tm_mday= atoi(Left(date2format+6,2));
  timeinfo->tm_mon= atoi(Left(date2format+4,2))-1;
  timeinfo->tm_year= atoi(Left(date2format,4))-1900;
    
   mktime( timeinfo);	

  strftime (buffer,25,"%h %e %Y %X%p",timeinfo);
  return (buffer);

}



/*
	Fonction de traitement de chaine de caractère
	renvoie les n(pos) premiers caractères de gauche de la chaine fournit en paramètre
*/ 

char * Left(char * str, int pos)
{
    int i;
    char * temp = NULL;
	if( str !=NULL)
	{
		temp = malloc(sizeof(char) * (pos+1));
    	for(i = 0; i < pos; i++)
    	{
        	temp[i]= str[i];
    	}
		temp[pos]='\0';
	}

    return temp;
}

/*void copy_string(char *target, char *source)
{
  int taille = strlen(source);
  if (taille)
  {
  strncpy(target, source, taille);
  }
  else
  		target='\0';
}*/




