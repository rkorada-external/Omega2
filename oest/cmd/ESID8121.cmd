#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE - Fichiers SRV vers RA
# nom du script SHELL           : ESID8121.cmd
# revision                      : 
# date de creation              : 27/07/2016
# auteur                        : Roger Cassis
# references des specifications : :spot:31717 Export fichiers SRV vers RA
#-----------------------------------------------------------------------------
# description
#  Préparation des fichiers SRV pour chargement dans RA
#
# Launch applicative job ESID8121
#
#-----------------------------------------------------------------------------
# historiques des modifications:
#[001] 06/04/2017 Roger Cassis :spira:xxxxx Suppression d'une condition qui bloque l'extraction de la TLIFEST
#[002] 24/05/2017 Roger Cassis :spot:32392 Si établissement pas renseigné, on force à 1
#[003] 17/05/2017 Roger Cassis :spira:60217 Ajout fichier EST_DLRGTAA dans ESID8120 pour retirer les echanges internes en trop vers RA
#[004] 17/07/2017 Roger Cassis :spira:63026 On prend le dernier fichier EST_DLRGTAA si plusieurs existent
#[005] 17/07/2017 Roger Cassis :spira:63026 On prend le dernier fichier EST_DLRGTAA si plusieurs existent
#[006] 14/12/2017 Roger Cassis :spira:66337 Ajout Extraction de la TLIFEST pour RA
#[007] 03/12/2020 Belaid Lagha :spira:91417 Changer la condition variante photo plan
#[008] 01/08/2023 JYP/Mariem/CAP :spira:110270 impact of new PERICASE, remove 3 columns on RA files 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4
CLODATMAX_D=$5
INVCONSO_D=$6
NORME=$7
TYPEINV=$8
TYPEDATE=$9
EXEPLAN=${10}
VSRPLAN=${11}
SSDs0=${12}
SSDESPLAN_LL=${13}
ICLODAT_D=${14}


################################################################
# Format du Fichier CLS_Type
#Norme données~type inv~année/mois du trimestre
#SRV~INV~YYYYMM
################################################################

if [ "${DNZFILP}" = "" ]
then
	DNZFILP=${DFILP}
	DNZFILI=${DFILI}
	DNZFILT=${DFILT}
fi

TRIM=`echo ${CLODATMAX_D} | awk '{trim = substr($0,5,2)/3; print trim;}'`
BALSHTYEA_NFTRIM=`echo ${CLODATMAX_D} | cut -c1-4` 
BALSHTMTH_NFDEB=`echo ${CLODATMAX_D} | awk '{mth = substr($0,5,2) - 2; print mth}'`
BALSHTMTH_NFFIN=`echo ${CLODATMAX_D} | cut -c5-6` 
ANTRIM=`echo ${CLODATMAX_D} | cut -c1-4` 
MOISTRIM=`echo ${CLODATMAX_D} | cut -c5-6` 
JOURTRIM=`echo ${CLODATMAX_D} | cut -c7-8` 
MOISTRIMDEB=`echo ${CLODATMAX_D} | cut -c5-6` 

EST_CLS=${NCHAIN}_CLSTYPE_${HOST_PRDSIT}.dat
EST_FILE_LIST=${NCHAIN}_FILE_LIST_${HOST_PRDSIT}.dat

# Job Initialisation
JOBINIT

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> EST_SRGTR_VENTIL.......: ${EST_SRGTR_VENTIL}"
ECHO_LOG "#===> EST_SRGTE_SRV_PA.......: ${EST_SRGTE_SRV_PA}"
ECHO_LOG "#===> EST_SRGTE_SRV_PC.......: ${EST_SRGTE_SRV_PC}"
ECHO_LOG "#===> EST_SRGTEF_SRV_PA......: ${EST_SRGTEF_SRV_PA}"
ECHO_LOG "#===> EST_SRGTEF_SRV_PC......: ${EST_SRGTEF_SRV_PC}"
ECHO_LOG "#===> EST_ECRSRVAPC_PA.......: ${EST_ECRSRVAPC_PA}"
ECHO_LOG "#===> EST_ECRSRVRPC_PA.......: ${EST_ECRSRVRPC_PA}"
ECHO_LOG "#===> EST_FLIFPLN1_VENTIL....: ${EST_FLIFPLN1_VENTIL}"
ECHO_LOG "#===> EST_FLIFPLN3_VENTIL....: ${EST_FLIFPLN3_VENTIL}"
ECHO_LOG "#===> EST_IARVPERICASE4......: ${EST_IARVPERICASE4}"
ECHO_LOG "#===> EST_IAVPERICASE0.......: ${EST_IAVPERICASE0}"
ECHO_LOG "#===> EST_DLRGTAA............: ${EST_DLRGTAA}"
ECHO_LOG "#===> EST_FILE_LIST..........: ${DNZFILP}/${EST_FILE_LIST}"
ECHO_LOG "#===> EST_CLS................: ${DNZFILP}/${EST_CLS}"
ECHO_LOG "#===> CLODAT_D...............: ${CLODAT_D}"
ECHO_LOG "#===> NORME..................: ${NORME}"
ECHO_LOG "#===> TYPEINV................: ${TYPEINV}"
ECHO_LOG "#===> TYPEDATE...............: ${TYPEDATE}"
ECHO_LOG "#===> CLODATMAX_D............: ${CLODATMAX_D}"
ECHO_LOG "#===> TRIM...................: ${TRIM}"
ECHO_LOG "#===> ANTRIM.................: ${ANTRIM}"
ECHO_LOG "#===> MOISTRIM...............: ${MOISTRIM}"
ECHO_LOG "#===> JOURTRIM...............: ${JOURTRIM}"
ECHO_LOG "#===> BALSHTYEA_NF...........: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF...........: ${BALSHTMTH_NF}"
ECHO_LOG "#===> BALSHTYEA_NFTRIM.......: ${BALSHTYEA_NFTRIM}"
ECHO_LOG "#===> BALSHTMTH_NFDEB........: ${BALSHTMTH_NFDEB}"
ECHO_LOG "#===> BALSHTMTH_NFFIN........: ${BALSHTMTH_NFFIN}"
ECHO_LOG "#===> EST_VARIANTE...........: ${EST_VARIANTE}"
ECHO_LOG "#========================================================================="

if [ "${TYPEDATE}" = "T" ]
then
	NSTEP=${NJOB}_000
	LIBEL="Erase Last Permanent files"
	RMFIL "${DFILT}/${NCHAIN}_listeFicsSRVRA.dat"
	RMFIL "${DNZFILP}/${NCHAIN}_*${HOST_PRDSIT}.dat"
fi

if [ "${TYPEDATE}" = "T" ]
then
	# Files with quarter date in file name
	echo "${EST_SRGTE_SRV_PC}~BSTA_SRGTE_SRV_PC"         > ${DFILT}/${NCHAIN}_listeFicsSRVRA.dat
	echo "${EST_SRGTEF_SRV_PC}~BSTA_SRGTEF_SRV_PC"      >> ${DFILT}/${NCHAIN}_listeFicsSRVRA.dat
	echo "${EST_ECRSRVAPC_PA}~BSTA_ECRSRVAPC_PA"        >> ${DFILT}/${NCHAIN}_listeFicsSRVRA.dat
	echo "${EST_ECRSRVRPC_PA}~BSTA_ECRSRVRPC_PA"        >> ${DFILT}/${NCHAIN}_listeFicsSRVRA.dat
	echo "${EST_FLIFPLN1_VENTIL}~BSTA_FLIFPLN1_VENTIL"  >> ${DFILT}/${NCHAIN}_listeFicsSRVRA.dat
	echo "${EST_FLIFPLN3_VENTIL}~BSTA_FLIFPLN3_VENTIL"  >> ${DFILT}/${NCHAIN}_listeFicsSRVRA.dat
	JOBEND
else
	# Files with annual date in file name (1231)
	echo "${EST_SRGTR_VENTIL}~BSTA_SRGTR_VENTIL"        >> ${DFILT}/${NCHAIN}_listeFicsSRVRA.dat
	echo "${EST_SRGTE_SRV_PA}~BSTA_SRGTE_SRV_PA"        >> ${DFILT}/${NCHAIN}_listeFicsSRVRA.dat
	echo "${EST_SRGTEF_SRV_PA}~BSTA_SRGTEF_SRV_PA"      >> ${DFILT}/${NCHAIN}_listeFicsSRVRA.dat
fi

#[004]
EST_DLRGTAA=`ls -rt ${DFILI}/*ESID2050_DLRGTAA_*.dat | tail -1`

