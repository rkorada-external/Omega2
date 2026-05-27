#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -
#                                 Comptabilisation des ecritures de couverture
#
# nom du script SHELL		: ESID1551.cmd
# revision			: $Revision:   1.6  $
# date de creation		: 20/11/97
# auteur			: C.G.I. (M.HA-THUC)
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Special entries booking
#
# Input files
#       EST_FACCSUP      DFILI
#       EST_FCES                 DFILP
#       EST_FCURCVSNI    DFILI
#       EST_FCURQUOT             DFILP
#       EST_FDETTRS      DFILI
#       EST_FPLC                 DFILP
#       EST_FRETTRF      DFILI
#
# Output files
#       EST_DLRNPGTAA    DFILI
#       EST_DLRNPGTAR            DFILP
#       EST_DLRNPGTR             DFILP
#
# Launch C program ESTC2303 ESTC2304
#
# Job launched by ESID1550.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#   31/ 01 / 03 J. Ribot ajout gestion colonne retintamt_m
#   01/ 06 / 04 J. Ribot ajout step 07 , 218 et 203 pour garder les enregistrements
#                        des filiales non presentes dans l'inventaire (SOPT 4935)
#[003] 05/10/2015 -=Dch=-  	:spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF) 
#[004] 01/02/2016  Florent  :spot:29066 GT à 71 colonnes
#[005] 27/04/2016  Roger  :spot:30516 Ajout gzips pour test agrandissament GT
#[006] 18/03/2021  B.Lagha:spot:81531 Remplacer les noms des fichiers perm par des varibales step 010 et 03
#[007] 24/11/2023  JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0  
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

#Get input parameters
CLODAT_D=$1
BALSHEY_NF=$2

# Job Initialisation
JOBINIT

if [ "${EST_ESID1550_COND1}" = "Y" ]
then
NSTEP=${NJOB}_010
#------------------------------------------------------------------------------
LIBEL="move EST_DLRNPGTAA ==> DFILT _WRK_DLRNPGTAA.dat"
EXECKSH "cp ${EST_DLRNPGTAA} ${DFILT}/${NSTEP}_${IB}_WRK_DLRNPGTAA.dat"


NSTEP=${NJOB}_011
#------------------------------------------------------------------------------
LIBEL="move EST_DLRNPGTAR ==> DFILT _WRK_DLRNPGTAR.dat"
EXECKSH "cp ${EST_DLRNPGTAR} ${DFILT}/${NSTEP}_${IB}_WRK_DLRNPGTAR.dat"

NSTEP=${NJOB}_012
#------------------------------------------------------------------------------
LIBEL="move EST_DLRNPGTR ==> DFILT _WRK_DLRNPGTR.dat"
EXECKSH "cp ${EST_DLRNPGTR} ${DFILT}/${NSTEP}_${IB}_WRK_DLRNPGTR.dat"

fi

NSTEP=${NJOB}_03
#Last version of ESID1550 files deletion
#-----------------------------------------------------------------
RMFIL "  ${EST_DLRNPGTAA}
         ${EST_DLRNPGTAR}
         ${EST_DLRNPGTR} "


NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of FACCSUP file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FACCSUP}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
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
        RETKEY_CF 40:1 -40:,
        RETAUTGEN_B 41:1 - 41:,
        ACCTYP_NF    42:1 - 42:EN,
        TRN_NT       43:1 - 43:,
        ORICOD_LS    44:1 - 44:,
        RETROAUTO_B  45:1 - 45:,
        SPEENTNAT_CT 46:1 - 46:,
        EVT_NF       47:1 - 47:,
        REVT_NF      48:1 - 48:
/CONDITION SERV (TRNCOD_SOUS_PREFIX < "4" or "SCORIT" CT TRNCOD_SOUS_PREFIX)
                and ACCTYP_NF != 0 and ACCTYP_NF != 1
                and ACCTYP_NF != 98 and ACCTYP_NF != 99
/OUTFILE ${SORT_O}
/INCLUDE SERV
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD ZERO "0.000" CHAR 5
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
          ACCTYP_NF,
          TRN_NT,
          ORICOD_LS,
          RETROAUTO_B,
          SPEENTNAT_CT,
          EVT_NF,
          REVT_NF
/COPY
exit
EOF
SORT

