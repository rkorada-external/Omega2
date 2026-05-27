#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATES
#                                 Retrocession closing period process
# nom du script SHELL		: ESID2502.cmd
# revision			: $Revision:   1.3  $
# date de creation		: 06/10/1997
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# Description :
#   Computing of the files to upload in tables TCESSION and TCONPAR
#
#
#   Output file sort ${DFILT}/${NSTEP}_${IB}_SORT_FBESTCESSION_O.dat
#   		     ${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat
#   		     ${EST_FBESTCONPAR}
#
#
#   Launch C program ESTC2306
#
# JOB LAUNCHED BY : ESID2500.cmd
# This job is launched only for a main closing period 
#-----------------------------------------------------------------------------
# historiques des modifications : 
#[001] 20/11/2019 M.NAJI Spira 81838  remplacement du fichier temporaire ${DFILT}/${NJOB}_20_${IB}_ESTC2301_CES_O.dat par $EST_FCES_NEW
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job initialisation
JOBINIT


NSTEP=${NJOB}_05
# Sum of retro shares for each (contract/section/endorsement number/
# underwriting year/underwriting order) in placement file.
# Reformat the resulting records according to the structure of table TCESSION
#-----------------------------------------------------------------------------
LIBEL="Sum of retro shares in placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLC}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FBESTCESSION_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: ,
        RETCTR_NF 3:1 - 3:,
        RETSEC_NF 5:1 - 5: ,
        RTY_NF 6:1 - 6: ,
        RETSIGSHA_R 16:1 - 16: EN 1/8
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF
/SUMMARIZE TOTAL RETSIGSHA_R
/DERIVEDFIELD RETSIGSHA_RC RETSIGSHA_R COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT RETCTR_NF,
          RTY_NF,
          RETSEC_NF,
          SSD_CF,
          RETSIGSHA_RC
exit
EOF
SORT

NSTEP=${NJOB}_10
# Sort of cession file according to contract/section/underwriting year
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#[001]SORT_I=${DFILT}/${NCHAIN}_ESID2501_20_${IB}_ESTC2301_CES_O.dat
SORT_I=${EST_FCES_NEW}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 6:1 - 6:,
        RETSEC_NF 8:1 - 8: ,
        RTY_NF 9:1 - 9: 
/KEYS   RETCTR_NF,
        RETSEC_NF,
        RTY_NF
exit
EOF
SORT

NSTEP=${NJOB}_15
# Computing of retro shares 
#-----------------------------------------------------------------------------
LIBEL="Computing retro shares..."
PRG=ESTC2306
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_FBESTCESSION_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_CES_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_BESTCONPAR_O.dat
EXECPRG
           
NSTEP=${NJOB}_20
# Sum of retro shares 
#-----------------------------------------------------------------------------
LIBEL="Final sum of retro shares..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_15_${IB}_ESTC2306_BESTCONPAR_O.dat
SORT_O="${EST_FBESTCONPAR} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: ,
        SEC_NF 3:1 - 3: ,
        UWY_NF 4:1 - 4: ,
        UW_NT 5:1 - 5:,
        SSD_CF 6:1 - 6: ,
        CUR_CF 7:1 - 7:,
        ACCADMTYP_CT 8:1 - 8: ,
        SHA_R 9:1 - 9: EN 1/8
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/SUMMARIZE TOTAL SHA_R
/DERIVEDFIELD SHA_RC SHA_R COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          SSD_CF,
          CUR_CF,
          ACCADMTYP_CT,
          SHA_RC
exit
EOF
SORT

if [ "${EST_ESID2500_COND2}" = "Y" ]
then   
   NSTEP=${NJOB}_25
   # Generation of table TCESSION
   #-------------------------------------------------------------------------
   LIBEL="Generation of table TCESSION"
   EXECKSH "mv ${DFILT}/${NJOB}_05_${IB}_SORT_FBESTCESSION_O.dat ${EST_FBESTCESSION}"
fi

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_30
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
RMFIL "${DFILT}/${NCHAIN}_ESID2501_20_${IB}_ESTC2301_CES_O.dat"

JOBEND

