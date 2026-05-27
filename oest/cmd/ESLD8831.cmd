#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : Integration des ecritures locales trimestrielles et annuelles
# nom du script SHELL           : ESLD8831.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description:
#    Integration des clotures et annulations trimestrielles ou 
#    clotures et ouvertures annuelles des ecritures locales dans les fichiers GT
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[xxx] JJ/MM/AAAA Prog. name :spira:xxxxx Comment
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
CRE_D=$1
BOOKING_D=$2
CONSOYEA=$3
CONSOMTH=$4
RETTHRESHOLD_R=$5

NSTEP=${NJOB}_05
# GTRR File Sort in progress
#-----------------------------------------------------------------------------
LIBEL="GTRR File Sort in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_DLSGTRLO}
if [ "${EST_ESLD8830_COND1}" = "Y" ]
then
	SORT_I2="${EPO_DLREJGTRLO} 1000 1"
fi
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RETRTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        PLC_NT 36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_10
# Placement File Sort In Progress
#-----------------------------------------------------------------------------
LIBEL="Placement File Sort In Progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_FPLC}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PLC_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4:,
        RETSEC_NF 5:1 - 5:,
        RETRTY_NF 6:1 - 6:,
        RETUW_NT 7:1 - 7:,
        PLC_NT 8:1 - 8:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_15
# Column Addition in GTRr containing Internal Retrocessionaire Indicator
#-----------------------------------------------------------------------------
LIBEL="Addition of Internal Retrocessionaire Indicator Information"
PRG=ESTC8931
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_PLC_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_SORT_GTRR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRR_O.dat
EXECPRG

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_PLC_O.dat      > ${DFILT}/${NJOB}_10_SORT_PLC_O.dat.gz
gzip -c ${DFILT}/${NJOB}_05_${IB}_SORT_GTRR_O.dat     > ${DFILT}/${NJOB}_05_SORT_GTRR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_15_${IB}_ESTC8931_GTRR_O.dat > ${DFILT}/${NJOB}_15_ESTC8931_GTRR_O.dat.gz
#------------------------------------------------------------------------------

NSTEP=${NJOB}_25
# Modified Retro GTR Sort in Progress
#-----------------------------------------------------------------------------
LIBEL="Modified Retro GTR Sort in Progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_15_${IB}_ESTC8931_GTRR_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  RETCTR_NF 24:1 - 24:,
         RETEND_NT 25:1 - 25:,
         RETSEC_NF 26:1 - 26:,
         RETRTY_NF 27:1 - 27:,
         RETUW_NT 28:1 - 28:,
         RETCUR_CF 34:1 - 34:,
         TRNCOD_CF 6:1 - 6:,
         RETOCCYEA_NF 29:1 - 29:,
         RETACY_NF 30:1 - 30:,
         RETSCOSTRMTH_NF 31:1 - 31:,
         RETSCOENDMTH_NF 32:1 - 32:,
         RCL_NF 33:1 - 33:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      RETCUR_CF,
      TRNCOD_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      RCL_NF
exit
EOF
SORT

NSTEP=${NJOB}_35
# GTAR Sort in Progress
#-----------------------------------------------------------------------------
LIBEL="GTAR Sort in Progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_DLSGTARLO}
if [ "${EST_ESLD8830_COND1}" = "Y" ]
then
	SORT_I2="${EPO_DLREJGTARLO} 1000 1"
fi
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  RETCTR_NF 24:1 - 24:,
         RETEND_NT 25:1 - 25:,
         RETSEC_NF 26:1 - 26:,
         RETRTY_NF 27:1 - 27:,
         RETUW_NT 28:1 - 28:,
         RETCUR_CF 34:1 - 34:,
         TRNCOD_CF 6:1 - 6:,
         RETOCCYEA_NF 29:1 - 29:,
         RETACY_NF 30:1 - 30:,
         RETSCOSTRMTH_NF 31:1 - 31:,
         RETSCOENDMTH_NF 32:1 - 32:,
         RCL_NF 33:1 - 33:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      RETCUR_CF,
      TRNCOD_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      RCL_NF
exit
EOF
SORT

NSTEP=${NJOB}_40
#GTARR Generation
#-----------------------------------------------------------------------------
LIBEL="GTARR Generation"
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
RETTHRESHOLD_R ${RETTHRESHOLD_R}
exit
EOF
PRG=ESTC8932
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_35_${IB}_SORT_GTAR_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_25_${IB}_SORT_GTRR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARR_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTANO_O.ano
EXECPRG

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_35_${IB}_SORT_GTAR_O.dat      > ${DFILT}/${NJOB}_35_SORT_GTAR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_25_${IB}_SORT_GTRR_O.dat      > ${DFILT}/${NJOB}_25_SORT_GTRR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_40_${IB}_ESTC8932_GTARR_O.dat > ${DFILT}/${NJOB}_40_ESTC8932_GTARR_O.dat.gz
#------------------------------------------------------------------------------

