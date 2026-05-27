#!/bin/ksh
#=============================================================================


#*****************************************************************************
#Description : SPIRA 84653 add date in some mappings : micro AOC- EBS and IFRS17 
#Author      : JYP
#Date        : 19/03/2020
#*****************************************************************************/

#-----------------------------------------------------------------------------------------------------------
#--[001] 03/04/2020 JYP : SPIRA 84653 : add FMARKET file
#--[002] 14/04/2020 JYP : SPIRA 84653 : display warning when I17G files are missing


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


CHAININIT CNLD0030 $DENV/CNLD0030.env

#set -x

PARAM_DATE=$2

# Get the parameters
export EST_PARAM=${DFILP}/${ENV_PREFIX}_ESCJ0000_PARM2.dat
set `GETPRM ${EST_PARAM}`

if [ "$PARM_DATE" != "" ]
then 
	PARM_ICLODAT_D=$PARAM_DATE
else
	PARM_ICLODAT_D=$7
fi

if [ ! -f ${DFILP}/${ENV_PREFIX}_ESCJ0000_PARM2.dat -o "${PARM_ICLODAT_D}" != "" ]
then
	echo "rename with PARM_ICLODAT_D=$PARM_ICLODAT_D "  >> $FLOG
	echo "rename with PARM_ICLODAT_D=$PARM_ICLODAT_D "
else
	echo "error cannot use PARM_ICLODAT_D=$PARM_ICLODAT_D file=${DFILP}/${ENV_PREFIX}_ESCJ0000_PARM2.dat  "  >> $FLOG
	echo "error cannot use PARM_ICLODAT_D=$PARM_ICLODAT_D file=${DFILP}/${ENV_PREFIX}_ESCJ0000_PARM2.dat  "   
    exit 11
fi



NSTEP=${NCHAIN}_${NJOB}_01
LIBEL="renommage de fichiers , ajout date EBS "
echo "$NSTEP : $LIBEL ...."  >> $FLOG
echo "$NSTEP : $LIBEL ...."  


cp -p $DFILP/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF.dat                     $DFILT/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF.dat_save$$                           
cp -p $DFILP/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC.dat                     $DFILT/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC.dat_save$$                
cp -p $DFILP/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYSO.dat                  $DFILT/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYSO.dat_save$$             
cp -p $DFILP/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYCO.dat                  $DFILT/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYCO.dat_save$$             
cp -p $DFILP/${ENV_PREFIX}_ESPD0060_FULAERATCO.dat                          $DFILT/${ENV_PREFIX}_ESPD0060_FULAERATCO.dat_save$$                     
cp -p $DFILP/${ENV_PREFIX}_ESPD0060_FULAERATSO.dat                          $DFILT/${ENV_PREFIX}_ESPD0060_FULAERATSO.dat_save$$                     
cp -p $DFILP/${ENV_PREFIX}_ESPT0000_IADPERICASE.dat                         $DFILT/${ENV_PREFIX}_ESPT0000_IADPERICASE.dat_save$$                    
cp -p $DFILP/${ENV_PREFIX}_ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO.dat     $DFILT/${ENV_PREFIX}_ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO.dat_save$$
cp -p $DFILP/${ENV_PREFIX}_ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO.dat        $DFILT/${ENV_PREFIX}_ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO.dat_save$$   
cp -p $DFILP/${ENV_PREFIX}_ESPT0000_FPRSMAP.dat                             $DFILT/${ENV_PREFIX}_ESPT0000_FPRSMAP.dat_save$$
cp -p $DFILP/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_EXPENSES.dat           $DFILT/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_EXPENSES.dat_save$$      
cp -p $DFILP/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_STD_EXPENSES.dat           $DFILT/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_STD_EXPENSES.dat_save$$      
cp -p $DFILI/${ENV_PREFIX}_ESFD0060_FMARKET.dat                             $DFILT/${ENV_PREFIX}_ESFD0060_FMARKET.dat_sav$$ 

