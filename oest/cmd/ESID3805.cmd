#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 Epuration Fichier FTECLEDA
#				                
# nom du script SHELL		: ESID3805.cmd
# revision			: $Revision:   1.2  $
# date de creation		: 25/03/2004
# auteur			: M. DJELLOULI
# references des specifications	: SPOT (5088 et 10076)
#                                 Fiches SPOT 5088 Optimisation inventaire
#                                 Fiches SPOT 10076 Suivi BSAR TTECLEDA
#-----------------------------------------------------------------------------
# description
#   10076 - Suivi du nombre de lignes dans TTECLEDA sur les différents inventaires (évolutions par postes)
#   5008 - Optimisation inventaire 
#
#   1- On effectue une première extraction des écritures de FTECLA =< Date de BILAN
#      On Cumule ces écritures en DATE MAX (BALSHTYEA_NF, BALSHTMTH_NF)
#   2- On effectue une seconde extraction des écritures de FTECLA > DATE de BILAN
#   3- On ajoute les écritures cumulées en (1) avec les écritures cumulées en (2) dans un nouveau Fichier.
#   4- Ce nouveau fichier est nommé à nouveau TTCLEDA
#
# Input files
#       EST_FTECLEDA			DFILP
#
# Output files
#       EST_FTECLEDA			DFILP
#
# launched by ESID3800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
    

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd


# Get input parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4

# Job Initialisation
JOBINIT

# Creation des Fichiers d'extractions 
NSTEP=${NJOB}_10
# Extraction Temporaire Ecritures AVANT Date BILAN
#-----------------------------------------------------------------------------
LIBEL="Extraction Temporaire Ecritures AVANT Date BILAN."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_PART1.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TECLEDA_SSD_CF 1:1 - 1: ,
        TECLEDA_ESB_CF 2:1 - 2: ,
        TECLEDA_BALSHEY_NF 3:1 - 3:EN ,
        TECLEDA_BALSHRMTH_NF 4:1 - 4:EN ,
        TECLEDA_BALSHRDAY_NF 5:1 - 5:EN ,
        TECLEDA_TRNCOD_CF 6:1 - 6:,
        TECLEDA_CTR_NF 8:1 - 8: ,
        TECLEDA_END_NT 9:1 - 9: ,
        TECLEDA_SEC_NF 10:1 - 10: ,
        TECLEDA_UWY_NF 11:1 - 11: ,
        TECLEDA_UW_NT 12:1 - 12: ,
        TECLEDA_OCCYEA_NF 13:1 - 13: ,
        TECLEDA_ACY_NF 14:1 - 14: ,
        TECLEDA_SCOSTRMTH_NF 15:1 - 15: ,
        TECLEDA_SCOENDMTH_NF 16:1 - 16: ,
        TECLEDA_CLM_NF 17:1 - 17: ,
        TECLEDA_CUR_CF 18:1 - 18: ,
        TECLEDA_RETCTR_NF 24:1 - 24: ,
        TECLEDA_RETEND_NT 25:1 - 25: ,
        TECLEDA_RETSEC_NF 26:1 - 26: ,
        TECLEDA_RTY_NF 27:1 - 27: ,
        TECLEDA_RETUW_NT 28:1 - 28: ,
        TECLEDA_RETOCCYEA_NF 29:1 - 29: ,
        TECLEDA_RETACY_NF 30:1 - 30: ,
        TECLEDA_RETSCOSTRMTH_NF 31:1 - 31: ,
        TECLEDA_RETSCOENDMTH_NF 32:1 - 32: ,
        TECLEDA_RCL_NF 33:1 - 33: ,
        TECLEDA_RETCUR_CF 34:1 - 34:,
        TRNCOD_CF_SUFFIX 6:8 - 6:8
