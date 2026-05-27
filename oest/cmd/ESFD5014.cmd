#!/bin/ksh
#=============================================================================
# nom de l'application          : I17
# nom du script SHELL           : ESFD50114.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 18\05\2021
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# Description
#	merge of I17 INV files with I17 POS files
#-----------------------------------------------------------------------------
#---------------------------------------------------------------------------------
# [001] 20/10/2022 : MZM : spira 105660 LO FACTOR Table update process I17 
# [002] 20/02/2025 : MZM : spira 112299 Change in comm/tax/reinst prem should have no impact in POS 
# [003] 02/03/2026 MZM/Manish US 7046 CUT OFF : Move FCTRGRO FROM ESFD5014 TO ESFD5015
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

FILE_INV=$1
PROTO_FILE_POS=$2
OUTPUT_FILE=$3
IS_SEQ_MODE=$4

# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF................................................................: ${NORME_CF}"
ECHO_LOG "#===> TYPEINV.................................................................: ${TYPEINV}"
ECHO_LOG "#===> PARM_TYPEINV2...........................................................: ${PARM_TYPEINV2}"
ECHO_LOG "#===> CONTEXT_CT..............................................................: ${CONTEXT_CT}"
ECHO_LOG "#===> PARM_SEQ_MODE...........................................................: ${PARM_SEQ_MODE}"
ECHO_LOG "#===> ............................ INPUT INV .................................."
ECHO_LOG "#===> EST_IADPERICASE_5010....................................................: ${EST_IADPERICASE_5010}"
ECHO_LOG "#===> EST_IRDPERICASE_5010....................................................: ${EST_IRDPERICASE_5010}"
ECHO_LOG "#===> EST_IADPERICASE0_INI_5010...............................................: ${EST_IADPERICASE0_INI_5010}"
ECHO_LOG "#===> EST_IADPERICASE_DUMMY_5010..............................................: ${EST_IADPERICASE_DUMMY_5010}"
##ECHO_LOG "#===> EST_FCTRGROLESII_5010...................................................: ${EST_FCTRGROLESII_5010}"
ECHO_LOG "#===> EST_FCES_5010...........................................................: ${EST_FCES_5010}"
##ECHO_LOG "#===> EST_FCTRGRO_5010........................................................: ${EST_FCTRGRO_5010}"
##ECHO_LOG "#===> EST_FCTRGRO1_5010.......................................................: ${EST_FCTRGRO1_5010}"
ECHO_LOG "#===> EST_FCTRULT_5010........................................................: ${EST_FCTRULT_5010}"
ECHO_LOG "#===> EST_FPLACEMT0_5010......................................................: ${EST_FPLACEMT0_5010}"
ECHO_LOG "#===> EST_FPLACEMT2_5010......................................................: ${EST_FPLACEMT2_5010}"
ECHO_LOG "#===> EST_FPLATXCUM_5010......................................................: ${EST_FPLATXCUM_5010}"
ECHO_LOG "#===> EST_FPLATXCUMALL_5010...................................................: ${EST_FPLATXCUMALL_5010}"
ECHO_LOG "#===> EST_FPLC_5010...........................................................: ${EST_FPLC_5010}"
ECHO_LOG "#===> EST_FULTIMATES_5010.....................................................: ${EST_FULTIMATES_5010}"
ECHO_LOG "#===> EST_IADPERIFCI_5010.....................................................: ${EST_IADPERIFCI_5010}"
ECHO_LOG "#===> EST_IADPERIFCT_5010.....................................................: ${EST_IADPERIFCT_5010}"
ECHO_LOG "#===> EST_IADPERIFR_5010......................................................: ${EST_IADPERIFR_5010}"
#ECHO_LOG "#===> ESF_FLOARAT_I17_5010...................................................: ${ESF_FLOARAT_I17_5010}"
ECHO_LOG "#===> EST_FMARKET_5010........................................................: ${EST_FMARKET_5010}"
ECHO_LOG "#===> EST_FCES_5010...........................................................: ${EST_FCES_5010}"
ECHO_LOG "#===> ............................ INPUT POS .................................."
ECHO_LOG "#===> EST_IADPERICASE_5000....................................................: ${EST_IADPERICASE_5000}"
ECHO_LOG "#===> EST_IRDPERICASE_5000....................................................: ${EST_IRDPERICASE_5000}"
ECHO_LOG "#===> EST_IADPERICASE0_INI_5000...............................................: ${EST_IADPERICASE0_INI_5000}"
ECHO_LOG "#===> EST_IADPERICASE_DUMMY_5000..............................................: ${EST_IADPERICASE_DUMMY_5000}"
##ECHO_LOG "#===> EST_FCTRGROLESII_5000...................................................: ${EST_FCTRGROLESII_5000}"
ECHO_LOG "#===> EST_FCES_5000...........................................................: ${EST_FCES_5000}"
##ECHO_LOG "#===> EST_FCTRGRO_5000........................................................: ${EST_FCTRGRO_5000}"
##ECHO_LOG "#===> EST_FCTRGRO1_5000.......................................................: ${EST_FCTRGRO1_5000}"
ECHO_LOG "#===> EST_FCTRULT_5000........................................................: ${EST_FCTRULT_5000}"
ECHO_LOG "#===> EST_FPLACEMT0_5000......................................................: ${EST_FPLACEMT0_5000}"
ECHO_LOG "#===> EST_FPLACEMT2_5000......................................................: ${EST_FPLACEMT2_5000}"
ECHO_LOG "#===> EST_FPLATXCUM_5000......................................................: ${EST_FPLATXCUM_5000}"
ECHO_LOG "#===> EST_FPLATXCUMALL_5000...................................................: ${EST_FPLATXCUMALL_5000}"
ECHO_LOG "#===> EST_FPLC_5000...........................................................: ${EST_FPLC_5000}"
ECHO_LOG "#===> EST_FULTIMATES_5000.....................................................: ${EST_FULTIMATES_5000}"
ECHO_LOG "#===> EST_IADPERIFCI_5000.....................................................: ${EST_IADPERIFCI_5000}"
ECHO_LOG "#===> EST_IADPERIFCT_5000.....................................................: ${EST_IADPERIFCT_5000}"
ECHO_LOG "#===> EST_IADPERIFR_5000......................................................: ${EST_IADPERIFR_5000}"
#ECHO_LOG "#===> ESF_FLOARAT_I17_5000...................................................: ${ESF_FLOARAT_I17_5000}"
ECHO_LOG "#===> EST_FMARKET_5000........................................................: ${EST_FMARKET_5000}"
ECHO_LOG "#===> ESF_FLORETFACTOR_INI_5000...............................................: ${ESF_FLORETFACTOR_INI_5000}"
ECHO_LOG "#===> .............................. OUTPUT ..................................."
ECHO_LOG "#===> EST_IADPERICASE.........................................................: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_IRDPERICASE.........................................................: ${EST_IRDPERICASE}"
ECHO_LOG "#===> EST_IADPERICASE0_INI....................................................: ${EST_IADPERICASE0_INI}"
ECHO_LOG "#===> EST_IADPERICASE_DUMMY...................................................: ${EST_IADPERICASE_DUMMY}"
##ECHO_LOG "#===> EST_FCTRGROLESII........................................................: ${EST_FCTRGROLESII}"
ECHO_LOG "#===> EST_FCES................................................................: ${EST_FCES}"
##ECHO_LOG "#===> EST_FCTRGRO.............................................................: ${EST_FCTRGRO}"
##ECHO_LOG "#===> EST_FCTRGRO1............................................................: ${EST_FCTRGRO1}"
ECHO_LOG "#===> EST_FCTRULT.............................................................: ${EST_FCTRULT}"
ECHO_LOG "#===> EST_FPLACEMT0...........................................................: ${EST_FPLACEMT0}"
ECHO_LOG "#===> EST_FPLACEMT2...........................................................: ${EST_FPLACEMT2}"
ECHO_LOG "#===> EST_FPLATXCUM...........................................................: ${EST_FPLATXCUM}"
ECHO_LOG "#===> EST_FPLATXCUMALL........................................................: ${EST_FPLATXCUMALL}"
ECHO_LOG "#===> EST_FPLC................................................................: ${EST_FPLC}"
ECHO_LOG "#===> EST_FULTIMATES..........................................................: ${EST_FULTIMATES}"
ECHO_LOG "#===> EST_IADPERIFCI..........................................................: ${EST_IADPERIFCI}"
ECHO_LOG "#===> EST_IADPERIFCT..........................................................: ${EST_IADPERIFCT}"
ECHO_LOG "#===> EST_IADPERIFR...........................................................: ${EST_IADPERIFR}"
#ECHO_LOG "#===> ESF_FLOARAT_I17........................................................: ${ESF_FLOARAT_I17}"
ECHO_LOG "#===> EST_FMARKET.............................................................: ${EST_FMARKET}"
ECHO_LOG "#===> ESF_FLORETFACTOR_INI_5010...............................................: ${ESF_FLORETFACTOR_INI_5010}"
ECHO_LOG "#===> ESF_FLORETFACTOR_INI....................................................: ${ESF_FLORETFACTOR_INI}"
ECHO_LOG "#============================================================================"


if [[ -e "${EST_IADPERICASE_5010}" ]]
then

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
# Merge EST_IADPERICASE_INV with EST_IADPERICASE_POS without duplicate key from EST_IADPERICASE_INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADPERICASE when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_5010} 1000 1"
SORT_I2="${EST_IADPERICASE_5000} 1000 1"
SORT_O="${EST_IADPERICASE} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_05B
#-----------------------------------------------------------------------------
# Copy EST_IADPERICASE_POS if EST_IADPERICASE_INV didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADPERICASE when TYPEINV = POS AND EST_IADPERICASE_INV doesn't exist"
EXECKSH "cp ${EST_IADPERICASE_5000} ${EST_IADPERICASE}"

fi

if [[ -e "${EST_IRDPERICASE_5010}" ]]
then

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
# Merge EST_IRDPERICASE_INV with EST_IRDPERICASE_POS without duplicate key from EST_IRDPERICASE_INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IRDPERICASE when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE_5010} 1000 1"
SORT_I2="${EST_IRDPERICASE_5000} 1000 1"
SORT_O="${EST_IRDPERICASE} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_10B
#-----------------------------------------------------------------------------
# Copy EST_IRDPERICASE_POS if EST_IRDPERICASE_INV didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IRDPERICASE when TYPEINV = POS AND EST_IRDPERICASE_INV doesn't exist"
EXECKSH "cp ${EST_IRDPERICASE_5000} ${EST_IRDPERICASE}"

