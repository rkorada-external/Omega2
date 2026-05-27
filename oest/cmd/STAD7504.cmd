#!/bin/ksh
#=================================================================================================================================
# Application name              : Management of OPENING / CLOSING Position => Monthly clean-up
# Batch name                    : STAD7504.cmd
# Revision                      : $Revision:  $
# Creation date                 : 26/08/2019
# Author                        : L. Wernert
# Specification reference       : http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-908624
# Technical reference           : http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BJTD-CLO-910416
#---------------------------------------------------------------------------------------------------------------------------------
# Description :	
#    Monthly clean-up (TLIFEST/TLIFESTD)
#
# Entry parameters :
#    BALSHTYEA_NF
#
#---------------------------------------------------------------------------------------------------------------------------------
# Modification history :
# <modification> <JJ/MM/AAAA> <author> <spot> <description>
# [001] XX/XX/XXXX XXXX XXX XXXX
#
#---------------------------------------------------------------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

# Entry parameters
set -x
BALSHTYEA_NF=$1
set +x

# Initialise JOB
JOBINIT


NSTEP=${NJOB}_10
# Clean-up TLIFEST
#------------------------------------------------------------------------------
LIBEL="Clean-up TLIFEST"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST.dbo.PdLIFEST_01 ${BALSHTYEA_NF}"
ISQL

NSTEP=${NJOB}_20
# Clean-up TLIFESTD
#------------------------------------------------------------------------------
LIBEL="Clean-up TLIFESTD"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST.dbo.PdLIFESTD_01 ${BALSHTYEA_NF}"
ISQL

JOBEND
