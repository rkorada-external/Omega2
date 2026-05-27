#ifndef __ESTM2565
#define __ESTM2565

/*
** Objet  : IRDVPERICASE (Maitre)
** Entree : ESTM2565_I1
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT) (5 champs)
*/


T_RUPTURE_VAR Kbd_ruptIRDVPERICASE;

int n_InitIRDVPERICASE(T_RUPTURE_VAR *pbd_Rupt);



int n_ActionLigneIRDVPERICASE(char **pbd_InRec_Cur);


/*
** Objet  : MGTAR_SORT (Esclave --> IRDVPERICASE)
** Entree : ESTM2565_I2
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT) (5 champs)
*/


T_RUPTURE_SYNC_VAR Kbd_ruptMGTAR_SORT;

int n_InitSyncMGTAR_SORT(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncMGTAR_SORT(char **ptb_InRecOwner, char **ptb_InRecChild);



int n_ActionLigneSyncMGTAR_SORT(char **ptb_InRecOwner, char **ptb_InRecChild);


/*
** Objet  : MGTAR
** Sortie : ESTM2565_O1
*/

FILE *Kp_OutputFileMGTAR;


#endif /* __ESTM2565 */
