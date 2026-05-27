/* Structure de la table de correspondance contrat */

/*  03/12/2009  Roger Cassis      :spot:18415 -> Restauration de ce .h qui n'était pas à jour dans cvs  */

typedef struct {
CS_CHAR          CTR_NF[10];
CS_TINYINT       SSD_CF;
CS_CHAR          DESTCTR_NF[10];
CS_TINYINT       DESTSSD_CF;
CS_TINYINT       ACCESB_CF;
CS_TINYINT       DESTACCESB_CF;
CS_CHAR          LSTUPD_D[9];
} T_TRFCROSSREF;

/* Structure de la table des postes comptables */

typedef struct {
char            DETTRS_CF[9] ;
unsigned char   TRSTYP_CT ;
} T_DETTRS;


/* Structure de la table des postes a transformer */

typedef struct {
char            POSTEFROM[9];
char            POSTETOIN[9];
char            POSTETOOUT[9];
}  T_PTF;




typedef struct {
CS_TINYINT       ESSD_CF;
CS_TINYINT       EESB_CF;
CS_TINYINT       RSSD_CF;
CS_TINYINT       RESB_CF;
char             POSTECP[9];
}      T_CTPE;
