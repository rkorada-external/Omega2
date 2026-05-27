#!/bin/ksh
#=============================================================================
# nom de l'application          : REQ 8.1
# nom du script SHELL           : ESFD3871.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 17/07/2020
# auteur                        : Nhat Linh DOAN
#-----------------------------------------------------------------------------
# description
#  : SPIRA 87876 :  IFRS 17 account file generation
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 17/07/2020 : SPIRA 87876: NLD :  IFRS 17 account file generation
#[002] 12/11/2020 : SPIRA 77469: NLD :  REQ11.9 - AOC- Experience Adjustement 
#[003] 03/02/2021 : SPIRA 83101: NLD :  REQ20.1 - GAPMAP transformation
#[004] 17/02/2021 : SPIRA 85522: NLD :  add DUMMY filter
#[005] 16/03/2021 : SPIRA 83101: NLD :  REQ20.1 - GAPMAP transformation: activate I17 >> I17
#[006] 06/07/2021 : SPIRA 92543: NLD :  REQ11.7.2- R0-09 should take into account IA
#[007] 06/07/2021 : SPIRA 98275: NLD :  refont NDIC Retro
#[008] 29/03/2022 : SPIRA 102507: MZM :  AI LCC IFRS17 Dans TTECLEDA
#[009] 04/04/2022 : SPIRA 103202: DaD :  merge opening IFRS17 in TTECLEDA
#[010] 07/04/2022 : SPIRA 102507: MZM :  AI LCC IFRS17 Dans TTECLEDA V2
#[011] 16/06/2022 : SPIRA 99814: DAD :  Exclude Onerous Q+1 contrat    
#[012] 04/07/2022 : SPIRA 104778: JBD : Build new closing for I17S norm 
#[013] 04/08/2022 : SPIRA 105382: DAD : exclude future profitable and onerous for STD and INI
#[014] 10/10/2022 : SPIRA 107024: DAD : exclude PROFUT and DUMMY for ASS and exclude PROFUT and Not DUMMY for RET
#[015] 10/10/2022 : SPIRA 107837: DAD : Fix regression on Life cancelation due to spira 107024
#[016] 10/10/2022 : SPIRA 106770: MZM : I17G - Internal assumed initial amounts to be aligned with internal retro initial amounts 
#[017] 29/03/2023 : SPIRA 109406: DAD : R03-09 - Exclude internal assumed contracts linked to this internal retro contract
#[018] 04/04/2023 : Spira 108791 :PROD - Missing Internal Assumed generated from AE booked on Internal Retro in project "Omega 2.0" Contraintes sur I17 : Ajout Fichier LCC_STD que sur Context STD
#[019] 12/04/2023 : SPIRA 109488: DAD : R03-08 fix bug exclut LC cession 49500
#[020] 18/04/2023 : SPIRA 109506: DAD : R03-01 Modify rule to not exclude closing positions of retro of assumed dummies
#[021] 26/04/2023 : SPIRA 108471: MiS : Exclude Retro Dummy LC Accretion and Unwind
#[022] 05/06/2023 : SPIRA 109911: MZM : I17G - Internal assumed initial amounts to be aligned with internal retro initial amounts 
#[023] 13/12/2023 : SPIRA 110473: MZM : I17 - RA vs RR view - Gaps on Unwind transactions (Suppression des DUMMY VUE TTECLEDR)
#[024] 24/01/2024 : SPIRA 111109: MZM : PRD - Retrocessionaire are missing in RR view
#[025] 02/04/2024 : SPIRA 111211: MZM : PRD - Gaps between RA & RR on CSM/LC ending
#[026] 14/05/2024 : SPIRA 111106: HR : Calculate unwind & LC accretion on Onerous Q+1 & retro dummy contracts
#[027] 13/12/2024 : SPIRA 112551: MZM : PRD - retro dummy transactions missing generate IADPERICASE_DUMMY_MRG At STD Closing
#[028] 01/04/2025 : SPIRA 112559: MZM : INI AE should also be filtered if underlying initialized after retro
#[029] 04/12/2025 : US7624 Retro by Retrocessionaire] Omega/Racube vs BPE : Ecart GTR/GTAR Rejet AE Life :  
#===============================================================================

# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> CONTEXT_CT.................: ${CONTEXT_CT}  "

ECHO_LOG "#===> PARM_ICLODAT_D.............: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}"
ECHO_LOG "#===> PARM_CRE_D.................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM_BLCSHTYEA_NF..........: ${PARM_BLCSHTYEA_NF}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"

CLODAT_D=${PARM_ICLODAT_D}



ECHO_LOG ""                                                                                     >>$FLOG
ECHO_LOG "#....................... INPUT ..........................................."           >>$FLOG
ECHO_LOG "#===> CLODAT_D.............................: ${CLODAT_D} "                            >>$FLOG
ECHO_LOG "#===> NORME_CF.............................: ${NORME_CF} "                            >>$FLOG


ECHO_LOG "#===> ESF_FTECLEDA....................: ${ESF_FTECLEDA} "                 >>$FLOG
ECHO_LOG "#===> ESF_FTECLEDR....................: ${ESF_FTECLEDR} "                 >>$FLOG
ECHO_LOG "#===> ESF_IADPERICASE_PROFUT..........: ${ESF_IADPERICASE_PROFUT} "                 >>$FLOG
ECHO_LOG "#===> ESF_IADPERICASE_ONEFUT..........: ${ESF_IADPERICASE_ONEFUT} "                 >>$FLOG
ECHO_LOG "#===> ESF_DLRGTAA_LCC_INI.............: ${ESF_DLRGTAA_LCC_INI} "                 >>$FLOG

if [ "${CONTEXT_CT}" = "STD" ]
then
    ECHO_LOG "#===> ESF_FTECLEDA_REJ............: ${ESF_FTECLEDA_REJ} "                 >>$FLOG
    ECHO_LOG "#===> ESF_FTECLEDA_OPNG...........: ${ESF_FTECLEDA_OPNG} "                 >>$FLOG
    ECHO_LOG "#===> ESF_FTECLEDR_REJ............: ${ESF_FTECLEDR_REJ} "                 >>$FLOG
    ECHO_LOG "#===> ESF_FTECLEDR_OPNG...........: ${ESF_FTECLEDR_OPNG} "                 >>$FLOG
