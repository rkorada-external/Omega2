#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESCJ0664.cmd
# revision                      : 
# date de creation              : 06/09/2021
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Extraction quatidienne des  fichiers
#
# job launched by ESCJ0000.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Creation	    : 
#Auteur         : M.NAJI
#Date           : 06/09/2021
#Version        : 1.0
#Description    :Extraction quatidienne des  fichiers
#===============================================================================
#[001] 06/09/2021  :spira:91532 Création

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
OPTION=Q
SEGTYP_CT=A




# Parameters

export LIMITINF_D=$((${CRE_D}-50000))

################################
# Compute of placed share rate #
################################

# Bilan en cours
################

NSTEP=${NJOB}_05
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLACEMT0}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FPLACUMUL_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4: EN,
        RETSEC_NF 5:1 - 5: EN,
        RTY_NF 6:1 - 6: EN,
        RETUW_NT 7:1 - 7: EN,
        SSDRTO_B 15:1 - 15:,
        RETSIGSHA_R 16:1 - 16:EN 1/8
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      SSDRTO_B
/SUMMARIZE TOTAL RETSIGSHA_R
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort of perimeter file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        SECACCSTS_CT 77:1 - 77:,
        CRTVRSINC_D 159:1 - 159:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION CLOSEDACC (SECACCSTS_CT EQ "9" AND CRTVRSINC_D >= "${LIMITINF_D}") or SECACCSTS_CT != "9"
/OUTFILE ${SORT_O}
   /INCLUDE CLOSEDACC
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCESSION0}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCESSION_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:
/KEYS CTR_NF, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new cession file..."
PRG=ESTC2301
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_15_${IB}_SORT_FCESSION_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FCES_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETNP_SEGMENT_O.dat   #[003]
EXECPRG

NSTEP=${NJOB}_30
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_20_${IB}_ESTC2301_FCES_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCES_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 6:1 - 6:, RETEND_NT 7:1 - 7: EN, RETSEC_NF 8:1 - 8: EN, RTY_NF 9:1 - 9: EN, RETUW_NT 10:1 - 10: EN
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_40
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Synchro between cessions and placements files"
PRG=ESTC3601
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_FPLACUMUL_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_FCES_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSHARE_O.dat
EXECPRG



NSTEP=${NJOB}_50
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_40_${IB}_ESTC3601_FSHARE_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCEDBIL_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2: EN, SEC_NF 3:1 - 3: EN, UWY_NF 4:1 - 4: EN, UW_NT 5:1 - 5: EN, SHARERI_R 6:1 - 6: EN 1/8, SHARERE_R 7:1 - 7: EN 1/8
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/SUMMARIZE TOTAL SHARERI_R, TOTAL SHARERE_R
exit
EOF
SORT

# Bilan anterieurs
##################

NSTEP=${NJOB}_60
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLCANT} # modif à confirmer ${EST_FPLCANT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FPLACUMUL_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 3:1 - 3:, RETEND_NT 4:1 - 4: EN, RETSEC_NF 5:1 - 5: EN, RTY_NF 6:1 - 6: EN, RETUW_NT 7:1 - 7: EN, SSDRTO_B 15:1 - 15:, RETSIGSHA_R 16:1 - 16:EN 1/8
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, SSDRTO_B
/SUMMARIZE TOTAL RETSIGSHA_R
exit
EOF
SORT

NSTEP=${NJOB}_65
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort of cession file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCESANT} # modif à confirmer ${EST_FCESANT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCESANT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 6:1 - 6:, RETEND_NT 7:1 - 7: EN, RETSEC_NF 8:1 - 8: EN, RTY_NF 9:1 - 9: EN, RETUW_NT 10:1 - 10: EN
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_70
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Synchro between cessions and placements files"
PRG=ESTC3601
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_FPLACUMUL_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_65_${IB}_SORT_FCESANT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSHARE_O.dat
EXECPRG


NSTEP=${NJOB}_80
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_70_${IB}_ESTC3601_FSHARE_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCEDANT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2: EN, SEC_NF 3:1 - 3: EN, UWY_NF 4:1 - 4: EN, UW_NT 5:1 - 5: EN, SHARERI_R 6:1 - 6: EN 1/8, SHARERE_R 7:1 - 7: EN 1/8
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/SUMMARIZE TOTAL SHARERI_R, TOTAL SHARERE_R
exit
EOF
SORT


###############################################
# Generation of ultimates and accounting file #
###############################################


NSTEP=${NJOB}_90
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of the ultimates file"
PRG=ESTC3603
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
OPTION ${OPTION}
SEGTYP_CT A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IADPERICASE0}
export ${PRG}_I2=${EST_FBSEGEST}
export ${PRG}_I3=${EST_FCTRGRO0}
export ${PRG}_I4=${DFILT}/${NCHAIN}_ESCJ0661_295_${IB}_SORT_FUNDSTA0_O.dat 
export ${PRG}_I5=${EST_FCTRULT}
export ${PRG}_I6=${EST_FAPR0}
export ${PRG}_I7=${EST_FAMPROT0}
export ${PRG}_I8=${EST_IADPERIFCT}
export ${PRG}_I9=${DFILT}/${NJOB}_50_${IB}_SORT_FCEDBIL_O.dat
export ${PRG}_I10=${DFILT}/${NJOB}_80_${IB}_SORT_FCEDANT_O.dat
export ${PRG}_I11=${EST_FSOBBLOB}
export ${PRG}_I12=${EST_FCURQUOT}
export ${PRG}_I13=${EST_FCPLACC}
export ${PRG}_O1=${EST_FULTIMATES}  #${DFILT}/${NSTEP}_${IB}_${PRG}_FULTIMATES_O.dat #[008]
EXECPRG

JOBEND





























