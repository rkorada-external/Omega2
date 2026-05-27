#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Comptabilisation des ecritures de services IFRS17 Life
#				  
# nom du script SHELL		: ESFD1800.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 30/06/2020
# auteur			: S.Behague
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#-----------------------------------------------------------------------------
# Input files
#       EST_FACCSUP       DFILI
#       EST_FCES                  DFILP
#       EST_FCURCVSNI     DFILI
#       EST_FCURQUOT              DFILP
#       EST_FDETTRS       DFILI
#       EST_FPLC                  DFILP
#       EST_FRETTRF       DFILI
#
# Output files
#       ESF_DLSGTAA       DFILI
#       ESF_DLSGTAR       DFILI
#       ESF_DLSGTR        DFILI
#
# Job launched by ESFD1800.cmd
#
# Launch C programs ESTC2303 ESTC2304
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[001] 18/03/2021  B.Lagha:spot:81531 Remplacer les noms des fichiers perm par des varibales step 010 et 02
#[002] 14/02/2022  MZM :spira:81531 Ajout touch pour creation fichier Vide si absent
#[003] 21/02/2022 S.Behague :spira:98141: IFRS17 FWH Bookings
#[004] 15/03/2022 HR :spira:104182: IFRS17 Life - Manage Pericase by Norm
#[005] 11/04/2022 S.Behague :spira:98141: IFRS17 FWH Bookings
#[006] 06/05/2022 S.Behague :spira:104252: IFRS 17 - FWH - Counterparty is missing
#[007] 22/11/2023 JYP/MZM/Florian:Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0  
#[008] 10/04/2024 JYP:Spira:110932 parameter A-AE for RET OVERRIDE exclude some TC when RAICOM_B=0  
#[009] 15/05/2024 JYP:Spira:110932 parameter A-AE for RET OVERRIDE exclude some TC when RAICOM_B=0  
#[010] 04/02/2025 S.Behague : SPIRA 111434 - [OMEGA Life] FWH - Accrual adjustment
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

#Get input parameters
CLODAT_D=$1
BALSHEY_NF=$2

################################################
#MODIF FGL du 18/10/2000
# Separation de la CLODAT en 3 YEAR/MTH/DAY
export CLODAT_YEAR=`echo ${CLODAT_D} | cut -c1-4`
export CLODAT_MTH=`echo ${CLODAT_D} | cut -c5-6`
export CLODAT_DAY=`echo ${CLODAT_D} | cut -c7-8`
################################################

# Job Initialisation
JOBINIT

##002]
if [ ! -f ${ESF_DLSGTAA} ]
then
	touch ${ESF_DLSGTAA}
fi

if [ ! -f ${ESF_DLSGTAR} ]
then
	touch ${ESF_DLSGTAR}
fi

if [ ! -f ${ESF_DLSGTR} ]
then
	touch ${ESF_DLSGTR}
fi

if [ ! -f ${EST_FUNDWITHHELD_I17_PC} ]
then
	touch ${EST_FUNDWITHHELD_I17_PC}
fi

if [ "${EST_ESID1800_COND1}" = "Y" ]
then
NSTEP=${NJOB}_010
#------------------------------------------------------------------------------
LIBEL="move ESF_DLSGTAA ==> DFILT _WRK_DLSGTAA.dat"
EXECKSH "cp ${ESF_DLSGTAA} ${DFILT}/${NSTEP}_${IB}_WRK_DLSGTAA.dat"


NSTEP=${NJOB}_011
#------------------------------------------------------------------------------
LIBEL="move EST_DLSGTAR ==> DFILT _WRK_DLSGTAR.dat"
EXECKSH "cp ${ESF_DLSGTAR} ${DFILT}/${NSTEP}_${IB}_WRK_DLSGTAR.dat"

NSTEP=${NJOB}_012
#------------------------------------------------------------------------------
LIBEL="move EST_DLSGTR ==> DFILT _WRK_DLSGTR.dat"
EXECKSH  "cp ${ESF_DLSGTR} ${DFILT}/${NSTEP}_${IB}_WRK_DLSGTR.dat"

