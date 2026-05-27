#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Rapprochement retrocession
# nom du script SHELL		: ESID2531.cmd
# revision			: $Revision:   1.21  $
# date de creation		: 09/97
# auteur			: C.G.I.
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Retrocession comparison
#
# job lance par ESID2530.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#	Le fichier des rapprochements est une fusion des resultats theoriques
# et comptables uniquement - modifs temporaires du 23/03/98 par M.HA-THUC
#
# J. Ribot  05/02/2003   ajout gestion champs RETINTAMT_M
#---------------
#MODIFICATION   : [002]
#Auteur         : D.GATIBELZA
#Date           : 09/05/2011
#Version        : 11.1
#Description    : ESTDOM21408 OneLedger
#[003] 27/06/2012 Roger Cassis :spot:23802 - Somme enregistrements Retro pour limiter les cles a traiter dans le prog ESTC2326
#[004] 25/09/2012 Roger Cassis :spot:24281 - Precision taille des records dans les tris
#[003] 05/10/2015 -=Dch=-  	 :spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF) 
#[005] 01/02/2016 Florent  :spot:29066 GT à 71 colonnes
#[006] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd

#set -x
# Job Initialisation
JOBINIT

# Parameters
CLODAT_D=$1
BALSHTYEA_NF=$2
RETTHRESHOLD_R=$3

# Last Balance Sheet Year
export BALYEAANT_NF=$((${BALSHTYEA_NF}-1))

#################################################
# The Retrocession Comparison File is generated
# with 10 temporary files:
# FTRAV1 :
# FTRAV2 :
# FTRAV3 :
# FTRAV4 :
# FTRAV5 :
# FTRAV6 :
# FTRAV7 :
# FTRAV8 :
# FTRAV9 :
# FTRAV10:
#
# FTRAV1 :Resulat Comptable
# FTRAV2 :Resultat Theorique
# FTRAV3 :Ecart de Placement et de change sur rejets de retard
# FTRAV4 :Ecart de Placement et de chande sur comptes
# FTRAV5 :Ecart retroactif sur bilans anterieurs
# FTRAV6 :Ecart dus aux ecritures de rachats
# FTRAV7 :Ecart de Versement sur les rejets d estimations, d actualisations et de service
# FTRAV8 :Ecart de Placement sur les rejets d estimations, d actualisations et de service
# FTRAV9 :Ecart de Change sur les rejets d estimations, d actualisations et de service
# FTRAV10:Ecart de Commissions Majorees
#
###############################################

NSTEP=${NJOB}_00
#Last version of ESID2530 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_FRAPP}`/${PCH}ESID2530_FRAPP*.dat*"

#################################################
# Generation of Work Files : FTRAV1,            #
#                            FTRAV3,            #
#################################################


NSTEP=${NJOB}_05
#Sort of TOTGTAR
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#-----------------------------------------------------------------------------
LIBEL="Sort of TOTGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TOTGTAR} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_TRAV10_O2.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        TRNCOD_CF_CAR1 6:1 - 6:1,
        TRNCOD_CF_CAR2 6:2 - 6:2,
        TRNCOD_CF_CAR3 6:3 - 6:3,
        TRNCOD_CF_CAR4 6:4 - 6:4,
        TRNCOD_CF_CAR8 6:8 - 6:8,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:
/KEYS TRNCOD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/CONDITION COND ((TRNCOD_CF_CAR1 = "2") OR (TRNCOD_CF_CAR1 = "4")) AND
                (TRNCOD_CF_CAR2 = "1") AND
                (TRNCOD_CF_CAR3 = "1") AND
                ((TRNCOD_CF_CAR4 = "0") OR (TRNCOD_CF_CAR4 = "1")) AND
                (TRNCOD_CF_CAR8 = "0")
/OUTFILE ${SORT_O}
/OUTFILE ${SORT_O2}
   /INCLUDE COND
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Selection of 'Delay Deniam' and Attachable Transaction Codes"
PRG=ESTC2337
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_GTAR_O1.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARFTRAV1_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARFTRAV3_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_05_${IB}_SORT_GTAR_O1.dat > ${DFILT}/${NJOB}_05_SORT_GTAR_O1.dat.gz
# ------------------------------------

NSTEP=${NJOB}_15
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_GTAR_O1.dat

NSTEP=${NJOB}_20
# Sort and generation of Work File (Theorical Result):FTRAV1
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="Generation of Work File (Theorical Result):FTRAV1"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTC2337_GTARFTRAV1_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTRAV1_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M
/DERIVEDFIELD SEPARATEUR    "~"
/DERIVEDFIELD SEPARATEUR12    "~~~~~~~~~~~~"
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          SEPARATEUR,
          RETAMT_MC,
          SEPARATEUR12
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_10_${IB}_ESTC2337_GTARFTRAV1_O.dat > ${DFILT}/${NJOB}_10_ESTC2337_GTARFTRAV1_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_25
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_10_${IB}_ESTC2337_GTARFTRAV1_O.dat

NSTEP=${NJOB}_30
# Sort and Summarizing after ESTC2337 C program
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="sort and summarizing of GTAR after ESTC2337 C program"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTC2337_GTARFTRAV3_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTARFTRAV3_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15: EN,
        SCOENDMTH_NF 16:1 - 16: EN,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        FILLER_30_COLS 42:1 - 71:
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF,
      TRNCOD_CF
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC    AMT_M    COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
          FILLER_30_COLS
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_10_${IB}_ESTC2337_GTARFTRAV3_O.dat > ${DFILT}/${NJOB}_10_ESTC2337_GTARFTRAV3_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_35
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_10_${IB}_ESTC2337_GTARFTRAV3_O.dat

NSTEP=${NJOB}_36
# Begin sort before ESTC2338 C program
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="sort of GTAR before ESTC2338 C program"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_GTARFTRAV3_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTARFTRAV3_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_37
# Filter on Transaction Cod = UPR/DAC on Pool
#------------------------------------------------------------------------------
LIBEL="Filter on Transaction Cod = UPR/DAC on Pool"
PRG=ESTC2338
export ${PRG}_I1=${EST_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_36_${IB}_SORT_GTARFTRAV3_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARFTRAV3_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_30_${IB}_SORT_GTARFTRAV3_O.dat > ${DFILT}/${NJOB}_30_SORT_GTARFTRAV3_O.dat.gz
gzip -c ${DFILT}/${NJOB}_36_${IB}_SORT_GTARFTRAV3_O.dat > ${DFILT}/${NJOB}_36_SORT_GTARFTRAV3_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_38
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_GTARFTRAV3_O.dat
RMFIL ${DFILT}/${NJOB}_36_${IB}_SORT_GTARFTRAV3_O.dat

NSTEP=${NJOB}_40
# Begin sort before ESTC2319 C program
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="sort of GTAR before ESTC2319 C program"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_37_${IB}_ESTC2338_GTARFTRAV3_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTARFTRAV3_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCUR_CF 34:1 - 34:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCUR_CF
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_37_${IB}_ESTC2338_GTARFTRAV3_O.dat > ${DFILT}/${NJOB}_37_ESTC2338_GTARFTRAV3_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_45
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_37_${IB}_ESTC2338_GTARFTRAV3_O.dat

NSTEP=${NJOB}_50
# Begin programme C: Generation of Work File (FTRAV3)
#------------------------------------------------------------------------------
LIBEL="Generation of Work File (Delay Denial Differences)(FTRAV3)"
PRG=ESTC2319
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_GTARFTRAV3_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FPLCANT}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTRAV3_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_40_${IB}_SORT_GTARFTRAV3_O.dat > ${DFILT}/${NJOB}_40_SORT_GTARFTRAV3_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_55
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_GTARFTRAV3_O.dat

#################################################
# Generation of Work File : FTRAV10             #
#################################################

#[004]
NSTEP=${NJOB}_60
# Begin sort of TOTGTR
#------------------------------------------------------------------------------
LIBEL="sort of TOTGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TOTGTR} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        TRNCOD_CF_CAR1 6:1 - 6:1,
        TRNCOD_CF_CAR2 6:2 - 6:2,
        TRNCOD_CF_CAR3 6:3 - 6:3,
        TRNCOD_CF_CAR4 6:4 - 6:4,
        TRNCOD_CF_CAR8 6:8 - 6:8,
        PLC_NT 36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT
/CONDITION COND ((TRNCOD_CF_CAR1 = "2") OR (TRNCOD_CF_CAR1 = "4")) AND
                (TRNCOD_CF_CAR2 = "1") AND
                (TRNCOD_CF_CAR3 = "1") AND
                ((TRNCOD_CF_CAR4 = "0") OR (TRNCOD_CF_CAR4 = "1")) AND
                (TRNCOD_CF_CAR8 = "0")
/INCLUDE COND
exit
EOF
SORT

NSTEP=${NJOB}_65
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Recovering Overrinding Commission Rates"
PRG=ESTC2325
export ${PRG}_I1=${EST_FPLC}
export ${PRG}_I2=${DFILT}/${NJOB}_60_${IB}_SORT_GTR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_SURCOM_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_60_${IB}_SORT_GTR_O.dat > ${DFILT}/${NJOB}_60_SORT_GTR_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_70
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_GTR_O.dat

#[003]
NSTEP=${NJOB}_75
# Begin sort
#------------------------------------------------------------------------------
LIBEL="sort of GTR + Surcom"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_65_${IB}_ESTC2325_GTR_SURCOM_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTR_SURCOM_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:
/SUMMARIZE TOTAL RETAMT_M
/KEYS SSD_CF,
      ESB_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF,
      TRNCOD_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      RTO_NF
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_65_${IB}_ESTC2325_GTR_SURCOM_O.dat > ${DFILT}/${NJOB}_65_ESTC2325_GTR_SURCOM_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_80
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_65_${IB}_ESTC2325_GTR_SURCOM_O.dat

NSTEP=${NJOB}_85
# Begin sort
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="sort of TOTGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTAR_TRAV10_O2.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_CF_CAR1 6:1 - 6:1,
        TRNCOD_CF_CAR2 6:2 - 6:2,
        TRNCOD_CF_CAR3 6:3 - 6:3,
        TRNCOD_CF_CAR4 6:4 - 6:4,
        TRNCOD_CF_CAR8 6:8 - 6:8,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF,
      TRNCOD_CF
/CONDITION COND ((TRNCOD_CF_CAR1 = "2") OR (TRNCOD_CF_CAR1 = "4")) AND
                (TRNCOD_CF_CAR2 = "1") AND
                (TRNCOD_CF_CAR3 = "1") AND
                ((TRNCOD_CF_CAR4 = "0") OR (TRNCOD_CF_CAR4 = "1")) AND
                (TRNCOD_CF_CAR8 = "0")
/INCLUDE COND
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_05_${IB}_SORT_GTAR_TRAV10_O2.dat > ${DFILT}/${NJOB}_05_SORT_GTAR_TRAV10_O2.dat.gz
# ------------------------------------

NSTEP=${NJOB}_90
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_GTAR_TRAV10_O2.dat

NSTEP=${NJOB}_95
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Taking into account Overriding commission Rates"
PRG=ESTC2326
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
RETTHRESHOLD_R ${RETTHRESHOLD_R}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_85_${IB}_SORT_GTAR_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_75_${IB}_SORT_GTR_SURCOM_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTANO_O2.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_85_${IB}_SORT_GTAR_O.dat > ${DFILT}/${NJOB}_85_SORT_GTAR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_75_${IB}_SORT_GTR_SURCOM_O.dat > ${DFILT}/${NJOB}_75_SORT_GTR_SURCOM_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_100
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_85_${IB}_SORT_GTAR_O.dat
RMFIL ${DFILT}/${NJOB}_75_${IB}_SORT_GTR_SURCOM_O.dat

NSTEP=${NJOB}_105
# Begin sort; Generation of Work File FTRAV10
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="Change to Attachement File Format; Generation of Work File FTRAV10"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_ESTC2326_GTARR_O1.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTRAV10_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M
/DERIVEDFIELD RIEN            ""
/DERIVEDFIELD SEPARATEUR13    "~~~~~~~~~~~~~"
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          SEPARATEUR13,
          RETAMT_MC,
          RIEN
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_95_${IB}_ESTC2326_GTARR_O1.dat > ${DFILT}/${NJOB}_95_ESTC2326_GTARR_O1.dat.gz
# ------------------------------------

NSTEP=${NJOB}_110
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_95_${IB}_ESTC2326_GTARR_O1.dat

#################################################
# Generation of Work File : FTRAV2              #
#################################################

#[003]
NSTEP=${NJOB}_115
#sort of TOTGTAA
#-----------------------------------------------------------------------------
LIBEL="sort of  TOTGTAA + Filter of TATGTAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TOTGTAA} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O2.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        TRNCOD_CF 6:1 - 6:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:,
        SOUS_PREFIX_TRNCOD_CF 6:2 - 6:2,
        SUFFIX_TRNCOD_CF 6:8 - 6:8,
        POSTE_TRNCOD_CF 6:3 - 6:7
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
/CONDITION COND (
                  (
                     (SOUS_PREFIX_TRNCOD_CF = "1") OR
                     (SOUS_PREFIX_TRNCOD_CF = "2") OR
                     (SOUS_PREFIX_TRNCOD_CF = "3")
                  )
                  AND
                  (
                     (SUFFIX_TRNCOD_CF = "1") OR
                     (SUFFIX_TRNCOD_CF = "3") OR
                     (SUFFIX_TRNCOD_CF = "7")
                  )
                )
                OR
                  (
                     (SOUS_PREFIX_TRNCOD_CF = "7") OR
                     (SOUS_PREFIX_TRNCOD_CF = "8") OR
                     (SOUS_PREFIX_TRNCOD_CF = "9")
                  )
                OR ( POSTE_TRNCOD_CF = "10301" )
                OR ( POSTE_TRNCOD_CF = "10311" )
                OR ( POSTE_TRNCOD_CF = "10321" )
                OR ( POSTE_TRNCOD_CF = "10331" )
                OR ( POSTE_TRNCOD_CF = "10341" )
                OR ( POSTE_TRNCOD_CF = "10351" )
                OR ( POSTE_TRNCOD_CF = "14201" )
                OR ( POSTE_TRNCOD_CF = "41101" )
                OR ( POSTE_TRNCOD_CF = "41901" )
                OR ( POSTE_TRNCOD_CF = "42101" )
                OR ( POSTE_TRNCOD_CF = "42111" )
                OR ( POSTE_TRNCOD_CF = "42141" )
                OR ( POSTE_TRNCOD_CF = "42151" )
                OR ( POSTE_TRNCOD_CF = "42161" )
                OR ( POSTE_TRNCOD_CF = "42191" )
                OR ( POSTE_TRNCOD_CF = "42801" )
                OR ( POSTE_TRNCOD_CF = "43101" )
                OR ( POSTE_TRNCOD_CF = "43701" )
                OR ( POSTE_TRNCOD_CF = "44101" )
                OR ( POSTE_TRNCOD_CF = "48101" )
                OR ( POSTE_TRNCOD_CF = "48111" )
                OR ( POSTE_TRNCOD_CF = "48801" )
/OUTFILE ${SORT_O}
/OUTFILE ${SORT_O2}
   /INCLUDE COND
exit
EOF
SORT

NSTEP=${NJOB}_120
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Session Operator"
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
GTE_B 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_115_${IB}_SORT_GTAA_O1.dat
export ${PRG}_I2=${EST_FCES}
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_115_${IB}_SORT_GTAA_O1.dat > ${DFILT}/${NJOB}_115_SORT_GTAA_O1.dat.gz
# ------------------------------------

NSTEP=${NJOB}_125
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_115_${IB}_SORT_GTAA_O1.dat

NSTEP=${NJOB}_130
# Begin sort before C Program
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="Sort of GTAR100 before ESTC2317 C Program"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_ESTC2303_GTAR100_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:,
        CLM_NF 17:1 - 17:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:
/KEYS TRNCOD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      CLM_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_120_${IB}_ESTC2303_GTAR100_O.dat > ${DFILT}/${NJOB}_120_ESTC2303_GTAR100_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_135
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_120_${IB}_ESTC2303_GTAR100_O.dat

NSTEP=${NJOB}_140
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Filter for Attachable Transaction Codes. Accumulation 'All Transaction Codes'"
PRG=ESTC2317
export ${PRG}_I1=${DFILT}/${NJOB}_130_${IB}_SORT_GTAR100_O.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_130_${IB}_SORT_GTAR100_O.dat > ${DFILT}/${NJOB}_130_SORT_GTAR100_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_145
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_130_${IB}_SORT_GTAR100_O.dat

NSTEP=${NJOB}_150
# Begin sort and summarizing after C Program
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="sort and summarize of GTAR after ESTC2317 C Program"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_ESTC2317_GTAR100_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15: EN,
        SCOENDMTH_NF 16:1 - 16: EN,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
	      RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        FILLER_30_COLS 42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      CLM_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC    AMT_M    COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
          FILLER_30_COLS
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_140_${IB}_ESTC2317_GTAR100_O.dat > ${DFILT}/${NJOB}_140_ESTC2317_GTAR100_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_155
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_140_${IB}_ESTC2317_GTAR100_O.dat

NSTEP=${NJOB}_160
# Begin sort before C Program
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="sort of GTAR100 before ESTC2304 C Program"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_150_${IB}_SORT_GTAR100_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O2.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        TRNCOD_CF 6:1 - 6:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      CUR_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_150_${IB}_SORT_GTAR100_O.dat > ${DFILT}/${NJOB}_150_SORT_GTAR100_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_165
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_150_${IB}_SORT_GTAR100_O.dat

NSTEP=${NJOB}_170
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Placement Operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTR_B 0
BALSHTYEA_NF ${BALSHTYEA_NF}
GTE_B 0
PRS 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_160_${IB}_SORT_GTAR100_O2.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_160_${IB}_SORT_GTAR100_O2.dat > ${DFILT}/${NJOB}_160_SORT_GTAR100_O2.dat.gz
# ------------------------------------

NSTEP=${NJOB}_175
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_160_${IB}_SORT_GTAR100_O2.dat

NSTEP=${NJOB}_180
# Begin sort and generation of Work File FTRAV2
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="Generation of Work File (Theorical Result) (FTRAV2)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_170_${IB}_ESTC2304_GTAR_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTRAV2_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M
/DERIVEDFIELD SEPARATEUR    "~"
/DERIVEDFIELD SEPARATEUR11    "~~~~~~~~~~~"
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          SEPARATEUR,
          SEPARATEUR,
          RETAMT_MC,
          SEPARATEUR11
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_170_${IB}_ESTC2304_GTAR_O.dat > ${DFILT}/${NJOB}_170_ESTC2304_GTAR_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_185
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_170_${IB}_ESTC2304_GTAR_O.dat

#################################################
# Generation of Work Files : FTRAV7,            #
#                            FTRAV8,            #
#                            FTRAV9             #
#################################################

NSTEP=${NJOB}_190
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Session Operator with Cession File"
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
GTE_B 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_115_${IB}_SORT_GTAA_O2.dat
export ${PRG}_I2=${EST_FCES}
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100V_O.dat
EXECPRG

NSTEP=${NJOB}_195
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Cession Operator with Cession File"
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
GTE_B 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_115_${IB}_SORT_GTAA_O2.dat
export ${PRG}_I2=${EST_FCESANT}
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100V0_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_115_${IB}_SORT_GTAA_O2.dat > ${DFILT}/${NJOB}_115_SORT_GTAA_O2.dat.gz
# ------------------------------------

NSTEP=${NJOB}_200
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_115_${IB}_SORT_GTAA_O2.dat

NSTEP=${NJOB}_205
# Begin sort
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="Sort of GTAR100"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_ESTC2303_GTAR100V_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100V_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:,
        CLM_NF 17:1 - 17:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:
/KEYS TRNCOD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      CLM_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_210
# Begin sort
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="Sort of GTAR100"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_195_${IB}_ESTC2303_GTAR100V0_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100V0_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:,
        CLM_NF 17:1 - 17:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:
/KEYS TRNCOD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      CLM_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_190_${IB}_ESTC2303_GTAR100V_O.dat > ${DFILT}/${NJOB}_190_ESTC2303_GTAR100V_O.dat.gz
gzip -c ${DFILT}/${NJOB}_195_${IB}_ESTC2303_GTAR100V0_O.dat > ${DFILT}/${NJOB}_195_ESTC2303_GTAR100V0_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_215
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_190_${IB}_ESTC2303_GTAR100V_O.dat
RMFIL ${DFILT}/${NJOB}_195_${IB}_ESTC2303_GTAR100V0_O.dat

NSTEP=${NJOB}_220
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Filter for Attachable Transaction Codes. Accumulation 'All Transaction Codes'"
PRG=ESTC2317
export ${PRG}_I1=${DFILT}/${NJOB}_205_${IB}_SORT_GTAR100V_O.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100V_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_205_${IB}_SORT_GTAR100V_O.dat > ${DFILT}/${NJOB}_205_SORT_GTAR100V_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_223
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_205_${IB}_SORT_GTAR100V_O.dat

NSTEP=${NJOB}_225
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Filter for Attachable Transaction Codes. Accumulation 'All Transaction Codes'"
PRG=ESTC2317
export ${PRG}_I1=${DFILT}/${NJOB}_210_${IB}_SORT_GTAR100V0_O.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100V0_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_210_${IB}_SORT_GTAR100V0_O.dat > ${DFILT}/${NJOB}_210_SORT_GTAR100V0_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_230
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_210_${IB}_SORT_GTAR100V0_O.dat

NSTEP=${NJOB}_235
# Begin sort
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="sort of GTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_220_${IB}_ESTC2317_GTAR100V_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_V_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15: EN,
        SCOENDMTH_NF 16:1 - 16: EN,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        FILLER_30_COLS 42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      CLM_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC    AMT_M    COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
          FILLER_30_COLS
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_220_${IB}_ESTC2317_GTAR100V_O.dat > ${DFILT}/${NJOB}_220_ESTC2317_GTAR100V_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_237
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_220_${IB}_ESTC2317_GTAR100V_O.dat


NSTEP=${NJOB}_240
# Begin sort
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="sort of GTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_225_${IB}_ESTC2317_GTAR100V0_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_V0_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15: EN,
        SCOENDMTH_NF 16:1 - 16: EN,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        FILLER_30_COLS 42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      CLM_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC    AMT_M    COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
          FILLER_30_COLS
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_225_${IB}_ESTC2317_GTAR100V0_O.dat > ${DFILT}/${NJOB}_225_ESTC2317_GTAR100V0_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_245
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_225_${IB}_ESTC2317_GTAR100V0_O.dat

NSTEP=${NJOB}_250
# Begin sort
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="sort of GTAR100"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_235_${IB}_SORT_V_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_V_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        TRNCOD_CF 6:1 - 6:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      CUR_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_225_${IB}_ESTC2317_GTAR100V0_O.dat > ${DFILT}/${NJOB}_225_ESTC2317_GTAR100V0_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_252
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_235_${IB}_SORT_V_O.dat


NSTEP=${NJOB}_255
# Begin sort
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
#------------------------------------------------------------------------------
LIBEL="sort of GTAR100"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_240_${IB}_SORT_V0_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_V0_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        TRNCOD_CF 6:1 - 6:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      CUR_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${DFILT}/${NJOB}_240_${IB}_SORT_V0_O.dat > ${DFILT}/${DFILT}/${NJOB}_240_SORT_V0_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_260
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_240_${IB}_SORT_V0_O.dat

NSTEP=${NJOB}_265
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Placement Operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTR_B 0
BALSHTYEA_NF ${BALSHTYEA_NF}
GTE_B 0
PRS 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_250_${IB}_SORT_V_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VPC_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_VPCMAJ_O2.dat
EXECPRG

NSTEP=${NJOB}_270
# Begin programme C
# Modif provisoire - le second parametre du programme devient l'annee
# bilan au lieu de l'annee bilan - 1
# Modif annulee le 07/05/1999
#------------------------------------------------------------------------------
LIBEL="Placement Operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTR_B 0
BALSHTYEA_NF ${BALYEAANT_NF}
GTE_B 0
PRS 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_250_${IB}_SORT_V_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VPC0_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_VPC0MAJ_O2.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_250_${IB}_SORT_V_O.dat > ${DFILT}/${DFILT}/${NJOB}_250_SORT_V_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_272
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_250_${IB}_SORT_V_O.dat


NSTEP=${NJOB}_275
# Begin programme C
# Modif provisoire - le second parametre du programme devient l'annee
# bilan au lieu de l'annee bilan - 1
# Modif annulee le 07/05/1999
#------------------------------------------------------------------------------
LIBEL="Placement Operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTR_B 0
BALSHTYEA_NF ${BALYEAANT_NF}
GTE_B 0
PRS 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_255_${IB}_SORT_V0_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_V0PC0_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_V0PC0MAJ_O2.dat
EXECPRG


NSTEP=${NJOB}_280
# Begin programme C
# Modif provisoire - le second parametre du programme devient l'annee
# bilan au lieu de l'annee bilan - 1
# Modif annulee le 07/05/1999
#------------------------------------------------------------------------------
LIBEL="Placement Operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTR_B 0
BALSHTYEA_NF ${BALYEAANT_NF}
GTE_B 0
PRS 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_255_${IB}_SORT_V0_O.dat
export ${PRG}_I2=${EST_FPLCANT}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_V0P0C0_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_V0P0C0MAJ_O2.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_255_${IB}_SORT_V0_O.dat > ${DFILT}/${NJOB}_255_SORT_V0_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_285
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_255_${IB}_SORT_V0_O.dat

#[003]
NSTEP=${NJOB}_290
#Sum and reformat of VPC
#-----------------------------------------------------------------------------
LIBEL="sort and reformat of VPC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_265_${IB}_ESTC2304_VPC_O1.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_VPC_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M
/DERIVEDFIELD SEPARATEUR    "~"
/DERIVEDFIELD INITMT1       "0"
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          INITMT1,
          SEPARATEUR,
          RETAMT_MC
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_265_${IB}_ESTC2304_VPC_O1.dat > ${DFILT}/${NJOB}_265_ESTC2304_VPC_O1.dat.gz
# ------------------------------------

NSTEP=${NJOB}_295
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_265_${IB}_ESTC2304_VPC_O1.dat

#[003]
NSTEP=${NJOB}_300
#Merge, sort and reformat of VPC0
#-----------------------------------------------------------------------------
LIBEL="Sum, sort and reformat of VPC0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_270_${IB}_ESTC2304_VPC0_O1.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_VPC0_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M
/DERIVEDFIELD INITMT2       "0"
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          RETAMT_MC,
          INITMT2
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_270_${IB}_ESTC2304_VPC0_O1.dat > ${DFILT}/${NJOB}_270_ESTC2304_VPC0_O1.dat.gz
# ------------------------------------

NSTEP=${NJOB}_305
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_270_${IB}_ESTC2304_VPC0_O1.dat

#[003]
NSTEP=${NJOB}_310
#Sum, sort and reformat of V0PC0
#-----------------------------------------------------------------------------
LIBEL="Merge, sort and reformat of V0PC0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_275_${IB}_ESTC2304_V0PC0_O1.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_V0PC0_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M
/DERIVEDFIELD SEPARATEUR    "~"
/DERIVEDFIELD INITMT1       "0"
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          INITMT1,
          SEPARATEUR,
          RETAMT_MC
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_275_${IB}_ESTC2304_V0PC0_O1.dat > ${DFILT}/${NJOB}_275_ESTC2304_V0PC0_O1.dat.gz
# ------------------------------------

NSTEP=${NJOB}_315
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_275_${IB}_ESTC2304_V0PC0_O1.dat

#[003]
NSTEP=${NJOB}_320
#sort and reformat of V0P0C0
#-----------------------------------------------------------------------------
LIBEL="Sum, sort and reformat of V0P0C0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_280_${IB}_ESTC2304_V0P0C0_O1.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_V0P0C0_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M
/DERIVEDFIELD INITMT2       "0"
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          RETAMT_MC,
          INITMT2
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_280_${IB}_ESTC2304_V0P0C0_O1.dat > ${DFILT}/${NJOB}_280_ESTC2304_V0P0C0_O1.dat.gz
# ------------------------------------

NSTEP=${NJOB}_325
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_280_${IB}_ESTC2304_V0P0C0_O1.dat

#[003]
NSTEP=${NJOB}_330
#Sum, and merge of V0PC0 and VPC0
#-----------------------------------------------------------------------------
LIBEL="Merge, V0PC0 and VPC0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_300_${IB}_SORT_VPC0_O.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_310_${IB}_SORT_V0PC0_O.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_VPC0_V0PC0_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        RETCTR_NF 8:1 - 8:,
        RETEND_NT 9:1 - 9:,
        RETSEC_NF 10:1 - 10:,
        RTY_NF 11:1 - 11:,
        RETUW_NT 12:1 - 12:,
        RETCUR_CF 13:1 - 13:,
        MT1_M 14:1 - 14:EN 15/3,
        MT2_M 15:1 - 15:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL MT1_M,
           TOTAL MT2_M
/DERIVEDFIELD MT1_MC MT1_M COMPRESS
/DERIVEDFIELD MT2_MC MT2_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          MT1_MC,
          MT2_MC
exit
EOF
SORT

NSTEP=${NJOB}_335
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Calculation of Row to Row Differences -> AMT8_M; Work File FTRAV7"
PRG=ESTC2324
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
FRAPP_AMT8_M AMT8_M
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_330_${IB}_SORT_VPC0_V0PC0_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTRAV7_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_330_${IB}_SORT_VPC0_V0PC0_O.dat > ${DFILT}/${NJOB}_330_SORT_VPC0_V0PC0_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_340
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_330_${IB}_SORT_VPC0_V0PC0_O.dat

#[003]
NSTEP=${NJOB}_345
#Sum, and merge of V0PC0 and V0P0C0
#-----------------------------------------------------------------------------
LIBEL="Merge, V0PC0 and V0P0C0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_320_${IB}_SORT_V0P0C0_O.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_310_${IB}_SORT_V0PC0_O.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_V0P0C0_V0PC0_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        RETCTR_NF 8:1 - 8:,
        RETEND_NT 9:1 - 9:,
        RETSEC_NF 10:1 - 10:,
        RTY_NF 11:1 - 11:,
        RETUW_NT 12:1 - 12:,
        RETCUR_CF 13:1 - 13:,
        MT1_M 14:1 - 14:EN 15/3,
        MT2_M 15:1 - 15:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL MT1_M,
           TOTAL MT2_M
/DERIVEDFIELD MT1_MC MT1_M COMPRESS
/DERIVEDFIELD MT2_MC MT2_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          MT1_MC,
          MT2_MC
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_320_${IB}_SORT_V0P0C0_O.dat > ${DFILT}/${NJOB}_320_SORT_V0P0C0_O.dat.gz
gzip -c ${DFILT}/${NJOB}_310_${IB}_SORT_V0PC0_O.dat > ${DFILT}/${NJOB}_310_SORT_V0PC0_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_350
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_320_${IB}_SORT_V0P0C0_O.dat
RMFIL ${DFILT}/${NJOB}_310_${IB}_SORT_V0PC0_O.dat

NSTEP=${NJOB}_355
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Calculation of Row to Row Differences -> AMT9_M; Work File FTRAV8"
PRG=ESTC2324
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
FRAPP_AMT9_M AMT9_M
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_345_${IB}_SORT_V0P0C0_V0PC0_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTRAV8_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_345_${IB}_SORT_V0P0C0_V0PC0_O.dat > ${DFILT}/${NJOB}_345_SORT_V0P0C0_V0PC0_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_360
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_345_${IB}_SORT_V0P0C0_V0PC0_O.dat

#[003]
NSTEP=${NJOB}_365
#Sum, and merge of VPC and VPC0
#-----------------------------------------------------------------------------
LIBEL="Merge, VPC and VPC0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_300_${IB}_SORT_VPC0_O.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_290_${IB}_SORT_VPC_O.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_VPC0_VPC_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        RETCTR_NF 8:1 - 8:,
        RETEND_NT 9:1 - 9:,
        RETSEC_NF 10:1 - 10:,
        RTY_NF 11:1 - 11:,
        RETUW_NT 12:1 - 12:,
        RETCUR_CF 13:1 - 13:,
        MT1_M 14:1 - 14:EN 15/3,
        MT2_M 15:1 - 15:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL MT1_M,
           TOTAL MT2_M
/DERIVEDFIELD MT1_MC MT1_M COMPRESS
/DERIVEDFIELD MT2_MC MT2_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          MT1_MC,
          MT2_MC
exit
EOF
SORT

NSTEP=${NJOB}_370
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_300_${IB}_SORT_VPC0_O.dat
RMFIL ${DFILT}/${NJOB}_290_${IB}_SORT_VPC_O.dat

NSTEP=${NJOB}_375
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Calculation of Row to Row Differences -> AMT10_M; Work File FTRAV9"
PRG=ESTC2324
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
FRAPP_AMT10_M AMT10_M
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_365_${IB}_SORT_VPC0_VPC_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTRAV9_O.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_365_${IB}_SORT_VPC0_VPC_O.dat > ${DFILT}/${NJOB}_365_SORT_VPC0_VPC_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_380
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_365_${IB}_SORT_VPC0_VPC_O.dat

#################################################
# Generation of Work Files : FTRAV4,            #
#                            FTRAV5             #
#################################################

#[003]
NSTEP=${NJOB}_385
# Merge of files FACCTRAI_O and FACCTRAA_O
#-------------------------------------------------------------------
LIBEL="Merge of files FACCTRAI_O and FACCTRAA_O and SORT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FACCTRAA} 500 1"
SORT_I2="${EST_FACCTRAI} 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FACCTRAA_I_O.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 3:1 - 3:,
        RTY_NF 2:1 - 2:,
        TRNCOD_CF 15:1 - 15:,
        ACC_D 24:1 - 24:4
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      TRNCOD_CF
exit
EOF
SORT


