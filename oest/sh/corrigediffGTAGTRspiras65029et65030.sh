# Spira 64275
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

#################################################################
###  ATTENTION
site=ubas
#################################################################

#grep 21122000 P_ESIX7000_CURGTR.dat | grep ~0~1~2017 | egrep '(22N000012|22N000009)' | grep 2017~10~3~ 
#22~2~2017~10~3~21122000~22804000~~~~~~~~~~~~~~~~~22N000009~0~1~2017~1~2017~2017~10~10~0~AUD~213750.000~1~21115~~21115~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#22~2~2017~10~3~21122000~22804000~~~~~~~~~~~~~~~~~22N000012~0~1~2017~1~2017~2017~10~10~0~AUD~22500.000~1~21115~~21115~A~0.000~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#if [ "${DEFAULT_SQL_LOGIN}" = "ubas" ]
if [ "${site}" = "ubas" ]
then
	if [ "${BATCH_SRV_HOSTNAME}" = "dcvdevobbatch" ]
	then
		echo "---> cree environnement Dev"
		DFILP2=/scordata_dcvprdobbatch/${site}/perm
		ENV_PREFIX2=P
		cp ${DFILP2}/${ENV_PREFIX2}_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
		cp ${DFILP2}/${ENV_PREFIX2}_ESIX7000_GTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	else
		DFILP=/scor/scordata/${site}/perm
		DFILI=/scor/scordata/${site}/interm
		DFILT=/scor/scordata/${site}/temporaire
		DSAV=/scor/scordata/${site}/save
		DARCH=/scor/scordata/${site}/arch
	fi
	
	grep 21122000 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat | grep ~0~1~2017 | egrep '(22N000012|22N000009)' | grep 2017~10~3~ > ${DFILT}/${ENV_PREFIX}_ESIX7000_repr22N00000922N000012GTA.dat
	echo "---> 22N000009 - 22N000012 - generation ligne GTAR a partir de ligne GTR"
	awk 'BEGIN { FS="~"; OFS="~"; s="" } \
	{
		$9 = 0
		$10 = 0
		$11 = $25
		$12 = $26
		$13 = $27
		$14 = $30
		$15 = $31
		$16 = $32
		$17 = $33
		$18 = $34
		$19 = $35
		$39 = ""
		$40 = ""
		$41 = $35
		$4 = 12
		$5 = 10
		for (i=42; i<57; i++) $i = "";  # rab champs OneGL SAP
		$57 = "GTAR"
		print $0
	}' \
	 ${DFILT}/${ENV_PREFIX}_ESIX7000_repr22N00000922N000012GTA.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat
	echo "";echo "---> In"
	cat ${DFILT}/${ENV_PREFIX}_ESIX7000_repr22N00000922N000012GTA.dat
	echo "---> out"
	cat ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat
	
	###################################################################
	echo "--> ****  maj GTA  ********************************"
	
	echo "---> Sauvegarde ancien GTA"
	gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat > ${DSAV}/${ENV_PREFIX}_ESIX7000_GTA_${datej}.dat.gz
	
	echo "---> Archivage corrections"
	gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_new1_${site}_${datej}.dat.gz
	
	echo "---> Comptage avant"
	wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat

	echo "---> Ajoute corrections au GTA"
	cat ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	
	echo "---> Comptage apres"
	wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	
	echo "--> ****  Fin maj GTA  ****************************"
fi

datej=`date '+%Y%m%d%H%M%S'`

#################################################################
###  ATTENTION
site=ubeu
#################################################################

