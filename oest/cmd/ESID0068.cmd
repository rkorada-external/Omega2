#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION - INVENTAIRE
#                                 Extracting life tables
# nom du script SHELL           : ESID0068.cmd
# revision                      : $Revision: 1.1 $
# date de creation              : 29/07/2010
# auteur                        : T. RIPERT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   :spot:19177 - Extracting tables.
#-----------------------------------------------------------------------------
# historique des modifications
#[001] Florent     06.09.2011 :spot:22460 - ajout année bilan pour le job ESID0068
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT
# Parameters [001]
BALSHTYEA_NF=$1

NSTEP=${NJOB}_05
# Begin bcp
#------------------------------------------------------------------------------
LIBEL=""
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FFAMCNA}
BCP_QRY="execute BTRT..PsFAMCNA_04 ${BALSHTYEA_NF}"
BCP

JOBEND
