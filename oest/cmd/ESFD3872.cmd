#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESFD3870.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 11/07/2023
# auteur                        : CGI
# references des specifications : SPIRA 110198 I17 -Generation of CSM LC ENDING Q-1 for Reclass conditions  [abs(CSM ending) + abs(LC ending)] ; 
#-----------------------------------------------------------------------------
# description
#   Generation of the file CSM Ending Q-1 and LC Ending Q-1
#-----------------------------------------------------------------------------
# historiques des modifications
#
#[001] 28/07/2023 : SPIRA 110198: MZM : I17 -Generation of CSM LC ENDING Q-1 for Reclass conditions  [abs(CSM ending) + abs(LC ending)] ; ONLY IF NOT FIRST_CLOSING_DATE 
#[002] 04/08/2023 : SPIRA 110198: MZM : I17 -Update Rule CSM_ENDING and LC_ENDING
#[003] 19/12/2023 : SPIRA 109797: MZM : REQ 20.1 - I17 - Unwind receivables reclass for earned contracts
#[004] 28/08/2024 : SPIRA 111738: MZM : REQ 20.1 - I17 - REQ 20.1 - Gaps on reclass

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
ECHO_LOG "#===> ICLODAT_A..................: ${ICLODAT_A}" 
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}"
ECHO_LOG "#===> PARM_CRE_D.................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM_BLCSHTYEA_NF..........: ${PARM_BLCSHTYEA_NF}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"

CLODAT_D=${PARM_ICLODAT_D}

ICLODAT_A=`echo ${CLODAT_D} | awk '{print substr($0,1,4)}'`

ECHO_LOG ""                                                                                     >>$FLOG
ECHO_LOG "#....................... INPUT ..........................................."           >>$FLOG
ECHO_LOG "#===> CLODAT_D.............................: ${CLODAT_D} "                            >>$FLOG
ECHO_LOG "#===> ICLODAT_A............................: ${ICLODAT_A} "                           >>$FLOG
ECHO_LOG "#===> NORME_CF.............................: ${NORME_CF} "                            >>$FLOG
ECHO_LOG "#===> PRS_CF...............................: ${PRS_CF} "                              >>$FLOG
ECHO_LOG "#===> ESF_FTECLEDA.........................: ${ESF_FTECLEDA} "                        >>$FLOG 
ECHO_LOG "#===> ESF_FTECLEDA_3870_PREV...............: ${ESF_FTECLEDA_3870_PREV} "              >>$FLOG 
ECHO_LOG "#===> ESF_FTRSLNK_TXT......................: ${ESF_FTRSLNK_TXT} "                     >>$FLOG
ECHO_LOG "#===> ESF_FCURQUOT_TXT.....................: ${ESF_FCURQUOT_TXT} "                    >>$FLOG
ECHO_LOG "#===> ESF_IADVPERICASE.....................: ${ESF_IADVPERICASE} "                    >>$FLOG
ECHO_LOG "#===> ESF_IRDPERICASE0.....................: ${ESF_IRDPERICASE0} "                    >>$FLOG 
ECHO_LOG "#===> ESF_FTECLEDA_8700....................: ${ESF_FTECLEDA_8700} "                    >>$FLOG 


ECHO_LOG "#....................... OUTPUT ........ ................................."           >>$FLOG

ECHO_LOG "#===> ESF_FCSM_LC_ENDING_ASS................: ${ESF_FCSM_LC_ENDING_ASS} "             >>$FLOG
ECHO_LOG "#===> ESF_FCSM_ENDING_RNP...................: ${ESF_FCSM_ENDING_RNP} "                >>$FLOG
ECHO_LOG "#===> ESF_FCSM_LC_ENDING_ASS_ONLY...........: ${ESF_FCSM_LC_ENDING_ASS_ONLY} "   >>$FLOG
ECHO_LOG "#===> ESF_FCSM_ENDING_RNP_ONLY..............: ${ESF_FCSM_ENDING_RNP_ONLY} "      >>$FLOG 



NSTEP=${NJOB}_01
# -  Sort of IADPERICASE
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE + on Omet les mouvements de retro interne du Pericase"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       3:1 -  3:,
        END_NT       4:1 -  4:EN,
        SEC_NF       5:1 -  5:EN,
        UWY_NF       6:1 -  6:,
        UW_NT        7:1 -  7:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_01A
#------------------------------------------------------------------------------
LIBEL="Extract CUR of  BALSHTYEA=${ICLODAT_A}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCURQUOT_TXT}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCURQUOT_${ICLODAT_A}.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CURQUOT_UWY_NF   3:1 -  3:
/CONDITION IS_BALSHTYEA ( CURQUOT_UWY_NF = "${ICLODAT_A}" )
/INCLUDE IS_BALSHTYEA
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_01B
#------------------------------------------------------------------------------
LIBEL="Extend IADPERICASE with CURQUOT_RATE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01_${IB}_SORT_IADPERICASE.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
                all_cols                 1:1  - 205:
/joinkeys
       SSD_CF
      ,PCPCUR_CF
/INFILE ${DFILT}/${NJOB}_01A_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols
       ,rightside:CURQUOT_RATE

exit
EOF
SORT


NSTEP=${NJOB}_01C
#------------------------------------------------------------------------------
LIBEL="Extend IADPERICASE with EGPCUR_RATE, PCPCUR and EGPCUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01B_${IB}_IADPERICASE_PCP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP_EGP_O.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        EGPCUR_CF        23:1 - 23:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
                all_cols                 1:1  - 206:
/joinkeys
       SSD_CF
      ,EGPCUR_CF
/INFILE ${DFILT}/${NJOB}_01A_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:all_cols
        ,rightside:CURQUOT_RATE
        ,leftside:PCPCUR_CF
        ,leftside:EGPCUR_CF
exit
EOF
SORT


NSTEP=${NJOB}_01D
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01C_${IB}_IADPERICASE_PCP_EGP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP_EGP.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS CTR_NF    3:1 -  3:,
        END_NT    4:1 -  4:,
        SEC_NF    5:1 -  5:EN,
        UWY_NF    6:1 -  6:,
        UW_NT     7:1 -  7:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT

exit
EOF
SORT


# SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_FTECLEDA_3870.dat 2000 1"

## Exclude OPNG AND Annulations

NSTEP=${NJOB}_02
#------------------------------------------------------------------------------
LIBEL="Sort ESF_FTECLEDA_3870_PREV AND Exclude OPNG AND Annulations"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_3870_PREV} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_PREV_SANS_ANNU.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF          11:1 - 11:,
        GT_ANNUL 				114:1 - 114:,
        all_cols         1:1  - 118:
/CONDITION SANS_ANNU ( GT_ANNUL != "A" AND GT_ANNUL != "O" )
/INCLUDE SANS_ANNU
exit
EOF
SORT        

NSTEP=${NJOB}_05A
#------------------------------------------------------------------------------
LIBEL="Sort ESF_FTECLEDA_3870_PREV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
##SORT_I="${ESF_FTECLEDA_3870_PREV} 2000 1"
SORT_I="${DFILT}/${NJOB}_02_${IB}_SORT_FTECLEDA_3870_PREV_SANS_ANNU.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_RATE.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF          11:1 - 11:,
        CUR_CF          18:1 - 18:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 51:

/joinkeys 
      SSD_CF
	   ,CUR_CF
/INFILE ${DFILT}/${NJOB}_01A_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"
/joinkeys 
      CURQUOT_SSD_CF
	   ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	   leftside:all_cols
	  ,rightside:CURQUOT_RATE   

exit
EOF
SORT


NSTEP=${NJOB}_05B
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05A_${IB}_SORT_FTECLEDA_3870_RATE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_RATE_RETRATE.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS SSD_CF            1:1 -  1:,
        RTY_NF           27:1 - 27:,
        RETCUR_CF        34:1 - 34:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 52:

/joinkeys 
      SSD_CF
	   ,RETCUR_CF
/INFILE ${DFILT}/${NJOB}_01A_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"
/joinkeys 
      CURQUOT_SSD_CF
	   ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	   leftside:all_cols
	  ,rightside:CURQUOT_RATE   

exit
EOF
SORT


NSTEP=${NJOB}_05C
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTRSLNK_TXT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_I17.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS PRS_CF       1:1 -  1:
		,all_cols       1:1  - 3:
