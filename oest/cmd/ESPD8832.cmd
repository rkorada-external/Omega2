#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - ecritures post omega
# nom du script SHELL		: ESPD8832.cmd
# revision			: $Revision:   1.3  $
# date de creation		: 22/06/2005
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# Description : Filling of the tables
#
# Job launched by ESPD8830.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001] 22/12/2020 : M.NAJI   :. SPIRA 91531 - Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[002] 15/09/2023 : DAD      : SPIRA 110067 - stop loading table if relaunch
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT


FILE_INFO_STEPRUN=${DFILP}/${NCHAIN}_INFO_STEPRUN_${NORME_CF}.dat

NSTEP=${NJOB}_00
LIBEL="TOUCH FILES NOT FOUND"
if [ ! -f ${FILE_INFO_STEPRUN} ]
then
    ECHO_LOG "#===> FILE_INFO_STEPRUN=${FILE_INFO_STEPRUN}  does not exist, take an empty file"
    EXECKSH "touch ${FILE_INFO_STEPRUN}"
    echo "ESPD8830_ESPD8832_05_RUN=" >> ${FILE_INFO_STEPRUN}
    echo "ESPD8830_ESPD8832_10_RUN=" >> ${FILE_INFO_STEPRUN}
    echo "ESPD8830_ESPD8832_15_RUN=" >> ${FILE_INFO_STEPRUN}
fi

ESPD8832_RUN_D=`awk -F'=' '{ if ( $1 == "ESPD8830_ESPD8832_05_RUN" ) { print $2 } }' ${FILE_INFO_STEPRUN}`
ECHO_LOG "#===> ESPD8830_ESPD8832_05_RUN=${ESPD8832_RUN_D}"
if [ "${ESPD8832_RUN_D}" != "${CRE_D}"  ]
then
    NSTEP=${NJOB}_05
    #Filling File to the Retrocession by Acceptance and Retrocessionaire
    #Accounting Transaction Table if it is an Internal Retrocessionaire in order
    #to give TACCTRTGT
    #-----------------------------------------------------------------------------
    LIBEL="Filling TACCTRTGT table"
    BCP_WAY="IN"; BCP_VER=""
    BCP_I=${DFILT}/${NCHAIN}_ESPD8831_71_${IB}_SORT_GTARR_O.dat
    BCP_TABLE=BEST..TACCTRTGT
    BCP

    NSTEP=${NJOB}_06
    #Deletion of temporary file
    #----------------------------------------------------------------------------
    LIBEL="Deletion of temporary file"
    RMFIL ${DFILT}/${NCHAIN}_ESPD8831_71_${IB}_SORT_GTARR_O.dat

    ECHO_LOG "#===> Save Run ESPD8830_ESPD8832_05_RUN=${CRE_D}"
    sed -i "s/^ESPD8830_ESPD8832_05_RUN=${ESPD8832_RUN_D}/ESPD8830_ESPD8832_05_RUN=${CRE_D}/" ${FILE_INFO_STEPRUN}
fi


ESPD8832_RUN_D=`awk -F'=' '{ if ( $1 == "ESPD8830_ESPD8832_10_RUN" ) { print $2 } }' ${FILE_INFO_STEPRUN}`
ECHO_LOG "#===> ESPD8830_ESPD8832_10_RUN=${ESPD8832_RUN_D}"
if [ "${ESPD8832_RUN_D}" != "${CRE_D}"  ]
then
    NSTEP=${NJOB}_10
    #Filling File in Acceptance Accounting Transaction table format in order
    #to give TACCTRNE
    #-----------------------------------------------------------------------------
    LIBEL="Filling TACCTRNE table"
    BCP_WAY="IN"; BCP_VER=""
    BCP_I=${DFILT}/${NCHAIN}_ESPD8831_90_${IB}_ESTC8933_ACCTRNE_O.dat
    BCP_TABLE=BEST..TACCTRNE
    BCP

    NSTEP=${NJOB}_11
    #Deletion of temporary file
    #----------------------------------------------------------------------------
    #LIBEL="Deletion of temporary file"
    RMFIL ${DFILT}/${NCHAIN}_ESPD8831_90_${IB}_ESTC8933_ACCTRNE_O.dat

    ECHO_LOG "#===> Save Run ESPD8830_ESPD8832_10_RUN=${CRE_D}"
    sed -i "s/^ESPD8830_ESPD8832_10_RUN=${ESPD8832_RUN_D}/ESPD8830_ESPD8832_10_RUN=${CRE_D}/" ${FILE_INFO_STEPRUN}
fi

ESPD8832_RUN_D=`awk -F'=' '{ if ( $1 == "ESPD8830_ESPD8832_15_RUN" ) { print $2 } }' ${FILE_INFO_STEPRUN}`
ECHO_LOG "#===> ESPD8830_ESPD8832_15_RUN=${ESPD8832_RUN_D}"
if [ "${ESPD8832_RUN_D}" != "${CRE_D}"  ]
then
    NSTEP=${NJOB}_15
    #Filling File in Statistics by retrocessionaire table format in order to give
    #TRTOSTAE
    #-----------------------------------------------------------------------------
    LIBEL="Filling TRTOSTAE table"
    BCP_WAY="IN"; BCP_VER=""
    BCP_I=${DFILT}/${NCHAIN}_ESPD8831_116_${IB}_SORT_GTRR_O.dat
    BCP_TABLE=BEST..TRTOSTAE
    BCP

    ECHO_LOG "#===> Save Run ESPD8830_ESPD8832_15_RUN=${CRE_D}"
    sed -i "s/^ESPD8830_ESPD8832_15_RUN=${ESPD8832_RUN_D}/ESPD8830_ESPD8832_15_RUN=${CRE_D}/" ${FILE_INFO_STEPRUN}
fi

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_20
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat"

JOBEND
