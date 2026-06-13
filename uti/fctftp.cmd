#==============================================================================
#nom de l'application          : bibliotheque technique
#nom du source                 : fctftp.cpl
#revision                      : $Revision: 1.1 $
#date de creation              : 05/26/1997
#auteur                        : C.G.I. ()
#references des specifications : #################
#------------------------------------------------------------------------------
#description :
#
#  Utilities calling standard programs (isql, bcp, syncsort, sqr, starpage, ...)
#  -----------------------------------------------------------------------------
#
#       - FTP_TEST
#       - FTP_PUT
#	- FTP_MGET
#	- FTP_MDEL
#	- FTP
#
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <22/05/2000>   <Guiheux>    <FTP_PUT: To make it compatible on Windows NT>
#
#----------------------------------------------------------------------------


#----------------------------------------------------------------------------

# Functions directory
DFUNCTION=${DUTI}/functions/fctftp

   . $DFUNCTION/FTP_PUT
   . $DFUNCTION/FTP_TEST
   . $DFUNCTION/FTP_MGET
   . $DFUNCTION/FTP_MDEL
   . $DFUNCTION/FTP_MDEL2
   . $DFUNCTION/FTP
