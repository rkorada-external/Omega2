#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - Internal retrocession
# nom du script SHELL           : 2021.cmd
# revision                      : $Revision:   1.4
# date de creation              : 22/06/2004
# auteur                        : CGI
# references des specifications : ESID2020.doc
#-----------------------------------------------------------------------------
# description :
# Création Retro Auto Interne et préparation pour deuxième passage ESID5027
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
# [001] 23/03/2015 J.FONTANA : Spot#28559 -> EST24BT
# [002] 26/11/2015 R. BEN EZZINE :spot 29565: Enlever les doublons sur les ACY > Bilan
# [003] 28/09/2016 PGA: spot 31124: forcer ACY = UWY pour contrat type 1
# [004] 27/03/2019 S.Behague    :spira 70044:REQ.L.02.05: Evolution quarterly
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

# Get parameters
DBCLO_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4

# Job initialisation
JOBINIT

# NSTEP=${NJOB}_000
# #Last version of ESID2020 files deletion
# #-----------------------------------------------------------------
# LIBEL="Delete last file"
# RMFIL " `dirname ${EST_DLEIEST}`/${NJOB}ESID2020_DLEIEST*.dat"


NSTEP=${NJOB}_020
# Sorting RETRO LIFEST TL file
#-----------------------------------------------------------------------------
LIBEL="Sorting RETRO LIFEST TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_I2="${EST_LIFESTNOACC} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ACY_NF        7:1 - 7:,
        ACM_NF        25:1 - 25:,
        CRE_D         8:1 - 8:,
        ACMTRS_NT    10:1 - 10:,
        ACMTRS1_NT   10:1 - 10:1,
        BALSHEY_NF   11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        DETTRNCOD_CF 20:1 - 20:,
        GAAP_NF      22:1 - 22:    
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      ACM_NF,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF  
/CONDITION RETRO (ACMTRS1_NT = '2' AND BALSHEY_NF = '${BALSHTYEA_NF}')
/OUTFILE  ${SORT_O}
/INCLUDE RETRO
exit
EOF
SORT

#gzip -c ${DFILT}/${NJOB}_020_${IB}_SORT_LIFEST_O.dat > ${DFILT}/${NJOB}_020_SORT_LIFEST_O_${IT}.dat.sgz


NSTEP=${NJOB}_030
# Launching cleaning chain ESID0002
#------------------------------------------------------------------------------
LIBEL="Launching cleaning chain ESID0002"
IBC=${IB}
INPUT_FILE1="${DFILT}/${NJOB}_020_${IB}_SORT_LIFEST_O.dat"
OUTPUT_FILE_NAME="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat"
OUTPUT_FILE_NAME_DIFF="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_OLD.dat"
${DCMD}/ESID0002.cmd ${IBC} ${OUTPUT_FILE_NAME} ${OUTPUT_FILE_NAME_DIFF} ${INPUT_FILE1} 2>&1 | ${TEE}   # ${INPUT_FILE2}
IB=${IBC}

#gzip -c ${DFILT}/${NJOB}_030_${IB}_SORT_LIFEST_O.dat > ${DFILT}/${NJOB}_030_SORT_LIFEST_O_${IT}.dat.sgz

