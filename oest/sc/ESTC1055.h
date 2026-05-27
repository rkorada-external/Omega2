/*==============================================================================
Application name : ESTIMATES                                                    
Source name      : ESTC1055.c                                                   
Version                                                                         
Creation date    : 2014/11/25                                                   
Author           : C. DESPRET                                                   
------------------------------------------------------------------------------  
  Description : Compute acceptation ratio for GTAR contracts                    
________________                                                                
MODIFICATION    [                                                               
[000]  13/11/2014   C. DESPRET            :spot:26391 - Creation                
[001]  02/11/2017   L. RAKOTOZAFY passer MAXSIZE de 10000 a 30000
==============================================================================*/


#include "struct.h"

#ifndef __ESTC1055
#define __ESTC1055

#define MAXSIZE    30000
#define SEPARATOR  '~'


// Structure
typedef struct {
	
                // Retro data
                char            RETCTR_NF[10];
                int             RETEND_NT;
                int             RETSEC_NF;
                int             RTY_NF;
                int             RETUW_NT;
                int             PLC_NT;
                char            ACMCUR_CF[10];                
                // Accept data
                char            CTR_NF[10];
                int             END_NT;
                int             SEC_NF;
                int             UWY_NF;
                int             UW_NT;                
								double        	AMT_M;
} T_ACCEPT_LINE;

// Pour les fichiers
T_RUPTURE_VAR       Kbd_ruptFGTAR;
FILE                *Kp_OutputFGTAR_REPARTITION;

// Donnees metier
T_ACCEPT_LINE       acceptLines[MAXSIZE];
int                 nbAcceptLines = 0;
double              sumAmtAccept  = 0.0;

// Fonctions sur fichier maitre : GTAR
int n_InitFGTAR(T_RUPTURE_VAR *);
int n_IsR1FGTAR(char **, char **);
int n_ActionFirstFGTAR(char **);
int n_ActionLigneFGTAR(char **);
int n_ActionLastFGTAR(char **);

#endif /* __ESTC1055 */


