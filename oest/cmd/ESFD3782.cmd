#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD3782.cmd
# auteur                        : Mr JYP
#---------------------------------------------------------------------------------
# description
#  update correct ESB for retro case
#
#---------------------------------------------------------------------------------
# 09/09/2024 : spira 111665 : Mr JYP : manage pericase retro to use the correct ESB
#[002] 19/06/2025 : SPIRA 113066: MZM : Remove Computation of transaction "49420" ; "49506"  ; "10123"
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctjsb.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ICLODAT_D....................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> CLOTYP.......................................................: ${TYPEINV}"
ECHO_LOG "#===> NORME_CF.....................................................: ${NORME_CF}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> ESF_CSM_LC_FTECLEDA.................................................: ${ESF_CSM_LC_FTECLEDA}"
ECHO_LOG "#===> ESF_CSM_LC_FTECLEDR.................................................: ${ESF_CSM_LC_FTECLEDR}"
ECHO_LOG "#===> ESF_OIRDVPERICASE ..................................................: ${ESF_OIRDVPERICASE}"
ECHO_LOG "#===> ............ OUTPUT ................................................"
ECHO_LOG "#===> ESF_CSM_LC_FTECLEDA.................................................: ${ESF_CSM_LC_FTECLEDA}"
ECHO_LOG "#===> ESF_CSM_LC_FTECLEDR.................................................: ${ESF_CSM_LC_FTECLEDR}"
ECHO_LOG "#========================================================================="




NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Get ESB from Pericase for $ESF_CSM_LC_FTECLEDA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_CSM_LC_FTECLEDA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        CTR_NF          24:1 - 24:,
        END_NT          25:1 - 25:,
        SEC_NF          26:1 - 26:,
        UWY_NF          27:1 - 27:,
        UW_NT           28:1 - 28:,
        all_cols1        1:1 - 118:,
        PER_SSD_CF       1:1 -  1:,
        PER_CTR_NF       3:1 -  3:,
        PER_END_NT       4:1 -  4:,
        PER_SEC_NF       5:1 -  5:,
        PER_UWY_NF       6:1 -  6:,
        PER_UW_NT        7:1 -  7:,
        PER_ESB_CF       8:1 -  8:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
/INFILE ${ESF_OIRDVPERICASE} 1000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols1
       ,rightside:PER_ESB_CF,PER_SSD_CF
exit
EOF
SORT


NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Replace ESB from Pericase to FTECLEDA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_FTECLEDA.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA.dat 1000 1 "  
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -   1:,
        ESB_CF           2:1 -   2:,
        TRNCOD1_CF       6:1 -   6:1,
        CTR_NF           8:1 -   8:,
        END_NT           9:1 -   9:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        UW_NT           12:1 -  12:,
        all_cols1        3:1 - 118:,
        PER_ESB_CF     119:1 - 119:,
        PER_SSD_CF     120:1 - 120:
/CONDITION retro (TRNCOD1_CF = "2" OR TRNCOD1_CF = "4") and PER_ESB_CF != "" and PER_SSD_CF != ""
/DERIVEDFIELD PER2_ESB_CF if retro then PER_ESB_CF else ESB_CF
/DERIVEDFIELD PER2_SSD_CF if retro then PER_SSD_CF else SSD_CF
/OUTFILE   ${SORT_O}
/REFORMAT PER2_SSD_CF, PER2_ESB_CF, all_cols1
exit
EOF
SORT


###[002]

NSTEP=${NJOB}_35
LIBEL="  REMOVE TRANSACTION  49420 49506   10123 "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDA.dat 1000 1 "
SORT_O="${ESF_CSM_LC_FTECLEDA} 1000 1" 
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	TRNCOD_CF 			6:1 	- 6:,
	TRNCOD3_5_CF 		6:3 	- 6:7,	
	CTR_NF 					8:1 	- 8:,
	END_NT 					9:1 	- 9:,
	SEC_NF 					10:1 	- 10:,
	UWY_NF 					11:1 	- 11:,
	UW_NT 					12:1 	- 12:,
  FILLER_1_17      1:1 	- 17:,
	CUR_CF 					18:1 	- 18:,	
	AMT_M 					19:1 	- 19:EN 18/3,
  FILLER_20_33    20:1 	- 33:,
	RETCUR_CF 			34:1 	- 34:,		
	RETAMT_M 				35:1 	- 35:EN 18/3,
  FILLER_36_113   36:1 	- 113:,			
	GT_ANNUL 				114:1 - 114:,	
  FILLER_115_120  115:1 - 120:,		
	ACMTRS_NT_F2		121:1 - 121:,	
  FILLER_122_122  122:1 - 122:,		
	INI_STATUS			123:1 - 123:,
	FIRST_CLODAT_D	124:1 - 124:,
  FILLER_125_127  125:1 - 127:,	
	FILLER					1:1	- 127:,
	CSM_ENDING_M 		128:1 - 128:EN 18/3,
	LC_ENDING_M 		129:1 - 129:EN 18/3			
/CONDITION REM_CSM_BOOKING   ( ( TRNCOD3_5_CF != "49420" ) AND  (TRNCOD3_5_CF != "49506" ) AND ( TRNCOD3_5_CF != "10123"   ) )
/OUTFILE ${SORT_O}
/INCLUDE REM_CSM_BOOKING
exit
EOF
SORT


NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Get ESB from Pericase for $ESF_CSM_LC_FTECLEDR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_CSM_LC_FTECLEDR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        CTR_NF          24:1 - 24:,
        END_NT          25:1 - 25:,
        SEC_NF          26:1 - 26:,
        UWY_NF          27:1 - 27:,
        UW_NT           28:1 - 28:,
        all_cols1        1:1 - 118:,
        PER_SSD_CF       1:1 -  1:,
        PER_CTR_NF       3:1 -  3:,
        PER_END_NT       4:1 -  4:,
        PER_SEC_NF       5:1 -  5:,
        PER_UWY_NF       6:1 -  6:,
        PER_UW_NT        7:1 -  7:,
        PER_ESB_CF       8:1 -  8:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
/INFILE ${ESF_OIRDVPERICASE} 1000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols1
       ,rightside:PER_ESB_CF,PER_SSD_CF
exit
EOF
SORT


NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Replace ESB from Pericase to FTECLEDR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_FTECLEDR.dat 1000 1 "
SORT_O="${ESF_CSM_LC_FTECLEDR} 1000 1"   
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -   1:,
        ESB_CF           2:1 -   2:,
        TRNCOD1_CF       6:1 -   6:1,
        CTR_NF           8:1 -   8:,
        END_NT           9:1 -   9:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        UW_NT           12:1 -  12:,
        all_cols1        3:1 - 118:,
        PER_ESB_CF     119:1 - 119:,
        PER_SSD_CF     120:1 - 120:
/CONDITION retro (TRNCOD1_CF = "2" OR TRNCOD1_CF = "4") and PER_ESB_CF != "" and PER_SSD_CF != ""
/DERIVEDFIELD PER2_ESB_CF if retro then PER_ESB_CF else ESB_CF
/DERIVEDFIELD PER2_SSD_CF if retro then PER_SSD_CF else SSD_CF
/OUTFILE   ${SORT_O}
/REFORMAT PER2_SSD_CF, PER2_ESB_CF, all_cols1
exit
EOF
SORT

exit
EOF
SORT



JOBEND
