/* Structure de la table de correspondance contrat */

/*  03/12/2009  Roger Cassis      :spot:18415 -> Restauration de ce .h qui n'était pas à jour dans cvs  */

typedef struct {
  char                CTR_NF[10];
  unsigned char       SSD_CF;
  char                DESTCTR_NF[10];
  unsigned char       DESTSSD_CF;
  unsigned char       ACCESB_CF;
  unsigned char       DESTACCESB_CF;
  char                LSTUPD_D[9];
}      T_TRFCROSSREF;

typedef struct {
  char                CTR_NF[10];
  unsigned char       SSD_CF;
  char                DESTCTR_NF[10];
  unsigned char       DESTSSD_CF;
  unsigned char       ACCESB_CF;
  unsigned char       DESTACCESB_CF;
  char                LSTUPD_D[9];
}      T_TRFACROSSREF;


//typedef struct {
//CS_CHAR          CTR_NF[10];
//CS_TINYINT       SSD_CF;
//CS_CHAR          DESTCTR_NF[10];
//CS_TINYINT       DESTSSD_CF;
//CS_TINYINT       ACCESB_CF;
//CS_CHAR          LSTUPD_D[9];
//} T_TRFCROSSREF;
//
//typedef struct {
//CS_CHAR          CTR_NF[10];
//CS_TINYINT       SSD_CF;
//CS_CHAR          DESTCTR_NF[10];
//CS_TINYINT       DESTSSD_CF;
//CS_TINYINT       ACCESB_CF;
//CS_CHAR          LSTUPD_D[9];
//} T_TRFACROSSREF;

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


