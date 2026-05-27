#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : Fusion des fichiers FTECLEDA_CUR et _MVT dans FTECLEDA
# nom du script SHELL           : ESID8701.cmd
# revision                      : 
# date de creation              : 15/03/2011
# auteur                        : R. Cassis
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  :spot:21408 - Fusion des fichiers FTECLEDA_CUR et FTECLEDA_MVT dans FTECLEDA final
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001]  08/09/2011  Roger Cassis   :spot:22435 - Suppression du step de delete du FTECLEDA_CUR.
#[002]  30/06/2015  DFI            :spot:28947 - filtre des analytiques dans la generation de l'interface 1GL
#[003]	07/09/2016	MMA			   :SPOT:31161 - SPIRA 53727 & 53733 : Verification des Poste analytique afin de les écarter
#[004]	19/08/2019	M.NAJI  	   :SPIRA ??? : optimisation changer les fichier binaire par des fichiers textes
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# No input parameters

# Job Initialisation
JOBINIT



ECHO_LOG "#===> EST_FTECLED_CUR ................ ${EST_FTECLED_CUR}"


NSTEP=${NJOB}_10
# Begin EXECKSH
#-------------------------------------------------------------------------------
LIBEL="Save ${EST_FTECLEDA_CUR}"
EXECKSH "cp ${EST_FTECLEDA_CUR} ${DSAV}/${SVG}_${NCHAIN}_EST_FTECLEDA_CUR.dat"

NSTEP=${NJOB}_20
# Begin EXECKSH
#-------------------------------------------------------------------------------
LIBEL="gzip ${DSAV}/${SVG}_${NCHAIN}_EST_FTECLEDA_CUR.dat"
EXECKSH "gzip ${DSAV}/${SVG}_${NCHAIN}_EST_FTECLEDA_CUR.dat"


JOBEND

