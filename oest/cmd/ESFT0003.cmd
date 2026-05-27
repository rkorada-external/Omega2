#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 projet TRANSITION 
# nom du script SHELL           : ESFT0003.cmd
# date de creation              : 12/05/2020
# auteur                        : JYP - PERSEE
#-----------------------------------------------------------------------------
# description
#  : projet TRANSITION : génération du fichier FMARKET spéficique
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[001] 12/05/2020 JYP : SPIRA 82719 : generation du fichier FMARKET speficique transition
#[002] 18/05/2020 JYP : SPIRA 82719 : generation du fichier FUWRETSEC speficique transition
#[003] 19/05/2020 JYP : SPIRA 82719 : generation du fichier FRARAT spécifique transition 
#[004] 25/05/2020 JYP : SPIRA 82719 : generation du fichier FCTRGRO et bugfix 
#[005] 15/06/2020 JYP : SPIRA 82718 : generate FSEGEST file for transition
#[006] 23/06/2020 JYP : SPIRA 82718 : bugfix GTRGRO
#[007] 13/10/2020 LEL :	SPIRA 86487 : UPDATE COLUMN TO MEET NEW TRANSITION FILE FORMAT
#[008] 09/04/2021 LEL :	SPIRA 95131 : ADD UWY_NF TO JOIN KEY FCTRGRO
#[009] 22/04/2021 JYP : SPIRA 94976 : retroNP issue
#[010] 03/05/2021 JYP : SPIRA 94976 : retroNP issue : UWRETSEC file
#[011] 18/05/2021 JYP : SPIRA 96349 : bugfix ESF_FCTRGRO_TRN file UWY
#[012] 20/05/2021 JYP : SPIRA 96349 : ESF_FCTRGRO_TRN change ref_quarter for ICR-RAD
#[013] 29/09/2021 JYP : SPIRA 98693 : CTRGRO File issue 
#[014] 30/09/2021 LEL : SPIRA 98698 : Create new FCTRGRO format for FUTURE uses 
#[015] 02/02/2022 JYP : SPIRA 102131: bugfix I17L I17P RARAT  
#[016] 19/04/2022 JYP : SPIRA 102131:remove duplicates into CTRGRO
#[017] 27/04/2022 JYP : SPIRA 102131:remove duplicates into CTRGRO
#[019] 19/19/2024 JYP : SPIRA 112188:add 2 fields RALIC_R/RALRC_R in RARAT
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

ECHO_LOG ""                                                                                  
ECHO_LOG "#==============================================================================================="                                  
ECHO_LOG "#===> NORME .......................................: ${NORME}"
ECHO_LOG "#===> NORME_CF ....................................: ${NORME_CF}"  
ECHO_LOG "#===> CONTEXT_CT ..................................: ${CONTEXT_CT}"                             
ECHO_LOG "#===> TYPEINV .....................................: ${TYPEINV}" 
ECHO_LOG "#===> IDF_CT ......................................: ${IDF_CT}" 
ECHO_LOG "#===> param_Request_id ............................: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id ............................: ${param_Context_id}  "
ECHO_LOG "#===> PARM_CRE_D ..................................: $PARM_CRE_D"
ECHO_LOG "#===> PARM_CLODAT_D ...............................: $PARM_CLODAT_D"
ECHO_LOG "#===> PARM_ICLODAT_D ..............................: $PARM_ICLODAT_D"
ECHO_LOG "#....................... INPUTS ................................................................"  
ECHO_LOG "#===> TRANSITION_DATA .............................: ${TRANSITION_DATA}" 
ECHO_LOG "#===> ESF_FMARKET_STD .............................: ${ESF_FMARKET_STD}" 
ECHO_LOG "#===> ESF_FCTRGRO_STD..............................: ${ESF_FCTRGRO_STD}"
ECHO_LOG "#....................... OUTPUT ................................................................"  
ECHO_LOG "#===> ESF_FMARKET_TRN .............................: ${ESF_FMARKET_TRN}"
ECHO_LOG "#===> ESF_FRARAT_TRN ..............................: ${ESF_FRARAT_TRN}"
ECHO_LOG "#===> ESF_FCTRGRO_TRN..............................: ${ESF_FCTRGRO_TRN}"
ECHO_LOG "#===> ESF_FSEGEST_TRN .............................: ${ESF_FSEGEST_TRN}"
ECHO_LOG "#===> ESF_FUWRETSEC_TRN ...........................: ${ESF_FUWRETSEC_TRN}"
ECHO_LOG "#===> ESF_FCTRGRO_FUT_TRN..........................: ${ESF_FCTRGRO_FUT_TRN}"
ECHO_LOG "#===> ESF_FCTRGRO_SEGNF_TRN .......................: ${ESF_FCTRGRO_SEGNF_TRN}"           
ECHO_LOG "#==============================================================================================="  

