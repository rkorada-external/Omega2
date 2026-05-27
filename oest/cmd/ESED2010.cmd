#!/bin/ksh
#=============================================================================
# nom de l'application		: SEGMENTATION - BATCH - SIMULATION
# nom du script SHELL		: ESED2010.cmd
# revision			        : $Revision:   1.0  $
# date de creation		    : 29/07/2013
# auteur			        : G. GUNTHER
# references des specifications	: 
#-----------------------------------------------------------------------------
# description : 
# Launch the segmentation process for simulation
# 19/07/2021	MOD 1: Parth : SPIRA 96590 
#-----------------------------------------------------------------------------
# Parametres :
# $1 User that asks the job
# $2 parameter n1 - Segmentation ID
# $3 parameter n2 - Concurrancy Factor
# $4 parameter n3
# $5 parameter n4
# $6 parameter n5
# $7 parameter n6
# $8 parameter n7
# $9 parameter n8
# $10 parameter n9
# $11 parameter c1
# $12 parameter c2
# $13 parameter c3
# $14 parameter c4
# $15 parameter c5
# $16 parameter c6
# $17 parameter c7
# $18 parameter c8
# $19 parameter c9
# $20 Current date yyyymmdd
# $21 Current time (?)
# $22 Log file of the daemon
#-----------------------------------------------------------------------------
# Modification history:
# 31/07/2013	GGU: Creation  
# 18/11/2013	NGA: Implementation of actual simulation perimeter processing  
#  
#===============================================================================

# Environment file
. ${DENV}/ESED2010.env

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the JOB
NJOB=ESED2010
JOBINIT

SGTRUN_NT=$2
CON_FAC=$3
SGTTYPMOD_NT=$4

# Call simulation job
$DEST/$UTIDIR/ESED2011.cmd $SGTRUN_NT $CON_FAC $SGTTYPMOD_NT


if [ "${SGTTYPMOD_NT}" == "2" ]; then 
	${DCMD}/RTPJ0701.cmd ${SGTRUN_NT} 
fi


JOBEND

