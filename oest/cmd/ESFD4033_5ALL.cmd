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
#[044] 16/05/2024 MZM : SPIRA 111009   20.1 - I17 - FIX ITK NUMERO Spira CORRECT
#[045] 22/05/2024 MZM : SPIRA 111206   20.1 - I17 - Remaining gaps on REQ 20.1
#==============================================================================

# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

EST_BASE=`basename ${ESF_FTECLEDA_OUT%.*}`

###  Generation des MOUVEMENTS LC AI IFRS17 ###

#--------------------------------------------
NSTEP=${NJOB}_103
# summarize TTECLEDA by BALSHTDAY
#--------------------------------
LIBEL="AGGREGATION I4I, EBS et IFRS17 RECLASS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_40_IFRS4}  2000 1"
SORT_I2="${ESF_FTECLEDA_70_EBS}  2000 1"
SORT_I3="${ESF_FTECLEDA_100_IFRS17}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
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
	ALL               1:1 - 118:
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
/OUTFILE ${SORT_O}
/REFORMAT ALL
exit
EOF
SORT

## Recuperer les Annulations (et Ouvertures) et filtre sur 740 ==> Les Inclure

NSTEP=${NJOB}_104
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="SGenerated 2 files With REJ_OPNG and Without..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_103_${IB}_${EST_BASE}_ALL.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_SANS_REJ_OPNG.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
							SSD_CF          		  1:1 -   1:,      
							ESB_CF          		  2:1 -   2:,      
							BALSHEY_NF      		  3:1 -   3:,      
							BALSHRMTH_NF    		  4:1 -   4:,      
							TRNCOD_CF     		  6:1 -   6:,        
							DBLTRNCOD_CF    		  7:1 -   7:,        
							CTR_NF          		  8:1 -   8:,        
							END_NT          		  9:1 -   9:,        
							SEC_NF          		 10:1 -  10:,        
							UWY_NF          		 11:1 -  11:,        
							UW_NT           		 12:1 -  12:,        
							OCCYEA_NF       		 13:1 -  13:,      
							ACY_NF          		 14:1 -  14:,      
							SCOSTRMTH_NF    		 15:1 -  15:,      
							SCOENDMTH_NF    		 16:1 -  16:,      
							CUR_CF          		 18:1 -  18:,        
							CED_NF          		 20:1 -  20:,        
							RETCTR_NF       		 24:1 -  24:,        
							RETEND_NT       		 25:1 -  25:,        
							RETSEC_NF       		 26:1 -  26:,        
							RTY_NF          		 27:1 -  27:,        
							RETUW_NT        		 28:1 -  28:,        
							RETOCCYEA_NF    		 29:1 -  29:,      
							RETACY_NF       		 30:1 -  30:,      
							RETSCOSTRMTH_NF 		 31:1 -  31:,      
							RETSCOENDMTH_NF 		 32:1 -  32:,      
							RETCUR_CF       		 34:1 -  34:,        
							PLC_NT          		 36:1 -  36:,        
							RTO_NF          		 37:1 -  37:,        
							ZZRECONKEY_CF   		102:1 - 102:,        
							TRN_NT          		103:1 - 103:,        
							ORICOD_LS       		104:1 - 104:,        
							RETROAUTO_B     		105:1 - 105:,        
							SPEENTNAT_CT    		106:1 - 106:,        
							EVT_NF          		107:1 - 107:,        
							REVT_NF         		108:1 - 108:,        
							RETARDRETINT_B  		109:1 - 109:,
              GT_ANNUL_OPNG   		114:1 - 114:           
                           
/KEYS  	 CTR_NF          	
				,END_NT          	
				,SEC_NF          	
				,UWY_NF          	
				,UW_NT           	
				,OCCYEA_NF       	
				,ACY_NF          	
				,SCOSTRMTH_NF    	
				,SCOENDMTH_NF    	
				,CUR_CF          	
				,CED_NF          	
				,RETCTR_NF       	
				,RETEND_NT       	
				,RETSEC_NF       	
				,RTY_NF          	
				,RETUW_NT        	
				,RETOCCYEA_NF    	
				,RETACY_NF       	
				,RETSCOSTRMTH_NF 	
				,RETSCOENDMTH_NF 	
				,RETCUR_CF       	
				,PLC_NT          	
				,TRNCOD_CF                
