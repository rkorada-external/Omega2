#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - preparation des fichiers pour one GL
# nom du script SHELL           : ESID3861.cmd
# date de creation              : 15/03/2011
# auteur                        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description: 
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#[001]  09/05/2011  R. Cassis     :spot:21408 - OneLG.
#[002]  24/08/2011  R. Cassis     :spot:22435 Parametrage pour Reception du fichier sur le serveur ONEGL.
#[003]  14/10/2011  R. CASSIS     :spot:22752 Nomage du fichier FTECLEDA_MVT provenant de OTGL0010 en OTGL0010
#[004]  30/11/2011  Roger Cassis  :spot:22859 Gestion transfert ONEGL et sauvegardes et archives.
#[005]  06/02/2012  Roger Cassis  :spot:23329 Archivage des fichiers OneGL avec dates.
#[006]  22/03/2012  Roger Cassis  :spot:23699 Si mois sur 1 position, on l'aligne sur 2 positions
#                                             Si le fichier flag du ESID3850 absent on genere un Abend
#[007]  18/07/2012  Roger Cassis  :spot:23742 Si Ny ou Mutre -> Pas de gestion OneGL
#[008]  21/03/2013  Roger Cassis  :spot:25006 Suppression condition sur USA1 et test fichier non vide MVT pour abort
#[009]  19/06/2013  Roger Cassis  :spot:25305 Ajout controles sur le fichier ONEGL
#[010]  25/07/2013  Paul Coppin   :spot:25405 Ajout controles sur le fichier ONEGL filiales 14, 25 et 26.
#[011]  08/01/2014  Roger Cassis  :spot:26048 :spot:25427 Warning si controles Onegl pas ok en mode simu au lieu d'abort
#[012]  28/02/2014      JBG             Remplacement nawk par awk
#[013]  05/08/2015  P. Coppin     :spot:29183  plantage du job ESID3860 en PRD USA.
#[014]  02/02/2015  Roger Cassis  :spot:28191 Reactivate data controls for life subsidiarys
#[015]  05/11/2015  Roger Cassis  :spot:29635 Les fichiers d'ano sont appel�s .log au lieu de .dat pour consultation ult�rieure
#[016]  01/02/2016  Roger Cassis  :spot:30154 Ajoute ssd 5 / etab 10 dans les exeptions de contr�le + option de reprise FORCE_CT
#[017]  02/05/2016  Roger Cassis  :spot:30545 Agrandissement taille des enregistrements dans les tris
#[018]  13/06/2016  Roger Cassis  :spot:30733 Si mode Simu et erreurs rencontrees, on copie quand m�me le fichier _MVT dans DFILP.
#                                             On ajoute les postes %E et %C dans les omissions des contr�les
#[019]  29/07/2016  Roger Cassis  :spot:30999 Pas de controle d'identifiants sur filiale 27 et 26:7-9-10
#[020]  14/12/2017  Roger Cassis  :spira:66593 Automatisation de la reprise du traitement du fichier ONEGL par param�trage au lancement de la chaine.
#[021]  05/02/2018  Roger Cassis  :spira:67293 Correction sur le nom de fichier MVT sauvegard�
#[022]  19/07/2019  Roger Cassis  :spira:80028 Suppression de la gestion de flags obsolete avec parametre Force et du test du site FRAM.
#[023]  13/07/2020  JYP/TD        :spira:97709 use new filename from variabilisation (ESID3800_FTECLEDA_MVT_I4I_INV_${PARM_ICLODAT_D})
#[024]  20/01/2022  Roger Cassis  :spira:96729 Add SAP file managing for Test servers
#[025]  03/02/2022 T. DEUTSCH   : spira:100097 Add prm option to take SAP file
#[026]  06/10/2022	JBD						:spira 104929 rename ESID3800_FTECLEDA_MVT_I4I_INV for Perm into -> ${EST_FTECLEDA_MVT_PREV} and Temp into -> _ESPD3860_FTECLEDASO_SAP_MVT
#[027]  14/09/2022 DAD            :spira:103544 Add update of the POSTING file when restarting the job
#[028]  12/05/2022 J.B-D          :spira:107645 remove from check if trncod = dlbtrncod
#[029]	13/01/2023 MiS            :spira:108408 Modifications des fichiers OTGL0010 remplaces par OTGL0030
#[030]	09/03/2023 JYP/TD         :spira:109153 do NOT check some SSD/ESB
#[033]	31/03/2023 JYP/TD         :spira:109178 produce warning file ESF_SAP_RETURN_CHECKS
#[034]	19/04/2024 JYP            :spira:111359 IFRS4/EBS - Do not block Omega if BODS simulation KO
#[035]  20/08/2024 JYP            :spira:112007 activate checks for 27-11
#-----------------------------------------------------------------------------
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctftp.cmd

