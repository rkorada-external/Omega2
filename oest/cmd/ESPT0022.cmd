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


#cp -v ${DFILP}/${ENV_PREFIX}_ESPD0060_EPOSII_POS_20201231.dat   ${DFILP}/${ENV_PREFIX}_ESPD0060_EPOSOCI.dat
cp -v ${DFILI}/${ENV_PREFIX}_ESID0060_FACCSUP0_${DATE_SRC}.dat   ${DFILP}/${ENV_PREFIX}_ESID0060_FACCSUP0_POS_${DATE_DST}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO.dat   ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_POC_${DATE_DST}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_I17G_${DATE_PREV}.dat   ${DFILP}/${ENV_PREFIX}_ESFD1130_TRERETFACCTR_I17G_POS_${DATE_PREV}.dat

cp -v ${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_CUR.dat		${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDA_CUR_I4I_INV_${DATE_SRC}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR_CUR.dat		${DFILP}/${ENV_PREFIX}_ESID3800_FTECLEDR_CUR_I4I_INV_${DATE_SRC}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_CUR.dat	${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_CUR_I4I_POS_${DATE_DST}.dat


cp -v ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat 		${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_I4I_POS_${DATE_DST}.dat
cp -v ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat		${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDR_I4I_POS_${DATE_DST}.dat

cp -v ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDACO.dat		${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDA_I4I_POC_${DATE_DST}.dat

cp -v ${DFILP}/${ENV_PREFIX}_ESPD3900_FCTRSTATSO.dat		${DFILP}/${ENV_PREFIX}_ESPD3900_FCTRSTAT_I4I_POS_${DATE_DST}.dat