fi

ECHO_LOG "#....................... OUTPUT ..........................................."          >>$FLOG
ECHO_LOG "#===> ESF_FTECLEDA_MVT ......................: ${ESF_FTECLEDA_MVT}"      	>>$FLOG
ECHO_LOG "#===> ESF_FTECLEDR_MVT ......................: ${ESF_FTECLEDR_MVT}" 		>>$FLOG
ECHO_LOG "#========================================================================="           >>$FLOG




# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES "


if [ ! -f ${ESF_FTECLEDA_INI} ]
then
        ECHO_LOG "ESF_FTECLEDA_INI=${ESF_FTECLEDA_INI}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDA_INI}"

fi

if [ ! -f ${ESF_FTECLEDR_INI} ]
then
        ECHO_LOG "ESF_FTECLEDR_INI=${ESF_FTECLEDR_INI}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDR_INI}"

fi

if [ ! -f ${ESF_FTECLEDA_STD} ]
then
        ECHO_LOG "ESF_FTECLEDA_STD=${ESF_FTECLEDA_STD}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDA_STD}"

fi

if [ ! -f ${ESF_FTECLEDR_STD} ]
then
        ECHO_LOG "ESF_FTECLEDR_STD=${ESF_FTECLEDR_STD}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDR_STD}"

fi

if [ ! -f ${ESF_FTECLEDA_CSM_ACC} ]
then
        ECHO_LOG "ESF_FTECLEDA_CSM_ACC=${ESF_FTECLEDA_CSM_ACC}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDA_CSM_ACC}"

fi

if [ ! -f ${ESF_FTECLEDR_CSM_ACC} ]
then
        ECHO_LOG "ESF_FTECLEDR_CSM_ACC=${ESF_FTECLEDR_CSM_ACC}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDR_CSM_ACC}"

fi


if [ ! -f ${ESF_FTECLEDA_AOC} ]
then
        ECHO_LOG "ESF_FTECLEDA_AOC=${ESF_FTECLEDA_AOC}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDA_AOC}"

fi

if [ ! -f ${ESF_DLREGTARSII} ]
then
        ECHO_LOG "ESF_DLREGTARSII=${ESF_DLREGTARSII}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_DLREGTARSII}"

fi


if [ ! -f ${ESF_DLREGTRSII} ]
then
        ECHO_LOG "ESF_DLREGTRSII=${ESF_DLREGTRSII}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_DLREGTRSII}"

fi

# [010] I2 Integration des AI I17 LCC  STD 
if [ ! -f ${ESF_DLRGTAASII} ]
then
        ECHO_LOG "ESF_DLRGTAASII=${ESF_DLRGTAASII}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_DLRGTAASII}"

fi

#[013]
if [ ! -f ${ESF_IADPERICASE_ONEFUT} ]
then
        ECHO_LOG "ESF_IADPERICASE_ONEFUT=${ESF_IADPERICASE_ONEFUT}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_IADPERICASE_ONEFUT}"

fi

#[013]
if [ ! -f ${ESF_IADPERICASE_PROFUT} ]
then
        ECHO_LOG "ESF_IADPERICASE_PROFUT=${ESF_IADPERICASE_PROFUT}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_IADPERICASE_PROFUT}"

fi


if [ ! -f ${ESF_IADPERICASE_DUMMY} ]
then
        ECHO_LOG "ESF_IADPERICASE_DUMMY=${ESF_IADPERICASE_DUMMY}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_IADPERICASE_DUMMY}"

fi

if [ ! -f ${ESF_IADPERICASE_DUMMY_INI} ] && [ "${CONTEXT_CT}" = "STD" ]
then
        ECHO_LOG "ESF_IADPERICASE_DUMMY_INI=${ESF_IADPERICASE_DUMMY_INI}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_IADPERICASE_DUMMY_INI}"

fi

if [ ! -f ${ESF_IADPERICASE_DUMMY_MRG} ] && [ "${CONTEXT_CT}" = "STD" ]
then
        ECHO_LOG "ESF_IADPERICASE_DUMMY_MRG=${ESF_IADPERICASE_DUMMY_MRG}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_IADPERICASE_DUMMY_MRG}"

fi

# [016] I2 Integration des AI I17 LCC  INI
if [ ! -f ${ESF_DLRGTAA_LCC_INI} ]
then
        ECHO_LOG "ESF_DLRGTAA_LCC_INI=${ESF_DLRGTAA_LCC_INI}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_DLRGTAA_LCC_INI}"

fi


if [ "${CONTEXT_CT}" = "STD" ] 
then
###[028]  AND ( PRS_CF = "751" AND ACMTRS_NT != "3420" )

NSTEP=${NJOB}_00
#-----------------------------------------------------------------------------
LIBEL="Filter ESF_FTRSLNK_TXT on TRNCOD_I17 AE ONLY "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_AE_TRNCOD_I17_INI.dat 500 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTRSLNK_AE_AI_TRNCOD_I17_INI.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  
     PRS_CF    		    1:1 -  1:,
     ACMTRS_NT    		2:1 -  2:,   
     DETTRS_CF    		3:1 -  3:,
     DETTRS2_CF    	  3:2 -  3:2,   
     DETTRS_1_2_CF    3:1 -  3:2, 
     DETTRS_3_5_CF    3:3 -  3:5,             
     DETTRS8_CF    		3:8 -  3:8    
