#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Transformation REQ 20.1
# nom du script SHELL           : ESFD4072.cmd
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
# [019] 15/04/2024 MZM : SPIRA 111156   20.1 - I17 - REQ 20.1 - Prod I17 - Opening 24 vs Closing 23 - Cancellation done on Reclass transactions while should not  REVERT
# [020] 16/04/2024 MZM : SPIRA 111156   20.1 - I17 - REQ 20.1 - Prod I17 - Opening 24 vs Closing 23 - Cancellation done on Reclass transactions while should not
# [021] 16/01/2025 MZM : SPIRA 112437   20.1 - I17 - Add conversion in EGPI currency of PA reclass
#======================================================================================================================

#set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

CLODAT_D=${PARM_ICLODAT_D}

ICLODAT_A=`echo ${CLODAT_D} | awk '{print substr($0,1,4)}'`


ECHO_LOG ""                                                                                     >>$FLOG
ECHO_LOG "#....................... INPUT ..........................................."           >>$FLOG
ECHO_LOG "#===> CLODAT_D.............................: ${CLODAT_D} "                            >>$FLOG
ECHO_LOG "#===> ICLODAT_A............................: ${ICLODAT_A} "                           >>$FLOG
ECHO_LOG "#===> NORME_CF.............................: ${NORME_CF} "                            >>$FLOG
ECHO_LOG "#===> PRS_CF...............................: ${PRS_CF} "                              >>$FLOG

## TI

##ESF_FTECLEDAR=/scor/home/u006596/martin/perm/P_ESFD4070_I17G_GAP_MAP_STD_FTECLEDAR_POS_20241231.dat
##ESF_FTECLEDAA=/scor/home/u006596/martin/perm/P_ESFD4070_I17G_GAP_MAP_STD_FTECLEDAA_POS_20241231.dat

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="extend  ${ESF_FTCLEDAR} withe retro pericase infos  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDAR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDAR.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	TECLEDAR_RETCTR_NF  	    24:1	-	24:,
	TECLEDAR_RETEND_NT  	    25:1	-	25:,
	TECLEDAR_RETSEC_NF  	    26:1	-	26:,
	TECLEDAR_RTY_NF     	    27:1	-	27:,
	TECLEDAR_RETUW_NT   	    28:1	-	28:,
	TECLEDAR_COL1-44    	     1:1	-	44:,
    TECLEDAR_LOBACC_CF	        45:1	 -	45	:,
    TECLEDAR_LOBRET_CF	        46:1	 -	46	:,
    TECLEDAR_SOBACC_CF	        47:1	 -	47	:,
    TECLEDAR_SOBRET_CF	        48:1	 -	48	:,
    TECLEDAR_TOPACC_CF	        49:1	 -	49	:,
    TECLEDAR_TOPRET_CF	        50:1	 -	50	:,
    TECLEDAR_NATACC_CF	        51:1	 -	51	:,
    TECLEDAR_NATRET_CF	        52:1	 -	52	:,
    TECLEDAR_GARACC_CF	        53:1	 -	53	:,
    TECLEDAR_GARRET_CF	        54:1	 -	54	:,
    TECLEDAR_PCPRSKTRYACC_CF	55:1	 -	55	:,
    TECLEDAR_PCPRSKTRYRET_CF	56:1	 -	56	:,
    TECLEDAR_USRCRTCODACC_CT	57:1	 -	57	:,
    TECLEDAR_USRCRTCODRET_CT	58:1	 -	58	:,
    TECLEDAR_USRCRTVALACC_LM	59:1	 -	59	:,
    TECLEDAR_USRCRTVALRET_LM	60:1	 -	60	:,
    TECLEDAR_CTRNAT_CT	        61:1	 -	61	:,
    TECLEDAR_RETCTRCAT_CF	    62:1	 -	62	:,
    TECLEDAR_WRKCAT_CT	        63:1	 -	63	:,
    TECLEDAR_PRDCOD_CT	        64:1	 -	64	:,
    TECLEDAR_ANLCTY_CF	        65:1	 -	65	:,
    TECLEDAR_ACCADMTYP_CT	    66:1	 -	66	:,
    TECLEDAR_RETACCTYP_CT	    67:1	 -	67	:,
    TECLEDAR_COL68-118   	    68:1	-	118:,
    PER_CTR_NF			         3:1 	- 3:,
    PER_END_NT			         4:1 	- 4:,
    PER_SEC_NF			         5:1 	- 5:,
    PER_UWY_NF			         6:1 	- 6:,
    PER_UW_NT 			        7:1 	- 7:,
	PER_GAR_CF			        32	:1		 -		32	:	,
	PER_LOB_CF			        38	:1		 -		38	:	,
	PER_NAT_CF			        49	:1		 -		49	:	,
	PER_PCPRSKTRY_CF	        52	:1		 -		52	:	,
	PER_SOB_CF			        81	:1		 -		81	:	,
	PER_TOP_CF			        84	:1		 -		84	:	,
	PER_ACCADMTYP_CT	        97	:1		 -		97	:	,
	PER_RETCTRCAT_CF	        107	:1		 -		107	:	,
	PER_USRCRTCOD_CT	        115	:1		 -		115	:	,
	PER_USRCRTVAL_LM	        116	:1		 -		116	:	
/joinkeys
	TECLEDAR_RETCTR_NF ,
	TECLEDAR_RETEND_NT ,
	TECLEDAR_RETSEC_NF ,
	TECLEDAR_RTY_NF    ,
	TECLEDAR_RETUW_NT 
/INFILE ${ESF_IRDVPERICASE} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}  overwrite
/REFORMAT
    leftside:TECLEDAR_COL1-44           ,
    leftside:TECLEDAR_LOBACC_CF	        ,               
    rightside:PER_LOB_CF	            ,
    leftside:TECLEDAR_SOBACC_CF	        ,
    rightside:PER_SOB_CF	            ,
    leftside:TECLEDAR_TOPACC_CF	        ,
    rightside:PER_TOP_CF	            ,
    leftside:TECLEDAR_NATACC_CF	        ,
    rightside:PER_NAT_CF	            ,
    leftside:TECLEDAR_GARACC_CF	        ,
    rightside:PER_GAR_CF	            ,
    leftside:TECLEDAR_PCPRSKTRYACC_CF	,
    rightside:PER_PCPRSKTRY_CF          ,
    leftside:TECLEDAR_USRCRTCODACC_CT	,
    rightside:PER_USRCRTCOD_CT	        ,
    leftside:TECLEDAR_USRCRTVALACC_LM	,
    rightside:PER_USRCRTVAL_LM	        ,
    leftside:TECLEDAR_CTRNAT_CT	        ,
    rightside:PER_RETCTRCAT_CF	        ,
    leftside:TECLEDAR_WRKCAT_CT	        ,
    leftside:TECLEDAR_PRDCOD_CT	        ,
    leftside:TECLEDAR_ANLCTY_CF	        ,
    leftside:TECLEDAR_ACCADMTYP_CT	    ,
    rightside:PER_ACCADMTYP_CT	        ,
    leftside:TECLEDAR_COL68-118 
exit
EOF
SORT

## TI

##zcat  /scor/home/u006596/martin/temporaire/P_ESFD4070_ESFD4072_30_I17G_GAP_MAP_STD_OPT_FTECLEDAA_LIFE.dat.gz > ${DFILT}/P_ESFD4070_ESFD4072_30.dat
##zcat /scor/home/u006596/martin/temporaire/P_ESFD4070_ESFD4072_40_I17G_GAP_MAP_STD_OPT_FTECLEDAR_LIFE.dat.gz > ${DFILT}/P_ESFD4070_ESFD4072_40.dat

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="merge all FTECLED* and split on SANS_REJ_OPNG and AVEC_REJ_OPNG"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDAA} 2000 1 "                      
SORT_I2="${DFILT}/${NJOB}_10_${IB}_FTECLEDAR.dat 2000 1 "                      
SORT_I3="${DFILT}/${NCHAIN}_ESFD4072_30_${IB}_FTECLEDAA_LIFE.dat 20001 1 "   
SORT_I4="${DFILT}/${NCHAIN}_ESFD4072_40_${IB}_FTECLEDAR_LIFE.dat 2000  1 "    
##SORT_I3="${DFILT}/P_ESFD4070_ESFD4072_30.dat 20001 1 "   
##SORT_I4="${DFILT}/P_ESFD4070_ESFD4072_40.dat 2000  1 "                     
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_SANS_REJ_OPNG.dat"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTECLEDA_AVEC_REJ_OPNG.dat"
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
				ORICOD_LS 104:1 - 104:,        
        GT_ANNUL_OPNG   114:1 - 114:,
				FILLER_1_113    1:1 - 113:,
				FILLER_115_118  115:1 -118: 
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
/CONDITION ANNU_OPNG  (GT_ANNUL_OPNG = "A" or GT_ANNUL_OPNG = "O")
/OUTFILE ${SORT_O}
/OMIT ANNU_OPNG
/OUTFILE ${SORT_O2}
/INCLUDE ANNU_OPNG   
      
