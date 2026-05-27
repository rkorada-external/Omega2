#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5024.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 08\11\2022
# auteur                        : David DA SILVA TEIXEIRA
# references des specifications :
#-----------------------------------------------------------------------------
# Description
#  Extend a pericase DUMMY EBS with TCR/TSECIFRS data in order to generate a IFRS17 pericase
#-----------------------------------------------------------------------------
# historiques des modifications :
#-----------------------------------------------------------------------------
#[001] 28/12/2023 MZM  	SPIRA : 111036 Generation fichier Permanent Pericase Merge I17 INI et I17 STD ESFD5020
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF...............................................................: ${NORME_CF}"

ECHO_LOG "#===> ............ INPUT ...................................................."
ECHO_LOG "#===> ESF_SECIFRS_CR_EXTRACT.................................................: ${ESF_SECIFRS_CR_EXTRACT}"
ECHO_LOG "#===> EST_IADPERICASE_DUMMY..................................................: ${EST_IADPERICASE_DUMMY}"
ECHO_LOG "#===> ESF_FI17CLOPER.........................................................: ${ESF_FI17CLOPER}"
ECHO_LOG "#===> ESF_IADPERICASE_I17_INI................................................: ${ESF_IADPERICASE_I17_INI}"
ECHO_LOG "#===> EST_IADPERICASE_I17....................................................: ${EST_IADPERICASE_I17}"

ECHO_LOG "#===> ............ OUTPUT ..................................................."
ECHO_LOG "#===> EST_IADPERICASE_DUMMY_I17..............................................: ${EST_IADPERICASE_DUMMY_I17}"
ECHO_LOG "#===> ESF_IADPERICASE_I17_MERGE..............................................: ${ESF_IADPERICASE_I17_MERGE}"
ECHO_LOG "#============================================================================"






NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES"
if [ ! -f ${EST_IADPERICASE_DUMMY} ]
then
    LAST_FILE=`ls -t ${DFILP}/${ENV_PREFIX}_ESFD5010_IADPERICASE_DUMMY_STD_EBS_*.dat | head -1`
    EXECKSH "cp ${LAST_FILE} ${EST_IADPERICASE_DUMMY}"
fi

NSTEP=${NJOB}_02
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

NSTEP=${NJOB}_03
# FILTER PERIMETER WITH TI17CLOPER
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER WITH TI17CLOPER"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_DUMMY} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FILTERED_EST_IADPERICASE_DUMMY.dat 2000 1"
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

NSTEP=${NJOB}_05
# Extend EST_IADPERICASE with TSECIFRS AND TCR INFO by norm
#-----------------------------------------------------------------------------
#LIBEL="Extend EST_IADPERICASE_DUMMY_EBS with TSECIFRS AND CR INFO by norm"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_02_${IB}_FILTERED_ESF_SECIFRS_CR_EXTRACT.dat 2000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_EST_IADPERICASE_DUMMY_I17.dat 2000 1"
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
#/INFILE ${EST_IADPERICASE_DUMMY} 2000 1 "~"
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

NSTEP=${NJOB}_06
# Extend EST_IADPERICASE with TSECIFRS AND TCR INFO by norm
#-----------------------------------------------------------------------------
LIBEL="Extend EST_IADPERICASE_DUMMY_EBS with TSECIFRS AND CR INFO by norm"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03_${IB}_FILTERED_EST_IADPERICASE_DUMMY.dat 2000 1"
SORT_O="${EST_IADPERICASE_DUMMY_I17} 2000 1"
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


# [001]

NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-INI not in pericase I17 STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADPERICASE_I17_INI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_INI_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       3:1 -  3:, 
		END_NT       4:1 -  4:, 
		SEC_NF       5:1 -  5:, 
		UWY_NF       6:1 -  6:, 
		UW_NT        7:1 -  7:, 
		STD_CTR_NF   3:1 -  3:, 
		STD_END_NT   4:1 -  4:, 
		STD_SEC_NF   5:1 -  5:, 
		STD_UWY_NF   6:1 -  6:, 
		STD_UW_NT    7:1 -  7:,
		ALL_COLS     1:1 -  252: 
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EST_IADPERICASE_I17} 2000 1 "~"
/joinkeys
        STD_CTR_NF,
        STD_END_NT,
        STD_SEC_NF,
        STD_UWY_NF,
        STD_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT




NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT PERICASE INI And STD "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_IADVPERICASE_INI_O.dat 2000 1"
SORT_I2="${EST_IADPERICASE_I17} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_MERGE_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       3:1 -  3:, 
        		END_NT       4:1 -  4:, 
        		SEC_NF       5:1 -  5:, 
       		  UWY_NF       6:1 -  6:, 
        		UW_NT        7:1 -  7: 
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT



## Filter PERICASE MEGE On ssd and esb 

NSTEP=${NJOB}_70
# FILTER PERIMETER WITH TI17CLOPER
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER WITH TI17CLOPER"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_IADVPERICASE_MERGE_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_MERGE_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        SSD_NF                                  1:1 - 1:,
        ESB_CF                                  2:1 - 2:,
        CP_SSD_NF                               1:1 - 1:,
        CP_ACCESB_CF                    				8:1 - 8:,
        PERICASE                             		1:1 - 252:
/joinkeys
        CP_SSD_NF ,
        CP_ACCESB_CF
/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
/joinkeys
        SSD_NF ,
        ESB_CF
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: PERICASE
exit
EOF
SORT

NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
LIBEL=" SORT PERICASE MERGE  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_SORT_IADVPERICASE_MERGE_O.dat 2000 1"
SORT_O="${ESF_IADPERICASE_I17_MERGE} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       3:1 -  3:, 
        		END_NT       4:1 -  4:, 
        		SEC_NF       5:1 -  5:, 
       		  UWY_NF       6:1 -  6:, 
        		UW_NT        7:1 -  7: 
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT




JOBEND
