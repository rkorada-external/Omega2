#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
#								 ENrichissement de du fichier EST_IADPERICASE et EST_IADPERIPRMD 
# nom du script SHELL          : ESID2001B.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 24/12/2019 
# auteur                       : M.NAJI 
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 )
#
# Job launched by ESID2000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
# [001] 26/02/2021 M.NAJI Spira 91531  commenter les suppression des fichier permanents  
#===========================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

#set -x

# Initialization of the Job
JOBINIT

# Parameters
CRE_D=$1
BALSHTYEA_NF=$2
CLOTYP_CT=$3
SEGTYP_CT=$4
ICLODAT_D=$5
SSDs=$6
SSDVRS_LL=$7
LSTCLODAT_LL=$8
SSDDEL_LL=$9


NSTEP=${NJOB}_05
#Last version of ESID2000 files deletion
#-----------------------------------------------------------------------------
RMFIL "
 ${DFILI}/${ENV_PREFIX}_ESID2000_*_${ICLODAT}.dat
 ${DFILI}/${ENV_PREFIX}_ESID2010_*_${ICLODAT}.dat
 `dirname ${EST_PERICASESNEM}`/${NCHAIN}_PERICASESNEM*.dat*
 `dirname ${EST_DSUMGTAASNEM}`/${NCHAIN}_DSUMGTAASNEM*.dat*
 `dirname ${EST_DSUMGTAASNEM_ESTC1005A}`/${NCHAIN}_DSUMGTAASNEM_ESTC1005A*.dat*
 `dirname ${EST_CTRULT02}`/${NCHAIN}_CTRULT02*.dat*
 `dirname ${EST_FLOARAT}`/${NCHAIN}_FLOARAT*.dat*
 `dirname ${EST_PERIANO}`/${NCHAIN}_PERIANO*.dat*
 `dirname ${EST_FPRMLOA}`/${NCHAIN}_FPRMLOA*.dat"

# [001]  `dirname ${EST_FT}`/${NCHAIN}_FT*.dat*
# [001] `dirname ${EST_DLCUMGTAAS}`/${NCHAIN}_DLCUMGTAAS*.dat*

# tri EST_FCPLACC avec la max des acy , MNTH  en premier
NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="tri EST_FCPLACC avec la max des ACY , MNTH  en premier"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCPLACC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCPLACC_SORT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CMP_CTR_NF 			2:1 - 2:,
	CMP_ACY_NF 			3:1 - 3:EN, 
	CMP_SCOENDMTH_NF 	5:1 - 5:EN
/KEYS 
	 CMP_CTR_NF 			
	,CMP_ACY_NF 	 descending		
	,CMP_SCOENDMTH_NF 	descending
/OUTFILE ${SORT_O}
exit	
EOF
SORT
 
# grader dans EST_FCPLACC  la max des acy , MNTH
NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="grader dans EST_FCPLACC  la max des ACH , MNTH"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_FCPLACC_SORT.dat"  
SORT_O="${DFILT}/${NSTEP}_${IB}_FCPLACC_MAX.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	CMP_CTR_NF 			2:1 - 2:,
	CMP_ACY_NF 			3:1 - 3:EN, 
	CMP_SCOENDMTH_NF 	5:1 - 5:EN
/KEYS 
	 CMP_CTR_NF 			
/SUM
/STABLE
/OUTFILE ${SORT_O}
exit	
EOF
SORT


