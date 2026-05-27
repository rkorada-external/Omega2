#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATES Retrocession closing period process
# nom du script SHELL            : ESID2501.cmd
# revision                       : $Revision:   1.6  $
# date de creation               : 03/10/1997
# auteur                         : CGI
# references des specifications  :
#-----------------------------------------------------------------------------
# Description :  Preparation of cession and placement files
#
#
# Output file sort ${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_O.dat
#                  ${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat
#                  ${EST_FCES}
#                  ${DFILT}/${NSTEP}_${IB}_SORT_PLC_O.dat
#                  ${EST_FPLC}
#
#
# Launch C programs ESTC2301 and ESTC2302
#
# JOB LAUNCHED BY : ESID2500.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001] 15/06/2012 Roger Cassis :spot:23802 - Modifications pour Solvency - ajout sortie ESTC2301
#[002] 20/11/2019 M.NAJI Spira 81838  remplacement du fichier temporaire ${DFILT}/${NJOB}_20_${IB}_ESTC2301_CES_O.dat par $EST_FCES_NEW
#[003] 26/02/2021 M.NAJI Spira 91531  commenter les suppression des fichier permanents  
##===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job initialisation
JOBINIT

# Get parameters

#[003]
#NSTEP=${NJOB}_00
##Last version of ESID2500 files deletion
##-----------------------------------------------------------------
#RMFIL "  `dirname ${EST_DLREGTAR}`/${PCH}ESID2500_DLREGTAR*.dat
# `dirname ${EST_DLREGTR}`/${PCH}ESID2500_DLREGTR*.dat
# `dirname ${EST_DLREMAJGTAR}`/${PCH}ESID2500_DLREMAJGTAR*.dat
# `dirname ${EST_DLREMAJGTR}`/${PCH}ESID2500_DLREMAJGTR*.dat
# `dirname ${EST_DLRPGTAR}`/${PCH}ESID2500_DLRPGTAR*.dat
# `dirname ${EST_DLRPGTR}`/${PCH}ESID2500_DLRPGTR*.dat
# `dirname ${EST_DLRTCGTAR}`/${PCH}ESID2500_DLRTCGTAR*.dat
# `dirname ${EST_DLRTCGTR}`/${PCH}ESID2500_DLRTCGTR*.dat
# `dirname ${EST_DLRTGTAR}`/${PCH}ESID2500_DLRTGTAR*.dat
# `dirname ${EST_DLRTGTR}`/${PCH}ESID2500_DLRTGTR*.dat
# `dirname ${EST_DLRTFGTAR}`/${PCH}ESID2500_DLRTFGTAR*.dat
# `dirname ${EST_DLRTFGTR}`/${PCH}ESID2500_DLRTFGTR*.dat
# `dirname ${EST_FBESTCESSION}`/${PCH}ESID2500_FBESTCESSION*.dat
# `dirname ${EST_FBESTCONPAR}`/${PCH}ESID2500_FBESTCONPAR*.dat
# `dirname ${EST_FCES}`/${PCH}ESID2500_FCES*.dat
# `dirname ${EST_FPLC}`/${PCH}ESID2500_FPLC*.dat
# `dirname ${EST_FPLCCOM}`/${PCH}ESID2500_FPLCCOM*.dat"


NSTEP=${NJOB}_05
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting acceptance perimeter file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCESSION}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new cession file..."
PRG=ESTC2301
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_IADVPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_CES_O.dat
#[002] export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CES_O.dat
export ${PRG}_O1=${EST_FCES_NEW}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETNP_SEGMENT_O.dat    #[001]
EXECPRG

NSTEP=${NJOB}_25
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_IADVPERICASE_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_CES_O.dat

NSTEP=${NJOB}_30
# Begin Sort
# Warning : do not remove this step!!!
# All other steps using the file EST_FCES assume that it is already
# sorted according to ctr_nf/end_nt/sec_nf/uwy_nf/uw_nt/
# retctr_nf/retend_nt/retsec_nf/rty_nf/retuw_nt
#-----------------------------------------------------------------------------
LIBEL="Sorting new cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#[002]SORT_I=${DFILT}/${NJOB}_20_${IB}_ESTC2301_CES_O.dat
SORT_I=${EST_FCES_NEW}
SORT_O="${EST_FCES} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: ,
        SEC_NF 3:1 - 3: ,
        UWY_NF 4:1 - 4: ,
        UW_NT 5:1 - 5: ,
        RETCTR_NF 6:1 - 6:,
        RETEND_NT 7:1 - 7: ,
        RETSEC_NF 8:1 - 8: ,
        RTY_NF 9:1 - 9: ,
        RETUW_NT 10:1 - 10:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION RETRO RETCTR_NF EQ ""
/OMIT RETRO
exit
EOF
SORT



NSTEP=${NJOB}_40
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLACEMT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PLC_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4: ,
        RETSEC_NF 5:1 - 5: ,
        RTY_NF 6:1 - 6: ,
        RETUW_NT 7:1 - 7:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_45
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting commuted placement file ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLACEMTCOM}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PLCCOM_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4: ,
        RETSEC_NF 5:1 - 5: ,
        RTY_NF 6:1 - 6: ,
        RETUW_NT 7:1 - 7:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT


NSTEP=${NJOB}_50
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new placement file..."
PRG=ESTC2302
export ${PRG}_I1=${EST_IRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_40_${IB}_SORT_PLC_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PLC_O.dat
EXECPRG

NSTEP=${NJOB}_53
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new placement file..."
PRG=ESTC2302
export ${PRG}_I1=${EST_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_45_${IB}_SORT_PLCCOM_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PLCCOM_O.dat
EXECPRG


NSTEP=${NJOB}_55
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_PLC_O.dat
RMFIL ${DFILT}/${NJOB}_45_${IB}_SORT_PLCCOM_O.dat


NSTEP=${NJOB}_60
# Begin Sort
# Warning : do not remove this step!!!
# All other steps using the file EST_FPLC assume that it is already
# sorted according to retctr_nf/retend_nt/retsec_nf/rty_nf/retuw_nt/plc_nt
#-----------------------------------------------------------------------------
LIBEL="Sorting new placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_50_${IB}_ESTC2302_PLC_O.dat
SORT_O="${EST_FPLC} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4: ,
        RETSEC_NF 5:1 - 5: ,
        RTY_NF 6:1 - 6: ,
        RETUW_NT 7:1 - 7: ,
        PLC_NT 8:1 - 8:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_63
# Begin Sort
# Warning : do not remove this step!!!
# All other steps using the file EST_FPLC assume that it is already
# sorted according to retctr_nf/retend_nt/retsec_nf/rty_nf/retuw_nt/plc_nt
#-----------------------------------------------------------------------------
LIBEL="Sorting new placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_53_${IB}_ESTC2302_PLCCOM_O.dat
SORT_O="${EST_FPLCCOM} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4: ,
        RETSEC_NF 5:1 - 5: ,
        RTY_NF 6:1 - 6: ,
        RETUW_NT 7:1 - 7: ,
        PLC_NT 8:1 - 8:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT
exit
EOF
SORT


NSTEP=${NJOB}_65
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Erase temporary file"
RMFIL "${DFILT}/${NJOB}_50_${IB}_ESTC2302_PLC_O.dat"
RMFIL "${DFILT}/${NJOB}_53_${IB}_ESTC2302_PLCCOM_O.dat"

############################################
# Warning : do not remove the file ${NJOB}_20_${IB}_ESTC2301_CES_O.dat
# at the end of this job (this file is used in the next job ESID2502.cmd)
############################################

JOBEND

