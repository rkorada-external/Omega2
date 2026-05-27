#!/bin/ksh
#=============================================================================
# nom de l'application          : Pericase
# nom du script SHELL           : ESFD3952.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 23/03/2022
# auteur                        : Bhimasen Karri
#-----------------------------------------------------------------------------
# description : Generate Pericase for Retro with new scope
#-----------------------------------------------------------------------------
# modif
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


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


NSTEP=${NJOB}_05
# FILTER PERIMETER WITH EST_FTHRHLDUWY
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER WITH EST_FTHRHLDUWY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EST_IRDPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF 					1:1 - 1:,
	ESB_CF  				2:1 - 2:,
	LOB_CF					3:1 - 3:,
	CP_SSD_CF 				1:1 - 1:,
	CP_ACCESB_CF  			8:1 - 8:,
	CP_LOB_CF				38:1 - 38:,
	IRDPERICASE				1:1 - 206:,
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
	leftside: IRDPERICASE ,
	rightside: THRHLDUWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Delete duplicate rows"
sort -u ${DFILT}/${NJOB}_05_${IB}_SORT_EST_IRDPERICASE.dat > ${DFILT}/${NSTEP}_${IB}_SORT_EST_IRDPERICASE_O.dat

NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="Sort pericase files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_EST_IRDPERICASE_O.dat 2000 1"
SORT_O="${EST_IRDPERICASE_FILTERED} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF						3:1 - 3:,
	END_NT						4:1 - 4:,
	SEC_NF						5:1 - 5:,
	UWY_NF						6:1 - 6:,
	UW_NT						7:1 - 7:,
	SECACCSTS_CT				77:1 - 77:,
	CTRACCSTS_CT				149:1 -	149:,
	THRHLDUWY_NF				207:1 - 207:,
	IRDPERICASE      			1:1 - 206:
/KEYS   CTR_NF ,
        SEC_NF ,
        UWY_NF ,
        UW_NT ,
		END_NT
/CONDITION COND (UWY_NF >= THRHLDUWY_NF AND SECACCSTS_CT != "9" ) 
/OUTFILE ${SORT_O}
/INCLUDE COND
/REFORMAT 
        IRDPERICASE
exit
EOF
SORT


if [ ${NORME_CF} = "EBS" ] || [ ${IDF_CT} = "I17G_ESFD3950" ] || [ ${IDF_CT} = "I17S_ESFD3950" ]
then

NSTEP=${NJOB}_20
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



NSTEP=${NJOB}_25
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND 
