#!/bin/ksh
#=============================================================================
# nom de l'application    : ESTIMATION - INVENTAIRE
#                                 Extracting life tables
# nom du script SHELL   : ESID0061.cmd
# revision      : $Revision: 1.2 $
# date de creation    : 10/07/97
# auteur      : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Extracting tables.
#-----------------------------------------------------------------------------
# historique des modifications
#  G. BUISSON    08/09/2003    Ajout du parametre BALSHTMTH_NF dans l'appel de la procedure
#                              BEST..PsLIFEST_09.prc pour eviter de prendre les lignes posterieures
#                              au mois bilan a traiter suite au deblocage des periodes
#                              exceptionnelles
#  [001]
#  T. RIPERT    13/07/2010     Extraction des contrats ayant des postes dépôts (1900, 1901)
#  JF VDV       24/09/2010     [20198] - Eviter les doublons dans TLIFEST (cas inventaire en journee)
#                              ajout de CRE_D dans le job ESID0061_10/11
#[004] 25/03/2015 R. Cassis :spot:28483 Generation of Estimates and retro account files to chain ESID0110 instead of ESID0060 for Vtom optimisation
#[005] 15/09/2015 DFI spot:29095 EST26A Ajout extraction FACCPAR0 pour intraday
#[006] 04/03/2016 MBO : spot:30277: Nettoyage des fichiers $DFILI
#[007] 08/09/2016 MMA spot:31175 SUppression de l'extration du FACCPAR0 pour l'intraday
#[008] 09/04/2020 MZM :spira:42212 Creation d'un fichier contenant la date de derniere Compta Cedante via la Ps PsFDATDERCPA_01
#[009] 03/11/2021 MZM :spira:87852: Retrocession automatized Tax Estimates management : Extraction Fichier I4I Taxes Retro Management
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

#[006]
RMFIL	"`dirname ${EST_FLIFEST1}`/${NCHAIN}_FLIFEST1_*.dat
		 `dirname ${EST_FLSTMTH}`/${NCHAIN}_FLSTMTH_*.dat
		 `dirname ${EST_FACCPAR0}`/${NCHAIN}_FACCPAR0_*.dat"
#\[006]

# Parameters
CLODAT0_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4

#[004]
#NSTEP=${NJOB}_10
## Begin bcp
##------------------------------------------------------------------------------
#LIBEL="Current Generation of Estimates File"
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${EST_FLIFEST0}
#BCP_QRY="execute BEST..PsLIFEST_09 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}'"
#BCP

# [001]
# TRIPERT 13/07/2010
NSTEP=${NJOB}_11
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Estimates File (que 1900 et 1901)"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FLIFEST1}
BCP_QRY="execute BEST..PsLIFEST_09_1 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}'"
BCP
# [001]

#[005]
NSTEP=${NJOB}_15
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Ending period months File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FLSTMTH}
BCP_QRY="execute BEST..PsSection_25"
BCP


# Generation d'un fichier temporaire de DATE DE DERNIERE COMPTABILITE CEDANTE	[008]
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Generate COMPTA FILE TO COMPUTE ESTIMATION"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="exec BEST..PsFDATDERCPA_01 "
BCP_O=${EST_FDATDERCPA}
BCP


#### [009]
##
NSTEP=${NJOB}_25
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Extraction des données pour l'application de la Taxe Retro Management"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_TAXRETMGNT}
BCP_QRY="execute BEST..PsTAXRETMGT  '${PARM_ICLODAT_D}' "
BCP



#[007]
# if [ ${NCHAIN} = "${PCH}ESDJ7000" ]
# then
#   NSTEP=${NJOB}_20
#   # Begin bcp
#   #------------------------------------------------------------------------------
#   LIBEL=""
#   BCP_WAY="OUT"
#   BCP_VER="+"
#   BCP_O=${EST_FACCPAR0}
#   BCP_QRY="execute BEST..PsACCPAR_02"
#   BCP
# fi

JOBEND
