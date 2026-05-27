#
# Correction pour RA FTECLEDR spira 64660.
# 1.Annulation des ecritures envoyées à tort dans CURGTR
# 2.Gestion PNA/FAR
# 3.Ajout fichier de correction Rto
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
prdsite=FRA1
site=ubeu
#################################################################
date1=20170315
date2=20170615
if [ "${site}" = "ubeu" -o "${site}" = "ubas" ]
then
	date2=20170614
fi
#################################################################

##################################################################
##################################################################
echo "--->>>  1. Annulation ecritures injectées dans CURGTR a tort"
##################################################################
##################################################################

echo "---> Unzip DLREGTRSO"
if [ "${ENV_PREFIX}" != "P" -a "${ENV_PREFIX}" != "T" ]
then
	DARCH2=/scordata_dcvprdobbatch/${site}/arch
	DFILP2=/scordata_dcvprdobbatch/${site}/perm
	ENV_PREFIX2=P
	cp ${DARCH2}/P_ESPD2500_DLREGTRSO_20170331_${date1}.dat.gz ${DARCH}
	gunzip -c ${DARCH}/P_ESPD2500_DLREGTRSO_20170331_${date1}.dat.gz > ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_${site}.dat
	cp ${DARCH2}/P_ESPD2500_DLREGTRSO_20170630_${date2}.dat.gz ${DARCH}
	gunzip -c ${DARCH}/P_ESPD2500_DLREGTRSO_20170630_${date2}.dat.gz > ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_${site}.dat
fi
if [ "${ENV_PREFIX}" = "P" ]
then
	gunzip -c ${DARCH2}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_${date1}.dat.gz > ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_${site}.dat
	gunzip -c ${DARCH2}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_${date2}.dat.gz > ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_${site}.dat
fi
#################################################################

EPO_OIRDVPERICASE=${DFILP2}/P_ESPT0000_OIRDVPERICASE.dat
EPO_FCLIENT=${DFILP2}/P_ESPT0000_FCLIENT.dat
EPO_FDETTRS=${DFILP2}/P_ESPT0000_FDETTRS.dat

echo "---> Report ligne GTR 1T sur mois 2T"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if (substr($6,2,1) == "A" || substr($6,2,1) == "E" || substr($6,2,1) == "J")
	{
		$4 = 6;
		$5 = 30;
		print $0
	}
}' \
 ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_${site}.dat > ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_${site}_reportmois6.dat
 
echo "---> Report ligne GTR 2T sur mois 3T"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if (substr($6,2,1) == "A" || substr($6,2,1) == "E" || substr($6,2,1) == "J")
	{
		$4 = 9;
		$5 = 30;
		print $0
	}
}' \
 ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_${site}.dat > ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_${site}_reportmois9.dat

##################################################################
echo "--> ****  Mise au format FTECLEDR 1T sur 2T *******************************"

NSTEP=${NJOB}_80
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_${site}_reportmois6.dat 1000 1"
SORT_O="${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_${site}_reportmois6_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF    27:1 - 27:,
        RETUW_NT  28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT

touch ${DFILT}/${NJOB}_80_${IB}_SORT_FTECLEDAR_O.dat
NSTEP=${NJOB}_90
#Double entry transaction code addition in dDVGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_${site}_reportmois6_O.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_${site}_reportmois6_O2.dat
EXECPRG

