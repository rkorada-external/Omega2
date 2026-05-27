/*==============================================================================
nom de l'application          : Prise en compte des AS pour les previsions
nom du source                 : ESTC2038.c
revision                      : $Revision: 1.9 $
date de creation              : 24/06/1997
auteur                        : C. Chavatte
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa>   <auteur>    <description de la modification>
 15/11/1999	    ANB			Le top maj auto est à 0 par défaut en rétrocession
 04/06/2003	    J. RIBOT		prise en compte du CNATYP_CT
 02/09/2003     J. RIBOT    ajout ACMTRS2_NT dans T_CleGT pour gerer les postes pna far rec
 05/02/2004     j. RIBOT    ne pas faire ex +1 sur liberation de depot
 13/01/2005     j. RIBOT    modif cre_d ARRETE STAT a "23:59:11" et "23:59:12"
 01/06/2006     j. Ribot    suppression mis en commentaire des lignes suivantes
          if (Kn_SyncPilot>=0)
                Kb_AUTUPD=Kbd_PILOT[Kn_SyncPilot].AUTUPD_B;
          else
    qui generent des AS a tord dans ESTIMATION

 16/06/2006     J. Ribot  Spot 12929  save du poste quand GT sans PREV pour generer les 1063 ou 2063
 27/03/2008     J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
---------------
 14/05/2008   [009]     ESTVIE15401 Agrandissement d'un tableau en mémoire
                        agrandissement de NB_MAX_PILOT 20000 => 40000
_________________
MODIFICATION    [010]
Auteur:         D.GATIBELZA
Date:           20/08/2009
Version:        9.1
Description:    ESTVIE17917 la VOBA se comporte de de la même façon à Paris que les CNA manuelle de type 1 (CNATYP_CT = 1 ou 2)
_________________
MODIFICATION    [011]
Auteur:         JF VDV
Date:           07/12/2009
Version:        9.1
Description:    [17950] - Forcer heures,minutes,secondes dans la date du jour qui alimente la date de creation
_________________
MODIFICATION    [012]
Auteur:         D.GATIBELZA
Date:           28/07/2010
Version:        10.1
Description:    ESTVIE18754 Creation ligne fds egal. stab dans onglet Primes ( pour tout et tous )
                faire le 1093 en dupliquant comme le 1063 et le 1094 comme le 1064
_________________
MODIFICATION    [013]
Auteur:         JF-VDV
Date:           02/09/2010
Version:        10.1
Description:   [18754] Creation ligne fds egal. stab dans onglet Primes ( pour tout et tous )
                faire le 1543 en dupliquant comme le 1093 et le 2543 comme le 2093
_________________
MODIFICATION    [014]
Auteur:         D.GATIBELZA
Date:           04/10/2010
Version:        10.1
Description:    ESTVIE19177 V10 Mettre en place un calcul spécial de DAC
c
MODIFICATION    [015]
Auteur:         D.GATIBELZA
Date:           09/11/2010
Version:        10.1
Description:    ESTVIE20655 Agrandissement d'un tableau en mémoire:
                NB_MAX_PILOT 40000 => 100000
_________________
[016] Florent  06/09/2011 :spot:22315 corrections gestion des libérations
_________________
MODIFICATION    [017]
Auteur:         S.BEHAGUE
Date:           14/01/2014
Version:        10.1
Description:    Changement rupture sur ACMTRS en rupture sur DETTRNCOD. Modification fonction n_SyncGT et structure T_CleGT.
								Ajout traitement multigaap.
								
Le programme prend un fichier de prévisions et le fichier de comptabilité en entrée.
 
Le fichier père est le fichier comptabilité. Les ruptures sur ce fichier sont effectuées sur CTR_NF, SEC_NF, UWY_NF, ACY_NF
Le fichier fils est le fichier des prévisions. La synchronisation se fait sur CTR_NF, SEC_NF, UWY_NF, ACY_NF et DETTRNCOD sur le GAAP 0.

3 cas de traitement :

-> Cas 1 : Une ligne de prévision correspond à une ligne de comptablilité. Synchronisation sur CTR_NF, SEC_NF, UWY_NF, ACY_NF .
		On affine la synchronisation sur le DETTRNCOD.
		Si le montant sur le GAAP 0 est différent du montant dans le fichier comptablité et si le flag COMACIMPACT_B est postionné à 1.
		Ce flag est présent dans le fichier FSUBTRSESBPROP
		On recrée la ligne de prévision en mettant à jour le montant du GAAP 0 avec le montant du fichier comptablilité.
		Les montants des autres lignes de GAAP pour ce même DETTRNCOD sont mis à jour en étant calculés à partir du montant modifié en GAAP 0 et du GAAP_DIF. 
		Le GAAP_DIF sera toujours identique.
	

-> Cas 2 : Une ligne comptablilité n'a pas de ligne de prévision correspondante ( PereSansFils : GTsansPrev )
		Une ligne de prévision est créée pour chaque poste (DETTRNCOD) sur un GAAP 0 si le flag COMACIMPACT_B est postionné à 1.
		ou sur un GAAP accessible au poste si le poste du fichier comptabilité n'est pas présent en GAAP 0.

-> Cas 3 : une ligne de prévision n'a pas de ligne de comptablilité correspondante ( FilsSansPere : PrevSansGT )
		La prévision est écrasée en mettant le montant à 0 si le le flag COMACIMPACT_B est postionné à 1
_________________
MODIFICATION    [018]
Auteur:         M.MECHRI
Date:           05/06/2014
Version:        10.1
Description:    Modification de la condition pour annuler les montants en cas de multigaap pour poste cash
                Changement de condition Initialisation
_________________
                MODIFICATION    [019]
Auteur:         S.BEHAGUE
Date:           07/07/2014
Version:        10.1
Description:    spot:25773 Modification of parameters of n_RechSUBTRSESBPROP function
[001] 18/07/2014 ABJ :spot:25773 Correction de la cre_d.
[002] 01/12/2014 SBE :Ré-implémentation traitement voba/dac
[003] 30/01/2015 SBE :spot 28179 - Activation traitement réserve
[004] 20/03/2015 SBE :spot 28476 - Traitement poste 42000 
[005] 26/03/2015 SAS : spot: 28512 - SGLA02 les postes analytics, 1217, 1233, 1465,1598, 1616
[006] 19/05/2015 SBE :spot 28476 - Traitement poste réserve idem poste 42000
[007] 06/08/2015 MMECHRI :spot 28476 - Traitement poste réserve
[008] 24/08/2014 MMECHRI : - Desactivation de traitement de propagation
[009] 28/08/2015 SBE :spot:29253: TAC02B poste analytique compta
[010] 16/11/2015 SBE :spot 29686 - Réactivation traitement poste réserve - Spira 34950
[011] 09/02/2016 SBE :spot 30155:Mise à jour flag compte complet dans TLIFDRI dans le cas où AutoUpd égal 0 (spira 45559) Acceptation seulement
[012] 25/02/2016 SBE :spot 30257:Modification traitement particulier poste réserve - Spira 49181
[013] 07/06/2016 SBE :spot:30300 EST39 
[014] 18/10/2016 SBE :spot:31343 - Spira 30649 - Propagation Réserves
[015] 29/11/2016 MMA :SPIRA 30649 - Attribution d'une seconde pour CreationReserveAna
[016] 19/01/2017 DFI :SPIRA 49155 - Activation de la propagation des réserves pour les estimations sans compta
[017] 10/10/2018 SBE  spira:30649: Batch: Fixed - INCIDENT IN RESERVES PROPAGATION FROM TAC AFTER COMPLETE ACCOUNT
[018] 30/01/2019 SBE :REQ.L.02.05: Evolution quarterly
[020] 10/07/2019 BEL :Spira 77276.
[021] 19/08/2019 BEL :Spira 79098.
[022] 29/01/2020 BEL :Spira 82973.
[023] 27/07/2020 BEL :Spira 88780: cherhcer dans tout le fichier LIFDRI.
==============================================================================*/
//#define TRACE_1

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

static char VERSION_ESTC2038_C[100] = "ESTC2038 version [018] - Spira 30649 + quarterly";
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
/*#define NB_MAX_PILOT    100000   //[015] / [009] */

/* ajout 12/01/98 */
// OMEGA2 B  : on va garder les define de struct.h 
//#define PRE_NBCOLNEW    38 /* passe a 38 jr 04/06/03 */
//#define PRE_UWGRP_CF    36
//#define PRE_CNATYP_CT   37 /* jr ajout 04/06/03 */

/*----------------------------------------------*/
/* Structure utilisee pour stocker la cle du GT */
/*----------------------------------------------*/
/* Modifications SBE 14/01/2014   
              */

#define GT_ACM_NF 74

typedef struct {
        int ACMTRS_NT; 
        int TRNCOD_CF;
        char AMT_M[25];
        int ACMTRS2_NT;            // jr 02/09/2003 pour gerer les postes pna far rec
        int TRNCOD_CF2;
        char TypePoste[4];
} T_CleGT;

/* Modifications SBE 14/01/2014                     */
/* Ajout structure pour stocker les différents GAAP */
/* du niveau DETTRNCOD. On va créer ensuite un      */
/* tableau sur cette strucure                       */
typedef struct {
				char 		ACMTRS[5];
				char 		DETTRNCOD[6];
				char 		GAAP[2];
				double 	ESTMNT_M;
				double 	GAAP_DIFF;
} T_DetGaap;

typedef  struct {
        int ACMTRS_NT; 
        int DETTRNCOD_CF;
        int GAAP_NT;
        char AMT_M[25];
        char GAAPDIFF_M[25];
        char RESERVE_M[25];
        int  FlagFirst;
        int  FlagLast;
        int  InputTyp;
} T_SavPrev ;

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE       *Kp_PilotIFil,               // Pointeur sur le fichier pilotage en entree
           *Kp_PilotOFil,               // Pointeur sur le fichier pilotage en sortie
           *Kp_PrevOFil,                // Pointeur sur les previsions en sortie
		       *Kp_AscPilotOFil,            // Pointeur sur le fichier ASSCI pilotage en sortie
		       *Kp_ReserveNoAccOFil,				// Pointeur sur le fichier Reserve NOACC en sortie
		       *Kp_ReserveOFil,							// Pointeur sur le fichier Reserve en sortie
		       *Kp_EsBpropIFil,							// Pointeur sur le fichier FSUBTRSESBPROP SBE 22/01/2014
		       *Kp_SubTRSAssoFil,           // Pointeur sur le fichier  
		       *Kp_SubTRSFil;          			// pointeur sur le fichier
		       
T_LIFDRI_ALL_QUARTER    Kbd_PILOTD[NB_MAX_PILOT];    // Fichier pilotage charge en memoire
int         Kn_NbLigPilot,              // Nombre de lignes dans le fichier pilotage
            Kn_SyncPilot;               // =-1 si le fichier pilotage n'est pas synchronise,
                                        // numero de la ligne synchronisee sinon
T_LIFDRI_ALL_QUARTER   *Kpbd_CPPILOT=NULL;	        // Tableau des complement PILOT
int         Kn_NbLigCPPilot=0;          // nombre de complement PILOT

T_SUBTRSESBPROP Kbd_SUBTRSESBPROP_old[5000];			// fichier FSUBTRSESBPROP chargé en mémoire SBE 22/01/2014
int  				Kn_NbLigSUBTRSESBPROP=0;		// Nombre de lignes dans le fichier FSUBTRSESBPROP

T_SUBTRSASSO SubTrsAssoLigne;						// Structure Association
T_SUBTRS     SubTrsLigne;
T_SUBTRSESBPROP SubTrsEsBprop;					// Structure EsBprop

T_RUPTURE_VAR       bd_RuptGT;          // gestion rupture sur GT
T_RUPTURE_SYNC_VAR  bd_RuptPrev;        // gestion synchro c. previsions-GT
int                 Kb_SyncPilot,       // Indicateur de synchro. du fichier pilotage
                    Kb_SyncPrev,        // Indicateur de synchro. du fichier previsions
                    Kb_AUTUPD,          // Indicateur de MAJ automatique
                    Kb_PropaReserve;		// indicteur de propagation
CS_TINYINT  Kn_FinPer,                  // Mois de fin de periode d'envoi
            Kn_Period;                  // Periodicite d'envoi des provisions
T_CleGT     Kbd_CleGT[150];              // Tableau des postes cumul de la rupture
int         Kn_CleGT=0;                 // Nombre de lignes dans ce tableau 
T_DetGaap	Kbd_DetGaap[6];							// Tableau pour le multi gaap 			SBE 14/01/2014
int			Kn_NbGaap=0;								// Nombre de lignes dans ce tableau SBE
int         i_ana=0;
int         flag_ana=0;

char        Ksz_DateJour[11];           // Date de traitement
int         Kn_BalYear,
            Kn_BalMonth,
            Kn_NbYear;

char        Ksz_Balshey[6],
            Ksz_Balshtmth[6],
            Ksz_NbYear[2];
char 		psz_SavLignePrevPrecedente[PRE_NBCOL+1][25];
T_SavPrev   Kbd_Analytic[150];

double		Kn_SavMontantGtSansPrev;
int         n_FlagFirst = 0;

double      Kf_PnaFarRec5,  /* Cumul des constitutions PNA, FAR et REC (x5xx) */
            Kf_PnaFarRec6;  /* Cumul des constitutions PNA, FAR et REC (x6xx) */
int         Kb_PnaFarRec5,  /* Indique si on a vu passer du PNA, FAR ou REC */
            Kb_PnaFarRec6;
int			Kb_FinSynchro=0; /* SBE indicateur de fin de synchro */
int 		LIFDRI_COMACC_B = 0; // [021]
double		Kf_Montant,Kf_MontantPrec,Kf_MontantGaap0GT,Kf_MontantGaap0Prev;			/* Montant pour Gaap */
char		Kz_DETTRNCOD_prec[6]="DETRN", Kz_PRE_UWY_NF_prec[5]="YYYY", Kz_PRE_ACY_NF_prec[5]="YYYY", Kz_PRE_CTR_N_prec[10]="CTRAAABBB", Kz_PRE_ACM_NF_prec[3]="MM";
char 		Ksz_MontantReserve[25];
int         ksz_indexPilot = 0; // Index pour RechPilot5000

int flag_Gaap =0;
int n_ChargerPilot();
int n_ChargerSUBTRSESBPROP_old();
int n_EcrireASCCPLLIFDRI();
double Arrondi(double);

void sav_LignePrevPrecedente(char ** pbd_LignePrev);
int  sav_MntPrevGaapCedente(int flag );
void sav_LignePrevAnalytic(char ** pbd_LignePrev, int Flag, int InputTyp);
void EcrireFlagLastAnalytic();

int n_InitPrev(T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePrev(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ConditionSyncPrev(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ActionPrevSansGT(char **ptb_InRecOwner);
int n_ActionGTsansPrev(char **ptb_InRecOwner);
int n_IsR1Prev(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ActionLastRuptPrev(char **ptb_InRec, char **ptb_InRec_Cur);

int n_InitGT(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLigneGT(char **pbd_InRec_Cur);
int n_IsR1GT(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLastRuptGT ( char **ptb_InRec_Cur);
void MemoGT (char **ptb_InRec);
int n_SyncGT(char *DETTRNCOD);

void CreationPrevision(char c_origine,char *AMT_M,char **ptb_InRec, char *sz_date, char *GAAP, char *GAAPDIFF, char *sz_regle);
void CreationLiberation(char c_origine, char *ACMTRS_NT, double AMT_M, char **ptb_InRec, char *sz_date, char *sz_dettrncod, char *GAAP, char *GAAPDIFF);

void CreationReserve(char c_origine,char *AMT_M,char **ptb_InRec, char *sz_date, char *GAAP, char *GAAPDIFF, char *sz_regle);
void CreationReserveAna(char c_origine,char *AMT_M,char **ptb_InRec, char *sz_date, char *GAAP, char *GAAPDIFF, char *sz_regle);

int n_RechPilot (char *sz_ctr, char *sz_sec, char *sz_acy);

void init_SubTrsAssoLigne();
void init_SubTrsLigne();
void init_SubTrsEsBprop();
int n_GaapInterdit( int , T_SUBTRSESBPROP * );

int n_AddCPLIFDRI(T_LIFDRI_ALL_QUARTER *pbd_new) ;
int n_EcrireCPLLIFDRI();


int n_FillLifdriQuarter(FILE *Kp_InputPilot);
// ==== Nouvelles fonctions recherche LIFDRI format QUARTERLY
//int n_ChargerPilot7000(FILE *Kp_InputPilot);
//int n_RechPilot7000 (char **ptb_struct, int CTR_NF ,int SEC_NF, int ACY_NF, int ACM_NF, int *index);
// ====

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
    /* Initialisation des signaux */
    char sz_date[11];
    
    InitSig () ;

    if ( n_BeginPgm (argc  ,argv) == ERR )
        ExitPgm ( ERR_XX , "" );

    // Recuperation des parametres et calcul des zones qui en decoulent
    strcpy(Ksz_Balshey,   psz_GetCharArgv(1));
    strcpy(Ksz_Balshtmth, psz_GetCharArgv(2));
    strcpy(Ksz_DateJour,  psz_GetCharArgv(3));
    strcpy(Ksz_NbYear,  psz_GetCharArgv(4));
    
	strcpy(sz_date,Ksz_DateJour);
    sz_date[4]=0;

    Kn_BalYear  = atoi(Ksz_Balshey);
    Kn_BalMonth = atoi(Ksz_Balshtmth);
    Kn_NbYear   = atoi(Ksz_NbYear);
    // ouverture des fichiers
    if ( n_OpenFileAppl ("ESTC2038_O1","wb",&Kp_PilotOFil) == ERR )             ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2038_O2","wt",&Kp_PrevOFil) == ERR )              ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2038_O3","wt",&Kp_AscPilotOFil) == ERR )          ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2038_O4","wt",&Kp_ReserveNoAccOFil) == ERR )      ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2038_O5","wt",&Kp_ReserveOFil) == ERR )           ExitPgm ( ERR_XX , "" );
    if ( n_OpenFileAppl ("ESTC2038_I2","rb",&Kp_PilotIFil) == ERR )             ExitPgm ( ERR_XX , "" ); // A implementer pour RechPilot5000

    // Initialisation de la varible bd_RuptGT
    if ( n_InitGT(&bd_RuptGT) )                             ExitPgm ( ERR_XX , "" );
    // Initialisation de la varible bd_RuptPrev
    if ( n_InitPrev(&bd_RuptPrev) )                         ExitPgm ( ERR_XX , "" );

    // Chargement en memoire du fichier pilotage
    // modif O.Arik:29/05/2001 on sort en cas de dep. de memoire
    //if(n_ChargerPilot () == ERR )                           ExitPgm( ERR_XX , "" ) ; // RechPilot5000

    if (n_ChargerPilot7000(Kp_PilotIFil) == ERR)
	//if (n_FillLifdriQuarter(Kp_PilotIFil) == -1)
      ExitPgm (ERR_XX, "");                            // RechPilot5000

    // Chargement fichier association
    if ( n_OpenFileAppl ("ESTC2038_I5","rb",&Kp_SubTRSAssoFil) == ERR )
                ExitPgm ( ERR_XX , "" );  
    if ( n_ChargerTsubTRSAsso(Kp_SubTRSAssoFil) == ERR ) 			ExitPgm( ERR_XX , "" ); 
    
    // Chargement fichier T_SUBTRS
    if (n_OpenFileAppl ("ESTC2038_I6","rb",&Kp_SubTRSFil) == ERR )
                ExitPgm ( ERR_XX , "" );
    if ( n_ChargerTsubTRS(Kp_SubTRSFil) == ERR ) 					ExitPgm( ERR_XX , "" ); 

    // Chargement fichier T_SUBTRS
    if (n_OpenFileAppl ("ESTC2038_I4","rb",&Kp_EsBpropIFil) == ERR )
                ExitPgm ( ERR_XX , "" );
    
    if ( n_ChargerSUBTRSESBPROP(Kp_EsBpropIFil) == ERR ) 			ExitPgm( ERR_XX , "" ); 
    
    // initialisation de la structure retour
    init_SubTrsAssoLigne();	
    init_SubTrsLigne();
    init_SubTrsEsBprop();

    // lancement du traitement du fichier
    if ( n_ProcessingRuptureVar (&bd_RuptGT) == ERR )       ExitPgm ( ERR_XX , "" );

    // Ecriture de LIFDRI + le complement en ASCII
    n_EcrireASCCPLLIFDRI();

    // Ecriture de LIFDRI + le complement en binaire
    n_EcrireCPLLIFDRI();


    if (n_CloseFileAppl ("ESTC2038_I1",&(bd_RuptGT.pf_InputFil)))               ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2038_I3",&(bd_RuptPrev.pf_InputFil)))             ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2038_I2",&Kp_PilotIFil))                          ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2038_I4",&Kp_EsBpropIFil))                        ExitPgm ( ERR_XX , "" );	
    if (n_CloseFileAppl ("ESTC2038_I5",&Kp_SubTRSAssoFil))                      ExitPgm ( ERR_XX , "" );	
    if (n_CloseFileAppl ("ESTC2038_O1",&Kp_PilotOFil))                          ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2038_O2",&Kp_PrevOFil))                           ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2038_O3",&Kp_AscPilotOFil))                       ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2038_O4",&Kp_ReserveNoAccOFil))                   ExitPgm ( ERR_XX , "" );
    if (n_CloseFileAppl ("ESTC2038_O4",&Kp_ReserveOFil))                        ExitPgm ( ERR_XX , "" );
    	
    if ( n_EndPgm () == ERR )                               ExitPgm ( ERR_XX , "" );

  exit(0);
}




