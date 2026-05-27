#!/bin/bash
#====================================================================================================
# NOM DE L'APPLICATION          : INITIAL PROFITABILITY
# NOM DU SCRIPT SHELL           : ESFD3711.cmd
# REVISION                      : 
# DATE DE CREATION              : 
# AUTEUR                        : 
# REFERENCES DES SPECIFICATIONS :
#----------------------------------------------------------------------------------------------------
# DESCRIPTION :
# 
#----------------------------------------------------------------------------------------------------
# HISTORIQUE DES MODIFICATIONS :
# 	<JJ/MM/AAAA>   	<AUTHOR>   		<SPIRA> 	<DESCRIPTION OF A CHANGE>
#	25/03/2020    	L.ELFAHIM       79070		RETRO P && RETRO NP IMPLEMENTATION
#	15/09/2020    	L.ELFAHIM       90001		CORRECTION REGRESSION OF NDIC INI IMPLEMENTATION
#	24/11/2020    	L.ELFAHIM       91098		Bug Fix
#====================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters

# Job Initialisation
JOBINIT

echo ${ESF_GTSII_ESCOMPTE_DSC}
echo ${ESF_GTSII_ESCOMPTE_RAD}
echo ${ESF_GTSII_CSM}

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Sort file Cashflow for prg"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_ESCOMPTE_DSC} 2000 1"
SORT_I2="${ESF_GTSII_ESCOMPTE_RAD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_CSU_INI_SORT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CTR_NF      8:1 	- 8:,
	END_NT   	9:1 	- 9:EN,
	SEC_NF     	10:1 	- 10:EN,
	UWY_NF     	11:1 	- 11:,
	UW_NT      	12:1 	- 12:EN,
	RETCTR_NF 	24:1 	- 24:,
	RETEND_NT 	25:1 	- 25:EN,
	RETSEC_NF 	26:1 	- 26:EN,
	RTY_NF 		27:1 	- 27:,
	RETUW_NT 	28:1 	- 28:EN,
	PLC_NT		36:1 	- 36:EN,
	ACMTRS3		124:1	- 124:,
	FILLER     	1:1  	- 124:	       
/KEYS   
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	RETCTR_NF,	
	RETEND_NT, 	
	RETSEC_NF, 	
	RTY_NF, 		
	RETUW_NT,
	PLC_NT,
	ACMTRS3
/OUTFILE ${SORT_O}
/REFORMAT FILLER
exit
EOF
SORT

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="INITIAL PROFITABILITY AT CSUOE/CSUOEP LEVEL"
PRG=ESFC3710
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_CSM_CSU_INI_SORT.dat
export ${PRG}_O1=${ESF_GTSII_CSM}
EXECPRG

JOBEND
