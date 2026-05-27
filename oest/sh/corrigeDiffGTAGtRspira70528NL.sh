#
######################################################################################
# Spira 70528 correction du GTA en générant le mouvement manquant a partir du CURGTR
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
#Sur Asie
######################################################################################

#grep 22N000009 P_ESIX7000_CURGTR.dat | grep 22~2~2018~10~2~22807000
#22~2~2018~10~2~22807000~22804000~~~~~~~~~~~~~~~~~22N000009~0~1~2018~1~2018~2018~10~10~0~AUD~192750.000~1~21115~~21115~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##################################################################
####  ATTENTION
site=ubas
##################################################################

if [ "${HOSTNAME}" = "dcvdevobbatch" ]
then
	DFILP2=$dprddat/${site}/perm
	cp $DFILP2/P_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
	cp $DFILP2/P_ESIX7000_GTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	ls -lrtFA ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGT*.dat
fi

echo "---> Extraction du mouvement modele pour generation du mouvement a ajouter"
grep 22N000009 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat | grep 22~2~2018~10~2~22807000 > ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_NL.dat

echo "---> Liste des mouvements modele"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_NL.dat

echo "---> generation du mouvement GTA NonLife : awk"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	 $9 = $25
	$10 = $26
	$11 = $27
	$12 = $28
	$13 = $29
	$14 = $30
	$15 = $31
	$16 = $32
	$17 = $33
	$18 = $34
	$19 = $35
	$41 = $35
	$4 = 12
	$5 = 2  #Dimanche pour trace
	for (i=42; i<57; i++) $i = "";  # rab champs OneGL SAP
	$57 = "GTAR"
	print $0
}' \
 ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_NL.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_NL_new.dat

echo "---> Mouvement GTA genere"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_NL_new.dat

###################################################################
echo "--> ****  maj GTA ${site} ********************************"

echo "---> Sauvegarde ancien GTA"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat > ${DSAV}/${ENV_PREFIX}_ESIX7000_GTA_${datej}.dat.gz

echo "---> Archivage corrections"
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_NL_new.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_NL_new_${datej}.dat.gz

echo "---> Comptage avant"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_NL_new.dat

#############################################################################################
#############################################################################################
#  Tester sans mettre à jour, 
#  Si tout ok, retirer le JOBEND pour faire les mises à jour
#JOBEND
#############################################################################################
#############################################################################################

echo "---> Ajoute corrections au GTA"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_spira70528_NL_new.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

echo "---> Comptage apres"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

echo "---> liste des mouvements ajoutés dans ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat"
tail -1 ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

#if [ "${HOSTNAME}" = "dcvdevobbatch" ]
#then
#	# ménage sur Dev
#	rm ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
#fi

echo "--> ****  Fin maj GTA ${site} ****************************"


JOBEND