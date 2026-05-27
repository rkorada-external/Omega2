/ksh
#=============================================================================
# nom de l'application		:  
#				  
# nom du script SHELL		: ESFD5051.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 06/12/2022
# auteur			: M.SEKBRAOUDINE
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#         Copy of I17G files for I17S
#-----------------------------------------------------------------------------
# Input files
#
# Output files
#
# Job launched by ESFD5050.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# [001]  DAD 21/07/2023  110206  - Filter TRERETFACCTR I17G with FI17CLOPER I17S  
# [002]  MZM 29/08/2023  110422  - Filter  EST_GTSII_DAC_LKI_PREV I17G with FI17CLOPER I17S Fix IN2
# [003]  DAD 21/11/2023  110858  - replace norme I17G too I17S for ESF_GTSII_DAC_LKI_PREV
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

#Get input parameters
CLODAT_D=$1
BALSHEY_NF=$2

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_010
#------------------------------------------------------------------------------
LIBEL="Copy EST_FLORETFACTOR_INI into ESF_FLORETFACTOR_INI"
EXECKSH "cp ${EST_FLORETFACTOR_INI} ${ESF_FLORETFACTOR_INI}"

NSTEP=${NJOB}_020
#------------------------------------------------------------------------------
LIBEL="Copy EST_FCTRGRO into ESF_FCTRGRO"
EXECKSH "cp ${EST_FCTRGRO} ${ESF_FCTRGRO}"

NSTEP=${NJOB}_030
#------------------------------------------------------------------------------
LIBEL="Copy EST_IADPERIFR into ESF_IADPERIFR"
EXECKSH "cp ${EST_IADPERIFR} ${ESF_IADPERIFR}"

NSTEP=${NJOB}_040
#------------------------------------------------------------------------------
LIBEL="Copy EST_IADPERIFCI into ESF_IADPERIFCI"
EXECKSH "cp ${EST_IADPERIFCI} ${ESF_IADPERIFCI}"

NSTEP=${NJOB}_050
#------------------------------------------------------------------------------
LIBEL="Copy EST_IADPERIFCT into ESF_IADPERIFCT"
EXECKSH "cp ${EST_IADPERIFCT} ${ESF_IADPERIFCT}"

NSTEP=${NJOB}_060
#------------------------------------------------------------------------------
LIBEL="Copy EST_FCES into ESF_FCES"
EXECKSH "cp ${EST_FCES} ${ESF_FCES}"

NSTEP=${NJOB}_070
#------------------------------------------------------------------------------
LIBEL="Copy EST_FPLC into ESF_FPLC"
EXECKSH "cp ${EST_FPLC} ${ESF_FPLC}"

NSTEP=${NJOB}_080
#------------------------------------------------------------------------------
LIBEL="Copy EST_FPLACEMT0 into ESF_FPLACEMT0"
EXECKSH "cp ${EST_FPLACEMT0} ${ESF_FPLACEMT0}"

NSTEP=${NJOB}_090
#------------------------------------------------------------------------------
LIBEL="Copy EST_FPLATXCUMALL into ESF_FPLATXCUMALL"
EXECKSH "cp ${EST_FPLATXCUMALL} ${ESF_FPLATXCUMALL}"

NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="Copy EST_FPLATXCUM into ESF_FPLATXCUM"
EXECKSH "cp ${EST_FPLATXCUM} ${ESF_FPLATXCUM}"

# [001]
NSTEP=${NJOB}_110
#------------------------------------------------------------------------------
LIBEL="Filter TRERETFACCTR I17G with FI17CLOPER I17S"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TRERETFACCTR} 2000 1"
SORT_O="${ESF_TRERETFACCTR} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	SSD_CF_F1 	  10:1 - 10:,
	ESB_CF_F1     11:1 - 11:,
	SSD_CF_F2	   1:1 -  1:,
	ESB_CF_F2	   2:1 -  2:,
	FIELDS_F1_1_20 1:1 - 20:
/JOINKEYS
	SSD_CF_F1,
    ESB_CF_F1
/INFILE ${EST_FI17CLOPER} 2000 1 "~"          
/JOINKEYS
	SSD_CF_F2,
    ESB_CF_F2
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:FIELDS_F1_1_20
exit
EOF
SORT

NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
LIBEL="Copy EST_SECIFRS_CR_EXTRACT into ESF_SECIFRS_CR_EXTRACT"
EXECKSH "cp ${EST_SECIFRS_CR_EXTRACT} ${ESF_SECIFRS_CR_EXTRACT}"

NSTEP=${NJOB}_130
#------------------------------------------------------------------------------
LIBEL="Copy EST_IADPERIFCI into ESF_IADPERIFCI"
EXECKSH "cp ${EST_IADPERIFCI_5040} ${ESF_IADPERIFCI_5040}"

NSTEP=${NJOB}_140
#------------------------------------------------------------------------------
LIBEL="Copy EST_IADPERIFCT into ESF_IADPERIFCT"
EXECKSH "cp ${EST_IADPERIFCT_5040} ${ESF_IADPERIFCT_5040}"

