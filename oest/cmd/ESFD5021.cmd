#!/bin/ksh
#============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5021.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\02\2021
# auteur                        : Cyril AVINENS
# references des specifications :
#-----------------------------------------------------------------------------
# Description
#  Extend a pericase EBS with TCR/TSECIFRS data in order to generate a IFRS17 pericase
#
#-----------------------------------------------------------------------------
# modif
# [01] 06/02/2024 FCI 	SPIRA 110735 : Fix for ESFD5040 NO GO mode
#==============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF...............................................................: ${NORME_CF}"

ECHO_LOG "#===> ............ INPUT ...................................................."
ECHO_LOG "#===> ESF_SECIFRS_CR_EXTRACT.................................................: ${ESF_SECIFRS_CR_EXTRACT}"
ECHO_LOG "#===> EST_IADPERICASE........................................................: ${EST_IADPERICASE}"
ECHO_LOG "#===> ESF_FI17CLOPER.........................................................: ${ESF_FI17CLOPER}"

ECHO_LOG "#===> ............ OUTPUT ..................................................."
ECHO_LOG "#===> EST_IADPERICASE_I17....................................................: ${EST_IADPERICASE_I17}"
ECHO_LOG "#============================================================================"

if [ ! -f ${EST_IADPERICASE} ]; then
NSTEP=${NJOB}_0
#------------------------------------------------------------------------------
LIBEL="touch ${EST_IADPERICASE} because ESFD5040 is in NOGO mode"
EXECKSH "touch ${EST_IADPERICASE}"
fi

NSTEP=${NJOB}_01
# FILTER PERIMETER WITH TI17CLOPER
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER WITH TI17CLOPER"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FILTERED_EST_IADPERICASE.dat 2000 1"
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

#NSTEP=${NJOB}_02
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

#NSTEP=${NJOB}_05
# Extend EST_IADPERICASE with TSECIFRS AND TCR INFO by norm
# PERICASE2  MULTUWY_NF excluded, EXP2_D, MULTICAN_D
# SECIFRS    from PRISRC_CT to MULTUWY_NF, MULTUWY_NF is also inside PERICASE2 but we take this one
#-----------------------------------------------------------------------------
#LIBEL="Extend EST_PER_EBS with TSECIFRS AND CR INFO by norm"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_02_${IB}_FILTERED_ESF_SECIFRS_CR_EXTRACT.dat 2000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_EST_IADPERICASE_I17.dat 2000 1"
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
#	PERICASE2			208:1 - 209:,
#	SECIFRS		 		6:1 - 48:,
#	SECIFRS2		 	51:1 - 51:
#/joinkeys 
#	SECIFRS_CTR_NF,
#	SECIFRS_END_NT,
#	SECIFRS_SEC_NF,
#	SECIFRS_UWY_NF,
#	SECIFRS_UW_NT
#/INFILE ${EST_IADPERICASE} 2000 1 "~"
#/joinkeys 
#	PERICASE_CTR_NF ,
#	PERICASE_END_NT ,
#	PERICASE_SEC_NF ,
#	PERICASE_UWY_NF ,
#	PERICASE_UW_NT 
#/OUTFILE ${SORT_O}
#/REFORMAT 
#	rightside :PERICASE,
#	leftside  :SECIFRS,
#	rightside :PERICASE2,
#	leftside  :SECIFRS2
#exit
#EOF
#SORT

NSTEP=${NJOB}_06
# Extend EST_IADPERICASE with TSECIFRS AND TCR INFO by norm
# PERICASE2  MULTUWY_NF excluded, EXP2_D, MULTICAN_D
# SECIFRS    from PRISRC_CT to MULTUWY_NF, MULTUWY_NF is also inside PERICASE2 but we take this one
#-----------------------------------------------------------------------------
LIBEL="Extend EST_PER_EBS with TSECIFRS AND CR INFO by norm"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01_${IB}_FILTERED_EST_IADPERICASE.dat 2000 1"
SORT_O="${EST_IADPERICASE_I17} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	PERICASE_CTR_NF 	3:1 - 3:,
	PERICASE_END_NT 	4:1 - 4:,
	PERICASE_SEC_NF 	5:1 - 5:,
	PERICASE_UWY_NF 	6:1 - 6:,
	PERICASE_UW_NT  	7:1 - 7:,
	SECIFRS_CTR_NF 		1:1 - 1:,
	SECIFRS_END_NT 		2:1 - 2:,
	SECIFRS_SEC_NF 		3:1 - 3:,
	SECIFRS_UWY_NF 		4:1 - 4:,
	SECIFRS_UW_NT  		5:1 - 5:,
	PERICASE	 		1:1 - 206:,
	PERICASE2			208:1 - 209:,
	SECIFRS		 		6:1 - 48:,
	SECIFRS2		 	51:1 - 51:
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
	rightside  :SECIFRS,
	leftside :PERICASE2,
	rightside  :SECIFRS2
exit
EOF
SORT

JOBEND
