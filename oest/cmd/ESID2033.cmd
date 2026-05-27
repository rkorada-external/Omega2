#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESID2032.cmd
# revision                      : $Revision: 1.10 $
# date de creation              : 06/03/03
# auteur                        : J. RIBOT
# references des specifications : SPOT-5075
#-----------------------------------------------------------------------------
# description :
#   Predictions Update
#   Output file sort
#		   ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat
#
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
#
# shell créé a partir du shell esid2031 step260 a step340
#_________________
#MODIFICATION    [001]
#Auteur:         D.GATIBELZA
#Date:           26/07/2010
#Version:        10.1
#Description:    ESTVIE19177 V10 Mettre en place un calcul spécial de DAC pour Köln
#                automatic DAC calculation taking into account the fanancing commission, the technical result, the interest on deposit
#-------------|------------------------------------------------------------------------------------------------------
# 10/09/2010  | [19177] - ajout export ${PRM} et remplacement du fichier ${EST_IAVPERICASE} par ${EST_IAVPERICASE0} STEP 40
#             |         - deplacement du STEP 01 au STEP 73
#[003]  06/01/2014  R. BEN EZZINE :spot:25427 - Extraction des derniers mouvements uniquement pour insertion en incremental dans la Tlifest
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3
CLODAT_D=$4



# Job Initialisation
JOBINIT


## --------------------------------
## Début Traitement pour CNATYP = 1
#
#NSTEP=${NJOB}_10
## Merging Annual Estimates for Sybase Insertion
##------------------------------------------------------------------------------
#LIBEL="Merging Annual Estimates for Sybase Insertion"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_VLIFEST195} 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195_O.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF           1:1 -  1:,
#        CTR_NF           2:1 -  2:,
#        END_NT           3:1 -  3:,
#        SEC_NF           4:1 -  4:,
#        UWY_NF           5:1 -  5:,
#        UW_NT            6:1 -  6:,
#        ACY_NF           7:1 -  7:,
#        CRE_D            8:1 -  8:,
#        PRS_CF           9:1 -  9:,
#        ACMTRS_NT       10:1 - 10:,
#        CUR_CF          13:1 - 13:,
#        ESTMNT_M        14:1 - 14:EN 15/3,
#        LOB_CF          16:1 - 16:,
#        ACCSTS_CT       17:1 - 17:,
#        ACCADMTYP_CT    18:1 - 18:,
#        ESTCRB_CT       19:1 - 19:,
#        CED_NF          20:1 - 20:,
#        BRK_NF          21:1 - 21:,
#        PAY_NF          22:1 - 22:,
#        GANPAYORD_NT    23:1 - 23:,
#        ADJCOD_CT       24:1 - 24:,
#        RETCOD_CT       25:1 - 25:,
#        DETTRS_CF       26:1 - 26:,
#        ADJSIG_B        27:1 - 27:,
#        ESB_CF          28:1 - 28:,
#        LIFTRTTYP_CF    29:1 - 29:,
#        SPIMOD_CT       35:1 - 35:,
#        NAT_CF          36:1 - 36:
#/KEYS SSD_CF,
#      CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT,
#      CRE_D,
#      ACY_NF,
#      CUR_CF,
#      ACMTRS_NT
#/CONDITION ACMTRS ( (ACMTRS_NT = "1110") OR (ACMTRS_NT = "1150") )
#/OUTFILE ${SORT_O}
#/INCLUDE ACMTRS
#/REFORMAT SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF, CRE_D, PRS_CF, ACMTRS_NT, CUR_CF, ESTMNT_M, LOB_CF, ACCSTS_CT, ACCADMTYP_CT, ESTCRB_CT,
#          CED_NF, BRK_NF, PAY_NF, GANPAYORD_NT, ADJCOD_CT, RETCOD_CT, DETTRS_CF, ADJSIG_B, ESB_CF, LIFTRTTYP_CF, SPIMOD_CT, NAT_CF
#exit
#EOF
#SORT
#
#
#NSTEP=${NJOB}_20
## Retrocession Amounts
##----------------------------------------------------------------------------
#LIBEL="Retrocession Amounts"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_SRGTC} 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_O.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF           1:1 -  1:,
#        ESB_CF           2:1 -  2:,
#        CTR_NF           8:1 -  8:,
#        END_NT           9:1 -  9:,
#        SEC_NF          10:1 - 10:,
#        UWY_NF          11:1 - 11:,
#        UW_NT           12:1 - 12:,
#        ACY_NF          14:1 - 14:,
#        CUR_CF          18:1 - 18:,
#        AMT_M           19:1 - 19:EN 15/3,
#        CED_NF          20:1 - 20:,
#        BRK_NF          21:1 - 21:,
#        PAY_NF          22:1 - 22:,
#        KEY_NF          23:1 - 23:,
#        ESTCUR_CF       41:1 - 41:,
#        ESTAMT_M        42:1 - 42:EN 15/3,
#        NAT_CF          43:1 - 43:,
#        ACMTRS_NT       44:1 - 44:,
#        LOB_CF          47:1 - 47:,
#        ESTCRB_CT       49:1 - 49:,
#        LIFTRTTYP_CF    50:1 - 50:,
#        ACCADMTYP_CT    51:1 - 51:,
#        ADJCOD_CT       56:1 - 56:,
#        RETCOD_CT       57:1 - 57:,
#        DETTRS_CF       58:1 - 58:,
#        ADJSIG_B        59:1 - 59:,
#        SPIMOD_CT       64:1 - 64:
#/KEYS SSD_CF,
#      CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT,
#      ACY_NF,
#      ESTCUR_CF,
#      ACMTRS_NT
#/CONDITION ACMTRS ( ( (ACMTRS_NT = "1110") OR (ACMTRS_NT = "1150") )    AND
#                    ACY_NF < "`expr ${BALSHTYEA_NF} - 4`"  )
#/DERIVEDFIELD ACCSTS_CT "1~"
#/DERIVEDFIELD PRS_CF "500~"
#/DERIVEDFIELD CRE_D "${CRE_D} 00:00:00~"
#/OUTFILE ${SORT_O}
#/INCLUDE ACMTRS
#/REFORMAT SSD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF, CRE_D, PRS_CF, ACMTRS_NT, ESTCUR_CF, ESTAMT_M, LOB_CF, ACCSTS_CT, ACCADMTYP_CT,
#          ESTCRB_CT, CED_NF, BRK_NF, PAY_NF, KEY_NF, ADJCOD_CT, RETCOD_CT, DETTRS_CF, ADJSIG_B, ESB_CF, LIFTRTTYP_CF, SPIMOD_CT, NAT_CF
#exit
#EOF
#SORT
#
#
#NSTEP=${NJOB}_30
## Merging Annual Estimates for Sybase Insertion
##------------------------------------------------------------------------------
#LIBEL="Merging Annual Estimates for Sybase Insertion"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_VLIFEST195_O.dat 1000 1"
#SORT_I2="${DFILT}/${NJOB}_20_${IB}_SORT_SRGTC_O.dat 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_CUMUL_CNA_O.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF           1:1 -  1:,
#        CTR_NF           2:1 -  2:,
#        END_NT           3:1 -  3:,
#        SEC_NF           4:1 -  4:,
#        UWY_NF           5:1 -  5:,
#        UW_NT            6:1 -  6:,
#        ACY_NF           7:1 -  7:,
#        CRE_D            8:1 -  8:,
#        PRS_CF           9:1 -  9:,
#        ACMTRS_NT       10:1 - 10:,
#        CUR_CF          11:1 - 11:,
#        ESTMNT_M        12:1 - 12:EN 15/3,
#        LOB_CF          13:1 - 13:,
#        ACCSTS_CT       14:1 - 14:,
#        ACCADMTYP_CT    15:1 - 15:,
#        ESTCRB_CT       16:1 - 16:,
#        CED_NF          17:1 - 17:,
#        BRK_NF          18:1 - 18:,
#        PAY_NF          19:1 - 19:,
#        GANPAYORD_NT    20:1 - 20:,
#        ADJCOD_CT       21:1 - 21:,
#        RETCOD_CT       22:1 - 22:,
#        DETTRS_CF       23:1 - 23:,
#        ADJSIG_B        24:1 - 24:,
#        ESB_CF          25:1 - 25:,
#        LIFTRTTYP_CF    26:1 - 26:,
#        SPIMOD_CT       27:1 - 27:,
#        NAT_CF          28:1 - 28:
#/KEYS SSD_CF,
#      CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT,
#      ACY_NF,
#      CRE_D,
#      PRS_CF,
#      ACMTRS_NT,
#      CUR_CF,
#      LOB_CF,
#      ACCSTS_CT,
#      ACCADMTYP_CT,
#      ESTCRB_CT,
#      CED_NF,
#      BRK_NF,
#      PAY_NF,
#      GANPAYORD_NT,
#      ADJCOD_CT,
#      RETCOD_CT,
#      DETTRS_CF,
#      ADJSIG_B,
#      ESB_CF,
#      LIFTRTTYP_CF,
#      SPIMOD_CT,
#      NAT_CF
#/SUM TOTAL ESTMNT_M
#/OUTFILE ${SORT_O}
#exit
#EOF
#SORT
#
#
#NSTEP=${NJOB}_40
## Delete temporary file
##-----------------------------------------------------------------------------
#LIBEL="Delete temporary file"
#RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_VLIFEST195_O.dat
#RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_SRGTC_O.dat
#
#
#NSTEP=${NJOB}_50
##Begin isql
##-----------------------------------------------------------------------------
#LIBEL="BTRAV..EST_ESID2030_CNA_1 table clear"
#ISQL_BASE="BTRAV"
#ISQL_QRY="truncate table BTRAV..EST_ESID2030_CNA_1"
#ISQL
#
#
#NSTEP=${NJOB}_60
## filling EST_ESID2030_CNA_1 table
##--------------------------------
#LIBEL="filling BTRAV..EST_ESID2030_CNA_1 table"
#BCP_WAY="IN"
#BCP_VER=""
#BCP_I=${DFILT}/${NJOB}_30_${IB}_CUMUL_CNA_O.dat
#BCP_TABLE="BTRAV..EST_ESID2030_CNA_1"
#BCP
#
#NSTEP=${NJOB}_70
## Delete temporary file
##-----------------------------------------------------------------------------
#LIBEL="Delete temporary file"
#RMFIL ${DFILT}/${NJOB}_30_${IB}_CUMUL_CNA_O.dat
#
#NSTEP=${NJOB}_80
## This step is launched only outside service period
##------------------------------------------------------------------------------
#LIBEL="Calcul CNA TYPE 1"
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_CNA_O.dat
#BCP_QRY="exec BEST..PtCNA_01 '${CLODAT_D}', '${CRE_D}', 12"
#BCP

touch ${DFILT}/${NJOB}_80_${IB}_BCP_CNA_O.dat

#[001]
# ------------------------------------
# Début Traitement DAC pour CNATYP = 5

#[001]
NSTEP=${NJOB}_90
# TRI DU FICHIER VLIFEST195
#------------------------------------------------------------------------------
LIBEL="TRI DU FICHIER VLIFEST195: les estimations les plus récentes en premier"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     2:1 -  2:,
        SEC_NF     4:1 -  4:EN,
        UWY_NF     5:1 -  5:,
        ACY_NF     7:1 -  7:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF
exit
EOF
SORT


#[001]
NSTEP=${NJOB}_100
# DAC
#------------------------------------------------------------------------------
LIBEL="DAC"
PRG=ESTC2148
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IAVPERICASE0}
export ${PRG}_I2=${DFILT}/${NJOB}_90_${IB}_SORT_LIFEST_O.dat
export ${PRG}_I3=${EST_FACCPAR0}
export ${PRG}_I4=${EST_FFAMCNA}
export ${PRG}_I5=${EST_FLIFDRI}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_DAC_LIFEST_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_DAC_LIFEST${BALSHTYEA_NF}${BALSHTMTH_NF}_O.log
EXECPRG

# [001]
# fin Traitement DAC pour CNATYP = 5
# ----------------------------------




#NSTEP=${NJOB}_130
## Tri du fichier VLIFEST195
##------------------------------------------------------------------------------
#LIBEL=" Tri du fichier VLIFEST195"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_VLIFEST195} 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS CTR_NF           2:1 -  2:,
#        END_NT           3:1 -  3:,
#        SEC_NF           4:1 -  4:,
#        UWY_NF           5:1 -  5:,
#        UW_NT            6:1 -  6:,
#        ACY_NF           7:1 -  7:,
#        CRE_D            8:1 -  8:,
#        ACMTRS_NT       10:1 - 10:,
#        BALSHEY_NF      11:1 - 11:,
#        BALSHTMTH_NF    12:1 - 12:EN,
#        ESTMNT_M        14:1 - 14:EN 15/3
#/KEYS CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT,
#      CRE_D,
#      BALSHEY_NF,
#      BALSHTMTH_NF,
#      ACY_NF,
#      ACMTRS_NT
#exit
#EOF
#SORT


##SORT_I="${DFILT}/${NJOB}_130_${IB}_SORT_LIFEST_O.dat 1000 1"
#NSTEP=${NJOB}_140
##Ajout des CNA calculés dans le fichier VLIFEST195 trié
##------------------------------------------------------------------------------
#LIBEL="Ajout des CNA et DAC calculés dans le fichier VLIFEST195 trié"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_VLIFEST195} 1000 1"
#SORT_I2="${DFILT}/${NJOB}_80_${IB}_BCP_CNA_O.dat 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS CTR_NF           2:1 -  2:,
#        END_NT           3:1 -  3:,
#        SEC_NF           4:1 -  4:,
#        UWY_NF           5:1 -  5:,
#        UW_NT            6:1 -  6:,
#        ACY_NF           7:1 -  7:,
#        CRE_D            8:1 -  8:,
#        ACMTRS_NT       10:1 - 10:,
#        BALSHEY_NF      11:1 - 11:,
#        BALSHTMTH_NF    12:1 - 12:EN,
#        CUR_CF          13:1 - 13:,
#        ESTMNT_M        14:1 - 14:EN 15/3
#/KEYS CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT,
#      CRE_D,
#      BALSHEY_NF,
#      BALSHTMTH_NF,
#      ACY_NF,
#      ACMTRS_NT,
#      CUR_CF
#/SUMMARIZE TOTAL ESTMNT_M
#exit
#EOF
#SORT



# debut ajout pour stable

NSTEP=${NJOB}_150
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
#RMFIL ${DFILT}/${NJOB}_80_${IB}_BCP_CNA.dat
#RMFIL ${DFILT}/${NJOB}_130_${IB}_SORT_LIFEST_O.dat



#[001]NSTEP=${NJOB}_160
#[001]# Retri du fichier VLIFEST trié + CNA + DAC
#[001]#------------------------------------------------------------------------------
#[001]LIBEL=" Retri du fichier VLIFEST trié + CNA + DAC"
#[001]SORT_WDIR=${SORTWORK}
#[001]SORT_CMD=`CFTMP`
#[001]SORT_I="${DFILT}/${NJOB}_140_${IB}_SORT_LIFEST_O.dat 1000 1"
#[001]SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
#[001]INPUT_TEXT ${SORT_CMD} <<EOF
#[001]/FIELDS CTR_NF           2:1 -  2:,
#[001]        END_NT           3:1 -  3:,
#[001]        SEC_NF           4:1 -  4:,
#[001]        UWY_NF           5:1 -  5:,
#[001]        UW_NT            6:1 -  6:,
#[001]        ACY_NF           7:1 -  7:,
#[001]        CRE_D            8:1 -  8:,
#[001]        ACMTRS_NT       10:1 - 10:,
#[001]        BALSHEY_NF      11:1 - 11:,
#[001]        BALSHTMTH_NF    12:1 - 12:EN,
#[001]        CUR_CF          13:1 - 13:,
#[001]        ESTMNT_M        14:1 - 14:EN 15/3,
#[001]        ORICOD_LS       31:1 - 31:
#[001]/KEYS CTR_NF,
#[001]      END_NT,
#[001]      SEC_NF,
#[001]      UWY_NF,
#[001]      UW_NT,
#[001]      BALSHEY_NF,
#[001]      ACY_NF,
#[001]      ACMTRS_NT,
#[001]      ESTMNT_M,
#[001]      CUR_CF,
#[001]      ORICOD_LS,
#[001]      CRE_D
#[001]exit
#[001]EOF
#[001]SORT



