#=============================================================================
# nom de l'application		: ESTIMATIONS - MISE A JOUR DE TREQJOB
#                                 Mise a jou de la table des demandes BEST..TREQJOB
# nom du scipt SHELL		: ESPJ8991.cmd
# evision			: 5.1
# date de ceation		: 31/08/2005
# auteu			: M. DJELLOULI
# eferences des specifications	: 
#-----------------------------------------------------------------------------
# desciption
#   Update of Request table
#
# Job launched by ESPJ8990.cmd
#-----------------------------------------------------------------------------
# histoiques des modifications
#[001] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[002] 16/06/2021      Linh DOAN       SPIRA :  91532 : remove VNORME
#[004] 17/24/2021      J.Bonneau-Dillon     SPIRA :  100571
#[005] 17/24/2021      J.Bonneau-Dillon     SPIRA :  100571
#[006] 25/04/2023      JYP/TD :spira:109440 : when SAP POSTING , check flag CLOSING_REQUEST_CANCELED
#===============================================================================
#set -x

# Call geneic functions
. ${DUTI}/fctgen.cmd

#Recupee arguments d'entree
CRE_D=$1
CONSOYEA=$2
CONSOMTH=$3
ENCONSO_D=$4
DBCLO_D=$5
INVCONSO_D=$6
                       
                        
# Job Initialisation
JOBINIT

				
ECHO_LOG "#========================================================================="
ECHO_LOG "-> CRE_D ..................: ${CRE_D}"
ECHO_LOG "-> ENCONSO_D ..............: ${ENCONSO_D}"
ECHO_LOG "-> CONSOYEA ...............: ${CONSOYEA}"
ECHO_LOG "-> CONSOMTH ...............: ${CONSOMTH}"
ECHO_LOG "-> DBCLO_D ................: ${DBCLO_D}"
ECHO_LOG "-> INVCONSO_D .............: ${INVCONSO_D}"
ECHO_LOG "-> CLOSING_REQUEST_CANCELED: ${CLOSING_REQUEST_CANCELED}"
ECHO_LOG "#========================================================================="




if [ "${CLOSING_REQUEST_CANCELED}" == "Y" -a "${NORME_CF}" == "EBS"  ]
then
	ECHO_LOG "-> CLOSING_REQUEST_CANCELED: ${CLOSING_REQUEST_CANCELED} : request is closed by ESFD3460-recover "


	NSTEP="ESPJ8991_02"
	#-----------------------------------------------------------------------------
	LIBEL="set CLOSING_REQUEST_CANCELED from Y to N into ${DPRM}/ESPJ8990_REQUEST_${NORME_CF}.prm "
	AWK_I=${DPRM}/ESPJ8990_REQUEST_${NORME_CF}.prm
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
	cp -p ${DFILT}/${ENV_PREFIX}_${NSTEP}_${IB}_REQUEST_CANCELED_${NORME_CF}.dat ${DPRM}/ESPJ8990_REQUEST_${NORME_CF}.prm
					
   JOBEND
fi


NSTEP=${NJOB}_05
# Begin isql 
#------------------------------------------------------------------------------
LIBEL="Update of Request table - Type F et T" 
ISQL_BASE="BEST"
ISQL_QRY="exec PuREQJOB_07 '${CRE_D}', ${CONSOYEA}, ${CONSOMTH}, '${INVCONSO_D}', '${DBCLO_D}', '${ENCONSO_D}'"
ISQL

if [ "${NORME_CF}" == "" ]
then
        JOBEND
fi


NSTEP=${NJOB}_10
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Update of I17 Request table "
ISQL_BASE="BEST"
ISQL_QRY="exec PuI17REQJOBPLAN_01 '${NORME_CF}', '${CRE_D}', ${CONSOYEA}, ${CONSOMTH}, '${INVCONSO_D}' with recompile"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL

# [003]
NSTEP=${NJOB}_15
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Update of I17 Request table"
ISQL_BASE="BEST"
ISQL_QRY="exec PuI17REQJOBPLAN_03 '${CRE_D}', ${CONSOYEA}, ${CONSOMTH}, '${INVCONSO_D}' with recompile"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL



JOBEND
