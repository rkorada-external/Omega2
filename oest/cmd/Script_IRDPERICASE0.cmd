#!/bin/ksh
#=============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


CHAININIT CNLD0030 $DENV/CNLD0030.env


# Get the parameters
export EST_PARAM=${DFILP}/${ENV_PREFIX}_ESCJ0000_IFRS17_PARM2.dat
set `GETPRM ${EST_PARAM}`

SSDs0=$1
SSDs=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
ICLODAT_D=$7
CLODAT_D=$8
CLOTYP_CT=${10}
SEGTYP_CT=${11}
SSDDEL_LL=${12}
LSTCLODAT_LL=${13}
SSDVRS_LL=${14}
INVCONSO_D=${21}
CONSOYEA=${22}
CONSOMTH=${23}



NJOB=${ENV_PREFIX}_CNLD0030_CNLD0031



# Initialization of the Job
JOBINIT

echo "Starting $0 " > $FLOG
date >> $FLOG 
SEGTYP_CT=A
SSD_CF=0
CRE_D=`date +"%Y%m%d" `
EST_IRDPERICASE0=${DFILP}/${ENV_PREFIX}_ESPT0000_IRDPERICASE0.dat

NSTEP=${NJOB}_50
#Generation of IRDPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRDPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_O.dat
BCP_QRY="execute BEST..PsSECTION_08 '${SEGTYP_CT}', ${SSD_CF}"
BCP               

NSTEP=${NJOB}_55
#-----------------------------------------------------------------------------
LIBEL="Current Sort of IRDPERICASE Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_BCP_PERICASE_O.dat 1000 1"
SORT_O="${EST_IRDPERICASE0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT             

ls -ltr $EST_IRDPERICASE0 >> $FLOG

echo "End $0 status=$?" >> $FLOG