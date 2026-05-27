/* Structure de la table de correspondance contrat */

/*    17/11/2009   R. Cassis   :spot:18415 -> Copie reconduction emetteur en date 01/01 puis annulation 02/01 pour contrats Vie parm VIE_B */

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

///typedef struct {
///unsigned char       ESSD_CF;
///unsigned char       EESB_CF;
///unsigned char       RSSD_CF;
///unsigned char       RESB_CF;
///char                POSTE[9];
///char                POSTECP[9];
///}      T_CTPE;
///
