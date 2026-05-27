#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 granularity
# nom du script SHELL           : ESFD3941.cmd
# date de creation              : 04/09/2020
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : IFRS17 Granularity product management
#
#-----------------------------------------------------------------------------
# historiques des modifications
#=================================================================================================
#[001] 04/09/2020 JYP : Spira 83614 : Creation
#[002] 08/09/2020 JYP : Spira 83614 : bugfix 
#[003] 10/09/2020 JYP : Spira 83614 : add Life file ESF_PI_UPDATE_TSECIFRS 
#[004] 11/09/2020 JYP : Spira 83614 : manage product by site 
#[005] 14/09/2020 JYP : Spira 83614 : granularity bugfix
#[006] 06/01/2020 JYP : Spira 91991 : rollout I17P I17L 
#[007] 06/01/2020 JYP : Spira 91991 : rollout I17P I17L 
#[008] 10/01/2020 JYP : Spira 91991 : rollout I17P I17L 
#[009] 22/02/2021 JYP : Spira 91531 : rework for INV+date mapping 
#[010] 26/02/2021 JYP : Spira 91531 : rework for INV+date mapping 
#[011] 17/03/2021 JYP : Spira 91531 : rework for INV+date mapping : bugfix I17P I17L
#[012] 18/03/2021 JYP : Spira 94931 : rework for INV+date mapping : bugfix I17P I17L
#[013] 31/03/2021 JYP : Spira 94931 : bugfix AE Life 
#[014] 31/03/2021 JYP : Spira 94931 : bugfix AE Life 
#[015] 22/06/2021 JYP : Spira 97118 : add transition field IFRSTRA_CT 
#[016] 22/07/2021 JYP : Spira 94896 : granularity retro
#[017] 22/06/2021 JYP : Spira 97118 : bugfix transition field IFRSTRA_CT 
#[018] 28/09/2021 JYP : Spira 99157 : stop when have input with no keys 
#[019] 21/12/2021 JYP : SPIRA 101025: new output file ESF_FI17PRODUCT_CUR without TYPEINV+date 
#[020] 17/01/2021 JYP : SPIRA 101025: exclude run-off duplicate in ESF_FCTRI17PRD=ESFD0060 and ESF_FSECIFRS=ESFD3720 
#===============================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT


#======  dynamic keys by norme , for table TSECIFRS format

case "${NORME_CF}" in
	"I17G") LETTER="G" 
		KEY_IFRSSEG="GRPIFRSSEG_CT"
		KEY_INIPRO="GRPINIPRO_CF" 
		KEY_IFRSTRA="GRPIFRSTRA_CT" ;;
	"I17L") LETTER="L"
		KEY_IFRSSEG="LOCIFRSSEG_CT"
		KEY_INIPRO="LOCINIPRO_CF" 		
		KEY_IFRSTRA="LOCIFRSTRA_CT" ;;
	"I17P") LETTER="P"
		KEY_IFRSSEG="PARIFRSSEG_CT"
		KEY_INIPRO="PARINIPRO_CF" 
		KEY_IFRSTRA="PARIFRSTRA_CT" ;;		
	*) ECHO_LOG "wrong value for NORME_CF: ${NORME_CF} "
       STEPEND 10;;		
esac


case "${PARM_BATCHUSER}" in 
	"ubas") PREFIX="AS$LETTER" ;;
	"ubeu") PREFIX="EU$LETTER" ;;
	"ubam") PREFIX="AM$LETTER" ;;
	*) ECHO_LOG "wrong value for PARM_BATCHUSER : ${PARM_BATCHUSER} "
       STEPEND 20;;
esac

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT ....................: ${IDF_CT} "
ECHO_LOG "#===> CONTEXT_CT ................: ${CONTEXT_CT} "
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> PARM_CRE_D.................: $PARM_CRE_D"
ECHO_LOG "#===> PARM_CLODAT_D..............: $PARM_CLODAT_D"
ECHO_LOG "#===> PARM_ICLODAT_D.............: $PARM_ICLODAT_D"
ECHO_LOG "#===> PREFIX PRDCOD_CT ..........: $PREFIX"
ECHO_LOG "#===> KEY_IFRSSEG ...............: $KEY_IFRSSEG"
ECHO_LOG "#===> KEY_INIPRO ................: $KEY_INIPRO"
ECHO_LOG "#===> KEY_IFRSTRA ...............: $KEY_IFRSTRA"
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#===> ESF_FI17PRODUCT .............: $ESF_FI17PRODUCT "
ECHO_LOG "#===> ESF_FCTRI17PRD ..............: $ESF_FCTRI17PRD "
ECHO_LOG "#===> ESF_FSECIFRS ................: $ESF_FSECIFRS "
ECHO_LOG "#===> ESF_PI_UPDATE_TSECIFRS ......: $ESF_PI_UPDATE_TSECIFRS "
ECHO_LOG "#===> ESF_FCTRI17PRD_RET_BR  ......: $ESF_FCTRI17PRD_RET_BR "
ECHO_LOG "#===> ESF_FCTRI17PRD_RET_INI ......: $ESF_FCTRI17PRD_RET_INI "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#===> ESF_FI17PRODUCT_NEW .........: $ESF_FI17PRODUCT_NEW "
ECHO_LOG "#===> ESF_FI17PRODUCT_CUR .........: $ESF_FI17PRODUCT_CUR "
ECHO_LOG "#===> ESF_FCTRI17PRD_NEW ..........: $ESF_FCTRI17PRD_NEW  "
ECHO_LOG "#========================================================================="



NSTEP=${NJOB}_00
#-----------------------------------------------------------------------------
LIBEL="touch ESF_FI17PRODUCT_NEW and ESF_FCTRI17PRD_NEW  "
EXECKSH_MODE=P
EXECKSH "touch $ESF_FI17PRODUCT_NEW "
EXECKSH_MODE=P
EXECKSH "touch $ESF_FCTRI17PRD_NEW "
EXECKSH_MODE=P
EXECKSH "touch $ESF_FI17PRODUCT_CUR "

# temporary solution
# subject send to CAP and Kouassi: to modify ESFD3860-java and produce empty file sometime

if [ ! -f $ESF_PI_UPDATE_TSECIFRS ]
then
ESF_PI_UPDATE_TSECIFRS="$DFILP/empty.dat" 
ECHO_LOG "#===> Warning use ESF_PI_UPDATE_TSECIFRS ......: $ESF_PI_UPDATE_TSECIFRS "
fi


NSTEP=${NJOB}_02
#-----------------------------------------------------------------------------
LIBEL="exclude run-off duplicate in ESF_FCTRI17PRD=ESFD0060 and ESF_FSECIFRS=ESFD3720"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCTRI17PRD} 1000 1"   
SORT_O="${DFILT}/${NSTEP}_${IB}_FCTRI17PRD_FILTERED_${IDF_CT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
     CTR_NF       1:1 - 1: , 
     END_NT       2:1 - 2: , 
     SEC_NF       3:1 - 3: ,  
     UWY_NF       4:1 - 4: , 
     UW_NT        5:1 - 5: ,
	 ALL_COLS     1:1 - 8: ,
     CSM_CTR_NF      1:1 - 1:,
     CSM_UWY_NF      2:1 - 2:,       
     CSM_UW_NT       3:1 - 3:, 
     CSM_END_NT      4:1 - 4:,
     CSM_SEC_NF      5:1 - 5: 
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT			
/INFILE $ESF_FSECIFRS  2000 1 "~"
/joinkeys
        CSM_CTR_NF ,
        CSM_END_NT ,
        CSM_SEC_NF ,
        CSM_UWY_NF ,
        CSM_UW_NT	
/JOIN UNPAIRED LEFTSIDE	ONLY		
/OUTFILE ${SORT_O} overwrite		
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT

 
NSTEP=${NJOB}_03
#-----------------------------------------------------------------------------
LIBEL="Merge assumed and Retro FCTRI17PRD, booked and run-off, exclude empty keys"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_02_${IB}_FCTRI17PRD_FILTERED_${IDF_CT}.dat 1000 1"        
SORT_I2="${ESF_FCTRI17PRD_RET_BR} 1000 1" 
SORT_I3="${ESF_FCTRI17PRD_RET_INI} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_FCTRI17PRD_MERGED_${IDF_CT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
     CTR_NF       1:1 - 1:   , 
     END_NT       2:1 - 2:EN , 
     SEC_NF       3:1 - 3:EN ,  
     UWY_NF       4:1 - 4:   , 
     UW_NT        5:1 - 5:EN ,
     IFRSSEG_CT   6:1 - 6:   ,  
     INIPRO_CF    7:1 - 7:   ,
     IFRSTRA_CT   8:1 - 8:   	 
/KEYS   CTR_NF,
        UWY_NF,
        SEC_NF,
        END_NT,
        UW_NT
/CONDITION KEYS_EMPTY ( IFRSSEG_CT EQ "" AND INIPRO_CF EQ "" AND IFRSTRA_CT EQ "" )
/OMIT KEYS_EMPTY		
exit
EOF
SORT



NSTEP=${NJOB}_05
#---------------------------------------------------------------BEGIN SORT
LIBEL="Enriched previous CSUOE ESF_FCTRI17PRD with FI17PRODUCT.I17PRDCOD_CT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03_${IB}_FCTRI17PRD_MERGED_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NSTEP}_${IB}_FCTRI17PRD_PREVIOUS_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
     CTR_NF       1:1 - 1:   , 
     END_NT       2:1 - 2:EN , 
     SEC_NF       3:1 - 3:EN ,  
     UWY_NF       4:1 - 4:   , 
     UW_NT        5:1 - 5:EN , 
     IFRSSEG_CT   6:1 - 6:   ,  
     INIPRO_CF    7:1 - 7:   ,
     IFRSTRA_CT   8:1 - 8:   ,
     CSUOE_COLS   1:1 - 5:   ,
     I17PRDCOD_CT    1:1     -  1:  ,        
     GRPIFRSSEG_CT   2:1     -  2:  ,        
     GRPINIPRO_CF    3:1     -  3:  ,         	
     GRPIFRSTRA_CT   4:1     -  4:  ,        
     PARIFRSSEG_CT   5:1     -  5:  ,        
     PARINIPRO_CF    6:1     -  6:  ,         	
     PARIFRSTRA_CT   7:1     -  7:  ,        
     LOCIFRSSEG_CT   8:1     -  8:  ,        
     LOCINIPRO_CF    9:1     -  9:  ,         	
     LOCIFRSTRA_CT   10:1    -  10: ,         	
     BCHUSR_CF       11:1    -  11:  
/joinkeys
     IFRSSEG_CT,
     INIPRO_CF,
	 IFRSTRA_CT
/INFILE $ESF_FI17PRODUCT 1000 1 "~"
/joinkeys
     $KEY_IFRSSEG ,        
     $KEY_INIPRO ,
     $KEY_IFRSTRA	 
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:CSUOE_COLS,IFRSSEG_CT,INIPRO_CF,IFRSTRA_CT,
        rightside:I17PRDCOD_CT
exit
EOF
SORT


NSTEP=${NJOB}_06
#------------------------------------------------------------------------------
LIBEL="split previous FCTRI17PRD with product_code "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_05_${IB}_FCTRI17PRD_PREVIOUS_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NJOB}_06_${IB}_FCTRI17PRD_PREVIOUS_PRDCODE_${IDF_CT}.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
I17PRDCOD_CT 9:1 - 9:
/KEYS  I17PRDCOD_CT 
/CONDITION PRD_EMPTY I17PRDCOD_CT EQ ""
/OMIT PRD_EMPTY
exit
EOF
SORT

NSTEP=${NJOB}_07
#------------------------------------------------------------------------------
LIBEL="split previous FCTRI17PRD without product_code "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_05_${IB}_FCTRI17PRD_PREVIOUS_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NJOB}_07_${IB}_FCTRI17PRD_PREVIOUS_NOCODE_${IDF_CT}.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
I17PRDCOD_CT 9:1 - 9:
/KEYS  I17PRDCOD_CT
/CONDITION PRD_EMPTY I17PRDCOD_CT EQ ""
/INCLUDE PRD_EMPTY
exit
EOF
SORT



NSTEP=${NJOB}_08
#-----------------------------------------------------------------------------
LIBEL="previous FCTRI17PRD without product_code formatting as TSECIFRS format "
AWK_I=$DFILT/${NJOB}_07_${IB}_FCTRI17PRD_PREVIOUS_NOCODE_${IDF_CT}.dat
AWK_O=$DFILT/${NJOB}_08_${IB}_FCTRI17PRD_PREVIOUS_NOCODE_${IDF_CT}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~";
       norme="$NORME_CF";
     }
     {
		I17G_IFRSSEG=""; 
		I17G_IFRSTRA="";		
        I17G_INIPRO="";
		I17P_IFRSSEG=""; 
        I17P_INIPRO="";		
		I17P_IFRSTRA="";		
		I17L_IFRSSEG=""; 
        I17L_INIPRO="";			
		I17L_IFRSTRA="";		
		
		if ( norme == "I17G") 
		{
		    I17G_IFRSSEG=\$6; 
            I17G_INIPRO=\$7;
            I17G_IFRSTRA=\$8;					
		}
		if ( norme == "I17P") 
		{
		    I17P_IFRSSEG=\$6; 
            I17P_INIPRO=\$7;
            I17P_IFRSTRA=\$8;					
		}		
		if ( norme == "I17L") 
		{
		    I17L_IFRSSEG=\$6; 
            I17L_INIPRO=\$7;
            I17L_IFRSTRA=\$8;		
		}	
			
     print \$1 "~" \$4 "~" \$5 "~" \$2 "~" \$3 "~~~~~~~~~~~" I17G_IFRSSEG "~~" I17G_INIPRO "~~~" I17P_IFRSSEG "~~" I17P_INIPRO "~~~"  I17L_IFRSSEG "~~" I17L_INIPRO "~~~~~~~~~~" I17G_IFRSTRA "~" I17P_IFRSTRA "~" I17L_IFRSTRA  ; 
 }
exit
EOF
AWK



NSTEP=${NJOB}_10
#---------------------------------------------------------------BEGIN SORT
LIBEL="Merge Life and P_C TSECIFRS file and history of old TSECIFRS  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$ESF_FSECIFRS 2000 1"
SORT_I2="$ESF_PI_UPDATE_TSECIFRS 2000 1"
SORT_I3="$DFILT/${NJOB}_08_${IB}_FCTRI17PRD_PREVIOUS_NOCODE_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NSTEP}_${IB}_FSECIFRS_${IDF_CT}.dat 2000 1"
SORT_O2="$DFILT/${NSTEP}_${IB}_FSECIFRS_${IDF_CT}_EMPTYKEYS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        ALL_COLS    1:1 - 36:,
        CTR_NF      1:1 - 1:,
        UWY_NF      2:1 - 2:,       
        UW_NT       3:1 - 3:, 
        END_NT      4:1 - 4:,
        SEC_NF      5:1 - 5:,
	GRPIFRSSEG_CT       16:1 - 16:,
	GRPINIPRO_CF        18:1 - 18:,
	PARIFRSSEG_CT       21:1 - 21:,
	PARINIPRO_CF        23:1 - 23:,
	LOCIFRSSEG_CT       26:1 - 26:,
	LOCINIPRO_CF        28:1 - 28:,
	GRPIFRSTRA_CT       38:1 - 38:,
	PARIFRSTRA_CT       39:1 - 39:,
	LOCIFRSTRA_CT       40:1 - 40:
/CONDITION KEYS_EMPTY    ( $KEY_IFRSSEG EQ "" AND $KEY_INIPRO  EQ "" AND $KEY_IFRSTRA EQ "" )
/CONDITION KEYS_NOTEMPTY ( $KEY_IFRSSEG != "" OR $KEY_INIPRO  != "" OR $KEY_IFRSTRA != "" )
/OUTFILE ${SORT_O}
/INCLUDE KEYS_NOTEMPTY
/OUTFILE ${SORT_O2}
/INCLUDE KEYS_EMPTY
/KEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT



NSTEP=${NJOB}_11
#---------------------------------------------------------------
LIBEL="check to avoid all keys empty "
nbwrong=`wc -l  $DFILT/${NJOB}_10_${IB}_FSECIFRS_${IDF_CT}_EMPTYKEYS.dat | cut -d" " -f1  `

EXECKSH_MODE=P
ECHO_LOG "CHECK : $nbwrong keys found with empty keys "
if [ $nbwrong -ne 0 ]
then
   ECHO_LOG "ERROR : $nbwrong keys found with empty keys "
   #STEPEND 2
fi



NSTEP=${NJOB}_12
#---------------------------------------------------------------BEGIN SORT
LIBEL="check new TSECIFRS CSUOE NOT in the previous run "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_10_${IB}_FSECIFRS_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NSTEP}_${IB}_FSECIFRS_NEW_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        ALL_COLS            1:1 - 40:,
        CTR_NF              1:1 - 1:,
        UWY_NF              2:1 - 2:,       
        UW_NT               3:1 - 3:, 
        END_NT              4:1 - 4:,
        SEC_NF              5:1 - 5:,
        GRPIFRSSEG_CT       16:1 - 16:,
        GRPINIPRO_CF        18:1 - 18:,
        PARIFRSSEG_CT       21:1 - 21:,
        PARINIPRO_CF        23:1 - 23:,	
        LOCIFRSSEG_CT       26:1 - 26:,
        LOCINIPRO_CF        28:1 - 28:,	
        GRPIFRSTRA_CT	    38:1 - 38:, 
        PARIFRSTRA_CT	    39:1 - 39:,  
        LOCIFRSTRA_CT	    40:1 - 40:,  		
        PREV_CTR_NF         1:1 - 1:, 
        PREV_END_NT         2:1 - 2:, 
        PREV_SEC_NF         3:1 - 3:,  
        PREV_UWY_NF         4:1 - 4:, 
        PREV_UW_NT          5:1 - 5: ,
        PREV_GRPIFRSSEG_CT  6:1 - 6:,
        PREV_GRPINIPRO_CF   7:1 - 7:,
        PREV_GRPIFRSTRA_CT  8:1 - 8:,
        PREV_PARIFRSSEG_CT  6:1 - 6:,
        PREV_PARINIPRO_CF   7:1 - 7:,
        PREV_PARIFRSTRA_CT  8:1 - 8:,
        PREV_LOCIFRSSEG_CT  6:1 - 6:,
        PREV_LOCINIPRO_CF   7:1 - 7:,
        PREV_LOCIFRSTRA_CT  8:1 - 8: 		
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        $KEY_IFRSSEG ,
        $KEY_INIPRO	,
        $KEY_IFRSTRA			
/INFILE $DFILT/${NJOB}_06_${IB}_FCTRI17PRD_PREVIOUS_PRDCODE_${IDF_CT}.dat  2000 1 "~"
/joinkeys
        PREV_CTR_NF ,
        PREV_END_NT ,
        PREV_SEC_NF ,
        PREV_UWY_NF ,
        PREV_UW_NT ,
        PREV_$KEY_IFRSSEG ,
        PREV_$KEY_INIPRO,		
        PREV_$KEY_IFRSTRA		
/JOIN UNPAIRED LEFTSIDE	ONLY		
/OUTFILE ${SORT_O} overwrite		
/REFORMAT LEFTSIDE:ALL_COLS

exit
EOF
SORT



NSTEP=${NJOB}_15
#---------------------------------------------------------------BEGIN SORT
LIBEL="Complete existing product id into NEW TSECIFRS "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_12_${IB}_FSECIFRS_NEW_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NSTEP}_${IB}_FSECIFRS_NEW_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        ALL_COLS    1:1 - 40:,
        CTR_NF      1:1 - 1:,
        UWY_NF      2:1 - 2:,       
        UW_NT       3:1 - 3:, 
        END_NT      4:1 - 4:,
        SEC_NF      5:1 - 5:,
        PRD_GRPIFRSSEG_CT   16:1 - 16:,
        PRD_GRPINIPRO_CF    18:1 - 18:,
        PRD_PARIFRSSEG_CT   21:1 - 21:,
        PRD_PARINIPRO_CF    23:1 - 23:,	
        PRD_LOCIFRSSEG_CT   26:1 - 26:,
        PRD_LOCINIPRO_CF    28:1 - 28:,	
        PRD_GRPIFRSTRA_CT   38:1 - 38:,	
		PRD_PARIFRSTRA_CT   39:1 - 39:,	
		PRD_LOCIFRSTRA_CT   40:1 - 40:,			
        I17PRDCOD_CT    1:1	 -  1:  ,        
        GRPIFRSSEG_CT   2:1	 -  2:  ,        
        GRPINIPRO_CF    3:1     -  3:  ,         	
        GRPIFRSTRA_CT   4:1     -  4:  ,        
        PARIFRSSEG_CT   5:1     -  5:  ,        
        PARINIPRO_CF    6:1     -  6:  ,         	
        PARIFRSTRA_CT   7:1     -  7:  ,        
        LOCIFRSSEG_CT   8:1     -  8:  ,        
        LOCINIPRO_CF    9:1     -  9:  ,         	
        LOCIFRSTRA_CT   10:1    -  10: ,         	
        BCHUSR_CF       11:1    -  11:          				
/joinkeys
     PRD_$KEY_IFRSSEG    ,
     PRD_$KEY_INIPRO     ,
	 PRD_$KEY_IFRSTRA
/INFILE $ESF_FI17PRODUCT 1000 1 "~"
/joinkeys
     $KEY_IFRSSEG ,
     $KEY_INIPRO ,
	 $KEY_IFRSTRA
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_COLS,
        rightside:I17PRDCOD_CT
exit
EOF
SORT





NSTEP=${NJOB}_18
#-----------------------------------------------------------------------------
LIBEL="Get max PRODUCT ID in $ESF_FI17PRODUCT "
EXECKSH_MODE=P
EXECKSH "export MAX_PRDCOD=`cut -d~ -f1 $ESF_FI17PRODUCT | cut -c4-10 | sort | tail -1 ` "
ECHO_LOG "MAX_PRDCOD=$MAX_PRDCOD "



NSTEP=${NJOB}_20
#---------------------------------------------------------------BEGIN SORT
LIBEL="PREPARE new records for FCTRI17PRD and FI17PRODUCT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_15_${IB}_FSECIFRS_NEW_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NSTEP}_${IB}_FSECIFRS_NEW_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
     ALL_COLS            1:1 -  40:,
     CTR_NF              1:1 - 1:,
     UWY_NF              2:1 - 2:,       
     UW_NT               3:1 - 3:, 
     END_NT              4:1 - 4:,
     SEC_NF              5:1 - 5:,
     GRPIFRSSEG_CT       16:1 - 16:,
     GRPINIPRO_CF        18:1 - 18:,
     GRPIFRSTRA_CT       38:1 - 38:,
     PARIFRSSEG_CT       21:1 - 21:,
     PARINIPRO_CF        23:1 - 23:,
     LOCIFRSSEG_CT       26:1 - 26:,
     LOCINIPRO_CF        28:1 - 28:,
     LOCIFRSTRA_CT       40:1 - 40:,
     PARIFRSTRA_CT       39:1 - 39:,
     PRDCOD_CT           41:1 - 41:
/KEYS  
     $KEY_IFRSSEG ,
     $KEY_INIPRO,
	 $KEY_IFRSTRA
/DERIVEDFIELD MAX_PRDCOD "${MAX_PRDCOD}~"
/DERIVEDFIELD PREFIX "${PREFIX}"
/OUTFILE ${SORT_O} overwrite	
/REFORMAT           
     CTR_NF             ,   
     END_NT             , 
     SEC_NF             , 
     UWY_NF             , 
     UW_NT              , 
     GRPIFRSSEG_CT      , 
     GRPINIPRO_CF       , 
     GRPIFRSTRA_CT      , 
     PARIFRSSEG_CT      , 
     PARINIPRO_CF       ,
     PARIFRSTRA_CT      , 	 
     LOCIFRSSEG_CT      , 
     LOCINIPRO_CF       , 
     LOCIFRSTRA_CT      , 
     PRDCOD_CT          ,
     MAX_PRDCOD	,
     PREFIX	 
exit
EOF
SORT


NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="Generate new product code when it is empty "
AWK_I=$DFILT/${NJOB}_20_${IB}_FSECIFRS_NEW_${IDF_CT}.dat
AWK_O=$DFILT/${NJOB}_25_${IB}_FSECIFRS_NEW_${IDF_CT}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~";
       new_id = 0;
	   prev_key = "";
	   new_key = "";
	   flag = "";
         }
     {
	 
	  if ( length( \$15 ) > 0 ) # prodcod exists, reuse it
	  {
	    product= \$15 ;
		flag="existed";
        print \$1 "~" \$2 "~" \$3 "~" \$4 "~" \$5 "~" \$6 "~" \$7 "~" \$8 "~" \$9 "~" \$10 "~" \$11 "~" \$12 "~" \$13 "~" \$14 "~" product "~" flag  ;		
	  }
	  else  # generate a new ID
	  {
	    flag= "new";
		if ( substr(\$17,3,1) == "G") 
			new_key=sprintf("%s~%s~%s",\$6,\$7,\$8);

		if ( substr(\$17,3,1) == "P") 
			new_key=sprintf("%s~%s~%s",\$9,\$10,\$11);

		if ( substr(\$17,3,1) == "L") 
			new_key=sprintf("%s~%s~%s",\$12,\$13,\$14);			
			
	    if ( new_id  == 0 && \$16 == "" ) 
		  new_id = 0;

	    if ( new_id  == 0 && \$16 != "" ) # new_id = max+1
		  new_id = \$16 ;

		if ( prev_key != new_key )
        {		
		new_id = new_id + 1;
		prev_key = new_key ;
        }
		
	    product=sprintf("%s%07d",\$17 ,new_id ); 
		
		if ( new_id > 0 )
        print \$1 "~" \$2 "~" \$3 "~" \$4 "~" \$5 "~" \$6 "~" \$7 "~" \$8 "~" \$9 "~" \$10 "~" \$11 "~" \$12 "~" \$13 "~" \$14 "~" product "~" flag  ;

      }
	  

     }
exit
EOF
AWK


NSTEP=${NJOB}_30
#---------------------------------------------------------------BEGIN SORT
LIBEL="New product codes list, adding user field "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_25_${IB}_FSECIFRS_NEW_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NJOB}_30_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
     CTR_NF              1:1 - 1:,
     END_NT              2:1 - 2:,
     SEC_NF              3:1 - 3:,
     UWY_NF              4:1 - 4:,       
     UW_NT               5:1 - 5:, 
     GRPIFRSSEG_CT       6:1 - 6:,
     GRPINIPRO_CF        7:1 - 7:,
     GRPIFRSTRA_CT       8:1 - 8:,
     PARIFRSSEG_CT       9:1 - 9:,
     PARINIPRO_CF        10:1 - 10:,
     PARIFRSTRA_CT       11:1 - 11:,
     LOCIFRSSEG_CT       12:1 - 12:,
     LOCINIPRO_CF        13:1 - 13:,
     LOCIFRSTRA_CT       14:1 - 14:, 
     PRDCOD_CT	         15:1 - 15:,
     FLAG                16:1 - 16: 
/CONDITION COND_FLAG (FLAG = "new")	 
/DERIVEDFIELD USR_FIELD "${PARM_BATCHUSER}"   	 
/KEYS   PRDCOD_CT	 
/OUTFILE ${SORT_O} overwrite	
/INCLUDE COND_FLAG
/REFORMAT 
     PRDCOD_CT           ,          
     GRPIFRSSEG_CT      , 
     GRPINIPRO_CF       , 
     GRPIFRSTRA_CT      , 
     PARIFRSSEG_CT      , 
     PARINIPRO_CF       ,
     PARIFRSTRA_CT      , 	 
     LOCIFRSSEG_CT      , 
     LOCINIPRO_CF       , 
     LOCIFRSTRA_CT      ,
     USR_FIELD	 
exit
EOF
SORT



NSTEP=${NJOB}_31
#---------------------------------------------------------------BEGIN SORT
LIBEL="Check no existing keys before saving new product codes"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_30_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NJOB}_31_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
     GRPIFRSSEG_CT       2:1    -  2:  ,
     GRPINIPRO_CF        3:1    -  3:  ,
	 GRPIFRSTRA_CT       4:1    -  4:  ,
     PARIFRSSEG_CT       5:1    -  5:  ,
     PARINIPRO_CF        6:1    -  6:  ,
     PARIFRSTRA_CT       7:1    -  7:  ,        
     LOCIFRSSEG_CT       8:1    -  8:  ,
     LOCINIPRO_CF        9:1    -  9:  ,
     LOCIFRSTRA_CT       10:1   -  10: ,         	
     PRD_GRPIFRSSEG_CT   2:1	-  2:  ,        
     PRD_GRPINIPRO_CF    3:1    -  3:  ,         	
     PRD_GRPIFRSTRA_CT   4:1    -  4:  ,        
     PRD_PARIFRSSEG_CT   5:1    -  5:  ,        
     PRD_PARINIPRO_CF    6:1    -  6:  ,         	
     PRD_PARIFRSTRA_CT   7:1    -  7:  ,        
     PRD_LOCIFRSSEG_CT   8:1    -  8:  ,        
     PRD_LOCINIPRO_CF    9:1    -  9:  ,         	
     PRD_LOCIFRSTRA_CT   10:1   -  10: ,         	
     PRD_BCHUSR_CF       11:1   -  11:	 
/joinkeys
     $KEY_IFRSSEG ,
     $KEY_INIPRO ,
	 $KEY_IFRSTRA
/INFILE $ESF_FI17PRODUCT 2000 1 "~"
/joinkeys
     PRD_${KEY_IFRSSEG} ,
     PRD_${KEY_INIPRO} ,
	 PRD_${KEY_IFRSTRA}
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:${KEY_IFRSSEG},${KEY_INIPRO},${KEY_IFRSTRA}
exit
EOF
SORT

# stop when existings keys found
found=`wc -l $DFILT/${NJOB}_31_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat | cut -d" " -f1  `
ECHO_LOG "found=$found existing keys found "

if [ $found -ne 0 ]
then
   ECHO_LOG "ERROR new CSUOE from ESFD3720 produced existings key into best..TI17PRODUCT "
   ECHO_LOG "check ESFD3720 wrong keys into $DFILT/${NJOB}_31_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat "
   STEPEND 1
fi




NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="save and UPDATE final file ESF_FI17PRODUCT_NEW "
cp $ESF_FI17PRODUCT_NEW $DSAVE/svg_${IB}_ESFD3940_${IDF_CT}_FI17PRODUCT.dat 
cp $ESF_FI17PRODUCT $DSAVE/svg_${IB}_ESFD3940_${IDF_CT}_ESFD0060_FI17PRODUCT.dat
sort -u $DFILT/${NJOB}_30_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat   > $DFILT/${NJOB}_35_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat

#--- check duplicate
sort -u $DFILT/${NJOB}_35_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat  | cut -d"~" -f1 | sort -u > $DFILT/${NJOB}_35_${IB}_FI17PRODUCT_UNIQ_${IDF_CT}.dat
nbtotal=`wc -l $DFILT/${NJOB}_35_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat | cut -d" " -f1 `
nbkeys=`wc -l  $DFILT/${NJOB}_35_${IB}_FI17PRODUCT_UNIQ_${IDF_CT}.dat | cut -d" " -f1 `
duplicate=`expr ${nbtotal} - ${nbkeys}`
EXECKSH_MODE=P
EXECKSH "echo CHECK_DUPLICATE : $duplicate duplicate , ${nbtotal} - ${nbkeys} "

if [ $duplicate -ne 0 ]
then
   ECHO_LOG "ERROR : $duplicate duplicate keys found into $DFILT/${NJOB}_35_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat  "
   diff $DFILT/${NJOB}_35_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat $DFILT/${NJOB}_35_${IB}_FI17PRODUCT_UNIQ_${IDF_CT}.dat > $DFILT/${NJOB}_35_${IB}_FI17PRODUCT_DUPLICATES_${IDF_CT}.dat
   STEPEND 30
fi


SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$ESF_FI17PRODUCT 2000 1"
SORT_I2="$DFILT/${NJOB}_35_${IB}_FI17PRODUCT_NEW_${IDF_CT}.dat 2000 1"
SORT_O="$ESF_FI17PRODUCT_NEW 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        PRDCOD_CT    1:1 - 1:
/KEYS
        PRDCOD_CT
exit
EOF
SORT

# save same file without TYPINV + date 
EXECKSH_MODE=P
EXECKSH "cp $ESF_FI17PRODUCT_NEW $ESF_FI17PRODUCT_CUR "



NSTEP=${NJOB}_40
#---------------------------------------------------------------BEGIN SORT
LIBEL="New contract links list  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_25_${IB}_FSECIFRS_NEW_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NJOB}_40_${IB}_FCTRI17PRD_NEW_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
     CTR_NF              1:1 - 1:,
     END_NT              2:1 - 2:,
     SEC_NF              3:1 - 3:,
     UWY_NF              4:1 - 4:,       
     UW_NT               5:1 - 5:, 
     GRPIFRSSEG_CT       6:1 - 6:,
     GRPINIPRO_CF        7:1 - 7:,
     GRPIFRSTRA_CT       8:1 - 8:,
     PARIFRSSEG_CT       9:1 - 9:,
     PARINIPRO_CF        10:1 - 10:,
     PARIFRSTRA_CT       11:1 - 11:,
     LOCIFRSSEG_CT       12:1 - 12:,
     LOCINIPRO_CF        13:1 - 13:,
     LOCIFRSTRA_CT       14:1 - 14:, 
     PRDCOD_CT	         15:1 - 15:  	 
/KEYS   
     CTR_NF              ,
     END_NT              ,
     SEC_NF              ,
     UWY_NF              ,       
     UW_NT                	 
/OUTFILE ${SORT_O} overwrite	
/REFORMAT 
     CTR_NF              ,
     END_NT              ,
     SEC_NF              ,
     UWY_NF              ,       
     UW_NT               ,	
     $KEY_IFRSSEG        ,
     $KEY_INIPRO         ,
     PRDCOD_CT          
exit
EOF
SORT



NSTEP=${NJOB}_50
#---------------------------------------------------------------
LIBEL="remove new CSUOE+keys from previous run , before replacing them "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_05_${IB}_FCTRI17PRD_PREVIOUS_${IDF_CT}.dat 2000 1"
SORT_O="$DFILT/${NJOB}_50_${IB}_FCTRI17PRD_PREVIOUS_${IDF_CT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        PREV_CTR_NF         1:1 - 1:, 
        PREV_END_NT         2:1 - 2:, 
        PREV_SEC_NF         3:1 - 3:,  
        PREV_UWY_NF         4:1 - 4:, 
        PREV_UW_NT          5:1 - 5:,
        PREV_IFRSSEG_CT     6:1 - 6:,
        PREV_INIPRO_CF      7:1 - 7:,
        PREV_FRSTRA_CT		8:1 - 8:,
		PREV_PRDCOD_CT      9:1 - 9:,
        ALL_COLS            1:1 - 9:,
        CTR_NF              1:1 - 1:,
        END_NT              2:1 - 2:,
        SEC_NF              3:1 - 3:, 
        UWY_NF              4:1 - 4:,       
        UW_NT               5:1 - 5:, 
        IFRSSEG_CT          6:1 - 6:,
        INIPRO_CF           7:1 - 7:		
/joinkeys
        PREV_CTR_NF ,
        PREV_END_NT ,
        PREV_SEC_NF ,
        PREV_UWY_NF ,
        PREV_UW_NT 
/INFILE $DFILT/${NJOB}_40_${IB}_FCTRI17PRD_NEW_${IDF_CT}.dat  2000 1 "~"
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/JOIN UNPAIRED LEFTSIDE	ONLY		
/OUTFILE ${SORT_O} overwrite		
/REFORMAT LEFTSIDE:PREV_CTR_NF,PREV_END_NT,PREV_SEC_NF,PREV_UWY_NF,PREV_UW_NT,PREV_IFRSSEG_CT,PREV_INIPRO_CF,PREV_PRDCOD_CT 

exit
EOF
SORT



NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="MERGE previous and new contact product links "

# save for maintenance
cp $ESF_FCTRI17PRD_NEW $DSAVE/svg_${IB}_ESFD3940_${IDF_CT}_FCTRI17PRD.dat

SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_50_${IB}_FCTRI17PRD_PREVIOUS_${IDF_CT}.dat  2000 1"
SORT_I2="$DFILT/${NJOB}_40_${IB}_FCTRI17PRD_NEW_${IDF_CT}.dat 2000 1"
SORT_O="$ESF_FCTRI17PRD_NEW 2000 1 overwrite"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        ALL_COLS    1:1 - 36:,
        CTR_NF      1:1 - 1:,
        UWY_NF      2:1 - 2:,       
        UW_NT       3:1 - 3:, 
        END_NT      4:1 - 4:,
        SEC_NF      5:1 - 5:
/KEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT




NSTEP=${NJOB}_70
#---------------------------------------------------------------
LIBEL="check to avoid duplicate into ESF_FCTRI17PRD_NEW = $ESF_FCTRI17PRD_NEW "
cut -d"~" -f1,2,3,4,5 $ESF_FCTRI17PRD_NEW  | sort          > $DFILT/${NJOB}_70_${IB}_ESF_FCTRI17PRD_ALL_${IDF_CT}.dat
cut -d"~" -f1,2,3,4,5 $ESF_FCTRI17PRD_NEW  | sort -u > $DFILT/${NJOB}_70_${IB}_ESF_FCTRI17PRD_UNIQ_${IDF_CT}.dat
nbtotal=`wc -l $DFILT/${NJOB}_70_${IB}_ESF_FCTRI17PRD_ALL_${IDF_CT}.dat  | cut -d" " -f1 `
nbkeys=`wc -l  $DFILT/${NJOB}_70_${IB}_ESF_FCTRI17PRD_UNIQ_${IDF_CT}.dat | cut -d" " -f1  `
duplicate=`expr ${nbtotal} - ${nbkeys}`
EXECKSH_MODE=P
EXECKSH "echo FINAL_CHECK: $duplicate duplicate , ${nbtotal} - ${nbkeys} "

if [ $duplicate -ne 0 ]
then
   ECHO_LOG "ERROR : $duplicate duplicate keys found into ESF_FCTRI17PRD_NEW=$ESF_FCTRI17PRD_NEW "
   diff $DFILT/${NJOB}_70_${IB}_ESF_FCTRI17PRD_ALL_${IDF_CT}.dat  $DFILT/${NJOB}_70_${IB}_ESF_FCTRI17PRD_UNIQ_${IDF_CT}.dat | grep "~"  > $DFILT/${NJOB}_70_${IB}_ESF_FCTRI17PRD_DUPLICATES_${IDF_CT}.dat
   STEPEND 11
fi


nb_new_ctrlink=`wc -l $DFILT/${NJOB}_40_${IB}_FCTRI17PRD_NEW_${IDF_CT}.dat | cut -d" " -f1 `
ECHO_LOG "$nb_new_ctrlink records added into ESF_FCTRI17PRD_NEW "


JOBEND

                     
