#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESARCH11.cmd
# revision                      : 
# date de creation              : 06/09/2021
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Extraction quatidienne des  fichiers
#
# job launched by ESARCH10.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Creation	    : 
#Auteur         : M.NAJI
#Date           : 18/10/2022
#Version        : 1.0
#Description    : 12/02/2025 :M.NAJI SPIRA 112675 : Green IT- Improve closing files lifecycle
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DCMD}/ESARCLIB.cmd

# Job Initialisation
JOBINIT




NSTEP=${NJOB}_10
#all PATHPATTRN_LL 
#-----------------------------------------------------------------------------
LIBEL=" all PATHPATTRN_LL ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_FILES_TO_ZIP.dat
BCP_QRY="
    SELECT  str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_1_D}')
    FROM BEST.dbo.TI17PERMRUL
    where RULES_NT & 2 = 2
    AND IDF_CT ='${IDF_CT}'
   
    UNION
    SELECT str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_2_D}')
    FROM BEST.dbo.TI17PERMRUL
    where RULES_NT & 4 = 4
    AND IDF_CT ='${IDF_CT}'
   
"
BCP

NSTEP=${NJOB}_20
#files  archive  
#-----------------------------------------------------------------------------
LIBEL="files  archive  "
export ZIP_FILES_IN=${DFILT}/${NJOB}_10_${IB}_FILES_TO_ZIP.dat
export ZIP_FILES_ODIR="$DARCH"
export ZIP_FILES_OPT=''
export ZIP_FILES_MODE='Z'
export ZIP_FILES_PREFIX='ARCH_'
ZIP_FILES

NSTEP=${NJOB}_30
#all PATHPATTRN_LL 
#-----------------------------------------------------------------------------
LIBEL=" all PATHPATTRN_LL ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_FILES_TO_REMOVE.dat
BCP_QRY="
    SELECT  str_replace(PATHPATTRN_LL,'{PARM_ICLODAT_D}','{PARM_ICLODAT_1_D}')
    FROM BEST.dbo.TI17PERMRUL
    where RULES_NT & 8 = 8
    AND IDF_CT ='${IDF_CT}'
   
"
BCP


NSTEP=${NJOB}_20
#files  archive  
#-----------------------------------------------------------------------------
LIBEL="files  archive  "
export REMOVE_FILES_IN=${DFILT}/${NJOB}_30_${IB}_FILES_TO_REMOVE.dat
REMOVE_FILES

# End of Job
JOBEND


