#!/bin/ksh
#-------------------------------------------------------------------
# Application name : SOLVENCY II
# Source name      : ESID0101
# Revision         : 1.0
# Creation date    : 11/04/2012
# Author           : DCH
#-------------------------------------------------------------------
# historiques des modifications
#[01] Florent         22/10/2012 :spot:24041 Solvency II
#[02] Cyrille Despret 21/11/2013 :spot:26391 Modification du test sur le type ICV : meme traitement que pour CUM
#[03] Florent         05/11/2014 :spot:27789 pour gérer les doublons sur le fichier trace TPATSEGSII
#[04] Florent         29/04/2015 :spot:26391 gestion du nombre de lignes à charger en mémoire
#[05] Florent         13/05/2016 :spot:30543 gestion du DSI !
#[06] Florent         21/07/2016 :spot:30976 Corections Solvency Ratio LoB
#====================================================================

#- Call generic functions
. ${DUTI}/fctgen.cmd

#set -x

TYPE_FICHIER=$1

#Job Initialization
JOBINIT

EST_LOCK=${DFILT}/${ENV_PREFIX}_ESID0101_EST_FPATTERNSII_${TYPE_FICHIER}_LOCK.dat

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Create Lock file in ${EST_LOCK}"
integer ATTENTE
ATTENTE=0
while [ -f ${EST_LOCK} ]
do
	# wait 1 second and increment the time wait
	sleep 1
	let ATTENTE=ATTENTE+1
	if [ $ATTENTE -ge 3600 ]
	then
		ECHO_LOG "Erreur dans l'attente du verrou sur ${EST_LOCK}"
		STEPEND 1
	fi
done
EXECKSH "echo '1' > ${EST_LOCK}"

LIGNES=$(cat ${EST_FPATTERNSII_REF} ${EST_FPATTERNSII_DDBL_IN} | wc -l)

NSTEP=${NJOB}_10
#--------------------------------
LIBEL="Call ESTC3001.exe vérifie l'unicité des patterns et sort les patterns nouveaux"
PRG=ESTC3001
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
LIGNES ${LIGNES}
TYPEFICHIER ${TYPE_FICHIER}
exit
EOF
export ${PRG}_I1=${EST_FPATTERNSII_REF}
export ${PRG}_I2=${EST_FPATTERNSII_DDBL_IN}
export ${PRG}_O1=${EST_FPATTERNSII_DDBL_OUT}
export ${PRG}_O2=${EST_FPATSEGSII_DUPLI}
EXECPRG

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Delete the duplicates in ${EST_FPATSEGSII_DUPLI}"
EXECKSH_MODE=P
EXECKSH "sort -u ${EST_FPATSEGSII_DUPLI} -o ${DFILT}/${NSTEP}_${IB}_EST_FPATSEGSII_DUPLI.dat; cp ${DFILT}/${NSTEP}_${IB}_EST_FPATSEGSII_DUPLI.dat ${EST_FPATSEGSII_DUPLI}"

if [[ "${TYPE_FICHIER}" = "DSI" ]];then
	NSTEP=${NJOB}_30
	#------------------------------------------------------------------------------
	LIBEL="Dans le fichier trace on récupère les nouvelles traces DSI pour maj"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I=${EST_FPATSEGSII_DUPLI}
	SORT_O=${DFILT}/${NSTEP}_${IB}_EST_FPATSEGSII_DDBL_NEW.dat
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
 DUPLI_PER_CF         2:1 -  2:
,DUPLI_LOB_CF         5:1 -  5:
,DUPLI_CUR_CF         6:1 -  6:
,DUPLI_NORME_CF       7:1 -  7:
,DUPLI_SEGNAT_CT      8:1 -  8:
,DUPLI_PATCAT_CT      9:1 -  9:
,DUPLI_PATTYP_CT     10:1 - 10:
,DUPLI_PATTERN_ID    11:1 - 11:
,DUPLI_ORIPATTERN_ID 14:1 - 14:
/KEYS DUPLI_LOB_CF,DUPLI_CUR_CF,DUPLI_NORME_CF,DUPLI_SEGNAT_CT,DUPLI_PATCAT_CT,DUPLI_PATTYP_CT,DUPLI_ORIPATTERN_ID
/CONDITION DUPLI_NEW DUPLI_PER_CF EQ "NEW"
/OUTFILE ${SORT_O}
/INCLUDE DUPLI_NEW
/REFORMAT DUPLI_LOB_CF,DUPLI_CUR_CF,DUPLI_NORME_CF,DUPLI_SEGNAT_CT,DUPLI_PATCAT_CT,DUPLI_PATTYP_CT,DUPLI_ORIPATTERN_ID,DUPLI_PATTERN_ID
exit
EOF
	SORT

	NSTEP=${NJOB}_40
	#------------------------------------------------------------------------------
	LIBEL="Avec les traces NEW du ESTC3001.exe on mets à jour les traces NEW du ESTC3003 pour ne garder que celles qui sont vraiment nouvelles"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I=${EST_FPATSEGSII_NEW}
	SORTI2=${DFILT}/${NJOB}_30_${IB}_EST_FPATSEGSII_DDBL_NEW.dat
	SORT_O="${DFILT}/${NSTEP}_${IB}_FPATSEGSII_NEW_SORT_O.dat 300 1"
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
 NEW_KEY              5:1 - 11:
,NEW_FILLER1          1:1 - 10:
,NEW_FILLER2         12:1 - 16:

,DUPLI_KEY             1:1 - 7:
,DUPLI_NEW_PATTERN_ID  8:1 - 8:

/JOINKEYS NEW_KEY

/INFILE ${SORTI2}
/JOINKEYS DUPLI_KEY

/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: NEW_FILLER1, RIGHTSIDE: DUPLI_NEW_PATTERN_ID, LEFTSIDE: NEW_FILLER2
exit
EOF
	SORT

	NSTEP=${NJOB}_22
	#------------------------------------------------------------------------------
	LIBEL="Maj EST_FPATSEGSII_NEW et vidage du EST_FPATSEGSII_DUPLI"
	EXECKSH_MODE=P
	EXECKSH "rm ${EST_FPATSEGSII_DUPLI}; touch ${EST_FPATSEGSII_DUPLI}; cp ${DFILT}/${NJOB}_40_${IB}_FPATSEGSII_NEW_SORT_O.dat ${EST_FPATSEGSII_NEW}"
fi

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Suppression du verrou de fichier ${EST_LOCK}"
RMFIL "${EST_LOCK}"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
