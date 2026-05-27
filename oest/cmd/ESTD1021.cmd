#=============================================================================
# nom de l'application          : ESTIMATIONS
#
# nom du script SHELL           : ESTD1021.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 09/11/2000
# auteur                        : Roger Cassis
# reference des specifications  :
#-----------------------------------------------------------------------------
# Description :
#   	Cumule a file named P_ESTD1020_SORT_I_ARCSTATGTA.dat to P.ESIX7000_ARCSTATGTA.dat
#
# Job launched by ESTD1020.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#   08/08/2006   Roger CASSIS  Pour eviter message Warning Unix, normalisation de la condition if 
#                              on met des crochets au lieu de la commande test
#[002] 24/01/2012 Roger Cassis :spot:23845 - Ajout des 16 champs dans le tri-cumul ARCSTATGTA - tri comme ESID7000
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

# If file exist we process it as sort input file
if [ ! -f ${DFILT}/${NCHAIN}_SORT_I_ARCSTATGTA.dat ]
then
   echo 'Fichier ${DFILT}/${NCHAIN}_SORT_I_ARCSTATGTA.dat non trouve - pas de traitement'
   JOBEND
fi

#[002]
NSTEP=${NJOB}_10
# Merge new GTA file to P_ESIX7000_ARCSTATGTA.dat
#------------------------------------------------------------------------------
LIBEL="Merge new GTA file to P_ESIX7000_ARCSTATGTA.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat 800 1"
SORT_I2="${DFILT}/${NCHAIN}_SORT_I_ARCSTATGTA.dat 800 1"
SORT_O="${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat.new 800 1"
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
	RETUW_NT 28:1 - 28:,
   KeyReconciliation  55:1 - 55:
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
	CUR_CF,
	KeyReconciliation
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="move $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat.new $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat"
EXECKSH "mv $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat.new $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat"


NSTEP=${NJOB}_20
# Begin RMFIL
#--------------------------------------------------------------------------
LIBEL="Remove of temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}_*"

JOBEND

