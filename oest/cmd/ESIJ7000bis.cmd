#!/bin/ksh
#=============================================================================
# Application name          : ESTIMATION
# source file               : ESIJ7000bis.cmd
# revision                  : 10.2
# creation date             : 09/12/2010
# author                    : D.GATIBELZA
# description : Integration des mouvements compta dans le GT
#               ESTDOM20828: mouvements comptables non venus dans GLT  sur exercices ou numero ordre  FACULTATIVE  supprimé
#-----------------------------------------------------------------------------
# Update history :
#   <dd/mm/yyyy>   <author>    <update description>
#=============================================================================

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FACCTRTGT
#	EST_FDRYTRN
#	EST_FRTOSTA
# Output files
#	EST_FDRYTRN
#	EST_GTA
#	EST_GTR
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT "ESIJ7000" $1

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd

# Launch applicative job ESIJ7003
NJOB="ESIJ7003bis"
${DCMD}/ESIJ7003bis.cmd 2>&1 | ${TEE}

# Launch applicative job ESIJ7005
NJOB="ESIJ7005bis"
${DCMD}/ESIJ7005bis.cmd 2>&1 | ${TEE}

CHAINEND
