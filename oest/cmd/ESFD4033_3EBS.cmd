#!/bin/ksh
#=======================================================================
# nom de l'application          : GAAP Transformation REQ 20.1
# nom du script SHELL           : ESFD4033.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 04/01/2021
# auteur                        : Nhat Linh DOAN
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 83101  :  - conversion transcode from others GAAP
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 04/01/2021 NLD : SPIRA 83101 :  conversion transcode from others GAAP
#[002] 17/03/2021 NLD : SPIRA 83101 :  activate conversion I17 to I17
#[003] 26/03/2021 NLD : SPIRA 83101 :  fix new ICLODAT
#[004] 10/05/2021 NLD : SPIRA 83101 :  integrate EBS
#[005] 17/05/2021 NLD : SPIRA 96351 :  REQ20.1 - Exclude Life contracts
#[006] 29/06/2021 NLD : SPIRA 97350 :  REQ20.1 - Transaction generated several times.
#[007] 06/09/2021 NLD : SPIRA 97350 :  REQ20.1 - Transaction generated several times, update CRE_D et LSTUPD_D 
#[008] 26/01/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  : (for grouping 751=1010 ; 2010) AND ((Prof = 3 and CSM =1) OR  (Prof = 1 and LC =1)) 
#[009] 31/01/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  Ajout des colonnes  SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF dans la cle de jointure
#[010] 14/02/2022  HR : SPIRA 100677 : I17 - Criteria to compute Revenue / EXP / CSM
#[011] 21/02/2022 MZM : SPIRA 102371:  I17 Filtrer les fichiers I17 Par Normes (Ajout jointures avec les fichiers Pericases)  Annulation : Modif effectuee dans ESFD4037
#[012] 05/05/2022 JYP : SPIRA 100172:  internal retro, retinamt should be 0
#[013] 06/05/2022 MZM : SPIRA 85522:   MERGE AVEC PERICASE Au STEP _115
#[014] 11/05/2022 JYP : SPIRA 100172:  REVERT : internal retro retinamt should be 0
#[015] 06/05/2022 MZM : SPIRA 85522:   MERGE AVEC PERICASE Au STEP _115
#[016] 13/05/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  Ajout SCORTH  dans la cle de jointure au step _19A
#[017] 31/05/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  For Retro NP : Inversion des colonnes LC et CSM
#[018] 09/06/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  For Retro NP : Condition sur RETRO NP (Exclure sur les enreg Accept et Retro Prop) ; Exclure Regle Profitabilite
#[019] 28/06/2022 MZM : SPIRA 105131:  REQ20.1 - no calculation  Fix sur les doublons apres Step _19A Ajout Step _19O
#[020] 14/10/2022 MZM : SPIRA 107125:  REQ20.1 - RA / RR View - REQ 20.1
#[021] 08/11/2022 MZM : SPIRA 107520:  REQ20.1 -Spira 107520 Change Input file to avoid double offset : FILTER ON PRS 740 
#[022] 08/11/2022 MZM : SPIRA 107133:  REQ20.1 -Spira 107133 TRN_NT  EMPTY AND TRANSFORMATION Stored In column 104 
#[023] 10/11/2022 MZM : SPIRA 107125:  REQ20.1 - RA / RR View - REQ 20.1 GENERER FTECLEDR A PARTIR DU FTECLEDA
#[024] 10/11/2022 MZM : SPIRA 107687:  REQ20.1 - TECHNICAL CHANGE : 2010,2013,2019,1016,1017
#[025] 30/01/2023 MZM : SPIRA 108631:  REQ 20.1 - Change Input file to avoid double offset - Copy : Prise en compte des Annulations PRS_740
#[026] 09/02/2023 MZM : SPIRA 108737:  INT - Missing Retrocessionaire in RR view for I17 transactions : MAPPING SUR FICHIER ESCJ0660_FPLATCUMALL0
#[027] 13/03/2023 MZM : SPIRA 107134   INT - Missing Retrocessionaire in RR view for I17 transactions : Variabilisation du Fichier FPLATXCUM (ALL ou CUM) en entree du ESTC1052B
#[028] 27/03/2023 MZM : SPIRA 108587   Mixed retro : AEs are wrong in RA view : Ajout du cumul sur cle total apres appel du ESTC1052B au step _38 
#[029] 03/04/2023 MZM : SPIRA 109394   Criteria to compute I4 to I17 transformation not properly applied
#[030] 07/04/2023 MZM : SPIRA 108576   20.1 - FD new update ; Generation des LC / CSM Annulables pour I17
#[031] 11/04/2023 MZM : SPIRA 108942   20.1 - Delta Posting - strange delta
#[032] 14/04/2023 MZM : SPIRA 108576   20.1 - FD new update  Generation des LC / CSM Annulables pour I17 : Grouping "1016" et "1017" Pour Tout
#[033] 22/05/2023 MZM : SPIRA 109559   20.1 - I17 - IFRS4 cancel calculated on retro NP with Q-1 CSM pattern at 1 : Modif du Step _19O pour filtre que Ass et Retro Prop
#[034] 04/07/2023 MZM : SPIRA 110070   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping QUE POUR EBS : "1041" OR "1051" OR "2041" OR "2044" OR "2051" OR "2054" et des conditions  [abs(CSM ending) + abs(LC ending)] 
#[035] 17/07/2023 MZM : SPIRA 110198   20.1 - I17 - REQ 20.1 - Update on Reclass conditions  [abs(CSM ending) + abs(LC ending)] 
#[036] 02/08/2023 MZM : SPIRA 110198   20.1 - I17 - REQ 20.1 - Update on Reclass conditions  [abs(CSM ending) + abs(LC ending)] Fix Sur Doublons CSM LC AMORT
#[037] 11/10/2023 MZM : SPIRA 110675   20.1 - I17 - REQ 20.1 - remove content of NEWCOLS5_NF on reclass transactions
#[038] 04/07/2023 MZM : SPIRA 109797   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping  : "4200" OR "4220" 
#[039] 04/07/2023 MZM : SPIRA 110789   20.1 - I17 -REQ 20.1 - Reclass still calculated when it shouldn't be : Ajout filtre avant jointure avec le Pericae RETRO
#[040] 11/01/2024 MZM : SPIRA 111113   20.1 - I17 -REQ 20.1  Fix Ano PROD
#[041] 16/01/2023 MZM : SPIRA 110217   20.1 - I17 -REQ 20.1 - 17 - Add the LC reclass to the IO auto generation : Prise en compte des Grouping  que pour les AI
#[042] 29/01/2024 MZM : SPIRA 109797   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping   "4200" OR "4220" 
#[043] 29/01/2023 MZM : SPIRA 111191   20.1 - I17 - Add the LC reclass to the IO auto generation - Revert
#==============================================================================

# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT




EST_BASE=`basename ${ESF_FTECLEDA_OUT%.*}`
ICLODAT_M0=$(($ICLODAT_MTH - 2))


## [026]FinAjout des PLC_NT et RTO 


## [034] Apply Transformation to EBS

NSTEP=${NJOB}_45
#------------------------------------------------------------------------------------
LIBEL="Excluse Life ${EPO_FTECLEDA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        BALSHEY_NF        3:1 -   3:EN,
        BALSHRMTH_NF      4:1 -   4:EN,
        DETTRS_CF        6:1 - 6:,
        LOBACC_CF       45:1 - 45:

/KEYS   DETTRS_CF
/CONDITION VIE ( LOBACC_CF="30" OR LOBACC_CF="31" ) or (BALSHRMTH_NF < ${ICLODAT_MTH}) or ( BALSHRMTH_NF > ${ICLODAT_MTH} ) or (BALSHEY_NF != ${ICLODAT_YEA} )

/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
exit
EOF
SORT



## [034] DEB GENERATION MOUVEMENTS EBS LC OU CSM ANNULABLES

NSTEP=${NJOB}_45A
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_${EST_BASE}_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_EBS_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN         
/KEYS   
         CTR_NF 
        ,END_NF              
				,SEC_NF   
				,UWY_NF   
				,UW_NT    
				,RETCTR_NF
				,RETEND_NT
				,RETSEC_NF
				,RTY_NF   
				,RETUW_NT  
/OUTFILE ${SORT_O}				          
exit
EOF
SORT


#####

  

NSTEP=${NJOB}_46
# Join AND Extend EBS_NOLIFE  with PRS_751 of _FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join EBS_NOLIFE.dat with PRS_ 751 and _FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45A_${IB}_${EST_BASE}_SORT_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_05_${IB}_FTRSLNK_751_EBS.dat 2000 1 "~"        
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


NSTEP=${NJOB}_46A
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_46_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_EBS_NOLIFE_RSLNK_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN         
/KEYS   
         CTR_NF
        ,END_NF   
				,SEC_NF   
				,UWY_NF   
				,UW_NT    
				,RETCTR_NF
				,RETEND_NT
				,RETSEC_NF
				,RTY_NF   
				,RETUW_NT            
