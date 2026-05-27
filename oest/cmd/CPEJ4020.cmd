#!/bin/ksh
#==============================================================================
#nom de l'application          : EPROC Batch
#nom du source                 : CPEJ4020
#date de creation              : 22/06/2015
#auteur                        : BSONAL
#references des specifications :
#------------------------------------------------------------------------------
#description :
#       Daily EPROC Batch
#==============================================================================

. ${DUTI}/fctgen.cmd

CHAININIT $0 $1

# Get input parameters
set `GETPRM ${DPRM}/CPEJ4020.prm`

DATE_T=$1
USR_CF=`whoami`

NJOB="CPEJ4021"
${DCMD}/CPEJ4021.cmd ${DATE_T} ${USR_CF} 2>&1 | ${TEE}

CHAINEND
