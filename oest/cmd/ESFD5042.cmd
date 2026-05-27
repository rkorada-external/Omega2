#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5042.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 05\10\2022
# auteur                        : Florian CULIOLI
# references des specifications :
#-----------------------------------------------------------------------------
# Description
#  Merge fces from 5030 & 5010
#	http://aenprdxwikiu/xwiki/wiki/omega/view/DEV/DF-CLO-916547
#-----------------------------------------------------------------------------
# Modifications
#[001] 04/09/2024 MZM : SPIRA 111972   Retro plan N+1 - limit cession to expected retro P according to the norm 
#[002] 17/10/2024 MZM : SPIRA 112322   Retro plan N+1 - Missing 2nd loop retrocession :  REPLACE CESSACCSTA_N with ${ICLODAT_A
#[003] 07/11/2025 M.NAJI : US 7359   adaptation SERQS
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

FCES_5030=$1
FCES_5010=$2
FCES_MERGED=$3


## Init Files For Tests 
##ESF_TRERETFACCTR=/scor/home/u006596/martin/perm/I_ESFD1130_TRERETFACCTR_I17G_INV_20240930.dat
##ESF_RETRO_PLAN=/scor/home/u006596/martin/temporaire/T_RETRO_PLAN_TEST.dat
##FCES_5010=/scordata_aenuato2batch/ubeu/perm/T_ESFD5010_I17G_MRG_PER_INI_FCES_INV_20240930.dat
##FCES_5030=/scordata_aenuato2batch/ubeu/perm/empty.dat
##FCES_MERGED=/scor/home/u006596/martin/perm/T_FCES_MERGED.dat



ICLODAT_A=`echo ${PARM_ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${PARM_ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${PARM_ICLODAT_D} | awk '{print substr($0,7,8)}'`

ICLODAT_M0=$(($ICLODAT_M - 2))



FCES_5030=$1
FCES_5010=$2
FCES_MERGED=$3

# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF...............................................................: ${NORME_CF}"
ECHO_LOG "#===> PARM_ICLODAT_D.........................................................: ${PARM_ICLODAT_D}" 
ECHO_LOG "#===> ICLODAT_D..............................................................: ${ICLODAT_D}" 
ECHO_LOG "#===> ICLODAT_A..............................................................: ${ICLODAT_A}" 


ECHO_LOG "#===> ............ INPUT ...................................................." 
ECHO_LOG "#===> ESF_IRDVPERICASE.......................................................: ${ESF_IRDVPERICASE}" 
ECHO_LOG "#===> ESF_TRERETFACCTR.......................................................: ${ESF_TRERETFACCTR}" 
ECHO_LOG "#===> ESF_RETRO_PLAN.........................................................: ${ESF_RETRO_PLAN}"
ECHO_LOG "#===> FCES_5010..............................................................: ${FCES_5010}"
ECHO_LOG "#===> FCES_5030..............................................................: ${FCES_5030}"

ECHO_LOG "#===> ............ OUTPUT ..................................................."
ECHO_LOG "#===> FCES_MERGED............................................................: ${FCES_MERGED}"
ECHO_LOG "#============================================================================"



NSTEP=${NJOB}_05
# FILTER UNPAIRED RECORDS FROM FCES_5010 WITH FCES_5030
#------------------------------------------------------------------------------
LIBEL="FILTER UNPAIRED RECORDS FROM FCES_5010 WITH FCES_5030"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${FCES_5010} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_UNPAIRED_FCES_5030.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF       			1:1 - 1:,
	END_NT  				2:1 - 2:,
	SEC_NF       			3:1 - 3:,
	UWY_NF       			4:1 - 4:,
	UW_NT       			5:1 - 5:,
	FCES					1:1 - 25:
/joinkeys 
	CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
	UW_NT
/INFILE ${FCES_5030} 2000 1 "~"
/joinkeys 
	CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
	UW_NT
/JOIN UNPAIRED RIGHTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT 
	rightside :FCES
exit
EOF
SORT


## SORT_O="${FCES_MERGED} 2000 1"

NSTEP=${NJOB}_10
# Generate FCES_5010 + UNPAIRED_5030 file by CSUOE
#-----------------------------------------------------------------------------
LIBEL="Generate FCES_5010 + UNPAIRED_5030 file by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${FCES_5010} 2000 1"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_UNPAIRED_FCES_5030.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCES_MERGED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF						1:1 - 1:,
	END_NT						2:1 - 2:,
	SEC_NF						3:1 - 3:,
	UWY_NF						4:1 - 4:,
	UW_NT						  5:1 - 5:
/KEYS   CTR_NF ,
		END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT		
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

#[003]
NSTEP=${NJOB}_12
# EBS case
#-----------------------------------------------------------------------------
LIBEL=" UPDATE FICHIER FCES ..."
EXECKSH "cp ${DFILT}/${NJOB}_10_${IB}_FCES_MERGED.dat  ${FCES_MERGED} "
        


if [ ${NORME_CF} != "EBS" ]
then

## VERIFICATION de  existence du fichier RETRO PLAN  

if [ !  -f ${ESF_RETRO_PLAN} ] 
then
        ECHO_LOG " FICHIER  RETRO PLAN ${ESF_RETRO_PLAN} EST INEXISTANT OU NORME DIFFERE DE I17 ; PAS DE MODIFICATION DU FICHIER ${FCES_MERGED} "    >> $FLOG
else


## INIT_STATUS Via 1130


#--------------------------------------------------------------------------------
# 	REFORMAT ESF_TRERETFACCTR ACCORDING TO THE NORME : GROUP, PARENT and LOCAL
#--------------------------------------------------------------------------------
if [ ${NORME_CF} = "I17G" ]
then
NSTEP=${NJOB}_15
LIBEL="REFORMAT ESF_TRERETFACCTR to GROUP FORMAT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_TRERETFACCTR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRERETFACCTR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	FILLER		1:1     - 17:
/OUTFILE ${SORT_O} OVERWRITE
/COPY 	
exit
EOF
SORT

elif [ ${NORME_CF} = "I17P" ]
then
NSTEP=${NJOB}_15
LIBEL="REFORMAT ESF_TRERETFACCTR to PARENT FORMAT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_TRERETFACCTR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRERETFACCTR.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	FILLER1			1:1     - 11:,
	INI_STATUS_P 	13:1    - 13:,
	FIRST_CLODAT_P  16:1    - 16:
/DERIVEDFIELD SPACES "~~"	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
	FILLER1,
	INI_STATUS_P,
	SPACES,
	FIRST_CLODAT_P
/COPY 
exit
EOF
SORT

else

NSTEP=${NJOB}_15
LIBEL="REFORMAT ESF_TRERETFACCTR to LOCAL FORMAT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_TRERETFACCTR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRERETFACCTR.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	FILLER1			1:1     - 11:,
	INI_STATUS_L 	14:1    - 14:,
	FIRST_CLODAT_L  17:1    - 17:
/DERIVEDFIELD SPACES "~~"	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
	FILLER1,
	INI_STATUS_L,
	SPACES,
	FIRST_CLODAT_L
/COPY 
exit
EOF
SORT

fi


## TRI Du fichier PERICASE RETRO Pour JOINTURE AVEC le FICHIER CES ==> Obtenir INCEPTION DATE RETRO

NSTEP=${NJOB}_20
# SORT RETRO PLAN file by CSUOE file by CSUOE
#-----------------------------------------------------------------------------
LIBEL="SORT IRDPERICASE file by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IRDVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	RETCTR_NF						3:1 - 3:,
	RETEND_NT						4:1 - 4:,
	RETSEC_NF						5:1 - 5:,
	RETRTY_NF						6:1 - 6:,
	RETUW_NT						7:1 - 7:
/KEYS   RETCTR_NF ,
		    RETEND_NT ,
        RETSEC_NF ,
        RETRTY_NF ,
        RETUW_NT		
/OUTFILE ${SORT_O}
exit
EOF
SORT


## JOIN FCES_MERGED With RETRO PLAN File 

## SORT_I="${DFILT}/${NJOB}_10_${IB}_FCES_MERGED.dat 2000 1"


NSTEP=${NJOB}_25
LIBEL="JOIN FCES_MERGED.dat FILE && ESF_TRERETFACCTR ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_10_${IB}_FCES_MERGED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCES_MERGED.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CES_CTR_NF 			1:1 	- 1:,
	CES_END_NT			2:1 	- 2:,
	CES_SEC_NF 			3:1 	- 3:,
	CES_UWY_NF 			4:1 	- 4:,
	CES_UW_NT 			5:1 	- 5:,
	CES_RETCTR_NF   6:1 	- 6:,
	CES_RETEND_NT   7:1 	- 7:,
	CES_RETSEC_NF  	8:1 	- 8:,
	CES_RTY_NF   		9:1 	- 9:,
	CES_RETUW_NT    10:1 	- 10:,
  FILLER_1_12   	1:1 	- 12:,	
	CESSH_R    			13:1 	- 13:,
	CTR_NF   				1:1 	- 1:,
	END_NT   				2:1 	- 2:,
	SEC_NF  				3:1 	- 3:,
	UWY_NF   				4:1 	- 4:,
	UW_NT    				5:1 	- 5:,
	INI_STATUS			12:1 	- 12:,
	FIRST_CLODAT_D	15:1 	- 15:,
	FILLER					1:1		- 25:	
/JOINKEYS
	CES_CTR_NF,    
	CES_END_NT,    
	CES_SEC_NF,    
	CES_UWY_NF,    
	CES_UW_NT		
/INFILE ${DFILT}/${NJOB}_15_${IB}_TRERETFACCTR.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:INI_STATUS,FIRST_CLODAT_D
exit
EOF
SORT

#

## AJOUT INCEPTION DATE RETRO     


## TRI DU FICHIER CCES par CLE CSUE RETRO AVANT MERGE

NSTEP=${NJOB}_27
LIBEL="TRI DU FICHIER CCES par CLE CSUE RETRO AVANT OINTURE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_25_${IB}_FCES_MERGED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCES_MERGED.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CES_CTR_NF 			1:1 	- 1:,
	CES_END_NT			2:1 	- 2:,
	CES_SEC_NF 			3:1 	- 3:,
	CES_UWY_NF 			4:1 	- 4:,
	CES_UW_NT 			5:1 	- 5:,
	CES_RETCTR_NF   6:1 	- 6:,
	CES_RETEND_NT   7:1 	- 7:,
	CES_RETSEC_NF  	8:1 	- 8:,
	CES_RTY_NF   		9:1 	- 9:,
	CES_RETUW_NT    10:1 	- 10:,
  FILLER_1_12   	1:1 	- 12:,	
	CESSH_R    			13:1 	- 13:,
	INI_STATUS			26:1 	- 26:,
	FIRST_CLODAT_D	27:1 	- 27:,
	FILLER					1:1		- 27:	
/KEYS
	CES_RETCTR_NF,    
	CES_RETEND_NT,    
	CES_RETSEC_NF,    
	CES_RTY_NF,    
	CES_RETUW_NT		
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT


NSTEP=${NJOB}_29
LIBEL="JOIN FCES_MERGED.dat FILE && IRDPERICASE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_27_${IB}_FCES_MERGED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCES_MERGED.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CES_CTR_NF 			1:1 	- 1:,
	CES_END_NT			2:1 	- 2:,
	CES_SEC_NF 			3:1 	- 3:,
	CES_UWY_NF 			4:1 	- 4:,
	CES_UW_NT 			5:1 	- 5:,
	CES_RETCTR_NF   6:1 	- 6:,
	CES_RETEND_NT   7:1 	- 7:,
	CES_RETSEC_NF  	8:1 	- 8:,
	CES_RTY_NF   		9:1 	- 9:,
	CES_RETUW_NT    10:1 	- 10:,
  FILLER_1_12   	1:1 	- 12:,	
	CESSH_R    			13:1 	- 13:,
	RET_CTR_NF   				3:1 	- 3:,
	RET_END_NT   				4:1 	- 4:,
	RET_SEC_NF  				5:1 	- 5:,
	RET_UWY_NF   				6:1 	- 6:,
	RET_UW_NT    				7:1 	- 7:, 
	CTRINCUWY_D         189:1 	- 189:,
	INI_STATUS			26:1 	- 26:,
	FIRST_CLODAT_D	27:1 	- 27:, 
	FILLER					1:1		- 27:	
/JOINKEYS
	CES_RETCTR_NF,    
	CES_RETEND_NT,    
	CES_RETSEC_NF,    
	CES_RTY_NF   ,    
	CES_RETUW_NT 	
/INFILE ${DFILT}/${NJOB}_20_${IB}_SORT_IRDPERICASE.dat 2000 1 "~" 
/JOINKEYS
	RET_CTR_NF,     
	RET_END_NT,     
	RET_SEC_NF,     
	RET_UWY_NF,     
	RET_UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:CTRINCUWY_D
exit
EOF
SORT


# TRI DU FICHIER RETRO_PLAN  CSUE 

NSTEP=${NJOB}_35
# SORT RETRO PLAN file by CSUOE file by CSUOE
#-----------------------------------------------------------------------------
LIBEL="SORT RETRO PLAN file by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_RETRO_PLAN} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_RETRO_PLAN.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	RETCTR_NF						1:1 - 1:,
	RETEND_NT						2:1 - 2:,
	RETSEC_NF						3:1 - 3:,
	RETRTY_NF						4:1 - 4:,
	RETUW_NT						5:1 - 5:
/KEYS   RETCTR_NF ,
		    RETEND_NT ,
        RETSEC_NF ,
        RETRTY_NF ,
        RETUW_NT		
/OUTFILE ${SORT_O}
exit
EOF
SORT


## [002] REPLACE CESSACCSTA_N with ${ICLODAT_A IF ( INI_STATUS = "" OR INI_STATUS = "0" OR INI_STATUS = "1") AND  ( CTRINCUWY_D > "${PARM_ICLODAT_D}" )

NSTEP=${NJOB}_50
LIBEL="UPDATE FCES_MERGED.dat WHEN INIT_STS = 1 or 0 ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_29_${IB}_FCES_MERGED.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCES_MERGED_AVEC_COND.dat  2000 1"  
SORT_O2="${DFILT}/${NSTEP}_${IB}_FCES_MERGED_SANS_MAJ.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CES_CTR_NF 			1:1 	- 1:,
	CES_END_NT			2:1 	- 2:,
	CES_SEC_NF 			3:1 	- 3:,
	CES_UWY_NF 			4:1 	- 4:,
	CES_UW_NT 			5:1 	- 5:,
	CES_RETCTR_NF   6:1 	- 6:,
	CES_RETEND_NT   7:1 	- 7:,
	CES_RETSEC_NF  	8:1 	- 8:,
	CES_RTY_NF   		9:1 	- 9:,
	CES_RETUW_NT    10:1 	- 10:,
  FILLER_1_10   	1:1 	- 10:,	
	CESACCSTA_N     11:1 	- 11:,
	CESACCEND_N     12:1 	- 12:,	
	CESSH_R    			13:1 	- 13:,
  FILLER_14_25   	14:1 	- 25:,		
  FCES_FILLER   	1:1 	- 25:,
	INI_STATUS			26:1 	- 26:,
	FIRST_CLODAT_D	27:1 	- 27:,      
	CTRINCUWY_D	    28:1 	- 28:,    
	FILLER					1:1		- 28:	
/KEY
	CES_CTR_NF,    
	CES_END_NT,    
	CES_SEC_NF,    
	CES_UWY_NF,    
	CES_UW_NT		
/CONDITION  MAJ_INIT_STS ( INI_STATUS = "" OR INI_STATUS = "0" OR INI_STATUS = "1") AND  ( CTRINCUWY_D > "${PARM_ICLODAT_D}" )
/DERIVEDFIELD CESACCSTA_N_NEW  "${ICLODAT_A}~"
/OUTFILE ${SORT_O} OVERWRITE 
/INCLUDE  MAJ_INIT_STS
/REFORMAT FILLER_1_10, CESACCSTA_N_NEW, CESACCEND_N, CESSH_R, FILLER_14_25
/OUTFILE ${SORT_O2} OVERWRITE
/OMIT  MAJ_INIT_STS
exit
EOF
SORT

##  dEB MISE A JOUR du TAUX si INISTATUS = 1 OU 0 OU SI contrat pas present

###   RETRO P NOT IN THE FILE THEN UPDATE CESSH_R 

NSTEP=${NJOB}_70
LIBEL=" RETRO P IN THE FILE THEN DO NOT UPDATE CESSH_R ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_50_${IB}_FCES_MERGED_AVEC_COND.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCES_MERGED.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CES_CTR_NF 			1:1 	- 1:,
	CES_END_NT			2:1 	- 2:,
	CES_SEC_NF 			3:1 	- 3:,
	CES_UWY_NF 			4:1 	- 4:,
	CES_UW_NT 			5:1 	- 5:,
	CES_RETCTR_NF   6:1 	- 6:,
	CES_RETEND_NT   7:1 	- 7:,
	CES_RETSEC_NF  	8:1 	- 8:,
	CES_RTY_NF   		9:1 	- 9:,
	CES_RETUW_NT    10:1 	- 10:,
  FILLER_1_12   	1:1 	- 12:,	
	CESSH_R    			13:1 	- 13:,
  FILLER_14_25   	14:1 	- 25:,		
  FCES_FILLER   	1:1 	- 25:,
	INI_STATUS			26:1 	- 26:,
	FIRST_CLODAT_D	27:1 	- 27:,
	FILLER					1:1		- 27:,
	FIC_CTR_NF 			1:1 	- 1:,
	FIC_END_NT			2:1 	- 2:,
	FIC_SEC_NF 			3:1 	- 3:,
	FIC_UWY_NF 			4:1 	- 4:,
	FIC_UW_NT 			5:1 	- 5:
/JOINKEYS
	CES_RETCTR_NF,    
	CES_RETEND_NT,    
	CES_RETSEC_NF,    
	CES_RTY_NF,    
	CES_RETUW_NT		
/INFILE ${DFILT}/${NJOB}_35_${IB}_SORT_RETRO_PLAN.dat 2000 1 "~" 
/JOINKEYS
	FIC_CTR_NF,     
	FIC_END_NT,     
	FIC_SEC_NF,     
	FIC_UWY_NF,     
	FIC_UW_NT 
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT FILLER_1_12, CESSH_R, FILLER_14_25
exit
EOF
SORT

## [002] 

