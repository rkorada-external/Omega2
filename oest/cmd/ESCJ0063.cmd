#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION - INVENTAIRE
# nom du script SHELL           : ESCJ0063.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 17/10/97
# auteur                        : CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# description: This chain get TL files from the estimation chain ESID2550
#-----------------------------------------------------------------------------
# historiques des modifications
# [01] 26/11/2012 PPEZOUT :spot:24516 création, ECHANGES INTERNES POST OMEGA
# [02] 20/03/2013 PPEZOUT :spot:25002 doublons, ECHANGES INTERNES POST OMEGA
#[003] 29/05/2013 PPEZOUT :spot:25171 Modifications Solvency
#[004] 25/06/2014 CDESPRET :spot:26956 Ajout du SUMMURIZE pour supprimer les lignes en doublon
#[005] 26/08/2016 MBO	  :spot:31117:pas de spira: ajout de colonne en plus
#[006] 03/08/2017 R.Cassis :spira:63164 Le fichier GTEP a un nom specifique pour chaque type d'inventaire post-omega.
#[007] 06/02/2018 R.Cassis :spira:63164 renomage fichier archivé
#[28] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[008] 02/03/2022 MZM :spira:102508 Ajout LOG SITE et EXTCHAIN et IDF_CT
#[009] 18/06/2025 MZM : SPIRA 112870 BBNI-Variabilisation NOMFIC
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

# Job Initialisation
JOBINIT

# Get parameters
TYPEINV=$1
NORME=$2
NOMFIC=GTEP${TYPEINV}


if [ "${IDF_CT}" = "EBS_ESPD4000" ] 
then
NOMFIC=GTEPSTDE

fi

if  [ "${IDF_CT}" = "EBS_ESPD4000_BBNI" ]
then
NOMFIC=GTEPBBNI
fi

##[006]
#if [ "${TYPEINV}" != "INV" ]
#then
#	if [ "${TYPEINV}" = "POS" ]
#	then
#		NOMFIC=GTEPSO
#		EST_GTEP=${EPO_GTEPSO}
#		if [ "${NORME}" = "EBS" ]
#		then
#			NOMFIC=GTEPSIISO
#			EST_GTEP=${EPO_GTEPSIISO}
#		fi
#	else
#		NOMFIC=GTEPCO
#		EST_GTEP=${EPO_GTEPCO}
#		if [ "${NORME}" = "EBS" ]
#		then
#			NOMFIC=GTEPSIICO
#			EST_GTEP=${EPO_GTEPSIICO}
#		fi
#	fi
#fi
touch ${EST_GTEP}	
	

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> REMOTE_SITE..............: ${REMOTE_SITE}"
ECHO_LOG "#===> NOMFIC...................: ${NOMFIC}"
ECHO_LOG "#===> EXTCHAIN.................: ${EXTCHAIN}"
ECHO_LOG "#===> TYPEINV..................: ${TYPEINV}"
ECHO_LOG "#===> NORME....................: ${NORME}"
ECHO_LOG "#===> CLOPRD...................: ${CLOPRD}"
ECHO_LOG "#===> EST_GTEP.................: ${EST_GTEP}"
ECHO_LOG "#===> IDF_CT...................: ${IDF_CT}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_10
#---------------------------------------------------------------------------
# va cherche le DLEIGTAA
LIBEL="Get files from directories and merge them"
GET_FILES_DIR=${REMOTE_SITE}
GET_FILES_PREFIX=${EXTCHAIN}
GET_FILES_MERGE="YES"
GET_FILES_O=${DFILT}/${NSTEP}_${IB}_GTE_O.dat
GET_FILES

NSTEP=${NJOB}_15
#---------------------------------------------------------------------------
LIBEL="Screening and sorting received file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I=${DFILT}/${NJOB}_10_${IB}_GTE_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTE_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS BALSHYEA_NF 3:1 - 3:, BALSHTMTH_NF 4:1 - 4:EN, BALSHTDAY_NF 5:1 - 5:, CLOPRD 41:1 - 41:, DBCLO_D 42:1 - 42:, CRE_D 43:1 - 43:, ORGSSD_CF 44:1 - 44:
/CONDITION CURRENT_PRD CLOPRD EQ "${CLOPRD}"
/KEYS ORGSSD_CF, BALSHYEA_NF, BALSHTMTH_NF, BALSHTDAY_NF, DBCLO_D DESCENDING, CRE_D DESCENDING
/INCLUDE CURRENT_PRD
exit
EOF
SORT

#[007]
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> Sauvegarde ...... ${EST_GTEP}"
ECHO_LOG "#========================================================================="
gzip -c ${EST_GTEP} > ${DFILT}/${NJOB}_20_${IB}_${NOMFIC}.dat.gz

NSTEP=${NJOB}_20
#---------------------------------------------------------------------------
LIBEL="Screening and sorting old file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_GTEP}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTEP_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS BALSHYEA_NF 3:1 - 3:, BALSHTMTH_NF 4:1 - 4:EN, BALSHTDAY_NF 5:1 - 5:, CLOPRD 41:1 - 41:, DBCLO_D 42:1 - 42:, CRE_D 43:1 - 43:, ORGSSD_CF 44:1 - 44:
/CONDITION CURRENT_PRD CLOPRD EQ "${CLOPRD}"
/KEYS ORGSSD_CF, BALSHYEA_NF, BALSHTMTH_NF, BALSHTDAY_NF, DBCLO_D DESCENDING, CRE_D DESCENDING
/INCLUDE CURRENT_PRD
exit
EOF
SORT


NSTEP=${NJOB}_25
#---------------------------------------------------------------------------
LIBEL="Merging files and sorting the result"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_15_${IB}_SORT_GTE_O.dat
SORT_I2=${DFILT}/${NJOB}_20_${IB}_SORT_GTEP_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_MGTE_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS BALSHYEA_NF 3:1 - 3:, BALSHTMTH_NF 4:1 - 4:EN, BALSHTDAY_NF 5:1 - 5:, CLOPRD 41:1 - 41:, DBCLO_D 42:1 - 42:, CRE_D 43:1 - 43:, ORGSSD_CF 44:1 - 44:
/KEYS ORGSSD_CF, BALSHYEA_NF, BALSHTMTH_NF, BALSHTDAY_NF, DBCLO_D DESCENDING, CRE_D DESCENDING
/MERGE
exit
EOF
SORT

NSTEP=${NJOB}_30
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_25_${IB}_SORT_MGTE_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTEKEYS_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS BALSHYEA_NF 3:1 - 3:, BALSHTMTH_NF 4:1 - 4:EN, BALSHTDAY_NF 5:1 - 5:, ORGSSD_CF 44:1 - 44:
/KEYS ORGSSD_CF, BALSHYEA_NF, BALSHTMTH_NF, BALSHTDAY_NF
/SUM
/STABLE
exit
EOF
SORT

NSTEP=${NJOB}_35
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Computing new TL file..."
PRG=ESTC7603
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_GTEKEYS_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_15_${IB}_SORT_GTE_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_20_${IB}_SORT_GTEP_O.dat
#export ${PRG}_O1=${EST_GTEP}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_GTEP.dat
EXECPRG

NSTEP=${NJOB}_38
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
# [004] Ajout du SUM pour supprimer les doublons en réception. Lors de l'envoi, les montants sont sommés lors de l'envoi
# [005]
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_35_${IB}_GTEP.dat
SORT_O=${EST_GTEP}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER      1:1 - 48:
/KEYS FILLER
/SUM
/STABLE
exit
EOF
SORT

#[007]
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> Sauvegarde ...... ${EST_GTEP}"
ECHO_LOG "#========================================================================="
gzip -c ${EST_GTEP} > ${DFILT}/${NJOB}_38_${IB}_${NOMFIC}.dat.gz

NSTEP=${NJOB}_40
# Begin rm
#------------------------------------------------------------------------------
LIBEL="Remove temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND
