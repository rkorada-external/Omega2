#!/bin/ksh
#set -x

#################################################################
# Spira 91792 PRD : annulation EBS Q3 pas correcte
# Annulation des lignes mois bilan 2020331 a injecter dans CURGTA
#################################################################

NCHAIN=${ENV_PREFIX}_CNLD0030
NJOB=${NCHAIN}_REPRANNU

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

spira=91792
datej=`date '+%Y%m%d%H%M%S'`

#DFILP2=/scordata_dcvprdobbatch/ubeu/perm
#DFTP=/scor/livraison/tmp/UAT_O2_UBEU

#cp $DFILT/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO_20200630_20200708_ubas.dat $dftp/TMAI_O2_UBAS/T_ESPD3800_FTECLEDASIISO_20200630_20200708_ubas.dat
#cp $DFILT/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO_20200630_20200708_ubam.dat $dftp/TMAI_O2_UBAM/T_ESPD3800_FTECLEDASIISO_20200630_20200708_ubam.dat
#cp $DFILT/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO_20200630_20200708_ubeu.dat $dftp/TMAI_O2_UBEU/T_ESPD3800_FTECLEDASIISO_20200630_20200708_ubeu.dat

if [ "${HOSTNAME}" = "dcvdevobbatch" ]
then
	#############################################
	###  ATTENTION pour TESTS DEV
	site=ubam
	#############################################
	echo "---> Copie fichiers GT de Prod sur Dev"
	DARCH2=/scordata_dcvprdobbatch/${site}/arch
	DFILP2=/scordata_dcvprdobbatch/${site}/perm
	cp $DARCH2/P_ESPD3800_FTECLEDASIISO_20200630_20200708.dat.gz $DARCH
	cp $DFILP2/P_ESIX7000_CURGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
	zgrep 2020~03~31~ $DARCH/P_ESPD3800_FTECLEDASIISO_20200630_20200708.dat.gz > $DFILT/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO_20200630_20200708_${site}.dat
else
	site=$DEFAULT_SQL_LOGIN
	if [ "${HOSTNAME}" = "dcvprdobbatch" ]
	then
		zgrep 2020~03~31~ $DARCH/P_ESPD3800_FTECLEDASIISO_20200630_20200708.dat.gz > $DFILT/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO_20200630_20200708_${site}.dat
	fi
fi


NSTEP=${NJOB}_00
# Begin Sort
#-----------------------------------------------------------------
LIBEL="reformat du $DFILT/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO_20200630_20200708_${site}.dat en fichier CURGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${ENV_PREFIX}_ESPD3800_FTECLEDASIISO_20200630_20200708_${site}.dat 1000  1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O1_${site}.dat
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

NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Annulation des montants"
AWK_I=${DFILT}/${NJOB}_00_${IB}_SORT_CURGTA_O1_${site}.dat
AWK_O=${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA_AnnulOImoisBilan3_20200630_annul_spira_${spira}_${site}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
		if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
		if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
		if (\$41  != 0) \$41 = sprintf("%-.3lf",-\$41);
		print \$0;
}
exit
EOF
AWK

###################################################################
echo "--> ****  maj CURGTA ${site} ********************************"

echo "---> Sauvegarde ancien CURGTA"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat > ${DSAV}/${ENV_PREFIX}_ESIX7000_CURGTA_avantspira_${spira}_${datej}.dat.gz

echo "---> Archivage corrections"
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA_AnnulOImoisBilan3_20200630_annul_spira_${spira}_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTA_AnnulOImoisBilan3_20200930_annul_spira_${spira}_${site}.dat.gz

echo "---> Comptage avant"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA_AnnulOImoisBilan3_20200630_annul_spira_${spira}_${site}.dat

#############################################################################################
#############################################################################################
#  Tester sans mettre a jour,
#  Si tout ok, retirer le JOBEND pour faire les mises a jour
#JOBEND
#############################################################################################
#############################################################################################

echo "---> Ajoute corrections au CURGTA"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA_AnnulOImoisBilan3_20200630_annul_spira_${spira}_${site}.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat

echo "---> Comptage apres"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat

nb1=1000
nb2=1001
if [ "$site" = "ubas" ]
then
	nb1=97
	nb2=98
fi
if [ "$site" = "ubam" ]
then
	nb1=260
	nb2=261
fi

echo "---> liste des $nb1 mouvements ajoutes +1 (sauf pour EU car trop de lignes) non ajoute dans ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat"
tail -$nb2 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat

JOBEND

