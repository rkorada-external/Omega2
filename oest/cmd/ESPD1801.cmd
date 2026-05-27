#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS -
#                                 Comptabilisation des ecritures de services Post omega
# nom du script SHELL           : ESPD1801.cmd
# revision                      : $Revision: 1.2 $
# date de creation              : 16/06/2005
# auteur                        : J. Ribot
# references des specifications : SPOT 5085
#-----------------------------------------------------------------------------
# description
#   Special entries booking
#
# Input files
#       EPO_EPOSOCI       DFILI
#       EPO_FCES          DFILP
#       EPO_FCURCVSN      DFILI
#       EPO_FCURCVSNI     DFILI
#       EPO_FCURQUOT      DFILP
#       EPO_FDETTRS       DFILI
#       EPO_FPLC          DFILP
#       EPO_FRETTRF       DFILI
#
# output files
#       EPO_DLSGTAA       DFILI
#       EPO_DLSGTARSO       DFILI
#       EPO_DLSGTRSO        DFILI
#
# Job launched by ESPD1800.cmd
#
# Launch C programs ESTC2303 ESTC2304
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#
# 07/11/2005 J. Ribot  ajout traitement maj retro interne (retm0532.c)
# 25/02/2009 J. Ribot SPOT16593 ajout steps   generation mvts IFRS
#_________________
#MODIFICATION    [003]
#Auteur:         D.GATIBELZA
#Date:           05/03/2009
#Version:        9.1
#Description:    ESTDOM16990 IFRS programme ESTM2069
#---------------
#MODIFICATION   : [004]
#Auteur         : D.GATIBELZA
#Date           : 14/04/2011
#Version        : 11.1
#Description    : ESTDOM21408 OneLedger
#[005] 13/09/2011 Roger Cassis  :spot:22435: Suppression du RETM0532, remplacement par un copy
#[006] 17/07/2012 Roger Cassis  :spot:23802 SOLVENCY - Gestion oricod_ls et autres
#[007] 30/07/2012 -=Dch=-  		:spot:24041 Solvency - Verification des fichiers 
#[008] 27/01/2014 Roger Cassis  :spot:26189 Reformat lignes GTR sur 41 colonnes
#[009] 09/01/2015 Roger Cassis  :spot:28088 Reformat sort for GTA column 42 BUKRS_CF and correct files formating
#[010] 05/10/2015 -=Dch=-  		:spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF) 
#[011] 23/02/2016 Roger Cassis  :spot:30151 Remplacement de l'identifiant IFRSGTA par GTAR pour prise en compte dans ESID3800
#[012] 17/02/2016 Florent       :spot:29066 formatage du fichier GT
#[013] 21/07/2016 Roger Cassis  :spot:30948 On prend le fichier EPO_FTRANSCODE au lieu de EST_FTRANSCODE et EST_FTRSLNK en EPO_FTRSLNK
#[014] 21/07/2016 Florent       :spot:30978 EST P&C - PRENDRE EN COMPTE LES ES POST OMEGA IFRS DANS LE BLANCHIMENT DU LEGALE ITALIEN (_IT_)
#[015] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[016] 29/01/2021 B.Lagha       :spot:91085 Remplacer le programme ESTM2569 par ESTM2069. 
#[017] 13/07/2021 MZM       :spira:92952 AE FUSION des Pericase I17 (INI et STD).
#[018] 10/01/2022 MZM  	SPIRA : 91532  	Bug Fix : Taille Syncsort de 1000 ==> 2000
#[019] 27/04/2022 MZM  	SPIRA : 104062 Ecart RA/RR view : Deplacement du LOfactor AE EBS uniquement du Job ESFD2507 au Job ESPD1801 ci dessous
#[020] 09/05/2022 MZM  	SPIRA : 104138 Generation fichier Permanent Pericase Merge I17 INI et I17 STD
#[021] 05/07/2022 JBD   SPIRA : 104778 Build new closing for I17S norm 
#[022] 20/07/2022 JYP   SPIRA : 104138 bugfix duplicate issue when merging pericase INI+STD
#[023] 12/04/2023 MiS   SPIRA : 108544 Add Norm Param for ESTM2561
#[024] 04/10/2023 MZM   SPIRA ::110474 PROD6 AEs entries not found in SAP : Force RETUW_NT to 1 when it's not null
#[025] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 
#[026] 10/04/2024 JYP   SPIRA 110932 parameter A-AE for RET OVERRIDE exclude some TC when RAICOM_B=0  
#[027] 23/09/2024 MZM   SPIRA :112214 Force RETUW_NT to 1 when it's different to 1 (Complement :110474 )  
#[028] 10/03/2025 MZM   SPIRA :112836 Q25 PRD - Program wrongly adds Retro order 1 when AE booked on Assumed only : "Force RETUW_NT to 1 when ( RETUW_NT != "1" )	AND  (RETCTR_NF != "")" 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

#Get input parameters
INVCONSO_D=$1
CONSOYEA=$2
TYPEINV=$3
NORME=$4

# TU
##INVCONSO_D="20201231"
##CONSOYEA="2020"
##TYPEINV="POS"
##NORME="EBS"
##
##EPO_EPOSOCI=/scor/home/u006596/martin/perm/
##EPO_EPOSOCI=/scor/home/u006596/martin/interm/M_ESFD0060_I17G____EPOSOCI_POS_20210930.dat
##EPO_DLSGTAA=/scor/home/u006596/martin/perm/M_ESPD1800_I17G_AET_RPO_I17_DLSGTAASII_POS_20210930.dat
##EPO_DLSGTAR=/scor/home/u006596/martin/perm/M_ESPD1800_I17G_AET_RPO_I17_DLSGTARSII_POS_20210930.dat
##EPO_DLSGTR=/scor/home/u006596/martin/perm/M_ESPD1800_I17G_AET_RPO_I17_DLSGTRSII_POS_20210930.dat
##ESF_IADVPERICASE_STD=/scor/scordata/ubeu/perm/D_ESFD5010_IADPERICASE_STD_EBS_INV_20210930.dat
##EPO_IADVPERICASE=/scor/home/u006596/martin/perm/M_ESFD5020_IADPERICASE_I17G_INI_POS_20210930.dat
##EPO_OIRDVPERICASE=/scor/home/u006596/martin/perm/M_ESFD5010_OIRDVPERICASE_EBS_POS_20210630.dat
##EPO_FDETTRS=/scor/home/u006596/martin/perm/M_ESCJ0060_FDETTRS_TXT_INV_20210630.dat
##EPO_FTRANSCODE=/scor/home/u006596/martin/perm/M_ESCJ0060_FTRANSCODE_INV_20210630.dat
##EPO_FCES=/scor/home/u006596/martin/perm/M_ESID2500_FCES_INV_20210930.dat
##
##EPO_FPLC=/scor/home/u006596/martin/perm/M_ESID2500_FPLC_INV_20210930.dat
##export ${PRG}_I3=${EPO_FCURCVSNI}
##EPO_FCURQUOT=/scor/home/u006596/martin/perm/M_ESCJ0060_FCURQUOT_INV_20210930.dat
##EPO_FCURCVSN=/scor/home/u006596/martin/perm/M_ESCJ0060_FCURCVSN_INV_20210930.dat
##EPO_FCURCVSNI=/scor/home/u006596/martin/perm/M_ESCJ0060_FCURCVSNI_INV_20210930.dat
##EPO_FTRSLNK=/scor/home/u006596/martin/perm/M_ESCJ0060_FTRSLNK_INV_20210930.dat
##
##EPO_FPLATXCUM=/scor/home/u006596/martin/perm/M_ESID0560_FPLATXCUM_INV_20210930.dat
##
##export ESF_FLORETFACTOR=/scor/home/u006596/martin/interm/M_ESPD0060_FLORETFACTOR_STD_POS_20201231.dat
# TU END

