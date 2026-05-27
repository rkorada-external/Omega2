#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Gestion des ecritures de services Life IFRS17
#				  Batch quotidien
# nom du script SHELL		: ESFJ0090.cmd
# revision
# date de creation		: 26/08/2020
# auteur			: S.Behague
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#
# launched by ESFJ0090.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
# [01]  26/08/2029 SBE  :spira:89796 I17 : RETRO - Life SAP posting
# [02]  22/11/2021 R. Cassis  :spira:100493 Remplacement PERTYP_CT par PARM_PERTYP_CT
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
CRE_D=$1
CLODAT_D=$2
BALSHTYEA_NF=$3
#PERTYP_CT=$4

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Selection of service writings and update of service writings table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FACCSUP_O.dat
BCP_QRY="exec BEST..PiESTACCSUP_07 '${CRE_D}'"
BCP

if [ "${PARM_PERTYP_CT}" = "H" ]
then
	NSTEP=${NJOB}_10
	# This step is launched only outside service period
	#------------------------------------------------------------------------------
	LIBEL="Data preparation for the cessions file"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FCES_O.dat
	BCP_QRY="exec BEST..PiESTCES_03"
	BCP

	NSTEP=${NJOB}_15
	# This step is launched only outside service period
	#------------------------------------------------------------------------------
	LIBEL="Data preparation for the placements file"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FPLC_O.dat
	BCP_QRY="exec BEST..PiESTPLC_03"
	BCP

	NSTEP=${NJOB}_20
	# Begin sort
	#------------------------------------------------------------------------------
	LIBEL="Sort of cessions file"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I=${DFILT}/${NJOB}_10_${IB}_BCP_FCES_O.dat
	SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCES_O.dat
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:, RETCTR_NF 6:1 - 6:, RETEND_NT 7:1 - 7:, RETSEC_NF 8:1 - 8:, RTY_NF 9:1 - 9:, RETUW_NT 10:1 - 10:
/KEYS   CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT
/CONDITION RETRO RETCTR_NF EQ ""
/OMIT RETRO
exit
EOF
	SORT

	NSTEP=${NJOB}_25
	# Begin sort
	#-----------------------------------------------------------------------------
	LIBEL="Sort of placements file"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I=${DFILT}/${NJOB}_15_${IB}_BCP_FPLC_O.dat
	SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FPLC_O.dat
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:, RETEND_NT 4:1 - 4:, RETSEC_NF 5:1 - 5:, RTY_NF 6:1 - 6:, RETUW_NT 7:1 - 7:, PLC_NT 8:1 - 8:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT
exit
EOF
	SORT

	NSTEP=${NJOB}_30
	# Delete of temporary files
	#------------------------------------------------------------------------------
	LIBEL="Delete of temporary files"
	RMFIL ${DFILT}/${NJOB}_10_${IB}_BCP_FCES_O.dat
	RMFIL ${DFILT}/${NJOB}_15_${IB}_BCP_FPLC_O.dat

   # Environmental variables point to current Cessions & Placements Files
	export ESTV_FCES_SER=${DFILT}/${NJOB}_20_${IB}_SORT_FCES_O.dat
	export ESTV_FPLC_SER=${DFILT}/${NJOB}_25_${IB}_SORT_FPLC_O.dat

else

	if [ ! -f ${EST_FCES} ]
	then
		touch ${DFILT}/${NJOB}_${IB}_FCES_EMPTYFILE.dat
		export ESTV_FCES_SER=`ls ${DFILT}/${NJOB}_${IB}_FCES_*.dat  2> /dev/null | sort -u | sed -n -e $,1p`  # modif OG 17/05/2000
	else
		export ESTV_FCES_SER=`ls ${EST_FCES}  2> /dev/null | sort -u | sed -n -e $,1p`  # modif OG 17/05/2000

	fi
	if [ ! -f ${EST_FPLC} ]
	then
		touch ${DFILT}/${NJOB}_${IB}_FPLC_EMPTYFILE.dat
		export ESTV_FPLC_SER=`ls ${DFILT}/${NJOB}_${IB}_FPLC_*.dat  2> /dev/null | sort -u | sed -n -e $,1p`  # modif OG 17/05/2000
	else
		export ESTV_FPLC_SER=`ls ${EST_FPLC}  2> /dev/null | sort -u | sed -n -e $,1p`
	fi

