#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
# nom du script SHELL          : ESFD2201.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 11/01/2022
# auteur                       : CGI puis Roger Cassis
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 )
#
# Job launched by ESID2220.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 11/01/2022 : M.NAJI : spira 101406 optimisation du ESFD2220

#==========================================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT


NSTEP=${NJOB}_10
#[012]
#[015]
#[026] /CONDITION CHARGES (ACMTRS_NT='10100' OR ACMTRS_NT='10400' OR ACMTRS_NT='22000' OR ACMTRS_NT ='23000')
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount of intermediary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESFD2003B00${IDF_CT}_125_${IB}_ESTC3604_FSTAT_O_00.dat 1000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESFD2003B01${IDF_CT}_125_${IB}_ESTC3604_FSTAT_O_01.dat 1000 1"
SORT_I3="${DFILT}/${NCHAIN}_ESFD2003B02${IDF_CT}_125_${IB}_ESTC3604_FSTAT_O_02.dat 1000 1"
SORT_I4="${DFILT}/${NCHAIN}_ESFD2003B03${IDF_CT}_125_${IB}_ESTC3604_FSTAT_O_03.dat 1000 1"
SORT_O="${EST_FSTAT}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF         1:1 -  1:,
        END_NT         2:1 -  2:,
        SEC_NF         3:1 -  3:,
        UWY_NF         4:1 -  4:,
        UW_NT          5:1 -  5:,
        ACMTRS_NT      6:1 -  6:,
        COD_CT         7:1 -  7:,
        AMT_M          8:1 -  8:EN 15/3,
        CUR_CF         9:1 -  9:,
        SSD_CF        10:1 - 10:,
        ESB_CF        11:1 - 11:,
        BALSHEY_NF    12:1 - 12:,
        CED_NF        13:1 - 13:,
        BRK_NF        14:1 - 14:,
        PAY_NF        15:1 - 15:,
        KEY_NF        16:1 - 16:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACMTRS_NT
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/CONDITION ACMTRS_FUTURES (ACMTRS_NT='10000' OR ACMTRS_NT='10010' OR ACMTRS_NT='10020' OR ACMTRS_NT='10030' OR ACMTRS_NT='10100' OR ACMTRS_NT='10400' OR ACMTRS_NT='22000' OR ACMTRS_NT ='23000')
/OUTFILE ${SORT_O}
/INCLUDE ACMTRS_FUTURES
/REFORMAT
	CTR_NF        ,
	END_NT        ,
	SEC_NF        ,
	UWY_NF        ,
	UW_NT         ,
	ACMTRS_NT     ,
	COD_CT        ,
	AMT_MC         ,
	CUR_CF        ,
	SSD_CF        ,
	ESB_CF        ,
	BALSHEY_NF    ,
	CED_NF        ,
	BRK_NF        ,
	PAY_NF        ,
	KEY_NF        
exit
EOF
SORT

JOBEND