NSTEP=${NJOB}_80
LIBEL=" RETRO P NOT IN THE FILE THEN UPDATE CESSH_R ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_50_${IB}_FCES_MERGED_AVEC_COND.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCES_MERGED.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CES_CTR_NF 			1:1 	- 1:,
	CES_END_NT			2:1 	- 2:,
	CES_SEC_NF 			3:1 	- 3:,
	CES_UWY_NF 			4:1 	- 4:,
	CES_UW_NT 			5:1 	- 5:,
	CES_RETCTR_NF   6:1 	- 6:,
	CES_RETEND_NT   7:1 	- 7:,
	CES_RETSEC_NF  	8:1 	- 8:,
	CES_RTY_NF   		9:1 	- 9:,
	CES_RETUW_NT    10:1 	- 10:,
  FILLER_1_10   	1:1 	- 10:,	
	CESACCSTA_N     11:1 	- 11:,
	CESACCEND_N     12:1 	- 12:,	
	CESSH_R    			13:1 	- 13:,
  FILLER_14_25   	14:1 	- 25:,		
  FCES_FILLER   	1:1 	- 25:,
	INI_STATUS			26:1 	- 26:,
	FIRST_CLODAT_D	27:1 	- 27:,
	FILLER					1:1		- 27:,
	FIC_CTR_NF 			1:1 	- 1:,
	FIC_END_NT			2:1 	- 2:,
	FIC_SEC_NF 			3:1 	- 3:,
	FIC_UWY_NF 			4:1 	- 4:,
	FIC_UW_NT 			5:1 	- 5:
/JOINKEYS
	CES_RETCTR_NF,    
	CES_RETEND_NT,    
	CES_RETSEC_NF,    
	CES_RTY_NF,    
	CES_RETUW_NT		
/INFILE ${DFILT}/${NJOB}_35_${IB}_SORT_RETRO_PLAN.dat 2000 1 "~" 
/JOINKEYS
	FIC_CTR_NF,     
	FIC_END_NT,     
	FIC_SEC_NF,     
	FIC_UWY_NF,     
	FIC_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} OVERWRITE
/DERIVEDFIELD CESSH_R_NEW  "0.00000000~" 
/REFORMAT FILLER_1_10, CESACCSTA_N, CESACCEND_N, CESSH_R_NEW, FILLER_14_25
exit
EOF
SORT


NSTEP=${NJOB}_90
LIBEL=" MERGE RETRO P NOT IN THE FILE AND RETRO P NOT UPDATE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_70_${IB}_FCES_MERGED.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_80_${IB}_FCES_MERGED.dat 2000 1" 
SORT_I3="${DFILT}/${NJOB}_50_${IB}_FCES_MERGED_SANS_MAJ.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCES_MERGED.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	CES_CTR_NF 			1:1 	- 1:,
	CES_END_NT			2:1 	- 2:,
	CES_SEC_NF 			3:1 	- 3:,
	CES_UWY_NF 			4:1 	- 4:,
	CES_UW_NT 			5:1 	- 5:,
	CES_RETCTR_NF   6:1 	- 6:,
	CES_RETEND_NT   7:1 	- 7:,
	CES_RETSEC_NF  	8:1 	- 8:,
	CES_RTY_NF   		9:1 	- 9:,
	CES_RETUW_NT    10:1 	- 10:,
  FILLER_1_10   	1:1 	- 10:,	
	CESACCSTA_N     11:1 	- 11:,
	CESACCEND_N     12:1 	- 12:,	
	CESSH_R    			13:1 	- 13:,
  FILLER_14_25   	14:1 	- 25:,	
  FCES_FILLER   	1:1 	- 25:,
	INI_STATUS			26:1 	- 26:,
	FIRST_CLODAT_D	27:1 	- 27:,
	FILLER					1:1		- 27:
/KEYS
	 CES_CTR_NF 		
	,CES_END_NT		
	,CES_SEC_NF 		
	,CES_UWY_NF 		
	,CES_UW_NT 	  	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT FILLER_1_10, CESACCSTA_N, CESACCEND_N, CESSH_R, FILLER_14_25
exit
EOF
SORT


NSTEP=${NJOB}_100
LIBEL=" UPDATE FICHIER FCES ..."
EXECKSH "cp ${DFILT}/${NJOB}_90_${IB}_FCES_MERGED.dat  ${FCES_MERGED} "
        

fi

##  FIN MISE A JOUR du TAUX si INISTATUS = 1 OU 0 OU SI contrat pas present

fi




NSTEP=${NJOB}_115
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
