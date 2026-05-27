#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESID2031.cmd
# revision                      : 
# date de creation              : 
# auteur                        : 
# references des specifications :
#-----------------------------------------------------------------------------
# description :
# Création SRGTC, SRGTCB et VLIFEST
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
# [001] 02/10/2014 M.MECHRI :spot:25773 Correction de fichier CPLIFEST
# [002] 10/05/2016 R.BEN EZZINE  :spot: : Optimisation ESID2030
# [008] 20/02/2019 S.Behague     :REQ.L.02.05: Evolution quarterly
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
BALSHTYEA_NF=$1


# Job Initialisation
JOBINIT


NSTEP=${NJOB}_240
# Parameters Actualization
#------------------------------------------------------------------------------
LIBEL="Parameters Actualization"
PRG=ESTC2130
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_470_SORT_GT_O}
export ${PRG}_I2=${EST_FACCPAR0}
export ${PRG}_I3=${EST_VLIFEST195}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTC${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O2${IT}.dat
EXECPRG

# # ------------------------------------
# gzip -c ${EST_215_SORT_GT_O}                              > ${DFILT}/${NJOB}_215_SORT_GT_O${IT}.dat.gz
# gzip -c ${EST_230_SORT_LIFEST_O}                          > ${DFILT}/${NJOB}_230_SORT_LIFEST_O${IT}.dat.gz
 gzip -c ${DFILT}/${NJOB}_240_${IB}_ESTC2130_SRGTC${IT}.dat     > ${DFILT}/${NJOB}_240_ESTC2130_SRGTC${IT}.dat.gz
 gzip -c ${DFILT}/${NJOB}_240_${IB}_ESTC2130_LIFEST_O2${IT}.dat > ${DFILT}/${NJOB}_240_ESTC2130_LIFEST_O2${IT}.dat.gz
# # ------------------------------------


#[012]
NSTEP=${NJOB}_242
# Begin sort
#------------------------------------------------------------------------------
LIBEL="REFORMAT SRGTC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_240_${IB}_ESTC2130_SRGTC${IT}.dat 1000 1"
SORT_O="${EST_SRGTC}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        FILLER1     1:1 - 36:,
        FILLER1B    37:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER2     42:1 - 75:
/COPY
/OUTFILE ${SORT_O}
/REFORMAT 
          FILLER1,
          FILLER1B,
          RETINTAMT_M,
          FILLER2
exit
EOF
SORT


NSTEP=${NJOB}_245
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_215_${IB}_SORT_GT_O${IT}.dat
RMFIL ${DFILT}/${NJOB}_240_${IB}_ESTC2130_SRGTC${IT}.dat


NSTEP=${NJOB}_250
# Annual Estimates Merge for Retrocession Generation
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Merge for Retrocession Generation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_240_${IB}_ESTC2130_LIFEST_O2${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF  2:1 - 2:,
        SEC_NF  4:1 - 4:,
        UWY_NF  5:1 - 5:
/KEYS 
      CTR_NF,
      SEC_NF,
      UWY_NF
exit
EOF
SORT


NSTEP=${NJOB}_255
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_240_${IB}_ESTC2130_LIFEST_O2${IT}.dat


NSTEP=${NJOB}_344
# Begin EXECKSH
#------------------------------------------------------------------------------
LIBEL="copy file SORT_LIFEST_O"
EXECKSH "cp ${DFILT}/${NJOB}_250_${IB}_SORT_LIFEST_O${IT}.dat ${DFILT}/${NJOB}_250_${IB}_SORT_LIFEST_O.log"


NSTEP=${NJOB}_345
# Merging Annual Estimates for Sybase Insertion
#------------------------------------------------------------------------------
LIBEL="Merging Annual Estimates for Sybase Insertion"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_SORT_LIFEST_O${IT}.dat"
SORT_O="${EST_VLIFEST195} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:,
        ACM_NF          25:1 - 25:EN,
        CRE_D            8:1 -  8:,
        ACMTRS_NT       10:1 - 10:,
        DETTRNCOD_CF    20:1 - 20:,
        GAAP_NF         22:1 - 22:,
        BALSHEY_NF      11:1 - 11:,
        BALSHTMTH_NF    12:1 - 12:EN,
        ESTMNT_M        14:1 - 14:EN 15/3
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/SUMMARIZE TOTAL ESTMNT_M
exit
EOF
SORT

gzip -c ${EST_LIFENDCPT} > ${DFILT}/ESID3025_350_END_LIFEST_I${IT}.dat.gz

NSTEP=${NJOB}_350
# Merging Annual Estimates for Sybase Insertion
#------------------------------------------------------------------------------
LIBEL="Merging Annual Estimates for Sybase Insertion"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_ESTC2040_LAST_LIFEST_O1} 1000 1"
#SORT_I2="${EST_75_ESTC2035_END_LIFEST_O5} 1000 1"
SORT_I="${EST_LIFENDCPT} 1000 1"
SORT_I2="${EST_VLIFEST195} 1000 1"
SORT_I3="${EST_180_ESTC2040_OLD_LIFEST_O2} 1000 1"
SORT_I4="${EST_LIFESTLIB} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLIFEST_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        SSD_CF           1:1 -  1: EN,
        CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:,
        CRE_D            8:1 -  8:,
        PRS_CF           9:1 -  9:,
        ACMTRS_NT       10:1 - 10:,
        BALSHEY_NF      11:1 - 11:,
        BALSHTMTH_NF    12:1 - 12:EN,
        CUR_CF          13:1 - 13:,
        ESTMNT_M        14:1 - 14:EN 15/3,
        INDSUP_B        15:1 - 15:,
        ORICOD_LS       16:1 - 16:,
        CREUSR_CF       17:1 - 17:,
        LSTUPD_D        18:1 - 18:,
        LSTUPDUSR_CF    19:1 - 19:,
        DETTRNCOD_CF	20:1 - 20:,
        GAAP_NF         22:1 - 22:,
        GAAPDIFF_M      23:1 - 23:EN 15/3,
        PROPAGATION_B   24:1 - 24:,
        ESTMTH_NF       25:1 - 25:,
        ORICTR_NF       26:1 - 26:,
        ORISEC_NF       27:1 - 27:,
        ORIUWY_NF       28:1 - 28:,
        BATCH_B         52:1 - 52:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ESTMTH_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/SUM TOTAL ESTMNT_M
/DERIVEDFIELD CALCULATED_B "0~"
/OUTFILE ${SORT_O}
/REFORMAT 
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          CRE_D,
          BALSHEY_NF,
          BALSHTMTH_NF,
          ACY_NF,
          GAAP_NF,
          DETTRNCOD_CF,
          ESTMTH_NF,
          PRS_CF,
          ACMTRS_NT,
          SSD_CF,
          CUR_CF,
          ESTMNT_M,
          INDSUP_B,
          ORICOD_LS,
          CREUSR_CF,
          LSTUPD_D,
          LSTUPDUSR_CF,
          ORICTR_NF,
          ORISEC_NF,
          ORIUWY_NF,
          GAAPDIFF_M,
          PROPAGATION_B,
          CALCULATED_B,
          BATCH_B  
exit
EOF
SORT


NSTEP=${NJOB}_352
# Inversion of estimates retrocession amounts before loading
#-----------------------------------------------------------------------------
LIBEL="Inversion of estimates retrocession amounts before loading"
AWK_I=${DFILT}/${NJOB}_350_${IB}_SORT_FLIFEST_O${IT}.dat
AWK_O=${EST_CPLIFEST}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
        { if( \$14 < "2000" ) { print \$0 }}
		{ if( \$14 > "2000" ) { \$17 = sprintf("%-.3lf",-\$17) ; print \$0 }}
exit
EOF
AWK


NSTEP=${NJOB}_353
# Merging and Filtering of Previous Balshey Year file
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of Previous Balshey Year file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_200_ESTC2034_GTB1_O} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O1${IT}.dat 1000 1 "
SORT_O1="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O2${IT}.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
      ESTCRB_CT 50:1 - 50:
/COPY
/CONDITION RATT ESTCRB_CT EQ "R"
/OUTFILE  ${SORT_O}
/OMIT RATT
/OUTFILE  ${SORT_O1}
/INCLUDE RATT
exit
EOF
SORT


NSTEP=${NJOB}_355
# Grouping Accounting Transactions by SyncSort
#------------------------------------------------------------------------------
LIBEL="Grouping Accounting Transactions by SyncSort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_353_${IB}_SORT_GTB1_O1${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        SSD_DBLTRNCOD    1:1 -  7:,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        GT_CED_NF       20:1 - 20:,
        BRK_NF   				21:1 - 21:,
        PAY_NF 					22:1 - 22:,
        KEY_NF 					23:1 - 23:,
        RETCTR_NF 			24:1 - 24:,
        RETEND_NT 			25:1 - 25:,
        RETSEC_NF 			26:1 - 26:,
        RTY_NF 					27:1 - 27:,
        RETUW_NT 				28:1 - 28:,
        RETOCCYEA_NF		29:1 - 29:,
        RETACY_NF 			30:1 - 30:,
        RETSCOSTRMTH		31:1 - 31:,
        RETSCOENDMTH		32:1 - 32:,
        RCL_NF 					33:1 - 33:,
        RETCUR_CF 			34:1 - 34:,
        RETAMT_M 				35:1 - 35:EN 15/3,
        PLC_NT 					36:1 - 36:,
        RTO_NF 					37:1 - 37:,
        INT_NF 					38:1 - 38:,
        RETPAY_NF 			39:1 - 39:,
        RETKEY_CF 			40:1 - 40:,
        RETINTAMT_M 		41:1 - 41:EN 15/3,
        CED_ESTCUR      42:1 - 42:,                                     
        ESTAMT_M        43:1 - 43:EN 15/3,                              
        NAT_CF          44:1 - 44:,                                     
        ACMTRS_NT       45:1 - 45:,                                     
        ACMTRS1_NT      45:1 - 45:1,  
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:EN 15/3,
        ESTCRB_CT       50:1 - 50:,
        LIFTRTTYP_CF 		51:1 - 51:,
        ACCADMTYP_CT 		52:1 - 52:,
        SECSTS_CT 			53:1 - 53:,
        PRD_NF 					54:1 - 54:,
        SEG_NF 					55:1 - 55:,
        COMACC_B 				56:1 - 56:,
        ADJCOD_CT 			57:1 - 57:,
        ORICOD_CF 			58:1 - 58:,
        DETTRS_CF 			59:1 - 59:,
        ACCRET_B 				60:1 - 60:,
        ESTUWY_NF 			61:1 - 61:,
        LSTENDMTH_NF 		62:1 - 62:,
        PROPER_N 				63:1 - 63:,
        RTOCTY_CF 			64:1 - 64:,
        GAAP_NF 				65:1 - 65:,
        BRKSCOEGP_M 		66:1 - 66:,
        UWGRP_CF 				67:1 - 67:,
        ACM_NF          68:1 - 75:
