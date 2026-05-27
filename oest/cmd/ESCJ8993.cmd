#=============================================================================
# nom de l'application		: ESTIMATIONS - MISE A JOUR DE TREQJOB
#                                       Mise a jou de la table des demandes BEST..TREQJOB
# nom du scipt SHELL		: ESCJ8993.cmd
# Revision			: $Revision:   5.1  $
# date de ceation		: 27/06/2005
# auteur			: M. DJELLOULI
# References des specifications	: 
#-----------------------------------------------------------------------------
# desciption
#   Update of equest table
#
# Job launched by ESCJ8990.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#set -x

# Call geneic functions
. ${DUTI}/fctgen.cmd

#Recupee arguments d'entree
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
ICLODAT_D=$4
CLODAT_D=$5
DBCLO_D=$6
CLODATMAX_D=$7
SSDCLO_LL=$8

# Job Initialisation
JOBINIT

#The Table that will take TTECLEDA results is
TECLEDA=`cat ${DFILT}/${NCHAIN}_ESCJ8992_10_${IB}_ISQLRES_O.dat | sed -e s/\ //g`
TTECLEDA=T${TECLEDA}
ITECLEDA0=I${TECLEDA}_00
ITECLEDA1=I${TECLEDA}_01

echo ${TECLEDA}
echo ${CRE_D}
echo ${BALSHTYEA_NF}
echo ${BALSHTMTH_NF}
echo ${ICLODAT_D}
echo ${CLODAT_D}
echo ${DBCLO_D}
echo ${CLODATMAX_D}
echo "SSDCLO_LL " ${SSDCLO_LL}

NSTEP=${NJOB}_10
# Begin isql 
#------------------------------------------------------------------------------
LIBEL="Update of Request table" 
ISQL_BASE="BEST"
ISQL_QRY="exec PuREQJOB_06 '${CRE_D}', ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CLODAT_D}', '${DBCLO_D}', '${CLODATMAX_D}' , '${TECLEDA}' , '${SSDCLO_LL}'"
ISQL

JOBEND