fi

NSTEP=${NJOB}_02
#Last version of ESID1800 files deletion
#-----------------------------------------------------------------
RMFIL "  ${ESF_DLSGTAA}
         ${ESF_DLSGTAR}
         ${ESF_DLSGTR}"

NSTEP=${NJOB}_02A
#Double entry transaction code addition
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition "
PRG=ESTM7603
#export ${PRG}_I1=${EST_FUNDWITHHELD_I17_PC}
export ${PRG}_I1=${DFILT}/${ENV_PREFIX}_ESFD1800_ESFD1804_180_${IB}_FWH_MERGED_SORT.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FUNDWITHHELD_I17_PC_O.dat
EXECPRG

NSTEP=${NJOB}_03
#-----------------------------------------------------------------------------
LIBEL="Dispatch assumed and retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_02A_${IB}_ESTM7603_FUNDWITHHELD_I17_PC_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FUNDWITHHELD_I17_ASSUMED.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FUNDWITHHELD_I17_RETRO.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ACCRET_B	60:1 - 60:,
        FILLER 1:1 - 35:,
        ORICOD 58:1 - 58:,
        FILLERA 1:1 - 34:
/CONDITION I17FWH ( ORICOD = "I17FWH" )
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD ZERO "0.000" CHAR 5
/DERIVEDFIELD FWH IF I17FWH THEN "I17FWH~" ELSE "I4IFWH~"
/DERIVEDFIELD SPEENTNAT "9~"
/COPY
/CONDITION ACCRET ( ACCRET_B = "A" )
/OUTFILE ${SORT_O}
/REFORMAT FILLERA,ZERO,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR, ZERO,
					SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,FWH,SEPARATEUR,SPEENTNAT,
					SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR
/INCLUDE ACCRET
/OUTFILE ${SORT_O2}
/REFORMAT FILLER,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR, ZERO,
					SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,FWH,SEPARATEUR,SPEENTNAT,
					SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR
/OMIT ACCRET
exit
EOF
SORT

#[004]
NSTEP=${NJOB}_05
# FILTER PERIMETER WITH PERICASE
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER ASSUMED WITH PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03_${IB}_FUNDWITHHELD_I17_ASSUMED.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FUNDWITHHELD_I17_ASSUMED_FILTERED.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF   8:1 - 8:,
        END_NT   9:1 - 9:,
        SEC_NF   10:1 - 10:,
        UWY_NF   11:1 - 11:,
        UW_NT    12:1 - 12:,
        PER_CTR_NF 3:1 - 3:,
        PER_END_NT 4:1 - 4:,
        PER_SEC_NF 5:1 - 5:,
        PER_UWY_NF 6:1 - 6:,
        PER_UW_NT  7:1 - 7:,
        ALLCOLS  1:1 - 71:
/joinkeys
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${EST_IADVPERICASE} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: ALLCOLS
exit
EOF
SORT

#[004]
NSTEP=${NJOB}_06
# FILTER PERIMETER WITH PERICASE
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER RETRO WITH PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03_${IB}_FUNDWITHHELD_I17_RETRO.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FUNDWITHHELD_I17_RETRO_FILTERED.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF   8:1 - 8:,
        END_NT   9:1 - 9:,
        SEC_NF   10:1 - 10:,
        UWY_NF   11:1 - 11:,
        UW_NT    12:1 - 12:,
        PER_CTR_NF 3:1 - 3:,
        PER_END_NT 4:1 - 4:,
        PER_SEC_NF 5:1 - 5:,
        PER_UWY_NF 6:1 - 6:,
        PER_UW_NT  7:1 - 7:,
        ALLCOLS  1:1 - 71:
/joinkeys
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${EST_IRDVPERICASE} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: ALLCOLS
exit
EOF
SORT


#[003]
NSTEP=${NJOB}_035
#-----------------------------------------------------------------------------
LIBEL="Exchange assumed and retro part for retro contract"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_06_${IB}_FUNDWITHHELD_I17_RETRO_FILTERED.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FUNDWITHHELD_I17_RETRO_REPLACED.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
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
        FILLER1 1:1 - 7:,
        FILLER2 36:1 - 70:
