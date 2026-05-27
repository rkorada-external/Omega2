#!/bin/ksh
#=================================================================================================================================
# Application name              : Management of OPENING / CLOSING Position => Extractions
# Batch name                    : STAD7501.cmd
# Revision                      : $Revision:  $
# Creation date                 : 26/08/2019
# Author                        : L. Wernert
# Specification reference       : http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-908624
# Technical reference           : http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BJTD-CLO-908351
#---------------------------------------------------------------------------------------------------------------------------------
# Description :	
#    Extractions, treatments and data archiving in history tables
#
# Entry parameters :
#    BALSHTYEA_NF
#    BALSHTMTH_NF
#    CRE_D
#    RUN_TYPE
#
#---------------------------------------------------------------------------------------------------------------------------------
# Modification history :
# <modification> <JJ/MM/AAAA> <author> <spot> <description>
# [001] XX/XX/XXXX XXXX XXX XXXX
#
#---------------------------------------------------------------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialise JOB
JOBINIT

# Entry parameters
set -x
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3
RUN_TYPE=$4
set +x


PARALLEL_INIT 2
	NSTEP=${NJOB}_10
	#------------------------------------------------------------------------------
	# Extract yearly estimates history file
	#------------------------------------------------------------------------------
	LIBEL="Getting yearly positions that are the latest for ${BALSHTYEA_NF}/${BALSHTMTH_NF}"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILT}/${NSTEP}_${IB}_FLIFEST_H.dat
	BCP_QRY="execute BEST..PsLIFEST_H_01 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
	PARALLEL BCP

	NSTEP=${NJOB}_20
	#------------------------------------------------------------------------------
	# Extract quarterly estimates history file
	#------------------------------------------------------------------------------
	LIBEL="Getting Quarterly positions that are the latest for ${BALSHTYEA_NF}/${BALSHTMTH_NF}"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILT}/${NSTEP}_${IB}_FLIFESTD_H.dat
	BCP_QRY="execute BEST..PsLIFESTD_H_01 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
	PARALLEL BCP
PARALLEL_END


set -x
gzip -c ${DFILT}/${NJOB}_10_${IB}_FLIFEST_H.dat  > ${DARCH}/${ENV_PREFIX}_STAD7501_FLIFEST_H_${BALSHTYEA_NF}_${CRE_D}.dat.gz
gzip -c ${DFILT}/${NJOB}_20_${IB}_FLIFESTD_H.dat > ${DARCH}/${ENV_PREFIX}_STAD7501_FLIFESTD_H_${BALSHTYEA_NF}_${CRE_D}.dat.gz
set +x


NSTEP=${NJOB}_30
#Deletion of Table BEST..TLIFEST_H
#-----------------------------------------------------------------------------
LIBEL="Delete if exist into BEST..TLIFEST_H for ${BALSHTYEA_NF}/${BALSHTMTH_NF}"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST..PdLIFEST_H_01 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_PdLIFEST_H_01.log
ISQL


NSTEP=${NJOB}_40
#Deletion of Table BEST..TLIFESTD_H
#-----------------------------------------------------------------------------
LIBEL="Delete if exist into BEST..TLIFESTD_H for ${BALSHTYEA_NF}/${BALSHTMTH_NF}"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST..PdLIFESTD_H_01 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_PdLIFESTD_H_01.log
ISQL


PARALLEL_INIT 2
	NSTEP=${NJOB}_50
	#------------------------------------------------------------------------------
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Loading ${BALSHTYEA_NF} Balance Sheet History data into TLIFEST_H table"
	BCP_WAY="IN"
	BCP_VER=""
	BCP_I=${DFILT}/${NJOB}_10_${IB}_FLIFEST_H.dat
	BCP_TABLE="BEST..TLIFEST_H"
	PARALLEL BCP

	NSTEP=${NJOB}_60
	#------------------------------------------------------------------------------
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Loading ${BALSHTYEA_NF} Balance Sheet History data into TLIFESTD_H table"
	BCP_WAY="IN"
	BCP_VER=""
	BCP_I=${DFILT}/${NJOB}_20_${IB}_FLIFESTD_H.dat
	BCP_TABLE="BEST..TLIFESTD_H"
	PARALLEL BCP
PARALLEL_END


if [ ${RUN_TYPE} == "Y" ]; then
  PARALLEL_INIT 2
    NSTEP=${NJOB}_70
    #------------------------------------------------------------------------------
    # Extract EST_LIFESTY0
    #------------------------------------------------------------------------------
    LIBEL="Current Generation of Yearly Estimates File"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O="${EST_FLIFESTY}"
    BCP_QRY="execute BEST..PsLIFEST_09 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}'"
  PARALLEL BCP

    NSTEP=${NJOB}_80
    #------------------------------------------------------------------------------
    # Extract EST_LIFESTQ0
    #------------------------------------------------------------------------------
    LIBEL="Current Generation of Quarterly Estimates File"
    BCP_WAY="OUT"
    BCP_VER="+"
    BCP_O="${EST_FLIFESTQ}"
    BCP_QRY="execute BEST..PsLIFESTD_01 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}'"
	PARALLEL BCP
  PARALLEL_END


  NSTEP=${NJOB}_90
  #------------------------------------------------------------------------------
  # Save full last month from BEST..TLIFEST
  #------------------------------------------------------------------------------
  LIBEL="Save full last month from BEST..TLIFEST"
  BCP_WAY="OUT"
  BCP_VER="+"
  BCP_O=${DFILT}/${NSTEP}_${IB}_FULL_LIFEST_MTH.dat
  BCP_QRY="SELECT * 
    FROM BEST..TLIFEST a, BREF..TBATCHSSD T
    WHERE a.BALSHEY_NF = ${BALSHTYEA_NF}
    AND   a.BALSHTMTH_NF = ${BALSHTMTH_NF}
    AND   a.SSD_CF = T.SSD_CF
    AND   T.BATCHUSER_CF = suser_name()"
  BCP

  set -x
  gzip -c ${DFILT}/${NJOB}_90_${IB}_FULL_LIFEST_MTH.dat > ${DARCH}/${ENV_PREFIX}_STAD7501_FULL_LIFEST_MTH_${BALSHTYEA_NF}_${BALSHTMTH_NF}_${CRE_D}.dat.gz
  gzip -c ${EST_FLIFESTY} > ${DARCH}/${ENV_PREFIX}_STAD7500_FLIFESTY0_${BALSHTYEA_NF}_${CRE_D}.dat.gz
  gzip -c ${EST_FLIFESTQ} > ${DARCH}/${ENV_PREFIX}_STAD7500_FLIFESTQ0_${BALSHTYEA_NF}_${CRE_D}.dat.gz
  set +x
fi


NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
# Erase temporary files
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
