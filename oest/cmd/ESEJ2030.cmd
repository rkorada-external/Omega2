
#=============================================================================
# nom de l'application		: SEGMENTATION - EXPORT TO UW ABSTRACT
# nom du script SHELL		: ESEJ2030.cmd
# revision			        : $Revision:   1.0  $
# date de creation		    : 20/02/2014
# auteur			        : N. GASULL
# references des specifications	: 
#-----------------------------------------------------------------------------
# description :
# Launch the export to UW abstract process
#-----------------------------------------------------------------------------
# Modification history:
#   20/02/2014    Nicolas Gasull    Wrap and externalize from segmentation night batch the script orgininally written in ESEJ2019.cmd
#===============================================================================

. ${DUTI}/fctgen.cmd

# Initialize the chain
CHAININIT $0 $1

SEG_FREQ=(1)

NJOB=ESEJ2031
${DCMD}/ESEJ2031.cmd $SEG_FREQ 2>&1 | ${TEE}

NJOB=ESEJ2032
${DCMD}/ESEJ2032.cmd 2>&1 | ${TEE}

CHAINEND