NSTEP=${NJOB}_10
LIBEL="CREATE FMARKET FILE from Transition file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IDF_CT}_FMARKET_MERGED.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	PER_CTR_NF    3:1 - 3:,
	PER_SEC_NF    4:1 - 4:,
	PER_UWY_NF    5:1 - 5:,
	PER_UW_NT     6:1 - 6:,
	PER_END_NT    7:1 - 7:,
	PER_CTRNAT_CT 10:1 - 10:,
	REF_QUARTER   28:1 - 28:,
	GRPGRP3_NT    29:1 - 29:,
	CTR_NF        1:1  - 1:,
	END_NT        2:1  - 2:,
	SEC_NF        3:1  - 3:,
	UWY_NF        4:1  - 4:,
	UW_NT         5:1  - 5:,
	SUBMRK_LS     7:1 - 7:,
	MRKUNT_NT     8:1  - 8:,
	SUBMRK_NT     9:1  - 9:
/joinkeys
	PER_CTR_NF ,
	PER_END_NT ,
	PER_SEC_NF ,
	PER_UWY_NF ,
	PER_UW_NT 
/INFILE ${ESF_FMARKET_STD} 1000 1 "~"
/joinkeys
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT 
	LEFTSIDE: PER_CTR_NF,PER_END_NT,PER_SEC_NF,PER_UWY_NF,PER_UW_NT,PER_CTRNAT_CT,
	RIGHTSIDE: SUBMRK_LS,MRKUNT_NT,SUBMRK_NT ,
	LEFTSIDE : GRPGRP3_NT , REF_QUARTER
exit
EOF
SORT

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Concatenate Lob GRPGRP3_NT + Reference quarter "

AWK_I=${DFILT}/${NJOB}_10_${IDF_CT}_FMARKET_MERGED.dat
AWK_O=${ESF_FMARKET_TRN}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; }
     { print \$1 "~" \$2 "~" \$3 "~" \$4 "~" \$5 "~" \$6 "~" \$7 "~" \$8 "~" \$9 "~" \$10 \$11  }
exit
EOF
AWK

NSTEP=${NJOB}_30
LIBEL="CREATE FUWRETSEC_TRN from Transition file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IDF_CT}_FUWRETSEC.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    RETCTR_NF   3:1 - 3:,
    RETSEC_NF   4:1 - 4:EN,
    RTY_NF      5:1 - 5:,
    RETUW_NT    6:1 - 6:EN,
    RETEND_NT   7:1 - 7:EN,
    CTRTYP_CT   9:1 - 9:,
    CTRNAT_CT   10:1 - 10:,
    REF_QUARTER	28:1 - 28:,
    GRPGRP3_NT  29:1 - 29:,
    SUBMRK_LS   7:1  - 7:,
    MRKUNT_NT   8:1  - 8:,
    SUBMRK_NT   9:1  - 9:
/CONDITION COND_RETRO CTRTYP_CT = "R"
/INCLUDE COND_RETRO
/OUTFILE ${SORT_O}
/KEYS
	RETCTR_NF ,
	RTY_NF,
	RETSEC_NF ,
	RETEND_NT ,
	RETUW_NT  
/REFORMAT 
	RETCTR_NF ,
	RETEND_NT ,
	RETSEC_NF ,
	RTY_NF    ,
	RETUW_NT  ,
	CTRNAT_CT ,
	SUBMRK_LS ,
	MRKUNT_NT ,
	SUBMRK_NT ,
	GRPGRP3_NT,
	REF_QUARTER
exit
EOF
SORT

NSTEP=${NJOB}_35
LIBEL="SORT retro file FUWRETSEC_TRN "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IDF_CT}_FUWRETSEC.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IDF_CT}_FUWRETSEC.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    RETCTR_NF   1:1 - 1:,
    RETSEC_NF   3:1 - 3:EN,
    RTY_NF      4:1 - 4:
/OUTFILE ${SORT_O}
/KEYS
	RETCTR_NF ,
	RTY_NF,
	RETSEC_NF 
exit
EOF
SORT

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="RETRO : Concatenate Lob GRPGRP3_NT + Reference quarter "

AWK_I=${DFILT}/${NJOB}_35_${IDF_CT}_FUWRETSEC.dat
AWK_O=${ESF_FUWRETSEC_TRN}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; }
     { 
	  if ( \$6 == "NP" )
     	  \$6="N";	  
		  
	  print \$1 "~" \$2 "~" \$3 "~" \$4 "~" \$5 "~" \$6 "~" \$7 "~" \$8 "~" \$9 "~" \$10 \$11 
	  }
exit
EOF
AWK

NSTEP=${NJOB}_50
LIBEL="CREATE FRARAT FILE from Transition file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IDF_CT}_FRARAT.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    SSD_CF      1:1 - 1:,
    ESB_CF      2:1 - 2:,
    CTRTYP_CT   9:1 - 9:,
    CTRNAT_CT   10:1 - 10:,
    REF_QUARTER	28:1 - 28:,
    GRPGRP3_NT  29:1 - 29:,
    PRMRAT_R    30:1 - 30:,
    RSRVRAT_R   31:1 - 31:
/KEYS
	SSD_CF     ,
	ESB_CF     ,
	CTRTYP_CT  ,
	CTRNAT_CT  ,
	GRPGRP3_NT , 
	REF_QUARTER 		
/REFORMAT 
	SSD_CF     ,
	ESB_CF     ,
	CTRTYP_CT  ,
	CTRNAT_CT  ,
	PRMRAT_R   ,
	RSRVRAT_R  ,
	GRPGRP3_NT ,
	REF_QUARTER   		
exit
EOF
SORT

NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="RARAT : Concatenate Lob GRPGRP3_NT + Reference quarter "
AWK_I=${DFILT}/${NJOB}_50_${IDF_CT}_FRARAT.dat
AWK_O=${ESF_FRARAT_TRN}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~";
       prev_key="";
	   current_key="";
	   norme="$NORME_CF";
	 }
     { 	 
	  current_key = \$1 \$2 \$3 \$4 \$7 \$8 ;
	  
	  if ( \$4 == "NP" )
	    \$4="N";
	  
	  if ( \$3 == "R" && \$4 == "P" )
	     domain="RetroP";
	  else
	  { 
		if ( \$3 == "R" && \$4 == "N" )
			domain="RetroNP";
		else
			domain="Gross";
	  } 
	 
	  if ( current_key != prev_key )
		print \$1 "~" \$2 "~~" norme "~" \$4 "~" domain "~" \$5 "~" \$6 "~" \$7 \$8 "~0~0~0";

      prev_key = current_key;
	 }
exit
EOF
AWK

NSTEP=${NJOB}_70
LIBEL="CREATE FCTRGRO from Transition file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IDF_CT}_FCTRGRO_MERGED.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
   PER_CTR_NF     3:1 - 3:,
   PER_SEC_NF     4:1 - 4:,
   PER_UWY_NF     5:1 - 5:,
   PER_UW_NT      6:1 - 6:,
   PER_END_NT     7:1 - 7:,
   PER_CTRNAT_CT  10:1 - 10:,
   BS_QUARTER_LR  16:1 - 16:,
   SEG_NF         17:1 - 17:,
   REF_QUARTER	  23:1 - 23:,
   GRPGRP3_NT     29:1 - 29:,  
   CTR_NF         1:1  - 1:,
   END_NT         2:1  - 2:,
   SEC_NF         3:1  - 3:,
   VRS_NF         4:1  - 4:,
   SSD_CF         5:1  - 5:,
   SEGTYP_CT      6:1  - 6:,
   DIV_NT         8:1  - 8:,
   CED_NF         9:1  - 9:,		
   UWGRP_CF       10:1 - 10:,
   LOB_CF         11:1 - 11:,
   SOB_CF         12:1 - 12:,
   TOP_CF         13:1 - 13:,
   NAT_CF         14:1 - 14:,
   SUBNAT_CF      15:1 - 15:,
   PCPRSKTY_CF    16:1 - 16:,
   SECINC_D       17:1 - 17:,
   SECCAN_D       18:1 - 18:,
   CTRRET_B       19:1 - 19:,
   CRE_D          20:1 - 20:,
   UWY            21:1 - 21:
/joinkeys
	PER_CTR_NF ,
	PER_END_NT ,
	PER_SEC_NF,
	PER_UWY_NF
/INFILE ${ESF_FCTRGRO_STD} 1000 1 "~"
/joinkeys
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY
/JOIN UNPAIRED LEFTSIDE	
/OUTFILE ${SORT_O} 
/REFORMAT 
    LEFTSIDE : PER_CTR_NF ,PER_END_NT , PER_SEC_NF, GRPGRP3_NT, REF_QUARTER, 
    RIGHTSIDE: VRS_NF,SSD_CF,SEGTYP_CT, DIV_NT,CED_NF,UWGRP_CF,LOB_CF,SOB_CF,TOP_CF,NAT_CF,SUBNAT_CF,PCPRSKTY_CF,SECINC_D,SECCAN_D,CTRRET_B,CRE_D,UWY,
	LEFTSIDE : SEG_NF,PER_UWY_NF, BS_QUARTER_LR 
exit
EOF
SORT



NSTEP=${NJOB}_75
LIBEL="CREATE FCTRGRO from Transition file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IDF_CT}_FCTRGRO_MERGED.dat 1000 1"
SORT_O="${DFILT}/${NJOB}_75_${IDF_CT}_FCTRGRO_SORTED.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS  
        CTR_NF      1:1 -  1:,
        END_NT      2:1 -  2:,
        SEC_NF      3:1 -  3:,
        UWY_NF      24:1 - 24:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF
exit
EOF
SORT



NSTEP=${NJOB}_77
#------------------------------------------------------------------------------
LIBEL="select random first CSUE to avoid duplicates"
AWK_I=${DFILT}/${NJOB}_75_${IDF_CT}_FCTRGRO_SORTED.dat
AWK_O=${DFILT}/${NJOB}_77_${IDF_CT}_FCTRGRO_UNIQ.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="~"; OFS="~"; prev_key=""; curr_key=""; }
{


if (prev_key == "")
  { prev_key=\$1 \$2 \$3 \$24 ;
    print \$0;
  }
  else { curr_key=\$1 \$2 \$3 \$24;
         if ( curr_key != prev_key )
           { print \$0;
             prev_key = curr_key; }
        }
}
exit
EOF
AWK







NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Concatenate Lob GRPGRP3_NT + Reference quarter "
AWK_I=${DFILT}/${NJOB}_77_${IDF_CT}_FCTRGRO_UNIQ.dat
AWK_O=${ESF_FCTRGRO_TRN}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; }
{ print \$1 "~" \$2 "~" \$3 "~"  \$6 "~" \$7 "~"  \$8  "~"  \$23 \$5 "~" \$9 "~" \$10 "~" \$11 "~" \$12 "~" \$13 "~" \$14 "~" \$15 "~" \$16 "~" \$17 "~" \$18 "~" \$19 "~" \$20 "~" \$21 "~" \$24 }	 
exit
EOF
AWK



NSTEP=${NJOB}_85
#-----------------------------------------------------------------------------
LIBEL="Generate CTRGRO for with SEG_NF "
AWK_I=${DFILT}/${NJOB}_77_${IDF_CT}_FCTRGRO_UNIQ.dat
AWK_O=${ESF_FCTRGRO_SEGNF_TRN}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; }
{ print \$1 "~" \$2 "~" \$3 "~"  \$6 "~" \$7 "~"  \$8  "~"  \$23 "~" \$9 "~" \$10 "~" \$11 "~" \$12 "~" \$13 "~" \$14 "~" \$15 "~" \$16 "~" \$17 "~" \$18 "~" \$19 "~" \$20 "~" \$21 "~" \$24 }	 
exit
EOF
AWK




NSTEP=${NJOB}_86
#-----------------------------------------------------------------------------
LIBEL="Concatenate SEG_NF & BS_QUARTER_LR"
AWK_I=${DFILT}/${NJOB}_77_${IDF_CT}_FCTRGRO_UNIQ.dat
AWK_O=${ESF_FCTRGRO_FUT_TRN}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; }
{ print \$1 "~" \$2 "~" \$3 "~"  \$6 "~" \$7 "~"  \$8  "~"  \$23 \$25 "~" \$9 "~" \$10 "~" \$11 "~" \$12 "~" \$13 "~" \$14 "~" \$15 "~" \$16 "~" \$17 "~" \$18 "~" \$19 "~" \$20 "~" \$21 "~" \$24 }	 
exit
EOF
AWK


NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="CREATE FSEGEST FILE from Transition file - type T "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IDF_CT}_FSEGEST_T.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    SSD_CF      1:1 - 1:,
    ESB_CF      2:1 - 2:,
	UWY         5:1 - 5:,
    CTRTYP_CT   9:1 - 9:,
    CTRNAT_CT   10:1 - 10:,
	EGPI_CUR    15:1 - 15:,
    REF_QUARTER	16:1 - 16:,
	SEG_NF      17:1 - 17:,
	FUTURE_LR   20:1 - 20: 	
/DERIVEDFIELD CLMAMT_M "~"	
/DERIVEDFIELD AMORAT_CT "R~"
/DERIVEDFIELD SEGTYP_CT "T~"
/KEYS
	SSD_CF     ,
	SEG_NF     ,
	UWY        ,
	EGPI_CUR   ,
	CTRNAT_CT 
/OUTFILE  ${SORT_O}	
/REFORMAT 
	SSD_CF     ,
	SEG_NF     ,
	UWY        ,
	EGPI_CUR   ,
	CTRNAT_CT  ,
	CLMAMT_M   ,
	FUTURE_LR  ,
	AMORAT_CT ,
	SEGTYP_CT ,
	REF_QUARTER	
exit
EOF
SORT

NSTEP=${NJOB}_95
#-----------------------------------------------------------------------------
LIBEL="CREATE FSEGEST FILE from Transition file - type W "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IDF_CT}_FSEGEST_W.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    SSD_CF      	1:1 - 1:,
    ESB_CF      	2:1 - 2:,
	UWY         	5:1 - 5:,
    CTRTYP_CT   	9:1 - 9:,
    CTRNAT_CT   	10:1 - 10:,
	EGPI_CUR    	15:1 - 15:,
	REF_QUARTER		16:1 - 16:,
	SEG_NF      	17:1 - 17:,
	ADJUSTMENT_LR   19:1 - 19:
/KEYS
	SSD_CF     ,
	SEG_NF     ,
	UWY        ,
	EGPI_CUR   ,
	CTRNAT_CT  	
/DERIVEDFIELD CLMAMT_M "~"	
/DERIVEDFIELD AMORAT_CT "R~"
/DERIVEDFIELD SEGTYP_CT "W~"
/OUTFILE  ${SORT_O}	
/REFORMAT 
	SSD_CF     ,
	SEG_NF     ,
	UWY        ,
	EGPI_CUR   ,
	CTRNAT_CT  ,
	CLMAMT_M   ,
	ADJUSTMENT_LR  ,
	AMORAT_CT ,
	SEGTYP_CT ,
	REF_QUARTER	
exit
EOF
SORT

NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="FSEGEST: merge and sort unique "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IDF_CT}_FSEGEST_T.dat  1000 1"
SORT_I2="${DFILT}/${NJOB}_95_${IDF_CT}_FSEGEST_W.dat  1000 1"
SORT_O="${DFILT}/${NJOB}_100_${IDF_CT}_FSEGEST_TW.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	SSD_CF    	1:1 - 1:,
	SEG_NF    	2:1 - 2:,
	UWY       	3:1 - 3:,
	EGPI_CUR  	4:1 - 4:,
	CTRNAT_CT 	5:1 - 5:,
	CLMAMT_M  	6:1 - 6:,
	LR        	7:1 - 7:,
	AMORAT_CT 	8:1 - 8:,
	SEGTYP_CT 	9:1 - 9:,
	REF_QUARTER 10:1 - 10:
/KEYS
    SEGTYP_CT  ,
	SSD_CF     ,
	SEG_NF     ,
	UWY        ,
	EGPI_CUR   ,
	CTRNAT_CT  ,
	CLMAMT_M   ,
	LR         ,
	AMORAT_CT  ,
	REF_QUARTER
/SUM
/STABLE
/OUTFILE  ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="Concatenate Lob GRPGRP3_NT + Reference quarter "
AWK_I=${DFILT}/${NJOB}_100_${IDF_CT}_FSEGEST_TW.dat
AWK_O=${ESF_FSEGEST_TRN}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; }
{ print \$1 "~" \$2 \$10 "~" \$3 "~"  \$4 "~" \$5 "~"  \$6  "~"  \$7 "~" \$8 "~" \$9  }	 
exit
EOF
AWK

JOBEND