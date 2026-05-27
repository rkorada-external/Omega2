#!/bin/ksh
#=============================================================================
# nom de l'application          : SET Closing plans and parameters
# nom du script SHELL           : ESFJ0010.cmd
# revision                      : $Revision: 1.3 $
# date de creation              : 28/02/2019
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  Preparing parametrs files and planning executions
# parameters: 4
#    1 - CRE_D        -> overides DATE_T of ESCJ0000.prm to generate plan-parms.
#
#    ex : ESCJ0000.cmd = 
#        
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] 30/03/2020 M.NAJI  :SPIRA  85707 ajout d'un 2ème paramètre pour gérer le mode transition
#[02] 08/04/2021 M.NAJI : SPIRA 91531  la valeur de la variable  TI17PERMFIL et maintenat lu dans ESFJ0000.prm 
#---------------
#MODIFICATION   : 
#Auteur         : M.NAJI
#Date           : 28/02/2019
#Version        : 1.0
#Description    : SET Closing plans and parameters
##################===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

#[01]
#export TI17PERMFIL="TI17PERMFIL"
#if [ "$2" != "" ]
#then
#	export TI17PERMFIL="TI17TRAPERMFIL"
#fi
#[01] end

#Get input parameters of ESCJ0000.prm
set `GETPRM ${DPRM}/ESCJ0000.prm` 
CRE_D=$1

#[02]
#Get input parameters ESFJ0000.prm
set `GETPRM ${DPRM}/ESFJ0000.prm` 
export TI17PERMFIL=$1

#Launch applicative job ESCJ0001
NJOB="ESFJ0001"
${DCMD}/ESFJ0001.cmd ${CRE_D} 2>&1 | ${TEE}

CHAINEND

