#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 Cashflow Inception
# nom du script SHELL           : ESFD3614.cmd
# date de creation              : 17/08/2021
# auteur                        : JYP - PERSEE
# references des specifications : spira 92591
#-----------------------------------------------------------------------------
# description
#   IFRS17 Cashflow Inception
#   filter AE => reverse AE amounts => merge AE with futures
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[01] 17/08/2021 JYP SPIRA 92591: AE at inception 
#[02] 04/10/2021 JYP SPIRA 92591: AE at inception, exclude some groupings
#[03] 19/04/2021 JYP SPIRA 92591: AE at inception bugfix big amounts
#[04] 07/07/2021 MZM SPIRA 92591: AE at inception bugfix big amounts Non convertis
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT



ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT ....................: ${IDF_CT} "
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}  "
ECHO_LOG "#===> PATTYP_CT..................: ${PATTYP_CT}  "
ECHO_LOG "#===> CONTEXT_CT ................: ${CONTEXT_CT} "
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> PARM_CRE_D.................: $PARM_CRE_D"
ECHO_LOG "#===> PARM_CLODAT_D..............: $PARM_CLODAT_D"
ECHO_LOG "#===> ICLODAT_D .................: $ICLODAT_D "
ECHO_LOG "#===> PARM_INVCONSO_D ...........: $PARM_INVCONSO_D"
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#==> EST_DLDGTAA ................:  $EST_DLDGTAA     "
ECHO_LOG "#==> ESF_DLDGTR_NP ..............:  $ESF_DLDGTR_NP     "
ECHO_LOG "#==> EST_DLSGTAA ................:  $EST_DLSGTAA     "
ECHO_LOG "#==> EST_DLSGTAR ................:  $EST_DLSGTAR      "
ECHO_LOG "#==> EST_AEPRSMAP ...............:  $EST_AEPRSMAP          "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#==> EST_DLDGTAA_DLSGTAA ........:  $EST_DLDGTAA_DLSGTAA    "
ECHO_LOG "#==> EST_DLDGTAR_DLSGTAR ........:  $EST_DLDGTAR_DLSGTAR     "
ECHO_LOG "#========================================================================="




NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="INCEPTION ASSUMED : filter AE I17G/P/L EST_DLSGTAA = $EST_DLSGTAA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLSGTAA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA_AE_IFRS17_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
		START_COLS   1:1 -  5:
		,TRNCOD_37    6:3 -  6:7
		,END_COLS     8:1 - 71:
		,DETTRS_CF    1:1 -  1:	
		,TRNCOD_CF_EBS 2:1 -  2:
		,GROUPING	  4:1 -  4:		
/joinkeys
		TRNCOD_37
/INFILE ${EST_AEPRSMAP} 1000 1  "~"	
/joinkeys
        DETTRS_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:START_COLS,RIGHTSIDE:TRNCOD_CF_EBS,TRNCOD_CF_EBS,LEFTSIDE:END_COLS,RIGHTSIDE:GROUPING
exit
EOF
SORT



NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="INCEPTION RETRO: filter AE I17G/P/L EST_DLSGTAR = $EST_DLSGTAR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLSGTAR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_AE_IFRS17_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
		START_COLS    1:1 -  5:
		,TRNCOD_37    6:3 -  6:7
		,END_COLS     8:1 - 71:
		,DETTRS_CF    1:1 -  1:	
		,TRNCOD_CF_EBS 3:1 -  3:
		,GROUPING	  4:1 -  4:			
/joinkeys
		TRNCOD_37
/INFILE ${EST_AEPRSMAP} 1000 1  "~"	
/joinkeys
        DETTRS_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:START_COLS,RIGHTSIDE:TRNCOD_CF_EBS,TRNCOD_CF_EBS,LEFTSIDE:END_COLS,RIGHTSIDE:GROUPING
exit
EOF
SORT



NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="reverse assumed amounts"
#AMT_M       * -1       
#RETAMT_M    * -1   
#RETINTAMT_M * -1
AWK_I=${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAA_AE_IFRS17_O.dat
AWK_O=$DFILT/${NJOB}_30_${IB}_SORT_DLSGTAA_AE_IFRS17_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~";
       OFS="\~";
     }
     {
	 if ( \$72 != "1151" &&  \$72 != "2151" && \$72 != "2154")
      {	 
		if ( \$19 != "") { \$19=sprintf("%-.3lf",-\$19 ) } ; 
		if ( \$35 != "") { \$35=sprintf("%-.3lf",-\$35 ) } ; 
		if ( \$41 != "") { \$41=sprintf("%-.3lf",-\$41 ) } ; 
	  }
	 \$72="";
	 NF-=1;	 	  
	 print \$0 ;
     }
exit
EOF
cat $AWK_CMD >> $FLOG
AWK

