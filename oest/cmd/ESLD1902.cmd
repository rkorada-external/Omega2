#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE 
#                                 Extraction des ecritures de services Post Omega Local - Gestion des fichiers antérieurs d'annulation
# nom du script SHELL           : ESLD1902.cmd
# revision                      :
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description
#   Reprend les données d'annulation de la veille et génère des données pour mois en cours et conserve les donnees des autres mois (Delta)
#
# Input files
#       ESL_DLREJGTAALO_NEW
#       ESL_DLREJGTAALO_CUR
#       ESL_DLREJGTARLO_NEW
#       ESL_DLREJGTARLO_CUR
#       ESL_DLREJGTRLO_NEW
#       ESL_DLREJGTRLO_CUR
# output files
#       ESL_DLREJGTAALO  -> vers ESLD3800 pour envoi RA
#       ESL_DLREJGTAALO_CURNEW
#       ESL_DLREJGTARLO  -> vers ESLD3800 pour envoi RA
#       ESL_DLREJGTARLO_CURNEW
#       ESL_DLREJGTRLO  -> vers ESLD3800 pour envoi RA
#       ESL_DLREJGTRLO_CURNEW
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 07/12/2017 R. Cassis :spira:66334 Les fichiers perimetre ES Local sont nommés ESL_ sont maintenant générés dans le ESID7000
#[002] 07/04/2020 R. Cassis :spira:76698 On month 12, this chain is not processed, it's ESLD2900 that will be processed for annual opening
#[003] 06/01/2021 R. Cassis :spira:92383 Manage Opening records into _CUR files with month 1, day 1
#[004] 03/03/2021 R. Cassis :spira:94422 Issue on "cp" command
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
BLCSHTYEALOC_NF=${1}
BLCSHTMTHLOC_NF=${2}

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> BLCSHTYEALOC_NF..........: ${BLCSHTYEALOC_NF}"
ECHO_LOG "#===> BLCSHTMTHLOC_NF..........: ${BLCSHTMTHLOC_NF}"
ECHO_LOG "#===> ESL_DLREJGTAALO..........: ${ESL_DLREJGTAALO}"
ECHO_LOG "#===> ESL_DLREJGTAALO_CUR......: ${ESL_DLREJGTAALO_CUR}"
ECHO_LOG "#===> ESL_DLREJGTAALO_CURNEW...: ${ESL_DLREJGTAALO_CURNEW}"
ECHO_LOG "#===> ESL_DLREJGTAALO_NEW......: ${ESL_DLREJGTAALO_NEW}"
ECHO_LOG "#===> ESL_DLREJGTARLO..........: ${ESL_DLREJGTAALO}"
ECHO_LOG "#===> ESL_DLREJGTARLO_CUR......: ${ESL_DLREJGTARLO_CUR}"
ECHO_LOG "#===> ESL_DLREJGTARLO_CURNEW...: ${ESL_DLREJGTARLO_CURNEW}"
ECHO_LOG "#===> ESL_DLREJGTARLO_NEW......: ${ESL_DLREJGTARLO_NEW}"
ECHO_LOG "#===> ESL_DLREJGTRLO...........: ${ESL_DLREJGTAALO}"
ECHO_LOG "#===> ESL_DLREJGTRLO_CUR.......: ${ESL_DLREJGTRLO_CUR}"
ECHO_LOG "#===> ESL_DLREJGTRLO_CURNEW....: ${ESL_DLREJGTRLO_CURNEW}"
ECHO_LOG "#===> ESL_DLREJGTRLO_NEW.......: ${ESL_DLREJGTRLO_NEW}"
ECHO_LOG "#========================================================================="

# Job Initialisation
JOBINIT

#[002]
if [ ${BLCSHTMTHLOC_NF} -eq 12 ]
then
	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===>>> We are on month ${BLCSHTMTHLOC_NF}, then it's ESLD2900 that will process annual opening - STOP for this chain "
	ECHO_LOG "#========================================================================="
	JOBEND
