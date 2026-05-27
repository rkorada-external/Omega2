#!/bin/ksh
#=============================================================================
# nom de l'application          : Adding product_id into TTECLEDA
# nom du script SHELL           : ESFD3817.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 07/09/2020
# auteur                        : JYP/Linh
# references des specifications : Granularity
#-----------------------------------------------------------------------------
# description
#  - Injection of product code into TECLEDA/R format		
#

#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 07/09/2020 : SPIRA 83104 : JYP : creation
#[002] 10/09/2020 : SPIRA 83104 : JYP : change logs
#[003] 06/05/2021 : SPIRA 96045 : NLD : EBS GAAPCODE Missing
#[004] 07/12/2021 : SPIRA 100744: JYP : new rules to detect assumed/retro
#[005] 31/03/2022 : SPIRA 102394: JYP : complete logs
#[006] 24/10/2022 : SPIRA 100748: JYP : use flag A/R/F in file contract links
#===============================================================================

# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

EST_BASE=`basename "${1%.*}"`
ESF_FCTRI17PRD_NEW="$2"
EST_OUT="$1"

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> CONTEXT_CT.................: ${CONTEXT_CT}  "

ECHO_LOG "#===> PARM_ICLODAT_D.............: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PARM_CRE_D.................: ${PARM_CRE_D}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"


ECHO_LOG "#===> ............INPUT ................................................."
ECHO_LOG "#===> ESF_FCTRI17PRD_NEW  .................: ${ESF_FCTRI17PRD_NEW}"
ECHO_LOG "#===> EST_OUT  ............................: ${EST_OUT}"
ECHO_LOG "#===> ............OUTPUT ................................................."
ECHO_LOG "#===> EST_OUT .............................: ${EST_OUT}"

NSTEP=${NJOB}_05
#------------------------------------------------------------------------------------
LIBEL="split ESF_FCTRI17PRD_NEW , retro and assumed "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCTRI17PRD_NEW} 2000 1"
SORT_O="${DFILT}/${NJOB}_05_${IB}_${EST_BASE}_RETRO_LINKS.dat 2000 1"
SORT_O2="${DFILT}/${NJOB}_05_${IB}_${EST_BASE}_ASSUMED_LINKS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS PRD_CTR_NF           1:1 - 1:,
        PRD_END_NT           2:1 - 2:,
        PRD_SEC_NF           3:1 - 3:,
        PRD_UWY_NF           4:1 - 4:,
        PRD_UW_NT            5:1 - 5:,
		PRD_TYP              6:1 - 6:
/KEYS   PRD_CTR_NF  ,
        PRD_END_NT  ,
        PRD_SEC_NF  ,
        PRD_UWY_NF  ,
        PRD_UW_NT   
/CONDITION TYP_RETRO (PRD_TYP = "R")
/OUTFILE ${SORT_O}
/INCLUDE TYP_RETRO
/OUTFILE ${SORT_O2}
/OMIT TYP_RETRO

exit
EOF
SORT

 
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="ASSUMED : split empty prod_code ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_OUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ASSUMED_EMPTY.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_OTHERS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           8:1 - 8:,
        END_NT           9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
		TRNCOD_CF1		6:1 - 6:1,
		RETCTR_NF       24:1 - 24:,		
		I17PRDCOD_CT    65:1 - 65:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION POST_CUR_ASSUMED ( I17PRDCOD_CT = "" AND (TRNCOD_CF1 = "1" OR TRNCOD_CF1 = "3") ) 
/OUTFILE ${SORT_O}
/INCLUDE POST_CUR_ASSUMED
/OUTFILE ${SORT_O2}
/OMIT POST_CUR_ASSUMED

exit
EOF
SORT



#${EST_OUT}
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="ASSUMED join ESF_FCTRI17PRD_NEW to ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_ASSUMED_EMPTY.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ASSUMED_PRDCOD.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF              8:1 - 8:,
        END_NT              9:1 - 9:,
        SEC_NF              10:1 - 10:,
        UWY_NF              11:1 - 11:,
        UW_NT               12:1 - 12:,
		TRNCOD_CF1			6:1 - 6:1,
		RETCTR_NF           24:1 - 24:,
        S_HEAD              1:1 - 64:,
        S_TAIL              66:1 - 71:,
        PRD_CTR_NF           1:1 - 1:,
        PRD_END_NT           2:1 - 2:,
        PRD_SEC_NF           3:1 - 3:,
        PRD_UWY_NF           4:1 - 4:,
        PRD_UW_NT            5:1 - 5:,		
        I17PRDCOD_CT         8:1 - 8:
/JOINKEYS
        CTR_NF  ,
        END_NT  ,
        SEC_NF  ,
        UWY_NF  ,
        UW_NT  
/INFILE ${DFILT}/${NJOB}_05_${IB}_${EST_BASE}_ASSUMED_LINKS.dat 2000 1 "~"
/JOINKEYS
        PRD_CTR_NF  ,
        PRD_END_NT  ,
        PRD_SEC_NF  ,
        PRD_UWY_NF  ,
        PRD_UW_NT   
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD, rightside : I17PRDCOD_CT , leftside : S_TAIL
exit
EOF
SORT


NSTEP=${NJOB}_30
#------------------------------------------------------------------------------------
LIBEL="RETRO P NP : split empty prod_code with others input ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_OTHERS.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_RETRO_EMPTY.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_OTHERS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           8:1 - 8:,
        END_NT           9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
		TRNCOD_CF1		6:1 - 6:1,
		RETCTR_NF       24:1 - 24:,			
		I17PRDCOD_CT    65:1 - 65:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION POST_CUR_RETRO ( I17PRDCOD_CT = "" AND RETCTR_NF != "" AND (TRNCOD_CF1 = "2" OR TRNCOD_CF1 = "4") ) 
/OUTFILE ${SORT_O}
/INCLUDE POST_CUR_RETRO
/OUTFILE ${SORT_O2}
/OMIT POST_CUR_RETRO

exit
EOF
SORT


#${EST_OUT}
NSTEP=${NJOB}_40
#------------------------------------------------------------------------------------
LIBEL="RETRO join ESF_FCTRI17PRD_NEW to ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_${EST_BASE}_RETRO_EMPTY.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_RETRO_PRDCOD.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF           24:1 - 24:,
        RETEND_NT           25:1 - 25:,
        RETSEC_NF           26:1 - 26:,
        RETRTY_NF           27:1 - 27:,
        RETUW_NT            28:1 - 28:,
        S_HEAD              1:1 - 64:,
        S_TAIL              66:1 - 71:,
        PRD_CTR_NF           1:1 - 1:,
        PRD_END_NT           2:1 - 2:,
        PRD_SEC_NF           3:1 - 3:,
        PRD_UWY_NF           4:1 - 4:,
        PRD_UW_NT            5:1 - 5:,		
        I17PRDCOD_CT         8:1 - 8:
/JOINKEYS
        RETCTR_NF ,
        RETEND_NT ,
        RETSEC_NF ,
        RETRTY_NF ,
        RETUW_NT  
/INFILE ${DFILT}/${NJOB}_05_${IB}_${EST_BASE}_RETRO_LINKS.dat 2000 1 "~"
/JOINKEYS
        PRD_CTR_NF  ,
        PRD_END_NT  ,
        PRD_SEC_NF  ,
        PRD_UWY_NF  ,
        PRD_UW_NT   
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD, rightside : I17PRDCOD_CT , leftside : S_TAIL
exit
EOF
SORT



NSTEP=${NJOB}_50
#------------------------------------------------------------------------------------
LIBEL="merge files to ouput ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_${EST_BASE}_ASSUMED_PRDCOD.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_40_${IB}_${EST_BASE}_RETRO_PRDCOD.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_30_${IB}_${EST_BASE}_OTHERS.dat 2000 1"
SORT_O="${EST_OUT} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           8:1 - 8:,
        END_NT           9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT

/OUTFILE ${SORT_O} OVERWRITE

exit
EOF
SORT

# stats into log
cut -d~ -f65 ${EST_OUT} | cut -c1-2 | sort | uniq -c 


JOBEND


