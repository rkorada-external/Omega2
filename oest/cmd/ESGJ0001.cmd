#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Gestion des ecritures de services Life IFRS17
#				  Batch quotidien
# nom du script SHELL		: ESGD0001.cmd
# revision
# revision                      : $Revision:   1.2  $
# date de creation              : 05/05/2025
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   SPIRA 111672  Evolution SERQ : Merge  files
#-----------------------------------------------------------------------------
# historiques des modifications :
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters

# Job Initialisation
JOBINIT



export DPRM_AS=`echo  ${DPRM} | sed -e s/ub../ubas/`
export DPRM_EU=`echo  ${DPRM} | sed -e s/ub../ubeu/`
export DPRM_AM=`echo  ${DPRM} | sed -e s/ub../ubam/`


NSTEP=${NJOB}_10
#---------------------------------------------------------------------------------------------
LIBEL="copy  ${DPRM_AS}//ESCJ0000.prm ${DPRM_AM}"   
EXECKSH "cp ${DPRM_AS}//ESCJ0000.prm ${DPRM_AM}"

NSTEP=${NJOB}_20
#---------------------------------------------------------------------------------------------
LIBEL="copy ${DPRM_AS}//ESCJ0000.prm ${DPRM_EU}"   
EXECKSH "cp ${DPRM_AS}//ESCJ0000.prm ${DPRM_EU}"