#[025]
# Get input parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4
ENV_SAP_PROD=$5
ENV_SAP_TST=$6

#[025] retour SAP
if [[ "${SRV}" = "PRD_TPO2" ]]
then
ENV_SAP=${ENV_SAP_PROD}
else
ENV_SAP=${ENV_SAP_TST}
fi

# Job Initialisation
JOBINIT

FICFROMONEGL=OTGL0030_FTECLEDA_MVT_${HOST_PRDSIT}_${CRE_D}
FICFROMONEGL1=OTGL0030_FTECLEDA_MVT_${HOST_PRDSIT}
FICFROMONEGLARC=${FICFROMONEGL1}

#[006]
#[012]
BALSHTMTH_NF=`echo "${BALSHTMTH_NF}" | awk '{ if (length($0) < 2) print "0" $0; else print $0;}'`
#[005]
if [ ${EST_VARIANTE} = "5" -o ${EST_VARIANTE} = "6" ]
then
	FICFROMONEGLARC=${FICFROMONEGL1}_${CLODAT_D}_${BALSHTYEA_NF}${BALSHTMTH_NF}_${CRE_D}_${EST_VARIANTE}
fi

ECHO_LOG "#========================================================================="
ECHO_LOG "-> CRE_D ..................: ${CRE_D}"
ECHO_LOG "-> CLODAT_D ...............: ${CLODAT_D}"
ECHO_LOG "-> TYPEINV  ...............: ${TYPEINV}"
ECHO_LOG "-> BALSHTYEA_NF ...........: ${BALSHTYEA_NF}"
ECHO_LOG "-> BALSHTMTH_NF ...........: ${BALSHTMTH_NF}"
ECHO_LOG "-> EST_VARIANTE ...........: ${EST_VARIANTE}"
ECHO_LOG "-> FICFROMONEGL ...........: ${FICFROMONEGL}"
ECHO_LOG "-> FICFROMONEGL1 ..........: ${FICFROMONEGL1}"
ECHO_LOG "-> FICFROMONEGLARC ........: ${FICFROMONEGLARC}"
ECHO_LOG "-> SITE_ONEGL .............: ${SITE_ONEGL}"
ECHO_LOG "-> RUNNING_ON_SERVER ..........: ${SRV}"
ECHO_LOG "-> SAP Interface (0=NO/1=YES) .: ${ENV_SAP}"
ECHO_LOG "-> SAP IN .....................: ${SAP_IN}"
ECHO_LOG "-> PARM_IS_COMPTA        ......: ${PARM_IS_COMPTA}"
ECHO_LOG "-> PARAM_IS_SAP_POSTING  ......: ${PARAM_IS_SAP_POSTING}"
ECHO_LOG "#========================================================================="



NSTEP=${NJOB}_00
#-----------------------------------------------------------------
LIBEL="initialize file ESF_SAP_RETURN_CHECKS=${ESF_SAP_RETURN_CHECKS}"
EXECKSH_MODE=P
EXECKSH "> $ESF_SAP_RETURN_CHECKS "



