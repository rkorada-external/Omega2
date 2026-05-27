#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES (PORTEFEUILLES)
# nom du script SHELL:            ESTD3001.cmd
# revision:                       $Revision: 1.3 $
# date de creation:               10/02/2009
# auteur:                         J.Ribot
# references des specifications : :spot:16765
#-----------------------------------------------------------------------------
# description
#
# extraction des fichiers gt
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#  05/06/2009  Roger Cassis    :spot:17532 -  Si statuts pas positionnes correctement, arret de la chaine
#  03/12/2009  Roger Cassis    :spot:18415 - Mise à jour parametres plus utilises - Ajout transfert fichier Plan_Vie.
#[003] 19/08/2015 Roger Cassis :spot:29223 Agrandissement valeur mini des enregistrements dans tri step25
#[004] 03/11/2015 Roger Cassis :spot:29514 - Correction parametre transmis a ESTD3051 : VIE_B au lieu de TRANSFESB
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Entry parameters
VIE_B=${1}

# Initialization of the Job
JOBINIT

NSTEP=${NJOB}_00
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Check if data to transfer exist"
ISQL_BASE="BTRT"
ISQL_QRY="set rowcount 2
          select * from BTRT..TRFCROSSREF
          where  (TRFACCSTS_CT = 16 and TRFSTS_CT = 2) OR (TRFACCSTS_CT = 46 and TRFSTS_CT = 14)
          UNION
          select * from BFAC..TRFCROSSREF
          where  (TRFACCSTS_CT = 16 and TRFSTS_CT = 2) OR (TRFACCSTS_CT = 46 and TRFSTS_CT = 14)"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_NOWARNING="YES"
ISQL_RES

if [ ! -s ${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat ]
then
  ECHO_LOG "---> No Data to process because Crossref statuts are not set right - Stop processing"
  JOBEND
fi

if [ ${TRANSFESB} = "1" ]             # transfert etablissement
then

	NSTEP=${NJOB}_01
	# Begin C Program
	#------------------------------------------------------------------------------
	LIBEL="Extraction des tables"
	PRG=ESTX7016
	export ${PRG}_O1=${DFILT}/${NJOB}_05_${IB}_ESTX7005_CTRCROSSREF.dat
	export ${PRG}_O2=${DFILT}/${NJOB}_05_${IB}_ESTX7005_FACCROSSREF.dat
	EXECPRG

else

	NSTEP=${NJOB}_05
	# Begin C Program
	#------------------------------------------------------------------------------
	LIBEL="Extraction des tables"
	PRG=ESTX7005
	export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRCROSSREF.dat
	export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FACCROSSREF.dat
	EXECPRG

fi

NSTEP=${NJOB}_07
# Sort binary file
#------------------------------------------------------------------------------
LIBEL="Sort of binary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_ESTX7005_CTRCROSSREF.dat fixed 32"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_ESTX7005_FACCROSSREF.dat fixed 32"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TRTFACCROSSREF.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
   CTR_NF	1 CHAR 10,
   SSD_CF	11 UINTEGER 1,
   DESTCTR_NF	12 CHAR 10,
   DESTSSD_CF 22 UINTEGER 1,
   ACCESB_CF  23 UINTEGER 1,
   LSTUPD_D	24 CHAR 9
/KEYS
   CTR_NF,
   SSD_CF,
   DESTCTR_NF,
   DESTSSD_CF,
   ACCESB_CF
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from ${PCH}ESIX7000_GTA.dat"
PRG=ESTX7007
export ${PRG}_I1=${DFILP}/${PCH}ESIX7000_GTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_SORT_TRTFACCROSSREF.dat
export ${PRG}_O1=${DFILT}/${NJOB}_GTA_TRANSFP.dat
EXECPRG

NSTEP=${NJOB}_15
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from ${PCH}ESIX7000_CURGTA.dat"
PRG=ESTX7007
export ${PRG}_I1=${DFILP}/${PCH}ESIX7000_CURGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_SORT_TRTFACCROSSREF.dat
export ${PRG}_O1=${DFILT}/${NJOB}_CURGTA_TRANSFP.dat
EXECPRG

if [ ${VIE_B} = "1" ]             # Traitement Vie
then

	NSTEP=${NJOB}_20
	# Begin isql-bcpmulti
	#---------------------------------------------------------------------
	LIBEL="Extract data from Trfcrossref for Lifstarep_plan file"
	BCP_WAY="OUT"; BCP_VER="+"
	BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TRTFACCROSSREF.dat
	BCP_QRY="select SSD_CF,CTR_NF,DESTSSD_CF,DESTCTR_NF from BTRT..TRFCROSSREF
	          where  (TRFACCSTS_CT = 16 and TRFSTS_CT = 2)
	          UNION
	          select SSD_CF,CTR_NF,DESTSSD_CF,DESTCTR_NF from BFAC..TRFCROSSREF
	          where  (TRFACCSTS_CT = 16 and TRFSTS_CT = 2)
	          order by CTR_NF"
	BCP

	#[003]
	NSTEP=${NJOB}_25
	# Sort Tlifstarep Plan file
	#------------------------------------------------------------------------------
	LIBEL="Sort Tlifstarep Plan file"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILP}/${ENV_PREFIX}_STAD1520_LIFSTAREP_PLAN.dat 512"
	SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFSTAREP_PLAN.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
   CTR_NF   3:1 - 3:
/KEYS
   CTR_NF
exit
EOF
	SORT

	NSTEP=${NJOB}_30
	# Begin C Program
	#------------------------------------------------------------------------------
	LIBEL="Generation of TRANSFERTS from P_STAD1520_LIFSTAREP_PLAN.dat"
	PRG=ESTM7020
	export ${PRG}_PRM=${FPRM}
	export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_BCP_TRTFACCROSSREF.dat
	export ${PRG}_I2=${DFILT}/${NJOB}_25_${IB}_SORT_LIFSTAREP_PLAN.dat
	export ${PRG}_O1=${DFILT}/${NJOB}_LIFSTAREP_PLAN_TRANSFP.dat
	EXECPRG

fi

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_35
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

