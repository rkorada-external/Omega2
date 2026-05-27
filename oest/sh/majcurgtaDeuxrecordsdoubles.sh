# Spira 67528 probleme general sur poste 21121100 - 2eme correction -> mise a jour du montant de retro interne.
#
#set -x

NCHAIN=${ENV_PREFIX}_CNLD0030
NJOB=CNLD0031

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd
. ${DUTI}/fctftp.cmd

CHAININIT $0 $DENV/CNLD0030.env

# Job Initialisation
JOBINIT

datej=`date '+%Y%m%d%H%M%S'`

#
######################################################################################
#Sur Amerique
######################################################################################

site=ubam

if [ "${BATCH_SRV_HOSTNAME}" = "dcvdevobbatch" ]
then
	echo "---> cree environnement Dev"
	DFILP2=/scordata_dcvprdobbatch/${site}/perm
	ENV_PREFIX2=P
	cp ${DFILP2}/${ENV_PREFIX2}_ESIX7000_CURGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
	cp ${DFILP2}/${ENV_PREFIX2}_ESIX7000_STATGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat
fi

NSTEP=${NJOB}_20
#Php
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Formatage du FTECLEDA en CURGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/P_OTGL0010_FTECLEDA_MVT_USA1_20180501b_RECUBE_21398-25738.dat 800 1"
SORT_O=""${DFILT}/${ENV_PREFIX}_OTGL0010_FTECLEDA_MVT_USA1_20180501b_RECUBE_21398-25738_new.dat 800 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FORMAT_STANDARD     1:1 -  40:,
        BALSHEY             3:1 -   3: EN,
        BALSHTMTH           4:1 -   4: EN,
        BALSHTDAY           5:1 -   5: EN,
        TRNCOD_CF           6:1 -   6:,
        TRNCOD1_CF          6:1 -   6:1,
        TRNCOD8_CF          6:8 -   6:8,
        RETINTAMT_M        88:1 -  88:,
        PLUS_13_CHAMPS     89:1 - 101:,
        KeyReconciliation 102:1 - 102:,
        TRN_NT            103:1 - 103:,
        FILLER_14_COLS    105:1 - 118:
/DERIVEDFIELD  ORICOD_LS "CURGTA~"
/DERIVEDFIELD  PLUS_14_CHAMPS 14"~"
/OUTFILE ${SORT_O}
/REFORMAT FORMAT_STANDARD,RETINTAMT_M,PLUS_14_CHAMPS,TRN_NT,ORICOD_LS,FILLER_14_COLS
exit
EOF
SORT

###################################################################
echo "--> ****  maj CURGTA ${site} ********************************"

echo "---> Omission lignes a remplacer dans CURGTA"
grep -v 180502OT155833N00001 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA.dat

echo "---> Sauvegarde ancien CURGTA"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat > ${DSAV}/${ENV_PREFIX}_ESIX7000_CURGTA_${datej}.dat.gz

echo "---> Archivage corrections"
gzip -c ${DFILT}/${ENV_PREFIX}_OTGL0010_FTECLEDA_MVT_USA1_20180501b_RECUBE_21398-25738_new.dat > ${DARCH}/P_OTGL0010_FTECLEDA_MVT_USA1_reversedoubles_20180501b_RECUBE_21398-25738_${datej}.dat.gz

echo "---> Comptage avant"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat ${ENV_PREFIX}_OTGL0010_FTECLEDA_MVT_USA1_20180501b_RECUBE_21398-25738_new.dat

echo "---> Mouvements ajoutés"
cat ${ENV_PREFIX}_OTGL0010_FTECLEDA_MVT_USA1_20180501b_RECUBE_21398-25738_new.dat

echo "---> Omission lignes a remplacer dans CURGTA"
grep -v 180502OT155833N00001 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA.dat

echo "---> Comptage CURGTA sans at avec"
wc -l ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
JOBEND
echo "---> Remplace le CURGTA sans les lignes a remplacer"
mv ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA.dat  ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat

echo "---> Ajoute corrections au CURGTA"
cat ${ENV_PREFIX}_OTGL0010_FTECLEDA_MVT_USA1_20180501b_RECUBE_21398-25738_new.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat

echo "---> Comptage apres"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat

echo "--> ****  Fin maj CURGTA ${site} ****************************"

# Adapter les variables
DFILP2=$DFILP
ENV_PREFIX2=${ENV_PREFIX}
#if [ "${HOSTNAME}" = "dcvdevobbatch" ]
#then
#	DFILP2=$dprd/scordata/ubxx/perm
#	cp $DFILP2/P_ESIX7000_CURGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
#	ENV_PREFIX2=P
#fi

#site=ubeu
#DEXE=$dprd/scoromega/runnable/exe

#############################################################################################
#############################################################################################
###  RECALCUL STATGTA
#############################################################################################
#############################################################################################

#cp $dprd/scordata/${site}/arch/P_ESIX7000_CURGTA_201612_apres_201612*.dat.gz $DFILT/${ENV_PREFIX}_ESIX7000_CURGTA.dat.gz
#gunzip -c $DFILT/${ENV_PREFIX}_ESIX7000_CURGTA.dat.gz > $DFILP2/${ENV_PREFIX}_ESIX7000_CURGTA.dat

echo "==> sauve STATGTA"
gzip -c ${DFILP2}/${ENV_PREFIX}_ESIX7000_STATGTA.dat > ${DSAVE}/${ENV_PREFIX}_ESIX7000_STATGTA_${datej}.dat.gz

wc -l ${DFILP2}/${ENV_PREFIX}_ESIX7000_STATGTA.dat

NSTEP=${NJOB}_20
#Generation of CRVPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRVPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_CRVPERICASE0_O.dat
BCP_QRY="execute BEST..PsSECTION_26 "
BCP


NSTEP=${NJOB}_23
#-----------------------------------------------------------------------------
LIBEL="Current Sort of IRVPERICASE Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_BCP_CRVPERICASE0_O.dat 1000"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CRVPERICASE0_O.dat 1000"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:, RETEND_NT 4:1 - 4:, RETSEC_NF 5:1 - 5:, RTY_NF 6:1 - 6:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF
exit
EOF
SORT

NSTEP=${NJOB}_62
#Php
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Extraction des mouvements à partir du CURGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP2}/${ENV_PREFIX2}_ESIX7000_CURGTA.dat 800  1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O5.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O6.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS SSD_CF       1:1 - 1:,
        BALSHEY      3:1 - 3: EN,
        BALSHTMTH    4:1 - 4: EN,
        TRNCOD_CF    6:1 - 6:,
        TRNCOD1_CF   6:1 - 6:1,
        TRNCOD2C_CF  6:2 - 6:2,
        TRNCOD8_CF   6:8 - 6:8
/CONDITION STATGTA 
	(( TRNCOD1_CF = "1" or TRNCOD1_CF = "3" ) and ( TRNCOD8_CF  = "0"  or TRNCOD8_CF  = "1" ))
/CONDITION STATGTAR
   (( TRNCOD1_CF = "2" or TRNCOD1_CF = "4" ) AND ( TRNCOD8_CF  = "0" or TRNCOD8_CF  = "1" ))
/OUTFILE ${SORT_O}
/INCLUDE STATGTA
/OUTFILE ${SORT_O2}
/INCLUDE STATGTAR
exit
EOF
SORT

NSTEP=${NJOB}_65
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Sort GTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_62_${IB}_SORT_GTAR_O6.dat 800 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O1.dat"
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


NSTEP=${NJOB}_75
#Dividing of STATGTR in retrocession by acceptance life and non-life
#-----------------------------------------------------------------------------
LIBEL="Eliminating Non-life transactions of GTAR"
PRG=ESTM7606
export ${PRG}_I1=${DFILT}/${NJOB}_65_${IB}_SORT_GTAR_O1.dat
export ${PRG}_I2=${DFILT}/${NJOB}_23_${IB}_SORT_CRVPERICASE0_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DGTR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_ANOS.dat
EXECPRG


NSTEP=${NJOB}_80
# Accumulation of GTAA + GTAR amounts and merge with STATGTA
#------------------------------------------------------------------------------
LIBEL="Accumulation of GTAA + GTAR amounts and merge with STATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_62_${IB}_SORT_GTAA_O5.dat 800 1"
SORT_I2="${DFILT}/${NJOB}_75_${IB}_ESTM7606_GTAR_O2.dat 800 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_STATGTA_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        TRNCOD8_CF 6:8 - 6:8,
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
        PLUS_13_CHAMPS  42:1 - 54:,
        KeyReconciliation  55:1 - 55:,
        PLUS_2_CHAMPS 56:1 - 57:,
        PLUS_14_CHAMPS 58:1 - 71:
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
        RETKEY_CF,
        KeyReconciliation
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT , SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_MC, PLUS_13_CHAMPS, KeyReconciliation, PLUS_2_CHAMPS, PLUS_14_CHAMPS

exit
EOF
SORT

NSTEP=${NJOB}_85
# Begin Sort
#-----------------------------------------------------------------
LIBEL="STATGTA sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_SORT_STATGTA_O.dat 800 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_STATGTA_O.dat 800 1"
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

echo "==> Maj STATGTA"
mv ${DFILT}/${NJOB}_85_${IB}_SORT_STATGTA_O.dat ${DFILP2}/${ENV_PREFIX}_ESIX7000_STATGTA.dat

echo "--> STATGTA nouveau"
wc -l ${DFILP2}/${ENV_PREFIX}_ESIX7000_STATGTA.dat


JOBEND