#[016] [020] [021] [022]
if [ -s ${DFILT}/${ENV_PREFIX}_ESID3860_FTECLEDA_SAP_MVT.dat ]
then

	# Fichier d�j� extrait mais rejet� pour cause d'erreurs detect�es, ici on force le traitement
	NSTEP=${NJOB}_01
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="mv ${DFILT}/${ENV_PREFIX}_ESID3860_FTECLEDA_SAP_MVT.dat ${EST_FTECLEDA_MVT}"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${ENV_PREFIX}_ESID3860_FTECLEDA_SAP_MVT.dat ${EST_FTECLEDA_MVT}"

	NSTEP=${NJOB}_02
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_FTECLEDA_MVT} > ${DTRANSFER}/OneGL/fromsave/${ENV_PREFIX}_${FICFROMONEGL}.dat.gz"

	NSTEP=${NJOB}_03
	# ARCHIVAGE
	#----------------------------------------------------------------------------
	LIBEL="Archive last file to DARCH : ${FICFROMONEGLARC}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_FTECLEDA_MVT} > ${DARCH}/${ENV_PREFIX}_${FICFROMONEGLARC}.dat.gz"

	if [ "${ENV_SAP}" = "1" ]
	then
		NSTEP=${NJOB}_04
		# FTP - Delete FTECLEDA_MVT on OneGL server /paris/to
		# ----------------
		LIBEL="Delete FTECLEDA_MVT on OneGL server /../to"
		FTP_FILE=${ENV_PREFIX}_${FICFROMONEGL}*.zip
		FTP_I=${ENV_PREFIX}_${FICFROMONEGL}*.zip
		FTP_SITE=${SITE_ONEGL}
		FTP_WAY=MDEL2
		FTP
	fi

	#[027]
	if [ ${PARAM_IS_SAP_POSTING} = "Y" ]
	then

		NSTEP=${NJOB}_80
		# Copie Append
		#----------------------------------------------------------------------------
		LIBEL="cat ${EST_FTECLEDA_MVT} to ${EST_FTECLEDA_MVT_POSTING}"
		EXECKSH_MODE=P
		EXECKSH "cat ${EST_FTECLEDA_MVT} >> ${EST_FTECLEDA_MVT_POSTING}"

	fi
	
	JOBEND
	
fi

#--------------------------------------
# Copy fichier _MVT one gl dans $DFILT
#--------------------------------------

#[026] SAP File treatment
if [ "${ENV_SAP}" = "0" ] || [ "${PARM_IS_COMPTA}" = "N" -a "${PARAM_IS_SAP_POSTING}" = "N" ]
then

	ECHO_LOG "#================================================================================"
	ECHO_LOG "# SAP NOT Processing  OneGL on ${SRV} : SAP_I4I_ENV.prm is ${ENV_SAP}  (0=NO/1=YES) FlagsCompta=$PARM_IS_COMPTA $PARAM_IS_SAP_POSTING  "
	ECHO_LOG "# copy ${EST_FTECLEDA_MVT_PREV} to ${EST_FTECLEDA_MVT} "
	ECHO_LOG "#================================================================================"
    # copy IN to OUT
	cp -a ${EST_FTECLEDA_MVT_PREV} ${EST_FTECLEDA_MVT}	

else

	ECHO_LOG "#=========================================================================="
	ECHO_LOG "# SAP Processing  OneGL on ${SRV} : Param is ${ENV_SAP}  (0=NO/1=YES)      "
	ECHO_LOG "#=========================================================================="


	NSTEP=${NJOB}_10
	# FTP - Get FTECLEDA_MVT OneGL data from OneGL server
	# ----------------
	LIBEL="Get FTECLEDA_MVT OneGL data from OneGL server"
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


		if [ ! -f ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat ]
		then
			ECHO_LOG "#========================================================================="
			ECHO_LOG "#-> SAP test file not extracted and ENV_SAP = 1 - Stop processing"
			ECHO_LOG "#========================================================================="
			STEPEND 1
		fi


	#[007][008]
	if [ ${EST_VARIANTE} = "5" -o ${EST_VARIANTE} = "6" ] &&
	   [ ! -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat ]
	then
		ECHO_LOG "#========================================================================="
		ECHO_LOG "#-> EST_VARIANTE ...........: ${EST_VARIANTE}"
		ECHO_LOG "#======> Variante 5 or 6 and no OneGL data file -> STOP Processing <======"
		ECHO_LOG "#========================================================================="
		STEPEND 1
	fi