# Job Initialisation
JOBINIT

################################################
# Separation de la INVCONSO en 3 YEAR/MTH/DAY
export INVCONSO_YEAR=`echo ${INVCONSO_D} | cut -c1-4`
export INVCONSO_MTH=`echo ${INVCONSO_D} | cut -c5-6`
export INVCONSO_DAY=`echo ${INVCONSO_D} | cut -c7-8`
################################################

#if [ "${NORME}" = "EBS" ]
#then
#	if [ "${TYPEINV}" = "POS" ]
#	then
#		EPO_EPOSOCI=${EPO_EPOSIISO}
#		EPO_DLSGTAA=${EPO_DLSGTAASIISO}
#		EPO_DLSGTAR=${EPO_DLSGTARSIISO}
#		EPO_DLSGTR=${EPO_DLSGTRSIISO}
#	else
#		EPO_EPOSOCI=${EPO_EPOSIICO}
#		EPO_DLSGTAA=${EPO_DLSGTAASIICO}
#		EPO_DLSGTAR=${EPO_DLSGTARSIICO}
#		EPO_DLSGTR=${EPO_DLSGTRSIICO}
#	fi		
#else
#	if [ "${TYPEINV}" = "POS" ]
#	then
#		EPO_EPOSOCI=${EPO_EPOSOCI}
#		EPO_DLSGTAA=${EPO_DLSGTAASO}
#		EPO_DLSGTAR=${EPO_DLSGTARSO}
#		EPO_DLSGTR=${EPO_DLSGTRSO}
#	else
#		EPO_EPOSOCI=${EPO_EPOCONS}
#		EPO_DLSGTAA=${EPO_DLSGTAACO}
#		EPO_DLSGTAR=${EPO_DLSGTARCO}
#		EPO_DLSGTR=${EPO_DLSGTRCO}
#	fi		
#fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV.................: ${TYPEINV}"
ECHO_LOG "#===> NORME...................: ${NORME}"
ECHO_LOG "#===> EPO_EPOSOCI.............: ${EPO_EPOSOCI}"
ECHO_LOG "#===> EPO_DLSGTAA.............: ${EPO_DLSGTAA}"
ECHO_LOG "#===> EPO_DLSGTAR.............: ${EPO_DLSGTAR}"
ECHO_LOG "#===> EPO_DLSGTR..............: ${EPO_DLSGTR}"
ECHO_LOG "#===> ESF_IADVPERICASE_STD....: ${ESF_IADVPERICASE_STD}"
ECHO_LOG "#===> EPO_IADVPERICASE........: ${EPO_IADVPERICASE}"
ECHO_LOG "#===> INVCONSO_D..............: ${INVCONSO_D}"
ECHO_LOG "#===> CONSOYEA................: ${CONSOYEA}"
ECHO_LOG "#========================================================================="

#[007]
NSTEP=${NJOB}_02
#Last version of ESPD1800 files deletion
#-----------------------------------------------------------------
RMFIL "${EPO_DLSGTAA}"
RMFIL "${EPO_DLSGTAR}"
RMFIL "${EPO_DLSGTR}"

#[006] [009]
NSTEP=${NJOB}_05
# begin sort
#[024] [027] #[024] [027]  #[028]Force RETUW_NT to 1 when it's empty
#-----------------------------------------------------------------------------
LIBEL="Sort of EPOSOCI file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_EPOSOCI}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_EPOSOCI_O.dat
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
/DERIVEDFIELD INVCONSO_YEAR ${INVCONSO_YEAR}
/DERIVEDFIELD INVCONSO_MTH ${INVCONSO_MTH}
/DERIVEDFIELD INVCONSO_DAY ${INVCONSO_DAY}
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD ZERO "0.000" CHAR 5
/DERIVEDFIELD RETUW_NT_NEW if  EST_INCORRECT then "1" else RETUW_NT
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

#[006]
NSTEP=${NJOB}_10
# begin sort
#-----------------------------------------------------------------------------
LIBEL="Split of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_05_${IB}_SORT_EPOSOCI_O.dat
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

