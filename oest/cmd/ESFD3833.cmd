#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 08.01 : Merge cashflow and discount files
# Nom du script SHELL           : ESFD3831.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 15/04/2019
# Auteur                        : Linh.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# Merge cashflow and discount files
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
#       <indice>        <jj/mm/aaaa>    <auteur>        <spira>                 <description de la modification>
# [001]		05/04/2020      Linh DOAN  85506			 Split merge ini and std
# [002]	 22/06/2020      Linh DOAN  87717			 Remove UWD in merge
# [003]  30/06/2020      Linh DOAN  87717			 Remove force Norm
#	[004]  26/08/2020      Linh DOAN  87660                     Analyse ICR missing for Inception
#	[005]  09/12/2020      JYP        90275                     add ICR 3202 for Inception
# [006]  19/02/2021      Linh DOAN  85522 			technical cashflow flux
# [007]  23/03/2022      MZM        85522 			Ajout Parenthses criteres extractions ONEROUS
# [008]  04/05/2022      HR        103942 			I17G- CSF/ALLNO should be loaded
# [009]	05/07/2022			JBD		SPIRA : 104778 Build new closing for I17S norm 
# [010]	05/01/2023			HR		SPIRA : 107754 IME I17 - Incorrect ratio applied for future positions 
# [011] 10/01/2023      DAD      102482         remove condition

#====================================================================================================
#set -x




# all generic functions
. ${DUTI}/fctgen.cmd

#IDF_CT=I17G_SII_MRG et  I17G_SII_MRG 

CLODAT_D=${PARM_ICLODAT_D}



ECHO_LOG ""                                                                                     >>$FLOG
ECHO_LOG "#....................... INPUT ..........................................."           >>$FLOG
ECHO_LOG "#===> CLODAT_D.............................: ${CLODAT_D} "                            >>$FLOG
ECHO_LOG "#===> NORME_CF.............................: ${NORME_CF} "                            >>$FLOG

ECHO_LOG "#===> ESF_GTSII_GLOBAL_CASHFLOW ...........: ${ESF_GTSII_GLOBAL_CASHFLOW} "       >>$FLOG
ECHO_LOG "#===> ESF_GTSII_ESCOMPTE_LKI ..............: ${ESF_GTSII_ESCOMPTE_LKI} "          >>$FLOG
ECHO_LOG "#===> ESF_GTSII_CASHFLOW_RAD_CKI ..........: ${ESF_GTSII_CASHFLOW_RAD_CKI} "      >>$FLOG

ECHO_LOG "#===> ESF_GTSII_ESCOMPTE_DSI...............: ${ESF_GTSII_ESCOMPTE_DSI} "          >>$FLOG

ECHO_LOG "#===> ESF_GTSII_ESCOMPTE_FWD...............: ${ESF_GTSII_ESCOMPTE_FWD} "          >>$FLOG

ECHO_LOG "#===> ESF_GTSII_IFRS17_REVENUE.............: ${ESF_GTSII_IFRS17_REVENUE} "            >>$FLOG
ECHO_LOG "#===> ESF_GTSII_IFRS17_CSM.................: ${ESF_GTSII_IFRS17_CSM} "                >>$FLOG
ECHO_LOG "#===> ESF_GTSII_CSM_CASHFLOW...............: ${ESF_GTSII_CSM_CASHFLOW} "              >>$FLOG
ECHO_LOG "#===> ESF_GTSII_ICR  ......................: ${ESF_GTSII_ICR} "              >>$FLOG

ECHO_LOG "#===> ESF_GTSII_CASHFLOW_RAP_CKI ..........: ${ESF_GTSII_CASHFLOW_RAP_CKI} "      >>$FLOG

ECHO_LOG "#....................... OUTPUT ..........................................."          >>$FLOG
ECHO_LOG "#===> ESF_GTSII_CASHFLOW ......................: ${ESF_GTSII_CASHFLOW}" 			>>$FLOG
ECHO_LOG "#========================================================================="           >>$FLOG



