#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - Fusion du fichier Ftecleda avec celui garni de One GL
# nom du script SHELL		: ESPD8701.cmd
# date de creation		   : 15/03/2011
# auteur			            : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:              
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#[001]  05/05/2011  R. CASSIS     :spot:21408 - Modification OneGL
#[002]  07/07/2015  D. Fillinger  :spot:28947 - filtrage analytiques
#[003]  20/07/2021  M. NAJI    r  :SPIRA: 92532 add ESB dans EPO_FTECLEDA
#[004]  03/08/2011  R. CASSIS     :spot:91531 - Nom variable EPO_FTECLEDASO au lieu de EPO_FTECLEDA en sortie
#[005]  22/03/2022  D. TEIXEIRA   :Spira 103245 - add EST_FTECLEDA output for RA without ESB
#[006]  01/04/2022  JYP/TD        :spira:103544 - DELTA posting new mode  
#[007]  14/06/2022  JYP/TD        :spira:103544 - DELTA posting new mode  
#[008]  16/06/2022  JYP/Flo       :spira:104337 - update ESB for retro  
#[009]  26/07/2022  JYP/TD        :spira:105805 - DELTA posting , bugfix POSI  
#[010]  08/29/2022  J.B-D	        :spira:105393 - O2/SAP remove 900-100 
#[011]  21/11/2022  JYP/Flo/TD    :SPIRA 107843 do NOT update ESB for retro in FTECLEDA 
#[012]  25/09/2024  Mr JYP        :SPIRA 112222 bugfix old spira 105393 900-100 remain file
#[013]  17/11/2025  Mr JYP        :US7576 SERQS POS cashflow issue
#-----------------------------------------------------------------------------
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 


# Get input parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_10
# Merge des fichiers EPO_FTECLEDASO et FTECLEDA
#------------------------------------------------------------------------------
LIBEL="Merge des fichiers EPO_FTECLEDASO de l'ETL et FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDA_CUR} 1000 1"
SORT_I2="${EPO_FTECLEDASO_MTH} 1000 1" # [002]
SORT_I3="${EPO_FTECLEDA_RMN} 1000 1" #[010]
if [ ${PARAM_IS_SAP_POSTING} = "N" ] #[007]
then
SORT_I4="${EPO_FTECLEDASO_MVT} 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDASO_CUR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_30
# Merge des fichiers EPO_FTECLEDASO et FTECLEDA
#------------------------------------------------------------------------------
LIBEL="Merge des fichiers EPO_FTECLEDASO de l'ETL et FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FTECLEDASO_CUR_O.dat 1000 1"
SORT_I2="${EPO_FTECLEDA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDASO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

# [005]
NSTEP=${NJOB}_35
LIBEL="cp ${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDASO_O.dat ${EST_FTECLEDA}"
EXECKSH "cp ${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDASO_O.dat ${EST_FTECLEDA}"


NSTEP=${NJOB}_40
# Merge des fichiers multi sites
#------------------------------------------------------------------------------
LIBEL="Merge des fichiers multi-sites"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDASO_MTH} 1000 1" 
SORT_I2="${EST_FTECLEDA_MVT_ALL} 1000 1"
SORT_I3="${EPO_FTECLEDA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_ALL_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT



NSTEP=${NJOB}_45
# Begin Remove
#--------------------------------------------------------------------------
LIBEL="cp ${EPO_FTECLEDASO_MVT} ${DSAV}/${SVG}_${ENV_PREFIX}_ESPD3800_FTECLEDASO_MVT.dat"
EXECKSH "cp ${EPO_FTECLEDASO_MVT} ${DSAV}/${SVG}_${ENV_PREFIX}_ESPD3800_FTECLEDASO_MVT.dat"

NSTEP=${NJOB}_20
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
RMFIL "${EPO_FTECLEDASO_MVT}"

#[003]
NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Get ESB from Pericase for FTECLEDASO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDASO_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDASO.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        all_cols1        1:1 - 118:,
        PER_SSD_CF       1:1 -  1:,
        PER_CTR_NF       3:1 -  3:,
        PER_END_NT       4:1 -  4:,
        PER_SEC_NF       5:1 -  5:,
        PER_UWY_NF       6:1 -  6:,
        PER_UW_NT        7:1 -  7:,
        PER_ESB_CF       8:1 -  8:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT 
/INFILE ${EPO_OIADVPERICASE} 1000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT 
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols1
       ,rightside:PER_ESB_CF
exit
EOF
SORT


NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="Replace ESB from Pericase to FTECLEDASO Cumul"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_FTECLEDASO.dat 1000 1 "
SORT_O="${EPO_FTECLEDASO} 1000 1"   # [004] EPO_FTECLEDASO au lieu de EPO_FTECLEDA
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -   1:,
        ESB_CF           2:1 -   2:,
        TRNCOD1_CF       6:1 -   6:1,
        CTR_NF           8:1 -   8:,
        END_NT           9:1 -   9:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        UW_NT           12:1 -  12:,
        all_cols1        3:1 - 118:,
        PER_ESB_CF     119:1 - 119:
/CONDITION blanc PER_ESB_CF = "" OR TRNCOD1_CF = "2" OR TRNCOD1_CF = "4"
/DERIVEDFIELD PER2_ESB_CF if blanc then ESB_CF else PER_ESB_CF
/OUTFILE   ${SORT_O}
/REFORMAT SSD_CF, PER2_ESB_CF, all_cols1
exit
EOF
SORT

NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
LIBEL="Get ESB from Pericase "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_FTECLEDA_ALL_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_ALL_O.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        all_cols1        1:1 - 118:,
        PER_SSD_CF       1:1 -  1:,
        PER_CTR_NF       3:1 -  3:,
        PER_END_NT       4:1 -  4:,
        PER_SEC_NF       5:1 -  5:,
        PER_UWY_NF       6:1 -  6:,
        PER_UW_NT        7:1 -  7:,
        PER_ESB_CF       8:1 -  8:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT 
/INFILE ${EPO_OIADVPERICASE} 1000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT 
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols1
       ,rightside:PER_ESB_CF
exit
EOF
SORT



NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
LIBEL="Replace ESB from Pericase to FTECLEDA_ALL "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDA_ALL_O.dat 1000 1 "
SORT_O="${EST_FTECLEDA_MULTISITE} 1000 1"   
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -   1:,
        ESB_CF           2:1 -   2:,
        TRNCOD1_CF       6:1 -   6:1,
        CTR_NF           8:1 -   8:,
        END_NT           9:1 -   9:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        UW_NT           12:1 -  12:,
        all_cols1        3:1 - 118:,
        PER_ESB_CF     119:1 - 119:
/CONDITION blanc PER_ESB_CF = "" OR TRNCOD1_CF = "2" OR TRNCOD1_CF = "4"
/DERIVEDFIELD PER2_ESB_CF if blanc then ESB_CF else PER_ESB_CF
/OUTFILE   ${SORT_O}
/REFORMAT SSD_CF, PER2_ESB_CF, all_cols1
exit
EOF
SORT




touch ${EPO_FTECLEDASO_MVT}

JOBEND