fi

if [[ -e "${EST_IADPERICASE0_INI_5010}" ]]
then

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
# Merge EST_IADPERICASE0_INI_INV with EST_IADPERICASE0_INI_POS without duplicate key from EST_IADPERICASE0_INI_INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADPERICASE0_INI when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0_INI_5010} 1000 1"
SORT_I2="${EST_IADPERICASE0_INI_5000} 1000 1"
SORT_O="${EST_IADPERICASE0_INI} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_15B
#-----------------------------------------------------------------------------
# Copy EST_IADPERICASE0_INI_POS if EST_IADPERICASE0_INI_INV didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADPERICASE0_INI when TYPEINV = POS AND EST_IADPERICASE0_INI_INV doesn't exist"
EXECKSH "cp ${EST_IADPERICASE0_INI_5000} ${EST_IADPERICASE0_INI}"

fi

if [[ -e "${EST_IADPERICASE_DUMMY_5010}" ]]
then

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
# Merge EST_IADPERICASE_DUMMY_INV with EST_IADPERICASE_DUMMY_POS without duplicate key from EST_IADPERICASE_DUMMY_INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADPERICASE_DUMMY when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_DUMMY_5010} 1000 1"
SORT_I2="${EST_IADPERICASE_DUMMY_5000} 1000 1"
SORT_O="${EST_IADPERICASE_DUMMY} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_20B
#-----------------------------------------------------------------------------
# Copy EST_IADPERICASE_DUMMY_POS if EST_IADPERICASE_DUMMY_INV didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADPERICASE_DUMMY when TYPEINV = POS AND EST_IADPERICASE_DUMMY_INV doesn't exist"
EXECKSH "cp ${EST_IADPERICASE_DUMMY_5000} ${EST_IADPERICASE_DUMMY}"

fi

##if [[ -e "${EST_FCTRGROLESII_5010}" ]]
##then
##
##NSTEP=${NJOB}_35
###------------------------------------------------------------------------------
### Merge EST_FCTRGROLESII INV  with EST_FCTRGROLESII POS without duplicate key from EST_FCTRGROLESII INV
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_FCTRGROLESII when TYPEINV=POS"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_FCTRGROLESII_5010} 1000 1"
##SORT_I2="${EST_FCTRGROLESII_5000} 1000 1"
##SORT_O="${EST_FCTRGROLESII} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##        END_NT 2:1 - 2:,
##        SEC_NF 3:1 - 3:,
##        UWY_NF 4:1 - 4:,
##        UW_NT  5:1 - 5:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT
##
##else 
##
##NSTEP=${NJOB}_35B
###-----------------------------------------------------------------------------
### Copy EST_FCTRGROLESII_5000 if EST_FCTRGROLESII_5010 didn't exist
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_FCTRGROLESII when TYPEINV = POS AND EST_FCTRGROLESII_5010 doesn't exist"
##EXECKSH "cp ${EST_FCTRGROLESII_5000} ${EST_FCTRGROLESII}"
##
##fi
##

if [[ -e "${EST_FCES_5010}" ]]
then

NSTEP=${NJOB}_75
#------------------------------------------------------------------------------
# Merge EST_FCES INV with EST_FCES POS  without duplicate key from EST_FCES INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCES when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCES_5010} 1000 1"
SORT_I2="${EST_FCES_5000} 1000 1"
SORT_O="${EST_FCES} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 		 1:1 - 1:,
        END_NT		 2:1 - 2:,
        SEC_NF		 3:1 - 3:,
        UWY_NF 		 4:1 - 4:,
		      UW_NT		 5:1 - 5:,
		      RETCTR_NF 	 6:1 - 6:,
        RETEND_NT 	 7:1 - 7:,
        RETSEC_NF 		 8:1 - 8:,
        RTY_NF 	 9:1 - 9:,
		      RETUW_NT 	 10:1 - 10:
/KEYS CTR_NF,
	     END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
	     RETCTR_NF,
	     RETEND_NT,
	     RETSEC_NF,
	     RTY_NF,
	     RETUW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_75B
#-----------------------------------------------------------------------------
# Copy EST_FCES_5000 if EST_FCES_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCES when TYPEINV = POS AND EST_FCES INV doesn't exist"
EXECKSH "cp ${EST_FCES_5000} ${EST_FCES}"

fi

##if [[ -e "${EST_FCTRGRO_5010}" ]]
##then
##
##NSTEP=${NJOB}_80
###------------------------------------------------------------------------------
### Merge EST_FCTRGRO INV with EST_FCTRGRO POS without duplicate key from EST_FCTRGRO INV
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_FCTRGRO when TYPEINV=POS"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_FCTRGRO_5010} 1000 1"
##SORT_I2="${EST_FCTRGRO_5000} 1000 1"
##SORT_O="${EST_FCTRGRO} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##        END_NT 2:1 - 2:,
##        SEC_NF 3:1 - 3:,
##        UWY_NF 21:1 - 21:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT
##
##else 
##
##NSTEP=${NJOB}_80B
###-----------------------------------------------------------------------------
### Copy EST_FCTRGRO_5000 if EST_FCTRGRO_5010 didn't exist
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_FCTRGRO when TYPEINV = POS AND EST_FCTRGRO_5010 doesn't exist"
##EXECKSH "cp ${EST_FCTRGRO_5000} ${EST_FCTRGRO}"
##
##fi
##
##if [[ -e "${EST_FCTRGRO1_5010}" ]]
##then
##
##NSTEP=${NJOB}_90
###------------------------------------------------------------------------------
### Merge EST_FCTRGRO1 INV with EST_FCTRGRO1 POS without duplicate key from EST_FCTRGRO1 INV
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_FCTRGRO1 when TYPEINV=POS"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_FCTRGRO1_5010} 1000 1"
##SORT_I2="${EST_FCTRGRO1_5000} 1000 1"
##SORT_O="${EST_FCTRGRO1} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##        END_NT 2:1 - 2:,
##        SEC_NF 3:1 - 3:,
##        UWY_NF 21:1 - 21:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT
##
##else 
##
##NSTEP=${NJOB}_90B
###-----------------------------------------------------------------------------
### Copy EST_FCTRGRO1_5000 if EST_FCTRGRO1_5010 didn't exist
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_FCTRGRO1 when TYPEINV = POS AND EST_FCTRGRO1 INV doesn't exist"
##EXECKSH "cp ${EST_FCTRGRO1_5000} ${EST_FCTRGRO1}"
##
##fi

if [[ -e "${EST_FCTRULT_5010}" ]]
then

NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
# Merge EST_FCTRULT INV with EST_FCTRULT POS without duplicate key from EST_FCTRULT INV
#-----------------------------------------------------------------------------
LIBEL="Generate FCTRULT when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRULT_5010} 1000 1"
SORT_I2="${EST_FCTRULT_5000} 1000 1"
SORT_O="${EST_FCTRULT} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT  5:1 - 5:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_100B
#-----------------------------------------------------------------------------
# Copy EST_FCTRULT_5000 if EST_FCTRULT_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate FCTRULT when TYPEINV = POS AND EST_FCTRULT INV doesn't exist"
EXECKSH "cp ${EST_FCTRULT_5000} ${EST_FCTRULT}"

fi

if [[ -e "${EST_FPLACEMT0_5010}" ]]
then

NSTEP=${NJOB}_105
#------------------------------------------------------------------------------
# Merge EST_FPLACEMT0 INV with EST_FPLACEMT0 POS without duplicate key from EST_FPLACEMT0 INV
#-----------------------------------------------------------------------------
LIBEL="Generate FPLACEMT0 when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMT0_5010} 1000 1"
SORT_I2="${EST_FPLACEMT0_5000} 1000 1"
SORT_O="${EST_FPLACEMT0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 	 3:1 - 3:,
        RETEND_NT 	 4:1 - 4:,
        RETSEC_NF 		 5:1 - 5:,
        RTY_NF 	 6:1 - 6:,
		      RETUW_NT 	 7:1 - 7:,
		      PLC_NT		 8:1 - 8:
/KEYS 
	  RETCTR_NF,
	  RETEND_NT,
	  RETSEC_NF,
	  RTY_NF,
	  RETUW_NT,
	  PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_105B
#-----------------------------------------------------------------------------
# Copy EST_FPLACEMT0_5000 if EST_FPLACEMT0_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate FPLACEMT0 when TYPEINV = POS AND EST_FPLACEMT0 INV doesn't exist"
EXECKSH "cp ${EST_FPLACEMT0_5000} ${EST_FPLACEMT0}"

fi

if [[ -e "${EST_FPLACEMT2_5010}" ]]
then

NSTEP=${NJOB}_110
#------------------------------------------------------------------------------
# Merge EST_FPLACEMT2 INV with EST_FPLACEMT2 POS without duplicate key from EST_FPLACEMT2 INV
#-----------------------------------------------------------------------------
LIBEL="Generate FPLACEMT0 when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMT2_5010} 1000 1"
SORT_I2="${EST_FPLACEMT2_5000} 1000 1"
SORT_O="${EST_FPLACEMT2} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        UWY_NF 2:1 - 2:,
        PLC_NT 3:1 - 3:
/KEYS CTR_NF,
      UWY_NF,
      PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_110B
#-----------------------------------------------------------------------------
# Copy EST_FPLACEMT2_5000 if EST_FPLACEMT2_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate FPLACEMT0 when TYPEINV = POS AND EST_FPLACEMT2 INV doesn't exist"
EXECKSH "cp ${EST_FPLACEMT2_5000} ${EST_FPLACEMT0}"

