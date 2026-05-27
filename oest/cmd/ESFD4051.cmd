#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 
# nom du script SHELL           : ESFD4051.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 06/01/2022
# auteur                        : M.NAJI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Optimisation et pr�paration des fichier pour  ESFD4020, 
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[01] 06/01/2022 : M.NAJI : SPIRA 101493 : CREATION 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_10
# Filter EST_FTRSLNK_TXT on PRS_CF = "751"
#-----------------------------------------------------------------------------
LIBEL="Filter EST_FTRSLNK_TXT on PRS_CF = "751""
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  PRS_CF    1:1 -  1:
/CONDITION IS_PRS_751 ( PRS_CF = "751" )
/OUTFILE $SORT_O
/INCLUDE IS_PRS_751
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_20
# Extend EST_FBOPRSLNK_TXT with PRS_ 751 and of EST_FTRSLNK_TXT
#-----------------------------------------------------------------------------
LIBEL="Extend EST_FBOPRSLNK_TXT with PRS_ 751 and of EST_FTRSLNK_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FBOPRSLNK_TXT}  500 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FBOPRSLNK_FTRSLNK.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
			TRSPFX_CF	          1:1 -  1:,   
			ACMTRSL0_NT	        2:1 -  2:,   
			ACMTRSL1_NT	        3:1 -  3:,   
			ACMTRSL2_NT	        4:1 -  4:,   
			ACMTRSL3_NT	        5:1 -  5:,   
			ACMTRSLL1_NT	      6:1 -  6:,   
			ACMTRSLL2_NT	      7:1 -  7:,   
			TRSTYP_NT	          8:1 -  8:,   
			DETTRS_CF	          9:1 -  9:,     
			PCPTRS_CF	          10:1 - 10:,  
			TRS_CF	            11:1 - 11:,  
			SUBTRS_CF	          12:1 - 12:,  
			ESTIM_NT	          13:1 - 13:,  
			TRNTYP_CT           14:1 - 14:,  			
			PRS_CF_F2           1:1  - 1:,
			ACMTRS_NT_F2				2:1  - 2:,
			DETTRS_CF_F2				3:1  - 3:,
			all_cols_F1		 		  1:1  - 14:
/joinkeys 
       DETTRS_CF
/INFILE ${DFILT}/${NJOB}_10_${IB}_FTRSLNK_751.dat 500 1 "~" 
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:all_cols_F1
	,rightside:PRS_CF_F2   
	,rightside:ACMTRS_NT_F2   
exit
EOF
SORT

if [ "${IDF_CT}" = "EBS_ESFD4050_ARCSTATGTA" ] || [ "${IDF_CT}" = "I17G_ESFD4050_ARCSTATGTA" ]
then

NSTEP=${NJOB}_30
# SORT ARCSTAGTA with ONLY ACTUAL
#-----------------------------------------------------------------------------
LIBEL="SORT ARCSTAGTA with ONLY ACTUAL ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_ARCSTATGTA} 1000 1"
SORT_I2="${EST_ARCSTATGTAR} 1000 1"
SORT_O="${EST_GT_A_AR} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHYM16_NF      3:1 -  3:6,       
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLOSTYP_NF       17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 35:,
        FILLER2          38:1 - 40:,
        all_cols_F1      1:1 -  72:
/KEYS all_cols_F1
/CONDITION COND_ONLYACTUAL  (BALSHEY_NF < ${ICLODAT_YEA}) AND (  (( ( "12"  CT TRNCOD1_CF) AND ("4" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  ) ) OR  (( ( "12"  CT TRNCOD1_CF) AND ("1" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  ) ) )
/OUTFILE ${SORT_O}
/INCLUDE COND_ONLYACTUAL
exit
EOF
SORT

fi 



JOBEND

