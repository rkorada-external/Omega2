#!/bin/ksh
#=============================================================================
# maj de l'application:           ESTIMATIONS - TRANSFERT INTER-SITES
# nom du script SHELL:            ESTD3001.cmd
# revision:                       $Revision: 1.5 $
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
#  05/06/2009   Roger Cassis      :spot:17532 -  Si statuts pas positionnes correctement, arret de la chaine
#  27/11/2009   R. Cassis         :spot:18415 -> Genere mouvements avec montants a zero dans best..tlifest pour contrats Vie : parm VIE_B
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Entry parameters
BALSHEY_NF=${1}
BALSHTMTH_NF=${2}
TRANSFESB=${3}
VIE_B=${4}

# Initialization of the Job
JOBINIT

ECHO_LOG "=> VIE_B......... = ${VIE_B}"  2>&1 | ${TEE}

NSTEP=${NJOB}_00
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Check if data to transfer exist"
ISQL_BASE="BTRT"
ISQL_QRY="set rowcount 2
          select * from BTRT..TRFCROSSREF
          where  (TRFACCSTS_CT = 14 and TRFSTS_CT = 2) OR (TRFACCSTS_CT = 44 and TRFSTS_CT = 14)
          UNION
          select * from BFAC..TRFCROSSREF
          where  (TRFACCSTS_CT = 14 and TRFSTS_CT = 2) OR (TRFACCSTS_CT = 44 and TRFSTS_CT = 14)"
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
	PRG=ESTX7014
	export ${PRG}_O1=${DFILT}/${NJOB}_05_${IB}_ESTX7004_CTRCROSSREF.dat
	export ${PRG}_O2=${DFILT}/${NJOB}_05_${IB}_ESTX7004_FACCROSSREF.dat
	EXECPRG

else

	NSTEP=${NJOB}_05
	# Begin C Program
	#------------------------------------------------------------------------------
	LIBEL="Extraction des tables"
	PRG=ESTX7004
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
SORT_I="${DFILT}/${NJOB}_05_${IB}_ESTX7004_CTRCROSSREF.dat fixed 32"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_ESTX7004_FACCROSSREF.dat fixed 32"
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

NSTEP=${NJOB}_08
#
#-----------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
LIBEL="Sort GTA Files "
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/${PCH}ESIX7000_GTA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTA.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:
/KEYS CTR_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from ${PCH}ESIX7000_GTA.dat"
PRG=ESTX7007
export ${PRG}_I1=${DFILT}/${NJOB}_08_${IB}_SORT_GTA.dat
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

NSTEP=${NJOB}_20
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of TRANSFERTS from ${PCH}ESIX7000_ARCSTATGTA.dat"
PRG=ESTX7007
export ${PRG}_I1=${DFILP}/${PCH}ESIX7000_ARCSTATGTA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_SORT_TRTFACCROSSREF.dat
export ${PRG}_O1=${DFILT}/${NJOB}_ARCSTATGTA_TRANSFP.dat
EXECPRG


if [ ${TRANSFESB} = "0" ]             # pas transfert etablissement
then

	if [ "${VIE_B}" = "1" ]
	then
		NSTEP=${NJOB}_24
		# Begin ISQL
		#-----------------------------------------------------------------
		LIBEL="Create new records into best..tlifest with zero amount for Life contracts"
		ISQL_BASE="BEST"
		ISQL_QRY="execute BEST..PiLIFEST_04 ${BALSHEY_NF}, ${BALSHTMTH_NF} with recompile"
		ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
		ISQL
	fi

	NSTEP=${NJOB}_25
	#Generation of TACCSTAT File
	#-----------------------------------------------------------------------------
	LIBEL="Current Generation of TACCSTAT File..."
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O="${DFILT}/${NJOB}_TACCSTAT_TRANSFP.dat"
	BCP_QRY="select a.destssd_cf, a.destaccesb_cf, a.destctr_nf, b.end_nt, b.sec_nf, b.uwy_nf,
	                b.uw_nt, b.cur_cf, b.dettrs_cf, b.amt_m
            from btrt..trfcrossref a, best..taccstat b
	         where  a.ctr_nf = b.ctr_nf  AND a.TRFSTS_CT = 2  AND a.TRFACCSTS_CT = 14
	         select a.destssd_cf, a.destaccesb_cf, a.destctr_nf, b.end_nt, b.sec_nf, b.uwy_nf,
	                b.uw_nt, b.cur_cf, b.dettrs_cf, b.amt_m
            from bfac..trfcrossref a, best..taccstat b
	         where  a.ctr_nf = b.ctr_nf  AND a.TRFSTS_CT = 2  AND a.TRFACCSTS_CT = 14"
	BCP

	NSTEP=${NJOB}_30
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 16 apres TRANSFERTS"
	ISQL_BASE="BTRT"
	ISQL_QRY="update BTRT..TRFCROSSREF
	            set TRFACCSTS_CT = 16
	          from BTRT..TRFCROSSREF where TRFSTS_CT = 2  AND TRFACCSTS_CT = 14"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

	NSTEP=${NJOB}_35
	# Begin ISQL
	#------------------------------------------------------------------------------
	LIBEL="Update TRFACCSTS_CT = 16 apres TRANSFERTS"
	ISQL_BASE="BFAC"
	ISQL_QRY="update BFAC..TRFCROSSREF
	             set TRFACCSTS_CT = 16
	           from BFAC..TRFCROSSREF where TRFSTS_CT = 2  AND TRFACCSTS_CT = 14"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
	ISQL

fi

JOBEND

