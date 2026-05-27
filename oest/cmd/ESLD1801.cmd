#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS -
#                                 Mise a jour et formatage des ecritures de service Post Omega Local
# nom du script SHELL           : ESLD1801.cmd
# revision                      :
# date de creation              : 04/072017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description
#   Mise a jour des informations Retrocession et formatage au fichier GT des ecritures de service Local
#
# Input files
#       ESL_FCES
#       ESL_FCURCVSN
#       ESL_FCURCVSNI
#       ESL_FCURQUOT
#       ESL_FDETTRS
#       ESL_FPLATXCUM
#       ESL_FPLC
#       ESL_FTRANSCODE
#       ESL_FTRSLNK
#       ESL_IADVPERICASE
#       ESL_OIRDVPERICASE
#
# output files
#       ESL_DLSGTAALO
#       ESL_DLSGTARLO
#       ESL_DLSGTRLO
#
# launched by ESLD1800.cmd
#
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 07/12/2017 R. Cassis :spira:66334 Les fichiers perimetre ES Local sont nommés ESL_ sont maintenant générés dans le ESID7000
#[002] 29/01/2021 B. Lagha  :spira:91085 Remplacer le programme ESTM2569 par ESTM2069.
#[003] 04/10/2023 MZM       :spira:110474 PROD6 AEs entries not found in SAP : Force RETUW_NT to 1 when it's not null
#[004] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 
#[005] 10/04/2024 JYP     SPIRA 110932 parameter A-AE for RET OVERRIDE exclude some TC when RAICOM_B=0  
#[006] 15/05/2024 JYP     SPIRA 110932 parameter A-AE for RET OVERRIDE exclude some TC when RAICOM_B=0 
#[007] 23/09/2024 MZM   SPIRA :112214 Force RETUW_NT to 1 when it's different to 1 (Complement :110474 )  
#[098] 10/03/2025 MZM   SPIRA :112836 Q25 PRD - Program wrongly adds Retro order 1 when AE booked on Assumed only : "Force RETUW_NT to 1 when ( RETUW_NT != "1" )	AND  (RETCTR_NF != "")"  
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

#Get input parameters
INVCONSO_D=$1
CONSOYEA=$2

# Job Initialisation
JOBINIT

ORICOD=LOCAL

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> INVCONSO_D............: ${INVCONSO_D}"
ECHO_LOG "#===> CONSOYEA..............: ${CONSOYEA}"
ECHO_LOG "#===> ORICOD................: ${ORICOD}"
ECHO_LOG "#===> ESL_DLSGTAALO.........: ${ESL_DLSGTAALO}"
ECHO_LOG "#===> ESL_DLSGTARLO.........: ${ESL_DLSGTARLO}"
ECHO_LOG "#===> ESL_DLSGTRLO..........: ${ESL_DLSGTRLO}"
ECHO_LOG "#===> ESL_EPOSOCLO..........: ${ESL_EPOSOCLO}"
ECHO_LOG "#===> ESL_FCES..............: ${ESL_FCES}"
ECHO_LOG "#===> ESL_FCURCVSN..........: ${ESL_FCURCVSN}"
ECHO_LOG "#===> ESL_FCURCVSNI.........: ${ESL_FCURCVSNI}"
ECHO_LOG "#===> ESL_FCURQUOT..........: ${ESL_FCURQUOT}"
ECHO_LOG "#===> ESL_FDETTRS...........: ${ESL_FDETTRS}"
ECHO_LOG "#===> ESL_FPLATXCUM.........: ${ESL_FPLATXCUM}"
ECHO_LOG "#===> ESL_FPLC..............: ${ESL_FPLC}"
ECHO_LOG "#===> ESL_FTRANSCODE........: ${ESL_FTRANSCODE}"
ECHO_LOG "#===> ESL_FTRSLNK...........: ${ESL_FTRSLNK}"
ECHO_LOG "#===> ESL_IADVPERICASE......: ${ESL_IADVPERICASE}"
ECHO_LOG "#===> ESL_OIRDVPERICASE.....: ${ESL_OIRDVPERICASE}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_02
#Last version of ESID120 files deletion
#-----------------------------------------------------------------
RMFIL "${ESL_DLSGTAALO}"
RMFIL "${ESL_DLSGTARLO}"
RMFIL "${ESL_DLSGTRLO}"

NSTEP=${NJOB}_05
# begin sort
#[003] [007] [008]  Force RETUW_NT to 1 when it's empty ""
#-----------------------------------------------------------------------------
LIBEL="Sort of EPOLOC file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${ESL_EPOSOCLO}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_EPOLOC_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF               1:1 -  1:,
        ESB_CF               2:1 -  2:,
        BALSHEY_NF           3:1 -  3:,
        BALSHRMTH_NF         4:1 -  4:,
        BALSHRDAY_NF         5:1 -  5:,
        TRNCOD_CF            6:1 -  6:,
        TRNCOD_SOUS_PREFIX   6:2 -  6:2,
        DBLTRNCOD_CF         7:1 -  7:,
        CTR_NF               8:1 -  8:,
        END_NT               9:1 -  9:,
        SEC_NF              10:1 - 10:,
        UWY_NF              11:1 - 11:,
        UW_NT               12:1 - 12:,
        OCCYEA_NF           13:1 - 13:,
        ACY_NF              14:1 - 14:,
        SCOSTRMTH_NF        15:1 - 15:,
        SCOENDMTH_NF        16:1 - 16:,
        CLM_NF              17:1 - 17:,
        CUR_CF              18:1 - 18:,
        AMT_M               19:1 - 19:EN 15/3,
        CED_NF              20:1 - 20:,
        BRK_NF              21:1 - 21:,
        GEMPRMPAY_NF        22:1 - 22:,
        GANPAYORD_NT        23:1 - 23:,
        RETCTR_NF           24:1 - 24:,
        RETEND_NT           25:1 - 25:,
        RETSEC_NF           26:1 - 26:,
        RTY_NF              27:1 - 27:,
        RETUW_NT            28:1 - 28:,
        RETOCCYEA_NF        29:1 - 29:,
        RETACY_NF           30:1 - 30:,
        RETSCOSTRMTH_NF     31:1 - 31:,
        RETSCOENDMTH_NF     32:1 - 32:,
        RCL_NF              33:1 - 33:,
        RETCUR_CF           34:1 - 34:,
        RETAMT_M            35:1 - 35:EN 15/3,
        PLC_NT              36:1 - 36:,
        RTO_NF              37:1 - 37:,
        INT_NF              38:1 - 38:,
        RETPAY_NF           39:1 - 39:,
        RETKEY_CF           40:1 - 40:,
        RETAUTGEN_B         41:1 - 41:,
        ACCTYP_NF           42:1 - 42:EN,
        TRN_NT              43:1 - 43:,
        ORICOD_LS           44:1 - 44:,
        RETROAUTO_B         45:1 - 45:,
        SPEENTNAT_CT        46:1 - 46:,
        EVT_NF              47:1 - 47:,
        REVT_NF             48:1 - 48:
/CONDITION SERV (TRNCOD_SOUS_PREFIX >= "4" and "SCORIT" NC TRNCOD_SOUS_PREFIX) or
                ("EGHJKL" CT TRNCOD_SOUS_PREFIX) or
                ("VWXNYU" CT TRNCOD_SOUS_PREFIX) or
                ACCTYP_NF = 0   or
                ACCTYP_NF = 1   or
                ACCTYP_NF = 98  or
                ACCTYP_NF = 99
/CONDITION EST_INCORRECT ( RETUW_NT != "1" )	AND  (RETCTR_NF != "")	                
/OUTFILE ${SORT_O}
/INCLUDE SERV
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD ZERO "0.000" CHAR 5
/DERIVEDFIELD RETUW_NT_NEW if  EST_INCORRECT then "1" else RETUW_NT
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
          RETUW_NT_NEW,
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