fi

if [[ -e "${EST_FPLATXCUM_5010}" ]]
then

NSTEP=${NJOB}_115
#------------------------------------------------------------------------------
# Merge EST_FPLATXCUM INV with EST_FPLATXCUM POS without duplicate key from EST_FPLATXCUM INV
#-----------------------------------------------------------------------------
LIBEL="Generate FPLATXCUM when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLATXCUM_5010} 1000 1"
SORT_I2="${EST_FPLATXCUM_5000} 1000 1"
SORT_O="${EST_FPLATXCUM} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        SEC_NF 2:1 - 2:,
        UWY_NF 3:1 - 3:,
        PLC_NT 4:1 - 4:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_115B
#-----------------------------------------------------------------------------
# Copy EST_FPLATXCUM_5000 if EST_FPLATXCUM_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate FPLATXCUM when TYPEINV = POS AND EST_FPLATXCUM_5010 doesn't exist"
EXECKSH "cp ${EST_FPLATXCUM_5000} ${EST_FPLATXCUM}"

fi

if [[ -e "${EST_FPLATXCUMALL_5010}" ]]
then

NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
# Merge EST_FPLATXCUMALL INV with EST_FPLATXCUMALL POS without duplicate key from EST_FPLATXCUMALL INV
#-----------------------------------------------------------------------------
LIBEL="Generate FPLATXCUMALL when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLATXCUMALL_5010} 1000 1"
SORT_I2="${EST_FPLATXCUMALL_5000} 1000 1"
SORT_O="${EST_FPLATXCUMALL} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        SEC_NF 2:1 - 2:,
        UWY_NF 3:1 - 3:,
        PLC_NT 4:1 - 4:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_120B
#-----------------------------------------------------------------------------
# Copy EST_FPLATXCUMALL_5000 if EST_FPLATXCUMALL_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate FPLATXCUMALL when TYPEINV = POS AND EST_FPLATXCUMALL INV doesn't exist"
EXECKSH "cp ${EST_FPLATXCUMALL_5000} ${EST_FPLATXCUMALL}"

fi

if [[ -e "${EST_FPLC_5010}" ]]
then

NSTEP=${NJOB}_125
#------------------------------------------------------------------------------
# Merge EST_FPLC INV with EST_FPLC POS without duplicate key from EST_FPLC INV
#-----------------------------------------------------------------------------
LIBEL="Generate FPLC when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLC_5010} 1000 1"
SORT_I2="${EST_FPLC_5000} 1000 1"
SORT_O="${EST_FPLC} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:,
		PLC_NT 8:1 - 8:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
	  PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_125B
#-----------------------------------------------------------------------------
# Copy EST_FPLC_5000 if EST_FPLC_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate FPLC when TYPEINV = POS AND EST_FPLC INV doesn't exist"
EXECKSH "cp ${EST_FPLC_5000} ${EST_FPLC}"

fi

if [[ -e "${EST_FULTIMATES_5010}" ]]
then

NSTEP=${NJOB}_140
#------------------------------------------------------------------------------
# Merge EST_FULTIMATES INV with EST_FULTIMATES POS without duplicate key from EST_FULTIMATES INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FULTIMATES when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FULTIMATES_5010} 1000 1"
SORT_I2="${EST_FULTIMATES_5000} 1000 1"
SORT_O="${EST_FULTIMATES} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT  5:1 - 5:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_140B
#-----------------------------------------------------------------------------
# Copy EST_FULTIMATES_5000 if EST_FULTIMATES_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FULTIMATES when TYPEINV = POS AND EST_FULTIMATES INV doesn't exist"
EXECKSH "cp ${EST_FULTIMATES_5000} ${EST_FULTIMATES}"

fi

if [[ -e "${EST_IADPERIFCI_5010}" ]]
then

##[002]
##NSTEP=${NJOB}_165
###------------------------------------------------------------------------------
### Merge EST_IADPERIFCI INV with EST_IADPERIFCI POS without duplicate key from EST_IADPERIFCI INV
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_IADPERIFCI when TYPEINV=POS"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_IADPERIFCI_5010} 1000 1"
##SORT_I2="${EST_IADPERIFCI_5000} 1000 1"
##SORT_O="${EST_IADPERIFCI} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##        END_NT 2:1 - 2:,
##        SEC_NF 3:1 - 3:,
##        UWY_NF 4:1 - 4:,
##        UW_NT  5:1 - 5:,
##								CHGLIN_NT  6:1 - 6:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT,
##						CHGLIN_NT
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT 

