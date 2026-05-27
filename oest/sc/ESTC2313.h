
 /* nombre de postes maxi des tableau TGTA et TGTR */

#define		NB_GT_MAX	1000


 /* definition d'une structure du GT */

typedef struct {
char		SSD_CF[4] ;
char		ESB_CF[4] ;
char		BALSHEY_NF[5] ;
char		BALSHRMTH_NF[3] ;
char		BALSHRDAY_NF[3] ;
char		TRNCOD_CF[9] ;
char		DBLTRNCOD_CF[9] ;
char		CTR_NF[10] ;
char		END_NT[4] ;
char		SEC_NF[4] ;
char		UWY_NF[5] ;
char		UW_NT[4] ;
char		OCCYEA_NF[5] ;
char		ACY_NF[5] ;
char		SCOSTRMTH_NF[3] ;
char		SCOENDMTH_NF[3] ;
char		CLM_NF[11] ;
char		CUR_CF[4] ;
double		AMT_M ;
char		CED_NF[6] ;
char		BRK_NF[6] ;
char		PAY_NF[6] ;
char		KEY_NF[3] ;
char		RETCTR_NF[10] ;
char		RETEND_NT[4] ;
char		RETSEC_NF[4] ;
char		RTY_NF[5] ;
char		RETUW_NT[4] ;
char		RETOCCYEA_NF[5] ;
char		RETACY_NF[5] ;
char		RETSCOSTRMTH_NF[3] ;
char		RETSCOENDMTH_NF[3] ;
char		RCL_NF[11] ;
char		RETCUR_CF[4] ;
double		RETAMT_M ;
char		PLC_NT[11] ;
char		RTO_NF[6] ;
char		INT_NF[6] ;
char		RETPAY_NF[6] ;
char		RETKEY_CF[2] ;
} T_GT ;


 
