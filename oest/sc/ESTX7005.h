/* Structure de la table de correspondance contrat */

typedef struct {
  char                CTR_NF[10];
  unsigned char       SSD_CF;
  char                DESTCTR_NF[10];
  unsigned char       DESTSSD_CF;
  unsigned char       ACCESB_CF;
  char                LSTUPD_D[9];
}      T_TRFCROSSREF;

typedef struct {
  char                CTR_NF[10];
  unsigned char       SSD_CF;
  char                DESTCTR_NF[10];
  unsigned char       DESTSSD_CF;
  unsigned char       ACCESB_CF;
  char                LSTUPD_D[9];
}      T_TRFACROSSREF;


