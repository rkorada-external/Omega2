#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - TRANSFERT PORTEFEUILLE INTER-SITES
# nom du script SHELL:           ESTD3042.cmd
# revision: $Revision:           1.1  $
# date de creation:              05/10/2006
# auteur:                        J.Ribot
# references des specifications : SPOT EST13427
#-----------------------------------------------------------------------------
# description
#   Transfert indiens
#
# job launched by ESTD3040.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#     <JJ/MM/AAAA> <Auteur >  <Description de la modification>
# [02] 07/07/2011   Florent    :spot:22328 ajout de 16 champs dans le GTA
#
#===============================================================================

# Call generic functions

. ${DUTI}/fctgen.cmd

#set -x

# Entry parameters
BLCSHT_D=${1}
BALSHEY_NF=${2}

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_05
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Extract bilan 2007  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESTD3000_ESTD3003_CURGTA_TRANSFP.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS  BALSHEY  3:1 - 3: EN
/CONDITION EX2007 ( BALSHEY  = 2007 )
/OUTFILE ${SORT_O}
/INCLUDE EX2007
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_10
# Inversion of estimates amounts before using pour CURGTA
#-----------------------------------------------------------------------------
LIBEL="Inversion of estimates amounts before using"
AWK_I=${DFILT}/${NJOB}_05_${IB}_SORT_CURGTA.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_CURGTA.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
      {if      (\$3 == "2007") \$19 = -\$19 ; \$35 = -\$35 ; \$41 = -\$41 ;
                \$19=sprintf("%.3lf",\$19);
                \$35=sprintf("%.3lf",\$35);
                \$41=sprintf("%.3lf",\$41);
           {   print \$0  }}
exit
EOF
AWK



NSTEP=${NJOB}_15
# Accumulation of CURGTA + CURGTA montants inversés
#------------------------------------------------------------------------------
LIBEL="Accumulation of CURGTA + CURGTA montants inversés"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_AWK_CURGTA.dat 1000 1"
#SORT_I2="${DFILP}/${PCH}ESIX7000_CURGTA.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_20
# Begin Sort
#-----------------------------------------------------------------
LIBEL="CURGTA sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_CURGTA_O.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_CURGTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
	CTR_NF 8:1 - 8:,
	END_NT 9:1 - 9:,
	SEC_NF 10:1 - 10:,
	UWY_NF 11:1 - 11:,
	UW_NT 12:1 - 12:,
	OCCYEA_NF 13:1 - 13:,
	ACY_NF 14:1 - 14:,
	SCOSTRMTH_NF 15:1 - 15:,
	SCOENDMTH_NF 16:1 - 16:,
	CLM_NF 17:1 - 17:,
	CUR_CF 18:1 - 18:,
	RETCTR_NF 24:1 - 24:,
	RETEND_NT 25:1 - 25:,
	RETSEC_NF 26:1 - 26:,
	RTY_NF 27:1 - 27:,
	RETUW_NT 28:1 - 28:
/KEYS
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT ,
        OCCYEA_NF ,
        ACY_NF ,
        SCOSTRMTH_NF ,
        SCOENDMTH_NF ,
        CLM_NF,
        CUR_CF
exit
EOF
SORT

#NSTEP=${NJOB}_22
## force bilan 20061231 pour arcstatgta
##-----------------------------------------------------------------------------
#LIBEL="Inversion of estimates  amounts before using"
#AWK_I=${DFILT}/${NJOB}_05_${IB}_SORT_CURGTA.dat
#AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_ARCSTATGTA.dat
#
#AWK_CMD=`CFTMP`
#INPUT_TEXT ${AWK_CMD} <<EOF
#BEGIN{ FS="\~"; OFS="\~" ; s="\"}
#      {if      (\$3 == "2007") \$3 = "2006" ; \$4 = "12" ; \$5 = "31" ;
#           {   print \$0  }}
#exit
#EOF
#AWK

NSTEP=${NJOB}_25
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Extraction des tables"
PRG=ESTX7009
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRCROSSREF.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_CLMCROSSREF.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_DETTRS.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FACCROSSREF.dat
EXECPRG

NSTEP=${NJOB}_27
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Extraction des tables"
PRG=ESTX7017
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRSECTION.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FACSECTION.dat
EXECPRG

NSTEP=${NJOB}_29
# Sort binary file
#------------------------------------------------------------------------------
LIBEL="Sort of binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_27_${IB}_ESTX7017_CTRSECTION.dat fixed 18"
SORT_I2="${DFILT}/${NJOB}_27_${IB}_ESTX7017_FACSECTION.dat fixed 18"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TRTFACSECTION.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
   CTR_NF	1 CHAR 10,
   UW_NT  11 UINTEGER 1,
   END_NT	12 UINTEGER 1,
   UWY_NF 13 INT 4,
   SEC_NF	17 UINTEGER 1
