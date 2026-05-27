
#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INTRADAY
# nom du script SHELL           : ESID0112.cmd
# revision                      : $Revision: 1.0 
# date de creation              : 30/07/2015
# auteur                        : JFO
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Generation of file needed for ESID8040
#-----------------------------------------------------------------------------
# historiques des modifications
# [001] 	JFO 	29/07/2015 	spot29095: Création du fichier
# [002]		MBO		08/03/2016	spot30277: Suppression de tous les fichier TMP de ce CMD quelque soit la date
#======================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd


# Job Initialization
JOBINIT

# Parameter

NSTEP=${NJOB}_080
# Testing if BEST..TIDLIFEST_CALL is empty
# ------------------------------------------------------------------------
LIBEL="Testing if BEST..TIDLIFEST_CALL is empty"
BCP_WAY="OUT"
BCP_VER="+" 
BCP_O=${DFILT}/${NSTEP}_${IB}_FIDLIFEST_CALL.dat
BCP_QRY="SELECT TOP 5 * FROM BEST..TIDLIFEST_CALL"
BCP


NSTEP=${NJOB}_250
# Extracting Call table for PsLIFEST09
#------------------------------------------------------------------------------
LIBEL="Extracting PsLIFEST_09_ID1"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FLIFEST0}
BCP_QRY="execute BEST..PsLIFEST_09_ID1"
BCP


NSTEP=${NJOB}_400
# Extracting Call table for Intraday
#------------------------------------------------------------------------------
LIBEL="Extracting TGAPTHR"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_TGAPTHR}
BCP_QRY="execute BEST..PsTGAPTHR_ID"
BCP


NSTEP=${NJOB}_500
# Erase temporary files
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat" #[002]

JOBEND
