#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Transformation REQ 20.1
# nom du script SHELL           : ESFD4075.cmd
# revision                      : $Revision:   1.0  $
# date de creation				: 17/01/2024
# auteur						: Mehdi NAJI
# references ds specifications	: 
#-----------------------------------------------------------------------------
# description
#       IFRS17 Accouting Update
#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# [001] 07/06/2021 Linh DOAN : SPIRA 92996 GLT IFRS17- Missing field in TTECLEDA and TTECLEDR format
# [001] 07/06/2021 Linh DOAN : SPIRA 97737 REQ20.1 - Exclude Life contracts
# [003] 21/02/2022 MZM : SPIRA 102371 : I17 Filtrer les fichiers I17 Par Normes (Ajout jointures avec les fichiers Pericases)  
# [004] 25/04/2022 MZM : SPIRA 103892: : Remise des champs GT de 73 a 118  pour Assume et de 73 a 71 pour Retro
# [005] 06/05/2022 MZM : SPIRA 85522:  : ONEROUS : Filtre  a partir des PERICASE :  Annulation et deplacement dans ESFD4033 et ESFD4035
# [006] 21/06/2022 MZM : SPIRA 105171:  :Ajout des ANNULATIONS LIFE en sortie du ESFD4030
# [007] 08/08/2022 HR : SPIRA 105449: INI RTO Missing (RA View)
# [008] 29/08/2022 MZ : SPIRA 105449: INI RTO Missing (RA View) Retrait de la SUM au _95B
# [009] 12/09/2022 MZM : SPIRA 106718 IFRS 17 - Annulations Life manquantes MAJ du step _55A
# [010] 17/10/2022 MZM : SPIRA 107357 IFRS 17 - RTO- Do not update opening and cancelation (Ajout Step _95D)
# [011] 10/19/2022 JBD : SPIRA 105609 IO contract info -> Update CSUOE if NOT RI line (step 120/130)
# [012] 16/11/2022 MZM : SPIRA 107725 IFRS 17 P&C closing - Exclusion of all Life treaties
# [013] 14/02/2023 MZM : SPIRA 108737 INT - Missing Retrocessionaire in RR view for I17 transactions : Mise à jour EST_FPLATXCUMALL ==> EST_FPLATXCUM
# [014] 13/03/2023 MZM : SPIRA 108587 Mixed retro : AEs are wrong in RA view : Variabilisation du Fichier FPLATXCUM (ALL ou CUM) en entree du ESTC1052B 
# [015] 12/10/2023 MZM : SPIRA 110675   20.1 - I17 - REQ 20.1 - remove content of NEWCOLS5_NF on reclass transactions
# [016] 08/01/2024 MZM : SPIRA 111009   OPTIM   
# [017] 17/01/2024 M.NAJI: SPIRA 111009   OPTIM : get data de l'ancien ESFD4037 à mettre le plus hat dans VTOM et en //   
# [018] 22/03/2024 MZM : SPIRA 111156   20.1 - I17 - REQ 20.1 - Prod I17 - Opening 24 vs Closing 23 - Cancellation done on Reclass transactions while should not  
# [019] 10/04/2024 MZM : SPIRA 111156   20.1 - I17 - REQ 20.1 - Prod I17 - Opening 24 vs Closing 23 - Cancellation done on Reclass transactions while should not - Revert
# [020] 16/04/2024 MZM : SPIRA 111156   20.1 - I17 - REQ 20.1 - Prod I17 - Opening 24 vs Closing 23 - Cancellation done on Reclass transactions while should not -
# [021] 02/01/2025 MZM : SPIRA 112437   20.1 - I17 - Add conversion in EGPI currency of PA reclass
#======================================================================================================================

#set -x

 

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

EST_BASE=`basename ${ESF_FTECLEDR_OUT%.*}`

CLODAT_D=${PARM_ICLODAT_D}

ICLODAT_A=`echo ${CLODAT_D} | awk '{print substr($0,1,4)}'`

## TI

##ESF_FCURQUOT_TXT=/scor/home/u006596/martin/perm/P_ESCJ0660_FCURQUOT_TXT.dat
##ESF_FBOPRSLNK_TXT=/scor/home/u006596/martin/perm/P_ESCJ0660_FBOPRSLNK_TXT.dat

