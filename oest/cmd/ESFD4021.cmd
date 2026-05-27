#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 EAGREGATION PAR CSUE
# nom du script SHELL           : ESFD4021.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 13/10/2020
# auteur                        : MZM
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Impact closing (agrégation par CSUOE des mouvements indépendant de la norme)
#   Generation d un Fichier ITD et d un fichier QUATERLY
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[01] 11/01/2021 : MZM : SPIRA 91531 : MAJ MAPPING
#[02] 14/01/2021 : MZM : SPIRA 89923 : Numero PLC_NT et RTO : Ajustements
#[03] 28/01/2021 : MZM : SPIRA 89923 : LOB_CF != "30" et != "31"
#[04] 29/01/2021 : MZM : SPIRA 93608 : Agregation file - Issue with ITD calculation
#[05] 02/02/2021 : MZM : SPIRA 93580 : Align retro and assumed regarding input files : Agregation file - Assume Pericase with Segmentation data
#[06] 05/02/2021 : MZM : SPIRA 93580 : Update Field ACMAMT_M with RETAMT_M if TYP_CT = 'R' with AMT_M it TYP_CT ='A'
#[06] 29/03/2021 : MZM : SPIRA 89923 : Exclusion des LOB 30, 31 des Pericases, ensuite jointure 1 A 1 avec les fichiers ITD et MVT
#[07] 04/05/2021 : MZM : SPIRA 96034 : Condition ITD (Balance sheet year = Closing year AND Balance sheet Month <= Closing Month) for UPR grouping 1030 le fichier ITD 
#[08] 19/05/2021 : MZM : SPIRA 91111 : Condition MVT  (  ( "12" CT TRNCOD1_CF) AND ("7" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF) ))  le fichier MVT 
#[09] 08/06/2021 : MZM : SPIRA 91111 : Correction Regression sur la generation de PLC_NT et RTO 
#[10] 22/09/2021 : MZM : SPIRA 97033 : Condition ITD (Balance sheet year = Closing year AND Balance sheet Month <= Closing Month) for  grouping ACMTRS2_NT 303 and ACMTRS2_NT 307 le fichier ITD 
#[11] 29/12/2021 : MZM : SPIRA 101217 : delta entre TECLEDA et ESFD4020
#[12] 14/02/2022 : MZM : SPIRA 101493 : optimisation et aussi Ano filtre step 185 ACMCUR_CF
#[13] 24/02/2022 : MZM : SPIRA 102619 : wrongly uses output o"${ESF_DLDSIIGTAR}
#[14] 26/04/2022 : HR  : SPIRA 102747 : REQ 11.06 - IFRS17 - Gaps in DAC positions Q DSCxLKI on FAC
#[15] 19/05/2022 : MZM : SPIRA 104058 : DAC I17 - AI TL missing ==> Bouclette  (Ajout du fichier AI ESF_DLRGTAA_DACI17)
#[16] 14/03/2023 : MZM : SPIRA 107134 : Incorrect allocation of retro ITD amounts between placements
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd


# Job Initialisation
JOBINIT

# Get input parameters



BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
ICLODAT_D=$3
TYPEINV=$4
IDF_CT=$5

#ICLODAT_D="20201231"

ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`


ICLODAT_3MOIS=`echo "$ICLODAT_D" | awk '{ y1 = substr($0,3,2); m1 = substr($0,5,2); j2 = substr($0,7,2); if (m1 > "03") {y2 = y1; m2 = m1-3;} else {y2 = y1-1; m2 = m1+9; } ; if (length(j2) < 2) j2 = "0" j2 ; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
ICLODAT_3MOIS_M=`echo ${ICLODAT_3MOIS} | awk '{print substr($0,5,2)}'`
ICLODAT_3MOIS_A=`echo ${ICLODAT_3MOIS} | awk '{print substr($0,1,4)}'`
ICLODAT_3MOIS_J=`echo ${ICLODAT_3MOIS} | awk '{print substr($0,7,2)}'`

ICLODAT_3MOIS_AM=`echo ${ICLODAT_3MOIS} | awk '{print substr($0,1,6)}'`

