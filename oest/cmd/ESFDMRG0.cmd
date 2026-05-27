#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFDMRG0.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 30/03/2023
# auteur                        : Mehdi NAJI
#---------------------------------------------------------------------------------
# description
#  IFRS17 MERGE FILES ( EXTENDED PERIOD)
#
#---------------------------------------------------------------------------------
# modif
# [01] 26/06/2023 : SPIRA 108961  - P&C and Life- Closing output during local extended period
# [02] 18/03/2024 : SPIRA 111271  - restore POS ESF_FSEGPROF_STD 
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
IDF_CT=$2

# Launch job to set context
NJOB="ESFD9001"
	. ${DCMD}/ESFD9001.cmd ${IDF_CT}

DT=`date +%Y%m%d%H%M%S`
for line  in `grep "^${IDF_CT}~ES[XR]_" ${DFILP}/${ENV_PREFIX}_ESFJ0000_TI17PERMFIL.dat  `
do
	
	SSD_COL=1  # par défault la position de la filiale est dans la première colonne
	ESB_COL=2  # par défault la position de l'établissement  est dans la 2ème   colonne
	PERMFIL_CT=`echo $line | cut -d"~" -f2 `
	PATHPATTRN_LL=`echo $line | cut -d"~" -f3 `
	comment=`echo $line | cut -d"~" -f5`
	if [ "${comment}" != "" ]
	then
		SSD_COL=`echo $line | cut -d"~" -f5| cut -d"," -f1 `
		ESB_COL=`echo $line | cut -d"~" -f5| cut -d"," -f2 `
	fi
	FILE_TO_MERGE=`eval echo $PATHPATTRN_LL | cut -d"=" -f2`
	FILE_POSX=`echo "$FILE_TO_MERGE" | sed -e s"/.dat$/_POSX.dat/"`
	FILE_GZ0=`echo $PATHPATTRN_LL | sed -e s/DFILP/DARCH/ -e s/.dat$/.dat.gz/ -e s/ENV_PREFIX/NCHAIN/ `
	FILE_GZ=`eval echo $FILE_GZ0 `
	if [  -f ${FILE_POSX} ]
	then
		NB_COLS=`head -1  ${FILE_POSX}| awk -F~ '{print NF}'`
	fi
	ECHO_LOG "" 											   2>&1 | ${TEE}
	ECHO_LOG " ------------------------------------------------------------------------------------" 2>&1 | ${TEE}
	ECHO_LOG " PERMFIL_CT ................. : $PERMFIL_CT"     2>&1 | ${TEE}
	ECHO_LOG " PATHPATTRN_LL .............. : $PATHPATTRN_LL"  2>&1 | ${TEE}
	ECHO_LOG " comment .................... : $comment"        2>&1 | ${TEE}
	ECHO_LOG " SSD_COL .................... : $SSD_COL "       2>&1 | ${TEE}
	ECHO_LOG " ESB_COL .................... : $ESB_COL"        2>&1 | ${TEE}
	ECHO_LOG " FILE_TO_MERGE .............. : $FILE_TO_MERGE " 2>&1 | ${TEE}
	ECHO_LOG " FILE_POSX .................. : $FILE_POSX"      2>&1 | ${TEE}
	ECHO_LOG " FILE_GZ .................... : $FILE_GZ "       2>&1 | ${TEE}
	ECHO_LOG " NB_COLS .................... : $NB_COLS "       2>&1 | ${TEE}
	ECHO_LOG "" 											   2>&1 | ${TEE}

	
	if [ "${PARM_POSX}" = "_POSX" ]
	then
		if [[ "${PERMFIL_CT}" =~ ^ESX_  ]]
		then
		if [ "${NB_COLS}" != "" ]
			then
				ECHO_LOG "------ MERGE ${FILE_TO_MERGE} ${FILE_POSX} -----------"
				NJOB="ESFDMRG1_$PERMFIL_CT"
				# Launch applicative job $NJOB
				${DCMD}/ESFDMRG1.cmd "${FILE_TO_MERGE}" "${FILE_POSX}"  "${SSD_COL}" "${ESB_COL}" "${NB_COLS}" 2>&1 | ${TEE} 
			fi
		fi
	else 
		ECHO_LOG "------ gzip  ${FILE_TO_MERGE} ${FILE_GZ} -----------"
		NJOB="ESFDMRG2_PERMFIL_CT"
		# Launch applicative job $NJOB
		${DCMD}/ESFDMRG2.cmd  "${FILE_TO_MERGE}" "${FILE_GZ}"  2>&1 | ${TEE} 
	fi	
	
	
done 


CHAINEND 