/CONDITION IS_TRNCOD_AE_I17_INI ( DETTRS_1_2_CF = "24" ) AND ( DETTRS8_CF = "I" OR DETTRS8_CF = "J" OR DETTRS8_CF = "K" OR DETTRS8_CF = "L"  OR DETTRS8_CF = "M" OR DETTRS8_CF = "N") AND ( DETTRS2_CF = "4" OR DETTRS2_CF = "7" ) AND ( PRS_CF= "740" AND ACMTRS_NT = "101" )  AND ( DETTRS_3_5_CF != "49500" )
/CONDITION IS_TRNCOD_AE_AI_I17_INI ( DETTRS_1_2_CF = "14" ) AND ( DETTRS8_CF = "I" OR DETTRS8_CF = "J" OR DETTRS8_CF = "K" OR DETTRS8_CF = "L"  OR DETTRS8_CF = "M" OR DETTRS8_CF = "N") AND ( DETTRS2_CF = "4" OR DETTRS2_CF = "7" ) AND ( PRS_CF= "740" AND ACMTRS_NT = "101" )  AND ( DETTRS_3_5_CF != "49500" )
/OUTFILE $SORT_O
/INCLUDE IS_TRNCOD_AE_I17_INI
/OUTFILE $SORT_O2
/INCLUDE IS_TRNCOD_AE_AI_I17_INI
/COPY
exit
EOF
SORT

##

## [027]


## [027] MERGE ESF_IADPERICASE_DUMMY_INI AND ESF_IADPERICASE_DUMMY_STD  ==> ESF_IADPERICASE_DUMMY_MRG

NSTEP=${NJOB}_01
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-INI not in pericase DUMMY  STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADPERICASE_DUMMY_INI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_DUMMY_INI_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       3:1 -  3:, 
		END_NT       4:1 -  4:, 
		SEC_NF       5:1 -  5:, 
		UWY_NF       6:1 -  6:, 
		UW_NT        7:1 -  7:, 
		STD_CTR_NF   3:1 -  3:, 
		STD_END_NT   4:1 -  4:, 
		STD_SEC_NF   5:1 -  5:, 
		STD_UWY_NF   6:1 -  6:, 
		STD_UW_NT    7:1 -  7:,
		ALL_COLS     1:1 -  252: 
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${ESF_IADPERICASE_DUMMY} 2000 1 "~"
/joinkeys
        STD_CTR_NF,
        STD_END_NT,
        STD_SEC_NF,
        STD_UWY_NF,
        STD_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT




NSTEP=${NJOB}_03
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT PERICASE DUMMY INI And STD "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01_${IB}_SORT_IADPERICASE_DUMMY_INI_O.dat 2000 1"
SORT_I2="${ESF_IADPERICASE_DUMMY} 2000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_DUMMY_MERGE_O.dat 2000 1"
SORT_O="${ESF_IADPERICASE_DUMMY_MRG} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       3:1 -  3:, 
        		END_NT       4:1 -  4:, 
        		SEC_NF       5:1 -  5:, 
       		  UWY_NF       6:1 -  6:, 
        		UW_NT        7:1 -  7: 
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

##cp ${DFILT}/${NJOB}_03_${IB}_SORT_IADPERICASE_DUMMY_MERGE_O.dat ${ESF_IADPERICASE_DUMMY}

cp ${ESF_IADPERICASE_DUMMY_MRG} ${ESF_IADPERICASE_DUMMY}

fi


#[014]
NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Generate Pericase Future Profitable and not Dummy Contracts "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADPERICASE_PROFUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_PROFUT_NOT_DUMMY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:,
        PER_ALL_COLS         1:1 - 240:
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/INFILE ${ESF_IADPERICASE_DUMMY} 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :PER_ALL_COLS
exit
EOF
SORT


# [008] I2 Integration des AI I17 LCC  STD 
# [014] I3 Integration des AI I17 LCC  INI 
# [018] Ajout condition ( TRNCOD2_CF != "1"  AND ("${CONTEXT_CT}" = "STD"))

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance Technical Ledgers File to format TTCLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLREGTARSII} 2000 1"
SORT_I2="${ESF_DLRGTAA_LCC_INI} 2000 1" 
SORT_I3="${ESF_DLRGTAASII} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA.dat  2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD1_CF       6:1 -  6:1,
	TRNCOD2_CF       6:2 -  6:2,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:,
        LIGNEGT          1:1 - 39:,
        RETKEY_CF       40:1 - 40:,
	RETAMT_M	35:1 - 35:,
        RETINTAMT_M     41:1 - 41:,
	SEG_NF		46:1 - 46:,
        FILLER_30_COLS  42:1 - 71:
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
        CUR_CF,
	SEG_NF
/CONDITION COND_GTAA0 ( TRNCOD1_CF eq "1" )
/CONDITION COND_IFRS17 ( TRNCOD2_CF eq "1" ) OR ( TRNCOD2_CF != "1"  AND ("${CONTEXT_CT}" = "STD"))
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/DERIVEDFIELD RETINTAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS17
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_MC,
          FILLER_30_COLS
exit
EOF
SORT


# [018] ( TRNCOD2_CF != "1"  AND ("${CONTEXT_CT}" = "STD"))

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance and Retrocession files
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File format TTECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLREGTRSII} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD1_CF       6:1 -  6:1,
	TRNCOD2_CF       6:2 -  6:2,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:,
        LIGNEGT          1:1 - 39:,
        RETKEY_CF       40:1 - 40:,
	SEG_NF          46:1 - 46:,
        FILLER_26_COLS  45:1 - 71:
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
        CUR_CF,
	SEG_NF
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/CONDITION COND_GTAR0 ( TRNCOD1_CF EQ "2" )
/CONDITION COND_IFRS17 ( TRNCOD2_CF eq "1" ) OR ( TRNCOD2_CF != "1"  AND ("${CONTEXT_CT}" = "STD"))
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS17
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          FILLER_26_COLS
exit
EOF
SORT



NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Merge GTL FTECLEDA IFRS17  File  to ${ESF_FTECLEDA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_INI} 2000 1"
SORT_I2="${ESF_FTECLEDA_STD} 2000 1"
SORT_I3="${ESF_FTECLEDA_CSM_ACC} 2000 1"
SORT_I4="${ESF_FTECLEDA_AOC} 2000 1"
SORT_I5="${DFILT}/${NJOB}_10_${IB}_FTECLEDA.dat 2000 1"
# [009]
if [ "${CONTEXT_CT}" = "STD" ]
then
    SORT_I6="${ESF_FTECLEDA_REJ} 2000 1"
    SORT_I7="${ESF_FTECLEDA_OPNG} 2000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
	    CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:
        
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

/OUTFILE ${SORT_O} OVERWRITE

exit
EOF
SORT

