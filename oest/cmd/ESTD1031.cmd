#=============================================================================
# nom de l'application          : ESTIMATIONS
#
# nom du script SHELL           : ESTD1031.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 09/11/2000
# auteur                        : Roger Cassis
# reference des specifications  :
#-----------------------------------------------------------------------------
# Description :
#   	Cumule a file named P_ESTD1030_SORT_I_STATGTR.dat to P.ESIX7000_STATGTR.dat
#
# Job launched by ESTD1030.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#   07/12/2007   Roger CASSIS   spot 14806 - Ajout colonne RETINTAMT_M au tri
#[002] 11/07/2016 Roger Cassis :spot:30911 - Agrandissement GTs
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

# If file exist we process it as sort input file
if test ! -f ${DFILT}/${NCHAIN}_SORT_I_STATGTR.dat
then
   echo 'Fichier ${DFILT}/${NCHAIN}_SORT_I_STATGTR.dat non trouve - pas de traitement'
   JOBEND
fi

NSTEP=${NJOB}_10
# Merge new GTR file to P_ESIX7000_STATGTR.dat
#------------------------------------------------------------------------------
LIBEL="Merge new GTR file to P_ESIX7000_STATGTR.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_STATGTR.dat 800 1"
SORT_I2="${DFILT}/${NCHAIN}_SORT_I_STATGTR.dat 800 1"
SORT_O=${DFILP}/${PCH}ESIX7000_STATGTR.dat.new
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF 1:1 - 1:,
	ESB_CF 2:1 - 2:,
	BALSHEY_NF 3:1 - 3:,
	BALSHRMTH_NF 4:1 - 4:,
	BALSHRDAY_NF 5:1 - 5:,
	TRNCOD_CF 6:1 - 6:,
		TRNCOD1_CF 6:1 - 6:1,
		TRNCOD8_CF 6:8 - 6:8 EN,
	DBLTRNCOD_CF 7:1 - 7:,
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
	AMT_M 19:1 - 19:EN 15/3,
	CED_NF 20:1 - 20:,
	BRK_NF 21:1 - 21:,
	PAY_NF 22:1 - 22:,
	KEY_NF 23:1 - 23:,
	RETCTR_NF 24:1 - 24:,
	RETEND_NT 25:1 - 25:,
	RETSEC_NF 26:1 - 26:,
	RTY_NF 27:1 - 27:,
	RETUW_NT 28:1 - 28:,
	RETOCCYEA_NF 29:1 - 29:,
	RETACY_NF 30:1 - 30:,
	RETSCOSTRMTH_NF 31:1 - 31:,
	RETSCOENDMTH_NF 32:1 - 32:,
	RCL_NF 33:1 - 33:,
	RETCUR_CF 34:1 - 34:,
	RETAMT_M 35:1 - 35:EN 15/3,
	PLC_NT 36:1 - 36:,
	RTO_NF 37:1 - 37:,
	INT_NF 38:1 - 38:,
	RETPAY_NF 39:1 - 39:,
	RETKEY_CF 40:1 - 40:,
   RETINTAMT_M 41:1 - 41:EN 15/3,
   FIN 42:1 - 71:
/KEYS
	RETCTR_NF ,
	RETEND_NT ,
	RETSEC_NF ,
	RTY_NF ,
	RETUW_NT ,
	CTR_NF ,
	END_NT ,
	SEC_NF ,
	UWY_NF ,
	UW_NT ,
	OCCYEA_NF ,
	ACY_NF ,
	SCOSTRMTH_NF ,
	SCOENDMTH_NF ,
	CLM_NF ,
	CUR_CF ,
	SSD_CF ,
	ESB_CF ,
	BALSHEY_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF ,
	CED_NF ,
	BRK_NF ,
	PAY_NF ,
	KEY_NF ,
	RETOCCYEA_NF ,
	RETACY_NF ,
	RETSCOSTRMTH_NF ,
	RETSCOENDMTH_NF ,
	RCL_NF ,
	RETCUR_CF ,
	PLC_NT ,
	RTO_NF ,
	INT_NF ,
	RETPAY_NF ,
	RETKEY_CF
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT , SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_MC, FIN
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILP/${PCH}ESIX7000_STATGTR.dat.new $DFILP/${PCH}ESIX7000_STATGTR.dat"
EXECKSH "mv $DFILP/${PCH}ESIX7000_STATGTR.dat.new $DFILP/${PCH}ESIX7000_STATGTR.dat"


NSTEP=${NJOB}_20
# Begin RMFIL
#--------------------------------------------------------------------------
LIBEL="Remove of temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}_*"

JOBEND

