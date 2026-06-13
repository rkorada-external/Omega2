#!/bin/ksh
#==============================================================================
#nom de l'application          : Technical Job for inter-site transfer
#nom du source                 : TEFJ0011.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 15/09/1997
#auteur                        : L.Moreau
#references des specifications : 
#------------------------------------------------------------------------------
# description :
#       Get extraction file produced by extchain from host sites 
#
# 2 variables must be defined
# 	$EXTCHAIN    : extraction chain name
#	$REMOTE_SITE : list of sites to process
#		       if all, all distant sites in bref..tftpb are contacted
#		       if s1|s2|.. , only these sites ara contacted
#==============================================================================
#set -x

. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd
. ${DUTI}/fctftp.cmd

# Job initialization
JOBINIT


NSTEP=${NJOB}_05    
#==============================================================================
LIBEL="GET ZIP EXTRACTION"
GET_ZIP_I="${REMOTE_SITE}"
GET_ZIP_CHAIN="${EXTCHAIN}"
GET_ZIP_O=${DFILT}/${NSTEP}_${IB}_GETZIP_O.dat
GET_ZIP 

NSTEP=${NJOB}_10    
#==============================================================================
LIBEL="CHECK TRANSFER"
CHECK_TFR_I=${GET_ZIP_O}
CHECK_TFR_CHAIN=${EXTCHAIN}
CHECK_TFR_O=${DFILT}/${NSTEP}_${IB}_CHECKTFR_O.dat
CHECK_TFR


NSTEP=${NJOB}_15
#==============================================================================
LIBEL="DEL ZIP EXTRACTION"
DEL_ZIP_I1=${GET_ZIP_O}
DEL_ZIP_I2=${CHECK_TFR_O}
DEL_ZIP


NSTEP=${NJOB}_20
# Begin rm
#==============================================================================
LIBEL="Step for the remove of the temporaty files of the job"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


# End of the Job
JOBEND
