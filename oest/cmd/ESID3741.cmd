#!/bin/ksh
#====================================================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 11.2 : MAINTENANCE EXPENSES PAID CALCULATION 
# Nom du script SHELL           : ESID3741.cmd
# Revision                      : $Revision:   
# Date de creation              : 07/03/2019
# Auteur                        : L.ELFAHIM
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# SPIRA 71570 : REQ 11.02 - IFRS17- CLOSING SCHEDULE : NEW CHAIN TO CALCULATE MAINTEANCE EXPENSES PAID:
#  - CALCULATION OF MAINTEANCE EXPENSES PAID
#
#----------------------------------------------------------------------------------------------------
# HISTORIQUE DES MODIFICATIONS
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   		<spira> 		<description de la modification>
#	[001] 		07/03/2019 		L.ELFAHIM 		71570 			Maintenance Expenses Paid calculation
#	[002] 		26/07/2019 		L.ELFAHIM 		71570 			Changement mapping de fichier
#====================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_10
LIBEL="MANAGE UNFOUND FILES " 
if [  ! -f "${ESF_GTSII_GLOBAL_CASHFLOW_PREV}"  ] 
then
	ECHO_LOG "ESF_GTSII_GLOBAL_CASHFLOW_PREV=${ESF_GTSII_GLOBAL_CASHFLOW_PREV} does not exist, take an empty file"  >> $FLOG
    EXECKSH "touch ${ESF_GTSII_GLOBAL_CASHFLOW_PREV}"
fi

LIBEL="MAINTENANCE EXPENSES PAID : sort ESF_GTSII_GLOBAL_CASHFLOW_PREV (period Q -1)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_GLOBAL_CASHFLOW_PREV} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_MAINTENANCE_EXPENSES.dat 1000 1" 
SORT_NOINFILE=YES
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF    	8:1   -  8:,
	END_NT    	9:1   -  9:,
	SEC_NF    	10:1  -  10:EN,
	UWY_NF    	11:1  -  11:,
	UW_NT     	12:1  -  12:,
	ACMTRS2_NT  42:1  -  42:,
	NORME_CF  	50:1  -  50:,
	PATCAT_CT	52:1  -  52:,
	PATTYP_CT	53:1  -  53:,
	FILLER     	1:1   -  124:
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
/CONDITION PAID_COND ( NORME_CF = "${NORME_CF}" AND PATCAT_CT CT "CSF" AND PATTYP_CT = "INF" AND ACMTRS2_NT = "314" )
/OUTFILE ${SORT_O}
/INCLUDE PAID_COND
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_20
LIBEL="MAINTENANCE EXPENSES PAID CALCULATION"
PRG=ESTC1091
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT ${PARM_ICLODAT_D}
NORME_CF ${NORME_CF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_MAINTENANCE_EXPENSES.dat
export ${PRG}_O1=${ESF_GTSII_MAINT_EXPENSES_PAID}
EXECPRG

JOBEND