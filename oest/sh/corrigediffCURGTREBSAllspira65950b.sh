#
# Correction pour CURGTR spira 65950.
# 1.Extraction FTECLEDRSIISO du 3T et la maintenance faite sur RA
# 2.Transformation au format CURGTR
# 3.Annulation des ecritures CURGTR 1T a 3T sauf ouv/clo
# 4.Ajout au CURGTR
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

ENV_PREFIX2=${ENV_PREFIX}
DFILP2=$DFILP
DARCH2=$DARCH

#################################################################
site=${DEFAULT_SQL_LOGIN}
prdsite=$HOST_PRDSIT
prdsite=SGP1
site=ubas
DFILPP=/scor/scordata/ubeu/perm
#################################################################

#################################################################

##################################################################
##################################################################
echo "--->>>  1. travail sur l'extraction RA pour site ${site}"
##################################################################
##################################################################

if [ "${HOSTNAME}" = "dcvdevobbatch" ]
then
	DFILPP=/scor/scoromega/dtra_dev
fi

#for (i=1; i<41; i++) { if ($i == "null") $i = ""; }
if [ "${ENV_PREFIX}" != "P" -a "${ENV_PREFIX}" != "T" ]
then
	DFILP2=/scordata_dcvprdobbatch/${site}/perm
	ENV_PREFIX2=P
	cp ${DFILP2}/P_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
fi

echo "---> Selelectionne les filiales du site et correction des champs pour ${site}"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if ($1 == 20 || $1 == 22 || $1 == 24)
	{
		if (substr($8,1,1) == " ") $8 = "";
		if (substr($18,1,1) == " ") $18 = "";
		if (substr($23,1,1) == " ") $23 = "";
		if (substr($40,1,1) == " ") $40 = "";
		$41 = "0.000"
		$57 = "EBSGTA"
		#$59 = "5"
		$71 = ""
		print $0;
	}
}' \
 ${DFILPP}/EBS_PROD_EXTRACT.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd1_${site}.dat

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
# GTR files merge
#-----------------------------------------------------------------------------
#[010] Reformat
LIBEL="Merge and sort of dGTR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd1_${site}.dat 500 1"
SORT_O="${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat 500 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
  SSD_CF     1:1 -  1:EN,
  ESB_CF     2:1 -  2:EN,
  RETCTR_NF 24:1 - 24:,
  RETEND_NT 25:1 - 25:,
  RETSEC_NF 26:1 - 26:,
  RTY_NF    27:1 - 27:,
  RETUW_NT  28:1 - 28:
/KEYS
  SSD_CF,
  ESB_CF,
  RETCTR_NF,
  RETEND_NT,
  RETSEC_NF,
  RTY_NF,
  RETUW_NT
exit
EOF
SORT

#################################################################

echo "---> Genere ecritures EBS CURGTR a supprimer 1T a 3T pour controle"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if ((substr($6,2,1) == "A" && substr($6,8,1) == "2") || (substr($6,2,1) == "E"))
		print $0;
}' \
 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_${site}.dat

echo "---> Genere CURGTR sans ecritures EBS 1T a 3T"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if ( ! ((substr($6,2,1) == "A" && substr($6,8,1) == "2") || (substr($6,2,1) == "E")) )
		print $0;
}' \
 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat

##################################################################
##################################################################
echo "--->>>  2. Sauvegardes et Mise a jour CURGTR"
##################################################################
##################################################################

##################################################################

echo "---> Comptage modifs"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
wc -l ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_${site}.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat
wc -l ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat

echo "---> Archivage corrections et CURGTR"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat                     > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_AvantSpira65950_${site}.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_${site}.dat      > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_Spira65950_${site}.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat        > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_Spira65950_${site}.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat     > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_AnnulEtEBS3T_Spira65950_${site}.dat.gz

##################################################################

echo "---> Move fichier dans CURGTR"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat > ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat

echo "---> Comptage apres CURGTR nouveau"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
echo "---> Comptage apres CURGTR work"
wc -l ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat

cp ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR_${site}.dat

echo "--> ***********************************"
##################################################################
exit
#################################################################
site=${DEFAULT_SQL_LOGIN}
prdsite=$HOST_PRDSIT
prdsite=FRA1
site=ubeu
DFILPP=/scor/scordata/ubeu/perm
#################################################################

#################################################################

##################################################################
##################################################################
echo "--->>>  1. travail sur l'extraction RA pour site ${site}"
##################################################################
##################################################################

if [ "${HOSTNAME}" = "dcvdevobbatch" ]
then
	DFILPP=/scor/scoromega/dtra_dev
fi

if [ "${ENV_PREFIX}" != "P" -a "${ENV_PREFIX}" != "T" ]
then
	DFILP2=/scordata_dcvprdobbatch/${site}/perm
	ENV_PREFIX2=P
	cp ${DFILP2}/P_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
fi

echo "---> Selelectionne les filiales du site et correction des champs pour ${site}"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if ($1 == 1  || $1 == 2  || $1 == 3  || $1 == 4  || $1 == 5  || $1 == 6  || $1 == 7 ||
		 $1 == 12 || $1 == 15 || $1 == 16 || $1 == 17 || $1 == 18 || $1 == 19 || $1 == 23)
	{
		if (substr($8,1,1) == " ") $8 = "";
		if (substr($18,1,1) == " ") $18 = "";
		if (substr($23,1,1) == " ") $23 = "";
		if (substr($40,1,1) == " ") $40 = "";
		$41 = "0.000"
		$57 = "EBSGTA"
		#$59 = "5"
		$71 = ""
		print $0;
	}
}' \
 ${DFILPP}/EBS_PROD_EXTRACT.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd1_${site}.dat

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
# GTR files merge
#-----------------------------------------------------------------------------
#[010] Reformat
LIBEL="Merge and sort of dGTR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd1_${site}.dat 500 1"
SORT_O="${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat 500 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
  SSD_CF     1:1 -  1:EN,
  ESB_CF     2:1 -  2:EN,
  RETCTR_NF 24:1 - 24:,
  RETEND_NT 25:1 - 25:,
  RETSEC_NF 26:1 - 26:,
  RTY_NF    27:1 - 27:,
  RETUW_NT  28:1 - 28:
/KEYS
  SSD_CF,
  ESB_CF,
  RETCTR_NF,
  RETEND_NT,
  RETSEC_NF,
  RTY_NF,
  RETUW_NT
exit
EOF
SORT

#################################################################

echo "---> Genere ecritures EBS CURGTR a supprimer 1T a 3T pour controle"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if ((substr($6,2,1) == "A" && substr($6,8,1) == "2") || (substr($6,2,1) == "E"))
		print $0;
}' \
 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_${site}.dat

echo "---> Genere CURGTR sans ecritures EBS 1T a 3T"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if ( ! ((substr($6,2,1) == "A" && substr($6,8,1) == "2") || (substr($6,2,1) == "E")) )
		print $0;
}' \
 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat

##################################################################
##################################################################
echo "--->>>  2. Sauvegardes et Mise a jour CURGTR"
##################################################################
##################################################################

##################################################################

echo "---> Comptage modifs"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
wc -l ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_${site}.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat
wc -l ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat

echo "---> Archivage corrections et CURGTR"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat                     > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_AvantSpira65950_${site}.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_${site}.dat      > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_Spira65950_${site}.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat        > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_Spira65950_${site}.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat     > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_AnnulEtEBS3T_Spira65950_${site}.dat.gz

##################################################################

echo "---> Move fichier dans CURGTR"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat > ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat

echo "---> Comptage apres CURGTR nouveau"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
echo "---> Comptage apres CURGTR work"
wc -l ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat

cp ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR_${site}.dat

echo "--> ***********************************"
##################################################################

#################################################################
site=${DEFAULT_SQL_LOGIN}
prdsite=$HOST_PRDSIT
prdsite=USA1
site=ubam
DFILPP=/scor/scordata/ubeu/perm
#################################################################

#################################################################

##################################################################
##################################################################
echo "--->>>  1. travail sur l'extraction RA pour site ${site}"
##################################################################
##################################################################

if [ "${HOSTNAME}" = "dcvdevobbatch" ]
then
	DFILPP=/scor/scoromega/dtra_dev
fi

if [ "${ENV_PREFIX}" != "P" -a "${ENV_PREFIX}" != "T" ]
then
	DFILP2=/scordata_dcvprdobbatch/${site}/perm
	ENV_PREFIX2=P
	cp ${DFILP2}/P_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
fi

echo "---> Selelectionne les filiales du site et correction des champs pour ${site}"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if ($1 == 10 || $1 == 11 || $1 == 13 || $1 == 14 || $1 == 25 || $1 == 26 || $1 == 27)
	{
		if (substr($8,1,1) == " ") $8 = "";
		if (substr($18,1,1) == " ") $18 = "";
		if (substr($23,1,1) == " ") $23 = "";
		if (substr($40,1,1) == " ") $40 = "";
		$41 = "0.000"
		$57 = "EBSGTA"
		#$59 = "5"
		$71 = ""
		print $0;
	}
}' \
 ${DFILPP}/EBS_PROD_EXTRACT.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd1_${site}.dat

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
# GTR files merge
#-----------------------------------------------------------------------------
#[010] Reformat
LIBEL="Merge and sort of dGTR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd1_${site}.dat 500 1"
SORT_O="${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat 500 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
  SSD_CF     1:1 -  1:EN,
  ESB_CF     2:1 -  2:EN,
  RETCTR_NF 24:1 - 24:,
  RETEND_NT 25:1 - 25:,
  RETSEC_NF 26:1 - 26:,
  RTY_NF    27:1 - 27:,
  RETUW_NT  28:1 - 28:
/KEYS
  SSD_CF,
  ESB_CF,
  RETCTR_NF,
  RETEND_NT,
  RETSEC_NF,
  RTY_NF,
  RETUW_NT
exit
EOF
SORT

#################################################################

echo "---> Genere ecritures EBS CURGTR a supprimer 1T a 3T pour controle"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if ((substr($6,2,1) == "A" && substr($6,8,1) == "2") || (substr($6,2,1) == "E"))
		print $0;
}' \
 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_${site}.dat

echo "---> Genere CURGTR sans ecritures EBS 1T a 3T"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if ( ! ((substr($6,2,1) == "A" && substr($6,8,1) == "2") || (substr($6,2,1) == "E")) )
		print $0;
}' \
 ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat

##################################################################
##################################################################
echo "--->>>  2. Sauvegardes et Mise a jour CURGTR"
##################################################################
##################################################################

##################################################################

echo "---> Comptage modifs"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
wc -l ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_${site}.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat
wc -l ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat

echo "---> Archivage corrections et CURGTR"
gzip -c ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat                     > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_AvantSpira65950_${site}.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_${site}.dat      > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_DELEBS_Spira65950_${site}.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat        > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_Spira65950_${site}.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat     > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_AnnulEtEBS3T_Spira65950_${site}.dat.gz

##################################################################

echo "---> Move fichier dans CURGTR"
cat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat > ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat

echo "---> Comptage apres CURGTR nouveau"
wc -l ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat
echo "---> Comptage apres CURGTR work"
wc -l ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_selssd2_${site}.dat ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_KEEP_${site}.dat

cp ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR.dat ${DFILP}/${ENV_PREFIX}_ESIX7000_CURGTR_${site}.dat

echo "--> ***********************************"
##################################################################

JOBEND