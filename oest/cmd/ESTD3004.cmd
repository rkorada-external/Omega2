#!/bin/ksh
#=============================================================================
# maj de l'application:          ESTIMATIONS - TRANSFERT PORTEFEUILLE INTER-SITES
# nom du script SHELL:           ESTD3004.cmd
# revision: $Revision:           1.1  $
# date de creation:              29/11/2006
# auteur:                        J.Ribot
# references des specifications : SPOT EST13427
#-----------------------------------------------------------------------------
# description
#   Transfert Amerique du Sud
#
# job launched by ESTD3000.cmd
#
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#la table BTRAV..RET_ESTM7002_CONTRATS_ACCEPT est chargée par scripte
#
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#     <JJ/MM/AAAA> <Auteur >  <Description de la modification>
# [02] 07/07/2011   Florent    :spot:22328 ajout de 16 champs dans le GTA
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Entry parameters
BLCSHT_D=${1}
BALSHEY_NF=${2}
BALSHTMTH_NF=${3}
ESTIM_B=${4}
FORCEBILAN=${5}
CREATION_GT=${6}

# Initialization of the Job
JOBINIT

NSTEP=${NJOB}_10
# Bcp out
#--------------------------------
LIBEL="Transferring table BTRAV..RET_ESTM7002_CONTRATS_ACCEPT into file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="select CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT,RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT,RCL_NF,PLC_NT,RTO_NF,INT_NF,RETPAY_NF,RETKEY_CF,TAUXCESSION FROM BTRAV..RET_ESTM7002_CONTRATS order by CTR_NF,END_NT,SEC_NF,UWY_NF,UW_NT"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_RET_ESTM7002_CONTRATS_ACCEPT_O.dat
BCP

NSTEP=${NJOB}_15
# Bcp out
#--------------------------------
LIBEL="Transferring table BTRAV..RET_ESTM7002_CONTRATS_RETRO into file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_QRY="select a.RETCTR_NF, a.RETEND_NT, a.RETSEC_NF, a.RTY_NF, a.RETUW_NT, b.LOB_CF FROM BTRAV..RET_ESTM7002_CONTRATS a, BRET..TRETSEC b
where a.RETCTR_NF = b.RETCTR_NF and a.RETEND_NT = b.RETEND_NT and a.RETSEC_NF = b.RETSEC_NF and a.RTY_NF = b.RTY_NF and a.RETUW_NT = b.RETUW_NT
  order by RETCTR_NF,RETEND_NT,RETSEC_NF,RTY_NF,RETUW_NT"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_RET_ESTM7002_CONTRATS_RETRO_O.dat
BCP

NSTEP=${NJOB}_20
# MOD003 -  Sort of Last Generated GTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_GTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3000_ESTD3003_GTA_TRANSFP.dat  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_GTA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_25
# MOD003 -  Sort of Last Generated GTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_GTA_EST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESTD3000_ESTD3003_GTA_TRANSFP_EST.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_GTA_EST.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_30
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for GTA"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_TRANSFP_GTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_ACCEPT_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTR_TRANSFP_GTAR.dat
export ${PRG}_O2=${DFILI}/${NJOB}_GTR_TRANSFP_GTR.dat
EXECPRG

NSTEP=${NJOB}_35
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for GTA_EST"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_25_${IB}_SORT_TRANSFP_GTA_EST.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_ACCEPT_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTR_TRANSFP_GTAR_EST.dat
export ${PRG}_O2=${DFILI}/${NJOB}_GTR_TRANSFP_GTR_EST.dat
EXECPRG

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_TRANSFP_GTA.dat
RMFIL ${DFILT}/${NJOB}_25_${IB}_SORT_TRANSFP_GTA_EST.dat

NSTEP=${NJOB}_50
# MOD003 -  Sort of Last Generated CURGTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_CURGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3000_ESTD3003_CURGTA_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_CURGTA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_55
# MOD003 -  Sort of Last Generated CURGTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_CURGTA_EST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESTD3000_ESTD3003_CURGTA_TRANSFP_EST.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_CURGTA_EST.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_60
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for CURGTA"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_TRANSFP_CURGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_ACCEPT_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTR_TRANSFP_CURGTAR.dat
export ${PRG}_O2=${DFILI}/${NJOB}_GTR_TRANSFP_CURGTR.dat
EXECPRG

NSTEP=${NJOB}_65
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for CURGTA_EST"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_55_${IB}_SORT_TRANSFP_CURGTA_EST.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_ACCEPT_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_GTR_TRANSFP_CURGTAR_EST.dat
export ${PRG}_O2=${DFILI}/${NJOB}_GTR_TRANSFP_CURGTR_EST.dat
EXECPRG

NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_TRANSFP_CURGTA.dat
RMFIL ${DFILT}/${NJOB}_55_${IB}_SORT_TRANSFP_CURGTA_EST.dat

