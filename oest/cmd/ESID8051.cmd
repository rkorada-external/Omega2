#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Envoi de fichiers log pour consultation utilisateur
# nom du script SHELL           : ESID8051.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 28/04/2015
# auteur                        : R. cassis
# references des specifications : Spira EST57
#-----------------------------------------------------------------------------
# description : 
#   Les fichiers log IBNR et NPSAIS générés dans le ESID2000 sont découpés par filiale et envoyés dans l'application pour consultation utilisateur
#
#   :spot:28860
#-----------------------------------------------------------------------------
# historique des modifications :
#[xxx] JJ/MM/AAAA Prog. name   :spot:xxxxx description
#[001] 14/04/2016 EST57b 	:spot:30465 Ajout de logs a l'ecran de consultation EBS FUTURES - PNA RETRO - BLANCHIEMENT
#[002] 27/02/2018 R. Cassis	:spira:67557 Test existence des fichiers avant d'exécuter le traitement d'envoi des fichiers
#==============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctsplit.cmd
. ${DUTI}/fctscp.cmd

# Initialization of the Job
JOBINIT

# Parameters
ICLODAT_D=$1
NORME=$2
TYPEINV=$3

if [ "${NORME}" = "EBS" ]
then
	if [ "${TYPEINV}" = "INV" ]
	then
		EST_IBNR=${EST_IBNR_EBS}
		EST_FUTURE_EBS=${EST_FUTURE_EBS}
	else
		EST_IBNR=${EPO_IBNR_EBS}
		EST_FUTURE_EBS=${EPO_FUTURE_EBS}
	fi
else
	EST_IBNR=${EST_IBNR_IFRS}
	EST_FUTURE_EBS=${EST_FUTURE_EBS}
fi

AN=`echo "${ICLODAT_D}" | cut -c1-4`
MOIS=`echo "${ICLODAT_D}" | cut -c5-6`

# Might do the trick for Quarter : ms=(echo "{$MOIS}" | sed -e's/^0//');TRIM=$(((ms-1)/3+1))

TRIM=`echo "${MOIS}" | awk '{ if ($0 < 4) print "1"; if ($0 > 3 && $0 < 7) print "2";  if ($0 > 6 && $0 < 10) print "3"; if ($0 > 9) print "4"; }'`
DATETRIM=${AN}Q${TRIM}

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV................= ${TYPEINV}"
ECHO_LOG "#===> NORME..................= ${NORME}"
ECHO_LOG "#===> ICLODAT_D..............= ${ICLODAT_D}"
ECHO_LOG "#===> AN.....................= ${AN}"
ECHO_LOG "#===> MOIS...................= ${MOIS}"
ECHO_LOG "#===> TRIM...................= ${TRIM}"
ECHO_LOG "#===> DATETRIM...............= ${DATETRIM}"
ECHO_LOG "#===> EST_IBNR...............= ${EST_IBNR}"
ECHO_LOG "#===> EST_NPSAIS.............= ${EST_NPSAIS}"
ECHO_LOG "#===> EST_PNARETRO...........= ${EST_PNARETRO}"
ECHO_LOG "#===> EST_FUTURE_EBS.........= ${EST_FUTURE_EBS}"
ECHO_LOG "#========================================================================="


########################################################################################
####################### ==>  NP liés à la saisonnalité <== #############################
#[002]
if [ -s "${EST_NPSAIS}" ]
then 
	NSTEP=${NJOB}_10
	#Anomalies Files Merging
	#------------------------------------------------------------------------------
	LIBEL="Anomalies Files Merging"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_NPSAIS} 500"
	SORT_O="${DFILT}/${NSTEP}_esid8050_${DATETRIM}_SAIS.dat 500"
	INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS SSD_CF 1:1 - 1:EN,
	        ESB_CF 2:1 - 2:EN
	/KEYS SSD_CF, ESB_CF
