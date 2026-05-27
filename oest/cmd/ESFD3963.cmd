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
#[003]  14/10/2011  R. CASSIS     :spot:22752 Nomage du fichier FTECLEDA_MVT provenant de OTGL0030 en OTGL0030
#[004]  30/11/2011  Roger Cassis  :spot:22859 Gestion transfert ONEGL et sauvegardes et archives.
#[005]  06/02/2012  Roger Cassis  :spot:23329 Archivage du fichier OneGL avec date creation.
#[006]  19/03/2012  Roger Cassis  :spot:23567 Gestion noms de fichiers et dates bilans
#[007]  03/05/2012  Roger Cassis  :spot:23699 Si le fichier flag du ESPD3850 absent on genere un Abend
#[008]  25/07/2012  Roger Cassis  :spot:23802 Si NY pas de message d'erreur sur OneGLL
#[009]  21/03/2013  Roger Cassis  :spot:25006 Suppression condition sur USA1 
#[010]  19/06/2013  Roger Cassis  :spot:25305 Ajout controles sur le fichier ONEGL
#[011]  25/07/2013  Paul Coppin   :spot:25405 Ajout controles sur le fichier ONEGL filiales 14, 25 et 26.
#[012]  18/09/2013  Roger Cassis  :spot:25521 Correction sur nom de fichier sauvegardé et archivé
#[013]  08/01/2014  Roger Cassis  :spot:26048 Warning si controles Onegl pas ok en mode simu au lieu d'abort
#[014]  20/03/2014  Roger Cassis  :spot:26481 Si fichier onegl pas trouvé et compta post-social, on plante
#[015]  18/06/2014  Roger Cassis  :spot:25427 Omega 1b - Modif nawk en awk et correction syntaxe commandes
#[016]  02/02/2015  Roger Cassis  :spot:28191 Reactivate data controls for life subsidiarys
#[017]  05/11/2015  Roger Cassis  :spot:29635 Les fichiers d'ano sont appelés .log au lieu de .dat pour consultation ultérieure
#[018]  16/02/2016  Roger Cassis  :spot:30154 Ajoute ssd 5 / etab 10 dans les exeptions de contrôle
#[019]  13/06/2016  Roger Cassis  :spot:30733 Si mode Simu et erreurs rencontrees, on copie quand même le fichier _MVT dans DFILP.
#                                             On ajoute les postes %E et %C dans les omissions des contrôles
#[020]  29/07/2016  Roger Cassis  :spot:30999 Pas de controle d'identifiants sur filiale 27 et 26:7-9-10
#[021]  14/12/2017  Roger Cassis  :spira:66593 Automatisation de la reprise du traitement du fichier ONEGL par paramétrage au lancement de la chaine.
#[022]  19/07/2019  Roger Cassis  :spira:80028 Suppression de la gestion de flags obsolete avec parametre Force et du test du site FRAM.
#[023]  22/09/2020 Linh DOAN	: spira 88368 Adapte pour IFRS17
#[024]  26/07/2021 Linh DOAN    : spira 96041 : IFRS17 Delta Posting (ESFD3960 for IFRS17 logic)
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctftp.cmd


#set -x

#[006]
# Get input parameters


#retour SAP

# Job Initialisation
JOBINIT


ECHO_LOG "#========================================================================="
ECHO_LOG "-> CRE_D ..................: ${PARM_CRE_D}"
ECHO_LOG "-> INVCONSO_D .............: ${PARM_INVCONSO_D}"
ECHO_LOG "-> CONSOYEA ...............: ${PARM_CONSOYEA}"
ECHO_LOG "-> CONSOMTH ...............: ${PARM_CONSOMTH}"
ECHO_LOG "-> ESF_FICFROMONEGL ...........: ${ESF_FICFROMONEGL}"
ECHO_LOG "-> ESF_FICFROMONEGL1 ..........: ${ESF_FICFROMONEGL1}"
ECHO_LOG "-> ESF_FICFROMONEGLARC ........: ${ESF_FICFROMONEGLARC}"
ECHO_LOG "-> SITE_ONEGL .............: ${SITE_ONEGL}"
ECHO_LOG "#========================================================================="

EST_FTECLEDA_MVT=`basename "${ESF_FTECLEDA_MVT}"`

NSTEP=${NJOB}_01
#------------------------------------------------------------------------------------
LIBEL="MANAGE UNFOUND FILES "