# ajout step pour garder les enregistrements des filiales non presentes dans l'inventaire
#  JR 01/06/2004
NSTEP=${NJOB}_07
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
#SORT_I=${EST_DLRNPGTAA}
SORT_I=${DFILT}/${NJOB}_010_${IB}_WRK_DLRNPGTAA.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLRNPGTAA_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/OMIT INVENTAIRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Split of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_05_${IB}_SORT_FACCSUP_O.dat
#SORT_O=${EST_DLRNPGTAA}
SORT_O=${DFILT}/${NJOB}_10_${IB}_SORT_DLRNPGTAA_O.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTAT1_O2.dat
SORT_O3=${DFILT}/${NSTEP}_${IB}_SORT_GTAT2_O3.dat
SORT_O4=${DFILT}/${NSTEP}_${IB}_SORT_GTAT3_O4.dat
SORT_O5=${DFILT}/${NSTEP}_${IB}_SORT_GTRRT4_O5.dat
SORT_O6=${DFILT}/${NSTEP}_${IB}_SORT_GTAT5_O6.dat

INPUT_TEXT $SORT_CMD <<EOF
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
        AMT_M 19:1 - 19:,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        RETAUTGEN_B 42:1 - 42:,
        ACCTYP_NF 43:1 - 43:,
        TRN_NT       44:1 - 44:,
        ORICOD_LS    45:1 - 45:,
        RETROAUTO_B  46:1 - 46:,
        SPEENTNAT_CT 47:1 - 47:,
        EVT_NF       48:1 - 48:,
        REVT_NF      49:1 - 49:
/CONDITION TYP1 ACCTYP_NF EQ "1" or ACCTYP_NF EQ "99"
/CONDITION TYP2 ACCTYP_NF EQ "2"
/CONDITION TYP3 ACCTYP_NF EQ "3"
/CONDITION TYP4 ACCTYP_NF EQ "4"
/CONDITION TYP5 ACCTYP_NF EQ "5"
/CONDITION TYP1AUT1 RETAUTGEN_B EQ "1" and ( ACCTYP_NF EQ "1" or ACCTYP_NF EQ "99" )
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/DERIVEDFIELD PLUS_10_CHAMPS 10"~"
/COPY
/OUTFILE ${SORT_O}
   /INCLUDE TYP1
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
             AMT_M,
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
             RETAMT_M,
             PLC_NT,
             RTO_NF,
             INT_NF,
             RETPAY_NF,
             RETKEY_CF,
             RETINTAMT_M,
             PLUS_14_CHAMPS,
             TRN_NT,
             ORICOD_LS,
             RETROAUTO_B,
             SPEENTNAT_CT,
             EVT_NF,
             REVT_NF,
             PLUS_10_CHAMPS
/OUTFILE ${SORT_O2}
   /INCLUDE TYP1AUT1
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
             AMT_M,
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
             RETAMT_M,
             PLC_NT,
             RTO_NF,
             INT_NF,
             RETPAY_NF,
             RETKEY_CF,
             RETINTAMT_M,
             PLUS_14_CHAMPS,
             TRN_NT,
             ORICOD_LS,
             RETROAUTO_B,
             SPEENTNAT_CT,
             EVT_NF,
             REVT_NF,
             PLUS_10_CHAMPS
/OUTFILE ${SORT_O3}
   /INCLUDE TYP2
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
             AMT_M,
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
             RETAMT_M,
             PLC_NT,
             RTO_NF,
             INT_NF,
             RETPAY_NF,
             RETKEY_CF,
             RETINTAMT_M,
             PLUS_14_CHAMPS,
             TRN_NT,
             ORICOD_LS,
             RETROAUTO_B,
             SPEENTNAT_CT,
             EVT_NF,
             REVT_NF,
             PLUS_10_CHAMPS
/OUTFILE ${SORT_O4}
   /INCLUDE TYP3
   /REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF,RETINTAMT_M,PLUS_14_CHAMPS,TRN_NT,ORICOD_LS,RETROAUTO_B,SPEENTNAT_CT,EVT_NF,REVT_NF,PLUS_10_CHAMPS
/OUTFILE ${SORT_O5}
   /INCLUDE TYP4
   /REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF,RETINTAMT_M,PLUS_14_CHAMPS,TRN_NT,ORICOD_LS,RETROAUTO_B,SPEENTNAT_CT,EVT_NF,REVT_NF,PLUS_10_CHAMPS

/OUTFILE ${SORT_O6}
   /INCLUDE TYP5
   /REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF,RETINTAMT_M,PLUS_14_CHAMPS,TRN_NT,ORICOD_LS,RETROAUTO_B,SPEENTNAT_CT,EVT_NF,REVT_NF,PLUS_10_CHAMPS