exit
EOF
	SORT

	NSTEP=${NJOB}_20
	#Split Files by SSD
	#------------------------------------------------------------------------------
	LIBEL="Split files by SSD"
	SPLIT_PREFIX=${NJOB}_10
	SPLIT_PREFIX_NEW=${NCHAIN}_${HOST_PRDSIT}
	SPLIT_I=${DFILT}/${NJOB}_10_esid8050_${DATETRIM}_SAIS.dat
	SPLIT_FILE_2
	
	# Ajout libelles et formules au fichier log SAIS et formatage en fichier .csv
	#------------------------------------------------------------------------------
	TYPE=SAIS
	for fic in `ls ${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.dat`
	do
		grep ${TYPE}~ ${DFILP}/${NCHAIN}_ENTETE_LOGS.dat | cut -d"~" -f2 > ${DFILT}/${NCHAIN}_ENTETE_LOGS_${TYPE}.dat
		cat ${DFILT}/${NCHAIN}_ENTETE_LOGS_${TYPE}.dat ${fic} > ${DFILT}/${NCHAIN}_ENTETE_LOGS_TRAV.dat
		fic2=`echo ${fic} | cut -d"." -f1`.csv
		ECHO_LOG "${fic} to ${fic2}"
		nostep=`echo ${fic2} | cut -d"_" -f3-5`
		NSTEP=${NJOB}_30_${nostep}
		# Convert delimiter tilde to csv
		#-----------------------------------------------------------------------------
		LIBEL="Convert delimiter tilde to csv"
		AWK_I=${DFILT}/${NCHAIN}_ENTETE_LOGS_TRAV.dat
		AWK_O=${fic2}
		AWK_CMD=`CFTMP`
		INPUT_TEXT ${AWK_CMD} <<EOF
		BEGIN{ FS="\~"; OFS=";" }
		     { \$1 = \$1; print \$0 }
exit
EOF
		AWK
	done
	
	NSTEP=${NJOB}_40
	# Begin SCP
	#----------------------------------------------------------------------------
	LIBEL="SCP des fichier ${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.csv vers le serveur de report"
	SCP_SITE=REPORT_SCP
	SCP_WAY=PUT
	SCP_FILE=${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.csv
	SCP
else
	ECHO_LOG "Pas de fichier EST_NPSAIS"
fi

#####################################################################
####################### ==>  IBNR <== ###############################
#[002]
if [ -s "${EST_IBNR}" ]
then 
	NSTEP=${NJOB}_50
	#Anomalies Files Merging
	#------------------------------------------------------------------------------
	LIBEL="Anomalies Files Merging"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_IBNR} 500"
	SORT_O="${DFILT}/${NSTEP}_esid8050_${DATETRIM}_IBNR_${NORME}.dat 500"
	INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS SSD_CF 1:1 - 1:EN,
	        ESB_CF 2:1 - 2:EN
	/KEYS SSD_CF, ESB_CF
exit
EOF
	SORT

	NSTEP=${NJOB}_60
	#Split Files by SSD
	#------------------------------------------------------------------------------
	LIBEL="Split files by SSD"
	SPLIT_PREFIX=${NJOB}_50
	SPLIT_PREFIX_NEW=${NCHAIN}_${HOST_PRDSIT}
	SPLIT_I=${DFILT}/${NJOB}_50_esid8050_${DATETRIM}_IBNR_${NORME}.dat
	SPLIT_FILE_2

	# Ajout libelles et formules au fichier log IBNR et formatage en fichier .csv
	#------------------------------------------------------------------------------
	TYPE=IBNR
	for fic in `ls ${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}_${NORME}.dat`
	do
		grep ${TYPE}~ ${DFILP}/${NCHAIN}_ENTETE_LOGS.dat | cut -d"~" -f2 > ${DFILT}/${NCHAIN}_ENTETE_LOGS_${TYPE}_${NORME}.dat
		cat ${DFILT}/${NCHAIN}_ENTETE_LOGS_${TYPE}_${NORME}.dat ${fic} > ${DFILT}/${NCHAIN}_ENTETE_LOGS_TRAV.dat
		fic2=`echo ${fic} | cut -d"." -f1`.csv
		ECHO_LOG "${fic} to ${fic2}"
		nostep=`echo ${fic2} | cut -d"_" -f3-5`
		NSTEP=${NJOB}_70_${nostep}
		# Convert delimiter tilde to csv
		#-----------------------------------------------------------------------------
		LIBEL="Convert delimiter tilde to csv"
		AWK_I=${DFILT}/${NCHAIN}_ENTETE_LOGS_TRAV.dat
		AWK_O=${fic2}
		AWK_CMD=`CFTMP`
		INPUT_TEXT ${AWK_CMD} <<EOF
		BEGIN{ FS="\~"; OFS=";" }
		     { \$1 = \$1; print \$0 }
exit
EOF
		AWK
	done

	NSTEP=${NJOB}_80
	# Begin SCP
	#----------------------------------------------------------------------------
	LIBEL="SCP des fichier ${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}_${NORME}.csv vers le serveur de report"
	SCP_SITE=REPORT_SCP
	SCP_WAY=PUT
	SCP_FILE=${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}_${NORME}.csv
	SCP
else
	ECHO_LOG "Pas de fichier EST_IBNR"
fi

