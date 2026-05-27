#!/bin/ksh
#====================================================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 08.01 : IFRS17 TL data generation 
# Nom du script SHELL           : ESFD3747.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 06/11/2020
# Auteur                        : L.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-906572 : Assumed contract at inception
# http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-911737 : Retro contract at inception
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#       [001]           06/11/2020      L.DOAN          SPIRA : 90492 		REQ11.6 accounting - EXP/ EARPR amount
# 	[002]		09/12/2020	L.DOAN		SPIRA : 88483		REQ 11.06 - IFRS 17 - Change rule for change in Estimates - TL generation (future receivables)		
#   [003]       29/01/2021  JYP         SPIRA : 91991       manage normes I17L/I17P
#   [004]       28/09/2021  NLD         SPIRA : 98114 : TTECLEDA/R.RETINTAMT- do not force to 0 when lerging GTL files 
#   [005]       28/09/2021  MZM         SPIRA : 98277 Local- Change in Estimates - Future Receivables not filtered on Local pericase     
#   [006]       28/09/2021  NLD         SPIRA : 98679 : fix RETINTAMT_M de written premimum
#   [007]       10/01/2022  DAD         SPIRA : 100371 : Calcul amount of Change in Estimates - Future Receivables : fix bug
#   [008]       10/01/2022  MZM         SPIRA : 101733 : Change in EST - Receivables :  add a factor (-1) for the transaction code 12121
#   [009]       14/03/2022  DaD         SPIRA : 102818 : Reverse spira 101733 
#   [010]       19/04/2022  DaD         SPIRA : 103425 : Refactor code use ratio of file ESFD3640
#   [011]	07/07/2022  JBD		Spira : 104778  Build new closing for I17S norm
#   [012] 	02/12/2022  HR		Spira : 107942  REQ 11.06 - Retro NP - Actuals premiums not taken into account in change in est receivables
#   [013]	17/02/2023  MiS		Spira : 107942  correction Actuals for FTECLEDR
#   [014]	17/02/2023  MiS		Spira : 107942  correction filter with placement
#   [015]	30/03/2023  HR		Spira : 109322  REQ 11.06 - I17 - Retro - Actuals not taken into account in Change in EST Receivables
#   [016]   24/04/2023 	DAD		SPIRA : 109322 REQ 11.06 - I17 - Retro - Actuals not taken into account in Change in EST Receivables
#   [017]   15/06/2023 	DAD		SPIRA : 109579 Generate Quaterly written premiums (actual) for pure retro NP
#   [018]   11/10/2023 	DAD		SPIRA : 110180 assign QWP to match the first transaction for retro NP 
#   [019]   30/11/2023  MZM   SPIRA:  110791 : I17 - Gaps between RA & RR view 
#   [020]   15/01/2024  HR    SPIRA:  111074 : Gaps on Chg EST fix items due to QWP
#   [021]   30/04/2024  DAD   SPIRA:  111414 : Update Key to find the right number of QWP lines 
#   [022]   26/11/2024  HR   SPIRA:  112201 : Modify Chg EST fix items calculation
#   [023]   26/11/2024  HR   SPIRA:  112789 : Change in est - future receivable corrected by spira 112201 has wrong subledger
#   [024]   07/03/2024  HR   SPIRA:  112749 : Modify Chg EST fix items calculation - Copy
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters


# Job Initialisation
JOBINIT

## TU
##ESF_OIRDVPERICASE=/scordata_aenitko2batch/ubeu/perm/T_ESFD5020_OIRDVPERICASE_I17G_POS_20210930.dat

######################################################
# REQ11.6 accounting - EXP/ EARPR amount at closing  #
######################################################


NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES " 
if [ ! -f ${ESF_RATIO_ASSUMED} ]
then
        ECHO_LOG "ESF_RATIO_ASSUMED=${ESF_RATIO_ASSUMED}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_RATIO_ASSUMED}"
fi

if [ ! -f ${ESF_RATIO_RET_P} ]
then
        ECHO_LOG "ESF_RATIO_RET_P=${ESF_RATIO_RET_P}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_RATIO_RET_P}"
fi

if [ ! -f ${ESF_RATIO_RET_NP} ]
then
        ECHO_LOG "ESF_RATIO_RET_NP=${ESF_RATIO_RET_NP}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_RATIO_RET_NP}"
fi

EST_GTASII_OTHER="${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3744${TYPEINV}_${CONTEXT_CT}_30_${IB}_GTASII_STD.dat"
EST_GTRSII_OTHER="${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3744${TYPEINV}_${CONTEXT_CT}_30_${IB}_GTRSII_STD.dat"

NORME_SUFFIX='R'

if [  $NORME_CF = I17G ] || [ $NORME_CF = I17S ] 
then
    NORME_SUFFIX='I'
else    
    if [  $NORME_CF = I17P ] 
    then 
         NORME_SUFFIX='K'
    else
        if [  $NORME_CF = I17L ] 
        then 
            NORME_SUFFIX='M'
        fi    
    fi
fi    

echo "NORME_SUFFIX = ${NORME_SUFFIX}"

#[015]
NSTEP=${NJOB}_02A
LIBEL="SORT TRERETFACCTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_TRERETFACCTR}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRERETFACCTR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            1:1 -  1:,
        END_NT            2:1 -  2:EN,
        SEC_NF            3:1 -  3:EN,
        UWY_NF            4:1 -  4:,
        UW_NT             5:1 -  5:EN,
        CTRNAT_CT         9:1 -  9:    
/KEYS   CTR_NF,
        END_NT descending,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION COND1 (CTRNAT_CT = "F")
/OUTFILE ${SORT_O}
/INCLUDE COND1
exit
EOF
SORT

#[015] [016]
NSTEP=${NJOB}_02
LIBEL="SUM TRERETFACCTR ON LAST ENDORSEMENT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_02A_${IB}_TRERETFACCTR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRERETFACCTR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            1:1 -  1:,
        END_NT            2:1 -  2:EN,
        SEC_NF            3:1 -  3:EN,
        UWY_NF            4:1 -  4:,
        UW_NT             5:1 -  5:EN
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

#[015] [016]
NSTEP=${NJOB}_03A
LIBEL="SORT RATIO_RET_P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_RATIO_RET_P}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RATIO_RET_P.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS    CTR_NF       1:1 - 1:,
           END_NT       2:1 - 2:EN,
           SEC_NF       3:1 - 3:EN,
           UWY_NF       4:1 - 4:,
           UW_NF        5:1 - 5:EN,
           RETCTR_NF    6:1 - 6:,
           RETEND_NT    7:1 - 7:,
           RETSEC_NF    8:1 - 8:,
           RTY_NF       9:1 - 9:,
           RETUW_NF     10:1 - 10:,
           FIXED_CHARGE_ACT    21:1 - 21:,
           ITD_PREM_ACT        22:1 - 22:,
           PLC_NT       11:1 - 11:EN
/KEYS      CTR_NF,
           END_NT,
           SEC_NF,
           UWY_NF,
           UW_NF,
           RETCTR_NF,
           RETEND_NT,
           RETSEC_NF,
           RTY_NF,
           RETUW_NF,
           PLC_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

# [016]
NSTEP=${NJOB}_03B
LIBEL="JOIN RATIO_RET_P and TRERETFACCTR ON LAST ENDORSEMENT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03A_${IB}_RATIO_RET_P.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RATIO_RET_P.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF       1:1 - 1:,
        END_NT       2:1 - 2:,
        SEC_NF       3:1 - 3:,
        UWY_NF       4:1 - 4:,
        UW_NT        5:1 - 5:,
        P_CTR_NF     1:1 -  1:,
        P_END_NT     2:1 -  2:,
        P_SEC_NF     3:1 -  3:,
        P_UWY_NF     4:1 -  4:,
        P_UW_NT      5:1 -  5:,
        FILLER1      3:1 -  32:
/joinkeys
    CTR_NF,
    SEC_NF,
    UWY_NF,
    UW_NT
/INFILE ${DFILT}/${NJOB}_02_${IB}_TRERETFACCTR.dat 2000 1 "~"
/joinkeys
    P_CTR_NF,
    P_SEC_NF,
    P_UWY_NF,
    P_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
    leftside:CTR_NF, rightside:P_END_NT, leftside:FILLER1