/DERIVEDFIELD SEPARATEUR "~"
/COPY
/OUTFILE ${SORT_O}
/REFORMAT FILLER1, SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,CUR_CF,AMT_M,SEPARATEUR,SEPARATEUR,SEPARATEUR,SEPARATEUR,
					CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, SEPARATEUR, CUR_CF, AMT_M, FILLER2, SEPARATEUR
exit
EOF
SORT


NSTEP=${NJOB}_05
#[004] longueur et REFORMAT et ajout des champs SPEENTNAT_CT, EVT_NF, REVT_NF
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of FACCSUP file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FACCSUPI17LIFE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_O.dat 1000 1"
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
        RETKEY_CF 40:1 - 40:,
        RETAUTGEN_B 41:1 - 41:,
        ACCTYP_NF    42:1 - 42:EN,
        TRN_NT       43:1 - 43:,
        ORICOD_LS    44:1 - 44:,
        RETROAUTO_B  45:1 - 45:,
        SPEENTNAT_CT 46:1 - 46:,
        EVT_NF       47:1 - 47:,
        REVT_NF      48:1 - 48:
/CONDITION SERV (TRNCOD_SOUS_PREFIX >= "4" and "SCORIT" NC TRNCOD_SOUS_PREFIX)
           or ACCTYP_NF = 0 or ACCTYP_NF = 1
           or ACCTYP_NF = 98 or ACCTYP_NF = 99
           or ("EGHJKL" CT TRNCOD_SOUS_PREFIX)
			  or ("VWXNYU" CT TRNCOD_SOUS_PREFIX)
/DERIVEDFIELD CLODAT_YEAR ${CLODAT_YEAR}
/DERIVEDFIELD CLODAT_MTH ${CLODAT_MTH}
/DERIVEDFIELD CLODAT_DAY ${CLODAT_DAY}
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD ZERO "0.000" CHAR 5
/OUTFILE ${SORT_O}
/INCLUDE SERV
/REFORMAT SSD_CF,
          ESB_CF,
          CLODAT_YEAR,
          SEPARATEUR,
          CLODAT_MTH,
          SEPARATEUR,
          CLODAT_DAY,
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

# ajout step pour garder les enregistrements des filiales non presentes dans l'inventaire
#  JR 01/06/2004
NSTEP=${NJOB}_08
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Extract of DLSGTAA file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I=${DFILT}/${NJOB}_010_${IB}_WRK_DLSGTAA.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA_O.dat
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
#[004] longueur et REFORMAT
#-----------------------------------------------------------------------------
LIBEL="Split of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_FACCSUP_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA.dat
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
/DERIVEDFIELD PLUS_10_CHAMPS 9"~"
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


#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_05_${IB}_SORT_FACCSUP_O.dat > ${DFILT}/${NJOB}_05_SORT_FACCSUP_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA.dat     > ${DFILT}/${NSTEP}_SORT_DLSGTAA.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_GTAT1_O2.dat    > ${DFILT}/${NSTEP}_SORT_GTAT1_O2.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_GTAT2_O3.dat    > ${DFILT}/${NSTEP}_SORT_GTAT2_O3.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_GTAT3_O4.dat    > ${DFILT}/${NSTEP}_SORT_GTAT3_O4.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_GTRRT4_O5.dat   > ${DFILT}/${NSTEP}_SORT_GTRRT4_O5.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_GTAT5_O6.dat    > ${DFILT}/${NSTEP}_SORT_GTAT5_O6.dat.gz 
#-----------------------------------------------------------------------------
# ajout Step_12 pour reintegrer les enregistrements des filiales non presentes dans l'inventaire
NSTEP=${NJOB}_12
# Begin sort
#[004]
#-----------------------------------------------------------------------------
LIBEL="Merge of DLSGTAA file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAA.dat
SORT_I2=${DFILT}/${NJOB}_08_${IB}_SORT_DLSGTAA_O.dat
SORT_I3=${DFILT}/${NJOB}_05_${IB}_FUNDWITHHELD_I17_ASSUMED_FILTERED.dat
#SORT_O=${ESF_DLSGTAA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA.dat
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT


#[004]
NSTEP=${NJOB}_13
# FILTER PERIMETER WITH PERICASE
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER ASSUMED WITH PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_12_${IB}_SORT_DLSGTAA.dat 1000 1"
SORT_O="${ESF_DLSGTAA}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF   8:1 - 8:,
        END_NT   9:1 - 9:,
        SEC_NF   10:1 - 10:,
        UWY_NF   11:1 - 11:,
        UW_NT    12:1 - 12:,
        PER_CTR_NF 3:1 - 3:,
        PER_END_NT 4:1 - 4:,
        PER_SEC_NF 5:1 - 5:,
        PER_UWY_NF 6:1 - 6:,
        PER_UW_NT  7:1 - 7:,
        ALLCOLS  1:1 - 71:
/joinkeys
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${EST_IADVPERICASE} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: ALLCOLS
exit
EOF
SORT


NSTEP=${NJOB}_15
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_WRK_DLSGTAA.dat
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_FACCSUP_O.dat
RMFIL ${DFILT}/${NJOB}_08_${IB}_SORT_DLSGTAA_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAA.dat

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
SORT_I="${ESF_FACCSUPI17LIFE} 1000 1"
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
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_37_${IB}_MAJ_RETRO_ES_GTAR100_O.dat
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
RETROCOM_FLG A
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
LIBEL="Sauvegarde des fichiers"
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

#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1_O3.dat    > ${DFILT}/${NJOB}_50_ESTC2304_GTRRT1_O3.dat.gz
gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC2304_GTRRT1MAJ_O4.dat > ${DFILT}/${NJOB}_50_ESTC2304_GTRRT1MAJ_O4.dat.gz
#-----------------------------------------------------------------------------

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
SORT_I2=${DFILT}/${NJOB}_035_${IB}_FUNDWITHHELD_I17_RETRO_REPLACED.dat
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
BALSHEY_NF ${BALSHEY_NF}
GTE_B 0
PRS_CF 50
OVERRIDE 1
RETROCOM_FLG N
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_GTAT2_O.dat
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
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_80_${IB}_SORT_GTAT2_O.dat      > ${DFILT}/${NJOB}_80_SORT_GTAT2_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2_O1.dat    > ${DFILT}/${NSTEP}_${PRG}_GTART2_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTART2MAJ_O2.dat > ${DFILT}/${NSTEP}_${PRG}_GTART2MAJ_O2.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2_O3.dat    > ${DFILT}/${NSTEP}_${PRG}_GTRRT2_O3.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT2MAJ_O4.dat > ${DFILT}/${NSTEP}_${PRG}_GTRRT2MAJ_O4.dat.gz 
#-----------------------------------------------------------------------------

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

#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2_O1.dat     > ${DFILT}/${NJOB}_90_ESTC2304_GTART2_O1.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2MAJ_O2.dat  > ${DFILT}/${NJOB}_90_ESTC2304_GTART2MAJ_O2.dat.gz
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_97
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2_O1.dat
RMFIL ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTART2MAJ_O2.dat

#[004]
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
        RCL_NF        33:1 - 33:,
        RETCUR_CF     34:1 - 34:,
        RETAMT_M      35:1 - 35:,
        PLC_NT        36:1 - 36:,
        RTO_NF        37:1 - 37:,
        INT_NF        38:1 - 38:,
        RETPAY_NF     39:1 - 39:,
        RETKEY_CF     40:1 - 40:,
        RETINTAMT_M   41:1 - 41:,
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

#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2_O3.dat     > ${DFILT}/${NJOB}_90_ESTC2304_GTRRT2_O3.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_ESTC2304_GTRRT2MAJ_O4.dat  > ${DFILT}/${NJOB}_90_ESTC2304_GTRRT2MAJ_O4.dat.gz
#-----------------------------------------------------------------------------

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
BALSHEY_NF ${BALSHEY_NF}
GTE_B 0
PRC_CF 50
OVERRIDE 1
RETROCOM_FLG N
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_120_${IB}_SORT_GTAT3_O.dat
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
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_120_${IB}_SORT_GTAT3_O.dat     > ${DFILT}/${NJOB}_120_SORT_GTAT3_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTART3_O1.dat    > ${DFILT}/${NSTEP}_${PRG}_GTART3_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTART3MAJ_O2.dat > ${DFILT}/${NSTEP}_${PRG}_GTART3MAJ_O2.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT3_O3.dat    > ${DFILT}/${NSTEP}_${PRG}_GTRRT3_O3.dat.gz 
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTRRT3MAJ_O4.dat > ${DFILT}/${NSTEP}_${PRG}_GTRRT3MAJ_O4.dat.gz 
#-----------------------------------------------------------------------------

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
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3_O3.dat
RMFIL ${DFILT}/${NJOB}_130_${IB}_ESTC2304_GTRRT3MAJ_O4.dat


#############
# Entries 4 #
#############


#[004]
NSTEP=${NJOB}_160
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_GTRRT4_O5.dat 1000 1"
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


#[004]
NSTEP=${NJOB}_170
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_GTAT5_O6.dat 1000 1"
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

# ajout step pour garder les enregistrements des filiales non presentes dans l'inventaire
#  JR 01/06/2004
NSTEP=${NJOB}_178
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Extract of DLSGTAR file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I=${DFILT}/${NJOB}_011_${IB}_WRK_DLSGTAR.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/OMIT INVENTAIRE
/COPY
exit
EOF
SORT

# ajout SORT_I6 pour reintegrer les enregistrements des filiales non presentes dans l'inventaire
NSTEP=${NJOB}_180
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of DLSGTAR files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_60_${IB}_SORT_GTART1_O.dat
SORT_I2=${DFILT}/${NJOB}_100_${IB}_SORT_GTART2_O.dat
SORT_I3=${DFILT}/${NJOB}_140_${IB}_SORT_GTART3_O.dat
SORT_I4=${DFILT}/${NJOB}_160_${IB}_SORT_GTART4_O.dat
SORT_I5=${DFILT}/${NJOB}_170_${IB}_SORT_GTART5_O.dat
SORT_I6=${DFILT}/${NJOB}_178_${IB}_SORT_DLSGTAR_O.dat
#SORT_O=${ESF_DLSGTAR}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

#[004]
NSTEP=${NJOB}_181
# FILTER PERIMETER WITH PERICASE
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER RETRO WITH PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_180_${IB}_SORT_DLSGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_O.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF   24:1 - 24:,
        END_NT   25:1 - 25:,
        SEC_NF   26:1 - 26:,
        UWY_NF   27:1 - 27:,
        UW_NT    28:1 - 28:,
        PER_CTR_NF 3:1 - 3:,
        PER_END_NT 4:1 - 4:,
        PER_SEC_NF 5:1 - 5:,
        PER_UWY_NF 6:1 - 6:,
        PER_UW_NT  7:1 - 7:,
        ALLCOLS  1:1 - 71:
/joinkeys
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${EST_IADVPERICASE} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: ALLCOLS
exit
EOF
SORT

#[004]
NSTEP=${NJOB}_182
# FILTER PERIMETER WITH PERICASE
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER RETRO WITH PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_180_${IB}_SORT_DLSGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_O.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF   24:1 - 24:,
        END_NT   25:1 - 25:,
        SEC_NF   26:1 - 26:,
        UWY_NF   27:1 - 27:,
        UW_NT    28:1 - 28:,
        PER_CTR_NF 3:1 - 3:,
        PER_END_NT 4:1 - 4:,
        PER_SEC_NF 5:1 - 5:,
        PER_UWY_NF 6:1 - 6:,
        PER_UW_NT  7:1 - 7:,
        ALLCOLS  1:1 - 71:
/joinkeys
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${EST_IRDVPERICASE} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: ALLCOLS
exit
EOF
SORT

#[004]
NSTEP=${NJOB}_183
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge of DLSGTAR files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_181_${IB}_SORT_DLSGTAR_O.dat
SORT_I2=${DFILT}/${NJOB}_182_${IB}_SORT_DLSGTAR_O.dat
SORT_O=${ESF_DLSGTAR}
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_011_${IB}_WRK_DLSGTAR.dat     > ${DFILT}/${NJOB}_011_WRK_DLSGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_60_${IB}_SORT_GTART1_O.dat    > ${DFILT}/${NJOB}_60_SORT_GTART1_O.dat.gz
gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_GTART2_O.dat   > ${DFILT}/${NJOB}_100_SORT_GTART2_O.dat.gz
gzip -c ${DFILT}/${NJOB}_140_${IB}_SORT_GTART3_O.dat   > ${DFILT}/${NJOB}_140_SORT_GTART3_O.dat.gz
gzip -c ${DFILT}/${NJOB}_160_${IB}_SORT_GTART4_O.dat   > ${DFILT}/${NJOB}_160_SORT_GTART4_O.dat.gz
gzip -c ${DFILT}/${NJOB}_170_${IB}_SORT_GTART5_O.dat   > ${DFILT}/${NJOB}_170_SORT_GTART5_O.dat.gz
gzip -c ${DFILT}/${NJOB}_178_${IB}_SORT_DLSGTAR_O.dat  > ${DFILT}/${NJOB}_178_SORT_DLSGTAR_O.dat.gz
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_185
# Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_011_${IB}_WRK_DLSGTAR.dat
RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_GTART1_O.dat
RMFIL ${DFILT}/${NJOB}_100_${IB}_SORT_GTART2_O.dat
RMFIL ${DFILT}/${NJOB}_140_${IB}_SORT_GTART3_O.dat
RMFIL ${DFILT}/${NJOB}_160_${IB}_SORT_GTART4_O.dat
RMFIL ${DFILT}/${NJOB}_170_${IB}_SORT_GTART5_O.dat
RMFIL ${DFILT}/${NJOB}_178_${IB}_SORT_DLSGTAR_O.dat


# ajout step pour garder les enregistrements des filiales non presentes dans l'inventaire
#  JR 01/06/2004
NSTEP=${NJOB}_188
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Extract of DLSGTR file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I=${DFILT}/${NJOB}_012_${IB}_WRK_DLSGTR.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE  ${EST_SORT_CONDITION}
/OMIT INVENTAIRE
/COPY
exit
EOF
SORT

# ajout SORT_I6 pour reintegrer les enregistrements des filiales non presentes dans l'inventaire

NSTEP=${NJOB}_190
# Begin sort
#[004]
#-----------------------------------------------------------------------------
LIBEL="Merge of DLSGTR files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_SORT_GTRRT1_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_110_${IB}_SORT_GTRRT2_O.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_150_${IB}_SORT_GTRRT3_O.dat 1000 1"
SORT_I4="${DFILT}/${NJOB}_10_${IB}_SORT_GTRRT4_O5.dat 1000 1"
SORT_I5="${DFILT}/${NJOB}_170_${IB}_SORT_GTRRT5_O.dat 1000 1"
SORT_I6="${DFILT}/${NJOB}_188_${IB}_SORT_DLSGTR_O.dat 1000 1"
#SORT_O="${ESF_DLSGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTR.dat"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

#[004]
NSTEP=${NJOB}_191
# FILTER PERIMETER WITH PERICASE
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER RETRO WITH PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_SORT_DLSGTR.dat 1000 1"
SORT_O="${ESF_DLSGTR}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF   24:1 - 24:,
        END_NT   25:1 - 25:,
        SEC_NF   26:1 - 26:,
        UWY_NF   27:1 - 27:,
        UW_NT    28:1 - 28:,
        PER_CTR_NF 3:1 - 3:,
        PER_END_NT 4:1 - 4:,
        PER_SEC_NF 5:1 - 5:,
        PER_UWY_NF 6:1 - 6:,
        PER_UW_NT  7:1 - 7:,
        ALLCOLS  1:1 - 71:
/joinkeys
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${EST_IRDVPERICASE} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: ALLCOLS
exit
EOF
SORT

NSTEP=${NJOB}_195
# Rm of temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND

