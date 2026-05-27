#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION - INVENTAIRE
#                                 Extracting life tables
# nom du script SHELL           : ESID0067.cmd
# revision                      : $Revision: 1.3 $
# date de creation              : 30/07/99
# auteur                        : Mehdi NAJI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Extracting tables.
#-----------------------------------------------------------------------------
# historique des modifications
# 10 05 2007 J. Ribot     modif step 45 longueur fichier entrée siute a plantage NY
# 31/07/2007 R. Cassis    spot 14335 - dans step 45 longueur du fichier sur fichier sortie également
#
# [001]
# 13/07/2010 T. Ripert    spot 18235 - isoler les postes 1900 et 1901
# 06/10/2010 JF VDV            [20198] - Eviter les doublons dans TLIFEST (cas inventaire en journee)
#                              ajout de CRE_D au step ESID0067_20
#[003] 25/03/2015 R. Cassis :spot:28483 Generation of Estimates and retro account files to chain ESID0110 instead of ESID0060 for Vtom optimisation
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Parameters

SSD_CF="00"
SEGTYP_CT=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4

NSTEP=${NJOB}_05
# Begin bcp
#------------------------------------------------------------------------------
LIBEL=""
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FACCPAR0}
BCP_QRY="execute BEST..PsACCPAR_02"
BCP

NSTEP=${NJOB}_10
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Deposit Conditions"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FDEPOSIT0}
BCP_QRY="execute BEST..PsDEPOSIT_01"
BCP

NSTEP=${NJOB}_15
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Interest Rate on Deposits"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FINTWIT}
BCP_QRY="execute BEST..PsINTWIT_01"
BCP

#[003]
#NSTEP=${NJOB}_20
## Begin bcp
##------------------------------------------------------------------------------
#LIBEL="Current Generation of Estimates File"
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${EST_FLIFEST0}
#BCP_QRY="execute BEST..PsLIFEST_09 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}'"
#BCP

#[001]
#NSTEP=${NJOB}_21
# Begin bcp
#------------------------------------------------------------------------------
#LIBEL="Current Generation of Estimates File (que les postes 1900 et 1901)"
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${EST_FLIFEST1}
#BCP_QRY="execute BEST..PsLIFEST_09_1 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}'"
#BCP
#[001]

NSTEP=${NJOB}_25
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Ending period months File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FLSTMTH}
BCP_QRY="execute BEST..PsSection_25"
BCP

NSTEP=${NJOB}_30
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Placement Deposit Conditions"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPFUNWIT0}
BCP_QRY="execute BEST..PsPFUNWIT_01"
BCP

NSTEP=${NJOB}_35
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Placement Deposit Interest Rates"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPINTWIT0}
BCP_QRY="execute BEST..PsPINTWIT_01"
BCP

NSTEP=${NJOB}_40
#Generation of IRVPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRVPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_O.dat
BCP_QRY="execute BEST..PsSECTION_21 '${SEGTYP_CT}', ${SSD_CF}"
BCP

NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="Current Sort of IRVPERICASE Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_BCP_PERICASE_O.dat 1000"
SORT_O="${EST_IRVPERICASE0} OVERWRITE 1000"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="Creation of empty Perimeter Files"
EXECKSH "touch ${EST_OADPERICASE0}"
EXECKSH "touch ${EST_OAVPERICASE0}"
EXECKSH "touch ${EST_IRDPERICASE0}"
EXECKSH "touch ${EST_ORDPERICASE0}"
EXECKSH "touch ${EST_ORVPERICASE0}"


JOBEND
