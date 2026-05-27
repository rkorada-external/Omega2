#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS -
#                                 Mise a jour et formatage des ecritures de service Post Omega Local
# nom du script SHELL           : ESLD1901.cmd
# revision                      :
# date de creation              : 29/09/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description   Reverse of Service Local entries generation
# job launched by ESLD1900.cmd
# Launch the C Program ESTM7601
# Output file sort ${DFILT}/${NSTEP}_${IB}_SORT_IGTA_O.dat

# Input files
#       ESL_DLSGTAALO
#       ESL_DLSGTARLO
#       ESL_DLSGTRLO
# Output files
#       ESL_DLREJGTAALO_NEW
#       ESL_DLREJGTARLO_NEW
#       ESL_DLREJGTRLO_NEW
#-----------------------------------------------------------------------------
# historique des modifications
#[001] 07/12/2017 R. Cassis :spira:66334 Les fichiers perimetre ES Local sont nommés ESL_ sont maintenant générés dans le ESID7000
#[002] 07/04/2020 R. Cassis :spira:76698 On month 12, this chain is not processed, it's ESLD2900 that will be processed for annual opening
#[003] 01/02/2022 R. cassis :spira:98240 Ajout d'un tri avec champs TRN_NT, GAAPCOD_NT, I17PRDCOD_CT et RETARDRETINT_B dans clé de tri
#[004] 26/06/2023 JYP       :spira:109764 update NEWCOLS1_NF=empty
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
CLODAT_D=$1
CONSOYEA=$2
CONSOMTH=$3
BLCSHTYEALOC_NF=$4
BLCSHTMTHLOC_NF=$5

#[002]
if [ ${BLCSHTMTHLOC_NF} -eq 12 ]
then
	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===>>> We are on month ${BLCSHTMTHLOC_NF}, then it's ESLD2900 that will process annual opening - STOP for this chain "
	ECHO_LOG "#========================================================================="
	JOBEND
fi

# To know what speentnat_ct to be used and if data to process
if [ -s ${ESL_DLSGTAALO} ]
then
	speentnat_ct=`cut -d~ -f59 ${ESL_DLSGTAALO} | head -1`
else
	if [ -s ${ESL_DLSGTARLO} ]
	then
		speentnat_ct=`cut -d~ -f59 ${ESL_DLSGTARLO} | head -1`
	else
		if [ -s ${ESL_DLSGTRLO} ]
		then
			speentnat_ct=`cut -d~ -f59 ${ESL_DLSGTRLO} | head -1`
		fi
	fi
fi

if [ "${speentnat_ct}" = "" ]
then
	NSTEP=${NJOB}_01
	#RAZ files
	#-----------------------------------------------------------------
	RMFIL "${ESL_DLREJGTAALO} ${ESL_DLREJGTARLO} ${ESL_DLREJGTRLO}"
	RMFIL "${ESL_DLREJGTAALO_NEW} ${ESL_DLREJGTARLO_NEW} ${ESL_DLREJGTRLO_NEW}"

	NSTEP=${NJOB}_02
	#Touch files
	#----------------------------------------------------------------------------
	LIBEL="touch ${ESL_DLREJGTAALO} ${ESL_DLREJGTARLO} ${ESL_DLREJGTRLO}"
	EXECKSH_MODE=P
	EXECKSH "touch ${ESL_DLREJGTAALO} ${ESL_DLREJGTARLO} ${ESL_DLREJGTRLO}"
	EXECKSH "touch ${ESL_DLREJGTAALO_NEW} ${ESL_DLREJGTARLO_NEW} ${ESL_DLREJGTRLO_NEW}"

	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===>>> No new data to process : Stop job processing"
	ECHO_LOG "#========================================================================="
	JOBEND
fi	

# Type de traitement Mensuel -> annul sur mois+1
if [ ${BLCSHTMTHLOC_NF} -lt 12 ]
then
	BLCSHTMTHLOC_ANNULM_NF=`expr ${BLCSHTMTHLOC_NF} + 1`
	BLCSHTYEALOC_ANNULM_NF=${BLCSHTYEALOC_NF}
else
	BLCSHTMTHLOC_ANNULM_NF=1
	BLCSHTYEALOC_ANNULM_NF=`expr ${BLCSHTYEALOC_NF} + 1`
fi
BLCSHTDAYLOC_ANNULM_NF=`date -d "${BLCSHTYEALOC_ANNULM_NF}-${BLCSHTMTHLOC_ANNULM_NF}-01 +1 month -1 day" +%d`

