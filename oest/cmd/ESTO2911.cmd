 #!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS 
#                                 Rejets / Reconduction ( Ouverture 98 )
# nom du script SHELL		: ESTO2911.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 23/10/98
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   
#
# job launched by ESTO2910.cmd
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
CRE_D=$2
BALSHEY_NF=$3


###############
# Input files #
###############

# EST_GTR
# EST_CURGTR
# EST_DLREJGTR_1997
# EST_FTECLEDR_1997


################
# Output files #
################

# EST_DLREJGTR_1997
# EST_FTECLEDR_1997


NSTEP=${NJOB}_05
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of binary format File"
PRG=ESTX2900
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTX2900_FACCTRSF_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_ESTX2900_FSOBBLOB_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_ESTX2900_FDETTRS_O.dat
EXECPRG

NSTEP=${NJOB}_10
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FPLC_O.dat
BCP_QRY="execute BTRAV..PsPLACEMT_03"
BCP

NSTEP=${NJOB}_15
# Begin Sort
# sorted according to retctr_nf/retend_nt/retsec_nf/rty_nf/retuw_nt/plc_nt
#-----------------------------------------------------------------------------
LIBEL="Sorting new placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_BCP_FPLC_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FPLC_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:, RETEND_NT 4:1 - 4: , RETSEC_NF 5:1 - 5: , RTY_NF 6:1 - 6: , RETUW_NT 7:1 - 7: , PLC_NT 8:1 - 8:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_20
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_BCP_FPLC_O.dat

NSTEP=${NJOB}_25
# Constituting retrocession perimeter file
#-----------------------------------------------------------------------------
LIBEL="Constituting retrocession perimeter file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASERET_O.dat
BCP_QRY="execute BTRAV..PsPericase_03"
BCP

NSTEP=${NJOB}_30
# Sort of perimeter files by CASEXN
#-----------------------------------------------------------------------------
LIBEL="Sort of perimeter files by CASEXN"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_BCP_PERICASERET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASERET_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_35
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_25_${IB}_BCP_PERICASERET_O.dat

NSTEP=${NJOB}_40
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Delete of estimates writing for 1998"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="/prodwk/reprise/perm/ESXGTRR_2,3,4,12.dat 1000 1"
SORT_I2="/prodwk/reprise/perm/ESXCURGTRR_2,3,4,12.dat 1000 1"
SORT_I3="/workprd/formation/perm/F_ESIX7000_CURGTR.dat 1000 1"
SORT_I4="/workprd/formation/perm/F_ESIX7000_GTR.dat  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTR_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTRVIE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, BALSHEY_NF 3:1 - 3: EN, TRNCOD_2PREFIX 6:2 - 6:2, TRNCOD_SUFIX 6:8 - 6:8
/CONDITION COND1 ( SSD_CF = 2 or SSD_CF = 3 or SSD_CF = 12 ) and ( BALSHEY_NF= 1998 and  TRNCOD_SUFIX <= "1" and TRNCOD_2PREFIX <= "3" ) or (BALSHEY_NF = 1997 and (TRNCOD_SUFIX > "1" or TRNCOD_2PREFIX > "3")) 
/CONDITION COND2 SSD_CF = 4 or SSD_CF = 6
/COPY
/OUTFILE ${SORT_O}
	/INCLUDE COND1
/OUTFILE ${SORT_O2}
	/INCLUDE COND2
exit
EOF
SORT

NSTEP=${NJOB}_45
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Filter of TOTGTR file on balance sheet year"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_TOTGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, BALSHEY_NF 3:1 - 3: EN, TRNCOD_CF 6:1 - 6:, TRNCOD_2PREFIX 6:2 - 6:2, TRNCOD_SUFIX 6:8 - 6:8, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETACY_NF 30:1 - 30:, RETSCOENDMTH_NF 32:1 - 32:, RETSCOSTRMTH_NF 31:1 - 31:, RETOCCYEA_NF 29:1 - 29:, RCL_NF 33:1 - 33:, RETCUR_CF 34:1 - 34:, PLC_NT 36:1 - 36:
/CONDITION COND1 BALSHEY_NF EQ ${BALSHEY_NF} and ( ( TRNCOD_SUFIX EQ "2" or TRNCOD_SUFIX EQ "4" or TRNCOD_SUFIX EQ "6" ) or ( TRNCOD_2PREFIX EQ "4" or TRNCOD_2PREFIX EQ "5" or TRNCOD_2PREFIX EQ "6" ) )
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETACY_NF, RETSCOENDMTH_NF, RETSCOSTRMTH_NF, RETOCCYEA_NF, RCL_NF, RETCUR_CF, PLC_NT, TRNCOD_CF
/OUTFILE ${SORT_O}
	/INCLUDE COND1
