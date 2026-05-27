#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 renommage des fichier EST pour les traitements ecritures post omega
# nom du script SHELL		: ESPT-1_0.cmd
# revision			:
# date de creation		: 09/01/2021
# auteur			: M. NAJI
# references des specifications	: spot 91531
#-----------------------------------------------------------------------------
# description
#   Restore original name of ESPT* filed 
#
#
#-----------------------------------------------------------------------------
# historique des modifications
# 08/03/2021 M.NAJI spliter la chaine ESPT0010 en ESPT0010 et ESPT0020
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd


# Job Initialisation
JOBINIT

copy()
{
	EXECKSH $1
}

NSTEP=${NJOB}_05
#copy fichier ESTIMATION pour traitement post omega
#----------------------------------------------------------------------------
#LIBEL="copy fichier ESTIMATION pour traitement post omega"
cp -v ${EPO_CPLIFDRI}        		${EST_CPLIFDRI}
cp -v ${EPO_CRVPERICASE0}    		${EST_CRVPERICASE0}
cp -v ${EPO_CTRULT02}        		${EST_CTRULT02}                      
cp -v ${EPO_DCGTAALOA}       		${EST_DCGTAALOA}                     
cp -v ${EPO_DLCGTAAEPPE}     		${EST_DLCGTAAEPPE}                   
cp -v ${EPO_DLCGTAAREC}      		${EST_DLCGTAAREC}                    
cp -v ${EPO_DLCGTAA}         		${EST_DLCGTAA}                       
cp -v ${EPO_DLCUMGTAAS}      		${EST_DLCUMGTAAS}                    
cp -v ${EPO_DLCUMGTAA}       		${EST_DLCUMGTAA}                     
cp -v ${EPO_FCURSII}         		${EST_FCURSII}                       
cp -v ${EPO_FRATINGRTO}      		${EST_FRATINGRTO}                    
#cp -v ${EPO_FT_EBS}              	${EST_FT_EBS}                        
cp -v ${EPO_DLDGTAA_IFRS}    		${EST_DLDGTAA_IFRS}                  
cp -v ${EPO_DLGTAAFPRE}      		${EST_DLGTAAFPRE}                    
cp -v ${EPO_DLGTAAPA}        		${EST_DLGTAAPA}                      
cp -v ${EPO_DLGTAAPNAE}      		${EST_DLGTAAPNAE}                    
cp -v ${EPO_DLGTAAPRE}       		${EST_DLGTAAPRE}                     
cp -v ${EPO_DLGTAARPPE}      		${EST_DLGTAARPPE}                    
cp -v ${EPO_DLGTAATFPNAE}    		${EST_DLGTAATFPNAE}                  
cp -v ${EPO_FCES}            		${EST_FCES}
cp -v ${EPO_FCPLACC}         		${EST_FCPLACC}
cp -v ${EPO_FCTRGRO1}        		${EST_FCTRGRO1}                      
cp -v ${EPO_FCTRGRO}         		${EST_FCTRGRO}
cp -v ${EPO_FCTRSTAT}        		${EST_FCTRSTAT}
cp -v ${EPO_FCTRULT}         		${EST_FCTRULT}                       
cp -v ${EPO_FCURCVSNI}       		${EST_FCURCVSNI}
cp -v ${EPO_FCURCVSN}        		${EST_FCURCVSN}
cp -v ${EPO_FCURQUOT}        		${EST_FCURQUOT}
cp -v ${EPO_FDETTRS}         		${EST_FDETTRS}
cp -v ${EPO_FPLACEMT2}       		${EST_FPLACEMT2}  
cp -v ${EPO_FPLATXCUM}       		${EST_FPLATXCUM}
cp -v ${EPO_FPLC}            		${EST_FPLC}
cp -v ${EPO_FRETTRF}         		${EST_FRETTRF}
cp -v ${EPO_FSOBBLOB}        		${EST_FSOBBLOB}
cp -v ${EPO_FSSDACTR}        		${EST_FSSDACTR}
cp -v ${EPO_FTECLEDA}        		${EST_FTECLEDA}
cp -v ${EPO_FTECLEDR}        		${EST_FTECLEDR}
cp -v ${EPO_FTFAC}           		${EST_FTFAC}      
cp -v ${EPO_FTFAMCHG}        		${EST_FTFAMCHG}   
cp -v ${EPO_FTRSLNK}         		${EST_FTRSLNK}
cp -v ${EPO_FBOPRSLNK}       		${EST_FBOPRSLNK}  
cp -v ${EPO_FPRSMAP}         		${EST_FPRSMAP} 	
cp -v ${EPO_FTTR_PRM}        		${EST_FTTR_PRM}   
cp -v ${EPO_FVPLACEMT}       		${EST_FVPLACEMT}
cp -v ${EPO_IADPERICASE}     		${EST_IADPERICASE}
cp -v ${EPO_IADPERIFCI}      		${EST_IADPERIFCI} 
cp -v ${EPO_IADPERIFCT}      		${EST_IADPERIFCT} 
cp -v ${EPO_IADPERIFR}       		${EST_IADPERIFR}  
cp -v ${EPO_IADVPERICASE}    		${EST_IADVPERICASE}       
cp -v ${EPO_IARVPERICASE0}   		${EST_IARVPERICASE0}
cp -v ${EPO_LABOCY1}         		${EST_LABOCY1}            
cp -v ${EPO_OIADVPERICASE}   		${EST_OIADVPERICASE}
cp -v ${EPO_OIRDVPERICASE}   		${EST_OIRDVPERICASE}
#cp -v ${EPO_LIFSTAREP_AS}    		${EST_LIFSTAREP_AS}
#cp -v ${EPO_LIFSTAREP}       		${EST_LIFSTAREP}
cp -v ${EPO_FVENTNPANT}      		${EST_FVENTNPANT}			
cp -v ${EPO_FTVENTNP}        		${EST_FTVENTNP}			
cp -v ${EPO_IRDVPERICASE}    		${EST_IRDVPERICASE}		
cp -v ${EPO_FLIBEL2}   	   		${EST_FLIBEL2}				
cp -v ${EPO_FLIBEL1}   	   		${EST_FLIBEL1}				
cp -v ${EPO_FWHGTA}          		${EST_FWHGTA}             
cp -v ${EPO_FWHGTR}          		${EST_FWHGTR}             
cp -v ${EPO_SUBTRS}          		${EST_SUBTRS}             
cp -v ${EPO_SUBTRSESBPROP}   		${EST_SUBTRSESBPROP} 
cp -v ${EPO_SUBTRSBLOCKLIFEST}   	${EST_SUBTRSBLOCKLIFEST}
cp -v ${EPO_SUBTRSASSO}          	${EST_SUBTRSASSO}
cp -v ${EPO_SUBTRSBASE}          	${EST_SUBTRSBASE}
cp -v ${EPO_FCLIENT}             	${EST_FCLIENT}
cp -v ${EPO_FTHRHLDUWY}          	${EST_FTHRHLDUWY}           
cp -v ${EPO_DTSTATGTAA}          	${EST_DTSTATGTAA}           
cp -v ${EPO_FTRSLNK_TXT}        	${EST_FTRSLNK_TXT}          
cp -v ${EPO_FBOPRSLNK_TXT}      	${EST_FBOPRSLNK_TXT}        
cp -v ${EPO_FPRSMAP_TXT}        	${EST_FPRSMAP_TXT} 		
cp -v ${EPO_FCURQUOT_TXT}       	${EST_FCURQUOT_TXT} 		
cp -v ${EPO_FSSDACTR_TXT}       	${EST_FSSDACTR_TXT} 		
cp -v ${EPO_SUBTRS_TXT}         	${EST_SUBTRS_TXT} 			
cp -v ${EPO_SUBTRSESBPROP_TXT}  	${EST_SUBTRSESBPROP_TXT} 	
cp -v ${EPO_FCLIENT_TXT}        	${EST_FCLIENT_TXT} 		
cp -v ${EPO_FDETTRS_TXT}        	${EST_FDETTRS_TXT} 		
cp -v ${EPO_IRDPERICASE0}   	  	${EST_IRDPERICASE0}
cp -v ${EPO_FPLATXCUMALL}   	  	${EST_FPLATXCUMALL}
cp -v ${EPO_FTRANSCODE}   	  	${EST_FTRANSCODE}
cp -v ${EPO_FULTIMATES} 		${EST_FULTIMATES}
cp -v ${EPO_FPLACEMT0} 		${EST_FPLACEMT0}



#EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_CMGTAASO}"
#EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_CMGTARSO}"
#EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_CMGTRSO}"
#
##[023]
#if [ "${EST_FTRANSCODE}" != "" -a "${EPO_FTRANSCODE}" != "" ]
#then
#	EXECKSH "cp ${EST_FTRANSCODE}          ${EPO_FTRANSCODE}"                 
#fi
#
#NSTEP=${NJOB}_06 # [008]
## Begin execksh
##-----------------------------------------------------------------
#LIBEL="Vide les fichiers ..SO"
## Vide les fichiers
#if [ "${EPO_GTEPCO}" != "" -a "${EPO_GTEPSO}" != "" -a "${EPO_GTEPSIICO}" != "" -a "${EPO_GTEPSIISO}" != "" ]
#then
#	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_GTEPCO}"
#	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_GTEPSO}"
#	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_GTEPSIICO}"
#	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_GTEPSIISO}"
#fi
##[016]
#if [ "${EPO_DLEIGTAA}" != "" ]
#then
#	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_DLEIGTAA}"
#fi
#if [ "${EPO_DLRIGTAA}" != "" ]
#then
#	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_DLRIGTAA}"
#fi
#if [ "${EPO_DLRGTAA}" != "" ]
#then
#	EXECKSH "cp ${DFILT}/${ENV_PREFIX}_ESPT0000_vide.dat ${EPO_DLRGTAA}"
#fi
#
##[028]
#if [ "${EST_FULTIMATES}" != "" ]
#then
#	EXECKSH "cp ${EST_FULTIMATES} ${EPO_FULTIMATES}"
#fi
#
#
##[013]
#NSTEP=${NJOB}_10
##Generation of CADVPERIESB0 File
##-----------------------------------------------------------------------------
#LIBEL="Current Generation of CADVPERIESB0 Perimeter File..."
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O="$DFILT/${NSTEP}_${IB}_CADVPERIESB0_O.dat"
#BCP_QRY="select ctr_nf, end_nt,  uwy_nf, uw_nt, accesb_cf from bfac..tcontr a, BREF..TBATCHSSD b
#         where ctrsts_ct in ( 14, 16, 17, 19)
#         and   a.SSD_CF=b.SSD_CF
#         and   b.BATCHUSER_CF = suser_name()
#         select ctr_nf, end_nt,  uwy_nf, uw_nt, accesb_cf from btrt..tcontr a, BREF..TBATCHSSD b
#         where ctrsts_ct in ( 14, 16, 17, 19)
#         and   a.SSD_CF=b.SSD_CF
#         and   b.BATCHUSER_CF = suser_name()"
#BCP
#
#NSTEP=${NJOB}_15
## Begin sort
##------------------------------------------------------------------------------
#LIBEL="Sort of CADVPERIESB0 -> EST_CADVPERIESB0 perimeter file"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_10_${IB}_CADVPERIESB0_O.dat"
#SORT_O="${EPO_CADVPERIESB0}"
#INPUT_TEXT ${SORT_CMD} << EOF
#/FIELDS CTR_NF 1:1 - 1:,
# END_NT 2:1 - 2:,
# UWY_NF 3:1 - 3:,
# UW_NT  4:1 - 4:
#/KEYS CTR_NF,
# END_NT,
# UWY_NF,
# UW_NT
#exit
#EOF
#SORT
#
##[012]
#