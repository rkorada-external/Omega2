#!/bin/ksh
#=============================================================================
# nom de l'application          : CLOSING ESTIMATIONS
# date de creation              : 25/02/2025
# auteur                        : Mr JYP
#-----------------------------------------------------------------------------
# description : rounding estimates amounts / TTECLEDR
#-----------------------------------------------------------------------------#
# Modifications
# [001] 27/02/2025 : Mr JYP : spira 112324 : rounding estimates amounts calculations
# [002] 03/04/2025 : Mr JYP : spira 112324 : rounding estimates amounts calculations
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Job Initialisation
JOBINIT

						

ECHO_LOG "#========================================================"
ECHO_LOG "#===> ............ PARAMETERS ............................"
ECHO_LOG "#===> NORME_CF...........................................: ${NORME_CF}"
ECHO_LOG "#===> ROUNDING_FILTER_FLG................................: [${ROUNDING_FILTER_FLG}]"
ECHO_LOG "#===> ROUNDING_APPLY_MAX_AMT  ...........................: [${ROUNDING_APPLY_MAX_AMT}]"
ECHO_LOG "#===> ROUNDING_EXCLUDE_LIMIT_AMT ........................: [${ROUNDING_EXCLUDE_LIMIT_AMT}]"

ECHO_LOG "#===> ............ INPUT ................................."
ECHO_LOG "#===> ESF_FTECLEDR_MVT     ..............................: ${ESF_FTECLEDR_MVT}"
ECHO_LOG "#===> ............ OUTPUT ..............................."
ECHO_LOG "#===> ESF_FTECLEDR_MVT     ..............................: ${ESF_FTECLEDR_MVT}"
ECHO_LOG "#===> ESF_FTECLEDR_EXCLUDED..............................: ${ESF_FTECLEDR_EXCLUDED}"
ECHO_LOG "#========================================================"



if [ ! -s "${ESF_FTECLEDR_MVT}" ]
then
    echo  -e "\nfile ESF_FTECLEDR_MVT is empty, nothing to update !! \n" 
    ECHO_LOG "file ESF_FTECLEDR_MVT is empty, nothing to update  !! \n"
	JOBEND
fi

if [ "${ROUNDING_FILTER_FLG}" != "Y" ]
then
    echo  -e "\nROUNDING_FILTER_FLG=$ROUNDING_FILTER_FLG : rounding function is not activated , nothing to do !! \n" 
    ECHO_LOG "ROUNDING_FILTER_FLG=$ROUNDING_FILTER_FLG : rounding function is not activated , nothing to do !! \n"
	JOBEND
fi 	

if [ "${ROUNDING_APPLY_MAX_AMT}" = "NOLIMIT" ]
then
    MAX_AMT=0
    echo  -e "\nROUNDING_APPLY_MAX_AMT is NOLIMIT: rounding function is applied on all amounts \n" 
    ECHO_LOG "ROUNDING_APPLY_MAX_AMT is NOLIMIT: rounding function is applied on all amounts  \n"
else
    MAX_AMT=$ROUNDING_APPLY_MAX_AMT
fi 


LIMIT_AMT=$ROUNDING_EXCLUDE_LIMIT_AMT
	 
#------------------------------------------------------------------------------
NSTEP=${NJOB}_20
LIBEL="rounding amount +- 0.5 file ESF_FTECLEDR_MVT= $ESF_FTECLEDR_MVT "
AWK_I=${ESF_FTECLEDR_MVT}
AWK_O=${DFILT}/${NSTEP}_${IB}_ROUNDING_SAP.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" ; TRACE="";}
{
TRACE="ACCEPTED~";
amt=\$19;
retamt=\$35;
if (\$19 < 0) { abs_amt=sprintf("%-.3lf",-\$19 ) } else { abs_amt=\$19 }
if (\$35 < 0) { abs_retamt=sprintf("%-.3lf",-\$35 ) } else { abs_retamt=\$35 }



 if ( \$56 != "" || \$67 == "O" || \$67 == "A" ||( substr(\$57 , 1, 7 )  == "RECLASS" && \$56 == "" )  ) 
 {
  TRACE=sprintf("ACCEPTED1~ OA:%s TNR_NT:%s ORICOD:%s",\$67 ,\$56,\$57); 
 }
 else 
 {
      if ( amt != "" && amt != 0 && ( abs_amt < $MAX_AMT || $MAX_AMT == 0 )   ) 
	    { 
		   if (amt > 0 ) { amt=int(amt + 0.5 ) } else { amt=int(amt - 0.5  ) } ;
		}
      if ( retamt != "" && retamt != 0 && ( abs_retamt < $MAX_AMT || $MAX_AMT == 0 )  ) 
	    { 
		   if (retamt > 0 ) { retamt=int(retamt + 0.5  ) } else { retamt=int(retamt - 0.5 ) } ;
		}

		
	if ( ( (substr(\$6,1,1) == "1" || substr(\$6,1,1) == "3") &&  (amt >= $LIMIT_AMT ||  amt <= -$LIMIT_AMT ) ) || ( (substr(\$6,1,1) == "2" || substr(\$6,1,1) == "4") &&  (retamt >= $LIMIT_AMT ||  retamt <= -$LIMIT_AMT ) ))
	{ 
		 TRACE=sprintf("ACCEPTED2~from(%-.3lf : %-.3lf ) to(%-.3lf : %-.3lf) ",\$19,\$35,amt,retamt);
		 \$19=amt;\$35=retamt ;
	}
	else 
	{ 
		 TRACE=sprintf("REJECTED~for(%-.3lf : %-.3lf) calc(%-.3lf : %-.3lf) ",\$19,\$35,amt,retamt);
	}
}
		  
print \$0 , TRACE ;

}
exit
EOF
cat $AWK_CMD > ${DFILT}/${NSTEP}_${IB}_AWK_SCRIPT.dat
AWK


NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="extract ACCEPTED data and override ESF_FTECLEDR_MVT=${ESF_FTECLEDR_MVT} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`                 
SORT_I="${DFILT}/${NJOB}_20_${IB}_ROUNDING_SAP.dat 2000 1"
SORT_O="${ESF_FTECLEDR_MVT} 2000 1"
SORT_O2="${ESF_FTECLEDR_EXCLUDED} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS STATUS          72:1 - 72:,
        71_FIELDS      1:1 - 71:,
        73_FIELDS      1:1 - 73:
/CONDITION COND_ACCEPTED (STATUS = "ACCEPTED1") OR (STATUS = "ACCEPTED2")
/CONDITION COND_REJECTED (STATUS = "REJECTED") 
/OUTFILE ${SORT_O} overwrite
/INCLUDE COND_ACCEPTED
/REFORMAT 71_FIELDS
/OUTFILE ${SORT_O2} overwrite
/INCLUDE COND_REJECTED
/REFORMAT 73_FIELDS
exit
EOF
SORT



JOBEND