#fi

fi


if [ -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat ] && [ "${PARM_IS_COMPTA}" = "Y" -o "${PARAM_IS_SAP_POSTING}" = "Y" ]
then

	ONEGLFILEDAT=`ls -rt ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat | tail -1`
	ECHO_LOG "File to move: ${ONEGLFILEDAT}"
	
	NSTEP=${NJOB}_30
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="copy ${ONEGLFILEDAT} to ${DFILT}/${ENV_PREFIX}_ESID3860_FTECLEDA_SAP_MVT.dat"
	EXECKSH_MODE=P
	EXECKSH "tr -d '\r' <${ONEGLFILEDAT} > ${DFILT}/${ENV_PREFIX}_ESID3860_FTECLEDA_SAP_MVT.dat"

fi

if [ -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat ] && [ "${PARM_IS_COMPTA}" = "Y" -o "${PARAM_IS_SAP_POSTING}" = "Y" ]
then

	#[009] debut [017]
	NSTEP=${NJOB}_31
	#------------------------------------------------------------------------------
	LIBEL="Somme de controle des montants : FTECLEDA avant OneGL"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_FTECLEDA_MVT_PREV} 1024"
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
	
	#[017]
	NSTEP=${NJOB}_32
	#------------------------------------------------------------------------------
	LIBEL="Somme de controle des montants : FTECLEDA apres Onegl"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${ENV_PREFIX}_ESID3860_FTECLEDA_SAP_MVT.dat 1024"
	SORT_O="${DFILT}/${NSTEP}_${IB}_OTGLMVT.dat 1024"
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
	AWK_I=${DFILT}/${NJOB}_32_${IB}_OTGLMVT.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_OTGLMVT.dat
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
	
	#[017]
	NSTEP=${NJOB}_34
	#------------------------------------------------------------------------------
	LIBEL="Somme de controle des montants"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_31_${IB}_ESIDMVT.dat 1024"
	SORT_I2="${DFILT}/${NJOB}_33_${IB}_AWK_OTGLMVT.dat 1024"
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
/KEYS   SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF,AMT_MC,RETAMT_MC,RETINTAMT_MC
exit
EOF
	SORT

	#[014] #[015]
	NSTEP=${NJOB}_35
	# Liste differences sur montants
	#-----------------------------------------------------------------------------
	LIBEL="Liste differences sur montants"
	AWK_I=${DFILT}/${NJOB}_34_${IB}_SORT_CUMMVT.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DIFFMVT_MONTANTS.log   #[014]
	AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{
			if ( \$9 > 1 || \$9 < -1 || \$10 > 1 || \$10 < -1 || \$11 > 1 || \$11 < -1) print \$0;
		}
exit
EOF
	AWK
	
	#[015]
	NSTEP=${NJOB}_36
	# Liste differences sur signe montant retro
	#-----------------------------------------------------------------------------
	LIBEL="Liste differences sur signe montant retro"
	AWK_I=${DFILT}/${ENV_PREFIX}_ESID3860_FTECLEDA_SAP_MVT.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log   #[014]
	AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{
			if (((\$88 < 0 && \$35 > 0) || (\$88 > 0 && \$35 < 0)) && \$88 != "" && \$88 != 0) print \$0;
		}