/KEYS TECLEDA_SSD_CF,
      TECLEDA_ESB_CF,
      TECLEDA_CTR_NF,
      TECLEDA_END_NT,
      TECLEDA_SEC_NF,
      TECLEDA_UWY_NF,
      TECLEDA_UW_NT,
      TECLEDA_ACY_NF,
      TECLEDA_SCOENDMTH_NF,
      TECLEDA_SCOSTRMTH_NF,
      TECLEDA_OCCYEA_NF,
      TECLEDA_CLM_NF,
      TECLEDA_CUR_CF,
      TECLEDA_RETCTR_NF,
      TECLEDA_RETEND_NT,
      TECLEDA_RETSEC_NF,
      TECLEDA_RTY_NF,
      TECLEDA_RETUW_NT,
      TECLEDA_RETACY_NF,
      TECLEDA_RETSCOENDMTH_NF,
      TECLEDA_RETSCOSTRMTH_NF,
      TECLEDA_RETOCCYEA_NF,
      TECLEDA_RCL_NF,
      TECLEDA_RETCUR_CF,
      TECLEDA_TRNCOD_CF,
      TECLEDA_BALSHEY_NF ASCENDING,
      TECLEDA_BALSHRMTH_NF DESCENDING,
      TECLEDA_BALSHRDAY_NF DESCENDING
/CONDITION TECLEDA_BALSHEY (TECLEDA_BALSHEY_NF LT ${BALSHTYEA_NF} OR (TECLEDA_BALSHEY_NF EQ ${BALSHTYEA_NF} AND TECLEDA_BALSHRMTH_NF LT ${BALSHTMTH_NF}))
                                     AND (TRNCOD_CF_SUFFIX GT "1" )
/INCLUDE TECLEDA_BALSHEY
exit
EOF
SORT


NSTEP=${NJOB}_15
# Tri pour CUMUL
#-----------------------------------------------------------------------------
LIBEL="TRI par pour CUMUL Fichier (AVANT Date Bilan)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_FTECLEDA_PART1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_PART1.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TECLEDA_SSD_CF 1:1 - 1: ,
        TECLEDA_ESB_CF 2:1 - 2: ,
        TECLEDA_TRNCOD_CF 6:1 - 6: ,
        TECLEDA_CTR_NF 8:1 - 8: ,
        TECLEDA_END_NT 9:1 - 9: ,
        TECLEDA_SEC_NF 10:1 - 10: ,
        TECLEDA_UWY_NF 11:1 - 11: ,
        TECLEDA_UW_NT 12:1 - 12: ,
        TECLEDA_OCCYEA_NF 13:1 - 13: ,
        TECLEDA_ACY_NF 14:1 - 14: ,
        TECLEDA_SCOSTRMTH_NF 15:1 - 15: ,
        TECLEDA_SCOENDMTH_NF 16:1 - 16: ,
        TECLEDA_CLM_NF 17:1 - 17: ,
        TECLEDA_CUR_CF 18:1 - 18: ,
        TECLEDA_AMT_M 19:1 - 19:EN 15/3,
        TECLEDA_RETCTR_NF 24:1 - 24: ,
        TECLEDA_RETEND_NT 25:1 - 25: ,
        TECLEDA_RETSEC_NF 26:1 - 26: ,
        TECLEDA_RTY_NF 27:1 - 27: ,
        TECLEDA_RETUW_NT 28:1 - 28: ,
        TECLEDA_RETOCCYEA_NF 29:1 - 29: ,
        TECLEDA_RETACY_NF 30:1 - 30: ,
        TECLEDA_RETSCOSTRMTH_NF 31:1 - 31: ,
        TECLEDA_RETSCOENDMTH_NF 32:1 - 32: ,
        TECLEDA_RCL_NF 33:1 - 33: ,
        TECLEDA_RETCUR_CF 34:1 - 34: ,
        TECLEDA_RETAMT_M 35:1 - 35:EN 15/3,
        TECLEDA_RETINTAMT_M 88:1 - 88:EN 15/3
