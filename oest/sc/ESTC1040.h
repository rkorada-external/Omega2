#ifndef __ESTC1040
#define __ESTC1040

/*
** Objet  : IADPERICASE (Maitre)
** Entree : ESTC1040_I1
** Cle    : (CTR_NF, UWY_NF, SEC_NF, UW_NT, END_NT, EGPCUR_CF) (6 champs)

________________
MODIFICATION    [001]
Auteur:         D.GATIBELZA
Date:           24/02/2010
Version:        9.1
Description:    ESTVIE17640 pas de redeclenchement de MAJ des utimes après mise à jour des taux de change (ESIJ1000)
*/

/* definition de la position des champs du fichier GT enrichi */
#define FAM_CTR_NF 0
#define FAM_UWY_NF 1
#define FAM_SEC_NF 2
#define FAM_END_NT 3        //[001] changement de l'ordre
#define FAM_UW_NT  4        //[001] changement de l'ordre
#define FAM_EGPCUR_CF 5

 /* nombre de colonnes de la table TTECLEDA */

#define NB_COL_FAM	5


T_RUPTURE_VAR Kbd_ruptIADPERICASE;

int n_InitIADPERICASE(T_RUPTURE_VAR *pbd_Rupt);



int n_ActionLigneIADPERICASE(char **pbd_InRec_Cur);


/*
** Objet  : IADPERIPRMD (Esclave --> IADPERICASE)
** Entree : ESTC1040_I2
** Cle    : (CTR_NF, UWY_NF, SEC_NF, UW_NT, END_NT, CUR_CF) (6 champs)
*/
#define GTA_CTR_NF 0
#define GTA_UWY_NF 1
#define GTA_SEC_NF 2
#define GTA_END_NT 3        //[001] changement de l'ordre
#define GTA_UW_NT  4        //[001] changement de l'ordre
#define GTA_CUR_CF 5

T_RUPTURE_SYNC_VAR Kbd_ruptIADPERIPRMD;

int n_InitSyncIADPERIPRMD(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncIADPERIPRMD(char **ptb_InRecOwner, char **ptb_InRecChild);



int n_ActionLigneSyncIADPERIPRMD(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionPsFIADPERIPRMD(char **ptb_InRecOwner);


/*
** Objet  : FTCTRACC
** Sortie : ESTC1040_O1
*/

FILE *Kp_OutputFileFTCTRACC;


#endif /* __ESTC1040 */