exit
EOF
SORT

NSTEP=${NJOB}_12
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Split of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_07_${IB}_SORT_DLRNPGTAA_O.dat
SORT_I2=${DFILT}/${NJOB}_10_${IB}_SORT_DLRNPGTAA_O.dat
SORT_O=${EST_DLRNPGTAA}
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_15
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_010_${IB}_WRK_DLRNPGTAA.dat
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_FACCSUP_O.dat
RMFIL ${DFILT}/${NJOB}_07_${IB}_SORT_DLRNPGTAA_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_DLRNPGTAA_O.dat

#############
# Entries 1 #
#############


NSTEP=${NJOB}_20
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_GTAT1_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAT1_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:, KEY_CTR 8:1 - 12:, KEY_ACY 14:1 - 16:, CUR_CF 18:1 - 18:
/KEYS KEY_CTR, TRNCOD_CF, KEY_ACY, CUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_25
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT1_O2.dat


NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Application of cession operator"
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
GTE_B 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_GTAT1_O.dat
export ${PRG}_I2=${EST_FCES}
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

NSTEP=${NJOB}_35
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_GTAT1_O.dat

NSTEP=${NJOB}_36
#-----------------------------------------------------------------------------
LIBEL="Reformat ${EST_FACCSUP} for maj TRN_NT RETRO AUTO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FACCSUP} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_RETROAUTO_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF    24:1 - 24:,
        RETSEC_NF    26:1 - 26:,
        RTY_NF       27:1 - 27:,
        ACCTYP_NF    42:1 - 42:EN,
        TRN_NT       43:1 - 43:,
        ACCTRN_NT    49:1 - 49:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      ACCTRN_NT
/CONDITION RETROAUTO ACCTYP_NF EQ 0
/OUTFILE ${SORT_O}
/INCLUDE RETROAUTO
/REFORMAT RETCTR_NF,RETSEC_NF,RTY_NF,TRN_NT,ACCTRN_NT
exit
EOF
SORT

NSTEP=${NJOB}_37
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="SyncSort Maj TRN_NT RETRO AUTO de ESTC2303"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_30_${IB}_ESTC2303_GTAR100_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_MAJ_RETRO_ES_GTAR100_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
 GT_RETCTR_NF       24:1 - 24:
,GT_RETSEC_NF       26:1 - 26:
,GT_RTY_NF          27:1 - 27:
,GT_TRN_NT          56:1 - 56:
,GT_DEBUT            1:1 - 55:
,GT_FIN             57:1 - 71:

,FACCSUP_RETCTR_NF 1:1 - 1:
,FACCSUP_RETSEC_NF 2:1 - 2:
,FACCSUP_RTY_NF    3:1 - 3:
,FACCSUP_TRN_NT    4:1 - 4:
,FACCSUP_ACCTRN_NT 5:1 - 5:

/JOINKEYS GT_RETCTR_NF,GT_RETSEC_NF,GT_RTY_NF,GT_TRN_NT

/INFILE ${DFILT}/${NJOB}_36_${IB}_SORT_FACCSUP_RETROAUTO_O.dat 1000 1
/JOINKEYS SORTED FACCSUP_RETCTR_NF,FACCSUP_RETSEC_NF,FACCSUP_RTY_NF,FACCSUP_ACCTRN_NT

/JOIN UNPAIRED LEFTSIDE

/OUTFILE ${SORT_O}
/REFORMAT
 LEFTSIDE:  GT_DEBUT
,RIGHTSIDE: FACCSUP_TRN_NT
,LEFTSIDE:  GT_FIN

exit
EOF
SORT

NSTEP=${NJOB}_40
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_37_${IB}_MAJ_RETRO_ES_GTAR100_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
 TRNCOD_CF 6:1 - 6:
,CTR_NF 8:1 - 8:
,END_NT 9:1 - 9:
,SEC_NF 10:1 - 10:
,UWY_NF 11:1 - 11:
,UW_NT 12:1 - 12:
,OCCYEA_NF 13:1 - 13:
,ACY_NF 14:1 - 14:
,SCOSTRMTH_NF 15:1 - 15:
,SCOENDMTH_NF 16:1 - 16:
,CUR_CF 18:1 - 18:
,RETCTR_NF 24:1 - 24:
,RETEND_NT 25:1 - 25:
,RETSEC_NF 26:1 - 26:
,RTY_NF 27:1 - 27:
,RETUW_NT 28:1 - 28:
,RETOCCYEA_NF 29:1 - 29:
,RETACY_NF 30:1 - 30:
,RETSCOSTRMTH_NF 31:1 - 31:
,RETSCOENDMTH_NF 32:1 - 32:
,RCL_NF          33:1 - 33:
,TRN_NT 56:1 - 56:
,RETROAUTO_B 58:1 - 58:
/KEYS
 RETCTR_NF
