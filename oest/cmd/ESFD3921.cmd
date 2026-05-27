#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD3921.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 12\04\2021
# auteur                        : Cyril AVINENS
#-----------------------------------------------------------------------------
# description : Generate EBS Pericase for ASSUMED with IFRS Structure
#-----------------------------------------------------------------------------
# modif
# [01] 28/01/2022 Bhimasen 	SPIRA 98794		: NDIC- curency issue
# [02] 06/07/2022 Bhimasen	SPIRA 104855 	: NDIC Internal Assumed
# [03] 08/22/2022 J.B-D 	SPIRA 106362 : Add [ IDF_CT = "I17G_ESFD3920"]
# [04] 01/02/2023 Suraj P 	SPIRA 107762 	: NDIC calculation with No estimates origin portfolio
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters
NORME_CF=$1


NSTEP=${NJOB}_00
LIBEL="MANAGE UNFOUND FILES "

if [ ! -f ${EST_DLCUMGTAAR_PREV} ]
then
    ECHO_LOG "EST_DLCUMGTAAR_PREV=${EST_DLCUMGTAAR_PREV}  does not exist, take an empty file"
    EXECKSH "touch ${EST_DLCUMGTAAR_PREV}"
fi

if [ ! -f ${ESF_GTSII_GLOBAL_CASHFLOW_PREV} ]
then
    ECHO_LOG "ESF_GTSII_GLOBAL_CASHFLOW_PREV=${ESF_GTSII_GLOBAL_CASHFLOW_PREV}  does not exist, take an empty file"
    EXECKSH "touch ${ESF_GTSII_GLOBAL_CASHFLOW_PREV}"
fi



if [ ${NORME_CF} = "EBS" ] || [ ${IDF_CT} = "I17G_ESFD3920" ]
then

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------------
LIBEL="Generate EBS Pericase for ASSUMED with IFRS Structure"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_EBS} 1000 1"
SORT_O="${EST_IADPERICASE} 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	PERICASE_EBS			1:1 	- 209:
/DERIVEDFIELD EMPTY_IFRS_FIELDS "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
	PERICASE_EBS,
	EMPTY_IFRS_FIELDS
exit
EOF
SORT

fi

NSTEP=${NJOB}_10
# FILTER PERIMETER WITH EST_FTHRHLDUWY
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER WITH EST_FTHRHLDUWY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EST_IADPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF 					1:1 - 1:,
	ESB_CF  				2:1 - 2:,
	LOB_CF					3:1 - 3:,
	CP_SSD_CF 				1:1 - 1:,
	CP_ACCESB_CF  			8:1 - 8:,
	CP_LOB_CF				38:1 - 38:,
	IADPERICASE				1:1 - 252:,
	THRHLDUWY_NF 			5:1 - 5:
/joinkeys 
	CP_SSD_CF ,
	CP_ACCESB_CF ,
	CP_LOB_CF 
/INFILE ${EST_FTHRHLDUWY} 1000 1 "~"
/joinkeys 
	SSD_CF ,
	ESB_CF ,
	LOB_CF 
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside: IADPERICASE ,
	rightside: THRHLDUWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="Delete duplicate rows"
sort -u ${DFILT}/${NJOB}_10_${IB}_SORT_EST_IADPERICASE.dat > ${DFILT}/${NSTEP}_${IB}_SORT_EST_IADPERICASE_O.dat

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Sort pericase files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_EST_IADPERICASE_O.dat 2000 1"
SORT_O="${EST_IADPERICASE_FILTERED} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF						3:1 - 3:,
	END_NT						4:1 - 4:,
	SEC_NF						5:1 - 5:,
	UWY_NF						6:1 - 6:,
	UW_NT						7:1 - 7:,
	CED_NF						12:1 - 12:,
	CTRRET_B					20:1 - 20:,
	SECACCSTS_CT				77:1 - 77:,
	UWORG_CF					119:1 - 119:,
	CTRACCSTS_CT				149:1 -	149:,
	THRHLDUWY_NF				253:1 - 253:,
	IADPERICASE      			1:1 - 252:
/KEYS   CTR_NF ,
        SEC_NF ,
        UWY_NF ,
        UW_NT ,
		END_NT
/CONDITION COND (UWY_NF >= THRHLDUWY_NF AND SECACCSTS_CT != "9" AND CTRRET_B = "0" AND (UWORG_CF != "253" OR (UWORG_CF = "253" AND CED_NF = "38466"))) 
/OUTFILE ${SORT_O}
/INCLUDE COND
/REFORMAT 
        IADPERICASE
exit
EOF
SORT


NSTEP=${NJOB}_25
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND 