#[001]
NSTEP=${NJOB}_160
#extraction des DAC
#------------------------------------------------------------------------------
LIBEL="extraction des DAC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_I2="${DFILT}/${NJOB}_100_${IB}_DAC_LIFEST_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DAC_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_SANS_DAC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           2:1 -  2:,
        SEC_NF           4:1 -  4:EN,
        UWY_NF           5:1 -  5:,
        ACY_NF           7:1 -  7:,
        CRE_D            8:1 -  8:,
        ACMTRS_NT       10:1 - 10:,
        BALSHEY_NF      11:1 - 11:,
        BALSHMTH_NF     12:1 - 12:EN,
        ORICOD_LS       31:1 - 31:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      BALSHEY_NF    DESCENDING,
      BALSHMTH_NF   DESCENDING,
      CRE_D         DESCENDING
/CONDITION DAC ( ACMTRS_NT = "1193" OR ACMTRS_NT = "2193" OR ACMTRS_NT = "1194" OR ACMTRS_NT = "2194" ) AND ( ORICOD_LS = 'CNA AUTO 5')
/OUTFILE ${SORT_O}
/INCLUDE DAC
/OUTFILE ${SORT_O2}
/OMIT DAC
exit
EOF
SORT



#[001] [003]
#NSTEP=${NJOB}_161
##on ne récupère que la dernière version du DAC n'ayant pas subi de modification de montant
##------------------------------------------------------------------------------
#LIBEL="on ne récupère que la dernière version du DAC n'ayant pas subi de modification de montant"
#PRG=ESTC2043
#export ${PRG}_I1=${DFILT}/${NJOB}_160_${IB}_SORT_DAC_O.dat
#export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LAST_DAC_MODIF_O1.dat
#EXECPRG



NSTEP=${NJOB}_170
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_140_${IB}_SORT_LIFEST_O.dat


#[003]
NSTEP=${NJOB}_180
# Puis retri du fichier VLIFEST trié + CNA + DAC pour redonner un fichier VLIFEST195
#[001] Ajout I2 fichier DAC
#------------------------------------------------------------------------------
LIBEL="Puis retri du fichier VLIFEST trié + CNA + DAC pour redonner un fichier VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_160_${IB}_SORT_LIFEST_SANS_DAC_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_160_${IB}_SORT_DAC_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_80_${IB}_BCP_CNA_O.dat 1000 1"
SORT_O="${EST_VLIFEST195} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:,
        ACMTRS_NT       10:1 - 10:,
        BALSHEY_NF      11:1 - 11:,
        BALSHTMTH_NF    12:1 - 12:EN,
        CUR_CF          13:1 - 13:,
        ESTMNT_M        14:1 - 14:EN 15/3,
        ORICOD_LS       31:1 - 31:
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



NSTEP=${NJOB}_190
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_160_${IB}_SORT_LIFEST_SANS_DAC_O.dat
#RMFIL ${DFILT}/${NJOB}_161_${IB}_ESTC2043_LAST_DAC_MODIF_O1.dat
RMFIL ${DFILT}/${NJOB}_80_${IB}_BCP_CNA_O.dat