#if [ "${DEFAULT_SQL_LOGIN}" = "ubeu" ]
if [ "${site}" = "ubeu" ]
then
	if [ "${BATCH_SRV_HOSTNAME}" = "dcvdevobbatch" ]
	then
		echo "---> cree environnement Dev"
		DFILP2=/scordata_dcvprdobbatch/${site}/perm
		ENV_PREFIX2=P
		cp ${DFILP2}/${ENV_PREFIX2}_ESIX7000_CURGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
		cp ${DFILP2}/${ENV_PREFIX2}_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
		cp ${DFILP2}/${ENV_PREFIX2}_ESIX7000_GTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	else
		DFILP=/scor/scordata/${site}/perm
		DFILI=/scor/scordata/${site}/interm
		DFILT=/scor/scordata/${site}/temporaire
		DSAV=/scor/scordata/${site}/save
		DARCH=/scor/scordata/${site}/arch
	fi
	
	echo "---> sur x contrats - annulation ligne GTA"
	awk 'BEGIN { FS="~"; OFS="~"; s="" } \
	{
		if ( ($24 == "02P000112" || $24 == "02P000116" || $24 == "02P000120" || $24 == "02Z052523" ||
			   $24 == "RP0001054" || $24 == "04P000038" || $24 == "04P000039" || $24 == "04P000043") &&
			   $33 == "" && $4 == 10 && $6 == "21122000" && $5 != 2)
		{
			if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
			if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
			if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
			$4 = 12
			$5 = 3  #Dimanche pour trace
			for (i=42; i<57; i++) $i = "";  # rab champs OneGL SAP
			$57 = "GTAR"
			print $0
		}
	}' \
	 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat
	
	echo "---> sur x contrats - annulation ligne GTA - Controle"
	awk 'BEGIN { FS="~"; OFS="~"; s="" } \
	{
		if ( ($24 == "02P000112" || $24 == "02P000116" || $24 == "02P000120" || $24 == "02Z052523" ||
			   $24 == "RP0001054" || $24 == "04P000038" || $24 == "04P000039" || $24 == "04P000043") &&
			   $33 == "0" && $4 == 10 && $6 == "21122000" && $5 != 2)
		{
			if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
			if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
			if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
			print $0
		}
	}' \
	 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_good1.dat
	
	echo "---> sur x contrats - annulation ligne GTA - Controle GTR"
	awk 'BEGIN { FS="~"; OFS="~"; s="" } \
	{
		if ( ($24 == "02P000112" || $24 == "02P000116" || $24 == "02P000120" || $24 == "02Z052523" ||
			   $24 == "RP0001054" || $24 == "04P000038" || $24 == "04P000039" || $24 == "04P000043") &&
			   $4 == 10 && $6 == "21122000" && $5 != 2)
		{
			if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
			if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
			if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
			print $0
		}
	}' \
	 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_curgtr1.dat
	
	###################################################################
	echo "--> ****  maj GTA  ********************************"
	
	echo "---> Sauvegarde ancien GTA"
	gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat > ${DSAV}/${ENV_PREFIX}_ESIX7000_GTA_${datej}.dat.gz
	
	echo "---> Archivage corrections"
	gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_new1_${site}_${datej}.dat.gz
	
	echo "---> Comptage avant"
	wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat

	echo "---> Ajoute corrections au GTA"
	cat ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	
	echo "---> Comptage apres"
	wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	
	echo "--> ****  Fin maj GTA  ****************************"
fi

datej=`date '+%Y%m%d%H%M%S'`

#################################################################
###  ATTENTION
site=ubam
#################################################################

