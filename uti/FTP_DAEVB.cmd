#!/bin/ksh
#==============================================================================
#nom de l'application          : bibliotheque technique
#nom du source                 : FTP_DAEVB.cmd
#revision                      : $Revision: 1.2 $
#date de creation              : 03/01/1997
#auteur                        : C.G.I. ()
#references des specifications : #################
#------------------------------------------------------------------------------
#description :
#    This program takes in charge file transfer to Printing server
#
#    This processis pooling every $LOOP_DELAY seconds the $DFTPLST directory 
#    to check transfer request.
#    A transfer request consists of a set of 3 files and following suffixes:
#    - .ftp contains information about printing server target to allow file transfer
#    - .dae file is the command file that will be executed on the printing server
#    - .dat file is the output file we want to be processed by the printing server.
#       => Publish the file to the web
#       => Print out the file
#       => Send the file by email
#
# These 3 files come from PRN functions that take .dat file as input and generates
# automatically .ftp and .dae files
#
# The 7th field value of .ftp file  belongs to "ALL","WEB","PRINT" set
# if value equals ALL, then .dat can be printed out and published
# if value equals WEB, then .dat can be only published to SCORWEB
# if value equals PRINT, then .dat can be only printed
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <05/06/1997>   <Guiheux>    < Error Handling for FTP >
#   <03/10/2000>   <Guiheux>    < Web publishing management >
#   <23/02/2001>   <Guiheux>    < allow web and/or print >
#   <20/03/2001>   <Guiheux>    < handle modified .ftp structure to allow web and/or from PRN_OUT value >
#
#----------------------------------------------------------------------------

# call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctftp.cmd
# set -x


CDE=`basename $0`
LOOP_DELAY=1	# Running File transfer process every 5 secondes
FTP_DELAY=2
FTP_NBRETRY=2
FTP_TIMEOUT=5

DEFAULT_PUBLISH_OUT=WEB


# Look if a old process is running
UXLOGIN=`/usr/ucb/whoami`

PROCESS=`ps -ef | grep FTP_DAEVB.cmd | awk '$1==UXLOGIN && $2!=NUMID && $3!=NUMID {print $2}' NUMID="$$" UXLOGIN="${UXLOGIN}"`

if [ ! -z "${PROCESS}" ]  # Is there a process ?
then  # yes
      kill -9 ${PROCESS}
      echo 'The old process is killed and the current one is running'
fi

# Initialisation
# --------------
CHAININIT FTP_DAEVB $1

NJOB=LISTENER
JOBINIT | ${TEE}
NSTEP=${NJOB}_01

echo "# Printing Pool"
echo "#   -> DFTPLST: ${DFTPLST}" | ${TEE}
echo "#   -> DLST: ${DLST}" | ${TEE}


# This file IP adress which connexion failed
# ------------------------------------------ 
FFTPERR=${DFTPLST}/${NSTEP}_DAEVB_IPERR.dat

