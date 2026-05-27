/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1061.c
 Revision                      : $Revision: 1.4 $
 Date de creation              : 09/01/2012
 Auteur                        : gensource v2.0 (auto)
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
[001]  01/06/2012 	-=Dch=-  :spot:23937 SOLVENCY II
[002]  01/06/2012 	-=Dch=-  :spot:24041 SOLVENCY II
==============================================================================*/
#ifndef __ESTC1061
#define __ESTC1061

T_RUPTURE_VAR *pbd_Rupture;
T_RUPTURE_SYNC_VAR *pbd_Sync;

// Variable de fichiers
FILE *Kp_OutFileANO;
FILE *Kp_OutputGTCumul;
FILE *Kp_InputCumul;
char gsz_seglobuwy[15] = "";
char gsz_seg_nf[11] = "";

/*--------------------------------------------------*/
/* Prototype des fonctions                          */
/*--------------------------------------------------*/

/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/
int n_InitRupture(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLignePereGTSII( char **pdb_InRec);
int n_ConditionRuptureGTSII(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionFistRuptureGTSII(char **pbd_InRec_Cur);
/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le maitre et l'esclave */
/*--------------------------------------------------------------*/
int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ConditionSync( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] );
int n_ActionLigneFils (char **pbd_InRecOwner, char **pbd_InRecChild);

#endif /* __ESTC1061 */
