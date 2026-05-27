
#=============================================================================
# nom de l'application		: ESTIMATIONS 
#                                 Rejets / Reconduction ( Ouverture 98 )
# nom du script SHELL		: ESTO2921.cmd
# revision			: $Revision:   1.6  $
# date de creation		: 07/04/98
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   
#
# job launched by ESTO2900.cmd
#-----------------------------------------------------------------------------
# historiques des modifications 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
CLODAT_D=$1
SSD_CF=$2
CRE_D=$3
BALSHEY_NF=$4


###############
# Input files #
###############

# EST_GTA
# EST_CURGTA
# EST_GTAR
# EST_CURGTAR
# EST_GTR
# EST_CURGTR
# EST_DLREJGTAA_1997
# EST_DLREJGTAR_1997
# EST_DLREJGTR_1997
# EST_FTECLEDA_1997
# EST_FTECLEDR_1997


################
# Output files #
################

# EST_DLREJGTAA_1997
# EST_DLREJGTAR_1997
# EST_DLREJGTR_1997
# EST_FTECLEDA_1997
# EST_FTECLEDR_1997


########
# GTAA #
########

NSTEP=${NJOB}_05
#Constituting treaty perimeter file with BTRT database fields
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Treaties perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASETRT_O.dat
BCP_QRY="execute BEST..PsPericase_01 ${SSD_CF}"
BCP

NSTEP=${NJOB}_10
#Constituting fac perimeter file with BFAC database fields
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Fac perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASEFAC_O.dat
BCP_QRY="execute BEST..PsPericase_02 ${SSD_CF}"
BCP

NSTEP=${NJOB}_15
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of binary format File"
PRG=ESTX2900
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTX2900_FACCTRSF_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_ESTX2900_FSOBBLOB_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_ESTX2900_FDETTRS_O.dat
EXECPRG

NSTEP=${NJOB}_20
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Complete Accounts Files"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FCPLACC_O.dat
BCP_QRY="execute BEST..PsCPLACC_03 '${CLODAT_D}', ${SSD_CF}"
BCP

NSTEP=${NJOB}_25
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FPLC_O.dat
BCP_QRY="execute BEST..PsPlacemt_01"
BCP

NSTEP=${NJOB}_27
# Begin Sort
# sorted according to retctr_nf/retend_nt/retsec_nf/rty_nf/retuw_nt/plc_nt
#-----------------------------------------------------------------------------
LIBEL="Sorting new placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_25_${IB}_BCP_FPLC_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FPLC_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:, RETEND_NT 4:1 - 4: , RETSEC_NF 5:1 - 5: , RTY_NF 6:1 - 6: , RETUW_NT 7:1 - 7: , PLC_NT 8:1 - 8:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_28
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_25_${IB}_BCP_FPLC_O.dat

NSTEP=${NJOB}_30
# Merge and Sort of perimeter files by Contract/Endorsement/UW Year
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Fusion..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_PERICASETRT_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_10_${IB}_BCP_PERICASEFAC_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASEACC_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_32
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_BCP_PERICASETRT_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_BCP_PERICASEFAC_O.dat

NSTEP=${NJOB}_34
# Begin programme C
# Current ACY transactions blanking for italian TOTGTAA only
#------------------------------------------------------------------------------
LIBEL="Current ACY transactions blanking for italian TOTGTAA only"
PRG=ESTM2061
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
BALSHEY_NF ${BALSHEY_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="/prodwk/reprise/perm/F_ESXCURGTA_6_1997.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_CURGTAA_O.dat"
EXECPRG 

NSTEP=${NJOB}_36
#
#-----------------------------------------------------------------------------
# Begin sort : italian blanking accumulation
#------------------------------------------------------------------------------
LIBEL="italian TOTGTAA blanking accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_34_${IB}_ESTM2061_CURGTAA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,  
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 15/3,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      CUR_CF,
      TRNCOD_CF
/SUMMARIZE TOTAL AMT_M
exit
EOF
SORT   

#################################
# Double entry transaction code #
#################################

NSTEP=${NJOB}_38
#Double entry transaction code addition in  TOTGTAA
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition TOTGTAA in progress ..."
PRG=ESTM7603
export ${PRG}_I1="${DFILT}/${NJOB}_36_${IB}_SORT_CURGTAA_O.dat"
export ${PRG}_I2=${DFILT}/${NJOB}_15_${IB}_ESTX2900_FDETTRS_O.dat
export ${PRG}_O1="${DFILP}/${NCHAIN}_BILDECGTAA_19971231_199712_19981112_19981112.dat"
EXECPRG
     

NSTEP=${NJOB}_40
# Filter of the TOTGTAA File on subsidiary
#------------------------------------------------------------------------------
LIBEL="Filter of TOTGTAA file on subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="/prodwk/reprise/perm/F_ESXCURGTA_6_1997.dat 1000 1"
SORT_I2="${DFILP}/${NCHAIN}_BILDECGTAA_19971231_199712_19981112_19981112.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAACOMPL_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, BALSHEY_NF 3:1 - 3: EN, TRNCOD_CF 6:1 - 6:, TRNCOD_PREFIX 6:1 - 6:1, TRNCOD_2PREFIX 6:2 - 6:2, TRNCOD_SUFIX 6:8 - 6:8, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, ACY_NF 14:1 - 14:, SCOENDMTH_NF 16:1 - 16:, SCOSTRMTH_NF 15:1 - 15:, OCCYEA_NF 13:1 - 13:, CLM_NF 17:1 - 17:, CUR_CF 18:1 - 18:
/CONDITION COND1 SSD_CF EQ ${SSD_CF} and BALSHEY_NF EQ ${BALSHEY_NF} and ( ( TRNCOD_SUFIX EQ "2" or TRNCOD_SUFIX EQ "4" or TRNCOD_SUFIX EQ "6" ) or ( TRNCOD_2PREFIX EQ "4" or TRNCOD_2PREFIX EQ "5" or TRNCOD_2PREFIX EQ "6" or TRNCOD_2PREFIX EQ "C" or TRNCOD_2PREFIX EQ "S") ) and ( TRNCOD_PREFIX EQ "1" or TRNCOD_PREFIX EQ "3" )
/CONDITION COND2 SSD_CF EQ ${SSD_CF} and BALSHEY_NF EQ ${BALSHEY_NF} and ( ( TRNCOD_SUFIX != "2" and TRNCOD_SUFIX != "4" and TRNCOD_SUFIX != "6" ) and ( TRNCOD_2PREFIX != "4" and TRNCOD_2PREFIX != "5" and TRNCOD_2PREFIX != "6" and TRNCOD_2PREFIX != "S" and TRNCOD_2PREFIX != "C") ) and ( TRNCOD_PREFIX EQ "1" or TRNCOD_PREFIX EQ "3" )
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF, SCOENDMTH_NF, SCOSTRMTH_NF, OCCYEA_NF, CLM_NF, CUR_CF, TRNCOD_CF
/OUTFILE ${SORT_O}
	/INCLUDE COND1
/OUTFILE ${SORT_O2}
	/INCLUDE COND2
exit
EOF
SORT

NSTEP=${NJOB}_45
# Acceptance retrocession reversal and carried forward of previous balance sheetin the book
#-----------------------------------------------------------------------------
LIBEL="Acceptance retrocession reversal and carried forward in progress ..."
PRG=ESTM2901
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_TOTGTAA_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJETGTAA_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRECGTAA_O.dat
EXECPRG

NSTEP=${NJOB}_50
# Accounting transaction code transformation
#-----------------------------------------------------------------------------
LIBEL="Accounting transaction code transformation for the GTAA"
PRG=ESTM2902
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_PERICASEACC_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_45_${IB}_ESTM2901_DLRECGTAA_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_15_${IB}_ESTX2900_FACCTRSF_O.dat
export ${PRG}_I4=${DFILT}/${NJOB}_15_${IB}_ESTX2900_FDETTRS_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRECGTAATRSF_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASEACC_O.dat
EXECPRG

NSTEP=${NJOB}_55
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_PERICASEACC_O.dat

NSTEP=${NJOB}_65
# Generation of the new rejects - reconductions GTAA
#-----------------------------------------------------------------------------
LIBEL="Generation of the new rejects - reconductions GTAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_DLREJGTAA_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_45_${IB}_ESTM2901_DLREJETGTAA_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_50_${IB}_ESTM2902_DLRECGTAATRSF_O.dat 1000 1"
SORT_I4="${DFILT}/${NJOB}_45_${IB}_ESTM2901_DLRECGTAA_O.dat 1000 1"
SORT_O="${DFILP}/${NCHAIN}_DLREJGTAA_19971231_199712_19981112_19981112.dat 1000 1 "
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_70
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_DLREJGTAA_O.dat

########
# GTAR #
########

NSTEP=${NJOB}_75
# Constituting retrocession perimeter file
#-----------------------------------------------------------------------------
LIBEL="Constituting retrocession perimeter file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASERET_O.dat
BCP_QRY="execute BEST..PsPericase_03 ${SSD_CF}"
BCP

NSTEP=${NJOB}_80
# Sort of perimeter files by CASEXN
#-----------------------------------------------------------------------------
LIBEL="Sort of perimeter files by CASEXN"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_BCP_PERICASERET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASERET_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_81
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_75_${IB}_BCP_PERICASERET_O.dat

NSTEP=${NJOB}_82
# Sort of perimeter files by CASEXN
#-----------------------------------------------------------------------------
LIBEL="Sort of perimeter files by CASEXN"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="/prodwk/reprise/perm/F_ESXCURGTAR_6_1997.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESXCURGTAR_6_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RETUWY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RETUWY_NF, RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_84
# Begin programme C
# Current ACY transactions blanking for italian TOTGTAR only
#------------------------------------------------------------------------------
LIBEL="Current ACY transactions blanking for italian TOTGTAR only"
PRG=ESTM2561
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
BALSHEY_NF ${BALSHEY_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NJOB}_82_${IB}_SORT_ESXCURGTAR_6_O.dat"
export ${PRG}_I2="${DFILT}/${NJOB}_80_${IB}_SORT_PERICASERET_O.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_CURGTAR_O1.dat"
EXECPRG
         
NSTEP=${NJOB}_86
#
#-----------------------------------------------------------------------------
# Begin sort : italian blanking accumulation
#------------------------------------------------------------------------------
LIBEL="italian TOTGTAR blanking accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_84_${IB}_ESTM2561_CURGTAR_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,   
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 15/3,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RETRTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,   
      UW_NT,
      ACY_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETCUR_CF,
      TRNCOD_CF
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M
exit
EOF
SORT   

NSTEP=${NJOB}_87
#Double entry transaction code addition in TOTGTAR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in TOTGTAR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_86_${IB}_SORT_CURGTAR_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_15_${IB}_ESTX2900_FDETTRS_O.dat
export ${PRG}_O1="${DFILP}/${NCHAIN}_BILDECGTAR_19971231_199712_19981112_19981112.dat"
EXECPRG

NSTEP=${NJOB}_90
# Filter of the TOTGTAR File on subsidiary
#------------------------------------------------------------------------------
LIBEL="Filter of TOTGTAR file on subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="/prodwk/reprise/perm/F_ESXCURGTAR_6_1997.dat 1000 1"
SORT_I2="${DFILP}/${NCHAIN}_BILDECGTAR_19971231_199712_19981112_19981112.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAR_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTARCOMPL_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, BALSHEY_NF 3:1 - 3: EN, TRNCOD_CF 6:1 - 6:, TRNCOD_PREFIX 6:1 - 6:1, TRNCOD_2PREFIX 6:2 - 6:2, TRNCOD_SUFIX 6:8 - 6:8, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, ACY_NF 14:1 - 14:, SCOENDMTH_NF 16:1 - 16:, SCOSTRMTH_NF 15:1 - 15:, OCCYEA_NF 13:1 - 13:, CLM_NF 17:1 - 17:, CUR_CF 18:1 - 18:, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETACY_NF 30:1 - 30:, RETSCOENDMTH_NF 32:1 - 32:, RETSCOSTRMTH_NF 31:1 - 31:, RETOCCYEA_NF 29:1 - 29:, RCL_NF 33:1 - 33:, RETCUR_CF 34:1 - 34:, PLC_NT 36:1 - 36:
/CONDITION COND1 SSD_CF EQ ${SSD_CF} and BALSHEY_NF EQ ${BALSHEY_NF} and ( ( TRNCOD_SUFIX EQ "2" or TRNCOD_SUFIX EQ "4" or TRNCOD_SUFIX EQ "6" ) or ( TRNCOD_2PREFIX EQ "4" or TRNCOD_2PREFIX EQ "5" or TRNCOD_2PREFIX EQ "6" or TRNCOD_2PREFIX EQ "S" or TRNCOD_2PREFIX EQ "C") ) and ( TRNCOD_PREFIX EQ "2" or TRNCOD_PREFIX EQ "4" )
/CONDITION COND2 SSD_CF EQ ${SSD_CF} and BALSHEY_NF EQ ${BALSHEY_NF} and ( ( TRNCOD_SUFIX != "2" and TRNCOD_SUFIX != "4" and TRNCOD_SUFIX != "6" ) and ( TRNCOD_2PREFIX != "4" and TRNCOD_2PREFIX != "5" and TRNCOD_2PREFIX != "6" and TRNCOD_2PREFIX != "S" and TRNCOD_2PREFIX != "C" ) ) and ( TRNCOD_PREFIX EQ "2" or TRNCOD_PREFIX EQ "4" )
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF, SCOENDMTH_NF, SCOSTRMTH_NF, OCCYEA_NF, CLM_NF, CUR_CF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETACY_NF, RETSCOENDMTH_NF, RETSCOSTRMTH_NF, RETOCCYEA_NF, RCL_NF, RETCUR_CF, PLC_NT, TRNCOD_CF
/OUTFILE ${SORT_O}
	/INCLUDE COND1
/OUTFILE ${SORT_O2}
	/INCLUDE COND2
exit
EOF
SORT

NSTEP=${NJOB}_100
# Acceptance retrocession reversal and carried forward of previous balance sheetin the book
#-----------------------------------------------------------------------------
LIBEL="Acceptance retrocession reversal and carried forward in progress ..."
PRG=ESTM2901
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D $CLODAT_D
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_90_${IB}_SORT_TOTGTAR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJETGTAR_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRECGTAR_O.dat
EXECPRG

NSTEP=${NJOB}_102
# Sort of DLRECGTAR File
#------------------------------------------------------------------------------
LIBEL="Sort of DLRECGTAR File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_ESTM2901_DLRECGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLRECGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_105
# Accounting transaction code transformation
#-----------------------------------------------------------------------------
LIBEL="Accounting transaction code transformation for the GTAR"
PRG=ESTM2903
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_PERICASERET_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_102_${IB}_SORT_DLRECGTAR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_15_${IB}_ESTX2900_FACCTRSF_O.dat
export ${PRG}_I4=${DFILT}/${NJOB}_15_${IB}_ESTX2900_FDETTRS_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRECGTARTRSF_O.dat
EXECPRG

NSTEP=${NJOB}_115
# Generation of the new rejects - reconductions GTAR
#-----------------------------------------------------------------------------
LIBEL="Generation of the new rejects - reconductions GTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_SORT_DLREJGTAR_1997_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_100_${IB}_ESTM2901_DLREJETGTAR_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_105_${IB}_ESTM2903_DLRECGTARTRSF_O.dat 1000 1"
SORT_I4="${DFILT}/${NJOB}_100_${IB}_ESTM2901_DLRECGTAR_O.dat 1000 1"
SORT_O="${DFILP}/${NCHAIN}_DLREJGTAR_19971231_199712_19980514_19980514.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_116
# Sort of CURGTR files by CASEXN
#-----------------------------------------------------------------------------
LIBEL="Sort of CURGTR files by CASEXN"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="/prodwk/reprise/perm/F_ESXCURGTRR_6_1997.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESXCURGTRR_6_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RETUWY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RETUWY_NF, RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_117
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_110_${IB}_SORT_DLREJGTAR_1997_O.dat
RMFIL ${DFILT}/${NJOB}_102_${IB}_SORT_DLRECGTAR_O.dat

#######
# GTR #
#######

NSTEP=${NJOB}_118
# Begin programme C
# Current ACY transactions blanking for italian TOTGTR only
#------------------------------------------------------------------------------
LIBEL="Current ACY transactions blanking for italian TOTGTR only"
PRG=ESTM2561
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
BALSHEY_NF ${BALSHEY_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NJOB}_116_${IB}_SORT_ESXCURGTRR_6_O.dat"
export ${PRG}_I3="${DFILT}/${NJOB}_80_${IB}_SORT_PERICASERET_O.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_CURGTR_O1.dat"
EXECPRG

NSTEP=${NJOB}_120
#
#-----------------------------------------------------------------------------
# Begin sort  : italian blanking accumulation
#------------------------------------------------------------------------------
LIBEL="italian TOTGTR blanking accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_118_${IB}_ESTM2561_CURGTR_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 15/3,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RETRTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      PLC_NT,
      RETACY_NF,
      RETCUR_CF,
      TRNCOD_CF
/SUMMARIZE TOTAL RETAMT_M
exit
EOF
SORT   

STEP=${NJOB}_122
#Double entry transaction code addition in TOTGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in TOTGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1="${DFILT}/${NJOB}_120_${IB}_SORT_CURGTR_O.dat"
export ${PRG}_I2=${DFILT}/${NJOB}_15_${IB}_ESTX2900_FDETTRS_O.dat
export ${PRG}_O1="${DFILP}/${NCHAIN}_BILDECGTR_19971231_199712_19981112_19981112.dat"
EXECPRG 
    
NSTEP=${NJOB}_125
# Filter of the TOTGTR File on subsidiary
#------------------------------------------------------------------------------
LIBEL="Filter of TOTGTR file on subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="/prodwk/reprise/perm/F_ESXCURGTRR_6_1997.dat 1000 1"
SORT_I2="${DFILP}/${NCHAIN}_BILDECGTR_19971231_199712_19981112_19981112.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTR_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTRCOMPL_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, BALSHEY_NF 3:1 - 3: EN, TRNCOD_CF 6:1 - 6:, TRNCOD_2PREFIX 6:2 - 6:2, TRNCOD_SUFIX 6:8 - 6:8, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETACY_NF 30:1 - 30:, RETSCOENDMTH_NF 32:1 - 32:, RETSCOSTRMTH_NF 31:1 - 31:, RETOCCYEA_NF 29:1 - 29:, RCL_NF 33:1 - 33:, RETCUR_CF 34:1 - 34:, PLC_NT 36:1 - 36:
/CONDITION COND1 SSD_CF EQ ${SSD_CF} and BALSHEY_NF EQ ${BALSHEY_NF} and ( ( TRNCOD_SUFIX EQ "2" or TRNCOD_SUFIX EQ "4" or TRNCOD_SUFIX EQ "6" ) or ( TRNCOD_2PREFIX EQ "4" or TRNCOD_2PREFIX EQ "5" or TRNCOD_2PREFIX EQ "6" or TRNCOD_2PREFIX EQ "S" or TRNCOD_2PREFIX EQ "C") )
/CONDITION COND2 SSD_CF EQ ${SSD_CF} and BALSHEY_NF EQ ${BALSHEY_NF} and ( ( TRNCOD_SUFIX != "2" and TRNCOD_SUFIX != "4" and TRNCOD_SUFIX != "6" ) and ( TRNCOD_2PREFIX != "4" and TRNCOD_2PREFIX != "5" and TRNCOD_2PREFIX != "6" and TRNCOD_2PREFIX != "C" and TRNCOD_2PREFIX != "S") )
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETACY_NF, RETSCOENDMTH_NF, RETSCOSTRMTH_NF, RETOCCYEA_NF, RCL_NF, RETCUR_CF, PLC_NT, TRNCOD_CF
/OUTFILE ${SORT_O}
	/INCLUDE COND1
/OUTFILE ${SORT_O2}
	/INCLUDE COND2
exit
EOF
SORT

NSTEP=${NJOB}_130
#Retrocession Retrocession reversal and carried forward of previous balance sheet in the book
#-----------------------------------------------------------------------------
LIBEL="Retrocession retrocession reversal and carried forward in progress ..."
PRG=ESTM2901
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_125_${IB}_SORT_TOTGTR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJETGTR_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRECGTR_O.dat
EXECPRG

NSTEP=${NJOB}_135
# Accounting transaction code transformation
#-----------------------------------------------------------------------------
LIBEL="Accounting transaction code transformation for the GTAR"
PRG=ESTM2904
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_PERICASERET_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_130_${IB}_ESTM2901_DLRECGTR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_15_${IB}_ESTX2900_FACCTRSF_O.dat
export ${PRG}_I4=${DFILT}/${NJOB}_15_${IB}_ESTX2900_FDETTRS_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRECGTRTRSF_O.dat
EXECPRG

NSTEP=${NJOB}_140
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTX2900_FACCTRSF_O.dat

NSTEP=${NJOB}_150
# Generation of the new rejects - reconductions GTR
#-----------------------------------------------------------------------------
LIBEL="Generation of the new rejects - reconductions GTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_145_${IB}_SORT_DLREJGTR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_130_${IB}_ESTM2901_DLREJETGTR_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_135_${IB}_ESTM2904_DLRECGTRTRSF_O.dat 1000 1"
SORT_I4="${DFILT}/${NJOB}_130_${IB}_ESTM2901_DLRECGTR_O.dat 1000 1"
SORT_O="${DFILP}/${NCHAIN}_DLREJGTR_19971231_199712_19981112_19981112.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_155
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_145_${IB}_SORT_DLREJGTR_O.dat

NSTEP=${NJOB}_160
# Sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_TOTGTAA_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_40_${IB}_SORT_TOTGTAACOMPL_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_45_${IB}_ESTM2901_DLREJETGTAA_O.dat 1000 1"
SORT_I4="${DFILT}/${NJOB}_50_${IB}_ESTM2902_DLRECGTAATRSF_O.dat 1000 1"
SORT_I5="${DFILT}/${NJOB}_45_${IB}_ESTM2901_DLRECGTAA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, LIGNEGT 1:1 - 39: , RETKEY_CF 40:1 - 40: 
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/DERIVEDFIELD DATTRAIT     ${CRE_D}
/DERIVEDFIELD USER         "BS97"
/DERIVEDFIELD SEPARATEUR   "~"
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT , RETKEY_CF , DATTRAIT, SEPARATEUR, USER, SEPARATEUR, DATTRAIT, SEPARATEUR, USER
exit
EOF
SORT

NSTEP=${NJOB}_165
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_TOTGTAA_O.dat
RMFIL ${DFILT}/${NJOB}_45_${IB}_ESTM2901_DLREJETGTAA_O.dat
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTM2902_DLRECGTAATRSF_O.dat
RMFIL ${DFILT}/${NJOB}_45_${IB}_ESTM2901_DLRECGTAA_O.dat
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_TOTGTAACOMPL_O.dat

NSTEP=${NJOB}_170
# Sort of the Acceptance and Retrocession files
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_SORT_TOTGTAR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_90_${IB}_SORT_TOTGTARCOMPL_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_100_${IB}_ESTM2901_DLREJETGTAR_O.dat 1000 1"
SORT_I4="${DFILT}/${NJOB}_105_${IB}_ESTM2903_DLRECGTARTRSF_O.dat 1000 1"
SORT_I5="${DFILT}/${NJOB}_100_${IB}_ESTM2901_DLRECGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, LIGNEGT 1:1 - 39: , RETKEY_CF 40:1 - 40: 
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/DERIVEDFIELD DATTRAIT     ${CRE_D}
/DERIVEDFIELD USER         "BS97"
/DERIVEDFIELD SEPARATEUR   "~"
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT , RETKEY_CF , DATTRAIT, SEPARATEUR, USER, SEPARATEUR, DATTRAIT, SEPARATEUR, USER
exit
EOF
SORT

NSTEP=${NJOB}_175
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_TOTGTAR_O.dat
RMFIL ${DFILT}/${NJOB}_100_${IB}_ESTM2901_DLREJETGTAR_O.dat
RMFIL ${DFILT}/${NJOB}_105_${IB}_ESTM2903_DLRECGTARTRSF_O.dat
RMFIL ${DFILT}/${NJOB}_100_${IB}_ESTM2901_DLRECGTAR_O.dat
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_TOTGTARCOMPL_O.dat

NSTEP=${NJOB}_180
# Creation of an empty contract group file
#------------------------------------------------------------------------------
LIBEL="Creation of an empty contract group file"
EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_KSH_FCTRGRO_O.dat"

NSTEP=${NJOB}_185
# File generation in TTECLEDA_97 table format
#-----------------------------------------------------------------------------
LIBEL="Files generation in TTECLEDA_97 table format"
PRG=ESTC8801
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_ESTM2902_PERICASEACC_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_160_${IB}_SORT_TOTGTAA_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_180_${IB}_KSH_FCTRGRO_O.dat
export ${PRG}_I4=${DFILT}/${NJOB}_20_${IB}_BCP_FCPLACC_O.dat
export ${PRG}_I5=${DFILT}/${NJOB}_170_${IB}_SORT_TOTGTAR_O.dat
export ${PRG}_I6=${DFILT}/${NJOB}_15_${IB}_ESTX2900_FSOBBLOB_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAA_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
EXECPRG

NSTEP=${NJOB}_190
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_160_${IB}_SORT_TOTGTAA_O.dat
RMFIL ${DFILT}/${NJOB}_180_${IB}_KSH_FCTRGRO_O.dat
RMFIL ${DFILT}/${NJOB}_170_${IB}_SORT_TOTGTAR_O.dat
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTM2902_PERICASEACC_O.dat
RMFIL ${DFILT}/${NJOB}_20_${IB}_BCP_FCPLACC_O.dat
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTX2900_FSOBBLOB_O.dat

NSTEP=${NJOB}_195
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledger"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_125_${IB}_SORT_TOTGTR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_125_${IB}_SORT_TOTGTRCOMPL_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_130_${IB}_ESTM2901_DLREJETGTR_O.dat 1000 1"
SORT_I4="${DFILT}/${NJOB}_135_${IB}_ESTM2904_DLRECGTRTRSF_O.dat 1000 1"
SORT_I5="${DFILT}/${NJOB}_130_${IB}_ESTM2901_DLRECGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, LIGNEGT 1:1 - 39: , RETKEY_CF 40:1 - 40: 
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT
/DERIVEDFIELD DATTRAIT     ${CRE_D}
/DERIVEDFIELD USER         "BS97"
/DERIVEDFIELD SEPARATEUR   "~"
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT, RETKEY_CF, DATTRAIT, SEPARATEUR, USER, SEPARATEUR, DATTRAIT, SEPARATEUR, USER
exit
EOF
SORT

NSTEP=${NJOB}_200
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_125_${IB}_SORT_TOTGTR_O.dat
RMFIL ${DFILT}/${NJOB}_130_${IB}_ESTM2901_DLREJETGTR_O.dat
RMFIL ${DFILT}/${NJOB}_135_${IB}_ESTM2904_DLRECGTRTRSF_O.dat
RMFIL ${DFILT}/${NJOB}_130_${IB}_ESTM2901_DLRECGTR_O.dat
RMFIL ${DFILT}/${NJOB}_125_${IB}_SORT_TOTGTRCOMPL_O.dat

NSTEP=${NJOB}_205
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_185_${IB}_ESTC8801_FTECLEDAR_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_210
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_185_${IB}_ESTC8801_FTECLEDAR_O2.dat

NSTEP=${NJOB}_215
# File generation in TTECLEDA_97 and TTECLEDR_97 tables format
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR_97 and TTECLEDA_97 tables format"
PRG=ESTC8802
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_PERICASERET_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_205_${IB}_SORT_FTECLEDAR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_195_${IB}_SORT_TOTGTR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
EXECPRG

NSTEP=${NJOB}_220
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_205_${IB}_SORT_FTECLEDAR_O.dat
RMFIL ${DFILT}/${NJOB}_195_${IB}_SORT_TOTGTR_O.dat
RMFIL ${DFILT}/${NJOB}_80_${IB}_SORT_PERICASERET_O.dat

NSTEP=${NJOB}_225
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_215_${IB}_ESTC8802_FTECLEDR_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, PLC_NT 36:1 - 36:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_230
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_215_${IB}_ESTC8802_FTECLEDR_O1.dat

NSTEP=${NJOB}_235
# Update of SSDRTO_B ( internal retrocession )
#-----------------------------------------------------------------------------
LIBEL="Update of SSDRTO_B ( internal retrocession )"
PRG=ESTC8803
export ${PRG}_I1=${DFILT}/${NJOB}_225_${IB}_SORT_FTECLEDR_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_27_${IB}_SORT_FPLC_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O.dat
EXECPRG

NSTEP=${NJOB}_240
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_225_${IB}_SORT_FTECLEDR_O.dat
RMFIL ${DFILT}/${NJOB}_27_${IB}_SORT_FPLC_O.dat

NSTEP=${NJOB}_250
# Merge of TL files 
#------------------------------------------------------------------------------
LIBEL="Merge of Technical Ledgers files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_185_${IB}_ESTC8801_FTECLEDAA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_215_${IB}_ESTC8802_FTECLEDAR_O2.dat 1000 1"
SORT_O="${DFILP}/${NCHAIN}_FTECLEDA_1997.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, ESB_CF 2:1 - 2: EN, TRNCOD_CF 6:1 - 6:
/KEYS TRNCOD_CF, SSD_CF, ESB_CF
exit
EOF
SORT

NSTEP=${NJOB}_255
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_185_${IB}_ESTC8801_FTECLEDAA_O1.dat
RMFIL ${DFILT}/${NJOB}_215_${IB}_ESTC8802_FTECLEDAR_O2.dat

NSTEP=${NJOB}_265
# Constitution of the new FTECLEDR file
#------------------------------------------------------------------------------
LIBEL="Constitution of the new FTECLEDR file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_235_${IB}_ESTC8803_FTECLEDR_O.dat 1000 1"
SORT_O="${DFILP}/${NCHAIN}_FTECLEDR_1997.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, ESB_CF 2:1 - 2: EN, TRNCOD_CF 6:1 - 6:
/KEYS TRNCOD_CF, SSD_CF, ESB_CF
exit
EOF
SORT

###############################
# Deletion of temporary files #
###############################

NSTEP=${NJOB}_270
LIBEL="Deletion of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND
