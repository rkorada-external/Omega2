#!/bin/ksh
#=======================================================================
# nom de l'application          : GAAP Transformation REQ 20.1
# nom du script SHELL           : ESFD4033.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 04/01/2021
# auteur                        : Nhat Linh DOAN
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 83101  :  - conversion transcode from others GAAP
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 04/01/2021 NLD : SPIRA 83101 :  conversion transcode from others GAAP
#[002] 17/03/2021 NLD : SPIRA 83101 :  activate conversion I17 to I17
#[003] 26/03/2021 NLD : SPIRA 83101 :  fix new ICLODAT
#[004] 10/05/2021 NLD : SPIRA 83101 :  integrate EBS
#[005] 17/05/2021 NLD : SPIRA 96351 :  REQ20.1 - Exclude Life contracts
#[006] 29/06/2021 NLD : SPIRA 97350 :  REQ20.1 - Transaction generated several times.
#[007] 06/09/2021 NLD : SPIRA 97350 :  REQ20.1 - Transaction generated several times, update CRE_D et LSTUPD_D 
#[008] 26/01/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  : (for grouping 751=1010 ; 2010) AND ((Prof = 3 and CSM =1) OR  (Prof = 1 and LC =1)) 
#[009] 31/01/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  Ajout des colonnes  SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF dans la cle de jointure
#[010] 14/02/2022  HR : SPIRA 100677 : I17 - Criteria to compute Revenue / EXP / CSM
#[011] 21/02/2022 MZM : SPIRA 102371:  I17 Filtrer les fichiers I17 Par Normes (Ajout jointures avec les fichiers Pericases)  Annulation : Modif effectuee dans ESFD4037
#[012] 05/05/2022 JYP : SPIRA 100172:  internal retro, retinamt should be 0
#[013] 06/05/2022 MZM : SPIRA 85522:   MERGE AVEC PERICASE Au STEP _115
#[014] 11/05/2022 JYP : SPIRA 100172:  REVERT : internal retro retinamt should be 0
#[015] 06/05/2022 MZM : SPIRA 85522:   MERGE AVEC PERICASE Au STEP _115
#[016] 13/05/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  Ajout SCORTH  dans la cle de jointure au step _19A
#[017] 31/05/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  For Retro NP : Inversion des colonnes LC et CSM
#[018] 09/06/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  For Retro NP : Condition sur RETRO NP (Exclure sur les enreg Accept et Retro Prop) ; Exclure Regle Profitabilite
#[019] 28/06/2022 MZM : SPIRA 105131:  REQ20.1 - no calculation  Fix sur les doublons apres Step _19A Ajout Step _19O
#[020] 14/10/2022 MZM : SPIRA 107125:  REQ20.1 - RA / RR View - REQ 20.1
#[021] 08/11/2022 MZM : SPIRA 107520:  REQ20.1 -Spira 107520 Change Input file to avoid double offset : FILTER ON PRS 740 
#[022] 08/11/2022 MZM : SPIRA 107133:  REQ20.1 -Spira 107133 TRN_NT  EMPTY AND TRANSFORMATION Stored In column 104 
#[023] 10/11/2022 MZM : SPIRA 107125:  REQ20.1 - RA / RR View - REQ 20.1 GENERER FTECLEDR A PARTIR DU FTECLEDA
#[024] 10/11/2022 MZM : SPIRA 107687:  REQ20.1 - TECHNICAL CHANGE : 2010,2013,2019,1016,1017
#[025] 30/01/2023 MZM : SPIRA 108631:  REQ 20.1 - Change Input file to avoid double offset - Copy : Prise en compte des Annulations PRS_740
#[026] 09/02/2023 MZM : SPIRA 108737:  INT - Missing Retrocessionaire in RR view for I17 transactions : MAPPING SUR FICHIER ESCJ0660_FPLATCUMALL0
#[027] 13/03/2023 MZM : SPIRA 107134   INT - Missing Retrocessionaire in RR view for I17 transactions : Variabilisation du Fichier FPLATXCUM (ALL ou CUM) en entree du ESTC1052B
#[028] 27/03/2023 MZM : SPIRA 108587   Mixed retro : AEs are wrong in RA view : Ajout du cumul sur cle total apres appel du ESTC1052B au step _38 
#[029] 03/04/2023 MZM : SPIRA 109394   Criteria to compute I4 to I17 transformation not properly applied
#[030] 07/04/2023 MZM : SPIRA 108576   20.1 - FD new update ; Generation des LC / CSM Annulables pour I17
#[031] 11/04/2023 MZM : SPIRA 108942   20.1 - Delta Posting - strange delta
#[032] 14/04/2023 MZM : SPIRA 108576   20.1 - FD new update  Generation des LC / CSM Annulables pour I17 : Grouping "1016" et "1017" Pour Tout
#[033] 22/05/2023 MZM : SPIRA 109559   20.1 - I17 - IFRS4 cancel calculated on retro NP with Q-1 CSM pattern at 1 : Modif du Step _19O pour filtre que Ass et Retro Prop
#[034] 04/07/2023 MZM : SPIRA 110070   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping QUE POUR EBS : "1041" OR "1051" OR "2041" OR "2044" OR "2051" OR "2054" et des conditions  [abs(CSM ending) + abs(LC ending)] 
#[035] 17/07/2023 MZM : SPIRA 110198   20.1 - I17 - REQ 20.1 - Update on Reclass conditions  [abs(CSM ending) + abs(LC ending)] 
#[036] 02/08/2023 MZM : SPIRA 110198   20.1 - I17 - REQ 20.1 - Update on Reclass conditions  [abs(CSM ending) + abs(LC ending)] Fix Sur Doublons CSM LC AMORT
#[037] 11/10/2023 MZM : SPIRA 110675   20.1 - I17 - REQ 20.1 - remove content of NEWCOLS5_NF on reclass transactions
#[038] 04/07/2023 MZM : SPIRA 109797   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping  : "4200" OR "4220" 
#[039] 04/07/2023 MZM : SPIRA 110789   20.1 - I17 -REQ 20.1 - Reclass still calculated when it shouldn't be : Ajout filtre avant jointure avec le Pericae RETRO
#[040] 11/01/2024 MZM : SPIRA 111113   20.1 - I17 -REQ 20.1  Fix Ano PROD
#[041] 16/01/2023 MZM : SPIRA 110217   20.1 - I17 -REQ 20.1 - 17 - Add the LC reclass to the IO auto generation : Prise en compte des Grouping  que pour les AI
#[042] 29/01/2024 MZM : SPIRA 109797   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping   "4200" OR "4220" 
#[043] 29/01/2023 MZM : SPIRA 111191   20.1 - I17 - Add the LC reclass to the IO auto generation - Revert
#==============================================================================

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
  
ECHO_LOG "#===> ESF_FTRSLNK_TXT..........................: ${ESF_FTRSLNK_TXT}"  
ECHO_LOG "#===> ESF_FBOPRSLNK_TXT........................: ${ESF_FBOPRSLNK_TXT}" 
ECHO_LOG "#===> ESF_CSM_PROF.............................: ${ESF_CSM_PROF}" 
ECHO_LOG "#===> ESF_CSM_LC_AMORT_PATTERN.................: ${ESF_CSM_LC_AMORT_PATTERN}" 
ECHO_LOG "#===> ESF_CSM_LC_AMORT_PATTERN_PREV............: ${ESF_CSM_LC_AMORT_PATTERN_PREV}" 
ECHO_LOG "#===> ESF_FCSM_ENDING_RNP......................: ${ESF_FCSM_ENDING_RNP}"
ECHO_LOG "#===> ESF_FCSM_LC_ENDING_ASS...................: ${ESF_FCSM_LC_ENDING_ASS} "    
ECHO_LOG "#===> ESF_IADVPERICASE.........................: ${ESF_IADVPERICASE} "                 

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
	
	ECHO_LOG "#===> EST_GAAPMAP is empty. End of processing"
	JOBEND

fi

#### [008]
##if [ ! -f ${ESF_CSM_PROF} ]
##then
##	touch ${ESF_CSM_PROF}
##fi

##
if [ ! -f ${ESF_CSM_LC_AMORT_PATTERN} ]
then
	touch ${ESF_CSM_LC_AMORT_PATTERN}
fi

##
if [ ! -f ${ESF_CSM_LC_AMORT_PATTERN_PREV} ]
then
	touch ${ESF_CSM_LC_AMORT_PATTERN_PREV}
fi



## [034]

if [ ! -f ${ESF_FTECLEDA_3870_PREV} ]
then
	touch ${ESF_FTECLEDA_3870_PREV}
fi

if [ ! -f ${ESF_FTECLEDA_3870} ]
then
	touch ${ESF_FTECLEDA_3870}
fi


if [ ! -f ${ESF_FCSM_LC_ENDING_RNP} ]
then
	touch ${ESF_FCSM_LC_ENDING_RNP}
fi

if [ ! -f ${ESF_FCSM_LC_ENDING_ASS} ]
then
	touch ${ESF_FCSM_LC_ENDING_ASS}
fi

## [024] [029] Ajout Filtre que sur 1016 et 1017 pour I17
## [034] Ajout des Groupings "1041" OR "1051" OR "2041" OR "2044" OR "2051" OR "2054" OR ACMTRS_NT = "1044" OR ACMTRS_NT = "1054" 
## [038] Ajout des Groupings "4220" OR "4200"  et Modification de la Regle pour I17
## [041] Ajout des Groupings "3420" OR ACMTRS_NT = "3425"  OR ACMTRS_NT = "3430" OR ACMTRS_NT = "4206"  OR ACMTRS_NT = "6440" Pour Implementer RECLASS AI que sur ces Grouping

NSTEP=${NJOB}_05
# Filter ESF_FTRSLNK_TXT on PRS_CF = "751"
#-----------------------------------------------------------------------------
LIBEL="Filter ESF_FTRSLNK_TXT on PRS_CF = "751" AND ACMTRS_NT IN ("1010", "2010", "2013", "2019", "1016", "1017")"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751.dat 500 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751_I17.dat 500 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751_EBS.dat 500 1"
SORT_O4="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751_I17_TRANS.dat 500 1"
SORT_O5="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751_AI_LC.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  PRS_CF       1:1 -  1:,
         ACMTRS_NT    2:1 -  2:,
         DETTRS_CF    3:1 -  3:
/CONDITION IS_PRS_751 ( PRS_CF = "751" AND (ACMTRS_NT = "1010" OR ACMTRS_NT = "1016" OR ACMTRS_NT = "1017" OR ACMTRS_NT = "1044" OR ACMTRS_NT = "1054" OR ACMTRS_NT = "2010" OR ACMTRS_NT = "2013" OR ACMTRS_NT = "2019" ) )
/CONDITION IS_PRS_751_EBS ( PRS_CF = "751" AND (ACMTRS_NT = "1041" OR ACMTRS_NT = "1044" OR ACMTRS_NT = "1054" OR ACMTRS_NT = "1051" OR ACMTRS_NT = "2041" OR ACMTRS_NT = "2044" OR ACMTRS_NT = "2051" OR ACMTRS_NT = "2054" ) )
/CONDITION IS_PRS_751_I17 ( PRS_CF = "751" AND (ACMTRS_NT = "1016" OR ACMTRS_NT = "1017"  OR ACMTRS_NT = "1044" OR ACMTRS_NT = "1054"  ) )
/CONDITION IS_PRS_751_I17_TRANS ( PRS_CF = "751" AND  ( ACMTRS_NT = "4200" OR ACMTRS_NT = "4220"  ) )  
/CONDITION IS_PRS_751_AI_LC ( PRS_CF = "751" AND  ( ACMTRS_NT = "3420" OR ACMTRS_NT = "3425"  OR ACMTRS_NT = "3430" OR ( ACMTRS_NT = "4206" AND DETTRS_CF = '1449450I') OR ACMTRS_NT = "6440") )  
/OUTFILE $SORT_O
/INCLUDE IS_PRS_751
/OUTFILE $SORT_O2
/INCLUDE IS_PRS_751_I17
/OUTFILE $SORT_O3
/INCLUDE IS_PRS_751_EBS
/OUTFILE $SORT_O4
/INCLUDE IS_PRS_751_I17_TRANS
/OUTFILE $SORT_O5
/INCLUDE IS_PRS_751_AI_LC
/COPY
exit
EOF
SORT

## FILTER PERICASE ON AI 

NSTEP=${NJOB}_07
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE + mvt retro interne du Pericase"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       3:1 -  3:,
        END_NT       4:1 -  4:EN,
        SEC_NF       5:1 -  5:EN,
        UWY_NF       6:1 -  6:,
        UW_NT        7:1 -  7:EN, 
        CED_NF       12:1 - 12:,     
        CTRRET_B   	 20:1 - 20:,
        SECACCSTS_CT 77:1 - 77:,
				PORTFOLIO    119:1 - 119:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION RETINT (CTRRET_B != "0" )
/INCLUDE RETINT
exit
EOF
SORT


## [021]

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


### Use IRDPERICASE TO generate RETRO NP fields

NSTEP=${NJOB}_12
#------------------------------------------------------------------------------------
LIBEL="ONLY RETRO NP from ESF_IRDPERICASE0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IRDVPERICASE} 2000 1"  
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


### 


NSTEP=${NJOB}_15
#------------------------------------------------------------------------------------
LIBEL="Excluse Life ${EST_IFRS4}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IFRS4} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        BALSHEY_NF        3:1 -   3:EN,
        BALSHRMTH_NF      4:1 -   4:EN,
        DETTRS_CF        6:1 - 6:,
        LOBACC_CF       45:1 - 45:

/KEYS   DETTRS_CF
/CONDITION VIE ( LOBACC_CF="30" OR LOBACC_CF="31" ) or (BALSHRMTH_NF < ${ICLODAT_M0}) or ( BALSHRMTH_NF > ${ICLODAT_M} ) or (BALSHEY_NF != ${ICLODAT_A} )
/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
exit
EOF
SORT

NSTEP=${NJOB}_15A
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_${EST_BASE}_IFRS4_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_IFRS4_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN         
/KEYS   
         CTR_NF 
        ,END_NF              
				,SEC_NF   
				,UWY_NF   
				,UW_NT    
				,RETCTR_NF
				,RETEND_NT
				,RETSEC_NF
				,RTY_NF   
				,RETUW_NT  
/OUTFILE ${SORT_O}				          
exit
EOF
SORT

NSTEP=${NJOB}_15B
# Join AND Extend IFRS4_NOLIFE  with PRS_751 of _FTRSLNK.dat LC AI
#-----------------------------------------------------------------------------
LIBEL="Join IFRS4_NOLIFE.dat with PRS_ 751 and _FTRSLNK.dat LC AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15A_${IB}_${EST_BASE}_SORT_IFRS4_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_O_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_FTRSLNK_751_AI_LC.dat 2000 1 "~"       
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



NSTEP=${NJOB}_15C
# Join AND Extend IFRS4_NOLIFE  with PERICASE TO EXTRACT  AI
#-----------------------------------------------------------------------------
LIBEL="Join AND Extend IFRS4_NOLIFE  with PERICASE TO EXTRACT AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15B_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_O_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_O_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        all_cols1        1:1 - 118:,
        PER_SSD_CF       1:1 -  1:,
        PER_CTR_NF       3:1 -  3:,
        PER_END_NT       4:1 -  4:,
        PER_SEC_NF       5:1 -  5:,
        PER_UWY_NF       6:1 -  6:,
        PER_UW_NT        7:1 -  7:,
        PER_ESB_CF       8:1 -  8:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT 
/INFILE ${DFILT}/${NJOB}_07_${IB}_SORT_IADPERICASE.dat 2000 1 "~"  
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT 
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols1
exit
EOF
SORT




NSTEP=${NJOB}_16
# Join AND Extend IFRS4_NOLIFE  with PRS_751 of _FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join IFRS4_NOLIFE.dat with PRS_ 751 and _FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15A_${IB}_${EST_BASE}_SORT_IFRS4_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_FTRSLNK_751.dat 2000 1 "~"       
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


NSTEP=${NJOB}_16A
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_IFRS4_NOLIFE_RSLNK_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN         
/KEYS   
         CTR_NF
        ,END_NF   
				,SEC_NF   
				,UWY_NF   
				,UW_NT    
				,RETCTR_NF
				,RETEND_NT
				,RETSEC_NF
				,RTY_NF   
				,RETUW_NT            
/OUTFILE ${SORT_O}
exit
EOF
SORT

# [017] Inversion des colonnes CSM_F1 and LC_F1
#[010] [017] CSM and LC Q-1

NSTEP=${NJOB}_16B
# TRI DU ESF_CSM_LC_AMORT_PATTERN par CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI DU ESF_CSM_LC_AMORT_PATTERN par CSUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_CSM_LC_AMORT_PATTERN_PREV} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_LC_AMORT_PATTERN_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            1:1 -  1:,
        SEC_NF            2:1 -  2:EN,
        UWY_NF            3:1 -  3:EN,
        UW_NF             4:1 -  4:EN,
				ASS_RET           5:1 -  5:,	
				RETRO_NP          6:1 -  6:,
				LC_F1             7:1 -  7:,				
				CSM_F1            8:1 -  8:
/KEYS   
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NF        
/OUTFILE ${SORT_O}
exit
EOF
SORT


#####

# [017] Inversion des colonnes CSM_F1 and LC_F1

#  (RETRO_NP != "N" OR RETRO_NP = "~" ) AND ( (PROF_CALC_NF = "3" AND CSM_F1="1" ) OR (PROF_CALC_NF = "1" AND LC_F1="1") ) 

## [029] /CONDITION  CSM_LC   (RETRO_NP != "N" OR RETRO_NP = "~" ) AND ( ( CSM_F1="1" ) OR ( LC_F1="1") ) 

## [034 ==>  OR (abs(CSM Ending Q-1) + abs(LC Ending Q-1) < 1 )

NSTEP=${NJOB}_16C
#  SORT ONLY (Prof=="3" and CSM=="1") OU (Prof=="1" and LC=="1")
#-----------------------------------------------------------------------------
LIBEL="SORT ONLY (Prof=="3" and CSM=="1") OU (Prof=="1" and LC=="1") WITH PROFITA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16B_${IB}_CSM_LC_AMORT_PATTERN_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_AMORT_PATTERN.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_CSM_AMORT_PATTERN_RNP.dat OVERWRITE 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            1:1 -  1:,
        SEC_NF            2:1 -  2:,
        UWY_NF            3:1 -  3:,
        UW_NF             4:1 -  4:,
				ASS_RET           5:1 -  5:,	
				RETRO_NP          6:1 -  6:,
				LC_F1             7:1 -  7:,				
				CSM_F1            8:1 -  8:,
        CTR_NF_F2         9:1 - 9:,
        SEC_NF_F2         10:1 - 10:,
        UWY_NF_F2         11:1 -  11:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:								
/KEYS   
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NF        
/CONDITION  CSM_LC   (RETRO_NP != "N" OR RETRO_NP = "~" ) AND ( ( CSM_F1="1" ) AND ( LC_F1="1") )  
/CONDITION  CSM_RNP  (RETRO_NP = "N") AND (CSM_F1 = "1")    
/OUTFILE ${SORT_O}
/INCLUDE CSM_LC   
/OUTFILE ${SORT_O2}
/INCLUDE CSM_RNP
exit
EOF
SORT




######


## [035] Debut Prise en compte des CSM LC ENDING

NSTEP=${NJOB}_16D
# TRI DU ESF_FCSM_LC_ENDING_ASS par CSUE et JOINTURE AVEC I4I
#-----------------------------------------------------------------------------
LIBEL="TRI DU ESF_FCSM_LC_ENDING_ASS  par CSUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCSM_LC_ENDING_ASS} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_LC_ENDING_ASS_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            1:1 -  1:,
        END_NT            2:1 -  2:EN,
        SEC_NF            3:1 -  3:EN,
        UWY_NF            4:1 -  4:EN,
        UW_NT             5:1 -  5:EN,
				CSM_ENDING_M 			6:1 	- 6:EN 18/3,
				LC_ENDING_M 			7:1 	- 7:EN 18/3,	
				CSM_PLUS_LC_M 		8:1 	- 8:EN 18/3					
/KEYS   
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT        
/OUTFILE ${SORT_O}
/REFORMAT CTR_NF, SEC_NF, UWY_NF, UW_NT, CSM_ENDING_M, LC_ENDING_M, CSM_PLUS_LC_M
exit
EOF
SORT



NSTEP=${NJOB}_16E
# TRI DU ESF_FCSM_ENDING_RNP RETRO par CSUE et JOINTURE AVEC I4I
#-----------------------------------------------------------------------------
LIBEL="TRI DU ESF_FCSM_ENDING_RNP  par CSUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCSM_ENDING_RNP} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_ENDING_RNP_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF            1:1 -  1:,                       
        RETEND_NT            2:1 -  2:EN,                     
        RETSEC_NF            3:1 -  3:EN,                     
        RTY_NF               4:1 -  4:EN,                     
        RETUW_NT             5:1 -  5:EN,                     
				CSM_ENDING_M 			   6:1 	- 6:EN 18/3		       
/KEYS   
        RETCTR_NF,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT        
/OUTFILE ${SORT_O}
/REFORMAT RETCTR_NF, RETSEC_NF, RTY_NF, RETUW_NT, CSM_ENDING_M
exit
EOF
SORT

###   Create Unique File contains CSM LC and CSM LC ENDING Before JOIN WITH OTHER NORMES FILE 

NSTEP=${NJOB}_16F
#-----------------------------------------------------------------------------
LIBEL="get CSM LC not in CSM LC ENDING"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16C_${IB}_PROF_CSM_LC_AMORT_PATTERN.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PROF_CSM_LC_AMORT_PATTERN_SANS_CSM_LC_ENDING.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF             1:1 -  1:, 
		SEC_NF             2:1 -  2:, 
		UWY_NF             3:1 -  3:,
		UW_NT              4:1 -  4:,
		ALL_COLS           1:1 -  8:,		
		CTR_NF_F2         1:1 -  1:, 
		SEC_NF_F2         2:1 -  2:, 
		UWY_NF_F2         3:1 -  3:, 
		UW_NT_F2          4:1 -  4:, 
		CSM_PLUS_LC_F2    7:1 -  7: 
/joinkeys
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${DFILT}/${NJOB}_16D_${IB}_CSM_LC_ENDING_ASS_O.dat 2000 1 "~" 
/joinkeys
        CTR_NF_F2,
        SEC_NF_F2,
        UWY_NF_F2,
        UW_NT_F2
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS, RIGHTSIDE:CSM_PLUS_LC_F2
exit
EOF
SORT


NSTEP=${NJOB}_16G
#------------------------------------------------------------------------------
LIBEL="MERGE CSM LC AMORT WITH CSM_LC ENDING AND GENERATE UNIQUE BY CSUE ==> /SUM  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16F_${IB}_SORT_PROF_CSM_LC_AMORT_PATTERN_SANS_CSM_LC_ENDING.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_16D_${IB}_CSM_LC_ENDING_ASS_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_AMORT_PATTERN_CSM_LC_ENDING.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       1:1 -  3:, 
        		SEC_NF       2:1 -  2:, 
        		UWY_NF       3:1 -  3:, 
       		  UW_NT        4:1 -  4:
/KEYS CTR_NF, 
      SEC_NF,
      UWY_NF,
      UW_NT
/SUM 
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_16H
#-----------------------------------------------------------------------------
LIBEL="get RETRO NP CSM not in CSM RETRO NP ENDING"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16C_${IB}_CSM_AMORT_PATTERN_RNP.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PROF_CSM_AMORT_PATTERN_SANS_CSM_ENDING_RNP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF             1:1 -  1:, 
		SEC_NF             2:1 -  2:, 
		UWY_NF             3:1 -  3:,
		UW_NT              4:1 -  4:,
		ALL_COLS           1:1 -  8:,		
		CTR_NF_F2         1:1 -  1:, 
		SEC_NF_F2         2:1 -  2:, 
		UWY_NF_F2         3:1 -  3:, 
		UW_NT_F2          4:1 -  4:, 
		CSM_PLUS_LC_F2    7:1 -  7: 
/joinkeys
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${DFILT}/${NJOB}_16E_${IB}_CSM_ENDING_RNP_O.dat 2000 1 "~" 
/joinkeys
        CTR_NF_F2,
        SEC_NF_F2,
        UWY_NF_F2,
        UW_NT_F2
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS, RIGHTSIDE:CSM_PLUS_LC_F2
exit
EOF
SORT


NSTEP=${NJOB}_16I
#------------------------------------------------------------------------------
LIBEL="MERGE CSM RETRO NP AMORT WITH CSM RETRO NP ENDING GENERATE UNIQUE BY CSUE==> /SUM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16H_${IB}_SORT_PROF_CSM_AMORT_PATTERN_SANS_CSM_ENDING_RNP.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_16E_${IB}_CSM_ENDING_RNP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_AMORT_PATTERN_CSM_ENDING_RNP.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       1:1 -  3:, 
        		SEC_NF       2:1 -  2:, 
        		UWY_NF       3:1 -  3:, 
       		  UW_NT        4:1 -  4:
/KEYS CTR_NF, 
      SEC_NF,
      UWY_NF,
      UW_NT
/SUM 
/OUTFILE ${SORT_O}
exit
EOF
SORT


## [035] FIN Prise en compte des CSM LC ENDING


######




## IDENTIFICATION DES CONTRATS RETRO PROP ELIGIBLES A LA TRANSFORMATION (TRNCOD1 = 2 ou 4)
## Pour les lignes RETRO de cet ensemble, les exclure du ESFD4035 avant la TRANSFORMATION) 

# Ajout NATRET_CF pour identifier RETRO et RETRO NP 
# NATRET_CF != ("30", "31", "32", "40", "41" ) ==> On traite

# [017] Inversion des colonnes CSM_F2 and LC_F2

## ##/INFILE ${DFILT}/${NJOB}_17B_${IB}_PROF_CSM_LC_AMORT_PATTERN.dat 2000 1 "~" 

NSTEP=${NJOB}_17C
# Join AND Extend ${EST_BASE}_IFRS4_NOLIFE with CSM LC PROFITABLE
#-----------------------------------------------------------------------------
LIBEL="Join ${EST_BASE}_IFRS4_NOLIFE.dat WITH ESFD3750_ESFD3770_PROFIT_CSM_LC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16A_${IB}_${EST_BASE}_SORT_IFRS4_NOLIFE_RSLNK_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        NATRET_CF        52:1 - 52:,                                                     
        ALL_COLS_F1      1:1 - 121:, 
        CTR_NF_F2         1:1 -  1:,
        SEC_NF_F2         2:1 -  2:,
        UWY_NF_F2         3:1 -  3:,
        UW_NT_F2          4:1 -  4:,
				ASS_RET_F2        5:1 -  5:,	
				RETRO_NP_F2       6:1 -  6:,
				LC_F2             7:1 -  7:,				
				CSM_F2            8:1 -  8:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:													         
/joinkeys CTR_NF,      
          SEC_NF,   
          UWY_NF,
          UW_NT                    
/INFILE ${DFILT}/${NJOB}_16G_${IB}_PROF_CSM_LC_AMORT_PATTERN_CSM_LC_ENDING.dat 2000 1 "~"
/joinkeys CTR_NF_F2,       
          SEC_NF_F2,    
          UWY_NF_F2,
          UW_NT_F2                     
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT


# [017] Inversion des colonnes CSM_F2 and LC_F2

NSTEP=${NJOB}_17D
# Join AND Extend ${EST_BASE}_IFRS4_NOLIFE with RETRO NP CSM
#-----------------------------------------------------------------------------
LIBEL="Join ${EST_BASE}_IFRS4_NOLIFE.dat WITH ESFD3750_ESFD3770_ with RETRO NP CSM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_16_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_O.dat 2000 1"
SORT_I="${DFILT}/${NJOB}_16A_${IB}_${EST_BASE}_SORT_IFRS4_NOLIFE_RSLNK_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_PROF_CSM_RNP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,  
        NATRET_CF        52:1 - 52:,                                            
        ALL_COLS_F1      1:1 - 121:, 
        CTR_NF_F2         1:1 -  1:,
        SEC_NF_F2         2:1 -  2:,
        UWY_NF_F2         3:1 -  3:,
        UW_NT_F2          4:1 -  4:,
				ASS_RET_F2        5:1 -  5:,	
				RETRO_NP_F2       6:1 -  6:,
				LC_F2             7:1 -  7:,				
				CSM_F2            8:1 -  8:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:													         
/joinkeys RETCTR_NF,      
          RETSEC_NF,   
          RTY_NF,
          RETUW_NT                    
/INFILE ${DFILT}/${NJOB}_16I_${IB}_PROF_CSM_AMORT_PATTERN_CSM_ENDING_RNP.dat 2000 1 "~" 
/joinkeys CTR_NF_F2,       
          SEC_NF_F2,    
          UWY_NF_F2,
          UW_NT_F2                     
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT


## 17E ${DFILT}/${NJOB}_17C_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 

# [018] NATRET_CF != ("30", "31", "32", "40", "41" )  

##NSTEP=${NJOB}_17E
### FILTER ACCEPT AND RETRO PROP ONLY
###-----------------------------------------------------------------------------
##LIBEL="FILTER ON ACCEPT AND RETRO PROP ONLY"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_17C_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 2000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 2000 1"
##INPUT_TEXT ${SORT_CMD} <<EOF
##/FIELDS SSD_CF            1:1 -  1:,
##        ESB_CF            2:1 -  2:,
##        BALSHEY_NF        3:1 -  3:,
##        BALSHRMTH_NF      4:1 -  4:,
##        BALSHRDAY_NF      5:1 -  5:,
##        TRNCOD_CF         6:1 -  6:,
##        DBLTRNCOD_CF      7:1 -  7:,
##        CTR_NF            8:1 -  8:,
##        END_NF            9:1 -  9:,
##        SEC_NF           10:1 - 10:,
##        UWY_NF           11:1 - 11:,
##        UW_NT            12:1 - 12:,
##        RETCTR_NF        24:1 - 24:,
##        RETEND_NT        25:1 - 25:,
##        RETSEC_NF        26:1 - 26:,
##        RTY_NF           27:1 - 27:,
##        RETUW_NT         28:1 - 28:,  
##        NATRET_CF        52:1 - 52:,                                            
##        ALL_COLS_F1      1:1 - 121: 
##/KEYS   
##         CTR_NF
##        ,END_NF   
##				,SEC_NF   
##				,UWY_NF   
##				,UW_NT    
##				,RETCTR_NF
##				,RETEND_NT
##				,RETSEC_NF
##				,RTY_NF   
##				,RETUW_NT                            
##/CONDITION  REMOVE_RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  )                
##/OUTFILE ${SORT_O}
##/OMIT REMOVE_RETRO_NP 													  
##exit
##EOF
##SORT


NSTEP=${NJOB}_17A
# FILTER ACCEPT AND RETRO PROP ONLY
#-----------------------------------------------------------------------------
LIBEL="FILTER ON ACCEPT AND RETRO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_17C_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS4_NOLIFE_ASS.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS4_NOLIFE_RETRO.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,  
        NATRET_CF        52:1 - 52:,                                            
        ALL_COLS_F1      1:1 - 121:                             

/CONDITION GRP_ASS (TRNCOD1_CF='1')
/CONDITION GRP_RET (TRNCOD1_CF='2')

/OUTFILE ${SORT_O}
/INCLUDE GRP_ASS

/OUTFILE ${SORT_O2}
/INCLUDE GRP_RET
exit
EOF
SORT



NSTEP=${NJOB}_17B
LIBEL="GENERATE FIELD WITHOUT RETRO NP FROM IRDPERICASE0  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
##SORT_I="${DFILT}/${NJOB}_17C_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 2000 1"
SORT_I="${DFILT}/${NJOB}_17A_${IB}_PROF_CSM_LC_IFRS4_NOLIFE_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS4_NOLIFE_RETRO.dat 2000 1"
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
/INFILE ${DFILT}/${NJOB}_12_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:NATRET_CF
exit
EOF
SORT


NSTEP=${NJOB}_17E
LIBEL="MERGE ASS With RETRO  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_17A_${IB}_PROF_CSM_LC_IFRS4_NOLIFE_ASS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_17B_${IB}_PROF_CSM_LC_IFRS4_NOLIFE_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 2000 1"
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

/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT


# [036]

NSTEP=${NJOB}_17F
# SORT UNIQUE of  file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of IFRS4_NOLIFE_PROF_CSM_LC.dat BEFORE JOIN  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_17E_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS         
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:
/KEYS   
         CTR_NF  
				,SEC_NF   
				,UWY_NF   
				,UW_NT                  
/OUTFILE ${SORT_O}
exit
EOF
SORT



# [009] Ajout des colonnes  SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF dans la cle de jointure
# [016] TRI UNICITE AJOUT SCORSTH dans Cle de Jointure ci dessous
# [017] Inversion des colonnes CSM_F2 and LC_F2
# [020] RA / RR View - REQ 20.1 : REMOVE /JOIN UNPAIRED LEFTSIDE

# [036] /INFILE ${DFILT}/${NJOB}_17F_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 2000 1 "~"

###NSTEP=${NJOB}_19A
#### Remove Grouping 751 1010 1020 AND CSM LC Prof from TTECLEDA ORI
####-----------------------------------------------------------------------------
###LIBEL="Remove Grouping 751 1010 1020 AND CSM LC Prof from TTECLEDA ORI"
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_15_${IB}_${EST_BASE}_IFRS4_NOLIFE.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_NOLIFE_PROF_CSM_LC.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS SSD_CF            1:1 -  1:,
###        ESB_CF            2:1 -  2:,
###        BALSHEY_NF        3:1 -  3:,
###        BALSHRMTH_NF      4:1 -  4:,
###        BALSHRDAY_NF      5:1 -  5:,
###        TRNCOD_CF         6:1 -  6:,
###        DBLTRNCOD_CF      7:1 -  7:,
###        CTR_NF            8:1 -  8:,
###        END_NF            9:1 -  9:,
###        SEC_NF           10:1 - 10:,
###        UWY_NF           11:1 - 11:,
###        UW_NT            12:1 - 12:,
###				SCOSTRMTH_NF     15:1 -  15:,
###				SCOENDMTH_NF     16:1 -  16:,
###				CUR_CF           18:1 -  18:,
###				AMT_M            19:1 -  19:EN 18/3,        
###        RETCTR_NF        24:1 - 24:,
###        RETEND_NT        25:1 - 25:,
###        RETSEC_NF        26:1 - 26:,
###        RTY_NF           27:1 - 27:,
###        RETUW_NT         28:1 - 28:,
###        NATRET_CF        52:1 - 52:,                                                     
###        all_cols_F1      1:1 - 121:,
###        SSD_CF_F2        1:1 -  1:,
###        ESB_CF_F2        2:1 -  2:,
###        BALSHEY_NF_F2    3:1 -  3:,
###        BALSHRMTH_NF_F2  4:1 -  4:,
###        BALSHRDAY_NF_F2  5:1 -  5:,        
###        TRNCOD_CF_F2     6:1 -  6:,
###        CTR_NF_F2        8:1 -  8:,        
###        SEC_NF_F2        10:1 - 10:, 
###        UWY_NF_F2        11:1 - 11:, 
###        UW_NT_F2         12:1 - 12:,
###				SCOSTRMTH_NF_F2     15:1 -  15:,
###				SCOENDMTH_NF_F2     16:1 -  16:,
###				CUR_CF_F2           18:1 -  18:,
###				AMT_M_F2            19:1 -  19:EN 18/3,                   
###	      LC_F2            122:1 - 122:, 
###	      CSM_F2           123:1 - 123:, 	 
###	      PROF_CALC_NF     124:1 - 124: 	        
###/joinkeys CTR_NF,      
###          SEC_NF,   
###          UWY_NF,
###          UW_NT,
###          SSD_CF,       
###          ESB_CF,       
###          BALSHEY_NF,   
###          BALSHRMTH_NF, 
###          BALSHRDAY_NF,
###          SCOSTRMTH_NF,
###					SCOENDMTH_NF,
###					CUR_CF,      
###          TRNCOD_CF                   
###/INFILE ${DFILT}/${NJOB}_17F_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 2000 1 "~"
###/joinkeys CTR_NF_F2,       
###          SEC_NF_F2,    
###          UWY_NF_F2,
###          UW_NT_F2,
###          SSD_CF_F2,       
###          ESB_CF_F2,       
###          BALSHEY_NF_F2,   
###          BALSHRMTH_NF_F2, 
###          BALSHRDAY_NF_F2, 
###          SCOSTRMTH_NF_F2,
###					SCOENDMTH_NF_F2,
###					CUR_CF_F2,           
###          TRNCOD_CF_F2                                    
###/OUTFILE ${SORT_O}
###/REFORMAT leftside:all_cols_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF		 													  
###exit
###EOF
###SORT

##[041]

NSTEP=${NJOB}_19U
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements AI IO Auto"
AWK_I=${DFILT}/${NJOB}_15C_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_O_AI.dat 
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_O_AI_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if ( \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        if ( \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);         
        print \$0;
  }
exit
EOF
AWK

###[019] Remove Doublons Sort Unique Profita
###[033] Ajout du filtre /CONDITION  REMOVE_RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  )  
###[036] Replace ##SORT_I="${DFILT}/${NJOB}_19A_${IB}_${EST_BASE}_IFRS4_NOLIFE_PROF_CSM_LC.dat 2000 1"

NSTEP=${NJOB}_19O
# SORT UNIQUE of  file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of IFRS4_NOLIFE_PROF_CSM_LC.dat  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_19A_${IB}_${EST_BASE}_IFRS4_NOLIFE_PROF_CSM_LC.dat 2000 1"
SORT_I="${DFILT}/${NJOB}_17F_${IB}_PROF_CSM_LC_IFRS4_NOLIFE.dat 2000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_NOLIFE_PROF_CSM_LC.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		1:1 - 126:,
        NATRET_CF    	52:1 - 52:
/KEYS   ALL_F1
/CONDITION  REMOVE_RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  )                
/OUTFILE ${SORT_O}
/OMIT REMOVE_RETRO_NP
exit
EOF
SORT 


#[015]

NSTEP=${NJOB}_19B
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements Assue et RETRO PROP CSM LC PROFITABLES"
AWK_I=${DFILT}/${NJOB}_19O_${IB}_${EST_BASE}_IFRS4_NOLIFE_PROF_CSM_LC.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_NOLIFE_PROF_CSM_LC_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if ( \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        if ( \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);         
        print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_19C
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements CSM RNP "
AWK_I=${DFILT}/${NJOB}_17D_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_PROF_CSM_RNP.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_PROF_CSM_RNP_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if ( \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        if ( \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);        
        print \$0;
  }
exit
EOF
AWK


##[031] ##[041]

##[043] Revert LC Assumes

NSTEP=${NJOB}_19D
# Remove Grouping 751 1010 1020 AND CSM LC Prof from ${EST_BASE}_IFRS4_NOLIFE
#-----------------------------------------------------------------------------
LIBEL=" UPDATE ${EST_BASE}_IFRS4_NOLIFE WITH cancellables mouvements "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_${EST_BASE}_IFRS4_NOLIFE.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_19B_${IB}_${EST_BASE}_IFRS4_NOLIFE_PROF_CSM_LC_AWK.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_19C_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_PROF_CSM_RNP_AWK.dat 2000 1"
##SORT_I4="${DFILT}/${NJOB}_19U_${IB}_${EST_BASE}_IFRS4_NOLIFE_RSLNK_O_AI_AWK.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_NOLIFE_NO_PROF_CSM_LC.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
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
  NATRET_CF        52:1 -  52:,
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
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0) 
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT	      


# [022] TRN_NT_NEW EMPTY AND TRANSFORMATION Stored In column 104 ==> /DERIVEDFIELD ORICOD_NEW   "RECLASSP~"

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="Apply transformation to ${EST_IFRS4}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_15_${IB}_${EST_BASE}_IFRS4_NOLIFE.dat 2000 1"
SORT_I="${DFILT}/${NJOB}_19D_${IB}_${EST_BASE}_IFRS4_NOLIFE_NO_PROF_CSM_LC.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4.dat 2000 1"
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
/DERIVEDFIELD ORICOD_NEW   "RECLASSP~"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD CRE_NEW "${PARM_CRE_D}~CloP~${PARM_CRE_D}~CloP~"
/DERIVEDFIELD TRN_NT_NEW "~"

/JOINKEYS
        S_DETTRS_CF
/INFILE ${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_GAAPMAP_IFRS4.dat 2000 1 "~"
/JOINKEYS
        ORIDETTRS_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW, rightside : TARGDETTRS_CF, SEPARATEUR,leftside : S_MID1, CRE_NEW , leftside : S_MID2, COLS14_NEW, leftside : TRN_NT_NEW, ORICOD_NEW , leftside : S_TAIL1,GAAPCOD_NEW, leftside : S_TAIL2, rightside : MAPTYP_CT
exit
EOF
SORT


NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Transforme using Sign"
AWK_I=${DFILT}/${NJOB}_20_${IB}_${EST_BASE}_IFRS4.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
	if (\$119 == "-1" && \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19); 
	if (\$119 == "-1" && \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35); 
	print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_32
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing GTAR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_${EST_BASE}_IFRS4_AWK.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4_AWK.dat 2000 1"
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




## Deb Ajout des PLC_NT et RTO 

## EST_FPLATXCUMALL0=/scor/home/u006596/martin/perm/M_ESCJ0660_FPLATXCUMALL0.dat
## SORT_I=${EST_FPLATXCUMALL0}

NSTEP=${NJOB}_35
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

#[026] #export ${PRG}_I2="${DFILT}/${NJOB}_30_${IB}_${EST_BASE}_IFRS4_AWK.dat"

NSTEP=${NJOB}_37
# Affectation par placement
#-----------------------------------------------------------------------------
LIBEL=" AGREGATES retro Affectation MVT par placement "
PRG=ESTC1052B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
FPLATXCUM ALL
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NJOB}_35_${IB}_FPLATXCUMALL0.dat"
export ${PRG}_I2="${DFILT}/${NJOB}_32_${IB}_${EST_BASE}_IFRS4_AWK.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_${PRG}_IFRS4.dat"
EXECPRG

#[028]
NSTEP=${NJOB}_38
#------------------------------------------------------------------------------------
LIBEL="Summarize on Key "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_37_${IB}_${EST_BASE}_ESTC1052B_IFRS4.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4.dat 2000 1"
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

## SORT_I="${DFILT}/${NJOB}_30_${IB}_${EST_BASE}_IFRS4_AWK.dat 2000 1"

