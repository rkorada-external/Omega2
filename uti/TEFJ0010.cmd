#!/bin/ksh
#==============================================================================
#nom de l'application          : Technical Chain for inter-site transfer
#nom du source                 : TEFJ0010.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 15/09/1997
#auteur                        : L.Moreau
#references des specifications : 
#------------------------------------------------------------------------------
# description :
#       Call technical Job TEFJ0011.cmd to get zip files from hosts sites
#	created by EXTCHAIN
# parameters  :
#	$1 : environment files
#	$2 : prefix name of files to get
#	$3 : remote site must be all, or "s1|s2|..."
#
#==============================================================================

if [ $# -ne 3 ]
then
  echo "# 3 parameters must be precised <env> <prefix name> <remote site s1|s2|..>"
  exit 1
fi

. ${DUTI}/fctgen.cmd

# Chain initialization
CHAININIT $0 $1

export EXTCHAIN="${2}"
export REMOTE_SITE="${3}"

# Get zip files from distant places according $REMOTE_SITE value
NJOB="TEFJ0011"
${DUTI}/TEFJ0011.cmd ${REMOTE_SITE} 2>&1 | ${TEE}

# Look in all pool directories if there is extraction files produced by EXTCHAIN
# if [ `ls ${DTRANSFER}/*/from/${EXTCHAIN}* 2>/dev/null | wc -l` -ne 0 ]
# then
#     MAX_RETURN_CODE=111  # this value is returned by CHAINEND function
# fi

CHAINEND
