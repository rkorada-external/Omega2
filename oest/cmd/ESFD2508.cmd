#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 MERGE DE FICHIERS
# nom du script SHELL           : ESFD2508
# revision                      : $Revision:   1.0  $
# date de creation              : 26/10/2020
# auteur                        : MZM
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Merge des fichiers issu du ESFD3780    : T_ESFD3780_I17G_CSM_ACC_STD_CSM_LC_FTECLEDA_20200930.dat
#                           et du ESFD3890 :
#-----------------------------------------------------------------------------
# historiques des modifications
#=============================================================================== 
#[01] 14/04/2021 MZM :spira:90073 : Merge des fichiers issu du ESID2210 (DCUMGTAA DAC I17) et du FICHIER ESFD2220_DLGTAA 
#[02] 12/04/2021 MZM :spira:92736 : Filtre que sur les fichiers ASSUMED en entrée de la bouclette 
#[03] 10/03/2022 MZM :spira:102507 : Filtre que sur les fichiers ESFD3780 pour determiner la Retro  NP==> Bouclette 
#[04] 26/04/2022 MZM :spira:102507 : Filtre que sur les fichiers ESFD3780 pour determiner toute la Retro Et plus de jointure sur Pericase ==> Bouclette 
#[05] 18/05/2022 MZM :spira:104058 : DAC I17 - AI TL missing ==> Bouclette 
#[06] 31/05/2022 MZM :spira:102507 : Filtre que sur les fichiers ESFD3780 : Suppression 
#[07] 12/07/2022 MZM :spira:104586 : Prise en compte / génération des AI pour CHG UNWIND et Ajout NORME I17S 
#[08] 06/11/2024 Mr JYP:Spira 111665/112295 wrong SSD/ESB for retro
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


# Job Initialisation
JOBINIT

# Get input parameters


#ICLODAT_D=$3
IDF_CT=$4
ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`


ICLODAT_3MOIS=`echo "$ICLODAT_D" | awk '{ y1 = substr($0,3,2); m1 = substr($0,5,2); j2 = substr($0,7,2); if (m1 > "03") {y2 = y1; m2 = m1-3;} else {y2 = y1-1; m2 = m1+9; } ; if (length(j2) < 2) j2 = "0" j2 ; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
ICLODAT_3MOIS_M=`echo ${ICLODAT_3MOIS} | awk '{print substr($0,5,2)}'`
ICLODAT_3MOIS_A=`echo ${ICLODAT_3MOIS} | awk '{print substr($0,1,4)}'`
ICLODAT_3MOIS_J=`echo ${ICLODAT_3MOIS} | awk '{print substr($0,7,2)}'`


# Merge des Fichiers ESF_ESFD3890_AOC et ESF_DLDGTAA3780SII

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT ....................: ${IDF_CT} "
ECHO_LOG "#========================================================================="

if [ "${IDF_CT}" = "I17G_LCC_RPO_STD" ] || [ "${IDF_CT}" = "I17S_LCC_RPO_STD" ] || [ "${IDF_CT}" = "I17L_LCC_RPO_STD" ] || [ "${IDF_CT}" = "I17P_LCC_RPO_STD" ]
then

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT ....................: ${IDF_CT} "
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}  "
ECHO_LOG "#===> PATTYP_CT..................: ${PATTYP_CT}  "
ECHO_LOG "#===> CONTEXT_CT ................: ${CONTEXT_CT} "
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> PARM_CRE_D.................: $PARM_CRE_D"
ECHO_LOG "#===> PARM_CLODAT_D..............: $PARM_CLODAT_D"
ECHO_LOG "#===> ICLODAT_D .................: $ICLODAT_D "
ECHO_LOG "#===> PARM_INVCONSO_D ...........: $PARM_INVCONSO_D"
ECHO_LOG "#===> ICLODAT_A .................: $ICLODAT_A  "
ECHO_LOG "#===> ICLODAT_M .................: $ICLODAT_M  "
ECHO_LOG "#===> ICLODAT_J .................: $ICLODAT_J  "
ECHO_LOG "#===> ICLODAT_3MOIS .............: $ICLODAT_3MOIS  "
ECHO_LOG "#===> ICLODAT_3MOIS_A ...........: $ICLODAT_3MOIS_A  "
ECHO_LOG "#===> ICLODAT_3MOIS_M ...........: $ICLODAT_3MOIS_M  "
ECHO_LOG "#===> ICLODAT_3MOIS_J ...........: $ICLODAT_3MOIS_J  "
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#==> ESF_ESFD3890_AOC .................:  $ESF_ESFD3890_AOC          "
ECHO_LOG "#==> ESF_DLDGTAA3780SII ...............:  $ESF_DLDGTAA3780SII        "
ECHO_LOG "#==> ESF_ESFD3740_AICHG_UWI ...........:  $ESF_ESFD3740_AICHG_UWI    " 
ECHO_LOG "#==> ESF_ESFD3780_CSM_RETRO ...........:  $ESF_ESFD3780_CSM_RETRO    " 
ECHO_LOG "#==> ESF_IRDPERICASE_NP ...............:  $ESF_IRDPERICASE_NP        "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#==> ESF_DLDGTAA3780_3890SII ..........:  $ESF_DLDGTAA3780_3890SII  "
ECHO_LOG "#==> EST_DLSGTR .......................:  $EST_DLSGTR  "
ECHO_LOG "#========================================================================="


if [ ! -f ${ESF_ESFD3780_CSM_RETRO} ]
then
	touch ${ESF_ESFD3780_CSM_RETRO}
fi


if [ ! -f ${ESF_ESFD3740_AICHG_UWI} ]
then
	touch ${ESF_ESFD3740_AICHG_UWI}
fi

if [ ! -f ${ESF_ESFD3890_AOC} ]
then
	touch ${ESF_ESFD3890_AOC}
fi


if [ ! -f ${ESF_DLDGTAA3780SII} ]
then
	touch ${ESF_DLDGTAA3780SII}
fi

if [ ! -f ${EST_DLSGTR} ]
then
	touch ${EST_DLSGTR}
fi


# [02] Filtre sur les contrats Assumed ==> Generer Assumed et Retro Interne	

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="AGREGATES ESF_DLDGTAA3890 ESF_DLDGTAA3780SII Merge and sort files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${ESF_ESFD3890_AOC} 1000 1" 
SORT_I2="${ESF_DLDGTAA3780SII}  1000 1" 
SORT_O="${ESF_DLDGTAA3780_3890SII} 1000 1"  
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA3780_3890SII_RETRO_O.dat 1000 1"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:8,
        TRNCOD4_CF        6:1 -  6:4,
        TRNCOD8_CF        6:8 -  6:8,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RETRTY_NF        27:1 - 27:,
        RETUW_NT         28:1 - 28:EN                     
/KEYS   				
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        ACY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RETRTY_NF,
        RETUW_NT, 
        SCOSTRMTH_NF,
        SCOENDMTH_NF              
/CONDITION ASSUMED_ONLY (TRNCOD1_CF = "1")
/OUTFILE ${SORT_O}
/INCLUDE ASSUMED_ONLY 
/OUTFILE ${SORT_O2}
/OMIT ASSUMED_ONLY     	
exit
EOF
SORT


# [06]

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="MERGE OF RETRO 3780 AND 3740 CHG_UWI AND CHG_ESTI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_ESFD3780_CSM_RETRO} 2000 1"
SORT_I2="${ESF_ESFD3740_AICHG_UWI}  2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA3780_3890SII_RETRO_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:8,
        TRNCOD4_CF        6:1 -  6:4,
        TRNCOD8_CF        6:8 -  6:8,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RETRTY_NF        27:1 - 27:,
        RETUW_NT         28:1 - 28:EN
/KEYS   RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RETRTY_NF,
        RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="Get SSD/ESB from Pericase retro $EST_IRDVPERICASE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_DLDGTAA3780_3890SII_RETRO_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA3780_3890SII_RETRO_O.dat  1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        CTR_NF          24:1 - 24:,
        END_NT          25:1 - 25:,
        SEC_NF          26:1 - 26:,
        UWY_NF          27:1 - 27:,
        UW_NT           28:1 - 28:,
        all_cols1        1:1 - 118:,
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
/INFILE ${EST_IRDVPERICASE} 1000 1 "~"
/joinkeys
        PER_CTR_NF
       ,PER_END_NT
       ,PER_SEC_NF
       ,PER_UWY_NF
       ,PER_UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols1
       ,rightside:PER_ESB_CF,PER_SSD_CF
exit
EOF
SORT



NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Replace SSD/ESB into FTECLEDR DVGTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_DLDGTAA3780_3890SII_RETRO_O.dat 1000 1 "
SORT_O="${EST_DLSGTR} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -   1:,
        ESB_CF           2:1 -   2:,
        TRNCOD1_CF       6:1 -   6:1,
        CTR_NF           8:1 -   8:,
        END_NT           9:1 -   9:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        UW_NT           12:1 -  12:,
        all_cols1        3:1 - 118:,
        PER_ESB_CF     119:1 - 119:,
        PER_SSD_CF     120:1 - 120:
/CONDITION retro (TRNCOD1_CF = "2" OR TRNCOD1_CF = "4") and PER_ESB_CF != "" and PER_SSD_CF != ""
/DERIVEDFIELD PER2_ESB_CF if retro then PER_ESB_CF else ESB_CF
/DERIVEDFIELD PER2_SSD_CF if retro then PER_SSD_CF else SSD_CF
/OUTFILE   ${SORT_O}
/REFORMAT PER2_SSD_CF, PER2_ESB_CF, all_cols1
exit
EOF
SORT






fi


# [01] Merge des Fichiers DAC IFRS17  et EST_DLDGTAA

if [ "${IDF_CT}" = "EBS_ESPD2550" ] 
then

ECHO_LOG " BEGIN JOB ESFD2508"
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT ....................: ${IDF_CT} "
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}  "
ECHO_LOG "#===> PATTYP_CT..................: ${PATTYP_CT}  "
ECHO_LOG "#===> CONTEXT_CT ................: ${CONTEXT_CT} "
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> PARM_CRE_D.................: $PARM_CRE_D"
ECHO_LOG "#===> PARM_CLODAT_D..............: $PARM_CLODAT_D"
ECHO_LOG "#===> ICLODAT_D .................: $ICLODAT_D "
ECHO_LOG "#===> PARM_INVCONSO_D ...........: $PARM_INVCONSO_D"
ECHO_LOG "#===> ICLODAT_A .................: $ICLODAT_A  "
ECHO_LOG "#===> ICLODAT_M .................: $ICLODAT_M  "
ECHO_LOG "#===> ICLODAT_J .................: $ICLODAT_J  "
ECHO_LOG "#===> ICLODAT_3MOIS .............: $ICLODAT_3MOIS  "
ECHO_LOG "#===> ICLODAT_3MOIS_A ...........: $ICLODAT_3MOIS_A  "
ECHO_LOG "#===> ICLODAT_3MOIS_M ...........: $ICLODAT_3MOIS_M  "
ECHO_LOG "#===> ICLODAT_3MOIS_J ...........: $ICLODAT_3MOIS_J  "
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#==> EST_DLCUMGTAATOT ...............:  $EST_DLCUMGTAATOT     "
ECHO_LOG "#==> EST_DLDGTAA ....................:  $EST_DLDGTAA          "
ECHO_LOG "#===>     -------- output  ----------"
ECHO_LOG "#==> EST_DLDGTAA ....................:  $EST_DLDGTAA  "

#[001] ${EST_DLCUMGTAATOT}
NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="Sort of EST_DLCUMGTAATOT file in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLCUMGTAATOT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DAC_DLCUMGTAATOT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1:,
        ESB_CF             2:1 - 2:,
        TRNCOD_CF          6:1 - 6:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:EN,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:
/KEYS 	CTR_NF,
      	END_NT,
      	SEC_NF,
      	UWY_NF,
      	UW_NT
/CONDITION DAC_IFRS17 (TRNCOD_CF = "1143060I")
/OUTFILE ${SORT_O}
/INCLUDE DAC_IFRS17      	
exit
EOF
SORT


# [01] [04] Merge des Fichiers DAC IFRS17  et EST_DLDGTAA


NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="AGREGATES DAC_IFRS17 AND  EST_DLDGTAA Merge and sort files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_DAC_DLCUMGTAATOT_O.dat 1000 1" 
SORT_I2="${EST_DLDGTAA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DACI17_DLDGTAA.dat 1000 1" 
#SORT_O="${EST_DLDGTAA} 1000 1"  
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN              
/KEYS   				
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF              
/OUTFILE ${SORT_O}
exit
EOF
SORT

EXECKSH "cp ${DFILT}/${NJOB}_70_${IB}_SORT_DACI17_DLDGTAA.dat  ${EST_DLDGTAA}"

ECHO_LOG "#==> TESTS MERGE ESFD2508 EST_DLDGTAA ....................:  $EST_DLDGTAA  "


fi



JOBEND

