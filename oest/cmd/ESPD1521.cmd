#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 Comptabilisation des ecritures de services
# nom du script SHELL		: ESPD1522.cmd
# revision			: $Revision:   1.8  $
# date de creation		: 03/09/2003
# auteur			: J. Ribot
# references des specifications	:     SPOT EST5085.doc
#-----------------------------------------------------------------------------
# description
#   Special entries booking
#
# Input files
#       EPO_EPOSOCI       DFILI
#       EPO_FCES          DFILP
#       EPO_FCURCVSNI     DFILP
#       EPO_FCURQUOT      DFILP
#       EPO_FDETTRS       DFILP
#       EPO_FPLC          DFILP
#       EPO_FRETTRF       DFILP
#
# Output files
#	     EPO_ECRSOCAPC    DFILI
#	     EPO_ECRSOCRPC    DFILI
#	     EPO_ECRSOCACBP   DFILI
#	     EPO_ECRSOCRCBP   DFILI
#
# Job launched by ESID1800.cmd
#
# Launch C programs ESTM7620 ESTM7621 ESTC2303 ESTC2304
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#
#   02/ 06 / 04 J. Ribot ajout step 00 02 03 05 (conditionné sur COND1 = 'Y' variante 4)
#                           pour garder les enregistrements des filiales non presentes dans l'inventaire (SOPT 4935)
#[002] 11/03/2015 P. Menant       :spot 28122 - EST48, ajout du parametre ICLODAT_D a ESTM7621
#[003] 05/10/2015 -=Dch=-   :spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF) 
#[004] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

#Get input parameters

#===============================================================================

#Get input parameters
INVCONSO_D=$1
CONSOYEA=$2
#[002] ajout de ICLODAT_D
ICLODAT_D=$3

################################################
# Separation de la INVCONSO en 3 YEAR/MTH/DAY
export INVCONSO_YEAR=`echo ${INVCONSO_D} | cut -c1-4`
export INVCONSO_MTH=`echo ${INVCONSO_D} | cut -c5-6`
export INVCONSO_DAY=`echo ${INVCONSO_D} | cut -c7-8`
################################################



# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
#Suppression fichiers pour traitement post omega
#----------------------------------------------------------------------------
#LIBEL="Suppression fichiers pour traitement post omega"

RMFIL   "${EPO_ECRSOCAPC}"
RMFIL   "${EPO_ECRSOCRPC}"
RMFIL   "${EPO_ECRSOCACBP}"
RMFIL   "${EPO_ECRSOCRCBP}"


NSTEP=${NJOB}_10
# Begin sort  ACCEPT
#-----------------------------------------------------------------------------
LIBEL="Sort of EPOSOCI file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_EPOSOCI}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_EPOSOCI_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_SOUS_PREFIX 6:2 - 6:2,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT  12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        GEMPRMPAY_NF 22:1 - 22:,
        GANPAYORD_NT 23:1 - 23:,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETAUTGEN_B 41:1 - 41:,
        ACCTYP_NF 42:1 - 42:EN
/CONDITION SERV ACCTYP_NF = 1
/OUTFILE ${SORT_O}
/INCLUDE SERV
/DERIVEDFIELD INVCONSO_YEAR ${INVCONSO_YEAR}
/DERIVEDFIELD INVCONSO_MTH ${INVCONSO_MTH}
/DERIVEDFIELD INVCONSO_DAY ${INVCONSO_DAY}
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD ZERO "0.000" CHAR 5
/REFORMAT SSD_CF,
          ESB_CF,
          INVCONSO_YEAR,
          SEPARATEUR,
          INVCONSO_MTH,
          SEPARATEUR,
          INVCONSO_DAY,
          SEPARATEUR,
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
          AMT_M,
          CED_NF,
          BRK_NF,
          GEMPRMPAY_NF,
          GANPAYORD_NT,
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
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          ZERO,
          SEPARATEUR,
          RETAUTGEN_B,
          ACCTYP_NF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_13
# Begin sort  RETRO
#-----------------------------------------------------------------------------
LIBEL="Sort of EPOSOCI file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_EPOSOCI}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_EPOSOCI_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:  EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_SOUS_PREFIX 6:2 - 6:2,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT  12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        GEMPRMPAY_NF 22:1 - 22:,
        GANPAYORD_NT 23:1 - 23:,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETAUTGEN_B 41:1 - 41:,
        ACCTYP_NF 42:1 - 42:EN
/CONDITION SERV (ACCTYP_NF = 2 or ACCTYP_NF = 3
                  or ACCTYP_NF = 4 or ACCTYP_NF = 5)
/OUTFILE ${SORT_O}
/INCLUDE SERV
/DERIVEDFIELD INVCONSO_YEAR ${INVCONSO_YEAR}
/DERIVEDFIELD INVCONSO_MTH ${INVCONSO_MTH}
/DERIVEDFIELD INVCONSO_DAY ${INVCONSO_DAY}
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD ZERO "0.000" CHAR 5
/REFORMAT SSD_CF,
          ESB_CF,
          INVCONSO_YEAR,
          SEPARATEUR,
          INVCONSO_MTH,
          SEPARATEUR,
          INVCONSO_DAY,
          SEPARATEUR,
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
          AMT_M,
          CED_NF,
          BRK_NF,
          GEMPRMPAY_NF,
          GANPAYORD_NT,
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
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          ZERO,
          SEPARATEUR,
          RETAUTGEN_B,
          ACCTYP_NF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_EPOSOCI_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAT1_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:
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
exit
EOF
SORT



NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Application of cession operator"
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
INVCONSO_D ${INVCONSO_D}
GTE_B 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_GTAT1_O.dat
export ${PRG}_I2=${EPO_FCES}
export ${PRG}_I3=${EPO_FDETTRS}
export ${PRG}_I4=${EPO_FTRANSCODE}
export ${PRG}_I5=${EPO_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

NSTEP=${NJOB}_45
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_GTAT1_O.dat

NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_40_${IB}_ESTC2303_GTAR100_O.dat
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
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
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
      TRNCOD_CF,
      CUR_CF,
      RETOCCYEA_NF,
      RCL_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      CLM_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF
exit
EOF
SORT

NSTEP=${NJOB}_55
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC2303_GTAR100_O.dat

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 1
BALSHEY_NF ${CONSOYEA}
GTE_B 0
PRS_CF 50
OVERRIDE 1
RETROCOM_FLG N
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_GTAR100_O.dat
export ${PRG}_I2=${EPO_FPLC}
export ${PRG}_I3=${EPO_FCURCVSNI}
export ${PRG}_I4=${EPO_FCURQUOT}
export ${PRG}_I5=${EPO_FCURCVSN}
export ${PRG}_I6=${EPO_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1MAJ_O4.dat
EXECPRG

NSTEP=${NJOB}_65
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_GTAR100_O.dat

#############
# Entries 2 #
#############

NSTEP=${NJOB}_70
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_13_${IB}_SORT_EPOSOCI_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAT2_O.dat
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
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        ACCTYP_NF 43:1 - 43:EN
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
/CONDITION RET23 ACCTYP_NF = 2 or ACCTYP_NF = 3
/OUTFILE ${SORT_O}
/INCLUDE RET23
exit
EOF
SORT

NSTEP=${NJOB}_80
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 1
BALSHEY_NF ${CONSOYEA}
GTE_B 0
PRS_CF 50
OVERRIDE 1
RETROCOM_FLG N
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_70_${IB}_SORT_GTAT2_O.dat
export ${PRG}_I2=${EPO_FPLC}
export ${PRG}_I3=${EPO_FCURCVSNI}
export ${PRG}_I4=${EPO_FCURQUOT}
export ${PRG}_I5=${EPO_FCURCVSN}
export ${PRG}_I6=${EPO_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2MAJ_O4.dat
EXECPRG

NSTEP=${NJOB}_85
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_70_${IB}_SORT_GTAT2_O.dat

#############
# Entries 3#
#############


NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_13_${IB}_SORT_EPOSOCI_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRT3_O.dat
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
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        ACCTYP_NF 43:1 - 43:EN
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
      RETSCOENDMTH_NF
/CONDITION RET45 ACCTYP_NF = 4 or ACCTYP_NF = 5
/OUTFILE ${SORT_O}
/INCLUDE RET45
exit
EOF
SORT

NSTEP=${NJOB}_92
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_13_${IB}_SORT_FACCSUP_O.dat




NSTEP=${NJOB}_105
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_EPOSOCI_O.dat
SORT_I2=${DFILT}/${NJOB}_60_${IB}_ESTC2304_GTRRT1_O3.dat
SORT_I3=${DFILT}/${NJOB}_80_${IB}_ESTC2304_GTRRT2_O3.dat
SORT_I4=${DFILT}/${NJOB}_90_${IB}_SORT_GTRT3_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ECRSOCGT.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_108
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_EPOSOCI_O.dat
RMFIL ${DFILT}/${NJOB}_25_${IB}_ESTM7620_GTEP_O1.dat
RMFIL ${DFILT}/${NJOB}_60_${IB}_ESTC2304_GTRRT1_O3.dat
RMFIL ${DFILT}/${NJOB}_80_${IB}_ESTC2304_GTRRT2_O3.dat
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_GTRT3_O.dat
RMFIL ${DFILT}/${NJOB}_95_${IB}_SORT_CURGTR_O.dat



NSTEP=${NJOB}_110
#Retrocession and Acceptance Data Exchange
#------------------------------------------------------------------------------
LIBEL="Retrocession and Acceptance Data Exchange"
PRG=ESTC2033
export ${PRG}_I1=${DFILT}/${NJOB}_105_${IB}_SORT_ECRSOCGT.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSOCGT_O.dat
EXECPRG

NSTEP=${NJOB}_112
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_105_${IB}_SORT_ECRSOCGT.dat


NSTEP=${NJOB}_115
# Sort of TL, merged by Contrat, Section and U/W Year
#------------------------------------------------------------------------------
LIBEL="Sort of TL, merged by Contrat, Section and U/W Year"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC2033_ECRSOCGT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ECRSOCGT_O1.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 -  1: EN,
        CTR_NF 8:1 - 8:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_118
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_110_${IB}_ESTC2033_ECRSOCGT_O.dat

NSTEP=${NJOB}_120
#Introduction of Conversion and Accumulated Transaction Codes
#[004] ajout de ICLODAT_D
#------------------------------------------------------------------------------
LIBEL="Introduction of Conversion and Accumulated Transaction Codes"
PRG=ESTM7621
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
ICLODAT_D  ${ICLODAT_D}
BALSHEY_NF ${CONSOYEA}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EPO_IARVPERICASE0}
export ${PRG}_I2=${DFILT}/${NJOB}_115_${IB}_SORT_ECRSOCGT_O1.dat
export ${PRG}_I3=${EPO_FTRSLNK}
export ${PRG}_I4=${EPO_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSOCGT_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSOCGTB1_O2.dat
EXECPRG

NSTEP=${NJOB}_122
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_115_${IB}_SORT_ECRSOCGT_O1.dat

NSTEP=${NJOB}_125
# Begin sort
#------------------------------------------------------------------------------
LIBEL="REFORMAT gt"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_ESTM7621_ECRSOCGT_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ECRSOCGT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1 1:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER2 42:1 - 67:
/COPY
/OUTFILE ${SORT_O}
/REFORMAT
           FILLER1,
           FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_128
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_120_${IB}_ESTM7621_ECRSOCGT_O1.dat

NSTEP=${NJOB}_130
# Begin sort
#------------------------------------------------------------------------------
LIBEL="REFORMAT gt"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_ESTM7621_ECRSOCGTB1_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ECRSOCGTB1_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1 1:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER2 42:1 - 67:
/COPY
/OUTFILE ${SORT_O}
/REFORMAT
           FILLER1,
           FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_132
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_120_${IB}_ESTM7621_ECRSOCGTB1_O2.dat

NSTEP=${NJOB}_135
#  Accounting acceptation and cession data separation
#----------------------------------------------------------------------------
LIBEL="Accounting acceptation and cession data separation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_125_${IB}_SORT_ECRSOCGT_O.dat 1000 1"
SORT_O=${EPO_ECRSOCAPC}
SORT_O2=${EPO_ECRSOCRPC}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELD  ESTCRB_CT 49:1 - 49:
/CONDITION CRIBLE ( ESTCRB_CT = "O" or ESTCRB_CT = "N"
         or ESTCRB_CT = "R" or ESTCRB_CT = "S" )
/COPY
/OUTFILE ${SORT_O}
/INCLUDE CRIBLE
/OUTFILE ${SORT_O2}
/OMIT CRIBLE
exit
EOF
SORT

NSTEP=${NJOB}_140
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_125_${IB}_SORT_ECRSOCGT_O.dat

NSTEP=${NJOB}_145
#  Accounting acceptation and cession data separation
#----------------------------------------------------------------------------
LIBEL="Accounting acceptation and cession data separation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_SORT_ECRSOCGTB1_O.dat 1000 1"
SORT_O=${EPO_ECRSOCACBP}
SORT_O2=${EPO_ECRSOCRCBP}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELD  ESTCRB_CT 49:1 - 49:
/CONDITION CRIBLE ( ESTCRB_CT = "O" or ESTCRB_CT = "N"

         or ESTCRB_CT = "R" or ESTCRB_CT = "S" )
/COPY
/OUTFILE ${SORT_O}
/INCLUDE CRIBLE
/OUTFILE ${SORT_O2}
/OMIT CRIBLE
exit
EOF
SORT

NSTEP=${NJOB}_150
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_130_${IB}_SORT_ECRSOCGTB1_O.dat

NSTEP=${NJOB}_155
# Begin rm
#----------------------------------------------------------------------------
LIBEL="Delete temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