if [ ! -f ${ESF_FTECLEDA_POSTING} ]
then
        ECHO_LOG "ESF_FTECLEDA_POSTING=${ESF_FTECLEDA_POSTING}  does not exist, take an empty file"     >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDA_POSTING}"
fi




#[021] [022]
if [ -s ${DFILT}/${EST_FTECLEDA_MVT} ]
then

	# Fichier déjà extrait mais rejeté pour cause d'erreurs detectées, ici on force le traitement
	NSTEP=${NJOB}_01
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="mv ${DFILT}/${EST_FTECLEDA_MVT} ${ESF_FTECLEDA_MVT}"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${EST_FTECLEDA_MVT} ${ESF_FTECLEDA_MVT}"

	NSTEP=${NJOB}_02
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DTRANSFER}/OneGL/fromsave/${ENV_PREFIX}_${ESF_FICFROMONEGL}.dat.gz"

	NSTEP=${NJOB}_03
	# ARCHIVAGE
	#----------------------------------------------------------------------------
	LIBEL="Archive last file to DARCH : ${ESF_FICFROMONEGLARC}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DARCH}/${ENV_PREFIX}_${ESF_FICFROMONEGLARC}.dat.gz"

	NSTEP=${NJOB}_04
	# FTP - Delete FTECLEDA_MVT on OneGL server /paris/to
	# ----------------
	LIBEL="Delete FTECLEDASO_MVT on OneGL server /../to"
	FTP_FILE=${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip
	FTP_I=${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip
	FTP_SITE=${SITE_ONEGL}
	FTP_WAY=MDEL2
	FTP

	#[012]
if [ -s ${ESF_FTECLEDA_MVT} ] 
   #[ -s ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip ]
then

	#[004]
	NSTEP=${NJOB}_50
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DTRANSFER}/OneGL/fromsave/${ENV_PREFIX}_${ESF_FICFROMONEGL}.dat.gz"

	#[005] [006]
	NSTEP=${NJOB}_60
	# ARCHIVAGE
	#----------------------------------------------------------------------------
	LIBEL="Archive last file to DARCH : ${ESF_FICFROMONEGLARC}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DARCH}/${ENV_PREFIX}_${ESF_FICFROMONEGLARC}.dat.gz"

	NSTEP=${NJOB}_70
	# FTP - Delete FTECLEDASO_MVT on OneGL server /paris/to
	# ----------------
	LIBEL="Delete FTECLEDASO_MVT on OneGL server /../to"
	FTP_FILE=${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip
	FTP_I=${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip
	FTP_SITE=${SITE_ONEGL}
	FTP_WAY=MDEL2
	FTP

	

	#update RA
	NSTEP=${NJOB}_80
LIBEL="Merge POSTING + MVT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_MVT} 2000 1"
SORT_I2="${ESF_FTECLEDA_POSTING} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_RA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_90
# summarize TTECLEDA by BALSHTDAY
#--------------------------------
LIBEL="Summarize TTECLEDA by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_FTECLEDA_RA.dat 2000 1"
SORT_O="${ESF_FTECLEDA_RA} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	DBLTRNCOD_CF      7:1 -   7:,
	CTR_NF            8:1 -   8:,
	END_NT            9:1 -   9:,
	SEC_NF           10:1 -  10:,
	UWY_NF           11:1 -  11:,
	UW_NT            12:1 -  12:,
	OCCYEA_NF        13:1 -  13:EN,
	ACY_NF           14:1 -  14:EN,
	SCOSTRMTH_NF     15:1 -  15:EN,
	SCOENDMTH_NF     16:1 -  16:EN,
	CUR_CF           18:1 -  18:,
	AMT_M            19:1 -  19:EN 18/3,
	CED_NF           20:1 -  20:,
	RETCTR_NF        24:1 -  24:,
	RETEND_NT        25:1 -  25:,
	RETSEC_NF        26:1 -  26:,
	RTY_NF           27:1 -  27:,
	RETUW_NT         28:1 -  28:,
	RETOCCYEA_NF     29:1 -  29:EN,
	RETACY_NF        30:1 -  30:EN,
	RETSCOSTRMTH_NF  31:1 -  31:EN,
	RETSCOENDMTH_NF  32:1 -  32:EN,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 18/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
  	CRE_D            41:1 -  41:,
	RETINTAMT_M      88:1 -  88:EN 18/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:,
	GAAPCOD_NF      111:1 - 111:,
	I17PRDCOD_CT    112:1 - 112:

/KEYS
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	OCCYEA_NF,
	ACY_NF,
	SCOSTRMTH_NF,
	SCOENDMTH_NF,
	CUR_CF,
	CED_NF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF,
	RETCUR_CF,
	PLC_NT,
	RTO_NF,
	CRE_D,
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B,
	GAAPCOD_NF,
	I17PRDCOD_CT
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT


# BOOKING
#PARM_IS_SAP_POSTING=Y

	if [ "${PARM_IS_SAP_POSTING}" = "Y" ]
	then
                # archive

                #[005] [006]
                NSTEP=${NJOB}_100
                # ARCHIVAGE
                #----------------------------------------------------------------------------
                LIBEL="Archive last Posting file to DARCH : ${ESF_FTECLEDA_POSTING_ARC_AVANT}"
                EXECKSH_MODE=P
                EXECKSH "gzip -c ${ESF_FTECLEDA_POSTING} > ${DARCH}/${ESF_FTECLEDA_POSTING_ARC_AVANT}.dat.gz"

		
		
                #[005] [006]
                NSTEP=${NJOB}_110
                # ARCHIVAGE
                #----------------------------------------------------------------------------
                LIBEL="cp ${ESF_FTECLEDA_RA} ${ESF_FTECLEDA_POSTING}"
                EXECKSH_MODE=P
                EXECKSH "cp ${ESF_FTECLEDA_RA} ${ESF_FTECLEDA_POSTING}"

		
                #[005] [006]
                NSTEP=${NJOB}_120
                # ARCHIVAGE
                #----------------------------------------------------------------------------
                LIBEL="Archive last Posting file to DARCH : ${ESF_FTECLEDA_POSTING_ARC_APRES}"
                EXECKSH_MODE=P
                EXECKSH "gzip -c ${ESF_FTECLEDA_POSTING} > ${DARCH}/${ESF_FTECLEDA_POSTING_ARC_APRES}.dat.gz"
		fi
	fi
		
	JOBEND
	
fi

#--------------------------------------
# Copy fichier _MVT one gl dans $DFILT
#--------------------------------------

SAP_IN="0"

NSTEP=${NJOB}_10
# FTP - Get FTECLEDA_MVT OneGL data from OneGL server
# ----------------
LIBEL="Get FTECLEDA_MVT OneGL data from OneGL server ${SITE_ONEGL}"
FTP_FILE=${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip
FTP_SITE=${SITE_ONEGL}
FTP_MODE=binary
FTP_WAY=MGET
FTP

if [ -s ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip ]
then

	ONEGLFILEZIP=`ls -rt ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip | tail -1`
	SAP_IN="1"

	echo "File to unzip: ${ONEGLFILEZIP}"	
	NSTEP=${NJOB}_20
	LIBEL="UNZIP Cessions File"
	#-----------------------------------------------------------------
	ZIP_ODIR=${DFILT}
	ZIP_I=${ONEGLFILEZIP}
	ZIP_OPT=""
	PKUNZIP
fi

echo "SAP_IN = ${SAP_IN}"

ls -l ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.dat


if [ ! -s ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.dat ] &&
   [ "${SAP_IN}" = "0" ]
then

	if [[ "${SRV}" =~ (DEV|ITK|CNV)_TPO2 ]]; then
        # copy IN to OUT
		cp -a ${ESF_FTECLEDA_MVT_PREV} ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}_$(date +'%Y%m%d').dat	
	else
	ECHO_LOG "#==============================================================="
	ECHO_LOG "#======> No OneGL data file received for Post-Social accounting -> STOP Processing <======="
	ECHO_LOG "#==============================================================="
		
	STEPEND 1	
	fi
fi

if [ -s ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.dat ]
then

	ONEGLFILEDAT=`ls -rt ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.dat | tail -1`
	ECHO_LOG "File to move: ${ONEGLFILEDAT}"	

	NSTEP=${NJOB}_30
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="copy ${ONEGLFILEDAT} to ${ESF_FTECLEDA_MVT}"
	EXECKSH_MODE=P
	EXECKSH "tr -d '\r' <${ONEGLFILEDAT} > ${DFILT}/${EST_FTECLEDA_MVT}"

	#[010] debut
	NSTEP=${NJOB}_31
	#------------------------------------------------------------------------------
	LIBEL="Somme de controle des montants : FTECLEDA avant OneGL"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${ESF_FTECLEDA_MVT_PREV} 1024"
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
	KEY_CF         101:1 - 101:,
	GAAPCOD_NF      111:1 - 111:,
	I17PRDCOD_CT	112:1 - 112:
	
/KEYS	SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF, GAAPCOD_NF, I17PRDCOD_CT
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF,GAAPCOD_NF,I17PRDCOD_CT,AMT_MC,RETAMT_MC,RETINTAMT_MC
exit
EOF
	SORT

	NSTEP=${NJOB}_32
	#------------------------------------------------------------------------------
	LIBEL="Somme de controle des montants : FTECLEDA apres Onegl"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${EST_FTECLEDA_MVT} 1024"
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
	KEY_CF         101:1 - 101:,
	GAAPCOD_NF      111:1 - 111:,
        I17PRDCOD_CT    112:1 - 112:
	
/KEYS	SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF,GAAPCOD_NF,I17PRDCOD_CT,AMT_MC,RETAMT_MC,RETINTAMT_MC
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
			if (\$11  != 0) \$11   = sprintf("%-.3lf",-\$11 );
			if (\$12  != 0) \$12  = sprintf("%-.3lf",-\$12);
			if (\$13  != 0) \$13  = sprintf("%-.3lf",-\$13);
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
	GAAPCOD_NF       9:1 -   9:,
        I17PRDCOD_CT    10:1 -  10:,
	AMT_M           11:1 -  11:EN 18/3,
	RETAMT_M        12:1 -  12:EN 18/3,
	RETINTAMT_M     13:1 -  13:EN 18/3
/KEYS	SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF,GAAPCOD_NF,I17PRDCOD_CT
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF,GAAPCOD_NF,I17PRDCOD_CT,AMT_MC,RETAMT_MC,RETINTAMT_MC
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
		if ( \$11 > 1 || \$11 < -1 || \$12 > 1 || \$12 < -1 || \$13 > 1 || \$13 < -1) print \$0;
	}
exit
EOF
	AWK

	#[017]
	NSTEP=${NJOB}_36
	# Liste differences sur signe montant retro
	#-----------------------------------------------------------------------------
	LIBEL="Liste differences sur signe montant retro"
	AWK_I=${DFILT}/${EST_FTECLEDA_MVT}
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

	#[016] #[017] [019] [020]
	NSTEP=${NJOB}_37
	# Controle Contrats Europe et identifiant
	#-----------------------------------------------------------------------------
	LIBEL="Liste mouvements sans identifiants"
	AWK_I=${DFILT}/${EST_FTECLEDA_MVT}
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
			        (\$1 == 27 ) ) )
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
		ECHO_LOG "#===> Erreurs rencontrées dans le controle du Fichier MVT provenant de ONEGL"
		ECHO_LOG "#===> Arret ou Warning."
		ECHO_LOG "#==========================================================================="
		wc -l ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log
		wc -l ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log
		wc -l ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log
		#[013]
		if [ "${PARM_IS_SAP_POSTING}" = "Y" ]
		then
			ECHO_LOG "#==========================================================================="
			ECHO_LOG "# DELTA BOOKING, we should stop all "
			ECHO_LOG "#==========================================================================="
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
	LIBEL="mv ${DFILT}/${EST_FTECLEDA_MVT} ${ESF_FTECLEDA_MVT}"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${EST_FTECLEDA_MVT} ${ESF_FTECLEDA_MVT}"

	#[010] fin

