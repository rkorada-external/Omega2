#!/bin/ksh
#=================================================================================================================================
# Application name              : Management of OPENING / CLOSING Position => Grid opening
# Batch name                    : STAD7502.cmd
# Revision                      : $Revision:  $
# Creation date                 : 26/08/2019
# Author                        : L. Wernert
# Specification reference       : http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-908624
# Technical reference           : http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BJTD-CLO-908797
#---------------------------------------------------------------------------------------------------------------------------------
# Description :	
#    Annual initialization of life estimates
#
# Entry parameters :
#    BALSHTYEA_NF
#    BALSHTMTH_NF
#    CRE_D
#
#---------------------------------------------------------------------------------------------------------------------------------
# Modification history :
# <modification> <JJ/MM/AAAA> <author> <spot> <description>
# [001]  04/03/2021 L. BEL   90055:Opning Yearly and Quaterly
#
#---------------------------------------------------------------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialize JOB
JOBINIT

# Entry parameters
set -x
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3
BALSHTYEA1_NF=$((${BALSHTYEA_NF}+1))
set +x


ECHO_LOG "#----------------------------------------------------"
ECHO_LOG "#....................INPUT...................."
ECHO_LOG "#===> EST_FLIFESTY...........: ${EST_FLIFESTY}"
ECHO_LOG "#===> EST_FLIFESTQ...........: ${EST_FLIFESTQ}"                    
ECHO_LOG "#===> EST_CPLIFDRI...........: ${EST_CPLIFDRI}"                          
ECHO_LOG "#===> EST_CPLIFDRIQ..........: ${EST_CPLIFDRIQ}"
ECHO_LOG "#===> EST_IARVPERICASE4......: ${EST_IARVPERICASE4}"
ECHO_LOG "#===> EST_SUBTRSASSO.........: ${EST_SUBTRSASSO}"
ECHO_LOG "#===> EST_SUBTRS.............: ${EST_SUBTRS}"
ECHO_LOG "#----------------------------------------------------"

###############################################################################
#                  TRAITEMENT QUARTERLY OPENING  - START
###############################################################################
NSTEP=${NJOB}_10
# Sorting quarterly file for ESTC2040
#------------------------------------------------------------------------------
LIBEL="Sorting file EST_FLIFESTQ for ESTC2040"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FLIFESTQ} 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_FLIFESTQ_MTH.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF         2:1 -  2:,
        END_NT         3:1 -  3:,
        SEC_NF         4:1 -  4:,
        UWY_NF         5:1 -  5:,
        UW_NT          6:1 -  6:,
        ACY_NF         7:1 -  7:,
        CRE_D          8:1 -  8:,
        PRS_CF         9:1 -  9:,
        ACMTRS_NT     10:1 - 10:,
        BALSHEY_NF    11:1 - 11:EN,
        BALSHTMTH_NF  12:1 - 12:EN,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:,
        ACM_NF        25:1 - 25:EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF,
      BALSHEY_NF DESCENDING,
      BALSHTMTH_NF DESCENDING,
      CRE_D DESCENDING
exit
EOF
SORT


NSTEP=${NJOB}_20
# Quarterly Estimates Screen
#------------------------------------------------------------------------------
LIBEL="Quarterly Estimates Screen"
PRG=ESTC2040
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_O1_FLIFESTQ_MTH.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFESTQ_LAST.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFESTQ_OLD.dat
EXECPRG


NSTEP=${NJOB}_30
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Getting ACCAMDTYP corresponding with max(UWY_NF) from IARVPERICASE4"
PRG=ESTC2149
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_ESTC2040_LIFESTQ_LAST.dat
export ${PRG}_I2=${EST_IARVPERICASE4}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFESTQ_O.dat
EXECPRG


NSTEP=${NJOB}_40
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_O1_FLIFESTQ_MTH.dat


