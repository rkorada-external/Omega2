#ifndef ESTC1036_H
# define ESTC1036_H

/*----------------------------------------------------------------------------*/
/*                          Include header file                               */
/*----------------------------------------------------------------------------*/
# include "utctlib.h"
# include "struct.h"
# include "estserv.h" 

/*----------------------------------------------------------------------------*/
/*                             Global Variable                                */
/*----------------------------------------------------------------------------*/
FILE				*Kp_lifest,			// pointer to output file
					*Kp_periacse,		// pointer to SUBTRS file
					*Kp_outputLIFEST;	// pointer to output file

T_RUPTURE_VAR		bd_RuptLIFEST;		// manage ruptur LIFEST (master file)
T_RUPTURE_SYNC_VAR	bd_RuptPERICASE;	// manage ruptur PERICASE (slave file)

char				crible;				// code crible

/*----------------------------------------------------------------------------*/
/*                             Function in file                               */
/*----------------------------------------------------------------------------*/
// function for LIFEST
int				n_initLIFEST(T_RUPTURE_VAR *pbd_Rupt);
int				n_CondRuptLIFEST(char **ptb_InRec, char **ptb_InRec_Cur);
int				n_ActionLineLIFEST(char **ptb_InRec);
int				n_ActionFirstLIFEST(char **ptb_InRec);

// function for PERICASE
int				n_initPERICASE(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int				n_ConditionRuptPERICASE(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ConditionSyncPERICASE(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ActionFirstPERICASE(char **ptb_InRecOwner, char **ptb_InRecChild);

#endif