,RETEND_NT
,RETSEC_NF
,RTY_NF
,RETUW_NT
,TRNCOD_CF
,CUR_CF
,RETOCCYEA_NF
,RCL_NF
,RETACY_NF
,RETSCOSTRMTH_NF
,RETSCOENDMTH_NF
,CTR_NF
,END_NT
,SEC_NF
,UWY_NF
,UW_NT
,OCCYEA_NF
,ACY_NF
,SCOSTRMTH_NF
,SCOENDMTH_NF
,TRN_NT
,RETROAUTO_B
exit
EOF
SORT

NSTEP=${NJOB}_45
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTC2303_GTAR100_O.dat

NSTEP=${NJOB}_50
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 1
BALSHEY_NF ${BALSHEY_NF}
GTE_B 0
PRS_CF 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_GTAR100_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1MAJ_O4.dat
EXECPRG

#-----------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_40_${IB}_SORT_GTAR100_O.dat    > ${DFILT}/${NJOB}_40_SORT_GTAR100_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1_O1.dat    > ${DFILT}/${NSTEP}_${PRG}_GTART1_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1MAJ_O2.dat > ${DFILT}/${NSTEP}_${PRG}_GTART1MAJ_O2.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1_O3.dat    > ${DFILT}/${NSTEP}_${PRG}_GTRRT1_O3.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1MAJ_O4.dat > ${DFILT}/${NSTEP}_${PRG}_GTRRT1MAJ_O4.dat.gz 
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_55
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_GTAR100_O.dat

NSTEP=${NJOB}_60
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1_O1.dat
SORT_I2=${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1MAJ_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART1_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
  SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
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
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
  RETINTAMT_M 41:1 - 41: EN 15/3,
  TRN_NT 56:1 - 56:,
  RETROAUTO_B 58:1 - 58:
/KEYS
  SSD_CF,
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
  PLC_NT,
  TRN_NT,
  RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_65
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1_O1.dat
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1MAJ_O2.dat

NSTEP=${NJOB}_70
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1_O3.dat
SORT_I2=${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1MAJ_O4.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRRT1_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
 TRNCOD       6:1 - 6:
,KEY_RETCTR  24:1 - 34:
,RETAMT_M    35:1 - 35:EN 15/3
,PLC_NT      36:1 - 36:
,RETINTAMT_M 41:1 - 41:EN 15/3
,TRN_NT      56:1 - 56:
,RETROAUTO_B 58:1 - 58:
/KEYS TRNCOD,KEY_RETCTR,PLC_NT,TRN_NT,RETROAUTO_B
/SUMMARIZE TOTAL RETAMT_M,TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_75
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1_O3.dat
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1MAJ_O4.dat


#############
# Entries 2 #
#############


NSTEP=${NJOB}_90
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_GTAT2_O3.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAT2_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
 TRNCOD_CF 6:1 - 6:
,CTR_NF 8:1 - 8:
,END_NT 9:1 - 9: 
,SEC_NF 10:1 - 10: 
,UWY_NF 11:1 - 11: 
,UW_NT 12:1 - 12: 
,OCCYEA_NF 13:1 - 13: 
,ACY_NF 14:1 - 14: 
,SCOSTRMTH_NF 15:1 - 15: 
,SCOENDMTH_NF 16:1 - 16: 
,CUR_CF 18:1 - 18:
,RETCTR_NF 24:1 - 24:
,RETEND_NT 25:1 - 25: 
,RETSEC_NF 26:1 - 26: 
,RTY_NF 27:1 - 27: 
,RETUW_NT 28:1 - 28:
,RETOCCYEA_NF 29:1 - 29: 
,RETACY_NF 30:1 - 30: 
,RETSCOSTRMTH_NF 31:1 - 31: 
,RETSCOENDMTH_NF 32:1 - 32:
,RCL_NF          33:1 - 33:
,TRN_NT 56:1 - 56:
,RETROAUTO_B 58:1 - 58:
/KEYS
 RETCTR_NF
,RETEND_NT
,RETSEC_NF
,RTY_NF
,RETUW_NT
,TRNCOD_CF
,CUR_CF
,RETOCCYEA_NF
,RCL_NF
,RETACY_NF
,RETSCOSTRMTH_NF
,RETSCOENDMTH_NF
,CTR_NF
,END_NT
,SEC_NF
,UWY_NF
,UW_NT 
,OCCYEA_NF
,ACY_NF
,SCOSTRMTH_NF
,SCOENDMTH_NF
,TRN_NT
,RETROAUTO_B
exit
EOF
SORT

NSTEP=${NJOB}_95
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT2_O3.dat

NSTEP=${NJOB}_100
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 1
BALSHEY_NF ${BALSHEY_NF}
GTE_B 0
PRS_CF 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_90_${IB}_SORT_GTAT2_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2MAJ_O4.dat
EXECPRG

#-----------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_90_${IB}_SORT_GTAT2_O.dat      > ${DFILT}/${NJOB}_90_SORT_GTAT2_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2_O1.dat    > ${DFILT}/${NSTEP}_${PRG}_GTART2_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2MAJ_O2.dat > ${DFILT}/${NSTEP}_${PRG}_GTART2MAJ_O2.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2_O3.dat    > ${DFILT}/${NSTEP}_${PRG}_GTRRT2_O3.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2MAJ_O4.dat > ${DFILT}/${NSTEP}_${PRG}_GTRRT2MAJ_O4.dat.gz 
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_103
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_GTAT2_O.dat


NSTEP=${NJOB}_105
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_100_${IB}_ESTC2304_GTART2_O1.dat
SORT_I2=${DFILT}/${NJOB}_100_${IB}_ESTC2304_GTART2MAJ_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART2_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
  SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
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
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
  RETINTAMT_M 41:1 - 41: EN 15/3,
  TRN_NT 56:1 - 56:,
  RETROAUTO_B 58:1 - 58:
/KEYS
  SSD_CF,
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
  PLC_NT,
  TRN_NT,
  RETROAUTO_B
/SUMMARIZE
  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_108
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_100_${IB}_ESTC2304_GTART2_O1.dat
RMFIL ${DFILT}/${NJOB}_100_${IB}_ESTC2304_GTART2MAJ_O2.dat

NSTEP=${NJOB}_110
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_105_${IB}_SORT_GTART2_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART2_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:
       ,ESB_CF 2:1 - 2:
       ,BALSHEY_NF 3:1 - 3:
       ,BALSHRMTH_NF 4:1 - 4:
       ,BALSHRDAY_NF 5:1 - 5:
       ,TRNCOD_CF 6:1 - 6:
       ,DBLTRNCOD_CF 7:1 - 7:
       ,CTR_NF 8:1 - 8:
       ,END_NT 9:1 - 9:
       ,SEC_NF 10:1 - 10:
       ,UWY_NF 11:1 - 11:
       ,UW_NT 12:1 - 12:
       ,OCCYEA_NF 13:1 - 13:
       ,ACY_NF 14:1 - 14:
       ,SCOSTRMTH_NF 15:1 - 15:
       ,SCOENDMTH_NF 16:1 - 16:
       ,CLM_NF 17:1 - 17:
       ,CUR_CF 18:1 - 18:
       ,AMT_M 19:1 - 19:
       ,CED_NF 20:1 - 20:
       ,BRK_NF 21:1 - 21:
       ,PAY_NF 22:1 - 22:
       ,KEY_NF 23:1 - 23:
       ,RETCTR_NF 24:1 - 24:
       ,RETEND_NT 25:1 - 25:
       ,RETSEC_NF 26:1 - 26:
       ,RTY_NF 27:1 - 27:
       ,RETUW_NT 28:1 - 28:
       ,RETOCCYEA_NF 29:1 - 29:
       ,RETACY_NF 30:1 - 30:
       ,RETSCOSTRMTH_NF 31:1 - 31:
       ,RETSCOENDMTH_NF 32:1 - 32:
       ,RCL_NF 33:1 - 33:
       ,RETCUR_CF 34:1 - 34:
       ,RETAMT_M 35:1 - 35:
       ,PLC_NT 36:1 - 36:
       ,RTO_NF 37:1 - 37:
       ,INT_NF 38:1 - 38:
       ,RETPAY_NF 39:1 - 39:
       ,RETKEY_CF 40:1 - 40:
       ,RETINTAMT_M 41:1 - 41:
       ,FILLER_30_COL 42:1 - 71:
/DERIVEDFIELD SEPA "~"
/COPY
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF
  ,ESB_CF
  ,BALSHEY_NF
  ,BALSHRMTH_NF
  ,BALSHRDAY_NF
  ,TRNCOD_CF
  ,DBLTRNCOD_CF
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,SEPA
  ,RETCTR_NF
  ,RETEND_NT
  ,RETSEC_NF
  ,RTY_NF
  ,RETUW_NT
  ,RETOCCYEA_NF
  ,RETACY_NF
  ,RETSCOSTRMTH_NF
  ,RETSCOENDMTH_NF
  ,RCL_NF
  ,RETCUR_CF
  ,RETAMT_M
  ,PLC_NT
  ,RTO_NF
  ,INT_NF
  ,RETPAY_NF
  ,RETKEY_CF
  ,RETINTAMT_M
  ,FILLER_30_COL
exit
EOF
SORT

NSTEP=${NJOB}_115
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_105_${IB}_SORT_GTART2_O.dat

NSTEP=${NJOB}_120
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_100_${IB}_ESTC2304_GTRRT2_O3.dat
SORT_I2=${DFILT}/${NJOB}_100_${IB}_ESTC2304_GTRRT2MAJ_O4.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRRT2_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
 TRNCOD       6:1 - 6:
,KEY_RETCTR  24:1 - 34:
,RETAMT_M    35:1 - 35:EN 15/3
,PLC_NT      36:1 - 36:
,RETINTAMT_M 41:1 - 41:EN 15/3
,TRN_NT      56:1 - 56:
,RETROAUTO_B 58:1 - 58:
/KEYS TRNCOD,KEY_RETCTR,PLC_NT,TRN_NT,RETROAUTO_B
/SUMMARIZE TOTAL RETAMT_M,TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_125
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_100_${IB}_ESTC2304_GTRRT2_O3.dat
RMFIL ${DFILT}/${NJOB}_100_${IB}_ESTC2304_GTRRT2MAJ_O4.dat


#############
# Entries 3 #
#############


NSTEP=${NJOB}_140
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_GTAT3_O4.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAT3_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
 TRNCOD_CF 6:1 - 6:
,CTR_NF 8:1 - 8:
,END_NT 9:1 - 9: 
,SEC_NF 10:1 - 10: 
,UWY_NF 11:1 - 11: 
,UW_NT 12:1 - 12: 
,OCCYEA_NF 13:1 - 13: 
,ACY_NF 14:1 - 14: 
,SCOSTRMTH_NF 15:1 - 15: 
,SCOENDMTH_NF 16:1 - 16: 
,CUR_CF 18:1 - 18:
,RETCTR_NF 24:1 - 24:
,RETEND_NT 25:1 - 25: 
,RETSEC_NF 26:1 - 26: 
,RTY_NF 27:1 - 27: 
,RETUW_NT 28:1 - 28:
,RETOCCYEA_NF 29:1 - 29: 
,RETACY_NF 30:1 - 30: 
,RETSCOSTRMTH_NF 31:1 - 31: 
,RETSCOENDMTH_NF 32:1 - 32:
,RCL_NF          33:1 - 33:
,TRN_NT 56:1 - 56:
,RETROAUTO_B 58:1 - 58:
/KEYS
 RETCTR_NF
,RETEND_NT
,RETSEC_NF
,RTY_NF
,RETUW_NT
,TRNCOD_CF
,CUR_CF
,RETOCCYEA_NF
,RCL_NF
,RETACY_NF
,RETSCOSTRMTH_NF
,RETSCOENDMTH_NF
,CTR_NF
,END_NT
,SEC_NF
,UWY_NF
,UW_NT 
,OCCYEA_NF
,ACY_NF
,SCOSTRMTH_NF
,SCOENDMTH_NF
,TRN_NT
,RETROAUTO_B
exit
EOF
SORT

NSTEP=${NJOB}_145
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT3_O4.dat

NSTEP=${NJOB}_150
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 1
BALSHEY_NF ${BALSHEY_NF}
GTE_B 0
PRS_CF 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_140_${IB}_SORT_GTAT3_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART3_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART3MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT3_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT3MAJ_O4.dat
EXECPRG

#-----------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_140_${IB}_SORT_GTAT3_O.dat     > ${DFILT}/${NJOB}_140_SORT_GTAT3_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTART3_O1.dat    > ${DFILT}/${NSTEP}_${PRG}_GTART3_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTART3MAJ_O2.dat > ${DFILT}/${NSTEP}_${PRG}_GTART3MAJ_O2.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT3_O3.dat    > ${DFILT}/${NSTEP}_${PRG}_GTRRT3_O3.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT3MAJ_O4.dat > ${DFILT}/${NSTEP}_${PRG}_GTRRT3MAJ_O4.dat.gz 
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_155
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_140_${IB}_SORT_GTAT3_O.dat

NSTEP=${NJOB}_160
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_150_${IB}_ESTC2304_GTART3_O1.dat
SORT_I2=${DFILT}/${NJOB}_150_${IB}_ESTC2304_GTART3MAJ_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART3_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
  SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
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
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
  RETINTAMT_M 41:1 - 41: EN 15/3,
  TRN_NT 56:1 - 56:,
  RETROAUTO_B 58:1 - 58:
/KEYS
  SSD_CF,
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
  PLC_NT,
  TRN_NT,
  RETROAUTO_B
/SUMMARIZE
  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_165
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_150_${IB}_ESTC2304_GTART3_O1.dat
RMFIL ${DFILT}/${NJOB}_150_${IB}_ESTC2304_GTART3MAJ_O2.dat

NSTEP=${NJOB}_170
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_150_${IB}_ESTC2304_GTRRT3_O3.dat
SORT_I2=${DFILT}/${NJOB}_150_${IB}_ESTC2304_GTRRT3MAJ_O4.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRRT3_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
 TRNCOD       6:1 - 6:
,KEY_RETCTR  24:1 - 34:
,RETAMT_M    35:1 - 35:EN 15/3
,PLC_NT      36:1 - 36:
,RETINTAMT_M 41:1 - 41:EN 15/3
,TRN_NT      56:1 - 56:
,RETROAUTO_B 58:1 - 58:
/KEYS TRNCOD,KEY_RETCTR,PLC_NT,TRN_NT,RETROAUTO_B
/SUMMARIZE TOTAL RETAMT_M,TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_175
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_150_${IB}_ESTC2304_GTRRT3_O3.dat
RMFIL ${DFILT}/${NJOB}_150_${IB}_ESTC2304_GTRRT3MAJ_O4.dat


#############
# Entries 4 #
#############


NSTEP=${NJOB}_190
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_GTRRT4_O5.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART4_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:, ESB_CF 2:1 - 2:, BALSHEY_NF 3:1 - 3:, BALSHRMTH_NF 4:1 - 4:, BALSHRDAY_NF 5:1 - 5:, TRNCOD_CF 6:1 - 6:, DBLTRNCOD_CF 7:1 - 7:, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, OCCYEA_NF 13:1 - 13:, ACY_NF 14:1 - 14:, SCOSTRMTH_NF 15:1 - 15:, SCOENDMTH_NF 16:1 - 16:, CLM_NF 17:1 - 17:,	CUR_CF 18:1 - 18:, AMT_M 19:1 - 19:, CED_NF 20:1 - 20:, BRK_NF 21:1 - 21:, PAY_NF 22:1 - 22:, KEY_NF 23:1 - 23:, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETOCCYEA_NF 29:1 - 29:, RETACY_NF 30:1 - 30:, RETSCOSTRMTH_NF 31:1 - 31:, RETSCOENDMTH_NF 32:1 - 32:, RCL_NF 33:1 - 33:, RETCUR_CF 34:1 - 34:, RETAMT_M 35:1 - 35:, PLC_NT 36:1 - 36:, RTO_NF 37:1 - 37:, INT_NF 38:1 - 38:, RETPAY_NF 39:1 - 39:, RETKEY_CF 40:1 - 40:, RETINTAMT_M 41:1 - 41:, FILLER_30_COL 42:1 - 71:
/DERIVEDFIELD SEPA "~"
/COPY
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, PLC_NT, SEPA, SEPA, SEPA, SEPA, RETINTAMT_M,FILLER_30_COL
exit
EOF
SORT


#############
# Entries 5 #
#############


NSTEP=${NJOB}_200
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_GTAT5_O6.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART5_O.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTRRT5_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:, ESB_CF 2:1 - 2:, BALSHEY_NF 3:1 - 3:, BALSHRMTH_NF 4:1 - 4:, BALSHRDAY_NF 5:1 - 5:, TRNCOD_CF 6:1 - 6:, DBLTRNCOD_CF 7:1 - 7:, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, OCCYEA_NF 13:1 - 13:, ACY_NF 14:1 - 14:, SCOSTRMTH_NF 15:1 - 15:, SCOENDMTH_NF 16:1 - 16:, CLM_NF 17:1 - 17:,	CUR_CF 18:1 - 18:, AMT_M 19:1 - 19:, CED_NF 20:1 - 20:, BRK_NF 21:1 - 21:, PAY_NF 22:1 - 22:, KEY_NF 23:1 - 23:, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETOCCYEA_NF 29:1 - 29:, RETACY_NF 30:1 - 30:, RETSCOSTRMTH_NF 31:1 - 31:, RETSCOENDMTH_NF 32:1 - 32:, RCL_NF 33:1 - 33:, RETCUR_CF 34:1 - 34:, RETAMT_M 35:1 - 35:, PLC_NT 36:1 - 36:, RTO_NF 37:1 - 37:, INT_NF 38:1 - 38:, RETPAY_NF 39:1 - 39:, RETKEY_CF 40:1 - 40:, RETINTAMT_M 41:1 - 41:, FILLER_30_COL 42:1 - 71:
/DERIVEDFIELD SEPA "~"
/COPY
/OUTFILE ${SORT_O}
   /REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, PLC_NT, SEPA, SEPA, SEPA, SEPA, RETINTAMT_M,FILLER_30_COL
/OUTFILE ${SORT_O2}
   /REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, SEPA, SEPA, SEPA, SEPA, SEPA, SEPA, SEPA, SEPA, SEPA, SEPA, SEPA, SEPA, SEPA, SEPA, SEPA, SEPA, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_M,FILLER_30_COL
exit
EOF
SORT

# ajout step pour garder les enregistrements des filiales non presentes dans l'inventaire
#  JR 01/06/2004
NSTEP=${NJOB}_203
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
#SORT_I=${EST_DLRNPGTAR}
SORT_I=${DFILT}/${NJOB}_011_${IB}_WRK_DLRNPGTAR.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLRNPGTAR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/OMIT INVENTAIRE
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_205
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_011_${IB}_WRK_DLRNPGTAR.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT5_O6.dat

# ajout SORT_I6 pour reintegrer les enregistrements des filiales non presentes dans l'inventaire
NSTEP=${NJOB}_210
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_60_${IB}_SORT_GTART1_O.dat
SORT_I2=${DFILT}/${NJOB}_110_${IB}_SORT_GTART2_O.dat
SORT_I3=${DFILT}/${NJOB}_160_${IB}_SORT_GTART3_O.dat
SORT_I4=${DFILT}/${NJOB}_190_${IB}_SORT_GTART4_O.dat
SORT_I5=${DFILT}/${NJOB}_200_${IB}_SORT_GTART5_O.dat
SORT_I6=${DFILT}/${NJOB}_203_${IB}_SORT_DLRNPGTAR_O.dat
SORT_O=${EST_DLRNPGTAR}
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_215
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_GTART1_O.dat
RMFIL ${DFILT}/${NJOB}_110_${IB}_SORT_GTART2_O.dat
RMFIL ${DFILT}/${NJOB}_160_${IB}_SORT_GTART3_O.dat
RMFIL ${DFILT}/${NJOB}_190_${IB}_SORT_GTART4_O.dat
RMFIL ${DFILT}/${NJOB}_200_${IB}_SORT_GTART5_O.dat
RMFIL ${DFILT}/${NJOB}_203_${IB}_SORT_DLRNPGTAR_O.dat

# ajout step pour garder les enregistrements des filiales non presentes dans l'inventaire
#  JR 01/06/2004
NSTEP=${NJOB}_218
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
#SORT_I=${EST_DLRNPGTR}
SORT_I=${DFILT}/${NJOB}_012_${IB}_WRK_DLRNPGTR.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLRNPGTR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/OMIT INVENTAIRE
/COPY
exit
EOF
SORT

# ajout SORT_I6 pour reintegrer les enregistrements des filiales non presentes dans l'inventaire
NSTEP=${NJOB}_220
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_70_${IB}_SORT_GTRRT1_O.dat
SORT_I2=${DFILT}/${NJOB}_120_${IB}_SORT_GTRRT2_O.dat
SORT_I3=${DFILT}/${NJOB}_170_${IB}_SORT_GTRRT3_O.dat
SORT_I4=${DFILT}/${NJOB}_10_${IB}_SORT_GTRRT4_O5.dat
SORT_I5=${DFILT}/${NJOB}_200_${IB}_SORT_GTRRT5_O.dat
SORT_I6=${DFILT}/${NJOB}_218_${IB}_SORT_DLRNPGTR_O.dat
SORT_O=${EST_DLRNPGTR}
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_225
# Rm of temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND

