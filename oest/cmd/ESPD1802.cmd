#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS -
#                                 Comptabilisation des ecritures de services
#                                 Post omega (CONSO) pour alimentation AIB
# nom du script SHELL            : ESPD1802.cmd
# revision                       : $Revision: 1.2 $
# date de creation               : 16/06/2005
# auteur                         : J. Ribot
# references des specifications  : SPOT 5085
#-----------------------------------------------------------------------------
# description
#   Special entries booking
#
# Input files
#       EPO_EPOCONS       DFILI
#       EPO_FCES          DFILP
#       EPO_FCURCVSN      DFILI
#       EPO_FCURCVSNI     DFILI
#       EPO_FCURQUOT      DFILP
#       EPO_FDETTRS       DFILI
#       EPO_FPLC          DFILP
#       EPO_FRETTRF       DFILI
#
# Output files
#       EPO_DLSGTAACO       DFILI
#       EPO_DLSGTARCO       DFILI
#       EPO_DLSGTRCO        DFILI
#
# Job launched by ESPD1800.cmd
#
# Launch C programs ESTC2303 ESTC2304
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# 25/02/2009 J. Ribot SPOT16593 ajout steps   generation mvts IFRS
#_________________
#MODIFICATION    [002]
#Auteur:         D.GATIBELZA
#Date:           05/03/2009
#Version:        9.1
#Description:    ESTDOM16990 IFRS programme ESTM2069
#[003] 17/07/2012 Roger Cassis  :spot:23802 SOLVENCY - Gestion oricod_ls Restructuration steps
#[004] 12/10/2012 Roger Cassis  :spot:24340 Correction step de tri condition
#[005] 05/10/2015 -=Dch=- 	:spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF) 
#[006] 17/02/2016 Florent       :spot:29066 formatage du fichier GT
#[007] 21/01/2021 B.Lagha       :spot:91085 Remplacer le programme ESTM2569 par ESTM2069
#[008] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 
#[009] 10/04/2024 JYP   SPIRA 110932 parameter A-AE for RET OVERRIDE exclude some TC when RAICOM_B=0  
#[010] 15/05/2024 JYP   SPIRA 110932 parameter A-AE for RET OVERRIDE exclude some TC when RAICOM_B=0  
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

#Get input parameters
INVCONSO_D=$1
CONSOYEA=$2
#[002] Ajout ICLODAT_D
ICLODAT_D=$3
TYPEINV=$4

# Job Initialisation
JOBINIT

################################################
# Separation de la INVCONSO en 3 YEAR/MTH/DAY
export INVCONSO_YEAR=`echo ${INVCONSO_D} | cut -c1-4`
export INVCONSO_MTH=`echo ${INVCONSO_D} | cut -c5-6`
export INVCONSO_DAY=`echo ${INVCONSO_D} | cut -c7-8`
################################################

if [ "${TYPEINV}" = "EBS" ]
then
	EPO_EPOCONS=${EPO_EPOCONSSII}
	EPO_DLSGTAACO=${EPO_DLSGTAACOSII}
	EPO_DLSGTARCO=${EPO_DLSGTARCOSII}
	EPO_DLSGTRCO=${EPO_DLSGTRCOSII}
fi

NSTEP=${NJOB}_02
#Last version of ESPD1800 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EPO_DLSGTAACO}`/${PCH}ESPD1800_DLSGTAACO.dat
         `dirname ${EPO_DLSGTARCO}`/${PCH}ESPD1800_DLSGTARCO.dat
         `dirname ${EPO_DLSGTRCO}`/${PCH}ESPD1800_DLSGTRCO.dat"

NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of EPOSOCI file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_EPOCONS}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_EPOCONS_O.dat
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

#[004]
NSTEP=${NJOB}_10
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Split of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_05_${IB}_SORT_EPOCONS_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAACO.dat
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
/DERIVEDFIELD PLUS_10_CHAMPS 10"~"
/CONDITION TYP1 ACCTYP_NF EQ "1" or ACCTYP_NF EQ "99"
/CONDITION TYP2 ACCTYP_NF EQ "2"
/CONDITION TYP3 ACCTYP_NF EQ "3"
/CONDITION TYP4 ACCTYP_NF EQ "4"
/CONDITION TYP5 ACCTYP_NF EQ "5"
/CONDITION TYP1AUT1 RETAUTGEN_B EQ "1" and ( ACCTYP_NF EQ "1" or ACCTYP_NF EQ "99" )
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


NSTEP=${NJOB}_15
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_EPOCONS_O.dat

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

NSTEP=${NJOB}_25
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT1_O2.dat

NSTEP=${NJOB}_30
# Begin programme C
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
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_GTAT1_O.dat
export ${PRG}_I2=${EPO_FCES}
export ${PRG}_I3=${EPO_FDETTRS}
export ${PRG}_I4=${EPO_FTRANSCODE}
export ${PRG}_I5=${EPO_IADVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

NSTEP=${NJOB}_35
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_GTAT1_O.dat

NSTEP=${NJOB}_40
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_30_${IB}_ESTC2303_GTAR100_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
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
BALSHEY_NF ${CONSOYEA}
GTE_B 0
PRS 50
OVERRIDE 1
RETROCOM_FLG A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_GTAR100_O.dat
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
        RETINTAMT_M 41:1 - 41: EN 15/3
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
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:

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
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1_O3.dat
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1MAJ_O4.dat


#############
# Entries 2 #
#############


NSTEP=${NJOB}_80
# Begin sort
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
        RETSCOENDMTH_NF 32:1 - 32:
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

NSTEP=${NJOB}_85
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT2_O3.dat

NSTEP=${NJOB}_90
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
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_GTAT2_O.dat
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

NSTEP=${NJOB}_93
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_80_${IB}_SORT_GTAT2_O.dat


NSTEP=${NJOB}_95
# Begin sort
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
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
        PLUS_15_CHAMPS 44:1 - 58:,
        ORICOD_LS 59:1 - 59:
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

NSTEP=${NJOB}_97
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2_O1.dat
RMFIL ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2MAJ_O2.dat

NSTEP=${NJOB}_100
# Begin sort
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
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_95_${IB}_SORT_GTART2_O.dat

NSTEP=${NJOB}_110
# Begin sort
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
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:
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

NSTEP=${NJOB}_115
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2_O3.dat
RMFIL ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2MAJ_O4.dat


#############
# Entries 3 #
#############


NSTEP=${NJOB}_120
# Begin sort
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
        RETSCOENDMTH_NF 32:1 - 32:
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

NSTEP=${NJOB}_125
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT3_O4.dat

NSTEP=${NJOB}_130
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
export ${PRG}_I1=${DFILT}/${NJOB}_120_${IB}_SORT_GTAT3_O.dat
export ${PRG}_I2=${EPO_FPLC}
export ${PRG}_I3=${EPO_FCURCVSNI}
export ${PRG}_I4=${EPO_FCURQUOT}
export ${PRG}_I5=${EPO_FCURCVSN}
export ${PRG}_I6=${EPO_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART3_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTART3MAJ_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT3_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT3MAJ_O4.dat
EXECPRG

NSTEP=${NJOB}_135
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_120_${IB}_SORT_GTAT3_O.dat

NSTEP=${NJOB}_140
# Begin sort
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
        RETINTAMT_M 41:1 - 41: EN 15/3
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
        PLC_NT
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_145
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTART3_O1.dat
RMFIL ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTART3MAJ_O2.dat

NSTEP=${NJOB}_150
# Begin sort
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
        BALSHRDAY_NF 5:1 - 5:

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
      PLC_NT
/SUMMARIZE TOTAL RETAMT_M,
           TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_155
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3_O3.dat
RMFIL ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3MAJ_O4.dat


#############
# Entries 4 #
#############


NSTEP=${NJOB}_160
# Begin sort
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
# Begin sort
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
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT5_O6.dat


NSTEP=${NJOB}_180
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of DLSGTARCO files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_60_${IB}_SORT_GTART1_O.dat
SORT_I2=${DFILT}/${NJOB}_100_${IB}_SORT_GTART2_O.dat
SORT_I3=${DFILT}/${NJOB}_140_${IB}_SORT_GTART3_O.dat
SORT_I4=${DFILT}/${NJOB}_160_${IB}_SORT_GTART4_O.dat
SORT_I5=${DFILT}/${NJOB}_170_${IB}_SORT_GTART5_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTARCO.dat
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_181
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_GTART1_O.dat
RMFIL ${DFILT}/${NJOB}_100_${IB}_SORT_GTART2_O.dat
RMFIL ${DFILT}/${NJOB}_140_${IB}_SORT_GTART3_O.dat
RMFIL ${DFILT}/${NJOB}_160_${IB}_SORT_GTART4_O.dat
RMFIL ${DFILT}/${NJOB}_170_${IB}_SORT_GTART5_O.dat


NSTEP=${NJOB}_185
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of DLSGTRCO files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_70_${IB}_SORT_GTRRT1_O.dat
SORT_I2=${DFILT}/${NJOB}_110_${IB}_SORT_GTRRT2_O.dat
SORT_I3=${DFILT}/${NJOB}_150_${IB}_SORT_GTRRT3_O.dat
SORT_I4=${DFILT}/${NJOB}_10_${IB}_SORT_GTRRT4_O5.dat
SORT_I5=${DFILT}/${NJOB}_170_${IB}_SORT_GTRRT5_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTRCO.dat
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

# SPOT 16593 nouveaux STEPS

NSTEP=${NJOB}_187
#Tri du fichier ESTC1005_PERICASE Extended with TFAMCHG_O
#-----------------------------------------------------------------------------
LIBEL="Tri de ESTC1005_PERICASE Extended ... "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IADVPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS	SSD_CF 1:1 - 1: EN, CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5: EN, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:, LOB_CF 38:1 - 38:, PCPRSKTRY_CF 52:1 - 52:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_190
# GTAa files merge
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAACO.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAACO.dat 1000 1"
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
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAACO.dat


NSTEP=${NJOB}_193
#
#----------------------------------------------------------------------------
#[002] ajout paramètre ICLODAT_D
LIBEL="  IFRS  treatment"
PRG=ESTM2069
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_187_${IB}_SORT_IADVPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_190_${IB}_SORT_DLSGTAACO.dat
export ${PRG}_I3=${EPO_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IFRS_DLSGTAACO_O.dat
EXECPRG

NSTEP=${NJOB}_194
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_187_${IB}_SORT_IADVPERICASE_O.dat

NSTEP=${NJOB}_197
#
#-----------------------------------------------------------------------------
# Begin sort : accumulation DLSGTAACO et IFRS       SPOT16593
#------------------------------------------------------------------------------
LIBEL="accumulation DLSGTAACO et IFRS "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_SORT_DLSGTAACO.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_193_${IB}_ESTM2069_IFRS_DLSGTAACO_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAACO_O.dat 1000 1"
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
        AMT_M 19:1 - 19:EN 15/3,
        RETAMT_M 35:1 - 35:EN 15/3
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
      BALSHRDAY_NF
/SUMMARIZE TOTAL AMT_M
exit
EOF
SORT

NSTEP=${NJOB}_210
#DLSGTARSO sort
#-----------------------------------------------------------------------------
LIBEL="DLSGTARCO SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_180_${IB}_SORT_DLSGTARCO.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTARCO.dat 1000 1"
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
# Prog affectation retro interne
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${EPO_FPLATXCUM}
export ${PRG}_I2=${DFILT}/${NJOB}_210_${IB}_SORT_DLSGTARCO.dat
export ${PRG}_O1=${EPO_DLSGTARCO}
EXECPRG


NSTEP=${NJOB}_220
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_180_${IB}_SORT_DLSGTARCO.dat
RMFIL ${DFILT}/${NJOB}_210_${IB}_SORT_DLSGTARCO.dat

NSTEP=${NJOB}_225
#DLSGTRCO sort
#-----------------------------------------------------------------------------
LIBEL="DLSGTRCO SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_185_${IB}_SORT_DLSGTRCO.dat 1000 1"
SORT_O="${EPO_DLSGTRCO} 1000 1"
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

NSTEP=${NJOB}_230
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_185_${IB}_SORT_DLSGTRCO.dat

NSTEP=${NJOB}_235
#DLSGTAASO sort
#-----------------------------------------------------------------------------
LIBEL="DLSGTAACO SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_197_${IB}_SORT_DLSGTAACO_O.dat 1000 1"
SORT_O="${EPO_DLSGTAACO} 1000 1"
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

NSTEP=${NJOB}_240
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND

