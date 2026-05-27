#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G 
# nom du script SHELL           : 
# revision                      : $Revision:   1.0  $
# date de creation              : 11/05/2021
# auteur                        : Cyril AVINENS
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 REQ , SAP posting
#-----------------------------------------------------------------------------# 
# Modifications
#  [001] ART Spira#100115 SAP Delta posting IFRS4
#  [002] ART Spira#104445 NRT- Delta posting I4I >> DELTA Calculation issue
#  [003] FCI Spira#109243 SAP Delta Posting- Issue with balsheet month format
#  [004] FCI Spira#109392 SAP delta calculation - Data format
#  [005] DAD Spira#109761 Delta calculation - blank not used field
#  [006] JYP Spira#109764 Delta calculation - blank not used field => move to next job ESFD3962
#  [007] JYP Spira#109764 remove GEMPRMPAY in keys 
#  [008] JYP Spira#112710 optimisation step 10
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================"
ECHO_LOG "#===> ............ PARAMETER ............................"
ECHO_LOG "#===> NORME_CF...........................................: ${NORME_CF}"
if [  ${NORME_CF} = "I4I" ]
then
ECHO_LOG "#===> PARM_BALSHEYEA_NF..................................: ${PARM_BALSHEYEA_NF}"
ECHO_LOG "#===> PARM_BALSHTMTH_NF..................................: ${PARM_BALSHTMTH_NF}"
fi
ECHO_LOG "#===> ............ INPUT ................................"
ECHO_LOG "#===> ESF_FTECLEDA_GLT_MVT...............................: ${ESF_FTECLEDA_GLT_MVT}"
ECHO_LOG "#===> ESF_FTECLEDA_SAP_MVT...............................: ${ESF_FTECLEDA_SAP_MVT}"
ECHO_LOG "#===> ............ OUTPUT ..............................."
ECHO_LOG "#===> ESF_FTECLEDA_DELTA.................................: ${ESF_FTECLEDA_DELTA}"

ECHO_LOG "#========================================================"


if [ ! -e "${ESF_FTECLEDA_SAP_MVT}" ]
then

#------------------------------------------------------------------------------
NSTEP=${NJOB}_05
LIBEL="Generate empty file because file ESF_FTECLEDA_SAP_MVT not found"
EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_INVERTED_SAP.dat"

else

#------------------------------------------------------------------------------
NSTEP=${NJOB}_05
LIBEL="Compute inverse amount of the SAP current view & Reformat BALSHRMTH_NF and BALSHRDAY_NF from ESF_FTECLEDA_SAP_MVT"
AWK_I=${ESF_FTECLEDA_SAP_MVT}
AWK_O=${DFILT}/${NSTEP}_${IB}_INVERTED_SAP.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
		 if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
		 if ( \$88 != 0 ) \$88 = sprintf("%-.3lf",-\$88);
		 
		 if (substr(\$4,1,1) == "0") \$4 = substr(\$4,2,1);
		 if (substr(\$5,1,1) == "0") \$5 = substr(\$5,2,1);
		 
		 if (substr(\$15,1,1) == "0") \$15 = substr(\$15,2,1);
		 if (substr(\$16,1,1) == "0") \$16 = substr(\$16,2,1);
		 
		 if (substr(\$31,1,1) == "0") \$31 = substr(\$31,2,1);
		 if (substr(\$32,1,1) == "0") \$32 = substr(\$32,2,1);
             print \$0 }
exit
EOF
AWK

fi

if [  ${NORME_CF} = "I4I" ]
then
#------------------------------------------------------------------------------
NSTEP=${NJOB}_07
LIBEL="Set BALSHEY_NF, BALSHRMTH_NF  and BALSHRDAY_NF for SAP  IF NORME_CF = I4I"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_INVERTED_SAP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SET_BALSH_DATE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1            1:1 -  2:,
								BALSHEY_NF       		3:1 -  3:,
								BALSHRMTH_NF       4:1 -  4:,
        BALSHRDAY_NF       5:1 -  5:,
        FILLER2            6:1 -  118:
/DERIVEDFIELD NEW_BALSHEY_NF "${PARM_BALSHEYEA_NF}~"
/DERIVEDFIELD NEW_BALSHRMTH_NF "${PARM_BALSHTMTH_NF}~"
/DERIVEDFIELD NEW_BALSHRDAY "1~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,
										NEW_BALSHEY_NF,
										NEW_BALSHRMTH_NF,
										NEW_BALSHRDAY,
										FILLER2
exit
EOF
SORT
fi

#------------------------------------------------------------------------------
NSTEP=${NJOB}_08
LIBEL="Reformat BALSHRMTH_NF and BALSHRDAY_NF from ESF_FTECLEDA_GLT_MVT"
AWK_I=${ESF_FTECLEDA_GLT_MVT}
AWK_O=${DFILT}/${NSTEP}_${IB}_GLT_REFORMATED.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="~"; OFS="~"; s="" }
       { if (substr(\$4,1,1) == "0") \$4 = substr(\$4,2,1);
		 if (substr(\$5,1,1) == "0") \$5 = substr(\$5,2,1);
		 
		 if (substr(\$15,1,1) == "0") \$15 = substr(\$15,2,1);
		 if (substr(\$16,1,1) == "0") \$16 = substr(\$16,2,1);
		 
		 if (substr(\$31,1,1) == "0") \$31 = substr(\$31,2,1);
		 if (substr(\$32,1,1) == "0") \$32 = substr(\$32,2,1);
	print \$0 	}

exit
EOF
AWK


#------------------------------------------------------------------------------
NSTEP=${NJOB}_10
LIBEL="Merge and clear blank in files"
ECHO_LOG "#========================================================================="
ECHO_LOG "# Begin of step : STEP $NSTEP : $LIBEL : $NORME_CF "
date >> $FLOG
	if [  ${NORME_CF} = "I4I" ]
	then
		cat ${DFILT}/${NJOB}_08_${IB}_GLT_REFORMATED.dat ${DFILT}/${NJOB}_07_${IB}_SET_BALSH_DATE.dat > ${DFILT}/${NSTEP}_${IB}_CLEAR_FILE.dat 
		RC=$?
	fi
	if [  ${NORME_CF:0:3} = "I17" -o ${NORME_CF} = "EBS" ]
	then
		cat ${DFILT}/${NJOB}_08_${IB}_GLT_REFORMATED.dat ${DFILT}/${NJOB}_05_${IB}_INVERTED_SAP.dat > ${DFILT}/${NSTEP}_${IB}_CLEAR_FILE.dat 
		RC=$?
	fi

	wc -l ${DFILT}/${NSTEP}_${IB}_CLEAR_FILE.dat   >> $FLOG
	ls -ltr ${DFILT}/${NSTEP}_${IB}_CLEAR_FILE.dat  >> $FLOG
ECHO_LOG "# End of step : return code $RC "
date >> $FLOG
ECHO_LOG "#========================================================================="
		
