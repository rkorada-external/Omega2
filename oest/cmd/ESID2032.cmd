#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESID2032.cmd
# revision                      : $Revision: 1.6 $
# date de creation              : 06/03/03
# auteur                        : J. RIBOT
# references des specifications : SPOT-5075
#-----------------------------------------------------------------------------
# description :
#   Predictions Update
#   Launch C programs ESTC2040, ESTC2147, ESTC2132, ESTC2133, ESTC2134, ESTC2135
#
#   Output file sort
#		   ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat
#
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
#
# J.Ribot 20/08/2004  ajout step 02 20 25 400 et 405 pour gestion des fichiers envoi filiales
#                     modif step 330 ajout ==> SORT_NOINFILE="YES"
#
# J.Ribot 20/08/2005  prise en compte FPLACEMT1 pour creation FVPLACEMT1 (SPOT 11167)
#
# J.Ribot 04/04/2008  ajout acces FLIFDRI pour test COMACC_B (SPOT 14633)
#         18/04/2008  ajout acces CPLIFDRI pour test COMACC_B (SPOT 14633) (remplace FLIFDRI)
#_________________
#MODIFICATION    [005]
#Auteur:         D.GATIBELZA
#Date:           15/09/2010
#Version:        10.1
#Description:    ESTVIE19177 V10 Mettre en place un calcul spécial de DAC pour Köln
#                automatic DAC calculation taking into account the fanancing commission, the technical result, the interest on deposit
#[006]  20/04/2011  Roger Cassis :spot:21655 - tris pas en numerique sur la section.
#[007]  19/03/2014  Roger Cassis :spot:25427 - Ajout gzip de fichiers temporaires
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd
#. /home/scordev/oest/work/cmd/bruno/scripts/overwrite_execprg

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3

# Job Initialisation
JOBINIT

LIFEP=0

if test -f ${EST_LIFEP}
then
LIFEP=1

NSTEP=${NJOB}_01
# Delete internal retro for dbclo periode for VLIFEST195
#------------------------------------------------------------------------------
LIBEL="Delete internal retro for dbclo periode for VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN,
        CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ORICOD_LS 31:1 - 31:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT,
      CUR_CF
/CONDITION RET_INTERN ( BALSHEY_NF = '${BALSHTYEA_NF}' AND  BALSHTMTH_NF = ${BALSHTMTH_NF}
               AND ORICOD_LS = 'RETRO INTERNE' AND ${EST_SORT_CONDITION})
/OUTFILE  ${SORT_O}
/OMIT RET_INTERN
exit
EOF
SORT


NSTEP=${NJOB}_03
# Delete internal retro for dbclo periode for CPLIFEST
#------------------------------------------------------------------------------
LIBEL="Delete internal retro for dbclo periode for CPLIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CPLIFEST} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CPLIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        CRE_D 6:1 - 6:,
        BALSHEY_NF 7:1 - 7:,
        BALSHTMTH_NF 8:1 - 8:EN,
        ACY_NF 9:1 - 9:,
        PRS_CF 10:1 - 10:,
        ACMTRS_NT 11:1 - 11:,
        SSD_CF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3,
        INDSUP_B 15:1 - 15:,
        ORICOD_LS 16:1 - 16:,
        CREUSR_CF 17:1 - 17:,
        LSTUPD_D 18:1 - 18:,
        LSTUPDUSR_CF 19:1 - 19:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT,
      CUR_CF
/CONDITION RET_INTERN ( BALSHEY_NF = '${BALSHTYEA_NF}' AND  BALSHTMTH_NF = ${BALSHTMTH_NF}
               AND ORICOD_LS = 'RETRO INTERNE' AND ${EST_SORT_CONDITION})
/OUTFILE  ${SORT_O}
/OMIT RET_INTERN
exit
EOF
SORT

NSTEP=${NJOB}_05
# move 01_SORT_VLIFEST195_O.dat ==> ${EST_VLIFEST195}
#------------------------------------------------------------------------------
LIBEL="move 01_SORT_VLIFEST195_O.dat ==> ${EST_VLIFEST195}"
EXECKSH "mv ${DFILT}/${NJOB}_01_${IB}_SORT_VLIFEST195_O.dat ${EST_VLIFEST195}"