#[028]

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------------
LIBEL="merg files to ouput ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_38_${IB}_${EST_BASE}_IFRS4.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS4.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 - 1:,
        ESB_CF            2:1 - 2:,
        DETTRS_CF         6:1 - 6:,
	ALL		  1:1 - 118:	        
/KEYS   SSD_CF,
        ESB_CF,
        DETTRS_CF
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT ALL
exit
EOF
SORT

## [026]FinAjout des PLC_NT et RTO 

## A RAJOUTER DANS MAPPING :ESF_FTECLEDA_17E_PROF_CSM_LC et :ESF_FTECLEDA_40_IFRS4
##EXECKSH "cp ${DFILT}/${NJOB}_40_${IB}_${EST_BASE}_IFRS4.dat ${DFILT}/${ENV_PREFIX}_ESFD4030_ESFD4033_${NORME_CF}_ESF_FTECLEDA_40_IFRS4.dat"
EXECKSH "cp ${DFILT}/${NJOB}_40_${IB}_${EST_BASE}_IFRS4.dat ${ESF_FTECLEDA_40_IFRS4}"

## [034] Apply Transformation to EBS

NSTEP=${NJOB}_45
#------------------------------------------------------------------------------------
LIBEL="Excluse Life ${EST_EBS}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_EBS} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        BALSHEY_NF        3:1 -   3:EN,
        BALSHRMTH_NF      4:1 -   4:EN,
        DETTRS_CF        6:1 - 6:,
        LOBACC_CF       45:1 - 45:

/KEYS   DETTRS_CF
/CONDITION VIE ( LOBACC_CF="30" OR LOBACC_CF="31" ) or (BALSHRMTH_NF < ${ICLODAT_M0}) or ( BALSHRMTH_NF > ${ICLODAT_M} ) or (BALSHEY_NF != ${ICLODAT_A} )

/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
exit
EOF
SORT



## [034] DEB GENERATION MOUVEMENTS EBS LC OU CSM ANNULABLES

NSTEP=${NJOB}_45A
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_${EST_BASE}_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_EBS_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN         
/KEYS   
         CTR_NF 
        ,END_NF              
				,SEC_NF   
				,UWY_NF   
				,UW_NT    
				,RETCTR_NF
				,RETEND_NT
				,RETSEC_NF
				,RTY_NF   
				,RETUW_NT  
/OUTFILE ${SORT_O}				          
exit
EOF
SORT

NSTEP=${NJOB}_45B
# Join AND Extend IFRS4_NOLIFE  with PRS_751 of _FTRSLNK.dat LC AI
#-----------------------------------------------------------------------------
LIBEL="Join EBS_NOLIFE.dat with PRS_ 751 and _FTRSLNK.dat LC AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45A_${IB}_${EST_BASE}_SORT_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_O_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_FTRSLNK_751_AI_LC.dat 2000 1 "~"       
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



NSTEP=${NJOB}_45C
# Join AND Extend EBS_NOLIFE  with PERICASE TO EXTRACT  AI
#-----------------------------------------------------------------------------
LIBEL="Join AND Extend IFRS4_NOLIFE  with PERICASE TO EXTRACT AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45B_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_O_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_O_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        all_cols1        1:1 - 118:,
        PER_SSD_CF       1:1 -  1:,
        PER_CTR_NF       3:1 -  3:,
        PER_END_NT       4:1 -  4:,
        PER_SEC_NF       5:1 -  5:,
        PER_UWY_NF       6:1 -  6:,
        PER_UW_NT        7:1 -  7:,
        PER_ESB_CF       8:1 -  8:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT 
/INFILE ${DFILT}/${NJOB}_07_${IB}_SORT_IADPERICASE.dat 2000 1 "~"  
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT 
/JOIN UNPAIRED LEFTSIDE ONLY       
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols1
exit
EOF
SORT

#####

  

NSTEP=${NJOB}_46
# Join AND Extend EBS_NOLIFE  with PRS_751 of _FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join EBS_NOLIFE.dat with PRS_ 751 and _FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45A_${IB}_${EST_BASE}_SORT_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_FTRSLNK_751_EBS.dat 2000 1 "~"        
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


NSTEP=${NJOB}_46A
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_46_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_EBS_NOLIFE_RSLNK_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN         
/KEYS   
         CTR_NF
        ,END_NF   
				,SEC_NF   
				,UWY_NF   
				,UW_NT    
				,RETCTR_NF
				,RETEND_NT
				,RETSEC_NF
				,RTY_NF   
				,RETUW_NT            
/OUTFILE ${SORT_O}
exit
EOF
SORT


## IDENTIFICATION DES CONTRATS RETRO PROP ELIGIBLES A LA TRANSFORMATION (TRNCOD1 = 2 ou 4)
## Pour les lignes RETRO de cet ensemble, les exclure du ESFD4035 avant la TRANSFORMATION) 



NSTEP=${NJOB}_47C
# Join AND Extend ${EST_BASE}_EBS_NOLIFE with CSM LC PROFITABLE
#-----------------------------------------------------------------------------
LIBEL="Join ${EST_BASE}_EBS_NOLIFE.dat WITH ESFD3750_ESFD3770_PROFIT_CSM_LC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_46A_${IB}_${EST_BASE}_SORT_EBS_NOLIFE_RSLNK_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        NATRET_CF        52:1 - 52:,                                                     
        ALL_COLS_F1      1:1 - 121:, 
        CTR_NF_F2         1:1 -  1:,
        SEC_NF_F2         2:1 -  2:,
        UWY_NF_F2         3:1 -  3:,
        UW_NT_F2          4:1 -  4:,
				ASS_RET_F2        5:1 -  5:,	
				RETRO_NP_F2       6:1 -  6:,
				LC_F2             7:1 -  7:,				
				CSM_F2            8:1 -  8:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:													         
/joinkeys CTR_NF,      
          SEC_NF,   
          UWY_NF,
          UW_NT                    
/INFILE ${DFILT}/${NJOB}_16G_${IB}_PROF_CSM_LC_AMORT_PATTERN_CSM_LC_ENDING.dat 2000 1 "~" 
/joinkeys CTR_NF_F2,       
          SEC_NF_F2,    
          UWY_NF_F2,
          UW_NT_F2                     
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT


NSTEP=${NJOB}_47D
# Join AND Extend ${EST_BASE}_EBS_NOLIFE with RETRO NP CSM
#-----------------------------------------------------------------------------
LIBEL="Join ${EST_BASE}_EBS_NOLIFE.dat WITH ESFD3750_ESFD3770_ with RETRO NP CSM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_46A_${IB}_${EST_BASE}_SORT_EBS_NOLIFE_RSLNK_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_PROF_CSM_RNP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,  
        NATRET_CF        52:1 - 52:,                                            
        ALL_COLS_F1      1:1 - 121:, 
        CTR_NF_F2         1:1 -  1:,
        SEC_NF_F2         2:1 -  2:,
        UWY_NF_F2         3:1 -  3:,
        UW_NT_F2          4:1 -  4:,
				ASS_RET_F2        5:1 -  5:,	
				RETRO_NP_F2       6:1 -  6:,
				LC_F2             7:1 -  7:,				
				CSM_F2            8:1 -  8:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:													         
/joinkeys RETCTR_NF,      
          RETSEC_NF,   
          RTY_NF,
          RETUW_NT                    
/INFILE ${DFILT}/${NJOB}_16I_${IB}_PROF_CSM_AMORT_PATTERN_CSM_ENDING_RNP.dat 2000 1 "~" 
/joinkeys CTR_NF_F2,       
          SEC_NF_F2,    
          UWY_NF_F2,
          UW_NT_F2                     
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT



###NSTEP=${NJOB}_47E
#### FILTER ACCEPT AND RETRO PROP ONLY
####-----------------------------------------------------------------------------
###LIBEL="FILTER ON ACCEPT AND RETRO PROP ONLY"
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_47C_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS SSD_CF            1:1 -  1:,
###        ESB_CF            2:1 -  2:,
###        BALSHEY_NF        3:1 -  3:,
###        BALSHRMTH_NF      4:1 -  4:,
###        BALSHRDAY_NF      5:1 -  5:,
###        TRNCOD_CF         6:1 -  6:,
###        DBLTRNCOD_CF      7:1 -  7:,
###        CTR_NF            8:1 -  8:,
###        END_NF            9:1 -  9:,
###        SEC_NF           10:1 - 10:,
###        UWY_NF           11:1 - 11:,
###        UW_NT            12:1 - 12:,
###        RETCTR_NF        24:1 - 24:,
###        RETEND_NT        25:1 - 25:,
###        RETSEC_NF        26:1 - 26:,
###        RTY_NF           27:1 - 27:,
###        RETUW_NT         28:1 - 28:,  
###        NATRET_CF        52:1 - 52:,                                            
###        ALL_COLS_F1      1:1 - 121: 
###/KEYS   
###         CTR_NF
###        ,END_NF   
###				,SEC_NF   
###				,UWY_NF   
###				,UW_NT    
###				,RETCTR_NF
###				,RETEND_NT
###				,RETSEC_NF
###				,RTY_NF   
###				,RETUW_NT                            
###/CONDITION  REMOVE_RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  )                
###/OUTFILE ${SORT_O}
###/OMIT REMOVE_RETRO_NP 													  
###exit
###EOF
###SORT


NSTEP=${NJOB}_47A
# FILTER ACCEPT AND RETRO PROP ONLY
#-----------------------------------------------------------------------------
LIBEL="FILTER ON ACCEPT AND RETRO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_47C_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE_ASS.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE_RETRO.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,  
        NATRET_CF        52:1 - 52:,                                            
        ALL_COLS_F1      1:1 - 121:                             

/CONDITION GRP_ASS (TRNCOD1_CF='1')
/CONDITION GRP_RET (TRNCOD1_CF='2')

/OUTFILE ${SORT_O}
/INCLUDE GRP_ASS

/OUTFILE ${SORT_O2}
/INCLUDE GRP_RET
exit
EOF
SORT



NSTEP=${NJOB}_47B
LIBEL="GENERATE FIELD WITHOUT RETRO NP FROM IRDPERICASE0  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_47A_${IB}_PROF_CSM_LC_EBS_NOLIFE_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE_RETRO.dat 2000 1"
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
/INFILE ${DFILT}/${NJOB}_12_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:NATRET_CF
exit
EOF
SORT


NSTEP=${NJOB}_47E
LIBEL="MERGE ASS With RETRO  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_47A_${IB}_PROF_CSM_LC_EBS_NOLIFE_ASS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_47B_${IB}_PROF_CSM_LC_EBS_NOLIFE_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
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

/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT



## [036]

NSTEP=${NJOB}_47F
# SORT UNIQUE of  file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of EBS_NOLIFE_PROF_CSM_LC.dat BEFORE JOIN  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_47E_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS         
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:
/KEYS   
         CTR_NF  
				,SEC_NF   
				,UWY_NF   
				,UW_NT                  