NSTEP=${NJOB}_50
# Accumulation and Reformating Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation and Reformating Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_40_${IB}_ESTC8932_GTARR_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTARR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2: EN,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5: EN,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 30/3,
        RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETCUR_CF 34:1 - 34:,
        RCL_NF 33:1 - 33:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        TRNCOD_CF 6:1 - 6:,
        RETAMT_M 35:1 - 35:EN 30/3
/KEYS SSD_CF ,
      ESB_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      ACY_NF,
      CUR_CF,
      RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      RETACY_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF,
      RCL_NF,
      RETOCCYEA_NF
/SUMMARIZE TOTAL AMT_M,
           TOTAL RETAMT_M
/DERIVEDFIELD SEPARATEUR    "~"
/DERIVEDFIELD SEPARATEUR2  2"~"
/DERIVEDFIELD EPSTATUS      "I"
/DERIVEDFIELD DATTRAIT     ${CRE_D}
/DERIVEDFIELD LIBINV       ${BOOKING_D}
/OUTFILE ${SORT_O}
/REFORMAT SEPARATEUR,
          SSD_CF,
          ESB_CF,
          CTR_NF,
          UWY_NF,
          UW_NT,
          END_NT,
          SEC_NF,
          CUR_CF,
          ACY_NF,
          RETCTR_NF,
          RTY_NF,
          RETSEC_NF,
          RETACY_NF,
          TRNCOD_CF,
          PLC_NT,
          RTO_NF,
          AMT_M,
          RETCUR_CF,
          RETAMT_M,
          LIBINV,
          SEPARATEUR,
          EPSTATUS,
          SEPARATEUR,
          RCL_NF,
          RETOCCYEA_NF,
          SEPARATEUR,
          OCCYEA_NF,
          SEPARATEUR2,
          DATTRAIT,
          SEPARATEUR,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF
exit
EOF
SORT

NSTEP=${NJOB}_55
# Delete temporary file
#----------------------------------------------------------------------------
LIBEL=" Delete temporary file"
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC8932_GTARR_O.dat

NSTEP=${NJOB}_60
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of the largest RETTRN_NT from TACCTRTGT"
ISQL_BASE="BEST"
ISQL_QRY="select max(RETTRN_NT) from BEST..TACCTRTGT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The largest RETTRN_NT is affected to RETTRNMAX_NT
RETTRNMAX_NT=`cat ${ISQL_FRES}`

NSTEP=${NJOB}_70
#Multiplication by -1 of CED and CNVAMT_M
#-----------------------------------------------------------------------------
LIBEL="Multiplication by -1 of CED and CNVAMT_M Add RETTRN_NT"
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
RETTRNMAX_NT ${RETTRNMAX_NT}
exit
EOF
PRG=ESTC8935
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_GTARR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARR_O.dat
EXECPRG

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_50_${IB}_SORT_GTARR_O.dat      > ${DFILT}/${NJOB}_50_SORT_GTARR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_70_${IB}_ESTC8935_GTARR_O.dat  > ${DFILT}/${NJOB}_70_ESTC8935_GTARR_O.dat.gz
#------------------------------------------------------------------------------

NSTEP=${NJOB}_71
#Suppression des 3 derniers champs
#-----------------------------------------------------------------------------
LIBEL="Reformating Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_70_${IB}_ESTC8935_GTARR_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTARR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS LIGNE 1:1 - 29:
/REFORMAT LIGNE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_73
# Delete temporary file
#----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_GTARR_O.dat

NSTEP=${NJOB}_75
# GTAA File Sort in Progress
#-----------------------------------------------------------------------------
LIBEL="GTAA File Sort in Progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_DLSGTAALO}
if [ "${EST_ESLD8830_COND1}" = "Y" ]
then
	SORT_I2="${EPO_DLREJGTAALO} 1000 1"
fi
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        TRNCOD_CF 6:1 - 6:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      TRNCOD_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF
exit
EOF
SORT

NSTEP=${NJOB}_80
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of the largest TRN_NT from TACCTRNE"
ISQL_BASE="BEST"
ISQL_QRY="select max(TRN_NT) from BEST..TACCTRNE"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The largest TRN_NT is affected to TRNMAX_NT
TRNMAX_NT=`cat ${ISQL_FRES}`

