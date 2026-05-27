/* Structure de la table des postes a transformer */

typedef struct {
char            POSTEFROM[9];
char            POSTETOIN[9];
char            POSTETOOUT[9];
}  T_ptf;

typedef struct {
unsigned char       ESSD_CF;
unsigned char       EESB_CF;
unsigned char       RSSD_CF;
unsigned char       RESB_CF;
char                POSTECP[9];
}      T_ctpe;
