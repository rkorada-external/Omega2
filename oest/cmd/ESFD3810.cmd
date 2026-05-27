#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 : BDA- Impact on Omega closing
# Revision                      : $Revision:   1.0  $
# Date de creation              : 09/04/2020
# Auteur                        : Linh.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# 
#  - BDA- Impact on Omega closing
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#       <indice>        <jj/mm/aaaa>    <auteur>       <spira>          <description de la modification>
#       [001]           09/04/2020      Linh DOAN      83103 			BDA- Impact on Omega closing
#       [002]           28/05/2020      Linh DOAN      83103            add CSM LC
#       [003]		    08/07/2020 	    Linh DOAN      87446			add counterpart code
#       [004]		    07/09/2020      Mr JYP         83104		    add I17PRODCOD_CT code
#       [005]           19/05/2021      Linh DOAN      96351 			fix error tecledr
#       [006]           27/07/2021      Mr JYP         94896            add I17PRODCOD_CT code into TTECLEDR
#====================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
CHAININIT $0 $1


#pour tester
#IDF_CT=
#	IFRS4: IFR4_GLT_GAP_STD
#	EBS: EBS_GLT_GAP_STD
#	IFRS17: I17G_GLT_GAP_STD


IDF_CT=$2



NJOB="ESFD9001"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}

PARALLEL_JOB_INIT 2

#NJOB="ESFD3815_I17G_ESF_CSM_LC_FTECLEDA"
#PARALLEL_JOB "${DCMD}/ESFD3815.cmd ${ESF_CSM_LC_FTECLEDA} ${ESF_FDETTRS_TXT}"

NJOB="ESFD3815_I17G_ESF_FTECLEDA"
PARALLEL_JOB "${DCMD}/ESFD3815.cmd ${ESF_FTECLEDA} ${ESF_FDETTRS_TXT}"


NJOB="ESFD3816_I17G_ESF_FTECLEDR"
PARALLEL_JOB "${DCMD}/ESFD3816.cmd ${ESF_FTECLEDR} ${ESF_FDETTRS_TXT}"


PARALLEL_JOB_END

 #"I17G Closing"

PARALLEL_JOB_INIT 2

# Launch applicative job ESFD3810_I17G_FTECLEDA
NJOB="ESFD3811_I17G_ESF_FTECLEDA"
PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${ESF_FTECLEDA} ${ESF_GAAPCOD_MAPPING}"


# Launch applicative job ESFD3810_I17G_FTECLEDR
NJOB="ESFD3813_I17G_ESF_FTECLEDR"
PARALLEL_JOB "${DCMD}/ESFD3813.cmd ${ESF_FTECLEDR} ${ESF_GAAPCOD_MAPPING}"


# Launch applicative job ESFD3810_I17G_CSM
#NJOB="ESFD3811_I17G_ESF_CSM_LC_FTECLEDA"
#PARALLEL_JOB "${DCMD}/ESFD3811.cmd ${ESF_CSM_LC_FTECLEDA} ${ESF_GAAPCOD_MAPPING}"


PARALLEL_JOB_END


PARALLEL_JOB_INIT 2

# Launch applicative job ESFD3819_I17G_ESF_FTECLEDA
NJOB="ESFD3819_I17G_ESF_FTECLEDA"
PARALLEL_JOB "${DCMD}/ESFD3819.cmd ${ESF_FTECLEDA} ${ESF_FCTRI17PRD_NEW}" 2>&1 | ${TEE}


# Launch applicative job ESFD3818_I17G_FTECLEDR
NJOB="ESFD3818_I17G_ESF_FTECLEDR"
PARALLEL_JOB "${DCMD}/ESFD3818.cmd ${ESF_FTECLEDR} ${ESF_FCTRI17PRD_NEW}" 2>&1 | ${TEE}

PARALLEL_JOB_END




CHAINEND