#################################################################################
####################### ==>  FUTURE EBS <== #####################################

if [ -s "${EST_FUTURE_EBS}" ]
then 
	STEP=${NJOB}_90
	#Anomalies Files Merging
	#------------------------------------------------------------------------------
	LIBEL="Anomalies Files Merging"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_FUTURE_EBS} 500"
	SORT_O="${DFILT}/${NSTEP}_esid8050_${DATETRIM}_FUTURES.dat 500"
	INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS SSD_CF 1:1 - 1:EN,
			ESB_CF 2:1 - 2:EN
	/KEYS SSD_CF, ESB_CF
exit
EOF
	SORT

	NSTEP=${NJOB}_92
	#Split Files by SSD
	#------------------------------------------------------------------------------
	LIBEL="Split files by SSD"
	SPLIT_PREFIX=${NJOB}_90
	SPLIT_PREFIX_NEW=${NCHAIN}_${HOST_PRDSIT}
	SPLIT_I=${DFILT}/${NJOB}_90_esid8050_${DATETRIM}_FUTURES.dat
	SPLIT_FILE_2

	# Ajout libelles et formules au fichier log FUTURES et formatage en fichier .csv
	#------------------------------------------------------------------------------
	TYPE=FUTURES
	for fic in `ls ${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.dat`
	do
		grep ${TYPE}~ ${DFILP}/${NCHAIN}_ENTETE_LOGS.dat | cut -d"~" -f2 > ${DFILT}/${NCHAIN}_ENTETE_LOGS_${TYPE}.dat
		cat ${DFILT}/${NCHAIN}_ENTETE_LOGS_${TYPE}.dat ${fic} > ${DFILT}/${NCHAIN}_ENTETE_LOGS_TRAV.dat
		fic2=$(echo ${fic%.dat}.csv)
		ECHO_LOG "${fic} to ${fic2}"
		nostep=`echo ${fic2} | cut -d"_" -f3-5`
		NSTEP=${NJOB}_95_${nostep}
		# Convert delimiter tilde to csv
		#-----------------------------------------------------------------------------
		LIBEL="Convert delimiter tilde to csv"
		AWK_I=${DFILT}/${NCHAIN}_ENTETE_LOGS_TRAV.dat
		AWK_O=${fic2}
		AWK_CMD=`CFTMP`
		INPUT_TEXT ${AWK_CMD} <<EOF
		BEGIN{ FS="\~"; OFS=";" }
			 { \$1 = \$1; print \$0 }
exit
EOF
		AWK
	done

	NSTEP=${NJOB}_100
	# Begin SCP
	#----------------------------------------------------------------------------
	LIBEL="SCP des fichier ${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.csv vers le serveur de report"
	SCP_SITE=REPORT_SCP
	SCP_WAY=PUT
	SCP_FILE=${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.csv
	SCP
else 
	ECHO_LOG "Pas de fichier EST_FUTURES_EBS"
fi

#################################################################################
####################### ==>  PNA RETRO  <== #####################################

if [ -s "${EST_PNARETRO}" ]
then
	NSTEP=${NJOB}_110
	#Anomalies Files Merging
	#------------------------------------------------------------------------------
	LIBEL="Anomalies Files Merging"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_PNARETRO} 500"
	SORT_O="${DFILT}/${NSTEP}_esid8050_${DATETRIM}_PNARETRO.dat 500"
	INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS SSD_CF 1:1 - 1:EN,
			ESB_CF 2:1 - 2:EN
	/KEYS SSD_CF, ESB_CF
exit
EOF
	SORT

	NSTEP=${NJOB}_120
	#Split Files by SSD
	#------------------------------------------------------------------------------
	LIBEL="Split files by SSD"
	SPLIT_PREFIX=${NJOB}_110
	SPLIT_PREFIX_NEW=${NCHAIN}_${HOST_PRDSIT}
	SPLIT_I=${DFILT}/${NJOB}_110_esid8050_${DATETRIM}_PNARETRO.dat
	SPLIT_FILE_2

	# Ajout libelles et formules au fichier log SAIS et formatage en fichier .csv
	#------------------------------------------------------------------------------
	TYPE=PNARETRO
	for fic in `ls ${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.dat`
	do
		grep ${TYPE}~ ${DFILP}/${NCHAIN}_ENTETE_LOGS.dat | cut -d"~" -f2 > ${DFILT}/${NCHAIN}_ENTETE_LOGS_${TYPE}.dat
		cat ${DFILT}/${NCHAIN}_ENTETE_LOGS_${TYPE}.dat ${fic} > ${DFILT}/${NCHAIN}_ENTETE_LOGS_TRAV.dat
		fic2=$(echo ${fic%.dat}.csv)
		ECHO_LOG "${fic} to ${fic2}"
		nostep=`echo ${fic2} | cut -d"_" -f3-5`
		NSTEP=${NJOB}_125_${nostep}
		# Convert delimiter tilde to csv
		#-----------------------------------------------------------------------------
		LIBEL="Convert delimiter tilde to csv"
		AWK_I=${DFILT}/${NCHAIN}_ENTETE_LOGS_TRAV.dat
		AWK_O=${fic2}
		AWK_CMD=`CFTMP`
		INPUT_TEXT ${AWK_CMD} <<EOF
		BEGIN{ FS="\~"; OFS=";" }
			 { \$1 = \$1; print \$0 }
