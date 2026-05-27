#!/bin/ksh                                                                           
#=============================================================================       
# nom de l'application          : ESTIMATION TEST                                    
# nom du script SHELL           : ESID3028.cmd                                       
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
# job launched by ESID3020.cmd                                                       
#-----------------------------------------------------------------------------       
# historique des modifications :                                                     
#                                                                                    
#                                                                                    
#===============================================================================     
#set -x                                                                              
                                                                                     
NCHAIN=${ENV_PREFIX}_CNLD0030     
NJOB=CNLD0031                     
                                  
# Call generic functions          
. ${DUTI}/fctgen.cmd              
. ${DUTI}/fcttransfer.cmd         
. ${DUTI}/fctftp.cmd              
                                  
CHAININIT $0 $DENV/CNLD0030.env   

JOBINIT 
                                                                                     
NSTEP=${NJOB}_10                                                                       
# Begin bcp                                                                            
#------------------------------------------------------------------------------        
LIBEL="Loading US TSUBTRSESBPROP table"                                    
BCP_WAY="IN"                                                                           
BCP_VER=""
BCP_FS=";"
BCP_TRUNCATE=YES                                                                             
BCP_I="${DDML}/TSUBTRSESBPROP_UAT_US.csv"                   
BCP_TABLE="BREF..TSUBTRSESBPROP"                                                            
BCP

NSTEP=${NJOB}_101                                                                      
# Begin bcp                                                                            
#------------------------------------------------------------------------------        
LIBEL="Loading PARIS TSUBTRSESBPROP table"                                    
BCP_WAY="IN"                                                                           
BCP_VER=""
BCP_FS=";"
#BCP_TRUNCATE=YES                                                                             
BCP_I="${DDML}TSUBTRSESBPROP_UAT_Paris.csv"                    
BCP_TABLE="BREF..TSUBTRSESBPROP"                                                            
BCP

NSTEP=${NJOB}_11                                                                       
# Begin bcp                                                                            
#------------------------------------------------------------------------------        
LIBEL="Loading TSUBTRSBLOCKLIFEST table"                                    
BCP_WAY="IN"                                                                           
BCP_VER=""
BCP_FS=";"
BCP_TRUNCATE=YES                                                                             
BCP_I="${DDML}TSUBTRSBLOCKLIFEST_UAT.csv"                    
BCP_TABLE="BREF..TSUBTRSBLOCKLIFEST"                                                            
BCP                                                                                    
                                                                                       

NSTEP=${NJOB}_12                                                                       
# Begin bcp                                                                            
#------------------------------------------------------------------------------        
LIBEL="Loading TSUBTRSBASE table"                                    
BCP_WAY="IN"                                                                           
BCP_VER=""
BCP_FS=";"
BCP_TRUNCATE=YES                                                                             
BCP_I="${DDML}/TSUBTRSBASE_UAT.csv"                    
BCP_TABLE="BREF..TSUBTRSBASE"                                                            
BCP
                                                                                    
NSTEP=${NJOB}_13                                                                       
# Begin bcp                                                                            
#------------------------------------------------------------------------------        
LIBEL="Loading TSUBTRSASSO table"                                    
BCP_WAY="IN"                                                                           
BCP_VER=""
BCP_FS=";"
BCP_TRUNCATE=YES                                                                             
BCP_I="${DDML}/TSUBTRSASSO_UAT.csv"                    
BCP_TABLE="BREF..TSUBTRSASSO"                                                            
BCP

                                                                                    
NSTEP=${NJOB}_14                                                                       
# Begin bcp                                                                            
#------------------------------------------------------------------------------        
LIBEL="Loading TSUBTRS table"                                    
BCP_WAY="IN"                                                                           
BCP_VER=""
BCP_FS=";"
BCP_TRUNCATE=YES                                                                             
BCP_I="${DDML}/TSUBTRS_UAT.csv"                    
BCP_TABLE="BREF..TSUBTRS"                                                            
BCP

                                                                                    
NSTEP=${NJOB}_15                                                                       
# Begin bcp                                                                            
#------------------------------------------------------------------------------        
LIBEL="Loading TACCPAR table"
BCP_WAY="IN"
BCP_VER=""
BCP_FS=";"
BCP_TRUNCATE=YES
BCP_I="${DDML}/TACCPAR_UAT.csv"
BCP_TABLE="BTRAV..TACCPAR"
BCP

                                                                                    
JOBEND 