/**************************************************************************/
/*** Objet:     Recherche une ligne du tableau de structures ou les     ***/
/***            champs correspondent aux parametres en entree.          ***/
/*** Nom:       n_RechPilot                                             ***/
/*** Parametres:                                                        ***/
/***            La ligne du tableau contenant les valeurs recherchees   ***/
/***            Le nombre de lignes du tableau ou s'effectue la         ***/
/***            recherche                                               ***/
/*** Retour:                                                            ***/
/***            Le numero de la ligne du tableau si trouve              ***/
/***            -1 si non trouve                                        ***/
/**************************************************************************/
int n_RechPilot (char *sz_ctr, char *sz_sec, char *sz_acy)
{
  int n_indice = 0,     // indice dans le tableau parcouru Indiquent si le champ a deja ete trouve
      b_chp1=0,b_chp2=0,b_chp3=0;

    DEBUT_FCT("n_RechPilot");

    while (1==1)
    {
        /* Si les champs correspondent, on a trouve le debut    */
        /* du bloc. Sinon, et si on etait precedemment sur ce   */
        /* bloc, alors on ne peut plus trouver la ligne, donc   */
        /* on sort en retournant -1                             */
        if (strcmp(sz_ctr,Kbd_PILOTD[n_indice].CTR_NF)==0)
        {
            /* 1er champ trouve */
            b_chp1=1;

            if (atoi(sz_sec)==Kbd_PILOTD[n_indice].SEC_NF)
            {
                b_chp2=1;       // 2eme champ trouve
                b_chp3=1;       // 3eme champ trouve: plus aucun controle sur l'exercice

                // Si le 4eme champ correspond, retour de l'indice
                if ( atoi(sz_acy) == Kbd_PILOTD[n_indice].ACY_NF )
                    RETURN_VAL (n_indice);
            }
            else
            if (b_chp2==1)
                RETURN_VAL (-1);
        }
        else
        if (b_chp1==1)
            RETURN_VAL (-1);

        // Ligne suivante
        n_indice++;

        // Si on a depasse la fin du tableau, ligne non trouvee
        if (n_indice>=Kn_NbLigPilot)
            RETURN_VAL (-1);
    }
}

/**************************************************************************/
/*** Objet :    Copie le contenu du fichier en entree dans un tableau   ***/
/*** Nom:       n_ChargerPilot                                          ***/
/***                                                                    ***/
/*** Parametres:                                                        ***/
/***            Le pointeur du fichier                                  ***/
/***            Le tableau de structures                                ***/
/*** Retour:                                                            ***/
/***            0                                                       ***/
/**************************************************************************/
int n_ChargerPilot()
{
  int n_EOF = 0;
  T_LIFDRI_ALL_QUARTER bd_Lu;
  char MsgAno[300];

    DEBUT_FCT("n_ChargerPilot");
		
    if ( n_OpenFileAppl ("ESTC2038_I2","rb",&Kp_PilotIFil) == ERR )
        ExitPgm ( ERR_XX , "" );

    Kn_NbLigPilot=0;

    /* Tant que la fin de fichier n'est pas atteinte,... */
    while ( n_EOF == 0 )
    {
        /* ... lecture d'une ligne dans le fichier. */
        if ( fread(&bd_Lu,sizeof(T_LIFDRI_ALL_QUARTER),1,Kp_PilotIFil) <= 0 )
            n_EOF = 1;      // Fin de fichier, mise a jour du flag
        else
        {
            // ecriture dans log si depassement du tableau
            if ( Kn_NbLigPilot >= NB_MAX_PILOT)
            {
                sprintf(MsgAno,"The number of Driving records  (/CTR %s /SEC %d /UWY %d) overflows the program's storage capacity",
                    bd_Lu.CTR_NF,
                    bd_Lu.SEC_NF,
                    bd_Lu.UWY_NF);
                    n_WriteAno(MsgAno);
                    RETURN_VAL(ERR);
            }

            // ecriture enregistrement dans le tableau
/*            printf("<%s|%d|%d|%d|%d|%d|%d|%d|%d|%d|%d|Res%d|%s|%c|%d|%s|%s|%s>\n",
bd_Lu.CTR_NF,
bd_Lu.END_NT,
bd_Lu.SEC_NF,
bd_Lu.UWY_NF,
bd_Lu.UW_NT,
bd_Lu.ACY_NF,
bd_Lu.SSD_CF,
bd_Lu.BALSHEY_NF,
bd_Lu.BALSHTMTH_NF,
bd_Lu.AUTUPD_B,
bd_Lu.COMACC_B,
bd_Lu.PROPAG_RES_B,
bd_Lu.CRE_D,
bd_Lu.UPD_NF,
bd_Lu.CMT_NT,
bd_Lu.CREUSR_CF,
bd_Lu.LSTUPD_D,
bd_Lu.LSTUPDUSR_CF);*/

            Kbd_PILOTD[Kn_NbLigPilot++] = bd_Lu;
            /* affiche (&bd_Lu);*/
        }
    }

  RETURN_VAL (0);
}



/*==============================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du GT.
retour :    0
==============================================================================*/
int n_InitGT(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitGT");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2038_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 1;
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1GT;
    pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptGT;

    pbd_Rupt->n_ActionLigne = n_ActionLigneGT ;

    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (0);
}



/*==============================================================================
objet :     fonction de test de rupture du niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1GT(char **ptb_InRec,char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR1GT");
    
  if (strcmp(ptb_InRec[GT_CTR_NF],ptb_InRec_Cur[GT_CTR_NF])!=0)           RETURN_VAL(1);
  if (strcmp(ptb_InRec[GT_SEC_NF],ptb_InRec_Cur[GT_SEC_NF])!=0)           RETURN_VAL(1);
  if (strcmp(ptb_InRec[GT_UWY_NF],ptb_InRec_Cur[GT_UWY_NF])!=0)           RETURN_VAL(1);
  if (strcmp(ptb_InRec[GT_ACY_NF],ptb_InRec_Cur[GT_ACY_NF])!=0)           RETURN_VAL(1);
  if (strcmp(ptb_InRec[GT_ACM_NF],ptb_InRec_Cur[GT_ACM_NF])!=0)           RETURN_VAL(1);

    	
  RETURN_VAL (0);
}



/*==============================================================================
  objet :     Fonction lancee a chaque rupture derniere sur contrat/sec/uwy/ACY
  ==============================================================================*/
int n_ActionLastRuptGT (char **ptb_InRec_Cur)
{
	int i, j, n_comacimpact=0, result_bprop, resultposte, type_poste, result_asso = 0, lib_analytique = 0;
	int Kb_AUTUPD_sav;
	int flagRetro = 0;
	char sz_acmtrs[5];
	char sz_acmtrs2[5];
	char sz_gaapdiff[25];
	char sz_gaap[2];
	char sz_MontantGaap[25];
	T_LIFDRI_ALL_QUARTER bd_new;
	double d_montant, NewGaapdiff;
	char sz_new_cre[20],sz_dettrncod[6];
	char sz_regle[]=" ";
	
    DEBUT_FCT("n_ActionLastRuptGT");

    if (atoi(ptb_InRec_Cur[GT_ACY_NF]) >= Kn_BalYear-Kn_NbYear)
    {
        // A priori, on suppose que le pilotage n'est pas synchro
        Kn_SyncPilot = -1;
        Kb_AUTUPD=0;

        // Si le GT est en Arrete statistique:
        if (ptb_InRec_Cur[GT_COMACC_B][0]=='1')
        {
            if (ptb_InRec_Cur[GT_ACMTRS_NT][0]=='1')
            {
                flagRetro = 0; // On est en accept
            }
            else
            {
                flagRetro = 1; // On est en Retro
            }
            
            // Synchronisation du fichier Pilotage pour cette ligne ...
            //Kn_SyncPilot = n_RechPilot(	ptb_InRec_Cur[GT_CTR_NF], ptb_InRec_Cur[GT_SEC_NF], ptb_InRec_Cur[GT_ACY_NF]);  // RechPilot5000 

            //Kn_SyncPilot = n_RechPilot5000 ( ptb_InRec_Cur,GT_CTR_NF ,GT_SEC_NF, GT_ACY_NF, &ksz_indexPilot) ;            // RechPilot5000 
            //Kn_SyncPilot = n_RechPilot7000 ( ptb_InRec_Cur,GT_CTR_NF ,GT_SEC_NF, GT_ACY_NF, GT_ACM_NF, &ksz_indexPilot) ; // RechPilot7000 TEST QUARTERLY // [023] deactivate this line
            //if ( ksz_indexPilot > 10 ) ksz_indexPilot-=10;

            /* [023] BEGIN */
            int mon_index = 0;
            Kn_SyncPilot = n_RechPilot7000 ( ptb_InRec_Cur,GT_CTR_NF ,GT_SEC_NF, GT_ACY_NF, GT_ACM_NF, &mon_index) ;             // RechPilot7000 TEST QUARTERLY
            /* [023] END   */
            

// 01/06/2006    j. Ribot   suppression mis en commentaire des lignes suivantes   
          	if (Kn_SyncPilot>=0 && Kbd_PILOTD[Kn_SyncPilot].BALSHEY_NF == Kn_BalYear )
          	{
                Kb_AUTUPD=Kbd_PILOTD[Kn_SyncPilot].AUTUPD_B;
                Kb_PropaReserve=Kbd_PILOTD[Kn_SyncPilot].PROPAG_RES_B;
                LIFDRI_COMACC_B = Kbd_PILOTD[Kn_SyncPilot].COMACC_B;
            }
          	else
            {
                LIFDRI_COMACC_B = 0;
// 01/06/2006    j. Ribot   fin  suppression mis en commentaire des lignes precedentes   
            //* Modif ANB le 15/11/1999 
            //* Le top maj auto est à 0 par défaut en rétrocession 
            //* AUTUPD = 1 par défaut pour acceptation, 0 Pour Retro - Kb_PropaReserve = 0 pour acceptation, 1 pour Retro
                if (ptb_InRec_Cur[GT_ACMTRS_NT][0]=='1')
                {
                   Kb_AUTUPD=1;
                   Kb_PropaReserve=0;
                }
                else
                {
                   Kb_AUTUPD=0;
                   Kb_PropaReserve=0;
                }
            }
            if (ptb_InRec_Cur[GT_ACMTRS_NT][0]=='1')
            {
                Kb_PropaReserve=atoi(ptb_InRec_Cur[GT_PROPAGRES_B]);
            }
            
            
            // Changement de récupération du Flag Propagation des réserves SBE 26/03/2014
            // Si acceptation on récupère l'info du GT
            // Si retrocession on récupère l'info du LIFDRI
            /* SBE commentaire à enlever */
            if (ptb_InRec_Cur[GT_ACMTRS_NT][0]=='1')
            {
                Kb_PropaReserve=atoi(ptb_InRec_Cur[GT_PROPAGRES_B]); 
            }
            else
            {
                if (Kn_SyncPilot>=0 && Kbd_PILOTD[Kn_SyncPilot].BALSHEY_NF == Kn_BalYear )
                {
                    Kb_PropaReserve=Kbd_PILOTD[Kn_SyncPilot].PROPAG_RES_B; 
                }
                else
                {
                    // On positionne le flag reserve à 0 pour la retro si non trouvé dans LIFDRI
                    Kb_PropaReserve=0;
                }
            }
            //Kb_PropaReserve=0; // A ENLEVER APRES COMPARAISON - SBE 05/05/2014 [003]
        } 
		
        /* Synchronisation des previsions */
        Kb_SyncPrev=0;
        Kb_AUTUPD_sav = Kb_AUTUPD;
        n_ProcessingRuptureSyncVar(&bd_RuptPrev, ptb_InRec_Cur);
        Kb_AUTUPD = Kb_AUTUPD_sav;

        if ( (flagRetro == 1 && Kb_AUTUPD==1 ) || flagRetro == 0 ) 
        {
      	    if ( (ptb_InRec_Cur[GT_COMACC_B][0]=='1') ) //&&  (Kb_AUTUPD==1) ) [011]
      	    {
      		    // Si previsions synchro, creation pilotage
      		    if (Kb_SyncPrev==1)
            	{
                    // Si pilotage synchro, creation a partir de l'enregistrement existant
                    // sprintf(sz_new_cre, "%s %s", Ksz_DateJour, " ");    [17950]    
                    sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:59:10");       // [17950] 

                    if (Kn_SyncPilot>=0)
                    {
                        bd_new=Kbd_PILOTD[Kn_SyncPilot];
                        if (bd_new.COMACC_B != 1)
                        {
                            bd_new.COMACC_B=1;
                            bd_new.PROPAG_RES_B=Kb_PropaReserve;
                            bd_new.UPD_NF='I';
                            strcpy(bd_new.CRE_D,sz_new_cre);
                            bd_new.BALSHEY_NF=Kn_BalYear;
                            bd_new.BALSHTMTH_NF=Kn_BalMonth;
						    // mis en commentaire JR 28 03 03 pour reconduire CMT_NT precedent
						    // bd_new.CMT_NT=1;                            
				            strcpy(bd_new.CREUSR_CF, "dbo");
		        		    strcpy(bd_new.LSTUPDUSR_CF, "dbo");
		                    strcpy(bd_new.LSTUPD_D, sz_new_cre);
						    n_AddCPLIFDRI(&bd_new);
                        }
                    }
                    else    // Sinon, creation de toute piece de l'enregistrement 
                    {
                        bd_new.UPD_NF='I';
                        sprintf(bd_new.CTR_NF,"%.9s",ptb_InRec_Cur[GT_CTR_NF]);
                        bd_new.END_NT=atoi(ptb_InRec_Cur[GT_END_NT]);
                        bd_new.SEC_NF=atoi(ptb_InRec_Cur[GT_SEC_NF]);
                        bd_new.UWY_NF=atoi(ptb_InRec_Cur[GT_ACY_NF]);
                        bd_new.UW_NT=atoi(ptb_InRec_Cur[GT_UW_NT]);
                        bd_new.ACY_NF=atoi(ptb_InRec_Cur[GT_ACY_NF]);
                        bd_new.ACM_NF=atoi(ptb_InRec_Cur[GT_ACM_NF]);
                        bd_new.SSD_CF=atoi(ptb_InRec_Cur[GT_SSD_CF]);
                        bd_new.BALSHEY_NF=Kn_BalYear;
                        bd_new.BALSHTMTH_NF=Kn_BalMonth;
                        bd_new.AUTUPD_B=1;
                        bd_new.COMACC_B=1;
                        bd_new.SEGUPD_B=0;
                        bd_new.PROPAG_RES_B=Kb_PropaReserve;
                        strcpy(bd_new.CRE_D,sz_new_cre);
                        bd_new.CMT_NT=0;          //  bd_new.CMT_NT=2;  JR  11/03/03 
                        strcpy(bd_new.CREUSR_CF, "dbo");
                        strcpy(bd_new.LSTUPDUSR_CF, "dbo");
                        strcpy(bd_new.LSTUPD_D, sz_new_cre);
                        n_AddCPLIFDRI(&bd_new);
                    }
        	    }

                // Pour tous les postes qui sont encore dans la liste (qui    
                // sont ceux auxquels ne correspond aucune prevision), une    
                // nouvelle prevision est cree, sauf si le montant est nul.
                if ( (Kb_AUTUPD==1) && (Kb_SyncPrev==1) )
                    for (i=0;i<Kn_CleGT;i++)
                    {
                        //sprintf(sz_acmtrs2,"%4.4d",Kbd_CleGT[i].ACMTRS2_NT);
					
                        // Un poste fait partie de la liste ssi ACMTRS_NT <> 0 si acmtrs_nt=0, alors le trncod du gt n'est pas mappé dans ttrslnk (500)
                        //if ( (Kbd_CleGT[i].ACMTRS_NT!=0) && (d_montant!=0)  )
                        //if ( (d_montant!=0)  )
                        //{
        		        /* Utilisation du numero de poste et du montant stockes */
            		    sprintf(sz_dettrncod,"%5.5d",Kbd_CleGT[i].TRNCOD_CF);		
         			    result_bprop = n_RechSUBTRSESBPROP(&SubTrsEsBprop, sz_dettrncod, ptb_InRec_Cur[GT_SSD_CF], ptb_InRec_Cur[GT_ESB_CF]);  // [019]
					    if ( result_bprop != (-1) )
					    {
    						n_comacimpact=SubTrsEsBprop.COMACIMPACT_B;
					    }
                        result_asso = n_FindTsubTRSAsso(&SubTrsAssoLigne, 1, 1, sz_dettrncod);
                        resultposte = n_FindTsubTRS(&SubTrsLigne,sz_dettrncod);

                        if ( result_asso == -1 && SubTrsLigne.TRSNATURE_CT == 2 && SubTrsLigne.TRSTYPE_CT == 6 )
                        {
                            lib_analytique = 1;
                        }
                        else 
                        {
                            lib_analytique = 0;
                        }             

                        sprintf(sz_acmtrs2,"%4.4d",Kbd_CleGT[i].ACMTRS2_NT);
                        d_montant=-1*atof(Kbd_CleGT[i].AMT_M);
    
					    if ( (Kbd_CleGT[i].ACMTRS_NT!=0) && (d_montant!=0) && (sz_acmtrs2[3] != '4') && (n_comacimpact == 1) && (lib_analytique == 0) )
					    {
    						sprintf(sz_acmtrs,"%4.4d",Kbd_CleGT[i].ACMTRS_NT);
                    	    // On ne cree pas de prevision sur une liberation
                    	    if (sz_acmtrs[3]!='4')
                    	    {
                                // Creation de la prevision avec le montant du GT
                                ptb_InRec_Cur[GT_ACMTRS_NT]=sz_acmtrs;
                            
                                // Renseignement de la règle - Dans ce cas, si poste CASH 		règle = 6
        					    // 											si poste réserve	règle = 2
        										
        					    //resultposte = n_FindTsubTRS(&SubTrsLigne,sz_dettrncod);
     						    if ( resultposte != (-1) )
							    {
    								if ( SubTrsLigne.TRSTYPE_CT == 1 )
	    							{
									    // poste Cash	
									    type_poste=1;
        							    sprintf(sz_regle,"%s","6");
        						    }
        						    if ( SubTrsLigne.TRSTYPE_CT == 3 )
        						    {
            							// poste reserve
        							    type_poste=2;
        							    sprintf(sz_regle,"%s","2");
        						    }
        					    }        										

                                // CreationPrevision('G',Kbd_CleGT[i].AMT_M,ptb_InRec_Cur, "NA");
                                // Creation de la prevision avec le montant du GT...  
                			    // Sur tous les gaap - Même montant, et gaab_diff = 0 
                			    // Test à ajouter si poste à propagation
                			for (j=1;j<6;j++)
                			{
                				// Verification si poste interdit pour le gaap en cours
                				sprintf(sz_gaap,"%d",j);
                				sprintf(sz_gaapdiff,"0");
                				strcpy(sz_MontantGaap,Kbd_CleGT[i].AMT_M);
                				switch(j)
    							{
					        		case 1:
					        			Kn_SavMontantGtSansPrev=atof(Kbd_CleGT[i].AMT_M);
            							if ( SubTrsEsBprop.GAAP1TRS_CT == 3)
            							{
            								// normalement le gaap 1 n'est jamais interdit
            							}
            							break;
									case 2:
							    		if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
							    		{
							    			// Si poste interdit Montant = 0 et gaap diff = 0 - montant sauvegardé
							    			strcpy(sz_MontantGaap,"0");
							    			NewGaapdiff=0-Kn_SavMontantGtSansPrev;
							    			sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
							    			Kn_SavMontantGtSansPrev=0;
							    		}
							    		else
							    		{
							    			Kn_SavMontantGtSansPrev=atof(Kbd_CleGT[i].AMT_M);
							    			NewGaapdiff=atof(sz_MontantGaap)-Kn_SavMontantGtSansPrev;
							    			sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
							    		}
							    		break;
									case 3:
							    		if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
							    		{
							    			strcpy(sz_MontantGaap,"0");
							    			NewGaapdiff=0-Kn_SavMontantGtSansPrev;
							    			sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
							    			Kn_SavMontantGtSansPrev=0;
							    		}
							    		else
							    		{
							    			Kn_SavMontantGtSansPrev=atof(Kbd_CleGT[i].AMT_M);
							    			NewGaapdiff=atof(sz_MontantGaap)-Kn_SavMontantGtSansPrev;
							    			sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
							    		}
							    		break;
									case 4:
							    			if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
							    			{
							    				strcpy(sz_MontantGaap,"0");
							    				NewGaapdiff=0-Kn_SavMontantGtSansPrev;
							    				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
							    				Kn_SavMontantGtSansPrev=0;
							    			}
							    			else
							    			{
							    				Kn_SavMontantGtSansPrev=atof(Kbd_CleGT[i].AMT_M);
							    				NewGaapdiff=atof(sz_MontantGaap)-Kn_SavMontantGtSansPrev;
							    				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
							    			}
							    			break;            				            				
									case 5:
            								if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
            								{
            									strcpy(sz_MontantGaap,"0");
							    				NewGaapdiff=0-Kn_SavMontantGtSansPrev;
							    				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
							    				Kn_SavMontantGtSansPrev=0;
							    			}
							    			else
							    			{
							    				NewGaapdiff=atof(sz_MontantGaap)-Kn_SavMontantGtSansPrev;
							    				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
							    			}
							    				// Reinitialisation de Kn_SavMontantGtSansPrev au gaap 5
							    			Kn_SavMontantGtSansPrev=0;
            								break;
								}
								ptb_InRec_Cur[GT_TRNCOD_CF]=sz_dettrncod; // SBE Correction 02/04/2014 Pour avoir le bon TRNCOD lors de l'écriture de la prévision
								CreationPrevision('G',sz_MontantGaap,ptb_InRec_Cur, "23:59:16", sz_gaap, sz_gaapdiff, sz_regle);
                			}
                                // Fin For ecriture multigaap
                    	    }   // ajout jr 05/09/2003 
                        }
                    // jr 01 09 03                 Kbd_CleGT[i].ACMTRS_NT=0;    
                    } // Fin boucle FOR
      	    }
        }
        /* Reinitialisation du compteur du tableau GT */
        Kn_CleGT=0;
    }
  RETURN_VAL(0);
}


/*==============================================================================
objet :     fonction lancee pour chaque ligne du GT
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLigneGT");

	if (atoi(ptb_InRec_Cur[GT_ACY_NF]) >= Kn_BalYear-Kn_NbYear)
 	{
		// La ligne du GT est memorisee 
		MemoGT(ptb_InRec_Cur);
    }
	RETURN_VAL (0);
}


/*==============================================================================
objet :     Initialisation de la synchronisation du GT avec les previsions
retour :    0
==============================================================================*/
int n_InitPrev(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitPrev");

    memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

    /* ouverture du fichier previsions */
    n_OpenFileAppl ("ESTC2038_I3","rt",&(pbd_Rupt->pf_InputFil));

    pbd_Rupt->n_NbRupture = 1;
    
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;
    pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPrev;

    /* fonction du test de la ligne du GT avec les previsions */
    pbd_Rupt->ConditionEndSync = n_ConditionSyncPrev;

    /* fonction d'action quand le GT est seul */
    pbd_Rupt->n_PereSansFils = n_ActionGTsansPrev;

    /* fonction d'action quand les previsions sont seules */
    pbd_Rupt->n_FilsSansPere = n_ActionPrevSansGT;

    /* fonction d'action sur la ligne courante du fichier previsions */
    pbd_Rupt->n_ActionLigne = n_ActionLignePrev;
    
    pbd_Rupt->c_Separ = '~';

 	RETURN_VAL (0);
}

/*==============================================================================
objet :     fonction de test de rupture du niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1Prev(char **ptb_InRec,char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR1GT");
    
  if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)           RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_SEC_NF],ptb_InRec_Cur[PRE_SEC_NF])!=0)           RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_UWY_NF],ptb_InRec_Cur[PRE_UWY_NF])!=0)           RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ACY_NF],ptb_InRec_Cur[PRE_ACY_NF])!=0)           RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ESTMTH_NF],ptb_InRec_Cur[PRE_ESTMTH_NF])!=0)           RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ACMTRS_NT],ptb_InRec_Cur[PRE_ACMTRS_NT])!=0)     RETURN_VAL(1);

  RETURN_VAL (0);
}

void EcrireFlagLastAnalytic()
{
    int l=0;
    
    while ( l < i_ana )
    {
        if ( Kbd_Analytic[l].FlagFirst == 0 && Kbd_Analytic[l].DETTRNCOD_CF != Kbd_Analytic[l-1].DETTRNCOD_CF )
        {
            Kbd_Analytic[l].FlagLast = 1;
        }
        l++;
    }
    Kbd_Analytic[i_ana-1].FlagLast = 1;
}
    

/*==============================================================================
  objet :     Fonction lancée a chaque rupture derniere sur contrat/sec/uwy/ACY/ACMTRS
              Si au moins un poste analytique pour le poste de regroupement est de de type montant.
              On écrase toutes les lignes prévision par la compta, MNT = 0
              Dans cette fonction on va comparer les ligne GT en cours avec les lignes de prévisions sauvegardées 
              dans le tableau Kbd_Analytic.
  ==============================================================================*/
int n_ActionLastRuptPrev(char **ptb_InRec, char **ptb_InRec_Cur)
{
    int i;
    char *psz_ligne[PRE_NBCOLNEW];
    char sz_tmp[]=" ";
    char sz_OriSav[]=" ";
    int  l=0, g=0, h=0;
    char sz_new_cre[20];
    char sz_lib_oricod[12] = "ARRETE STAT";
    int  flag_mvt = 0;
    char sz_MontantTmp[25]={0};
    int  ResultAsso;
    char sz_Dettrncod[6] = "DETRN";
    int  Kbd_SavAsso[10]; // Tableau pour sauvegarder les postes écrits en Calculated
    int  Kn_SavAsso=0;    // Taille de ce tableau
    int  flagAsso=0;
    EcrireFlagLastAnalytic();
    

    //if ( (! (strcmp(ptb_InRec[GT_ADJCOD_CT],"FIC") == 0 )) && flag_ana > 0)
    if ( flag_ana > 0)
    {
        // Recherche si mouvement sur un des poste analytique du regroupement
        // Cad si la compta est différente des estimations pour au moins un poste détail.
        // Dans ce cas, on effectue le compte complet pour tous les postes analytiques du regroupement
        while ( l < i_ana && flag_mvt == 0 )
        {
            while ( g < Kn_CleGT && flag_mvt == 0 )
            {
                if ( Kbd_CleGT[g].ACMTRS2_NT == Kbd_Analytic[l].ACMTRS_NT 
                  && Kbd_CleGT[g].TRNCOD_CF == Kbd_Analytic[l].DETTRNCOD_CF
                  && ( atof(Kbd_Analytic[l].AMT_M) != atof( Kbd_CleGT[g].AMT_M) )
                  && Kbd_Analytic[l].FlagFirst == 1 )
                {
                    flag_mvt = 1;
                }
                g++;
            }
            g=0;
            l++;
        }
        l=0;
        g=0;
        // Un mouvement a été détecté. On met à jour les prévisions de tous les postes analytiques
        // du regroupement par la compta.
        while ( g < Kn_CleGT && flag_mvt == 1)
        {
            while ( l < i_ana )
            {
                if ( Kbd_CleGT[g].ACMTRS2_NT == Kbd_Analytic[l].ACMTRS_NT && Kbd_CleGT[g].TRNCOD_CF == Kbd_Analytic[l].DETTRNCOD_CF && strcmp(Kbd_CleGT[g].TypePoste, "FIC") !=0  )
                {
                    if ( Kbd_Analytic[l].FlagFirst == 1 )
                    {
                        // On calcule le montant de reserve à reporter sur les années de compte futures avant de mettre à jour le montant par la compta dans le tableau
                        sprintf(Kbd_Analytic[l].RESERVE_M, "%.3lf", atof(Kbd_CleGT[g].AMT_M) - atof(Kbd_Analytic[l].AMT_M));
                        // On remplace le montant des prévisions par le montant de la compta
                        strcpy(Kbd_Analytic[l].AMT_M, Kbd_CleGT[g].AMT_M);
                    }
                    else
                    {
                        // On calcule le gaap diff
                        sprintf(sz_MontantTmp, "%.3lf", atof(Kbd_Analytic[l-1].AMT_M) + atof(Kbd_Analytic[l].GAAPDIFF_M));
                        strcpy(Kbd_Analytic[l].AMT_M, sz_MontantTmp);
                        strcpy(Kbd_Analytic[l].RESERVE_M, Kbd_Analytic[l-1].RESERVE_M);
                    }
                }
                l++;
            }
            g++;
            l=0;
        }
        g=0;
        
        // Le champ 50 est effacé de la ligne d'entrée ptb_InRec_Cur dans la boucle for.
        // On sauvegarde pour repositionner après la boucle For
        strcpy(sz_OriSav, ptb_InRec_Cur[PRE_ORISSD_CF]);
        // On recopie ptb_InRec dans psz_ligne
        for (i=0;i <= PRE_NBCOLNEW; i++)
        {
             psz_ligne[i]=ptb_InRec_Cur[i];
        }
        psz_ligne[PRE_NBCOLNEW]=0;
        strcpy(psz_ligne[PRE_ORISSD_CF],sz_OriSav);

       
        // Ecriture en sortie du tableau d'analytiques       
        // + Propagation reserve si nécessaire 
        if ( flag_ana == 1 && flag_mvt == 1 )
        {
            memset(sz_new_cre, 0, sizeof(sz_new_cre));
            sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:59:18");
            ptb_InRec_Cur[PRE_LSTUPD_D]= sz_new_cre;
            ptb_InRec_Cur[PRE_ORICOD_LS]= sz_lib_oricod;
            //psz_ligne[PRE_NBCOLNEW]="\0";*/
            l = 0;
        
            while (l < i_ana)
            {
                (void)snprintf(sz_tmp, 2, "%d", Kbd_Analytic[l].GAAP_NT);
                strcpy(ptb_InRec_Cur[PRE_GAAP_NF],sz_tmp);
                memset(sz_tmp, 0, 2);
                (void)snprintf(sz_tmp, 6, "%d", Kbd_Analytic[l].DETTRNCOD_CF);
                strcpy(ptb_InRec_Cur[PRE_DETTRNCOD_CF],sz_tmp);
                strcpy(sz_Dettrncod,sz_tmp);
                memset(sz_tmp, 0, 6);
                //strcpy(ptb_InRec_Cur[PRE_ESTMNT_M],Kbd_Analytic[l].AMT_M);
                ptb_InRec_Cur[PRE_ESTMNT_M]=Kbd_Analytic[l].AMT_M;
                ptb_InRec_Cur[PRE_ORICOD_LS]= sz_lib_oricod;
                
                // Propagation réserves
                // Si la propagation n'a pas ete jouee lors du premier Compte Complet [021] 
                if ( Kb_PropaReserve == 1  &&
                     (LIFDRI_COMACC_B != 1 && atoi(ptb_InRec_Cur[PRE_BATCH_B]) != 1)
                   )
                {
                    CreationReserveAna('P',Kbd_Analytic[l].RESERVE_M,ptb_InRec_Cur, "23:59:19", ptb_InRec_Cur[PRE_GAAP_NF], "0","NA");		//[015]
                }
                
                for(h = 0; h < Kn_SavAsso; h++)
                {
                    if ( Kbd_Analytic[l].DETTRNCOD_CF == Kbd_SavAsso[h] )
                    {
                        flagAsso = 1;
                    }
                }
                if ( flagAsso == 0 )
                {
                    n_WriteCols(Kp_PrevOFil,ptb_InRec_Cur,SEPARATEUR,0);
                
                    // Si type montant ou ratio (inputtyp = 1 ou 3, 
                    // on cherche le poste associé. Association 2,4
                    // Puis on positionne le flag ORICOD_LS = CALCULATED
                    if ( Kbd_Analytic[l].InputTyp == 1 || Kbd_Analytic[l].InputTyp == 3 )
                    {
                        ResultAsso = n_FindTsubTRSAsso(&SubTrsAssoLigne, 2, 4,sz_Dettrncod);
                        if ( ResultAsso != (-1) ) // [022]
                        {
                           strcpy(ptb_InRec_Cur[PRE_DETTRNCOD_CF],SubTrsAssoLigne.DETTRNCOD2_CF);
                           ptb_InRec_Cur[PRE_ORICOD_LS]  = "Calculated";
                           n_WriteCols(Kp_PrevOFil,ptb_InRec_Cur,SEPARATEUR,0);
                           // Propagation réserves
                           // Si la propagation n'a pas ete jouee lors du premier Compte Complet [021]
                           if ( Kb_PropaReserve == 1  &&
                              (LIFDRI_COMACC_B != 1 && atoi(ptb_InRec_Cur[PRE_BATCH_B]) != 1)
                              )
                           {
                               CreationReserveAna('P',Kbd_Analytic[l].RESERVE_M,ptb_InRec_Cur, "23:59:19", ptb_InRec_Cur[PRE_GAAP_NF], "0","NA");		//[015]
                           } 
                                                 
                           /* Il faut sauvegarder les postes associés écrits pour ne pas les écrire à nouveau s'ils sont également présent en compta.
                           -- Le 1er poste d'une association Amount/Ratio écrit est le 1er poste rencontré dans le fichie prévisions. Le poste associés
                           -- est toujours écrit en "Calculated"
                           -- Si ce même poste associé est de nouveau rencontré dans le fichier compta, il n'est pas réécrit en prévision en sortie.    */
                           if ( Kbd_Analytic[l].FlagLast == 1 )
                           {
                               Kbd_SavAsso[Kn_SavAsso] = atoi(SubTrsAssoLigne.DETTRNCOD2_CF);
                               Kn_SavAsso++;
                           }
                        }
                    }
                }
                l++;
            }
            flagAsso = 0;
        }
    }
    flag_ana = 0;
    i_ana = 0;    
    RETURN_VAL (0);
}
    


