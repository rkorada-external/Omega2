#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire dommages
# nom du script SHELL           : ESID2210.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/07/2018
# auteur                        : JYP
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#              for IFRS Losses and IBNR calculation
#
#   	       Launch application jobs ESCD9001 and ESID2002A
#
#-----------------------------------------------------------------------------
# historique des modifications :
#[001] 20/07/2018 : JYP : creation , copied from ESID2000.cmd
#[002] 23/09/2020 : JYP : SPIRA 83609 : microAOC, manage multi instance IDF_CT
#[003] 18/01/2022 : M.NAJI spira 101406 split du ESFD2220 en ESFD2200,ESFD2230 ESID2210  ==> optimisation
#===============================================================================



#set -x


IDF_CT=$2

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1



NJOB="ESFD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESFD9001.cmd "$IDF_CT"




PARALLEL_JOB_INIT 2

NJOB="ESID2002A${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESID2002A.cmd ${PARM_CRE_D} ${PARM_CONSOYEA} ${PARM_CLOTYP_CT} ${PARM_INVCONSO_D} ${PARM_SSDCLO_LL} ${PARM_SSDVRS_LL} ${PARM_LSTCLODAT_LL} ${PARM_SSDDEL_LL} EBS ${PARM_TYPEINV} "

NJOB="ESFD2211${TYPEINV}"
PARALLEL_JOB "${DCMD}/ESFD2211.cmd "


PARALLEL_JOB_END




CHAINEND
