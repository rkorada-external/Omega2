#!/bin/ksh
#=============================================================================
# nom de l'application          : ESID2081.cmd
# nom du script SHELL           : ESID2081.cmd
# revision                      : 
# date de creation              : 
# auteur                        : 
# references des specifications :
#-----------------------------------------------------------------------------
# [001] 07/05/2019 :spira:70045 Evolution quarterly
# [002] 05/09/2019 S.Behague :spira:78597 APOLO QE : TLIFSTAREP current, annual and photo plan estimations are wrong
# [003] 26/09/2019 S.Behague :spira:81482 APOLO QE : TLIFSTAREP Field CBNMNT + CBPMNT No fed
# [004] 21/04/2020 S.Behague :spira:81946: Apolo QE: Trimestrialisation des compléments Distinction poste cash et reserve
# [005] 17/02/2022 S.Behague :spira:98141: IFRS17 FWH Bookings
# [006] 24/08/2022 S.Behague :spira:106463: SRL : Estimations annuelles sur AC> 2022 - Copy
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_10
# [005]
# Merge file EST_DLVGTAA_PC
#------------------------------------------------------------------------------
LIBEL="Merge file EST_DLVGTAA_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLVGTAA_PCQ} 1000 1"
SORT_I2="${EST_DLVGTAA_PCY} 1000 1"
SORT_O=${EST_DLVGTAA_PC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_20
# [005]
# Merge file EST_DLVGTAA_PA
#------------------------------------------------------------------------------
LIBEL="Merge file EST_DLVGTAA_PA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLVGTAA_PAQ} 1000 1"
SORT_I2="${EST_DLVGTAA_PAY} 1000 1"
SORT_O=${EST_DLVGTAA_PA}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_30
# [005]
# Merge file EST_DLVGTAR_PC
#------------------------------------------------------------------------------
LIBEL="Merge file EST_DLVGTAR_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLVGTAR_PCQ} 1000 1"
SORT_I2="${EST_DLVGTAR_PCY} 1000 1"
SORT_O=${EST_DLVGTAR_PC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_40
# [005]
# Merge file EST_DLVGTAR_PA
#------------------------------------------------------------------------------
LIBEL="Merge file EST_DLVGTAR_PA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLVGTAR_PAQ} 1000 1"
SORT_I2="${EST_DLVGTAR_PAY} 1000 1"
SORT_O=${EST_DLVGTAR_PA}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_50
# [005]
# Merge file EST_DLVGTR_PC
#------------------------------------------------------------------------------
LIBEL="Merge file EST_DLVGTR_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLVGTR_PCQ} 1000 1"
SORT_I2="${EST_DLVGTR_PCY} 1000 1"
SORT_O=${EST_DLVGTR_PC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_60
# [005]
# Merge file EST_DLVGTR_PA
#------------------------------------------------------------------------------
LIBEL="Merge file EST_DLVGTR_PA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLVGTR_PAQ} 1000 1"
SORT_I2="${EST_DLVGTR_PAY} 1000 1"
SORT_O=${EST_DLVGTR_PA}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_70
# [005]
# Merge file EST_SIGNANO
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SIGNANO_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SIGNANO_PCQ} 1000 1"
SORT_I2="${EST_SIGNANO_PCY} 1000 1"
SORT_O=${EST_SIGNANO_PC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           3:1 -  3:
/OUTFILE ${SORT_O}
/KEYS CTR_NF
exit
EOF
SORT


NSTEP=${NJOB}_80
# [005]
# Merge file EST_SIGNANO_PA
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SIGNANO_PA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SIGNANO_PAQ} 1000 1"
SORT_I2="${EST_SIGNANO_PAY} 1000 1"
SORT_O=${EST_SIGNANO_PA}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_90
# [005]
# Merge file EST_SRGTE_PC
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SRGTE_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTE_PCQ} 1000 1"
SORT_I2="${EST_SRGTE_PCY} 1000 1"
SORT_O=${EST_SRGTE_PC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_100
# [005]
# Merge file EST_SRGTE_PA
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SRGTE_PA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTE_PAQ} 1000 1"
SORT_I2="${EST_SRGTE_PAY} 1000 1"
SORT_O=${EST_SRGTE_PA}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_110
# [005]
# Merge file EST_SRGTEF_PC
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SRGTEF_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTEF_PCQ} 1000 1"
SORT_I2="${EST_SRGTEF_PCY} 1000 1"
SORT_O=${EST_SRGTEF_PC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_120
# [005]
# Merge file EST_SRGTEF_PA
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SRGTEF_PA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTEF_PAQ} 1000 1"
SORT_I2="${EST_SRGTEF_PAY} 1000 1"
SORT_O=${EST_SRGTEF_PA}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


############################
NSTEP=${NJOB}_130
# [005]
# Merge file EST_SRGTE_SRV_PC
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SRGTE_SRV_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTE_SRV_PCQ} 1000 1"
SORT_I2="${EST_SRGTE_SRV_PCY} 1000 1"
SORT_O=${EST_SRGTE_SRV_PC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_140
# [005]
# Merge file EST_SRGTE_SRV_PA
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SRGTE_SRV_PA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTE_SRV_PAQ} 1000 1"
SORT_I2="${EST_SRGTE_SRV_PAY} 1000 1"
SORT_O=${EST_SRGTE_SRV_PA}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_150
# [005]
# Merge file EST_SRGTEF_SRV_PC
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SRGTEF_SRV_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTEF_SRV_PCQ} 1000 1"
SORT_I2="${EST_SRGTEF_SRV_PCY} 1000 1"
SORT_O=${EST_SRGTEF_SRV_PC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_160
# [005]
# Merge file EST_SRGTEF_SRV_PA
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SRGTEF_SRV_PA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTEF_SRV_PAQ} 1000 1"
SORT_I2="${EST_SRGTEF_SRV_PAY} 1000 1"
SORT_O=${EST_SRGTEF_SRV_PA}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_170
## [005]
## Merge file EST_CMPCALC_PC
##------------------------------------------------------------------------------
#LIBEL="Merge file EST_CMPCALC_PC"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_CMPCALC_PCQ} 1000 1"
#SORT_I2="${EST_CMPCALC_PCY} 1000 1"
#SORT_O=${EST_CMPCALC_PC}
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS CTR_NF           8:1 -  8:,
#        END_NT           9:1 -  9:,
#        SEC_NF          10:1 - 10:,
#        UWY_NF          11:1 - 11:,
#        UW_NT           12:1 - 12:
#/OUTFILE ${SORT_O}
#/KEYS CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT
#exit
#EOF
#SORT
cp ${EST_CMPCALC_PCY} ${EST_CMPCALC_PC}


NSTEP=${NJOB}_180
## [005]
## Merge file EST_CMPCALC_PA
##------------------------------------------------------------------------------
#LIBEL="Merge file EST_CMPCALC_PA"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_CMPCALC_PAQ} 1000 1"
#SORT_I2="${EST_CMPCALC_PAY} 1000 1"
#SORT_O=${EST_CMPCALC_PA}
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS CTR_NF           8:1 -  8:,
#        END_NT           9:1 -  9:,
#        SEC_NF          10:1 - 10:,
#        UWY_NF          11:1 - 11:,
#        UW_NT           12:1 - 12:
#/OUTFILE ${SORT_O}
#/KEYS CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT
#exit
#EOF
#SORT
cp ${EST_CMPCALC_PAY} ${EST_CMPCALC_PA}


NSTEP=${NJOB}_190
# [005]
# Merge file EST_SRGTC
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SRGTC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTCQ} 1000 1"
SORT_I2="${EST_SRGTCY} 1000 1"
SORT_O=${EST_SRGTC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT
 

NSTEP=${NJOB}_200
# [005]
# Merge file EST_SRGTCB1
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SRGTCB1"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTCB1Q} 1000 1"
SORT_I2="${EST_SRGTCB1Y} 1000 1"
SORT_O=${EST_SRGTCB1}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_210
# [005]
# Merge file EST_VLIFEST195
#------------------------------------------------------------------------------
LIBEL="Merge file EST_VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195Q} 1000 1"
SORT_I2="${EST_VLIFEST195Y} 1000 1"
SORT_O=${EST_VLIFEST195}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF           2:1 -  2:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        ACY_NF           7:1 -  7:,
        ACM_NF          25:1 - 25:EN,
        ACMTRS_NT       10:1 - 10:
/OUTFILE ${SORT_O}
/KEYS 
      CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT
exit
EOF
SORT

NSTEP=${NJOB}_215
# [005]
# Merge file EST_SRGTR_VENTIL
#------------------------------------------------------------------------------
LIBEL="Merge file EST_SRGTR_VENTIL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTR_VENTILQ} 1000 1"
SORT_I2="${EST_SRGTR_VENTILY} 1000 1"
SORT_O=${EST_SRGTR_VENTIL}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_220
# Merge file EST_IARVPERICASE4
#------------------------------------------------------------------------------
LIBEL="Merge file EST_IARVPERICASE4"

cp -v ${EST_IARVPERICASE4Y} ${EST_IARVPERICASE4}

############################
NSTEP=${NJOB}_230
# Merge file EST_FUNDWITHHELD_I17G_PC
#------------------------------------------------------------------------------
LIBEL="Merge file EST_FUNDWITHHELD_I17G_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FUNDWITHHELD_I17G_PCY} 1000 1"
SORT_I2="${EST_FUNDWITHHELD_I17G_PCQ} 1000 1"
SORT_O=${EST_FUNDWITHHELD_I17G_PC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

############################
NSTEP=${NJOB}_240
# Merge file EST_FUNDWITHHELD_I17P_PC
#------------------------------------------------------------------------------
LIBEL="Merge file EST_FUNDWITHHELD_I17P_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FUNDWITHHELD_I17P_PCY} 1000 1"
SORT_I2="${EST_FUNDWITHHELD_I17P_PCQ} 1000 1"
SORT_O=${EST_FUNDWITHHELD_I17P_PC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

############################
NSTEP=${NJOB}_250
# Merge file EST_FUNDWITHHELD_I17L_PC
#------------------------------------------------------------------------------
LIBEL="Merge file EST_FUNDWITHHELD_I17L_PC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FUNDWITHHELD_I17L_PCY} 1000 1"
SORT_I2="${EST_FUNDWITHHELD_I17L_PCQ} 1000 1"
SORT_O=${EST_FUNDWITHHELD_I17L_PC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/OUTFILE ${SORT_O}
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

CHAINEND
NSTEP=${NJOB}_300
# Renommage des fichiers ESID2080 generes par ESID2040
#-----------------------------------------------------------------------------
LIBEL="Renommage des fichiers ESID2080 generes par ESID2040"

#EST_DLVGTAA_PA_rename=`echo ${EST_DLVGTAA_PA} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_DLVGTAA_PA $EST_DLVGTAA_PA_rename
#EST_DLVGTAA_PC_rename=`echo ${EST_DLVGTAA_PC} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_DLVGTAA_PC $EST_DLVGTAA_PC_rename
#EST_DLVGTAR_PA_rename=`echo ${EST_DLVGTAR_PA} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_DLVGTAR_PA $EST_DLVGTAR_PA_rename
#EST_DLVGTAR_PC_rename=`echo ${EST_DLVGTAR_PC} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_DLVGTAR_PC $EST_DLVGTAR_PC_rename
#EST_DLVGTR_PA_rename=`echo ${EST_DLVGTR_PA} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_DLVGTR_PA $EST_DLVGTR_PA_rename
#EST_DLVGTR_PC_rename=`echo ${EST_DLVGTR_PC} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_DLVGTR_PC $EST_DLVGTR_PC_rename
#EST_SIGNANO_PA_rename=`echo ${EST_SIGNANO_PA} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_SIGNANO_PA $EST_SIGNANO_PA_rename
#EST_SIGNANO_PC_rename=`echo ${EST_SIGNANO_PC} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_SIGNANO_PC $EST_SIGNANO_PC_rename
#EST_SRGTE_PC_rename=`echo ${EST_SRGTE_PC} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_SRGTE_PC $EST_SRGTE_PC_rename
#EST_SRGTE_PA_rename=`echo ${EST_SRGTE_PA} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_SRGTE_PA $EST_SRGTE_PA_rename
#EST_SRGTE_SRV_PC_rename=`echo ${EST_SRGTE_SRV_PC} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_SRGTE_SRV_PC $EST_SRGTE_SRV_PC_rename
#EST_SRGTE_SRV_PA_rename=`echo ${EST_SRGTE_SRV_PA} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_SRGTE_SRV_PA $EST_SRGTE_SRV_PA_rename
#EST_SRGTEF_PC_rename=`echo ${EST_SRGTEF_PC} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_SRGTEF_PC $EST_SRGTEF_PC_rename
#EST_SRGTEF_PA_rename=`echo ${EST_SRGTEF_PA} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_SRGTEF_PA $EST_SRGTEF_PA_rename
#EST_SRGTEF_SRV_PC_rename=`echo ${EST_SRGTEF_SRV_PC} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_SRGTEF_SRV_PC $EST_SRGTEF_SRV_PC_rename
#EST_SRGTEF_SRV_PA_rename=`echo ${EST_SRGTEF_SRV_PA} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_SRGTEF_SRV_PA $EST_SRGTEF_SRV_PA_rename
#EST_CMPCALC_PC_rename=`echo ${EST_CMPCALC_PC} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_CMPCALC_PC $EST_CMPCALC_PC_rename
#EST_CMPCALC_PA_rename=`echo ${EST_CMPCALC_PA} | sed "s/ESID2080_/ESID2040_/"`
#cp -v $EST_CMPCALC_PA $EST_CMPCALC_PA_rename
#EST_IARVPERICASE4_rename=`echo ${EST_IARVPERICASE4Y} | sed "s/ESID2070_/ESID2030_/;s/IARVPERICASE4Y_/IARVPERICASE4_/"`
#cp -v ${EST_IARVPERICASE4Y} ${EST_IARVPERICASE4_rename}
#EST_SRGTC_rename=`echo ${EST_SRGTC} | sed "s/ESID2080_/ESID2030_/"`
#cp -v $EST_SRGTC $EST_SRGTC_rename
#EST_SRGTCB1_rename=`echo ${EST_SRGTCB1} | sed "s/ESID2080_/ESID2030_/"`
#cp -v $EST_SRGTCB1 $EST_SRGTCB1_rename
#EST_VLIFEST195_rename=`echo ${EST_VLIFEST195} | sed "s/ESID2080_/ESID2030_/"`
#cp -v $EST_VLIFEST195 $EST_VLIFEST195_rename
#

NSTEP=${NJOB}_220
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

# Job End
JOBEND
