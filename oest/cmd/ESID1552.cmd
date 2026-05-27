#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS
# nom du script SHELL           : ESID1552.cmd
# date de creation              : 23/10/2015
# auteur                        : Florent
# references des specifications : :spot:29176 Comptabilité Rétro des PNA
#-----------------------------------------------------------------------------
# description
#   Comptabilisation des PNA
#
# Input files
#       EST_FCURCVSN     DFILP
#       EST_FCURCVSNI    DFILP
#       EST_FCURQUOT     DFILP
#       EST_FPLC         DFILP
#       EST_FTRSLNK      DFILI
#       EST_RETPNAGTR    DFILI
#
# Output files modifiées, crées dans ESID1551.cmd
#       EST_DLRNPGTAR    DFILP
#       EST_DLRNPGTR     DFILP
#
# Launch C program ESTC2304
#
# Job launched by ESID1550.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
# historiques des modifications :
#[001] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 


# Call generic functions
. ${DUTI}/fctgen.cmd

#Get input parameters
BALSHEY_NF=$1

# Job Initialisation
JOBINIT

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> BALSHEY_NF ................: ${BALSHEY_NF}"
ECHO_LOG "#===> EST_FCURCVSN ..............: ${EST_FCURCVSN}"
ECHO_LOG "#===> EST_FCURCVSNI..............: ${EST_FCURCVSNI}"
ECHO_LOG "#===> EST_FCURQUOT ..............: ${EST_FCURQUOT}"
ECHO_LOG "#===> EST_FPLC     ..............: ${EST_FPLC}"
ECHO_LOG "#===> EST_FTRSLNK  ..............: ${EST_FTRSLNK}"
ECHO_LOG "#===> EST_RETPNAGTR..............: ${EST_RETPNAGTR}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 1
BALSHEY_NF ${BALSHEY_NF}
GTE_B 0
PRS_CF 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_RETPNAGTR}
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1MAJ_O4.dat
EXECPRG

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTART1_O1.dat
SORT_I2=${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTART1MAJ_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART1_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RETINTAMT_M 41:1 - 41: EN 15/3
/KEYS   SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
        TRNCOD_CF,
        DBLTRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files ${EST_DLRNPGTAR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_40_${IB}_SORT_GTART1_O.dat
SORT_O="${EST_DLRNPGTAR} APPEND"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files 3,4"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTRRT1_O3.dat
SORT_I2=${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTRRT1MAJ_O4.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRRT1_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD 6:1 - 6:, KEY_RETCTR 24:1 - 34:, RETAMT_M 35:1 - 35: EN 15/3, PLC_NT 36:1 - 36:, RETINTAMT_M 41:1 - 41: EN 15/3
/KEYS TRNCOD, KEY_RETCTR, PLC_NT
/SUMMARIZE TOTAL RETAMT_M, TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="Merge with ${EST_DLRNPGTR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_60_${IB}_SORT_GTRRT1_O.dat
SORT_O="${EST_DLRNPGTR} APPEND"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
