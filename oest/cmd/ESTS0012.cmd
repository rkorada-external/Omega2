#!/bin/ksh
#=============================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESTS0012.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 06\12\2019
# auteur                        : Arnaud RUFFAULT
#-----------------------------------------------------------------------------
# description : Sort DLCUMGTAAR files by CSUOE
#
# Modification #93580 04/02/2021 : Sort DLCUMGTAAR to get ITD and UPR NBD 
#-----------------------------------------------------------------------------
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
INPUT=$2
OUTPUT=$3

#-----------------------------------------------------------------------------
NSTEP=${NJOB}_$1
LIBEL="Sort DLCUMGTAAR files by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${INPUT}.dat 2000 1"
SORT_O="${OUTPUT}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF   			1:1 - 1:,
	ESB_CF   			2:1 - 2:,
	BALSHEY_NF         	3:1 - 3:,
	BALSHRMTH_NF       	4:1 - 4:,
	BALSHRDAY_NF       	5:1 - 5:,
	TRNCOD_CF          	6:1 - 6:,
	DBLTRNCOD_CF       	7:1 - 7:,
	CTR_NF         		8:1 - 8:,
	END_NT         		9:1 - 9:,
	SEC_NF          	10:1 - 10:,
	UWY_NF          	11:1 - 11:,
	UW_NT            	12:1 - 12:,
	LINETYP_NF         	13:1 - 13:,
	ACY_NF           	14:1 - 14:,
	SCOSTRMTH_NF       	15:1 - 15:,
	SCOENDMTH_NF       	16:1 - 16:,
	CLOSTYP_NF         	17:1 - 17:,
	CUR_CF          	18:1 - 18:,
	AMT_M         		19:1 - 19:,
	CED_NF           	20:1 - 20:,
	BRK_NF           	21:1 - 21:,
	PAY_NF          	22:1 - 22:,
	KEY_NF           	23:1 - 23:,
	RETCTR_NF          	24:1 - 24:,
	RETEND_NT          	25:1 - 25:,
	RETSEC_NF          	26:1 - 26:,
	RTY_NF           	27:1 - 27:,
	RETUW_NT           	28:1 - 28:,
	RETOCCYEA_NF       	29:1 - 29:,
	RETACY_NF          	30:1 - 30:,
	RETSCOSTRMTH_NF    	31:1 - 31:,
	RETSCOENDMTH_NF    	32:1 - 32:,
	RCL_NF           	33:1 - 33:,
	RETCUR_CF          	34:1 - 34:,
	RETAMT_M           	35:1 - 35:,
	PLC_NT         		36:1 - 36:,
	RTO_NF         		37:1 - 37:,
	INT_NF        	    38:1 - 38:,
	RETPAY_NF          	39:1 - 39:,
	RETKEY_CF          	40:1 - 40:,
	RETINTAMT_M        	41:1 - 41:,
	ACMTRS_NT          	42:1 - 42:,
	ACMAMT_MC          	43:1 - 43:,
	ACMCUR_CF          	44:1 - 44:,
	PRS_CF             	45:1 - 45:,
	SEG_NF          	46:1 - 46:,
	LOB_CF         		47:1 - 47:,
	NAT_CF        	    48:1 - 48:,
	TYP_CT        	    49:1 - 49:,
	PATTYP_CT          	50:1 - 50:,
	SEGLOB_CF          	51:1 - 51:,
	ACMTRSL3           	52:1 - 52:,
	TRNTYP_CT          	53:1 - 53:,
	TRSTYP_NT          	54:1 - 54:,
	TRSPFX_CF          	55:1 - 55: 
/KEYS
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/CONDITION COND_ITD_AND_UPR ((ACMTRSL3 ="1030" OR ACMTRSL3 ="1010") AND CLOSTYP_NF = "I" AND TYP_CT = "A")
/OUTFILE ${SORT_O}
/INCLUDE COND_ITD_AND_UPR

exit
EOF
SORT
