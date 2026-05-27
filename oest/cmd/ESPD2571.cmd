#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                           Future premium and future claim for retro NP contracts
#                           Cree a partir du shell ESID2003
# nom du script SHELL           : ESID2571
# revision                      : 
# date de creation              : 03/10/2018
# auteur                        : MZM
# references des specifications : REQ10.7 et REQ10.8 Future premium and future claim for retro NP contracts
#
#				:spira:70671:Future premium for retro NP contracts  
#				:spira:70782:Future claim for retro NP contracts 
#-----------------------------------------------------------------------------
# description
#   Future premium and future claim for retro NP contracts
#
# Input files
#			IRDPERICASE0            	DFILP
#			FTECLEDR		      	DFILP
#			FPLACEMT0		     	DFILP
#			FBOPRSLNK		 	DFILP
#			FCURQUOT		 	DFILP
#			GTR				DFILP
#
#
# Output files
#     FUTURE_RETRO_EBS     				DFILP   
#     EPO_DLDGTR_E_TRNCODEBS  				DFILP  
#     EPO_DLDGTRCO  					DFILP  
#     EPO_DLDGTRSO  					DFILP 
#     EPO_DLDGTAR_E 					DFILP  
#
#   
# Launch C program  --> Creer le programme ESTC1066.c 
#
# job launched by ESID2570
#
#-----------------------------------------------------------------------------
# historiques des modifications
# 	Modifs
#[001]	29/07/2019  MZM	:spira:80281:add stop rule for retro future premium
#[002]  22/08/2019  MZM :spira:80807:Mutiple placements and retrocessionnaire changes
#[003]  23/08/2019  MZM :spira:80808:UPR transactions missed by future claim calculation program : TRI SANS LE RETCUR SUR LA CLE
#[004]  06/09/2019  MZM :spira:73772:Manage retro contract and merge input to cashflow calculations,
#	Calcul des Future Premium Written Remaining Estimates (2A100112), 
#	Annulation Calcul des Future Premium Written Remaining Estimates (2A100122), 
# 	Future Fixed Commission Written Remaining Estimates (2A120112) 
#	Annulation des Future Fixed Commission Written Remaining Estimates (2A120122)
#[005] 04/10/2019  MZM :spira:81349 REQ 10.7 Future Premium = Net Retro Premium
#[006] 14/10/2019  MZM :spira:80307 
#[007] 13/11/2019  MZM :spira:82508 Retro future premium- Problem with retro future premium exemple : "01N000008" et "01N000065"
#[008] 15/11/2019  MZM :spira:81680 REQ10.7 Retro NP Future Premium Multi Sections Contracts (Cumul des ITD sur la section la plus basse)
#[009] 20/11/2019  MZM :spira:81680 REQ10.7 Retro NP Future Premium Multi Sections Contract (Ajout de la Currency dans le cumul des ITD)
#[010] 13/02/2020  LEL :spira:79102 REQ11.3 Retro NP EXPENSES : Add two copy steps of UPR and ITD temporary files to intermediate files
#[011] 03/03/2020  MZM :spira:79070 Adaptations Future Retro for NP Contracts At Inception
#[012] 18/05/2020  MZM :spira:81349 REQ 10.7 Future Premium = Net Retro Premium : Postes d'ouverture"21101105", terminant par 5 ne doivent pas être pris en compte dans les ITD Estimes
#[013] 04/06/2020  MZM :spira:83691 REQ10.7/10.8 Future Premium and future Claims issue
#[014] 04/06/2020  MZM :spira:83120 REQ10.7/10.8 Future Premium and future Claims issue Multi Currencies : Ajout de la Currency dans la cle de tri
#[015] 05/08/2020  MZM :Spira:86100 REQ 11.07 Inconsistent rule for the different CFs when abs(EGPI=<=1) at init : Ajout de la NORME_CF
#[016] 01/10/2020  JYP :Spira:83609 MicroAOC, move DFILI file into mapping to run many IDF_CT in //
#[017] 05/10/2020  MZM :spira:xxxxx Mise à vide des champs 61, 62, 63, 64 65  en sortie du traitements des FUTURE Retro NP
#[018] 05/10/2020  MZM :spira:89705 EBS - Retro NP - UPR regression Ajout du TRNCOD dans la cle de TRI des UPR
#[019] 30/11/2020  JYP : SPIRA 91125 : new files for EBS OI TL
#[020] 22/12/2020 : M.NAJI : 	. SPIRA 91531 
#							 	. variabilisation du TYPEINV et NORME
# 								. Ajout de l'IDF_CT  préfixé par la norme
#[021] : 10/03/2021 : JYP Spira:94556 manage mode EBS when microAOC
#[022] : 29/03/2021 : JYP Spira:94556 manage mode EBS when microAOC 
#[023] : 17/06/2021 : MZM Spira:97112 : expiry date > closing date" applies only for the calculation of retro future premium 
#                                       and not for the calculation of the retro future claims or any other future item 
#[024] : 07/10/2021 : MZM Spira:97112 :Calcul des Future Claims meme Si RetroNetPremium = 0  
#[025] : 30/06/2023 : MZM Spira:110104 : Remove internal assumed reference on future retro NP 
#-----------------------------------------------------------------------------
#
#=================================================================================================================================
#set -x


# ***************************************************************************************
# ***************************************************************************************

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

