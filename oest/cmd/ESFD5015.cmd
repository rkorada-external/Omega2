#!/bin/ksh
#=============================================================================
# nom de l'application          : 
# nom du script SHELL           : ESFD5015.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 02\03\2026
# auteur                        : MZM / Manish
# references des specifications :
#-----------------------------------------------------------------------------
# Description
# GENERATE FCTRGRO ; FCTRGRO0 ; FCTRGRO1 ; FCTRGROLESSI
#-----------------------------------------------------------------------------
#[001]
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF...............................................................: ${NORME_CF}"
ECHO_LOG "#===> TYPEINV................................................................: ${TYPEINV}"
ECHO_LOG "#===> PARM_TYPEINV2..........................................................: ${PARM_TYPEINV2}"
ECHO_LOG "#===> PARM_SEQ_MODE..........................................................: ${PARM_SEQ_MODE}"


if [ ${TYPEINV} = "POS" ]
then
        FCTRGRO0=${EST_FCTRGRO0_5010}
        FCTRGRO=${EST_FCTRGRO_5010}
        FCTRGRO1=${EST_FCTRGRO1_5010}
        FCTRGROLESII=${EST_FCTRGROLESII_5010}

else

        FCTRGRO0=${EST_FCTRGRO0_I4}
        FCTRGRO=${EST_FCTRGRO_I4}
        FCTRGRO1=${EST_FCTRGRO1_I4}
        FCTRGROLESII=${EST_FCTRGROLESII_I4}
fi

ECHO_LOG "#===> ............ INPUT ...................................................."

ECHO_LOG "#===> FCTRGRO0...............................................................: ${FCTRGRO0}"
ECHO_LOG "#===> FCTRGRO................................................................: ${FCTRGRO}"
ECHO_LOG "#===> FCTRGRO1...............................................................: ${FCTRGRO1}"
ECHO_LOG "#===> FCTRGROLESII...........................................................: ${FCTRGROLESII}"


ECHO_LOG "#===> ............ OUTPUT ..................................................."


ECHO_LOG "#===> EST_FCTRGRO0...........................................................: ${EST_FCTRGRO0}"
ECHO_LOG "#===> EST_FCTRGRO............................................................: ${EST_FCTRGRO}"
ECHO_LOG "#===> EST_FCTRGR1............................................................: ${EST_FCTRGRO1}"
ECHO_LOG "#===> EST_FCTRGROLESII.......................................................: ${EST_FCTRGROLESII}"


if [ ${NORME_CF} = "EBS" -a ${TYPEINV} = "INV" ] || [ ${NORME_CF} = "EBS" -a ${TYPEINV} = "POS" -a ${PARM_SEQ_MODE} = "1" ]
then
                # Launch step on applicative job ESFD5011 old


NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
# Copy EST_FCTRGROLESII
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCTRGROLESII"
EXECKSH "cp ${FCTRGROLESII} ${EST_FCTRGROLESII}"


NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
# Copy EST_FCTRGRO
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCTRGRO"
EXECKSH "cp ${FCTRGRO} ${EST_FCTRGRO}"


NSTEP=${NJOB}_85
#-----------------------------------------------------------------------------
# Copy EST_FCTRGRO0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCTRGRO0"
EXECKSH "cp ${FCTRGRO0} ${EST_FCTRGRO0}"

NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
# Copy EST_FCTRGRO1
#-----------------------------------------------------------------------------
LIBEL="Copy  FCTRGRO1"
EXECKSH "cp ${FCTRGRO1} ${EST_FCTRGRO1}"


fi

if [ ${NORME_CF} = "EBS" -a ${TYPEINV} = "POS" -a ${PARM_SEQ_MODE} = "0" ]
then


ECHO_LOG "#===> ............ INPUT ..................................................."

ECHO_LOG "#===> EST_FCTRGRO0_5010......................................................: ${EST_FCTRGRO0_5010}"
ECHO_LOG "#===> EST_FCTRGRO0_I4........................................................: ${EST_FCTRGRO0_I4}"
ECHO_LOG "#===> EST_FCTRGRO_5010.......................................................: ${EST_FCTRGRO_5010}"
ECHO_LOG "#===> EST_FCTRGRO_I4.........................................................: ${EST_FCTRGRO_I4}"
ECHO_LOG "#===> EST_FCTRGRO1_5010......................................................: ${EST_FCTRGRO1_5010}"
ECHO_LOG "#===> EST_FCTRGRO1_I4........................................................: ${EST_FCTRGRO1_I4}"
ECHO_LOG "#===> EST_FCTRGROLESII_5010..................................................: ${EST_FCTRGROLESII_5010}"
ECHO_LOG "#===> EST_FCTRGROLESII_I4....................................................: ${EST_FCTRGROLESII_I4}"


