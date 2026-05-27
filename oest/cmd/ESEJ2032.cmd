#!/bin/ksh
#===============================================================
# application name               : Update fiel GEOLVL
# source name                    : ESEJ2032.cmd
# revision                       : $Revision:   1.0  $
# creation date                  : 14/08/2014
# author                         : Paul Coppin
# specifications references      : 
#---------------------------------------------------------------
# description :
# Script that update fields GEOLVL_CF and GEOLVL_LM
#
# parameters :
# 
#---------------------------------------------------------------
# modifications chronology:
#
#===============================================================
#set -x

#*******************************************************************

# Call generic functions
. ${DUTI}/fctgen.cmd

JOBINIT

NSTEP=${NJOB}_05
# Update
#---------------------------------------------------------------------
LIBEL="update BSBO..TUWSEC"
ISQL_BASE="BSBO"
ISQL_QRY="execute BSBO..PuTUWSEC_GEOLVL_01 50000 with recompile"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PuTUWSEC_GEOLVL_01.log
ISQL


JOBEND
