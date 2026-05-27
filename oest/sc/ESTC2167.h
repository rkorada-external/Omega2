#ifndef ESTC2167_H
# define ESTC2167_H

/* [001] 25/11/2019 S.Behague :spira:91872 Apolo - TLIFESTD alimentée uniquement sur le quarter 4 */
/*----------------------------------------------------------------------------*/
/*                          Include header file                               */
/*----------------------------------------------------------------------------*/
# include "utctlib.h"
# include "struct.h"
# include "estserv.h"

/*----------------------------------------------------------------------------*/
/*                             Global Variable                                */
/*----------------------------------------------------------------------------*/
FILE				*Kp_aggregate_MVT;		// pointer to output file
FILE				*Kp_Subtrs;				// pointer to SUBTRS file

T_RUPTURE_VAR		bd_RuptCPLIFEST_MVT;	// manage ruptur CPLIFEST_MVT (master file)
T_RUPTURE_SYNC_VAR	bd_RuptCPLIFEST;		// manage ruptur CPLIFEST (slave file)

T_SUBTRS			subtrsLine;				// struct for subtrs

double				amount;					// amount of aggregate
int					amount_upd;				// (1)True if amount was updated, (0)False else
int					lastMthMvt;				// last month before sync with CPLIFEST
char				newAmount[20];			// string of amount
int	mois3;
int	mois6;
int mois9;
int mois12;

/*----------------------------------------------------------------------------*/
/*                             Function in file                               */
/*----------------------------------------------------------------------------*/
// function for CPLIFEST_MVT
int				n_initCPLIFEST_MVT(T_RUPTURE_VAR *pbd_Rupt);
int				n_CondRuptCPLIFEST_MVT(char **ptb_InRec, char **ptb_InRec_Cur);
int				n_ActionFirstRuptCPLIFEST_MVT(char **ptb_InRec);
int				n_ActionLineCPLIFEST_MVT(char **ptb_InRec);
int				n_ActionLastRuptCPLIFEST_MVT(char **ptb_InRec);

// function for CPLIFEST
int				n_initCPLIFEST(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int				n_ConditionRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ConditionSyncCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ActionLastRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ActionFirstRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild);
int				n_ActionRuptCPLIFEST(char **ptb_InRecOwner, char **ptb_InRecChild);

// function for SUBTRS
static void		init_SubTrsLigne(void);

#endif