datej=`date '+%Y%m%d%H%M%S'`
datedel=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-1; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel1=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-2; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel2=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-3; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`


if [ ${ICLODAT_3MOIS_M} = 12 ] 
then
ICLODAT_3MOIS_M=0
fi

##if [ "${TYPEINV}" != "INV" ]
##then
##
##	if [ "${TYPEINV}" = "POS" ]
##	then
##			EST_FTECLEDASII=${EST_FTECLEDASIISO}							
##	else
##			EST_FTECLEDASII=${EST_FTECLEDASIICO}														
##	fi
##	
##else
##
## EST_FTECLEDASII=${EST_FTECLEDASII}		   # Fichier EBS Inventaire A mettre a jour
##fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> TYPEINV0...................: ${TYPEINV0}"
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
ECHO_LOG "#===> ICLODAT_3MOIS_AM ..........: $ICLODAT_3MOIS_AM  "
ECHO_LOG "#===> ICLODAT_3MOIS_A ...........: $ICLODAT_3MOIS_A  "
ECHO_LOG "#===> ICLODAT_3MOIS_M ...........: $ICLODAT_3MOIS_M  "
ECHO_LOG "#===> ICLODAT_3MOIS_J ...........: $ICLODAT_3MOIS_J  "
ECHO_LOG "#===>     -------- input  ---------"
ECHO_LOG "#==> EST_ARCSTATGTA ...................:  ${EST_ARCSTATGTA}                 "
ECHO_LOG "#==> EST_ARCSTATGTAR...................:  ${EST_ARCSTATGTAR}                 "
ECHO_LOG "#==> EST_FTECLEDASO ...................:  $EST_FTECLEDASO                       "

ECHO_LOG "#==> EST_FBOPRSLNK ....................:  $EST_FBOPRSLNK                    "
ECHO_LOG "#==> EST_FBOPRSLNK_TXT ................:  $EST_FBOPRSLNK_TXT                "

ECHO_LOG "#==> EST_FCURSII ......................:  $EST_FCURSII                      "
ECHO_LOG "#==> EST_FDETTRS ......................:  $EST_FDETTRS                      "

ECHO_LOG "#==> EST_FPLATXCUMALL .................:  $EST_FPLATXCUMALL                 "

ECHO_LOG "#==> EST_FTECLEDASII ..................:  $EST_FTECLEDASII                  "
ECHO_LOG "#==> EST_FTRSLNK ......................:  $EST_FTRSLNK                      "

ECHO_LOG "#==> EST_FCTRGRO ......................:  $EST_FCTRGRO                   "
ECHO_LOG "#==> EST_IADPERICASE ..................:  $EST_IADPERICASE                  "
ECHO_LOG "#==> EST_IRDPERICASE0 .................:  $EST_IRDPERICASE0                 "
ECHO_LOG "#==> EST_IRDPERICASE ..................:  $EST_IRDPERICASE                 "
ECHO_LOG "#==> EST_IRDVPERICASE .................:  $EST_IRDVPERICASE                 "
ECHO_LOG "#==> EST_FCURQUOT_TXT .................:  $EST_FCURQUOT_TXT                 "
ECHO_LOG "#==> ESF_IRDPERICASE_NP ...............:  $ESF_IRDPERICASE_NP               "
ECHO_LOG "#==> ESF_IADVPERICASE_P ...............:  $ESF_IADVPERICASE_P               "
ECHO_LOG "#==> ESF_DLREGTAR_DACI17 ..............:  $ESF_DLREGTAR_DACI17              "
ECHO_LOG "#==> ESF_DLRGTAA_DACI17 ...............:  $ESF_DLRGTAA_DACI17              "

ECHO_LOG "#==> ESF_DLASIIGTAA ...................:  $ESF_DLASIIGTAA              "
ECHO_LOG "#==> ESF_DLASIIGTAR ...................:  $ESF_DLASIIGTAR              "
ECHO_LOG "#==> ESF_DLDGTAA_E_TRNCODEBS ..........:  $ESF_DLDGTAA_E_TRNCODEBS              "
ECHO_LOG "#==> ESF_DLDGTR_E .....................:  $ESF_DLDGTR_E              "
ECHO_LOG "#==> ESF_DLREGTAR .....................:  $ESF_DLREGTAR              "
ECHO_LOG "#==> ESF_DLSGTAA ......................:  $ESF_DLSGTAA              "
ECHO_LOG "#==> ESF_DLSGTAR ......................:  $ESF_DLSGTAR              "
ECHO_LOG "#==> ESF_DLSGTR .......................:  $ESF_DLSGTR              "
ECHO_LOG "#==> ESF_DLDSIIGTAR ...................:  $ESF_DLDSIIGTAR              "


ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#==> EST_DLCUMGTAAR_MVT ...............:  $EST_DLCUMGTAAR_MVT                   "
ECHO_LOG "#==> EST_DLCUMGTAAR_ITD ...............:  $EST_DLCUMGTAAR_ITD    "
ECHO_LOG "#==> EST_GTSII_CASHFLOW ...............:  $EST_GTSII_CASHFLOW               "
ECHO_LOG "#========================================================================="


# ESPD1800_I17G_AET_RPO_INI_DLSGTAASII

##if [ ! -f ${EST_ARCSTATGTA} ]
##then
##	touch ${EST_ARCSTATGTA}
##fi
##
##if [ ! -f ${EST_ARCSTATGTAR} ]
##then
##	touch ${EST_ARCSTATGTAR}
##fi


##if [ ! -f ${EST_FTECLEDASO} ]
##then
##	touch ${EST_FTECLEDASO}
##fi



##if [ ! -f ${EST_FTECLEDASII} ]
##then
##	touch ${EST_FTECLEDASII}
##fi


if [ ! -f ${ESF_DLREGTAR_DACI17} ]
then
	touch ${ESF_DLREGTAR_DACI17}
fi

if [ ! -f ${ESF_DLRGTAA_DACI17} ]
then
	touch ${ESF_DLRGTAA_DACI17}
fi

#/CONDITION NPVALID ((RETCTRCAT_CF = "02" OR  RETCTRCAT_CF = "2") AND (CTRSTS_CT = "3" OR  CTRSTS_CT = "03") AND FLAPROPRM_M != 0 )  AND (EXP_D >= $ICLODAT_D) AND ${EST_SORT_CONDITION} 
#/INCLUDE NPVALID


#SORT_I="${EPO_IRDPERICASE0} 1000 1"
#SORT_I="/scordata_dcvcnvobbatch/ubeu/perm/C_ESPT0000_IRDVPERICASE.dat 1000 1 "

## TU

##ESF_DLASIIGTAA=/scordata_aenitko2batch/ubeu/perm/T_ESPD3630_DLASIIGTAA_EBS_INV_20210930.dat
##ESF_DLASIIGTAR=/scordata_aenitko2batch/ubeu/perm/T_ESPD3630_DLASIIGTAR_EBS_INV_20210930.dat
##ESF_DLDGTAA_E_TRNCODEBS=/scordata_aenitko2batch/ubeu/perm/T_ESID2220_DLDGTAA_EBS_INV_20210930.dat
##ESF_DLDGTR_E=/scordata_aenitko2batch/ubeu/perm/T_ESPD2570_DLDGTR_E_EBS_INV_20210930.dat
##ESF_DLREGTAR=/scordata_aenitko2batch/ubeu/perm/T_ESPD2550_DLREGTAR_EBS_INV_20210930.dat
##ESF_DLSGTAA=/scordata_aenitko2batch/ubeu/perm/T_ESPD1800_DLSGTAA_EBS_INV_20210930.dat
##ESF_DLSGTAR=/scordata_aenitko2batch/ubeu/perm/T_ESPD1800_DLSGTAR_EBS_INV_20210930.dat
##ESF_DLSGTR=/scordata_aenitko2batch/ubeu/perm/T_ESPD1800_DLSGTR_EBS_INV_20210930.dat
##ESF_DLDSIIGTAR=/scordata_aenitko2batch/ubeu/perm/T_ESPD3710_DLDSIIGTAR_EBS_INV_20210930.dat

## TU

#[06]

NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Sort of IRDPERICASE : o "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDPERICASE.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS     SSD_CF 						1:1 - 1:EN,
						CTR_NF 						3:1 - 3:,
            SEC_NF 						5:1 - 5:EN,
            UWY_NF 						6:1 - 6:EN,
            UW_NF 						7:1 - 7:EN,
            LOB_CF 						38:1 - 38:,                                     
            NAT_CF 						49:1 - 49:,                       
            EXP_D  						28:1 - 28:EN,
            CTRSTS_CT 				99:1 - 99:,
            RETCTRCAT_CF 			107:1 - 107:,
            FLAPROPRM_M  			203:1 - 203:EN  15/3
/KEYS CTR_NF, SEC_NF, UWY_NF, UW_NF 
/CONDITION SANS_CTR_LIFE ( LOB_CF != "30" AND  LOB_CF != "31" )
/OUTFILE $SORT_O
/INCLUDE SANS_CTR_LIFE
exit
EOF
SORT


#SORT_I="/scordata_dcvcnvobbatch/ubeu/perm/C_ESPT0000_IADPERICASE_20200930.dat 1000 1 "
#export ${PRG}_I2=/scor/home/u006596/martin/perm/M_ESPT0000_FCTRGRO.dat

#[05]
NSTEP=${NJOB}_07
#-----------------------------------------------------------------------------
LIBEL="Filling segmentation perimeters in IADPERICASE ..."
PRG=ESTM1004
export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FCTRGRO1.dat  # plus utilise
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO.dat   # plus utilise
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE.dat
EXECPRG



#SORT_I="${EST_IADPERICASE} 1000 1"

#[06]

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Sort of Assumed IADPERICASE : "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_07_${IB}_ESTM1004_IADPERICASE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS     SSD_CF 						1:1 - 1:EN,
						CTR_NF 						3:1 - 3:,
            SEC_NF 						5:1 - 5:EN,
            UWY_NF 						6:1 - 6:EN,
            UW_NF 						7:1 - 7:EN, 
            LOB_CF 						38:1 - 38:,                                     
            NAT_CF 						49:1 - 49:,            
            EXP_D  						28:1 - 28:EN,
            CTRSTS_CT 				99:1 - 99:
/KEYS CTR_NF, SEC_NF, UWY_NF, UW_NF 
/CONDITION SANS_CTR_LIFE ( LOB_CF != "30" AND  LOB_CF != "31" )
/OUTFILE $SORT_O
/INCLUDE SANS_CTR_LIFE
exit
EOF
SORT


#SORT_I="/scor/home/u006596/martin/perm/M_ESPT0000_FTRSLNK_TXT_20210331.dat 500 1"

NSTEP=${NJOB}_25
# Filter EST_FTRSLNK_TXT on PRS_CF = "751"
#-----------------------------------------------------------------------------
LIBEL="Filter EST_FTRSLNK_TXT on PRS_CF = "751""
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_751.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  PRS_CF    1:1 -  1:
/CONDITION IS_PRS_751 ( PRS_CF = "751" )
/OUTFILE $SORT_O
/INCLUDE IS_PRS_751
/COPY
exit
EOF
SORT

#SORT_I="/scor/home/u006596/martin/perm/M_ESPT0000_FBOPRSLNK_TXT_20201231.dat 500 1"

NSTEP=${NJOB}_30
# Extend EST_FBOPRSLNK_TXT with PRS_ 751 and of EST_FTRSLNK_TXT
#-----------------------------------------------------------------------------
LIBEL="Extend EST_FBOPRSLNK_TXT with PRS_ 751 and of EST_FTRSLNK_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FBOPRSLNK_TXT}  500 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FBOPRSLNK_FTRSLNK.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
			TRSPFX_CF	          1:1 -  1:,   
			ACMTRSL0_NT	        2:1 -  2:,   
			ACMTRSL1_NT	        3:1 -  3:,   
			ACMTRSL2_NT	        4:1 -  4:,   
			ACMTRSL3_NT	        5:1 -  5:,   
			ACMTRSLL1_NT	      6:1 -  6:,   
			ACMTRSLL2_NT	      7:1 -  7:,   
			TRSTYP_NT	          8:1 -  8:,   
			DETTRS_CF	          9:1 -  9:,     
			PCPTRS_CF	          10:1 - 10:,  
			TRS_CF	            11:1 - 11:,  
			SUBTRS_CF	          12:1 - 12:,  
			ESTIM_NT	          13:1 - 13:,  
			TRNTYP_CT           14:1 - 14:,  			
			PRS_CF_F2           1:1  - 1:,
			ACMTRS_NT_F2				2:1  - 2:,
			DETTRS_CF_F2				3:1  - 3:,
			all_cols_F1		 		  1:1  - 14:
/joinkeys 
       DETTRS_CF
/INFILE ${DFILT}/${NJOB}_25_${IB}_FTRSLNK_751.dat 500 1 "~" 
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:all_cols_F1
	,rightside:PRS_CF_F2   
	,rightside:ACMTRS_NT_F2   
exit
EOF
SORT


#SORT_I="/scor/home/u006596/martin/perm/M_ESIX7000_ARCSTATGTA.dat 1000 1"
#SORT_I2="/scordata_dcvcnvobbatch/ubeu/perm/C_ESIX7000_ARCSTATGTAR.dat 1000 1"

#NSTEP=${NJOB}_35
## SORT ARCSTAGTA with ONLY ACTUAL
##-----------------------------------------------------------------------------
#LIBEL="SORT ARCSTAGTA with ONLY ACTUAL ..."
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_ARCSTATGTA} 1000 1"
#SORT_I2="${EST_ARCSTATGTAR} 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTAR_O.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF            1:1 -  1:EN,
#        ESB_CF            2:1 -  2:EN,
#        BALSHEY_NF        3:1 -  3:EN,
#        BALSHYM16_NF      3:1 -  3:6,       
#        BALSHRMTH_NF      4:1 -  4:EN,
#        BALSHRDAY_NF      5:1 -  5:EN,
#        TRNCOD_CF         6:1 -  6:,
#        TRNCOD1_CF        6:1 -  6:1,
#        TRNCOD2_CF        6:2 -  6:2,
#        TRNCOD3_CF        6:3 -  6:6,
#        TRNCOD34_CF       6:3 -  6:4,        
#        TRNCOD4_CF        6:3 -  6:7,
#        TRNCOD8_CF        6:8 -  6:8,
#        DBLTRNCOD_CF      7:1 -  7:,
#        CTR_NF            8:1 -  8:,
#        END_NT            9:1 -  9:EN,
#        SEC_NF           10:1 - 10:EN,
#        UWY_NF           11:1 - 11:,
#        UW_NT            12:1 - 12:EN,
#        OCCYEA_NF        13:1 - 13:,
#        ACY_NF           14:1 - 14:,
#        SCOSTRMTH_NF     15:1 - 15:EN,
#        SCOENDMTH_NF     16:1 - 16:EN,
#        CLOSTYP_NF       17:1 - 17:,
#        CUR_CF           18:1 - 18:,
#        AMT_M            19:1 - 19:EN 15/3,
#        CED_NF           20:1 - 20:,
#        BRK_NF           21:1 - 21:,
#        PAY_NF           22:1 - 22:,
#        KEY_NF           23:1 - 23:,
#        RETCTR_NF        24:1 - 24:,
#        RETEND_NT        25:1 - 25:EN,
#        RETSEC_NF        26:1 - 26:EN,
#        RTY_NF           27:1 - 27:,
#        RETUW_NT         28:1 - 28:EN,
#        RETOCCYEA_NF     29:1 - 29:,
#        RETACY_NF        30:1 - 30:,
#        RETSCOSTRMTH_NF  31:1 - 31:EN,
#        RETSCOENDMTH_NF  32:1 - 32:EN,
#        RCL_NF           33:1 - 33:,
#        RETCUR_CF        34:1 - 34:,
#        RETAMT_M         35:1 - 35:EN 15/3,
#        PLC_NT           36:1 - 36:,
#        RTO_NF           37:1 - 37:,
#        INT_NF           38:1 - 38:,
#        RETPAY_NF        39:1 - 39:,
#        RETKEY_CF        40:1 - 40:,
#        RETINTAMT_M      41:1 - 41:EN 15/3,
#        FILLER1           1:1 - 35:,
#        FILLER2          38:1 - 40:,
#        all_cols_F1      1:1 -  72:
#/KEYS all_cols_F1
#/CONDITION COND_ONLYACTUAL  (BALSHEY_NF < ${ICLODAT_A}) AND (  (( ( "12"  CT TRNCOD1_CF) AND ("4" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  ) ) OR  (( ( "12"  CT TRNCOD1_CF) AND ("1" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  ) ) )
#/OUTFILE ${SORT_O}
#/INCLUDE COND_ONLYACTUAL
#exit
#EOF
#SORT


#SORT_I=/scor/home/u006596/martin/perm/M_ESPT0000_FPLATXCUMALL.dat

NSTEP=${NJOB}_40
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

#[12] 
#NSTEP=${NJOB}_60
## Join AND Extend ARCSTAGTA with PRS_751, TRSTYP_NT, AND TRNTYP_CT of FBOPRSLNK_FTRSLNK.dat
##-----------------------------------------------------------------------------
#LIBEL="Join ARCSTAGTA with PRS_ 751 and TRNTYP_CT FBOPRSLNK_FTRSLNK.dat"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_35_${IB}_SORT_ARCSTATGTAR_O.dat 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTAR_O.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF            1:1 -  1:EN,
#        ESB_CF            2:1 -  2:EN,
#        BALSHEY_NF        3:1 -  3:EN,
#        BALSHRMTH_NF      4:1 -  4:EN,
#        BALSHRDAY_NF      5:1 -  5:EN,
#        TRNCOD_CF         6:1 -  6:,
#        DBLTRNCOD_CF      7:1 -  7:,
#        CTR_NF            8:1 -  8:,
#        END_NT            9:1 -  9:EN,
#        SEC_NF           10:1 - 10:EN,
#        UWY_NF           11:1 - 11:,
#        UW_NT            12:1 - 12:EN,
#        OCCYEA_NF        13:1 - 13:,
#        ACY_NF           14:1 - 14:,
#        SCOSTRMTH_NF     15:1 - 15:EN,
#        SCOENDMTH_NF     16:1 - 16:EN,
#        CLOSTYP_NF       17:1 - 17:,
#        CUR_CF           18:1 - 18:,
#        AMT_M            19:1 - 19:EN 15/3,
#        CED_NF           20:1 - 20:,
#        BRK_NF           21:1 - 21:,
#        PAY_NF           22:1 - 22:,
#        KEY_NF           23:1 - 23:,
#        RETCTR_NF        24:1 - 24:,
#        RETEND_NT        25:1 - 25:EN,
#        RETSEC_NF        26:1 - 26:EN,
#        RTY_NF           27:1 - 27:,
#        RETUW_NT         28:1 - 28:EN,
#        RETOCCYEA_NF     29:1 - 29:,
#        RETACY_NF        30:1 - 30:,
#        RETSCOSTRMTH_NF  31:1 - 31:EN,
#        RETSCOENDMTH_NF  32:1 - 32:EN,
#        RCL_NF           33:1 - 33:,
#        RETCUR_CF        34:1 - 34:,
#        RETAMT_M         35:1 - 35:EN 15/3,
#        PLC_NT           36:1 - 36:,
#        RTO_NF           37:1 - 37:,
#        INT_NF           38:1 - 38:,
#        RETPAY_NF        39:1 - 39:,
#        RETKEY_CF        40:1 - 40:,                                                               
#        RETINTAMT_M      41:1 - 41:EN 15/3,                                               
#        COLS_STD_F1       1:1 - 41:,                                                      
#        ACMTRS_NT        42:1 - 42:,                                                      
#        ACMAMT_M         43:1 - 43:EN 15/3,                                                  
#        ACMCUR_CF        44:1 - 44:,                                                      
#				PRS_CF 		       45:1 - 45:,                                                      
#				SEG_NF 		       46:1 - 46:,                                                      
#				LOB_CF 		       47:1 - 47:,                                                      
#				NAT_CF 		       48:1 - 48:,                                                      
#				TYP_CT 		       49:1 - 49:,                                                      
#				PATTYP_CT        50:1 - 50:,                                                      
#				SEGLOB_CF        51:1 - 51:,                                                      
#				ACMTRSL3_NT      52:1 - 52:,                                                                                                           
#				TRSPFX_CF_F2	   1:1 -  1:,                                                       
#				ACMTRSL3_NT_F2   5:1 -  5:, 
#				ACMTRSL2_NT_F2   4:1 -  4:,                                           
#				TRSTYP_NT_F2	   8:1 -  8:,         
#				DETTRS_CF_F2	   9:1 -  9:,           
#				TRNTYP_CT_F2    14:1 - 14:,  
#				PRS_CF_F2       15:1 - 15:,
#				ACMTRS_NT_F2    16:1 - 16:													         
#/joinkeys 
#       TRNCOD_CF
#/INFILE ${DFILT}/${NJOB}_30_${IB}_SORT_FBOPRSLNK_FTRSLNK.dat 1000 1 "~" 
#/joinkeys 
#       DETTRS_CF_F2
#/JOIN UNPAIRED LEFTSIDE
#/OUTFILE ${SORT_O}
#/REFORMAT 
#	leftside:COLS_STD_F1
#	,rightside:ACMTRSL2_NT_F2  
#	,leftside:RETINTAMT_M 	 
#	,leftside:ACMCUR_CF 
#	,rightside:PRS_CF_F2
#	,leftside:SEG_NF 		
#	,leftside:LOB_CF 		
#	,leftside:NAT_CF 		
#	,leftside:TYP_CT 		
#	,leftside:PATTYP_CT 
#	,leftside:SEGLOB_CF 
#	,rightside:ACMTRSL3_NT_F2	
#	,rightside:TRNTYP_CT_F2
#	,rightside:TRSTYP_NT_F2
#	,rightside:TRSPFX_CF_F2										  
#exit
#EOF
#SORT
#
##### JOINTURE AVEC FBO_TTRSLNK
#
##SORT_I="/scor/home/u006596/martin/perm/M_ESPD3800_FTECLEDASO_I4I.dat 1000 1"		
#
#NSTEP=${NJOB}_65
## Join AND Extend FTECLEDASO_I4I with PRS_751, TRSTYP_NT, AND TRNTYP_CT of FBOPRSLNK_FTRSLNK.dat
##-----------------------------------------------------------------------------
#LIBEL="Join FTECLEDASO_I4I with PRS_ 751 and TRNTYP_CT FBOPRSLNK_FTRSLNK.dat"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_FTECLEDASO} 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDASO_I4I.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF            1:1 -  1:EN,
#        ESB_CF            2:1 -  2:EN,
#        BALSHEY_NF        3:1 -  3:EN,
#        BALSHRMTH_NF      4:1 -  4:EN,
#        BALSHRDAY_NF      5:1 -  5:EN,
#        TRNCOD_CF         6:1 -  6:,
#        DBLTRNCOD_CF      7:1 -  7:,
#        CTR_NF            8:1 -  8:,
#        END_NT            9:1 -  9:EN,
#        SEC_NF           10:1 - 10:EN,
#        UWY_NF           11:1 - 11:,
#        UW_NT            12:1 - 12:EN,
#        OCCYEA_NF        13:1 - 13:,
#        ACY_NF           14:1 - 14:,
#        SCOSTRMTH_NF     15:1 - 15:EN,
#        SCOENDMTH_NF     16:1 - 16:EN,
#        CLOSTYP_NF       17:1 - 17:,
#        CUR_CF           18:1 - 18:,
#        AMT_M            19:1 - 19:EN 15/3,
#        CED_NF           20:1 - 20:,
#        BRK_NF           21:1 - 21:,
#        PAY_NF           22:1 - 22:,
#        KEY_NF           23:1 - 23:,
#        RETCTR_NF        24:1 - 24:,
#        RETEND_NT        25:1 - 25:EN,
#        RETSEC_NF        26:1 - 26:EN,
#        RTY_NF           27:1 - 27:,
#        RETUW_NT         28:1 - 28:EN,
#        RETOCCYEA_NF     29:1 - 29:,
#        RETACY_NF        30:1 - 30:,
#        RETSCOSTRMTH_NF  31:1 - 31:EN,
#        RETSCOENDMTH_NF  32:1 - 32:EN,
#        RCL_NF           33:1 - 33:,
#        RETCUR_CF        34:1 - 34:,
#        RETAMT_M         35:1 - 35:EN 15/3,
#        PLC_NT           36:1 - 36:,
#        RTO_NF           37:1 - 37:,
#        INT_NF           38:1 - 38:,
#        RETPAY_NF        39:1 - 39:,
#        RETKEY_CF        40:1 - 40:,                                                               
#        RETINTAMT_M      41:1 - 41:EN 15/3,                                               
#        COLS_STD_F1       1:1 - 41:,                                                       
#        ACMTRS_NT        42:1 - 42:,                                                      
#        ACMAMT_M         43:1 - 43:EN 15/3,                                                   
#        ACMCUR_CF        44:1 - 44:,                                                      
#				PRS_CF 		       45:1 - 45:,                                                      
#				SEG_NF 		       46:1 - 46:,                                                      
#				LOB_CF 		       47:1 - 47:,                                                      
#				NAT_CF 		       48:1 - 48:,                                                      
#				TYP_CT 		       49:1 - 49:,                                                      
#				PATTYP_CT        50:1 - 50:,                                                      
#				SEGLOB_CF        51:1 - 51:,                                                      
#				ACMTRSL3_NT      52:1 - 52:,                                                                                                           
#				TRSPFX_CF_F2	   1:1 -  1:,                                                       
#				ACMTRSL2_NT_F2   4:1 -  4:, 
#				ACMTRSL3_NT_F2   5:1 -  5:, 								                                              
#				TRSTYP_NT_F2	   8:1 -  8:,         
#				DETTRS_CF_F2	   9:1 -  9:,           
#				TRNTYP_CT_F2    14:1 - 14:,  
#				PRS_CF_F2       15:1 - 15:,
#				ACMTRS_NT_F2    16:1 - 16:													         
#/joinkeys 
#       TRNCOD_CF
#/INFILE ${DFILT}/${NJOB}_30_${IB}_SORT_FBOPRSLNK_FTRSLNK.dat 1000 1 "~" 
#/joinkeys 
#       DETTRS_CF_F2
#/JOIN UNPAIRED LEFTSIDE
#/OUTFILE ${SORT_O}
#/REFORMAT 
#	leftside:COLS_STD_F1
#	,rightside:ACMTRSL2_NT_F2  
#	,leftside:RETINTAMT_M 	 
#	,leftside:ACMCUR_CF 
#	,rightside:PRS_CF_F2
#	,leftside:SEG_NF 		
#	,leftside:LOB_CF 		
#	,leftside:NAT_CF 		
#	,leftside:TYP_CT 		
#	,leftside:PATTYP_CT 
#	,leftside:SEGLOB_CF 
#	,rightside:ACMTRSL3_NT_F2	
#	,rightside:TRNTYP_CT_F2
#	,rightside:TRSTYP_NT_F2
#	,rightside:TRSPFX_CF_F2								  
#exit
#EOF
#SORT


#SORT_I="/scor/home/u006596/martin/perm/M_ESPD3800_FTECLEDASIISO.dat 1000 1"

# deb Modif

## [11] Remplacement du fichier ESPD3800 par les fichiers Futurs, ESFD3630, ....
#[13]


NSTEP=${NJOB}_67
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Merge and Sort of old Input ESPD3800 File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLASIIGTAA} 1000 1"
SORT_I2="${ESF_DLASIIGTAR} 1000 1"
SORT_I3="${ESF_DLDGTAA_E_TRNCODEBS} 1000 1"
SORT_I4="${ESF_DLDGTR_E} 1000 1"
SORT_I5="${ESF_DLREGTAR} 1000 1"
SORT_I6="${ESF_DLSGTAA} 1000 1"
SORT_I7="${ESF_DLSGTAR} 1000 1"
SORT_I8="${ESF_DLSGTR} 1000 1"
SORT_I9="${ESF_DLRGTAA} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLTECLEDSII_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF     6:1 -  6:,
        TRNCOD2C_CF   6:2 -  6:2,
        TRNCOD2D_CF   6:8 -  6:8,
        CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:,
        LIGNEGT       1:1 - 39:,
        RETCTR_NF    24:1 - 24:,
        RETEND_NT    25:1 - 25:EN,
        RETSEC_NF    26:1 - 26:EN,
        RTY_NF       27:1 - 27:,
        RETUW_NT     28:1 - 28:EN,
        PLC_NT       36:1 - 36:EN,
        RETKEY_CF    40:1 - 40:,
        RETINTAMT_M  41:1 - 41:,
        FILLER_30_COLS 42:1 - 71:
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT,
     RETEND_NT,
      RETUW_NT,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF
/CONDITION COND_EBS ("AEJG" CT TRNCOD2C_CF ) OR ("GH" CT TRNCOD2D_CF )
/OUTFILE ${SORT_O}
/INCLUDE COND_EBS
exit
EOF
SORT

###[35]
##NSTEP=${NJOB}_68
### Merge and sort of the Acceptance file
###------------------------------------------------------------------------------
##LIBEL="Omit BDT Internal retro"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_DLSGTAAEBS_O.dat 1000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAAEBS_O.dat OVERWRITE 1000 1"
##INPUT_TEXT ${SORT_CMD} <<EOF
##/FIELDS TRNCOD_CF      6:1 -   6:,
##        TRNCOD2_CF     6:3 -   6:6,
##        CTR_NF         8:1 -   8:,
##        END_NT         9:1 -   9:,
##        SEC_NF        10:1 -  10:,
##        UWY_NF        11:1 -  11:,
##        UW_NT         12:1 -  12:,
##        ORICOD_LS    104:1 - 104:
##/KEYS RETCTR_NF,
##      RTY_NF,	
##      RETSEC_NF,
##      PLC_NT,
##     RETEND_NT,
##      RETUW_NT,
##      CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT,
##      TRNCOD_CF
##/CONDITION COND_EBS ORICOD_LS = "OIGTA" AND (TRNCOD2_CF = "4161" OR TRNCOD2_CF = "4261" OR TRNCOD2_CF = "1008")
##/OMIT COND_EBS
##exit
##EOF
##SORT


# end Modif


NSTEP=${NJOB}_70
# Join AND Extend FTECLEDASII with PRS_751, TRSTYP_NT, AND TRNTYP_CT of FBOPRSLNK_FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join FTECLEDASII with PRS_ 751 and TRNTYP_CT FBOPRSLNK_FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
# SORT_I="${EST_FTECLEDASII} 1000 1"
SORT_I="${DFILT}/${NJOB}_67_${IB}_SORT_DLTECLEDSII_O.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDASII.dat 1000 1"
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
        SCOENDMTH_NF     16:1 - 16:EN,
        CLOSTYP_NF       17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,                                                               
        RETINTAMT_M      41:1 - 41:EN 15/3,                                               
        COLS_STD_F1       1:1 - 41:,                                                       
        ACMTRS_NT        42:1 - 42:,                                                      
        ACMAMT_M         43:1 - 43:EN 15/3,                                                    
        ACMCUR_CF        44:1 - 44:,                                                      
				PRS_CF 		       45:1 - 45:,                                                      
				SEG_NF 		       46:1 - 46:,                                                      
				LOB_CF 		       47:1 - 47:,                                                      
				NAT_CF 		       48:1 - 48:,                                                      
				TYP_CT 		       49:1 - 49:,                                                      
				PATTYP_CT        50:1 - 50:,                                                      
				SEGLOB_CF        51:1 - 51:,                                                      
				ACMTRSL3_NT      52:1 - 52:,  				                                                                                                          
				TRSPFX_CF_F2	   1:1 -  1:,                                                       
				ACMTRSL2_NT_F2   4:1 -  4:,
				ACMTRSL3_NT_F2   5:1 -  5:, 				 				                                              
				TRSTYP_NT_F2	   8:1 -  8:,         
				DETTRS_CF_F2	   9:1 -  9:,           
				TRNTYP_CT_F2    14:1 - 14:,  
				PRS_CF_F2       15:1 - 15:,
				ACMTRS_NT_F2    16:1 - 16:													         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_30_${IB}_SORT_FBOPRSLNK_FTRSLNK.dat 1000 1 "~" 
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:COLS_STD_F1
	,rightside:ACMTRSL2_NT_F2  
	,leftside:RETINTAMT_M 	 
	,leftside:ACMCUR_CF 
	,rightside:PRS_CF_F2
	,leftside:SEG_NF 		
	,leftside:LOB_CF 		
	,leftside:NAT_CF 		
	,leftside:TYP_CT 		
	,leftside:PATTYP_CT 
	,leftside:SEGLOB_CF 
	,rightside:ACMTRSL3_NT_F2	
	,rightside:TRNTYP_CT_F2
	,rightside:TRSTYP_NT_F2
	,rightside:TRSPFX_CF_F2										  
exit
EOF
SORT


## [15] AI DAC I17

NSTEP=${NJOB}_75
# Join AND Extend ESF_DLREGTAR_DACI17 with PRS_751, TRSTYP_NT, AND TRNTYP_CT of FBOPRSLNK_FTRSLNK.dat
#-----------------------------------------------------------------------------
LIBEL="Join ESF_DLREGTAR_DACI17 with PRS_ 751 and TRNTYP_CT FBOPRSLNK_FTRSLNK.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLREGTAR_DACI17} 1000 1"
SORT_I2="${ESF_DLRGTAA_DACI17}  1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTAR_DACI17.dat 1000 1"
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
        SCOENDMTH_NF     16:1 - 16:EN,
        CLOSTYP_NF       17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,                                                               
        RETINTAMT_M      41:1 - 41:EN 15/3,                                               
        COLS_STD_F1       1:1 - 41:,                                                       
        ACMTRS_NT        42:1 - 42:,                                                      
        ACMAMT_M         43:1 - 43:EN 15/3,                                                    
        ACMCUR_CF        44:1 - 44:,                                                      
				PRS_CF 		       45:1 - 45:,                                                      
				SEG_NF 		       46:1 - 46:,                                                      
				LOB_CF 		       47:1 - 47:,                                                      
				NAT_CF 		       48:1 - 48:,                                                      
				TYP_CT 		       49:1 - 49:,                                                      
				PATTYP_CT        50:1 - 50:,                                                      
				SEGLOB_CF        51:1 - 51:,                                                      
				ACMTRSL3_NT      52:1 - 52:,  				                                                                                                          
				TRSPFX_CF_F2	   1:1 -  1:,                                                       
				ACMTRSL2_NT_F2   4:1 -  4:,
				ACMTRSL3_NT_F2   5:1 -  5:, 				 				                                              
				TRSTYP_NT_F2	   8:1 -  8:,         
				DETTRS_CF_F2	   9:1 -  9:,           
				TRNTYP_CT_F2    14:1 - 14:,  
				PRS_CF_F2       15:1 - 15:,
				ACMTRS_NT_F2    16:1 - 16:													         
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_30_${IB}_SORT_FBOPRSLNK_FTRSLNK.dat 1000 1 "~" 
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:COLS_STD_F1
	,rightside:ACMTRSL2_NT_F2  
	,leftside:RETINTAMT_M 	 
	,leftside:ACMCUR_CF 
	,rightside:PRS_CF_F2
	,leftside:SEG_NF 		
	,leftside:LOB_CF 		
	,leftside:NAT_CF 		
	,leftside:TYP_CT 		
	,leftside:PATTYP_CT 
	,leftside:SEGLOB_CF 
	,rightside:ACMTRSL3_NT_F2	
	,rightside:TRNTYP_CT_F2
	,rightside:TRSTYP_NT_F2
	,rightside:TRSPFX_CF_F2										  
exit
EOF
SORT


# [006] 
#[08]  ( ( "12" CT TRNCOD1_CF) AND ("7" CT TRNCOD2_CF) ) ) 

#[012]
NSTEP=${NJOB}_80
#/CONDITION COND_ONLYACTUAL  (( ( "12"  CT TRNCOD1_CF) AND ("4" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  ) ) OR  (( ( "12"  CT TRNCOD1_CF) AND ("1" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  ) )           
#-----------------------------------------------------------------------------
LIBEL="AGREGATES Merge FILE For QUATERLY ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDASII.dat 1000 1"  # Tout le trimestre EBS en cours de traitement
SORT_I2="${ESF_FTECLEDA_I4I_ACMTRS} 1000 1"
SORT_I3="${DFILT}/${NJOB}_75_${IB}_SORT_DLREGTAR_DACI17.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,       
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        LINETYP_NF       13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLOSTYP_NF       17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,     
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
				PRS_CF 		       45:1 - 45:,
				SEG_NF 		       46:1 - 46:,
				NAT_CF		       47:1 - 47:,
				LOB_CF 		       48:1 - 48:,				
				TYP_CT 		       49:1 - 49:,
				PATTYP_CT        50:1 - 50:,
				SEGLOB_CF        51:1 - 51:,
				ACMTRSL3_NT      52:1 - 52:, 
				TRNTYP_CT        53:1 - 53:EN, 	
				TRSTYP_NT        54:1 - 54:EN, 	
				TRSPFX_CF        55:1 - 55:EN            
/KEYS   
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,        
        RETCTR_NF,
        RETEND_NT,
        RTY_NF,
        RETUW_NT,
        RETSEC_NF,
        TRNCOD_CF,	         
        PLC_NT,        
        ACMTRSL3_NT,
        RETCUR_CF,
        LINETYP_NF,
        CLOSTYP_NF,
        TRNTYP_CT,   
        TRSTYP_NT,
        TRSPFX_CF                            
/CONDITION COND_TQUATERLY ( (BALSHEY_NF = ${ICLODAT_A}) AND ( BALSHRMTH_NF <= ${ICLODAT_M})  AND  ( ${ICLODAT_3MOIS_M} < BALSHRMTH_NF) AND ( ${ICLODAT_M} >= ${ICLODAT_3MOIS_M}) 
														AND ( ( (TRSTYP_NT = 1) OR (TRSTYP_NT = 2) OR (TRSTYP_NT = 3)  OR ( (TRSTYP_NT = 0)  AND  ( TRNTYP_CT = 150))  )  ) 
                            AND (LOB_CF != "30" AND LOB_CF != "31") )
/CONDITION AE_EST  		( ( "12"  CT TRNCOD1_CF) AND ("47E" CT TRNCOD2_CF) AND ("0" NC TRNCOD8_CF) )  
/CONDITION AE_ACT  		( ( "12"  CT TRNCOD1_CF) AND ("47" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  ) 
/CONDITION ACTUAL  		( ( "12"  CT TRNCOD1_CF) AND ("17" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  )  
/CONDITION ESTIMATES  ( ( "12"  CT TRNCOD1_CF) AND ("17A" CT TRNCOD2_CF) AND (  "0" NC TRNCOD8_CF) ) 
/CONDITION EBS        ( ( "12" CT TRNCOD1_CF ) AND ("AE" CT TRNCOD2_CF)  AND (TRNTYP_CT = 100) )
/CONDITION IFRS4      ( ( "12" CT TRNCOD1_CF ) AND ("147" CT TRNCOD2_CF)  AND ( TRNTYP_CT < 100) )
/CONDITION IFRS17      ( ( "12" CT TRNCOD1_CF ) AND ("1A" CT TRNCOD2_CF)  AND ( TRNTYP_CT = 150) )
/CONDITION ASS_RET  	( "1"  CT TRNCOD1_CF)  
/DERIVEDFIELD LINETYP_NF_NEW if AE_EST then "AE~" else if AE_ACT then "AA~" else if ACTUAL then "AC~" else if ESTIMATES then "ES~" else "OO~"
/DERIVEDFIELD CLOSTYP_NF_NEW if EBS then "E~" else if IFRS4 then "I~" else if IFRS17 then "G~" else "A~"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD TYP_CT_NEW if ASS_RET then "A~" else "R~" 
/DERIVEDFIELD STRVIDE "~"
/DERIVEDFIELD PLUS_20_CHAMPS 20"~"
/DERIVEDFIELD ACY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD SCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD SCOENDMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD RETINTAMT_MC RETAMT_M 
/DERIVEDFIELD ACMAMT_MC if ASS_RET then AMT_M else RETAMT_M
/DERIVEDFIELD ACMCUR_CF_NEW if ASS_RET then CUR_CF else RETCUR_CF
/OUTFILE ${SORT_O}
/INCLUDE COND_TQUATERLY
/REFORMAT 
         SSD_CF          
         ,ESB_CF          
         ,BALSHEY_NF_NEW      
         ,BALSHRMTH_NF_NEW    
         ,BALSHRDAY_NF_NEW    
         ,TRNCOD_CF            
         ,DBLTRNCOD_CF    
         ,CTR_NF          
         ,END_NT          
         ,SEC_NF          
         ,UWY_NF          
         ,UW_NT           
         ,LINETYP_NF_NEW       
         ,ACY_NF_NEW          
         ,SCOSTRMTH_NF_NEW    
         ,SCOENDMTH_NF_NEW    
         ,CLOSTYP_NF_NEW          
         ,CUR_CF          
         ,AMT_M           
         ,CED_NF          
         ,BRK_NF          
         ,PAY_NF          
         ,KEY_NF          
         ,RETCTR_NF       
         ,RETEND_NT       
         ,RETSEC_NF       
         ,RTY_NF          
         ,RETUW_NT        
         ,RETOCCYEA_NF    
         ,ACY_NF_NEW       
         ,SCOSTRMTH_NF_NEW 
         ,SCOENDMTH_NF_NEW 
         ,RCL_NF          
         ,RETCUR_CF       
         ,RETAMT_M        
         ,PLC_NT          
         ,RTO_NF          
         ,INT_NF          
         ,RETPAY_NF       
         ,RETKEY_CF       
         ,RETINTAMT_MC
         ,ACMTRS_NT    
         ,ACMAMT_MC
         ,ACMCUR_CF_NEW     
         ,PRS_CF 		  
         ,STRVIDE 		  
         ,STRVIDE 		  
         ,STRVIDE 		  
         ,TYP_CT_NEW 		  
         ,STRVIDE    
         ,STRVIDE    
         ,ACMTRSL3_NT
         ,TRNTYP_CT 
         ,TRSTYP_NT
				 ,TRSPFX_CF 
         ,STRVIDE				 
         ,PLUS_20_CHAMPS				   
exit
EOF
SORT 


# /DERIVEDFIELD ACMCUR_CF_NEW if ASS_RET then CUR_CF else RETCUR_CF

NSTEP=${NJOB}_85
# SORT UNIQUE of AGGREGATION file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of AGGREGATION QUATERLY file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_SORT_DLCUMGTAAR_MVT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_ASS_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
       SSD_CF            1:1 -  1:EN,         
       ESB_CF            2:1 -  2:EN,         
       BALSHEY_NF        3:1 -  3:EN,         
       BALSHRMTH_NF      4:1 -  4:EN,         
       BALSHRDAY_NF      5:1 -  5:EN,         
       TRNCOD_CF         6:1 -  6:,           
       TRNCOD1_CF        6:1 -  6:1,          
       TRNCOD2_CF        6:2 -  6:2,          
       TRNCOD3_CF        6:3 -  6:6,          
       TRNCOD34_CF       6:3 -  6:4,          
       TRNCOD4_CF        6:3 -  6:7,          
       TRNCOD8_CF        6:8 -  6:8,          
       DBLTRNCOD_CF      7:1 -  7:,           
       CTR_NF            8:1 -  8:,           
       END_NT            9:1 -  9:EN,         
       SEC_NF           10:1 - 10:EN,         
       UWY_NF           11:1 - 11:,           
       UW_NT            12:1 - 12:EN,         
       LINETYP_NF       13:1 - 13:,           
       ACY_NF           14:1 - 14:,           
       SCOSTRMTH_NF     15:1 - 15:EN,         
       SCOENDMTH_NF     16:1 - 16:EN,         
       CLOSTYP_NF       17:1 - 17:,           
       CUR_CF           18:1 - 18:,           
       AMT_M            19:1 - 19:EN 15/3,    
       CED_NF           20:1 - 20:,           
       BRK_NF           21:1 - 21:,           
       PAY_NF           22:1 - 22:,           
       KEY_NF           23:1 - 23:,           
       RETCTR_NF        24:1 - 24:,           
       RETEND_NT        25:1 - 25:EN,         
       RETSEC_NF        26:1 - 26:EN,         
       RTY_NF           27:1 - 27:,           
       RETUW_NT         28:1 - 28:EN,         
       RETOCCYEA_NF     29:1 - 29:,           
       RETACY_NF        30:1 - 30:,           
       RETSCOSTRMTH_NF  31:1 - 31:EN,         
       RETSCOENDMTH_NF  32:1 - 32:EN,         
       RCL_NF           33:1 - 33:,           
       RETCUR_CF        34:1 - 34:,           
       RETAMT_M         35:1 - 35:EN 15/3,    
       PLC_NT           36:1 - 36:,           
       RTO_NF           37:1 - 37:,           
       INT_NF           38:1 - 38:,           
       RETPAY_NF        39:1 - 39:,           
       RETKEY_CF        40:1 - 40:,           
       RETINTAMT_M      41:1 - 41:EN 15/3,    
       ACMTRSL2_NT      42:1 - 42:,              
       ACMAMT_M         43:1 - 43:EN 15/3,    
       ACMCUR_CF        44:1 - 44:,           
       PRS_CF 		      45:1 - 45:,           
       SEG_NF 		      46:1 - 46:,           
       LOB_CF 		      47:1 - 47:,           
       NAT_CF 		      48:1 - 48:,           
       TYP_CT 		      49:1 - 49:,           
       PATTYP_CT        50:1 - 50:,           
       SEGLOB_CF        51:1 - 51:,           
       ACMTRSL3_NT      52:1 - 52:,           
       TRNTYP_CT        53:1 - 53:EN, 	       
       TRSTYP_NT        54:1 - 54:EN, 	       
       TRSPFX_CF        55:1 - 55:EN                            
/KEYS   
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,        
        RETCTR_NF,
        RETEND_NT,
        RTY_NF,
        RETUW_NT,
        RETSEC_NF,
        TRNCOD_CF,
        PLC_NT,        
        ACMTRSL3_NT,
        RETCUR_CF,
        LINETYP_NF,
        CLOSTYP_NF,
        TRNTYP_CT,   
        TRSTYP_NT,
        TRSPFX_CF 
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M
/CONDITION ASS_RET  	( "1"  CT TRNCOD1_CF) 
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC if ASS_RET then AMT_M else RETAMT_M
/CONDITION LINETYP_VIDE (LINETYP_NF="OO")
/CONDITION CLOSTYP_VIDE (CLOSTYP_NF="A")
/CONDITION MONTANT_DIFF_ASS_ZERO  (AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0 OR ACMAMT_M != 0) AND (LINETYP_NF != "OO") AND (CLOSTYP_NF !="A") AND (TYP_CT ="A")
/CONDITION MONTANT_DIFF_RET_ZERO  (AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0 OR ACMAMT_M != 0) AND (LINETYP_NF != "OO") AND (CLOSTYP_NF !="A") AND (TYP_CT ="R")
/DERIVEDFIELD LINETYP_NF_NEW if LINETYP_VIDE then "~" else LINETYP_NF
/DERIVEDFIELD CLOSTYP_NF_NEW if CLOSTYP_VIDE then "~" else CLOSTYP_NF
/DERIVEDFIELD STRVIDE "~"
/OUTFILE ${SORT_O}
/INCLUDE MONTANT_DIFF_RET_ZERO
/REFORMAT    
				  SSD_CF          
         ,ESB_CF          
         ,BALSHEY_NF      
         ,BALSHRMTH_NF    
         ,BALSHRDAY_NF    
         ,TRNCOD_CF              
         ,DBLTRNCOD_CF    
         ,CTR_NF          
         ,END_NT          
         ,SEC_NF          
         ,UWY_NF          
         ,UW_NT           
         ,LINETYP_NF      
         ,ACY_NF          
         ,SCOSTRMTH_NF    
         ,SCOENDMTH_NF    
         ,CLOSTYP_NF      
         ,CUR_CF          
         ,AMT_MC           
         ,CED_NF          
         ,BRK_NF          
         ,PAY_NF          
         ,KEY_NF          
         ,RETCTR_NF       
         ,RETEND_NT       
         ,RETSEC_NF       
         ,RTY_NF          
         ,RETUW_NT        
         ,RETOCCYEA_NF    
         ,RETACY_NF       
         ,RETSCOSTRMTH_NF    				  
         ,RETSCOENDMTH_NF 
         ,RCL_NF          
         ,RETCUR_CF          
         ,RETAMT_MC        
         ,PLC_NT          
         ,RTO_NF          
         ,INT_NF          
         ,RETPAY_NF       
         ,RETKEY_CF       
         ,RETINTAMT_MC     
         ,ACMTRSL2_NT                
         ,ACMAMT_MC        
         ,RETCUR_CF      
         ,PRS_CF 		      
         ,SEG_NF 		      
         ,LOB_CF 		      
         ,NAT_CF 		      
         ,TYP_CT 		      
         ,PATTYP_CT       
         ,SEGLOB_CF       
         ,ACMTRSL3_NT     
         ,TRNTYP_CT       
         ,TRSTYP_NT       
         ,TRSPFX_CF               
/OUTFILE ${SORT_O2}
/INCLUDE MONTANT_DIFF_ASS_ZERO
/REFORMAT    
				  SSD_CF          
         ,ESB_CF          
         ,BALSHEY_NF      
         ,BALSHRMTH_NF    
         ,BALSHRDAY_NF    
         ,TRNCOD_CF              
         ,DBLTRNCOD_CF    
         ,CTR_NF          
         ,END_NT          
         ,SEC_NF          
         ,UWY_NF          
         ,UW_NT           
         ,LINETYP_NF      
         ,ACY_NF          
         ,SCOSTRMTH_NF    
         ,SCOENDMTH_NF    
         ,CLOSTYP_NF      
         ,CUR_CF          
         ,AMT_MC           
         ,CED_NF          
         ,BRK_NF          
         ,PAY_NF          
         ,KEY_NF          
         ,RETCTR_NF       
         ,RETEND_NT       
         ,RETSEC_NF       
         ,RTY_NF          
         ,RETUW_NT        
         ,RETOCCYEA_NF    
         ,RETACY_NF       
         ,RETSCOSTRMTH_NF    				  
         ,RETSCOENDMTH_NF 
         ,RCL_NF          
         ,RETCUR_CF          
         ,RETAMT_MC        
         ,PLC_NT          
         ,RTO_NF          
         ,INT_NF          
         ,RETPAY_NF       
         ,RETKEY_CF       
         ,RETINTAMT_MC     
         ,ACMTRSL2_NT                
         ,ACMAMT_MC        
         ,CUR_CF       
         ,PRS_CF 		      
         ,SEG_NF 		      
         ,LOB_CF 		      
         ,NAT_CF 		      
         ,TYP_CT 		      
         ,PATTYP_CT       
         ,SEGLOB_CF       
         ,ACMTRSL3_NT     
         ,TRNTYP_CT       
         ,TRSTYP_NT       
         ,TRSPFX_CF     
exit
EOF
SORT          

#NSTEP=${NJOB}_87 Jointure DCUM_RETRO avec ASSUMED_PERICASE Cle CSUE Uniquement
# En Retro MVT Et Pericase Assumed, jointure externe  gauche

NSTEP=${NJOB}_87
# Join and sort PERICASE Assume DLCUMGTAAR_RETRO_P by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="PERICASE Assumed DLCUMGTAAR_Retro P Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_85_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
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
        FIELD_49_73_F1    	49:1 - 73:,
        CTR_NF_F2 			 	  3:1 -  3:, 
        END_NT_F2           4:1 -  4:,                  
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:,           
        LOB_CF_F2 		      38:1 - 38:, 				
				NAT_CF_F2   		   	49:1 - 49:,
        SEG_NF_F2 		      80:1 - 80:				       		          
/JOINKEYS CTR_NF_F1,
					END_NT_F1,
          SEC_NF_F1,
          UWY_NF_F1,
          UW_NT_F1  
/INFILE ${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE.dat 1000 1 "~"                 
/JOINKEYS CTR_NF_F2,
          END_NT_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2
/JOIN UNPAIRED LEFTSIDE                               
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FIELD_1_45_F1, RIGHTSIDE: SEG_NF_F2, RIGHTSIDE: LOB_CF_F2, RIGHTSIDE: NAT_CF_F2, LEFTSIDE: FIELD_49_73_F1
exit
EOF
SORT 



NSTEP=${NJOB}_90
# SORT UNIQUE of AGGREGATION file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of AGGREGATION ITD file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_85_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
SORT_I="${DFILT}/${NJOB}_87_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		1:1 - 72:
/KEYS   ALL_F1
/SUM 
/OUTFILE ${SORT_O}
exit
EOF
SORT 


# JOINTURE 1 A 1 IRDPERICASE /JOIN UNPAIRED LEFTSIDE ==> /JOIN UNPAIRED  RIGHTSIDE 


NSTEP=${NJOB}_95
# Join and sort Retro PERICASE  DLCUMGTAAR by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="PERICASE RETRO DLCUMGTAAR Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF_F1        24:1 - 24:,  
        RETEND_NT_F1        25:1 - 25:EN,
        RETSEC_NF_F1        26:1 - 26:,
        RTY_NF_F1           27:1 - 27:,
        RETUW_NT_F1         28:1 - 28:,
        FIELD_1_35_F1       1:1 - 35:, 
        PLC_NT_F1           36:1 - 36:,
        RTO_NF_F1           37:1 - 37:,
        FILED_38_46_F1      38:1 - 46:,        
        LOB_CF_F1 		      47:1 - 47:,          
        NAT_CF_F1           48:1 - 48:,  
        TYP_CT_F1           49:1 - 49:,                                             
        FIELD_49_73_F1    	49:1 - 73:,
        CTR_NF_F2 			 	  3:1 -  3:,                   
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:,
				LOB_CF_F2   		   	38:1 - 38:, 				
				NAT_CF_F2   		   	49:1 - 49:       		          
/JOINKEYS RETCTR_NF_F1,
          RETSEC_NF_F1,
          RTY_NF_F1,
          RETUW_NT_F1  
/INFILE ${DFILT}/${NJOB}_05_${IB}_SORT_IRDPERICASE.dat 1000 1 "~"                 
/JOINKEYS CTR_NF_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2
/JOIN UNPAIRED  RIGHTSIDE            
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FIELD_1_35_F1, LEFTSIDE: PLC_NT_F1, LEFTSIDE: RTO_NF_F1, LEFTSIDE: FILED_38_46_F1, RIGHTSIDE: LOB_CF_F2, RIGHTSIDE: NAT_CF_F2, LEFTSIDE: FIELD_49_73_F1
exit
EOF
SORT


## [09] ANO PLC_NT et RTO NON renseignes : Ajout TRI INTERMEDIAIRE du Fichier Retro

NSTEP=${NJOB}_97
# SORT SORT RETRO FILE 
#------------------------------------------------------------------------------
LIBEL="Sort Of MVT RETRO file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS        
       CTR_NF            8:1 -  8:,           
       END_NT            9:1 -  9:EN,         
       SEC_NF           10:1 - 10:EN,         
       UWY_NF           11:1 - 11:,           
       UW_NT            12:1 - 12:EN,                   
       CUR_CF           18:1 - 18:,                       
       RETCTR_NF        24:1 - 24:,           
       RETEND_NT        25:1 - 25:EN,         
       RETSEC_NF        26:1 - 26:EN,         
       RTY_NF           27:1 - 27:,           
       RETUW_NT         28:1 - 28:EN,                  
       RETCUR_CF        34:1 - 34:,              
       PLC_NT           36:1 - 36:          
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
        CUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT



##[16]


NSTEP=${NJOB}_98
# SORT  RETRO FILE 
#------------------------------------------------------------------------------
LIBEL="Sort Of MVT RETRO file AND Remove PLC and RTO ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_97_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS        
       CTR_NF            8:1 -  8:,           
       END_NT            9:1 -  9:EN,         
       SEC_NF           10:1 - 10:EN,         
       UWY_NF           11:1 - 11:,           
       UW_NT            12:1 - 12:EN,                   
       CUR_CF           18:1 - 18:,                       
       RETCTR_NF        24:1 - 24:,           
       RETEND_NT        25:1 - 25:EN,         
       RETSEC_NF        26:1 - 26:EN,         
       RTY_NF           27:1 - 27:,           
       RETUW_NT         28:1 - 28:EN,                  
       RETCUR_CF        34:1 - 34:, 
       FILLER_1_35       1:1 - 35:,                    
       PLC_NT           36:1 - 36:,
       RTO_NF           37:1 - 37:,
       FILLER_38_71     38:1 - 71:                                         
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        RETEND_NT,
        RETUW_NT,
        RETCUR_CF,
        PLC_NT,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF
/DERIVEDFIELD PLUS_2_CHAMPS "~~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER_1_35, PLUS_2_CHAMPS, FILLER_38_71
exit
EOF
SORT



NSTEP=${NJOB}_99
#Accumulation of acceptation and retrocession amount by ACMTRS_NT
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES Accumulation of retrocession amount by ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_98_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat  2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat  2000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD8_CF        6:8 -  6:8,
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
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 18:,
        FILLER2          20:1 - 34:,
        FILLER3          36:1 - 40:,
        FILLER4          42:1 - 56:
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        PLC_NT,
        RETEND_NT,
        RETUW_NT,
        RETCUR_CF,
        RTO_NF,
        TRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION MONTANT ( AMT_MC !=0 OR RETAMT_MC !=0 )
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
/REFORMAT FILLER1,AMT_MC,FILLER2,RETAMT_MC,FILLER3,RETINTAMT_MC,FILLER4
exit
EOF
SORT


#[16]


NSTEP=${NJOB}_100
# SORT UNIQUE of AGGREGATION file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of AGGREGATION ITD Assumed file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_85_${IB}_SORT_DLCUMGTAAR_MVT_ASS_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_ASS_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		1:1 - 72:
/KEYS   ALL_F1
/SUM 
/OUTFILE ${SORT_O}
exit
EOF
SORT

# JOINTURE 1 A 1 /JOIN UNPAIRED LEFTSIDE
# En Assumed MVT Et Pericase Assumed, jointure externe Droite 

NSTEP=${NJOB}_105
# Join and sort PERICASE Assume DLCUMGTAAR by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="PERICASE Assumed DLCUMGTAAR Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_SORT_DLCUMGTAAR_MVT_ASS_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_ASS_O.dat 1000 1"
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
        FIELD_49_73_F1    	49:1 - 73:,
        CTR_NF_F2 			 	  3:1 -  3:, 
        END_NT_F2           4:1 -  4:,                  
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:,           
        LOB_CF_F2 		      38:1 - 38:, 				
				NAT_CF_F2   		   	49:1 - 49:,
        SEG_NF_F2 		      80:1 - 80:				       		          
/JOINKEYS CTR_NF_F1,
					END_NT_F1,
          SEC_NF_F1,
          UWY_NF_F1,
          UW_NT_F1  
/INFILE ${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE.dat 1000 1 "~"                 
/JOINKEYS CTR_NF_F2,
          END_NT_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2
/JOIN UNPAIRED RIGHTSIDE                            
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FIELD_1_45_F1, RIGHTSIDE: SEG_NF_F2, RIGHTSIDE: LOB_CF_F2, RIGHTSIDE: NAT_CF_F2, LEFTSIDE: FIELD_49_73_F1
exit
EOF
SORT 

# [09] export ${PRG}_I2=${DFILT}/${NJOB}_95_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat

NSTEP=${NJOB}_107
# Affectation par placement
#-----------------------------------------------------------------------------
LIBEL=" AGREGATES retro Affectation MVT par placement"
PRG=ESTC1052
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_FPLATXCUMALL.dat
export ${PRG}_I2=${DFILT}/${NJOB}_99_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLCUMGTAAR_MVT_RET_O.dat
#SORT_O=${EST_DLCUMGTAAR_MVT} OVERWRITE 
EXECPRG       



#[06]

NSTEP=${NJOB}_109
#-----------------------------------------------------------------------------
LIBEL="EVOL ACMAMT_T MAJ DLCUMGTAAR_MVT_RET..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_107_${IB}_ESTC1052_DLCUMGTAAR_MVT_RET_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS        
       FIELD_0_34        1:1 - 34:,             
       RETAMT_M         35:1 - 35:EN 15/3,               
       FIELD_36_42      36:1 - 42:,                  
       ACMAMT_M         43:1 - 43:EN 15/3,
       FIELD_44_73      44:1 - 73:,
       ALL_1_73          1:1 - 73:                          
/KEYS   
        ALL_1_73 
/DERIVEDFIELD ACMAMT_MC RETAMT_M
/OUTFILE ${SORT_O}
/REFORMAT               
         FIELD_0_34          
         ,RETAMT_M                 
         ,FIELD_36_42                   
         ,ACMAMT_MC
         ,FIELD_44_73                     
exit
EOF
SORT

#SORT_O="/scor/home/u006596/martin/perm/M_DLCUMGTAAR_MVT 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_MVT_O.dat 1000 1"
#SORT_I="${DFILT}/${NJOB}_95_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 1000 1"

NSTEP=${NJOB}_112
# SORT UNIQUE of AGGREGATION MVT file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of AGGREGATION MVT file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_109_${IB}_SORT_DLCUMGTAAR_MVT_RET_O.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_105_${IB}_SORT_DLCUMGTAAR_MVT_ASS_O.dat 2000 1"
SORT_O="${EST_DLCUMGTAAR_MVT} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		 1:1 - 72:,
				LOB_CF    		47:1 - 47:
/KEYS   ALL_F1
/CONDITION LOB_P_AND_C (LOB_CF != '30' AND LOB_CF != '31')
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE LOB_P_AND_C
exit
EOF
SORT



##############################################################################
################ GENERATION OF ITD FILE  #####################################
##############################################################################

# [04] [07] [14]

#/DERIVEDFIELD ACMAMT_MC    RETAMT_M COMPRESS
#[012]
NSTEP=${NJOB}_120
touch ${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTA_O.dat
#-----------------------------------------------------------------------------
LIBEL="ARCSTATGTA AGREGATES ESPD3800_FTECLEDASO_I4I ESPD3800_FTECLEDASII Merge and sort files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
#	SORT_I="${DFILT}/${NJOB}_65_${IB}_SORT_FTECLEDASO_I4I.dat 1000 1"      # Tout IFRS4 jusqu’au 3T2020 + Tout EBS jusqu’au 2T/2020 + les annulations EBS sur 3T/2020 ; 
	SORT_I="${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDASII.dat 1000 1"        # Tout le trimestre EBS 3T/2020 en cours de traitement
#if [ ${ICLODAT_M} != 12 ] 
#then
#	SORT_I3="${DFILT}/${NJOB}_60_${IB}_SORT_ARCSTATGTAR_O.dat 1000 1"      # les MVTS du 4T (mois 12) ne sont pas pris car présents dans ESPD3800_FTECLEDASO_I4I
#fi
SORT_I2="${DFILT}/${NJOB}_75_${IB}_SORT_DLREGTAR_DACI17.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_O.dat 1000 1" 
#SORT_O="${EST_DLCUMGTAAR_ITD} 1000 1"   
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,       
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        LINETYP_NF       13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLOSTYP_NF       17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRSL2_NT      42:1 - 42:,     
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
				PRS_CF 		       45:1 - 45:,
				SEG_NF 		       46:1 - 46:,
				NAT_CF		       47:1 - 47:,
				LOB_CF 		       48:1 - 48:,
				TYP_CT 		       49:1 - 49:,
				PATTYP_CT        50:1 - 50:,
				SEGLOB_CF        51:1 - 51:,
				ACMTRSL3_NT      52:1 - 52:, 
				TRNTYP_CT        53:1 - 53:EN, 	
				TRSTYP_NT        54:1 - 54:EN, 	
				TRSPFX_CF        55:1 - 55:EN          
/KEYS   
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,        
        RETCTR_NF,
        RETEND_NT,
        RTY_NF,
        RETUW_NT,
        RETSEC_NF,
        TRNCOD_CF,	         
        PLC_NT,        
        ACMTRSL3_NT,
        RETCUR_CF,
        LINETYP_NF,
        CLOSTYP_NF,
        TRNTYP_CT,   
        TRSTYP_NT,
        TRSPFX_CF       
/CONDITION PERIODE_ITD (  ( ( (BALSHEY_NF < ${ICLODAT_A} ) OR ( (BALSHEY_NF = ${ICLODAT_A} ) AND (BALSHRMTH_NF <= ${ICLODAT_M})  ) )  AND (LOB_CF != "30" AND LOB_CF != "31") AND (ACMTRSL3_NT != "1030") AND (ACMTRSL2_NT != "303") AND (ACMTRSL2_NT != "307")
                              AND ( (TRSTYP_NT = 1) OR (TRSTYP_NT = 3)  OR ( (TRSTYP_NT = 0)  AND  ( TRNTYP_CT = 150))  OR ( (TRSTYP_NT = 2)  AND  ( TRNTYP_CT <= 100) AND (ACMTRSL3_NT = "1020"  OR ACMTRSL3_NT = "2043" OR ACMTRSL3_NT = "1023" OR ACMTRSL3_NT =  "2020" OR ACMTRSL3_NT = "2022" OR ACMTRSL3_NT = "2021" OR ACMTRSL3_NT = "3020" OR ACMTRSL3_NT = "3021" OR ACMTRSL3_NT = "3022" OR ACMTRSL3_NT = "3080"  ) ) )   )  
                       OR ( (BALSHEY_NF = ${ICLODAT_A} ) AND (BALSHRMTH_NF <= ${ICLODAT_M})   AND ( (TRSTYP_NT = 1) OR (TRSTYP_NT = 3) )  AND (LOB_CF != "30" AND LOB_CF != "31") AND ( (ACMTRSL3_NT = "1030")  OR  (ACMTRSL2_NT = "303")  OR  (ACMTRSL2_NT = "307")  OR  (ACMTRSL2_NT = "203") ) ) 
                       )                                                          
/CONDITION AE_EST  		( ( "12"  CT TRNCOD1_CF) AND ("4E" CT TRNCOD2_CF) AND ("0" NC TRNCOD8_CF) )                                                                     
/CONDITION AE_ACT  		( ( "12"  CT TRNCOD1_CF) AND ("4" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  ) 
/CONDITION ACTUAL  		( ( "12"  CT TRNCOD1_CF) AND ("1" CT TRNCOD2_CF) AND ("0" CT TRNCOD8_CF)  )  
/CONDITION ESTIMATES  ( ( "12"  CT TRNCOD1_CF) AND ("1A" CT TRNCOD2_CF) AND ( "0" NC TRNCOD8_CF ) ) 
/CONDITION EBS        ( ( "12" CT TRNCOD1_CF ) AND ("AE" CT TRNCOD2_CF)  AND (TRNTYP_CT = 100) )
/CONDITION IFRS4      ( ( "12" CT TRNCOD1_CF ) AND ("14" CT TRNCOD2_CF)  AND ( TRNTYP_CT < 100) ) 
/CONDITION IFRS17      ( ( "12" CT TRNCOD1_CF ) AND ("1A" CT TRNCOD2_CF)  AND ( TRNTYP_CT = 150) )  
/CONDITION ASS_RET  	( "1"  CT TRNCOD1_CF)  
/DERIVEDFIELD LINETYP_NF_NEW if AE_EST then "AE~" else if AE_ACT then "AA~" else if ACTUAL then "AC~" else if ESTIMATES then "ES~" else "OO~"
/DERIVEDFIELD CLOSTYP_NF_NEW if EBS then "E~" else if IFRS4 then "I~" else if IFRS17 then "G~" else "A~"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD TYP_CT_NEW if ASS_RET then "A~" else "R~" 
/DERIVEDFIELD STRVIDE "~"
/DERIVEDFIELD PLUS_20_CHAMPS 20"~"
/DERIVEDFIELD ACY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD SCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD SCOENDMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD RETINTAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC if ASS_RET then AMT_M else RETAMT_M
/DERIVEDFIELD ACMCUR_CF_NEW if ASS_RET then CUR_CF else RETCUR_CF
/OUTFILE ${SORT_O}
/INCLUDE PERIODE_ITD
/REFORMAT 
         SSD_CF          
         ,ESB_CF          
         ,BALSHEY_NF_NEW      
         ,BALSHRMTH_NF_NEW    
         ,BALSHRDAY_NF_NEW    
         ,TRNCOD_CF            
         ,DBLTRNCOD_CF    
         ,CTR_NF          
         ,END_NT          
         ,SEC_NF          
         ,UWY_NF          
         ,UW_NT           
         ,LINETYP_NF_NEW       
         ,ACY_NF_NEW          
         ,SCOSTRMTH_NF_NEW    
         ,SCOENDMTH_NF_NEW    
         ,CLOSTYP_NF_NEW          
         ,CUR_CF          
         ,AMT_M           
         ,CED_NF          
         ,BRK_NF          
         ,PAY_NF          
         ,KEY_NF          
         ,RETCTR_NF       
         ,RETEND_NT       
         ,RETSEC_NF       
         ,RTY_NF          
         ,RETUW_NT        
         ,RETOCCYEA_NF    
         ,ACY_NF_NEW       
         ,SCOSTRMTH_NF_NEW 
         ,SCOENDMTH_NF_NEW 
         ,RCL_NF          
         ,RETCUR_CF       
         ,RETAMT_M        
         ,PLC_NT          
         ,RTO_NF          
         ,INT_NF          
         ,RETPAY_NF       
         ,RETKEY_CF       
         ,RETINTAMT_MC
         ,ACMTRSL2_NT    
         ,ACMAMT_MC    
         ,ACMCUR_CF_NEW    
         ,PRS_CF 		  
         ,STRVIDE 		  
         ,STRVIDE 		  
         ,STRVIDE 		  
         ,TYP_CT_NEW 		  
         ,STRVIDE    
         ,STRVIDE    
         ,ACMTRSL3_NT
         ,TRNTYP_CT 
         ,TRSTYP_NT
				 ,TRSPFX_CF 
         ,STRVIDE				 
         ,PLUS_20_CHAMPS					                                     
exit
EOF
SORT

#[012]
NSTEP=${NJOB}_130
# SORT UNIQUE of AGGREGATION file ITD FILE
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of AGGREGATION ITD file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_SORT_DLCUMGTAAR_ITD_O.dat 1000 1"
SORT_I2="${ESF_ARCSTATGTA_AR_ACTUAL_SUM} 1000 1" 
SORT_I3="${ESF_FTECLEDA_I4I_SUM} 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_ASS_O.dat 1000 1"
#SORT_O="${EST_DLCUMGTAAR_ITD} 1000 1" 
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
       SSD_CF            1:1 -  1:EN,         
       ESB_CF            2:1 -  2:EN,         
       BALSHEY_NF        3:1 -  3:EN,         
       BALSHRMTH_NF      4:1 -  4:EN,         
       BALSHRDAY_NF      5:1 -  5:EN,         
       TRNCOD_CF         6:1 -  6:,           
       TRNCOD1_CF        6:1 -  6:1,          
       TRNCOD2_CF        6:2 -  6:2,          
       TRNCOD3_CF        6:3 -  6:6,          
       TRNCOD34_CF       6:3 -  6:4,          
       TRNCOD4_CF        6:3 -  6:7,          
       TRNCOD8_CF        6:8 -  6:8,          
       DBLTRNCOD_CF      7:1 -  7:,           
       CTR_NF            8:1 -  8:,           
       END_NT            9:1 -  9:EN,         
       SEC_NF           10:1 - 10:EN,         
       UWY_NF           11:1 - 11:,           
       UW_NT            12:1 - 12:EN,         
       LINETYP_NF       13:1 - 13:,           
       ACY_NF           14:1 - 14:,           
       SCOSTRMTH_NF     15:1 - 15:EN,         
       SCOENDMTH_NF     16:1 - 16:EN,         
       CLOSTYP_NF       17:1 - 17:,           
       CUR_CF           18:1 - 18:,           
       AMT_M            19:1 - 19:EN 15/3,    
       CED_NF           20:1 - 20:,           
       BRK_NF           21:1 - 21:,           
       PAY_NF           22:1 - 22:,           
       KEY_NF           23:1 - 23:,           
       RETCTR_NF        24:1 - 24:,           
       RETEND_NT        25:1 - 25:EN,         
       RETSEC_NF        26:1 - 26:EN,         
       RTY_NF           27:1 - 27:,           
       RETUW_NT         28:1 - 28:EN,         
       RETOCCYEA_NF     29:1 - 29:,           
       RETACY_NF        30:1 - 30:,           
       RETSCOSTRMTH_NF  31:1 - 31:EN,         
       RETSCOENDMTH_NF  32:1 - 32:EN,         
       RCL_NF           33:1 - 33:,           
       RETCUR_CF        34:1 - 34:,           
       RETAMT_M         35:1 - 35:EN 15/3,    
       PLC_NT           36:1 - 36:,           
       RTO_NF           37:1 - 37:,           
       INT_NF           38:1 - 38:,           
       RETPAY_NF        39:1 - 39:,           
       RETKEY_CF        40:1 - 40:,           
       RETINTAMT_M      41:1 - 41:EN 15/3,    
       ACMTRSL2_NT      42:1 - 42:,                 
       ACMAMT_M         43:1 - 43:EN 15/3,    
       ACMCUR_CF        44:1 - 44:,           
       PRS_CF 		      45:1 - 45:,           
       SEG_NF 		      46:1 - 46:,           
       LOB_CF 		      47:1 - 47:,           
       NAT_CF 		      48:1 - 48:,           
       TYP_CT 		      49:1 - 49:,           
       PATTYP_CT        50:1 - 50:,           
       SEGLOB_CF        51:1 - 51:,           
       ACMTRSL3_NT      52:1 - 52:,           
       TRNTYP_CT        53:1 - 53:EN, 	       
       TRSTYP_NT        54:1 - 54:EN, 	       
       TRSPFX_CF        55:1 - 55:EN                            
/KEYS   
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF,        
        RETCTR_NF,
        RETEND_NT,
        RTY_NF,
        RETUW_NT,
        RETSEC_NF,
        TRNCOD_CF,
        PLC_NT,        
        ACMTRSL3_NT,
        RETCUR_CF,
        LINETYP_NF,
        CLOSTYP_NF,
        TRNTYP_CT,   
        TRSTYP_NT,
        TRSPFX_CF 
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M
/CONDITION ASS_RET  	( "1"  CT TRNCOD1_CF) 
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC if ASS_RET then AMT_M else RETAMT_M
/CONDITION LINETYP_VIDE (LINETYP_NF="OO")
/CONDITION CLOSTYP_VIDE (CLOSTYP_NF="A")
/CONDITION MONTANT_DIFF_ASS_ZERO  (AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0 OR ACMAMT_M != 0) AND (LINETYP_NF != "OO") AND (CLOSTYP_NF !="A") AND (TYP_CT ="A") AND (LOB_CF != "30" AND LOB_CF != "31")
/CONDITION MONTANT_DIFF_RET_ZERO  (AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0 OR ACMAMT_M != 0) AND (LINETYP_NF != "OO") AND (CLOSTYP_NF !="A") AND (TYP_CT ="R") AND (LOB_CF != "30" AND LOB_CF != "31")
/DERIVEDFIELD LINETYP_NF_NEW if LINETYP_VIDE then "~" else LINETYP_NF
/DERIVEDFIELD CLOSTYP_NF_NEW if CLOSTYP_VIDE then "~" else CLOSTYP_NF
/DERIVEDFIELD STRVIDE "~"
/OUTFILE ${SORT_O}
/INCLUDE MONTANT_DIFF_RET_ZERO
/REFORMAT    
				  SSD_CF          
         ,ESB_CF          
         ,BALSHEY_NF      
         ,BALSHRMTH_NF    
         ,BALSHRDAY_NF    
         ,TRNCOD_CF              
         ,DBLTRNCOD_CF    
         ,CTR_NF          
         ,END_NT          
         ,SEC_NF          
         ,UWY_NF          
         ,UW_NT           
         ,LINETYP_NF      
         ,ACY_NF          
         ,SCOSTRMTH_NF    
         ,SCOENDMTH_NF    
         ,CLOSTYP_NF      
         ,CUR_CF          
         ,AMT_MC           
         ,CED_NF          
         ,BRK_NF          
         ,PAY_NF          
         ,KEY_NF          
         ,RETCTR_NF       
         ,RETEND_NT       
         ,RETSEC_NF       
         ,RTY_NF          
         ,RETUW_NT        
         ,RETOCCYEA_NF    
         ,RETACY_NF       
         ,RETSCOSTRMTH_NF    				  
         ,RETSCOENDMTH_NF 
         ,RCL_NF          
         ,RETCUR_CF          
         ,RETAMT_MC        
         ,PLC_NT          
         ,RTO_NF          
         ,INT_NF          
         ,RETPAY_NF       
         ,RETKEY_CF       
         ,RETINTAMT_MC     
         ,ACMTRSL2_NT     
         ,ACMAMT_MC        
         ,RETCUR_CF       
         ,PRS_CF 		      
         ,SEG_NF 		      
         ,LOB_CF 		      
         ,NAT_CF 		      
         ,TYP_CT 		      
         ,PATTYP_CT       
         ,SEGLOB_CF       
         ,ACMTRSL3_NT     
         ,TRNTYP_CT       
         ,TRSTYP_NT       
         ,TRSPFX_CF              
/OUTFILE ${SORT_O2}
/INCLUDE MONTANT_DIFF_ASS_ZERO
/REFORMAT    
				  SSD_CF          
         ,ESB_CF          
         ,BALSHEY_NF      
         ,BALSHRMTH_NF    
         ,BALSHRDAY_NF    
         ,TRNCOD_CF              
         ,DBLTRNCOD_CF    
         ,CTR_NF          
         ,END_NT          
         ,SEC_NF          
         ,UWY_NF          
         ,UW_NT           
         ,LINETYP_NF      
         ,ACY_NF          
         ,SCOSTRMTH_NF    
         ,SCOENDMTH_NF    
         ,CLOSTYP_NF      
         ,CUR_CF          
         ,AMT_MC           
         ,CED_NF          
         ,BRK_NF          
         ,PAY_NF          
         ,KEY_NF          
         ,RETCTR_NF       
         ,RETEND_NT       
         ,RETSEC_NF       
         ,RTY_NF          
         ,RETUW_NT        
         ,RETOCCYEA_NF    
         ,RETACY_NF       
         ,RETSCOSTRMTH_NF    				  
         ,RETSCOENDMTH_NF 
         ,RCL_NF          
         ,RETCUR_CF          
         ,RETAMT_MC        
         ,PLC_NT          
         ,RTO_NF          
         ,INT_NF          
         ,RETPAY_NF       
         ,RETKEY_CF       
         ,RETINTAMT_MC     
         ,ACMTRSL2_NT     
         ,ACMAMT_MC        
         ,CUR_CF       
         ,PRS_CF 		      
         ,SEG_NF 		      
         ,LOB_CF 		      
         ,NAT_CF 		      
         ,TYP_CT 		      
         ,PATTYP_CT       
         ,SEGLOB_CF       
         ,ACMTRSL3_NT     
         ,TRNTYP_CT       
         ,TRSTYP_NT       
         ,TRSPFX_CF              
exit
EOF
SORT 

# En Retro Et Pericase Assumed, jointure externe  gauche

NSTEP=${NJOB}_135
# Join and sort PERICASE Assume DLCUMGTAAR_ITD_RETRO_P by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="PERICASE Assumed DLCUMGTAAR_Retro P Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
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
        FIELD_49_73_F1    	49:1 - 73:,
        CTR_NF_F2 			 	  3:1 -  3:, 
        END_NT_F2           4:1 -  4:,                  
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:,           
        LOB_CF_F2 		      38:1 - 38:, 				
				NAT_CF_F2   		   	49:1 - 49:,
        SEG_NF_F2 		      80:1 - 80:				       		          
/JOINKEYS CTR_NF_F1,
					END_NT_F1,
          SEC_NF_F1,
          UWY_NF_F1,
          UW_NT_F1  
/INFILE ${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE.dat 1000 1 "~"                 
/JOINKEYS CTR_NF_F2,
          END_NT_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2
/JOIN UNPAIRED LEFTSIDE                               
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FIELD_1_45_F1, RIGHTSIDE: SEG_NF_F2, RIGHTSIDE: LOB_CF_F2, RIGHTSIDE: NAT_CF_F2, LEFTSIDE: FIELD_49_73_F1
exit
EOF
SORT 



NSTEP=${NJOB}_140
# SORT UNIQUE of AGGREGATION file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of AGGREGATION ITD file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_135_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
#SORT_O="${EST_DLCUMGTAAR_ITD} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		1:1 - 72:
/KEYS   ALL_F1
/SUM 
/OUTFILE ${SORT_O}
exit
EOF
SORT 


# JOINTURE 1 A 1 /JOIN UNPAIRED LEFTSIDE ==> RIGHTSIDE 

NSTEP=${NJOB}_150
# Join and sort Retro PERICASE  DLCUMGTAAR by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="PERICASE RETRO DLCUMGTAAR Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF_F1        24:1 - 24:,  
        RETEND_NT_F1        25:1 - 25:EN,
        RETSEC_NF_F1        26:1 - 26:,
        RTY_NF_F1           27:1 - 27:,
        RETUW_NT_F1         28:1 - 28:,
        FIELD_1_35_F1       1:1 - 35:, 
        PLC_NT_F1           36:1 - 36:,
        RTO_NF_F1           37:1 - 37:,
        FILED_38_46_F1      38:1 - 46:,        
        LOB_CF_F1 		      47:1 - 47:,          
        NAT_CF_F1           48:1 - 48:,  
        TYP_CT_F1           49:1 - 49:,                                             
        FIELD_49_73_F1    	49:1 - 73:,
        CTR_NF_F2 			 	  3:1 -  3:,                   
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:,
				LOB_CF_F2   		   	38:1 - 38:, 				
				NAT_CF_F2   		   	49:1 - 49:       		          
/JOINKEYS RETCTR_NF_F1,
          RETSEC_NF_F1,
          RTY_NF_F1,
          RETUW_NT_F1  
/INFILE ${DFILT}/${NJOB}_05_${IB}_SORT_IRDPERICASE.dat 1000 1 "~"                 
/JOINKEYS CTR_NF_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2
/JOIN UNPAIRED  RIGHTSIDE             
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FIELD_1_35_F1, LEFTSIDE: PLC_NT_F1, LEFTSIDE: RTO_NF_F1, LEFTSIDE: FILED_38_46_F1, RIGHTSIDE: LOB_CF_F2, RIGHTSIDE: NAT_CF_F2, LEFTSIDE: FIELD_49_73_F1
exit
EOF
SORT


## [09] ANO PLC_NT et RTO NON renseignes : Ajout TRI INTERMEDIAIRE du Fichier Retro

NSTEP=${NJOB}_152
# SORT SORT RETRO FILE 
#------------------------------------------------------------------------------
LIBEL="Sort Of ITD RETRO file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_150_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS        
       CTR_NF            8:1 -  8:,           
       END_NT            9:1 -  9:EN,         
       SEC_NF           10:1 - 10:EN,         
       UWY_NF           11:1 - 11:,           
       UW_NT            12:1 - 12:EN,                   
       CUR_CF           18:1 - 18:,                       
       RETCTR_NF        24:1 - 24:,           
       RETEND_NT        25:1 - 25:EN,         
       RETSEC_NF        26:1 - 26:EN,         
       RTY_NF           27:1 - 27:,           
       RETUW_NT         28:1 - 28:EN,                  
       RETCUR_CF        34:1 - 34:,              
       PLC_NT           36:1 - 36:          
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
        CUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT



##[16]


NSTEP=${NJOB}_153
# SORT  RETRO ITD FILE 
#------------------------------------------------------------------------------
LIBEL="Sort Of MVT RETRO file AND Remove PLC and RTO ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_152_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS        
       CTR_NF            8:1 -  8:,           
       END_NT            9:1 -  9:EN,         
       SEC_NF           10:1 - 10:EN,         
       UWY_NF           11:1 - 11:,           
       UW_NT            12:1 - 12:EN,                   
       CUR_CF           18:1 - 18:,                       
       RETCTR_NF        24:1 - 24:,           
       RETEND_NT        25:1 - 25:EN,         
       RETSEC_NF        26:1 - 26:EN,         
       RTY_NF           27:1 - 27:,           
       RETUW_NT         28:1 - 28:EN,                  
       RETCUR_CF        34:1 - 34:, 
       FILLER_1_35       1:1 - 35:,                    
       PLC_NT           36:1 - 36:,
       RTO_NF           37:1 - 37:,
       FILLER_38_71     38:1 - 71:                                         
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        RETEND_NT,
        RETUW_NT,
        RETCUR_CF,
        PLC_NT,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF
/DERIVEDFIELD PLUS_2_CHAMPS "~~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER_1_35, PLUS_2_CHAMPS, FILLER_38_71
exit
EOF
SORT



NSTEP=${NJOB}_154
#Accumulation of acceptation and retrocession amount by ACMTRS_NT
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES Accumulation of retrocession amount by ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_153_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat  2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat  2000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD8_CF        6:8 -  6:8,
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
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 18:,
        FILLER2          20:1 - 34:,
        FILLER3          36:1 - 40:,
        FILLER4          42:1 - 56:
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        PLC_NT,
        RETEND_NT,
        RETUW_NT,
        RETCUR_CF,
        RTO_NF,
        TRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION MONTANT ( AMT_MC !=0 OR RETAMT_MC !=0 )
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
/REFORMAT FILLER1,AMT_MC,FILLER2,RETAMT_MC,FILLER3,RETINTAMT_MC,FILLER4
exit
EOF
SORT


#[16]



# [09] export ${PRG}_I2=${DFILT}/${NJOB}_150_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat

NSTEP=${NJOB}_155
# Affectation par placement
#-----------------------------------------------------------------------------
LIBEL=" AGREGATES retro Affectation ITD par placement"
PRG=ESTC1052
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_FPLATXCUMALL.dat
export ${PRG}_I2=${DFILT}/${NJOB}_154_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLCUMGTAAR_ITD_RET_O.dat
#SORT_O=${EST_DLCUMGTAAR_ITD} OVERWRITE 
EXECPRG

##[16]

NSTEP=${NJOB}_160
# SORT UNIQUE of AGGREGATION file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of AGGREGATION ITD Assumed file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_SORT_DLCUMGTAAR_ITD_ASS_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_ASS_O.dat 1000 1"
#SORT_O="${EST_DLCUMGTAAR_ITD} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		1:1 - 72:
/KEYS   ALL_F1
/SUM 
/OUTFILE ${SORT_O}
exit
EOF
SORT

# JOINTURE 1 A 1 AU LIEU du /JOIN UNPAIRED   LEFTSIDE
# # En Assumed Et Pericase Assumed, jointure externe Droite 

NSTEP=${NJOB}_170
# Join and sort PERICASE Assume DLCUMGTAAR by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="PERICASE Assumed DLCUMGTAAR Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_160_${IB}_SORT_DLCUMGTAAR_ITD_ASS_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_ASS_O.dat 1000 1"
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
        FIELD_49_73_F1    	49:1 - 73:,
        CTR_NF_F2 			 	  3:1 -  3:, 
        END_NT_F2           4:1 -  4:,                  
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:,           
        LOB_CF_F2 		      38:1 - 38:, 				
				NAT_CF_F2   		   	49:1 - 49:,
        SEG_NF_F2 		      80:1 - 80:				       		          
/JOINKEYS CTR_NF_F1,
					END_NT_F1,
          SEC_NF_F1,
          UWY_NF_F1,
          UW_NT_F1  
/INFILE ${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE.dat 1000 1 "~"                 
/JOINKEYS CTR_NF_F2,
          END_NT_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2
/JOIN UNPAIRED RIGHTSIDE                              
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FIELD_1_45_F1, RIGHTSIDE: SEG_NF_F2, RIGHTSIDE: LOB_CF_F2, RIGHTSIDE: NAT_CF_F2, LEFTSIDE: FIELD_49_73_F1
exit
EOF
SORT 



#[06]
NSTEP=${NJOB}_175
#-----------------------------------------------------------------------------
LIBEL="EVOL ACMAMT_T MAJ DLCUMGTAAR_ITD_RET..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_155_${IB}_ESTC1052_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS        
       FIELD_0_34        1:1 - 34:,             
       RETAMT_M         35:1 - 35:EN 15/3,               
       FIELD_36_42      36:1 - 42:,                  
       ACMAMT_M         43:1 - 43:EN 15/3,
       FIELD_44_73      44:1 - 73:,
       ALL_1_73          1:1 - 73:                          
/KEYS   
        ALL_1_73 
/DERIVEDFIELD ACMAMT_MC RETAMT_M
/OUTFILE ${SORT_O}
/REFORMAT               
         FIELD_0_34          
         ,RETAMT_M                 
         ,FIELD_36_42                   
         ,ACMAMT_MC
         ,FIELD_44_73                     
exit
EOF
SORT


##06]SORT_I="${DFILT}/${NJOB}_150_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"


NSTEP=${NJOB}_180
# SORT UNIQUE of AGGREGATION file 
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of AGGREGATION ITD file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_175_${IB}_SORT_DLCUMGTAAR_ITD_RET_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_170_${IB}_SORT_DLCUMGTAAR_ITD_ASS_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAR_ITD_ALL_O.dat 1000 1"
#SORT_O="${EST_DLCUMGTAAR_ITD} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		 1:1 - 72:,
				LOB_CF    		47:1 - 47:
/KEYS   ALL_F1
/CONDITION LOB_P_AND_C (LOB_CF != '30' AND LOB_CF != '31')
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE LOB_P_AND_C
exit
EOF
SORT

NSTEP=${NJOB}_185
# SORT UNIQUE of AGGREGATION file MVT FILE
#------------------------------------------------------------------------------
LIBEL="Current UNIQUE of AGGREGATION ITD file  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_180_${IB}_SORT_DLCUMGTAAR_ITD_ALL_O.dat 1000 1"
SORT_O="${EST_DLCUMGTAAR_ITD} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
       SSD_CF            1:1 -  1:EN,         
       ESB_CF            2:1 -  2:EN,         
       BALSHEY_NF        3:1 -  3:EN,         
       BALSHRMTH_NF      4:1 -  4:EN,         
       BALSHRDAY_NF      5:1 -  5:EN,         
       TRNCOD_CF         6:1 -  6:,           
       TRNCOD1_CF        6:1 -  6:1,          
       TRNCOD2_CF        6:2 -  6:2,          
       TRNCOD3_CF        6:3 -  6:6,          
       TRNCOD34_CF       6:3 -  6:4,          
       TRNCOD4_CF        6:3 -  6:7,          
       TRNCOD8_CF        6:8 -  6:8,          
       DBLTRNCOD_CF      7:1 -  7:,           
       CTR_NF            8:1 -  8:,           
       END_NT            9:1 -  9:EN,         
       SEC_NF           10:1 - 10:EN,         
       UWY_NF           11:1 - 11:,           
       UW_NT            12:1 - 12:EN,         
       LINETYP_NF       13:1 - 13:,           
       ACY_NF           14:1 - 14:,           
       SCOSTRMTH_NF     15:1 - 15:EN,         
       SCOENDMTH_NF     16:1 - 16:EN,         
       CLOSTYP_NF       17:1 - 17:,           
       CUR_CF           18:1 - 18:,           
       AMT_M            19:1 - 19:EN 15/3,    
       CED_NF           20:1 - 20:,           
       BRK_NF           21:1 - 21:,           
       PAY_NF           22:1 - 22:,           
       KEY_NF           23:1 - 23:,           
       RETCTR_NF        24:1 - 24:,           
       RETEND_NT        25:1 - 25:EN,         
       RETSEC_NF        26:1 - 26:EN,         
       RTY_NF           27:1 - 27:,           
       RETUW_NT         28:1 - 28:EN,         
       RETOCCYEA_NF     29:1 - 29:,           
       RETACY_NF        30:1 - 30:,           
       RETSCOSTRMTH_NF  31:1 - 31:EN,         
       RETSCOENDMTH_NF  32:1 - 32:EN,         
       RCL_NF           33:1 - 33:,           
       RETCUR_CF        34:1 - 34:,           
       RETAMT_M         35:1 - 35:EN 15/3,    
       PLC_NT           36:1 - 36:,           
       RTO_NF           37:1 - 37:,           
       INT_NF           38:1 - 38:,           
       RETPAY_NF        39:1 - 39:,           
       RETKEY_CF        40:1 - 40:,           
       RETINTAMT_M      41:1 - 41:EN 15/3,    
       ACMTRSL2_NT      42:1 - 42:,                 
       ACMAMT_M         43:1 - 43:EN 15/3,    
       ACMCUR_CF        44:1 - 44:,           
       PRS_CF 		      45:1 - 45:,           
       SEG_NF 		      46:1 - 46:,           
       LOB_CF 		      47:1 - 47:,           
       NAT_CF 		      48:1 - 48:,           
       TYP_CT 		      49:1 - 49:,           
       PATTYP_CT        50:1 - 50:,           
       SEGLOB_CF        51:1 - 51:,           
       ACMTRSL3_NT      52:1 - 52:,           
       TRNTYP_CT        53:1 - 53:EN, 	       
       TRSTYP_NT        54:1 - 54:EN, 	       
       TRSPFX_CF        55:1 - 55:EN                            
/KEYS   
       SSD_CF      
      ,ESB_CF      
      ,BALSHEY_NF  
      ,BALSHRMTH_NF
      ,BALSHRDAY_NF
      ,TRNCOD_CF   
      ,CTR_NF      
      ,END_NT      
      ,SEC_NF      
      ,UWY_NF      
      ,UW_NT       
      ,LINETYP_NF  
      ,ACY_NF      
      ,SCOSTRMTH_NF
      ,SCOENDMTH_NF
      ,CLOSTYP_NF  
      ,CUR_CF            
      ,CED_NF      
      ,BRK_NF      
      ,PAY_NF      
      ,KEY_NF      
      ,RETCTR_NF   
      ,RETEND_NT   
      ,RETSEC_NF   
      ,RTY_NF      
      ,RETUW_NT    
      ,RETOCCYEA_NF
      ,RETACY_NF   
      ,RETSCOSTRMTH_NF
      ,RETSCOENDMTH_NF
      ,RCL_NF      
      ,RETCUR_CF      
      ,PLC_NT      
      ,RTO_NF      
      ,INT_NF      
      ,RETPAY_NF   
      ,RETKEY_CF   
      ,ACMTRSL2_NT 
      ,ACMCUR_CF   
      ,PRS_CF 		 
      ,SEG_NF 		 
      ,LOB_CF 		 
      ,NAT_CF 		 
      ,TYP_CT 		 
      ,PATTYP_CT   
      ,SEGLOB_CF   
      ,ACMTRSL3_NT 
      ,TRNTYP_CT   
      ,TRSTYP_NT   
      ,TRSPFX_CF                                            
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M
/CONDITION MONTANT_DIFF_ZERO  	(AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0 OR ACMAMT_M != 0)
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS 
/DERIVEDFIELD STRVIDE "~"
/OUTFILE ${SORT_O}
/INCLUDE MONTANT_DIFF_ZERO
/REFORMAT    
				  SSD_CF          
         ,ESB_CF          
         ,BALSHEY_NF      
         ,BALSHRMTH_NF    
         ,BALSHRDAY_NF    
         ,TRNCOD_CF              
         ,DBLTRNCOD_CF    
         ,CTR_NF          
         ,END_NT          
         ,SEC_NF          
         ,UWY_NF          
         ,UW_NT           
         ,LINETYP_NF      
         ,ACY_NF          
         ,SCOSTRMTH_NF    
         ,SCOENDMTH_NF    
         ,CLOSTYP_NF      
         ,CUR_CF          
         ,AMT_MC           
         ,CED_NF          
         ,BRK_NF          
         ,PAY_NF          
         ,KEY_NF          
         ,RETCTR_NF       
         ,RETEND_NT       
         ,RETSEC_NF       
         ,RTY_NF          
         ,RETUW_NT        
         ,RETOCCYEA_NF    
         ,RETACY_NF       
         ,RETSCOSTRMTH_NF    				  
         ,RETSCOENDMTH_NF 
         ,RCL_NF          
         ,RETCUR_CF          
         ,RETAMT_MC        
         ,PLC_NT          
         ,RTO_NF          
         ,INT_NF          
         ,RETPAY_NF       
         ,RETKEY_CF       
         ,RETINTAMT_MC     
         ,ACMTRSL2_NT     
         ,ACMAMT_MC        
         ,ACMCUR_CF       
         ,PRS_CF 		      
         ,SEG_NF 		      
         ,LOB_CF 		      
         ,NAT_CF 		      
         ,TYP_CT 		      
         ,PATTYP_CT       
         ,SEGLOB_CF       
         ,ACMTRSL3_NT     
         ,TRNTYP_CT       
         ,TRSTYP_NT       
         ,TRSPFX_CF                           
exit
EOF
SORT 




JOBEND

