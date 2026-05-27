#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESGD2560.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 16/07/2025
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   
#-----------------------------------------------------------------------------
# historiques des modifications

#===============================================================================
#set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"

# Launch job to set context
NJOB="ESFD9001"
. ${DCMD}/ESFD9001.cmd ${IDF_CT}



set `GETPRM ${DPRM}/ESCJ0660.prm`
export X_DAYS=$1
export QUARTER_END_FOUND=`grep ${PARM_ICLODAT_D} ${DPRM}/ESFD5000.prm | cut -d' ' -f 2`

if [ "${NORME_CF}" = "EBS" ] || [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
then
      if  [ "${TYPEINV}" = "INV" ]
      then
            export PARM_DATE_FIN_D="${PARM_BOOKINGNEXT_D}"
      fi
      if  [ "${TYPEINV}" = "POS" ]
      then
            export PARM_DATE_FIN_D="${PARM_PSTOMGEND17_D}"
      fi
fi



if [ "$IDF_CT" = "I4I_EBS_SERQS_MERGE_REFRESH" ]; then
	# Launch job ESGD2561
	NJOB="ESGD2561"
	${DCMD}/ESGD2561.cmd  2>&1 | ${TEE}

fi


if [ "$IDF_CT" = "I4I_SERQS_MERGE_REFRESH" ]; then

	
    # Launch applicative job ESEH1101
    NJOB="ESEH1101"
    ${DCMD}/ESEH1101.cmd ${PARM_SEGTYP_CT} ${PARM_DBCLO_D} 2>&1 | ${TEE}


fi


if [ "$IDF_CT" = "EBS_SERQS_MERGE_REFRESH" ]; then

	
	# Launch job ESGD2562
	NJOB="ESGD2562"
	${DCMD}/ESGD2562.cmd  2>&1 | ${TEE}

fi


CHAINEND
