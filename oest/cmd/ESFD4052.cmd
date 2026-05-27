#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 EAGREGATION PAR CSUE
# nom du script SHELL           : ESFD4051.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 06/01/2022
# auteur                        : M.NAJI

# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Impact closing (agrégation par CSUOE des mouvements indépendant de la norme)
#   Generation d un Fichier ITD et d un fichier QUATERLY
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[01] 11/01/2021 : MZM : SPIRA 91531 : MAJ MAPPING
#[02] 14/01/2021 : MZM : SPIRA 89923 : Numero PLC_NT et RTO : Ajustements
#[03] 28/01/2021 : MZM : SPIRA 89923 : LOB_CF != "30" et != "31"
#[04] 29/01/2021 : MZM : SPIRA 93608 : Agregation file - Issue with ITD calculation
#[05] 02/02/2021 : MZM : SPIRA 93580 : Align retro and assumed regarding input files : Agregation file - Assume Pericase with Segmentation data
#[06] 05/02/2021 : MZM : SPIRA 93580 : Update Field ACMAMT_M with RETAMT_M if TYP_CT = 'R' with AMT_M it TYP_CT ='A'
#[06] 29/03/2021 : MZM : SPIRA 89923 : Exclusion des LOB 30, 31 des Pericases, ensuite jointure 1 A 1 avec les fichiers ITD et MVT
#[07] 04/05/2021 : MZM : SPIRA 96034 : Condition ITD (Balance sheet year = Closing year AND Balance sheet Month <= Closing Month) for UPR grouping 1030 le fichier ITD 
#[08] 19/05/2021 : MZM : SPIRA 91111 : Condition MVT  (  ( "12" CT TRNCOD1_CF) AND ("7" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF) ))  le fichier MVT 
#[09] 08/06/2021 : MZM : SPIRA 91111 : Correction Regression sur la generation de PLC_NT et RTO 
#[10] 22/09/2021 : MZM : SPIRA 97033 : Condition ITD (Balance sheet year = Closing year AND Balance sheet Month <= Closing Month) for  grouping ACMTRS2_NT 303 and ACMTRS2_NT 307 le fichier ITD 
#[11] 17/03/2022 : MZM : SPIRA 103016 : Ajout des fichiers de Rejet et des OPNG
#[12] 28/09/2022 : MNAJI : SPIRA 86795 : Agrégation de FTCLEDA hors ESTIM 0 et 1
#[13] 14/12/2022 : MNAJI : SPIRA 108224 EGPI_R2 ratio wrong on INT 
#[14] 16/02/2023 : MZM : SPIRA 108551 ESFD4020 : add EBS previous quarter transactions + EBS cancellation file : Desactivation Input Opening et Activation sur entree du 4020 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


# Job Initialisation
JOBINIT


