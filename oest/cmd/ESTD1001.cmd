#=============================================================================
# nom de l'application		: ESTIMATIONS
#				  
# nom du script SHELL		: ESTD1001.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 
# auteur			: CGI
# reference des specifications  : 
#-----------------------------------------------------------------------------
# Description :
#   	Sort of STATGTA and ARCSTATGTA files.
#
# Job launched by ESTD1000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications : 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT


NSTEP=${NJOB}_05
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Sort of ARCSTATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat 1000 1"
SORT_O="${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD << EOF
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
	CUR_CF 18:1 - 18:,
	RETCTR_NF 24:1 - 24:,
	RETEND_NT 25:1 - 25:,
	RETSEC_NF 26:1 - 26:,
	RTY_NF 27:1 - 27:,
	RETUW_NT 28:1 - 28:
/KEYS 
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF ,
	RETUW_NT,
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

JOBEND

NSTEP=${NJOB}_10
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Sort of STATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_STATGTA.dat 1000 1"
SORT_O="${DFILP}/${PCH}ESIX7000_STATGTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD << EOF
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
	CUR_CF 18:1 - 18:,
	RETCTR_NF 24:1 - 24:,
	RETEND_NT 25:1 - 25:,
	RETSEC_NF 26:1 - 26:,
	RTY_NF 27:1 - 27:,
	RETUW_NT 28:1 - 28:
/KEYS 
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF ,
	RETUW_NT,
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

JOBEND