/KEYS 
      CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      BALSHEY_NF,
			RETCTR_NF,
			RETSEC_NF,
			RTY_NF,
			RETACY_NF,
			RETCUR_CF,
			PLC_NT
/SUM TOTAL ESTAMT_M, TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M      
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/CONDITION ACMTRS_A ACMTRS1_NT = "1"
/DERIVEDFIELD ACCRET_B1 if ACMTRS_A then "A~" else "R~"
/DERIVEDFIELD ORICOD_CF1 "CBP~"
/DERIVEDFIELD GAAP_NF1 "1~"
/OUTFILE ${SORT_O}
/REFORMAT 
        SSD_DBLTRNCOD,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTR_CUR,
        AMT_MC,
        GT_CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH,
        RETSCOENDMTH,
        RCL_NF,
        RETCUR_CF,
        RETAMT_MC,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        RETINTAMT_MC,
        CED_ESTCUR,
        ESTAMT_MC,
        NAT_CF,
        ACMTRS_NT,
        ESTCTR_NF,
        ESTSEC_NF,
        LOB_CF,
        SCOEGP_MC,
        ESTCRB_CT,
        LIFTRTTYP_CF,
        ACCADMTYP_CT,
        SECSTS_CT,
        PRD_NF,
        SEG_NF,
        COMACC_B,
        ADJCOD_CT,
        ORICOD_CF1,
        DETTRS_CF,
        ACCRET_B1,
        ESTUWY_NF,
        LSTENDMTH_NF,
        PROPER_N,
        RTOCTY_CF,
        GAAP_NF1,
        BRKSCOEGP_M, 
        UWGRP_CF,
        ACM_NF
exit
EOF
SORT


