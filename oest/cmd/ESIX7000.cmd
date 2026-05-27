#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Maintenance sur fichier ARCSTATGTR
# nom du script SHELL           : ESIX7000.cmd
# revision                      : $Revision: 1$
# date de creation              : 01/10/2010
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   :spot:20133 - Modification du fichier ARCSTATGTR, recreation a partir du CURGTR archivé.
#
# job launched by ESIX7000.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#
#  <jj/mm/AAAA>  Programer Name  Description de la modification
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESIX7001
NJOB="ESIX7001"
${DCMD}/ESIX7001.cmd  2>&1 | ${TEE}

#SPLIT ARCSTATGTA
NJOB="ESFJ0011"
${DCMD}/ESFJ0011.cmd $DFILP/${ENV_PREFIX}_ESIX7000_ARCSTATGTA.dat 4 2>&1 | ${TEE}

CHAINEND
