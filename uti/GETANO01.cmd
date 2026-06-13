#!/bin/ksh
#=============================================================================
# nom de l'application          : TECHNICAL BATCH
# nom du script SHELL           : GETANO01.cmd
# revision                      : $Revision: 1.1 $
# date de creation              : 25/05/98
# auteur                        : JP
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
#   No input parameters
#
# JOB LANCE PAR : GETANO00.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#    
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

JOBINIT

NSTEP=${NJOB}_00
# Build dynamically the awk file that build the report
#------------------------------------------------------------------------------
AWK_CMD1=${DTMP}/${NSTEP}_${IB}_AWK1_I.dat
AWK_CMD2=${DTMP}/${NSTEP}_${IB}_AWK2_I.dat
cat <<EOF >${AWK_CMD1}
BEGIN { FS=" " }
{ 
   if ((match(\$2, "Begin") != 0)  && (match(\$4, "step") != 0))
   {  
print "#=========================================================================" > FILETMP
      cpt_step=1
   }

   if (match(\$2, "ABNORMAL") != 0) 
   {  print "#  ======================================================="
      found_error=1
      cpt=1
   }

 if (cpt == 1) 
  { if (match(\$2, "ERROR:") != 0) cpt=0;
   print \$0
   if (cpt == 0)
     print "#  =======================================================\n";
  }  

 if (cpt_step == 1) 
  { print \$0 >> FILETMP
   if ( ( (match(\$2, "Max") != 0)  || (match(\$2, "LOOP_JOBSSD") != 0) ) || ((match(\$2, "End") != 0)  && (match(\$4, "step") != 0)))
    {  cpt_step=0
       print "#-------------------------------------------------------------------------\n" >> FILETMP
       if (found_error == 1) 
       #ce step contient une erreur donc on le garde
	{  system("cat " FILETMP " >> " FILE)
	   found_error=0
        }
	close(FILETMP)
    }
  }  
}
EOF


cat <<EOF >${AWK_CMD2}
BEGIN { FS=":" }
{ 
   if  ((match(\$1, "# PRGANO") != 0) || (match(\$1, "# PRGLOG") != 0))
   {  printf("Step Log: %s \n", \$2 )
      found=1
      system("lp -onobanner $DFILT/" \$2 " 2>/dev/null")  #/dev/null pour estimations
   }

}
END {
   if (found == 0) 
   { # on imprime la log de la chaine si pas de log du step 
   print "Not Found" > RETOUR
   }
}
EOF


NSTEP=${NJOB}_05
# Begin EXECKSH
#------------------------------------------------------------------------------
LIBEL="Get List of Failed Jobs"
EXECKSH_MODE=P
EXECKSH "ls ${DRMF}/RMF_*_${ENV}_*FAILED >${DTMP}/${NSTEP}_${IB}_FAILED.dat 2>/dev/null ; echo"

NSTEP=${NJOB}_10
# Begin EXECKSH
#------------------------------------------------------------------------------
LIBEL="Display number of failed jobs"
EXECKSH_MODE=P
EXECKSH "echo '\nNb of failed jobs in' ${ENV_LL} ' on machine' ${MACHINE} ':' `wc -l ${DTMP}/${NJOB}_05_${IB}_FAILED.dat | awk '{print $1}'`"

if [ -s ${DTMP}/${NJOB}_05_${IB}_FAILED.dat ]
then

NSTEP=${NJOB}_15
# Begin EXECKSH
#------------------------------------------------------------------------------
LIBEL="Get Name of Chain Log File"
EXECKSH_MODE=P
awk -F'_' '{print "$DLOG/" $3 "_" $4 "_*" $2 "*.log"}' ${DTMP}/${NJOB}_05_${IB}_FAILED.dat  >${DTMP}/${NSTEP}_${IB}_ANOFILES.dat

NSTEP=${NJOB}_20
# Begin EXECKSH
#------------------------------------------------------------------------------
LIBEL="Print Corresponding Ano Files"
for i in `cat ${DTMP}/${NJOB}_15_${IB}_ANOFILES.dat`
do
  files=`eval ls $i`
  echo "\nChain Log: $files"
  rm -f ${DTMP}/${NSTEP}_${IB}_LOGCHAIN.tmp
  rm -f ${DTMP}/${NSTEP}_${IB}_LOGCHAIN.dat
  awk -f${AWK_CMD1} FILE=${DTMP}/${NSTEP}_${IB}_LOGCHAIN.dat FILETMP=${DTMP}/${NSTEP}_${IB}_LOGCHAIN.tmp $files | awk -f${AWK_CMD2} RETOUR=${DTMP}/${NJOB}_20_${IB}_RETOUR.dat
  cat ${DTMP}/${NSTEP}_${IB}_LOGCHAIN.dat
  if [ -s ${DTMP}/${NSTEP}_${IB}_RETOUR.dat ]
  then
	lp ${DTMP}/${NSTEP}_${IB}_LOGCHAIN.dat
  fi

done

fi


NSTEP=${NJOB}_25
# Begin RMFIL
#------------------------------------------------------------------------------
LIBEL="Remove temporary files"
RMFIL "${DTMP}/${NJOB}*_${IB}_*.dat"
RMFIL "${DTMP}/${NJOB}*_${IB}_*.tmp"

# End of Job
JOBEND
