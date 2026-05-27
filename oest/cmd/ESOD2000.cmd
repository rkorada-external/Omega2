#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire dommages
# nom du script SHELL           : ESID2000.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 16/09/97
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
#   Non life acceptance closing period process ( set 10 )
#
#   Launch application jobs ESCD9001 and ESID2001-2-3-4  
#
#-----------------------------------------------------------------------------
# historique des modifications :
#[001] 18/04/2012 Roger Cassis :spot:23802 - refonte entiere pour Solvency
#[002] 05/09/2012 Roger Cassis :spot:24041 - Solvency - maj commentaires
#[003] 06/09/2012 -=Dch=-      :spot:24041 - refonte entiere pour Solvency => Ajout du paramètre ICLODAT_D à ESID2003
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_DTSTATGTAA
#	EST_FCPLACC
#	EST_FCTREST
#	EST_FCTRGRO
#	EST_FCTRULT
#	EST_FCURQUOT
#	EST_FLABOCY
#	EST_FLOARAT
#	EST_FPRMLOA
#	EST_FSEGEST
#	EST_FT
#	EST_FTRSLNK
#	EST_IADPERICASE
#	EST_IADPERIFCI
#	EST_IADPERIFCT
#	EST_IADPERIFR
#	EST_IADPERIPRMD
#	EST_MVTPNA
#	EST_PERICASESNEM
# Output files
#	EST_DLDGTAA
#	EST_DSUMGTAASNEM
#	EST_FCTREST
#	EST_FLOARAT
#	EST_FLOARATSNEM
#	EST_FPRMLOA
#	EST_FT
#	EST_PERIANO
#	EST_PERICASESNEM
#-=-=-=-=-=-=-=-=-=-=-=


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get the parameters
set `GETPRM ${EST_PARAM}` 

SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8
CLOTYP_CT=${10}
SEGTYP_CT=${11}
SSDDEL_LL=${12}
LSTCLODAT_LL=${13}
SSDVRS_LL=${14}

# valeur forcée juste pour tests
#EST_COND1=Y

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}

# Launch applicative job ESID2001
NJOB="ESID2001"
${DCMD}/ESID2001.cmd ${CRE_D} ${BALSHTYEA_NF} ${CLOTYP_CT} ${SEGTYP_CT} ${ICLODAT_D} ${SSDs} ${SSDVRS_LL} ${LSTCLODAT_LL} ${SSDDEL_LL} 2>&1 | ${TEE}

# Launch applicative job ESID2001
NJOB="ESID2002I"
${DCMD}/ESID2002.cmd ${CRE_D} ${BALSHTYEA_NF} ${CLOTYP_CT} ${ICLODAT_D} ${SSDs} ${SSDVRS_LL} ${LSTCLODAT_LL} ${SSDDEL_LL} IFRS INV 2>&1 | ${TEE}

if [ "${EST_ESID2000_COND1}" = "Y" ]     # option EBS ?
then

	# Launch applicative job ESID2001
	NJOB="ESID2002E"
	${DCMD}/ESID2002.cmd ${CRE_D} ${BALSHTYEA_NF} ${CLOTYP_CT} ${ICLODAT_D} ${SSDs} ${SSDVRS_LL} ${LSTCLODAT_LL} ${SSDDEL_LL} EBS INV 2>&1 | ${TEE}
	
	# Launch applicative job ESID2001
	NJOB="ESID2003"
	${DCMD}/ESID2003.cmd INV ${ICLODAT_D} 2>&1 | ${TEE}

fi

# Launch applicative job ESID2001
NJOB="ESID2004"
${DCMD}/ESID2004.cmd ${CRE_D} ${CLOTYP_CT} ${ICLODAT_D} ${EST_VARIANTE} 2>&1 | ${TEE}

CHAINEND
