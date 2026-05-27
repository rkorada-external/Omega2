#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - COMPTABILISATION
# nom du script SHELL		: ESID7301.cmd
# revision			: $Revision: 1.0 $
# date de creation		: 18/06/2010
# auteur			: Dominique OURMIAH
# references des specifications	: :spot:22752
#-----------------------------------------------------------------------------
# description : Accumulation of facultative premium
#
# job launched by ESID7300.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#---------------------------------------------------------------
#modifications chronology:
#   <jj/mm/aaaa>   <author>    <description de la modification>
#
#---------------
#MODIFICATION   :
#Auteur         :
#Date           :
#Version        :
#Description    :
#[001] 08/08/2013   R. CASSIS  :spot:25427 - Ajout jointure table tbatchssd pour Omega2
#[002] 23/09/2015	CCH		- Modification due RET03A
#[003] 13/06/2016	CCH		- Fix defect #51103
#[004] - L. Rakotozafy - 18/10/2023 - User Story 737 - Dette technique - Decommissioning Infocentre (TTECLEDA)
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CLODAT_D=$3
SIMMOD_B=$4

# Initialization of the Job
JOBINIT

#[001] & [002]
#NSTEP=${NJOB}_05
# [002] TCLORET is no longer used.
# On r,cupSre les contrats actifs dans la table BRET..TCLORET
#-----------------------------------------------------------------------------
#LIBEL=" Extraction of Retro contracts "
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_CLORETCTR.dat
#BCP_QRY="
#select RETCTR_NF, a.SSD_CF, RSV_CT, PRFT_CT, ACT_CT, LSTPCS_D, CRE_D, CREUSR_CF,	LSTUPD_D, LSTUPDUSR_CF
#from BRET..TCLORET a, BREF..TBATCHSSD b
#where act_ct = 1
#and   a.SSD_CF=b.SSD_CF
#and   b.BATCHUSER_CF = suser_name()
#order by RETCTR_NF
#"
#BCP


#[004] 
#Switch on INFO CENTER server defined in the environment file
#----------------------------------------------------------------
#SWITCH_SRV ${SRV_2}


#[002] No need as TCLORET is no longer used.
#NSTEP=${NJOB}_10
# Begin BCP IN
#----------------------------------------------------------------------------
#LIBEL="BCP IN of RETRO contracts in BTRAVI table "
#BCP_WAY="IN"; BCP_VER=""
#BCP_TRUNCATE=YES
#BCP_I=${DFILT}/${NJOB}_05_${IB}_BCP_CLORETCTR.dat
#BCP_TABLE="BTRAVI..TCLORETTMP"
#BCP

#[004] INFO CENTER server is no longer used.
#NSTEP=${NJOB}_15
#Begin isql
#-----------------------------------------------------------------------------
#LIBEL="Determination of the TTECLEDA table that will be loaded"
#ISQL_BASE="BSTA"
#ISQL_QRY="execute BSTA..PsTBOPAR_03 'EST', 'TTECLEDA', '${CLODAT_D}',${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
#ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
#ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
#ISQL_RES

#The Table that will take TTECLEDA results is
#TECLEDA=`cat ${ISQL_FRES} | sed -e s/\ //g`
#TTECLEDA=T${TECLEDA}

NSTEP=${NJOB}_05
#[003] 
#-----------------------------------------------------------------------------
LIBEL=" Retrieve Closing file name "
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_ClosingFileName_O.dat
BCP_QRY="select PATHPATTRN_LL from BEST..TI17PERMFIL where PERMFIL_CT like 'EST_FTECLEDA' and IDF_CT = 'I4I_ESPD8100'"
BCP
ClosingFile=`cat ${BCP_O}`

NSTEP=${NJOB}_06
#[003] 
#-----------------------------------------------------------------------------
LIBEL=" Check if there is more than one line retrieved "
EXECKSH_MODE=P
EXECKSH "NB_RECORD=`cat ${BCP_O} | wc -l`"

if [ "${NB_RECORD}" != 1 ]

then
        ECHO_LOG "#========================================================================="
        ECHO_LOG "#===> CLOSING FILE ${ClosingFile} MORE THAN ONE FILE FOUND "
        ECHO_LOG "#========================================================================="
        
        STEPEND 1
fi

NSTEP=${NJOB}_10
#[003] 
#--------------------------------------------------
LIBEL=" Setting Closing file name path "
EXECKSH_MODE=P
EXECKSH "ClosingFilePath=$(echo "${ClosingFile}" | sed 's/${ENV_PREFIX}/"${ENV_PREFIX}"/g; s/${TYPEINV}/POS/g; s/${PARM_ICLODAT_D}/"${CLODAT_D}"/g')"

if [[ ! -s "${ClosingFilePath}" ]]

then
        ECHO_LOG "#========================================================================="
        ECHO_LOG "#===> CLOSING FILE ${ClosingFilePath} NOT FOUND "
        ECHO_LOG "#========================================================================="
        
        STEPEND 1
fi

NSTEP=${NJOB}_15
#[003] 
#-----------------------------------------------------------------------------
LIBEL=" Extract perimeter of the Closing transformation "
BCP_WAY="OUT"; BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PerClosTrans_O.dat
BCP_QRY="select distinct T2.RETCTR_NF, T2.RTY_NF, T3.ORIDETTRS_CF, T3.TRADETTRS_CF
FROM BRET..TRETCTR T2, BRET..TRTRANSTCODE T3, BREF..TBATCHSSD T4
WHERE T2.CLOFAM_CT = T3.FAMTRAN_CF
AND T2.SSD_CF = T4.SSD_CF
AND T4.BATCHUSER_CF = suser_name()
AND T3.TRANSTYP_CF ='CLOFA' 
AND T3.TRADETTRS_CF != '99999999'
AND T2.RETCTRSTS_CT in (3,19)
order by T2.RETCTR_NF, T2.RTY_NF, T3.ORIDETTRS_CF, T3.TRADETTRS_CF"
BCP

NSTEP=${NJOB}_16
# summarize TTECLEDA by BALSHTDAY
#--------------------------------
LIBEL="Summarize TTECLEDA by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ClosingFilePath} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDA_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	DBLTRNCOD_CF      7:1 -   7:,
	CTR_NF            8:1 -   8:,
	END_NT            9:1 -   9:,
	SEC_NF           10:1 -  10:,
	UWY_NF           11:1 -  11:,
	UW_NT            12:1 -  12:,
	OCCYEA_NF        13:1 -  13:EN,
	ACY_NF           14:1 -  14:EN,
	SCOSTRMTH_NF     15:1 -  15:EN,
	SCOENDMTH_NF     16:1 -  16:EN,
	CUR_CF           18:1 -  18:,
	AMT_M            19:1 -  19:EN 15/3,
	CED_NF           20:1 -  20:,
	RETCTR_NF        24:1 -  24:,
	RETEND_NT        25:1 -  25:,
	RETSEC_NF        26:1 -  26:,
	RTY_NF           27:1 -  27:,
	RETUW_NT         28:1 -  28:,
	RETOCCYEA_NF     29:1 -  29:EN,
	RETACY_NF        30:1 -  30:EN,
	RETSCOSTRMTH_NF  31:1 -  31:EN,
	RETSCOENDMTH_NF  32:1 -  32:EN,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 15/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
	CRE_D            41:1 -  41:,
	RETINTAMT_M      88:1 -  88:EN 15/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:
/KEYS
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
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
	CUR_CF,
	CED_NF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF,
	RETCUR_CF,
	PLC_NT,
	RTO_NF,
  CRE_D,
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT

NSTEP=${NJOB}_17
#[003] 
#-----------------------------------------------------------------------------
LIBEL=" Extraction of closing transactions step #1 - by contract/uwy/TCode "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16_${IB}_SORT_TECLEDA_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ClosTrans1_SORT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF                   1:1 - 1:,
        ESB_CF                   2:1 - 2:,
        BALSHEY_NF               3:1 - 3:,
        BALSHRMTH_NF             4:1 - 4:,
        BALSHRDAY_NF             5:1 - 5:,
        TRNCOD_CF                6:1 - 6:,
        DBLTRNCOD_CF             7:1 - 7:,
        CTR_NF                   8:1 - 8:,
        END_NT                   9:1 - 9:,
        SEC_NF                   10:1 - 10:,
        UWY_NF                   11:1 - 11:,
        UW_NT                    12:1 - 12:,
        OCCYEA_NF                13:1 - 13:,
        ACY_NF                   14:1 - 14:,
        SCOSTRMTH_NF             15:1 - 15:,
        SCOENDMTH_NF             16:1 - 16:,
        CLM_NF                   17:1 - 17:,
        CUR_CF                   18:1 - 18:,
        AMT_M                    19:1 - 19:,
        CED_NF                   20:1 - 20:,
        BRK_NF                   21:1 - 21:,
        GEMPRMPAY_NF             22:1 - 22:,
        GANPAYORD_NT             23:1 - 23:,
        RETCTR_NF                24:1 - 24:,
        RETEND_NT                25:1 - 25:,
        RETSEC_NF                26:1 - 26:,
        RETRTY_NF                27:1 - 27:,
        RETUW_NT                 28:1 - 28:,
        RETOCCYEA_NF             29:1 - 29:,
        RETACY_NF                30:1 - 30:,
        RETSCOSTRMTH_NF          31:1 - 31:,
        RETSCOENDMTH_NF          32:1 - 32:,
        RCL_NF                   33:1 - 33:,
        RETCUR_CF                34:1 - 34:,
        RETAMT_M                 35:1 - 35:,
        PLC_NT                   36:1 - 36:,
        RTO_NF                   37:1 - 37:,
        INT_NF                   38:1 - 38:,
        RETPAY_NF                39:1 - 39:,
        RETKEY_CF                40:1 - 40:,
        CRE_D                    41:1 - 41:,
        CREUSR_CF                42:1 - 42:,
        LSTUPD_D                 43:1 - 43:,
        LSTUPDUSR_CF             44:1 - 44:,
        LOBACC_CF                45:1 - 45:,
        LOBRET_CF                46:1 - 46:,
        SOBACC_CF                47:1 - 47:,
        SOBRET_CF                48:1 - 48:,
        TOPACC_CF                49:1 - 49:,
        TOPRET_CF                50:1 - 50:,
        NATACC_CF                51:1 - 51:,
        NATRET_CF                52:1 - 52:,
        GARACC_CF                53:1 - 53:,
        GARRET_CF                54:1 - 54:,
        PCPRSKTRYACC_CF          55:1 - 55:,
        PCPRSKTRYRET_CF          56:1 - 56:,
        USRCRTCODACC_CT          57:1 - 57:,
        USRCRTCODRET_CT          58:1 - 58:,
        USRCRTVALACC_LM          59:1 - 59:,
        USRCRTVALRET_LM          60:1 - 60:,
        CTRNAT_CT                61:1 - 61:,
        RETCTRCAT_CF             62:1 - 62:,
        WRKCAT_CT                63:1 - 63:,
        PRDCOD_CT                64:1 - 64:,
        ANLCTY_CF                65:1 - 65:,
        ACCADMTYP_CT             66:1 - 66:,
        RETACCTYP_CT             67:1 - 67:,
        COMACC_B                 68:1 - 68:,
        CPLACCUPD_D              69:1 - 69:,
        CTRRET_B                 70:1 - 70:,
        UWGRP_CF                 71:1 - 71:,
        VRS_NF                   72:1 - 72:,
        SEG_NF                   73:1 - 73:,
        UWORG_CF                 74:1 - 74:,
        ESTCRB_CT                75:1 - 75:,
        ESTCTR_NF                76:1 - 76:,
        ESBACC_CF                77:1 - 77:,
        ORGCED_NF                78:1 - 78:,
        CEDHORDNBR_NT            79:1 - 79:,
        CEDSORDNBR_NT            80:1 - 80:,
        ORGCEDHORDNBR_NT         81:1 - 81:,
        ORGCEDSORDNBR_NT         82:1 - 82:,
        BRKHORDNBR_NT            83:1 - 83:,
        BRKSORDNBR_NT            84:1 - 84:,
        FACADMTYP_CT             85:1 - 85:,
        CLIIND_NF                86:1 - 86:,
        HORDNBR_NT               87:1 - 87:,
        RETINTAMT_M              88:1 - 88:,
        RETARDRETINT_B           109:1 - 109:,
        RETCTR_NF_F2             1:1 - 1:,
        RTY_NF_F2                2:1 - 2:,
        ORIDETTRS_CF_F2          3:1 - 3:,
        TRADETTRS_CF_F2          4:1 - 4:,
        all_cols                 1:1 - 88:
/joinkeys
       RETCTR_NF
      ,RETRTY_NF
      ,TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_15_${IB}_BCP_PerClosTrans_O.dat  2000 1 "~"
/joinkeys
        RETCTR_NF_F2
       ,RTY_NF_F2
       ,ORIDETTRS_CF_F2
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:all_cols
       ,rightside:TRADETTRS_CF_F2
       ,leftside:RETARDRETINT_B
exit
EOF
SORT

NSTEP=${NJOB}_19
#[003] 
#-----------------------------------------------------------------------------
LIBEL=" Extraction of closing transactions step #2 - by conditions "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_17_${IB}_ClosTrans1_SORT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ClosTrans2_SORT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF                   1:1 - 1:,
        ESB_CF                   2:1 - 2:,
        BALSHEY_NF               3:1 - 3:,
        BALSHRMTH_NF             4:1 - 4:,
        BALSHRDAY_NF             5:1 - 5:,
        TRNCOD_CF                6:1 - 6:,
        TRNCOD_CF_8              6:8 -  6:8,
        DBLTRNCOD_CF             7:1 - 7:,
        CTR_NF                   8:1 - 8:,
        END_NT                   9:1 - 9:,
        SEC_NF                   10:1 - 10:,
        UWY_NF                   11:1 - 11:,
        UW_NT                    12:1 - 12:,
        OCCYEA_NF                13:1 - 13:,
        ACY_NF                   14:1 - 14:,
        SCOSTRMTH_NF             15:1 - 15:,
        SCOENDMTH_NF             16:1 - 16:,
        CLM_NF                   17:1 - 17:,
        CUR_CF                   18:1 - 18:,
        AMT_M                    19:1 - 19:,
        CED_NF                   20:1 - 20:,
        BRK_NF                   21:1 - 21:,
        GEMPRMPAY_NF             22:1 - 22:,
        GANPAYORD_NT             23:1 - 23:,
        RETCTR_NF                24:1 - 24:,
        RETEND_NT                25:1 - 25:,
        RETSEC_NF                26:1 - 26:,
        RETRTY_NF                27:1 - 27:,
        RETUW_NT                 28:1 - 28:,
        RETOCCYEA_NF             29:1 - 29:,
        RETACY_NF                30:1 - 30:,
        RETSCOSTRMTH_NF          31:1 - 31:,
        RETSCOENDMTH_NF          32:1 - 32:,
        RCL_NF                   33:1 - 33:,
        RETCUR_CF                34:1 - 34:,
        RETAMT_M                 35:1 - 35:,
        PLC_NT                   36:1 - 36:,
        RTO_NF                   37:1 - 37:,
        INT_NF                   38:1 - 38:,
        RETPAY_NF                39:1 - 39:,
        RETKEY_CF                40:1 - 40:,
        CRE_D                    41:1 - 41:,
        CREUSR_CF                42:1 - 42:,
        LSTUPD_D                 43:1 - 43:,
        LSTUPDUSR_CF             44:1 - 44:,
        LOBACC_CF                45:1 - 45:,
        LOBRET_CF                46:1 - 46:,
        SOBACC_CF                47:1 - 47:,
        SOBRET_CF                48:1 - 48:,
        TOPACC_CF                49:1 - 49:,
        TOPRET_CF                50:1 - 50:,
        NATACC_CF                51:1 - 51:,
        NATRET_CF                52:1 - 52:,
        GARACC_CF                53:1 - 53:,
        GARRET_CF                54:1 - 54:,
        PCPRSKTRYACC_CF          55:1 - 55:,
        PCPRSKTRYRET_CF          56:1 - 56:,
        USRCRTCODACC_CT          57:1 - 57:,
        USRCRTCODRET_CT          58:1 - 58:,
        USRCRTVALACC_LM          59:1 - 59:,
        USRCRTVALRET_LM          60:1 - 60:,
        CTRNAT_CT                61:1 - 61:,
        RETCTRCAT_CF             62:1 - 62:,
        WRKCAT_CT                63:1 - 63:,
        PRDCOD_CT                64:1 - 64:,
        ANLCTY_CF                65:1 - 65:,
        ACCADMTYP_CT             66:1 - 66:,
        RETACCTYP_CT             67:1 - 67:,
        COMACC_B                 68:1 - 68:,
        CPLACCUPD_D              69:1 - 69:,
        CTRRET_B                 70:1 - 70:,
        UWGRP_CF                 71:1 - 71:,
        VRS_NF                   72:1 - 72:,
        SEG_NF                   73:1 - 73:,
        UWORG_CF                 74:1 - 74:,
        ESTCRB_CT                75:1 - 75:,
        ESTCTR_NF                76:1 - 76:,
        ESBACC_CF                77:1 - 77:,
        ORGCED_NF                78:1 - 78:,
        CEDHORDNBR_NT            79:1 - 79:,
        CEDSORDNBR_NT            80:1 - 80:,
        ORGCEDHORDNBR_NT         81:1 - 81:,
        ORGCEDSORDNBR_NT         82:1 - 82:,
        BRKHORDNBR_NT            83:1 - 83:,
        BRKSORDNBR_NT            84:1 - 84:,
        FACADMTYP_CT             85:1 - 85:,
        CLIIND_NF                86:1 - 86:,
        HORDNBR_NT               87:1 - 87:,
        RETINTAMT_M              88:1 - 88:,
        TRADETTRS_CF             89:1 - 89:,
        RETARDRETINT_B           90:1 - 90:,
        all_cols                 1:1 - 89 :
/CONDITION COND1  ( ( RETARDRETINT_B = "1" AND TRNCOD_CF_8 = "4" ) OR TRNCOD_CF_8 != "4" )
/OUTFILE ${SORT_O}
/INCLUDE COND1
/REFORMAT all_cols
exit
EOF
SORT


#Switch on INFO CENTER server defined in the environment file
#----------------------------------------------------------------
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL=" closing transactions BCP in BTRAV_RETCLOTRANS " 
BCP_WAY="IN"
BCP_VER=""
BCP_TRUNCATE=YES
BCP_I=${DFILT}/${NJOB}_19_${IB}_ClosTrans2_SORT.dat
BCP_TABLE="BTRAVI..RETCLOTRANS"
BCP

NSTEP=${NJOB}_25
#[004] 
# Extraction of closing transactions
#-----------------------------------------------------------------------------
LIBEL=" Extraction of closing transactions step #3  "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_CLOTRANS.dat
BCP_QRY="execute BSAR..PsTTECLEDA_09b ${BALSHTYEA_NF}"
BCP

#Switch on current server
#-----------------------------------------------------------------------------
SWITCH_SRV ${SRV_DEFAULT}

#[002] Removing of this step. C program is replaced by PsTTECLEDA_09
#NSTEP=${NJOB}_30
# Modify transactions code
#-----------------------------------------------------------------------------
#LIBEL="Modify transactions code"
#PRG=ESTM7622
#export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_BCP_CLORETCTR.dat
#export ${PRG}_I2=${DFILT}/${NJOB}_20_${IB}_BCP_CLOTRANS.dat
#export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CLOTRANS_O.dat
#EXECPRG

#[002] Output is coming from STEP 20 instead of 30
#[004] step renumbering
NSTEP=${NJOB}_40
# Begin BCP IN
#-----------------------------------------------------------------------------
LIBEL="BCP IN TCLOMVTTMP table "
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=YES
BCP_I=${DFILT}/${NJOB}_25_${IB}_BCP_CLOTRANS.dat
BCP_TABLE="BTRAV..TCLOMVTTMP"
BCP

#[002] Truncate of TOUTTRAA_S Partition only if Simulation
if [ "${SIMMOD_B}" = "1" ];
then
NSTEP=${NJOB}_45
# TRUNCATE TOUTTRAA_S
#-----------------------------------------------------------------------------
LIBEL="Truncate TOUTTRAA_S Partition"
TRUNCATE_TABLENAME="BRET..TOUTTRAA_S"
TRUNCATE_PARTITION="YES"
TRUNCATE_TABLE
fi

NSTEP=${NJOB}_46
# TRUNCATE of BTRAV..TRETSIGSHA
#-----------------------------------------------------------------------------
LIBEL="Truncate BTRAV..TRETSIGSHA"
TRUNCATE_TABLENAME="BTRAV..TRETSIGSHA"
TRUNCATE_TABLE

#[003] New proc to sum up all Placed Share of all Retro. Contract
NSTEP=${NJOB}_47
# Calculation 100% Placed Share
#-----------------------------------------------------------------------------
LIBEL="Calculation 100%"
ISQL_BASE="BRET"
ISQL_QRY="execute BRET..PiPLACEMT_19"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL

#[003] Split into 2 SP to accelerate the process.
NSTEP=${NJOB}_50
# Injects transactions in Retro awaiting
#-----------------------------------------------------------------------------
LIBEL="Insert TRACCSEN & Constitution movements"
ISQL_BASE="BRET"
ISQL_QRY="execute BRET..PiRACCSEN_08 ${BALSHTMTH_NF}, ${BALSHTYEA_NF}, ${SIMMOD_B}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL

#[003] Split into 2 SP to accelerate the process.
NSTEP=${NJOB}_60
# Injects transactions in Retro awaiting
#-----------------------------------------------------------------------------
LIBEL="Insert Cancellation movements"
ISQL_BASE="BRET"
ISQL_QRY="execute BRET..PiRACCSEN_09 ${BALSHTMTH_NF}, ${BALSHTYEA_NF}, ${SIMMOD_B}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
ISQL

# Delete temporary files
NSTEP=${NJOB}_100
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

