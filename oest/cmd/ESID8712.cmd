#!/bin/ksh 
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : TNR   FTECLEDR  P&C  et ceux de l'inventaire
# nom du script SHELL           : ESID8712.cmd
# revision                      : 
# date de creation              : 26/02/2020
# auteur                        : M. NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  :SPIRA: 81838 - Split Life et P&C
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001]	26/02/2020	M.NAJI  	   :SPIRA 81838 : TNR Split Life et P&C
#[002]  15/06/2020      L.DOAN             :SPIRA 81838 : fix ENV_PREFIX
#[003]  17/06/2020      L.DOAN             :SPIRA 81838 : fix typing error in grep
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# No input parameters

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="Extract P&C rows and split INTERN and NOT ${ENV_PREFIX}_ESID3800_FTECLEDR.dat ==>  ${ENV_PREFIX}_ESID8700_${NSTEP}_FTECLEDR_PC.dat , ${ENV_PREFIX}_ESID8700_${NSTEP}_FTECLEDR_PC_INTERNE.dat"

SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILP/${ENV_PREFIX}_ESID3800_FTECLEDR.dat 1000 1"
SORT_O="$DFILT/${NSTEP}_FTECLEDR_PC.dat "
SORT_O2="$DFILT/${NSTEP}_FTECLEDR_PC_INTERNE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS 
		SSDRTO_B 55:1 - 55:EN ,
		LOBACC_CF	45:1 	- 45:, 
		LOBRET_CF	46:1	-	46:,
		all_cols 1:1 - 118:
	/CONDITION COND_PC_CLEAN  ( LOBRET_CF != '30' and  LOBRET_CF !='31' and LOBACC_CF != '30' and  LOBACC_CF !='31'  and SSDRTO_B = 0) 
	/CONDITION COND_PC_INTERNE_CLEAN  ( LOBRET_CF != '30' and  LOBRET_CF !='31' and LOBACC_CF != '30' and  LOBACC_CF !='31'  and SSDRTO_B = 1) 
	/OUTFILE ${SORT_O} 1000 1 "~" overwrite
	/INCLUDE COND_PC_CLEAN 
	/OUTFILE ${SORT_O2} overwrite
	/INCLUDE COND_PC_INTERNE_CLEAN 
	/COPY	
	exit
EOF
SORT



NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="Extract P&C rows and split INTERN and NOT ${ENV_PREFIX}_ESID8700_I4_PC___FTECLEDR.dat ==>  ${ENV_PREFIX}_ESID8700_I4_PC___${NSTEP}_FTECLEDR_PC.dat , ${ENV_PREFIX}_ESID8700_${NSTEP}_FTECLEDR_PC_I4_PC___INTERNE.dat"

SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILP/${ENV_PREFIX}_ESID8700_I4_PC___FTECLEDR.dat 1000 1"
SORT_O="$DFILT/${NSTEP}_FTECLEDR_I4_PC__.dat "
SORT_O2="$DFILT/${NSTEP}_FTECLEDR_I4_PC___INTERNE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS 
		SSDRTO_B 55:1 - 55:EN ,
		LOBACC_CF	45:1 	- 45:, 
		LOBRET_CF	46:1	-	46:,
		all_cols 1:1 - 118:
	/CONDITION COND_PC_CLEAN  ( LOBRET_CF != '30' and  LOBRET_CF !='31' and LOBACC_CF != '30' and  LOBACC_CF !='31'  and SSDRTO_B = 0) 
	/CONDITION COND_PC_INTERNE_CLEAN  ( LOBRET_CF != '30' and  LOBRET_CF !='31' and LOBACC_CF != '30' and  LOBACC_CF !='31'  and SSDRTO_B = 1) 
	/OUTFILE ${SORT_O} 1000 1 "~" overwrite
	/INCLUDE COND_PC_CLEAN 
	/OUTFILE ${SORT_O2} overwrite
	/INCLUDE COND_PC_INTERNE_CLEAN 
	/COPY	
	exit
EOF
SORT



NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="Diff ${ENV_PREFIX}_ESID8700_${NJOB}_50_FTECLEDR_PC.dat x ${ENV_PREFIX}_ESID8700_${NJOB}_60_FTECLEDR_I4_PC__.dat ==>  diff_FTECLEDR.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_50_FTECLEDR_PC.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS
			key1_cols        1:1     -       6:,
			key2_cols        24:1     -       30:,
			key3_cols        34:1     -       40:,
			key4_cols        44:1     -       56:,
			key5_cols        58:1     -       62:,
			all_cols        1:1     -       109:
	/joinkeys
			 key1_cols,
			 key2_cols,
			 key3_cols,
			 key4_cols,
			 key5_cols
	/INFILE  $DFILT/${NJOB}_60_FTECLEDR_I4_PC__.dat   2000 1  "~"
	/joinkeys
			 key1_cols,
			 key2_cols,
			 key3_cols,
			 key4_cols,
			 key5_cols
	/JOIN UNPAIRED  ONLY
	/OUTFILE $DFILT/${NSTEP}_diff_FTECLEDR.dat overwrite
	/REFORMAT
			leftside:all_cols, rightside:all_cols
	exit
EOF
SORT

NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Diff ${ENV_PREFIX}_ESID8700_${NJOB}_50_FTECLEDR_PC.dat x ${ENV_PREFIX}_ESID8700_${NJOB}_60_FTECLEDR_I4_PC__.dat ==>  diff_FTECLEDR.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_50_FTECLEDR_PC_INTERNE.dat 1000 1"
SORT_O="$DFILT/${NSTEP}_diff_FTECLEDR_INTERNE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS
		key1_cols        1:1     -       17:,
		key2_cols        24:1     -       30:,
		key3_cols        34:1     -       40:,
		key4_cols        44:1     -       56:,
		key5_cols        58:1     -       61:,
		all_cols        1:1     -       109:
	/joinkeys
			 key1_cols,
			 key2_cols,
			 key3_cols,
			 key4_cols,
			 key5_cols
	/INFILE  $DFILT/${NJOB}_60_FTECLEDR_I4_PC___INTERNE.dat   2000 1  "~"
	/joinkeys
			 key1_cols,
			 key2_cols,
			 key3_cols,
			 key4_cols,
			 key5_cols
	/JOIN UNPAIRED  ONLY
	/OUTFILE ${SORT_O} overwrite
	/REFORMAT
			leftside:all_cols, rightside:all_cols
	exit
EOF
SORT


grep -v "^~~"   $DFILT/${NJOB}_70_diff_FTECLEDR.dat > $DFILT/${NJOB}_70_diff_FTECLEDR_R.dat
grep  "^~~"   $DFILT/${NJOB}_70_diff_FTECLEDR.dat > $DFILT/${NJOB}_70_diff_FTECLEDR_L.dat


NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="Sum"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT//${NJOB}_70_diff_FTECLEDR_R.dat 1000 1"
SORT_O="$DFILT/${NSTEP}_diff_FTECLEDR_R_.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS 
		BEFORE_AM			1:1		-	18:	,
        RETAMT_M		 	35:1    -   35: EN 15/3,
		AFTER_AM			36:1	-	109:	
	/DERIVEDFIELD RETAMT_M1 -RETAMT_M 
	/COPY
	/OUTFILE ${SORT_O} overwrite
	/REFORMAT
			BEFORE_AM,
			RETAMT_M1,
			AFTER_AM
	exit
EOF
SORT

#${ENV_PREFIX}_ESID8710_ESID8712_100_diff_FTECLEDR_INTERNE_R.dat

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="Sum"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_70_diff_FTECLEDR_L.dat 1000 1"
SORT_I2="$DFILT/${NJOB}_90_diff_FTECLEDR_R_.dat 1000 1"
SORT_O="$DFILT/diff_FTECLEDR.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS 
			key1_cols         1:1     -        6:,
			key2_cols        24:1     -       30:,
			key3_cols        34:1     -       34:,
			RETAMT_M		 35:1     -       35:EN 15/3,
			key4_cols        36:1     -       40:,
			key5_cols        44:1     -       56:,
			key6_cols        58:1     -       62:	
	/KEYS
			key1_cols,
			key2_cols,
			key3_cols,
			key4_cols,
			key5_cols,
			key6_cols
	/SUMMARIZE TOTAL RETAMT_M
	/COND  COND_ECART RETAMT_M < -0.010 OR  RETAMT_M > 0.010  
	/OUTFILE ${SORT_O} overwrite
	/INCLUDE COND_ECART 
	exit
EOF
SORT

grep -v "^~~"   $DFILT/${NJOB}_80_diff_FTECLEDR_INTERNE.dat > $DFILT/${NJOB}_80_diff_FTECLEDR_INTERNE_R.dat
grep  "^~~"   $DFILT/${NJOB}_80_diff_FTECLEDR_INTERNE.dat > $DFILT/${NJOB}_80_diff_FTECLEDR_INTERNE_L.dat
																
NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="Sum"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT//${NJOB}_80_diff_FTECLEDR_INTERNE_R.dat 1000 1"
SORT_O="$DFILT/${NSTEP}_diff_FTECLEDR_INTERNE_R_.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS 
		BEFORE_AM			1:1		-	18:	,
        RETAMT_M		 	35:1    -   35: EN 15/3,
		AFTER_AM			36:1	-	109:	
	/DERIVEDFIELD RETAMT_M1 -RETAMT_M 
	/COPY
	/OUTFILE ${SORT_O} overwrite
	/REFORMAT
			BEFORE_AM,
			RETAMT_M1,
			AFTER_AM
	exit
EOF
SORT


NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
LIBEL="Sum"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_80_diff_FTECLEDR_INTERNE_L.dat 1000 1"
SORT_I2="$DFILT/${NJOB}_110_diff_FTECLEDR_INTERNE_R_.dat 1000 1"
SORT_O="$DFILT/diff_FTECLEDR_INTERNE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS 
			key1_cols         1:1     -        6:,
			key2_cols        24:1     -       30:,
			key3_cols        34:1     -       34:,
			RETAMT_M		 35:1     -       35:EN 15/3,
			key4_cols        36:1     -       40:,
			key5_cols        44:1     -       56:,
			key6_cols        58:1     -       62:	
	/KEYS
			key1_cols,
			key2_cols,
			key3_cols,
			key4_cols,
			key5_cols,
			key6_cols
	/SUMMARIZE TOTAL RETAMT_M
	/COND  COND_ECART RETAMT_M < -0.010 OR  RETAMT_M > 0.010  
	/OUTFILE ${SORT_O} overwrite
	/INCLUDE COND_ECART 
	exit
EOF
SORT


JOBEND