NSTEP=${NJOB}_200
# Extraction des CNA AUTO du jour à partir du nouveau fichier VLIFEST195
#----------------------------------------------------------------------------
LIBEL="Extraction des CNA AUTO du jour à partir du nouveau fichier VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195_CNA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:,
        CRE_D            8:1 -  8:,
        ACMTRS_NT       10:1 - 10:,
        BALSHEY_NF      11:1 - 11:,
        BALSHTMTH_NF    12:1 - 12:EN,
        CUR_CF          13:1 - 13:,
        ESTMNT_M        14:1 - 14:EN 15/3,
        INDSUP_B        30:1 - 30:,
        ORICOD_LS       31:1 - 31:,
        CREUSR_CF       32:1 - 32:,
        LSTUPD_D        33:1 - 33:,
        LSTUPDUSR_CF    34:1 - 34:
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
/CONDITION CNAAUTO (CRE_D = "${CRE_D} 23:59:50" AND ORICOD_LS = 'CNA AUTO')
/DERIVEDFIELD PRS_CF "500~"
/OUTFILE  ${SORT_O}
/INCLUDE CNAAUTO
/REFORMAT CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, PRS_CF, ACMTRS_NT, SSD_CF,
          CUR_CF, ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
exit
EOF
SORT



NSTEP=${NJOB}_205
# Extraction des DAC du jour à partir du nouveau fichier VLIFEST195
#----------------------------------------------------------------------------
LIBEL="Extraction des DAC du jour à partir du nouveau fichier VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195_DAC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:,
        CRE_D            8:1 -  8:,
        ACMTRS_NT       10:1 - 10:,
        BALSHEY_NF      11:1 - 11:,
        BALSHTMTH_NF    12:1 - 12:EN,
        CUR_CF          13:1 - 13:,
        ESTMNT_M        14:1 - 14:EN 15/3,
        INDSUP_B        30:1 - 30:,
        ORICOD_LS       31:1 - 31:,
        CREUSR_CF       32:1 - 32:,
        LSTUPD_D        33:1 - 33:,
        LSTUPDUSR_CF    34:1 - 34:
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
/CONDITION DACAUTO (CRE_D = "${CRE_D} 23:59:50" AND ( ORICOD_LS = 'CNA AUTO 5' ) )
/DERIVEDFIELD PRS_CF "500~"
/OUTFILE ${SORT_O}
/INCLUDE DACAUTO
/REFORMAT CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, PRS_CF, ACMTRS_NT, SSD_CF,
          CUR_CF, ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
exit
EOF
SORT



NSTEP=${NJOB}_210
# Inversion des montant RETRO venant des CNA AUTO + DAC extraits
#-----------------------------------------------------------------------------
LIBEL="Inversion des montant RETRO venant des CNA AUTO + DAC extraits"
AWK_I=${DFILT}/${NJOB}_200_${IB}_SORT_VLIFEST195_CNA_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_VLIFEST195_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
        { if( \$11 < "2000" ) { print \$0 }}
		{ if( \$11 > "2000" ) { \$14 = sprintf("%-.3lf",-\$14) ; print \$0 }}
exit
EOF
AWK

NSTEP=${NJOB}_220
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_200_${IB}_SORT_VLIFEST195_CNA_O.dat

NSTEP=${NJOB}_230
# Begin sort
#------------------------------------------------------------------------------
LIBEL="move EST_CPLIFEST ==> DFILT _OLD_CPLIFEST.dat"
EXECKSH "mv ${EST_CPLIFEST} ${DFILT}/${NSTEP}_${IB}_OLD_CPLIFEST.dat"


#[001]
NSTEP=${NJOB}_235
#on ne prend que les nouveaux DAC du VLIFEST195
#------------------------------------------------------------------------------
LIBEL="on ne prend que les nouveaux DAC du VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_205_${IB}_SORT_VLIFEST195_DAC_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195_DAC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS LSTUPD_D 18:1 - 18:
/CONDITION NEW_DAC ( LSTUPD_D = "${CRE_D}" )
/OUTFILE ${SORT_O}
/INCLUDE NEW_DAC
exit
EOF
SORT

NSTEP=${NJOB}_240
# Ajout des CNA et DAC dans le fichier CPLIFEST
#[001] Ajout des DAC
#------------------------------------------------------------------------------
LIBEL="Ajout des CNA et DAC dans le fichier CPLIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_210_${IB}_AWK_VLIFEST195_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_230_${IB}_OLD_CPLIFEST.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_235_${IB}_SORT_VLIFEST195_DAC_O.dat 1000 1"
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

NSTEP=${NJOB}_250
# Deletion of Temporary Files
#------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

# Job End
JOBEND

