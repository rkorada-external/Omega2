#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE 
#                                 SHERPA
# nom du script SHELL		: ESID1021.cmd
# revision			: 
# date de creation		: 10/07/98
# auteur			: L.Capomazza
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Life
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================
#set -x
. ${DUTI}/fctgen.cmd


#Get input parameter
CLODAT_D=$1

# Initialization of the Job
JOBINIT

NSTEP=${NJOB}_05
# Selection and Conversion
#------------------------------------------------------------------------------
LIBEL="Selection and Conversion"
PRG=ESTC1025
export ${PRG}_I1=${EST_FTECLEDA}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ERRORA.dat
EXECPRG

NSTEP=${NJOB}_10
# Specific program for undefined lob (1)
#------------------------------------------------------------------------------
LIBEL="Specific program for undefined lob (1)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_ESTC1025_FTECLEDA.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS  SSD_CF 1: 1 - 1:, LOBACC_CF 7: 1 - 7:, CTR_NF 13: 1 - 13:, SEC_NF 14: 1 - 14:, UWY_NF 15: 1 - 15:
/KEYS SSD_CF , CTR_NF , SEC_NF , UWY_NF , LOBACC_CF DESCENDING
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_15
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_05_${IB}_ESTC1025_FTECLEDA.dat

NSTEP=${NJOB}_20
# Specific program for undefined lob (2)
#------------------------------------------------------------------------------
LIBEL="Specific program for undefined lob (2)"
PRG=ESTC1034
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_FTECLEDA.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA.dat
EXECPRG

NSTEP=${NJOB}_25
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_FTECLEDA.dat

NSTEP=${NJOB}_30
# Grouping figures by selected criteria
#------------------------------------------------------------------------------
LIBEL="Grouping figures by selected criteria"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_ESTC1034_FTECLEDA.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS  SSD_CF 1: 1 - 1:, BALSHEY_NF 2: 1 - 2:, TRNCOD_CF 3: 1 - 3:, CTRNAT_NF 4: 1 - 4:, CUR_CF 5: 1 - 5:, AMT_CF 6: 1 - 6:EN 15/3, LOBACC_CF 7: 1 - 7:, NATACC_CF 8: 1 - 8:
/KEYS SSD_CF , BALSHEY_NF , TRNCOD_CF , CTRNAT_NF , CUR_CF , LOBACC_CF , NATACC_CF 
/SUM TOTAL AMT_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_35
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_20_${IB}_ESTC1034_FTECLEDA.dat

NSTEP=${NJOB}_40
# Conversion and Decodification
#------------------------------------------------------------------------------
LIBEL="Conversion and Decodification"
PRG=ESTC1026
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDA.dat
export ${PRG}_I2=${EST_FSUBSID}
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA.dat
EXECPRG

NSTEP=${NJOB}_45
# Grouping by selected criteria
#------------------------------------------------------------------------------
LIBEL="Grouping by selected criteria"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ESTC1026_FTECLEDA.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS  SSD_CF 1: 1 - 1:, NAT_CF 2: 1 - 2:, LOBACC_CF 4: 1 - 4:, TRNCOD_CF 5: 1 - 5:, AMT_CF 6: 1 - 6:EN 15/3
/KEYS SSD_CF , NAT_CF , LOBACC_CF , TRNCOD_CF 
/SUM TOTAL AMT_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_50
# Creation of the file GROSS (1)
#------------------------------------------------------------------------------
LIBEL="Creation of the file GROSS (1)"
PRG=ESTC1029
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_45_${IB}_SORT_FTECLEDA.dat
export ${PRG}_I2=${EST_FSUBSID}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA.dat
EXECPRG

NSTEP=${NJOB}_55
# Creation of the user file GROSS (2)
#------------------------------------------------------------------------------
LIBEL="Creation of the user file GROSS (2)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1029_FTECLEDA.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS  INV_CF 1: 1 - 1:, SSD_CF 2: 1 - 2:, COD_CF 4: 1 - 4:, TRNCOD_CF 6: 1 - 6:, AMT_CF 7: 1 - 7:EN 15/3, CUR_CF 8: 1 - 8 :
/KEYS SSD_CF , TRNCOD_CF 
/SUM TOTAL AMT_CF
/OUTFILE ${SORT_O}
/REFORMAT INV_CF , SSD_CF , COD_CF , TRNCOD_CF , AMT_CF , CUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_60
# Selection and Conversion
#------------------------------------------------------------------------------
LIBEL="Selection and Conversion"
PRG=ESTC1030
export ${PRG}_I1=${EST_FTECLEDR}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ERRORR.dat
EXECPRG

NSTEP=${NJOB}_65
# Specific program for undefined lob (1)
#------------------------------------------------------------------------------
LIBEL="Specific program for undefined lob (1)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESTC1030_FTECLEDR.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS  SSD_CF 1: 1 - 1:, LOB_CF 7: 1 - 7:, CTR_NF 13: 1 - 13:, SEC_NF 14: 1 - 14:, UWY_NF 15: 1 - 15:
/KEYS SSD_CF , CTR_NF , SEC_NF , UWY_NF , LOB_CF DESCENDING
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_70
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_60_${IB}_ESTC1030_FTECLEDR.dat

NSTEP=${NJOB}_75
# Specific program for undefined lob (2)
#------------------------------------------------------------------------------
LIBEL="Specific program for undefined lob (2)"
PRG=ESTC1035
export ${PRG}_I1=${DFILT}/${NJOB}_65_${IB}_SORT_FTECLEDR.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR.dat
EXECPRG

NSTEP=${NJOB}_80
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_65_${IB}_SORT_FTECLEDR.dat

NSTEP=${NJOB}_85
# Grouping figures by selected criteria
#------------------------------------------------------------------------------
LIBEL="Grouping figures by selected criteria"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_ESTC1035_FTECLEDR.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS  SSD_CF 1: 1 - 1:, BALSHEY_NF 2: 1 - 2:, TRNCOD_CF 3: 1 - 3:, CTRNAT_NF 4: 1 - 4:, CUR_CF 5: 1 - 5:, AMT_CF 6: 1 - 6:EN 15/3, LOB_CF 7: 1 - 7:, NAT_CF 8: 1 - 8:, TOP_RTO 9: 1 - 9:
/KEYS SSD_CF , BALSHEY_NF , TRNCOD_CF , CTRNAT_NF , CUR_CF , LOB_CF , NAT_CF , TOP_RTO
/SUM TOTAL AMT_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_90
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_75_${IB}_ESTC1035_FTECLEDR.dat

NSTEP=${NJOB}_95
# Conversion and Decodification
#------------------------------------------------------------------------------
LIBEL="Conversion and Decodification"
PRG=ESTC1031
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_85_${IB}_SORT_FTECLEDR.dat
export ${PRG}_I2=${EST_FSUBSID}
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR.dat
EXECPRG

NSTEP=${NJOB}_100
# Grouping by selected criteria
#------------------------------------------------------------------------------
LIBEL="Grouping by selected criteria"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_ESTC1031_FTECLEDR.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS  SSD_CF 1: 1 - 1:, NAT_CF 2: 1 - 2:, TOP_RTO 3: 1 - 3:, LOB_CF 4: 1 - 4:, TRNCOD_CF 5: 1 - 5:, AMT_CF 6: 1 - 6:EN 15/3
/KEYS SSD_CF , NAT_CF , TOP_RTO , LOB_CF , TRNCOD_CF 
/SUM TOTAL AMT_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_105
# Creation of the file RETROCESSION (1)
#------------------------------------------------------------------------------
LIBEL="Creation of the file RETROCESSION (1)"
PRG=ESTC1033
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_SORT_FTECLEDR.dat
export ${PRG}_I2=${EST_FSUBSID}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR.dat
EXECPRG

NSTEP=${NJOB}_110
# Selection of the total retrocesion
#------------------------------------------------------------------------------
LIBEL="Selection of the total retrocesion"
PRG=ESTC1032
export ${PRG}_I1=${DFILT}/${NJOB}_105_${IB}_ESTC1033_FTECLEDR.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR.dat
EXECPRG

NSTEP=${NJOB}_115
# Creation of the file NET (1)
#------------------------------------------------------------------------------
LIBEL="Creation of the file NET (1)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1029_FTECLEDA.dat 1000 1 "
SORT_I2="${DFILT}/${NJOB}_110_${IB}_ESTC1032_FTECLEDR.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDN.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 2: 1 - 2:, NAT_CF 3: 1 - 3:, LOB_CF 5: 1 - 5:, TRNCOD_CF 6: 1 - 6:, AMT_CF 7: 1 - 7:EN 15/3
/KEYS SSD_CF , NAT_CF , LOB_CF , TRNCOD_CF 
/SUM TOTAL AMT_CF
/DERIVEDFIELD RES "net~"
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF , NAT_CF , RES , LOB_CF , TRNCOD_CF , AMT_CF 
exit
EOF
SORT

NSTEP=${NJOB}_120
# Creation of the user file RETROCESSION (2)
#------------------------------------------------------------------------------
LIBEL="Creation of the user file RETROCESSION (2)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_105_${IB}_ESTC1033_FTECLEDR.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS INV_CF 1: 1 - 1:, SSD_CF 2: 1 - 2:, COD_CF 4: 1 - 4:, TRNCOD_CF 6: 1 - 6:, AMT_CF 7: 1 - 7:EN 15/3, CUR_CF 8: 1 - 8 :
/KEYS SSD_CF , COD_CF , TRNCOD_CF 
/SUM TOTAL AMT_CF
/OUTFILE ${SORT_O}
/REFORMAT INV_CF , SSD_CF , COD_CF , TRNCOD_CF , AMT_CF , CUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_125
# Creation of the file NET (2)
#------------------------------------------------------------------------------
LIBEL="Creation of the file NET (2)"
PRG=ESTC1029
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_115_${IB}_SORT_FTECLEDN.dat
export ${PRG}_I2=${EST_FSUBSID}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDN.dat
EXECPRG

NSTEP=${NJOB}_130
# Creation of the user file NET (3)
#------------------------------------------------------------------------------
LIBEL="Creation of the user file NET (3)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_125_${IB}_ESTC1029_FTECLEDN.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDN.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS  INV_CF 1: 1 - 1:, SSD_CF 2: 1 - 2:, COD_CF 4: 1 - 4:, TRNCOD_CF 6: 1 - 6:, AMT_CF 7: 1 - 7:EN 15/3, CUR_CF 8: 1 - 8 :
/KEYS SSD_CF , TRNCOD_CF 
/SUM TOTAL AMT_CF
/OUTFILE ${SORT_O}
/REFORMAT INV_CF , SSD_CF , COD_CF , TRNCOD_CF , AMT_CF , CUR_CF
exit
EOF
SORT

JOBEND
