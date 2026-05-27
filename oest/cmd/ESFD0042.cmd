#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESFD0042.cmd
# date de creation              : 27/01/2022
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description : send granularity files to SAP
#
#-----------------------------------------------------------------------------
# historiques des modifications
#=================================================================================================
#[001] 27/01/2022 JYP : Spira 101782 : Creation : send granularity files to SAP
#[002] 02/02/2022 JYP : Spira 101782 : keep que QTD quater files with products codes
#[003] 23/09/2022 JYP : Spira 106691 : remove product=retctr from OneGl/to
#[004] 28/09/2022 JYP : Spira 106691 : clean old products files OneGl/to
#[005] 07/08/2025 JYP : spira 113075 : SERQS split files by site 
#===============================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT




#--------------------------------------------------------------------------- 
NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="load mapping, specific chain for all NORME "
. ${DFILT}/${ENV_PREFIX}_ESFD0040_${IB}_ESFD0040_PERMFIL.dat


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> HOST_PRDSIT ...............: ${HOST_PRDSIT}"
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT ....................: ${IDF_CT} "
ECHO_LOG "#===> CONTEXT_CT ................: ${CONTEXT_CT} "
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> PARM_CRE_D.................: $PARM_CRE_D "
ECHO_LOG "#===> PARM_ICLODAT_D.............: $PARM_ICLODAT_D "

ECHO_LOG "#===>     -------- internal input ESFD0040  ---------"
ECHO_LOG "#===> ESF_FCTRI17PRD_NEW  .....: $ESF_FCTRI17PRD_NEW  "
ECHO_LOG "#===> ESF_FI17PRODUCT_NEW .....: $ESF_FI17PRODUCT_NEW "
ECHO_LOG "#===>     -------- external input from EBS/I4I/I17x : PRODUCTS Override  ---------"
ECHO_LOG "#===> ESF_FI17PRODUCT_OVR_MVT_I4I    ....: $ESF_FI17PRODUCT_OVR_MVT_I4I    "
ECHO_LOG "#===> ESF_FI17PRODUCT_OVR_EBS        ....: $ESF_FI17PRODUCT_OVR_EBS        "
ECHO_LOG "#===> ESF_FI17PRODUCT_OVR_I4I        ....: $ESF_FI17PRODUCT_OVR_I4I     "
ECHO_LOG "#===> ESF_FI17PRODUCT_OVR_I17G       ....: $ESF_FI17PRODUCT_OVR_I17G    "
ECHO_LOG "#===> ESF_FI17PRODUCT_OVR_I17P       ....: $ESF_FI17PRODUCT_OVR_I17P       "
ECHO_LOG "#===> ESF_FI17PRODUCT_OVR_I17L       ....: $ESF_FI17PRODUCT_OVR_I17L       "
ECHO_LOG "#===> ESF_FI17PRODUCT_OVR_PC_I4I     ....: $ESF_FI17PRODUCT_OVR_PC_I4I  "
ECHO_LOG "#===>     -------- external input from EBS/I4I/I17x : contract links Override  ---------"
ECHO_LOG "#===> ESF_FCTRI17PRD_OVR_EBS        ....: $ESF_FCTRI17PRD_OVR_EBS        "
ECHO_LOG "#===> ESF_FCTRI17PRD_OVR_I4I        ....: $ESF_FCTRI17PRD_OVR_I4I        "
ECHO_LOG "#===> ESF_FCTRI17PRD_OVR_PC_I4I     ....: $ESF_FCTRI17PRD_OVR_PC_I4I  "
ECHO_LOG "#===> ESF_FCTRI17PRD_OVR_I17G       ....: $ESF_FCTRI17PRD_OVR_I17G    "
ECHO_LOG "#===> ESF_FCTRI17PRD_OVR_I17P       ....: $ESF_FCTRI17PRD_OVR_I17P       "
ECHO_LOG "#===> ESF_FCTRI17PRD_OVR_I17L       ....: $ESF_FCTRI17PRD_OVR_I17L       "
ECHO_LOG "#===> ESF_FCTRI17PRD_OVR_MVT_I4I    ....: $ESF_FCTRI17PRD_OVR_MVT_I4I "
ECHO_LOG "#===>     -------- output  -----------------------------------------------"
ECHO_LOG "#===> ESF_FCTRI17PRD_SAP  ..............: $ESF_FCTRI17PRD_SAP     "
ECHO_LOG "#===> ESF_FI17PRODUCT_SAP ..............: $ESF_FI17PRODUCT_SAP    "
ECHO_LOG "#===> ESF_FI17PRODUCT_MRG ..............: $ESF_FI17PRODUCT_MRG "
ECHO_LOG "#===> ESF_FI17PRODUCT_QTD  .............: $ESF_FI17PRODUCT_QTD  "
ECHO_LOG "#===> ESF_FCTRI17PRD_QTD  ..............: $ESF_FCTRI17PRD_QTD  "
ECHO_LOG "#===> ESF_FCTRI17PRD_TOAS ..............: $ESF_FCTRI17PRD_TOAS "
ECHO_LOG "#===> ESF_FCTRI17PRD_TOEU  .............: $ESF_FCTRI17PRD_TOEU  "
ECHO_LOG "#===> ESF_FCTRI17PRD_TOAM ..............: $ESF_FCTRI17PRD_TOAM "
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_10
LIBEL="INITIALISATION touchs missing files "	
ECHO_LOG "#======= check product files OVR that are NOT mandatory"

