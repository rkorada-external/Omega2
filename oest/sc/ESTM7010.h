/* Structure de la table des sections */

typedef struct {
char            CTR_NF[10];
unsigned char   UW_NT;
unsigned char   END_NT;
short           UWY_NF;
unsigned char   SEC_NF;
char            NAT_CF[3];
}  T_TSECT;

/* Structure de la table des postes comptables */

typedef struct {
char            DETTRS_CF[9] ;
unsigned char   TRSTYP_CT ;
} T_DETTRS;