#------------------------------------------------------------------------------
NSTEP=${NJOB}_15
LIBEL="Compute the delta amount and generate output transaction"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_CLEAR_FILE.dat 2000 1"
SORT_O="${ESF_FTECLEDA_DELTA} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF				1:1 - 1:EN,
	ESB_CF				2:1 - 2:EN,
	BALSHEY_NF			3:1 - 3:EN,
	BALSHRMTH_NF		4:1 - 4:EN,
	BALSHRDAY_NF		5:1 - 5:EN,
	TRNCOD_CF			6:1 - 6:,
	DBLTRNCOD_CF		7:1 - 7:,
	CTR_NF				8:1 - 8:,
	END_NT				9:1 - 9:,
	SEC_NF				10:1 - 10:,
	UWY_NF				11:1 - 11:,
	UW_NT				12:1 - 12:,
	OCCYEA_NF			13:1 - 13:EN,
	ACY_NF				14:1 - 14:EN,
	SCOSTRMTH_NF		15:1 - 15:EN,
	SCOENDMTH_NF		16:1 - 16:EN,
	CLM_NF				17:1 - 17:,
	CUR_CF				18:1 - 18:,
	AMT_M				19:1 - 19:EN,
	CED_NF				20:1 - 20:,
	BRK_NF				21:1 - 21:,
	GEMPRMPAY_NF		22:1 - 22:,
	GANPAYORD_NT		23:1 - 23:,
	RETCTR_NF			24:1 - 24:,
	RETEND_NT			25:1 - 25:,
	RETSEC_NF			26:1 - 26:,
	RETRTY_NF			27:1 - 27:,
	RETUW_NT			28:1 - 28:,
	RETOCCYEA_NF		29:1 - 29:EN,
	RETACY_NF			30:1 - 30:EN,
	RETSCOSTRMTH_NF		31:1 - 31:EN,
	RETSCOENDMTH_NF		32:1 - 32:EN,
	RCL_NF				33:1 - 33:,
	RETCUR_CF			34:1 - 34:,
	RETAMT_M			35:1 - 35:EN,
	PLC_NT				36:1 - 36:,
	RTO_NF				37:1 - 37:,
	INT_NF				38:1 - 38:,
	RETPAY_NF			39:1 - 39:,
	RETKEY_CF			40:1 - 40:,
	CRE_D				41:1 - 41:,
	CREUSR_CF			42:1 - 42:,
	LSTUPD_D			43:1 - 43:,
	LSTUPDUSR_CF		44:1 - 44:,
	LOBACC_CF			45:1 - 45:,
	LOBRET_CF			46:1 - 46:,
	SOBACC_CF			47:1 - 47:,
	SOBRET_CF			48:1 - 48:,
	TOPACC_CF			49:1 - 49:,
	TOPRET_CF			50:1 - 50:,
	NATACC_CF			51:1 - 51:,
	NATRET_CF			52:1 - 52:,
	GARACC_CF			53:1 - 53:,
	GARRET_CF			54:1 - 54:,
	PCPRSKTRYACC_CF		55:1 - 55:,
	PCPRSKTRYRET_CF		56:1 - 56:,
	USRCRTCODACC_CT		57:1 - 57:,
	USRCRTCODRET_CT		58:1 - 58:,
	USRCRTVALACC_LM		59:1 - 59:,
	USRCRTVALRET_LM		60:1 - 60:,
	CTRNAT_CT			61:1 - 61:,
	RETCTRCAT_CF		62:1 - 62:,
	WRKCAT_CT			63:1 - 63:,
	PRDCOD_CT			64:1 - 64:,
	ANLCTY_CF			65:1 - 65:,
	ACCADMTYP_CT		66:1 - 66:,
	RETACCTYP_CT		67:1 - 67:,
	COMACC_B			68:1 - 68:,
	CPLACCUPD_D			69:1 - 69:,
	CTRRET_B			70:1 - 70:,
	UWGRP_CF			71:1 - 71:,
	VRS_NF				72:1 - 72:,
	SEG_NF				73:1 - 73:,
	UWORG_CF			74:1 - 74:,
	ESTCRB_CT			75:1 - 75:,
	ESTCTR_NF			76:1 - 76:,
	ESBACC_CF			77:1 - 77:,
	ORGCED_NF			78:1 - 78:,
	CEDHORDNBR_NT		79:1 - 79:,
	CEDSORDNBR_NT		80:1 - 80:,
	ORGCEDHORDNBR_NT	81:1 - 81:,
	ORGCEDSORDNBR_NT	82:1 - 82:,
	BRKHORDNBR_NT		83:1 - 83:,
	BRKSORDNBR_NT		84:1 - 84:,
	FACADMTYP_CT		85:1 - 85:,
	CLIIND_NF			86:1 - 86:,
	HORDNBR_NT			87:1 - 87:,
	RETINTAMT_M			88:1 - 88:EN,
	BUKRS_CF			89:1 - 89:,
	RCOMP_CF			90:1 - 90:,
	LDGRP_CF			91:1 - 91:,
	HKONT_CF			92:1 - 92:,
	DBLHKONT_CF			93:1 - 93:,
	GJAHR_NF			94:1 - 94:,
	MONAT_NF			95:1 - 95:,
	VBUND_CF			96:1 - 96:,
	ZZCED_NF			97:1 - 97:,
	SEGMENT_CF			98:1 - 98:,
	BEWAR_CF			99:1 - 99:,
	ZZGAAPDIF_CF		100:1 - 100:,
	BLART_CF			101:1 - 101:,
	ZZRECONKEY_CF		102:1 - 102:,
	TRN_NT				103:1 - 103:,
	ORICOD_LS			104:1 - 104:,
	RETROAUTO_B			105:1 - 105:,
	SPEENTNAT_CT		106:1 - 106:,
	EVT_NF				107:1 - 107:,
	REVT_NF				108:1 - 108:,
	RETARDRETINT_B		109:1 - 109:,
	NEWCOLS1_NF			110:1 - 110:,
	GAAPCOD_NT			111:1 - 111:,
	I17PRDCOD_CT		112:1 - 112:,
	NEWCOLS4_NF			113:1 - 113:,
	NEWCOLS5_NF			114:1 - 114:,
	NEWCOLS6_NF			115:1 - 115:,
	NEWCOLS7_NF			116:1 - 116:,
	NEWCOLS8_NF			117:1 - 117:,
	NEWCOLS9_NF			118:1 - 118:
/KEYS SSD_CF,		
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
	GANPAYORD_NT,	
    RETCTR_NF,
    RETEND_NT,		
    RETSEC_NF,		
    RETRTY_NF,		
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
    LOBACC_CF,		
    LOBRET_CF,		
    SOBACC_CF,	
    SOBRET_CF,		
    TOPACC_CF,		
    TOPRET_CF,		
    NATACC_CF,		
    NATRET_CF,		
    GARACC_CF,		
    GARRET_CF,	
    CTRNAT_CT,		
    RETCTRCAT_CF,		
	ACCADMTYP_CT,
	RETACCTYP_CT,		
    CPLACCUPD_D,	
    CTRRET_B,		
    UWGRP_CF,		
    VRS_NF,			
    SEG_NF,			
    UWORG_CF,		
    ESTCRB_CT,		
    ESTCTR_NF,		
    ESBACC_CF,	
    TRN_NT,		
    ORICOD_LS,		
    RETROAUTO_B,		
    SPEENTNAT_CT,	
    EVT_NF,			
    REVT_NF,			
    RETARDRETINT_B,
    GAAPCOD_NT,	
    I17PRDCOD_CT
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/CONDITION ZERO_AMT AMT_M = 0 and RETAMT_M = 0 and RETINTAMT_M = 0
/OUTFILE ${SORT_O}
/OMIT ZERO_AMT

exit
EOF
SORT


########################
# Erase temporary files #
########################
NSTEP=${NJOB}_30
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
