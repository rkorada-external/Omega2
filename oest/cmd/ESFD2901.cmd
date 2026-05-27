#!/bin/ksh
#=============================================================================
# nom de l'application         : ESTIMATION - EBS / I17 Opening data Generation
# nom du script SHELL          : ESFD2901.cmd
# revision                     : $Revision: 1.0 $
# date de creation             : 02/02/2021
# auteur                       : R. Cassis
# references des specifications: spira:91379
#-----------------------------------------------------------------------------
# description
#  IFRS17 Spira : 91379 I17 - Opening data Generation and add it to CUR_FTECLEDA-R files
#
# job launched by ESFD2900.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 15/12/2021 R.CASSIS :spira:101117-100487 Adaptation a la norme EBS + 98240 ajout colonnes TRN_NT, I17PRDCOD_CT et RETARDRETINT_B dans cl� de tri
#[002] 09/02/2022 TD/JYP:spira:101117-100487 bugfix T.code I17P
#[003] 10/01/2023 TD/DAD:spira:108411 bugfix I17 openings - Q3 reversal on Q4 wrongly opened
#[004] 15/03/2023 MiS:spira:109236 Creation files for I17S
#[005] 26/06/2023 JYP:spira 109764 : update NEWCOLS1_NF=empty 
#[006] 07/09/2023 MZM:spira 110422 : NORME S FIX ISSU ITK 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters

RUN_MODE=`echo ${IDF_CT} | cut -d_ -f4`

if [ ! -f ${ESF_FTECLEDA_CUR} ]
then
	touch ${ESF_FTECLEDA_CUR} ${ESF_FTECLEDR_CUR} 
fi

#Default input TRNCOD suffix 

if [ "${NORME_CF}" = "EBS" ]
then
	COND_NORME='"AE" CT TRNCOD2_CF'
else
	COND_NORME='TRNCOD8_CF = "I"'
	if [ "${NORME_CF}" = "I17P" ]
	then
		COND_NORME='TRNCOD8_CF = "K"'
	fi
	if [ "${NORME_CF}" = "I17L" ]
	then
		COND_NORME='TRNCOD8_CF = "M"'
	fi
fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME_CF....................................: ${NORME_CF}"
ECHO_LOG "#===> RUN_MODE....................................: ${RUN_MODE}"
ECHO_LOG "#===> PARM_BATCHUSER..............................: ${PARM_BATCHUSER}"
ECHO_LOG "#===> IDF_CT......................................: ${IDF_CT}"
ECHO_LOG "#===> VNORME......................................: ${VNORME}"
ECHO_LOG "#===> COND_NORME..................................: ${COND_NORME}"
ECHO_LOG "#===> PARM_TYPEINV................................: ${PARM_TYPEINV}"
ECHO_LOG "#===> PARM_INVCONSO_D.............................: ${PARM_INVCONSO_D}"
ECHO_LOG "#===> PARM_CONSOYEA...............................: ${PARM_CONSOYEA}"
ECHO_LOG "#===> PARM_CONSOMTH...............................: ${PARM_CONSOMTH}"
ECHO_LOG "#===> ............ INPUT .................................................."
ECHO_LOG "#===> ESF_FTECLEDA_CUR............................: ${ESF_FTECLEDA_CUR}"
ECHO_LOG "#===> ESF_FTECLEDR_CUR............................: ${ESF_FTECLEDR_CUR}"
ECHO_LOG "#===> ESF_GROUPING_TC_TOOMIT......................: ${ESF_GROUPING_TC_TOOMIT}"
ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> ESF_FTECLEDA_OPNG...........................: ${ESF_FTECLEDA_OPNG}"
ECHO_LOG "#===> ESF_FTECLEDR_OPNG...........................: ${ESF_FTECLEDR_OPNG}"
ECHO_LOG "#========================================================================="


