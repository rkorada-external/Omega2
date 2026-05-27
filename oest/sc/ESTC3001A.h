/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC3001.c
 Revision                      : $Revision: 1.4 $
 Date de creation              : 09/01/2012
 Auteur                        : gensource v2.0 (auto)
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
     Historique des modifications :
[01]  01/06/2012  -=Dch=-  :spot:23937 SOLVENCY II
[02]  10/12/2012  Florent  :spot:24041 SOLVENCY II
[03]  14/10/2014  Florent  :spot:27789 ajout de define pour le nombre de ligne du tableau et redimensionnement de la définition  de la structure du pattern à l’identique de TPATTERNSII
[04]  28/04/2015 Florent   :spot:26391 gestion de l'année bilan pour la clef de la recherche des doublons
[05]  12/05/2016 Florent   :spot:30543 on passe à 65 années et ce fichier devient la références pour les PAATERNSII !
[06] 03/09/2018 Charles Socie : EXT-IFRS17-903121  REQ 10.02 Cash flow: more detailed granularity ( split between variable and fixed premiums)
==============================================================================*/
#ifndef __ESTC3001
#define __ESTC3001

#ifndef __STRUCT
static const char SEPARATEUR = '~';
#endif

#define SEPARATEUR_SPLIT "~"

#define LONGBUF 3000

//utilisé en assignation de pointeur, ne pouvait être du const et on evite le warning avec le define pour variable non utilisée
#define PER_CF_NEW "NEW"
#define PER_CF_DUPLI "DUPLI"
#define PATTYP_INFLATIONCALC "INFI"
#define PATTYP_INFLATION "INF"
#define PATTYP_DISCILLIQ "DSI"
#define PATTYP_BDT_RAT "RAT"
#define PATCAT_BAD_DEBT "BDT"
#define RECHERCHE_DISCOUNT_ILLIQUIDITY "~DSC~ILL~"
#define RECHERCHE_DISCOUNT_LKI "~DSC~LKI~"
#define RECHERCHE_DISCOUNT_DISCOUNT "~DSC~DSC~"

#define PATCAT_INFLATION "INF"
#define PATCAT_CUMULATIVE_INCURRED "CUM,ICV"
#define PATCAT_CUMULATIVE "CUM"
#define PATCAT_INCURRED "ICV"
#define PATCAT_DISCOUNT "DSC"
#define PATCAT_INCREMENTAL "ICR"
#define PATCAT_CASHFLOW "CSF"
#define PATTYP_DISCOUNT "DSC"
#define PATTYP_ILLIQUIDITY "ILL"

enum { PATTERNSII_ANNEES = 65 };
//11 chiffres dont 8 décimales et signe et séparateur décimal et séparateur ~
enum { TAILLE_PATTERNSII_TAUX = ((1 + 11 + 1 + 1) * PATTERNSII_ANNEES) + 1};  // "<3 entiers>.<8 décimales>~" x PATTERNSII_ANNEES taux + '\0'
//SSD_CF[3]/PATCAT_CT[6]/PATTYP_CT[6]/SEG_NF[11]/CUR_CF[4]/LOB_CF[3]/RATING_CF[6]/NORME_CF[6]/SEGNAT_CT[2]/BALSHEY_NF[5]/courbe_taux[TAILLE_COURBE_TAUX]
enum { TAILLE_CLE_PATTERNSII = 3 + 6 + 6 + 11 + 4 + 3 + 6 + 6 + 2 + 5 + TAILLE_PATTERNSII_TAUX };

enum ENUM_FPATTERNSII {
  PAT_SSD_CF = 0
  , PAT_PATCAT_CT
  , PAT_PATTYP_CT
  , PAT_SEG_NF
  , PAT_UWY_NF
  , PAT_CUR_CF
  , PAT_LOB_CF
  , PAT_RATING_CF
  , PAT_NORME_CF
  , PAT_SEGNAT_CT
  , PAT_BALSHEY_NF
  , PAT_PATTERN_ID
  , PAT_CRE_D
  , PAT_CREUSR_CF
  , PAT_TOTAUX
  , PAT_AN1
  , PAT_AN_FIN = PAT_AN1 + PATTERNSII_ANNEES - 1
  , PAT_RATEINDEX
  , PAT_NBCOL
};

enum ENUM_FRATINGSII
{
  RATSII_RATING_CF = 0
  , RATSII_NORME_CF
  , RATSII_CRE_D
  , RATSII_DEFPROB_R
  , RATSII_RECOVRAT_R
  , RATSII_NBCOL
};

enum ENUM_FLOBSII
{
  LOBSII_LOB_CF = 0
  , LOBSII_SEGNAT_CT
  , LOBSII_NORME_CF
  , LOBSII_COEF_R
  , LOBSII_CRE_D
  , LOBSII_NBCOL
};

