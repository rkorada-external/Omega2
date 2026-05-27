#!/bin/ksh
#===============================================================================
# application name               : Compare data to send to TTECLECDA
# source name                    : ESDC0012.cmd
# revision                       : $Revision:   0.1  $
# extraction date                : 08/07/2021
# author                         : S.Behague
# specifications reference       :
#                                :
#-------------------------------------------------------------------------------
# description                    : 
#
# parameters                     :
#
#
#-------------------------------------------------------------------------------
# modifications chronology       :
# [001] - 08/07/2021 S.Behague :spira:96760 - RA and SAP interface data checks
# [002] - 24/08/2021 S.Behague :spira:96760 - RA and SAP interface data checks Version 2
# [003] - 16/03/2023 JYP:spira:104893 - rework all checks
# [004] - 20/03/2023 JYP:spira:104893 - new field for default products
# [005] - 21/03/2023 JYP:spira:104893 - remove field partial defaulting
# [006] - 22/03/2023 JYP:spira:104893 - add checks on product attributes
# [007] - 29/03/2023 JYP:spira:109361 - more checks on product attributes  
# [008] - 13/04/2023 JYP:spira:109178 - more checks from ES?D3860  
# [009] - 17/04/2023 JYP:spira:109178 - more checks from ESFD3560 
# [010] - 03/07/2023 JYP:spira:109764 - use specific maillist by env
# [011] - 20/11/2023 JYP:spira:110891 - exclude some TC I17G into IFRS4, update mail SAP warnings
# [012] - 19/12/2023 JYP:spira:110086 - new version of SAP checks
# [013] - 10/01/2024 JYP:spira:110086 - new version of SAP checks
# [014] - 15/03/2024 JYP:spira:111359 - SAP checks for SIMU EBS/IFRS4
# [015] - 11/02/2025 JYP:spira 111574/109805 : detect IBNR bugs each year Q1
#===============================================================================

# call generic functions
#------------------------------------------------------------------------------
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Job Initialisation
#-------------------
JOBINIT



################################
#==== print ratio (%) from 2 numbers
print_ratio100 () {
 nb=$1
 total=$2
 
	if [ $total -ne 0 ]
	then
		ratio=`echo "(($nb/$total)*100)" | bc -l`
	else
		ratio="0"
	fi

ratio_disp=`printf "%.2f" "$ratio" `
if [ $ratio -ge 0.59 ] && [ "$3" = "" ]
then
 echo "<B><font color=red>($ratio_disp %)</font></B>"
else
 echo "($ratio_disp %)"
fi 
}
################################




#------------------------------------------------------------------------------
NSTEP=${NJOB}_10
LIBEL="check DFILP/empty.dat  "
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "# Begin of step:  $NSTEP "
ECHO_LOG "# Subject: $LIBEL "
	
if [ -s ${DFILP}/empty.dat ] || [ ! -f ${DFILP}/empty.dat ] 
then
	EMPTY="<BR><b><font color=red>VERY URGENT ISSUE: the file DFILP/empty.dat is not empty or missing , please check ! </font></B><BR>"
	URGENT_MSG="VERY URGENT ISSUE: "
	ECHO_LOG "empty.dat is KO"
	head -10 ${DFILP}/empty.dat >> $FLOG	
else
	EMPTY="<BR>The file DFILP/empty.dat is empty => <b><font color=green>OK</font></B><br>"
	ECHO_LOG "empty.dat is OK"
	URGENT_MSG=""
fi
ECHO_LOG "#"
ECHO_LOG "#========================================================================="
ECHO_LOG ""
	


#------------------------------------------------------------------------------
NSTEP=${NJOB}_15
LIBEL="check SAP return files ES?D3860 "
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "# Begin of step:  $NSTEP "
ECHO_LOG "# Subject: $LIBEL "

# merge all checks files
# filter only list of temporary filenames (because no need to have details in the mail)


grep "/temporaire" $DFILP/empty.dat $ESF_SAP_RETURN_CHECKS_EBS $ESF_SAP_RETURN_CHECKS_I17G $ESF_SAP_RETURN_CHECKS_I17L $ESF_SAP_RETURN_CHECKS_I17P  $ESF_SAP_RETURN_CHECKS_I4I | grep -v "0 /" | sed 's/^/<br><font size=1>/' |  sed 's/$/<\/font>/' > ${DFILT}/${ENV_PREFIX}_ESDC0010_15_${IB}_RETURN_CHECKS.dat

# SIMU inputs 
grep "/temporaire" $DFILP/empty.dat $ESF_SAP_SIMU_CHECKS_I17G $ESF_SAP_SIMU_CHECKS_I17P $ESF_SAP_SIMU_CHECKS_I17L $ESF_SAP_SIMU_CHECKS_I17S | grep -v "0 /" | sed 's/^/<br><font size=1>/' |  sed 's/$/<\/font>/'  >> ${DFILT}/${ENV_PREFIX}_ESDC0010_15_${IB}_RETURN_CHECKS.dat
grep "/temporaire" $DFILP/empty.dat $ESF_SAP_SIMU_CHECKS_I4I $ESF_SAP_SIMU_CHECKS_EBS $ESF_SAP_SIMU_CHECKS_POSI | grep -v "0 /" | sed 's/^/<br><font size=1>/' |  sed 's/$/<\/font>/'  >> ${DFILT}/${ENV_PREFIX}_ESDC0010_15_${IB}_RETURN_CHECKS.dat

# SSD_ESB missing in SAP setup
grep "/temporaire" $ESF_SAP_SETUP_MISSING_I17G $ESF_SAP_SETUP_MISSING_I17P $ESF_SAP_SETUP_MISSING_I17L $ESF_SAP_SETUP_MISSING_EBS $ESF_SAP_SETUP_MISSING_I4I | grep -v "0 /" | sed 's/^/<br><font size=1>/' |  sed 's/$/<\/font>/' > ${DFILT}/${ENV_PREFIX}_ESDC0010_15_${IB}_SSD_ESB_MISSING_SAP.dat

	
if [ -s  ${DFILT}/${ENV_PREFIX}_ESDC0010_15_${IB}_RETURN_CHECKS.dat  ] 
then

	SAP_RETURN_MSG="<BR><b><font color=red>WARNING : errors detected by ES?D3x60, please check files below ! </font></B>"
	WARNING_MSG="WARNING: "
	ECHO_LOG "WARNING : errors detected by ES?D3x60, please check !"
	cat  ${DFILT}/${ENV_PREFIX}_ESDC0010_15_${IB}_RETURN_CHECKS.dat   >> $FLOG	
else
	SAP_RETURN_MSG="<BR>The checks of return files by ES?D3x60 are <b><font color=green>OK</font></B><br>"
	ECHO_LOG "The checks of SAP return files by ES?D3x60 are OK"
	WARNING_MSG=""
fi


if [ -s  ${DFILT}/${ENV_PREFIX}_ESDC0010_15_${IB}_SSD_ESB_MISSING_SAP.dat  ] 
then
	SAP_MSG2="<BR><BR><b><font color=red>ERROR : missing SSD/ESB into SAP setup file, please check perm/*ESPD3910_*_SAP_SETUP_MISSING.dat  </font></B>"
	WARNING_MSG="ERROR: "
	URGENT_MSG="URGENT: "
	ECHO_LOG "ERROR : missing SSD/ESB into SAP setup file , please check perm/*ESPD3910_*_SAP_SETUP_MISSING.dat"
	cat  ${DFILP}/${ENV_PREFIX}_ESPD3910_*_SAP_SETUP_MISSING.dat   >> $FLOG	
fi 

ECHO_LOG "#"
ECHO_LOG "#========================================================================="
ECHO_LOG ""
	
	
	

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="MERGE all TMP data into 1 file ESF_FILELIST_STATS=$ESF_FILELIST_STATS "
EXECKSH_MODE=P
EXECKSH "echo $NSTEP : $LIBEL running ...."
cat ${DFILT}/${ENV_PREFIX}_ESDC0010_???*_*_${IB}_STATS.dat | sort -k1,3  > $ESF_FILELIST_STATS
cat $ESF_FILELIST_STATS  >> $FLOG
ECHO_LOG "#"
ECHO_LOG "#========================================================================="
ECHO_LOG ""


NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="MERGE all TMP data into 1 file ESF_CSUOE_PRODUCT=$ESF_CSUOE_PRODUCT "
EXECKSH_MODE=P
EXECKSH "echo $NSTEP : $LIBEL running ...."
cat ${DFILT}/${ENV_PREFIX}_ESDC0010_???*_*_${IB}_CSUOE_*.dat | sort -u  > $ESF_CSUOE_PRODUCT 
wc -l $ESF_CSUOE_PRODUCT >> $FLOG
ECHO_LOG "#"
ECHO_LOG "#========================================================================="
ECHO_LOG ""



NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="MERGE all TMP data into 1 file ESF_EMPTY_DATA=$ESF_EMPTY_DATA "
EXECKSH_MODE=P
EXECKSH "echo $NSTEP : $LIBEL running ...."
cat ${DFILT}/${ENV_PREFIX}_ESDC0010_???*_*_${IB}_ALL_EMPTY.dat | sort -u  > $ESF_EMPTY_DATA
wc -l $ESF_EMPTY_DATA >> $FLOG
ECHO_LOG "#"
ECHO_LOG "#========================================================================="
ECHO_LOG ""




NSTEP=${NJOB}_50
#-------------------------------------------------------------
LIBEL="add product attributes to the file $ESF_CSUOE_PRODUCT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_CSUOE_PRODUCT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSUOE_PRODUCT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
     ALL_COLS               1:1 - 9:  ,
     I17PRDCOD_CT_FILE      9:1  -  9: ,
	 I17PRDCOD_CT           1:1  -  1: ,
     GRPIFRSSEG_CT          2:1  -  2: ,
     GRPINIPRO_CF           3:1  -  3: ,
     GRPIFRSTRA_CT          4:1  -  4: ,
     PARIFRSSEG_CT          5:1  -  5: ,
     PARINIPRO_CF           6:1  -  6: ,
     PARIFRSTRA_CT          7:1  -  7: ,
     LOCIFRSSEG_CT          8:1  -  8: ,
     LOCINIPRO_CF           9:1  -  9: ,
     LOCIFRSTRA_CT          10:1 -  10:
/joinkeys
     I17PRDCOD_CT_FILE
/INFILE $ESF_FI17PRODUCT 1000 1 "~"
/joinkeys
     I17PRDCOD_CT 
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_COLS,
        rightside:GRPIFRSSEG_CT,GRPINIPRO_CF,GRPIFRSTRA_CT,PARIFRSSEG_CT,PARINIPRO_CF,PARIFRSTRA_CT,LOCIFRSSEG_CT,LOCINIPRO_CF,LOCIFRSTRA_CT
exit
EOF
SORT


NSTEP=${NJOB}_70
#-------------------------------------------------------------
LIBEL="add I17P/I17G cloper param to the file $EST_FESB "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FESB} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESB_CLOPER.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
     ALL_COLS               1:1 - 12:,
	 SSD_CF_1               1:1 - 1:,
	 ESB_CF_1               2:1 - 2:,	
	 SSD_CF_2               1:1 - 1:,
	 ESB_CF_2               2:1 - 2:,	 	 
	 PARM1_I17P             3:1 - 3:, 
	 PARM2_I17P             4:1 - 4: 	 
/joinkeys
     SSD_CF_1,
	 ESB_CF_1
/INFILE $ESF_FI17CLOPER_I17P 1000 1 "~"
/joinkeys
     SSD_CF_2,
	 ESB_CF_2
/JOIN UNPAIRED LEFTSIDE
/DERIVEDFIELD EMPTY_I17G "~"
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_COLS,EMPTY_I17G,EMPTY_I17G,
        rightside:PARM1_I17P,PARM2_I17P
exit
EOF
SORT



NSTEP=${NJOB}_80
#-------------------------------------------------------------
LIBEL="add I17P cloper param to the file $EST_FESB "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_ESB_CLOPER.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESB_CLOPER.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
     ALL_COLS               1:1 - 16:,
	 SSD_CF_1               1:1 - 1:,
	 ESB_CF_1               2:1 - 2:,	
	 SSD_CF_2               1:1 - 1:,
	 ESB_CF_2               2:1 - 2:,	 	 
	 PARM1_I17L             3:1 - 3:, 
	 PARM2_I17L             4:1 - 4: 	 
/joinkeys
     SSD_CF_1,
	 ESB_CF_1
/INFILE $ESF_FI17CLOPER_I17L 1000 1 "~"
/joinkeys
     SSD_CF_2,
	 ESB_CF_2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_COLS,
        rightside:PARM1_I17L,PARM2_I17L
exit
EOF
SORT