#[003]
NSTEP=${NJOB}_05
# Begin sort
#----------------------------------------------------------------------------
LIBEL="selection of life contracts from Pericase"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IAVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_CONTRATSVIE.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3: - 3:
/KEYS CTR_NF
/SUM
/REFORMAT CTR_NF
exit
EOF
SORT

#[003]
NSTEP=${NJOB}_06
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Join DLRGTAA file with life ctrs file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLRGTAA} 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_DLRGTAA.dat 500 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF_F1 8: -  8:,
        CTR_NF_F2 1: -  1:,
        ALL       1: - 71:
/INFILE  ${EST_DLRGTAA} "~"
/JOINKEYS sorted CTR_NF_F1
/INFILE  ${DFILT}/${NJOB}_05_${IB}_SORT_O_CONTRATSVIE.dat "~"
/JOINKEYS sorted CTR_NF_F2
/OUTFILE  ${SORT_O}
/REFORMAT LEFTSIDE: ALL
exit
EOF
SORT

#[003]
NSTEP=${NJOB}_07
# Begin bcp
#----------------------------------------------------------------------------
LIBEL="Distinct on Joined DLRGTAA file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_06_${IB}_SORT_O_DLRGTAA.dat 500"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_DLRGTAA.dat 500"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL 1:1 - 71:
/KEYS ALL
/SUM
exit
EOF
SORT

#[003]
NSTEP=${NJOB}_08
# Update balance sheet date
#-----------------------------------------------------------------------------
LIBEL="invert OI DLRGTAA File to add to SRGTE file"
AWK_I=${DFILT}/${NJOB}_07_${IB}_SORT_O_DLRGTAA.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLRGTAA_INVERTEDAMOUNTS.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{
			if (\$19 != 0) \$19 = sprintf("%-.3lf",-\$19) # AMT_M
			if (\$35 != 0) \$35 = sprintf("%-.3lf",-\$35); else \$35 = 0.000 # RETAMT_M
			\$56 = 0      #COMACC_B
			\$57 = 1      #ADJCOD_CT
			\$58 = "PAPC" #ORICOD_CF
			\$60 = "A"    #ACCRET_B
			\$65 = 2      #GAAP_NF
			print \$0;
		}
exit
EOF
AWK

for fic1 in `cat ${DFILT}/${NCHAIN}_listeFicsSRVRA.dat`
do
	ent=`echo "${fic1}" | cut -d~ -f1`
	sor=`echo "${fic1}" | cut -d~ -f2`
	ECHO_LOG "--->>>  Process ${ent} ==>> ${sor}"

	if [ -f "${ent}" ]; then
		SRGTR=N
		if [ "${ent}" = "${EST_SRGTR_VENTIL}" ]; then
			SRGTR=Y
		fi
		ACMTRSNULL=N
		if [ "${ent}" = "${EST_SRGTR_VENTIL}" -o "${ent}" = "${EST_SRGTE_SRV_PA}" -o "${ent}" = "${EST_SRGTEF_SRV_PA}" ]; then
			ACMTRSNULL=Y
		fi
		ECHO_LOG ""
		ECHO_LOG "#===> SRGTR...........: ${SRGTR}"
		ECHO_LOG "#===> ACMTRSNULL......: ${ACMTRSNULL}"
		#[002]
		NSTEP=${NJOB}_${sor}
		# Update balance sheet date
		#-----------------------------------------------------------------------------
		LIBEL="Update balance sheet date to ${CLODATMAX_D} for ${sor}"
		AWK_I=${ent}
		AWK_O=${DNZFILP}/${NCHAIN}_${sor}_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
		AWK_PARAM=" -v an=${ANTRIM} -v mois=${MOISTRIM} -v jour=${JOURTRIM} -v srgtr=${SRGTR} -v acmtrs=${ACMTRSNULL} "
		AWK_CMD=`CFTMP`
		INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{
			\$3 = an;
			\$4 = mois;
			\$5 = jour;
			if (\$2 == "") \$2 = "1";
			if (acmtrs == "Y")
			{ 
				\$45 = "";
			}
			if (srgtr == "Y")
			{ 
				if (\$19 > 0.1 || \$19 < -0.1) print \$0;
			}
			else print \$0;
		}
exit
EOF
		AWK
	fi
done

