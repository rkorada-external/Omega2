#ifndef __ESTM2563
#define __ESTM2563

/*
** Objet  : CADVPERIESB0(Maitre)
** Entree : ESTM2563_I1
** Cle    : (CTR_NF, END_NT, UWY_NF, UW_NT) (4 champs)
*/
#define PERESB_CTR_NF 0
#define PERESB_END_NT 1
#define PERESB_UWY_NF 2
#define PERESB_UW_NT  3
#define PERESB_ACCESB_CF 4


T_RUPTURE_VAR Kbd_ruptCADVPERIESB;

int n_InitCADVPERIESB(T_RUPTURE_VAR *pbd_Rupt);



int n_ActionLigneCADVPERIESB(char **pbd_InRec_Cur);


/*
** Objet  : MGTAR_SORT (Esclave --> CADVPERIESB)
** Entree : ESTM2563_I2
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT) (5 champs)
*/


T_RUPTURE_SYNC_VAR Kbd_ruptMGTAR_SORT;

int n_InitSyncMGTAR_SORT(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncMGTAR_SORT(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionFilsSansPereMGTAR(char **ptb_InRecChild );   /*  jr 28 12 2007 */


int n_ActionLigneSyncMGTAR_SORT(char **ptb_InRecOwner, char **ptb_InRecChild);


/*
** Objet  : MGTAR
** Sortie : ESTM2563_O1
*/

FILE *Kp_OutputFileMGTAR;


#endif /* __ESTM2563 */
