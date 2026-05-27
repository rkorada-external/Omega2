#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD4011.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 23\03\2021
# auteur                        : AGD
#---------------------------------------------------------------------------------
# description
#  IFRS17 REQ PAA
#
#---------------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd 

# Job Initialisation
JOBINIT

ICLODAT_M=$(echo ${PARM_ICLODAT_D} | awk '{print substr($0,5,2)}')

# Get input parameters

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ICLODAT_D........................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> ICLODAT_M........................................................: ${ICLODAT_M}"
ECHO_LOG "#===> NORME_CF.........................................................: ${NORME_CF}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> EST_IRDPERICASE0.................................................: ${EST_IRDPERICASE0}"
ECHO_LOG "#===> EST_IADPERICASE_STD..............................................: ${EST_IADPERICASE_STD}"
ECHO_LOG "#===> EST_FPLC.........................................................: ${EST_FPLC}"
ECHO_LOG "#===> EST_FCES.........................................................: ${EST_FCES}"
ECHO_LOG "#===> EST_DLCUMGTAAR...................................................: ${EST_DLCUMGTAAR}"
ECHO_LOG "#===> ESF_FTECLEDR.....................................................: ${ESF_FTECLEDR}"
ECHO_LOG "#===> ESF_FTECLEDA.....................................................: ${ESF_FTECLEDA}"
ECHO_LOG "#===> EPO_FCURQUOT_TXT.................................................: ${EPO_FCURQUOT_TXT}"
ECHO_LOG "#===> ESF_FI17CLOPER...................................................: ${ESF_FI17CLOPER}"
ECHO_LOG "#===> ESF_FTRSLNK_TXT..................................................: ${ESF_FTRSLNK_TXT}"
ECHO_LOG "#===> ESF_FTECLEDR_OPNG................................................: ${ESF_FTECLEDR_OPNG}"
ECHO_LOG "#===> ESF_FTECLEDR_REJ.................................................: ${ESF_FTECLEDR_REJ}"
ECHO_LOG "#===> ESF_FTECLEDA_OPNG................................................: ${ESF_FTECLEDA_OPNG}"
ECHO_LOG "#===> ESF_FTECLEDA_REJ.................................................: ${ESF_FTECLEDA_REJ}"
ECHO_LOG "#===> EST_ACC_RETRO_NDIC_AMOUNT........................................: ${EST_ACC_RETRO_NDIC_AMOUNT}"
ECHO_LOG "#===> EST_ACC_NDIC_AMOUNT..............................................: ${EST_ACC_NDIC_AMOUNT}"

ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> EST_PAA_RETRO....................................................: ${EST_PAA_RETRO}"
ECHO_LOG "#===> EST_PAA_ASSUM....................................................: ${EST_PAA_ASSUM}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_1
# Filter on PAA compliant configuration
#------------------------------------------------------------------------------
LIBEL="Filter on PAA (PARM3) compliant configuration"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FI17CLOPER} 2000 1"
SORT_O="${DFILI}/${NSTEP}_${IB}_ESF_FI17CLOPER_PAA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2: EN,
        PARM1 3:1 - 3:,
        PARM2 4:1 - 4:,
		PARM3 5:1 - 5:,
        PARM4 6:1 - 6:,
        PARM5 7:1 - 7:,
        PARM6 8:1 - 8:,
		PARM7 9:1 - 9:,
        PARM8 10:1 - 10:,
        PARM9 11:1 - 11:,
        PARM10 12:1 - 12:
/KEYS SSD_CF,
      ESB_CF
/CONDITION PAA (PARM3 = "1")
/OUTFILE ${SORT_O}
/INCLUDE PAA
exit
EOF
SORT

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------

# inputs files
export ESTJ0012_PERICASE_RETRO="${EST_IRDPERICASE0}"
export ESTJ0012_PERICASE_ASSUM="${EST_IADPERICASE_STD}"
export ESTJ0012_FPLC="${EST_FPLC}"
export ESTJ0012_FCES="${EST_FCES}"
export ESTJ0012_DLCUMGTAAR="${EST_DLCUMGTAAR}"
export ESTJ0012_FTECLEDR="${ESF_FTECLEDR}"
export ESTJ0012_FTECLEDA="${ESF_FTECLEDA}"
export ESTJ0012_CURRENCY_EX_RATE="${EPO_FCURQUOT_TXT}"
export ESTJ0012_FCLOPER="${DFILI}/${NJOB}_1_${IB}_ESF_FI17CLOPER_PAA.dat"
export ESTJ0012_FTRSLNK="${ESF_FTRSLNK_TXT}"
if [[ "${ICLODAT_M}" = "01" || "${ICLODAT_M}" = "02" || "${ICLODAT_M}" = "03" ]];
then
	export ESTJ0012_FTECLEDR_OPNG="${ESF_FTECLEDR_OPNG}"
	export ESTJ0012_FTECLEDA_OPNG="${ESF_FTECLEDA_OPNG}"
else
	export ESTJ0012_FTECLEDR_OPNG="${DFILP}/empty.dat"
	export ESTJ0012_FTECLEDA_OPNG="${DFILP}/empty.dat"
fi
export ESTJ0012_FTECLEDR_REJ="${ESF_FTECLEDR_REJ}"
export ESTJ0012_FTECLEDA_REJ="${ESF_FTECLEDA_REJ}"
export ESTJ0012_NDIC_RETRO="${EST_ACC_RETRO_NDIC_AMOUNT}"
export ESTJ0012_NDIC_ASSUM="${EST_ACC_NDIC_AMOUNT}"

