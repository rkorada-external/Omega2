#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESID2031.cmd
# revision                      : 
# date de creation              : 
# auteur                        : 
# references des specifications :
#-----------------------------------------------------------------------------
# description :
# Création GT
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
# 05/06/2014 M.MECHRI [007]: Ajout de filtre pour les contrats des traités non criblés sans traités de rattachement
# [008] 24/08/2015 SBE :spot 29253 - TAC02B
# [009] 20/01/2019 RAF REQ.L.02.05: Evolution quarterly 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
BALSHTYEA_NF=$1


# Job Initialisation
JOBINIT

#[012]
#[015]
NSTEP=${NJOB}_10
# Sort ARCSTATGTR + IGTR00
#----------------------------------------------------------------------------
LIBEL="Sort ARCSTATGTR + IGTR00"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_ARCSTATGTR} 1000 1"
SORT_I2="${EST_IGTR00} 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTR${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	BALSHEY_NF		3:1 - 3:EN,
	BALSHRMTH_NF	4:1 - 4:EN,
	BALSHRDAY_NF	5:1 - 5:EN,
	TRNCOD8_CF		6:8 - 6:8,
	RETCTR_NF		24:1 - 24:,
	RETEND_NT		25:1 - 25:,
	RETSEC_NF		26:1 - 26:,
	RTY_NF			27:1 - 27:,
	RETUW_NT		28:1 - 28:
/KEYS 
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	BALSHEY_NF,
	BALSHRMTH_NF
/CONDITION MVTRET (TRNCOD8_CF = "0" OR (("246ACEG" CT TRNCOD8_CF )
			AND BALSHEY_NF = `expr ${BALSHTYEA_NF} - 1` AND BALSHRMTH_NF = 12 AND BALSHRDAY_NF = 31))
/OUTFILE  ${SORT_O}
/INCLUDE MVTRET
exit
EOF
SORT

