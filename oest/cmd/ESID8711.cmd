#!/bin/ksh 
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : TNR  des FTECLEDA , FTECLEDR  P&C  et ceux de l'inventaire
# nom du script SHELL           : ESID8711.cmd
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
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# No input parameters

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="${ENV_PREFIX}_ESID3800_FTECLEDA.dat ==>  ${ENV_PREFIX}_ESID3800_${NSTEP}_FTECLEDA_PC.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA.dat 1000 1"
SORT_O="${DFILT}/${ENV_PREFIX}_ESID3800_${NSTEP}_FTECLEDA_PC.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS 
		LOBACC_CF	45:1 	- 45:, 
		LOBRET_CF	46:1	-	46:
	/CONDITION COND_PC_CLEAN  ( LOBRET_CF != '30' and  LOBRET_CF !='31' and LOBACC_CF != '30' and  LOBACC_CF !='31' )
	/OUTFILE ${SORT_O} 1000 1 "~" overwrite
	/INCLUDE COND_PC_CLEAN 
	/COPY	
	exit
EOF
SORT

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="compress ${ENV_PREFIX}_ESID3800_${NJOB}_10_FTECLEDA_PC.dat ==>  ${ENV_PREFIX}_ESID3800_${NSTEP}_FTECLEDA_PC_COMPRESS.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_ESID3800_${NJOB}_10_FTECLEDA_PC.dat 1000 1"
SORT_O="${DFILT}/${ENV_PREFIX}_ESID3800_${NSTEP}_FTECLEDA_PC_COMPRESS.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS 
		AMT_M 19:1 - 19:EN 15/3,
		BEFORE_AMT_M 1:1 - 18:,
		AFTER_AMT_M 20:1 - 34:,
		RETAMT_M 35:1 - 35:EN 15/3,
		AFTER_RETAMT_M 36:1 - 87:,
		RETINTAMT_M 88:1 - 88:EN 15/3,
		AFTER_RETINTAMT_M 89:1 - 118:,
		LOBACC_CF	45:1 	- 45:, 
		LOBRET_CF	46:1	-	46:
	/DERIVEDFIELD AMT_MC AMT_M COMPRESS
	/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
	/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
	/OUTFILE ${SORT_O} 1000 1 "~" overwrite
	/REFORMAT 
		 BEFORE_AMT_M
		,AMT_MC
		,AFTER_AMT_M
		,RETAMT_MC
		,AFTER_RETAMT_M
		,RETINTAMT_MC
		,AFTER_RETINTAMT_M
	/COPY	
	exit
EOF
SORT

NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="compress ${ENV_PREFIX}_ESID8700_I4_PC___FTECLEDA.dat ==>  ${ENV_PREFIX}_ESID8700_${NSTEP}_I4_PC___FTECLEDA.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${ENV_PREFIX}_ESID8700_I4_PC___FTECLEDA.dat 1000 1"
SORT_O="${DFILT}/${ENV_PREFIX}_ESID8700_${NSTEP}_I4_PC___FTECLEDA_COMPRESS.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS 
		AMT_M 19:1 - 19:EN 15/3,
		BEFORE_AMT_M 1:1 - 18:,
		AFTER_AMT_M 20:1 - 34:,
		RETAMT_M 35:1 - 35:EN 15/3,
		AFTER_RETAMT_M 36:1 - 87:,
		RETINTAMT_M 88:1 - 88:EN 15/3,
		AFTER_RETINTAMT_M 89:1 - 118:,
		LOBACC_CF	45:1 	- 45:, 
		LOBRET_CF	46:1	-	46:,
		all_cols 1:1 - 118:
	/DERIVEDFIELD AMT_MC AMT_M COMPRESS
	/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
	/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
	/OUTFILE ${SORT_O} 1000 1 "~" overwrite
	/REFORMAT 
		 BEFORE_AMT_M
		,AMT_MC
		,AFTER_AMT_M
		,RETAMT_MC
		,AFTER_RETAMT_M
		,RETINTAMT_MC
		,AFTER_RETINTAMT_M
	/COPY	
	exit
EOF
SORT


NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="Diff ${ENV_PREFIX}_ESID3800_${NJOB}_20_FTECLEDA_PC_COMPRESS.dat ==>  ${NJOB}_30_I4_PC___FTECLEDA_COMPRESS.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_ESID3800_${NJOB}_20_FTECLEDA_PC_COMPRESS.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS
			key1_cols        1:1     -       19:,
			key2_cols        24:1     -       28:,
			key3_cols        34:1     -       40:,
			key4_cols        44:1     -       108:,
			all_cols        1:1     -       109:
	/joinkeys
			 key1_cols,
			 key2_cols,
			 key3_cols,
			 key4_cols
	/INFILE  $DFILT/${ENV_PREFIX}_ESID8700_${NJOB}_30_I4_PC___FTECLEDA_COMPRESS.dat 2000 1  "~"
	/joinkeys
			 key1_cols,
			 key2_cols,
			 key3_cols,
			 key4_cols
	/JOIN UNPAIRED  ONLY
	/OUTFILE $DFILT/diff_FTECLEDA.dat overwrite
	/REFORMAT
			leftside:all_cols, rightside:all_cols
	exit
EOF
SORT




JOBEND