#[014] #[015]
NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Split contrat assumed and retro in TECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_FTECLEDA.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_ASS.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTECLEDA_RET.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_FTECLEDA_REJ.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD1_CF       6:1 -  6:1,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
	CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:  
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
/CONDITION COND_GTAA ( TRNCOD1_CF EQ "1" )
/CONDITION COND_GTAR ( TRNCOD1_CF EQ "2" )
/CONDITION COND_OPNG ( TRNCOD1_CF != "1" and TRNCOD1_CF != "2")
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_GTAA
/OUTFILE ${SORT_O2} OVERWRITE
/INCLUDE COND_GTAR
/OUTFILE ${SORT_O3} OVERWRITE
/INCLUDE COND_OPNG
exit
EOF
SORT


NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
# Merge and sort of the IFRS17 GLT Retro file
#------------------------------------------------------------------------------
LIBEL="Merge GTL FTELEDR IFRS17 Files to ${ESF_FTECLEDR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`

SORT_I="${ESF_FTECLEDR_INI} 2000 1"
SORT_I2="${ESF_FTECLEDR_STD} 2000 1"
SORT_I3="${ESF_FTECLEDR_CSM_ACC} 2000 1"
SORT_I4="${DFILT}/${NJOB}_20_${IB}_FTECLEDR.dat 2000 1"
# [009]
if [ "${CONTEXT_CT}" = "STD" ]
then
    SORT_I5="${ESF_FTECLEDR_REJ} 2000 1"
    SORT_I6="${ESF_FTECLEDR_OPNG} 2000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
	CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:
        
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

/OUTFILE ${SORT_O} OVERWRITE

exit
EOF
SORT

# [022] ##SORT_I="$DFILT/P_ESFD3870_ESFD3871INV_40_I17G_GLT_ALL_INI_FTECLEDR.dat 2000 1"

##[029]

##/CONDITION COND_GTAA ( TRNCOD1_CF EQ "1" )
##/CONDITION COND_GTR ( TRNCOD1_CF EQ "2" )
##/CONDITION COND_OPNG ( TRNCOD1_CF != "1" and TRNCOD1_CF != "2")


NSTEP=${NJOB}_40A
# FILTER ACCEPT AND RETRO PROP ONLY
#-----------------------------------------------------------------------------
LIBEL="FILTER FTECLEDR ON ACCEPT AND RETRO PROP ONLY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_FTECLEDR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_ASS_RET.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RET.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_FTECLEDR_REJ.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD1_CF       6:1 -  6:1,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
	CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:,
        TRN_NT         56:1 - 56:
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

/CONDITION COND_GTAA ( ( TRNCOD1_CF EQ "1" ) or ( TRNCOD1_CF EQ "3" ) )
/CONDITION COND_GTR ( ( TRNCOD1_CF EQ "2" ) or ( TRNCOD1_CF EQ "4" ) )
/CONDITION COND_OPNG ( TRNCOD1_CF != "1" and TRNCOD1_CF != "2") and ( TRNCOD1_CF != "3" and TRNCOD1_CF != "4")
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_GTAA
/OUTFILE ${SORT_O2} OVERWRITE
/INCLUDE COND_GTR
/OUTFILE ${SORT_O3} OVERWRITE
/INCLUDE COND_OPNG
exit
EOF
SORT

NSTEP=${NJOB}_40B
#-----------------------------------------------------------------------------
LIBEL="Supression de future profitable and not dummy contracts RET pour TECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40A_${IB}_FTECLEDR_RET.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RET_PROFUT_NOT_DUMMY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 71:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT
/INFILE ${DFILT}/${NJOB}_05_${IB}_SORT_IADPERICASE_PROFUT_NOT_DUMMY.dat  2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT



#[013] #[014]
#Exclude future profitable for STD qnd INI
NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="Supression de future profitable contracts ASS pour TECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_FTECLEDA_ASS.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_ASS_NOT_PROFUT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 118:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT
/INFILE ${ESF_IADPERICASE_PROFUT} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

#[014]
NSTEP=${NJOB}_46
#-----------------------------------------------------------------------------
LIBEL="Supression de DUMMY Contracts ASS pour TECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_FTECLEDA_ASS_NOT_PROFUT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_ASS_NOT_PROFUT_DUMMY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 118:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT
/INFILE ${ESF_IADPERICASE_DUMMY} 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

#[014]
NSTEP=${NJOB}_47
#-----------------------------------------------------------------------------
LIBEL="Supression de future profitable and not dummy contracts RET pour TECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_FTECLEDA_RET.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_RET_PROFUT_NOT_DUMMY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 118:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT
/INFILE ${DFILT}/${NJOB}_05_${IB}_SORT_IADPERICASE_PROFUT_NOT_DUMMY.dat  2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

#[014]
NSTEP=${NJOB}_50
LIBEL="Merge des fichiers TECLEDA  ASS not PROFUT and not DUMMY + RET PROFUT and not DUMMY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_46_${IB}_SORT_FTECLEDA_ASS_NOT_PROFUT_DUMMY.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_47_${IB}_FTECLEDA_RET_PROFUT_NOT_DUMMY.dat 2000 1"
SORT_O="${ESF_FTECLEDA} 2000 1"
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
        ACCRET_CF       49:1 - 49:
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

#[013] #[014] [022] 


