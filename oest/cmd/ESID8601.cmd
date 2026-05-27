#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS -
#                                  Injection des resultats des calculs solvency dans l'infocentre
# nom du script SHELL            : ESID8601.cmd
# revision                       : $Revision: 1.5 $
# date de creation               : 24/07/2012
# auteur                         : P. Pezout
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   :spot:23802 Injection of the Acceptance and Retrocession TL files into the infocenter
#
# Input files
#       EST_FTECLEDSII               DFILP
#
# Output files
#
# launched by ESID8600.cmd or ESPD8600.cmd
#
#-----------------------------------------------------------------------------
#[002] 31/07/2012 -=Dch=-   :spot:24041 remplacement de TECLEDA par TECLEDASII
#[003] 29/01/2013 R. Cassis :spot:24659 Suppression donnees avec commit pour gestion syslog sybase
#[004] 13/08/2013 P. Coppin :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2
#[005] 30/10/2013 Florent   :spot:25726  Maj pour prendre en compte l'existence d'une autre clodat_d dans TTECLEDSII
#[006] 16/05/2014 Roger     :spot:26778  Correction requete d'extraction des donn�es EBS
#[007] 26/11/2014 Roger     :spot:27857  Correct sql query to select a.*
#[008] 23/09/2015 Philippe  :spot:28941 
#[009] 07/06/2016 Roger     :spot:30713  Archivage fichier POCE
#[010] 12/08/2016 Roger     :spot:31046  Fiabilise le chargement de la table en cas de reprise
#[011] 06/10/2016 Roger     :spot:31302  Gestion fichiers GTSII_RISKMARGINCO et GTSII_RISKMARGINSO
#[012] 19/12/2016 Roger     :spot:21263  correction affectation du fichier POC
#[013] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[014] 08/07/2021 D. DA SILVA TEIXEIRA : SPIRA 91532 Add VNORME I4I condition
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CLODAT_D=$4
TYPEINV=$5
SUFFTABLE=$6
INVCONSO_D=$7

# Job Initialisation
JOBINIT

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV.............: ${TYPEINV}"
ECHO_LOG "#===> CLODAT_D............: ${CLODAT_D}"
ECHO_LOG "#===> INVCONSO_D..........: ${INVCONSO_D}"
ECHO_LOG "#===> SUFFTABLE...........: ${SUFFTABLE}"
ECHO_LOG "#===> BALSHTYEA_NF........: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF........: ${BALSHTMTH_NF}"
ECHO_LOG "#===> CRE_D...............: ${CRE_D}"
ECHO_LOG "#========================================================================="

#[014]
if [ "${TYPEINV}" != "INV" && "${VNORME}" != "I4I" ]
then
	NSTEP=${NJOB}_10
	#-----------------------------------------------------------------------------
	LIBEL="Determination of the TTECLEDSII table that will be loaded"
	ISQL_BASE="BSTA"
	ISQL_QRY="execute PsTBOPAR_01 'EST', 'TTECLEDA', '${CLODAT_D}',${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
	ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
	ISQL_RES
	
	#[002] The Table that will take TTECLEDSII results is
	TTECLEDSII=`cat ${ISQL_FRES} | sed -e s/\ //g | sed -e s/TTECLEDA/TTECLEDSII/`
else
	#if [ "${TYPEINV}" = "POS" ]
	#then
	#	EST_FTECLEDSII=${EPO_FTECLEDSIISO}
	#else
	#	EST_FTECLEDSII=${EPO_FTECLEDSIICO}
	#fi
	TTECLEDSII=TTECLEDSII_${SUFFTABLE}
fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TTECLEDSII............: ${TTECLEDSII}"
ECHO_LOG "#===> EST_FTECLEDSII........: ${EST_FTECLEDSII}"
ECHO_LOG "#===> TTECLEDSII............: ${TTECLEDSII}"
ECHO_LOG "#========================================================================="

