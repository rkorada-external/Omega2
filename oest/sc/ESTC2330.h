#ifndef __ESTC2330
#define __ESTC2330

/*
** Objet  : GTAR100 (Maitre)
** Entree : ESTC2330_I1
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CUR_CF, RETCTR_NF, RETSEC_NF, RTY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, ACY_NF) (12 champs)
*/


T_RUPTURE_VAR Kbd_ruptGTAR100;

int n_InitGTAR100(T_RUPTURE_VAR *pbd_Rupt);



int n_ActionLigneGTAR100(char **pbd_InRec_Cur);


/*
** Objet  : GTAR100_COMPTA (Esclave --> GTAR100)
** Entree : ESTC2330_I2
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CUR_CF, RETCTR_NF, RETSEC_NF, RTY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, ACY_NF) (12 champs)
*/


T_RUPTURE_SYNC_VAR Kbd_ruptGTAR100_COMPTA;

int n_InitSyncGTAR100_COMPTA(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncGTAR100_COMPTA(char **ptb_InRecOwner, char **ptb_InRecChild);



int n_ActionLigneSyncGTAR100_COMPTA(char **ptb_InRecOwner, char **ptb_InRecChild);


/*
** Objet  : RAPPROCH
** Sortie : ESTC2330_O1
*/

FILE *Kp_OutputFileRAPPROCH;


#endif /* __ESTC2330 */
