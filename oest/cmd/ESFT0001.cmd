#!/bin/ksh
#===================================================================================================================
# APPLICATION NAME          		: TRANSITION
# JOB NAME             				: ESFT0001.cmd
# REVISION                     		: 1.0 
# CREATION DATE              		: 22/04/2020
# AUTHOR                        	: L.ELFAHIM
#===================================================================================================================
#-------------------------------------------------------------------------------------------------------------------
# DESCRIPTION - SPIRA 86487 - TRANSITION MANAGEMENT :
#
#-------------------------------------------------------------------------------------------------------------------
# CHANGES HISTORY :
#===================================================================================================================
#	22/04/2020	LEL	 	SPIRA : 86487	DEVELOPMENT OF INITIAL VERSION
#	27/04/2020	LEL		SPIRA : 84496	FORCE EXPIRY DATE PERICASE RETRO NP 
#	28/04/2020	LEL		SPIRA : 84240	PREPARE CSF FILE FOR TRANSITION PURPOSE
#	19/05/2020	LEL		SPIRA : 86487	TAKE INTO ACCOUNT EGPI FROM TRANSITION FILE
#	12/06/2020	JYP		SPIRA : 84240	Add LR into IADPERICASE for FUTURES Assumed
# 	12/06/2020 	LEL    	SPIRA : 82714 	ENRICHMENT OF ESF_FRERETFACCTR_INI BY REF QUARTER
#  	06/07/2020 	JYP  	SPIRA : 82718  	IRDPERICASE0_PNP contains retroP retroNP
#  	13/10/2020 	LEL  	SPIRA : 86487  	UPDATE COLUMN POSITIONS TO FIT NEW TRANSITION FILE FORMAT
#  	29/01/2021 	LEL  	SPIRA : 90059  	CHANGE FORMAT OF FILE ESF_FRERETFACCTR_INI
#  	29/01/2021 	JYP  	SPIRA : 90059  	CHANGE FORMAT OF FILE ESF_FRERETFACCTR_INI
#  	22/03/2021 	LEL  	SPIRA : 94971  	MANAGE RATEINDEX RETRO P && NP
#  	07/09/2021 	JYP  	SPIRA : 97976  	add rule for retro with section missing
#  	10/01/2022 	MZM  	SPIRA : 91532  	Bug Fix : Taille Syncsort de 1000 ==> 2000
#  	14/04/2022 	JYP  	SPIRA : 103597  transition ALL PERICASE SSD/ESB issue
#		05/07/2022	JBD		SPIRA : 104778	Build new closing for I17S norm 
#===================================================================================================================



#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Get input parameters
ICLODAT_D=$1
TYPEINV=$2
CRE_D=$3

ECHO_LOG ""                                                                                  
ECHO_LOG "#==============================================================================================="                                  
ECHO_LOG "#===> NORME .......................................: ${NORME}"                                                                                  
ECHO_LOG "#===> IDF_CT ......................................: ${IDF_CT}" 
ECHO_LOG "#===> NORME_CF ....................................: ${NORME_CF}"  
ECHO_LOG "#===> CONTEXT_CT ..................................: ${CONTEXT_CT}"                             
ECHO_LOG "#===> PARM_ICLODAT_D ..............................: ${PARM_ICLODAT_D}"                                                         
ECHO_LOG "#....................... INPUTS ................................................................"  
ECHO_LOG "#===> EPO_IADPERICASE .............................: ${EPO_IADPERICASE}"
ECHO_LOG "#===> EPO_IRDPERICASE0 ............................: ${EPO_IRDPERICASE0}"   
ECHO_LOG "#===> EPO_IRDPERICASE0_EBS ........................: ${EPO_IRDPERICASE0_EBS}"       
ECHO_LOG "#===> TRANSITION_DATA .............................: ${TRANSITION_DATA}" 
ECHO_LOG "#===> ESF_FRERETFACCTR_INI ........................: ${ESF_FRERETFACCTR_INI}" 
ECHO_LOG "#===> ESF_IADVPERICASE_P ..........................: ${ESF_IADVPERICASE_P}"                   
ECHO_LOG "#....................... OUTPUT ................................................................"  
ECHO_LOG "#===> ESF_IADPERICASE_TRN .........................: ${ESF_IADPERICASE_TRN}"
ECHO_LOG "#===> ESF_IRDPERICASE0_TRN ........................: ${ESF_IRDPERICASE0_TRN}" 
ECHO_LOG "#===> ESF_IRDPERICASE0_PNP_TRN ....................: ${ESF_IRDPERICASE0_PNP_TRN}" 
ECHO_LOG "#===> ESF_FRERETFACCTR_INI_TRN ....................: ${ESF_FRERETFACCTR_INI_TRN}"
ECHO_LOG "#===> ESF_IRDPERICASE0_P_TRN ......................: ${ESF_IRDPERICASE0_P_TRN}" 
ECHO_LOG "#===============================================================================================" 

NSTEP=${NJOB}_10
LIBEL="SPIRA : 82710 - PERICASE PREPARATION : JOIN IADPERICASE && TRANSITION FILE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 2000 1"
SORT_O="${ESF_IADPERICASE_TRN} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	PER_SSD_CF      1:1  	-  1:,
	PER_ACCESB_CF   8:1     -  8:,
	PER_CTR_NF      3:1  	-  3:,
	PER_END_NT      4:1  	-  4:,
	PER_SEC_NF      5:1  	-  5:,
	PER_UWY_NF      6:1  	-  6:,
	PER_UW_NT       7:1  	-  7:,
	SSD_CF          1:1     -  1:,
	ESB_CF          2:1     -  2:,	
	CTR_NF          3:1  	-  3:,
	SEC_NF          4:1  	-  4:,
	UWY_NF          5:1  	-  5:,
	UW_NT           6:1  	-  6:,
	END_NT          7:1  	-  7:,
	EGPI_TRN		14:1	-  14:,
	EGPI_CUR_TRN	15:1	-  15:,
	UW_LR			18:1	-  18:,
	REF_Q_TRN		23:1	-  23:,
	PRICED_LR		21:1	-  21:,
	PRICED_FLG		22:1	-  22:,
	FILLER1			1:1		-  22:,
	FILLER2			24:1	-  74:,
	FILLER3			76:1	-  150:,
	FILLER4			152:1	-  200:,
	FILLER5			203:1	-  207:
/JOINKEYS
	SSD_CF,
	ESB_CF,
	CTR_NF,    
	END_NT,    
	SEC_NF,    
	UWY_NF,    
	UW_NT     	
/INFILE ${EPO_IADPERICASE} 2000 1 "~"
/JOINKEYS
	PER_SSD_CF   ,
	PER_ACCESB_CF,
	PER_CTR_NF,  
	PER_END_NT,  
	PER_SEC_NF,  
	PER_UWY_NF,
	PER_UW_NT
/OUTFILE  ${SORT_O}
/REFORMAT
	RIGHTSIDE:FILLER1,
	LEFTSIDE:EGPI_CUR_TRN,
	RIGHTSIDE:FILLER2,
	LEFTSIDE:EGPI_TRN,
	RIGHTSIDE:FILLER3,
	LEFTSIDE:UW_LR,
	RIGHTSIDE:FILLER4,
	LEFTSIDE:PRICED_FLG,PRICED_LR,
	RIGHTSIDE:FILLER5,
	LEFTSIDE:REF_Q_TRN
exit
EOF
SORT

# STEP TO BE LAUNCHED ONLY FOR INI
if [ "${CONTEXT_CT}" = "INI" ]
then
NSTEP=${NJOB}_20
LIBEL="SPIRA 84496 - RETRO NP FUTURE CALCULATION : FORCE EXPIRY DATE TO 31/12/2999 ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IRDPERICASE0} 2000 1"
SORT_O="${DFILT}/${NJOB}_${IB}_IRDPERICASE.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	PER_CTR_NF      3:1     -  3:,
	PER_END_NT      4:1     -  4:,
	PER_SEC_NF      5:1     -  5:,
	PER_UWY_NF      6:1     -  6:,
	PER_UW_NT       7:1     -  7:,
	FILLER1         1:1     -  27:,
	FILLER2         29:1    -  207:
/DERIVEDFIELD CTREXP_D "29991231~"
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	FILLER1,
	CTREXP_D,
	FILLER2
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_25
LIBEL="SPIRA : 82710 - PERICASE PREPARATION: JOIN PERICASE RETRO NP && TRANSITION FILE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 2000 1"
SORT_O="${ESF_IRDPERICASE0_TRN} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	PER_SSD_CF      1:1  	-  1:,
	PER_ACCESB_CF   8:1     -  8:,
	PER_CTR_NF      3:1  	-  3:,
	PER_END_NT      4:1  	-  4:,
	PER_SEC_NF      5:1  	-  5:,
	PER_UWY_NF      6:1  	-  6:,
	PER_UW_NT       7:1  	-  7:,
	SSD_CF          1:1     -  1:,
	ESB_CF          2:1     -  2:,		
	CTR_NF          3:1  	-  3:,
	SEC_NF          4:1  	-  4:,
	UWY_NF          5:1  	-  5:,
	UW_NT           6:1  	-  6:,
	END_NT          7:1  	-  7:,
	PRICE_LR_TRN	21:1	-  21:,
	REF_Q_TRN		23:1	-  23:,
	FILLER1			1:1		-  201:,
	FILLER2			203:1	-  224:
/JOINKEYS
	SSD_CF,   
	ESB_CF,   
	CTR_NF,    
	END_NT,    
	SEC_NF,    
	UWY_NF,    
	UW_NT     	
/INFILE ${DFILT}/${NJOB}_${IB}_IRDPERICASE.dat 2000 1 "~"
/JOINKEYS
	PER_SSD_CF   ,
	PER_ACCESB_CF,
	PER_CTR_NF,  
	PER_END_NT,  
	PER_SEC_NF,  
	PER_UWY_NF,
	PER_UW_NT
/OUTFILE  ${SORT_O}
/REFORMAT
	RIGHTSIDE:FILLER1,
	LEFTSIDE:PRICE_LR_TRN,
	RIGHTSIDE:FILLER2,
	LEFTSIDE:REF_Q_TRN
exit
EOF
SORT

else
NSTEP=${NJOB}_30
LIBEL="SPIRA : 82710 - PERICASE PREPARATION: JOIN PERICASE RETRO NP && TRANSITION FILE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 2000 1"
SORT_O="${ESF_IRDPERICASE0_TRN} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	PER_SSD_CF      1:1  	-  1:,
	PER_ACCESB_CF   8:1     -  8:,
	PER_CTR_NF      3:1  	-  3:,
	PER_END_NT      4:1  	-  4:,
	PER_SEC_NF      5:1  	-  5:,
	PER_UWY_NF      6:1  	-  6:,
	PER_UW_NT       7:1  	-  7:,
	SSD_CF          1:1     -  1:,
	ESB_CF          2:1     -  2:,	
	CTR_NF          3:1  	-  3:,
	SEC_NF          4:1  	-  4:,
	UWY_NF          5:1  	-  5:,
	UW_NT           6:1  	-  6:,
	END_NT          7:1  	-  7:,
	REF_QUARTER		23:1	-  23:,
	FILLER			1:1		-  224:
/JOINKEYS
	SSD_CF ,
	ESB_CF ,
	CTR_NF,    
	END_NT,    
	SEC_NF,    
	UWY_NF,    
	UW_NT     	
/INFILE ${EPO_IRDPERICASE0} 2000 1 "~"
/JOINKEYS
	PER_SSD_CF    ,
	PER_ACCESB_CF ,
	PER_CTR_NF,  
	PER_END_NT,  
	PER_SEC_NF,  
	PER_UWY_NF,
	PER_UW_NT
/OUTFILE  ${SORT_O}
/REFORMAT 
	RIGHTSIDE:FILLER,
	LEFTSIDE:REF_QUARTER
exit
EOF
SORT
fi

NSTEP=${NJOB}_35
LIBEL="FILTER ESF_FRERETFACCTR_INI : RETRO && ASSUMED ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FRERETFACCTR_INI} 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RETRO_FRERETFACCTR.dat 500 1"
SORT_O1="${DFILT}/${NSTEP}_${IB}_ASSUMED_FRERETFACCTR.dat 500 1"
SORT_NOINFILE=YES
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	TYPE_CTR      	9:1 	- 9:,
	FILLER   		1:1  	- 20:															
/CONDITION RETRO 	TYPE_CTR = 'R' 
/CONDITION ASSUMED	TYPE_CTR != 'R' 
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE RETRO
/OUTFILE ${SORT_O1} OVERWRITE
/INCLUDE ASSUMED
/COPY      
exit
EOF
SORT

NSTEP=${NJOB}_40
LIBEL="TRANSITION PURPOSE I17G : ADD REFERENCE QUARTER TO ESF_FRERETFACCTR ASSUMED"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ASSUMED_FRERETFACCTR_JOINED.dat 500 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF          3:1  	-  3:,
	SEC_NF          4:1  	-  4:,
	UWY_NF          5:1  	-  5:,
	UW_NT           6:1  	-  6:,
	END_NT          7:1  	-  7:,
	RAT_CTR_NF  	1:1  	-  1:,
	RAT_END_NT  	2:1  	-  2:,
	RAT_SEC_NF  	3:1  	-  3:,
	RAT_UWY_NF		4:1  	-  4:,
	RAT_UW_NT		5:1  	-  5:,
	RAT_INDEX		26:1	-  26:,
	FILLER1			1:1		-  5:,
	FILLER2			7:1		-  20:
/JOINKEYS
	CTR_NF,    
	END_NT,    
	SEC_NF,    
	UWY_NF,    
	UW_NT     
/INFILE ${DFILT}/${NJOB}_35_${IB}_ASSUMED_FRERETFACCTR.dat 500 1 "~"
/JOINKEYS
	RAT_CTR_NF,  
	RAT_END_NT,  
	RAT_SEC_NF,  
	RAT_UWY_NF,
	RAT_UW_NT	
/OUTFILE  ${SORT_O}
/REFORMAT   
	RIGHTSIDE:FILLER1,
	LEFTSIDE:RAT_INDEX,
	RIGHTSIDE:FILLER2
exit
EOF
SORT


NSTEP=${NJOB}_41
LIBEL="RATEINDEX retro : RETRO list with all section"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RETRO_FRERETFACCTR_ALLSEC.dat 500 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF          3:1  	-  3:,
	SEC_NF          4:1  	-  4:,
	UWY_NF          5:1  	-  5:,
	UW_NT           6:1  	-  6:,
	END_NT          7:1  	-  7:,
	RAT_CTR_NF  	1:1  	-  1:,
	RAT_END_NT  	2:1  	-  2:,
	RAT_SEC_NF  	3:1  	-  3:,
	RAT_UWY_NF		4:1  	-  4:,
	RAT_UW_NT		5:1  	-  5:,
	RAT_INDEX		26:1	-  26:,
	FILLER1			1:1		-  5:,
	FILLER2			7:1		-  20:
/JOINKEYS
	CTR_NF,           
	UWY_NF     
/INFILE ${DFILT}/${NJOB}_35_${IB}_RETRO_FRERETFACCTR.dat 500 1 "~"
/JOINKEYS
	RAT_CTR_NF,   
	RAT_UWY_NF
/OUTFILE  ${SORT_O}
/REFORMAT   
	RIGHTSIDE:FILLER1,
	LEFTSIDE:RAT_INDEX,
	RIGHTSIDE:FILLER2
exit
EOF
SORT


NSTEP=${NJOB}_42
LIBEL="RATEINDEX retro : detect RETRO with missing section only"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RETRO_FRERETFACCTR_MISS_SEC.dat 500 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF          3:1  	-  3:,
	SEC_NF          4:1  	-  4:,
	UWY_NF          5:1  	-  5:,
	UW_NT           6:1  	-  6:,
	END_NT          7:1  	-  7:,
	RAT_CTR_NF  	1:1  	-  1:,
	RAT_END_NT  	2:1  	-  2:,
	RAT_SEC_NF  	3:1  	-  3:,
	RAT_UWY_NF		4:1  	-  4:,
	RAT_UW_NT		5:1  	-  5:,
	RAT_INDEX		26:1	-  26:,
	ALL_FIELDS		1:1		-  20:
/JOINKEYS
	CTR_NF,           
	UWY_NF,
	SEC_NF  	
/INFILE ${DFILT}/${NJOB}_41_${IB}_RETRO_FRERETFACCTR_ALLSEC.dat 2000 1 "~"
/JOINKEYS
	RAT_CTR_NF,   
	RAT_UWY_NF,
	RAT_SEC_NF
/JOIN UNPAIRED RIGHTSIDE ONLY	
/OUTFILE  ${SORT_O}
/REFORMAT   
	RIGHTSIDE:ALL_FIELDS
exit
EOF
SORT


NSTEP=${NJOB}_43
LIBEL="RATEINDEX retro : select only one rate index "
EXECKSH_MODE=P
EXECKSH "sort -u ${DFILT}/${NJOB}_42_${IB}_RETRO_FRERETFACCTR_MISS_SEC.dat > ${DFILT}/${NJOB}_43_${IB}_RETRO_FRERETFACCTR_MISS_SEC.dat  "
wc -l ${DFILT}/${NJOB}_43_${IB}_RETRO_FRERETFACCTR_MISS_SEC.dat



NSTEP=${NJOB}_45
LIBEL="TRANSITION PURPOSE I17G : ADD REFERENCE QUARTER TO ESF_FRERETFACCTR RETRO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RETRO_FRERETFACCTR_JOINED.dat 500 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	CTR_NF          3:1  	-  3:,
	SEC_NF          4:1  	-  4:,
	UWY_NF          5:1  	-  5:,
	UW_NT           6:1  	-  6:,
	END_NT          7:1  	-  7:,
	RAT_CTR_NF  	1:1  	-  1:,
	RAT_END_NT  	2:1  	-  2:,
	RAT_SEC_NF  	3:1  	-  3:,
	RAT_UWY_NF		4:1  	-  4:,
	RAT_UW_NT		5:1  	-  5:,
	RAT_INDEX		26:1	-  26:,
	FILLER1			1:1		-  5:,
	FILLER2			7:1		-  20:
/JOINKEYS
	CTR_NF,    
	END_NT,    
	SEC_NF,    
	UWY_NF     
/INFILE ${DFILT}/${NJOB}_35_${IB}_RETRO_FRERETFACCTR.dat 500 1 "~"
/JOINKEYS
	RAT_CTR_NF,  
	RAT_END_NT,  
	RAT_SEC_NF,  
	RAT_UWY_NF
/OUTFILE  ${SORT_O}
/REFORMAT   
	RIGHTSIDE:FILLER1,
	LEFTSIDE:RAT_INDEX,
	RIGHTSIDE:FILLER2
exit
EOF
SORT

#--------------------------------------------------------------------------
# 	MERGE and REFORMAT ESF_FRERETFACCTR_INI_TRN ACCORDING TO THE NORME 
#--------------------------------------------------------------------------
if [ ${NORME_CF} = "I17G" ] || [ ${NORME_CF} = "I17S" ]
then
NSTEP=${NJOB}_46
LIBEL="MERGE OUTFILE ASSUMED && RETRO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ASSUMED_FRERETFACCTR_JOINED.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_45_${IB}_RETRO_FRERETFACCTR_JOINED.dat 500 1"
SORT_I3="${DFILT}/${NJOB}_43_${IB}_RETRO_FRERETFACCTR_MISS_SEC.dat 500 1"
SORT_O="${ESF_FRERETFACCTR_INI_TRN}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	FILLER         1:1    -  20:
/OUTFILE ${SORT_O} OVERWRITE
/COPY
exit
EOF
SORT
elif [ ${NORME_CF} = "I17P" ]
then
NSTEP=${NJOB}_46
LIBEL="MERGE OUTFILE ASSUMED && RETRO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ASSUMED_FRERETFACCTR_JOINED.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_45_${IB}_RETRO_FRERETFACCTR_JOINED.dat 500 1"
SORT_I3="${DFILT}/${NJOB}_43_${IB}_RETRO_FRERETFACCTR_MISS_SEC.dat 500 1"
SORT_O="${ESF_FRERETFACCTR_INI_TRN}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	FILLER1         1:1    	- 6:,
	RATEINDEX_CTG	6:1		- 6:,
	FILLER2         8:1    	- 20:
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
	FILLER1,
	RATEINDEX_CTG,
	FILLER2
/COPY
exit
EOF
SORT
else
NSTEP=${NJOB}_46
LIBEL="MERGE OUTFILE ASSUMED && RETRO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ASSUMED_FRERETFACCTR_JOINED.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_45_${IB}_RETRO_FRERETFACCTR_JOINED.dat 500 1"
SORT_I3="${DFILT}/${NJOB}_43_${IB}_RETRO_FRERETFACCTR_MISS_SEC.dat 500 1"
SORT_O="${ESF_FRERETFACCTR_INI_TRN}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	FILLER1         1:1    	- 7:,
	RATEINDEX_CTG	6:1		- 6:,
	FILLER2         9:1    	- 20:
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
	FILLER1,
	RATEINDEX_CTG,
	FILLER2
/COPY
exit
EOF
SORT
fi

NSTEP=${NJOB}_50
LIBEL="CREATE IRDPERICASE with retroP and retroNP : same CSUOE as EBS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 2000 1"
SORT_O="${ESF_IRDPERICASE0_PNP_TRN} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	PER_SSD_CF      1:1 -  1:,
	PER_ACCESB_CF   8:1 -  8:,
    PER_CTR_NF      3:1 -  3:,
    PER_END_NT      4:1 -  4:,
    PER_SEC_NF      5:1 -  5:,
    PER_UWY_NF      6:1 -  6:,
    PER_UW_NT       7:1 -  7:,
	SSD_CF          1:1  -  1:,
	ESB_CF          2:1  -  2:,	
    CTR_NF          3:1  -  3:,
    SEC_NF          4:1  -  4:,
    UWY_NF          5:1  -  5:,
    UW_NT           6:1  -  6:,
    END_NT          7:1  -  7:,
    REF_QUARTER	    23:1 -  23:,
    FILLER		    1:1	 -  224:
/JOINKEYS
	SSD_CF  , 
	ESB_CF  , 
	CTR_NF,    
	END_NT,    
	SEC_NF,    
	UWY_NF,    
	UW_NT     	
/INFILE ${EPO_IRDPERICASE0_EBS} 2000 1 "~"
/JOINKEYS
	PER_SSD_CF    ,
	PER_ACCESB_CF ,
	PER_CTR_NF,  
	PER_END_NT,  
	PER_SEC_NF,  
	PER_UWY_NF,
	PER_UW_NT
/OUTFILE  ${SORT_O}
/REFORMAT 
	RIGHTSIDE:FILLER,
	LEFTSIDE:REF_QUARTER
exit
EOF
SORT

NSTEP=${NJOB}_60
LIBEL="CREATE IRDPERICASE for retroP TRANSITION..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${TRANSITION_DATA} 2000 1"
SORT_O="${ESF_IRDPERICASE0_P_TRN} 2000 1"   
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	PER_SSD_CF      1:1 -  1:,
	PER_ACCESB_CF   8:1 -  8:,
    PER_CTR_NF      3:1 -  3:,
    PER_END_NT      4:1 -  4:,
    PER_SEC_NF      5:1 -  5:,
    PER_UWY_NF      6:1 -  6:,
    PER_UW_NT       7:1 -  7:,
	SSD_CF          1:1  -  1:,
	ESB_CF          2:1  -  2:,	
    CTR_NF          3:1  -  3:,
    SEC_NF          4:1  -  4:,
    UWY_NF          5:1  -  5:,
    UW_NT           6:1  -  6:,
    END_NT          7:1  -  7:,
    REF_QUARTER	    23:1 -  23:,
    FILLER		    1:1	 -  250:
/JOINKEYS
	SSD_CF,
	ESB_CF,
	CTR_NF,    
	END_NT,    
	SEC_NF,    
	UWY_NF,    
	UW_NT     	
/INFILE ${ESF_IADVPERICASE_P} 2000 1 "~"  
/JOINKEYS
	PER_SSD_CF   ,
	PER_ACCESB_CF,
	PER_CTR_NF,  
	PER_END_NT,  
	PER_SEC_NF,  
	PER_UWY_NF,
	PER_UW_NT
/OUTFILE  ${SORT_O}
/REFORMAT 
	RIGHTSIDE:FILLER,
	LEFTSIDE:REF_QUARTER
exit
EOF
SORT

JOBEND