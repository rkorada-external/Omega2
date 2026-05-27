#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESF4081.cmd
# date de creation              : 02/04/2025
# auteur                        : S. Behague
#-----------------------------------------------------------------------------
# description:              
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================

#[001]  02/04/2025  S.Behague  : spira 111789
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd 
. ${DUTI}/fctftp.cmd


#set -x

#[006]
# Get input parameters

CRE_D=${PARM_CRE_D}


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_10
# Check AE 
#------------------------------------------------------------------------------
#LIBEL="Check AE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_POSTING} 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_POSTING_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
				TRN_NT 		   103:1 - 103:,
				LOB_CF		    45:1 -  45:
/CONDITION AE (TRN_NT != "" AND TRN_NT != "0")
/OUTFILE ${SORT_O}
/INCLUDE AE
exit
EOF
SORT


NSTEP=${NJOB}_20
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Extract TACCSUPSAP"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCPOUT_TACCSUPSAP.dat
BCP_QRY="exec BEST..PsACCSUPSAP_01 '${PARM_BALSHTYEA_NF}', ${PARM_BALSHTMTH_NF}"
BCP


NSTEP=${NJOB}_30
#Get TRN present in TACCSUP SAP and SAP POSTING file
#------------------------------------------------------------------------------------
LIBEL="Get TRN present in TACCSUP SAP and SAP POSTING file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FTECLEDA_POSTING_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TACCSUPSAP_TO_UPDATE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
		TRNSAP_NT         1:1 -   1:,
		POSTING_D       110:1 - 110:,
		TRNPOSTING_NT   103:1 - 103:
/JOINKEYS
        TRNPOSTING_NT
/INFILE ${DFILT}/${NJOB}_20_${IB}_BCPOUT_TACCSUPSAP.dat 1000 1 "~"
/JOINKEYS
        TRNSAP_NT
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:TRNPOSTING_NT, LEFTSIDE:POSTING_D
exit
EOF
SORT


NSTEP=${NJOB}_40
# Begin BCP IN
#------------------------------------------------------------------------------
LIBEL="Import the input file into the table: BTRAV..TACCSUPSAPPOS"
BCP_WAY="IN"; BCP_VER=""
BCP_TRUNCATE=YES
BCP_I=${DFILT}/${NJOB}_30_${IB}_TACCSUPSAP_TO_UPDATE.dat
BCP_TABLE="BTRAV..TACCSUPSAPPOS"
BCP


NSTEP=${NJOB}_50
# Begin Update of TACCSUPSAP
#------------------------------------------------------------------------------
LIBEL="Begin Update of TACCSUPSAP"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PuACCSUPSAP_01 "
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_PROCEDURE_PuACCSUPSAP_01.log
ISQL


JOBEND

