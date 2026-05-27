#!/bin/ksh
#=============================================================================
# nom de l'application          : CLOSING ESTIMATIONS
# date de creation              : 15/07/2025
# auteur                        : Mr JYP
#-----------------------------------------------------------------------------
# description : split TTECLEDR file by site 
#-----------------------------------------------------------------------------#
# Modifications
#[001] 15/07/2025 Mr JYP : US 5559 spira 113075 : SERQS split files by site
#[002] 01/08/2025 Mr JYP : US 5559 SERQS RA/SAP phase1 , do not update OPEN/CANCEL
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Job Initialisation
JOBINIT

ESF_FTECLEDR_MVT=$1		# FTECLEDR of current closing				
ESF_FTECLEDR_TOAS=$2    # output by site
ESF_FTECLEDR_TOEU=$3    # output by site
ESF_FTECLEDR_TOAM=$4    # output by site
ESF_FTECLEDR_FROMAS=$5  # input from other sites or NONE
ESF_FTECLEDR_FROMEU=$6  # input from other sites or NONE
ESF_FTECLEDR_FROMAM=$7  # input from other sites or NONE

ECHO_LOG "#========================================================"
ECHO_LOG "#===> ............ PARAMETERS ............................"
ECHO_LOG "#===> SITE...............................................: ${DEFAULT_SQL_LOGIN}"
ECHO_LOG "#===> EST_SORT_CONDITION_AS .............................: ${EST_SORT_CONDITION_AS}"
ECHO_LOG "#===> EST_SORT_CONDITION_AM .............................: ${EST_SORT_CONDITION_AM}"
ECHO_LOG "#===> EST_SORT_CONDITION_EU .............................: ${EST_SORT_CONDITION_EU}"
ECHO_LOG "#===> PARAM_DFILPAS .....................................: ${PARAM_DFILPAS}"
ECHO_LOG "#===> PARAM_DFILPEU .....................................: ${PARAM_DFILPEU}"
ECHO_LOG "#===> PARAM_DFILPAM .....................................: ${PARAM_DFILPAM}"


ECHO_LOG "#===> ............ INPUT ................................."
ECHO_LOG "#===> ESF_FTECLEDR_MVT ..............................: ${ESF_FTECLEDR_MVT}"
ECHO_LOG "#===> ESF_FTECLEDR_FROMAS ...........................: ${ESF_FTECLEDR_FROMAS}"
ECHO_LOG "#===> ESF_FTECLEDR_FROMEU ...........................: ${ESF_FTECLEDR_FROMEU}"
ECHO_LOG "#===> ESF_FTECLEDR_FROMAM ...........................: ${ESF_FTECLEDR_FROMAM}"
ECHO_LOG "#===> ............ OUTPUT ..............................."
ECHO_LOG "#===> ESF_FTECLEDR_TOAS ............................: ${ESF_FTECLEDR_TOAS}" 
ECHO_LOG "#===> ESF_FTECLEDR_TOEU ............................: ${ESF_FTECLEDR_TOEU}" 
ECHO_LOG "#===> ESF_FTECLEDR_TOAM ............................: ${ESF_FTECLEDR_TOAM}" 
ECHO_LOG "#========================================================"





NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="each quarter : need to initialise inputs from other sites  "
if [ ! -f $ESF_FTECLEDR_FROMAS ] ||   [ ! -f $ESF_FTECLEDR_FROMEU ] ||  [ ! -f $ESF_FTECLEDR_FROMAM ]
then
	EXECKSH_MODE=P
	EXECKSH "touch ${ESF_FTECLEDR_FROMAS}"
	EXECKSH_MODE=P
	EXECKSH "touch ${ESF_FTECLEDR_FROMEU}"	
	EXECKSH_MODE=P
	EXECKSH "touch ${ESF_FTECLEDR_FROMAM}"
fi 

	
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
# Merge inputs files 
#------------------------------------------------------------------------------
LIBEL="Merge input files "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR_MVT} 1000 1"
if [ -s "${ESF_FTECLEDR_FROMAM}" ] && ( [ "${DEFAULT_SQL_LOGIN}" = "ubas" ] || [ "${DEFAULT_SQL_LOGIN}" = "ubeu" ] ) 
then
   SORT_I2="${ESF_FTECLEDR_FROMAM} 1000 1"
fi
if [ -s "${ESF_FTECLEDR_FROMAS}" ] && ( [ "${DEFAULT_SQL_LOGIN}" = "ubam" ] || [ "${DEFAULT_SQL_LOGIN}" = "ubeu" ] ) 
then
   SORT_I3="${ESF_FTECLEDR_FROMAS} 1000 1"
fi
if [ -s "${ESF_FTECLEDR_FROMEU}" ] && ( [ "${DEFAULT_SQL_LOGIN}" = "ubam" ] || [ "${DEFAULT_SQL_LOGIN}" = "ubas" ] ) 
then
   SORT_I4="${ESF_FTECLEDR_FROMEU} 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_ALL_INPUT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT


#---- prepare clean of gaap+product only for external sites 
GAAP_CODE_AS="CODE_EMPTY"
GAAP_CODE_EU="CODE_EMPTY"
GAAP_CODE_AM="CODE_EMPTY" 
PRD_CODE_AS="CODE_EMPTY"
PRD_CODE_EU="CODE_EMPTY"
PRD_CODE_AM="CODE_EMPTY" 
		   
