/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Creation des complements previsionnels
nom du source                 : ESTC2137.c
revision                      : $Revision: 1.25 $
date de creation              : 03/09/1997
auteur                        : P. Louveau
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
                Creation du fichier des complements previsionnels
                a partir des previsions et du fichier de pilotage.


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
           ...           ...            ...              ...
     05/05/1998 ANB      correction particularité inventaire non annuel
     07/3/2001       ANB       prise en compte ptc positive
     02/4/2002       ANB       correction prise en compte ptc positive  (sinistre)
     05/6/2002       ANB       prise en compte Remark
     11/3/2003       PP      Pas de remise a 0 complement sur poste stat vers gaap
     11/7/2003       JR      ne plus faire ex +1 sur liberations depots postes 1303 2303 1323 2323
     15/3/2004      JR        ACCADMTYP PREV + a jour que le GT  (en SYNCRO)
     11/12/2007     JR        SPOT 14688 Ajout postes VOBA 1163 2163 on ajoute +1 en plus pour la generation des liberations des
                              postes VOBA
     27/03/2008     J. Ribot  SPOT 15219  ASE15 : recompilation des programmes C
     ---------------
     14/05/2008     [010]     ESTVIE15401 Agrandissement d'un tableau en mémoire
                              agrandissement de NB_MAX_PILOT 20000 => 40000
     15/05/2008     [011]     Spot 15408 : Modification du poste détail pour les estimations 1073 en LOB '31'
     26/05/2008     [012]     Spot 15482 : Trimestrialisation des réserves positives
_________________
MODIFICATION    [013]
Auteur:         D.GATIBELZA
Date:           23/04/2009
Version:        9.1
Description:    ESTVIE16263 Modifier les règles de trimestrialisation Acceptation  rétro sur des mouvements qui ne sont pas dans leur sens naturel

     27/05/2009     JFVDV     [014] Spot[16263] : ajout / suppression de type de poste pour l'algorithme de semestrialisation
     22/06/2009     [015]     Spot 17629 : modif test sur postes 1163 et 2163
_________________
MODIFICATION    [016]
Auteur:         D.GATIBELZA
Date:           14/08/2009
Version:        9.1
Description:    ESTVIE16263 Modifier les règles de trimestrialisation Acceptation  rétro sur des mouvements qui ne sont pas dans leur sens naturel
_________________
MODIFICATION    [017]
Auteur:         D.GATIBELZA
Date:           20/08/2009
Version:        9.1
Description:    ESTVIE17917 la VOBA se comporte de de la même façon à Paris que les CNA manuelle de type 1 (CNATYP_CT = 1 ou 2)
_________________
MODIFICATION    [018]
Auteur:         D.GATIBELZA
Date:           20/11/2009
Version:        9.1
Description:    ESTVIE18289 Trimestrialisation  les postes DAC, VOBA  et commission de financement acceptation et retro
_________________
MODIFICATION    [019]
Auteur:         D.GATIBELZA
Date:           28/07/2010
Version:        10.1
Description:    ESTVIE18754 Creation ligne fds egal. stab dans onglet Primes ( pour tout et tous )
                faire le 1093 en dupliquant comme le 1063 et le 1094 comme le 1064
_________________
MODIFICATION    [020]
Auteur:         D.GATIBELZA
Date:           04/10/2010
Version:        10.1
Description:    ESTVIE19177 V10 Mettre en place un calcul spécial de DAC
_________________
MODIFICATION    [021]
Auteur:         D.GATIBELZA
Date:           03/11/2010
Version:        10.1
Description:    ESTVIE20655 Agrandissement d'un tableau en mémoire:
                NB_MAX_PILOT 40000 => 100000

[022] Florent  06/09/2011 :spot:22315 corrections gestion des libérations
               ce programme fait une synchronisation entre le GT et le PREV, il y aura trois branches ( ligne synchro, ligne pre sans GT ( pere sans
               fils) et ligne Gt sans pre ( fils sans pere)
               Dans les trois branches on le meme automate ( remplissage de la structure GTinfo, Calcul de complement, ecriture dans la GT, si c une constitution
               on transforme le poste en liberation et on ecrit dans la GT une liberation.
               Il faut noté que tout au long du pg, il a recherche de compte particulier pour adapter le traitement.

[023] 12/06/2014 JBG :spot:25773 Remove testing lines in code
[024] 04/07/2014 ABJ : Correction test ADJCOD
[025] 09/07/2014 ABJ :spot:25773 Modification of init_SubTrsAssoLigne()
[026] 15/07/2014 ABJ :spot:25773 Ajout de test sur le DETTRNCOD pour determiner le 2eme champs du TRNCOD
[027] 16/07/2014 ABJ :spot:25773 Generation de lignes avec montant =0 pour le calcul de complement interdit
[028] 17/07/2014 ABJ :spot:25773 Annulation du montant complementSRGTEF lorsque le Gaap est interdit.
[029] 22/07/2014 ABJ  spot:25773 exception post cash pour l' annulation du montant complementSRGTEF lorsque le Gaap est interdit.
[030] 26/08/2014 ABJ  spot:25773 Remplissage des champs GT_OCCYEA_NF/GT_SCOENDMTH_NF/GT_SCOSTRMTH_NF
[031] 26/08/2014 ABJ  spot:25773 Ajout du champs SPIMOD
[032] 03/09/2014 ABJ  spot:25773 Test d ecriture pour les Gaap qui precedent une ecriture OK
[033] 05/09/2014 ABJ  spot:25773 Correction du champs GT_BALSHRDAY_NF
[034] 05/09/2014 ABJ  spot:25773 Ajout du flag Complement_B
[035] 12/09/2014 ABJ  spot:25773 Calcul des complement pour compta sans prevision
[036] 29/09/2014 ABJ  spot:25773 Filtration des lignes postes Cash et complement =0
[037] 10/10/2014 ABJ  spot:25773 filtration des gaap interdit
[038] 14/10/2014 ABJ  spot:25773 filtration des gaap interdit
[039] 21/10/2014 ABJ  spot:25773 Control de gaap interdit pour les liberations
[040] 14/11/2014 ABJ  spot:25773 Ajout des posts 1243/2243/2263 pour l 'activation de calcul de complement
[041] 26/11/2014 ABJ  spot:25773 Ajout de la generation des 1393 , 1383  et 1363
[042] 09/01/2015 ABJ  spot:25773 Gestion de DAC compte complet et compta
[043] 02/02/2015 ABJ  spot:28188 Generation des liberations pour SRV ( pour les postes Complement_b=0)
[044] 04/03/2015 ABJ  spot:28403 Controle des GAAP interdits - Calcul de compléments en cas de cc
[045] 25/03/2015 SAS  spot:28465 Prise en compte des Dummy Est29a
[046] 30/03/2015 SAS  spot:28512 calcul de compléments pour les postes analytiques
[047] 03/06/2015 DFI  spot:28472 EST41 Automatic Calculation
[048] 01/06/2015 ABJ  spot:28838  Activation de calcul de complement pour Dac >0
[049] 01/06/2015 ABJ  spot:28889  Gestion des Gaap pour Compta sans Estim
[050] 17/06/2015 ABJ  spot:28982    Annulation du Gaap SII en cas de changement de poste
[051] 12/08/2015 DFI  spot:28982 Propagation des modifs apportees dans la branche 09
[052] 12/08/2015 GBO  spot:29095 ajout sorti dans le cadre de cadre de L'est26 A et B intrat-day
[053] 24/09/2015 SAS  spot:29337 Ne pas faire de complement sur les ratio (analytiques)
[054] 29/09/2015 GBO  spot:29095 est26 CMPCALC recuperation dettrncod depuis compta siu pas d'estimation
[055] 12/10/2015 NES  spot:29095 est26 CMPCALC pas de generation de ligne si absence de compta ou contrat retro
[056] 17/03/2016 DFI  spot:30195 est27 Traites decales, correction des calculs sur acy courante
[057] 04/05/2016 DFI  spot:30557 est27 Traites decales, utilisation nouveau parametre MODE pour differencier PA et PC
[058] 12/05/2016 DFI  spot:30557 est27 modification calcul date expiration retro
[059] 13/06/2016 DFI  spot:30744 correction des PNA crees a tort
[060] 17/06/2016 DFI  spot:30744 spira 34285 quand excedent de prime (cpt>est sur poste 10) alors alimentation gaap 5 forcee
[061] 13/09/2018 SBE  spira:70063: [Apolo - QE] - Life Closing: Management of exlcuded contracts for the estimates process
[062] 26/04/2019 SBE  spira:70045: Evolution Quarterly
[063] 08/07/2019 SBE  spira:78597: APOLO QE : TLIFSTAREP current, annual and photo plan estimations are wrong
[064] 09/01/2019 SBE  spira:81946: Apolo QE: Trimestrialisation des compléments Distinction poste cash et reserve
[065] 12/08/2020 SBE  spira:89222: TECH - ESTC2137 - Erreur de log générée par ESTC2137.exe
[066] 22/09/2020 SBE  spira:78597: APOLO QE : TLIFSTAREP current, annual and photo plan estimations are wrong
[067] 14/10/2020 SBE  spira:88742: APOLO QE : Pas d'accrual cash sur Période 12
[068] 14/10/2020 SBE  spira:83285: calcul complement quelque soit son signe.
[069] 07/12/2020 SBE  spira:90054: Apolo QE - Computation of Accruals for Cash T.code - Copy
[070] 11/03/2021 SBE  spira:88659: APOLO QE : Comptabilisation relative à la période 3-3 sur un TC non estimé => accruals sur période 12-12
[071] 17/09/2021 SBE  spira:89148: Apolo QE - Computation of Accruals for Reserves T.Codes
[072] 29/09/2021 SBE  spira:81642: APOLO QE : Pas de beginning sur les postes de réserves en GAAP IFRS
[073] 05/10/2021 BEL  spira:96257: Life Closing - Scor Start/End months not consistent
[074] 07/10/2021 SBE  spira:81642: APOLO QE : Pas de beginning sur les postes de réserves en GAAP IFRS
[075] 04/11/2021 SBE  spira:81642: APOLO QE : Pas de beginning sur les postes de réserves en GAAP IFRS (Retour spira)
[076] 11/01/2022 SBE  spira:101412: Life Closing - Scor Start/End months not consistent - Copy
[077] 28/06/2022 SBE  spira:104576:IFRS 17 FWH - Beginning accruals missing after complete account
[078] 14/09/2022 SBE  spira:106396:IFRS 17 FWH - Beginning accruals missing after complete account - Copy
[079] 06/10/2022 SBE  spira:106396:IFRS 17 FWH - Beginning accruals missing after complete account - Copy
[080] 10/11/2022 SBE  spira:107703:IFRS 17 - FWH - Issue on Complete Account
[081] 11/01/2023 SBE  spira:108255:IFRS17 FWH : Calcul des accruals même si compta ( et pas de compte complet)
[082] 23/01/2023 SBE  spira:107703:IFRS 17 - FWH - Issue on Complete Account (Reopen)
[083] 10/02/2023 SBE  spira:107703:IFRS 17 - FWH - Issue on Complete Account (Reopen)
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

/*
#define TRACE_1
#define TRACE_2*/

static char VERSION_ESTC2137_C[100] = "ESTC2137.c version [061] - Spira 70045 - Quarterly" ;

#define TRACE_CTR
#define GT_ACM_NF 74

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
//#define NB_MAX_PILOT    100000  //[021] / [010]

/*----------------------*/
/* variables de travail */
/*----------------------*/
typedef struct {
  char    *CTR_NF;
  char    *SEC_NF;
  char    *BALSHEY_NF;
  char    *BALSHRMTH_NF;
  char    *ACCADMTYP_CT;
  char    *LOB_CF;
  char    ACMTRS_NT[5];
  char    *ACCRET_B;
  char    *LIFTRTTYP_CF;
  char    *SSD_CF;
  char    *CUR_CF;
  char    *NAT_CF;
  char    *UWGRP_CF;      /* ajout 12/01/98 */
  int     exercice;
  int     annee_compte;
  char    poste_complement[9];
  char    poste_complement_TRN5[6];
  double  complement;
  double  complementSRGTEF;
  int     Gap;
  int     mode_ventil;
}  TINFO;

#define MAX_DATES 5000000   //[056]

typedef struct
{
  char sz_CTR_NF[10];
  char sz_SEC_NF[4];
  char sz_UWY_NF[6];
  char sz_EFFET_D[9];
  char sz_EXPIRATION_D[9];
} T_DATES;   //[056]

T_DATES L_DATES[MAX_DATES];   //[056]

FILE    *Kp_PrevFile;           /* pointeur sur les previsions */
FILE    *Kp_PilotFile;          /* pointeur sur les pilotages */
FILE    *Kp_SubTRSFile;          /* pointeur sur les pilotages */
FILE    *Kp_SubTRSAssoFile;          /* pointeur sur les pilotages */
FILE    *Kp_TrslnkFil;
FILE    *Kp_MvtFile;            /* pointeur sur les mouvements compta */
FILE    *Kp_AnoFile;            /* pointeur sur le fichier des anomalies */
FILE    *Kp_OutGTFile;      /* pointeur sur les complements pour les traites cribles */
FILE    *Kp_OutSRGTEFile;     /* pointeur sur les complements pour les traites de rattachement */
FILE    *Kp_EsBpropIFil;
FILE    *Kp_OutCMPFile;
FILE    *Kp_OutESTCRBEXCLUSFile;

T_RUPTURE_VAR           bd_RuptPrev;    /* gestion rupture sur pilotage */
T_RUPTURE_SYNC_VAR      bd_RuptMvt;     /* gestion rupture sur prev */

T_RUPTURE_VAR pbd_RuptPerim;/* gestion rupture sur Perimetre            */  //[056]

T_LIFDRI_ALL    Kbd_PILOT[NB_MAX_PILOT];    /* Fichier pilotage 1  charge en memoire  */
T_LIFDRI_ALL_QUARTER    Kbd_PILOTD[NB_MAX_PILOT];    // Fichier pilotage charge en memoire

T_SUBTRS     SubTrsLigne;
T_SUBTRSASSO SubTrsAssoLigne;
T_SUBTRSESBPROP SubTrsEsBprop;

int         Kn_NbLigPilot;              /* Nombre de lignes dans le fichier pilotage 1 */
int         Kn_SyncPilot;               // =-1 si le fichier pilotage n'est pas synchronise,
            
int         Kn_NbLigSubTRSfile;              /* Nombre de lignes dans le fichier pilotage 2 */

int         Kn_PasCompl = 0;

int         Kn_Complparticul = 0;
char        Ksz_CLODAT[9];              /* date d'inventaire */
int         Kn_Chaine_apl;
int         Kn_AnneeBilan,
            Kn_MoisBilan,
            Kn_MoisInv,
            Kn_Dates,               /* dates effet et expiration par CTR/SEC/UWY*/  //[056]
            Kn_Cpt_Dates,           /* compteur sur structure Dates             */  //[056]
            Kn_Cpt_Dates_ctrsec = 0;  /* compteur sur structure Dates premiere
                                                  ocurrence CTR/SEC             */  //[056]
int         Kn_FilsSansPere;

int         Flag_Depot=0;
int         Flag_Depot_CC=0;

char sz_ref_CTR[30] = "";   /* CTR reference pour recherche dates       */  //[056]
char sz_ref_SEC[4]  = "";   /* SEC reference pour recherche dates       */  //[056]

int gi_LogSig = 0;

char scorPriodGt[3];
int yearly;

enum MODE {
  PA = 0,
  PC = 1
} Kn_mode;     //[057]


int n_InitPrev(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLignePrev(char **pbd_InRec_Cur);
int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_IsR2Prev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptPrev(char **ptb_InRec_Cur);
int n_ActionFirstRupt2Prev(char **ptb_InRec_Cur);

int n_InitMvt(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncMvt (char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneMvt(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionPereSansFils(char **ptb_InRec);
int n_ActionFilsSansPere(char **ptb_InRec);
void n_CompareTE(char **Tlifest, char **GT);
int ActionFirstGT(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ConditionRuptSyncMvt(char **ptb_InRecOwner, char **ptb_InRecChild);

int n_CalculerComplement (TINFO *, double , double, char);

void  CompleterPoste (char*, char, char *, char *, int , int, char* ) ;
int n_ChargerPilot();
int n_RechPilot (char **, int );
int n_RechSUBTRSLogSig (char *);
void init_SubTrsLigne();
void init_SubTrsAssoLigne();
//[028]
void init_SubTrsEsBprop();


int n_EcrireAno(int , TINFO *);

int n_InitRuptPerim(T_RUPTURE_VAR *pbd_Rupt);  //[056]
int n_ActionLignePerim(char **pbd_InRec_Cur);  //[056]
int n_RechercheDates(char *sz_CTR_NF, char *sz_SEC_NF, int n_UWY_NF);            //[056]
int n_AcyCourante(char *sz_CTR_NF, char *sz_SEC_NF, int n_UWY_NF, int n_ACY_NF); //[056]

int n_nbJoursDansMois(int annee, int mois);    //[026]

double gd_Summ_Compl_Gaap_Preced = 0;
int newbloc = 0;
int newblocSync = 0;
double G_MGT = 0;
int first_gaap_writen = 0; //[032]
int Complement_B = 0; //[034]
int poste_modifie_PNA = 0; //[049]
int         ksz_indexPilot = 0; // Index pour RechPilot7000
/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{
  char sz_buf[4];
  char sz_mode[3];  //[057]

  /* int n_logsig_1 =0;
   int n_logsig_2 =0;*/


  /* Initialisation des signaux */
  InitSig () ;

  if ( n_BeginPgm (argc  , argv) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* Recuperation de la date d'inventaire annee et mois bilan*/
  Kn_Chaine_apl = n_GetIntArgv(1);
  strcpy(Ksz_CLODAT, psz_GetCharArgv(2));
  Kn_AnneeBilan = n_GetIntArgv(3);
  Kn_MoisBilan = n_GetIntArgv(4);
  sprintf(sz_buf, "%.2s", Ksz_CLODAT + 4);
  Kn_MoisInv = atoi(sz_buf);
  
  // [057]
  strcpy(sz_mode, psz_GetCharArgv(5));
  if(strcmp(sz_mode,"PA")==0)
    Kn_mode = PA;
  if(strcmp(sz_mode,"PC")==0)
    Kn_mode = PC;
  ////////

  /* Ouverture des fichiers en sortie */
  if ( n_OpenFileAppl ("ESTC2137_O1", "wt", &Kp_OutGTFile) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC2137_O2", "wt", &Kp_OutSRGTEFile) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC2137_O3", "wt", &Kp_AnoFile) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC2137_O4", "wt", &Kp_OutCMPFile) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC2137_O5", "wt", &Kp_OutESTCRBEXCLUSFile) == ERR )
    ExitPgm ( ERR_XX , "" );

  if (n_OpenFileAppl ("ESTC2137_I4", "rb", &Kp_SubTRSFile) == ERR )
    ExitPgm ( ERR_XX , "" );
  n_ChargerTsubTRS(Kp_SubTRSFile);

  if ( n_OpenFileAppl ("ESTC2137_I5", "rb", &Kp_SubTRSAssoFile) == ERR )
    ExitPgm ( ERR_XX , "" );
  n_ChargerTsubTRSAsso(Kp_SubTRSAssoFile);


  if ( n_OpenFileAppl ("ESTC2137_I6", "rb", &Kp_TrslnkFil) == ERR )
    ExitPgm ( ERR_XX , "" );
  n_ChargerTRSLNK500(Kp_TrslnkFil);
  //[28]
  if (n_OpenFileAppl ("ESTC2137_I7", "rb", &Kp_EsBpropIFil) == ERR )
    ExitPgm ( ERR_XX , "" );

  if (n_OpenFileAppl ("ESTC2137_I3", "rb", &Kp_PilotFile) == ERR )
    ExitPgm ( ERR_XX , "" );
    
  if ( n_ChargerSUBTRSESBPROP(Kp_EsBpropIFil) == ERR )      ExitPgm( ERR_XX , "" );

  // Chargement structure contenant les dates d'effet et d'expiration   //[056]
  if ( n_InitRuptPerim(&pbd_RuptPerim) )
    ExitPgm ( ERR_XX , "Erreur a l'ouverture du fichier PERICASE" );
  Kn_Cpt_Dates = 0; // initialisation du compteur sur structure Dates
  if ( n_ProcessingRuptureVar(&pbd_RuptPerim) == ERR )
    ExitPgm ( ERR_XX , "Erreur lors du chargement du PERICASE" );

  /* Initialisation de la varible bd_RuptPrev */
  if ( n_InitPrev(&bd_RuptPrev) )
    ExitPgm ( ERR_XX , "" );

  /* Initialisation de la varible bd_RuptMvt */
  if ( n_InitMvt(&bd_RuptMvt) )
    ExitPgm ( ERR_XX , "" );

  if (n_ChargerPilot7000(Kp_PilotFile) == ERR)
      ExitPgm (ERR_XX, "");  
      
  /* Chargement en memoire du fichier pilotage */
  n_ChargerPilot();

  /* Lancement du traitement du fichier */
  if ( n_ProcessingRuptureVar (&bd_RuptPrev) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* Fermeture fichier */
  if (n_CloseFileAppl ("ESTC2137_I2", &(bd_RuptPrev.pf_InputFil)) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2137_I1", &(bd_RuptMvt.pf_InputFil)) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2137_I3", &Kp_PilotFile) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2137_I4", &Kp_SubTRSFile) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2137_I5", &Kp_SubTRSAssoFile) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2137_I6", &Kp_TrslnkFil) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2137_I7", &Kp_EsBpropIFil) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2137_O1", &Kp_OutGTFile) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2137_O2", &Kp_OutSRGTEFile) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2137_O3", &Kp_AnoFile) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2137_O4", &Kp_OutCMPFile) == ERR)
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2137_O5", &Kp_OutESTCRBEXCLUSFile) == ERR)
    ExitPgm ( ERR_XX , "" );

  if ( n_EndPgm () == ERR )
    ExitPgm ( ERR_XX , "" );

  exit(0);
}

//[052]
void n_CompareTE(char **Tlifest, char **GT)
{
  DEBUT_FCT("n_IsR1Prev");
  char *CMD[20];
  char dest[6] = {0};  // [054]

  if (GT == NULL) //[055]
    return;
  if (Tlifest != NULL)
  {
    CMD[0] = Tlifest[PRE_SSD_CF];
    CMD[2] = Tlifest[PRE_LSTUPDUSR_CF];
    CMD[3] = Tlifest[PRE_CTR_NF];
    CMD[4] = Tlifest[PRE_SEC_NF];
    CMD[5] = Tlifest[PRE_UWY_NF];
    CMD[6] = Tlifest[PRE_ACY_NF];
    CMD[7] = Tlifest[PRE_DETTRNCOD_CF];
    CMD[10] = Tlifest[PRE_CUR_CF];
    CMD[11] = Tlifest[PRE_ESTMNT_M];
    CMD[18] = Tlifest[PRE_UWGRP_CF];
  }
  else
  {
    CMD[0] = GT[GT_SSD_CF];
    CMD[2] = "     ";           // [054]
    CMD[3] = GT[GT_CTR_NF];
    CMD[4] = GT[GT_SEC_NF];
    CMD[5] = GT[GT_UWY_NF];
    CMD[6] = GT[GT_ACY_NF];
    strncpy(dest, &GT[GT_TRNCOD_CF][2], 5); // [054]
    CMD[7] = dest;                          // [054]
    CMD[10] = GT[GT_ESTCUR_CF];
    CMD[11] = "0.000";
    CMD[18] = GT[GT_UWGRP_CF];
  }

  if (GT[GT_TRNCOD_CF] &&
      (GT[GT_TRNCOD_CF][0] == '2' ||
       GT[GT_TRNCOD_CF][0] == '4')) //[055]
    return;

  if (GT != NULL) //[055]
  {
    CMD[9] = GT[GT_ESTAMT_M];
    CMD[1] = GT[GT_ESB_CF];
    CMD[8] = GT[GT_ESTCUR_CF];
  }
  else
  {
    return;
    /* CMD[9] = "0.000";
    CMD[1] = Tlifest[PRE_ESB_CF];
    CMD[8] = Tlifest[PRE_CUR_CF]; */
  }
  CMD[12] = "";                           //DiffTE
  CMD[13] = "";                           //SCOENDMTH_NF
  CMD[14] = "";                           //GAP_D
  CMD[15] = "";                           //VAC_NT
  CMD[16] = "2";                          //GAPSTS_NT
  CMD[17] = "";                           //CMT_NT
  CMD[19] = NULL;
  n_WriteCols(Kp_OutCMPFile, CMD, SEPARATEUR, 0);
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

	Kn_FilsSansPere = 0;

  if ( n_OpenFileAppl ("ESTC2137_I2", "rt", &(pbd_Rupt->pf_InputFil)))
    RETURN_VAL (ERR);

  pbd_Rupt->n_NbRupture = 2 ;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPrev;

  pbd_Rupt->n_ActionLigne = n_ActionLignePrev ;

  pbd_Rupt->n_ConditionRupture[1] = n_IsR2Prev;
  pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRupt2Prev;



  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave Perim
retour :    OK
==============================================================================*/
int n_InitMvt(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitMvt");

  memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

  /* ouverture du fichier esclave */
  n_OpenFileAppl ("ESTC2137_I1", "rt", &(pbd_Rupt->pf_InputFil));

  pbd_Rupt->n_NbRupture = 1;

  pbd_Rupt->ConditionEndSync      = n_ConditionSyncMvt ;
  pbd_Rupt->n_ActionLigne         = n_ActionLigneMvt ;
  pbd_Rupt->n_PereSansFils        = n_ActionPereSansFils;

  if ( Kn_Chaine_apl == 2040)
    pbd_Rupt->n_FilsSansPere        = n_ActionFilsSansPere;

  pbd_Rupt->c_Separ               = '~' ;

  RETURN_VAL (OK);
}

/*==============================================================================
objet : fonction de test de rupture niveau 1 sur
        Contrat/Section/Exercice/Annee de compte
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR1Prev");

  if (strcmp(ptb_InRec[PRE_CTR_NF], ptb_InRec_Cur[PRE_CTR_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_SEC_NF], ptb_InRec_Cur[PRE_SEC_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ACY_NF], ptb_InRec_Cur[PRE_ACY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ESTMTH_NF], ptb_InRec_Cur[PRE_ESTMTH_NF]) != 0)
    RETURN_VAL(1);

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de rupture niveau 1 sur
        Contrat/Section/Exercice/Annee de compte
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR2Prev(char **ptb_InRec, char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR2Prev");

  if (strcmp(ptb_InRec[PRE_CTR_NF], ptb_InRec_Cur[PRE_CTR_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_END_NT], ptb_InRec_Cur[PRE_END_NT]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_SEC_NF], ptb_InRec_Cur[PRE_SEC_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ACY_NF], ptb_InRec_Cur[PRE_ACY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ESTMTH_NF], ptb_InRec_Cur[PRE_ESTMTH_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_UWY_NF], ptb_InRec_Cur[PRE_UWY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ACMTRS_NT], ptb_InRec_Cur[PRE_ACMTRS_NT]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != 0)
    RETURN_VAL(1);
  RETURN_VAL (0);

}


/*==============================================================================
objet :     fonction de test de synchro
retour :    0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
            > 0     ---> pbd_InRecOwne> > pbd_InRecChild
            < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncMvt (char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */ )
{
  int ret;
  char sz_buf[6];

  DEBUT_FCT("n_ConditionSyncMvt");

  if ( (ret = strcmp(pbd_InRecOwner[PRE_CTR_NF], pbd_InRecChild[GT_CTR_NF])) != 0 )
    RETURN_VAL (ret);
  if ( (ret = strcmp(pbd_InRecOwner[PRE_SEC_NF], pbd_InRecChild[GT_SEC_NF])) != 0 )
    RETURN_VAL (ret);
  if ( (ret = strcmp(pbd_InRecOwner[PRE_ACY_NF], pbd_InRecChild[GT_ACY_NF])) != 0 )
    RETURN_VAL (ret);
  if ( (ret = atoi(pbd_InRecOwner[PRE_ESTMTH_NF]) - atoi(pbd_InRecChild[GT_ACM_NF])))
    RETURN_VAL (ret);
  if ( (ret = strcmp(pbd_InRecOwner[PRE_UWY_NF], pbd_InRecChild[GT_UWY_NF])) != 0 )
    RETURN_VAL (ret);
  if ( (ret = strcmp(pbd_InRecOwner[PRE_ACMTRS_NT], pbd_InRecChild[GT_ACMTRS_NT])) != 0 )
    RETURN_VAL (ret);
  sprintf(sz_buf, "%.5s", pbd_InRecChild[GT_TRNCOD_CF] + 2);
  sz_buf[5] = 0;
  if ( (ret = strcmp(pbd_InRecOwner[PRE_DETTRNCOD_CF], sz_buf)) != 0 )
    RETURN_VAL (ret);

  RETURN_VAL (0);
}
/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere de niveau 2
==============================================================================*/
int n_ActionFirstRuptPrev (char **ptb_InRec_Cur)
{
//[044]
  DEBUT_FCT("n_ActionFirstRuptPrev");

  /* Initialistion de la variable somme complement Gap presedant */
  gd_Summ_Compl_Gaap_Preced = 0;
	Flag_Depot_CC=0;
	
  RETURN_VAL(0);
}


/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRupt2Prev (char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionFirstRupt2Prev");

  /* Initialistion de la variable somme complement Gap presedant */
  gd_Summ_Compl_Gaap_Preced = 0;
  poste_modifie_PNA = 0; //[049]

  newbloc = 0;
  newblocSync = 0;

strcpy(scorPriodGt, ptb_InRec_Cur[PRE_ESTMTH_NF]);
  yearly = 0;
  if (atoi(scorPriodGt) == 13)
    yearly = 1;

  RETURN_VAL(0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionLignePrev");
  int result = 0;
  gi_LogSig = 0;
  Complement_B = 0; //[034]
  init_SubTrsLigne();

  /* recherche de la cle dans la table de pilotage */
  result = n_FindTsubTRS(&SubTrsLigne, ptb_InRec_Cur[PRE_DETTRNCOD_CF]);
//[024]
  if (result == -1)
    RETURN_VAL(0);
  else
  {
    Complement_B = SubTrsLigne.COMPLEMENT_B; //[034]
    if (strcmp(SubTrsLigne.LOGSIG_CT, "0") == 0)
    {
      gi_LogSig = 0;

    }

    else if (ptb_InRec_Cur[PRE_ACMTRS_NT][0] == '1')

    {
      gi_LogSig = atoi(SubTrsLigne.LOGSIG_CT);

    }


    else
    {
      if (strcmp(SubTrsLigne.LOGSIG_CT, "1") == 0)
      {
        gi_LogSig = 2;
      }
      else
        gi_LogSig = 1;

    }
  }
//[024]
//[053]    /* si c'est un poste analytique avec un inputtype=ratio, alors on ne trimestrialise pas */
  if ( (SubTrsLigne.TRSINPUTTYPE_CT == 3) && (SubTrsLigne.TRSNATURE_CT == 2))
  {
    fprintf(Kp_OutSRGTEFile, "%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~~~%s~~%s~~~~~%s~%s~~~~%s\n",
            ptb_InRec_Cur[PRE_SSD_CF],
            ptb_InRec_Cur[PRE_ESB_CF],
            Ksz_CLODAT,
            Ksz_CLODAT + 4,
            Ksz_CLODAT + 6,
            "",
            "",
            ptb_InRec_Cur[PRE_CTR_NF],
            ptb_InRec_Cur[PRE_END_NT],
            ptb_InRec_Cur[PRE_SEC_NF],
            ptb_InRec_Cur[PRE_UWY_NF],
            ptb_InRec_Cur[PRE_UW_NT],
            ""/* OCCYEA_NF */,
            ptb_InRec_Cur[PRE_ACY_NF],
            Ksz_CLODAT + 4,
            Ksz_CLODAT + 4,
            "" /* CLM_NF */,
            ptb_InRec_Cur[PRE_CUR_CF],
            ptb_InRec_Cur[PRE_ESTMNT_M],
            ptb_InRec_Cur[PRE_CED_NF],
            "",
            "0",
            ptb_InRec_Cur[PRE_GANPAYORD_NT],
            ptb_InRec_Cur[PRE_CUR_CF], /* GT enrichi */
            "",
            "",
            ptb_InRec_Cur[PRE_ACMTRS_NT],
            "",
            "",
            ptb_InRec_Cur[PRE_LOB_CF],
            "",
            ptb_InRec_Cur[PRE_ESTCRB_CT],
            "",
            ptb_InRec_Cur[PRE_ACCADMTYP_CT],
            ptb_InRec_Cur[PRE_ORICOD_LS],
            ptb_InRec_Cur[PRE_ACCRET_B],
            ptb_InRec_Cur[PRE_GAAP_NF],
            "",
            ""
           );

    RETURN_VAL(0);
  }

  n_ProcessingRuptureSyncVar (&bd_RuptMvt, ptb_InRec_Cur);

  RETURN_VAL (0);
}



/*==============================================================================
objet : fonction permettant de formater le poste complement,
        ajoute prefixe, sous-prefixe et suffixe
entree: type: 1 pour acceptation,
              2 pour retrocession = 1er chiffre de l'ACMTRS
==============================================================================*/
void CompleterPoste (char *lob, char type, char *poste, char *DETTRN, int norme, int id_contexte, char* ACMTRS)
{
  int n_lob, i;
  int reslt;
  char Acmtrs_new[5];
  char TRN1[2];
  char TRN2[2];
  char TRN8[2];


  if (strcmp(lob, "0") == 0 && (id_contexte == 0) && (type == '0') && (norme == 0))
  {
    TRN1[0] = poste[0];
    TRN1[1] = 0;
    TRN2[0] = poste[1];
    TRN2[1] = 0;
    TRN8[0] = poste[7];
    sprintf(poste, "%.1s%.1s%.5s%.1s", TRN1, TRN2, DETTRN, TRN8);
    poste[8] = 0;
    ACMTRS[3] = '4';
    return;
  }

  DEBUT_FCT("CompleterPoste");

  n_lob = atoi(lob);
  switch (norme)
  {
  case 1: strcpy(TRN8, "2");
    break;
  case 2: strcpy(TRN8, "A");
    break;
  case 3:  strcpy(TRN8, "C");
    break;
  case 4:  strcpy(TRN8, "E");
    break;
  case 5:   strcpy(TRN8, "G");
    break;
  default:
    strcpy(TRN8, "2"); //

  }
  TRN8[1] = 0;

  type = ACMTRS[0];// a enlever le ACCRET sera bien mis a jour dans tout les fichiers .c

  if ( (type == '1') && (n_lob == 31) )
    strcpy(TRN1, "1");
  if ( (type == '2') && (n_lob == 31) )
    strcpy(TRN1, "2");
  if ( (type == '1') && (n_lob == 30) )
    strcpy(TRN1, "3");
  if ( (type == '2') && (n_lob == 30) )
    strcpy(TRN1, "4");

  TRN1[1] = 0;

  if ((SubTrsLigne.TRSTYPE_CT == 1) || (SubTrsLigne.TRSTYPE_CT == 2) || (SubTrsLigne.TRSTYPE_CT == 3))
    strcpy(TRN2, "1");
  else if (SubTrsLigne.TRSTYPE_CT == 4 )
    strcpy(TRN2, "3");
  else
    strcpy(TRN2, "9"); // pour tester

  if (DETTRN[0] == '2')
    strcpy(TRN2, "1");

  TRN2[1] = 0;


  if (id_contexte == 0)
    id_contexte = 1;
  else if ((id_contexte == 1) && (n_lob == 30))
    id_contexte = 2;
  else if ((id_contexte == 1) && (n_lob == 31))
    id_contexte = 3;

  init_SubTrsAssoLigne();

  reslt = n_FindTsubTRSAsso(&SubTrsAssoLigne, 4, id_contexte, DETTRN);

  if (reslt != (-1))
  {
    strcpy(DETTRN, SubTrsAssoLigne.DETTRNCOD2_CF);
    DETTRN[5] = 0;
  }

  //Pour Test
  strcpy(TRN2, "1");
  TRN2[1] = 0;
  if (strcmp(DETTRN, "90860") == 0)
  {
    strcpy(TRN2, "1");
    TRN2[1] = 0;
  }
  if ((DETTRN[0] == '8') && ((DETTRN[1] == '1') || (DETTRN[1] == '5'))) // 81xxx ou 85xxx
  {
    strcpy(TRN2, "2");
    TRN2[1] = 0;
  }
//[026]
  if ((strcmp(DETTRN, "90300") == 0) || (strcmp(DETTRN, "90310") == 0) || (strcmp(DETTRN, "90320") == 0) || (strcmp(DETTRN, "90330") == 0) || (strcmp(DETTRN, "90410") == 0))
  {
    strcpy(TRN2, "3");
    TRN2[1] = 0;
  }
  if ((DETTRN[0] == '8') && ((DETTRN[1] == '2') || (DETTRN[1] == '3') || (DETTRN[1] == '4'))) // 82xxx ou 83xxx ou 84xxx
  {
    strcpy(TRN2, "3");
    TRN2[1] = 0;
  }

  sprintf(poste, "%.1s%.1s%.5s%.1s", TRN1, TRN2, DETTRN, "0");
  poste[8] = 0;

  //Modifier l ACMTRS en cas de besoin
  if (reslt != (-1))
  {
    for (i = 0; i < 4; i++)
      Acmtrs_new[i] = '0';

    if ((strcmp(DETTRN, "40000") == 0) || (strcmp(DETTRN, "41000") == 0))
      Acmtrs_new[1] = '0'; // pour test

    reslt = n_RechACMTRS(poste);
    if (reslt != -1)
    {
      sprintf(Acmtrs_new, "%d", reslt);
      Acmtrs_new[4] = 0;
      strcpy(ACMTRS, Acmtrs_new);
    }


  }
  sprintf(poste, "%.1s%.1s%.5s%.1s", TRN1, TRN2, DETTRN, TRN8);
  poste[8] = 0;

}




/*==============================================================================
objet :     fonction de calcul du complement
retour :    affecte  complement.
            renvoie un boleen   1 -> une liberation ulterieure est a creer
                                0 -> sinon
==============================================================================*/
int n_CalculerComplement (TINFO *info, double montant_Prev, double montant_GT, char crible)
{
  int poste, type_poste;
  int n_EstConstit;
  int diff_montant_sens;
  int anomalie_actif = 0;
  int result=0;
  
  DEBUT_FCT("n_CalculerComplement");

  poste = atoi(info->ACMTRS_NT);    /* format xxxx */
  type_poste = poste % 1000;
  n_EstConstit = 0;                 /* Initialisation : pas une constit */
  Flag_Depot=0;
  
  result = n_FindTsubTRS(&SubTrsLigne, info->poste_complement_TRN5);
  
  /* Verification si TRSTYP_CT = 4 (Depot) et ACY + 1 n'est pas CC */
  /* Dans ce cas on force l'écriture d'une libération              */
  if ( result != -1 && SubTrsLigne.TRSTYPE_CT == 4 )
  {
  	//montant_GT=0;
  	Flag_Depot = 1;
  }
  
  info->complement = (montant_Prev - montant_GT) - gd_Summ_Compl_Gaap_Preced;

  gd_Summ_Compl_Gaap_Preced += info->complement;


  
  info->complementSRGTEF = montant_Prev - montant_GT ;
  if (fabs(info->complement) < 0.001)
    info->complement = 0;

  if ((info->complementSRGTEF == 0) && (info->complement == 0 ))
  {
    Kn_PasCompl = 1;
    return 0;
  }


  /* Verification de signe de AMT_M si crible != A ou E */
  if ( crible != 'A' && crible != 'E' && (                // [47]
         ((info->complement > 0) && (gi_LogSig == 1))   ||
         ((info->complement < 0) &&  (gi_LogSig == 2)) ) )
  {
    n_EcrireAno (A_SigneComplementAnormal, info);
    anomalie_actif = 1;

  }

  CompleterPoste(info->LOB_CF,
                 info->ACCRET_B[0],
                 info->poste_complement,
                 info->poste_complement_TRN5,
                 info->Gap,
                 0,
                 info->ACMTRS_NT);

  /* s'il s'agit d'un poste de constitution et si l'annee de compte < bilan, ... */
  /*[056] if ( ((poste%10) == 3) && (info->annee_compte < Kn_AnneeBilan) )
      n_EstConstit = 1;*/

  if ( ((poste % 10) == 3) &&
       ((n_AcyCourante(info->CTR_NF, info->SEC_NF, info->exercice, info->annee_compte) < 0 || yearly == 0 ) ))
  {
    n_EstConstit = 1;
  }
    
  //[013]
  diff_montant_sens = 0;
  Kn_Complparticul  = 0; //[068]
  // [016] finalement, on l'active
  if ( ( gi_LogSig == 1 && montant_Prev > 0) ||
       ( gi_LogSig == 2 && montant_Prev < 0) )
    diff_montant_sens = 1;
  else  //[068]
    Kn_Complparticul = 1; //[068]

  /* si inventaire intermediaire et si complement de signe anormal */
  /* Modif Anb le 24/06/99 */
  /* le non calcul du complément ne s'applique plus que pour AC = bilan */
  /* compte tenu des pbs sur la compta rétro                            */
  if ( (Kn_MoisInv != 12) &&
       ( anomalie_actif == 1 || poste_modifie_PNA == 1  ) &&
       //[056](info->annee_compte == Kn_AnneeBilan))
       (n_AcyCourante(info->CTR_NF, info->SEC_NF, info->exercice, info->annee_compte) == 0))
  {
    if ( (diff_montant_sens == 1 && first_gaap_writen == 0) || (first_gaap_writen == 1) ) // [032]
    {
      //-- ACCEPTATION ET RETRO

      if ( type_poste == 140  ||      // si poste Commission et prévision sens anormal, ne pas appliquer l'algorithme de semestrialisation (ne rien faire donc)
           type_poste == 160  ||      // si poste PB et prévision sens anormal, ne pas appliquer l'algorithme de semestrialisation (ne rien faire donc)
           type_poste == 83   ||      // Modif Anb du 7/3/01 : Prise en cpte ptc positive si poste PTC et prévision sens anormal, ne pas appliquer l'algorithme de semestrialisation (ne rien faire donc)
           type_poste == 603  ||      // -
           type_poste == 623  ||      // Modif Anb du 5/6/02 : Si Remark et prévision sens anormal, ne pas appliquer l'algorithme de semestrialisation (ne rien faire donc)
           type_poste == 633  ||      // -
           type_poste == 183  ||
           type_poste == 383  ||  //[41]
           type_poste == 483  ||  //[048]
           type_poste == 193  ||
           type_poste == 393  ||  //[41]
           type_poste == 493  ||  //[48]
           type_poste == 163  ||      // [018] // [016] [finalement on le vire ]  type_poste == 163  ||    // [014] [spot16263] ajout
           type_poste == 363  ||  //[41]
           type_poste == 463  ||  //[048] a ajouter !!!!
           type_poste == 63   ||      // [012] début
           type_poste == 93   ||      // [018]
           type_poste == 503  ||      //
           type_poste == 533  ||      // fin
           type_poste == 523  ||
           type_poste == 73   ||      // PP Pour les postes stat vers gaap on calcul toujours un complement meme si sens anormal, donc ne pas appliquer l'algo de semestrialisation
           type_poste == 10   ||
           type_poste == 263  ||    //[040]
           type_poste == 243  ||    //[040]
           type_poste == 900  ||    //[046]
           type_poste == 950        //[046]

         )
      {
        Kn_Complparticul = 1;

      }

      if ((( info->ACMTRS_NT[0] == '2') && ( type_poste == 145 )) || (( info->ACMTRS_NT[0] == '1') && ( type_poste == 150 )) )
      {
        Kn_Complparticul = 1;
      }
    }
    /* Modif Anb du 5/6/02 : Si Remark et prévision sens anormal, ne pas appliquer
    l'algorithme de semestrialisation (ne rien faire donc) */
    if  (strcmp(info->LIFTRTTYP_CF, "A9") == 0)
    {
      Kn_Complparticul = 1;

    }
    /* Fin modif Anb du 7/3/01 */
    /* si poste 'Prime +Rpcc' et AC = Année d'inventaire */
    if (( type_poste == 10) && //[056]( info-> annee_compte == Kn_AnneeBilan ))
        (n_AcyCourante(info->CTR_NF, info->SEC_NF, info->exercice, info->annee_compte) == 0))
    {
      Kn_Complparticul = 1;
      n_EstConstit = 0;
      CompleterPoste(info->LOB_CF,
                     info->ACCRET_B[0],
                     info->poste_complement,
                     info->poste_complement_TRN5,//"41000",
                     info->Gap,
                     1,
                     info->ACMTRS_NT);
      info->mode_ventil = 3; //[031]
      poste_modifie_PNA = 1;//[049]


    }

    /* si autres cas ne pas calculer de complements */
    if ((Kn_Complparticul == 0 &&   first_gaap_writen == 0) || Complement_B == 0) //[032][034]
    {
      //  [027]
      info->complement = 0;
      //   Kn_PasCompl = 1;
      if (info->complementSRGTEF == 0)
      {
        Kn_PasCompl = 1;
        return 0;
      }
      CompleterPoste(info->LOB_CF,
                     info->ACCRET_B[0],
                     info->poste_complement,
                     info->poste_complement_TRN5,
                     info->Gap,
                     0,
                     info->ACMTRS_NT);
      // Comme on est censé pas ecrire la ligne, On repasse le cumul a 0

      return n_EstConstit; //[043]
    }


  }
  /* si le traite est en unite de compte */
  if ((strcmp(info->LIFTRTTYP_CF, "A7") == 0) && ( (type_poste == 63)  || (type_poste == 83))) // ajouter test (type_poste == 63) (type_poste == 83)
  { //context4
    CompleterPoste(info->LOB_CF,
                   info->ACCRET_B[0],
                   info->poste_complement,
                   info->poste_complement_TRN5,//"40020",//"49010",
                   info->Gap,
                   4,
                   info->ACMTRS_NT);

  }
  /*  [011] GIBU le 15/05/2008
   *  Le poste 1073 doit verser dans le poste 11400102 si lob 30 (normal) mais dans le poste 11410112 si lob 31    */
  // a verifier si pour lob 30 on fait le traitement ou c le commentaire n est pas bon.
  if ((strcmp(info->LOB_CF, "31") == 0) && (type_poste == 73))
  { //context 5

    CompleterPoste(info->LOB_CF,
                   info->ACCRET_B[0],
                   info->poste_complement,
                   info->poste_complement_TRN5,
                   info->Gap,
                   5,
                   info->ACMTRS_NT);
  }
  /* MODIFICATION: */
  /* si traite non proportionnel (nat >= 30) et poste detail prime */
  /* (xx100002) alors poste detail = xx101002  */
  /* pointe sur le 1er chiffre apres le 2e x */
  if ( (atoi(info->NAT_CF) >= 30) && (strcmp(info->poste_complement_TRN5, "10000") == 0 ) )
    CompleterPoste(info->LOB_CF,
                   info->ACCRET_B[0],
                   info->poste_complement,
                   info->poste_complement_TRN5,
                   info->Gap,
                   6,
                   info->ACMTRS_NT);



  if (Complement_B == 0) //[032][034]
  {
    info->complement = 0;

    if (info->complementSRGTEF == 0)
    {
      Kn_PasCompl = 1;
      return 0;
    }
    CompleterPoste(info->LOB_CF,
                   info->ACCRET_B[0],
                   info->poste_complement,
                   info->poste_complement_TRN5,
                   info->Gap,
                   0,
                   info->ACMTRS_NT);

    return n_EstConstit; // [043]
  }

  /* FIN MODIFICATION */
  return n_EstConstit;
}




/*==============================================================================
objet :     fonction de calcul du complement
retour :    affecte exercice, annee de compte et complement.
            OK ---> traitement correctement effectue
==============================================================================*/
int EcrireGT(char **ptb_InRec, TINFO *info)
{
  DEBUT_FCT("EcrireGT");
  char OR[3];
  char sz_OCCYEA_NF[5]="";
	int DebPeriode = 0, FinPeriode = 0, Kn_ACY = 0;

  if (info->ACMTRS_NT[0] == '1')
    ptb_InRec[GT_ACCRET_B] = "A";
  else
    ptb_InRec[GT_ACCRET_B] = "R";
  // [057]
  if (Kn_mode == PA)
    strcpy(OR, "PA");
  else
    strcpy(OR, "PC");
  OR[2] = 0;
//[028]
//[029]
//[036]
  Kn_ACY = atoi (ptb_InRec[GT_ACY_NF]);

  init_SubTrsLigne();
  n_FindTsubTRS(&SubTrsLigne, info->poste_complement_TRN5);
//[030]
  if (strcmp(ptb_InRec[GT_SCOSTRMTH_NF], "") == 0)
  { 
    //[073]
  	char scorStrtMonth[3];
    strncpy(scorStrtMonth,Ksz_CLODAT + 4,2);
    scorStrtMonth[2] = 0;
    ptb_InRec[GT_SCOSTRMTH_NF] = scorStrtMonth;
  }

  if (strcmp(ptb_InRec[GT_SCOENDMTH_NF], "") == 0)
  { 
  	//[073]
  	char scorEndMonth[3];
    strncpy(scorEndMonth,Ksz_CLODAT + 4,2);
    scorEndMonth[2] = 0;
    ptb_InRec[GT_SCOENDMTH_NF] = scorEndMonth;
  }

  if (strcmp(ptb_InRec[GT_OCCYEA_NF], "") == 0)
  { 
  	//sprintf(ptb_InRec[GT_OCCYEA_NF], "%d" , info->exercice);
  	sprintf(sz_OCCYEA_NF, "%d" , info->exercice);
  	ptb_InRec[GT_OCCYEA_NF]=sz_OCCYEA_NF;
  }
//

  if (ptb_InRec[GT_ESTCRB_CT][0] == 'V')
  {
    n_WriteCols(Kp_OutESTCRBEXCLUSFile,ptb_InRec,SEPARATEUR,0);
  }

  if ( ((ptb_InRec[GT_ESTCRB_CT][0] == 'O') ||
       (ptb_InRec[GT_ESTCRB_CT][0] == ' ') ||
       (ptb_InRec[GT_ESTCRB_CT][0] == 'S') ||
       (ptb_InRec[GT_ESTCRB_CT][0] == 'A') || //[47]
       (ptb_InRec[GT_ESTCRB_CT][0] == 'E') || //[47]
       (ptb_InRec[GT_ESTCRB_CT][0] == 'D') || //[045]
       (ptb_InRec[GT_ESTCRB_CT][0] == 'T') || // ESTCRB Quarterly
       (ptb_InRec[GT_ESTCRB_CT][0] == 'U') )  // ESTCRB Quarterly
        && ptb_InRec[GT_ESTCRB_CT][0] != 'V') //[061]
  {
    /* ecriture dans le GT pour les traites cribles et speciaux */  //[033]
    // pour le quarterly, ecriture seulement si periode scor <= mois bilan et si mode PC, en mode PA on écrit tout jusqu'au mois 12
    if ( ( (ptb_InRec[GT_ESTCRB_CT][0] != 'U' && ptb_InRec[GT_ESTCRB_CT][0] != 'T') || Kn_mode == PA)
    	   || 
    	 	 ( ((ptb_InRec[GT_ESTCRB_CT][0] == 'U' || ptb_InRec[GT_ESTCRB_CT][0] == 'T') && (Kn_ACY < Kn_AnneeBilan || atoi(ptb_InRec[GT_ACM_NF]) <= Kn_MoisInv) ) )
    	 )
    {
    	DebPeriode = atoi(yearly ? ptb_InRec[GT_SCOSTRMTH_NF] : ptb_InRec[GT_SCOSTRMTH_NF]);
      FinPeriode = atoi(yearly ? ptb_InRec[GT_SCOENDMTH_NF] : ptb_InRec[GT_SCOENDMTH_NF]);

      if ( Kn_FilsSansPere == 1 )
      {
      	DebPeriode = atoi(ptb_InRec[GT_SCOSTRMTH_NF]);
      	FinPeriode = atoi(ptb_InRec[GT_SCOENDMTH_NF]);
      }
      //
      if ( DebPeriode == 0)
      {
      	DebPeriode = atoi(ptb_InRec[GT_BALSHRMTH_NF]);
      }
      if ( DebPeriode == 0)
      {
      	FinPeriode = atoi(ptb_InRec[GT_BALSHRMTH_NF]);
      }
	    fprintf(Kp_OutGTFile, "%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%d~%s~%s~%d~%d~%d~%s~%s~%.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%s~%.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%d~%s~~~~%d\n",
            ptb_InRec[GT_SSD_CF],
            ptb_InRec[GT_ESB_CF],
            Ksz_CLODAT,
            Ksz_CLODAT + 4,
            Ksz_CLODAT + 6,
            info->poste_complement,
            "",
            ptb_InRec[GT_CTR_NF],
            ptb_InRec[GT_END_NT],
            ptb_InRec[GT_SEC_NF],
            info->exercice,
            ptb_InRec[GT_UW_NT],
            ptb_InRec[GT_OCCYEA_NF],
            info->annee_compte,
            DebPeriode,// = yearly ? ptb_InRec[GT_SCOSTRMTH_NF] : scorPriodGt,
            FinPeriode,// = yearly ? ptb_InRec[GT_SCOENDMTH_NF] : scorPriodGt,
            ptb_InRec[GT_CLM_NF],
            ptb_InRec[GT_ESTCUR_CF],
            info->complement,
            ptb_InRec[GT_CED_NF],
            ptb_InRec[GT_BRK_NF],
            ptb_InRec[GT_PAY_NF],
            ptb_InRec[GT_KEY_NF],
            ptb_InRec[GT_ESTCUR_CF],  /* GT enrichi */
            info->complementSRGTEF,
            ptb_InRec[GT_NAT_CF],
            info->ACMTRS_NT,
            ptb_InRec[GT_ESTCTR_NF],
            ptb_InRec[GT_ESTSEC_NF],
            ptb_InRec[GT_LOB_CF],
            ptb_InRec[GT_SCOEGP_M],
            ptb_InRec[GT_ESTCRB_CT],
            ptb_InRec[GT_LIFTRTTYP_CF],
            ptb_InRec[GT_ACCADMTYP_CT],
            ptb_InRec[GT_SECSTS_CT],
            ptb_InRec[GT_PRD_NF],
            ptb_InRec[GT_SEG_NF],
            ptb_InRec[GT_COMACC_B],
            ptb_InRec[GT_ADJCOD_CT],
            OR,
            ptb_InRec[GT_DETTRS_CF],
            ptb_InRec[GT_ACCRET_B],
            ptb_InRec[GT_ESTUWY_NF],
            ptb_InRec[GT_LSTENDMTH_NF],
            ptb_InRec[GT_PROPER_N],
            ptb_InRec[GT_RTOCTY_CF],
            info->Gap,
            ptb_InRec[GT_BRKSCOEGP_M],
            info->mode_ventil); //[031]

	  }
  }
  else if (ptb_InRec[GT_ESTCRB_CT][0] == 'R')
  {
    /* ecriture dans le GT(enrichi) pour les traites de rattachement */ //[033]
    fprintf(Kp_OutSRGTEFile, "%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%d~%s~%s~%d~%2.2s~%2.2s~%s~%s~%.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%s~%.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%d~%s~~~~%d\n",
            ptb_InRec[GT_SSD_CF],
            ptb_InRec[GT_ESB_CF],
            Ksz_CLODAT,
            Ksz_CLODAT + 4,
            Ksz_CLODAT + 6,
            info->poste_complement,
            "",
            ptb_InRec[GT_CTR_NF],
            ptb_InRec[GT_END_NT],
            ptb_InRec[GT_SEC_NF],
            info->exercice,
            ptb_InRec[GT_UW_NT],
            ptb_InRec[GT_OCCYEA_NF],
            info->annee_compte,
            ptb_InRec[GT_SCOSTRMTH_NF],
            ptb_InRec[GT_SCOENDMTH_NF],
            ptb_InRec[GT_CLM_NF],
            ptb_InRec[GT_ESTCUR_CF],
            info->complement,

            "0",
            "",//20
            "0",
            ptb_InRec[GT_KEY_NF],
            ptb_InRec[GT_ESTCUR_CF],        /* GT enrichi *///
            info->complementSRGTEF,               /* estamt */
            ptb_InRec[GT_NAT_CF],
            info->ACMTRS_NT,
            ptb_InRec[GT_ESTCTR_NF],
            ptb_InRec[GT_ESTSEC_NF],
            ptb_InRec[GT_LOB_CF],
            ptb_InRec[GT_SCOEGP_M],
            ptb_InRec[GT_ESTCRB_CT],
            ptb_InRec[GT_LIFTRTTYP_CF],
            ptb_InRec[GT_ACCADMTYP_CT],
            ptb_InRec[GT_SECSTS_CT],
            ptb_InRec[GT_PRD_NF],
            ptb_InRec[GT_SEG_NF],
            ptb_InRec[GT_COMACC_B],
            ptb_InRec[GT_ADJCOD_CT],
            OR,
            ptb_InRec[GT_DETTRS_CF],
            ptb_InRec[GT_ACCRET_B],
            ptb_InRec[GT_ESTUWY_NF],
            ptb_InRec[GT_LSTENDMTH_NF],
            ptb_InRec[GT_PROPER_N],
            ptb_InRec[GT_RTOCTY_CF],
            info->Gap,
            ptb_InRec[GT_BRKSCOEGP_M],
            info->mode_ventil);  //[031]

  }
  RETURN_VAL (OK);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne des previsions synchronisee
        avec les mouvements comptables
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneMvt(
  char **ptb_InRecOwner ,         /* adresse de la ligne du maitre */
  char **ptb_InRecChild)          /* adresse de la ligne de l'esclave */
{
  TINFO GtInfo;
  int   n_EstConstit;
  int reslt = 0;
  int result = 0;
  first_gaap_writen = 0; //[032]
  char sz_Mnt[10];
  int		month;
  Kn_PasCompl = 0; // Mariem
  newbloc = 1;
  newblocSync = 1;
  char scorStrtMonth[3];
  char scorEndMonth[3];
  char Kz_ACY[5]="1111";
  
  DEBUT_FCT("n_ActionLigneMvt");

  /* Initialistion de la variable somme complement Gap presedant */
  init_SubTrsLigne();
  n_CompareTE(ptb_InRecOwner, ptb_InRecChild);
  sprintf(sz_Mnt, "%d", 0);

  /* recherche de la cle dans la table de pilotage */

  result = n_FindTsubTRS(&SubTrsLigne, ptb_InRecOwner[PRE_DETTRNCOD_CF]);

//[023]
//[024]
  if (result != -1)

  {
    Complement_B = SubTrsLigne.COMPLEMENT_B; //[034]
    if (strcmp(SubTrsLigne.LOGSIG_CT, "0") == 0)
    {
      gi_LogSig = 0;
    }
    else if (ptb_InRecOwner[PRE_ACMTRS_NT][0] == '1') // juste pour test, a enlever lorsque les PRE_ACCRET seront bien rempli

    {
      gi_LogSig = atoi(SubTrsLigne.LOGSIG_CT);
    }
    else
    {
      if (strcmp(SubTrsLigne.LOGSIG_CT, "1") == 0)
      {
        gi_LogSig = 2;
      }
      else
        gi_LogSig = 1;
    }
  }

//[023]
//[024]
  (void) memset(&GtInfo, 0, sizeof(TINFO));

  GtInfo.CTR_NF = ptb_InRecChild[GT_CTR_NF];
  GtInfo.SEC_NF = ptb_InRecChild[GT_SEC_NF];
  GtInfo.BALSHEY_NF = ptb_InRecChild[GT_BALSHEY_NF];
  GtInfo.BALSHRMTH_NF = ptb_InRecChild[GT_BALSHRMTH_NF];
  GtInfo.ACCADMTYP_CT = ptb_InRecOwner[PRE_ACCADMTYP_CT];
  GtInfo.LOB_CF = ptb_InRecChild[GT_LOB_CF];
  strcpy(GtInfo.ACMTRS_NT, ptb_InRecChild[GT_ACMTRS_NT]);
  GtInfo.ACCRET_B = ptb_InRecChild[GT_ACCRET_B];
  GtInfo.LIFTRTTYP_CF = ptb_InRecChild[GT_LIFTRTTYP_CF];
  GtInfo.SSD_CF = ptb_InRecChild[GT_SSD_CF];
  GtInfo.CUR_CF = ptb_InRecChild[GT_ESTCUR_CF];
  GtInfo.NAT_CF = ptb_InRecChild[GT_NAT_CF];
  GtInfo.UWGRP_CF = ptb_InRecChild[GT_UWGRP_CF]; /* ajout 12/01/98 */
  GtInfo.exercice = atoi(ptb_InRecChild[GT_UWY_NF]);
  GtInfo.annee_compte = atoi(ptb_InRecChild[GT_ACY_NF]);
  strcpy(GtInfo.poste_complement, ptb_InRecChild[GT_TRNCOD_CF]);
  strcpy(GtInfo.poste_complement_TRN5, ptb_InRecOwner[PRE_DETTRNCOD_CF]);
  GtInfo.Gap = atoi(ptb_InRecOwner[PRE_GAAP_NF]);
  GtInfo.mode_ventil = atoi(ptb_InRecChild[GT_GAAP_NF]); //[031] recuperation du spimod

  G_MGT = atof(ptb_InRecChild[GT_ESTAMT_M]);


  // Gestion de Gaap Interdit
  init_SubTrsEsBprop();
  n_RechSUBTRSESBPROP(&SubTrsEsBprop, GtInfo.poste_complement_TRN5, ptb_InRecOwner[PRE_SSD_CF], ptb_InRecOwner[PRE_ESB_CF]);
  switch (GtInfo.Gap)
  {
  case 1:
    if ( SubTrsEsBprop.GAAP1TRS_CT == 3)
    {
      strcpy(ptb_InRecOwner[PRE_ESTMNT_M], sz_Mnt);
    }
    break;
  case 2:
    if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
    {
      strcpy(ptb_InRecOwner[PRE_ESTMNT_M], sz_Mnt);
    }

    break;
  case 3:
    if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
    {
      strcpy(ptb_InRecOwner[PRE_ESTMNT_M], sz_Mnt);
    }

    break;
  case 4:
    if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
    {
      strcpy(ptb_InRecOwner[PRE_ESTMNT_M], sz_Mnt);
    }
    break;
  case 5:
    if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
    {
      strcpy(ptb_InRecOwner[PRE_ESTMNT_M], sz_Mnt);
    }
    break;
  default:  ;

  }
  n_EstConstit = n_CalculerComplement (&GtInfo,
                                       atof(ptb_InRecOwner[PRE_ESTMNT_M]),
                                       atof(ptb_InRecChild[GT_ESTAMT_M]),
                                       ptb_InRecOwner[PRE_ESTCRB_CT][0] ); //[047]
    if ( Flag_Depot == 1 && atoi(ptb_InRecChild[GT_COMACC_B])==1)
    {
    	n_EstConstit = 1;
    	Kn_PasCompl = 0;
    	//GtInfo.complement=atof(ptb_InRecOwner[PRE_ESTMNT_M]);
    } 

  /* pas d'ecriture dans GT simple */
  if (Kn_PasCompl == 1 || n_AcyCourante(GtInfo.CTR_NF, GtInfo.SEC_NF, GtInfo.exercice, GtInfo.annee_compte) > 0)
  {
    Kn_PasCompl = 0;
    gd_Summ_Compl_Gaap_Preced = 0;
    first_gaap_writen = 0; //[032]
    return (OK);
  }

  /* ecriture dans GT simple */
  //[036]
  init_SubTrsLigne();
  n_FindTsubTRS(&SubTrsLigne, GtInfo.poste_complement_TRN5);

  if (((SubTrsLigne.TRSTYPE_CT == 1) && ( GtInfo.Gap == 1)) || (SubTrsLigne.TRSTYPE_CT != 1)   ) //[44]
  {
    init_SubTrsEsBprop();
    n_RechSUBTRSESBPROP(&SubTrsEsBprop, GtInfo.poste_complement_TRN5, ptb_InRecOwner[PRE_SSD_CF], ptb_InRecOwner[PRE_ESB_CF]);
    switch (GtInfo.Gap)
    {
    case 1:
      if ( SubTrsEsBprop.GAAP1TRS_CT == 3)
      {
        GtInfo.complementSRGTEF = 0;

      }
      break;
    case 2:
      if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
      {
        GtInfo.complementSRGTEF = 0;
      }

      break;
    case 3:
      if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
      {
        GtInfo.complementSRGTEF = 0;
      }

      break;
    case 4:
      if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
      {
        GtInfo.complementSRGTEF = 0;
      }
      break;
    case 5:
      if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
      {
        GtInfo.complementSRGTEF = 0;
      }
      break;
    default:  ;

    }

    // Sauvegarde des valeurs periodes [101412]
    strncpy(scorStrtMonth,ptb_InRecChild[GT_SCOSTRMTH_NF],2);
    scorStrtMonth[2] = 0;
    strncpy(scorEndMonth,ptb_InRecChild[GT_SCOENDMTH_NF],2);
    scorEndMonth[2] = 0;
    
    if ((GtInfo.complement != 0) || (GtInfo.complementSRGTEF != 0) )
    {
    	EcrireGT(ptb_InRecChild, &GtInfo);
    	// Reecriture des valeurs periodes [101412]
      ptb_InRecChild[GT_SCOSTRMTH_NF] = scorStrtMonth;
      ptb_InRecChild[GT_SCOENDMTH_NF] = scorEndMonth;
    }
    
  }

  if (n_EstConstit == 1)
  { /* Creation d'une liberation */
    month = atoi(ptb_InRecOwner[PRE_ESTMTH_NF]);
    if (month == 12 || month == 13)
    {
      /* ecriture direct du bilan */
      GtInfo.annee_compte++;
      /* modification eventuelle de l'exercice */
      GtInfo.exercice += i_LiberationExeP1( atoi(GtInfo.ACMTRS_NT) , atoi(GtInfo.ACCADMTYP_CT) ); //[022]
    	/* Le complement change de signe */
    }

	if ( Flag_Depot == 1 )
	{
		//if ( Kbd_PILOTD[Kn_SyncPilot].COMACC_B == 0 )
		if ( atoi(ptb_InRecChild[GT_COMACC_B]) == 0 )
		{
			GtInfo.complement = atof(ptb_InRecOwner[PRE_ESTMNT_M]) - atof(ptb_InRecChild[GT_ESTAMT_M]);
			GtInfo.complementSRGTEF = atof(ptb_InRecOwner[PRE_ESTMNT_M]) - atof(ptb_InRecChild[GT_ESTAMT_M]);
		}
		else
		{
			if ( atof(ptb_InRecOwner[PRE_ESTMNT_M]) != 0 )
			{
				GtInfo.complement = atof(ptb_InRecOwner[PRE_ESTMNT_M]);
				GtInfo.complementSRGTEF = atof(ptb_InRecOwner[PRE_ESTMNT_M]);
			}
			else
			{
				GtInfo.complement = 0 - atof(ptb_InRecChild[GT_ESTAMT_M]);
				GtInfo.complementSRGTEF = 0 - atof(ptb_InRecChild[GT_ESTAMT_M]);
			}
		}

		// Verification si ACY+1 est compte complet
		sprintf(Kz_ACY,"%d", atoi(ptb_InRecChild[GT_ACY_NF])+1);
  	ptb_InRecChild[GT_ACY_NF]=Kz_ACY;
  	
    Kn_SyncPilot = n_RechPilot7000 ( ptb_InRecChild,GT_CTR_NF ,GT_SEC_NF, GT_ACY_NF, GT_ACM_NF, &ksz_indexPilot) ;
    sprintf(Kz_ACY,"%d", atoi(ptb_InRecChild[GT_ACY_NF])-1);
    ptb_InRecChild[GT_ACY_NF]=Kz_ACY;
    if ( Kbd_PILOTD[Kn_SyncPilot].COMACC_B == 1)
    {
    	  Flag_Depot_CC=1;
    	  RETURN_VAL (OK);
    }
	}
	if (month == 12)
	{
		month = 3;
		sprintf(ptb_InRecChild[GT_SCOSTRMTH_NF],"%d",month);
		sprintf(ptb_InRecChild[GT_SCOENDMTH_NF],"%d",month);
	}
	else
	{
		if (month != 13)
		{
			month += 3;
			sprintf(ptb_InRecChild[GT_SCOENDMTH_NF],"%d",month);
			ptb_InRecChild[GT_SCOSTRMTH_NF]=ptb_InRecChild[GT_SCOENDMTH_NF];
		}
	}
    GtInfo.complement = GtInfo.complement * (-1);
    GtInfo.complementSRGTEF = GtInfo.complementSRGTEF * (-1);
    /* Le poste se transforme en libération */

    init_SubTrsAssoLigne();

    reslt = n_FindTsubTRSAsso(&SubTrsAssoLigne, 1, 1, GtInfo.poste_complement_TRN5);

    if (reslt != (-1))
    {

      strcpy(GtInfo.poste_complement_TRN5, SubTrsAssoLigne.DETTRNCOD2_CF);
      GtInfo.poste_complement_TRN5[5] = 0;
    }
    else
    {

      GtInfo.poste_complement[4] += 1;
      GtInfo.poste_complement_TRN5[2] += 1;

    }

    if ( Flag_Depot == 1 )
    {
    	CompleterPoste(GtInfo.LOB_CF,
                 GtInfo.ACCRET_B[0],
                 GtInfo.poste_complement,
                 GtInfo.poste_complement_TRN5,
                 GtInfo.Gap,
                 0,
                 GtInfo.ACMTRS_NT);    
    }
    else
    {
      CompleterPoste ("0", '0', GtInfo.poste_complement, GtInfo.poste_complement_TRN5, 0, 0, GtInfo.ACMTRS_NT) ;
    }
    GtInfo.mode_ventil = 0;

    //[036]
    init_SubTrsLigne();
    n_FindTsubTRS(&SubTrsLigne, GtInfo.poste_complement_TRN5);
    if (((SubTrsLigne.TRSTYPE_CT == 1) && (GtInfo.complement != 0)) || (SubTrsLigne.TRSTYPE_CT != 1)  ) //[044]
    {
      init_SubTrsEsBprop();
      n_RechSUBTRSESBPROP(&SubTrsEsBprop, GtInfo.poste_complement_TRN5, ptb_InRecOwner[PRE_SSD_CF], ptb_InRecOwner[PRE_ESB_CF]);
      switch (GtInfo.Gap)
      {
      case 1:
        if ( SubTrsEsBprop.GAAP1TRS_CT == 3)
        {
          GtInfo.complementSRGTEF = 0;
        }
        break;
      case 2:
        if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
        {
          GtInfo.complementSRGTEF = 0;
        }

        break;
      case 3:
        if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
        {
          GtInfo.complementSRGTEF = 0;
        }

        break;
      case 4:
        if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
        {
          GtInfo.complementSRGTEF = 0;
        }
        break;
      case 5:
        if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
        {
          GtInfo.complementSRGTEF = 0;
        }
        break;
      default:  ;

      }

      EcrireGT(ptb_InRecChild, &GtInfo);

      if (month != 13)
      {
      	// Spira 81642 - On remet les valeurs initiales pour les autres gaap pour le quarterly
				sprintf(ptb_InRecChild[GT_SCOSTRMTH_NF],"%s",ptb_InRecChild[GT_ACM_NF]);
				sprintf(ptb_InRecChild[GT_SCOENDMTH_NF],"%s",ptb_InRecChild[GT_ACM_NF]);
			}
    }
  }
  if ((GtInfo.complement != 0) && (first_gaap_writen == 0))
    first_gaap_writen = 1; //[032] [039]
  if ((GtInfo.complement == 0) && (first_gaap_writen == 0 ) )
    gd_Summ_Compl_Gaap_Preced = 0;

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
  TINFO PrevInfo;
  int   n_EstConstit;
  int reslt = 0;
  int result = 0;
  gi_LogSig = 0;
  Complement_B = 0; //[034]
  char sz_Mnt[10];
  Kn_PasCompl = 0;
  int DebPeriode = 0, FinPeriode = 0;
  DEBUT_FCT("n_ActionPereSansFils");
  char DebTmp[2]="77" ;
  int month;

  (void) memset(&PrevInfo, 0, sizeof(TINFO));

  /* Initialistion de la variable somme complement Gap presedant */

  init_SubTrsLigne();
  sprintf(sz_Mnt, "%d", 0);

  /* recherche de la cle dans la table de pilotage */
  result = n_FindTsubTRS(&SubTrsLigne, ptb_InRec[PRE_DETTRNCOD_CF]);
//[023]
//[024]
  if (result != -1)

  {
    Complement_B = SubTrsLigne.COMPLEMENT_B; //[034]
    if (strcmp(SubTrsLigne.LOGSIG_CT, "0") == 0)
    {
      gi_LogSig = 0;
    }
    else if (ptb_InRec[PRE_ACMTRS_NT][0] == '1') // juste pour test, a enlever lorsque les PRE_ACCRET seront bien rempli

    {
      gi_LogSig = atoi(SubTrsLigne.LOGSIG_CT);
    }
    else
    {
      if (strcmp(SubTrsLigne.LOGSIG_CT, "1") == 0)
      {
        gi_LogSig = 2;
      }
      else
        gi_LogSig = 1;
    }
  }
//[023]
//[024]

  PrevInfo.CTR_NF = ptb_InRec[PRE_CTR_NF];
  PrevInfo.SEC_NF = ptb_InRec[PRE_SEC_NF];
  PrevInfo.BALSHEY_NF = ptb_InRec[PRE_BALSHEY_NF];
  PrevInfo.BALSHRMTH_NF = ptb_InRec[PRE_BALSHTMTH_NF];
  PrevInfo.ACCADMTYP_CT = ptb_InRec[PRE_ACCADMTYP_CT];
  PrevInfo.LOB_CF = ptb_InRec[PRE_LOB_CF];
  strcpy(PrevInfo.ACMTRS_NT , ptb_InRec[PRE_ACMTRS_NT]);
  PrevInfo.ACCRET_B = ptb_InRec[PRE_ACCRET_B];
  PrevInfo.LIFTRTTYP_CF = ptb_InRec[PRE_LIFTRTTYP_CF];
  PrevInfo.SSD_CF = ptb_InRec[PRE_SSD_CF];
  PrevInfo.CUR_CF = ptb_InRec[PRE_CUR_CF];
  PrevInfo.NAT_CF = ptb_InRec[PRE_NAT_CF];
  PrevInfo.UWGRP_CF = ptb_InRec[PRE_UWGRP_CF];
  PrevInfo.exercice = atoi(ptb_InRec[PRE_UWY_NF]);
  PrevInfo.annee_compte = atoi(ptb_InRec[PRE_ACY_NF]);
  strcpy(PrevInfo.poste_complement, ptb_InRec[PRE_DETTRS_CF]);
  strcpy(PrevInfo.poste_complement_TRN5, ptb_InRec[PRE_DETTRNCOD_CF]);
  PrevInfo.Gap = atoi(ptb_InRec[PRE_GAAP_NF]);
  PrevInfo.mode_ventil = atoi(ptb_InRec[PRE_SPIMOD_CT]);//[031]

  // Gestion de Gaap Interdit
  init_SubTrsEsBprop();
  n_RechSUBTRSESBPROP(&SubTrsEsBprop, PrevInfo.poste_complement_TRN5, ptb_InRec[PRE_SSD_CF], ptb_InRec[PRE_ESB_CF]);
  switch (PrevInfo.Gap)
  {
  case 1:
    if ( SubTrsEsBprop.GAAP1TRS_CT == 3)
    {
      strcpy(ptb_InRec[PRE_ESTMNT_M], sz_Mnt);
    }
    break;
  case 2:
    if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
    {
      strcpy(ptb_InRec[PRE_ESTMNT_M], sz_Mnt);
    }

    break;
  case 3:
    if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
    {
      strcpy(ptb_InRec[PRE_ESTMNT_M], sz_Mnt);
    }

    break;
  case 4:
    if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
    {
      strcpy(ptb_InRec[PRE_ESTMNT_M], sz_Mnt);
    }
    break;
  case 5:
    // [060]
    if(poste_modifie_PNA == 1)
    {
      gd_Summ_Compl_Gaap_Preced = 0; //pour ne plus annuler info.complement
      break;
    } // \[060]
    if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
    {
      strcpy(ptb_InRec[PRE_ESTMNT_M], sz_Mnt);
    }
    break;
  default:  ;

  }

  if (newbloc == 1 || (PrevInfo.Gap == 5 && poste_modifie_PNA == 1))
  {

    n_EstConstit = n_CalculerComplement(&PrevInfo, atof(ptb_InRec[PRE_ESTMNT_M]), G_MGT, ptb_InRec[PRE_ESTCRB_CT][0]); //[047]

    if ( Flag_Depot == 1 && Flag_Depot_CC == 1 )
    {
    	RETURN_VAL (OK); /* pas d'ecriture */
    }

  }
  else
    /* le montant comptable est considere comme = 0 */
  {
    gd_Summ_Compl_Gaap_Preced = 0;
    n_EstConstit = n_CalculerComplement(&PrevInfo, atof(ptb_InRec[PRE_ESTMNT_M]), 0, ptb_InRec[PRE_ESTCRB_CT][0]); //[047]

    newbloc = 1;
    G_MGT = 0;
    first_gaap_writen = 0; //[032]
  }
  if (Kn_PasCompl == 1 || n_AcyCourante(PrevInfo.CTR_NF, PrevInfo.SEC_NF, PrevInfo.exercice, PrevInfo.annee_compte) > 0)
  {
    Kn_PasCompl = 0;
    first_gaap_writen = 0; //[032]
    gd_Summ_Compl_Gaap_Preced = 0;
    RETURN_VAL (OK); /* pas d'ecriture */
  }


  /* JR 11/12/2007  SPOT 14688 Ajout postes VOBA 1163 2163
  on ajoute +1 en plus pour la generation des liberations des postes VOBA */
//    if (atoi(PrevInfo.ACMTRS_NT) == 1164)
  if (atoi(PrevInfo.ACMTRS_NT) % 1000 == 164)        // jr 19 06 2009   Spot 17629
  {
    PrevInfo.poste_complement[4] += 2;
  }
  /* ECRITURE GT */

  if (PrevInfo.ACMTRS_NT[0] == '1')
    ptb_InRec[PRE_ACCRET_B] = "A";
  else
    ptb_InRec[PRE_ACCRET_B] = "R";
  // [057]
  if (Kn_mode == PA)
    ptb_InRec[PRE_ORICOD_LS] = "PA";
  else
    ptb_InRec[PRE_ORICOD_LS] = "PC";
//[028]
//[029]
//[036]
  init_SubTrsLigne();
  n_FindTsubTRS(&SubTrsLigne, PrevInfo.poste_complement_TRN5);


//[036]
  if (SubTrsLigne.TRSTYPE_CT == 1 )
  {
    if (PrevInfo.complement == 0)
      RETURN_VAL (OK);
  }

  init_SubTrsEsBprop();
  n_RechSUBTRSESBPROP(&SubTrsEsBprop, PrevInfo.poste_complement_TRN5, ptb_InRec[PRE_SSD_CF], ptb_InRec[PRE_ESB_CF]);  //[044]

  switch (PrevInfo.Gap)
  {
  case 1:
    if ( SubTrsEsBprop.GAAP1TRS_CT == 3)
    {
      PrevInfo.complementSRGTEF = 0;
    }
    break;
  case 2:
    if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
    {
      PrevInfo.complementSRGTEF = 0;
    }

    break;
  case 3:
    if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
    {
      PrevInfo.complementSRGTEF = 0;
    }

    break;
  case 4:
    if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
    {
      PrevInfo.complementSRGTEF = 0;
    }
    break;
  case 5:
    // [060]
    if(poste_modifie_PNA == 1)
    {
      PrevInfo.complement = - PrevInfo.complement;
      PrevInfo.complementSRGTEF = - PrevInfo.complementSRGTEF;
      break;
    } // \[060]
    if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
    {
      PrevInfo.complementSRGTEF = 0;
    }
    break;
  default:  ;

  }

  if ( (ptb_InRec[PRE_ESTCRB_CT][0] == 'O') ||
       (ptb_InRec[PRE_ESTCRB_CT][0] == ' ') ||
       (ptb_InRec[PRE_ESTCRB_CT][0] == 'S') ||
       (ptb_InRec[PRE_ESTCRB_CT][0] == 'A') || //[047]
       (ptb_InRec[PRE_ESTCRB_CT][0] == 'E') || //[047]
       (ptb_InRec[PRE_ESTCRB_CT][0] == 'D') || //[045]
       (ptb_InRec[PRE_ESTCRB_CT][0] == 'T') || // ESTCRB Quarterly
       (ptb_InRec[PRE_ESTCRB_CT][0] == 'U') )  // ESTCRB Quarterly
  {
    if ( ((ptb_InRec[PRE_ESTCRB_CT][0] != 'U' && ptb_InRec[PRE_ESTCRB_CT][0] != 'T')  || Kn_mode == PA)
    	   || 
    	 	 ( ((ptb_InRec[PRE_ESTCRB_CT][0] == 'U' || ptb_InRec[PRE_ESTCRB_CT][0] == 'T') && ( atoi(ptb_InRec[PRE_ACY_NF]) <= Kn_AnneeBilan ) ) )
    	 )
    {
    		sprintf(DebTmp, "%.2s", Ksz_CLODAT + 4);
    	  //DebPeriode = atoi(yearly ? DebTmp : scorPriodGt);
      	//FinPeriode = atoi(yearly ? DebTmp : scorPriodGt);
      	//DebPeriode=atoi(ptb_InRec[PRE_ESTMTH_NF]);
      	//FinPeriode=atoi(ptb_InRec[PRE_ESTMTH_NF]);
      	DebPeriode=atoi(yearly ? DebTmp : ptb_InRec[PRE_ESTMTH_NF]);
      	FinPeriode=atoi(yearly ? DebTmp : ptb_InRec[PRE_ESTMTH_NF]);

  	    fprintf(Kp_OutGTFile, "%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%d~%s~%d~%d~%d~%d~%s~%s~%.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%s~%.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~~~%s~~%s~~~~~%d~%s~~~~%d\n",
            ptb_InRec[PRE_SSD_CF],
            ptb_InRec[PRE_ESB_CF],
            Ksz_CLODAT,
            Ksz_CLODAT + 4,
            Ksz_CLODAT + 6,
            PrevInfo.poste_complement,
            "",
            ptb_InRec[PRE_CTR_NF],
            ptb_InRec[PRE_END_NT],
            ptb_InRec[PRE_SEC_NF],
            PrevInfo.exercice,
            ptb_InRec[PRE_UW_NT],
            PrevInfo.exercice, /* occyea */
            PrevInfo.annee_compte,
            DebPeriode,//yearly ? Ksz_CLODAT + 4 : scorPriodGt,
            FinPeriode,//yearly ? Ksz_CLODAT + 4 : scorPriodGt,
            //Ksz_CLODAT + 4,
            //Ksz_CLODAT + 4,
            "", /* clm */
            ptb_InRec[PRE_CUR_CF],
            PrevInfo.complement,//19
            ptb_InRec[PRE_CED_NF],
            ptb_InRec[PRE_BRK_NF],
            ptb_InRec[PRE_PAY_NF],
            ptb_InRec[PRE_GANPAYORD_NT],
            ptb_InRec[PRE_CUR_CF],
            PrevInfo.complementSRGTEF,//25
            "",
            PrevInfo.ACMTRS_NT,
            "",
            "",
            PrevInfo.LOB_CF,  //  "",                 JR 07/04/05
            "",
            ptb_InRec[PRE_ESTCRB_CT],
            "",
            ptb_InRec[PRE_ACCADMTYP_CT],
            ptb_InRec[PRE_ORICOD_LS],
            ptb_InRec[PRE_ACCRET_B],
            PrevInfo.Gap, // pour test to mariem
            "",
            PrevInfo.mode_ventil //[031]
           );
		}
  }
  else if (ptb_InRec[PRE_ESTCRB_CT][0] == 'R')
  {
    fprintf(Kp_OutSRGTEFile, "%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%d~%s~%d~%d~%2.2s~%2.2s~%s~%s~%.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%s~%.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~~~%s~~%s~~~~~%d~%s~~~~%d\n",
            ptb_InRec[PRE_SSD_CF],
            ptb_InRec[PRE_ESB_CF],
            Ksz_CLODAT,
            Ksz_CLODAT + 4,
            Ksz_CLODAT + 6,
            PrevInfo.poste_complement,
            "",
            ptb_InRec[PRE_CTR_NF],
            ptb_InRec[PRE_END_NT],
            ptb_InRec[PRE_SEC_NF],
            PrevInfo.exercice,
            ptb_InRec[PRE_UW_NT],
            PrevInfo.exercice /* OCCYEA_NF */,
            PrevInfo.annee_compte,
            yearly ? Ksz_CLODAT + 4 : scorPriodGt,
            yearly ? Ksz_CLODAT + 4 : scorPriodGt,
            //Ksz_CLODAT + 4 /* SCOSTRMTH_NF */,
            //Ksz_CLODAT + 4 /* SCOENDMTH_NF */,
            "" /* CLM_NF */,
            ptb_InRec[PRE_CUR_CF],
            PrevInfo.complement,
            /* modif ANB le 16/7/98 */
            ptb_InRec[PRE_CED_NF],        // JR 08/04/05
            /* ptb_InRec[PRE_BRK_NF],
            ptb_InRec[PRE_PAY_NF],*/
            //        "0",
            "",
            "0",
            ptb_InRec[PRE_GANPAYORD_NT],
            ptb_InRec[PRE_CUR_CF],
            PrevInfo.complementSRGTEF,
            "",
            PrevInfo.ACMTRS_NT,
            "",
            "",
            PrevInfo.LOB_CF,  //  "",                 JR 07/04/05
            "",
            ptb_InRec[PRE_ESTCRB_CT],
            "",
            ptb_InRec[PRE_ACCADMTYP_CT],
            ptb_InRec[PRE_ORICOD_LS],
            ptb_InRec[PRE_ACCRET_B],
            PrevInfo.Gap, // pour test to mariem
            "",
            PrevInfo.mode_ventil //[031]
           );
  }

  if (n_EstConstit == 1)
  {

  	month = atoi(ptb_InRec[PRE_ESTMTH_NF]);

    if (month == 12 || month == 13)
    {
      /* ecriture direct du bilan */
      PrevInfo.annee_compte++;
      /* modification eventuelle de l'exercice */
      PrevInfo.exercice += i_LiberationExeP1( atoi(PrevInfo.ACMTRS_NT) , atoi(PrevInfo.ACCADMTYP_CT) ); //[022]
    	/* Le complement change de signe */
    }

		if (month == 12)
		{
			month = 3;
			sprintf(ptb_InRec[PRE_ESTMTH_NF],"%d",month);
		}
		else
		{
			if (month != 13)
			{
				month += 3;
				sprintf(ptb_InRec[PRE_ESTMTH_NF],"%d",month);
			}
		}

    PrevInfo.complement = PrevInfo.complement * (-1);
    PrevInfo.complementSRGTEF = PrevInfo.complementSRGTEF * (-1);
    /* Le poste se transforme en libération */
    init_SubTrsAssoLigne();

    reslt = n_FindTsubTRSAsso(&SubTrsAssoLigne, 1, 1, PrevInfo.poste_complement_TRN5);

    if (reslt != (-1))
    {
      strcpy(PrevInfo.poste_complement_TRN5, SubTrsAssoLigne.DETTRNCOD2_CF);
      PrevInfo.poste_complement_TRN5[5] = 0;
    }
    else
    {

      PrevInfo.poste_complement[4] += 1;
      PrevInfo.poste_complement_TRN5[2] += 1;

    }

    CompleterPoste ("0", '0', PrevInfo.poste_complement, PrevInfo.poste_complement_TRN5, 0, 0, PrevInfo.ACMTRS_NT) ;

    /* ECRITURE GT */
    if (PrevInfo.ACMTRS_NT[0] == '1')
      ptb_InRec[PRE_ACCRET_B] = "A";
    else
      ptb_InRec[PRE_ACCRET_B] = "R";

    // [057]
    if (Kn_mode == PA)
      ptb_InRec[PRE_ORICOD_LS] = "PA";
    else
      ptb_InRec[PRE_ORICOD_LS] = "PC";
//[028]
//[029]
//[036]
    init_SubTrsLigne();
    n_FindTsubTRS(&SubTrsLigne, PrevInfo.poste_complement_TRN5);

//[036]
    if (SubTrsLigne.TRSTYPE_CT == 1 )
    {
      if (PrevInfo.complement == 0)
        RETURN_VAL (OK);
    }
    init_SubTrsEsBprop();
    n_RechSUBTRSESBPROP(&SubTrsEsBprop, PrevInfo.poste_complement_TRN5, ptb_InRec[PRE_SSD_CF], ptb_InRec[PRE_ESB_CF]); //[44]
    switch (PrevInfo.Gap)
    {
    case 1:
      if ( SubTrsEsBprop.GAAP1TRS_CT == 3)
      {
        PrevInfo.complementSRGTEF = 0;
      }
      break;
    case 2:
      if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
      {
        PrevInfo.complementSRGTEF = 0;
      }

      break;
    case 3:
      if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
      {
        PrevInfo.complementSRGTEF = 0;
      }

      break;
    case 4:
      if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
      {
        PrevInfo.complementSRGTEF = 0;
      }
      break;
    case 5:
      // [060]
      if(poste_modifie_PNA == 1)
      {
        PrevInfo.complement = - PrevInfo.complement;
        PrevInfo.complementSRGTEF = - PrevInfo.complementSRGTEF;
        break;
      } // \[060]
      if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
      {
        PrevInfo.complementSRGTEF = 0;
      }
      break;
    default:  ;

    }


    /* JR 11/12/2007  SPOT 14688 Ajout postes VOBA 1163 2163
     on ajoute +1 en plus pour la generation des liberations des postes VOBA */
//
    if ( (ptb_InRec[PRE_ESTCRB_CT][0] == 'O') ||
         (ptb_InRec[PRE_ESTCRB_CT][0] == ' ') ||
         (ptb_InRec[PRE_ESTCRB_CT][0] == 'S') ||
         (ptb_InRec[PRE_ESTCRB_CT][0] == 'A') || //[047]
         (ptb_InRec[PRE_ESTCRB_CT][0] == 'E') || //[047]
         (ptb_InRec[PRE_ESTCRB_CT][0] == 'D') || //[045]
         (ptb_InRec[PRE_ESTCRB_CT][0] == 'T') || // ESTCRB Quarterly
         (ptb_InRec[PRE_ESTCRB_CT][0] == 'U') )  // ESTCRB Quarterly)
    {
      /* ecriture dans le GT(simple) pour les traites cribles et speciaux */

      if ( ((ptb_InRec[PRE_ESTCRB_CT][0] != 'U' && ptb_InRec[PRE_ESTCRB_CT][0] != 'T')  || Kn_mode == PA)
    	   || 
    	 	 ( ((ptb_InRec[PRE_ESTCRB_CT][0] == 'U' || ptb_InRec[PRE_ESTCRB_CT][0] == 'T') && ( atoi(ptb_InRec[PRE_ACY_NF]) <= Kn_AnneeBilan  ) ) )
    	   )
    	{

    		 sprintf(DebTmp, "%.2s", Ksz_CLODAT + 4); // [065]
      	 fprintf(Kp_OutGTFile, "%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%d~%s~%d~%d~%2.2s~%2.2s~%s~%s~%.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%s~%.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~~~%s~~%s~~~~~%d~%s~~~~%d\n",
              ptb_InRec[PRE_SSD_CF],
              ptb_InRec[PRE_ESB_CF],
              Ksz_CLODAT,
              Ksz_CLODAT + 4,
              Ksz_CLODAT + 6,
              PrevInfo.poste_complement,
              "",
              ptb_InRec[PRE_CTR_NF],
              ptb_InRec[PRE_END_NT],
              ptb_InRec[PRE_SEC_NF],
              PrevInfo.exercice,
              ptb_InRec[PRE_UW_NT],
              PrevInfo.exercice, /* occyea */
              PrevInfo.annee_compte,
              yearly ? DebTmp : ptb_InRec[PRE_ESTMTH_NF],
              yearly ? DebTmp : ptb_InRec[PRE_ESTMTH_NF],
              "", /* clm */
              ptb_InRec[PRE_CUR_CF],
              PrevInfo.complement,
              ptb_InRec[PRE_CED_NF],
              ptb_InRec[PRE_BRK_NF],
              ptb_InRec[PRE_PAY_NF],
              ptb_InRec[PRE_GANPAYORD_NT],
              ptb_InRec[PRE_CUR_CF],
              PrevInfo.complementSRGTEF,
              "",
              PrevInfo.ACMTRS_NT,
              "",
              "",
              PrevInfo.LOB_CF,  //  "",                 JR 07/04/05
              "",
              ptb_InRec[PRE_ESTCRB_CT],
              "",
              ptb_InRec[PRE_ACCADMTYP_CT],
              ptb_InRec[PRE_ORICOD_LS],
              ptb_InRec[PRE_ACCRET_B],
              PrevInfo.Gap, // pour test to mariem
              "",
              PrevInfo.mode_ventil //[031]
             );
			}
      //
//                            PrevInfo.ACMTRS_NT,
//                            PrevInfo.LOB_CF,                  // JR 07/04/05
//                            ptb_InRec[PRE_ESTCRB_CT],
//              ptb_InRec[PRE_ACCADMTYP_CT]);
    }
    else if (ptb_InRec[PRE_ESTCRB_CT][0] == 'R')
    {
      fprintf(Kp_OutSRGTEFile, "%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%d~%s~%d~%d~%2.2s~%2.2s~%s~%s~%.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%s~%.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~~~%s~~%s~~~~~%d~%s~~~~%d\n",
//  1 2    3    3     3     4  5 6   7  8  9 10 11 12 13    14    15 16  17   18 19 20 21                    40 41   42 43 44 45 46 47 48 48
//"%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%d~%s~%d~%d~%2.2s~%2.2s~%s~%s~%.3lf~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%s~%.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%d~%s\n",
              ptb_InRec[PRE_SSD_CF],
              ptb_InRec[PRE_ESB_CF],
              Ksz_CLODAT,
              Ksz_CLODAT + 4,
              Ksz_CLODAT + 6,
              PrevInfo.poste_complement,
              "",
              ptb_InRec[PRE_CTR_NF],
              ptb_InRec[PRE_END_NT],
              ptb_InRec[PRE_SEC_NF],
              PrevInfo.exercice,
              ptb_InRec[PRE_UW_NT],
              PrevInfo.exercice /* OCCYEA_NF */,
              PrevInfo.annee_compte,
              yearly ? Ksz_CLODAT + 4 : scorPriodGt,
              yearly ? Ksz_CLODAT + 4 : scorPriodGt,
              //scorPriodGt /* SCOSTRMTH_NF */,
              //scorPriodGt /* SCOENDMTH_NF */,
              //Ksz_CLODAT + 4 /* SCOSTRMTH_NF */,
              //Ksz_CLODAT + 4 /* SCOENDMTH_NF */,
              "" /* CLM_NF */,
              ptb_InRec[PRE_CUR_CF],
              PrevInfo.complement,
              /* modif ANB le 16/7/98 */
              ptb_InRec[PRE_CED_NF],    // jr 08/04/05
              "",
              "0",
              ptb_InRec[PRE_GANPAYORD_NT],
              ptb_InRec[PRE_CUR_CF], /* GT enrichi */
              PrevInfo.complementSRGTEF, // a faire evoluer en complement 2 ( ne pas prendre en consederation le GAP)
              "",
              PrevInfo.ACMTRS_NT,
              "",
              "",
              PrevInfo.LOB_CF,  //  "",                 JR 07/04/05
              "",
              ptb_InRec[PRE_ESTCRB_CT],
              "",
              ptb_InRec[PRE_ACCADMTYP_CT],
              ptb_InRec[PRE_ORICOD_LS],
              ptb_InRec[PRE_ACCRET_B],
              PrevInfo.Gap, // pour test to mariem
              "",
              PrevInfo.mode_ventil //[031]
             );
    }

  }
  if ((PrevInfo.complement != 0) && ( first_gaap_writen == 0))
    first_gaap_writen = 1; //[032]
  if ( (PrevInfo.complement == 0) && (first_gaap_writen == 0) )
    gd_Summ_Compl_Gaap_Preced = 0; //[032]
  RETURN_VAL (OK);
}



/*==============================================================================
objet :
        fonction lancee quand le fichier comptable participe seul

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPere(char **ptb_InRec)
{
  TINFO       GtInfo;
  int n_EstConstit;
  int result = 0;
  char DETTRNCOD[6];
  int reslt = 0;
  first_gaap_writen = 0; //[035]
  double mont = 0;
  int i = 0;
  int annee_cpt = 0; //[051]
  Kn_PasCompl = 0;
  poste_modifie_PNA = 0; //[049]
  int Kn_SavAcy = 0;
  int month;
  
  DEBUT_FCT("n_ActionFilsSansPere");

  /* Controle sur l'AC (ajoute le 14 jan 98) */
  /* on ne calcule des complements que pour les AC sur lesquelles */
  /* on peut saisir des previsions, ie celles comprises entre */
  /* annee bilan - 4 et annee bilan + 2 (bornes incluses) */
  /*Initialisation de la variable gd_Summ_Compl_Gaap_Preced, y aura une autre methode pour calculer le complement GAAP*/
  gd_Summ_Compl_Gaap_Preced = 0;

	Kn_SavAcy = atoi(ptb_InRec[GT_ACY_NF]);
	Kn_FilsSansPere = 1;
	
  n_CompareTE(NULL , ptb_InRec);
  
  init_SubTrsLigne();
  //[28]
  init_SubTrsEsBprop();

  strcpy(DETTRNCOD, ptb_InRec[GT_TRNCOD_CF] + 2);
  DETTRNCOD[5] = '\0';
  gi_LogSig = 0;
  Complement_B = 0; //[034]


  /* recherche de la cle dans la table de pilotage */
  result = n_FindTsubTRS(&SubTrsLigne, DETTRNCOD);
  if (result != (-1))
  {
    Complement_B = SubTrsLigne.COMPLEMENT_B; //[034]
    if (strcmp(SubTrsLigne.LOGSIG_CT, "0") == 0)
      gi_LogSig = 0;

    // else if (strcmp(ptb_InRec[GT_ACCRET_B],"1")==0)
    else if (ptb_InRec[GT_ACMTRS_NT][0] == '1')
    {
      gi_LogSig = atoi(SubTrsLigne.LOGSIG_CT);

    }

    else
    {
      if (strcmp(SubTrsLigne.LOGSIG_CT, "1") == 0)
        gi_LogSig = 2;
      else
        gi_LogSig = 1;
    }
  }

  
  // [057]
  if ((atoi(ptb_InRec[GT_ACY_NF]) < Kn_AnneeBilan - 4) ||
       (atoi(ptb_InRec[GT_ACY_NF]) > Kn_AnneeBilan + 4) )
  {
       return (OK);
  }
  // /////


  (void) memset(&GtInfo, 0, sizeof(TINFO));

  GtInfo.CTR_NF = ptb_InRec[GT_CTR_NF];
  GtInfo.SEC_NF = ptb_InRec[GT_SEC_NF];
  GtInfo.BALSHEY_NF = ptb_InRec[GT_BALSHEY_NF];
  GtInfo.BALSHRMTH_NF = ptb_InRec[GT_BALSHRMTH_NF];
  GtInfo.ACCADMTYP_CT = ptb_InRec[GT_ACCADMTYP_CT];
  GtInfo.LOB_CF = ptb_InRec[GT_LOB_CF];
  strcpy(GtInfo.ACMTRS_NT , ptb_InRec[GT_ACMTRS_NT]);
  GtInfo.ACCRET_B = ptb_InRec[GT_ACCRET_B];
  GtInfo.LIFTRTTYP_CF = ptb_InRec[GT_LIFTRTTYP_CF];
  GtInfo.SSD_CF = ptb_InRec[GT_SSD_CF];
  /* modif ANB le 16/07/98 CUR_CF devient ESTCUR_CF */
  GtInfo.CUR_CF = ptb_InRec[GT_ESTCUR_CF];
  GtInfo.NAT_CF = ptb_InRec[GT_NAT_CF];
  GtInfo.UWGRP_CF = ptb_InRec[GT_UWGRP_CF];

  GtInfo.exercice = atoi(ptb_InRec[GT_UWY_NF]);
  GtInfo.annee_compte = atoi(ptb_InRec[GT_ACY_NF]);
  strcpy(GtInfo.poste_complement, ptb_InRec[GT_TRNCOD_CF]);
  strcpy(GtInfo.poste_complement_TRN5, ptb_InRec[GT_TRNCOD_CF] + 2);
  GtInfo.poste_complement_TRN5[5] = 0;
  GtInfo.Gap = atoi(ptb_InRec[GT_GAAP_NF]);

  GtInfo.mode_ventil = atoi(ptb_InRec[GT_SPIMOD_CT]);//[031]
  annee_cpt = GtInfo.annee_compte;  //[051]

  for ( i = 1; i < 6; i++) //[049]
  {
    // Gestion de Gaap Interdit
    GtInfo.Gap = i; //le GTC est monogap
    init_SubTrsEsBprop();
    mont = (atof(ptb_InRec[GT_ESTAMT_M]) * -1) ;
    GtInfo.exercice = atoi(ptb_InRec[GT_UWY_NF]);
    GtInfo.annee_compte = annee_cpt;  //[051]
    strcpy(GtInfo.poste_complement, ptb_InRec[GT_TRNCOD_CF]);
    strcpy(GtInfo.poste_complement_TRN5, ptb_InRec[GT_TRNCOD_CF] + 2);
    GtInfo.poste_complement_TRN5[5] = 0;
    strcpy(GtInfo.ACMTRS_NT , ptb_InRec[GT_ACMTRS_NT]);
    // GtInfo.mode_ventil=9;

    n_RechSUBTRSESBPROP(&SubTrsEsBprop, GtInfo.poste_complement_TRN5, ptb_InRec[GT_SSD_CF], ptb_InRec[GT_ESB_CF]);
    switch (GtInfo.Gap)
    {
    case 1:
      if ( SubTrsEsBprop.GAAP1TRS_CT == 3)
      {
        mont = 0 ;

      }
      break;
    case 2:
      if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
      {
        mont = 0 ;

      }

      break;
    case 3:
      if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
      {
        mont = 0 ;

      }

      break;
    case 4:
      if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
      {
        mont = 0 ;

      }
      break;
    case 5:
      // [060]
      if(poste_modifie_PNA == 1)
      {
        gd_Summ_Compl_Gaap_Preced = 0; //pour ne plus annuler info.complement
        break;
      } // \[060]
      if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
      {
        mont = 0 ;

      }
      break;
    default:  ;

    }

    /* le montant de prevision est considere comme = 0 */
    n_EstConstit = n_CalculerComplement (&GtInfo, mont, 0, ptb_InRec[GT_ESTCRB_CT][0]);

    /* ecriture dans GT simple */
    //[036]
    init_SubTrsLigne();
    n_FindTsubTRS(&SubTrsLigne, GtInfo.poste_complement_TRN5);

    if (((SubTrsLigne.TRSTYPE_CT == 1) && ( GtInfo.Gap == 1)) || (SubTrsLigne.TRSTYPE_CT != 1)   ) //[44]

    {
      init_SubTrsEsBprop();
      n_RechSUBTRSESBPROP(&SubTrsEsBprop, GtInfo.poste_complement_TRN5, ptb_InRec[GT_SSD_CF], ptb_InRec[GT_ESB_CF]);
      switch (GtInfo.Gap)
      {
      case 1:
        if ( SubTrsEsBprop.GAAP1TRS_CT == 3)
        {
          GtInfo.complementSRGTEF = 0;
        }
        break;
      case 2:
        if ( SubTrsEsBprop.GAAP2TRS_CT == 3)
        {
          GtInfo.complementSRGTEF = 0;
        }

        break;
      case 3:
        if ( SubTrsEsBprop.GAAP3TRS_CT == 3)
        {
          GtInfo.complementSRGTEF = 0;
        }

        break;
      case 4:
        if ( SubTrsEsBprop.GAAP4TRS_CT == 3)
        {
          GtInfo.complementSRGTEF = 0;
        }
        break;
      case 5:
        // [060]
        if(poste_modifie_PNA == 1)
        {
          GtInfo.complement = - GtInfo.complement;
          GtInfo.complementSRGTEF = - GtInfo.complementSRGTEF;
          break;
        } // \[060]
        if ( SubTrsEsBprop.GAAP5TRS_CT == 3)
        {
          GtInfo.complementSRGTEF = 0;
        }
        break;
      default:  ;

      }
    }
    if ((GtInfo.complement != 0) || (GtInfo.complementSRGTEF != 0))
    {
      sprintf(ptb_InRec[GT_ACY_NF],"%d", Kn_SavAcy);
      EcrireGT(ptb_InRec, &GtInfo);
    }

    if (n_EstConstit == 1)
    {
		month = atoi(ptb_InRec[GT_ACM_NF]);

    if (month == 12 || month == 13)
    {
      /* ecriture direct du bilan */
      GtInfo.annee_compte++;
      /* modification eventuelle de l'exercice */
      GtInfo.exercice += i_LiberationExeP1( atoi(GtInfo.ACMTRS_NT) , atoi(GtInfo.ACCADMTYP_CT) ); //[022]
    	/* Le complement change de signe */
    }

	if (month == 12)
	{
		month = 3;
		sprintf(ptb_InRec[GT_SCOSTRMTH_NF],"%d",month);
		sprintf(ptb_InRec[GT_SCOENDMTH_NF],"%d",month);
	}
	else
	{
		if (month != 13)
		{
			month += 3;

		//sprintf(ptb_InRecChild[GT_SCOSTRMTH_NF],"%d",month);
		sprintf(ptb_InRec[GT_SCOENDMTH_NF],"%d",month);
		ptb_InRec[GT_SCOSTRMTH_NF]=ptb_InRec[GT_SCOENDMTH_NF];
		}
	}
		
      /* Le complement change de signe */
      GtInfo.complement = GtInfo.complement * (-1);
      GtInfo.complementSRGTEF = GtInfo.complementSRGTEF * (-1);
      /* Le poste se transforme en libération */
      init_SubTrsAssoLigne();

      reslt = n_FindTsubTRSAsso(&SubTrsAssoLigne, 1, 1, GtInfo.poste_complement_TRN5);

      if (reslt != (-1))
      {
        strcpy(GtInfo.poste_complement_TRN5, SubTrsAssoLigne.DETTRNCOD2_CF);
        GtInfo.poste_complement_TRN5[5] = 0;
      }
      else
      {

        GtInfo.poste_complement[4] += 1;
        GtInfo.poste_complement_TRN5[2] += 1;

      }
      CompleterPoste ("0", '0', GtInfo.poste_complement, GtInfo.poste_complement_TRN5, 0, 0, GtInfo.ACMTRS_NT) ;

      if ((GtInfo.complement != 0) || (GtInfo.complementSRGTEF != 0))
      {
        EcrireGT(ptb_InRec, &GtInfo);
      }
      if (month != 13)
      {
      	// Spira 81642 - On remet les valeurs initiales pour les autres gaap pour le quarterly
				sprintf(ptb_InRec[GT_SCOSTRMTH_NF],"%s",ptb_InRec[GT_ACM_NF]);
				sprintf(ptb_InRec[GT_SCOENDMTH_NF],"%s",ptb_InRec[GT_ACM_NF]);
			}
    }

    if ((poste_modifie_PNA == 0) && (SubTrsLigne.TRSTYPE_CT == 1)) //[049]
      break;
  }

  gd_Summ_Compl_Gaap_Preced = 0;
  poste_modifie_PNA = 0; //[059]
  RETURN_VAL (OK);
}


/*==========================================================================
     Objet :    Ecriture dans le fichier des anomalies

     Nom:       n_EcrireAno
===========================================================================*/
int n_EcrireAno(int n_ano, TINFO *info)
{
  DEBUT_FCT("n_EcrireAno");

  fprintf(Kp_AnoFile, "%d~%s~%s~%s~%d~%d~%s~%s~%s\n",
          n_ano,
          info->UWGRP_CF,  /* modif 12/01/98 */
          info->CTR_NF,
          info->SEC_NF,
          info->exercice,
          info->annee_compte,
          info->ACMTRS_NT,
          info->CUR_CF,
          info->SSD_CF );
  RETURN_VAL (0);
}



/*==========================================================================
     Objet :    Recherche un pilotage dans la table charge en memoire

     Nom:       n_RechPilot

     Parametres:  la prevision recherche

     Retour:    indice de le ligne du pilotage cherchee
                -1 si non trouvee
===========================================================================*/
int n_RechPilot (char **psz_prev, int n_indice)
{

  int i ;

  for (i = n_indice; i < Kn_NbLigPilot; i++)
  {
    if (strcmp(psz_prev[PRE_CTR_NF], Kbd_PILOT[i].CTR_NF) == 0 &&
        atoi(psz_prev[PRE_SEC_NF]) == Kbd_PILOT[i].SEC_NF &&
        atoi(psz_prev[PRE_ACY_NF]) == Kbd_PILOT[i].ACY_NF )
    {
      return i ;
    }
  }

  return (-1) ;
}

/*==========================================================================
     Objet :    Copie le contenu du fichier en entree dans un tableau
     

     Nom:       n_ChargerPilot

     Parametres:
                Le pointeur du fichier
                Le tableau de structures

     Retour:    0
===========================================================================*/
int n_ChargerPilot()
{
  int n_EOF = 0;
  T_LIFDRI_ALL bd_Lu;
  char MsgAno[300];

  DEBUT_FCT("n_ChargerPilot");

  if ( n_OpenFileAppl ("ESTC2137_I3", "rb", &Kp_PilotFile) == ERR )
    ExitPgm ( ERR_XX , "" );

  Kn_NbLigPilot = 0;
  /* Tant que la fin de fichier n'est pas atteinte,... */
  while ( n_EOF == 0 )
  {
    /* ... lecture d'une ligne dans le fichier. */
    if ( fread(&bd_Lu, sizeof(T_LIFDRI_ALL), 1, Kp_PilotFile) <= 0 )
      /* Fin de fichier, mise a jour du flag */
      n_EOF = 1;
    else {
      /* Ecriture dans log si depassement du tableau */
      if ( Kn_NbLigPilot >= NB_MAX_PILOT) {
        sprintf(MsgAno, "The number of Driving records  (/CTR %s /SEC %d /UWY %d) overflows the program's storage capacity",
                bd_Lu.CTR_NF,
                bd_Lu.SEC_NF,
                bd_Lu.UWY_NF);
        n_WriteAno(MsgAno);
        RETURN_VAL(0);
      }

      /* Enregistrement ecrit dans le tableau */
      Kbd_PILOT[Kn_NbLigPilot++] = bd_Lu;

    }
  }
  RETURN_VAL (0);
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
  strcpy(SubTrsLigne.SUBTRS_GL, "");
  strcpy(SubTrsLigne.SUBTRS_GS, "");
  strcpy(SubTrsLigne.SUBTRSEXP_D, "");
  strcpy(SubTrsLigne.SUBTRSINC_D, "");
  SubTrsLigne.CMT_NT = 0;
  SubTrsLigne.TRSINPUTTYPE_CT = 0;
  SubTrsLigne.TRSNATURE_CT = 0 ;
  strcpy(SubTrsLigne.LOGSIG_CT, "");
  strcpy(SubTrsLigne.LOB_CF, "");
  SubTrsLigne.TRSTYPE_CT = 0;
  SubTrsLigne.TRSPURERETRO_B = 0;
  SubTrsLigne.DACTYPE_B   = 0;
  SubTrsLigne.COMPLEMENT_B = 0;
  SubTrsLigne.NEWBALSHEETPROPAG_B = 0;
  SubTrsLigne.CELLPROTECEXC_B = 0;
}
/*==========================================================================
     Objet :    Initialisation de la structure TRSASSO

     Nom:       init_SubTrsAssoLigne

     Parametres:


     Retour:    0
===========================================================================*/
//[025]
void init_SubTrsAssoLigne()
{
  strcpy (SubTrsAssoLigne.ASSOTYP_CT, "");
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
/*==========================================================================
     Objet :    Initialisation de la structure TRS

     Nom:       init_SubTrsEsBprop

     Parametres:


     Retour:    0
===========================================================================*/
void init_SubTrsEsBprop()
{
  strcpy(SubTrsEsBprop.DETTRNCOD_CF, "");
  SubTrsEsBprop.SSD_CF = 0;
  SubTrsEsBprop.ESB_CF = 0;
  SubTrsEsBprop.GLTFEEDING_B = 0;
  SubTrsEsBprop.INTERNRETRO_B = 0;
  SubTrsEsBprop.SRVFEEDING_B = 0;
  SubTrsEsBprop.PREMIUMPNPEGPI_B = 0;
  SubTrsEsBprop.RETROAUTO_B = 0;
  SubTrsEsBprop.COMACIMPACT_B = 0;
  SubTrsEsBprop.CASHFLOWPOS_CT = 0;
  SubTrsEsBprop.GAAP1TRS_CT = 0;
  SubTrsEsBprop.GAAP2TRS_CT = 0;
  SubTrsEsBprop.GAAP3TRS_CT = 0;
  SubTrsEsBprop.GAAP4TRS_CT = 0;
  SubTrsEsBprop.GAAP5TRS_CT = 0;
  strcpy(SubTrsEsBprop.CRE_D, "");
  strcpy(SubTrsEsBprop.CREUSR_CF, "");
  strcpy(SubTrsEsBprop.LSTUPD_D, "");
  strcpy(SubTrsEsBprop.LSTUPDUSR_CF, "");
}


/*==============================================================================
objet :     Initialisation de la structure de rupture du Detail
retour:     OK
==============================================================================*/
int n_InitRuptPerim(T_RUPTURE_VAR *pbd_RuptPerim)  //[056]
{
  DEBUT_FCT("n_InitRuptDetail");

  memset(pbd_RuptPerim, 0, sizeof(T_RUPTURE_VAR));

  // Ouverture du fichier Detail
  if (n_OpenFileAppl("ESTC2137_I8", "rt", &(pbd_RuptPerim->pf_InputFil)) == ERR)
    ExitPgm ( ERR_XX , "Erreur ouverture fichier PERICASE" );

  pbd_RuptPerim->n_NbRupture   = 0;
  pbd_RuptPerim->n_ActionLigne = n_ActionLignePerim;
  pbd_RuptPerim->c_Separ       = SEPARATEUR;

  RETURN_VAL(OK);
}

/*==============================================================================
  Objet :     chargement de la structure contenant les dates d'effet et d'expiration
  Parametre : pointeur sur ligne pericase
  retour :    -1 si depassement de capacite
==============================================================================*/
int n_ActionLignePerim(char **ptb_InRec_Cur)  //[056]
{
  DEBUT_FCT("n_ActionLignePerim");

  if (Kn_Dates < MAX_DATES)
  {
    if (ptb_InRec_Cur[PER_CTR_NF] == 0)
      return 0;
    strcpy(L_DATES[Kn_Dates].sz_CTR_NF, ptb_InRec_Cur[PER_CTR_NF]);
    strcpy(L_DATES[Kn_Dates].sz_SEC_NF, ptb_InRec_Cur[PER_SEC_NF]);
    strcpy(L_DATES[Kn_Dates].sz_UWY_NF, ptb_InRec_Cur[PER_UWY_NF]);

    if (strcmp(ptb_InRec_Cur[PER_CTRTYP_CT], "TRT") == 0)     // Accept
    {
      strcpy(L_DATES[Kn_Dates].sz_EFFET_D, ptb_InRec_Cur[PER_SCOINC_D]);

      if(strcmp(ptb_InRec_Cur[PER_SCOINC_D],"") != 0 && strcmp(ptb_InRec_Cur[PER_EXP_D],"") == 0)
      {
        strcpy(L_DATES[Kn_Dates].sz_EXPIRATION_D,ptb_InRec_Cur[PER_SCOINC_D]);
        L_DATES[Kn_Dates].sz_EXPIRATION_D[4]='1';
        L_DATES[Kn_Dates].sz_EXPIRATION_D[5]='2';
        L_DATES[Kn_Dates].sz_EXPIRATION_D[6]='3';
        L_DATES[Kn_Dates].sz_EXPIRATION_D[7]='1';
      }
      else
      {
        strcpy(L_DATES[Kn_Dates].sz_EXPIRATION_D, ptb_InRec_Cur[PER_EXP_D]);
      }
      
    }
    else if (strcmp(ptb_InRec_Cur[PER_CTRTYP_CT], "RET") == 0) // Retro
    {
      strcpy(L_DATES[Kn_Dates].sz_EFFET_D, ptb_InRec_Cur[PER_CTRINCUWY_D]);
      if(strcmp(ptb_InRec_Cur[PER_CTRINCUWY_D],"") != 0 && strcmp(ptb_InRec_Cur[PER_EXP_D],"") == 0)
      {
        strcpy(L_DATES[Kn_Dates].sz_EXPIRATION_D,ptb_InRec_Cur[PER_CTRINCUWY_D]);
        n_AddYears(L_DATES[Kn_Dates].sz_EXPIRATION_D, 1, '+', L_DATES[Kn_Dates].sz_EXPIRATION_D); // [058]
        n_AddDays( L_DATES[Kn_Dates].sz_EXPIRATION_D, 1, '-', L_DATES[Kn_Dates].sz_EXPIRATION_D); // [058]
      }
      else
      {
        strcpy(L_DATES[Kn_Dates].sz_EXPIRATION_D, ptb_InRec_Cur[PER_EXP_D]);
      }
    }

    Kn_Dates++;
  }
  else
  {
    printf("Taille max de la structure atteinte\n");
    return -1;
  }

  RETURN_VAL(OK);
}

/*==========================================================================
  Objet :     Recherche des dates d'effet et d'expiration
  Parametres: Pointeur sur ligne prevision
  Retour:     position des dates recherchees dans L_DATES ou -1 si non trouve
===========================================================================*/
int n_RechercheDates(char *sz_CTR_NF, char *sz_SEC_NF, int n_UWY_NF)  //[056]
{
  //int i=Kn_Cpt_Dates;
  int i = Kn_Cpt_Dates_ctrsec;

  for (; i < Kn_Dates; i++)
  {
    if (strcmp(sz_ref_CTR, L_DATES[i].sz_CTR_NF) || strcmp(sz_ref_SEC, L_DATES[i].sz_SEC_NF))
    {
      sprintf(sz_ref_CTR, "%s", L_DATES[i].sz_CTR_NF);
      sprintf(sz_ref_SEC, "%s", L_DATES[i].sz_SEC_NF);
      Kn_Cpt_Dates_ctrsec = i;
    }

    //if (strcmp(L_DATES[Kn_Dates].sz_CTR_NF, "") == 0)
    //return -1;

    if (strcmp(L_DATES[i].sz_CTR_NF, sz_CTR_NF) == 0 &&
        strcmp(L_DATES[i].sz_SEC_NF, sz_SEC_NF) == 0 &&
        atoi(L_DATES[i].sz_UWY_NF) == n_UWY_NF)
    {
      Kn_Cpt_Dates = i;
      //printf("trouve\n");
      return i;
    }

    if (strcmp(L_DATES[i].sz_CTR_NF, sz_CTR_NF) > 0 ||
        (strcmp(L_DATES[i].sz_CTR_NF, sz_CTR_NF) == 0 &&
         strcmp(L_DATES[i].sz_SEC_NF, sz_SEC_NF) > 0) ||
        (strcmp(L_DATES[i].sz_CTR_NF, sz_CTR_NF) == 0 &&
         strcmp(L_DATES[i].sz_SEC_NF, sz_SEC_NF) == 0 &&
         atoi(L_DATES[i].sz_UWY_NF) > n_UWY_NF ))
    {
      //printf("pas trouve 1\n");
      return -1;
    }
  }
  //printf("pas trouve 2\n");
  return -1; // si non trouve
}

/*==========================================================================
  Objet :     Acy Courante
  Parametres: Pointeur sur ligne prevision
  Retour:     0 si la prevision est courante
              -1 si la prevision est passee
              +1 si la prevision est future
===========================================================================*/
int n_AcyCourante(char *sz_CTR_NF, char *sz_SEC_NF, int n_UWY_NF, int n_ACY_NF)  //[056]
{
  int n_Dates;
  int n_annee_eff, n_mois_eff, n_annee_exp, n_mois_exp, n_jour_exp, n_acy, n_diff_dates;
  int n_tot_b, n_tot_eff, n_tot_exp;

  n_acy = n_ACY_NF;

  n_Dates = n_RechercheDates(sz_CTR_NF, sz_SEC_NF, n_UWY_NF);
  //[057]
  if (Kn_mode == PA || n_Dates == -1 ||
      strcmp(L_DATES[n_Dates].sz_EFFET_D, "") == 0 ||
      strcmp(L_DATES[n_Dates].sz_EXPIRATION_D, "") == 0) // dates non trouvees
  {
    if (n_ACY_NF < Kn_AnneeBilan)
      return -1;
    if (n_ACY_NF > Kn_AnneeBilan)
      return 1;
    return 0;
  }

  sscanf(L_DATES[n_Dates].sz_EFFET_D,      "%4d%2d", &n_annee_eff, &n_mois_eff);
  sscanf(L_DATES[n_Dates].sz_EXPIRATION_D, "%4d%2d%2d", &n_annee_exp, &n_mois_exp, &n_jour_exp);

  // R03 Date d’expiration = mois d’expiration -1 sauf si la date d’expiration est le dernier jour du mois
  if(n_jour_exp < n_nbJoursDansMois(n_annee_exp,n_mois_exp))
  {
    n_mois_exp--;
    if(n_mois_exp < 1)
    {
      n_annee_exp--;
      n_mois_exp=12;
    }
  }

  // glissement des dates (sur ACY)
  n_diff_dates = n_acy - n_annee_eff;
  if (n_acy > n_annee_eff)
  {
    n_annee_eff = n_acy;
    if (n_mois_exp == 12)
    {
      n_mois_eff = 1;
      n_annee_exp = n_annee_eff;
    }
    else if (n_mois_exp == 1)
    {
      n_mois_eff = 2;
      n_annee_exp = n_annee_eff + 1;
    }
    else
    {
      n_mois_eff = n_mois_exp + 1;
      n_annee_exp = n_annee_eff + 1;
    }
  }

  n_tot_b   = 12 * Kn_AnneeBilan + Kn_MoisBilan;
  n_tot_eff = 12 * n_annee_eff + n_mois_eff;
  n_tot_exp = 12 * n_annee_exp + n_mois_exp;

  if (n_tot_b > n_tot_exp)
    return -1;

  if (n_tot_b < n_tot_eff)
    return 1;

  return 0;
}

/*==========================================================================
  Objet :     Nombre de jours dans un mois
  Parametres: annee et mois
  Retour:     nombre de jours dans le mois
===========================================================================*/
int n_nbJoursDansMois(int annee, int mois)
{
  /* Case where the month of the settlement date is among [january, march, may, july, august, october or december] */
  if ((mois == 1) || (mois == 3) || (mois == 5) || (mois == 7) || (mois == 8) || (mois == 10) || (mois == 12))
  {
    return 31;
  }
  /* Case where the month of the settlement date is among [april, june, september or november] */
  if ((mois == 4) || (mois == 6) || (mois == 9) || (mois == 11))
  {
    return 30;
  }
  /* Case where the month of the settlement date is february, it must be taken into account that the year is a leap year or not */
  if (mois == 2)
  {
    /* Is it a leap year ? */
    if ((((annee % 4) == 0) && ((annee % 100) != 0)) || ((annee % 400) == 0))
      return 29;
    else
      return 28;
  }

  /* si non trouve (annee et/ou mois en parametre non valide) */
  return 0;
}
