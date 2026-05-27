#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESFD5062.cmd
# revision                      : 
# date de creation              : 15/01/2026
# auteur                        : MZM
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Extraction quatidienne des  fichiers AE BBNI
#
# job launched by ESFD5060.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Description    :Extraction quatidienne DES AE BBNI Independemment de la CUT-OFF
#===============================================================================
#[001] 15/01/2026 MZM  	      :US8221 : Prod Q4 2025 - AE BBNI extracted wrongly by normal EBS process (IMPACT ON EBS INI)
#[002] 24/03/2026 MZM  	      :US8947 : BBNI retro AE extracted wrongly by EBS AE program
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT



if [ ! -f ${ESF_EPOSOCI_BBNI} ]
then
        ECHO_LOG "ESF_EPOSOCI_BBNI=${ESF_EPOSOCI_BBNI}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_EPOSOCI_BBNI}"

fi


if [ ! -f ${ESF_EPOSOCI} ]
then
        ECHO_LOG "ESF_EPOSOCI=${ESF_EPOSOCI}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_EPOSOCI}"

fi


##ESF_EPOSOCI=${EPO_EPOSOCI}

ECHO_LOG "#====================================INPUT FILES====================="
ECHO_LOG "#===> ESF_FTRSLNK_TXT................................................: ${ESF_FTRSLNK_TXT}"
ECHO_LOG "#===>ESF_IADPERICASE_BBNI............................................: ${ESF_IADPERICASE_BBNI}" 
ECHO_LOG "#===>ESF_IADPERICASE_BNI.............................................: ${ESF_IADPERICASE_BNI}" 
ECHO_LOG "#===>ESF_IRDPERICASE_BBNI............................................: ${ESF_IRDPERICASE_BBNI}" 
ECHO_LOG "#===>ESF_IRDPERICASE_BNI.............................................: ${ESF_IRDPERICASE_BNI}"
ECHO_LOG "#===> ESF_EPOSOCI....................................................: ${ESF_EPOSOCI}" 
ECHO_LOG "#===> EPO_EPOSOCI....................................................: ${EPO_EPOSOCI}"

ECHO_LOG "#========================================================================="
ECHO_LOG "#====================================INPUT PARAMETERS====================="
ECHO_LOG "#===> PARM_ICLODAT_D.....................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> NORME_CF...........................................................: ${NORME_CF}"
ECHO_LOG "#===> TYPEINV............................................................: ${TYPEINV}"
ECHO_LOG "#===> X_DAYS.............................................................: ${X_DAYS}"
ECHO_LOG "#===> QUARTER_END_FOUND..................................................: ${QUARTER_END_FOUND}"
ECHO_LOG "#========================================================================="
ECHO_LOG "#====================================OUTPUT FILES====================="
ECHO_LOG "#===> ESF_EPOSOCI....................................................: ${ESF_EPOSOCI}"
ECHO_LOG "#===> ESF_EPOSOCI_BBNI...............................................: ${ESF_EPOSOCI_BBNI}"
ECHO_LOG "#===> ESF_EPOSOCI_INI...............................................: ${ESF_EPOSOCI_INI}"


# Parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
ICLODAT_D=$4
CLODAT_D=$5
OPTION=Q
SSD_CF=00
SEGTYP_CT=A

PARALLEL_INIT 50




NSTEP=${NJOB}_13
#-----------------------------------------------------------------------------
LIBEL="Filter ESF_FTRSLNK_TXT on TRNCOD_ES ONLY "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_TRNCOD_EBS_STD.dat 500 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTRSLNK_TRNCOD_EBS_INI.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
     PRS_CF                 1:1 -  1:,
     ACMTRS_NT                  2:1 -  2:,
     DETTRS_CF                  3:1 -  3:,
     DETTRS8_CF                 3:8 -  3:8
/CONDITION IS_TRNCOD_EBS_STD  (PRS_CF != "740" OR ACMTRS_NT != "101")
/CONDITION IS_TRNCOD_EBS_INI  (PRS_CF= "740" AND ACMTRS_NT = "101")
/OUTFILE $SORT_O
/INCLUDE IS_TRNCOD_EBS_STD
/OUTFILE $SORT_O2
/INCLUDE IS_TRNCOD_EBS_INI
/COPY
exit
EOF
SORT

