#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Transformation REQ 20.1
# nom du script SHELL           : ESFD4034.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 26/10/2022
# auteur                        : S.Behague
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 107049  :  - conversion transcode from others GAAP
#                     - Copy ESFD4033.cmd (P&C) and adpated for Life
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 04/01/2021 : SPIRA 107049: SBE : Copy from ESFD0433.cmd
#[002] 26/10/2022 : SPIRA 107049: SBE : IFRS17 LIFE - IFRS4 Reversal 
#[003] 21/12/2022 : SPIRA 107049: SBE : IFRS17 LIFE - IFRS4 Reversal - Sélection traité
#[004] 25/01/2023 : SPIRA 108436: SBE : IFRS17 LIFE - IFRS4 Reversal - Manage reversals
#[005] 15/03/2023 : SPIRA 109834: SBE : [TECH] IFRS17 LIFE - IFRS4 Reversal - Manage Life scope
#[006] 13/04/2023 : SPIRA 109501: SBE : IFRS 4 Reversal - Duplicate issue on POS booking
#[007] 18/04/2023 : SPIRA 109533: SBE : IFRS17 LIFE - IFRS4 Reversal - Life Retro missing
#[008] 02/05/2023 : SPIRA 109647: SBE : IFRS17 LIFE - IFRS4 Reversal - Issue when no mapping
#[009] 11/10/2023 : SPIRA 110675: MZM   20.1 - I17 - REQ 20.1 - remove content of NEWCOLS5_NF on reclass transactions
#[010] 13/06/2024 : SPIRA 111175: SBE : L&H- change IBNP cancellation granularity
#[011] 27/08/2024 : SPIRA 112108: SBE : L&H- reclass does not match
#[011] 16/09/2024 : SPIRA 112148: SBE : IFRS17 LIFE - IFRS4 Reversal - Life Retro missing
#[012] 03/12/2024 : SPIRA 111435 OMEGA Life IFRS17 IO mirroring management
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
ECHO_LOG "#===> PARM_ICLODAT_D.............: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}"
ECHO_LOG "#===> PARM_CRE_D.................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM_BLCSHTYEA_NF..........: ${PARM_BLCSHTYEA_NF}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"


EST_IFRS4=${1}
EST_EBS=${2}
EST_IFRS17=${3}
EST_GAAPMAP=${4}
EST_OUT=${5}
EST_DELTA=${6}

EST_BASE=`basename "${5%.*}"`

ORICOD=""

if [[ "${NORME_CF}" = I4I* ]]
then
	ORICOD="CURGTA"
	EST_ORG=${EST_IFRS4}
fi

if [[ "${NORME_CF}" = EBS* ]]
then 
	ORICOD="EBSGTA"
	EST_ORG=${EST_EBS}
fi

if [[ "${NORME_CF}" = I17* ]]
then
	ORICOD="I17GGTA"
	EST_ORG=${EST_IFRS17}
fi


ICLODAT_A=`echo ${PARM_ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${PARM_ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${PARM_ICLODAT_D} | awk '{print substr($0,7,8)}'`

ICLODAT_M0=$(($ICLODAT_M - 2))

ECHO_LOG "#===> ICLODAT_M0 ....................: ${ICLODAT_M0}"
ECHO_LOG "#===> ICLODAT_M .....................: ${ICLODAT_M}"
ECHO_LOG "#===> ORICOD ....................: ${ORICOD}"

 

ECHO_LOG "#===> ............INPUT ................................................."

ECHO_LOG "#===> EST_GAAPMAP .............................: ${EST_GAAPMAP}"
ECHO_LOG "#===> EST_ORG .................................: ${EST_ORG}"
ECHO_LOG "#===> EST_IFRS4 ...............................: ${EST_IFRS4}"
ECHO_LOG "#===> EST_EBS .................................: ${EST_EBS}"
ECHO_LOG "#===> EST_IFRS17...............................: ${EST_IFRS17}" 
ECHO_LOG "#===> ESF_IADVPERICASE.........................: ${ESF_IADVPERICASE}" 
ECHO_LOG "#===> ESF_DLRGTAA..............................: ${ESF_DLRGTAA}"  
ECHO_LOG "#===> ESF_FTRSLNK_TXT..........................: ${ESF_FTRSLNK_TXT}"  
ECHO_LOG "#===> ESF_FBOPRSLNK_TXT........................: ${ESF_FBOPRSLNK_TXT}" 
ECHO_LOG "#===> ESF_CSM_PROF.............................: ${ESF_CSM_PROF}" 
ECHO_LOG "#===> ESF_CSM_LC_AMORT_PATTERN.................: ${ESF_CSM_LC_AMORT_PATTERN}" 
ECHO_LOG "#===> ESF_CSM_LC_AMORT_PATTERN_PREV............: ${ESF_CSM_LC_AMORT_PATTERN_PREV}" 

ECHO_LOG "#===> ............OUTPUT ................................................."

ECHO_LOG "#===> EST_OUT .................................: ${EST_OUT}"
ECHO_LOG "#===> EST_DELTA .................................: ${EST_DELTA}"



if [ ! -s "${EST_GAAPMAP}" ] 
then

        NSTEP=${NJOB}_10
        LIBEL="cp ${EST_ORG} ${EST_OUT}"
	if [ ${EST_ORG} != ${EST_OUT} ]
        then
        	EXECKSH "cp ${EST_ORG} ${EST_OUT}"
	fi
	cp ${ESF_FTECLEDA_I17AELIFE} ${ESF_FTECLEDA_I17AELIFE_OUT}
	ECHO_LOG "#===> EST_GAAPMAP is empty. End of processing"
	JOBEND

fi

NSTEP=${NJOB}_08
# Filter ESF_FTRSLNK_TXT on PRS_CF = "740"
#-----------------------------------------------------------------------------
LIBEL="Filter ESF_FTRSLNK_TXT on PRS_CF = "740" "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_740.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  PRS_CF       1:1 -  1:,
         ACMTRS_NT    2:1 -  2:
/CONDITION IS_PRS_740 ( PRS_CF = "740")
/OUTFILE $SORT_O
/INCLUDE IS_PRS_740
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="split mapping in three norms"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GAAPMAP} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_GAAPMAP_IFRS4.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_GAAPMAP_EBS.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_GAAPMAP_IFRS17.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        ORIGAPACMTRS_NT 1:1 - 1:,
        ORIACMTRS_NT    2:1 - 2:,
        ORIDETTRS_CF    3:1 - 3:,
        TARGAPACMTRS_NT 4:1 - 4:,
        TARGACMTRS_NT   5:1 - 5:,
        TARGDETTRS1_CF  6:1 - 6:1,
        TARGDETTRS_CF   6:1 - 6:
/KEYS   ORIGAPACMTRS_NT,
        ORIACMTRS_NT,
        ORIDETTRS_CF,
        TARGAPACMTRS_NT,
        TARGACMTRS_NT,
        TARGDETTRS_CF
/CONDITION POST_IFRS4 ( ORIGAPACMTRS_NT = "200" or ORIGAPACMTRS_NT = "100")
/CONDITION POST_EBS ( ORIGAPACMTRS_NT = "400" or ORIGAPACMTRS_NT = "401" or ORIGAPACMTRS_NT = "402")
/CONDITION POST_I17 ( ORIGAPACMTRS_NT = "300" or ORIGAPACMTRS_NT = "301" or ORIGAPACMTRS_NT = "302")
/OUTFILE ${SORT_O}
/INCLUDE POST_IFRS4
/OUTFILE ${SORT_O2}
/INCLUDE POST_EBS
/OUTFILE ${SORT_O3}
/INCLUDE POST_I17
exit
EOF
SORT


NSTEP=${NJOB}_15
#------------------------------------------------------------------------------------
LIBEL="Include Life ${EST_IFRS4}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IFRS4} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_LIFE.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_RETRO_LIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF            8:1 -   8:,
        RETCTR_NF        24:1 -  24:,
        BALSHEY_NF        3:1 -   3:EN,
        BALSHRMTH_NF      4:1 -   4:EN,
        DETTRS_CF        6:1 - 6:,
        LOBACC_CF       45:1 - 45:,
        LOBRET_CF       46:1 - 46:

/KEYS   DETTRS_CF
/CONDITION VIE ( LOBACC_CF="30" OR LOBACC_CF="31" OR LOBRET_CF="30" OR LOBRET_CF="31" ) and (BALSHRMTH_NF >= ${ICLODAT_M0}) AND ( BALSHRMTH_NF <= ${ICLODAT_M} ) AND (BALSHEY_NF = ${ICLODAT_A} ) AND CTR_NF != "" AND RETCTR_NF = ""
/CONDITION VIERETRO ( LOBACC_CF="30" OR LOBACC_CF="31" OR LOBRET_CF="30" OR LOBRET_CF="31" ) and (BALSHRMTH_NF >= ${ICLODAT_M0}) AND ( BALSHRMTH_NF <= ${ICLODAT_M} ) AND (BALSHEY_NF = ${ICLODAT_A} ) AND RETCTR_NF != ""
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE VIE
/OUTFILE ${SORT_O2} OVERWRITE
/INCLUDE VIERETRO
exit
EOF
SORT

NSTEP=${NJOB}_18
#---------------------------------------------------------------
LIBEL="Extraction of TSECTIONDYNVAL"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_LIST_TSECTIONDYNVAL.dat
BCP_QRY="exec BEST..PsTDYNFIELD_01 "
BCP

NSTEP=${NJOB}_18A
#---------------------------------------------------------------
LIBEL="Extraction of TSECTIONDYNVAL"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_LIST_TSECTIONDYNVAL.dat
BCP_QRY="exec BEST..PsTDYNFIELD_02"
BCP

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="Include Life with Garanty to be treated"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_PERICASE_LIFE_GAR_CF.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        GAR_CF        32:1 -   32:,
        CTR_NF            3:1 -   3:,
		    SEC_NF            5:1 -   5:,
		    UWY_NF            6:1 -   6:,
		    LOBACC_CF			38:1 -   38:
/KEYS CTR_NF,SEC_NF,UWY_NF
/SUM
/STABLE
/CONDITION GARANTY ( LOBACC_CF="30" OR LOBACC_CF="31" )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE GARANTY
/REFORMAT CTR_NF, SEC_NF, UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_20A
#------------------------------------------------------------------------------------
LIBEL="Include Life with Garanty to be treated"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IRDVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_PERICASE_LIFE_GAR_CF.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        GAR_CF        32:1 -   32:,
        CTR_NF            3:1 -   3:,
		    SEC_NF            5:1 -   5:,
		    UWY_NF            6:1 -   6:,
		    LOBACC_CF			38:1 -   38:
/KEYS CTR_NF,SEC_NF, UWY_NF
/SUM
/STABLE
/CONDITION GARANTY ( LOBACC_CF="30" OR LOBACC_CF="31" )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE GARANTY
/REFORMAT CTR_NF, SEC_NF, UWY_NF
exit
EOF
SORT


NSTEP=${NJOB}_22
#------------------------------------------------------------------------------------
LIBEL="Include Life Treaty "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_${EST_BASE}_PERICASE_LIFE_GAR_CF.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_PERICASE_LIFE_GAR_CF.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
		CTR_NF            1:1 -   1:,
		SEC_NF            2:1 -   2:,
		UWY_NF            3:1 -   3:,
		CTR2_NF           1:1 -   1:,
		SEC2_NF           5:1 -   5:,
		UWY2_NF           2:1 -   2:
/JOINKEYS
        CTR_NF, SEC_NF, UWY_NF
/INFILE ${DFILT}/${NJOB}_18_${IB}_LIST_TSECTIONDYNVAL.dat 2000 1 "~"
/JOINKEYS
        CTR2_NF, SEC2_NF, UWY2_NF
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:CTR_NF, LEFTSIDE:SEC_NF, LEFTSIDE:UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_22A
#------------------------------------------------------------------------------------
LIBEL="Include Life Treaty "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20A_${IB}_${EST_BASE}_PERICASE_LIFE_GAR_CF.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_PERICASE_LIFE_GAR_CF.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
		CTR_NF            1:1 -   1:,
		SEC_NF            2:1 -   2:,
		UWY_NF            3:1 -   3:,
		CTR2_NF           1:1 -   1:,
		SEC2_NF           3:1 -   3:,
		UWY2_NF           2:1 -   2:
/JOINKEYS
        CTR_NF, SEC_NF, UWY_NF
/INFILE ${DFILT}/${NJOB}_18A_${IB}_LIST_TSECTIONDYNVAL.dat 2000 1 "~"
/JOINKEYS
        CTR2_NF, SEC2_NF, UWY2_NF
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:CTR_NF, LEFTSIDE:SEC_NF, LEFTSIDE:UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------------
LIBEL="Include Life Treaty "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_${EST_BASE}_IFRS4_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_LIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
		CTR_NF            8:1 -   8:,
		SEC_NF           10:1 -  10:,
		UWY_NF           11:1 -   11:,
		CTR2_NF            1:1 -   1:,
		SEC2_NF            2:1 -   2:,
		UWY2_NF           3:1 -   3:,
		FIELD_1_118_F1    1:1 - 118:
/JOINKEYS
        CTR_NF, SEC_NF, UWY_NF
/INFILE ${DFILT}/${NJOB}_22_${IB}_${EST_BASE}_PERICASE_LIFE_GAR_CF.dat 2000 1 "~"
/JOINKEYS
        CTR2_NF, SEC2_NF, UWY2_NF
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:FIELD_1_118_F1
exit
EOF
SORT

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------------
LIBEL="Include Life Treaty "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_${EST_BASE}_IFRS4_RETRO_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_RETRO_LIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
		RETCTR_NF            24:1 -   24:,
		RETSEC_NF           26:1 -  26:,
		RETUWY_NF           27:1 -  27:,
		CTR2_NF            1:1 -   1:,
		SEC2_NF            2:1 -   2:,
		UWY2_NF            3:1 -   3:,
		FIELD_1_118_F1    1:1 - 118:
/JOINKEYS
        RETCTR_NF, RETSEC_NF, RETUWY_NF
/INFILE ${DFILT}/${NJOB}_22A_${IB}_${EST_BASE}_PERICASE_LIFE_GAR_CF.dat 2000 1 "~"
/JOINKEYS
        CTR2_NF, SEC2_NF, UWY2_NF
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:FIELD_1_118_F1
exit
EOF
SORT


NSTEP=${NJOB}_80
#------------------------------------------------------------------------------------
LIBEL="Apply transformation to ${EST_IFRS4}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_${EST_BASE}_IFRS4_LIFE.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_30_${IB}_${EST_BASE}_IFRS4_RETRO_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_LIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        S_DETTRS_CF        6:1 - 6:,
        S_HEAD             1:1 - 2:,
	ORIDETTRS_CF       3:1 - 3:,
	TARGDETTRS_CF      6:1 - 6:,
	MAPTYP_CT	   7:1 - 7: EN,
	S_MID1            8:1 - 40:,
	S_MID2            45:1 - 88:,
        TRN_NT            103:1 - 103:,
	S_TAIL1            105:1 - 110:,
        S_TAIL2             113:1 - 118:
/DERIVEDFIELD GAAPCOD_NEW 2"~"
/DERIVEDFIELD COLS14_NEW 14"~"
/DERIVEDFIELD SEPARATEUR   "~"
/DERIVEDFIELD ORICOD_NEW   "RECLASSL~"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD CRE_NEW "${PARM_CRE_D}~CloP~${PARM_CRE_D}~CloP~"

/JOINKEYS
        S_DETTRS_CF