/OUTFILE ${SORT_O}
exit
EOF
SORT


## IDENTIFICATION DES CONTRATS RETRO PROP ELIGIBLES A LA TRANSFORMATION (TRNCOD1 = 2 ou 4)
## Pour les lignes RETRO de cet ensemble, les exclure du ESFD4035 avant la TRANSFORMATION) 



NSTEP=${NJOB}_47C
# Join AND Extend ${ESF_FTECLEDA_OUT}_EBS_NOLIFE with CSM LC PROFITABLE
#-----------------------------------------------------------------------------
LIBEL="Join ${ESF_FTECLEDA_OUT}_EBS_NOLIFE.dat WITH ESFD3750_ESFD3770_PROFIT_CSM_LC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_46A_${IB}_${EST_BASE}_SORT_EBS_NOLIFE_RSLNK_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        NATRET_CF        52:1 - 52:,                                                     
        ALL_COLS_F1      1:1 - 121:, 
        CTR_NF_F2         1:1 -  1:,
        SEC_NF_F2         2:1 -  2:,
        UWY_NF_F2         3:1 -  3:,
        UW_NT_F2          4:1 -  4:,
				ASS_RET_F2        5:1 -  5:,	
				RETRO_NP_F2       6:1 -  6:,
				LC_F2             7:1 -  7:,				
				CSM_F2            8:1 -  8:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:													         
/joinkeys CTR_NF,      
          SEC_NF,   
          UWY_NF,
          UW_NT                    
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_16G_${IB}_PROF_CSM_LC_AMORT_PATTERN_CSM_LC_ENDING.dat 2000 1 "~" 
/joinkeys CTR_NF_F2,       
          SEC_NF_F2,    
          UWY_NF_F2,
          UW_NT_F2                     
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT


NSTEP=${NJOB}_47D
# Join AND Extend ${ESF_FTECLEDA_OUT}_EBS_NOLIFE with RETRO NP CSM
#-----------------------------------------------------------------------------
LIBEL="Join ${ESF_FTECLEDA_OUT}_EBS_NOLIFE.dat WITH ESFD3750_ESFD3770_ with RETRO NP CSM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_46A_${IB}_${EST_BASE}_SORT_EBS_NOLIFE_RSLNK_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_PROF_CSM_RNP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,  
        NATRET_CF        52:1 - 52:,                                            
        ALL_COLS_F1      1:1 - 121:, 
        CTR_NF_F2         1:1 -  1:,
        SEC_NF_F2         2:1 -  2:,
        UWY_NF_F2         3:1 -  3:,
        UW_NT_F2          4:1 -  4:,
				ASS_RET_F2        5:1 -  5:,	
				RETRO_NP_F2       6:1 -  6:,
				LC_F2             7:1 -  7:,				
				CSM_F2            8:1 -  8:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:													         
/joinkeys RETCTR_NF,      
          RETSEC_NF,   
          RTY_NF,
          RETUW_NT                    
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_16I_${IB}_PROF_CSM_AMORT_PATTERN_CSM_ENDING_RNP.dat 2000 1 "~" 
/joinkeys CTR_NF_F2,       
          SEC_NF_F2,    
          UWY_NF_F2,
          UW_NT_F2                     
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT



NSTEP=${NJOB}_47A
# FILTER ACCEPT AND RETRO PROP ONLY
#-----------------------------------------------------------------------------
LIBEL="FILTER ON ACCEPT AND RETRO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_47C_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE_ASS.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE_RETRO.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,  
        NATRET_CF        52:1 - 52:,                                            
        ALL_COLS_F1      1:1 - 121:                             

/CONDITION GRP_ASS (TRNCOD1_CF='1')
/CONDITION GRP_RET (TRNCOD1_CF='2')

/OUTFILE ${SORT_O}
/INCLUDE GRP_ASS

/OUTFILE ${SORT_O2}
/INCLUDE GRP_RET
exit
EOF
SORT



NSTEP=${NJOB}_47B
LIBEL="GENERATE FIELD WITHOUT RETRO NP FROM IRDPERICASE0  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_47A_${IB}_PROF_CSM_LC_EBS_NOLIFE_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE_RETRO.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	GT_RETCTR_NF 			24:1 	- 24:,
	GT_RETEND_NT			25:1 	- 25:,
	GT_RETSEC_NF 			26:1 	- 26:,
	GT_RETRTY_NF 			27:1 	- 27:,
	GT_RETUW_NT 			28:1 	- 28:,
	CTR_NF   				3:1 	- 3:,
	END_NT   				4:1 	- 4:,
	SEC_NF  				5:1 	- 5:,
	UWY_NF   				6:1 	- 6:,
	UW_NT    				7:1 	- 7:,
	NATRET_CF    		49:1 	- 49:,	
	FILLER					1:1		- 122:	
/JOINKEYS
	GT_RETCTR_NF,    
	GT_RETEND_NT,    
	GT_RETSEC_NF,    
	GT_RETRTY_NF,    
	GT_RETUW_NT		
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_12_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1 "~" 
/JOINKEYS
	CTR_NF,     
	END_NT,     
	SEC_NF,     
	UWY_NF,     
	UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:NATRET_CF
exit
EOF
SORT


NSTEP=${NJOB}_47E
LIBEL="MERGE ASS With RETRO  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_47A_${IB}_PROF_CSM_LC_EBS_NOLIFE_ASS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_47B_${IB}_PROF_CSM_LC_EBS_NOLIFE_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	GT_RETCTR_NF 			24:1 	- 24:,
	GT_RETEND_NT			25:1 	- 25:,
	GT_RETSEC_NF 			26:1 	- 26:,
	GT_RETRTY_NF 			27:1 	- 27:,
	GT_RETUW_NT 			28:1 	- 28:,
	CTR_NF   				3:1 	- 3:,
	END_NT   				4:1 	- 4:,
	SEC_NF  				5:1 	- 5:,
	UWY_NF   				6:1 	- 6:,
	UW_NT    				7:1 	- 7:,
	NATRET_CF    		49:1 	- 49:,	
	FILLER					1:1		- 122:	

/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT



## [036]

NSTEP=${NJOB}_47F
# SORT UNIQUE of  file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of EBS_NOLIFE_PROF_CSM_LC.dat BEFORE JOIN  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_47E_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS         
        CTR_NF            8:1 -  8:,
        END_NF            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:
/KEYS   
         CTR_NF  
				,SEC_NF   
				,UWY_NF   
				,UW_NT                  
/OUTFILE ${SORT_O}
exit
EOF
SORT

## [036] /INFILE ${DFILT}/${NJOB}_47E_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1 "~"



##[041]



## [036]SORT_I="${DFILT}/${NJOB}_49A_${IB}_${EST_BASE}_EBS_NOLIFE_PROF_CSM_LC.dat 2000 1"

NSTEP=${NJOB}_49O
# SORT UNIQUE of  file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of EBS_NOLIFE_PROF_CSM_LC.dat  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_47F_${IB}_PROF_CSM_LC_EBS_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_PROF_CSM_LC.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		1:1 - 126:,
        NATRET_CF    	52:1 - 52:
/KEYS   ALL_F1
/CONDITION  REMOVE_RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  )                
/OUTFILE ${SORT_O}
/OMIT REMOVE_RETRO_NP
exit
EOF
SORT 


#[015]

NSTEP=${NJOB}_49B
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements CSM LC PROFITABLES"
AWK_I=${DFILT}/${NJOB}_49O_${IB}_${EST_BASE}_EBS_NOLIFE_PROF_CSM_LC.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_PROF_CSM_LC_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if ( \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        if ( \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);         
        print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_49C
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements CSM RNP "
AWK_I=${DFILT}/${NJOB}_47D_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_PROF_CSM_RNP.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_PROF_CSM_RNP_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19);
        if ( \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35);
        if ( \$88 != 0)   \$88 = sprintf("%-.3lf",-\$88);        
        print \$0;
  }
exit
EOF
AWK


##[043] REvert LC Assume

NSTEP=${NJOB}_49D
# Remove Grouping 751 1010 1020 AND CSM LC Prof AND AI AUTO GENERATION  from ${ESF_FTECLEDA_OUT}_EBS_NOLIFE
#-----------------------------------------------------------------------------
LIBEL=" UPDATE ${ESF_FTECLEDA_OUT}_EBS_NOLIFE WITH cancellables mouvements "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_${EST_BASE}_EBS_NOLIFE.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_49B_${IB}_${EST_BASE}_EBS_NOLIFE_PROF_CSM_LC_AWK.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_49C_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_PROF_CSM_RNP_AWK.dat 2000 1"
##SORT_I4="${DFILT}/${NJOB}_49U_${IB}_${EST_BASE}_EBS_NOLIFE_RSLNK_O_AI_AWK.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_NOLIFE_NO_PROF_CSM_LC.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
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
  CRE_D            41:1 -  41:,
  NATRET_CF        52:1 -  52:,
	RETINTAMT_M      88:1 -  88:EN 18/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:
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
	CRE_D,
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0) 
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT	      



