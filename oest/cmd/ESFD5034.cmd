#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD5034.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 28\06\2024
# auteur                        : David DA SILVA TEIXEIRA
#---------------------------------------------------------------------------------
# description
#
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#====================================INPUT PARAMETERS====================="
ECHO_LOG "#===> NORME_CF...........................................................: ${NORME_CF}"
ECHO_LOG "#===> TYPEINV............................................................: ${TYPEINV}"
ECHO_LOG "#===> PARM_CRE_D.........................................................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM_ICLODAT_D.....................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#====================================INPUT FILE=========================="
ECHO_LOG "#===> EST_IADPERICASE_STD_EBS............................................: ${EST_IADPERICASE_STD_EBS}"
ECHO_LOG "#===> EST_FCESSION0......................................................: ${EST_FCESSION0}"
ECHO_LOG "#====================================OUTPUT FILE=========================="
ECHO_LOG "#===> EST_FCES...........................................................: ${EST_FCES}"
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_05
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting acceptance perimeter file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_STD_EBS} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_STD_EBS.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF 3:1 - 3:,
    SEC_NF 5:1 - 5:,
    UWY_NF 6:1 - 6:,
    UW_NT 7:1 - 7:
/KEYS 
    CTR_NF,
    SEC_NF,
    UWY_NF,
    UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_10
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCESSION0}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CES.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF 1:1 - 1:,
    SEC_NF 3:1 - 3:,
    UWY_NF 4:1 - 4:,
    UW_NT 5:1 - 5:
/KEYS 
    CTR_NF,
    SEC_NF,
    UWY_NF,
    UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new cession file..."
PRG=ESTC2301
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_IADPERICASE_STD_EBS.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_CES.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FCES_NEW.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETNP_SEGMENT_NOT_USE.dat
EXECPRG


NSTEP=${NJOB}_20
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting new cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_15_${IB}_ESTC2301_FCES_NEW.dat
SORT_O="${EST_FCES} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    CTR_NF 1:1 - 1:,
    END_NT 2:1 - 2: ,
    SEC_NF 3:1 - 3: ,
    UWY_NF 4:1 - 4: ,
    UW_NT 5:1 - 5: ,
    RETCTR_NF 6:1 - 6:,
    RETEND_NT 7:1 - 7: ,
    RETSEC_NF 8:1 - 8: ,
    RTY_NF 9:1 - 9: ,
    RETUW_NT 10:1 - 10:
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
    RETUW_NT
/CONDITION RETRO RETCTR_NF EQ ""
/OMIT RETRO
exit
EOF
SORT


JOBEND