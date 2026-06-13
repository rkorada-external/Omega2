#!/bin/ksh
#=============================================================================
#nom de l'application          : bibliotheque technique
#nom du source                 : fctprint.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 01/03/1997
#auteur                        : C.G.I. ()
#references des specifications : #################
#------------------------------------------------------------------------------
#description :
#       Generic functions that enable Step an Errors Handling
#
#       - LOOP_JOB
#       - LOOP_JOB_SSD
#       - LOOP_JOB_SSDESB
#       - LOOP_AS_PRINT 
#	- PRN
#       - PRN_WORD
#
#       Sub functions:
#	- LIST_SWITCH_SSDESB
#	- GET_SWITCH_SSDESB
#	- GET_PRTUNIX_NAME
#	- GET_PRTNOVELL_INFO
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <14/01/1997>   <Guiheux>    <Mise en place de commentaires>
#    06/03/2014     Florent      :spot:25427 centralisation, ajout de LOOP_AS_PRINT_SITE
#	 24/08/2021		Parth		 SPIRA 96246: Addition of TEXT2HTML. Add SCOR logo and banner to email communication
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------

# Functions directory
DFUNCTION=${DUTI}/functions/fctprint

   . $DFUNCTION/LOOP_JOB
   . $DFUNCTION/LOOP_AS_PRINT
   . $DFUNCTION/LOOP_AS_PRINT_SITE
   . $DFUNCTION/LOOP_JOB_SSD
   . $DFUNCTION/LOOP_JOB_SSDESB
   . $DFUNCTION/LOOP_JOB_SSDESB_CORP
   . $DFUNCTION/LOOP_JOB_SSD_CORP
   . $DFUNCTION/GET_PRTID_FROMSSD
   . $DFUNCTION/GET_PRTID_FROMUSER
   . $DFUNCTION/LIST_SWITCH_SSD_CORP
   . $DFUNCTION/LIST_SWITCH_SSD
   . $DFUNCTION/GET_SWITCH_SSD_CORP
   . $DFUNCTION/GET_SWITCH_SSD
   . $DFUNCTION/LIST_SWITCH_SSDESB_CORP
   . $DFUNCTION/LIST_SWITCH_SSDESB
   . $DFUNCTION/GET_SWITCH_SSDESB
   . $DFUNCTION/GET_SWITCH_SSDESB_CORP
   . $DFUNCTION/GET_PRTUNIX_NAME
   . $DFUNCTION/GET_LAG_FROMSSD
   . $DFUNCTION/GET_LAG_FROMUSER
   . $DFUNCTION/GET_PRTNOVELL_INFO
   . $DFUNCTION/GET_PRTSERVER_INFO
   . $DFUNCTION/PRN
   . $DFUNCTION/LOOP_PRN_SSD
   . $DFUNCTION/SENDMAIL
   . $DFUNCTION/GET_MAILID_FROMUSER
   . $DFUNCTION/TEXT2HTML