NSTEP=${NJOB}_150
#------------------------------------------------------------------------------
LIBEL="Copy EST_IADPERIFR into ESF_IADPERIFR"
EXECKSH "cp ${EST_IADPERIFR_5040} ${ESF_IADPERIFR_5040}"

NSTEP=${NJOB}_160
#------------------------------------------------------------------------------
LIBEL="Copy EST_FCES_5040 into ESF_FCES_5040"
EXECKSH "cp ${EST_FCES_5040} ${ESF_FCES_5040}"

NSTEP=${NJOB}_170
#------------------------------------------------------------------------------
LIBEL="Copy EST_FSEGPATTERNDSCf17 into ESF_FSEGPATTERNDSCf17"
EXECKSH_MODE=W
EXECKSH_I=${EST_FSEGPATTERNDSCf17}
EXECKSH_O=${ESF_FSEGPATTERNDSCf17}
EXECKSH 'sed s/I17G/I17S/'

NSTEP=${NJOB}_180
#------------------------------------------------------------------------------
LIBEL="Copy EST_GTSII_ESCOMPTE_PREVCLODAT into ESF_GTSII_ESCOMPTE_PREVCLODAT"
EXECKSH_MODE=W
EXECKSH_I=${EST_GTSII_ESCOMPTE_PREVCLODAT}
EXECKSH_O=${ESF_GTSII_ESCOMPTE_PREVCLODAT}
EXECKSH 'sed s/I17G/I17S/'

NSTEP=${NJOB}_190
#------------------------------------------------------------------------------
LIBEL="Copy EST_GTSII_ESCOMPTE_RAD_PREVCLODAT into ESF_GTSII_ESCOMPTE_RAD_PREVCLODAT"
EXECKSH_MODE=W
EXECKSH_I=${EST_GTSII_ESCOMPTE_RAD_PREVCLODAT}
EXECKSH_O=${ESF_GTSII_ESCOMPTE_RAD_PREVCLODAT}
EXECKSH 'sed s/I17G/I17S/'

NSTEP=${NJOB}_200
#------------------------------------------------------------------------------
LIBEL="Copy EST_GTSII_GLOBAL_CASHFLOW_PREV into ESF_GTSII_GLOBAL_CASHFLOW_PREV"
EXECKSH_MODE=W
EXECKSH_I=${EST_GTSII_GLOBAL_CASHFLOW_PREV}
EXECKSH_O=${ESF_GTSII_GLOBAL_CASHFLOW_PREV}
EXECKSH 'sed s/I17G/I17S/'

# [002]

# [003]
NSTEP=${NJOB}_205
#------------------------------------------------------------------------------
LIBEL="Filter EST_GTSII_DAC_LKI_PREV I17G with FI17CLOPER I17S"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTSII_DAC_LKI_PREV} 2000 1"
SORT_O="${ESF_GTSII_DAC_LKI_PREV} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	SSD_CF_F1 	  1:1 - 1:,
	ESB_CF_F1     2:1 - 2:,
	SSD_CF_F2	   1:1 -  1:,
	ESB_CF_F2	   2:1 -  2:,
	FIELDS_F1_1_49 1:1 - 49:,
	FIELDS_F1_51_118 51:1 - 118:
/JOINKEYS
	SSD_CF_F1,
    ESB_CF_F1
/INFILE ${EST_FI17CLOPER} 2000 1 "~"          
/JOINKEYS
	SSD_CF_F2,
    ESB_CF_F2
/DERIVEDFIELD
	NORME_I17S "I17S"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:FIELDS_F1_1_49, NORME_I17S, FIELDS_F1_51_118
exit
EOF
SORT

##NSTEP=${NJOB}_210
###------------------------------------------------------------------------------
##LIBEL="Copy EST_GTSII_DAC_LKI_PREV into ESF_GTSII_DAC_LKI_PREV"
##EXECKSH_MODE=W
##EXECKSH_I=${EST_GTSII_DAC_LKI_PREV}
##EXECKSH_O=${ESF_GTSII_DAC_LKI_PREV}
##EXECKSH 'sed s/I17G/I17S/'

# [002]

NSTEP=${NJOB}_213
#------------------------------------------------------------------------------
LIBEL="Filter EST_FTECLEDA_REJ_PREV I17G with FI17CLOPER I17S"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA_REJ_PREV} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESF_FTECLEDA_REJ_PREV.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	SSD_CF_F1 	  1:1 - 1:,
	ESB_CF_F1     2:1 - 2:,
	SSD_CF_F2	   1:1 -  1:,
	ESB_CF_F2	   2:1 -  2:,
	FIELDS_F1_1_118 1:1 - 118:
/JOINKEYS
	SSD_CF_F1,
    ESB_CF_F1
/INFILE ${EST_FI17CLOPER} 2000 1 "~"          
/JOINKEYS
	SSD_CF_F2,
    ESB_CF_F2
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:FIELDS_F1_1_118
exit
EOF
SORT