#if [ "${DEFAULT_SQL_LOGIN}" = "ubam" ]
if [ "${site}" = "ubam" ]
then
	if [ "${BATCH_SRV_HOSTNAME}" = "dcvdevobbatch" ]
	then
		echo "---> cree environnement Dev"
		DFILP2=/scordata_dcvprdobbatch/${site}/perm
		ENV_PREFIX2=P
		cp ${DFILP2}/${ENV_PREFIX2}_ESIX7000_CURGTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat
		cp ${DFILP2}/${ENV_PREFIX2}_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
		cp ${DFILP2}/${ENV_PREFIX2}_ESIX7000_GTA.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	else
		DFILP=/scor/scordata/${site}/perm
		DFILI=/scor/scordata/${site}/interm
		DFILT=/scor/scordata/${site}/temporaire
		DSAV=/scor/scordata/${site}/save
		DARCH=/scor/scordata/${site}/arch
	fi
	
	echo "---> sur x contrats mois 10 - annulation ligne GTA"
	awk 'BEGIN { FS="~"; OFS="~"; s="" } \
	{
		if ( ($24 == "14ZR20635" || $24 == "14ZR20791" || $24 == "RPA021735" || $24 == "RPA021122" || $24 == "RPA022919" || $24 == "RPA023137" ||
		      $24 == "14ZR13358" || $24 == "RP0001450" || $24 == "RPA121646" || $24 == "RPA021467" || $24 == "RPA021520" || $24 == "RPA040214" ||
		      $24 == "RPA122877" || $24 == "RPA120097" || $24 == "RPA221646") &&
			   $33 == "" && $4 == 10 && $6 == "41122000")
		{
			if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
			if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
			if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
			$4 = 12
			$5 = 3  #Dimanche pour trace
			for (i=42; i<57; i++) $i = "";  # rab champs OneGL SAP
			$57 = "GTAR"
			print $0
		}
	}' \
	 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat
	
	echo "---> sur x contrats mois 10 - annulation ligne GTA - Controle"
	awk 'BEGIN { FS="~"; OFS="~"; s="" } \
	{
		if ( ($24 == "14ZR20635" || $24 == "14ZR20791" || $24 == "RPA021735" || $24 == "RPA021122" || $24 == "RPA022919" || $24 == "RPA023137" ||
		      $24 == "14ZR13358" || $24 == "RP0001450" || $24 == "RPA121646" || $24 == "RPA021467" || $24 == "RPA021520" || $24 == "RPA040214" ||
		      $24 == "RPA122877" || $24 == "RPA120097" || $24 == "RPA221646") &&
			   $33 == "0" && $4 == 10 && $6 == "41122000")
		{
			if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
			if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
			if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
			print $0
		}
	}' \
	 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_good1.dat
	
	echo "---> sur x contrats mois 10 - annulation ligne GTA - Controle GTR"
	awk 'BEGIN { FS="~"; OFS="~"; s="" } \
	{
		if ( ($24 == "14ZR20635" || $24 == "14ZR20791" || $24 == "RPA021735" || $24 == "RPA021122" || $24 == "RPA022919" || $24 == "RPA023137" ||
		      $24 == "14ZR13358" || $24 == "RP0001450" || $24 == "RPA121646" || $24 == "RPA021467" || $24 == "RPA021520" || $24 == "RPA040214" ||
		      $24 == "RPA122877" || $24 == "RPA120097" || $24 == "RPA221646") &&
			   $4 == 10 && $6 == "41122000")
		{
			if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
			if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
			if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
			print $0
		}
	}' \
	 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_curgtr1.dat
	
	echo "---> sur x contrats mois 11 - annulation ligne GTA"
	awk 'BEGIN { FS="~"; OFS="~"; s="" } \
	{
		if ( ($24 == "RPA021122" || $24 == "RPA023137" || $24 == "RPA020093" || $24 == "RPA021511" || $24 == "RPA021467" || $24 == "RPA122877" ||
			   $24 == "RPA120093") &&
			   $33 == "" && $4 == 11 && $6 == "41122000")
		{
			if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
			if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
			if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
			$4 = 12
			$5 = 10  #Dimanche pour trace
			for (i=42; i<57; i++) $i = "";  # rab champs OneGL SAP
			$57 = "GTAR"
			print $0
		}
	}' \
	 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul2.dat
	
	echo "---> sur x contrats mois 11 - annulation ligne GTA - Controle"
	awk 'BEGIN { FS="~"; OFS="~"; s="" } \
	{
		if ( ($24 == "RPA021122" || $24 == "RPA023137" || $24 == "RPA020093" || $24 == "RPA021511" || $24 == "RPA021467" || $24 == "RPA122877" ||
			   $24 == "RPA120093") &&
			   $33 == "0" && $4 == 11 && $6 == "41122000")
		{
			if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
			if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
			if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
			print $0
		}
	}' \
	 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTA.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_good2.dat
	
	echo "---> sur x contrats mois 11 - annulation ligne GTA - Controle GTR"
	awk 'BEGIN { FS="~"; OFS="~"; s="" } \
	{
		if ( ($24 == "RPA021122" || $24 == "RPA023137" || $24 == "RPA020093" || $24 == "RPA021511" || $24 == "RPA021467" || $24 == "RPA122877" ||
			   $24 == "RPA120093") &&
			   $4 == 11 && $6 == "41122000")
		{
			if ($19 != 0) $19 = sprintf("%-.3lf",-$19)
			if ($35 != 0) $35 = sprintf("%-.3lf",-$35)
			if ($41 != 0) $41 = sprintf("%-.3lf",-$41)
			print $0
		}
	}' \
	 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_curgtr2.dat

	###################################################################
	echo "--> ****  maj GTA  ********************************"
	
	echo "---> Sauvegarde ancien GTA"
	gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat > ${DSAV}/${ENV_PREFIX}_ESIX7000_GTA_${datej}.dat.gz
	
	echo "---> Archivage corrections"
	gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_new1_${site}_${datej}.dat.gz
	gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul2.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_new2_${site}_${datej}.dat.gz
	
	echo "---> Comptage avant"
	wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul2.dat
	#wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul2.dat

	echo "---> Ajoute corrections au GTA"
	cat ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul1.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul2.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	#cat ${DFILT}/${ENV_PREFIX}_ESIX7000_corrigeGTRSpira65029et65030_${site}_annul2.dat >> ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	
	echo "---> Comptage apres"
	wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_GTA.dat
	
	echo "--> ****  Fin maj GTA  ****************************"
fi

JOBEND