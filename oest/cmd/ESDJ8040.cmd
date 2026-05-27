#!/bin/ksh
#=============================================================================
# nom de l'application    : ESTIMATIONS - INVENTAIRE
#                                 Inventaire vie
# nom du script SHELL   : ESID2040.cmd
# revision      : $Revision:   1.5  $
# date de creation    : 27/10/97
# auteur      : C.G.I.
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Life
#
# Launch applicative jobs ESCD9001,ESDJ8041,ESID2042,ESID2043
#-----------------------------------------------------------------------------
# historique des modifications
#
#   21/08/2003     J. Ribot   ajout 5è parametre appel ESDJ8041 pour gestion CNA
#   15/10/2003     J. Ribot   ${ICLODAT_MTH} a la place de BALSHTMTH_NF lancement 1er ESDJ8041
#[003] 05/03/2014  R. Cassis  :spot:25427 Changement noms NJOBS pour possibilité de Restart
# [004] 28/02/2017  DFI        spira58664: nettoyage fichiers intraday
# [005] 13/05/2019  MIS        spira76548: Ajout parametre IT
#===============================================================================
#set -x

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
# EST_CPLIFDRI
# EST_CRIBLEANO
# EST_DLVGTAR
# EST_FACMTRSH
# EST_FBANTECL
# EST_FCPLACC
# EST_FCURQUOT
# EST_FGRP
# EST_FSUBSID
# EST_FVPLACEMT
# EST_IAVPERICASE
# EST_IRVPERICASE
# EST_SEGRATANO
# EST_SIGNANO
# EST_SRGTC
# EST_SRGTE
# EST_SRGTEF
# EST_VLIFEST195
# Output files
# EST_DLVGTAA
# EST_DLVGTAR
# EST_DLVGTR
# EST_SIGNANO
# EST_SRGTE
# EST_SRGTEF
#-=-=-=-=-=-=-=-=-=-=-=


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

ECHO_LOG "#"
if [[ $# -eq 3  ]]; then
  MODE_NT=0
  VAC_NT=$2
  ECHO_LOG "# Valeur de Vac_NT => ${VAC_NT}"
  export IT=$3
  ECHO_LOG "# Valeur de IT => ${IT}"
else
  MODE_NT=0
  VAC_NT=0
fi
ECHO_LOG "# Valeur de MODE_NT => ${MODE_NT}"
ECHO_LOG "#"

# Get the parameters
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
ICLODAT_D=${102}
CLODAT_D=$6
# ICLODAT_D=$7
# CLODAT_D=$8
DATE=`date +"%Y%m%d %H:%M:%S"`

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

echo "EST_TRACEFILE = ${EST_TRACEFILE}"
echo "EST_CMPCALC = ${EST_CMPCALC}"
echo "EST_SIGNANO = ${EST_SIGNANO}"
echo "EST_SUBTRSESBPROP = ${EST_SUBTRSESBPROP}"
echo "EST_FTRSLNK = ${EST_FTRSLNK}"
echo "EST_CPLIFDRI = ${EST_CPLIFDRI}"
echo "EST_SRGTC = ${EST_SRGTC}"
echo "EST_SUBTRS = ${EST_SUBTRS}"
echo "EST_FACCPAR0 = ${EST_FACCPAR0}"
echo "EST_IARVPERICASE0 = ${EST_IARVPERICASE0}"
echo "EST_SUBTRSASSO = ${EST_SUBTRSASSO}"
echo "EST_SRGTE = ${EST_SRGTE}"
echo "EST_VLIFEST195 = ${EST_VLIFEST195}"
echo "EST_FLIFEST0 = ${EST_FLIFEST0}"
echo "EST_TCALL = ${EST_TCALL}"
echo "EST_TGAPTHR = ${EST_TGAPTHR}"
echo "EST_FCURQUOT = ${EST_FCURQUOT}"

# Launch applicative job ESID2041
NJOB="ESID2041${IT}"
${DCMD}/ESID2041.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${ICLODAT_D} ${CRE_D} ${ICLODAT_MTH} PC 2>&1 | ${TEE}

# Launch applicative job ESDJ8041
NJOB="ESDJ8041"
${DCMD}/ESDJ8041.cmd ${MODE_NT} ${CLODAT_D} "${DATE}" ${VAC_NT} 2>&1 | ${TEE}

NSTEP=${NCHAIN}_000
# [004]
# Suppression des fichiers present dans le répertoire DFILI plus ancien # que 14 jours (exclus)
#------------------------------------------------------------------------------
LIBEL="Erase intraday files older than 1 day"
EXECKSH_MODE=P
EXECKSH "find ${DFILI} -mtime +1 -name \"${NCHAIN}*.dat*\" -exec sh -c 'exec /bin/rm -vf \"\$@\" ' inline.cmd '{}' +"

CHAINEND
