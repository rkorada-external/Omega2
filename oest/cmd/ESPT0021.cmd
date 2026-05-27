#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 renommage des fichier EST pour les traitements ecritures post omega
# nom du script SHELL		: ESPT-1_0.cmd
# revision			:
# date de creation		: 08/03/2021
# auteur			: M. NAJI
# references des specifications	: spot 91531
#-----------------------------------------------------------------------------
# description
#   Restore original name of ESPT* filed 
#
#
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd




cp -v `ls -t ${DFILI}/${ENV_PREFIX}_ESEH1110_FCESSION0*.dat | head -1`         					${DFILP}/${ENV_PREFIX}_ESEH1110_FCESSION0_POS_${DATE_DST}.dat                 
cp -v `ls -t ${DFILI}/${ENV_PREFIX}_ESEH1110_FCPLACC0*.dat | head -1`              				${DFILP}/${ENV_PREFIX}_ESEH1110_FCPLACC0_POS_${DATE_DST}.dat                  
cp -v `ls -t ${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING*.dat | head -1`         			${DFILP}/${ENV_PREFIX}_ESCJ0060_GAAPCOD_MAPPING_POS_${DATE_DST}.dat              
cp -v `ls -t ${DFILI}/${ENV_PREFIX}_ESEH1110_FCTRGRO0*.dat | head -1`      						${DFILP}/${ENV_PREFIX}_ESEH1110_FCTRGRO0_POS_${DATE_DST}.dat              
cp -v `ls -t ${DFILP}/${ENV_PREFIX}_ESEH1100_IADVPERICASE_I17P_P_INI_INV*.dat | head -1` 		${DFILP}/${ENV_PREFIX}_ESEH1100_IADVPERICASE_I17P_P_INI_POS_${DATE_DST}.dat
cp -v `ls -t ${DFILI}/${ENV_PREFIX}_ESID0060_FSEGPATTERN_CSF*.dat | head -1`					${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF_POS_${DATE_DST}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_GLOBAL_CASHFLOWSO_${DATE_DST}.dat          			${DFILP}/${ENV_PREFIX}_ESPD3610_GTSII_GLOBAL_CASHFLOWPOS_${DATE_DST}.dat    
cp -v ${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSIISO.dat  											${DFILP}/${ENV_PREFIX}_ESPD4000_GTEPSII_POS_${DATE_DST}.dat               
cp -v ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_EBS.dat  										${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_EBS_POS_${DATE_DST}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat  											${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_POS_${DATE_DST}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat  											${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDR_POS_${DATE_DST}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO.dat 										${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSII_POS_${DATE_DST}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYSO_${DATE_PREV}.dat 						${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGEST_SOLVENCYPOS_${DATE_PREV}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESPD3900_FSEGSTATSO.dat   											${DFILP}/${ENV_PREFIX}_ESPD3900_FSEGSTAT_I4I_POS_${DATE_DST}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF_${DATE_PREV}.dat 							${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_CSF_POS_${DATE_PREV}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_I17G_${DATE_PREV}.dat 					${DFILP}/${ENV_PREFIX}_ESFD1130_FSEGPATTERNDSCf17_I17G_POS_${DATE_PREV}.dat

# Ajouté le 08/03/2021
cp -v `ls -t /${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE0* | head -1         `  				${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE0_POS_${DATE_DST}.dat    
cp -v `ls -t /${DFILI}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0* | head -1         `  				${DFILP}/${ENV_PREFIX}_ESEH1100_IAVPERICASE0_POS_${DATE_DST}.dat             
cp -v `ls -t /${DFILI}/${ENV_PREFIX}_ESID0060_IRVPERICASE0* | head -1         `  				${DFILP}/${ENV_PREFIX}_ESID0060_IRVPERICASE0_POS_${DATE_DST}.dat             
cp -v `ls -t /${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_DUMMY* | head -1    `  				${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_DUMMYPOS_${DATE_DST}.dat         
cp -v `ls -t /${DFILI}/${ENV_PREFIX}_ESEH1100_IADPERICASE_DUMMY* | head -1    `  				${DFILP}/${ENV_PREFIX}_ESEH1100_IADPERICASE_DUMMYPOS_${DATE_DST}.dat         
cp -v ${DFILP}/${ENV_PREFIX}_ESPT0000_FPLACEMT0.dat          									${DFILP}/${ENV_PREFIX}_ESEH1110_FPLACEMT0_POS_${DATE_DST}.dat  
cp -v ${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____RARAT_POS_${DATE_DST}.dat         				${DFILP}/${ENV_PREFIX}_ESFD0060_I17G____RARAT_POS_${DATE_PREV}.dat 
cp -v ${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_ICR_${DATE_DST}.dat          					${DFILP}/${ENV_PREFIX}_ESPD0060_FSEGPATTERN_ICR_POS_${DATE_PREV}.dat   
cp -v ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_I17G_${DATE_PREV}.dat          			    ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_I17G_POS_${DATE_PREV}.dat 

#transition 
cp -v ${DFILP}/${ENV_PREFIX}_ESEH1100_IADVPERICASE_P_INI.dat          							${DFILP}/${ENV_PREFIX}_ESEH1100_IADVPERICASE_P_INIPOS_${DATE_DST}.dat 
