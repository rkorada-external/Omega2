/* Structure de la table de correspondance contrat */

typedef struct {
CS_CHAR          CTR_NF[10];
CS_TINYINT       SSD_CF;
CS_CHAR          DESTCTR_NF[10];
CS_TINYINT       DESTSSD_CF;
CS_TINYINT       ACCESB_CF;
CS_TINYINT       DESTACCESB_CF;
CS_CHAR          LSTUPD_D[9];
} T_TRFCROSSREF;


/* Structure de la table de correspondance sinistre */

typedef struct {
CS_INT          CLM_NF;
CS_TINYINT      SSD_CF;
CS_INT          DESTCLM_NF;
CS_TINYINT      DESTSSD_CF;
} T_TCLMCROSSREF;


/* Structure de la table des postes comptables */

typedef struct {
char            DETTRS_CF[9] ;
unsigned char   TRSTYP_CT ;
} T_DETTRS;