fi

#############################################
#
#  Gestion Accept
#
#############################################

if [ ! -f ${ESL_DLREJGTAALO_CUR} ]
then
	touch ${ESL_DLREJGTAALO_CUR}
fi

#[003]
if [ ${BLCSHTMTHLOC_NF} -eq 1 ]
then
	BLCSHTYEALOC_ANNULT_NF=${BLCSHTYEALOC_NF}
	BLCSHTMTHLOC_ANNULT_NF=3
	BLCSHTDAYLOC_ANNULT_NF=31
	NSTEP=${NJOB}_05
	# Manage yearly opening data.
	#-----------------------------------------------------------------------------
	LIBEL="Manage yearly opening data from ${ESL_DLREJGTAALO_CUR}"
	AWK_I=${ESL_DLREJGTAALO_CUR}
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLREJGTAALO_CUROpen.dat
	AWK_PARAM=" -v ant=${BLCSHTYEALOC_ANNULT_NF} -v moist=${BLCSHTMTHLOC_ANNULT_NF} -v jourt=${BLCSHTDAYLOC_ANNULT_NF}"
	AWK_CMD=`CFTMP`
	INPUT_TEXT ${AWK_CMD} <<EOF
	BEGIN{ FS="\~"; OFS="\~" }
			{	if ( \$4 == 1 && \$5 == 1 )
				{ 
					if ( \$59 == 7 && substr(\$6,2,1) == "7" ) print \$0; # type mensuel
       		if ( \$59 == 8 )  # type trimestriel
       		{
       			if ( substr(\$6,2,1) == "7" ) print \$0;  # Ouverture
       			if ( substr(\$6,2,1) == "4" )  # cloture
       			{
       				print \$0;
	       			\$3 = ant;
	       			\$4 = moist;
	       			\$5 = jourt;
							if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
							if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
							if (\$41  != 0) \$41 = sprintf("%-.3lf",-\$41);
       				print \$0;
						}	       			
	       	}
				}
				else print \$0;
			}
	exit
EOF
	AWK
else
	NSTEP=${NJOB}_06
	#Touch files
	#----------------------------------------------------------------------------
	LIBEL="copy ${ESL_DLREJGTAALO_CUR} to ${DFILT}/${NJOB}_05_${IB}_AWK_DLREJGTAALO_CUROpen.dat"
	EXECKSH_MODE=P
	EXECKSH "cp ${ESL_DLREJGTAALO_CUR} ${DFILT}/${NJOB}_05_${IB}_AWK_DLREJGTAALO_CUROpen.dat"
fi

NSTEP=${NJOB}_10
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Create final DLREJGTAALO to process and Delta to process next time"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${ESL_DLREJGTAALO_CUR} 1000 1 "
SORT_I="${DFILT}/${NJOB}_05_${IB}_AWK_DLREJGTAALO_CUROpen.dat 1000 1 "  #[003]
SORT_I2="${ESL_DLREJGTAALO_NEW} 1000 1 "
SORT_O="${ESL_DLREJGTAALO} 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLREJGTAALO_DeltaNewCur_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS BALSHEY_NF 3:1 - 3:EN,
        BALSHRMTH_NF 4:1 - 4:EN,
        AMT_M 19:1 - 19: EN 15/3,
        RETAMT_M 35:1 - 35: EN 15/3,
        RETINTAMT_M 41:1 - 41: EN 15/3
/CONDITION MoisBilan BALSHEY_NF = ${BLCSHTYEALOC_NF} AND BALSHRMTH_NF = ${BLCSHTMTHLOC_NF} AND (AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0)        
/CONDITION SaufMoisBilan BALSHEY_NF != ${BLCSHTYEALOC_NF} OR BALSHRMTH_NF != ${BLCSHTMTHLOC_NF}
/OUTFILE ${SORT_O}
/INCLUDE MoisBilan
/OUTFILE ${SORT_O2}
/INCLUDE SaufMoisBilan
exit
EOF
SORT

