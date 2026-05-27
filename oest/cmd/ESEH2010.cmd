#!/bin/ksh
#=============================================================================
# nom de lapplication		: SEGMENTATION - BATCH - WEEKLY DAILY
# nom du script SHELL		: ESEH2010.cmd
# revision			        : $Revision:   1.0  $
# date de creation		    : 29/07/2013
# auteur			        : G. GUNTHER
# references des specifications	: 
#-----------------------------------------------------------------------------
# description : xwiki BCL-SEG-801737
# Launch the weekly and daily segmentation process
#-----------------------------------------------------------------------------
# Modification history:
# 31/07/2013	GGU: Creation  
# MOD02	Parth	12/11/2020	SPIRA 91638	Pass Concurrency Factor to Batch web from parameter file 
#===============================================================================

. ${DUTI}/fctgen.cmd

# Initialize the chain
CHAININIT $0 $1

set `GETPRM $DPRM/ESEH2010.prm`
export RUN_DATE=$1
export PRDSIT_CF="$HOST_PRDSIT"
export SEG_FREQ=1,2
export CON_FACTOR=$2

# Cache BEST/BREF data into BSEG
NJOB=ESEJ2019
${DCMD}/ESEJ2019.cmd

# Launch the main process
NJOB=ESEJ2011
${DCMD}/ESEJ2011.cmd

CHAINEND
