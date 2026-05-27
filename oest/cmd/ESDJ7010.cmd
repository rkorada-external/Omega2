#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Chaine de preparation des fichiers DTSTATGTA 
#                                 et VTSTATGTA
# nom du script SHELL		: ESID7010.cmd
# revision			: $Revision:   1.11  $
# date de creation		: 26/03/2019
# auteur			: MIS
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   Preparing files DTSTATGTA et VSTATGTA
#   Launch applicative jobs ESCD9001 and ESID1011 
#-----------------------------------------------------------------------------
# historique des modifications
# [001]     MIS     26/03/2019  spira76548: Mise en place de la chaine
# [002]     MIS     16/04/2019  spira76548: Renommage de fichier pour ESDJ8040
# [003]		MIS		23/04/2019	spira76548: Ajout condition Yearly(temporairement) pour le renommage pour eviter que Quarterly ecrase les données ESDJ8040 fonctionnant pour le moment en Yearly
# [004]		MIS		23/04/2019	spira76548: Renommage fichiers mis en commentaires
# [005]		MiS		06/09/2019	spira81032: Suppression Anciens fichiers 
#===============================================================================


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_ARCSTATGTA
#	EST_GTA
#	EST_IADVPERICASE0
#	EST_IRDVPERICASE0
#	EST_STATGTA
# Output files
#	EST_DTSTATGTAA0
#	EST_TSTATGTAANO
#	EST_VTSTATGTA0
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

export IT=$2

# Chain Initialization variables
CHAININIT $0 $1

# Get the input parameters : 
# ${EST_PARAM} is a global environment varible 
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D} 

export EST_ARCSTATGTA="/dev/null"
export EST_ARCSTATGTA_ID="/dev/null"

touch ${EST_STATGTR}

# Launch applicative job ESID0061
NJOB="ESID0061${IT}"
${DCMD}/ESID0061.cmd ${CLODAT_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESID3023
NJOB="ESID3023${IT}"
${DCMD}/ESID3023.cmd ${CLODAT_D} ${CRE_D} 2>&1 | ${TEE} 

# Launch applicative job ESID3022
NJOB="ESID3022${IT}"
${DCMD}/ESID3022.cmd ${BALSHTYEA_NF} 2>&1 | ${TEE} 

# Launch applicative job ESID3024 -> 
NJOB="ESID3024${IT}"
${DCMD}/ESID3024.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}

# Launch applicative job ESID3025 -> SRGTC + VLIFEST
NJOB="ESID3025${IT}"
${DCMD}/ESID3025.cmd ${BALSHTYEA_NF} 2>&1 | ${TEE} 

NSTEP=${NCHAIN}_000
# [001]
# Suppression des fichiers present dans le répertoire DFILI plus ancien # que 14 jours (exclus)
#------------------------------------------------------------------------------
LIBEL="Erase intraday files older than 1 day"
EXECKSH_MODE=P
EXECKSH "find ${DFILI} -mtime +1 -name \"${NCHAIN}*.dat*\" -exec sh -c 'exec /bin/rm -vf \"\$@\" ' inline.cmd '{}' +"

#Renommage des fichier
#if [ "${IT}" = "Y" ]
#then 
#EST_CPLIFDRID=`echo ${EST_CPLIFDRI} | sed "s/${IT}_/_/"`
#cp -v $EST_CPLIFDRI $EST_CPLIFDRID

#EST_SRGTCD=`echo ${EST_SRGTC} | sed "s/${IT}_/_/"`
#cp -v $EST_SRGTC $EST_SRGTCD

#EST_VLIFEST195D=`echo ${EST_VLIFEST195} | sed "s/${IT}_/_/"`
#cp -v $EST_VLIFEST195 $EST_VLIFEST195D

#EST_FLIFEST0D=`echo ${EST_FLIFEST0} | sed "s/${IT}0_/0_/"`
#cp -v $EST_FLIFEST0 $EST_FLIFEST0D
#fi
CHAINEND
