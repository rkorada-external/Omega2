#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 EBS : Spira 88638
# Revision                      : $Revision:   1.0  $
# Date de creation              : 06/10/2020
# Auteur                        : Linh.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#       [001]           06/10/2020      L.DOAN         SPIRA : 88638  		SAP feedback 
#       [002]           01/02/2020      L.DOAN         SPIRA : 91998            SAP EBS
#[003] 15/12/2021 R.CASSIS :spira:101117 Ajout des fichiers REJ et OPNG EBS
#[004] 15/03/2023 DaD      :spira:109219 Exclusion on groupings 900/100 and 900/900
#[005] 27/11/2023 JYP      :spira:110891 exclude some TC I17G into IFRS4, update mail SAP warnings
#[006] 04/12/2023 JYP      :spira:110602 exclude some gaap_code without digit 1
#[007] 06/12/2023 JYP      :spira:110602 keep empty gaap_code 
#[008] 15/12/2023 JYP      :spira:110086 new SAP filter based on SAP table
#[009] 10/01/2023 JYP      :spira:110086 new SAP filter based on SAP table, rule option2
#[010] 12/12/2024 JYP      :spira:110086 new SAP filter based on SAP table, bugfix
#[011] 16/04/2024 JYP      :spira:111526 EBS- Accept grouping 100
#[012] 03/09/2024 JYP      :spira:111995 complete filter rules, avoid wrong warnings ESDC0010 
#[013] 29/10/2024 JYP      :spira:111995 complete filter rules 
#[014] 08/11/2024 JYP      :spira:111995 complete filter rules 
#[015] 08/07/2025 JYP      :spira 113075 SERQS split files by site
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd


#CLODAT_D=${PARM_ICLODAT_D}
CLODAT_D=${PARM_CRE_D}

# Job Initialisation
JOBINIT


ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ENV_SAP............................................................: ${ENV_SAP}"
ECHO_LOG "#===> SAP_GAAPFILTER_FLAG................................................: ${SAP_GAAPFILTER_FLAG}"
ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> ESF_FTECLEDA_MVT_LOCALSIT .........................................: ${ESF_FTECLEDA_MVT_LOCALSIT}"
ECHO_LOG "#===> ESF_FTECLEDA_REJ...................................................: ${ESF_FTECLEDA_REJ}"
ECHO_LOG "#===> ESF_FTECLEDA_OPNG..................................................: ${ESF_FTECLEDA_OPNG}"
ECHO_LOG "#===> ESF_SAP_GAAPS_FILTER...............................................: ${ESF_SAP_GAAPS_FILTER}"
ECHO_LOG "#===> ESF_SAP_SETUP_IGNORED .............................................: ${ESF_SAP_SETUP_IGNORED}"
ECHO_LOG "#===> ............ OUTPUT ................................................"
ECHO_LOG "#===> ESF_FTECLEDA_MVT_LOCALSIT .........................................: ${ESF_FTECLEDA_MVT_LOCALSIT}"
ECHO_LOG "#===> EPO_FTECLEDA_RMN ..................................................: ${EPO_FTECLEDA_RMN}"
ECHO_LOG "#===> ESF_SAP_SETUP_MISSING .............................................: ${ESF_SAP_SETUP_MISSING}"
ECHO_LOG "#===> ESF_SAP_RETURN_CHECKS .............................................: ${ESF_SAP_RETURN_CHECKS}"
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_01
#-----------------------------------------------------------------
LIBEL="initialize touch missing files "
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "$NSTEP : $LIBEL "


if [ ! -f ${ESF_FTECLEDA_REJ} ]
then
	touch ${ESF_FTECLEDA_REJ} ${ESF_FTECLEDR_REJ}
fi

if [ ! -f ${ESF_FTECLEDA_OPNG} ]
then
	touch ${ESF_FTECLEDA_OPNG} ${ESF_FTECLEDR_OPNG}
fi

if [ -n "$ESF_SAP_SETUP_IGNORED" ] && [[ ! -f "${ESF_SAP_SETUP_IGNORED}"  ]]
then
	EXECKSH_MODE=P
	EXECKSH "touch $ESF_SAP_SETUP_IGNORED "
fi

ls -ltr $ESF_FTECLEDA_REJ $ESF_FTECLEDR_REJ $ESF_FTECLEDA_OPNG $ESF_FTECLEDR_OPNG $ESF_SAP_SETUP_IGNORED 


NSTEP=${NJOB}_03
#-----------------------------------------------------------------
LIBEL="initialize SAP checks files I4I"
if [ "$NORME_CF" = "I4I" ]
then 
	EXECKSH_MODE=P
	EXECKSH "> $ESF_SAP_RETURN_CHECKS "
fi 

NSTEP=${NJOB}_05
#-----------------------------------------------------------------
LIBEL="check if setup from SAP should be used : ESF_SAP_GAAPS_FILTER=$ESF_SAP_GAAPS_FILTER "
nb_setup=0
if [ -s "$ESF_SAP_GAAPS_FILTER" ] && [ "$SAP_GAAPFILTER_FLAG" = "Y" ] 
then 
    nb_setup=`wc -l $ESF_SAP_GAAPS_FILTER  | cut -d" " -f1 `
fi 

if [ $nb_setup -lt 4 ] 
then 
	ESF_SAP_GAAPS_FILTER="$DFILP/empty.dat"
fi 

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "$NSTEP : $LIBEL "
ECHO_LOG "running with SAP setup : $ESF_SAP_GAAPS_FILTER   : nb_setup = $nb_setup  "
ECHO_LOG "#========================================================================="
ECHO_LOG ""



#Chaine vide
#[004]
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Sort ${EPO_FTRSLNK_640_TXT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTRSLNK_640_TXT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_900_100.dat 2000 1 "
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTRSLNK_EBS.dat 2000 1 "
SORT_O3="${DFILT}/${NSTEP}_${IB}_FTRSLNK_EBS_900_100.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS PRS_CF       1:1 -  1:,
        ACMTRS_NT        2:1 -  2:,
        DETTRS_CF        3:1 -  3:
/KEYS
        PRS_CF,
        ACMTRS_NT,
        DETTRS_CF
/CONDITION SORT_DATA ( PRS_CF = "900" and ( ACMTRS_NT = "100" OR ACMTRS_NT = "900" ))
/CONDITION IS_EBS    ( PRS_CF = "640" and ( ACMTRS_NT = "400" OR ACMTRS_NT = "100" ))
/CONDITION BOTH_COND ((PRS_CF = "900" and ( ACMTRS_NT = "100" OR ACMTRS_NT = "900" )) OR ( PRS_CF = "640" and ( ACMTRS_NT = "400" OR ACMTRS_NT = "100" ) ) )
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE SORT_DATA
/OUTFILE ${SORT_O2} OVERWRITE
/INCLUDE IS_EBS
/OUTFILE ${SORT_O3} OVERWRITE
/INCLUDE BOTH_COND
exit
EOF
SORT


# WE REMOVE 900-100 FROM FILE -> FOR 02/SAP INTERFACE, FOR I17*
NSTEP=${NJOB}_15
#------------------------------------------------------------------------------------
LIBEL="remove FTECLEDA TCODE 900-100 for 02/SAP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_MVT_LOCALSIT} 2000 1"
SORT_I2="${ESF_FTECLEDA_REJ} 2000 1"
SORT_I3="${ESF_FTECLEDA_OPNG} 2000 1"
if [  ${NORME_CF} = "EBS" ]
then
SORT_O="${DFILT}/${NSTEP}_${IB}_ESF_FTECLEDA_GLT_MVT_EBS.dat 2000 1"
else
SORT_O="${DFILT}/${NJOB}_${IB}_ESF_FTECLEDA_GLT_MVT.dat 2000 1"
fi
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        DETTRS_CF               3:1 -  3:,
        GLT_TRNCOD_CF           6:1 -  6:,
        GLT_ALL                 1:1 -  118:
/joinkeys 
        GLT_TRNCOD_CF
/INFILE "${DFILT}/${NJOB}_10_${IB}_FTRSLNK_900_100.dat" 2000 1 "~"
/joinkeys 
        DETTRS_CF
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GLT_ALL
exit
EOF
SORT


NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="RMN FILE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_MVT_LOCALSIT} 2000 1"
SORT_I2="${ESF_FTECLEDA_REJ} 2000 1"
SORT_I3="${ESF_FTECLEDA_OPNG} 2000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_FTECLEDA_REMAIN.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        DETTRS_CF               3:1 -  3:,
        GLT_TRNCOD_CF           6:1 -  6:,
        GLT_ALL                 1:1 -  118:
/joinkeys 
        GLT_TRNCOD_CF
/INFILE "${DFILT}/${NJOB}_10_${IB}_FTRSLNK_900_100.dat" 2000 1 "~"
/joinkeys 
        DETTRS_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GLT_ALL
exit
EOF
SORT


if [ ${NORME_CF} = "EBS" ]
then
#[003]
NSTEP=${NJOB}_25
#------------------------------------------------------------------------------------
LIBEL="remove FTECLEDA EBS GTL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_MVT_LOCALSIT} 2000 1"
SORT_I2="${ESF_FTECLEDA_REJ} 2000 1"
SORT_I3="${ESF_FTECLEDA_OPNG} 2000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_FTECLEDA_REMAIN.dat APPEND 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        DETTRS_CF               3:1 -  3:,
        GLT_TRNCOD_CF           6:1 -  6:,
        GLT_ALL                 1:1 -  118:
/joinkeys 
        GLT_TRNCOD_CF
/INFILE "${DFILT}/${NJOB}_10_${IB}_FTRSLNK_EBS_900_100.dat" 2000 1 "~"
/joinkeys 
        DETTRS_CF
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT
        leftside :GLT_ALL
exit
EOF
SORT

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------------
LIBEL="extract FTECLEDA EBS/I17 Common GTL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESF_FTECLEDA_GLT_MVT_EBS.dat 2000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_ESF_FTECLEDA_GLT_MVT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        DETTRS_CF               3:1 -  3:,
        GLT_TRNCOD_CF           6:1 -  6:,
        GLT_ALL                 1:1 -  118:
/joinkeys 
        GLT_TRNCOD_CF
/INFILE "${DFILT}/${NJOB}_10_${IB}_FTRSLNK_EBS.dat" 2000 1 "~"
/joinkeys 
        DETTRS_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GLT_ALL
exit
EOF
SORT
fi


NSTEP=${NJOB}_35
#------------------------------------------------------------------------------------
LIBEL="add SAP setup ESF_SAP_GAAPS_FILTER=$ESF_SAP_GAAPS_FILTER "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_${IB}_ESF_FTECLEDA_GLT_MVT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESF_FTECLEDA_GLT_MVT_SAP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        SSD_CF                          1:1 - 1:,
        ESB_CF                          2:1 - 2:,
		GLT_ALL                         1:1 - 118:,
        GAAPCOD_SAP                     3:1 - 3:EN
/joinkeys 
		SSD_CF,        
		ESB_CF		
/INFILE "${ESF_SAP_GAAPS_FILTER}" 1000 1 "~"
/joinkeys 
		SSD_CF,        
		ESB_CF	
/JOIN UNPAIRED LEFTSIDE		
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GLT_ALL , rightside:GAAPCOD_SAP
exit
EOF
SORT




NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="add status for exclusion or not "
AWK_I=${DFILT}/${NJOB}_35_${IB}_ESF_FTECLEDA_GLT_MVT_SAP.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_FTECLEDA_EXCLUDED_STATUS.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
function ABS(x) { if (x < 0) return -x; else return x }
BEGIN{ FS="\~"; OFS="~"; }
{
   TRACE="~OK";
			
   if ( substr(\$6,8,1) == "I" && "$NORME_CF" == "I4I"  )
   {
     TRACE="~EXCLUDE_I17G";
   }
   else if ( \$111 !~ /1/ && \$111 != "" ) 
   {
        TRACE="~EXCLUDE_GAAP_NOT1";
   } 
   else if ( ABS(\$35) == 0 && ABS(\$88) == 0 && ABS(\$19) == 0 ) 
   { 
   	TRACE="~EXCLUDE_AMOUNT0";
   }    
   else if ( ((\$24 == "17P000028" || \$24 == "17P000037" || \$24 == "17P000038" || \$24 == "17P000039" || \$24 == "17P000052" || \$24 == "17P000055" ||
			         \$24 == "17P000056" || \$24 == "17P000058" || \$24 == "17P000059" || \$24 == "17P000060" || \$8  == "17ZF35062" || \$8  == "17ZF41634" ||
			         \$8  == "17ZF41638" || \$8  == "17ZF41639" || \$8  == "17ZF41640" || \$8  == "17ZF41641" || \$8  == "17ZF41644" || \$8  == "17ZF41645" ||
			         \$8  == "17ZF41646" || \$8  == "17ZF41647" || \$8  == "17ZF41653" || \$8  == "17ZF41654" || \$8  == "17ZF41787" || \$8  == "17ZF47945" ||
			         \$8  == "17ZF47946") ||
			        (\$6 == \$7 ) ) )
   {
        TRACE="~EXCLUDE_HARDCODED";
   }    
   else if ( \$119 != "" && \"${SAP_GAAPFILTER_FLAG}\" == "Y" ) 
   {
    gaap_len = length(\$111);
    SAPlen   = length(\$119);
	split(\$111, TAB_gaap , "") ;
	split(\$119, TAB_SAP  , "") ;
	TRACE="~EXCLUDE_SAP_TABLE";

    if ( gaap_len <= SAPlen ) 
	{
	   for (i=gaap_len ; i >= 1 ; i--) 
	   {
	       if ( TAB_gaap[i] == "1" && TAB_SAP[i + SAPlen-gaap_len] == "1" )
           {
		   TRACE="~OK";break;
           }		   
	   }
	}
	else
	{
	   for (i=SAPlen ; i >= 1 ; i--) 
	   {
	       if ( TAB_gaap[i + gaap_len-SAPlen] == "1" && TAB_SAP[i] == "1" )
           {
		   TRACE="~OK";break;
           }		   
	   }	
	}
   } 
   else if ( \$119 == "" && \"${SAP_GAAPFILTER_FLAG}\" == "Y" ) 
   { 
   	TRACE="~SAP_SETUP_MISSING";
   }   
   else 
   {
	TRACE="~OK";
   }   
   print \$0 TRACE ;
}
exit
EOF
cat $AWK_CMD > ${DFILT}/${NSTEP}_${IB}_AWK_SCRIPT.dat
AWK


NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="split by each status"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_FTECLEDA_EXCLUDED_STATUS.dat 2000 1"
SORT_O="${ESF_FTECLEDA_MVT_LOCALSIT} 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTECLEDA_REMAIN_I17G_ERROR.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_FTECLEDA_REMAIN_NOT1.dat 2000 1"
SORT_O4="${DFILT}/${NSTEP}_${IB}_FTECLEDA_REMAIN_SAPTABLE.dat 2000 1"
SORT_O5="${DFILT}/${NSTEP}_${IB}_FTECLEDA_REMAIN_SAP_MISSING.dat 2000 1"
SORT_O6="${DFILT}/${NSTEP}_${IB}_FTECLEDA_REMAIN_HARDCODED.dat 2000 1"
SORT_O7="${DFILT}/${NSTEP}_${IB}_FTECLEDA_REMAIN_AMOUNT0.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS STATUS          120:1 - 120:,
        118_FIELDS      1:1 - 118:
/CONDITION COND_I17G_ERROR (STATUS = "EXCLUDE_I17G")
/CONDITION COND_1NOTFOUND  (STATUS = "EXCLUDE_GAAP_NOT1")
/CONDITION COND_SAP_TABLE  (STATUS = "EXCLUDE_SAP_TABLE")
/CONDITION COND_SAP_MISSING (STATUS = "SAP_SETUP_MISSING")
/CONDITION COND_HARDCODED  (STATUS = "EXCLUDE_HARDCODED")
/CONDITION COND_AMOUNT0    (STATUS = "EXCLUDE_AMOUNT0")
/CONDITION COND_MVT_OK     (STATUS = "OK")
/OUTFILE ${SORT_O} overwrite
/INCLUDE COND_MVT_OK
/REFORMAT 118_FIELDS
/OUTFILE ${SORT_O2} overwrite
/INCLUDE COND_I17G_ERROR
/REFORMAT 118_FIELDS
/OUTFILE ${SORT_O3} overwrite
/INCLUDE COND_1NOTFOUND
/REFORMAT 118_FIELDS
/OUTFILE ${SORT_O4} overwrite
/INCLUDE COND_SAP_TABLE
/REFORMAT 118_FIELDS
/OUTFILE ${SORT_O5} overwrite
/INCLUDE COND_SAP_MISSING
/REFORMAT 118_FIELDS
/OUTFILE ${SORT_O6} overwrite
/INCLUDE COND_HARDCODED
/REFORMAT 118_FIELDS
/OUTFILE ${SORT_O7} overwrite
/INCLUDE COND_AMOUNT0
/REFORMAT 118_FIELDS
exit
EOF
SORT
			

NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="MERGE ALL REMAINS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_${IB}_FTECLEDA_REMAIN.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_60_${IB}_FTECLEDA_REMAIN_I17G_ERROR.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_60_${IB}_FTECLEDA_REMAIN_NOT1.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_60_${IB}_FTECLEDA_REMAIN_SAPTABLE.dat 2000 1"
SORT_I5="${DFILT}/${NJOB}_60_${IB}_FTECLEDA_REMAIN_SAP_MISSING.dat 2000 1"
SORT_I6="${DFILT}/${NJOB}_60_${IB}_FTECLEDA_REMAIN_HARDCODED.dat 2000 1"
SORT_O="${EPO_FTECLEDA_RMN} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GAAPCOD_NF          111:1 - 111:
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT

#------- IFRS4 warning 
if [ "$NORME_CF" = "I4I" ]
then 
	wc -l ${DFILT}/${NJOB}_60_${IB}_FTECLEDA_REMAIN_I17G_ERROR.dat > $ESF_SAP_RETURN_CHECKS
	cat ${DFILT}/${NJOB}_60_${IB}_FTECLEDA_REMAIN_I17G_ERROR.dat >> $ESF_SAP_RETURN_CHECKS
fi 

cat ${DFILT}/${NJOB}_60_${IB}_FTECLEDA_REMAIN_SAP_MISSING.dat | cut -d~ -f1,2 | sort -u >> $FLOG


NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="exclude wrong warnings "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_FTECLEDA_REMAIN_SAP_MISSING.dat  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_REMAIN_SAP_MISSING.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        SSD_CF                          1:1 - 1:,
        ESB_CF                          2:1 - 2:,
        TRNCD_CF                        6:1 - 6:,
		TRNCD_CF_IGNORED                3:1 - 3:,
		ALL_FIELDS                      1:1 - 118:
/joinkeys
        SSD_CF,
        ESB_CF,
        TRNCD_CF
/INFILE $ESF_SAP_SETUP_IGNORED  2000 1 "~"
/joinkeys
        SSD_CF,
        ESB_CF,
        TRNCD_CF_IGNORED
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_FIELDS
exit
EOF
SORT


#------- Missing setup SSD/ESB , for email ESDC0010
wc -l ${DFILT}/${NJOB}_80_${IB}_FTECLEDA_REMAIN_SAP_MISSING.dat > $ESF_SAP_SETUP_MISSING
cat ${DFILT}/${NJOB}_80_${IB}_FTECLEDA_REMAIN_SAP_MISSING.dat | cut -d~ -f1,2 | sort -u  >> $ESF_SAP_SETUP_MISSING
 


JOBEND