NSTEP=${NJOB}_164
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-POS not in pericase INV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFCI_5010} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFCI_POS_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       1:1 - 1:, 
		END_NT       2:1 - 2:, 
		SEC_NF       3:1 - 3:, 
		UWY_NF       4:1 - 4:, 
		UW_NT        5:1 - 5:, 
		STD_CTR_NF   1:1 - 1:, 
		STD_END_NT   2:1 - 2:, 
		STD_SEC_NF   3:1 - 3:, 
		STD_UWY_NF   4:1 - 4:, 
		STD_UW_NT    5:1 - 5:,
		ALL_COLS     1:1 -  15: 
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EST_IADPERIFCI_5000} 2000 1 "~"
/joinkeys
        STD_CTR_NF,
        STD_END_NT,
        STD_SEC_NF,
        STD_UWY_NF,
        STD_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT


# Merge EST_IADPERIFCI INV with EST_IADPERIFCI POS without duplicate key from EST_IADPERIFCI INV

NSTEP=${NJOB}_165
#------------------------------------------------------------------------------
LIBEL="Merge EST_IADPERIFCI INV with EST_IADPERIFCI POS without duplicate key from EST_IADPERIFCI INV "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_164_${IB}_SORT_IADPERIFCI_POS_O.dat 2000 1"
SORT_I2="${EST_IADPERIFCI_5000} 2000 1"
SORT_O="${EST_IADPERIFCI} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       1:1 - 1:, 
        		END_NT       2:1 - 2:, 
        		SEC_NF       3:1 - 3:, 
       		  UWY_NF       4:1 - 4:, 
        		UW_NT        5:1 - 5:
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

##[002]

else 

NSTEP=${NJOB}_165B
#-----------------------------------------------------------------------------
# Copy EST_IADPERIFCI_5000 if EST_IADPERIFCI_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADPERIFCI when TYPEINV = POS AND EST_IADPERIFCI INV doesn't exist"
EXECKSH "cp ${EST_IADPERIFCI_5000} ${EST_IADPERIFCI}"

fi

if [[ -e "${EST_IADPERIFCT_5010}" ]]
then

##[002]
##NSTEP=${NJOB}_170
###------------------------------------------------------------------------------
### Merge EST_IADPERIFCT INV with EST_IADPERIFCT POS without duplicate key from EST_IADPERIFCT INV
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_IADPERIFCT when TYPEINV=POS"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_IADPERIFCT_5010} 1000 1"
##SORT_I2="${EST_IADPERIFCT_5000} 1000 1"
##SORT_O="${EST_IADPERIFCT} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##        END_NT 2:1 - 2:,
##        SEC_NF 3:1 - 3:,
##        UWY_NF 4:1 - 4:,
##        UW_NT  5:1 - 5:,
##								TAXLIN_NT 9:1 - 9:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT,
##						TAXLIN_NT
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT
##

NSTEP=${NJOB}_168
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-POS not in pericase INV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFCT_5010} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFCT_POS_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       1:1 - 1:,   
		END_NT       2:1 - 2:,   
		SEC_NF       3:1 - 3:,   
		UWY_NF       4:1 - 4:,   
		UW_NT        5:1 - 5:,   
		STD_CTR_NF   1:1 - 1:,   
		STD_END_NT   2:1 - 2:,   
		STD_SEC_NF   3:1 - 3:,   
		STD_UWY_NF   4:1 - 4:,   
		STD_UW_NT    5:1 - 5:,  
		ALL_COLS     1:1 -  12: 
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EST_IADPERIFCT_5000} 2000 1 "~"
/joinkeys
        STD_CTR_NF,
        STD_END_NT,
        STD_SEC_NF,
        STD_UWY_NF,
        STD_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT


# Merge EST_IADPERIFCT INV with EST_IADPERIFCT POS without duplicate key from EST_IADPERIFCT INV

NSTEP=${NJOB}_170
#------------------------------------------------------------------------------
LIBEL="Merge EST_IADPERIFCT INV with EST_IADPERIFCT POS without duplicate key from EST_IADPERIFCT INV "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_168_${IB}_SORT_IADPERIFCT_POS_O.dat 2000 1"
SORT_I2="${EST_IADPERIFCT_5000} 2000 1"
SORT_O="${EST_IADPERIFCT} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       1:1 - 1:,   
        		END_NT       2:1 - 2:,   
        		SEC_NF       3:1 - 3:,   
       		  UWY_NF       4:1 - 4:,   
        		UW_NT        5:1 - 5:,
        		TAXLIN_NT 9:1 - 9:  
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

##[002]

else 

NSTEP=${NJOB}_170B
#-----------------------------------------------------------------------------
# Copy EST_IADPERIFCT_5000 if EST_IADPERIFCT_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADPERIFCT when TYPEINV = POS AND EST_IADPERIFCT INV doesn't exist"
EXECKSH "cp ${EST_IADPERIFCT_5000} ${EST_IADPERIFCT}"

fi

if [[ -e "${EST_IADPERIFR_5010}" ]]
then

##[002]
##NSTEP=${NJOB}_175
###------------------------------------------------------------------------------
### Merge EST_IADPERIFR INV with EST_IADPERIFR POS without duplicate key from EST_IADPERIFRINV
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_IADPERIFR when TYPEINV=POS"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_IADPERIFR_5010} 1000 1"
##SORT_I2="${EST_IADPERIFR_5000} 1000 1"
##SORT_O="${EST_IADPERIFR} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##        END_NT 2:1 - 2:,
##        SEC_NF 3:1 - 3:,
##        UWY_NF 4:1 - 4:,
##        UW_NT  5:1 - 5:,
##								REILIN_NT 6:1 - 6:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT,
##						REILIN_NT
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT 


NSTEP=${NJOB}_173
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-POS not in pericase INV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFR_5010} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFR_POS_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       1:1 - 1:,   
		END_NT       2:1 - 2:,   
		SEC_NF       3:1 - 3:,   
		UWY_NF       4:1 - 4:,   
		UW_NT        5:1 - 5:,   
		STD_CTR_NF   1:1 - 1:,   
		STD_END_NT   2:1 - 2:,   
		STD_SEC_NF   3:1 - 3:,   
		STD_UWY_NF   4:1 - 4:,   
		STD_UW_NT    5:1 - 5:,  
		ALL_COLS     1:1 -  15: 
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EST_IADPERIFR_5000} 2000 1 "~"
/joinkeys
        STD_CTR_NF,
        STD_END_NT,
        STD_SEC_NF,
        STD_UWY_NF,
        STD_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT


# Merge EST_IADPERIFR INV with EST_IADPERIFR POS without duplicate key from EST_IADPERIFR INV

NSTEP=${NJOB}_175
#------------------------------------------------------------------------------
LIBEL="Merge EST_IADPERIFR INV with EST_IADPERIFR POS without duplicate key from EST_IADPERIFR INV "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_173_${IB}_SORT_IADPERIFR_POS_O.dat 2000 1"
SORT_I2="${EST_IADPERIFR_5000} 2000 1"
SORT_O="${EST_IADPERIFR} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       1:1 - 1:,   
        		END_NT       2:1 - 2:,   
        		SEC_NF       3:1 - 3:,   
       		  UWY_NF       4:1 - 4:,   
        		UW_NT        5:1 - 5: 
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

##[002]

else 

NSTEP=${NJOB}_175B
#-----------------------------------------------------------------------------
# Copy EST_IADPERIFR_5000 if EST_IADPERIFR_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADPERIFR when TYPEINV = POS AND EST_IADPERIFR INV doesn't exist"
EXECKSH "cp ${EST_IADPERIFR_5000} ${EST_IADPERIFR}"

fi

#if [[ -e "${ESF_FLOARAT_I17_5010}" ]]
#then
#
#NSTEP=${NJOB}_180
##------------------------------------------------------------------------------
## Merge ESF_FLOARAT_I17 INV with ESF_FLOARAT_I17 POS without duplicate key from ESF_FLOARAT_I17 INV
##-----------------------------------------------------------------------------
#LIBEL="Generate ESF_FLOARAT_I17 when TYPEINV=POS"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${ESF_FLOARAT_I17_5010} 1000 1"
#SORT_I2="${ESF_FLOARAT_I17_5000} 1000 1"
#SORT_O="${ESF_FLOARAT_I17} 1000 1"
#INPUT_TEXT $SORT_CMD <<EOF
#/FIELDS CTR_NF 1:1 - 1:,
#        END_NT 2:1 - 2:,
#        SEC_NF 3:1 - 3:,
#        UWY_NF 4:1 - 4:,
#        UW_NT  5:1 - 5:
#/KEYS CTR_NF,
#      END_NT,
#      SEC_NF,
#      UWY_NF,
#      UW_NT
#/STABLE
#/SUMMARIZE
#/OUTFILE ${SORT_O}
#exit
#EOF
#SORT
#
#else 
#
#NSTEP=${NJOB}_180B
##-----------------------------------------------------------------------------
## Copy ESF_FLOARAT_I17_5000 if ESF_FLOARAT_I17_5010 didn't exist
##-----------------------------------------------------------------------------
#LIBEL="Generate ESF_FLOARAT_I17 when TYPEINV = POS AND ESF_FLOARAT_I17 INV doesn't exist"
#EXECKSH "cp ${ESF_FLOARAT_I17_5000} ${ESF_FLOARAT_I17}"
#
#fi

if [[ -e "${EST_FMARKET_5010}" ]]
then

NSTEP=${NJOB}_185
#------------------------------------------------------------------------------
# Merge EST_FMARKET INV with EST_FMARKET POS without duplicate key from EST_FMARKET INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FMARKET when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FMARKET_5010} 1000 1"
SORT_I2="${EST_FMARKET_5000} 1000 1"
SORT_O="${EST_FMARKET} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT  5:1 - 5:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_185B
#-----------------------------------------------------------------------------
# Copy EST_FMARKET_5000 if EST_FMARKET_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FMARKET when TYPEINV = POS AND EST_FMARKET INV doesn't exist"
EXECKSH "cp ${EST_FMARKET_5000} ${EST_FMARKET}"

fi


## |001]

if [[ -e "${ESF_FLORETFACTOR_INI_5010}" ]]
then

