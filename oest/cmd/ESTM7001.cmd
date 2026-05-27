#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - INVENTAIRE
# nom du script SHELL:           ESTM7001.cmd
# revision: $Revision:           1.1  $
# date de creation:              10/1999
# auteur:                        J.Ribot
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Preparation for technical balance print out
#
# job launched by EST7000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#    18/08/2003     Roger Cassis    prise en compte des 2 dates parametres du .prm
#    07/01/2004     Roger Cassis    Ajout parametre ESTIM_B pour traiter les postes estimations
#    21/01/2004     Roger Cassis    Ajout fichier Estime en sortie dans execution ESTM7001
#                                   qui contient les mouvements d'origine avec montants inverses
#    20/02/2006     M.DJELLOULI    Flag FORCEBILAN Forcé Bilan à à 31/12/N-1 (1=Oui par Défaut / 0= Bilan N préservé)
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
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TRANSFP_GTA.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_TRANSFP_GTA_EST.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_CTR_NOT_FOUND.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_CLM_NOT_FOUND.dat
export ${PRG}_O5=${DFILT}/${NSTEP}_${IB}_${PRG}_RETCTR_EXCLUS.dat
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
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TRANSFP_CURGTA.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_TRANSFP_CURGTA_EST.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_CTR_NOT_FOUND.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_CLM_NOT_FOUND.dat
export ${PRG}_O5=${DFILT}/${NSTEP}_${IB}_${PRG}_RETCTR_EXCLUS.dat
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
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TRANSFP_ARCSTATGTA.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_TRANSFP_ARCSTATGTA_EST.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_CTR_NOT_FOUND.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_CLM_NOT_FOUND.dat
export ${PRG}_O5=${DFILT}/${NSTEP}_${IB}_${PRG}_RETCTR_EXCLUS.dat
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
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Split GTA BILAN -1 BILAN en cours "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_ESTM7001_TRANSFP_GTA.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_GTA_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_GTA_O2.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY  3:1 - 3: EN
/CONDITION GTA_BALSHEY_1 BALSHEY = `expr ${BALSHEY_NF} - 1`
/CONDITION GTA_BALSHEY BALSHEY = ${BALSHEY_NF}
/OUTFILE ${SORT_O}
/INCLUDE GTA_BALSHEY_1
/OUTFILE ${SORT_O2}
/INCLUDE GTA_BALSHEY
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_35
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Split CURGTA BILAN -1 BILAN en cours "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_15_${IB}_ESTM7001_TRANSFP_CURGTA.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_CURGTA_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_CURGTA_O2.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY  3:1 - 3: EN
/CONDITION GTA_BALSHEY_1 BALSHEY = `expr ${BALSHEY_NF} - 1`
/CONDITION GTA_BALSHEY BALSHEY = ${BALSHEY_NF}
/OUTFILE ${SORT_O}
/INCLUDE GTA_BALSHEY_1
/OUTFILE ${SORT_O2}
/INCLUDE GTA_BALSHEY
/COPY
exit
EOF
SORT

JOBEND