NSTEP=${NJOB}_50
#------------------------------------------------------------------------------------
LIBEL="Apply transformation to ${EPO_FTECLEDA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_49D_${IB}_${EST_BASE}_EBS_NOLIFE_NO_PROF_CSM_LC.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        S_DETTRS_CF       6:1 - 6:,
        S_HEAD            1:1 - 2:,
        ORIDETTRS_CF      3:1 - 3:,
        TARGDETTRS_CF     6:1 - 6:,
        MAPTYP_CT         7:1 - 7: EN,
	S_MID1            8:1 - 40:,
	S_MID2            45:1 - 88:,
	TRN_NT		        103:1 - 103:,	
	S_TAIL1           105:1 - 110:,
  S_TAIL2     			113:1 - 118:
/DERIVEDFIELD GAAPCOD_NEW 2"~"
/DERIVEDFIELD COLS14_NEW 14"~"
/DERIVEDFIELD SEPARATEUR   "~"
/DERIVEDFIELD ORICOD_NEW   "RECLASSP~"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_YEA}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_MTH}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_DAY}~"
/DERIVEDFIELD CRE_NEW "${PARM_CRE_D}~CloP~${PARM_CRE_D}~CloP~"
/DERIVEDFIELD TRN_NT_NEW "~"
/JOINKEYS
        S_DETTRS_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_10_${IB}_GAAPMAP_EBS.dat 2000 1 "~"
/JOINKEYS
        ORIDETTRS_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW, rightside : TARGDETTRS_CF, SEPARATEUR,leftside : S_MID1, CRE_NEW , leftside : S_MID2, COLS14_NEW,leftside : TRN_NT_NEW, ORICOD_NEW,   leftside : S_TAIL1,GAAPCOD_NEW, leftside : S_TAIL2,rightside : MAPTYP_CT
exit
EOF
SORT





NSTEP=${NJOB}_52
#-----------------------------------------------------------------------------
LIBEL="Transforme using Sign"
AWK_I=${DFILT}/${NJOB}_50_${IB}_${EST_BASE}_EBS.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
	if (\$119 == "-1" && \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19); 
	if (\$119 == "-1" && \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35); 
	print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_55
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing GTAR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_52_${IB}_${EST_BASE}_EBS_AWK.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS_AWK.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:EN,
        RTY_NF 27:1 - 27:,
		    PLC_NT 36:1 - 36:EN 15/3,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:EN,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        RETAMT_M 35:1 - 35:EN 15/3,
        RETINTAMT_M 88:1 - 88:EN 15/3,
        GT_ANNUL_OPNG   114:1 - 114:              
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        PLC_NT,
        RETEND_NT,
        RETUW_NT,
        RETCUR_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,
        TRNCOD_CF                
/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT



NSTEP=${NJOB}_57
# Affectation par placement DES MVTS IFRS17
#-----------------------------------------------------------------------------
LIBEL=" AGREGATES retro Affectation MVT IFRS17 par placement "
PRG=ESTC1052B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
FPLATXCUM ALL
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_35_${IB}_FPLATXCUMALL0.dat"
export ${PRG}_I2="${DFILT}/${NJOB}_55_${IB}_${EST_BASE}_EBS_AWK.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_${PRG}_EBS.dat"
EXECPRG


NSTEP=${NJOB}_60
#------------------------------------------------------------------------------------
LIBEL="Summarize on Key "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_57_${IB}_${EST_BASE}_ESTC1052B_EBS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_EBS.dat 2000 1"
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
  CRE_D            41:1 -  41:,
	RETINTAMT_M      88:1 -  88:EN 18/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:,
	GT_ANNUL_OPNG   114:1 - 114:	
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
	CRE_D,
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B,
	GT_ANNUL_OPNG
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT



## FIN  GENERATION MOUVEMENTS IFRS17 LC OU CSM ANNULABLE



## [034] 


NSTEP=${NJOB}_70
#------------------------------------------------------------------------------------
LIBEL="merg files to ouput ${ESF_FTECLEDA_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_${EST_BASE}_EBS.dat 2000 1"
SORT_O="${ESF_FTECLEDA_70_EBS}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 - 1:,
        ESB_CF            2:1 - 2:,
        DETTRS_CF         6:1 - 6:,
        ALL               1:1 - 118:
/KEYS   SSD_CF,
        ESB_CF,
        DETTRS_CF
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT ALL
exit
EOF
SORT





JOBEND
