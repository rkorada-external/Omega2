/* nombre de lignes de reconstitution maxi par affaire */

#define	NB_REC_MAX  500

/* nombre de lignes du Fichier de travail maxi par affaire */

#define	NB_FT_MAX  1000


/* definition de la structure du Fichier de travail */ 

typedef struct
{
char			CLODAT_D[9] ; 
char		 	CTR_NF[10] ;
unsigned char	END_NT ;
unsigned char	SEC_NF ;
short			UWY_NF ;
unsigned char	UW_NT ;
char			ACY_NF[5] ; 
char			SCOSTRMTH_NF[3] ;
char 			SCOENDMTH_NF[3] ;
short			UWYDIS_NF ;
unsigned char	SSD_CF ;
char			WFCOD_NT[6] ;
char			WFTYP_CF ;
char			EGPCUR_CF[4] ;
double		PRM_M ;
double		PPNAC_M ; 
double		PPNAEA_M ;
double		RPPC_M ;
double		RPPEA_M ;
double		LPPNAC_M ;
double		EPPC_M ;
double		EPPEA_M ;
double		RECC_M ;
double		RECE_M ;
double		BCC_M ;
double		BCE_M ;
double		SHR_R ;
unsigned char	ACCADMTYP_CT ;
} T_FTBC ;