exit
EOF
SORT

NSTEP=${NJOB}_30
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLATXCUM}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUM.dat
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
# Affectation par placement
#-----------------------------------------------------------------------------
LIBEL=" AGREGATES retro Affectation MVT par placement "
PRG=ESTC1052B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
FPLATXCUM CUM
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NJOB}_30_${IB}_FPLATXCUM.dat"
export ${PRG}_I2="${DFILT}/${NJOB}_20_${IB}_FTECLEDA_SANS_REJ_OPNG.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA_SANS_REJ_OPNG.dat"
EXECPRG


##[018] Vider colonne _67 sauf pour la nouvelle condition "BALSHEY_NF = ${PARM_CONSOYEA} AND BALSHRMTH_NF > 9 AND GT_ANNUL_OPNG != "A" "

##[019] /CONDITION VIDER_NEWCOLS5  (ORICOD_LS = "RECLASSP" or ORICOD_LS = "RECLASSL") AND ( BALSHEY_NF != ${PARM_CONSOYEA} OR BALSHRMTH_NF <= 9 OR GT_ANNUL_OPNG = "A" )  -REVERT

## [020] Deb Modif

NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="Join ${DFILT}/${NJOB}_20_${IB}_FTECLEDA_AVEC_REJ_OPNG.dat with PRS_ 740_FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_FTECLEDA_AVEC_REJ_OPNG.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_AVEC_REJ_OPNG_NOT_740.dat 2000 1"
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
/JOIN UNPAIRED LEFTSIDE ONLY       
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:COLS_STD_F1
	,rightside:PRS_CF_F2  
	,rightside:ACMTRS_NT_F2 	  							  
exit
EOF
SORT



NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="Join ${DFILT}/${NJOB}_20_${IB}_FTECLEDA_AVEC_REJ_OPNG.dat with PRS_ 740_FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_FTECLEDA_AVEC_REJ_OPNG.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_AVEC_REJ_OPNG_ET_PRS_740.dat 2000 1"
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


NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
# Merge des fichiers
#------------------------------------------------------------------------------
LIBEL="MERGE CUMUL DE SANS_REJ_OPNG.dat et FTECLEDA_AVEC_REJ_OPNG_ET_740.dat  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ESTC1052B_FTECLEDA_SANS_REJ_OPNG.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_50_${IB}_FTECLEDA_AVEC_REJ_OPNG_ET_PRS_740.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_SANS_REJ_OPNG_MERGE_AVEC_REJ_OPNG_ET_740.dat 2000 1"
##SORT_O="${ESF_FTECLEDA_OUT}"
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
  GT_ANNUL_OPNG   114:1 - 114:,
	FILLER_1_113    1:1 - 113:,
	FILLER_115_118  115:1 - 118:		
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
/CONDITION VIDER_NEWCOLS5  (ORICOD_LS = "RECLASSP" or ORICOD_LS = "RECLASSL")       
/DERIVEDFIELD GT_ANNUL_OPNG_NEW if VIDER_NEWCOLS5 then "" else GT_ANNUL_OPNG   	
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT FILLER_1_113, GT_ANNUL_OPNG_NEW, FILLER_115_118
exit
EOF
SORT


NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
# Merge des fichiers
#------------------------------------------------------------------------------
LIBEL="Merge des fichiers et cumul sur Cle ==> ${ESF_FTECLEDA_OUT} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_FTECLEDA_SANS_REJ_OPNG_MERGE_AVEC_REJ_OPNG_ET_740.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_45_${IB}_FTECLEDA_AVEC_REJ_OPNG_NOT_740.dat 2000 1"
##SORT_I2="${DFILT}/${NJOB}_45_${IB}_FTECLEDA_AVEC_REJ_OPNG_NOT_740.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_ALL.dat 2000 1"
##SORT_O="${ESF_FTECLEDA_OUT}"
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
  GT_ANNUL_OPNG   114:1 - 114:,
	FILLER_1_113    1:1 - 113:,
	FILLER_115_118  115:1 - 118:,
	FILLER_1_118    1:1 - 118: 	
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
/REFORMAT FILLER_1_118
exit
EOF
SORT


