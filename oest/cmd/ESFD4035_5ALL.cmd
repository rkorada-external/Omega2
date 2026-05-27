#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Transformation REQ 20.1
# nom du script SHELL           : ESFD4035.cmd
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
#[007] 06/09/2021 NLD : SPIRA 97350 :  REQ20.1 - Transaction generated several times, update CRE_D and LSTUPD_D 
#[008] 26/01/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  : (for grouping 751=1010 ; 2010) AND ((Prof = 3 and CSM =1) OR  (Prof = 1 and LC =1))
#[009] 31/01/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  Ajout des colonnes  SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF dans la cle de jointure
#[010] 11/02/2022  HR : SPIRA 100977 : I17 - Criteria to compute Revenue / EXP / CSM
#[011] 21/02/2022 MZM : SPIRA 102371:  I17 Filtrer les fichiers I17 Par Normes (Ajout jointures avec les fichiers Pericases) : Annulation  ; Modif effectuee dans ESFD4037
#[012] 12/05/2022 MZM : SPIRA 85522:   MERGE AVEC PERICASE Au STEP _115 (Ajout Cartouche)
#[013] 13/05/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  Ajout SCORTH  dans la cle de jointure au step _19A
#[014] 31/05/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  For Retro NP : Inversion des colonnes LC et CSM
#[015] 09/06/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  For Retro NP : Condition sur RETRO NP (Exclure sur les enreg Accept et Retro Prop) ; Exclure Regle Profitabilite
#[016] 21/06/2022 MZM : SPIRA 97768 :  REQ20.1 - no calculation  For Retro NP :Fix sur Anomalie Dans LOG au step _19D
#[017] 28/06/2022 MZM : SPIRA 105131:  REQ20.1 - no calculation  Fix sur les doublons apres Step _19A : Ajout Step _19O
#[018] 10/11/2022 MZM : SPIRA 107125:  REQ20.1 - RA / RR View - REQ 20.1 GENERER FTECLEDR A PARTIR DU FTECLEDA
#[019] 10/11/2022 MZM : SPIRA 107687:  REQ20.1 - TECHNICAL CHANGE : 2010,2013,2019,1016,1017
#[020] 06/12/2022 MZM : SPIRA 107133:  REQ20.1 -Spira 107133 TRN_NT  EMPTY AND TRANSFORMATION Stored In column 57 ==> RECLASSP
#[021] 30/01/2023 MZM : SPIRA 108631:  REQ 20.1 - Change Input file to avoid double offset - Copy : Prise en compte des Annulations PRS_740
#[022] 03/04/2023 MZM : SPIRA 109394   Criteria to compute I4 to I17 transformation not properly applied
#[023] 07/04/2023 MZM : SPIRA 108576   20.1 - FD new update ; Generation des LC / CSM Annulables pour I17
#[024] 11/04/2023 MZM : SPIRA 108942   20.1 - Delta Posting - strange delta
#[025] 14/04/2023 MZM : SPIRA 108576   20.1 - FD new update ; Generation des LC / CSM Annulables pour I17 : Grouping "1016" et "1017" Pour Tout
#[026] 22/05/2023 MZM : SPIRA 109559   20.1 - I17 - IFRS4 cancel calculated on retro NP with Q-1 CSM pattern at 1 : Modif du Step _19O pour filtre que Ass et Retro Prop
#[027] 04/07/2023 MZM : SPIRA 110070   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping POUR EBS : "1041" OR "1051" OR "2041" OR "2044" OR "2051" OR "2054" et des conditions  [abs(CSM ending) + abs(LC ending)] 
#[028] 18/07/2023 MZM : SPIRA 110198   20.1 - I17 - REQ 20.1 - Update on Reclass conditions  [abs(CSM ending) + abs(LC ending)] 
#[029] 02/08/2023 MZM : SPIRA 110198   20.1 - I17 - REQ 20.1 - Update on Reclass conditions  Fix sur Doublons CSM / LC AMORT
#[030] 02/08/2023 MZM : SPIRA 110198   20.1 - I17 - REQ 20.1 - Update on Reclass conditions  Fix sur Doublons CSM / LC AMORT (Fix ITK _19A)
#[031] 11/10/2023 MZM : SPIRA 110675   20.1 - I17 - REQ 20.1 - remove content of NEWCOLS5_NF on reclass transactions
#[032] 09/07/2023 MZM : SPIRA 109797   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping  : "4200" OR "4220" 
#[033] 16/01/2023 MZM : SPIRA 110217   20.1 - I17 -REQ 20.1 - 17 - Add the LC reclass to the IO auto generation : Prise en compte des Grouping  que pour les AI
#[034] 29/01/2024 MZM : SPIRA 109797   20.1 - I17 - REQ 20.1 - Update on Reclass : Ajout des Grouping  : "4200" OR "4220"
#[035] 29/01/2023 MZM : SPIRA 111191   20.1 - I17 - Add the LC reclass to the IO auto generation - Revert 
#[036] 22/04/2024 MZM : SPIRA 111156   20.1 - I17 - Opening 24 vs Closing 23 - Cancellation done on Reclass transactions while should not
#[037] 16/05/2024 MZM : SPIRA 111009   20.1 - I17 - FIX ITK NUMERO Spira CORRECT
#[038] 22/05/2024 MZM : SPIRA 111206   20.1 - I17 - Remaining gaps on REQ 20.1 
#[039] 28/10/2024 MZM : SPIRA 112301 : Ecart RR / RA : Regenerer RR A partir de la vue RA au Step _103
#===============================================================================


# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

EST_BASE=`basename ${ESF_FTECLEDR_OUT%.*}`
ICLODAT_M0=$(($ICLODAT_MTH - 2))



## [023]
#SORT_I="${DFILT}/${NJOB}_40_${IB}_${EST_BASE}_IFRS4.dat  2000 1"
#[039] ##SORT_I3="${DFILT}/${NCHAIN}_ESFD4035_4I17_${NORME_CF}_100_${IB}_${EST_BASE}_IFRS17.dat  2000 1"

#--------------------------------------------
NSTEP=${NJOB}_103
# summarize TTECLEDR by BALSHTDAY
#--------------------------------
LIBEL="Summarize TTECLEDR by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESFD4035_2I4_${NORME_CF}_40A_${IB}_${EST_BASE}_IFRS4.dat  2000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESFD4035_3EBS_${NORME_CF}_70A_${IB}_${EST_BASE}_EBS.dat  2000 1"
SORT_I3="${DFILT}/${NCHAIN}_ESFD4035_4I17_${NORME_CF}_100A_${IB}_${EST_BASE}_IFRS17.dat  2000 1"
##SORT_I2="${DFILT}/${NJOB}_70_${IB}_${EST_BASE}_EBS.dat  2000 1"
##SORT_I3="${DFILT}/${NCHAIN}_ESFD4035_4I17_${NORME_CF}_100_${IB}_${EST_BASE}_IFRS17.dat  2000 1"
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
  ALL               1:1 - 71:
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
/OUTFILE ${SORT_O}
/REFORMAT ALL
exit
EOF
SORT

## Recuperer les Annulations (et Ouvertures) et filtre sur 740 ==> Les Inclure

NSTEP=${NJOB}_104
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Generate 2 Files With REJ_OPNG and Without..."
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
							FIELD_1_64					  1:1 -  64:,				       
              GT_ANNUL_OPNG   		 65:1 -  65:,
              NEWCOLS5_NF          67:1 -  67:, 
							FIELD_66_71					 66:1 -  71:,
							FIELD_1_71  			    1:1 -  71:                        
                           
/KEYS  	 RETCTR_NF       	
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
/CONDITION ANNU_OPNG  (NEWCOLS5_NF = "A" or NEWCOLS5_NF = "O")
/OUTFILE ${SORT_O} overwrite
/OMIT ANNU_OPNG
/OUTFILE ${SORT_O2} overwrite
/INCLUDE ANNU_OPNG
exit
EOF
SORT


#[045] MOVE /JOIN UNPAIRED LEFTSIDE ONLY 

NSTEP=${NJOB}_105
# Join AND Extend ${DFILT}/${NJOB}_104_${IB}_${EST_BASE}_ALL.dat  with PRS_740 of _FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join ${DFILT}/${NJOB}_104_${IB}_${EST_BASE}_ALL_AVEC_REJ_OPNG.dat with PRS_740_FTRSLNK.dat"
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
              GT_ANNUL_OPNG   		 65:1 -  65:,                                              
        			COLS_STD_F1       		1:1 - 71:,                                                                                                                                                                  
			  			PRS_CF_F2         		1:1  - 1:,
			  			ACMTRS_NT_F2					2:1  - 2:,
			  			DETTRS_CF_F2					3:1  - 3:												         
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



## Inclusion des Annulations du PRS 740 

## [031] Vider le champs _67 POur Les RECLASS Que pour le Fichier DELTA et pour Toute Norme Sauf I17
## [036]  Vider colonne _67 Sauf pour les Annulations du PRS _740

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
	TRN_NT           56:1 -  56:,
	ORICOD_LS        57:1 - 57:,	
  ALL               1:1 - 71:,
	GT_ANNUL_OPNG   67:1 - 67:,
	FILLER_1_66     1:1 - 66:,
	FILLER_68_71    68:1 - 71:  
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
/CONDITION VIDER_NEWCOLS5  (ORICOD_LS = "RECLASSP" or ORICOD_LS = "RECLASSL")     
/DERIVEDFIELD GT_ANNUL_OPNG_NEW if VIDER_NEWCOLS5 then "" else GT_ANNUL_OPNG 
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M
/OUTFILE ${SORT_O} 
/INCLUDE RESTRICTION
/REFORMAT ALL
/OUTFILE ${SORT_O2} 
/INCLUDE RESTRICTION
/REFORMAT FILLER_1_66, GT_ANNUL_OPNG_NEW, FILLER_68_71
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
	ORICOD_LS        57:1 - 57:,	
  ALL               1:1 - 71:,
	GT_ANNUL_OPNG   67:1 - 67:,
	FILLER_1_66     1:1 - 66:,
	FILLER_68_71    68:1 - 71:  
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
	FILLER_68_71    68:1 - 71:  
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
	FILLER_68_71    68:1 - 71:  
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

# [036] Fin Modif 

### DEB Merge Fusion PERICASE STD


## Ajout du Merge DU PERICASE ASS et Retro avec le fichier  "${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL.dat  2000 1" Avec PERICASE STANDART ACC / RET




#[012] DEB JOINTURE DES FICHIERS AVEC LES PERICASES

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
        RETAMT_M         35:1 - 35:EN 15/3

/CONDITION GRP_ASS ( TRNCOD1_CF='1' ) OR ( TRNCOD1_CF='3' )
/CONDITION GRP_RET ( TRNCOD1_CF='2' ) OR ( TRNCOD1_CF='4' )

/OUTFILE ${SORT_O}
/INCLUDE GRP_ASS

/OUTFILE ${SORT_O2}
/INCLUDE GRP_RET
exit
EOF
SORT




# [012]#${DFILT}/${NJOB}_23_${IB}_SORT_IADPERICASE_I17_MERGE_O.dat
#${ESF_IRDVPERICASE}

#[012] JOINTURE DES FICHIERS AVEC LES PERICASES

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
        LOBRET_CF   45:1 - 45:
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

#[012] FIN JOINTURE DES FICHIERS AVEC LES PERICASES

fi


NSTEP=${NJOB}_120

LIBEL="Sort GTSII INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR} 2000 1"
if [ "${IDF_CT}" != "EBS_GAP_MAP_STD" ] 
then
SORT_I2="${DFILT}/${NJOB}_119_${IB}_${EST_BASE}_ALL.dat  2000 1" 
else
SORT_I2="${DFILT}/${NJOB}_110_${IB}_${EST_BASE}_ALL_DELTA.dat  2000 1"
fi
#SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_ALL.dat 2000 1"
SORT_O="${ESF_FTECLEDR_OUT} 2000 1"
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
        SEGNAT_CT				48:1 - 48:,
	ACCRET_CF 						49:1 - 49:
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

#NSTEP=${NJOB}_130
#
#LIBEL="Sort GLT OUT"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_120_${IB}_${EST_BASE}_ALL.dat  2000 1"
#SORT_O="${ESF_FTECLEDR_OUT} 2000 1"
#INPUT_TEXT ${SORT_CMD} << EOF
#/FIELDS CTR_NF            8:1 -  8:,
#        END_NT            9:1 -  9:EN,
#        SEC_NF           10:1 - 10:EN,
#        UWY_NF           11:1 - 11:,
#        UW_NT            12:1 - 12:EN,
#        CUR_CF           18:1 -  18:,
#        RETCTR_NF       24:1 - 24:,
#        RETEND_NT       25:1 - 25:,
#        RETSEC_NF       26:1 - 26:,
#        RTY_NF          27:1 - 27:,
#        RETUW_NT        28:1 - 28:,
#        PLC_NT          36:1 - 36:EN,
#        SEGNAT_CT       48:1 - 48:,
#        ACCRET_CF       49:1 - 49:
#/KEYS   CTR_NF,
#        END_NT,
#        SEC_NF,
#        UWY_NF,
#        UW_NT,
#        RETCTR_NF,
#        RETEND_NT,
#        RETSEC_NF,
#        RTY_NF,
#        RETUW_NT,
#        ACCRET_CF,
#        SEGNAT_CT,
#        PLC_NT,
#        CUR_CF
#
#/OUTFILE ${SORT_O} overwrite
#exit
#EOF
#SORT


## GENERER TTECLEDR A PARTIR du TTECLEDA (filtre sur les postes RETRO Uniquement)

##ESF_FTECLEDA=




JOBEND
