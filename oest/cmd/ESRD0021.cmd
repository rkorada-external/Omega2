#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS Controle des operations internes
#                                 
# nom du script SHELL		: ESRD0021.cmd
# revision			: 
# date de creation		: 15/12/00
# auteur			: S Llorente
# references des specifications	: 
#-----------------------------------------------------------------------------
# Description
# Recuperation sur le site de paris des fichiers GTA et GTR cumules par postes 
# en provenance de paris, singapour et new-york. Stockage des fichiers zippes 
# dans ${DFILP}
#-----------------------------------------------------------------------------
# historique des modifications
#===============================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Parameters
DATE_T=$3


NSTEP=${NJOB}_00
# management of number of GTA files into $DFILI directory
#----------------------------------------------------------------------------
while [ $(ls ${DFILI}/${NCHAIN}_GTAINIO_${CURPOOL}_*.zip | wc -l ) -gt 2 ]
do
file=$(ls ${DFILI}/*_GTAINIO_${SITE}*.dat.Z.zip | head  -1 )
EXECKSH "rm $file"
done

NSTEP=${NJOB}_00
# management of number of GTR files into $DFILI directory
#----------------------------------------------------------------------------
while [ $(ls ${DFILI}/${NCHAIN}_GTRINIO_${CURPOOL}_*.zip | wc -l ) -gt 2 ]
do
file=$(ls ${DFILI}/*_GTRINIO_${SITE}*.dat.Z.zip | head  -1 )
EXECKSH "rm $file"
done



NSTEP=${NJOB}_10
# ZIP summarized GTA input files into $DFILI directory
#----------------------------------------------------------------------------
LIBEL="ZIP summarized GTA input files into $DFILI directory"
if [ -r "${DFILT}/${NJOB}_LOOP_${IB}_GTAOUTIO_${CURPOOL}.dat" ]
  then
    EXECKSH "mv ${DFILT}/${NJOB}_LOOP_${IB}_GTAOUTIO_${CURPOOL}.dat ${DFILT}/${NCHAIN}_GTAINIO_${CURPOOL}_${DATE_T}.dat"
    ZIP_ODIR=${DFILI} 
    ZIP_I="${DFILT}/${NCHAIN}_GTAINIO_${CURPOOL}_${DATE_T}.dat"
    ZIP_O="${NCHAIN}_GTAINIO_${CURPOOL}_${DATE_T}.dat.Z"
    ZIP_OPT=""
    ZIP_MODE="Z"
    ZIP	    
fi



NSTEP=${NJOB}_15
# ZIP summarized GTR input files into $DFILI directory
#----------------------------------------------------------------------------
LIBEL="ZIP summarized GTR input files into $DFILI directory"
if [ -r "${DFILT}/${NJOB}_LOOP_${IB}_GTROUTIO_${CURPOOL}.dat" ]
  then
    EXECKSH "mv ${DFILT}/${NJOB}_LOOP_${IB}_GTROUTIO_${CURPOOL}.dat ${DFILT}/${NCHAIN}_GTRINIO_${CURPOOL}_${DATE_T}.dat"
    ZIP_ODIR=${DFILI} 
    ZIP_I="${DFILT}/${NCHAIN}_GTRINIO_${CURPOOL}_${DATE_T}.dat"
    ZIP_O="${NCHAIN}_GTRINIO_${CURPOOL}_${DATE_T}.dat.Z"
    ZIP_OPT=""
    ZIP_MODE="Z"
    ZIP
fi

  

NSTEP=${NJOB}_20
# Begin RMFIL
#--------------------------------------------------------------------------
LIBEL="Remove of temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}_*.dat"


JOBEND