NSTEP=${NJOB}_100
# File generation in TTECLEDR table format
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8802
export ${PRG}_I1=${EPO_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_80_${IB}_SORT_FTECLEDAR_O.dat
#export ${PRG}_I3=${DFILT}/${NJOB}_70_${IB}_ESTM7603_DLSGTR.dat
export ${PRG}_I3=${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_${site}_reportmois6_O2.dat
export ${PRG}_I4=${EPO_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_REJETE_O4.dat
EXECPRG

echo "---> Complete zones"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	$41 = "20170611";
	$42 = "CloP";
	$43 = "20170611";
	$44 = "CloP"
	$57 = "EBSGTA"
	$59 = "5"
	print $0
}' \
 ${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat > ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_reportmois6_new_${site}.dat


##################################################################
echo "--> ****  Mise au format FTECLEDR 2T sur 3T *******************************"

NSTEP=${NJOB}_80
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_${site}_reportmois9.dat 1000 1"
SORT_O="${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_${site}_reportmois9_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF    27:1 - 27:,
        RETUW_NT  28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT

touch ${DFILT}/${NJOB}_80_${IB}_SORT_FTECLEDAR_O.dat
NSTEP=${NJOB}_90
#Double entry transaction code addition in dDVGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_${site}_reportmois9_O.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_${site}_reportmois9_O2.dat
EXECPRG

NSTEP=${NJOB}_100
# File generation in TTECLEDR table format
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8802
export ${PRG}_I1=${EPO_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_80_${IB}_SORT_FTECLEDAR_O.dat
#export ${PRG}_I3=${DFILT}/${NJOB}_70_${IB}_ESTM7603_DLSGTR.dat
export ${PRG}_I3=${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_${site}_reportmois9_O2.dat
export ${PRG}_I4=${EPO_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_REJETE_O4.dat
EXECPRG

echo "---> Complete zones"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	$41 = "20170911";
	$42 = "CloP";
	$43 = "20170911";
	$44 = "CloP"
	$57 = "EBSGTA"
	$59 = "5"
	print $0
}' \
 ${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat > ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_reportmois9_new_${site}.dat

##################################################################
echo "--> ****  Génération FTECLEDRSIISO  *******************************"

echo "---> Archivage corrections"
gzip -c ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_reportmois6_new_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331_reportmois6annulDLREGTRSOSpira64660.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_reportmois9_new_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630_reportmois9annulDLREGTRSOSpira64660.dat.gz

echo "---> Comptage modifs"
wc -l ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_reportmois6_new_${site}.dat ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_reportmois9_new_${site}.dat


##################################################################
##################################################################
echo "--->>>  1. Gestion PNA"
##################################################################
##################################################################

echo "---> Unzip P_ESPD3800_FTECLEDRSIISO_2017xxxx"
if [ "${ENV_PREFIX}" != "P" -a "${ENV_PREFIX}" != "T" ]
then
	DARCH2=/scordata_dcvprdobbatch/${site}/arch
	DFILP2=/scordata_dcvprdobbatch/${site}/perm
	ENV_PREFIX2=P
	cp ${DARCH2}/P_ESPD3800_FTECLEDRSIISO_20170331.dat.gz ${DARCH}
	cp ${DARCH2}/P_ESPD3800_FTECLEDRSIISO_20170630.dat.gz ${DARCH}
	gunzip -c ${DARCH}/P_ESPD3800_FTECLEDRSIISO_20170331.dat.gz > ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331.dat
	gunzip -c ${DARCH}/P_ESPD3800_FTECLEDRSIISO_20170630.dat.gz > ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630.dat
fi
if [ "${ENV_PREFIX}" = "P" ]
then
	gunzip -c ${DARCH}/P_ESPD3800_FTECLEDRSIISO_20170331.dat.gz > ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331.dat
	gunzip -c ${DARCH}/P_ESPD3800_FTECLEDRSIISO_20170630.dat.gz > ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630.dat
fi
if [ "${ENV_PREFIX}" = "T" ]
then
	echo "---> Fichiers copiés par dbatool"
fi

#################################################################

echo "---> Report ligne GLT Retro 1T sur mois 2T et 3T"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if (($6 == "2A410002" || $6 == "2A411002" || $6 == "2A436002" || $6 == "2A430002" || $6 == "2A431002" || 
		  $6 == "2A417002" || $6 == "2A431012" || $6 == "2A411012" || $6 == "2A437002") && $4 == 3 && $5 == 3)
	{
		if ($35 != 0) $35 = sprintf("%-.3lf",-$35);
		$4 = 6;
		$5 = 30;
		$59 = 5;
		print $0
	}
}' \
 ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331.dat > ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331_reportmois6PNAFAR_${site}.dat

echo "---> Report ligne GLT Retro 1T sur mois 2T et 3T"
awk 'BEGIN { FS="~"; OFS="~"; s="" } \
{
	if (($6 == "2A410002" || $6 == "2A411002" || $6 == "2A436002" || $6 == "2A430002" || $6 == "2A431002" || 
		  $6 == "2A417002" || $6 == "2A431012" || $6 == "2A411012" || $6 == "2A437002") && $4 == 6 && $5 == 3)
	{
		if ($35 != 0) $35 = sprintf("%-.3lf",-$35);
		$4 = 9;
		$5 = 30;
		$59 = 5;
		print $0
	}
}' \
 ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630.dat > ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630_reportmois9PNAFAR_${site}.dat

echo "---> Archivage corrections"
gzip -c ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331_reportmois6PNAFAR_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331_reportmois6PNAFAR_Spira64660.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630_reportmois9PNAFAR_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630_reportmois9PNAFAR_Spira64660.dat.gz

echo "---> Comptage modifs"
wc -l ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331_reportmois6PNAFAR_${site}.dat ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630_reportmois9PNAFAR_${site}.dat
 
##################################################################
echo "--> ****  Génération FTECLEDRSIISO FINAL *******************************"

echo "---> Cumul fichiers pour RA"
cat ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170331_reportmois6_new_${site}.dat ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331_reportmois6PNAFAR_${site}.dat > ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331_reportmois6all_${site}.dat
cat ${DFILT}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_20170630_reportmois9_new_${site}.dat ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630_reportmois9PNAFAR_${site}.dat > ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630_reportmois9all_${site}.dat

echo "---> Ajout fichier correction RTO pour RA"
if [ -s ${DFILT}/${ENV_PREFIX}_ESPD3700_FTECLEDRSIISO_addRto_${site}.dat ]
then
	gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3700_FTECLEDRSIISO_annulsansRto_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170930_annulsansRtoSpira64660.dat.gz
	gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3700_FTECLEDRSIISO_addRto_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170930_addRtoSpira64660.dat.gz
	cat ${DFILP}/${ENV_PREFIX}_ESPD3700_FTECLEDRSIISO_annulsansRto_${site}.dat ${DFILP}/${ENV_PREFIX}_ESPD3700_FTECLEDRSIISO_addRto_${site}.dat >> ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630_reportmois9all_${site}.dat
fi

echo "---> Archivage corrections"
gzip -c ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331_reportmois6all_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331_reportmois6AllpourRASpira64660.dat.gz
gzip -c ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630_reportmois9all_${site}.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630_reportmois9AllpourRASpira64660.dat.gz

echo "---> Move fichier pour RA"
cp ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170331_reportmois6all_${site}.dat ${DFILP}/${ENV_PREFIX}_ESPD8100_BSAR_FTECLEDRSIISO_2017_2Q_${prdsite}.dat
cp ${DFILT}/${ENV_PREFIX}_ESPD3800_FTECLEDRSIISO_20170630_reportmois9all_${site}.dat ${DFILP}/${ENV_PREFIX}_ESPD8100_BSAR_FTECLEDRSIISO_2017_3Q_${prdsite}.dat

echo "---> Comptage apres"
wc -l ${DFILP}/${ENV_PREFIX}_ESPD8100_BSAR_FTECLEDRSIISO_2017_*.dat

echo "--> ***********************************"
##################################################################

JOBEND