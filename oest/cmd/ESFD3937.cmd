#!/bin/ksh
#=============================================================================
# nom de l'application          : CLOSING ESTIMATIONS
# date de creation              : 05/08/2025
# auteur                        : Mr JYP
#-----------------------------------------------------------------------------
# description : split SII file by site 
#-----------------------------------------------------------------------------#
# Modifications
# [001] 06/08/2025 : Mr JYP : US 5559 : SERQS split files by site
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Job Initialisation
JOBINIT

ESF_FTCLEDSII_MVT=$1	 # FTCLEDSII of current closing				
ESF_FTCLEDSII_TOAS=$2    # output by site
ESF_FTCLEDSII_TOEU=$3    # output by site
ESF_FTCLEDSII_TOAM=$4    # output by site
ESF_FTCLEDSII_FROMAS=$5  # input from other sites or NONE
ESF_FTCLEDSII_FROMEU=$6  # input from other sites or NONE
ESF_FTCLEDSII_FROMAM=$7  # input from other sites or NONE

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
ECHO_LOG "#===> ESF_FTCLEDSII_MVT ..............................: ${ESF_FTCLEDSII_MVT}"
ECHO_LOG "#===> ESF_FTCLEDSII_FROMAS ...........................: ${ESF_FTCLEDSII_FROMAS}"
ECHO_LOG "#===> ESF_FTCLEDSII_FROMEU ...........................: ${ESF_FTCLEDSII_FROMEU}"
ECHO_LOG "#===> ESF_FTCLEDSII_FROMAM ...........................: ${ESF_FTCLEDSII_FROMAM}"
ECHO_LOG "#===> ............ OUTPUT ..............................."
ECHO_LOG "#===> ESF_FTCLEDSII_TOAS ............................: ${ESF_FTCLEDSII_TOAS}" 
ECHO_LOG "#===> ESF_FTCLEDSII_TOEU ............................: ${ESF_FTCLEDSII_TOEU}" 
ECHO_LOG "#===> ESF_FTCLEDSII_TOAM ............................: ${ESF_FTCLEDSII_TOAM}" 
ECHO_LOG "#========================================================"





NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="each quarter : need to initialise inputs from other sites  "
if [ ! -f $ESF_FTCLEDSII_FROMAS ] ||   [ ! -f $ESF_FTCLEDSII_FROMEU ] ||  [ ! -f $ESF_FTCLEDSII_FROMAM ]
then
	EXECKSH_MODE=P
	EXECKSH "touch ${ESF_FTCLEDSII_FROMAS}"
	EXECKSH_MODE=P
	EXECKSH "touch ${ESF_FTCLEDSII_FROMEU}"	
	EXECKSH_MODE=P
	EXECKSH "touch ${ESF_FTCLEDSII_FROMAM}"
fi 


if [ ! -f $ESF_FTCLEDSII_MVT ] 
then 
	EXECKSH_MODE=P
	EXECKSH "touch $ESF_FTCLEDSII_MVT " 
fi 

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
# Merge inputs files 
#------------------------------------------------------------------------------
LIBEL="Merge input files "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTCLEDSII_MVT} 1000 1"
if [ -s "${ESF_FTCLEDSII_FROMAM}" ] && ( [ "${DEFAULT_SQL_LOGIN}" = "ubas" ] || [ "${DEFAULT_SQL_LOGIN}" = "ubeu" ] ) 
then
   SORT_I2="${ESF_FTCLEDSII_FROMAM} 1000 1"
fi
if [ -s "${ESF_FTCLEDSII_FROMAS}" ] && ( [ "${DEFAULT_SQL_LOGIN}" = "ubam" ] || [ "${DEFAULT_SQL_LOGIN}" = "ubeu" ] ) 
then
   SORT_I3="${ESF_FTCLEDSII_FROMAS} 1000 1"
fi
if [ -s "${ESF_FTCLEDSII_FROMEU}" ] && ( [ "${DEFAULT_SQL_LOGIN}" = "ubam" ] || [ "${DEFAULT_SQL_LOGIN}" = "ubas" ] ) 
then
   SORT_I4="${ESF_FTCLEDSII_FROMEU} 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_FTCLEDSII_ALL_INPUT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

	   
NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="split by site "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`                 
SORT_I="${DFILT}/${NJOB}_20_${IB}_FTCLEDSII_ALL_INPUT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTCLEDSII_AS_O.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTCLEDSII_EU_O.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_FTCLEDSII_AM_O.dat 2000 1"
SORT_O4="${DFILT}/${NSTEP}_${IB}_FTCLEDSII_OTHER_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  
SSD_CF          1:1 - 1: EN,
ALL_FIELDS      1:1 - 106: 
/CONDITION COND_ASIA   $EST_SORT_CONDITION_AS
/CONDITION COND_EUROPE $EST_SORT_CONDITION_EU
/CONDITION COND_USA    $EST_SORT_CONDITION_AM
/CONDITION COND_OTHER  $EST_SORT_CONDITION_AS OR $EST_SORT_CONDITION_EU OR  $EST_SORT_CONDITION_AM 
/OUTFILE ${SORT_O} overwrite
/INCLUDE COND_ASIA
/OUTFILE ${SORT_O2} overwrite
/INCLUDE COND_EUROPE
/OUTFILE ${SORT_O3} overwrite
/INCLUDE COND_USA
/OUTFILE ${SORT_O4} overwrite
/OMIT COND_OTHER
exit
EOF
SORT



NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Phase 1: Copy file ASIA  "
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_AS_O.dat ${PARAM_DFILPAS}/${ESF_FTCLEDSII_TOAS}"
LIBEL="Phase 1: Copy file EU  "	
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_EU_O.dat ${PARAM_DFILPEU}/${ESF_FTCLEDSII_TOEU}"
LIBEL="Phase 1: Copy file US  "
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_AM_O.dat ${PARAM_DFILPAM}/${ESF_FTCLEDSII_TOAM}"
	

# NSTEP=${NJOB}_50
# #------------------------------------------------------------------------------
# LIBEL="Phase 2 : Copy file ASIA  "
# 
# case "${DEFAULT_SQL_LOGIN}" in 
#    "ubas") 
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_EU_O.dat ${PARAM_DFILPEU}/${ESF_FTCLEDSII_TOEU}"
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_AM_O.dat ${PARAM_DFILPAM}/${ESF_FTCLEDSII_TOAM}"
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_AS_O.dat ${PARAM_DFILPAS}/${ESF_FTCLEDSII_TOAS}"  ;;
#    "ubeu")  
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_EU_O.dat ${PARAM_DFILPEU}/${ESF_FTCLEDSII_TOEU}"
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_AM_O.dat ${PARAM_DFILPAM}/${ESF_FTCLEDSII_TOAM}"
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_AS_O.dat ${PARAM_DFILPEU}/${ESF_FTCLEDSII_TOAS}"  ;; #====== ASIA processed by EU
#    "ubam")
#    	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_EU_O.dat ${PARAM_DFILPAM}/${ESF_FTCLEDSII_TOEU}"    #====== EU processed by AM
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_AM_O.dat ${PARAM_DFILPAM}/${ESF_FTCLEDSII_TOAM}"
# 	EXECKSH_MODE=P
# 	EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_FTCLEDSII_AS_O.dat ${PARAM_DFILPAM}/${ESF_FTCLEDSII_TOAS}"  ;; #====== ASIA processed by AM	
# esac ;
#  
   
ls -ltr ${PARAM_DFILPAS}/$ESF_FTCLEDSII_TOAS ${PARAM_DFILPEU}/$ESF_FTCLEDSII_TOEU ${PARAM_DFILPAM}/$ESF_FTCLEDSII_TOAM




JOBEND
