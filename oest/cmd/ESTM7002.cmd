#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - INVENTAIRE
# nom du script SHELL:           ESTM7002.cmd
# revision: $Revision:           1.1  $
# date de creation:              27/02/2006
# auteur:                        M. DJELLOULI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Transfert Coree Vie
#
# job launched by ESTM7000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#    27/02/2006     M.DJELLOULI  Calqué sur JOB initial ESTM7001.cmd
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

NSTEP=${NJOB}_05
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Extraction des tables"
PRG=ESTX7001
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRCROSSREF.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_CLMCROSSREF.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_DETTRS.dat
EXECPRG

NSTEP=${NJOB}_10
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from ${PCH}ESIX7000_GTA.dat"
PRG=ESTM7001
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILP}/${PCH}ESIX7000_GTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_ESTX7001_CTRCROSSREF.dat
export ${PRG}_I3=${DFILT}/${NJOB}_05_${IB}_ESTX7001_CLMCROSSREF.dat
export ${PRG}_I4=${DFILT}/${NJOB}_05_${IB}_ESTX7001_DETTRS.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTA_TRANSFP.dat
export ${PRG}_O2=${DFILI}/${NJOB}_GTA_TRANSFP_EST.dat
export ${PRG}_O3=${DFILI}/${NJOB}_GTA_CTR_NOT_FOUND.dat
export ${PRG}_O4=${DFILI}/${NJOB}_GTA_CLM_NOT_FOUND_EST.dat
export ${PRG}_O5=${DFILI}/${NJOB}_GTA_RETCTR_EXCLUS.dat
EXECPRG

NSTEP=${NJOB}_15
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from ${PCH}ESIX7000_CURGTA.dat"
PRG=ESTM7001
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILP}/${PCH}ESIX7000_CURGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_ESTX7001_CTRCROSSREF.dat
export ${PRG}_I3=${DFILT}/${NJOB}_05_${IB}_ESTX7001_CLMCROSSREF.dat
export ${PRG}_I4=${DFILT}/${NJOB}_05_${IB}_ESTX7001_DETTRS.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTA_TRANSFP_CURGTA.dat
export ${PRG}_O2=${DFILI}/${NJOB}_GTA_TRANSFP_CURGTA_EST.dat
export ${PRG}_O3=${DFILI}/${NJOB}_GTA_CTR_NOT_FOUND_CURGTA.dat
export ${PRG}_O4=${DFILI}/${NJOB}_GTA_CLM_NOT_FOUND_CURGTA.dat
export ${PRG}_O5=${DFILI}/${NJOB}_GTA_RETCTR_EXCLUS_CURGTA.dat
EXECPRG

NSTEP=${NJOB}_20
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from ${PCH}ESIX7000_ARCSTATGTA.dat"
PRG=ESTM7001
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_ESTX7001_CTRCROSSREF.dat
export ${PRG}_I3=${DFILT}/${NJOB}_05_${IB}_ESTX7001_CLMCROSSREF.dat
export ${PRG}_I4=${DFILT}/${NJOB}_05_${IB}_ESTX7001_DETTRS.dat
export ${PRG}_O1=${DFILI}/${NJOB}_ARCSTATGTA_TRANSFP.dat
export ${PRG}_O2=${DFILI}/${NJOB}_ARCSTATGTA_TRANSFP_EST.dat
export ${PRG}_O3=${DFILI}/${NJOB}_ARCSTATGTA_CTR_NOT_FOUND.dat
export ${PRG}_O4=${DFILI}/${NJOB}_ARCSTATGTA_CLM_NOT_FOUND.dat
export ${PRG}_O5=${DFILI}/${NJOB}_ARCSTATGTA_RETCTR_EXCLUS.dat
EXECPRG

NSTEP=${NJOB}_25
# Begin ISQL
#------------------------------------------------------------------------------
LIBEL="Update TRFACCSTS_CT = 41 apres TRANSFERTS"
ISQL_BASE="BTRT"
ISQL_QRY="update BTRT..TRFCROSSREF
             set TRFACCSTS_CT = 51
           from BTRT..TRFCROSSREF where TRFACCSTS_CT = 41"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL

NSTEP=${NJOB}_30
# delete old temporary Data files
#---------------------------------------------------------------
LIBEL="delete old temporary Data files"
RMFIL "${DFILT}/${NJOB}*_${IB}*.dat"

JOBEND
