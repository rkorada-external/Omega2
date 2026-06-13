#==============================================================================
#nom de l'application          : bibliotheque technique
#nom du source                 : fcttransfer.cpl
#revision                      : $Revision: 1.1 $
#date de creation              : 15/05/1997
#auteur                        : C.G.I. ()
#references des specifications : #################
#
#------------------------------------------------------------------------------
#description :
#   Generic functions that enable Data Transfers
#   -----------------------------------------------------
#
#	SEND_POOL ()	
#		get_extnum ()
#		get_tftpb ()
#		put_pool ()
#		send_pool_ssd ()
#		send_pool_ssdesb ()
#		send_pool_site ()	
#	LOOP_JOB_POOL ()	
#	CHECK_TFR ()	
#	CHECK_SITE ()	
#	GET_ZIP ()	
#	GET_FILES ()	
#	GET_ACK ()	
#	TEST_TFR_FILES ()	
#	STR_CAT ()	
#
#------------------------------------------------------------------------------
#historique des modifications :
#----------------------------------------------------------------------------


#----------------------------------------------------------------------------

# Functions directory
DFUNCTION=${DUTI}/functions/fcttransfer

   . $DFUNCTION/SEND_POOL
   . $DFUNCTION/LOOP_JOB_POOL
   . $DFUNCTION/LOOP_JOB_POOL_MFILE
   . $DFUNCTION/CHECK_TFR
   . $DFUNCTION/GET_ZIP
   . $DFUNCTION/TEST_TFR_FILES
   . $DFUNCTION/CHECK_SITE
   . $DFUNCTION/STR_CAT
   . $DFUNCTION/GET_FILES
   . $DFUNCTION/DEL_ZIP
   . $DFUNCTION/GET_SITES
