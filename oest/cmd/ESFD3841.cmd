#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Mapping Code Component Mapping
# nom du script SHELL           : ESFD3841.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 11/05/2020
# auteur                        : Nhat Linh DOAN
#-----------------------------------------------------------------------------
# description
#  : SPIRA 85741 :  Omega-SAP interface - IFRS 17 account file generation
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 11/05/2020 : SPIRA 85741: NLD : Omega-SAP interface - IFRS 17 account file generation
#[002] 02/07/2020 : SPIRA 87674: SBE : IFRS 17 - Omega SAP interface - SAS Engine transactions management
#[003] 06/07/2020 : SPIRA 87674: NLD : add init mapping management
#[004] 21/12/2020 : SPIRA 91994: NLD : Local - IFRS17L/IFRS1P Omega/RA  interface
#[005] 09/02/2021 : SPIRA 91379: RC  : IFRS17 - Take Annual Opening file ESF_OPNG_FTECLEDA-R to _MVT.dat at 1Q quarter
#[006] 24/03/2021 : SPIRA 91379: NLD : IFRS17 - Copy ESF_FTECLEDA_MVT to ESFD3960 output
#[007] 09/02/2021 : SPIRA 91379: RC  : IFRS17 - Take Annual Opening file ESF_FTECLEDA-R_OPNG instead of ESF_OPNG_FTECLEDA-R to _MVT.dat at 1Q quarter
#[006] 28/04/2021 : SPIRA 95859: NLD : Force LOBRET_CF=01 for retro contract on IFRS17
#[009] 28/04/2021 : SPIRA 93345: SBE : I17 : RETRO - Life SAP posting - Copy
#[010] 02/06/2021 : SPIRA 92996: NLD : GLT IFRS17- Missing field in TTECLEDA and TTECLEDR format
#[011] 04/04/2022 : SPIRA 103202: DaD : remove opening IFRS17 into merge
#[012] 11/05/2022 : SPIRA 102172: JYP : overwrite RETINTAMT for some cases
#[013] 31/05/2022 : SPIRA 100702: DaD : overwrite RETAMT & RETINTAMT for TRNCOD = 1XXXXXXXX
#===============================================================================

# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> CONTEXT_CT.................: ${CONTEXT_CT}  "

ECHO_LOG "#===> PARM_ICLODAT_D.............: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}"
ECHO_LOG "#===> PARM_CRE_D.................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM_BLCSHTYEA_NF..........: ${PARM_BLCSHTYEA_NF}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"

CLODAT_D=${PARM_ICLODAT_D}
MONTH_QTR=`echo ${PARM_ICLODAT_D} | cut -c5-6`


ECHO_LOG ""                                                                                     >>$FLOG
ECHO_LOG "#....................... INPUT ..........................................."           >>$FLOG
ECHO_LOG "#===> CLODAT_D.............................: ${CLODAT_D} "                            >>$FLOG
ECHO_LOG "#===> NORME_CF.............................: ${NORME_CF} "                            >>$FLOG


ECHO_LOG "#===> EPO_FTECLEDASII.................: ${EPO_FTECLEDASII} "              >>$FLOG
ECHO_LOG "#===> EPO_FTECLEDRSII.................: ${EPO_FTECLEDRSII} "              >>$FLOG
ECHO_LOG "#===> ESF_FTECLEDA....................: ${ESF_FTECLEDA} "                 >>$FLOG
ECHO_LOG "#===> ESF_FTECLEDR....................: ${ESF_FTECLEDR} "                 >>$FLOG
ECHO_LOG "#===> ESF_FTECLEDA_OPNG...............: ${ESF_FTECLEDA_OPNG} "            >>$FLOG
ECHO_LOG "#===> ESF_FTECLEDR_OPNG...............: ${ESF_FTECLEDR_OPNG} "            >>$FLOG
ECHO_LOG "#===> ESF_FTECLEDA_REJ................: ${ESF_FTECLEDA_REJ} "             >>$FLOG
ECHO_LOG "#===> ESF_FTECLEDR_REJ................: ${ESF_FTECLEDR_REJ} "             >>$FLOG


ECHO_LOG "#....................... OUTPUT ..........................................."          >>$FLOG
ECHO_LOG "#===> ESF_FTECLEDA_MVT ......................: ${ESF_FTECLEDA_MVT}"      	>>$FLOG
ECHO_LOG "#===> ESF_FTECLEDR_MVT ......................: ${ESF_FTECLEDR_MVT}" 		>>$FLOG
ECHO_LOG "#========================================================================="           >>$FLOG


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES "


if [ ! -f ${ESF_FTECLEDA_I17AELIFE} ]
then
        ECHO_LOG "ESF_FTECLEDA_I17AELIFE=${ESF_FTECLEDA_I17AELIFE}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDA_I17AELIFE}"

fi

if [ ! -f ${ESF_FTECLEDR_I17AELIFE} ]
then
        ECHO_LOG "ESF_FTECLEDR_I17AELIFE=${ESF_FTECLEDR_I17AELIFE}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_FTECLEDR_I17AELIFE}"

fi

if [ ! -f ${ESF_FTECLEDA_OPNG} ]
then
	touch ${ESF_FTECLEDA_OPNG} ${ESF_FTECLEDR_OPNG}
fi

if [ ! -f ${ESF_FTECLEDA_REJ} ]
then
	touch ${ESF_FTECLEDA_REJ} ${ESF_FTECLEDR_REJ}
fi

#[005]
NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Merge GTL FTECLEDA EBS and IFRS17 File  to ${ESF_FTECLEDA_MVT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA} 2000 1"
SORT_I2="${ESF_FTECLEDA_I17AELIFE} 2000 1"
# SORT_I3="${ESF_FTECLEDA_REJ} 2000 1" # [011]
# SORT_I4="${ESF_FTECLEDA_OPNG} 2000 1" # [011]
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
	CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:
        
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF

/OUTFILE ${SORT_O} OVERWRITE

exit
EOF
SORT


#[013]
NSTEP=${NJOB}_40
LIBEL="Add lobret_cf"
AWK_I="${DFILT}/${NJOB}_30_${IB}_FTECLEDA.dat"
AWK_O="${ESF_FTECLEDA_MVT}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
    if ((substr(\$6,1 , 1) == "2" ) && (length(\$24) > 0) && (length(\$46) == 0)) {\$46="01"};

    if (\$36 == "") \$88=0;

    if ( (\$36 != "") && (\$37 != "") ) \$88=\$35;

    if (substr(\$6, 1, 1) == "1" ) {
        \$35=0;
        \$88=0;
    }

    print \$0;
  }
exit


EOF
AWK



#[005]
NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Merge GTL FTELEDR EBS and IFRS17 File  to ${ESF_FTECLEDR_MVT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR} 2000 1"
SORT_I2="${ESF_FTECLEDR_I17AELIFE} 2000 1"
# SORT_I3="${ESF_FTECLEDR_REJ} 2000 1" # [011]
# SORT_I4="${ESF_FTECLEDR_OPNG} 2000 1" # [011]
SORT_O="${ESF_FTECLEDR_MVT} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
	CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:
        
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF

/OUTFILE ${SORT_O} OVERWRITE

exit
EOF
SORT


#step temporaire � enlever

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="copy ${ESF_FTECLEDA_MVT} to ESFD3960 output"
EXECKSH "cp ${ESF_FTECLEDA_MVT} ${DFILP}/${ENV_PREFIX}_ESFD3960_${NORME_CF}_SAP_OMG_STD_FTECLEDA_MVT_${TYPEINV}_${PARM_ICLODAT_D}.dat"


JOBEND


