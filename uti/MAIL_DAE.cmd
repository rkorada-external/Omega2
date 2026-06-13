#!/bin/ksh
#==============================================================================
#nom de l'application          : bibliotheque technique
#nom du source                 : MAIL_DAE.cmd
#revision                      : $Revision: 1.2 $
#date de creation              : 17/03/1999
#auteur                        : SCOR
#references des specifications : #################
#------------------------------------------------------------------------------
#description :
#    This program takes in charge mail sending to end users
#    It waits for command files to be posted in $DMAILLST
#    A command file (.dam) is composed as follows:
#        - 1st line: email address of the recipient
#        - 2nd line: subject of the mail
#        - 3rd line: file name for user
#        - 4th line: file name to transfer
#        - Rest of file: Message body (optional)
#------------------------------------------------------------------------------
#historique des modifications :
#
#----------------------------------------------------------------------------

# call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctftp.cmd


# Look if a old process is running
UXLOGIN=`/usr/ucb/whoami`

PROCESS=`ps -ef | grep MAIL_DAE | awk '$1==UXLOGIN && $2!=NUMID && $3!=NUMID {print $2}' NUMID="$$" UXLOGIN="${UXLOGIN}"`

if [ ! -z "${PROCESS}" ]  # Is there a process ?
then  # yes
      kill -9 ${PROCESS}
      echo 'The old process is killed and the current one is running'
fi

# Initialisation
# --------------
CHAININIT MAIL_DAE $1

NJOB=MAILSENDER
JOBINIT | ${TEE}
NSTEP=${NJOB}_01

# Running Mail sending process every 5 secondes
# ---------------------------------------------- 
LOOP_DELAY=5


# This file IP adress which connexion failed
# ------------------------------------------ 
FMAILERR=${DMAILLST}/${NSTEP}_DAE_ADRERR.dat

# No-ending Loop for continual transfer
# -------------------------------------
while (true)
do
   /bin/rm -f ${FMAILERR}

   for file in `ls -rt ${DMAILLST}/*.dam 2>/dev/null`
   do
      BASENAME=`basename ${file} | cut -d"." -f1`

      if [ `basename $file | awk '{print substr ($0,3,3)}'` != "DAE" ] && [ ! -z "${EXCEPT}" ] 
      then
       if [ `echo $file | egrep -v "${EXCEPT}" | wc -l` = 0 ]
       then
        mv ${DMAILLST}/${BASENAME}.* ${DMAIL}
        continue
       fi 
      fi

#      MAIL_DELAY=60
#      MAIL_NBRETRY=10

      # Get information about target 
      # ----------------------------
      MAIL_ADR=`head -1 ${file}`

      # If the restart exists, look if the Mail address is the one that failed  
      if [ -f ${FMAILERR} ]
      then
        if  [ `grep ${MAIL_ADR} ${FMAILERR} | wc -l` -ne 0 ]
        then
          continue
        fi
      fi
         
      MAIL_SUBJECT=`head -2 ${file} | tail -1`
      MAIL_FILEUSER=`head -3 ${file} | tail -1`
      MAIL_FILEPROD=${DMAILLST}/`head -4 ${file} | tail -1`

      STEPEND_CONTINUE="YES"
      STEP_NOECHO="YES"

      # Mail the data file
      #--------------------------------------------------
      # Step MAIL_PUT
      if [ "${RP}" = ""  -o "${RP}" = "${NSTEP}" -o "${ADT}" != "" ]
      then ADT="${NSTEP}"
         STEP_PRG=MAIL_PUT
         STEPSTART

         # Mail sending after encoding
         LIBEL="Mail sending"
         MAIL_ENCODED=${DFILT}/${NSTEP}_${IB}_MAILDAE_CODED_O1.tmp
         uuencode ${MAIL_FILEPROD} ${MAIL_FILEUSER} >${MAIL_ENCODED}
#         mailx -v -r'jpreget@scor.com' -s"${MAIL_SUBJECT}" ${MAIL_ADR} 1>>${FLOG} 2>&1 <<EOF
         mailx -s"${MAIL_SUBJECT}" ${MAIL_ADR} 1>>${FLOG} 2>&1 <<EOF
`tail +5 ${file}`

`cat ${MAIL_ENCODED}`
EOF
 

         MAIL_PUT_ERR=$?

         echo "#" | ${TEE}
         echo "# Mail to ${MAIL_ADR} ("  `date +"%Y/%m/%d %H:%M:%S"` ")" | ${TEE}
         if [ "${MAIL_PUT_ERR}" -eq 0 ]
         then
            # OK
            echo "# Sending of " `basename ${MAIL_FILEPROD}` " succeeded  (" `date +"%Y/%m/%d %H:%M:%S"` ")" | ${TEE}
            echo "# " `wc -c ${MAIL_ENCODED}|awk '{print $1}'` " bytes sent."| ${TEE}
         else
            echo "# Sending of " `basename ${MAIL_FILEPROD}` "  failed  (" `date +"%Y/%m/%d %H:%M:%S"` ")" | ${TEE}
            cat ${MAIL_LOG} | ${TEE}
         fi

         /bin/rm -f "${MAIL_LOG}" >/dev/null 2>&1
         /bin/rm -f "${MAIL_ENCODED}" >/dev/null 2>&1
         STEPEND ${MAIL_PUT_ERR}
      fi
      # End of Step MAIL_PUT

      if [ ${MAIL_PUT_ERR} -ne 0 ]
      then 
         echo `date +"%Y/%m/%d %H:%M:%S"` "-- MAIL_PUT failure for ${MAIL_FILEPROD} ; mail address : ${MAIL_ADR}\nmail file : $file\n" >> ${DABORT}/${NCHAIN}.rst     
      fi

      # The transfer has been done, the files are saved into $DMAIL
      mv ${DMAILLST}/${BASENAME}.dam ${DMAIL}/${BASENAME}.dam >/dev/null
      mv ${MAIL_FILEPROD} ${DMAIL} >/dev/null

   done
   sleep ${LOOP_DELAY}
done

