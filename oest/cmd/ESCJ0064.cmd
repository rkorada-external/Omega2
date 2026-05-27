#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATION - INVENTAIRE
# nom du script SHELL		: ESCJ0064.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 23/06/2004
# auteur			: J. Ribot
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#  This chain get TL files from the estimation chain ESID2020
#-----------------------------------------------------------------------------
# historiques des modifications
#  13/01/2005    J. Ribot        ajout 'CRE_D DESCENDING' step25
#[001] 28/07/2014 ABJ  spot:25773 Taille Fichier. 
#[001] 30/08/2014 R. BEN EZZINE  spot:25773 Format du Fichier LIFEST.
#[002] 04/09/2014 R. CASSIS  spot:25773 grow record size in sort step
#[003] 07/10/2014 R. BEN EZZINE  spot:25773 ajout de DETTRNCOD et GAAP dans le critère.
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Job Initialisation
JOBINIT


# Get parameters
DBCLO_D=$1
CRE_D=$2

NSTEP=${NJOB}_10
#---------------------------------------------------------------------------
LIBEL="Get files from directories and merge them"
GET_FILES_DIR=${REMOTE_SITE}
GET_FILES_PREFIX=${EXTCHAIN_LIFE}
GET_FILES_MERGE="YES"
GET_FILES_O=${DFILT}/${NSTEP}_${IB}_LIFEST_O.dat
GET_FILES

gzip -c ${DFILT}/${NSTEP}_${IB}_LIFEST_O.dat > ${DFILT}/${NJOB}_010_LIFEST_O.dat.gz

#[001]
NSTEP=${NJOB}_15
#---------------------------------------------------------------------------
LIBEL="Screening and sorting received file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${NJOB}_10_${IB}_LIFEST_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 -  1: EN,
        CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        PRS_CF 9:1 - 9:,
	    	ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3,
        ORICOD_LS 31:1 - 31:,
        CLOPRD 48:1 - 48:,
        DBCLO_D 49:1 - 49:,
        CRE2_D 50:1 - 50:,
        ORGSSD_CF 51:1 - 51:
/CONDITION CURRENT_PRD CLOPRD EQ "${CLOPRD}"
/KEYS CTR_NF, SEC_NF, UWY_NF, ACY_NF, ACMTRS_NT, CRE_D DESCENDING, CRE2_D DESCENDING,
      ORICOD_LS, ORGSSD_CF, BALSHEY_NF, BALSHTMTH_NF, DBCLO_D DESCENDING
/INCLUDE CURRENT_PRD
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat > ${DFILT}/${NJOB}_015_SORT_LIFEST_O.dat.gz

NSTEP=${NJOB}_20
#---------------------------------------------------------------------------
LIBEL="Screening and sorting old file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${EST_LIFEP} 512 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEP_O.dat 512 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 -  1: EN,
        CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        PRS_CF 9:1 - 9:,
	    	ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3,
        ORICOD_LS 31:1 - 31:,
        CLOPRD 48:1 - 48:,
        DBCLO_D 49:1 - 49:,
        CRE2_D 50:1 - 50:,
        ORGSSD_CF 51:1 - 51:
/CONDITION CURRENT_PRD CLOPRD EQ "${CLOPRD}"
/KEYS CTR_NF, SEC_NF, UWY_NF, ACY_NF, ACMTRS_NT, CRE_D DESCENDING, CRE2_D DESCENDING, CUR_CF, ESTMNT_M,
      ORICOD_LS, ORGSSD_CF, BALSHEY_NF, BALSHTMTH_NF, DBCLO_D DESCENDING
/INCLUDE CURRENT_PRD
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEP_O.dat > ${DFILT}/${NJOB}_020_SORT_LIFEP_O.dat.gz

#[001]
NSTEP=${NJOB}_25
#---------------------------------------------------------------------------
LIBEL="Merging files and sorting the result"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_LIFEST_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_20_${IB}_SORT_LIFEP_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_MLIFEP_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 -  1: EN,
        CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        PRS_CF 9:1 - 9:,
	    	ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3,
        ORICOD_LS 31:1 - 31:,
        CLOPRD 48:1 - 48:,
        DBCLO_D 49:1 - 49:,
        CRE2_D 50:1 - 50:,
        ORGSSD_CF 51:1 - 51:
/CONDITION CURRENT_PRD CLOPRD EQ "${CLOPRD}"
/KEYS CTR_NF, SEC_NF, UWY_NF, ACY_NF, ACMTRS_NT, CRE_D DESCENDING, CRE2_D, CUR_CF, ESTMNT_M,
      ORICOD_LS, ORGSSD_CF, BALSHEY_NF, BALSHTMTH_NF, DBCLO_D
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_25_${IB}_SORT_MLIFEP_O.dat > ${DFILT}/${NJOB}_025_SORT_MLIFEP_O.dat.gz

#[001]
#[003]
NSTEP=${NJOB}_30
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_MLIFEP_O.dat 1000 1"
SORT_O=${EST_LIFEP}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF        1:1 -  1: EN,
        CTR_NF        2:1 - 2:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        ACY_NF        7:1 - 7:,
        PRS_CF        9:1 - 9:,
	    ACMTRS_NT    10:1 - 10:,
        BALSHEY_NF   11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF       13:1 - 13:,
        ESTMNT_M     14:1 - 14:EN 15/3,
        DETTRNCOD_CF 20:1 - 20:,
		GAAP_NF      22:1 - 22:,
        ORICOD_LS    31:1 - 31:,
        CLOPRD       48:1 - 48:,
        DBCLO_D      49:1 - 49:,
        CRE2_D       50:1 - 50:,
        ORGSSD_CF    51:1 - 51:
/CONDITION CURRENT_PRD CLOPRD EQ "${CLOPRD}"
/KEYS CTR_NF, SEC_NF, UWY_NF, ACY_NF, ACMTRS_NT, DETTRNCOD_CF, GAAP_NF, CUR_CF,
      ORICOD_LS, ORGSSD_CF, BALSHEY_NF, BALSHTMTH_NF
/SUM
/STABLE
exit
EOF
SORT

gzip -c ${EST_LIFEP} > ${DFILT}/${NJOB}_030_SUM_MLIFEP.dat.gz

NSTEP=${NJOB}_35
# Begin rm
#------------------------------------------------------------------------------
LIBEL="Remove temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

