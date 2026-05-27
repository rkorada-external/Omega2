#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS
#                                 Chaine de lancement du perimetre de 
#                                 segmentation
# nom du script SHELL		: ESEJ0000.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 01/08/97
# auteur			: CGI
# references des specifications	: ESTSEG01.doc
#-----------------------------------------------------------------------------
# description
#   Launch segmentation perimeter after a PB request
#-----------------------------------------------------------------------------
# historique des modifications
#[01] 02/04/2014 Florent :spot:25427 Centralisation
#===============================================================================


#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FCURQUOT
#	EST_FINFOSEGPOR
#	EST_SADPERICAS0
#	EST_SADPERICASE0
#	EST_SADPERIFCI0
#	EST_SADPERIFCT0
#	EST_SADPERIFR0
#	EST_SADPERIPRMD0
# Output files
#	EST_FINFOSEGPOR
#	EST_OADPERICASE0
#	EST_OAVPERICASE0
#	EST_ORDPERICASE0
#	EST_ORVPERICASE0
#	EST_SADPERICAS0
#	EST_SADPERICASE0
#	EST_SADPERIFCI0
#	EST_SADPERIFCT0
#	EST_SADPERIFR0
#	EST_SADPERIPRMD0
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESCD0001
NJOB="ESCD0001"

NSTEP=${NJOB}_00
#-----------------------------------------------------------------------------
LIBEL="maj filiale pour le job ESCD0001"
ISQL_BASE="BREF"
ISQL_QRY="update BTEC..TTASKQUEUE set N_PARM_VAL_9=N_PARM_VAL_2 from BTEC..TTASKQUEUE where V_IN_FILE_PATH_1 like '%ESCD0001%' and isnull(N_PARM_VAL_9,'')=''"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

LOOP_AS_PRINT_SITE ${DCMD}/ESCD0001.cmd 2>&1 | ${TEE}

CHAINEND
