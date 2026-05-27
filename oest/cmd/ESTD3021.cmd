#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - TRANSFERT PORTEFEUILLE INTER-SITES
# nom du script SHELL:           ESTD3021.cmd
# revision: $Revision:           1.1  $
# date de creation:              29/11/2006
# auteur:                        J.Ribot
# references des specifications : SPOT EST13427
#-----------------------------------------------------------------------------
# description
#   Transfert Amerique du Sud
#
# job launched by ESTD3000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#     <JJ/MM/AAAA> <Auteur >  <Description de la modification>
# [02] 07/07/2011   Florent    :spot:22328 ajout de 16 champs dans le GTA
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Entry parameters
BLCSHT_D=${1}
BALSHEY_NF=${2}

# Initialization of the Job
JOBINIT

NSTEP=${NJOB}_05
# [02]
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILP}/${PCH}ESTD3000_ESTD3001_GTA_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTA.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        LIG_GT 2:1 - 57:,
        GT_CTR_NF 8:1 - 8:,
        SSD_EMET_CF 58:1 - 58: EN
/KEYS GT_CTR_NF
/OUTFILE ${SORT_O}
/REFORMAT SSD_EMET_CF, LIG_GT
exit
EOF
SORT


NSTEP=${NJOB}_07
# [02]
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILP}/${PCH}ESTD3000_ESTD3001_CURGTA_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTA.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        LIG_GT 2:1 - 57:,
        GT_CTR_NF 8:1 - 8:,
        SSD_EMET_CF 58:1 - 58: EN
/KEYS GT_CTR_NF
/OUTFILE ${SORT_O}
/REFORMAT SSD_EMET_CF, LIG_GT
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Extraction de la table des postes a transformer"
PRG=ESTX7011
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_POSTES.dat
EXECPRG

NSTEP=${NJOB}_15
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation des retraits portefeuille GTA.dat"
PRG=ESTM7005
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_GTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_ESTX7011_POSTES.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTA_TRANSFP_RETRAIT.dat
EXECPRG


NSTEP=${NJOB}_20
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation des retraits portefeuille CURGTA.dat"
PRG=ESTM7005
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_07_${IB}_SORT_CURGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_ESTX7011_POSTES.dat
export ${PRG}_O1=${DFILI}/${NJOB}_CURGTA_TRANSFP_RETRAIT.dat
EXECPRG


########################
# Erase temporary files #
########################

NSTEP=${NJOB}_135
LIBEL="Erase temporary files"
#RMFIL "${DFILP}/${PCH}ESTD3000_ESTD3001_*.dat"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND



