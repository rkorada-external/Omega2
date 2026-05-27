#!/bin/ksh
#====================================================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 11.2 : MAINTENANCE EXPENSES PAID CALCULATION 
# Nom du script SHELL           : ESID3741.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 07/03/2019
# Auteur                        : L.ELFAHIM
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# SPIRA 71570 : REQ 11.02 - IFRS17- Closing schedule : new chain to calculate mainteance Expenses Paid:
#  - Calculation of Mainteance Expenses Paid
#
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#	[001] 		07/03/2019 	L.ELFAHIM 	SPIRA : 71570 		Maintenance Expenses Paid calculation
#       [002]           24/07/2019      L.DOAN          SPIRA : 77079           Generating IFRS 17 Group TL file
#	[003]  		02/01/2020      L.DOAN       	SPIRA : 79100 		REQ21.9- Manage retro dummy contracts in closing
#       [004]           03/06/2020      L.DOAN          SPIRA : 79070           Add contre partie
#       [005]           09/07/2020      L.DOAN          SPIRA : 85208           add GTL REQ11.1 of ESFD3630
#       [006]           13/10/2020     MZM             SPIRA : 85522           ADD ALL FUTURE generate AT INI to STD CLOSING
#       [007]           19/02/2021      N.DOAN          SPIRA : 85522 technical cashflow flux
#       [008]           19/10/2021      N.DOAN          SPIRA : 97767 I17 - FWH initial bookings
#       [009]           04/02/2022      HR              SPIRA : 100977 I17 - Criteria to compute Revenue / EXP / CSM
#       [010]           01/03/2022      DaD             SPIRA : 100992 Fix Bug : Change in EST / Change in EGPI MAJ Signe in STEP 30
#       [011]           08/03/2022      DaD             SPIRA : 101440 change EST_GTSII_ALL_STD
#       [012]           10/10/2022      HR              SPIRA : 106766 Revenue - endorsement management
#       [013]           30/01/2023      HR              SPIRA : 108588 Undiscounted and discounted RA booked on last endorsment
#       [013]           30/01/2023      MZZ             SPIRA : 108588 FIX ITK :Undiscounted and discounted RA booked on last endorsment
#       [014]       	14/02/2023 		HR		        SPIRA : 108616	REQ 11.06 - I17 - Revenue endorsement management
#       [015]       	06/03/2023 		HR		        SPIRA : 108973 Change in EGPI position- estimates incorrect on some retro NP - Copy
#       [016]           06/07/2023      DaD             SPIRA : 110011 add SORT GTSII with PATCAT_CT, PATTYP_CT, PRS_CF, CUR_CF
#       [017]           18/09/2023      DaD             SPIRA : 110297 add CUR_CF into SORT step 25E
#       [018]           26/11/2024      HR              SPIRA:  112201 : Modify Chg EST fix items calculation
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd


CLODAT_D=${PARM_ICLODAT_D}

#TODO date to be defined
#POS_BOOKING_X_DT="20190823"   

NORME="${NORME_CF}"

# Get input parameters


# Job Initialisation
JOBINIT


# [011]
# EST_GTSII_ALL_STD=${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3742${TYPEINV}_${CONTEXT_CT}_01_${IB}_FULL_GTSII_NO_MUWY.dat
EST_GTSII_ALL_STD=${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3742${TYPEINV}_${CONTEXT_CT}_09_${IB}_SORT_GTSII_FWD_OTHER_STD.dat


if [ ! -f ${ESF_GTSII_FWH} ]
then
        ECHO_LOG "ESF_GTSII_FWH=${ESF_GTSII_FWH}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_FWH}"

fi


NSTEP=${NJOB}_05
LIBEL="Add Norme ${NORME_CF} to FWH SII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_FWH} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_FWH.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:,
        NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:,
        PATCAT3_CT       52:1 - 52:3,
	PATTYP5_CT       53:1 - 53:5,
        PATTYP_CT        53:1 - 53:,
	ACMTRS3_NF	 124:1 -124:,
	HEAD 		 1:1 - 49:,
	TAIL		 51:1 - 124:  
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF

/CONDITION COND_FWH ( PATCAT3_CT="CSF" and PATTYP5_CT="CLACC" and  ACMTRS3_NF="7029")
/DERIVEDFIELD NEW_NORME_CF "${NORME_CF}~"
/DERIVEDFIELD END 2"~"

/OUTFILE ${SORT_O}
/INCLUDE COND_FWH
/REFORMAT HEAD, NEW_NORME_CF, TAIL, END

exit
EOF
SORT

NSTEP=${NJOB}_10
LIBEL="Filter with ${NORME_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTSII_ALL_STD} 2000 1"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_SORT_GTSII_FWH.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:,
        NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:,
        PATCAT3_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF

/CONDITION COND_I17 ( NORME_CF = "${NORME_CF}" )
/OUTFILE ${SORT_O}
/INCLUDE COND_I17
exit
EOF
SORT


#[009]
NSTEP=${NJOB}_15A
LIBEL="JOIN ESF_CSM_LC_AMORT_PATTERN Q-1..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_GTSII.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ENRICHI.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        GT_CTR_NF       8:1    -  8:,
        GT_END_NT       9:1    -  9:,
        GT_SEC_NF      10:1    - 10:,
        GT_UWY_NF      11:1    - 11:,
        GT_UW_NT       12:1    - 12:,
        CTR_NF          1:1    -  1:,
        SEC_NF          2:1    -  2:,
        UWY_NF          3:1    -  3:,
        UW_NT           4:1    -  4:,
        LC_PAT_PREV     7:1    -  7:,
        CSM_PAT_PREV    8:1    -  8:,
        FILLER1         1:1    - 124:
/JOINKEYS
        GT_CTR_NF,
        GT_SEC_NF,
        GT_UWY_NF,
        GT_UW_NT
/INFILE ${ESF_CSM_LC_AMORT_PATTERN_PREV} 1000 1 "~"
/JOINKEYS
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        LEFTSIDE:FILLER1,
        RIGHTSIDE:LC_PAT_PREV,CSM_PAT_PREV
exit
EOF
SORT


#[015]
NSTEP=${NJOB}_15B
LIBEL="JOIN ESF_CSM_LC_AMORT_PATTERN Q-1 for retro ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15A_${IB}_SORT_GTSII_ENRICHI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ENRICHI.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        GT_RETCTR_NF   24:1    -  24:,
        GT_RETEND_NT   25:1    -  25:,
        GT_RETSEC_NF   26:1    -  26:,
        GT_RETUWY_NF   27:1    -  27:,
        GT_RETUW_NT    28:1    -  28:,
        CTR_NF          1:1    -  1:,
        SEC_NF          2:1    -  2:,
        UWY_NF          3:1    -  3:,
        UW_NT           4:1    -  4:,
        CSM_PAT_PREV    8:1    -  8:,
        FILLER1         1:1    - 126:
/JOINKEYS
        GT_RETCTR_NF,
        GT_RETSEC_NF,
        GT_RETUWY_NF,
        GT_RETUW_NT
/INFILE ${ESF_CSM_LC_AMORT_PATTERN_PREV} 1000 1 "~"
/JOINKEYS
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        LEFTSIDE:FILLER1,
        RIGHTSIDE:CSM_PAT_PREV
exit
EOF
SORT

#[009]
NSTEP=${NJOB}_15C
LIBEL="Filter with ${NORME_CF}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15B_${IB}_SORT_GTSII_ENRICHI.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ENRICHI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:,
        NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:,
        PATCAT3_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

#015
NSTEP=${NJOB}_17A
LIBEL="JOIN IRDPERICASE0 AND PERIMETER RETRO FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15C_${IB}_SORT_GTSII_ENRICHI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ENRICHI.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        CTR_NF          3:1  - 3:,
        END_NT          4:1  - 4:,
        SEC_NF          5:1  - 5:,
        UWY_NF          6:1  - 6:,
        UW_NT           7:1  - 7:,
        CTRCAT_CF     107:1  - 107:,
        FILLER1         1:1  - 127:
/JOINKEYS
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/INFILE ${EST_IRDPERICASE0} 2000 1 "~"
/JOINKEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        LEFTSIDE:FILLER1,
        RIGHTSIDE:CTRCAT_CF
exit
EOF
SORT

# [016]
# NSTEP=${NJOB}_18
# LIBEL="Sort GTSII with PATCAT_CT, PATTYP_CT, PRS_CF, CUR_CF"
# SORT_WDIR=${SORTWORK}
# SORT_CMD=`CFTMP`
# SORT_I="${DFILT}/${NJOB}_17A_${IB}_SORT_GTSII_ENRICHI.dat 2000 1"
# SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ENRICHI.dat"
# INPUT_TEXT ${SORT_CMD} << EOF
# /FIELDS CUR_CF      18:1 -  18:,
#         PRS_CF      45:1 - 45:EN,
#         PATCAT_CT   52:1 - 52:,
#         PATTYP_CT   53:1 - 53:
# /KEYS   PATCAT_CT,
#         PATTYP_CT,
#         PRS_CF,
#         CUR_CF
# /OUTFILE ${SORT_O}
# exit
# EOF
# SORT

#[009]
NSTEP=${NJOB}_20
LIBEL="Generation TL des fichiers STD"
PRG=ESFC3740
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT ${CLODAT_D}
NORME_CF ${NORME_CF}
exit
EOF

export ${PRG}_LOG=${DFILT}/${PRG}.log
export ${PRG}_ANO=${DFILT}/${PRG}.ano
#export ${PRG}_SRV=''
#export ${PRG}_USR=''
#export ${PRG}_PSWD=''

export ${PRG}_PRM=${FPRM}
#export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_GTSII.dat
#export ${PRG}_I1=${DFILT}/${NJOB}_15B_${IB}_SORT_GTSII_ENRICHI.dat
export ${PRG}_I1=${DFILT}/${NJOB}_17A_${IB}_SORT_GTSII_ENRICHI.dat
export ${PRG}_I2=${ESF_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTASII_STD.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRSII_STD.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_ANO.dat
EXECPRG
#gdb $DEXE/$PRG.exe


#[018]
#NSTEP=${NJOB}_17B
#-----------------------------------------------------------------------------
#LIBEL="Contracts to exclude in change in estimates "
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`  
#SORT_I="${DFILT}/${NJOB}_17A_${IB}_SORT_GTSII_ENRICHI.dat 2000 1" 
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_EXCHGEST.dat 2000 1"   
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS CTR_NF            8:1 -  8:,
#        END_NT            9:1 -  9:EN,
#        SEC_NF           10:1 - 10:EN,
#        UWY_NF           11:1 - 11:,
#        UW_NT            12:1 - 12:EN,
#        CUR_CF           18:1 -  18:,
#        RETCTR_NF       24:1 - 24:,
#        RETEND_NT       25:1 - 25:,
#        RETSEC_NF       26:1 - 26:,
#        RTY_NF          27:1 - 27:,
#        RETUW_NT        28:1 - 28:,
#        PLC_NT          36:1 - 36:EN,
#        SEGNAT_CT       48:1 - 48:,
#        ACCRET_CF       49:1 - 49:,
#        NORME_CF         50:1 - 50:,
#        PATCAT_CT       52:1 - 52:,
#        PATTYP_CT        53:1 - 53:,
#		ACMTRS3_NF      124:1 - 124:     
#/KEYS   CTR_NF,
#        END_NT,
#        SEC_NF,
#        UWY_NF,
#        UW_NT,
#        RETCTR_NF,
#        RETEND_NT,
#        RETSEC_NF,
#        RTY_NF,
#        RETUW_NT,
#        PLC_NT 
#/CONDITION GRP1 (( ACMTRS3_NF EQ '1010' AND PATCAT_CT EQ 'DSC' AND PATTYP_CT EQ 'LKI' ) OR ( ACMTRS3_NF EQ '1051' AND PATCAT_CT EQ 'EXP' AND PATTYP_CT EQ 'EARPR' ))
#/STABLE
#/SUMMARIZE
#/INCLUDE GRP1
#/OUTFILE ${SORT_O} OVERWRITE
#/REFORMAT
# CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT
#exit
#EOF
#SORT

#014
NSTEP=${NJOB}_22A
LIBEL="SORT PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_STD}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            3:1 -  3:,
        END_NT            4:1 -  4:EN,
        SEC_NF            5:1 -  5:EN,
        UWY_NF            6:1 -  6:,
        UW_NT             7:1 -  7:EN
/KEYS   CTR_NF,
        END_NT descending,
        SEC_NF,
        UWY_NF,
        UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

#014
NSTEP=${NJOB}_22B
LIBEL="SUM PERICASE ON LAST ENDORSEMENT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_22A_${IB}_IADPERICASE_STD.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            3:1 -  3:,
        END_NT            4:1 -  4:EN,
        SEC_NF            5:1 -  5:EN,
        UWY_NF            6:1 -  6:,
        UW_NT             7:1 -  7:EN
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT


# [010]
NSTEP=${NJOB}_25A
LIBEL="GTASII reverse TRNCOD 49350, 49440, 12200, 12220, 49100, 49120, 43667, 43666, 46077, 46075, 49300, 49320, 43062, 43065, 43064, 43067, 43063, 43066"
AWK_I="${DFILT}/${NJOB}_20_${IB}_ESFC3740_GTASII_STD.dat"
AWK_O=${DFILT}/${NSTEP}_${IB}_GTASII_STD.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if (substr(\$6,3,5) == "49350" || substr(\$6,3,5) == "49440" || substr(\$6,3,5) == "12200" || substr(\$6,3,5) == "12220" || substr(\$6,3,5) == "49100" || 
        substr(\$6,3,5) == "49120" || substr(\$6,3,5) == "43667" || substr(\$6,3,5) == "43666" || substr(\$6,3,5) == "46077" || substr(\$6,3,5) == "46075" || 
        substr(\$6,3,5) == "49300" || substr(\$6,3,5) == "49320" || substr(\$6,3,5) == "43062" || substr(\$6,3,5) == "43065" || substr(\$6,3,5) == "43064" || 
        substr(\$6,3,5) == "43067" || substr(\$6,3,5) == "43063" || substr(\$6,3,5) == "43066") 
        {        
                if ( \$19 != "" )
                {
                        \$19 = sprintf("%-.3lf", -\$19);
                }
                if ( \$35 != "" )
                {
                        \$35 = sprintf("%-.3lf", -\$35);
                }
                if ( \$41 != "" )
                {
                        \$41 = sprintf("%-.3lf", -\$41);	
                }
         }
        print \$0;
        
  }
exit
EOF
AWK 

#[012] [013] split
NSTEP=${NJOB}_25B
LIBEL="SORT AND SPLIT GTASII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25A_${IB}_GTASII_STD.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_STD.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_STD_EX.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:EN,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:EN,
        TRNCOD_CF        6:1 - 6:,
        TRNCOD37         6:3 - 6:7
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        TRNCOD_CF,
        END_NT
/CONDITION COND1 (TRNCOD37 = '12121' OR TRNCOD37 = '12200' OR TRNCOD37 = '49100' OR TRNCOD37 = '43667' OR TRNCOD37 = '46077' OR TRNCOD37 = '49300'
               OR TRNCOD37 = '49350' OR TRNCOD37 = '43062' OR TRNCOD37 = '43064' OR TRNCOD37 = '43063' OR TRNCOD37 = '49340' OR TRNCOD37 = '10121'
               OR TRNCOD37 = '12220' OR TRNCOD37 = '49120' OR TRNCOD37 = '43666' OR TRNCOD37 = '46075' OR TRNCOD37 = '49320' OR TRNCOD37 = '49440'
               OR TRNCOD37 = '43065' OR TRNCOD37 = '43067' OR TRNCOD37 = '43066' OR TRNCOD37 = '49320')
/OUTFILE ${SORT_O}
/INCLUDE COND1
/OUTFILE ${SORT_O2}
/OMIT COND1
exit
EOF
SORT


#014
NSTEP=${NJOB}_25C
#-----------------------------------------------------------------------------
LIBEL="GTASII join PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25B_${IB}_SORT_GTASII_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        P_CTR_NF          3:1 -  3:,
        P_END_NT          4:1 -  4:,
        P_SEC_NF          5:1 -  5:,
        P_UWY_NF          6:1 -  6:,
        P_UW_NT           7:1 -  7:,
	FILLER1           1:1 -  7:,
        FILLER2          13:1 - 72: 
/joinkeys
        CTR_NF ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${DFILT}/${NJOB}_22B_${IB}_IADPERICASE_STD.dat 2000 1 "~"
/joinkeys
        P_CTR_NF ,
        P_SEC_NF ,
        P_UWY_NF ,
        P_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:FILLER1,CTR_NF, rightside:P_END_NT, leftside:SEC_NF,UWY_NF,UW_NT,FILLER2
exit
EOF
SORT

#014
NSTEP=${NJOB}_25D
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-INI not in pericase STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25B_${IB}_SORT_GTASII_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_STD_UNPAIRED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        P_CTR_NF          3:1 -  3:,
        P_END_NT          4:1 -  4:,
        P_SEC_NF          5:1 -  5:,
        P_UWY_NF          6:1 -  6:,
        P_UW_NT           7:1 -  7:,
        FILLER1           1:1 -  72:
/joinkeys
        CTR_NF ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${DFILT}/${NJOB}_22B_${IB}_IADPERICASE_STD.dat 2000 1 "~"
/joinkeys
        P_CTR_NF ,
        P_SEC_NF ,
        P_UWY_NF ,
        P_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:FILLER1
exit
EOF
SORT

#014 [017]
NSTEP=${NJOB}_25E
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-INI not in pericase STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25C_${IB}_SORT_GTASII_STD.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_25D_${IB}_SORT_GTASII_STD_UNPAIRED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:EN,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:EN,
        CUR_CF       18:1 -  18:,
        RETCTR_NF    24:1 - 24:,
        RETEND_NT    25:1 - 25:,
        RETSEC_NF    26:1 - 26:,
        RTY_NF       27:1 - 27:,
        RETUW_NT     28:1 - 28:,
        TRNCOD_CF     6:1 - 6:,
        PLC_NT       36:1 - 36:,
        RTO_NF       37:1 - 37:
/KEYS  CUR_CF,
       CTR_NF,
       SEC_NF,
       UWY_NF,
       UW_NT,
       RETCTR_NF,
       RETEND_NT,
       RETSEC_NF,
       RTY_NF,
       RETUW_NT,
       TRNCOD_CF,
       PLC_NT,
       RTO_NF
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT

#014
NSTEP=${NJOB}_25F
#-----------------------------------------------------------------------------
LIBEL="SUM GTASII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25E_${IB}_SORT_GTASII_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:EN,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:EN,
        RETCTR_NF    24:1 - 24:,
        RETEND_NT    25:1 - 25:,
        RETSEC_NF    26:1 - 26:,
        RTY_NF       27:1 - 27:,
        RETUW_NT     28:1 - 28:,
        TRNCOD_CF     6:1 - 6:,
        PLC_NT       36:1 - 36:,
        RTO_NF       37:1 - 37:,
		ACMAMT_M     43:1 - 43:EN 18/3,
		AMT_M        19:1 - 19:EN 18/3,
        RETAMT_M     35:1 - 35:EN 18/3,
        RETINTAMT_M  41:1 - 41:EN 18/3,
        FILLER1      1:1  - 18:,
        FILLER2      20:1 - 34:,
        FILLER3      36:1 - 40:,
        FILLER4      42:1 - 42:,
        FILLER5      44:1 - 72:
/KEYS  CTR_NF,
       SEC_NF,
       UWY_NF,
       UW_NT,
       RETCTR_NF,
       RETEND_NT,
       RETSEC_NF,
       RTY_NF,
       RETUW_NT,
       TRNCOD_CF,
       PLC_NT,
       RTO_NF
/SUMMARIZE TOTAL ACMAMT_M, TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O} overwrite
/REFORMAT FILLER1, AMT_MC, FILLER2, RETAMT_MC, FILLER3, RETINTAMT_MC, FILLER4, ACMAMT_MC, FILLER5
/STABLE
exit
EOF
SORT

#[014]
NSTEP=${NJOB}_25G
# Update balance sheet date
#-----------------------------------------------------------------------------
LIBEL="invert OI DLRGTAA File to add to SRGTE file"
AWK_I=${DFILT}/${NJOB}_25F_${IB}_SORT_GTASII_STD.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_SORT_GTASII_STD.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
                {
                        if (\$19 == "0") \$19 = "0.000"
                        if (\$35 == "0") \$35 = "0.000" 
                        if (\$41 == "0") \$41 = "0.000"
                        if (\$43 == "0") \$43 = "0.000"
                        print \$0;
                }
exit
EOF
AWK


#[013] [014] merge
NSTEP=${NJOB}_30
LIBEL="Merge GTASII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25B_${IB}_SORT_GTASII_STD_EX.dat  2000 1"
SORT_I2="${DFILT}/${NJOB}_25G_${IB}_SORT_GTASII_STD.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:EN,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:EN,
        TRNCOD_CF        6:1 - 6:
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        TRNCOD_CF,
        END_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

# [010]
NSTEP=${NJOB}_25A
LIBEL="GTRSII reverse TRNCOD 49350, 49440, 12200, 12220, 49100, 49120, 43667, 43666, 46077, 46075, 49300, 49320, 43062, 43065, 43064, 43067, 43063, 43066"
AWK_I="${DFILT}/${NJOB}_20_${IB}_ESFC3740_GTRSII_STD.dat"
AWK_O=${DFILT}/${NSTEP}_${IB}_GTRSII_STD.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if (substr(\$6,3,5) == "49350" || substr(\$6,3,5) == "49440" || substr(\$6,3,5) == "12200" || substr(\$6,3,5) == "12220" || substr(\$6,3,5) == "49100" || 
        substr(\$6,3,5) == "49120" || substr(\$6,3,5) == "43667" || substr(\$6,3,5) == "43666" || substr(\$6,3,5) == "46077" || substr(\$6,3,5) == "46075" || 
        substr(\$6,3,5) == "49300" || substr(\$6,3,5) == "49320" || substr(\$6,3,5) == "43062" || substr(\$6,3,5) == "43065" || substr(\$6,3,5) == "43064" || 
        substr(\$6,3,5) == "43067" || substr(\$6,3,5) == "43063" || substr(\$6,3,5) == "43066")  
        {
                if ( \$19 != "" )
                {
                        \$19 = sprintf("%-.3lf", -\$19);
                }
                if ( \$35 != "" )
                {
                        \$35 = sprintf("%-.3lf", -\$35);
                }
                if ( \$41 != "" )
                {
                        \$41 = sprintf("%-.3lf", -\$41);	
                }		
         }
        print \$0;
        
  }
exit
EOF
AWK 

#[012] [013] split
NSTEP=${NJOB}_25B
LIBEL="SORT AND SPLIT GTRSII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25A_${IB}_GTRSII_STD.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_STD.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_STD_EX.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:EN,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:EN,
        TRNCOD_CF        6:1 - 6:,
        TRNCOD37         6:3 - 6:7
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        TRNCOD_CF,
        END_NT
/CONDITION COND1 (TRNCOD37 = '12121' OR TRNCOD37 = '12200' OR TRNCOD37 = '49100' OR TRNCOD37 = '43667' OR TRNCOD37 = '46077' OR TRNCOD37 = '49300'
               OR TRNCOD37 = '49350' OR TRNCOD37 = '43062' OR TRNCOD37 = '43064' OR TRNCOD37 = '43063' OR TRNCOD37 = '49340' OR TRNCOD37 = '10121'
               OR TRNCOD37 = '12220' OR TRNCOD37 = '49120' OR TRNCOD37 = '43666' OR TRNCOD37 = '46075' OR TRNCOD37 = '49320' OR TRNCOD37 = '49440'
               OR TRNCOD37 = '43065' OR TRNCOD37 = '43067' OR TRNCOD37 = '43066' OR TRNCOD37 = '49320')
/OUTFILE ${SORT_O}
/INCLUDE COND1
/OUTFILE ${SORT_O2}
/OMIT COND1
exit
EOF
SORT

#014
NSTEP=${NJOB}_25C
#-----------------------------------------------------------------------------
LIBEL="GTRSII join PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25B_${IB}_SORT_GTRSII_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        P_CTR_NF          3:1 -  3:,
        P_END_NT          4:1 -  4:,
        P_SEC_NF          5:1 -  5:,
        P_UWY_NF          6:1 -  6:,
        P_UW_NT           7:1 -  7:,
	FILLER1           1:1 -  7:,
        FILLER2          13:1 - 72: 
/joinkeys
        CTR_NF ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${DFILT}/${NJOB}_22B_${IB}_IADPERICASE_STD.dat 2000 1 "~"
/joinkeys
        P_CTR_NF ,
        P_SEC_NF ,
        P_UWY_NF ,
        P_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:FILLER1,CTR_NF, rightside:P_END_NT, leftside:SEC_NF,UWY_NF,UW_NT,FILLER2
exit
EOF
SORT

#014
NSTEP=${NJOB}_25D
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-INI not in pericase STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25B_${IB}_SORT_GTRSII_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_STD_UNPAIRED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        P_CTR_NF          3:1 -  3:,
        P_END_NT          4:1 -  4:,
        P_SEC_NF          5:1 -  5:,
        P_UWY_NF          6:1 -  6:,
        P_UW_NT           7:1 -  7:,
        FILLER1           1:1 -  72:
/joinkeys
        CTR_NF ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${DFILT}/${NJOB}_22B_${IB}_IADPERICASE_STD.dat 2000 1 "~"
/joinkeys
        P_CTR_NF ,
        P_SEC_NF ,
        P_UWY_NF ,
        P_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:FILLER1
exit
EOF
SORT

#014 [017]
NSTEP=${NJOB}_25E
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-INI not in pericase STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25C_${IB}_SORT_GTRSII_STD.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_25D_${IB}_SORT_GTRSII_STD_UNPAIRED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:EN,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:EN,
        CUR_CF       18:1 -  18:,
        RETCTR_NF    24:1 - 24:,
        RETEND_NT    25:1 - 25:,
        RETSEC_NF    26:1 - 26:,
        RTY_NF       27:1 - 27:,
        RETUW_NT     28:1 - 28:,
        TRNCOD_CF     6:1 - 6:,
        PLC_NT       36:1 - 36:,
        RTO_NF       37:1 - 37:
/KEYS  CUR_CF,
       CTR_NF,
       SEC_NF,
       UWY_NF,
       UW_NT,
       RETCTR_NF,
       RETEND_NT,
       RETSEC_NF,
       RTY_NF,
       RETUW_NT,
       TRNCOD_CF,
       PLC_NT,
       RTO_NF
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT


#014
NSTEP=${NJOB}_25F
#-----------------------------------------------------------------------------
LIBEL="SUM GTRSII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25E_${IB}_SORT_GTRSII_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:EN,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:EN,
        RETCTR_NF    24:1 - 24:,
        RETEND_NT    25:1 - 25:,
        RETSEC_NF    26:1 - 26:,
        RTY_NF       27:1 - 27:,
        RETUW_NT     28:1 - 28:,
        TRNCOD_CF     6:1 - 6:,
        PLC_NT       36:1 - 36:,
        RTO_NF       37:1 - 37:,
		ACMAMT_M     43:1 - 43:EN 18/3,
		AMT_M        19:1 - 19:EN 18/3,
        RETAMT_M     35:1 - 35:EN 18/3,
        RETINTAMT_M  41:1 - 41:EN 18/3,
        FILLER1      1:1  - 18:,
        FILLER2      20:1 - 34:,
        FILLER3      36:1 - 40:,
        FILLER4      42:1 - 42:,
        FILLER5      44:1 - 72:
/KEYS  CTR_NF,
       SEC_NF,
       UWY_NF,
       UW_NT,
       RETCTR_NF,
       RETEND_NT,
       RETSEC_NF,
       RTY_NF,
       RETUW_NT,
       TRNCOD_CF,
       PLC_NT,
       RTO_NF
/SUMMARIZE TOTAL ACMAMT_M, TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O} overwrite
/REFORMAT FILLER1, AMT_MC, FILLER2, RETAMT_MC, FILLER3, RETINTAMT_MC, FILLER4, ACMAMT_MC, FILLER5
/STABLE
exit
EOF
SORT

#[014]
NSTEP=${NJOB}_25G
# Update balance sheet date
#-----------------------------------------------------------------------------
LIBEL="invert OI DLRGTAA File to add to SRGTE file"
AWK_I=${DFILT}/${NJOB}_25F_${IB}_SORT_GTRSII_STD.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_STD.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
                {
                        if (\$19 == "0") \$19 = "0.000"
                        if (\$35 == "0") \$35 = "0.000" 
                        if (\$41 == "0") \$41 = "0.000"
                        if (\$43 == "0") \$43 = "0.000"
                        print \$0;
                }
exit
EOF
AWK

#[013] merge 
## SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_STD.dat 2000 1" Enleve le SORT


NSTEP=${NJOB}_30
LIBEL="Merge GTRSII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25B_${IB}_SORT_GTRSII_STD_EX.dat  2000 1"
SORT_I2="${DFILT}/${NJOB}_25G_${IB}_SORT_GTRSII_STD.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTRSII_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:EN,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:EN,
        TRNCOD_CF        6:1 - 6:
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        TRNCOD_CF,
        END_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

JOBEND
