#!/bin/ksh
#=============================================================================
# Application name          : ESTIMATION LOT 28
# source file               : ESIJ7000.cmd
# revision                  : $Revision:   1.3  $
# creation date             : 01/08/97
# author                    : C.G.I. (M.NAJI)
# specifications references : ESARC01F.DOC
#-----------------------------------------------------------------------------
# description :
# JOB SET: Lot 28 -  Integration of accounts and  retro mouvements 
#                      in the daily GT 
# IMPORTANT : 2 job ont ete ajoute qui disparaitront en janvier: ESIJ7002 et ESIJ7004
#             Variable pour le fichiers GT pour jean franrcois
#             EST_GTASC defini dans ESCD9001.cmd
#-----------------------------------------------------------------------------
# Update history :
#   <dd/mm/yyyy>   <author>    <update description>
#=============================================================================

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_FACCTRTGT
#	EST_FDRYTRN
#	EST_FRTOSTA
# Output files
#	EST_FDRYTRN
#	EST_GTA
#	EST_GTR
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

# Launch applicative job ESCD9001
NJOB="ESCD9001"
. ${DCMD}/ESCD9001.cmd

# Launch applicative job ESIJ7003
NJOB="ESIJ7003"
${DCMD}/ESIJ7003.cmd 2>&1 | ${TEE}

# Launch applicative job ESIJ7004, spécial pour jean françois VAN DE VELDE
#NJOB="ESIJ7004"
#${DCMD}/ESIJ7004.cmd 2>&1 | ${TEE}

# Launch applicative job ESIJ7005
NJOB="ESIJ7005"
${DCMD}/ESIJ7005.cmd 2>&1 | ${TEE}

CHAINEND