/KEYS TECLEDA_SSD_CF,
      TECLEDA_ESB_CF,
      TECLEDA_CTR_NF,
      TECLEDA_END_NT,
      TECLEDA_SEC_NF,
      TECLEDA_UWY_NF,
      TECLEDA_UW_NT,
      TECLEDA_ACY_NF,
      TECLEDA_SCOENDMTH_NF,
      TECLEDA_SCOSTRMTH_NF,
      TECLEDA_OCCYEA_NF,
      TECLEDA_CLM_NF,
      TECLEDA_CUR_CF,
      TECLEDA_RETCTR_NF,
      TECLEDA_RETEND_NT,
      TECLEDA_RETSEC_NF,
      TECLEDA_RTY_NF,
      TECLEDA_RETUW_NT,
      TECLEDA_RETACY_NF,
      TECLEDA_RETSCOENDMTH_NF,
      TECLEDA_RETSCOSTRMTH_NF,
      TECLEDA_RETOCCYEA_NF,
      TECLEDA_RCL_NF,
      TECLEDA_RETCUR_CF,
      TECLEDA_TRNCOD_CF
exit
EOF
SORT

NSTEP=${NJOB}_17
# Suppression Fichier Temporaire Extraction.
#-----------------------------------------------------------------------------
LIBEL="Suppression Fichier Extrait Temporaire de traitement FTECLEDA_PART1 et FTECLEDA_PART2 "
RMFIL "${DFILT}/${NJOB}_10_${IB}_*.dat"


NSTEP=${NJOB}_20
# PGM ESTC3805 - Cumul Fichier Inventaire.
#-----------------------------------------------------------------------------
LIBEL="PGM ESTC3805 - Cumul Fichier Inventaire."
PRG=ESTC3805
export ${PRG}_I1=${DFILT}/${NJOB}_15_${IB}_FTECLEDA_PART1.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA_PART1.dat
EXECPRG

NSTEP=${NJOB}_23
# Suppression Fichier Temporaire Extraction.
#-----------------------------------------------------------------------------
LIBEL="Suppression Fichier Extrait Temporaire de traitement FTECLEDA_PART1 et FTECLEDA_PART2 "
RMFIL "${DFILT}/${NJOB}_15_${IB}_*.dat"


NSTEP=${NJOB}_25
# Tri du Fichier en Entrée
#-----------------------------------------------------------------------------
LIBEL="Extraction Temporaire Ecritures APRES Date BILAN"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_PART2.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TECLEDA_SSD_CF 1:1 - 1: ,
        TECLEDA_ESB_CF 2:1 - 2: ,
        TECLEDA_BALSHEY_NF 3:1 - 3:EN ,
        TECLEDA_BALSHRMTH_NF 4:1 - 4:EN ,
        TECLEDA_BALSHRDAY_NF 5:1 - 5:EN ,
        TECLEDA_TRNCOD_CF 6:1 - 6: ,
        TECLEDA_CTR_NF 8:1 - 8: ,
        TECLEDA_END_NT 9:1 - 9: ,
        TECLEDA_SEC_NF 10:1 - 10: ,
        TECLEDA_UWY_NF 11:1 - 11: ,
        TECLEDA_UW_NT 12:1 - 12: ,
        TECLEDA_OCCYEA_NF 13:1 - 13: ,
        TECLEDA_ACY_NF 14:1 - 14: ,
        TECLEDA_SCOSTRMTH_NF 15:1 - 15: ,
        TECLEDA_SCOENDMTH_NF 16:1 - 16: ,
        TECLEDA_CLM_NF 17:1 - 17: ,
        TECLEDA_CUR_CF 18:1 - 18: ,
        TECLEDA_RETCTR_NF 24:1 - 24: ,
        TECLEDA_RETEND_NT 25:1 - 25: ,
        TECLEDA_RETSEC_NF 26:1 - 26: ,
        TECLEDA_RTY_NF 27:1 - 27: ,
        TECLEDA_RETUW_NT 28:1 - 28: ,
        TECLEDA_RETOCCYEA_NF 29:1 - 29: ,
        TECLEDA_RETACY_NF 30:1 - 30: ,
        TECLEDA_RETSCOSTRMTH_NF 31:1 - 31: ,
        TECLEDA_RETSCOENDMTH_NF 32:1 - 32: ,
        TECLEDA_RCL_NF 33:1 - 33: ,
        TECLEDA_RETCUR_CF 34:1 - 34:,
        TRNCOD_CF_SUFFIX 6:8 - 6:8
