#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD8031.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 28\01\2022
# auteur                        : Arnaud RUFFAULT
#---------------------------------------------------------------------------------
# description
#  Copy to all sections (valid or not) the info IFRS 17  on rate index, first closing date and profitability
#  once at least a section of the treaty or facultative is initialised
#---------------------------------------------------------------------------------
##-----------------------------------------------------------------------------
# modifications
# [001] FCI Spira#102725 Profitability for dummy and PCA contracts
# Steps 15 & 20
# [002] BKarri Spira#104502 IFRS17 info - Rate index update
# Steps 05 & 10
# [003] HR Spira#111420 Update on the rule to copy I17 info on all contracts in a CR
# Steps 05 & 10
#-----------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#====================================INPUT PARAMETERS====================="
ECHO_LOG "#===> NORME_CF...........................................................: ${NORME_CF}"
ECHO_LOG "#===> PARM_ICLODAT_D.....................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PARM_PREV_ICLODAT_D................................................: ${PARM_PREV_ICLODAT_D}"
ECHO_LOG "#===> PARM_NEXT_ICLODAT_D................................................: ${PARM_NEXT_ICLODAT_D}"
ECHO_LOG "#===> X_DAYS.............................................................: ${X_DAYS}"
ECHO_LOG "#===> QUARTER_END_FOUND..................................................: ${QUARTER_END_FOUND}"
ECHO_LOG "#===> PARM_IS_TRN........................................................: ${PARM_IS_TRN}"
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_05
#Copy to all sections (valid or not) the info IFRS 17  on rate index, 
#first closing date and profitability once at least a section of the treaty or facultative is initialised
#-----------------------------------------------------------------------------
LIBEL="Copy to all sections (valid or not) the info IFRS 17  on rate index, first closing date and profitability once at least a section of the facultative is initialised"
ISQL_BASE="BFAC"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="execute BFAC..PuSECIFRS_05 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}', '${PARM_PREV_ICLODAT_D}', '${PARM_NEXT_ICLODAT_D}'"
ISQL

NSTEP=${NJOB}_10
#Copy to all sections (valid or not) the info IFRS 17  on rate index, 
#first closing date and profitability once at least a section of the treaty or facultative is initialised
#-----------------------------------------------------------------------------
LIBEL="Copy to all sections (valid or not) the info IFRS 17  on rate index, first closing date and profitability once at least a section of the treaty  is initialised"
ISQL_BASE="BTRT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="execute BTRT..PuSECIFRS_05 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}', '${PARM_PREV_ICLODAT_D}', '${PARM_NEXT_ICLODAT_D}'"
ISQL

NSTEP=${NJOB}_15
#Update the FAC info IFRS 17
#on Initial profitability (3), Inception status (1), First closing date (closing date) for dummy and PCA contracts
#on rate index for PCA contracts only
#-----------------------------------------------------------------------------
LIBEL="Update the FAC info IFRS 17 on Initial profitability, Inception status, First closing date for dummy and PCA contracts && on rate index for PCA contracts only."
ISQL_BASE="BFAC"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="execute BFAC..PuSECIFRS_07 '${PARM_ICLODAT_D}', '${PARM_PREV_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}'"
ISQL

NSTEP=${NJOB}_20
#Update the TRT info IFRS 17
#on Initial profitability (3), Inception status (1), First closing date (closing date) for dummy and PCA contracts
#on rate index for PCA contracts only
#-----------------------------------------------------------------------------
LIBEL="Update the TRT info IFRS 17 on Initial profitability, Inception status, First closing date for dummy and PCA contracts && on rate index for PCA contracts only."
ISQL_BASE="BTRT"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="execute BTRT..PuSECIFRS_07 '${PARM_ICLODAT_D}', '${PARM_PREV_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}'"
ISQL

JOBEND
