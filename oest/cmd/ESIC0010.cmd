#!/bin/ksh
#==========================================================================
#nom de l'application          : Job chargement table TLIFSTAREP
#nom du source                 : ESIC0010.cmd
#revision                      : $Revision:   1.7  $
#date de creation              : 02/12/1997
#auteur                        : C.G.I. ()
#references des specifications :
#--------------------------------------------------------------------------
#description :
# Cette chaine EXTRAIT TLIFPRNO et CHARGE TLISFSTAREP
#
# Arguments d'entree du job :
#    CLODAT_D     trimestre a extraire
#    CLODAT1_D    31/12     a extraire
#
#--------------------------------------------------------------------------
#historique des modifications :
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#
#--------------------------------------------------------------------------

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
set `GETPRM ${DPRM}/ESIC0010.prm`
CLODAT00_D=${1}
CLODAT01_D=${2}
CLODAT02_D=${3}
CLODAT03_D=${4}
CLODAT04_D=${5}
CLODAT05_D=${6}
CLODAT06_D=${7}
CLODAT07_D=${8}
CLODAT08_D=${9}
CLODAT09_D=${10}
CLODAT10_D=${11}
CLODAT11_D=${12}
CLODAT12_D=${13}
CLODAT13_D=${14}


# Launch applicative job ESIC0011 (TLIFSTAREP) 20021231 20021231
NJOB="ESIC0011"
  ${DCMD}/ESIC0011.cmd ${CLODAT00_D} ${CLODAT01_D} 2>&1 | ${TEE}

# Launch applicative job ESIC0011 (TLIFSTAREP) 20031231 20031231
NJOB="ESIC0011"
  ${DCMD}/ESIC0011.cmd ${CLODAT02_D} ${CLODAT03_D} 2>&1 | ${TEE}

# Launch applicative job ESIC0011 (TLIFSTAREP) 20040331 20041229
NJOB="ESIC0011"
  ${DCMD}/ESIC0011.cmd ${CLODAT04_D} ${CLODAT05_D} 2>&1 | ${TEE}

# Launch applicative job ESIC0011 (TLIFSTAREP) 20040630 20041228
NJOB="ESIC0011"
  ${DCMD}/ESIC0011.cmd ${CLODAT06_D} ${CLODAT07_D} 2>&1 | ${TEE}

# Launch applicative job ESIC0011 (TLIFSTAREP) 20040930 20041227
NJOB="ESIC0011"
  ${DCMD}/ESIC0011.cmd ${CLODAT08_D} ${CLODAT09_D} 2>&1 | ${TEE}

# Launch applicative job ESIC0011 (TLIFSTAREP) 20041231 20041231
NJOB="ESIC0011"
  ${DCMD}/ESIC0011.cmd ${CLODAT10_D} ${CLODAT11_D} 2>&1 | ${TEE}

# Launch applicative job ESIC0011 (TLIFSTAREP) 20050331 20051231
NJOB="ESIC0011"
  ${DCMD}/ESIC0011.cmd ${CLODAT12_D} ${CLODAT13_D} 2>&1 | ${TEE}

# Launch applicative job ESIC0011B (BCP IN)
NJOB="ESIC0011B"
  ${DCMD}/ESIC0011B.cmd 2>&1 | ${TEE}


CHAINEND