/*==============================================================================
objet :     fonction lancee quand le GT est seul (pas de previsions)
retour :    0 ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
                        // adresse de la ligne du GT
int n_ActionGTsansPrev( char **ptb_InRec )
{
  	int i,j, n_comacimpact=0, resultposte, type_poste, result_bprop, result_asso, lib_analytique=0;
  	T_LIFDRI_ALL_QUARTER bd_new;
  	double d_montant, NewGaapdiff;
  	char sz_MontantGaap[25];
  	char sz_poste[10], sz_new_cre[20], sz_dettrncod[6], sz_gaap[2],sz_gaapdiff[25];
	char sz_regle[]=" ";

  	DEBUT_FCT("n_ActionGTsansPrev");
    /* Modif ANB le 10/3/99 */
    /* Pas de création de prévision si l'affaire eSt terminée  */

    if ( (ptb_InRec[GT_COMACC_B][0]=='1') && (Kb_AUTUPD==1) && (ptb_InRec[GT_ADJCOD_CT][0] =='0') )
    {
        /* Creation d'une nouvelle prevision pour chaque poste sauf si le montant est nul ou pour une liberation.  */
        for (i=0;i<Kn_CleGT;i++)
        {
            /* Utilisation du numero de poste et du montant stockes */
            sprintf(sz_dettrncod,"%d",Kbd_CleGT[i].TRNCOD_CF);

			// On recupere le flag comacimpact et les flags sur les différents gaap pour savoir si ce sont des gaaps interdits au poste. 
			result_bprop = n_RechSUBTRSESBPROP(&SubTrsEsBprop, sz_dettrncod, ptb_InRec[GT_SSD_CF], ptb_InRec[GT_ESB_CF]);  //[019]
            result_asso = n_FindTsubTRSAsso(&SubTrsAssoLigne, 1, 1, sz_dettrncod);
            resultposte = n_FindTsubTRS(&SubTrsLigne,sz_dettrncod);

            if ( result_asso == -1 && SubTrsLigne.TRSNATURE_CT == 2 && SubTrsLigne.TRSTYPE_CT == 6 )
            {
                lib_analytique = 1;
            }
            else 
            {
                lib_analytique = 0;
            }             

			if ( result_bprop != (-1) )
			{
				n_comacimpact=SubTrsEsBprop.COMACIMPACT_B;
			}
						
            sprintf(sz_poste,"%4.4d",Kbd_CleGT[i].ACMTRS_NT);
            ptb_InRec[GT_ACMTRS_NT]=sz_poste;

            d_montant=-1*atof(Kbd_CleGT[i].AMT_M);

            if ( (Kbd_CleGT[i].ACMTRS_NT!=0) && (d_montant!=0) && ((sz_poste[3] != '4' && lib_analytique ==0) &&  (n_comacimpact == 1) ) )
            {
                // Creation de la prevision avec le montant du GT...  
                // Sur tous les gaap - Même montant, et gaab_diff = 0 
                // Test à ajouter si poste à propagation 
                
                ptb_InRec[GT_TRNCOD_CF]=sz_dettrncod; // SBE Pour avoir le bon TRNCOD lors de l'écriture de la prévision.

                // Renseignement de la règle - Dans ce cas, si poste CASH 		règle = 6
                //si poste réserve	règle = 2
//                resultposte = n_FindTsubTRS(&SubTrsLigne,sz_dettrncod);
     			if ( resultposte != (-1) )
				{
					if ( SubTrsLigne.TRSTYPE_CT == 1 )
					{
						// poste Cash	
						type_poste=1;
        				sprintf(sz_regle,"%s","6");
        			}
        			if ( SubTrsLigne.TRSTYPE_CT == 3 )
        			{
        				// poste reserve
        				type_poste=2;
        				sprintf(sz_regle,"%s","2");
        			}
        		}

				// Création de tous les gaap - Prise en compte des caractéristiques des postes
                for (j=1;j<6;j++)
                {
                	// Verification si poste interdit pour le gaap en cours
                	sprintf(sz_gaap,"%d",j);
                	sprintf(sz_gaapdiff,"0");
                	strcpy(sz_MontantGaap,Kbd_CleGT[i].AMT_M);
                	switch(j)
           {
					    case 1:
					    Kn_SavMontantGtSansPrev=atof(Kbd_CleGT[i].AMT_M);
            			if ( SubTrsEsBprop.GAAP1TRS_CT == 3)
            			{
            				// normalement le gaap 1 n'est jamais interdit
            			}
            			break;
					    case 2:
            			if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
            			{
            				// Si poste interdit Montant = 0 et gaap diff = 0 - montant sauvegardé
            				strcpy(sz_MontantGaap,"0");
            				NewGaapdiff=0-Kn_SavMontantGtSansPrev;
            				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
            				Kn_SavMontantGtSansPrev=0;
            			}
            			else
            			{
            				Kn_SavMontantGtSansPrev=atof(Kbd_CleGT[i].AMT_M);
            				NewGaapdiff=atof(sz_MontantGaap)-Kn_SavMontantGtSansPrev;
            				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
            			}
            			break;
					    case 3:
            			if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
            			{
            				strcpy(sz_MontantGaap,"0");
            				NewGaapdiff=0-Kn_SavMontantGtSansPrev;
            				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
            				Kn_SavMontantGtSansPrev=0;
            			}
            			else
            			{
            				Kn_SavMontantGtSansPrev=atof(Kbd_CleGT[i].AMT_M);
            				NewGaapdiff=atof(sz_MontantGaap)-Kn_SavMontantGtSansPrev;
            				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
            			}
            			break;
					    case 4:
            			if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
            			{
            				strcpy(sz_MontantGaap,"0");
            				NewGaapdiff=0-Kn_SavMontantGtSansPrev;
            				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
            				Kn_SavMontantGtSansPrev=0;
            			}
            			else
            			{
            				Kn_SavMontantGtSansPrev=atof(Kbd_CleGT[i].AMT_M);
            				NewGaapdiff=atof(sz_MontantGaap)-Kn_SavMontantGtSansPrev;
            				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
            			}
            			break;            				            				
					    case 5:
            			if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
            			{
            				strcpy(sz_MontantGaap,"0");
            				NewGaapdiff=0-Kn_SavMontantGtSansPrev;
            				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
            				Kn_SavMontantGtSansPrev=0;
            			}
            			else
            			{
            				NewGaapdiff=atof(sz_MontantGaap)-Kn_SavMontantGtSansPrev;
            				sprintf(sz_gaapdiff,"%.3lf",NewGaapdiff);
            			}
            			// Reinitialisation de Kn_SavMontantGtSansPrev au gaap 5
            			Kn_SavMontantGtSansPrev=0;
            			break;
					}
					CreationPrevision('G',sz_MontantGaap,ptb_InRec, "23:59:20", sz_gaap, sz_gaapdiff, sz_regle);
                }
            }
        }

        /* Synchronisation du fichier Pilotage pour cette ligne */
        //Kn_SyncPilot = n_RechPilot( ptb_InRec[GT_CTR_NF], ptb_InRec[GT_SEC_NF], ptb_InRec[GT_ACY_NF]);           // RechPilot5000
        //Kn_SyncPilot = n_RechPilot5000 ( ptb_InRec, GT_CTR_NF, GT_SEC_NF, GT_ACY_NF, &ksz_indexPilot) ;             // RechPilot5000
        Kn_SyncPilot = n_RechPilot7000 ( ptb_InRec, GT_CTR_NF, GT_SEC_NF, GT_ACY_NF, GT_ACM_NF, &ksz_indexPilot) ;             // RechPilot5000

        /* Si pilotage synchro, creation a partir de l'enregistrement existant */
        sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:59:13");

        if (Kn_SyncPilot>=0)
        {
            bd_new=Kbd_PILOTD[Kn_SyncPilot];
            if (bd_new.COMACC_B != 1)
            {
                bd_new.COMACC_B=1;
                bd_new.PROPAG_RES_B=Kb_PropaReserve;
                bd_new.UPD_NF='I';
                strcpy(bd_new.CRE_D,sz_new_cre);
                bd_new.BALSHEY_NF=Kn_BalYear;
                bd_new.BALSHTMTH_NF=Kn_BalMonth;
                /* mis en commentaire JR 28 03 03 pour reconduire CMT_NT precedent
                bd_new.CMT_NT=3;                               */
                strcpy(bd_new.CREUSR_CF, "dbo");
                strcpy(bd_new.LSTUPDUSR_CF, "dbo");
                strcpy(bd_new.LSTUPD_D, sz_new_cre);
                n_AddCPLIFDRI(&bd_new);
            }
        }
        else  // Sinon, creation de toute piece de l'enregistrement
        {
            bd_new.UPD_NF='I';
            bd_new.SSD_CF=atoi(ptb_InRec[GT_SSD_CF]);
            sprintf(bd_new.CTR_NF,"%.9s",ptb_InRec[GT_CTR_NF]);
            bd_new.END_NT=atoi(ptb_InRec[GT_END_NT]);
            bd_new.SEC_NF=atoi(ptb_InRec[GT_SEC_NF]);
            bd_new.UWY_NF=atoi(ptb_InRec[GT_ACY_NF]);
            bd_new.UW_NT=atoi(ptb_InRec[GT_UW_NT]);
            bd_new.ACY_NF=atoi(ptb_InRec[GT_ACY_NF]);
            bd_new.ACM_NF=atoi(ptb_InRec[GT_ACM_NF]);
            bd_new.BALSHEY_NF=Kn_BalYear;
            bd_new.BALSHTMTH_NF=Kn_BalMonth;
            bd_new.AUTUPD_B=1;
            bd_new.COMACC_B=1;
            bd_new.SEGUPD_B=0;
            bd_new.PROPAG_RES_B=Kb_PropaReserve;
            strcpy(bd_new.CRE_D,sz_new_cre);
            bd_new.CMT_NT=0;          /*  bd_new.CMT_NT=4;  JR  11/03/03  */
            strcpy(bd_new.CREUSR_CF, "dbo");
            strcpy(bd_new.LSTUPDUSR_CF, "dbo");
            strcpy(bd_new.LSTUPD_D, sz_new_cre);
            n_AddCPLIFDRI(&bd_new);
        }
    }
	RETURN_VAL (0);
}


/*==============================================================================
objet :     fonction lancee quand les previsions sont seules (pas de GT)
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
                        // adresse de la ligne des previsions */
int n_ActionPrevSansGT( char **ptb_InRec )
{
	int i=0, resultposte, type_poste, propagation, result_bprop;
	double NewGaapDiff;
    char *espace=" ", unite;

	int n_comacimpact=0; 
	char sz_NewGaapDiff[25];
	char *psz_ligne[PRE_NBCOL];
	char sz_AUTUPD[]=" ";
	char sz_regle[]=" ";
	double d_MontantReserve;
		
    DEBUT_FCT("n_ActionPrevSansGT");

    // La prevision est reconduite dans tous les cas 
    n_WriteCols(Kp_PrevOFil,ptb_InRec,SEPARATEUR,0);
    Kb_AUTUPD=0;

    	//Kn_SyncPilot = n_RechPilot(	ptb_InRec[GT_CTR_NF], ptb_InRec[GT_SEC_NF], ptb_InRec[GT_ACY_NF]);         // RechPilot5000
    	//Kn_SyncPilot = n_RechPilot5000 ( ptb_InRec, GT_CTR_NF, GT_SEC_NF, GT_ACY_NF, &ksz_indexPilot) ;            // RechPilot5000
        Kn_SyncPilot = n_RechPilot7000 ( ptb_InRec, GT_CTR_NF, GT_SEC_NF, GT_ACY_NF, GT_ACM_NF, &ksz_indexPilot) ;            // RechPilot5000
    	//if ( ksz_indexPilot > 10 ) ksz_indexPilot-=10;

    	if (Kn_SyncPilot>=0)
    	{
    		Kb_AUTUPD=Kbd_PILOTD[Kn_SyncPilot].AUTUPD_B;
    		Kb_PropaReserve=Kbd_PILOTD[Kn_SyncPilot].PROPAG_RES_B;
            LIFDRI_COMACC_B = Kbd_PILOTD[Kn_SyncPilot].COMACC_B; // [021]
    	}
    	else
        {
            LIFDRI_COMACC_B = 0;
            if (ptb_InRec[GT_ACMTRS_NT][0]=='1')
    	    {
		       Kb_AUTUPD=1;
			   Kb_PropaReserve=0;
		    }
    	    else
    	    {
    		   Kb_AUTUPD=0;      // AUTUPD = 0 par défaut pour rétrocession
    		   Kb_PropaReserve=1;
    	    }
        }
    	//Kb_PropaReserve=0; // A ENLEVER APRES COMPARAISON - SBE 05/05/2014 [003] [016]
    	
        // Changement de récupération du Flag Propagation des réserves SBE 26/03/2014
        // Si acceptation on récupère l'info du GT
        // Si retrocession on récupère l'info du LIFDRI
        /* SBE commentaire à enlever
        if (ptb_InRec_Cur[GT_ACMTRS_NT][0]=='1')
        {
            Kb_PropaReserve=atoi(ptb_InRec_Cur[GT_PROPAGRES_B]); 
        }
        else
        {
            if (Kn_SyncPilot>=0)
            {
                Kb_PropaReserve=Kbd_PILOTD[Kn_SyncPilot].PROPAG_RES_B; 
            }
            else
            {
                Kb_PropaReserve=1;
            }
        } */    	
		
		sprintf(sz_AUTUPD,"%d",Kb_AUTUPD);
		ptb_InRec[PRE_ORISSD_CF]=sz_AUTUPD;		
		
		// On recopie ptb_InRec dans psz_ligne
		for (i=0;i<PRE_NBCOL+1;i++)
		{
			psz_ligne[i]=ptb_InRec[i];
		}
		psz_ligne[PRE_NBCOL+1]=0;
		
		// Sans GT, il faut savoir si le compte est en compte complet avant de reconduire la prévision
		// On crée la ligne prévision avec le montant à 0 
		
		// Test si compte complet et auto update
		if ( (ptb_InRec[PRE_ORICRE_D][0]=='1') && (ptb_InRec[PRE_ORISSD_CF][0]=='1') )
		{
			result_bprop = n_RechSUBTRSESBPROP(&SubTrsEsBprop, ptb_InRec[PRE_DETTRNCOD_CF], ptb_InRec[PRE_SSD_CF], ptb_InRec[PRE_ESB_CF]);  //[019]
			if ( result_bprop != (-1) )
			{
				n_comacimpact=SubTrsEsBprop.COMACIMPACT_B;
			}
			if (atoi(ptb_InRec[PRE_ACY_NF]) >= Kn_BalYear-Kn_NbYear)
			{
				// La prevision est reconduite  A faire systematiquement
    			psz_ligne[PRE_UPD_NF]=espace;
    			//n_WriteCols(Kp_PrevOFil,ptb_InRec,SEPARATEUR,0); Reconduction prevision faite au début de la fonction SBE 04042014
				if ( n_comacimpact==1 )
				{
					if ( (strcmp(Kz_DETTRNCOD_prec,ptb_InRec[PRE_DETTRNCOD_CF]) !=0 ) 
                        || (strcmp(Kz_PRE_UWY_NF_prec,ptb_InRec[PRE_UWY_NF]) != 0) 
                        || (strcmp(Kz_PRE_CTR_N_prec,ptb_InRec[PRE_CTR_NF]) != 0) 
                        || (strcmp(Kz_PRE_ACY_NF_prec,ptb_InRec[PRE_ACY_NF]) != 0) 
                        || (strcmp(Kz_PRE_ACM_NF_prec,ptb_InRec[PRE_ESTMTH_NF]) != 0))
        			{
        				// On est sur le DETTRNCODE suivant 
        				strcpy(Kz_DETTRNCOD_prec,ptb_InRec[PRE_DETTRNCOD_CF]);
        				strcpy(Kz_PRE_UWY_NF_prec,ptb_InRec[PRE_UWY_NF]);
        				strcpy(Kz_PRE_ACY_NF_prec,ptb_InRec[PRE_ACY_NF]);
                        strcpy(Kz_PRE_ACM_NF_prec,ptb_InRec[PRE_ESTMTH_NF]);
        				strcpy(Kz_PRE_CTR_N_prec,ptb_InRec[PRE_CTR_NF]);
        				Kf_MontantGaap0Prev=atof(ptb_InRec[PRE_ESTMNT_M]);
        				// Si montant différent. Dans le cadre de la propagation des réserves, on va insérer cette différente dans 
            			// le fichier de sortie des réserves. 
            			// Différence = Montant Prevision - montant GT. Calcul de cette différence que sur le gaap 1. La reserve est ensuite reportee sur les autres gaap
            			d_MontantReserve= 0 - Kf_MontantGaap0Prev;
            			sprintf(Ksz_MontantReserve,"%.3lf",d_MontantReserve);
            			n_FlagFirst = 1;
        			} 
        			else 
                    {
                        n_FlagFirst = 0;
                    }
					
              // Renseignement de la règle - Dans ce cas, si poste CASH 		règle = 7
              //si poste réserve	règle = 3 ou 4 si poste à propagation
        			resultposte = n_FindTsubTRS(&SubTrsLigne,ptb_InRec[PRE_DETTRNCOD_CF]);
        			SubTrsLigne.TRSTYPE_CT = 3;
        			
     				if ( resultposte != (-1) )
					{
						if ( SubTrsLigne.TRSTYPE_CT == 1 )
						{
                            // poste Cash
                            type_poste=1;
                            sprintf(sz_regle,"%s","7");
                            ptb_InRec[PRE_UPD_NF]=sz_regle;
                            CreationPrevision('P',"0",ptb_InRec, "23:59:15", ptb_InRec[PRE_GAAP_NF], "0", "NA");
        				} else // Calcul pour poste Analytiques
                        if ( (SubTrsLigne.TRSTYPE_CT == 5 ) || (SubTrsLigne.TRSTYPE_CT == 6 ) )
                        {
                            if ( SubTrsLigne.TRSINPUTTYPE_CT == 1 )
                            {
                                flag_ana = 1;
                            }
                            sav_LignePrevAnalytic(ptb_InRec, n_FlagFirst, SubTrsLigne.TRSINPUTTYPE_CT);
                        }   else
        				if ( ((SubTrsLigne.TRSTYPE_CT == 3) ||
                         ((SubTrsLigne.TRSINPUTTYPE_CT != 3) && (SubTrsLigne.TRSNATURE_CT == 2 ) && (SubTrsLigne.TRSTYPE_CT == 6))) && ( atof(ptb_InRec[PRE_GAAPDIFF_M]) == 0 ) )//[005] //(SubTrsLigne.NEWBALSHEETPROPAG_B == 1) ) // NEWBALSHEETPROPAG_B -> Propagation
        				{
        					// poste reserve et propagation 
        					type_poste=3;
        					propagation = 1;
        					sprintf(sz_regle,"%s","3");
        					ptb_InRec[PRE_UPD_NF]=sz_regle;
        					CreationPrevision('P',"0",ptb_InRec, "23:59:15", ptb_InRec[PRE_GAAP_NF], "0", "NA");
        					// CreationReserve
                            // Si la propagation n'a pas ete jouee lors du premier Compte Complet [021]
        					if ( Kb_PropaReserve == 1  &&
                                 (LIFDRI_COMACC_B != 1 && atoi(ptb_InRec[PRE_BATCH_B]) != 1)
                               )
        					{
        						// Pour tous les gaap on créé une ligne avec le montant de la reserve
     							CreationReserve('P',Ksz_MontantReserve,ptb_InRec, "23:59:15", ptb_InRec[PRE_GAAP_NF], "0","NA");
        					}
        				} else
        				if ( ((SubTrsLigne.TRSTYPE_CT == 3) ||
                        ((SubTrsLigne.TRSINPUTTYPE_CT != 3) && (SubTrsLigne.TRSNATURE_CT == 2 ) && (SubTrsLigne.TRSTYPE_CT == 6))) && ( atof(ptb_InRec[PRE_GAAPDIFF_M]) != 0 ) ) // [005] //(SubTrsLigne.NEWBALSHEETPROPAG_B == 0) ) // NEWBALSHEETPROPAG_B -> Propagation
        				{
        					// poste reserve et pas de propagation
        					type_poste=3;
        					propagation = 0;
        					sprintf(sz_regle,"%s","4");
        					ptb_InRec[PRE_UPD_NF]=sz_regle;
        					if ( strcmp(ptb_InRec[PRE_GAAP_NF],"1") == 0 || n_FlagFirst == 1 ) 
							{
								// Si GAAP 1 on écrase à 0
								//ptb_InRec[PRE_ESTMNT_M]="0";
								CreationPrevision('P',ptb_InRec[PRE_GAAPDIFF_M],ptb_InRec, "23:59:15", ptb_InRec[PRE_GAAP_NF], ptb_InRec[PRE_GAAPDIFF_M], "NA");
								n_FlagFirst = 0;
							}
							else
							{

								// Si autres GAAP on réécrit les gaap avec les memes montants
								NewGaapDiff=atof(ptb_InRec[PRE_ESTMNT_M])-atof(psz_SavLignePrevPrecedente[PRE_ESTMNT_M]);
								sprintf(sz_NewGaapDiff,"%.3lf",NewGaapDiff);
								CreationPrevision('P',ptb_InRec[PRE_ESTMNT_M],ptb_InRec, "23:59:15", ptb_InRec[PRE_GAAP_NF], sz_NewGaapDiff, "NA");
							}
							// CreationReserve
                            // Si la propagation n'a pas ete jouee lors du premier Compte Complet [021]
        					if ( Kb_PropaReserve == 1  &&
                                 (LIFDRI_COMACC_B != 1 && atoi(ptb_InRec[PRE_BATCH_B]) != 1)
                               )
        					{
        						// Pour tous les gaap on créé une ligne avec le montant de la reserve
     							CreationReserve('P',Ksz_MontantReserve,ptb_InRec, "23:59:15", ptb_InRec[PRE_GAAP_NF], "0","NA"); //[001]
        					}
        				}
        			}
					ptb_InRec[PRE_UPD_NF]=sz_regle;					
					// Si on est sur une constitution, on recherche le DETTRNCODE de libération
					unite=ptb_InRec[PRE_ACMTRS_NT][3];
				
				}
    	    }
		}
	// On sauvegarde la ligne pour pouvoir comparer à la ligne suivante
	sav_LignePrevPrecedente(ptb_InRec);
	
  RETURN_VAL (0);
}


