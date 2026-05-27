#----------------------------------------------------------------------------
# ESEJ2019
#
# Subject: Cache latest Infomega segmentation references into BSEG.
# Purpose:
#   BEST and BREF segmentation references can't be accessed from screens when TP to DW copy happens.
#   This job calls BSEG..PuSEGCACHEREF_01 which caches this data into BSEG for access from Omega2.
# Return 0 if OK, >0 otherwise
#---------------------------------------------------------------
# modifications chronology:
#   03/12/2014    Nicolas Gasull    Initial version
#===============================================================
#set -x

#*******************************************************************

# Call generic functions
. ${DUTI}/fctgen.cmd

JOBINIT

LIBEL="Cache segmentation reference tables"
NSTEP=${NJOB}_CACHE_SEG_REF_TABLES
ISQL_BASE="BTRAVI"
ISQL_QRY="execute BSEG.dbo.PuSEGCACHEREF_01"
ISQL_O=${DFILT}/${NSTEP}_${IB}.log
ISQL

JOBEND