NSTEP=${NJOB}_15
# Affect BLCSHTD year/month/day.
#-----------------------------------------------------------------------------
LIBEL="Affect BLCSHTD year/month/day to ${ESL_DLREJGTAALO_NEW}"
AWK_I=${DFILT}/${NJOB}_10_${IB}_SORT_DLREJGTAALO_DeltaNewCur_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLREJGTAALO_DeltaNewCur_O.dat
AWK_PARAM=" -v anm=${BLCSHTYEALOC_ANNULM_NF} -v moism=${BLCSHTMTHLOC_ANNULM_NF} -v jourm=${BLCSHTDAYLOC_ANNULM_NF} -v ant=${BLCSHTYEALOC_ANNULT_NF} -v moist=${BLCSHTMTHLOC_ANNULT_NF} -v jourt=${BLCSHTDAYLOC_ANNULT_NF}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{	if ( \$59 == 7 )
       	{
       		\$3 = anm;
       		\$4 = moism;
       		\$5 = jourm;
       	}
       	else
       	{
       		\$3 = ant;
       		\$4 = moist;
       		\$5 = jourt;
       	}
			print \$0; 
		}
exit
EOF
AWK

NSTEP=${NJOB}_20
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing DLREJGTAALO_CUR with CurRevert file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_DLREJGTAALO_DeltaNewCur_O.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREJGTAALO_Delta_O.dat 1000 1"
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
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        COLS1   1:1 -  18:,
        COLS2  20:1 -  34:,
        COLS3  36:1 -  40:,
        COLS4  42:1 -  71:
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
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT COLS1, AMT_MC, COLS2, RETAMT_MC, COLS3, RETINTAMT_MC, COLS4
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="create next CUR file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_DLREJGTAALO_Delta_O.dat 1000 1 "
SORT_O="${ESL_DLREJGTAALO_CURNEW} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS AMT_M 19:1 - 19: EN 15/3,
        RETAMT_M 35:1 - 35: EN 15/3,
        RETINTAMT_M 41:1 - 41: EN 15/3
/CONDITION Montants (AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0)        
/INCLUDE Montants
exit
EOF
SORT

#############################################
#
#  Gestion Accept-Retro
#
#############################################

if [ ! -f ${ESL_DLREJGTARLO_CUR} ]
then
	touch ${ESL_DLREJGTARLO_CUR}
fi

#[003]
if [ ${BLCSHTMTHLOC_NF} -eq 1 ]
then
	NSTEP=${NJOB}_105
	# Manage yearly opening data.
	#-----------------------------------------------------------------------------
	LIBEL="Manage yearly opening data from ${ESL_DLREJGTARLO_CUR}"
	AWK_I=${ESL_DLREJGTARLO_CUR}
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLREJGTARLO_CUROpen.dat
	AWK_PARAM=" -v ant=${BLCSHTYEALOC_ANNULT_NF} -v moist=${BLCSHTMTHLOC_ANNULT_NF} -v jourt=${BLCSHTDAYLOC_ANNULT_NF}"
	AWK_CMD=`CFTMP`
	INPUT_TEXT ${AWK_CMD} <<EOF
	BEGIN{ FS="\~"; OFS="\~" }
			{	if ( \$4 == 1 && \$5 == 1 )
				{ 
					if ( \$59 == 7 && substr(\$6,2,1) == "7" ) print \$0; # type mensuel
       		if ( \$59 == 8 )  # type trimestriel
       		{
       			if ( substr(\$6,2,1) == "7" ) print \$0;  # Ouverture
       			if ( substr(\$6,2,1) == "4" )  # cloture
       			{
       				print \$0;
	       			\$3 = ant;
	       			\$4 = moist;
	       			\$5 = jourt;
							if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
							if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
							if (\$41  != 0) \$41 = sprintf("%-.3lf",-\$41);
       				print \$0;
						}	       			
	       	}
				}
				else print \$0;
			}
	exit