/CONDITION IS_EBS ( PRS_CF = "713" )
/INCLUDE IS_EBS
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_05D
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05B_${IB}_SORT_FTECLEDA_3870_RATE_RETRATE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_RATE_RETRATE_I17.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS TRNCOD_CF         6:1 -  6:,
        DETTRS_CF        3:1 -  3:,
        ACMTRS_NT        2:1 -  2:,
        all_cols         1:1  - 53:
/joinkeys 
       TRNCOD_CF 
/INFILE ${DFILT}/${NJOB}_05C_${IB}_FTRSLNK_I17.dat  2000 1 "~"
/joinkeys 
       DETTRS_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
      leftside:all_cols
     ,rightside:ACMTRS_NT   

exit
EOF
SORT


NSTEP=${NJOB}_05E
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05D_${IB}_SORT_FTECLEDA_3870_RATE_RETRATE_I17.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_RATE_RETRATE_I17_FBOPRSLNK.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS 
        TRNCOD_CF         		6:1 -  6:,
		FBOPRSLNK_ACMTRSL2_NT     4:1 -  4:,
		FBOPRSLNK_ACMTRSL3_NT     5:1 -  5:,
		FBOPRSLNK_DETTRS_CF       9:1 -  9:,
		FBOPRSLNK_TRNTYP_CT      14:1 - 14:,
		all_cols		              1:1  - 54:
/joinkeys 
       TRNCOD_CF
/INFILE ${EST_FBOPRSLNK_TXT} 2000 1 "~"
/joinkeys 
       FBOPRSLNK_DETTRS_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside:all_cols
	,rightside:FBOPRSLNK_ACMTRSL2_NT    
	,rightside:FBOPRSLNK_ACMTRSL3_NT    
	,rightside:FBOPRSLNK_TRNTYP_CT     

exit
EOF
SORT


NSTEP=${NJOB}_05F
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05E_${IB}_SORT_FTECLEDA_3870_RATE_RETRATE_I17_FBOPRSLNK.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_RATE_RETRATE_I17_FBOPRSLNK.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS 
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        PLC_NT           36:1 - 36:,
        all_cols          1:1  - 57:
/KEYS   CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,PLC_NT

exit
EOF
SORT


NSTEP=${NJOB}_07
#------------------------------------------------------------------------------
LIBEL="FTECLEDA_3870 PREPARATION : AJOUT CODE REGROUPEMENT + LOB + CONVERSION DES MONTANTS DANS DEVISE ALIMENT "
PRG=ESTC1051B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT A
BALSHTYEA_NF ${ICLODAT_A}
PRS_CF 751
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_01D_${IB}_IADPERICASE_PCP_EGP.dat
export ${PRG}_I2=${DFILT}/${NJOB}_05F_${IB}_SORT_FTECLEDA_3870_RATE_RETRATE_I17_FBOPRSLNK.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA_3870.dat
EXECPRG

## cp ${DFILT}/${NJOB}_07_${IB}_ESTC1051B_FTECLEDA_3870.dat  ${ESF_FTECLEDA_3870}

###


#--------------------------------------------------------------------------------
# 	REFORMAT ESF_TRERETFACCTR ACCORDING TO THE NORME : GROUP, PARENT and LOCAL
#--------------------------------------------------------------------------------
if [ ${NORME_CF} = "I17G" ]
then
NSTEP=${NJOB}_08
LIBEL="REFORMAT ESF_TRERETFACCTR to GROUP FORMAT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_TRERETFACCTR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRERETFACCTR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	FILLER		1:1     - 17:
/OUTFILE ${SORT_O} OVERWRITE
/COPY 	
exit
EOF
SORT

elif [ ${NORME_CF} = "I17P" ]
then
NSTEP=${NJOB}_08
LIBEL="REFORMAT ESF_TRERETFACCTR to PARENT FORMAT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_TRERETFACCTR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRERETFACCTR.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	FILLER1			1:1     - 11:,
	INI_STATUS_P 	13:1    - 13:,
	FIRST_CLODAT_P  16:1    - 16:
/DERIVEDFIELD SPACES "~~"	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
	FILLER1,
	INI_STATUS_P,
	SPACES,
	FIRST_CLODAT_P
/COPY 
exit
EOF
SORT

else

NSTEP=${NJOB}_08
LIBEL="REFORMAT ESF_TRERETFACCTR to LOCAL FORMAT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_TRERETFACCTR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRERETFACCTR.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	FILLER1			1:1     - 11:,
	INI_STATUS_L 	14:1    - 14:,
	FIRST_CLODAT_L  17:1    - 17:
/DERIVEDFIELD SPACES "~~"	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
	FILLER1,
	INI_STATUS_L,
	SPACES,
	FIRST_CLODAT_L
/COPY 
exit
EOF
SORT

fi





NSTEP=${NJOB}_10
# Filter ESF_FTRSLNK_TXT on PRS_CF = "751"
#-----------------------------------------------------------------------------
LIBEL="Filter ESF_FTRSLNK_TXT on PRS_CF = "751" AND (ACMTRS_NT = "3430"  OR AACMTRS_NT = "3330"  )"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751_CSM_LC_ENDING.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  PRS_CF       1:1 -  1:,
         ACMTRS_NT    2:1 -  2:
/CONDITION IS_PRS_751_LC_CSM_ENDING ( PRS_CF = "751" AND (ACMTRS_NT = "3430"  OR  ACMTRS_NT = "3330"  ) )
/OUTFILE $SORT_O
/INCLUDE IS_PRS_751_LC_CSM_ENDING
/COPY
exit
EOF
SORT




NSTEP=${NJOB}_15
#------------------------------------------------------------------------------------
LIBEL="Exclude Life from ESF_FTECLEDA_3870_PREV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
##SORT_I="${ESF_FTECLEDA_3870_PREV} 2000 1" 
SORT_I="${DFILT}/${NJOB}_07_${IB}_ESTC1051B_FTECLEDA_3870.dat 2000 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_ESF_FTECLEDA_3870.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        BALSHEY_NF        3:1 -   3:EN,
        BALSHRMTH_NF      4:1 -   4:EN,
        DETTRS_CF        6:1 - 6:,
        LOBACC_CF        45:1 - 45:,
        NATRET_CF        52:1 - 52:        

/KEYS   DETTRS_CF
/CONDITION VIE ( LOBACC_CF="30" OR LOBACC_CF="31" ) 
/OMIT VIE
exit
EOF
SORT

NSTEP=${NJOB}_17
#------------------------------------------------------------------------------------
LIBEL="ONLY RETRO NP from ESF_IRDPERICASE0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IRDPERICASE0} 2000 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        RETCTR_NF        3:1 -   3:,
        RETEND_NF        4:1 -   4:,
        RETSEC_NF        5:1 -   5:,
        RTY_NF           6:1 -   6:,
        RETUW_NT         7:1 -   7:,    
        NATRET_CF        49:1 - 49:               

/KEYS   RETCTR_NF,
				RETEND_NF,    
				RETSEC_NF,
				RTY_NF,   
				RETUW_NT 				
/CONDITION  RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  ) 
/INCLUDE RETRO_NP
exit
EOF
SORT

## MERGE DU ESF_FTECLEDA_8700 et ESF_FTECLEDA_3870

NSTEP=${NJOB}_18
#------------------------------------------------------------------------------
LIBEL="MERGE ESFD3870 CURRENT WITH ESID8700  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_8700} 2000 1" 
SORT_I2="${ESF_FTECLEDA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_MERGE.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   
	GT_TRNCOD_CF 			6:1 	- 6:,   	
	GT_CTR_NF 			  8:1 	- 8:, 
	GT_END_NT			    9:1 	- 9:, 
	GT_SEC_NF 			  10:1 	- 10:, 
	GT_UWY_NF 			  11:1 	- 11:, 
	GT_UW_NT 			    12:1 	- 12:, 
	GT_RETCTR_NF 			24:1 	- 24:,
	GT_RETEND_NT			25:1 	- 25:,
	GT_RETSEC_NF 			26:1 	- 26:,
	GT_RETRTY_NF 			27:1 	- 27:,
	GT_RETUW_NT 			28:1 	- 28:,
	GT_OPNG_ANNUL 		114:1 	- 114:	