exit
EOF
	AWK

	#[014] #[015] [016] [018] [019] [028]
	NSTEP=${NJOB}_37
	# Controle Contrats Europe et identifiant
	#-----------------------------------------------------------------------------
	LIBEL="Liste mouvements sans identifiants"
	AWK_I=${DFILT}/${ENV_PREFIX}_ESID3860_FTECLEDA_SAP_MVT.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DIFFMVT_IDENTIFIANT.log   #[014]
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
			        (\$1 == 10 && \$2 == 12 ) ||
			        (\$1 == 10 && \$2 == 15 ) ||
			        (\$1 == 10 && \$2 == 1 ) ||
			        (\$1 == 10 && \$2 == 7 ) ||
			        (\$1 == 10 && \$2 == 8 ) ||
			        (\$1 == 11 && \$2 == 1 ) ||
			        (\$1 == 4  && \$2 == 11 ) ||
			        (\$1 == 6  && \$2 == 1 ) ||
					(\$1 == 17 && \$2 == 3 ) ||
			        (\$1 == 2  && \$2 == 4 ) ||
			        (\$1 == 26 ) ||
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
	
	#[015]
	if [ -s ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log ] ||
	   [ -s ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log ] ||
	   [ -s ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log ]
	then
	
		ECHO_LOG "#========================================================================="
		ECHO_LOG "#===> Erreur rencontr�es sur le controle du Fichier MVT provenant de ONEGL"
		ECHO_LOG "#===> Arret ou Warning."
		ECHO_LOG "#========================================================================="
		
		wc -l ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log
		wc -l ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log
		wc -l ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log
		
		ECHO_LOG "complete ESF_SAP_RETURN_CHECKS files for reporting ESDC0010 "		
		    wc -l ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log            >> $ESF_SAP_RETURN_CHECKS
			cat ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log              >> $ESF_SAP_RETURN_CHECKS
		    wc -l ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log   >> $ESF_SAP_RETURN_CHECKS
			cat ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log     >> $ESF_SAP_RETURN_CHECKS
		    wc -l ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log	        >> $ESF_SAP_RETURN_CHECKS
			cat ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log	        >> $ESF_SAP_RETURN_CHECKS
		
		#[011]
		if [ ${EST_VARIANTE} = "5" -o ${EST_VARIANTE} = "6" ]
		then
			STEPEND 1
		else
			echo "WARNING" > ${DFILT}/${NSTEP}_${IB}_CTLONEGL.wng
		fi
	
	#[018]
	fi	

	NSTEP=${NJOB}_40
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="mv ${DFILT}/${ENV_PREFIX}_ESID3860_FTECLEDA_SAP_MVT.dat ${EST_FTECLEDA_MVT}"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${ENV_PREFIX}_ESID3860_FTECLEDA_SAP_MVT.dat ${EST_FTECLEDA_MVT}"

	#[009] fin

fi

if [ -s ${EST_FTECLEDA_MVT} ] &&
   [ -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.zip ] &&
   [ "${PARM_IS_COMPTA}" = "Y" -o "${PARAM_IS_SAP_POSTING}" = "Y" ]
then

	#[004]
	NSTEP=${NJOB}_50
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_FTECLEDA_MVT} > ${DTRANSFER}/OneGL/fromsave/${ENV_PREFIX}_${FICFROMONEGL}.dat.gz"
	
	#[005]
	NSTEP=${NJOB}_60
	# ARCHIVAGE
	#----------------------------------------------------------------------------
	LIBEL="Archive last file to DARCH : ${FICFROMONEGLARC}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_FTECLEDA_MVT} > ${DARCH}/${ENV_PREFIX}_${FICFROMONEGLARC}.dat.gz"
	
	NSTEP=${NJOB}_70
	# FTP - Delete FTECLEDA_MVT on OneGL server /paris/to
	# ----------------
	LIBEL="Delete FTECLEDA_MVT on OneGL server /../to"
	FTP_FILE=${ENV_PREFIX}_${FICFROMONEGL}*.zip
	FTP_I=${ENV_PREFIX}_${FICFROMONEGL}*.zip
	FTP_SITE=${SITE_ONEGL}
	FTP_WAY=MDEL2
	FTP

fi

if [ ${PARAM_IS_SAP_POSTING} = "Y" ]
then

	NSTEP=${NJOB}_80
	# Copie Append
	#----------------------------------------------------------------------------
	LIBEL="cat ${EST_FTECLEDA_MVT} to ${EST_FTECLEDA_MVT_POSTING}"
	EXECKSH_MODE=P
	EXECKSH "cat ${EST_FTECLEDA_MVT} >> ${EST_FTECLEDA_MVT_POSTING}"

fi

NSTEP=${NJOB}_100
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
