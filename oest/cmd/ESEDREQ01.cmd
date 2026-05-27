#!/bin/ksh
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd

CHAININIT $0 $DENV/CNLD0030.env

. ${DENV}/EST2.env
set `GETPRM ${EST_PARAM}`
SSDs0=$1
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CRE_D=$5
DBCLO_D=$6
CLODAT_D=$8
BOOKING_D=${18}
PSTOMGEN_D=${19}
ENCONSO_D=${20}
INVCONSO_D=${21}
CONSOYEA=${22}
EBSPSTOMGEN_D=${29}


# Initialization of the Job
JOBINIT



 

EST_FCTRFWH=${DFILP}/${PCH}ESPD0060_FCTRFWH.dat
EST_FSEGPATTERNFWH=${DFILP}/${PCH}ESPD0060_FSEGPATTERNFWH.dat
EST_FPRSMAP=${DFILP}/${PCH}ESPT0000_FPRSMAP.dat


NSTEP=${NJOB}_10
#Generate the list of contract/section/UWY/UWY order/Endorsement  with signed fund held
#-----------------------------------------------------------------------------
LIBEL="Generation of the list of contracts with signed fund held"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCTRFWH}
BCP_QRY="execute BEST..PsACCRETTRN_FWH_01 '${TYPEINV}', '${INVCONSO_D}'"
BCP


NSTEP=${NJOB}_15
#Generate data having PATCAT_CT= FWH  and PATTYP_CT = RAT and the patterns necessary for the calculation of fund held investment income 
#-----------------------------------------------------------------------------
LIBEL="Generation of data for calculation of fund held investment income"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FSEGPATTERNFWH}
BCP_QRY="execute BEST..PsFPATTERNFWH_01 '${CRE_D}', 'CSF', ${CONSOYEA}, '${TYPEINV}', '${INVCONSO_D}'"
BCP

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Read date in T_TMAPPING table"
PRG=ESTX0009
export ${PRG}_O1=${EST_FPRSMAP}
EXECPRG	  

NSTEP=${NJOB}_25
# Begin rm
#------------------------------------------------------------------------------
LIBEL="Step to remove temporary files"
#RMFIL "${DFILT}/${NJOB}_${IB}_TMPPERM_EST*.dat"


JOBEND

CHAINEND
