#!/bin/ksh
#=============================================================================
# nom de l'application          : CLOSING ESTIMATIONS
# date de creation              : 09/06/2023
# auteur                        : Mr JYP
#-----------------------------------------------------------------------------
# description :
#              update TTECLEDA.NEWCOLS1_NF for all norms (LOCAL too)
#-----------------------------------------------------------------------------#
# Modifications
# [001] 09/06/2023 : JYP : spira 109764 : update NEWCOLS1_NF=DBCLO_D, GEMPRMPAY_NF=empty 
# [002] 18/07/2023 : JYP : spira 109764 : update NEWCOLS1_NF=CRE_D instead of DBCLO_D
# [003] 18/09/2023 : JYP : spira:110487 : clean SAP fields and NEWCOLS1 for remain files
# [004] 19/02/2025 : JYP : spira 112710 : optimisation step 30
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

PARM_NORM_CRE_D=$1   # when calling, each norm have a different viariable
PARM_LOCAL_RULE=$2   # for LOCAL , not same rules as other norms 
PARM_REMAIN_FILE=$3  # for remaining files, update all to empty 

# Job Initialisation
JOBINIT


ECHO_LOG "#========================================================"
ECHO_LOG "#===> ............ PARAMETERS ............................"
ECHO_LOG "#===> NORME_CF...........................................: ${NORME_CF}"
ECHO_LOG "#===> PARM_IS_COMPTA    .................................: ${PARM_IS_COMPTA}"
ECHO_LOG "#===> PARAM_IS_SAP_POSTING ..............................: ${PARAM_IS_SAP_POSTING}"
ECHO_LOG "#===> PARM_LOCAL_RULE        ............................: ${PARM_LOCAL_RULE}"
ECHO_LOG "#===> PARM_REMAIN_FILE       ............................: ${PARM_REMAIN_FILE}"
ECHO_LOG "#===> PARM_NORM_CRE_D      ..............................: ${PARM_NORM_CRE_D}"
ECHO_LOG "#===> ............ INPUT ................................"
ECHO_LOG "#===> ESF_FTECLEDA_DELTA.................................: ${ESF_FTECLEDA_DELTA}"
ECHO_LOG "#===> ............ OUTPUT ..............................."
ECHO_LOG "#===> ESF_FTECLEDA_DELTA.................................: ${ESF_FTECLEDA_DELTA}"
ECHO_LOG "#========================================================"





if [ ! -s "${ESF_FTECLEDA_DELTA}" ]
then
    echo  -e "\nfile ESF_FTECLEDA_DELTA is empty, nothing to update !! \n" 
    ECHO_LOG "\nfile ESF_FTECLEDA_DELTA is empty, nothing to update  !! \n"
	JOBEND
fi
		

#-- NEWCOLS1 rules
if [[ "$PARM_REMAIN_FILE" = "Y" ]] 
then 
	NEWCOLS1_NF=""
else 
	if [[ "${PARM_IS_COMPTA}" = "Y" || "${PARAM_IS_SAP_POSTING}" = "Y" || "${PARM_LOCAL_RULE}" = "Y" ]]
	then
		NEWCOLS1_NF="$PARM_NORM_CRE_D"
	else 
		NEWCOLS1_NF=""
	fi
fi 


#-- SAP fields rules : old spira 109761
if [[ "${PARM_LOCAL_RULE}" != "Y" ]]
then
	Filler89to102_MSG="Blank 14 SAP columns"
	Filler89to102="PLUS_14_EMPTY"
else
	Filler89to102_MSG="14 SAP columns NOT UPDATED for Local"
	Filler89to102="Filler89to102"
fi



NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="update NEWCOLS1_NF field to CRE_D='$NEWCOLS1_NF' GEMPRMPAY_NF=empty, $Filler89to102_MSG "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_DELTA} 2000 1"
SORT_O="${DFILT}/${NJOB}_20_${IB}_CLEAR_FILE.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
       Filler1         1:1   -  21:,
       GEMPRMPAY_NF    22:1  -  22:,
       Filler23to88    23:1  -  88:,
       Filler89to102   89:1  -  102:,
       Filler2         103:1 - 109:,
       Filler3         111:1 - 118:
/DERIVEDFIELD NEWCOLS1_NF "${NEWCOLS1_NF}~"
/DERIVEDFIELD PLUS_14_EMPTY 14"~"
/DERIVEDFIELD GEMPRMPAY_NF_EMPTY "~"
/COPY
/OUTFILE ${SORT_O}
/REFORMAT Filler1, GEMPRMPAY_NF_EMPTY , Filler23to88, $Filler89to102  , Filler2 , NEWCOLS1_NF , Filler3
exit
EOF
SORT


NSTEP=${NJOB}_30
# execksh
#------------------------------------------------------------------------------
LIBEL="override ESF_FTECLEDA_DELTA=${ESF_FTECLEDA_DELTA}"
EXECKSH_MODE=P
EXECKSH "mv ${DFILT}/${NJOB}_20_${IB}_CLEAR_FILE.dat ${ESF_FTECLEDA_DELTA}"


JOBEND
