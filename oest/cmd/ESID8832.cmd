#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - Tests Lot 33
# nom du script SHELL		: ESID8832.cmd
# revision			: $Revision:   1.3  $
# date de creation		: 12/08/1997
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# Description : Filling of the tables
#
# Job launched by ESID8830.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications : 
# [001] : 26/05/2021  B.LAGHA    96612 - Block insertion in BEST..TRTOSTAE
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

NSTEP=${NJOB}_05
#Filling File to the Retrocession by Acceptance and Retrocessionaire 
#Accounting Transaction Table if it is an Internal Retrocessionaire in order 
#to give TACCTRTGT
#-----------------------------------------------------------------------------
LIBEL="Filling TACCTRTGT table"
BCP_WAY="IN"; BCP_VER=""
BCP_I=${DFILT}/${NCHAIN}_ESID8831_71_${IB}_SORT_GTARR_O.dat
BCP_TABLE=BEST..TACCTRTGT
BCP               

NSTEP=${NJOB}_06
#Deletion of temporary file
#----------------------------------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NCHAIN}_ESID8831_71_${IB}_SORT_GTARR_O.dat

NSTEP=${NJOB}_10
#Filling File in Acceptance Accounting Transaction table format in order
#to give TACCTRNE
#-----------------------------------------------------------------------------
LIBEL="Filling TACCTRNE table"
BCP_WAY="IN"; BCP_VER=""
BCP_I=${DFILT}/${NCHAIN}_ESID8831_90_${IB}_ESTC8933_ACCTRNE_O.dat
BCP_TABLE=BEST..TACCTRNE
BCP               

NSTEP=${NJOB}_11
#Deletion of temporary file
#----------------------------------------------------------------------------
#LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NCHAIN}_ESID8831_90_${IB}_ESTC8933_ACCTRNE_O.dat

# [001]
#NSTEP=${NJOB}_15
##Filling File in Statistics by retrocessionaire table format in order to give 
##TRTOSTAE
##-----------------------------------------------------------------------------
#LIBEL="Filling TRTOSTAE table"
#BCP_WAY="IN"; BCP_VER=""
#BCP_I=${DFILT}/${NCHAIN}_ESID8831_116_${IB}_SORT_GTRR_O.dat
#BCP_TABLE=BEST..TRTOSTAE
#BCP               


########################
# Erase temporary files #
########################

NSTEP=${NJOB}_20
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat" 

JOBEND
