/*historique des modifications :

[001]	MBO		21/03/2016	spot:?????:spira:45519/44675	:	correction, pour la date avant start_d c'est ">" et non pas ">="
[002]	MBO		22/03/2016	spot:30352:spira:44672			:	ajout des millisecondes dans END_D, START_D, CRE_D
[003]	MBO		20/06/2016	spot:     :spira:43333			:	ajout de la trimestrialisation
[004]	MBO		20/06/2016	spot:spot30691 Trimestrialisation
=============================================================================*/

#ifndef ESTC5000_H_
#define ESTC5000_H_

#define T_MAX_CSU 	   	50000
#define T_MAX_CUR 	   	500
#define NB_ESB_MAX     	250
#define T_MAX_LIST_IDS 	500
#define T_MAX_BASE 		50000

#define START			1
#define END				0

#define DETAIL_NBCOLS	21 //[003]
#define DETAIL_NBPERIOD	2

#define             T_MAX_CALL 10000
#define             T_MAX_MVT 5000

typedef struct {
	int     ID_CF;
	char    UPDTYP_CT;
	char    SSD_CF[3];
	char    ESB_CF[3];
	char    LSTUPDUSR_CF[9];
	char    END_D[22]; //[002]
} T_ID_CALL;


typedef struct {
	char ACMTRS_NT[5];
	char DETTRNCOD_CF[6];
} T_SUBTRSB;


typedef struct {
	int			n_ACY;
	int			n_DETTRNCOD;
	char		c_GAAP;
	char		sz_CUR[4];
	double		d_MNT;
	char		ACMTRS[5]; //[004]
} T_CSU_TEMP;


typedef struct {
	char		sz_CUR[4];
	double 		d_ratio;
} T_FAVERATE_RATIO;


typedef struct {
	short    	SSD;            /* Subsidiary code        */
	short    	ESB;      /* Ledger code            */
	char    	THRHLDCUR[4];   /* Subsidiary currency    */
} T_ESB;

typedef struct {
	int		ID_CF;
	short 	UPDTYP_CT;
	char	SSD_CF[3];
	char	ESB_CF[3];
	char	LSTUPDUSR_CF[9];
	char 	CTR_NF[8];
	int 	SEC_NF;
	char	UWY_NF[5];
	char	START_D[22]; //[002]
	char	END_D[22]; //[002]
} T_CALL;

typedef struct {
	int			ACY;
	char		CRE_D[22]; //[002]
	char		CUR[4];
	double		MNT;
	int			DETTRNCOD;
	char		GAAP;
	char		ACMTRS[5]; //[99]
} T_MVT;

// typedef struct {
//     char 		ID_CF[12];
//     char 		UPDTYP_CT;
//     char 		SSD_CF[3];
//     char 		ESB_CF[4];
//     char 		LSTUPDUSR_CF[5];
//     char 		GAAP_NT;
//     char 		PERIOD_NT;
//     char 		PREMLSTAMT_M[20];
//     char 		PREMAMT_M[20];
//     char 		DIFFPREMAMT_M[20];
//     char 		PLNPREMAMT_M[20];
//     char 		TECRESLSTAMT_M[20];
//     char 		TECRESAMT_M[20];
//     char 		DIFFTECRESAMT_M[20];
//     char 		PLNTECRESAMT_M[20];
//     char 		FINTECCOMLSTAMT_M[20];
//     char 		FINTECCOMAMT_M[20];
//     char 		DIFFFINTECCOMAMT_M[20];
//     char 		PLNFINTECCOMAMT_M[20];
//     char 		ACY_NF[5];
//     char 		CUR_CF[4];
//     char 		LSTUPDCUR_D[20];
//     char 		LSTUSRUPD_D[20];
//     char 		END_D[20];
// } T_GLOBAL_LINE;


enum {
	PLAN_CLODAT_D = 0,
	PLAN_SSD_CF,
	PLAN_CTR_NF,
	PLAN_END_NT,
	PLAN_SEC_NF,
	PLAN_UWY_NF,
	PLAN_UW_NT,
	PLAN_PLC_NT,
	PLAN_ACCRET_CF,
	PLAN_ACY_NF,
	PLAN_ACMTRS_NT,
	PLAN_DETTRNCOD_CF,
	PLAN_ESTMTH_NF,
	PLAN_CUR_CF,
	PLAN_CBNMNT_M,
	PLAN_CBPMNT_M,
	PLAN_PC1MNT_M,
	PLAN_PCMNT_M,
	PLAN_PC3MNT_M,
	PLAN_PC4MNT_M,
	PLAN_PC5MNT_M,
	PLAN_PA1MNT_M,
	PLAN_PAMNT_M,
	PLAN_PA3MNT_M,
	PLAN_PA4MNT_M,
	PLAN_PA5MNT_M,
	PLAN_PR1MNT_M,
	PLAN_PRMNT_M,
	PLAN_PR3MNT_M,
	PLAN_PR4MNT_M,
	PLAN_PR5MNT_M,
	PLAN_CED_NF,
	PLAN_SECSTS_CT,
	PLAN_SECACCSTS_CT,
	PLAN_ACCADMTYP_CT,
	PLAN_ESTCRB_CT,
	PLAN_ESTCTR_NF,
	PLAN_ESTSEC_NF,
	PLAN_COMACC_B,
	PLAN_AUTUPD_B,
	PLAN_YNEWCTR_B,
	PLAN_TNEWCTR_B,
	PLAN_CLMCUTOFF_B,
	PLAN_PRMCUTOFF_B,
	PLAN_CLMRUNOFF_B,
	PLAN_PRMRUNOFF_B,
	PLAN_LSTUPD_D,
	PLAN_CTRINC_D,
	PLAN_TRNCOD_CF,
	PLAN_ORICTR_NF,
	PLAN_ORISEC_NF,
	PLAN_ORIUWY_NF,
	PLAN_PAMNTNB_M,
	PLAN_PRMNTNB_M,
	PLAN_SSDRTO_B,
	PLAN_PROPAG_B,
	PLAN_UWYPLAN_NF,
	PLAN_VRSPLAN_NF,
	PLAN_PR1POST_M,
	PLAN_PR2POST_M,
	PLAN_PR3POST_M,
	PLAN_PR4POST_M,
	PLAN_PR5POST_M
};


enum CALL_STRUCT
{
	CALL_ID_CF = 0,
	CALL_UPDTYP_CT,
	CALL_SSD_CF,
	CALL_ESB_CF,
	CALL_LSTUPDUSR_CF,
	CALL_CTR_NF,
	CALL_SEC_NF,
	CALL_UWY_NF,
	CALL_FLAG_B,
	CALL_START_D,
	CALL_END_D
};


enum
{
	DETAIL_ID_CF = 0,
	DETAIL_SSD_CF,
	DETAIL_ESB_CF,
	DETAIL_LSTUPDUSR_CF,
	DETAIL_PERIOD_NT,
	DETAIL_CTR_NF,
	DETAIL_SEC_NF,
	DETAIL_UWY_NF,
	DETAIL_ACY_NF,
	DETAIL_DETTRNCOD_CF,
	DETAIL_CUR_CF,
	DETAIL_PREVIFRSAMT_M,
	DETAIL_IFRSAMT_M,
	DETAIL_PLNIFRSAMT_M,
	DETAIL_PREVPRNTAMT_M,
	DETAIL_PRNTAMT_M,
	DETAIL_PLNPRNTAMT_M,
	DETAIL_PREVLOCALAMT_M,
	DETAIL_LOCALAMT_M,
	DETAIL_PLNLOCALAMT_M,
	DETAIL_QUARTER_B, //[003]
	DETAIL_ACMTRS_NT,//[004]
	DETAIL_ACMDET_NT//[004]
};


enum
{
	FSUBTRSBASE_PRS_CF = 0,
	FSUBTRSBASE_ACMTRS_NT,
	FSUBTRSBASE_DETTRNCOD_CF,
	FSUBTRSBASE_ADJSIG_B,
	FSUBTRSBASE_CRE_D,
	FSUBTRSBASE_CREUSR_CF,
	FSUBTRSBASE_LSTUPD_D,
	FSUBTRSBASE_LSTUPDUSR_CF
};


enum
{
	GLOBAL_ID_CF = 0,            // ID_CF
	GLOBAL_UPDTYP_CT,            // UPDTYP_CT
	GLOBAL_SSD_CF,               // SSD_CF
	GLOBAL_ESB_CF,               // ESB_CF
	GLOBAL_LSTUPDUSR_CF,         // LSTUPDUSR_CF
	GLOBAL_GAAP_NT,              // GAAP_NT
	GLOBAL_PERIOD_NT,            // PERIOD_NT
	GLOBAL_ACY_NF,               // ACY_NF
	GLOBAL_CUR_CF,               // CUR_CF
	GLOBAL_PREMLSTAMT_M,         // PRIPRMAMT_M
	GLOBAL_PREMAMT_M,            // CURPRMAMT_M
	GLOBAL_DIFFPREMAMT_M,        // DIFFPRMAMT_M
	GLOBAL_PLNPREMAMT_M,         // PLNPRMAMT_M
	GLOBAL_TECRESLSTAMT_M,       // PRIRESTECAMT_M
	GLOBAL_TECRESAMT_M,          // CURRESTECAMT_M
	GLOBAL_DIFFTECRESAMT_M,      // DIFFRESTECAMT_M
	GLOBAL_PLNTECRESAMT_M,       // PLNRESTECAMT_M
	GLOBAL_FINTECCOMLSTAMT_M,    // PRIRESDACAMT_M
	GLOBAL_FINTECCOMAMT_M,       // CURRESDACAMT_M
	GLOBAL_DIFFFINTECCOMAMT_M,   // DIFFRESDACAMT_M
	GLOBAL_PLNFINTECCOMAMT_M,    // PLNRESDACAMT_M
	GLOBAL_LSTUPDCUR_D,          // EXC_D
	GLOBAL_LSTUSRUPD_D,          // STATREP_D
	GLOBAL_END_D,                // END_D
	GLOBAL_QUARTER_B //[003]
};


#endif /* !ESTC5000_H_ */
