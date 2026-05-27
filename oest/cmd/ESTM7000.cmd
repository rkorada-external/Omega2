#!/bin/ksh
#=============================================================================
# nom de l'application: ESTIMATIONS
#Rejets / Reconduction ( Ouverture 98 )
# nom du script SHELL: ESTM7000.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 07/04/98
# auteur                        : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Chain of retrocession reversal and carried forward entries generation
#-----------------------------------------------------------------------------
# historique des modifications
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#    07/01/2004     Roger Cassis    Ajout parametre ESTIM_B pour traiter les postes estimations
#    20/02/2006     M.DJELLOULI  Flag Forcé Bilan à à 31/12/N-1 (1=Oui par Défaut / 0= Bilan N préservé)
#    24/02/2006     M.DJELLOULI  Intégration JOB ESTM7002.cmd
#    27/02/2006     M.DJELLOULI  On utilise le JOB ESTM7002.cmd à la place du ESTM7001.cmd
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

#Entry parameters
set `GETPRM ${DPRM}/ESTM7000.prm`
BLCSHT_D=${1}
BALSHEY_NF=${2}
ESTIM_B=${3}
FORCEBILAN=${4}

# Launch applicative job ESTM7002
NJOB="ESTM7002"
${DCMD}/ESTM7002.cmd  ${BLCSHT_D} ${BALSHEY_NF} ${ESTIM_B} ${FORCEBILAN} 2>&1 | ${TEE}

# Launch applicative job ESTM7003
NJOB="ESTM7003"
${DCMD}/ESTM7003.cmd  ${BLCSHT_D} ${BALSHEY_NF} ${ESTIM_B} ${FORCEBILAN} 2>&1 | ${TEE}

CHAINEND

