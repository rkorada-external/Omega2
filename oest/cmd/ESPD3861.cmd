#!/bin/ksh
#=============================================================================
# nom de l'application     : ESTIMATIONS - preparation des fichiers pour one GL
# nom du script SHELL      : ESPD3861.cmd
# date de creation         : 15/03/2011
# auteur                   : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:              
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#[001]  05/05/2011  R. CASSIS     :spot:21408 - Modification OneGL
#[002]  26/08/2011  R. CASSIS     :spot:22435 Parametrage pour Reception du fichier sur le serveur ONEGL.
#[003]  14/10/2011  R. CASSIS     :spot:22752 Nomage du fichier FTECLEDA_MVT provenant de OTGL0010 en OTGL0010
#[004]  30/11/2011  Roger Cassis  :spot:22859 Gestion transfert ONEGL et sauvegardes et archives.
#[005]  06/02/2012  Roger Cassis  :spot:23329 Archivage du fichier OneGL avec date creation.
#[006]  19/03/2012  Roger Cassis  :spot:23567 Gestion noms de fichiers et dates bilans
#[007]  03/05/2012  Roger Cassis  :spot:23699 Si le fichier flag du ESPD3850 absent on genere un Abend
#[008]  25/07/2012  Roger Cassis  :spot:23802 Si NY pas de message d'erreur sur OneGLL
#[009]  21/03/2013  Roger Cassis  :spot:25006 Suppression condition sur USA1 
#[010]  19/06/2013  Roger Cassis  :spot:25305 Ajout controles sur le fichier ONEGL
#[011]  25/07/2013  Paul Coppin   :spot:25405 Ajout controles sur le fichier ONEGL filiales 14, 25 et 26.
#[012]  18/09/2013  Roger Cassis  :spot:25521 Correction sur nom de fichier sauvegard� et archiv�
#[013]  08/01/2014  Roger Cassis  :spot:26048 Warning si controles Onegl pas ok en mode simu au lieu d'abort
#[014]  20/03/2014  Roger Cassis  :spot:26481 Si fichier onegl pas trouv� et compta post-social, on plante
#[015]  18/06/2014  Roger Cassis  :spot:25427 Omega 1b - Modif nawk en awk et correction syntaxe commandes
#[016]  02/02/2015  Roger Cassis  :spot:28191 Reactivate data controls for life subsidiarys
#[017]  05/11/2015  Roger Cassis  :spot:29635 Les fichiers d'ano sont appel�s .log au lieu de .dat pour consultation ult�rieure
#[018]  16/02/2016  Roger Cassis  :spot:30154 Ajoute ssd 5 / etab 10 dans les exeptions de contr�le
#[019]  13/06/2016  Roger Cassis  :spot:30733 Si mode Simu et erreurs rencontrees, on copie quand m�me le fichier _MVT dans DFILP.
#                                             On ajoute les postes %E et %C dans les omissions des contr�les
#[020]  29/07/2016  Roger Cassis  :spot:30999 Pas de controle d'identifiants sur filiale 27 et 26:7-9-10
#[021]  14/12/2017  Roger Cassis  :spira:66593 Automatisation de la reprise du traitement du fichier ONEGL par param�trage au lancement de la chaine.
#[022]  19/07/2019  Roger Cassis  :spira:80028 Suppression de la gestion de flags obsolete avec parametre Force et du test du site FRAM.
#[023]  26/06/2021  Mehdi NAJI	  :Spira 95833 retirer la condition EST_ESPD3860_COND1
#[024]  20/01/2022  Roger Cassis  :spira:96729 Add extract file managing for Test servers
#[025]  03/02/2022 T. DEUTSCH   : spira:100097 Add prm option to take SAP file
#[026]  24/02/2022  Roger Cassis  :spira:96729 commande gzip pas dans EXECKSH
#[027]  06/10/2022	JBD						:spira 104929 rename ESPD3800_FTECLEDASO_MVT for Perm into ->${EPO_FTECLEDA_MVT_PREV} and Temp into -> _ESPD3860_FTECLEDASO_SAP_MVT
#[028]  01/04/2022  JYP/TD        :spira:103544 - DELTA posting new mode  
#[029]  14/09/2022 DAD            :spira:103544 Add update of the POSTING file when restarting the job
#[030]  12/05/2022 J.B-D          :spira:107645 remove from check if trncod = dlbtrncod
#[031]	13/01/2023 MiS            :spira:108408 Modifications des fichiers OTGL0010 remplacess par OTGL0030
#[032]	09/03/2023 JYP/TD         :spira:109153 do NOT check some SSD/ESB
#[033]	31/03/2023 JYP/TD         :spira:109178 produce warning file ESF_SAP_RETURN_CHECKS
#[034]	09/05/2023 JYP/TD         :spira:109721 when SAP return file is empty, touch POSI file in perm directory 
#[035]	19/04/2024 JYP            :spira:111359 IFRS4/EBS - Do not block Omega if BODS simulation KO
#[036]	30/07/2024 JYP            :spira:111359 IFRS4/EBS - Do not block Omega if BODS simulation KO
#[035]  20/08/2024 JYP            :spira:112007 activate checks for 27-11
#-----------------------------------------------------------------------------
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctftp.cmd

#[006][025]
# Get input parameters
CRE_D=$1
CONSOYEA=$2
CONSOMTH=$3
INVCONSO_D=$4
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

#[031]
FICFROMONEGL=OTGL0030_FTECLEDASO_MVT_${HOST_PRDSIT}_${CRE_D}
FICFROMONEGL1=OTGL0030_FTECLEDASO_MVT_${HOST_PRDSIT}
FICFROMONEGLARC=${FICFROMONEGL1}

#[006] [015]
CONSOMTH=`echo "${CONSOMTH}" | awk '{ if (length($0) < 2) print "0" $0; else print $0;}'`
#[010]
FICFROMONEGLARC=${FICFROMONEGL1}_${INVCONSO_D}_${CONSOYEA}${CONSOMTH}_${CRE_D}

ECHO_LOG "#========================================================================="
ECHO_LOG "-> CRE_D ..................: ${CRE_D}"
ECHO_LOG "-> INVCONSO_D .............: ${INVCONSO_D}"
ECHO_LOG "-> CONSOYEA ...............: ${CONSOYEA}"
ECHO_LOG "-> CONSOMTH ...............: ${CONSOMTH}"
ECHO_LOG "-> EST_ESPD3860_COND1 .....: ${EST_ESPD3860_COND1}"
ECHO_LOG "-> FICFROMONEGL ...........: ${FICFROMONEGL}"
ECHO_LOG "-> FICFROMONEGL1 ..........: ${FICFROMONEGL1}"
ECHO_LOG "-> FICFROMONEGLARC ........: ${FICFROMONEGLARC}"
ECHO_LOG "-> SITE_ONEGL .............: ${SITE_ONEGL}"
ECHO_LOG "-> RUNNING_ON_SERVER ..........: ${SRV}"
ECHO_LOG "-> SAP Interface (0=NO/1=YES) .: ${ENV_SAP}"
ECHO_LOG "-> PARM_IS_COMPTA        ......: ${PARM_IS_COMPTA}"
ECHO_LOG "-> PARAM_IS_SAP_POSTING  ......: ${PARAM_IS_SAP_POSTING}"
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_00
#-----------------------------------------------------------------
LIBEL="initialize file ESF_SAP_RETURN_CHECKS=${ESF_SAP_RETURN_CHECKS}"
EXECKSH_MODE=P
EXECKSH "> $ESF_SAP_RETURN_CHECKS "



#[021] [022]
if [ -s ${DFILT}/${ENV_PREFIX}_ESPD3860_FTECLEDASO_SAP_MVT.dat ]
then

	# Fichier d�j� extrait mais rejet� pour cause d'erreurs detect�es, ici on force le traitement
	NSTEP=${NJOB}_01
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="mv ${DFILT}/${ENV_PREFIX}_ESPD3860_FTECLEDASO_SAP_MVT.dat ${EPO_FTECLEDASO_MVT}"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${ENV_PREFIX}_ESPD3860_FTECLEDASO_SAP_MVT.dat ${EPO_FTECLEDASO_MVT}"

	NSTEP=${NJOB}_02
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EPO_FTECLEDASO_MVT} > ${DTRANSFER}/OneGL/fromsave/${ENV_PREFIX}_${FICFROMONEGL}.dat.gz"

	NSTEP=${NJOB}_03
	# ARCHIVAGE
	#----------------------------------------------------------------------------
	LIBEL="Archive last file to DARCH : ${FICFROMONEGLARC}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EPO_FTECLEDASO_MVT} > ${DARCH}/${ENV_PREFIX}_${FICFROMONEGLARC}.dat.gz"

	if [ "${ENV_SAP}" = "1" ]
	then

		NSTEP=${NJOB}_04
		# FTP - Delete FTECLEDASO_MVT on OneGL server /paris/to
		# ----------------
		LIBEL="Delete FTECLEDASO_MVT on OneGL server /../to"
		FTP_FILE=${ENV_PREFIX}_${FICFROMONEGL}*.zip
		FTP_I=${ENV_PREFIX}_${FICFROMONEGL}*.zip
		FTP_SITE=${SITE_ONEGL}
		FTP_WAY=MDEL2
		FTP
	
	fi

	#[028] [029]
	touch ${EPO_FTECLEDA_CUR}

	if [ ${PARAM_IS_SAP_POSTING} = "Y" ]
	then

		NSTEP=${NJOB}_80
		# Copie Append
		#----------------------------------------------------------------------------
		LIBEL="cat ${EPO_FTECLEDASO_MVT} to ${EPO_FTECLEDASO_MVT_POSTING} and ${EPO_FTECLEDASO_CUR}"
		EXECKSH_MODE=P
		#[026]	EXECKSH "cat ${EPO_FTECLEDASO_MVT} >> ${EPO_FTECLEDASO_MVT_POSTING}"
		cat ${EPO_FTECLEDASO_MVT} >> ${EPO_FTECLEDASO_MVT_POSTING}
		#[028]
		cat ${EPO_FTECLEDASO_MVT} >> ${EPO_FTECLEDA_CUR}
		
	fi

	JOBEND
	
fi

#--------------------------------------
# Copy fichier _MVT one gl dans $DFILT
#--------------------------------------

#[025] SAP File treatment
if [ "${ENV_SAP}" = "0" ] || [ "${PARM_IS_COMPTA}" = "N" -a "${PARAM_IS_SAP_POSTING}" = "N" ]
then

	ECHO_LOG "#================================================================================"
	ECHO_LOG "# SAP NOT Processing OneGL on ${SRV} : SAP_I4I_ENV.prm is ${ENV_SAP} (0=NO/1=YES) FlagsCompta=$PARM_IS_COMPTA $PARAM_IS_SAP_POSTING "
	ECHO_LOG "# copy ${EPO_FTECLEDA_MVT_PREV} to ${EPO_FTECLEDASO_MVT} "
	ECHO_LOG "#================================================================================"
    # copy IN to OUT
	cp -a ${EPO_FTECLEDA_MVT_PREV} ${EPO_FTECLEDASO_MVT}	

else

	ECHO_LOG "#=========================================================================="
	ECHO_LOG "# SAP Processing  OneGL on ${SRV} : Param is ${ENV_SAP}  (0=NO/1=YES)      "
	ECHO_LOG "#=========================================================================="



	NSTEP=${NJOB}_10
	# FTP - Get FTECLEDASO_MVT OneGL data from OneGL server
	# ----------------
	LIBEL="Get FTECLEDASO_MVT OneGL data from OneGL server"
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

	if   [ ! -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat ] && [ -s ${EPO_FTECLEDA_MVT_PREV} ]
	then
		ECHO_LOG "#==============================================================="
		ECHO_LOG "#======> No OneGL data file received for Post-Social accounting -> STOP Processing <======="
		ECHO_LOG "#==============================================================="
		STEPEND 1	
	fi

fi

if [ -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat ] && [ "${PARM_IS_COMPTA}" = "Y" -o "${PARAM_IS_SAP_POSTING}" = "Y" ]
then

	ONEGLFILEDAT=`ls -rt ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat | tail -1`
	ECHO_LOG "File to move: ${ONEGLFILEDAT}"	

	NSTEP=${NJOB}_30
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="copy ${ONEGLFILEDAT} to ${DFILT}/${ENV_PREFIX}_ESPD3860_FTECLEDASO_SAP_MVT.dat"
	EXECKSH_MODE=P
	EXECKSH "tr -d '\r' <${ONEGLFILEDAT} > ${DFILT}/${ENV_PREFIX}_ESPD3860_FTECLEDASO_SAP_MVT.dat"

fi

if [ -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.dat ] && [ "${PARM_IS_COMPTA}" = "Y" -o "${PARAM_IS_SAP_POSTING}" = "Y" ]
then

	#[010] debut
	NSTEP=${NJOB}_31
	#------------------------------------------------------------------------------
	LIBEL="Somme de controle des montants : FTECLEDA avant OneGL"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EPO_FTECLEDA_MVT_PREV} 1024"
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
	SORT_I="${DFILT}/${ENV_PREFIX}_ESPD3860_FTECLEDASO_SAP_MVT.dat 1024"
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
	AWK_I=${DFILT}/${ENV_PREFIX}_ESPD3860_FTECLEDASO_SAP_MVT.dat
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

	#[016] #[017] [019] [020] [030]
	NSTEP=${NJOB}_37
	# Controle Contrats Europe et identifiant
	#-----------------------------------------------------------------------------
	LIBEL="Liste mouvements sans identifiants"
	AWK_I=${DFILT}/${ENV_PREFIX}_ESPD3860_FTECLEDASO_SAP_MVT.dat
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
		
		ECHO_LOG "complete ESF_SAP_RETURN_CHECKS files for reporting ESDC0010 "		
		    wc -l ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log            >> $ESF_SAP_RETURN_CHECKS
			cat ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log              >> $ESF_SAP_RETURN_CHECKS
		    wc -l ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log   >> $ESF_SAP_RETURN_CHECKS
			cat ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log     >> $ESF_SAP_RETURN_CHECKS
		    wc -l ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log	        >> $ESF_SAP_RETURN_CHECKS
			cat ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log	        >> $ESF_SAP_RETURN_CHECKS
		
		
		#[013]
		if [ ${EST_VARIANTE} = "5" -o ${EST_VARIANTE} = "6" ]
		then
			STEPEND 1
		else
		#[015]
			echo "WARNING" > ${DFILT}/${NSTEP}_${IB}_CTLONEGL.wng
		fi

	#[019]
	fi	

	NSTEP=${NJOB}_40
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="mv ${DFILT}/${ENV_PREFIX}_ESPD3860_FTECLEDASO_SAP_MVT.dat ${EPO_FTECLEDASO_MVT}"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${ENV_PREFIX}_ESPD3860_FTECLEDASO_SAP_MVT.dat ${EPO_FTECLEDASO_MVT}"

	#[010] fin

else 
	NSTEP=${NJOB}_45
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="touch file EPO_FTECLEDASO_MVT=${EPO_FTECLEDASO_MVT}"
	EXECKSH_MODE=P
	EXECKSH "touch ${EPO_FTECLEDASO_MVT}"

fi


if [ -s ${EPO_FTECLEDASO_MVT} ] &&
   [ -s ${DFILT}/${ENV_PREFIX}_${FICFROMONEGL}*.zip ] && 
   [ "${PARM_IS_COMPTA}" = "Y" -o "${PARAM_IS_SAP_POSTING}" = "Y" ]
then

	NSTEP=${NJOB}_50
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EPO_FTECLEDASO_MVT} > ${DTRANSFER}/OneGL/fromsave/${ENV_PREFIX}_${FICFROMONEGL}.dat.gz"

	#[005] [006]
	NSTEP=${NJOB}_60
	# ARCHIVAGE
	#----------------------------------------------------------------------------
	LIBEL="Archive last file to DARCH : ${FICFROMONEGLARC}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EPO_FTECLEDASO_MVT} > ${DARCH}/${ENV_PREFIX}_${FICFROMONEGLARC}.dat.gz"

	NSTEP=${NJOB}_70
	# FTP - Delete FTECLEDASO_MVT on OneGL server /paris/to
	# ----------------
	LIBEL="Delete FTECLEDASO_MVT on OneGL server /../to"
	FTP_FILE=${ENV_PREFIX}_${FICFROMONEGL}*.zip
	FTP_I=${ENV_PREFIX}_${FICFROMONEGL}*.zip
	FTP_SITE=${SITE_ONEGL}
	FTP_WAY=MDEL2
	FTP
else 
		ECHO_LOG "PARM_IS_COMPTA=$PARM_IS_COMPTA PARAM_IS_SAP_POSTING=$PARAM_IS_SAP_POSTING => FTPfile not managed by this job "
fi


	touch ${EPO_FTECLEDA_CUR}

if [ ${PARAM_IS_SAP_POSTING} = "Y" ]
then

	NSTEP=${NJOB}_80
	# Copie Append
	#----------------------------------------------------------------------------
	LIBEL="cat ${EPO_FTECLEDASO_MVT} to ${EPO_FTECLEDASO_MVT_POSTING} and ${EPO_FTECLEDASO_CUR}"
	EXECKSH_MODE=P
#[026]	EXECKSH "cat ${EPO_FTECLEDASO_MVT} >> ${EPO_FTECLEDASO_MVT_POSTING}"
	cat ${EPO_FTECLEDASO_MVT} >> ${EPO_FTECLEDASO_MVT_POSTING}
#[028]
	cat ${EPO_FTECLEDASO_MVT} >> ${EPO_FTECLEDA_CUR}
	
fi

NSTEP=${NJOB}_100
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