# No-ending Loop for continual transfer
# -------------------------------------
while (true)
do
   /bin/rm -f ${FFTPERR}

   for i in `ls -rt ${DFTPLST}/*.ftp 2>/dev/null`
   do
      FLAG_PRINT=1
      BASENAME=`basename ${i} | cut -d"." -f1`

      # Printing Filter from Exception variable
      if [ `basename $i | awk '{print substr ($0,3,3)}'` != "DAE" ] && [ ! -z "${EXCEPT}" ] 
      then
       if [ `echo $i | egrep -v "${EXCEPT}" | wc -l` = 0 ]
       then
        # ftp transfer will be disactivated
        ####################################

        # HG 04/10/02
        # If it is a starpdf to be mailed the request will sent to the printing server
        FLAG_PGM=`awk -F"," '{print $1}' ${DFTPLST}/${BASENAME}.dae`
        if [ "${FLAG_PGM}" != "Starpdf" ]
        then
           FLAG_PRINT=0 
        fi
        #/bin/mv ${DFTPLST}/${BASENAME}.* ${DLST}
        #continue
       fi 
      fi

      # Get information about target 
      # ----------------------------
      FTP_IP=`cat ${i} | awk '{print $1}'`
 
      # If the restart exists, look if the IP adress is the one in fail 
      if [ -f ${FFTPERR} ]
      then
        if  [ `grep ${FTP_IP} ${FFTPERR} | wc -l` -ne 0 ]
        then
          continue
        fi
      fi

         
      FTP_USR=`cat ${i} | awk '{print $2}'`
      FTP_PSWD=`cat ${i} | awk '{print $3}'`
      FTP_RDIR=`cat ${i} | awk '{print $4}'`
      FTP_FDATA=`cat ${i} | awk '{print $5}'`
      FTP_MODE=`cat ${i} | awk '{print $6}'`
      PUBLISH_OUT=`cat ${i} | awk '{print $7}'`
      [ "${PUBLISH_OUT}" != "ALL" ] && [ "${PUBLISH_OUT}" != "WEB" ] && [ "${PUBLISH_OUT}" != "PRINT" ] && PUBLISH_OUT=${DEFAULT_PUBLISH_OUT}

      FTP_LDIR=${DFTPLST}
      FTP_PUT_ERR=0

      #
      # Distinguish 2 directory targets
      # One for standard Input Queue
      # One for WEB PUBLISHING
      # ################################
      FTP_RDIR_DATA=${FTP_RDIR}
      FTP_RDIR_WEB=${FTP_RDIR}web


      # Determine if the file must be published to WEB
      # Required Conditions :
      #    - It is not an asynchronous job
      #    - It is a Starpage command
      # ##############################################
      
      # Determine if the file to transfer comes asynchronous job (?DAE*)
      FILTERED_FILE=`ls ${FTP_LDIR}/?_DAE_*.dat 2>/dev/null | grep ${BASENAME}.dat | awk -F"/" '{print $NF}'`
      if [ "${FILTERED_FILE}" = "${BASENAME}.dat" ]
      then
         PUBLISH_OUT=PRINT   # Asynchronous job => DO NOT PUBLISH TO SCORWEB
      else
         FILTERED_COMMAND=`cut -d"," -f1  ${FTP_LDIR}/${BASENAME}.dae`
         if [ "${FILTERED_COMMAND}" != "Starpage" ]
         then
            PUBLISH_OUT=PRINT
         fi
      fi

      # Test if a File transfer can be proceeded
      # ----------------------------------------
      STEP_NOECHO="YES"
      STEPEND_CONTINUE="YES"
      FTP_TEST >> ${FLOG} 2>&1
      FTP_TEST_ERR=$?

      # if connexion can be established, let's do the file transfer
      # -----------------------------------------------------------
      if [ ${FTP_TEST_ERR} -eq 0 ]
      then

         STEPEND_CONTINUE="YES"
         STEP_NOECHO="YES"


         # The filename transferred is not the complete name
         # but the reduced one with sjtxxxx.*
         # --------------------------------------------------
         # Transfer the data file
         FTP_RDIR=${FTP_RDIR_DATA}
         FTP_I="${BASENAME}.dat"
         FTP_O=${FTP_FDATA}


         if [ "${FLAG_PRINT}" = 1 ] && [ "${PUBLISH_OUT}" != "WEB" ]
	 then
	    FTP_PUT >> ${FLOG} 2>&1
            FTP_PUT_ERR=$?
         fi


	 # Transfer .dat file for WEB PUBLISHING with complete name
	 #########################################################
         FTP_O=${FTP_I}
         FTP_RDIR=${FTP_RDIR_WEB}

         if [ ${FTP_PUT_ERR} -eq 0 ] && [ "${PUBLISH_OUT}" != "PRINT" ]
         then
            FTP_PUT >> ${FLOG} 2>&1
            FTP_PUT_ERR=$?
         fi


         # Reset ftp mode to asccii after data transfer
         FTP_MODE=ascii

         if [ ${FTP_PUT_ERR} -eq 0 ]
         then
            STEPEND_CONTINUE="YES"
            STEP_NOECHO="YES"
            # The filename transferred is not the complete name
            # but the reduced one with sjtxxxx.*
            # --------------------------------------------------
            FTP_I="${BASENAME}.daw"
            FTP_RDIR=${FTP_RDIR_DATA}

            if [ ! -f  ${DFTPLST}/${BASENAME}.daw ]
            then
               FTP_I="${BASENAME}.dae"
               FTP_O=`echo ${BASENAME} | awk -F"_" '{ print $NF}'`".dae"
            else
               FTP_O=`echo ${BASENAME} | awk -F"_" '{ print $NF}'`".daw"
            fi


            if [ "${FLAG_PRINT}" = 1 ] && [ "${PUBLISH_OUT}" != "WEB" ]
	    then
	       FTP_PUT >> ${FLOG} 2>&1
               FTP_PUT_ERR=$?
            fi

            # Transfer Printing .dae file for WEB PUBLISHING
            # #################################################################
            if [ ${FTP_PUT_ERR} -eq 0 ] && [ ! -f  ${DFTPLST}/${BASENAME}.daw ] && [ "${PUBLISH_OUT}" != "PRINT" ]
            then

               FTP_RDIR=${FTP_RDIR_WEB}
               FTP_O="${BASENAME}.dae"

               FTP_PUT >> ${FLOG} 2>&1
               FTP_PUT_ERR=$?
            fi

           
            if [ ${FTP_PUT_ERR} -ne 0 ]
	    then 
               echo `date +"%Y/%m/%d %H:%M:%S"` "-- FTP_PUT failure for ${FTP_I} ; IP adress : ${FTP_IP}web\nftp file : $i\n" >> ${DABORT}/${NCHAIN}.rst     
            fi

         else
            echo `date +"%Y/%m/%d %H:%M:%S"` "-- FTP_PUT failure for ${FTP_I} ; IP adress : ${FTP_IP}web\nftp file : $i\n" >> ${DABORT}/${NCHAIN}.rst     
         fi


         if [ ! -f  ${DFTPLST}/${BASENAME}.daw ]
         then
            mv ${DFTPLST}/${BASENAME}.dae ${DLST}/${BASENAME}.dae >/dev/null
         else
            mv ${DFTPLST}/${BASENAME}.daw ${DLST}/${BASENAME}.daw >/dev/null
         fi

           
         # The transfer has been done, the files are saved into $DLST
         mv ${DFTPLST}/${BASENAME}.ftp ${DLST}/${BASENAME}.ftp >/dev/null
         mv ${DFTPLST}/${BASENAME}.dat ${DLST}/${BASENAME}.dat >/dev/null
     else
       echo ${FTP_IP} >> ${FFTPERR}
       echo `date +"%Y/%m/%d %H:%M:%S"` "-- FTP_TEST failure for IP adress : ${FTP_IP}\nftp file : $i\n" >> ${DABORT}/${NCHAIN}.rst 
     fi
   done
sleep ${LOOP_DELAY}
done

