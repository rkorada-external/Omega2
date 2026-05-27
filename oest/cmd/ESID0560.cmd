#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Chaine de filtre des fichiers
# nom du script SHELL           : ESID0560.cmd
# revision                      : $Revision:   1.7  $
# date de creation              : 06/10/1997
# auteur                        : CGI (M.NAJI)
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Filtering files
#
#   Launch applicative jobs ESID0561,562,563,564
#-----------------------------------------------------------------------------
# historiques des modifications
# JR 05/02/2004   pour creer le FACCSUP 31/12 systematiquement.
# JR 06/02/2004   deplacement appel ESID0564 (avant ESID0563 31/12)
# JR 09/02/2004   ajout appel ESID0568 (pour creer les fichiers au 12/31/xxxx)
#[004] 03/05/2012 Roger Cassis  :spot:23699 - ESID0561 passe systématiquement si variante != 7 et le mois ICLODAT_MTH est affecté
#[005] 31/10/2019 M.NAJI        :spot:81838 - DÃ©placement du job ESID2501 de ESID2500 vesr ici pour la crÃ©ation de EST_FLPC et EST_FCES
#===============================================================================
#set -x
#
#
#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_DLAGTAA0
#	EST_DLAGTAR0
#	EST_DLAGTR0
#	EST_DTSTATGTAA0
#	EST_FACCSUP0
#	EST_FACCSUP12
#	EST_FACCTRAA0
#	EST_FAMPROT0
#	EST_FAPR0
#	EST_FCESSION0
#	EST_FCMUSPLI0
#	EST_FCMUSPLIT0
#	EST_FCPLACC0
#	EST_FCTREST0
#	EST_FCTRGRO0
#	EST_FCTRULT0
#	EST_FLABOCY0
#	EST_FOUTTRAA0
#	EST_FOUTTRAI0
#	EST_FPLACEMT0
#	EST_FSEGEST0
#	EST_FSNEMHIST0
#	EST_GTEP
#	EST_IADPERICASE0
#	EST_IADPERIFCI0
#	EST_IADPERIFCT0
#	EST_IADPERIFR0
#	EST_IADPERIPRMD0
#	EST_IADVPERICASE0
#	EST_IAVPERICASE0
#	EST_IGTAA0
#	EST_IGTAR0
#	EST_IGTR0
#	EST_IRDVPERICASE0
#	EST_IRVPERICASE0
#	EST_MVTPNA0
# Output files
#	EST_DLAGTAA
#	EST_DLAGTAR
#	EST_DLAGTR
#	EST_DLRIGTAA
#	EST_DTSTATGTAA
#	EST_FACCSUP
#	EST_FACCSUPF
#	EST_FACCTRAA
#	EST_FAMPROT
#	EST_FAPR
#	EST_FCESSION
#	EST_FCMUSPLI
#	EST_FCMUSPLIT
#	EST_FCPLACC
#	EST_FCTREST
#	EST_FCTRGRO
#	EST_FCTRULT
#	EST_FLABOCY
#	EST_FOUTTRAA
#	EST_FOUTTRAI
#	EST_FPLACEMT
#	EST_FSEGEST
#	EST_FSNEMHIST
#	EST_IADPERICASE
#	EST_IADPERIFCI
#	EST_IADPERIFCT
#	EST_IADPERIFR
#	EST_IADPERIPRMD
#	EST_IADVPERICASE
#	EST_IAVPERICASE
#	EST_IGTAA
#	EST_IGTAR
#	EST_IGTR
#	EST_IRDVPERICASE
#	EST_IRVPERICASE
#	EST_MVTPNA
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the input parameters :
# ${EST_PARAM} is a global environment variable
set `GETPRM ${EST_PARAM}`
SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8

#[004]
ICLODAT_MTH=`echo "${ICLODAT_D}" | awk '{ print substr($0,5,2) }'`





NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

if [ "${EST_VARIANTE}" = "7"   ]
then

	# Launch applicative job ESID0567
	NJOB="ESID0567"
	${DCMD}/ESID0567.cmd   ${ICLODAT_D} 2>&1 | ${TEE}
	
	# Launch applicative job ESID0563
	NJOB="ESID0563"
	${DCMD}/ESID0563.cmd  ${ICLODAT_D} 2>&1 | ${TEE}
	
	if [ "${ICLODAT_MTH}" != "12"   ]
	then
		. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} "${BALSHTYEA_NF}1231"
		
		# Launch applicative job ESID0567 31/12
		NJOB="ESID0567"
		${DCMD}/ESID0567.cmd   "${BALSHTYEA_NF}1231" 2>&1 | ${TEE}
		
		# Launch applicative job ESID0568 31/12
		NJOB="ESID0568"
		${DCMD}/ESID0568.cmd  "${BALSHTYEA_NF}1231" 2>&1 | ${TEE}
	fi

CHAINEND

fi

#[004]
# Launch applicative job ESID0561
NJOB="ESID0561"
${DCMD}/ESID0561.cmd  ${ICLODAT_D} 2>&1 | ${TEE}


# Jobs launched if COND1 == N
if [ ${EST_ESID0560_COND1} = "N" -a "${SSDs0}" = "${SSDs}" ]
then
	# Launch applicative job ESID0562
	NJOB="ESID0562"
	${DCMD}/ESID0562.cmd  ${ICLODAT_D} 2>&1 | ${TEE}
fi

# Launch applicative job ESID0563
NJOB="ESID0563"
${DCMD}/ESID0563.cmd  ${ICLODAT_D} 2>&1 | ${TEE}

# Launch applicative job ESID0564
NJOB="ESID0564"
${DCMD}/ESID0564.cmd  ${ICLODAT_D} 2>&1 | ${TEE}

#[005]
# Launch applicative job ESID2501 
NJOB="ESID2501"
${DCMD}/ESID2501.cmd 2>&1 | ${TEE} 


# MODIF JR 05/02/2004   pour creer le FACCSUP 31/12 systematiquement.
if [ "${ICLODAT_MTH}" != "12"   ]
then
	. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} "${BALSHTYEA_NF}1231"
	
	# Launch applicative job ESID0568 31/12
	NJOB="ESID0568"
	${DCMD}/ESID0568.cmd  "${BALSHTYEA_NF}1231" 2>&1 | ${TEE}
fi


if [ "${EST_VARIANTE}" = "3" -a "${ICLODAT_MTH}" != "12"   ]
then
	. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} "${BALSHTYEA_NF}1231"
	
	# Launch applicative job ESID0567 31/12
	NJOB="ESID0567"
	${DCMD}/ESID0567.cmd   "${BALSHTYEA_NF}1231" 2>&1 | ${TEE}
fi




CHAINEND
