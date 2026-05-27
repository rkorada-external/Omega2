#!/bin/ksh
#==============================================================================
#nom de l'application          : Correction fichier LIFSTAREP_PLAN.dat
#nom du source                 : 
#date de creation              : 
#auteur                        : 
#references des specifications : 


# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialise JOB

CHAININIT $0 $DENV/Correction_STAD1520_LIFSTAREP_PLAN.env

NJOB=LIFSTAREP_PLAN

NSTEP=${NJOB}_10
# Si ACCRET = A et ACMTRS = 2534 , ACMTRS = ACMTRS - 1000
#-----------------------------------------------------------------------------
LIBEL="Modification ACMTRS"
AWK_I=${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat
AWK_O=${DFILI}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN_ERR.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{ if( \$11 >= "2000" && \$9 == "A") { print \$0 }}
exit
EOF
AWK

NSTEP=${NJOB}_11
# Si ACCRET = A et ACMTRS = 2534 , ACMTRS = ACMTRS - 1000
#-----------------------------------------------------------------------------
LIBEL="Modification ACMTRS"
AWK_I=${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat
AWK_O=${DFILT}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{ if( \$11 < "2000" ) { print \$0 }}
		{ if( \$11 >= "2000" && \$9 == "R") { print \$0 }}
		{ if( \$11 >= "2000" && \$9 == "A") { \$11 = sprintf("%d",\$11 - 1000) ; print \$0 }}
exit
EOF
AWK

NSTEP=${NJOB}_20
# CUMUL DES MONTANTS PRMNT
#----------------------------------------------------------------------------
LIBEL="CUMUL DES MONTANTS PR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN_O.dat 2000 1"
SORT_O=${DFILT}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN_O1.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  FILLER1       1:1 - 26:,
        FILLER2       32: - 56:,
        CTR_NF        3: -  3: ,
        SEC_NF        5: -  5: EN 3/0,
        UWY_NF        6: -  6: EN 4/0,
        UW_NT         7: -  7: EN 2/0,
        PLC_NT        8: -  8:,
        ACY_NF       10: - 10: EN 4/0,
        ACMTRS_NT    11: - 11:,
        DETTRNCOD_CF 12: - 12:,
        PR1MNT_M     27: - 27: EN 15/3,
        PRMNT_M      28: - 28: EN 15/3,
        PR3MNT_M     29: - 29: EN 15/3,
        PR4MNT_M     30: - 30: EN 15/3,
        PR5MNT_M     31: - 31: EN 15/3,
        CED_NF       32: - 32:
/KEYS CTR_NF,SEC_NF, UWY_NF,PLC_NT,ACY_NF, ACMTRS_NT, DETTRNCOD_CF,CED_NF
/SUMMARIZE  TOTAL PR1MNT_M, TOTAL PRMNT_M, TOTAL PR3MNT_M, TOTAL PR4MNT_M, TOTAL PR5MNT_M
/DERIVEDFIELD PR1MNT_MC PR1MNT_M COMPRESS
/DERIVEDFIELD PRMNT_MC PRMNT_M COMPRESS
/DERIVEDFIELD PR3MNT_MC PR3MNT_M COMPRESS
/DERIVEDFIELD PR4MNT_MC PR4MNT_M COMPRESS
/DERIVEDFIELD PR5MNT_MC PR5MNT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FILLER1, PR1MNT_MC, PRMNT_MC, PR3MNT_MC, PR4MNT_MC, PR5MNT_MC, FILLER2
exit
EOF
SORT

#NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
#LIBEL="CP LIFSTAREP_PLAN ==> LIFSTAREP_PLAN.dat.old"
EXECKSH "cp ${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat ${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat.old"

#NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
#LIBEL="CP LIFSTAREP_PLAN_O1==> LIFSTAREP_PLAN.dat"
EXECKSH "cp ${DFILT}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN_O1.dat ${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat"

JOBEND
