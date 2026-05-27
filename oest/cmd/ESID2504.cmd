#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATES
#                                 Retrocession closing period process
# nom du script SHELL		: ESID2504.cmd
# revision			: $Revision: 1.1.1.1 $
# date de creation		: 06/10/1997
# auteur			: CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# Description :
#   Application of cessions and placements to the acceptance estimates
#   for proportional retrocession treaties
#
#   This job computes four Technical Ledger (TL) files :
#   - retrocession-per-acceptance (AR) TL of estimates and actualized
#     not including raised commissions (EST_DLREGTAR)
#   - retrocession-per-retrocessionnaire (RR) TL of estimates and actualized
#     not including raised commissions (EST_DLREGTR)
#   - retrocession-per-acceptance (AR) TL of estimates and actualized
#     raised commissions (EST_DLREMAJGTAR)
#   - retrocession-per-retrocessionnaire (RR) TL of estimates and actualized
#     raised commissions (EST_DLREMAJGTR)
#
# Output file sort  ${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat
#		    ${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
#	            ${EST_DLREGTR}
#		    ${EST_DLREMAJGTR}
#
# Launch C programs ESTC2303 and ESTC2304
# JOB LAUNCHED BY : ESID2500.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#   30/ 01 / 03 J. Ribot ajout gestion colonne retintamt_m
#
#   09/ 06 / 09 J. Ribot spot 17495 ajout step 07 omit lob 30 et 31
#   07/ 10 / 11 JFVDV. [22715] Mise en commentaire des lignes CONDITION & OMIT au STEP 07
#   03/ 07 / 12 JFVDV. [23390] SOLVENCY II Amenagements (ajout step 39A, 39B, 39C)
#[05] 10/07/2012 Roger Cassis :spot:23802 SOLVENCY II Ajout fichiers post-omega
#[06] 29/10/2012 Roger Cassis :spot:24041 SOLVENCY II
#[07] 20/03/2013 Philippe Pezout :spot:24979 SOLVENCY II
#[08] 16/05/2013 Roger Cassis :spot:25171 Suppression du fichier EPO_DLDSIIGTAA
#[09] 29/05/2013 PPEZOUT :spot:25171 Modifications Solvency
#[10] 13/01/2014 CDESPRET :spot:26209 Ajout condition discount
#[11] 02/11/2015 P PEZOUT :spot:29615 EST45 gestion des doubles bouclettes RETRO
#[12] 05/10/2015 -=Dch=-  :spot:29162 - Ajout du fichier p�rim�tre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF)
#[13] 02/02/2016 Florent  :spot:29066 GT � 71 colonnes
#[14] 24/05/2016 Roger    :spot:30516 - Ajout colonnes 58 � 71 dans tri avant ESTC2304
#[15] 09/02/2017 MMA      :Spira 58492 - SUppression de "la STEP 39" ventillation par placement type LIFE sur les EBS
#                                        + Renommage archive
#[16] 17/01/2019 JYP : spira 69157 : change filename DLDGTAA FUTURES
#[17] 27/03/2019 JYP : spira 77117 : when IFRS POC/POS, DLDGTAA = empty.dat
#[18] 17/04/2019 Roger   :Spira:65656 Normalisation des fichiers pour separation IFRS/EBS
#[19] 13/08/2019 MZM     :spira:71539 - REQ10.4-REQ10.5/Retro override commission mangement
#[20] 13/12/2019 MZM     :spira:71539 - REQ10.4-REQ10.5/Retro override commission : Jointure avec FPLC et + ajout Step [_29]
#[21] 20/01/2020 MZM     :spira:71539 - REQ10.4-REQ10.5/Retro override commission : G�n�ration de deux fichiers permanents a integrer dans ESPD3802
#[22] 26/03/2020 MZM     :spira:85662 - Future OVERRIDEby Assumed KO
#[23] 23/06/2020 MZM     :spira:87321 - I17 - Ini - Retro overrider not specific to placement : Tri du fichier FPLC sur PLC en entier
#[24] 31/08/2020 MZM     :spira:88354 - No Cession of Assume Initial Components
#[25] 01/09/2020 MZM     :spira:87320 - I17 Overrider - Based on criteria
#[26] 01/10/2020 JYP :spira:83609 : microAOC : add IB into DFILT files
#[27] 16/11/2020 MZM :spira:88626 : DLRGTAA non utise si I17G_LCC_RPO_INI ou I17G_LCC_RPO_STD
#[28] 07/01/2021 MZM :spira:90406 : DLRGTAA non utise si I17G_NDC_RPO_INI ou I17G_NDC_RPO_STD
#[29] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[30] 01/02/2021 JYP :spira:90406/91991: DLRGTAA non utis� si I17(GPL)_NDC_RPO(INI or STD) I17(GPL)_NDC_RPO(INI or STD) 
#[31] 06/02/2021 JYP :spira:90406/91991: DLRGTAA non utilis� si I17(GPL)_LCC_RPO(INI or STD) I17(GPL)_LCC_RPO(INI or STD) 
#[32] 22/03/2021 MZM :spira:94899 Generation des Placements dans le DLGTAR pour IDF_CT I17(G/P/L)_NDC_RPO(INI / STD) : 
#                                : Modif du tri (NoSection Numerique) et Ajout PLC_NT Cle de tri au step 48 
#[32] 08/06/2021 MZM :spira:94899: Remplacement IDF_CT I17(GPL)_NDC_RPO_STD par EBS_ESFD2550 au step 48 
#[33] 20/07/2021 MZM :spira:93933: Mode Parallele : modif test INV par VNORME I4I
#[34] 07/09/2021 MZM :spira:98331: DLRGTAA non utilis� si I17(GPL)_FUT_RPO(INI) or IDF_CT = EBS_ESFD2550
#[35] 16/08/2021 MZM :spira:98332 IFRS17 retro- Incorrect RETINTAMT_M (ESFD2550) 
#[36] 02/11/2021 MZM :spira:87852 RETRO TAXE MANAGEMENT 
#[37] 10/12/2021 MZM :spira:97734 APPLICATION LORETROFACTOR JUSTE APRES LES CESSION
#[38] 12/15/2021 JBD :spira:99819 Cession of assumed contract incepting after closing date
#[39] 24/12/2021 JYP :spira:99819 bugfix closing dev KO, type issue
#[40] 24/12/2021 JYP :spira:99819 bugfix closing dev KO, syncort length issue
#[41] 06/01/2022 JYP/JBD/MZM :spira:99819 bugfix closing dev KO, if/then/fi issue
#[42] 10/01/2022 MZM :spira:91532 Bug Fix : Taille Syncsort de 1000 ==> 2000
#[43] 14/01/2022 MZM :spira:100743 (Reactivation de la 98331 - Reutilisation du DLRGTAA)
#[44] 06/05/2022 MZM :spira:104209 REMAINING CHARGES ESTIMATES ENDING ANO Assumed Overrides
#[45] 17/06/2022 MZM :spira:104778 Ajout pour nouveau couloir I17S 
#[46] 12/09/2022 MZM :spira:106628 PRD - Ecarts vues RA/RR Generation PLC et RTO dans GTAR pour IDF_CF I17G/L/P_FUT_RPO_INI
#[47] 24/11/2023 JYP/MZM/Florian :Spira:110901 add parameter Y_N for RET OVERRIDE exclude some TC when RAICOM_B=0 
#[48] 13/02/2024 HR/MZM/Florian :Spira:111062 I17 - No retro link for LC assumed cession on onerous Q+1  
#[49] 03/07/2024 MZM :Spira:111875 I17 - No retro link for LC assumed cession on onerous Q+1 (Modification du MERGE EST_FCES et EST_FCES_ESFD5040 ) 
#[50] 17/10/2024 MZM :Spira:112322 Retro plan N+1 - Missing 2nd loop retrocession : Merge ESFD5040_FCES AND FCES ON IDF_CT I17G/L/P/LCC_INI on key CSUE R  
#[51] 25/11/2024 MZM :Spira:112386 Retro Plan N+1 - Missing INI positions cession on subsequent loops
#[52] 18/02/2025 MZM :Spira:112608 I17 - No cession of LC ending for onerous Q+1 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job initialisation
JOBINIT