# Job Initialisation
JOBINIT


NSTEP=${NJOB}_01
#------------------------------------------------------------------------------------
LIBEL="MANAGE UNFOUND FILES "



if [ ! -f ${ESF_GTSII_GLOBAL_CASHFLOW} ]
then
        ECHO_LOG "ESF_GTSII_GLOBAL_CASHFLOW=${ESF_GTSII_GLOBAL_CASHFLOW}  does not exist, take an empty file"     >> $FLOG
        EXECKSH "touch ${ESF_GTSII_GLOBAL_CASHFLOW}"
fi


if [ ! -f ${ESF_GTSII_ESCOMPTE_DSI} ]
then
        ECHO_LOG "ESF_GTSII_ESCOMPTE_DSI=${ESF_GTSII_ESCOMPTE_DSI}  does not exist, take an empty file"            >> $FLOG
	EXECKSH "touch ${ESF_GTSII_ESCOMPTE_DSI}"

fi


if [ ! -f ${ESF_GTSII_ESCOMPTE_LKI} ]
then
        ECHO_LOG "ESF_GTSII_ESCOMPTE_LKI=${ESF_GTSII_ESCOMPTE_LKI}  does not exist, take an empty file"            >> $FLOG
	EXECKSH "touch ${ESF_GTSII_ESCOMPTE_LKI}"
fi

if [ ! -f ${ESF_GTSII_CASHFLOW_RAD_CUR} ]
then
        ECHO_LOG "ESF_GTSII_CASHFLOW_RAD_CUR=${ESF_GTSII_CASHFLOW_RAD_CUR}  does not exist, take an empty file"    >> $FLOG
        EXECKSH "touch ${ESF_GTSII_CASHFLOW_RAD_CUR}"

fi


if [ ! -f ${ESF_GTSII_CASHFLOW_RAD_CKI} ]
then
        ECHO_LOG "ESF_GTSII_CASHFLOW_RAD_CKI=${ESF_GTSII_CASHFLOW_RAD_CKI}  does not exist, take an empty file"    >> $FLOG
        EXECKSH "touch ${ESF_GTSII_CASHFLOW_RAD_CKI}"

fi

if [ ! -f ${ESF_GTSII_ESCOMPTE_RAD_DSI} ]
then
        ECHO_LOG "ESF_GTSII_ESCOMPTE_RAD_DSI=${ESF_GTSII_ESCOMPTE_RAD_DSI}  does not exist, take an empty file"              >> $FLOG
        EXECKSH "touch ${ESF_GTSII_ESCOMPTE_RAD_DSI}"

fi

#ESF_GTSII_ESCOMPTE_RAD_LKI
if [ ! -f ${ESF_GTSII_ESCOMPTE_RAD_LKI} ]
then
        ECHO_LOG "ESF_GTSII_ESCOMPTE_RAD_LKI=${ESF_GTSII_ESCOMPTE_RAD_LKI}  does not exist, take an empty file"              >> $FLOG
        EXECKSH "touch ${ESF_GTSII_ESCOMPTE_RAD_LKI}"

fi


if [ ! -f ${ESF_GTSII_ESCOMPTE_FWD} ]
then
        ECHO_LOG "ESF_GTSII_ESCOMPTE_FWD=${ESF_GTSII_ESCOMPTE_FWD}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_ESCOMPTE_FWD}"

fi

if [ ! -f ${ESF_GTSII_IFRS17_REVENUE} ]
then
        ECHO_LOG "ESF_GTSII_IFRS17_REVENUE=${ESF_GTSII_IFRS17_REVENUE}  does not exist, take an empty file"   >> $FLOG
        EXECKSH "touch ${ESF_GTSII_IFRS17_REVENUE}"

fi


if [ ! -f ${ESF_GTSII_IFRS17_CSM} ]
then
        ECHO_LOG "ESF_GTSII_IFRS17_CSM=${ESF_GTSII_IFRS17_CSM}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_IFRS17_CSM}"

