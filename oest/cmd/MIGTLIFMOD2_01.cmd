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

# Parameters
BALSHTYEA_NF=$1
SSD_CF=$2


NSTEP=${NJOB}_10
# Begin sql 
#------------------------------------------------------------------------------
LIBEL="Generation of hitory of update Table Migrated BALSHTYEA_NF=${BALSHTYEA_NF} and SSD_CF = ${SSD_CF}"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PsTLIFMOD2_MIGRATION ${BALSHTYEA_NF}, ${SSD_CF}"
ISQL

JOBEND