fi

#[012]
if [ -s ${ESF_FTECLEDA_MVT} ] &&
	[ "${SAP_IN}" = "1" ]
   #[ -s ${DFILT}/${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip ]
then

	#[004]
	NSTEP=${NJOB}_50
	# Copy to Tosave
	#----------------------------------------------------------------------------
	LIBEL="Copy MVT file to tosave"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DTRANSFER}/OneGL/fromsave/${ENV_PREFIX}_${ESF_FICFROMONEGL}.dat.gz"

	#[005] [006]
	NSTEP=${NJOB}_60
	# ARCHIVAGE
	#----------------------------------------------------------------------------
	LIBEL="Archive last file to DARCH : ${ESF_FICFROMONEGLARC}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${ESF_FTECLEDA_MVT} > ${DARCH}/${ENV_PREFIX}_${ESF_FICFROMONEGLARC}.dat.gz"

	NSTEP=${NJOB}_70
	# FTP - Delete FTECLEDASO_MVT on OneGL server /paris/to
	# ----------------
	LIBEL="Delete FTECLEDASO_MVT on OneGL server /../to"
	FTP_FILE=${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip
	FTP_I=${ENV_PREFIX}_${ESF_FICFROMONEGL}*.zip
	FTP_SITE=${SITE_ONEGL}
	FTP_WAY=MDEL2
	FTP

	

	#update RA
	NSTEP=${NJOB}_80
LIBEL="Merge POSTING + MVT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_MVT} 2000 1"
SORT_I2="${ESF_FTECLEDA_POSTING} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_RA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_90
# summarize TTECLEDA by BALSHTDAY
#--------------------------------
LIBEL="Summarize TTECLEDA by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_FTECLEDA_RA.dat 2000 1"
SORT_O="${ESF_FTECLEDA_RA} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	DBLTRNCOD_CF      7:1 -   7:,
	CTR_NF            8:1 -   8:,
	END_NT            9:1 -   9:,
	SEC_NF           10:1 -  10:,
	UWY_NF           11:1 -  11:,
	UW_NT            12:1 -  12:,
	OCCYEA_NF        13:1 -  13:EN,
	ACY_NF           14:1 -  14:EN,
	SCOSTRMTH_NF     15:1 -  15:EN,
	SCOENDMTH_NF     16:1 -  16:EN,
	CUR_CF           18:1 -  18:,
	AMT_M            19:1 -  19:EN 18/3,
	CED_NF           20:1 -  20:,
	RETCTR_NF        24:1 -  24:,
	RETEND_NT        25:1 -  25:,
	RETSEC_NF        26:1 -  26:,
	RTY_NF           27:1 -  27:,
	RETUW_NT         28:1 -  28:,
	RETOCCYEA_NF     29:1 -  29:EN,
	RETACY_NF        30:1 -  30:EN,
	RETSCOSTRMTH_NF  31:1 -  31:EN,
	RETSCOENDMTH_NF  32:1 -  32:EN,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 18/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
  	CRE_D            41:1 -  41:,
	RETINTAMT_M      88:1 -  88:EN 18/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:,
	GAAPCOD_NF      111:1 - 111:,
	I17PRDCOD_CT    112:1 - 112:

/KEYS
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	OCCYEA_NF,
	ACY_NF,
	SCOSTRMTH_NF,
	SCOENDMTH_NF,
	CUR_CF,
	CED_NF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF,
	RETCUR_CF,
	PLC_NT,
	RTO_NF,
	CRE_D,
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B,
	GAAPCOD_NF,
	I17PRDCOD_CT
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT


# BOOKING
#PARM_IS_SAP_POSTING=Y

	if [ "${PARM_IS_SAP_POSTING}" = "Y" ]
	then
                # archive

                #[005] [006]
                NSTEP=${NJOB}_100
                # ARCHIVAGE
                #----------------------------------------------------------------------------
                LIBEL="Archive last Posting file to DARCH : ${ESF_FTECLEDA_POSTING_ARC_AVANT}"
                EXECKSH_MODE=P
                EXECKSH "gzip -c ${ESF_FTECLEDA_POSTING} > ${DARCH}/${ESF_FTECLEDA_POSTING_ARC_AVANT}.dat.gz"

		
		
                #[005] [006]
                NSTEP=${NJOB}_110
                # ARCHIVAGE
                #----------------------------------------------------------------------------
                LIBEL="cp ${ESF_FTECLEDA_RA} ${ESF_FTECLEDA_POSTING}"
                EXECKSH_MODE=P
                EXECKSH "cp ${ESF_FTECLEDA_RA} ${ESF_FTECLEDA_POSTING}"

		
                #[005] [006]
                NSTEP=${NJOB}_120
                # ARCHIVAGE
                #----------------------------------------------------------------------------
                LIBEL="Archive last Posting file to DARCH : ${ESF_FTECLEDA_POSTING_ARC_APRES}"
                EXECKSH_MODE=P
                EXECKSH "gzip -c ${ESF_FTECLEDA_POSTING} > ${DARCH}/${ESF_FTECLEDA_POSTING_ARC_APRES}.dat.gz"

				
	
	fi
	
fi


NSTEP=${NJOB}_130
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