NSTEP=${NJOB}_360
# Taking into Account Accounting Transactions Statistical Expiries
#------------------------------------------------------------------------------
LIBEL="Taking into Account Accounting Transactions Statistical Expiries"
PRG=ESTC2036
export ${PRG}_I1=${DFILT}/${NJOB}_355_${IB}_SORT_GTB1_O${IT}.dat
export ${PRG}_I2=${EST_160_SORT_CPLACC_O}
export ${PRG}_I3=${EST_180_SORT_LSTMTH_O}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O1${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O2${IT}.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O3${IT}.dat
EXECPRG


NSTEP=${NJOB}_365
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_CPLACC_O${IT}.dat
RMFIL ${DFILT}/${NJOB}_100_${IB}_SORT_LSTMTH_O${IT}.dat
RMFIL ${DFILT}/${NJOB}_353_${IB}_SORT_GTB1_O1${IT}.dat
RMFIL ${DFILT}/${NJOB}_355_${IB}_SORT_GTB1_O${IT}.dat


NSTEP=${NJOB}_370
# Treaties Sort
#------------------------------------------------------------------------------
LIBEL="Treaties Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O1${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        ACY_NF      14:1 - 14:,
        ACM_NF      75:1 - 75:EN,
        ACMTRS_NT   45:1 - 45:,
        ESTCTR_NF   46:1 - 46:,
        ESTSEC_NF   47:1 - 47:
/KEYS 
      ESTCTR_NF,
      ESTSEC_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT
exit
EOF
SORT


NSTEP=${NJOB}_375
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O1${IT}.dat


NSTEP=${NJOB}_385
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O2${IT}.dat

NSTEP=${NJOB}_386A
# Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_310_SORT_GT_O}
SORT_O="${DFILT}/${NSTEP}_${IB}_GT_OR${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        8:1 -  8:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:
/KEYS 
      CTR_NF,
      SEC_NF,
      UWY_NF DESCENDING
exit
EOF
SORT

NSTEP=${NJOB}_386B
# Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_386A_${IB}_GT_OR${IT}.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_GT_OR${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        8:1 -  8:,
        SEC_NF       10:1 - 10:
/KEYS 
      CTR_NF,
      SEC_NF
/SUM
/STABLE
exit
EOF
SORT

NSTEP=${NJOB}_390
# Accounting Update and Fictitious Treaties Statistical Expiries Indicator
#------------------------------------------------------------------------------
LIBEL="Accounting Update and Fictitious Treaties Statistical Expiries Indicator"
PRG=ESTC2037
export ${PRG}_I1=${DFILT}/${NJOB}_370_${IB}_SORT_GTB1_O${IT}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_386B_${IB}_GT_OR${IT}.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O1${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O2${IT}.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O3${IT}.log  #[013]
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O1${IT}.dat       > ${DFILT}/${NJOB}_ESTC2037_GTB1_O1${IT}.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O2${IT}.dat       > ${DFILT}/${NJOB}_ESTC2037_GTB1_O2${IT}.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O3${IT}.log       > ${DFILT}/${NJOB}_ESTC2037_GTB1_O3${IT}.log.gz
# ------------------------------------

NSTEP=${NJOB}_395
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_370_${IB}_SORT_GTB1_O${IT}.dat


NSTEP=${NJOB}_400
# Sort of TL filled in by Contrat, Accounting Year, Indicator
#------------------------------------------------------------------------------
LIBEL="Sort of TL filled in by Contrat, Accounting Year, Indicator"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_390_${IB}_ESTC2037_GTB1_O2${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF       8:1 -  8:,
        ACY_NF      14:1 - 14:,
        ACM_NF      75:1 - 75:EN,
        COMACC_B    56:1 - 56:
/KEYS 
      CTR_NF,
      ACY_NF,
      ACM_NF,
      COMACC_B
exit
EOF
SORT


NSTEP=${NJOB}_405
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_390_${IB}_ESTC2037_GTB1_O2${IT}.dat


NSTEP=${NJOB}_410
# Calculation of COMACC_B by CTR_NF, ACY_NF
#------------------------------------------------------------------------------
PRG=ESTC2037b
export ${PRG}_I1=${DFILT}/${NJOB}_400_${IB}_SORT_GTB1_O${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1_O${IT}.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_400_${IB}_SORT_GTB1_O${IT}.dat      > ${DFILT}/${NJOB}_400_SORT_GTB1_O${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_410_${IB}_ESTC2037b_GTB1_O${IT}.dat > ${DFILT}/${NJOB}_410_ESTC2037b_GTB1_O${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O3${IT}.dat > ${DFILT}/${NJOB}_360_ESTC2036_GTB1_O3${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_353_${IB}_SORT_GTB1_O2${IT}.dat     > ${DFILT}/${NJOB}_353_SORT_GTB1_O2${IT}.dat.gz
# ------------------------------------


NSTEP=${NJOB}_415
# Grouping All Treaties Transactions except non-sorted ones
#------------------------------------------------------------------------------
LIBEL="Grouping All Treaties Transactions except non-sorted ones"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_410_${IB}_ESTC2037b_GTB1_O${IT}.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O3${IT}.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_353_${IB}_SORT_GTB1_O2${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        SSD_DBLTRNCOD    1:1 -  7:,
        TRNCOD1_CF       6:1 -  6:1,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        GT_CED_NF       20:1 - 20:,
				BRK_NF   				21:1 - 21:,
				PAY_NF 					22:1 - 22:,
				KEY_NF 					23:1 - 23:,
				RETCTR_NF 			24:1 - 24:,
				RETEND_NT 			25:1 - 25:,
				RETSEC_NF 			26:1 - 26:,
				RTY_NF 					27:1 - 27:,
				RETUW_NT 				28:1 - 28:,
				RETOCCYEA_NF		29:1 - 29:,
				RETACY_NF 			30:1 - 30:,
				RETSCOSTRMTH		31:1 - 31:,
				RETSCOENDMTH		32:1 - 32:,
				RCL_NF 					33:1 - 33:,
				RETCUR_CF 			34:1 - 34:,
				RETAMT_M 				35:1 - 35:EN 15/3,
				PLC_NT 					36:1 - 36:,
				RTO_NF 					37:1 - 37:,
				INT_NF 					38:1 - 38:,
				RETPAY_NF 			39:1 - 39:,
				RETKEY_CF 			40:1 - 40:,
				RETINTAMT_M 		41:1 - 41:EN 15/3,
				CED_ESTCUR      42:1 - 42:,                                     
        ESTAMT_M        43:1 - 43:EN 15/3,                              
        NAT_CF          44:1 - 44:,                                     
        ACMTRS_NT       45:1 - 45:,                                     
        ACMTRS1_NT      45:1 - 45:1,  
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:EN 15/3,
        ESTCRB_CT       50:1 - 50:,
        LIFTRTTYP_CF 		51:1 - 51:,
				ACCADMTYP_CT 		52:1 - 52:,
				SECSTS_CT 			53:1 - 53:,
				PRD_NF 					54:1 - 54:,
				SEG_NF 					55:1 - 55:,
				COMACC_B 				56:1 - 56:,
				ADJCOD_CT 			57:1 - 57:,
				ORICOD_CF 			58:1 - 58:,
				DETTRS_CF 			59:1 - 59:,
				ACCRET_B 				60:1 - 60:,
				ESTUWY_NF 			61:1 - 61:,
				LSTENDMTH_NF 		62:1 - 62:,
				PROPER_N 				63:1 - 63:,
				RTOCTY_CF 			64:1 - 64:,
				GAAP_NF 				65:1 - 65:,
				BRKSCOEGP_M 		66:1 - 66:,
				UWGRP_CF 				67:1 - 67:,
        ACM_NF          68:1 - 75:
/KEYS 
      CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      BALSHEY_NF,
			RETCTR_NF,
			RETSEC_NF,
			RTY_NF,
			RETACY_NF,
			RETCUR_CF,
			PLC_NT
/SUM TOTAL ESTAMT_M, TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M      
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/CONDITION TRNCOD_A ( TRNCOD1_CF = "1" OR TRNCOD1_CF = "3")
/DERIVEDFIELD ACCRET_B1 if TRNCOD_A then "A~" else "R~"
/DERIVEDFIELD ORICOD_CF1 "CBP~"
/DERIVEDFIELD GAAP_NF1 "1~"
/OUTFILE ${SORT_O}
/REFORMAT 
        SSD_DBLTRNCOD,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTR_CUR,
        AMT_MC,
        GT_CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH,
        RETSCOENDMTH,
        RCL_NF,
        RETCUR_CF,
        RETAMT_MC,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        RETINTAMT_MC,
        CED_ESTCUR,
        ESTAMT_MC,
        NAT_CF,
        ACMTRS_NT,
        ESTCTR_NF,
        ESTSEC_NF,
        LOB_CF,
        SCOEGP_MC,
        ESTCRB_CT,
        LIFTRTTYP_CF,
        ACCADMTYP_CT,
        SECSTS_CT,
        PRD_NF,
        SEG_NF,
        COMACC_B,
        ADJCOD_CT,
        ORICOD_CF1,
        DETTRS_CF,
        ACCRET_B1,
        ESTUWY_NF,
        LSTENDMTH_NF,
        PROPER_N,
        RTOCTY_CF,
        GAAP_NF1,
        BRKSCOEGP_M,
        UWGRP_CF,
        ACM_NF
exit
EOF
SORT


NSTEP=${NJOB}_420
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_410_${IB}_ESTC2037b_GTB1_O${IT}.dat
RMFIL ${DFILT}/${NJOB}_360_${IB}_ESTC2036_GTB1_O3${IT}.dat
RMFIL ${DFILT}/${NJOB}_353_${IB}_SORT_GTB1_O2${IT}.dat


NSTEP=${NJOB}_425
# Grouping All Non-sorted Treaties Transactions
#------------------------------------------------------------------------------
LIBEL="Grouping All Non-sorted Treaties Transactions"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_390_${IB}_ESTC2037_GTB1_O1${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O1${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        SSD_DBLTRNCOD    1:1 -  7:,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        ACM_NF          75:1 - 75:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:,
        CED_ESTCUR      20:1 - 42:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        NAT_CF          44:1 - 44:,
        ACMTRS_NT       45:1 - 45:,
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:,
        ESTCRB_CT       50:1 - 50:,
        ESTCRB_UWGRP    50:1 - 75:
/KEYS 
      CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT
/SUM TOTAL ESTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT 
        SSD_DBLTRNCOD,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTR_CUR,
        AMT_MC,
        CED_ESTCUR,
        ESTAMT_MC,
        NAT_CF,
        ACMTRS_NT,
        ESTCTR_NF,
        ESTSEC_NF,
        LOB_CF,
        SCOEGP_MC,
        ESTCRB_UWGRP
exit
EOF
SORT


NSTEP=${NJOB}_430
# Merged TL file Sort
#------------------------------------------------------------------------------
LIBEL="Merged TL file Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_415_${IB}_SORT_GTB1_O${IT}.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_425_${IB}_SORT_GTB1_O1${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTB1_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACMTRS_NT 45:1 - 45:
/KEYS ACMTRS_NT
exit
EOF
SORT


NSTEP=${NJOB}_435
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_400_${IB}_SORT_GTB1_O${IT}.dat
RMFIL ${DFILT}/${NJOB}_415_${IB}_SORT_GTB1_O${IT}.dat


NSTEP=${NJOB}_440
# Parameters Actualization
#------------------------------------------------------------------------------
LIBEL="Parameters Actualization"
PRG=ESTC2130
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_430_${IB}_SORT_GTB1_O${IT}.dat
export ${PRG}_I2=${EST_FACCPAR0}
export ${PRG}_I3=${EST_VLIFEST195}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTCB1${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O2${IT}.dat
EXECPRG



NSTEP=${NJOB}_455
#------------------------------------------------------------------------------ 
gzip -c  ${EST_VLIFEST195}  > ${DFILT}/${NJOB}_450_VLIFEST_O${IT}.dat.gz
gzip -c  ${EST_LIFESTNOACC} > ${DFILT}/${NJOB}_450_LIFESTNOACC${IT}.dat.gz


#[012]
NSTEP=${NJOB}_460
# Begin sort
#/DERIVEDFIELD PLC_NT "~"
#------------------------------------------------------------------------------
LIBEL="REFORMAT SRGTCB1"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_440_${IB}_ESTC2130_SRGTCB1${IT}.dat 1000 1"
SORT_O="${EST_SRGTCB1}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        FILLER1      1:1 - 36:,
        FILLER1B    37:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER2     42:1 - 75:
/COPY
/OUTFILE ${SORT_O}
/REFORMAT 
        FILLER1,
        FILLER1B,
        RETINTAMT_M,
        FILLER2
exit
EOF
SORT


NSTEP=${NJOB}_465
# Deletion of Temporary Files
#------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*${IT}.dat"

# Job End
JOBEND