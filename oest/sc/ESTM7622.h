#ifndef __ESTM7622
#define __ESTM7622

/*
** Objet  : CLORETCTR (Maitre)
** Entree : ESTM7622_I1
** Cle    : (RETCTR_NF) (1 champs)
*/

#define CLORETCTR_RETCTR_NF  0
#define CLORETCTR_PRFT_CT  3

T_RUPTURE_VAR Kbd_ruptCLORETCTR;
int n_InitCLORETCTR(T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1CLORETCTR(char **pbd_InRec, char **pbd_InRec_Cur);
int n_ActionF1CLORETCTR(char **pbd_InRec_Cur);



/*
** Objet  : CLOTRS (Esclave)
** Entree : ESTM7622_I2
** Cle    : (RETCTR_NF) (1 champs)
*/

#define CLOTRS_RETCTR_NF   	0
#define CLOTRS_TRNCOD_CF   	15
#define CLOTRS_OSDRLS_CT    38

T_RUPTURE_SYNC_VAR Kbd_ruptCLOTRS;

int n_InitCLOTRS(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ConditionSyncCLOTRS(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionLigneSyncCLOTRS(char **ptb_InRecOwner, char **ptb_InRecChild);



/*
** Sortie : ESTM7622_O1
*/

FILE *Kp_OutputFileCLOTRS;


#endif /* __ESTM7622 */