#[004]

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="reverse retro amounts "
#AMT_M       * -1       
#RETAMT_M    * -1   
#RETINTAMT_M * -1
AWK_I=${DFILT}/${NJOB}_20_${IB}_SORT_DLSGTAR_AE_IFRS17_O.dat
AWK_O=$DFILT/${NJOB}_40_${IB}_SORT_DLSGTAR_AE_IFRS17_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~";
       OFS="\~";
     }
     {
	 if ( \$72 != "1151" &&  \$72 != "2151" && \$72 != "2154")
      {	 
		if ( \$19 != "") { \$19=sprintf("%-.3lf",-\$19 ) } ; 
		if ( \$35 != "") { \$35=sprintf("%-.3lf",-\$35 ) } ; 
		if ( \$41 != "") { \$41=sprintf("%-.3lf",-\$41 ) } ; 
	  }
	 \$72=""
	 NF-=1;	 
	 print \$0 ;
     }
exit
EOF
AWK



NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="merge and sum DLDGTAA with DLSGTAA  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA} 1000 1"
SORT_I2="$DFILT/${NJOB}_30_${IB}_SORT_DLSGTAA_AE_IFRS17_O.dat 1000 1"
SORT_O="${EST_DLDGTAA_DLSGTAA} 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
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
        REVT_NF         49:1 - 49:,
		END_FIELDS      50:1 - 71:
/KEYS
		SSD_CF         ,
		ESB_CF         ,
		BALSHEY_NF     ,
		BALSHRMTH_NF   ,
		BALSHRDAY_NF   ,
		TRNCOD_CF      ,
		DBLTRNCOD_CF   ,
		CTR_NF         ,
		END_NT         ,
		SEC_NF         ,
		UWY_NF         ,
		UW_NT          ,
		OCCYEA_NF      ,
		ACY_NF         ,
		SCOSTRMTH_NF   ,
		SCOENDMTH_NF   ,
		CLM_NF         ,
		CUR_CF         ,
		CED_NF         ,
		BRK_NF         ,
		PAY_NF         ,
		KEY_NF         ,
		RETCTR_NF      ,
		RETEND_NT      ,
		RETSEC_NF      ,
		RTY_NF         ,
		RETUW_NT       ,
		RETOCCYEA_NF   ,
		RETACY_NF      ,
		RETSCOSTRMTH_NF,
		RETSCOENDMTH_NF,
		RCL_NF         ,
		RETCUR_CF      ,
		PLC_NT         ,
		RTO_NF         ,
		INT_NF         ,
		RETPAY_NF      ,
		RETKEY_CF      ,
		RETAUTGEN_B    ,
		ACCTYP_NF      ,
		TRN_NT         ,
		ORICOD_LS      ,
		RETROAUTO_B    ,
		SPEENTNAT_CT   ,
		EVT_NF         ,
		REVT_NF        ,
		END_FIELDS     
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION MONTANT ( AMT_MC !=0 OR RETAMT_MC !=0 )
/OUTFILE ${SORT_O} overwrite
/INCLUDE MONTANT
exit
EOF
SORT



NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="merge and sum DLDGTAR with DLSGTAR  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLDGTR_NP} 1000 1"
SORT_I2="$DFILT/${NJOB}_40_${IB}_SORT_DLSGTAR_AE_IFRS17_O.dat 1000 1"
SORT_O="${EST_DLDGTAR_DLSGTAR} 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
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
        REVT_NF         49:1 - 49:,
		END_FIELDS      50:1 - 73:
/KEYS
		SSD_CF         ,
		ESB_CF         ,
		BALSHEY_NF     ,
		BALSHRMTH_NF   ,
		BALSHRDAY_NF   ,
		TRNCOD_CF      ,
		DBLTRNCOD_CF   ,
		CTR_NF         ,
		END_NT         ,
		SEC_NF         ,
		UWY_NF         ,
		UW_NT          ,
		OCCYEA_NF      ,
		ACY_NF         ,
		SCOSTRMTH_NF   ,
		SCOENDMTH_NF   ,
		CLM_NF         ,
		CUR_CF         ,
		CED_NF         ,
		BRK_NF         ,
		PAY_NF         ,
		KEY_NF         ,
		RETCTR_NF      ,
		RETEND_NT      ,
		RETSEC_NF      ,
		RTY_NF         ,
		RETUW_NT       ,
		RETOCCYEA_NF   ,
		RETACY_NF      ,
		RETSCOSTRMTH_NF,
		RETSCOENDMTH_NF,
		RCL_NF         ,
		RETCUR_CF      ,
		PLC_NT         ,
		RTO_NF         ,
		INT_NF         ,
		RETPAY_NF      ,
		RETKEY_CF      ,
		RETAUTGEN_B    ,
		ACCTYP_NF      ,
		TRN_NT         ,
		ORICOD_LS      ,
		RETROAUTO_B    ,
		SPEENTNAT_CT   ,
		EVT_NF         ,
		REVT_NF        ,
		END_FIELDS     
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION MONTANT ( AMT_MC !=0 OR RETAMT_MC !=0 )
/OUTFILE ${SORT_O} overwrite
/INCLUDE MONTANT
exit
EOF
SORT



JOBEND

