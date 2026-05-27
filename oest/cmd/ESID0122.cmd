#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESID0121.cmd
# revision                      : $Revision: 1.0 
# date de creation              : 05/02/2019
# auteur                        : Rafael Vieville
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Generation of Estimates File and retro account files :APOLO Quarterly
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] 08/04/2022 M.NAJI     :SPIRA 111484 Optimisation CLOSING_D0 ESID0120
#======================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd

# Job Initialization
JOBINIT

# Parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3

CRE_D_PLUS_1_DAY=$(date -d "${CRE_D:0:4}-${CRE_D:4:2}-${CRE_D:6:2} +1 day" +"%Y%m%d")
ECHO_LOG "#===> CRE_D ..............................: ${CRE_D}"
ECHO_LOG "#===> CRE_D_PLUS_1_DAY ...................: ${CRE_D_PLUS_1_DAY}"



if [ ${EST_ESID0060_COND1} = "N"  -a ${EST_ESID0060_COND3} = "N" ] ||
	[ ${EST_VARIANTE} = "7" -o  ${EST_VARIANTE} = "4" ]
then
	NSTEP=${NJOB}_10
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Current Generation of Estimates File ARCH"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${EST_FLIFESTY1_ARCH}
	BCP_QRY="execute BEST..PsLIFEST_09_ARCH ${BALSHTYEA_NF}"
	BCP

	NSTEP=${NJOB}_15
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Current Generation of Estimates File CUR"
	BCP_WAY="OUT"
	BCP_VER="+"
	BCP_O=${DFILT}/${NSTEP}_${IB}_LIFEST_CUR.dat
	BCP_QRY="execute BEST..PsLIFEST_09_CUR ${BALSHTYEA_NF}"
	BCP

	NSTEP=${NJOB}_20
	#------------------------------------------------------------------------------
	LIBEL="Merge Generation of Estimates Files"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_FLIFESTY1_ARCH} 1000 1"
	SORT_I2="${DFILT}/${NJOB}_15_${IB}_LIFEST_CUR.dat 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_LIFEST.dat"
	INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	CTR_NF           1:1 -  1:,             
	END_NT           2:1 -  2:,             
	SEC_NF           3:1 -  3:,             
	UWY_NF           4:1 -  4:,             
	UW_NT            5:1 -  5:,             
	CRE_D            6:1 -  6:,             
	BALSHEY_NF       7:1 -  7: EN,             
	BALSHTMTH_NF     8:1 -  8: EN,             
	ACY_NF           9:1 -  9:,             
	GAAP_NT         10:1 - 10:,             
	DETTRNCOD_CF    11:1 - 11:,             
	ACM_NF          12:1 - 12:,             
	PRS_CF          13:1 - 13: EN,             
	ACMTRS_NT       14:1 - 14:,             
	SSD_CF          15:1 - 15:,             
	CUR_CF          16:1 - 16:,             
	ESTMNT_M        17:1 - 17: ,     
	INDSUP_B        18:1 - 18:,             
	ORICOD_LS       19:1 - 19:,             
	CREUSR_CF       20:1 - 20:,             
	LSTUPD_D        21:1 - 21:,             
	LSTUPDUSR_CF    22:1 - 22:,             
	ORICTR_NF       23:1 - 23:,             
	ORISEC_NF       24:1 - 24:,             
	ORIUWY_NF       25:1 - 25:,             
	DIFF_M          26:1 - 26: ,     
	PROPAGATION_B   27:1 - 27:,             
	CALCULATED_B    28:1 - 28:,             
	BATCH_B         29:1 - 29:,
	SPIMOD_CT        30:1 - 30:
/DERIVEDFIELD SPACE ' ~'
/DERIVEDFIELD 1SPACE ' '
/DERIVEDFIELD VIDE '~'
/DERIVEDFIELD ZERO "0~"
/CONDITION COND_PRS  PRS_CF = 500  AND	BALSHTMTH_NF <= ${BALSHTMTH_NF}  AND 	 BALSHEY_NF = ${BALSHTYEA_NF} and  CRE_D <= "${CRE_D_PLUS_1_DAY}"
/KEYS
    CTR_NF ,
    END_NT ,
    SEC_NF ,
    UWY_NF ,
    UW_NT ,
    ACY_NF ,
    ACMTRS_NT ,
    GAAP_NT ,
    DETTRNCOD_CF,
    BALSHTMTH_NF DESCENDING ,
    CRE_D DESCENDING 
/OUTFILE   ${SORT_O}
/INCLUDE COND_PRS
/REFORMAT
    SSD_CF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	ACY_NF,
	CRE_D,
	PRS_CF,
	ACMTRS_NT,
	BALSHEY_NF,
	BALSHTMTH_NF,
	CUR_CF,
	ESTMNT_M,
	INDSUP_B,
	ORICOD_LS,
	CREUSR_CF,
	LSTUPD_D,
	LSTUPDUSR_CF,
	DETTRNCOD_CF,
	SPACE,
	GAAP_NT,
    DIFF_M,
	PROPAGATION_B,
	ACM_NF,
	ORICTR_NF,
	ORISEC_NF,
	ORIUWY_NF,                  
	SPACE,
	1SPACE,SPACE,
	ZERO,
	ZERO,
	VIDE,           
	VIDE,
	ZERO,
	SPIMOD_CT,
	VIDE,
	VIDE,
	VIDE,
	VIDE,
	VIDE,
	ZERO,
	ZERO,
	SPACE,
	ZERO,
	ZERO,
	ZERO,
	ZERO,
	ZERO,
	ZERO,
	ZERO,
	BATCH_B,
	ZERO,
	ZERO
exit
EOF
SORT

	NSTEP=${NJOB}_30
	#------------------------------------------------------------------------------
	LIBEL="Create Estimates File"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_20_${IB}_LIFEST.dat 1000 1"
	SORT_O="${EST_FLIFESTY1}"
	INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CTR_NF               2:1 -  2:,             
	END_NT               3:1 -  3:EN,             
	SEC_NF               4:1 -  4:EN,             
	UWY_NF               5:1 -  5:EN,             
	UW_NT                6:1 -  6:EN,             
	ACY_NF               7:1 -  7:EN,             
	ACMTRS_NT           10:1 - 10:,             
	DETTRNCOD_CF        20:1 - 20:,             
	GAAP_NT             22:1 - 22:
/KEYS
    CTR_NF ,
    END_NT ,
    SEC_NF ,
    UWY_NF ,
    UW_NT ,
    ACY_NF ,
    ACMTRS_NT ,
    GAAP_NT ,
    DETTRNCOD_CF
/STABLE
/SUM
exit
EOF
SORT

fi

JOBEND
