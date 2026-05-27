#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5011.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 02\03\2021
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# Description
# Copy IFRS4 files INV
#-----------------------------------------------------------------------------
#[001] 08/11/2022 DAD  :spira:107518 Generate IADPERICASE DUMMY STD
#[002] 12/06/2023 DAD  :spira:109759 Generate FCESSION1 use for ratio
#[003] 02/03/2026 MZM/Manish US 7046 CUT OFF : Move FCTRGRO FROM ESFD5011 TO ESFD5015
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
 IADPERICASE=${EST_IADPERICASE_5010}
 IRDPERICASE0=${EST_IRDPERICASE0_5010}
 IRDVPERICASE=${EST_IRDVPERICASE_5010}
 OIRDVPERICASE=${EST_OIRDVPERICASE_5010}
 IADVPERICASE=${EST_IADVPERICASE_5010}
	CADVPERIESB0=${EST_CADVPERIESB0_5010}
	CRVPERICASE0=${EST_CRVPERICASE0_5010}
	CTRULT02=${EST_CTRULT02_5010}
	FCES=${EST_FCES_5010}
	##FCTRGRO0=${EST_FCTRGRO0_5010}
	##FCTRGRO=${EST_FCTRGRO_5010}
	##FCTRGRO1=${EST_FCTRGRO1_5010}
	##FCTRGROLESII=${EST_FCTRGROLESII_5010}
	FCTRULT=${EST_FCTRULT_5010}
	FPLACEMT0=${EST_FPLACEMT0_5010}
	FPLACEMT1=${EST_FPLACEMT1_5010}
	FPLACEMT2=${EST_FPLACEMT2_5010}
	FPLATXCUM0=${EST_FPLATXCUM0_5010}
	FPLATXCUM=${EST_FPLATXCUM_5010}
	FPLATXCUMALL0=${EST_FPLATXCUMALL0_5010}
	FPLC=${EST_FPLC_5010}
	FPLCCOM=${EST_FPLCCOM_5010}
	FSSDACTR_TXT=${EST_FSSDACTR_TXT_5010}
	FTVENTNP=${EST_FTVENTNP_5010}
	IADPERIFCI=${EST_IADPERIFCI_5010}
	IADPERIFCT=${EST_IADPERIFCT_5010}
	IADPERIFR=${EST_IADPERIFR_5010}
	IADPERICASE_ENTIER0=${EST_IADPERICASE_ENTIER0_5010}
	IADPERICASE0=${EST_IADPERICASE0_5010}
	IARVPERICASE0=${EST_IARVPERICASE0_5010}
	FCESSION0=${EST_FCESSION0_5010}
	FCESSION1=${EST_FCESSION1_5010}
	IADPERICASE_DUMMY=${EST_IADPERICASE_DUMMY_5010}
else 
 IADPERICASE=${EST_IADPERICASE_I4}
 IRDPERICASE0=${EST_IRDPERICASE0_I4}
 IRDVPERICASE=${EST_IRDVPERICASE_I4}
 OIRDVPERICASE=${EST_OIRDVPERICASE_I4}
 IADVPERICASE=${EST_IADVPERICASE_I4}
	CADVPERIESB0=${EST_CADVPERIESB0_I4}
	CRVPERICASE0=${EST_CRVPERICASE0_I4}
	CTRULT02=${EST_CTRULT02_I4}
	FCES=${EST_FCES_I4}
	##FCTRGRO0=${EST_FCTRGRO0_I4}
	##FCTRGRO=${EST_FCTRGRO_I4}
	##FCTRGRO1=${EST_FCTRGRO1_I4}
	##FCTRGROLESII=${EST_FCTRGROLESII_I4}
	FCTRULT=${EST_FCTRULT_I4}
	FPLACEMT0=${EST_FPLACEMT0_I4}
	FPLACEMT1=${EST_FPLACEMT1_I4}
	FPLACEMT2=${EST_FPLACEMT2_I4}
	FPLATXCUM0=${EST_FPLATXCUM0_I4}
	FPLATXCUM=${EST_FPLATXCUM_I4}
	FPLATXCUMALL0=${EST_FPLATXCUMALL0_I4}
	FPLC=${EST_FPLC_I4}
	FPLCCOM=${EST_FPLCCOM_I4}
	FSSDACTR_TXT=${EST_FSSDACTR_TXT_I4}
	FTVENTNP=${EST_FTVENTNP_I4}
	IADPERIFCI=${EST_IADPERIFCI_I4}
	IADPERIFCT=${EST_IADPERIFCT_I4}
	IADPERIFR=${EST_IADPERIFR_I4}
	IADPERICASE_ENTIER0=${EST_IADPERICASE_ENTIER0_I4}
	IADPERICASE0=${EST_IADPERICASE0_I4}
	IARVPERICASE0=${EST_IARVPERICASE0_I4}
	FCESSION0=${EST_FCESSION0_I4}
	FCESSION1=${EST_FCESSION1_I4}
	IADPERICASE_DUMMY=${EST_IADPERICASE_DUMMY_I4}
fi

ECHO_LOG "#===> ............ INPUT ...................................................."
ECHO_LOG "#===> IADPERICASE............................................................: ${IADPERICASE}"
ECHO_LOG "#===> IRDPERICASE0...........................................................: ${IRDPERICASE0}"
ECHO_LOG "#===> IRDVPERICASE...........................................................: ${IRDVPERICASE}"
ECHO_LOG "#===> OIRDVPERICASE..........................................................: ${OIRDVPERICASE}"
ECHO_LOG "#===> IADVPERICASE...........................................................: ${IADVPERICASE}"
ECHO_LOG "#===> CADVPERIESB0...........................................................: ${CADVPERIESB0}"
ECHO_LOG "#===> CRVPERICASE0...........................................................: ${CRVPERICASE0}"
ECHO_LOG "#===> CTRULT02...............................................................: ${CTRULT02}"
ECHO_LOG "#===> FCES...................................................................: ${FCES}"
##ECHO_LOG "#===> FCTRGRO0...............................................................: ${FCTRGRO0}"
##ECHO_LOG "#===> FCTRGRO................................................................: ${FCTRGRO}"
##ECHO_LOG "#===> FCTRGRO1...............................................................: ${FCTRGRO1}"
##ECHO_LOG "#===> FCTRGROLESII...........................................................: ${FCTRGROLESII}"
ECHO_LOG "#===> FCTRULT................................................................: ${FCTRULT}"
ECHO_LOG "#===> FPLACEMT0..............................................................: ${FPLACEMT0}"
ECHO_LOG "#===> FPLACEMT1..............................................................: ${FPLACEMT1}"
ECHO_LOG "#===> FPLACEMT2..............................................................: ${FPLACEMT2}"
ECHO_LOG "#===> FPLATXCUM0.............................................................: ${FPLATXCUM0}"
ECHO_LOG "#===> FPLATXCUM..............................................................: ${FPLATXCUM}"
ECHO_LOG "#===> FPLATXCUMALL0..........................................................: ${FPLATXCUMALL0}"
ECHO_LOG "#===> FPLC...................................................................: ${FPLC}"
ECHO_LOG "#===> FPLCCOM................................................................: ${FPLCCOM}"
ECHO_LOG "#===> FSSDACTR_TXT...........................................................: ${FSSDACTR_TXT}"
ECHO_LOG "#===> FTVENTNP...............................................................: ${FTVENTNP}"
ECHO_LOG "#===> IADPERIFCI.............................................................: ${IADPERIFCI}"
ECHO_LOG "#===> IADPERIFCT.............................................................: ${IADPERIFCT}"
ECHO_LOG "#===> IADPERIFR..............................................................: ${IADPERIFR}"
ECHO_LOG "#===> IADPERICASE_ENTIER0....................................................: ${IADPERICASE_ENTIER0}"
ECHO_LOG "#===> IADPERICASE0...........................................................: ${IADPERICASE0}"
ECHO_LOG "#===> IARVPERICASE0..........................................................: ${IARVPERICASE0}"
ECHO_LOG "#===> FCESSION0..............................................................: ${FCESSION0}"
ECHO_LOG "#===> FCESSION1..............................................................: ${FCESSION1}"
ECHO_LOG "#===> IADPERICASE_DUMMY......................................................: ${IADPERICASE_DUMMY}"


ECHO_LOG "#===> ............ OUTPUT ..................................................."
ECHO_LOG "#===> EST_IADPERICASE........................................................: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_IADPERICASE_DELTA_POS..............................................: ${EST_IADPERICASE_DELTA_POS}"
ECHO_LOG "#===> EST_IRDPERICASE0.......................................................: ${EST_IRDPERICASE0}"
ECHO_LOG "#===> EST_IRDVPERICASE.......................................................: ${EST_IRDVPERICASE}"
ECHO_LOG "#===> EST_OIRDVPERICASE......................................................: ${EST_OIRDVPERICASE}"
ECHO_LOG "#===> EST_CADVPERIESB0.......................................................: ${EST_CADVPERIESB0}"
ECHO_LOG "#===> EST_CRVPERICASE0.......................................................: ${EST_CRVPERICASE0}"
ECHO_LOG "#===> EST_CTRULT02...........................................................: ${EST_CTRULT02}"
ECHO_LOG "#===> EST_FCES...............................................................: ${EST_FCES}"
##ECHO_LOG "#===> EST_FCTRGRO0...........................................................: ${EST_FCTRGRO0}"
##ECHO_LOG "#===> EST_FCTRGRO............................................................: ${EST_FCTRGRO}"
##ECHO_LOG "#===> EST_FCTRGR1............................................................: ${EST_FCTRGRO1}"
##ECHO_LOG "#===> EST_FCTRGROLESII.......................................................: ${EST_FCTRGROLESII}"
ECHO_LOG "#===> EST_FCTRULT............................................................: ${EST_FCTRULT}"
ECHO_LOG "#===> EST_FPLACEMT0..........................................................: ${EST_FPLACEMT0}"
ECHO_LOG "#===> EST_FPLACEMT1..........................................................: ${EST_FPLACEMT1}"
ECHO_LOG "#===> EST_FPLACEMT2..........................................................: ${EST_FPLACEMT2}"
ECHO_LOG "#===> EST_FPLATXCUM0.........................................................: ${EST_FPLATXCUM0}"
ECHO_LOG "#===> EST_FPLATXCUM..........................................................: ${EST_FPLATXCUM}"
ECHO_LOG "#===> EST_FPLATXCUMALL0......................................................: ${EST_FPLATXCUMALL0}"
ECHO_LOG "#===> EST_FPLC...............................................................: ${EST_FPLC}"
ECHO_LOG "#===> EST_FPLCCOM............................................................: ${EST_FPLCCOM}"
ECHO_LOG "#===> EST_FSSDACTR_TXT.......................................................: ${EST_FSSDACTR_TXT}"
ECHO_LOG "#===> EST_FTVENTNP...........................................................: ${EST_FTVENTNP}"
ECHO_LOG "#===> EST_FVENTNPANT.........................................................: ${EST_FVENTNPANT}"
ECHO_LOG "#===> EST_IADPERIFCI.........................................................: ${EST_IADPERIFCI}"
ECHO_LOG "#===> EST_IADPERIFCT.........................................................: ${EST_IADPERIFCT}"
ECHO_LOG "#===> EST_IADPERIFR..........................................................: ${EST_IADPERIFR}"
ECHO_LOG "#===> EST_IADPERICASE_ENTIER0................................................: ${EST_IADPERICASE_ENTIER0}"
ECHO_LOG "#===> EST_IADPERICASE0.......................................................: ${EST_IADPERICASE0}"
ECHO_LOG "#===> EST_IARVPERICASE0......................................................: ${EST_IARVPERICASE0}"
ECHO_LOG "#===> EST_FCESSION0..........................................................: ${EST_FCESSION0}"
ECHO_LOG "#===> EST_FCESSION1..........................................................: ${EST_FCESSION1}"
ECHO_LOG "#===> EST_IADPERICASE_DUMMY..................................................: ${EST_IADPERICASE_DUMMY}"
ECHO_LOG "#============================================================================"


NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
# Copy EST_IADPERICASE
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERICASE"
EXECKSH "cp ${IADPERICASE} ${EST_IADPERICASE}"


NSTEP=${NJOB}_07
#-----------------------------------------------------------------------------
# Generate Empty output EST_IADPERICASE_DELTA_POS
#-----------------------------------------------------------------------------
LIBEL="Generate Empty output EST_IADPERICASE_DELTA_POS"
EXECKSH_MODE=P
EXECKSH " > ${EST_IADPERICASE_DELTA_POS} "

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
# Copy EST_IRDPERICASE0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IRDPERICASE0"
EXECKSH "cp ${IRDPERICASE0} ${EST_IRDPERICASE0}"


NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
# Copy EST_IRDVPERICASE
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IRDVPERICASE"
EXECKSH "cp ${IRDVPERICASE} ${EST_IRDVPERICASE}"


NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
# Copy EST_OIRDVPERICASE
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_OIRDVPERICASE"
EXECKSH "cp ${OIRDVPERICASE} ${EST_OIRDVPERICASE}"

NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
# Copy EST_IADVPERICASE
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADVPERICASE"
EXECKSH "cp ${IADVPERICASE} ${EST_IADVPERICASE}"


##NSTEP=${NJOB}_35
###-----------------------------------------------------------------------------
### Copy EST_FCTRGROLESII
###-----------------------------------------------------------------------------
##LIBEL="Copy  EST_FCTRGROLESII"
##EXECKSH "cp ${FCTRGROLESII} ${EST_FCTRGROLESII}"


NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
# Copy EST_CADVPERIESB0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_CADVPERIESB0"
EXECKSH "cp ${CADVPERIESB0} ${EST_CADVPERIESB0}"

NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
# Copy EST_CRVPERICASE0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_CRVPERICASE0"
EXECKSH "cp ${CRVPERICASE0} ${EST_CRVPERICASE0}"


NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
# Copy EST_CTRULT02
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_CTRULT02"
EXECKSH "cp ${CTRULT02} ${EST_CTRULT02}"

NSTEP=${NJOB}_75
#-----------------------------------------------------------------------------
# Copy EST_FCES
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCES"
EXECKSH "cp ${FCES} ${EST_FCES}"


##NSTEP=${NJOB}_80
###-----------------------------------------------------------------------------
### Copy EST_FCTRGRO
###-----------------------------------------------------------------------------
##LIBEL="Copy  EST_FCTRGRO"
##EXECKSH "cp ${FCTRGRO} ${EST_FCTRGRO}"


##NSTEP=${NJOB}_85
###-----------------------------------------------------------------------------
### Copy EST_FCTRGRO0
###-----------------------------------------------------------------------------
##LIBEL="Copy  EST_FCTRGRO0"
##EXECKSH "cp ${FCTRGRO0} ${EST_FCTRGRO0}"

##NSTEP=${NJOB}_90
###-----------------------------------------------------------------------------
### Copy EST_FCTRGRO1
###-----------------------------------------------------------------------------
##LIBEL="Copy  FCTRGRO1"
##EXECKSH "cp ${FCTRGRO1} ${EST_FCTRGRO1}"


NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
# Copy EST_FCTRULT
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCTRULT"
EXECKSH "cp ${FCTRULT} ${EST_FCTRULT}"

NSTEP=${NJOB}_105
#-----------------------------------------------------------------------------
# Copy EST_FPLACEMT0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLACEMT0"
EXECKSH "cp ${FPLACEMT0} ${EST_FPLACEMT0}"

NSTEP=${NJOB}_107
#-----------------------------------------------------------------------------
# Copy EST_FPLACEMT1
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLACEMT1"
EXECKSH "cp ${FPLACEMT1} ${EST_FPLACEMT1}"

NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
# Copy EST_FPLACEMT2
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLACEMT2"
EXECKSH "cp ${FPLACEMT2} ${EST_FPLACEMT2}"

NSTEP=${NJOB}_115
#-----------------------------------------------------------------------------
# Copy EST_FPLATXCUM
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLATXCUM"
EXECKSH "cp ${FPLATXCUM} ${EST_FPLATXCUM}"

NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
# Copy EST_FPLATXCUMALL0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLATXCUMALL0"
EXECKSH "cp ${FPLATXCUMALL0} ${EST_FPLATXCUMALL0}"

NSTEP=${NJOB}_125
#-----------------------------------------------------------------------------
# Copy EST_FPLC
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLC"
EXECKSH "cp ${FPLC} ${EST_FPLC}"

NSTEP=${NJOB}_130
#-----------------------------------------------------------------------------
# Copy EST_FPLCCOM
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLCCOM"
EXECKSH "cp ${FPLCCOM} ${EST_FPLCCOM}"

NSTEP=${NJOB}_135
#-----------------------------------------------------------------------------
# Copy EST_FSSDACTR_TXT
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FSSDACTR_TXT"
EXECKSH "cp ${FSSDACTR_TXT} ${EST_FSSDACTR_TXT}"

NSTEP=${NJOB}_145
#-----------------------------------------------------------------------------
# Copy EST_FTVENTNP
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FTVENTNP"
EXECKSH "cp ${FTVENTNP} ${EST_FTVENTNP}"

NSTEP=${NJOB}_150
#-----------------------------------------------------------------------------
# Copy EST_FVENTNPANT
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FVENTNPANT"
EXECKSH "cp ${FTVENTNP} ${EST_FVENTNPANT}"

NSTEP=${NJOB}_165
#-----------------------------------------------------------------------------
# Copy EST_IADPERIFCI
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERIFCI"
EXECKSH "cp ${IADPERIFCI} ${EST_IADPERIFCI}"

NSTEP=${NJOB}_170
#-----------------------------------------------------------------------------
# Copy EST_IADPERIFCT
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERIFCT"
EXECKSH "cp ${IADPERIFCT} ${EST_IADPERIFCT}"

NSTEP=${NJOB}_175
#-----------------------------------------------------------------------------
# Copy EST_IADPERIFR
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERIFR"
EXECKSH "cp ${IADPERIFR} ${EST_IADPERIFR}"

NSTEP=${NJOB}_180
#-----------------------------------------------------------------------------
# Copy EST_FPLATXCUM0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FPLATXCUM0"
EXECKSH "cp ${FPLATXCUM0} ${EST_FPLATXCUM0}"

NSTEP=${NJOB}_185
#-----------------------------------------------------------------------------
# Copy EST_IADPERICASE_ENTIER0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERICASE_ENTIER0"
EXECKSH "cp ${IADPERICASE_ENTIER0} ${EST_IADPERICASE_ENTIER0}"

NSTEP=${NJOB}_190
#-----------------------------------------------------------------------------
# Copy EST_IADPERICASE0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERICASE0"
EXECKSH "cp ${IADPERICASE0} ${EST_IADPERICASE0}"

NSTEP=${NJOB}_195
#-----------------------------------------------------------------------------
# Copy EST_IARVPERICASE0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IARVPERICASE0"
EXECKSH "cp ${IARVPERICASE0} ${EST_IARVPERICASE0}"

NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
# Copy EST_FCESSION0
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCESSION0"
EXECKSH "cp ${FCESSION0} ${EST_FCESSION0}"

#[001]
NSTEP=${NJOB}_205
#-----------------------------------------------------------------------------
# Copy EST_IADPERICASE_DUMMY
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_IADPERICASE_DUMMY"
EXECKSH "cp ${IADPERICASE_DUMMY} ${EST_IADPERICASE_DUMMY}"

NSTEP=${NJOB}_210
#-----------------------------------------------------------------------------
# Copy EST_FCESSION1
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FCESSION1"
EXECKSH "cp ${FCESSION1} ${EST_FCESSION1}"

JOBEND
