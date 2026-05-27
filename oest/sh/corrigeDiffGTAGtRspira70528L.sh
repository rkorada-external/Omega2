#
######################################################################################
# Spira 70528 correction du GTA en annulant le mouvement en trop dans CURGTA
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

#
######################################################################################
#Sur Europe
######################################################################################

#grep RP0001887 T_ESIX7000_CURGTA.dat | grep 4~20~2018~10~15~21120000 | grep 151067231
#4~20~2018~10~15~21120000~22804000~TR0032840~0~1~2018~1~2018~2018~4~6~0~JPY~-151067231.000~48767~~48767~A~RP0001887~0~1~2018~1~2018~2018~4~6~~JPY~-151067231.000~~~~~ ~0.000~5014~16113~~45211000~16350500~2018~10~~~31~F11~~YC~181105OT220131N05193~~CURGTA~~~~~~~~~~~~~~

##################################################################
####  ATTENTION
site=ubeu
##################################################################

if [ "${HOSTNAME}" = "dcvdevobbatch" ]
then
	DFILP2=$dprddat/${site}/perm
	cp $DFILP2/P_ESIX7000_CURGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
	cp $DFILP2/P_ESIX7000_GTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	ls -lrtFA ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGT*.dat
fi

echo "---> Extraction du mouvement a annuler dans GTA"
grep RP0001887 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat | grep 4~20~2018~10~15~21120000 | grep 151067231 > ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_L.dat

echo "---> Liste des mouvements modele"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_L.dat

echo "---> Annulation du mouvement GTA Life : awk"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
	if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
	if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
	$4 = 12
	$5 = 2  #Dimanche pour trace
	for (i=42; i<57; i++) $i = "";  # rab champs OneGL SAP
	$57 = "GTAR"
	print $0
}' \
 ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_L.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_L_new.dat

echo "---> Mouvement GTA genere"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_L_new.dat

###################################################################
echo "--> ****  maj GTA ${site} ********************************"

echo "---> Sauvegarde ancien GTA"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat > ${DSAV}/${ENV_PREFIX}_ESIX7000_GTA_${datej}.dat.gz

echo "---> Archivage corrections"
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_L_new.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_L_new_${datej}.dat.gz

echo "---> Comptage avant"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_L_new.dat

#############################################################################################
#############################################################################################
#  Tester sans mettre à jour, 
#  Si tout ok, retirer le JOBEND pour faire les mises à jour
#JOBEND
#############################################################################################
#############################################################################################

echo "---> Ajoute corrections au GTA"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_L_new.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

echo "---> Comptage apres"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

echo "---> liste des mouvements ajoutés dans ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat"
tail -1 ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

#if [ "${HOSTNAME}" = "dcvdevobbatch" ]
#then
#	# ménage sur Dev
#	rm ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
#fi

echo "--> ****  Fin maj GTA ${site} ****************************"


JOBEND