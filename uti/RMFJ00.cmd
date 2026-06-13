#!/bin/ksh
# Management of RMF files
#
# 
# set -x
. $DUTI/fctgen.cmd

CHAININIT $0 $1

NJOB="RMFJ01"

# Launch Job RMFJ01.cmd
${DUTI}/RMFJ01.cmd 	2>&1 | ${TEE}

CHAINEND
