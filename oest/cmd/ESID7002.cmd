#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 creation année +1 dans TCURQUOT
#                                 ESTDOM19231 V10 Inventaires de janvier sans taux sur Bilan en cours  au closing annuel, charger le taux de décembre YY dans janvier YY+1
# nom du script SHELL           : ESID7002.cmd
# date de creation              : 21/07/2010
# auteur                        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:      Update estimates
# job launched by:  ESID7000.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#_________________
#MODIFICATION    []
#Auteur:         
#Date:           
#Version:        
#Description:    
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
BLCSHTYEA_NF=$1
BLCSHTMTH_NF=$2

# Job Initialisation
JOBINIT


echo "BLCSHTMTH_NF = ${BLCSHTMTH_NF}"

if [ "${BLCSHTMTH_NF}" = "12" ]
then

NSTEP=${NJOB}_10
#Update Normal Period Table BEST..TREQJOB
#-----------------------------------------------------------------------------
LIBEL="Chargement des taux de TCURQUOT: décembre YY dans janvier YY+1"
ISQL_QRY="EXECUTE BEST..PiCURQUOT_03"
ISQL_BASE="BEST"
ISQL

fi

JOBEND
