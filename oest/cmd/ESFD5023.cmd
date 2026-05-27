#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5023.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 04\03\2021
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# Description
#  Generate EST_IRDPERICASE_I17_NP and EST_IADVPERICASE_P_INI from EST_IRDPERICASE_I17
#
#-----------------------------------------------------------------------------
# [01]  2022/03/08      DaD     Spira 101582 : add Inception date <= closing date for Retro NP (Rollback)
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF...............................................................: ${NORME_CF}"

ECHO_LOG "#===> ............ INPUT ...................................................."
ECHO_LOG "#===> EST_IRDPERICASE_I17....................................................: ${EST_IRDPERICASE_I17}"
ECHO_LOG "#===> ESF_SECIFRS_CR_EXTRACT.................................................: ${ESF_SECIFRS_CR_EXTRACT}"
ECHO_LOG "#===> EST_IADPERICASE0_INI...................................................: ${EST_IADPERICASE0_INI}"
ECHO_LOG "#===> ESF_FI17CLOPER.........................................................: ${ESF_FI17CLOPER}"

ECHO_LOG "#===> ............ OUTPUT ..................................................."
ECHO_LOG "#===> EST_IRDPERICASE_I17_NP.................................................: ${EST_IRDPERICASE_I17_NP}"
ECHO_LOG "#===> EST_IADVPERICASE_P_INI.................................................: ${EST_IADVPERICASE_P_INI}"
ECHO_LOG "#============================================================================"

NSTEP=${NJOB}_02
# FILTER PERIMETER WITH TI17CLOPER
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER WITH TI17CLOPER"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE_I17} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FILTERED_EST_IRDPERICASE_I17.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_NF 					1:1 - 1:,
	ESB_CF  				2:1 - 2:,
	IRDPERICASE_SSD_NF 		1:1 - 1:,
	IRDPERICASE_ESB_CF  	8:1 - 8:,
	IRDPERICASE				1:1 - 206:
/joinkeys 
	IRDPERICASE_SSD_NF ,
	IRDPERICASE_ESB_CF
/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
/joinkeys 
	SSD_NF ,
	ESB_CF
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside: IRDPERICASE
exit
EOF
SORT

# [01] remove AND (PER_CTRINC_D <= "20210931") in condition NPVALID (this condition is in proc BEST_PsPeriRetIni.prc)
NSTEP=${NJOB}_05
# SORT EST_IADPERICASE_INI to EST_IRDPERICASE_NP_INI
#-----------------------------------------------------------------------------
LIBEL="Trie IRDPERICASE_INI to EST_IADVPERICASE_P_INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_02_${IB}_FILTERED_EST_IRDPERICASE_I17.dat 2000 1"
SORT_O="${EST_IRDPERICASE_I17_NP} 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_IRPERICASE_P_INI_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat  2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        PER_CTR_NF              3:1 - 3:,
        PER_END_NT              4:1 - 4: ,
        PER_SEC_NF              5:1 - 5: ,
        PER_UWY_NF              6:1 - 6: ,
        PER_UW_NT               7:1 - 7: ,
        PER_CTRINC_D           19:1 - 19:,
        PER_CTRNAT_CT          85:1 - 85:,
        PER_CTRSTS_CT          99:1 - 99:,
        PER_CTRTYP_CT         188:1 - 188:
/KEYS
        PER_CTR_NF,
        PER_END_NT,
        PER_SEC_NF,
        PER_UWY_NF,
        PER_UW_NT
/CONDITION NPVALID  (PER_CTRNAT_CT = "N") AND (PER_CTRTYP_CT = "RET")
/CONDITION PVALID  (PER_CTRNAT_CT = "P") AND (PER_CTRTYP_CT = "RET")
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE NPVALID
/OUTFILE ${SORT_O2} OVERWRITE
/INCLUDE PVALID
exit
EOF
SORT

NSTEP=${NJOB}_06
# FILTER PERIMETER WITH TI17CLOPER
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER WITH TI17CLOPER"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0_INI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FILTERED_EST_IADPERICASE0_INI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_NF 					1:1 - 1:,
	ESB_CF  				2:1 - 2:,
	IADPERICASE_SSD_NF 		1:1 - 1:,
	IADPERICASE_ESB_CF  	8:1 - 8:,
	IADPERICASE				1:1 - 209:
/joinkeys 
	IADPERICASE_SSD_NF ,
	IADPERICASE_ESB_CF
/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
/joinkeys 
	SSD_NF ,
	ESB_CF
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside: IADPERICASE
exit
EOF
SORT

NSTEP=${NJOB}_07
# FILTER PERIMETER WITH TI17CLOPER
#------------------------------------------------------------------------------
#LIBEL="FILTER PERIMETER WITH TI17CLOPER"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${ESF_SECIFRS_CR_EXTRACT} 2000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_FILTERED_ESF_SECIFRS_CR_EXTRACT.dat 2000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS
#	SSD_NF 					1:1 - 1:,
#	ESB_CF  				2:1 - 2:,
#	SECIFRS_SSD_NF 				32:1 - 32:,
#	SECIFRS_ESB_CF  			33:1 - 33:,
#	SECIFRS				1:1 - 51:
#/joinkeys 
#	SECIFRS_SSD_NF ,
#	SECIFRS_ESB_CF
#/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
#/joinkeys 
#	SSD_NF ,
#	ESB_CF
#/OUTFILE ${SORT_O}
#/REFORMAT 
#	leftside: SECIFRS
#exit
#EOF
#SORT