###Exclude future profitable for STD qnd INI
##NSTEP=${NJOB}_60
###-----------------------------------------------------------------------------
##LIBEL="Supression dfuture profitable and not dummy contracts RET pour TECLEDR"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_40_${IB}_FTECLEDR.dat 2000 1" FTECLEDR_ASS_RET.dat
###SORT_I="${DFILT}/${NJOB}_40A_${IB}_FTECLEDR_ASS_RET.dat 2000 1" 
##SORT_I="${DFILT}/${NJOB}_40B_${IB}_FTECLEDR_ASS_RET.dat 2000 1" 
##SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_ASS_RET.dat 2000 1"
####SORT_O="${ESF_FTECLEDR} 2000 1"
##INPUT_TEXT ${SORT_CMD} <<EOF
##/FIELDS GT_CTR_NF    8:1 -  8:,
##        GT_END_NT    9:1 -  9:,
##        GT_SEC_NF    10:1 - 10:,
##        GT_UWY_NF    11:1 - 11:,
##        GT_UW_NT     12:1 - 12:,
##        GT_ALL_COLS          1:1 - 71:,
##        PER_CTR_NF           3:1 - 3:,
##        PER_END_NT           4:1 - 4:,
##        PER_SEC_NF           5:1 - 5:,
##        PER_UWY_NF           6:1 - 6:,
##        PER_UW_NT            7:1 - 7:
##/joinkeys
##        GT_CTR_NF ,
##        GT_END_NT ,
##        GT_SEC_NF ,
##        GT_UWY_NF ,
##        GT_UW_NT
##/INFILE ${DFILT}/${NJOB}_05_${IB}_SORT_IADPERICASE_PROFUT_NOT_DUMMY.dat 2000 1 "~"
##/joinkeys
##        PER_CTR_NF ,
##        PER_END_NT ,
##        PER_SEC_NF ,
##        PER_UWY_NF ,
##        PER_UW_NT
##/JOIN UNPAIRED LEFTSIDE ONLY
##/OUTFILE ${SORT_O} overwrite
##/REFORMAT
##        leftside :GT_ALL_COLS
##exit
##EOF
##SORT

#[025]

