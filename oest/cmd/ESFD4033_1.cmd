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
#[044] 21/02/2024 MZM : SPIRA 111190   20.1 - I17 - Add the LC reclass to the IO auto generation - Update 
#[045] 28/08/2024 MZM : SPIRA 111738   20.1 - I17 - REQ 20.1 - I17 - REQ 20.1 - Gaps on reclass : Sur I17 Ajout des Groupings  "1051" OR ACMTRS_NT = "2041" OR ACMTRS_NT = "2044" OR ACMTRS_NT = "2051" OR ACMTRS_NT = "2054"
#[046] 02/01/2025 MZM : SPIRA 112738   20.1 - I17 - Add conversion in EGPI currency of PA reclass
#[047] 16/06/2025 MZM : SPIRA 112987   20.1 - I17 - Add conversion in EGPI currency of Initial fixed Position
#==============================================================================

# set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


##ESF_FCURQUOT_TXT=/scor/home/u006596/martin/perm/P_ESCJ0660_FCURQUOT_TXT.dat
##ESF_FBOPRSLNK_TXT=/scor/home/u006596/martin/perm/P_ESCJ0660_FBOPRSLNK_TXT.dat 


CLODAT_D=${PARM_ICLODAT_D}                                                                                          
ICLODAT_A=`echo ${CLODAT_D} | awk '{print substr($0,1,4)}'`

EST_BASE=`basename ${ESF_FTECLEDA_OUT%.*}`

## [024] [029] Ajout Filtre que sur 1016 et 1017 pour I17
## [034] Ajout des Groupings "1041" OR "1051" OR "2041" OR "2044" OR "2051" OR "2054" OR ACMTRS_NT = "1044" OR ACMTRS_NT = "1054" 
## [038] Ajout des Groupings "4220" OR "4200"  et Modification de la Regle pour I17
## [041] Ajout des Groupings "3420" OR ACMTRS_NT = "3425"  OR ACMTRS_NT = "3430" OR ACMTRS_NT = "4206"  OR ACMTRS_NT = "6440" Pour Implementer RECLASS AI que sur ces Grouping
## [045] Ajout des Groupings  "1051" OR ACMTRS_NT = "2041" OR ACMTRS_NT = "2044" OR ACMTRS_NT = "2051" OR ACMTRS_NT = "2054"  Pour Implementer RECLASS AI que sur ces Grouping
## [046]  Identification Des Grouping impactes IS_PRS_751_PA_RECLASS ( PRS_CF = "751" AND  ( ACMTRS_NT = "1210" OR ACMTRS_NT = "1211"  OR ACMTRS_NT = "1212"  ) )
## [047]  Identification Des Grouping impactes IS_PRS_751_PA_RECLASS ( PRS_CF = "751" AND  ( ACMTRS_NT = "1210" OR ACMTRS_NT = "1211"  OR ACMTRS_NT = "1212"  OR  ACMTRS_NT = "1151" OR ACMTRS_NT = "1154"  OR ACMTRS_NT = "2151"  OR ACMTRS_NT = "2154" ) )

NSTEP=${NJOB}_05
# Filter ESF_FTRSLNK_TXT on PRS_CF = "751"
#-----------------------------------------------------------------------------
LIBEL="Filter ESF_FTRSLNK_TXT on PRS_CF = "751" AND ACMTRS_NT IN ("1010", "2010", "2013", "2019", "1016", "1017")"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751.dat 500 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751_I17.dat 500 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751_EBS.dat 500 1"
SORT_O4="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751_I17_TRANS.dat 500 1"
SORT_O5="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751_AI_LC.dat 500 1"
SORT_O6="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751_PA_RECLASS.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  PRS_CF       1:1 -  1:,
         ACMTRS_NT    2:1 -  2:,
         DETTRS_CF    3:1 -  3:
/CONDITION IS_PRS_751 ( PRS_CF = "751" AND (ACMTRS_NT = "1010" OR ACMTRS_NT = "1016" OR ACMTRS_NT = "1017" OR ACMTRS_NT = "1044" OR ACMTRS_NT = "1054" OR ACMTRS_NT = "2010" OR ACMTRS_NT = "2013" OR ACMTRS_NT = "2019" ) )
/CONDITION IS_PRS_751_EBS ( PRS_CF = "751" AND (ACMTRS_NT = "1041" OR ACMTRS_NT = "1044" OR ACMTRS_NT = "1054" OR ACMTRS_NT = "1051" OR ACMTRS_NT = "2041" OR ACMTRS_NT = "2044" OR ACMTRS_NT = "2051" OR ACMTRS_NT = "2054" ) )
/CONDITION IS_PRS_751_I17 ( PRS_CF = "751" AND (ACMTRS_NT = "1016" OR ACMTRS_NT = "1017"  OR ACMTRS_NT = "1044" OR ACMTRS_NT = "1054" OR ACMTRS_NT = "1051" OR ACMTRS_NT = "2041" OR ACMTRS_NT = "2044" OR ACMTRS_NT = "2051" OR ACMTRS_NT = "2054"  ) )
/CONDITION IS_PRS_751_I17_TRANS ( PRS_CF = "751" AND  ( ACMTRS_NT = "4200" OR ACMTRS_NT = "4220"  ) )  
/CONDITION IS_PRS_751_AI_LC ( PRS_CF = "751" AND  ( ACMTRS_NT = "3420" OR ACMTRS_NT = "3425"  OR ACMTRS_NT = "3430" OR ( ACMTRS_NT = "4206" ) OR ACMTRS_NT = "6440") )  
/CONDITION IS_PRS_751_PA_RECLASS ( PRS_CF = "751" AND  ( ACMTRS_NT = "1210" OR ACMTRS_NT = "1211"  OR ACMTRS_NT = "1212"  OR  ACMTRS_NT = "1151" OR ACMTRS_NT = "1154"  OR ACMTRS_NT = "2151"  OR ACMTRS_NT = "2154" ) )
/OUTFILE $SORT_O
/INCLUDE IS_PRS_751
/OUTFILE $SORT_O2
/INCLUDE IS_PRS_751_I17
/OUTFILE $SORT_O3
/INCLUDE IS_PRS_751_EBS
/OUTFILE $SORT_O4
/INCLUDE IS_PRS_751_I17_TRANS
/OUTFILE $SORT_O5
/INCLUDE IS_PRS_751_AI_LC
/OUTFILE $SORT_O6
/INCLUDE IS_PRS_751_PA_RECLASS
/COPY
exit
EOF
SORT


## FILTER PERICASE ON AI 

NSTEP=${NJOB}_07
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE + mvt retro interne du Pericase"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       3:1 -  3:,
        END_NT       4:1 -  4:EN,
        SEC_NF       5:1 -  5:EN,
        UWY_NF       6:1 -  6:,
        UW_NT        7:1 -  7:EN, 
        CED_NF       12:1 - 12:,     
        CTRRET_B   	 20:1 - 20:,
        SECACCSTS_CT 77:1 - 77:,
				PORTFOLIO    119:1 - 119:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION RETINT (CTRRET_B != "0" )
/INCLUDE RETINT
exit
EOF
SORT


## [021]

NSTEP=${NJOB}_08
# Filter ESF_FTRSLNK_TXT on PRS_CF = "740"
#-----------------------------------------------------------------------------
LIBEL="Filter ESF_FTRSLNK_TXT on PRS_CF = "740" "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_740.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  PRS_CF       1:1 -  1:,
         ACMTRS_NT    2:1 -  2:
/CONDITION IS_PRS_740 ( PRS_CF = "740")
/OUTFILE $SORT_O
/INCLUDE IS_PRS_740
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_09
#------------------------------------------------------------------------------------
LIBEL="sort GAAPMAP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GAAPMAP} 1000 1"
SORT_O="${ESF_FGAAPMAP_ASSUMED} 1000 1"
SORT_O2="${ESF_FGAAPMAP_RETRO} 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
	ORIGAPACMTRS_NT 1:1 - 1:,
	ORIACMTRS_NT 	2:1 - 2:, 
	ORIDETTRS_CF 	3:1 - 3:, 
	ORIDETTRS1_CF   3:1 - 3:1,	
	TARGAPACMTRS_NT 4:1 - 4:,  
	TARGACMTRS_NT   5:1 - 5:, 
	TARGDETTRS1_CF  6:1 - 6:1,
	TARGDETTRS_CF   6:1 - 6:
/KEYS   ORIGAPACMTRS_NT,
	ORIACMTRS_NT, 
	ORIDETTRS_CF, 
	TARGAPACMTRS_NT,  
	TARGACMTRS_NT, 
	TARGDETTRS_CF
/CONDITION RETRO (TARGDETTRS1_CF = "2" or TARGDETTRS1_CF = "4") and (ORIDETTRS1_CF = "2" or ORIDETTRS1_CF = "4")
/CONDITION ASUMMED ((TARGDETTRS1_CF = "1" or TARGDETTRS1_CF = "3") and (ORIDETTRS1_CF = "1" or ORIDETTRS1_CF = "3")) or ((TARGDETTRS1_CF = "2" or TARGDETTRS1_CF = "4") and (ORIDETTRS1_CF = "2" or ORIDETTRS1_CF = "4")
)
/OUTFILE ${SORT_O} overwrite
/INCLUDE ASUMMED
/OUTFILE ${SORT_O2} overwrite
/INCLUDE RETRO

exit
EOF
SORT



NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="split mapping in three norms"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FGAAPMAP_ASSUMED} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GAAPMAP_IFRS4.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_GAAPMAP_EBS.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_GAAPMAP_IFRS17.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        ORIGAPACMTRS_NT 1:1 - 1:,
        ORIACMTRS_NT    2:1 - 2:,
        ORIDETTRS_CF    3:1 - 3:,
        TARGAPACMTRS_NT 4:1 - 4:,
        TARGACMTRS_NT   5:1 - 5:,
        TARGDETTRS1_CF  6:1 - 6:1,
        TARGDETTRS_CF   6:1 - 6:
/KEYS   ORIGAPACMTRS_NT,
        ORIACMTRS_NT,
        ORIDETTRS_CF,
        TARGAPACMTRS_NT,
        TARGACMTRS_NT,
        TARGDETTRS_CF
/CONDITION POST_IFRS4 ( ORIGAPACMTRS_NT = "200" or ORIGAPACMTRS_NT = "100")
/CONDITION POST_EBS ( ORIGAPACMTRS_NT = "400" or ORIGAPACMTRS_NT = "401" or ORIGAPACMTRS_NT = "402")
/CONDITION POST_I17 ( ORIGAPACMTRS_NT = "300" or ORIGAPACMTRS_NT = "301" or ORIGAPACMTRS_NT = "302")
/OUTFILE ${SORT_O}
/INCLUDE POST_IFRS4
/OUTFILE ${SORT_O2}
/INCLUDE POST_EBS
/OUTFILE ${SORT_O3}
/INCLUDE POST_I17
exit
EOF
SORT

NSTEP=${NJOB}_11
#------------------------------------------------------------------------------------
LIBEL="split mapping in three norms"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FGAAPMAP_RETRO} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GAAPMAP_IFRS4.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_GAAPMAP_EBS.dat 2000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_GAAPMAP_IFRS17.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        ORIGAPACMTRS_NT 1:1 - 1:,
        ORIACMTRS_NT    2:1 - 2:,
        ORIDETTRS_CF    3:1 - 3:,
        TARGAPACMTRS_NT 4:1 - 4:,
        TARGACMTRS_NT   5:1 - 5:,
        TARGDETTRS1_CF  6:1 - 6:1,
        TARGDETTRS_CF   6:1 - 6:
/KEYS   ORIGAPACMTRS_NT,
        ORIACMTRS_NT,
        ORIDETTRS_CF,
        TARGAPACMTRS_NT,
        TARGACMTRS_NT,
        TARGDETTRS_CF
/CONDITION POST_IFRS4 ( ORIGAPACMTRS_NT = "200" or ORIGAPACMTRS_NT = "100")
/CONDITION POST_EBS ( ORIGAPACMTRS_NT = "400" or ORIGAPACMTRS_NT = "401" or ORIGAPACMTRS_NT = "402")
/CONDITION POST_I17 ( ORIGAPACMTRS_NT = "300" or ORIGAPACMTRS_NT = "301" or ORIGAPACMTRS_NT = "302")
/OUTFILE ${SORT_O}
/INCLUDE POST_IFRS4
/OUTFILE ${SORT_O2}
/INCLUDE POST_EBS
/OUTFILE ${SORT_O3}
/INCLUDE POST_I17
exit
EOF
SORT


### Use IRDPERICASE TO generate RETRO NP fields

NSTEP=${NJOB}_12
#------------------------------------------------------------------------------------
LIBEL="ONLY RETRO NP from ESF_IRDPERICASE0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IRDVPERICASE} 2000 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE0_RETRO_NP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        RETCTR_NF        3:1 -   3:,
        RETEND_NF        4:1 -   4:,
        RETSEC_NF        5:1 -   5:,
        RTY_NF           6:1 -   6:,
        RETUW_NT         7:1 -   7:,    
        NATRET_CF        49:1 - 49:               

/KEYS   RETCTR_NF,
				RETEND_NF,    
				RETSEC_NF,
				RTY_NF,   
				RETUW_NT 				
/CONDITION  RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  ) 
/INCLUDE RETRO_NP
exit
EOF
SORT





# [017] Inversion des colonnes CSM_F1 and LC_F1
#[010] [017] CSM and LC Q-1

NSTEP=${NJOB}_16B
# TRI DU ESF_CSM_LC_AMORT_PATTERN par CSUE
#-----------------------------------------------------------------------------
LIBEL="TRI DU ESF_CSM_LC_AMORT_PATTERN par CSUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_CSM_LC_AMORT_PATTERN_PREV} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_LC_AMORT_PATTERN_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            1:1 -  1:,
        SEC_NF            2:1 -  2:EN,
        UWY_NF            3:1 -  3:EN,
        UW_NF             4:1 -  4:EN,
				ASS_RET           5:1 -  5:,	
				RETRO_NP          6:1 -  6:,
				LC_F1             7:1 -  7:,				
				CSM_F1            8:1 -  8:
/KEYS   
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NF        
/OUTFILE ${SORT_O}
exit
EOF
SORT


#####

# [017] Inversion des colonnes CSM_F1 and LC_F1

#  (RETRO_NP != "N" OR RETRO_NP = "~" ) AND ( (PROF_CALC_NF = "3" AND CSM_F1="1" ) OR (PROF_CALC_NF = "1" AND LC_F1="1") ) 

## [029] /CONDITION  CSM_LC   (RETRO_NP != "N" OR RETRO_NP = "~" ) AND ( ( CSM_F1="1" ) OR ( LC_F1="1") ) 

## [034 ==>  OR (abs(CSM Ending Q-1) + abs(LC Ending Q-1) < 1 )

NSTEP=${NJOB}_16C
#  SORT ONLY (Prof=="3" and CSM=="1") OU (Prof=="1" and LC=="1")
#-----------------------------------------------------------------------------
LIBEL="SORT ONLY (Prof=="3" and CSM=="1") OU (Prof=="1" and LC=="1") WITH PROFITA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16B_${IB}_CSM_LC_AMORT_PATTERN_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_AMORT_PATTERN.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_CSM_AMORT_PATTERN_RNP.dat OVERWRITE 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            1:1 -  1:,
        SEC_NF            2:1 -  2:,
        UWY_NF            3:1 -  3:,
        UW_NF             4:1 -  4:,
				ASS_RET           5:1 -  5:,	
				RETRO_NP          6:1 -  6:,
				LC_F1             7:1 -  7:,				
				CSM_F1            8:1 -  8:,
        CTR_NF_F2         9:1 - 9:,
        SEC_NF_F2         10:1 - 10:,
        UWY_NF_F2         11:1 -  11:,
				PROF_CALC_NF      12:1 -  12:,	
				PREV_CLO_PRO      13:1 -  13:,
				INI_CLO_PRO       14:1 -  14:								
/KEYS   
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NF        
/CONDITION  CSM_LC   (RETRO_NP != "N" OR RETRO_NP = "~" ) AND ( ( CSM_F1="1" ) AND ( LC_F1="1") )  
/CONDITION  CSM_RNP  (RETRO_NP = "N") AND (CSM_F1 = "1")    
/OUTFILE ${SORT_O}
/INCLUDE CSM_LC   
/OUTFILE ${SORT_O2}
/INCLUDE CSM_RNP
exit
EOF
SORT




######


## [035] Debut Prise en compte des CSM LC ENDING

NSTEP=${NJOB}_16D
# TRI DU ESF_FCSM_LC_ENDING_ASS par CSUE et JOINTURE AVEC I4I
#-----------------------------------------------------------------------------
LIBEL="TRI DU ESF_FCSM_LC_ENDING_ASS  par CSUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCSM_LC_ENDING_ASS} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_LC_ENDING_ASS_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            1:1 -  1:,
        END_NT            2:1 -  2:EN,
        SEC_NF            3:1 -  3:EN,
        UWY_NF            4:1 -  4:EN,
        UW_NT             5:1 -  5:EN,
				CSM_ENDING_M 			6:1 	- 6:EN 18/3,
				LC_ENDING_M 			7:1 	- 7:EN 18/3,	
				CSM_PLUS_LC_M 		8:1 	- 8:EN 18/3					
/KEYS   
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT        
/OUTFILE ${SORT_O}
/REFORMAT CTR_NF, SEC_NF, UWY_NF, UW_NT, CSM_ENDING_M, LC_ENDING_M, CSM_PLUS_LC_M
exit
EOF
SORT



NSTEP=${NJOB}_16E
# TRI DU ESF_FCSM_ENDING_RNP RETRO par CSUE et JOINTURE AVEC I4I
#-----------------------------------------------------------------------------
LIBEL="TRI DU ESF_FCSM_ENDING_RNP  par CSUE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCSM_ENDING_RNP} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CSM_ENDING_RNP_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF            1:1 -  1:,                       
        RETEND_NT            2:1 -  2:EN,                     
        RETSEC_NF            3:1 -  3:EN,                     
        RTY_NF               4:1 -  4:EN,                     
        RETUW_NT             5:1 -  5:EN,                     
				CSM_ENDING_M 			   6:1 	- 6:EN 18/3		       
/KEYS   
        RETCTR_NF,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT        
/OUTFILE ${SORT_O}
/REFORMAT RETCTR_NF, RETSEC_NF, RTY_NF, RETUW_NT, CSM_ENDING_M
exit
EOF
SORT

###   Create Unique File contains CSM LC and CSM LC ENDING Before JOIN WITH OTHER NORMES FILE 

NSTEP=${NJOB}_16F
#-----------------------------------------------------------------------------
LIBEL="get CSM LC not in CSM LC ENDING"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16C_${IB}_PROF_CSM_LC_AMORT_PATTERN.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PROF_CSM_LC_AMORT_PATTERN_SANS_CSM_LC_ENDING.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF             1:1 -  1:, 
		SEC_NF             2:1 -  2:, 
		UWY_NF             3:1 -  3:,
		UW_NT              4:1 -  4:,
		ALL_COLS           1:1 -  8:,		
		CTR_NF_F2         1:1 -  1:, 
		SEC_NF_F2         2:1 -  2:, 
		UWY_NF_F2         3:1 -  3:, 
		UW_NT_F2          4:1 -  4:, 
		CSM_PLUS_LC_F2    7:1 -  7: 
/joinkeys
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${DFILT}/${NJOB}_16D_${IB}_CSM_LC_ENDING_ASS_O.dat 2000 1 "~" 
/joinkeys
        CTR_NF_F2,
        SEC_NF_F2,
        UWY_NF_F2,
        UW_NT_F2
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS, RIGHTSIDE:CSM_PLUS_LC_F2
exit
EOF
SORT


NSTEP=${NJOB}_16G
#------------------------------------------------------------------------------
LIBEL="MERGE CSM LC AMORT WITH CSM_LC ENDING AND GENERATE UNIQUE BY CSUE ==> /SUM  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16F_${IB}_SORT_PROF_CSM_LC_AMORT_PATTERN_SANS_CSM_LC_ENDING.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_16D_${IB}_CSM_LC_ENDING_ASS_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_LC_AMORT_PATTERN_CSM_LC_ENDING.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       1:1 -  3:, 
        		SEC_NF       2:1 -  2:, 
        		UWY_NF       3:1 -  3:, 
       		  UW_NT        4:1 -  4:
/KEYS CTR_NF, 
      SEC_NF,
      UWY_NF,
      UW_NT
/SUM 
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_16H
#-----------------------------------------------------------------------------
LIBEL="get RETRO NP CSM not in CSM RETRO NP ENDING"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16C_${IB}_CSM_AMORT_PATTERN_RNP.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PROF_CSM_AMORT_PATTERN_SANS_CSM_ENDING_RNP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF             1:1 -  1:, 
		SEC_NF             2:1 -  2:, 
		UWY_NF             3:1 -  3:,
		UW_NT              4:1 -  4:,
		ALL_COLS           1:1 -  8:,		
		CTR_NF_F2         1:1 -  1:, 
		SEC_NF_F2         2:1 -  2:, 
		UWY_NF_F2         3:1 -  3:, 
		UW_NT_F2          4:1 -  4:, 
		CSM_PLUS_LC_F2    7:1 -  7: 
/joinkeys
        CTR_NF,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${DFILT}/${NJOB}_16E_${IB}_CSM_ENDING_RNP_O.dat 2000 1 "~" 
/joinkeys
        CTR_NF_F2,
        SEC_NF_F2,
        UWY_NF_F2,
        UW_NT_F2
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS, RIGHTSIDE:CSM_PLUS_LC_F2
exit
EOF
SORT


NSTEP=${NJOB}_16I
#------------------------------------------------------------------------------
LIBEL="MERGE CSM RETRO NP AMORT WITH CSM RETRO NP ENDING GENERATE UNIQUE BY CSUE==> /SUM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16H_${IB}_SORT_PROF_CSM_AMORT_PATTERN_SANS_CSM_ENDING_RNP.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_16E_${IB}_CSM_ENDING_RNP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROF_CSM_AMORT_PATTERN_CSM_ENDING_RNP.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       1:1 -  3:, 
        		SEC_NF       2:1 -  2:, 
        		UWY_NF       3:1 -  3:, 
       		  UW_NT        4:1 -  4:
/KEYS CTR_NF, 
      SEC_NF,
      UWY_NF,
      UW_NT
/SUM 
/OUTFILE ${SORT_O}
exit
EOF
SORT


## [035] FIN Prise en compte des CSM LC ENDING


######

## EST_FPLATXCUMALL0=/scor/home/u006596/martin/perm/M_ESCJ0660_FPLATXCUMALL0.dat
## SORT_I=${EST_FPLATXCUMALL0}

NSTEP=${NJOB}_35
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Sort FPLATXCUMALL0 file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${ESF_FPLATXCUMALL0}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUMALL0.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 2:1 - 2:EN,
        RETRTY_NF 3:1 - 3:,
        PLC_NT    4:1 - 4:EN
/KEYS RETCTR_NF, RETRTY_NF, RETSEC_NF, PLC_NT
/SUM
/STABLE
exit
EOF
SORT 


NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Extract CUR of  BALSHTYEA=${ICLODAT_A}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCURQUOT_TXT}  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCURQUOT_${ICLODAT_A}.dat  2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CURQUOT_UWY_NF   3:1 -  3:
/CONDITION IS_BALSHTYEA ( CURQUOT_UWY_NF = "${ICLODAT_A}" )
/INCLUDE IS_BALSHTYEA
/COPY
exit
EOF
SORT



NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
LIBEL="Extend IRDVPERICASE with CURQUOT_RATE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IRDVPERICASE}  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_PCP.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
                all_cols                 1:1  - 205:
/joinkeys
       SSD_CF
      ,PCPCUR_CF
/INFILE ${DFILT}/${NJOB}_40_${IB}_FCURQUOT_${ICLODAT_A}.dat 1000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols
       ,rightside:CURQUOT_RATE

exit
EOF
SORT



NSTEP=${NJOB}_90
#------------------------------------------------------------------------------
LIBEL="Extend IRDPERICASE with EGPCUR_RATE, PCPCUR and EGPCUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_IRDPERICASE_PCP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_PCP_EGP_O.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        EGPCUR_CF        23:1 - 23:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 206:
/joinkeys
       SSD_CF
      ,EGPCUR_CF
/INFILE ${DFILT}/${NJOB}_40_${IB}_FCURQUOT_${ICLODAT_A}.dat 1000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:all_cols
        ,rightside:CURQUOT_RATE
        ,leftside:PCPCUR_CF
        ,leftside:EGPCUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_IRDPERICASE_PCP_EGP_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_PCP_EGP.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS CTR_NF    3:1 -  3:,
        END_NT    4:1 -  4:,
        SEC_NF    5:1 -  5:EN,
        UWY_NF    6:1 -  6:,
        UW_NT     7:1 -  7:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT

exit
EOF
SORT

JOBEND
