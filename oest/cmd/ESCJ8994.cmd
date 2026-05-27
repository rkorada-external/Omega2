#=============================================================================
# nom de l'application		    : ESTIMATIONS -  Mise a jour de la table TBOPAR
# nom du scipt SHELL		    : ESCJ8994.cmd
# Revision			            :
# date de creation		        : 25/11/2009
# auteur			            : JF VDV
# References des specifications	:
#-----------------------------------------------------------------------------
# desciption:   Update table bsar..TBOPAR
#
# Job launched by ESCJ8990.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#MODIFICATION   : [001]
#Auteur         : D.GATIBELZA
#Date           : 25/05/2010
#Version        : 10.1
#Description    : ESTDOM12363 Revoir le mécanisme de lancement de la comptabilisation des réglements, de lancement des inventaires
#===============================================================================
#set -x

# Call geneic functions
. ${DUTI}/fctgen.cmd

#Recupere arguments d'entree
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
#[001]
CRE_D=$3
DATE_T=${CRE_D}

echo 'BALSHTYEA_NF = ' ${BALSHTYEA_NF}
echo 'BALSHTMTH_NF = ' ${BALSHTMTH_NF}
#[001]
echo 'DATE_T = ' ${DATE_T}

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_10
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Cas de variante egale a 5 - maj de la table TBOPAR"
ISQL_BASE="BSTA"
ISQL_QRY="execute PuTBOPAR_02 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

JOBEND


