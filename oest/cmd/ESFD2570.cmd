#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire 
# nom du script SHELL           : ESFD2570.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 01/12/2018
# auteur                        : MZM
# references des specifications :spira:70671:Future premium for retro NP contracts  
#																:spira:70782:Future claim for retro NP contracts
#-----------------------------------------------------------------------------
# description :
#   REQ10.7 et REQ10.8 Future premium and future claim for retro NP contracts
#
#   Launch application jobs ESCD9001 and ESPD2570 
#
#-----------------------------------------------------------------------------
# historique des modifications :
# 001 : 03/03/2020 : MZM Spira:79070 Adaptation At INCEPTION de la generation des RETRO NP
# 002 : 30/0832021 : M.AJI SPIRA:91532 EST_PARAM n'est plu utilisÃ
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2


# 001
NJOB="ESCD9001"
# Launch applicative job ESCD9001
#. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}
#. ${DCMD}/ESFD9001.cmd ""
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT.....................: ${IDF_CT}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> CRE_D......................: $CRE_D "
ECHO_LOG "#===> ICLODAT_D..................: $ICLODAT_D    " 
ECHO_LOG "#===> ICLODAT_A..................: $ICLODAT_A    " 
ECHO_LOG "#===> ICLODAT_M..................: $ICLODAT_M    " 
ECHO_LOG "#===> ICLODAT_J..................: $ICLODAT_J    " 
ECHO_LOG "#===> MIN_ICLODAT_A..............: $MIN_ICLODAT_A    "
ECHO_LOG "#===> EST_FCURQUOT_TXT...........: $EST_FCURQUOT_TXT    "
ECHO_LOG "#===> EST_IRDPERICASE............: $EST_IRDPERICASE    "
ECHO_LOG "#===> EST_FTRSLNK_TXT............: $EST_FTRSLNK_TXT    "
ECHO_LOG "#===> EST_FBOPRSLNK_TXT..........: $EST_FBOPRSLNK_TXT    "
ECHO_LOG "#===> EST_FDETTRS_TXT............: $EST_FDETTRS_TXT    "
ECHO_LOG "#========================================================================="


# Launch applicative job ESPD2570
NJOB="ESPD2571"
${DCMD}/ESPD2571.cmd ${TYPEINV} ${PARM_INVCONSO_D} 2>&1 | ${TEE}

CHAINEND

