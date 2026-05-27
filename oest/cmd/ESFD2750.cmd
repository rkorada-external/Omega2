#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESFD2750.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 03/10/1997
# auteur                        : CGI
# references des specifications : ESTIEI23.doc
#-----------------------------------------------------------------------------
# description
#   Generation of the acceptance TL for retrocessionnaire subsidiaries
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] 26/11/2012 PPEZOUT :spot:24516 ECHANGES INTERNES POST OMEGA
#===============================================================================
#set -x 

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fcttransfer.cmd


# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"


# Launch applicative job ESCD9001
#. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}         
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"
  
JOBINIT  
    NSTEP=${NJOB}_10
    #-----------------------------------------------------------------------------
    LIBEL="COPY $EST_DLREMAJGTR_ESFD2550 $EST_DLREMAJGTR_ESFD2650  " 
    EXECKSH "cp $EST_DLREMAJGTR_ESFD2550 $EST_DLREMAJGTR_ESFD2650"   2>&1 | ${TEE} 

    NSTEP=${NJOB}_20
    #-----------------------------------------------------------------------------
    LIBEL="COPY $EST_DLREGTR_ESFD2550 $EST_DLREGTR_ESFD2650  " 
    EXECKSH "cp $EST_DLREGTR_ESFD2550 $EST_DLREGTR_ESFD2650"  2>&1 | ${TEE} 

    NSTEP=${NJOB}_30
    #-----------------------------------------------------------------------------
    LIBEL="COPY $EST_DLRGTAA_ESFD2550 $EST_DLRGTAA_ESFD2650  " 
    EXECKSH "cp $EST_DLRGTAA_ESFD2550 $EST_DLRGTAA_ESFD2650"   2>&1 | ${TEE} 

    NSTEP=${NJOB}_40
    #-----------------------------------------------------------------------------
    LIBEL="COPY $EST_DLDGTAA_ESFD2550 $EST_DLDGTAA_ESFD2650  " 
    EXECKSH "cp $EST_DLDGTAA_ESFD2550 $EST_DLDGTAA_ESFD2650"   2>&1 | ${TEE} 
   
JOBEND

CHAINEND
