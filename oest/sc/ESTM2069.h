#ifndef __ESTM2069
#define __ESTM2069


/*   Generation de lignes IFRS MGTA   SPOT16593    */


/*
** Objet  : IADVPERICASE (Maitre)
** Entree : ESTM2069_I1
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT) (5 champs)
*/


T_RUPTURE_VAR Kbd_ruptIADVPERICASE;

int n_InitIADVPERICASE(T_RUPTURE_VAR *pbd_Rupt);



int n_ActionLigneIADVPERICASE(char **pbd_InRec_Cur);


/*
** Objet  : MGTA_SORT (Esclave --> IADVPERICASE)
** Entree : ESTM2069_I2
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT) (5 champs)
*/


T_RUPTURE_SYNC_VAR Kbd_ruptMGTA_SORT;

int n_InitSyncMGTA_SORT(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncMGTA_SORT(char **ptb_InRecOwner, char **ptb_InRecChild);



int n_ActionLigneSyncMGTA_SORT(char **ptb_InRecOwner, char **ptb_InRecChild);


/*
** Objet  : MGTA
** Sortie : ESTM2069_O1
*/

FILE *Kp_TrslnkFil,
     *Kp_OutputFileMGTA,
     *Kp_TrslnkFil;  /* fichier des postes */

#endif /* __ESTM2069 */