/KEYS
   CTR_NF,
   UW_NT,
   END_NT,
   UWY_NF,
   SEC_NF
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of bilan-1 a partir curgta pour arcstatgta"
PRG=ESTM7010
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_CURGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_25_${IB}_ESTX7009_DETTRS.dat
export ${PRG}_I3=${DFILT}/${NJOB}_29_${IB}_SORT_TRTFACSECTION.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ARCSTATGTA_B1.dat
EXECPRG


NSTEP=${NJOB}_35
# Merge P_ESIX7000_ARCSTATGTA.dat et CURGTA Bilan 2006 [02]
#------------------------------------------------------------------------------
LIBEL="Merge P_ESIX7000_ARCSTATGTA.dat et CURGTA Bilan 2006"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTM7010_ARCSTATGTA_B1.dat 1000 1"
SORT_I2="${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat 1000 1"
SORT_O="${DFILT}/${PCH}ESIX7000_ARCSTATGTA.dat.new 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF 1:1 - 1:,
	ESB_CF 2:1 - 2:,
	BALSHEY_NF 3:1 - 3:,
	BALSHRMTH_NF 4:1 - 4:,
	BALSHRDAY_NF 5:1 - 5:,
	TRNCOD_CF 6:1 - 6:,
		TRNCOD1_CF 6:1 - 6:1,
		TRNCOD8_CF 6:8 - 6:8 EN ,
	DBLTRNCOD_CF 7:1 - 7:,
	CTR_NF 8:1 - 8:,
	END_NT 9:1 - 9:,
	SEC_NF 10:1 - 10:,
	UWY_NF 11:1 - 11:,
	UW_NT 12:1 - 12:,
	OCCYEA_NF 13:1 - 13:,
	ACY_NF 14:1 - 14:,
	SCOSTRMTH_NF 15:1 - 15:,
	SCOENDMTH_NF 16:1 - 16:,
	CLM_NF 17:1 - 17:,
	CUR_CF 18:1 - 18:,
	AMT_M 19:1 - 19:EN 15/3,
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
	RETAMT_M 35:1 - 35:EN 15/3,
	PLC_NT 36:1 - 36:,
	RTO_NF 37:1 - 37:,
	INT_NF 38:1 - 38:,
	RETPAY_NF 39:1 - 39:,
	RETKEY_CF 40:1 - 40:,
	RETINTAMT_M 41:1 - 41:EN 15/3,
	BUKRS_CF 42:1 - 42:,
	RCOMP_CF 43:1 - 43:,
	LDGRP_CF 44:1 - 44:,
	HKONT_CF 45:1 - 45:,
	DBLHKONT_CF 46:1 - 46:,
	GJAHR_NF 47:1 - 47:,
	MONAT_NF 48:1 - 48:,
	VBUND_CF 49:1 - 49:,
	ZZCED_NF 50:1 - 50:,
	SEGMENT_CF 51:1 - 51:,
	BEWAR_CF 52:1 - 52:,
	ZZGAAPDIF_CF 53:1 - 53:,
	BLART_CF 54:1 - 54:,
	ZZRECONKEY_CF 55:1 - 55:,
	TRN_NT 56:1 - 56:,
	FILETYP_CF 57:1 - 57:
/KEYS
	CTR_NF ,
	END_NT ,
	SEC_NF ,
	UWY_NF ,
	UW_NT ,
	OCCYEA_NF ,
	ACY_NF ,
	SCOSTRMTH_NF ,
	SCOENDMTH_NF ,
	CLM_NF,
	CUR_CF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF ,
	RETUW_NT,
	SSD_CF ,
	ESB_CF ,
	BALSHEY_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF ,
	CED_NF ,
	BRK_NF ,
	PAY_NF ,
	KEY_NF ,
	RETOCCYEA_NF ,
	RETACY_NF ,
	RETSCOSTRMTH_NF ,
	RETSCOENDMTH_NF ,
	RCL_NF ,
	RETCUR_CF ,
	PLC_NT ,
	RTO_NF ,
	INT_NF ,
	RETPAY_NF ,
	RETKEY_CF
exit
EOF
SORT

#NSTEP=${NJOB}_35
## Begin Remove
##--------------------------------------------------------------------------
#LIBEL="move $DFILT/${PCH}ESIX7000_CURGTA.dat.new $DFILP/${PCH}ESIX7000_CURGTA.dat"
#EXECKSH "mv $DFILT/${PCH}ESIX7000_CURGTA.dat.new $DFILP/${PCH}ESIX7000_CURGTA.dat"
#
#
#NSTEP=${NJOB}_40
## Begin Remove
##--------------------------------------------------------------------------
#LIBEL="move $DFILT/${PCH}ESIX7000_ARCSTATGTA.dat.new $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat"
#EXECKSH "mv $DFILT/${PCH}ESIX7000_ARCSTATGTA.dat.new $DFILP/${PCH}ESIX7000_ARCSTATGTA.dat"

NSTEP=${NJOB}_45
# delete old temporary Data files
#---------------------------------------------------------------
LIBEL="delete old temporary Data files"
#RMFIL "${DFILT}/${NJOB}*_${IB}*.dat"


JOBEND