NSTEP=${NJOB}_11
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
GZIPM_I="${DFILT}/${NJOB}_05_${IB}_SORT_EPOSOCI_O.dat ${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAA.dat ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT1_O2.dat ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT2_O3.dat ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT3_O4.dat ${DFILT}/${NJOB}_10_${IB}_SORT_GTRRT4_O5.dat ${DFILT}/${NJOB}_10_${IB}_SORT_GTAT5_O6.dat"
GZIPM

NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_EPOSOCI_O.dat

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



NSTEP=${NJOB}_26
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-INI not in pericase STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IADVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_INI_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       3:1 -  3:, 
		END_NT       4:1 -  4:, 
		SEC_NF       5:1 -  5:, 
		UWY_NF       6:1 -  6:, 
		UW_NT        7:1 -  7:, 
		STD_CTR_NF   3:1 -  3:, 
		STD_END_NT   4:1 -  4:, 
		STD_SEC_NF   5:1 -  5:, 
		STD_UWY_NF   6:1 -  6:, 
		STD_UW_NT    7:1 -  7:,
		ALL_COLS     1:1 -  252: 
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${ESF_IADVPERICASE_STD} 2000 1 "~"
/joinkeys
        STD_CTR_NF,
        STD_END_NT,
        STD_SEC_NF,
        STD_UWY_NF,
        STD_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT




NSTEP=${NJOB}_28
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT PERICASE INI And STD "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_26_${IB}_SORT_IADVPERICASE_INI_O.dat 2000 1"
SORT_I2="${ESF_IADVPERICASE_STD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_MERGE_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       3:1 -  3:, 
        		END_NT       4:1 -  4:, 
        		SEC_NF       5:1 -  5:, 
       		  UWY_NF       6:1 -  6:, 
        		UW_NT        7:1 -  7: 
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT



## [020] GENERATION D'Un Fichier Permanent PERICASE ASSUMED MERGE I17 INI et I17 STD

if [ "${IDF_CT}" = "I17G_AET_RPO_I17" ] || [ "${IDF_CT}" = "I17L_AET_RPO_I17" ] || [ "${IDF_CT}" = "I17P_AET_RPO_I17" ] || [ "${IDF_CT}" = "I17S_AET_RPO_I17" ]
then

NSTEP=${NJOB}_29
LIBEL="GENERATION D'Un Fichier Permanent PERICASE ASSUMED MERGE I17 INI et I17 STD..."
	EXECKSH "cp ${DFILT}/${NJOB}_28_${IB}_SORT_IADVPERICASE_MERGE_O.dat  ${ESF_IADPERICASE_I17_MERGE}"

fi

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
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_GTAT1_O.dat
export ${PRG}_I2=${EPO_FCES}
export ${PRG}_I3=${EPO_FDETTRS}
export ${PRG}_I4=${EPO_FTRANSCODE}    #[013]
#export ${PRG}_I5=${EPO_IADVPERICASE} 
export ${PRG}_I5=${DFILT}/${NJOB}_28_${IB}_SORT_IADVPERICASE_MERGE_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG



## DEb [019] DEB Applying LOFACTOR AFTER CESSION


if [ "${VNORME}" = "EBS" ]
then

# TRIE du fichier LOFACTOR sur RETCTR, RETENT, RETSEC, RTY, RETUW 

NSTEP=${NJOB}_32I
# FLORETFACTOR 
#-----------------------------------------------------------------------------
LIBEL="SORT OF FLORETFACTOR BY RETCTR,RETENT, RETSEC, RTY, RETUW ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLORETFACTOR.dat 2000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 	CTR_NF 				  		    1:1 - 1:,
					END_NT 				          2:1 - 2:,
					SEC_NF 				          3:1 - 3:,
					UWY_NF 				          4:1 - 4:,
					UW_NT 					        5:1 - 5:,
					RETCTR_NF 			   			6:1 - 6:,
					RETEND_NT 			        7:1 - 7:,
					RETSEC_NF 			        8:1 - 8:,
					RETRTY_NF 				      9:1 - 9:,
					RETUW_NT 			          10:1 - 10:,
					LOFACTOR  			        30:1 - 30: EN 15/3
/KEYS 		RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT,
          CTR_NF, 
					END_NT, 
					SEC_NF, 
					UWY_NF,
      LOFACTOR
exit
EOF
SORT



NSTEP=${NJOB}_32A
# Sort ${DFILT}/${NJOB}_30_${IB}_ESTC2303_GTAR100_O.dat
#-----------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, TO Join To LOFACTOR..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC2303_GTAR100_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:       	
/KEYS 		RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT,
          CTR_NF, 
					END_NT, 
					SEC_NF, 
					UWY_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT
#


NSTEP=${NJOB}_32B
# Join and sort of  ${DFILT}/${NJOB}_10_${IB}_ESTC2303_GTAR100_O.dat File and FLORETFACTOR by RETCTR,RETENT, RETSEC, RTY, RETUW 
#------------------------------------------------------------------------------
LIBEL="Current GTAR100_O.dat File Sort, Join and Fusion With ESF_FLORETFACTOR ..."
SORT_WDIR=${SORTWORK}
SORT_I="${DFILT}/${NJOB}_32A_${IB}_SORT_GTAR100_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
					CTR_NF_F2						    1:1 -  1:,
        	END_NT_F2        		    2:1 -  2:,
					SEC_NF_F2 			  	    3:1 -  3:,
					UWY_NF_F2        	      4:1 -  4:,
					RETCTR_NF_F2				    6:1 -  6:,
        	RETEND_NT_F2            7:1 -  7:,
					RETSEC_NF_F2 			      8:1 -  8:,
					RTY_NF_F2        	      9:1 -  9:,
					RETUW_NT_F2             10:1 -  10:,							
        	LOFACTOR_F2 		        30:1 - 30: EN 15/3,
					ALL_F1    			        1:1 -  72:,        	
					ALL_F2    			        1:1 - 30:				
/JOINKEYS RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT,
          CTR_NF, 
					END_NT, 
					SEC_NF, 
					UWY_NF	
/INFILE ${DFILT}/${NJOB}_32I_${IB}_SORT_FLORETFACTOR.dat 2000 1 "~"
/JOINKEYS RETCTR_NF_F2,
					RETEND_NT_F2,
					RETSEC_NF_F2,
          RTY_NF_F2,
          RETUW_NT_F2,
					CTR_NF_F2,	
      		END_NT_F2, 
					SEC_NF_F2, 
					UWY_NF_F2           
/JOIN UNPAIRED LEFTSIDE                 
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: LOFACTOR_F2        
exit
EOF
SORT   



NSTEP=${NJOB}_32C
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="SORT GTAR UNIQUE TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_32B_${IB}_SORT_GTAR100_FACTOR_O.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    	            1:1 - 73:       
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (ALL_F1 != "" )
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT



NSTEP=${NJOB}_32D
# SORT UNIQUE of GTAR100_FACTOR 
#------------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, Join and Fusion UNIQUE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_32C_${IB}_SORT_GTAR100_FACTOR_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT_F2               36:1 - 36:,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,										
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
        	LOFACTOR      					72:1 - 72: EN 15/3        	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT,
      		PLC_NT_F2,
      		RETCUR_CF,
      		TRNCOD_CF,    		 
					LOFACTOR