# Parameters
TYPEINV=$1
ICLODAT_D=$2

ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`

UWY_MIN=2

MIN_ICLODAT_A=`expr ${ICLODAT_A} - ${UWY_MIN}`

# SSD_CF=00, used for all subsidiaries
SSD_CF=00


if [ "$NORME2" != "" ]  # mode double norme
then
   CLOSING_MODE="$NORME2"
else
   CLOSING_MODE="$NORME_CF"
fi

# Premium Written Remaining Estimates (accounts 1A100112) = min (Premium Estimates ; UPR)
# Commission Written Remaining Estimates (accounts 1A120112) = min (Commission Estimates; DAC)


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> NORME2.....................: ${NORME2}"
ECHO_LOG "#===> CLOSING_MODE ..............: ${CLOSING_MODE}"
ECHO_LOG "#===> IDF_CT.....................: ${IDF_CT}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> CRE_D......................: $CRE_D "
ECHO_LOG "#===> BALSHTYEA_NF...............: $BALSHTYEA_NF "
ECHO_LOG "#===> BALSHEY_NF.................: $ICLODAT_D    " 
ECHO_LOG "#===> ICLODAT_A..................: $ICLODAT_A    " 
ECHO_LOG "#===> ICLODAT_M..................: $ICLODAT_M    " 
ECHO_LOG "#===> ICLODAT_J..................: $ICLODAT_J    " 
ECHO_LOG "#===> MIN_ICLODAT_A..............: $MIN_ICLODAT_A    " 
ECHO_LOG "#===> EST_SORT_CONDITION.........: $EST_SORT_CONDITION    " 
ECHO_LOG "#===> PARM_BATCHUSER.............: $PARM_BATCHUSER    "
ECHO_LOG "#===>     -------- input   ---------"
ECHO_LOG "#===> EPO_FTECLEDR .............: $EPO_FTECLEDR           "
ECHO_LOG "#===> EPO_FTECLEDRSO .............: $EPO_FTECLEDRSO           "
ECHO_LOG "#===> EPO_FTECLEDRCO .............: $EPO_FTECLEDRCO           "
ECHO_LOG "#===> EPO_FBOPRSLNK  .............: $EPO_FBOPRSLNK            "
ECHO_LOG "#===> EST_FCURCVSNI  .............: $EST_FCURCVSNI              "
ECHO_LOG "#===> EST_FCURCVSN   .............: $EST_FCURCVSN              "
ECHO_LOG "#===> EPO_FPLACEMT22 .............: $EPO_FPLACEMT22           "
ECHO_LOG "#===> EPO_FCURQUOT   .............: $EPO_FCURQUOT             "
ECHO_LOG "#===> EPO_IRDPERICASE0............: $EPO_IRDPERICASE0          "
ECHO_LOG "#===> EPO_RETITDPRM_UPR_ACT.......: $EPO_RETITDPRM_UPR_ACT  "
ECHO_LOG "#===> EPO_DLSGTRSII_AE ...........: $EPO_DLSGTRSII_AE "
ECHO_LOG "#===>     -------- output  ---------"
ECHO_LOG "#===> EPO_DLDGTR_E_TRNCODEBS .....: $EPO_DLDGTR_E_TRNCODEBS "
ECHO_LOG "#===> EPO_FUTURE_RETRO_EBS .......: $EPO_FUTURE_RETRO_EBS 	 "
ECHO_LOG "#===> EPO_DLDGTR_E................: $EPO_DLDGTR_E 					 "
ECHO_LOG "#===> EPO_DLDGTRSO................: $EPO_DLDGTRSO  				 "
ECHO_LOG "#===> EPO_DLDGTRCO................: $EPO_DLDGTRCO 					 "
ECHO_LOG "#===> EPO_DLDGTAR_E...............: $EPO_DLDGTAR_E 				"
ECHO_LOG "#===> EPO_DLDGTR_TCODINI .........: $EPO_DLDGTR_TCODINI "
ECHO_LOG "#===> EPO_DLDGTAR_TCODINI ........: $EPO_DLDGTAR_TCODINI "
ECHO_LOG "#===> EST_RETITDPRM ..............: $EST_RETITDPRM "
ECHO_LOG "#===> EST_RETUPR_ESTIME ..........: $EST_RETUPR_ESTIME "
ECHO_LOG "#===> EPO_DLSGTRSII_AE_RETRONP ...: $EPO_DLSGTRSII_AE_RETRONP "
ECHO_LOG "#========================================================================="



# Definir DANS ESID9001 les fichier DLDGTR_E ; DLDGTR_CUMULS_PREC ; DLDGTR_E_TRNCODEBS
#set -x
#set +x


#if [ ${PARM_BATCHUSER} = ubeu ]
#then
#	EST_SORT_CONDITION=$PARAM_EU_SSD_LIST
#fi
#
#if [ ${PARM_BATCHUSER} = ubam ]
#then 
#	EST_SORT_CONDITION=$PARAM_AM_SSD_LIST
#fi
#
#if [ ${PARM_BATCHUSER} = ubas ]
#then
#	EST_SORT_CONDITION=$PARAM_AS_SSD_LIST
#fi

ECHO_LOG "#===> EST_SORT_CONDITION EN COURS..............: $EST_SORT_CONDITION 					 "

if [ ! -f ${EPO_DLDGTRCO} ]
then
	touch ${EPO_DLDGTRCO}
fi


if [ ! -f ${EPO_DLDGTR_E} ]
then
	touch ${EPO_DLDGTR_E}
fi

if [ ! -f ${EPO_DLDGTRSO} ]
then
	touch ${EPO_DLDGTRSO}
fi

if [ ! -f ${EPO_DLDGTRCO} ]
then
	touch ${EPO_DLDGTRCO}
fi



if [ ! -f ${EPO_DLDGTARCO} ]
then
	touch ${EPO_DLDGTARCO}
fi


if [ ! -f ${EPO_DLDGTAR_E} ]
then
	touch ${EPO_DLDGTAR_E}
fi

if [ ! -f ${EPO_DLDGTARSO} ]
then
	touch ${EPO_DLDGTARSO}
fi

if [ ! -f ${EPO_DLDGTARCO} ]
then
	touch ${EPO_DLDGTARCO}
fi


if [ ! -f ${EPO_DLDGTR_TCODINI} ]
then
	touch ${EPO_DLDGTR_TCODINI}
fi

if [ ! -f ${EPO_DLDGTAR_TCODINI} ]
then
	touch ${EPO_DLDGTAR_TCODINI}
fi



NSTEP=${NJOB}_00${TYPEINV}
#------------------------------------------------------------------------------
LIBEL="Sort and Format  EPO_DLDGTRSO LAST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLDGTRSO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTRSO.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
DEBUT         1:1 -  40:,
RETINTAMT_M  88:1 -  88:,
FIN         103:1 - 118:
/COPY
/REFORMAT
DEBUT,RETINTAMT_M,FIN
exit
EOF
SORT


#[006] Prendre le fichier EPO_FTECLEDRSO en entree du calcul des RETRO NP #SORT_I="${EPO_FTECLEDR} 1000 1" 
#[007] Suppression de la clause sur RETRO_ITD_ESTIMATE --   AND (CTR_NF="")
#[012] Postes d'ouverture"21101105", terminant par 5 ne doivent pas être pris en compte dans les ITD Estimes : Ajout du TRNCOD dans la clé
NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Sort of FTECLEDR : only ITD Written Premium Estimate to compute Future Retro for NP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDRSO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ITDESTIMES.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_RETUPR_ESTIME.dat 1000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_SORT_RETRO_COMM_DAC_ESTM.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        ESB_CF           2:1 -  2:EN,
        BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        BALSHRDAY_NF     5:1 -  5:EN,
        TRNCOD_CF        6:1 -  6:,
        TRNCOD1_CF       6:1 -  6:1,
        TRNCOD2_CF       6:2 -  6:2,
        TRNCOD34_CF      6:3 -  6:4,	        
        TRNCOD4_CF       6:1 -  6:4,
        TRNCOD8_CF       6:8 -  6:8,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:EN,
        SEC_NF          10:1 - 10:EN,
        UWY_NF          11:1 - 11:EN,
        UW_NT           12:1 - 12:EN,
        AMT_M           19:1 - 19:EN 15/3,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:EN,
        RETSEC_NF       26:1 - 26:EN,
        RTY_NF          27:1 - 27:EN,
        RETUW_NT        28:1 - 28:EN,
        RETAMT_M        35:1 - 35:EN 15/3,
        RTO_NF          37:1 - 37:,        
        ACMTRS_NT       42:1 - 42:,   
        FILLER          1:1 - 73:
/KEYS   RETCTR_NF
       ,RETSEC_NF
       ,RTY_NF
       ,RTO_NF
       ,RETEND_NT       
       ,RETUW_NT
			 ,TRNCOD_CF       
/CONDITION RETRO_ITD_ESTIMATE ( "2"=TRNCOD1_CF AND BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) AND (TRNCOD2_CF = "1" OR TRNCOD2_CF = "4" OR TRNCOD2_CF = "E" OR TRNCOD2_CF = "A")  AND (TRNCOD34_CF != "41") AND (TRNCOD8_CF !="0") AND (TRNCOD_CF !="21101105")
/CONDITION RETRO_UPR ( "2"=TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) AND (TRNCOD2_CF = "1" OR TRNCOD2_CF = "4" OR TRNCOD2_CF = "E" OR TRNCOD2_CF = "A") AND (TRNCOD34_CF = "41") 
/CONDITION RETRO_COMM_DAC_ESTM ( "2"=TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) AND (TRNCOD2_CF = "1" OR TRNCOD2_CF = "4" OR TRNCOD2_CF = "E" OR TRNCOD2_CF = "A")  
/OUTFILE ${SORT_O}
/INCLUDE RETRO_ITD_ESTIMATE
/REFORMAT FILLER
/OUTFILE ${SORT_O2}
/INCLUDE RETRO_UPR
/REFORMAT FILLER
/OUTFILE ${SORT_O3}
/INCLUDE RETRO_COMM_DAC_ESTM
/REFORMAT FILLER
exit
EOF
SORT



#[023] /CONDITION NPVALID ((RETCTRCAT_CF = "02" OR  RETCTRCAT_CF = "2") AND (CTRSTS_CT = "3" OR  CTRSTS_CT = "03") AND FLAPROPRM_M != 0 )  AND (EXP_D >= $ICLODAT_D) AND ${EST_SORT_CONDITION} 
#(BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= $ICLODAT_M ) AND 
#/CONDITION RETROESTIMATE ("2" CT TRNCOD1_CF AND BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= $ICLODAT_M ) AND (TRNCOD8_CF !="0" AND (TRNCOD2_CF = "1" OR TRNCOD2_CF = "4" OR TRNCOD2_CF = "E" OR TRNCOD2_CF = "A") )

# [024] Supp de cette regle : Les RetroNetPremium qui sont ▒|  0 sont exclus du pericase (FLAPROPRM_M != 0)
# [001] Seuls les contrats dont la date d'expiration >= CLODAT_D : EXP_D >= $ICLODAT_D (EXP_D 28:1 - 28,)
NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Sort of IRDPERICASE : only Retro Mvts NP and Validated "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IRDPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDPERICASE.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS     SSD_CF 1:1 - 1:EN,
						CTR_NF 3:1 - 3:,
            UWY_NF 6:1 - 6:EN,
            SEC_NF 5:1 - 5:EN,
            EXP_D  28:1 - 28:EN,
            CTRSTS_CT 99:1 - 99:,
            RETCTRCAT_CF 107:1 - 107:,
            FLAPROPRM_M  203:1 - 203:EN  15/3
/KEYS CTR_NF, SEC_NF, UWY_NF 
/CONDITION NPVALID ((RETCTRCAT_CF = "02" OR  RETCTRCAT_CF = "2") AND (CTRSTS_CT = "3" OR  CTRSTS_CT = "03") )  AND ${EST_SORT_CONDITION} 
/INCLUDE NPVALID
exit
EOF
SORT

##/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
##/INCLUDE INVENTAIRE


#  GENERATION DES RETRO COMMISSION, DAC PREMIUM, ESTIMES sur PRS 750
NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : GENERATION DES RETRO COMMISSION, DAC PREMIUM, ESTIMES sur PRS 750"
PRG=ESTC1051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${ICLODAT_A}
PRS_CF 750
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_IRDPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_RETRO_COMM_DAC_ESTM.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EPO_FCURQUOT}
export ${PRG}_I5=${EPO_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_RETRO_COMM_DAC_ESTM.dat
EXECPRG



# TRI DU FICHIER Temporaire et regroupement des montants par code ACMTRS 101, 201 .
# ACMTRS_NT = '101' --> PREMIUM ESTIMATE --> 2A100112
# ACMTRS_NT = '201' --> COMMISSIONS ESTIMATE --> 2A120112


NSTEP=${NJOB}_32
#  GENERATION EXTRACTION DES Retro Estimate prm et Commission, DAC
#------------------------------------------------------------------------------
#LIBEL="FUTURES PREPARATION : EXTRACTION DES Retro Estimate prm et Commission, DAC  ACTMTRS 101, 201, 203 PRS 750"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC1051_RETRO_COMM_DAC_ESTM.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_RETRO_PREMIUM_ESTM.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_RETRO_COMMISSION_ESTM.dat 1000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_SORT_RETRO_DAC_ESTM.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN
       ,ESB_CF           2:1 -  2:EN
       ,BALSHEY_NF       3:1 -  3:EN
       ,BALSHRMTH_NF     4:1 -  4:EN
       ,BALSHRDAY_NF     5:1 -  5:EN
       ,TRNCOD_CF        6:1 -  6:
       ,TRNCOD1_CF       6:1 -  6:1
       ,TRNCOD2_CF       6:2 -  6:2
       ,TRNCOD4_CF       6:1 -  6:4
       ,TRNCOD8_CF       6:8 -  6:8
       ,DBLTRNCOD_CF     7:1 -  7:
       ,CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:
       ,SEC_NF          10:1 - 10:EN
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:
       ,OCCYEA_NF       13:1 - 13:
       ,ACY_NF          14:1 - 14:
       ,SCOSTRMTH_NF    15:1 - 15:EN
       ,SCOENDMTH_NF    16:1 - 16:EN
       ,CLM_NF          17:1 - 17:
       ,CUR_CF          18:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,CED_NF          20:1 - 20:
       ,BRK_NF          21:1 - 21:
       ,PAY_NF          22:1 - 22:
       ,KEY_NF          23:1 - 23:
       ,RETCTR_NF       24:1 - 24:
       ,RETEND_NT       25:1 - 25:EN
       ,RETSEC_NF       26:1 - 26:EN
       ,RTY_NF          27:1 - 27:EN
       ,RETUW_NT        28:1 - 28:EN
       ,RETOCCYEA_NF    29:1 - 29:
       ,RETACY_NF       30:1 - 30:
       ,RETSCOSTRMTH_NF 31:1 - 31:EN
       ,RETSCOENDMTH_NF 32:1 - 32:EN
       ,RCL_NF          33:1 - 33:
       ,RETCUR_CF       34:1 - 34:
       ,RETAMT_M        35:1 - 35:EN 15/3
       ,PLC_NT          36:1 - 36:EN
       ,RTO_NF          37:1 - 37:
       ,INT_NF          38:1 - 38:
       ,RETPAY_NF       39:1 - 39:
       ,RETKEY_CF       40:1 - 40:
       ,RETINTAMT_M     41:1 - 41:EN 15/3
       ,ACMTRS_NT       42:1 - 42:
       ,FILLER1         43:1 - 73: 
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      PLC_NT,
      ACMTRS_NT
/CONDITION RETRO_PREMIUM_ESTM    (ACMTRS_NT='101' AND RETAMT_MC != 0)
/CONDITION RETRO_COMMISSION_ESTM   (ACMTRS_NT='201' AND RETAMT_MC != 0)
/CONDITION RETRO_DAC_ESTM   (ACMTRS_NT='203' AND RETAMT_MC != 0)
/CONDITION RETROUPR RETAMT_MC != 0   
/DERIVEDFIELD RETSCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD RETSCOENDMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD TRNCOD_CF_NF_NEW if RETRO_PREMIUM_ESTM then "2A100112~" else if RETRO_COMMISSION_ESTM then  "2A120112~" else if RETRO_DAC_ESTM then "CODED0~" else "ANOFILT~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/SUMMARIZE TOTAL RETAMT_M, TOTAL AMT_M
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF                   
         ,ESB_CF              
         ,BALSHEY_NF          
         ,BALSHRMTH_NF        
         ,BALSHRDAY_NF        
         ,TRNCOD_CF_NF_NEW           
         ,DBLTRNCOD_CF        
         ,CTR_NF              
         ,END_NT              
         ,SEC_NF              
         ,UWY_NF              
         ,UW_NT               
         ,OCCYEA_NF           
         ,ACY_NF              
         ,SCOSTRMTH_NF        
         ,SCOENDMTH_NF        
         ,CLM_NF              
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
         ,RETSCOSTRMTH_NF_NEW 
         ,RETSCOENDMTH_NF_NEW 
         ,RCL_NF              
         ,RETCUR_CF           
         ,RETAMT_MC          
         ,PLC_NT              
         ,RTO_NF              
         ,INT_NF              
         ,RETPAY_NF           
         ,RETKEY_CF           
         ,RETINTAMT_M         
         ,ACMTRS_NT           
         ,FILLER1             
/INCLUDE RETRO_PREMIUM_ESTM
/OUTFILE ${SORT_O2}
/INCLUDE RETRO_COMMISSION_ESTM
/REFORMAT SSD_CF                   
         ,ESB_CF              
         ,BALSHEY_NF          
         ,BALSHRMTH_NF        
         ,BALSHRDAY_NF        
         ,TRNCOD_CF_NF_NEW           
         ,DBLTRNCOD_CF        
         ,CTR_NF              
         ,END_NT              
         ,SEC_NF              
         ,UWY_NF              
         ,UW_NT               
         ,OCCYEA_NF           
         ,ACY_NF              
         ,SCOSTRMTH_NF        
         ,SCOENDMTH_NF        
         ,CLM_NF              
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
         ,RETSCOSTRMTH_NF_NEW 
         ,RETSCOENDMTH_NF_NEW 
         ,RCL_NF              
         ,RETCUR_CF           
         ,RETAMT_MC          
         ,PLC_NT              
         ,RTO_NF              
         ,INT_NF              
         ,RETPAY_NF           
         ,RETKEY_CF           
         ,RETINTAMT_M         
         ,ACMTRS_NT           
         ,FILLER1 
/OUTFILE ${SORT_O3}
/INCLUDE RETRO_DAC_ESTM
/REFORMAT SSD_CF                   
         ,ESB_CF              
         ,BALSHEY_NF          
         ,BALSHRMTH_NF        
         ,BALSHRDAY_NF        
         ,TRNCOD_CF_NF_NEW           
         ,DBLTRNCOD_CF        
         ,CTR_NF              
         ,END_NT              
         ,SEC_NF              
         ,UWY_NF              
         ,UW_NT               
         ,OCCYEA_NF           
         ,ACY_NF              
         ,SCOSTRMTH_NF        
         ,SCOENDMTH_NF        
         ,CLM_NF              
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
         ,RETSCOSTRMTH_NF_NEW 
         ,RETSCOENDMTH_NF_NEW 
         ,RCL_NF              
         ,RETCUR_CF           
         ,RETAMT_MC          
         ,PLC_NT              
         ,RTO_NF              
         ,INT_NF              
         ,RETPAY_NF           
         ,RETKEY_CF           
         ,RETINTAMT_M         
         ,ACMTRS_NT           
         ,FILLER1                                          
exit
EOF
SORT

NSTEP=${NJOB}_34
#  GENERATION EXTRACTION DES Annulation des Retro Estimate prm 
#------------------------------------------------------------------------------
#LIBEL="FUTURES PREPARATION : Annulation des Retro Estimate prm PRS 750" --> "2A100122"
#-----------------------------------------------------------------------------
LIBEL="Generate cancellations Retro Estimate prm "
AWK_I="${DFILT}/${NJOB}_32_${IB}_SORT_RETRO_PREMIUM_ESTM.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_RETRO_PREMIUM_ESTM_ANNULATION.dat"
AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{
		\$3 = an
		\$4 = mois
		\$5 = jour
		if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
		if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
		\$6 = "2A100122"
		\$59 = speentnat_ct
		print \$0;
	}
exit
EOF
AWK



NSTEP=${NJOB}_36
#  GENERATION EXTRACTION DES Annulation des Retro Commission, DAC
#------------------------------------------------------------------------------
#LIBEL="FUTURES PREPARATION : Annulation des Retro  Commission PRS 750" --> "2A120122"
#-----------------------------------------------------------------------------
LIBEL="Generate cancellations Retro Commission Remaining"
AWK_I="${DFILT}/${NJOB}_32_${IB}_SORT_RETRO_COMMISSION_ESTM.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_RETRO_COMMISSION_ESTM_ANNULATION.dat"
AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{
		\$3 = an
		\$4 = mois
		\$5 = jour
		if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
		if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
		\$6 = "2A120122"
		\$59 = speentnat_ct
		print \$0;
	}
exit
EOF
AWK




#[002] TRI SANS  ,RTO_NF 
NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="SORT BCP_PLACEMT22.dat"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FPLACEMT22}  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FPLACEMT22.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF     		1:1 -  1:EN,   
        ESB_CF        2:1 -  2:EN,                   
				RETCTR_NF 		3:1 -  3:,          
				RETEND_NT 		4:1 -  4:EN,          
				RETSEC_NF 		5:1 -  5:EN,          
				RTY_NF        6:1 -  6:EN,       
				RETUW_NT      7:1 -  7:,      
				PLC_NT 				8:1 -  8:EN,             
				OVRCOM_R			9:1 -  9:EN,           
				RTO_NF 				10:1 - 10:,             
				INT_NF 				11:1 - 11:,            
				PAY_NF        12:1 - 12:,            
				KEY_CF 				13:1 - 13:,            
				ORICUR_B 			14:1 - 14:,          
				SSDRTO_B 			15:1 - 15:,          
				RETSIGSHA_R 	16:1 - 16:EN  15/3,  
				TOTRETSIGSHA_R 	17:1 - 17:EN  15/3,        
				NBCOL 				38:1 - 38:EN	15/3			          
/KEYS   RETCTR_NF
       ,RETSEC_NF
       ,RTY_NF
       ,PLC_NT          				
exit
EOF
SORT 

# [11] Ano Warning Tech /INFILE ${DFILT}/${NJOB}_20_${IB}_SORT_IRDPERICASE.dat 1000 1 "~"

NSTEP=${NJOB}_45
# Join and sort of perimetre file and FPLACEMENT by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_IRDPERICASE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_ADDI_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 				3:1 - 3:,
        SEC_NF 				5:1 - 5:,
        UWY_NF 				6:1 - 6:,        
        ALL_F1    		1:1 - 206:,
        RETCTR_NF 		3:1 -  3:,                   
				RETSEC_NF 		5:1 -  5:,          
				RTY_NF        6:1 -  6:,             
				PLC_NT_PLA 		8:1 -  8:EN,                        
				RTO_NF_PLA    11:1 - 11:,                                     
				RETSIGSHA_R 	17:1 - 17:,  
				TOTRETSIGSHA_R 	37:1 - 37:,        	
				ALL_F2    		1:1 - 38:		          
/JOINKEYS CTR_NF,
          SEC_NF,
          UWY_NF  
/INFILE ${DFILT}/${NJOB}_40_${IB}_SORT_FPLACEMT22.dat 1000 1 "~"
/JOINKEYS RETCTR_NF,
          RETSEC_NF,
          RTY_NF  
/JOIN UNPAIRED                 
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: PLC_NT_PLA, RIGHTSIDE: RTO_NF_PLA, RIGHTSIDE: RETSIGSHA_R, RIGHTSIDE: TOTRETSIGSHA_R
exit
EOF
SORT
 


#[002] SORT WITHOUT  ,RTO_NF_PLA  
NSTEP=${NJOB}_50
# Join and sort of perimetre file and FPLACEMENT by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_IRDPERICASE_ADDI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_ADDI_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 						3:1 - 3:,
        SEC_NF 						5:1 - 5:EN,                 
				RTY_NF        		6:1 -  6:EN,       
				RETUW_NT      		7:1 -  7:EN,      
				PLC_NT_PLA 				207:1 - 207:EN,                       
				RTO_NF_PLA 				208:1 - 208:,
				RETSIGSHA_R 			209:1 - 209:,
				TOTRETSIGSHA_R 		210:1 - 210:				
/KEYS   CTR_NF
       ,SEC_NF
       ,RTY_NF
       ,PLC_NT_PLA            				
exit
EOF
SORT



NSTEP=${NJOB}_52
# SORT UNIQUE of perimetre file and FPLACEMENT by ALL_COLUMN 
#------------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_IRDPERICASE_ADDI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_ADDI_O.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		1:1 - 209:, 
        CTR_NF    		3:1 - 3: 
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (ALL_F1 != "")
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT


NSTEP=${NJOB}_55
# SORT UNIQUE of perimetre file and FPLACEMENT by ALL_COLUMN 
#------------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_52_${IB}_IRDPERICASE_ADDI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_ADDI_O.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    		1:1 - 209:, 
        CTR_NF    		3:1 - 3:
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (CTR_NF != "")
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT

#[002] SORT WITHOUT  RTO_NF_PLA
NSTEP=${NJOB}_57
# Join and sort of perimetre file and FPLACEMENT by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_IRDPERICASE_ADDI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_ADDI_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 						3:1 - 3:,
        SEC_NF 						5:1 - 5:EN,                 
				RTY_NF        		6:1 -  6:EN,       
				RETUW_NT      		7:1 -  7:EN,      
				PLC_NT_PLA 				207:1 - 207:EN,                       
				RTO_NF_PLA 				208:1 - 208:,
				RETSIGSHA_R 			209:1 - 209:,
				TOTRETSIGSHA_R 		210:1 - 210:				
/KEYS   CTR_NF
       ,SEC_NF
       ,RTY_NF
       ,PLC_NT_PLA              				
exit
EOF
SORT


#  GENERATION ITD PREMIUM ESTIMES
NSTEP=${NJOB}_58
#------------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : GENERATION DES RETRO ITD PREMIUM ESTIMES "
PRG=ESTC1051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${ICLODAT_A}
PRS_CF 751
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_IRDPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_ITDESTIMES.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EPO_FCURQUOT}
export ${PRG}_I5=${EPO_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ITDESTIMES.dat
EXECPRG


#[002] Sort Without 
#  GENERATION ITD PREMIUM ESTIMES
NSTEP=${NJOB}_59
#------------------------------------------------------------------------------
#LIBEL="FUTURES PREPARATION : EXTRACTION DES ITDPREMIUM ACTMTRS 1010 PRS 751 "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_58_${IB}_ESTC1051_ITDESTIMES.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ITDESTIMES.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN
       ,ESB_CF           2:1 -  2:EN
       ,BALSHEY_NF       3:1 -  3:EN
       ,BALSHRMTH_NF     4:1 -  4:EN
       ,BALSHRDAY_NF     5:1 -  5:EN
       ,TRNCOD_CF        6:1 -  6:
       ,TRNCOD1_CF       6:1 -  6:1
       ,TRNCOD2_CF       6:2 -  6:2
       ,TRNCOD4_CF       6:1 -  6:4
       ,TRNCOD8_CF       6:8 -  6:8
       ,DBLTRNCOD_CF     7:1 -  7:
       ,CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:
       ,SEC_NF          10:1 - 10:EN
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:
       ,OCCYEA_NF       13:1 - 13:
       ,ACY_NF          14:1 - 14:
       ,SCOSTRMTH_NF    15:1 - 15:EN
       ,SCOENDMTH_NF    16:1 - 16:EN
       ,CLM_NF          17:1 - 17:
       ,CUR_CF          18:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,CED_NF          20:1 - 20:
       ,BRK_NF          21:1 - 21:
       ,PAY_NF          22:1 - 22:
       ,KEY_NF          23:1 - 23:
       ,RETCTR_NF       24:1 - 24:
       ,RETEND_NT       25:1 - 25:EN
       ,RETSEC_NF       26:1 - 26:EN
       ,RTY_NF          27:1 - 27:EN
       ,RETUW_NT        28:1 - 28:EN
       ,RETOCCYEA_NF    29:1 - 29:
       ,RETACY_NF       30:1 - 30:
       ,RETSCOSTRMTH_NF 31:1 - 31:EN
       ,RETSCOENDMTH_NF 32:1 - 32:EN
       ,RCL_NF          33:1 - 33:
       ,RETCUR_CF       34:1 - 34:
       ,RETAMT_M        35:1 - 35:EN 15/3
       ,PLC_NT          36:1 - 36:EN
       ,RTO_NF          37:1 - 37:
       ,INT_NF          38:1 - 38:
       ,RETPAY_NF       39:1 - 39:
       ,RETKEY_CF       40:1 - 40:
       ,RETINTAMT_M     41:1 - 41:EN 15/3
       ,ACMTRS_NT       42:1 - 42:  
       ,FILLER1         43:1 - 73:                   
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      PLC_NT,
      TRNCOD_CF
/CONDITION RETITDESTM   ( ACMTRS_NT='1010') 
/DERIVEDFIELD RETSCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD RETSCOENDMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/SUMMARIZE TOTAL RETAMT_M, TOTAL AMT_M
/OUTFILE ${SORT_O}
/INCLUDE RETITDESTM
/REFORMAT SSD_CF                   
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
         ,OCCYEA_NF           
         ,ACY_NF              
         ,SCOSTRMTH_NF        
         ,SCOENDMTH_NF        
         ,CLM_NF              
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
         ,RETSCOSTRMTH_NF_NEW 
         ,RETSCOENDMTH_NF_NEW 
         ,RCL_NF              
         ,RETCUR_CF           
         ,RETAMT_MC          
         ,PLC_NT              
         ,RTO_NF              
         ,INT_NF              
         ,RETPAY_NF           
         ,RETKEY_CF           
         ,RETINTAMT_M         
         ,ACMTRS_NT           
         ,FILLER1                     
exit
EOF
SORT



# Le fichier POS en entree ne doit il contenir que les FUTURES RETRO
# [004] TRNCOD_CF="2A100112" OR  TRNCOD_CF="2A100122"  OR TRNCOD_CF="2A120112"  OR  TRNCOD_CF="2A120112" --TRNCOD ='2A100012' ou  '2A494302'
#-----------------------------------------------------------------------------
# Begin Merge and Sort #/CONDITION RETRO ("2" CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A}) 
#-----------------------------------------------------------------------------
NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : Selection of movements ('2' CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLDGTRSO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTRSO.dat 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        ESB_CF           2:1 -  2:EN,
        BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:,
        BALSHRDAY_NF     5:1 -  5:,
        TRNCOD_CF        6:1 -  6:,
        TRNCOD1_CF       6:1 -  6:1,
        TRNCOD2_CF       6:2 -  6:2,
        TRNCOD4_CF       6:1 -  6:4,
        TRNCOD8_CF       6:8 -  6:8,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:EN,
        SEC_NF          10:1 - 10:EN,
        UWY_NF          11:1 - 11:EN,
        UW_NT           12:1 - 12:EN,
        AMT_M           19:1 - 19:EN 15/3,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:EN,
        RETSEC_NF       26:1 - 26:EN,
        RTY_NF          27:1 - 27:EN,
        RETUW_NT        28:1 - 28:EN,
        RETAMT_M        35:1 - 35:EN 15/3,
        RTO_NF          37:1 - 37:,        
        ACMTRS_NT       42:1 - 42:,   
        FILLER          43:1 - 73:
/KEYS   RETCTR_NF
       ,RETSEC_NF
       ,RTY_NF
       ,RTO_NF
       ,RETEND_NT       
       ,RETUW_NT
/CONDITION RETROFUTURE ("2" CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} ) AND (TRNCOD_CF="2A100012" OR TRNCOD_CF="2A494302" OR  TRNCOD_CF="2A100112" OR  TRNCOD_CF="2A100122"  OR TRNCOD_CF="2A120112"  OR  TRNCOD_CF="2A120112")
/OUTFILE ${SORT_O}
/INCLUDE RETROFUTURE
/REFORMAT FILLER
exit
EOF
SORT
	
#[002] Sort without      RTO_NF
#  GENERATION ITD PREMIUM ESTIMES
NSTEP=${NJOB}_63
#------------------------------------------------------------------------------
#LIBEL="FUTURES PREPARATION : EXTRACTION DES ITDPREMIUM ACTMTRS 1010 PRS 751 "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_58_${IB}_ESTC1051_ITDESTIMES.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ITDESTIMES.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN
       ,ESB_CF           2:1 -  2:EN
       ,BALSHEY_NF       3:1 -  3:EN
       ,BALSHRMTH_NF     4:1 -  4:EN
       ,BALSHRDAY_NF     5:1 -  5:EN
       ,TRNCOD_CF        6:1 -  6:
       ,DBLTRNCOD_CF     7:1 -  7:
       ,CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:
       ,SEC_NF          10:1 - 10:EN
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:
       ,OCCYEA_NF       13:1 - 13:
       ,ACY_NF          14:1 - 14:
       ,SCOSTRMTH_NF    15:1 - 15:EN
       ,SCOENDMTH_NF    16:1 - 16:EN
       ,CLM_NF          17:1 - 17:
       ,CUR_CF          18:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,CED_NF          20:1 - 20:
       ,BRK_NF          21:1 - 21:
       ,PAY_NF          22:1 - 22:
       ,KEY_NF          23:1 - 23:
       ,RETCTR_NF       24:1 - 24:
       ,RETEND_NT       25:1 - 25:EN
       ,RETSEC_NF       26:1 - 26:EN
       ,RTY_NF          27:1 - 27:EN
       ,RETUW_NT        28:1 - 28:EN
       ,RETOCCYEA_NF    29:1 - 29:
       ,RETACY_NF       30:1 - 30:
       ,RETSCOSTRMTH_NF 31:1 - 31:EN
       ,RETSCOENDMTH_NF 32:1 - 32:EN
       ,RCL_NF          33:1 - 33:
       ,RETCUR_CF       34:1 - 34:
       ,RETAMT_M        35:1 - 35:EN 15/3
       ,PLC_NT          36:1 - 36:EN
       ,RTO_NF          37:1 - 37:
       ,INT_NF          38:1 - 38:
       ,RETPAY_NF       39:1 - 39:
       ,RETKEY_CF       40:1 - 40:
       ,RETINTAMT_M     41:1 - 41:EN 15/3
       ,ACMTRS_NT       42:1 - 42:              
       ,FILLER1         43:1 - 73:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      PLC_NT
/CONDITION RETITDESTM   ( ACMTRS_NT='1010') 
/OUTFILE ${SORT_O}
/INCLUDE RETITDESTM              
exit
EOF
SORT


NSTEP=${NJOB}_65
#-----------------------------------------------------------------------------
LIBEL="FUTURES RETRO PREPARATION : CREATION et TRI DES FICHIERS ACTUAL ITDPREMIUM  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_RETITDPRM_UPR_ACT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_RETITD_ACTUAL.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN
       ,ESB_CF           2:1 -  2:EN
       ,BALSHEY_NF       3:1 -  3:EN
       ,BALSHRMTH_NF     4:1 -  4:EN
       ,BALSHRDAY_NF     5:1 -  5:EN
       ,TRNCOD_CF        6:1 -  6:
       ,TRNCOD1_CF       6:1 -  6:1
       ,TRNCOD2_CF       6:2 -  6:2
       ,TRNCOD4_CF       6:1 -  6:4
       ,TRNCOD8_CF       6:8 -  6:8
       ,DBLTRNCOD_CF     7:1 -  7:
       ,CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:
       ,SEC_NF          10:1 - 10:EN
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:
       ,OCCYEA_NF       13:1 - 13:
       ,ACY_NF          14:1 - 14:
       ,SCOSTRMTH_NF    15:1 - 15:EN
       ,SCOENDMTH_NF    16:1 - 16:EN
       ,CLM_NF          17:1 - 17:
       ,CUR_CF          18:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,CED_NF          20:1 - 20:
       ,BRK_NF          21:1 - 21:
       ,PAY_NF          22:1 - 22:
       ,KEY_NF          23:1 - 23:
       ,RETCTR_NF       24:1 - 24:
       ,RETEND_NT       25:1 - 25:EN
       ,RETSEC_NF       26:1 - 26:EN
       ,RTY_NF          27:1 - 27:EN
       ,RETUW_NT        28:1 - 28:EN
       ,RETOCCYEA_NF    29:1 - 29:
       ,RETACY_NF       30:1 - 30:
       ,RETSCOSTRMTH_NF 31:1 - 31:EN
       ,RETSCOENDMTH_NF 32:1 - 32:EN
       ,RCL_NF          33:1 - 33:
       ,RETCUR_CF       34:1 - 34:
       ,RETAMT_M        35:1 - 35:EN 15/3
       ,PLC_NT          36:1 - 36:EN
       ,RTO_NF          37:1 - 37:
       ,INT_NF          38:1 - 38:
       ,RETPAY_NF       39:1 - 39:
       ,RETKEY_CF       40:1 - 40:
       ,RETINTAMT_M     41:1 - 41:EN 15/3
       ,ACMTRS_NT       42:1 - 42:       
       ,FILLER1         43:1 - 73:
/CONDITION RETROITD    ("2" CT TRNCOD1_CF )
/DERIVEDFIELD RETSCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD RETSCOENDMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD STRVIDE "~"
/KEYS   RETCTR_NF 
       ,RETSEC_NF 
       ,RTY_NF
       ,PLC_NT
       ,TRNCOD_CF
       ,RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RETROITD
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
  ,OCCYEA_NF
  ,ACY_NF
  ,SCOSTRMTH_NF
  ,SCOENDMTH_NF
  ,CLM_NF
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
  ,RETACY_NF
  ,RETSCOSTRMTH_NF_NEW
  ,RETSCOENDMTH_NF_NEW
  ,RCL_NF
  ,RETCUR_CF
  ,RETAMT_MC
  ,PLC_NT
  ,RTO_NF
  ,INT_NF
  ,RETPAY_NF
  ,RETKEY_CF
  ,RETINTAMT_M
  ,ACMTRS_NT
  ,FILLER1

exit
EOF
SORT



#  GENERATION DES RETRO UPR ESTIMES sur PRS 750
NSTEP=${NJOB}_67
#------------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : GENERATION DES RETRO UPR ESTIMES sur PRS 750 "
PRG=ESTC1051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${ICLODAT_A}
PRS_CF 750
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_IRDPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_RETUPR_ESTIME.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EPO_FCURQUOT}
export ${PRG}_I5=${EPO_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_RETUPR_ESTIME.dat
EXECPRG

NSTEP=${NJOB}_67A
#--------------------------------------------------------------------------------------------------------
LIBEL="THIS FILE IS USED WITHIN JOB ESFD3672" 	#[010] 
EXECKSH "cp ${DFILT}/${NJOB}_67_${IB}_${PRG}_RETUPR_ESTIME.dat  ${EST_RETUPR_ESTIME} "
#--------------------------------------------------------------------------------------------------------

# [014] Ajout du RETCUR_CF dans Cle du TRI 
# [013] Ajout du TRNCOD dans Cle du TRI et test des RETAMT != 0
# [018] TRI DU FICHIER Temporaire et regroupement des montants par code TRNCOD.
NSTEP=${NJOB}_68
#  GENERATION DES RETRO UPR ESTIMES sur PRS 750 GROUPING 103
#------------------------------------------------------------------------------
#LIBEL="FUTURES PREPARATION : EXTRACTION DES Retro UPR GROUPING 103"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_67_${IB}_ESTC1051_RETUPR_ESTIME.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_RETUPR_ESTIME.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_RETUPR_DAC_COMM_ESTIME.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN
       ,ESB_CF           2:1 -  2:EN
       ,BALSHEY_NF       3:1 -  3:EN
       ,BALSHRMTH_NF     4:1 -  4:EN
       ,BALSHRDAY_NF     5:1 -  5:EN
       ,TRNCOD_CF        6:1 -  6:
       ,TRNCOD1_CF       6:1 -  6:1
       ,TRNCOD2_CF       6:2 -  6:2
       ,TRNCOD4_CF       6:1 -  6:4
       ,TRNCOD8_CF       6:8 -  6:8
       ,DBLTRNCOD_CF     7:1 -  7:
       ,CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:
       ,SEC_NF          10:1 - 10:EN
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:
       ,OCCYEA_NF       13:1 - 13:
       ,ACY_NF          14:1 - 14:
       ,SCOSTRMTH_NF    15:1 - 15:EN
       ,SCOENDMTH_NF    16:1 - 16:EN
       ,CLM_NF          17:1 - 17:
       ,CUR_CF          18:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,CED_NF          20:1 - 20:
       ,BRK_NF          21:1 - 21:
       ,PAY_NF          22:1 - 22:
       ,KEY_NF          23:1 - 23:
       ,RETCTR_NF       24:1 - 24:
       ,RETEND_NT       25:1 - 25:EN
       ,RETSEC_NF       26:1 - 26:EN
       ,RTY_NF          27:1 - 27:EN
       ,RETUW_NT        28:1 - 28:EN
       ,RETOCCYEA_NF    29:1 - 29:
       ,RETACY_NF       30:1 - 30:
       ,RETSCOSTRMTH_NF 31:1 - 31:EN
       ,RETSCOENDMTH_NF 32:1 - 32:EN
       ,RCL_NF          33:1 - 33:
       ,RETCUR_CF       34:1 - 34:
       ,RETAMT_M        35:1 - 35:EN 15/3
       ,PLC_NT          36:1 - 36:EN
       ,RTO_NF          37:1 - 37:
       ,INT_NF          38:1 - 38:
       ,RETPAY_NF       39:1 - 39:
       ,RETKEY_CF       40:1 - 40:
       ,RETINTAMT_M     41:1 - 41:EN 15/3
       ,ACMTRS_NT       42:1 - 42: 
       ,FILLER1         43:1 - 73:              
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      PLC_NT,
      TRNCOD_CF,	
      RETCUR_CF
/CONDITION RETRO_UPR   "2" CT TRNCOD1_CF AND ACMTRS_NT='103' AND (RETAMT_M != 0)
/CONDITION RETRO_COMM_DAC_ESTM   "2" CT TRNCOD1_CF AND (ACMTRS_NT='101' OR ACMTRS_NT='103' OR ACMTRS_NT='201') AND (RETAMT_M != 0)
/DERIVEDFIELD RETSCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD RETSCOENDMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/SUMMARIZE TOTAL RETAMT_M, TOTAL AMT_M
/OUTFILE ${SORT_O}
/INCLUDE RETRO_UPR
/REFORMAT SSD_CF                   
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
         ,OCCYEA_NF           
         ,ACY_NF              
         ,SCOSTRMTH_NF        
         ,SCOENDMTH_NF        
         ,CLM_NF              
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
         ,RETSCOSTRMTH_NF_NEW 
         ,RETSCOENDMTH_NF_NEW 
         ,RCL_NF              
         ,RETCUR_CF           
         ,RETAMT_MC          
         ,PLC_NT              
         ,RTO_NF              
         ,INT_NF              
         ,RETPAY_NF           
         ,RETKEY_CF           
         ,RETINTAMT_M         
         ,ACMTRS_NT           
         ,FILLER1                   
/OUTFILE ${SORT_O2}
/INCLUDE RETRO_COMM_DAC_ESTM
/REFORMAT SSD_CF                   
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
         ,OCCYEA_NF           
         ,ACY_NF              
         ,SCOSTRMTH_NF        
         ,SCOENDMTH_NF        
         ,CLM_NF              
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
         ,RETSCOSTRMTH_NF_NEW 
         ,RETSCOENDMTH_NF_NEW 
         ,RCL_NF              
         ,RETCUR_CF           
         ,RETAMT_MC          
         ,PLC_NT              
         ,RTO_NF              
         ,INT_NF              
         ,RETPAY_NF           
         ,RETKEY_CF           
         ,RETINTAMT_M         
         ,ACMTRS_NT           
         ,FILLER1                               
exit
EOF
SORT



# [014] Ajout du RETCUR_CF dans Cle du TRI 
# [003] TRI des UPR  ESTIMES Uniquement ,   RETCUR_CF : TRI SANS LE RETCUR SUR LA CLE
NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
LIBEL="FUTURES CALCULATIONS :  SORT UPR ESTIMATES..."
# Begin  Sort 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_RETUPR_ESTIME.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_UPR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD3_CF        6:3 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:,
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
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,        
        FIN              43:1 - 73:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      PLC_NT,
      TRNCOD_CF,
      RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M, TOTAL RETINTAMT_M 
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS  
/CONDITION RETROUPR RETAMT_MC != 0   
/OUTFILE ${SORT_O}
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
     ,OCCYEA_NF        
     ,ACY_NF           
     ,SCOSTRMTH_NF     
     ,SCOENDMTH_NF     
     ,CLM_NF           
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
     ,ACMTRS_NT        
     ,FIN              
exit
EOF
SORT

##set  -x
####  Tri du fichier Des ITDPREMIUM fabriqué via la PSRETITDPRM et mis au format GTR, qui servira à l'extraction des ITDPREMIUM
#[005] SORT_I2="${DFILT}/${NJOB}_59_${IB}_SORT_ITDESTIMES.dat 1000 1" --> SORT_I2="${DFILT}/${NJOB}_63_${IB}_SORT_ITDESTIMES.dat 1000 1"
# [014] Ajout du RETCUR_CF dans Cle du TRI 

# Fusion des ITD ACTUALS Et ESTIMES #SORT_I2="${DFILT}/${NJOB}_10_${IB}_SORT_ITDESTIMES.dat 1000 1"
NSTEP=${NJOB}_75
#------------------------------------------------------------------------------
LIBEL="FUTURES CALCULATIONS :  SORT ITDPREMIUM ACTUALS AND ITDPREMIUM ESTIMATES..."
# Begin  Sort 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_65_${IB}_SORT_RETITD_ACTUAL.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_63_${IB}_SORT_ITDESTIMES.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_RETITDPRM.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD3_CF        6:3 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:,
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
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,        
        FIN              43:1 - 73:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,	
      PLC_NT,
      TRNCOD_CF,	
      RETCUR_CF	
/SUMMARIZE TOTAL RETAMT_M, TOTAL RETINTAMT_M 
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS  
/CONDITION RETROITD RETAMT_MC != 0   
/OUTFILE ${SORT_O}
/INCLUDE RETROITD
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
     ,OCCYEA_NF        
     ,ACY_NF           
     ,SCOSTRMTH_NF     
     ,SCOENDMTH_NF     
     ,CLM_NF           
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
     ,ACMTRS_NT        
     ,FIN              
exit
EOF
SORT

#[11 /INFILE ${DFILT}/${NJOB}_75_${IB}_SORT_RETITDPRM.dat 1000 1 "~"]

NSTEP=${NJOB}_80
# Join and sort of ITD PREMIUM file and FPLACEMENT by CTR,UWY,SEC 
#------------------------------------------------------------------------------
LIBEL="Current ITD PREMIUM File Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_SORT_RETITDPRM.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RETITDPRM_ADDI_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF_F1        24:1 - 24:,  
        RETEND_NT_F1        25:1 - 25:EN,
        RETSEC_NF_F1        26:1 - 26:,
        RTY_NF_F1           27:1 - 27:,
        RETUW_NT_F1         28:1 - 28:EN,
        PLC_NT_F1           36:1 - 36:,
        RTO_NF_F1           37:1 - 37:,               
        ALL_F1    			 1:1 - 73:,
        RETCTR_NF_F2 			 3:1 -  3:,                   
				RETSEC_NF_F2 			 5:1 -  5:,          
				RTY_NF_F2        	 6:1 -  6:,             
				PLC_NT_PLA 		     8:1 -  8:,                        
				RTO_NF_PLA         11:1 - 11:,                                     
				RETSIGSHA_R 		   17:1 - 17:,  
				TOTRETSIGSHA_R 	   37:1 - 37:,        	
				ALL_F2    			 1:1 - 38:		          
/JOINKEYS RETCTR_NF_F1,
          RTY_NF_F1,
          RETSEC_NF_F1,
          PLC_NT_F1
/INFILE ${DFILT}/${NJOB}_40_${IB}_SORT_FPLACEMT22.dat 1000 1 "~"
/JOINKEYS RETCTR_NF_F2,
          RTY_NF_F2,
          RETSEC_NF_F2,
          PLC_NT_PLA
/JOIN UNPAIRED LEFTSIDE                 
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: PLC_NT_PLA, RIGHTSIDE: RTO_NF_PLA, RIGHTSIDE: RETSIGSHA_R, RIGHTSIDE: TOTRETSIGSHA_R
exit
EOF
SORT


#[002]
NSTEP=${NJOB}_85
# SORT UNIQUE of ITD PREMIUM file and FPLACEMENT by ALL_COLUMN 
#------------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_RETITDPRM_ADDI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RETITDPRM_ADDI_O.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF    	24:1 - 24:, 
        RETSEC_NF     26:1 - 26:EN,
        RTY_NF        27:1 - 27:EN,
        PLC_NT_PLA    74:1 - 74:EN      
/KEYS   RETCTR_NF
       ,RETSEC_NF
       ,RTY_NF
       ,PLC_NT_PLA
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_90
# SORT UNIQUE of ITD PREMIUM file and FPLACEMENT by ALL_COLUMN 
#------------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_85_${IB}_RETITDPRM_ADDI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RETITDPRM_ADDI_O.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    	  1:1 - 74:, 
			  RETCTR_NF    	24:1 - 24:, 
        RETSEC_NF     26:1 - 26:EN,
        RTY_NF        27:1 - 27:EN,
        PLC_NT_PLA    74:1 - 74:EN     
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (ALL_F1 != "" )
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT

#[002] [011] Ajout RETCUR_CF Dans la cle de tri
NSTEP=${NJOB}_95
# SORT UNIQUE of ITD PREMIUM file 
#------------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort, Join and Fusion ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_RETITDPRM_ADDI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RETITDPRM_ADDI_O.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF    	24:1 - 24:, 
        RETSEC_NF     26:1 - 26:EN,
        RTY_NF        27:1 - 27:EN,
	      RETCUR_CF     34:1 - 34:,
        PLC_NT_PLA    74:1 - 74:EN            
/KEYS   RETCTR_NF
       ,RETSEC_NF
       ,RTY_NF
       ,PLC_NT_PLA
       ,RETCUR_CF	
/OUTFILE ${SORT_O}
exit
EOF
SORT

# [014] Ajout du RETCUR_CF dans Cle du TRI 
#[010] Ajout du TRNCOD dans la Cle tenir compte des Ouvertures
#[008] Cumul des ITD sur la SECTION la plus Basse et [009] Ajout de la Currency dans le cumul des ITD 
NSTEP=${NJOB}_97
# CUMULATE ITD PREMIUM ON LOWER SECTION UNIQUE KEY contract/rty/placement
#------------------------------------------------------------------------------
LIBEL="Cumulate ITD Premium on lower Section ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_RETITDPRM_ADDI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_RETITDPRM_ADDI_O.dat OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD3_CF        6:3 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:,
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
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,        
        FIN              43:1 - 73:,
        PLC_NT_PLA    	 74:1 - 74:EN,  
        RTO_NF_PLA			 75:1 - 75:EN,
        RETSIGSHA_R			 76:1 - 76:EN,
        TOTRETSIGSHA_R   77:1 - 77:EN        
/KEYS   RETCTR_NF
       ,RTY_NF
       ,PLC_NT_PLA
       ,RETCUR_CF
/SUMMARIZE TOTAL RETAMT_M 
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD  RETSEC_NF_NEW  "1~"
/CONDITION CUMUL_ITD_SECT RETAMT_MC != 0   
/OUTFILE ${SORT_O}
/INCLUDE CUMUL_ITD_SECT
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
     ,OCCYEA_NF        
     ,ACY_NF           
     ,SCOSTRMTH_NF     
     ,SCOENDMTH_NF     
     ,CLM_NF           
     ,CUR_CF           
     ,AMT_M            
     ,CED_NF           
     ,BRK_NF           
     ,PAY_NF           
     ,KEY_NF           
     ,RETCTR_NF        
     ,RETEND_NT        
     ,RETSEC_NF_NEW        
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
     ,ACMTRS_NT        
     ,FIN 
     ,PLC_NT_PLA
     ,RTO_NF_PLA
     ,RETSIGSHA_R
     ,TOTRETSIGSHA_R                         
exit
EOF
SORT

NSTEP=${NJOB}_98A
#---------------------------------------------------------------------------------------------
LIBEL="THIS FILE IS USED WITHIN JOB ESFD3672" 	#[010] 
EXECKSH "cp ${DFILT}/${NJOB}_97_${IB}_RETITDPRM_ADDI_O.dat  ${EST_RETITDPRM} "
#---------------------------------------------------------------------------------------------

# [015]
NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="FUTURES CALCULATIONS :  Calcul of Retro future premium  and Retro premium claim..."
PRG=ESTC1066
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
MIN_ICLODAT_A ${MIN_ICLODAT_A}
CLODAT_D ${ICLODAT_D}
NORME    ${CLOSING_MODE}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_57_${IB}_IRDPERICASE_ADDI_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_97_${IB}_RETITDPRM_ADDI_O.dat
#export ${PRG}_I2=${DFILT}/${NJOB}_95_${IB}_RETITDPRM_ADDI_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_40_${IB}_SORT_FPLACEMT22.dat
export ${PRG}_I4=${EPO_FCURQUOT}
export ${PRG}_I5=${EPO_FBOPRSLNK}								
#export ${PRG}_I6=${DFILT}/${NJOB}_70_${IB}_SORT_UPR.dat 
#export ${PRG}_I6=${DFILT}/${NJOB}_68_${IB}_SORT_RETUPR_ESTIME.dat
export ${PRG}_I6=${DFILT}/${NJOB}_68_${IB}_SORT_RETUPR_DAC_COMM_ESTIME.dat 
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTR.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTR_ANO.log
export ${PRG}_O3=${EPO_FUTURE_RETRO_EBS}                                      
EXECPRG


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC1066 "
ECHO_LOG "#===> Nombre de lignes futures generees "
wc -l ${DFILT}/${NJOB}_100_${IB}_ESTC1066_DLGTR.dat
#============================================"

#[017] Positionner le champ GAA A vide
#[002] Cle de regroupement sans RTO_NF
# Trier le fichier sur la cle CSUOE + RTO et PLC
NSTEP=${NJOB}_120
# Begin  Sort 
#-----------------------------------------------------------------------------
LIBEL=" FUTURES :  Sort of FUTURES GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_ESTC1066_DLGTR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTR.dat 1000 1"
#SORT_O="${EPO_DLDGTR_E} OVERWRITE  1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:,
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
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        FILLER1					 43:1 - 62:, 
        RTOCTY_CF				 63:1 - 63:,          
        GAAP_NF					 64:1 - 64:,
        BRKSCOEGP_M			 65:1 - 65:,                    
        FIN              66:1 - 73:
        
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      TRNCOD_CF,
      PLC_NT,
      RETCUR_CF     
/SUMMARIZE TOTAL RETAMT_M, TOTAL RETINTAMT_M 
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS  
/DERIVEDFIELD STRVIDE   "~"
/CONDITION MONTANT ( RETAMT_MC !=0 )
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
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
     ,OCCYEA_NF        
     ,ACY_NF           
     ,SCOSTRMTH_NF     
     ,SCOENDMTH_NF     
     ,CLM_NF           
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
     ,ACMTRS_NT
     ,FILLER1
     ,STRVIDE 
     ,STRVIDE 
     ,STRVIDE               
     ,FIN              
exit
EOF
SORT

#gzip -c ${EPO_DLDGTR_E} >  ${DFILT}/SAUVEGARDE_DLDGTR_TRIE.dat.gz

#set -x

#[002] Sans le  RTO_NF,
# Trier le fichier sur la cle CSUOE + RTO et PLC
NSTEP=${NJOB}_130
# Begin  Sort 
#-----------------------------------------------------------------------------
LIBEL=" FUTURES :  Sort of FUTURES GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_SORT_DLDGTR.dat 1000 1"
SORT_O="${EPO_DLDGTR_E} OVERWRITE  1000 1"
SORT_O2="${EPO_DLDGTRSO} OVERWRITE  1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:,
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
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,        
        FIN              43:1 - 73:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      PLC_NT,
      RETUW_NT,
      RETCUR_CF,
      TRNCOD_CF
/OUTFILE ${SORT_O}
/OUTFILE ${SORT_O2}             
exit
EOF
SORT

if [ "${TYPEINV}" = "POC" ]
then
NSTEP=${NJOB}_140
# Generate cancellations 
#-----------------------------------------------------------------------------
LIBEL="Generate cancellations POS ${NORME} ${ICLODAT_D}"
AWK_I="${DFILT}/${NJOB}_60_${IB}_SORT_DLDGTRSO.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_DLDGTRSO_PREC.dat"
AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{
		\$3 = an
		\$4 = mois
		\$5 = jour
		if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
		if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
		\$44 = "POST"
		\$59 = speentnat_ct
		print \$0;
	}
exit
EOF
AWK

#fi


### EN POC FAIRE LE DELTA ENTRE COURANT --> EPO_DLDGTRSO ET DLDGTRSO_PREC"


#if [ "${TYPEINV}" = "POC" ] #
#then
NSTEP=${NJOB}_160
# Begin  Sort 
#-----------------------------------------------------------------------------
LIBEL=" FUTURES :  DELTA ENTRE MVTS PRECEDENTS POS et MVTS EN COURS Sur Les POSTES TRNCOD_CF=2A100012 OR TRNCOD_CF=2A494302 "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_ESTC1066_DLGTR.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_140_${IB}_AWK_DLDGTRSO_PREC.dat 1000 1"
SORT_O="${EPO_DLDGTR_E} OVERWRITE  1000 1"
SORT_O2="${EPO_DLDGTRCO} OVERWRITE  1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:EN,
        UW_NT            12:1 - 12:,
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
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,      
        FILLER1					 43:1 - 62:, 
        RTOCTY_CF				 63:1 - 63:,          
        GAAP_NF					 64:1 - 64:,
        BRKSCOEGP_M			 65:1 - 65:,                    
        FIN              66:1 - 73:        
        
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      RTO_NF,
      RETUW_NT,
      RETCUR_CF,
      TRNCOD_CF
/SUMMARIZE  TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD STRVIDE   "~"
/CONDITION MVTSCOMPTA  (TRNCOD_CF="2A100012" OR TRNCOD_CF="2A494302")
/OUTFILE ${SORT_O}
/INCLUDE MVTSCOMPTA
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
          ACMTRS_NT,
        	FILLER1,	          
          STRVIDE,
          STRVIDE,
          STRVIDE,
          FIN
/OUTFILE ${SORT_O2}
/INCLUDE MVTSCOMPTA
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
          ACMTRS_NT,
          FIN          
exit
EOF
SORT
fi


#[025]
NSTEP=${NJOB}_190
# Generate DLDGTAR mvts from DLDGTR 
#-----------------------------------------------------------------------------
LIBEL="ADD AMT_MC AMOUT AND CUR_CF "
AWK_I=${EPO_DLDGTR_E}
AWK_O=${EPO_DLDGTAR_E}
#AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{   
		\$8 = "";
  	\$9 = "";
  	\$10 = "";
  	\$11 = "";
  	\$12 = "";
		\$19 = 0;
		\$18 = "";
		\$42 = "";           
    \$43 = "";           
    \$44 = "";           
    \$45 = "";           
    \$46 = "";           
    \$47 = "";           
    \$48 = "";           
    \$49 = "";           
    \$50 = "";           
    \$51 = "";           
    \$52 = "";           
    \$53 = "";           
    \$54 = "";           
    \$55 = "";           
    \$56 = "";           
    \$57 = "EBSGTA"; 
    \$58 = "";           
    \$59 = "";           
    \$60 = "";           
    \$61 = "";           
    \$62 = "";           
    \$63 = "";           
    \$64 = "";           
    \$65 = "";           
    \$66 = "";           
    \$67 = "";           
    \$68 = "";           
    \$69 = "";           
    \$70 = "";           
    \$71 = "";           
    \$72 = "";                      
		print \$0;
	}
exit
EOF
AWK


NSTEP=${NJOB}_200
# Begin  Sort 
#-----------------------------------------------------------------------------
LIBEL=" FUTURES : merge AE+retroNP : EPO_DLSGTRSII_AE_RETRONP=$EPO_DLSGTRSII_AE_RETRONP "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLDGTAR_E} 1000 1"
SORT_I2="${EPO_DLSGTRSII_AE} 1000 1"
SORT_O="${EPO_DLSGTRSII_AE_RETRONP} OVERWRITE  1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        RETCTR_NF        24:1 - 24:,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:EN,
        RETUW_NT         28:1 - 28:EN,
        RETCUR_CF        34:1 - 34:,
        RTO_NF           37:1 - 37:,
		TRNCOD_CF        6:1 -  6:,
		ALL_71           1:1 -  71: 
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      RTO_NF,
      RETUW_NT,
      RETCUR_CF,
      TRNCOD_CF
/REFORMAT ALL_71	  
exit
EOF
SORT
 

 


#########################
# Erase temporary files #
#########################

NSTEP=${NJOB}_210
LIBEL="Erase temporary files"

#RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
   
