
# ****************************************************
datej=`date '+%Y%m%d%H%M%S'`

echo "********************************************************************************"
echo "===>  :spira:69775 et 70042 Annulation des écritures POSI Asie 1T2018 qui ont été ajoutées dans le traitement 2T2018"
echo "********************************************************************************"

#Ce sont que les écritures de service du POSI (960 records mais uniquement 190 lignes concernées).
#Ces écritures ont été mises dans le FTECLEDASO.dat. C’est vrai qu’il faudra les annuler du CURGTA et du FTECLEDASO.
#Oui, c’est le fichier pris par EBS en entrée dans le ESID3703.cmd
#Les lignes sont en date du 20180314 :
#-	Sur perm
#grep ~20180314~ P_ESPD3800_FTECLEDASO.dat | wc -l
#190
#
#-	Dans ARCH
#zcat P_ESPD3800_FTECLEDASO_CUR_20180331.dat.gz | grep ~20180314~ | wc -l                          
#190
#
#Voilà le fichier que j’ai contrôlé avec celui de Martine (1er fichier de ton mail : documentsocialAsie.xls).
#
#Dans mon fichier, c’est l’onglet « image fic Martine 20180314 » qui correspond à ce qu’il faut retirer FTECLEDASO, annuler du CURGTA. 


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 

#CHAININIT $0 CNLD0000.env

# Job Initialisation
JOBINIT

NJOB="MAJCURGT"

datej=`date '+%Y%m%d%H%M%S'`

DARCH2=${DARCH}
if [ "${HOSTNAME}" = "dcvdevobbatch" ]
then
	DFILP2=$dprddat/ubas/perm
	DARCH2=$dprddat/ubas/arch
	cp $DFILP2/P_ESIX7000_CURGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
	ls -lrtFA ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
fi

echo "---> DARCH = ${DARCH}"

if [ "${HOSTNAME}" = "dcvdevobbatch" -o "${HOSTNAME}" = "dcvprdobbatch" ]
then
	echo "---> Extraction données à inverser"
	###################################################################################
	# ATTENTION : en commentaire pour Test UAT car fichier différent de celui de prod
	zcat ${DARCH2}/P_ESPD3800_FTECLEDASO_CUR_20180331.dat.gz | grep ~20180314~ > ${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad.dat
	###################################################################################
fi

if [ ! -s ${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad.dat ]
then
	ECHO_LOG "======================================================================="
	ECHO_LOG "Fichier ${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad.dat non trouvé, le transférer par ftp - ARRET"
	ECHO_LOG "======================================================================="
	JOBEND
else
	wc -l ${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad.dat
fi

echo "---> Annulations ecritures"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
 	if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
	if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
	if ($88 != 0) $88 = sprintf("%-.3lf",-$88)
	print $0
}' \
 ${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad.dat > ${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad_annul0.dat

NSTEP=${NJOB}_00
# Begin Sort
#-----------------------------------------------------------------
LIBEL="reformat du FTECLEDASO_CUR en fichier CURGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad_annul0.dat 1000  1"
SORT_O=${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad_annul.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FORMAT_STANDARD      1:1 -  40:,
        PLUS_16_CHAMPS      88:1 - 103:,
        FILLER_14_COLS     105:1 - 118:
/DERIVEDFIELD ORICOD_LS "CURGTA_PO~"
/OUTFILE ${SORT_O}
/REFORMAT FORMAT_STANDARD, PLUS_16_CHAMPS, ORICOD_LS, FILLER_14_COLS
exit
EOF
SORT
 
echo "--> Sauvegarde ancien CURGTA"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat > ${DSAV}/${ENV_PREFIX}_ESIX7000_CURGTA_${datej}.dat.gz

echo "--> Données en entrée"
cat ${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad.dat

echo "--> Données ajoutées"
cat ${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad_annul.dat

echo "********************************************************************************"
echo "--> **************** Début maj fichier ${ENV_PREFIX}_ESIX7000_CURGTA.dat - ${datej}"
echo "********************************************************************************"

echo "--> Comptage ancien CURGTA et l'ajout"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat ${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad_annul.dat

echo "--> Archivage données ajoutées"
gzip -c ${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad_annul.dat > ${DARCH}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad_annul_spira69775.dat.gz

#############################################################################################
#############################################################################################
#  Tester sans mettre à jour, 
#  Si tout ok, retirer le JOBEND pour faire les mises à jour
#JOBEND
#############################################################################################
#############################################################################################
echo "--> Ajout fichier au ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat"
cat ${DFILT}/${ENV_PREFIX}_FTECLEDASO_CUR_20180331_bad_annul.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat

echo "--> Comptage nouveau ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat

datej=`date '+%Y%m%d%H%M%S'`

echo "********************************************************************************"
echo "--> **************** Fin   maj fichier ${ENV_PREFIX}_ESIX7000_CURGTA.dat - ${datej}"
echo "********************************************************************************"


#############################################################################################
#############################################################################################
###  RECALCUL STATGTA
#############################################################################################
#############################################################################################

DFILP2=${DFILP}
# Adapter les variables
if [ "${HOSTNAME}" = "dcvdevobbatch" ]
then
	DFILP2=$dprddat/ubas/perm
	ENV_PREFIX2=P
	cp $DFILP2/${ENV_PREFIX2}_ESIX7000_STATGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat

	SRV_2=DEV_TPO2
	NSTEP=${NJOB}_05
	# Switch to Infomega server
	#---------------------------------------------------------------
	LIBEL="Switch to TP server ${SRV_2}"
	SWITCH_SRV ${SRV_2}
fi

#site=ubeu
#DEXE=$dprd/scoromega/runnable/exe

#cp $dprd/scordata/${site}/arch/P_ESIX7000_CURGTA_201612_apres_201612*.dat.gz $DFILT/${ENV_PREFIX}_ESIX7000_CURGTA.dat.gz
#gunzip -c $DFILT/${ENV_PREFIX}_ESIX7000_CURGTA.dat.gz > $DFILP2/${ENV_PREFIX}_ESIX7000_CURGTA.dat

echo "==> sauve STATGTA"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat > ${DSAVE}/${ENV_PREFIX}_ESIX7000_STATGTA_${datej}.dat.gz

wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat

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
SORT_I="${DFILP2}/${ENV_PREFIX}_ESIX7000_CURGTA.dat 800  1"
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
mv ${DFILT}/${NJOB}_85_${IB}_SORT_STATGTA_O.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat

echo "--> STATGTA nouveau"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_STATGTA.dat

JOBEND
