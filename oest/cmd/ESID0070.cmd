#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATION
# nom du script SHELL		: ESID0070.cmd
# date de creation          : 08/06/2010
# auteur                    : D.GATIBELZA
#-----------------------------------------------------------------------------
# description :     :spot:19204 - DETERMINATION DES PNA FACULTATIVES pour la chaine ESTIMATION
#                   ( ESID0070 pour ESTIMATION )
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

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
CLODATMAX_D=${22}

# Get Input Parameters
set `GETPRM ${DPRM}/CPTM1010.prm`
BUTEC_B=$7

if [ ${BUTEC_B} -eq 1 ]
then
    BUTEC_B='S'
fi


USR_CF='INV'
ESTIM_B='1'
OPTION='I'      # I for Inventory


echo "SSDs0=$SSDs0                  "
echo "BALSHTYEA_NF=$BALSHTYEA_NF    "
echo "BALSHTMTH_NF=$BALSHTMTH_NF    "
echo "CRE_D=$CRE_D                  "
echo "DBCLO_D=$DBCLO_D              "
echo "CLODAT_D=$CLODAT_D            "
echo "SEGTYP_CT=$SEGTYP_CT          "
echo "CLODATMAX_D=$CLODATMAX_D      "
echo "USR_CF=$USR_CF                "
echo "ESTIM_B=$ESTIM_B              "
echo "OPTION=$OPTION                "
echo "BUTEC_B=$BUTEC_B              "

NJOB="ESCD9001"
# Launch applicative job ESCD9001
. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs0} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${CLODAT_D}


# SR Life
if [ ${EST_VARIANTE} = "7"   ]
then
	CHAINEND
fi

# Jobs launched if COND1 == N
if [ ${EST_ESID0060_COND1} = "N"  -a ${EST_ESID0060_COND3} = "N" ]
then

	echo "------------------------------"
	echo "SSDs0=$SSDs0                  "
	echo "BALSHTYEA_NF=$BALSHTYEA_NF    "
	echo "BALSHTMTH_NF=$BALSHTMTH_NF    "
	echo "CRE_D=$CRE_D                  "
	echo "DBCLO_D=$DBCLO_D              "
	echo "CLODAT_D=$CLODAT_D            "
	echo "SEGTYP_CT=$SEGTYP_CT          "
	echo "CLODATMAX_D=$CLODATMAX_D      "
	echo "USR_CF=$USR_CF                "
	echo "ESTIM_B=$ESTIM_B              "
	echo "OPTION=$OPTION                "
	echo "BUTEC_B=$BUTEC_B              "

	echo "appel"
	echo "DCMD/CPTM1011.cmd USR_CF[${USR_CF}] ESTIM_B[${ESTIM_B}] CLODATMAX_D[${CLODATMAX_D}] CRE_D[${CRE_D}] BUTEC_B[${BUTEC_B}]"

	# Launch applicative job CPTM1011
	NJOB="CPTM1011"
	${DCMD}/CPTM1011.cmd ${USR_CF} ${ESTIM_B} ${CLODATMAX_D} ${CRE_D} ${BUTEC_B} 2>&1 | ${TEE}


	# Launch applicative job ESID0063
	NJOB="ESID0063"
	${DCMD}/ESID0063.cmd 2>&1 | ${TEE}

	# Creation of file for PNA FAC IFRS17
	if [ -f "${EST_FTPNA17}" ]; then
		rm ${EST_FTPNA17}
	fi
	touch ${EST_FTPNA17}
	
	# Lock on parameter file Rows generated in job ESID0063.cmd
	for lig in `cat ${DFILT}/${NCHAIN}_ESID0063_05_${IB}_BCP_PNAPARAM_O.dat`
	do
		# Setting the processing Date, the subsidiary and the establishment
		TRT_D=`echo $lig | cut -d"~" -f1`
		SSD_CF=`echo $lig | cut -d"~" -f2`
		ESB_CF=`echo $lig | cut -d"~" -f3`

		# Launch applicative job CPTM1012
		NJOB="CPTM1012"
		${DCMD}/CPTM1012.cmd ${SSD_CF} ${ESB_CF} ${USR_CF} ${TRT_D} ${ESTIM_B} ${CRE_D} ${CLODAT_D} ${BUTEC_B} ${CLODATMAX_D} 2>&1 | ${TEE}
	done

	# Launch applicative job ESID0064
	NJOB="ESID0064"
	${DCMD}/ESID0064.cmd 2>&1 | ${TEE}

fi

CHAINEND

