#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 08.01 : Accouting and Reporting
# Nom du script SHELL           : ESFD8100.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 07/03/2019
# Auteur                        : Linh DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# SPIRA 77081 : REQ 08.01 - F3. Generating data for RA
#  - Generation of RA files : TTECLEDA, TTECLEDR, TTECLEDSII
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#	[001] 		11/04/2019 		Linh DOAN 	SPIRA : 77081 Generating IFRS 17 Group RA files	
#   [002]       01/07/2022      D.Teixeira  Spira : 104403 - Add new job ESID8102 Controle Period and Closing type 
#   [003]       01/07/2022      M.NAJI      Spira : 999999 - deplacment du job ESID8102 dans le bloc IFRS4   
#	[004] 		18/10/2023 		M.NAJI       :spira 110480 I17S- Change in RA interface  
#	[005]       05/08/2025      Mr JYP      US 5559 : SERQS split files by site  , SII part  
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#IDF_CT=I17G_OMG_RA_STD            

IDF_CT=$2

NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}



if [ "${IDF_CT}" = "I17S_OMG_RA_STD" ]
then
	NJOB="ESFD8102"
	${DCMD}/ESFD8102.cmd  2>&1 | ${TEE}
fi


# SII split by site
NJOB="ESFD3937${TYPEINV}"
${DCMD}/ESFD3937.cmd $ESF_FTECLEDSII $ESF_FTECLEDSII_TOAS $ESF_FTECLEDSII_TOEU $ESF_FTECLEDSII_TOAM  $ESF_FTECLEDSII_FROMAS $ESF_FTECLEDSII_FROMEU $ESF_FTECLEDSII_FROMAM  2>&1 | ${TEE}


if [[ "${IDF_CT}" =~ I17(G|L|P)_OMG_RA_AOC ]]
then

	# Launch applicative job ESFD8101 for RA Posting Aoc
	NJOB="ESFD8103"
	${DCMD}/ESFD8103.cmd 2>&1 | ${TEE}

else

	# SII split by site
	NJOB="ESFD3937${TYPEINV}"
	${DCMD}/ESFD3937.cmd $ESF_GTSII_RISKMARGIN $ESF_SII_RISKMARGIN_TOAS $ESF_SII_RISKMARGIN_TOEU $ESF_SII_RISKMARGIN_TOAM  $ESF_SII_RISKMARGIN_FROMAS $ESF_SII_RISKMARGIN_FROMEU $ESF_SII_RISKMARGIN_FROMAM  2>&1 | ${TEE}

	# Launch applicative job ESFD8101 for RA Posting IFRS17
	NJOB="ESFD8101"
	${DCMD}/ESFD8101.cmd 2>&1 | ${TEE}

	NJOB="ESID8102"
	${DCMD}/ESID8102.cmd ${NORME_CF} 2>&1 | ${TEE}
fi

CHAINEND
 