## Deb # [021] 

NSTEP=${NJOB}_75
#-----------------------------------------------------------------------------
LIBEL="Join ${DFILT}/${NJOB}_70_${IB}_FTECLEDA_ALL.dat with FTRSLNK_751_PA_RECLASS.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_FTECLEDA_ALL.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_ALL_SANS_FTRSLNK_751_PA_RECLASS.dat 2000 1"
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
        			COLS_STD_F1       1:1 - 118:,                                                                                                                                                                  
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


NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Join ${DFILT}/${NJOB}_70_${IB}_FTECLEDA_ALL.dat with FTRSLNK_751_PA_RECLASS.dat "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_FTECLEDA_ALL.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS.dat 2000 1"
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
        			COLS_STD_F1       1:1 - 118:,                                                                                                                                                                  
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

## Align CURRENCY on CUR PERICASE WITH ${DFILT}/${NJOB}_75_${IB}_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS.dat

NSTEP=${NJOB}_81
# -  Sort of IADPERICASE
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE + on Omet les mouvements de retro interne du Pericase"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       3:1 -  3:,
        END_NT       4:1 -  4:,
        SEC_NF       5:1 -  5:EN,
        UWY_NF       6:1 -  6:,
        UW_NT        7:1 -  7:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT



## TI 

##ESF_FCURQUOT_TXT=/scor/home/u006596/martin/perm/P_ESCJ0660_FCURQUOT_TXT.dat
##ESF_FBOPRSLNK_TXT=/scor/home/u006596/martin/perm/P_ESCJ0660_FBOPRSLNK_TXT.dat


NSTEP=${NJOB}_81A
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


##/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_40_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"

NSTEP=${NJOB}_81B
#------------------------------------------------------------------------------
LIBEL="Extend IADPERICASE with CURQUOT_RATE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_81_${IB}_SORT_IADPERICASE.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 204:
/joinkeys
       SSD_CF
      ,PCPCUR_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_40_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"
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

NSTEP=${NJOB}_81C
#------------------------------------------------------------------------------
LIBEL="Extend IADPERICASE with EGPCUR_RATE, PCPCUR and EGPCUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_81B_${IB}_IADPERICASE_PCP.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP_EGP_O.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        EGPCUR_CF        23:1 - 23:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols                 1:1  - 205:
/joinkeys
       SSD_CF
      ,EGPCUR_CF
/INFILE ${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_40_${IB}_FCURQUOT_${ICLODAT_A}.dat 2000 1 "~"
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


NSTEP=${NJOB}_81D
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_81C_${IB}_IADPERICASE_PCP_EGP_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP_EGP.dat 2000 1 "
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

### FTECLEDA ==> CONVERT 

NSTEP=${NJOB}_83A
#------------------------------------------------------------------------------
LIBEL="Sort ESF_FTECLEDA_4070"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_RATE.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF          11:1 - 11:,
        CUR_CF          18:1 - 18:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 120:

/joinkeys 
      SSD_CF
	   ,CUR_CF
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


NSTEP=${NJOB}_88
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_83A_${IB}_SORT_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_RATE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_RATE.dat 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS SSD_CF            1:1 -  1:,
        RTY_NF           27:1 - 27:,
        RETCUR_CF        34:1 - 34:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 121:

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
#------------------------------------------------------------------------------------
LIBEL="Generate PA_RECLASS_RATE_FBOPRSLNK_RETRO AND PA_RECLASS_RATE_FBOPRSLNK_ASSUME"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_88_${IB}_SORT_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_RATE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_RATE_FBOPRSLNK_ASSUME.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
				TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,  
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
        RETCUR_CF        34:1 - 34:,    	
				FILLER					1:1		- 122:	
/KEYS   
				 CTR_NF 	
				,END_NT	
				,SEC_NF 	
				,UWY_NF 	
				,UW_NT 	
/CONDITION ASS_ONLY (TRNCOD1_CF = "1" OR TRNCOD1_CF = "3")
/OUTFILE ${SORT_O}
/INCLUDE ASS_ONLY
exit
EOF
SORT



NSTEP=${NJOB}_92
#------------------------------------------------------------------------------------
LIBEL="Generate PA_RECLASS_RATE_FBOPRSLNK_RETRO AND PA_RECLASS_RATE_FBOPRSLNK_ASSUME"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_88_${IB}_SORT_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_RATE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_RATE_FBOPRSLNK_RETRO.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
				TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,  
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
        RETCUR_CF        34:1 - 34:,    	
				FILLER					1:1		- 122:	
/KEYS   
				 RETCTR_NF 	
				,RETEND_NT	
				,RETSEC_NF 	
				,RTY_NF 	 	
/CONDITION RETRO_ONLY (TRNCOD1_CF = "2" OR TRNCOD1_CF = "4")
/OUTFILE ${SORT_O}
/INCLUDE RETRO_ONLY
exit
EOF
SORT


NSTEP=${NJOB}_96
#------------------------------------------------------------------------------
LIBEL="FTECLEDAR_4070 RETRO PREPARATION : CONVERSION DES MONTANTS DANS DEVISE ALIMENT "
PRG=ESFC4070
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${ICLODAT_A}
GTF_CURQUOT_RATE 121
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESFD4033_1_${NORME_CF}_100_${IB}_IRDPERICASE_PCP_EGP.dat
export ${PRG}_I2=${DFILT}/${NJOB}_92_${IB}_SORT_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_RATE_FBOPRSLNK_RETRO.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_CUR_UPD_RETRO.dat
EXECPRG



NSTEP=${NJOB}_98
#------------------------------------------------------------------------------
LIBEL="FTECLEDA_4070 ASSUMED PREPARATION : CONVERSION DES MONTANTS DANS DEVISE ALIMENT "
PRG=ESFC4070
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT A
BALSHTYEA_NF ${ICLODAT_A}
GTF_CURQUOT_RATE 121
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_81D_${IB}_IADPERICASE_PCP_EGP.dat
export ${PRG}_I2=${DFILT}/${NJOB}_90_${IB}_SORT_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_RATE_FBOPRSLNK_ASSUME.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_CUR_UPD_ASSUME.dat
EXECPRG


####




### # [021] Fin Align CURRENCY on CUR PERICASE

NSTEP=${NJOB}_160
#------------------------------------------------------------------------------
# Merge des fichiers
#------------------------------------------------------------------------------
LIBEL="Merge des fichiers et cumul sur Cle ==> ${ESF_FTECLEDA_OUT} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_FTECLEDA_ALL_SANS_FTRSLNK_751_PA_RECLASS.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_96_${IB}_ESFC4070_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_CUR_UPD_RETRO.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_98_${IB}_ESFC4070_FTECLEDA_AVEC_FTRSLNK_751_PA_RECLASS_CUR_UPD_ASSUME.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_ALL.dat 2000 1"
##SORT_O="${ESF_FTECLEDA_OUT}"
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
  GT_ANNUL_OPNG   114:1 - 114:,
	FILLER_1_113    1:1 - 113:,
	FILLER_115_118  115:1 - 118:,
	FILLER_1_118    1:1 - 118: 	
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
/REFORMAT FILLER_1_118
exit
EOF
SORT


###

NSTEP=${NJOB}_170
#------------------------------------------------------------------------------
# copy ESF_FTECLEDA_OUT  ==> $DFILP
#------------------------------------------------------------------------------
LIBEL="copy $ESF_FTECLEDA_OUT  ==> ${ESF_FTECLEDA_OUT_ESFD4030}"
EXECKSH_MODE=P
EXECKSH "cp ${DFILT}/${NJOB}_160_${IB}_FTECLEDA_ALL.dat ${ESF_FTECLEDA_OUT} "

NSTEP=${NJOB}_180
#------------------------------------------------------------------------------
# copy ESF_FTECLEDA_OUT  ==> $DFILP
#------------------------------------------------------------------------------
LIBEL="copy $ESF_FTECLEDA_OUT  ==> ${ESF_FTECLEDA_OUT_ESFD4030}"
EXECKSH_MODE=P
EXECKSH "cp ${ESF_FTECLEDA_OUT} ${ESF_FTECLEDA_OUT_ESFD4030}"

## [020] Fin Modif

JOBEND