load=n
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="touch ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat"
EXECKSH_MODE=P
EXECKSH "touch ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat"
if [ "${TYPEINV}" != "INV" ]
then
	#[012]
	#trimCO=`head -1 ${EPO_FTECLEDSIICO} | cut -d~ -f3`
	#trimSO=`head -1 ${EPO_FTECLEDSIISO} | cut -d~ -f3`
	# On recharge SO et CO si le trimestre des fichiers est celui trait�
	#if [ "${trimSO}" = "${INVCONSO_D}" ]
	#then
	#	LIBEL="cat ${EPO_FTECLEDSIISO} ${EPO_GTSII_RISKMARGINSO} >> ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat"
	#	EXECKSH ""
	#	cat ${EPO_FTECLEDSIISO} ${EPO_GTSII_RISKMARGINSO} >> ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat
	#	load=y
	#fi
	#if [ "${trimCO}" = "${INVCONSO_D}" ]
	#then
	#	LIBEL="cat ${EPO_FTECLEDSIICO} ${EPO_GTSII_RISKMARGINCO} >> ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat"
	#	EXECKSH ""
	#	cat ${EPO_FTECLEDSIICO} ${EPO_GTSII_RISKMARGINCO} >> ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat
	#	load=y
	#fi

	trim=`head -1 ${EST_FTECLEDSII} | cut -d~ -f3`
	if [ "${trim}" = "${INVCONSO_D}" ]
	then
		LIBEL="cat ${EST_FTECLEDSII} ${EST_GTSII_RISKMARGIN} >> ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat"
		EXECKSH ""
		cat ${EST_FTECLEDSII} ${EST_GTSII_RISKMARGIN} >> ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat
		load=y
	fi


else
	LIBEL="cat ${EST_FTECLEDSII} ${EST_GTSII_RISKMARGIN} >> ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat"
	EXECKSH ""
	cat ${EST_FTECLEDSII} ${EST_GTSII_RISKMARGIN} >> ${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat
	load=y
fi

if [ "${load}" = "n" ]
then
	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===> Pas de fichier � charger car pas de donn�es pour ${INVCONSO_D} - Arret"
	ECHO_LOG "#========================================================================="
	JOBEND
fi

NSTEP=${NJOB}_28
#------------------------------------------------------------------------------
LIBEL="Sort of FTECLEDR File on index key"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_${TTECLEDSII}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}_OTHERS.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2: EN,
        TRNCOD_CF 6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF,
      ESB_CF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/OUTFILE ${SORT_O}
/INCLUDE INVENTAIRE
/OUTFILE ${SORT_O2}
/OMIT INVENTAIRE


exit
EOF
SORT


NSTEP=${NJOB}_30
#--------------------------------
LIBEL="BCP in ${TTECLEDSII} table"
BCP_WAY="IN"
BCP_VER=""
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_RMINFILE=YES
BCP_I=${DFILT}/${NJOB}_28_${IB}_${TTECLEDSII}.dat
BCP_TABLE="BSAR..${TTECLEDSII}"
BCP


#NSTEP=${NJOB}_50
##------------------------------------------------------------------------------
#LIBEL="Update LSTUPD_D in TBOPAR"
#ISQL_QRY=`CFTMP`
#ISQL_BASE=BSTA
#ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDSII','${CLODAT_D}',${BALSHTYEA_NF},${BALSHTMTH_NF},'${CRE_D}','CP'"
#ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
#ISQL

#[009]
if [ "${TYPEINV}" = "POC" ]
then
	gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3700_FTECLEDSIICO.dat > ${DARCH}/${ENV_PREFIX}_ESPD3700_FTECLEDSIICO_${INVCONSO_D}_${CRE_D}.dat.gz
	gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGINCO.dat > ${DARCH}/${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGINCO_${INVCONSO_D}_${CRE_D}.dat.gz
fi

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