mv $DFILP/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF.dat                     $DFILP/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat                              
mv $DFILP/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC.dat                     $DFILP/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat                  
mv $DFILP/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYSO.dat                  $DFILP/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat               
mv $DFILP/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYCO.dat                  $DFILP/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat               
mv $DFILP/${ENV_PREFIX}_ESPD0060_FULAERATCO.dat                          $DFILP/${ENV_PREFIX}_ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat                       
mv $DFILP/${ENV_PREFIX}_ESPD0060_FULAERATSO.dat                          $DFILP/${ENV_PREFIX}_ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat                       
mv $DFILP/${ENV_PREFIX}_ESPT0000_IADPERICASE.dat                         $DFILP/${ENV_PREFIX}_ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat                      
mv $DFILP/${ENV_PREFIX}_ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO.dat     $DFILP/${ENV_PREFIX}_ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat  
mv $DFILP/${ENV_PREFIX}_ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO.dat        $DFILP/${ENV_PREFIX}_ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat     
mv $DFILP/${ENV_PREFIX}_ESPT0000_FPRSMAP.dat                             $DFILP/${ENV_PREFIX}_ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat                          
mv $DFILP/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_EXPENSES.dat           $DFILP/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_EXPENSES_${PARM_ICLODAT_D}.dat        
mv $DFILP/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_STD_EXPENSES.dat           $DFILP/${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_STD_EXPENSES_${PARM_ICLODAT_D}.dat        
mv $DFILI/${ENV_PREFIX}_ESFD0060_FMARKET.dat                             $DFILP/${ENV_PREFIX}_ESFD0060_FMARKET_${PARM_ICLODAT_D}.dat 

cd $DFILP
ls -ltr ${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF_${PARM_ICLODAT_D}.dat ${ENV_PREFIX}_ESPD0060_FSEGPATTERN_DSC_${PARM_ICLODAT_D}.dat  ${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYSO_${PARM_ICLODAT_D}.dat ${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYCO_${PARM_ICLODAT_D}.dat ${ENV_PREFIX}_ESPD0060_FULAERATCO_${PARM_ICLODAT_D}.dat  ${ENV_PREFIX}_ESPD0060_FULAERATSO_${PARM_ICLODAT_D}.dat  ${ENV_PREFIX}_ESPT0000_IADPERICASE_${PARM_ICLODAT_D}.dat ${ENV_PREFIX}_ESPD3610_GTSII_REMAINTOPAY_ULAEINF_SIISO_${PARM_ICLODAT_D}.dat ${ENV_PREFIX}_ESPD3610_GTSII_REMAINTOPAY_ULAE_SIICO_${PARM_ICLODAT_D}.dat   ${ENV_PREFIX}_ESPT0000_FPRSMAP_${PARM_ICLODAT_D}.dat 
RC=$?

ls -ltr ${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_INI_EXPENSES_${PARM_ICLODAT_D}.dat  ${ENV_PREFIX}_ESFD3630_I17G_IEX_ALL_STD_EXPENSES_${PARM_ICLODAT_D}.dat  ${ENV_PREFIX}_ESFD0060_FMARKET_${PARM_ICLODAT_D}.dat 
RCI17G=$?
cd - 


if [ ! $RCI17G -eq 0 ]
then
	echo "warning : files I17G missings could be nornal : FMARKET EXPENSES  "
	echo "warning : files I17G missings could be nornal : FMARKET EXPENSES  " >> $FLOG
fi	


if [ $RC -eq 0 ]
then
	echo "End $0 $PARM_ICLODAT_D finished OK  "
	echo "End $0 $PARM_ICLODAT_D finished OK  " >> $FLOG
else
	echo "ERROR : some files were NOT renamed , please check logs "  >> $FLOG
	echo "ERROR : some files were NOT renamed , please check logs "  
    exit 12
fi



set +x


CHAINEND