NSTEP=${NJOB}_10
# begin sort
#-----------------------------------------------------------------------------
LIBEL="Split of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_05_${IB}_SORT_EPOLOC_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTAT1_O2.dat
SORT_O3=${DFILT}/${NSTEP}_${IB}_SORT_GTAT2_O3.dat
SORT_O4=${DFILT}/${NSTEP}_${IB}_SORT_GTAT3_O4.dat
SORT_O5=${DFILT}/${NSTEP}_${IB}_SORT_GTRRT4_O5.dat
SORT_O6=${DFILT}/${NSTEP}_${IB}_SORT_GTAT5_O6.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        BALSHEY_NF       3:1 -  3:,
        BALSHRMTH_NF     4:1 -  4:,
        BALSHRDAY_NF     5:1 -  5:,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        CED_NF          20:1 - 20:,
        BRK_NF          21:1 - 21:,
        PAY_NF          22:1 - 22:,
        KEY_NF          23:1 - 23:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:EN 15/3,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        INT_NF          38:1 - 38:,
        RETPAY_NF       39:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:EN 15/3,
        RETAUTGEN_B     42:1 - 42:,
        ACCTYP_NF       43:1 - 43:,
        TRN_NT          44:1 - 44:,
        ORICOD_LS       45:1 - 45:,
        RETROAUTO_B     46:1 - 46:,
        SPEENTNAT_CT    47:1 - 47:,
        EVT_NF          48:1 - 48:,
        REVT_NF         49:1 - 49:
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/DERIVEDFIELD PLUS_10_CHAMPS 9"~"
/CONDITION TYP1     ACCTYP_NF EQ "1" or ACCTYP_NF EQ "99"
/CONDITION TYP2     ACCTYP_NF EQ "2"
/CONDITION TYP3     ACCTYP_NF EQ "3"
/CONDITION TYP4     ACCTYP_NF EQ "4"
/CONDITION TYP5     ACCTYP_NF EQ "5"
/CONDITION TYP1AUT1 ( ACCTYP_NF EQ "1" or ACCTYP_NF EQ "99" ) and RETAUTGEN_B EQ "1"
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
/OUTFILE ${SORT_O5}
/INCLUDE TYP4
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
/OUTFILE ${SORT_O6}
/INCLUDE TYP5
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
exit
EOF
SORT

#-----------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_05_${IB}_SORT_EPOLOC_O.dat  > ${DFILT}/${NJOB}_05_SORT_EPOLOC_O.dat.gz
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAA.dat   > ${DFILT}/${NJOB}_10_SORT_DLSGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT1_O2.dat  > ${DFILT}/${NJOB}_10_SORT_GTAT1_O2.dat.gz
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT2_O3.dat  > ${DFILT}/${NJOB}_10_SORT_GTAT2_O3.dat.gz
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT3_O4.dat  > ${DFILT}/${NJOB}_10_SORT_GTAT3_O4.dat.gz
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_GTRRT4_O5.dat > ${DFILT}/${NJOB}_10_SORT_GTRRT4_O5.dat.gz
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT5_O6.dat  > ${DFILT}/${NJOB}_10_SORT_GTAT5_O6.dat.gz
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_EPOLOC_O.dat

#############
# Entries 1 #
#############

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_GTAT1_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAT1_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CUR_CF          18:1 - 18:
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

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT1_O2.dat

