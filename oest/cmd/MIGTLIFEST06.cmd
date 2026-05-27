#!/bin/ksh                                                                           
#=============================================================================       
# nom de l'application          : ESTIMATION MIGRATION                                    
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
 

JOBINIT

NSTEP=${NJOB}_01
# Begin isql  : Installation et ajout du parametrages
#-----------------------------------------------------------------
LIBEL="Installation et ajout du parametrages"
ISQL_BASE="BEST"
ISQL_QRY=${DDML}/BEST_PARAMETRAGES.sql
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL

JOBEND
