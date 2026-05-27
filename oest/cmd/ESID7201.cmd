#!/bin/ksh
#=============================================================================
# nom de l'application      : ESTIMATIONS - INVENTAIRE
#                               Chaine d'extraction mensuelle VISMA
# nom du script SHELL		: ESID7201.cmd
# revision			        : $Revision:   1.0  $
# date de creation		    : 18/09/2008
# auteur			        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description :
#
# job launched by ESID7200.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


DATE_T=`date '+%Y%m%d'`
DATE_TIME=`date '+%Y%m%d %H:%M:%S'`


NSTEP=${NJOB}_10
# Begin C Program
#----------------------------------------------------------------------------
LIBEL="VISMA GTA EXTRACTION from ${EST_GTASW}"
PRG=ESTCVISMAA01
export ${PRG}_I1=${EST_GTASW}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTASW_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_VISMAA_O1.dat
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
DATE_T ${DATE_T}
DATE_TIME ${DATE_TIME}
exit
EOF
export ${PRG}_PRM=${FPRM}
EXECPRG


NSTEP=${NJOB}_20
# Begin C Program
#----------------------------------------------------------------------------
LIBEL="VISMA GTR EXTRACTION from ${EST_GTRSW}"
PRG=ESTCVISMAR01
export ${PRG}_I1=${EST_GTRSW}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRSW_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_VISMAR_O1.dat
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
DATE_T ${DATE_T}
DATE_TIME ${DATE_TIME}
exit
EOF
export ${PRG}_PRM=${FPRM}
EXECPRG



NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="# Test VISMA GTASW file presence"
if test -s ${DFILT}/${NJOB}_10_${IB}_ESTCVISMAA01_VISMAA_O1.dat
then 
    NSTEP=${NJOB}_35
    # DEPLACE le fichier VISMAA dans le répertoire ftp
    #------------------------------------------------------------------------------
    LIBEL="DEPLACE le fichier VISMAA dans le répertoire ftp"
    EXECKSH_MODE=P
    EXECKSH "cp ${DFILT}/${NJOB}_10_${IB}_ESTCVISMAA01_VISMAA_O1.dat ${DTRANSFER}/revios/to/${NSTEP}_${IB}_ESTCVISMAA01_VISMAA.dat"

    NSTEP=${NJOB}_36
    # DEPLACE le fichier VISMAA dans le répertoire ftp archive
    #------------------------------------------------------------------------------
    LIBEL="DEPLACE le fichier VISMAA dans le répertoire ftp tosave"
    EXECKSH_MODE=P
    EXECKSH "cp ${DFILT}/${NJOB}_10_${IB}_ESTCVISMAA01_VISMAA_O1.dat ${DTRANSFER}/revios/tosave/${NSTEP}_${IB}_ESTCVISMAA01_VISMAA.dat"
else
    echo "STEP 30 : No VISMA GTASW file"
fi


NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="# Test VISMA GTRSW file presence"
if test -s ${DFILT}/${NJOB}_20_${IB}_ESTCVISMAR01_VISMAR_O1.dat
then 
    NSTEP=${NJOB}_45
    # DEPLACE le fichier VISMAR dans le répertoire ftp
    #------------------------------------------------------------------------------
    LIBEL="DEPLACE le fichier VISMAR dans le répertoire ftp"
    EXECKSH_MODE=P
    EXECKSH "cp ${DFILT}/${NJOB}_20_${IB}_ESTCVISMAR01_VISMAR_O1.dat ${DTRANSFER}/revios/to/${NSTEP}_${IB}_ESTCVISMAR01_VISMAR.dat"

    NSTEP=${NJOB}_46
    # DEPLACE le fichier VISMAR dans le répertoire ftp archive
    #------------------------------------------------------------------------------
    LIBEL="DEPLACE le fichier VISMAR dans le répertoire ftp tosave"
    EXECKSH_MODE=P
    EXECKSH "cp ${DFILT}/${NJOB}_20_${IB}_ESTCVISMAR01_VISMAR_O1.dat ${DTRANSFER}/revios/tosave/${NSTEP}_${IB}_ESTCVISMAR01_VISMAR.dat"
else
    echo "STEP 40 : No VISMA GTRSW file"
fi



NSTEP=${NJOB}_50
# new GTASW file
#------------------------------------------------------------------------------
LIBEL="copie le nouveau fichier GTASW dans DFILP"
EXECKSH_MODE=P
EXECKSH "cp ${DFILT}/${NJOB}_10_${IB}_ESTCVISMAA01_GTASW_O1.dat ${DFILP}/${NSTEP}_${IB}_ESTCVISMAA01_GTASW_O1.dat"

NSTEP=${NJOB}_55
# new GTASW file
#------------------------------------------------------------------------------
LIBEL="Le nouveau fichier GTASW remplace l'ancien"
EXECKSH_MODE=P
EXECKSH "mv ${DFILP}/${NJOB}_50_${IB}_ESTCVISMAA01_GTASW_O1.dat ${EST_GTASW}"




NSTEP=${NJOB}_60
# new GTRSW file
#------------------------------------------------------------------------------
LIBEL="copie le nouveau fichier GTRSW dans DFILP"
EXECKSH_MODE=P
EXECKSH "cp ${DFILT}/${NJOB}_20_${IB}_ESTCVISMAR01_GTRSW_O1.dat ${DFILP}/${NSTEP}_${IB}_ESTCVISMAR01_GTRSW_O1.dat"

NSTEP=${NJOB}_55
# new GTRSW file
#------------------------------------------------------------------------------
LIBEL="Le nouveau fichier GTRSW remplace l'ancien"
EXECKSH_MODE=P
EXECKSH "mv ${DFILP}/${NJOB}_60_${IB}_ESTCVISMAR01_GTRSW_O1.dat ${EST_GTRSW}"



#########################
# Erase temporary files #
#########################
NSTEP=${NJOB}_160
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"


JOBEND

