#!/bin/ksh
#=============================================================================
# nom de l'application          : I17
# nom du script SHELL           : ESFD5013.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 18\05\2021
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# Description
# Copy IFRS17 INI files INV
#-----------------------------------------------------------------------------
#---------------------------------------------------------------------------------
# [001] 20/10/2022 : MZM : spira 105660 LO FACTOR Table update process I17 
# [002] 02/03/2026 MZM/Manish US 7046 CUT OFF : Move FCTRGRO FROM ESFD5014 TO ESFD5015
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
ECHO_LOG "#===> CONTEXT_CT.............................................................: ${CONTEXT_CT}"

ECHO_LOG "#===> ........................... INPUT INV..................................."
ECHO_LOG "#===> EST_IADPERICASE_5000...................................................: ${EST_IADPERICASE_5000}"
ECHO_LOG "#===> EST_IRDPERICASE_5000...................................................: ${EST_IRDPERICASE_5000}"
ECHO_LOG "#===> EST_IADPERICASE0_INI_5000..............................................: ${EST_IADPERICASE0_INI_5000}"
ECHO_LOG "#===> EST_IADPERICASE_DUMMY_5000.............................................: ${EST_IADPERICASE_DUMMY_5000}"
ECHO_LOG "#===> EST_FCES_5000..........................................................: ${EST_FCES_5000}"
##ECHO_LOG "#===> EST_FCTRGROLESII_5000..................................................: ${EST_FCTRGROLESII_5000}"
##ECHO_LOG "#===> EST_FCTRGRO_5000.......................................................: ${EST_FCTRGRO_5000}"
##ECHO_LOG "#===> EST_FCTRGRO1_5000......................................................: ${EST_FCTRGRO1_5000}"
ECHO_LOG "#===> EST_FCTRULT_5000.......................................................: ${EST_FCTRULT_5000}"
ECHO_LOG "#===> EST_FPLACEMT0_5000.....................................................: ${EST_FPLACEMT0_5000}"
ECHO_LOG "#===> EST_FPLACEMT2_5000.....................................................: ${EST_FPLACEMT2_5000}"
ECHO_LOG "#===> EST_FPLATXCUM_5000.....................................................: ${EST_FPLATXCUM_5000}"
ECHO_LOG "#===> EST_FPLATXCUMALL_5000..................................................: ${EST_FPLATXCUMALL_5000}"
ECHO_LOG "#===> EST_FPLC_5000..........................................................: ${EST_FPLC_5000}"
ECHO_LOG "#===> EST_FULTIMATES_5000....................................................: ${EST_FULTIMATES_5000}"
ECHO_LOG "#===> EST_IADPERIFCI_5000....................................................: ${EST_IADPERIFCI_5000}"
ECHO_LOG "#===> EST_IADPERIFCT_5000....................................................: ${EST_IADPERIFCT_5000}"
ECHO_LOG "#===> EST_IADPERIFR_5000.....................................................: ${EST_IADPERIFR_5000}"
#ECHO_LOG "#===> ESF_FLOARAT_I17_5000..................................................: ${ESF_FLOARAT_I17_5000}"
ECHO_LOG "#===> EST_FMARKET_5000.......................................................: ${EST_FMARKET_5000}"
ECHO_LOG "#===> ESF_FLORETFACTOR_INI_5000..............................................: ${ESF_FLORETFACTOR_INI_5000}"

ECHO_LOG "#===> ............ OUTPUT ..................................................."
ECHO_LOG "#===> EST_IADPERICASE........................................................: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_IRDPERICASE........................................................: ${EST_IRDPERICASE}"
ECHO_LOG "#===> EST_IADPERICASE0_INI...................................................: ${EST_IADPERICASE0_INI}"
ECHO_LOG "#===> EST_IADPERICASE_DUMMY..................................................: ${EST_IADPERICASE_DUMMY}"
##ECHO_LOG "#===> EST_FCTRGROLESII.......................................................: ${EST_FCTRGROLESII}"
ECHO_LOG "#===> EST_FCES...............................................................: ${EST_FCES}"
##ECHO_LOG "#===> EST_FCTRGRO............................................................: ${EST_FCTRGRO}"
##ECHO_LOG "#===> EST_FCTRGRO1...........................................................: ${EST_FCTRGRO1}"
ECHO_LOG "#===> EST_FCTRULT............................................................: ${EST_FCTRULT}"
ECHO_LOG "#===> EST_FPLACEMT0..........................................................: ${EST_FPLACEMT0}"
ECHO_LOG "#===> EST_FPLACEMT2..........................................................: ${EST_FPLACEMT2}"
ECHO_LOG "#===> EST_FPLATXCUM..........................................................: ${EST_FPLATXCUM}"
ECHO_LOG "#===> EST_FPLATXCUMALL.......................................................: ${EST_FPLATXCUMALL}"
ECHO_LOG "#===> EST_FPLC...............................................................: ${EST_FPLC}"
ECHO_LOG "#===> EST_FULTIMATES.........................................................: ${EST_FULTIMATES}"
ECHO_LOG "#===> EST_IADPERIFCI.........................................................: ${EST_IADPERIFCI}"
ECHO_LOG "#===> EST_IADPERIFCT.........................................................: ${EST_IADPERIFCT}"
ECHO_LOG "#===> EST_IADPERIFR..........................................................: ${EST_IADPERIFR}"
#ECHO_LOG "#===> ESF_FLOARAT_I17........................................................: ${ESF_FLOARAT_I17}"
ECHO_LOG "#===> EST_FMARKET............................................................: ${EST_FMARKET}"
ECHO_LOG "#===> ESF_FLORETFACTOR_INI_5010...............................................: ${ESF_FLORETFACTOR_INI_5010}"
ECHO_LOG "#============================================================================"


NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
# Copy EST_IADPERICASE_5000 into EST_IADPERICASE
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERICASE_5000 into EST_IADPERICASE"
EXECKSH "cp ${EST_IADPERICASE_5000} ${EST_IADPERICASE}"


NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
# Copy EST_IRDPERICASE_5000 into EST_IRDPERICASE
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IRDPERICASE_5000 into EST_IRDPERICASE"
EXECKSH "cp ${EST_IRDPERICASE_5000} ${EST_IRDPERICASE}"


NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
# Copy EST_IADPERICASE0_INI_5000 into EST_IADPERICASE0_INI
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERICASE0_INI_5000 into EST_IADPERICASE0_INI"
EXECKSH "cp ${EST_IADPERICASE0_INI_5000} ${EST_IADPERICASE0_INI}"


NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
# Copy EST_IADPERICASE_DUMMY_5000 into EST_IADPERICASE_DUMMY
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERICASE_DUMMY_5000 into EST_IADPERICASE_DUMMY"
EXECKSH "cp ${EST_IADPERICASE_DUMMY_5000} ${EST_IADPERICASE_DUMMY}"

##NSTEP=${NJOB}_35
###-----------------------------------------------------------------------------
### Copy EST_FCTRGROLESII_5000 into EST_FCTRGROLESII
###-----------------------------------------------------------------------------
##LIBEL="Copy  EST_FCTRGROLESII_5000 into EST_FCTRGROLESII"
##EXECKSH "cp ${EST_FCTRGROLESII_5000} ${EST_FCTRGROLESII}"

NSTEP=${NJOB}_75
#-----------------------------------------------------------------------------
# Copy EST_FCES_5000 into EST_FCES
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCES_5000 into EST_FCES"
EXECKSH "cp ${EST_FCES_5000} ${EST_FCES}"

##NSTEP=${NJOB}_80
###-----------------------------------------------------------------------------
### Copy EST_FCTRGRO_5000 into EST_FCTRGRO
###-----------------------------------------------------------------------------
##LIBEL="Copy  EST_FCTRGRO_5000 into EST_FCTRGRO"
##EXECKSH "cp ${EST_FCTRGRO_5000} ${EST_FCTRGRO}"
##
##NSTEP=${NJOB}_90
###-----------------------------------------------------------------------------
### Copy EST_FCTRGRO1_5000 into EST_FCTRGRO1
###-----------------------------------------------------------------------------
##LIBEL="Copy  EST_FCTRGRO1_5000 into EST_FCTRGRO1"
##EXECKSH "cp ${EST_FCTRGRO1_5000} ${EST_FCTRGRO1}"

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
# Copy EST_FCTRULT_5000 into EST_FCTRULT
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCTRULT_5000 into EST_FCTRULT"
EXECKSH "cp ${EST_FCTRULT_5000} ${EST_FCTRULT}"

