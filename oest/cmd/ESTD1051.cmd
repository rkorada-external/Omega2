#=============================================================================
# nom de l'application          : ESTIMATIONS
#
# nom du script SHELL           : ESTD1051.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 15/03/2002
# auteur                        : Roger Cassis
# reference des specifications  :
#-----------------------------------------------------------------------------
# Description :
#   	sort of P.ESIX7000_ARCSTATGTA.dat
#
# Job launched by ESTD1050.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

NSTEP=${NJOB}_05
# Sort P_ESIX7000_ARCSTATGTA.dat
#------------------------------------------------------------------------------
LIBEL="SORT P_ESIX7000_ARCSTATGTA.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat 800 1"
SORT_O="${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat.new 800 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	CTR_NF 8:1 - 8:,
	END_NT 9:1 - 9:,
	SEC_NF 10:1 - 10:,
	UWY_NF 11:1 - 11:,
	UW_NT 12:1 - 12:,
	OCCYEA_NF 13:1 - 13:,
	ACY_NF 14:1 - 14:,
	SCOSTRMTH_NF 15:1 - 15:,
	SCOENDMTH_NF 16:1 - 16:,
	CLM_NF 17:1 - 17:,
	CUR_CF 18:1 - 18:
/KEYS
	CTR_NF ,
	END_NT ,
	SEC_NF ,
	UWY_NF ,
	UW_NT ,
	OCCYEA_NF ,
	ACY_NF ,
	SCOSTRMTH_NF ,
	SCOENDMTH_NF ,
	CLM_NF,
	CUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat.new $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat"
EXECKSH "mv $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat.new $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat"

JOBEND