exit
EOF
SORT

NSTEP=${NJOB}_50
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
export ${PRG}_I1=${DFILT}/${NJOB}_45_${IB}_SORT_TOTGTR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJETGTR_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRECGTR_O.dat
EXECPRG

NSTEP=${NJOB}_55
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_45_${IB}_SORT_TOTGTR_O.dat

NSTEP=${NJOB}_60
# Accounting transaction code transformation
#-----------------------------------------------------------------------------
LIBEL="Accounting transaction code transformation for the GTAR"
PRG=ESTM2904
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_PERICASERET_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_50_${IB}_ESTM2901_DLRECGTR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_05_${IB}_ESTX2900_FACCTRSF_O.dat
export ${PRG}_I4=${DFILT}/${NJOB}_05_${IB}_ESTX2900_FDETTRS_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRECGTRTRSF_O.dat
EXECPRG

NSTEP=${NJOB}_65
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_ESTX2900_FACCTRSF_O.dat
RMFIL ${DFILT}/${NJOB}_05_${IB}_ESTX2900_FDETTRS_O.dat

NSTEP=${NJOB}_70
# Generation of the new rejects - reconductions GTR
#-----------------------------------------------------------------------------
LIBEL="Generation of the new rejects - reconductions GTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTM2901_DLREJETGTR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_60_${IB}_ESTM2904_DLRECGTRTRSF_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_50_${IB}_ESTM2901_DLRECGTR_O.dat 1000 1"
SORT_O="${DFILP}/${NCHAIN}_DLREJGTR_19971231_199712_${CRE_D}_${CRE_D}.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_75
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledger"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_TOTGTR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_50_${IB}_ESTM2901_DLREJETGTR_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_60_${IB}_ESTM2904_DLRECGTRTRSF_O.dat 1000 1"
SORT_I4="${DFILT}/${NJOB}_50_${IB}_ESTM2901_DLRECGTR_O.dat 1000 1"
SORT_I5="${DFILT}/${NJOB}_40_${IB}_SORT_TOTGTRVIE_O.dat 1000 1"
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

NSTEP=${NJOB}_80
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_TOTGTR_O.dat
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTM2901_DLREJETGTR_O.dat
RMFIL ${DFILT}/${NJOB}_60_${IB}_ESTM2904_DLRECGTRTRSF_O.dat
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTM2901_DLRECGTR_O.dat
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_TOTGTRVIE_O.dat

NSTEP=${NJOB}_85
# begin Ksh
#-----------------------------------------------------------------------------
LIBEL="Creation of a file for the following program"
touch ${DFILT}/${NJOB}_85_${IB}_SORT_FTECLEDAR_O.dat

NSTEP=${NJOB}_90
# File generation in TTECLEDA_97 and TTECLEDR_97 tables format
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR_97 and TTECLEDA_97 tables format"
PRG=ESTC8802
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_PERICASERET_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_85_${IB}_SORT_FTECLEDAR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_75_${IB}_SORT_TOTGTR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
EXECPRG

NSTEP=${NJOB}_95
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_85_${IB}_SORT_FTECLEDAR_O.dat
RMFIL ${DFILT}/${NJOB}_75_${IB}_SORT_TOTGTR_O.dat
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_PERICASERET_O.dat

NSTEP=${NJOB}_100
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_ESTC8802_FTECLEDR_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, PLC_NT 36:1 - 36:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_105
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_90_${IB}_ESTC8802_FTECLEDR_O1.dat

NSTEP=${NJOB}_110
# Update of SSDRTO_B ( internal retrocession )
#-----------------------------------------------------------------------------
LIBEL="Update of SSDRTO_B ( internal retrocession )"
PRG=ESTC8803
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_SORT_FTECLEDR_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_15_${IB}_SORT_FPLC_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O.dat
EXECPRG

NSTEP=${NJOB}_115
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_100_${IB}_SORT_FTECLEDR_O.dat
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_FPLC_O.dat

NSTEP=${NJOB}_120
# Constitution of the new FTECLEDR file
#------------------------------------------------------------------------------
LIBEL="Constitution of the new FTECLEDR file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC8803_FTECLEDR_O.dat 1000 1"
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

NSTEP=${NJOB}_125
LIBEL="Deletion of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND
