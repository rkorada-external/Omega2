#!/bin/ksh
#=================================================================================================================================
# Application name              : Management of OPENING / CLOSING Position
# Batch name                    : STAD7500.cmd
# Revision                      : $Revision:  $
# Creation date                 : 26/08/2019
# Author                        : L. Wernert
# Specification reference       : http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-908624
# Technical reference           : http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BC-CLO-908266
#---------------------------------------------------------------------------------------------------------------------------------
# Description :	
#    Management of OPENING / CLOSING Position
#    Monthly process: STAD7500 => STAD7501 => STAD7504 (archiving and clean-up)
#    Yearly process: STAD7500 => STAD7501 => STAD7502 => STAD7503 => STAD7504 (archiving/extraction, opening, annual clean-up, monthly clean-up)
#
# Entry parameters :
#    SSDs0
#    BALSHTYEA_NF
#    BALSHTMTH_NF
#    CRE_D
#    DBCLO_D
#    CLODAT_D
#
#---------------------------------------------------------------------------------------------------------------------------------
# Modification history :
# <modification> <JJ/MM/AAAA> <author> <spot> <description>
# [001] XX/XX/XXXX XXXX XXX XXXX
#
#---------------------------------------------------------------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variable 
CHAININIT $0 $1

# Get entry parameters from PARM0
. ${EST_PARAM2}
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=${SSDs0}
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} "${BALSHTYEA_NF}1231"


ECHO_LOG ""                                                                          
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> SSDs..................: ${SSDs}"                                   
ECHO_LOG "#===> BALSHTMTH_NF..........: ${BALSHTMTH_NF}"
ECHO_LOG "#===> BALSHTYEA_NF..........: ${BALSHTYEA_NF}"                             
ECHO_LOG "#===> CRE_D.................: ${CRE_D}"                                    
ECHO_LOG "#===> DBCLO_D...............: ${DBCLO_D}"
ECHO_LOG "#===> CLODAT_D..............: ${CLODAT_D}"
ECHO_LOG "#===> EST_STAD7500_COND1....: ${EST_STAD7500_COND1}"
ECHO_LOG "#========================================================================="

# Launch applicative job STAD7501
# Extractions, treatments and data archiving in history tables
NJOB="STAD7501"
${DCMD}/STAD7501.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${EST_STAD7500_COND1} 2>&1 | ${TEE}

if [ ${EST_STAD7500_COND1} == "Y" ]
then
  # Launch applicative job STAD7502
  # Grid opening: Annual initialization of life estimates
  NJOB="STAD7502"
  ${DCMD}/STAD7502.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}

  # Launch applicative job STAD7503
  # Annual clean-up
  NJOB="STAD7503"
  ${DCMD}/STAD7503.cmd ${BALSHTYEA_NF} 2>&1 | ${TEE}
fi


CHAINEND