NSTEP=${NJOB}_105
#-----------------------------------------------------------------------------
# Copy EST_FPLACEMT0_5000 into EST_FPLACEMT0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLACEMT0_5000 into EST_FPLACEMT0"
EXECKSH "cp ${EST_FPLACEMT0_5000} ${EST_FPLACEMT0}"

NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
# Copy EST_FPLACEMT2_5000 into EST_FPLACEMT2
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLACEMT2_5000 into EST_FPLACEMT2"
EXECKSH "cp ${EST_FPLACEMT2_5000} ${EST_FPLACEMT2}"

NSTEP=${NJOB}_115
#-----------------------------------------------------------------------------
# Copy EST_FPLATXCUM_5000 into EST_FPLATXCUM
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLATXCUM_5000 into EST_FPLATXCUM"
EXECKSH "cp ${EST_FPLATXCUM_5000} ${EST_FPLATXCUM}"

NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
# Copy EST_FPLATXCUMALL_5000 into EST_FPLATXCUMALL
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLATXCUMALL_5000 into EST_FPLATXCUMALL"
EXECKSH "cp ${EST_FPLATXCUMALL_5000} ${EST_FPLATXCUMALL}"

NSTEP=${NJOB}_125
#-----------------------------------------------------------------------------
# Copy EST_FPLC_5000 into EST_FPLC
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLC_5000 into EST_FPLC"
EXECKSH "cp ${EST_FPLC_5000} ${EST_FPLC}"

NSTEP=${NJOB}_140
#-----------------------------------------------------------------------------
# Copy EST_FULTIMATES_5000 into EST_FULTIMATES
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FULTIMATES_5000 into EST_FULTIMATES"
EXECKSH "cp ${EST_FULTIMATES_5000} ${EST_FULTIMATES}"

NSTEP=${NJOB}_165
#-----------------------------------------------------------------------------
# Copy EST_IADPERIFCI_5000 into EST_IADPERIFCI
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERIFCI_5000 into EST_IADPERIFCI"
EXECKSH "cp ${EST_IADPERIFCI_5000} ${EST_IADPERIFCI}"

NSTEP=${NJOB}_170
#-----------------------------------------------------------------------------
# Copy EST_IADPERIFCT_5000 into EST_IADPERIFCT
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERIFCT_5000 into EST_IADPERIFCT"
EXECKSH "cp ${EST_IADPERIFCT_5000} ${EST_IADPERIFCT}"

NSTEP=${NJOB}_175
#-----------------------------------------------------------------------------
# Copy EST_IADPERIFR_5000 into EST_IADPERIFR
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERIFR_5000 into EST_IADPERIFR"
EXECKSH "cp ${EST_IADPERIFR_5000} ${EST_IADPERIFR}"

#NSTEP=${NJOB}_180
##-----------------------------------------------------------------------------
## Copy ESF_FLOARAT_I17_5000 into ESF_FLOARAT_I17
##-----------------------------------------------------------------------------
#LIBEL="Copy  ESF_FLOARAT_I17_5000 into ESF_FLOARAT_I17"
#EXECKSH "cp ${ESF_FLOARAT_I17_5000} ${ESF_FLOARAT_I17}"

NSTEP=${NJOB}_185
#-----------------------------------------------------------------------------
# Copy ESF_FMARKET_INV into ESF_FMARKET
#-----------------------------------------------------------------------------
LIBEL="Copy  ESF_FMARKET_INV into ESF_FMARKET"
EXECKSH "cp ${EST_FMARKET_5000} ${EST_FMARKET}"

## [001]

NSTEP=${NJOB}_195
#-----------------------------------------------------------------------------
# Copy ESF_FLORETFACTOR_INI_5000_INV into ESF_FLORETFACTOR_INI_5000
#-----------------------------------------------------------------------------
LIBEL="Copy  ESF_FLORETFACTOR_INI_5000 into ESF_FLORETFACTOR_INI_5010"
EXECKSH "cp ${ESF_FLORETFACTOR_INI_5000} ${ESF_FLORETFACTOR_INI_5010}"

JOBEND