#[001]
NSTEP=${NJOB}_20
#Dividing of TSTATGTA in retrocession by acceptance life and non-life
#-----------------------------------------------------------------------------
LIBEL="Current dividing of ARCSTATGTR_O in retrocession by acceptance life and non-life ..."
PRG=ESTM7606
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_ARCSTATGTR${IT}_O.dat
export ${PRG}_I2=${EST_IRVPERICASE0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DTSTATGTR${IT}_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_VTSTATGTR${IT}_O1.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_STATGTRANO${IT}.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_DTSTATGTR${IT}_O1.dat  > ${DFILT}/${NJOB}_20_DTSTATGTR${IT}_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_VTSTATGTR${IT}_O1.dat  > ${DFILT}/${NJOB}_20_VTSTATGTR${IT}_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_STATGTRANO${IT}.dat    > ${DFILT}/${NJOB}_20_STATGTRANO${IT}.dat.gz
# ----------------------------------------

#[008] On utilise le fichier IGTAA00 à la place des CURGTA et GTA
#[009] Reduction au format 41 col
NSTEP=${NJOB}_30
# Estimates Acceptance Amounts current Balshey Year (Openning ES)
#---------------------------------------------------------------------------
LIBEL="1GL: Estimates Acceptance Amounts current Balshey Year (Openning ES)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IGTAA00} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CURGTA${IT}_O.dat 1000 1 "
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_CURGTA${IT}_O2.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_CF			1:1  - 1:EN,
	BALSHEY_NF		3:1  - 3:EN,
	BALSHRMTH_NF	4:1  - 4:EN,
	BALSHRDAY_NF	5:1  - 5:EN,
	TRNCOD1_CF		6:1  - 6:1,
	TRNCOD2_CF		6:2  - 6:2,
	TRNCOD8_CF		6:8  - 6:8,
	CTR_NF			8:1  - 8:,        
	FIELD_41		1:1  - 41:
/COPY
/CONDITION ESTACC1
		(BALSHEY_NF = ${BALSHTYEA_NF} AND
			CTR_NF != "         " AND
			BALSHRMTH_NF = 1                           AND
			BALSHRDAY_NF = 1                           AND
		(TRNCOD1_CF = "1" OR TRNCOD1_CF = "3")      AND
			TRNCOD2_CF ne "7"                          AND
		(TRNCOD8_CF = "2" OR ("246ACEG" CT TRNCOD8_CF))) AND
		${EST_SORT_CONDITION}
/CONDITION ESTACC2
            (BALSHEY_NF = ${BALSHTYEA_NF}               AND
             CTR_NF != "         "                      AND
             BALSHRMTH_NF ne 1                          AND
            (TRNCOD1_CF = "1" OR TRNCOD1_CF = "3" )     AND
             TRNCOD2_CF = "7" )                         AND
           ${EST_SORT_CONDITION}
/OUTFILE ${SORT_O}
/INCLUDE ESTACC1
/REFORMAT FIELD_41
/OUTFILE ${SORT_O2}
/INCLUDE ESTACC2
/REFORMAT FIELD_41
exit
EOF
SORT

NSTEP=${NJOB}_40
# Inversion of amounts before merge
#-----------------------------------------------------------------------------
LIBEL="Inversion of amounts before merge"
AWK_I=${DFILT}/${NJOB}_30_${IB}_SORT_CURGTA${IT}_O2.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA${IT}_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
     { if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
       if (substr(\$6,2,1) == "7")
            \$6= substr(\$6,1,1) "4" substr(\$6,3,6);
            print \$0 }
exit
EOF
AWK

NSTEP=${NJOB}_50
# Merge of Estimates Acceptance Amounts
#----------------------------------------------------------------------------
LIBEL="Merge of Estimates Acceptance Amounts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_CURGTA${IT}_O.dat"
SORT_I2="${DFILT}/${NJOB}_40_${IB}_SORT_CURGTA${IT}_O.dat"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA${IT}_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/OUTFILE  ${SORT_O}
/FIELDS 
	CTR_NF	8:1 - 8:, 
	END_NT	9:1 - 9:, 
	SEC_NF	10:1 - 10:, 
	UWY_NF	11:1 - 11:, 
	UW_NT	12:1 - 12:
/KEYS
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_60
#Dividing of TSTATGTA in retrocession by acceptance life and non-life
#-----------------------------------------------------------------------------
LIBEL="Current dividing of ARCSTATGTR_O in retrocession by acceptance life and non-life ..."
PRG=ESTM7605
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_CURGTA${IT}_O.dat
export ${PRG}_I2=${EST_IAVPERICASE0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DTSTATGTA${IT}_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_VTSTATGTA${IT}_O1.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_STATGTAANO${IT}.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_DTSTATGTA${IT}_O1.dat  > ${DFILT}/${NJOB}_60_DTSTATGTA_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_VTSTATGTA${IT}_O1.dat  > ${DFILT}/${NJOB}_60_VTSTATGTA_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_STATGTAANO${IT}.dat    > ${DFILT}/${NJOB}_60_STATGTAANO.dat.gz
# ----------------------------------------

NSTEP=${NJOB}_70
# Cession Amounts
#----------------------------------------------------------------------------
LIBEL="Cession Amounts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VTSTATGTA0} 1000"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VTSTATGTA0${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	TRNCOD1_CF	6:1 - 6:1,
	TRNCOD8_CF	6:8 - 6:8,
	CTR_NF		8:1 - 8:
/COPY
/CONDITION CEDACC ((TRNCOD1_CF EQ "1" OR TRNCOD1_CF EQ "3")   AND
                    TRNCOD8_CF = "0"  AND CTR_NF != "         ")
/INCLUDE CEDACC
exit
EOF
SORT

NSTEP=${NJOB}_80
# Merge of cession and retrocession amounts
#----------------------------------------------------------------------------
LIBEL="Merge of cession and retrocession amounts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_SORT_VTSTATGTA0${IT}_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_20_${IB}_ESTM7606_VTSTATGTR${IT}_O1.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_60_${IB}_ESTM7605_VTSTATGTA${IT}_O1.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_STATGTAR${IT}_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_CF 1:1 - 1:EN
/COPY
/CONDITION NONVIE (SSD_CF = 5 OR SSD_CF = 6)
/OMIT NONVIE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_90
# Years modification for particular contracts
#-----------------------------------------------------------------------------
LIBEL="Years modification for particular contracts"
AWK_I=${DFILT}/${NJOB}_80_${IB}_SORT_STATGTAR${IT}_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_STATGTAR${IT}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
    CTR_NF=\$24;
    SEC_NF=\$26;
    UWY_NF=\$27;

    if ((index(CTR_NF, "04W059112") || index(CTR_NF, "04W059113")) && SEC_NF == 1 && UWY_NF > 1996)
        \$27="1996";
                
    if (index(CTR_NF, "04W604280") && SEC_NF == 1 && UWY_NF > 1989)
        \$27="1989";
	print \$0;
}
exit
EOF
AWK

NSTEP=${NJOB}_100
#Retrocession and Acceptance Data Exchange
#------------------------------------------------------------------------------
LIBEL="Retrocession and Acceptance Data Exchange"
PRG=ESTC2033
export ${PRG}_I1=${DFILT}/${NJOB}_90_${IB}_AWK_STATGTAR${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O.dat
EXECPRG

NSTEP=${NJOB}_110
# Merge of cession and retrocession amounts
#----------------------------------------------------------------------------
LIBEL="Merge of cession and retrocession amounts"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST2070} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2040_LAST_LIFEST${IT}_O2.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF			2:1 - 2:,
	SEC_NF			4:1 - 4:,
	UWY_NF			5:1 - 5:,
	ACY_NF			7:1 - 7:,
	ACMTRS_NT		10:1 - 10:,
	DETTRNCOD_CF	20:1 - 20:,
	ACM_NF			25:1 - 25:EN
/KEYS   
	CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT,
	DETTRNCOD_CF
/SUM
/STABLE
exit
EOF
SORT

NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
# Mise au format GT du fichier prevision
# Paramètre du programme STAM1501 --> AMOUNT : 0 --> On force le montant ESTMNT à 0
#											 : 1 --> On laisse le traitement actuel
#[008]
#------------------------------------------------------------------------------
LIBEL="Mise au format GT du fichier des prevision ACY N+1 et N+2"
PRG=STAM1501
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
AMOUNT  0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_110_${IB}_ESTC2040_LAST_LIFEST${IT}_O2.dat
export ${PRG}_I2=${EST_SUBTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST${IT}_GT_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST${IT}_GT_ANA_O1.dat
EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST${IT}_GT_ANA_O1.dat > ${DFILT}/${NSTEP}_${PRG}_LIFEST${IT}_GT_ANA_O1.dat.gz

NSTEP=${NJOB}_130
# Sort of TL, merged by Contrat, Section and U/W Year
#------------------------------------------------------------------------------
LIBEL="Sort of TL, merged by Contrat, Section and U/W Year"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_ESTC2033_GT${IT}_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_120_${IB}_STAM1501_LIFEST${IT}_GT_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_CF			1:1 - 1:EN,
	CTR_NF			8:1 - 8:,
	SEC_NF			10:1 - 10:,
	UWY_NF			11:1 - 11:,
	BALSHEY_NF		3:1 - 3:EN,
	BALSHRMTH_NF	4:1 - 4:EN
/KEYS 
	CTR_NF,
	SEC_NF,
	UWY_NF,
	BALSHEY_NF,
	BALSHRMTH_NF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
exit
EOF
SORT

NSTEP=${NJOB}_140
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_ARCSTATGTR${IT}_O.dat
RMFIL ${DFILT}/${NJOB}_36_${IB}_SORT_CURGTA${IT}_O.dat
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_CURGTA${IT}_O.dat
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_CURGTA${IT}_O.dat
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_CURGTA${IT}_O.dat
RMFIL ${DFILT}/${NJOB}_70_${IB}_SORT_VTSTATGTA0${IT}_O.dat
RMFIL ${DFILT}/${NJOB}_80_${IB}_SORT_STATGTAR${IT}_O.dat
RMFIL ${DFILT}/${NJOB}_100_${IB}_ESTC2033_GT${IT}_O.dat

# [009]
NSTEP=${NJOB}_145
# Sort file CPLACC for PRG ESTC2054
#------------------------------------------------------------------------------
LIBEL="Sort file CPLACC for PRG ESTC2054"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCPLACC0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CPLACC${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_CF			1:1 - 1:EN,
	CTR_NF			2:1 - 2:,
	ACY_NF			3:1 - 3:,
	SCOENDMTH_NF	5:1 - 5:EN
/KEYS 
	CTR_NF,
	ACY_NF,
	SCOENDMTH_NF
/CONDITION NONVIE (SSD_CF = 5 OR SSD_CF = 6)
/CONDITION DECEMBRE SCOENDMTH_NF EQ 12
/CONDITION QUART (SCOENDMTH_NF EQ 3 OR SCOENDMTH_NF EQ 6 OR SCOENDMTH_NF EQ 9 OR SCOENDMTH_NF EQ 12)
/OMIT NONVIE
/INCLUDE DECEMBRE
/INCLUDE QUART
/OUTFILE ${SORT_O}
exit
EOF
SORT

# [009]
NSTEP=${NJOB}_146
# Sort LSTMTH for PRG ESTC2054
#------------------------------------------------------------------------------
LIBEL="Sort LSTMTH for PRG ESTC2054"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FLSTMTH} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LSTMTH${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			1:1 - 1:,
	SCOENDMTH_NF	2:1 - 2:EN,
	RETACCYER_NF	3:1 - 3:
/KEYS 
	CTR_NF,
	RETACCYER_NF,
	SCOENDMTH_NF
/CONDITION DECEMBRE SCOENDMTH_NF EQ 12
/CONDITION QUART (SCOENDMTH_NF EQ 3 OR SCOENDMTH_NF EQ 6 OR SCOENDMTH_NF EQ 9 OR SCOENDMTH_NF EQ 12)
/INCLUDE DECEMBRE
/INCLUDE QUART
/OUTFILE ${SORT_O}
exit
EOF
SORT

# [009]
NSTEP=${NJOB}_147
# Save line with the quarter complet per contract for CPLACC and LSTMTH
#------------------------------------------------------------------------------
LIBEL="Save line with the quarter complet per contract for CPLACC and LSTMTH"
PRG=ESTC2054
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IARVPERICASE4}
export ${PRG}_I2=${DFILT}/${NJOB}_145_${IB}_SORT_CPLACC${IT}.dat
export ${PRG}_I3=${DFILT}/${NJOB}_146_${IB}_SORT_LSTMTH${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CPLACC${IT}_0.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LSTMTH${IT}_0.dat
EXECPRG



NSTEP=${NJOB}_150
# Complete Accounts Screen and Sort
#------------------------------------------------------------------------------
LIBEL="Complete Accounts Screen and Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_145_${IB}_SORT_CPLACC${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CPLACC${IT}_0.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_CF			1:1 - 1:EN,
	CTR_NF			2:1 - 2:,
	ACY_NF			3:1 - 3:,
	SCOENDMTH_NF	5:1 - 5:EN
/KEYS 
	CTR_NF,
	ACY_NF DESCENDING,
	SCOENDMTH_NF DESCENDING
/CONDITION NONVIE (SSD_CF = 5 OR SSD_CF = 6)
/CONDITION DECEMBRE SCOENDMTH_NF EQ 12
/CONDITION QUART (SCOENDMTH_NF EQ 3 OR SCOENDMTH_NF EQ 6 OR SCOENDMTH_NF EQ 9 OR SCOENDMTH_NF EQ 12)
/OMIT NONVIE
/INCLUDE DECEMBRE
/INCLUDE QUART
/OUTFILE  ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_160
# Complete Account Screen
#------------------------------------------------------------------------------
LIBEL="Complete Account Screen"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_150_${IB}_SORT_CPLACC${IT}_0.dat 1000 1"
SORT_O="${EST_160_SORT_CPLACC_O} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF	2:1 - 2:
/KEYS 
	CTR_NF
/STABLE
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_170
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
gzip -c ${DFILT}/${NJOB}_150_${IB}_SORT_CPLACC${IT}_O.dat > ${DFILT}/${NJOB}_150_SORT_CPLACC${IT}_O.dat.gz
RMFIL ${DFILT}/${NJOB}_85_${IB}_SORT_CPLACC${IT}_O.dat
RMFIL ${DFILT}/${NJOB}_150_${IB}_SORT_CPLACC${IT}_O.dat

NSTEP=${NJOB}_180
# Sort FLSTMTH file
#------------------------------------------------------------------------------
LIBEL="Sort FLSTMTH file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I=${EST_FLSTMTH}
SORT_I="${DFILT}/${NJOB}_146_${IB}_SORT_LSTMTH${IT}.dat 1000 1"
SORT_O=${EST_180_SORT_LSTMTH_O}
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			1:1 - 1:,
	SCOENDMTH_NF	2:1 - 2:EN,
	RETACCYER_NF	3:1 - 3:
/KEYS 
	CTR_NF,
	RETACCYER_NF,
	SCOENDMTH_NF
/CONDITION LSTMTH SCOENDMTH_NF = 12
/CONDITION QUART (SCOENDMTH_NF EQ 3 OR SCOENDMTH_NF EQ 6 OR SCOENDMTH_NF EQ 9 OR SCOENDMTH_NF EQ 12)
/INCLUDE QUART
/INCLUDE LSTMTH
exit
EOF
SORT

NSTEP=${NJOB}_200
#Introduction of Conversion and Accumulated Transaction Codes
# [007] Ajout I5 et O3
# [008] Ajout I6
#------------------------------------------------------------------------------
LIBEL="Introduction of Conversion and Accumulated Transaction Codes"
PRG=ESTC2034
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IARVPERICASE0}
export ${PRG}_I2=${DFILT}/${NJOB}_130_${IB}_SORT_GT${IT}_O.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_31_SORT_R_IAVPERICASE_O}
export ${PRG}_I6=${EST_SUBTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTB1${IT}_O.dat
#export ${PRG}_O2=${EST_200_ESTC2034_GTB1_O}
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_TERMINE_ERR.log
EXECPRG

NSTEP=${NJOB}_205
# Remove contract Yearly if in Quarterly or Quarterly if in Yearly in GT file
#------------------------------------------------------------------------------
LIBEL="Remove contract Yearly if in Quarterly or Quarterly if in Yearly in GT file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_ESTC2034_GTB1${IT}_O.dat  1000 1"
SORT_O=${EST_200_ESTC2034_GTB1_O}
if [ ${IT} = Q ]
then
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS
		ESTCRB_CT	50:1 - 50:	
	/COPY
	/CONDITION QUART ESTCRB_CT = "T" or ESTCRB_CT = "U"
	/INCLUDE QUART
	/OUTFILE ${SORT_O}
	exit
EOF
SORT
else
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS
		ESTCRB_CT	50:1 - 50:	
	/COPY
	/CONDITION YEAR ESTCRB_CT != "T" and ESTCRB_CT != "U"
	/INCLUDE YEAR
	/OUTFILE ${SORT_O}
	exit
EOF
SORT
fi

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_130_${IB}_SORT_GT${IT}_O.dat	> ${DFILT}/${NJOB}_130_SORT_GT${IT}_O.dat.gz
gzip -c ${EST_31_SORT_R_IAVPERICASE_O}					> ${DFILT}/${NJOB}_31_SORT_R_IAVPERICASE${IT}_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O.dat	> ${DFILT}/${NSTEP}_ESTC2034_GT${IT}_O.dat.gz
gzip -c ${EST_200_ESTC2034_GTB1_O}						> ${DFILT}/${NSTEP}_ESTC2034_GTB1${IT}_O.dat.gz
# ----------------------------------------

NSTEP=${NJOB}_210
# Appel ESTC2047 pour positionner le flag Poste Fictif
# [008] 
# Positionnement flag poste Fictif
#----------------------------------------------------------------------------
LIBEL="Positionnement flag poste Fictif"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_STAM1501_LIFEST${IT}_GT_ANA_O1.dat  1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_STAM1501_LIFEST${IT}_GT_O2.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF		8:1 - 8:,
	SEC_NF		10:1 - 10:,
	UWY_NF		11:1 - 11:,
	ACY_NF		14:1 - 14:,
	ACM_NF		25:1 - 25:EN,
	ACMTRS_NT	45:1 - 45:
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_STAM1501_LIFEST${IT}_GT_O2.dat     > ${DFILT}/${NSTEP}_STAM1501_LIFEST${IT}_GT_O2.dat.gz

NSTEP=${NJOB}_220
# Tri du fichier de sortie ESTC2034
#----------------------------------------------------------------------------
LIBEL="Tri du fichier de sortie ESTC2034"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_ESTC2034_GT${IT}_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_ESTC2034_GT${IT}_O2.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF		8:1  -  8:,
	SEC_NF		10:1 - 10:,
	UWY_NF		11:1 - 11:,
	ACY_NF		14:1 - 14:,
	ACMTRS_NT	45:1 - 45:,
	QUART_NF	75:1 - 75:EN
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	QUART_NF,
	ACMTRS_NT
exit
EOF
SORT

NSTEP=${NJOB}_230
# Begin programme C ESTC2047.exe
#------------------------------------------------------------------------------
LIBEL="test"
PRG=ESTC2047
export ${PRG}_I1=${DFILT}/${NJOB}_210_${IB}_STAM1501_LIFEST${IT}_GT_O2.dat
export ${PRG}_I2=${DFILT}/${NJOB}_220_${IB}_ESTC2034_GT${IT}_O2.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O3.dat
EXECPRG

if [ -s ${DFILT}/${NJOB}_210_${IB}_STAM1501_LIFEST${IT}_GT_O2.dat ]
then
	echo "File not empty"
else
	echo "File I1 empty copy I2 into output file"
	cp ${DFILT}/${NJOB}_220_${IB}_ESTC2034_GT${IT}_O2.dat ${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O3.dat
fi

gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2047_GT${IT}_O3.dat      > ${DFILT}/${NSTEP}_ESTC2047_GT${IT}_O3.dat.gz

NSTEP=${NJOB}_240
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_130_${IB}_SORT_GT${IT}_O.dat

NSTEP=${NJOB}_250
# Grouping Accounting Transactions by SyncSort
#------------------------------------------------------------------------------
LIBEL="Grouping Accounting Transactions by SyncSort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_230_${IB}_ESTC2047_GT${IT}_O3.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_DBLTRNCOD   1:1 - 7:,
	TRNCOD1_CF      6:1 - 6:1,
	TRNCOD_CF       6:1 - 6:,
	BALSHEY_NF      3:1 - 3:,
	CTR_NF          8:1 - 8:,
	END_NT          9:1 - 9:,
	SEC_NF          10:1 - 10:,
	UWY_NF          11:1 - 11:,
	UW_NT           12:1 - 12:,
	OCCYEA_NF       13:1 - 13:,
	ACY_NF          14:1 - 14:EN,
	SCOSTR_CUR      15:1 - 18:,
	AMT_M           19:1 - 19:EN 15/3,
	GT_CED_NF       20:1 - 20:,
	BRK_NF          21:1 - 21:,
	PAY_NF          22:1 - 22:,
	KEY_NF          23:1 - 23:,
	RETCTR_NF       24:1 - 24:,
	RETEND_NT       25:1 - 25:,
	RETSEC_NF       26:1 - 26:,
	RTY_NF          27:1 - 27:,
	RETUW_NT        28:1 - 28:,
	RETOCCYEA_NF    29:1 - 29:,
	RETACY_NF       30:1 - 30:,
	RETSCOSTRMTH    31:1 - 31:,
	RETSCOENDMTH    32:1 - 32:,
	RCL_NF          33:1 - 33:,
	RETCUR_CF       34:1 - 34:,
	RETAMT_M        35:1 - 35:EN 15/3,
	PLC_NT          36:1 - 36:,
	RTO_NF          37:1 - 37:,
	INT_NF          38:1 - 38:,
	RETPAY_NF       39:1 - 39:,
	RETKEY_CF       40:1 - 40:,
	RETINTAMT_M     41:1 - 41:EN 15/3,
	CED_ESTCUR      42:1 - 42:,
	ESTAMT_M        43:1 - 43:EN 15/3,
	NAT_CF          44:1 - 44:,
	ACMTRS_NT       45:1 - 45:,
	ACMTRS1_NT      45:1 - 45:1,  
	ESTCTR_NF       46:1 - 46:,
	ESTSEC_NF       47:1 - 47:,
	LOB_CF          48:1 - 48:,
	SCOEGP_M        49:1 - 49:EN 15/3,
	ESTCRB_CT       50:1 - 50:,
	LIFTRTTYP_CF    51:1 - 51:,
	ACCADMTYP_CT    52:1 - 52:,
	SECSTS_CT       53:1 - 53:,
	PRD_NF          54:1 - 54:,
	SEG_NF          55:1 - 55:,
	COMACC_B        56:1 - 56:,
	ADJCOD_CT       57:1 - 57:,
	ORICOD_CF       58:1 - 58:,
	DETTRS_CF       59:1 - 59:,
	ACCRET_B        60:1 - 60:,
	ESTUWY_NF       61:1 - 61:,
	LSTENDMTH_NF    62:1 - 62:,
	PROPER_N        63:1 - 63:,
	RTOCTY_CF       64:1 - 64:,
	GAAP_NF         65:1 - 65:,
	BRKSCOEGP_M     66:1 - 66:,
	UWGRP_CF        67:1 - 75:,
	QUART_NF		75:1 - 75:
/KEYS 
	CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	QUART_NF,
	ACMTRS_NT,
	TRNCOD_CF,
	BALSHEY_NF,
	RETCTR_NF,
	RETSEC_NF,
	RTY_NF,
	RETACY_NF,
	RETCUR_CF,
	PLC_NT
/SUM TOTAL ESTAMT_M, TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/CONDITION TRNCOD_A ( TRNCOD1_CF = "1" OR TRNCOD1_CF = "3")
/DERIVEDFIELD ACCRET_B1 if TRNCOD_A then "A~" else "R~"
/DERIVEDFIELD ORICOD_CF1 "CBN~"
/DERIVEDFIELD GAAP_NF1 "1~"
/OUTFILE ${SORT_O}
/REFORMAT 
	SSD_DBLTRNCOD,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	OCCYEA_NF,
	ACY_NF,
	SCOSTR_CUR,
	AMT_MC,
	GT_CED_NF,
	BRK_NF,
	PAY_NF,
	KEY_NF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH,
	RETSCOENDMTH,
	RCL_NF,
	RETCUR_CF,
	RETAMT_MC,
	PLC_NT,
	RTO_NF,
	INT_NF,
	RETPAY_NF,
	RETKEY_CF,
	RETINTAMT_MC,
	CED_ESTCUR,
	ESTAMT_MC,
	NAT_CF,
	ACMTRS_NT,
	ESTCTR_NF,
	ESTSEC_NF,
	LOB_CF,
	SCOEGP_MC,
	ESTCRB_CT,
	LIFTRTTYP_CF,
	ACCADMTYP_CT,
	SECSTS_CT,
	PRD_NF,
	SEG_NF,
	COMACC_B,
	ADJCOD_CT,
	ORICOD_CF1,
	DETTRS_CF,
	ACCRET_B1,
	ESTUWY_NF,
	LSTENDMTH_NF,
	PROPER_N,
	RTOCTY_CF,
	GAAP_NF1,
	BRKSCOEGP_M,
	UWGRP_CF
exit
EOF
SORT

NSTEP=${NJOB}_260
# Tri du fichier GT pour eliminer les lignes d'erreur retro
#------------------------------------------------------------------------------
LIBEL="Annual Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_SORT_GT${IT}_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT${IT}_O.dat 1000 1"
SORT_O1="${DFILT}/${NSTEP}_${IB}_ERR_RETRO_SORT_GT${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	TRNCOD1_CF		6:1 -  6:1,
	TRNCOD_CF		6:1 -  6:,
	BALSHEY_NF		3:1 -  3:,
	CTR_NF			8:1 -  8:,
	SEC_NF			10:1 - 10:,
	UWY_NF			11:1 - 11:,
	ACY_NF			14:1 - 14:EN,
	RETCTR_NF		24:1 - 24:,
	RETSEC_NF		26:1 - 26:,
	RTY_NF			27:1 - 27:,
	RETACY_NF		30:1 - 30:,
	RETCUR_CF		34:1 - 34:,
	PLC_NT			36:1 - 36:,
	ACMTRS_NT		45:1 - 45:,
	QUART_NF		75:1 - 75:
/KEYS 
	CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	QUART_NF,
	ACMTRS_NT,
	TRNCOD_CF,
	BALSHEY_NF,
	RETCTR_NF,
	RETSEC_NF,
	RTY_NF,
	RETACY_NF,
	RETCUR_CF,
	PLC_NT
/CONDITION ERR_RETRO ( (TRNCOD1_CF = "2" OR TRNCOD1_CF = "4") AND CTR_NF = "" )
/OUTFILE ${SORT_O}
/OMIT ERR_RETRO
/OUTFILE ${SORT_O1}
/INCLUDE ERR_RETRO
exit
EOF
SORT

NSTEP=${NJOB}_270
# Taking into Account Accounting Transactions Statistical Expiries
#------------------------------------------------------------------------------
LIBEL="Taking into Account Accounting Transactions Statistical Expiries"
PRG=ESTC2036
export ${PRG}_I1=${DFILT}/${NJOB}_250_${IB}_SORT_GT${IT}_O.dat
export ${PRG}_I2=${EST_160_SORT_CPLACC_O}
export ${PRG}_I3=${EST_180_SORT_LSTMTH_O}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O1N.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O2R.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O3OS.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_250_${IB}_SORT_GT${IT}_O.dat			> ${DFILT}/${NJOB}_250_SORT_GT${IT}_O.dat.gz
gzip -c ${EST_160_SORT_CPLACC_O}								> ${DFILT}/${NJOB}_160_SORT_CPLACC${IT}_O.dat.gz
gzip -c ${EST_180_SORT_LSTMTH_O}								> ${DFILT}/${NJOB}_180_SORT_LSTMTH${IT}_O.dat.gz
gzip -c ${DFILT}/${NJOB}_270_${IB}_ESTC2036_GT${IT}_O1N.dat		> ${DFILT}/${NJOB}_270_ESTC2036_GT${IT}_O1.dat.gz
gzip -c ${DFILT}/${NJOB}_270_${IB}_ESTC2036_GT${IT}_O2R.dat		> ${DFILT}/${NJOB}_270_ESTC2036_GT${IT}_O2.dat.gz
gzip -c ${DFILT}/${NJOB}_270_${IB}_ESTC2036_GT${IT}_O3OS.dat	> ${DFILT}/${NJOB}_270_ESTC2036_GT${IT}_O3.dat.gz
# ------------------------------------

NSTEP=${NJOB}_280
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_250_${IB}_SORT_GT${IT}_O.dat

NSTEP=${NJOB}_290
# Treaties Sort
#------------------------------------------------------------------------------
#[007] Ajout SCOEND et OCCYEA dans le tri pour générer dans le ESCT2037 toujours la dernière période/exercice de survenance., et ajout de EN sur les champs numériques
LIBEL="Treaties Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_270_${IB}_ESTC2036_GT${IT}_O1N.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT${IT}_ON.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	ACY_NF          14:1 - 14:EN,
	ACMTRS_NT       45:1 - 45:EN,
	ESTCTR_NF       46:1 - 46:,
	ESTSEC_NF       47:1 - 47:,
	SCOENDMTH_NF    16:1 - 16:EN,
	OCCYEA_NF       13:1 - 13:EN,
	QUART_NF		75:1 - 75:
/KEYS 
	ESTCTR_NF, 
	ESTSEC_NF, 
	ACY_NF, 
	QUART_NF,
	ACMTRS_NT, 
	SCOENDMTH_NF, 
	OCCYEA_NF
exit
EOF
SORT

NSTEP=${NJOB}_300
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_270_${IB}_ESTC2036_GT${IT}_O1.dat

NSTEP=${NJOB}_310
# Attachment Treaties Sort
#------------------------------------------------------------------------------
LIBEL="Attachment Treaties Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_270_${IB}_ESTC2036_GT${IT}_O2R.dat 1000 1"
SORT_O="${EST_310_SORT_GT_O} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF	8:1 - 8:,
	SEC_NF	10:1 - 10:,
	UWY_NF	11:1 - 11:
/KEYS 
	CTR_NF,
	SEC_NF,
	UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_320
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_270_${IB}_ESTC2036_GT${IT}_O2.dat

NSTEP=${NJOB}_330
# Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IARVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IARVPERICASE0${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	UWY_NF		6:1 -  6:,
	ESTCTR_NF	25:1 - 25:,
	ESTSEC_NF	27:1 - 27:
/KEYS 
	ESTCTR_NF,
	ESTSEC_NF,
	UWY_NF
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_340
#Syncro Attachment treaties / A-R perimeter
#------------------------------------------------------------------------------
LIBEL="Syncro Attachment treaties / A-R perimeter"
PRG=ESTC2042
export ${PRG}_I1=${DFILT}/${NJOB}_330_${IB}_SORT_IARVPERICASE0${IT}_O.dat
export ${PRG}_I2=${EST_310_SORT_GT_O}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_OR.dat
EXECPRG

NSTEP=${NJOB}_350
# Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_340_${IB}_ESTC2042_GT${IT}_OR.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_GT${IT}_OR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF	8:1 -  8:,
	SEC_NF	10:1 - 10:,
	UWY_NF	11:1 - 11:
/KEYS 
	CTR_NF,
	SEC_NF,
	UWY_NF DESCENDING
exit
EOF
SORT

NSTEP=${NJOB}_360
# Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_350_${IB}_GT${IT}_OR.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_GT${IT}_OR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF	8:1 - 8:,
	SEC_NF	10:1 - 10:
/KEYS 
	CTR_NF,
	SEC_NF
/SUM
/STABLE
exit
EOF
SORT

NSTEP=${NJOB}_370
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_330_${IB}_SORT_IARVPERICASE0${IT}_O.dat

NSTEP=${NJOB}_380
# Accounting Update and Fictitious Treaties Statistical Expiries Indicator
#------------------------------------------------------------------------------
LIBEL="Accounting Update and Fictitious Treaties Statistical Expiries Indicator"
PRG=ESTC2037
export ${PRG}_I1=${DFILT}/${NJOB}_290_${IB}_SORT_GT${IT}_ON.dat
export ${PRG}_I2=${DFILT}/${NJOB}_360_${IB}_GT${IT}_OR.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O1N.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O2R.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O3.log  #[013]
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_290_${IB}_SORT_GT${IT}_ON.dat	> ${DFILT}/${NJOB}_290_SORT_GT${IT}_ON.dat.gz
gzip -c ${DFILT}/${NJOB}_340_${IB}_ESTC2042_GT_OR.dat	> ${DFILT}/${NJOB}_340_ESTC2042_GT${IT}_OR.dat.gz
gzip -c ${DFILT}/${NJOB}_350_${IB}_GT${IT}_OR.dat		> ${DFILT}/${NJOB}_350GT${IT}_OR.dat.gz
gzip -c ${DFILT}/${NJOB}_360_${IB}_GT${IT}_OR.dat		> ${DFILT}/${NJOB}_360_GT${IT}_OR.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O1N.dat	> ${DFILT}/${NSTEP}_ESTC2037_GT${IT}_O1N.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O2R.dat	> ${DFILT}/${NSTEP}_ESTC2037_GT${IT}_O2R.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_O3.log	> ${DFILT}/${NSTEP}_ESTC2037_GT${IT}_O3.log.gz
# ----------------------------------------

NSTEP=${NJOB}_390
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_290_${IB}_SORT_GT${IT}_ON.dat
RMFIL ${DFILT}/${NJOB}_340_${IB}_ESTC2042_GT${IT}_OR.dat
RMFIL ${DFILT}/${NJOB}_350_${IB}_GT${IT}_OR.dat
RMFIL ${DFILT}/${NJOB}_360_${IB}_GT${IT}_OR.dat

NSTEP=${NJOB}_400
# Sort of TL filled in by Contrat, Accounting Year, Indicator
#[007]
#------------------------------------------------------------------------------
LIBEL="Sort of TL filled in by Contrat, Accounting Year, Indicator"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_380_${IB}_ESTC2037_GT${IT}_O2R.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT${IT}_OR.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_GT${IT}_OR.ano"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF		8:1 - 8:,
	ACY_NF		14:1 - 14:,
	COMACC_B	56:1 - 56:,
	QUART_NF	75:1 - 75:
/KEYS 
	CTR_NF,
	ACY_NF,
	QUART_NF,
	COMACC_B
/CONDITION NONCRIBLE (CTR_NF ne "ESTCTRERR" and  CTR_NF ne "         ")
/OUTFILE ${SORT_O}
/INCLUDE NONCRIBLE
/OUTFILE ${SORT_O2}
/OMIT NONCRIBLE
exit
EOF
SORT

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_400_${IB}_SORT_GT${IT}_OR.ano  > ${DFILT}/${NJOB}_400_${IB}_SORT_GT${IT}_OR.ano.gz
# ----------------------------------------

NSTEP=${NJOB}_410
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_380_${IB}_ESTC2037_GT${IT}_O2.dat

NSTEP=${NJOB}_420
# Calculation of COMACC_B by CTR_NF, ACY_NF
#------------------------------------------------------------------------------
PRG=ESTC2037b
export ${PRG}_I1=${DFILT}/${NJOB}_400_${IB}_SORT_GT${IT}_OR.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_OR.dat
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_400_${IB}_SORT_GT${IT}_OR.dat > ${DFILT}/${NJOB}_400_SORT_GT${IT}_OR.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT${IT}_OR.dat  > ${DFILT}/${NSTEP}_${IB}_ESTC2037b_GT${IT}_OR.dat.gz
# ----------------------------------------

NSTEP=${NJOB}_430
# Grouping All Treaties Transactions except non-sorted ones
#------------------------------------------------------------------------------
LIBEL="Grouping All Treaties Transactions except non-sorted ones"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_270_${IB}_ESTC2036_GT${IT}_O3OS.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_420_${IB}_ESTC2037b_GT${IT}_OR.dat 1000 1"
SORT_O="${EST_430_SORT_GT_O} 1000 1"
if [ ${IT} = Q ]
then
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_DBLTRNCOD	1:1 -  5:,
	BALSHEY_NF		3:1 -  3:,
	TRNCOD_CF		6:1 -  6:,
	TRNCOD1_CF		6:1 -  6:1,
	TRNCOD5_CF		6:3 -  6:7,
	DBLTRNCOD_CF	7:1 -  7:,
	CTR_NF			8:1 -  8:,
	END_NT			9:1 -  9:,
	SEC_NF			10:1 - 10:,
	UWY_NF			11:1 - 11:,
	UW_NT			12:1 - 12:,
	OCCYEA_NF		13:1 - 13:,
	ACY_NF			14:1 - 14:EN,
	SCOSTR_CUR		15:1 - 18:,
	AMT_M			19:1 - 19:,
	CED_ESTCUR		20:1 - 42:,
	ESTAMT_M		43:1 - 43:EN 15/3,
	NAT_CF			44:1 - 44:,
	ACMTRS_NT		45:1 - 45:,
	ESTCTR_NF		46:1 - 46:,
	ESTSEC_NF		47:1 - 47:,
	LOB_CF			48:1 - 48:,
	SCOEGP_M		49:1 - 49:,
	ESTCRB_CT		50:1 - 50:,
	ESTCRB_UWGRP	50:1 - 75:,
	QUART_NF		75:1 - 75:
/KEYS CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	QUART_NF,
	ACMTRS_NT,
	TRNCOD5_CF
/SUM TOTAL ESTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/DERIVEDFIELD DBLTRN "~"
/DERIVEDFIELD DBLTRN2 "~~"
/CONDITION NONVIE ( TRNCOD_CF = "" and CTR_NF="         ")
/CONDITION ACCEPT ( TRNCOD1_CF = "1" or TRNCOD1_CF = "3")
/CONDITION QUART ( ESTCRB_CT = "T" or ESTCRB_CT = "U")
/DERIVEDFIELD ACCRET if ACCEPT then "A" else "R"
/OMIT NONVIE
/INCLUDE QUART
/OUTFILE ${SORT_O}
/REFORMAT 
	SSD_DBLTRNCOD,
	TRNCOD_CF,
	DBLTRN,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	OCCYEA_NF,
	ACY_NF,
	SCOSTR_CUR,
	AMT_MC,
	CED_ESTCUR,
	ESTAMT_MC,
	NAT_CF,
	ACMTRS_NT,
	ESTCTR_NF,
	ESTSEC_NF,
	LOB_CF,
	SCOEGP_MC,
	ESTCRB_UWGRP
exit
EOF
SORT
else
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	SSD_DBLTRNCOD	1:1 -  5:,
	BALSHEY_NF		3:1 -  3:,
	TRNCOD_CF		6:1 -  6:,
	TRNCOD1_CF		6:1 -  6:1,
	TRNCOD5_CF		6:3 -  6:7,
	DBLTRNCOD_CF	7:1 -  7:,
	CTR_NF			8:1 -  8:,
	END_NT			9:1 -  9:,
	SEC_NF			10:1 - 10:,
	UWY_NF			11:1 - 11:,
	UW_NT			12:1 - 12:,
	OCCYEA_NF		13:1 - 13:,
	ACY_NF			14:1 - 14:EN,
	SCOSTR_CUR		15:1 - 18:,
	AMT_M			19:1 - 19:,
	CED_ESTCUR		20:1 - 42:,
	ESTAMT_M		43:1 - 43:EN 15/3,
	NAT_CF			44:1 - 44:,
	ACMTRS_NT		45:1 - 45:,
	ESTCTR_NF		46:1 - 46:,
	ESTSEC_NF		47:1 - 47:,
	LOB_CF			48:1 - 48:,
	SCOEGP_M		49:1 - 49:,
	ESTCRB_CT		50:1 - 50:,
	ESTCRB_UWGRP	50:1 - 75:,
	QUART_NF		75:1 - 75:
/KEYS CTR_NF,
	SEC_NF,
	UWY_NF,
	ACY_NF,
	QUART_NF,
	ACMTRS_NT,
	TRNCOD5_CF
/SUM TOTAL ESTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/DERIVEDFIELD DBLTRN "~"
/DERIVEDFIELD DBLTRN2 "~~"
/CONDITION NONVIE ( TRNCOD_CF = "" and CTR_NF="         ")
/CONDITION ACCEPT ( TRNCOD1_CF = "1" or TRNCOD1_CF = "3")
/CONDITION YEAR ( ESTCRB_CT != "T" and ESTCRB_CT != "U")
/DERIVEDFIELD ACCRET if ACCEPT then "A" else "R"
/OMIT NONVIE
/INCLUDE YEAR
/OUTFILE ${SORT_O}
/REFORMAT 
	SSD_DBLTRNCOD,
	TRNCOD_CF,
	DBLTRN,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	OCCYEA_NF,
	ACY_NF,
	SCOSTR_CUR,
	AMT_MC,
	CED_ESTCUR,
	ESTAMT_MC,
	NAT_CF,
	ACMTRS_NT,
	ESTCTR_NF,
	ESTSEC_NF,
	LOB_CF,
	SCOEGP_MC,
	ESTCRB_UWGRP
exit
EOF
SORT
fi


NSTEP=${NJOB}_440
# Grouping All Treaties Transactions except non-sorted ones
#------------------------------------------------------------------------------
LIBEL="Grouping All Treaties Transactions except non-sorted ones"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_270_${IB}_ESTC2036_GT${IT}_O3OS.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_420_${IB}_ESTC2037b_GT${IT}_OR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT${IT}_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_DBLTRNCOD    1:1 -  7:,
        TRNCOD1_CF       6:1 -  6:1,
        TRNCOD_CF        6:1 -  6:,
        TRNCOD5_CF       6:3 -  6:7,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        CED_NF          20:1 - 20:,
        BRK_NF          21:1 - 21:,
        PAY_NF          22:1 - 22:,
        KEY_NF          23:1 - 23:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH    31:1 - 31:,
        RETSCOENDMTH    32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:EN 15/3,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        INT_NF          38:1 - 38:,
        RETPAY_NF       39:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:EN 15/3,
        CED_ESTCUR      42:1 - 42:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        NAT_CF          44:1 - 44:,
        ACMTRS_NT       45:1 - 45:,
        ACMTRS1_NT      45:1 - 45:1,  
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:EN 15/3,
        ESTCRB_CT       50:1 - 50:,
        LIFTRTTYP_CF    51:1 - 51:,
        ACCADMTYP_CT    52:1 - 52:,
        SECSTS_CT       53:1 - 53:,
        PRD_NF          54:1 - 54:,
        SEG_NF          55:1 - 55:,
        COMACC_B        56:1 - 56:,
        ADJCOD_CT       57:1 - 57:,
        ORICOD_CF       58:1 - 58:,
        DETTRS_CF       59:1 - 59:,
        ACCRET_B        60:1 - 60:,
        ESTUWY_NF       61:1 - 61:,
        LSTENDMTH_NF    62:1 - 62:,
        PROPER_N        63:1 - 63:,
        RTOCTY_CF       64:1 - 64:,
        GAAP_NF         65:1 - 65:,
        BRKSCOEGP_M     66:1 - 66:,
        UWGRP_CF        67:1 - 75:,
		QUART_NF		75:1 - 75:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
	QUART_NF,
      ACMTRS_NT,
      TRNCOD5_CF,
      BALSHEY_NF,
      RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      RETACY_NF,
      RETCUR_CF,
      PLC_NT,
      CED_NF
/SUM TOTAL ESTAMT_M, TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/CONDITION TRNCOD_A ( TRNCOD1_CF = "1" OR TRNCOD1_CF = "3")
/DERIVEDFIELD ACCRET_B1 if TRNCOD_A then "A~" else "R~"
/DERIVEDFIELD ORICOD_CF1 "CBN~"
/DERIVEDFIELD GAAP_NF1 "1~"
/OUTFILE ${SORT_O}
/REFORMAT 
        SSD_DBLTRNCOD,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTR_CUR,
        AMT_MC,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH,
        RETSCOENDMTH,
        RCL_NF,
        RETCUR_CF,
        RETAMT_MC,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        RETINTAMT_MC,
        CED_ESTCUR,
        ESTAMT_MC,
        NAT_CF,
        ACMTRS_NT,
        ESTCTR_NF,
        ESTSEC_NF,
        LOB_CF,
        SCOEGP_MC,
        ESTCRB_CT,
        LIFTRTTYP_CF,
        ACCADMTYP_CT,
        SECSTS_CT,
        PRD_NF,
        SEG_NF,
        COMACC_B,
        ADJCOD_CT,
        ORICOD_CF1,
        DETTRS_CF,
        ACCRET_B1,
        ESTUWY_NF,
        LSTENDMTH_NF,
        PROPER_N,
        RTOCTY_CF,
        GAAP_NF1,
        BRKSCOEGP_M,
        UWGRP_CF
exit
EOF
SORT

NSTEP=${NJOB}_450
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_420_${IB}_ESTC2037b_GT${IT}_O.dat
RMFIL ${DFILT}/${NJOB}_270_${IB}_ESTC2036_GT${IT}_O3.dat

NSTEP=${NJOB}_460
# Grouping All Non-sorted Treaties Transactions
#------------------------------------------------------------------------------
LIBEL="Grouping All Non-sorted Treaties Transactions"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_380_${IB}_ESTC2037_GT${IT}_O1N.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT${IT}_O1N.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_DBLTRNCOD    1:1 -  7:,
        TRNCOD1_CF       6:1 -  6:1,
        TRNCOD_CF        6:1 -  6:,
        TRNCOD5_CF       6:3 -  6:7,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        SCOSTR_CUR      15:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        CED_NF          20:1 - 20:,
        BRK_NF          21:1 - 21:,
        PAY_NF          22:1 - 22:,
        KEY_NF          23:1 - 23:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH    31:1 - 31:,
        RETSCOENDMTH    32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:EN 15/3,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        INT_NF          38:1 - 38:,
        RETPAY_NF       39:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:EN 15/3,
        CED_ESTCUR      42:1 - 42:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        NAT_CF          44:1 - 44:,
        ACMTRS_NT       45:1 - 45:,
        ACMTRS1_NT      45:1 - 45:1,  
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:EN 15/3,
        ESTCRB_CT       50:1 - 50:,
        LIFTRTTYP_CF    51:1 - 51:,
        ACCADMTYP_CT    52:1 - 52:,
        SECSTS_CT       53:1 - 53:,
        PRD_NF          54:1 - 54:,
        SEG_NF          55:1 - 55:,
        COMACC_B        56:1 - 56:,
        ADJCOD_CT       57:1 - 57:,
        ORICOD_CF       58:1 - 58:,
        DETTRS_CF       59:1 - 59:,
        ACCRET_B        60:1 - 60:,
        ESTUWY_NF       61:1 - 61:,
        LSTENDMTH_NF    62:1 - 62:,
        PROPER_N        63:1 - 63:,
        RTOCTY_CF       64:1 - 64:,
        GAAP_NF         65:1 - 65:,
        BRKSCOEGP_M     66:1 - 66:,
        UWGRP_CF        67:1 - 75:,
		QUART_NF		75:1 - 75:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
		QUART_NF,
      ACMTRS_NT,
      TRNCOD5_CF,
      BALSHEY_NF,
      RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      RETACY_NF,
      RETCUR_CF,
      PLC_NT,
      CED_NF
/SUM TOTAL ESTAMT_M, TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/CONDITION TRNCOD_A ( TRNCOD1_CF = "1" OR TRNCOD1_CF = "3")
/DERIVEDFIELD ACCRET_B1 if TRNCOD_A then "A~" else "R~"
/DERIVEDFIELD ORICOD_CF1 "CBN~"
/DERIVEDFIELD GAAP_NF1 "1~"
/OUTFILE ${SORT_O}
/REFORMAT 
        SSD_DBLTRNCOD,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        OCCYEA_NF,
        ACY_NF,
        SCOSTR_CUR,
        AMT_MC,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH,
        RETSCOENDMTH,
        RCL_NF,
        RETCUR_CF,
        RETAMT_MC,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        RETINTAMT_MC,
        CED_ESTCUR,
        ESTAMT_MC,
        NAT_CF,
        ACMTRS_NT,
        ESTCTR_NF,
        ESTSEC_NF,
        LOB_CF,
        SCOEGP_MC,
        ESTCRB_CT,
        LIFTRTTYP_CF,
        ACCADMTYP_CT,
        SECSTS_CT,
        PRD_NF,
        SEG_NF,
        COMACC_B,
        ADJCOD_CT,
        ORICOD_CF1,
        DETTRS_CF,
        ACCRET_B1,
        ESTUWY_NF,
        LSTENDMTH_NF,
        PROPER_N,
        RTOCTY_CF,
        GAAP_NF1,
        BRKSCOEGP_M,
        UWGRP_CF
exit
EOF
SORT

NSTEP=${NJOB}_470
# Merged TL file Sort
#------------------------------------------------------------------------------
LIBEL="Merged TL file Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_440_${IB}_SORT_GT${IT}_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_460_${IB}_SORT_GT${IT}_O1N.dat 1000 1"
SORT_O="${EST_470_SORT_GT_O} 1000 1"
if [ ${IT} = Q ]
then
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS
		ACMTRS_NT	45:1 - 45:,
		ESTCRB_CT	50:1 - 50:	
	/KEYS
		ACMTRS_NT
	/CONDITION QUART ESTCRB_CT = "T" or ESTCRB_CT = "U"
	/INCLUDE QUART
	/OUTFILE ${SORT_O}
	exit
EOF
SORT
else
INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS
		ACMTRS_NT	45:1 - 45:,
		ESTCRB_CT	50:1 - 50:	
	/KEYS
		ACMTRS_NT
	/CONDITION YEAR ESTCRB_CT != "T" and ESTCRB_CT != "U"
	/INCLUDE YEAR
	/OUTFILE ${SORT_O}
	exit
EOF
SORT
fi

# ------------------------------------
gzip -c ${EST_430_SORT_GT_O}								> ${DFILT}/${NJOB}_430_SORT_GT${IT}_O.dat.gz
gzip -c ${DFILT}/${NJOB}_460_${IB}_SORT_GT${IT}_O1N.dat		> ${DFILT}/${NJOB}_460_SORT_GT${IT}_O1N.dat.gz
gzip -c ${DFILT}/${NJOB}_440_${IB}_SORT_GT${IT}_O.dat		> ${DFILT}/${NJOB}_440_SORT_GT${IT}_O.dat.gz
# ------------------------------------

NSTEP=${NJOB}_480
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"


# Job End
JOBEND