NSTEP=${NJOB}_040
# Computing acceptance TL for retrocessionaire subsidiaries
#------------------------------------------------------------------------------
LIBEL="Computing acceptance TL for retrocessionaire subsidiaries"
PRG=ESTC2020
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CLOPRD_D ${CLOPRD}
DBCLO_D ${DBCLO_D}
CRE_D ${CRE_D}
BALSHTMTH_NF ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_FVPLACEMT}
export ${PRG}_I2=${DFILT}/${NJOB}_030_${IB}_SORT_LIFEST_O.dat
export ${PRG}_I3=${EST_FSSDACTR}
export ${PRG}_I5=${EST_FACCPAR0}
export ${PRG}_I6=${EST_SUBTRSASSO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST.dat
EXECPRG

#gzip -c ${DFILT}/${NJOB}_040_${IB}_ESTC2020_LIFEST.dat   >   ${DFILT}/${NJOB}_040_ESTC2020_LIFEST_${IT}.dat.sgz

NSTEP=${NJOB}_045
# [003]
# Sorting RETRO LIFEST TL file
#-----------------------------------------------------------------------------
LIBEL="Sorting RETRO LIFEST TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_040_${IB}_ESTC2020_LIFEST.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        ACY_NF        7:1 - 7:,
        ACM_NF       25:1 - 25:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      ACY_NF,
      ACM_NF
/OUTFILE  ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_050
# [003]
# for type 1 contract forced UWY = ACY
#------------------------------------------------------------------------------
LIBEL=" for type 1 contract forced UWY = ACY"
PRG=ESTC2094
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_045_${IB}_SORT_LIFEST.dat
export ${PRG}_I2=${EST_IARVPERICASE4}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST.dat
EXECPRG

#gzip -c ${DFILT}/${NJOB}_050_${IB}_ESTC2094_LIFEST.dat   >   ${DFILT}/${NJOB}_050_ESTC2094_LIFEST_${IT}.dat.sgz

NSTEP=${NJOB}_060
# Merging Annual Estimates for Sybase Insertion
#------------------------------------------------------------------------------
LIBEL="Merging Annual Estimates for Sybase Insertion"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_050_${IB}_ESTC2094_LIFEST.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat"
SORT_O1="${DFILT}/${NSTEP}_${IB}_CTR_ERR_LIFEST_O.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ACY_NF        7:1 - 7:,
        ACM_NF       25:1 - 25:,
        CRE_D         8:1 - 8:,
        ACMTRS_NT    10:1 - 10:,
        DETTRNCOD_CF 20:1 - 20:,
        BALSHEY_NF   11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        ESTMNT_M     14:1 - 14:EN 15/3,
        GAAP_NF      22:1 - 22:    
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      ACM_NF,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/CONDITION CONTRAT ( CTR_NF = '' )
/SUMMARIZE TOTAL ESTMNT_M
/OUTFILE  ${SORT_O}
/OMIT CONTRAT
/OUTFILE  ${SORT_O1}
/INCLUDE CONTRAT
exit
EOF
SORT


NSTEP=${NJOB}_080
# Grouped Transaction Codes Sort
#------------------------------------------------------------------------------
LIBEL="Grouped Transaction Codes Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FACCPAR0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCPAR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACMTRS_NT 1:1 - 1:
/KEYS ACMTRS_NT
exit
EOF
SORT


NSTEP=${NJOB}_100
# Annual Estimates Sort
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_060_${IB}_SORT_LIFEST_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACMTRS_NT 10:1 - 10:
/KEYS ACMTRS_NT
exit
EOF
SORT


NSTEP=${NJOB}_120
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_040_${IB}_ESTC2020_LIFEST.dat


NSTEP=${NJOB}_140
# Parameters Actualization
#------------------------------------------------------------------------------
LIBEL="Syncro Prev Accpar"
PRG=ESTC2022
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_080_${IB}_SORT_FACCPAR.dat
export ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_SORT_LIFEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST.dat
EXECPRG

#gzip -c ${DFILT}/${NJOB}_140_${IB}_ESTC2022_LIFEST.dat   >   ${DFILT}/${NJOB}_140_ESTC2022_LIFEST_${IT}.dat.sgz


NSTEP=${NJOB}_160
# Tri du fichier EST_DLRLIFEP_INT
#------------------------------------------------------------------------------
LIBEL="Tri du fichier LIFEI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_ESTC2022_LIFEST.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF  2:1 -  2:,
        SEC_NF  4:1 -  4:,
        UWY_NF  5:1 -  5:
/KEYS 
    CTR_NF,
    SEC_NF,
    UWY_NF
/OUTFILE   ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_200
# Syncro PERICASE FULL_DLEIEST pour EST_DLRLIFEI et LIFEI
#------------------------------------------------------------------------------
LIBEL="Syncro PERICASE FULL_DLEIEST to create EST_DLRLIFEI and LIFEI"
PRG=ESTC7607
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IARVPERICASE4}
export ${PRG}_I2=${DFILT}/${NJOB}_160_${IB}_SORT_LIFEST.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${EST_CPLIFDRI}
export ${PRG}_O1=${DFILI}/${NSTEP}_${IB}_EST_DLRLIFEP.dat  	# Echanges internes
export ${PRG}_O2=${EST_DLRLIFEI}                        	# Echanges inter-serveur
export ${PRG}_O3=${DFILI}/${NSTEP}_${IB}_EST_LIFEP_COMACC_1.dat
EXECPRG

#gzip -c ${DFILT}/${NJOB}_160_${IB}_SORT_LIFEST.dat > ${DFILT}/${NJOB}_160_SORT_LIFEST_${IT}.dat.sgz

NSTEP=${NJOB}_220
# Tri du fichier EST_DLRLIFEP_INT
#------------------------------------------------------------------------------
LIBEL="Tri du fichier LIFEI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${NJOB}_200_${IB}_EST_DLRLIFEP.dat 1000 1"
SORT_O="${EST_DLRLIFEP}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF  2:1 -  2:,
        SEC_NF  4:1 -  4:,
        UWY_NF  5:1 -  5:
/KEYS 
    CTR_NF,
    SEC_NF,
    UWY_NF
/OUTFILE   ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_250
# Erase temporary files
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND