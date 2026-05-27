#!/bin/ksh
#==============================================================================
#nom de l'application          : ESTIMATIONS : Sauvegarde trimestrielle tables Infocentre
#nom du source                 : ESID9991
#revision                      :
#date de creation              : 18/01/2001
#auteur                        : S. Llorente
#references des spicifications : #################
#squelette de base             :
#------------------------------------------------------------------------------
#description :
#
# Objet : Control by DBCC on each databases of SQL Server
#
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
#[001] 03/01/2013 Roger Cassis :spot:24041 Solvency 2 - Ajout archivage FTECLEDSII
#[002] 21/03/2013 Roger Cassis :spot:25006 Transformation des .zip en .gz plus performants
#[003] 08/08/2013 R. CASSIS    :spot:25427 - Ajout jointure table tbatchssd pour Omega2
#[004] 31/08/2015 R. CASSIS    :spot:29282 - Correction sur les requetes d'extraction
#[005] 01/08/2016 R. Cassis    :spot:31046 - Ajout variables PARM0 pour Archivage table TTECLEDSII du trimestre -1
#=============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# JOB initialization
JOBINIT

#Recuperation des variables d'entree
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CLODAT_D=$3
SUFFIXINV=$4
TYPTAB=$5
SUFFIXPOST=$6
SUFFTABLE=$7

if [ ${TYPTAB} =  "W" ]
then
	NSTEP=${NJOB}_01
	#Begin isql
	#-----------------------------------------------------------------------------
	LIBEL="Determination of the TTECLEDA table that will be loaded"
	ISQL_BASE="BSTA"
	ISQL_QRY="execute PsTBOPAR_01 'EST', 'TTECLEDA', '${CLODAT_D}',
	                               ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
	ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
	ISQL_RES

	#The Tables that will take results are
	TABLES=`cat ${ISQL_FRES} | sed -e s/\ //g`
	export TYPTAB=`echo ${TABLES} | cut -c9-9`
fi


ECHO_LOG "#================================================"
ECHO_LOG "-> BALSHTYEA_NF... : ${BALSHTYEA_NF}"
ECHO_LOG "-> BALSHTMTH_NF... : ${BALSHTMTH_NF}"
ECHO_LOG "-> CLODAT_D....... : ${CLODAT_D}"
ECHO_LOG "-> SUFFIXINV...... : ${SUFFIXINV}"
ECHO_LOG "-> TYPTAB......... : ${TYPTAB}"
ECHO_LOG "-> SUFFIXPOST..... : ${SUFFIXPOST}"
ECHO_LOG "-> SUFFTABLE...... : ${SUFFTABLE}"
ECHO_LOG "#================================================="

#[003]
NSTEP=${NJOB}_10
# Begin BCP OUT
#-----------------------------------------------------------------
LIBEL="BCP OUT of table BSAR..TTCLEDA"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DARCH}/${NJOB}_${SRV}_TTECLEDA_${TYPTAB}_${SUFFIXINV}.dat
BCP_QRY="select a.* from BSAR..TTECLEDA_${TYPTAB} a, BREF..TBATCHSSD b
         where a.SSD_CF=b.SSD_CF
         and   b.BATCHUSER_CF = suser_name()"
BCP

NSTEP=${NJOB}_15
#-----------------------------------------------------------------
LIBEL="delete ${DARCH}/${NJOB}_${SRV}_TTECLEDA_${TYPTAB}_${SUFFIXINV}.dat.gz"
RMFIL "${DARCH}/${NJOB}_${SRV}_TTECLEDA_${TYPTAB}_${SUFFIXINV}.dat.gz"

NSTEP=${NJOB}_20
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip ${DARCH}/${NJOB}_${SRV}_TTECLEDA_${TYPTAB}_${SUFFIXINV}.dat"
EXECKSH_MODE=P
EXECKSH "gzip ${DARCH}/${NJOB}_${SRV}_TTECLEDA_${TYPTAB}_${SUFFIXINV}.dat"

#[003]
NSTEP=${NJOB}_30
# Begin BCP OUT
#-----------------------------------------------------------------
LIBEL="BCP OUT of table BSAR..TTCLEDR"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DARCH}/${NJOB}_${SRV}_TTECLEDR_${TYPTAB}_${SUFFIXINV}.dat
BCP_QRY="select a.* from BSAR..TTECLEDR_${TYPTAB} a, BREF..TBATCHSSD b
         where a.SSD_CF=b.SSD_CF
         and   b.BATCHUSER_CF = suser_name()"
BCP

NSTEP=${NJOB}_35
#-----------------------------------------------------------------
LIBEL="delete ${DARCH}/${NJOB}_${SRV}_TTECLEDR_${TYPTAB}_${SUFFIXINV}.dat.gz"
RMFIL "${DARCH}/${NJOB}_${SRV}_TTECLEDR_${TYPTAB}_${SUFFIXINV}.dat.gz"

NSTEP=${NJOB}_40
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip ${DARCH}/${NJOB}_${SRV}_TTECLEDR_${TYPTAB}_${SUFFIXINV}.dat"
EXECKSH_MODE=P
EXECKSH "gzip ${DARCH}/${NJOB}_${SRV}_TTECLEDR_${TYPTAB}_${SUFFIXINV}.dat"

#[003]
NSTEP=${NJOB}_50
# Begin BCP OUT
#-----------------------------------------------------------------
LIBEL="BCP OUT of table BSAR..TSEGSTAT"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DARCH}/${NJOB}_${SRV}_TSEGSTAT_${TYPTAB}_${SUFFIXINV}.dat
BCP_QRY="select a.* from BSAR..TSEGSTAT_${TYPTAB} a, BREF..TBATCHSSD b
         where a.SSD_CF=b.SSD_CF
         and   b.BATCHUSER_CF = suser_name()"
BCP

NSTEP=${NJOB}_55
#-----------------------------------------------------------------
LIBEL="delete ${DARCH}/${NJOB}_${SRV}_TSEGSTAT_${TYPTAB}_${SUFFIXINV}.dat.gz"
RMFIL "${DARCH}/${NJOB}_${SRV}_TSEGSTAT_${TYPTAB}_${SUFFIXINV}.dat.gz"

NSTEP=${NJOB}_60
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip ${DARCH}/${NJOB}_${SRV}_TSEGSTAT_${TYPTAB}_${SUFFIXINV}.dat"
EXECKSH_MODE=P
EXECKSH "gzip ${DARCH}/${NJOB}_${SRV}_TSEGSTAT_${TYPTAB}_${SUFFIXINV}.dat"

#[003]
NSTEP=${NJOB}_70
# Begin BCP OUT
#-----------------------------------------------------------------
LIBEL="BCP OUT of table BSAR..TCTRSTAT"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DARCH}/${NJOB}_${SRV}_TCTRSTAT_${TYPTAB}_${SUFFIXINV}.dat
BCP_QRY="select a.* from BSAR..TCTRSTAT_${TYPTAB} a, BREF..TBATCHSSD b
         where a.SSD_CF=b.SSD_CF
         and   b.BATCHUSER_CF = suser_name()"
BCP

NSTEP=${NJOB}_75
#-----------------------------------------------------------------
LIBEL="delete ${DARCH}/${NJOB}_${SRV}_TCTRSTAT_${TYPTAB}_${SUFFIXINV}.dat.gz"
RMFIL "${DARCH}/${NJOB}_${SRV}_TCTRSTAT_${TYPTAB}_${SUFFIXINV}.dat.gz"

NSTEP=${NJOB}_80
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip ${DARCH}/${NJOB}_${SRV}_TCTRSTAT_${TYPTAB}_${SUFFIXINV}.dat"
EXECKSH_MODE=P
EXECKSH "gzip ${DARCH}/${NJOB}_${SRV}_TCTRSTAT_${TYPTAB}_${SUFFIXINV}.dat"

#[003]
NSTEP=${NJOB}_90
# Begin BCP OUT
#-----------------------------------------------------------------
LIBEL="BCP OUT of table BSAR..TTECLEDRSNEM"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DARCH}/${NJOB}_${SRV}_TTECLEDRSNEM_${TYPTAB}_${SUFFIXINV}.dat
BCP_QRY="select a.* from BSAR..TTECLEDRSNEM_${TYPTAB} a, BREF..TBATCHSSD b
         where a.SSD_CF=b.SSD_CF
         and   b.BATCHUSER_CF = suser_name()"
BCP

NSTEP=${NJOB}_95
#-----------------------------------------------------------------
LIBEL="delete ${DARCH}/${NJOB}_${SRV}_TTECLEDRSNEM_${TYPTAB}_${SUFFIXINV}.dat.gz"
RMFIL "${DARCH}/${NJOB}_${SRV}_TTECLEDRSNEM_${TYPTAB}_${SUFFIXINV}.dat.gz"

NSTEP=${NJOB}_100
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip ${DARCH}/${NJOB}_${SRV}_TTECLEDRSNEM_${TYPTAB}_${SUFFIXINV}.dat"
EXECKSH_MODE=P
EXECKSH "gzip ${DARCH}/${NJOB}_${SRV}_TTECLEDRSNEM_${TYPTAB}_${SUFFIXINV}.dat"

#[003]
NSTEP=${NJOB}_110
# Begin BCP OUT
#-----------------------------------------------------------------
LIBEL="BCP OUT of table BSAR..TTECLEDASNEM"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DARCH}/${NJOB}_${SRV}_TTECLEDASNEM_${TYPTAB}_${SUFFIXINV}.dat
BCP_QRY="select a.* from BSAR..TTECLEDASNEM_${TYPTAB} a, BREF..TBATCHSSD b
         where a.SSD_CF=b.SSD_CF
         and   b.BATCHUSER_CF = suser_name()"
BCP

NSTEP=${NJOB}_115
#-----------------------------------------------------------------
LIBEL="delete ${DARCH}/${NJOB}_${SRV}_TTECLEDASNEM_${TYPTAB}_${SUFFIXINV}.dat.gz"
RMFIL "${DARCH}/${NJOB}_${SRV}_TTECLEDASNEM_${TYPTAB}_${SUFFIXINV}.dat.gz"

NSTEP=${NJOB}_120
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip ${DARCH}/${NJOB}_${SRV}_TTECLEDASNEM_${TYPTAB}_${SUFFIXINV}.dat"
EXECKSH_MODE=P
EXECKSH "gzip ${DARCH}/${NJOB}_${SRV}_TTECLEDASNEM_${TYPTAB}_${SUFFIXINV}.dat"

if [ "${NCHAIN}" = "${ENV_PREFIX}_ESID9990" ]
then
	# On archive la table du trimestre precedent pour prendre en compte les donnees du dernier Conso EBS
	#[001] [003] [005]
	NSTEP=${NJOB}_130
	# Begin BCP OUT
	#-----------------------------------------------------------------
	LIBEL="BCP OUT of table BSAR..TTECLEDSII"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DARCH}/${NJOB}_${SRV}_TTECLEDSII_${SUFFTABLE}_${SUFFIXPOST}.dat
	BCP_QRY="select a.* from BSAR..TTECLEDSII_${SUFFTABLE} a, BREF..TBATCHSSD b
	         where a.SSD_CF=b.SSD_CF
	         and   b.BATCHUSER_CF = suser_name()"
	BCP
	
	#[005]
	NSTEP=${NJOB}_135
	#-----------------------------------------------------------------
	LIBEL="delete ${DARCH}/${NJOB}_${SRV}_TTECLEDSII_${SUFFTABLE}_${SUFFIXPOST}.dat.gz"
	RMFIL "${DARCH}/${NJOB}_${SRV}_TTECLEDSII_${SUFFTABLE}_${SUFFIXPOST}.dat.gz"
	
	#[005]
	NSTEP=${NJOB}_140
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Gzip ${DARCH}/${NJOB}_${SRV}_TTECLEDSII_${SUFFTABLE}_${SUFFIXPOST}.dat"
	EXECKSH_MODE=P
	EXECKSH "gzip ${DARCH}/${NJOB}_${SRV}_TTECLEDSII_${SUFFTABLE}_${SUFFIXPOST}.dat"
fi

# End of job
#-----------------------------------------------------------------
JOBEND