if [ "${RUN_MODE}" = "SIM" ]
then

	#FTECLEDA_CUR_SRC=`echo ${ESF_FTECLEDA_CUR} | sed "s/_SIM_/_/"`
	#FTECLEDR_CUR_SRC=`echo ${ESF_FTECLEDA_CUR} | sed "s/_SIM_/_/"`

	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===> Simulation mode : initialize ${ESF_FTECLEDA_CUR}  with ${ESF_FTECLEDA_CUR_SRC} "
	ECHO_LOG "#===> Initialize ${ESF_FTECLEDA_CUR}  with ${ESF_FTECLEDA_CUR_SRC} "
	ECHO_LOG "#===> Initialize ${ESF_FTECLEDR_CUR}  with ${ESF_FTECLEDR_CUR_SRC} "
	ECHO_LOG "#========================================================================="

	cp -v ${ESF_FTECLEDA_CUR_SRC} ${ESF_FTECLEDA_CUR}
	cp -v ${ESF_FTECLEDR_CUR_SRC} ${ESF_FTECLEDR_CUR}

NSTEP=${NJOB}_01
#----------------------------------------------------------------------------
# APPEND into ESF_FTECLEDA_CUR
#----------------------------------------------------------------------------
LIBEL="APPEND into ESF_FTECLEDA_CUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_POSTING} 800 1"
SORT_O="${ESF_FTECLEDA_CUR} APPEND"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_02
#----------------------------------------------------------------------------
# APPEND into ESF_FTECLEDR_CUR
#----------------------------------------------------------------------------
LIBEL="APPEND into ESF_FTECLEDR_CUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR_POSTING} 800 1"
SORT_O="${ESF_FTECLEDR_CUR} APPEND"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

fi


NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
#Sort-join and filter of ESF_FTECLEDA_CUR on AA-AR on GAAPCODE_NT
#-----------------------------------------------------------------------------
LIBEL="Sort-join and filter of ESF_FTECLEDA_CUR on AA-AR contracts and GAAPCODE_NT ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_CUR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:1 -   6:,
        F_TRNCOD_CF       1:1 -   1:,       
        ALL_COLS          1:1 - 118:
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

#[003]
NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
# Filtering clotures AR on 4Q month...
#-----------------------------------------------------------------------------
LIBEL="Filtering clotures AR on 4Q month..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FTECLEDA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY_NF         3:1 -   3: EN,
        BALSHRMTH_NF       4:1 -   4: EN,
        CTR_NF             8:1 -   8:,
        ACY_NF            14:1 -  14:,
        SCOSTRMTH_NF      15:1 -  15: EN,
        SCOENDMTH_NF      16:1 -  16: EN,
        RETCTR_NF         24:1 -  24:,
        RETACY_NF         30:1 -  30:,
        RETSCOSTRMTH_NF   31:1 -  31: EN,
        RETSCOENDMTH_NF   32:1 -  32: EN,
        GT_ANNUL_OPNG     114:1 -  114:, 
        cols1              1:1 -  13:,
        cols2             17:1 -  29:,
        cols3             33:1 - 118:
/CONDITION bilan BALSHEY_NF = ${PARM_CONSOYEA} AND BALSHRMTH_NF > 9 AND GT_ANNUL_OPNG != "A"
/CONDITION acy ACY_NF = "" AND CTR_NF != ""
/CONDITION retacy RETACY_NF = "" AND RETCTR_NF != ""
/DERIVEDFIELD ACY2_NF if acy then "${PARM_CONSOYEA}" else ACY_NF
/DERIVEDFIELD SCOENDMTH2_NF if acy then 12 else SCOENDMTH_NF
/DERIVEDFIELD SCOSTRMTH2_NF if acy then 12 else SCOSTRMTH_NF
/DERIVEDFIELD RETACY2_NF if retacy then "${PARM_CONSOYEA}" else RETACY_NF
/DERIVEDFIELD RETSCOENDMTH2_NF if retacy then 12 else RETSCOENDMTH_NF
/DERIVEDFIELD RETSCOSTRMTH2_NF if retacy then 12 else RETSCOSTRMTH_NF
/OUTFILE ${SORT_O}
/INCLUDE bilan
/REFORMAT cols1,ACY2_NF,SCOSTRMTH2_NF,SCOENDMTH2_NF,cols2,RETACY2_NF,RETSCOSTRMTH2_NF,RETSCOENDMTH2_NF,cols3
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
# Current sort file FTECLEDA
#-----------------------------------------------------------------------------
LIBEL="Current sort file FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_FTECLEDA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        TRNCOD2_CF 6:2 - 6:2,
        TRNCOD8_CF 6:8 - 6:8,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRN_NT 103:1 - 103:,
        RETARDRETINT_B 109:1 - 109:,
        GAAPCOD_NT  111:1 - 111:,
        I17PRDCOD_CT 112:1 - 112:

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
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
/CONDITION Norme ${COND_NORME}
/OUTFILE ${SORT_O}
/INCLUDE Norme
exit
EOF
SORT

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
#Sort-join and filter of ESF_FTECLEDA_CUR on AA-AR on GAAPCODE_NT
#-----------------------------------------------------------------------------
LIBEL="Sort-join and filter of ESF_FTECLEDA_CUR on AA-AR contracts and GAAPCODE_NT ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR_CUR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
        F_TRNCOD_CF       1:1 -  1:,       
        ALL_COLS          1:1 - 71:
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

