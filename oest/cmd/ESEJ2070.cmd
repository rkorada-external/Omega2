#!/bin/ksh
#=============================================================================
# nom de l'application          : 1.04 
#                                 Feeding Job
# nom du script SHELL           : ESEJ2070.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 08/10/2020
# auteur                        : KBagwe
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 88477  : Main LOB - Feeding the Field I17 Segment / Portfolio for the group process
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001]
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


# Launch applicative job ESEJ2071.cmd Feeding job
NJOB="ESEJ2071"
${DCMD}/ESEJ2071.cmd  2>&1 | ${TEE}


CHAINEND




