NSTEP=${NJOB}_06
# move 03_SORT_CPLIFEST_O.dat ==> ${EST_CPLIFEST}
#------------------------------------------------------------------------------
LIBEL="move 03_SORT_CPLIFEST_O.dat ==> ${EST_CPLIFEST}"
EXECKSH "mv ${DFILT}/${NJOB}_03_${IB}_SORT_CPLIFEST_O.dat ${EST_CPLIFEST}"


NSTEP=${NJOB}_08
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_01_${IB}_SORT_VLIFEST195_O.dat
RMFIL ${DFILT}/${NJOB}_03_${IB}_SORT_CPLIFEST_O.dat

fi

NSTEP=${NJOB}_09
# Delete internal retro for dbclo periode for LIFESTNOACC
#------------------------------------------------------------------------------
LIBEL="Delete internal retro for dbclo periode for LIFESTNOACC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_LIFESTNOACC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFESTNOACC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN,
        CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        ORICOD_LS 31:1 - 31:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      BALSHEY_NF,
      BALSHTMTH_NF,
      CRE_D
/CONDITION RET_INTERN ( BALSHEY_NF = '${BALSHTYEA_NF}' AND  BALSHTMTH_NF = ${BALSHTMTH_NF}
               AND ORICOD_LS = 'RETRO INTERNE' AND ${EST_SORT_CONDITION})
/OUTFILE  ${SORT_O}
/OMIT RET_INTERN
exit
EOF
SORT

NSTEP=${NJOB}_10
#Last version of ESID2560 files deletion
#-----------------------------------------------------------------
RMFIL "`dirname ${EST_LIFESTNOACC}`/${PCH}ESID2030_LIFESTNOACC*.dat"

NSTEP=${NJOB}_13
# move 09_SORT_LIFESTNOACC_O.dat ==> ${EST_LIFESTNOACC}
#------------------------------------------------------------------------------
LIBEL="move 09_SORT_LIFESTNOACC_O.dat ==> ${EST_LIFESTNOACC}"
EXECKSH "mv ${DFILT}/${NJOB}_09_${IB}_SORT_LIFESTNOACC_O.dat ${EST_LIFESTNOACC}"

NSTEP=${NJOB}_15
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_09_${IB}_SORT_LIFESTNOACC_O.dat

if [ ${NCHAIN} = "${PCH}ESID1530" ]
then

NSTEP=${NJOB}_17
# move EST_VLIFEST195 ==> DFILT _OLD_VLIFEST195.dat
#------------------------------------------------------------------------------
LIBEL="move EST_VLIFEST195 ==> DFILT _OLD_VLIFEST195.dat"
EXECKSH "mv ${EST_VLIFEST195} ${DFILT}/${NSTEP}_${IB}_OLD_VLIFEST195.dat"

NSTEP=${NJOB}_15
# Delete  file TRANSFERT
#-----------------------------------------------------------------------------
LIBEL="Delete file"
RMFIL " `dirname ${EST_LIFTRANSFR}`/${PCH}ESID1530_LIFTRANSFR.dat
        `dirname ${EST_DLRLIFEP}`/${PCH}ESID1530_DLRLIFEP.dat"

fi

NSTEP=${NJOB}_30
# move EST_CPLIFEST ==> DFILT _OLD_CPLIFEST.dat
#------------------------------------------------------------------------------
LIBEL="move EST_CPLIFEST ==> DFILT _OLD_CPLIFEST.dat"
EXECKSH "mv ${EST_CPLIFEST} ${DFILT}/${NSTEP}_${IB}_OLD_CPLIFEST.dat"

NSTEP=${NJOB}_35
# SORT & REFORMAT received file
#---------------------------------------------------------------------------
LIBEL="SORT & REFORMAT received file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${EST_LIFEP} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEP_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ZONE1 1:1 - 38:,
        ZONE2 39:1 - 42:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/OUTFILE  ${SORT_O}