# Get parameters
BALSHTYEA_NF=$1
CLODAT_D=$2
TYPEINV=$3
NORME=$4
BOUCLE=$5



##[005] [18] [20]
#if [ "${TYPEINV}" != "INV" ]
#then
#	EST_FDETTRS=${EPO_FDETTRS}
#	EST_FRETTRF=${EPO_FRETTRF}
#	EST_FCES=${EPO_FCES}
#	EST_FPLC=${EPO_FPLC}
#	EST_FCURCVSNI=${EPO_FCURCVSNI}
#	EST_FCURQUOT=${EPO_FCURQUOT}
#	EST_FCURCVSN=${EPO_FCURCVSN}
#	EST_FPLACEMT0=${EPO_FPLACEMT0}
#	EST_IADVPERICASE=${EPO_IADVPERICASE}
#	EST_FTRANSCODE=${EPO_FTRANSCODE}
#	EST_FTRSLNK=${EPO_FTRSLNK}
#	if [ "${TYPEINV}" = "POS" ]
#	then
#		if [ "${NORME}" = "EBS" ]
#		then
#		  EST_DLRGTAA=${EPO_DLRGTAASIISO}
#			EST_DLDGTAA=${EPO_DLDGTAASIISO}
#			EST_DLREGTAR=${EPO_DLREGTARSIISO}
#			EST_DLREMAJGTAR=${EPO_DLREMAJGTARSIISO}
#			EST_DLREGTR=${EPO_DLREGTRSIISO}
#			EST_DLREMAJGTR=${EPO_DLREMAJGTRSIISO}
#			EST_DLREGTAR_OVR=${EPO_DLREGTAR_OVRSIISO}
#			EST_DLREGTR_OVR=${EPO_DLREGTR_OVRSIISO}
#		else
#		  EST_DLRGTAA=${EPO_DLRGTAASO}
#			EST_DLDGTAA=${EPO_DLDGTAASO}
#			EST_DLREGTAR=${EPO_DLREGTARSO}
#			EST_DLREMAJGTAR=${EPO_DLREMAJGTARSO}
#			EST_DLREGTR=${EPO_DLREGTRSO}
#			EST_DLREMAJGTR=${EPO_DLREMAJGTRSO}
#			EST_DLREGTAR_OVR=${EPO_DLREGTAR_OVRSO}
#			EST_DLREGTR_OVR=${EPO_DLREGTR_OVRSO}
#		fi
#	else
#		if [ "${NORME}" = "EBS" ]
#		then
#		  EST_DLRGTAA=${EPO_DLRGTAASIICO}
#			EST_DLDGTAA=${EPO_DLDGTAASIICO}
#			EST_DLREGTAR=${EPO_DLREGTARSIICO}
#			EST_DLREMAJGTAR=${EPO_DLREMAJGTARSIICO}
#			EST_DLREGTR=${EPO_DLREGTRSIICO}
#			EST_DLREMAJGTR=${EPO_DLREMAJGTRSIICO}
#			EST_DLREGTAR_OVR=${EPO_DLREGTAR_OVRSIICO}
#			EST_DLREGTR_OVR=${EPO_DLREGTR_OVRSIICO}
#		else
#		  EST_DLRGTAA=${EPO_DLRGTAACO}
#			EST_DLDGTAA=${EPO_DLDGTAACO}
#			EST_DLREGTAR=${EPO_DLREGTARCO}
#			EST_DLREMAJGTAR=${EPO_DLREMAJGTARCO}
#			EST_DLREGTR=${EPO_DLREGTRCO}
#			EST_DLREMAJGTR=${EPO_DLREMAJGTRCO}
#			EST_DLREGTAR_OVR=${EPO_DLREGTAR_OVRCO}
#			EST_DLREGTR_OVR=${EPO_DLREGTR_OVRCO}
#		fi
#	fi
#	if [ "${NORME}" = "IFRS" ]
#	then
#		#touch ${EST_DLDGTAA}
#		EST_DLDGTAA="${DFILP}/empty.dat"
#	fi
#fi

## TU
##EST_FPLATXCUMALL=/scor/home/u006596/martin/perm/M_ESID0560_FPLATXCUMALL_POS_20210331.dat

if [ ! -f ${EST_DLREGTR_OVR} ]
then
	touch ${EST_DLREGTR_OVR}
fi

if [ ! -f ${EST_DLREGTAR_OVR} ]
then
	touch ${EST_DLREGTAR_OVR}
fi



ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> IDF_CT...................: ${IDF_CT}"
ECHO_LOG "#===> TYPEINV..................: ${TYPEINV}"
ECHO_LOG "#===> NORME....................: ${NORME}"
ECHO_LOG "#===> BALSHTYEA_NF.............: ${BALSHTYEA_NF}"
ECHO_LOG "#===> CLODAT_D.................: ${CLODAT_D}"
ECHO_LOG "#===> BOUCLE...................: ${BOUCLE}"
ECHO_LOG "#===> EST_FDETTRS..............: ${EST_FDETTRS}"
ECHO_LOG "#===> EST_FRETTRF..............: ${EST_FRETTRF}"
ECHO_LOG "#===> EST_FCES.................: ${EST_FCES}"
ECHO_LOG "#===> EST_FCES_ESFD5040........: ${EST_FCES_ESFD5040}"
ECHO_LOG "#===> EST_FPLC.................: ${EST_FPLC}"
ECHO_LOG "#===> EST_FCURCVSNI............: ${EST_FCURCVSNI}"
ECHO_LOG "#===> EST_FCURQUOT.............: ${EST_FCURQUOT}"
ECHO_LOG "#===> EST_FCURCVSN.............: ${EST_FCURCVSN}"
ECHO_LOG "#===> EST_FPLACEMT0............: ${EST_FPLACEMT0}"
ECHO_LOG "#===> EST_DLRGTAA..............: ${EST_DLRGTAA}"
ECHO_LOG "#===> EST_DLDGTAA..............: ${EST_DLDGTAA}"
ECHO_LOG "#===> EST_DLREGTAR.............: ${EST_DLREGTAR}"
ECHO_LOG "#===> EST_DLREMAJGTAR..........: ${EST_DLREMAJGTAR}"
ECHO_LOG "#===> EST_DLREGTR..............: ${EST_DLREGTR}"
ECHO_LOG "#===> EST_DLREMAJGTR...........: ${EST_DLREMAJGTR}"
ECHO_LOG "#===> EST_DLREGTAR_OVR.........: ${EST_DLREGTAR_OVR}"
ECHO_LOG "#===> EST_DLREGTR_OVR..........: ${EST_DLREGTR_OVR}"
ECHO_LOG "#==> EST_FPLATXCUMALL .........: $EST_FPLATXCUMALL                 "
ECHO_LOG "#==> EST_IRDPERICASE ..........: $EST_IRDPERICASE                 "
ECHO_LOG "#==> EST_IRDVPERICASE .........: $EST_IRDVPERICASE                " 
ECHO_LOG "#==> ESF_FLORETFACTOR .........: $ESF_FLORETFACTOR                "
ECHO_LOG "#========================================================================="





#==== MZM/JYP spira:90406 : DLRGTAA non utis� si I17(GPL)_NDC_RPO(INI or STD) I17(GPL)_NDC_RPO(INI or STD) 
#  [34] or I17(GPL)_FUT_RPO(INI) or IDF_CT = EBS_ESFD2550
#  [45] Ajout Norme I17S

IDF_CT_PARAM=`echo ${ARG2_CHN_2}"_"${ARG2_CHN_3} `
FLAG_DLRGTAA="Y"
if [ "$NORME_CF" = "I17G" ] || [ "$NORME_CF" = "I17S" ] || [ "$NORME_CF" = "I17L" ] || [ "$NORME_CF" = "I17P" ] || [ "$NORME_CF" = "EBS" ]
then
   if [ "$IDF_CT_PARAM" = "LCC_RPO" ] || [ "$IDF_CT_PARAM" = "NDC_RPO" ] || [ "$IDF_CT_PARAM" = "FUT_RPO" ] || [ "$IDF_CT" = "EBS_ESFD2550" ]
   then
      FLAG_DLRGTAA="N"
   fi
fi

#[43]
##if [ "${FLAG_DLRGTAA}" = "Y" ]
##then
##		SORT_I2="${EST_DLRGTAA} 2000 1"
##fi
#[43]
 
NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
#[010] Ajout de la condition DISCOUNT [027] [028]  #[43]
LIBEL="Merging and sorting acceptance TL files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA} 2000 1"
SORT_I2="${EST_DLRGTAA} 2000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10: ,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD3_CF 6:3 -  6:6,
        ACY_NF 14:1 - 14: ,
        SCOSTRMTH_NF 15:1 - 15: ,
        SCOENDMTH_NF 16:1 - 16:,
        CUR_CF 18:1 - 18:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CUR_CF
/CONDITION DISCOUNT ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" AND TRNCOD3_CF != "1008" )
/OUTFILE ${SORT_O}
/INCLUDE DISCOUNT
exit
EOF
SORT

##[52]if [ "$IDF_CT" = "I17G_LCC_RPO_INI" ]  || [ "$IDF_CT" = "I17S_LCC_RPO_INI" ] || [ "$IDF_CT" = "I17P_LCC_RPO_INI" ] || [ "$IDF_CT" = "I17L_LCC_RPO_INI" ]  
##then

   if [ "$IDF_CT_PARAM" = "LCC_RPO" ] 
   then


###[50]

###[48]
##NSTEP=${NJOB}_06
### Join and sort EST_FCES ESCJ0660 and ESFD5040 files)
##LIBEL="MERGE FILES"
##LIBEL="MERGE FCES UNIQUE...."
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_FCES_ESFD5040} 2000 1"
##SORT_I2="${EST_FCES} 2000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat 2000 1" 
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS ALL_F1    	            1:1 - 25: 
##/KEYS   ALL_F1
##/CONDITION NODUPLICATEKEY (ALL_F1 != "" )
##/SUM 
##/INCLUDE NODUPLICATEKEY
##exit
##EOF
##SORT 

NSTEP=${NJOB}_06A
#-----------------------------------------------------------------------------
LIBEL="get RETRO/ACC CSUOE of  ESFD5040_FCES_EBS not in ESFD5040_FCES_INI "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCES} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_EST_FCES_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
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
	CES_CESACCSTA_N     11:1 	- 11:,
	CES_CESACCEND_N     12:1 	- 12:,	
	CES_CESSH_R    			13:1 	- 13:,
  CES_FILLER_1_25   	1:1 	- 25:,  
 	CTR_NF 			1:1 	- 1:,
	END_NT			2:1 	- 2:,
	SEC_NF 			3:1 	- 3:,
	UWY_NF 			4:1 	- 4:,
	UW_NT 			5:1 	- 5:,
	RETCTR_NF   6:1 	- 6:,
	RETEND_NT   7:1 	- 7:,
	RETSEC_NF  	8:1 	- 8:,
	RTY_NF   		9:1 	- 9:,
	RETUW_NT    10:1 	- 10:,	
	CESACCSTA_N     11:1 	- 11:,
	CESACCEND_N     12:1 	- 12:,	
	CESSH_R    			13:1 	- 13:,
  FILLER_1_25   	1:1 	- 25:  		 
/joinkeys
	CES_RETCTR_NF,    
	CES_RETEND_NT,    
	CES_RETSEC_NF,    
	CES_RTY_NF,    
	CES_RETUW_NT,
	CES_CTR_NF,    
	CES_END_NT,    
	CES_SEC_NF,    
	CES_UWY_NF,    
	CES_UW_NT					
/INFILE ${EST_FCES_ESFD5040} 2000 1 "~"
/joinkeys
	RETCTR_NF,    
	RETEND_NT,    
	RETSEC_NF,    
	RTY_NF,    
	RETUW_NT,
	CTR_NF,    
	END_NT,    
	SEC_NF,    
	UWY_NF,    
	UW_NT				
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:CES_FILLER_1_25
exit
EOF
SORT




NSTEP=${NJOB}_06
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT ESFD5040_FCES INI And ESFD5040_FCES_EBS "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCES_ESFD5040} 2000 1"
SORT_I2="${DFILT}/${NJOB}_06A_${IB}_SORT_EST_FCES_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
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
	CES_CESACCSTA_N     11:1 	- 11:,
	CES_CESACCEND_N     12:1 	- 12:,	
	CES_CESSH_R    			13:1 	- 13:,
  CES_FILLER_1_25   	1:1 	- 25:
/KEYS CES_FILLER_1_25
/OUTFILE ${SORT_O}
exit
EOF
SORT

## [50] 


NSTEP=${NJOB}_07
# EST_FCESSION0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCESSION0 ==> CES dat ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_06_${IB}_SORT_CES_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT  5:1 - 5:,
        ALL_DATA 1:1 - 25:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/OUTFILE ${SORT_O}
/REFORMAT ALL_DATA
exit
EOF
SORT


else

NSTEP=${NJOB}_07
# EST_FCESSION0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCESSION0 ==> CES dat ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCES} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: ,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        LOB_CF 21:1 - 21:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

fi

#if [ "${CONTEXT_CT}" = "INI" ] # Closing at Inception
#then
#	PARAM_DATE=$PARM_ICLODAT_D
#else
#	PARAM_DATE=$PARM_CLODAT_D
#fi


# [24] Filter PERICASE AT INI assumed contract inception date > closing date and not dummy contract (portfolio origin=248)
# [41] [51]/CONDITION  LC_ASSUME (CTRINC_D > "${CLODAT_D}" ) AND (PORTFOLIO != "248") AND ("${CONTEXT_CT}" = "INI")
NSTEP=${NJOB}_08
#-----------------------------------------------------------------------------
LIBEL="Sort of IADVPERICASE + No Cession of Assume Initial Components"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       3:1 -  3:,
        END_NT       4:1 -  4:EN,
        SEC_NF       5:1 -  5:EN,
        UWY_NF       6:1 -  6:,
        UW_NT        7:1 -  7:EN, 
        CED_NF       12:1 - 12:,     
        CTRINC_D     19:1 - 19:, 
        CTRRET_B   	 20:1 - 20:,         
				PORTFOLIO    119:1 - 119:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION  LC_ASSUME  ( CTRRET_B = "0") AND (CTRINC_D > "${CLODAT_D}" ) AND (PORTFOLIO != "248") AND ("${CONTEXT_CT}" = "INI") AND ("$IDF_CT_PARAM" != "LCC_RPO")
/OMIT LC_ASSUME
exit
EOF
SORT

#[41] Deb Modif

#[45]

if [ "$IDF_CT" = "I17G_NDC_RPO_INI" ]  || [ "$IDF_CT" = "I17S_NDC_RPO_INI" ] || [ "$IDF_CT" = "I17P_NDC_RPO_INI" ] || [ "$IDF_CT" = "I17L_NDC_RPO_INI" ] || 
   [ "$IDF_CT" = "I17G_FUT_RPO_INI" ]  || [ "$IDF_CT" = "I17S_FUT_RPO_INI" ] || [ "$IDF_CT" = "I17P_FUT_RPO_INI" ] || [ "$IDF_CT" = "I17L_FUT_RPO_INI" ]
then

NSTEP=${NJOB}_09
# Join and sort -> PERICASE (step 8) and GTAA (step 5)
LIBEL="MERGE FILES"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF_1 8:1 - 8:,
        END_NT_1 9:1 - 9:,
        SEC_NF_1 10:1 - 10:,
        UWY_NF_1 11:1 - 11:,
        UW_NT_1 12:1 - 12:,
        ALL_DATA 1:1 - 80:,
        CTR_NF_2       3:1 -  3:,
        END_NT_2       4:1 -  4:,
        SEC_NF_2       5:1 -  5:,
        UWY_NF_2       6:1 -  6:,
        UW_NT_2        7:1 -  7:
/JOINKEYS CTR_NF_1,
        	END_NT_1,
        	SEC_NF_1,
        	UWY_NF_1,
        	UW_NT_1
/INFILE ${DFILT}/${NJOB}_08_${IB}_SORT_IADVPERICASE.dat 2000 1 "~"
/JOINKEYS CTR_NF_2,
        	END_NT_2,
        	SEC_NF_2,
        	UWY_NF_2,
        	UW_NT_2
/JOIN UNPAIRED RIGHTSIDE
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_DATA
exit
EOF
SORT

## On reecrit le fichier fusionn� dans le fichier Initial

ECHO_LOG "#==> AVANT 05_SORT_GTAA_O.dat .........: ${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat "
  

EXECKSH "cp ${DFILT}/${NJOB}_09_${IB}_SORT_GTAA_O.dat  ${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat"


ECHO_LOG "#==> APRES 05_SORT_GTAA_O.dat .........: ${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat "

fi

#[41]	Fin Modif

NSTEP=${NJOB}_10
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying cessions..."
PRG=ESTC2303
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
GTE_B 0
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat
#export ${PRG}_I2=${EST_FCES}
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_SORT_CES_O.dat
export ${PRG}_I3=${EST_FDETTRS}
export ${PRG}_I4=${EST_FTRANSCODE}
#export ${PRG}_I5=${EST_IADVPERICASE}
export ${PRG}_I5=${DFILT}/${NJOB}_08_${IB}_SORT_IADVPERICASE.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG



### [37] DEBApplying LOFACTOR AFTER CESSION


if [ "${VNORME}" != "I4I" -a "${VNORME}" != "" ]
then

# TRIE du fichier LOFACTOR sur RETCTR, RETENT, RETSEC, RTY, RETUW 

NSTEP=${NJOB}_10I
# FLORETFACTOR 
#-----------------------------------------------------------------------------
LIBEL="SORT OF FLORETFACTOR BY RETCTR,RETENT, RETSEC, RTY, RETUW ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLORETFACTOR.dat 2000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 	CTR_NF 				  		    1:1 - 1:,
					END_NT 				          2:1 - 2:,
					SEC_NF 				          3:1 - 3:,
					UWY_NF 				          4:1 - 4:,
					UW_NT 					        5:1 - 5:,
					RETCTR_NF 			   			6:1 - 6:,
					RETEND_NT 			        7:1 - 7:,
					RETSEC_NF 			        8:1 - 8:,
					RETRTY_NF 				      9:1 - 9:,
					RETUW_NT 			          10:1 - 10:,
					LOFACTOR  			        30:1 - 30: EN 15/3
/KEYS 		RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT,
          CTR_NF, 
					END_NT, 
					SEC_NF, 
					UWY_NF,
      LOFACTOR
exit
EOF
SORT



NSTEP=${NJOB}_10A
# Sort ${DFILT}/${NJOB}_10_${IB}_ESTC2303_GTAR100_O.dat
#-----------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, TO Join To LOFACTOR..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTC2303_GTAR100_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:       	
/KEYS 		RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT,
          CTR_NF, 
					END_NT, 
					SEC_NF, 
					UWY_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT
#


NSTEP=${NJOB}_10B
# Join and sort of  ${DFILT}/${NJOB}_10_${IB}_ESTC2303_GTAR100_O.dat File and FLORETFACTOR by RETCTR,RETENT, RETSEC, RTY, RETUW 
#------------------------------------------------------------------------------
LIBEL="Current GTAR100_O.dat File Sort, Join and Fusion With ESF_FLORETFACTOR ..."
SORT_WDIR=${SORTWORK}
SORT_I="${DFILT}/${NJOB}_10A_${IB}_SORT_GTAR100_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
					CTR_NF_F2						    1:1 -  1:,
        	END_NT_F2        		    2:1 -  2:,
					SEC_NF_F2 			  	    3:1 -  3:,
					UWY_NF_F2        	      4:1 -  4:,
					RETCTR_NF_F2				    6:1 -  6:,
        	RETEND_NT_F2            7:1 -  7:,
					RETSEC_NF_F2 			      8:1 -  8:,
					RTY_NF_F2        	      9:1 -  9:,
					RETUW_NT_F2             10:1 -  10:,							
        	LOFACTOR_F2 		        30:1 - 30: EN 15/3,
					ALL_F1    			        1:1 -  72:,        	
					ALL_F2    			        1:1 - 30:				
/JOINKEYS RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT,
          CTR_NF, 
					END_NT, 
					SEC_NF, 
					UWY_NF	
/INFILE ${DFILT}/${NJOB}_10I_${IB}_SORT_FLORETFACTOR.dat 2000 1 "~"
/JOINKEYS RETCTR_NF_F2,
					RETEND_NT_F2,
					RETSEC_NF_F2,
          RTY_NF_F2,
          RETUW_NT_F2,
					CTR_NF_F2,	
      		END_NT_F2, 
					SEC_NF_F2, 
					UWY_NF_F2           
/JOIN UNPAIRED LEFTSIDE                 
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: LOFACTOR_F2        
exit
EOF
SORT   



NSTEP=${NJOB}_10C
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="SORT GTAR UNIQUE TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10B_${IB}_SORT_GTAR100_FACTOR_O.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    	            1:1 - 73:       
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (ALL_F1 != "" )
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT



NSTEP=${NJOB}_10D
# SORT UNIQUE of GTAR100_FACTOR 
#------------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, Join and Fusion UNIQUE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10C_${IB}_SORT_GTAR100_FACTOR_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_FACTOR_O.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
    GT_TRNCOD_CF	        6	:1 - 	6	:,
    GT_DBLTRNCOD_CF	        7	:1 - 	7	:,
    GT_ALL_COLS             1:1 - 73:,
    TRNCOD_CF                6:1 -  6:,
    FBOPRSLNK_ACMTRSL2_NT     4:1 -  4:,
    FBOPRSLNK_ACMTRSL3_NT     5:1 -  5:,
    FBOPRSLNK_DETTRS_CF       9:1 -  9:,
    FBOPRSLNK_TRNTYP_CT      14:1 - 14:
/joinkeys
       TRNCOD_CF
/INFILE ${EST_FBOPRSLNK_TXT} 1000 1 "~"
/joinkeys
       FBOPRSLNK_DETTRS_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}  overwrite
/REFORMAT
         leftside:GT_ALL_COLS
        ,rightside:FBOPRSLNK_ACMTRSL3_NT

exit
EOF
SORT



NSTEP=${NJOB}_10E
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying Lofacactor to ${DFILT}/${NJOB}_10_${IB}_ESTC2303_GTAR100_O.dat..."
PRG=ESTC2308A
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10D_${IB}_SORT_GTAR100_FACTOR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat
EXECPRG

fi 

### [37 Fin ]Applying LOFACTOR AFTER CESSION

gzip -c ${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat > ${DFILT}/${NJOB}_05_${IB}_ENTREE_ESTC2303_SORT_GTAA_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O.dat > ${DFILT}/${NJOB}_10_${IB}_SORTIE_ESTC2303_SORT_GTAA_O.dat.gz
### [38]
gzip -c ${DFILT}/${NJOB}_09_${IB}_SORT_GTAA_O.dat > ${DFILT}/${NJOB}_09_${IB}_ENTREE_ESTC2303_SORT_GTAA_O.dat.gz

NSTEP=${NJOB}_15
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat

NSTEP=${NJOB}_20
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting 100% retro TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${VNORME}" != "I4I" -a "${VNORME}" != "" ]
then
SORT_I="${DFILT}/${NJOB}_10E_${IB}_ESTC2308A_GTAR100_O.dat 500 1"
else
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTC2303_GTAR100_O.dat 500 1"
fi
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9: ,
        SEC_NF 10:1 - 10: ,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12: ,
        OCCYEA_NF 13:1 - 13: ,
        ACY_NF 14:1 - 14: ,
        SCOSTRMTH_NF 15:1 - 15: ,
        SCOENDMTH_NF 16:1 - 16: ,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25: ,
        RETSEC_NF 26:1 - 26: ,
        RETRTY_NF 27:1 - 27: ,
        RETUW_NT 28:1 - 28: ,
        RETOCCYEA_NF 29:1 - 29: ,
        RETACY_NF 30:1 - 30: ,
        RETSCOSTRMTH_NF 31:1 - 31: ,
        RETSCOENDMTH_NF 32:1 - 32:,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:,
        FILLER_1  1:1 - 71:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      CUR_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT ,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      TRN_NT,
      RETROAUTO_B
/REFORMAT FILLER_1
exit
EOF
SORT

#[023]
NSTEP=${NJOB}_22
# temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_10_${IB}_ESTC2303_GTAR100_O.dat  
  
# #023] Tri du fichier FPLC
NSTEP=${NJOB}_25
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sorting FPLC TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLC} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FPLC_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF        3:1 - 3:,
        RETEND_NT        4:1 - 4:,
        RETSEC_NF        5:1 - 5:,
        RTY_NF           6:1 - 6:,
        RETUW_NT         7:1 - 7:,
        PLC_NT           8:1 - 8:EN 15/3
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      PLC_NT
exit
EOF
SORT


#[25] Ajout Grouping 2051 (2A120012)
NSTEP=${NJOB}_27
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort AR TL With only Future Premium file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_GTAR100_O.dat 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat 500 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      TRNCOD_CF,
      CUR_CF,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT ,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      TRN_NT,
      RETROAUTO_B
/CONDITION FUTRETROPRM (TRNCOD_CF != "2A100022" AND TRNCOD_CF !="2A100012" AND TRNCOD_CF != "2A120012")
/OUTFILE ${SORT_O}
/OMIT FUTRETROPRM
exit
EOF
SORT

# [20] JOINTURE WITH FPLC BEFORE COMPUTE THE FUTURE
# [23] ${DFILT}/${NJOB}_25_${IB}_SORT_FPLC_O.dat 500 1 "~"
NSTEP=${NJOB}_28
# Join and sort of  GTA File and FPLC by RETCTR,RETENT, RETSEC, RTY, RETUW
#------------------------------------------------------------------------------
LIBEL="Current GTA File Sort, Join and Fusion With FPLC ..."
SORT_WDIR=${SORTWORK}
SORT_I="${DFILT}/${NJOB}_27_${IB}_SORT_GTAR100_O.dat 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat 500 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 							1:1 - 1:,
        ESB_CF 							2:1 - 2:,
        BALSHEY_NF 					3:1 - 3:,
        BALSHRMTH_NF 				4:1 - 4:,
        BALSHRDAY_NF 				5:1 - 5:,
        TRNCOD_CF 					6:1 - 6:,
        DBLTRNCOD_CF 				7:1 - 7:,
        CTR_NF 							8:1 - 8:,
        END_NT 							9:1 - 9:,
        SEC_NF 							10:1 - 10:,
        UWY_NF 							11:1 - 11:,
        UW_NT 							12:1 - 12:,
        OCCYEA_NF 					13:1 - 13:,
        ACY_NF 							14:1 - 14:,
        SCOSTRMTH_NF 				15:1 - 15:,
        SCOENDMTH_NF 				16:1 - 16:,
        CLM_NF 							17:1 - 17:,
        CUR_CF 							18:1 - 18:,
        AMT_M 							19:1 - 19:EN 15/3,
        CED_NF 							20:1 - 20:,
        BRK_NF 							21:1 - 21:,
        PAY_NF 							22:1 - 22:,
        KEY_NF 							23:1 - 23:,
        RETCTR_NF 					24:1 - 24:,
        RETEND_NT 					25:1 - 25:,
        RETSEC_NF 					26:1 - 26:,
        RTY_NF 							27:1 - 27:,
        RETUW_NT 						28:1 - 28:,
        RETOCCYEA_NF 				29:1 - 29:,
        RETACY_NF 					30:1 - 30:,
        RETSCOSTRMTH_NF 		31:1 - 31:,
        RETSCOENDMTH_NF 		32:1 - 32:,
        RCL_NF 							33:1 - 33:,
        RETCUR_CF 					34:1 - 34:,
        RETAMT_M 						35:1 - 35:EN 15/3,
        PLC_NT 							36:1 - 36:EN 15/3,
        RTO_NF 							37:1 - 37 :,
        INT_NF 							38:1 - 38:,
        RETPAY_NF 					39:1 - 39:,
        RETKEY_CF 					40:1 - 40:,
        RETINTAMT_M 				41:1 - 41:EN 15/3,
        FILLER_14_COLS 			42:1 - 55:,
        TRN_NT 							56:1 - 56:,
        FILLER_1_COLS 			57:1 - 57:,
        RETROAUTO_B 				58:1 - 58:,
        FILLER_13_COLS 			59:1 - 71:,
        RETCTR_NF_F2 			  3:1 -  3:,
        RETEND_NT_F2        4:1 -  4:,
				RETSEC_NF_F2 			  5:1 -  5:,
				RTY_NF_F2        	  6:1 -  6:,
				RETUW_NT_F2         7:1 -  7:,
				PLC_NT_F2 		      8:1 -  8:EN 15/3,
				RETSIGSHA_R_F2      9:1 -  9:,
				RTO_NF_F2           10:1 - 10:,
				ALL_F2    			    1:1 - 38:
/JOINKEYS RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RTY_NF,
          RETUW_NT
/INFILE ${DFILT}/${NJOB}_25_${IB}_SORT_FPLC_O.dat 2000 1 "~" 
/JOINKEYS RETCTR_NF_F2,
					RETEND_NT_F2,
					RETSEC_NF_F2,
          RTY_NF_F2,
          RETUW_NT_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT  leftside: SSD_CF
          ,leftside: ESB_CF
          ,leftside: BALSHEY_NF
          ,leftside: BALSHRMTH_NF
          ,leftside: BALSHRDAY_NF
          ,leftside: TRNCOD_CF
          ,leftside: DBLTRNCOD_CF
          ,leftside: CTR_NF
          ,leftside: END_NT
          ,leftside: SEC_NF
          ,leftside: UWY_NF
          ,leftside: UW_NT
          ,leftside: OCCYEA_NF
          ,leftside: ACY_NF
          ,leftside: SCOSTRMTH_NF
          ,leftside: SCOENDMTH_NF
          ,leftside: CLM_NF
          ,leftside: CUR_CF
          ,leftside: AMT_M
          ,leftside: CED_NF
          ,leftside: BRK_NF
          ,leftside: PAY_NF
          ,leftside: KEY_NF
          ,leftside: RETCTR_NF
          ,leftside: RETEND_NT
          ,leftside: RETSEC_NF
          ,leftside: RTY_NF
          ,leftside: RETUW_NT
          ,leftside: RETOCCYEA_NF
          ,leftside: RETACY_NF
          ,leftside: RETSCOSTRMTH_NF
          ,leftside: RETSCOENDMTH_NF
          ,leftside: RCL_NF
          ,leftside: RETCUR_CF
          ,leftside: RETAMT_M
          ,RIGHTSIDE: PLC_NT_F2
          ,RIGHTSIDE: RTO_NF_F2
          ,leftside: RETINTAMT_M
          ,leftside: FILLER_14_COLS
          ,leftside: TRN_NT
          ,leftside: FILLER_1_COLS
          ,leftside: RETROAUTO_B
          ,leftside: FILLER_13_COLS
exit
EOF
SORT


# NO DUPLICATE KEY # [23] Tri sur PLC en entier


NSTEP=${NJOB}_29
# SORT UNIQUE of GTAR100 file and FPLACEMENT by ALL_COLUMN
#------------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_28_${IB}_SORT_GTAR100_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O.dat OVERWRITE 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT_F2               36:1 - 36: EN 15/3,
					RETINTAMT_M 		        38:1 - 38: EN 15/3,
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT,
      		PLC_NT_F2,
      		RETCUR_CF,
      		TRNCOD_CF,
      		RETOCCYEA_NF,
      		RETACY_NF,
      		RETSCOSTRMTH_NF,
      		RETSCOENDMTH_NF,
      		CTR_NF,
      		END_NT,
      		SEC_NF,
      		UWY_NF,
      		UW_NT ,
      		OCCYEA_NF,
      		ACY_NF,
      		SCOSTRMTH_NF,
      		SCOENDMTH_NF,
      		TRN_NT,
      		RETROAUTO_B
/SUM
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[23] Ajout du Tri du Fichier FPLC
NSTEP=${NJOB}_30
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying placements..."
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTR_B 1
CURQUOT_YEAR ${BALSHTYEA_NF}
GTE_B 0
PRS_CF 50
OVERRIDE 1
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_GTAR100_O.dat
#export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I2=${DFILT}/${NJOB}_25_${IB}_SORT_FPLC_O.dat                  
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR100_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ100_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRMAJ_O4.dat
EXECPRG


#[19] [20] Ajout de l'option  2 : pour calcul des RETRO OVERRIDES COMMISSSION
#[22] GTAR_1 Accep / Override
#[23] Ajout du Tri du Fichier FPLC
NSTEP=${NJOB}_31
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Compute RETRO OVERRIDE COMMISSIONS."
PRG=ESTC2304
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
GTR_B 1
CURQUOT_YEAR ${BALSHTYEA_NF}
GTE_B 0
PRS_CF 50
OVERRIDE 2
RETROCOM_FLG Y
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_29_${IB}_SORT_GTAR100_O.dat
#export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I2=${DFILT}/${NJOB}_25_${IB}_SORT_FPLC_O.dat
export ${PRG}_I3=${EST_FCURCVSNI}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FCURCVSN}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTARMAJ100_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRMAJ_O4.dat
EXECPRG



#[19]
#[31] if [ "${NORME}" = "EBS" -a "${TYPEINV}" != "INV" ] 



# [35] RETINTAMT_M = RETAMT_M  ## (Uniquement S il existe un PLC_NT ==> Spira 102172 )

# [36] if [ "${TYPEINV}" != "INV" ]

if [ "${VNORME}" != "I4I" -a "${VNORME}" != "" ]
then
#[19] Filter only on TRNCOD 2A121212 #[19] #[19] #[44] Compute RETRO OVERRIDE GTR
NSTEP=${NJOB}_32
#-----------------------------------------------------------------------------
LIBEL="Filter only on TRNCOD 2A121212 FUTURE OVERRIDE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_31_${IB}_ESTC2304_GTR_O3.dat 500 1"
SORT_O="${EST_DLREGTR_OVR} OVERWRITE"	
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        FILLER_4_COLS 37:1 - 40:, 
        RETINTAMT_M 41:1 - 41:EN 15/3,
        FILLER_14_COLS 42:1 - 55:,
        TRN_NT 56:1 - 56:,
        FILLER_1_COLS 57:1 - 57:,
        RETROAUTO_B 58:1 - 58:,
        FILLER_13_COLS 59:1 - 71:                 
/KEYS   SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
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
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRN_NT,
        RETROAUTO_B                      
/SUMMARIZE TOTAL AMT_M,
           TOTAL RETAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
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
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_MC,
          PLC_NT,
          FILLER_4_COLS,
          RETINTAMT_M,
          FILLER_14_COLS,
          TRN_NT,
          FILLER_1_COLS,
          RETROAUTO_B,
          FILLER_13_COLS
exit
EOF
SORT

#[19] Filter only on TRNCOD 2A121212 #[19] #[44] Compute RETRO OVERRIDE GTR
NSTEP=${NJOB}_32A
#-----------------------------------------------------------------------------
LIBEL="Filter only on TRNCOD 2A121212 FUTURE OVERRIDE ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_31_${IB}_ESTC2304_GTAR_O1.dat 500 1"
SORT_O="${EST_DLREGTAR_OVR} OVERWRITE"	
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        FILLER_4_COLS 37:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        FILLER_14_COLS 42:1 - 55:,
        TRN_NT 56:1 - 56:,
        FILLER_1_COLS 57:1 - 57:,
        RETROAUTO_B 58:1 - 58:,
        FILLER_13_COLS 59:1 - 71:                 
/KEYS   
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETCUR_CF,
        PLC_NT,
        TRN_NT,
        RETROAUTO_B,
        TRNCOD_CF                              
/SUMMARIZE TOTAL AMT_M,
           TOTAL RETAMT_M,
           TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
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
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_MC,
          PLC_NT,
          FILLER_4_COLS,
          RETINTAMT_MC,
          FILLER_14_COLS,
          TRN_NT,
          FILLER_1_COLS,
          RETROAUTO_B,
          FILLER_13_COLS
exit
EOF
SORT


fi

NSTEP=${NJOB}_33
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTR_O3.dat  500 1"
# SORT_I2=${DFILT}/${NJOB}_39C_${IB}_ESTC2131_DLREGTR_O.dat
SORT_O="${EST_DLREGTR} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS   SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
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
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_36
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing AR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTARMAJ100_O2.dat 500 1"
SORT_O="${EST_DLREMAJGTAR}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS   SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
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
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT



# ########################################
# [15] SUppression de la ventillation par placement du DLREGTAR d�ja ventill� plus haut
#     ESTC2131 : programme de ventillation par placement dans les cha�nes LIFE
# ########################################
# NSTEP=${NJOB}_39A
# # Sort of placement file
# #------------------------------------------------------------------------------
# LIBEL="Sort of placement file"
# SORT_WDIR=${SORTWORK}
# SORT_CMD=`CFTMP`
# SORT_I="${EST_FPLACEMT0} 2000 1"
# SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PLACEMT_O.dat 2000 1"
# INPUT_TEXT ${SORT_CMD} <<EOF
# /FIELDS RETCTR_NF    3:1 -  3:,
#         RETEND_NT    4:1 -  4:,
#        RETSEC_NF    5:1 -  5:,
#         RTY_NF       6:1 -  6:,
#         RETUW_NT     7:1 -  7:,
#         LOB_CF      18:1 - 18:
# /KEYS RETCTR_NF,
#       RETEND_NT,
#       RETSEC_NF,
#       RTY_NF,
#       RETUW_NT
# /CONDITION LOB_25_OU_31 ((LOB_CF = "30") OR (LOB_CF = "31"))
# /OMIT LOB_25_OU_31
# exit
# EOF
# SORT

# NSTEP=${NJOB}_39B
# # Begin Merge and Sort
# #-----------------------------------------------------------------------------
# LIBEL="Include EBSGTA records"
# SORT_WDIR=${SORTWORK}
# SORT_CMD=`CFTMP`
# SORT_I="${EST_DLREGTAR}  2000 1"
# SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTAR_O.dat 2000 1"
# INPUT_TEXT ${SORT_CMD} <<EOF
# /FIELDS ORICOD_LS    57:1 - 57:
# /CONDITION INCLUDEEBS  ORICOD_LS = 'EBSGTA'
# /OUTFILE ${SORT_O}
# /INCLUDE INCLUDEEBS
# exit
# EOF
# SORT

# NSTEP=${NJOB}_39C
# # Selection of the last contract record
# #------------------------------------------------------------------------------
# LIBEL="Selection of the last contract record"
# PRG=ESTC2131
# export ${PRG}_I1=${DFILT}/${NJOB}_39A_${IB}_SORT_PLACEMT_O.dat
# export ${PRG}_I2=${DFILT}/${NJOB}_39B_${IB}_SORT_DLREGTAR_O.dat
# export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREGTR_O.dat
# EXECPRG
# ###############
#
# ###############



##[19]
NSTEP=${NJOB}_42
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing GTAR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTAR100_O1.dat 500 1"
SORT_O="${EST_DLREGTAR} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS   SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
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
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

### MZM



        
###        

##[32] Deb Ajout du Placement au DLGTAR pour les IDF_CT NDIC_INI et EBS_ESFD2550

#if [ "${IDF_CT}"="I17G_NDC_RPO_STD" -o "${IDF_CT}"="I17G_NDC_RPO_INI" -o "${IDF_CT}"="I17P_NDC_RPO_STD" -o "${IDF_CT}"="I17P_NDC_RPO_INI" -o "${IDF_CT}"="I17L_NDC_RPO_STD" 
#then



##[46]

if [ "${IDF_CT}"  = "I17G_NDC_RPO_INI" ] ||  [ "${IDF_CT}"  = "I17S_NDC_RPO_INI" ] || [ "${IDF_CT}"  = "I17L_NDC_RPO_INI" ] || [ "${IDF_CT}" = "I17P_NDC_RPO_INI" ] ||
   [ "${IDF_CT}" = "EBS_ESFD2550" ] || [ "${IDF_CT}" = "I17G_ESFD2550" ] ||
   [ "${IDF_CT}"  = "I17G_FUT_RPO_INI" ] ||  [ "${IDF_CT}"  = "I17S_FUT_RPO_INI" ] || [ "${IDF_CT}"  = "I17L_FUT_RPO_INI" ] || [ "${IDF_CT}" = "I17P_FUT_RPO_INI" ] 
then



NSTEP=${NJOB}_45
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLATXCUMALL}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUMALL.dat
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


#SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTAR100_O1.dat 500 1"
#SORT_O="${EST_DLREGTAR} OVERWRITE"


##[19]
NSTEP=${NJOB}_48
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing GTAR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTAR100_O1.dat 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR100_O1.dat 500 1"
##SORT_O="${EST_DLREGTAR} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:EN,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:EN,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        PLC_NT,
        RETEND_NT,
        RETUW_NT,
        RETCUR_CF,
        TRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_50
# Affectation par placement
#-----------------------------------------------------------------------------
LIBEL=" AGREGATES retro Affectation MVT par placement"
PRG=ESTC1052
export ${PRG}_I1=${DFILT}/${NJOB}_45_${IB}_FPLATXCUMALL.dat
#export ${PRG}_I2="${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTAR100_O1.dat"
export ${PRG}_I2="${DFILT}/${NJOB}_48_${IB}_SORT_GTAR100_O1.dat"
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREGTAR_O.dat
#export ${PRG}_O1="${EST_DLREGTAR} " 
EXECPRG


NSTEP=${NJOB}_55
#LIBEL="Copy De la Fusion --> DLREGTAR et DLREGTR..."
	EXECKSH "cp ${DFILT}/${NJOB}_50_${IB}_ESTC1052_DLREGTAR_O.dat  ${EST_DLREGTAR}"

fi 

## [32] fin 

NSTEP=${NJOB}_60
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing raised commission RR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC2304_GTRMAJ_O4.dat 500 1"
SORT_O="${EST_DLREMAJGTR} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9: ,
        SEC_NF 10:1 - 10: ,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12: ,
        OCCYEA_NF 13:1 - 13: ,
        ACY_NF 14:1 - 14: ,
        SCOSTRMTH_NF 15:1 - 15: ,
        SCOENDMTH_NF 16:1 - 16: ,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29: ,
        RETACY_NF 30:1 - 30: ,
        RETSCOSTRMTH_NF 31:1 - 31: ,
        RETSCOENDMTH_NF 32:1 - 32: ,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        FILLER_14_COLS 42:1 - 55:,
        TRN_NT 56:1 - 56:,
        FILLER_1_COLS 57:1 - 57:,
        RETROAUTO_B 58:1 - 58:,
        FILLER_13_COLS 59:1 - 71:
/KEYS TRNCOD_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETOCCYEA_NF,
      RETACY_NF,
      RETSCOSTRMTH_NF,
      RETSCOENDMTH_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      TRN_NT,
      RETROAUTO_B
/SUMMARIZE TOTAL RETAMT_M,
           TOTAL RETINTAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
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
          CLM_NF,
          CUR_CF,
          AMT_M,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
          FILLER_14_COLS,
          TRN_NT,
          FILLER_1_COLS,
          RETROAUTO_B,
          FILLER_13_COLS
exit
EOF
SORT

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_70
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