/KEYS TECLEDA_SSD_CF,
      TECLEDA_ESB_CF,
      TECLEDA_CTR_NF,
      TECLEDA_END_NT,
      TECLEDA_SEC_NF,
      TECLEDA_UWY_NF,
      TECLEDA_UW_NT,
      TECLEDA_ACY_NF,
      TECLEDA_SCOENDMTH_NF,
      TECLEDA_SCOSTRMTH_NF,
      TECLEDA_OCCYEA_NF,
      TECLEDA_CLM_NF,
      TECLEDA_CUR_CF,
      TECLEDA_RETCTR_NF,
      TECLEDA_RETEND_NT,
      TECLEDA_RETSEC_NF,
      TECLEDA_RTY_NF,
      TECLEDA_RETUW_NT,
      TECLEDA_RETACY_NF,
      TECLEDA_RETSCOENDMTH_NF,
      TECLEDA_RETSCOSTRMTH_NF,
      TECLEDA_RETOCCYEA_NF,
      TECLEDA_RCL_NF,
      TECLEDA_RETCUR_CF,
      TECLEDA_TRNCOD_CF,
      TECLEDA_BALSHEY_NF ASCENDING,
      TECLEDA_BALSHRMTH_NF DESCENDING,
      TECLEDA_BALSHRDAY_NF DESCENDING
/CONDITION TECLEDA_BALSHEY ((TECLEDA_BALSHEY_NF EQ ${BALSHTYEA_NF} AND TECLEDA_BALSHRMTH_NF EQ ${BALSHTMTH_NF}) OR (TECLEDA_BALSHEY_NF GT ${BALSHTYEA_NF})  OR (TECLEDA_BALSHEY_NF EQ ${BALSHTYEA_NF} AND TECLEDA_BALSHRMTH_NF GT ${BALSHTMTH_NF}))
                                  OR  (TRNCOD_CF_SUFFIX LT "2" )
/INCLUDE TECLEDA_BALSHEY
exit
EOF
SORT


NSTEP=${NJOB}_30
# Sauvegarde du Fichier FTECLEDA avant Optimisation 
#----------------------------------------------------------------------------
LIBEL="ZIP FTECLEDA"
ZIP_ODIR=""
ZIP_I="${EST_FTECLEDA}"
ZIP_O="${EST_FTECLEDA}.z.zip"
ZIP_OPT=""
ZIP_MODE="Z"
ZIP	    


NSTEP=${NJOB}_35
# Suppression Ancien Fichier
#------------------------------------------------------------------------------
LIBEL="Suppression Ancien Fichier avant nouveau Merge"
RMFIL "${EST_FTECLEDA}"


NSTEP=${NJOB}_40
# Merge of TL files
#------------------------------------------------------------------------------
LIBEL="Merge of FTCLEDA files PART1 and PART2"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_ESTC3805_FTECLEDA_PART1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_25_${IB}_FTECLEDA_PART2.dat 1000 1"
SORT_O="${EST_FTECLEDA} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_45
# Suppression Fichier Temporaire Extraction.
#-----------------------------------------------------------------------------
LIBEL="Suppression Fichier Extrait Temporaire de traitement FTECLEDA_PART1 et FTECLEDA_PART2 "
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
