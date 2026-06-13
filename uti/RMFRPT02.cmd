#!/bin/ksh
#==============================================================================
#nom de l'application          : TECHNICAL BATCH
#nom du source                 : RMFRTP02.cmd
#revision                      : $Revision:   2.0  $
#date de creation              : 20/03/1998
#auteur                        : SCOR
#------------------------------------------------------------------------------
#description :
#
# ERROR BATCH REPORT 
#
#------------------------------------------------------------------------------
#historique des modifications :
#  
#
#----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

#set -x

# JOB Initialization
JOBINIT 


NSTEP=${NJOB}_05
# Begin
#------------------------------------------------------------------------------
LIBEL="Step to rename previous report file"
EXECKSH "grep FAILED $DFILT/${NCHAIN}_${IB}.dat > ${DFILP}/${NCHAIN}.dat.err"


# Build dynamically the awk file that build the report
AWK_CMD=${DFILT}/${NSTEP}_${IB}_AWK_I.dat
AWK_CMD2=${DFILT}/${NSTEP}_${IB}_AWK2_I.dat
cat <<EOF >${AWK_CMD}
BEGIN {
FS="_";
OFS=" "; 
LEFT_MARGIN = sprintf(" ");
} 
{
FOUND=1

# Print Title
if (NR==1) {
   DATE=sprintf ("%s/%s/%s", 
	substr(\$3,1,4), 
	substr(\$3,5,2), 
	substr(\$3,7,2)); 

   printf ("%19s DAILY %s ERROR BATCH REPORT\\n",
                LEFT_MARGIN, ENV_LL );

   printf ("%16s ON SERVER %s (DATE:%s)\\n\\n",
                LEFT_MARGIN, MACHINE, DATE );

   printf ("%4s %-19s %-10s %5s %-5s %7s %s\\n",
                LEFT_MARGIN, "CHAIN", "DAY", "START", "END", "ELAPSED", "STATUS");

   printf ("%4s-------------------- ---------- ----- ----- ------- -------\\n", 
		LEFT_MARGIN);

   if (\$4 == "START")
      continue
   }


}
END {
}
EOF


         NSTEP=${NJOB}_$i$j
         # Begin EXECKSH
         #-----------------------------------------------------------------
         LIBEL="Build  ERROR Report "
            EXECKSH_MODE=P
            EXECKSH "grep FAILED $DFILT/${NCHAIN}_${IB}.dat  | nawk -f ${AWK_CMD2} MACHINE=${HOST_PRDSIT} ENV_LL='${VAR_LABEL}'  >> ${DFILP}/${NCHAIN}.err
         fi

       fi
     done
   fi

done


NSTEP=${NJOB}_60
# Begin rm
#------------------------------------------------------------------------------
LIBEL="Step to remove temporary files"
# RMFIL "${AWK_CMD}"
# RMFIL "${AWK_CMD2}"

NSTEP=${NJOB}_65
# Copy in ${DFILT}
#------------------------------------------------------------------------------
EXECKSH_MODE=P
EXECKSH " touch ${DFILP}/${NCHAIN}.dat "
EXECKSH " cp ${DFILP}/${NCHAIN}.dat ${DFILT}/${NCHAIN}_${IB}.dat "

# End of Job
JOBEND
