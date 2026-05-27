#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			            : Generation des ouvertures annuelles des ecritures Locales
# nom du script SHELL           : ESLD2901.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description:
#    Generation des ouvertures annuelles des ecritures Locales
#
# Input files
#       ESL_DLSGTAALO
#       ESL_DLSGTARLO
#       ESL_DLSGTRLO
#
# Output files
#       ESL_DLOPNGTAALO
#       ESL_DLOPNGTARLO
#       ESL_DLOPNGTRLO
#
# launched by ESLD2900.cmd

#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[001] 07/04/2020 R. Cassis :spira:76698 On month 12, this chain is processed for Local annual opening
#[002] 22/12/2020 R. Cassis :spira:92776 On reprend pas le fichier d'annulation en entrée ESL_DLREJGT..
#[002] 22/12/2020 R. Cassis :spira:92383 On reprend pas le fichier d'annulation en entrée ESL_DLREJGT..
#[003] 27/01/2022 R. cassis :spira:98240 - ajout colonnes TRN_NT, GAAPCOD_NT, I17PRDCOD_CT et RETARDRETINT_B dans clé de tri
#[004] 27/06/2023 JYP       :spira 109764 - update NEWCOLS1_NF=empty 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
CRE_D=$1
CONSOYEA=$2
CONSOMTH=$3
INVCONSO_D=$4
BLCSHTYEALOC_NF=$5
BLCSHTMTHLOC_NF=$6

NORME="LOCAL"

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME....................: ${NORME}"
ECHO_LOG "#===> INVCONSO_D...............: ${INVCONSO_D}"
ECHO_LOG "#===> CONSOMTH.................: ${CONSOMTH}"
ECHO_LOG "#===> BLCSHTYEALOC_NF..........: ${BLCSHTYEALOC_NF}"
ECHO_LOG "#===> BLCSHTMTHLOC_NF..........: ${BLCSHTMTHLOC_NF}"
ECHO_LOG "#===> ESL_DLSGTAALO............: ${ESL_DLSGTAALO}"
ECHO_LOG "#===> ESL_DLSGTARLO............: ${ESL_DLSGTARLO}"
ECHO_LOG "#===> ESL_DLSGTRLO.............: ${ESL_DLSGTRLO}"
ECHO_LOG "#===> ESL_DLOPNGTAALO..........: ${ESL_DLOPNGTAALO}"
ECHO_LOG "#===> ESL_DLOPNGTARLO..........: ${ESL_DLOPNGTARLO}"
ECHO_LOG "#===> ESL_DLOPNGTRLO...........: ${ESL_DLOPNGTRLO}"
ECHO_LOG "#========================================================================="

#[002]
if [ ${BLCSHTMTHLOC_NF} -ne 12 ]
then
	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===>>> We are on month ${BLCSHTMTHLOC_NF}, then it's ESLD1900 that will process quaterly reject - STOP for this chain "
	ECHO_LOG "#========================================================================="
	JOBEND
fi

if [ ! -f ${ESL_DLSGTAALO} ]
then
	NSTEP=${NJOB}_000
	#Touch files
	#----------------------------------------------------------------------------
	LIBEL="touch ${ESL_DLSGTAALO} ${ESL_DLSGTARLO} ${ESL_DLSGTRLO}"
	EXECKSH_MODE=P
	EXECKSH "touch ${ESL_DLSGTAALO} ${ESL_DLSGTARLO} ${ESL_DLSGTRLO}"
#	EXECKSH "touch ${ESL_DLREJGTAALO_CUR} ${ESL_DLREJGTARLO_CUR} ${ESL_DLREJGTRLO_CUR}"

	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===>>> No new data to process : Stop job processing"
	ECHO_LOG "#========================================================================="
	JOBEND
fi	

#[003]
NSTEP=${NJOB}_00
#-----------------------------------------------------------------
LIBEL="Last version of ESID2900 files deletion"
RMFIL "${ESL_DLOPNGTAALO} ${ESL_DLOPNGTARLO} ${ESL_DLOPNGTRLO}"

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Current sort file GTAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_DLSGTAALO} 1000 1"
#[002] SORT_I2="${ESL_DLREJGTAALO_CUR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAALO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ESB_CF 2:1 - 2:,
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
        RETARDRETINT_B 61:1 - 61:,
        GAAPCOD_NT  64:1 - 64:,
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
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
/CONDITION BilanAnnuel BALSHEY_NF = ${BLCSHTYEALOC_NF} AND BALSHRMTH_NF = 12
/INCLUDE BilanAnnuel      
exit
EOF
SORT

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Acceptance retrocession reversal and carried forward in progress ..."
PRG=ESTM7602
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${INVCONSO_D}
BALSHTMTH_NF ${CONSOMTH}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAALO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAALO_O.dat
EXECPRG

