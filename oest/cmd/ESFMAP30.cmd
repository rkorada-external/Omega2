#!/bin/ksh
#=============================================================================
# nom de l'application          : SET Closing plans and parameters
# nom du script SHELL           : ESFJ0010.cmd
# revision                      : $Revision: 1.3 $
# date de creation              : 27/01/2021
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  Fxtraction only of the file mapping 
# parameters: 
#
#    ex : ESFMAP00.cmd = 
#        
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] 30/03/2020 M.NAJI  :SPIRA  85707 ajout d'un 2ème paramètre pour gérer le mode transition
#---------------
#MODIFICATION   : 
#Auteur         : M.NAJI
#Date           : 27/01/2021
#Version        : 1.0
#Description    : Fxtraction only of the file mapping 
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
#---------------------------------------------------------------
LIBEL="Extract conditions file  "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NCHAIN}_ESFMAP30_CMD.dat
BCP_QRY="
	select * from TEMPDB..ESFMAP30_CMD
	delete TEMPDB..ESFMAP30_CMD
	"
BCP

. ${DFILT}/${NCHAIN}_ESFMAP30_CMD.dat



JOBEND

CHAINEND

