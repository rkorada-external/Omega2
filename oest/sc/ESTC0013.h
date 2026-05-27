#ifndef __DELTA
#define __DELTA

/*
** Objet  : CLEDR_OUTIO (Maitre)
** Entree : DELTA_I1
** Cle    : (SSD_CF, SSD_CF_R, AMTM_M, ACMTRS_CF, PCPTRS_CF, CUR_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT) (11 champs)
*/

#define CLEDR_SSD_CF 0
#define CLEDR_SSD_CF_R 1
#define CLEDR_AMT_M 2
#define CLEDR_ACMTRS_NT 3
#define CLEDR_TYPMNT_CT 4
#define CLEDR_CUR_CF 5
#define CLEDR_CTR_NF 6
#define CLEDR_END_NT 7
#define CLEDR_SEC_NF 8
#define CLEDR_UWY_NF 9
#define CLEDR_UW_NT 10



T_RUPTURE_VAR Kbd_ruptGTROUTIO;

int n_InitGTROUTIO(T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1GTROUTIO(char **pbd_InRec, char **pbd_InRec_Cur);
int n_ActionF1GTROUTIO(char **pbd_InRec_Cur);
int n_ActionLigneGTROUTIO(char **pbd_InRec_Cur);


/*
** Objet  : GTAOUTIO (Esclave --> CLEDR_OUTIO)
** Entree : DELTA_I2
** Cle    : (SSD_CF, SSD_CF_R, AMTM_M, ACMTRS_CF, PCPTRS_CF, CUR_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT) (11 champs)
*/

#define CLEDA_SSD_CF 0
#define CLEDA_AMT_M 1
#define CLEDA_ACMTRS_NT 2
#define CLEDA_TYPMNT_CT 3
#define CLEDA_CUR_CF 4
#define CLEDA_CTR_NF 5
#define CLEDA_END_NT 6
#define CLEDA_SEC_NF 7
#define CLEDA_UWY_NF 8
#define CLEDA_UW_NT 9
#define CLEDA_SSDS_CF 10

T_RUPTURE_SYNC_VAR Kbd_ruptGTAOUTIO;

int n_InitSyncGTAOUTIO(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncGTAOUTIO(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionLigneSyncGTAOUTIO(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionFsPGTAOUTIO(char **ptb_InRecChild);
int n_ActionPsFGTAOUTIO(char **ptb_InRecOwner);


/*
** Objet  : DiffGTACLEDR_
** Sortie : DELTA_O1
*/

FILE *Kp_OutputFileDiffGTAGTR;


#endif /* __DELTA */
