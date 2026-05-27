
/* Position des champs dans le fichier Liste des affaires */
/*
[001] 21/05/2014 R. cassis :spot:26775 Agrandissement nb_rec_maxi de 50 a 500
[002] 17/06/2014 JBG :spot:25773 Float format change (nnnnnnnn.nnn)
[002] 17/06/2014 JBG :spot:25773 Float format change (nnnnnnnn.nnn)
[003] 22/09/2014 R. Cassis :spot:27489 field CALAMTPRM_M fixed to double instead of float.
[004] 29/05/20223 M.NAJI  SPIRA 999999  augmentation de la taille de Kbd_Rec à 10000
*/

#define AFF_CTR_NF		0
#define AFF_UWY_NF		1
#define AFF_UW_NT		2
#define AFF_END_NT		3
#define AFF_SEC_NF		4
#define AFF_DIV_NT		5
#define AFF_UWRSPUSR_CF		6
#define AFF_ADMUSR_CF		7
#define AFF_SECLAB_LM		8
#define AFF_SSD_CF		9	
#define AFF_SECACCSTS_CT	10
#define AFF_ESTEND_B		11
#define AFF_EVTCOD_NF		12
#define AFF_CTRNAT_CT		13
#define AFF_ESTUPDTYP_CT	14
#define AFF_LOB_CF		15
#define AFF_SOB_CF		16
#define AFF_PCPRSKTRY_CF	17
#define AFF_ACCADMTYP_CT	18
#define AFF_SCOORGEGP_M		19
#define AFF_SCOGLOEGP_M		20
#define AFF_EGPCUR_CF		21
#define AFF_PMLRAT_R		22
#define AFF_CUTSHA_R		23
#define AFF_RIDSHA_R		24
#define AFF_LIARIDSHA_B		25
#define AFF_SCOEGPCAL_B		26
#define AFF_EGPLESSCO_M		27
#define AFF_PRMFLCRAT_B		28
#define AFF_PRMFIXEFF_R		29
#define AFF_PRMMINEFF_R		30
#define AFF_PRMMAXEFF_R		31
#define AFF_SUPLOATYP_CT	32
#define AFF_PRMEFFLOA_M		33
#define AFF_PRMEFFLOA_R		34
#define AFF_SBJPRMCUR_CF	35
#define AFF_ESTSBJPRM_M		36
#define AFF_DEFSBJPRM_M		37
#define AFF_SBJPRMCPT_M		38
#define AFF_REIEXI_B		39
#define AFF_REIUNL_B		40
#define AFF_REIFRE_B		41
#define AFF_REINBR_N		42
#define AFF_LAYCAP_M		43
#define AFF_FLAPRM_B		44
#define AFF_SBJCPTDEF_B		45
#define AFF_PMDEGPCUR_M		46
#define AFF_CPLACCY_NF		47
#define AFF_SCOLSTMTH_NF	48
#define AFF_EXP_D		49


/* Position des champs dans le fichier Mouvements comptables */

#define MVT_SSD_CF 		0
#define MVT_BALSHEY_NF 		1
#define MVT_CTR_NF 		2
#define MVT_END_NT 		3
#define MVT_SEC_NF 		4
#define MVT_UWY_NF 		5
#define MVT_UW_NT 		6
#define MVT_ACMTRS_NT		7
#define MVT_EGPCUR_CF		8
#define MVT_EGPCUR_M		9


/* Position des champs dans le fichier Parametres de reconstitution */

#define REC_CTR_NF		0
#define REC_UWY_NF		1
#define REC_UW_NT		2
#define REC_END_NT		3
#define REC_SEC_NF		4
#define REC_REILIN_NT		5
#define REC_REIRNK_N		6
#define REC_REIPRMBAS_R		7
#define REC_REIPRM_M		8
#define REC_REIPRM_R		9
#define REC_REIPROTMP_B		10


/* Position des champs dans le fichier Primes et sinistres ultimes */

