#=============================================================================
# nom de l'application		: ESTIMATIONS - MISE A JOUR DE TREQJOB
#                                       Récupération de la TABLE Active dans TBOPAR.
# nom du scipt SHELL		: ESCJ8992.cmd
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
LIBEL="Determination of the TTECLEDA table that will be loaded"
ISQL_BASE="BSTA"
ISQL_QRY="execute PsTBOPAR_01 'EST', 'TTECLEDA', '${CLODATMAX_D}',
                               ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The Table that will take TTECLEDA results is
# Attention, le Fichier temporaire ${ISQL_FRES} est réutilisé dans le JOB suivant ESCJ8993.cmd
TECLEDA=`cat ${ISQL_FRES} | sed -e s/\ //g`
TTECLEDA=T${TECLEDA}
ITECLEDA0=I${TECLEDA}_00
ITECLEDA1=I${TECLEDA}_01

# ATTENTION : PAS de RMFIL des Fichiers Temporaires dans ce JOB !

JOBEND
