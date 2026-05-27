#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - TRANSFERT PORTEFEUILLE INTER-SITES
# nom du script SHELL:           ESTD3022.cmd
# revision: $Revision:           1.1  $
# date de creation:              29/11/2006
# auteur:                        J.Ribot
# references des specifications : SPOT EST13720
#-----------------------------------------------------------------------------
# description
#   Transfert Amerique du Sud
#
# job launched by ESTD3020.cmd
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
BALSHTMTH_NF=${3}
ESTIM_B=${4}
FORCEBILAN=${5}

# Initialization of the Job
JOBINIT

NSTEP=${NJOB}_05
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Extraction des tables"
PRG=ESTX7009
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRCROSSREF.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_CLMCROSSREF.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_DETTRS.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FACCROSSREF.dat
EXECPRG


NSTEP=${NJOB}_07
# Sort binary file
#------------------------------------------------------------------------------
LIBEL="Sort of binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_ESTX7009_CTRCROSSREF.dat fixed 32"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_ESTX7009_FACCROSSREF.dat fixed 32"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TRTFACCROSSREF.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
   CTR_NF	1 CHAR 10,
   SSD_CF	11 UINTEGER 1,
   DESTCTR_NF	12 CHAR 10,
   DESTSSD_CF 22 UINTEGER 1,
   ACCESB_CF  23 UINTEGER 1,
   LSTUPD_D	24 CHAR 9
/KEYS
   CTR_NF,
   SSD_CF,
   DESTCTR_NF,
   DESTSSD_CF,
   ACCESB_CF
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
# [02]
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILP}/${PCH}ESTD3000_ESTD3003_GTA_ENTREEP.dat 1000 1"
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

NSTEP=${NJOB}_20
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from GTA.dat"
PRG=ESTM7007
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_15_${IB}_SORT_GTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_SORT_TRTFACCROSSREF.dat
export ${PRG}_I3=${DFILT}/${NJOB}_05_${IB}_ESTX7009_CLMCROSSREF.dat
export ${PRG}_I4=${DFILT}/${NJOB}_05_${IB}_ESTX7009_DETTRS.dat
export ${PRG}_I5=${DFILT}/${NJOB}_10_${IB}_ESTX7011_POSTES.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTA_TRANSFP_ENTREE.dat
EXECPRG

NSTEP=${NJOB}_13
# [02]
#-----------------------------------------------------------------------------
LIBEL="Sort TL file according to subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILP}/${PCH}ESTD3000_ESTD3003_CURGTA_ENTREEP.dat 1000 1"
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


NSTEP=${NJOB}_15
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from GTA.dat"
PRG=ESTM7007
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_13_${IB}_SORT_CURGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_SORT_TRTFACCROSSREF.dat
export ${PRG}_I3=${DFILT}/${NJOB}_05_${IB}_ESTX7009_CLMCROSSREF.dat
export ${PRG}_I4=${DFILT}/${NJOB}_05_${IB}_ESTX7009_DETTRS.dat
export ${PRG}_I5=${DFILT}/${NJOB}_10_${IB}_ESTX7011_POSTES.dat
export ${PRG}_O1=${DFILI}/${NJOB}_CURGTA_TRANSFP_ENTREE.dat
EXECPRG


NSTEP=${NJOB}_35
# Begin ISQL
#------------------------------------------------------------------------------
LIBEL="Update TRFACCSTS_CT = 41 apres TRANSFERTS"
ISQL_BASE="BTRT"
ISQL_QRY="update BTRT..TRFCROSSREF
             set TRFACCSTS_CT = 51
           from BTRT..TRFCROSSREF where TRFACCSTS_CT = 41"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL

NSTEP=${NJOB}_40
# Begin ISQL
#------------------------------------------------------------------------------
LIBEL="Update TRFACCSTS_CT = 41 apres TRANSFERTS"
ISQL_BASE="BFAC"
ISQL_QRY="update BFAC..TRFCROSSREF
             set TRFACCSTS_CT = 51
           from BFAC..TRFCROSSREF where TRFACCSTS_CT = 41"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL

NSTEP=${NJOB}_45
# delete old temporary Data files
#---------------------------------------------------------------
LIBEL="delete old temporary Data files"
#RMFIL "${DFILP}/${PCH}ESTD3000_ESTD3003_*.dat"
RMFIL "${DFILT}/${NJOB}*_${IB}*.dat"

JOBEND



