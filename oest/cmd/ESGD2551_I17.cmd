#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Merge IFRS17 SERQS
#				  Batch quotidien
# nom du script SHELL		: ESGD2551_I17.cmd
# revision
# revision                      : $Revision:   1.2  $
# date de creation              : 05/05/2025
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   SPIRA US5850  Evolution SERQ : Merge  files
#-----------------------------------------------------------------------------
# historiques des modifications :
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation

JOBINIT



# Get input parameters

set `GETPRM ${DPRM}/ESCJ0660.prm`
export X_DAYS=$1
export QUARTER_END_FOUND=`grep ${PARM_ICLODAT_D} ${DPRM}/ESFD5000.prm | cut -d' ' -f 2`

if [ "${NORME_CF}" = "EBS" ] || [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
then
      if  [ "${TYPEINV}" = "INV" ]
      then
            PARM_DATE_FIN_D="${PARM_BOOKINGNEXT_D}"
      fi
      if  [ "${TYPEINV}" = "POS" ]
      then
            PARM_DATE_FIN_D="${PARM_PSTOMGEND17_D}"
      fi
fi




NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Extract  ${ESF_FCES_I17_SERQ}"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${ESF_FCES_I17_SERQ}"
BCP_QRY="execute BEST..PsCESSIONI17_SERQ_02 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP


NSTEP=${NJOB}_10
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Extract LORETFACTOR I17 SERQS"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${ESF_FLORETFACTOR_I17_SERQ}"
BCP_QRY="execute BEST..PsLORETFACTOR_I17_SERQ_01   '${PARM_ICLODAT_D}', '${PARM_ICLODAT_D}', '${PARM_DATE_FIN_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' "
BCP

if [ "$TYPEINV" = "INV" ]; then
     JOBEND
fi

NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="get ALL ESF_FLORETFACTOR_INI_5000 - INV ==> POS File LOFACTOR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR_I17_SERQ} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLORETFACTOR_DELTA_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS       CTR_NF                                              1:1 - 1:,
                                      END_NT                                    2:1 - 2:,
                                      SEC_NF                                    3:1 - 3:,
                                      UWY_NF                                    4:1 - 4:,
                                      UW_NT                                           5:1 - 5:,
                                      RETCTR_NF                                               6:1 - 6:,
                                      RETEND_NT                               7:1 - 7:,
                                      RETSEC_NF                               8:1 - 8:,
                                      RETRTY_NF                                     9:1 - 9:,
                                      RETUW_NT                                  10:1 - 10:,
                                      ALL_COLS                                                1:1 -  35:,
                                      INV_CTR_NF                                              1:1 - 1:,
                                      INV_END_NT                                    2:1 - 2:,
                                      INV_SEC_NF                                    3:1 - 3:,
                                      INV_UWY_NF                                    4:1 - 4:,
                                      INV_UW_NT                                           5:1 - 5:,
                                      INV_RETCTR_NF                           6:1 - 6:,
                                      INV_RETEND_NT                       7:1 - 7:,
                                      INV_RETSEC_NF                       8:1 - 8:,
                                      INV_RETRTY_NF                             9:1 - 9:,
                                      INV_RETUW_NT                          10:1 - 10:
/joinkeys
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT
/INFILE ${ESF_FLORETFACTOR_I17_INV_SERQ} 2000 1 "~"
/joinkeys
     INV_CTR_NF,
     INV_END_NT,
     INV_SEC_NF,
     INV_UWY_NF,
     INV_UW_NT,
     INV_RETCTR_NF,
     INV_RETEND_NT,
     INV_RETSEC_NF,
     INV_RETRTY_NF,
     INV_RETUW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT




NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT LOFACTOR INI INV And LOFACTOR DELTA_POS  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR_I17_INV_SERQ} 2000 1"
SORT_I2="${DFILT}/${NJOB}_15_${IB}_SORT_FLORETFACTOR_DELTA_O.dat 2000 1"
SORT_O="${ESF_FLORETFACTOR_I17_SERQ} 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS       CTR_NF                                              1:1 - 1:,
                                      END_NT                                    2:1 - 2:,
                                      SEC_NF                                    3:1 - 3:,
                                      UWY_NF                                    4:1 - 4:,
                                      UW_NT                                           5:1 - 5:,
                                      RETCTR_NF                                               6:1 - 6:,
                                      RETEND_NT                               7:1 - 7:,
                                      RETSEC_NF                               8:1 - 8:,
                                      RETRTY_NF                                     9:1 - 9:,
                                      RETUW_NT                                  10:1 - 10:,
                                      ALL_COLS                                                1:1 -  35:
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="get ALL FCES - INV ==> POS File FCES"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCES_I17_SERQ} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCES_DELTA_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS       CTR_NF                                              1:1 - 1:,
                                      END_NT                                    2:1 - 2:,
                                      SEC_NF                                    3:1 - 3:,
                                      UWY_NF                                    4:1 - 4:,
                                      UW_NT                                           5:1 - 5:,
                                      RETCTR_NF                                               6:1 - 6:,
                                      RETEND_NT                               7:1 - 7:,
                                      RETSEC_NF                               8:1 - 8:,
                                      RETRTY_NF                                     9:1 - 9:,
                                      RETUW_NT                                  10:1 - 10:,
                                      ALL_COLS                                                1:1 -  35:,
                                      INV_CTR_NF                                              1:1 - 1:,
                                      INV_END_NT                                    2:1 - 2:,
                                      INV_SEC_NF                                    3:1 - 3:,
                                      INV_UWY_NF                                    4:1 - 4:,
                                      INV_UW_NT                                           5:1 - 5:,
                                      INV_RETCTR_NF                           6:1 - 6:,
                                      INV_RETEND_NT                       7:1 - 7:,
                                      INV_RETSEC_NF                       8:1 - 8:,
                                      INV_RETRTY_NF                             9:1 - 9:,
                                      INV_RETUW_NT                          10:1 - 10:
/joinkeys
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT
/INFILE ${ESF_FCES_I17_INV_SERQ} 2000 1 "~"
/joinkeys
     INV_CTR_NF,
     INV_END_NT,
     INV_SEC_NF,
     INV_UWY_NF,
     INV_UW_NT,
     INV_RETCTR_NF,
     INV_RETEND_NT,
     INV_RETSEC_NF,
     INV_RETRTY_NF,
     INV_RETUW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT FCES INI INV And FCES DELTA_POS  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCES_I17_INV_SERQ} 2000 1"
SORT_I2="${DFILT}/${NJOB}_25_${IB}_SORT_FCES_DELTA_O.dat 2000 1"
SORT_O="${ESF_FCES_I17_SERQ} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS       CTR_NF                                              1:1 - 1:,
      END_NT                                    2:1 - 2:,
      SEC_NF                                    3:1 - 3:,
      UWY_NF                                    4:1 - 4:,
      UW_NT                                           5:1 - 5:,
      RETCTR_NF                                               6:1 - 6:,
      RETEND_NT                               7:1 - 7:,
      RETSEC_NF                               8:1 - 8:,
      RETRTY_NF                                     9:1 - 9:,
      RETUW_NT                                  10:1 - 10:,
      ALL_COLS                                                1:1 -  35:

/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_35
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Extract LORETFACTOR I17 SERQS"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FI17CLOPER}
BCP_QRY="execute BEST..PsTI17CLOPER_SERQ_02 '${NORME_CF}', '${PARM_PSTOMGEND17_D}', '${PARM_REQCOD_CT}', '${PARM_CRE_D}'"
BCP
                                                
JOBEND