# filte EST_IADPERICASE COND_UWORG != 253, 255 and 13
NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="filte EST_IADPERICASE COND_UWORG != 253, 255 and 13"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE} 1000 1"
SORT_O="${EST_IADPERICASE_NON_TERM}"
SORT_O2="${EST_IADPERICASE_TERM}" 
SORT_O3="${EST_PERICASESNEM}"
SORT_O4="${DFILT}/${NSTEP}_${IB}_IADPERICASE_O2.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
		PER_SSD_CF						1:1 - 1: ,	
        PER_CTR_NF 						3:1 - 3:,
        PER_END_NT						4:1 - 4:,
        PER_SEC_NF						5:1 - 5:,
        PER_UWY_NF						6:1 - 6:,
        PER_UW_NT 						7:1 - 7:,
		PER_CED_NF 						12:1 - 12:,
		PER_PCPRSKTRY_CF				52:1 - 52:,
		PER_LOB_CF						38:1 - 38:,
        PER_EGPCUR_CF       			23:1 - 23:,
		PER_CTRRET_B					20:1 - 20: , 
        PER_NAT_CF 						49:1 - 49:  ,
		PER_SECACCSTS_CT    			77:1 - 77:,
		PER_CTRNAT_CT   				85:1 - 85:,
		PER_UWORG_CF					119:1 - 119: ,
      	BEFORE_PER_LOSCOREXI_B 			1:1 -  38:,
		PER_LOSCOREXI_B		    		39:1 -  39:,
		AFTER_PER_LOSCOREXI_B			40:1 -  206:,
		all_cols		 				1:1  - 206:
/CONDITION COND_PERM  ( ( PER_UWORG_CF != "253" AND PER_UWORG_CF != "255" AND PER_UWORG_CF != "13") 
					  ) AND
					  PER_CTRRET_B = '0'  AND
					  PER_SECACCSTS_CT != "9"
/CONDITION COND_PERM2 ( ( PER_UWORG_CF != "253" AND PER_UWORG_CF != "255" AND PER_UWORG_CF != "13") 
					  ) AND
					  PER_SECACCSTS_CT != "9"
/CONDITION COND_PERM_TERM  ( ( PER_UWORG_CF != "253" AND PER_UWORG_CF != "255" AND PER_UWORG_CF != "13") 
					  ) AND
					  PER_SECACCSTS_CT = "9"
/CONDITION COND_UW_RI  ( ( PER_UWORG_CF != "253" AND PER_UWORG_CF != "255" AND PER_UWORG_CF != "13") 
					  ) AND 
						PER_PCPRSKTRY_CF = "FRA" AND 
						PER_LOB_CF ="04" AND 
						PER_CTRRET_B = "0" AND 
						PER_SECACCSTS_CT != "9" AND 
						( PER_SSD_CF = "2" OR PER_SSD_CF = "3" OR PER_SSD_CF = "12" ) AND 
						PER_CTR_NF  != "02Z041517" AND  
			   		( PER_CTR_NF != "02G0X7677" OR PER_UWY_NF != "1993" )					  
/DERIVEDFIELD PER_LOSCOREXI_B_NEW if COND_PERM_TERM then "0" else PER_LOSCOREXI_B 
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE COND_PERM  
/REFORMAT 
	BEFORE_PER_LOSCOREXI_B
	,PER_LOSCOREXI_B_NEW
	,AFTER_PER_LOSCOREXI_B
/OUTFILE ${SORT_O2} OVERWRITE
/INCLUDE COND_PERM_TERM
/REFORMAT 
	BEFORE_PER_LOSCOREXI_B
	,PER_LOSCOREXI_B_NEW
	,AFTER_PER_LOSCOREXI_B
/OUTFILE ${SORT_O3} OVERWRITE
/INCLUDE COND_UW_RI
/REFORMAT 
	BEFORE_PER_LOSCOREXI_B
	,PER_LOSCOREXI_B_NEW
	,AFTER_PER_LOSCOREXI_B
/OUTFILE ${SORT_O4} OVERWRITE 
/INCLUDE COND_PERM2
/REFORMAT 
	BEFORE_PER_LOSCOREXI_B
	,PER_LOSCOREXI_B_NEW
	,AFTER_PER_LOSCOREXI_B
/COPY
exit	
EOF
SORT


