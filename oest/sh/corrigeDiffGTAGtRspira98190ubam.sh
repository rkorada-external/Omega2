#
######################################################################################
# Spira 98190 correction du GTA en générant le mouvement manquant a partir du CURGTR
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
#gunzip -c $DSAVE/T_ESIX7000_GTA_avantspira_98190_20210824102917.dat.gz > ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
##############################

#######################################################################################
spira=98190
#######################################################################################

##
########################################################################################
###Sur Amerique -- debut
########################################################################################
##
#
#Tout ajouter sur AR AM sans Retro Interne :
#grep RP0001844~0~1~2018 P_ESIX7000_CURGTR.dat | grep 2021~4~1~21120300 | grep -v 82834
#10~15~2021~4~1~21120300~22804000~~~~~~~~~~~~~~~~~RP0001844~0~1~2018~1~0~2020~1~3~0~BRL~191261.870~7~16472~~16472~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#10~15~2021~4~1~21120300~22804000~~~~~~~~~~~~~~~~~RP0001844~0~1~2018~1~0~2020~1~3~0~BRL~245908.120~8~82226~~82226~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#10~15~2021~4~1~21120300~22804000~~~~~~~~~~~~~~~~~RP0001844~0~1~2018~1~0~2020~1~3~0~BRL~491816.250~3~69273~~69273~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#10~15~2021~4~1~21120300~22804000~~~~~~~~~~~~~~~~~RP0001844~0~1~2018~1~0~2020~1~3~0~BRL~819693.740~2~69546~~69546~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#grep RP0001844~0~2~2018 P_ESIX7000_CURGTR.dat | grep 2021~4~1~21120300 | grep -v 82834
#10~15~2021~4~1~21120300~22804000~~~~~~~~~~~~~~~~~RP0001844~0~2~2018~1~0~2020~1~3~0~BRL~12428.890~3~69273~~69273~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#10~15~2021~4~1~21120300~22804000~~~~~~~~~~~~~~~~~RP0001844~0~2~2018~1~0~2020~1~3~0~BRL~20714.810~2~69546~~69546~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#10~15~2021~4~1~21120300~22804000~~~~~~~~~~~~~~~~~RP0001844~0~2~2018~1~0~2020~1~3~0~BRL~4833.460~7~16472~~16472~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#10~15~2021~4~1~21120300~22804000~~~~~~~~~~~~~~~~~RP0001844~0~2~2018~1~0~2020~1~3~0~BRL~6214.440~8~82226~~82226~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#grep RP0001844~0~1~2018 P_ESIX7000_CURGTA.dat | grep 2021~4~1~21120300 | grep -v 82834
#
#grep RP0001844~0~2~2018 P_ESIX7000_CURGTA.dat | grep 2021~4~1~21120300 | grep -v 82834
#
##
##Tout ajouter sur AR AM avec Retro Interne :
#grep RP0001844~0~1~2018 P_ESIX7000_CURGTR.dat | grep 2021~4~1~21120300 | grep 82834
#10~15~2021~4~1~21120300~22804000~~~~~~~~~~~~~~~~~RP0001844~0~1~2018~1~2020~2020~1~3~0~BRL~3715944.980~5~82834~~82834~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#grep RP0001844~0~2~2018 P_ESIX7000_CURGTR.dat | grep 2021~4~1~21120300 | grep 82834
#10~15~2021~4~1~21120300~22804000~~~~~~~~~~~~~~~~~RP0001844~0~2~2018~1~2020~2020~1~3~0~BRL~93907.160~5~82834~~82834~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#grep RP0001844~0~1~2018 P_ESIX7000_CURGTA.dat | grep 2021~4~1~21120300 | grep 82834
#
#grep RP0001844~0~2~2018 P_ESIX7000_CURGTA.dat | grep 2021~4~1~21120300 | grep 82834
#
##
###Sur Amerique -- fin
########################################################################################

##################################################################
site=ubam
###################################################################

if [ "${HOSTNAME}" = "dcvdevobbatch" -o "${HOSTNAME}" = "AEnDevO2Batch" ]
then
	DFILP2=/scordata_aenprdo2batch/${site}/perm
	cp $DFILP2/P_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
	cp $DFILP2/P_ESIX7000_CURGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
	cp $DFILP2/P_ESIX7000_GTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	#cp $DFILP2/P_ESIX7000_GTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_GTR.dat
	ls -lrtFA ${DFILP}/${ENV_PREFIX}_ESIX7000_*GT*.dat