NSTEP=${NJOB}_03
#-----------------------------------------------------------------------------
LIBEL="filter life rows of FTECLEDAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NCHAIN}_ESFD4035_${NORME_CF}_ESF_FTECLEDR_120_${IB}_${EST_BASE}_ALL.dat  2000 1"
SORT_I="${ESF_FTECLEDR_OUT}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_LIFE.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        GT_CTR_NF        8:1 -  8:,
        GT_END_NT        9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_RETCTR_NF    24:1 - 24:,
        GT_RETEND_NT    25:1 - 25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS      1:1 - 71:,
        LIF_CTR_NF       2:1 - 2:,
        LIF_END_NT       3:1 - 3:,
        LIF_SEC_NF       4:1 - 4:,
        LIF_UWY_NF       5:1 - 5:,
        LIF_UW_NT        6:1 - 6:
/joinkeys
        GT_RETCTR_NF ,
        GT_RETEND_NT ,
        GT_RETSEC_NF ,
        GT_RTY_NF ,
        GT_RETUW_NT
/INFILE ${ESF_IADVPERICASE_LIFE_RETRO} 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/OUTFILE ${SORT_O}
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT


NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Generate Only  Cancellable Life Contracts in TECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03_${IB}_FTECLEDR_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_LIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        GT_CTR_NF        8:1 -  8:,
        GT_END_NT        9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_RETCTR_NF    24:1 - 24:,
        GT_RETEND_NT    25:1 - 25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
				ORICOD_LS       57:1 - 57:,	        
        GT_ANNUL_OPNG   67:1 - 67:,        
        GT_ALL_COLS      1:1 - 71:,
        FILLER_1_66      1:1 - 66:,
        FILLER_68_71     68:1 - 71:                      
/CONDITION ANNU_OPNG  (GT_ANNUL_OPNG = "A" or GT_ANNUL_OPNG = "O")
/OUTFILE ${SORT_O} overwrite
/INCLUDE ANNU_OPNG
exit
EOF
SORT

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="filter life rows of FTECLEDAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NCHAIN}_ESFD4035_${NORME_CF}_ESF_FTECLEDR_120_${IB}_${EST_BASE}_ALL.dat  2000 1"
SORT_I="${ESF_FTECLEDR_OUT}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_NON_LIFE.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        GT_CTR_NF        8:1 -  8:,
        GT_END_NT        9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_RETCTR_NF    24:1 - 24:,
        GT_RETEND_NT    25:1 - 25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS      1:1 - 118:,
        LIF_CTR_NF       2:1 - 2:,
        LIF_END_NT       3:1 - 3:,
        LIF_SEC_NF       4:1 - 4:,
        LIF_UWY_NF       5:1 - 5:,
        LIF_UW_NT        6:1 - 6:
/joinkeys
        GT_RETCTR_NF ,
        GT_RETEND_NT ,
        GT_RETSEC_NF ,
        GT_RTY_NF ,
        GT_RETUW_NT
/INFILE ${ESF_IADVPERICASE_LIFE_RETRO} 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/OUTFILE ${SORT_O}
/JOIN UNPAIRED LEFTSIDE ONLY
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT





NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="EXTEND  FTCLEDR with retro infos"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_FTECLEDR_NON_LIFE.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_NON_LIFE.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	TECLEDR_RETCTR_NF  	24:1	-	24:,
	TECLEDR_RETEND_NT  	25:1	-	25:,
	TECLEDR_RETSEC_NF  	26:1	-	26:,
	TECLEDR_RTY_NF     	27:1	-	27:,
	TECLEDR_RETUW_NT   	28:1	-	28:,
	TECLEDR_COL1-44    	 1:1	-	44:,
	TECLEDR_COL56-71   	56:1	-	71:,
	PER_CTR_NF			 3:1 	- 3:,
    PER_END_NT			 4:1 	- 4:,
    PER_SEC_NF			 5:1 	- 5:,
    PER_UWY_NF			 6:1 	- 6:,
    PER_UW_NT 			7:1 	- 7:,
	PER_GAR_CF			32	:1		 -		32	:	,
	PER_LOB_CF			38	:1		 -		38	:	,
	PER_NAT_CF			49	:1		 -		49	:	,
	PER_PCPRSKTRY_CF	52	:1		 -		52	:	,
	PER_SOB_CF			81	:1		 -		81	:	,
	PER_TOP_CF			84	:1		 -		84	:	,
	PER_ACCADMTYP_CT	97	:1		 -		97	:	,
	PER_RETCTRCAT_CF	107	:1		 -		107	:	,
	PER_USRCRTCOD_CT	115	:1		 -		115	:	,
	PER_USRCRTVAL_LM	116	:1		 -		116	:	
/DERIVEDFIELD TECLEDR_SSDRTO_B "~"
/joinkeys
	TECLEDR_RETCTR_NF ,
	TECLEDR_RETEND_NT ,
	TECLEDR_RETSEC_NF ,
	TECLEDR_RTY_NF    ,
	TECLEDR_RETUW_NT 
/INFILE ${ESF_IRDVPERICASE} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}  
/REFORMAT
  leftside:TECLEDR_COL1-44       ,   
	rightside:PER_LOB_CF        ,
	rightside:PER_SOB_CF        ,
	rightside:PER_TOP_CF        ,
	rightside:PER_NAT_CF        ,
	rightside:PER_GAR_CF        ,
	rightside:PER_PCPRSKTRY_CF  ,
	rightside:PER_USRCRTCOD_CT  ,
	rightside:PER_USRCRTVAL_LM  ,
	rightside:PER_RETCTRCAT_CF     ,
	rightside:PER_ACCADMTYP_CT     ,
	TECLEDR_SSDRTO_B     ,    
	leftside:TECLEDR_COL56-71         
exit
EOF
SORT


NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Extend FTCLEDAR with PLACEMT2_RTO_NF, PLACEMT2_SSDRTO_B "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_FTECLEDR_NON_LIFE.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_05_${IB}_FTECLEDR_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RTO.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
  	TECLEDR_SSD_CF                 1 :1	-	1 :,
	TECLEDR_ESB_CF                 2 :1	-	2 :,
	TECLEDR_BALSHEY_NF             3 :1	-	3 :,
	TECLEDR_BALSHRMTH_NF           4 :1	-	4 :,
	TECLEDR_BALSHRDAY_NF           5 :1	-	5 :,
	TECLEDR_TRNCOD_CF              6 :1	-	6 :,
	TECLEDR_DBLTRNCOD_CF           7 :1	-	7 :,
	TECLEDR_CTR_NF                 8 :1	-	8 :,
	TECLEDR_END_NT                 9 :1	-	9 :,
	TECLEDR_SEC_NF                 10:1	-	10:,
	TECLEDR_UWY_NF                 11:1	-	11:,
	TECLEDR_UW_NT                  12:1	-	12:,
	TECLEDR_OCCYEA_NF              13:1	-	13:,
	TECLEDR_ACY_NF                 14:1	-	14:,
	TECLEDR_SCOSTRMTH_NF           15:1	-	15:,
	TECLEDR_SCOENDMTH_NF            16:1	-	16:,
	TECLEDR_CLM_NF                  17:1	-	17:,
	TECLEDR_CUR_CF                  18:1	-	18:,
	TECLEDR_AMT_M                   19:1	-	19:,
	TECLEDR_CED_NF                  20:1	-	20:,
	TECLEDR_BRK_NF                  21:1	-	21:,
	TECLEDR_PAY_NF                  22:1	-	22:,
	TECLEDR_KEY_NF                  23:1	-	23:,
	TECLEDR_RETCTR_NF               24:1	-	24:,
	TECLEDR_RETEND_NT               25:1	-	25:,
	TECLEDR_RETSEC_NF               26:1	-	26:,
	TECLEDR_RTY_NF                  27:1	-	27:,
	TECLEDR_RETUW_NT                28:1	-	28:,
	TECLEDR_RETOCCYEA_NF            29:1	-	29:,
	TECLEDR_RETACY_NF               30:1	-	30:,
	TECLEDR_RETSCOSTRMTH_NF         31:1	-	31:,
	TECLEDR_RETSCOENDMTH_NF         32:1	-	32:,
	TECLEDR_RCL_NF                  33:1	-	33:,
	TECLEDR_RETCUR_CF               34:1	-	34:,
	TECLEDR_RETAMT_M                35:1	-	35:,
	TECLEDR_PLC_NT                  36:1	-	36:,
	TECLEDR_RTO_NF                  37:1	-	37:,
	TECLEDR_INT_NF                  38:1	-	38:,
	TECLEDR_RETPAY_NF               39:1	-	39:,
	TECLEDR_RETKEY_CF               40:1	-	40:,
	TECLEDR_CRE_D                   41:1	-	41:,
	TECLEDR_CREUSR_CF               42:1	-	42:,
	TECLEDR_LSTUPD_D                43:1	-	43:,
	TECLEDR_LSTUPDUSR_CF            44:1	-	44:,
	TECLEDR_LOBRET_CF               45:1	-	45:,
	TECLEDR_SOBRET_CF               46:1	-	46:,
	TECLEDR_TOPRET_CF               47:1	-	47:,
	TECLEDR_NATRET_CF               48:1	-	48:,
	TECLEDR_GARRET_CF               49:1	-	49:,
	TECLEDR_PCPRSKTRYRET_CF         50:1	-	50:,
	TECLEDR_USRCRTCODRET_CT         51:1	-	51:,
	TECLEDR_USRCRTVALRET_LM         52:1	-	52:,
	TECLEDR_RETCTRCAT_CF            53:1	-	53:,
	TECLEDR_RETACCTYP_CT            54:1	-	54:,
	TECLEDR_SSDRTO_B                55:1	-	55:,
	TECLEDR_TRN_NT                  56:1	-	56:,
	TECLEDR_ORICOD_LS               57:1	-	57:,
	TECLEDR_RETROAUTO_B             58:1	-	58:,
	TECLEDR_SPEENTNAT_CF            59:1	-	59:,
	TECLEDR_EVT_CF                  60:1	-	60:,
	TECLEDR_REVT_CF                 61:1	-	61:,
	TECLEDR_RETARDRETINT_B          62:1	-	62:,
	TECLEDR_NEWCOLS1_NF             63:1	-	63:,
	TECLEDR_GAAPCOD_NT              64:1	-	64:,
	TECLEDR_I17PRDCOD_CT            65:1	-	65:,
	TECLEDR_NEWCOLS4_NF             66:1	-	66:,
	TECLEDR_NEWCOLS5_NF             67:1	-	67:,
	TECLEDR_NEWCOLS6_NF             68:1	-	68:,
	TECLEDR_NEWCOLS7_NF             69:1	-	69:,
	TECLEDR_NEWCOLS8_NF             70:1	-	70:,
	TECLEDR_NEWCOLS9_NF             71:1	-	71:,
	PLACEMT2_RETCTR_NF   			1:1		-	1:,
	PLACEMT2_RTY_NF      			2:1		-	2:,
	PLACEMT2_PLC_NT      			3:1		-	3:,
	PLACEMT2_RTO_NF      			4:1		-	4:,
	PLACEMT2_SSDRTO_B    			5:1		-	5:,
	TECLEDR_ALL						1:		-	71:
/joinkeys
    TECLEDR_RETCTR_NF  ,
	TECLEDR_RTY_NF     ,
	TECLEDR_PLC_NT  
/INFILE ${ESF_FPLACEMT2} 2000 1 "~"   
/joinkeys
    PLACEMT2_RETCTR_NF  ,
	PLACEMT2_RTY_NF     ,
	PLACEMT2_PLC_NT     
/JOIN UNPAIRED leftside	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	leftside:TECLEDR_ALL,
	rightside:PLACEMT2_RTO_NF,
	rightside:PLACEMT2_SSDRTO_B 
exit
EOF
SORT

##[018] Vider colonne _67 sauf pour la nouvelle condition "BALSHEY_NF = ${PARM_CONSOYEA} AND BALSHRMTH_NF > 9 AND GT_ANNUL_OPNG != "A" "

##[019] REVERT  /CONDITION VIDER_NEWCOLS5  (ORICOD_LS = "RECLASSP" or ORICOD_LS = "RECLASSL")  AND  ( BALSHEY_NF != ${PARM_CONSOYEA} OR BALSHRMTH_NF <= 9 OR GT_ANNUL_OPNG = "A" ) 

##[020] 

NSTEP=${NJOB}_22
#-----------------------------------------------------------------------------
LIBEL="GENERATE 2 files SANS_REJ_OPNG and AVEC_REJ_OPNG "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_FTECLEDR_RTO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RTO_SANS_REJ_OPNG.dat "
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RTO_AVEC_REJ_OPNG.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	BALSHEY_NF     3:1 -   3:EN,
	BALSHRMTH_NF   4:1 -   4:EN,
	TRNCOD_CF      6:1 -   6:,		
	TECLEDR_COL1-36					 1:1	-	36:,
	TECLEDR_RTO_NF					37:1	-	37:,
	ORICOD_LS       				57:1 	- 	57:,
	TECLEDR_COL38-54				38:1	-	54:,
	TECLEDR_COL56-66				56:1	-	66:,
    GT_ANNUL_OPNG   				67:1	- 	67:,
	TECLEDR_COL68-73				68:1	-	73:,
	PLACEMT2_RTO_NF		   		    72:1	-	72:,
	PLACEMT2_SSDRTO_B   			73:1	-	73:,
	COLS_STD_F1                   1:1 - 73:
/KEYS   COLS_STD_F1    	
/CONDITION ANNU_OPNG  (GT_ANNUL_OPNG = "A" or GT_ANNUL_OPNG = "O")
/OUTFILE ${SORT_O}
/OMIT ANNU_OPNG
/OUTFILE ${SORT_O2}
/INCLUDE ANNU_OPNG        
exit
EOF
SORT

NSTEP=${NJOB}_24
#-----------------------------------------------------------------------------
LIBEL="Join ${DFILT}/${NJOB}_22_${IB}_FTECLEDR_RTO_AVEC_REJ_OPNG.dat with PRS_ 740_FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_22_${IB}_FTECLEDR_RTO_AVEC_REJ_OPNG.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RTO_AVEC_REJ_OPNG_NOT_740.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS                                         
	BALSHEY_NF     3:1 -   3:EN,
	BALSHRMTH_NF   4:1 -   4:EN,
	TRNCOD_CF   6:1 -   6:,	
	TECLEDR_COL1-36					 1:1	-	36:,
	TECLEDR_RTO_NF					37:1	-	37:,
	ORICOD_LS       				57:1 	- 	57:,
	TECLEDR_COL38-54				38:1	-	54:,
	TECLEDR_COL56-66				56:1	-	66:,
    GT_ANNUL_OPNG   				67:1	- 	67:,
	TECLEDR_COL68-73				68:1	-	73:,
	PLACEMT2_RTO_NF		   		    72:1	-	72:,
	PLACEMT2_SSDRTO_B   			73:1	-	73:,                                             
        			COLS_STD_F1       1:1 - 73:,                                                                                                                                                                  
			  			PRS_CF_F2         1:1  - 1:,
			  			ACMTRS_NT_F2			2:1  - 2:,
			  			DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_08_${IB}_FTRSLNK_740.dat 2000 1 "~"       
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE ONLY        
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:COLS_STD_F1
	,rightside:PRS_CF_F2  
	,rightside:ACMTRS_NT_F2 	  							  
exit
EOF
SORT

NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="Join ${DFILT}/${NJOB}_22_${IB}_FTECLEDR_RTO_AVEC_REJ_OPNG.dat with PRS_ 740_FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_22_${IB}_FTECLEDR_RTO_AVEC_REJ_OPNG.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RTO_AVEC_REJ_OPNG_ET_PRS_740.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS                                         
	BALSHEY_NF     3:1 -   3:EN,
	BALSHRMTH_NF   4:1 -   4:EN,
	TRNCOD_CF   6:1 -   6:,	
	TECLEDR_COL1-36					 1:1	-	36:,
	TECLEDR_RTO_NF					37:1	-	37:,
	ORICOD_LS       				57:1 	- 	57:,
	TECLEDR_COL38-54				38:1	-	54:,
	TECLEDR_COL56-66				56:1	-	66:,
    GT_ANNUL_OPNG   				67:1	- 	67:,
	TECLEDR_COL68-73				68:1	-	73:,
	PLACEMT2_RTO_NF		   		    72:1	-	72:,
	PLACEMT2_SSDRTO_B   			73:1	-	73:,                                             
        			COLS_STD_F1       1:1 - 73:,                                                                                                                                                                  
			  			PRS_CF_F2         1:1  - 1:,
			  			ACMTRS_NT_F2			2:1  - 2:,
			  			DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_08_${IB}_FTRSLNK_740.dat 2000 1 "~"       
/joinkeys 
       DETTRS_CF_F2       
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:COLS_STD_F1
	,rightside:PRS_CF_F2  
	,rightside:ACMTRS_NT_F2 	  							  
exit
EOF
SORT



NSTEP=${NJOB}_28
#-----------------------------------------------------------------------------
LIBEL="MERGE ALL WITHOUT REJ_OPNG_740"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_22_${IB}_FTECLEDR_RTO_SANS_REJ_OPNG.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_25_${IB}_FTECLEDR_RTO_AVEC_REJ_OPNG_ET_PRS_740.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RTO_MERGE.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	BALSHEY_NF     3:1 -   3:EN,
	BALSHRMTH_NF   4:1 -   4:EN,
	TECLEDR_COL1-36					 1:1	-	36:,
	TECLEDR_RTO_NF					37:1	-	37:,
	ORICOD_LS       				57:1 	- 	57:,
	TECLEDR_COL38-54				38:1	-	54:,
	TECLEDR_COL56-66				56:1	-	66:,
    GT_ANNUL_OPNG   				67:1	- 	67:,
	TECLEDR_COL68-73				68:1	-	73:,
	PLACEMT2_RTO_NF		   		    72:1	-	72:,
	PLACEMT2_SSDRTO_B   			73:1	-	73:
/CONDITION COND_RTO PLACEMT2_RTO_NF != "O" 
/CONDITION COND_SSDRTO PLACEMT2_RTO_NF != "O" and PLACEMT2_SSDRTO_B !="0" and PLACEMT2_SSDRTO_B !="1"
/CONDITION VIDER_NEWCOLS5  (ORICOD_LS = "RECLASSP" or ORICOD_LS = "RECLASSL") 
/DERIVEDFIELD NEW_TECLEDR_RTO_NF 	if COND_RTO then  PLACEMT2_RTO_NF 	else TECLEDR_RTO_NF
/DERIVEDFIELD NEW_TECLEDR_SSDRTO_B 	if COND_SSDRTO then  "0" else PLACEMT2_SSDRTO_B  
/DERIVEDFIELD GT_ANNUL_OPNG_NEW if VIDER_NEWCOLS5 then "" else GT_ANNUL_OPNG   
/OUTFILE ${SORT_O}
/REFORMAT
	TECLEDR_COL1-36,
	NEW_TECLEDR_RTO_NF,
	TECLEDR_COL38-54,
	NEW_TECLEDR_SSDRTO_B,
	TECLEDR_COL56-66,
	GT_ANNUL_OPNG_NEW,
	TECLEDR_COL68-73
exit
EOF
SORT


NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="MERGE WITH  FTECLEDR_RTO_AVEC_REJ_OPNG_740"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_28_${IB}_FTECLEDR_RTO_MERGE.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_24_${IB}_FTECLEDR_RTO_AVEC_REJ_OPNG_NOT_740.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RTO.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	BALSHEY_NF     3:1 -   3:EN,
	BALSHRMTH_NF   4:1 -   4:EN,
	TECLEDR_COL1-36					 1:1	-	36:,
	TECLEDR_RTO_NF					37:1	-	37:,
	ORICOD_LS       				57:1 	- 	57:,
	TECLEDR_COL38-54				38:1	-	54:,
	TECLEDR_COL56-66				56:1	-	66:,
    GT_ANNUL_OPNG   				67:1	- 	67:,
	TECLEDR_COL68-73				68:1	-	73:,
	PLACEMT2_RTO_NF		   		    72:1	-	72:,
	PLACEMT2_SSDRTO_B   			73:1	-	73:
/CONDITION COND_RTO PLACEMT2_RTO_NF != "O" 
/CONDITION COND_SSDRTO PLACEMT2_RTO_NF != "O" and PLACEMT2_SSDRTO_B !="0" and PLACEMT2_SSDRTO_B !="1"
/DERIVEDFIELD NEW_TECLEDR_RTO_NF 	if COND_RTO then  PLACEMT2_RTO_NF 	else TECLEDR_RTO_NF
/DERIVEDFIELD NEW_TECLEDR_SSDRTO_B 	if COND_SSDRTO then  "0" else PLACEMT2_SSDRTO_B    
/OUTFILE ${SORT_O}
/REFORMAT
	TECLEDR_COL1-36,
	NEW_TECLEDR_RTO_NF,
	TECLEDR_COL38-54,
	NEW_TECLEDR_SSDRTO_B,
	TECLEDR_COL56-66,
	GT_ANNUL_OPNG,
	TECLEDR_COL68-73
exit
EOF
SORT

##[020] 


NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="replace CESU of  FTCLEDAR with CESU of ${ESF_FSSDACTR_TXT} ==> ${ESF_FTECLEDR_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_FTECLEDR_RTO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RTO.dat 2000 1"
##SORT_O=${ESF_FTECLEDR_OUT}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	TECLEDR_1-7           1 :1	-	7 :,
	TECLEDR_13-71           13 :1	-	71:,
	TECLEDR_CTR_NF                 8 :1	-	8 :,
	TECLEDR_END_NT                 9 :1	-	9 :,
	TECLEDR_SEC_NF                 10:1	-	10:,
	TECLEDR_UWY_NF                 11:1	-	11:,
	TECLEDR_UW_NT                  12:1	-	12:,
	TECLEDR_RETCTR_NF               24:1	-	24:,
	TECLEDR_RETEND_NT               25:1	-	25:,
	TECLEDR_RETSEC_NF               26:1	-	26:,
	TECLEDR_RTY_NF                  27:1	-	27:,
	TECLEDR_RETUW_NT                28:1	-	28:,
	TECLEDR_PLC_NT                  36:1	-	36:,
	SSDACTR_RETCTR_NF	  			1 :1	-	1 :,					
	SSDACTR_RTY_NF        			2 :1	-	2 :,
	SSDACTR_PLC_NT        			3 :1	-	3 :,
	SSDACTR_RETSEC_NF     			4 :1	-	4 :,
	SSDACTR_UW_NT         			5 :1	-	5 :,
	SSDACTR_CTR_NF        			6 :1	-	6 :,
	SSDACTR_UWY_NF        			7 :1	-	7 :,
	SSDACTR_SEC_NF        			8 :1	-	8 :,
	SSDACTR_END_NT        			9 :1	-	9 :,
	SSDACTR_CLISSD_NF     			10:1	-	10:,
	SSDACTR_RTOSSD_CF     			11:1	-	11:,
	SSDACTR_SSD_CF        			12:1	-	12:
/joinkeys
    TECLEDR_RETCTR_NF  ,
	TECLEDR_RTY_NF     ,
	TECLEDR_PLC_NT  ,
	TECLEDR_RETSEC_NF
/INFILE ${ESF_FSSDACTR_TXT} 2000 1 "~"   
/joinkeys
    SSDACTR_RETCTR_NF  ,
	SSDACTR_RTY_NF     ,
	SSDACTR_PLC_NT  ,
	SSDACTR_RETSEC_NF
/JOIN UNPAIRED leftside	
/OUTFILE ${SORT_O}
/REFORMAT
	leftside:TECLEDR_1-7,
	rightside:SSDACTR_CTR_NF          ,
	rightside:SSDACTR_END_NT          ,
	rightside:SSDACTR_SEC_NF          ,
	rightside:SSDACTR_UWY_NF          ,
	rightside:SSDACTR_UW_NT           ,
	leftside:TECLEDR_13-71  
exit
EOF
SORT



### # [021] Deb


NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="replace CESU of  FTCLEDR with CESU of ${ESF_FSSDACTR_TXT} ==> ${ESF_FTECLEDR_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_FTECLEDR_RTO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RTO_AVEC_FTRSLNK_751_PA_RECLASS.dat 2000 1"
##SORT_O=${ESF_FTECLEDR_OUT}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	TECLEDR_1-7           1 :1	-	7 :,
	TECLEDR_13-71     13 :1	-	71:,
	TRNCOD_CF         6:1	 -	6 :,
	COLS_STD_F1     	1:1	 - 71 :,					
	PRS_CF_F2         1:1  - 1:,
	ACMTRS_NT_F2			2:1  - 2:,
	DETTRS_CF_F2			3:1  - 3:	
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_05_${IB}_FTRSLNK_751_PA_RECLASS.dat 2000 1 "~"      
/joinkeys 
       DETTRS_CF_F2      
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:COLS_STD_F1
	,rightside:PRS_CF_F2  
	,rightside:ACMTRS_NT_F2 	  							  
exit
EOF
SORT


NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="replace CESU of  FTCLEDAR with CESU of ${ESF_FSSDACTR_TXT} ==> ${ESF_FTECLEDR_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_FTECLEDR_RTO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_RTO_SANS_FTRSLNK_751_PA_RECLASS.dat 2000 1"
##SORT_O=${ESF_FTECLEDR_OUT}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	TECLEDR_1-7           1 :1	-	7 :,
	TECLEDR_13-71     13 :1	-	71:,
	TRNCOD_CF         6:1	 -	6 :,
	COLS_STD_F1     	1:1	 - 71 :,					
	PRS_CF_F2         1:1  - 1:,
	ACMTRS_NT_F2			2:1  - 2:,
	DETTRS_CF_F2			3:1  - 3:	
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_05_${IB}_FTRSLNK_751_PA_RECLASS.dat 2000 1 "~"       
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE ONLY       
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:COLS_STD_F1
	,rightside:PRS_CF_F2  
	,rightside:ACMTRS_NT_F2 	  							  
exit
EOF
SORT

NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_FTECLEDR_RTO_AVEC_FTRSLNK_751_PA_RECLASS.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_RATE_RETRATE_I17.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF          11:1 - 11:,
        RETCUR_CF       34:1 - 34:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 71:

/joinkeys
      SSD_CF
           ,RETCUR_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_40_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"
/joinkeys
      CURQUOT_SSD_CF
           ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
           leftside:all_cols
          ,rightside:CURQUOT_RATE

exit
EOF
SORT