EXECKSH "cp ${DFILT}/${NJOB}_213_${IB}_ESF_FTECLEDA_REJ_PREV.dat ${ESF_FTECLEDA_REJ_PREV}"

NSTEP=${NJOB}_215
#------------------------------------------------------------------------------
LIBEL="Filter EST_FTECLEDR_REJ_PREV I17G with FI17CLOPER I17S"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDR_REJ_PREV} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESF_FTECLEDR_REJ_PREV.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	SSD_CF_F1 	  1:1 - 1:,
	ESB_CF_F1     2:1 - 2:,
	SSD_CF_F2	   1:1 -  1:,
	ESB_CF_F2	   2:1 -  2:,
	FIELDS_F1_1_118 1:1 - 71:
/JOINKEYS
	SSD_CF_F1,
    ESB_CF_F1
/INFILE ${EST_FI17CLOPER} 2000 1 "~"          
/JOINKEYS
	SSD_CF_F2,
    ESB_CF_F2
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:FIELDS_F1_1_118
exit
EOF
SORT

EXECKSH "cp ${DFILT}/${NJOB}_215_${IB}_ESF_FTECLEDR_REJ_PREV.dat ${ESF_FTECLEDR_REJ_PREV}"

NSTEP=${NJOB}_216
#------------------------------------------------------------------------------
LIBEL="Filter EST_FTECLEDA_OPNG_PREV I17G with FI17CLOPER I17S"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA_OPNG_PREV} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESF_FTECLEDA_OPNG_PREV.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	SSD_CF_F1 	  1:1 - 1:,
	ESB_CF_F1     2:1 - 2:,
	SSD_CF_F2	   1:1 -  1:,
	ESB_CF_F2	   2:1 -  2:,
	FIELDS_F1_1_118 1:1 - 118:
/JOINKEYS
	SSD_CF_F1,
    ESB_CF_F1
/INFILE ${EST_FI17CLOPER} 2000 1 "~"          
/JOINKEYS
	SSD_CF_F2,
    ESB_CF_F2
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:FIELDS_F1_1_118
exit
EOF
SORT

EXECKSH "cp ${DFILT}/${NJOB}_216_${IB}_ESF_FTECLEDA_OPNG_PREV.dat ${ESF_FTECLEDA_OPNG_PREV}"

NSTEP=${NJOB}_218
#------------------------------------------------------------------------------
LIBEL="Filter EST_FTECLEDR_OPNG_PREV I17G with FI17CLOPER I17S"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDR_OPNG_PREV} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESF_FTECLEDR_OPNG_PREV.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	SSD_CF_F1 	  1:1 - 1:,
	ESB_CF_F1     2:1 - 2:,
	SSD_CF_F2	   1:1 -  1:,
	ESB_CF_F2	   2:1 -  2:,
	FIELDS_F1_1_118 1:1 - 71:
/JOINKEYS
	SSD_CF_F1,
    ESB_CF_F1
/INFILE ${EST_FI17CLOPER} 2000 1 "~"          
/JOINKEYS
	SSD_CF_F2,
    ESB_CF_F2
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:FIELDS_F1_1_118
exit
EOF
SORT

EXECKSH "cp ${DFILT}/${NJOB}_218_${IB}_ESF_FTECLEDR_OPNG_PREV.dat ${ESF_FTECLEDR_OPNG_PREV}"


# [002] Fin Modif


NSTEP=${NJOB}_220
#------------------------------------------------------------------------------
LIBEL="Copy EST_GTSII_GLOBAL_CASHFLOW_RAD_PREV into ESF_GTSII_GLOBAL_CASHFLOW_RAD_PREV"
EXECKSH_MODE=W
EXECKSH_I=${EST_GTSII_GLOBAL_CASHFLOW_RAD_PREV}
EXECKSH_O=${ESF_GTSII_GLOBAL_CASHFLOW_RAD_PREV}
EXECKSH 'sed s/I17G/I17S/'

NSTEP=${NJOB}_230
#------------------------------------------------------------------------------
LIBEL="Copy EST_FSEGPROF_STD_PREVIOUS into ESF_FSEGPROF_STD_PREVIOUS"
EXECKSH_MODE=W
EXECKSH_I=${EST_FSEGPROF_STD_PREVIOUS}
EXECKSH_O=${ESF_FSEGPROF_STD_PREVIOUS}
EXECKSH 'sed s/I17G/I17S/'

NSTEP=${NJOB}_240
#------------------------------------------------------------------------------
LIBEL="Copy EST_GTSII_CSM_CASHFLOW_PREV into ESF_GTSII_CSM_CASHFLOW_PREV"
EXECKSH_MODE=W
EXECKSH_I=${EST_GTSII_CSM_CASHFLOW_PREV}
EXECKSH_O=${ESF_GTSII_CSM_CASHFLOW_PREV}
EXECKSH 'sed s/I17G/I17S/'



JOBEND


