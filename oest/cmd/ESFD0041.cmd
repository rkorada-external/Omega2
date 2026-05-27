#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESFD0041.cmd
# date de creation              : 24/01/2022
# auteur                        : JYP - PERSEE
# references des specifications :
#-----------------------------------------------------------------------------
# description : Granularity product codes 
#
#-----------------------------------------------------------------------------
# historiques des modifications
#=================================================================================================
#[001] 24/01/2022 JYP : Spira 101782 : Creation 
#[002] 27/01/2022 JYP : Spira 101782 : generate product codes  and contract links 
#[003] 27/01/2022 JYP : Spira 101782 : manage option BOOKED_OPT
#[004] 31/01/2022 JYP : Spira 101782 : clean empty product code into contract links file
#[005] 09/06/2022 JYP : SPIRA 104771 : IFRS17 Product defaulting
#===============================================================================================
#set -x

BOOKED_OPT="$1"

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT


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
ECHO_LOG "#===> PARM_ICLODAT_D.............: $PARM_ICLODAT_D"
ECHO_LOG "#===> BOOKED_OPT ................: $BOOKED_OPT"




#--------------------------------------------------------------------------- 
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="load mapping, specific chain for all NORME "
ISQL_BASE=BEST
ISQL_O=${DFILT}/${NSTEP}_${IB}_ESFD0040.dat
ISQL_QRY="select 'export ' +  PERMFIL_CT + '=\"' + pathpattrn_ll + '\"' from BEST..TI17PERMFIL where IDF_CT = 'ESFD0040' "
ECHO_LOG "ISQL_QRY = [ $ISQL_QRY ] "
ISQL

grep export ${DFILT}/${NSTEP}_${IB}_ESFD0040.dat  > ${DFILT}/${ENV_PREFIX}_ESFD0040_${IB}_ESFD0040_PERMFIL.dat
. ${DFILT}/${ENV_PREFIX}_ESFD0040_${IB}_ESFD0040_PERMFIL.dat

ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#===> ESF_FCTRI17PRD_AF_PREV .....: $ESF_FCTRI17PRD_AF_PREV  "
ECHO_LOG "#===> ESF_FCTRI17PRD_RET_PREV.....: $ESF_FCTRI17PRD_RET_PREV "
ECHO_LOG "#===> ESF_FI17PRODUCT_PREV    ....: $ESF_FI17PRODUCT_PREV    "
ECHO_LOG "#===> ESF_FCTRI17PRD_NEW      ....: $ESF_FCTRI17PRD_NEW      "
ECHO_LOG "#===> ESF_FI17PRODUCT_NEW     ....: $ESF_FI17PRODUCT_NEW     "
ECHO_LOG "#===> ESF_FCTRI17PRD_DEFAULT  ....: $ESF_FCTRI17PRD_DEFAULT     "
ECHO_LOG "#========================================================================="




#------ check user is OK
case "${DEFAULT_SQL_LOGIN}" in
        "ubas") PREFIX="AS" ;;
        "ubeu") PREFIX="EU" ;;
        "ubam") PREFIX="AM" ;;
        *) ECHO_LOG "wrong value for DEFAULT_SQL_LOGIN : ${DEFAULT_SQL_LOGIN} , should be ubxx "
       STEPEND 20;;
esac
ECHO_LOG "#===> site/DEFAULT_SQL_LOGIN   ....: $DEFAULT_SQL_LOGIN  "
ECHO_LOG "#===> PREFIX              .........: $PREFIX  "




NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="extract TI17PRODUCT table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FI17PRODUCT_PREV}
BCP_QRY="execute BEST..PsTI17PRODUCT_02  '${DEFAULT_SQL_LOGIN}' "
BCP

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="extract TSECIFRS table TRT/FAC"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FCTRI17PRD_AF_PREV}
BCP_QRY="execute BEST..PsFetchTSECIFRS_GRN '${DEFAULT_SQL_LOGIN}'  "
BCP

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="extract TRETIFRS table Retro"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FCTRI17PRD_RET_PREV}
BCP_QRY="execute BEST..PsFetchTRETIFRS_GRN '${DEFAULT_SQL_LOGIN}'  "
BCP


NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="Get max PRODUCT ID in $ESF_FI17PRODUCT_PREV "
EXECKSH_MODE=P
EXECKSH "export MAX_PRDCOD=`cut -d~ -f1 $ESF_FI17PRODUCT_PREV | cut -c3-10  | grep -v ACC | grep -v RET | sort | tail -1 ` "
ECHO_LOG "MAX_PRDCOD=$MAX_PRDCOD "



NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="PREPARATION : merge inputs files , add prefix  "
#------------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCTRI17PRD_AF_PREV} 2000 1"
SORT_I2="${ESF_FCTRI17PRD_RET_PREV} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCTRI17PRD_ALL_PREV.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
     CTR_NF                 1:1 - 1:   , 
     END_NT                 2:1 - 2:EN , 
     SEC_NF                 3:1 - 3:EN ,  
     UWY_NF                 4:1 - 4:   , 
     UW_NT                  5:1 - 5:EN ,
     PREV_GRPIFRSSEG_CT     6:1 - 6:   ,         
     PREV_GRPINIPRO_CF      7:1 - 7:   ,         
     PREV_GRPIFRSTRA_CT     8:1 - 8:   ,       
     PREV_PARIFRSSEG_CT     9:1 - 9:   ,      
     PREV_PARINIPRO_CF      10:1 - 10: ,        
     PREV_PARIFRSTRA_CT     11:1 - 11: ,        
     PREV_LOCIFRSSEG_CT     12:1 - 12: ,        
     PREV_LOCINIPRO_CF      13:1 - 13: ,         
     PREV_LOCIFRSTRA_CT     14:1 - 14: ,   
     PREV_GRPINISTS_CT      15:1 - 15: ,
     PREV_PARINISTS_CT      16:1 - 16: ,
     PREV_LOCINISTS_CT      17:1 - 17: ,
     PREV_USER_SITE         18:1 - 18: ,		
     PREV_CTR_TYP           19:1 - 19: ,
	 PREV_LIFE_CF           20:1 - 20: ,
	 PREV_PARM1             21:1 - 21: ,
	 PREV_PARM2             22:1 - 22: ,
     PREV_ALL_FIELDS        1:1  - 22:	 
/KEYS  
     PREV_GRPIFRSSEG_CT  ,
     PREV_GRPINIPRO_CF   ,
     PREV_GRPIFRSTRA_CT  ,
     PREV_PARIFRSSEG_CT  ,
     PREV_PARINIPRO_CF   ,
     PREV_PARIFRSTRA_CT  ,
     PREV_LOCIFRSSEG_CT  ,
     PREV_LOCINIPRO_CF   ,
     PREV_LOCIFRSTRA_CT  
/DERIVEDFIELD MAX_PRDCOD "${MAX_PRDCOD}~"
/DERIVEDFIELD PREFIX "${PREFIX}"
/OUTFILE ${SORT_O} overwrite	
/REFORMAT           
     PREV_ALL_FIELDS,
     MAX_PRDCOD,
     PREFIX	 
exit
EOF
SORT



NSTEP=${NJOB}_55
#-----------------------------------------------------------------------------
LIBEL="defaulting attributes"
AWK_I=${DFILT}/${NJOB}_50_${IB}_FCTRI17PRD_ALL_PREV.dat
AWK_O=${DFILT}/${NJOB}_55_${IB}_FCTRI17PRD_ALL_PREV.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; }
     {
	    UPD_FLAG="";
        if ( \$19 == "R" )
		{ AR="RET";
		  inipro="8";
	    }
		else  
		{ AR="ACC";
 	      inipro="9";
        }

        if ( \$20 == "1" )
		{ LIFEPC="SGL";
		  SUF="000";
	    }
		else  
		{ LIFEPC="PC";
		  SUF="0000";
		}
 
	    if ( \$6 == "" ) 		
	         { grpifrsseg=sprintf("%s%s%s",LIFEPC,AR,SUF); UPD_FLAG=sprintf("%s%s",UPD_FLAG,"1"); }
		else grpifrsseg=\$6;

	    if ( \$9 == "" && \$21 == "1" ) 		
	         { parifrsseg=sprintf("%s%s%s",LIFEPC,AR,SUF); UPD_FLAG=sprintf("%s%s",UPD_FLAG,"2"); }
		else parifrsseg=\$9;

	    if ( \$12 == "" && \$22 == "1" ) 		
	         { locifrsseg=sprintf("%s%s%s",LIFEPC,AR,SUF); UPD_FLAG=sprintf("%s%s",UPD_FLAG,"3"); }
		else locifrsseg=\$12;

	    if ( \$7 == "" ) 		
	         { grpinipro=inipro; UPD_FLAG=sprintf("%s%s",UPD_FLAG,"4"); }
		else grpinipro=\$7;

	    if ( \$10 == "" && \$21 == "1" ) 		
	         { parinipro=inipro; UPD_FLAG=sprintf("%s%s",UPD_FLAG,"5"); }
		else parinipro=\$10;

	    if ( \$13 == "" && \$22 == "1" ) 		
	         { locinipro=inipro; UPD_FLAG=sprintf("%s%s",UPD_FLAG,"6"); }
		else locinipro=\$13;
		
	    if ( \$8 == "" && \$4 <= 2021 ) 		
	         { grpifrstra="9"; UPD_FLAG=sprintf("%s%s",UPD_FLAG,"7"); }
		else grpifrstra=\$8;
		
	    if ( \$11 == "" && \$4 <= 2021 && \$21 == "1" ) 		
	         { parifrstra="9"; UPD_FLAG=sprintf("%s%s",UPD_FLAG,"8"); }
		else parifrstra=\$11;		

	    if ( \$14 == "" && \$4 <= 2021 && \$22 == "1" ) 		
	         { locifrstra="9"; UPD_FLAG=sprintf("%s%s",UPD_FLAG,"9"); }
		else locifrstra=\$14;		
		
        print \$1 "~" \$2 "~" \$3 "~" \$4 "~" \$5 "~" grpifrsseg "~" grpinipro "~" grpifrstra "~" parifrsseg "~" parinipro "~" parifrstra "~" locifrsseg "~" locinipro "~" locifrstra "~" \$15 "~" \$16 "~" \$17 "~" \$18 "~" \$19 "~" \$23 "~" \$24  "~" UPD_FLAG ; 

     }
exit
EOF
AWK

NSTEP=${NJOB}_57
#------------------------------------------------------------------------------
LIBEL="LOG data updated with default values  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_FCTRI17PRD_ALL_PREV.dat 2000 1"
SORT_O="${ESF_FCTRI17PRD_DEFAULT} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
     UPD_FLAG           22:1 - 22:
/KEYS UPD_FLAG
/CONDITION UPD_FLAG_NOT_EMPTY UPD_FLAG != ""
/OUTFILE ${SORT_O}
/INCLUDE UPD_FLAG_NOT_EMPTY
exit
EOF
SORT



NSTEP=${NJOB}_60
#-------------------------------------------------------------
LIBEL="Enriched previous CSUOE ESF_FCTRI17PRD with FI17PRODUCT.I17PRDCOD_CT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_FCTRI17PRD_ALL_PREV.dat 2000 1"
SORT_O="$DFILT/${NSTEP}_${IB}_FCTRI17PRD_ALL_PREV_PRDCODE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
     ALL_COLS               1:1 - 21:  ,	 
     PREV_GRPIFRSSEG_CT     6:1 - 6:   ,         
     PREV_GRPINIPRO_CF      7:1 - 7:   ,         
     PREV_GRPIFRSTRA_CT     8:1 - 8:   ,       
     PREV_PARIFRSSEG_CT     9:1 - 9:   ,      
     PREV_PARINIPRO_CF      10:1 - 10: ,        
     PREV_PARIFRSTRA_CT     11:1 - 11: ,        
     PREV_LOCIFRSSEG_CT     12:1 - 12: ,        
     PREV_LOCINIPRO_CF      13:1 - 13: ,         
     PREV_LOCIFRSTRA_CT     14:1 - 14: ,    
     PREV_GRPINISTS_CT      15:1 - 15: ,
     PREV_PARINISTS_CT      16:1 - 16: ,
     PREV_LOCINISTS_CT      17:1 - 17: ,
     PREV_USER_SITE         18:1 - 18: ,		
     PREV_CTR_TYP           19:1 - 19: ,	 
     I17PRDCOD_CT           1:1  -  1: ,        
     GRPIFRSSEG_CT          2:1  -  2: ,        
     GRPINIPRO_CF           3:1  -  3: ,         	
     GRPIFRSTRA_CT          4:1  -  4: ,        
     PARIFRSSEG_CT          5:1  -  5: ,        
     PARINIPRO_CF           6:1  -  6: ,         	
     PARIFRSTRA_CT          7:1  -  7: ,        
     LOCIFRSSEG_CT          8:1  -  8: ,        
     LOCINIPRO_CF           9:1  -  9: ,         	
     LOCIFRSTRA_CT          10:1 -  10:,         	
     BCHUSR_CF              11:1 -  11:  
/joinkeys
     PREV_GRPIFRSSEG_CT  ,
     PREV_GRPINIPRO_CF   ,
     PREV_GRPIFRSTRA_CT  ,
     PREV_PARIFRSSEG_CT  ,
     PREV_PARINIPRO_CF   ,
     PREV_PARIFRSTRA_CT  ,
     PREV_LOCIFRSSEG_CT  ,
     PREV_LOCINIPRO_CF   ,
     PREV_LOCIFRSTRA_CT
/INFILE $ESF_FI17PRODUCT_PREV 1000 1 "~"
/joinkeys
     GRPIFRSSEG_CT ,
     GRPINIPRO_CF  ,
     GRPIFRSTRA_CT ,
     PARIFRSSEG_CT ,
     PARINIPRO_CF  ,
     PARIFRSTRA_CT ,
     LOCIFRSSEG_CT ,
     LOCINIPRO_CF  ,
     LOCIFRSTRA_CT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_COLS,
        rightside:I17PRDCOD_CT
exit
EOF
SORT


NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
LIBEL="split to select CSUOE that need product_code calculation  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_60_${IB}_FCTRI17PRD_ALL_PREV_PRDCODE.dat 2000 1"
SORT_O="$DFILT/${NJOB}_70_${IB}_FCTRI17PRD_EMPTY_NOTBOOKED.dat 2000 1"
SORT_O2="$DFILT/${NJOB}_70_${IB}_FCTRI17PRD_EMPTY_BOOKED.dat 2000 1"
SORT_O3="$DFILT/${NJOB}_70_${IB}_FCTRI17PRD_NOT_EMPTY.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
     CTR_NF             1:1 - 1:   , 
     END_NT             2:1 - 2:EN , 
     SEC_NF             3:1 - 3:EN ,  
     UWY_NF             4:1 - 4:   , 
     UW_NT              5:1 - 5:EN ,
     GRPIFRSSEG_CT      6:1 - 6:   ,         
     GRPINIPRO_CF       7:1 - 7:   ,         
     GRPIFRSTRA_CT      8:1 - 8:   ,       
     PARIFRSSEG_CT      9:1 - 9:   ,      
     PARINIPRO_CF       10:1 - 10: ,        
     PARIFRSTRA_CT      11:1 - 11: ,        
     LOCIFRSSEG_CT      12:1 - 12: ,        
     LOCINIPRO_CF       13:1 - 13: ,         
     LOCIFRSTRA_CT      14:1 - 14: ,   	 
     GRPINISTS_CT       15:1 - 15: ,
     PARINISTS_CT       16:1 - 16: ,
     LOCINISTS_CT       17:1 - 17: ,
     I17PRDCOD_CT       22:1 - 22:
/KEYS  
     GRPIFRSSEG_CT  ,
     GRPINIPRO_CF   ,
     GRPIFRSTRA_CT  ,
     PARIFRSSEG_CT  ,
     PARINIPRO_CF   ,
     PARIFRSTRA_CT  ,
     LOCIFRSSEG_CT  ,
     LOCINIPRO_CF   ,
     LOCIFRSTRA_CT 
/CONDITION PRD_EMPTY_NOTBOOKED I17PRDCOD_CT EQ "" AND (GRPINISTS_CT != "2" OR PARINISTS_CT != "2" OR LOCINISTS_CT != "2" OR "$BOOKED_OPT" = "PROCESSBOOK" ) 
/CONDITION PRD_EMPTY_BOOKED    I17PRDCOD_CT EQ "" AND GRPINISTS_CT = "2" AND PARINISTS_CT = "2" AND LOCINISTS_CT = "2" AND "$BOOKED_OPT" != "PROCESSBOOK"
/CONDITION PRD_NOT_EMPTY       I17PRDCOD_CT != "" 
/OUTFILE ${SORT_O}
/INCLUDE PRD_EMPTY_NOTBOOKED
/OUTFILE ${SORT_O2}
/INCLUDE PRD_EMPTY_BOOKED
/OUTFILE ${SORT_O3}
/INCLUDE PRD_NOT_EMPTY
exit
EOF

if [ "$BOOKED_OPT" = "PROCESSBOOK" ]
then
ECHO_LOG "/!\ WARNING : product code is generated for booked contracts"
fi 

SORT


NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Generate new product code when it is empty "
AWK_I=$DFILT/${NJOB}_70_${IB}_FCTRI17PRD_EMPTY_NOTBOOKED.dat
AWK_O=$DFILT/${NJOB}_80_${IB}_FCTRI17PRD_NOTBOOKED_NEW.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~";
       new_id = 0;
	   prev_key = "";
	   new_key = "";
         }
     {

		new_key=sprintf("%s~%s~%s~%s~%s~%s~%s~%s~%s",\$6,\$7,\$8,\$9,\$10,\$11,\$12,\$13,\$14);	
			
	    if ( new_id  == 0 && \$20 == "" ) 
		  new_id = 0;

	    if ( new_id  == 0 && \$20 != "" ) # new_id = max+1
		  new_id = \$20 ;

		if ( prev_key != new_key )
        {		
		new_id = new_id + 1;
		prev_key = new_key ;
        }
		
	    product=sprintf("%s%08d",\$21 ,new_id ); 
		
		if ( new_id > 0 )
        print \$1 "~" \$2 "~" \$3 "~" \$4 "~" \$5 "~" \$6 "~" \$7 "~" \$8 "~" \$9 "~" \$10 "~" \$11 "~" \$12 "~" \$13 "~" \$14 "~" \$15 "~" \$16 "~" \$17 "~" \$18 "~" \$19 "~" \$20 "~" \$21 "~" product 


     }
exit
EOF
AWK



NSTEP=${NJOB}_90
#---------------------------------------------------------------
LIBEL="New product codes list  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_80_${IB}_FCTRI17PRD_NOTBOOKED_NEW.dat 2000 1"
SORT_O="$DFILT/${NJOB}_90_${IB}_FI17PRODUCT_NEW.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
     GRPIFRSSEG_CT       6:1 - 6:,
     GRPINIPRO_CF        7:1 - 7:,
     GRPIFRSTRA_CT       8:1 - 8:,
     PARIFRSSEG_CT       9:1 - 9:,
     PARINIPRO_CF        10:1 - 10:,
     PARIFRSTRA_CT       11:1 - 11:,
     LOCIFRSSEG_CT       12:1 - 12:,
     LOCINIPRO_CF        13:1 - 13:,
     LOCIFRSTRA_CT       14:1 - 14:, 
     PRDCOD_CT	         22:1 - 22:,
     PREV_USER_SITE      18:1 - 18: 
/OUTFILE ${SORT_O} overwrite	
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
     PREV_USER_SITE	 
exit
EOF
SORT


NSTEP=${NJOB}_95
#---------------------------------------------------------------
LIBEL="Check no existing keys before saving new product codes"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_90_${IB}_FI17PRODUCT_NEW.dat 2000 1"
SORT_O="$DFILT/${NJOB}_95_${IB}_FI17PRODUCT_NEW.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
     GRPIFRSSEG_CT       6:1 - 6:,
     GRPINIPRO_CF        7:1 - 7:,
     GRPIFRSTRA_CT       8:1 - 8:,
     PARIFRSSEG_CT       9:1 - 9:,
     PARINIPRO_CF        10:1 - 10:,
     PARIFRSTRA_CT       11:1 - 11:,
     LOCIFRSSEG_CT       12:1 - 12:,
     LOCINIPRO_CF        13:1 - 13:,
     LOCIFRSTRA_CT       14:1 - 14:, 
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
     GRPIFRSSEG_CT ,
     GRPINIPRO_CF  ,
     GRPIFRSTRA_CT ,
     PARIFRSSEG_CT ,
     PARINIPRO_CF  ,
     PARIFRSTRA_CT ,
     LOCIFRSSEG_CT ,
     LOCINIPRO_CF  ,
     LOCIFRSTRA_CT 
/INFILE $ESF_FI17PRODUCT_PREV 2000 1 "~"
/joinkeys
     PRD_GRPIFRSSEG_CT     ,
     PRD_GRPINIPRO_CF      ,
     PRD_GRPIFRSTRA_CT     ,
     PRD_PARIFRSSEG_CT     ,
     PRD_PARINIPRO_CF      ,
     PRD_PARIFRSTRA_CT     ,
     PRD_LOCIFRSSEG_CT     ,
     PRD_LOCINIPRO_CF      ,
     PRD_LOCIFRSTRA_CT     
/OUTFILE ${SORT_O} overwrite
/REFORMAT
     leftside:GRPIFRSSEG_CT ,
     GRPINIPRO_CF  ,
     GRPIFRSTRA_CT ,
     PARIFRSSEG_CT ,
     PARINIPRO_CF  ,
     PARIFRSTRA_CT ,
     LOCIFRSSEG_CT ,
     LOCINIPRO_CF  ,
     LOCIFRSTRA_CT 
exit
EOF
SORT

# stop when existings keys found
found=`wc -l $DFILT/${NJOB}_95_${IB}_FI17PRODUCT_NEW.dat  | cut -d" " -f1  `
ECHO_LOG "found=$found existing keys found "

if [ $found -ne 0 ]
then
   ECHO_LOG "ERROR new CSUOE produced existings key into best..TI17PRODUCT "
   ECHO_LOG "check  wrong keys into  $DFILT/${NJOB}_95_${IB}_FI17PRODUCT_NEW.dat  "
   STEPEND 95
fi


NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="generate final product catalog ESF_FI17PRODUCT_NEW=$ESF_FI17PRODUCT_NEW "
touch $ESF_FI17PRODUCT_NEW
gzip -c ${ESF_FI17PRODUCT_NEW} > ${DARCH}/${ENV_PREFIX}_ESFD0040_FI17PRODUCT_${IB}.dat.gz
sort -u $DFILT/${NJOB}_90_${IB}_FI17PRODUCT_NEW.dat    > $DFILT/${NJOB}_100_${IB}_FI17PRODUCT_NEW.dat

#--- check duplicate
sort -u $DFILT/${NJOB}_100_${IB}_FI17PRODUCT_NEW.dat  | cut -d"~" -f1 | sort -u > $DFILT/${NJOB}_100_${IB}_FI17PRODUCT_NEW_UNIQ.dat
nbtotal=`wc -l $DFILT/${NJOB}_100_${IB}_FI17PRODUCT_NEW.dat | cut -d" " -f1 `
nbkeys=`wc -l  $DFILT/${NJOB}_100_${IB}_FI17PRODUCT_NEW_UNIQ.dat  | cut -d" " -f1 `
duplicate=`expr ${nbtotal} - ${nbkeys}`
EXECKSH_MODE=P
EXECKSH "echo CHECK_DUPLICATE : $duplicate duplicate , ${nbtotal} - ${nbkeys} "

if [ $duplicate -ne 0 ]
then
   ECHO_LOG "ERROR : $duplicate duplicate keys found into $DFILT/${NJOB}_100_${IB}_FI17PRODUCT_NEW.dat  "
   diff $DFILT/${NJOB}_100_${IB}_FI17PRODUCT_NEW.dat  $DFILT/${NJOB}_100_${IB}_FI17PRODUCT_NEW_UNIQ.dat  > $DFILT/${NJOB}_100_${IB}_FI17PRODUCT_NEW_DUPLICATES.dat
   STEPEND 100
fi

SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$ESF_FI17PRODUCT_PREV 2000 1"
SORT_I2="$DFILT/${NJOB}_100_${IB}_FI17PRODUCT_NEW.dat  2000 1"
SORT_O="$ESF_FI17PRODUCT_NEW 2000 1 overwrite "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        PRDCOD_CT    1:1 - 1:
/KEYS
        PRDCOD_CT
exit
EOF
SORT




NSTEP=${NJOB}_110
#------------------------------------------------------------------------------
LIBEL="MERGE ALL data : New contract links list  "
#------------------------------------------------------------------------------
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_80_${IB}_FCTRI17PRD_NOTBOOKED_NEW.dat 2000 1"
SORT_I2="$DFILT/${NJOB}_70_${IB}_FCTRI17PRD_EMPTY_BOOKED.dat 2000 1"
SORT_I3="$DFILT/${NJOB}_70_${IB}_FCTRI17PRD_NOT_EMPTY.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCTRI17PRD_ALL_UPDATED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
     CTR_NF                 1:1 - 1:   , 
     END_NT                 2:1 - 2:EN , 
     SEC_NF                 3:1 - 3:EN ,  
     UWY_NF                 4:1 - 4:   , 
     UW_NT                  5:1 - 5:EN ,
     PREV_GRPIFRSSEG_CT     6:1 - 6:   ,         
     PREV_GRPINIPRO_CF      7:1 - 7:   ,         
     PREV_GRPIFRSTRA_CT     8:1 - 8:   ,       
     PREV_PARIFRSSEG_CT     9:1 - 9:   ,      
     PREV_PARINIPRO_CF      10:1 - 10: ,        
     PREV_PARIFRSTRA_CT     11:1 - 11: ,        
     PREV_LOCIFRSSEG_CT     12:1 - 12: ,        
     PREV_LOCINIPRO_CF      13:1 - 13: ,         
     PREV_LOCIFRSTRA_CT     14:1 - 14: ,   
     PREV_GRPINISTS_CT      15:1 - 15: ,
     PREV_PARINISTS_CT      16:1 - 16: ,
     PREV_LOCINISTS_CT      17:1 - 17: ,
     PREV_USER_SITE         18:1 - 18: ,		
     PREV_CTR_TYP           19:1 - 19: ,
     I17PRDCOD_CT           22:1 - 22:	 
/DERIVEDFIELD EMPTY_FIELD "~"	 
/KEYS  
     CTR_NF  ,
     END_NT  ,
     SEC_NF  ,
     UWY_NF  ,
     UW_NT   
/CONDITION PRDCOD_OK ( I17PRDCOD_CT != "" )	 
/OUTFILE ${SORT_O} overwrite
/INCLUDE PRDCOD_OK 	
/REFORMAT     CTR_NF    ,
              END_NT       ,
              SEC_NF       ,
              UWY_NF       ,       
              UW_NT        ,	
              PREV_CTR_TYP ,
              EMPTY_FIELD ,
              I17PRDCOD_CT     
exit
EOF
SORT




NSTEP=${NJOB}_120
#---------------------------------------------------------------
LIBEL="check to avoid duplicate and overwrite ESF_FCTRI17PRD_NEW = $ESF_FCTRI17PRD_NEW "
cut -d"~" -f1,2,3,4,5 ${DFILT}/${NJOB}_110_${IB}_FCTRI17PRD_ALL_UPDATED.dat | sort    > $DFILT/${NJOB}_120_${IB}_FCTRI17PRD_ALL_UPDATED.dat
cut -d"~" -f1,2,3,4,5 ${DFILT}/${NJOB}_110_${IB}_FCTRI17PRD_ALL_UPDATED.dat | sort -u > $DFILT/${NJOB}_120_${IB}__FCTRI17PRD_ALL_UPDATED_UNIQ.dat
nbtotal=`wc -l $DFILT/${NJOB}_120_${IB}_FCTRI17PRD_ALL_UPDATED.dat  | cut -d" " -f1 `
nbkeys=`wc -l  $DFILT/${NJOB}_120_${IB}__FCTRI17PRD_ALL_UPDATED_UNIQ.dat | cut -d" " -f1  `
duplicate=`expr ${nbtotal} - ${nbkeys}`
EXECKSH_MODE=P
EXECKSH "echo FINAL_CHECK: $duplicate duplicate , ${nbtotal} - ${nbkeys} "

if [ $duplicate -ne 0 ]
then
   ECHO_LOG "ERROR : $duplicate duplicate keys found into ESF_FCTRI17PRD_NEW=$ESF_FCTRI17PRD_NEW "
   diff $DFILT/${NJOB}_120_${IB}_FCTRI17PRD_ALL_UPDATED.dat  $DFILT/${NJOB}_120_${IB}__FCTRI17PRD_ALL_UPDATED_UNIQ.dat  | grep "~"  > $DFILT/${NJOB}_120_${IB}__FCTRI17PRD_ALL_UPDATED_DUPLICATES.dat
   STEPEND 120
fi

touch $ESF_FCTRI17PRD_NEW 
gzip -c ${ESF_FCTRI17PRD_NEW} > ${DARCH}/${ENV_PREFIX}_ESFD0040_FCTRI17PRD_${IB}.dat.gz
mv  ${DFILT}/${NJOB}_110_${IB}_FCTRI17PRD_ALL_UPDATED.dat  $ESF_FCTRI17PRD_NEW
ECHO_LOG "overwrite file ESF_FCTRI17PRD_NEW=$ESF_FCTRI17PRD_NEW "

JOBEND

                     
