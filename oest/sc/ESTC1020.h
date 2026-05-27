/*==============================================================================
[001] 18/04/2012 Roger Cassis  :spot:23802 - Ajout colonne PRS_CF pour Solvency
==============================================================================*/

/* nombre de colonnes de la table Acquisition d'entree de portefeuille */

#define NB_COL_EARIPP	12 	

/* nombre de colonnes de la table des primes par periode de compte */

#define NB_COL_CALPRE	16 	

/* definition de la position des champs du fichier des acquisition d'entree de portefeuille */

#define EAR_CTR_NF 	0
#define EAR_END_NT	1
#define EAR_SEC_NF	2
#define EAR_UWY_NF	3
#define EAR_UW_NT	4
#define EAR_ACY_NF	5
#define EAR_SCOSTRMTH_NF	6
#define EAR_SCOENDMTH_NF	7
#define EAR_SSD_CF	8
#define EAR_CUR_CF	9
#define EAR_REFPRM_M	10
#define EAR_WPPORT_M	11
#define EAR_PRS_CF 12

/* definition de la position des champs du fichier des primes par periode de compte */

#define CAL_CTR_NF 	0
#define CAL_END_NT	1
#define CAL_SEC_NF	2
#define CAL_UWY_NF	3
#define CAL_UW_NT	4
#define CAL_ACY_NF	5
#define CAL_SCOSTRMTH_NF	6
#define CAL_SCOENDMTH_NF	7
#define CAL_SSD_CF	8
#define CAL_CUR_CF	9
#define CAL_RECPRM_M	10
#define CAL_BRRECPRM_M	11
#define CAL_ESTPRM_M	12
#define CAL_BRESTPRM_M	13
#define CAL_URNRECPRM_M	14
#define CAL_URNESTPRM_M	15
#define CAL_PRS_CF 16
