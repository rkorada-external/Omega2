#!/bin/ksh
#=================================================================================================================================
# Application name              : Management of OPENING / CLOSING Position => Annual clean-up
# Batch name                    : STAD7503.cmd
# Revision                      : $Revision:  $
# Creation date                 : 26/08/2019
# Author                        : L. Wernert
# Specification reference       : http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BPR-EST-908624
# Technical reference           : http://dcvprdxwikiu/xwiki/wiki/omega/view/DEV/BJTD-CLO-908803
#---------------------------------------------------------------------------------------------------------------------------------
# Description :	
#    Annual clean-up (TLIFDRI/TLIFDRID, TLIFMOD/TLIFMOD2, TLIFEST_H/TLIFESTD_H, TLIFPEN)
#
# Entry parameters :
#    BALSHTYEA_NF
#
#---------------------------------------------------------------------------------------------------------------------------------
# Modification history :
# <modification> <JJ/MM/AAAA> <author> <spot> <description>
# [001]  08/03/2021 L. BEL  70816:Purge estimate tables
#
#---------------------------------------------------------------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

# Entry parameters
set -x
BALSHTYEA_NF=$1
set +x

# Initialise JOB
JOBINIT


NSTEP=${NJOB}_05A
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Get list of balance sheet month of ${BALSHTYEA_NF} from TLIFEST"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_LISTE_BALSHMTH_LIFEST_O1.dat         
BCP_QRY="select distinct a.BALSHTMTH_NF from BEST..TLIFEST a 
          where a.BALSHEY_NF = ${BALSHTYEA_NF}
          and a.SSD_CF in (select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF = suser_name())
          order by a.BALSHTMTH_NF"
BCP


NSTEP=${NJOB}_05B
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Get list of balance sheet month of ${BALSHTYEA_NF} from TLIFEST_H"
BCP_WAY="OUT"
BCP_VER="+" 
BCP_O=${DFILT}/${NSTEP}_${IB}_LISTE_BALSHMTH_LIFESTH_O1.dat         
BCP_QRY="select distinct a.BALSHTMTH_NF from BEST..TLIFEST_H a
          where a.BALSHEY_NF = ${BALSHTYEA_NF}
          and a.SSD_CF in (select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF = suser_name())
          order by a.BALSHTMTH_NF"
BCP


# Check if diff 
#------------------------------------------------------------------------------
ISDIFF=$(grep -Fxvf ${DFILT}/${NJOB}_05B_${IB}_LISTE_BALSHMTH_LIFESTH_O1.dat ${DFILT}/${NJOB}_05A_${IB}_LISTE_BALSHMTH_LIFEST_O1.dat)
ISDIFF=`echo ${ISDIFF} | sed 's/^ *//'`

if [ "${ISDIFF}" != "" ]; then
	ISDIFF=$(echo "${ISDIFF}" | tr '\n' ',' | sed 's/, *$//')
	echo "WORNING : the BALSHTMTH_NF in [${ISDIFF}] are not present in TLIFEST_H table. "
	ISDIFF=(`echo ${ISDIFF} | sed 's/, */ /g' | sed 's/^ *//'`)
	for BALSHTMTH_NF in ${ISDIFF[@]}; do
	  echo "BALSHTMTH_NF ===> $BALSHTMTH_NF"
	  NSTEP=${NJOB}_10A
	  #------------------------------------------------------------------------------
	  # Extract yearly estimates history file
	  #------------------------------------------------------------------------------
	  LIBEL="Getting yearly positions that are the latest for ${BALSHTYEA_NF}/${BALSHTMTH_NF}"
	  BCP_WAY="OUT"
	  BCP_VER="+"
	  BCP_O=${DFILT}/${NSTEP}_${IB}_FLIFEST_H_${BALSHTYEA_NF}${BALSHTMTH_NF}.dat
	  BCP_QRY="execute BEST..PsLIFEST_H_01 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
	  BCP

	  NSTEP=${NJOB}_10B
	  #Deletion of Table BEST..TLIFEST_H
	  #-----------------------------------------------------------------------------
	  LIBEL="Delete if exist into BEST..TLIFEST_H for ${BALSHTYEA_NF}/${BALSHTMTH_NF}"
	  ISQL_BASE='BEST'
	  ISQL_QRY="execute BEST..PdLIFEST_H_01 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
	  ISQL_O=${DFILT}/${NSTEP}_${IB}_PdLIFEST_H_01.log
	  ISQL

	  NSTEP=${NJOB}_10C
	  #------------------------------------------------------------------------------
	  # Begin bcp
	  #------------------------------------------------------------------------------
	  LIBEL="Loading ${BALSHTYEA_NF} Balance Sheet History data into TLIFEST_H table"
	  BCP_WAY="IN"
	  BCP_VER=""
	  BCP_I=${DFILT}/${NJOB}_10A_${IB}_FLIFEST_H_${BALSHTYEA_NF}${BALSHTMTH_NF}.dat
	  BCP_TABLE="BEST..TLIFEST_H"
	  BCP
	done
fi


NSTEP=${NJOB}_10
# Clean-up TLIFEST all rows of current BALSHTYEA_NF
#------------------------------------------------------------------------------
LIBEL="Clean-up TLIFEST ${BALSHTYEA_NF}"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST..PdLIFEST_01 ${BALSHTYEA_NF}"
ISQL


NSTEP=${NJOB}_15A
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Get list of balance sheet month of ${BALSHTYEA_NF} from TLIFESTD"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_LISTE_BALSHMTH_LIFESTD_O1.dat         
BCP_QRY="select distinct a.BALSHTMTH_NF from BEST..TLIFESTD a
          where a.BALSHEY_NF = ${BALSHTYEA_NF}
          and a.SSD_CF in (select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF = suser_name())
          order by a.BALSHTMTH_NF"
BCP


NSTEP=${NJOB}_15B
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Get list of balance sheet month of ${BALSHTYEA_NF} from TLIFESTD_H"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_LISTE_BALSHMTH_LIFESTDH_O1.dat
BCP_QRY="select distinct a.BALSHTMTH_NF from BEST..TLIFESTD_H a
          where a.BALSHEY_NF = ${BALSHTYEA_NF}
          and a.SSD_CF in (select SSD_CF from BREF..TBATCHSSD where BATCHUSER_CF = suser_name())
          order by a.BALSHTMTH_NF"
BCP

# Check if diff 
#------------------------------------------------------------------------------
ISDIFFD=$(grep -Fxvf ${DFILT}/${NJOB}_15B_${IB}_LISTE_BALSHMTH_LIFESTDH_O1.dat ${DFILT}/${NJOB}_15A_${IB}_LISTE_BALSHMTH_LIFESTD_O1.dat)
ISDIFFD=`echo ${ISDIFFD} | sed 's/^ *//'`

if [ "${ISDIFFD}" != "" ]; then
	ISDIFFD=$(echo "${ISDIFFD}" | tr '\n' ',' | sed 's/, *$//')
	echo "WORNING : the BALSHTMTH_NF in [${ISDIFFD}] are not present in TLIFESTD_H table. "
	ISDIFFD=(`echo ${ISDIFFD} | sed 's/, */ /g' | sed 's/^ *//'`)
	for BALSHTMTH_NF in ${ISDIFFD[@]}; do
	  echo "BALSHTMTH_NF ===> $BALSHTMTH_NF"
	  NSTEP=${NJOB}_20A
	  #------------------------------------------------------------------------------
	  # Extract quarterly estimates history file
	  #------------------------------------------------------------------------------
	  LIBEL="Getting Quarterly positions that are the latest for ${BALSHTYEA_NF}/${BALSHTMTH_NF}"
	  BCP_WAY="OUT"
	  BCP_VER="+"
	  BCP_O=${DFILT}/${NSTEP}_${IB}_FLIFESTD_H_${BALSHTYEA_NF}${BALSHTMTH_NF}.dat
	  BCP_QRY="execute BEST..PsLIFESTD_H_01 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
	  BCP

	  NSTEP=${NJOB}_20B
	  #Deletion of Table BEST..TLIFESTD_H
	  #-----------------------------------------------------------------------------
	  LIBEL="Delete if exist into BEST..TLIFESTD_H for ${BALSHTYEA_NF}/${BALSHTMTH_NF}"
	  ISQL_BASE='BEST'
	  ISQL_QRY="execute BEST..PdLIFESTD_H_01 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
	  ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_PdLIFESTD_H_01.log
	  ISQL

	  NSTEP=${NJOB}_20C
	  #------------------------------------------------------------------------------
	  # Begin bcp
	  #------------------------------------------------------------------------------
	  LIBEL="Loading ${BALSHTYEA_NF} Balance Sheet History data into TLIFESTD_H table"
	  BCP_WAY="IN"
	  BCP_VER=""
	  BCP_I=${DFILT}/${NJOB}_20A_${IB}_FLIFESTD_H_${BALSHTYEA_NF}${BALSHTMTH_NF}.dat
	  BCP_TABLE="BEST..TLIFESTD_H"
	  BCP
	done
fi

NSTEP=${NJOB}_20
# Clean-up TLIFESTD all rows of current BALSHTYEA_NF
#------------------------------------------------------------------------------
LIBEL="Clean-up TLIFESTD ${BALSHTYEA_NF}"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST..PdLIFESTD_01 ${BALSHTYEA_NF}"
ISQL


NSTEP=${NJOB}_20
# Clean-up TLIFDRI
#------------------------------------------------------------------------------
LIBEL="Clean-up TLIFDRI"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST..PdLIFDRI_01 ${BALSHTYEA_NF}"
ISQL


NSTEP=${NJOB}_30
# Clean-up TLIFDRID
#------------------------------------------------------------------------------
LIBEL="Clean-up TLIFDRID"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST..PdLIFDRID_01 ${BALSHTYEA_NF}"
ISQL


NSTEP=${NJOB}_40
# Clean-up TLIFMOD
#------------------------------------------------------------------------------
LIBEL="Clean-up TLIFMOD"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST..PdLIFMOD_01 ${BALSHTYEA_NF}"
ISQL


NSTEP=${NJOB}_50
# Clean-up TLIFMOD2
#------------------------------------------------------------------------------
LIBEL="Clean-up TLIFMOD2"
ISQL_BASE='BEST'
ISQL_QRY="execute BEST..PdLIFMOD2_01 ${BALSHTYEA_NF}"
ISQL


NSTEP=${NJOB}_60
# Clean-up TLIFPEN
#------------------------------------------------------------------------------
#LIBEL="Clean-up TLIFPEN"
#ISQL_BASE='BEST'
#ISQL_QRY="execute BEST..PdLIFPEN_01"
#ISQL

JOBEND