NSTEP=${NJOB}_80
# MOD003 -  Sort of Last Generated CURGTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_ARCSTATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3000_ESTD3003_ARCSTATGTA_TRANSFP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_ARCSTATGTA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_85
# MOD003 -  Sort of Last Generated GTA Files in ESTM7001
#-----------------------------------------------------------------------------
LIBEL="Sort of TRANSFP_ARCSTATGTA_EST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESTD3000_ESTD3003_ARCSTATGTA_TRANSFP_EST.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TRANSFP_ARCSTATGTA_EST.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_90
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for TRANSFP_ARCSTATGTA"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_TRANSFP_ARCSTATGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_ACCEPT_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_ARCSTATGTR_TRANSFP_ARCSTATGTAR.dat
export ${PRG}_O2=${DFILI}/${NJOB}_ARCSTATGTR_TRANSFP_ARCSTATGTR.dat
EXECPRG


NSTEP=${NJOB}_95
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of GTR Files for TRANSFP_ARCSTATGTA_EST"
PRG=ESTM7608
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BLCSHT_D ${BLCSHT_D}
BALSHEY_NF ${BALSHEY_NF}
ESTIM_B ${ESTIM_B}
FORCEBILAN ${FORCEBILAN}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_85_${IB}_SORT_TRANSFP_ARCSTATGTA_EST.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_BCP_RET_ESTM7002_CONTRATS_ACCEPT_O.dat
export ${PRG}_O1=${DFILI}/${NJOB}_ARCSTATGTR_TRANSFP_ARCSTATGTAR_EST.dat
export ${PRG}_O2=${DFILI}/${NJOB}_ARCSTATGTR_TRANSFP_ARCSTATGTR_EST.dat
EXECPRG


### STATGTR

NSTEP=${NJOB}_100
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Split GTR ==> delta(CURGTR), GTR-CURGTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3000_ESTD3004_CURGTR_TRANSFP_GTR.dat 1000 1"
if [ ${CREATION_GT} = 0 ]
then
SORT_I2="${DFILI}/${PCH}ESTD3000_ESTD3004_GTR_TRANSFP_GTR.dat 1000 1"
fi
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTR_O.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY  3:1 - 3: EN,
	BALSHTMTH  4:1 - 4: EN,
	TRNCOD_CF 6:1 - 6:,
		TRNCOD1_CF 6:1 - 6:1,
		TRNCOD2C_CF 6:2 - 6:2 ,
		TRNCOD8_CF 6:8 - 6:8 EN
/CONDITION AVANT_PERIODE	( BALSHEY = ${BALSHEY_NF} and BALSHTMTH <= ${BALSHTMTH_NF} )
/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE
/COPY
exit
EOF

SORT


NSTEP=${NJOB}_105
# Begin Sort
#-----------------------------------------------------------------
LIBEL="SORT GTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_SORT_CURGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTR_O.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
	RETCTR_NF 24:1 - 24:,
 	RETEND_NT 25:1 - 25:,
 	RETSEC_NF 26:1 - 26:,
 	RTY_NF 27:1 - 27:,
 	RETUW_NT 28:1 - 28:
/KEYS
	RETCTR_NF,
 	RETEND_NT,
        RETSEC_NF,
        RTY_NF ,
        RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_115
#Dividing of STATGTR in retrocession by acceptance life and non-life
#-----------------------------------------------------------------------------
LIBEL="Eliminating Non-life transactions of GTR"
PRG=ESTM7606
export ${PRG}_I1=${DFILT}/${NJOB}_105_${IB}_SORT_GTR_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_15_BCP_RET_ESTM7002_CONTRATS_RETRO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DGTR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRANO.ano
EXECPRG

NSTEP=${NJOB}_120
# Accumulation of GTR amounts and merge with STATGTR [02]
#------------------------------------------------------------------------------
LIBEL="Accumulation of GTR amounts and merge with STATGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_115_${IB}_ESTM7606_GTR_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_STATGTR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF 1:1 - 1:,
	ESB_CF 2:1 - 2:,
	BALSHEY_NF 3:1 - 3:,
	BALSHRMTH_NF 4:1 - 4:,
	BALSHRDAY_NF 5:1 - 5:,
	TRNCOD_CF 6:1 - 6:,
		TRNCOD1_CF 6:1 - 6:1,
		TRNCOD8_CF 6:8 - 6:8 EN,
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
	SSD_CF ,
	ESB_CF ,
	BALSHEY_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF ,
	CTR_NF ,
	END_NT ,
	SEC_NF ,
	UWY_NF ,
	UW_NT ,
	OCCYEA_NF ,
	ACY_NF ,
	SCOSTRMTH_NF ,
	SCOENDMTH_NF ,
	CLM_NF ,
	CUR_CF ,
	CED_NF ,
	BRK_NF ,
	PAY_NF ,
	KEY_NF ,
	RETCTR_NF ,
	RETEND_NT ,
	RETSEC_NF ,
	RTY_NF ,
	RETUW_NT ,
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
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_125
# Begin Sort
#-----------------------------------------------------------------
LIBEL="EST_STATGTR sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_120_${IB}_SORT_STATGTR_O.dat
SORT_O="${DFILI}/${NJOB}_STATGTR_TRANSFP_STATGTR.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
	RETCTR_NF 24:1 - 24:,
	RETEND_NT 25:1 - 25:,
	RETSEC_NF 26:1 - 26:,
	RTY_NF 27:1 - 27:,
	RETUW_NT 28:1 - 28:
/KEYS
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF ,
	RETUW_NT
exit
EOF
SORT


# STAGTR EST


NSTEP=${NJOB}_130
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Split GTR ==> delta(CURGTR), GTR-CURGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILI}/${PCH}ESTD3000_ESTD3004_CURGTR_TRANSFP_GTR_EST.dat 1000 1"
if [ ${CREATION_GT} = 0 ]
then
SORT_I2="${DFILI}/${PCH}ESTD3000_ESTD3004_GTR_TRANSFP_GTR_EST.dat 1000 1"
fi
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTR_O.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY  3:1 - 3: EN,
	BALSHTMTH  4:1 - 4: EN,
	TRNCOD_CF 6:1 - 6:,
		TRNCOD1_CF 6:1 - 6:1,
		TRNCOD2C_CF 6:2 - 6:2 ,
		TRNCOD8_CF 6:8 - 6:8 EN
/CONDITION AVANT_PERIODE	( BALSHEY = ${BALSHEY_NF} and BALSHTMTH <= ${BALSHTMTH_NF} )
/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE
/COPY
exit
EOF

SORT


NSTEP=${NJOB}_135
# Begin Sort
#-----------------------------------------------------------------
LIBEL="SORT GTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_SORT_CURGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTR_O.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
	RETCTR_NF 24:1 - 24:,
 	RETEND_NT 25:1 - 25:,
 	RETSEC_NF 26:1 - 26:,
 	RTY_NF 27:1 - 27:,
 	RETUW_NT 28:1 - 28:
/KEYS
	RETCTR_NF,
 	RETEND_NT,
        RETSEC_NF,
        RTY_NF ,
        RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_140
#Dividing of STATGTR in retrocession by acceptance life and non-life
#-----------------------------------------------------------------------------
LIBEL="Eliminating Non-life transactions of GTR"
PRG=ESTM7606
export ${PRG}_I1=${DFILT}/${NJOB}_135_${IB}_SORT_GTR_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_15_BCP_RET_ESTM7002_CONTRATS_RETRO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DGTR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRANO.ano
EXECPRG

NSTEP=${NJOB}_145
# Accumulation of GTR amounts and merge with STATGTR [02]
#------------------------------------------------------------------------------
LIBEL="Accumulation of GTR amounts and merge with STATGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_140_${IB}_ESTM7606_GTR_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_STATGTR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF 1:1 - 1:,
	ESB_CF 2:1 - 2:,
	BALSHEY_NF 3:1 - 3:,
	BALSHRMTH_NF 4:1 - 4:,
	BALSHRDAY_NF 5:1 - 5:,
	TRNCOD_CF 6:1 - 6:,
		TRNCOD1_CF 6:1 - 6:1,
		TRNCOD8_CF 6:8 - 6:8 EN,
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
	SSD_CF ,
	ESB_CF ,
	BALSHEY_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF ,
	CTR_NF ,
	END_NT ,
	SEC_NF ,
	UWY_NF ,
	UW_NT ,
	OCCYEA_NF ,
	ACY_NF ,
	SCOSTRMTH_NF ,
	SCOENDMTH_NF ,
	CLM_NF ,
	CUR_CF ,
	CED_NF ,
	BRK_NF ,
	PAY_NF ,
	KEY_NF ,
	RETCTR_NF ,
	RETEND_NT ,
	RETSEC_NF ,
	RTY_NF ,
	RETUW_NT ,
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
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_150
# Begin Sort
#-----------------------------------------------------------------
LIBEL="EST_STATGTR sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_145_${IB}_SORT_STATGTR_O.dat
SORT_O="${DFILI}/${NJOB}_STATGTR_TRANSFP_STATGTR_EST.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
	RETCTR_NF 24:1 - 24:,
	RETEND_NT 25:1 - 25:,
	RETSEC_NF 26:1 - 26:,
	RTY_NF 27:1 - 27:,
	RETUW_NT 28:1 - 28:
/KEYS
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF ,
	RETUW_NT
exit
EOF
SORT


NSTEP=${NJOB}_160
# delete old temporary Data files
#---------------------------------------------------------------
LIBEL="delete old temporary Data files"
RMFIL "${DFILT}/${NJOB}*_${IB}*.dat"

JOBEND