/OUTFILE ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_32E
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying Lofacactor to ${DFILT}/${NJOB}_32C_${IB}_ESTC2303_GTAR100_O.dat..."
PRG=ESTC2308  
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_32C_${IB}_SORT_GTAR100_FACTOR_O.dat
export ${PRG}_I2=${EPO_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

fi 

#### FIN [019] Applying LOFACTOR AFTER CESSION




NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_GTAT1_O.dat

NSTEP=${NJOB}_36
#-----------------------------------------------------------------------------
LIBEL="Reformat ${EST_FACCSUP} for maj TRN_NT RETRO AUTO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_EPOSOCI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_RETROAUTO_O.dat 2000 1"
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
if [ "${VNORME}" = "EBS" ]
then
SORT_I="${DFILT}/${NJOB}_32E_${IB}_ESTC2308_GTAR100_O.dat 500 1"
else
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC2303_GTAR100_O.dat 500 1"
fi
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

/INFILE ${DFILT}/${NJOB}_36_${IB}_SORT_FACCSUP_RETROAUTO_O.dat 2000 1
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

NSTEP=${NJOB}_51
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
GZIPM_I="${DFILT}/${NJOB}_40_${IB}_SORT_GTAR100_O.dat ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1_O1.dat ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTART1MAJ_O2.dat ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1_O3.dat ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1MAJ_O4.dat"
GZIPM

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

NSTEP=${NJOB}_71
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

NSTEP=${NJOB}_91
#-----------------------------------------------------------------------------
GZIPM_I="${DFILT}/${NJOB}_80_${IB}_SORT_GTAT2_O.dat ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2_O1.dat ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2MAJ_O2.dat ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2_O3.dat ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2MAJ_O4.dat"
GZIPM

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

#[006]
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

NSTEP=${NJOB}_131
#-----------------------------------------------------------------------------
GZIPM_I="${DFILT}/${NJOB}_120_${IB}_SORT_GTAT3_O.dat ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTART3_O1.dat ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTART3MAJ_O2.dat ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3_O3.dat ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3MAJ_O4.dat"
GZIPM

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

#[006]
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

#[006]
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

NSTEP=${NJOB}_181
#-----------------------------------------------------------------------------
GZIPM_DEL="YES"
GZIPM_I="${DFILT}/${NJOB}_60_${IB}_SORT_GTART1_O.dat ${DFILT}/${NJOB}_100_${IB}_SORT_GTART2_O.dat ${DFILT}/${NJOB}_140_${IB}_SORT_GTART3_O.dat ${DFILT}/${NJOB}_160_${IB}_SORT_GTART4_O.dat ${DFILT}/${NJOB}_170_${IB}_SORT_GTART5_O.dat"
GZIPM

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

# SPOT 16593 nouveaux STEPS
NSTEP=${NJOB}_187
#-----------------------------------------------------------------------------
LIBEL="Tri de ESTC1005_PERICASE Extended with TFAMCHG_O"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IADVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_O.dat 2000 1"
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
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA.dat 2000 1"
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
export ${PRG}_I3=${EPO_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IFRS_DLSGTAA_O.dat
EXECPRG

NSTEP=${NJOB}_194
#----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_187_${IB}_SORT_IADVPERICASE_O.dat

#[009] Compress du AMT_M
NSTEP=${NJOB}_197
#-----------------------------------------------------------------------------
LIBEL="accumulation DLSGTAASO et IFRS SPOT16593"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_SORT_DLSGTAA.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_193_${IB}_ESTM2069_IFRS_DLSGTAA_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA_O.dat 2000 1"
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
export ${PRG}_I2=${EPO_FDETTRS}
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
export ${PRG}_I2=${EPO_FDETTRS}
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
export ${PRG}_I2=${EPO_FDETTRS}
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
SORT_I="${DFILT}/${NJOB}_200_${IB}_ESTM7603_DLSGTAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR.dat 2000 1"
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
export ${PRG}_I1=${EPO_FPLATXCUM}
export ${PRG}_I2=${DFILT}/${NJOB}_210_${IB}_SORT_DLSGTAR.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR.dat
EXECPRG

NSTEP=${NJOB}_220
#-----------------------------------------------------------------------------
LIBEL="sort of balance sheet year "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_215_${IB}_RETM0532_DLSGTAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_O.dat 2000 1"
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
NORME ${NORME}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_220_${IB}_SORT_DLSGTAR_O.dat
export ${PRG}_I2=${EPO_OIRDVPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IT_DLSGTAR.dat
EXECPRG

NSTEP=${NJOB}_235
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition for italian DLSGTAR"
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_230_${IB}_ESTM2561_IT_DLSGTAR.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IT_DLSGTAR.dat
EXECPRG


#[019] Suppression des Montants a zero

NSTEP=${NJOB}_240
#-----------------------------------------------------------------------------
LIBEL="Cration ${EPO_DLSGTAR} SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_215_${IB}_RETM0532_DLSGTAR.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_235_${IB}_ESTM7603_IT_DLSGTAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS DEBUT      1:1 - 56:,
        FIN       58:1 - 71:,
        TRNCOD_2   6:2 -  6:2,
        RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF    27:1 - 27:,
        PLC_NT    36:1 - 36:EN,
        AMT_M     19:1 - 19:EN 15/3,
        RETAMT_M  35:1 - 35:EN 15/3,
        RETINTAMT_M 41:1 - 41:EN 15/3    
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 )
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION      
exit
EOF
SORT

NSTEP=${NJOB}_241
#-----------------------------------------------------------------------------
LIBEL="exec awk Update oricod_ls to EBSGTA or GTAR"
AWK_I=${DFILT}/${NJOB}_240_${IB}_SORT_DLSGTAR.dat
AWK_O=${EPO_DLSGTAR}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  { post = substr(\$6,2,1);
    if ( post == "A" || post == "B" || post == "D" || post == "E" || post == "G" ||
         post == "H" || post == "J" || post == "K" || post == "L" )
    {
      \$57 = "EBSGTA";
      print \$0;
    }
    else
    {
      \$57 = "GTAR";
      print \$0;
    }
  }
exit
EOF
AWK


NSTEP=${NJOB}_245
#------------------------------------------------------------------------------
LIBEL="italian DLSGTR blanking accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_235_${IB}_ESTM7603_IT_DLSGTAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IT_DLSGTR.dat 2000 1"
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



#[008]
#[019] Suppression des lignes dont Montants RETAMT_M et RETINTAMT_M a zero

NSTEP=${NJOB}_250
#-----------------------------------------------------------------------------
LIBEL="DLSGTRSO SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_205_${IB}_ESTM7603_DLSGTR.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_245_${IB}_SORT_IT_DLSGTR.dat 2000 1"
SORT_O="${EPO_DLSGTR} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF    27:1 - 27:,
        PLC_NT    36:1 - 36:EN,
        RETAMT_M 35:1 - 35:EN 15/3      
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
/CONDITION RESTRICTION ( RETAMT_M NE 0 )
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION      
exit
EOF
SORT

NSTEP=${NJOB}_260
#------------------------------------------------------------------------------
LIBEL="Current ACY transactions blanking for italian ${EPO_DLSGTAA} only"
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
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IT_DLSGTAA.dat
EXECPRG

#[009]
NSTEP=${NJOB}_270
#-----------------------------------------------------------------------------
LIBEL="Création ${EPO_DLSGTAA} SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_265_${IB}_ESTM7603_IT_DLSGTAA.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_198_${IB}_ESTM7603_DLSGTAA.dat 2000 1"
SORT_O="${EPO_DLSGTAA} 2000 1"
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
/DERIVEDFIELD NEW_ORICOL_LS "${NORME}GTA~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,NEW_ORICOL_LS,FILLER_14_COLS
exit
EOF
SORT

NSTEP=${NJOB}_271
#-----------------------------------------------------------------------------
LIBEL="gzip Italy EPO_DLSGT $TYPEINV $NORME"
GZIPM_DEL="YES"
GZIPM_I="${DFILT}/${NJOB}_265_${IB}_ESTM7603_IT_DLSGTAA.dat ${DFILT}/${NJOB}_245_${IB}_SORT_IT_DLSGTR.dat ${DFILT}/${NJOB}_235_${IB}_ESTM7603_IT_DLSGTAR.dat"
GZIPM

NSTEP=${NJOB}_300
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

