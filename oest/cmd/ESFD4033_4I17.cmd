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
#[044] 05/04/2024 MZM : SPIRA 111190   20.1 - I17 - Add the LC reclass to the IO auto generation - Update 
#[045] 22/04/2024 MZM : SPIRA 111156   20.1 - I17 - Opening 24 vs Closing 23 - Cancellation done on Reclass transactions while should not 
#[046] 10/05/2024 MZM : SPIRA 111156   20.1 - I17 - FIX SUR SIGNE DES RECLASS
#[047] 22/05/2024 MZM : SPIRA 111190   20.1 - I17 - Add the LC reclass to the IO auto generation - Copy
#[048] 24/06/2024 MZM : SPIRA 111781   20.1 - I17 - LC reclass done on external contracts when it should only be internal contracts
#[049] 23/04/2025 MZM : SPIRA 112900   20.1 - I17 - LC ending AE reclassed in CSM ending on external contracts
#==============================================================================

# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


EST_BASE=`basename ${ESF_FTECLEDA_OUT%.*}`
ICLODAT_M0=$(($ICLODAT_MTH - 2))


NSTEP=${NJOB}_75
#------------------------------------------------------------------------------------
LIBEL="Excluse Life ${ESF_FTECLEDA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        BALSHEY_NF        3:1 -   3:EN,
        BALSHRMTH_NF      4:1 -   4:EN,
        DETTRS_CF        6:1 - 6:,
        LOBACC_CF       45:1 - 45:

/KEYS   DETTRS_CF
/CONDITION VIE ( LOBACC_CF="30" OR LOBACC_CF="31" ) or (BALSHRMTH_NF < ${ICLODAT_M0}) or ( BALSHRMTH_NF > ${ICLODAT_MTH} ) or (BALSHEY_NF != ${ICLODAT_YEA} )
/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
exit
EOF
SORT

## [030] DEB GENERATION MOUVEMENTS IFRS17 LC OU CSM ANNULABLES

NSTEP=${NJOB}_75A
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_${EST_BASE}_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE.dat 2000 1"
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

## [038] 


NSTEP=${NJOB}_75B
# Join AND Extend IFRS17_NOLIFE  with PRS_751 of _FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join IFRS17_NOLIFE.dat with PRS_ 751 and _FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75A_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AVANT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_05_${IB}_FTRSLNK_751_I17.dat 2000 1 "~"        
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

NSTEP=${NJOB}_75C
# Join AND Extend IFRS17_NOLIFE  with PRS_751 of _FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join IFRS17_NOLIFE.dat with PRS_ 751 and _FTRSLNK.dat TRANS NEW RULE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75A_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_TRANS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 119:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_05_${IB}_FTRSLNK_751_I17_TRANS.dat 2000 1 "~"        
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


#[044] DEB GENERATION MOUVEMENTS IFRS17 LC OU CSM ANNULABLES



NSTEP=${NJOB}_75D
# Join AND Extend IFRS17_NOLIFE  with PRS_751 of _FTRSLNK.dat LC AI
#-----------------------------------------------------------------------------
LIBEL="Join IFRS17_NOLIFE.dat with PRS_ 751 and _FTRSLNK.dat LC AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75A_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:,                                             
        COLS_STD_F1       1:1 - 118:,                                                                                                                                                                  
			  PRS_CF_F2         1:1  - 1:,
			  ACMTRS_NT_F2			2:1  - 2:,
			  DETTRS_CF_F2			3:1  - 3:												         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_05_${IB}_FTRSLNK_751_AI_LC.dat 2000 1 "~"       
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


NSTEP=${NJOB}_75E
# SORT  of _FTRSLNK.dat LC AI
#-----------------------------------------------------------------------------
LIBEL="Sort _FTRSLNK.dat LC AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75D_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        TRNCOD_CF         6:1 -  6:, 
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,                                                    
        COLS_STD_F1     1:1 - 120:                                                                                                                                                                											         
/KEYS  
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT							  
exit
EOF
SORT



NSTEP=${NJOB}_75F
# Join AND Extend IFRS17_NOLIFE  with PERICASE TO EXTRACT  AI
#-----------------------------------------------------------------------------
LIBEL="Join AND Extend IFRS17_NOLIFE  with PERICASE TO EXTRACT AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75E_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        all_cols1        1:1 - 120:,
        PER_SSD_CF       1:1 -  1:,
        PER_CTR_NF       3:1 -  3:,
        PER_END_NT       4:1 -  4:,
        PER_SEC_NF       5:1 -  5:,
        PER_UWY_NF       6:1 -  6:,
        PER_UW_NT        7:1 -  7:,
        PER_ESB_CF       8:1 -  8:
/joinkeys
        CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT 
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_07_${IB}_SORT_IADPERICASE.dat 2000 1 "~"  
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY      
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols1
exit
EOF
SORT


### JOINTURE AVEC le FICHIER GAAP_MAP

NSTEP=${NJOB}_75G
# Join AND Extend IFRS17_NOLIFE_RSLNK_O_AI  with GAAP_MAPE TO EXTRACT  AI ONLY
#-----------------------------------------------------------------------------
LIBEL="Join AND Extend IFRS17_NOLIFE_RSLNK_O_AI  with GAAP_MAPE TO EXTRACT  AI ONLY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75F_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF          	 1:1 -  1:,
        ESB_CF          	 2:1 -  2:,
        TRNCOD_CF          6:1 -  6:,         
        CTR_NF          	 8:1 -  8:,
        END_NT          	 9:1 -  9:,
        SEC_NF          	10:1 - 10:,
        UWY_NF          	11:1 - 11:,
        UW_NT           	12:1 - 12:,
        ACMTRS_NT 	      120:1 - 120:,
        all_cols1       	 1:1 - 120:,
        ORIGRP_NT 	       1:1 -  1:,        
        ORIGAPACMTRS_NT 	 2:1 -  2:,
        ORIDETTRS_CF    	 3:1 -  3:,        
        TARGAPACMTRS_NT 	 5:1 -  5:,
        TARDETTRS_CF 	     6:1 -  6:
/joinkeys
        TRNCOD_CF,
        ACMTRS_NT 
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_10_${IB}_GAAPMAP_IFRS17.dat 2000 1 "~" 
/joinkeys
				ORIDETTRS_CF,
        ORIGAPACMTRS_NT     
/OUTFILE   ${SORT_O}
/REFORMAT 
	leftside:all_cols1
	,rightside:ORIGAPACMTRS_NT  
	,rightside:TARGAPACMTRS_NT
	,rightside:ORIGRP_NT
	,rightside:TARDETTRS_CF	
exit
EOF
SORT

### FILTER ONLY WITH TARGET GAAPCOD ... 


#[047] AJOUT Condition specifique sur : ( ORIGAPACMTRS_NT= "3420"  AND TARGAPACMTRS_NT="1155" AND TARDETTRS_CF = "1149409I") 
#[048] AJOUT Condition specifique sur : ( ORIGAPACMTRS_NT= "3420"  AND TARGAPACMTRS_NT="1155" AND TARDETTRS_CF = "1449409I" AND  TRN_NT = "" )
#[049] /CONDITION GRP_RSLNK_O_AI (TRNCOD01_CF = "1" )  AND ( TRN_NT = "") AND ( ( ORIGRP_NT= "300" AND ORIGAPACMTRS_NT= "4206"  AND TARGAPACMTRS_NT="4205" AND TRNCOD_CF= "1149550I" ) OR ( ORIGAPACMTRS_NT= "3420"  AND TARGAPACMTRS_NT="1155" AND TARDETTRS_CF = "1149409I") OR ( ORIGAPACMTRS_NT= "3420"  AND TARGAPACMTRS_NT="1155" AND TARDETTRS_CF = "1449409I" ) OR ( ORIGAPACMTRS_NT= "3420"  AND TARGAPACMTRS_NT="3320" ) OR ( ORIGAPACMTRS_NT = "3420"  AND TARGAPACMTRS_NT="3540" ) OR ( ORIGAPACMTRS_NT="3425"  AND TARGAPACMTRS_NT="3540" ) OR ( ORIGAPACMTRS_NT="3430"  AND TARGAPACMTRS_NT="3330" )  OR ( ORIGAPACMTRS_NT="3430"  AND TARGAPACMTRS_NT="3540" )  OR ( ORIGAPACMTRS_NT="6440"  AND TARGAPACMTRS_NT="3540" ) ) 


NSTEP=${NJOB}_75H
# FILTER AND MATCH ORI WITH TARGET IFRS17_NOLIFE_RSLNK_O_AI 
#-----------------------------------------------------------------------------
LIBEL="FILTER AND MATCH ORI WITH TARGET IFRS17_NOLIFE_RSLNK_O_AI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75G_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1" 
SORT_O2="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI_AVEC.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:,
        BALSHRDAY_NF      5:1 -  5:,
        TRNCOD_CF         6:1 -  6:, 
        TRNCOD01_CF       6:1 -  6:1,              
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
        TRN_NT           103:1 - 103:,
        ORIGAPACMTRS_NT  121:1 - 121:,  
        TARGAPACMTRS_NT  122:1 - 122:, 
        ORIGRP_NT        123:1 - 123:,
        TARDETTRS_CF     124:1 - 124:,                                              
        ALL_COLS_F1      1:1 - 124:    
                                 
/CONDITION GRP_RSLNK_O_AI (TRNCOD01_CF = "1" )  AND ( ( ORIGRP_NT= "300" AND ORIGAPACMTRS_NT= "4206"  AND TARGAPACMTRS_NT="4205" AND TRNCOD_CF= "1149550I" ) OR ( ORIGAPACMTRS_NT= "3420"  AND TARGAPACMTRS_NT="1155" AND TARDETTRS_CF = "1149409I") OR ( ORIGAPACMTRS_NT= "3420"  AND TARGAPACMTRS_NT="1155" AND TARDETTRS_CF = "1449409I" ) OR ( ORIGAPACMTRS_NT= "3420"  AND TARGAPACMTRS_NT="3320" ) OR ( ORIGAPACMTRS_NT = "3420"  AND TARGAPACMTRS_NT="3540" ) OR ( ORIGAPACMTRS_NT="3425"  AND TARGAPACMTRS_NT="3540" ) OR ( ORIGAPACMTRS_NT="3430"  AND TARGAPACMTRS_NT="3330" )  OR ( ORIGAPACMTRS_NT="3430"  AND TARGAPACMTRS_NT="3540" )  OR ( ORIGAPACMTRS_NT="6440"  AND TARGAPACMTRS_NT="3540" ) ) 
/OUTFILE ${SORT_O}
/OMIT GRP_RSLNK_O_AI
/OUTFILE ${SORT_O2}  
/INCLUDE GRP_RSLNK_O_AI
exit
EOF
SORT


NSTEP=${NJOB}_75I
# SORT UNIQUE IFRS17_NOLIFE_RSLNK_O_AI 
#-----------------------------------------------------------------------------
LIBEL="SORT UNIQUE IFRS17_NOLIFE_RSLNK_O_AI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75H_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat 2000 1"
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
        ORIGAPACMTRS_NT  121:1 - 121:,  
        TARGAPACMTRS_NT  122:1 - 122:, 
        ORIGRP_NT        123:1 - 123:, 
				TARDETTRS_CF     124:1 - 124:, 	        
        ALL_COLS_F0      1:1 - 121:,                                       
        ALL_COLS_F1      1:1 - 124:   
                                 
/KEYS ALL_COLS_F0
/SUM
/STABLE
exit
EOF
SORT

##[044]  Generation des MOUVEMENTS LC AI IFRS17 ###




NSTEP=${NJOB}_76B
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75B_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AVANT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_AVANT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:,
        BALSHRHRMTH_NF      4:1 -  4:,
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

NSTEP=${NJOB}_76C
# TRI DU FICHIER SUR CLE CSUE / RETRO CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI SUR CLE CSUE / Retro CSUE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75C_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_TRANS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_TRANS.dat 2000 1"
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

# Ajout NATRET_CF pour identifier RETRO et RETRO NP 
# NATRET_CF != ("30", "31", "32", "40", "41" ) ==> On traite

# [017] Inversion des colonnes CSM_F2 and LC_F2

## Eligible  a la TRANSFORMATION SI GROUPING != ("4200" ; "4220") et CSM LC != 1 OU GROUPING "4200" ; "4220" et REGLE ACTUELLE CSM / LC


## [038] correction REGLE AVANT  "/JOIN UNPAIRED LEFTSIDE  " a ete desactive au step _76D

NSTEP=${NJOB}_76D
# Join AND Extend ${ESF_FTECLEDA_OUT}_IFRS17_NOLIFE with CSM LC PROFITABLE
#-----------------------------------------------------------------------------
LIBEL="Join ${ESF_FTECLEDA_OUT}_IFRS17_NOLIFE.dat WITH ESFD3750_ESFD3770_PROFIT_CSM_LC NEW RULE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_76B_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_AVANT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_TRANS_V0.dat 2000 1"
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



NSTEP=${NJOB}_76E
# Join AND Extend ${ESF_FTECLEDA_OUT}_IFRS17_NOLIFE with CSM LC PROFITABLE
#-----------------------------------------------------------------------------
LIBEL="Join ${ESF_FTECLEDA_OUT}_IFRS17_NOLIFE.dat WITH ESFD3750_ESFD3770_PROFIT_CSM_LC NEW RULE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_76C_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_TRANS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_TRANS_V2.dat 2000 1"
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
/JOIN UNPAIRED LEFTSIDE ONLY                                            
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT


### CAS DES RETRO NP

NSTEP=${NJOB}_77D
# Join AND Extend ${ESF_FTECLEDA_OUT}_IFRS17_NOLIFE with RETRO NP CSM
#-----------------------------------------------------------------------------
LIBEL="Join ${ESF_FTECLEDA_OUT}_IFRS17_NOLIFE.dat WITH ESFD3750_ESFD3770_ with RETRO NP CSM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_76B_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_AVANT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_AVANT.dat 2000 1"
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


NSTEP=${NJOB}_77G
# Join AND Extend ${ESF_FTECLEDA_OUT}_IFRS17_NOLIFE with RETRO NP CSM
#-------------------------------------------------------------------------------
LIBEL="Join ${ESF_FTECLEDA_OUT}_IFRS17_NOLIFE.dat WITH ESFD3750_ESFD3770_ with RETRO NP CSM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_76C_${IB}_${EST_BASE}_SORT_IFRS17_NOLIFE_RSLNK_O_TRANS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_TRANS.dat 2000 1"
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
/JOIN UNPAIRED LEFTSIDE ONLY                              
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:ALL_COLS_F1, rightside:CSM_F2, rightside:LC_F2, rightside:PROF_CALC_NF 	 													  
exit
EOF
SORT

#[042] Correction filtre que sur RNP

NSTEP=${NJOB}_77H
LIBEL="GENERATE FIELD ONLY WITH RETRO NP FROM IRDPERICASE0  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_77G_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_TRANS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_TRANS.dat 2000 1"
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
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:FILLER,
	RIGHTSIDE:NATRET_CF
exit
EOF
SORT


##### MERGE RETRO NP OLD AND NEW :

NSTEP=${NJOB}_77I
# MERGE RETRO NP OLD AND NEW RULE CSM LC "4200" "4220" 
#-----------------------------------------------------------------------------
LIBEL="MERGE RETRO NP OLD AND NEW RULE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_77D_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_AVANT.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_77H_${IB}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_TRANS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP.dat 2000 1"
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
                                 
/CONDITION GRP_RETNP (TRNCOD1_CF='2' OR TRNCOD1_CF='4')
/OUTFILE ${SORT_O}
/INCLUDE GRP_RETNP
exit
EOF
SORT


######


NSTEP=${NJOB}_77A
# FILTER ACCEPT AND RETRO PROP ONLY
#-----------------------------------------------------------------------------
LIBEL="FILTER ON ACCEPT AND RETRO "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_76D_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_TRANS_V0.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_76E_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_TRANS_V2.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_ASS.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_RETRO.dat 2000 1"
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



NSTEP=${NJOB}_77B
LIBEL="GENERATE FIELD WITHOUT RETRO NP FROM IRDPERICASE0  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_77A_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_RETRO.dat 2000 1"
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


NSTEP=${NJOB}_77E
LIBEL="MERGE ASS With RETRO PROP  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_77A_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_ASS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_77B_${IB}_PROF_CSM_LC_IFRS17_NOLIFE_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE.dat 2000 1"
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

NSTEP=${NJOB}_77F
# SORT UNIQUE of  file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of IFRS17_NOLIFE_PROF_CSM_LC.dat BEFORE JOIN  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_77E_${IB}_PROF_CSM_LC_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_IFRS17_NOLIFE.dat 2000 1"
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


##[040]



## [036] SORT_I="${DFILT}/${NJOB}_79A_${IB}_${EST_BASE}_IFRS17_NOLIFE_PROF_CSM_LC.dat 2000 1"

NSTEP=${NJOB}_79O
# SORT UNIQUE of  file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of IFRS17_NOLIFE_PROF_CSM_LC.dat  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_77F_${IB}_PROF_CSM_LC_IFRS17_NOLIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_PROF_CSM_LC.dat 2000 1"
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

NSTEP=${NJOB}_79B
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements CSM LC PROFITABLES"
AWK_I=${DFILT}/${NJOB}_79O_${IB}_${EST_BASE}_IFRS17_NOLIFE_PROF_CSM_LC.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_PROF_CSM_LC_AWK.dat
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


NSTEP=${NJOB}_79C
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements CSM RNP "
AWK_I=${DFILT}/${NJOB}_77I_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_AWK.dat
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

##[041] AWK_I=${DFILT}/${NJOB}_75H_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat

NSTEP=${NJOB}_79D
#-----------------------------------------------------------------------------
LIBEL="Annulation des Mouvements IFRS17 AI IO Auto"
AWK_I=${DFILT}/${NJOB}_75I_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI_AWK.dat
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

##[043] Revert LC Assume ##[044] LC Assume 


NSTEP=${NJOB}_79E
# Remove Grouping 751 1010 1020 AND CSM LC Prof from ${EST_BASE}_IFRS17_NOLIFE
#-----------------------------------------------------------------------------
LIBEL=" UPDATE ${EST_BASE}_IFRS17_NOLIFE WITH cancellables mouvements "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_${EST_BASE}_IFRS17_NOLIFE.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_79B_${IB}_${EST_BASE}_IFRS17_NOLIFE_PROF_CSM_LC_AWK.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_79C_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_PROF_CSM_RNP_AWK.dat 2000 1"
##SORT_I4="${DFILT}/${NJOB}_79D_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI_AWK.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_NO_PROF_CSM_LC.dat 2000 1"
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


#[045] Ne plus vider les colonnes GAAPCOD_NT, I17PRDCOD_CT ; Vider GT_ANNUL_OPNG que si differe de "A", "O"

NSTEP=${NJOB}_80
#----------------------------------------------------------------------------------
LIBEL="Apply transformation to ${ESF_FTECLEDA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_79E_${IB}_${EST_BASE}_IFRS17_NOLIFE_NO_PROF_CSM_LC.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        S_DETTRS_CF       6:1 - 6:,
        S_HEAD            1:1 - 2:,
	ORIACMTRS_NT       2:1 - 2:,
  ORIDETTRS_CF       3:1 - 3:,
	TARGACMTRS_NT      5:1 - 5:,            
   TARGDETTRS_CF     6:1 - 6:,
   MAPTYP_CT         7:1 - 7: EN,
	S_MID1            8:1 - 40:,
	S_MID2            45:1 - 88:,
	TRN_NT		        103:1 - 103:,	
	ORICOD_LS		      104:1 - 104:,	
	S_TAIL1           105:1 - 110:,
	GAAPCOD_NT        111:1 - 111:,	
	I17PRDCOD_CT      112:1 - 112:,	
  S_TAIL2     			113:1 - 118:,	
	GT_ANNUL_OPNG     114:1 - 114:	

/CONDITION VIDER_GAAPCOD_NT_I17PRDCOD_CT  (GT_ANNUL_OPNG != "A" and GT_ANNUL_OPNG != "O")         
/DERIVEDFIELD GAAPCOD_NT_NEW if VIDER_GAAPCOD_NT_I17PRDCOD_CT then "" else GAAPCOD_NT 
/DERIVEDFIELD I17PRDCOD_CT_NEW if VIDER_GAAPCOD_NT_I17PRDCOD_CT then "" else I17PRDCOD_CT 
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
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_10_${IB}_GAAPMAP_IFRS17.dat 2000 1 "~"
/JOINKEYS
        ORIDETTRS_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside : S_HEAD,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW, rightside : TARGDETTRS_CF, SEPARATEUR,leftside : S_MID1, CRE_NEW , leftside : S_MID2, COLS14_NEW,leftside : TRN_NT_NEW, ORICOD_NEW,   leftside : S_TAIL1, GAAPCOD_NT_NEW, I17PRDCOD_CT_NEW, S_TAIL2, rightside : MAPTYP_CT, rightside : ORIACMTRS_NT,  rightside : ORIDETTRS_CF,  rightside : TARGACMTRS_NT,  rightside : TARGDETTRS_CF
exit
EOF
SORT

## FILTER LC AI ON CONDITION /CONDITION GRP_RSLNK_O_AI ( ORIGRP_NT= "300" AND ORIGAPACMTRS_NT= "4206"  AND TARGAPACMTRS_NT="4205" AND TRNCOD_CF= "1149550I" ) OR ( ORIGAPACMTRS_NT= "3420"  AND TARGAPACMTRS_NT="1155" ) OR ( ORIGAPACMTRS_NT= "3420"  AND TARGAPACMTRS_NT="3320" ) OR ( ORIGAPACMTRS_NT= "3420"  AND TARGAPACMTRS_NT="3540" ) OR ( ORIGAPACMTRS_NT="3425"  AND TARGAPACMTRS_NT="3540" ) OR ( ORIGAPACMTRS_NT="3430"  AND TARGAPACMTRS_NT="3330" )  OR ( ORIGAPACMTRS_NT="3430"  AND TARGAPACMTRS_NT="3540" )  OR ( ORIGAPACMTRS_NT="6440"  AND TARGAPACMTRS_NT="3540" )  

NSTEP=${NJOB}_80A
#----------------------------------------------------------------------------------
LIBEL="SORT TRANSFORMATION BEFORE JOIN"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_${EST_BASE}_IFRS17.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        TRNCOD_CF         6:1 -  6:,
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
        ORIACMTRS_NT    120:1 - 120:,
        ORIDETTRS_CF    121:1 - 121:,
        TARGACMTRS_NT   122:1 - 122:,
        TARGDETTRS_CF   123:1 - 123:,                                           
        ALL_COLS_F1      1:1 - 124:             
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
				,ORIDETTRS_CF
				,TARGDETTRS_CF    
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT


NSTEP=${NJOB}_80B
#----------------------------------------------------------------------------------
LIBEL="SORT TRANSFORMATION BEFORE JOIN"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75H_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI_AVEC.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI_AVEC.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        TRNCOD_CF_2          6:1 -  6:,
      	CTR_NF_F2            8:1 -  8:,
        END_NF_F2            9:1 -  9:,
        SEC_NF_F2           10:1 - 10:,
        UWY_NF_F2           11:1 - 11:,
        UW_NT_F2            12:1 - 12:,
        RETCTR_NF_F2        24:1 - 24:,
        RETEND_NT_F2        25:1 - 25:,
        RETSEC_NF_F2        26:1 - 26:,
        RTY_NF_F2           27:1 - 27:,
        RETUW_NT_F2         28:1 - 28:,  
        ORIACMTRS_NT    118:1 - 118:,

        TARGACMTRS_NT_F2   122:1 - 122:,
        TARGDETTRS_CF_F2   124:1 - 124:            
/KEYS       
				CTR_NF_F2    
				,END_NF_F2    
				,SEC_NF_F2    
				,UWY_NF_F2    
				,UW_NT_F2     
				,RETCTR_NF_F2 
				,RETEND_NT_F2 
				,RETSEC_NF_F2 
				,RTY_NF_F2    
				,RETUW_NT_F2 
				,TRNCOD_CF_2 
				,TARGDETTRS_CF_F2
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

NSTEP=${NJOB}_81
#----------------------------------------------------------------------------------
LIBEL="Apply transformation to ${ESF_FTECLEDA} Filter LC AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80A_${IB}_${EST_BASE}_IFRS17.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        TRNCOD_CF         6:1 -  6:,
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
        ORIACMTRS_NT    120:1 - 120:,
        ORIDETTRS_CF    121:1 - 121:,
        TARGACMTRS_NT   122:1 - 122:,
        TARGDETTRS_CF   123:1 - 123:,                                           
        ALL_COLS_F1      1:1 - 124:,
        
        TRNCOD_CF_2          6:1 -  6:,
      	CTR_NF_F2            8:1 -  8:,
        END_NF_F2            9:1 -  9:,
        SEC_NF_F2           10:1 - 10:,
        UWY_NF_F2           11:1 - 11:,
        UW_NT_F2            12:1 - 12:,
        RETCTR_NF_F2        24:1 - 24:,
        RETEND_NT_F2        25:1 - 25:,
        RETSEC_NF_F2        26:1 - 26:,
        RTY_NF_F2           27:1 - 27:,
        RETUW_NT_F2         28:1 - 28:,  
        ORIACMTRS_NT    118:1 - 118:,

        TARGACMTRS_NT_F2   122:1 - 122:,
        TARGDETTRS_CF_F2   124:1 - 124:        
/JOINKEYS       
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
				,ORIDETTRS_CF
				,TARGDETTRS_CF    

/INFILE ${DFILT}/${NJOB}_80B_${IB}_${EST_BASE}_IFRS17_NOLIFE_RSLNK_O_AI_AVEC.dat 2000 1 "~" 
/JOINKEYS 
				CTR_NF_F2    
				,END_NF_F2    
				,SEC_NF_F2    
				,UWY_NF_F2    
				,UW_NT_F2     
				,RETCTR_NF_F2 
				,RETEND_NT_F2 
				,RETSEC_NF_F2 
				,RTY_NF_F2    
				,RETUW_NT_F2 
				,TRNCOD_CF_2 
				,TARGDETTRS_CF_F2

/JOIN UNPAIRED LEFTSIDE ONLY	
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT
	LEFTSIDE:ALL_COLS_F1
exit
EOF
SORT

#[046] Fix sur le signe incorrect de vertains RECLASS (colonne 121)

NSTEP=${NJOB}_82
#-----------------------------------------------------------------------------
LIBEL="Transforme using Sign"
AWK_I=${DFILT}/${NJOB}_81_${IB}_${EST_BASE}_IFRS17.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_AWK.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
	if (( \$119 == "-1" )  && \$19 != 0)   \$19 =sprintf("%-.3lf",-\$19); 
	if (( \$119 == "-1" )  && \$35 != 0)   \$35 = sprintf("%-.3lf",-\$35); 
	print \$0;
  }
exit
EOF
AWK


NSTEP=${NJOB}_85
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing GTAR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_82_${IB}_${EST_BASE}_IFRS17_AWK.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17_AWK.dat 2000 1"
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



NSTEP=${NJOB}_87
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
export ${PRG}_I2="${DFILT}/${NJOB}_85_${IB}_${EST_BASE}_IFRS17_AWK.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_${PRG}_IFRS17.dat"
EXECPRG


NSTEP=${NJOB}_90
#------------------------------------------------------------------------------------
LIBEL="Summarize on Key "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_87_${IB}_${EST_BASE}_ESTC1052B_IFRS17.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${EST_BASE}_IFRS17.dat 2000 1"
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


NSTEP=${NJOB}_100
#------------------------------------------------------------------------------------
LIBEL="merg files to ouput ${ESF_FTECLEDA_OUT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_${EST_BASE}_IFRS17.dat 2000 1"
SORT_O="${ESF_FTECLEDA_100_IFRS17} 2000 1"
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


## [025]

JOBEND
