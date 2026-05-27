#
######################################################################################
# Spira 87691 correction du GTA sur devise et montant retamt invalide
######################################################################################
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


#######################################################################################
spira=87691
#######################################################################################

#
#######################################################################################
##Sur EU
#######################################################################################
#
#grep 04P000048 P_ESIX7000_GTA.dat | grep 21121040 | grep 1891264859
#4~1~2020~6~2~21121040~22804000~04T002271~0~1~2002~1~2002~2020~3~3~0~EUR~             22.750~41559~40575~40575~A~04P000048~0~1~2002~1~2002~2020~3~3~0~CNY~     1891264859.880~~~~~ ~              0.000~~~~~~~~~~~~~~~~GTAR~~~~~~~~~~~~~~
##
#######################################################################################


##################################################################
####  ATTENTION
site=ubeu
##################################################################

if [ "${HOSTNAME}" = "dcvdevobbatch" ]
then
echo "---> Copie fichiers GT de Prod sur Dev"
	DFILP2=/scordata_dcvprdobbatch/${site}/perm
#	cp $DFILP2/P_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
#	cp $DFILP2/P_ESIX7000_CURGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
	cp $DFILP2/P_ESIX7000_GTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
#	cp $DFILP2/P_ESIX7000_GTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat
	ls -lrtFA ${DFILP}/${ENV_PREFIX}_ESIX7000_*GT*.dat
fi

# Generation mouvements avec retro interne

echo "---> Extraction du mouvement modele pour generation des mouvements a ajouter"
grep 04P000048 $DFILP/${ENV_PREFIX}_ESIX7000_GTA.dat | grep 21121040 | grep 1891264859 > ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira${spira}_${site}.dat

# Annulation des mouvements GTA et correction pour ajout
echo "---> Annulation des mouvements GTA et correction pour ajout : awk"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
	if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
	if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
	for (i=42; i<57; i++) $i = "";  # rab champs OneGL SAP
	$5 = 7  #Dimanche pour trace
	print $0
	if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
	if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
	$34 = $18
	$35 = $19
	print $0
}' \
 ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira${spira}_${site}.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_annulajoutspira${spira}_${site}.dat

echo "---> Liste des mouvements modele invalides"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira${spira}_${site}.dat

###################################################################

echo "---> liste des mouvements GTA a ajouter"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_annulajoutspira${spira}_${site}.dat

###################################################################

echo "---> Sauvegarde ancien GTA"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat > ${DSAV}/${ENV_PREFIX}_ESIX7000_GTA_avantspira_${spira}_${datej}.dat.gz

echo "---> Archivage corrections"
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_annulajoutspira${spira}_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_GTA_annulajoutspira${spira}_${site}.dat.gz

echo "---> Comptage avant"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_annulajoutspira${spira}_${site}.dat

#############################################################################################
#############################################################################################
#  Tester sans mettre à jour, 
#  Si tout ok, retirer le JOBEND pour faire les mises à jour
#JOBEND
#############################################################################################
#############################################################################################
echo "--> ****  maj GTA et GTR ${site} ********************************"

echo "---> Ajoute corrections au GTA"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_annulajoutspira${spira}_${site}.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

echo "---> Comptage apres"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
#wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat

echo "---> liste des mouvements GTA ajoutés dans ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat"
tail -3 ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

#if [ "${HOSTNAME}" = "dcvdevobbatch" ]
#then
#	# ménage sur Dev
#	rm ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
#	rm ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
#fi

echo "--> ****  Fin maj GTA-GTR ${site} ****************************"


JOBEND