fi


if [ ! -f ${ESF_GTSII_IFRS17_CSM_ESCOMPTE} ]
then
        ECHO_LOG "ESF_GTSII_IFRS17_CSM_ESCOMPTE=${ESF_GTSII_IFRS17_CSM_ESCOMPTE}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_IFRS17_CSM_ESCOMPTE}"

fi


if [ ! -f ${ESF_GTSII_CSM_CASHFLOW} ]
then
        ECHO_LOG "ESF_GTSII_CSM_CASHFLOW=${ESF_GTSII_CSM_CASHFLOW}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_CSM_CASHFLOW}"

fi


#ESF_GTSII_CLACC_CASHFLOW
if [ ! -f ${ESF_GTSII_CLACC_CASHFLOW} ]
then
        ECHO_LOG "ESF_GTSII_CLACC_CASHFLOW=${ESF_GTSII_CLACC_CASHFLOW}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_CLACC_CASHFLOW}"

fi

#ESF_GTSII_REMAINTOPAY_ULAE
if [ ! -f ${ESF_GTSII_REMAINTOPAY_ULAE} ]
then
        ECHO_LOG "ESF_GTSII_REMAINTOPAY_ULAE=${ESF_GTSII_REMAINTOPAY_ULAE}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_REMAINTOPAY_ULAE}"

fi


if [ ! -f ${ESF_GTSII_ICR} ]
then
        ECHO_LOG "ESF_GTSII_ICR=${ESF_GTSII_ICR}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_ICR}"

fi



if [ ! -f ${ESF_GTSII_CASHFLOW_RAP_CKI} ]
then
        ECHO_LOG "ESF_GTSII_CASHFLOW_RAP_CKI=${ESF_GTSII_CASHFLOW_RAP_CKI}  does not exist, take an empty file"    >> $FLOG
        EXECKSH "touch ${ESF_GTSII_CASHFLOW_RAP_CKI}"

fi


#[008]
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="Cashflow selection"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_GLOBAL_CASHFLOW} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_CASHFLOW.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
		ACMTRS_NT        42:1 - 42:,
        NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:3,
        PATTYP_CT        53:1 - 53:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION COND_MAINTEXPCSF (( PATCAT_CT = "CSF" and ( NORME_CF = "${NORME_CF}" or ((("${NORME_CF}"="I17G") or ("${NORME_CF}"="I17S")) and NORME_CF = "ALLNO" and ACMTRS_NT="221") )) or "${CONTEXT_CT}" != "STD" )

/OUTFILE ${SORT_O}
/INCLUDE COND_MAINTEXPCSF
exit
EOF
SORT

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------------
LIBEL="Selection ICR INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_ICR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ICR.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
	ACMTRS_NT        42:1 - 42:,
	ACMTRS3_NT       124:1 - 124:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION ICR_INI (ACMTRS_NT="320" and ( ACMTRS3_NT="3201" OR ACMTRS3_NT="3202" ) )
/OUTFILE ${SORT_O} 
/INCLUDE ICR_INI
exit
EOF
SORT


NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="Merge with other files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_ESCOMPTE_DSI} 2000 1"
SORT_I2="${ESF_GTSII_ESCOMPTE_LKI} 2000 1"
SORT_I3="${ESF_GTSII_CASHFLOW_RAD_CUR} 2000 1"
SORT_I4="${ESF_GTSII_CASHFLOW_RAD_CKI} 2000 1"
SORT_I5="${ESF_GTSII_ESCOMPTE_RAD_DSI} 2000 1"
SORT_I6="${ESF_GTSII_ESCOMPTE_RAD_LKI} 2000 1"
SORT_I7="${ESF_GTSII_ESCOMPTE_FWD} 2000 1"
SORT_I8="${ESF_GTSII_IFRS17_REVENUE} 2000 1"
SORT_I9="${ESF_GTSII_IFRS17_CSM} 2000 1"
SORT_I10="${ESF_GTSII_CSM_CASHFLOW} 2000 1"
SORT_I11="${ESF_GTSII_IFRS17_CSM_ESCOMPTE} 2000 1"
SORT_I12="${ESF_GTSII_CLACC_CASHFLOW} 2000 1"
SORT_I13="${ESF_GTSII_REMAINTOPAY_ULAE} 2000 1"
SORT_I14="${DFILT}/${NJOB}_15_${IB}_SORT_GTSII_ICR.dat 2000 1"
SORT_I15="${DFILT}/${NJOB}_10_${IB}_SORT_GTSII_CASHFLOW.dat 2000 1"
SORT_I16="${ESF_GTSII_CASHFLOW_RAP_CKI} 2000 1"
SORT_O="${ESF_GTSII_CASHFLOW} 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT



NSTEP=${NJOB}_30
#------------------------------------------------------------------------------------
LIBEL="sort SECIFRS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FSECIFRS} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FSECIFRS.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            1:1 - 1:,
        END_NT            4:1 - 4:EN,
        SEC_NF            5:1 - 5:EN,
        UWY_NF            2:1 - 2:,
        UW_NT             3:1 - 3:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT

/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------------
LIBEL="Pericase INI + SECIFRS join"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADPERICASE_INI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_SECIFRS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:,
        PER_CTRINC_D     19:1 - 19:,
        PER_CTRSTS_CT    99:1 - 99:EN,
        PER_ALL          1:1 - 206:,
        SECIFRS_ALL      6:1 - 36:,
        CTR_NF           1:1 - 1:,
        END_NT           4:1 - 4:,
        SEC_NF           5:1 - 5:,
        UWY_NF           2:1 - 2:,
        UW_NT            3:1 - 3:
/JOINKEYS   PER_CTR_NF,
        PER_END_NT,
        PER_SEC_NF,
        PER_UWY_NF,
        PER_UW_NT
/INFILE ${DFILT}/${NJOB}_30_${IB}_SORT_FSECIFRS.dat  2000 1 "~"
/JOINKEYS   CTR_NF,
            END_NT,
            SEC_NF,
            UWY_NF,
            UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : PER_ALL, rightside : SECIFRS_ALL
exit
EOF
SORT


NSTEP=${NJOB}_50
# [003] Tri EST_IADPERICASE_INI : ONLY profitable contracts
# [004] Tri EST_IADPERICASE_INI : ONLY ONEROUS contracts
#-----------------------------------------------------------------------------
LIBEL="Sort EST_IADPERICASE_INI with "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_IADPERICASE_SECIFRS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_INI_PROFITABLE_O.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_ONE_FUT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        PER_CTR_NF              3:1 - 3:,
        PER_END_NT              4:1 - 4:,
        PER_SEC_NF              5:1 - 5:,
        PER_UWY_NF              6:1 - 6:,
        PER_UW_NT               7:1 - 7:,
        PER_CTRINC_D           19:1 - 19:,        
        GRPINIPRO_CF     219:1 - 219:EN,
        PARINIPRO_CF     224:1 - 224:EN,
        LOCINIPRO_CF     229:1 - 229:EN

/KEYS 
	PER_CTR_NF,
	PER_END_NT,
	PER_SEC_NF,
	PER_UWY_NF,
	PER_UW_NT
/CONDITION PROFITABLE ((GRPINIPRO_CF > 1  AND (("${NORME}" = "I17G") OR ("${NORME_CF}"="I17S"))) OR (PARINIPRO_CF > 1 AND "${NORME}" = "I17P") OR (LOCINIPRO_CF > 1 AND "${NORME}" = "I17L")) AND (PER_CTRINC_D > "${CLODAT_D}" )
/CONDITION ONEROUS ((GRPINIPRO_CF = 1 AND (("${NORME}" = "I17G") OR ("${NORME_CF}"="I17S"))) OR (PARINIPRO_CF = 1 AND "${NORME}" = "I17P") OR (LOCINIPRO_CF = 1 AND "${NORME}" = "I17L")) AND (PER_CTRINC_D > "${CLODAT_D}" )
/OUTFILE ${SORT_O}
/INCLUDE PROFITABLE
/OUTFILE ${SORT_O2}
/INCLUDE ONEROUS
exit
EOF
SORT