# enrichissement du PERICASE avec le taux de la device CURQUOT_RATE de EGPCUR
NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="enrichissement du PERICASE avec le taux de la device CURQUOT_RATE de EGPCUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_TERM} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_TERM_EXTEND.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
		PER_SSD_CF			 1:1 - 1: ,	
        PER_CTR_NF 			 3:1 - 3:,
        PER_END_NT			 4:1 - 4:,
        PER_SEC_NF			 5:1 - 5:,
        PER_UWY_NF			 6:1 - 6:,
        PER_UW_NT 			 7:1 - 7:,
        PER_EGPCUR_CF       23:1 - 23:,
		PER_CTRRET_B		20:1 - 20: , 
		PER_LOB_CF			38:1 - 38:,
        PER_NAT_CF 			49:1 - 49:  ,
		PER_PCPRSKTRY_CF	52:1 - 52:,
		PER_SECACCSTS_CT    77:1 - 77:,
		PER_CTRNAT_CT   	85:1 - 85:,
		PER_UWORG_CF	   119:1 - 119: ,
		PER_RECBRK_B 	   160:1 - 160:,
        CURQUOT_SSD_CF    	 1:1 -  1:,
        CURQUOT_CUR_CF       2:1 -  2:,
        CURQUOT_UWY_NF       3:1 -  3:,
        PER_EGPCUR_RATE      4:1 -  4:,
		all_cols		     1:1  - 206:
/joinkeys 
       PER_SSD_CF
	  ,PER_EGPCUR_CF
	  ,PER_UWY_NF
/INFILE ${EST_FCURQUOT_TXT} 256 1 "~"
/joinkeys 
        CURQUOT_SSD_CF
	   ,CURQUOT_CUR_CF
	   ,CURQUOT_UWY_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
	 leftside:PER_CTR_NF        
	,leftside:PER_END_NT
	,leftside:PER_SEC_NF
	,leftside:PER_UWY_NF
	,leftside:PER_UW_NT
	,leftside:PER_CTRRET_B
    ,leftside:PER_NAT_CF
	,leftside:PER_CTRNAT_CT
	,leftside:PER_UWORG_CF
	,leftside:PER_EGPCUR_CF
	,leftside:PER_SECACCSTS_CT
	,leftside:PER_PCPRSKTRY_CF
	,rightside:PER_EGPCUR_RATE   
	,leftside:PER_LOB_CF
	,leftside:PER_RECBRK_B

exit	
EOF
SORT


# enrichissement IADPERICASE avec 	CPLAACC.ACY_NF,  CPLAACC.SCOENDMTH_NF
NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="enrichissement IADPERICASE avec 	CPLAACC.ACY_NF,  CPLAACC.SCOENDMTH_NF"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_IADPERICASE_TERM_EXTEND.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_TERM_EXTEND.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	PER_CTR_NF 			1:1 - 1:,    
	PER_END_NT			2:1 - 2:, 
	PER_SEC_NF			3:1 - 3:,
	PER_UWY_NF			4:1 - 4:,
	PER_UW_NT 			5:1 - 5:,
	PER_CTRRET_B		6:1 - 6: , 
	PER_NAT_CF 			7:1 - 7:,
	PER_CTRNAT_CT   	8:1 - 8:,
	PER_UWORG_CF		9:1 - 9:,
	PER_EGPCUR_CF   	10:1 -10:,
	PER_SECACCSTS_CT    11:1 - 11:, 
	PER_PCPRSKTRY_CF    12:1 - 12:,
	PER_EGPCUR_RATE     13:1 - 13:, 
	PER_LOB_CF     		14:1 - 14:, 
	PER_RECBRK_B		15:1 - 15:, 
	ALL_COLS_PER		1:1 - 15:,
	CMP_CTR_NF 			2:1 - 2:,
	CMP_ACY_NF 			3:1 - 3:,
	CMP_SCOENDMTH_NF 	5:1 - 5:
/joinkeys 
       PER_CTR_NF
/INFILE ${DFILT}/${NJOB}_20_${IB}_FCPLACC_MAX.dat 1000 1 "~"
/joinkeys 
        CMP_CTR_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside:ALL_COLS_PER   
	,rightside:CMP_ACY_NF 		
	,rightside:CMP_SCOENDMTH_NF   

