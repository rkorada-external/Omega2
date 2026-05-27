#!/bin/ksh
#=============================================================================
# maj de l'application:          TRANSFERT COREE - Generation GTR
# nom du script SHELL:           ESTM7003.cmd
# revision: $Revision:
# date de creation:              24/02/2006
# auteur:                        M.DJELLOULI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Preparation for technical balance print out
#
# job launched by ESTM7000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#    27/02/2006   M.DJELLOULI   Stockage dans DFILI
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Entry parameters
BLCSHT_D=${1}
BALSHEY_NF=${2}
ESTIM_B=${3}
FORCEBILAN=${4}

# Initialization of the Job
JOBINIT

NSTEP=${NJOB}_10
# Bcp out
#--------------------------------
LIBEL="Transferring table BTRAV..RET_ESTM7002_CONTRATS into file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="select CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,RCL_NF,PLC_NT,RTO_NF,INT_NF,RETPAY_NF,RETKEY_CF,TAUXCESSION FROM BTRAV..RET_ESTM7002_CONTRATS order by CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_RET_ESTM7002_CONTRATS_O.dat
BCP



NSTEP=${NJOB}_20
# MOD003 -  Sort of Last Generated GTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_GTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${NCHAIN}_ESTM7002_GTA_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_GTA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_25
# MOD003 -  Sort of Last Generated GTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_GTA_EST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${NCHAIN}_ESTM7002_GTA_TRANSFP_EST.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_GTA_EST.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_30
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for GTA"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_TRANSFP_GTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTR_TRANSFP_GTAR.dat
export ${PRG}_O2=${DFILI}/${NJOB}_GTR_TRANSFP_GTR.dat
EXECPRG



NSTEP=${NJOB}_35
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for GTA_EST"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_25_${IB}_SORT_TRANSFP_GTA_EST.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTR_TRANSFP_GTAR_EST.dat
export ${PRG}_O2=${DFILI}/${NJOB}_GTR_TRANSFP_GTR_EST.dat
EXECPRG

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_TRANSFP_GTA.dat
RMFIL ${DFILT}/${NJOB}_25_${IB}_SORT_TRANSFP_GTA_EST.dat





NSTEP=${NJOB}_50
# MOD003 -  Sort of Last Generated CURGTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_CURGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${NCHAIN}_ESTM7002_GTA_TRANSFP_CURGTA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_CURGTA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_55
# MOD003 -  Sort of Last Generated CURGTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_CURGTA_EST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${NCHAIN}_ESTM7002_GTA_TRANSFP_CURGTA_EST.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_CURGTA_EST.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_60
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for CURGTA"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_TRANSFP_CURGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTR_TRANSFP_CURGTAR.dat
export ${PRG}_O2=${DFILI}/${NJOB}_GTR_TRANSFP_CURGTR.dat
EXECPRG



NSTEP=${NJOB}_65
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for CURGTA_EST"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_55_${IB}_SORT_TRANSFP_CURGTA_EST.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTR_TRANSFP_CURGTAR_EST.dat
export ${PRG}_O2=${DFILI}/${NJOB}_GTR_TRANSFP_CURGTR_EST.dat
EXECPRG

NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_TRANSFP_CURGTA.dat
RMFIL ${DFILT}/${NJOB}_55_${IB}_SORT_TRANSFP_CURGTA_EST.dat



NSTEP=${NJOB}_80
# MOD003 -  Sort of Last Generated CURGTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_ARCSTATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${NCHAIN}_ESTM7002_ARCSTATGTA_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_ARCSTATGTA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_85
# MOD003 -  Sort of Last Generated GTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_ARCSTATGTA_EST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${NCHAIN}_ESTM7002_ARCSTATGTA_TRANSFP_EST.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_ARCSTATGTA_EST.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_90
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for TRANSFP_ARCSTATGTA"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_TRANSFP_ARCSTATGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_ARCSTATGTR_TRANSFP_ARCSTATGTAR.dat
export ${PRG}_O2=${DFILI}/${NJOB}_ARCSTATGTR_TRANSFP_ARCSTATGTR.dat
EXECPRG



NSTEP=${NJOB}_95
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for TRANSFP_ARCSTATGTA_EST"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_85_${IB}_SORT_TRANSFP_ARCSTATGTA_EST.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_ARCSTATGTR_TRANSFP_ARCSTATGTAR_EST.dat
export ${PRG}_O2=${DFILI}/${NJOB}_ARCSTATGTR_TRANSFP_ARCSTATGTR_EST.dat
EXECPRG

NSTEP=${NJOB}_100
# delete old temporary Data files
#---------------------------------------------------------------
LIBEL="delete old temporary Data files"
RMFIL "${DFILT}/${NJOB}*_${IB}*.dat"

JOBEND