#[003]
NSTEP=${NJOB}_09
#Copie fichiers SRV pour chargement dans RA
#----------------------------------------------------------------------------
#LIBEL="Add inverted OI movements from DLRGTAA"
EXECKSH_MODE=P
EXECKSH "cat ${DFILT}/${NJOB}_08_${IB}_AWK_DLRGTAA_INVERTEDAMOUNTS.dat >> ${DNZFILP}/${NCHAIN}_BSTA_SRGTE_SRV_PA_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat"


if [ "${EST_IARVPERICASE4}" != "" ]; then

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="remove 3 last columns, no need them on RA side "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IARVPERICASE4} 2000 1"
SORT_O="${DFILT}/${NJOB}_10_${IB}_IARVPERICASE_TRUNCATED.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
       Filler1         1:1   -  206:
/COPY
/OUTFILE ${SORT_O}
/REFORMAT Filler1
exit
EOF
SORT



NSTEP=${NJOB}_11
#Copie fichiers SRV pour chargement dans RA
#----------------------------------------------------------------------------
#LIBEL="Copie fichiers SRV pour chargement dans RA"
EXECKSH_MODE=P
EXECKSH "cp ${DFILT}/${NJOB}_10_${IB}_IARVPERICASE_TRUNCATED.dat ${DNZFILP}/${NCHAIN}_BSTA_IARVPERICASE4_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat"

fi

#[006]
if [ ! -f ${DFILP}/${NCHAIN}_TLIFEST_YEAR_RA.dat ]
then

	# cas 1er passage : extraction de tout jusqu'a < trim en cours
	NSTEP=${NJOB}_30
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Initialization permanent file"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILP}/${NCHAIN}_TLIFEST_YEAR_RA.dat
	BCP_QRY="select * from best..tlifest a, bref..tbatchssd b
	         where a.ssd_cf = b.ssd_cf 
	         and   b.BATCHUSER_CF = suser_name()
	         and   a.balshey_nf   = ${BALSHTYEA_NF}
	         and   a.balshtmth_nf < ${BALSHTMTH_NFDEB}"
	BCP

fi

if [ ${EST_VARIANTE} -eq 6 ]
then

	# cas compta trimestrielle : extraction de tout <= trim en cours
	NSTEP=${NJOB}_20
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Extraction of Tlifest for quaterly booking"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DNZFILP}/${NCHAIN}_TLIFEST_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
	BCP_QRY="select * from best..tlifest a, bref..tbatchssd b
	         where a.ssd_cf = b.ssd_cf 
	         and   b.BATCHUSER_CF = suser_name()
	         and   a.balshey_nf   = ${BALSHTYEA_NF}
	         and   a.balshtmth_nf <= ${BALSHTMTH_NFFIN}"
	BCP
		
	NSTEP=${NJOB}_40
	#Copie fichiers SRV pour chargement dans RA
	#----------------------------------------------------------------------------
	LIBEL="Sauvegarde fichier permanent TLIFEST"
	EXECKSH_MODE=P
	EXECKSH "cp ${DNZFILP}/${NCHAIN}_TLIFEST_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat ${DFILP}/${NCHAIN}_TLIFEST_YEAR_RA.dat"

else

	# cas regime de croisiere : extraction de tout >= trim en cours
	NSTEP=${NJOB}_50
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Daily Extraction of Tlifest"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILT}/${NCHAIN}_TLIFEST_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
	BCP_QRY="select * from best..tlifest a, bref..tbatchssd b
	         where a.ssd_cf = b.ssd_cf 
	         and   b.BATCHUSER_CF = suser_name()
	         and   a.balshey_nf   = ${BALSHTYEA_NF}
	         and   a.balshtmth_nf >= ${BALSHTMTH_NFDEB}"
	BCP

	NSTEP=${NJOB}_60
	#Copie fichiers SRV pour chargement dans RA
	#----------------------------------------------------------------------------
	LIBEL="Ajoute fichier trimestriel TLIFEST au fichier permanent"
	EXECKSH_MODE=P
	EXECKSH "cat ${DFILP}/${NCHAIN}_TLIFEST_YEAR_RA.dat ${DFILT}/${NCHAIN}_TLIFEST_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat > ${DNZFILP}/${NCHAIN}_TLIFEST_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat"

fi

if [[ ${EST_VARIANTE} -eq 7 || (${SSDESPLAN_LL} != "_" && ${SSDESPLAN_LL} != "") ]]
then
	# Variante Photo plan
	SSDS=`echo ${SSDs0} | sed -e s/_/,/g | awk '{s1 = substr($0,2,length($0)-2); print s1;}'`
	echo "${ICLODAT_D}~${EXEPLAN}~${VSRPLAN}~(${SSDS})" > ${DNZFILP}/${NCHAIN}_PHOTOPLAN_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
	gzip -c ${DNZFILP}/${NCHAIN}_PHOTOPLAN_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat > ${DSAVE}/${SVG}_${NCHAIN}_PHOTOPLAN_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz
fi

#EXECKSH "cp ${EST_FLIFDRI}           ${DNZFILP}/${NCHAIN}_BSTA_EST_FLIFDRI_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat"

ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Creation fichier descriptif dans ${EST_CLS}"
ECHO_LOG "#"
#------------------------------------------------------------------------------
echo "${NORME}~${TYPEINV}~${BALSHTYEA_NFTRIM}${BALSHTMTH_NFFIN}" > ${DNZFILP}/${EST_CLS}
cat ${DNZFILP}/${EST_CLS}

ECHO_LOG "#"
ECHO_LOG "#===> Creation liste des fichiers dans ${EST_FILE_LIST}"
ECHO_LOG "#"
#------------------------------------------------------------------------------
wc -l ${DNZFILP}/${NCHAIN}_*${HOST_PRDSIT}.dat |  grep -v "total" | grep -v "FILE_LIST" | awk '{split($0,tab1," "); i=split(tab1[2],tab2,"/"); print tab2[i] "~" tab1[1]}' > ${DNZFILP}/${EST_FILE_LIST}
cat ${DNZFILP}/${EST_FILE_LIST}

ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Sauvegarde des fichiers"
ECHO_LOG "#"
#------------------------------------------------------------------------------
gzip -c ${DNZFILP}/${NCHAIN}_BSTA_SRGTR_VENTIL_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat    > ${DSAVE}/${SVG}_${NCHAIN}_BSTA_SRGTR_VENTIL_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz
gzip -c ${DNZFILP}/${NCHAIN}_BSTA_SRGTE_SRV_PA_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat    > ${DSAVE}/${SVG}_${NCHAIN}_BSTA_SRGTE_SRV_PA_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz
gzip -c ${DNZFILP}/${NCHAIN}_BSTA_SRGTE_SRV_PC_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat    > ${DSAVE}/${SVG}_${NCHAIN}_BSTA_SRGTE_SRV_PC_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz
gzip -c ${DNZFILP}/${NCHAIN}_BSTA_SRGTEF_SRV_PA_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat   > ${DSAVE}/${SVG}_${NCHAIN}_BSTA_SRGTEF_SRV_PA_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz
gzip -c ${DNZFILP}/${NCHAIN}_BSTA_SRGTEF_SRV_PC_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat   > ${DSAVE}/${SVG}_${NCHAIN}_BSTA_SRGTEF_SRV_PC_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz
gzip -c ${DNZFILP}/${NCHAIN}_BSTA_ECRSRVAPC_PA_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat    > ${DSAVE}/${SVG}_${NCHAIN}_BSTA_ECRSRVAPC_PA_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz
gzip -c ${DNZFILP}/${NCHAIN}_BSTA_ECRSRVRPC_PA_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat    > ${DSAVE}/${SVG}_${NCHAIN}_BSTA_ECRSRVRPC_PA_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz
gzip -c ${DNZFILP}/${NCHAIN}_BSTA_FLIFPLN1_VENTIL_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat > ${DSAVE}/${SVG}_${NCHAIN}_BSTA_FLIFPLN1_VENTIL_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz
gzip -c ${DNZFILP}/${NCHAIN}_BSTA_FLIFPLN3_VENTIL_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat > ${DSAVE}/${SVG}_${NCHAIN}_BSTA_FLIFPLN3_VENTIL_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz
gzip -c ${DNZFILP}/${NCHAIN}_BSTA_IARVPERICASE4_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat   > ${DSAVE}/${SVG}_${NCHAIN}_BSTA_IARVPERICASE4_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz
gzip -c ${DNZFILP}/${NCHAIN}_TLIFEST_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat              > ${DSAVE}/${SVG}_${NCHAIN}_TLIFEST_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat.gz

ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Delete temporary file"
ECHO_LOG "#"
NSTEP=${NJOB}_100
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
RMFIL "${DFILT}/${NCHAIN}_TLIFEST_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat"

JOBEND