exit	
EOF
SORT


# enrichissement du PERICASE avec le taux de la device CURQUOT_RATE de EGPCUR
NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="enrichissement du PERICASE avec le taux de la device CURQUOT_RATE de EGPCUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_NON_TERM} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_EXTEND.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
		PER_SSD_CF			 1:1 - 1: ,	
        PER_CTR_NF 			 3:1 - 3:,
        PER_END_NT			 4:1 - 4:,
        PER_SEC_NF			 5:1 - 5:,
        PER_UWY_NF			 6:1 - 6:,
        PER_UW_NT 			 7:1 - 7:,
        PER_EGPCUR_CF       23:1 - 23:,
		PER_CTRRET_B		20:1 - 20: , 
		PER_LOB_CF			38:1 - 38:,
        PER_NAT_CF 			49:1 - 49:  ,
		PER_PCPRSKTRY_CF	52:1 - 52:,
		PER_SECACCSTS_CT    77:1 - 77:,
		PER_CTRNAT_CT   	85:1 - 85:,
		PER_UWORG_CF	   119:1 - 119: ,
		PER_RECBRK_B 	   160:1 - 160:,
        CURQUOT_SSD_CF    	 1:1 -  1:,
        CURQUOT_CUR_CF       2:1 -  2:,
        CURQUOT_UWY_NF       3:1 -  3:,
        PER_EGPCUR_RATE      4:1 -  4:,
		all_cols		     1:1  - 206:
/joinkeys 
       PER_SSD_CF
	  ,PER_EGPCUR_CF
	  ,PER_UWY_NF
/INFILE ${EST_FCURQUOT_TXT} 256 1 "~"
/joinkeys 
        CURQUOT_SSD_CF
	   ,CURQUOT_CUR_CF
	   ,CURQUOT_UWY_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT 
	 leftside:PER_CTR_NF        
	,leftside:PER_END_NT
	,leftside:PER_SEC_NF
	,leftside:PER_UWY_NF
	,leftside:PER_UW_NT
	,leftside:PER_CTRRET_B
    ,leftside:PER_NAT_CF
	,leftside:PER_CTRNAT_CT
	,leftside:PER_UWORG_CF
	,leftside:PER_EGPCUR_CF
	,leftside:PER_SECACCSTS_CT
	,leftside:PER_PCPRSKTRY_CF
	,rightside:PER_EGPCUR_RATE   
	,leftside:PER_LOB_CF
	,leftside:PER_RECBRK_B

exit	
EOF
SORT


# enrichissement IADPERICASE avec 	CPLAACC.ACY_NF,  CPLAACC.SCOENDMTH_NF
NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="enrichissement IADPERICASE avec 	CPLAACC.ACY_NF,  CPLAACC.SCOENDMTH_NF"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_IADPERICASE_EXTEND.dat 1000 1"
SORT_O="${EST_IADPERICASE_EXTEND}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	PER_CTR_NF 			1:1 - 1:,    
	PER_END_NT			2:1 - 2:, 
	PER_SEC_NF			3:1 - 3:,
	PER_UWY_NF			4:1 - 4:,
	PER_UW_NT 			5:1 - 5:,
	PER_CTRRET_B		6:1 - 6: , 
	PER_NAT_CF 			7:1 - 7:,
	PER_CTRNAT_CT   	8:1 - 8:,
	PER_UWORG_CF		9:1 - 9:,
	PER_EGPCUR_CF   	10:1 -10:,
	PER_SECACCSTS_CT    11:1 - 11:, 
	PER_PCPRSKTRY_CF    12:1 - 12:,
	PER_EGPCUR_RATE     13:1 - 13:, 
	PER_LOB_CF     		14:1 - 14:, 
	PER_RECBRK_B		15:1 - 15:, 
	ALL_COLS_PER		1:1 - 15:,
	CMP_CTR_NF 			2:1 - 2:,
	CMP_ACY_NF 			3:1 - 3:,
	CMP_SCOENDMTH_NF 	5:1 - 5:
/joinkeys 
       PER_CTR_NF
/INFILE ${DFILT}/${NJOB}_20_${IB}_FCPLACC_MAX.dat 1000 1 "~"
/joinkeys 
        CMP_CTR_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside:ALL_COLS_PER   
	,rightside:CMP_ACY_NF 		
	,rightside:CMP_SCOENDMTH_NF   

exit	
EOF
SORT





# filtre de EST_IADPERIPRMD  sur PER_CTRRET_B = "0" AND PER_SECACCSTS_CT != "9"
NSTEP=${NJOB}_65
#-----------------------------------------------------------------------------
LIBEL="filtre de EST_IADPERIPRMD  sur PER_CTRRET_B = "0" AND PER_SECACCSTS_CT != "9""
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIPRMD} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERIPRMD.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	PERPRMD_CTR_NF			1:1 - 1:,	
	PERPRMD_END_NT			2:1 - 2:,
	PERPRMD_SEC_NF			3:1 - 3:,
	PERPRMD_UWY_NF			4:1 - 4:,
	PERPRMD_UW_NT 			5:1 - 5:,
	PER_CTR_NF 			 3:1 - 3:,
	PER_END_NT			 4:1 - 4:,
	PER_SEC_NF			 5:1 - 5:,
	PER_UWY_NF			 6:1 - 6:,
	PER_UW_NT 			 7:1 - 7:,
	PER_EGPCUR_CF       23:1 -23:,
	all_cols 				1:1	-	11:
/joinkeys 
	PERPRMD_CTR_NF			,	
	PERPRMD_END_NT			,
	PERPRMD_SEC_NF			,
	PERPRMD_UWY_NF			,
	PERPRMD_UW_NT 			
/INFILE ${EST_IADPERICASE_NON_TERM} 1000 1 "~"
/joinkeys 
	PER_CTR_NF			,	
	PER_END_NT			,
	PER_SEC_NF			,
	PER_UWY_NF			,
	PER_UW_NT 			
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside:all_cols
	,rightside:PER_EGPCUR_CF
exit	
EOF
SORT

NSTEP=${NJOB}_67
# Omit EBS trncod
#-----------------------------------------------------------------------------
LIBEL="Omit EBS trncod on ${EPO_DLREGTRSO}"
AWK_I=${DFILT}/${NJOB}_65_${IB}_IADPERIPRMD.dat
AWK_O="${DFILT}/${NSTEP}_${IB}_IADPERIPRMD.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
	uwy_1=\$4-1 ; print \$0,uwy_1 
}
exit
EOF
AWK



# enrichissement du EST_IADPERIPRMD avec le taux de la device PERPRMD_PRMDUECUR_CF
NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="enrichissement du EST_IADPERIPRMD avec le taux de la device PERPRMD_PRMDUECUR_CF"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_67_${IB}_IADPERIPRMD.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERIPRMD_PRMDUECUR_RATE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	PERPRMD_CTR_NF			1:1 - 1:,	
	PERPRMD_END_NT			2:1 - 2:,
	PERPRMD_SEC_NF			3:1 - 3:,
	PERPRMD_UWY_NF			4:1 - 4:,
	PERPRMD_UW_NT 			5:1 - 5:,
	PERPRMD_PRMDUECUR_CF    8:1 - 8:,
	PERPRMD_SSD_CF			11:1 - 11:,
	PERPRMD_UWY_NF_1		13:1 - 13:,
	all_cols 				1:1	-	13:,
	CURQUOT_SSD_CF   		1:1 -  1:,
	CURQUOT_CUR_CF   		2:1 -  2:,
	CURQUOT_UWY_NF   		3:1 -  3:,
	CURQUOT_RATE     		4:1 -  4:
/joinkeys 
	PERPRMD_SSD_CF
	,PERPRMD_PRMDUECUR_CF
	,PERPRMD_UWY_NF_1