exit
EOF
		AWK
	done

	NSTEP=${NJOB}_130
	# Begin SCP
	#----------------------------------------------------------------------------
	LIBEL="SCP des fichier ${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.csv vers le serveur de report"
	SCP_SITE=REPORT_SCP
	SCP_WAY=PUT
	SCP_FILE=${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.csv
	SCP
else 
	ECHO_LOG "Pas de fichier EST_PNARETRO"
fi

#################################################################################
####################### ==>  BLANCHIMENT RPCC  <== ##############################

if [ -s "${EST_BLANCHIMENT_RPCC}" ]
then 
	NSTEP=${NJOB}_140
	#Anomalies Files Merging
	#------------------------------------------------------------------------------
	LIBEL="Anomalies Files Merging"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_BLANCHIMENT_RPCC} 500"
	SORT_O="${DFILT}/${NSTEP}_esid8050_${DATETRIM}_BLANCHIMENT_RPCC.dat 500"
	INPUT_TEXT ${SORT_CMD} <<EOF
	/FIELDS SSD_CF 1:1 - 1:EN,
			ESB_CF 2:1 - 2:EN
	/KEYS SSD_CF, ESB_CF
exit
EOF
	SORT

	NSTEP=${NJOB}_150
	#Split Files by SSD
	#------------------------------------------------------------------------------
	LIBEL="Split files by SSD"
	SPLIT_PREFIX=${NJOB}_140
	SPLIT_PREFIX_NEW=${NCHAIN}_${HOST_PRDSIT}
	SPLIT_I=${DFILT}/${NJOB}_140_esid8050_${DATETRIM}_BLANCHIMENT_RPCC.dat
	SPLIT_FILE_2

	# Ajout libelles et formules au fichier log SAIS et formatage en fichier .csv
	#------------------------------------------------------------------------------
	TYPE=BLANCHIMENT_RPCC
	for fic in `ls ${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.dat`
	do
		grep ${TYPE}~ ${DFILP}/${NCHAIN}_ENTETE_LOGS.dat | cut -d"~" -f2 > ${DFILT}/${NCHAIN}_ENTETE_LOGS_${TYPE}.dat
		cat ${DFILT}/${NCHAIN}_ENTETE_LOGS_${TYPE}.dat ${fic} > ${DFILT}/${NCHAIN}_ENTETE_LOGS_TRAV.dat
		fic2=$(echo ${fic%.dat}.csv)
		ECHO_LOG "${fic} to ${fic2}"
		nostep=`echo ${fic2} | cut -d"_" -f3-5`
		NSTEP=${NJOB}_155_${nostep}
		# Convert delimiter tilde to csv
		#-----------------------------------------------------------------------------
		LIBEL="Convert delimiter tilde to csv"
		AWK_I=${DFILT}/${NCHAIN}_ENTETE_LOGS_TRAV.dat
		AWK_O=${fic2}
		AWK_CMD=`CFTMP`
		INPUT_TEXT ${AWK_CMD} <<EOF
		BEGIN{ FS="\~"; OFS=";" }
			 { \$1 = \$1; print \$0 }
exit
EOF
		AWK
	done

	NSTEP=${NJOB}_160
	# Begin SCP
	#----------------------------------------------------------------------------
	LIBEL="SCP des fichier ${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.csv vers le serveur de report"
	SCP_SITE=REPORT_SCP
	SCP_WAY=PUT
	SCP_FILE=${DFILT}/${NCHAIN}_${HOST_PRDSIT}_*_esid8050_${DATETRIM}_${TYPE}.csv
	SCP
else
	ECHO_LOG "Pas de fichier EST_BLANCHIMENT_RPCC"

fi
#########################
# Erase temporary files #
#########################

NSTEP=${NJOB}_500
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NCHAIN}_*.dat"

JOBEND