/OUTFILE ${SORT_O}
exit
EOF
SORT

## [036] /INFILE ${DFILT}/${NJOB}_47E_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1 "~"

##[040]

##NSTEP=${NJOB}_49A
### Remove Grouping 751 1010 1020 AND CSM LC Prof from TTECLEDA ORI
###-----------------------------------------------------------------------------
##LIBEL="Remove Grouping 751 1010 1020 AND CSM LC Prof from TTECLEDA ORI"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_45_${IB}_${EST_BASE}_EBS_NOLIFE.dat 2000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_PROF_CSM_LC.dat 2000 1"
##INPUT_TEXT ${SORT_CMD} <<EOF
##/FIELDS SSD_CF            1:1 -  1:,
##        ESB_CF            2:1 -  2:,
##        BALSHEY_NF        3:1 -  3:,
##        BALSHRMTH_NF      4:1 -  4:,
##        BALSHRDAY_NF      5:1 -  5:,
##        TRNCOD_CF         6:1 -  6:,
##        DBLTRNCOD_CF      7:1 -  7:,
##        CTR_NF            8:1 -  8:,
##        END_NF            9:1 -  9:,
##        SEC_NF           10:1 - 10:,
##        UWY_NF           11:1 - 11:,
##        UW_NT            12:1 - 12:,
##				SCOSTRMTH_NF     15:1 -  15:,
##				SCOENDMTH_NF     16:1 -  16:,
##				CUR_CF           18:1 -  18:,
##				AMT_M            19:1 -  19:EN 18/3,        
##        RETCTR_NF        24:1 - 24:,
##        RETEND_NT        25:1 - 25:,
##        RETSEC_NF        26:1 - 26:,
##        RTY_NF           27:1 - 27:,
##        RETUW_NT         28:1 - 28:,
##        NATRET_CF        52:1 - 52:,                                                     
##        all_cols_F1      1:1 - 121:,
##        SSD_CF_F2        1:1 -  1:,
##        ESB_CF_F2        2:1 -  2:,
##        BALSHEY_NF_F2    3:1 -  3:,
##        BALSHRMTH_NF_F2  4:1 -  4:,
##        BALSHRDAY_NF_F2  5:1 -  5:,        
##        TRNCOD_CF_F2     6:1 -  6:,
##        CTR_NF_F2        8:1 -  8:,        
##        SEC_NF_F2        10:1 - 10:, 
##        UWY_NF_F2        11:1 - 11:, 
##        UW_NT_F2         12:1 - 12:,
##				SCOSTRMTH_NF_F2     15:1 -  15:,
##				SCOENDMTH_NF_F2     16:1 -  16:,
##				CUR_CF_F2           18:1 -  18:,
##				AMT_M_F2            19:1 -  19:EN 18/3,                   
##	      LC_F2            122:1 - 122:, 
##	      CSM_F2           123:1 - 123:, 	 
##	      PROF_CALC_NF     124:1 - 124: 	        
##/joinkeys CTR_NF,      
##          SEC_NF,   
##          UWY_NF,
##          UW_NT,
##          SSD_CF,       
##          ESB_CF,       
##          BALSHEY_NF,   
##          BALSHRMTH_NF, 
##          BALSHRDAY_NF,
##          SCOSTRMTH_NF,
##					SCOENDMTH_NF,
##					CUR_CF,      
##          TRNCOD_CF                   
##/INFILE ${DFILT}/${NJOB}_47F_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1 "~"
##/joinkeys CTR_NF_F2,       
##          SEC_NF_F2,    
##          UWY_NF_F2,
##          UW_NT_F2,
##          SSD_CF_F2,       
##          ESB_CF_F2,       
##          BALSHEY_NF_F2,   
##          BALSHRMTH_NF_F2, 
##          BALSHRDAY_NF_F2, 
##          SCOSTRMTH_NF_F2,
##					SCOENDMTH_NF_F2,
##					CUR_CF_F2,           
##          TRNCOD_CF_F2                                    
##/OUTFILE ${SORT_O}
##/REFORMAT leftside:all_cols_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF		 													  
##exit
##EOF
##SORT


##[041]

NSTEP=${NJOB}_49U
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements EBS AI IO Auto"
AWK_I=${DFILT}/${NJOB}_45C_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_O_AI.dat 
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_O_AI_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if ( \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        if ( \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);         
        print \$0;
  }
exit
EOF
AWK

## [036]SORT_I="${DFILT}/${NJOB}_49A_${IB}_${EST_BASE}_EBS_NOLIFE_PROF_CSM_LC.dat 2000 1"

NSTEP=${NJOB}_49O
# SORT UNIQUE of  file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of EBS_NOLIFE_PROF_CSM_LC.dat  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_47F_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_PROF_CSM_LC.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		1:1 - 126:,
        NATRET_CF    	52:1 - 52:
/KEYS   ALL_F1
/CONDITION  REMOVE_RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  )                
/OUTFILE ${SORT_O}
/OMIT REMOVE_RETRO_NP
exit
EOF
SORT 


#[015]

NSTEP=${NJOB}_49B
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements CSM LC PROFITABLES"
AWK_I=${DFILT}/${NJOB}_49O_${IB}_${EST_BASE}_EBS_NOLIFE_PROF_CSM_LC.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_PROF_CSM_LC_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if ( \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        if ( \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);         
        print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_49C
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements CSM RNP "
AWK_I=${DFILT}/${NJOB}_47D_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_PROF_CSM_RNP.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_PROF_CSM_RNP_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if ( \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        if ( \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);        
        print \$0;
  }
exit
EOF
AWK


##[043] REvert LC Assume

NSTEP=${NJOB}_49D
# Remove Grouping 751 1010 1020 AND CSM LC Prof AND AI AUTO GENERATION  from ${EST_BASE}_EBS_NOLIFE
#-----------------------------------------------------------------------------
LIBEL=" UPDATE ${EST_BASE}_EBS_NOLIFE WITH cancellables mouvements "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_${EST_BASE}_EBS_NOLIFE.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_49B_${IB}_${EST_BASE}_EBS_NOLIFE_PROF_CSM_LC_AWK.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_49C_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_PROF_CSM_RNP_AWK.dat 2000 1"
##SORT_I4="${DFILT}/${NJOB}_49U_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_O_AI_AWK.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_NO_PROF_CSM_LC.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
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
  NATRET_CF        52:1 -  52:,
	RETINTAMT_M      88:1 -  88:EN 18/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:
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
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0) 
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT	      



NSTEP=${NJOB}_50
#------------------------------------------------------------------------------------
LIBEL="Apply transformation to ${EST_EBS}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_49D_${IB}_${EST_BASE}_EBS_NOLIFE_NO_PROF_CSM_LC.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        S_DETTRS_CF       6:1 - 6:,
        S_HEAD            1:1 - 2:,
        ORIDETTRS_CF      3:1 - 3:,
        TARGDETTRS_CF     6:1 - 6:,
        MAPTYP_CT         7:1 - 7: EN,
	S_MID1            8:1 - 40:,
	S_MID2            45:1 - 88:,
	TRN_NT		        103:1 - 103:,	
	S_TAIL1           105:1 - 110:,
  S_TAIL2     			113:1 - 118:
/DERIVEDFIELD GAAPCOD_NEW 2"~"
/DERIVEDFIELD COLS14_NEW 14"~"
/DERIVEDFIELD SEPARATEUR   "~"
/DERIVEDFIELD ORICOD_NEW   "RECLASSP~"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD CRE_NEW "${PARM_CRE_D}~CloP~${PARM_CRE_D}~CloP~"
/DERIVEDFIELD TRN_NT_NEW "~"
/JOINKEYS
        S_DETTRS_CF