# Type de traitement trimestriel -> annul sur mois T+1
if [ ${CONSOMTH} -lt 10 ]
then
	BLCSHTMTHLOC_ANNULT_NF=`expr ${CONSOMTH} + 3`
	BLCSHTYEALOC_ANNULT_NF=${CONSOYEA}
else
	BLCSHTMTHLOC_ANNULT_NF=3
	BLCSHTYEALOC_ANNULT_NF=`expr ${CONSOYEA} + 1`
fi
BLCSHTDAYLOC_ANNULT_NF=`date -d "${BLCSHTYEALOC_ANNULT_NF}-${BLCSHTMTHLOC_ANNULT_NF}-01 +1 month -1 day" +%d`


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> CLODAT_D.................: ${CLODAT_D}"
ECHO_LOG "#===> CONSOYEA.................: ${CONSOYEA}"
ECHO_LOG "#===> CONSOMTH.................: ${CONSOMTH}"
ECHO_LOG "#===> BLCSHTYEALOC_NF..........: ${BLCSHTYEALOC_NF}"
ECHO_LOG "#===> BLCSHTMTHLOC_NF..........: ${BLCSHTMTHLOC_NF}"
ECHO_LOG "#===> BLCSHTYEALOC_ANNULM_NF...: ${BLCSHTYEALOC_ANNULM_NF}"
ECHO_LOG "#===> BLCSHTMTHLOC_ANNULM_NF...: ${BLCSHTMTHLOC_ANNULM_NF}"
ECHO_LOG "#===> BLCSHTDAYLOC_ANNULM_NF...: ${BLCSHTDAYLOC_ANNULM_NF}"
ECHO_LOG "#===> BLCSHTYEALOC_ANNULT_NF...: ${BLCSHTYEALOC_ANNULT_NF}"
ECHO_LOG "#===> BLCSHTMTHLOC_ANNULT_NF...: ${BLCSHTMTHLOC_ANNULT_NF}"
ECHO_LOG "#===> BLCSHTDAYLOC_ANNULT_NF...: ${BLCSHTDAYLOC_ANNULT_NF}"
ECHO_LOG "#===> ESL_DLSGTAALO............: ${ESL_DLSGTAALO}"
ECHO_LOG "#===> ESL_DLREJGTAALO_NEW......: ${ESL_DLREJGTAALO_NEW}"
ECHO_LOG "#===> ESL_DLSGTARLO............: ${ESL_DLSGTARLO}"
ECHO_LOG "#===> ESL_DLREJGTARLO_NEW......: ${ESL_DLREJGTARLO_NEW}"
ECHO_LOG "#===> ESL_DLSGTRLO.............: ${ESL_DLSGTRLO}"
ECHO_LOG "#===> ESL_DLREJGTRLO_NEW.......: ${ESL_DLREJGTRLO_NEW}"
ECHO_LOG "#========================================================================="


###########################
# Acceptance cancellation #
###########################

NSTEP=${NJOB}_00
#Last version of ESLD1900 files deletion
#-----------------------------------------------------------------
RMFIL " `dirname ${ESL_DLREJGTAALO_NEW}`/${PCH}ESLD1900_DLREJGTAALO_NEW*.dat
        `dirname ${ESL_DLREJGTARLO_NEW}`/${PCH}ESLD1900_DLREJGTARLO_NEW*.dat
        `dirname ${ESL_DLREJGTRLO_NEW}`/${PCH}ESLD1900_DLREJGTRLO_NEW*.dat"

#[003]
NSTEP=${NJOB}_05
#Sort and screen of IGTA on pure Acceptance contracts
#-----------------------------------------------------------------------------
LIBEL="Current sort and screen on pure Acceptance contracts ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_DLSGTAALO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_DLSGTAALO.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
	      CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRN_NT     56:1 - 56:,
        RETARDRETINT_B   62:1 - 62:,
	      GAAPCOD_NT 64:1 - 64:,
        I17PRDCOD_CT 65:1 - 65:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
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
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT	
exit
EOF
SORT

NSTEP=${NJOB}_10
#Cancellation of the previous closing period in IGTAa
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closing period in DLSGTAALO..."
PRG=ESTM7601
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_O_DLSGTAALO.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJGTAA0.dat
EXECPRG

NSTEP=${NJOB}_20
#reset to blanc 15 cols from SAP/ONEGL
#-----------------------------------------------------------------------------
LIBEL="reset to blanc 15 cols from SAP/ONEGL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTM7601_DLREJGTAA0.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREJGTAALO.dat OVERWRITE"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS COLS1            1:1 - 41:,
        FILLER56to62    56:1 - 62:,
		COLS_END        64:1 - 71: 
