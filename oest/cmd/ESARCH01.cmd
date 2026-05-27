#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESARCH01.cmd
# revision                      : 
# date de creation              : 06/09/2021
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Extraction quatidienne des  fichiers
#
# job launched by ESARCH00.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Creation	    : 
#Auteur         : M.NAJI
#Date           : 20/04/2022
#Version        : 1.0
#Description    : Archivage des fichier permanant 
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
#all PATHPATTRN_LL 
#-----------------------------------------------------------------------------
LIBEL=" all PATHPATTRN_LL ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_ALL_ESTIMATE_FILES_VAR.dat
BCP_QRY='
	select   distinct substring(str_replace(PATHPATTRN_LL ,\"\${PARM_FTECLED}\",\"*\"), 1,31) + \"*.dat\"
	from BEST..TI17PERMFIL 
	where  PATHPATTRN_LL  like  \"\${DFILP}/\${ENV_PREFIX}_ES%\"
'
BCP

NSTEP=${NJOB}_15
#files  to keep   
#-----------------------------------------------------------------------------
LIBEL="to keep ..."
for f in `grep RULES_00_  $DFILT/${NCHAIN}_${IDF_CT}_${IB}_PERM.dat | cut -d= -f2`
do
        ls `eval echo $f` >> ${DFILT}/${NSTEP}_${IB}_FILE_RULES_00.dat
done

for f in `cat ${DFILT}/${NJOB}_05_${IB}_ALL_ESTIMATE_FILES_VAR.dat`
do
        ls `eval echo $f` >> ${DFILT}/${NSTEP}_${IB}_ALL_ESTIMATE_FILES.dat
done



NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ALL_ESTIMATE_FILES.dat 1000 1"
SORT_O="${EST_FILE_TO_REMOVE} 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS file           1:1 -  1:
/joinkeys
      file
/INFILE ${DFILT}/${NJOB}_15_${IB}_FILE_RULES_00.dat 1000 1 "~"
/joinkeys
      file
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT
   leftside:file
exit
EOF
SORT

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ALL_ESTIMATE_FILES.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_UNPAIRED.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS file           1:1 -  1:
/joinkeys
      file
/INFILE ${DFILT}/${NJOB}_15_${IB}_FILE_RULES_00.dat 1000 1 "~"
/joinkeys
      file
/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT
   rightside:file
exit
EOF
SORT

NSTEP=${NJOB}_30
#files  archive  PREV
#-----------------------------------------------------------------------------
LIBEL="files archive	PREV..."
for f in `cat ${EST_FILE_TO_REMOVE}`
do
	BASE_NAME=`basename ${f}`
	echo mv ${DFILP}/${BASE_NAME} ${DARCH}/${BASE_NAME}
	#mv $f ${DARCH}
done
echo gzip ${DSAVE}/${PARM_ICLODAT_D}*

NSTEP=${NJOB}_35
#files  archive  PREV
#-----------------------------------------------------------------------------
LIBEL="Deletion  Files"
for f in `grep RULES_01_  $DFILT/${NCHAIN}_${IDF_CT}_${IB}_PERM.dat | cut -d= -f2`
do
	#RMFIL `eval echo $f`
	echo RMFIL `eval echo $f`
done

# End of Job
JOBEND


