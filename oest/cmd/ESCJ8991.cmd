#=============================================================================
# nom de l'application		: ESTIMATIONS - MISE A JOUR DE TREQJOB
#                                 Mise a jou de la table des demandes 
#				  BEST..TREQJOB
# nom du scipt SHELL		: ESCJ8991.cmd
# evision			: $Revision: 1.4 $
# date de ceation		: 28/11/97
# auteu			: C.G.I. (M.HA-THUC)
# eferences des specifications	: 
#-----------------------------------------------------------------------------
# desciption
#   Update of equest table
#
# Job launched by ESCJ8990.cmd
#-----------------------------------------------------------------------------
# histoiques des modifications
#---------------
#MODIFICATION   : [001]
#Auteur         : D.GATIBELZA
#Date           : 23/08/2010
#Version        : 10.0
#Description    : ESTDOM19070 V10 scheduler pour le lancement des inventaires
#
#--------------------------------------------------------------------------------------------------
# Historique des modifications
#==================================================================================================
#   <indice>        <jj/mm/aaaa>    <auteur>        <spira>                 <description de la modification>
# 	[001]           15/06/2021      Linh DOAN       SPIRA :  91532 : remove VNORME
# 	[002]           15/07/2021      D.TEIXEIRA      SPIRA :  97541 Replace ${PARM0_ICLODAT_D} to ${ICLODAT_D} on ISQL_QRY
# 	[003]           28/09/2021      D.TEIXEIRA      SPIRA :  91532 debug
# 	[004]           11/24/2021      J.Bonneau-Dillon     SPIRA :  100571
#===============================================================================
#set -x

# Call geneic functions
. ${DUTI}/fctgen.cmd

#Recupee arguments d'entree
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
ICLODAT_D=$4
DBCLO_D=$5
CLODATMAX_D=$6



# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
# Begin isql 
#------------------------------------------------------------------------------
LIBEL="Update of equest table" 
ISQL_BASE="BEST"
ISQL_QRY="exec PuREQJOB_02 '${CRE_D}', ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${ICLODAT_D}', '${DBCLO_D}', '${CLODATMAX_D}'"
ISQL


#[001]
NSTEP=${NJOB}_10
# Begin isql 
#------------------------------------------------------------------------------
LIBEL="Maj TREQJOBPLAN" 
ISQL_BASE="BEST"
ISQL_QRY="exec PuREQJOBPLAN_02 '${CRE_D}'"
ISQL

# [003]
# if [ "${NORME_CF}" == "" ]
# then
# 	JOBEND
# fi

BALSHTYEA=`echo ${PARM0_ICLODAT_D} | cut -c1-4`
BALSHTMTH=`echo ${PARM0_ICLODAT_D} | cut -c5-6`


NSTEP=${NJOB}_15
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Update of I17 Request table for  $BALSHTMTH / $BALSHTYEA"
ISQL_BASE="BEST"
# [02]
ISQL_QRY="exec PuI17REQJOBPLAN_01 '${NORME_CF}', '${CRE_D}', ${BALSHTYEA}, ${BALSHTMTH}, '${ICLODAT_D}' with recompile"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL

# [004]
NSTEP=${NJOB}_20
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Update of I17 Request table"
ISQL_BASE="BEST"
ISQL_QRY="exec PuI17REQJOBPLAN_03 '${CRE_D}', ${BALSHTYEA}, ${BALSHTMTH}, '${ICLODAT_D}' with recompile"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL


JOBEND