case "${DEFAULT_SQL_LOGIN}" in 
   "ubas") GAAP_CODE_AS="SAME_GAAP_CODE" 
           PRD_CODE_AS="SAME_PRD_CODE"  ;;
   "ubeu") GAAP_CODE_EU="SAME_GAAP_CODE"
           PRD_CODE_EU="SAME_PRD_CODE" ;;
   "ubam") GAAP_CODE_AM="SAME_GAAP_CODE" 
           PRD_CODE_AM="SAME_PRD_CODE" ;;
		*) GAAP_CODE_AS="SAME_GAAP_CODE"
           GAAP_CODE_EU="SAME_GAAP_CODE"
           GAAP_CODE_AM="SAME_GAAP_CODE" 
           PRD_CODE_AS="SAME_PRD_CODE"
           PRD_CODE_EU="SAME_PRD_CODE"
           PRD_CODE_AM="SAME_PRD_CODE" ;;
esac 

	   
NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="split by site "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`                 
SORT_I="${DFILT}/${NJOB}_20_${IB}_FTECLEDR_ALL_INPUT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_AS_O.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTECLEDR_EU_O.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_FTECLEDR_AM_O.dat 2000 1"
SORT_O4="${DFILT}/${NSTEP}_${IB}_FTECLEDR_OTHER_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  
SSD_CF          1:1 - 1: EN,
SAME_GAAP_CODE  64:1 - 64: ,
SAME_PRD_CODE   65:1 - 65: ,
FLAG_OA          67:1 - 67:,
FIELDS_1to63   1:1 - 63: ,
FIELDS_66to71 66:1 - 71: 
/DERIVEDFIELD CODE_EMPTY "~"
/CONDITION COND_NOT_OA   (FLAG_OA != "O" AND FLAG_OA != "A")
/DERIVEDFIELD PRODUCT_NEW_AS if COND_NOT_OA then $PRD_CODE_AS  else SAME_PRD_CODE
/DERIVEDFIELD PRODUCT_NEW_EU if COND_NOT_OA then $PRD_CODE_EU  else SAME_PRD_CODE
/DERIVEDFIELD PRODUCT_NEW_AM if COND_NOT_OA then $PRD_CODE_AM  else SAME_PRD_CODE
/DERIVEDFIELD GAAP_NEW_AS if COND_NOT_OA then $GAAP_CODE_AS  else SAME_GAAP_CODE
/DERIVEDFIELD GAAP_NEW_EU if COND_NOT_OA then $GAAP_CODE_EU  else SAME_GAAP_CODE
/DERIVEDFIELD GAAP_NEW_AM if COND_NOT_OA then $GAAP_CODE_AM  else SAME_GAAP_CODE
/CONDITION COND_ASIA   $EST_SORT_CONDITION_AS
/CONDITION COND_EUROPE $EST_SORT_CONDITION_EU
/CONDITION COND_USA    $EST_SORT_CONDITION_AM
/CONDITION COND_OTHER  $EST_SORT_CONDITION_AS OR $EST_SORT_CONDITION_EU OR  $EST_SORT_CONDITION_AM 
/OUTFILE ${SORT_O} overwrite
/INCLUDE COND_ASIA
/REFORMAT FIELDS_1to63  , GAAP_NEW_AS , PRODUCT_NEW_AS , FIELDS_66to71
/OUTFILE ${SORT_O2} overwrite
/INCLUDE COND_EUROPE
/REFORMAT FIELDS_1to63 , GAAP_NEW_EU , PRODUCT_NEW_EU , FIELDS_66to71
/OUTFILE ${SORT_O3} overwrite
/INCLUDE COND_USA
/REFORMAT FIELDS_1to63 , GAAP_NEW_AM , PRODUCT_NEW_AM , FIELDS_66to71
/OUTFILE ${SORT_O4} overwrite
/OMIT COND_OTHER
exit
EOF
SORT



NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Phase 1: Copy file ASIA  "
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_AS_O.dat ${PARAM_DFILPAS}/${ESF_FTECLEDR_TOAS}"
LIBEL="Phase 1: Copy file EU  "	
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_EU_O.dat ${PARAM_DFILPEU}/${ESF_FTECLEDR_TOEU}"
LIBEL="Phase 1: Copy file US  "
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_AM_O.dat ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOAM}"
	

# NSTEP=${NJOB}_50
# #------------------------------------------------------------------------------
# LIBEL="Phase 2 : Copy file ASIA  "
# 
# case "${DEFAULT_SQL_LOGIN}" in 
#    "ubas") 
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_EU_O.dat ${PARAM_DFILPEU}/${ESF_FTECLEDR_TOEU}"
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_AM_O.dat ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOAM}"
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_AS_O.dat ${PARAM_DFILPAS}/${ESF_FTECLEDR_TOAS}"  ;;
#    "ubeu")  
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_EU_O.dat ${PARAM_DFILPEU}/${ESF_FTECLEDR_TOEU}"
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_AM_O.dat ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOAM}"
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_AS_O.dat ${PARAM_DFILPEU}/${ESF_FTECLEDR_TOAS}"  ;; #====== ASIA processed by EU
#    "ubam")
#    	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_EU_O.dat ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOEU}"    #====== EU processed by AM
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_AM_O.dat ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOAM}"
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTECLEDR_AS_O.dat ${PARAM_DFILPAM}/${ESF_FTECLEDR_TOAS}"  ;; #====== ASIA processed by AM	
# esac ;
#  
   
ls -ltr ${PARAM_DFILPAS}/$ESF_FTECLEDR_TOAS ${PARAM_DFILPEU}/$ESF_FTECLEDR_TOEU ${PARAM_DFILPAM}/$ESF_FTECLEDR_TOAM



JOBEND
