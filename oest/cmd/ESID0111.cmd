#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID0111.cmd
# revision                      : $Revision: 1.0 
# date de creation              : 25/03/2015
# auteur                        : Roger cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Generation of Estimates File and retro account files :spot:28483
#-----------------------------------------------------------------------------
# historiques des modifications
#[xxx] prog. name  JJ/MM/AAAA :spot:xxxxx - Comment
#======================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3

if [ ${EST_ESID0060_COND1} = "N"  -a ${EST_ESID0060_COND3} = "N" ]
then
	NSTEP=${NJOB}_20
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Current Generation of retro accounted 100% transactions"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${EST_FACCTRAA0}
	BCP_QRY="execute BEST..PsACCTRAA_01 ${BALSHTYEA_NF}"
	BCP
fi

JOBEND
