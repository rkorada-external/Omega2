#=============================================================================
#nom de l'application          : bibliotheque technique
#nom du source                 : fctgen.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 01/01/1997
#auteur                        : C.G.I. ()
#references des specifications : #################
#------------------------------------------------------------------------------
#description :
#   Generic functions that enable Step an Errors Handling
#   -----------------------------------------------------
#
#       - CHAININIT
#       - CHAININIT_SYB
#       - CHAINEND
#
#       - JOBINIT
#       - JOBEND
#
#       - SUBJOBINIT
#       - SUBJOBEND
#
#       - STEPSTART
#       - STEPWARNING
#       - STEPEND
#
#       - EXCEPTION
#       - EXCEPTION_INIT
#       - EXCEPTION_END
#
#       - LOGWRITE
#
#       - SIZEOF 
#       - RMFIL
#       - SWITCH_SRV
#
#
#	Sub functions:
#           - INSTANCEINIT
#           - SETENV
#           - CHAINLOGWRITEHEADER 
#           - CHAINLOGWRITEFOOTER
#
#  Utilities calling standard programs (isql, bcp, syncsort, sqr, starpage, ...)
#  -----------------------------------------------------------------------------
#
# 	- BCP ( ->BCPIN, BCPINMULTI, BCPOUT, BCPOUTMULTI) 
# 	- ISQL
#	- SORT
#	- SQR
#       - ZIP
#       - MD5
#
# Generic Sql Server functions
# ----------------------------
#
#       - GET_SQL_LOGIN_PSWD
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <mm/jj/aaaa>   <Guiheux>    <description de la modification>
#   <03/03/1997>   <Guiheux>    <New functions added>
#   <04/29/1997>   <Guiheux>    <old fctuti.cmd and fctsyb.cmd are included>
#   <09/12/2013>   <JBG>        <Add UPDATE_INDEX_STAT and TRUNCATE_TABLE functions>
#   <22/01/2014>   <PAV>        <Add DECRYPT_PASSWD and ENCRYPT_PASSWD functions>
#   <29/07/2016>   <Florent>    <:spot:30978 Added GZIPM>
#   <04/08/2025>   <Sir JYP>    <:US:5559 Add GETPRM0 optimized>
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#set -x
# Functions directory
DFUNCTION=${DUTI}/functions/fctgen

   . $DFUNCTION/GETPRM
   . $DFUNCTION/GETPRMO
   . $DFUNCTION/INSTANCEINIT
   . $DFUNCTION/CHAINLOGWRITEHEADER
   . $DFUNCTION/CHAINLOGWRITEFOOTER
   . $DFUNCTION/CHAININIT_SYB
   . $DFUNCTION/CHAININIT
   . $DFUNCTION/CHAINEND
   . $DFUNCTION/CHAINSTOP
   . $DFUNCTION/EXCEPTION
   . $DFUNCTION/EXCEPTION_INIT
   . $DFUNCTION/EXCEPTION_END
   . $DFUNCTION/ECHO_LOG
   . $DFUNCTION/APPEND_LOG
   . $DFUNCTION/JOBINIT
   . $DFUNCTION/JOBEND
   . $DFUNCTION/STEPSTART
   . $DFUNCTION/IDENTIFY_WARNING
   . $DFUNCTION/STEPWARNING
   . $DFUNCTION/STEPEND
   . $DFUNCTION/STEPSTART_FORCE
   . $DFUNCTION/LOGWRITE
   . $DFUNCTION/SIZEOF
   . $DFUNCTION/RMFIL
   . $DFUNCTION/SWITCH_SYB_VERSION
   . $DFUNCTION/SWITCH_SRV
   . $DFUNCTION/FIND_SVC_LOGIN
   . $DFUNCTION/FIND_SQL_LOGIN_PSWD
   . $DFUNCTION/GET_SQL_LOGIN_PSWD
   . $DFUNCTION/SET_SQL_LOGIN
   . $DFUNCTION/INPUT_TEXT
   . $DFUNCTION/CFTMP
   . $DFUNCTION/ANTISLASH_SLASH
   . $DFUNCTION/DOUBLE_ANTISLASH
   . $DFUNCTION/CREATE_RANDOMUSER
   . $DFUNCTION/BCP
   . $DFUNCTION/BCPIN
   . $DFUNCTION/BCPINMULTI
   . $DFUNCTION/BCPOUT
   . $DFUNCTION/BCPOUTMULTI
   . $DFUNCTION/ISQL
   . $DFUNCTION/SORT
   . $DFUNCTION/SQR
   . $DFUNCTION/DEBUGPRG
   . $DFUNCTION/DECRYPT_PASSWD
   . $DFUNCTION/ENCRYPT_PASSWD
   . $DFUNCTION/EXECPRG
   . $DFUNCTION/EXECKSH
   . $DFUNCTION/AWK
   . $DFUNCTION/ISQL_INFO
   . $DFUNCTION/ISQL_RES
   . $DFUNCTION/ZIP
   . $DFUNCTION/PKUNZIP
   . $DFUNCTION/PKZIP
   . $DFUNCTION/CONVDATE
   . $DFUNCTION/SUBJOBINIT
   . $DFUNCTION/SUBJOBEND
   . $DFUNCTION/BCPLOAD
   . $DFUNCTION/LAPS_RMF
   . $DFUNCTION/MD5
   . $DFUNCTION/UPDATE_INDEX_STAT
   . $DFUNCTION/TRUNCATE_TABLE
   . $DFUNCTION/GZIPM
   . $DFUNCTION/MAJOB
   . $DFUNCTION/GETV
   . $DFUNCTION/ISQL_RSLT 
   . $DFUNCTION/ZIP_FILES
   . $DFUNCTION/EXTRACT
   