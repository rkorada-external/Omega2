#!/bin/ksh
#=============================================================================
# nom de l'application          : Merge RAD and RAP
# nom du script SHELL           : ESFD3623.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 01\11\2024
# auteur                        : David Teixeira
# references des specifications :
#-----------------------------------------------------------------------------
# description
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW_RAD............: ${ESF_GTSII_GLOBAL_CASHFLOW_RAD}"
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW_RAP............: ${ESF_GTSII_GLOBAL_CASHFLOW_RAP}"
ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW................: ${ESF_GTSII_GLOBAL_CASHFLOW}"
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_00
LIBEL="MANAGE UNFOUND FILES"
if [ ! -f ${ESF_GTSII_GLOBAL_CASHFLOW_RAD} ]
then
    ECHO_LOG "ESF_GTSII_GLOBAL_CASHFLOW_RAD=${ESF_GTSII_GLOBAL_CASHFLOW_RAD}  does not exist, take an empty file"
    EXECKSH "touch ${ESF_GTSII_GLOBAL_CASHFLOW_RAD}"
fi

if [ ! -f ${ESF_GTSII_GLOBAL_CASHFLOW_RAP} ]
then
    ECHO_LOG "ESF_GTSII_GLOBAL_CASHFLOW_RAP=${ESF_GTSII_GLOBAL_CASHFLOW_RAP}  does not exist, take an empty file"
    EXECKSH "touch ${ESF_GTSII_GLOBAL_CASHFLOW_RAP}"
fi


NSTEP=${NJOB}_05
# Begin Overwrite
#-----------------------------------------------------------------------------
LIBEL="Overwrite the GTSII GLOBAL CASHFLOW RAP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_GLOBAL_CASHFLOW_RAP} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_GLOBAL_CASHFLOW.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
    COL_1_51         1:1 - 51:,
    COL_53_124       53:1 - 124:
/DERIVEDFIELD PATCAT_CT_NEW "RAD~"
/OUTFILE ${SORT_O} overwrite
/REFORMAT COL_1_51, PATCAT_CT_NEW, COL_53_124
exit
EOF
SORT


NSTEP=${NJOB}_10
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Merge and Sort the GTSII GLOBAL CASHFLOW"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_GLOBAL_CASHFLOW_RAD} 2000 1"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_SORT_GTSII_GLOBAL_CASHFLOW.dat 2000 1"
SORT_O="${ESF_GTSII_GLOBAL_CASHFLOW}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
    SSD_CF            1:1 -  1:EN,
    ESB_CF            2:1 -  2:EN,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:EN,
    SEC_NF           10:1 - 10:EN,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:EN,
    CUR_CF           18:1 - 18:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:EN,
    RETSEC_NF        26:1 - 26:EN,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:EN,
    RETCUR_CF        34:1 - 34:,
    PLC_NT           36:1 - 36:,
    ACMTRS_NT        42:1 - 42:,
    ACMCUR_CF        44:1 - 44:,
    TYP_CT           49:1 - 49:,
    NORME_CF         50:1 - 50:,
    PATCAT_CT        52:1 - 52:,
    ACMTRS3_NT       124:1 - 124:
/KEYS   
    SSD_CF,
    ESB_CF,
    CTR_NF, 
    END_NT,
    SEC_NF,
    UWY_NF,
    UW_NT,
    RETCTR_NF,
    RETEND_NT,
    RETSEC_NF,
    RTY_NF,
    RETUW_NT,
    PLC_NT,
    CUR_CF,
    ACMCUR_CF,
    RETCUR_CF,
    TYP_CT,
    NORME_CF,
    PATCAT_CT,
    ACMTRS_NT,
    ACMTRS3_NT
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT

JOBEND