NSTEP=${NJOB}_390
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Elimination of Reserve Transaction Codes. Filter on Attachable Transaction Codes"
PRG=ESTC2320
export ${PRG}_I1=${EST_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_385_${IB}_SORT_FACCTRAA_I_O.dat
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FIC100_O.dat
EXECPRG

#[003]
NSTEP=${NJOB}_395
# Sort and Summarize
#------------------------------------------------------------------------------
LIBEL="sort and summarize of FIC100 before ESTC2321 C Program"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_390_${IB}_ESTC2320_FIC100_O.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FIC100_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        CTR_NF 6:1 - 6:,
        END_NT 7:1 - 7:,
        SEC_NF 8:1 - 8:,
        UWY_NF 9:1 - 9:,
        UW_NT 10:1 - 10:,
        CUR_CF 11:1 - 11:,
        AMT_M 12:1 - 12:EN 18/3,
        RETCTR_NF 13:1 - 13:,
        RETEND_NT 14:1 - 14:,
        RETSEC_NF 15:1 - 15:,
        RTY_NF 16:1 - 16:,
        RETUW_NT 17:1 - 17:,
        RETCUR_CF 18:1 - 18:,
        RETAMT_M 19:1 - 19:EN 18/3,
        ACCTRTCUR_R 20:1 - 20:EN 1/8
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCUR_CF,
      CUR_CF,
      ACCTRTCUR_R
/SUMMARIZE TOTAL AMT_M,
           TOTAL RETAMT_M
/DERIVEDFIELD AMT_MC       AMT_M       COMPRESS
/DERIVEDFIELD RETAMT_MC    RETAMT_M    COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          CUR_CF,
          AMT_MC,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          RETAMT_MC,
          ACCTRTCUR_R
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_390_${IB}_ESTC2320_FIC100_O.dat > ${DFILT}/${NJOB}_390_ESTC2320_FIC100_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_400
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_390_${IB}_ESTC2320_FIC100_O.dat

NSTEP=${NJOB}_405
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Generation of Work File (Difference on Account) (FTRAV4)"
PRG=ESTC2321
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_395_${IB}_SORT_FIC100_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${EST_FCURCVSNI}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTRAV4_O.dat
EXECPRG

NSTEP=${NJOB}_410
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_395_${IB}_SORT_FIC100_O.dat

#[003]
NSTEP=${NJOB}_415
# Begin sort
#------------------------------------------------------------------------------
LIBEL="sort of FOUTTRAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FOUTTRAA} 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FOUTTRAA_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 3:1 - 3:,
        RTY_NF 2:1 - 2:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF
exit
EOF
SORT

NSTEP=${NJOB}_420
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Selection of Retroactive Transactions. Elimination of Resrve Transaction Codes. Filter on Attachable Transaction Codes"
PRG=ESTC2322
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_415_${IB}_SORT_FOUTTRAA_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_385_${IB}_SORT_FACCTRAA_I_O.dat
export ${PRG}_I4=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

NSTEP=${NJOB}_425
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_415_${IB}_SORT_FOUTTRAA_O.dat
RMFIL ${DFILT}/${NJOB}_385_${IB}_SORT_FACCTRAA_I_O.dat

NSTEP=${NJOB}_430
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Accumulation amounts of GTAR100"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_420_${IB}_ESTC2322_GTAR100_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        FILLER_30_COLS 42:1 - 71:
/KEYS SSD_CF,
      ESB_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETOCCYEA_NF,
      RETACY_NF
/SUMMARIZE TOTAL AMT_M,
           TOTAL RETAMT_M,
           TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          OCCYEA_NF,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
	        RETCUR_CF,
	        RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
          FILLER_30_COLS
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_420_${IB}_ESTC2322_GTAR100_O.dat > ${DFILT}/${NJOB}_420_ESTC2322_GTAR100_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_435
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_420_${IB}_ESTC2322_GTAR100_O.dat

NSTEP=${NJOB}_440
# Begin sort before C Program
#------------------------------------------------------------------------------
LIBEL="sort of GTAR100 before ESTC2304 C Program"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_430_${IB}_SORT_GTAR100_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        TRNCOD_CF 6:1 - 6:,
        RETCUR_CF 34:1 - 34:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      RETCUR_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF
exit
EOF
SORT

NSTEP=${NJOB}_445
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_430_${IB}_SORT_GTAR100_O.dat

NSTEP=${NJOB}_450
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Placement Operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTR_B 0
BALSHTYEA_NF ${BALSHTYEA_NF}
GTE_B 0
PRS 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_440_${IB}_SORT_GTAR100_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ_O.dat
EXECPRG

NSTEP=${NJOB}_455
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_440_${IB}_SORT_GTAR100_O.dat

NSTEP=${NJOB}_460
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Generation of Work File (Retroactive Effect on Balance Sheet of Previus Balance Sheets)(FTRAV5)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_450_${IB}_ESTC2304_GTAR_O.dat 1000"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTRAV5_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M
/DERIVEDFIELD SEPARATEUR8    "~~~~~~~~"
/DERIVEDFIELD SEPARATEUR5    "~~~~~"
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          SEPARATEUR8,
          RETAMT_MC,
          SEPARATEUR5
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_450_${IB}_ESTC2304_GTAR_O.dat > ${DFILT}/${NJOB}_450_ESTC2304_GTAR_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_465
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_450_${IB}_ESTC2304_GTAR_O.dat

#################################################
# Generation of Work Files : FTRAV6             #
#################################################

NSTEP=${NJOB}_470
# Begin sort
#------------------------------------------------------------------------------
LIBEL="sort of FCMUSPLI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCMUSPLI}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCMUSPLI_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 2:1 - 2:,
        RETSEC_NF 4:1 - 4:,
        RTY_NF 3:1 - 3:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF
exit
EOF
SORT

#[003]
NSTEP=${NJOB}_475
# Begin sort
#------------------------------------------------------------------------------
LIBEL="sort of FCMUSPLIT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCMUSPLIT} 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCMUSPLIT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 2:1 - 2:,
        RETSEC_NF 4:1 - 4:,
        RTY_NF 3:1 - 3:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF
exit
EOF
SORT

NSTEP=${NJOB}_480
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Selection of Commutation Type Entries. Filter on Attachable Transaction Codes. Change to Attachable File Format"
PRG=ESTC2323
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_475_${IB}_SORT_FCMUSPLIT_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_470_${IB}_SORT_FCMUSPLI_O.dat
export ${PRG}_I4=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTRAV6_O.dat
EXECPRG

NSTEP=${NJOB}_485
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_475_${IB}_SORT_FCMUSPLIT_O.dat
RMFIL ${DFILT}/${NJOB}_470_${IB}_SORT_FCMUSPLI_O.dat

#[003]
NSTEP=${NJOB}_490
# Begin sort and generation of a Work File
#------------------------------------------------------------------------------
LIBEL="Generation of Work File (Commutations)(FTRAV6)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_480_${IB}_ESTC2323_FTRAV6_O.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTRAV6_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        RETCTR_NF 8:1 - 8:,
        RETEND_NT 9:1 - 9:,
        RETSEC_NF 10:1 - 10:,
        RTY_NF 11:1 - 11:,
        RETUW_NT 12:1 - 12:,
        RETCUR_CF 13:1 - 13:,
        AMT7_M 23:1 - 23:EN 15/3
/KEYS SSD_CF,
      ESB_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF
/SUMMARIZE TOTAL AMT7_M
/DERIVEDFIELD AMT7_MC AMT7_M COMPRESS
/DERIVEDFIELD SEP1 "~~~~~~~~~"
/DERIVEDFIELD SEP2 "~~~~"
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          SEP1,
          AMT7_MC,
          SEP2
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_480_${IB}_ESTC2323_FTRAV6_O.dat > ${DFILT}/${NJOB}_480_ESTC2323_FTRAV6_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_495
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_480_${IB}_ESTC2323_FTRAV6_O.dat


#[003]
NSTEP=${NJOB}_500
#Sum, and merge of FTRAV's files
#-----------------------------------------------------------------------------
LIBEL="Sum, and merge of FTRAV's files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_FTRAV1_O.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_180_${IB}_SORT_FTRAV2_O.dat 500 1"
SORT_I3="${DFILT}/${NJOB}_50_${IB}_ESTC2319_FTRAV3_O.dat 500 1"
SORT_I4="${DFILT}/${NJOB}_405_${IB}_ESTC2321_FTRAV4_O.dat 500 1"
SORT_I5="${DFILT}/${NJOB}_460_${IB}_SORT_FTRAV5_O.dat 500 1"
SORT_I6="${DFILT}/${NJOB}_490_${IB}_SORT_FTRAV6_O.dat 500 1"
SORT_I7="${DFILT}/${NJOB}_335_${IB}_ESTC2324_FTRAV7_O.dat 500 1"
SORT_I8="${DFILT}/${NJOB}_355_${IB}_ESTC2324_FTRAV8_O.dat 500 1"
SORT_I9="${DFILT}/${NJOB}_375_${IB}_ESTC2324_FTRAV9_O.dat 500 1"
SORT_I10="${DFILT}/${NJOB}_105_${IB}_SORT_FTRAV10_O.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTRAV_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        RETCTR_NF 8:1 - 8:,
        RETEND_NT 9:1 - 9:,
        RETSEC_NF 10:1 - 10:,
        RTY_NF 11:1 - 11:,
        RETUW_NT 12:1 - 12:,
        RETCUR_CF 13:1 - 13:,
        ACRES_M 15:1 - 15:EN 15/3,
        THRES_M 16:1 - 16:EN 15/3,
        AMT1_M 17:1 - 17:EN 15/3,
        AMT2_M 18:1 - 18:EN 15/3,
        AMT3_M 19:1 - 19:EN 15/3,
        AMT4_M 20:1 - 20:EN 15/3,
        AMT5_M 21:1 - 21:EN 15/3,
        AMT6_M 22:1 - 22:EN 15/3,
        AMT7_M 23:1 - 23:EN 15/3,
        AMT8_M 24:1 - 24:EN 15/3,
        AMT9_M 25:1 - 25:EN 15/3,
        AMT10_M 26:1 - 26:EN 15/3,
        AMT11_M 27:1 - 27:EN 15/3,
        AMT12_M 28:1 - 28:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETCUR_CF,
      SSD_CF,
      ESB_CF
/SUMMARIZE TOTAL ACRES_M,
           TOTAL THRES_M,
           TOTAL AMT1_M,
           TOTAL AMT2_M,
           TOTAL AMT3_M,
           TOTAL AMT4_M,
           TOTAL AMT5_M,
           TOTAL AMT6_M,
           TOTAL AMT7_M,
           TOTAL AMT8_M,
           TOTAL AMT9_M,
           TOTAL AMT10_M,
           TOTAL AMT11_M,
           TOTAL AMT12_M
/DERIVEDFIELD SEPARATEUR    "~"
/DERIVEDFIELD ACRES_MC ACRES_M COMPRESS
/DERIVEDFIELD THRES_MC THRES_M COMPRESS
/DERIVEDFIELD AMT1_MC AMT1_M COMPRESS
/DERIVEDFIELD AMT2_MC AMT2_M COMPRESS
/DERIVEDFIELD AMT3_MC AMT3_M COMPRESS
/DERIVEDFIELD AMT4_MC AMT4_M COMPRESS
/DERIVEDFIELD AMT5_MC AMT5_M COMPRESS
/DERIVEDFIELD AMT6_MC AMT6_M COMPRESS
/DERIVEDFIELD AMT7_MC AMT7_M COMPRESS
/DERIVEDFIELD AMT8_MC AMT8_M COMPRESS
/DERIVEDFIELD AMT9_MC AMT9_M COMPRESS
/DERIVEDFIELD AMT10_MC AMT10_M COMPRESS
/DERIVEDFIELD AMT11_MC AMT11_M COMPRESS
/DERIVEDFIELD AMT12_MC AMT12_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETCUR_CF,
          SEPARATEUR,
          ACRES_MC,
          THRES_MC,
          AMT1_MC,
          AMT2_MC,
          AMT3_MC,
          AMT4_MC,
          AMT5_MC,
          AMT6_MC,
          AMT7_MC,
          AMT8_MC,
          AMT9_MC,
          AMT10_MC,
          AMT11_MC,
          AMT12_MC
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC2319_FTRAV3_O.dat > ${DFILT}/${NJOB}_50_ESTC2319_FTRAV3_O.dat.gz
gzip -c ${DFILT}/${NJOB}_335_${IB}_ESTC2324_FTRAV7_O.dat > ${DFILT}/${NJOB}_335_ESTC2324_FTRAV7_O.dat.gz
gzip -c ${DFILT}/${NJOB}_355_${IB}_ESTC2324_FTRAV8_O.dat > ${DFILT}/${NJOB}_355_ESTC2324_FTRAV8_O.dat.gz
gzip -c ${DFILT}/${NJOB}_375_${IB}_ESTC2324_FTRAV9_O.dat > ${DFILT}/${NJOB}_375_ESTC2324_FTRAV9_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_505
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_FTRAV1_O.dat
RMFIL ${DFILT}/${NJOB}_180_${IB}_SORT_FTRAV2_O.dat
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTC2319_FTRAV3_O.dat
RMFIL ${DFILT}/${NJOB}_405_${IB}_ESTC2321_FTRAV4_O.dat
RMFIL ${DFILT}/${NJOB}_460_${IB}_SORT_FTRAV5_O.dat
RMFIL ${DFILT}/${NJOB}_490_${IB}_SORT_FTRAV6_O.dat
RMFIL ${DFILT}/${NJOB}_335_${IB}_ESTC2324_FTRAV7_O.dat
RMFIL ${DFILT}/${NJOB}_355_${IB}_ESTC2324_FTRAV8_O.dat
RMFIL ${DFILT}/${NJOB}_375_${IB}_ESTC2324_FTRAV9_O.dat
RMFIL ${DFILT}/${NJOB}_105_${IB}_SORT_FTRAV10_O.dat

#[003]
NSTEP=${NJOB}_510
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of FTRAV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_500_${IB}_SORT_FTRAV_O.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTRAV_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 8:1 - 8:,
        RETEND_NT 9:1 - 9:,
        RETSEC_NF 10:1 - 10:,
        RTY_NF 11:1 - 11:,
        RETUW_NT 12:1 - 12:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_515
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Calculation of the Gross Difference and Purged Difference Determintion of the prop/non prop Retro Nature"
PRG=ESTC2327
export ${PRG}_I1=${EST_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_510_${IB}_SORT_FTRAV_O.dat
export ${PRG}_O1=${EST_FRAPP}
EXECPRG

NSTEP=${NJOB}_520
# Delete of temporary files
#------------------------------------------------------------------------------
LIBEL="Delete of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