NSTEP=${NJOB}_65
LIBEL="Generate FTECLEDR_RET "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`    
SORT_I="${DFILT}/${NJOB}_40B_${IB}_FTECLEDR_RET_PROFUT_NOT_DUMMY.dat 2000 1"         
SORT_O="${ESF_FTECLEDR} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
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
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT




if [ "${CONTEXT_CT}" != STD ]
then


if [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17S" ]
then
    # R03-08
    RQ="select RETCTR_NF, RTY_NF, GRPFSTCLO_D as FSTCLO_D, GRPINISTS_CT as INISTS_CT from BRET..TRETIFRS where GRPFSTCLO_D < '${PARM_ICLODAT_D}' and GRPINISTS_CT=2"
            #[017] R03-09
    RQ2="select a.RETCTR_NF, a.RTY_NF, a.GRPFSTCLO_D as FSTCLO_D, a.GRPINISTS_CT as INISTS_CT, b.CTR_NF, b.END_NT, b.SEC_NF, b.UWY_NF, b.UW_NT
    from BRET..TRETIFRS a, BRET..TSSDACTR b
    where a.GRPFSTCLO_D < '${PARM_ICLODAT_D}' and a.GRPINISTS_CT=2
    and a.RETCTR_NF = b.RETCTR_NF
    and a.RTY_NF = b.RTY_NF"
fi

if [ "${NORME_CF}" = "I17P" ]
then
    # R03-08
    RQ="select RETCTR_NF, RTY_NF, PARFSTCLO_D as FSTCLO_D, PARINISTS_CT as INISTS_CT from BRET..TRETIFRS where PARFSTCLO_D < '${PARM_ICLODAT_D}' and PARINISTS_CT=2"
fi

if [ "${NORME_CF}" = "I17L" ]
then
    # R03-08
    RQ="select RETCTR_NF, RTY_NF, LCLFSTCLO_D as FSTCLO_D, LOCINISTS_CT as INISTS_CT from BRET..TRETIFRS where LCLFSTCLO_D < '${PARM_ICLODAT_D}' and LOCINISTS_CT=2"

fi


NSTEP=${NJOB}_71
#-----------------------------------------------------------------------------
LIBEL="Collecting retro contracts"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${DFILT}/${NSTEP}_${IB}_FRETIFRS_INTERNE.dat"
BCP_QRY="${RQ}"
BCP

#remove Internal retro contracts in INI
#[019] [020]
NSTEP=${NJOB}_72
#-----------------------------------------------------------------------------
LIBEL="split FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_LC.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_OTHERS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	TRNCOD5_CF 6:3 - 6:7   
/CONDITION LC ( TRNCOD5_CF = "49500" OR
                TRNCOD5_CF = "10061" OR 
                TRNCOD5_CF = "10062" OR
                TRNCOD5_CF = "12061" OR
                TRNCOD5_CF = "12062" OR
                TRNCOD5_CF = "12063" OR
                TRNCOD5_CF = "14061" OR
                TRNCOD5_CF = "49461" OR
                TRNCOD5_CF = "49462" OR
                TRNCOD5_CF = "43014" OR
                TRNCOD5_CF = "43024" OR 
                TRNCOD5_CF = "43034" OR                 
                TRNCOD5_CF = "12161"   )
/OUTFILE ${SORT_O} overwrite
/INCLUDE LC
/OUTFILE ${SORT_O2} overwrite
/OMIT LC
exit
EOF
SORT



NSTEP=${NJOB}_75
#-----------------------------------------------------------------------------
LIBEL="remove Internal retro contracts in INI TECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_72_${IB}_SORT_FTECLEDA_OTHERS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	GT_RETCTR_NF 24:1 - 24:,	
	GT_RETRTY_NF 27:1 - 27:,	
       GT_ALL_COLS          1:1 - 118:,
        PER_RETCTR_NF           1:1 - 1:,
        PER_RETRTY_NF           2:1 - 2:
        
/joinkeys
        GT_RETCTR_NF ,
        GT_RETRTY_NF 
/INFILE ${DFILT}/${NJOB}_71_${IB}_FRETIFRS_INTERNE.dat 2000 1 "~"
/joinkeys
        PER_RETCTR_NF,
        PER_RETRTY_NF 
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

#[017]
if [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17S" ]
then
    # R03-09
    NSTEP=${NJOB}_80
    #-----------------------------------------------------------------------------
    LIBEL="Collecting internal retro contracts linked internal assumed contracts"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O="${DFILT}/${NSTEP}_${IB}_INTERN_RET_WITH_ASS.dat"
    BCP_QRY="${RQ2}"
    BCP

    # R03-09
    NSTEP=${NJOB}_85
    #-----------------------------------------------------------------------------
    LIBEL="Remove internal assumed contracts linked to this internal retro contract"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_75_${IB}_SORT_FTECLEDA.dat 2000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 2000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS 
            GT_CTR_NF    8:1 -  8:,
            GT_END_NT    9:1 -  9:,
            GT_SEC_NF    10:1 - 10:,
            GT_UWY_NF    11:1 - 11:,
            GT_UW_NT     12:1 - 12:,
            GT_ALL_COLS  1:1 - 118:,
            PER_CTR_NF    5:1 -  5:,
            PER_END_NT    6:1 -  6:,
            PER_SEC_NF    7:1 - 7:,
            PER_UWY_NF    8:1 - 8:,
            PER_UW_NT     9:1 - 9:    
    /joinkeys
            GT_CTR_NF,
            GT_END_NT,
            GT_SEC_NF,
            GT_UWY_NF,
            GT_UW_NT
    /INFILE ${DFILT}/${NJOB}_80_${IB}_INTERN_RET_WITH_ASS.dat 2000 1 "~"
    /joinkeys
            PER_CTR_NF,
            PER_END_NT,
            PER_SEC_NF,
            PER_UWY_NF,
            PER_UW_NT 
    /JOIN UNPAIRED LEFTSIDE ONLY
    /OUTFILE ${SORT_O} overwrite
    /REFORMAT
            leftside :GT_ALL_COLS
    exit
EOF
    SORT

fi


NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="Fusion TECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17S" ]
then
    SORT_I="${DFILT}/${NJOB}_85_${IB}_SORT_FTECLEDA.dat 2000 1"
else 
    SORT_I="${DFILT}/${NJOB}_75_${IB}_SORT_FTECLEDA.dat 2000 1"
fi
SORT_I2="${DFILT}/${NJOB}_72_${IB}_SORT_FTECLEDA_LC.dat 2000 1"
SORT_O="${ESF_FTECLEDA} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT


#remove Internal retro contracts in INI
# [020] 
NSTEP=${NJOB}_92
#-----------------------------------------------------------------------------
LIBEL="split FTECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_LC.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_OTHERS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	TRNCOD5_CF 6:3 - 6:7   
/CONDITION LC ( TRNCOD5_CF = "49500" OR
                TRNCOD5_CF = "10062" OR
                TRNCOD5_CF = "12061" OR
                TRNCOD5_CF = "12062" OR
                TRNCOD5_CF = "12063" OR
                TRNCOD5_CF = "14061" OR
                TRNCOD5_CF = "49461" OR
                TRNCOD5_CF = "49462" OR
                TRNCOD5_CF = "43014" OR
                TRNCOD5_CF = "43024" OR
                TRNCOD5_CF = "43034" OR
                TRNCOD5_CF = "12161"   )
/OUTFILE ${SORT_O} overwrite
/INCLUDE LC
/OUTFILE ${SORT_O2} overwrite
/OMIT LC
exit
EOF
SORT


NSTEP=${NJOB}_95
#-----------------------------------------------------------------------------
LIBEL="remove Internal retro contracts in INI TECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_92_${IB}_SORT_FTECLEDR_OTHERS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	GT_RETCTR_NF 24:1 - 24:,	
	GT_RETRTY_NF 27:1 - 27:,	
    GT_ALL_COLS          1:1 - 118:,
    PER_RETCTR_NF           1:1 - 1:,
    PER_RETRTY_NF           2:1 - 2:
        
/joinkeys
        GT_RETCTR_NF ,
        GT_RETRTY_NF 
/INFILE ${DFILT}/${NJOB}_71_${IB}_FRETIFRS_INTERNE.dat 2000 1 "~"
/joinkeys
        PER_RETCTR_NF,
        PER_RETRTY_NF 
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT



NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="move to TECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_SORT_FTECLEDR.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_92_${IB}_SORT_FTECLEDR_LC.dat 2000 1"
SORT_O="${ESF_FTECLEDR} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT

fi


##[011] [026]
##NSTEP=${NJOB}_120
##-----------------------------------------------------------------------------
##LIBEL="Split FTECLEDA by TRNCOD for Onerous Q+1"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${ESF_FTECLEDA} 2000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_ONEFUT.dat 2000 1"
##SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_OTHERS.dat 2000 1"
##INPUT_TEXT ${SORT_CMD} <<EOF
##/FIELDS 
##	TRNCOD_CF 6:3 - 6:7   
##/CONDITION ONEFUT (TRNCOD_CF = "49550" or TRNCOD_CF = "10160" or TRNCOD_CF = "42660"  or TRNCOD_CF = "10150" or TRNCOD_CF = "42650" or TRNCOD_CF = "10260" or TRNCOD_CF = "10250" or TRNCOD_CF = "43616" or TRNCOD_CF = "46076" or TRNCOD_CF = "46066" or TRNCOD_CF = "43081" or TRNCOD_CF = "43071")
##/OUTFILE ${SORT_O} overwrite
##/INCLUDE ONEFUT
##/OUTFILE ${SORT_O2} overwrite
##/OMIT ONEFUT
##exit
##EOF
##SORT

#[026]
NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
LIBEL="No filter on FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT

##[021] [026]
##NSTEP=${NJOB}_125
##-----------------------------------------------------------------------------
##LIBEL="Filter Retro Dummy from FTECLEDA"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_120_${IB}_SORT_FTECLEDA_ONEFUT.dat 2000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_ONEFUT.dat 2000 1"
##INPUT_TEXT ${SORT_CMD} <<EOF
##/FIELDS
##        PER_CTR_NF           3:1 - 3:,
##        PER_END_NT           4:1 - 4:,
##        PER_SEC_NF           5:1 - 5:,
##        PER_UWY_NF           6:1 - 6:,
##        PER_UW_NT            7:1 - 7:,
##        GT_CTR_NF            8:1 - 8:,
##        GT_END_NT            9:1 - 9:,
##        GT_SEC_NF           10:1 - 10:,
##        GT_UWY_NF           11:1 - 11:,
##        GT_UW_NT            12:1 - 12:,
##        GT_ALL_COLS          1:1 - 118:
##/joinkeys
##        GT_CTR_NF ,
##        GT_END_NT ,
##        GT_SEC_NF ,
##        GT_UWY_NF ,
##        GT_UW_NT
##/INFILE ${ESF_IADPERICASE_DUMMY} 2000 1 "~"
##/joinkeys
##        PER_CTR_NF ,
##        PER_END_NT ,
##        PER_SEC_NF ,
##        PER_UWY_NF ,
##        PER_UW_NT
##/JOIN UNPAIRED LEFTSIDE ONLY
##/OUTFILE ${SORT_O} overwrite
##/REFORMAT
##        leftside :GT_ALL_COLS
##exit
##EOF
##SORT

## [026]
##NSTEP=${NJOB}_130
##-----------------------------------------------------------------------------
##LIBEL="Exclude Onerous Q+1 Contracts in TECLEDA"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_125_${IB}_SORT_FTECLEDA_ONEFUT.dat 2000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_ONEFUT.dat 2000 1"
##INPUT_TEXT ${SORT_CMD} <<EOF
##/FIELDS GT_CTR_NF    8:1 -  8:,
##        GT_END_NT    9:1 -  9:,
##        GT_SEC_NF    10:1 - 10:,
##        GT_UWY_NF    11:1 - 11:,
##        GT_UW_NT     12:1 - 12:,
##        GT_ALL_COLS          1:1 - 118:,
##        PER_CTR_NF           3:1 - 3:,
##        PER_END_NT           4:1 - 4:,
##        PER_SEC_NF           5:1 - 5:,
##        PER_UWY_NF           6:1 - 6:,
##        PER_UW_NT            7:1 - 7:
##/joinkeys 
##        GT_CTR_NF ,
##        GT_END_NT ,
##        GT_SEC_NF ,
##        GT_UWY_NF ,
##        GT_UW_NT
##/INFILE ${ESF_IADPERICASE_ONEFUT} 2000 1 "~"
##/joinkeys 
##        PER_CTR_NF ,
##        PER_END_NT ,
##        PER_SEC_NF ,
##        PER_UWY_NF ,
##        PER_UW_NT
##/JOIN UNPAIRED LEFTSIDE ONLY
##/OUTFILE ${SORT_O} overwrite
##/REFORMAT
##        leftside :GT_ALL_COLS
##exit
##EOF
##SORT

#[015] [026]
NSTEP=${NJOB}_130
#-----------------------------------------------------------------------------
LIBEL="Merge exclude Onerous Q+1 and others to FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_SORT_FTECLEDA_ALL.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_35_${IB}_FTECLEDA_REJ.dat 2000 1"
SORT_O="${ESF_FTECLEDA} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:

/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT


#[028]

if [ "${CONTEXT_CT}" = STD ]
then


NSTEP=${NJOB}_135
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Remove AE INI FROM STD "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 2000 1"
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
				all_cols_F1 1:1  - 118:,
			  PRS_CF_F2           1:1  - 1:,
			  ACMTRS_NT_F2				2:1  - 2:,
			  DETTRS_CF_F2				3:1  - 3:
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_00_${IB}_FTRSLNK_AE_TRNCOD_I17_INI.dat 500 1 "~" 
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:all_cols_F1   	
exit
EOF
SORT

##R03-09

NSTEP=${NJOB}_137
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Remove AE AI INI FROM STD  R03-09"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_135_${IB}_SORT_FTECLEDA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 2000 1"
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
				all_cols_F1 1:1  - 118:,
			  PRS_CF_F2           1:1  - 1:,
			  ACMTRS_NT_F2				2:1  - 2:,
			  DETTRS_CF_F2				3:1  - 3:
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_00_${IB}_FTRSLNK_AE_AI_TRNCOD_I17_INI.dat 500 1 "~" 
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:all_cols_F1   	
exit
EOF
SORT

NSTEP=${NJOB}_140
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Remove AE INI FROM STD "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR.dat 2000 1"
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
				all_cols_F1 1:1  - 71:,
			  PRS_CF_F2           1:1  - 1:,
			  ACMTRS_NT_F2				2:1  - 2:,
			  DETTRS_CF_F2				3:1  - 3:
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_00_${IB}_FTRSLNK_AE_TRNCOD_I17_INI.dat 500 1 "~" 
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:all_cols_F1   	
exit
EOF
SORT

EXECKSH "cp ${DFILT}/${NJOB}_137_${IB}_SORT_FTECLEDA.dat ${ESF_FTECLEDA}"

EXECKSH "cp ${DFILT}/${NJOB}_140_${IB}_SORT_FTECLEDR.dat ${ESF_FTECLEDR}" 

 
fi

## [022] Generate FTECLEDR From FTECLEDA AT INI ONLY  

# [024] Ajout de la Ventilation des PLC_NT / RTO ==> Generer TTECLEDR

if [ "${CONTEXT_CT}" != STD ]
then


NSTEP=${NJOB}_150
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Sort FPLATXCUMALL0 file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${ESF_FPLATXCUMALL0}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUMALL0.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 2:1 - 2:EN,
        RETRTY_NF 3:1 - 3:,
        PLC_NT    4:1 - 4:EN
/KEYS RETCTR_NF, RETRTY_NF, RETSEC_NF, PLC_NT
/SUM
/STABLE
exit
EOF
SORT 

NSTEP=${NJOB}_160
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort GTAR TL file before Applying PLC..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ESF_FTECLEDA.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:EN,
        RTY_NF 27:1 - 27:,
		    PLC_NT 36:1 - 36:EN 15/3,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:EN,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        RETAMT_M 35:1 - 35:EN 15/3,
        RETINTAMT_M 88:1 - 88:EN 15/3,
        GT_ANNUL_OPNG   114:1 - 114:              
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        PLC_NT,
        RETEND_NT,
        RETUW_NT,
        RETCUR_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,
        TRNCOD_CF                
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT



NSTEP=${NJOB}_170
# Affectation par placement DES MVTS IFRS17
#-----------------------------------------------------------------------------
LIBEL=" AGREGATES retro Affectation MVT IFRS17 par placement "
PRG=ESTC1052B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
FPLATXCUM ALL
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NJOB}_150_${IB}_FPLATXCUMALL0.dat"
export ${PRG}_I2="${DFILT}/${NJOB}_160_${IB}_${EST_BASE}_ESF_FTECLEDA.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_${PRG}_ESF_FTECLEDA.dat"
EXECPRG


NSTEP=${NJOB}_180
#------------------------------------------------------------------------------------
LIBEL="Summarize on Key "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_170_${IB}_${EST_BASE}_ESTC1052B_ESF_FTECLEDA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ESF_FTECLEDA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
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
	GT_ANNUL_OPNG   114:1 - 114:	
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
	GT_ANNUL_OPNG
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT


NSTEP=${NJOB}_190
#------------------------------------------------------------------------------------
LIBEL="Generate FTECLEDR FROM STEP _180 OF FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_180_${IB}_${EST_BASE}_ESF_FTECLEDA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        SSD_CF            1:1 -   1:,
        ESB_CF            2:1 -   2:,
        BALSHEY_NF        3:1 -   3:,
        BALSHRMTH_NF      4:1 -   4:,
        CHAMPS_1A7        1:1 -   7:,
        TRNCOD_CF         6:1 -   6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -   7:,
        CTR_NF            8:1 -   8:,
        END_NT            9:1 -   9:,
        SEC_NF           10:1 -  10:,
        UWY_NF           11:1 -  11:,
        UW_NT            12:1 -  12:,
        OCCYEA_NF        13:1 -  13:,
        ACY_NF           14:1 -  14:,
        SCOSTRMTH_NF     15:1 -  15:,
        SCOENDMTH_NF     16:1 -  16:,
        CUR_CF           18:1 -  18:,
        AMT_M            19:1 -  19:EN 18/3,
        CED_NF           20:1 -  20:,
        RETCTR_NF        24:1 -  24:,
        RETEND_NT        25:1 -  25:,
        RETSEC_NF        26:1 -  26:,
        RTY_NF           27:1 -  27:,
        RETUW_NT         28:1 -  28:,
        RETOCCYEA_NF     29:1 -  29:,
        RETACY_NF        30:1 -  30:,
        RETSCOSTRMTH_NF  31:1 -  31:,
        RETSCOENDMTH_NF  32:1 -  32:,
        RETCUR_CF        34:1 -  34:,
        RETAMT_M         35:1 -  35:EN 18/3,
        PLC_NT           36:1 -  36:,
        RTO_NF           37:1 -  37:,
  			CHAMPS_1A40       1:1 -  40:,
  			CHAMPS_41A41     41:1 -  41:,
  			CHAMPS_42A44     42:1 -  44:,
  			LOBRET_CF        46:1 -  46:,
  			SOBRET_CF        48:1 -  48:,
  			TOPRET_CF        50:1 -  50:,
  			NATRET_CF        52:1 -  52:,
  			GARRET_CF        54:1 -  54:,
  			PCPRSKTRYRET_CF  56:1 -  56:,
  			USRCRTCODRET_CT  58:1 -  58:,
  			USRCRTVALRET_LM  60:1 -  60:,
  			RETCTRCAT_CF     62:1 -  62:,
  			RETACCTYP_CT     67:1 -  67:,
  			CHAMPS_42A55     42:1 -  55:,
  			CHAMPS_56A56     56:1 -  56:,
  			CHAMPS_57A57     57:1 -  57:,
  			CHAMPS_58A58     58:1 -  58:,
  			CHAMPS_59A59     59:1 -  59:,
  			CHAMPS_60A64     60:1 -  64:,
  			CHAMPS_65A65     65:1 -  65:,
  			CHAMPS_66A71     66:1 -  71:,
        RETINTAMT_M      88:1 -  88:EN 18/3,
        CHAMPS_89A113    89:1 -  113:,
        ZZRECONKEY_CF   102:1 - 102:,
        TRN_NT          103:1 - 103:,
        ORICOD_LS       104:1 - 104:,
        RETROAUTO_B     105:1 - 105:,
        SPEENTNAT_CT    106:1 - 106:,
        EVT_NF          107:1 - 107:,
        REVT_NF         108:1 - 108:,
        RETARDRETINT_B  109:1 - 109:,
        NEWCOLS1_NF     110:1 - 110:,
        GAAPCOD_NT      111:1 - 111:,
        I17PRDCOD_CT    112:1 - 112:,
        GT_ANNUL_OPNG   114:1 - 114:,
        CHAMPS_115A118  115:1 - 118:
/KEYS   SSD_CF,
        ESB_CF,
        TRNCOD_CF
/CONDITION RETRO_ONLY (TRNCOD1_CF = "2" OR TRNCOD1_CF = "4")
/DERIVEDFIELD CHAMPS_VIDE "~"
/INCLUDE RETRO_ONLY
/OUTFILE ${SORT_O}
/REFORMAT
      CHAMPS_1A40,
      CHAMPS_41A41,
      CHAMPS_42A44,
      LOBRET_CF,
      SOBRET_CF,
      TOPRET_CF,
      NATRET_CF,
      GARRET_CF,
      PCPRSKTRYRET_CF,
      USRCRTCODRET_CT,
      USRCRTVALRET_LM,
      RETCTRCAT_CF,
      RETACCTYP_CT,
      CHAMPS_VIDE,
      CHAMPS_VIDE,
      ORICOD_LS,
      RETROAUTO_B,
      CHAMPS_VIDE,
      EVT_NF,
      REVT_NF,
      RETARDRETINT_B,
      NEWCOLS1_NF,
      GAAPCOD_NT,
      I17PRDCOD_CT,
      CHAMPS_VIDE,
      GT_ANNUL_OPNG,
      CHAMPS_VIDE,
      CHAMPS_VIDE,
      CHAMPS_VIDE,
      CHAMPS_VIDE
exit
EOF
SORT

#--------------------------------------------
NSTEP=${NJOB}_200
# summarize TTECLEDR by BALSHTDAY
#--------------------------------
LIBEL="Summarize TTECLEDR by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_FTECLEDR.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR.dat 2000 1"
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
	TRN_NT           56:1 -  56:,
  ALL               1:1 - 71:
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
	TRN_NT
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT

EXECKSH "cp ${DFILT}/${NJOB}_200_${IB}_FTECLEDR.dat ${ESF_FTECLEDR}"

fi


JOBEND


