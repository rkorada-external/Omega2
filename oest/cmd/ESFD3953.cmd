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
# [01] 16/10/2024 DaD - Spira : 111562 : Add AEs into NDIC Cash computation
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#======================================================================"
ECHO_LOG "#===> ............ INPUT .............................................."
ECHO_LOG "#===> EST_FPLATXCUMALL.................................................: ${EST_FPLATXCUMALL}"
ECHO_LOG "#===> EST_FBOPRSLNK_TXT................................................: ${EST_FBOPRSLNK_TXT}"
ECHO_LOG "#===> ESF_DLSGTAR......................................................: ${ESF_DLSGTAR}"
ECHO_LOG "#===> ............ OUTPUT ............................................."
ECHO_LOG "#===> ESF_DLSGTAR_FILTERED.............................................: ${ESF_DLSGTAR_FILTERED}"
ECHO_LOG "#======================================================================"



# T_ESFD5010_FPLATXCUMALL0_EBS_PO_20241231.dat

NSTEP=${NJOB}_05
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Summarizing FPLATXCUMALL file by RETCTR_NF, RETRTY_NF, RETSEC_NF, PLC_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLATXCUMALL}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUMALL.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    RETCTR_NF 1:1 - 1:,
    RETSEC_NF 2:1 - 2:EN,
    RETRTY_NF 3:1 - 3:,
    PLC_NT    4:1 - 4:EN
/KEYS RETCTR_NF, RETRTY_NF, RETSEC_NF, PLC_NT
/SUM
/STABLE
exit
EOF
SORT 


NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Sort ESF_DLSGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLSGTAR} 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR.dat 2000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
    TRNCOD_CF         6:1 -  6:,
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:EN,
    SEC_NF           10:1 - 10:EN,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:EN,
    CUR_CF           18:1 - 18:,
    AMT_M            19:1 - 19:EN 15/3,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:EN,
    RETSEC_NF        26:1 - 26:EN,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:EN,
    RETCUR_CF        34:1 - 34:,
    RETAMT_M         35:1 - 35:EN 15/3,
    PLC_NT           36:1 - 36:,
    RTO_NF           37:1 - 37:,
    RETINTAMT_M      41:1 - 41:EN 15/3,
    FILLER1           1:1 - 18:,
    FILLER2          20:1 - 34:,
    FILLER3          36:1 - 40:,
    FILLER4          42:1 - 64:
/KEYS   
    RETCTR_NF,
    RTY_NF,
    RETSEC_NF,
    PLC_NT,
    RETEND_NT,
    RETUW_NT,
    RETCUR_CF,
    RTO_NF,
    TRNCOD_CF,
    CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
    UW_NT,
    CUR_CF
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,AMT_MC,FILLER2,RETAMT_MC,FILLER3,RETINTAMT_MC,FILLER4
exit
EOF
SORT


NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="AGREGATES retro I17 EA allocation by placement"
PRG=ESTC1052
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_FPLATXCUMALL.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAR.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR.dat
EXECPRG 

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Filter DLSGTAR by placement with EST_FBOPRSLNK_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTC1052_DLSGTAR.dat 2000 1"
SORT_O="${ESF_DLSGTAR_FILTERED} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
    ACMTRSL3_NT     5:1 - 5:,
	TRNCOD_CF       6:1 - 6:,
    DETTRS_CF       9:1 - 9:,
    COL_1_64        1:1 - 64:
/JOINKEYS
	TRNCOD_CF
/INFILE ${EST_FBOPRSLNK_TXT} 2000 1 "~"
/JOINKEYS 
	DETTRS_CF
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside: COL_1_64, rightside: ACMTRSL3_NT
exit
EOF
SORT


NSTEP=${NJOB}_25
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND 
