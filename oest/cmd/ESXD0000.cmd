#!/bin/ksh
#=============================================================================
# Application name          : 
# source file               : ESXD0000.cmd
# revision                  : $Revision:   1.0  $
# creation date             : 30/10/97
# author                    : Florent (SCOR)
# specifications references : 
#-----------------------------------------------------------------------------
# description :
# JOB SET: Extraction d'information pour le batch MVS de Jean François Van De Velde
# IMPORTANT : 
#             Avant le batch MVS POMID05
#       Variables used by the job set (defined in ESXD0000.env) :
#        ${EST_JFVDV_TCLMDET}
#        ${EST_JFVDV_TSECTION}
#-----------------------------------------------------------------------------
# Update history :
#   <dd/mm/yyyy>   <author>    <update description>
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESXD0001 
NJOB="ESXD0001"
${DCMD}/ESXD0001.cmd 2>&1 | ${TEE}

CHAINEND
