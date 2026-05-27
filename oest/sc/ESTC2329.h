#ifndef __ESTC2329
#define __ESTC2329

/*
** Objet  : EST_FCES (Maitre)
** Entree : ESTC2329_I1
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT) (10 champs)
*/


T_RUPTURE_VAR Kbd_ruptEST_FCES;

int n_InitEST_FCES(T_RUPTURE_VAR *pbd_Rupt);



int n_ActionLigneEST_FCES(char **pbd_InRec_Cur);


/*
** Objet  : EST_FCESANT (Esclave --> EST_FCES)
** Entree : ESTC2329_I2
** Cle    : (CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT) (10 champs)
*/


T_RUPTURE_SYNC_VAR Kbd_ruptEST_FCESANT;

int n_InitSyncEST_FCESANT(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncEST_FCESANT(char **ptb_InRecOwner, char **ptb_InRecChild);



int n_ActionLigneSyncEST_FCESANT(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionFsPEST_FCESANT(char **ptb_InRecChild);
int n_ActionPsFEST_FCESANT(char **ptb_InRecOwner);


/*
** Objet  : DIFFCES
** Sortie : ESTC2329_O1
*/

FILE *Kp_OutputFileDIFFCES;


#endif /* __ESTC2329 */
