#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - EBS / I17 Demand Booking or Posting
# nom du script SHELL           : ESFD7001.cmd
# revision                      : $Revision: 1.0 $
# date de creation              : 01/02/2021
# auteur                        : R. Cassis
# references des specifications : :spira:91379
#-----------------------------------------------------------------------------
# description
#   I17-EBS Quaterly booking : Save booked data from ESF_FTECLEDx_POSTING to ESF_FTECLEDx_CUR
#
# job launched by ESFD7000.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 06/06/2022  MZGM    :spira:91532 Ajout Test avant Control
#[001] 15/12/2021 R.CASSIS :spira:100487-101117 divers ajustements pour EBS-I17
#[002] 24/07/2023 DAD :spira:110198 copy empty file for I17S FTECLEDA FTECLEDR OPNG only I17G
#[003] 13/11/2023 DAD : spira 108167 : Modifier l’archivage des fichier REJ / OPNG
#===================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters

# Job Initialisation
JOBINIT


ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME_CF.....................................: ${NORME_CF}"
ECHO_LOG "#===> PARM_BATCHUSER...............................: ${PARM_BATCHUSER}"
ECHO_LOG "#===> IDF_CT.......................................: ${IDF_CT}"
ECHO_LOG "#===> VNORME.......................................: ${VNORME}"
ECHO_LOG "#===> PARM_ICLODAT_D...............................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> ............ INPUT .........................."
ECHO_LOG "#===> ESF_FTECLEDA_POSTING.........................: ${ESF_FTECLEDA_POSTING}"
ECHO_LOG "#===> ESF_FTECLEDR_POSTING.........................: ${ESF_FTECLEDR_POSTING}"
ECHO_LOG "#===> ESF_FTECLEDA_RMN.............................: ${ESF_FTECLEDA_RMN}"
ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> ESF_FTECLEDA_CUR.............................: ${ESF_FTECLEDA_CUR}"
ECHO_LOG "#===> ESF_FTECLEDR_CUR.............................: ${ESF_FTECLEDR_CUR}"
ECHO_LOG "#========================================================================="

if [ ! -f ${ESF_FTECLEDA_CUR} ]
then
	touch ${ESF_FTECLEDA_CUR} ${ESF_FTECLEDR_CUR}
fi

if [ -f ${DSAV}/${ENV_PREFIX}_ESFD7000_FTECLEDA_CUR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz ]
then
	gunzip -c ${DSAV}/${ENV_PREFIX}_ESFD7000_FTECLEDA_CUR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz > ${ESF_FTECLEDA_CUR}
	gunzip -c ${DSAV}/${ENV_PREFIX}_ESFD7000_FTECLEDR_CUR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz > ${ESF_FTECLEDR_CUR}

	ECHO_LOG "#############################################################"
	ECHO_LOG "###### ${ESF_FTECLEDA_CUR} restored because relaunched ######"
	ECHO_LOG "#############################################################"
fi

gzip -c ${ESF_FTECLEDA_CUR} > ${DSAV}/${ENV_PREFIX}_ESFD7000_FTECLEDA_CUR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz
gzip -c ${ESF_FTECLEDR_CUR} > ${DSAV}/${ENV_PREFIX}_ESFD7000_FTECLEDR_CUR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz

ECHO_LOG "#############################################################"
ECHO_LOG "###### ${ESF_FTECLEDA_CUR} saved if relaunch ################"
ECHO_LOG "#############################################################"

#[003]
if [ -s $ESF_FTECLEDA_OPNG ]
then

	NSTEP=${NJOB}_05
	LIBEL="Archiving quaterly opening files ESF_FTECLEDA_OPNG"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${ESF_FTECLEDA_OPNG} > ${ESF_FTECLEDA_OPNG_ARC}"
fi

#[003]
if [ -s $ESF_FTECLEDR_OPNG ]
then

	NSTEP=${NJOB}_06
	LIBEL="Archiving quaterly opening files ESF_FTECLEDR_OPNG"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${ESF_FTECLEDR_OPNG} > ${ESF_FTECLEDR_OPNG_ARC}"
fi

NSTEP=${NJOB}_10
#----------------------------------------------------------------------------
# APPEND into ESF_FTECLEDA_CUR
#----------------------------------------------------------------------------
LIBEL="APPEND into ESF_FTECLEDA_CUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_POSTING} 1000 1"
if [ "${NORME_CF}" = "EBS" ]
then
	SORT_I2="${ESF_FTECLEDA_RMN} 1000 1"	
fi
SORT_O="${ESF_FTECLEDA_CUR} APPEND"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_20
#----------------------------------------------------------------------------
# APPEND into ESF_FTECLEDR_CUR
#----------------------------------------------------------------------------
LIBEL="APPEND into ESF_FTECLEDR_CUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR_POSTING} 800 1"
SORT_O="${ESF_FTECLEDR_CUR} APPEND"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree ${ESF_FTECLEDA_CUR}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${ESF_FTECLEDA_CUR} > ${ESF_FTECLEDA_CUR_ARC}"

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree ${ESF_FTECLEDR_CUR}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${ESF_FTECLEDR_CUR} > ${ESF_FTECLEDR_CUR_ARC}"

NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
# Empty ESF_FTECLEDA_OPNG files
#------------------------------------------------------------------------------
LIBEL="Empty ESF_FTECLEDA_OPNG opening files"
EXECKSH_MODE=P
EXECKSH "cp ${DFILP}/empty.dat ${ESF_FTECLEDA_OPNG}"

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
# Empty ESF_FTECLEDA_OPNG files
#------------------------------------------------------------------------------
LIBEL="Empty ESF_FTECLEDR_OPNG opening files"
EXECKSH_MODE=P
EXECKSH "cp ${DFILP}/empty.dat ${ESF_FTECLEDR_OPNG}"

#[002]
if [ "${NORME_CF}" = "I17G" ]
then

NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
# Empty I17S_ESF_FTECLEDR_OPNG file
#------------------------------------------------------------------------------
LIBEL="copy ESF_FTECLEDR_OPNG files"
EXECKSH_MODE=P
EXECKSH "cp ${DFILP}/empty.dat ${I17S_ESF_FTECLEDR_OPNG}"

NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
# Empty I17S_ESF_FTECLEDA_OPNG file
#------------------------------------------------------------------------------
LIBEL="copy ESF_FTECLEDA_OPNG files"
EXECKSH_MODE=P
EXECKSH "cp ${DFILP}/empty.dat ${I17S_ESF_FTECLEDA_OPNG}"

fi

JOBEND
