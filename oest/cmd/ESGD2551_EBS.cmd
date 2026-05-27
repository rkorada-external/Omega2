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



if [ "$TYPEINV" = "INV" ]; then
     JOBEND
fi


NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="get ${ESF_FLORETFACTOR_EBS_POS_SERQ}  and not in INV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR_SERQ} 2000 1"
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
/INFILE ${ESF_FLORETFACTOR_EBS_INV_SERQ} 2000 1 "~"
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
LIBEL="MERGE delta ${ESF_FLORETFACTOR_EBS_POS_SERQ} with INV   "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR_EBS_INV_SERQ} 2000 1"
SORT_I2="${DFILT}/${NJOB}_15_${IB}_SORT_FLORETFACTOR_DELTA_O.dat 2000 1"
SORT_O="${ESF_FLORETFACTOR_SERQ} 2000 1 "
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
LIBEL="get ${ESF_FCES_SERQ}  and not in INV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCES_SERQ} 2000 1"
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
/INFILE ${ESF_FCES_EBS_INV_SERQ} 2000 1 "~"
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
LIBEL="MERGE delta ${ESF_FCES_EBS_POS_SERQ} with INV "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCES_EBS_INV_SERQ} 2000 1"
SORT_I2="${DFILT}/${NJOB}_25_${IB}_SORT_FCES_DELTA_O.dat 2000 1"
SORT_O="${ESF_FCES_SERQ} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS       CTR_NF        1:1 - 1:,
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



                                                
JOBEND