/INFILE ${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_GAAPMAP_IFRS4.dat 2000 1 "~"
/JOINKEYS
        ORIDETTRS_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW, rightside : TARGDETTRS_CF, SEPARATEUR,leftside : S_MID1, CRE_NEW , leftside : S_MID2, COLS14_NEW, leftside : TRN_NT, ORICOD_NEW , leftside : S_TAIL1,GAAPCOD_NEW, leftside : S_TAIL2, rightside : MAPTYP_CT
exit
EOF
SORT

NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="Transforme using Sign"
AWK_I=${DFILT}/${NJOB}_80_${IB}_${EST_BASE}_IFRS4_LIFE.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_LIFE_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

    if (\$119 == "-1" && \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
    if (\$119 == "-1" && \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
	if (\$119 == "-1" && \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);
    
	print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_100
#------------------------------------------------------------------------------------
LIBEL="merg files to ouput ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_${EST_BASE}_IFRS4_LIFE_AWK.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_LIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 - 1:,
        ESB_CF            2:1 - 2:,
        DETTRS_CF         6:1 - 6:,
        ALL               1:1 - 118:
/KEYS   SSD_CF,
        ESB_CF,
        DETTRS_CF
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT ALL
exit
EOF
SORT


## Recuperer les Annulations (et Ouvertures) et filtre sur 740 ==> Les Exclure

NSTEP=${NJOB}_104
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing GTAR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_${EST_BASE}_IFRS4_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_SANS_REJ_OPNG.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
							SSD_CF          		  1:1 -   1:,      
							ESB_CF          		  2:1 -   2:,      
							BALSHEY_NF      		  3:1 -   3:,      
							BALSHRMTH_NF    		  4:1 -   4:,      
							TRNCOD_CF       		  6:1 -   6:,        
							DBLTRNCOD_CF    		  7:1 -   7:,        
							CTR_NF          		  8:1 -   8:,        
							END_NT          		  9:1 -   9:,        
							SEC_NF          		 10:1 -  10:,        
							UWY_NF          		 11:1 -  11:,        
							UW_NT           		 12:1 -  12:,        
							OCCYEA_NF       		 13:1 -  13:,      
							ACY_NF          		 14:1 -  14:,      
							SCOSTRMTH_NF    		 15:1 -  15:,      
							SCOENDMTH_NF    		 16:1 -  16:,      
							CUR_CF          		 18:1 -  18:,        
							CED_NF          		 20:1 -  20:,        
							RETCTR_NF       		 24:1 -  24:,        
							RETEND_NT       		 25:1 -  25:,        
							RETSEC_NF       		 26:1 -  26:,        
							RTY_NF          		 27:1 -  27:,        
							RETUW_NT        		 28:1 -  28:,        
							RETOCCYEA_NF    		 29:1 -  29:,      
							RETACY_NF       		 30:1 -  30:,      
							RETSCOSTRMTH_NF 		 31:1 -  31:,      
							RETSCOENDMTH_NF 		 32:1 -  32:,      
							RETCUR_CF       		 34:1 -  34:,        
							PLC_NT          		 36:1 -  36:,        
							RTO_NF          		 37:1 -  37:,        
							ZZRECONKEY_CF   		102:1 - 102:,        
							TRN_NT          		103:1 - 103:,        
							ORICOD_LS       		104:1 - 104:,        
							RETROAUTO_B     		105:1 - 105:,        
							SPEENTNAT_CT    		106:1 - 106:,        
							EVT_NF          		107:1 - 107:,        
							REVT_NF         		108:1 - 108:,        
							RETARDRETINT_B  		109:1 - 109:,
              GT_ANNUL_OPNG   		114:1 - 114:           
                           
/KEYS  	 CTR_NF          	
				,END_NT          	
				,SEC_NF          	
				,UWY_NF          	
				,UW_NT           	
				,OCCYEA_NF       	
				,ACY_NF          	
				,SCOSTRMTH_NF    	
				,SCOENDMTH_NF    	
				,CUR_CF          	
				,CED_NF          	
				,RETCTR_NF       	
				,RETEND_NT       	
				,RETSEC_NF       	
				,RTY_NF          	
				,RETUW_NT        	
				,RETOCCYEA_NF    	
				,RETACY_NF       	
				,RETSCOSTRMTH_NF 	
				,RETSCOENDMTH_NF 	
				,RETCUR_CF       	
				,PLC_NT          	
				,TRNCOD_CF                
/CONDITION ANNU_OPNG  (GT_ANNUL_OPNG = "A" or GT_ANNUL_OPNG = "O")
/OUTFILE ${SORT_O} overwrite
/OMIT ANNU_OPNG
/OUTFILE ${SORT_O2} overwrite
/INCLUDE ANNU_OPNG
exit
EOF
SORT

NSTEP=${NJOB}_105
# Join AND Extend ${DFILT}/${NJOB}_104_${IB}_${EST_BASE}_ALL.dat  with PRS_740 of _FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join ${DFILT}/${NJOB}_104_${IB}_${EST_BASE}_ALL.dat with PRS_ 740 and _FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_104_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG_740.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS                                         
							SSD_CF          		  1:1 -   1:, 
							ESB_CF          		  2:1 -   2:, 
							BALSHEY_NF      		  3:1 -   3:, 
							BALSHRMTH_NF    		  4:1 -   4:, 
							TRNCOD_CF       		  6:1 -   6:, 
							DBLTRNCOD_CF    		  7:1 -   7:, 
							CTR_NF          		  8:1 -   8:, 
							END_NT          		  9:1 -   9:, 
							SEC_NF          		 10:1 -  10:, 
							UWY_NF          		 11:1 -  11:, 
							UW_NT           		 12:1 -  12:, 
							OCCYEA_NF       		 13:1 -  13:, 
							ACY_NF          		 14:1 -  14:, 
							SCOSTRMTH_NF    		 15:1 -  15:, 
							SCOENDMTH_NF    		 16:1 -  16:, 
							CUR_CF          		 18:1 -  18:, 
							CED_NF          		 20:1 -  20:, 
							RETCTR_NF       		 24:1 -  24:, 
							RETEND_NT       		 25:1 -  25:, 
							RETSEC_NF       		 26:1 -  26:, 
							RTY_NF          		 27:1 -  27:, 
							RETUW_NT        		 28:1 -  28:, 
							RETOCCYEA_NF    		 29:1 -  29:, 
							RETACY_NF       		 30:1 -  30:, 
							RETSCOSTRMTH_NF 		 31:1 -  31:, 
							RETSCOENDMTH_NF 		 32:1 -  32:, 
							RETCUR_CF       		 34:1 -  34:, 
							PLC_NT          		 36:1 -  36:, 
							RTO_NF          		 37:1 -  37:, 
							ZZRECONKEY_CF   		102:1 - 102:, 
							TRN_NT          		103:1 - 103:, 
							ORICOD_LS       		104:1 - 104:, 
							RETROAUTO_B     		105:1 - 105:, 
							SPEENTNAT_CT    		106:1 - 106:, 
							EVT_NF          		107:1 - 107:, 
							REVT_NF         		108:1 - 108:, 
							RETARDRETINT_B  		109:1 - 109:, 
              GT_ANNUL_OPNG   		114:1 - 114:,                                              
        			COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  			PRS_CF_F2         1:1  - 1:,
			  			ACMTRS_NT_F2			2:1  - 2:,
			  			DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_08_${IB}_FTRSLNK_740.dat 2000 1 "~"       
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


## On garde les Annulations du PRS 740 

##[009]

NSTEP=${NJOB}_110
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Exclusion des Annulations du PRS 740 ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_104_${IB}_${EST_BASE}_ALL_SANS_REJ_OPNG.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_105_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG_740.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_AVEC_PRS_740.dat 2000 1"
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
	GT_ANNUL_OPNG   114:1 - 114:,
	FILLER_1_113    1:1 - 113:,
	FILLER_115_124  115:1 -124:	
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
/DERIVEDFIELD GT_ANNUL_OPNG_NEW "~"
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT FILLER_1_113, GT_ANNUL_OPNG_NEW, FILLER_115_124
exit
EOF
SORT

## 

EXECKSH "cp ${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL_AVEC_PRS_740.dat ${EST_DELTA}"

### DEB Merge Fusion PERICASE STD


## Ajout du Merge DU PERICASE ASS et Retro avec le fichier  "${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL.dat  2000 1" Avec PERICASE STANDART ACC / RET




#[013] DEB JOINTURE DES FICHIERS AVEC LES PERICASES

NSTEP=${NJOB}_115

LIBEL="Generate Assume and Retro files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL_AVEC_PRS_740.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_${EST_BASE}_ALL_ASS.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_${EST_BASE}_ALL_RET.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        ACY_NF           14:1 - 14:,
        TRNCOD_CF         6:1 -  6:,
	      TRNCOD1_CF	  		6:1 -  6:1,
	      TRNCOD8_CF	  		6:8 -  6:8,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        ACMTRS_NT        42:1 - 42:,
				ACMTRSL3_NT      52:1 - 52:,
        AMT_M            19:1 - 19:EN 15/3,
        RETAMT_M         35:1 - 35:EN 15/3,
        RETINTAMT_M      41:1 - 41:EN 15/3

/CONDITION GRP_ASS (TRNCOD1_CF='1') OR (TRNCOD1_CF='3')
/CONDITION GRP_RET (TRNCOD1_CF='2') OR (TRNCOD1_CF='4')

/OUTFILE ${SORT_O}
/INCLUDE GRP_ASS

/OUTFILE ${SORT_O2}
/INCLUDE GRP_RET
exit
EOF
SORT


#[013] JOINTURE DES FICHIERS AVEC LES PERICASES

if [ "${IDF_CT}" != "EBS_GAP_MAP_STD" ] 
then

NSTEP=${NJOB}_116
# Join  PERICASE Assume with SORT_${EST_BASE}_ALL_ASS by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="PERICASE Assumed ${EST_BASE}_ALL_ASS, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_115_${IB}_SORT_${EST_BASE}_ALL_ASS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_${EST_BASE}_ALL_ASS.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF_F1        		8:1 - 8:,  
        END_NT_F1        		9:1 - 9:,
        SEC_NF_F1        		10:1 - 10:,
        UWY_NF_F1        		11:1 - 11:,
        UW_NT_F1         		12:1 - 12:,
        FIELD_1_45_F1    		1:1  - 45:,
        SEG_NF_F1 		      46:1 - 46:,           
        LOB_CF_F1 		      47:1 - 47:,                    
        NAT_CF_F1           48:1 - 48:, 
        TYP_CT_F1           49:1 - 49:,                                             
        FIELD_1_118_F1    	 1:1 - 118:,
        CTR_NF_F2 			 	  3:1 -  3:, 
        END_NT_F2           4:1 -  4:,                  
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:			       		          
/JOINKEYS CTR_NF_F1,
					END_NT_F1,
          SEC_NF_F1,
          UWY_NF_F1,
          UW_NT_F1            
/INFILE ${ESF_IADVPERICASE} 2000 1 "~"                 
/JOINKEYS CTR_NF_F2,
          END_NT_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2                         
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FIELD_1_118_F1
exit
EOF
SORT 


NSTEP=${NJOB}_118
# Join  PERICASE Assume with SORT_${EST_BASE}_ALL_RET by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="PERICASE Assumed ${EST_BASE}_ALL_RET, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_115_${IB}_SORT_${EST_BASE}_ALL_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_${EST_BASE}_ALL_RET.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF_F1        24:1 - 24:,  
        RETEND_NT_F1        25:1 - 25:EN,
        RETSEC_NF_F1        26:1 - 26:,
        RTY_NF_F1           27:1 - 27:,
        RETUW_NT_F1         28:1 - 28:,
        FILED_1_118_F1       1:1 - 118:,        
        CTR_NF_F2 			 	  3:1 -  3:,                   
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:      		          
/JOINKEYS RETCTR_NF_F1,
          RETSEC_NF_F1,
          RTY_NF_F1,
          RETUW_NT_F1  
/INFILE ${ESF_IRDVPERICASE} 2000 1 "~"          
/JOINKEYS CTR_NF_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2           
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FILED_1_118_F1
exit
EOF
SORT

NSTEP=${NJOB}_119
#------------------------------------------------------------------------------------
LIBEL="Fusion des ASS et RET"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_116_${IB}_SORT_${EST_BASE}_ALL_ASS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_118_${IB}_SORT_${EST_BASE}_ALL_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25:,
        RETSEC_NF   26:1 - 26:,
        RTY_NF      27:1 - 27:,
        RETUW_NT    28:1 - 28:,
        LOBACC_CF   45:1 - 45:,
        LOBRET_CF   46:1 - 46:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION VIE ( LOBRET_CF="30" OR LOBRET_CF="31" OR LOBACC_CF="30" OR LOBACC_CF="31")
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE VIE
exit
EOF
SORT

fi

#[013] FIN JOINTURE DES FICHIERS AVEC LES PERICASES


NSTEP=${NJOB}_120

LIBEL="Sort GLT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_ORG} 2000 1"
if [ "${IDF_CT}" != "EBS_GAP_MAP_STD" ] 
then
SORT_I2="${DFILT}/${NJOB}_119_${IB}_${EST_BASE}_ALL.dat  2000 1" 
else
SORT_I2="${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL.dat  2000 1"
fi 
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL.dat 2000 1"
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
        SEGNAT_CT	48:1 - 48:,
	ACCRET_CF 	49:1 - 49:
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


NSTEP=${NJOB}_130
#------------------------------------------------------------------------------------
LIBEL="Sort GLT OUT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_${EST_BASE}_ALL.dat  2000 1"
SORT_O="${EST_OUT} 2000 1"
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
        ACCRET_CF       49:1 - 49:,
				TRN_NT         103:1 - 103:,
        FILLED1          1:1 - 102:,
        FILLED2        104:1 - 119:
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
/DERIVEDFIELD TRN_NT_VIDE   "~"
/OUTFILE ${SORT_O} overwrite
/REFORMAT FILLED1, TRN_NT_VIDE, FILLED2
exit
EOF
SORT


NSTEP=${NJOB}_135
#-----------------------------------------------------------------------------
LIBEL="Files generation in TTECLEDA table format"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLRGTAA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_DLRGTAA.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        LIGNEGT 1:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER_30_COLS 42:1 - 71:
/KEYS CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT ,
          RETKEY_CF ,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_M,
          FILLER_30_COLS
exit
EOF
SORT




##[012]

### REFORMAT ESF_DLRGTAA : MERGE With IADVPERICASE

## 
##GT_LOBACC_CF	     45:1 - 45:,
##GT_SOBACC_CF	     47:1 - 47:,
##GT_TOPACC_CF	     49:1 - 49:,
##GT_NATACC_CF	     51:1 - 51:,
##GT_GARACC_CF	     53:1 - 53:,

#[004]
NSTEP=${NJOB}_140
# REFORMAT ESF_DLRGTAA : MERGE WITH PERICASE
#------------------------------------------------------------------------------
LIBEL="REFORMAT ESF_DLRGTAA : MERGE WITH PERICASEE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_135_${IB}_SORT_O_DLRGTAA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_DLRGTAA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF					 8:1 - 8:,
        END_NT					 9:1 - 9:,
        SEC_NF					 10:1 - 10:,
        UWY_NF					 11:1 - 11:,
        UW_NT 					12:1 - 12:,
        LIGNEGT 				1:1 - 44:,
        FILLER_118_COLS 	54:1 - 118:,
        PER_CTR_NF 			3:1 - 3:,
        PER_END_NT 			4:1 - 4:,
        PER_SEC_NF 			5:1 - 5:,
        PER_UWY_NF 			6:1 - 6:,
        PER_UW_NT  			7:1 - 7:,
 		    PER_GAR_CF			32:1 - 32:,        
 		    PER_LOB_CF			38:1 - 38:,
 		    PER_NAT_CF			49:1 - 49:, 		    
 		    PER_SOB_CF      81:1 - 81:,
				PER_TOP_CF      84:1 - 84:,
				PER_CTRNAT_CT   85:1 - 85:
/joinkeys
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${ESF_IADVPERICASE} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/DERIVEDFIELD SEPA  "~"
/OUTFILE ${SORT_O}
/REFORMAT leftside:LIGNEGT,
          rightside:PER_LOB_CF,
          SEPA,
          rightside:PER_SOB_CF,
          SEPA,
          rightside:PER_TOP_CF,          
          SEPA,
          rightside:PER_NAT_CF,          
          SEPA,
          rightside:PER_GAR_CF,                             
          leftside:FILLER_118_COLS
exit
EOF
SORT



NSTEP=${NJOB}_150
#------------------------------------------------------------------------------------
LIBEL="Sort GLT OUT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_I17AELIFE} 2000 1"
SORT_I2="${DFILT}/${NJOB}_140_${IB}_SORT_O_DLRGTAA.dat 2000 1"
SORT_I3="${EST_OUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_I17LIFE.dat 2000 1"
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

/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT

cp ${DFILT}/${NSTEP}_${IB}_FTECLEDA_I17LIFE.dat ${ESF_FTECLEDA_I17AELIFE_OUT}

JOBEND
