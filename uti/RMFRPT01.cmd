#!/bin/ksh
#==============================================================================
#nom de l'application          : TECHNICAL BATCH
#nom du source                 : RMFRTP01.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 20/03/1998
#auteur                        : SCOR
#------------------------------------------------------------------------------
#description :
#
# No input parameters
#
#------------------------------------------------------------------------------
#historique des modifications :
#   23/02/1999: New loop on environment/machine, simplified design
#               addition of day field 
#----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

#set -x

# JOB Initialization
JOBINIT 


NSTEP=${NJOB}_05
# Begin rm
#------------------------------------------------------------------------------
LIBEL="Step to rename previous report file"
EXECKSH "mv ${DFILP}/${NCHAIN}.dat ${DFILP}/${NCHAIN}.dat.old"


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

   printf ("%19s DAILY %s BATCH REPORT\\n",
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

 # Extract and format data
 CHAIN=sprintf ("%s_%s",\$3, \$4); 
 STARTED=sprintf ("%sh%s", substr(\$2,9,2), substr(\$2,11,2)); 

}
END {
}
EOF

cat <<EOF >${AWK_CMD2}
BEGIN {
FS="_";
OFS=" ";
LEFT_MARGIN = sprintf(" ");
}
{
FOUND=1

   if (\$4 == "START")
	 continue
	}
{
 # Extract and format data
 CHAIN=sprintf ("%s_%s",\$3, \$4);
 STARTED=sprintf ("%sh%s", substr(\$2,9,2), substr(\$2,11,2));
 DATE=sprintf ("%s/%s/%s", 
	substr(\$2,1,4), 
	substr(\$2,5,2), 
	substr(\$2,7,2)); 

# Test if we are in IN_RUN case
 if (\$9 != 0) {
     ENDED=sprintf ("%sh%s", substr(\$5,9,2), substr(\$5,11,2));
     ELAPSED=sprintf ("%sh%smn", substr(\$6,1,2), substr(\$6,4,2));
 }
 else {
     ENDED=sprintf ("%7s", LEFT_MARGIN);
     ELAPSED=sprintf ("%7s", LEFT_MARGIN);
 }

 STATUS=\$7;
 if ( match (STATUS, "FAILED" ))
  STATUS=sprintf ("%s   *****", STATUS);

 # Print formatted data
  printf("%4s%-20s %s %s %s %s %s\\n", LEFT_MARGIN, CHAIN, DATE, STARTED, ENDED, ELAPSED, STATUS);
}
END {
   if (FOUND !=0) printf ("\\n\\n^L\\n");
}
EOF

# Loop on environments
# --------------------
i=0
while [ true ]
do
   i=`expr $i + 1`
   VAR_ENV=`eval 'echo $ENV'$i`
   VAR_LABEL=`eval 'echo $ENV_LL'$i`
   if [ -z "${VAR_ENV}" ]
   then
      break   # var not defined. end of loop on environments
   else
     # Loop on machines
     # ----------------
     j=0
     while [ true ]
     do
       j=`expr $j + 1`
       VAR_MACHINE=`eval 'echo $MACHINE'$j`
       VAR_RMFDIR=`eval 'echo $DRMFI'$j`
       if [ -z "${VAR_MACHINE}" ]
       then
          break   # var not defined. end of loop on machines
       else

         NSTEP=${NJOB}_$i$j
         # Begin EXECKSH
         #-----------------------------------------------------------------
         LIBEL="Build Report for server ${VAR_MACHINE} on ${VAR_LABEL} environment "
         if test -f ${VAR_RMFDIR}/RMF_*_${VAR_ENV}_*
         then
            EXECKSH_MODE=P
            EXECKSH "grep -l ${VAR_MACHINE} ${VAR_RMFDIR}/RMF_*_START_BATCH_PROCESS | nawk -f ${AWK_CMD} MACHINE=${VAR_MACHINE} ENV_LL='${VAR_LABEL}'   >> ${DFILP}/${NCHAIN}.dat"
            EXECKSH_MODE=P
            EXECKSH "grep -l ${VAR_MACHINE} ${VAR_RMFDIR}/RMF_*_${VAR_ENV}_* | nawk -f ${AWK_CMD2} MACHINE=${VAR_MACHINE} ENV_LL='${VAR_LABEL}'  >> ${DFILP}/${NCHAIN}.dat"
         fi

       fi
     done
   fi

done


NSTEP=${NJOB}_60
# Begin rm
#------------------------------------------------------------------------------
LIBEL="Step to remove temporary files"
RMFIL "${AWK_CMD}"
RMFIL "${AWK_CMD2}"

NSTEP=${NJOB}_65
# Copy in ${DFILT}
#------------------------------------------------------------------------------
EXECKSH_MODE=P
EXECKSH " touch ${DFILP}/${NCHAIN}.dat "
EXECKSH " cp ${DFILP}/${NCHAIN}.dat ${DFILT}/${NCHAIN}_${IB}.dat "

# End of Job
JOBEND