fi

# Extraction des mouvements concernes

echo "---> Extraction sur AM des mouvements RR sans Retro Interne"
grep RP0001844~0~1~2018 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat | grep 2021~4~1~21120300 | grep -v 82834  > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_spira_${spira}sri_${site}.dat
grep RP0001844~0~2~2018 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat | grep 2021~4~1~21120300 | grep -v 82834 >> ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_spira_${spira}sri_${site}.dat

echo "---> Extraction sur AM des mouvements RR avec Retro Interne"
grep RP0001844~0~1~2018 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat | grep 2021~4~1~21120300 | grep 82834     > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_spira_${spira}ari_${site}.dat
grep RP0001844~0~2~2018 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat | grep 2021~4~1~21120300 | grep 82834    >> ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_spira_${spira}ari_${site}.dat

# Rien a annuler car rien sur mois 4
#echo "---> Extraction sur AM des mouvements GTA a annuler"
#grep RP0001844 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat | grep 21120300                 > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA_spira_${spira}annul_${site}.dat

echo "---> generation des mouvements GTA sans retro interne : awk"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	 $8 = "TR0030970"
   $9 = $25
  $10 = $26
  $11 = $27
  $12 = $28
  $13 = $11
  $14 = $30
  $15 = $31
  $16 = $32
  $17 = $33
  $18 = $34
  $19 = $35
  $41 = 0
  $4 = 10   #mois bilan 10 en cours GTA
  $5 = 3  #Dimanche pour trace
  for (i=36; i<41; i++) $i = "";  # rab champs infos retro interne
  for (i=42; i<57; i++) $i = "";  # rab champs OneGL SAP
  $57 = "GTAR"
  print $0
}' \
 ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_spira_${spira}sri_${site}.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}sri_${site}.dat

echo "---> generation des mouvements GTA avec retro interne : awk"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	 $8 = "TR0030970"
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
	$20 = "16420"
	$22 = "16420"
	$23 = "C"
	$41 = $35
  $4 = 10   #mois bilan 10 en cours GTA
  $5 = 3  #Dimanche pour trace
	for (i=42; i<57; i++) $i = "";  # rab champs OneGL SAP
	$57 = "GTAR"
	print $0
}' \
 ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_spira_${spira}ari_${site}.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}ari_${site}.dat

#echo "---> generation des mouvements GTA a annuler : awk"
#awk 'BEGIN { FS="~"; OFS="~"; s="" } \
#{
#  $4 = 10   #mois bilan 10 en cours GTA
#  $5 = 3  #Dimanche pour trace
#	if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
#  if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
#  if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
#  for (i=42; i<57; i++) $i = "";  # rab champs OneGL SAP
#	$57 = "GTAR"
#	print $0
#}' \
# ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTA_spira_${spira}annul_${site}.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}annul_${site}.dat

###################################################################
echo "---> Liste des mouvements modele a generer sans retro interne"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_spira_${spira}sri_${site}.dat

echo "---> Liste des mouvements modele a generer avec retro interne"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_spira_${spira}ari_${site}.dat

#echo "---> Liste des mouvements modele a annuler"
#cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}annul_${site}.dat
###################################################################
echo "---> Cumul dans un seul fichier GTA"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}sri_${site}.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}ari_${site}.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat

echo "---> liste tout ce qui sera ajouté"
wc -l ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat
###################################################################

###################################################################

echo "---> Sauvegarde ancien GTA"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat > ${DSAV}/${ENV_PREFIX}_ESIX7000_GTA_avantspira_${spira}_${datej}.dat.gz

echo "---> Archivage corrections"
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat.gz

#############################################################################################
#############################################################################################
#  Tester sans mettre à jour, 
#  Si tout ok, retirer le JOBEND pour faire les mises à jour
#JOBEND
#############################################################################################
#############################################################################################
echo "--> ****  maj GTA ${site} ********************************"

echo "---> Comptage avant"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat

echo "---> Ajoute corrections au GTA"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_GTA_final_spira_${spira}_${site}.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

echo "---> Comptage apres"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

echo "---> liste des mouvements ajoutés dans ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat"
tail -10 ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat

#if [ "${HOSTNAME}" = "dcvdevobbatch" ]
#then
#	# ménage sur Dev
#	rm ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
#	rm ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
#fi

echo "--> ****  Fin maj GTA ${site} ****************************"


JOBEND