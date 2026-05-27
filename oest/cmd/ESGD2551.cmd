#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Gestion des ecritures de services Life IFRS17
#				  Batch quotidien
# nom du script SHELL		: ESGD2551.cmd
# revision
# revision                      : $Revision:   1.2  $
# date de creation              : 05/05/2025
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   SPIRA 111672  Evolution SERQ : Merge  files
#-----------------------------------------------------------------------------
# historiques des modifications :
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters

# Job Initialisation
JOBINIT




NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Extract  FCES  SERQS"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="$ESF_FCES_EBS_SERQ"
BCP_QRY=" BEST..PsCESSION_SERQ_01 "
BCP

NSTEP=${NJOB}_10
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Extract LORETFACTOR SERQS"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="$ESF_FLORETFACTOR_EBS_SERQ"
BCP_QRY=" BEST..PsLORETFACTOR_SERQ_02  '$PARM_ICLODAT_D', '$PARM_TYPEINV'
    "
BCP




FILE_AS=`echo  ${EST_FSSDACTR_TXT} | sed -e s/ub../ubas/`
FILE_EU=`echo  ${EST_FSSDACTR_TXT} | sed -e s/ub../ubeu/`
FILE_AM=`echo  ${EST_FSSDACTR_TXT} | sed -e s/ub../ubam/`

NSTEP=${NJOB}_20
# filter 
#------------------------------------------------------------------------------
LIBEL="fusion FSSDACTR   "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${FILE_AS} 2000 1"
SORT_I2="${FILE_EU} 2000 1"
SORT_I3="${FILE_AM} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FSSDACTR_TXT_ALL_O.dat"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
/OUTFILE  ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_30
# filter 
#------------------------------------------------------------------------------
LIBEL="clean doublon FSSDACTR  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_FSSDACTR_TXT_ALL_O.dat 2000 1"
SORT_O="$EST_FSSDACTR_TXT_MERGE 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
   END_NT 4:1 - 4:,
   SEC_NF 5:1 - 5:,
   UWY_NF 6:1 - 6:,
   UW_NT 7:1 - 7:,
   PLC_NT 8:1 - 8:
/KEYS CTR_NF,
   END_NT,
   SEC_NF,
   UWY_NF,
   UW_NT,
   PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_40
# Begin programme C TYPETRAIT=L/A (local/Autres)
#------------------------------------------------------------------------------
LIBEL="Application of ${EST_FCURCVSNI} and  ${EST_FSSDACTR}"
PRG=ESGX0061
export ${PRG}_O1=${EST_FCURCVSNI}
export ${PRG}_O2=${EST_FSSDACTR}
EXECPRG

NSTEP=${NJOB}_50
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Extract FCURCVSN SERQS"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="$EST_FCURCVSN"
BCP_QRY="select distinct a.ssd_cf, a.retctr_nf, a.rty_nf, a.plc_nt
         from bret..tcurcvsn a
         where plc_nt > 0
         order by a.ssd_cf, a.retctr_nf, a.rty_nf, a.plc_nt"
BCP


NSTEP=${NJOB}_60
#---------------------------------------------------------------------------------------------
LIBEL="copy FSSDACTR to EBS"   
EXECKSH "cp ${EST_FSSDACTR} ${EST_FSSDACTR_EBS}"

NSTEP=${NJOB}_70
#---------------------------------------------------------------------------------------------
LIBEL="copy EST_FSSDACTR_TXT to EBS"   
EXECKSH "cp ${EST_FSSDACTR_TXT} ${EST_FSSDACTR_TXT_EBS}"

NSTEP=${NJOB}_80
#---------------------------------------------------------------------------------------------
LIBEL="copy EST_FCURCVSNI to EBS"   
EXECKSH "cp ${EST_FCURCVSNI} ${EST_FCURCVSNI_EBS}"

NSTEP=${NJOB}_90
#---------------------------------------------------------------------------------------------
LIBEL="copy EST_FCURCVSN to EBS"   
EXECKSH "cp ${EST_FCURCVSN} ${EST_FCURCVSN_EBS}"

JOBEND