# tmp files
export ESTJ0012_SORTED_PERICASE_RETRO="${DFILT}/${NJOB}_1_${IB}_SORTED_PERICASE_RETRO.dat"
export ESTJ0012_SORTED_PERICASE_ASSUM="${DFILT}/${NJOB}_1_${IB}_SORTED_PERICASE_ASSUM.dat"
export ESTJ0012_SORTED_FPLC="${DFILT}/${NJOB}_1_${IB}_SORTED_FPLC.dat"
export ESTJ0012_SORTED_FCES="${DFILT}/${NJOB}_1_${IB}_SORTED_FCES.dat"
export ESTJ0012_SORTED_DLCUMGTAAR_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR_RP.dat"
export ESTJ0012_SORTED_DLCUMGTAAR_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR_RNP.dat"
export ESTJ0012_SORTED_DLCUMGTAAR_A="${DFILT}/${NJOB}_1_${IB}_SORTED_DLCUMGTAAR_A.dat"
export ESTJ0012_SORTED_FTECLEDR="${DFILT}/${NJOB}_1_${IB}_SORTED_FTECLEDR.dat"
export ESTJ0012_SORTED_FTECLEDA="${DFILT}/${NJOB}_1_${IB}_SORTED_FTECLEDA.dat"
export ESTJ0012_PERICASE_EXTENDED_R="${DFILT}/${NJOB}_1_${IB}_PERICASE_EXTENDED_R.dat"
export ESTJ0012_SORTED_PERICASE_EXTENDED_RP="${DFILT}/${NJOB}_1_${IB}_SORTED_PERICASE_EXTENDED_RP.dat"
export ESTJ0012_SORTED_PERICASE_EXTENDED_RNP="${DFILT}/${NJOB}_1_${IB}_SORTED_PERICASE_EXTENDED_RNP.dat"
export ESTJ0012_MERGED_FTECLEDA="${DFILT}/${NJOB}_1_${IB}_MERGED_FTECLEDA.dat"
export ESTJ0012_MERGED_FTECLEDR="${DFILT}/${NJOB}_1_${IB}_MERGED_FTECLEDR.dat"
export ESTJ0012_SORTED_MERGED_FTECLEDA="${DFILT}/${NJOB}_1_${IB}_SORTED_MERGED_FTECLEDA.dat"
export ESTJ0012_SORTED_MERGED_FTECLEDR="${DFILT}/${NJOB}_1_${IB}_SORTED_MERGED_FTECLEDR.dat"
export ESTJ0012_PAA_R_NOT_MERGED="${DFILT}/${NJOB}_1_${IB}_PAA_R_NOT_MERGED.dat"
export ESTJ0012_PAA_A_NOT_MERGED="${DFILT}/${NJOB}_1_${IB}_PAA_A_NOT_MERGED.dat"
export ESTJ0012_SORTED_NDIC_RETRO="${DFILT}/${NJOB}_1_${IB}_SORTED_NDIC_RETRO.dat"
export ESTJ0012_SORTED_NDIC_ASSUM="${DFILT}/${NJOB}_1_${IB}_SORTED_NDIC_ASSUM.dat"

# outputs files
export ESTJ0012_PAA_RETRO="${EST_PAA_RETRO}"
export ESTJ0012_PAA_ASSUM="${EST_PAA_ASSUM}"

# CMD variable
export SYNCSORT_CMD_ESTJ0012_SORT_PERICASE_R_BY_CSUOER=${DCMD}/ESTS0020.cmd
export SYNCSORT_CMD_ESTJ0012_SORT_PERICASE_A_BY_CSUOE=${DCMD}/ESTS0003.cmd
export SYNCSORT_CMD_ESTJ0012_SORT_FPLC_BY_CSUOER=${DCMD}/ESTS0040.cmd
export SYNCSORT_CMD_ESTJ0012_SORT_FCES_BY_CSUOER=${DCMD}/ESTS0023.cmd
export SYNCSORT_CMD_ESTJ0012_SORT_DLCUMGTAAR_BY_FULL_KEY=${DCMD}/ESTS0051.cmd
export SYNCSORT_CMD_ESTJ0012_SORT_FTECLEDR_BY_FULL_KEY=${DCMD}/ESTS0011.cmd
export SYNCSORT_CMD_ESTJ0012_SORT_FTECLEDA_BY_CSUOE=${DCMD}/ESTS0019.cmd
export SYNCSORT_CMD_ESTJ0012_SORT_PERICASE_EXTENDED_BY_FULL_KEY=${DCMD}/ESTS0052.cmd
export SYNCSORT_CMD_ESTJ0012_MERGE=${DCMD}/ESTS0005.cmd
export SYNCSORT_CMD_ESTJ0012_SORT_NDIC_R_BY_FULL_KEY=${DCMD}/ESTS0057.cmd
export SYNCSORT_CMD_ESTJ0012_SORT_NDIC_A_BY_CSUOE=${DCMD}/ESTS0058.cmd

# Jar execution
JSB_CHAIN="estj0012"
JSB_PARAMS="cloDate=${PARM_ICLODAT_D} normcf=${NORME_CF}"
EXECJSB

NSTEP=${NJOB}_2
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${IB}*.dat "

JOBEND