# Get last Balance Sheet date
BLCSHTYEALOC_NF=`cut -d~ -f3 ${DFILT}/${NJOB}_20_${IB}_SORT_GTAT1_O.dat | head -1`
BLCSHTMTHLOC_NF=`cut -d~ -f4 ${DFILT}/${NJOB}_20_${IB}_SORT_GTAT1_O.dat | head -1`
BLCSHTDAYLOC_NF=`cut -d~ -f5 ${DFILT}/${NJOB}_20_${IB}_SORT_GTAT1_O.dat | head -1`

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Application of cession operator"
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
INVCONSO_D ${INVCONSO_D}
GTE_B 0
exit
EOF
set -x
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_GTAT1_O.dat
export ${PRG}_I2=${ESL_FCES}
export ${PRG}_I3=${ESL_FDETTRS}
export ${PRG}_I4=${ESL_FTRANSCODE}    #[013]
export ${PRG}_I5=${ESL_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
set +x
EXECPRG

NSTEP=${NJOB}_31
#----------------------------------------------------------------------------
LIBEL="Replace Balance sheet date with the original date"
AWK_I=${DFILT}/${NJOB}_30_${IB}_ESTC2303_GTAR100_O.dat
AWK_PARAM=" year=${BLCSHTYEALOC_NF}  month=${BLCSHTMTHLOC_NF} day=${BLCSHTDAYLOC_NF}"
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_GTAR100_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN {FS="\~"; OFS="\~"}
{
   \$3 = year;
   \$4 = month;
   \$5 = day;
   print \$0;
}
exit
EOF
AWK

NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_GTAT1_O.dat

NSTEP=${NJOB}_36
#-----------------------------------------------------------------------------
LIBEL="Reformat ${ESL_EPOSOCLO} for maj TRN_NT RETRO AUTO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_EPOSOCLO} 1000 1"
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
#-----------------------------------------------------------------------------
LIBEL="SyncSort Maj TRN_NT RETRO AUTO de ESTC2303"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_31_${IB}_AWK_GTAR100_O.dat
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

/INFILE ${DFILT}/${NJOB}_36_${IB}_SORT_FACCSUP_RETROAUTO_O.dat 1000 1 "~"
/JOINKEYS SORTED FACCSUP_RETCTR_NF,FACCSUP_RETSEC_NF,FACCSUP_RTY_NF,FACCSUP_ACCTRN_NT

/JOIN UNPAIRED LEFTSIDE

/OUTFILE ${SORT_O} "~"
/REFORMAT
 LEFTSIDE:  GT_DEBUT
,RIGHTSIDE: FACCSUP_TRN_NT
,LEFTSIDE:  GT_FIN  

exit
EOF
SORT

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_37_${IB}_MAJ_RETRO_ES_GTAR100_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        TRN_NT          56:1 - 56:,
        RETROAUTO_B     58:1 - 58:
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
      SCOENDMTH_NF,
      TRN_NT,
      RETROAUTO_B
exit
EOF
SORT

NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTC2303_GTAR100_O.dat

NSTEP=${NJOB}_50
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
RETROCOM_FLG A
exit
EOF
set -x
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_GTAR100_O.dat
export ${PRG}_I2=${ESL_FPLC}
export ${PRG}_I3=${ESL_FCURCVSNI}
export ${PRG}_I4=${ESL_FCURQUOT}
export ${PRG}_I5=${ESL_FCURCVSN}
export ${PRG}_I6=${ESL_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART1MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT1MAJ_O4.dat
set +x
EXECPRG

#-----------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_30_${IB}_ESTC2303_GTAR100_O.dat    > ${DFILT}/${NJOB}_30_ESTC2303_GTAR100_O.dat.gz
gzip -c ${DFILT}/${NJOB}_31_${IB}_AWK_GTAR100_O.dat         > ${DFILT}/${NJOB}_30_AWK_GTAR100_O.dat.gz
gzip -c ${DFILT}/${NJOB}_40_${IB}_SORT_GTAR100_O.dat        > ${DFILT}/${NJOB}_40_SORT_GTAR100_O.dat.gz
gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1_O1.dat    > ${DFILT}/${NJOB}_50_ESTC2304_GTART1_O1.dat.gz
gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1MAJ_O2.dat > ${DFILT}/${NJOB}_50_ESTC2304_GTART1MAJ_O2.dat.gz
gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1_O3.dat    > ${DFILT}/${NJOB}_50_ESTC2304_GTRRT1_O3.dat.gz
gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1MAJ_O4.dat > ${DFILT}/${NJOB}_50_ESTC2304_GTRRT1MAJ_O4.dat.gz
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_55
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_GTAR100_O.dat

NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1_O1.dat
SORT_I2=${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1MAJ_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART1_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
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
/KEYS   SSD_CF,
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
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL "${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1_O1.dat ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1MAJ_O2.dat"

NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1_O3.dat
SORT_I2=${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1MAJ_O4.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRRT1_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD 6:1 - 6:,
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
        PLC_NT 36:1 - 36:,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF,
      TRNCOD,
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
/SUMMARIZE TOTAL RETAMT_M,
           TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_75
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL "${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1_O3.dat ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1MAJ_O4.dat"

#############
# Entries 2 #
#############

NSTEP=${NJOB}_80
# begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_GTAT2_O3.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAT2_O.dat
INPUT_TEXT $SORT_CMD <<EOF
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
        RCL_NF 33:1 - 33:,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
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
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      TRN_NT,
      RETROAUTO_B
exit
EOF
SORT

NSTEP=${NJOB}_85
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT2_O3.dat

NSTEP=${NJOB}_90
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
set -x
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_GTAT2_O.dat
export ${PRG}_I2=${ESL_FPLC}
export ${PRG}_I3=${ESL_FCURCVSNI}
export ${PRG}_I4=${ESL_FCURQUOT}
export ${PRG}_I5=${ESL_FCURCVSN}
export ${PRG}_I6=${ESL_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2MAJ_O4.dat
set +x
EXECPRG

#-----------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_80_${IB}_SORT_GTAT2_O.dat          > ${DFILT}/${NJOB}_80_SORT_GTAT2_O.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2_O1.dat    > ${DFILT}/${NJOB}_90_ESTC2304_GTART2_O1.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2MAJ_O2.dat > ${DFILT}/${NJOB}_90_ESTC2304_GTART2MAJ_O2.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2_O3.dat    > ${DFILT}/${NJOB}_90_ESTC2304_GTRRT2_O3.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2MAJ_O4.dat > ${DFILT}/${NJOB}_90_ESTC2304_GTRRT2MAJ_O4.dat.gz
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_93
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_80_${IB}_SORT_GTAT2_O.dat

NSTEP=${NJOB}_95
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2_O1.dat
SORT_I2=${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2MAJ_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART2_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
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
/KEYS   SSD_CF,
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

NSTEP=${NJOB}_96
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL " ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2_O1.dat ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2MAJ_O2.dat"

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_95_${IB}_SORT_GTART2_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART2_O.dat
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
        FILLER_15_COL 42:1 - 56:,
        ORICOD_LS     57:1 - 57:,
        FILLER_14_COL 58:1 - 71:
/DERIVEDFIELD SEPA "~"
/COPY
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
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
          FILLER_15_COL,
          ORICOD_LS,
          FILLER_14_COL
exit
EOF
SORT

NSTEP=${NJOB}_105
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_95_${IB}_SORT_GTART2_O.dat

NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2_O3.dat
SORT_I2=${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2MAJ_O4.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRRT2_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD 6:1 - 6:,
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
        PLC_NT 36:1 - 36:,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF,
      TRNCOD,
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
/SUMMARIZE TOTAL RETAMT_M,
           TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_111
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL "${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2_O3.dat ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2MAJ_O4.dat"

#############
# Entries 3 #
#############

NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_GTAT3_O4.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAT3_O.dat
INPUT_TEXT $SORT_CMD <<EOF
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
        RCL_NF 33:1 - 33:,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
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
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      TRN_NT,
      RETROAUTO_B
exit
EOF
SORT

NSTEP=${NJOB}_125
#------------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT3_O4.dat

NSTEP=${NJOB}_130
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
set -x
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_120_${IB}_SORT_GTAT3_O.dat
export ${PRG}_I2=${ESL_FPLC}
export ${PRG}_I3=${ESL_FCURCVSNI}
export ${PRG}_I4=${ESL_FCURQUOT}
export ${PRG}_I5=${ESL_FCURCVSN}
export ${PRG}_I6=${ESL_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART3_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART3MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT3_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT3MAJ_O4.dat
set +x
EXECPRG

#-----------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_120_${IB}_SORT_GTAT3_O.dat           > ${DFILT}/${NJOB}_120_SORT_GTAT3_O.dat.gz          
gzip -c ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTART3_O1.dat     > ${DFILT}/${NJOB}_130_ESTC2304_GTART3_O1.dat.gz    
gzip -c ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTART3MAJ_O2.dat  > ${DFILT}/${NJOB}_130_ESTC2304_GTART3MAJ_O2.dat.gz 
gzip -c ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3_O3.dat     > ${DFILT}/${NJOB}_130_ESTC2304_GTRRT3_O3.dat.gz    
gzip -c ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3MAJ_O4.dat  > ${DFILT}/${NJOB}_130_ESTC2304_GTRRT3MAJ_O4.dat.gz
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_135
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_120_${IB}_SORT_GTAT3_O.dat

NSTEP=${NJOB}_140
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTART3_O1.dat
SORT_I2=${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTART3MAJ_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART3_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
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
/KEYS   SSD_CF,
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

NSTEP=${NJOB}_150
#-----------------------------------------------------------------------------
LIBEL="Merge of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3_O3.dat
SORT_I2=${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3MAJ_O4.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRRT3_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD 6:1 - 6:,
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
        PLC_NT 36:1 - 36:,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF,
      TRNCOD,
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
/SUMMARIZE TOTAL RETAMT_M,
           TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_155
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL "${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3_O3.dat ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3MAJ_O4.dat"

#############
# Entries 4 #
#############

NSTEP=${NJOB}_160
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_GTRRT4_O5.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART4_O.dat
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
        RETINTAMT_M 41:1 - 41:,
        FILLER_15_COL 42:1 - 56:,
        ORICOD_LS     57:1 - 57:,
        FILLER_14_COL 58:1 - 71:
/DERIVEDFIELD SEPA "~"
/COPY
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
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          RETINTAMT_M,
          FILLER_15_COL,
          ORICOD_LS,
          FILLER_14_COL
exit
EOF
SORT

#############
# Entries 5 #
#############

NSTEP=${NJOB}_170
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_GTAT5_O6.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTART5_O.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTRRT5_O.dat
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
        RETINTAMT_M 41:1 - 41:,
        FILLER_15_COL 42:1 - 56:,
        ORICOD_LS     57:1 - 57:,
        FILLER_14_COL 58:1 - 71:
/DERIVEDFIELD SEPA "~"
/COPY
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
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          RETINTAMT_M,
          FILLER_15_COL,
          ORICOD_LS,
          FILLER_14_COL
/OUTFILE ${SORT_O2}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
          SEPA,
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
          FILLER_15_COL,
          ORICOD_LS,
          FILLER_14_COL
exit
EOF
SORT

NSTEP=${NJOB}_175
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT5_O6.dat

NSTEP=${NJOB}_180
#-----------------------------------------------------------------------------
LIBEL="Merge of DLSGTARSO files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_60_${IB}_SORT_GTART1_O.dat
SORT_I2=${DFILT}/${NJOB}_100_${IB}_SORT_GTART2_O.dat
SORT_I3=${DFILT}/${NJOB}_140_${IB}_SORT_GTART3_O.dat
SORT_I4=${DFILT}/${NJOB}_160_${IB}_SORT_GTART4_O.dat
SORT_I5=${DFILT}/${NJOB}_170_${IB}_SORT_GTART5_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR.dat
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

#-----------------------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_60_${IB}_SORT_GTART1_O.dat  > ${DFILT}/${NJOB}_60_SORT_GTART1_O.dat.gz
gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_GTART2_O.dat > ${DFILT}/${NJOB}_100_SORT_GTART2_O.dat.gz
gzip -c ${DFILT}/${NJOB}_140_${IB}_SORT_GTART3_O.dat > ${DFILT}/${NJOB}_140_SORT_GTART3_O.dat.gz
gzip -c ${DFILT}/${NJOB}_160_${IB}_SORT_GTART4_O.dat > ${DFILT}/${NJOB}_160_SORT_GTART4_O.dat.gz
gzip -c ${DFILT}/${NJOB}_170_${IB}_SORT_GTART5_O.dat > ${DFILT}/${NJOB}_170_SORT_GTART5_O.dat.gz
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_185
#-----------------------------------------------------------------------------
LIBEL="Merge of DLSGTRSO files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_70_${IB}_SORT_GTRRT1_O.dat
SORT_I2=${DFILT}/${NJOB}_110_${IB}_SORT_GTRRT2_O.dat
SORT_I3=${DFILT}/${NJOB}_150_${IB}_SORT_GTRRT3_O.dat
SORT_I4=${DFILT}/${NJOB}_10_${IB}_SORT_GTRRT4_O5.dat
SORT_I5=${DFILT}/${NJOB}_170_${IB}_SORT_GTRRT5_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTR.dat
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_187
#-----------------------------------------------------------------------------
LIBEL="Tri de ESTC1005_PERICASE Extended with TFAMCHG_O"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_IADVPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5: EN, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:, LOB_CF 38:1 - 38:, PCPRSKTRY_CF 52:1 - 52:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_190
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_191
#----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAA.dat

NSTEP=${NJOB}_193
#----------------------------------------------------------------------------
#[003] ajout paramètre INVCONSO_D
LIBEL="  IFRS  treatment"
PRG=ESTM2069
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${INVCONSO_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_187_${IB}_SORT_IADVPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_190_${IB}_SORT_DLSGTAA.dat
export ${PRG}_I3=${ESL_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IFRS_DLSGTAA_O.dat
EXECPRG

NSTEP=${NJOB}_194
#----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_187_${IB}_SORT_IADVPERICASE_O.dat

NSTEP=${NJOB}_197
#-----------------------------------------------------------------------------
LIBEL="accumulation DLSGTAASO et IFRS SPOT16593"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_SORT_DLSGTAA.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_193_${IB}_ESTM2069_IFRS_DLSGTAA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF         1:1 - 1:,
        ESB_CF         2:1 - 2:,
        BALSHEY_NF     3:1 - 3:,
        BALSHRMTH_NF   4:1 - 4:,
        BALSHRDAY_NF   5:1 - 5:,
        TRNCOD_CF      6:1 - 6:,
        DBLTRNCOD_CF   7:1 - 7:,
        CTR_NF         8:1 - 8:,
        END_NT         9:1 - 9:,
        SEC_NF        10:1 - 10:,
        UWY_NF        11:1 - 11:,
        UW_NT         12:1 - 12:,
        OCCYEA_NF     13:1 - 13:,
        ACY_NF        14:1 - 14:,
        SCOSTRMTH_NF  15:1 - 15:,
        SCOENDMTH_NF  16:1 - 16:,
        CLM_NF        17:1 - 17:,
        CUR_CF        18:1 - 18:,
        AMT_M         19:1 - 19:EN 15/3,
        RETAMT_M      35:1 - 35:EN 15/3,
        TRN_NT        56:1 - 56:,
        RETROAUTO_B   58:1 - 58:,
        FIELDSDEB      1:1 - 18:,
        FIELDSFIN     20:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      CUR_CF,
      TRNCOD_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF,
      TRN_NT,
      RETROAUTO_B
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FIELDSDEB, AMT_MC, FIELDSFIN
exit
EOF
SORT

NSTEP=${NJOB}_198
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_197_${IB}_SORT_DLSGTAA_O.dat
export ${PRG}_I2=${ESL_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAA.dat
EXECPRG

NSTEP=${NJOB}_199
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL "${DFILT}/${NJOB}_190_${IB}_SORT_DLSGTAA.dat ${DFILT}/${NJOB}_193_${IB}_ESTM2069_IFRS_DLSGTAA.dat ${DFILT}/${NJOB}_197_${IB}_SORT_DLSGTAA_O.dat"

NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_180_${IB}_SORT_DLSGTAR.dat
export ${PRG}_I2=${ESL_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR.dat
EXECPRG

NSTEP=${NJOB}_202
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_180_${IB}_SORT_DLSGTAR.dat

NSTEP=${NJOB}_205
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_185_${IB}_SORT_DLSGTR.dat
export ${PRG}_I2=${ESL_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTR.dat
EXECPRG

NSTEP=${NJOB}_208
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_185_${IB}_SORT_DLSGTR.dat

NSTEP=${NJOB}_210
#-----------------------------------------------------------------------------
LIBEL="DLSGTARSO SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_ESTM7603_DLSGTAR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF 27:1 - 27:,
        PLC_NT 36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_215
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${ESL_FPLATXCUM}
export ${PRG}_I2=${DFILT}/${NJOB}_210_${IB}_SORT_DLSGTAR.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR.dat
EXECPRG

NSTEP=${NJOB}_220
#-----------------------------------------------------------------------------
LIBEL="sort of balance sheet year "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_215_${IB}_RETM0532_DLSGTAR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRNCOD_CF
exit
EOF
SORT

NSTEP=${NJOB}_230
#------------------------------------------------------------------------------
LIBEL="Current ACY transactions blanking for italian DLSGTAR only"
PRG=ESTM2561
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${INVCONSO_D}
BALSHTYEA_NF ${CONSOYEA}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_220_${IB}_SORT_DLSGTAR_O.dat
export ${PRG}_I2=${ESL_OIRDVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IT_DLSGTAR.dat
EXECPRG

NSTEP=${NJOB}_235
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition for italian DLSGTAR"
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_230_${IB}_ESTM2561_IT_DLSGTAR.dat
export ${PRG}_I2=${ESL_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IT_DLSGTAR.dat
EXECPRG

NSTEP=${NJOB}_240
#-----------------------------------------------------------------------------
LIBEL="Creation ${ESL_DLSGTARLO} SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_215_${IB}_RETM0532_DLSGTAR.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_235_${IB}_ESTM7603_IT_DLSGTAR.dat 1000 1"
SORT_O="${ESL_DLSGTARLO} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS DEBUT      1:1 - 56:,
        FIN       58:1 - 71:,
        TRNCOD_2   6:2 -  6:2,
        RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF    27:1 - 27:,
        PLC_NT    36:1 - 36:EN,
        COLSDEB    1:1 - 56:,
        COLSFIN   58:1 - 71:
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
/DERIVEDFIELD NEW_ORICOL_LS "${ORICOD}~" 
/OUTFILE ${SORT_O}     
/REFORMAT COLSDEB, NEW_ORICOL_LS, COLSFIN      
exit
EOF
SORT

NSTEP=${NJOB}_245
#------------------------------------------------------------------------------
LIBEL="italian DLSGTR blanking accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_235_${IB}_ESTM7603_IT_DLSGTAR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IT_DLSGTR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        TRNCOD_CF 6:1 - 6:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT          56:1 - 56:,
        RETROAUTO_B     58:1 - 58:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RETACY_NF,
      RETCUR_CF,
      TRNCOD_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      TRN_NT,
      RETROAUTO_B
/SUMMARIZE TOTAL RETAMT_M,
           TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_250
#-----------------------------------------------------------------------------
LIBEL="DLSGTRSO SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_205_${IB}_ESTM7603_DLSGTR.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_245_${IB}_SORT_IT_DLSGTR.dat 1000 1"
SORT_O="${ESL_DLSGTRLO} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF    27:1 - 27:,
        PLC_NT    36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_260
#------------------------------------------------------------------------------
LIBEL="Current ACY transactions blanking for italian ${ESL_DLSGTAALO} only"
PRG=ESTM2061
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${INVCONSO_D}
BALSHTYEA_NF ${CONSOYEA}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_198_${IB}_ESTM7603_DLSGTAA.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IT_DLSGTAA.dat
EXECPRG

NSTEP=${NJOB}_265
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition for italian DLSGTAA"
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_260_${IB}_ESTM2061_IT_DLSGTAA.dat
export ${PRG}_I2=${ESL_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IT_DLSGTAA.dat
EXECPRG

NSTEP=${NJOB}_270
#-----------------------------------------------------------------------------
LIBEL="Création ${ESL_DLSGTAALO} SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_265_${IB}_ESTM7603_IT_DLSGTAA.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_198_${IB}_ESTM7603_DLSGTAA.dat 1000 1"
SORT_O="${ESL_DLSGTAALO} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER1         1:1 - 56:,
        FILLER_14_COLS 58:1 - 71:,
        RETCTR_NF      24:1 - 24:,
        RETSEC_NF      26:1 - 26: EN,
        RTY_NF         27:1 - 27:,
        PLC_NT         36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
/DERIVEDFIELD NEW_ORICOL_LS "${ORICOD}~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,NEW_ORICOL_LS,FILLER_14_COLS
exit
EOF
SORT

#--------------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_205_${IB}_ESTM7603_DLSGTR.dat     > ${DFILT}/${NJOB}_205_ESTM7603_DLSGTR.dat.gz
gzip -c ${DFILT}/${NJOB}_235_${IB}_ESTM7603_IT_DLSGTAR.dat > ${DFILT}/${NJOB}_235_ESTM7603_IT_DLSGTAR.dat.gz 
gzip -c ${DFILT}/${NJOB}_245_${IB}_SORT_IT_DLSGTR.dat      > ${DFILT}/${NJOB}_245_SORT_IT_DLSGTR.dat.gz      
gzip -c ${DFILT}/${NJOB}_265_${IB}_ESTM7603_IT_DLSGTAA.dat > ${DFILT}/${NJOB}_265_ESTM7603_IT_DLSGTAA.dat.gz  
#--------------------------------------------------------------

NSTEP=${NJOB}_300
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