fi

NSTEP=${NJOB}_35
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Working tables truncate"
ISQL_BASE="BEST"
ISQL_QRY="truncate table BTRAV..EST_ESFD0070_TACCSUP  truncate table BTRAV..EST_ESFJ0090_TESTCES  truncate table BTRAV..EST_ESFJ0090_TESTPLC"
ISQL

#[007]
NSTEP=${NJOB}_40
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Transformation of service writing file into extended LT format"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_FACCSUP_O.dat 1000 1" #[004]
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat 1000 1" #[004]
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRN_NT 1:1 - 1:
       ,ACCTYP_NF 2:1 - 2:
       ,SSD_CF 3:1 - 3:
       ,ESB_CF 4:1 - 4:
       ,ENTPERY_NF 5:1 - 5:
       ,ENTPERMTH_NF 6:1 - 6:
       ,BALSHEY_NF 7:1 - 7:
       ,BALSHRMTH_NF 8:1 - 8:
       ,BALSHRDAY_NF 9:1 - 9:
       ,VALPERY_NF 10:1 - 10:
       ,VALPERMTH_NF 11:1 - 11:
       ,TRNCOD_CF 12:1 - 12:
       ,DBLTRNCOD_CF 13:1 - 13:
       ,CTR_NF 15:1 - 15:
       ,END_NT 16:1 - 16:
       ,SEC_NF 17:1 - 17:
       ,UWY_NF 18:1 - 18:
       ,UW_NT 19:1 - 19:
       ,OCCYEA_NF 20:1 - 20:
       ,ACY_NF 21:1 - 21:
       ,SCOSTRMTH_NF 22:1 - 22:
       ,SCOENDMTH_NF 23:1 - 23:
       ,CLM_NF 24:1 - 24:
       ,CUR_CF 25:1 - 25:
       ,AMT_M 26:1 - 26:
       ,CED_NF 27:1 - 27:
       ,BRK_NF 28:1 - 28:
       ,PAY_NF 29:1 - 29:
       ,KEY_NF 30:1 - 30:
       ,RETCTR_NF 31:1 - 31:
       ,RETEND_NT 32:1 - 32:
       ,RETSEC_NF 33:1 - 33:
       ,RTY_NF 34:1 - 34:
       ,RETUW_NT 35:1 - 35:
       ,PLC_NT 36:1 - 36:
       ,RETOCCYEA_NF 37:1 - 37:
       ,RETACY_NF 38:1 - 38:
       ,RETSCOSTRMTH_NF 39:1 - 39:
       ,RETSCOENDMTH_NF 40:1 - 40:
       ,RCL_NF 41:1 - 41:
       ,RETCUR_CF 42:1 - 42:
       ,RETAMT_M 43:1 - 43:
       ,RTO_NF 44:1 - 44:
       ,INT_NF 45:1 - 45:
       ,RETPAY_NF 46:1 - 46:
       ,RETKEY_CF 47:1 - 47:
       ,COMMAC_LL 49:1 - 49:
       ,SPEENTTYP_CF 54:1 - 54:
       ,SPEENTNAT_CT 55:1 - 55:
       ,EVT_NF 56:1 - 56:
       ,REVT_NF 57:1 - 57:
/DERIVEDFIELD ZERO "0.000" CHAR 5
/DERIVEDFIELD SEPA "~"
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, TRNCOD_CF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CUR_CF
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, ZERO, SEPA, ENTPERY_NF, ENTPERMTH_NF, VALPERY_NF, VALPERMTH_NF, TRN_NT, ACCTYP_NF, COMMAC_LL, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
exit
EOF
SORT


NSTEP=${NJOB}_45
# Delete of temporary file
#------------------------------------------------------------------------------
LIBEL="Delete of temporary file"
RMFIL ${DFILT}/${NJOB}_05_${IB}_BCP_FACCSUP_O.dat

NSTEP=${NJOB}_48
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Selection of service writings and update of service writings table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_IADVPERICASE.dat
BCP_QRY="select CTR_NF, NAT_CF from BTRT..TSECTION where SSD_CF in ( select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF= suser_name()) 
union 
select CTR_NF, NAT_CF from BFAC..TSECTION where SSD_CF in ( select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF= suser_name())"
BCP

