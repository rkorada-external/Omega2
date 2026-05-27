#!/bin/ksh
#==============================================================================
#nom de l'application          : EPROC Batch
#nom du source                 : CPEJ4010
#date de creation              : 24/06/2015
#auteur                        : BSONAl
#references des specifications :
#------------------------------------------------------------------------------
#description :
#       Daily EPROC Batch
#==============================================================================

. ${DUTI}/fctgen.cmd

CHAININIT $0 $1

# Get input parameters
set `GETPRM ${DPRM}/CPEJ4010.prm`

USR_CF=whoami
NBR_DAY=$1

NJOB="CPEJ4011"
${DCMD}/CPEJ4011.cmd ${USR_CF} ${NBR_DAY} 2>&1 | ${TEE}

CHAINEND
