#==============================================================================
#nom de l'application          : bibliotheque technique
#nom du source                 : fctdaemon.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 01/01/1997
#auteur                        : C.G.I. ()
#references des specifications : #################
#------------------------------------------------------------------------------
#description :
#   Generic functions associated to the daemon
#   ------------------------------------------
#
#       - SET_DAEMON_DIR
#       - FINDENV
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <05/12/1997>   <Guiheux>    <Specific functions for the daemon>
#
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# FUNCTION: SET_DAEMON_DIR
#
# 1 input parameter
# $1: Server Name
#
# Subject: Set Directories used Daemon
#----------------------------------------------------------------------------

SET_DAEMON_DIR() {
#set -x
# HG Modif du 15.11.97
return 0
}


#----------------------------------------------------------------------------
# FUNCTION: FINDENV() {
# Subject: Determines from command file which environment file must be used
# from the command filename
#----------------------------------------------------------------------------
FINDENV() {
#set -x
# HG Modif du 15.11.97
return 0

}


case $1 in
   SET_DAEMON_DIR) 
      SET_DAEMON_DIR  $2
      break;;
   FINDENV) 
      FINDENV
      break;;
esac