#define ULT_CTR_NF		0
#define ULT_UWY_NF		1
#define ULT_UW_NT			2
#define ULT_END_NT		3
#define ULT_SEC_NF		4
#define ULT_CRE_D			5
#define ULT_SSD_CF		6
#define ULT_DIV_NT		7
#define ULT_CUR_CF		8
#define ULT_CALAMTPRM_M		9
#define ULT_ENTAMTPRM_M		10
#define ULT_RETAMTPRM_M		11
#define ULT_ADMMODPRM_CT	12
#define ULT_RESPRM_M		13
#define ULT_CALAMTCLM_M		14
#define ULT_ENTAMTCLM_M		15
#define ULT_RETAMTCLM_M		16
#define ULT_ADMMODCLM_CT	17
#define ULT_ORICOD_LS		18
#define ULT_UPDUSR_CF		19
#define ULT_ULTUPDTYP_CF	20


/* Nombre de reconstitution maxi par affaire */
// [001]
#define NB_REC_MAX		10000


/* nombre de lignes maxi de la table BEST..TAUTPAR */
#define NB_AUTPAR_MAX 		200


/* postes cumules */
#define POSTCUM_10000		0	/* poste cumul 10000: prime (hors reconstit et burning cost) */
#define POSTCUM_10000c		1	/* poste cumul 10000: idem et periode de compte complet */
#define POSTCUM_12000c		2	/* poste cumul 12000: prime de reconstitution et periode de compte complet */
#define POSTCUM_13000c 		3	/* poste cumul 13000: prime de burning cost et periode de compte complet */
#define POSTCUM_10050		4	/* poste cumul 10050: PNA et portefeuille */
#define POSTCUM_10050c		5	/* poste cumul 10050: idem et periode de compte complet */


#define POSTCUM_10100		0	/* poste cumul 10100: charges */
#define POSTCUM_10100c		1	/* poste cumul 10100: idem et periode de compte complet */

#define POSTCUM_20000		0	/* poste cumul 20000: sinistre ( hors ACR ) */
#define POSTCUM_20000c		1	/* poste cumul 20000: idem et periode de compte complet */
#define POSTCUM_20050		2	/* poste cumul 20000: ACR */
#define POSTCUM_20050c		3	/* poste cumul 20000: idem et periode de compte complet */


/* definition d'un type Liste des affaires */

typedef struct 
{
char 			CTR_NF[10] ;	
short			UWY_NF ;		
unsigned char	UW_NT	;	
unsigned char	END_NT ;		
unsigned char	SEC_NF ;		
unsigned char 	DIV_NT ;		
char			UWRSPUSR_CF[5] ;		
char			ADMUSR_CF[5] ;		
char			SECLAB_LM[33] ;		
unsigned char	SSD_CF ;			
unsigned char	SECACCSTS_CT ;	
unsigned char	ESTEND_B ;	
unsigned char	EVTCOD_NF ;	
char			CTRNAT_CT ;	
char			ESTUPDTYP_CT ;	
char			LOB_CF[3] ;		
char			SOB_CF[3] ;		
char			PCPRSKTRY_CF[4] ;	
unsigned char	ACCADMTYP_CT ;	
double		SCOORGEGP_M	;	
double		SCOGLOEGP_M	;	
char			EGPCUR_CF[4] ;		
double		PMLRAT_R ;	
double		CUTSHA_R ;		
double		RIDSHA_R ;		
unsigned char	LIARIDSHA_B	;	
unsigned char	SCOEGPCAL_B	;	
double		EGPLESSCO_M	;	
unsigned char	PRMFLCRAT_B	;	
double		PRMFIXEFF_R	;	
double		PRMMINEFF_R	;	
double		PRMMAXEFF_R	;	
unsigned char	SUPLOATYP_CT ;	
double		PRMEFFLOA_M	;	
double		PRMEFFLOA_R	;	
char			SBJPRMCUR_CF[4] ;	
double		ESTSBJPRM_M	;	
double		DEFSBJPRM_M	;	
double		SBJPRMCPT_M	;	
unsigned char	REIEXI_B ;		
unsigned char	REIUNL_B ;		
unsigned char	REIFRE_B ;		
unsigned char	REINBR_N ;		
double		LAYCAP_M ;		
unsigned char	FLAPRM_B ;		
unsigned char	SBJCPTDEF_B	;	
double		PMDEGPCUR_M	;	
short			CPLACCY_NF ;		
unsigned char	SCOLSTMTH_NF ;	
char		EXP_D[9];
} T_AFFAIRE ;


/* definition d'un type Primes et sinistres ultimes */

typedef struct 
{
char 			CTR_NF[10] ;	
short			UWY_NF ;		
unsigned char	UW_NT	;	
unsigned char	END_NT ;		
unsigned char	SEC_NF ;
char			CRE_D[18] ;
unsigned char	SSD_CF ;
unsigned char	DIV_NT ;
char			CUR_CF[4] ;
double 		CALAMTPRM_M	; //[002] [003]	
double 		ENTAMTPRM_M	;	
double 		RETAMTPRM_M	;	
char			ADMMODPRM_CT ;	
double		RESPRM_M ;		
double		CALAMTCLM_M	;	
double		ENTAMTCLM_M	;	
double		RETAMTCLM_M	;	
char			ADMMODCLM_CT ;	
char			ORICOD_LS[17] ;		
char			UPDUSR_CF[11] ;		
char			ULTUPDTYP_CF ;	
} T_ULTIME ;		


/* definition d'un type Montant de prime, charge et sinistre */

typedef struct
{
double		PRMAMT_M[6] ;
double		CHAAMT_M[2] ;
double		CLMAMT_M[4] ;
} T_PCSAMT;


/* definition d'un type Souscription */

typedef struct
{
char 			CTR_NF[10] ;	
short			UWY_NF ;		
unsigned char	UW_NT	;	
unsigned char	END_NT ;		
unsigned char	SEC_NF ;
char			CTRNAT_CT ;
double		SCOGLOEGP_M ;
double		TOTCLM_M ;
unsigned char	SCOEGPCAL_B ;
char			ADMMODCTR_CT ;
unsigned char	ESTEND_B ;
char			ESTUPDTYP_CT ;
double		PMLRAT_R ;
} T_SOUS ;


/* definition d'un type Montants stats */

typedef struct
{
char 			CTR_NF[10] ;	
short			UWY_NF ;		
unsigned char	UW_NT	;	
unsigned char	END_NT ;		
unsigned char	SEC_NF ;
double 		PRMCPLACC_M ;	/* prime compte complet */
double 		UPRCPLACC_M ;	/* PNA compte complet */
double		CLMCPLACC_M ;	/* sinistre compte complet */
double 		ACRCPLACC_M ;	/* ACR compte complet */
double		CHACPLACC_M ;	/* charge compte complet */
double 		RESCPLACC_M ;	/* reconstit et burning cost */
double 		ACCPRM_M ;	/* prime comptabilisee */
double		ACCUPR_M ;	/* PNA comptabilisee */
double		ACCCLM_M ;	/* sinistre comptabilise */
double		ACCACR_M ;	/* ACR comptabilise */
double 		ACCCHA_M ;	/* charge comptabilisee */
short		ACY_NF ;	/* annee compte complet */
unsigned char	SCOENDMTH_NF ;	/* mois compte complet */
} T_STATS ;


/* definition d'un type Agenda */

typedef struct
{
char			UWRSPUSR_CF[5] ;
char			ADMUSR_CF[5] ;
char			RMDOBJ_LL[65] ;
char			RMDDOM_CT[4] ;
char			RMDENTLAB_LL[65] ;
char			RMDENTIDT_CT[21] ;
char			CMT_T[256] ;
} T_AGENDA ;





