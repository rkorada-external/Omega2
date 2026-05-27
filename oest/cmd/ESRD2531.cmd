#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Evol rapprochement effets retroactifs
# nom du script SHELL		: ESRD2531.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 01/2001
# auteur			: O.Arik
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#
#
# job lance par ESRD2530.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#
#[001]  16/06/2011  R. Cassis       :spot:21408 Ajout taille records dans tris
#[002] 27/06/2012 Roger Cassis :spot:23802 - gzip fichiers pour optimisation
#[003] 13/09/2013 Florent      :spot:25427 Closing batches adaptation for centralization, maj step 50
#[004] 05/10/2015 -=Dch=-  	 :spot:29162 - 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd

#set -x
# Job Initialisation
JOBINIT

# Parameters
CLODAT_D=$1


#################################################
# Generation of Work Files : GTAA100            #
#################################################

NSTEP=${NJOB}_05
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Recuperation des mvts comptables acceptation (gross transactions fetching)"
PRG=ESTC2328
export ${PRG}_I1=${EST_ARCSTATGTA}
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAA100_O.dat
EXECPRG


NSTEP=${NJOB}_10
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Differentiel Anciens et nveaux taux de cession (Diff old/new Cession rates )"
PRG=ESTC2329
export ${PRG}_I1=${EST_FCES}
export ${PRG}_I2=${EST_FCESANT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DIFFCES_O.dat
EXECPRG


NSTEP=${NJOB}_15
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application des taux de cession (cession rate fetching)"
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
GTE_B 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_ESTC2328_GTAA100_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_ESTC2329_DIFFCES_O.dat
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_ACCEPT_O.dat
EXECPRG


NSTEP=${NJOB}_20
# Sort FACCTRAA
#-------------------------------------------------------------------
LIBEL="Sort of FACCTRAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FACCTRAA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FACCTRAA_O.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 3:1 - 3:,
        RTY_NF 2:1 - 2:,
        TRNCOD_CF 15:1 - 15:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF
exit
EOF
SORT


NSTEP=${NJOB}_25
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of FOUTTRAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FOUTTRAA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FOUTTRAA_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 3:1 - 3:,
        RTY_NF 2:1 - 2:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF
exit
EOF
SORT


NSTEP=${NJOB}_30
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Selection of Retroactive Transactions. Elimination of Resrve Transaction Codes."
PRG=ESTC2331
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_25_${IB}_SORT_FOUTTRAA_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_20_${IB}_SORT_FACCTRAA_O.dat
export ${PRG}_I4=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_RETRO_O.dat
EXECPRG


NSTEP=${NJOB}_35
# Begin sort and summarizing before C Program
#------------------------------------------------------------------------------
LIBEL="Sort and Summarize of GTAR_ACCEPT before ESTC2330 C Program"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTC2303_GTAR_ACCEPT_O.dat 512 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR_ACCEPT_O.dat 512 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
       END_NT 9:1 - 9:,
       SEC_NF 10:1 - 10:,
       UWY_NF 11:1 - 11:,
       UW_NT 12:1 - 12:,
       RETCTR_NF 24:1 - 24:,
       RETEND_NT 25:1 - 25:,
       RETSEC_NF 26:1 - 26:,
       RTY_NF 27:1 - 27:,
       RETUW_NT 28:1 - 28:,
       TRNCOD_CF 6:1 - 6:,
       RETCUR_CF 34:1 - 34:,
       AMT_M 19:1 - 19:EN 18/3,
       RETAMT_M 35:1 - 35:EN 18/3
/KEYS CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       RETCTR_NF,
       RETEND_NT,
       RETSEC_NF,
       RTY_NF,
       RETUW_NT,
       TRNCOD_CF,
       RETCUR_CF
/CONDITION RESTRICTION AMT_M NE 0 OR RETAMT_M NE 0
/SUMMARIZE TOTAL AMT_M,TOTAL RETAMT_M
/OUTFILE ${SORT_O}
	/INCLUDE RESTRICTION
exit
EOF
SORT

NSTEP=${NJOB}_40
# Begin sort and summarizing before C Program
#------------------------------------------------------------------------------
LIBEL="Sort and Summarize of GTAR_RETRO before ESTC2330 C Program"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC2331_GTAR_RETRO_O.dat 512 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR_RETRO_O.dat 512 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
       END_NT 9:1 - 9:,
       SEC_NF 10:1 - 10:,
       UWY_NF 11:1 - 11:,
       UW_NT 12:1 - 12:,
       RETCTR_NF 24:1 - 24:,
       RETEND_NT 25:1 - 25:,
       RETSEC_NF 26:1 - 26:,
       RTY_NF 27:1 - 27:,
       RETUW_NT 28:1 - 28:,
       TRNCOD_CF 6:1 - 6:,
       RETCUR_CF 34:1 - 34:,
       AMT_M 19:1 - 19:EN 18/3,
       RETAMT_M 35:1 - 35:EN 18/3
/KEYS CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT,
       RETCTR_NF,
       RETEND_NT,
       RETSEC_NF,
       RTY_NF,
       RETUW_NT,
       TRNCOD_CF,
       RETCUR_CF
/CONDITION RESTRICTION AMT_M NE 0 OR RETAMT_M NE 0
/SUMMARIZE TOTAL AMT_M,TOTAL RETAMT_M
/OUTFILE ${SORT_O}
	/INCLUDE RESTRICTION
exit
EOF
SORT


NSTEP=${NJOB}_45
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Rapprochement GTAR_ACCEPT et GTAR_RETRO (Merge of files GTAR_ACCEPT and GTAR_RETRO)"
PRG=ESTC2330
export ${PRG}_I1=${DFILT}/${NJOB}_35_${IB}_SORT_GTAR_ACCEPT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_40_${IB}_SORT_GTAR_RETRO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_RAPPROCH_O.dat
EXECPRG


#Switch on INFO CENTER server defined in the environment file
#----------------------------------------------------------------
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_50
# Begin BCP IN
#-----------------------------------------------------------------
LIBEL=" Cancel & replace new results in BSAR..TRETCOMPPREV"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_I=${DFILT}/${NJOB}_45_${IB}_${PRG}_RAPPROCH_O.dat
BCP_TABLE="BSAR..TRETCOMPPREV"
BCP

#Switch on current server
#-----------------------------------------------------------------
SWITCH_SRV ${SRV_DEFAULT}

NSTEP=${NJOB}_55
# Delete of temporary files
#------------------------------------------------------------------------------
LIBEL="Delete of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
