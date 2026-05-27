#!/bin/ksh
#====================================================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 : Planning update
# Nom du script SHELL           : ESFJ8991.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 07/03/2019
# Auteur                        : Linh DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
#  - update planning
#
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#   <indice>    <jj/mm/aaaa>    <auteur>    <spira>        <description de la modification>
#   [001]       19/02/2020      Linh DOAN   SPIRA : 83904 : Ending of Closing plan I17G
#	[002]		15/10/2020  	Linh DOAN 	SPIRA : 87596 : change EBS & IFRS4	
#	[003]	    17/11/2020    	Linh DOAN	SPIRA : 84234 : planning AOC update
#   [003]       03/06/2021      Linh DOAN   SPIRA : 91532 : remove VNORME
#   [006]       25/04/2023      JYP/TD      SPIRA : 109440: when SAP POSTING , check flag CLOSING_REQUEST_CANCELED
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd


# Get input parameters

CRE_D=${PARM_CRE_D}
#BALSHTYEA_NF=${PARM_BLCSHTYEA_NF}
#BALSHTMTH_NF=${PARM_BLCSHTMTH_NF}

CONSOYEA=${PARM_CONSOYEA}
CONSOMTH=${PARM_CONSOMTH}

CLODAT_D=${PARM_ICLODAT_D}
INVCONSO_D=${PARM_INVCONSO_D}

# Job Initialization
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "-> CRE_D ..................: ${CRE_D}"
ECHO_LOG "-> CLODAT_D  ..............: ${CLODAT_D}"
ECHO_LOG "-> CONSOYEA ...............: ${CONSOYEA}"
ECHO_LOG "-> CONSOMTH ...............: ${CONSOMTH}"
ECHO_LOG "-> INVCONSO_D .............: ${INVCONSO_D}"
ECHO_LOG "-> CLOSING_REQUEST_CANCELED: ${CLOSING_REQUEST_CANCELED}"
ECHO_LOG "#========================================================================="


# Job Initialisation
JOBINIT

if [[ "${IDF_CT}" =~ I17(G|L|P)_OMG_CLO_AOC ]]
then

        #REQ1000.13- IFRS17 SAP - Closing plan generation

        NSTEP=${NJOB}_05
        # Begin isql
        #------------------------------------------------------------------------------
        LIBEL="Update of I17 Request table "
        ISQL_BASE="BEST"
        ISQL_QRY="exec PuI17REQJOBPLAN_02 '${NORME_CF}', '${CRE_D}', ${CONSOYEA}, ${CONSOMTH}, '${INVCONSO_D}' with recompile"
        ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
        ISQL

	
else #IFRS17 closing 


	if [ "${CLOSING_REQUEST_CANCELED}" == "Y"  ]
	then
		ECHO_LOG "-> CLOSING_REQUEST_CANCELED: ${CLOSING_REQUEST_CANCELED} : request is closed by ESFD3460-recover "
	
		NSTEP="ESFJ8991_02"
		#-----------------------------------------------------------------------------
		LIBEL="set CLOSING_REQUEST_CANCELED from Y to N into ${DPRM}/ESFJ8990_REQUEST_${NORME_CF}.prm "
		AWK_I=${DPRM}/ESFJ8990_REQUEST_${NORME_CF}.prm
		AWK_O=${DFILT}/${ENV_PREFIX}_${NSTEP}_${IB}_REQUEST_CANCELED_${NORME_CF}.dat
		AWK_CMD=`CFTMP`
		INPUT_TEXT ${AWK_CMD} <<EOF
		{ 
		if (substr(\$1,1,24) != "CLOSING_REQUEST_CANCELED" ) 
			{print \$0;}
		}
		END { print "CLOSING_REQUEST_CANCELED N";}
		exit
EOF
		AWK
		cp -p ${DFILT}/${ENV_PREFIX}_${NSTEP}_${IB}_REQUEST_CANCELED_${NORME_CF}.dat ${DPRM}/ESFJ8990_REQUEST_${NORME_CF}.prm
						
		JOBEND
	fi



	

	#REQ1000.13- IFRS 17- Closing plan generation
	NSTEP=${NJOB}_05
	# Begin isql 
	#------------------------------------------------------------------------------
	LIBEL="Update of I17 Request table " 
	ISQL_BASE="BEST"
	ISQL_QRY="exec PuI17REQJOBPLAN_01 '${NORME_CF}', '${CRE_D}', ${CONSOYEA}, ${CONSOMTH}, '${INVCONSO_D}' with recompile"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

fi


JOBEND