EOF
	AWK
else
	NSTEP=${NJOB}_106
	#Touch files
	#----------------------------------------------------------------------------
	LIBEL="copy ${ESL_DLREJGTARLO_CUR} to ${DFILT}/${NJOB}_105_${IB}_AWK_DLREJGTARLO_CUROpen.dat"
	EXECKSH_MODE=P
	EXECKSH "cp ${ESL_DLREJGTARLO_CUR} ${DFILT}/${NJOB}_105_${IB}_AWK_DLREJGTARLO_CUROpen.dat"
fi

NSTEP=${NJOB}_110
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Create final DLREJGTARLO to process and Delta to process next time"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${ESL_DLREJGTARLO_CUR} 1000 1 "
SORT_I="${DFILT}/${NJOB}_105_${IB}_AWK_DLREJGTARLO_CUROpen.dat 1000 1 "  #[003]
SORT_I2="${ESL_DLREJGTARLO_NEW} 1000 1 "
SORT_O="${ESL_DLREJGTARLO} 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLREJGTARLO_DeltaNewCur_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS BALSHEY_NF 3:1 - 3:EN,
        BALSHRMTH_NF 4:1 - 4:EN,
        AMT_M 19:1 - 19: EN 15/3,
        RETAMT_M 35:1 - 35: EN 15/3,
        RETINTAMT_M 41:1 - 41: EN 15/3
/CONDITION MoisBilan BALSHEY_NF = ${BLCSHTYEALOC_NF} AND BALSHRMTH_NF = ${BLCSHTMTHLOC_NF} AND (AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0)        
/CONDITION SaufMoisBilan BALSHEY_NF != ${BLCSHTYEALOC_NF} OR BALSHRMTH_NF != ${BLCSHTMTHLOC_NF}
/OUTFILE ${SORT_O}
/INCLUDE MoisBilan
/OUTFILE ${SORT_O2}
/INCLUDE SaufMoisBilan
exit
EOF
SORT

NSTEP=${NJOB}_120
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing DLREJGTARLO_CUR with CurRevert file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_SORT_DLREJGTARLO_DeltaNewCur_O.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREJGTARLO_Delta_O.dat 1000 1"
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
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        COLS1   1:1 -  18:,
        COLS2  20:1 -  34:,
        COLS3  36:1 -  40:,
        COLS4  42:1 -  71:
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
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT COLS1, AMT_MC, COLS2, RETAMT_MC, COLS3, RETINTAMT_MC, COLS4
exit
EOF
SORT

NSTEP=${NJOB}_130
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="create next CUR file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_SORT_DLREJGTARLO_Delta_O.dat 1000 1 "
SORT_O="${ESL_DLREJGTARLO_CURNEW} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS AMT_M 19:1 - 19: EN 15/3,
        RETAMT_M 35:1 - 35: EN 15/3,
        RETINTAMT_M 41:1 - 41: EN 15/3
/CONDITION Montants (AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0)        
/INCLUDE Montants
exit
EOF
SORT

#############################################
#
#  Gestion Retrocession
#
#############################################

if [ ! -f ${ESL_DLREJGTRLO_CUR} ]
then
	touch ${ESL_DLREJGTRLO_CUR}
fi

