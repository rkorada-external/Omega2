#==============================================================================
#nom de l'application          : bibliotheque technique
#nom du source                 : fctsftp.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : March 01 2016 
#auteur                        : Alain Spinosa 
#references des specifications : :spot:30348
#------------------------------------------------------------------------------
#description :
#  Utilities calling standard SFTP Utilities
#  -----------------------------------------------------------------------------
#
#	- FTP_PUT
#	- FTP_GET
#	- FTP
#
#
#------------------------------------------------------------------------------
#historique des modifications :
#
#----------------------------------------------------------------------------
# Functions directory
DFUNCTION=${DUTI}/functions/fctsftp

   . $DFUNCTION/SFTP_PUT
   . $DFUNCTION/SFTP_GET
   . $DFUNCTION/SFTP
