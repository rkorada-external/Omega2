#!/bin/ksh
#=============================================================================
# nom de l'application     : ESTIMATIONS - preparation des fichiers pour one GL
# nom du script SHELL      : ESPD3861.cmd
# date de creation         : 15/03/2011
# auteur                   : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:              
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#[001]	12/04/2023 JYP/TD :spira:109178: new version created from old ESFD3961 
#[002]  25/04/2023 JYP/TD :spira:109440: flag POSTING_UPDATE_CANCELED from ESFD3460-recover
#[003]  10/05/2023 JYP/TD :spira:109440: flag POSTING_UPDATE_CANCELED from ESFD3460-recover
#[004]	18/04/2024 JYP    :spira 111359: move MDEL file in a specific job
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctftp.cmd


POSTING_UPDATE_CANCELED=$1

# Job Initialisation
JOBINIT


ECHO_LOG "#========================================================================="
ECHO_LOG "-> ESF_FICFROMONEGL ...........: ${ESF_FICFROMONEGL}"
ECHO_LOG "-> ESF_FICFROMONEGLARC ........: ${ESF_FICFROMONEGLARC}"
ECHO_LOG "-> ESF_FTECLEDA_MVT_TMP .......: ${ESF_FTECLEDA_MVT_TMP}"
ECHO_LOG "-> ESF_FTECLEDA_MVT ...........: ${ESF_FTECLEDA_MVT}"
ECHO_LOG "-> ESF_FTECLEDA_POSTING .......: ${ESF_FTECLEDA_POSTING}"
ECHO_LOG "-> POSTING_UPDATE_CANCELED ....: ${POSTING_UPDATE_CANCELED}"
ECHO_LOG "-> SITE_ONEGL .................: ${SITE_ONEGL}"
ECHO_LOG "-> SAP Interface (0=NO/1=YES)..: ${ENV_SAP}"
ECHO_LOG "-> SAP MODE (4=SIMU/1=COMPTA)..: ${MODE}"
ECHO_LOG "#========================================================================="



NSTEP=${NJOB}_40
# Begin execksh
#-----------------------------------------------------------------
LIBEL="mv ${ESF_FTECLEDA_MVT_TMP} ${ESF_FTECLEDA_MVT}"
EXECKSH_MODE=P
EXECKSH "mv ${ESF_FTECLEDA_MVT_TMP} ${ESF_FTECLEDA_MVT}"


# Save SAP file to ONEGL
if [ -f ${ESF_FTECLEDA_MVT} ] && [ "${ENV_SAP}" = "1" ]
then

   if [ "$POSTING_UPDATE_CANCELED" != "Y" ]
   then
 
	#[004]
	NSTEP=${NJOB}_50
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DTRANSFER}/OneGL/fromsave/${ENV_PREFIX}_${ESF_FICFROMONEGL}.dat.gz"

	#[005] [006]
	NSTEP=${NJOB}_60
	# ARCHIVAGE
	#----------------------------------------------------------------------------
	LIBEL="Archive last file into DARCH or DSAVE : ${ESF_FICFROMONEGLARC}"
	EXECKSH_MODE=P
	if [ "${MODE}" = "4" ]
	then 
		EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DSAVE}/${ENV_PREFIX}_${ESF_FICFROMONEGLARC}.dat.gz"
	else
		EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DARCH}/${ENV_PREFIX}_${ESF_FICFROMONEGLARC}.dat.gz"	
	fi 
	

    else
	  ECHO_LOG "--> POSTING_UPDATE_CANCELED=$POSTING_UPDATE_CANCELED , FTP_file is managed by ESFD3460-recover "			 

		NSTEP=${NJOB}_75
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive last file to DSAV : ${ESF_FICFROMONEGLARC}"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DSAVE}/${ENV_PREFIX}_${ESF_FICFROMONEGLARC}_CANCELED.dat.gz"

	fi
	
fi


#update RA
NSTEP=${NJOB}_80
#-----------------------------------------------------------------
LIBEL="UPDATE RA : Merge POSTING + MVT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_MVT} 2000 1"
SORT_I2="${ESF_FTECLEDA_POSTING} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_RA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
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
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_90
# summarize TTECLEDA by BALSHTDAY
#--------------------------------
LIBEL="Summarize TTECLEDA by BALSHTDAY into ESF_FTECLEDA_RA=$ESF_FTECLEDA_RA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_FTECLEDA_RA.dat 2000 1"
SORT_O="${ESF_FTECLEDA_RA} 2000 1"
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
	AMT_M            19:1 -  19:EN 18/3,
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
	RETAMT_M         35:1 -  35:EN 18/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
  	CRE_D            41:1 -  41:,
	RETINTAMT_M      88:1 -  88:EN 18/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:,
	GAAPCOD_NF      111:1 - 111:,
	I17PRDCOD_CT    112:1 - 112:

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
	RETARDRETINT_B,
	GAAPCOD_NF,
	I17PRDCOD_CT
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT


if [ "${PARM_IS_SAP_POSTING}" = "Y" ]
then

	if [ "$POSTING_UPDATE_CANCELED" != "Y" ]
    then

		NSTEP=${NJOB}_100
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive last Posting file to DARCH : ${ESF_FTECLEDA_POSTING_ARC_AVANT}"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${ESF_FTECLEDA_POSTING} > ${DARCH}/${ESF_FTECLEDA_POSTING_ARC_AVANT}.gz"
		
		NSTEP=${NJOB}_110
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="OVERWRITE POSTING : cp ${ESF_FTECLEDA_RA} ${ESF_FTECLEDA_POSTING}"
		EXECKSH_MODE=P
		EXECKSH "cp ${ESF_FTECLEDA_RA} ${ESF_FTECLEDA_POSTING}"
		
		NSTEP=${NJOB}_120
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive last Posting file to DARCH : ${ESF_FTECLEDA_POSTING_ARC_APRES}"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${ESF_FTECLEDA_POSTING} > ${DARCH}/${ESF_FTECLEDA_POSTING_ARC_APRES}.gz"

	else
					NSTEP=${NJOB}_130
					#-----------------------------------------------------------------------------
					LIBEL="set POSTING_UPDATE_CANCELED from Y to N into ${ESFD3960_PRM}  "
					AWK_I=${ESFD3960_PRM}
					AWK_O=${DFILT}/${NJOB}_130_${IB}_POSTING_UPDATE_CANCELED_${NORME_CF}.dat
					AWK_CMD=`CFTMP`
					INPUT_TEXT ${AWK_CMD} <<EOF
					{ 
					if (substr(\$1,1,23) != "POSTING_UPDATE_CANCELED" ) 
						{print \$0;}
					}
					END { print "POSTING_UPDATE_CANCELED N";} 
					exit
EOF
					AWK
					cp -p ${DFILT}/${NJOB}_130_${IB}_POSTING_UPDATE_CANCELED_${NORME_CF}.dat ${ESFD3960_PRM}

    fi	

fi


		
NSTEP=${NJOB}_140
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