/CONDITION ANNU_OPNG  (GT_ANNUL_OPNG = "A" or GT_ANNUL_OPNG = "O")
/OUTFILE ${SORT_O} overwrite
/OMIT ANNU_OPNG
/OUTFILE ${SORT_O2} overwrite
/INCLUDE ANNU_OPNG
exit
EOF
SORT

#[045] Modification : /JOIN UNPAIRED LEFTSIDE ONLY

NSTEP=${NJOB}_105
#-----------------------------------------------------------------------------
LIBEL="Join ${DFILT}/${NJOB}_104_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG.dat with PRS_ 740_FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_104_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG_740.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS                                         
							SSD_CF          		  1:1 -   1:, 
							ESB_CF          		  2:1 -   2:, 
							BALSHEY_NF      		  3:1 -   3:, 
							BALSHRMTH_NF    		  4:1 -   4:, 
							TRNCOD_CF       		  6:1 -   6:, 
							DBLTRNCOD_CF    		  7:1 -   7:, 
							CTR_NF          		  8:1 -   8:, 
							END_NT          		  9:1 -   9:, 
							SEC_NF          		 10:1 -  10:, 
							UWY_NF          		 11:1 -  11:, 
							UW_NT           		 12:1 -  12:, 
							OCCYEA_NF       		 13:1 -  13:, 
							ACY_NF          		 14:1 -  14:, 
							SCOSTRMTH_NF    		 15:1 -  15:, 
							SCOENDMTH_NF    		 16:1 -  16:, 
							CUR_CF          		 18:1 -  18:, 
							CED_NF          		 20:1 -  20:, 
							RETCTR_NF       		 24:1 -  24:, 
							RETEND_NT       		 25:1 -  25:, 
							RETSEC_NF       		 26:1 -  26:, 
							RTY_NF          		 27:1 -  27:, 
							RETUW_NT        		 28:1 -  28:, 
							RETOCCYEA_NF    		 29:1 -  29:, 
							RETACY_NF       		 30:1 -  30:, 
							RETSCOSTRMTH_NF 		 31:1 -  31:, 
							RETSCOENDMTH_NF 		 32:1 -  32:, 
							RETCUR_CF       		 34:1 -  34:, 
							PLC_NT          		 36:1 -  36:, 
							RTO_NF          		 37:1 -  37:, 
							ZZRECONKEY_CF   		102:1 - 102:, 
							TRN_NT          		103:1 - 103:, 
							ORICOD_LS       		104:1 - 104:, 
							RETROAUTO_B     		105:1 - 105:, 
							SPEENTNAT_CT    		106:1 - 106:, 
							EVT_NF          		107:1 - 107:, 
							REVT_NF         		108:1 - 108:, 
							RETARDRETINT_B  		109:1 - 109:, 
              GT_ANNUL_OPNG   		114:1 - 114:,                                              
        			COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
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


## Prise en compte des Annulations du PRS 740 et cumul sur CLE

##[037] Vider le champs _114 POur Les RECLASS

## [044]  Vider colonne _114 Sauf pour les Annulations du PRS _740

NSTEP=${NJOB}_107
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Aggregation  et Des SANS_REJ_OPNG  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_104_${IB}_${EST_BASE}_ALL_SANS_REJ_OPNG.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_SANS_REJ_OPNG.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_SANS_REJ_OPNG_DELTA.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
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
	FILLER_1_124    1:1 - 124:,
	GT_ANNUL_OPNG   114:1 - 114:,
	FILLER_1_113    1:1 - 113:,
	FILLER_115_124  115:1 -124:
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
/CONDITION VIDER_NEWCOLS5  (ORICOD_LS = "RECLASSP" or ORICOD_LS = "RECLASSL")        
/DERIVEDFIELD GT_ANNUL_OPNG_NEW if VIDER_NEWCOLS5 then "" else GT_ANNUL_OPNG
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT FILLER_1_124
/OUTFILE ${SORT_O2}
/INCLUDE RESTRICTION
/REFORMAT FILLER_1_113, GT_ANNUL_OPNG_NEW, FILLER_115_124
exit
EOF
SORT

## SORT_I2="${DFILT}/${NJOB}_105_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG_740.dat 2000 1"

NSTEP=${NJOB}_108
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Aggregation REJ_OPNG_740  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_105_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG_740.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG_740.dat  2000 1"
INPUT_TEXT $SORT_CMD <<EOF
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
	ORICOD_LS        103:1 - 103:,	
	GT_ANNUL_OPNG   104:1 - 104:,
  ALL               1:1 - 118:	
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
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M
/OUTFILE ${SORT_O} 
/INCLUDE RESTRICTION
/REFORMAT ALL
exit
EOF
SORT

## MERGE DES REJ_OPNG_740 et RECLASS AUTRE



NSTEP=${NJOB}_109
#------------------------------------------------------------------------------------
LIBEL="MERGE DES REJ_OPNG_740 et RECLASS AUTRE POR FICHIER DE VERIF DES RECLASS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_107_${IB}_${EST_BASE}_ALL_SANS_REJ_OPNG_DELTA.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_108_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG_740.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL_DELTA.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
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
	ORICOD_LS        103:1 - 103:,	
	GT_ANNUL_OPNG   104:1 - 104:,
  ALL               1:1 - 118:	
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
exit
EOF
SORT


NSTEP=${NJOB}_110
#------------------------------------------------------------------------------------
LIBEL="MERGE DES REJ_OPNG_740 et RECLASS AUTRE POUR SUITE TRAITEMENT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_107_${IB}_${EST_BASE}_ALL_SANS_REJ_OPNG.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_108_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG_740.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
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
	ORICOD_LS        103:1 - 103:,	
	GT_ANNUL_OPNG   104:1 - 104:,
  ALL               1:1 - 118:	
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
exit
EOF
SORT


EXECKSH "cp ${DFILT}/${NJOB}_109_${IB}_${EST_BASE}_ALL_DELTA.dat ${ESF_FTECLEDA_DELTA}"

# [044] Fin Modif 

### DEB Merge Fusion PERICASE STD


## Ajout du Merge DU PERICASE ASS et Retro avec le fichier  "${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL.dat  2000 1" Avec PERICASE STANDART ACC / RET


#[013] DEB JOINTURE DES FICHIERS AVEC LES PERICASES

NSTEP=${NJOB}_115

LIBEL="Generate Assume and Retro files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_${EST_BASE}_ALL_ASS.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_${EST_BASE}_ALL_RET.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        ACY_NF           14:1 - 14:,
        TRNCOD_CF         6:1 -  6:,
	      TRNCOD1_CF	  		6:1 -  6:1,
	      TRNCOD8_CF	  		6:8 -  6:8,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        ACMTRS_NT        42:1 - 42:,
				ACMTRSL3_NT      52:1 - 52:,
        AMT_M            19:1 - 19:EN 15/3,
        RETAMT_M         35:1 - 35:EN 15/3,
        RETINTAMT_M      41:1 - 41:EN 15/3

/CONDITION GRP_ASS (TRNCOD1_CF='1')
/CONDITION GRP_RET (TRNCOD1_CF='2')

/OUTFILE ${SORT_O}
/INCLUDE GRP_ASS

/OUTFILE ${SORT_O2}
/INCLUDE GRP_RET
exit
EOF
SORT

# [013]#${DFILT}/${NJOB}_23_${IB}_SORT_IADPERICASE_I17_MERGE_O.dat
#${ESF_IRDVPERICASE}

#[013] JOINTURE DES FICHIERS AVEC LES PERICASES

if [ "${IDF_CT}" != "EBS_GAP_MAP_STD" ] 
then

NSTEP=${NJOB}_116
# Join  PERICASE Assume with SORT_${EST_BASE}_ALL_ASS by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="PERICASE Assumed ${EST_BASE}_ALL_ASS, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_115_${IB}_SORT_${EST_BASE}_ALL_ASS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_${EST_BASE}_ALL_ASS.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF_F1        		8:1 - 8:,  
        END_NT_F1        		9:1 - 9:,
        SEC_NF_F1        		10:1 - 10:,
        UWY_NF_F1        		11:1 - 11:,
        UW_NT_F1         		12:1 - 12:,
        FIELD_1_45_F1    		1:1  - 45:,
        SEG_NF_F1 		      46:1 - 46:,           
        LOB_CF_F1 		      47:1 - 47:,                    
        NAT_CF_F1           48:1 - 48:, 
        TYP_CT_F1           49:1 - 49:,                                             
        FIELD_1_118_F1    	 1:1 - 118:,
        CTR_NF_F2 			 	  3:1 -  3:, 
        END_NT_F2           4:1 -  4:,                  
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:			       		          
/JOINKEYS CTR_NF_F1,
					END_NT_F1,
          SEC_NF_F1,
          UWY_NF_F1,
          UW_NT_F1            
/INFILE ${ESF_IADVPERICASE} 2000 1 "~"                 
/JOINKEYS CTR_NF_F2,
          END_NT_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2                         
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FIELD_1_118_F1
exit
EOF
SORT 


NSTEP=${NJOB}_118
# Join  PERICASE Assume with SORT_${EST_BASE}_ALL_RET by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="PERICASE Assumed ${EST_BASE}_ALL_RET, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_115_${IB}_SORT_${EST_BASE}_ALL_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_${EST_BASE}_ALL_RET.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF_F1        24:1 - 24:,  
        RETEND_NT_F1        25:1 - 25:EN,
        RETSEC_NF_F1        26:1 - 26:,
        RTY_NF_F1           27:1 - 27:,
        RETUW_NT_F1         28:1 - 28:,
        FILED_1_118_F1       1:1 - 118:,        
        CTR_NF_F2 			 	  3:1 -  3:,                   
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:      		          
/JOINKEYS RETCTR_NF_F1,
          RETSEC_NF_F1,
          RTY_NF_F1,
          RETUW_NT_F1  
/INFILE ${ESF_IRDVPERICASE} 2000 1 "~"          
/JOINKEYS CTR_NF_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2           
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FILED_1_118_F1
exit
EOF
SORT

NSTEP=${NJOB}_119
#------------------------------------------------------------------------------------
LIBEL="Fusion des ASS et RET"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_116_${IB}_SORT_${EST_BASE}_ALL_ASS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_118_${IB}_SORT_${EST_BASE}_ALL_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25:,
        RETSEC_NF   26:1 - 26:,
        RTY_NF      27:1 - 27:,
        RETUW_NT    28:1 - 28:,
        LOBRET_CF   46:1 - 46:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION VIE ( LOBRET_CF="30" OR LOBRET_CF="31")
/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
exit
EOF
SORT

fi

#[013] FIN JOINTURE DES FICHIERS AVEC LES PERICASES


NSTEP=${NJOB}_120

LIBEL="Sort GLT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA} 2000 1"
if [ "${IDF_CT}" != "EBS_GAP_MAP_STD" ] 
then
SORT_I2="${DFILT}/${NJOB}_119_${IB}_${EST_BASE}_ALL.dat  2000 1" 
else
SORT_I2="${ESF_FTECLEDA_DELTA}  2000 1"

fi 
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
	CUR_CF           18:1 -  18:,
	RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT	48:1 - 48:,
	ACCRET_CF 	49:1 - 49:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
	RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
	ACCRET_CF,
	SEGNAT_CT,
	PLC_NT,
	CUR_CF

/OUTFILE ${SORT_O} overwrite
exit
EOF
SORT


NSTEP=${NJOB}_130

LIBEL="Sort GLT OUT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_${EST_BASE}_ALL.dat  2000 1"
SORT_O="${ESF_FTECLEDA_OUT} 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        ACCRET_CF,
        SEGNAT_CT,
        PLC_NT,
        CUR_CF

/OUTFILE ${SORT_O} overwrite
/OUTFILE ${SORT_O2} overwrite
exit
EOF
SORT

JOBEND
