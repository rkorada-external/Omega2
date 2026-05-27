#!/bin/ksh
#=============================================================================
# nom de l'application		: IFRS17 AE Life
#
# nom du script SHELL		: ESFJ0071.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 24/06/2020
# auteur			: S.Behague
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Extraction file for LIFE AE IFRS17
# [01]  09/10/2020 SBE  :spira:90643 IFRS 17 - Management of I17 AE in the I17 closing
# [02]  29/04/2021 SBE  :spira:92905 I17P: Management of Life AE for the Closing norm "LOCAL"
# [03]  19/05/2021 SBE  :spira:94442 I17: AE - Delta used IFRS 4 closing date instead of IFRS 17 one
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
IDF_CT=$1


NORME=$3

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Selection of IFRS17 AE Life"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FACCSUPI17LIFE}
BCP_QRY="exec BEST..PiESTACCSUP_08 ${PARM_BALSHTYEA_NF}, ${PARM_BALSHTMTH_NF}, '${PARM_ICLODAT_D}', ${NORME}"
BCP

JOBEND