## RETRO P  / RETRO NP BBNI

NSTEP=${NJOB}_85
#------------------------------------------------------------------------------------
LIBEL=" RETRO NP AND RETRO PROP from ESF_IRDPERICASE_BBNI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IRDPERICASE_BBNI} 2000 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETRO_NP.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETPROP.dat 2000 1"
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
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE RETRO_NP
/OUTFILE ${SORT_O2} OVERWRITE
/OMIT RETRO_NP
exit
EOF
SORT



NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="Split contrat assmued and retro "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_EPOSOCI}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RET.dat 2000 1"
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
/CONDITION COND_GTAA ( TRNCOD1_CF EQ "1" OR TRNCOD1_CF EQ "3" )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_GTAA
/OUTFILE ${SORT_O2} OVERWRITE
/OMIT COND_GTAA
exit
EOF
SORT

ECHO_LOG "#===> ESF_IADPERICASE_BBNI..DEBUG....001.......: ${ESF_IADPERICASE_BBNI}   "



ECHO_LOG "#===> ESF_IADPERICASE_BBNI..DEBUG....003.......: ${ESF_IADPERICASE_BBNI}   "


ECHO_LOG "#===> ESF_IADPERIFACACCEPT_BBNI..DEBUG....003.......: ${ESF_IADPERIFACACCEPT_BBNI}   "


NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
LIBEL="Extract AE for BBNI Contracts RETRO NP "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_EPOSOCI_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_RETCTR_NF    24:1 -  24:,
        GT_RETEND_NT    25:1 -  25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS          1:1 - 49:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        GT_RETCTR_NF  ,
        GT_RETEND_NT  ,
        GT_RETSEC_NF  ,
        GT_RTY_NF     ,
        GT_RETUW_NT  
/INFILE ${DFILT}/${NJOB}_85_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETRO_NP.dat 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

##

NSTEP=${NJOB}_121
#-----------------------------------------------------------------------------
LIBEL="Filter RETRO ON RETRO PROP AND RETRO NON-PROP "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_EPOSOCI_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETPROP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        GT_CTR_NF       8:1 -  8:,
        GT_END_NT       9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_RETCTR_NF    24:1 -  24:,
        GT_RETEND_NT    25:1 -  25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:, 
        GT_ALL_COLS     1:1 - 49:        
/condition IS_RETRO_NONPROP ( ( GT_CTR_NF = "" ) AND ( GT_END_NT = "" ) AND ( GT_SEC_NF = "" ) AND ( GT_UWY_NF = "" )  AND ( GT_UW_NT = "" ) )
/OUTFILE ${SORT_O} overwrite
/INCLUDE IS_RETRO_NONPROP
/OUTFILE ${SORT_O2} overwrite
/OMIT IS_RETRO_NONPROP
exit
EOF
SORT



NSTEP=${NJOB}_123
#-----------------------------------------------------------------------------
LIBEL="Extract AE for BBNI Contracts RETRO  PROP WHERE ASSUME NOT BBNI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_121_${IB}_EPOSOCI_RETPROP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETPROP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_RETCTR_NF    24:1 -  24:,
        GT_RETEND_NT    25:1 -  25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS          1:1 - 49:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys
        GT_RETCTR_NF  ,
        GT_RETEND_NT  ,
        GT_RETSEC_NF  ,
        GT_RTY_NF     ,
        GT_RETUW_NT
/INFILE ${DFILT}/${NJOB}_85_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETPROP.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT




##




NSTEP=${NJOB}_125
#-----------------------------------------------------------------------------
LIBEL="Extract AE for BBNI Contracts RETRO NP PROP "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_121_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_RETCTR_NF    24:1 -  24:,
        GT_RETEND_NT    25:1 -  25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS          1:1 - 49:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        GT_RETCTR_NF  ,
        GT_RETEND_NT  ,
        GT_RETSEC_NF  ,
        GT_RTY_NF     ,
        GT_RETUW_NT  
/INFILE ${DFILT}/${NJOB}_85_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETRO_NP.dat 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT



## ALL ASS  BBNI

