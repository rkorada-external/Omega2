#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESGETDT1.cmd
# revision                      : 
# date de creation              : 13/07/2018
# auteur                        : ASCOTT(M.NAJI)
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Preparing parametrs files and planning executions
#
# job launched by ESCJ0000.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Creation	    : [007]
#Auteur         : M.NAJI
#Date           : 18/07/2018
#Version        : 1.0
#Description    : Copie les fichier permanents avec la nouvelle nomenclature
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
CRE_D=$1

NSTEP=${NJOB}_05
#---------------------------------------------------------------
LIBEL="Create script shell commands to copy files IFRS4 with new names "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_GET_DATA.sh
BCP_QRY="select 'echo ' +  p0.fileVariable +  ':; cp '+ p0.pattern + ' ' + p1.pattern
                from BEST..TIfrs17Perm p0
                join BEST..TIfrs17Perm p1  on p1.version = 1 and p0.fileVariable = p1.fileVariable and p0.ContextId = p1.ContextId
                join BEST..TIfrs17ContextRequest cr  on cr.requestId = '${param_Request_id}' and cr.ContextId = p0.ContextId
                where  p0.version = 0  and p0.pattern not like '%empty%'
		and p0.chain != 'not used'
" 
BCP

NSTEP=${NJOB}_10
#---------------------------------------------------------------
LIBEL="execute previous script "
EXECKSH "chmod +x ${DFILT}/${NJOB}_05_${IB}_GET_DATA.sh"
EXECKSH "${DFILT}/${NJOB}_05_${IB}_GET_DATA.sh"

# End of Job
JOBEND
