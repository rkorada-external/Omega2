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
# 	[001]		05/04/2020      Linh DOAN      85506			 Split merge ini and std
#       [002]	        22/06/2020      Linh DOAN      87717			 Remove UWD in merge
#       [003]           30/06/2020      Linh DOAN      87717			 Remove force Norm
#	[004]           26/08/2020      Linh DOAN      87660                     Analyse ICR missing for Inception
#	[005]           09/12/2020      JYP            90275                     add ICR 3202 for Inception
# 	[006]           11/02/2021      Linh DOAN      91994                     fix norme bug
# [007]  04/05/2022      HR        103942 			I17G- CSF/ALLNO should be loaded
#[008] 05/07/2022	JBD	SPIRA : 104778 Build new closing for I17S norm 
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

ECHO_LOG "#===> ESF_GTSII_CASHFLOW_RAP_CUR ..........: ${ESF_GTSII_CASHFLOW_RAP_CUR} "      >>$FLOG

ECHO_LOG "#....................... OUTPUT ..........................................."          >>$FLOG
ECHO_LOG "#===> ESF_GTSII_CASHFLOW ......................: ${ESF_GTSII_CASHFLOW}" 			>>$FLOG
ECHO_LOG "#========================================================================="           >>$FLOG



# Job Initialisation
JOBINIT


NSTEP=${NJOB}_01
#------------------------------------------------------------------------------------
LIBEL="MANAGE UNFOUND FILES "

if [ ! -f ${ESF_GTSII_CASHFLOW_RAP_CUR} ]
then
        ECHO_LOG "ESF_GTSII_CASHFLOW_RAP_CUR=${ESF_GTSII_CASHFLOW_RAP_CUR}  does not exist, take an empty file"     >> $FLOG
        EXECKSH "touch ${ESF_GTSII_CASHFLOW_RAP_CUR}"
fi

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

#[007]
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
/CONDITION COND_MAINTEXPCSF (( PATCAT_CT = "CSF" and (NORME_CF = "${NORME_CF}" or ((("${NORME_CF}"="I17G") or ("${NORME_CF}"="I17S"))  and NORME_CF = "ALLNO" and ACMTRS_NT="221")) ) or "${CONTEXT_CT}" != "STD" )

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
SORT_I16="${ESF_GTSII_CASHFLOW_RAP_CUR} 2000 1"
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


JOBEND