#[003]
if [ ${BLCSHTMTHLOC_NF} -eq 1 ]
then
	NSTEP=${NJOB}_205
	# Manage yearly opening data.
	#-----------------------------------------------------------------------------
	LIBEL="Manage yearly opening data from ${ESL_DLREJGTRLO_CUR}"
	AWK_I=${ESL_DLREJGTRLO_CUR}
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLREJGTRLO_CUROpen.dat
	AWK_PARAM=" -v ant=${BLCSHTYEALOC_ANNULT_NF} -v moist=${BLCSHTMTHLOC_ANNULT_NF} -v jourt=${BLCSHTDAYLOC_ANNULT_NF}"
	AWK_CMD=`CFTMP`
	INPUT_TEXT ${AWK_CMD} <<EOF
	BEGIN{ FS="\~"; OFS="\~" }
			{	if ( \$4 == 1 && \$5 == 1 )
				{ 
					if ( \$59 == 7 && substr(\$6,2,1) == "7" ) print \$0; # type mensuel
       		if ( \$59 == 8 )  # type trimestriel
       		{
       			if ( substr(\$6,2,1) == "7" ) print \$0;  # Ouverture
       			if ( substr(\$6,2,1) == "4" )  # cloture
       			{
       				print \$0;
	       			\$3 = ant;
	       			\$4 = moist;
	       			\$5 = jourt;
							if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
       				print \$0;
						}	       			
	       	}
				}
				else print \$0;
			}
	exit
EOF
	AWK
else
	NSTEP=${NJOB}_206
	#Touch files
	#----------------------------------------------------------------------------
	LIBEL="copy ${ESL_DLREJGTRLO_CUR} to ${DFILT}/${NJOB}_205_${IB}_AWK_DLREJGTRLO_CUROpen.dat"
	EXECKSH_MODE=P
	EXECKSH "cp ${ESL_DLREJGTRLO_CUR} ${DFILT}/${NJOB}_205_${IB}_AWK_DLREJGTRLO_CUROpen.dat"
fi

NSTEP=${NJOB}_210
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Create final DLREJGTRLO to process and Delta to process next time"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${ESL_DLREJGTRLO_CUR} 1000 1 "
SORT_I="${DFILT}/${NJOB}_205_${IB}_AWK_DLREJGTRLO_CUROpen.dat 1000 1 "  #[003]
SORT_I2="${ESL_DLREJGTRLO_NEW} 1000 1 "
SORT_O="${ESL_DLREJGTRLO} 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLREJGTRLO_DeltaNewCur_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS BALSHEY_NF 3:1 - 3:EN,
        BALSHRMTH_NF 4:1 - 4:EN,
        AMT_M 19:1 - 19: EN 15/3,
        RETAMT_M 35:1 - 35: EN 15/3
/CONDITION MoisBilan BALSHEY_NF = ${BLCSHTYEALOC_NF} AND BALSHRMTH_NF = ${BLCSHTMTHLOC_NF} AND (AMT_M NE 0 OR RETAMT_M NE 0)        
/CONDITION SaufMoisBilan BALSHEY_NF != ${BLCSHTYEALOC_NF} OR BALSHRMTH_NF != ${BLCSHTMTHLOC_NF}
/OUTFILE ${SORT_O}
/INCLUDE MoisBilan
/OUTFILE ${SORT_O2}
/INCLUDE SaufMoisBilan
exit
EOF
SORT

NSTEP=${NJOB}_220
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing DLREJGTRLO_CUR with CurRevert file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_210_${IB}_SORT_DLREJGTRLO_DeltaNewCur_O.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREJGTRLO_Delta_O.dat 1000 1"
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
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        COLS1   1:1 -  18:,
        COLS2  20:1 -  34:,
        COLS3  36:1 -  71:
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
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT COLS1, AMT_MC, COLS2, RETAMT_MC, COLS3
exit
EOF
SORT

NSTEP=${NJOB}_230
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="create next CUR file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_220_${IB}_SORT_DLREJGTRLO_Delta_O.dat 1000 1 "
SORT_O="${ESL_DLREJGTRLO_CURNEW} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS AMT_M 19:1 - 19: EN 15/3,
        RETAMT_M 35:1 - 35: EN 15/3
/CONDITION Montants (AMT_M NE 0 OR RETAMT_M NE 0)        
/INCLUDE Montants
exit
EOF
SORT

NSTEP=${NJOB}_500
# Deletion of temporary files
#------------------------------------------------------------------------------
LIBEL="Deletion of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
