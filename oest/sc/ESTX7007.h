/* Structure de la table de correspondance contrat */

typedef struct {
CS_CHAR          CTR_NF[10];
CS_TINYINT       SSD_CF;
CS_CHAR          DESTCTR_NF[10];
CS_TINYINT       DESTSSD_CF;
CS_TINYINT       ACCESB_CF;
CS_CHAR          LSTUPD_D[9];
} T_TRFCROSSREF;

