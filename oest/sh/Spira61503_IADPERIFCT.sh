#!/bin/ksh
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

NJOB=${ENV_PREFIX}_CNLD0030_CNLD0031

# Initialization of the Job
JOBINIT

SEGTYP_CT=A
SSD_CF=0
CRE_D=`date +"%Y%m%d" `
EST_IADPERIFCT=${DFILP}/${ENV_PREFIX}_ESPT0000_IADPERIFCT.dat

NSTEP=${NJOB}_15
#Download to the XADPERIFCT Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCT perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIFCT_O.dat
BCP_QRY="execute BEST..PsSECTION_05 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}' with recompile"
BCP


NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Current Sort of XADPERIFCT Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_15_${IB}_BCP_PERIFCT_O.dat
SORT_O="${EST_IADPERIFCT} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: EN,
        SEC_NF 3:1 - 3: EN,
        UWY_NF 4:1 - 4: EN,
        UW_NT 5:1 - 5: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

JOBEND

