#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Comptabilisation des ecritures de services IFRS17 Life
#                                 ESFD1803 is checking th SAS Projection file and compute all files in input in one permanent file
#				  
# nom du script SHELL		: ESFD1803.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 23/12/2024
# auteur			: S.Behague
# references des specifications	: BPR-EST-920810
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#-----------------------------------------------------------------------------
# Input files
#       EST_FACCSUP       DFILI
#       EST_FCES                  DFILP
#       EST_FCURCVSNI     DFILI
#       EST_FCURQUOT              DFILP
#       EST_FDETTRS       DFILI
#       EST_FPLC                  DFILP
#       EST_FRETTRF       DFILI
#
# Output files
#       EST_DLSGTAA       DFILI
#       EST_DLSGTAR       DFILI
#       EST_DLSGTR        DFILI
#
# Job launched by ESFD1800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# [001] 23/12/2024 S.Behague : SPIRA 111434 - [OMEGA Life] FWH - Accrual adjustment
# [002] 21/05/2025 sbehague: SPIRA 113027 - FWH accrual complement issue
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Job Initialisation
JOBINIT


#Get input parameters
CLODAT_D=$1
BALSHEY_NF=$2
NORME=`echo $3 | cut -d"_" -f1`
FILE=$4
FILENAME=`basename ${FILE}`


ISFWH=`echo ${FILENAME} | cut -d"_" -f3`
SSD=`echo ${FILENAME} | cut -d"_" -f4`
ESB=`echo ${FILENAME} | cut -d"_" -f5`
ISCSMENG=`echo ${FILENAME} | cut -d"_" -f6 | awk -F"I17" '{ print $1 }'`
CLODAT=`echo ${FILENAME} | cut -d"_" -f7`

echo "                 Fichier  -${FILENAME}-
                 ISFWH    -${ISFWH}-
                 SSD      -${SSD}-
                 ESB      -${ESB}-
                 ISCSMENG -${ISCSMENG}-
                 CLODAT   -${CLODAT}-${CLODAT_D}
                 "

NSTEP=${NJOB}_10_${SSD}_${ESB}
#------------------------------------------------------------------------------
LIBEL="Ckeck file's name"
if [ "X${ISFWH}" != "XFWH" ] || [ "X${ISCSMENG}" != "XCSMENG" ] || [ "X${CLODAT}" != "X${CLODAT_D}" ] || [ "X${SSD}" = "X" ] || [ "X${ESB}" = "X" ]
then
  ECHO_LOG "File's name <${FILENAME}> is incorrect"
  EXECKSH "mv ${FILE} ${DTRANSFER}/${REMOTE_SITE}/fromsave/${FILENAME}.INCORRECT_NAME"
JOBEND
fi

#EXECKSH "cp ${FILE} ${DFILT}/${NJOB}_10_${SSD}_${ESB}_${IB}_INPUT_SAS_FILE.dat"
#---- Effacement d'entete du fichier projection
cat ${FILE} | grep -v ROW_NUMBER > ${DFILT}/${NJOB}_10_${SSD}_${ESB}_${IB}_INPUT_SAS_FILE.dat

EXECKSH "mv ${FILE} ${DTRANSFER}/${REMOTE_SITE}/fromsave/"

NSTEP=${NJOB}_20_${SSD}_${ESB}
#------------------------------------------------------------------------------
LIBEL="Ckeck mandatory fields"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${SSD}_${ESB}_${IB}_INPUT_SAS_FILE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_INPUT_SAS_FILE_FIELDS_OK.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_INPUT_SAS_FILE_MISSING_MANDATORY_FIELDS.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PROJCTR_NF         12:1 -  12:,
        PROJSEC_NF         13:1 -  13:,
        PROJTRNCOD_CF      18:1 -  18:,
        PROJCUR_CF         19:1 -  19:,
        PROJAMT_M          20:1 -  20:,
        ALLCOLS             1:1 -  24:
/CONDITION FIELDS ( PROJCTR_NF NE "" ) AND ( PROJSEC_NF NE "" ) AND ( PROJTRNCOD_CF NE "" ) AND ( PROJCUR_CF NE "" ) AND ( PROJAMT_M NE "" )
/OUTFILE ${SORT_O}
/INCLUDE FIELDS
/OUTFILE ${SORT_O2}
/OMIT FIELDS
exit
EOF
SORT


NSTEP=${NJOB}_25_${SSD}_${ESB}
#------------------------------------------------------------------------------
LIBEL="Moving file with missing mandatory fields"
if [ -s ${DFILT}/${NJOB}_20_${SSD}_${ESB}_${IB}_INPUT_SAS_FILE_MISSING_MANDATORY_FIELDS.dat ]
then
	EXECKSH "mv ${DFILT}/${NJOB}_20_${SSD}_${ESB}_${IB}_INPUT_SAS_FILE_MISSING_MANDATORY_FIELDS.dat ${DTRANSFER}/${REMOTE_SITE}/fromsave/${FILENAME}.MISSING_MANDATORY_FIELDS"
fi


NSTEP=${NJOB}_30_${SSD}_${ESB}
#-----------------------------------------------------------------------------
LIBEL="Merge PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE} 1000 1"
SORT_I2="${EST_IRDVPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IARDVPERICASE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PER_SSD_CF          1:1 -   1:,
        PER_CTR_NF          3:1 -   3:,
        PER_SEC_NF          5:1 -   5:,
        PER_UWY_NF          6:1 -   6:,
        PER_ESB_CF          8:1 -   8:
/KEYS   PER_CTR_NF,
        PER_SEC_NF,
        PER_UWY_NF
/CONDITION CONDSSD ( PER_SSD_CF = "${SSD}" ) AND ( PER_ESB_CF = "${ESB}" )
/OUTFILE ${SORT_O}
/INCLUDE CONDSSD
exit
EOF
SORT


NSTEP=${NJOB}_40_${SSD}_${ESB}
#------------------------------------------------------------------------------
LIBEL="Merge Projection file to check with PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${SSD}_${ESB}_${IB}_INPUT_SAS_FILE_FIELDS_OK.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_INPUT_SAS_FILE_PERICASE_OK.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PROJCTR_NF         12:1 -  12:,
        PROJSEC_NF         13:1 -  13:,
        PROJUWY_NF         14:1 -  14:,
        PER_CTR_NF          3:1 -   3:,
        PER_SEC_NF          5:1 -   5:,
        PER_UWY_NF          6:1 -   6:,
        PER_CUR_CF         51:1 -  51:,
        ALLCOLS             1:1 -  24:
/joinkeys
        PROJCTR_NF,
        PROJSEC_NF,
        PROJUWY_NF
/INFILE ${DFILT}/${NJOB}_30_${SSD}_${ESB}_${IB}_SORT_IARDVPERICASE.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF,
        PER_SEC_NF,
        PER_UWY_NF
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: ALLCOLS
exit
EOF
SORT


NSTEP=${NJOB}_40Bis_${SSD}_${ESB}
#------------------------------------------------------------------------------
LIBEL="Merge Projection file to check with PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${SSD}_${ESB}_${IB}_INPUT_SAS_FILE_FIELDS_OK.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_INPUT_SAS_FILE_PERICASE_KO.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PROJCTR_NF         12:1 -  12:,
        PROJSEC_NF         13:1 -  13:,
        PROJUWY_NF         14:1 -  14:,
        PER_CTR_NF          3:1 -   3:,
        PER_SEC_NF          5:1 -   5:,
        PER_UWY_NF          6:1 -   6:,
        PER_CUR_CF         51:1 -  51:,
        ALLCOLS             1:1 -  24:
/joinkeys
        PROJCTR_NF,
        PROJSEC_NF,
        PROJUWY_NF
/INFILE ${DFILT}/${NJOB}_30_${SSD}_${ESB}_${IB}_SORT_IARDVPERICASE.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF,
        PER_SEC_NF,
        PER_UWY_NF
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: ALLCOLS
exit
EOF
SORT


NSTEP=${NJOB}_42_${SSD}_${ESB}
#------------------------------------------------------------------------------
LIBEL="Moving file with CTR not present in PERICASE"
if [ -s ${DFILT}/${NJOB}_40Bis_${SSD}_${ESB}_${IB}_INPUT_SAS_FILE_PERICASE_KO.dat ]
then
	EXECKSH "mv ${DFILT}/${NJOB}_40Bis_${SSD}_${ESB}_${IB}_INPUT_SAS_FILE_PERICASE_KO.dat ${DTRANSFER}/${REMOTE_SITE}/fromsave/${FILENAME}.NOT_IN_PERICASE"
fi


NSTEP=${NJOB}_50_${SSD}_${ESB}
#------------------------------------------------------------------------------
LIBEL="Delete SSD/ESB from perm file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SAS_PROJECTION} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SAS_PROJECTION.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PROJSSD_CF         10:1 -  10:,
        PROJESB_CF         11:1 -  11:
/CONDITION CONDSSD ( PROJSSD_CF = "${SSD}" ) AND ( PROJESB_CF = "${ESB}" )
/OUTFILE ${SORT_O}
/OMIT CONDSSD
exit
EOF
SORT


NSTEP=${NJOB}_60_${SSD}_${ESB}
#------------------------------------------------------------------------------
LIBEL="Insert SSD/ESB into perm file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${SSD}_${ESB}_${IB}_INPUT_SAS_FILE_PERICASE_OK.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_50_${SSD}_${ESB}_${IB}_SAS_PROJECTION.dat 1000 1"
SORT_O="${EST_SAS_PROJECTION}"
INPUT_TEXT ${SORT_CMD} <<EOF
/OUTFILE ${SORT_O} 
exit
EOF
SORT

JOBEND

