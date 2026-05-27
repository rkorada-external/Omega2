/*
[001] 29/05/2012  Roger Cassis  :spot:23816 incrementation du nb de postes Kn_MaxLigTCLIENT a 1000
[002] 27/06/2014 R. Cassis :spot:25036 Modifie compteur du Kn_MaxLigFBOTRSLNK (triplé)
*/

#ifndef __prg
#define __prg

#define FTECLEDA_CTR_NF 0
#define FTECLEDA_END_NT 1
#define FTECLEDA_SEC_NF 2
#define FTECLEDA_UWY_NF 3
#define FTECLEDA_UW_NT 4
#define FTECLEDA_CUR_CF 5
#define FTECLEDA_TRNCOD_CF 6
#define FTECLEDA_RTY_NF 7
#define FTECLEDA_PLC_NT 8
#define FTECLEDA_SSD_CF 9
#define FTECLEDA_AMT_M 10
#define FTECLEDA_RETCTR_NF 11
#define FTECLEDA_CED_NF 12


const char* rech_PcpTrs_cf(char *dettrs_cf);

/*
** Objet  : FCLEDA (Maitre)
** Entree : prg_I1
** Cle    : (RETCTR_NF, RTY_NF, RETSEC_NF, PLC_NT, TRNCOD_CF, RETCUR_CF, RETAMT_M) (7 champs)
*/


T_RUPTURE_VAR Kbd_ruptFCLEDA;

int n_InitFCLEDA(T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1FCLEDA(char **pbd_InRec, char **pbd_InRec_Cur);
int n_ActionF1FCLEDA(char **pbd_InRec_Cur);
int n_ActionL1FCLEDA(char **pbd_InRec_Cur);
int n_ActionLigneFCLEDA(char **pbd_InRec_Cur);



/*
** Objet  : FBOTRSLNK (Binaire)
** Entree : prg_I3
*/

FILE *Kp_FBOTRSLNK;
/* Structure pour la recuperation des donnees dans le fichier binaire FTRSLNK */
#define Kn_MaxLigFBOTRSLNK   100000    // [002]



T_FBOTRSLNK Ktbd_FBOTRSLNK[Kn_MaxLigFBOTRSLNK];

int n_ChargerFBOTRSLNK();
int n_RechTrn(char *sz_trn );




FILE *Kp_TCLIENT;
#define Kn_MaxLigTCLIENT   1000
T_TCLIENT Ktbd_TCLIENT[Kn_MaxLigTCLIENT];

int n_ChargerTCLIENT();
int n_RechSsds(int n_ced_nf);


#define MaxLigAcmTrs 600



/*
** Objet  : OUT1
** Sortie : prg_O1
*/

FILE *Kp_OutputFileOUT1;


#endif /* __prg */
