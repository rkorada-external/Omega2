#!/bin/ksh                                                                           
#=============================================================================       
# nom de l'application          : ESTIMATION MIGRATION                                    
# nom du script SHELL           : .cmd                                       
# revision                      : $Revision: 1.10 $                                  
# date de creation              : 30/12/2014                                                   
# auteur                        : Cyrille Despret                                                   
# references des specifications :                                                    
#-----------------------------------------------------------------------------       
# description :                              
#  Migre les fichiers ESTP0000_*PERICASE*.dat en version 2C                                        
#-----------------------------------------------------------------------------       
# historique des modifications :                                                     
#                                                                                    
#                                                                                    
#===============================================================================     
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd


CHAININIT $0 $DENV/CNLD0030.env

NJOB=UpdateEspt0000Peric2C

# Job Initialisation
JOBINIT

echo "**********************************************"
echo " ESPT0000 PERICASE files update to 2C version "
echo "**********************************************"
echo

# Pour chaque fichier ESPT PERICASE
for FICHIER in ${ENV_PREFIX}_ESPT0000_CRVPERICASE0.dat ${ENV_PREFIX}_ESPT0000_IADVPERICASE.dat ${ENV_PREFIX}_ESPT0000_IARVPERICASE0.dat ${ENV_PREFIX}_ESPT0000_OIADVPERICASE.dat ${ENV_PREFIX}_ESPT0000_OIRDVPERICASE.dat ${ENV_PREFIX}_ESPT0000_IRDPERICASE0.dat ${ENV_PREFIX}_ESPT0000_IADPERICASE.dat
do

  echo                         >&1 | ${TEE}
  echo - - - - - - - - - - 
  echo File: ${FICHIER}
  echo Head : ${FICHIER}
  head -1 ${DFILP}/${FICHIER}
  echo
  
  # sauvegarde
  echo - Sauvegarde ${DSAV}/${FICHIER}.gz             >&1 | ${TEE} 
  gzip -c ${DFILP}/${FICHIER} > ${DSAV}/${FICHIER}.gz >&1 | ${TEE}
  
  # colonne 35 = INSPOL_R renseignee uniquement pour traite sinon vide
  # ajout des colonnes
  echo - Awk ${FICHIER} >&1 | ${TEE}
  awk -F"~" 'BEGIN { OFS="~" } $35 != "" {print $0"~~~~~~~~~1~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"} $35 == "" {print $0"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"}' ${DFILP}/${FICHIER} > ${DFILT}/${FICHIER}.2C		>&1 | ${TEE}
  
  # Renomme le fichier genere
  echo - Move ${DFILP}/${FICHIER}               >&1 | ${TEE}
  mv ${DFILT}/${FICHIER}.2C ${DFILP}/${FICHIER} >&1 | ${TEE}
  
  echo
  echo Head ${FICHIER}
  head -1 ${DFILP}/${FICHIER}
  echo ${FICHIER} done		
  echo
	
done

JOBEND >&1 | ${TEE}

CHAINEND


