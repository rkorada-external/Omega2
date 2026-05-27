#! /bin/ksh
#===============================================================================
#application name               : Extraction data from database
#source name                    : EXTJ0012.cmd
#revision                       : $Revision:   0.1  $
#extraction date                : 17/11/2023
#author                         : Teixeira David
#specifications reference       :
#                               :
#-------------------------------------------------------------------------------
#description : Delete Files
#
#parameters :
#
#-------------------------------------------------------------------------------
#modifications chronology  :
# [01] 20/07/2021 D.TEIXEIRA : add EXTJ0010.prm 
#===============================================================================


# call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
#-------------------
JOBINIT

#------------------------------------------------------------------------------
# Get the parameters
#-------------------
if [ "${FPARM}" = "" ]; then
   FPARM=`CFTMP` 
   cat ${DPRM}/EXTJ0010.prm | sed 's/^ *//g;/^$/d' | sed 's/ \+/="/' | sed 's/ *$/"/' > ${FPARM}
fi

KEEP_TEMP_DAY=`GETV ${FPARM} KEEP_TEMP_DAY`
KEEP_INTERM_DAY=`GETV ${FPARM} KEEP_INTERM_DAY`


NSTEP=${NJOB}_05
LIBEL="Delete files oldest then ${KEEP_INTERM_DAY} days from \${DFILI}"
EXECKSH_MODE=P
EXECKSH "find '${DFILI}' -maxdepth 1 -mtime +${KEEP_INTERM_DAY} -name '${NCHAIN}_EXTJ0011*' -exec rm -vf {} \;"

NSTEP=${NJOB}_10
LIBEL="Delete of temporary files"
RMFIL "${DFILT}/${NCHAIN}_EXTJ0011*.dat"

JOBEND
