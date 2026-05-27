#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESID2041.cmd
# revision                      : $Revision:   1.8  $
# date de creation              : 10/08/16
# auteur                        : RKE
# references des specifications : 
#-----------------------------------------------------------------------------
# description :
#               VENTILATION DE LA RETRO PAR PLACEMENT des fichier EST_ECRSRVRPC,EST_FLIFPLN1
#   Chain launched by Chain ESID2040
#-----------------------------------------------------------------------------
# historique des modifications :
#==============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Recupere arguments d'entree
ICLODAT_D=$1
CLODAT_D=$2
CRE_D=$3
BALSHTYEA_NF=$4
BALSHTMTH_NF=$5
LIF_ACY_MAX=4
LIF_ACY_MIN=4
################################################
export CLODAT_YEAR=`echo ${ICLODAT_D} | cut -c1-4`
export CLODAT_MTH=`echo ${ICLODAT_D} | cut -c5-6`
export CLODAT_DAY=`echo ${ICLODAT_D} | cut -c7-8`
################################################
# Initialise JOB
JOBINIT
NSTEP=${NJOB}_00
#[002] Last version of STAD150A files deletion
#-----------------------------------------------------------------
rem RMFIL "  `dirname ${EST_SRGTEFR_VENTIL}`/${NCHAIN}_SRGTEFR_VENTIL*.dat
rem          `dirname ${EST_FLIFPLN1_VENTIL}`/${NCHAIN}_FLIFPLN1_VENTIL*.dat
rem          `dirname ${EST_SRGTEFAR}`/${NCHAIN}_SRGTEFAR*.dat
rem          `dirname ${EST_SRGTEF_BILAN}`/${NCHAIN}_EST_SRGTEF_BILAN*.dat
rem          `dirname ${EST_ECRSRVRPC}`/${NCHAIN}_ECRSRVRPC*.dat"



NSTEP=${NJOB}_10
# Estimates cession amounts accumulation
#----------------------------------------------------------------------------
LIBEL="Estimates cession amounts accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FVPLACEMT} 1000 "
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FVPLACEMT_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  RCTR_NF     3:1 - 3:,
        RSEC_NF     5:1 - 5: EN,
        RTY_NF      6:1 - 6: EN
/KEYS RCTR_NF,RSEC_NF,RTY_NF
/COPY
/OUTFILE ${SORT_O}
exit
EOF
SORT


######################  ########################
#####         Traitement ECRSRVRPC         #####
######################  ########################
NSTEP=${NJOB}_20
# Estimates cession amounts accumulation
#----------------------------------------------------------------------------
LIBEL="Estimates cession amounts accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${EST_ECRSRVRPC}  1000 "
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_STGTER05_O.dat
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  CTR_NF      8:1 -  8: ,
        SEC_NF     10:1 - 10: EN ,
        UWY_NF     11:1 - 11: EN ,
        ACY_NF     14:1 - 14: EN ,
        PLC_NT     36:1 - 36: EN,
        ACMTRS_NT  45:1 - 45: ,
        ACMTRS4_NT 45:4 - 45: ,
        ESTAMT_M   43:1 - 43: EN 15/3
/KEYS CTR_NF,SEC_NF,UWY_NF,ACY_NF, PLC_NT, ACMTRS_NT
/COPY
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_30
# Amount by retrocessionnaire"
#----------------------------------------------------------------------------
LIBEL="Amount by retrocessionnaire"
PRG=STAM1225
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_FVPLACEMT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_20_${IB}_SORT_STGTER05_O.dat
export ${PRG}_O1=${EST_ECRSRVRPC_PA}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_STGTER10_REJET_O1.log
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
EXECPRG

######################  ########################
#####         Traitement ECRSRVRAPC        #####
######################  ########################
NSTEP=${NJOB}_50
# Estimates cession amounts accumulation
#----------------------------------------------------------------------------
LIBEL="Estimates cession amounts accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I="${EST_ECRSRVAPC}  1000 "
SORT_O="${EST_ECRSRVAPC_PA}  1000 "
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  CTR_NF      8:1 -  8: ,
        SEC_NF     10:1 - 10: EN ,
        UWY_NF     11:1 - 11: EN ,
        ACY_NF     14:1 - 14: EN ,
        PLC_NT     36:1 - 36: EN,
        ACMTRS_NT  45:1 - 45: ,
        ACMTRS4_NT 45:4 - 45: ,
        ESTAMT_M   43:1 - 43: EN 15/3
/KEYS CTR_NF,SEC_NF,UWY_NF,ACY_NF, PLC_NT, ACMTRS_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

######################  ########################
#####          Traitement FLIFPLN1         #####
######################  ########################
NSTEP=${NJOB}_100
# Begin sort  ACCEPT et RETRO
#-----------------------------------------------------------------------------
LIBEL="Sort of FLIFPLN file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FLIFPLN1} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FLIFPLN1_R_VENTIL.dat 1000"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FLIFPLN1_A_VENTIL.dat 1000"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD1_CF    6:1 - 6:1,
        CTR_NF        8:1 - 8:,
        UWY_NF       11:1 - 11: EN,
        SEC_NF       10:1 - 10: EN
/KEYS CTR_NF, SEC_NF, UWY_NF
/CONDITION ACCEPT (TRNCOD1_CF = '1' or TRNCOD1_CF = '3')
/OUTFILE ${SORT_O}
/OMIT ACCEPT
/OUTFILE ${SORT_O2}
/INCLUDE ACCEPT
exit
EOF
SORT

NSTEP=${NJOB}_110
# Ventilation de FLIFPLN
#----------------------------------------------------------------------------
LIBEL="Amount by retrocessionnaire"
PRG=STAM1225
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_FVPLACEMT_O.dat 
export ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_FLIFPLN1_R_VENTIL.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_FLIFPLN1_VENTIL.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_STGTER10_REJET_O1.log
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
EXECPRG

NSTEP=${NJOB}_120
#  Merge estimate acceptation and cession data
#----------------------------------------------------------------------------
LIBEL="Regroupement des données ESTIMATION acceptation et retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I=${DFILT}/${NJOB}_110_${IB}_FLIFPLN1_VENTIL.dat
SORT_I2=${DFILT}/${NJOB}_100_${IB}_FLIFPLN1_A_VENTIL.dat
SORT_O=${EST_FLIFPLN1_VENTIL}
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  TRNCOD1_CF    6:1 - 6:1,
        CTR_NF        8:1 - 8:,
        UWY_NF       11:1 - 11: EN,
        SEC_NF       10:1 - 10: EN,
        ACY_NF       14:1 - 14: EN
/KEYS CTR_NF,SEC_NF,UWY_NF, ACY_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

######################  ########################
#####          Traitement FLIFPLN3         #####
######################  ########################
NSTEP=${NJOB}_200
# Begin sort  ACCEPT et RETRO
#-----------------------------------------------------------------------------
LIBEL="Sort of FLIFPLN3 file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FLIFPLN3} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FLIFPLN3_R_VENTIL.dat 1000"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FLIFPLN3_A_VENTIL.dat 1000"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD1_CF    6:1 - 6:1,
        CTR_NF        8:1 - 8:,
        UWY_NF       11:1 - 11: EN,
        SEC_NF       10:1 - 10: EN
/KEYS CTR_NF, SEC_NF, UWY_NF
/CONDITION ACCEPT (TRNCOD1_CF = '1' or TRNCOD1_CF = '3')
/OUTFILE ${SORT_O}
/OMIT ACCEPT
/OUTFILE ${SORT_O2}
/INCLUDE ACCEPT
exit
EOF
SORT

NSTEP=${NJOB}_210
# Ventilation de FLIFPLN
#----------------------------------------------------------------------------
LIBEL="Amount by retrocessionnaire"
PRG=STAM1225
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_FVPLACEMT_O.dat 
export ${PRG}_I2=${DFILT}/${NJOB}_200_${IB}_FLIFPLN3_R_VENTIL.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_FLIFPLN3_VENTIL.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_STGTER10_REJET_O1.log
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
EXECPRG

NSTEP=${NJOB}_220
#  Merge estimate acceptation and cession data
#----------------------------------------------------------------------------
LIBEL="Regroupement des données ESTIMATION acceptation et retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
set -x
SORT_I=${DFILT}/${NJOB}_210_${IB}_FLIFPLN3_VENTIL.dat
SORT_I2=${DFILT}/${NJOB}_200_${IB}_FLIFPLN3_A_VENTIL.dat
SORT_O=${EST_FLIFPLN3_VENTIL}
set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  TRNCOD1_CF    6:1 - 6:1,
        CTR_NF        8:1 - 8:,
        UWY_NF       11:1 - 11: EN,
        SEC_NF       10:1 - 10: EN,
        ACY_NF       14:1 - 14: EN
/KEYS CTR_NF,SEC_NF,UWY_NF, ACY_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

echo " "
echo " "
echo "############  VERIFICATION GENERALE ##########"          
echo "====> VOLUMETRIE"
 wc ${DFILT}/${NJOB}_10_${IB}_SORT_FVPLACEMT_O.dat ${DFILT}/${NJOB}_20_${IB}_SORT_STGTER05_O.dat
 wc ${EST_ECRSRVRPC_PA}
echo "-------------------------------------------------"
 wc ${EST_ECRSRVAPC_PA}
echo "-------------------------------------------------"
 wc ${DFILT}/${NJOB}_10_${IB}_SORT_FVPLACEMT_O.dat ${DFILT}/${NJOB}_100_${IB}_FLIFPLN1_R_VENTIL.dat
 wc ${EST_FLIFPLN1_VENTIL}
echo "-------------------------------------------------"
 wc ${DFILT}/${NJOB}_10_${IB}_SORT_FVPLACEMT_O.dat ${DFILT}/${NJOB}_200_${IB}_FLIFPLN3_R_VENTIL.dat
 wc ${EST_FLIFPLN3_VENTIL}

NSTEP=${NJOB}_990
# Suppression des fichiers Temporaires
#------------------------------------------------------------------------------
LIBEL="Delete temporary files"
RMFIL "${DFILT}/${NJOB}*_*.dat"

JOBEND