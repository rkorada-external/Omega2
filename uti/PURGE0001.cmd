#!/bin/ksh
############################################################################
###                                                                      ###
###                     @(#)  PURGE.CMD   VERSION  1.00                  ###
###  Module:                       cleanlog                              ###
###  Dernier Modifieur:  ---- prod                       ----            ###
###  Create date     :            le 09/09/96                            ###
###  Update date     :            le  21/10/96                           ###
###  ------------------------------------------------------------------- ###
###  Description: Suppression des fichiers vieux de plus de N jours      ###
###  Descript   : delete of files oldest N days                          ###
###  ------------  							 ###
###  parameters                                                          ###
###  	$1	directory into wich we want deleted     		 ###
###     $2      number of days we want kept ( > or = à 3j )              ###
############################################################################

# Usage
#
# set -x
# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the job
JOBINIT

if [ $# -lt 2 ]
then
  echo ""
  echo "  Usage : PURGE.ksh  <directory> <Nb days>  "
  echo ""
  echo "  with : <Nb days>  > or =  3 days  "
  echo "     log dans /....../production/log/PURGEXPL.log) "
  echo ""
  exit 12
fi

# Nouvelle version de echo
#
e_cho()
{ echo "$*" | tee -a ${LOG}
}


# Variables
#
 
DEL_FILES=non
 
if [ $# -eq 1 ]
then 
	e_cho " you must give the directory's name and the number of days" 
fi

if [ $# -eq 2 ]
then 
	DEL_FILES=oui
	DEL_REP=$1
	NB_JOURS=$2
fi

T_MP=${DTMP}/purge.$$

# e_cho "\n---- START ---- : "`date`


# Test sur les variables
#
if [ ${DEL_FILES} = oui ]
then
    TT=`expr ${NB_JOURS} + 0 2>/dev/null`
    if [ "${TT}" != "${NB_JOURS}" ]
    then e_cho "\nThe value <${NB_JOURS}> is not numeric ...\n"
         exit 2
    fi
    if [ ${NB_JOURS} -le 1 ]
    then e_cho "\n<${NB_JOURS}> is below  2 days ...\n" ; exit 4
    fi
fi

# Suppression des fichiers vieux de plus de NB_JOURS jours
# sous ${DEL_REP}
#
if [ -d ${DEL_REP} ]
then
   du_AVANT=`du -s ${DEL_REP}` 
   cd ${DEL_REP}
   if [ ${DEL_FILES} = oui ]
   then e_cho "\ndelete of files (oldest ${NB_JOURS} days) into ${DEL_REP} :"
     find . -type f -mtime +${NB_JOURS} -print -exec /usr/bin/rm -f {} \; | tee -a ${LOG}
   fi
else
   e_cho "\nThe directory ${DEL_REP} does not exist ..."
   exit 12
fi

JOBEND
