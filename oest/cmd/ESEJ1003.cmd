#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS 
#                                 Mise a jour des ultimes
# nom du script SHELL		: ESEJ1003.cmd
# revision			: $Revision:   1.7  $
# date de creation		: 23/06/97
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	: ESTIR32F.doc
#-----------------------------------------------------------------------------
# description
#   Ultimates update (set 32)
#
# job launched by ESEJ1000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 19/05/2014 R. Cassis   :spot:26775  - gzip fichiers temporaires
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

#Recupere arguments d'entree
UPDULTTYP_CT=$1
CRE_D=$2

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
# Transferring automatic parameters table into a file
#------------------------------------------------------------------------------
LIBEL="Transferring automatic parameters table into a file"
PRG=ESTC3207
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ESTAUTPAR_O.dat
EXECPRG

#[001]
#---------------------------------------
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_ESTAUTPAR_O.dat                > ${DFILT}/${NSTEP}_${PRG}_ESTAUTPAR_O.dat.gz
gzip -c ${DFILT}/${NCHAIN}_ESEJ1002_15_${IB}_SORT_ESTMVTCPT_O.dat     > ${DFILT}/${NCHAIN}_ESEJ1002_15_SORT_ESTMVTCPT.dat.gz
gzip -c ${DFILT}/${NCHAIN}_ESEJ1001_45_${IB}_SORT_ESTRECPAR_O.dat     > ${DFILT}/${NCHAIN}_ESEJ1001_45_SORT_ESTRECPAR.dat.gz
gzip -c ${DFILT}/${NCHAIN}_ESEJ1001_55_${IB}_SORT_ESTCTRULT_O.dat     > ${DFILT}/${NCHAIN}_ESEJ1001_55_SORT_ESTCTRULT.dat.gz
gzip -c ${DFILT}/${NCHAIN}_ESEJ1002_10_${IB}_ESTC3211_ESTCTRLIS_O.dat > ${DFILT}/${NCHAIN}_ESEJ1002_10_ESTC3211_ESTCTRLIS.dat.gz
#---------------------------------------

NSTEP=${NJOB}_10
# Ultimates update 
#------------------------------------------------------------------------------
LIBEL="Ultimates update"
PRG=ESTC3206
FPRM=`CFTMP`
INPUT_TEXT $FPRM << EOF
UPDULTTYP_CT ${UPDULTTYP_CT}
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESEJ1002_15_${IB}_SORT_ESTMVTCPT_O.dat
export ${PRG}_I2=${DFILT}/${NCHAIN}_ESEJ1001_45_${IB}_SORT_ESTRECPAR_O.dat
export ${PRG}_I3=${DFILT}/${NCHAIN}_ESEJ1001_55_${IB}_SORT_ESTCTRULT_O.dat
export ${PRG}_I4=${DFILT}/${NCHAIN}_ESEJ1002_10_${IB}_ESTC3211_ESTCTRLIS_O.dat
export ${PRG}_I5=${DFILT}/${NJOB}_05_${IB}_ESTC3207_ESTAUTPAR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ESTCTRULT_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ESTCPLAMT_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_ESTUW_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_ESTRMD_O4.dat
EXECPRG


#[001]
#---------------------------------------
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_ESTCTRULT_O1.dat > ${DFILT}/${NSTEP}_${PRG}_ESTCTRULT_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_ESTCPLAMT_O2.dat > ${DFILT}/${NSTEP}_${PRG}_ESTCPLAMT_O2.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_ESTUW_O3.dat     > ${DFILT}/${NSTEP}_${PRG}_ESTUW_O3.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_ESTRMD_O4.dat    > ${DFILT}/${NSTEP}_${PRG}_ESTRMD_O4.dat.gz
#---------------------------------------

JOBEND