/INFILE ${EST_FCURQUOT_TXT} 1000 1 "~"
/joinkeys 
	CURQUOT_SSD_CF
	,CURQUOT_CUR_CF
	,CURQUOT_UWY_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside:all_cols
	,rightside:CURQUOT_RATE  
exit	
EOF
SORT


# enrichissement du EST_IADPERIPRMD avec le taux de la device PER_EGPCUR_CF
NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="enrichissement du EST_IADPERIPRMD avec le taux de la device PER_EGPCUR_CF"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_IADPERIPRMD_PRMDUECUR_RATE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERIPRMD_PRMDUECUR_RATE_EGPCUR_RATE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	PERPRMD_CTR_NF			1:1 - 1:,	
	PERPRMD_END_NT			2:1 - 2:,
	PERPRMD_SEC_NF			3:1 - 3:,
	PERPRMD_UWY_NF			4:1 - 4:,
	PERPRMD_UW_NT 			5:1 - 5:,
	PERPRMD_PRMDUECUR_CF    8:1 - 8:,
	PER_EGPCUR_CF		    12:1 - 12:,
	PERPRMD_SSD_CF			11:1 - 11:,
	PERPRMD_UWY_NF_1		13:1 - 13:,
	all_cols 				1:1	-	14:,
	CURQUOT_SSD_CF   		1:1 -  1:,
	CURQUOT_CUR_CF   		2:1 -  2:,
	CURQUOT_UWY_NF   		3:1 -  3:,
	CURQUOT_RATE     		4:1 -  4:
/joinkeys 
	PERPRMD_SSD_CF
	,PER_EGPCUR_CF
	,PERPRMD_UWY_NF_1
/INFILE ${EST_FCURQUOT_TXT} 1000 1 "~"
/joinkeys 
	CURQUOT_SSD_CF
	,CURQUOT_CUR_CF
	,CURQUOT_UWY_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside:all_cols
	,rightside:CURQUOT_RATE  
exit	
EOF
SORT


NSTEP=${NJOB}_90
# convert amount IADPERIPRMD to PER_EGPCUR
#-----------------------------------------------------------------------------
LIBEL="convert amount IADPERIPRMD to PER_EGPCUR ..."
PRG=ESTC1005B
export ${PRG}_I1="${DFILT}/${NJOB}_80_${IB}_IADPERIPRMD_PRMDUECUR_RATE_EGPCUR_RATE.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_IADPERIPRMD_PRMDUECUR_RATE_EGPCUR_RATE_CONV.dat"
EXECPRG



NSTEP=${NJOB}_95
# SORT IADPERIPRMD 
#-----------------------------------------------------------------------------
LIBEL="SORT IADPERIPRMD  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_IADPERIPRMD_PRMDUECUR_RATE_EGPCUR_RATE_CONV.dat"
SORT_O="${EST_IADPERIPRMD_CONV}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	PERPRMD_CTR_NF			1:1 - 1:,	
	PERPRMD_END_NT			2:1 - 2:,
	PERPRMD_SEC_NF			3:1 - 3:,
	PERPRMD_UWY_NF			4:1 - 4:,
	PERPRMD_UW_NT 			5:1 - 5:
/KEY
	PERPRMD_CTR_NF		,	
	PERPRMD_END_NT		,
	PERPRMD_SEC_NF		,
	PERPRMD_UWY_NF		,
	PERPRMD_UW_NT 		
/OUTFILE ${SORT_O}
exit	
EOF
SORT

############################################################
# Comparison of period closing and segmentation perimeters #
############################################################
NSTEP=${NJOB}_100
#Comparison of period closing and segmentation perimeters
#(by the contract grouping file)
#-----------------------------------------------------------------------------
LIBEL="Comparison of period closing process and segmentation perimeters ..."
PRG=ESTM1004
export ${PRG}_I1="${DFILT}/${NJOB}_30_${IB}_IADPERICASE_O2.dat"
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_O1=${EST_FCTRGRO1}
export ${PRG}_O2=${EST_PERIANO}
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE.dat
EXECPRG

JOBEND
