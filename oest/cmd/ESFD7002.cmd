#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - EBS / I17 Reject data Generation
# nom du script SHELL           : ESFD7002.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 02/02/2021
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  IFRS17 Spira : 91379 I17 - Reject booked data Generation
#-----------------------------------------------------------------------------
# historiques des modifications
#[002] 15/12/2021 R.CASSIS SPIRA 100487-101117-98240 : Ajustage conditions pour posting I17 et EBS
#[003] 21/02/2022 SirTD/JYP SPIRA 100487-101117-98240: bugfix zgip EBS-KO et Fichier RMN plus trait� ici
#[004] 15/03/2023 MiS SPIRA 109236: Creation file for I17S
#[005] 04/04/2023 MZM SPIRA 99999: bugfix ISU MAI 500 1 ==> 1000 1 et 800 1 ==> 1000 1
#[006] 26/06/2023 JYP:spira 109764 : update NEWCOLS1_NF=empty 
#[007] 30/08/2023 JYP/Mark/TD:spira 110282 : add DBLTRNCD in cumul keys  
#[008] 13/11/2023 DAD : spira 108167 : Modifier l’archivage des fichier REJ
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters


# Reject date
ICLODAT_D_REJ=`echo ${PARM_ICLODAT_D}  | awk '{ if (substr($0,5,2) == "03") dateb = substr($0,1,4) "0630"; if (substr($0,5,2) == "06") dateb = substr($0,1,4) "0930"; if (substr($0,5,2) == "09") dateb = substr($0,1,4) "1231"; if (substr($0,5,2) == "12") dateb = substr($0,1,4)+1 "0331";print dateb }'`

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME_CF.....................................: ${NORME_CF}"
ECHO_LOG "#===> PARM_BATCHUSER...............................: ${PARM_BATCHUSER}"
ECHO_LOG "#===> IDF_CT.......................................: ${IDF_CT}"
ECHO_LOG "#===> VNORME.......................................: ${VNORME}"
ECHO_LOG "#===> PARM_ICLODAT_D...............................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> ICLODAT_D_REJ................................: ${ICLODAT_D_REJ}"
ECHO_LOG "#===> ............ INPUT .................................................."
ECHO_LOG "#===> ESF_FTECLEDA_CUR.............................: ${ESF_FTECLEDA_CUR}"
ECHO_LOG "#===> ESF_FTECLEDR_CUR.............................: ${ESF_FTECLEDR_CUR}"
ECHO_LOG "#===> ESF_GROUPING_TC_TOOMIT.......................: ${ESF_GROUPING_TC_TOOMIT}"
ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> ESF_FTECLEDA_REJ.............................: ${ESF_FTECLEDA_REJ}"
ECHO_LOG "#===> ESF_FTECLEDR_REJ.............................: ${ESF_FTECLEDR_REJ}"
ECHO_LOG "#========================================================================="



#[008]
NSTEP=${NJOB}_05
LIBEL="Archiving previous quaterly reject files ESF_FTECLEDA_REJ"
EXECKSH_MODE=P
EXECKSH "gzip -c ${ESF_FTECLEDA_REJ} > ${ESF_FTECLEDA_REJ_ARC_PREV}"

#[008]
LIBEL="Archiving previous quaterly reject files ESF_FTECLEDR_REJ"
EXECKSH_MODE=P
EXECKSH "gzip -c ${ESF_FTECLEDR_REJ} > ${ESF_FTECLEDR_REJ_ARC_PREV}"


###########################
# Acceptance cancellation #
###########################

#[001]
if [ "${NORME_CF}" != "EBS" ]
then
	NSTEP=${NJOB}_10
	#------------------------------------------------------------------------------
	#Sort-join and filter of FTECLEDA on I17 trncod to cancel
	#-----------------------------------------------------------------------------
	LIBEL="Sort-join and filter of FTECLEDA on I17 trncod to cancel ..."
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${ESF_FTECLEDA_CUR} 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat OVERWRITE 1000 1 "
	INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF        6:1 -   6:,
        F_TRNCOD_CF      1:1 -   1:,       
        ALL_COLS         1:1 - 118:
/joinkeys
         TRNCOD_CF   
/INFILE ${ESF_GROUPING_TC_TOOMIT} 100 1 "~"
/joinkeys
         F_TRNCOD_CF   
/JOIN UNPAIRED leftside ONLY
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:ALL_COLS
exit
EOF
	SORT
fi

#[001]
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
# Sort FTECLEDA
#-----------------------------------------------------------------------------
LIBEL="Sort/Sum FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${NORME_CF}" != "EBS" ]
then
	SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FTECLEDA_O.dat 1000 1"
else
	SORT_I="${ESF_FTECLEDA_CUR} 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -   1: EN,
        ESB_CF           2:1 -   2:,
        BALSHEY_NF       3:1 -   3: EN,
        BALSHRMTH_NF     4:1 -   4: EN,
        TRNCOD_CF        6:1 -   6:,
        DBLTRNCOD_CF     7:1 -   7:,
	      CTR_NF         8:1 -   8:,
        END_NT           9:1 -   9:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        UW_NT           12:1 -  12:,
        OCCYEA_NF       13:1 -  13:,
        ACY_NF          14:1 -  14:,
        SCOSTRMTH_NF    15:1 -  15:,
        SCOENDMTH_NF    16:1 -  16:,
        CLM_NF          17:1 -  17:,
        CUR_CF          18:1 -  18:,
        AMT_M           19:1 -  19:EN 18/3,
        RETCTR_NF       24:1 -  24:,
        RETEND_NT       25:1 -  25:,
        RETSEC_NF       26:1 -  26:,
        RTY_NF          27:1 -  27:,
        RETUW_NT        28:1 -  28:,
        RETOCCYEA_NF    29:1 -  29:,
        RETACY_NF       30:1 -  30:,
        RETSCOSTRMTH_NF 31:1 -  31:,
        RETSCOENDMTH_NF 32:1 -  32:,
        RCL_NF          33:1 -  33:,
        RETCUR_CF       34:1 -  34:,
        RETAMT_M        35:1 -  35:EN 18/3,
        PLC_NT          36:1 -  36:,
        RETINTAMT_M     88:1 -  88:EN 18/3,
        TRN_NT         103:1 - 103:,
        RETARDRETINT_B 109:1 - 109:,
        GAAPCOD_NT     111:1 - 111:,
        I17PRDCOD_CT   112:1 - 112:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
	  DBLTRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
/CONDITION Somme ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0)
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M , TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE Somme
exit
EOF
SORT

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
# Current cancellation of the previous closing period in FTECLEDA...
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closing period in FTECLEDA..."
PRG=ESTM7601b
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D_REJ}
TYPFIC GLTAR
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_FTECLEDA.dat
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_REJ_FTECLEDA.dat"
EXECPRG

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
#reset to blanc 16 cols from SAP/ONEGL
#-----------------------------------------------------------------------------
LIBEL="reset to blanc 16 cols from SAP/ONEGL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTM7601b_REJ_FTECLEDA.dat 1000 1"
SORT_O="${ESF_FTECLEDA_REJ}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS COLS1          1:1 -  88:,
        COLS2        103:1 - 109:,
		COLS3      111:1 -  118:		
/DERIVEDFIELD BLANK_14_CHAMPS 14"~"
/DERIVEDFIELD  NEWCOLS1_NF "~"
/OUTFILE ${SORT_O}
/REFORMAT COLS1,BLANK_14_CHAMPS,COLS2,NEWCOLS1_NF,COLS3
exit
EOF
SORT


#############################
# Retrocession cancellation #
#############################

#[001]
if [ "${NORME_CF}" != "EBS" ]
then
	NSTEP=${NJOB}_50
	#-----------------------------------------------------------------------------
	#Sort-join and filter of FTECLEDR on I17 trncod to cancel
	#-----------------------------------------------------------------------------
	LIBEL="Sort-join and filter of FTECLEDR on I17 trncod to cancel ..."
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${ESF_FTECLEDR_CUR} 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat OVERWRITE 1000 1 "
	INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        F_TRNCOD_CF      1:1 -  1:,       
        ALL_COLS         1:1 - 71:
/joinkeys
         TRNCOD_CF   
/INFILE ${ESF_GROUPING_TC_TOOMIT} 100 1 "~"
/joinkeys
         F_TRNCOD_CF   
/JOIN UNPAIRED leftside ONLY
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:ALL_COLS
exit
EOF
	SORT
fi

#[001]
NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
# Sort FTECLEDR
#-----------------------------------------------------------------------------
LIBEL="Sort FTECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${NORME_CF}" != "EBS" ]
then
	SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_FTECLEDR_O.dat 1000 1"
else
	SORT_I="${ESF_FTECLEDR_CUR} 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1: EN,
        ESB_CF           2:1 -  2:,
        BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 - 7:,		
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:,
        OCCYEA_NF       13:1 - 13:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:EN 18/3,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETACY_NF       30:1 - 30:,
        RETOCCYEA_NF    29:1 - 29:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:EN 18/3,
        PLC_NT          36:1 - 36:,
        TRN_NT          56:1 - 56:,
        RETARDRETINT_B  62:1 - 62:,
        GAAPCOD_NT      64:1 - 64:,
        I17PRDCOD_CT    65:1 - 65:

/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
	  DBLTRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
/CONDITION Somme ( AMT_M NE 0 OR RETAMT_M NE 0)
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M
/OUTFILE ${SORT_O}
/INCLUDE Somme
exit
EOF
SORT

NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
#Cancellation of the previous closing period in FTECLEDR
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closing period in FTECLEDR ..."
PRG=ESTM7601b
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D_REJ}
TYPFIC GLTRR
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_FTECLEDR_O.dat
export ${PRG}_O1="${ESF_FTECLEDR_REJ}"
EXECPRG

#[004]
if [ "${NORME_CF}" = "I17G" ]
then

NSTEP=${NJOB}_75
#------------------------------------------------------------------------------
# Copy ESF_FTECLEDR_REJ file
#------------------------------------------------------------------------------
LIBEL="copy ESF_FTECLEDR_REJ files"
EXECKSH_MODE=P
EXECKSH "cp ${ESF_FTECLEDR_REJ} ${I17S_ESF_FTECLEDR_REJ}"

NSTEP=${NJOB}_76
#------------------------------------------------------------------------------
# Copy ESF_FTECLEDA_REJ file
#------------------------------------------------------------------------------
LIBEL="copy ESF_FTECLEDA_REJ files"
EXECKSH_MODE=P
EXECKSH "cp ${ESF_FTECLEDA_REJ} ${I17S_ESF_FTECLEDA_REJ}"

fi


NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Archiving quaterly reject files ESF_FTECLEDA_REJ"
EXECKSH_MODE=P
EXECKSH "gzip -c ${ESF_FTECLEDA_REJ} > ${ESF_FTECLEDA_REJ_ARC}"

NSTEP=${NJOB}_90
#------------------------------------------------------------------------------
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Archiving quaterly reject files ESF_FTECLEDR_REJ"
EXECKSH_MODE=P
EXECKSH "gzip -c ${ESF_FTECLEDR_REJ} > ${ESF_FTECLEDR_REJ_ARC}"

if [ "${NORME_CF}" = "EBS" ]
then
	NSTEP=${NJOB}_100
	#------------------------------------------------------------------------------
	# Archive others EBS files
	#------------------------------------------------------------------------------
	LIBEL="Archive others EBS files"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EPO_DLASIIGTRSO} > ${EPO_DLASIIGTRSO_ARC}"
	gzip -c ${EPO_DLDSIIGTRSO}         > ${EPO_DLDSIIGTRSO_ARC}
	gzip -c ${EPO_DLEIFTECLEDSIIEPSO}  > ${EPO_DLEIFTECLEDSIIEPSO_ARC}
	gzip -c ${EPO_DLEIGTAA}            > ${EPO_DLEIGTAA_ARC}
	gzip -c ${EPO_DLREGTRSIISO}        > ${EPO_DLREGTRSIISO_ARC}
	gzip -c ${EPO_DLRGTAASIISO}        > ${EPO_DLRGTAASIISO_ARC}
	gzip -c ${EPO_FCTRSTATSO}          > ${EPO_FCTRSTATSO_ARC}
	gzip -c ${EPO_FSEGSTATSO}          > ${EPO_FSEGSTATSO_ARC}
	gzip -c ${EPO_GTEPSIISO}           > ${EPO_GTEPSIISO_ARC}
fi
JOBEND