/REFORMAT  ZONE1
exit
EOF
SORT


NSTEP=${NJOB}_40
#Syncro perimetre / retro interne
#------------------------------------------------------------------------------
LIBEL="Syncro perimeter file / retro interne"
PRG=ESTC7607
export ${PRG}_I1=${EST_IARVPERICASE0}
export ${PRG}_I2=${DFILT}/${NJOB}_35_${IB}_SORT_LIFEP_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${EST_CPLIFDRI}
export ${PRG}_O1=${EST_DLRLIFEP}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANOS_O.dat
EXECPRG

NSTEP=${NJOB}_50
#Syncro perimetre / retro interne
#------------------------------------------------------------------------------
LIBEL="Formatting of the data"
WS_BATCH_NAME=ESID2050
WS_INPUT_FILE=${DFILT}/${NJOB}_40_${IB}_ESTC7607_ANOS_O.dat
WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_ANOS_O.dat
WS_BATCH

NSTEP=${NJOB}_260
#Retro Generation, Placements File Sort
#------------------------------------------------------------------------------
LIBEL="Retro Generation, Placements File Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMT1} 1000 1"
SORT_O="${EST_FVPLACEMT1} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        LOB_CF 18:1 - 18:,
        RETCTR_NF 3:1 - 3:, RETSEC_NF 5:1 - 5:, RTY_NF 6:1 - 6:
/KEYS RETCTR_NF, RETSEC_NF, RTY_NF
/CONDITION LOB_25_OU_31 ((LOB_CF = "30") OR (LOB_CF = "31"))
/INCLUDE LOB_25_OU_31
exit
EOF
SORT

#        LOB_CF 17:1 - 17:,

NSTEP=${NJOB}_262
#Retro Generation, Cession File Sort
#------------------------------------------------------------------------------
LIBEL="Retro Generation, Cession File Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCESSION0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VVERS_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 6:1 - 6:,
        RETSEC_NF 8:1 - 8:,
        RTY_NF 9:1 - 9:,
        LOB_CF 21:1 - 21:,
        RETCTRCAT_CF 16:1 - 16:,
        SSD_CF 14:1 - 14: EN
/KEYS RETCTR_NF,
      RETSEC_NF,
       RTY_NF
/CONDITION LOB_RETCTRCAT (((LOB_CF = "30") OR (LOB_CF = "31")) AND
                         ((RETCTRCAT_CF = "01") OR (RETCTRCAT_CF = "06")))
/INCLUDE LOB_RETCTRCAT
exit
EOF
SORT

NSTEP=${NJOB}_265
#Retro Generation, Cession File Sort
#------------------------------------------------------------------------------
LIBEL="Retro Generation, Cession File Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_262_${IB}_SORT_VVERS_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VVERS_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        RETCTR_NF 6:1 - 6:,
        RETSEC_NF 8:1 - 8:,
        RTY_NF 9:1 - 9:,
        LOB_CF 21:1 - 21:,
        RETCTRCAT_CF 16:1 - 16:,
        SSD_CF 14:1 - 14: EN
/KEYS RETCTR_NF,
      RETSEC_NF,
       RTY_NF
/CONDITION NONVIE   ( SSD_CF = 5 OR SSD_CF = 6)
/OMIT NONVIE
/OUTFILE  ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_270
# Synchro Cessions + Placements
#------------------------------------------------------------------------------
LIBEL="Synchro Cessions + Placements"
PRG=ESTC2147
export ${PRG}_I1=${EST_FVPLACEMT1}
export ${PRG}_I2=${DFILT}/${NJOB}_265_${IB}_SORT_VVERS_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VPLACEMT_O.dat
EXECPRG

NSTEP=${NJOB}_275
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_265_${IB}_SORT_VVERS_O.dat

NSTEP=${NJOB}_280
#Retro Generation, Placements File Sort
#------------------------------------------------------------------------------
LIBEL="Retro Generation, Placements File Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_270_${IB}_ESTC2147_VPLACEMT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VPLACEMT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        RETCTR_NF 3:1 - 3:,
        RTY_NF 6:1 - 6:,
        PLC_NT 8:1 - 8:
/KEYS RETCTR_NF, RTY_NF, PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_285
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_270_${IB}_ESTC2147_VPLACEMT_O.dat

NSTEP=${NJOB}_290
# Searches for claims and URR Funds Withheld Rates
#------------------------------------------------------------------------------
LIBEL="Searches for claims and URR Funds Withheld Rates"
PRG=ESTC2132
export ${PRG}_I1=${DFILT}/${NJOB}_280_${IB}_SORT_VPLACEMT_O.dat
export ${PRG}_I2=${EST_FDEPOSIT0}
export ${PRG}_I3=${EST_FPFUNWIT0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VPLACEMT_O.dat
EXECPRG

NSTEP=${NJOB}_295
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_280_${IB}_SORT_VPLACEMT_O.dat

NSTEP=${NJOB}_300
# Searches for Interest Rates on OLR and URR Funds Withheld
#------------------------------------------------------------------------------
LIBEL="Searches for Interest Rates on OLR and URR Funds Withheld"
PRG=ESTC2133
export ${PRG}_I1=${DFILT}/${NJOB}_290_${IB}_ESTC2132_VPLACEMT_O.dat
export ${PRG}_I2=${EST_FINTWIT}
export ${PRG}_I3=${EST_FPINTWIT0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VPLACEMT_O.dat
EXECPRG

NSTEP=${NJOB}_305
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_290_${IB}_ESTC2132_VPLACEMT_O.dat

NSTEP=${NJOB}_310
# Placements File Sort
#------------------------------------------------------------------------------
LIBEL="Placements File Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_300_${IB}_ESTC2133_VPLACEMT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VPLACEMT_O.dat 1000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        RETCTR_NF 3:1 - 3:,
        RETSEC_NF 5:1 - 5:,
        RTY_NF    6:1 - 6:,
        CTR_NF   21:1 - 21:,
        SEC_NF  23:1 - 23:,
        UWY_NF  24:1 - 24:
/KEYS RETCTR_NF, RETSEC_NF, RTY_NF, CTR_NF, SEC_NF, UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_315
# Accumulation of all Placements Rates
#------------------------------------------------------------------------------
LIBEL="Accumulation of all Placements Rates"
PRG=ESTC2134
export ${PRG}_I1=${DFILT}/${NJOB}_310_${IB}_SORT_VPLACEMT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VPLACEMT_O.dat
EXECPRG

NSTEP=${NJOB}_320
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_300_${IB}_ESTC2133_VPLACEMT_O.dat
RMFIL ${DFILT}/${NJOB}_310_${IB}_SORT_VPLACEMT_O.dat

NSTEP=${NJOB}_325
# Placements File Sort
#------------------------------------------------------------------------------
LIBEL="Placements File Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_315_${IB}_ESTC2134_VPLACEMT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VPLACEMT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 21:1 - 21:,
        END_NT 22:1 - 22:,
        SEC_NF 23:1 - 23:,
        UWY_NF 24:1 - 24:,
        UW_NT 25:1 - 25:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_327
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_315_${IB}_ESTC2134_VPLACEMT_O.dat

NSTEP=${NJOB}_330
# Annual Estimates Merge for Retrocession Generation
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Merge for Retrocession Generation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_I2="${EST_DLRLIFEP} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_335
# Estimates Calculations Generation RETRO AUTO
#------------------------------------------------------------------------------
LIBEL="Estimates Calculations Generation RETRO AUTO"
PRG=ESTC2135
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
CRE_D ${CRE_D}
BALSHTMTH_NF ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_325_${IB}_SORT_VPLACEMT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_330_${IB}_SORT_LIFEST_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${EST_CPLIFDRI}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O.dat
export ${PRG}_O2=${EST_LIFDANO}
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_325_${IB}_SORT_VPLACEMT_O.dat  > ${DFILT}/${NJOB}_325_SORT_VPLACEMT_O.dat.gz
gzip -c ${DFILT}/${NJOB}_330_${IB}_SORT_LIFEST_O.dat    > ${DFILT}/${NJOB}_330_SORT_LIFEST_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2135_LIFEST_O.dat   > ${DFILT}/${NJOB}_335_ESTC2135_LIFEST_O.dat.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------


NSTEP=${NJOB}_338
# Merged TL file Sort
#------------------------------------------------------------------------------
LIBEL="Merged TL file Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_335_${IB}_ESTC2135_LIFEST_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACMTRS_NT 10:1 - 10:
/KEYS ACMTRS_NT
exit
EOF
SORT

NSTEP=${NJOB}_339
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_335_${IB}_ESTC2135_LIFEST_O.dat

NSTEP=${NJOB}_340
# Synchro Cessions + Placements
#------------------------------------------------------------------------------
LIBEL="Synchro prev + AccPar"
PRG=ESTC2155
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_VACCPAR120}
export ${PRG}_I2=${DFILT}/${NJOB}_338_${IB}_SORT_LIFEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_338_${IB}_SORT_LIFEST_O.dat  > ${DFILT}/${NJOB}_338_SORT_LIFEST_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2155_LIFEST_O.dat > ${DFILT}/${NJOB}_340_ESTC2155_LIFEST_O.dat.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------

NSTEP=${NJOB}_341
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_338_${IB}_SORT_LIFEST_O.dat

NSTEP=${NJOB}_342
# Merging Annual Estimates for Sybase Insertion
#------------------------------------------------------------------------------
LIBEL="Merging Annual Estimates for Sybase Insertion"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_330_${IB}_SORT_LIFEST_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_340_${IB}_ESTC2155_LIFEST_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        ESTMNT_M 14:1 - 14:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT
/SUMMARIZE TOTAL ESTMNT_M
exit
EOF
SORT




NSTEP=${NJOB}_344

# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_330_${IB}_SORT_LIFEST_O.dat
RMFIL ${DFILT}/${NJOB}_340_${IB}_ESTC2155_LIFEST_O.dat

NSTEP=${NJOB}_345
# Complete Accounts Screen and Sort
#------------------------------------------------------------------------------
LIBEL="Complete Accounts Screen and Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_342_${IB}_SORT_LIFEST_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3,
        ORICOD_LS 31:1 - 31:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      BALSHEY_NF,
      ACY_NF,
      ACMTRS_NT,
      ESTMNT_M,
      CUR_CF,
      ORICOD_LS,
      CRE_D
exit
EOF
SORT

NSTEP=${NJOB}_348
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_342_${IB}_SORT_LIFEST_O.dat

NSTEP=${NJOB}_350
# Complete Account Screen
#------------------------------------------------------------------------------
LIBEL="Complete Account Screen"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_345_${IB}_SORT_LIFEST_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:,
        ACY_NF 7:1 - 7:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3,
        ORICOD_LS 31:1 - 31:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      BALSHEY_NF,
      ACY_NF,
      ACMTRS_NT,
      ESTMNT_M,
      CUR_CF,
      ORICOD_LS
/STABLE
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_352
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_345_${IB}_SORT_LIFEST_O.dat

NSTEP=${NJOB}_355
# Annual Estimates Sort
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_350_${IB}_SORT_LIFEST_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHMTH_NF 12:1 - 12:EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      BALSHEY_NF DESCENDING,
      BALSHMTH_NF DESCENDING,
      CRE_D DESCENDING
exit
EOF
SORT

NSTEP=${NJOB}_358
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_350_${IB}_SORT_LIFEST_O.dat

NSTEP=${NJOB}_360
# Annual Estimates Screen
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC2040
export ${PRG}_I1=${DFILT}/${NJOB}_355_${IB}_SORT_LIFEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LAST_LIFEST_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_OLD_LIFEST_O2.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_355_${IB}_SORT_LIFEST_O.dat       > ${DFILT}/${NJOB}_355_SORT_LIFEST_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_LAST_LIFEST_O1.dat  > ${DFILT}/${NJOB}_360_ESTC2040_LAST_LIFEST_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_OLD_LIFEST_O2.dat   > ${DFILT}/${NJOB}_360_ESTC2040_OLD_LIFEST_O2.dat.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------

NSTEP=${NJOB}_362
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_355_${IB}_SORT_LIFEST_O.dat

NSTEP=${NJOB}_365
# Merging Annual Estimates for Sybase Insertion
#------------------------------------------------------------------------------
LIBEL="Merging Annual Estimates for Sybase Insertion"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_360_${IB}_ESTC2040_LAST_LIFEST_O1.dat"
SORT_O="${EST_VLIFEST195} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT,
      CUR_CF
/SUMMARIZE TOTAL ESTMNT_M
exit
EOF
SORT

NSTEP=${NJOB}_368
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_360_${IB}_ESTC2040_LAST_LIFEST_O1.dat

#if test -f ${EST_LIFEP}

if [ ${LIFEP} -ne 0 ]
then


echo ${LIFEP}

NSTEP=${NJOB}_370
# Retrocession Amounts
#----------------------------------------------------------------------------
LIBEL="Retrocession Amounts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_I2="${DFILT}/${NJOB}_360_${IB}_ESTC2040_OLD_LIFEST_O2.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN,
        CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3,
        INDSUP_B 30:1 - 30:,
        ORICOD_LS 31:1 - 31:,
        CREUSR_CF 32:1 - 32:,
        LSTUPD_D 33:1 - 33:,
        LSTUPDUSR_CF 34:1 - 34:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT,
      CUR_CF
/CONDITION RETAUTO ((CRE_D = "${CRE_D} 23:59:15" AND ORICOD_LS = 'RETRO AUTO') OR
                   ( BALSHEY_NF = '${BALSHTYEA_NF}' AND  BALSHTMTH_NF = ${BALSHTMTH_NF}
                     AND ORICOD_LS = 'RETRO INTERNE' AND ${EST_SORT_CONDITION}))
/DERIVEDFIELD PRS_CF "500~"
/OUTFILE  ${SORT_O}
/INCLUDE RETAUTO
/REFORMAT CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          CRE_D,
          BALSHEY_NF,
          BALSHTMTH_NF,
          ACY_NF,
          PRS_CF,
          ACMTRS_NT,
          SSD_CF,
          CUR_CF,
          ESTMNT_M,
          INDSUP_B,
          ORICOD_LS,
          CREUSR_CF,
          LSTUPD_D,
          LSTUPDUSR_CF
exit
EOF
SORT

else

NSTEP=${NJOB}_372
# Retrocession Amounts
#----------------------------------------------------------------------------
LIBEL="Retrocession Amounts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_I2="${DFILT}/${NJOB}_360_${IB}_ESTC2040_OLD_LIFEST_O2.dat"
SORT_O="${DFILT}/${NJOB}_370_${IB}_SORT_VLIFEST195_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN,
        CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3,
        INDSUP_B 30:1 - 30:,
        ORICOD_LS 31:1 - 31:,
        CREUSR_CF 32:1 - 32:,
        LSTUPD_D 33:1 - 33:,
        LSTUPDUSR_CF 34:1 - 34:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT,
      CUR_CF
/CONDITION RETAUTO  (CRE_D = "${CRE_D} 23:59:15" AND ORICOD_LS = 'RETRO AUTO')
/DERIVEDFIELD PRS_CF "500~"
/OUTFILE  ${SORT_O}
/INCLUDE RETAUTO
/REFORMAT CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          CRE_D,
          BALSHEY_NF,
          BALSHTMTH_NF,
          ACY_NF,
          PRS_CF,
          ACMTRS_NT,
          SSD_CF,
          CUR_CF,
          ESTMNT_M,
          INDSUP_B,
          ORICOD_LS,
          CREUSR_CF,
          LSTUPD_D,
          LSTUPDUSR_CF
exit
EOF
SORT

NSTEP=${NJOB}_375
# delete LIFEP cree par le NOINFILE = YES
#-----------------------------------------------------------------
RMFIL " `dirname ${EST_LIFEP}`/${PCH}ESCJ0060_LIFEP*.dat"

fi

NSTEP=${NJOB}_376
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_360_${IB}_ESTC2040_OLD_LIFEST_O2.dat

NSTEP=${NJOB}_378
# Inversion of estimates retrocession amounts before loading
#-----------------------------------------------------------------------------
LIBEL="Inversion of estimates retrocession amounts before loading"
AWK_I=${DFILT}/${NJOB}_370_${IB}_SORT_VLIFEST195_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_VLIFEST195_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
        { if( \$11 < "2000" ) { print \$0 }}
		{ if( \$11 > "2000" ) { \$14 = sprintf("%-.3lf",-\$14) ; print \$0 }}
exit
EOF
AWK

NSTEP=${NJOB}_380
# Merging Annual Estimates for Sybase Insertion
#------------------------------------------------------------------------------
LIBEL="Merging Annual Estimates for Sybase Insertion"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_378_${IB}_AWK_VLIFEST195_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_30_${IB}_OLD_CPLIFEST.dat 1000 1"
SORT_O="${EST_CPLIFEST} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        CRE_D 6:1 - 6:,
        BALSHEY_NF 7:1 - 7:,
        BALSHTMTH_NF 8:1 - 8:EN,
        ACY_NF 9:1 - 9:,
        PRS_CF 10:1 - 10:,
        ACMTRS_NT 11:1 - 11:,
        SSD_CF 12:1 - 12:,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3,
        INDSUP_B 15:1 - 15:,
        ORICOD_LS 16:1 - 16:,
        CREUSR_CF 17:1 - 17:,
        LSTUPD_D 18:1 - 18:,
        LSTUPDUSR_CF 19:1 - 19:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT,
      CUR_CF
/SUM TOTAL ESTMNT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_382
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_30_${IB}_OLD_CPLIFEST.dat
RMFIL ${DFILT}/${NJOB}_370_${IB}_SORT_VLIFEST195_O.dat

NSTEP=${NJOB}_385
# Merging Annual Estimates for Sybase Insertion
#[005] ajout CNA AUTO 5 dans la condition
#------------------------------------------------------------------------------
LIBEL="Merging Annual Estimates for Sybase Insertion"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1 1:1 - 8:,
        SSD_CF 1:1 - 1:EN,
        CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        FILLER2 10:1 - 37:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3,
        INDSUP_B 30:1 - 30:,
        ORICOD_LS 31:1 - 31:,
        CREUSR_CF 32:1 - 32:,
        LSTUPD_D 33:1 - 33:,
        LSTUPDUSR_CF 34:1 - 34:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT,
      CUR_CF
/CONDITION NOACC ( (ACY_NF > "${BALSHTYEA_NF}")     AND
                   ( (CRE_D = "${CRE_D} 23:59:15" AND ORICOD_LS = 'RETRO AUTO')     OR
                     (CRE_D = "${CRE_D} 23:59:50" AND ORICOD_LS = 'CNA AUTO')       OR
                     (CRE_D = "${CRE_D} 23:59:50" AND ORICOD_LS = 'CNA AUTO 5')     OR
                     ( BALSHEY_NF = '${BALSHTYEA_NF}'   AND
                       BALSHTMTH_NF = ${BALSHTMTH_NF}   AND
                       ORICOD_LS = 'RETRO INTERNE'      AND
                       ${EST_SORT_CONDITION})))
/DERIVEDFIELD PRS_CF "500~"
/OUTFILE  ${SORT_O}
/INCLUDE NOACC
/REFORMAT  FILLER1,
           PRS_CF,
           FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_390
# Annual Estimates Sort
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_LIFESTNOACC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFESTNOACC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHMTH_NF 12:1 - 12:EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      BALSHEY_NF DESCENDING,
      BALSHMTH_NF DESCENDING,
      CRE_D DESCENDING
exit
EOF
SORT

NSTEP=${NJOB}_395
# Annual Estimates Sort
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_385_${IB}_SORT_VLIFEST195_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_390_${IB}_SORT_LIFESTNOACC_O.dat 1000 1"
SORT_O="${EST_LIFESTNOACC} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHMTH_NF 12:1 - 12:EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      BALSHEY_NF DESCENDING,
      BALSHMTH_NF DESCENDING,
      CRE_D DESCENDING
exit
EOF
SORT

NSTEP=${NJOB}_398
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_385_${IB}_SORT_VLIFEST195_O.dat
RMFIL ${DFILT}/${NJOB}_390_${IB}_SORT_LIFESTNOACC_O.dat

if [ ${NCHAIN} = "${PCH}ESID1530" ]
then

NSTEP=${NJOB}_425
# create EST_LIFTRANSFR pour ESID2040 internal retro only
#------------------------------------------------------------------------------
LIBEL="create EST_LIFTRANSFR pour ESID2040 internal retro only "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_O="${EST_LIFTRANSFR} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT,
      CUR_CF
/SUMMARIZE TOTAL ESTMNT_M
exit
EOF
SORT



NSTEP=${NJOB}_430
# Merging Create vlifest195
#------------------------------------------------------------------------------
LIBEL="Merging Create vlifest195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_17_${IB}_OLD_VLIFEST195.dat 1000 1"
SORT_I2="${EST_LIFTRANSFR} 1000 1"
SORT_O="${EST_VLIFEST195}  OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ESTMNT_M 14:1 - 14:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT,
      CUR_CF
/SUMMARIZE TOTAL ESTMNT_M
exit
EOF
SORT

NSTEP=${NJOB}_435
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_17_${IB}_OLD_VLIFEST195.dat

else

NSTEP=${NJOB}_455
# create EST_LIFTRANSFR pour ESID2040 Without internal retro
#------------------------------------------------------------------------------
LIBEL="create EST_LIFTRANSFR pour ESID2040 Without internal retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_O="${EST_LIFTRANSFR}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:EN,
        CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        UW_NT 6:1 - 6:,
        ACY_NF 7:1 - 7:,
        CRE_D 8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        BALSHEY_NF 11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        CUR_CF 13:1 - 13:,
        ORICOD_LS 31:1 - 31:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACMTRS_NT,
      CUR_CF
/CONDITION RET_INTERN ( BALSHEY_NF = '${BALSHTYEA_NF}' AND  BALSHTMTH_NF = ${BALSHTMTH_NF}
               AND ORICOD_LS = 'RETRO INTERNE' AND ${EST_SORT_CONDITION})
/OUTFILE  ${SORT_O}
/OMIT RET_INTERN
exit
EOF
SORT

fi

NSTEP=${NJOB}_470
# Get the printer code from the subsidiary
# Cela permet de recuperer le PRDSIT, GEOSIT et PRT_CF necessaire pour l'envoi du .pdf sur le bon serveur INTRANET
# On a une édition à sortir par site, PARIS;MUTRE;NY;SGP
#------------------------------------------------------------------------------
if [ ${HOST_PRDSIT} = FRA1 ];
then
SSD_CF=2
GET_PRTID_FROMSSD ${SSD_CF}
fi

if [ ${HOST_PRDSIT} = FRAM ];
then
SSD_CF=9
GET_PRTID_FROMSSD ${SSD_CF}
fi

if [ ${HOST_PRDSIT} = USA1 ];
then
SSD_CF=10
GET_PRTID_FROMSSD ${SSD_CF}
fi

if [ ${HOST_PRDSIT} = SGP1 ];
then
SSD_CF=20
GET_PRTID_FROMSSD ${SSD_CF}
fi


NSTEP=${NJOB}_475
#subject : Print out perimeter anos
#--------------------------------------------------------------------------
LIBEL="Print out on INTRANET"
WS_REPORT_NAME=ESID2050
WS_PARAMS_TEXT << EOF
SSD_CF          ${SSD_CF}
ACTION          WEB
EOF
WS_INPUT_FILE=${DFILT}/${NJOB}_50_${IB}_ESID2050_ANOS_O.dat
WS_REPORT

NSTEP=${NJOB}_480
# Deletion of Temporary Files
#------------------------------------------------------------------------------
#LIBEL="Deletion of Temporary Files"
#RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

# Job End
JOBEND