/KEYS  
   GT_TRNCOD_CF
	,GT_CTR_NF 			 
	,GT_END_NT			   
	,GT_SEC_NF 			 
	,GT_UWY_NF 			 
	,GT_UW_NT 			   
	,GT_RETCTR_NF 			
	,GT_RETEND_NT			
	,GT_RETSEC_NF 			
	,GT_RETRTY_NF 			
	,GT_RETUW_NT 	
/SUM
/CONDITION 	MERGE_WITHOUT_OPNG (GT_OPNG_ANNUL != "O" AND GT_OPNG_ANNUL != "A")	
/OUTFILE ${SORT_O} 
/INCLUDE MERGE_WITHOUT_OPNG
exit
EOF
SORT



NSTEP=${NJOB}_20
# Join AND Extend ESFD3870  with PRS_751 of _FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join FTECLEDA_3870 with PRS_ 751 and _FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESF_FTECLEDA_3870.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_FTECLEDA_3870_CSM_LC_ENDING.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_10_${IB}_FTRSLNK_751_CSM_LC_ENDING.dat 2000 1 "~"       
/joinkeys 
       DETTRS_CF_F2
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:COLS_STD_F1
	,rightside:PRS_CF_F2  
	,rightside:ACMTRS_NT_F2 	  							  
exit
EOF
SORT



NSTEP=${NJOB}_22
# Join AND Extend ESFD3870  with PRS_751 of _FTRSLNK.dat NOT EXIST
#-----------------------------------------------------------------------------
LIBEL="Join FTECLEDA_3870 with PRS_ 751 and _FTRSLNK.dat LC CSM ENDING NOT EXIST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESF_FTECLEDA_3870.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_10_${IB}_FTRSLNK_751_CSM_LC_ENDING.dat 2000 1 "~"       
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite       
/REFORMAT 
	leftside:COLS_STD_F1
	,rightside:PRS_CF_F2  
	,rightside:ACMTRS_NT_F2 	  							  
exit
EOF
SORT

## GENERATE RETRO NP FROM IRDPERICASE0 


NSTEP=${NJOB}_23
LIBEL="GENERATE RETRO NP CSM ENDING EXIST FROM IRDPERICASE0  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_ESF_FTECLEDA_3870_CSM_LC_ENDING.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_FTECLEDA_3870_CSM_LC_ENDING_NP.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	GT_RETCTR_NF 			24:1 	- 24:,
	GT_RETEND_NT			25:1 	- 25:,
	GT_RETSEC_NF 			26:1 	- 26:,
	GT_RETRTY_NF 			27:1 	- 27:,
	GT_RETUW_NT 			28:1 	- 28:,
	CTR_NF   				3:1 	- 3:,
	END_NT   				4:1 	- 4:,
	SEC_NF  				5:1 	- 5:,
	UWY_NF   				6:1 	- 6:,
	UW_NT    				7:1 	- 7:,
	NATRET_CF    		49:1 	- 49:,	
	FILLER					1:1		- 122:	
/JOINKEYS
	GT_RETCTR_NF,    
	GT_RETEND_NT,    
	GT_RETSEC_NF,    
	GT_RETRTY_NF,    
	GT_RETUW_NT		
/INFILE ${DFILT}/${NJOB}_17_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:NATRET_CF
exit
EOF
SORT


NSTEP=${NJOB}_24
LIBEL="GENERATE RETRO NP FROM IRDPERICASE0 NOT EXIST ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_22_${IB}_SORT_ESF_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_NOT_EXIST.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	GT_RETCTR_NF 			24:1 	- 24:,
	GT_RETEND_NT			25:1 	- 25:,
	GT_RETSEC_NF 			26:1 	- 26:,
	GT_RETRTY_NF 			27:1 	- 27:,
	GT_RETUW_NT 			28:1 	- 28:,
	CTR_NF   				3:1 	- 3:,
	END_NT   				4:1 	- 4:,
	SEC_NF  				5:1 	- 5:,
	UWY_NF   				6:1 	- 6:,
	UW_NT    				7:1 	- 7:,
	NATRET_CF    		49:1 	- 49:,	
	FILLER					1:1		- 122:	
/JOINKEYS
	GT_RETCTR_NF,    
	GT_RETEND_NT,    
	GT_RETSEC_NF,    
	GT_RETRTY_NF,    
	GT_RETUW_NT		
/INFILE  ${DFILT}/${NJOB}_17_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:NATRET_CF
exit
EOF
SORT



NSTEP=${NJOB}_25
#------------------------------------------------------------------------------------
LIBEL="Generate RETRO_NP AND OTHER ESFD3870"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_ESF_FTECLEDA_3870_CSM_LC_ENDING.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP.dat OVERWRITE 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        BALSHEY_NF        3:1 -   3:EN,
        BALSHRMTH_NF      4:1 -   4:EN,
        DETTRS_CF        6:1 - 6:,
        LOBACC_CF        45:1 - 45:,
        NATRET_CF        52:1 - 52:        

/KEYS   DETTRS_CF
/CONDITION  RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  ) 
/OUTFILE ${SORT_O}
/OMIT RETRO_NP 	
/OUTFILE ${SORT_O2}
/INCLUDE RETRO_NP												  
exit
EOF
SORT

##${DFILT}/${NJOB}_08_${IB}_TRERETFACCTR.dat

## /INFILE ${DFILT}/${NJOB}_10_${IB}_FTRSLNK_751_CSM_LC_ENDING.dat 2000 1 "~" 

NSTEP=${NJOB}_30
LIBEL="JOIN ESFD3870 ASSUMED FILE && ESF_TRERETFACCTR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	GT_CTR_NF 			8:1 	- 8:,
	GT_END_NT				9:1 	- 9:,
	GT_SEC_NF 			10:1 	- 10:,
	GT_UWY_NF 			11:1 	- 11:,
	GT_UW_NT 				12:1 	- 12:,
	CTR_NF   				1:1 	- 1:,
	END_NT   				2:1 	- 2:,
	SEC_NF  				3:1 	- 3:,
	UWY_NF   				4:1 	- 4:,
	UW_NT    				5:1 	- 5:,
	INI_STATUS			12:1 	- 12:,
	FIRST_CLODAT_D	15:1 	- 15:,
	FILLER					1:1		- 122:	
/JOINKEYS
	GT_CTR_NF,    
	GT_END_NT,    
	GT_SEC_NF,    
	GT_UWY_NF,    
	GT_UW_NT		
/INFILE ${DFILT}/${NJOB}_08_${IB}_TRERETFACCTR.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:INI_STATUS,FIRST_CLODAT_D
exit
EOF
SORT



NSTEP=${NJOB}_35
LIBEL="JOIN ESFD3870 RETRO_NP FILE && ESF_TRERETFACCTR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP.dat 2000 1 "
SORT_I="${DFILT}/${NJOB}_23_${IB}_SORT_ESF_FTECLEDA_3870_CSM_LC_ENDING_NP.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETCTR_NF 			24:1 	- 24:,
	RETEND_NT 			25:1 	- 25:,
	RETSEC_NF 			26:1 	- 26:,
	RTY_NF 					27:1 	- 27:,
	RETUW_NT 				28:1 	- 28:,
	CTR_NF          1:1 	- 1:,
	END_NT          2:1 	- 2:,
	SEC_NF          3:1 	- 3:,
	UWY_NF          4:1 	- 4:,
	UW_NT           5:1 	- 5:,
	INI_STATUS			12:1 	- 12:,
	FIRST_CLODAT_D	15:1 	- 15:,
	FILLER					1:1		- 122:	
/JOINKEYS
	RETCTR_NF,    
	RETEND_NT,    
	RETSEC_NF,    
	RTY_NF
/INFILE ${DFILT}/${NJOB}_08_${IB}_TRERETFACCTR.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:INI_STATUS,FIRST_CLODAT_D
exit
EOF
SORT



### MANAGE NOT EXIST LC CSM ENDING **********************


NSTEP=${NJOB}_40
#------------------------------------------------------------------------------------
LIBEL="Generate RETRO_NP AND OTHER ESFD3870 NOT EXIST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_22_${IB}_SORT_ESF_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_NOT_EXIST.dat OVERWRITE 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        BALSHEY_NF        3:1 -   3:EN,
        BALSHRMTH_NF      4:1 -   4:EN,
        DETTRS_CF        6:1 - 6:,
        LOBACC_CF        45:1 - 45:,
        NATRET_CF        52:1 - 52:        