NSTEP=${NJOB}_195
#------------------------------------------------------------------------------
# Merge ESF_FLORETFACTOR_INI INV with ESF_FLORETFACTOR_INI POS without duplicate key from ESF_FLORETFACTOR_INI INV
#-----------------------------------------------------------------------------
LIBEL="Generate ESF_FLORETFACTOR_INI when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR_INI_5010} 1000 1"
SORT_I2="${ESF_FLORETFACTOR_INI_5000} 1000 1"
SORT_O="${ESF_FLORETFACTOR_INI} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        CTR_NF           1:1     - 1:,
        END_NT           2:1     - 2:,
        SEC_NF           3:1     - 3:,
        UWY_NF           4:1     - 4:,
        UW_NT            5:1     - 5:,
        RETCTR_NF        6:1     - 6:,
        RETEND_NT        7:1     - 7:,
        RETSEC_NF        8:1     - 8:,
        RETRTY_NF        9:1     - 9:,
        RETUW_NT        10:1     - 10:
/KEYS
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
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

else 

NSTEP=${NJOB}_195B
#-----------------------------------------------------------------------------
# Copy ESF_FLORETFACTOR_INI_5000 if ESF_FLORETFACTOR_INI_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate ESF_FLORETFACTOR_INI when TYPEINV = POS AND ESF_FLORETFACTOR_INI INV doesn't exist"
EXECKSH "cp ${ESF_FLORETFACTOR_INI_5000} ${ESF_FLORETFACTOR_INI}"

fi


JOBEND


##
##
##NSTEP=${NJOB}_195
###-----------------------------------------------------------------------------
##LIBEL="get ALL ESF_FLORETFACTOR_INI_5000 - INV ==> POS File LOFACTOR"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${ESF_FLORETFACTOR_INI_5000} 2000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLORETFACTOR_INI_DELTA_O.dat 2000 1"
##INPUT_TEXT ${SORT_CMD} <<EOF  	
##/FIELDS 	CTR_NF 				  		    1:1 - 1:,
##					END_NT 				          2:1 - 2:,
##					SEC_NF 				          3:1 - 3:,
##					UWY_NF 				          4:1 - 4:,
##					UW_NT 					        5:1 - 5:,
##					RETCTR_NF 			   			6:1 - 6:,
##					RETEND_NT 			        7:1 - 7:,
##					RETSEC_NF 			        8:1 - 8:,
##					RETRTY_NF 				      9:1 - 9:,
##					RETUW_NT 			          10:1 - 10:,
##					ALL_COLS     						1:1 -  35:, 
##					INV_CTR_NF 				  		1:1 - 1:,
##					INV_END_NT 				      2:1 - 2:,
##					INV_SEC_NF 				      3:1 - 3:,
##					INV_UWY_NF 				      4:1 - 4:,
##					INV_UW_NT 					    5:1 - 5:,
##					INV_RETCTR_NF 			   	6:1 - 6:,
##					INV_RETEND_NT 			    7:1 - 7:,
##					INV_RETSEC_NF 			    8:1 - 8:,
##					INV_RETRTY_NF 				  9:1 - 9:,
##					INV_RETUW_NT 			      10:1 - 10:					
##/joinkeys
##      CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT,
##      RETCTR_NF,
##      RETEND_NT,
##      RETSEC_NF,
##      RETRTY_NF,
##      RETUW_NT
##/INFILE ${ESF_FLORETFACTOR_INI_5010} 2000 1 "~"
##/joinkeys
##     INV_CTR_NF,
##     INV_END_NT,
##     INV_SEC_NF,
##     INV_UWY_NF,
##     INV_UW_NT,
##     INV_RETCTR_NF,
##     INV_RETEND_NT,
##     INV_RETSEC_NF,
##     INV_RETRTY_NF,
##     INV_RETUW_NT
##/JOIN UNPAIRED LEFTSIDE ONLY
##/OUTFILE ${SORT_O} overwrite
##/REFORMAT LEFTSIDE:ALL_COLS
##exit
##EOF
##SORT
##
##
##
##
##NSTEP=${NJOB}_16
###------------------------------------------------------------------------------
##LIBEL="MERGE AND SORT LOFACTOR INI INV And LOFACTOR DELTA_POS  "
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_150_${IB}_SORT_FLORETFACTOR_INI_DELTA_O.dat 2000 1"
##SORT_I2="${ESF_FLORETFACTOR_INI_5010} 2000 1"
##SORT_O="${ESF_FLORETFACTOR_INI} 2000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS 	CTR_NF 				  		    1:1 - 1:,
##					END_NT 				          2:1 - 2:,
##					SEC_NF 				          3:1 - 3:,
##					UWY_NF 				          4:1 - 4:,
##					UW_NT 					        5:1 - 5:,
##					RETCTR_NF 			   			6:1 - 6:,
##					RETEND_NT 			        7:1 - 7:,
##					RETSEC_NF 			        8:1 - 8:,
##					RETRTY_NF 				      9:1 - 9:,
##					RETUW_NT 			          10:1 - 10:,
##					ALL_COLS     						1:1 -  35: 
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT,
##      RETCTR_NF,
##      RETEND_NT,
##      RETSEC_NF,
##      RETRTY_NF,
##      RETUW_NT
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT
##
##*/