NSTEP=${NJOB}_90
#-------------------------------------------------------------
LIBEL="add LIFE flag and cloper params to the file $ESF_CSUOE_PRODUCT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_CSUOE_PRODUCT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSUOE_PRODUCT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
     ALL_COLS               1:1 - 18:,
	 SSD_CF_1               1:1 - 1:,
	 ESB_CF_1               2:1 - 2:,	
	 SSD_CF_2               1:1 - 1:,
	 ESB_CF_2               2:1 - 2:,	 	 
	 LIFE_CF                9:1 - 9:,
	 PARM1_I17G             13:1 - 13:, 
	 PARM2_I17G             14:1 - 14:, 	 
	 PARM1_I17P             15:1 - 15:, 
	 PARM2_I17P             16:1 - 16:, 
	 PARM1_I17L             17:1 - 17:, 
	 PARM2_I17L             18:1 - 18: 
/joinkeys
     SSD_CF_1,
	 ESB_CF_1
/INFILE ${DFILT}/${NJOB}_80_${IB}_ESB_CLOPER.dat 1000 1 "~"
/joinkeys
     SSD_CF_2,
	 ESB_CF_2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_COLS,
        rightside:LIFE_CF,PARM1_I17G,PARM2_I17G,PARM1_I17P,PARM2_I17P,PARM1_I17L,PARM2_I17L
exit
EOF
SORT


NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="check defaulting attributes"
AWK_I=${DFILT}/${NJOB}_90_${IB}_CSUOE_PRODUCT.dat 
AWK_O=${DFILT}/${NJOB}_100_${IB}_CSUOE_PRODUCT.dat 
AWK_CMD=`CFTMP`
#===========================================
# DOC : STAT table description
#===========================================
# 1 => Missing IFRS17 product 
# 2 => With wrong attributes
# 3 => Without error
# 4 => Porfolio missing I17G
# 5 => Porfolio missing I17P
# 6 => Porfolio missing I17L
# 7 => Profitability missing I17G
# 8 => Profitability missing I17P
# 9 => Profitability missing I17L
# 10 => Transition approach missing I17G
# 11 => Transition approach missing I17P
# 12 => Transition approach missing I17L
# 13 => With default IFRS17 product
# 14 => With default attributes
# 15 => With default porfolio I17G
# 16 => With default porfolio I17P
# 17 => With default porfolio I17L
# 18 => With default profitability I17G
# 19 => With default profitability I17P
# 20 => With default profitability I17L
# 21 => With default transition approach I17G
# 22 => With default transition approach I17P
# 23 => With default transition approach I17L
# 24 => Total CSUOE
#===========================================
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~";
 i=1
 for (i=1;i<=24;i++)
 { STAT["LIFE",i]=0;STAT["PC",i]=0; }
}
     {
	    default_attr_flg="N";
		wrong_attr_flg="N";
		
        if ( \$19 == "1" )
		{ TYP="LIFE";
		  LIFEPC="SGL";
		  SUF="000";
 	      STAT[TYP,24]=STAT[TYP,24]+1 ;		  
	    }
		else  
		{ TYP="PC";
		  LIFEPC="PC";
		  SUF="0000";
 	      STAT[TYP,24]=STAT[TYP,24]+1 ;		  
        }

        if ( \$8 == "A" )
		{ default_seg=sprintf("%s%s%s",LIFEPC,"ACC",SUF);
		  default_pro="9";
	    }
		else  
		{ default_seg=sprintf("%s%s%s",LIFEPC,"RET",SUF);
		  default_pro="8";
		}
 
	    if ( \$10 == default_seg ) 		
	         {
			   print \$0 "~" TYP "~GRP with default porfolio" ;
			   default_attr_flg="Y" ;
			   STAT[TYP,15]=STAT[TYP,15]+1 ;
			 }
		
		if ( \$10 == "" ) 		
	         {  
			   print \$0 "~" TYP "~GRP missing porfolio" ;	
			   STAT[TYP,4]=STAT[TYP,4]+1 ;		
			   wrong_attr_flg="Y";			   
			 }


	    if ( \$13 == default_seg && \$22 == "1" ) 		
			 { 
			   print \$0 "~" TYP "~PAR with default porfolio" ;
			   default_attr_flg="Y" ;	
			   STAT[TYP,16]=STAT[TYP,16]+1 ;			   
			 }
		
		if ( \$13 == "" && \$22 == "1" ) 		
	         {
			 print \$0 "~" TYP "~PAR missing porfolio" ;	
			 STAT[TYP,5]=STAT[TYP,5]+1 ;
			 wrong_attr_flg="Y";			   			 
			 }

	    if ( \$16 == default_seg && \$25 == "1" ) 		
	         { 
			   print \$0 "~" TYP "~LOC with default porfolio" ;
			   default_attr_flg="Y" ;	
			   STAT[TYP,17]=STAT[TYP,17]+1 ;			   
			 }
		
		if ( \$16 == "" && \$25 == "1" ) 		
	         { 
			 print \$0 "~" TYP "~LOC missing porfolio" ;	
			 STAT[TYP,6]=STAT[TYP,6]+1 ;
			 wrong_attr_flg="Y";			   			 
			 }
			 

	    if ( \$11 == default_pro ) 		
	         { 
			   print \$0 "~" TYP "~GRP with default profitability" ;
			   default_attr_flg="Y" ;
			   STAT[TYP,18]=STAT[TYP,18]+1 ;			   
			 }
		
		if ( \$11 == "" ) 		
	         { 
			 print \$0 "~" TYP "~GRP missing profitability" ;	
			 STAT[TYP,7]=STAT[TYP,7]+1 ;	
			 wrong_attr_flg="Y";			   			 
			 }
			 

	    if ( \$14 == default_pro && \$22 == "1" ) 		
	         { 
			   print \$0 "~" TYP "~PAR with default profitability" ;
			   default_attr_flg="Y" ;	
			   STAT[TYP,19]=STAT[TYP,19]+1 ;			   
			 }
		
		if ( \$14 == "" && \$22 == "1" ) 		
	         { 
			 print \$0 "~" TYP "~PAR missing profitability" ;	
			 STAT[TYP,8]=STAT[TYP,8]+1 ;	
			 wrong_attr_flg="Y";			   			 			 
			 }


	    if ( \$17 == default_pro && \$25 == "1" ) 		
	         { 
			 print \$0 "~" TYP "~LOC with default profitability" ;
			 default_attr_flg="Y" ;	
			 STAT[TYP,20]=STAT[TYP,20]+1 ;			 
			 }
		
		if ( \$17 == "" && \$25 == "1" ) 		
	         {
			 print \$0 "~" TYP "~LOC missing profitability" ;	
			 STAT[TYP,9]=STAT[TYP,9]+1 ;
			 wrong_attr_flg="Y";			   			 			 
			 }
			 

	    if ( \$12 == "9" && \$6 <= 2021 ) 		
	         { 
			 print \$0 "~" TYP "~GRP with default transition approach" ;
			 default_attr_flg="Y" ;	
			 STAT[TYP,21]=STAT[TYP,21]+1 ;			 
			 }
		
		if ( \$12 == "" && \$6 <= 2021 ) 		
	         {
			 print \$0 "~" TYP "~GRP missing transition approach" ;	
			 STAT[TYP,10]=STAT[TYP,10]+1 ;	
			 wrong_attr_flg="Y";			   			 			 
			 }
			 

	    if ( \$15 == "9" && \$6 <= 2021 && \$22 == "1" ) 		
	         { 
			 print \$0 "~" TYP "~PAR with default transition approach" ;
			 default_attr_flg="Y" ;	
			 STAT[TYP,22]=STAT[TYP,22]+1 ;			 
			 }
		
		if ( \$15 == "" && \$6 <= 2021  && \$22 == "1" ) 		
	         { 
			 print \$0 "~" TYP "~PAR missing transition approach" ;		
			 STAT[TYP,11]=STAT[TYP,11]+1 ;	
			 wrong_attr_flg="Y";			   			 			 
			 }
			 

	    if ( \$18 == "9" && \$6 <= 2021 && \$25 == "1" ) 		
	         { 
			 print \$0 "~" TYP "~LOC with default transition approach" ;
			 default_attr_flg="Y" ;		
			 STAT[TYP,23]=STAT[TYP,23]+1 ;			 
			 }
		
		if ( \$18 == "" && \$6 <= 2021  && \$25 == "1" ) 		
	         { 
			 print \$0 "~" TYP "~LOC missing transition approach" ;	
			 STAT[TYP,12]=STAT[TYP,12]+1 ;	
			 wrong_attr_flg="Y";			   			 			 
			 }
		

		if (substr(\$9,1,2) == "SG" || substr(\$9,1,2) == "PC" )	 	
		     { 
			 print \$0 "~" TYP "~with default product" ;	
			 STAT[TYP,13]=STAT[TYP,13]+1 ;			 			 
			 }

		if (\$9 == "" )	 	
		  { 
		  print \$0 "~" TYP "~missing product" ;	
		  STAT[TYP,1]=STAT[TYP,1]+1 ;
		  wrong_attr_flg="Y";			   			 
		  }
		 

       if ( default_attr_flg == "Y" )
	   {
	   print \$0 "~" TYP "~with default attributes" ;
	   STAT[TYP,14]=STAT[TYP,14]+1 ;		   
	   }

       if ( wrong_attr_flg == "Y" )
	   {
	   print \$0 "~" TYP "~with wrong attributes" ;
	   STAT[TYP,2]=STAT[TYP,2]+1 ;		   
	   }

		   			 
     }
END {

STAT["LIFE",3]=STAT["LIFE",24] - STAT["LIFE",2] - STAT["LIFE",1] ;
STAT["PC",3]=STAT["PC",24] - STAT["PC",2] - STAT["PC",1] ;

  TOTAL_LIFE="TOTAL_LIFE~"; 
  i=1
  for (i=1;i<=24;i++)
  { TOTAL_LIFE=TOTAL_LIFE STAT["LIFE",i] "~" ;}

  TOTAL_PC="TOTAL_PC~"; 
  i=1
  for (i=1;i<=24;i++)
  { TOTAL_PC=TOTAL_PC STAT["PC",i] "~" ;}

  print TOTAL_PC ;  
  print TOTAL_LIFE ;
  
}	 
exit
EOF
#cat $AWK_CMD >> $FLOG 
AWK


NSTEP=${NJOB}_105
#-----------------------------------------------------------------------------
LIBEL="prepare data for ANO file ESF_EMPTY_DATA=$ESF_EMPTY_DATA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_CSUOE_PRODUCT.dat 2000 1"
SORT_O="${DFILT}/${NJOB}_105_${IB}_CSUOE_ERROR_ASSUMED.dat 2000 1"
SORT_O2="${DFILT}/${NJOB}_105_${IB}_CSUOE_ERROR_RETRO.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
SSD_CF       1:1 - 1:,
ESB_CF       2:1 - 2:,	
CTR_NF       3:1 - 3:,
SEC_NF       4:1 - 4:,	
END_NT       5:1 - 5:,
UWY_NF       6:1 - 6:, 
UW_NT        7:1 - 7:, 
TYPE_A       8:1 - 8:, 
I17PRDCOD_NT 9:1 - 9:,
ERROR_MSG    27:1 - 27:
/KEYS CTR_NF
/CONDITION  COND_ASSUMED ( SSD_CF != "TOTAL_PC" AND SSD_CF != "TOTAL_LIFE" ) AND TYPE_A = "A"
/CONDITION  COND_RETRO   ( SSD_CF != "TOTAL_PC" AND SSD_CF != "TOTAL_LIFE" ) AND TYPE_A = "R"
/DERIVEDFIELD EMPTY "~"
	
/OUTFILE ${SORT_O}
/REFORMAT CTR_NF,SEC_NF,END_NT,UWY_NF,UW_NT, EMPTY , EMPTY ,EMPTY ,EMPTY ,I17PRDCOD_NT,ERROR_MSG
/INCLUDE COND_ASSUMED

/OUTFILE ${SORT_O2}
/REFORMAT EMPTY,EMPTY,END_NT,EMPTY,UW_NT, CTR_NF , SEC_NF ,UWY_NF ,EMPTY ,I17PRDCOD_NT,ERROR_MSG
/INCLUDE COND_RETRO
	
exit
EOF
SORT	



NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="complete ANO file ESF_EMPTY_DATA=$ESF_EMPTY_DATA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_105_${IB}_CSUOE_ERROR_ASSUMED.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_105_${IB}_CSUOE_ERROR_RETRO.dat 2000 1"
SORT_O="${ESF_EMPTY_DATA} APPEND "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
CTR_NF       1:1 - 1:
exit
EOF
SORT	
	


NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
LIBEL="produce HTML report"
DAT=`date '+%d/%m/%Y %H:%M:%S' `
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "# Begin of step:  $NSTEP : Date : $DAT "
ECHO_LOG "# Subject: $LIBEL "
ECHO_LOG ""	
	

> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat

# init table values
typeset -A tab_total=(   ['I4I']=0 ['LOC']=0 ['EBS']=0 ['I17G']=0 ['I17P']=0 ['I17L']=0 )
typeset -A tab_gaap=(    ['I4I']=0 ['LOC']=0 ['EBS']=0 ['I17G']=0 ['I17P']=0 ['I17L']=0 )
typeset -A tab_prd=(     ['I4I']=0 ['LOC']=0 ['EBS']=0 ['I17G']=0 ['I17P']=0 ['I17L']=0 )
typeset -A tab_trncd=(   ['I4I']=0 ['LOC']=0 ['EBS']=0 ['I17G']=0 ['I17P']=0 ['I17L']=0 )
typeset -A tab_dbltrncd=(['I4I']=0 ['LOC']=0 ['EBS']=0 ['I17G']=0 ['I17P']=0 ['I17L']=0 )
typeset -A tab_dflt=(    ['I4I']=0 ['LOC']=0 ['EBS']=0 ['I17G']=0 ['I17P']=0 ['I17L']=0 )
typeset -A tab_ssd=(     ['I4I']=0 ['LOC']=0 ['EBS']=0 ['I17G']=0 ['I17P']=0 ['I17L']=0 )
typeset -A tab_esb=(     ['I4I']=0 ['LOC']=0 ['EBS']=0 ['I17G']=0 ['I17P']=0 ['I17L']=0 )
typeset -A tab_lobacc=(     ['I4I']=0 ['LOC']=0 ['EBS']=0 ['I17G']=0 ['I17P']=0 ['I17L']=0 )
typeset -A tab_lobret=(     ['I4I']=0 ['LOC']=0 ['EBS']=0 ['I17G']=0 ['I17P']=0 ['I17L']=0 )


case "${HOST_PRDSIT}" in
        "SGP1") SITE="ASIA";SITE2="AS";;
        "FRA1") SITE="EUROPE";SITE2="EU";;
        "USA1") SITE="AMERICA";SITE2="AM";;
        *) SITE="unknown_site";SITE2="??";;
esac


i=0
prevtyp=""
while read line; do
i=`expr $i + 1 `

ECHO_LOG  "id $i : $line "

  normedesc=`echo $line | cut -d":" -f1`
  norme14=`echo $line | cut -d":" -f2`  
  filedesc=`echo $line | cut -d":" -f3`
  File_Short_Name=`echo $line | cut -d":" -f4`
  empty_ssd=`echo $line | cut -d":" -f5`
  empty_esb=`echo $line | cut -d":" -f6`
  empty_trncd=`echo $line | cut -d":" -f7`
  empty_dbltrncd=`echo $line | cut -d":" -f8`
  empty_gaap=`echo $line | cut -d":" -f9`
  empty_prd=`echo $line | cut -d":" -f10`
  default_prd=`echo $line | cut -d":" -f11`
  total=`echo $line | cut -d":" -f12`
  permfile=`echo $line | cut -d":" -f13`
  empty_lobacc=`echo $line | cut -d":" -f14`
  empty_lobret=`echo $line | cut -d":" -f15`

  PARM_CLODAT_D_RPT=$PARM_CLODAT_D
  PARM_TYPEINV_RPT=$TYPEINV


#===== update total fields

tab_total[$norme14]=`expr ${tab_total[$norme14]} + $total `
tab_gaap[$norme14]=`expr  ${tab_gaap[$norme14]}  + $empty_gaap `
tab_prd[$norme14]=`expr   ${tab_prd[$norme14]}   + $empty_prd `
tab_dflt[$norme14]=`expr  ${tab_dflt[$norme14]}   + $default_prd `	 
tab_dbltrncd[$norme14]=`expr  ${tab_dbltrncd[$norme14]}  + $empty_dbltrncd `		 
tab_trncd[$norme14]=`expr ${tab_trncd[$norme14]} + $empty_trncd ` 
tab_esb[$norme14]=`expr ${tab_esb[$norme14]} + $empty_esb ` 
tab_ssd[$norme14]=`expr ${tab_ssd[$norme14]} + $empty_ssd ` 
tab_lobacc[$norme14]=`expr ${tab_lobacc[$norme14]} + $empty_lobacc ` 
tab_lobret[$norme14]=`expr ${tab_lobret[$norme14]} + $empty_lobret ` 
			 
case "$normedesc" in 
   "EBS")
         if [ -s ${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM_EBS.dat ]
         then
           PARM_ICLODAT_D_RPT=`grep "PARM_TYPEINV="  ${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM_I4I.dat | cut -d"=" -f2`
           PARM_TYPEINV_RPT=`grep "PARM_TYPEINV="    ${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM_I4I.dat | cut -d"=" -f2`
         fi    
         NORME_RPT="EBS" ;;
   "I4I")
         if [ -s ${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM_I4I.dat ]
         then
           PARM_ICLODAT_D_RPT=`grep "PARM_TYPEINV="  ${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM_I4I.dat | cut -d"=" -f2`
           PARM_TYPEINV_RPT=`grep "PARM_TYPEINV="    ${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM_I4I.dat | cut -d"=" -f2`
         fi    
         NORME_RPT="IFRS4";;
   "LOC")
         NORME_RPT="IFRS4 LOCAL"
         if [ -s ${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM_I4I.dat ]
         then
           PARM_ICLODAT_D_RPT=`grep "PARM_TYPEINV="  ${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM_I4I.dat | cut -d"=" -f2`
           PARM_TYPEINV_RPT=`grep "PARM_TYPEINV="    ${DFILP}/${ENV_PREFIX}_ESFJ0000_PARM_I4I.dat | cut -d"=" -f2`
         fi ;;		 
   
   "I17X")
     NORME_RPT="IFRS17" ;;
esac

#===== display header by norm

   if [ "$prevtyp" = "" ] || [ "$prevtyp" != "$normedesc" ]
   then
     prevtyp="$normedesc"

  
     if [ $i -gt 1 ]
     then
        echo "</table>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
     fi 
   
     echo -e "<BR><B><u>$NORME_RPT : $TYPEINV $PARM_CLODAT_D_RPT : </u></B></BR><br>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
   
     echo "<table border=1>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
     echo "<tr bgcolor=#CBCBCB>"    >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
     echo "<td><b>site</b></td><td><b>type</b></td><td><b>empty ssd</b></td><td><b>empty esb</b></td><td><b>empty gaap</b></td><td><b>empty product</b></td><td><b>empty TC</b></td> <td><b>empty dblTC</b></td><td><b>default product</b></td><td><b>LOBACC</b></td><td><b>LOBRET</b></td><td><b>total lines</b></td><td><b>filename</b></td>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
     echo "</tr>"  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
   
   fi
   

#===== display each line data , by file 

  if [ $empty_gaap -gt 0 ]
  then
     empty_gaap_rpt="<font color=red><b>$empty_gaap</b></font>"
  else
     empty_gaap_rpt="$empty_gaap"
  fi
 
   if [ $empty_prd -gt 0 ]
  then
     empty_prd_rpt="<font color=red>$empty_prd</font>"
  else
     empty_prd_rpt="$empty_prd"
  fi
 
  if [ $default_prd -gt 0 ]
  then
     dflt_prd_rpt="<font color=red>$default_prd</font>"
  else
     dflt_prd_rpt="$default_prd"
  fi
 
 echo "<tr>"   >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat 
 echo "<td>${SITE2}</td><td>${filedesc}</td><td>$empty_ssd</td> <td>$empty_esb</td>  <td>$empty_gaap_rpt</td> <td>$empty_prd_rpt</td>  <td>$empty_trncd</td> <td>$empty_dbltrncd</td>  <td>$dflt_prd_rpt</td> <td>$empty_lobacc</td> <td>$empty_lobret</td>  <td>$total</td><td>$permfile</td>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
 echo "</tr>"  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat


done < $ESF_FILELIST_STATS

echo "</table>" >>  $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat


#============= table ratios
typeset -A rat_gaap=(    ['I4I']="" ['LOC']="" ['EBS']="" ['I17G']="" ['I17P']="" ['I17L']="" )
typeset -A rat_prd=(     ['I4I']="" ['LOC']="" ['EBS']="" ['I17G']="" ['I17P']="" ['I17L']="" )
typeset -A rat_trncd=(   ['I4I']="" ['LOC']="" ['EBS']="" ['I17G']="" ['I17P']="" ['I17L']="" )
typeset -A rat_dbltrncd=(['I4I']="" ['LOC']="" ['EBS']="" ['I17G']="" ['I17P']="" ['I17L']="" )
typeset -A rat_dflt=(    ['I4I']="" ['LOC']="" ['EBS']="" ['I17G']="" ['I17P']="" ['I17L']="" )
typeset -A rat_ssd=(     ['I4I']="" ['LOC']="" ['EBS']="" ['I17G']="" ['I17P']="" ['I17L']="" )
typeset -A rat_esb=(     ['I4I']="" ['LOC']="" ['EBS']="" ['I17G']="" ['I17P']="" ['I17L']="" )
typeset -A rat_lobacc=( ['I4I']="" ['LOC']="" ['EBS']="" ['I17G']="" ['I17P']="" ['I17L']="" )
typeset -A rat_lobret=( ['I4I']="" ['LOC']="" ['EBS']="" ['I17G']="" ['I17P']="" ['I17L']="" )

for id in I4I LOC EBS I17G I17P I17L
do

rat_gaap[$id]=`print_ratio100  ${tab_gaap[$id]} ${tab_total[$id]}   ` 
rat_prd[$id]=`print_ratio100  ${tab_prd[$id]} ${tab_total[$id]}   `    
rat_trncd[$id]=`print_ratio100  ${tab_trncd[$id]} ${tab_total[$id]}   `  
rat_dbltrncd[$id]=`print_ratio100  ${tab_dbltrncd[$id]} ${tab_total[$id]}   ` 
rat_dflt[$id]=`print_ratio100  ${tab_dflt[$id]} ${tab_total[$id]}   `    
rat_ssd[$id]=`print_ratio100  ${tab_ssd[$id]} ${tab_total[$id]}   `     
rat_esb[$id]=`print_ratio100  ${tab_esb[$id]} ${tab_total[$id]}   ` 
rat_lobacc[$id]=`print_ratio100  ${tab_lobacc[$id]} ${tab_total[$id]}   ` 
rat_lobret[$id]=`print_ratio100  ${tab_lobret[$id]} ${tab_total[$id]}   ` 

#echo -e "\nrat_gaap $id => ${rat_gaap[$id]} ${rat_prd[$id]}   "
    
done


#==== display HTML table

echo -e "<BR><BR><B><u>TOTAL stats by norm :</u></B></BR><br>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat

echo "<table border=1>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat

echo "<tr bgcolor=#CBCBCB><td><b>norm</b></td><td><b>empty gaap_code</b><td><b>empty prod_code</b></td>  <td><b>empty TC</b></td> <td><b>empty dblTC</b></td> <td><b>default product</b></td><td><b>LOBACC</b></td><td><b>LOBRET</b></td><td><b>total lines</b></td></tr>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat


for id in I4I LOC EBS I17G I17P I17L
do
echo "<tr><td>$id</td> <td>${tab_gaap[$id]} ${rat_gaap[$id]}</td> <td>${tab_prd[$id]} ${rat_prd[$id]}</td><td>${tab_trncd[$id]} ${rat_trncd[$id]}</td> <td>${tab_dbltrncd[$id]} ${rat_dbltrncd[$id]}</td><td>${tab_dflt[$id]} ${rat_dflt[$id]}</td> <td>${tab_lobacc[$id]} ${rat_lobacc[$id]}</td>  <td>${tab_lobret[$id]} ${rat_lobret[$id]}</td>  <td>${tab_total[$id]}</td> </tr>"  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
done

echo "</table>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat



#========== diplay HTML tables with attributes stats 

echo "<BR><BR><table border=0><TR>"  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat

flag_first="Y"
for line in `grep  "^TOTAL_" ${DFILT}/${NJOB}_100_${IB}_CSUOE_PRODUCT.dat `
do
   # file format 
   # 0 =>  TOTAL_LIFE or TOTAL_PC  
   # 1 =>  Missing IFRS17 product 
   # 2 =>  With wrong attributes
   # 3 =>  Without error
   # 4 =>  Porfolio missing I17G
   # 5 =>  Porfolio missing I17P
   # 6 =>  Porfolio missing I17L
   # 7 =>  Profitability missing I17G
   # 8 =>  Profitability missing I17P
   # 9 =>  Profitability missing I17L
   # 10 => Transition approach missing I17G
   # 11 => Transition approach missing I17P
   # 12 => Transition approach missing I17L
   # 13 => With default IFRS17 product
   # 14 => With default attributes
   # 15 => With default porfolio I17G
   # 16 => With default porfolio I17P
   # 17 => With default porfolio I17L
   # 18 => With default profitability I17G
   # 19 => With default profitability I17P
   # 20 => With default profitability I17L
   # 21 => With default transition approach I17G
   # 22 => With default transition approach I17P
   # 23 => With default transition approach I17L
   # 24 => Total CSUOE

  TYP=`echo "$line" | cut -d~ -f1 `
  prd_missing=`echo "$line" | cut -d~ -f2 `
  wrong_attr=`echo "$line" | cut -d~ -f3 `
  without_err=`echo "$line" | cut -d~ -f4 `
  portI17G_miss=`echo "$line" | cut -d~ -f5 `
  portI17P_miss=`echo "$line" | cut -d~ -f6 `
  portI17L_miss=`echo "$line" | cut -d~ -f7 `
  profI17G_miss=`echo "$line" | cut -d~ -f8 `
  profI17P_miss=`echo "$line" | cut -d~ -f9 `
  profI17L_miss=`echo "$line" | cut -d~ -f10 `  
  trnI17G_miss=`echo "$line" | cut -d~ -f11 `
  trnI17P_miss=`echo "$line" | cut -d~ -f12 `
  trnI17L_miss=`echo "$line" | cut -d~ -f13 `
  dflt_prod=`echo "$line" | cut -d~ -f14 `
  dflt_attr=`echo "$line" | cut -d~ -f15 `
  portI17G_dflt=`echo "$line" | cut -d~ -f16 `
  portI17P_dflt=`echo "$line" | cut -d~ -f17 `
  portI17L_dflt=`echo "$line" | cut -d~ -f18 `
  profI17G_dflt=`echo "$line" | cut -d~ -f19 `
  profI17P_dflt=`echo "$line" | cut -d~ -f20 `
  profI17L_dflt=`echo "$line" | cut -d~ -f21 ` 
  trnI17G_dflt=`echo "$line" | cut -d~ -f22 `
  trnI17P_dflt=`echo "$line" | cut -d~ -f23 `
  trnI17L_dflt=`echo "$line" | cut -d~ -f24 `
  total_csuoe=`echo "$line" | cut -d~ -f25 `

  rat_prd_missing=`print_ratio100  $prd_missing $total_csuoe ` 
  rat_wrong_attr=`print_ratio100  $wrong_attr $total_csuoe ` 
  rat_without_err=`print_ratio100  $without_err $total_csuoe N `
  rat_dflt_prod=`print_ratio100  $dflt_prod $total_csuoe `
  rat_dflt_attr=`print_ratio100  $dflt_attr $total_csuoe `


if [ "$TYP" = "TOTAL_LIFE" ]
then
    tabtitle="Life"
	tabcolor="#C7F9C5"
else 
    tabtitle="P&C"
	tabcolor="#CEE1FA"
fi
  
ECHO_LOG "reformat stats : $line "

if [ "$flag_first" = "N" ] 
then
    # empty column to separate 2 tables PC & Life
    echo "<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
fi 


echo "<TD><BR><table border=0><TR bgcolor=$tabcolor><TD><B><font size=4>--------------------------- $tabtitle ---------------------------</B></TD></TR></table>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat


echo "<BR><table border=1>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
echo "<tr><td><B>Contracts attributes (CSUOE)</B></td><td>$total_csuoe</td></tr> " >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
echo "</table>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat 


  echo "<BR><table border=1>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td border=0></td><td bgcolor=$tabcolor>Nb</td><td bgcolor=$tabcolor>%</td> </tr> "  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td>Missing IFRS17 product                </td><td>$prd_missing</td><td>$rat_prd_missing</td></tr> "   >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td>With wrong attributes                 </td><td>$wrong_attr</td> <td>$rat_wrong_attr</td> </tr> "    >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td>Without error                            </td><td>$without_err</td>   <td>$rat_without_err</td>   </tr> "      >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "</table>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat 
  
  echo "<BR><table border=1>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td border=0></td><td bgcolor=$tabcolor>I17G</td><td bgcolor=$tabcolor>I17P</td> <td bgcolor=$tabcolor>I17L</td></tr> "  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td>Missing porfolio</td><td>$portI17G_miss</td><td>$portI17P_miss</td> <td>$portI17L_miss</td></tr> "  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td>Missing profitability</td><td>$profI17G_miss</td><td>$profI17P_miss</td> <td>$profI17L_miss</td></tr> "  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td>Missing transition approach</td><td>$trnI17G_miss</td><td>$trnI17P_miss</td> <td>$trnI17L_miss</td></tr> "  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "</table>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat 

  echo "<br><B>Defaulting</B>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat

  echo "<BR><table border=1>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td border=0></td><td bgcolor=$tabcolor>Nb</td><td bgcolor=$tabcolor>%</td> </tr> "  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td>With default IFRS17 product           </td><td>$dflt_prod</td><td>$rat_dflt_prod</td></tr> " >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td>With default attributes               </td><td>$dflt_attr</td><td>$rat_dflt_attr</td></tr> " >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "</table>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat 


  echo "<BR><table border=1>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td border=0></td><td bgcolor=$tabcolor>I17G</td><td bgcolor=$tabcolor>I17P</td> <td bgcolor=$tabcolor>I17L</td></tr> "  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td>With default porfolio</td><td>$portI17G_dflt</td><td>$portI17P_dflt</td> <td>$portI17L_dflt</td></tr> "  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td>With default profitability</td><td>$profI17G_dflt</td><td>$profI17P_dflt</td> <td>$profI17L_dflt</td></tr> "  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "<tr><td>With default transition approach</td><td>$trnI17G_dflt</td><td>$trnI17P_dflt</td> <td>$trnI17L_dflt</td></tr> "  >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
  echo "</table>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat 
  
  
  echo "</TD>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat 
  
  flag_first="N"

done
echo "</TR></TABLE>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat 



echo -e "<BR><BR><B>The report CSUOE+product is generated on the server :</B><BR>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
wc -l $ESF_CSUOE_PRODUCT >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat

echo -e "<BR><BR><B>The report with all empty data is generated on the server : </B><BR>" >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat
wc -l $ESF_EMPTY_DATA >> $DFILT/${NSTEP}_${IB}_MAIL_REPORT.dat



NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
LIBEL="Mailing to user : $ESF_HTML_REPORT "
INPUT_FILE=$DFILT/${NJOB}_120_${IB}_MAIL_REPORT.dat
OUTPUT_FILE=$ESF_HTML_REPORT
DAT=`date '+%d/%m/%Y %H:%M:%S'`
ECHO_LOG "#"
ECHO_LOG "#========================================================================="
ECHO_LOG "# Begin of step: $NSTEP : Date: $DAT : $LIBEL " 
ECHO_LOG "#========================================================================="



ENVIRONNEMENT=`echo ${SRV} | cut -c1-3 `

case "${ENVIRONNEMENT}" in
        "DEV") Adresse_Liste=$(echo ${MAILTO_DEV} | sed -e 's/;/ /g' | sed -e 's/"//g') ;;
        "PRD") Adresse_Liste=$(echo ${MAILTO_PROD} | sed -e 's/;/ /g' | sed -e 's/"//g') ;;
        *) Adresse_Liste=$(echo ${MAILTO_TEST} | sed -e 's/;/ /g' | sed -e 's/"//g') ;;
esac

ECHO_LOG "ENV=${ENVIRONNEMENT} => choose mails : $Adresse_Liste " 

MAIL_SUBJECT="${URGENT_MSG}${WARNING_MSG}${ENVIRONNEMENT}_${SITE} RA_SAP interface checks - REPORT"
today=`date '+%d/%m/%Y %H:%M:%S' `

> $OUTPUT_FILE

echo  "<HTML><HEAD><style>table,th,td {padding: 10px;border: 1px solid black;border-collapse: collapse;}</style></HEAD><BODY>" >> $OUTPUT_FILE
echo -e "Dear all,<BR>this is the report from chain ESDC0010 run on ${ENVIRONNEMENT} $SITE at $today . <BR>" >>  $OUTPUT_FILE
echo -e $EMPTY >> $OUTPUT_FILE

echo -e "$SAP_RETURN_MSG" >> $OUTPUT_FILE 
cat ${DFILT}/${ENV_PREFIX}_ESDC0010_15_${IB}_RETURN_CHECKS.dat  >> $OUTPUT_FILE

echo -e "$SAP_MSG2" >> $OUTPUT_FILE 

echo -e "<BR><BR>" >> $OUTPUT_FILE

cat $INPUT_FILE >> $OUTPUT_FILE

echo -e "<BR><BR><B>Thanks & Regards</B><BR><BR>" >> $OUTPUT_FILE
echo -e "</BODY></HTML>" >> $OUTPUT_FILE


#-----------------------------------------------------------------
# FUNCTIONS CREATE BODY MAIL
#-----------------------------------------------------------------
BOUNDARY="---boundary$$--"
INIT_MAIL(){
        echo "From: ${SENDER}";
        echo "To: ${Adresse_Liste}";
        echo "Subject: $1";
        echo "MIME-Version: 1.0";
        echo "Content-Type: multipart/mixed; boundary=\"${BOUNDARY}\"";
}

END_MAIL(){
        echo "--${BOUNDARY}--";
}

HTMLBODY_MAIL(){
        echo "--${BOUNDARY}";
        echo "Content-Type: text/html";
        cat $1;
}


SENDER="EST.AUTO.SAPCHECK.REPORT"

#-----------------------------------------------------------------
# Send emails to recipients
#-----------------------------------------------------------------
DAT=`date '+%d/%m/%Y %H:%M:%S' `
ECHO_LOG "# Sending summary email : $OUTPUT_FILE  : Date : $DAT "
ECHO_LOG "# Sender: ${SENDER}"
ECHO_LOG "# Recipient: ${Adresse_Liste}"

#JOBEND

if [ -f $OUTPUT_FILE ] ; then
        (
                INIT_MAIL "${MAIL_SUBJECT}"
                HTMLBODY_MAIL ${OUTPUT_FILE}
                END_MAIL
        ) | sendmail -t
ECHO_LOG " sendmail RCODE = $? "
fi
ECHO_LOG "========================================================================="
ECHO_LOG "#"

NSTEP=${NJOB}_210
#-----------------------------------------------------------------------------
LIBEL="Cleaning DFILI inputs older than $PURGE_DAYS  "
DAT=`date '+%d/%m/%Y %H:%M:%S'`
ECHO_LOG " "
ECHO_LOG "#========================================================================="
ECHO_LOG "# Begin of step: $NSTEP : Date: $DAT : $LIBEL " 
ECHO_LOG "#========================================================================="

cd $DFILI
for fic in `find . -name ${ENV_PREFIX}_ES?D\*_SAP_RETURN_CHECKS.dat -size +0 -mtime +$PURGE_DAYS `
do
	echo "=== clean file=$fic === "
	> $fic
done
cd -


NSTEP=${NJOB}_220
# ARCHIVAGE
#----------------------------------------------------------------------------
LIBEL="detect IBNR bug spira 111574/109805"

ECHO_LOG " " 
ECHO_LOG "#=========================================================================" 
ECHO_LOG "# Begin of step: $NSTEP : $LIBEL " 

if [ -s "$ESL_FTECLEDALO" ]; then

    found=`grep FA0022495 $ESL_FTECLEDALO | grep "14494162\|14494132" | wc -l `
	
	if [ $found -gt 0 ]; then
		ECHO_LOG "$found record(s) found for contract FA0022495 , need to push an urgent mail" 

		
		MAIL_SUBJECT="${ENVIRONNEMENT} : VERY URGENT : LOCAL IBNR bug detected, check temporary files before the next closing"
		today=`date '+%d/%m/%Y %H:%M:%S' `

		OUTPUT_FILE=${DFILT}/${ENV_PREFIX}_${NSTEP}_MAIL.dat
		> $OUTPUT_FILE 
		echo  "<HTML><HEAD><style>table,th,td {padding: 10px;border: 1px solid black;border-collapse: collapse;}</style></HEAD><BODY>" >> $OUTPUT_FILE
		echo -e "Dear all,<BR>this is the report from chain ESDC0010 run on ${ENVIRONNEMENT} $SITE at $today . <BR><br>" >>  $OUTPUT_FILE
		echo -e "There is probably a bug, having LOCAL data for the contract FA0022495 (TC 14494162 or 14494132) into $ESL_FTECLEDALO . <BR> " >> $OUTPUT_FILE
		echo -e "<b><font color=red>Please check temporary/perm files before the next closing !!!</font></b> <BR> " >> $OUTPUT_FILE

		echo -e "<br> This is a specific alert implemented for spiras 111574/109805 . <BR> " >> $OUTPUT_FILE


		echo -e "<BR><BR>Thanks & Regards<BR><BR>" >> $OUTPUT_FILE

		
		#-----------------------------------------------------------------
		# Send emails to recipients
		#-----------------------------------------------------------------
		DAT=`date '+%d/%m/%Y %H:%M:%S' `
		ECHO_LOG "# Sending summary email : $OUTPUT_FILE  : Date : $DAT "
		ECHO_LOG "# Sender: ${SENDER}"
		ECHO_LOG "# Recipient: ${Adresse_Liste}"

		if [ -f $OUTPUT_FILE ] ; then
				(
						INIT_MAIL "${MAIL_SUBJECT}"
						HTMLBODY_MAIL ${OUTPUT_FILE}
						END_MAIL
				) | sendmail -t
		ECHO_LOG " sendmail RCODE = $? "
		fi
		ECHO_LOG "========================================================================="
		ECHO_LOG "#"


	fi
else
    echo "no data to check"
fi

# END Of Job
#------------------------------------------------------------------------------
JOBEND

