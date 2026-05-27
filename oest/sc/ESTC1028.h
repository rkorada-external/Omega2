// [01] -=Dch=-  13/01/2014 Linux Centralisation NB_PAR_MAX passe de 100 à 500 
// [02] Florent :spot:28140 ajout de la sinistralité
// [03] 08/02/2018 Roger   :spira:67327 Agrandissement des tableaux NB_FAM_MAX de 50 a 100 et NB_UWY_MAX de 30 a 50

#define NB_PAR_MAX    500 /* nombre de postes maxi du tableau des participations Ktbd_Par */
#define NB_FAM_MAX    100 /* nombre de postes maxi du tableau des familles de charges iterees par exercice */
#define NB_UWY_MAX     50 /* nombre d'exercice maxi par famille de charges iterees */
#define NB_COL_CTREST  21 /* nombre de colonnes de la tables des Estimations dommages */
#define NB_COL_GT      41 /* nombre de colonne du fichier GT */

#define UPR   1  
#define DAC   2  
#define COME  3  
#define PRME  4  
#define ITDP  5 
#define OTHER 6  
#define Kn_MaxLigFBOTRSLNK   30000 //[11] 

/* definition de la structure T_ESTGT */
typedef struct
{
  short         UWY_NF;
  unsigned char UW_NT;
  unsigned char SSD_CF;
  char          DIV_NT[4];
  char          EGPCUR_CF[4];
  unsigned char ACCESB_CF;
  int           CED_NF;
  int           PRD_NF;
  int           GENPRMPAY_NF;
  char          GANPAYORD_NT[3];
  double        PB_M;
  double        PAP_M;
  char          LOSADMMOD_CT;
  double        LOSENTAMT_M;
  double        LOSRETAMT_M;
  char          PBADMMOD_CT;
  double        PBENTAMT_M;
  double        PBRETAMT_M;
  char          PAPADMMOD_CT;
  double        PAPENTAMT_M;
  double        PAPRETAMT_M;
  char          DIFMTH_NF;
  char          SEGSA_B;
} T_ESTGT;
