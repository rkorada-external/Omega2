#!/bin/ksh
#=============================================================================
# nom de l'application          : Fusion VLIFEST et RI
# nom du script SHELL           : ESID3027I.cmd
# revision                      : $Revision: 1.0 $
# date de creation              : 16/04/2015
# auteur                        : Julien FONTANA
# references des specifications : SPOT 28559
#-----------------------------------------------------------------------------
# description :
# Fusion VLIFEST et RI
#
# 2 Passages :
#   Passage N°1 : grille local + RI interserveur
#   Passage N°2 : RI intraserveur suite a closing
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
# [001] 23/03/2015 J.FONTANA	spot:28559: -> EST24BT
# [002] 21/10/2015 S.ASKRI		spot:29541: -> EST24BT
# [003] 21/01/2016 RBE			spot:30080: ne pas tenir compte du mois Bilan apres la remise � 0 des EI
# [004] 09/02/2016 SAS			spot:30136: Optimisation de l'ESID2030.cmd
# [005] 10/05/2016 R.BEN EZZINE	spot: : Optimisation ESID2030
# [006] 27/09/2016 PGA			spot:31124: forcer UWY = ACY pour contrat type 1
# [007] 25/02/2019 RAF			spot:70045: Add key mounth in SORT
# [008] 25/02/2019 BEL			spot:82673: Insertion des lignes en boucle dans TLIFEST (fixed)
# [009] 16/05/2021 S.Behague spira:109620 Estimates from IO retro with balance sheet date on quarter already booked
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

# Get input parameters
CRE_D=$1
PASS=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_010
echo "#      ###  PASSAGE ${PASS} ${NJOB} ###"
#gzip -c ${EST_VLIFEST195}   >     ${DFILI}/${NSTEP}_VLIFEST_START_3027I.dat.gz
if [[ ${PASS} -eq 2 ]]; 
then
  EST_LIFEP=${EST_DLRLIFEP}
  echo "#      Using EST_DLRLIFEP instead of EST_LIFEP"
fi

NSTEP=${NJOB}_050
# Splitting VLIFEST in two : Part with and without RI
#[002] O3 added
# [007]
#------------------------------------------------------------------------------
LIBEL="Splitting VLIFEST in two : Part with and without RI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_I2="${EST_LIFESTNOACC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_VLIFEST${IT}_RI.dat"     # VLIFEST with RI
SORT_O2="${DFILT}/${NSTEP}_${IB}_VLIFEST${IT}_woRI.dat"  # VLIFEST without RI
SORT_O3="${DFILT}/${NSTEP}_${IB}_VLIFEST${IT}_O.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			2:1 - 2:,
	END_NT			3:1 - 3:,
	SEC_NF			4:1 - 4:,
	UWY_NF			5:1 - 5:,
	ACY_NF			7:1 - 7:,
	UW_NT			6:1 - 6:,
	CRE_D			8:1 - 8:,
	ACMTRS_NT		10:1 - 10:,
	BALSHEY_NF		11:1 - 11:,
	BALSHTMTH_NF	12:1 - 12:EN,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	ORICOD_LS		16:1 - 16:,
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
/CONDITION RETRO_INTERNE ORICOD_LS = "RETRO INTERNE"
/OUTFILE ${SORT_O}
/INCLUDE RETRO_INTERNE
/OUTFILE ${SORT_O2}
/OMIT RETRO_INTERNE
/OUTFILE ${SORT_O3}
exit
EOF
SORT

#gzip -c ${DFILT}/${NJOB}_050_${IB}_VLIFEST${IT}_woRI.dat > ${DFILT}/${NJOB}_050_VLIFEST${IT}_woRI.dat.gz
#gzip -c ${DFILT}/${NJOB}_050_${IB}_VLIFEST${IT}_RI.dat   > ${DFILT}/${NJOB}_050_VLIFEST${IT}_RI.dat.gz


NSTEP=${NJOB}_090
# SORT & FILTER received file
# [008]
#---------------------------------------------------------------------------
FILTER="/OMIT QUATERLY"
if [ "${IT}" == "Q" ]; then
   FILTER="/INCLUDE QUATERLY"
fi
LIBEL="SORT & FILTER received LIFEP/LIFEI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${EST_LIFEP} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FILTERED_SORT_LIFEP${IT}_O.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
    ESTCRB_CT       33:1 - 33:
/CONDITION QUATERLY ( ESTCRB_CT CT "T" OR ESTCRB_CT CT "U" )
/OUTFILE  ${SORT_O}
${FILTER}

exit
EOF
SORT


NSTEP=${NJOB}_100
# SORT & REFORMAT received file
# [007]
#---------------------------------------------------------------------------
LIBEL="SORT & REFORMAT received LIFEP/LIFEI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${NJOB}_090_${IB}_FILTERED_SORT_LIFEP${IT}_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEP${IT}_O.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  
	SSD_CF			1:1 - 1:EN,
	CTR_NF			2:1 - 2:,
	SEC_NF			4:1 - 4:,
	UWY_NF			5:1 - 5:,
	ACY_NF			7:1 - 7:,
	ACMTRS_NT		10:1 - 10:,
	BALSHEY_NF		11:1 - 11:,
	BALSHTMTH_NF	12:1 - 12:EN,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	ACM_NF			25:1 - 25:EN,
	ZONE1			1:1 -  7:,
	ZONE11			9:1 - 51:,
	ZONE2			53:1 - 54:
/KEYS 
	CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT,
	BALSHEY_NF,
	BALSHTMTH_NF,
	DETTRNCOD_CF,
	GAAP_NF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/DERIVEDFIELD BATCH_B "1~"
/DERIVEDFIELD CRE_DAT "${CRE_D} 23:59:05~"
/OUTFILE  ${SORT_O}
/REFORMAT 
	ZONE1,
	CRE_DAT, 
	ZONE11, 
	BATCH_B, 
	ZONE2
exit
EOF
SORT

NSTEP=${NJOB}_110
# [006]
# for type 1 contract forced UWY = ACY
#------------------------------------------------------------------------------
LIBEL=" for type 1 contract forced UWY = ACY"
PRG=ESTC2094
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_SORT_LIFEP${IT}_O.dat
export ${PRG}_I2=${EST_IARVPERICASE4}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST${IT}.dat
EXECPRG

#gzip -c ${DFILT}/${NJOB}_110_${IB}_ESTC2094_LIFEST${IT}.dat   >   ${DFILT}/${NJOB}_110_ESTC2094_LIFEST${IT}.dat.gz

NSTEP=${NJOB}_120
#Syncro perimetre / retro interne 
#------------------------------------------------------------------------------
LIBEL=" retro interne"
PRG=ESTC7606
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_110_${IB}_ESTC2094_LIFEST${IT}.dat
export ${PRG}_I2=${EST_IARVPERICASE4}
export ${PRG}_I3=${DFILT}/${NJOB}_050_${IB}_VLIFEST${IT}_O.dat
export ${PRG}_O=${DFILT}/${NSTEP}_${IB}_LIFEST${IT}_O.dat
EXECPRG

#gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_LIFEP${IT}_O.dat > ${DFILT}/${NSTEP}_SORT_LIFEP${IT}_O.dat.gz
#gzip -c ${DFILT}/${NJOB}_050_${IB}_VLIFEST${IT}_O.dat > ${DFILT}/${NSTEP}_VLIFEST${IT}_O.dat.gz
#gzip -c ${DFILT}/${NJOB}_120_${IB}_LIFEST${IT}_O.dat > ${DFILT}/${NSTEP}_LIFEST${IT}_ESTC7606.dat.gz

NSTEP=${NJOB}_150
# Gestion des Gaaps Parents et Local par le recepteur
#------------------------------------------------------------------------------
LIBEL="Gestion of Parent and Local Gaaps by the receiver"
PRG=ESTC3700
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_110_${IB}_ESTC2094_LIFEST${IT}.dat
export ${PRG}_I2=${EST_IARVPERICASE4}
export ${PRG}_I3=${EST_SUBTRSESBPROP}
export ${PRG}_I4=${EST_SUBTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEP${IT}.dat
EXECPRG

#gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEP${IT}.dat > ${DFILT}/${NSTEP}_ESTC3700_LIFEP${IT}.dat.gz

NSTEP=${NJOB}_155
# [007]
# Merging Annual Estimates for Sybase Insertion 
#------------------------------------------------------------------------------
LIBEL="Merging Annual Estimates for Sybase Insertion"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_LIFEST${IT}_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_150_${IB}_ESTC3700_LIFEP${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_NEW_LIFEP${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			2:1 -  2:,
	END_NT			3:1 -  3:,
	SEC_NF			4:1 -  4:,
	UWY_NF			5:1 -  5:,
	ACY_NF			7:1 -  7:,
	UW_NT			6:1 -  6:,
	CRE_D			8:1 -  8:,
	ACMTRS_NT		10:1 - 10:,
	BALSHEY_NF		11:1 - 11:,
	BALSHTMTH_NF	12:1 - 12:EN,
	ESTMNT_M		14:1 - 14:EN 15/3,
	ORICOD_LS		16:1 - 16:,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	ACM_NF			25:1 - 25:EN,
	FILLER1    1:1 - 11:,
	FILLER2   13:1 - 52:
/KEYS 
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	CRE_D,
	BALSHEY_NF,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF
/SUMMARIZE TOTAL ESTMNT_M
/DERIVEDFIELD BALSHTMTH "${BALSHTMTH_NF}~"
/OUTFILE ${SORT_O}
/REFORMAT 
          FILLER1,
          BALSHTMTH,
          FILLER2
exit
EOF
SORT

#gzip -c ${DFILT}/${NSTEP}_${IB}_NEW_LIFEP${IT}.dat > ${DFILT}/${NJOB}_155_NEW_LIFEP${IT}_${PASS}.dat.gz

# NSTEP=${NJOB}_170
# # Tri du fichier EST_DLRLIFEP_INT
# #------------------------------------------------------------------------------
# LIBEL="Tri du fichier LIFEI"
# SORT_WDIR=${SORTWORK}
# SORT_CMD=`CFTMP`
# SORT_I="${DFILT}/${NJOB}_155_${IB}_NEW_LIFEP.dat 1000 1"
# SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST.dat"
# INPUT_TEXT ${SORT_CMD} <<EOF
# /FIELDS 
#         CTR_NF  2:1 -  2:,
#         SEC_NF  4:1 -  4:,
#         UWY_NF  5:1 -  5:
# /KEYS 
#     CTR_NF,
#     SEC_NF,
#     UWY_NF
# /OUTFILE   ${SORT_O}
# exit
# EOF
# SORT


NSTEP=${NJOB}_200
#Syncro perimetre / retro interne
#------------------------------------------------------------------------------
LIBEL="Syncro of perimeter and intern retrocession"
PRG=ESTC7607
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IARVPERICASE4}
export ${PRG}_I2=${DFILT}/${NJOB}_155_${IB}_NEW_LIFEP${IT}.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${EST_CPLIFDRI}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRLIFEP${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEP${IT}_AI_EXTRA_LOG.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEP${IT}_AI_COMACC_1.dat
EXECPRG

#gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEP${IT}_AI_EXTRA_LOG.dat 	> 		${DFILT}/${NSTEP}_ESTC7607_LIFEP${IT}_AI_EXTRA_ERR.dat.gz
#gzip -c ${DFILT}/${NJOB}_200_${IB}_ESTC7607_DLRLIFEP${IT}.dat		>		${DFILT}/${NJOB}_200_ESTC7607_DLRLIFEP${IT}.dat.gz

NSTEP=${NJOB}_300
#------------------------------------------------------------------------------
LIBEL="Launching cleaning chain ESID0002"
IBC=${IB}
INPUT_FILE1="${DFILT}/${NJOB}_200_${IB}_ESTC7607_DLRLIFEP${IT}.dat"
INPUT_FILE2="${DFILT}/${NJOB}_050_${IB}_VLIFEST${IT}_RI.dat"
OUTPUT_FILE_NAME="${DFILT}/${NSTEP}_${IB}_ESID0002_VLIFEST${IT}_NEW.dat"
OUTPUT_FILE_NAME_DIFF="${DFILT}/${NSTEP}_${IB}_ESID0002_OLD_VLIFEST${IT}.dat"
#on sauvegarde la variable NJOB qui est modifiée dans le ESID0002 avec le JOBINIT
SAVINGJOB=${NJOB}
NJOB=${NSTEP}_ESID0002
${DCMD}/ESID0002.cmd ${IBC} ${OUTPUT_FILE_NAME} ${OUTPUT_FILE_NAME_DIFF} ${INPUT_FILE1} ${INPUT_FILE2} 2>&1 | ${TEE}
IB=${IBC}
NJOB=${SAVINGJOB}

NSTEP=${NJOB}_400
# Recreating VLIFEST195
#------------------------------------------------------------------------------
LIBEL="Recreating VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_050_${IB}_VLIFEST${IT}_woRI.dat  1000 1"           # VLIFEST without RI 
SORT_I2="${DFILT}/${NJOB}_300_${IB}_ESID0002_VLIFEST${IT}_NEW.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_LIFEST${IT}_O2.dat"                                  # New VLIFEST
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
	ESTMNT_M		14:1 - 14:EN 15/3,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	ACM_NF			25:1 - 25:EN
/KEYS 
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF,
	BALSHEY_NF,
	CRE_D
exit
EOF
SORT

NSTEP=${NJOB}_450
#------------------------------------------------------------------------------
LIBEL="Launching spliting chain ESID0003"
INPUT_FILE1="${DFILT}/${NJOB}_400_${IB}_LIFEST${IT}_O2.dat"
OUTPUT_FILE_NAME_1="${EST_VLIFEST195}"
OUTPUT_FILE_NAME_2="${EST_LIFESTNOACC}"
${DCMD}/ESID0003.cmd ${OUTPUT_FILE_NAME_1} ${OUTPUT_FILE_NAME_2} ${INPUT_FILE1} ${BALSHTYEA_NF} 2>&1 | ${TEE}

# #gzip fichiers temporaires
#------------------------------------------------------------------------------ 
#gzip -c  ${EST_VLIFEST195}  > ${DFILT}/${NJOB}_450_VLIFEST${IT}_${PASS}.dat.gz
#gzip -c  ${EST_LIFESTNOACC} > ${DFILT}/${NJOB}_450_LIFESTNOACC${IT}_${PASS}.dat.gz

NSTEP=${NJOB}_500
# Deletion of Temporary Files
#------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
#RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

# Job End
JOBEND