NSTEP=${NJOB}_10
# Extend EST_IADPERICASE0_INI with TSECIFRS AND TCR INFO by norm
#-----------------------------------------------------------------------------
#LIBEL="Extend EST_IADPERICASE0_INI with TSECIFRS AND CR INFO by norm"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_07_${IB}_FILTERED_ESF_SECIFRS_CR_EXTRACT.dat 2000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE0_INI_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat 2000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS 
#	SECIFRS_CTR_NF 		1:1 - 1:,
#	SECIFRS_END_NT 		2:1 - 2:,
#	SECIFRS_SEC_NF 		3:1 - 3:,
#	SECIFRS_UWY_NF 		4:1 - 4:,
#	SECIFRS_UW_NT  		5:1 - 5:,
#	PERICASE_CTR_NF 	3:1 - 3:,
#	PERICASE_END_NT 	4:1 - 4:,
#	PERICASE_SEC_NF 	5:1 - 5:,
#	PERICASE_UWY_NF 	6:1 - 6:,
#	PERICASE_UW_NT  	7:1 - 7:,
#	PERICASE	 		1:1 - 206:,
#	SECIFRS		 		6:1 - 51:
#/joinkeys 
#	SECIFRS_CTR_NF,
#	SECIFRS_END_NT,
#	SECIFRS_SEC_NF,
#	SECIFRS_UWY_NF,
#	SECIFRS_UW_NT 
#/INFILE ${EST_IADPERICASE0_INI} 2000 1 "~"
#/joinkeys 
#	PERICASE_CTR_NF ,
#	PERICASE_END_NT ,
#	PERICASE_SEC_NF ,
#	PERICASE_UWY_NF ,
#	PERICASE_UW_NT 
#/OUTFILE ${SORT_O}
#/REFORMAT 
#	rightside :PERICASE,
#	leftside  :SECIFRS
#exit
#EOF
#SORT

NSTEP=${NJOB}_11
# Extend EST_IADPERICASE0_INI with TSECIFRS AND TCR INFO by norm
#-----------------------------------------------------------------------------
LIBEL="Extend EST_IADPERICASE0_INI with TSECIFRS AND CR INFO by norm"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_06_${IB}_FILTERED_EST_IADPERICASE0_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE0_INI_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SECIFRS_CTR_NF 		1:1 - 1:,
	SECIFRS_END_NT 		2:1 - 2:,
	SECIFRS_SEC_NF 		3:1 - 3:,
	SECIFRS_UWY_NF 		4:1 - 4:,
	SECIFRS_UW_NT  		5:1 - 5:,
	PERICASE_CTR_NF 	3:1 - 3:,
	PERICASE_END_NT 	4:1 - 4:,
	PERICASE_SEC_NF 	5:1 - 5:,
	PERICASE_UWY_NF 	6:1 - 6:,
	PERICASE_UW_NT  	7:1 - 7:,
	PERICASE	 		1:1 - 206:,
	SECIFRS		 		6:1 - 51:
/joinkeys
	PERICASE_CTR_NF ,
	PERICASE_END_NT ,
	PERICASE_SEC_NF ,
	PERICASE_UWY_NF ,
	PERICASE_UW_NT 
/INFILE ${ESF_SECIFRS_CR_EXTRACT} 2000 1 "~"
/joinkeys 
	SECIFRS_CTR_NF,
	SECIFRS_END_NT,
	SECIFRS_SEC_NF,
	SECIFRS_UWY_NF,
	SECIFRS_UW_NT
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside :PERICASE,
	rightside  :SECIFRS
exit
EOF
SORT

NSTEP=${NJOB}_15
# SORT IRDPERICASE_P_INI to EST_IADVPERICASE_P_INI
#-----------------------------------------------------------------------------
LIBEL="Trie IRDPERICASE_P_INI to EST_IADVPERICASE_P_INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_11_${IB}_IADPERICASE0_INI_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_IRPERICASE_P_INI_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat 2000 1"
SORT_O="${EST_IADVPERICASE_P_INI} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        PER_CTR_NF              3:1 - 3:,
        PER_END_NT              4:1 - 4: ,
        PER_SEC_NF              5:1 - 5: ,
        PER_UWY_NF              6:1 - 6: ,
        PER_UW_NT               7:1 - 7: ,
        PER_CTRINC_D           19:1 - 19:,
        PER_CTRNAT_CT          85:1 - 85:,
        PER_CTRSTS_CT          99:1 - 99:,
        PER_CTRTYP_CT         188:1 - 188:
/KEYS
        PER_CTR_NF,
        PER_END_NT,
        PER_SEC_NF,
        PER_UWY_NF,
        PER_UW_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

JOBEND
