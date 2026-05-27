#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD8021.cmd
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
ECHO_LOG "#============================================================================"


if [ ${TYPEINV} = "INV" ]
then

NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Generate Estimate pattern POS for EBS"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PuEstimatePattern_01 '${PARM_ICLODAT_D}', '${PARM_CRE_D}', 'INV', ${NORME_CF}, 'BOOK'"
ISQL


NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Generate ULAE Ratios POS"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PuUlaeRatio_01 '${PARM_ICLODAT_D}', '${PARM_CRE_D}', 'INV', 'BOOK'"
ISQL


fi

JOBEND
