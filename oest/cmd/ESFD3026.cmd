#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESID3026.cmd
# revision                      : $Revision: 1.10 $
# date de creation              : 06/03/03
# auteur                        : J. RIBOT
# references des specifications : SPOT-5075
#-----------------------------------------------------------------------------
# description :
# Création PLACEMT et PERICASE
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
#
#MODIFICATION    [001]
#Auteur:         D.GATIBELZA
#Date:           26/07/2010
#Version:        10.1
#Description:    ESTVIE19177 V10 Mettre en place un calcul spécial de DAC pour Köln
#                automatic DAC calculation taking into account the fanancing commission, the technical result, the interest on deposit
#-------------|------------------------------------------------------------------------------------------------------
# 10/09/2010  | [19177] - ajout export ${PRM} et remplacement du fichier ${EST_IAVPERICASE} par ${EST_IAVPERICASE0} STEP 40
#             |         - deplacement du STEP 01 au STEP 73
#[002] 07/07/2014 ABJ :spot:25773 Correction du format du CPLIFEST
#[003] 10/10/2014 M.MECHRI :spot:25773 Correction de DACC
#[004] 14/10/2014 ABJ  :spot:25773 Ajout du mois bilan pour le ESTC2164
#[005] 16/10/2014 ABJ  :spot:25773 Ajout d'un fichier de log pour le ESTC2164 ( pour les postes inexistants) 
#[006] 10/05/2016 R.BEN EZZINE  :spot: : Optimisation ESID2030
#[007] 25/02/2019 R.Vieville	:spot:70045: Add mounth in key SORT
#===============================================================================
# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3
CLODAT_D=$4
LIF_ACY_MIN=5

# Job Initialisation
JOBINIT

#[003]
NSTEP=${NJOB}_60
# Filter Gaap2 VLIFEST195
# [007]
#------------------------------------------------------------------------------
LIBEL="TRI DU FICHIER VLIFEST195: les estimations les plus récentes en premier"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_I2="${EST_LIFESTNOACC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF	2:1 - 2:,
	SEC_NF	4:1 - 4:,
	UWY_NF	5:1 - 5:EN,
	ACY_NF	7:1 - 7:EN,
	GAAP_NF	22:1 - 22:,
	ACM_NF	25:1 - 25:EN
/KEYS 
	CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	ACM_NF
/CONDITION GAAP2 ( GAAP_NF = "2" ) 
/INCLUDE GAAP2
exit
EOF
SORT

# gzip -c ${EST_VLIFEST195}		> ${DFILT}/${NJOB}_VLIFEST195.dat.gz

NSTEP=${NJOB}_70
# Filter LIB
# [007]
#------------------------------------------------------------------------------
LIBEL="Filter LIB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_LIFEST${IT}_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST${IT}_O.dat 1000 1"
SORT_O1="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST${IT}_LIB_O1.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			2:1 - 2:,
	END_NT			3:1 - 3:,
	SEC_NF			4:1 - 4:EN,
	UWY_NF			5:1 - 5:,
	UW_NT			6:1 - 6:,
	ACY_NF			7:1 - 7:,
	CRE_D			8:1 - 8:,
	ACMTRS_NT		10:1 - 10:,
	ACMTRS4_NT		10:4 - 10:4,
	BALSHEY_NF		11:1 - 11:,
	CUR_CF1			3:1 - 13:,
	ORICOD_LS		16:1 - 16:,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	ACM_NF			25:1 - 25:EN
/KEYS 
	CTR_NF,
	END_NT,
	SEC_NF,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF,
	ACY_NF,
	ACM_NF,
	UWY_NF,
	UW_NT,
	BALSHEY_NF,
	CRE_D,
	CUR_CF1,
	ORICOD_LS
/CONDITION ACMTRS_A (ACMTRS4_NT = "4")
/OUTFILE ${SORT_O}
/OMIT ACMTRS_A
/OUTFILE ${SORT_O1}
/INCLUDE ACMTRS_A
exit
EOF
SORT

NSTEP=${NJOB}_75
# Traitement Liberation 
#[004]
#[005]
#------------------------------------------------------------------------------
LIBEL="Calculation of begining =< 2015"
PRG=ESTC2164
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
BALSHTYEA ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
ACY_MIN ${LIF_ACY_MIN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_70_${IB}_SORT_LIFEST${IT}_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_70_${IB}_SORT_LIFEST${IT}_LIB_O1.dat 
export ${PRG}_I3=${EST_SUBTRS}
export ${PRG}_I4=${EST_SUBTRSASSO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LAST_LIFESTLib${IT}_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_Log${IT}.dat
EXECPRG

NSTEP=${NJOB}_85
# Annual Estimates Sort
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_ESTC2164_LAST_LIFESTLib${IT}_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			2:1 - 2:,
	SEC_NF			4:1 - 4:,
	UWY_NF			5:1 - 5:,
	ACY_NF			7:1 - 7:,
	CRE_D			8:1 - 8:,
	ACMTRS_NT		10:1 - 10:,
	BALSHEY_NF		11:1 - 11:,
	BALSHMTH_NF		12:1 - 12:EN,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	ACM_NF			25:1 - 25:EN
/KEYS 
	CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF,
	BALSHEY_NF DESCENDING,
	BALSHMTH_NF DESCENDING,
	CRE_D DESCENDING
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_87
# Annual Estimates Screen
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Screen"
PRG=ESTC2040
export ${PRG}_I1=${DFILT}/${NJOB}_85_${IB}_SORT_LIFEST${IT}_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LAST_LIFEST${IT}_MVT_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LAST_LIFEST${IT}_MVT_O2.dat
EXECPRG

NSTEP=${NJOB}_90
# TRI DU FICHIER
# [007] 
#------------------------------------------------------------------------------
LIBEL="TRI DU FICHIER ESTC2148"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_87_${IB}_ESTC2040_LAST_LIFEST${IT}_MVT_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_70_${IB}_SORT_LIFEST${IT}_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF	2:1 - 2:,
	SEC_NF	4:1 - 4:,
	UWY_NF	5:1 - 5:EN,
	ACY_NF	7:1 - 7:EN,
	ACM_NF	25:1 - 25:EN
/KEYS 
	CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	ACM_NF
exit
EOF
SORT

#[001]
NSTEP=${NJOB}_100
# DAC
#------------------------------------------------------------------------------
LIBEL="DAC"
PRG=ESTC2148
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IAVPERICASE0}
export ${PRG}_I2=${DFILT}/${NJOB}_90_${IB}_SORT_LIFEST${IT}_O.dat
export ${PRG}_I3=${EST_FACCPAR0}
export ${PRG}_I4=${EST_FFAMCNA}
export ${PRG}_I5=${EST_ESTC2035_LIFDRI_O1}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_DAC_LIFEST${IT}_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_DAC_LIFEST${IT}${BALSHTYEA_NF}${BALSHTMTH_NF}_O.log
EXECPRG

gzip -c ${DFILT}/${NJOB}_100_${IB}_DAC_LIFEST${IT}_O.dat  > ${DFILT}/${NJOB}_DAC_LIFEST${IT}_O.dat.gz

NSTEP=${NJOB}_130
# Tri du fichier VLIFEST195
# [007]
#------------------------------------------------------------------------------
LIBEL=" Tri du fichier VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_I2="${EST_LIFESTNOACC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			2:1 - 2:,
	END_NT			3:1 - 3:,
	SEC_NF			4:1 - 4:,
	UWY_NF			5:1 - 5:,
	UW_NT			6:1 - 6:,
	ACY_NF			7:1 - 7:,
	CRE_D			8:1 - 8:,
	ACMTRS_NT		10:1 - 10:,
	BALSHEY_NF		11:1 - 11:,
	BALSHTMTH_NF	12:1 - 12:EN,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	ACM_NF			25:1 - 25:EN
/KEYS 
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	CRE_D,
	BALSHEY_NF,
	BALSHTMTH_NF,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF
exit
EOF
SORT

NSTEP=${NJOB}_180
# Puis retri du fichier VLIFEST trié + CNA + DAC pour redonner un fichier VLIFEST195
#[001] Ajout I2 fichier DAC
# [007]
#------------------------------------------------------------------------------
LIBEL="Puis tri pour le 2040"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_SORT_LIFEST${IT}_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_100_${IB}_DAC_LIFEST${IT}_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DAC_MERGE_LIFEST${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			2:1 - 2:,
	SEC_NF			4:1 - 4:,
	UWY_NF			5:1 - 5:,
	ACY_NF			7:1 - 7:,
	CRE_D			8:1 - 8:,
	ACMTRS_NT		10:1 - 10:,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	BALSHEY_NF		11:1 - 11:,
	BALSHMTH_NF		12:1 - 12:EN,
	ACM_NF			25:1 - 25:EN
/KEYS 
	CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF,
	BALSHEY_NF DESCENDING,
	BALSHMTH_NF DESCENDING,
	CRE_D DESCENDING
exit
EOF
SORT

NSTEP=${NJOB}_181
## Clean Merge SORT/DAC LIFEST
##------------------------------------------------------------------------------
#LIBEL="Puis retri du fichier VLIFEST trié + CNA + DAC pour redonner un fichier VLIFEST195"
IBC=${IB}
INPUT_FILE1="${DFILT}/${NJOB}_180_${IB}_SORT_DAC_MERGE_LIFEST${IT}_O.dat"
OUTPUT_FILE_NAME="${EST_VLIFEST195}"
OUTPUT_FILE_NAME_DIFF="${DFILT}/${NSTEP}_${IB}_VLIFEST195${IT}_OLD.dat"
${DCMD}/ESID0002.cmd ${IBC} ${OUTPUT_FILE_NAME} ${OUTPUT_FILE_NAME_DIFF} ${INPUT_FILE1} 2>&1 | ${TEE}   # ${INPUT_FILE2}
IB=${IBC}


NSTEP=${NJOB}_190
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_160_${IB}_SORT_LIFEST_SANS_DAC${IT}_O.dat

NSTEP=${NJOB}_200
# Extraction des CNA AUTO du jour à partir du nouveau fichier VLIFEST195
# [007]
#----------------------------------------------------------------------------
LIBEL="Extraction des CNA AUTO du jour à partir du nouveau fichier VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195${IT}_CNA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_CF			1:1 - 1:,
	CTR_NF			2:1 - 2:,
	END_NT			3:1 - 3:,
	SEC_NF			4:1 - 4:,
	UWY_NF			5:1 - 5:,
	UW_NT			6:1 - 6:,
	ACY_NF			7:1 - 7:,
	CRE_D			8:1 - 8:,
	ACMTRS_NT		10:1 - 10:,
	BALSHEY_NF		11:1 - 11:,
	BALSHTMTH_NF	12:1 - 12:EN,
	CUR_CF			13:1 - 13:,
	ESTMNT_M		14:1 - 14:EN 15/3,
	INDSUP_B		15:1 - 15:,
	ORICOD_LS		16:1 - 16:,
	CREUSR_CF		17:1 - 17:,
	LSTUPD_D		18:1 - 18:,
	LSTUPDUSR_CF	19:1 - 19:,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	ACM_NF			25:1 - 25:EN
/KEYS 
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	CRE_D,
	BALSHEY_NF,
	BALSHTMTH_NF,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF
/CONDITION CNAAUTO (CRE_D = "${CRE_D} 23:59:50" AND ORICOD_LS = 'CNA AUTO')
/DERIVEDFIELD PRS_CF "500~"
/OUTFILE ${SORT_O}
/INCLUDE CNAAUTO
/REFORMAT 
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	CRE_D,
	BALSHEY_NF,
	BALSHTMTH_NF,
	ACY_NF,
	PRS_CF,
	ACMTRS_NT,
	SSD_CF,
	CUR_CF,
	ESTMNT_M,
	INDSUP_B,
	ORICOD_LS,
	CREUSR_CF,
	LSTUPD_D,
	LSTUPDUSR_CF,
	DETTRNCOD_CF, 
	GAAP_NF
exit
EOF
SORT


NSTEP=${NJOB}_205
# Extraction des DAC du jour à partir du nouveau fichier VLIFEST195
# [007]
#----------------------------------------------------------------------------
LIBEL="Extraction des DAC du jour à partir du nouveau fichier VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195${IT}_DAC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_CF			1:1 - 1:,
	CTR_NF			2:1 - 2:,
	END_NT			3:1 - 3:,
	SEC_NF			4:1 - 4:,
	UWY_NF			5:1 - 5:,
	UW_NT			6:1 - 6:,
	ACY_NF			7:1 - 7:,
	CRE_D			8:1 - 8:,
	ACMTRS_NT		10:1 - 10:,
	BALSHEY_NF		11:1 - 11:,
	BALSHTMTH_NF	12:1 - 12:EN,
	CUR_CF			13:1 - 13:,
	ESTMNT_M		14:1 - 14:EN 15/3,
	INDSUP_B		15:1 - 15:,
	ORICOD_LS		16:1 - 16:,
	CREUSR_CF		17:1 - 17:,
	LSTUPD_D		18:1 - 18:,
	LSTUPDUSR_CF	19:1 - 19:,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	CRE_D2			8:1 - 8:14,
	GAAPDIFF_M		23:1 - 23:EN 15/3,
	PROPAGATION_B	24:1 - 24:,
	ESTMTH_NF		25:1 - 25:EN,
	ORICTR_NF		26:1 - 26:,
	ORISEC_NF		27:1 - 27:,
	ORIUWY_NF		28:1 - 28:,
	BATCH_B			52:1 - 52:        
/KEYS 
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	CRE_D,
	BALSHEY_NF,
	BALSHTMTH_NF,
	ACY_NF,
	ESTMTH_NF,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF
/CONDITION DACAUTO (CRE_D = "${CRE_D} 23:59:50" AND ( ORICOD_LS = 'CNA AUTO 5' ) )
/DERIVEDFIELD PRS_CF "500~"
/DERIVEDFIELD CALCULATED_B "0~"
/OUTFILE ${SORT_O}
/INCLUDE DACAUTO
/REFORMAT 
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	CRE_D,
	BALSHEY_NF,
	BALSHTMTH_NF,
	ACY_NF,
	GAAP_NF,
	DETTRNCOD_CF,
	ESTMTH_NF,
	PRS_CF,
	ACMTRS_NT,
	SSD_CF,
	CUR_CF,
	ESTMNT_M,
	INDSUP_B,
	ORICOD_LS,
	CREUSR_CF,
	LSTUPD_D,
	LSTUPDUSR_CF,
	ORICTR_NF,
	ORISEC_NF,
	ORIUWY_NF,
	GAAPDIFF_M,
	PROPAGATION_B,
	CALCULATED_B,
	BATCH_B          
exit
EOF
SORT

NSTEP=${NJOB}_210
# Inversion des montant RETRO venant des CNA AUTO + DAC extraits
#-----------------------------------------------------------------------------
LIBEL="Inversion des montant RETRO venant des CNA AUTO + DAC extraits"
AWK_I=${DFILT}/${NJOB}_200_${IB}_SORT_VLIFEST195${IT}_CNA_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_VLIFEST195${IT}_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
        { if( \$14 < "2000" ) { print \$0 }}
		{ if( \$14 > "2000" ) { \$17 = sprintf("%-.3lf",-\$17) ; print \$0 }}
exit
EOF
AWK

NSTEP=${NJOB}_220
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_200_${IB}_SORT_VLIFEST195${IT}_CNA_O.dat

NSTEP=${NJOB}_230
# Begin sort
#------------------------------------------------------------------------------
LIBEL="move EST_CPLIFEST ==> DFILT _OLD_CPLIFEST.dat"
EXECKSH "mv ${EST_CPLIFEST} ${DFILT}/${NSTEP}_${IB}_OLD_CPLIFEST${IT}.dat"

#[001]
#[002]
NSTEP=${NJOB}_235
#on ne prend que les nouveaux DAC du VLIFEST195
#------------------------------------------------------------------------------
LIBEL="on ne prend que les nouveaux DAC du VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_205_${IB}_SORT_VLIFEST195${IT}_DAC_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195${IT}_DAC_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	LSTUPD_D 21:1 - 21:
/CONDITION NEW_DAC ( LSTUPD_D = "${CRE_D}" )
/OUTFILE ${SORT_O}
/INCLUDE NEW_DAC
exit
EOF
SORT

NSTEP=${NJOB}_240
# Ajout des CNA et DAC dans le fichier CPLIFEST
#[001] Ajout des DAC
# [007]
#------------------------------------------------------------------------------
LIBEL="Ajout des CNA et DAC dans le fichier CPLIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_210_${IB}_AWK_VLIFEST195${IT}_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_230_${IB}_OLD_CPLIFEST${IT}.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_235_${IB}_SORT_VLIFEST195${IT}_DAC_O.dat 1000 1"
SORT_O="${EST_CPLIFEST} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			1:1 - 1:,
	END_NT			2:1 - 2:,
	SEC_NF			3:1 - 3:,
	UWY_NF			4:1 - 4:,
	UW_NT			5:1 - 5:,
	CRE_D			6:1 - 6:,
	BALSHEY_NF		7:1 - 7:,
	BALSHTMTH_NF	8:1 - 8:EN,
	ACY_NF			9:1 - 9:,
	GAAP_NF			10:1 - 10:,
	DETTRNCOD_CF	11:1 - 11:,
	ACM_NF			12:1 - 12:EN,
	ACMTRS_NT		14:1 - 14:,
	CUR_CF			16:1 - 16:,
	ESTMNT_M		17:1 - 17:EN 15/3
/KEYS 
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	CRE_D,
	BALSHEY_NF,
	BALSHTMTH_NF,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF,
	CUR_CF
/SUM TOTAL ESTMNT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT
#[002]

NSTEP=${NJOB}_245
##------------------------------------------------------------------------------
# gzip fichiers temporaires
#------------------------------------------------------------------------------ 
gzip -c  ${EST_VLIFEST195}  > ${DFILT}/${NJOB}_250_VLIFEST${IT}_O.dat.gz
gzip -c  ${EST_LIFESTNOACC} > ${DFILT}/${NJOB}_250_LIFESTNOACC${IT}.dat.gz

NSTEP=${NJOB}_250
# Deletion of Temporary Files
#------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

# Job End
JOBEND
