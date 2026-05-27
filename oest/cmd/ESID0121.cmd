#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID0121.cmd
# revision                      : $Revision: 1.0 
# date de creation              : 05/02/2019
# auteur                        : Rafael Vieville
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Generation of Estimates File and retro account files :APOLO Quarterly
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] 08/04/2022 M.NAJI     :SPIRA 111484 Optimisation CLOSING_D0 ESID0120
#======================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd

# Job Initialization
JOBINIT

# Parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3

if [ ${EST_ESID0060_COND1} = "N"  -a ${EST_ESID0060_COND3} = "N" ] ||
	[ ${EST_VARIANTE} = "7" -o  ${EST_VARIANTE} = "4" ]
then
#PARALLEL_INIT 2
	#[01]
	#NSTEP=${NJOB}_10
	## Begin bcp
	##------------------------------------------------------------------------------
	#LIBEL="Current Generation of Estimates File"
	#BCP_WAY="OUT"
	#BCP_VER="+"
	#BCP_O=${EST_FLIFESTY1}.old
	#BCP_QRY="execute BEST..PsLIFEST_09 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}'"
	#BCP

	NSTEP=${NJOB}_15
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Current Generation of Estimates File quaterly"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${EST_FLIFESTQ0}
	BCP_QRY="execute BEST..PsLIFESTD_01 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}'"
	BCP
#PARALLEL_END
fi

JOBEND
