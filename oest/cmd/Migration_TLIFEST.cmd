#!/bin/ksh                                                                           
#=============================================================================       
# nom de l'application          : ESTIMATION TEST                                    
# nom du script SHELL           : .cmd                                       
# revision                      : $Revision: 1.10 $                                  
# date de creation              :                                                    
# auteur                        :                                                    
# references des specifications :                                                    
#-----------------------------------------------------------------------------       
# description :                                                                      
#   Predictions Update                                                               
#   Output file sort                                                                 
#		                                                                                 
#                                                                                    
#                                                                                    
# job launched by .cmd                                                       
#-----------------------------------------------------------------------------       
# historique des modifications :                                                     
#                                                                                    
#                                                                                    
#===============================================================================     
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd
. ${DUTI}/fctftp.cmd
 
CHAININIT $0 $DENV/Migration_TLIFEST.env


for ssd_cf in $(cat ${DPRM}/liste_SSD.prm)
do
    # Launch applicative job MIGTLIFEST02 (Migration du bilan en cours = 2015)
    NJOB="MIGTLIFEST02"
    echo "Traitement de la filiale : $ssd_cf"
    ${DCMD}/MIGTLIFEST02.cmd 2015 $ssd_cf 2>&1 | ${TEE}
done 

for ssd_cf in $(cat ${DPRM}/liste_SSD.prm)
do
    # Launch applicative job MIGTLIFEST02 (Migration du bilan en cours = 2015)
    NJOB="MIGTLIFEST02"
    echo "Traitement de la filiale : $ssd_cf"
    ${DCMD}/MIGTLIFEST022.cmd 2015 $ssd_cf 2>&1 | ${TEE}
done 

for bilan in $(cat ${DPRM}/liste_BILAN.prm)
do
	for ssd_cf in $(cat ${DPRM}/liste_SSD.prm)
  do
			# Launch applicative job MIGTLIFEST03 (Migration des bilan precedants < 2015)
			NJOB="MIGTLIFEST03"
			${DCMD}/MIGTLIFEST03.cmd $bilan $ssd_cf 2>&1 | ${TEE}
  done
done 



CHAINEND
