#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			            : Reception des fichiers d'ecritures Locales provenant de OneGL
# nom du script SHELL           : ESLD3861.cmd
# revision                      : 
# date de creation              : 04/07/2017
# auteur                        : R. Cassis
# references des specifications : Spira:61508
#-----------------------------------------------------------------------------
# description:
#
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#[001] 07/12/2017 R. Cassis :spira:66334 Les fichiers perimetre ES Local sont nomm�s ESL_ sont maintenant g�n�r�s dans le ESID7000
#[002] 27/12/2017 R. Cassis :Spira:66794 renomage de OLGL0010 en OTGL0010
#[003] 05/02/2018 R. Cassis :spira:67293 Correction sur le nom de fichier MVT sauvegard�
#[004] 19/07/2019 R. Cassis :spira:80028 Suppression de la gestion de flags obsolete avec parametre Force et du test du site FRAM.
#[005] 12/07/2021 D. TEIXEIRA : SPIRA 97709 replace ${ENV_PREFIX}_ESLD3800_FTECLEDALO_MVT.dat to ${ENV_PREFIX}_ESLD3800_FTECLEDA_MVT_I4I_LOC.dat
#[006] 18/10/2022 HR : SPIRA 107203 IFRS4 Local Adjustment O2/SAP interface- Exclude transation base on grouping 900/100
#[007] 12/05/2022 J.B-D     :spira:107645 remove from check if trncod = dlbtrncod
#[008] 13/01/2023 MiS : SPIRA 108408 Modifications des fichiers OTGL0010 remplaces par OTGL0030
#[009] 20/08/2024 JYP spira 112007 : activate checks for 27-11
#[010] 25/07/2025  Mr JYP :US 5559 spira 113075 : SERQS split files by site
#[011] 17/09/2025  Mr JYP :US 6954 SERQS bugfix LOCAL ESLD3860
#===============================================================================
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctftp.cmd

# Get input parameters
CRE_D=$1
CONSOYEA=$2
CONSOMTH=$3
INVCONSO_D=$4

# Job Initialisation
JOBINIT

#[008]
FICFROMONEGL=OTGL0030_FTECLEDALO_MVT_${HOST_PRDSIT}_${CRE_D}
FICFROMONEGL1=OTGL0030_FTECLEDALO_MVT_${HOST_PRDSIT}
CONSOMTH=`echo "${CONSOMTH}" | awk '{ if (length($0) < 2) print "0" $0; else print $0;}'`
FICFROMONEGLARC=${FICFROMONEGL1}_${INVCONSO_D}_${CONSOYEA}${CONSOMTH}_${CRE_D}

ECHO_LOG "#========================================================================="
ECHO_LOG "-> CRE_D ..................: ${CRE_D}"
ECHO_LOG "-> INVCONSO_D .............: ${INVCONSO_D}"
ECHO_LOG "-> CONSOYEA ...............: ${CONSOYEA}"
ECHO_LOG "-> CONSOMTH ...............: ${CONSOMTH}"
ECHO_LOG "-> EST_VARIANTE ...........: ${EST_VARIANTE}"
ECHO_LOG "-> FICFROMONEGL ...........: ${FICFROMONEGL}"
ECHO_LOG "-> FICFROMONEGL1 ..........: ${FICFROMONEGL1}"
ECHO_LOG "-> FICFROMONEGLARC ........: ${FICFROMONEGLARC}"
ECHO_LOG "-> SITE_ONEGL .............: ${SITE_ONEGL}"
ECHO_LOG "-> ESL_FTECLEDALO_MVT_PREV : $ESL_FTECLEDALO_MVT_PREV "
ECHO_LOG "#========================================================================="

#[004]
if [ -s ${DFILT}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat ]
then

	# Fichier d�j� extrait mais rejet� pour cause d'erreurs detect�es, ici on force le traitement
	NSTEP=${NJOB}_01
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="mv ${DFILT}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat ${DFILP}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat ${DFILP}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat"

	#[004]
	NSTEP=${NJOB}_02
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${DFILP}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat > ${DTRANSFER}/OneGL/fromsave/${ENV_PREFIX}_${FICFROMONEGL}.dat.gz"
	
	#[005]
	NSTEP=${NJOB}_03
	# ARCHIVAGE
	#----------------------------------------------------------------------------
	LIBEL="Archive last file to DARCH : ${FICFROMONEGLARC}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${DFILP}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat > ${DARCH}/${ENV_PREFIX}_${FICFROMONEGLARC}.dat.gz"
	
	NSTEP=${NJOB}_04
	# FTP - Delete FTECLEDALO_MVT on OneGL server /paris/to
	# ----------------
	LIBEL="Delete FTECLEDALO_MVT on OneGL server /../to"
	FTP_FILE=${ENV_PREFIX}_${FICFROMONEGL}*.zip
	FTP_I=${ENV_PREFIX}_${FICFROMONEGL}*.zip
	FTP_SITE=${SITE_ONEGL}
	FTP_WAY=MDEL2
	FTP

	JOBEND
	
fi

NSTEP=${NJOB}_10
# FTP - Get FTECLEDALO_MVT OneGL data from OneGL server
# ----------------
LIBEL="Get FTECLEDALO_MVT OneGL data from OneGL server"
FTP_FILE=${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.zip
FTP_SITE=${SITE_ONEGL}
FTP_MODE=binary
FTP_WAY=MGET
FTP

if [ -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.zip ]
then

	ONEGLFILEZIP=`ls -rt ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.zip | tail -1`
	echo "File to unzip: ${ONEGLFILEZIP}"	
	NSTEP=${NJOB}_20
	LIBEL="UNZIP Cessions File"
	#-----------------------------------------------------------------
	ZIP_ODIR=${DFILT}
	ZIP_I=${ONEGLFILEZIP}
	ZIP_OPT=""
	PKUNZIP

fi

ls -l ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat

if [ ! -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat ] &&
   [ -s ${ESL_FTECLEDALO_MVT_PREV} ]
then
	ECHO_LOG "#==============================================================="
	ECHO_LOG "#======> No OneGL data file received for Post-Social Local process -> STOP Processing <======="
	ECHO_LOG "#==============================================================="
	STEPEND 1	
fi

if [ -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat ]
then

	ONEGLFILEDAT=`ls -rt ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat | tail -1`
	ECHO_LOG "File to move: ${ONEGLFILEDAT}"	

	NSTEP=${NJOB}_30
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="copy ${ONEGLFILEDAT} to ${DFILT}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat"
	EXECKSH_MODE=P
	EXECKSH "tr -d '\r' <${ONEGLFILEDAT} > ${DFILT}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat"

	NSTEP=${NJOB}_31
	#------------------------------------------------------------------------------
	LIBEL="Somme de controle des montants : FTECLEDA avant OneGL"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${ESL_FTECLEDALO_MVT_PREV} 1024"
	SORT_O="${DFILT}/${NSTEP}_${IB}_ESIDMVT.dat 1024"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF           1:1 -   1:EN,
	ESB_CF           2:1 -   2:EN,
	AN               3:1 -   3:EN,
	MOIS             4:1 -   4:EN,
	JOUR             5:1 -   5:EN,
	TRNCOD_CF        6:1 -   6:,
	TRNCOD1_CF       6:1 -   6:1,
	TRNCOD2_CF       6:3 -   6:4,
	CTR_NF           8:1 -   8:,
	SEC_NF          10:1 -  10:EN,
	UWY_NF          11:1 -  11:EN,
	AMT_M           19:1 -  19:EN 18/3,
	RETCTR_NF       24:1 -  24:,
	RTY_NF          27:1 -  27:,
	CUR_CF          34:1 -  34:,
	RETAMT_M        35:1 -  35:EN 18/3,
	RETINTAMT_M     88:1 -  88:EN 18/3,
	KEY_CF         101:1 - 101:
	
/KEYS	SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF,AMT_MC,RETAMT_MC,RETINTAMT_MC
exit
EOF
	SORT

	NSTEP=${NJOB}_32
	#------------------------------------------------------------------------------
	LIBEL="Somme de controle des montants : FTECLEDA apres Onegl"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat 1024"
	SORT_O="${DFILT}/${NSTEP}_${IB}_OLGLMVT.dat 1024"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF           1:1 -   1:EN,
	ESB_CF           2:1 -   2:EN,
	AN               3:1 -   3:EN,
	MOIS             4:1 -   4:EN,
	JOUR             5:1 -   5:EN,
	TRNCOD_CF        6:1 -   6:,
	TRNCOD1_CF       6:1 -   6:1,
	TRNCOD2_CF       6:3 -   6:4,
	CTR_NF           8:1 -   8:,
	SEC_NF          10:1 -  10:EN,
	UWY_NF          11:1 -  11:EN,
	AMT_M           19:1 -  19:EN 18/3,
	RETCTR_NF       24:1 -  24:,
	RTY_NF          27:1 -  27:,
	CUR_CF          34:1 -  34:,
	RETAMT_M        35:1 -  35:EN 18/3,
	RETINTAMT_M     88:1 -  88:EN 18/3,
	KEY_CF         101:1 - 101:
	
/KEYS	SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF,AMT_MC,RETAMT_MC,RETINTAMT_MC
exit
EOF
	SORT

	NSTEP=${NJOB}_33
	# Inverse montants pour compare
	#-----------------------------------------------------------------------------
	LIBEL="Inverse montants pour compare"
	AWK_I=${DFILT}/${NJOB}_32_${IB}_OLGLMVT.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_OLGLMVT.dat
	AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{
			if (\$9   != 0) \$9   = sprintf("%-.3lf",-\$9 );
			if (\$10  != 0) \$10  = sprintf("%-.3lf",-\$10);
			if (\$11  != 0) \$11  = sprintf("%-.3lf",-\$11);
			print \$0;
		}
exit
EOF
	AWK

	NSTEP=${NJOB}_34
	#------------------------------------------------------------------------------
	LIBEL="Somme de controle des montants"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_31_${IB}_ESIDMVT.dat 1024"
	SORT_I2="${DFILT}/${NJOB}_33_${IB}_AWK_OLGLMVT.dat 1024"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CUMMVT.dat 1024"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF           1:1 -   1:EN,
	AN               2:1 -   2:EN,
	MOIS             3:1 -   3:EN,
	CTR_NF           4:1 -   4:,
	UWY_NF           5:1 -   5:EN,
	SEC_NF           6:1 -   6:EN,
	TRNCOD_CF        7:1 -   7:,
	RETCTR_NF        8:1 -   8:,
	AMT_M            9:1 -   9:EN 18/3,
	RETAMT_M        10:1 -  10:EN 18/3,
	RETINTAMT_M     11:1 -  11:EN 18/3
/KEYS	SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF,AMT_MC,RETAMT_MC,RETINTAMT_MC
exit
EOF
	SORT

	#[017]
	NSTEP=${NJOB}_35
	# Liste differences sur montants
	#-----------------------------------------------------------------------------
	LIBEL="Liste differences sur montants"
	AWK_I=${DFILT}/${NJOB}_34_${IB}_SORT_CUMMVT.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DIFFMVT_MONTANTS.log
	AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{
		if ( \$9 > 1 || \$9 < -1 || \$10 > 1 || \$10 < -1 || \$11 > 1 || \$11 < -1) print \$0;
	}
exit
EOF
	AWK

	#[017]
	NSTEP=${NJOB}_36
	# Liste differences sur signe montant retro
	#-----------------------------------------------------------------------------
	LIBEL="Liste differences sur signe montant retro"
	AWK_I=${DFILT}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log
	AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{
		if (((\$88 < 0 && \$35 > 0) || (\$88 > 0 && \$35 < 0)) && \$88 != "" && \$88 != 0) print \$0;
	}
exit
EOF
	AWK

	NSTEP=${NJOB}_37
	# Controle Contrats Europe et identifiant
	#-----------------------------------------------------------------------------
	LIBEL="Liste mouvements sans identifiants"
	AWK_I=${DFILT}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DIFFMVT_IDENTIFIANT.log
	AWK_PARAM=" -v an=${BALSHTYEA_NF} -v mois=${BALSHTMTH_NF} "
	AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{
			if ( ! ((\$24 == "17P000028" || \$24 == "17P000037" || \$24 == "17P000038" || \$24 == "17P000039" || \$24 == "17P000052" || \$24 == "17P000055" ||
			         \$24 == "17P000056" || \$24 == "17P000058" || \$24 == "17P000059" || \$24 == "17P000060" || \$8  == "17ZF35062" || \$8  == "17ZF41634" ||
			         \$8  == "17ZF41638" || \$8  == "17ZF41639" || \$8  == "17ZF41640" || \$8  == "17ZF41641" || \$8  == "17ZF41644" || \$8  == "17ZF41645" ||
			         \$8  == "17ZF41646" || \$8  == "17ZF41647" || \$8  == "17ZF41653" || \$8  == "17ZF41654" || \$8  == "17ZF41787" || \$8  == "17ZF47945" ||
			         \$8  == "17ZF47946") ||
			        (substr(\$6,8,1)  == "C" || substr(\$6,8,1)  == "E") ||
			        (\$1 ==  5 && \$2 == 10) || 
			        (\$1 == 16 && \$2 == 1 ) || 
			        (\$1 == 19 && \$2 == 2 ) ||
			        (\$1 == 14 && \$2 == 1 ) ||
			        (\$1 == 14 && \$2 == 10) ||
			        (\$1 == 14 && \$2 == 11) ||
			        (\$1 == 14 && \$2 == 12) ||
			        (\$1 == 14 && \$2 == 13) ||
			        (\$1 == 14 && \$2 == 3 ) ||
			        (\$1 == 14 && \$2 == 4 ) ||
			        (\$1 == 14 && \$2 == 5 ) ||
			        (\$1 == 14 && \$2 == 6 ) ||
			        (\$1 == 14 && \$2 == 7 ) ||
			        (\$1 == 14 && \$2 == 8 ) ||
			        (\$1 == 14 && \$2 == 9 ) ||
			        (\$1 == 25 && \$2 == 1 ) ||
			        (\$1 == 26 && \$2 == 1 ) ||
			        (\$1 == 26 && \$2 == 2 ) ||
			        (\$1 == 26 && \$2 == 3 ) ||
			        (\$1 == 26 && \$2 == 7 ) ||
			        (\$1 == 26 && \$2 == 9 ) ||
			        (\$1 == 26 && \$2 == 10 ) ||
			        (\$1 == 27 && \$2 != 11 ) ||
			        (\$6 == \$7 ) ) )
			{
				if (\$102 == "" && (\$19 > 1 || \$19 < -1) && (\$35 > 1 || \$35 < -1) && \$3 == an && \$4 == mois)
					print \$0;
			}
		}
exit
EOF
	AWK

	#[017]
	if [ -s ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log ] ||
	   [ -s ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log ] ||
	   [ -s ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log ]
	then
		
		ECHO_LOG "#==========================================================================="
		ECHO_LOG "#===> Erreurs rencontr�es dans le controle du Fichier MVT provenant de ONEGL"
		ECHO_LOG "#===> Arret ou Warning."
		ECHO_LOG "#==========================================================================="
		wc -l ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log
		wc -l ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log
		wc -l ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log
		#A VOIR APRES..................
		if [ ${EST_VARIANTE} = "5" -o ${EST_VARIANTE} = "6" ]
		then
			STEPEND 1
		else
			echo "WARNING" > ${DFILT}/${NSTEP}_${IB}_CTLONEGL.wng
		fi

	#[019]
	fi	

	NSTEP=${NJOB}_40
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="mv ${DFILT}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat ${ESL_FTECLEDALO_MVT_PREV} "
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${ENV_PREFIX}_ESLD3910_FTECLEDA_MVT_I4I_LOC.dat ${ESL_FTECLEDALO_MVT_PREV} "

fi

#[012]
if [ -s ${ESL_FTECLEDALO_MVT_PREV} ] &&
   [ -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.zip ]
then

	NSTEP=${NJOB}_50
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${ESL_FTECLEDALO_MVT_PREV} > ${DTRANSFER}/OneGL/fromsave/${ENV_PREFIX}_${FICFROMONEGL}.dat.gz"

	NSTEP=${NJOB}_60
	# ARCHIVAGE
	#----------------------------------------------------------------------------
	LIBEL="Archive last file to DARCH : ${FICFROMONEGLARC}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${ESL_FTECLEDALO_MVT_PREV}  > ${DARCH}/${ENV_PREFIX}_${FICFROMONEGLARC}.dat.gz"

	NSTEP=${NJOB}_70
	# FTP - Delete FTECLEDALO_MVT on OneGL server /paris/to
	# ----------------
	LIBEL="Delete FTECLEDALO_MVT on OneGL server /../to"
	FTP_FILE=${ENV_PREFIX}_${FICFROMONEGL}*.zip
	FTP_I=${ENV_PREFIX}_${FICFROMONEGL}*.zip
	FTP_SITE=${SITE_ONEGL}
	FTP_WAY=MDEL2
	FTP
	
fi

NSTEP=${NJOB}_100
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

