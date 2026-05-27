
#=============================================================================
# nom de l'application		: ESTIMATIONS 
#                                 Rejets / Reconduction ( Ouverture 98 )
# nom du script SHELL		: ESTO2901.cmd
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

# EST_CURGTR
# EST_DLREJGTR_1997

################
# Output files #
################

# EST_DLREJGTR_1997
# EST_FTECLEDR_1997

NSTEP=${NJOB}_15
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of binary format File"
PRG=ESTX2900
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTX2900_FACCTRSF_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_ESTX2900_FSOBBLOB_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_ESTX2900_FDETTRS_O.dat
EXECPRG

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

NSTEP=${NJOB}_82
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_75_${IB}_BCP_PERICASERET_O.dat   

#######
# GTR #
#######

NSTEP=${NJOB}_125
# Filter of the TOTGTR File on subsidiary
#------------------------------------------------------------------------------
LIBEL="Filter of TOTGTR file on subsidiary"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="/prodwk/reprise/perm/F_ESIXCURGTRR_2,3,4,12.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTR_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTRCOMPL_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, BALSHEY_NF 3:1 - 3: EN, TRNCOD_CF 6:1 - 6:, TRNCOD_2PREFIX 6:2 - 6:2, TRNCOD_SUFIX 6:8 - 6:8, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETACY_NF 30:1 - 30:, RETSCOENDMTH_NF 32:1 - 32:, RETSCOSTRMTH_NF 31:1 - 31:, RETOCCYEA_NF 29:1 - 29:, RCL_NF 33:1 - 33:, RETCUR_CF 34:1 - 34:, PLC_NT 36:1 - 36:
/CONDITION COND1 SSD_CF EQ ${SSD_CF} and BALSHEY_NF EQ ${BALSHEY_NF} and ( ( TRNCOD_SUFIX EQ "2" or TRNCOD_SUFIX EQ "4" or TRNCOD_SUFIX EQ "6" ) or ( TRNCOD_2PREFIX EQ "4" or TRNCOD_2PREFIX EQ "5" or TRNCOD_2PREFIX EQ "6" ) )
/CONDITION COND2 SSD_CF EQ ${SSD_CF} and BALSHEY_NF EQ ${BALSHEY_NF} and ( ( TRNCOD_SUFIX != "2" and TRNCOD_SUFIX != "4" and TRNCOD_SUFIX != "6" ) and ( TRNCOD_2PREFIX != "4" and TRNCOD_2PREFIX != "5" and TRNCOD_2PREFIX != "6" ) ) and (TRNCOD_SUFIX > "1" or TRNCOD_2PREFIX > "3")
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
LIBEL="Accounting transaction code transformation for the GTR"
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
SORT_I="${DFILT}/${NJOB}_130_${IB}_ESTM2901_DLREJETGTR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_135_${IB}_ESTM2904_DLRECGTRTRSF_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_130_${IB}_ESTM2901_DLRECGTR_O.dat 1000 1"
SORT_O="${DFILP}/${NCHAIN}_DLREJGTR_19971231_199712_19981112_19981210.dat APPEND 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT


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

NSTEP=${NJOB}_202
# Creation of an empty file
#------------------------------------------------------------------------------
LIBEL="Creation of an empty file"
EXECKSH "touch ${DFILT}/${NJOB}_205_${IB}_SORT_FTECLEDAR_O.dat"


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
LIBEL="Update of SSDRTO_B  internal retrocession "
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


NSTEP=${NJOB}_265
# Constitution of the new FTECLEDR file
#------------------------------------------------------------------------------
LIBEL="Constitution of the new FTECLEDR file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_260_${IB}_SORT_FTECLEDR_O.dat 1000 1"
SORT_I="${DFILT}/${NJOB}_235_${IB}_ESTC8803_FTECLEDR_O.dat 1000 1"
SORT_O="${DFILP}/${NCHAIN}_FTECLEDR_1997.dat APPEND 1000 1"
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
