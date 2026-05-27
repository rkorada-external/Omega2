/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Determination des previsions intermediaires
nom du source                 : ESTC2136.c
revision                      : $Revision: 1.12 $
date de creation              : 22/07/1997
auteur                        : C. Chavatte
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Pour tout enregistrement des previsions correspondant a l'annee
        d'inventaire (date d'inventaire passee en parametre) le montant
        estime est corrige au prorata du nombre de mois.

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    19/08/98    M.HA-THUC Calcul automatique d'une prevision intermediaire
        de RPP/S, si en entree on a une prevision d'EPP/S
        sans RPP/S

 30/08/2006    J. Ribot  Spot 13087  ajout postes rétro (PTC + ventilation) 2083 2084 + 2603 2604 2623 2624 2633 2634

 07/12/2007    J.Ribot   SPOT 14688 Ajout postes VOBA 1163 2163
 14/02/2008    J.Ribot   SPOT 12723 Ajout postes 2193
 21/02/2008    J.Ribot   SPOT 14307 ne pas trimestrialiser les contrats non renouvellés selon le type comptable
 15/04/2008    J.Ribot   SPOT 15221 Autoriser la saisie en lob non vie dans le Poste provision prime constistuée cédante ajustement GAAP (poste 1073)
 05/11/2008    J.Ribot   SPOT 16409 prise en compte du poste 2145 commission financement
 19/05/2009    J.rbot    SPOT 16263 prise en compte du poste 2263 ptc rétro => passé en fiche 17504
_________________
MODIFICATION    [009]
Auteur:         D.GATIBELZA
Date:           22/01/2010
Version:        9.1
Description:    INDENTATION
_________________
MODIFICATION    [010]
Auteur:         D.GATIBELZA
Date:           28/07/2010
Version:        10.1
Description:    ESTVIE18754 Creation ligne fds egal. stab dans onglet Primes ( pour tout et tous )
                faire le 1093 en dupliquant comme le 1063 et le 1094 comme le 1064
_________________
MODIFICATION    [011]
Auteur:         JF-VDV
Date:           02/09/2010
Version:        10.1
Description:   [18754] Creation ligne fds egal. stab dans onglet Primes ( pour tout et tous )
                faire le 1543 en dupliquant comme le 1093 et le 2543 comme le 2093

[012] 25/11/2013 -=Dch=-       :spot:25773  - Omega 2B modification de colonnes pour LIFEST
[012] 04/03/2014 R. cassis :spot:25427 - correction technique strcpy remplace par =
[013] 11/06/2014 M. Mariem :           - Modification de condition de repture1 et repture2
[014] 10/07/2014 ABJ  spot:25773 : Correction du DETTRNCOD pour la 1263
[015] 19/08/2014 ABJ  spot:25773 : Correction des commentaires
[016] 29/08/2014 ABJ  spot:25773 : Suppression de traitement supplementaire pour les postes pour les non vie
[017] 29/08/2014 ABJ  spot:25773 : Automatisation de la generation des constit apartir de liberation
[018] 01/09/2014 ABJ  spot:25773 : Initialisation des variables pour les E/S PF
[019] 05/09/2014 ABJ  spot:25773 : Correction pour E/S PF
[020] 01/10/2014 ABJ  spot:25773 : Traitement des constit et liberation sur les 1010  et 1140
[021] 13/10/2014 SBE  spot:25773 : Traitement Liberation 1014 et 1144
[022] 20/11/2014 SBE  spot:25773 : Traitement des nouvelles acmtrs 1393/1383/1363
[023] 26/03/2015 SAS  spot : 28512 changement de la devise des postes analytics la SGLA02
[023] 20/11/2014 ABJ  spot:28639 : Traitement des nouvelles acmtrs 1493/1483
[024] 27/05/2015 SAS  spot : 28512 réajustement de la condition de verification des libérations, constitutions, entrées ou retraits
[025] 31/08/2015 SAS  spot :   modification de la trimestrialisation des entrees et retraits de portefeuille
[026] 15/02/2016 DFI  spot:30195   EST27 Trimestrialisation des traites decales
[027] 24/02/2016 SAS  spot 30250 : Parametrage postes analytiques
[028] 12/05/2016 DFI  spot:      : EST27 modification calcul date expiration retro
[029] 05/09/2016 DFI  spot:31153 : Correction trimestrialisation 2145
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

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE *Kp_PrevFil;           /* pointeur sur les previsions en sortie    */
FILE   *Kp_SubTRSAssoFile, *Kp_SubTRSFile;
T_RUPTURE_VAR bd_RuptPrev;  /* gestion rupture sur Prev                 */
T_RUPTURE_VAR pbd_RuptPerim;/* gestion rupture sur Perimetre            */  //[026]
int Kn_annee,               /* Annee d'inventaire                       */
    Kn_annee1,              /* Annee d'inventaire - 1                   */
    Kn_mois,                /* Mois d'inventaire                        */
    Kb_AnInv,               /* 1 si ACY=annee d'inventaire, 0 sinon     */
    Kn_postegen,            /* Ancien poste                             */
    Kb_rollback,            /* 1 si rollback possible, 0 sinon          */
    Kn_Dates,               /* dates effet et expiration par CTR/SEC/UWY*/  //[026]
    Kn_Cpt_Dates,           /* compteur sur structure Dates             */  //[026]
    Kn_Cpt_Dates_ctrsec=0;  /* compteur sur structure Dates premiere
                                          ocurrence CTR/SEC             */  //[026]
int KnEffacer = 0;                                          

char sz_ref_CTR[30] = "";   /* CTR reference pour recherche dates       */  //[026]
char sz_ref_SEC[4]  = "";   /* SEC reference pour recherche dates       */  //[026]

double Kd_coef,             /* Coefficient = mois d'inventaire / 12     */
       Kd_RP,               /* Retrait de portefeuille                  */
       Kd_EP,               /* Entree de portefeuille                   */
       Kd_Lib,              /* Liberation                               */
       Kd_Cst;              /* Constitution                             */

enum MODE {
  PA = 0,
  PC = 1
} Kn_mode;     //[026]

fpos_t K_pos;

T_SUBTRS     SubTrsLigne;
int n_InitPrev(T_RUPTURE_VAR *pbd_RuptPerim) ;  //[026]
int n_ActionLignePrev(char **pbd_RuptPerim);    //[026]
int n_IsR1Prev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_IsR2Prev(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRupt1Prev(char **ptb_InRec_Cur);
int n_ActionLastRupt1Prev(char **ptb_InRec_Cur);
int n_ActionFirstRupt2Prev(char **ptb_InRec_Cur);
void EcrirePrevision(double d, char **psz_ligne);

int n_InitRuptPerim(T_RUPTURE_VAR *pbd_Rupt);  //[026]
int n_ActionLignePerim(char **pbd_InRec_Cur);  //[026]
double d_CalculerRatio(char **ptb_InRec_Cur);  //[026]
int n_AcyCourante(char **ptb_InRec_Cur);       //[026]
int n_nbJoursDansMois(int annee, int mois);    //[026]

//[17]
int n_InitTACCPAR                       (T_RUPTURE_VAR  *);     // Initialisation de traitement du fichier TACCPAR
int n_ActionLigneTACCPAR                (char **);              // à chaque ligne du fichier TACCPAR_I3
int n_RechercheTACCPAR                (char *);
void init_SubTrsLigne();  //[023]

typedef struct
{
  char sz_RETCOD[2];
  char sz_SPIMOD[2];
  char sz_ADJCOD[2];
  char  ACmtrs[5];
} T_POST_INFO;

T_POST_INFO L_PostInfo_ACMTRS[180];    //Modification parametrage TACCPAR [027]


typedef struct
{
  char sz_CTR_NF[10];
  char sz_SEC_NF[4];
  char sz_UWY_NF[6];
  char sz_EFFET_D[9];
  char sz_EXPIRATION_D[9];
} T_DATES;   //[026]

#define MAX_DATES 5000000   //[026]

T_DATES L_DATES[MAX_DATES];   //[026]

char champs[10] = "";
T_RUPTURE_VAR bd_RuptTACCPAR;                                   // Gestion rupture

int K = 0; // nombre de ACMTRS from TACCPAR

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{
  char sz_annee[5], sz_mois[3];
  char sz_clodat[9] ;
  char sz_clodatyea[5], sz_clodatmth[3], sz_clodatday[3] ;
  char sz_mode[3];  //[026]


  /* Initialisation des signaux */
  InitSig();

  if (n_BeginPgm (argc, argv) == ERR)
    ExitPgm (ERR_XX, "");

  /* Recuperation des dates d'inventaire */
  strcpy (sz_annee,  psz_GetCharArgv(1));
  strcpy (sz_mois,   psz_GetCharArgv(2));
  strcpy (sz_clodat, psz_GetCharArgv(3));
  strcpy (sz_mode,   psz_GetCharArgv(4));  //[026]

  /* Eclatement du clodat AAAAMMJJ en 3 chaines de caractere */
  /*    sscanf( sz_clodat, "%4s%2s%2s", sz_clodatyea, sz_clodatmth, sz_clodatday ) ;*/
  sscanf( sz_clodat, "%4s%2s%2s", sz_clodatyea, sz_clodatmth, sz_clodatday ) ;

  printf("Params lus :\nBALSHTYEA_NF %s\nBALSHTMTH_NF %s\nCLODAT_D %s\nMODE %s\n",
         sz_annee, sz_mois, sz_clodat, sz_mode);  //[026]

  /* Calcul du coefficient */
  //Kd_coef = atof( sz_clodatmth ) / 12.0;   //[026]

  /* Isolement de l'annee et du mois */
  /*Kn_mois=atoi(sz_mois);
  Kn_annee=atoi(sz_annee);
  Kn_annee1=Kn_annee -1;*/

  Kn_mois = atoi(sz_clodatmth);
  Kn_annee = atoi(sz_clodatyea);
  Kn_annee1 = Kn_annee - 1;

  //[026]
  if(strcmp(sz_mode,"PA")==0)
    Kn_mode = PA;
  if(strcmp(sz_mode,"PC")==0)
    Kn_mode = PC;

  memset(&L_PostInfo_ACMTRS, 0, 150 * sizeof(T_POST_INFO));

  /* Ouverture des fichiers en sortie wt */
  if ( n_OpenFileAppl ("ESTC2136_O1", "w", &Kp_PrevFil) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_InitTACCPAR(&bd_RuptTACCPAR) )
    ExitPgm ( ERR_XX , "" );

  if ( n_ProcessingRuptureVar (&bd_RuptTACCPAR) == ERR )
    ExitPgm ( ERR_XX , "" );

  if ( n_OpenFileAppl ("ESTC2136_I3", "rb", &Kp_SubTRSAssoFile) == ERR )
    ExitPgm ( ERR_XX , "" );
  n_ChargerTsubTRSAsso(Kp_SubTRSAssoFile);

  if ( n_OpenFileAppl ("ESTC2136_I4", "rb", &Kp_SubTRSFile) == ERR ) //[023]
    ExitPgm ( ERR_XX , "" );
  n_ChargerTsubTRS(Kp_SubTRSFile);

  // Chargement structure contenant les dates d'effet et d'expiration   //[026]
  if ( n_InitRuptPerim(&pbd_RuptPerim) )
    ExitPgm ( ERR_XX , "Erreur a l'ouverture du fichier PERICASE" );
  Kn_Cpt_Dates=0; // initialisation du compteur sur structure Dates
  if ( n_ProcessingRuptureVar(&pbd_RuptPerim) == ERR )
    ExitPgm ( ERR_XX , "Erreur lors du chargement du PERICASE" );

  /* Initialisation de la varible bd_RuptPrev */
  if ( n_InitPrev(&bd_RuptPrev) )
    ExitPgm ( ERR_XX , "" );

  // initialisation de la structure retour  //[]
  init_SubTrsLigne();

  /* Lancement du traitement du fichier */
  if ( n_ProcessingRuptureVar (&bd_RuptPrev) == ERR )
    ExitPgm ( ERR_XX , "" );

  /* Fermeture fichier */
  if (n_CloseFileAppl ("ESTC2136_I1", &(bd_RuptPrev.pf_InputFil)))
    ExitPgm ( ERR_XX , "" );

  if (n_CloseFileAppl ("ESTC2136_O1", &Kp_PrevFil))
    ExitPgm ( ERR_XX , "" );
  if (n_CloseFileAppl ("ESTC2136_I2", &(bd_RuptTACCPAR.pf_InputFil)))
    ExitPgm ( ERR_XX , "" );
  if (n_CloseFileAppl ("ESTC2136_I3", &Kp_SubTRSAssoFile) == ERR)
    ExitPgm ( ERR_XX , "" );
  if (n_CloseFileAppl ("ESTC2136_I4", &Kp_SubTRSFile) == ERR) //[023]
    ExitPgm ( ERR_XX , "" );

   
  if ( n_EndPgm () == ERR )
    ExitPgm ( ERR_XX , "" );


  exit(0);
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier maitre.
retour :    0
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitPrev");

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  if ( n_OpenFileAppl ("ESTC2136_I1", "rt", &(pbd_Rupt->pf_InputFil)))
    RETURN_VAL (ERR);

  pbd_Rupt->n_NbRupture = 2 ;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;
  pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt1Prev;
  pbd_Rupt->n_ActionLast[0]  = n_ActionLastRupt1Prev;

  pbd_Rupt->n_ConditionRupture[1] = n_IsR2Prev;
  pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRupt2Prev;

  pbd_Rupt->n_ActionLigne = n_ActionLignePrev ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de rupture de niveau 1
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
  if (strcmp(ptb_InRec[PRE_GAAP_NF], ptb_InRec_Cur[PRE_GAAP_NF]) != 0) // Ajout Rupture Gaap [015]
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_UWY_NF], ptb_InRec_Cur[PRE_UWY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ACY_NF], ptb_InRec_Cur[PRE_ACY_NF]) != 0)
    RETURN_VAL(1);

  RETURN_VAL (0);
}


/*==============================================================================
objet :     fonction de test de rupture de niveau 2
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR2Prev(char **ptb_InRec, char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR2Prev");

  if (strcmp(ptb_InRec[PRE_CTR_NF], ptb_InRec_Cur[PRE_CTR_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_SEC_NF], ptb_InRec_Cur[PRE_SEC_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_GAAP_NF], ptb_InRec_Cur[PRE_GAAP_NF]) != 0) // Ajout Rupture Gaap [015]
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_UWY_NF], ptb_InRec_Cur[PRE_UWY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ACY_NF], ptb_InRec_Cur[PRE_ACY_NF]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_ACMTRS_NT], ptb_InRec_Cur[PRE_ACMTRS_NT]) != 0)
    RETURN_VAL(1);
  if (strcmp(ptb_InRec[PRE_DETTRNCOD_CF], ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != 0) // Ajout Rupture PRE_DETTRNCOD_CF 07012014
    RETURN_VAL(1);

  RETURN_VAL (0);
}


/*==============================================================================
objet : Fonction lancee a chaque rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRupt1Prev (char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionFirstRupt1Prev");

  /* Réinitialisation de la variable rollback dans tous les cas */
  Kb_rollback = 0;
  KnEffacer=0;
  //[019]
  /* Réinitialisation des variables sauf si on est sur l'année d'inventaire */
  if ( atoi(ptb_InRec_Cur[PRE_ACY_NF]) != Kn_annee )   //[18]
  {
    Kd_RP = 0;
    Kd_EP = 0;
    Kd_Lib = 0;
    Kd_Cst = 0;
  }


  RETURN_VAL(0);
}


/*==============================================================================
objet : Fonction lancee a chaque rupture premiere de niveau 2
==============================================================================*/
int n_ActionFirstRupt2Prev (char **ptb_InRec_Cur)
{
  double d_montant = 0, d_coeff;   //[026]
  int  n_poste, n_UnitePoste, pre_accadmtyp_ct, m_poste;
  char sz_poste[5];
  int dettrncod;
  int result = 0;
  char ZDETTRNCOD[6];

  DEBUT_FCT("n_ActionFirstRupt2Prev");

  /* Traitement effectue pour les inventaires intermedaire */
  //if ( Kn_mois == 12 )    //[026]
  if ( Kn_mode == PA )
  {
    n_WriteCols(Kp_PrevFil, ptb_InRec_Cur, '~', 0);
    RETURN_VAL(0);

  }

  /* Si l'annee de compte ne correspond pas a l'annee d'inventaire, */
  /* l'indicateur est mis a 0 pour interdire tout traitement de modification */
  /*if ( atoi(ptb_InRec_Cur[PRE_ACY_NF]) == Kn_annee ) */
  // [026]
  if(n_AcyCourante(ptb_InRec_Cur)==0)
    Kb_AnInv = 1;
  else
    Kb_AnInv = 0;

  // Calcul du ratio  //[026]
  d_coeff = d_CalculerRatio(ptb_InRec_Cur);
  //printf("ratio = %f\n", d_coeff);


  /* Conversion du montant pour le calcul */
  d_montant = atof(ptb_InRec_Cur[PRE_ESTMNT_M]);

  /* Numero de poste */
  n_poste = atoi(ptb_InRec_Cur[PRE_ACMTRS_NT]);
  m_poste = atoi(ptb_InRec_Cur[PRE_NBCOL + 2]); //[024]

  /* Extraction du chiffre des unites du poste */
  n_UnitePoste = m_poste % 10;


  //SPOT 14307 25 02 2008

  /* Si type comptable = 1 ou si type comptable 3 ou 5 et poste prime et que le contrat n'a pas ete renouvelé pour l'exercice egale a l'annee d'inventaire, */
  /* l'indicateur est mis a 0 pour interdire tout traitement de modification  SPOT 14307 */
  // initialisation de la structure retour
  //*************initsubtrs.old  init_SubTrsLigne();

  result = n_FindTsubTRS(&SubTrsLigne, ptb_InRec_Cur[PRE_DETTRNCOD_CF]); //[023]

  /* si c'est un poste analytique avec un inputtype=ration, alors on ne trimestrialise pas */
  if ( (SubTrsLigne.TRSINPUTTYPE_CT == 3) && (SubTrsLigne.TRSNATURE_CT == 2)) // [023]
  {
    n_WriteCols(Kp_PrevFil, ptb_InRec_Cur, '~', 0);                  //
    RETURN_VAL(0);
  }

  if ( Kb_AnInv == 1 )
  {

    if ((ptb_InRec_Cur[PRE_RENOUV_B][0]) == '0')
    { pre_accadmtyp_ct = atoi(ptb_InRec_Cur[PRE_ACCADMTYP_CT]);
      if (((pre_accadmtyp_ct == 1) || (pre_accadmtyp_ct == 3) || (pre_accadmtyp_ct == 5)) && ((ptb_InRec_Cur[PRE_ACMTRS_NT][1]) == '0'))    //n_UnitePoste == 0 )
      {
        Kb_AnInv = 0;
        n_WriteCols(Kp_PrevFil, ptb_InRec_Cur, '~', 0);
        RETURN_VAL(0);
      }
    }
  }

  /* Si type comptable = 2 ou 4 ou si type comptable 3 ou 5 et poste sinistre et que le contrat soit renouvelé ou non ac egale a l'annee d'inventaire, */
  /* l'indicateur est mis a 1 pour declencher le traitement de modification  SPOT 14307 */
  if ( Kb_AnInv == 1 )
  {
    if ((ptb_InRec_Cur[PRE_RENOUV_B][0]) == '0')
    {
      pre_accadmtyp_ct = atoi(ptb_InRec_Cur[PRE_ACCADMTYP_CT]);
      if (((pre_accadmtyp_ct == 2) || (pre_accadmtyp_ct == 4) || (pre_accadmtyp_ct == 3) || (pre_accadmtyp_ct == 5)) && ((ptb_InRec_Cur[PRE_ACMTRS_NT][1]) == '2'))    //n_UnitePoste == 0 )
        Kb_AnInv = 1;
    }
  }

  // Fin SPOT 14307 25 02 2008


  // Traitement de modification effectue uniquement pour l'annee d'inventaire 
  if ( Kb_AnInv == 1 )
  {
    //[029] suppression exception 2145
    
    /* Le calcul est fonction de ce chiffre */
    switch (n_UnitePoste)
    {
    case 0:             /* cas de suffixe '0' ('Primes+RPCC', 'Echeances', ...) */
      Kb_rollback = 0;
      d_montant *= d_coeff;  //[026]
      EcrirePrevision (d_montant, ptb_InRec_Cur);
      break;


    case 1:             /* cas des entree; memorisation de l'estimation */ //2
      Kb_rollback = 0;
      Kd_EP = d_montant;
      EcrirePrevision (d_montant, ptb_InRec_Cur);
      break;

    case 2:             /* cas des retraits de portfeuille */ //1
      Kb_rollback = 0;
      Kd_RP = (-Kd_EP) + ((Kd_EP + d_montant) * d_coeff);  //[026]
      EcrirePrevision (Kd_RP, ptb_InRec_Cur);
      Kd_EP = 0;
      break;


    case 3:             /* annulation écriture des constitutions par défaut */

      if (Kb_rollback == 1)
      {

        Kb_rollback = 0;

        if (n_poste == Kn_postegen)
        {
          if ( KnEffacer == 0 )
          {
          	fsetpos(Kp_PrevFil, &K_pos);
          }
        }
        else
        {
          Kd_Lib = 0;
        }
      }
      else
      {
        Kd_Lib = 0;
      }

      /* cas des constitutions de provisions */


      Kd_Cst = (Kd_Lib + d_montant) * d_coeff - Kd_Lib;  //[17]  //[026]
      Kd_Lib = 0;

      if ( (strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1073") == 0) || (strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "2073") == 0) )
      {
        if ( ptb_InRec_Cur[PRE_ACMTRS_NT][0] == '1')
          ptb_InRec_Cur[PRE_ACCRET_B] = "0";
        else
          ptb_InRec_Cur[PRE_ACCRET_B] = "1";

        ptb_InRec_Cur[PRE_RETCOD_CT] = L_PostInfo_ACMTRS[n_RechercheTACCPAR(ptb_InRec_Cur[PRE_ACMTRS_NT])].sz_RETCOD;
        ptb_InRec_Cur[PRE_SPIMOD_CT] = L_PostInfo_ACMTRS[n_RechercheTACCPAR(ptb_InRec_Cur[PRE_ACMTRS_NT])].sz_SPIMOD;
        ptb_InRec_Cur[PRE_ADJCOD_CT] = L_PostInfo_ACMTRS[n_RechercheTACCPAR(ptb_InRec_Cur[PRE_ACMTRS_NT])].sz_ADJCOD;
      }
      if ( KnEffacer == 0 )
      {
        EcrirePrevision (Kd_Cst, ptb_InRec_Cur);
      }
      KnEffacer=0;
      break;

    case 4:         /* cas des liberations: memorisation */   //[17] //4
      Kd_Lib = d_montant;
      EcrirePrevision (d_montant, ptb_InRec_Cur);


      /* stockage adresse au cas où il existe une constitution */
      fgetpos(Kp_PrevFil, &K_pos);
      Kb_rollback = 1;

      Kd_Cst = Kd_Lib * d_coeff - Kd_Lib;  //[026]

      //if (n_FindTsubTRSAssoCons(1, 1, ptb_InRec_Cur[PRE_DETTRNCOD_CF]) != -1) {ret = n_ReturnDett(1, 1, ptb_InRec_Cur[PRE_DETTRNCOD_CF]);}
      if (n_poste % 10 == 4)
        sprintf(sz_poste, "%d", n_poste - 1); //[024]
      else
        sprintf(sz_poste, "%d", n_poste);

      ptb_InRec_Cur[PRE_ACMTRS_NT] = sz_poste;

      Kn_postegen = atoi(ptb_InRec_Cur[PRE_ACMTRS_NT]);

      if (ptb_InRec_Cur[PRE_ACMTRS_NT][0] == '1')
        ptb_InRec_Cur[PRE_ACCRET_B] = "0";
      else
        ptb_InRec_Cur[PRE_ACCRET_B] = "1";

      ptb_InRec_Cur[PRE_RETCOD_CT] = L_PostInfo_ACMTRS[n_RechercheTACCPAR(ptb_InRec_Cur[PRE_ACMTRS_NT])].sz_RETCOD;
      // ptb_InRec_Cur[PRE_SPIMOD_CT]=0;
      // ptb_InRec_Cur[PRE_SPIMOD_CT]=L_PostInfo_ACMTRS[n_RechercheTACCPAR(ptb_InRec_Cur[PRE_ACMTRS_NT])].sz_SPIMOD; //[023]
      ptb_InRec_Cur[PRE_ADJCOD_CT] = L_PostInfo_ACMTRS[n_RechercheTACCPAR(ptb_InRec_Cur[PRE_ACMTRS_NT])].sz_ADJCOD;

      /*[021]*/

      if ( n_poste == 1144)
      {
        ptb_InRec_Cur[PRE_RETCOD_CT] = L_PostInfo_ACMTRS[n_RechercheTACCPAR("1064")].sz_RETCOD;
        ptb_InRec_Cur[PRE_SPIMOD_CT] = L_PostInfo_ACMTRS[n_RechercheTACCPAR("1064")].sz_SPIMOD;
        ptb_InRec_Cur[PRE_ADJCOD_CT] = L_PostInfo_ACMTRS[n_RechercheTACCPAR("1064")].sz_ADJCOD;

      }
      if ( n_poste == 1014)
      {
        ptb_InRec_Cur[PRE_RETCOD_CT] = L_PostInfo_ACMTRS[n_RechercheTACCPAR("1064")].sz_RETCOD;
        ptb_InRec_Cur[PRE_SPIMOD_CT] = L_PostInfo_ACMTRS[n_RechercheTACCPAR("1064")].sz_SPIMOD;
        ptb_InRec_Cur[PRE_ADJCOD_CT] = L_PostInfo_ACMTRS[n_RechercheTACCPAR("1064")].sz_ADJCOD;

      }
      /*[021]*/
      dettrncod = n_FindTsubTRSAssoCons(1, 1, ptb_InRec_Cur[PRE_DETTRNCOD_CF]);
      if (dettrncod != -1)

      {
        sprintf(ZDETTRNCOD, "%d", dettrncod);
        ZDETTRNCOD[5] = 0;
        sprintf(ptb_InRec_Cur[PRE_DETTRNCOD_CF], "%s", ZDETTRNCOD);
      }
      if ( (strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1303") == 0 || strcmp(ptb_InRec_Cur[PRE_ACMTRS_NT], "1323") == 0) && (atoi(ptb_InRec_Cur[PRE_UWY_NF]) == atoi(ptb_InRec_Cur[PRE_ACY_NF])-1 ) )
			{
				ptb_InRec_Cur[PRE_UWY_NF]=ptb_InRec_Cur[PRE_ACY_NF];
				KnEffacer=1;
			}
      EcrirePrevision (Kd_Cst, ptb_InRec_Cur);
      break;

    }
  }


      
  /* Pour les annees anterieures à l'annee d'inventaire, reconduction des previsions */
  //if ( atoi(ptb_InRec_Cur[PRE_ACY_NF] ) < Kn_annee )
  // [026]
  if(n_AcyCourante(ptb_InRec_Cur)==-1)
  {
    n_WriteCols(Kp_PrevFil, ptb_InRec_Cur, '~', 0);
	}
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

  RETURN_VAL (0);
}


/*==============================================================================
objet : Fonction lancee a chaque rupture derniere de niveau 1
==============================================================================*/
int n_ActionLastRupt1Prev (char **ptb_InRec_Cur)
{
  
  //[019]
 
     

  DEBUT_FCT("n_ActionLastRupt1Prev");

  RETURN_VAL(0);
}


/*==============================================================================
objet : Fonction d'ecriture dans le champs  psz_ligne
==============================================================================*/
void EcrirePrevision(double d, char **psz_ligne)
{
  char sz_montant[30];
  char sz_balshtyea[5] ;  /* zone de travail */
  char sz_balshtmth[3] ;  /* zone de travail */

  /* Conversion de l'annee et mois bilan en chaine - modifs du 27/03/98 */
  sprintf( sz_balshtyea, "%d", Kn_annee ) ;
  sprintf( sz_balshtmth, "%d", Kn_mois ) ;

  /* Conversion du montant en chaine */
  sprintf(sz_montant, "%lf", d);

  //printf("ecriture prevision d'un montant=%s\n", sz_montant);

  /* Affectation a la structure de prevision */
  /*   strcpy(psz_ligne[PRE_ESTMNT_M],sz_montant);*/
  psz_ligne[PRE_ESTMNT_M] = sz_montant;

  /* Affectation a la structure de l'annee et mois bilan */
  psz_ligne[PRE_BALSHEY_NF] = sz_balshtyea ;
  psz_ligne[PRE_BALSHTMTH_NF] = sz_balshtmth ;

  /* Ecriture */
  n_WriteCols(Kp_PrevFil, psz_ligne, '~', 0);

}

//[17]

/*==============================================================================
objet :     Initialisation du fichier
retour:     OK
==============================================================================*/
int n_InitTACCPAR(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitTACCPAR");

  memset( pbd_Rupt, 0, sizeof(T_RUPTURE_VAR) ) ;

  n_OpenFileAppl ("ESTC2136_I2", "rt", &(pbd_Rupt->pf_InputFil));

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
  DEBUT_FCT("n_ActionLigneTACCPAR");

  strcpy( L_PostInfo_ACMTRS[K].sz_RETCOD, ptb_InRecTACCPAR[ACC_RETCOD_CT]);
  strcpy( L_PostInfo_ACMTRS[K].sz_SPIMOD, ptb_InRecTACCPAR[ ACC_SPIMOD_CT]);
  strcpy( L_PostInfo_ACMTRS[K].sz_ADJCOD, ptb_InRecTACCPAR[ACC_ADJCOD_CT]);
  strcpy( L_PostInfo_ACMTRS[K].ACmtrs, ptb_InRecTACCPAR[ACC_ACMTRS_NT]);
  K++;

  RETURN_VAL(OK);
}


/*=============================================================================
objet : Recherche le DETTRS du poste de regroupement
=============================================================================*/
int n_RechercheTACCPAR(char* ACMTRS )
{
  int i = 0;
  for (i = 0; i < K; i++)
  {
    if (strcmp(ACMTRS, L_PostInfo_ACMTRS[i].ACmtrs) == 0)
      return  i;

  }
  return -1;
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


/*==============================================================================
objet :     Initialisation de la structure de rupture du Detail
retour:     OK
==============================================================================*/
int n_InitRuptPerim(T_RUPTURE_VAR *pbd_RuptPerim)  //[026]
{
  DEBUT_FCT("n_InitRuptDetail");

  memset(pbd_RuptPerim, 0, sizeof(T_RUPTURE_VAR));

  // Ouverture du fichier Detail
  if (n_OpenFileAppl("ESTC2136_I5", "rt", &(pbd_RuptPerim->pf_InputFil)) == ERR)
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
int n_ActionLignePerim(char **ptb_InRec_Cur)  //[026]
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
        n_AddYears(L_DATES[Kn_Dates].sz_EXPIRATION_D, 1, '+', L_DATES[Kn_Dates].sz_EXPIRATION_D); // [028]
        n_AddDays( L_DATES[Kn_Dates].sz_EXPIRATION_D, 1, '-', L_DATES[Kn_Dates].sz_EXPIRATION_D); // [028]
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
int n_RechercheDates(char **ptb_InRec_Cur)  //[026]
{
  //int i=Kn_Cpt_Dates;
  int i=Kn_Cpt_Dates_ctrsec;

  for (; i < Kn_Dates; i++)
  {
    if(strcmp(sz_ref_CTR, L_DATES[i].sz_CTR_NF) || strcmp(sz_ref_SEC, L_DATES[i].sz_SEC_NF))
    {
      sprintf(sz_ref_CTR,"%s",L_DATES[i].sz_CTR_NF);
      sprintf(sz_ref_SEC,"%s",L_DATES[i].sz_SEC_NF);
      Kn_Cpt_Dates_ctrsec=i;
    }

    //if (strcmp(L_DATES[Kn_Dates].sz_CTR_NF, "") == 0)
      //return -1;

    if (strcmp(L_DATES[i].sz_CTR_NF, ptb_InRec_Cur[PRE_CTR_NF]) == 0 &&
        strcmp(L_DATES[i].sz_SEC_NF, ptb_InRec_Cur[PRE_SEC_NF]) == 0 &&
        strcmp(L_DATES[i].sz_UWY_NF, ptb_InRec_Cur[PRE_UWY_NF]) == 0)
    {
      Kn_Cpt_Dates = i;
      //printf("trouve\n");
      return i;
    }

    if (strcmp(L_DATES[i].sz_CTR_NF, ptb_InRec_Cur[PRE_CTR_NF]) > 0 ||
         (strcmp(L_DATES[i].sz_CTR_NF, ptb_InRec_Cur[PRE_CTR_NF]) == 0 &&
          strcmp(L_DATES[i].sz_SEC_NF, ptb_InRec_Cur[PRE_SEC_NF]) > 0) ||
         (strcmp(L_DATES[i].sz_CTR_NF, ptb_InRec_Cur[PRE_CTR_NF]) == 0 &&
          strcmp(L_DATES[i].sz_SEC_NF, ptb_InRec_Cur[PRE_SEC_NF]) == 0 &&
          strcmp(L_DATES[i].sz_UWY_NF, ptb_InRec_Cur[PRE_UWY_NF]) > 0 ))
    {
      //printf("pas trouve 1\n");
      return -1;
    }
  }
  //printf("pas trouve 2\n");
  return -1; // si non trouve
}

/*==========================================================================
  Objet :     Calcul du ratio
  Parametres: Pointeur sur ligne prevision
  Retour:     ratio
===========================================================================*/
double d_CalculerRatio(char **ptb_InRec_Cur)  //[026]
{
  int n_Dates;
  int n_annee_eff, n_mois_eff, n_annee_exp, n_mois_exp, n_jour_exp, n_acy, n_diff_dates;
  int n_tot_b, n_tot_eff, n_tot_exp;

  double d_ratio_default = Kn_mois / 12.0;

  n_acy = atoi(ptb_InRec_Cur[PRE_ACY_NF]);

  // Calcul du ratio
  // si mode = PA => ratio = 1
  // si mode = PC
  //   si annee/mois >= expiration => ratio = 1
  //   si annee/mois < effet => ratio = 0
  //   sinon ratio = (min(annee/mois,echeance) - (effet-1)) / (echeance - (effet-1))

  /*printf("\nCalcul ratio : %s %s %s %s %s %s %s %s\n",
         ptb_InRec_Cur[PRE_CTR_NF], ptb_InRec_Cur[PRE_SEC_NF],
         ptb_InRec_Cur[PRE_UWY_NF], ptb_InRec_Cur[PRE_ACY_NF],
         ptb_InRec_Cur[PRE_ACMTRS_NT], ptb_InRec_Cur[PRE_DETTRNCOD_CF],
         ptb_InRec_Cur[PRE_GAAP_NF], ptb_InRec_Cur[PRE_ESTMNT_M]);*/

  if (Kn_mode == PA)
    return 1.0;

  if (Kn_mode == PC)
  {
    n_Dates = n_RechercheDates(ptb_InRec_Cur);
    //printf("Valeur de retour '%d'\n", n_Dates);
    if (n_Dates == -1 ||
      strcmp(L_DATES[n_Dates].sz_EFFET_D,"") == 0 ||
      strcmp(L_DATES[n_Dates].sz_EXPIRATION_D,"") == 0) // dates non trouvees
    {
      if(atoi(ptb_InRec_Cur[PRE_ACY_NF]) < Kn_annee)
        return 1.0;
      if(atoi(ptb_InRec_Cur[PRE_ACY_NF]) > Kn_annee)
        return 0.0;
      return d_ratio_default;
    }
    
    //printf("Dates trouvees : %s => %s\n", L_DATES[n_Dates].sz_EFFET_D, L_DATES[n_Dates].sz_EXPIRATION_D);
    
    sscanf(L_DATES[n_Dates].sz_EFFET_D,      "%4d%2d", &n_annee_eff, &n_mois_eff);
    sscanf(L_DATES[n_Dates].sz_EXPIRATION_D, "%4d%2d%2d", &n_annee_exp, &n_mois_exp, &n_jour_exp);

    // application R03 EST27 : Date d’expiration = mois d’expiration -1 sauf si la date d’expiration est le dernier jour de mois
    if(n_jour_exp!=n_nbJoursDansMois(n_annee_exp, n_mois_exp))
    {
      if(n_mois_exp==1)
      {
        n_annee_exp--;
        n_mois_exp=12;
      } else {
        n_mois_exp--;
      }
    }

    //printf("%i/%i => %i/%i/%i\n", n_mois_eff, n_annee_eff, n_jour_exp, n_mois_exp, n_annee_exp);

    // glissement des dates (sur ACY)
    n_diff_dates = n_acy - n_annee_eff;
    if(n_acy > n_annee_eff)
    {
      //n_annee_eff += n_diff_dates;
      //n_annee_exp += n_diff_dates;
      n_annee_eff = n_acy;
      if(n_mois_exp == 12)
      {
        n_mois_eff = 1;
        n_annee_exp = n_annee_eff;
      }
      else if(n_mois_exp == 1)
      {
        n_mois_eff = 2;
        n_annee_exp = n_annee_eff + 1;
      }
      else
      {
        n_mois_eff = n_mois_exp + 1;
        n_annee_exp = n_annee_eff + 1;
      }
      
      //printf("Glissement des dates : %i/%i => %i/%i\n", 
      //  n_mois_eff, n_annee_eff, n_mois_exp, n_annee_exp);
    }

    n_tot_b   = 12 * Kn_annee + Kn_mois;
    n_tot_eff = 12 * n_annee_eff + n_mois_eff;
    n_tot_exp = 12 * n_annee_exp + n_mois_exp;

    //printf("Dates calculees : bilan=%i effet=%i exp=%i\n", n_tot_b, n_tot_eff, n_tot_exp);
   
    if (n_tot_b >= n_tot_exp)
      return 1.0;

    if (n_tot_b < n_tot_eff)
      return 0.0;

    /*printf("Super calcul : (min(%i,%i) - (%i - 1)) / (%i - (%i - 1)) = %f\n",
      n_tot_b, n_tot_exp, n_tot_eff, n_tot_exp, n_tot_eff, 1.0 * ((n_tot_b < n_tot_exp ? n_tot_b : n_tot_exp) - (n_tot_eff - 1)) / (n_tot_exp - (n_tot_eff - 1)));*/
    return 1.0 * ((n_tot_b < n_tot_exp ? n_tot_b : n_tot_exp) - (n_tot_eff - 1)) / (n_tot_exp - (n_tot_eff - 1));
  }

  return d_ratio_default;
}

/*==========================================================================
  Objet :     Acy Courante
  Parametres: Pointeur sur ligne prevision
  Retour:     0 si la prevision est courante
              -1 si la prevision est passee
              +1 si la prevision est future
===========================================================================*/
int n_AcyCourante(char **ptb_InRec_Cur)  //[026]
{
  int n_Dates;
  int n_annee_eff, n_mois_eff, n_annee_exp, n_mois_exp, n_jour_exp, n_acy, n_diff_dates;
  int n_tot_b, n_tot_eff, n_tot_exp;

  n_acy = atoi(ptb_InRec_Cur[PRE_ACY_NF]);

  n_Dates = n_RechercheDates(ptb_InRec_Cur);
  if (n_Dates == -1 ||
    strcmp(L_DATES[n_Dates].sz_EFFET_D,"") == 0 ||
    strcmp(L_DATES[n_Dates].sz_EXPIRATION_D,"") == 0) // dates non trouvees
  {
    if(atoi(ptb_InRec_Cur[PRE_ACY_NF]) < Kn_annee)
      return -1;
    if(atoi(ptb_InRec_Cur[PRE_ACY_NF]) > Kn_annee)
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
  if(n_acy > n_annee_eff)
  {
    //n_annee_eff += n_diff_dates;
    //n_annee_exp += n_diff_dates;
    n_annee_eff = n_acy;
    if(n_mois_exp == 12)
    {
      n_mois_eff = 1;
      n_annee_exp = n_annee_eff;
    }
    else if(n_mois_exp == 1)
    {
      n_mois_eff = 2;
      n_annee_exp = n_annee_eff + 1;
    }
    else
    {
      n_mois_eff = n_mois_exp + 1;
      n_annee_exp = n_annee_eff + 1;
    }
    
    /*printf("Glissement des dates : %i/%i => %i/%i\n", 
      n_mois_eff, n_annee_eff, n_mois_exp, n_annee_exp);*/
  }

  n_tot_b   = 12 * Kn_annee + Kn_mois;
  n_tot_eff = 12 * n_annee_eff + n_mois_eff;
  n_tot_exp = 12 * n_annee_exp + n_mois_exp;

  /*printf("Dates calculees : bilan=%i effet=%i exp=%i => %s\n",
    n_tot_b, n_tot_eff, n_tot_exp, ((n_tot_b > n_tot_exp) || (n_tot_b < n_tot_eff))?"Hors plage":"Courante");*/
 
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