NSTEP=${NJOB}_90
#Conversion to the Acceptance Accounting Transaction table format TACCTRNE
#-----------------------------------------------------------------------------
LIBEL="Conversion to the TACCTRNE table format"
PRG=ESTC8933
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TRNMAX_NT $TRNMAX_NT
CRE_D $CRE_D
CLODAT_D $BOOKING_D
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_75_${IB}_SORT_GTAA_O.dat
export ${PRG}_I2=${EPO_OIADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ACCTRNE_O.dat
EXECPRG

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_75_${IB}_SORT_GTAA_O.dat        > ${DFILT}/${NJOB}_75_SORT_GTAA_O.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC8933_ACCTRNE_O.dat > ${DFILT}/${NJOB}_90_ESTC8933_ACCTRNE_O.dat.gz
#------------------------------------------------------------------------------

NSTEP=${NJOB}_95
# Delete temporary file
#----------------------------------------------------------------------------
LIBEL=" Delete temporary file"
RMFIL ${DFILT}/${NJOB}_75_${IB}_SORT_GTAA_O.dat

NSTEP=${NJOB}_100
# Accumulation and Reformatting GTR Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation and Reformatting GTR Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_DLSGTRLO}
if [ "${EST_ESLD8830_COND1}" = "Y" ]
then
	SORT_I2="${EPO_DLREJGTRLO} 1000 1"
fi
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        BALSHRDAY_NF 5:1 - 5: EN,
        RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETACY_NF 30:1 - 30:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        TRNCOD_CF 6:1 - 6:,
        RETAMT_M 35:1 - 35:EN 30/3
/KEYS RETCTR_NF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF,
      RETSEC_NF,
      RTY_NF,
      RETACY_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
/SUMMARIZE TOTAL RETAMT_M
/DERIVEDFIELD EPSTATUS    "I"
/DERIVEDFIELD SEPARATEUR    "~"
/DERIVEDFIELD SEPARATEUR2  2"~"
/DERIVEDFIELD DATTRAIT     ${CRE_D}
/DERIVEDFIELD LIBINV       ${BOOKING_D}
/DERIVEDFIELD ANNEEPC      ${CONSOYEA}
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SEPARATEUR,
          RETCTR_NF,
          PLC_NT,
          RTY_NF,
          SEPARATEUR2,
          RETACY_NF,
          RETACY_NF,
          SEPARATEUR,
          TRNCOD_CF,
          SEPARATEUR,
          RETSEC_NF,
          RETCUR_CF,
          SSD_CF,
          ESB_CF,
          ANNEEPC,
          SEPARATEUR,
          RETAMT_MC,
          SEPARATEUR2,
          SEPARATEUR2,
          RTO_NF,
          SEPARATEUR,
          DATTRAIT,
          SEPARATEUR,
          EPSTATUS,
          SEPARATEUR2,
          SEPARATEUR,
          LIBINV,
          SEPARATEUR,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF
exit
EOF
SORT

NSTEP=${NJOB}_105
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of the largest PLCSTA_NT from TRTOSTAE"
ISQL_BASE="BEST"
ISQL_QRY="select max(PLCSTA_NT) from BEST..TRTOSTAE"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The largest PLCSTA_NT is affected to PLCSTAMAX_NT
PLCSTAMAX_NT=`cat ${ISQL_FRES}`

NSTEP=${NJOB}_110
# Delete temporary file
#----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_105_${IB}_ISQL_O.dat
RMFIL ${DFILT}/${NJOB}_105_${IB}_ISQLRES_O.dat

NSTEP=${NJOB}_115
#Multiplication by -1 of the CNVAMT field
#-----------------------------------------------------------------------------
LIBEL="Multiplication by -1 of the CNVAMT field"
PRG=ESTC8934
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
PLCSTAMAX_NT $PLCSTAMAX_NT
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_SORT_GTRR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRR_O.dat
EXECPRG

#------------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_GTRR_O.dat     > ${DFILT}/${NJOB}_100_SORT_GTRR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_115_${IB}_ESTC8934_GTRR_O.dat > ${DFILT}/${NJOB}_115_ESTC8934_GTRR_O.dat.gz
#------------------------------------------------------------------------------

NSTEP=${NJOB}_116
#Suppression des 3 derniers champs
#-----------------------------------------------------------------------------
LIBEL="Reformating Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_115_${IB}_ESTC8934_GTRR_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS LIGNE 1:1 - 28:,
		  TRNCOD2C_CF 10:2 - 10:2
/CONDITION COND_SCORIT ("SCORIT" NC TRNCOD2C_CF )
/OUTFILE ${SORT_O}
/INCLUDE COND_SCORIT
/REFORMAT LIGNE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_120
# Delete temporary file
#----------------------------------------------------------------------------
LIBEL=" Delete temporary file"
RMFIL ${DFILT}/${NJOB}_100_${IB}_SORT_GTRR_O.dat


#              Warning !
# Do not remove all the temporary files because  some of them are used in the next job
################################################################################
JOBEND