/INFILE ${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_GAAPMAP_EBS.dat 2000 1 "~"
/JOINKEYS
        ORIDETTRS_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW, rightside : TARGDETTRS_CF, SEPARATEUR,leftside : S_MID1, CRE_NEW , leftside : S_MID2, COLS14_NEW,leftside : TRN_NT_NEW, ORICOD_NEW,   leftside : S_TAIL1,GAAPCOD_NEW, leftside : S_TAIL2,rightside : MAPTYP_CT
exit
EOF
SORT





NSTEP=${NJOB}_52
#-----------------------------------------------------------------------------
LIBEL="Transforme using Sign"
AWK_I=${DFILT}/${NJOB}_50_${IB}_${EST_BASE}_EBS.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
	if (\$119 == "-1" && \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19); 
	if (\$119 == "-1" && \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35); 
	print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_55
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing GTAR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_52_${IB}_${EST_BASE}_EBS_AWK.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_AWK.dat 2000 1"
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



NSTEP=${NJOB}_57
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
export ${PRG}_I1="${DFILT}/${NJOB}_35_${IB}_FPLATXCUMALL0.dat"
export ${PRG}_I2="${DFILT}/${NJOB}_55_${IB}_${EST_BASE}_EBS_AWK.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_${PRG}_EBS.dat"
EXECPRG


NSTEP=${NJOB}_60
#------------------------------------------------------------------------------------
LIBEL="Summarize on Key "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_57_${IB}_${EST_BASE}_ESTC1052B_EBS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS.dat 2000 1"
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



## FIN  GENERATION MOUVEMENTS IFRS17 LC OU CSM ANNULABLE



## [034] 


NSTEP=${NJOB}_70
#------------------------------------------------------------------------------------
LIBEL="merg files to ouput ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_${EST_BASE}_EBS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS.dat 2000 1"
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


## Generation du Fichier après transformation pour TTECLEDR
EXECKSH "cp ${DFILT}/${NJOB}_70_${IB}_${EST_BASE}_EBS.dat ${ESF_FTECLEDA_70_EBS}"


NSTEP=${NJOB}_75
#------------------------------------------------------------------------------------
LIBEL="Excluse Life ${EST_IFRS17}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IFRS17} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        BALSHEY_NF        3:1 -   3:EN,
        BALSHRMTH_NF      4:1 -   4:EN,
        DETTRS_CF        6:1 - 6:,
        LOBACC_CF       45:1 - 45:

/KEYS   DETTRS_CF
/CONDITION VIE ( LOBACC_CF="30" OR LOBACC_CF="31" ) or (BALSHRMTH_NF < ${ICLODAT_M0}) or ( BALSHRMTH_NF > ${ICLODAT_M} ) or (BALSHEY_NF != ${ICLODAT_A} )
/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
exit
EOF
SORT

## [030] DEB GENERATION MOUVEMENTS IFRS17 LC OU CSM ANNULABLES

NSTEP=${NJOB}_75A
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_${EST_BASE}_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN         
/KEYS   
         CTR_NF 
        ,END_NF              
				,SEC_NF   
				,UWY_NF   
				,UW_NT    
				,RETCTR_NF
				,RETEND_NT
				,RETSEC_NF
				,RTY_NF   
				,RETUW_NT  
/OUTFILE ${SORT_O}				          
exit
EOF
SORT

## [038] 


NSTEP=${NJOB}_75B
# Join AND Extend IFRS17_NOLIFE  with PRS_751 of _FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join IFRS17_NOLIFE.dat with PRS_ 751 and _FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75A_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AVANT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_FTRSLNK_751_I17.dat 2000 1 "~"        
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

NSTEP=${NJOB}_75C
# Join AND Extend IFRS17_NOLIFE  with PRS_751 of _FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join IFRS17_NOLIFE.dat with PRS_ 751 and _FTRSLNK.dat TRANS NEW RULE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75A_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_TRANS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_FTRSLNK_751_I17_TRANS.dat 2000 1 "~"        
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


#####[041]  Generation des MOUVEMENTS LC AI IFRS17 ###


NSTEP=${NJOB}_75D
# Join AND Extend IFRS17_NOLIFE  with PRS_751 of _FTRSLNK.dat LC AI
#-----------------------------------------------------------------------------
LIBEL="Join IFRS17_NOLIFE.dat with PRS_ 751 and _FTRSLNK.dat LC AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75A_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_FTRSLNK_751_AI_LC.dat 2000 1 "~"       
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


NSTEP=${NJOB}_75E
# SORT  of _FTRSLNK.dat LC AI
#-----------------------------------------------------------------------------
LIBEL="Sort _FTRSLNK.dat LC AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75D_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:, 
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,                                                    
        COLS_STD_F1     1:1 - 119:                                                                                                                                                                											         
/KEYS  
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT							  
exit
EOF
SORT



NSTEP=${NJOB}_75F
# Join AND Extend IFRS17_NOLIFE  with PERICASE TO EXTRACT  AI
#-----------------------------------------------------------------------------
LIBEL="Join AND Extend IFRS17_NOLIFE  with PERICASE TO EXTRACT AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75E_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        all_cols1        1:1 - 118:,
        PER_SSD_CF       1:1 -  1:,
        PER_CTR_NF       3:1 -  3:,
        PER_END_NT       4:1 -  4:,
        PER_SEC_NF       5:1 -  5:,
        PER_UWY_NF       6:1 -  6:,
        PER_UW_NT        7:1 -  7:,
        PER_ESB_CF       8:1 -  8:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT 
/INFILE ${DFILT}/${NJOB}_07_${IB}_SORT_IADPERICASE.dat 2000 1 "~"  
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY      
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols1
exit
EOF
SORT


###  Generation des MOUVEMENTS LC AI IFRS17 ###


NSTEP=${NJOB}_76B
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75B_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AVANT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_AVANT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN         
/KEYS   
         CTR_NF
        ,END_NF   
				,SEC_NF   
				,UWY_NF   
				,UW_NT    
				,RETCTR_NF
				,RETEND_NT
				,RETSEC_NF
				,RTY_NF   
				,RETUW_NT  			          
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_76C
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75C_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_TRANS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_TRANS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN         
/KEYS   
         CTR_NF
        ,END_NF   
				,SEC_NF   
				,UWY_NF   
				,UW_NT    
				,RETCTR_NF
				,RETEND_NT
				,RETSEC_NF
				,RTY_NF   
				,RETUW_NT            
/OUTFILE ${SORT_O}
exit
EOF
SORT


## IDENTIFICATION DES CONTRATS RETRO PROP ELIGIBLES A LA TRANSFORMATION (TRNCOD1 = 2 ou 4)
## Pour les lignes RETRO de cet ensemble, les exclure du ESFD4035 avant la TRANSFORMATION) 

# Ajout NATRET_CF pour identifier RETRO et RETRO NP 
# NATRET_CF != ("30", "31", "32", "40", "41" ) ==> On traite

# [017] Inversion des colonnes CSM_F2 and LC_F2

## Eligible  a la TRANSFORMATION SI GROUPING != ("4200" ; "4220") et CSM LC != 1 OU GROUPING "4200" ; "4220" et REGLE ACTUELLE CSM / LC


## [038] correction REGLE AVANT  "/JOIN UNPAIRED LEFTSIDE  " a ete desactive au step _76D

NSTEP=${NJOB}_76D
# Join AND Extend ${EST_BASE}_IFRS17_NOLIFE with CSM LC PROFITABLE
#-----------------------------------------------------------------------------
LIBEL="Join ${EST_BASE}_IFRS17_NOLIFE.dat WITH ESFD3750_ESFD3770_PROFIT_CSM_LC NEW RULE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_76B_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_AVANT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_TRANS_V0.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        NATRET_CF        52:1 - 52:,                                                     
        ALL_COLS_F1      1:1 - 121:, 
        CTR_NF_F2         1:1 -  1:,
        SEC_NF_F2         2:1 -  2:,
        UWY_NF_F2         3:1 -  3:,
        UW_NT_F2          4:1 -  4:,
				ASS_RET_F2        5:1 -  5:,	
				RETRO_NP_F2       6:1 -  6:,
				LC_F2             7:1 -  7:,				
				CSM_F2            8:1 -  8:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:													         
/joinkeys CTR_NF,      
          SEC_NF,   
          UWY_NF,
          UW_NT                    
/INFILE ${DFILT}/${NJOB}_16G_${IB}_PROF_CSM_LC_AMORT_PATTERN_CSM_LC_ENDING.dat 2000 1 "~" 
/joinkeys CTR_NF_F2,       
          SEC_NF_F2,    
          UWY_NF_F2,
          UW_NT_F2                                       
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT



NSTEP=${NJOB}_76E
# Join AND Extend ${EST_BASE}_IFRS17_NOLIFE with CSM LC PROFITABLE
#-----------------------------------------------------------------------------
LIBEL="Join ${EST_BASE}_IFRS17_NOLIFE.dat WITH ESFD3750_ESFD3770_PROFIT_CSM_LC NEW RULE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_76C_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_TRANS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_TRANS_V2.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        NATRET_CF        52:1 - 52:,                                                     
        ALL_COLS_F1      1:1 - 121:, 
        CTR_NF_F2         1:1 -  1:,
        SEC_NF_F2         2:1 -  2:,
        UWY_NF_F2         3:1 -  3:,
        UW_NT_F2          4:1 -  4:,
				ASS_RET_F2        5:1 -  5:,	
				RETRO_NP_F2       6:1 -  6:,
				LC_F2             7:1 -  7:,				
				CSM_F2            8:1 -  8:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:													         
/joinkeys CTR_NF,      
          SEC_NF,   
          UWY_NF,
          UW_NT                    
/INFILE ${DFILT}/${NJOB}_16G_${IB}_PROF_CSM_LC_AMORT_PATTERN_CSM_LC_ENDING.dat 2000 1 "~" 
/joinkeys CTR_NF_F2,       
          SEC_NF_F2,    
          UWY_NF_F2,
          UW_NT_F2 
/JOIN UNPAIRED LEFTSIDE ONLY                                            
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT


### CAS DES RETRO NP

NSTEP=${NJOB}_77D
# Join AND Extend ${EST_BASE}_IFRS17_NOLIFE with RETRO NP CSM
#-----------------------------------------------------------------------------
LIBEL="Join ${EST_BASE}_IFRS17_NOLIFE.dat WITH ESFD3750_ESFD3770_ with RETRO NP CSM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_76B_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_AVANT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_AVANT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,  
        NATRET_CF        52:1 - 52:,                                            
        ALL_COLS_F1      1:1 - 121:, 
        CTR_NF_F2         1:1 -  1:,
        SEC_NF_F2         2:1 -  2:,
        UWY_NF_F2         3:1 -  3:,
        UW_NT_F2          4:1 -  4:,
				ASS_RET_F2        5:1 -  5:,	
				RETRO_NP_F2       6:1 -  6:,
				LC_F2             7:1 -  7:,				
				CSM_F2            8:1 -  8:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:													         
/joinkeys RETCTR_NF,      
          RETSEC_NF,   
          RTY_NF,
          RETUW_NT                    
/INFILE ${DFILT}/${NJOB}_16I_${IB}_PROF_CSM_AMORT_PATTERN_CSM_ENDING_RNP.dat 2000 1 "~" 
/joinkeys CTR_NF_F2,       
          SEC_NF_F2,    
          UWY_NF_F2,
          UW_NT_F2                    
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT


NSTEP=${NJOB}_77G
# Join AND Extend ${EST_BASE}_IFRS17_NOLIFE with RETRO NP CSM
#-------------------------------------------------------------------------------
LIBEL="Join ${EST_BASE}_IFRS17_NOLIFE.dat WITH ESFD3750_ESFD3770_ with RETRO NP CSM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_76C_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_TRANS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_TRANS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,  
        NATRET_CF        52:1 - 52:,                                            
        ALL_COLS_F1      1:1 - 121:, 
        CTR_NF_F2         1:1 -  1:,
        SEC_NF_F2         2:1 -  2:,
        UWY_NF_F2         3:1 -  3:,
        UW_NT_F2          4:1 -  4:,
				ASS_RET_F2        5:1 -  5:,	
				RETRO_NP_F2       6:1 -  6:,
				LC_F2             7:1 -  7:,				
				CSM_F2            8:1 -  8:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:													         
/joinkeys RETCTR_NF,      
          RETSEC_NF,   
          RTY_NF,
          RETUW_NT                    
/INFILE ${DFILT}/${NJOB}_16I_${IB}_PROF_CSM_AMORT_PATTERN_CSM_ENDING_RNP.dat 2000 1 "~" 
/joinkeys CTR_NF_F2,       
          SEC_NF_F2,    
          UWY_NF_F2,
          UW_NT_F2
/JOIN UNPAIRED LEFTSIDE ONLY                              
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT

#[042] Correction filtre que sur RNP

NSTEP=${NJOB}_77H
LIBEL="GENERATE FIELD ONLY WITH RETRO NP FROM IRDPERICASE0  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_77G_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_TRANS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_TRANS.dat 2000 1"
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
/INFILE ${DFILT}/${NJOB}_12_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1 "~" 
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


##### MERGE RETRO NP OLD AND NEW :

NSTEP=${NJOB}_77I
# MERGE RETRO NP OLD AND NEW RULE CSM LC "4200" "4220" 
#-----------------------------------------------------------------------------
LIBEL="MERGE RETRO NP OLD AND NEW RULE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_77D_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_AVANT.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_77H_${IB}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_TRANS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,        
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,  
        NATRET_CF        52:1 - 52:,                                            
        ALL_COLS_F1      1:1 - 121:    
                                 
/CONDITION GRP_RETNP (TRNCOD1_CF='2' OR TRNCOD1_CF='4')
/OUTFILE ${SORT_O}
/INCLUDE GRP_RETNP
exit
EOF
SORT


######


NSTEP=${NJOB}_77A
# FILTER ACCEPT AND RETRO PROP ONLY
#-----------------------------------------------------------------------------
LIBEL="FILTER ON ACCEPT AND RETRO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_76D_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_TRANS_V0.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_76E_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_TRANS_V2.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_ASS.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_RETRO.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,  
        NATRET_CF        52:1 - 52:,                                            
        ALL_COLS_F1      1:1 - 121:                             

/CONDITION GRP_ASS (TRNCOD1_CF='1')
/CONDITION GRP_RET (TRNCOD1_CF='2')

/OUTFILE ${SORT_O}
/INCLUDE GRP_ASS

/OUTFILE ${SORT_O2}
/INCLUDE GRP_RET
exit
EOF
SORT



NSTEP=${NJOB}_77B
LIBEL="GENERATE FIELD WITHOUT RETRO NP FROM IRDPERICASE0  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_77A_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_RETRO.dat 2000 1"
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
/INFILE ${DFILT}/${NJOB}_12_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:NATRET_CF
exit
EOF
SORT


NSTEP=${NJOB}_77E
LIBEL="MERGE ASS With RETRO PROP  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_77A_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_ASS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_77B_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE.dat 2000 1"
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

/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT



## [036]

NSTEP=${NJOB}_77F
# SORT UNIQUE of  file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of IFRS17_NOLIFE_PROF_CSM_LC.dat BEFORE JOIN  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_77E_${IB}_PROF_CSM_LC_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS         
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:
/KEYS   
         CTR_NF  
				,SEC_NF   
				,UWY_NF   
				,UW_NT                   
/OUTFILE ${SORT_O}
exit
EOF
SORT


##[040]



## [036] SORT_I="${DFILT}/${NJOB}_79A_${IB}_${EST_BASE}_IFRS17_NOLIFE_PROF_CSM_LC.dat 2000 1"

NSTEP=${NJOB}_79O
# SORT UNIQUE of  file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of IFRS17_NOLIFE_PROF_CSM_LC.dat  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_77F_${IB}_PROF_CSM_LC_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_PROF_CSM_LC.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		1:1 - 126:,
        NATRET_CF    	52:1 - 52:
/KEYS   ALL_F1
/CONDITION  REMOVE_RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  )                
/OUTFILE ${SORT_O}
/OMIT REMOVE_RETRO_NP
exit
EOF
SORT 


