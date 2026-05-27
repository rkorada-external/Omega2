#! /bin/ksh
#===============================================================================
# application name               : AE and Profitability rapport
# source name                    : ESDC0020.cmd
# revision                       : $Revision:   0.1  $
# extraction date                : 22/09/2025
# author                         : S.Behague
# specifications reference       :
#                                :
#-------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------
# modifications chronology       :
# [001] - 22/09/2025 S.Behague :US5609: PROD Report- job that generates closing report should be migrated in PRD - Spira 111994
#============================================================================


# call generic functions
#------------------------------------------------------------------------------
. ${DUTI}/fctgen.cmd


# Chain Initialization variables
#------------------------------------------------------------------------------
# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


NJOB="ESDC0022"
#----------------------------------------------------------------------------
# Launch applicative job ESDC0022.cmd
${DCMD}/ESDC0022.cmd 


NJOB="ESDC0021"
#----------------------------------------------------------------------------
# Launch applicative job ESDC0021.cmd
${DCMD}/ESDC0021.cmd 


CHAINEND