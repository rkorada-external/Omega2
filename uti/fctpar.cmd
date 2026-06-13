#!/bin/ksh
#==============================================================================
#nom de l'application          : bibliotheque technique
#nom du source                 : fctpar.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 05/26/1997
#auteur                        : C.G.I. ()
#references des specifications : #################
#------------------------------------------------------------------------------
#description :
#
#  Utilities allowing steps running parallelized
#  -----------------------------------------------------------------------------
#
#
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <Guiheux>    <description de la modification>
#
#----------------------------------------------------------------------------


#----------------------------------------------------------------------------

# Functions directory
DFUNCTION=${DUTI}/functions/fctpar

   . $DFUNCTION/PARALLEL_INIT
   . $DFUNCTION/PARALLEL_MANAGE_ACTIVE_PROCESS
   . $DFUNCTION/PARALLEL
   . $DFUNCTION/PARALLEL_END
   . $DFUNCTION/PARALLEL_JOB_INIT
   . $DFUNCTION/PARALLEL_JOB
   . $DFUNCTION/PARALLEL_JOB_END
