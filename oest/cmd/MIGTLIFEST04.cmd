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


NSTEP=${NJOB}_10
# Begin sql 
#------------------------------------------------------------------------------
LIBEL="Rename Estimates Table TLIFEST to TLIFEST_OLD"
ISQL_BASE="BEST"
ISQL_QRY="execute sp_rename TLIFEST, TLIFEST_OLD"
ISQL

NSTEP=${NJOB}_11
# Begin sql 
#------------------------------------------------------------------------------
LIBEL="Rename Estimates Table Migrated TLIFEST_MIG to TLIFEST"
ISQL_BASE="BEST"
ISQL_QRY="execute sp_rename TLIFEST_MIG, TLIFEST"
ISQL


NSTEP=${NJOB}_12
# Begin isql  : create Index BEST..TLIFEST_MIG
#-----------------------------------------------------------------
LIBEL="create index BEST..TLIFEST"
ISQL_BASE="BEST"
ISQL_QRY=${DDDL}/BEST_TLIFEST.idx
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL

JOBEND
