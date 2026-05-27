#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Inventaire dommages OPTUMISATION de la chaine 
# nom du script SHELL           : ESFD2000.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 24/12/2019
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
#   Non life acceptance closing period process ( set 10 )
#
#   Launch application jobs ESCD9001 and ESID2001A-B-C-D  
#
#-----------------------------------------------------------------------------
# historique des modifications :
#[001] 18/04/2012 Roger Cassis :spot:23802 - refonte entiere pour Solvency
#[002] 05/09/2012 Roger Cassis :spot:24041 - Solvency - maj commentaires
#[003] 06/09/2012 -=Dch=-      :spot:24041 - refonte entiere pour Solvency => Ajout du paramètre ICLODAT_D à ESID2003
#[004] 13/03/2020 M.NAJI	   :Spira SPIRA 84317 : Optimisation ESID2000 : decoupage de la chaine ESID2000 en 2
#===============================================================================
#set -x


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	
# Output files
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


NJOB="ESCD9001"
# Launch applicative job ESCD9001A
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}



# Launch applicative job ESFD2001E
NJOB="ESFD2001E"
${DCMD}/ESFD2001E.cmd ${CRE_D} ${BALSHTYEA_NF} ${CLOTYP_CT} ${SEGTYP_CT} ${ICLODAT_D} ${SSDs} ${SSDVRS_LL} ${LSTCLODAT_LL} ${SSDDEL_LL} 2>&1 | ${TEE}



# Launch applicative job ESFD2001
NJOB="ESFD2002I"
${DCMD}/ESFD2002.cmd ${CRE_D} ${BALSHTYEA_NF} ${CLOTYP_CT} ${ICLODAT_D} ${SSDs} ${SSDVRS_LL} ${LSTCLODAT_LL} ${SSDDEL_LL} IFRS INV 2>&1 | ${TEE}

if [ "${EST_ESFD2000_COND1}" = "Y" ]     # option EBS ?
then

        # Launch applicative job ESFD2001
        NJOB="ESFD2002E"
        ${DCMD}/ESFD2002.cmd ${CRE_D} ${BALSHTYEA_NF} ${CLOTYP_CT} ${ICLODAT_D} ${SSDs} ${SSDVRS_LL} ${LSTCLODAT_LL} ${SSDDEL_LL} EBS INV 2>&1 | ${TEE}

        # Launch applicative job ESFD2001
        NJOB="ESFD2003"
        ${DCMD}/ESFD2003.cmd INV ${ICLODAT_D} 2>&1 | ${TEE}

fi

# Launch applicative job ESFD2001
NJOB="ESFD2004"
${DCMD}/ESFD2004.cmd ${CRE_D} ${CLOTYP_CT} ${ICLODAT_D} ${EST_VARIANTE} 2>&1 | ${TEE}

CHAINEND
	