NSTEP=${NJOB}_130
#-----------------------------------------------------------------------------
LIBEL="MERGE  AE BBNI ASS and RETRO PROP Contracts  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_EPOSOCI_ASS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS.dat  2000 1"
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
        RETUW_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT


NSTEP=${NJOB}_140
#-----------------------------------------------------------------------------
LIBEL="Extract AE for BBNI Contracts ASS "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_EPOSOCI_ASS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 49:,
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
/INFILE ${ESF_IADPERICASE_BBNI} 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

NSTEP=${NJOB}_150
#-----------------------------------------------------------------------------
LIBEL="MERGE  AE BBNI ASS and RETRO Contracts  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_EPOSOCI_ASS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_123_${IB}_EPOSOCI_RETPROP.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_125_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
SORT_O="${ESF_EPOSOCI_BBNI}  2000 1"
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
        RETUW_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

## REMOVE AE BBNI ON AE EBS STD

##[004] Remove AE BBNI FROM AE EBS STD file

NSTEP=${NJOB}_220
#------------------------------------------------------------------------------
LIBEL=" SORT AE ALL  ON TRN_NT  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_EPOSOCI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_EPOSOCI_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	TRN_NT 43:1 - 43:
/KEYS TRN_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_230
#------------------------------------------------------------------------------
LIBEL=" SORT AE BBNI ON TRN_NT  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_EPOSOCI_BBNI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_EPOSOCI_BBNI_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	TRN_NT 43:1 - 43:
/KEYS TRN_NT 
/OUTFILE ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_240
#-----------------------------------------------------------------------------
LIBEL="get TRN_NT-BBNI not in TRN_NT ALL STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_EPOSOCI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_EPOSOCI_NOT_BBNI_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		TRN_NT       43:1 - 43:,
		ALL_FIELDS   1:1 - 49:,        
		TRN_NT_BBNI 43:1 - 43:		
/joinkeys
        TRN_NT
/INFILE ${ESF_EPOSOCI_BBNI} 2000 1 "~"
/joinkeys
        TRN_NT_BBNI
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT ALL_FIELDS
exit
EOF
SORT


NSTEP=${NJOB}_250
#-----------------------------------------------------------------------------
LIBEL="UPDATE ESF_EPOSOCI WITH ONLY NOT BBNI"
EXECKSH "cp ${DFILT}/${NJOB}_240_${IB}_SORT_ESF_EPOSOCI_NOT_BBNI_O.dat   ${ESF_EPOSOCI} "

## REMOVE INI AE FROM ALL AE EBS

## RETRO P  / RETRO NP EBS INI

NSTEP=${NJOB}_285
#------------------------------------------------------------------------------------
LIBEL=" RETRO NP AND RETRO PROP from ESF_IRDPERICASE_INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IRDPERICASE_INI} 2000 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE_INI_RETRO_NP.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE_INI_RETPROP.dat 2000 1"
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
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE RETRO_NP
/OUTFILE ${SORT_O2} OVERWRITE
/OMIT RETRO_NP
exit
EOF
SORT




NSTEP=${NJOB}_310
#-----------------------------------------------------------------------------
LIBEL="Split contrat assmued and retro "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_EPOSOCI}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RET.dat 2000 1"
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
/CONDITION COND_GTAA ( TRNCOD1_CF EQ "1" OR TRNCOD1_CF EQ "3" )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_GTAA
/OUTFILE ${SORT_O2} OVERWRITE
/OMIT COND_GTAA
exit
EOF
SORT

ECHO_LOG "#===> ESF_IADPERICASE_INI..DEBUG....001.......: ${ESF_IADPERICASE_INI}   "



ECHO_LOG "#===> ESF_IADPERICASE_INI..DEBUG....003.......: ${ESF_IADPERICASE_INI}   "


ECHO_LOG "#===> ESF_IADPERIFACACCEPT_INI..DEBUG....003.......: ${ESF_IADPERIFACACCEPT_INI}   "


NSTEP=${NJOB}_320
#-----------------------------------------------------------------------------
LIBEL="Extract AE for INI Contracts RETRO NP "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_310_${IB}_EPOSOCI_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_RETCTR_NF    24:1 -  24:,
        GT_RETEND_NT    25:1 -  25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS          1:1 - 49:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        GT_RETCTR_NF  ,
        GT_RETEND_NT  ,
        GT_RETSEC_NF  ,
        GT_RTY_NF     ,
        GT_RETUW_NT  