#[003]
NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
# Filtering clotures RR on 4Q month...
#-----------------------------------------------------------------------------
LIBEL="Filtering clotures RR on 4Q month..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_FTECLEDR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY_NF         3:1 -   3: EN,
        BALSHRMTH_NF       4:1 -   4: EN,
        CTR_NF             8:1 -   8:,
        ACY_NF            14:1 -  14:,
        SCOSTRMTH_NF      15:1 -  15: EN,
        SCOENDMTH_NF      16:1 -  16: EN,
        RETCTR_NF         24:1 -  24:,
        RETACY_NF         30:1 -  30:,
        RETSCOSTRMTH_NF   31:1 -  31: EN,
        RETSCOENDMTH_NF   32:1 -  32: EN,
        GT_ANNUL_OPNG     67:1 -  67:, 
        cols1              1:1 -  13:,
        cols2             17:1 -  29:,
        cols3             33:1 -  71:
/CONDITION bilan BALSHEY_NF = ${PARM_CONSOYEA} AND BALSHRMTH_NF > 9 AND GT_ANNUL_OPNG != "A"
/CONDITION acy ACY_NF = "" AND CTR_NF != ""
/CONDITION retacy RETACY_NF = "" AND RETCTR_NF != ""
/DERIVEDFIELD ACY2_NF if acy then "${PARM_CONSOYEA}" else ACY_NF
/DERIVEDFIELD SCOENDMTH2_NF if acy then 12 else SCOENDMTH_NF
/DERIVEDFIELD SCOSTRMTH2_NF if acy then 12 else SCOSTRMTH_NF
/DERIVEDFIELD RETACY2_NF if retacy then "${PARM_CONSOYEA}" else RETACY_NF
/DERIVEDFIELD RETSCOENDMTH2_NF if retacy then 12 else RETSCOENDMTH_NF
/DERIVEDFIELD RETSCOSTRMTH2_NF if retacy then 12 else RETSCOSTRMTH_NF
/OUTFILE ${SORT_O}
/INCLUDE bilan
/REFORMAT cols1,ACY2_NF,SCOSTRMTH2_NF,SCOENDMTH2_NF,cols2,RETACY2_NF,RETSCOSTRMTH2_NF,RETSCOENDMTH2_NF,cols3
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
# Current sort file FTECLEDR
#-----------------------------------------------------------------------------
LIBEL="Current sort file FTECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_FTECLEDR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        TRNCOD2_CF 6:2 - 6:2,
        TRNCOD8_CF 6:8 - 6:8,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRN_NT 56:1 - 56:,
        RETARDRETINT_B 62:1 - 62:,
        GAAPCOD_NT 64:1 - 64:,
        I17PRDCOD_CT 65:1 - 65:
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
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
/CONDITION Norme ${COND_NORME}
/OUTFILE ${SORT_O}
/INCLUDE Norme
exit
EOF
SORT

###########################################################
### Generate Opening
###########################################################

NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
# Acceptance retrocession reversal and carried forward of previous balance sheet in the book
#-----------------------------------------------------------------------------
LIBEL="Acceptance retrocession reversal and carried forward in progress ..."
PRG=ESTM7602b
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${PARM_INVCONSO_D}
BALSHTMTH_NF ${PARM_CONSOMTH}
TYPFIC GLTAR
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDA_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTARSO_O.dat
EXECPRG

NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
# Double entry transaction code addition in  GT
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTA in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_70_${IB}_ESTM7602b_DLSGTARSO_O.dat
export ${PRG}_I2=${ESF_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTARSO_O.dat
EXECPRG


NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Update ORICOD_LS and blank 15 SAP fields for FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTM7603_DLSGTARSO_O.dat 800  1"
SORT_O="${ESF_FTECLEDA_OPNG} OVERWRITE"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS COLS1        1:1 -   88:,
        COLS2      103:1 -  103:,
        COLS3      105:1 -  109:,
		COLS4      111:1 -  118:
/DERIVEDFIELD  ORICOD_LS "${NORME_CF}GTA~"
/DERIVEDFIELD  PLUS_14_CHAMPS 14"~"
/DERIVEDFIELD  NEWCOLS1_NF "~"
/OUTFILE ${SORT_O}
/REFORMAT COLS1,PLUS_14_CHAMPS,COLS2,ORICOD_LS,COLS3 ,NEWCOLS1_NF,COLS4
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
# Retrocession reversal and carried forward of previous balance sheet in the book
#-----------------------------------------------------------------------------
LIBEL="Retrocession reversal and carried forward in progress ..."
PRG=ESTM7602b
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${PARM_INVCONSO_D}
BALSHTMTH_NF ${PARM_CONSOMTH}
TYPFIC GLTRR
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_FTECLEDR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTRSO_O.dat
EXECPRG

NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
# Double entry transaction code addition in  GT
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_ESTM7602b_DLSGTRSO_O.dat
export ${PRG}_I2=${ESF_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTRSO_O.dat
EXECPRG

NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Update ORICOD_LS for FTECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTM7603_DLSGTRSO_O.dat 800  1"
SORT_O="${ESF_FTECLEDR_OPNG} OVERWRITE"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS COLS1        1:1 -   56:,
        COLS2       58:1 -   71:
/DERIVEDFIELD  ORICOD_LS "${NORME_CF}GTR~"
/OUTFILE ${SORT_O}
/REFORMAT COLS1,ORICOD_LS,COLS2
/COPY
exit
EOF
SORT

#[004] ##[006]
if [ "${NORME_CF}" = "I17G" ] && [ "${IDF_CT}" != "I17G_OMG_OPNG_SIM" ]
then
 
NSTEP=${NJOB}_130
#------------------------------------------------------------------------------
# Copy ESF_FTECLEDR_OPNG file
#------------------------------------------------------------------------------
LIBEL="copy ESF_FTECLEDR_OPNG files"
EXECKSH_MODE=P
EXECKSH "cp ${ESF_FTECLEDR_OPNG} ${I17S_ESF_FTECLEDR_OPNG}"

NSTEP=${NJOB}_140
#------------------------------------------------------------------------------
# Copy ESF_FTECLEDA_OPNG file
#------------------------------------------------------------------------------
LIBEL="copy ESF_FTECLEDA_OPNG files"
EXECKSH_MODE=P
EXECKSH "cp ${ESF_FTECLEDA_OPNG} ${I17S_ESF_FTECLEDA_OPNG}"

fi

NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Archiving annual data files : ${ESF_FTECLEDA_OPNG}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${ESF_FTECLEDA_OPNG}  > ${ESF_FTECLEDA_OPNG_ARC}"

NSTEP=${NJOB}_210
#-----------------------------------------------------------------------------
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Archiving annual data files : ${ESF_FTECLEDR_OPNG}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${ESF_FTECLEDR_OPNG}  > ${ESF_FTECLEDR_OPNG_ARC}"

NSTEP=${NJOB}_220
#------------------------------------------------------------------------------
# Empty ESF_CUR_FTECLEDx files
#------------------------------------------------------------------------------
LIBEL="Empty ESF_FTECLEDA_CUR files"
EXECKSH_MODE=P
EXECKSH "cp ${DFILP}/empty.dat ${ESF_FTECLEDA_CUR}"

NSTEP=${NJOB}_230
#------------------------------------------------------------------------------
# Empty ESF_CUR_FTECLEDx files
#------------------------------------------------------------------------------
LIBEL="Empty ESF_FTECLEDR_CUR files"
EXECKSH_MODE=P
EXECKSH "cp ${DFILP}/empty.dat ${ESF_FTECLEDR_CUR}"

JOBEND

