#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID0060.cmd
# revision                      : $Revision: 1.6 $
# date de creation              : 26/05/1997
# auteur                        : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Launch perimeter and extract tables
#-----------------------------------------------------------------------------
# historiques des modifications
#  J.Ribot   13/01/03     parametre CLODATMAX_D  a la place de CLODAT_D
#                                      (appel de ESID0065.cmd)
#  G.Buisson  08/09/2003  Ajout du parametre BALSHTMTH_NF dans le lancement de
#                         ESID0061.cmd pour eviter de prendre les lignes posterieures
#                         au mois bilan a traiter suite au deblocage des periodes
#                         exceptionnelles
# 06/04/2006 M. DJELLOULI SPOT 10102-11155 - Adding Parameter BUTEC_B
#---------------
#[004] D.GATIBELZA 08/06/2010 :spot:19204 - Optimisation des batch
#[005] T.RIPERT    03/09/2010 :spot:19177 - DAC
#[006] JF VDV      24/10/2010 :spot:20198 - Eviter les doublons dans TLIFEST (cas inventaire en journée) ajout de CRE_D dans les job ESID0061 & ESID0067
#[007] R. CASSIS   11/04/2011 :spot:21408 - Suppression du ESID0066 car le fichier est déja fait dans le ESIJ0011
#[008] D.CHETBOUL  03.08.2011 :spot:22422 - inventaire service (variante 4)
#[009] Florent     06.09.2011 :spot:22460 - ajout année bilan pour le job ESID0068
#[010] R. Cassis   11/07/2012 :spot:23802 - Ajout cre_d dans appel ESID0065 pour Solvency
#[011] R. Cassis   09/10/2012 :spot:24041 - Ajout option INV dans job ESID0065
#[012] R. Cassis   24/04/2014 :spot:25427 - Si mode compta, on utilise clodat au lieu de clodatmax pour les fichiers FWH dans ESID0065
#[013] R. Cassis   24/06/2015 :spot:28694 - La creation de FVSEGEST se fait dans le ESID0065 pas le ESID0062
#[014] S. Askri    30/06/2015 :spot:28694 - La creation de FVSEGEST se fait le ESID0062
#[015] R. Cassis   03/05/2021 :spira:92356 - Ajout PERTYP_CT en parametre
#======================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Get entry parameters
# ${EST_PARAM} is a global environment variable
#SSDs0 subsidiaries of all closing years
#CLODAT_D closing year label
set `GETPRM ${EST_PARAM}`
SSDs0=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
DBCLO_D=$5
CLODAT_D=$6
SEGTYP_CT=$8
PERTYP_CT=$9
CLODATMAX_D=${22}


NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}

USR_CF='INV'
ESTIM_B='1'
# I for Inventory
OPTION='I'



# SR Life (7)

#  ==- [008]  Dch -==
# ou inventaire service (variante 4)

if [ ${EST_VARIANTE} = "7" -o  ${EST_VARIANTE} = "4"  ]
then

	# Launch applicative job ESID0067
	NJOB="ESID0067"
	${DCMD}/ESID0067.cmd   ${SEGTYP_CT} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}

	#[010] [012]
	NJOB="ESID0065"
	${DCMD}/ESID0065.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODATMAX_D} ${CRE_D} INV ${CLODAT_D} 2>&1 | ${TEE}

	#[007]
	# Launch applicative job ESID0068
	NJOB="ESID0068"
	${DCMD}/ESID0068.cmd ${BALSHTYEA_NF} 2>&1 | ${TEE}

	CHAINEND

fi

# Jobs launched if variante 5 Comptabilisation mensuelle
if [ ${EST_VARIANTE} = "5"   ]
then

	# Launch applicative job ESID0069
	NJOB="ESID0069"
	${DCMD}/ESID0069.cmd  2>&1 | ${TEE}

	# Launch applicative job ESID0001
	NJOB="ESID0001"
	${DCMD}/ESID0001.cmd ${SEGTYP_CT} ${CRE_D}  2>&1 | ${TEE}

fi

if [ ${EST_ESID0060_COND1} = "N"  -a ${EST_ESID0060_COND3} = "N" ]
then

	# Launch applicative job ESID0069
	NJOB="ESID0069"
	${DCMD}/ESID0069.cmd  2>&1 | ${TEE}

	# Launch applicative job ESID0001
	NJOB="ESID0001"
	${DCMD}/ESID0001.cmd ${SEGTYP_CT} ${CRE_D}  2>&1 | ${TEE}

	# Launch applicative job ESID0061
	NJOB="ESID0061"
	${DCMD}/ESID0061.cmd ${CLODAT_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} 2>&1 | ${TEE}

	# Launch applicative job ESID0062
	NJOB="ESID0062"
	${DCMD}/ESID0062.cmd ${SEGTYP_CT} ${CRE_D} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODAT_D} ${SEGTYP_CT} ${PERTYP_CT} 2>&1 | ${TEE} #[014]

fi

# Launch applicative job ESID0065
# Modif OG 18/11/02, on ajoute la clodat
#[010] [012]
NJOB="ESID0065"
${DCMD}/ESID0065.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CLODATMAX_D} ${CRE_D} INV ${CLODAT_D} 2>&1 | ${TEE}   #[013]

#[007]
# Launch applicative job ESID0066
#NJOB="ESID0066"
#${DCMD}/ESID0066.cmd ${BALSHTYEA_NF} ${BALSHTMTH_NF} 2>&1 | ${TEE}

#[005]
# Launch applicative job ESID0068
NJOB="ESID0068"
${DCMD}/ESID0068.cmd ${BALSHTYEA_NF} 2>&1 | ${TEE}

CHAINEND
