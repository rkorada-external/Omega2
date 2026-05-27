#!/bin/ksh
#=============================================================================
# nom de l'application          : Get data - COMMUNS
# nom du script SHELL           : ESCJ0660.cmd
# revision                      : 
# date de creation              : 06/09/2021
# auteur                        : 
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  Copy permanent files from IFRS4
# parameters: 
#		ESCJ0660.env
#
#-----------------------------------------------------------------------------
# historiques des modifications
# Modifié le            Par                 Desc.
#
#---------------
#MODIFICATION   : [
#Auteur         : M.NAJI
#Date           : 06/09/2021
#Version        : 1.0
#Description    : Extraction quatidienne des  fichiers
#
#[001] 25/04/2022 DaD  spira : 94569 add parameter Quarter End
#===============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd


# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"



NJOB="ESFD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESFD9001.cmd "$IDF_CT"

# Extracting the number of days to substract on the pos booking date
set `GETPRM ${DPRM}/ESCJ0660.prm`
export X_DAYS=$1

ECHO_LOG "#===> GREP ON...............................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> GREP IN...............................................................: ${DPRM}/ESCJ0660.prm"

#[001]
export QUARTER_END_FOUND=`grep ${PARM_ICLODAT_D} ${DPRM}/ESCJ0660.prm | cut -d' ' -f 2` 

if [ -z "$QUARTER_END_FOUND" -o "$QUARTER_END_FOUND" -eq "${PARM_ICLODAT_D}" ];
then
	export QUARTER_END_FOUND=NONE
fi

ECHO_LOG "#===> QUARTER_END_FOUND.....................................................: ${QUARTER_END_FOUND}"

# Launch applicative job ESCJ0661
NJOB="ESCJ0661"
${DCMD}/ESCJ0661.cmd "${PARM_CRE_D}"  "$PARM_BALSHEYEA_NF" "$PARM_BALSHTMTH_NF" "$PARM_ICLODAT_D" "$PARM_CLODAT_D" 2>&1 | ${TEE}

# Launch applicative job ESCJ0662
NJOB="ESCJ0662"
${DCMD}/ESCJ0662.cmd   "$PARM_ICLODAT_D"  "$PARM_CLODAT_D"2>&1 | ${TEE}

# Launch applicative job ESCJ0663
NJOB="ESCJ0663"
${DCMD}/ESCJ0663.cmd   2>&1 | ${TEE}

# Launch applicative job ESCJ0664
NJOB="ESCJ0664"
${DCMD}/ESCJ0664.cmd   "${PARM_CRE_D}"  "$PARM_BALSHEYEA_NF" "$PARM_BALSHTMTH_NF"  2>&1 | ${TEE}

CHAINEND