echo "ESTC2333_I1=${DFILT}/${NJOB}_40_${IB}_SORT_GTAA_O.dat"
echo "ESTC2333_I2=${ESTV_FCES_SER}"
echo "ESTC2333_I3=${EST_FDETTRS}"
echo "ESTC2333_I4=${EST_FTRANSCODE}"
echo "ESTC2333_I5=${DFILT}/${NJOB}_48_${IB}_BCP_IADVPERICASE.dat"


#[009]
NSTEP=${NJOB}_50
# Begin programme C TYPETRAIT=L/A (local/Autres)
#------------------------------------------------------------------------------
LIBEL="Application of cessions operator"
PRG=ESTC2333
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
GTE_B 1
TYPETRAIT A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_GTAA_O.dat
export ${PRG}_I2=${ESTV_FCES_SER}
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
#export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_I5=${DFILT}/${NJOB}_48_${IB}_BCP_IADVPERICASE.dat

export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O1.dat
EXECPRG

##----------------
gzip -c ${DFILT}/${NJOB}_40_${IB}_SORT_GTAA_O.dat > ${DFILT}/${NJOB}_40_SORT_GTAA_O.dat.gz
##----------------

NSTEP=${NJOB}_55
# Delete of temporary files
#------------------------------------------------------------------------------
LIBEL="Delete of temporary files"
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_GTAA_O.dat

##----------------
gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC2333_GTAR100_O1.dat > ${DFILT}/${NJOB}_50_ESTC2333_GTAR100_O1.dat.gz
##----------------

NSTEP=${NJOB}_60
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC2333_GTAR100_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat 1000 1" #[004]
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, OCCYEA_NF 13:1 - 13:, ACY_NF 14:1 - 14:, SCOSTRMTH_NF 15:1 - 15:, SCOENDMTH_NF 16:1 - 16:, CLM_NF 17:1 - 17:, CUR_CF 18:1 - 18:, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETOCCYEA_NF 29:1 - 29:, RETACY_NF 30:1 - 30:, RETSCOSTRMTH_NF 31:1 - 31:, RETSCOENDMTH_NF 32:1 - 32:, RCL_NF 33:1 - 33:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, TRNCOD_CF, CUR_CF, RETOCCYEA_NF, RCL_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT , OCCYEA_NF, CLM_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF
exit
EOF
SORT

NSTEP=${NJOB}_65
# Delete of temporary file
#------------------------------------------------------------------------------
LIBEL="Delete of temporary file"
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTC2333_GTAR100_O1.dat

NSTEP=${NJOB}_70
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Application of placements operator"
PRG=ESTC2334
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTRR_B 0
BALSHTYEA_NF ${BALSHTYEA_NF}
GTE_B 1
PRS 50
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_GTAR100_O.dat
export ${PRG}_I2=${ESTV_FPLC_SER}
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ_O2.dat
EXECPRG

NSTEP=${NJOB}_75
# Delete of temporary files
#------------------------------------------------------------------------------
LIBEL="Delete of temporary files"
RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_GTAR100_O.dat

#[007]
NSTEP=${NJOB}_80
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_ESTC2334_GTAR_O1.dat  1000 1 "
SORT_I2="${DFILT}/${NJOB}_70_${IB}_ESTC2334_GTARMAJ_O2.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_O.dat 1000 1" #[004]
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
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
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        ENTPERY_NF 42:1 - 42:,
        ENTPERMTH_NF 43:1 - 43:,
        VALPERY_NF 44:1 - 44:,
        VALPERMTH_NF 45:1 - 45:,
        TRN_NT 46:1 - 46:,
        ACCTYP_NF 47:1 - 47:,
        BALSHEY_NF 48:1 - 48:,
        BALSHRMTH_NF 49:1 - 49:,
        BALSHRDAY_NF 50:1 - 50:,
        COMMAC_LL 51:1 - 51:,
        SPEENTTYP_CF 52:1 - 52:,
        SPEENTNAT_CT 53:1 - 53:,
        EVT_NF 54:1 - 54:,
        REVT_NF 55:1 - 55:
/KEYS   SSD_CF,
        ESB_CF,
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
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        ENTPERY_NF,
        ENTPERMTH_NF,
        VALPERY_NF,
        VALPERMTH_NF,
        TRN_NT,
        ACCTYP_NF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
        COMMAC_LL,
        SPEENTTYP_CF,
        SPEENTNAT_CT,
        EVT_NF,
        REVT_NF
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_83
# Delete of temporary files
#------------------------------------------------------------------------------
LIBEL="Delete of temporary files"
RMFIL ${DFILT}/${NJOB}_70_${IB}_ESTC2334_GTAR_O1.dat
RMFIL ${DFILT}/${NJOB}_70_${IB}_ESTC2334_GTARMAJ_O2.dat

#[007]
NSTEP=${NJOB}_85
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_SORT_FACCSUP_O.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCSUP_O.dat 1000 1" #[004]
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:, ESB_CF 2:1 - 2:, TRNCOD_CF 6:1 - 6:, DBLTRNCOD_CF 7:1 - 7:, CTR_NF 8:1 - 8:, END_NT 9:1 - 9:, SEC_NF 10:1 - 10:, UWY_NF 11:1 - 11:, UW_NT 12:1 - 12:, OCCYEA_NF 13:1 - 13:, ACY_NF 14:1 - 14:, SCOSTRMTH_NF 15:1 - 15:, SCOENDMTH_NF 16:1 - 16:, CLM_NF 17:1 - 17:, CUR_CF 18:1 - 18:, AMT_M 19:1 - 19:, CED_NF 20:1 - 20:, BRK_NF 21:1 - 21:, PAY_NF 22:1 - 22:, KEY_NF 23:1 - 23:, RETCTR_NF 24:1 - 24:, RETEND_NT 25:1 - 25:, RETSEC_NF 26:1 - 26:, RTY_NF 27:1 - 27:, RETUW_NT 28:1 - 28:, RETOCCYEA_NF 29:1 - 29:, RETACY_NF 30:1 - 30:, RETSCOSTRMTH_NF 31:1 - 31:, RETSCOENDMTH_NF 32:1 - 32:, RCL_NF 33:1 - 33:, RETCUR_CF 34:1 - 34:, RETAMT_M 35:1 - 35:, PLC_NT 36:1 - 36:, RTO_NF 37:1 - 37:, INT_NF 38:1 - 38:, RETPAY_NF 39:1 - 39:, RETKEY_CF 40:1 - 40:, RETINTAMT_M 41:1 - 41:, ENTPERY_NF 42:1 - 42:, ENTPERMTH_NF 43:1 - 43:, VALPERY_NF 44:1 - 44:, VALPERMTH_NF 45:1 - 45:, TRN_NT 46:1 - 46:, ACCTYP_NF 47:1 - 47:, BALSHEY_NF 48:1 - 48:, BALSHRMTH_NF 49:1 - 49:, BALSHRDAY_NF 50:1 - 50:, COMMAC_LL 51:1 - 51:, SPEENTTYP_CF 52:1 - 52:, SPEENTNAT_CT 53:1 - 53:, EVT_NF 54:1 - 54:, REVT_NF 55:1 - 55:
/COPY
/CONDITION TYP1 ACCTYP_NF EQ "1"
/DERIVEDFIELD SEPA "~"
/DERIVEDFIELD TYP_NF IF TYP1 THEN "00" ELSE "98" CHAR 2
/DERIVEDFIELD ZERO "0" CHAR 1
/DERIVEDFIELD VIDE ""
/DERIVEDFIELD CRE_D "${CRE_D}"
/DERIVEDFIELD LSTUPDUSR_CF "AG"
/OUTFILE ${SORT_O}
/REFORMAT TYP_NF, SEPA, SSD_CF, ESB_CF, ENTPERY_NF, ENTPERMTH_NF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, VALPERY_NF, VALPERMTH_NF, TRNCOD_CF, DBLTRNCOD_CF, ZERO, SEPA, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, PLC_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, TRN_NT, COMMAC_LL, CRE_D, SEPA, VIDE, SEPA, CRE_D, SEPA, LSTUPDUSR_CF, SEPA, SPEENTTYP_CF, SPEENTNAT_CT, EVT_NF, REVT_NF
exit
EOF
SORT

NSTEP=${NJOB}_87
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_80_${IB}_SORT_FACCSUP_O.dat

NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="Selection of the largest TRN_NT from TACCSUP"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="select isnull(max(TRN_NT),0) from BEST..TACCSUP"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O.dat
BCP

#The largest TRN_NT is affected to TRNMAX_NT
TRNMAX_NT=`cat ${BCP_O}`

NSTEP=${NJOB}_95
#-----------------------------------------------------------------------------
LIBEL="Adding an identity column to the Accetance TL"
PRG=ESTC8800
FPRM=`CFTMP`
INPUT_TEXT $FPRM << EOF
TRN_NT ${TRNMAX_NT}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_85_${IB}_SORT_FACCSUP_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FACCSUP_O.dat
EXECPRG

NSTEP=${NJOB}_100
# Delete of temporary file
#------------------------------------------------------------------------------
LIBEL="Delete of temporary file"
RMFIL ${DFILT}/${NJOB}_85_${IB}_SORT_FACCSUP_O.dat

NSTEP=${NJOB}_105
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Transfer of service writing file into BEST..TACCSUP table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_95_${IB}_ESTC8800_FACCSUP_O.dat
BCP_TABLE="BEST..TACCSUP"
BCP

NSTEP=${NJOB}_110
# Update of double entry transaction code
#------------------------------------------------------------------------------
LIBEL="Update of double entry transaction code"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PuACCSUP_02 ${TRNMAX_NT}"
ISQL

NSTEP=${NJOB}_115
#------------------------------------------------------------------------------
LIBEL="Delete of temporary file"
RMFIL ${DFILT}/${NJOB}_95_${IB}_ESTC8800_FACCSUP_O.dat

#[010]
#NSTEP=${NJOB}_120
##------------------------------------------------------------------------------
#LIBEL="Convert BEST..TACCSUP into a file for the copy in BSAR..TACCSUP"
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_QRY="select a.* from BEST..TACCSUP a, BREF..TBATCHSSD T where a.SSD_CF=T.SSD_CF and T.BATCHUSER_CF=suser_name()"
#BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FACCSUP_O.dat
#BCP


#NSTEP=${NJOB}_123
## Begin bcp
##------------------------------------------------------------------------------
#LIBEL=" FREQJOB File Generation"
#BCP_WAY="OUT"; BCP_VER="+"
#BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FREQJOB_O.dat
#BCP_QRY="execute BEST..PtREQJOB_01 '${CRE_D}'"
#BCP
#
#
NSTEP=${NJOB}_125
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}
#
#if [ -s ${DFILT}/${NJOB}_123_${IB}_BCP_FREQJOB_O.dat ] ; then
#
## Get input parameters from FREQJOB
#set `GETPRM ${DFILT}/${NJOB}_123_${IB}_BCP_FREQJOB_O.dat`
#USR_CF=${1}
#CLOPER_LS=${2}
#BLSYEA_NF=${3}
#BLSMTH_NF=${4}
#CLO_D=${5}
#
#NSTEP=${NJOB}_127
## Begin bcp
##------------------------------------------------------------------------------
#LIBEL=" Update or insert lines in TBOPAR for closing tables "
#ISQL_BASE="BSTA"
#ISQL_QRY="execute PtTBOPAR_01 '${USR_CF}', '${CLOPER_LS}', ${BLSYEA_NF}, ${BLSMTH_NF}, '${CLO_D}' "
#ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
#ISQL
#
#
#fi

#[010]
#NSTEP=${NJOB}_130
##------------------------------------------------------------------------------
#LIBEL="Copy of BEST..TACCSUP file into BSAR..TACCSUP"
#BCP_WAY="IN"
#BCP_VER=""
#BCP_I=${DFILT}/${NJOB}_120_${IB}_BCP_FACCSUP_O.dat
#BCP_TRUNCATE=YES
#BCP_PARTITION=YES
#BCP_UPDATE_INDEX_STAT=YES
#BCP_TABLE="BSAR..TACCSUP"
#BCP

NSTEP=${NJOB}_140
#------------------------------------------------------------------------------
LIBEL="Deletion of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND
