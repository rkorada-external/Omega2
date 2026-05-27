#!/bin/ksh
#=============================================================================
# nom de l'application          : Product Granularity Mapping 
# nom du script SHELL           : ESFD3815.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 16/06/2020
# auteur                        : Nhat Linh DOAN
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  - Injection of  counterpart code into TECLEDR format		
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 16/06/2019 : SPIRA 87446 : NLD : inject counterpart code to FTECLEDR file
#===============================================================================

# set -x

#NJOB="ESFD3815_EST_FTECLEDA_MVT"
#PARALLEL_JOB "${DCMD}/ESFD3815.cmd ${EST_FTECLEDA_MVT} ${EST_DETTRS_MAPPING}"


# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> CONTEXT_CT.................: ${CONTEXT_CT}  "

ECHO_LOG "#===> PARM_ICLODAT_D.............: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}"
ECHO_LOG "#===> PARM_CRE_D.................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM_BLCSHTYEA_NF..........: ${PARM_BLCSHTYEA_NF}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"


ECHO_LOG "#===> ............INPUT ................................................."
ECHO_LOG "#===> EST_DETTRS_MAPPING .................: ${EST_DETTRS_MAPPING}"
ECHO_LOG "#===> ............OUTPUT ................................................."
ECHO_LOG "#===> EST_OUT .............................: ${EST_OUT}"

 
EST_OUT="$1"

EST_BASE=`basename "${1%.*}"`
EST_DETTRS_MAPPING="$2"

 
ECHO_LOG "#===> EST_DETTRS_MAPPING .................: ${EST_DETTRS_MAPPING}"
ECHO_LOG "#===> ............OUTPUT ................................................."
ECHO_LOG "#===> EST_OUT .............................: ${EST_OUT}"
ECHO_LOG "#===> EST_BASE.............................: ${EST_BASE}"

#JOBEND


 
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="sort input ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_OUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_CUR.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_PREV.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           8:1 - 8:,
	END_NT           9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CTRSCOD_CF	 7:1 - 7:
/KEYS   CTR_NF,
	END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION POST_CUR ( CTRSCOD_CF = "" )
/OUTFILE ${SORT_O}
/INCLUDE POST_CUR
/OUTFILE ${SORT_O2}
/OMIT POST_CUR

exit
EOF
SORT



#${EST_OUT}
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="join CTRSCOD_CF  to ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_CUR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_CUR_CTRSCOD.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        S_DETTRS_CF	    6:1 - 6:,	 
        S_HEAD              1:1 - 6:,
        S_TAIL              8:1 - 71:,
        DETTRS_CF 	    1:1 - 1:,
	CTRSCOD_CF          2:1 - 2:		
/JOINKEYS
	S_DETTRS_CF 
/INFILE ${EST_DETTRS_MAPPING} 2000 1 "~"
/JOINKEYS 
        DETTRS_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD, rightside : CTRSCOD_CF , leftside : S_TAIL
exit
EOF
SORT


NSTEP=${NJOB}_30
#------------------------------------------------------------------------------------
LIBEL="merg files to ouput ${EST_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_${EST_BASE}_CUR_CTRSCOD.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_10_${IB}_${EST_BASE}_PREV.dat 2000 1"
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

JOBEND



