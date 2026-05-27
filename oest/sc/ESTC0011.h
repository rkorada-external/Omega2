
#ifndef __prg
#define __prg


FILE 		*Kp_OutputFilGtr ; 	/* pointeur sur le fichier de sortie GTR */

T_RUPTURE_VAR  	   	bd_RuptGtr ; 	/* variable de gestion de la rupture sur le 
					fichier FTECLEDR */
T_RUPTURE_SYNC_VAR 	bd_RuptPlc ; /* variable de gestion de la synchronisation avec 
					le fichier des placements */

int n_InitGtr	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Gtr			( char **ptb_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptGtr	( char **ptb_InRec_Cur ) ;
int n_ActionLigneGtr		( char **pbd_InRec_Cur ) ;

int n_InitTotPlc 		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePlc		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPlc		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt, 
			char **ptb_InRecOwner );


#endif /* __prg */