NSTEP=${NJOB}_90
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDR_RATE_RETRATE_I17.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_RATE_RETRATE_I17_FBOPRSLNK.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,        
        RETCUR_CF        34:1 - 34:
        
/KEYS  RETCTR_NF           
      ,RETEND_NT
      ,RETSEC_NF
      ,RTY_NF
      ,RETUW_NT

exit
EOF
SORT

##IRDPERICASE_PCP_EGP.dat


NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="Add cols data to GT format"
PRG=ESFC4070
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${ICLODAT_A}
GTF_CURQUOT_RATE 71
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_100_${IB}_IRDPERICASE_PCP_EGP.dat
export ${PRG}_I2=${DFILT}/${NJOB}_90_${IB}_SORT_FTECLEDR_RATE_RETRATE_I17_FBOPRSLNK.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_RATE_RETRATE_I17_FBOPRSLNK.dat
EXECPRG




NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
# Merge des fichiers
#------------------------------------------------------------------------------
LIBEL="Merge des fichiers et cumul sur Cle ==> ${ESF_FTECLEDR_OUT} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_FTECLEDR_RTO_SANS_FTRSLNK_751_PA_RECLASS.dat  2000 1"
SORT_I2="${DFILT}/${NJOB}_100_${IB}_ESFC4070_FTECLEDR_RATE_RETRATE_I17_FBOPRSLNK.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_ALL.dat 2000 1"
##SORT_O="${ESF_FTECLEDR_OUT}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	DBLTRNCOD_CF      7:1 -   7:,
	CTR_NF            8:1 -   8:,
	END_NT            9:1 -   9:,
	SEC_NF           10:1 -  10:,
	UWY_NF           11:1 -  11:,
	UW_NT            12:1 -  12:,
	OCCYEA_NF        13:1 -  13:EN,
	ACY_NF           14:1 -  14:EN,
	SCOSTRMTH_NF     15:1 -  15:EN,
	SCOENDMTH_NF     16:1 -  16:EN,
	CUR_CF           18:1 -  18:,
	AMT_M            19:1 -  19:EN 18/3,
	CED_NF           20:1 -  20:,
	RETCTR_NF        24:1 -  24:,
	RETEND_NT        25:1 -  25:,
	RETSEC_NF        26:1 -  26:,
	RTY_NF           27:1 -  27:,
	RETUW_NT         28:1 -  28:,
	RETOCCYEA_NF     29:1 -  29:EN,
	RETACY_NF        30:1 -  30:EN,
	RETSCOSTRMTH_NF  31:1 -  31:EN,
	RETSCOENDMTH_NF  32:1 -  32:EN,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 18/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
	TRN_NT           56:1 -  56:,
	ORICOD_LS        57:1 - 57:,	
  ALL               1:1 - 71:,
	GT_ANNUL_OPNG   67:1 - 67:,
	FILLER_1_66     1:1 - 66:,
	FILLER_68_71    68:1 - 71:,
	FILLER_1_71    1:1 - 71: 
/KEYS
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF,
	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT,
	OCCYEA_NF,
	ACY_NF,
	SCOSTRMTH_NF,
	SCOENDMTH_NF,
	CUR_CF,
	CED_NF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF,
	RETCUR_CF,
	PLC_NT,
	RTO_NF,
	TRN_NT
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT FILLER_1_71
exit
EOF
SORT



### # [021] Fin


NSTEP=${NJOB}_130
#------------------------------------------------------------------------------
# copy ESF_FTECLEDR_OUT  ==> $DFILP
#------------------------------------------------------------------------------
LIBEL="copy ${DFILT}/${NJOB}_120_${IB}_FTECLEDR_ALL.dat  ==>  ${ESF_FTECLEDR_OUT}"
EXECKSH_MODE=P
EXECKSH "cp ${DFILT}/${NJOB}_120_${IB}_FTECLEDR_ALL.dat ${ESF_FTECLEDR_OUT} "


NSTEP=${NJOB}_140
#------------------------------------------------------------------------------
# copy ESF_FTECLEDR_OUT  ==> $DFILP
#------------------------------------------------------------------------------
LIBEL="copy ${DFILT}/${NJOB}_120_${IB}_FTECLEDR_ALL.dat  ==>  ${ESF_FTECLEDR_OUT_ESFD4030}"
EXECKSH_MODE=P
EXECKSH "cp ${DFILT}/${NJOB}_120_${IB}_FTECLEDR_ALL.dat ${ESF_FTECLEDR_OUT_ESFD4030} "


JOBEND