ECHO_LOG "#===> ............ OUTPUT ..................................................."

ECHO_LOG "#===> EST_FCTRGRO0...........................................................: ${EST_FCTRGRO0}"
ECHO_LOG "#===> EST_FCTRGRO............................................................: ${EST_FCTRGRO}"
ECHO_LOG "#===> EST_FCTRGRO1...........................................................: ${EST_FCTRGRO1}"
ECHO_LOG "#===> EST_FCTRGROLESII.......................................................: ${EST_FCTRGROLESII}"


                # Launch step of  applicative job ESFD5012 old


NSTEP=${NJOB}_135
#------------------------------------------------------------------------------
# Merge EST_FCTRGROLESII_5010 with EST_FCTRGROLESII_I4 without duplicate key from EST_FCTRGROLESII_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCTRGROLESII when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGROLESII_5010} 1000 1"
SORT_I2="${EST_FCTRGROLESII_I4} 1000 1"
SORT_O="${EST_FCTRGROLESII} 1000 1"
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
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_180
#------------------------------------------------------------------------------
# Merge EST_FCTRGRO_5010 with EST_FCTRGRO_I4 without duplicate key from EST_FCTRGRO_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCTRGRO when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGRO_5010} 1000 1"
SORT_I2="${EST_FCTRGRO_I4} 1000 1"
SORT_O="${EST_FCTRGRO} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
                                                                END_NT 2:1 - 2:,
                                                                SEC_NF 3:1 - 3:,
        UWY_NF 21:1 - 21:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_185
#------------------------------------------------------------------------------
# Merge EST_FCTRGRO0_5010 with EST_FCTRGRO0_I4 without duplicate key from EST_FCTRGRO0_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCTRGRO0 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGRO0_5010} 1000 1"
SORT_I2="${EST_FCTRGRO0_I4} 1000 1"
SORT_O="${EST_FCTRGRO0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
                                                                END_NT 2:1 - 2:,
                                                                SEC_NF 3:1 - 3:,
        UWY_NF 21:1 - 21:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_190
#------------------------------------------------------------------------------
# Merge EST_FCTRGRO1_5010 with EST_FCTRGRO1_I4 without duplicate key from EST_FCTRGRO1_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCTRGRO1 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGRO1_5010} 1000 1"
SORT_I2="${EST_FCTRGRO1_I4} 1000 1"
SORT_O="${EST_FCTRGRO1} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
                                                                END_NT 2:1 - 2:,
                                                                SEC_NF 3:1 - 3:,
        UWY_NF 21:1 - 21:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT



fi


if [ ${NORME_CF:0:3} = "I17" -a ${TYPEINV} = "INV" ]
then
                # Launch applicative job ESFD5013

ECHO_LOG "#===> ............ INPUT ..................................................."

ECHO_LOG "#===> EST_FCTRGROLESII_5000..................................................: ${EST_FCTRGROLESII_5000}"
ECHO_LOG "#===> EST_FCES_5000..........................................................: ${EST_FCES_5000}"
ECHO_LOG "#===> EST_FCTRGRO_5000.......................................................: ${EST_FCTRGRO_5000}"
ECHO_LOG "#===> EST_FCTRGRO1_5000......................................................: ${EST_FCTRGRO1_5000}"

ECHO_LOG "#===> ............ OUTPUT ..................................................."

ECHO_LOG "#===> EST_FCTRGROLESII.......................................................: ${EST_FCTRGROLESII}"
ECHO_LOG "#===> EST_FCES...............................................................: ${EST_FCES}"
ECHO_LOG "#===> EST_FCTRGRO............................................................: ${EST_FCTRGRO}"
ECHO_LOG "#===> EST_FCTRGRO1...........................................................: ${EST_FCTRGRO1}"



NSTEP=${NJOB}_235
#-----------------------------------------------------------------------------
# Copy EST_FCTRGROLESII_5000 into EST_FCTRGROLESII
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCTRGROLESII_5000 into EST_FCTRGROLESII"
EXECKSH "cp ${EST_FCTRGROLESII_5000} ${EST_FCTRGROLESII}"


NSTEP=${NJOB}_280
#-----------------------------------------------------------------------------
# Copy EST_FCTRGRO_5000 into EST_FCTRGRO
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCTRGRO_5000 into EST_FCTRGRO"
EXECKSH "cp ${EST_FCTRGRO_5000} ${EST_FCTRGRO}"

