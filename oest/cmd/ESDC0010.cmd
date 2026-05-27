#!/bin/ksh
#===============================================================================
# application name               : Compare data to send to TTECLECDA
# source name                    : ESDC0010.cmd
# revision                       : $Revision:   0.1  $
# extraction date                : 05/07/2021
# author                         : S.Behague
# specifications reference       :
#                                :
#-------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------
# modifications chronology       :
# [001] - 05/07/2021 S.Behague :spira:96760 - RA and SAP interface data checks
# [002] - 16/03/2023 JYP:spira:104893 - rework all checks
# [003] - 20/03/2023 JYP:spira:104893 - new field for default products
# [004] - 22/03/2023 JYP:spira:104893 - remove field partial defaulting 
# [005] - 24/03/2023 JYP:spira:104893 - rework some checks, add lob checks 
# [006] - 28/03/2023 JYP:spira:109361 - complete checks with product attributes
#============================================================================


# call generic functions
#------------------------------------------------------------------------------
. ${DUTI}/fctgen.cmd


# Chain Initialization variables
#------------------------------------------------------------------------------
# Chain Initialization variables
CHAININIT $0 $1

IDF_CT=$2

# Parameter
# ------------------------------------
set `GETPRM ${DPRM}/ESDC0010.prm`
export MAILTO_PROD=$1
export MAILTO_TEST=$2
export MAILTO_DEV=$3
export PURGE_DAYS=$4

export GAAPCOD_ERR="empty GAAP code"
export I17PRDCOD_ERR="empty Product Code"
export SSD_ERR="empty SSD"
export ESB_ERR="empty EBS"
export TRNCOD_ERR="empty TC"
export DBLTRNCOD_ERR="empty Counter-balance TC"
export FULL_DEFAULTING_ERROR="Full defaulting product SG/PC"
export LOBACC_ERROR="empty LOBACC_CF"
export LOBRET_ERROR="empty LOBRET_CF"


NJOB="ESFD9001"
# Launch applicative job ESFD9001
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

# initialise file 


PARALLEL_JOB_INIT 17
#- 1 ---------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_I17G_DLT_SAP_STD_FTECLEDA_DELTA"
Fichier=${ESF_FTECLEDAG_DELTA}
Fichier_court=ESF_FTECLEDAG_DELTA
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier} ${Fichier_court} A I17G "


#- 2 ---------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_I17L_DLT_SAP_STD_FTECLEDA_DELTA"
Fichier1=${ESF_FTECLEDAL_DELTA}
Fichier1_court=ESF_FTECLEDAL_DELTA
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} A  I17L "

#- 3 ---------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_I17P_DLT_SAP_STD_FTECLEDA_DELTA"
Fichier1=${ESF_FTECLEDAP_DELTA}
Fichier1_court=ESF_FTECLEDAP_DELTA
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} A I17P "


#- 4 ---------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_BSAR_I17G_OMG_RA_STD_FTECLEDARA"
Fichier1=${ESF_I17GFTECLEDARA}
Fichier1_court=ESF_I17GFTECLEDARA
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} A I17G "

sleep 1

#- 5 ---------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_BSAR_I17G_OMG_RA_STD_FTECLEDRRA"
Fichier1=${ESF_I17GFTECLEDRRA}
Fichier1_court=ESF_I17GFTECLEDRRA
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} R I17G "

#- 6 ---------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_BSAR_I17L_OMG_RA_STD_FTECLEDARA"
Fichier1=${ESF_I17LFTECLEDARA}
Fichier1_court=ESF_I17LFTECLEDARA
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} A I17L "



#- 7 ---------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_BSAR_I17L_OMG_RA_STD_FTECLEDRRA"
Fichier1=${ESF_I17LFTECLEDRRA}
Fichier1_court=ESF_I17LFTECLEDRRA
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} R I17L "

#- 8 ---------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_BSAR_I17P_OMG_RA_STD_FTECLEDARA"
Fichier1=${ESF_I17PFTECLEDARA}
Fichier1_court=ESF_I17PFTECLEDARA
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} A I17P "

sleep 1

#- 9 ---------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_BSAR_I17P_OMG_RA_STD_FTECLEDRRA"
Fichier1=${ESF_I17PFTECLEDRRA}
Fichier1_court=ESF_I17PFTECLEDRRA
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} R I17P "

#### IFRS4 ####
#- 10 --------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_FTECLEDA_MVT_I4I"
Fichier1=${EST_FTECLEDARA}
Fichier1_court=EST_FTECLEDARA
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} A I4I "

if [ "$TYPEINV" = "INV" ]
then
    #- 11 --------------------------------------------------------------------------
    # Launch applicative job ESDC1101.cmd
    NJOB="ESDC0011_BSAR_FTECLEDA"
    Fichier1=${EST_BSAR_FTECLEDA}
    Fichier1_court=EST_BSAR_FTECLEDA
    PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} A I4I "
    
    #- 12 --------------------------------------------------------------------------
    # Launch applicative job ESDC1101.cmd
    NJOB="ESDC0011_BSAR_FTECLEDR"
    Fichier1=${EST_BSAR_FTECLEDR}
    Fichier1_court=EST_BSAR_FTECLEDR
    PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} R I4I "
fi


sleep 1

#### EBS ####

#- 13 --------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_BSAR_FTECLEDASII"
Fichier1=${EST_BSAR_FTECLEDASII}
Fichier1_court=EST_BSAR_FTECLEDASII
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} A EBS "

#- 14 --------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_FTECLEDA_EBS_DELTA"
Fichier1=${EST_FTECLEDA_EBS_DELTA}
Fichier1_court=EST_FTECLEDA_EBS_DELTA
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} A EBS "


#- 15 --------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_BSAR_FTECLEDRSII"
Fichier1=${EST_BSAR_FTECLEDRSII}
Fichier1_court=EST_BSAR_FTECLEDRSII
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} R EBS "


# LOCAL 
#- 16 --------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_EST_FTECLEDA_LOC"
Fichier1=${EST_FTECLEDA_LOC}
Fichier1_court=EST_FTECLEDA_LOC
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} A LOC  "

#- 17 --------------------------------------------------------------------------
# Launch applicative job ESDC1101.cmd
NJOB="ESDC0011_EST_FTECLEDR_LOC"
Fichier1=${EST_FTECLEDR_LOC}
Fichier1_court=EST_FTECLEDR_LOC
PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} R LOC  "



# POSI 

if [ "$TYPEINV" = "POS" ]
then
   #- 18 --------------------------------------------------------------------------
   # Launch applicative job ESDC1101.cmd
   NJOB="ESDC0011_EST_FTECLEDA_POSI"
   Fichier1=${EST_FTECLEDA_POSI}
   Fichier1_court=EST_FTECLEDA_POSI
   PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} A I4I  "
   
   #- 19 --------------------------------------------------------------------------
   # Launch applicative job ESDC1101.cmd
   NJOB="ESDC0011_EST_FTECLEDR_POSI"
   Fichier1=${EST_FTECLEDR_POSI}
   Fichier1_court=EST_FTECLEDR_POSI
   PARALLEL_JOB "${DCMD}/ESDC0011.cmd ${Fichier1} ${Fichier1_court} R I4I  "
fi 


PARALLEL_JOB_END

 
NJOB="ESDC0012"
#- Envoi Mail ------------------------------------------------------------------
${DCMD}/ESDC0012.cmd 2>&1 | ${TEE}

CHAINEND




