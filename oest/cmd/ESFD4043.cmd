#!/bin/ksh
#=============================================================================
# nom de l'application          : I17G -APP4 (TL and cashflow data aggregation)
# nom du script SHELL           : ESFD4043.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 10\03\2021
# auteur                        : Charles SOCIE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  TI17CTRINFO update table
#
#-----------------------------------------------------------------------------
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> PARM_ICLODAT_D...................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PARM_BATCHUSER...................................................: ${PARM_BATCHUSER}"
ECHO_LOG "#===> PARM_CRE_D.......................................................: ${PARM_CRE_D}"
ECHO_LOG "#===> MERGE_PERICASE_EXTENDED..........................................: ${MERGE_PERICASE_EXTENDED}"
ECHO_LOG "#========================================================================="



NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Load file into the working table BTRAV..ESFD4040_TI17CTRINFO"
BCP_WAY="IN"
BCP_TRUNCATE="YES"
BCP_VER=""
BCP_I="${MERGE_PERICASE_EXTENDED}"
BCP_TABLE="BTRAV..ESFD4040_TI17CTRINFO"
BCP

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Update table BEST..TI17CTRINFO_01"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
ISQL_QRY="exec TI17CTRINFO_01 '${PARM_ICLODAT_D}' , '${PARM_BATCHUSER}' , '${PARM_CRE_D}'"
ISQL


NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
# Sort and ADD new columns
#-----------------------------------------------------------------------------
LIBEL="SORT of MERGE_PERICASE_EXTENDED"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${MERGE_PERICASE_EXTENDED} 4000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_MERGE_PERICASE_EXTENDED.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            1:1 -  1:,
        END_NT            2:1 -  2:EN,
        SEC_NF            3:1 - 3:EN,
        UWY_NF            4:1 - 4:,
        UW_NT             5:1 - 5:EN,
		RETCTR_NF         6:1 - 6:,
        RETEND_NT         7:1 - 7:EN,
        RETSEC_NF         8:1 - 8:EN,
        RTY_NF            9:1 - 9:,
        RETUW_NT         10:1 - 10:EN,
		LOFACTORSTD_R	 11:1 - 11:EN,
		LOFACTORINI_R	 12:1 - 12:EN,
		LCPATTERN_R		 13:1 - 13:EN,
		CSMPATTERN_R	 14:1 - 14:EN,
		ANNLIM_B	  	 15:1 - 15:EN,
		EGPI_R1			 16:1 - 16:EN,
		EGPI_R2			 17:1 - 17:EN,
		EARP_R1			 18:1 - 18:EN,
		COMMENT_NF		 19:1 - 19:EN
/KEYS CTR_NF
	,SEC_NF
	,UWY_NF
	,UW_NT
	,END_NT
	,RETCTR_NF
	,RETSEC_NF
	,RTY_NF
	,RETUW_NT
	,RETEND_NT
/DERIVEDFIELD CLOSING_D "${PARM_ICLODAT_D}~"
/DERIVEDFIELD USER_CF "${PARM_BATCHUSER}~"
/DERIVEDFIELD CRE_D "${PARM_CRE_D}~"
/DERIVEDFIELD EMPTY "~~"
/OUTFILE ${SORT_O}
/REFORMAT CTR_NF
	,SEC_NF
	,UWY_NF
	,UW_NT
	,END_NT
	,RETCTR_NF
	,RETSEC_NF
	,RTY_NF
	,RETUW_NT
	,RETEND_NT
	,LOFACTORSTD_R
	,LOFACTORINI_R
	,LCPATTERN_R
	,CSMPATTERN_R
	,ANNLIM_B
	,CLOSING_D
	,CRE_D
	,USER_CF
	,EMPTY
	,EGPI_R1
	,EGPI_R2
	,EARP_R1
	,COMMENT_NF
exit
EOF
SORT

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Load file into the table BEST..TI17CTRINFO"
BCP_WAY="IN"
BCP_VER=""
BCP_I="${DFILT}/${NJOB}_15_${IB}_SORT_MERGE_PERICASE_EXTENDED.dat"
BCP_TABLE="BEST..TI17CTRINFO"
BCP

JOBEND