#!/bin/ksh
#============================================================================
#nom de l'application          : TECHNICAL BATCH
#nom du source                 : RMFRPT00.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 20/03/1998
#auteur                        : SCOR
#squelette de base             :
#----------------------------------------------------------------------------
#description :
# This chain generates the daily batch report
# In the environment file the following variables must be defined:
#   - List of machine/directories couple containing RMF records
#        MACHINEx : Server name
#        DRMFIx   : Directory storing RMF records
#   - List of environment prefix/labels
#        ENVx     : Environnement prefix 
#        LABELx   : Environnement label
#
#----------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <auteur>   <description de la modification>
#    25/02/1999    JP          Redesign to include loop on environments/machines
#============================================================================


. ${DUTI}/fctgen.cmd
CHAININIT $0 $1

# Launch job
NJOB=RMFRPT01
${DUTI}/RMFRPT01.cmd  2>&1 | ${TEE}

CHAINEND