NSTEP=${NJOB}_290
#-----------------------------------------------------------------------------
# Copy EST_FCTRGRO1_5000 into EST_FCTRGRO1
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCTRGRO1_5000 into EST_FCTRGRO1"
EXECKSH "cp ${EST_FCTRGRO1_5000} ${EST_FCTRGRO1}"


fi

if [ ${NORME_CF:0:3} = "I17" -a ${TYPEINV} = "POS" ]
then
                # Launch applicative job ESFD5014


ECHO_LOG "#===> ............................ INPUT INV .................................."


ECHO_LOG "#===> EST_FCTRGROLESII_5010...................................................: ${EST_FCTRGROLESII_5010}"
ECHO_LOG "#===> EST_FCTRGRO_5010........................................................: ${EST_FCTRGRO_5010}"
ECHO_LOG "#===> EST_FCTRGRO1_5010.......................................................: ${EST_FCTRGRO1_5010}"

ECHO_LOG "#===> ............................ INPUT POS .................................."
ECHO_LOG "#===> EST_FCTRGROLESII_5000...................................................: ${EST_FCTRGROLESII_5000}"
ECHO_LOG "#===> EST_FCTRGRO_5000........................................................: ${EST_FCTRGRO_5000}"
ECHO_LOG "#===> EST_FCTRGRO1_5000.......................................................: ${EST_FCTRGRO1_5000}"


ECHO_LOG "#===> .............................. OUTPUT ..................................."
ECHO_LOG "#===> EST_FCTRGROLESII........................................................: ${EST_FCTRGROLESII}"
ECHO_LOG "#===> EST_FCTRGRO.............................................................: ${EST_FCTRGRO}"
ECHO_LOG "#===> EST_FCTRGRO1............................................................: ${EST_FCTRGRO1}"



if [[ -e "${EST_FCTRGROLESII_5010}" ]]
then

NSTEP=${NJOB}_335
#------------------------------------------------------------------------------
# Merge EST_FCTRGROLESII INV  with EST_FCTRGROLESII POS without duplicate key from EST_FCTRGROLESII INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCTRGROLESII when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGROLESII_5010} 1000 1"
SORT_I2="${EST_FCTRGROLESII_5000} 1000 1"
SORT_O="${EST_FCTRGROLESII} 1000 1"
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

NSTEP=${NJOB}_335B
#-----------------------------------------------------------------------------
# Copy EST_FCTRGROLESII_5000 if EST_FCTRGROLESII_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCTRGROLESII when TYPEINV = POS AND EST_FCTRGROLESII_5010 doesn't exist"
EXECKSH "cp ${EST_FCTRGROLESII_5000} ${EST_FCTRGROLESII}"

fi




if [[ -e "${EST_FCTRGRO_5010}" ]]
then

NSTEP=${NJOB}_380
#------------------------------------------------------------------------------
# Merge EST_FCTRGRO INV with EST_FCTRGRO POS without duplicate key from EST_FCTRGRO INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCTRGRO when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGRO_5010} 1000 1"
SORT_I2="${EST_FCTRGRO_5000} 1000 1"
SORT_O="${EST_FCTRGRO} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 21:1 - 21:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT


else

NSTEP=${NJOB}_380B
#-----------------------------------------------------------------------------
# Copy EST_FCTRGRO_5000 if EST_FCTRGRO_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCTRGRO when TYPEINV = POS AND EST_FCTRGRO_5010 doesn't exist"
EXECKSH "cp ${EST_FCTRGRO_5000} ${EST_FCTRGRO}"

fi

if [[ -e "${EST_FCTRGRO1_5010}" ]]
then

NSTEP=${NJOB}_390
#------------------------------------------------------------------------------
# Merge EST_FCTRGRO1 INV with EST_FCTRGRO1 POS without duplicate key from EST_FCTRGRO1 INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCTRGRO1 when TYPEINV=POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRGRO1_5010} 1000 1"
SORT_I2="${EST_FCTRGRO1_5000} 1000 1"
SORT_O="${EST_FCTRGRO1} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 21:1 - 21:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT


else

NSTEP=${NJOB}_390B
#-----------------------------------------------------------------------------
# Copy EST_FCTRGRO1_5000 if EST_FCTRGRO1_5010 didn't exist
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCTRGRO1 when TYPEINV = POS AND EST_FCTRGRO1 INV doesn't exist"
EXECKSH "cp ${EST_FCTRGRO1_5000} ${EST_FCTRGRO1}"

fi

fi

JOBEND
