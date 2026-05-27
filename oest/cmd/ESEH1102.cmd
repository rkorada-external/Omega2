#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS
#                                 Descente de table en fichiers permanents
# nom du script SHELL		: ESEH1102.cmd
# revision			: $Revision: 1.1.1.1 $
# date de creation		: 05/10/1998
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   	Table Download into permanent files.
#
# job launched by ESEH1100
#-----------------------------------------------------------------------------
# historiques des modifications
#
#  J. Ribot ajout step12 appel BEST..PsPLACEMT_03 pour creation fichier EST_FPLACEMT1 (SPOT 11167)
#  #[004] 12/06/2015 SAS, spot: 28694 ajout du step 31 pour charger la table TCTRGRO pour la vie
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
OPTION=$1
CLODAT_D=$2
SEGTYP_CT=$3

###################
# Tables Download #
###################

NSTEP=${NJOB}_05
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession Cessions File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCESSION0}
BCP_QRY="execute BEST..PsCESSION_01"
BCP

NSTEP=${NJOB}_10
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMT0}
BCP_QRY="execute BEST..PsPLACEMT_01"
BCP

NSTEP=${NJOB}_12
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMT1}
BCP_QRY="execute BEST..PsPLACEMT_03"
BCP

NSTEP=${NJOB}_15
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of statistic amounts table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FUNDSTA0}
BCP_QRY="execute BEST..PsUNDSTA_01"
BCP

NSTEP=${NJOB}_20
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Selection of the last ultimates by contract"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCTRULT0}
BCP_QRY="execute BEST..PsCTRULT_01 '${OPTION}'"
BCP

NSTEP=${NJOB}_25
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Research of active versions for each subsidiary"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PsVERSION_03 '${OPTION}'"
ISQL

NSTEP=${NJOB}_30
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BEST..TCTRGRO table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCTRGRO0}
BCP_QRY="execute BEST..PsSECTION_10 '${OPTION}', '${SEGTYP_CT}'"
BCP

NSTEP=${NJOB}_31
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BEST..TCTRGROlife table life"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FVCTRGRO0}
BCP_QRY="execute BEST..PsFVCTRGRO_01 '${OPTION}', '${SEGTYP_CT}'"
BCP

NSTEP=${NJOB}_35
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Complete Accounts Files"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCPLACC0}
BCP_QRY="execute BEST..PsCPLACC_02 '${CLODAT_D}'"
BCP

NSTEP=${NJOB}_40
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BCTA..TAPR table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FAPR0}
BCP_QRY="execute BEST..PsAPR_01 '${OPTION}'"
BCP

NSTEP=${NJOB}_45
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BFAC..TFAMPROT table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FAMPROT0}
BCP_QRY="execute BEST..PsFAMPROT_01"
BCP

NSTEP=${NJOB}_50
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of binary format Files"
PRG=ESTX3602
export ${PRG}_O1=${EST_FBSEGEST}
EXECPRG

NSTEP=${NJOB}_55
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession commuted placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMTCOM0}
BCP_QRY="execute BEST..PsPLACEMT_10"
BCP

#PLG 19/10/2009 - Fiche Spot n° 16778: Ajout du fichier des taux de sinistralité des traités non proportionnels
NSTEP=${NJOB}_60
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation des taux lies a la saisonnalite des traites non proportionnels"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_SAISPERICASE}
BCP_QRY="execute BEST..PsPERITRTSAIS_01"
BCP
#Fin PLG 19/10/2009

JOBEND