/DERIVEDFIELD BLANK_14_CHAMPS 14"~"
/DERIVEDFIELD NEWCOLS1_NF "~"
/OUTFILE ${SORT_O}
/REFORMAT COLS1, BLANK_14_CHAMPS, FILLER56to62,NEWCOLS1_NF,COLS_END
exit
EOF
SORT



NSTEP=${NJOB}_25
# Affect BLCSHTD year/month/day.
#-----------------------------------------------------------------------------
LIBEL="Affect BLCSHTD year/month/day to ${ESL_DLREJGTAALO_NEW}"
AWK_I=${DFILT}/${NJOB}_20_${IB}_SORT_DLREJGTAALO.dat
AWK_O=${ESL_DLREJGTAALO_NEW}
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

#[003]
NSTEP=${NJOB}_26
#Sort and screen on Retrocession contracts by Acceptance
#-----------------------------------------------------------------------------
LIBEL="Current sort and screen on Retrocession contracts by Acceptance ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_DLSGTARLO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_DLSGTARLO.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        TRNCOD2_CF 6:2 - 6:2,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRN_NT 56:1 - 56:,
        RETARDRETINT_B   62:1 - 62:,
        GAAPCOD_NT 64:1 - 64:,
        I17PRDCOD_CT 65:1 - 65:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
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
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
exit
EOF
SORT

NSTEP=${NJOB}_30
#Cancellation of the previous closinf period in IGTAr
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closinf period in IGTAr ..."
PRG=ESTM7601
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_26_${IB}_SORT_O_DLSGTARLO.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJGTARLO.dat
EXECPRG

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="reset to blanc 15 cols from SAP/ONEGL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTM7601_DLREJGTARLO.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREJGTARLO.dat OVERWRITE"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS COLS1            1:1 - 41:,
        FILLER56to62    56:1 - 62:,
		COLS_END        64:1 - 71: 		
/DERIVEDFIELD BLANK_14_CHAMPS 14"~"
/DERIVEDFIELD NEWCOLS1_NF "~"
/OUTFILE ${SORT_O}
/REFORMAT COLS1, BLANK_14_CHAMPS, FILLER56to62,NEWCOLS1_NF,COLS_END
exit
EOF
SORT


NSTEP=${NJOB}_45
# Affect BLCSHTD year/month/day.
#-----------------------------------------------------------------------------
LIBEL="Affect BLCSHTD year/month/day to ${ESL_DLREJGTARLO_NEW}"
AWK_I=${DFILT}/${NJOB}_40_${IB}_SORT_DLREJGTARLO.dat
AWK_O=${ESL_DLREJGTARLO_NEW}
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

#[003]
NSTEP=${NJOB}_46
#Current sort and screen on Retrocession contracts by Acceptance ...
#-----------------------------------------------------------------------------
LIBEL="Current sort and screen on Retrocession contracts by Acceptance ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_DLSGTRLO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_DLSGTRLO.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        TRNCOD2_CF 6:2 - 6:2,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRN_NT 56:1 - 56:,
        RETARDRETINT_B   62:1 - 62:,
        GAAPCOD_NT 64:1 - 64:,
        I17PRDCOD_CT 65:1 - 65:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
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
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT	
exit
EOF
SORT

NSTEP=${NJOB}_50
#Cancellation of the previous closing period in IGTR
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closing period in IGTR ..."
PRG=ESTM7601
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_46_${IB}_SORT_O_DLSGTRLO.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJGTRLO.dat
EXECPRG

NSTEP=${NJOB}_60
#reset to blanc 14 cols from SAP/ONEGL
#-----------------------------------------------------------------------------
LIBEL="reset to blanc 14 cols from SAP/ONEGL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTM7601_DLREJGTRLO.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREJGTRLO.dat OVERWRITE"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS COLS1            1:1 - 41:,
        FILLER16COLS    56:1 - 71:
/DERIVEDFIELD BLANK_14_CHAMPS 14"~"
/OUTFILE ${SORT_O}
/REFORMAT COLS1, BLANK_14_CHAMPS, FILLER16COLS
exit
EOF
SORT

NSTEP=${NJOB}_65
# Affect BLCSHTD year/month/day.
#-----------------------------------------------------------------------------
LIBEL="Affect BLCSHTD year/month/day to ${ESL_DLREJGTRLO_NEW}"
AWK_I=${DFILT}/${NJOB}_60_${IB}_SORT_DLREJGTRLO.dat
AWK_O=${ESL_DLREJGTRLO_NEW}
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

###############################
# Deletion of temporary files #
###############################

NSTEP=${NJOB}_100
LIBEL="Deletion of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