# [007] Ajout Parentheses sur criteres d'extractions ONEROUS
# [011] remove condition and ( CTRSTS_CT=14 or CTRSTS_CT=16 or CTRSTS_CT=17 or CTRSTS_CT=19) )
NSTEP=${NJOB}_50
#------------------------------------------------------------------------------------
LIBEL="Pericase  INI oronous future"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_IADPERICASE_SECIFRS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_ONE_FUT.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           3:1 - 3:,
        END_NT           4:1 - 4:,
        SEC_NF           5:1 - 5:,
        UWY_NF           6:1 - 6:,
        UW_NT            7:1 - 7:,
        CTRINC_D     19:1 - 19:,
        CTRSTS_CT    99:1 - 99:EN,
        GRPFIRCLO_D      216:1 - 216:,
        PARFIRCLO_D      221:1 - 221:,
        LOCFIRCLO_D      226:1 - 226:,
        GRPINISTS_CT     234:1 - 234:EN,
        PARINISTS_CT     235:1 - 235:EN,
        LOCINISTS_CT     236:1 - 236:EN,
        GRPINIPRO_CF     219:1 - 219:,
        PARINIPRO_CF     224:1 - 224:,
        LOCINIPRO_CF     229:1 - 229:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION COND_ONE_FUT ( (("${NORME_CF}" = "I17G") or ("${NORME_CF}" = "I17S")) and ( GRPFIRCLO_D = "" or  GRPINISTS_CT = 1) and ( CTRINC_D > "${CLODAT_D}") and  (GRPINIPRO_CF = "1") )    
        or ( ("${NORME_CF}" = "I17L") and ( LOCFIRCLO_D = "" or  LOCINISTS_CT = 1 ) and ( CTRINC_D > "${CLODAT_D}") and (LOCINIPRO_CF = "1") )
        or ( ("${NORME_CF}" = "I17P")  and ( PARFIRCLO_D = "" or  PARINISTS_CT = 1 ) and ( CTRINC_D > "${CLODAT_D}")  and  (PARINIPRO_CF = "1") ) 
/OUTFILE ${SORT_O}
/INCLUDE COND_ONE_FUT
exit
EOF
SORT



NSTEP=${NJOB}_60
#------------------------------------------------------------------------------------
LIBEL="Merge with other files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_CASHFLOW} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_CSF.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
	NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:3,
        PATTYP_CT        53:1 - 53:

/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION COND_CSF ( PATCAT_CT = "CSF")
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_CSF
exit
EOF
SORT


NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="Extract de DUMMY Contracts dans GTSII INI et sortie GTSII STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_GTSII_CSF.dat 2000 1"
SORT_O="${ESF_GTSII_DUMMY_STD} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 124:,
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
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT


#[010] filtering INF 3115
NSTEP=${NJOB}_75
#------------------------------------------------------------------------------------
LIBEL="Merge with other files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_GTSII_CSF.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_CSF.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
	NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:3,
        PATTYP_CT        53:1 - 53:,
        ACMTRS3_NT      124:1 - 124:

/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION COND1 ( PATTYP_CT != "INF" OR ACMTRS3_NT != "3115")
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND1
exit
EOF
SORT


NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Extract de ONEROUS Future Contracts dans GTSII INI et sortie GTSII STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_SORT_GTSII_CSF.dat 2000 1"
SORT_O="${ESF_GTSII_ONE_STD} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 124:,
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
/INFILE "${DFILT}/${NJOB}_50_${IB}_SORT_IADPERICASE_ONE_FUT.dat" 2000 1 "~"
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

JOBEND