/KEYS   DETTRS_CF
/CONDITION  RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  ) 
/OUTFILE ${SORT_O}
/OMIT RETRO_NP 	
/OUTFILE ${SORT_O2}
/INCLUDE RETRO_NP												  
exit
EOF
SORT


NSTEP=${NJOB}_45
LIBEL="JOIN ESFD3870 ASSUMED FILE NOT EXIST && ESF_TRERETFACCTR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	GT_CTR_NF 			8:1 	- 8:,
	GT_END_NT				9:1 	- 9:,
	GT_SEC_NF 			10:1 	- 10:,
	GT_UWY_NF 			11:1 	- 11:,
	GT_UW_NT 				12:1 	- 12:,
	CTR_NF   				1:1 	- 1:,
	END_NT   				2:1 	- 2:,
	SEC_NF  				3:1 	- 3:,
	UWY_NF   				4:1 	- 4:,
	UW_NT    				5:1 	- 5:,
	INI_STATUS			12:1 	- 12:,
	FIRST_CLODAT_D	15:1 	- 15:,
	FILLER					1:1		- 122:	
/JOINKEYS
	GT_CTR_NF,    
	GT_END_NT,    
	GT_SEC_NF,    
	GT_UWY_NF,    
	GT_UW_NT		
/INFILE ${DFILT}/${NJOB}_08_${IB}_TRERETFACCTR.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:INI_STATUS,FIRST_CLODAT_D
exit
EOF
SORT


NSTEP=${NJOB}_50
LIBEL="  GENERATES CSM ENDING Q-1 LC ENDING Q-1 ASSUMED  WHEN NOT EXIST..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	TRNCOD_CF 			6:1 	- 6:,
	TRNCOD1_CF 			6:1 	- 6:1,	
	CTR_NF 					8:1 	- 8:,
	END_NT 					9:1 	- 9:,
	SEC_NF 					10:1 	- 10:,
	UWY_NF 					11:1 	- 11:,
	UW_NT 					12:1 	- 12:,
  FILLER_1_17      1:1 	- 17:,
	CUR_CF 					18:1 	- 18:,	
	AMT_M 					19:1 	- 19:EN 18/3,
  FILLER_20_33    20:1 	- 33:,
	RETCUR_CF 			34:1 	- 34:,		
	RETAMT_M 				35:1 	- 35:EN 18/3,
  FILLER_36_113   36:1 	- 113:,			
	GT_ANNUL 				114:1 - 114:,	
  FILLER_115_120  115:1 - 120:,		
	ACMTRS_NT_F2		121:1 - 121:,	
  FILLER_122_122  122:1 - 122:,		
	INI_STATUS			123:1 - 123:,
	FIRST_CLODAT_D	124:1 - 124:,
  FILLER_125_127  125:1 - 127:,	
	FILLER					1:1	- 127:,
	CSM_ENDING_M 		128:1 - 128:EN 18/3,
	LC_ENDING_M 		129:1 - 129:EN 18/3		
/KEYS   
  CTR_NF, 
  END_NT, 
  SEC_NF, 
  UWY_NF, 
  UW_NT, 	         
  ACMTRS_NT_F2,
  TRNCOD1_CF,
  INI_STATUS,
  GT_ANNUL 	
/CONDITION LC_CSM_ENDING_NOT_EXIST   ( (TRNCOD1_CF = "1") AND  (INI_STATUS != "1" AND  ( ACMTRS_NT_F2 != "3430" AND ACMTRS_NT_F2 != "3330" ) ) 	 AND ( GT_ANNUL != "A" AND GT_ANNUL != "O")  )
/DERIVEDFIELD AMT_MC 0
/OUTFILE ${SORT_O}
/INCLUDE LC_CSM_ENDING_NOT_EXIST
/REFORMAT
	FILLER_1_17, CUR_CF, AMT_MC, FILLER_20_33, RETCUR_CF, AMT_MC, FILLER_36_113, GT_ANNUL, FILLER_115_120, ACMTRS_NT_F2, FILLER_122_122, INI_STATUS, FIRST_CLODAT_D, FILLER_125_127
exit
EOF
SORT

##[004]SORT_I="${DFILT}/${NJOB}_45_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat  2000 1"

NSTEP=${NJOB}_55
LIBEL="  GENERATES CSM ENDING Q-1 LC ENDING Q-1 ASSUMED  WHEN NOT EXIST UNIQUE CSUE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	TRNCOD_CF 			6:1 	- 6:,
	TRNCOD1_CF 			6:1 	- 6:1,	
	CTR_NF 					8:1 	- 8:,
	END_NT 					9:1 	- 9:,
	SEC_NF 					10:1 	- 10:,
	UWY_NF 					11:1 	- 11:,
	UW_NT 					12:1 	- 12:,
  FILLER_1_17      1:1 	- 17:,
	CUR_CF 					18:1 	- 18:,	
	AMT_M 					19:1 	- 19:EN 18/3,
  FILLER_20_33    20:1 	- 33:,
	RETCUR_CF 			34:1 	- 34:,		
	RETAMT_M 				35:1 	- 35:EN 18/3,
  FILLER_36_113   36:1 	- 113:,			
	GT_ANNUL 				114:1 - 114:,	
  FILLER_115_120  115:1 - 120:,		
	ACMTRS_NT_F2		121:1 - 121:,	
  FILLER_122_122  122:1 - 122:,		
	INI_STATUS			123:1 - 123:,
	FIRST_CLODAT_D	124:1 - 124:,
  FILLER_125_127  125:1 - 127:,	
	FILLER					1:1	- 127:,
	CSM_ENDING_M 		128:1 - 128:EN 18/3,
	LC_ENDING_M 		129:1 - 129:EN 18/3		
/KEYS   
  CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/SUM  
/DERIVEDFIELD AMT_MC 0.000
/DERIVEDFIELD SEP "~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, AMT_MC, SEP, AMT_MC, SEP, AMT_MC
exit
EOF
SORT

###  MANAGE RETRO NP WHEN LC CSM NOT EXIST ###########

NSTEP=${NJOB}_60
LIBEL="JOIN ESFD3870 RETRO_NP NOT EXIST FILE && ESF_TRERETFACCTR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_NOT_EXIST.dat 2000 1 "
SORT_I="${DFILT}/${NJOB}_24_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_NOT_EXIST.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_NOT_EXIST.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETCTR_NF 			24:1 	- 24:,
	RETEND_NT 			25:1 	- 25:,
	RETSEC_NF 			26:1 	- 26:,
	RTY_NF 					27:1 	- 27:,
	RETUW_NT 				28:1 	- 28:,
	CTR_NF          1:1 	- 1:,
	END_NT          2:1 	- 2:,
	SEC_NF          3:1 	- 3:,
	UWY_NF          4:1 	- 4:,
	UW_NT           5:1 	- 5:,
	INI_STATUS			12:1 	- 12:,
	FIRST_CLODAT_D	15:1 	- 15:,
	FILLER					1:1		- 122:	
/JOINKEYS
	RETCTR_NF,    
	RETEND_NT,    
	RETSEC_NF,    
	RTY_NF
/INFILE ${DFILT}/${NJOB}_08_${IB}_TRERETFACCTR.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:INI_STATUS,FIRST_CLODAT_D
exit
EOF
SORT



NSTEP=${NJOB}_65
LIBEL=" WHEN NOT EXISTE CSM LC RETRO_NP GENERATES CSM ENDING Q-1 LC ENDING Q-1 WITH 0..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_NOT_EXIST.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_NOT_EXIST.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	TRNCOD_CF 			6:1 	- 6:,
	TRNCOD1_CF 			6:1 	- 6:1,	
	RETCTR_NF 			24:1 	- 24:,
	RETEND_NT 			25:1 	- 25:,
	RETSEC_NF 			26:1 	- 26:,
	RTY_NF 					27:1 	- 27:,
	RETUW_NT 				28:1 	- 28:,
	RETCUR_CF 			34:1 	- 34:,		
	RETAMT_M 				35:1 	- 35:EN 18/3,	
	GT_ANNUL 				114:1 - 114:,		
	ACMTRS_NT_F2		121:1 - 121:,	
	INI_STATUS			123:1 - 123:,
	FIRST_CLODAT_D	124:1 - 124:,
	FILLER					1:1	- 127:
/KEYS   
  RETCTR_NF,
  RETEND_NT,
  RETSEC_NF,
  RTY_NF,
  RETUW_NT,
  RETCUR_CF,        
  ACMTRS_NT_F2,
  TRNCOD1_CF,
  GT_ANNUL 	
/DERIVEDFIELD RETAMT_MC 0.000
/DERIVEDFIELD SEP "~"
/CONDITION CSM_ENDING_NOT_EXIST  ( (TRNCOD1_CF = "2") AND  (INI_STATUS != "1" AND  ACMTRS_NT_F2 != "3330" ) 	 AND ( GT_ANNUL != "A" AND GT_ANNUL != "O")  )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE CSM_ENDING_NOT_EXIST
/REFORMAT
	RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,RETAMT_MC
exit
EOF
SORT

###  END MANAGE RETRO NP WHEN LC CSM NOT EXIST ###########

NSTEP=${NJOB}_75
LIBEL=" OTHER  DIFFERENT TO RETRO_NP GENERATES CSM ENDING Q-1 LC ENDING Q-1 ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_ALL_CSM_ENDING_RETRO_NP.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	TRNCOD_CF 			6:1 	- 6:,
	TRNCOD1_CF 			6:1 	- 6:1,	
	RETCTR_NF 			24:1 	- 24:,
	RETEND_NT 			25:1 	- 25:,
	RETSEC_NF 			26:1 	- 26:,
	RTY_NF 					27:1 	- 27:,
	RETUW_NT 				28:1 	- 28:,
	RETCUR_CF 			34:1 	- 34:,		
	RETAMT_M 				35:1 	- 35:EN 18/3,	
	GT_ANNUL 				114:1 - 114:,		
	ACMTRS_NT_F2		121:1 - 121:,	
	INI_STATUS			123:1 - 123:,
	FIRST_CLODAT_D	124:1 - 124:,
	FILLER					1:1	- 127:
/KEYS   
  RETCTR_NF,
  RETSEC_NF,
  RTY_NF,
  RETUW_NT,
  RETCUR_CF,        
  ACMTRS_NT_F2,
  TRNCOD1_CF,
  GT_ANNUL 	
/SUMMARIZE  TOTAL RETAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETEND_NT_NEW  0
/CONDITION CSM_ENDING  ( (TRNCOD1_CF = "2") AND  (INI_STATUS != "1" AND  ACMTRS_NT_F2 = "3330" ) 	 AND ( GT_ANNUL != "A" AND GT_ANNUL != "O")  )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE CSM_ENDING
/REFORMAT
  RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETAMT_MC
exit
EOF
SORT


NSTEP=${NJOB}_80
LIBEL="  GENERATES CSM ENDING Q-1 LC ENDING Q-1 ASSUMED ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_ALL_LC_CSM_ENDING_ASS.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	TRNCOD_CF 			6:1 	- 6:,
	TRNCOD1_CF 			6:1 	- 6:1,	
	CTR_NF 					8:1 	- 8:,
	END_NT 					9:1 	- 9:,
	SEC_NF 					10:1 	- 10:,
	UWY_NF 					11:1 	- 11:,
	UW_NT 					12:1 	- 12:,
  FILLER_1_17      1:1 	- 17:,
	CUR_CF 					18:1 	- 18:,	
	AMT_M 					19:1 	- 19:EN 18/3,
  FILLER_20_33    20:1 	- 33:,
	RETCUR_CF 			34:1 	- 34:,		
	RETAMT_M 				35:1 	- 35:EN 18/3,
  FILLER_36_113   36:1 	- 113:,			
	GT_ANNUL 				114:1 - 114:,	
  FILLER_115_120  115:1 - 120:,		
	ACMTRS_NT_F2		121:1 - 121:,	
  FILLER_122_122  122:1 - 122:,		
	INI_STATUS			123:1 - 123:,
	FIRST_CLODAT_D	124:1 - 124:,
  FILLER_125_127  125:1 - 127:,	
	FILLER					1:1	- 127:,
	CSM_ENDING_M 		128:1 - 128:EN 18/3,
	LC_ENDING_M 		129:1 - 129:EN 18/3		
/KEYS   
  CTR_NF, 
  END_NT, 
  SEC_NF, 
  UWY_NF, 
  UW_NT, 	         
  ACMTRS_NT_F2,
  TRNCOD1_CF,
  INI_STATUS,
  GT_ANNUL 	
/SUMMARIZE  TOTAL AMT_M
/CONDITION LC_CSM_ENDING   ( (TRNCOD1_CF = "1") AND  (INI_STATUS != "1" AND  ( ACMTRS_NT_F2 = "3430" OR ACMTRS_NT_F2 = "3330" ) ) 	 AND ( GT_ANNUL != "A" AND GT_ANNUL != "O")  )
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/INCLUDE LC_CSM_ENDING
/REFORMAT
	FILLER_1_17, CUR_CF, AMT_MC, FILLER_20_33, RETCUR_CF, AMT_MC, FILLER_36_113, GT_ANNUL, FILLER_115_120, ACMTRS_NT_F2, FILLER_122_122, INI_STATUS, FIRST_CLODAT_D, FILLER_125_127
exit
EOF
SORT


NSTEP=${NJOB}_90
# Generate ABS Of AMOUNT  
#-----------------------------------------------------------------------------
LIBEL="Generate ABS CSM + ABS LC Of AMOUNT ALL_CSM_LC_ENDING_ASSUMES "
AWK_I="${DFILT}/${NJOB}_80_${IB}_SORT_FTECLEDA_3870_ALL_LC_CSM_ENDING_ASS.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_FTECLEDA_3870_ALL_LC_CSM_ENDING_ASS.dat"
AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{
		if (\$19  < 0) \$19 = sprintf("%-.3lf",-\$19);
		if (\$35  < 0) \$35 = sprintf("%-.3lf",-\$35); 
		print \$0;
	}
exit
EOF
AWK

## 	FILLER_1_17, CUR_CF, AMT_MC, FILLER_20_33, RETCUR_CF, AMT_MC, FILLER_36_113, GT_ANNUL, FILLER_115_120, ACMTRS_NT_F2, FILLER_122_122, INI_STATUS, FIRST_CLODAT_D, FILLER_125_127

NSTEP=${NJOB}_100
LIBEL=" GENERATE ABS(CSM) + ABS(LC) ENDING Q-1 ASSUMED ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_AWK_FTECLEDA_3870_ALL_LC_CSM_ENDING_ASS.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_ALL_LC_CSM_ENDING_ASS.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	TRNCOD_CF 			6:1 	- 6:,
	TRNCOD1_CF 			6:1 	- 6:1,	
	CTR_NF 					8:1 	- 8:,
	END_NT 					9:1 	- 9:,
	SEC_NF 					10:1 	- 10:,
	UWY_NF 					11:1 	- 11:,
	UW_NT 					12:1 	- 12:,
  FILLER_1_17      1:1 	- 17:,
	CUR_CF 					18:1 	- 18:,	
	AMT_M 					19:1 	- 19:EN 18/3,
  FILLER_20_33    20:1 	- 33:,
	RETCUR_CF 			34:1 	- 34:,		
	RETAMT_M 				35:1 	- 35:EN 18/3,
  FILLER_36_113   36:1 	- 113:,			
	GT_ANNUL 				114:1 - 114:,	
  FILLER_115_120  115:1 - 120:,		
	ACMTRS_NT_F2		121:1 - 121:,	
  FILLER_122_122  122:1 - 122:,		
	INI_STATUS			123:1 - 123:,
	FIRST_CLODAT_D	124:1 - 124:,
  FILLER_125_127  125:1 - 127:,	
	FILLER					1:1	- 127:	
/KEYS   
  CTR_NF,
  END_NT,
  SEC_NF, 
  UWY_NF, 
  UW_NT
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT
	CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, AMT_MC, AMT_MC, AMT_MC
exit
EOF
SORT




NSTEP=${NJOB}_110
LIBEL="  SUMMARIZECSM ENDING Q-1 LC ENDING Q-1 ASSUMED  UNIQUE CSUE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_NOT_EXIST.dat  2000 1"
SORT_I2="${DFILT}/${NJOB}_100_${IB}_SORT_FTECLEDA_3870_ALL_LC_CSM_ENDING_ASS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_ALL.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF 					1:1 	- 1:,
	END_NT 		 			2:1 	- 2:,	
	SEC_NF 					3:1 	- 3:,
	UWY_NF 					4:1 	- 4:,
	UW_NT 					5:1 	- 5:,
	LC_CSM_ENDING 	6:1 	- 6:EN 18/3
/KEYS   
  CTR_NF, SEC_NF, UWY_NF, UW_NT
/SUMMARIZE  TOTAL LC_CSM_ENDING  
/DERIVEDFIELD LC_CSM_ENDING_MC LC_CSM_ENDING COMPRESS
/DERIVEDFIELD END_NT_NEW  "0~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	CTR_NF, END_NT_NEW, SEC_NF, UWY_NF, UW_NT, LC_CSM_ENDING_MC
exit
EOF
SORT


NSTEP=${NJOB}_120
LIBEL=" GENERATE CSM LC (ABS(CSM) + ABS(LC) < 1 ) ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_ALL.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_ALL_CSM_LC_ENDING_ASS.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF 					1:1 	- 1:,
	END_NT 					2:1 	- 2:,
	SEC_NF 					3:1 	- 3:,
	UWY_NF 					4:1 	- 4:,
	UW_NT 					5:1 	- 5:,
	CSM_PLUS_LC_M 	6:1 	- 6:EN 18/3
/KEYS   
  CTR_NF,
  SEC_NF,
  UWY_NF,
  UW_NT
/CONDITION CSM_PLUS_LC_ABS  ( CSM_PLUS_LC_M < 1 )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE CSM_PLUS_LC_ABS
/REFORMAT
	CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CSM_PLUS_LC_M
exit
EOF
SORT

### GENERATE UNIQUE CSUE 

## Generate LC CSM ENDING Q-1 ONLY

EXECKSH "cp ${DFILT}/${NJOB}_120_${IB}_SORT_FTECLEDA_3870_ALL_CSM_LC_ENDING_ASS.dat ${ESF_FCSM_LC_ENDING_ASS_ONLY}"


## [003] GENERATE DELTA ESID8700 AND ESFD3870_Q-1



NSTEP=${NJOB}_125
LIBEL="GENERATE ASSUME AND RETRO PROP ESF_FTECLEDA_8700   ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_18_${IB}_SORT_FTECLEDA_3870_8700_MERGE.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_MERGE_ASS.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	GT_CTR_NF 			  8:1 	- 8:, 
	GT_END_NT			    9:1 	- 9:, 
	GT_SEC_NF 			  10:1 	- 10:, 
	GT_UWY_NF 			  11:1 	- 11:, 
	GT_UW_NT 			    12:1 	- 12:, 
	GT_RETCTR_NF 			24:1 	- 24:,
	GT_RETEND_NT			25:1 	- 25:,
	GT_RETSEC_NF 			26:1 	- 26:,
	GT_RETRTY_NF 			27:1 	- 27:,
	GT_RETUW_NT 			28:1 	- 28:,
	CTR_NF   				  3:1 	- 3:,
	END_NT   				  4:1 	- 4:,
	SEC_NF  				  5:1 	- 5:,
	UWY_NF   				  6:1 	- 6:,
	UW_NT    				  7:1 	- 7:,
	NATRET_CF    		  49:1 	- 49:,	
	FILLER					  1:1		- 118:	
/JOINKEYS
	GT_RETCTR_NF,    
	GT_RETEND_NT,    
	GT_RETSEC_NF,    
	GT_RETRTY_NF,    
	GT_RETUW_NT		
/INFILE ${DFILT}/${NJOB}_17_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
LEFTSIDE:FILLER
exit
EOF
SORT

NSTEP=${NJOB}_130
LIBEL="GENERATE ASSUME AND RETRO PROP ESF_FTECLEDA_3870_PREV   ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${ESF_FTECLEDA_3870_PREV} 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_FTECLEDA_3870_PREV_ASS.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	GT_CTR_NF 			  8:1 	- 8:, 
	GT_END_NT			    9:1 	- 9:, 
	GT_SEC_NF 			  10:1 	- 10:, 
	GT_UWY_NF 			  11:1 	- 11:, 
	GT_UW_NT 			    12:1 	- 12:, 
	GT_RETCTR_NF 			24:1 	- 24:,
	GT_RETEND_NT			25:1 	- 25:,
	GT_RETSEC_NF 			26:1 	- 26:,
	GT_RETRTY_NF 			27:1 	- 27:,
	GT_RETUW_NT 			28:1 	- 28:,
	CTR_NF   				  3:1 	- 3:,
	END_NT   				  4:1 	- 4:,
	SEC_NF  				  5:1 	- 5:,
	UWY_NF   				  6:1 	- 6:,
	UW_NT    				  7:1 	- 7:,
	NATRET_CF    		  49:1 	- 49:,	
	FILLER					  1:1		- 118:	
/JOINKEYS
	GT_RETCTR_NF,    
	GT_RETEND_NT,    
	GT_RETSEC_NF,    
	GT_RETRTY_NF,    
	GT_RETUW_NT		
/INFILE ${DFILT}/${NJOB}_17_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT	
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER
exit
EOF
SORT



NSTEP=${NJOB}_135
LIBEL="GENERATE ASSUME AND RETRO PROP ESF_FTECLEDA_8700_ASS MINUS ESF_FTECLEDA_3870_PREV_ASS  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_125_${IB}_SORT_FTECLEDA_3870_8700_MERGE_ASS.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_ASS.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	GT_CTR_NF 			  8:1 	- 8:, 
	GT_END_NT			    9:1 	- 9:, 
	GT_SEC_NF 			  10:1 	- 10:, 
	GT_UWY_NF 			  11:1 	- 11:, 
	GT_UW_NT 			    12:1 	- 12:, 
	CTR_NF   				  8:1 	- 8:, 
	END_NT   				  9:1 	- 9:, 
	SEC_NF  				  10:1 	- 10:,
	UWY_NF   				  11:1 	- 11:,
	UW_NT    				  12:1 	- 12:,
	NATRET_CF    		  49:1 	- 49:,	
	FILLER					  1:1		- 118:	
/JOINKEYS
	GT_CTR_NF,    
	GT_END_NT,    
	GT_SEC_NF,    
	GT_UWY_NF,    
	GT_UW_NT 	
/INFILE ${DFILT}/${NJOB}_130_${IB}_SORT_ESF_FTECLEDA_3870_PREV_ASS.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
LEFTSIDE:FILLER
exit
EOF
SORT 

## [004] Deb Modif 

### FILTRER / APPLIQUER La condition INIT_STS != "1" sur le fichier Merge FTECLEDA3870_8700 

NSTEP=${NJOB}_137
LIBEL="JOIN FTECLEDA_3870_8700_DELTA_MERGE_ASS.dat  ASSUMED FILE && ESF_TRERETFACCTR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_135_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_ASS.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_ASS.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	GT_CTR_NF 			8:1 	- 8:,
	GT_END_NT				9:1 	- 9:,
	GT_SEC_NF 			10:1 	- 10:,
	GT_UWY_NF 			11:1 	- 11:,
	GT_UW_NT 				12:1 	- 12:,
	CTR_NF   				1:1 	- 1:,
	END_NT   				2:1 	- 2:,
	SEC_NF  				3:1 	- 3:,
	UWY_NF   				4:1 	- 4:,
	UW_NT    				5:1 	- 5:,
	INI_STATUS			12:1 	- 12:,
	FIRST_CLODAT_D	15:1 	- 15:,
	FILLER					1:1		- 122:	
/JOINKEYS
	GT_CTR_NF,    
	GT_END_NT,    
	GT_SEC_NF,    
	GT_UWY_NF,    
	GT_UW_NT		
/INFILE ${DFILT}/${NJOB}_08_${IB}_TRERETFACCTR.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:INI_STATUS,FIRST_CLODAT_D
exit
EOF
SORT

### FILTRER / APPLIQUER La condition INIT_STS != "1" sur le fichier Merge FTECLEDA3870_8700 


NSTEP=${NJOB}_138
LIBEL=" APPLIQUER La condition INIT_STS != 1 sur le fichier Merge FTECLEDA3870_8700..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_137_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_ASS.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_ASS.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	TRNCOD_CF 			6:1 	- 6:,
	TRNCOD1_CF 			6:1 	- 6:1,	
	CTR_NF 					8:1 	- 8:,
	END_NT 					9:1 	- 9:,
	SEC_NF 					10:1 	- 10:,
	UWY_NF 					11:1 	- 11:,
	UW_NT 					12:1 	- 12:,
  FILLER_1_17      1:1 	- 17:,
	CUR_CF 					18:1 	- 18:,	
	AMT_M 					19:1 	- 19:EN 18/3,
  FILLER_20_33    20:1 	- 33:,
	RETCUR_CF 			34:1 	- 34:,		
	RETAMT_M 				35:1 	- 35:EN 18/3,
  FILLER_36_113   36:1 	- 113:,			
	GT_ANNUL 				114:1 - 114:,	
  FILLER_115_120  115:1 - 120:,		
	ACMTRS_NT_F2		121:1 - 121:,	
  FILLER_122_122  122:1 - 122:,		
	INI_STATUS			123:1 - 123:,
	FIRST_CLODAT_D	124:1 - 124:,
  FILLER_125_127  125:1 - 127:,	
	FILLER					1:1	- 127:,
	CSM_ENDING_M 		128:1 - 128:EN 18/3,
	LC_ENDING_M 		129:1 - 129:EN 18/3		
/KEYS   
  CTR_NF, 
  END_NT, 
  SEC_NF, 
  UWY_NF, 
  UW_NT, 	         
  ACMTRS_NT_F2,
  TRNCOD1_CF,
  INI_STATUS,
  GT_ANNUL 	
/CONDITION LC_CSM_ENDING_NOT_EXIST   (  (TRNCOD1_CF = "1") AND  (INI_STATUS != "1" ) )
/DERIVEDFIELD AMT_MC 0
/OUTFILE ${SORT_O}
/INCLUDE LC_CSM_ENDING_NOT_EXIST
/REFORMAT
	FILLER_1_17, CUR_CF, AMT_MC, FILLER_20_33, RETCUR_CF, AMT_MC, FILLER_36_113, GT_ANNUL, FILLER_115_120, ACMTRS_NT_F2, FILLER_122_122, INI_STATUS, FIRST_CLODAT_D, FILLER_125_127
exit
EOF
SORT

## Fin Modif

NSTEP=${NJOB}_140
LIBEL="GENERATE RETRO NP ESF_FTECLEDA_8700 ESFD3870_CUR FROM IRDPERICASE0  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_18_${IB}_SORT_FTECLEDA_3870_8700_MERGE.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_MERGE_RNP.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	GT_RETCTR_NF 			24:1 	- 24:,
	GT_RETEND_NT			25:1 	- 25:,
	GT_RETSEC_NF 			26:1 	- 26:,
	GT_RETRTY_NF 			27:1 	- 27:,
	GT_RETUW_NT 			28:1 	- 28:,
	CTR_NF   				3:1 	- 3:,
	END_NT   				4:1 	- 4:,
	SEC_NF  				5:1 	- 5:,
	UWY_NF   				6:1 	- 6:,
	UW_NT    				7:1 	- 7:,
	NATRET_CF    		49:1 	- 49:,	
	FILLER					1:1		- 118:	
/JOINKEYS
	GT_RETCTR_NF,    
	GT_RETEND_NT,    
	GT_RETSEC_NF,    
	GT_RETRTY_NF,    
	GT_RETUW_NT		
/INFILE ${DFILT}/${NJOB}_17_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER
exit
EOF
SORT

NSTEP=${NJOB}_145
LIBEL="GENERATE RETRO NP ESF_FTECLEDA_3870_PREV FROM IRDPERICASE0  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${ESF_FTECLEDA_3870_PREV} 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_FTECLEDA_3870_PREV_RNP.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	GT_RETCTR_NF 			24:1 	- 24:,
	GT_RETEND_NT			25:1 	- 25:,
	GT_RETSEC_NF 			26:1 	- 26:,
	GT_RETRTY_NF 			27:1 	- 27:,
	GT_RETUW_NT 			28:1 	- 28:,
	CTR_NF   				3:1 	- 3:,
	END_NT   				4:1 	- 4:,
	SEC_NF  				5:1 	- 5:,
	UWY_NF   				6:1 	- 6:,
	UW_NT    				7:1 	- 7:,
	NATRET_CF    		49:1 	- 49:,	
	FILLER					1:1		- 118:	
/JOINKEYS
	GT_RETCTR_NF,    
	GT_RETEND_NT,    
	GT_RETSEC_NF,    
	GT_RETRTY_NF,    
	GT_RETUW_NT		
/INFILE ${DFILT}/${NJOB}_17_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER
exit
EOF
SORT


## [004]  Deb Modif Apply Rule INITSTS != 1 for FTECLEDA_3870_8700_MERGE_RNP

NSTEP=${NJOB}_147
LIBEL="JOIN FTECLEDA_3870_8700_MERGE_RNP RETRO_NP FILE && ESF_TRERETFACCTR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_SORT_FTECLEDA_3870_8700_MERGE_RNP.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_MERGE_RNP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETCTR_NF 			24:1 	- 24:,
	RETEND_NT 			25:1 	- 25:,
	RETSEC_NF 			26:1 	- 26:,
	RTY_NF 					27:1 	- 27:,
	RETUW_NT 				28:1 	- 28:,
	CTR_NF          1:1 	- 1:,
	END_NT          2:1 	- 2:,
	SEC_NF          3:1 	- 3:,
	UWY_NF          4:1 	- 4:,
	UW_NT           5:1 	- 5:,
	INI_STATUS			12:1 	- 12:,
	FIRST_CLODAT_D	15:1 	- 15:,
	FILLER					1:1		- 122:	
/JOINKEYS
	RETCTR_NF,    
	RETEND_NT,    
	RETSEC_NF,    
	RTY_NF
/INFILE ${DFILT}/${NJOB}_08_${IB}_TRERETFACCTR.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:INI_STATUS,FIRST_CLODAT_D
exit
EOF
SORT

NSTEP=${NJOB}_148
LIBEL=" Apply Rule INITSTS != 1 for FTECLEDA_3870_8700_MERGE_RNP ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_147_${IB}_SORT_FTECLEDA_3870_8700_MERGE_RNP.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_MERGE_RNP.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	TRNCOD_CF 			6:1 	- 6:,
	TRNCOD1_CF 			6:1 	- 6:1,	
	RETCTR_NF 			24:1 	- 24:,
	RETEND_NT 			25:1 	- 25:,
	RETSEC_NF 			26:1 	- 26:,
	RTY_NF 					27:1 	- 27:,
	RETUW_NT 				28:1 	- 28:,
	RETCUR_CF 			34:1 	- 34:,		
	RETAMT_M 				35:1 	- 35:EN 18/3,	
	GT_ANNUL 				114:1 - 114:,		
	ACMTRS_NT_F2		121:1 - 121:,	
	INI_STATUS			123:1 - 123:,
	FIRST_CLODAT_D	124:1 - 124:,
	FILLER					1:1	- 127:
/KEYS   
  RETCTR_NF,
  RETSEC_NF,
  RTY_NF,
  RETUW_NT,
  RETCUR_CF,        
  ACMTRS_NT_F2,
  TRNCOD1_CF,
  GT_ANNUL 	
/SUMMARIZE  TOTAL RETAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETEND_NT_NEW  0
/CONDITION CSM_ENDING  ( (TRNCOD1_CF = "2") AND  (INI_STATUS != "1" )  )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE CSM_ENDING
/REFORMAT
  RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETAMT_MC
exit
EOF
SORT

##SORT_I="${DFILT}/${NJOB}_140_${IB}_SORT_FTECLEDA_3870_8700_MERGE_RNP.dat 2000 1" 


NSTEP=${NJOB}_150
LIBEL="GENERATE RETRO NP ESF_FTECLEDA_8700 MINUS ESF_FTECLEDA_3870_PREV  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_148_${IB}_SORT_FTECLEDA_3870_8700_MERGE_RNP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_RNP.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	GT_RETCTR_NF 				1:1 	- 1:,
	GT_RETEND_NT				2:1 	- 2:,
	GT_RETSEC_NF 				3:1 	- 3:,
	GT_RETRTY_NF 				4:1 	- 4:,
	GT_RETUW_NT 				5:1 	- 5:,
	GT_RETCTR_NF_F2 		24:1 	- 24:,
	GT_RETEND_NT_F2			25:1 	- 25:,
	GT_RETSEC_NF_F2 		26:1 	- 26:,
	GT_RETRTY_NF_F2 		27:1 	- 27:,
	GT_RETUW_NT_F2 			28:1 	- 28:,	
	FILLER							1:1		- 118:	
/JOINKEYS
	GT_RETCTR_NF,    
	GT_RETEND_NT,    
	GT_RETSEC_NF,    
	GT_RETRTY_NF,    
	GT_RETUW_NT		
/INFILE ${DFILT}/${NJOB}_145_${IB}_SORT_ESF_FTECLEDA_3870_PREV_RNP.dat 2000 1 "~" 
/JOINKEYS
	GT_RETCTR_NF_F2,     
	GT_RETEND_NT_F2,     
	GT_RETSEC_NF_F2,     
	GT_RETRTY_NF_F2,     
	GT_RETUW_NT_F2 	
/JOIN UNPAIRED LEFTSIDE ONLY	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER
exit
EOF
SORT

## Fin Modif 



NSTEP=${NJOB}_155
#-----------------------------------------------------------------------------
LIBEL="get CSUOE - not in ESF_FTECLEDA_CURRENT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_135_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_ASS.dat 2000 1" 
SORT_I="${DFILT}/${NJOB}_138_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_ASS.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_ASS.dat 2000 1"   
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       1:1 -  1:, 
		END_NT       2:1 -  2:, 
		SEC_NF       3:1 -  3:, 
		UWY_NF       4:1 -  4:, 
		UW_NT        5:1 -  5:, 
		STD_CTR_NF   1:1 -  1:, 
		STD_END_NT   2:1 -  2:, 
		STD_SEC_NF   3:1 -  3:, 
		STD_UWY_NF   4:1 -  4:, 
		STD_UW_NT    5:1 -  5:,
		ALL_COLS     1:1 -  12: 
/joinkeys
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${DFILT}/${NJOB}_120_${IB}_SORT_FTECLEDA_3870_ALL_CSM_LC_ENDING_ASS.dat 2000 1 "~"
/joinkeys
        STD_CTR_NF,
        STD_SEC_NF,
        STD_UWY_NF,
        STD_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT




NSTEP=${NJOB}_160
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT ESF_FTECLEDA_CURRENT_WITHOUT _CSM AND  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_155_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_ASS.dat 2000 1" 
SORT_I2="${DFILT}/${NJOB}_120_${IB}_SORT_FTECLEDA_3870_ALL_CSM_LC_ENDING_ASS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_ASS_ALL_NEW.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	
		CTR_NF       1:1 -  1:, 
		END_NT       2:1 -  2:, 
		SEC_NF       3:1 -  3:, 
		UWY_NF       4:1 -  4:, 
		UW_NT        5:1 -  5:
/KEYS CTR_NF, 
      SEC_NF,
      UWY_NF,
      UW_NT
/SUM      
/OUTFILE ${SORT_O} 
exit
EOF
SORT

## Generate LC CSM ENDING Q-1 MERGE WITH CURRENT FILE

EXECKSH "cp ${DFILT}/${NJOB}_160_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_ASS_ALL_NEW.dat ${ESF_FCSM_LC_ENDING_ASS}"




NSTEP=${NJOB}_190
# Generate ABS Of AMOUNT CSM ENDING RETRO N
#-----------------------------------------------------------------------------
LIBEL="Generate ABS Of AMOUNT CSM ENDING RETRO NP "
AWK_I="${DFILT}/${NJOB}_75_${IB}_SORT_FTECLEDA_3870_ALL_CSM_ENDING_RETRO_NP.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_FTECLEDA_3870_ALL_CSM_ENDING_RETRO_NP_ABS.dat"
AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{

		if (\$6  < 0) \$6 = sprintf("%-.3lf",-\$6);
		print \$0;
	}
exit
EOF
AWK


NSTEP=${NJOB}_200
LIBEL=" Generate ABS Of AMOUNT CSM ENDING RETRO NP  ) ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_AWK_FTECLEDA_3870_ALL_CSM_ENDING_RETRO_NP_ABS.dat  2000 1"  
SORT_I2="${DFILT}/${NJOB}_65_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_NOT_EXIST.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_ALL_CSM_ENDING_RETRO_NP.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF 					1:1 	- 1:,
	END_NT 		 			2:1 	- 2:,	
	SEC_NF 					3:1 	- 3:,
	UWY_NF 					4:1 	- 4:,
	UW_NT 					5:1 	- 5:,
	LC_CSM_ENDING 	6:1 	- 6:EN 18/3
/KEYS   
  CTR_NF, SEC_NF, UWY_NF, UW_NT
/SUMMARIZE  TOTAL LC_CSM_ENDING  
/DERIVEDFIELD LC_CSM_ENDING_MC LC_CSM_ENDING COMPRESS
/DERIVEDFIELD END_NT_NEW  "0~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	CTR_NF, END_NT_NEW, SEC_NF, UWY_NF, UW_NT, LC_CSM_ENDING_MC
exit
EOF
SORT


### GENERATE UNIQUE CSUE 


NSTEP=${NJOB}_220
LIBEL="  GENERATES CSM ENDING Q-1 LC ENDING Q-1 RETRO NP  UNIQUE CSUE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_SORT_FTECLEDA_3870_ALL_CSM_ENDING_RETRO_NP.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_ALL.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	RETCTR_NF 					1:1 	- 1:,
	RETEND_NT 		 			2:1 	- 2:,	
	RETSEC_NF 					3:1 	- 3:,
	RTY_NF 					    4:1 	- 4:,
	RETUW_NT 					  5:1 	- 5:,
	LC_CSM_ENDING 	6:1 	- 6:EN 18/3	
/KEYS   
  RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT
/CONDITION CSM_PLUS_ABS  ( LC_CSM_ENDING < 1 )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE CSM_PLUS_ABS
exit
EOF
SORT

## GENERATE ONLY RETRO NP CSM ENDING Q-1

EXECKSH "cp ${DFILT}/${NJOB}_220_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_ALL.dat ${ESF_FCSM_ENDING_RNP_ONLY}"


NSTEP=${NJOB}_230
#-----------------------------------------------------------------------------
LIBEL="get CSUOE - not in ESF_FTECLEDA_CURRENT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_150_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_RNP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_RNP.dat 2000 1"   
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       1:1 -  1:, 
		END_NT       2:1 -  2:, 
		SEC_NF       3:1 -  3:, 
		UWY_NF       4:1 -  4:, 
		UW_NT        5:1 -  5:, 
		STD_CTR_NF   1:1 -  1:, 
		STD_END_NT   2:1 -  2:, 
		STD_SEC_NF   3:1 -  3:, 
		STD_UWY_NF   4:1 -  4:, 
		STD_UW_NT    5:1 -  5:,
		ALL_COLS     1:1 -  12: 
/joinkeys
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${DFILT}/${NJOB}_220_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_ALL.dat 2000 1 "~"
/joinkeys
        STD_CTR_NF,
        STD_SEC_NF,
        STD_UWY_NF,
        STD_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT




NSTEP=${NJOB}_240
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT ESF_FTECLEDA_CURRENT_WITHOUT _CSM AND  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_220_${IB}_SORT_FTECLEDA_3870_CSM_LC_ENDING_RETRO_NP_ALL.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_230_${IB}_SORT_FTECLEDA_3870_8700_DELTA_MERGE_RNP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_3870_8700_CSM_LC_ENDING_RETRO_NP_ALL_NEW.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	
		CTR_NF       1:1 -  1:, 
		END_NT       2:1 -  2:, 
		SEC_NF       3:1 -  3:, 
		UWY_NF       4:1 -  4:, 
		UW_NT        5:1 -  5:
/KEYS CTR_NF, 
      SEC_NF,
      UWY_NF,
      UW_NT
/SUM      
/OUTFILE ${SORT_O} 
exit
EOF
SORT

## GENERATE RETRO CSM ENDING MERGE WITH CURRENT ESFD3870

EXECKSH "cp ${DFILT}/${NJOB}_240_${IB}_SORT_FTECLEDA_3870_8700_CSM_LC_ENDING_RETRO_NP_ALL_NEW.dat ${ESF_FCSM_ENDING_RNP}"


JOBEND