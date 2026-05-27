#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17/EBS
# nom du script SHELL           : ESPT0031.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 08\10\2021
# auteur                        : Cyril AVINENS
#-----------------------------------------------------------------------------
# description
#  		IFRS17/EBS : Manualy Pattern renewal process
#
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="  
ECHO_LOG "#===> P_ICLODAT_D .............................: ${P_ICLODAT_D}"
ECHO_LOG "#===> P_NORME_CF ..............................: ${P_NORME_CF}"
ECHO_LOG "#===> P_TYPEINV ...............................: ${P_TYPEINV}"                                                              
ECHO_LOG "#===> P_OBJECT ................................: ${P_OBJECT}"
ECHO_LOG "#===> PARM_CRE_D ..............................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM_BATCHUSER ..........................: ${PARM_BATCHUSER}"
ECHO_LOG "#=========================================================================" 

UPDATED=0

if [ ${P_TYPEINV} = "INV" -o ${P_TYPEINV} = "POS" ]
then

	if [ ${P_NORME_CF} = "EBS" ]
	then
	
		if [ ${P_OBJECT} = "ULR" ]
		then	
   NSTEP=${NJOB}_05
   #-----------------------------------------------------------------------------
   LIBEL="table BEST..TSEGEST update"
   ISQL_BASE="BEST"
   ISQL_QRY="exec PuULR_01 '${PARM_CRE_D}', '${P_TYPEINV}'"
   ISQL
			
			UPDATED=1
		fi
		
		if [ ${P_OBJECT} = "ULAE" ]
		then
		
   NSTEP=${NJOB}_10
   #-----------------------------------------------------------------------------
   LIBEL="Generate ULAE Ratios"
   ISQL_BASE="BEST"
   ISQL_QRY="exec BEST..PuUlaeRatio_01 '${P_ICLODAT_D}', '${PARM_CRE_D}', '${P_TYPEINV}', '${PARM_BATCHUSER}'"
   ISQL
			
			UPDATED=1
		fi
		
		if [ ${P_OBJECT} = "ESTIMATE" ]
		then
			NSTEP=${NJOB}_15
   #-----------------------------------------------------------------------------
   LIBEL="Generate Estimate pattern for EBS"
   ISQL_BASE="BEST"
   ISQL_QRY="exec BEST..PuEstimatePattern_01 '${P_ICLODAT_D}', '${PARM_CRE_D}', '${P_TYPEINV}', ${P_NORME_CF}, '${PARM_BATCHUSER}'"
   ISQL
			
			UPDATED=1
		fi
	fi
	
	if [ ${P_NORME_CF:0:3} = "I17" ]
	then
		if [ ${P_OBJECT} = "ESTIMATE" ]
		then 
			NSTEP=${NJOB}_20
			#-----------------------------------------------------------------------------
			LIBEL="Generate Estimate pattern for I17G/P/L"
			ISQL_BASE="BEST"
			ISQL_QRY="exec BEST..PuEstimatePattern_01 '${P_ICLODAT_D}', '${PARM_CRE_D}', '${P_TYPEINV}', ${P_NORME_CF}, '${PARM_BATCHUSER}'"
			ISQL
			
			UPDATED=1
		fi
		
		if [ ${P_OBJECT} = "EXPENSES" ]
		then
			NSTEP=${NJOB}_25
			#-----------------------------------------------------------------------------
			LIBEL="Generate Expenses Ratios for I17G/P/L"
			ISQL_BASE="BEST"
			ISQL_QRY="exec BEST..PuExpensesRatios_01 '${P_ICLODAT_D}', '${PARM_CRE_D}', '${P_TYPEINV}', ${P_NORME_CF}, '${PARM_BATCHUSER}'"
			ISQL

			UPDATED=1
		fi
		
		if [ ${P_OBJECT} = "RISK" ]
		then 
			NSTEP=${NJOB}_30
			#-----------------------------------------------------------------------------
			LIBEL="Generate Risk Adjustment Ratios for I17G/P/L"
			ISQL_BASE="BEST"
			ISQL_QRY="exec BEST..PuRiskAdjustmentRatios_01 '${P_ICLODAT_D}', '${PARM_CRE_D}', '${P_TYPEINV}', ${P_NORME_CF}, '${PARM_BATCHUSER}'"
			ISQL
			
			UPDATED=1
		fi
	fi
fi

if [ ${UPDATED} = 0 ]
then
	ECHO_LOG "Nothing to update with this parameters"  
fi

JOBEND
