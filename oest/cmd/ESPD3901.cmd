#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS
#                                 Ecritures post omega
# nom du script SHELL		: ESPD3901.cmd
# revision			: $Revision:   1.3  $
# date de creation		: 20/06/2005
# auteur			: J. R
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#
# Input files
#       EPO_IADPERICASE	DFILP
#       EPO_DLSGTAASO 	DFILI
#       EPO_FTRSLNK    	DFILP
#       EPO_FCURQUOT   	DFILP
#       EPO_FCPLACC    	DFILP
#       EPO_FDETTRS     DFILP
#       EPO_FCTRSTAT  	DFILP
#
# Output files
#       EPO_FCTRSTATSO		DFILI
#       EPO_FSEGSTATSO		DFILI
#
# Launch C program ESP01001 ESTC3606
#
# job launched by ESPD3900.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 31/10/2012 Roger Cassis :spot:24041 - Solvency 2 - reprise du shell de prod
#[002] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
OPTION=$1
CRE_D=$2
CONSOYEA=$3

export LIMITINF_D=$((${CRE_D}-50000))

NSTEP=${NJOB}_01
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Split of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_DLSGTAASO}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAASO_01.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_05
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Introduction of accumulation code, ..."
PRG=ESPO1001
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${CONSOYEA}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EPO_IADPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_01_${IB}_SORT_DLSGTAASO_01.dat
export ${PRG}_I3=${EPO_FTRSLNK}
export ${PRG}_I4=${EPO_FCURQUOT}
export ${PRG}_I5=${EPO_FCPLACC}
export ${PRG}_I6=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSTAT_O.dat
EXECPRG

NSTEP=${NJOB}_07
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_01_${IB}_SORT_DLSGTAASO_01.dat

NSTEP=${NJOB}_10
# Sort old FCTRSTAT file
#------------------------------------------------------------------------------x
LIBEL="Sort old FCTRSTAT file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FCTRSTAT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_OLD_FCTRSTAT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
	END_NT 2:1 - 2:,
	SEC_NF 3:1 - 3:,
	UWY_NF 4:1 - 4:,
	UW_NT 5:1 - 5:
/KEYS	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount of intermediary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_ESPO1001_FSTAT_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_NEW_FCTRSTAT.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of FCTRSTAT file"
PRG=ESPO1002
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_OLD_FCTRSTAT.dat
export ${PRG}_I2=${DFILT}/${NJOB}_15_${IB}_SORT_NEW_FCTRSTAT.dat
export ${PRG}_O1=${EPO_FCTRSTATSO}
EXECPRG

NSTEP=${NJOB}_22
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_05_${IB}_ESPO1001_FSTAT_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_OLD_FCTRSTAT.dat
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_NEW_FCTRSTAT.dat

NSTEP=${NJOB}_25
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort of FCTRSTAT file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FCTRSTATSO} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRSTAT_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 6:1 - 6:,
        ESB_CF 7:1 - 7:,
        SEG_NF 101:1 - 101:,
        UWY_NF 4:1 - 4:,
        EGPCUR_CF 62:1 - 62:,
        SECACCSTS_CT 39:1 - 39:
/KEYS SSD_CF,
      ESB_CF,
      SEG_NF,
      UWY_NF,
      EGPCUR_CF
/CONDITION CLOSEACC SECACCSTS_CT != "9"
/OUTFILE ${SORT_O}
/INCLUDE CLOSEACC
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of FSEGSTAT file"
PRG=ESTC3606
export ${PRG}_I1=${DFILT}/${NJOB}_25_${IB}_SORT_FCTRSTAT_O.dat
export ${PRG}_O1=${EPO_FSEGSTATSO}
EXECPRG

NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat"

JOBEND
