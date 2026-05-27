#!/bin/ksh
#=========================================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 11.1 
# nom du script SHELL           : ESFD0040.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 29/11/2018
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 69814 : REQ 11.01 - IFRS17- Closing schedule : Extract tables for closing in new architecture IFRS17
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===========================================================================================
#[001] 26/11/2018 JYP : SPIRA 69814 : EXTRACT TABLES FOR CLOSING IN NEW ARCHITECTURE IFRS17
#[002] 18/07/2019 LEL : SPIRA 81087 : MOVED PROC TO INFOCENTRE : ESFD0061 NOT USED
#[003] 18/09/2019 LEL : SPIRA 81087 : EXTRACT TABLE BREF..TPRSMAP TXT MODE
#[004] 15/11/2019 LEL : SPIRA 82279 : REACTIVATE ESFD0061 JOB TO EXTRACT FLOARAT FILE
#[005] 27/01/2020 LEL : SPIRA 83904 : MAPING FILES MANAGEMENT
#[006] 18/03/2020 KBagwe : SPIRA 94696 : Annual limit
#[007] 30/08/2021 M.NAJI SPIRA:91532: EST_PARAM n'est plu utilis
#[008] 06/09/2021 LEL :	SPIRA 97351 : ACF/PCA: Expenses calculation
#===========================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2


NJOB="SETCONTEXT"
# Launch applicative job SETCONTEXT
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# Proc moved to infocentre
# Launch applicative job ESFD0061 : this job extracts permanent file for closing 
#NJOB="ESFD0061${TYPEINV}"
#${DCMD}/ESFD0061.cmd  2>&1 | ${TEE}


# Launch applicative job ESFD0062 : to extract the table BSBO..TUWSEC to a permanent file ESF_FMARKET.dat
NJOB="ESFD0062"
${DCMD}/ESFD0062.cmd  ${PARM_CLODAT_D} ${TYPEINV} ${PARM_CRE_D}  2>&1 | ${TEE}


#MOD[006]
NJOB="ESFD0063${TYPEINV}"
${DCMD}/ESFD0063.cmd  2>&1 | ${TEE}

CHAINEND
