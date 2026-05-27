#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire dommages
# nom du script SHELL           : ESID2220.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/07/2018
# auteur                        : JYP
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#              for IFRS Losses and IBNR calculation
#
#              Launch application jobs ESCD9001 and ESID2002A
#
#-----------------------------------------------------------------------------
# historique des modifications :
#[001] 20/07/2018 : JYP : creation , copied from ESID2000.cmd
#[002] 25/09/2019 : RC  :spira:65656 ajout cotes dans IDFCT car pas fait.
#[003] 17/10/2019 : M.NAJI : spira 78653 remettre le parallellisme des job qui a ete commente
#[004] 21/10/2019 : RC  :spira:78653 Rajoute TYPEINV dans les noms de job pour qu'ils soient bien reconnus dans le ESFD2003C.
#[005] 24/10/2019 : RC  :spira:81934 Maintenant on met l'IDFCT dans les noms de job au lieu du TYPEINV pour qu'ils soient bien reconnus dans le ESFD2003C.
#[006] 19/04/2022 : RC  :spira:101543 Ajout du TYPEINV dans les noms de jobs.
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
#set `GETPRM ${EST_PARAM}` 

#SSDs0=$1
#SSDs=$2
#BALSHTYEA_NF=$3
#BALSHTMTH_NF=$4
#CRE_D=$5
#DBCLO_D=$6
#ICLODAT_D=$7
#CLODAT_D=$8
#CLOTYP_CT=${10}
#SEGTYP_CT=${11}
#SSDDEL_LL=${12}
#LSTCLODAT_LL=${13}
#SSDVRS_LL=${14}
#INVCONSO_D=${21}
#CONSOYEA=${22}
#CONSOMTH=${23}

IDF_CT=$2

NJOB="ESFD9001"
# Launch applicative job ESCD9001
#. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}
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
#ECHO_LOG "#===> BALSHTYEA_NF...............: $BALSHTYEA_NF "
ECHO_LOG "#===> ICLODAT_D..................: $ICLODAT_D    " 
ECHO_LOG "#===> ICLODAT_A..................: $ICLODAT_A    " 
ECHO_LOG "#===> ICLODAT_M..................: $ICLODAT_M    " 
ECHO_LOG "#===> ICLODAT_J..................: $ICLODAT_J    " 
ECHO_LOG "#===> MIN_ICLODAT_A..............: $MIN_ICLODAT_A    "
ECHO_LOG "#===> EST_FCURQUOT_TXT...........: $EST_FCURQUOT_TXT    "
ECHO_LOG "#===> EST_IADPERICASE............: $EST_IADPERICASE    "
ECHO_LOG "#===> EST_IADPERICASE............: $EST_IADPERICASE    "
ECHO_LOG "#===> EST_FTRSLNK_TXT............: $EST_FTRSLNK_TXT    "
ECHO_LOG "#===> EST_FBOPRSLNK_TXT..........: $EST_FBOPRSLNK_TXT    "
ECHO_LOG "#===> EST_FDETTRS_TXT............: $EST_FDETTRS_TXT    "
ECHO_LOG "#========================================================================="


PARALLEL_JOB_INIT 5

# Launch applicative job ESFD2003A
NJOB="ESFD2003A${IDF_CT}${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD2003A.cmd ${TYPEINV} ${PARM_INVCONSO_D}" 

# Launch applicative job ESFD2003B
NJOB="ESFD2003B00${IDF_CT}${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD2003B.cmd ${TYPEINV} ${PARM_INVCONSO_D} 00" 

# Launch applicative job ESFD2003B
NJOB="ESFD2003B01${IDF_CT}${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD2003B.cmd ${TYPEINV} ${PARM_INVCONSO_D} 01" 

# Launch applicative job ESFD2003B
NJOB="ESFD2003B02${IDF_CT}${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD2003B.cmd ${TYPEINV} ${PARM_INVCONSO_D} 02" 

# Launch applicative job ESFD2003B
NJOB="ESFD2003B03${IDF_CT}${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD2003B.cmd ${TYPEINV} ${PARM_INVCONSO_D} 03" 

PARALLEL_JOB_END

# Launch applicative job ESFD2003C
NJOB="ESFD2003C${IDF_CT}${TYPEINV}"
${DCMD}/ESFD2003C.cmd ${TYPEINV} ${PARM_INVCONSO_D} 2>&1 | ${TEE}

CHAINEND

