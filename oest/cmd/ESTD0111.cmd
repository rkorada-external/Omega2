#!/bin/ksh
#===============================================================
#application name               : Clearing old data into BEST..TRTOSTAE
#source name                    : ESTD0111.cmd
#revision                       : $Revision:   1.1  $
#creation date                  : 26/09/2003
#author                         : Roger Cassis
#specifications reference       :
#                               :
#---------------------------------------------------------------
#description :
# Suppression de mouvements anterieurs a une date dans BEST..TRTOSTAE
#
#parameters :
# BALSHEYEA_NF = Min update date of movements to be kept into BEST..TRTOSTAE
#
#---------------------------------------------------------------
#modifications chronology  :
#   <jj/mm/aaaa>   <author>    <modification description>
#
#===============================================================
#set -x

#***************************************************************

# Call generic functions
. ${DUTI}/fctgen.cmd

# Entry parameters
BALSHEYEA_NF=${1}

# Job Initialization
JOBINIT

NSTEP=${NJOB}_05
# Begin Bcmulti
#---------------------------------------------------------------
LIBEL="BCP out of BEST..TRTOSTAE (mouvements a conserver)"
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1_TRTOSTAE.dat
BCP_QRY="SELECT
    PLCSTA_NT    ,
    RETCTR_NF    ,
    PLC_NT       ,
    RTY_NF       ,
    SCOSTRMTH_NF ,
    SCOENDMTH_NF ,
    RETACCYER_NF ,
    ACCYER_NF    ,
    ACCGRPYEA_NF ,
    TRNCOD_CF    ,
    LOB_CF       ,
    RETSEC_NF    ,
    ACCCUR_CF    ,
    SSD_CF       ,
    ESB_CF       ,
    BALSHEYEA_NF ,
    CNVAMT_M     ,
    RETPCPCUR_CF ,
    PCPCUR_M     ,
    RETACCSEN_NT ,
    INT_NF       ,
    RTO_NF       ,
    KEPTRN_B     ,
    LSTUPD_D     ,
    EPSTATUS     ,
    TIMESTAMP    ,
    STAPROSTS_B  ,
    BLSHT_D
  FROM BEST..TRTOSTAE
   where BALSHEYEA_NF >= ${BALSHEYEA_NF}
"

BCP

NSTEP=${NJOB}_10
# Begin BCP IN
#---------------------------------------------------------------
LIBEL="BCP IN into BEST..TRTOSTAE"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=YES
BCP_I=${DFILT}/${NJOB}_05_${IB}_BCP_O1_TRTOSTAE.dat
BCP_TABLE="BEST..TRTOSTAE"
BCP

NSTEP=${NJOB}_15
# Begin RMFIL
#---------------------------------------------------------------
LIBEL="Remove of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

#End of job
JOBEND