ICLODAT_D=$1

ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`

PREV_ICLODAT_YEA=`echo "${PARM_PREV_ICLODAT_D}" | awk '{print substr($0,1,4)}'`
PREV_ICLODAT_MTH=`echo "${PARM_PREV_ICLODAT_D}" | awk '{print substr($0,5,2)}'`

SYNCSORT_ICLODAT=`echo "${PARM_ICLODAT_D}" | awk  '{ printf "%s~%s~%s~",substr($1,1,4),substr($1,5,2),substr($1,7,2)}'`
SYNCSORT_PREV_ICLODAT=`echo "${PARM_PREV_ICLODAT_D}"  | awk  '{ printf "%s~%s~%s~",substr($1,1,4),substr($1,5,2),substr($1,7,2)}'`



ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ICLODAT_D .................: $ICLODAT_D "
ECHO_LOG "#===> ICLODAT_3MOIS_A ...........: $ICLODAT_3MOIS_A  "
ECHO_LOG "#===> ICLODAT_3MOIS_M ...........: $ICLODAT_3MOIS_M  "
ECHO_LOG "#===> ICLODAT_3MOIS_J ...........: $ICLODAT_3MOIS_J  "
ECHO_LOG "#===> PREV_ICLODAT_YEA ...........: $PREV_ICLODAT_YEA  "
ECHO_LOG "#===> PREV_ICLODAT_MTH ...........: $PREV_ICLODAT_MTH  "
ECHO_LOG "#===> SYNCSORT_ICLODAT ...........: $SYNCSORT_ICLODAT  "
ECHO_LOG "#===> SYNCSORT_PREV_ICLODAT ......: $SYNCSORT_PREV_ICLODAT  "
ECHO_LOG "#========================================================================="

## [11] Prise en compte des fichiers de REJETS EBS et des OPENING EBS, RETRO et ASSUMES

# SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_A_AR_REJ_OPNG.dat 1000 1"  


NSTEP=${NJOB}_00
# Extend FTECLEDA with FBOPRSLNK:ESTIM_NT
#-----------------------------------------------------------------------------
LIBEL="Extend FTECLEDA with FBOPRSLNK:ESTIM_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GT_A_AR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GT_A_AR_WITH_ESTIM_SORT_O.dat" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        TRNCOD_CF                   6:1 -  6:,
		FBOPRSLNK_DETTRS_CF       	9:1 -  9:,
		FBOPRSLNK_ESTIM_NT 			13:1 -  13:EN,
		all_cols					1:1 - 118:
/joinkeys
       TRNCOD_CF
/INFILE "${EST_FBOPRSLNK_TXT}" 1000 1 "~"
/joinkeys
       FBOPRSLNK_DETTRS_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	leftside:all_cols,
	rightside:FBOPRSLNK_ESTIM_NT
exit
EOF
SORT


NSTEP=${NJOB}_01
# SPLIT FTECLEDA  on ( ESTIM_NTin (0,1)  and the other
#-----------------------------------------------------------------------------
LIBEL="SPLIT FTECLEDA  on ( ESTIM_NTin (0,1)  and the other"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_00_${IB}_GT_A_AR_WITH_ESTIM_SORT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GT_A_AR_WITH_ESTIM_1-2.dat 1000 1" 
SORT_O2="${DFILT}/${NSTEP}_${IB}_GT_A_AR_WITHOUT_ESTIM_TOSUM.dat 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
		all_cols	1:1 - 118:,
		ESTIM_NT	119:1 -  119:EN
/CONDITION RESTRICTION ESTIM_NT EQ 0 OR ESTIM_NT EQ 1
/OUTFILE  ${SORT_O} OVERWRITE
/INCLUDE RESTRICTION
/REFORMAT all_cols
/OUTFILE  ${SORT_O2} OVERWRITE
/OMIT RESTRICTION
exit
EOF
SORT

NSTEP=${NJOB}_02
# SUM not  ( ESTIM_NTin (0,1)
#-----------------------------------------------------------------------------
# à voir cette condition :
#/CONDITION RESTRICTION  (AMT_M GT 0.1 OR AMT_M LT -0.1) OR (RETAMT_M GT 0.1 OR RETAMT_M LT -0.1) OR (RETINTAMT_M GT 0.1 OR RETINTAMT_M LT -0.1)
LIBEL="SUM not  ( ESTIM_NTin (0,1)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01_${IB}_GT_A_AR_WITHOUT_ESTIM_TOSUM.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GT_A_AR_WITHOUT_ESTIM_SUM.dat 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF				1:1 -  1:,	
	ESB_CF              2:1 -  2:,
	BALSHEY_NF          3:1 -  3:EN,       
	BALSHRMTH_NF        4:1 -  4:EN,
	BALSHRDAY_NF        5:1 -  5:EN,
	TRNCOD_CF           6:1 -  6:,
	DBLTRNCOD_CF      	7:1 -  7:,
	CTR_NF              8:1 -  8:,
	END_NT              9:1 -  9:,
	SEC_NF              10:1 -  10:,
	UWY_NF              11:1 -  11:,
	UW_NT               12:1 -  12:,
	OCCYEA_NF           13:1 -  13:,
	ACY_NF              14:1 -  14:,
	SCOSTRMTH_NF        15:1 -  15:,
	SCOENDMTH_NF        16:1 -  16:,
	CLM_NF              17:1 -  17:,
	CUR_CF              18:1 -  18:,
	COL6-18				6:1 -  18:,
	AMT_M               19:1 -  19:EN 15/3,
	COL20-23			20:1 -  23:,
	RETCTR_NF           24:1 -  24:,
	RETEND_NT           25:1 -  25:,
	RETSEC_NF           26:1 -  26:,
	RETRTY_NF           27:1 -  27:,
	RETUW_NT            28:1 -  28:,
	RETOCCYEA_NF        29:1 -  29:,
	RETACY_NF           30:1 -  30:,
	RETSCOSTRMTH_NF  	31:1 - 31:EN,
	RETSCOENDMTH_NF  	32:1 - 32:EN,
	RCL_NF              33:1 -  33:,
	RETCUR_CF           34:1 -  34:,
	COL20-34			20:1 -  34:,
	RETAMT_M            35:1 -  35:EN 15/3,
	LOBACC_CF           45:1 -  45:,
	LOBRET_CF           46:1 -  46:,
	COL36-87			36:1 -  87:,
	RETINTAMT_M         88:1 -  88:EN 15/3,
	COL89-119			89:1 -  119:
/KEYS   
	SSD_CF,
	ESB_CF,
	NEW_ICLODAT,
	TRNCOD_CF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	OCCYEA_NF,
	ACY_NF,
	SCOSTRMTH_NF ,
	SCOENDMTH_NF ,
	CLM_NF,
	CUR_CF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RETRTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
    RETSCOENDMTH_NF,
	RCL_NF,
	RETCUR_CF,
	LOBACC_CF,
	LOBRET_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/CONDITION COND_PREV_ICLODAT  (BALSHEY_NF > ${PREV_ICLODAT_YEA} ) OR ( BALSHEY_NF = ${PREV_ICLODAT_YEA} AND BALSHRMTH_NF  > ${PREV_ICLODAT_MTH}  )
/DERIVEDFIELD  NEW_ICLODAT if COND_PREV_ICLODAT then "${SYNCSORT_ICLODAT}"  else "${SYNCSORT_PREV_ICLODAT}" 
/DERIVEDFIELD  SCOSTRMTH_NF_NEW if COND_PREV_ICLODAT then SCOSTRMTH_NF  else "${PREV_ICLODAT_MTH}" 
/DERIVEDFIELD  SCOENDMTH_NF_NEW if COND_PREV_ICLODAT then SCOENDMTH_NF  else "${PREV_ICLODAT_MTH}" 
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION RESTRICTION AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0
/OUTFILE  ${SORT_O} OVERWRITE
/INCLUDE RESTRICTION
/REFORMAT 
	SSD_CF,
	ESB_CF,
	NEW_ICLODAT,
	TRNCOD_CF           ,
	DBLTRNCOD_CF        ,
	CTR_NF              ,
	END_NT              ,
	SEC_NF              ,
	UWY_NF              ,
	UW_NT               ,
	OCCYEA_NF           ,
	ACY_NF              ,
	SCOSTRMTH_NF    	,
	SCOENDMTH_NF   		,
	CLM_NF              ,
	CUR_CF              ,
	AMT_M               ,
	COL20-23            ,
	RETCTR_NF           ,
	RETEND_NT           ,
	RETSEC_NF           ,
	RETRTY_NF           ,
	RETUW_NT            ,
	RETOCCYEA_NF        ,
	RETACY_NF           ,
	RETSCOSTRMTH_NF ,
	RETSCOENDMTH_NF	 ,
	RCL_NF              ,
	RETCUR_CF           ,
	RETAMT_M            ,
	COL36-87			,
	RETINTAMT_MC        ,
	COL89-119		

exit
EOF
SORT


#[14] Begin


if [ "${IDF_CT}" = "EBS_ESFD4050_TECLEDA" ] || [ "${IDF_CT}" = "I17G_ESFD4050_TECLEDA" ] || [ "${IDF_CT}" = "I17S_ESFD4050_TECLEDA" ]
then

NSTEP=${NJOB}_03
# Fusion du Fichier FTECLEDR et des fichiers de REJETS EBS et celui des OPENING EBS ASUME
#-----------------------------------------------------------------------------
LIBEL="MERGE FTECLEDA with ESF_FTECLEDR_REJ and ESF_OPNG_ASSUMED"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_GT_A_AR} 1000 1"
SORT_I="${DFILT}/${NJOB}_02_${IB}_GT_A_AR_WITHOUT_ESTIM_SUM.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_01_${IB}_GT_A_AR_WITH_ESTIM_1-2.dat 1000 1"
SORT_O="${ESF_FTECLEDA_REJ_OPNG} 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,       
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:
exit
EOF
SORT


NSTEP=${NJOB}_04
# Fusion du Fichier FTECLEDA et des fichiers de REJETS EBS et celui des OPENING EBS ASUME
#-----------------------------------------------------------------------------
LIBEL="MERGE FTECLEDA with ESF_FTECLEDR_REJ and ESF_OPNG_ASSUMED AND PREVIOUS CURGTA FOR ESFD4020"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_REJ_OPNG} 1000 1"
SORT_I2="${ESF_FTECLEDA_REJ} 1000 1"
SORT_I3="${ESF_OPNG_EBS_ASS} 1000 1"
SORT_I4="${ESF_CURGTA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_REJ_OPNG_4020.dat 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,       
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:
exit
EOF
SORT


## [14] Desactivation des fichiers de Rejet et OPNG RETRO (Non utilisés en entrée du ESFD4020 )

NSTEP=${NJOB}_05
# Fusion du Fichier FTECLEDR et des fichiers de REJETS EBS et celui des OPENING EBS ASUME 
#-----------------------------------------------------------------------------
LIBEL="MERGE FTECLEDR WITH REJ_RETRO AND WITH OPENING_RETRO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDRSO} 1000 1"
##SORT_I2="${ESF_FTECLEDR_REJ} 1000 1"
##SORT_I3="${ESF_OPNG_EBS_RET} 1000 1"
SORT_O="${ESF_FTECLEDR_REJ_OPNG} 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,       
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:
exit
EOF
SORT

##NSTEP=${NJOB}_07
### Fusion du Fichier FTECLEDR et des fichiers de REJETS EBS et celui des OPENING EBS ASUME POUR ESFD4020
###-----------------------------------------------------------------------------
##LIBEL="MERGE FTECLEDR WITH REJ_RETRO AND WITH OPENING_RETRO AND PREVIOUS CURGTR FOR ESFD4020"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
###SORT_I="${ESF_FTECLEDR_REJ_OPNG} 1000 1"
##SORT_I="${EPO_FTECLEDRSO} 1000 1"
##SORT_I2="${ESF_FTECLEDR_REJ} 1000 1"
##SORT_I3="${ESF_OPNG_EBS_RET} 1000 1"
##SORT_I4="${ESF_CURGTR} 1000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_REJ_OPNG_4020.dat 1000 1" 
##INPUT_TEXT ${SORT_CMD} <<EOF
##/FIELDS SSD_CF            1:1 -  1:EN,
##        ESB_CF            2:1 -  2:EN,
##        BALSHEY_NF        3:1 -  3:EN,       
##        BALSHRMTH_NF      4:1 -  4:EN,
##        BALSHRDAY_NF      5:1 -  5:EN,
##        TRNCOD_CF         6:1 -  6:,
##        DBLTRNCOD_CF      7:1 -  7:,
##        CTR_NF            8:1 -  8:,
##        END_NT            9:1 -  9:EN,
##        SEC_NF           10:1 - 10:EN,
##        UWY_NF           11:1 - 11:
##exit
##EOF
##SORT

else

NSTEP=${NJOB}_03A
# Fusion du Fichier FTECLEDR et des fichiers de REJETS EBS et celui des OPENING EBS ASUME
#-----------------------------------------------------------------------------
LIBEL="MERGE FTECLEDA with ESF_FTECLEDR_REJ and ESF_OPNG_ASSUMED"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_GT_A_AR} 1000 1"
SORT_I="${DFILT}/${NJOB}_02_${IB}_GT_A_AR_WITHOUT_ESTIM_SUM.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_01_${IB}_GT_A_AR_WITH_ESTIM_1-2.dat 1000 1"
SORT_I3="${ESF_FTECLEDA_REJ} 1000 1"
SORT_I4="${ESF_OPNG_EBS_ASS} 1000 1"
SORT_O="${ESF_FTECLEDA_REJ_OPNG} 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,       
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:
exit
EOF
SORT



NSTEP=${NJOB}_05A
# Fusion du Fichier FTECLEDR et des fichiers de REJETS EBS et celui des OPENING EBS ASUME 
#-----------------------------------------------------------------------------
LIBEL="MERGE FTECLEDR WITH REJ_RETRO AND WITH OPENING_RETRO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDRSO} 1000 1"
SORT_I2="${ESF_FTECLEDR_REJ} 1000 1"
SORT_I3="${ESF_OPNG_EBS_RET} 1000 1"
SORT_O="${ESF_FTECLEDR_REJ_OPNG} 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,       
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:
exit
EOF
SORT

fi

#[14] End

#SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GT_A_AR_REJ_OPNG.dat 1000 1" 
#SORT_I="${ESF_FTECLEDA_REJ_OPNG_4020} 2000 1"          

NSTEP=${NJOB}_10
# Join AND Extend ARCSTAGTA with PRS_751, TRSTYP_NT, AND TRNTYP_CT of FBOPRSLNK_FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join ARCSTAGTA with PRS_ 751 and TRNTYP_CT FBOPRSLNK_FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_GT_A_AR} 1000 1"

if [ "${IDF_CT}" = "EBS_ESFD4050_TECLEDA" ]
then
		SORT_I="${DFILT}/${NJOB}_04_${IB}_FTECLEDA_REJ_OPNG_4020.dat 1000 1" 
else
    SORT_I="${ESF_FTECLEDA_REJ_OPNG} 2000 1" 
fi		
SORT_O="${EST_GT_ACMTRS} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLOSTYP_NF       17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,                                                               
        RETINTAMT_M      41:1 - 41:EN 15/3,                                               
        COLS_STD_F1       1:1 - 41:,                                                      
        ACMTRS_NT        42:1 - 42:,                                                      
        ACMAMT_M         43:1 - 43:EN 15/3,                                                  
        ACMCUR_CF        44:1 - 44:,                                                      
				PRS_CF 		       45:1 - 45:,                                                      
				SEG_NF 		       46:1 - 46:,                                                      
				LOB_CF 		       47:1 - 47:,                                                      
				NAT_CF 		       48:1 - 48:,                                                      
				TYP_CT 		       49:1 - 49:,                                                      
				PATTYP_CT        50:1 - 50:,                                                      
				SEGLOB_CF        51:1 - 51:,                                                      
				ACMTRSL3_NT      52:1 - 52:,                                                                                                           
				TRSPFX_CF_F2	   1:1 -  1:,                                                       
				ACMTRSL3_NT_F2   5:1 -  5:, 
				ACMTRSL2_NT_F2   4:1 -  4:,                                           
				TRSTYP_NT_F2	   8:1 -  8:,         
				DETTRS_CF_F2	   9:1 -  9:,           
				TRNTYP_CT_F2    14:1 - 14:,  
				PRS_CF_F2       15:1 - 15:,
				ACMTRS_NT_F2    16:1 - 16:													         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4051_20_${IB}_SORT_FBOPRSLNK_FTRSLNK.dat 1000 1 "~" 
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:COLS_STD_F1
	,rightside:ACMTRSL2_NT_F2  
	,leftside:RETINTAMT_M 	 
	,leftside:ACMCUR_CF 
	,rightside:PRS_CF_F2
	,leftside:SEG_NF 		
	,leftside:LOB_CF 		
	,leftside:NAT_CF 		
	,leftside:TYP_CT 		
	,leftside:PATTYP_CT 
	,leftside:SEGLOB_CF 
	,rightside:ACMTRSL3_NT_F2	
	,rightside:TRNTYP_CT_F2
	,rightside:TRSTYP_NT_F2
	,rightside:TRSPFX_CF_F2										  
exit
EOF
SORT


##############################################################################
################ GENERATION OF ITD FILE  #####################################
##############################################################################

# [04] [07]

#/DERIVEDFIELD ACMAMT_MC    RETAMT_M COMPRESS

NSTEP=${NJOB}_20
touch ${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTA_O.dat
#-----------------------------------------------------------------------------
LIBEL="ARCSTATGTA AGREGATES ESPD3800_FTECLEDASO_I4I ESPD3800_FTECLEDASII Merge and sort files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${EST_GT_ACMTRS} 1000 1"      
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_O.dat 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,       
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        LINETYP_NF       13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLOSTYP_NF       17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRSL2_NT      42:1 - 42:,     
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
				PRS_CF 		       45:1 - 45:,
				SEG_NF 		       46:1 - 46:,
				NAT_CF		       47:1 - 47:,
				LOB_CF 		       48:1 - 48:,
				TYP_CT 		       49:1 - 49:,
				PATTYP_CT        50:1 - 50:,
				SEGLOB_CF        51:1 - 51:,
				ACMTRSL3_NT      52:1 - 52:, 
				TRNTYP_CT        53:1 - 53:EN, 	
				TRSTYP_NT        54:1 - 54:EN, 	
				TRSPFX_CF        55:1 - 55:EN          
/KEYS   
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,        
        RETCTR_NF,
        RETEND_NT,
        RTY_NF,
        RETUW_NT,
        RETSEC_NF,
        TRNCOD_CF,	         
        PLC_NT,        
        ACMTRSL3_NT,
        RETCUR_CF,
        LINETYP_NF,
        CLOSTYP_NF,
        TRNTYP_CT,   
        TRSTYP_NT,
        TRSPFX_CF       
/CONDITION PERIODE_ITD (  ( ( (BALSHEY_NF < ${ICLODAT_A} ) OR ( (BALSHEY_NF = ${ICLODAT_A} ) AND (BALSHRMTH_NF <= ${ICLODAT_M})  ) )  AND (LOB_CF != "30" AND LOB_CF != "31") AND (ACMTRSL3_NT != "1030") AND (ACMTRSL2_NT != "303") AND (ACMTRSL2_NT != "307") AND (ACMTRSL2_NT != "203")
                              AND ( (TRSTYP_NT = 1) OR (TRSTYP_NT = 3)  OR ( (TRSTYP_NT = 0)  AND  ( TRNTYP_CT = 150))  OR ( (TRSTYP_NT = 2)  AND  ( TRNTYP_CT <= 100) AND (ACMTRSL3_NT = "1020"  OR ACMTRSL3_NT = "2043" OR ACMTRSL3_NT = "1023" OR ACMTRSL3_NT =  "2020" OR ACMTRSL3_NT = "2022" OR ACMTRSL3_NT = "2021" OR ACMTRSL3_NT = "3020" OR ACMTRSL3_NT = "3021" OR ACMTRSL3_NT = "3022" OR ACMTRSL3_NT = "3080"  ) ) )   )  
                       OR ( (BALSHEY_NF = ${ICLODAT_A} ) AND (BALSHRMTH_NF <= ${ICLODAT_M})   AND ( (TRSTYP_NT = 1) OR (TRSTYP_NT = 3) )  AND (LOB_CF != "30" AND LOB_CF != "31") AND ( (ACMTRSL3_NT = "1030")  OR  (ACMTRSL2_NT = "303")  OR  (ACMTRSL2_NT = "307") OR (ACMTRSL2_NT = "203") ) ) 
                       )  
/CONDITION AE_EST  		( ( "12"  CT TRNCOD1_CF) AND ("4E" CT TRNCOD2_CF) AND ("0" NC TRNCOD8_CF) )                                                                     
/CONDITION AE_ACT  		( ( "12"  CT TRNCOD1_CF) AND ("4" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  ) 
/CONDITION ACTUAL  		( ( "12"  CT TRNCOD1_CF) AND ("1" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  )  
/CONDITION ESTIMATES  ( ( "12"  CT TRNCOD1_CF) AND ("1A" CT TRNCOD2_CF) AND ( "0" NC TRNCOD8_CF ) ) 
/CONDITION EBS        ( ( "12" CT TRNCOD1_CF ) AND ("AE" CT TRNCOD2_CF)  AND (TRNTYP_CT = 100) )
/CONDITION IFRS4      ( ( "12" CT TRNCOD1_CF ) AND ("14" CT TRNCOD2_CF)  AND ( TRNTYP_CT < 100) ) 
/CONDITION IFRS17      ( ( "12" CT TRNCOD1_CF ) AND ("1A" CT TRNCOD2_CF)  AND ( TRNTYP_CT = 150) )  
/CONDITION ASS_RET  	( "1"  CT TRNCOD1_CF)  
/DERIVEDFIELD LINETYP_NF_NEW if AE_EST then "AE~" else if AE_ACT then "AA~" else if ACTUAL then "AC~" else if ESTIMATES then "ES~" else "OO~"
/DERIVEDFIELD CLOSTYP_NF_NEW if EBS then "E~" else if IFRS4 then "I~" else if IFRS17 then "G~" else "A~"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD TYP_CT_NEW if ASS_RET then "A~" else "R~" 
/DERIVEDFIELD STRVIDE "~"
/DERIVEDFIELD PLUS_20_CHAMPS 20"~"
/DERIVEDFIELD ACY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD SCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD SCOENDMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD RETINTAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC if ASS_RET then AMT_M else RETAMT_M
/DERIVEDFIELD ACMCUR_CF_NEW if ASS_RET then CUR_CF else RETCUR_CF
/OUTFILE ${SORT_O}
/INCLUDE PERIODE_ITD
/REFORMAT 
         SSD_CF          
         ,ESB_CF          
         ,BALSHEY_NF_NEW      
         ,BALSHRMTH_NF_NEW    
         ,BALSHRDAY_NF_NEW    
         ,TRNCOD_CF            
         ,DBLTRNCOD_CF    
         ,CTR_NF          
         ,END_NT          
         ,SEC_NF          
         ,UWY_NF          
         ,UW_NT           
         ,LINETYP_NF_NEW       
         ,ACY_NF_NEW          
         ,SCOSTRMTH_NF_NEW    
         ,SCOENDMTH_NF_NEW    
         ,CLOSTYP_NF_NEW          
         ,CUR_CF          
         ,AMT_M           
         ,CED_NF          
         ,BRK_NF          
         ,PAY_NF          
         ,KEY_NF          
         ,RETCTR_NF       
         ,RETEND_NT       
         ,RETSEC_NF       
         ,RTY_NF          
         ,RETUW_NT        
         ,RETOCCYEA_NF    
         ,ACY_NF_NEW       
         ,SCOSTRMTH_NF_NEW 
         ,SCOENDMTH_NF_NEW 
         ,RCL_NF          
         ,RETCUR_CF       
         ,RETAMT_M        
         ,PLC_NT          
         ,RTO_NF          
         ,INT_NF          
         ,RETPAY_NF       
         ,RETKEY_CF       
         ,RETINTAMT_MC
         ,ACMTRSL2_NT    
         ,ACMAMT_MC    
         ,ACMCUR_CF_NEW    
         ,PRS_CF 		  
         ,STRVIDE 		  
         ,STRVIDE 		  
         ,STRVIDE 		  
         ,TYP_CT_NEW 		  
         ,STRVIDE    
         ,STRVIDE    
         ,ACMTRSL3_NT
         ,TRNTYP_CT 
         ,TRSTYP_NT
				 ,TRSPFX_CF 
         ,STRVIDE				 
         ,PLUS_20_CHAMPS					                                     
exit
EOF
SORT



NSTEP=${NJOB}_30
# SORT UNIQUE of AGGREGATION file ITD FILE
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of AGGREGATION ITD file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_DLCUMGTAAR_ITD_O.dat 1000 1"
SORT_O="${EST_GT_A_AR_SUM} 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
       SSD_CF            1:1 -  1:EN,         
       ESB_CF            2:1 -  2:EN,         
       BALSHEY_NF        3:1 -  3:EN,         
       BALSHRMTH_NF      4:1 -  4:EN,         
       BALSHRDAY_NF      5:1 -  5:EN,         
       TRNCOD_CF         6:1 -  6:,           
       TRNCOD1_CF        6:1 -  6:1,          
       TRNCOD2_CF        6:2 -  6:2,          
       TRNCOD3_CF        6:3 -  6:6,          
       TRNCOD34_CF       6:3 -  6:4,          
       TRNCOD4_CF        6:3 -  6:7,          
       TRNCOD8_CF        6:8 -  6:8,          
       DBLTRNCOD_CF      7:1 -  7:,           
       CTR_NF            8:1 -  8:,           
       END_NT            9:1 -  9:EN,         
       SEC_NF           10:1 - 10:EN,         
       UWY_NF           11:1 - 11:,           
       UW_NT            12:1 - 12:EN,         
       LINETYP_NF       13:1 - 13:,           
       ACY_NF           14:1 - 14:,           
       SCOSTRMTH_NF     15:1 - 15:EN,         
       SCOENDMTH_NF     16:1 - 16:EN,         
       CLOSTYP_NF       17:1 - 17:,           
       CUR_CF           18:1 - 18:,           
       AMT_M            19:1 - 19:EN 15/3,    
       CED_NF           20:1 - 20:,           
       BRK_NF           21:1 - 21:,           
       PAY_NF           22:1 - 22:,           
       KEY_NF           23:1 - 23:,           
       RETCTR_NF        24:1 - 24:,           
       RETEND_NT        25:1 - 25:EN,         
       RETSEC_NF        26:1 - 26:EN,         
       RTY_NF           27:1 - 27:,           
       RETUW_NT         28:1 - 28:EN,         
       RETOCCYEA_NF     29:1 - 29:,           
       RETACY_NF        30:1 - 30:,           
       RETSCOSTRMTH_NF  31:1 - 31:EN,         
       RETSCOENDMTH_NF  32:1 - 32:EN,         
       RCL_NF           33:1 - 33:,           
       RETCUR_CF        34:1 - 34:,           
       RETAMT_M         35:1 - 35:EN 15/3,    
       PLC_NT           36:1 - 36:,           
       RTO_NF           37:1 - 37:,           
       INT_NF           38:1 - 38:,           
       RETPAY_NF        39:1 - 39:,           
       RETKEY_CF        40:1 - 40:,           
       RETINTAMT_M      41:1 - 41:EN 15/3,    
       ACMTRSL2_NT      42:1 - 42:,                 
       ACMAMT_M         43:1 - 43:EN 15/3,    
       ACMCUR_CF        44:1 - 44:,           
       PRS_CF 		      45:1 - 45:,           
       SEG_NF 		      46:1 - 46:,           
       LOB_CF 		      47:1 - 47:,           
       NAT_CF 		      48:1 - 48:,           
       TYP_CT 		      49:1 - 49:,           
       PATTYP_CT        50:1 - 50:,           
       SEGLOB_CF        51:1 - 51:,           
       ACMTRSL3_NT      52:1 - 52:,           
       TRNTYP_CT        53:1 - 53:EN, 	       
       TRSTYP_NT        54:1 - 54:EN, 	       
       TRSPFX_CF        55:1 - 55:EN                            
/KEYS   
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,        
        RETCTR_NF,
        RETEND_NT,
        RTY_NF,
        RETUW_NT,
        RETSEC_NF,
        TRNCOD_CF,
        PLC_NT,        
        ACMTRSL3_NT,
        RETCUR_CF,
        LINETYP_NF,
        CLOSTYP_NF,
        TRNTYP_CT,   
        TRSTYP_NT,
        TRSPFX_CF 
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M
/CONDITION ASS_RET  	( "1"  CT TRNCOD1_CF) 
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC if ASS_RET then AMT_M else RETAMT_M
/CONDITION MONTANT_DIFF_ASS  (AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0 OR ACMAMT_M != 0) AND (LINETYP_NF != "OO") AND (LOB_CF != "30" AND LOB_CF != "31")
/OUTFILE ${SORT_O}
/INCLUDE MONTANT_DIFF_ASS
exit
EOF
SORT 



