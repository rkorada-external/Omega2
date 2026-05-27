#!/bin/ksh
#=============================================================================
# nom de l'application          : Pericase
# nom du script SHELL           : ESFDMRG1.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 30/03/2023
# auteur                        : Mehdi NAJI
#-----------------------------------------------------------------------------
# description : Save files of exetended period 
#-----------------------------------------------------------------------------
# modif
#[01] 17/08/2023 : SPIRA 108961: M.Naji: P&C and Life- Closing output during local extended period
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

FILE_TO_MERGE=$1
FILE_GZ=$2

NSTEP=${NJOB}_05
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree ${EST_CURGTA}"
EXECKSH_MODE=W
EXECKSH_I=${FILE_TO_MERGE}
EXECKSH_O=${FILE_GZ}
EXECKSH "gzip -c "


JOBEND 