#[09]
NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTA in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_ESTM7602_DLSGTAALO_O.dat
export ${PRG}_I2=${ESL_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAALO_O.dat
EXECPRG

#[007]
NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="DLSGTAALO SORT , blank NEWCOLS1_NF ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTM7603_DLSGTAALO_O.dat 1000 1"
SORT_O="${ESL_DLOPNGTAALO} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF    27:1 - 27:,
        PLC_NT    36:1 - 36:EN,
        FILLER01   1:1 - 56:,
        FILLER02  58:1 - 62:,
		COLS_END  64:1 - 71: 
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
/DERIVEDFIELD ORICOD_LS "${NORME}~"
/DERIVEDFIELD  NEWCOLS1_NF "~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER01, ORICOD_LS, FILLER02 ,NEWCOLS1_NF, COLS_END
exit
EOF
SORT

#[003]
NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="Current sort file GTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_DLSGTARLO} 1000 1"
#[002] SORT_I2="${ESL_DLREJGTARLO_CUR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTARLO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ESB_CF           2:1 - 2:,
        BALSHEY_NF       3:1 - 3: EN,
        BALSHRMTH_NF     4:1 - 4: EN,
        TRNCOD_CF        6:1 - 6:,
        TRNCOD1_CF       6:1 - 6:1,
        CTR_NF           8:1 - 8:,
        END_NT           9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOENDMTH_NF    16:1 - 16:,
        SCOSTRMTH_NF    15:1 - 15:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:,
        TRN_NT          56:1 - 56:,
        RETARDRETINT_B  61:1 - 61:,
        GAAPCOD_NT      64:1 - 64:,
        I17PRDCOD_CT    65:1 - 65:
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
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
/CONDITION BilanAnnuel BALSHEY_NF = ${BLCSHTYEALOC_NF} AND BALSHRMTH_NF = 12
/INCLUDE BilanAnnuel      
exit
EOF
SORT

NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="Acceptance retrocession reversal and carried forward in progress ..."
PRG=ESTM7602
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${INVCONSO_D}
BALSHTMTH_NF ${CONSOMTH}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_DLSGTARLO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTARLO_O.dat  #[007]
EXECPRG

#[09]
NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTAR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_ESTM7602_DLSGTARLO_O.dat
export ${PRG}_I2=${ESL_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTARLO_O.dat
EXECPRG

#[007]
NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Update oricod_ls to LOCGTA, blank NEWCOLS1 "
AWK_I=${DFILT}/${NJOB}_70_${IB}_ESTM7603_DLSGTARLO_O.dat
AWK_O=${ESL_DLOPNGTARLO}
AWK_PARAM=" -v norme=${NORME}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
	\$57 = norme;
	\$42 = "";
	\$43 = "";
	\$63 = "";
	print \$0;
}
exit
EOF
AWK

#[003]
NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="Current sort file GTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESL_DLSGTRLO} 1000 1"
#[002] SORT_I2="${ESL_DLREJGTRLO_CUR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTRLO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ESB_CF 2:1 - 2:,
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
        RETARDRETINT_B 61:1 - 61:,
        GAAPCOD_NT  64:1 - 64:,
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
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
/CONDITION BilanAnnuel BALSHEY_NF = ${BLCSHTYEALOC_NF} AND BALSHRMTH_NF = 12
/INCLUDE BilanAnnuel      
exit
EOF
SORT

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="Retrocession retrocession reversal and carried forward of previous balance sheet in the book in progress ..."
PRG=ESTM7602
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${INVCONSO_D}
BALSHTMTH_NF ${CONSOMTH}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_90_${IB}_SORT_DLSGTRLO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTRLO_O.dat
EXECPRG

NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_ESTM7602_DLSGTRLO_O.dat
export ${PRG}_I2=${ESL_FDETTRS}
export ${PRG}_O1=${ESL_DLOPNGTRLO}
EXECPRG

ECHO_LOG "--> Archivage des fichiers"
gzip -c ${ESL_DLSGTAALO}     > ${DARCH}/${ENV_PREFIX}_ESLD1800_DLSGTAALO_${NORME}_${INVCONSO_D}_${CRE_D}.dat.gz
gzip -c ${ESL_DLSGTARLO}     > ${DARCH}/${ENV_PREFIX}_ESLD1800_DLSGTARLO_${NORME}_${INVCONSO_D}_${CRE_D}.dat.gz
gzip -c ${ESL_DLSGTRLO}      > ${DARCH}/${ENV_PREFIX}_ESLD1800_DLSGTRLO_${NORME}_${INVCONSO_D}_${CRE_D}.dat.gz
gzip -c ${ESL_DLOPNGTAALO}   > ${DARCH}/${ENV_PREFIX}_ESLD2900_DLOPNGTAALO_${NORME}_${INVCONSO_D}_${CRE_D}.dat.gz
gzip -c ${ESL_DLOPNGTARLO}   > ${DARCH}/${ENV_PREFIX}_ESLD2900_DLOPNGTARLO_${NORME}_${INVCONSO_D}_${CRE_D}.dat.gz
gzip -c ${ESL_DLOPNGTRLO}    > ${DARCH}/${ENV_PREFIX}_ESLD2900_DLOPNGTRLO_${NORME}_${INVCONSO_D}_${CRE_D}.dat.gz


JOBEND
