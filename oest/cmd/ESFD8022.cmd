#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD8022.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 06\10\2021
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# Description:
# Auto-renewal of estimates patterns and ratios for EBS norme
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF...............................................................: ${NORME_CF}"
ECHO_LOG "#===> TYPEINV................................................................: ${TYPEINV}"
ECHO_LOG "#===> PARM_CRE_D.............................................................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM_ICLODAT_D.........................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PARM_BATCHUSER.........................................................: ${PARM_BATCHUSER}"
ECHO_LOG "#============================================================================"



NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Generate Estimate pattern for EBS"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PuEstimatePattern_01 '${PARM_ICLODAT_D}', '${PARM_CRE_D}', '${TYPEINV}', ${NORME_CF}, 'BOOK'"
ISQL


NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Generate ULAE Ratios"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PuUlaeRatio_01 '${PARM_ICLODAT_D}', '${PARM_CRE_D}', '${TYPEINV}', 'BOOK'"
ISQL

## execution only once
if [ ${TYPEINV} = "POS" -a ${NORME_CF} = "EBS"]
then
NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="table BEST..TSEGEST update"
ISQL_BASE="BEST"
ISQL_QRY="exec PuULR_01 '${PARM_CRE_D}', '${TYPEINV}', '${PARM_BATCHUSER}'"
ISQL
fi

JOBEND
