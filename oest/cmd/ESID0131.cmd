#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID0131.cmd
# revision                      : $Revision: 1.0 
# date de creation              : 21/08/2019
# auteur                        : Rafael Vieville
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Remove quarterly line in FLIFESTY0
#-----------------------------------------------------------------------------
# historiques des modifications
#[xxx] prog. name  JJ/MM/AAAA :spot:xxxxx - Comment
#======================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Merge PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IAVPERICASE0} 1000 1"
SORT_I2="${EST_IRVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IARVPERICASE.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	SSD_CF		1:1 - 1:EN,
	CTR_NF      3:1 - 3:,
	SEC_NF      5:1 - 5:,
	UWY_NF		6:1 - 6:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF
/CONDITION NONVIE (SSD_CF = 5 OR SSD_CF = 6)
/OMIT NONVIE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_20
# Merge FCTREST and FCTREST
#-----------------------------------------------------------------------------
LIBEL="Sort PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_IARVPERICASE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IARVPERICASE.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF      3:1 - 3:,
	SEC_NF      5:1 - 5:,
	UWY_NF		6:1 - 6:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF DESCENDING
/OUTFILE ${SORT_O}
exit
EOF
SORT
	
NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Sort LIFEST for ESTC1036"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FLIFESTY1}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF      2:1 - 3:,
	SEC_NF      4:1 - 4:,
	UWY_NF		5:1 - 5:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT
	
NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Prg for exclude qurterly contrat"
PRG=ESTC1036
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_LIFEST.dat
export ${PRG}_I2=${DFILT}/${NJOB}_20_${IB}_SORT_IARVPERICASE.dat
export ${PRG}_O1=${EST_FLIFESTY0}
EXECPRG

JOBEND