/*==============================================================================
objet :     fonction de test de synchro
retour :    0 ---> synchro
            sinon, non trouve
==============================================================================*/
/* adresse de la ligne du GT *//* adresse de la ligne des previsions */
int n_ConditionSyncPrev(  char **pbd_InRecOwner, char **pbd_InRecChild  )
{
  int ret;
	
  DEBUT_FCT("n_ConditionSyncPrev");

//	printf("ok\n");
//	printf("%s\n", pbd_InRecChild[GT_CTR_NF]);
  if ((ret=strcmp(pbd_InRecOwner[GT_CTR_NF],  pbd_InRecChild[PRE_CTR_NF]))!=0)       RETURN_VAL (ret);
  if ((ret=strcmp(pbd_InRecOwner[GT_SEC_NF],  pbd_InRecChild[PRE_SEC_NF]))!=0)       RETURN_VAL (ret);
  if ((ret=strcmp(pbd_InRecOwner[GT_UWY_NF],  pbd_InRecChild[PRE_UWY_NF]))!=0)       RETURN_VAL (ret);
  if ((ret=strcmp(pbd_InRecOwner[GT_ACY_NF],  pbd_InRecChild[PRE_ACY_NF]))!=0)       RETURN_VAL (ret);
  if ((ret=strcmp(pbd_InRecOwner[GT_ACM_NF],  pbd_InRecChild[PRE_ESTMTH_NF]))!=0)    RETURN_VAL (ret);
//  if ((ret=strcmp(pbd_InRecOwner[GT_ACMTRS_NT],  pbd_InRecChild[PRE_ACMTRS_NT]))!=0)    RETURN_VAL (ret);
	
  RETURN_VAL (0);
}



/*==============================================================================
objet : fonction lancee pour chaque ligne des previsions synchronisee avec le GT
retour: 0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
                /* adresse de la ligne du GT, des previsions */
int n_ActionLignePrev( char **ptb_InRecOwner, char **ptb_InRecChild )
{
  	int n_GT,n_poste, n_comacimpact=0, resultposte, type_poste, propagation, result_bprop;
  	int flag_trstype, resultgaap, n_FlagFirst=0 ;
  	double d_MontantReserve, NewGaapDiff, Kf_Montant_gaapdiff;
  
  	char unite, *sz_poste, sz_amt[25]="", sz_cnatyp, sz_amt_gaapdiff[25]="";
  	char sz_AUTUPD[]=" ";
  	char sz_regle[]=" ";
  	char sz_NewGaapDiff[25];
 
  	DEBUT_FCT("n_ActionLignePrev");

  	Kb_SyncPrev=1;
//#==============
//#    TRACE
//#--------------
#ifdef TRACE_1
printf("**** n_ActionLignePrev:  [%s][%s][%s][%s][%s][%s]  reconduction\n",
    ptb_InRecChild[PRE_CTR_NF],
    ptb_InRecChild[PRE_UWY_NF],
    ptb_InRecChild[PRE_SEC_NF],
    ptb_InRecChild[PRE_ACY_NF],
    ptb_InRecChild[PRE_ACMTRS_NT],
    ptb_InRecChild[PRE_ESTMNT_M]);
#endif
//#--------------
//#  FIN TRACE
//#==============


	// SBE 07/02/2014 Ajout nouveau champs de sortie dans LIFEST de sortie
	// On place avant de reconduire les lignes dans le fichiers de sortie afin qu'elles soient à jour également
	// Dans les champs PRE_ORICRE_D(compte complet), PRE_ORISSD_CF(auto update), PRE_UPD_NF(test case)
	ptb_InRecChild[PRE_ORICRE_D]=ptb_InRecOwner[GT_COMACC_B];
	sprintf(sz_AUTUPD,"%d",Kb_AUTUPD);
	ptb_InRecChild[PRE_ORISSD_CF]=sz_AUTUPD;

    /* La prevision est reconduite dans tous les cas */
    // ptb_InRecChild[PRE_UPD_NF]=espace; SBE 07022014 on utilise ce champ pour le test case 
    n_WriteCols(Kp_PrevOFil,ptb_InRecChild,SEPARATEUR,0);
	result_bprop = n_RechSUBTRSESBPROP(&SubTrsEsBprop, ptb_InRecChild[PRE_DETTRNCOD_CF], ptb_InRecChild[PRE_SSD_CF], ptb_InRecChild[PRE_ESB_CF]);  // [019]
	if ( result_bprop != (-1) )
	{
		n_comacimpact=SubTrsEsBprop.COMACIMPACT_B;
	}


    /* Si le GT est en arrete statistique */
    if ( (ptb_InRecOwner[GT_COMACC_B][0]=='1') && (Kb_AUTUPD==1) && (n_comacimpact ==1) )
    {
        // Stockage du poste et de son chiffre des unites
        sz_poste=ptb_InRecChild[PRE_ACMTRS_NT];
        n_poste=atoi(sz_poste);
        unite=sz_poste[3];
        
        sz_cnatyp=atoi(ptb_InRecChild[PRE_CNATYP_CT]);

        // ajout JR
        // modif 14/11/03 = 2  
        // [002] Ajout 1393/1394/1383/1384 
        if ( ( sz_cnatyp != 3 && sz_cnatyp != 5 )  //[014] Ajout != 5
             &&
             ( (n_poste==1183) || (n_poste==1184) || (n_poste==1193) || (n_poste==1194) || (n_poste==1393) || (n_poste==1394) || (n_poste==1383) || (n_poste==1384) ) )         // [010] ajout de parentheses pour regrouper les postes et qu'ils soient tous conditionnes par le cnatyp
            RETURN_VAL (0);

        // [010]
        // [002] ajout 1363/1364/2363/2364
        if ( ( (n_poste==1163) || (n_poste==1164) ||
               (n_poste==2163) || (n_poste==2164) ||
               (n_poste==1363) || (n_poste==1364) ||
               (n_poste==2363) || (n_poste==2364)
                                   )  )
            RETURN_VAL (0);


        if ( n_comacimpact == 1 )
        {
         // On crée la ligne prévision avec le montant à 0
         //n_EcrirePrevAzero(ptb_InRecChild, sz_Date);
         //CreationPrevision('P',"0",ptb_InRecChild, "23:59:10",ptb_InRecChild[PRE_GAAP_NF], "0");
    		}
		    else
		    {
		    	RETURN_VAL (0);
		    }

        // n_GT=n_SyncGT(ptb_InRecChild[PRE_ACMTRS_NT]);
        /* Si la synchro. s'effectue jusqu'au poste détail ACMTRS/DETTRNCOD */
        /* Dans ce cas il faut écrire la ligne GT dans le fichier prévision */
        /* Action que l'on répète pour chaque lignes de gaap */
        n_GT=n_SyncGT(ptb_InRecChild[PRE_DETTRNCOD_CF]); // SBE 14/01/2014


//#==============
//#    TRACE
//#--------------
#ifdef TRACE_1
//if(strcmp(ptb_InRecTFAMCNA[GT_CTR_NF], ctr_test)==0)
printf("**** n_ActionLignePrev:  [%s][%s][%s][%s][%s]\n",
    ptb_InRecChild[PRE_CTR_NF],
    ptb_InRecChild[PRE_UWY_NF],
    ptb_InRecChild[PRE_SEC_NF],
    ptb_InRecChild[PRE_ACY_NF],
    ptb_InRecChild[PRE_ACMTRS_NT]);
#endif
//#--------------
//#  FIN TRACE
//#==============
        if (n_GT>=0)
        {
            init_SubTrsLigne();
            resultposte = n_FindTsubTRS(&SubTrsLigne,ptb_InRecChild[PRE_DETTRNCOD_CF]);
            
            if ( (strcmp(Kz_DETTRNCOD_prec,ptb_InRecChild[PRE_DETTRNCOD_CF])==0) 
                && (strcmp(Kz_PRE_UWY_NF_prec,ptb_InRecChild[PRE_UWY_NF])==0) 
                && (strcmp(Kz_PRE_CTR_N_prec,ptb_InRecChild[PRE_CTR_NF]) == 0) 
                && (strcmp(Kz_PRE_ACY_NF_prec,ptb_InRecChild[PRE_ACY_NF]) == 0) 
                && (strcmp(Kz_PRE_ACM_NF_prec,ptb_InRecChild[PRE_ESTMTH_NF]) == 0) )
            {
				// Dans le cas des cash et reserve et les montants des gaap {2,3,4} sont diff de gaap 1
				// Le montant des prevision des gaap {2,3,4} ne change pas [020] 
                if (resultposte != (-1) && (SubTrsLigne.TRSTYPE_CT == 2 || SubTrsLigne.TRSTYPE_CT == 3 ) 
                                        && (atof(Kbd_CleGT[n_GT].AMT_M) == 0)
                                        && (atof(ptb_InRecChild[PRE_ESTMNT_M]) != Kf_MontantGaap0Prev))
                {
                   Kf_Montant = atof(ptb_InRecChild[PRE_ESTMNT_M]);
                }
                else
                {
                  // On est sur le même dettrncod, on ajoute le diff au montant précédent
                  Kf_Montant=Kf_Montant+atof(ptb_InRecChild[PRE_GAAPDIFF_M]);
                }
                  n_FlagFirst = 0;
            }
            else
            {
                // On est sur le DETTRNCODE suivant
                n_FlagFirst = 1;
                strcpy(Kz_DETTRNCOD_prec,ptb_InRecChild[PRE_DETTRNCOD_CF]);
                strcpy(Kz_PRE_UWY_NF_prec,ptb_InRecChild[PRE_UWY_NF]);
                strcpy(Kz_PRE_ACY_NF_prec,ptb_InRecChild[PRE_ACY_NF]);
                strcpy(Kz_PRE_ACM_NF_prec,ptb_InRecChild[PRE_ESTMTH_NF]);
                strcpy(Kz_PRE_CTR_N_prec,ptb_InRecChild[PRE_CTR_NF]);
                Kf_Montant = atof(Kbd_CleGT[n_GT].AMT_M);
                Kf_MontantGaap0GT=Kf_Montant;
                Kf_MontantGaap0Prev=atof(ptb_InRecChild[PRE_ESTMNT_M]);
                // Si montant différent. Dans le cadre de la propagation des réserves, on va insérer cette différente dans 
                // le fichier de sortie des réserves. 
                // Différence = Montant Prevision - montant GT. Calcul de cette différence que sur le gaap 1. La reserve est ensuite reportee sur les autres gaap
                d_MontantReserve=Kf_MontantGaap0GT - Kf_MontantGaap0Prev;
                sprintf(Ksz_MontantReserve,"%.3lf",d_MontantReserve);
                
            }

            if ( SubTrsLigne.TRSNATURE_CT == 2 )
            {
                flag_ana = 1;
                sav_LignePrevAnalytic(ptb_InRecChild, n_FlagFirst, SubTrsLigne.TRSINPUTTYPE_CT);
            } else
            // Autres Postes que analytique
            // Si le montant est different de celui du GT, et pas sur une liberation
            //[018]

            if ( ( Kf_MontantGaap0Prev != Kf_MontantGaap0GT ) || (atof(sz_amt) == 0)) //&& (unite!='4') )
            {
                // Renseignement de la règle - Dans ce cas, si poste CASH 		règle = 1, 
                //si poste réserve	règle = 5

                // SI non trouvé TRSTYP = 1 on met TRSTYPE_CT = 1
                if ( resultposte == (-1) )
                {
                	flag_trstype = 1;
                }
                if ( SubTrsLigne.TRSTYPE_CT == 1 || flag_trstype == 1 )
                {
                    // poste Cash - Le montant est le même pour tous les gaap, on prend le montant du gaap 0
                    type_poste=1;
                    Kf_Montant=Kf_MontantGaap0GT;
                    sprintf(sz_regle,"%s","5");
                    ptb_InRecChild[PRE_UPD_NF]=sz_regle;
                    // Creation d'une nouvelle prevision
                    sprintf(sz_amt,"%.3lf", Kf_MontantGaap0GT);
                    CreationPrevision('P',sz_amt,ptb_InRecChild, "23:59:12", ptb_InRecChild[PRE_GAAP_NF], "0","NA");

                } else // Calcul pour poste Analytiques
                if (( SubTrsLigne.TRSTYPE_CT == 3 ) || 
                    ((SubTrsLigne.TRSINPUTTYPE_CT != 3) && (SubTrsLigne.TRSNATURE_CT == 2 ) && (SubTrsLigne.TRSTYPE_CT == 6))) //[005]
                {
                    // POSTE RESERVE - On applique le gaap diff au montant. On créé également une réserve
                    type_poste=3;
                    sprintf(sz_regle,"%s","1");
                    ptb_InRecChild[PRE_UPD_NF]=sz_regle;
                    // Creation d'une nouvelle prevision
                    //[007]
                    // spira 34950 - Si poste reserve on ne change pas le montant du gaap IFRS(2)  // [010]
                    if ((atof(ptb_InRecChild[PRE_ESTMNT_M])) == 0 && (ptb_InRecChild[PRE_GAAP_NF][0] == '1') )
                        		sav_MntPrevGaapCedente(1);

                    if ((atof(ptb_InRecChild[PRE_ESTMNT_M])) != 0 && (ptb_InRecChild[PRE_GAAP_NF][0] == '1') )
                        		sav_MntPrevGaapCedente(0);  		

                    if ( flag_Gaap ==1 )
                    {
	                    Kf_Montant = atof(ptb_InRecChild[PRE_ESTMNT_M]);
	                    if ( ptb_InRecChild[PRE_GAAP_NF][0] == '2' && atof(ptb_InRecChild[PRE_ESTMNT_M]) != 0 )
	                    {
	                        // Si gaap 2, on laisse le montant de l'estimation, sauf si le montant est égal à zero. 
	                        // Dans ce cas, on remplace le gaap 2 par la compta [012]
	                        Kf_Montant = atof(ptb_InRecChild[PRE_ESTMNT_M]);
	                    }
	                    else 
	                    {
	                        // Si autre gaap, si montant = 0 on met le montant de la compta
	                        // Sinon on laisse le montant de l'estimation initiale
	                        if ( Kf_Montant == 0 ) //|| (ptb_InRecChild[PRE_GAAP_NF][0] == '1')  )
	                        {
	                            Kf_Montant = atof(Kbd_CleGT[n_GT].AMT_M);
	                        }
	                        else 
	                        {
	                            Kf_Montant = atof(ptb_InRecChild[PRE_ESTMNT_M]);
	                        }
	                    }
	                    
                        // Pas de gaap interdit sur le gaap 1
                        if ( atoi(ptb_InRecChild[PRE_GAAP_NF]) == 1 )
                        {
                            resultgaap = 0;
                        }
                        else 
                        {
                            resultgaap = n_GaapInterdit(atoi(ptb_InRecChild[PRE_GAAP_NF]),&SubTrsEsBprop);
                        }
                    
                        if ( resultgaap == 0 )
                        {
                            Kf_Montant_gaapdiff = atof(ptb_InRecChild[PRE_GAAPDIFF_M]);
                        }
                        else 
                        {
                            Kf_Montant = 0;
                            Kf_Montant_gaapdiff = Kf_Montant - Kf_MontantPrec;
                            Kf_MontantPrec = 0;
                        }
                    }
                    else
                    {
                    	// Pas de gaap interdit sur le gaap 1
		                if ( atoi(ptb_InRecChild[PRE_GAAP_NF]) == 1 )
		                {
		                    resultgaap = 0;
		                }
		                else 
		                {
		                    resultgaap = n_GaapInterdit(atoi(ptb_InRecChild[PRE_GAAP_NF]),&SubTrsEsBprop);
		                }

		                if ( resultgaap == 0 )
		                {
		                    Kf_Montant_gaapdiff = atof(ptb_InRecChild[PRE_GAAPDIFF_M]);
		                }
		                else 
		                {
		                    Kf_Montant = 0;
		                    Kf_Montant_gaapdiff = Kf_Montant - Kf_MontantPrec;
		                    Kf_MontantPrec = 0;
		                }
                    }
                    // Fin [007]
                    // Fin [006]
                    
                    sprintf(sz_amt,"%.3lf", Kf_Montant);
                    sprintf(sz_amt_gaapdiff,"%.3lf", Kf_Montant_gaapdiff);
                    CreationPrevision('P',sz_amt,ptb_InRecChild, "23:59:12", ptb_InRecChild[PRE_GAAP_NF], sz_amt_gaapdiff,"NA");

                    // CreationReserve
                    // Si la propagation n'a pas ete jouee lors du premier Compte Complet [021]
                    if ( Kb_PropaReserve == 1  &&
                         (LIFDRI_COMACC_B != 1 && atoi(ptb_InRecChild[PRE_BATCH_B]) != 1)
                       )
                    {
                        // Pour tous les gaap on créé une ligne avec le montant de la reserve
                        CreationReserve('P',Ksz_MontantReserve,ptb_InRecChild, "23:59:12", ptb_InRecChild[PRE_GAAP_NF], "0","NA");
                    }
                    Kf_MontantPrec = Kf_Montant;
                }
                else // POSTE TRSTYPE_CT = 2,4,5,6
                {
                    // AUTRES POSTES - On applique le gaap diff au montant.
                    type_poste=3;
                    sprintf(sz_regle,"%s","1");
                    ptb_InRecChild[PRE_UPD_NF]=sz_regle;
                    // Creation d'une nouvelle prevision
                    sprintf(sz_amt,"%.3lf", Kf_Montant);
                    CreationPrevision('P',sz_amt,ptb_InRecChild, "23:59:12", ptb_InRecChild[PRE_GAAP_NF], ptb_InRecChild[PRE_GAAPDIFF_M],"NA");
                }
            }
            /* On enleve cette ligne du tableau GT (on considere que le */
            /* poste fait partie de la liste ssi ACMTRS_NT est non-nul) */
//#==============
//#    TRACE
//#--------------
#ifdef TRACE_1
//if(strcmp(ptb_InRecTFAMCNA[GT_CTR_NF], ctr_test)==0)
printf("**** n_ActionLignePrev:  Ecrasement de Kbd_CleGT[%d].ACMTRS_NT[%d]=0\n", n_GT, Kbd_CleGT[n_GT].ACMTRS_NT);
#endif
//#--------------
//#  FIN TRACE
//#==============
        Kbd_CleGT[n_GT].ACMTRS_NT=0;

        } /* Fin de la synchro jusque ACMTRS_NT */
        else // Equivalent PrevSansGT
        {
      	    if ( (strcmp(Kz_DETTRNCOD_prec,ptb_InRecChild[PRE_DETTRNCOD_CF]) !=0 ) 
                || (strcmp(Kz_PRE_UWY_NF_prec,ptb_InRecChild[PRE_UWY_NF]) != 0) 
                || (strcmp(Kz_PRE_CTR_N_prec,ptb_InRecChild[PRE_CTR_NF]) != 0) 
                || (strcmp(Kz_PRE_ACY_NF_prec,ptb_InRecChild[PRE_ACY_NF]) != 0) 
                || (strcmp(Kz_PRE_ACM_NF_prec,ptb_InRecChild[PRE_ESTMTH_NF]) != 0) )
        	{
        		// On est sur le DETTRNCODE suivant 
        		strcpy(Kz_DETTRNCOD_prec,ptb_InRecChild[PRE_DETTRNCOD_CF]);
        		strcpy(Kz_PRE_UWY_NF_prec,ptb_InRecChild[PRE_UWY_NF]);
        		strcpy(Kz_PRE_ACM_NF_prec,ptb_InRecChild[PRE_ESTMTH_NF]);
        		strcpy(Kz_PRE_CTR_N_prec,ptb_InRecChild[PRE_CTR_NF]);
        		Kf_MontantGaap0Prev=atof(ptb_InRecChild[PRE_ESTMNT_M]);
        		// Si montant différent. Dans le cadre de la propagation des réserves, on va insérer cette différente dans 
            	// le fichier de sortie des réserves. 
            	// Différence = Montant Prevision - montant GT. Calcul de cette différence que sur le gaap 1. La reserve est ensuite reportee sur les autres gaap
            	d_MontantReserve=Kf_MontantGaap0GT - Kf_MontantGaap0Prev;
            	sprintf(Ksz_MontantReserve,"%.3lf",d_MontantReserve);
            	n_FlagFirst = 1;
        	}
        	else 
            {
                n_FlagFirst = 0;
            }
            
            // [TAC02B - [007] Appel SUBTRS global. Cela permet de déterminer si on est sur un poste
            // [TAC02B - [007] analytique et de faire le traitement compte complet correspondant
            
            resultposte = n_FindTsubTRS(&SubTrsLigne,ptb_InRecChild[PRE_DETTRNCOD_CF]);
            if ( SubTrsLigne.TRSNATURE_CT == 2)
            {
                sav_LignePrevAnalytic(ptb_InRecChild, n_FlagFirst, SubTrsLigne.TRSINPUTTYPE_CT);
            }
            else

         	//if ( !( (unite=='4') || (atof(ptb_InRecChild[PRE_ESTMNT_M])==0) || (atoi(ptb_InRecOwner[GT_LOB_CF])==31) && ( (n_poste==1063) || (n_poste==1083) || (n_poste==2063) || (n_poste==2083) ) ) ) )
        	if ( !( (unite=='4') || (atof(ptb_InRecChild[PRE_ESTMNT_M])==0) ) )
         	{
            	ptb_InRecOwner[GT_ACCADMTYP_CT] = ptb_InRecChild[PRE_ACCADMTYP_CT]; //[016]
            	// Renseignement de la règle - Dans ce cas, si poste CASH 		règle = 7 
            	//											si poste réserve	règle = 3 ou 4 si Poste à propagation

        		// SI non trouvé TRSTYP = 1 on met TRSTYPE_CT = 1
     			if ( resultposte == (-1) )
				{
					flag_trstype = 1;
				}

                if ( SubTrsLigne.TRSTYPE_CT == 1 || flag_trstype == 1 )
                {
                	// Si poste CASH : On Positionne tous les gaap à zéro
                	type_poste=1;
                	sprintf(sz_regle,"%s","7");
                	ptb_InRecChild[PRE_UPD_NF]=sz_regle;
                	CreationPrevision('P',"0",ptb_InRecChild, "23:59:13", ptb_InRecChild[PRE_GAAP_NF], "0", "NA");//[001]
                } else // Calcul pour poste Analytiques
                if ( (SubTrsLigne.TRSTYPE_CT == 5 ) || (SubTrsLigne.TRSTYPE_CT == 6 ) )
                {
                    if ( SubTrsLigne.TRSINPUTTYPE_CT == 1 )
                    {
                        flag_ana = 1;
                    }
                    //sav_LignePrevAnalytic(ptb_InRecChild);
                } else
                if ( ((SubTrsLigne.TRSTYPE_CT == 3) || 
                    ((SubTrsLigne.TRSINPUTTYPE_CT != 3) && (SubTrsLigne.TRSNATURE_CT == 2 ) && (SubTrsLigne.TRSTYPE_CT == 6))) &&  ( atof(ptb_InRecChild[PRE_GAAPDIFF_M]) == 0 ) )  //[005]
                {
                	// Si poste reserve et propagation
                	// Si GAAPDIFF == 0 on considère qu'il y a propagation du GAAP 1
                	type_poste=3;
                	propagation = 1;
                	sprintf(sz_regle,"%s","3");
                	ptb_InRecChild[PRE_UPD_NF]=sz_regle;
                	CreationPrevision('P',"0",ptb_InRecChild, "23:59:13", ptb_InRecChild[PRE_GAAP_NF], "0", "NA");
                	// CreationReserve
                    // Si la propagation n'a pas ete jouee lors du premier Compte Complet [021]
                	if ( Kb_PropaReserve == 1  &&
                         (LIFDRI_COMACC_B != 1 && atoi(ptb_InRecChild[PRE_BATCH_B]) != 1)
                       )
                	{
                		// Pour tous les gaap on créé une ligne avec le montant de la reserve
                		CreationReserve('P',Ksz_MontantReserve,ptb_InRecChild, "23:59:13", ptb_InRecChild[PRE_GAAP_NF], "0","NA");
                	}
                } else
                if ( ((SubTrsLigne.TRSTYPE_CT == 3) || 
                    ((SubTrsLigne.TRSINPUTTYPE_CT != 3) && (SubTrsLigne.TRSNATURE_CT == 2 ) && (SubTrsLigne.TRSTYPE_CT == 6))) && ( atof(ptb_InRecChild[PRE_GAAPDIFF_M]) != 0 ) ) //[005]
                {
                	// Si poste reserve et pas de propagation
                	// Si GAAPDIFF != 0 on considère qu'il n'y a pas de propagation du GAAP 1
                	type_poste=3;
                	propagation = 0;
                	sprintf(sz_regle,"%s","4");
                	ptb_InRecChild[PRE_UPD_NF]=sz_regle;
                	if ( strcmp(ptb_InRecChild[PRE_GAAP_NF],"1") == 0 || n_FlagFirst == 1 ) 
                	{
                		// Si GAAP 1 on écrase à 0
                		//ptb_InRecChild[PRE_ESTMNT_M]="0";
                		CreationPrevision('P',ptb_InRecChild[PRE_GAAPDIFF_M],ptb_InRecChild, "23:59:13", ptb_InRecChild[PRE_GAAP_NF], ptb_InRecChild[PRE_GAAPDIFF_M], "NA");
                		n_FlagFirst = 0;
                	}
                	else
                	{
                		// Si autres GAAP on réécrit les gaap avec les memes montants
                		NewGaapDiff=atof(ptb_InRecChild[PRE_ESTMNT_M])-atof(psz_SavLignePrevPrecedente[PRE_ESTMNT_M]);
                		sprintf(sz_NewGaapDiff,"%.3lf",NewGaapDiff);
                		CreationPrevision('P',ptb_InRecChild[PRE_ESTMNT_M],ptb_InRecChild, "23:59:13", ptb_InRecChild[PRE_GAAP_NF], sz_NewGaapDiff, "NA");
                	}
                	// CreationReserve
                    // Si la propagation n'a pas ete jouee lors du premier Compte Complet [021]
                	if ( Kb_PropaReserve == 1  &&
                         (LIFDRI_COMACC_B != 1 && atoi(ptb_InRecChild[PRE_BATCH_B]) != 1)
                       )
                	{
                		// Pour tous les gaap on créé une ligne avec le montant de la reserve
                		CreationReserve('P',Ksz_MontantReserve,ptb_InRecChild, "23:59:13", ptb_InRecChild[PRE_GAAP_NF], "0","NA");
                	}
                } // else Si autres postes type 2,4,5,6
                else // Autres postes - Traitement à confirmer
                {
                    if ( (atof(ptb_InRecChild[PRE_GAAPDIFF_M]) == 0) && ( atof(ptb_InRecChild[PRE_GAAPDIFF_M]) == 0 ) ) // NEWBALSHEETPROPAG_B -> Propagation
                    {
                	    // Si autre poste et propagation
                	    propagation = 1;
                	    sprintf(sz_regle,"%s","3");
                	    ptb_InRecChild[PRE_UPD_NF]=sz_regle;
                	    CreationPrevision('P',"0",ptb_InRecChild, "23:59:13", ptb_InRecChild[PRE_GAAP_NF], "0", "NA");
                    }
                    else
                    {
                        // autre poste et pas de propagation
                	    propagation = 0;
                	    sprintf(sz_regle,"%s","4");
                	    ptb_InRecChild[PRE_UPD_NF]=sz_regle;
                	    if ( strcmp(ptb_InRecChild[PRE_GAAP_NF],"1") == 0 ) 
                	    {
                	        // Si GAAP 1 On applique le gaap diff - Spira 29537
                	        ptb_InRecChild[PRE_ESTMNT_M]="0";
                	        CreationPrevision('P',"0",ptb_InRecChild, "23:59:13", ptb_InRecChild[PRE_GAAP_NF], "0", "NA");
                	    }
                	    else
                	    {
                		    // Si autres GAAP on réécrit les gaap avec les memes montants
                		    NewGaapDiff=atof(ptb_InRecChild[PRE_ESTMNT_M])-atof(psz_SavLignePrevPrecedente[PRE_ESTMNT_M]);
                		    sprintf(sz_NewGaapDiff,"%.3lf",NewGaapDiff);
                		    CreationPrevision('P',ptb_InRecChild[PRE_ESTMNT_M],ptb_InRecChild, "23:59:13", ptb_InRecChild[PRE_GAAP_NF], sz_NewGaapDiff, "NA");
                	    }
                    }
                }
            }
            n_FlagFirst = 0;
        }
    }    // On sauvegarde la ligne pour pouvoir comparer à la ligne suivante
    sav_LignePrevPrecedente(ptb_InRecChild);
    
  RETURN_VAL (0);
}

/*=============================================================================
objet:  Sauvegarde la ligne prevision pour comparaison

Parametre:  La ligne courante des previsions
=============================================================================*/
void sav_LignePrevPrecedente(char ** pbd_LignePrev)
{
    int i;

    for (i=0;i < PRE_NBCOL; i++)
    {
         strcpy(psz_SavLignePrevPrecedente[i],pbd_LignePrev[i]);
    }
}

/*=============================================================================
objet:  Flag initilaiser pour detecter la gaap cedente

Parametre:  La ligne courante des previsions
=============================================================================*/
int sav_MntPrevGaapCedente(int flag )
{
    flag_Gaap = flag;
    return flag_Gaap;
}

/*=============================================================================
objet:  Memorise dans un tableau la cle de la ligne courante du GT avec
        le montant qui l'accompagne
Parametre:  La ligne courante du GT
Modif SBE 14/01/2014: On travaille sur le DETTRNCOD_CF
=============================================================================*/
void MemoGT (char **ptb_InRec)
{
    char sz_tmp[50];
    DEBUT_FCT("MemoGT");
    sprintf(sz_tmp,"%.5s", ptb_InRec[GT_TRNCOD_CF]+2);
    /* On memorise le poste et le poste détail*/
        
    Kbd_CleGT[Kn_CleGT].ACMTRS_NT=atoi(ptb_InRec[GT_ACMTRS_NT]);
    Kbd_CleGT[Kn_CleGT].TRNCOD_CF=atoi(sz_tmp);
    strcpy(Kbd_CleGT[Kn_CleGT].AMT_M,ptb_InRec[GT_ESTAMT_M]);
    Kbd_CleGT[Kn_CleGT].ACMTRS2_NT=atoi(ptb_InRec[GT_ACMTRS_NT]);  /* jr 05/09/2003 */
    //Kbd_CleGT[Kn_CleGT].TRNCOD_CF2=atoi(sz_tmp);
    strcpy(Kbd_CleGT[Kn_CleGT].TypePoste,ptb_InRec[GT_ADJCOD_CT]);
    
    Kn_CleGT++;

 RETURN_VOID();
}


/*=============================================================================
objet:      Verifie la synchronisation des previsions avec le GT jusqu'a ACMTRS_NT/DETTRNCOD
Parametre:  Le poste regroupe des previsions
Retour: -> la ligne correspondante dans le tableau GT
        -> -1 si non trouve
=============================================================================*/
int n_SyncGT(char *DETTRNCOD_CF)
//int n_SyncGT(char *ACMTRS_NT, char *DETTRNCOD_CF)
{
    int i;

    DEBUT_FCT("n_SyncGT");

    for (i=0;i<Kn_CleGT;i++)
    {
        if (Kbd_CleGT[i].TRNCOD_CF==atoi(DETTRNCOD_CF))    RETURN_VAL(i);
    }

	RETURN_VAL(-1);
}


/*=============================================================================
objet:  Cree un enregistrement dans le fichier des previsions en sortie avec:
        - le montant passe
        - si l'indicateur de mise a jour est I, le pointeur represente le GT,
          sinon il represente la ligne de prevision courante
Parametres:
        - l'indicateur d'origine (G pour GT, P pour Previsions)
        - le montant sous forme de chaine de caracteres
        - le pointeur sur le GT/la prevision
        
Modifications SBE 22/01/2014 - Prise en compte Multigaap
=============================================================================*/
void CreationPrevision(char c_origine,char *AMT_M,char **ptb_InRec, char *sz_date, char *GAAP, char *GAAPDIFF, char *sz_regle)
{
    int i;
    char *psz_ligne[PRE_NBCOL+1],
    sz_prs[]="500",
    sz_amt[22];
    char sz_new_cre[20], sz_dettrncod[]="DETTR";
    char sz_lib_oricod[12] = "ARRETE STAT";
    char sz_AUTUPD[]=" ";
    
    DEBUT_FCT("CreationPrevision");
    
    if (c_origine=='G')
    {
        //[018]
        for (i=0;i<=PRE_NBCOLNEW;i++)
            psz_ligne[i]=" ";
        psz_ligne[PRE_NBCOL]=NULL;

        psz_ligne[PRE_SSD_CF]=ptb_InRec[GT_SSD_CF];
        psz_ligne[PRE_ESB_CF]=ptb_InRec[GT_ESB_CF];
        psz_ligne[PRE_CTR_NF]=ptb_InRec[GT_CTR_NF];
        psz_ligne[PRE_END_NT]=ptb_InRec[GT_END_NT];
        psz_ligne[PRE_SEC_NF]=ptb_InRec[GT_SEC_NF];
        psz_ligne[PRE_UWY_NF]=ptb_InRec[GT_UWY_NF];
        psz_ligne[PRE_UW_NT]=ptb_InRec[GT_UW_NT];
        psz_ligne[PRE_ACY_NF]=ptb_InRec[GT_ACY_NF];
        psz_ligne[PRE_ESTMTH_NF]=ptb_InRec[GT_ACM_NF];
        // On vérifie la longueur du GT_TRNCOD_CF, si longueur = 8, on passe a 5
        if ( (strlen(ptb_InRec[GT_TRNCOD_CF])==8 ) )
        {
            sprintf(sz_dettrncod,"%.5s",ptb_InRec[GT_TRNCOD_CF]+2);
            psz_ligne[PRE_DETTRNCOD_CF]=sz_dettrncod;
        }
        else
            psz_ligne[PRE_DETTRNCOD_CF]=ptb_InRec[GT_TRNCOD_CF]; // Le TRNCOD est sur 5 caracteres a ce moment
            
        psz_ligne[PRE_ACMTRS_NT]=ptb_InRec[GT_ACMTRS_NT];
        psz_ligne[PRE_PRS_CF]=sz_prs;
        psz_ligne[PRE_CUR_CF]=ptb_InRec[GT_ESTCUR_CF];
        psz_ligne[PRE_LOB_CF]=ptb_InRec[GT_LOB_CF];
        psz_ligne[PRE_ACCADMTYP_CT]=ptb_InRec[GT_ACCADMTYP_CT];
        psz_ligne[PRE_ESTCRB_CT]=ptb_InRec[GT_ESTCRB_CT];
        psz_ligne[PRE_CED_NF]=ptb_InRec[GT_CED_NF];
        psz_ligne[PRE_BRK_NF]=ptb_InRec[GT_BRK_NF];
        psz_ligne[PRE_PAY_NF]=ptb_InRec[GT_PAY_NF];
        psz_ligne[PRE_ADJCOD_CT]=ptb_InRec[GT_ADJCOD_CT];
        psz_ligne[PRE_RETCOD_CT]=ptb_InRec[GT_ORICOD_LS];
        psz_ligne[PRE_DETTRS_CF]=ptb_InRec[GT_DETTRS_CF];
        psz_ligne[PRE_ACCRET_B]=ptb_InRec[GT_ACCRET_B];
        psz_ligne[PRE_UWGRP_CF]=ptb_InRec[GT_UWGRP_CF];
        psz_ligne[PRE_ESTCRB_CT]=ptb_InRec[GT_ESTCRB_CT];
        
        // SBE 07/02/2014 Ajout nouveau champs de sortie dans LIFEST de sortie
        // On place avant de reconduire les lignes dans le fichiers de sortie afin qu'elles soient à jour également
        // Dans les champs PRE_ORICRE_D(compte complet), PRE_ORISSD_CF(auto update), PRE_UPD_NF(test case)
        
        psz_ligne[PRE_ORICRE_D]=ptb_InRec[GT_COMACC_B];
        sprintf(sz_AUTUPD,"%d",Kb_AUTUPD);
        psz_ligne[PRE_ORISSD_CF]=sz_AUTUPD;
        psz_ligne[PRE_UPD_NF]=sz_regle;
    }
    else
    {
        /*for (i=0;i<(PRE_NBCOLNEW -1);i++)*/
        //[018]
        for (i=0;i<(PRE_NBCOLNEW);i++)
            psz_ligne[i]=ptb_InRec[i];

        psz_ligne[PRE_NBCOLNEW]="0";
        psz_ligne[PRE_NBCOL]=0;
    }

    /* Annee et mois bilan, indicateur maj, date de creation */
    psz_ligne[PRE_BALSHEY_NF]=Ksz_Balshey;
    psz_ligne[PRE_BALSHTMTH_NF]=Ksz_Balshtmth;
    //psz_ligne[PRE_UPD_NF]=sz_maj;
    //sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:59:14");
    //MME: modif : 03062014
    memset(sz_new_cre, 0, sizeof(sz_new_cre));
    sprintf(sz_new_cre, "%s %s", Ksz_DateJour, sz_date);
    psz_ligne[PRE_CRE_D]= sz_new_cre;
    psz_ligne[PRE_BATCH_B]="1";
    /* PRE_CNATYP_CT  JR 05/06/03 */
    /* if ( atoi( ptb_InRec[PRE_CNATYP_CT] ) == 2 )
        {*/

    /* Substitution du montant */
    sprintf(sz_amt,"%.3lf",atof(AMT_M));
    psz_ligne[PRE_ESTMNT_M]=sz_amt;
		/*  }   */

    /* Mise a blanc ou zero */
    psz_ligne[PRE_INDSUP_B]= "0";
    psz_ligne[PRE_CREUSR_CF]=  "dbo";
    psz_ligne[PRE_ORICOD_LS]= sz_lib_oricod;  /* JR  ajout 23/04/03 */
    psz_ligne[PRE_LSTUPD_D]= sz_new_cre;
    psz_ligne[PRE_LSTUPDUSR_CF]= "dbo";
    /* 06/01/2014: Modif MME */ 
    psz_ligne[PRE_NBCOLNEW]= "0";
    psz_ligne[PRE_NBCOL]=0;

//#==============
//#    TRACE
//#--------------
#ifdef TRACE_1
printf("**** n_ActionLignePrev:  [%s][%s][%s][%s][%s][%s]  ecriture\n",
    ptb_InRec[PRE_CTR_NF],
    ptb_InRec[PRE_UWY_NF],
    ptb_InRec[PRE_SEC_NF],
    ptb_InRec[PRE_ACY_NF],
    ptb_InRec[PRE_ACMTRS_NT],
    ptb_InRec[PRE_ESTMNT_M]);
#endif
//#--------------
//#  FIN TRACE
//#==============
    psz_ligne[PRE_GAAP_NF]=GAAP;
    psz_ligne[PRE_GAAPDIFF_M]=GAAPDIFF;
if (strcmp(psz_ligne[PRE_ACMTRS_NT], "2340") == 0 && strcmp(psz_ligne[PRE_CTR_NF], "20P000118") == 0) 
	printf("CTR=%s, ACMTRS=%s, ESTMNT=%s\n",psz_ligne[PRE_CTR_NF], psz_ligne[PRE_ACMTRS_NT], psz_ligne[PRE_ESTMNT_M]);
    n_WriteCols(Kp_PrevOFil,psz_ligne,SEPARATEUR,0);
    
  RETURN_VOID();
}


/*=============================================================================
objet:  Cree un enregistrement dans le fichier des previsions reserve en sortie avec:
        - le montant passe
        - si l'indicateur de mise a jour est I, le pointeur represente le GT,
          sinon il represente la ligne de prevision courante
Parametres:
        - l'indicateur d'origine (G pour GT, P pour Previsions)
        - le montant sous forme de chaine de caracteres
        - le pointeur sur le GT/la prevision
        
=============================================================================*/
void CreationReserve (char c_origine,char *AMT_M,char **ptb_InRec, char *sz_date, char *GAAP, char *GAAPDIFF, char *sz_regle)
{
    DEBUT_FCT("CreationReserve");

    // Si pas de changement --> rien a propager
    if (Arrondi(atof(AMT_M)) == 0)
    {
       RETURN_VOID();
    }
    int i, acy_reserve,acy_reserve_sav, uwy_reserve,uwy_reserve_sav , r;
    char *psz_ligne[PRE_NBCOL+1],
    sz_prs[]="500",
    sz_amt[22];
    char sz_new_cre[20], sz_dettrncod[]="DETTR";
    char sz_lib_oricod[12] = "ARRETE STAT";
    char sz_AUTUPD[]=" ";
    
    DEBUT_FCT("CreationPrevision");
    if (c_origine=='G')
    {
        //[018]
        /*for (i=0;i<PRE_NBCOLNEW;i++)*/
        for (i=0;i<=PRE_NBCOLNEW;i++)
            psz_ligne[i]=" ";
        psz_ligne[PRE_NBCOL]=0;

        psz_ligne[PRE_SSD_CF]=ptb_InRec[GT_SSD_CF];
        psz_ligne[PRE_ESB_CF]=ptb_InRec[GT_ESB_CF];
        psz_ligne[PRE_CTR_NF]=ptb_InRec[GT_CTR_NF];
        psz_ligne[PRE_END_NT]=ptb_InRec[GT_END_NT];
        psz_ligne[PRE_SEC_NF]=ptb_InRec[GT_SEC_NF];
        psz_ligne[PRE_UWY_NF]=ptb_InRec[GT_UWY_NF];
        psz_ligne[PRE_UW_NT]=ptb_InRec[GT_UW_NT];
        psz_ligne[PRE_ACY_NF]=ptb_InRec[GT_ACY_NF];
        psz_ligne[PRE_ESTMTH_NF]=ptb_InRec[GT_ACM_NF];
        // On vérifie la longueur du GT_TRNCOD_CF, si longueur = 8, on passe a 5
        if ( (strlen(ptb_InRec[GT_TRNCOD_CF])==8 ) )
        {
            sprintf(sz_dettrncod,"%.5s",ptb_InRec[GT_TRNCOD_CF]+2);
            psz_ligne[PRE_DETTRNCOD_CF]=sz_dettrncod;
        }
        else
            psz_ligne[PRE_DETTRNCOD_CF]=ptb_InRec[GT_TRNCOD_CF]; // Le TRNCOD est sur 5 caracteres a ce moment
            
        psz_ligne[PRE_ACMTRS_NT]=ptb_InRec[GT_ACMTRS_NT];
        psz_ligne[PRE_PRS_CF]=sz_prs;
        psz_ligne[PRE_CUR_CF]=ptb_InRec[GT_ESTCUR_CF];
        psz_ligne[PRE_LOB_CF]=ptb_InRec[GT_LOB_CF];
        psz_ligne[PRE_ACCADMTYP_CT]=ptb_InRec[GT_ACCADMTYP_CT];
        psz_ligne[PRE_ESTCRB_CT]=ptb_InRec[GT_ESTCRB_CT];
        psz_ligne[PRE_CED_NF]=ptb_InRec[GT_CED_NF];
        psz_ligne[PRE_BRK_NF]=ptb_InRec[GT_BRK_NF];
        psz_ligne[PRE_PAY_NF]=ptb_InRec[GT_PAY_NF];
        psz_ligne[PRE_ADJCOD_CT]=ptb_InRec[GT_ADJCOD_CT];
        psz_ligne[PRE_RETCOD_CT]=ptb_InRec[GT_ORICOD_LS];
        psz_ligne[PRE_DETTRS_CF]=ptb_InRec[GT_DETTRS_CF];
        psz_ligne[PRE_ACCRET_B]=ptb_InRec[GT_ACCRET_B];
        psz_ligne[PRE_UWGRP_CF]=ptb_InRec[GT_UWGRP_CF];
        psz_ligne[PRE_ESTCRB_CT]=ptb_InRec[GT_ESTCRB_CT];
        
        // SBE 07/02/2014 Ajout nouveau champs de sortie dans LIFEST de sortie
        // On place avant de reconduire les lignes dans le fichiers de sortie afin qu'elles soient à jour également
        // Dans les champs PRE_ORICRE_D(compte complet), PRE_ORISSD_CF(auto update), PRE_UPD_NF(test case)
        
        psz_ligne[PRE_ORICRE_D]=ptb_InRec[GT_COMACC_B];
        sprintf(sz_AUTUPD,"%d",Kb_AUTUPD);
        psz_ligne[PRE_ORISSD_CF]=sz_AUTUPD;
        psz_ligne[PRE_UPD_NF]=sz_regle;
    }
    else
    {
        //[018]
        /*for (i=0;i<(PRE_NBCOLNEW -1);i++)*/
        for (i=0;i<(PRE_NBCOLNEW);i++)
            psz_ligne[i]=ptb_InRec[i];

        psz_ligne[PRE_NBCOLNEW]="0";
        psz_ligne[PRE_NBCOL]=0;
    }

    /* Annee et mois bilan, indicateur maj, date de creation */
    psz_ligne[PRE_BALSHEY_NF]=Ksz_Balshey;
    psz_ligne[PRE_BALSHTMTH_NF]=Ksz_Balshtmth;
    //psz_ligne[PRE_UPD_NF]=sz_maj;
    //sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:59:14");
    //MME modif
    memset(sz_new_cre,0, sizeof(sz_new_cre));
    sprintf(sz_new_cre, "%s %s", Ksz_DateJour, sz_date);
    strcpy(psz_ligne[PRE_CRE_D],sz_new_cre);

    psz_ligne[PRE_BATCH_B]="1";


    /* [017] Si gaap cedante, si traite auto et si montant gaap 1 = 0, on laisse le montant de la reserve à 0 */
    if ( ! (strcmp(psz_ligne[PRE_ESTCRB_CT],"A")==0  && strcmp(psz_ligne[PRE_GAAP_NF],"1") == 0  && atof(psz_ligne[PRE_ESTMNT_M]) ==0) )
    {
        sprintf(sz_amt,"%.3lf",Arrondi(atof(AMT_M)));
        psz_ligne[PRE_ESTMNT_M]=sz_amt;        
    }

    /* Mise a blanc ou zero */
    psz_ligne[PRE_INDSUP_B]= "0";
    psz_ligne[PRE_CREUSR_CF]=  "dbo";
    psz_ligne[PRE_ORICOD_LS]= sz_lib_oricod;  /* JR  ajout 23/04/03 */
    psz_ligne[PRE_LSTUPD_D]= sz_new_cre;
    psz_ligne[PRE_LSTUPDUSR_CF]= "dbo";
    /* 06/01/2014: Modif MME */ 
    psz_ligne[PRE_NBCOLNEW]= "0";
    psz_ligne[PRE_NBCOL]=0;


    psz_ligne[PRE_GAAP_NF]=GAAP;
    psz_ligne[PRE_GAAPDIFF_M]=GAAPDIFF;
    	
    // On cree les lignes de report des reserve pour les 4 années suivantes l'année de compte; BALYEAR
    acy_reserve=atoi(psz_ligne[PRE_ACY_NF]);
    uwy_reserve=atoi(psz_ligne[PRE_UWY_NF]);
    acy_reserve_sav=acy_reserve;
    uwy_reserve_sav=uwy_reserve;
    for (r=acy_reserve+1 ; r<=Kn_BalYear+LIF_ACY_MAX ; r++)
    {
        // Si type comptable = 1, on positionne UWY_NF = ACY_NF
        if ( psz_ligne[PRE_ACCADMTYP_CT][0] == '1' )
        {
            sprintf(psz_ligne[PRE_UWY_NF],"%d",r);
        }
        if ( r > Kn_BalYear)
        {
            // Si année > année bilan
            sprintf(psz_ligne[PRE_ACY_NF],"%d",r);
            n_WriteCols(Kp_ReserveNoAccOFil,psz_ligne,SEPARATEUR,0);
        }
        else
        {
            // si année <= Année bilan
            sprintf(psz_ligne[PRE_ACY_NF],"%d",r);
            n_WriteCols(Kp_ReserveOFil,psz_ligne,SEPARATEUR,0);
        }
    }
    sprintf(psz_ligne[PRE_ACY_NF],"%d",acy_reserve_sav);
    sprintf(psz_ligne[PRE_UWY_NF],"%d",uwy_reserve_sav);
    
	RETURN_VOID();
}

void CreationReserveAna (char c_origine,char *AMT_M,char **ptb_InRec, char *sz_date, char *GAAP, char *GAAPDIFF, char *sz_regle)
{
    DEBUT_FCT("CreationReserve");

    // Si pas de changement --> rien a propager
    if (Arrondi(atof(AMT_M)) == 0)
    {
       RETURN_VOID();
    }

    int i, acy_reserve,acy_reserve_sav, uwy_reserve,uwy_reserve_sav , r;
    char *psz_ligne[PRE_NBCOL+1],
    sz_prs[]="500",
    sz_amt[22];
    char sz_new_cre[20], sz_dettrncod[]="DETTR";
    char sz_AUTUPD[]=" ";
    
    DEBUT_FCT("CreationPrevision");

    if (c_origine=='G')
    {
        //[018]
        /*for (i=0;i<PRE_NBCOLNEW;i++)*/
        for (i=0;i<=PRE_NBCOLNEW;i++)
            psz_ligne[i]=" ";
        psz_ligne[PRE_NBCOL]=0;

        psz_ligne[PRE_SSD_CF]=ptb_InRec[GT_SSD_CF];
        psz_ligne[PRE_ESB_CF]=ptb_InRec[GT_ESB_CF];
        psz_ligne[PRE_CTR_NF]=ptb_InRec[GT_CTR_NF];
        psz_ligne[PRE_END_NT]=ptb_InRec[GT_END_NT];
        psz_ligne[PRE_SEC_NF]=ptb_InRec[GT_SEC_NF];
        psz_ligne[PRE_UWY_NF]=ptb_InRec[GT_UWY_NF];
        psz_ligne[PRE_UW_NT]=ptb_InRec[GT_UW_NT];
        psz_ligne[PRE_ACY_NF]=ptb_InRec[GT_ACY_NF];
        psz_ligne[PRE_ESTMTH_NF]=ptb_InRec[GT_ACM_NF];
        // On vérifie la longueur du GT_TRNCOD_CF, si longueur = 8, on passe a 5
        if ( (strlen(ptb_InRec[GT_TRNCOD_CF])==8 ) )
        {
            sprintf(sz_dettrncod,"%.5s",ptb_InRec[GT_TRNCOD_CF]+2);
            psz_ligne[PRE_DETTRNCOD_CF]=sz_dettrncod;
        }
        else
            psz_ligne[PRE_DETTRNCOD_CF]=ptb_InRec[GT_TRNCOD_CF]; // Le TRNCOD est sur 5 caracteres a ce moment
            
        psz_ligne[PRE_ACMTRS_NT]=ptb_InRec[GT_ACMTRS_NT];
        psz_ligne[PRE_PRS_CF]=sz_prs;
        psz_ligne[PRE_CUR_CF]=ptb_InRec[GT_ESTCUR_CF];
        psz_ligne[PRE_LOB_CF]=ptb_InRec[GT_LOB_CF];
        psz_ligne[PRE_ACCADMTYP_CT]=ptb_InRec[GT_ACCADMTYP_CT];
        psz_ligne[PRE_ESTCRB_CT]=ptb_InRec[GT_ESTCRB_CT];
        psz_ligne[PRE_CED_NF]=ptb_InRec[GT_CED_NF];
        psz_ligne[PRE_BRK_NF]=ptb_InRec[GT_BRK_NF];
        psz_ligne[PRE_PAY_NF]=ptb_InRec[GT_PAY_NF];
        psz_ligne[PRE_ADJCOD_CT]=ptb_InRec[GT_ADJCOD_CT];
        psz_ligne[PRE_RETCOD_CT]=ptb_InRec[GT_ORICOD_LS];
        psz_ligne[PRE_DETTRS_CF]=ptb_InRec[GT_DETTRS_CF];
        psz_ligne[PRE_ACCRET_B]=ptb_InRec[GT_ACCRET_B];
        psz_ligne[PRE_UWGRP_CF]=ptb_InRec[GT_UWGRP_CF];
        psz_ligne[PRE_ESTCRB_CT]=ptb_InRec[GT_ESTCRB_CT];
        
        // SBE 07/02/2014 Ajout nouveau champs de sortie dans LIFEST de sortie
        // On place avant de reconduire les lignes dans le fichiers de sortie afin qu'elles soient à jour également
        // Dans les champs PRE_ORICRE_D(compte complet), PRE_ORISSD_CF(auto update), PRE_UPD_NF(test case)
        
        psz_ligne[PRE_ORICRE_D]=ptb_InRec[GT_COMACC_B];
        sprintf(sz_AUTUPD,"%d",Kb_AUTUPD);
        psz_ligne[PRE_ORISSD_CF]=sz_AUTUPD;
        psz_ligne[PRE_UPD_NF]=sz_regle;
    }
    else
    {
        //[018]
        /*for (i=0;i<(PRE_NBCOLNEW -1);i++)*/
        for (i=0;i<(PRE_NBCOLNEW);i++)
            psz_ligne[i]=ptb_InRec[i];

        psz_ligne[PRE_NBCOLNEW]="0";
        psz_ligne[PRE_NBCOL]=0;
    }

    /* Annee et mois bilan, indicateur maj, date de creation */
    psz_ligne[PRE_BALSHEY_NF]=Ksz_Balshey;
    psz_ligne[PRE_BALSHTMTH_NF]=Ksz_Balshtmth;
    //psz_ligne[PRE_UPD_NF]=sz_maj;
    //sprintf(sz_new_cre, "%s %s", Ksz_DateJour, "23:59:14");
    //MME modif
    memset(sz_new_cre,0, sizeof(sz_new_cre));
    sprintf(sz_new_cre, "%s %s", Ksz_DateJour, sz_date);
    strcpy(psz_ligne[PRE_CRE_D],sz_new_cre);

    psz_ligne[PRE_BATCH_B]="1";

    /* Substitution du montant */
    sprintf(sz_amt,"%.3lf",atof(AMT_M));
    psz_ligne[PRE_ESTMNT_M]=sz_amt;
 /*  }   */

    /* Mise a blanc ou zero */
    psz_ligne[PRE_INDSUP_B]= "0";
    psz_ligne[PRE_CREUSR_CF]=  "dbo";
    //psz_ligne[PRE_ORICOD_LS]= sz_lib_oricod;  /* JR  ajout 23/04/03 */
    psz_ligne[PRE_LSTUPD_D]= sz_new_cre;
    psz_ligne[PRE_LSTUPDUSR_CF]= "dbo";
    /* 06/01/2014: Modif MME */ 
    psz_ligne[PRE_NBCOLNEW]= "0";
    psz_ligne[PRE_NBCOL]=0;


    psz_ligne[PRE_GAAP_NF]=GAAP;
    psz_ligne[PRE_GAAPDIFF_M]=GAAPDIFF;
    	
    // On cree les lignes de report des reserve pour les 4 années suivantes l'année de compte; BALYEAR
    acy_reserve=atoi(psz_ligne[PRE_ACY_NF]);
    uwy_reserve=atoi(psz_ligne[PRE_UWY_NF]);
    acy_reserve_sav=acy_reserve;
    uwy_reserve_sav=uwy_reserve;
    for (r=acy_reserve+1 ; r<=Kn_BalYear+LIF_ACY_MAX ; r++)
    {
        // Si type comptable = 1, on positionne UWY_NF = ACY_NF
        if ( psz_ligne[PRE_ACCADMTYP_CT][0] == '1' )
        {
            sprintf(psz_ligne[PRE_UWY_NF],"%d",r);
        }
        if ( r > Kn_BalYear)
        {
            // Si année > année bilan
            sprintf(psz_ligne[PRE_ACY_NF],"%d",r);
            n_WriteCols(Kp_ReserveNoAccOFil,psz_ligne,SEPARATEUR,0);
        }
        else
        {
            // si année <= Année bilan
            sprintf(psz_ligne[PRE_ACY_NF],"%d",r);
            n_WriteCols(Kp_ReserveOFil,psz_ligne,SEPARATEUR,0);
        }
    }
    sprintf(psz_ligne[PRE_ACY_NF],"%d",acy_reserve_sav);
    sprintf(psz_ligne[PRE_UWY_NF],"%d",uwy_reserve_sav);
    
	RETURN_VOID();
}

/*=============================================================================
objet:  Cree la liberation correspondante a la reserve si on est sur une constitution
        
=============================================================================*/

/*=============================================================================
objet:
        Retourne si le gaap passé en paramètre est interdit ou non
Parametre:
        
Retour:
        -> OK
=============================================================================*/
int n_GaapInterdit( int n_gaap, T_SUBTRSESBPROP * s_EsbProp )
{
    switch(n_gaap)
    {
		case 1:
    		return 0;
    		break;
		case 2:
			if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
			{
                return 1;
			}
			else
			{
                return 0;
			}
			break;
		case 3:
			if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
			{
			    return 1;
			}
			else
			{
			    return 0;
			}
			break;
		case 4:
			if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
			{
			    return 1;
			}
			else
            {
			    return 0;
            }
				break;            				            				
		case 5:
    	    if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
    		{
    		    return 1;
			}
			else
			{
			    return 0;
			}
    		break;
	}    
    
    RETURN_VAL(1);
}


/*=============================================================================
objet:
        ajoute une ligne dans le tableau Kpbd_CPPILOT et la remplie avec *pb_new
Parametre:
        la nouvelle ligne*pb_new
Retour:
        -> OK
=============================================================================*/

int n_AddCPLIFDRI(T_LIFDRI_ALL_QUARTER *pbd_new)
{
	int i;

	DEBUT_FCT("n_AddCPLIFDRI");
	for(i=0;i<Kn_NbLigCPPilot;i++)
	{
		if (strcmp(pbd_new->CTR_NF,Kpbd_CPPILOT[i].CTR_NF)==0 &&
			pbd_new->SEC_NF == Kpbd_CPPILOT[i].SEC_NF &&
			pbd_new->ACY_NF == Kpbd_CPPILOT[i].ACY_NF &&
            pbd_new->ACM_NF == Kpbd_CPPILOT[i].ACM_NF)

				RETURN_VAL(OK);
	}

	Kn_NbLigCPPilot++ ;
	Kpbd_CPPILOT = (T_LIFDRI_ALL_QUARTER *)realloc(Kpbd_CPPILOT,sizeof(T_LIFDRI_ALL_QUARTER)*Kn_NbLigCPPilot);
	Kpbd_CPPILOT[Kn_NbLigCPPilot-1]=*pbd_new ;

	RETURN_VAL(OK)	;

}


/*=============================================================================
objet:
        Ecrit le tableau lifdri(Kbd_PILOTD) et le tableau (Kpbd_CPPILOT) des
        complement dans le fichier de sortie binaire CPLIFDRI.

Retour:
        -> OK
=============================================================================*/
int n_EcrireCPLLIFDRI()
{
	DEBUT_FCT("n_EcrireCPLLIFDRI");

    fwrite(Kbd_PILOTD	,sizeof(T_LIFDRI_ALL_QUARTER),Kn_NbLigPilot		,Kp_PilotOFil);
    fwrite(Kpbd_CPPILOT	,sizeof(T_LIFDRI_ALL_QUARTER),Kn_NbLigCPPilot	,Kp_PilotOFil);

	if ( Kpbd_CPPILOT ) free(Kpbd_CPPILOT), Kpbd_CPPILOT=NULL;

	RETURN_VAL(OK)	;
}

/*==========================================================================
     Objet :    Initialisation de la structure TRSASSO

     Nom:       init_SubTrsAssoLigne

     Parametres:
               

     Retour:    0
===========================================================================*/
void init_SubTrsAssoLigne()
{
          strcpy (SubTrsAssoLigne.ASSOTYP_CT,"");
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
     Objet :    Initialisation de la structure TRS

     Nom:       init_SubTrsLigne

     Parametres:
               

     Retour:    0
===========================================================================*/
void init_SubTrsLigne()
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

/*==========================================================================
     Objet :    Initialisation de la structure TRS

     Nom:       init_SubTrsEsBprop

     Parametres:
               

     Retour:    0
===========================================================================*/
void init_SubTrsEsBprop()
{
            strcpy(SubTrsEsBprop.DETTRNCOD_CF, "");
            SubTrsEsBprop.SSD_CF=0;
            SubTrsEsBprop.ESB_CF=0;
            SubTrsEsBprop.GLTFEEDING_B=0;
            SubTrsEsBprop.INTERNRETRO_B=0;
            SubTrsEsBprop.SRVFEEDING_B=0;
            SubTrsEsBprop.PREMIUMPNPEGPI_B=0;
            SubTrsEsBprop.RETROAUTO_B=0;
            SubTrsEsBprop.COMACIMPACT_B=0;
            SubTrsEsBprop.CASHFLOWPOS_CT=0;
            SubTrsEsBprop.GAAP1TRS_CT=0;
            SubTrsEsBprop.GAAP2TRS_CT=0;
            SubTrsEsBprop.GAAP3TRS_CT=0;
            SubTrsEsBprop.GAAP4TRS_CT=0;
            SubTrsEsBprop.GAAP5TRS_CT=0;
            strcpy(SubTrsEsBprop.CRE_D,"");
            strcpy(SubTrsEsBprop.CREUSR_CF,"");
            strcpy(SubTrsEsBprop.LSTUPD_D,"");
            strcpy(SubTrsEsBprop.LSTUPDUSR_CF,"");
}


/*=============================================================================
objet:
        Ecrit le tableau lifdri(Kbd_PILOTD) et le tableau (Kpbd_CPPILOT) des
        complement dans le fichier de sortie AASCII ASCCPLIFDRI.

Retour:
        -> OK
=============================================================================*/
int n_EcrireASCCPLLIFDRI()
{
	int i ;

	DEBUT_FCT("n_EcrireASCCPLLIFDRI");

	for(i=0;i<Kn_NbLigPilot;i++)
	    fprintf(Kp_AscPilotOFil,
                "%s~%d~%d~%d~%d~%s~%d~%d~%d~%d~%d~%d~%d~%d~%d~%d~%s~%s~%s\n",
                Kbd_PILOTD[i].CTR_NF,
                (int)Kbd_PILOTD[i].END_NT,
                (int)Kbd_PILOTD[i].SEC_NF,
                (int)Kbd_PILOTD[i].UWY_NF,
                (int)Kbd_PILOTD[i].UW_NT,
                Kbd_PILOTD[i].CRE_D,
                (int)Kbd_PILOTD[i].BALSHEY_NF,
                (int)Kbd_PILOTD[i].BALSHTMTH_NF,
                (int)Kbd_PILOTD[i].ACY_NF,
                (int)Kbd_PILOTD[i].ACM_NF,
                (int)Kbd_PILOTD[i].SSD_CF,
                (int)Kbd_PILOTD[i].AUTUPD_B,
                (int)Kbd_PILOTD[i].COMACC_B,
                (int)Kbd_PILOTD[i].SEGUPD_B,
                (int)Kbd_PILOTD[i].PROPAG_RES_B,
                (int)Kbd_PILOTD[i].CMT_NT,
                Kbd_PILOTD[i].CREUSR_CF,
                Kbd_PILOTD[i].LSTUPD_D,
                Kbd_PILOTD[i].LSTUPDUSR_CF);

	for(i=0;i<Kn_NbLigCPPilot;i++)
	    fprintf(Kp_AscPilotOFil,
                "%s~%d~%d~%d~%d~%s~%d~%d~%d~%d~%d~%d~%d~%d~%d~%d~%s~%s~%s\n",
                Kpbd_CPPILOT[i].CTR_NF,
                (int)Kpbd_CPPILOT[i].END_NT,
                (int)Kpbd_CPPILOT[i].SEC_NF,
                (int)Kpbd_CPPILOT[i].UWY_NF,
                (int)Kpbd_CPPILOT[i].UW_NT,
                Kpbd_CPPILOT[i].CRE_D,
                (int)Kpbd_CPPILOT[i].BALSHEY_NF,
                (int)Kpbd_CPPILOT[i].BALSHTMTH_NF,
                (int)Kpbd_CPPILOT[i].ACY_NF,
                (int)Kpbd_CPPILOT[i].ACM_NF,
                (int)Kpbd_CPPILOT[i].SSD_CF,
                (int)Kpbd_CPPILOT[i].AUTUPD_B,
                (int)Kpbd_CPPILOT[i].COMACC_B,
                (int)Kpbd_CPPILOT[i].SEGUPD_B,
                (int)Kpbd_CPPILOT[i].PROPAG_RES_B,
                (int)Kpbd_CPPILOT[i].CMT_NT,
                Kpbd_CPPILOT[i].CREUSR_CF,
                Kpbd_CPPILOT[i].LSTUPD_D,
                Kpbd_CPPILOT[i].LSTUPDUSR_CF);


	RETURN_VAL(OK);

}

/*=============================================================================
objet:  Sauvegarde la ligne prevision pour comparaison

Parametre:  La ligne courante des previsions
=============================================================================*/
void sav_LignePrevAnalytic(char ** pbd_LignePrev, int Flag, int InputTyp)
{
    Kbd_Analytic[i_ana].ACMTRS_NT = atoi(pbd_LignePrev[PRE_ACMTRS_NT]);
    Kbd_Analytic[i_ana].DETTRNCOD_CF = atoi(pbd_LignePrev[PRE_DETTRNCOD_CF]);
    Kbd_Analytic[i_ana].GAAP_NT = atoi(pbd_LignePrev[PRE_GAAP_NF]);
    strcpy(Kbd_Analytic[i_ana].AMT_M,pbd_LignePrev[PRE_ESTMNT_M]);
    strcpy(Kbd_Analytic[i_ana].GAAPDIFF_M,pbd_LignePrev[PRE_GAAPDIFF_M]);
    Kbd_Analytic[i_ana].FlagFirst = Flag;
    Kbd_Analytic[i_ana].InputTyp = InputTyp;

	i_ana ++;
}

double Arrondi(double Montant)
{
    return floor(Montant + 0.5);
}

int n_FillLifdriQuarter(FILE *Kp_InputPilot)
{
  int n_EOF = 0;
  T_LIFDRI_ALL_QUARTER bd_Lu;


    DEBUT_FCT("n_ChargerPilot7000");
    
    /* Tant que la fin de fichier n'est pas atteinte,... */
    while (n_EOF == 0)
    {
        /* ... lecture d'une ligne dans le fichier. */
        if (fread(&bd_Lu,sizeof(T_LIFDRI_ALL_QUARTER1),1,Kp_InputPilot)<=0)
            /* Fin de fichier, mise a jour du flag */
            n_EOF = 1;
        else
        {
            if ( Kn_NbLigPilot >= MAX_LIFDRI_ALL )
            {
                n_WriteAno ("Valeur MAXLIFDRI (MAX_LIFDRI_ALL) atteinte !!!");
                RETURN_VAL (-1);
            }
            else
            {
                /* Enregistrement ecrit dans le tableau */
                Kbd_PILOTD[Kn_NbLigPilot++] = bd_Lu;
            }
        }
    }
    RETURN_VAL (0);
}