/INFILE ${DFILT}/${NJOB}_285_${IB}_SORT_ESF_IRDPERICASE_INI_RETRO_NP.dat 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

##

NSTEP=${NJOB}_321
#-----------------------------------------------------------------------------
LIBEL="Filter RETRO ON RETRO PROP AND RETRO NON-PROP "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_310_${IB}_EPOSOCI_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETPROP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        GT_CTR_NF       8:1 -  8:,
        GT_END_NT       9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_RETCTR_NF    24:1 -  24:,
        GT_RETEND_NT    25:1 -  25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:, 
        GT_ALL_COLS     1:1 - 49:        
/condition IS_RETRO_NONPROP ( ( GT_CTR_NF = "" ) AND ( GT_END_NT = "" ) AND ( GT_SEC_NF = "" ) AND ( GT_UWY_NF = "" )  AND ( GT_UW_NT = "" ) )
/OUTFILE ${SORT_O} overwrite
/INCLUDE IS_RETRO_NONPROP
/OUTFILE ${SORT_O2} overwrite
/OMIT IS_RETRO_NONPROP
exit
EOF
SORT



NSTEP=${NJOB}_323
#-----------------------------------------------------------------------------
LIBEL="Extract AE for INI Contracts RETRO  PROP WHERE ASSUME NOT INI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_321_${IB}_EPOSOCI_RETPROP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETPROP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_RETCTR_NF    24:1 -  24:,
        GT_RETEND_NT    25:1 -  25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS          1:1 - 49:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys
        GT_RETCTR_NF  ,
        GT_RETEND_NT  ,
        GT_RETSEC_NF  ,
        GT_RTY_NF     ,
        GT_RETUW_NT
/INFILE ${DFILT}/${NJOB}_285_${IB}_SORT_ESF_IRDPERICASE_INI_RETPROP.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT




##

## /INFILE ${DFILT}/${NJOB}_285_${IB}_SORT_ESF_IRDPERICASE_INI_RETRO_NP.dat 2000 1 "~"


NSTEP=${NJOB}_325
#-----------------------------------------------------------------------------
LIBEL="Extract AE for INI Contracts RETRO NP PROP "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_321_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_RETCTR_NF    24:1 -  24:,
        GT_RETEND_NT    25:1 -  25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS          1:1 - 49:,
        PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:
/joinkeys 
        GT_RETCTR_NF  ,
        GT_RETEND_NT  ,
        GT_RETSEC_NF  ,
        GT_RTY_NF     ,
        GT_RETUW_NT  
/INFILE ${ESF_IRDPERICASE_INI} 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT



## ALL ASS  INI

NSTEP=${NJOB}_330
#-----------------------------------------------------------------------------
LIBEL="MERGE  AE INI ASS and RETRO PROP Contracts  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_310_${IB}_EPOSOCI_ASS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS.dat  2000 1"
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
        RETUW_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT


NSTEP=${NJOB}_340
#-----------------------------------------------------------------------------
LIBEL="Extract AE for INI Contracts ASS "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_330_${IB}_EPOSOCI_ASS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 49:,
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
/INFILE ${ESF_IADPERICASE_INI} 2000 1 "~"
/joinkeys 
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

NSTEP=${NJOB}_350
#-----------------------------------------------------------------------------
LIBEL="MERGE  AE INI ASS and RETRO Contracts  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_340_${IB}_EPOSOCI_ASS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_323_${IB}_EPOSOCI_RETPROP.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_325_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EPOSOCI_EBS_INI_O.dat 2000 1"
##SORT_O="${ESF_EPOSOCI_INI}  2000 1"
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
        RETUW_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

## REMOVE AE WHERE PRS = 751 AND 

NSTEP=${NJOB}_355
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Generate  ESF_EPOSOCI_INI : FILTER ON PRS 751 AND ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_350_${IB}_SORT_EPOSOCI_EBS_INI_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EPOSOCI_EBS_INI_O.dat 2000 1"
##SORT_O="${ESF_EPOSOCI_INI} 2000 1"
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
        PRS_CF_F2              1:1  - 1:,
        ACMTRS_NT_F2           2:1  - 2:,        
        DETTRS_CF_F2           3:1  - 3:,
        all_cols_F1            1:1  - 49:
/joinkeys
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_13_${IB}_FTRSLNK_TRNCOD_EBS_INI.dat 500 1 "~"
/joinkeys
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:all_cols_F1
        ,rightside:PRS_CF_F2
        ,rightside:ACMTRS_NT_F2
exit
EOF
SORT



NSTEP=${NJOB}_360
# Sort ${DFILT}/${NSTEP}_${IB}_SORT_EPOSOCI_EBS_INI_O.dat
#-----------------------------------------------------------------------------
LIBEL="Current GTR File Sort, Filter INI..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_355_${IB}_SORT_EPOSOCI_EBS_INI_O.dat 2000 1" 
SORT_O="${ESF_EPOSOCI_INI} 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							  1:1 - 1:,
					ESB_CF 				      2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			      6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				      8:1 - 8:,
					END_NT 				      9:1 - 9:,
					SEC_NF 				      10:1 - 10:,
					UWY_NF 				      11:1 - 11:,
					UW_NT 					  12:1 - 12:,
					OCCYEA_NF 			      13:1 - 13:,
					ACY_NF 				      14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				      17:1 - 17:,
					CUR_CF 				      18:1 - 18:,
					AMT_M 					  19:1 - 19: EN 15/3,
					CED_NF 				      20:1 - 20:,
					BRK_NF 				      21:1 - 21:,
					PAY_NF 				      22:1 - 22:,
					KEY_NF 				      23:1 - 23:,
					RETCTR_NF 			      24:1 - 24:,
					RETEND_NT 			      25:1 - 25:,
					RETSEC_NF 			      26:1 - 26:,
					RETRTY_NF 				  27:1 - 27:,
					RETUW_NT 			      28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			      30:1 - 30:,
					RETSCOSTRMTH_NF           31:1 - 31:,
					RETSCOENDMTH_NF           32:1 - 32:,
					RCL_NF 				      33:1 - 33:,
					RETCUR_CF 			      34:1 - 34:,
					RETAMT_M 			      35:1 - 35: EN 15/3,
                    all_cols_F1               1:1  - 49:,
                    PRS_CF_F2                 50:1 - 50:,
        	        ACMTRS_NT_F2              51:1 - 51:      	
/CONDITION  IS_PRS_EBS_INI ( PRS_CF_F2 = "740"  and ACMTRS_NT_F2 = "101")   
/OUTFILE ${SORT_O} overwrite
/INCLUDE IS_PRS_EBS_INI 
/REFORMAT  all_cols_F1  
exit
EOF
SORT


##[004] Remove AE INI FROM AE EBS STD file

NSTEP=${NJOB}_370
#------------------------------------------------------------------------------
LIBEL=" SORT AE ALL  ON TRN_NT  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_EPOSOCI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_EPOSOCI_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	TRN_NT 43:1 - 43:
/KEYS TRN_NT
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT



NSTEP=${NJOB}_380
#------------------------------------------------------------------------------
LIBEL=" SORT AE INI ON TRN_NT  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_EPOSOCI_INI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_EPOSOCI_INI_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	TRN_NT 43:1 - 43:
/KEYS TRN_NT 
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT



NSTEP=${NJOB}_390
#-----------------------------------------------------------------------------
LIBEL="get TRN_NT-INI not in TRN_NT ALL STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_EPOSOCI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_EPOSOCI_NOT_INI_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		TRN_NT       43:1 - 43:,
		ALL_FIELDS   1:1 - 49:,        
		TRN_NT_INI 43:1 - 43:		
/joinkeys
        TRN_NT
/INFILE ${ESF_EPOSOCI_INI} 2000 1 "~"
/joinkeys
        TRN_NT_INI
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT ALL_FIELDS
exit
EOF
SORT


NSTEP=${NJOB}_400
#-----------------------------------------------------------------------------
LIBEL="UPDATE ESF_EPOSOCI WITH ONLY NOT EBS INI"
EXECKSH "cp ${DFILT}/${NJOB}_390_${IB}_SORT_ESF_EPOSOCI_NOT_INI_O.dat ${ESF_EPOSOCI} "



JOBEND
