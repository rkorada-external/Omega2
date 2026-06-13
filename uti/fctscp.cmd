#==============================================================================
#nom de l'application          : bibliotheque technique
#nom du source                 : fctftp.cpl
#revision                      : $Revision: 1.1 $
#date de creation              : 05/26/1997
#auteur                        : Serge Raynaud - Alain Spinosa
#references des specifications : #################
#------------------------------------------------------------------------------
#description :
#
#  Utilities calling standard programs (isql, bcp, syncsort, sqr, starpage, ...)
#  -----------------------------------------------------------------------------
#
#   - SCP_TEST
#   - SCP_PUT
#   - SCP_GET
#   - SCP_MDEL
#   - SCP
#
#
#------------------------------------------------------------------------------
#historique des modifications :
#[001] 02/06/2015 R. cassis :spot:28843 Mise en commentaire des fonctions développées mais pas encore testées
#----------------------------------------------------------------------------


#----------------------------------------------------------------------------

# Functions directory
DFUNCTION=${DUTI}/functions/fctscp

   . $DFUNCTION/SCP_PUT
   #. $DFUNCTION/SCP_TEST -> Pas encore testée
   #. $DFUNCTION/SCP_GET  -> Pas encore testée
   #. $DFUNCTION/SCP_MDEL -> Pas encore testée
   . $DFUNCTION/SCP