if [[ ! -f ${ESF_FI17PRODUCT_OVR_MVT_I4I} ]] || [[ ! -f ${ESF_FI17PRODUCT_OVR_EBS} ]] || [[ ! -f ${ESF_FI17PRODUCT_OVR_I4I} ]] || [[ ! -f ${ESF_FCTRI17PRD_OVR_EBS} ]]
then
	EXECKSH_MODE=P
	EXECKSH "touch ${ESF_FI17PRODUCT_OVR_MVT_I4I}"
	EXECKSH_MODE=P
	EXECKSH "touch ${ESF_FI17PRODUCT_OVR_EBS}"
	EXECKSH_MODE=P
	EXECKSH "touch ${ESF_FI17PRODUCT_OVR_I4I}"	
	EXECKSH_MODE=P		
	EXECKSH "touch ${ESF_FCTRI17PRD_OVR_EBS}"	
fi

if [[ ! -f ${ESF_FI17PRODUCT_OVR_I17G} ]] || [[ ! -f ${ESF_FI17PRODUCT_OVR_PC_I4I} ]] || [[ ! -f ${ESF_FCTRI17PRD_OVR_I4I} ]] || [[ ! -f ${ESF_FI17PRODUCT_OVR_I17P} ]] || [[ ! -f ${ESF_FI17PRODUCT_OVR_I17L} ]]
then
	EXECKSH_MODE=P		
	EXECKSH "touch ${ESF_FI17PRODUCT_OVR_I17G}"		
	EXECKSH_MODE=P		
	EXECKSH "touch ${ESF_FI17PRODUCT_OVR_I17P}"	
	EXECKSH_MODE=P		
	EXECKSH "touch ${ESF_FI17PRODUCT_OVR_I17L}"		
	EXECKSH_MODE=P		
	EXECKSH "touch ${ESF_FI17PRODUCT_OVR_PC_I4I}"			
	EXECKSH_MODE=P		
	EXECKSH "touch ${ESF_FCTRI17PRD_OVR_I4I}"		
fi

if [[ ! -f ${ESF_FCTRI17PRD_OVR_PC_I4I} ]] || [[ ! -f ${ESF_FCTRI17PRD_OVR_I17G} ]] || [[ ! -f ${ESF_FCTRI17PRD_OVR_MVT_I4I} ]] || [[ ! -f ${ESF_FCTRI17PRD_OVR_I17P} ]] || [[ ! -f ${ESF_FCTRI17PRD_OVR_I17L} ]]
then
	EXECKSH_MODE=P		
	EXECKSH "touch ${ESF_FCTRI17PRD_OVR_PC_I4I}"
	EXECKSH_MODE=P		
	EXECKSH "touch ${ESF_FCTRI17PRD_OVR_MVT_I4I}"			
	EXECKSH_MODE=P		
	EXECKSH "touch ${ESF_FCTRI17PRD_OVR_I17G}"
	EXECKSH_MODE=P		
	EXECKSH "touch ${ESF_FCTRI17PRD_OVR_I17P}"
	EXECKSH_MODE=P		
	EXECKSH "touch ${ESF_FCTRI17PRD_OVR_I17L}"

fi



	
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="MERGE OVERRIDE Products files, remove duplicates from normes "
#------------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FI17PRODUCT_OVR_MVT_I4I}  2000 1"
SORT_I2="${ESF_FI17PRODUCT_OVR_EBS}  2000 1"
SORT_I3="${ESF_FI17PRODUCT_OVR_I4I}  2000 1"
SORT_I4="${ESF_FI17PRODUCT_OVR_I17G}  2000 1"
SORT_I5="${ESF_FI17PRODUCT_OVR_I17P}  2000 1"
SORT_I6="${ESF_FI17PRODUCT_OVR_I17L}  2000 1"
SORT_I7="${ESF_FI17PRODUCT_OVR_PC_I4I}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FI17PRODUCT_OVR_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

EXECKSH_MODE=P
EXECKSH "sort -u ${DFILT}/${NSTEP}_${IB}_FI17PRODUCT_OVR_ALL.dat > ${DFILT}/${NSTEP}_${IB}_FI17PRODUCT_OVR_ALL_UNIQ.dat    "
	
	
NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="MERGE OVERRIDE Products files and standard file"
#------------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_FI17PRODUCT_OVR_ALL_UNIQ.dat  2000 1"
SORT_I2="${ESF_FI17PRODUCT_NEW} 2000 1"
SORT_O="${ESF_FI17PRODUCT_MRG}  2000 1 overwrite"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT




NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="MERGE OVERRIDE contract links files, remove duplicates from normes "
#------------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCTRI17PRD_OVR_EBS}    2000 1"
SORT_I2="${ESF_FCTRI17PRD_OVR_I4I}    2000 1"
SORT_I3="${ESF_FCTRI17PRD_OVR_PC_I4I} 2000 1"
SORT_I4="${ESF_FCTRI17PRD_OVR_I17G}   2000 1"
SORT_I5="${ESF_FCTRI17PRD_OVR_I17P}   2000 1"
SORT_I6="${ESF_FCTRI17PRD_OVR_I17L}   2000 1"
SORT_I7="${ESF_FCTRI17PRD_OVR_MVT_I4I} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCTRI17PRD_OVR_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

EXECKSH_MODE=P
EXECKSH "sort -u ${DFILT}/${NSTEP}_${IB}_FCTRI17PRD_OVR_ALL.dat > ${DFILT}/${NSTEP}_${IB}_FCTRI17PRD_OVR_ALL_UNIQ.dat    "
	

	
NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="MERGE OVERRIDE contracts links files and standard file"
#------------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_FCTRI17PRD_OVR_ALL_UNIQ.dat 2000 1"
SORT_I2="${ESF_FCTRI17PRD_NEW} 2000 1"
SORT_O="${ESF_FCTRI17PRD_MRG}  2000 1 overwrite"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_55
#------------------------------------------------------------------------------
LIBEL="copy product link to all sites "
	EXECKSH_MODE=P
	EXECKSH "cp  ${ESF_FCTRI17PRD_MRG} ${ESF_FCTRI17PRD_TOAS} "
	EXECKSH_MODE=P
	EXECKSH "cp  ${ESF_FCTRI17PRD_MRG} ${ESF_FCTRI17PRD_TOEU} "
	EXECKSH_MODE=P
	EXECKSH "cp ${ESF_FCTRI17PRD_MRG} ${ESF_FCTRI17PRD_TOAM}"


EST_FCTRI17PRD_SAP_ZIP=`basename "${ESF_FCTRI17PRD_SAP%.*}"`
EST_FI17PRODUCT_SAP_ZIP=`basename "${ESF_FI17PRODUCT_SAP%.*}"`

if [ -s "${ESF_FCTRI17PRD_MRG}" ] 
then 

    NSTEP=${NJOB}_60
    LIBEL="Copy Product file"	
    EXECKSH "cp -a ${ESF_FCTRI17PRD_NEW} ${ESF_FCTRI17PRD_SAP}"

	NSTEP=${NJOB}_62
	LIBEL="Delete eventual old zip files"
	RMFIL "${DTRANSFER}/OneGL/to/${EST_FCTRI17PRD_SAP_ZIP}.zip"

	NSTEP=${NJOB}_65
	# ZIP
	#----------------------------------------------------------------------------
	LIBEL="Beginning of a ZIP session $ESF_FCTRI17PRD_SAP "
	ZIP_MODE="Z" 
	ZIP_ODIR="${DTRANSFER}/OneGL/to"  
	ZIP_I="${ESF_FCTRI17PRD_SAP}"
	ZIP_O="${EST_FCTRI17PRD_SAP_ZIP}.zip"
	ZIP_OPT=""
	ZIP

fi


if [ -s "${ESF_FI17PRODUCT_MRG}" ]
then
	NSTEP=${NJOB}_70
	LIBEL="Copy Product file"
	EXECKSH_MODE=P			 
	EXECKSH "cp -a ${ESF_FI17PRODUCT_NEW} ${ESF_FI17PRODUCT_SAP}"

	NSTEP=${NJOB}_72
	LIBEL="Delete eventual old zip files"
	RMFIL "${DTRANSFER}/OneGL/to/${EST_FI17PRODUCT_SAP_ZIP}.zip"

	NSTEP=${NJOB}_80
	# ZIP
	#----------------------------------------------------------------------------
	LIBEL="Beginning of a ZIP session $ESF_FI17PRODUCT_SAP "
	ZIP_MODE="Z" 
	ZIP_ODIR="${DTRANSFER}/OneGL/to"  
	ZIP_I="${ESF_FI17PRODUCT_SAP}"
	ZIP_O="${EST_FI17PRODUCT_SAP_ZIP}.zip"
	ZIP_OPT=""
	ZIP
fi
	

	
NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="QUATERLY files : keep a quater Product files "
#------------------------------------------------------------------------------

if [ -s "${ESF_FI17PRODUCT_MRG}" ]
then
	EXECKSH_MODE=P
	EXECKSH "cp $ESF_FI17PRODUCT_MRG  $ESF_FI17PRODUCT_QTD  "
fi 

if [ -s "${ESF_FCTRI17PRD_MRG}" ] 
then 
	EXECKSH_MODE=P
	EXECKSH "cp $ESF_FCTRI17PRD_MRG  $ESF_FCTRI17PRD_QTD  "
fi 
	
JOBEND

                     
