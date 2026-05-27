#ifndef ESTC2169_H
# define ESTC2169_H

/*----------------------------------------------------------------------------*/
/*                          Include header file                               */
/*----------------------------------------------------------------------------*/
# include "utctlib.h"
# include "struct.h"
# include "estserv.h"

/*----------------------------------------------------------------------------*/
/*                             Global Variable                                */
/*----------------------------------------------------------------------------*/
FILE				*Kp_aggregate_LIFEST_Q;		// pointer to output file
FILE				*Kp_Subtrs;				// pointer to SUBTRS file

T_RUPTURE_VAR		bd_RuptLIFEST_Q;	// manage ruptur CPLIFEST_MVT (master file)
//T_RUPTURE_SYNC_VAR	bd_RuptCPLIFEST;		// manage ruptur CPLIFEST (slave file)

T_SUBTRS			subtrsLine;				// struct for subtrs

double				amount;					// amount of aggregate
int					lastMthMvt;				// last month before sync with CPLIFEST
char				newAmount[20];			// string of amount

/*----------------------------------------------------------------------------*/
/*                             Function in file                               */
/*----------------------------------------------------------------------------*/
// function for LIFEST_Q
int				n_initLIFEST_Q(T_RUPTURE_VAR *pbd_Rupt);
int				n_CondRuptLIFEST_Q(char **ptb_InRec, char **ptb_InRec_Cur);
int				n_ActionFirstRuptLIFEST_Q(char **ptb_InRec);
int				n_ActionLineLIFEST_Q(char **ptb_InRec);
int				n_ActionLastRuptLIFEST_Q(char **ptb_InRec);

// function for CPLIFEST
/*int				n_initCPLIFEST(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int				n_ConditionRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ConditionSyncCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ActionLastRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ActionFirstRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ActionRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild);*/

// function for SUBTRS
static void		init_SubTrsLigne(void);

#endif
