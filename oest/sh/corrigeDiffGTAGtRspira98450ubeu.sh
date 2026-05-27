#
######################################################################################
# Spira 98450 correction du GTA en générant le mouvement manquant a partir du GTR ou du CURGTR
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


##############################
#  ATTENTION  !!!!!!!
#gunzip -c $DSAVE/T_ESIX7000_GTA_avantspira_${spira}_20190306141104.dat.gz > ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
##############################

#######################################################################################
spira=98450
#######################################################################################


##
########################################################################################
###Sur Europe -- debut
########################################################################################
##
###   Avec retro interne
#grep 02N000645 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat | grep 22807000 | 2021~7~1~
#2~7~2021~7~1~22807000~22804000~~~~~~~~~~~~~~~~~02N000645~0~1~2021~1~2021~2021~4~4~0~USD~18000.000~3~52001~~52001~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Rien dans CURGTA
#grep 02N000645 P_ESIX7000_CURGTA.dat | grep 22807000 | 2021~7~1~
##
#grep 02N000646 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat | grep 22807000 | 2021~7~1~
#2~7~2021~7~1~22807000~22804000~~~~~~~~~~~~~~~~~02N000646~0~1~2021~1~2021~2021~6~6~0~USD~11000.000~3~52001~~52001~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Rien dans CURGTA
#grep 02N000646 P_ESIX7000_CURGTA.dat | grep 22807000 | 2021~7~1~
##
###Sur Europe -- fin
########################################################################################

##################################################################
site=ubeu
###################################################################

if [ "${HOSTNAME}" = "dcvdevobbatch" -o "${HOSTNAME}" = "AEnDevO2Batch" ]
then
	DFILP2=/scordata_aenprdo2batch/${site}/perm
	cp $DFILP2/P_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
	#cp $DFILP2/P_ESIX7000_CURGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
	cp $DFILP2/P_ESIX7000_GTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	#cp $DFILP2/P_ESIX7000_GTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat
	ls -lrtFA ${DFILP}/${ENV_PREFIX}_ESIX7000_*GT*.dat
fi

# Generation mouvements avec retro interne

echo "---> Extraction du mouvement modele pour generation des mouvements a ajouter"
grep 02N000645 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat | grep 22807000 | grep 2021~7~1~ >  ${DFILT}/${ENV_PREFIX}_ESIX7000_GTR_spira_${spira}ari_${site}.dat
grep 02N000646 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat | grep 22807000 | grep 2021~7~1~ >> ${DFILT}/${ENV_PREFIX}_ESIX7000_GTR_spira_${spira}ari_${site}.dat

# Annulation des mouvements GTA -> NON pas d'annulations

echo "---> Liste des mouvements modele a generer avec retro interne"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTR_spira_${spira}ari_${site}.dat

echo "---> generation des mouvements GTA avec retro interne : awk"
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
	$4 = 9   #mois bilan 9 en cours GTA
	$5 = 22  #dimanche pour trace
	for (i=42; i<57; i++) $i = "";  # rab champs OneGL SAP
	$57 = "GTAR"
	print $0
}' \
 ${DFILT}/${ENV_PREFIX}_ESIX7000_GTR_spira_${spira}ari_${site}.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat
 
echo "---> liste Mouvement GTA generes"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat

###################################################################
#echo "---> liste Mouvement GTA annules"
#cat $DFILT/${ENV_PREFIX}_ESIX7000_GTA_annulLast_spira_${spira}_${site}.dat
#
#echo "---> ajoute GTA annules"
#cat $DFILT/${ENV_PREFIX}_ESIX7000_GTA_annulLast_spira_${spira}_${site}.dat >> ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat

echo "---> liste tout"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat
###################################################################

###################################################################
echo "--> ****  maj GTA ${site} ********************************"

echo "---> Sauvegarde ancien GTA"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat > ${DSAV}/${ENV_PREFIX}_ESIX7000_GTA_avantspira_${spira}_${datej}.dat.gz

echo "---> Comptage avant"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat

#############################################################################################
#############################################################################################
#  Tester sans mettre à jour, 
#  Si tout ok, retirer le JOBEND pour faire les mises à jour
#JOBEND
#############################################################################################
#############################################################################################

echo "---> Archivage corrections"
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_GTA_final2_spira_${spira}_${site}.dat.gz

echo "---> Ajoute corrections au GTA"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

echo "---> Comptage apres"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

echo "---> liste des mouvements ajoutés dans ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat"
tail -2 ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

#if [ "${HOSTNAME}" = "dcvdevobbatch" ]
#then
#	# ménage sur Dev
#	rm ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
#	rm ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
#fi

echo "--> ****  Fin maj GTA ${site} ****************************"


JOBEND