#[015]

NSTEP=${NJOB}_79B
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements CSM LC PROFITABLES"
AWK_I=${DFILT}/${NJOB}_79O_${IB}_${EST_BASE}_IFRS17_NOLIFE_PROF_CSM_LC.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_PROF_CSM_LC_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if ( \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        if ( \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);         
        print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_79C
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements CSM RNP "
AWK_I=${DFILT}/${NJOB}_77I_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if ( \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        if ( \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);        
        print \$0;
  }
exit
EOF
AWK

##[041]

##  

NSTEP=${NJOB}_79D
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements IFRS17 AI IO Auto"
AWK_I=${DFILT}/${NJOB}_75F_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if ( \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        if ( \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);         
        print \$0;
  }
exit
EOF
AWK

##[043] Revert LC Assume

NSTEP=${NJOB}_79E
# Remove Grouping 751 1010 1020 AND CSM LC Prof from ${EST_BASE}_IFRS17_NOLIFE
#-----------------------------------------------------------------------------
LIBEL=" UPDATE ${EST_BASE}_IFRS17_NOLIFE WITH cancellables mouvements "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_${EST_BASE}_IFRS17_NOLIFE.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_79B_${IB}_${EST_BASE}_IFRS17_NOLIFE_PROF_CSM_LC_AWK.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_79C_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_AWK.dat 2000 1"
##SORT_I4="${DFILT}/${NJOB}_79D_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI_AWK.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_NO_PROF_CSM_LC.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
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
  NATRET_CF        52:1 -  52:,
	RETINTAMT_M      88:1 -  88:EN 18/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:
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
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0) 
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT	      



NSTEP=${NJOB}_80
#----------------------------------------------------------------------------------
LIBEL="Apply transformation to ${EST_IFRS17}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_79E_${IB}_${EST_BASE}_IFRS17_NOLIFE_NO_PROF_CSM_LC.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        S_DETTRS_CF       6:1 - 6:,
        S_HEAD            1:1 - 2:,
        ORIDETTRS_CF      3:1 - 3:,
        TARGDETTRS_CF     6:1 - 6:,
        MAPTYP_CT         7:1 - 7: EN,
	S_MID1            8:1 - 40:,
	S_MID2            45:1 - 88:,
	TRN_NT		        103:1 - 103:,	
	S_TAIL1           105:1 - 110:,
  S_TAIL2     			113:1 - 118:
/DERIVEDFIELD GAAPCOD_NEW 2"~"
/DERIVEDFIELD COLS14_NEW 14"~"
/DERIVEDFIELD SEPARATEUR   "~"
/DERIVEDFIELD ORICOD_NEW   "RECLASSP~"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD CRE_NEW "${PARM_CRE_D}~CloP~${PARM_CRE_D}~CloP~"
/DERIVEDFIELD TRN_NT_NEW "~"
/JOINKEYS
        S_DETTRS_CF
/INFILE ${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_GAAPMAP_IFRS17.dat 2000 1 "~"
/JOINKEYS
        ORIDETTRS_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW, rightside : TARGDETTRS_CF, SEPARATEUR,leftside : S_MID1, CRE_NEW , leftside : S_MID2, COLS14_NEW,leftside : TRN_NT_NEW, ORICOD_NEW,   leftside : S_TAIL1,GAAPCOD_NEW, leftside : S_TAIL2,rightside : MAPTYP_CT
exit
EOF
SORT





NSTEP=${NJOB}_82
#-----------------------------------------------------------------------------
LIBEL="Transforme using Sign"
AWK_I=${DFILT}/${NJOB}_80_${IB}_${EST_BASE}_IFRS17.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
	if (\$119 == "-1" && \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19); 
	if (\$119 == "-1" && \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35); 
	print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_85
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing GTAR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_82_${IB}_${EST_BASE}_IFRS17_AWK.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_AWK.dat 2000 1"
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



NSTEP=${NJOB}_87
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
export ${PRG}_I1="${DFILT}/${NJOB}_35_${IB}_FPLATXCUMALL0.dat"
export ${PRG}_I2="${DFILT}/${NJOB}_85_${IB}_${EST_BASE}_IFRS17_AWK.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_${PRG}_IFRS17.dat"
EXECPRG


NSTEP=${NJOB}_90
#------------------------------------------------------------------------------------
LIBEL="Summarize on Key "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_87_${IB}_${EST_BASE}_ESTC1052B_IFRS17.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17.dat 2000 1"
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



## FIN  GENERATION MOUVEMENTS IFRS17 LC OU CSM ANNULABLE


NSTEP=${NJOB}_100
#------------------------------------------------------------------------------------
LIBEL="merg files to ouput ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_${EST_BASE}_IFRS17.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17.dat 2000 1"
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

EXECKSH "cp ${DFILT}/${NJOB}_100_${IB}_${EST_BASE}_IFRS17.dat ${ESF_FTECLEDA_100_IFRS17}"

## [025]

#--------------------------------------------
NSTEP=${NJOB}_103
# summarize TTECLEDA by BALSHTDAY
#--------------------------------
LIBEL="AGGREGATION I4I, EBS et IFRS17 RECLASS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_${EST_BASE}_IFRS4.dat  2000 1"
SORT_I2="${DFILT}/${NJOB}_70_${IB}_${EST_BASE}_EBS.dat  2000 1"
SORT_I3="${DFILT}/${NJOB}_100_${IB}_${EST_BASE}_IFRS17.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL.dat 2000 1"
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
	RETARDRETINT_B  109:1 - 109:
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
/OUTFILE ${SORT_O}
exit
EOF
SORT

## Recuperer les Annulations (et Ouvertures) et filtre sur 740 ==> Les Inclure

NSTEP=${NJOB}_104
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="SGenerated 2 files With REJ_OPNG and Without..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_103_${IB}_${EST_BASE}_ALL.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_SANS_REJ_OPNG.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
							SSD_CF          		  1:1 -   1:,      
							ESB_CF          		  2:1 -   2:,      
							BALSHEY_NF      		  3:1 -   3:,      
							BALSHRMTH_NF    		  4:1 -   4:,      
							TRNCOD_CF     		  6:1 -   6:,        
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
#-----------------------------------------------------------------------------
LIBEL="Join ${DFILT}/${NJOB}_104_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG.dat with PRS_ 740_FTRSLNK.dat"
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


## Prise en compte des Annulations du PRS 740 et cumul sur CLE

##[037] Vider le champs _114 POur Les RECLASS

NSTEP=${NJOB}_110
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Prise en compte des Annulations OPNG du PRS 740 ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_104_${IB}_${EST_BASE}_ALL_SANS_REJ_OPNG.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_105_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG_740.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_DELTA.dat 2000 1"
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
	FILLER_1_124    1:1 - 124:,
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
/CONDITION VIDER_NEWCOLS5  (ORICOD_LS = "RECLASSP" or ORICOD_LS = "RECLASSL")        
/DERIVEDFIELD GT_ANNUL_OPNG_NEW if VIDER_NEWCOLS5 then "" else GT_ANNUL_OPNG
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT FILLER_1_124
/OUTFILE ${SORT_O2}
/INCLUDE RESTRICTION
/REFORMAT FILLER_1_113, GT_ANNUL_OPNG_NEW, FILLER_115_124
exit
EOF
SORT


## 


EXECKSH "cp ${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL_DELTA.dat ${EST_DELTA}"


## [021]

### DEB Merge Fusion PERICASE STD


## Ajout du Merge DU PERICASE ASS et Retro avec le fichier  "${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL.dat  2000 1" Avec PERICASE STANDART ACC / RET


#[013] DEB JOINTURE DES FICHIERS AVEC LES PERICASES

NSTEP=${NJOB}_115

LIBEL="Generate Assume and Retro files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL.dat 2000 1"
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

/CONDITION GRP_ASS (TRNCOD1_CF='1')
/CONDITION GRP_RET (TRNCOD1_CF='2')

/OUTFILE ${SORT_O}
/INCLUDE GRP_ASS

/OUTFILE ${SORT_O2}
/INCLUDE GRP_RET
exit
EOF
SORT

# [013]#${DFILT}/${NJOB}_23_${IB}_SORT_IADPERICASE_I17_MERGE_O.dat
#${ESF_IRDVPERICASE}

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
        LOBRET_CF   46:1 - 46:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION VIE ( LOBRET_CF="30" OR LOBRET_CF="31")
/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
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
SORT_I2="${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL_DELTA.dat  2000 1"
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

LIBEL="Sort GLT OUT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_${EST_BASE}_ALL.dat  2000 1"
SORT_O="${EST_OUT} 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL.dat 2000 1"
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
/OUTFILE ${SORT_O2} overwrite
exit
EOF
SORT


JOBEND