typedef struct {
  char   SSD_CF[3];
  char   PATCAT_CT[6];
  char   PATTYP_CT[6];
  char   SEG_NF[17];
  short  UWY_NF;
  char   CUR_CF[4];
  char   LOB_CF[3];
  char   RATING_CF[6];
  char   NORME_CF[6];
  char   SEGNAT_CT[2];
  short  BALSHEY_NF;
  char   PATTERN_ID[22];
  char   CRE_D[22];
  char   CREUSR_CF[5];
  char   RATEINDEX[33];
  double TOTAUX;
  double AN[PATTERNSII_ANNEES];
} T_FPATTERNSII;

typedef struct {
  char cle[TAILLE_CLE_PATTERNSII];
} T_FPATTERNSII_CLE;

typedef struct {
  T_FPATTERNSII db_pat;
  char          jointure[100];
} T_FPATTERNSII_JOIN;

typedef struct {
  char   LOB_CF[3];
  char   SEGNAT_CT[2];
  char   NORME_CF[6];
  double COEF_R;
  char   CRE_D[22];
} T_FLOBSII;

enum COL_CUMUL {
  CML_SSD_CF = 0,
  CML_ESB_CF,
  CML_BALSHEY_NF,
  CML_BALSHRMTH_NF,
  CML_BALSHRDAY_NF,
  CML_TRNCOD_CF,
  CML_DBLTRNCOD_CF,
  CML_CTR_NF,
  CML_END_NT,
  CML_SEC_NF,
  CML_UWY_NF,
  CML_UW_NT,
  CML_OCCYEA_NF,
  CML_ACY_NF,
  CML_SCOSTRMTH_NF,
  CML_SCOENDMTH_NF,
  CML_CLM_NF,
  CML_CUR_CF,
  CML_AMT_MC,
  CML_CED_NF,
  CML_BRK_NF,
  CML_PAY_NF,
  CML_KEY_NF,
  CML_RETCTR_NF,
  CML_RETEND_NT,
  CML_RETSEC_NF,
  CML_RTY_NF,
  CML_RETUW_NT,
  CML_RETOCCYEA_NF,
  CML_RETACY_NF,
  CML_RETSCOSTRMTH_NF,
  CML_RETSCOENDMTH_NF,
  CML_RCL_NF,
  CML_RETCUR_CF,
  CML_RETAMT_MC,
  CML_PLC_NT,
  CML_RTO_NF,
  CML_INT_NF,
  CML_RETPAY_NF,
  CML_RETKEY_CF,
  CML_RETINTAMT_MC,
  CML_ACMTRS_NT,
  CML_ACMAMT_MC,
  CML_ACMCUR_CF,
  CML_PRS_CF,
  CML_SEG_NF,
  CML_LOB_CF,
  CML_NAT_CF,
  CML_TYP_CT,
  CML_NORME_CF,
  CML_PATTYP_1056 = CML_NORME_CF,
  CML_RATING_CF,
  CML_JOINTURE_1056 = CML_RATING_CF,
  CML_PATCAT_CT,
  CML_PATTYP_CT,
  CML_PATTERN_ID,
  CML_AN1,
  CML_AM01_MC = CML_AN1,
  CML_AM_FIN = CML_AM01_MC +  PATTERNSII_ANNEES - 1,
  CML_COEF_LOB,
  CML_DSCCUR_CF,
  CML_COMMENT,
  CML_TOTAUX_MC,
  CML_SEGMENT_SII,
  CML_SEGMENT_LE,
  CML_AMT_EURO,
  CML_RATIO = CML_AMT_EURO,
  CML_ACMTRS3_NT = CML_PATCAT_CT, //[IFRS17REQ10.2]
  CML_ACMTRS3_NT2 = CML_SEGMENT_SII, //[IFRS17REQ10.2]
  CML_QUARTER_FC 
};

enum SEG_LE_SII {
  SEGSII_CTR_NF = 0,
  SEGSII_END_NT,
  SEGSII_SEC_NF,
  SEGSII_UWY_NF,
  SEGSII_UW_NT,
  SEGSII_VRS_NF,
  SEGSII_SSD_CF,
  SEGSII_LE_NF,
  SEGSII_SII_NF,
  SEGSII_CLODAT_D,
  SEGSII_PER_CF,
  SEGSII_CRE_D
};

enum COL_RISK_MARGIN {
  RSKM_LGENSGTVRS_NT = 0,
  RSKM_LE_SEGMENT_NF,
  RSKM_LOBSIISGMTVRS_NT,
  RSKM_SII_SEGMENT_NF,
  RSKM_NORME_CF,
  RSKM_PER_CF,
  RSKM_CLOSING_D,
  RSKM_AMT_M,
  RSKM_CUR_CF,
  RSKM_CREUSR_CF,
  RSKM_CRE_D
};

enum COL_RATIO {
  RTO_SSD_CF = 0,
  RTO_ESB_CF ,
  RTO_PER_CF ,
  RTO_CLOSING_D,
  RTO_RATIO_NF,
  RTO_CREUSR_CF,
  RTO_CRE_D
};

//[003] Ajout des 2 types ICACC et ICRET
enum C_TYPE
{
  PRACC = 0
  , PRRET
  , CLACC
  , CLRET
  , ICACC
  , ICRET
};

typedef struct {
  T_FPATTERNSII db_pat;
  char          joint_seg[100];
  char          joint_lob[100];
  size_t used ;
} T_FPATTERNSII_JOIN2;

typedef struct {
  char  curr[4];
  char  ref[4];
} T_DEVISE;

typedef struct {
  char  		 ctr_nf[10];
  int 			 end_nt;
  int  			 sec_nf;
  short 		 uwy_nf;
  int  uw_nt;
  char  		 sgmt_ls[5];
} T_ILLIQUIDITY;

typedef struct {
	int prs_cf;
	int acmtrs_nt;
	char parm1[3];
	int  parm2;
	int  parm3;
	int  parm4;
	char parm5[2];
	char parm6[2];
	char parm7[2];
	char parm8[2];
	int  parm9;
	char parm10[2];
} T_TPRSMAP;

enum ENUM_TPRSMAP
{
  TPRSMAP_PRS_CF = 0
  , TPRSMAP_ACMTRS_NT
  , TPRSMAP_PARM1
  , TPRSMAP_PARM2
  , TPRSMAP_PARM3
  , TPRSMAP_PARM4
  , TPRSMAP_PARM5
  , TPRSMAP_PARM6
  , TPRSMAP_PARM7
  , TPRSMAP_PARM8
  , TPRSMAP_PARM9
  , TPRSMAP_PARM10
};

typedef struct {
	char 		    RI_CTR_NF[10];
	unsigned char	RI_END_NT;
    unsigned char   RI_UW_NT;
	int				RI_SEC_NF;
	int 			RI_UWY_NF;
	char			RI_RATEINDEX_G[33];
	char			RI_RATEINDEX_P[33];
	char 			RI_RATEINDEX_L[33];
    char 			RI_RATEINDEX_S[33];
} T_RI_DATA;

typedef struct {
	T_RI_DATA      *t_DATA;
	unsigned int 			count;
} T_RI_UWY;

typedef struct {
	T_RI_UWY 		t_UWY[500];
} T_RI_SSD;


typedef struct {
	T_RI_SSD 		t_SSD[100];
} T_RATEINDEX;


enum {
    RI_CTR_NF = 0   //0
  , RI_END_NT      //1
  , RI_SEC_NF    //2
  , RI_UWY_NF   //3
  , RI_UW_NT    //4
  , RI_RATEINDEX_G    //5
  , RI_RATEINDEX_P   //6
  , RI_RATEINDEX_L    //7
  , RI_RATEINDEX_S    //8
  , RI_TYPE
  , RI_SSD_CF
  , RI_ESB_CF
};

typedef struct {
  char 		    CTR_NF[10];
  unsigned char	END_NT;
  short  		UWY_NF;
  unsigned char UW_NT;
  int			SEC_NF;
  char   		CTRINC_D[22];
  char			RETCTRCAT_CF[3];
} T_PERICASE;

typedef struct {
  char   SSD_CF[3];
  char   ESB_CF[3];
  char   PATCAT_CT[6];
  char   PATTYP_CT[6];
  char   SEG_NF[17];
  short  UWY_NF;
  char   CUR_CF[4];
  char   LOB_CF[3];
  char   RATING_CF[6];
  char   NORME_CF[6];
  char   SEGNAT_CT[2];
  short  BALSHEY_NF;
  char   PATTERN_ID[22];
  char   CRE_D[22];
  char   CREUSR_CF[5];
  char   RATEINDEX[33];
  double TOTAUX;
  double AN[PATTERNSII_ANNEES];
} T_FPATTERNSII2;

typedef struct {
  T_FPATTERNSII2 db_pat;
  char          jointure[100];
  size_t used ;
} T_FPATTERNSII2_JOIN;

enum ENUM_FPATTERNSII2 {
  PAT2_SSD_CF = 0
  , PAT2_ESB_CF
  , PAT2_PATCAT_CT
  , PAT2_PATTYP_CT
  , PAT2_SEG_NF
  , PAT2_UWY_NF
  , PAT2_CUR_CF
  , PAT2_LOB_CF
  , PAT2_RATING_CF
  , PAT2_NORME_CF
  , PAT2_SEGNAT_CT
  , PAT2_BALSHEY_NF
  , PAT2_PATTERN_ID
  , PAT2_CRE_D
  , PAT2_CREUSR_CF
  , PAT2_TOTAUX
  , PAT2_AN1
  , PAT2_AN_FIN = PAT2_AN1 + PATTERNSII_ANNEES - 1
  , PAT2_RATEINDEX
  , PAT2_NBCOL
};

#endif /* __ESTC3001 */

