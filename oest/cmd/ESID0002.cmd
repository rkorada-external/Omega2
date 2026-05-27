#!/bin/ksh
#=============================================================================
# nom de l'application          : Tri génerique de fichier
# nom du script SHELL           : ESID0002.cmd
# revision                      : $Revision: 1.0 $
# date de creation              : 20/04/2015
# auteur                        : Takfarinas LAIDI
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#   Cette chaine tri un fichier et n'en conserve que les derniers mouvements.
#
#-----------------------------------------------------------------------------
# historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
# 	 20/04/2015      LTA        spot 28559: Création de la chaine
#==============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Job Initialisation
JOBINIT

# Get input parameters
IBC=$1                   # IB of calling chain
OUTPUT_FILE_NAME=$2      # Output file 1
OUTPUT_FILE_NAME_DIFF=$3 # Output file 2 - Not sync
INPUT_FILE1=$4 		       # /path/to/file/file1.dat

# Optional fusion file
INPUT_FILE2=$5    # /path/to/file/file2.dat
FUSION=1          # Boolean set to FALSE

if [[ ${#OUTPUT_FILE_NAME} -eq 0 ]]
then
	echo "Output file name (1) is empty. JOBEND"
	JOBEND
fi

if [[ ${#OUTPUT_FILE_NAME_DIFF} -eq 0 ]]
then
	echo "Output diff file name (2) is empty. JOBEND"
	JOBEND
fi

if [[ ${#INPUT_FILE1} -eq 0 ]]
then
  echo "Input File path is empty. JOBEND"
  JOBEND
fi

if [[ ${#INPUT_FILE2} -ne 0 ]]; 
then
  echo "Merging :
  ${INPUT_FILE1} 
  and 
  ${INPUT_FILE2}"
  FUSION=0 # Boolean set to TRUE if INPUT_FILE2 is set
fi

NSTEP=${NJOB}_050
# Sorting file for ESTC2043
#------------------------------------------------------------------------------
LIBEL="Sorting file for ESTC2043"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT_FILE1} 1000 1"
if [[ ${FUSION} -eq 0 ]]; 
then
  SORT_I2="${INPUT_FILE2} 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IBC}_SORT_FILE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			2:1 - 2:,
	END_NT			3:1 - 3:,
	SEC_NF			4:1 - 4:,
	UWY_NF			5:1 - 5:,
	UW_NT			6:1 - 6:,
	ACY_NF			7:1 - 7:,
	CRE_D			8:1 - 8:,
	ACMTRS_NT		10:1 - 10:,
	BALSHEY_NF		11:1 - 11:,
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	ACM_NF			25:1 - 25:EN
/KEYS 
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF,
	BALSHEY_NF,
	CRE_D
exit
EOF
SORT

NSTEP=${NJOB}_100
# ESTC2043
#------------------------------------------------------------------------------
LIBEL="ESTC2043"
PRG=ESTC2043
export ${PRG}_I1=${DFILT}/${NJOB}_050_${IBC}_SORT_FILE.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IBC}_${PRG}_SORT_FILE.dat
EXECPRG

NSTEP=${NJOB}_150
# Sorting file for ESTC2040
#------------------------------------------------------------------------------
LIBEL="Sorting file for ESTC2040"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IBC}_ESTC2043_SORT_FILE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IBC}_SORT_FILE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF			2:1 - 2:,
	END_NT			3:1 - 3:,
	SEC_NF			4:1 - 4:,
	UWY_NF			5:1 - 5:,
	UW_NT			6:1 - 6:,
	ACY_NF			7:1 - 7:,
	CRE_D			8:1 - 8:,
	ACMTRS_NT		10:1 - 10:,
	BALSHEY_NF		11:1 - 11:,
	BALSHTMTH_NF	12:1 - 12:EN, 
	DETTRNCOD_CF	20:1 - 20:,
	GAAP_NF			22:1 - 22:,
	ACM_NF			25:1 - 25:EN
/KEYS 
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ACY_NF,
	ACM_NF,
	ACMTRS_NT,
	DETTRNCOD_CF,
	GAAP_NF,
	BALSHEY_NF DESCENDING,
	BALSHTMTH_NF DESCENDING,
	CRE_D DESCENDING
exit
EOF
SORT

NSTEP=${NJOB}_200
# ESTC2040
#------------------------------------------------------------------------------
LIBEL="ESTC2040"
PRG=ESTC2040
export ${PRG}_I1=${DFILT}/${NJOB}_150_${IBC}_SORT_FILE.dat
export ${PRG}_O1=${OUTPUT_FILE_NAME}
export ${PRG}_O2=${OUTPUT_FILE_NAME_DIFF}
EXECPRG

gzip -c ${OUTPUT_FILE_NAME_DIFF}   >     ${OUTPUT_FILE_NAME_DIFF}.gz

NSTEP=${NJOB}_250
# Delete temporary files
#------------------------------------------------------------------------------
LIBEL="Delete temporary files"
RMFIL "${DFILT}/${NJOB}_50_${IBC}_SORT_FILE.dat"
RMFIL "${DFILT}/${NJOB}_100_${IBC}_ESTC2043_SORT_FILE.dat"
RMFIL "${DFILT}/${NJOB}_150_${IBC}_SORT_FILE.dat"

# Job End
JOBEND
