#ifndef ESTC2168_H
# define ESTC2168_H

/*----------------------------------------------------------------------------*/
/*                          Include header file                               */
/*----------------------------------------------------------------------------*/
# include "utctlib.h"
# include "struct.h"
# include "estserv.h"

/*----------------------------------------------------------------------------*/
/*                             PREPROCESSING                                  */
/*----------------------------------------------------------------------------*/
#define LIFDRI_CTR_NF 0
#define LIFDRI_END_NF 1
#define LIFDRI_SEC_NF 2
#define LIFDRI_UWY_NF 3
#define LIFDRI_UW_NF 4
#define LIFDRI_CRE_D 5
#define LIFDRI_BALSHEY_NF 6
#define LIFDRI_BALSHMTH_NF 7
#define LIFDRI_ACY_NF 8
#define LIFDRI_ACM_NF 9
#define LIFDRI_SSD_CF 10
#define LIFDRI_AUTUPD_B 11
#define LIFDRI_COMMAC_B 12
#define LIFDRI_CMT_B 13
#define LIFDRI_CREUSR_CF 14
#define LIFDRI_LSTUPD_D 15
#define LIFDRI_LSTUPDUSR_CF 16
#define LIFDRI_PROPAG_B 17
#define LIFDRI_SEGUPD_B 18

/*----------------------------------------------------------------------------*/
/*                             Global Variable                                */
/*----------------------------------------------------------------------------*/
FILE				*Kp_aggregate_LIFDRI;	// pointer to output file

T_RUPTURE_VAR		bd_RuptLIFDRI;			// manage ruptur CPLIFDRI (master file)

//int					nbLines;				// number of lines for the rupt
char				cre_d[9];				// today date

/*----------------------------------------------------------------------------*/
/*                             Function in file                               */
/*----------------------------------------------------------------------------*/
// function for LIFDRI
int				n_initLIFDRI(T_RUPTURE_VAR *pbd_Rupt);
int				n_CondRuptLIFDRI(char **ptb_InRec, char **ptb_InRec_Cur);
int				n_ActionLineLIFDRI(char **ptb_InRec);
int				n_ActionLastRuptLIFDRI(char **ptb_InRec);

#endif