exit
EOF
SORT

#[015] [016]
NSTEP=${NJOB}_03
LIBEL="SUM RATIO_RET_P ON LAST ENDORSEMENT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03B_${IB}_RATIO_RET_P.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RATIO_RET_P.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS    CTR_NF       1:1 - 1:,
           END_NT       2:1 - 2:EN,
           SEC_NF       3:1 - 3:EN,
           UWY_NF       4:1 - 4:,
           UW_NF        5:1 - 5:EN,
           RETCTR_NF    6:1 - 6:,
           RETEND_NT    7:1 - 7:,
           RETSEC_NF    8:1 - 8:,
           RTY_NF       9:1 - 9:,
           RETUW_NF     10:1 - 10:,
           FIXED_CHARGE_ACT    21:1 - 21:EN 19/3,
           ITD_PREM_ACT        22:1 - 22:EN 19/3,
           PLC_NT       11:1 - 11:EN
/KEYS      CTR_NF,
           SEC_NF,
           UWY_NF,
           UW_NF,
           RETCTR_NF,
           RETEND_NT,
           RETSEC_NF,
           RTY_NF,
           RETUW_NF,
           PLC_NT
/SUMMARIZE TOTAL FIXED_CHARGE_ACT, TOTAL ITD_PREM_ACT
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[024]
NSTEP=${NJOB}_04
LIBEL="SUM RATIO_RET_P ON LAST ENDORSEMENT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03A_${IB}_RATIO_RET_P.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RATIO_RET_P.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS    CTR_NF       1:1 - 1:,
           END_NT       2:1 - 2:EN,
           SEC_NF       3:1 - 3:EN,
           UWY_NF       4:1 - 4:,
           UW_NF        5:1 - 5:EN,
           RETCTR_NF    6:1 - 6:,
           RETEND_NT    7:1 - 7:,
           RETSEC_NF    8:1 - 8:,
           RTY_NF       9:1 - 9:,
           RETUW_NF     10:1 - 10:,
           FIXED_CHARGE_ACT    21:1 - 21:EN 19/3,
           ITD_PREM_ACT        22:1 - 22:EN 19/3,
           PLC_NT       11:1 - 11:EN
/KEYS      CTR_NF,
           SEC_NF,
           UWY_NF,
           UW_NF,
           RETCTR_NF,
           RETEND_NT,
           RETSEC_NF,
           RTY_NF,
           RETUW_NF,
           PLC_NT
/SUMMARIZE TOTAL FIXED_CHARGE_ACT, TOTAL ITD_PREM_ACT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_05
LIBEL="Split GTASII by TRNCODE 112121"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTASII_OTHER} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_ASS_O.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RET_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:2 -  6:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:

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

/CONDITION GRP_ASS ( TRNCOD_CF = "112121${NORME_SUFFIX}" and RETCTR_NF = "" )
/CONDITION GRP_RET ( TRNCOD_CF = "112121${NORME_SUFFIX}" and RETCTR_NF != "" )

/OUTFILE ${SORT_O}
/INCLUDE GRP_ASS

/OUTFILE ${SORT_O2}
/INCLUDE GRP_RET

exit
EOF
SORT

#[020] no join on END_NT
NSTEP=${NJOB}_10
LIBEL="GTASII Join of Quaterly written premiums (actual) assumed"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTASII_ASS_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_ASS_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    FILLER1_F1    	1:1 - 73:,
    CTR_NF_F2       1:1 - 1:,
    END_NT_F2       2:1 - 2:,
    SEC_NF_F2       3:1 - 3:,
    UWY_NF_F2       4:1 - 4:,
    UW_NF_F2        5:1 - 5:,
    FIXED_CHARGE_ACT    15:1 - 15:,
    ITD_PREM_ACT        16:1 - 16:
/JOINKEYS 
    CTR_NF_F1,
    SEC_NF_F1,
    UWY_NF_F1,
    UW_NT_F1            
/INFILE ${ESF_RATIO_ASSUMED} 2000 1 "~"                 
/JOINKEYS 
    CTR_NF_F2,
    SEC_NF_F2,
    UWY_NF_F2,          
    UW_NF_F2           

/OUTFILE ${SORT_O} overwrite
/REFORMAT
    leftside:FILLER1_F1,
    rightside:FIXED_CHARGE_ACT,ITD_PREM_ACT
exit
EOF
SORT

#[022]
NSTEP=${NJOB}_11A
LIBEL="QWP GTASII JOIN RATIO ASSUMED"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTASII_ASS_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_ASSUMED_QWP.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    FILLER1_F1          1:1 - 73:,
    CTR_NF_F2       1:1 - 1:,
    END_NT_F2       2:1 - 2:,
    SEC_NF_F2       3:1 - 3:,
    UWY_NF_F2       4:1 - 4:,
    UW_NF_F2        5:1 - 5:,
    FIXED_CHARGE_ACT    15:1 - 15:,
    ITD_PREM_ACT        16:1 - 16:,
    FILLER2        1:1 - 24:
/JOINKEYS
    CTR_NF_F1,
    SEC_NF_F1,
    UWY_NF_F1,
    UW_NT_F1
/INFILE ${ESF_RATIO_ASSUMED} 2000 1 "~"  
/JOINKEYS
    CTR_NF_F2,
    SEC_NF_F2,
    UWY_NF_F2,
    UW_NF_F2
/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
    rightside:FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_11B
#-----------------------------------------------------------------------------
LIBEL="MERGE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_11A_${IB}_IVR_CHR_STD_RATIO_ASSUMED_QWP.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_ASSUMED_QWP.dat 2000 1"   
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 - 1:,
    END_NT       2:1 - 2:,
    SEC_NF       3:1 - 3:,
    UWY_NF       4:1 - 4:,
    UW_NT        5:1 - 5:,
    FIXED_CHARGE_ACT    15:1 - 15:EN,
    ITD_PREM_ACT        16:1 - 16:EN,
	CSM_PAT_PREV  22:1 - 22:EN,
	LC_PAT_PREV   24:1 - 24:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION GRP1 ( ( FIXED_CHARGE_ACT NE 0 OR ITD_PREM_ACT NE 0 ) AND ( CSM_PAT_PREV NE 1 OR LC_PAT_PREV NE 1 ) )
/INCLUDE GRP1
/OUTFILE ${SORT_O} OVERWRITE 
exit
EOF
SORT

#[23] colonne ESB 8
NSTEP=${NJOB}_11C
LIBEL="JOIN IRDPERICASE0 AND PERIMETER RETRO FILE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_11B_${IB}_IVR_CHR_STD_RATIO_ASSUMED_QWP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_ASS_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF       1:1 - 1:,
        END_NT       2:1 - 2:,
        SEC_NF       3:1 - 3:,
        UWY_NF       4:1 - 4:,
        UW_NT        5:1 - 5:,
        PERCTR_NF    3:1 - 3:,
        PEREND_NT    4:1 - 4:,
        PERSEC_NF    5:1 - 5:,
        PERUWY_NF    6:1 - 6:,
        PERUW_NT     7:1 - 7:,
        F1           1:1 - 1:,
        F1B          8:1 - 8:,
        F6           1:1 - 5:,
        F7           23:1 - 23:,
        FIXED_CHARGE_ACT    15:1 - 15:,
        ITD_PREM_ACT        16:1 - 16:
/JOINKEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EST_IADPERICASE_STD} 2000 1 "~"
/JOINKEYS
        PERCTR_NF,
        PEREND_NT,
        PERSEC_NF,
        PERUWY_NF,
        PERUW_NT
/DERIVEDFIELD EMPTY_FIELD "~"
/DERIVEDFIELD F2 "${ICLODAT_YEA}~"
/DERIVEDFIELD F3 "${ICLODAT_MTH}~"
/DERIVEDFIELD F4 "${ICLODAT_DAY}~"
/DERIVEDFIELD F5 "1112121${NORME_SUFFIX}~1212121${NORME_SUFFIX}~"
/DERIVEDFIELD F8 "0.000~~~~~~~~~~~~~~~~0.000~~~~~~0.000~~0.000~~~~~~~~~~~~~~${NORME_CF}GTA~~~~~~~~~~~~~~~6500~~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        RIGHTSIDE:F1,F1B,LEFTSIDE:F2,F3,F4,F5,F6,F2,F2,F3,F3,EMPTY_FIELD,
        RIGHTSIDE:F7,
        LEFTSIDE:F8,FIXED_CHARGE_ACT,ITD_PREM_ACT
exit
EOF
SORT

#[016]
NSTEP=${NJOB}_15A
#-----------------------------------------------------------------------------
LIBEL="GTASII RET P join TRERETFACCTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTASII_RET_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        P_CTR_NF          1:1 -  1:,
        P_END_NT          2:1 -  2:,
        P_SEC_NF          3:1 -  3:,
        P_UWY_NF          4:1 -  4:,
        P_UW_NT           5:1 -  5:,
        FILLER1           1:1 -  7:,
        FILLER2           13:1 -  73:
/joinkeys
        CTR_NF ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${DFILT}/${NJOB}_02_${IB}_TRERETFACCTR.dat 2000 1 "~"
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

#[016]
NSTEP=${NJOB}_15B
LIBEL="GTASII RET P summarize"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15A_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    AMT_M           19:1 - 19:EN,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    PLC_NT           36:1 - 36:EN
/KEYS   
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
    PLC_NT
/SUMMARIZE TOTAL AMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[016]
NSTEP=${NJOB}_15C
#-----------------------------------------------------------------------------
LIBEL="GTRSII RETP join TRERETFACCTR exclude"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTASII_RET_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        P_CTR_NF          1:1 -  1:,
        P_END_NT          2:1 -  2:,
        P_SEC_NF          3:1 -  3:,
        P_UWY_NF          4:1 -  4:,
        P_UW_NT           5:1 -  5:,
        FILLER1           1:1 -  73:
/joinkeys
        CTR_NF ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${DFILT}/${NJOB}_02_${IB}_TRERETFACCTR.dat 2000 1 "~"
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

#[016]
#[020] no join on END_NT
NSTEP=${NJOB}_16A
LIBEL="GTASII Join RATIO_RET_P ON LAST ENDORSEMENT of Quaterly written premiums (actual) retro P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15B_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1       36:1 - 36:,
    CTR_NF_F2       1:1 - 1:,
    END_NT_F2       2:1 - 2:,
    SEC_NF_F2       3:1 - 3:,
    UWY_NF_F2       4:1 - 4:,
    UW_NF_F2        5:1 - 5:,
    RETCTR_NF_F2       6:1 - 6:,
    RETEND_NT_F2       7:1 - 7:,
    RETSEC_NF_F2       8:1 - 8:,
    RTY_NF_F2          9:1 - 9:,
    RETUW_NF_F2        10:1 - 10:,
    FIXED_CHARGE_ACT    21:1 - 21:,
    ITD_PREM_ACT        22:1 - 22:,
    PLC_NT_F2           11:1 - 11:
/JOINKEYS 
    CTR_NF_F1,
    SEC_NF_F1,
    UWY_NF_F1,
    UW_NT_F1,
    RETCTR_NF_F1,
    RETEND_NT_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    RETUW_NT_F1,
    PLC_NT_F1            
/INFILE ${DFILT}/${NJOB}_03_${IB}_RATIO_RET_P.dat 2000 1 "~"                 
/JOINKEYS 
    CTR_NF_F2,
    SEC_NF_F2,
    UWY_NF_F2,          
    UW_NF_F2,
    RETCTR_NF_F2,
    RETEND_NT_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    RETUW_NF_F2,
    PLC_NT_F2

/OUTFILE ${SORT_O} overwrite
/REFORMAT
    leftside:FILLER1_F1,
    rightside:FIXED_CHARGE_ACT,ITD_PREM_ACT
exit
EOF
SORT 

#[016]
#[020] no join on END_NT
NSTEP=${NJOB}_16B
LIBEL="GTASII Join ESF_RATIO_RET_P of Quaterly written premiums (actual) retro P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15C_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1       36:1 - 36:,
    CTR_NF_F2       1:1 - 1:,
    END_NT_F2       2:1 - 2:,
    SEC_NF_F2       3:1 - 3:,
    UWY_NF_F2       4:1 - 4:,
    UW_NF_F2        5:1 - 5:,
    RETCTR_NF_F2       6:1 - 6:,
    RETEND_NT_F2       7:1 - 7:,
    RETSEC_NF_F2       8:1 - 8:,
    RTY_NF_F2          9:1 - 9:,
    RETUW_NF_F2        10:1 - 10:,
    FIXED_CHARGE_ACT    21:1 - 21:,
    ITD_PREM_ACT        22:1 - 22:,
    PLC_NT_F2           11:1 - 11:
/JOINKEYS 
    CTR_NF_F1,
    SEC_NF_F1,
    UWY_NF_F1,
    UW_NT_F1,
    RETCTR_NF_F1,
    RETEND_NT_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    RETUW_NT_F1,
    PLC_NT_F1            
/INFILE ${DFILT}/${NJOB}_04_${IB}_RATIO_RET_P.dat 2000 1 "~"                 
/JOINKEYS 
    CTR_NF_F2,
    SEC_NF_F2,
    UWY_NF_F2,          
    UW_NF_F2,
    RETCTR_NF_F2,
    RETEND_NT_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    RETUW_NF_F2,
    PLC_NT_F2

/OUTFILE ${SORT_O} overwrite
/REFORMAT
    leftside:FILLER1_F1,
    rightside:FIXED_CHARGE_ACT,ITD_PREM_ACT
exit
EOF
SORT 

#[024]
NSTEP=${NJOB}_16C
LIBEL="GTRSII Join of Quaterly written premiums (actual) retro P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_04_${IB}_RATIO_RET_P.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RATIO_RET_P.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       1:1 -  1:,
    END_NT_F1       2:1 -  2:,
    SEC_NF_F1       3:1 -  3:,
    UWY_NF_F1       4:1 -  4:,
    UW_NT_F1        5:1 -  5:,
    RETCTR_NF_F1        6:1 - 6:,
    RETEND_NT_F1        7:1 - 7:,
    RETSEC_NF_F1        8:1 - 8:,
    RTY_NF_F1           9:1 - 9:,
    RETUW_NT_F1         10:1 - 10:,
    PLC_NT_F1       11:1 - 11:,
    CTR_NF_F2       1:1 - 1:,
    END_NT_F2       2:1 - 2:,
    SEC_NF_F2       3:1 - 3:,
    UWY_NF_F2       4:1 - 4:,
    UW_NF_F2        5:1 - 5:,
    RETCTR_NF_F2       6:1 - 6:,
    RETEND_NT_F2       7:1 - 7:,
    RETSEC_NF_F2       8:1 - 8:,
    RTY_NF_F2          9:1 - 9:,
    RETUW_NF_F2        10:1 - 10:,
    FIXED_CHARGE_ACT    21:1 - 21:,
    ITD_PREM_ACT        22:1 - 22:,
    PLC_NT_F2           11:1 - 11:,
    FILLER1_F2    	1:1 - 32:
/JOINKEYS 
    CTR_NF_F2,
    SEC_NF_F2,
    UWY_NF_F2,          
    UW_NF_F2,
    RETCTR_NF_F2,
    RETEND_NT_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    RETUW_NF_F2,
    PLC_NT_F2
/INFILE ${DFILT}/${NJOB}_03_${IB}_RATIO_RET_P.dat 2000 1 "~"                 
/JOINKEYS 
    CTR_NF_F1,
    SEC_NF_F1,
    UWY_NF_F1,
    UW_NT_F1,
    RETCTR_NF_F1,
    RETEND_NT_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    RETUW_NT_F1,
    PLC_NT_F1  
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
    leftside:FILLER1_F2
exit
EOF
SORT 

#[024]
NSTEP=${NJOB}_16D
LIBEL="GTASII RET P summarize"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15B_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_15C_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    AMT_M           19:1 - 19:EN,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    PLC_NT           36:1 - 36:EN
/KEYS   
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
    PLC_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[022]
NSTEP=${NJOB}_17A
LIBEL="GTASII Join RATIO_RET_P ON LAST ENDORSEMENT of Quaterly written premiums (actual) retro P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16D_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1       36:1 - 36:,
    CTR_NF_F2       1:1 - 1:,
    END_NT_F2       2:1 - 2:,
    SEC_NF_F2       3:1 - 3:,
    UWY_NF_F2       4:1 - 4:,
    UW_NF_F2        5:1 - 5:,
    RETCTR_NF_F2       6:1 - 6:,
    RETEND_NT_F2       7:1 - 7:,
    RETSEC_NF_F2       8:1 - 8:,
    RTY_NF_F2          9:1 - 9:,
    RETUW_NF_F2        10:1 - 10:,
    FIXED_CHARGE_ACT    21:1 - 21:,
    ITD_PREM_ACT        22:1 - 22:,
    PLC_NT_F2           11:1 - 11:,
	FILLER2             1:1 - 32:
/JOINKEYS 
    CTR_NF_F1,
    SEC_NF_F1,
    UWY_NF_F1,
    UW_NT_F1,
    RETCTR_NF_F1,
    RETEND_NT_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    RETUW_NT_F1,
    PLC_NT_F1            
/INFILE ${DFILT}/${NJOB}_03_${IB}_RATIO_RET_P.dat 2000 1 "~"                 
/JOINKEYS 
    CTR_NF_F2,
    SEC_NF_F2,
    UWY_NF_F2,          
    UW_NF_F2,
    RETCTR_NF_F2,
    RETEND_NT_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    RETUW_NF_F2,
    PLC_NT_F2

/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
    rightside:FILLER2
exit
EOF
SORT 

#[022]
NSTEP=${NJOB}_17B
LIBEL="GTASII Join ESF_RATIO_RET_P of Quaterly written premiums (actual) retro P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16D_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1       36:1 - 36:,
    CTR_NF_F2       1:1 - 1:,
    END_NT_F2       2:1 - 2:,
    SEC_NF_F2       3:1 - 3:,
    UWY_NF_F2       4:1 - 4:,
    UW_NF_F2        5:1 - 5:,
    RETCTR_NF_F2       6:1 - 6:,
    RETEND_NT_F2       7:1 - 7:,
    RETSEC_NF_F2       8:1 - 8:,
    RTY_NF_F2          9:1 - 9:,
    RETUW_NF_F2        10:1 - 10:,
    FIXED_CHARGE_ACT    21:1 - 21:,
    ITD_PREM_ACT        22:1 - 22:,
    PLC_NT_F2           11:1 - 11:,
	FILLER2             1:1 - 32:
/JOINKEYS 
    CTR_NF_F1,
    SEC_NF_F1,
    UWY_NF_F1,
    UW_NT_F1,
    RETCTR_NF_F1,
    RETEND_NT_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    RETUW_NT_F1,
    PLC_NT_F1            
/INFILE ${DFILT}/${NJOB}_16C_${IB}_RATIO_RET_P.dat 2000 1 "~"                 
/JOINKEYS 
    CTR_NF_F2,
    SEC_NF_F2,
    UWY_NF_F2,          
    UW_NF_F2,
    RETCTR_NF_F2,
    RETEND_NT_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    RETUW_NF_F2,
    PLC_NT_F2

/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
    rightside:FILLER2
exit
EOF
SORT 

#[022]
NSTEP=${NJOB}_18A
#-----------------------------------------------------------------------------
LIBEL="QWP GTASII RET P MERGE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_17A_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1" 
SORT_I2="${DFILT}/${NJOB}_17B_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat  2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1"   
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 - 1:,
    END_NT       2:1 - 2:,
    SEC_NF       3:1 - 3:,
    UWY_NF       4:1 - 4:,
    UW_NT        5:1 - 5:,
    RETCTR_NF       6:1 - 6:,
    RETEND_NT       7:1 - 7:,
    RETSEC_NF       8:1 - 8:,
    RTY_NF          9:1 - 9:,
    RETUW_NT        10:1 - 10:,
    PLC_NT          11:1 - 11:,
    FIXED_CHARGE_ACT    21:1 - 21:EN,
    ITD_PREM_ACT        22:1 - 22:EN,
	CSM_PAT_PREV        30:1 - 30:EN,
	LC_PAT_PREV         32:1 - 32:EN
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
        PLC_NT 
/CONDITION GRP1 ( ( FIXED_CHARGE_ACT NE 0 OR ITD_PREM_ACT NE 0 ) AND ( CSM_PAT_PREV NE 1 OR LC_PAT_PREV NE 1 ) )
/STABLE
/SUMMARIZE
/INCLUDE GRP1
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

NSTEP=${NJOB}_18B
LIBEL="QWP GTASII JOIN RATIO RET P IRDPERICASE0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_18A_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
       RETCTR_NF       6:1 - 6:,
       RETEND_NT       7:1 - 7:,
       RETSEC_NF       8:1 - 8:,
       RTY_NF          9:1 - 9:,
       RETUW_NT        10:1 - 10:,
       PRETCTR_NF       3:1 - 3:,
       PRETEND_NT       4:1 - 4:,
       PRETSEC_NF       5:1 - 5:,
       PRTY_NF          6:1 - 6:,
       PRETUW_NT        7:1 - 7:,
       F1           1:1 - 1:,
       F1B          8:1 - 8:,
       F6           6:1 - 10:,
       F7           51:1 - 51:,
       F10          1:1 - 5:,
       FIXED_CHARGE_ACT    21:1 - 21:,
       ITD_PREM_ACT        22:1 - 22:
/JOINKEYS
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/INFILE ${EST_IRDPERICASE0} 2000 1 "~"
/JOINKEYS
        PRETCTR_NF,
        PRETEND_NT,
        PRETSEC_NF,
        PRTY_NF,
        PRETUW_NT
/DERIVEDFIELD EMPTY_FIELD "~"
/DERIVEDFIELD F2 "${ICLODAT_YEA}~"
/DERIVEDFIELD F3 "${ICLODAT_MTH}~"
/DERIVEDFIELD F4 "${ICLODAT_DAY}~"
/DERIVEDFIELD F5 "2112121${NORME_SUFFIX}~2212121${NORME_SUFFIX}~"
/DERIVEDFIELD F8 "0.000~~~~~~0.000~~0.000~~~~~~~~~~~~~~${NORME_CF}GTA~~~~~~~~~~~~~~~6500~~"
/DERIVEDFIELD F9 "~~0~~~~~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        RIGHTSIDE:F1,F1B,LEFTSIDE:F2,F3,F4,F5,F10,F2,F2,F3,F3,F9,F6,F2,F2,F3,F3,EMPTY_FIELD,
        RIGHTSIDE:F7,
        LEFTSIDE:F8,FIXED_CHARGE_ACT,ITD_PREM_ACT
exit
EOF
SORT

NSTEP=${NJOB}_18C
LIBEL="QWP GTASII JOIN RATIO RET P IADPERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_18B_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RETP_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF       8:1 - 8:,
        END_NT       9:1 - 9:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:,
        PERCTR_NF    3:1 - 3:,
        PEREND_NT    4:1 - 4:,
        PERSEC_NF    5:1 - 5:,
        PERUWY_NF    6:1 - 6:,
        PERUW_NT     7:1 - 7:,
        F1           23:1 - 23:,
        FILLER1      1:1 - 17:,
        FILLER2      19:1 - 75:
/JOINKEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EST_IADPERICASE_STD} 2000 1 "~"
/JOINKEYS
        PERCTR_NF,
        PEREND_NT,
        PERSEC_NF,
        PERUWY_NF,
        PERUW_NT
/DERIVEDFIELD EMPTY_FIELD "~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        LEFTSIDE:FILLER1,RIGHTSIDE:F1,
        LEFTSIDE:FILLER2
exit
EOF
SORT

#[012] no more RETUW on join 
#[020] no join on END_NT
NSTEP=${NJOB}_20
LIBEL="GTASII Join of Quaterly written premiums (actual) retro NP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTASII_RET_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RETNP_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1           36:1 - 36:,
    RETCTR_NF_F2       1:1 - 1:,
    RETEND_NT_F2       2:1 - 2:,
    RETSEC_NF_F2       3:1 - 3:,
    RTY_NF_F2          4:1 - 4:,
    RETUW_NF_F2        5:1 - 5:,
    FIXED_CHARGE_ACT    16:1 - 16:,
    ITD_PREM_ACT        17:1 - 17:,
    PLC_NT_F2          6:1 - 6:
/JOINKEYS 
    RETCTR_NF_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    PLC_NT_F1
/INFILE ${ESF_RATIO_RET_NP} 2000 1 "~"                 
/JOINKEYS 
    RETCTR_NF_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    PLC_NT_F2
/OUTFILE ${SORT_O} overwrite
/REFORMAT
    leftside:FILLER1_F1,
    rightside:FIXED_CHARGE_ACT,ITD_PREM_ACT
exit
EOF
SORT 

#[022]
NSTEP=${NJOB}_20B
LIBEL="GTASII Join of Quaterly written premiums (actual) retro NP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTASII_RET_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_RET_NP_QWP.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1           36:1 - 36:,
    RETCTR_NF_F2       1:1 - 1:,
    RETEND_NT_F2       2:1 - 2:,
    RETSEC_NF_F2       3:1 - 3:,
    RTY_NF_F2          4:1 - 4:,
    RETUW_NF_F2        5:1 - 5:,
    FIXED_CHARGE_ACT    16:1 - 16:,
    ITD_PREM_ACT        17:1 - 17:,
    PLC_NT_F2          6:1 - 6:,
	FILLER2            1:1 - 25:
/JOINKEYS 
    RETCTR_NF_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    PLC_NT_F1
/INFILE ${ESF_RATIO_RET_NP} 2000 1 "~"                 
/JOINKEYS 
    RETCTR_NF_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    PLC_NT_F2
/JOIN UNPAIRED RIGHTSIDE ONLY	
/OUTFILE ${SORT_O} overwrite
/REFORMAT
    rightside:FILLER2
exit
EOF
SORT 

NSTEP=${NJOB}_20C
#-----------------------------------------------------------------------------
LIBEL="QWP GTASII RET NP RATIO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_20B_${IB}_IVR_CHR_STD_RATIO_RET_NP_QWP.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_RET_NP_QWP.dat 2000 1"   
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF       1:1 - 1:,
    RETEND_NT       2:1 - 2:,
    RETSEC_NF       3:1 - 3:,
    RTY_NF          4:1 - 4:,
    RETUW_NT        5:1 - 5:,
    PLC_NT          6:1 - 6:,
    FIXED_CHARGE_ACT    16:1 - 16:EN,
    ITD_PREM_ACT        17:1 - 17:EN,
	CSM_PAT_PREV        23:1 - 23:EN
/KEYS   RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        PLC_NT 
/CONDITION GRP1 ( ( FIXED_CHARGE_ACT NE 0 OR ITD_PREM_ACT NE 0 ) AND CSM_PAT_PREV NE 1 )
/STABLE
/SUMMARIZE
/INCLUDE GRP1
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

NSTEP=${NJOB}_20D
LIBEL="QWP GTASII RET NP JOIN IRDPERICASE0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20C_${IB}_IVR_CHR_STD_RATIO_RET_NP_QWP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RETNP_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
       RETCTR_NF       1:1 - 1:,
       RETEND_NT       2:1 - 2:,
       RETSEC_NF       3:1 - 3:,
       RTY_NF          4:1 - 4:,
       RETUW_NT        5:1 - 5:,
       PRETCTR_NF       3:1 - 3:,
       PRETEND_NT       4:1 - 4:,
       PRETSEC_NF       5:1 - 5:,
       PRTY_NF          6:1 - 6:,
       PRETUW_NT        7:1 - 7:,
       F1           1:1 - 1:,
       F1B          8:1 - 8:,
       F6           1:1 - 5:,
       F7           51:1 - 51:,
       FIXED_CHARGE_ACT    16:1 - 16:,
       ITD_PREM_ACT        17:1 - 17:
/JOINKEYS
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/INFILE ${EST_IRDPERICASE0} 2000 1 "~"
/JOINKEYS
        PRETCTR_NF,
        PRETEND_NT,
        PRETSEC_NF,
        PRTY_NF,
        PRETUW_NT
/DERIVEDFIELD EMPTY_FIELD "~"
/DERIVEDFIELD F2 "${ICLODAT_YEA}~"
/DERIVEDFIELD F3 "${ICLODAT_MTH}~"
/DERIVEDFIELD F4 "${ICLODAT_DAY}~"
/DERIVEDFIELD F5 "2112121${NORME_SUFFIX}~2212121${NORME_SUFFIX}~~~~~~"
/DERIVEDFIELD F8 "0.000~~~~~~0.000~~0.000~~~~~~~~~~~~~~${NORME_CF}GTA~~~~~~~~~~~~~~~6500~~"
/DERIVEDFIELD F9 "~~0~~~~~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        RIGHTSIDE:F1,F1B,LEFTSIDE:F2,F3,F4,F5,F2,F2,F3,F3,F9,F6,F2,F2,F3,F3,EMPTY_FIELD,
        RIGHTSIDE:F7,
        LEFTSIDE:F8,FIXED_CHARGE_ACT,ITD_PREM_ACT,EMPTY_FIELD
exit
EOF
SORT

# [017]
# NSTEP=${NJOB}_21
# LIBEL="Quaterly written premiums (actual) Pure NP"
# SORT_WDIR=${SORTWORK}
# SORT_CMD=`CFTMP`
# SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_GTASII_RETNP_O.dat 2000 1"
# SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RETNP_O.dat 2000 1"
# INPUT_TEXT $SORT_CMD <<EOF
# /FIELDS 
#     CTR_NF_F1       8:1 -  8:,
#     END_NT_F1       9:1 -  9:,
#     SEC_NF_F1       10:1 - 10:,
#     UWY_NF_F1       11:1 - 11:,
#     UW_NT_F1        12:1 - 12:           
# /CONDITION PURE_NP ( CTR_NF_F1 = "" AND END_NT_F1 = "" AND SEC_NF_F1 = "" AND  UWY_NF_F1 = "" AND UW_NT_F1 = "")
# /OUTFILE ${SORT_O} overwrite
# /INCLUDE PURE_NP
# /COPY
# exit
# EOF
# SORT 

# [018]
##[019] Ajout du PLC dans la Cle du cumul 
# [021]
NSTEP=${NJOB}_21
LIBEL="Quaterly written premiums (actual) Pure NP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_GTASII_RETNP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RETNP_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    SSD_CF          1:1 -  1:,
    ESB_CF          2:1 -  2:,
    TRNCOD_CF       6:1 -  6:,
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    RETCTR_NF_F1    24:1 - 24:,
    RETEND_NT_F1    25:1 - 25:,
    RETSEC_NF_F1    26:1 - 26:,
    RTY_NF_F1       27:1 - 27:,
    RETUW_NT_F1     28:1 - 28:,
    PLC_NT_F1       36:1 - 36:,  
    FILLER1_F1    	1:1 - 73:
/KEYS
    SSD_CF,
    ESB_CF,
    TRNCOD_CF,
    RETCTR_NF_F1,
    RETEND_NT_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    RETUW_NT_F1,
    PLC_NT_F1
/SUMMARIZE 
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT 

#[022]
NSTEP=${NJOB}_25
LIBEL="Merge assume and retro GTASII Quaterly written premiums (actual)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_GTASII_ASS_O.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_16A_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_16B_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_21_${IB}_SORT_GTASII_RETNP_O.dat 2000 1"
SORT_I5="${DFILT}/${NJOB}_11C_${IB}_SORT_GTASII_ASS_O.dat 2000 1"
SORT_I6="${DFILT}/${NJOB}_18C_${IB}_SORT_GTASII_RETP_O.dat 2000 1"
SORT_I7="${DFILT}/${NJOB}_20D_${IB}_SORT_GTASII_RETNP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RATIO_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    AMT_M           19:1 - 19:EN,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    PLC_NT           36:1 - 36:EN,
	FIXED_CHARGE_ACT 74:1 - 74:EN,
	ITD_PREM_ACT     75:1 - 75:EN
/KEYS   
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
    PLC_NT
/SUMMARIZE TOTAL AMT_M, TOTAL FIXED_CHARGE_ACT, TOTAL ITD_PREM_ACT
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_30
LIBEL="GTASII generation amout of Quaterly written premiums (actual)"
AWK_I="${DFILT}/${NJOB}_25_${IB}_SORT_GTASII_RATIO_O.dat "
AWK_O="${DFILT}/${NSTEP}_${IB}_SORT_GTASII_RATIO_O.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
    AMT_M = 0;
    RETAMT_M = 0;
    RETINTAMT_M = 0;

    AMT_M = \$74 + \$75;

    if ( \$24 != "" )
    {
        RETAMT_M = \$74 + \$75;
        RETINTAMT_M = \$74 + \$75;
    }

    \$19 = sprintf("%.3lf", AMT_M);
    \$35 = sprintf("%.3lf", RETAMT_M);
    \$41 = sprintf("%.3lf", RETINTAMT_M);

    print \$0;
}
exit
EOF
AWK


NSTEP=${NJOB}_35
LIBEL="Assumed DLCUMGTAAR Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_GTASII_RATIO_O.dat 2000 1"
SORT_O="${ESF_DLCUMGTAAR_MVT_AGG} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    CUR_CF           18:1 - 18:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    FILLER1    	1:1 - 71:
/KEYS   
    CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
    UW_NT,
    RETCTR_NF,
    RETEND_NT,
    RETSEC_NF,
    RTY_NF,
    RETUW_NT
/DERIVEDFIELD COLS1 2"~"                            
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,COLS1
exit
EOF
SORT 

NSTEP=${NJOB}_40
LIBEL="Split GTRSII by TRNCODE 112121"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTRSII_OTHER} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:2 -  6:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:

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

/CONDITION GRP_RET ( TRNCOD_CF = "112121${NORME_SUFFIX}")
/OUTFILE ${SORT_O}
/INCLUDE GRP_RET
exit
EOF
SORT

#[015]
NSTEP=${NJOB}_44A
#-----------------------------------------------------------------------------
LIBEL="GTRSII RETP join TRERETFACCTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_GTRSII_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        P_CTR_NF          1:1 -  1:,
        P_END_NT          2:1 -  2:,
        P_SEC_NF          3:1 -  3:,
        P_UWY_NF          4:1 -  4:,
        P_UW_NT           5:1 -  5:,
        FILLER1           1:1 -  7:,
        FILLER2           13:1 -  73:
/joinkeys
        CTR_NF ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${DFILT}/${NJOB}_02_${IB}_TRERETFACCTR.dat 2000 1 "~"
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

#[015]
NSTEP=${NJOB}_44B
LIBEL="retro P summarize"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_44A_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    AMT_M           19:1 - 19:EN,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    PLC_NT           36:1 - 36:EN
/KEYS   
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
    PLC_NT
/SUMMARIZE TOTAL AMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[015]
NSTEP=${NJOB}_44C
#-----------------------------------------------------------------------------
LIBEL="GTRSII RETP join TRERETFACCTR exclude"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_GTRSII_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        P_CTR_NF          1:1 -  1:,
        P_END_NT          2:1 -  2:,
        P_SEC_NF          3:1 -  3:,
        P_UWY_NF          4:1 -  4:,
        P_UW_NT           5:1 -  5:,
        FILLER1           1:1 -  73:
/joinkeys
        CTR_NF ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${DFILT}/${NJOB}_02_${IB}_TRERETFACCTR.dat 2000 1 "~"
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

#[015]
#[020] no join on END_NT
NSTEP=${NJOB}_45A
LIBEL="GTRSII Join of Quaterly written premiums (actual) retro P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_44B_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1       36:1 - 36:,
    CTR_NF_F2       1:1 - 1:,
    END_NT_F2       2:1 - 2:,
    SEC_NF_F2       3:1 - 3:,
    UWY_NF_F2       4:1 - 4:,
    UW_NF_F2        5:1 - 5:,
    RETCTR_NF_F2       6:1 - 6:,
    RETEND_NT_F2       7:1 - 7:,
    RETSEC_NF_F2       8:1 - 8:,
    RTY_NF_F2          9:1 - 9:,
    RETUW_NF_F2        10:1 - 10:,
    FIXED_CHARGE_ACT    21:1 - 21:,
    ITD_PREM_ACT        22:1 - 22:,
    PLC_NT_F2           11:1 - 11:
/JOINKEYS 
    CTR_NF_F1,
    SEC_NF_F1,
    UWY_NF_F1,
    UW_NT_F1,
    RETCTR_NF_F1,
    RETEND_NT_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    RETUW_NT_F1,
    PLC_NT_F1            
/INFILE ${DFILT}/${NJOB}_03_${IB}_RATIO_RET_P.dat 2000 1 "~"                 
/JOINKEYS 
    CTR_NF_F2,
    SEC_NF_F2,
    UWY_NF_F2,          
    UW_NF_F2,
    RETCTR_NF_F2,
    RETEND_NT_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    RETUW_NF_F2,
    PLC_NT_F2

/OUTFILE ${SORT_O} overwrite
/REFORMAT
    leftside:FILLER1_F1,
    rightside:FIXED_CHARGE_ACT,ITD_PREM_ACT
exit
EOF
SORT 

#[015]
#[020] no join on END_NT
NSTEP=${NJOB}_45B
LIBEL="GTRSII Join of Quaterly written premiums (actual) retro P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_44C_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1       36:1 - 36:,
    CTR_NF_F2       1:1 - 1:,
    END_NT_F2       2:1 - 2:,
    SEC_NF_F2       3:1 - 3:,
    UWY_NF_F2       4:1 - 4:,
    UW_NF_F2        5:1 - 5:,
    RETCTR_NF_F2       6:1 - 6:,
    RETEND_NT_F2       7:1 - 7:,
    RETSEC_NF_F2       8:1 - 8:,
    RTY_NF_F2          9:1 - 9:,
    RETUW_NF_F2        10:1 - 10:,
    FIXED_CHARGE_ACT    21:1 - 21:,
    ITD_PREM_ACT        22:1 - 22:,
    PLC_NT_F2           11:1 - 11:
/JOINKEYS 
    CTR_NF_F1,
    SEC_NF_F1,
    UWY_NF_F1,
    UW_NT_F1,
    RETCTR_NF_F1,
    RETEND_NT_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    RETUW_NT_F1,
    PLC_NT_F1            
/INFILE ${DFILT}/${NJOB}_04_${IB}_RATIO_RET_P.dat 2000 1 "~"                 
/JOINKEYS 
    CTR_NF_F2,
    SEC_NF_F2,
    UWY_NF_F2,          
    UW_NF_F2,
    RETCTR_NF_F2,
    RETEND_NT_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    RETUW_NF_F2,
    PLC_NT_F2

/OUTFILE ${SORT_O} overwrite
/REFORMAT
    leftside:FILLER1_F1,
    rightside:FIXED_CHARGE_ACT,ITD_PREM_ACT
exit
EOF
SORT 

#[024]
NSTEP=${NJOB}_45C
LIBEL="retro P summarize"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_44B_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_44C_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    AMT_M           19:1 - 19:EN,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    PLC_NT           36:1 - 36:EN
/KEYS   
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
    PLC_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[022]
NSTEP=${NJOB}_46A
LIBEL="GTRSII Join of Quaterly written premiums (actual) retro P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45C_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1       36:1 - 36:,
    CTR_NF_F2       1:1 - 1:,
    END_NT_F2       2:1 - 2:,
    SEC_NF_F2       3:1 - 3:,
    UWY_NF_F2       4:1 - 4:,
    UW_NF_F2        5:1 - 5:,
    RETCTR_NF_F2       6:1 - 6:,
    RETEND_NT_F2       7:1 - 7:,
    RETSEC_NF_F2       8:1 - 8:,
    RTY_NF_F2          9:1 - 9:,
    RETUW_NF_F2        10:1 - 10:,
    FIXED_CHARGE_ACT    21:1 - 21:,
    ITD_PREM_ACT        22:1 - 22:,
    PLC_NT_F2           11:1 - 11:,
	FILLER2             1:1 - 32:
/JOINKEYS 
    CTR_NF_F1,
    SEC_NF_F1,
    UWY_NF_F1,
    UW_NT_F1,
    RETCTR_NF_F1,
    RETEND_NT_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    RETUW_NT_F1,
    PLC_NT_F1            
/INFILE ${DFILT}/${NJOB}_03_${IB}_RATIO_RET_P.dat 2000 1 "~"                 
/JOINKEYS 
    CTR_NF_F2,
    SEC_NF_F2,
    UWY_NF_F2,          
    UW_NF_F2,
    RETCTR_NF_F2,
    RETEND_NT_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    RETUW_NF_F2,
    PLC_NT_F2
	
/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
    rightside:FILLER2
exit
EOF
SORT 

#[022]
NSTEP=${NJOB}_46B
LIBEL="GTRSII Join of Quaterly written premiums (actual) retro P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45C_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1       36:1 - 36:,
    CTR_NF_F2       1:1 - 1:,
    END_NT_F2       2:1 - 2:,
    SEC_NF_F2       3:1 - 3:,
    UWY_NF_F2       4:1 - 4:,
    UW_NF_F2        5:1 - 5:,
    RETCTR_NF_F2       6:1 - 6:,
    RETEND_NT_F2       7:1 - 7:,
    RETSEC_NF_F2       8:1 - 8:,
    RTY_NF_F2          9:1 - 9:,
    RETUW_NF_F2        10:1 - 10:,
    FIXED_CHARGE_ACT    21:1 - 21:,
    ITD_PREM_ACT        22:1 - 22:,
    PLC_NT_F2           11:1 - 11:,
	FILLER2             1:1 - 32:
/JOINKEYS 
    CTR_NF_F1,
    SEC_NF_F1,
    UWY_NF_F1,
    UW_NT_F1,
    RETCTR_NF_F1,
    RETEND_NT_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    RETUW_NT_F1,
    PLC_NT_F1            
/INFILE ${DFILT}/${NJOB}_16C_${IB}_RATIO_RET_P.dat 2000 1 "~"                 
/JOINKEYS 
    CTR_NF_F2,
    SEC_NF_F2,
    UWY_NF_F2,          
    UW_NF_F2,
    RETCTR_NF_F2,
    RETEND_NT_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    RETUW_NF_F2,
    PLC_NT_F2

/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
    rightside:FILLER2
exit
EOF
SORT 

NSTEP=${NJOB}_47A
#-----------------------------------------------------------------------------
LIBEL="QWP GTRSII RATIO RET P MERGE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_46A_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_46B_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1"   
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       1:1 - 1:,
    END_NT       2:1 - 2:,
    SEC_NF       3:1 - 3:,
    UWY_NF       4:1 - 4:,
    UW_NT        5:1 - 5:,
    RETCTR_NF       6:1 - 6:,
    RETEND_NT       7:1 - 7:,
    RETSEC_NF       8:1 - 8:,
    RTY_NF          9:1 - 9:,
    RETUW_NT        10:1 - 10:,
    PLC_NT          11:1 - 11:,
    FIXED_CHARGE_ACT    21:1 - 21:EN,
    ITD_PREM_ACT        22:1 - 22:EN,
	CSM_PAT_PREV        30:1 - 30:EN,
	LC_PAT_PREV         32:1 - 32:EN
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
        PLC_NT 
/CONDITION GRP1 ( ( FIXED_CHARGE_ACT NE 0 OR ITD_PREM_ACT NE 0 ) AND ( CSM_PAT_PREV NE 1 OR LC_PAT_PREV NE 1 ) )
/STABLE
/SUMMARIZE
/INCLUDE GRP1
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

NSTEP=${NJOB}_47B
LIBEL="QWP GTRSII RATIO RET P JOIN IRDPERICASE0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_47A_${IB}_IVR_CHR_STD_RATIO_RET_P_QWP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RETP_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
       RETCTR_NF       6:1 - 6:,
       RETEND_NT       7:1 - 7:,
       RETSEC_NF       8:1 - 8:,
       RTY_NF          9:1 - 9:,
       RETUW_NT        10:1 - 10:,
       PRETCTR_NF       3:1 - 3:,
       PRETEND_NT       4:1 - 4:,
       PRETSEC_NF       5:1 - 5:,
       PRTY_NF          6:1 - 6:,
       PRETUW_NT        7:1 - 7:,
       F1           1:1 - 1:,
       F1B          8:1 - 8:,
       F6           6:1 - 10:,
       F7           51:1 - 51:,
       F10          1:1 - 5:,
       FIXED_CHARGE_ACT    21:1 - 21:,
       ITD_PREM_ACT        22:1 - 22:
/JOINKEYS
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/INFILE ${EST_IRDPERICASE0} 2000 1 "~"
/JOINKEYS
        PRETCTR_NF,
        PRETEND_NT,
        PRETSEC_NF,
        PRTY_NF,
        PRETUW_NT
/DERIVEDFIELD EMPTY_FIELD "~"
/DERIVEDFIELD F2 "${ICLODAT_YEA}~"
/DERIVEDFIELD F3 "${ICLODAT_MTH}~"
/DERIVEDFIELD F4 "${ICLODAT_DAY}~"
/DERIVEDFIELD F5 "2112121${NORME_SUFFIX}~2212121${NORME_SUFFIX}~"
/DERIVEDFIELD F8 "0.000~~~~~~0.000~~0.000~~~~~~~~~~~~~~${NORME_CF}GTA~~~~~~~~~~~~~~~6500~~"
/DERIVEDFIELD F9 "~~0~~~~~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        RIGHTSIDE:F1,F1B,LEFTSIDE:F2,F3,F4,F5,F10,F2,F2,F3,F3,F9,F6,F2,F2,F3,F3,EMPTY_FIELD,
        RIGHTSIDE:F7,
        LEFTSIDE:F8,FIXED_CHARGE_ACT,ITD_PREM_ACT
exit
EOF
SORT

NSTEP=${NJOB}_47C
LIBEL="QWP GTRSII RATIO RET P JOIN IADPERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_47B_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RETP_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF       8:1 - 8:,
        END_NT       9:1 - 9:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:,
        PERCTR_NF    3:1 - 3:,
        PEREND_NT    4:1 - 4:,
        PERSEC_NF    5:1 - 5:,
        PERUWY_NF    6:1 - 6:,
        PERUW_NT     7:1 - 7:,
        F1           23:1 - 23:,
        FILLER1      1:1 - 17:,
        FILLER2      19:1 - 75:
/JOINKEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EST_IADPERICASE_STD} 2000 1 "~"
/JOINKEYS
        PERCTR_NF,
        PEREND_NT,
        PERSEC_NF,
        PERUWY_NF,
        PERUW_NT
/DERIVEDFIELD EMPTY_FIELD "~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        LEFTSIDE:FILLER1,RIGHTSIDE:F1,
        LEFTSIDE:FILLER2
exit
EOF
SORT

#[013]
#[020] no join on END_NT
NSTEP=${NJOB}_50
LIBEL="GTRSII Join of Quaterly written premiums (actual) retro NP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_GTRSII_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RETNP_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1           36:1 - 36:,
    RETCTR_NF_F2       1:1 - 1:,
    RETEND_NT_F2       2:1 - 2:,
    RETSEC_NF_F2       3:1 - 3:,
    RTY_NF_F2          4:1 - 4:,
    RETUW_NF_F2        5:1 - 5:,
    FIXED_CHARGE_ACT    16:1 - 16:,
    ITD_PREM_ACT        17:1 - 17:,
    PLC_NT_F2          6:1 - 6:
/JOINKEYS 
    RETCTR_NF_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    PLC_NT_F1
/INFILE ${ESF_RATIO_RET_NP} 2000 1 "~"                 
/JOINKEYS 
    RETCTR_NF_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    PLC_NT_F2

/OUTFILE ${SORT_O} overwrite
/REFORMAT
    leftside:FILLER1_F1,
    rightside:FIXED_CHARGE_ACT,ITD_PREM_ACT
exit
EOF
SORT 

#[022]
NSTEP=${NJOB}_50B
LIBEL="QWP GTRSII RATIO Join of Quaterly written premiums (actual) retro NP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_GTRSII_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_RET_NP_QWP.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    RETCTR_NF_F1        24:1 - 24:,
    RETEND_NT_F1        25:1 - 25:,
    RETSEC_NF_F1        26:1 - 26:,
    RTY_NF_F1           27:1 - 27:,
    RETUW_NT_F1         28:1 - 28:,
    FILLER1_F1    	1:1 - 73:,
    PLC_NT_F1           36:1 - 36:,
    RETCTR_NF_F2       1:1 - 1:,
    RETEND_NT_F2       2:1 - 2:,
    RETSEC_NF_F2       3:1 - 3:,
    RTY_NF_F2          4:1 - 4:,
    RETUW_NF_F2        5:1 - 5:,
    FIXED_CHARGE_ACT    16:1 - 16:,
    ITD_PREM_ACT        17:1 - 17:,
    PLC_NT_F2          6:1 - 6:,
	FILLER2            1:1 - 25:
/JOINKEYS 
    RETCTR_NF_F1,
    RETSEC_NF_F1,
    RTY_NF_F1,
    PLC_NT_F1
/INFILE ${ESF_RATIO_RET_NP} 2000 1 "~"                 
/JOINKEYS 
    RETCTR_NF_F2,
    RETSEC_NF_F2,
    RTY_NF_F2,
    PLC_NT_F2
/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
    rightside:FILLER2
exit
EOF
SORT 

NSTEP=${NJOB}_50C
#-----------------------------------------------------------------------------
LIBEL="QWP GTRSII RATIO RET NP FILTER"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_50B_${IB}_IVR_CHR_STD_RATIO_RET_NP_QWP.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_IVR_CHR_STD_RATIO_RET_NP_QWP.dat 2000 1"   
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF       1:1 - 1:,
    RETEND_NT       2:1 - 2:,
    RETSEC_NF       3:1 - 3:,
    RTY_NF          4:1 - 4:,
    RETUW_NT        5:1 - 5:,
    PLC_NT          6:1 - 6:,
    FIXED_CHARGE_ACT    16:1 - 16:EN,
    ITD_PREM_ACT        17:1 - 17:EN,
	CSM_PAT_PREV        23:1 - 23:EN
/KEYS   RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        PLC_NT 
/CONDITION GRP1 ( ( FIXED_CHARGE_ACT NE 0 OR ITD_PREM_ACT NE 0 ) AND CSM_PAT_PREV NE 1 )
/STABLE
/SUMMARIZE
/INCLUDE GRP1
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

NSTEP=${NJOB}_50D
LIBEL="QWP GTRSII RATIO RET NP JOIN IRDPERICASE0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50C_${IB}_IVR_CHR_STD_RATIO_RET_NP_QWP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RETNP_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
       RETCTR_NF       1:1 - 1:,
       RETEND_NT       2:1 - 2:,
       RETSEC_NF       3:1 - 3:,
       RTY_NF          4:1 - 4:,
       RETUW_NT        5:1 - 5:,
       PRETCTR_NF       3:1 - 3:,
       PRETEND_NT       4:1 - 4:,
       PRETSEC_NF       5:1 - 5:,
       PRTY_NF          6:1 - 6:,
       PRETUW_NT        7:1 - 7:,
       F1           1:1 - 1:,
       F1B          8:1 - 8:,
       F6           1:1 - 5:,
       F7           51:1 - 51:,
       FIXED_CHARGE_ACT    16:1 - 16:,
       ITD_PREM_ACT        17:1 - 17:
/JOINKEYS
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/INFILE ${EST_IRDPERICASE0} 2000 1 "~"
/JOINKEYS
        PRETCTR_NF,
        PRETEND_NT,
        PRETSEC_NF,
        PRTY_NF,
        PRETUW_NT
/DERIVEDFIELD EMPTY_FIELD "~"
/DERIVEDFIELD F2 "${ICLODAT_YEA}~"
/DERIVEDFIELD F3 "${ICLODAT_MTH}~"
/DERIVEDFIELD F4 "${ICLODAT_DAY}~"
/DERIVEDFIELD F5 "2112121${NORME_SUFFIX}~2212121${NORME_SUFFIX}~~~~~~"
/DERIVEDFIELD F8 "0.000~~~~~~0.000~~0.000~~~~~~~~~~~~~~${NORME_CF}GTA~~~~~~~~~~~~~~~6500~~"
/DERIVEDFIELD F9 "~~0~~~~~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
        RIGHTSIDE:F1,F1B,LEFTSIDE:F2,F3,F4,F5,F2,F2,F3,F3,F9,F6,F2,F2,F3,F3,EMPTY_FIELD,
        RIGHTSIDE:F7,
        LEFTSIDE:F8,FIXED_CHARGE_ACT,ITD_PREM_ACT,EMPTY_FIELD
exit
EOF
SORT

# [019] RNP ==> Vider AMT_M et RUR_CF si CTR_NF vide
# [017]
NSTEP=${NJOB}_51
LIBEL="Quaterly written premiums (actual) Pure NP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_GTRSII_RETNP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RETNP_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF_F1       8:1 -  8:,
    END_NT_F1       9:1 -  9:,
    SEC_NF_F1       10:1 - 10:,
    UWY_NF_F1       11:1 - 11:,
    UW_NT_F1        12:1 - 12:,
    FILED_1_17      1:1 - 17:,
    CUR_CF          18:1 - 18:,
    AMT_M           19:1 - 19:,
    FILED_20_76     20:1 - 76:    
    
/CONDITION PURE_NP ( CTR_NF_F1 = "" AND END_NT_F1 = "" AND SEC_NF_F1 = "" AND  UWY_NF_F1 = "" AND UW_NT_F1 = "" )
/DERIVEDFIELD CUR_CF_NEW "~" 
/DERIVEDFIELD AMT_M_NEW "0~" 
/OUTFILE ${SORT_O} overwrite
/INCLUDE PURE_NP
/REFORMAT
    FILED_1_17,CUR_CF_NEW,AMT_M_NEW,FILED_20_76
/COPY
exit
EOF
SORT 

#[015]
#[019]  
NSTEP=${NJOB}_55
LIBEL="Merge retro P and NP GTRSII Quaterly written premiums (actual)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_45_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_I="${DFILT}/${NJOB}_45A_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_45B_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_51_${IB}_SORT_GTRSII_RETNP_O.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_47C_${IB}_SORT_GTRSII_RETP_O.dat 2000 1"
SORT_I5="${DFILT}/${NJOB}_50D_${IB}_SORT_GTRSII_RETNP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RATIO_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    AMT_M           19:1 - 19:EN,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    PLC_NT           36:1 - 36:EN,
	FIXED_CHARGE_ACT 74:1 - 74:EN,
	ITD_PREM_ACT     75:1 - 75:EN
/KEYS   
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
    PLC_NT
/SUMMARIZE TOTAL AMT_M, TOTAL FIXED_CHARGE_ACT, TOTAL ITD_PREM_ACT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_60
LIBEL="GTRSII generation amout of Quaterly written premiums (actual)"
AWK_I="${DFILT}/${NJOB}_55_${IB}_SORT_GTRSII_RATIO_O.dat "
AWK_O="${DFILT}/${NSTEP}_${IB}_SORT_GTRSII_RATIO_O.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
    AMT_M = 0;
    RETAMT_M = 0;
    RETINTAMT_M = 0;

    AMT_M = \$74 + \$75;

    if ( \$24 != "" )
    {
        RETAMT_M = \$74 + \$75;
        RETINTAMT_M = \$74 + \$75;
    }

    \$19 = sprintf("%.3lf", AMT_M);
    \$35 = sprintf("%.3lf", RETAMT_M);
    \$41 = sprintf("%.3lf", RETINTAMT_M);

    print \$0;
}
exit
EOF
AWK

NSTEP=${NJOB}_65
LIBEL="RETRO DLCUMGTAAR Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_GTRSII_RATIO_O.dat 2000 1"
SORT_O="${ESF_DLCUMGTAAR_MVT_AGG_RET} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF            8:1 -  8:,
    END_NT            9:1 -  9:,
    SEC_NF           10:1 - 10:,
    UWY_NF           11:1 - 11:,
    UW_NT            12:1 - 12:,
    CUR_CF           18:1 - 18:,
    RETCTR_NF        24:1 - 24:,
    RETEND_NT        25:1 - 25:,
    RETSEC_NF        26:1 - 26:,
    RTY_NF           27:1 - 27:,
    RETUW_NT         28:1 - 28:,
    FILLER1    	1:1 - 71:
/KEYS   
    CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
    UW_NT,
    RETCTR_NF,
    RETEND_NT,
    RETSEC_NF,
    RTY_NF,
    RETUW_NT
/DERIVEDFIELD COLS1 2"~"                            
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,COLS1
exit
EOF
SORT


JOBEND

