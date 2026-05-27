#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Preparation de l'edition acceptation
# nom du script SHELL		: ESID2091.cmd
# revision			: $Revision:   1.6  $
# date de creation		: 09/97
# auteur			: C.G.I.
# references des specifications	: 
#-----------------------------------------------------------------------------
# description 
#   Preparation of data for acceptance closing period synthesis print out
#   Call C programs ESTR7606, ESTR7607, ESTR7608 and ESTR7610
#   Line <<fusion>> for all the amounts for a same contract/Avenant/section/exercise 
#
#-----------------------------------------------------------------------------
#
# Input files
#       EST_FCURQUOT              DFILP
#       EST_FLIBEL1               DFILP
#       EST_FTRSLNK        DFILI
#       EST_OIADVPERICASE   DFILI
#       EST_TOTGTAA        DFILI
#
# Launch C program ESTR7606 ESTR7607 ESTR7608 ESTR7610
#
# job launched by ESID2090.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 25/11/2015 R. Cassis  :spot:29162 Agrandissement taille des enregistrements de tri
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd


# Job Initialisation
JOBINIT

# Parameters
CLODAT_D=$1
CRE_D=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
DBCLO_D=$5


# ESID2092_${IB}_ESTR7620_O.dat


NSTEP=${NJOB}_05
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Conversion in subsidiary currency"
PRG=ESTR7606
export ${PRG}_I1=${EST_OIADVPERICASE}
export ${PRG}_I2=${EST_TOTGTAA}
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTI_O.dat
EXECPRG      

NSTEP=${NJOB}_10
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Accumulation amount by SSD_CF, ESB_CF, LOB_CF, CTRNAT_CT, WRKCAT_CT, ACMTRS_NT" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_ESTR7606_FTI_O.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTI_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN, 
        ESB_CF 2:1 - 2:EN, 
        LOB_CF 3:1 - 3:, 
        CTRNAT_CT 4:1 - 4:, 
        WRKCAT_CT 5:1 - 5:, 
        ACMTRS_NT 6:1 - 6:, 
        AMT_M 7:1 - 7:EN 20/3
/KEYS SSD_CF, 
      ESB_CF, 
      LOB_CF, 
      CTRNAT_CT, 
      WRKCAT_CT, 
      ACMTRS_NT
/SUMMARIZE TOTAL AMT_M
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Report preparation - first phase"
PRG=ESTR7607
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_FTI_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_REPORT1_O.dat
EXECPRG  

NSTEP=${NJOB}_20
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_FTI_O.dat  

NSTEP=${NJOB}_25
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Accumulation amount by SSD_CF, LOB_CF" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_ESTR7606_FTI_O.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTI_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN, 
        LOB_CF 3:1 - 3:, 
        CTRNAT_CT 4:1 - 4:, 
        WRKCAT_CT 5:1 - 5:, 
        ACMTRS_NT 6:1 - 6:, 
        AMT_M 7:1 - 7:EN 20/3
/KEYS SSD_CF, 
      LOB_CF, 
      CTRNAT_CT, 
      WRKCAT_CT, 
      ACMTRS_NT
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD ETABLISSEMENT "256"
/DERIVEDFIELD SEPARATEUR "~"
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ETABLISSEMENT, SEPARATEUR, LOB_CF, CTRNAT_CT, WRKCAT_CT, ACMTRS_NT, AMT_M
exit
EOF
SORT

NSTEP=${NJOB}_30
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_ESTR7606_FTI_O.dat

NSTEP=${NJOB}_35
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Report preparation - second phase"
PRG=ESTR7608
export ${PRG}_I1=${DFILT}/${NJOB}_25_${IB}_SORT_FTI_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_REPORT2_O.dat
EXECPRG   

NSTEP=${NJOB}_40
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_25_${IB}_SORT_FTI_O.dat 
                                                      

NSTEP=${NJOB}_45
# Begin sort and sort
#------------------------------------------------------------------------------
LIBEL="Merge and sort of report preparations" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTR7607_REPORT1_O.dat 500 1"
SORT_I2=${DFILT}/${NJOB}_35_${IB}_ESTR7608_REPORT2_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTI_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN, 
        ESB_CF 2:1 - 2:EN, 
        LOB_CF 3:1 - 3:, 
        CTRNAT_CT 4:1 - 4:, 
        WRKCAT_CT 5:1 - 5:
/KEYS SSD_CF, 
      ESB_CF, 
      LOB_CF, 
      CTRNAT_CT, 
      WRKCAT_CT
exit
EOF
SORT

NSTEP=${NJOB}_50
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTR7607_REPORT1_O.dat 
RMFIL ${DFILT}/${NJOB}_35_${IB}_ESTR7608_REPORT2_O.dat

NSTEP=${NJOB}_55
#subject : Print out of acceptance closing period synthesis
#---------------------------------------------------------------------
PRG=ESTR7610
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
CRE_D ${CRE_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
DBCLO_D ${DBCLO_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_45_${IB}_SORT_FTI_O.dat
export ${PRG}_I2=${EST_FLIBEL1}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_O.dat
EXECPRG

NSTEP=${NJOB}_60
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_45_${IB}_SORT_FTI_O.dat 

NSTEP=${NJOB}_65
#subject : Split Files by SSD
#---------------------------------------------------------------
LIBEL="Split files by SSD"
SPLIT_PREFIX=${NJOB}_55
SPLIT_PREFIX_NEW=${NCHAIN}_ESID2092
SPLIT_I=${DFILT}/${NJOB}_55_${IB}_ESTR7610_O.dat
SPLIT_SSD

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_70
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
          
JOBEND
