#ifndef __ESTM2569
#define __ESTM2569

#define Kn_MaxPostes  50000

/*   Generation de lignes IFRS MGTR   SPIRA:91085  */


/*
** Objet  : IRDVPERICASE (Maitre)
** Entree : ESTM2569_I1
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT) (5 champs)
*/

T_RUPTURE_VAR Kbd_ruptIRDVPERICASE;

int n_InitIRDVPERICASE(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneIRDVPERICASE(char **pbd_InRec_Cur);

/*
** Objet  : MGTR_SORT (Esclave --> Le GT)
** Entree : ESTM2569_I2
** Cle    : (RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT) (5 champs)
*/

T_RUPTURE_SYNC_VAR Kbd_ruptMGTR_SORT;

int n_InitSyncMGTR_SORT(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncMGTR_SORT(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionLigneSyncMGTR_SORT(char **ptb_InRecOwner, char **ptb_InRecChild);

/*
** Objet  : IFRSGTR (les annulations des mouvements non IFRS + ecritures IFRS)
** Sortie : ESTM2569_O1
*/

FILE *Kp_OutputFileMGTR,
     *Kp_TrslnkFil;  /* fichier des postes */

#endif /* __ESTM2569 */