NSTEP=${NJOB}_50
# Sort CPLIFDRIQ binary file
#------------------------------------------------------------------------------
LIBEL="Sort of CPLIFDRIQ binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CPLIFDRIQ} fixed 112"
SORT_O=${DFILT}/${NSTEP}_${IB}_CPLIFDRIQ_O1.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS CTR_NF           1 CHAR 10,
        END_NT          11 UINTEGER 1,
        SEC_NF          12 UINTEGER 1,
        UWY_NF          13 INT 2,
        UW_NT           15 UINTEGER 1,
        ACY_NF          16 INT 2,
        ACM_NF          19 UINTEGER 1,
        SSD_CF          20 UINTEGER 1,
        BALSHEY_NF      21 INT 2,
        BALSHTMTH_NF    22 UINTEGER 1,
        AUTUPD_B        23 UINTEGER 1,
        COMACC_B        24 UINTEGER 1,
        PROPAG_RES_B    25 UINTEGER 1,
        SEGUPD_B        26 UINTEGER 1,
        CRE_D           27 CHAR 17
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      CRE_D DESCENDING
exit
EOF
SORT


NSTEP=${NJOB}_60
# Begin program C
#------------------------------------------------------------------------------
LIBEL="Quarterly Estimates Purge. Opening to Next Balance Sheet"
PRG=ESTC2150
FPRM=`CFTMP`
INPUT_TEXT $FPRM << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
CRE_D ${CRE_D}
QUARTER 1
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_ESTC2149_LIFESTQ_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_50_${IB}_CPLIFDRIQ_O1.dat
export ${PRG}_I3=${EST_SUBTRSASSO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFESTQ_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFDRIQ_O2.dat
EXECPRG


# -----------------------------------------------
# QUATERLY TRACES FOR THE TEST ENVIRONMENT
# -----------------------------------------------
gzip -c ${FPRM}                                          > ${DFILT}/${NJOB}_${NSTEP}_${PRG}_FPRM.gz
gzip -c ${DFILT}/${NJOB}_30_${IB}_ESTC2149_LIFESTQ_O.dat > ${DFILT}/${NJOB}_30_ESTC2149_LIFESTQ_O.dat.gz
gzip -c ${DFILT}/${NJOB}_50_${IB}_CPLIFDRIQ_O1.dat       > ${DFILT}/${NJOB}_50_CPLIFDRIQ_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2150_LIFESTQ_O1.dat  > ${DFILT}/${NSTEP}_ESTC2150_LIFESTQ_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2150_LIFDRIQ_O2.dat  > ${DFILT}/${NSTEP}_ESTC2150_LIFDRIQ_O2.dat.gz
# -----------------------------------------------
# QUATERLY TRACES FOR THE TEST ENVIRONMENT - END
# -----------------------------------------------


NSTEP=${NJOB}_65
# Sort quarterly estimates for ESTC2169
#------------------------------------------------------------------------------
LIBEL="Sort of quarterly estimates for ESTC2169"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESTC2150_LIFESTQ_O1.dat 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2150_SORT_LIFESTQ_O1.dat 500 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS CTR_NF           1:1 -  1:,
        SEC_NF           3:1 -  3:,
        UWY_NF           4:1 -  4:,
        ACY_NF           9:1 -  9:,
        GAAP_NF         10:1 - 10:,
        DETTRNCOD_CF    11:1 - 11:,
        ESTMTH_NF       12:1 - 12:EN,
        ACMTRS_NT       14:1 - 14:

/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF,
      ESTMTH_NF
exit
EOF
SORT


NSTEP=${NJOB}_70
# Aggregation of quarterly estimates into yearly estimates
#------------------------------------------------------------------------------
LIBEL="Aggregation of quarterly estimates into yearly estimates"
PRG=ESTC2169
export ${PRG}_I1=${DFILT}/${NJOB}_65_${IB}_ESTC2150_SORT_LIFESTQ_O1.dat
export ${PRG}_I2=${EST_SUBTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FLIFESTQ_AGGREG.dat
EXECPRG

###############################################################################
#                   TRAITEMENT QUARTERLY OPENING - END  
###############################################################################
#                    TRAITEMENT YEARLY OPENING - START
###############################################################################

NSTEP=${NJOB}_80
# Separation between pure yearly contracts and aggregated quarterly contracts
#------------------------------------------------------------------------------
LIBEL="Separation between pure yearly contracts and aggregated quarterly contracts"
PRG=ESTC1036
export ${PRG}_I1=${EST_FLIFESTY}
export ${PRG}_I2=${EST_IARVPERICASE4}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FLIFEST_PURE.dat
EXECPRG


NSTEP=${NJOB}_90
# Sorting file for ESTC2040
#------------------------------------------------------------------------------
LIBEL="Sorting file FLIFEST_PURE for ESTC2040"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTC1036_FLIFEST_PURE.dat 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O1_FLIFEST_MTH.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF         2:1 -  2:,
        END_NT         3:1 -  3:,
        SEC_NF         4:1 -  4:,
        UWY_NF         5:1 -  5:,
        UW_NT          6:1 -  6:,
        ACY_NF         7:1 -  7:,
        CRE_D          8:1 -  8:,
        PRS_CF         9:1 -  9:,
        ACMTRS_NT     10:1 - 10:,
        BALSHEY_NF    11:1 - 11:EN,
        BALSHTMTH_NF  12:1 - 12:EN,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF,
      BALSHEY_NF DESCENDING,
      BALSHTMTH_NF DESCENDING,
      CRE_D DESCENDING
exit
EOF
SORT


NSTEP=${NJOB}_100
# Annual Estimates Screen
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC2040
export ${PRG}_I1=${DFILT}/${NJOB}_90_${IB}_SORT_O1_FLIFEST_MTH.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_LAST.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_OLD.dat
EXECPRG


NSTEP=${NJOB}_110
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Getting ACCAMDTYP corresponding with max(UWY_NF) from IARVPERICASE4"
PRG=ESTC2149
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_ESTC2040_LIFEST_LAST.dat
export ${PRG}_I2=${EST_IARVPERICASE4}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O.dat
EXECPRG


NSTEP=${NJOB}_115
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_O1_FLIFEST_MTH.dat


NSTEP=${NJOB}_120
# Sort CPLIFDRI binary file
# input file has same struct as QUATERLY (T_LIFDRI_ALL_QUARTER in struct.h)
# for YEARLY, ACM_NF always remains equal to 13
#------------------------------------------------------------------------------
LIBEL="Sort of CPLIFDRI binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CPLIFDRI} fixed 112"
SORT_O=${DFILT}/${NSTEP}_${IB}_CPLIFDRI_O1.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS CTR_NF           1 CHAR 10,
        END_NT          11 UINTEGER 1,
        SEC_NF          12 UINTEGER 1,
        UWY_NF          13 INT 2,
        UW_NT           15 UINTEGER 1,
        ACY_NF          16 INT 2,
        ACM_NF          19 UINTEGER 1,
        SSD_CF          20 UINTEGER 1,
        BALSHEY_NF      21 INT 2,
        BALSHTMTH_NF    22 UINTEGER 1,
        AUTUPD_B        23 UINTEGER 1,
        COMACC_B        24 UINTEGER 1,
        PROPAG_RES_B    25 UINTEGER 1,
        SEGUPD_B        26 UINTEGER 1,
        CRE_D           27 CHAR 17
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      CRE_D DESCENDING
exit
EOF
SORT


NSTEP=${NJOB}_130
# Begin program C
#------------------------------------------------------------------------------
LIBEL="Yearly Estimates Purge. Opening to Next Balance Sheet"
PRG=ESTC2150
FPRM=`CFTMP`
INPUT_TEXT $FPRM << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
CRE_D ${CRE_D}
QUARTER 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_110_${IB}_ESTC2149_LIFEST_O.dat 
export ${PRG}_I2=${DFILT}/${NJOB}_120_${IB}_CPLIFDRI_O1.dat
export ${PRG}_I3=${EST_SUBTRSASSO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFDRI_O2.dat
EXECPRG


# -----------------------------------------------
# YEARLY TRACES FOR THE TEST ENVIRONMENT
# -----------------------------------------------
gzip -c ${FPRM}                                         > ${DFILT}/${NJOB}_${NSTEP}_${PRG}_FPRM.gz
gzip -c ${DFILT}/${NJOB}_110_${IB}_ESTC2149_LIFEST_O.dat > ${DFILT}/${NJOB}_110_ESTC2149_LIFEST_O.dat.gz
gzip -c ${DFILT}/${NJOB}_120_${IB}_CPLIFDRI_O1.dat       > ${DFILT}/${NJOB}_120_CPLIFDRI_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2150_LIFEST_O1.dat  > ${DFILT}/${NSTEP}_ESTC2150_LIFEST_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2150_LIFDRI_O2.dat  > ${DFILT}/${NSTEP}_ESTC2150_LIFDRI_O2.dat.gz
# -----------------------------------------------
# YEARLY TRACES FOR THE TEST ENVIRONMENT - END
# -----------------------------------------------

###############################################################################
#                     TRAITEMENT YEARLY OPENING - END  
###############################################################################
#                      LOADING YEARLY OPENING - START  
###############################################################################

NSTEP=${NJOB}_140
# Annual Estimates Sort and adding the aggregated quaterly estimates into
# yearly estimates
#------------------------------------------------------------------------------
LIBEL="Annual Estimates + aggregated quaterly estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_ESTC2150_LIFEST_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_70_${IB}_ESTC2169_FLIFESTQ_AGGREG.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF        1:1 - 1:,
        END_NT        2:1 - 2:,
        SEC_NF        3:1 - 3:,
        UWY_NF        4:1 - 4:,
        UW_NT         5:1 - 5:,
        CRE_D         6:1 - 6:,
        BALSHEY_NF    7:1 - 7:,
        BALSHTMTH_NF  8:1 - 8:,
        ACY_NF        9:1 - 9:,
        GAAP_NF      10:1 - 10:,
        DETTRNCOD_CF 11:1 - 11:,
        ESTMTH_NF    12:1 - 12:,
        PRS_CF       13:1 - 13:,
        ACMTRS_NT    14:1 - 14:,
        SSD_CF       15:1 - 15:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      GAAP_NF,
      ESTMTH_NF,
      DETTRNCOD_CF,
      PRS_CF,
      ACMTRS_NT,
      SSD_CF
/SUM
/STABLE
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_150
# Begin C Program
# if QUARTER = 0 then yearly if QUARTER = 1 then quarterly
#------------------------------------------------------------------------------
LIBEL="Puts driving file into bcp format"
PRG=ESTC203B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
QUARTER  0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_130_${IB}_ESTC2150_LIFDRI_O2.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFDRI_BCP_O.dat
EXECPRG


NSTEP=${NJOB}_160
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Get actual BALSHEY_NF only on TLIFDRI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_150_${IB}_ESTC203B_LIFDRI_BCP_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFDRI_O.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_LIFDRI_OMIT.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 10:1 - 10:EN,
        FILLER  1:1 - 17:

/KEYS FILLER

/CONDITION SSD ${EST_SORT_CONDITION}
/DERIVEDFIELD SEGUPD_B "1"

/OUTFILE  ${SORT_O}
/REFORMAT FILLER, SEGUPD_B
/INCLUDE SSD

/OUTFILE ${SORT_O2}
/REFORMAT FILLER, SEGUPD_B
/OMIT SSD
exit
EOF
SORT 


NSTEP=${NJOB}_170
# Temporary file deletion 
LIBEL="Temporary file deletion" 
RMFIL ${DFILT}/${NJOB}_130_${IB}_ESTC2150_LIFDRI_O2.dat 
gzip -c ${DFILT}/${NJOB}_160_${IB}_SORT_LIFDRI_OMIT.dat > ${DFILT}/${NJOB}_160_SORT_LIFDRI_OMIT.dat.gz


NSTEP=${NJOB}_180
# Clean-up TLIFEST if exists all rows of next BALSHTYEA_NF
#------------------------------------------------------------------------------
LIBEL="Clean-up if exists TLIFEST ${BALSHTYEA1_NF}"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST..PdLIFEST_01 ${BALSHTYEA1_NF}, 1"
ISQL


NSTEP=${NJOB}_190
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading opning file into TLIFEST table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_140_${IB}_SORT_LIFEST_O.dat
BCP_TABLE="BEST..TLIFEST"
BCP


NSTEP=${NJOB}_200
# Deletion of Table BEST..TLIFDRI
#-----------------------------------------------------------------------------
LIBEL="Delete BEST..TLIFDRI"
ISQL_BASE='BEST'
ISQL_QRY=`CFTMP`
INPUT_TEXT ${ISQL_QRY} <<EOF
DELETE BEST..TLIFDRI FROM BEST..TLIFDRI a, BREF..TBATCHSSD T
WHERE a.BALSHEY_NF in (${BALSHTYEA_NF},${BALSHTYEA1_NF})
AND   a.SSD_CF = T.SSD_CF
AND   T.BATCHUSER_CF = suser_name()
go
exit
EOF
ISQL


NSTEP=${NJOB}_210
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading file into TLIFDRI table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_160_${IB}_SORT_LIFDRI_O.dat
BCP_TABLE="BEST..TLIFDRI"
BCP

###############################################################################
#                      LOADING YEARLY OPENING - END  
###############################################################################
#                    LOADING QUATERLY OPENING - START  
###############################################################################

NSTEP=${NJOB}_220
# Quarterly Estimates Sort
#------------------------------------------------------------------------------
LIBEL="Quarterly Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESTC2150_LIFESTQ_O1.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFESTQ_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF        1:1 - 1:,
        END_NT        2:1 - 2:,
        SEC_NF        3:1 - 3:,
        UWY_NF        4:1 - 4:,
        UW_NT         5:1 - 5:,
        CRE_D         6:1 - 6:,
        BALSHEY_NF    7:1 - 7:,
        BALSHTMTH_NF  8:1 - 8:,
        ACY_NF        9:1 - 9:,
        GAAP_NF      10:1 - 10:,
        DETTRNCOD_CF 11:1 - 11:,
        ESTMTH_NF    12:1 - 12:,
        PRS_CF       13:1 - 13:,
        ACMTRS_NT    14:1 - 14:,
        SSD_CF       15:1 - 15:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      GAAP_NF,
      ESTMTH_NF,
      DETTRNCOD_CF,
      PRS_CF,
      ACMTRS_NT,
      SSD_CF
/SUM
/STABLE
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_230
# Begin C Program
# if QUARTER = 0 then yearly if QUARTER = 1 then quarterly
#------------------------------------------------------------------------------
LIBEL="Puts driving file into bcp format"
PRG=ESTC203B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
QUARTER  1
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_ESTC2150_LIFDRIQ_O2.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFDRIQ_BCP_O.dat
EXECPRG


NSTEP=${NJOB}_240
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Get actual BALSHEY_NF only on TLIFDRIQ"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_230_${IB}_ESTC203B_LIFDRIQ_BCP_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFDRIQ_O.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_LIFDRIQ_OMIT.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 11:1 - 11:EN,
        FILLER  1:1 - 18: 

/KEYS FILLER

/DERIVEDFIELD SEGUPD_B "1" 
/CONDITION SSD ${EST_SORT_CONDITION}

/OUTFILE  ${SORT_O}
/REFORMAT FILLER, SEGUPD_B
/INCLUDE SSD 

/OUTFILE ${SORT_O2} 
/REFORMAT FILLER, SEGUPD_B
/OMIT SSD 
exit
EOF
SORT 


NSTEP=${NJOB}_250
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_60_${IB}_ESTC2150_LIFDRIQ_O2.dat
gzip -c ${DFILT}/${NJOB}_240_${IB}_SORT_LIFDRIQ_OMIT.dat > ${DFILT}/${NJOB}_240_SORT_LIFDRIQ_OMIT.dat.gz


NSTEP=${NJOB}_260
# Clean-up TLIFESTD if exists all rows of next BALSHTYEA_NF
#------------------------------------------------------------------------------
LIBEL="Clean-up if exists TLIFESTD ${BALSHTYEA1_NF}"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST..PdLIFESTD_01 ${BALSHTYEA1_NF}, 1"
ISQL


NSTEP=${NJOB}_270
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading opning file into TLIFESTD table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_220_${IB}_SORT_LIFESTQ_O.dat
BCP_TABLE="BEST..TLIFESTD"
BCP


NSTEP=${NJOB}_280
# Deletion of Table BEST..LIFEST, BEST..TLIFDRI
#-----------------------------------------------------------------------------
LIBEL="Delete BEST..TLIFDRID"
ISQL_BASE='BEST'
ISQL_QRY=`CFTMP`
INPUT_TEXT ${ISQL_QRY} <<EOF
DELETE BEST..TLIFDRID FROM BEST..TLIFDRID a, BREF..TBATCHSSD T
WHERE a.BALSHEY_NF in (${BALSHTYEA_NF},${BALSHTYEA1_NF})
AND   a.SSD_CF = T.SSD_CF
AND   T.BATCHUSER_CF = suser_name()
go
exit
EOF
ISQL


NSTEP=${NJOB}_290
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Loading file into TLIFDRID table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_240_${IB}_SORT_LIFDRIQ_O.dat
BCP_TABLE="BEST..TLIFDRID"
BCP

###############################################################################
#                      LOADING QUATERLY OPENING - END  
###############################################################################


NSTEP=${NJOB}_340
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*${IB}_*.dat"

JOBEND
