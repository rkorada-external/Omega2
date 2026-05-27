#!/bin/ksh
#====================================================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 11.2 : MAINTENANCE EXPENSES PAID CALCULATION 
# Nom du script SHELL           : ESFD3741.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 07/03/2019
# Auteur                        : L.ELFAHIM
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# SPIRA 71570 : REQ 11.02 - IFRS17- Closing schedule : new chain to calculate mainteance Expenses Paid:
#  - Calculation of Mainteance Expenses Paid
#
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   		<spira> 			<description de la modification>
#	[001] 		07/03/2019 		LEL 			SPIRA : 71570 		Maintenance Expenses Paid calculation
#   [002]   	24/07/2019      L.DOAN          SPIRA : 77079      	Generating IFRS 17 Group TL file
#	[003]  		02/01/2020      L.DOAN       	SPIRA : 79100 		REQ21.9- Manage retro dummy contracts in closing
#  	[003]   	03/06/2020      L.DOAN          SPIRA : 79070     	Add contre partie
# 	[003]   	09/07/2020      L.DOAN          SPIRA : 85208      	add GTL REQ11.1 of ESFD3630
#	[004]   	25/08/2020      L.DOAN          SPIRA : 87876     	GLT generation using PRSMAP	
#	[005]   	12/10/2020      L.DOAN          SPIRA : 90514      	reverse the sign for all INI transactions except 
#	[006]		27/10/2020      L.DOAN          SPIRA : 90211      	retro NDIC
# [007]   	05/11/2020      L.DOAN          SPIRA : 90492 		add Quarterly Written Premium
# [008]   	20/01/2021      L.DOAN          SPIRA : 91531      	Fix param
# [009]   	19/02/2021      L.DOAN          SPIRA : 85522 		technical cashflow flux
# [010]   	09/03/2021      L.DOAN          SPIRA : 91488      	future profitable filtre
# [011]   	09/03/2021      L.DOAN          SPIRA : 94597 		integrate AE I17 
# [012]   	28/04/2021      L.DOAN          SPIRA : 90073           integrate AE DAC IFRS17
# [013]   	24/05/2021      L.DOAN          SPIRA : 90091      	delete multiyear INI
# [014]   	09/09/2021      L.DOAN          SPIRA : 90514     	reverse the sign of RETINTAMT_M
# [015]   	14/09/2021      L.DOAN          SPIRA : 98275 		refont NDIC RETRO
# [016]   	13/10/2021      LEL          	SPIRA : 99572 		REMOVE RETRO FILE :ESF_EXPENSES_RETRO 
# [017]   	15/10/2021      MiS             SPIRA : 98877		Generate DAC IFRS17 for Parent and Local
# [017]     06/11/2021      L.DOAN          SPIRA : 98877           Generate DAC IFRS17 for Parent and Local : fix condition
# [018]     10/01/2022      D.TEIXEIRA      SPIRA : 100371          Calcul amount of Change in Estimates - Future Receivables : fix bug
# [019]     28/02/2022      D.TEIXEIRA      SPIRA : 100992          Fix Bug : Change in EST / Change in EGPI MAJ Signe in STEP 30
# [020]     07/04/2022      MZM             SPIRA : 102508 / 102507    Integration des AI I17 Dans TTECLEDA Prise en compte LCC INI  et NDC INI
# [021]     21/04/2022      MZM             SPIRA:  103583 I17P/I17L- Undiscounted NDIC transactions : NDC STD Ventile sur Norme L et P par MAJ Suffixes TRNCODS
# [022]     25/04/2022      DAD             SPIRA:  103425 Sum amount Future Receivables and Prime actual
# [023]     04/05/2022      MZM             SPIRA:  103583 I17P/I17L- Undiscounted NDIC transactions : Ajout TRI PERICASE sur Section Num
# [024]     18/05/2022      MZM             SPIRA:  104058 : DAC I17 - AI TL missing ==> Bouclette 
# [025]     16/06/2022      DaD             SPIRA:  99814  :  Exclude future Onerous contrat
#	[026] 		07/07/2022  		JBD							Spira : 104778  Build new closing for I17S norm
# [027]     07/07/2022      MZM             SPIRA:  104857 : NDIC TC - AI TL missing : Prise en compte ESF_DLRGTAA_NDC_TC
# [028]     12/07/2022      DAD             SPIRA:  104061 : Not Generate AI TL for I17G/S
# [029]     04/08/2022      DAD             SPIRA:  105382 : exclude future profitable and onerous for STD and INI in ESFD3870
# [030]     29/08/2022      MZM             SPIRA:  106381 : IO - Sign inversion not implemented 
# [031]     13/09/2022      DAD             SPIRA:  106628 : generate DLREGTRSII from DLREGTARSII for TECLEDR
# [032]     19/09/2022      MZM             SPIRA:  106629 : generate PLC, RTO FOR DAC I17 for TECLEDR
# [033]     23/09/2022      DAD             SPIRA:  106628 : not exclude contrat assmued AI with contrat retro for TL TECLEDA
# [034]     24/09/2022      DAD             SPIRA:  106628 : remove duplication
# [035]     03/10/2022      DAD             SPIRA:  106952 : not reverse sign for T.CODE EBS
# [036]     24/10/2022      DAD             SPIRA:  106803 : not reverse sign for NEW T.CODE EBS
# [037]     21/11/2022      MZM             SPIRA:  107841 Regression on IO change / unwind entries
# [038]     28/11/2022      DAD             SPIRA:  107135 : not reverse sign for NDIC INI and STD (futures onerous and dummy)
# [039]     12/12/2022      JBD             SPIRA:  107893 : Regression on IO change / unwind for DAC (fix MZ ITK)
# [040]     11/01/2023      DAD             SPIRA:  108404 missing AEs
# [041]     13/01/2023      HR              SPIRA:  106770 : I17G - Internal assumed initial amounts to be aligned with internal retro initial amounts
# [042]     26/01/2023      MiS             SPIRA:  108027 : Update Condition for I17S
# [043]     08/02/2023      DAD             SPIRA:  108715 : reverse sign for NDIC copy
# [044]     20/02/2023      DAD             SPIRA:  108715 : reverse sign for NDIC copy STD (futures onerous and dummy)
# [045]     06/04/2023      MZM             SPIRA:  108791 : PROD - Missing Internal Assumed generated from AE booked on Internal Retro in project "Omega 2.0" Contraintes sur I17 : 
# [046]     18/04/2023      DAD             SPIRA:  109510 : I17 - Correct the sign of overriding com for dummies (copy INI to POS)
# [047]     11/05/2023      MZM             SPIRA:  109187 : [1Q23 I17 Prod] RA/RR gap on Retro NP contracts : Ajout TRNCOD1_CF dans clé de cumul
# [048]     23/05/2023      MZM             SPIRA:  109829 : PROD - RR/RA discrepancy - Missing INI amounts (and Reclass) on RA view 
# [049]     21/08/2023      MZM             SPIRA:  110151 : I17 Prod - IO issues
# [050]     30/04/2024      DAD             SPIRA:  111414 : Fix QWP sum on View RR  
# [051]     21/08/2024      MZM             SPIRA:  111807 : No pure retro NDIC calculation when underlying is internal assumed
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd


#CLODAT_D=${PARM_ICLODAT_D}
CRE_D=${PARM_CRE_D}

#TODO date to be defined
#POS_BOOKING_X_DT="20190823"   

NORME="${NORME_CF}"


# Get input parameters


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES " 

# [027]


if [ ! -f ${ESF_DLRGTAA_NDC_TC} ]
then
        ECHO_LOG "ESF_DLRGTAA_NDC_TC=${ESF_DLRGTAA_NDC_TC}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLRGTAA_NDC_TC}"
fi


if [ ! -f ${ESF_ACC_NDIC} ]
then
        ECHO_LOG "ESF_ACC_NDIC=${ESF_ACC_NDIC}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_ACC_NDIC}"
fi

if [ ! -f ${ESF_ACC_NDIC_RET_NP} ]
then
        ECHO_LOG "ESF_ACC_NDIC_RET=${ESF_ACC_NDIC_RET_NP}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_ACC_NDIC_RET_NP}"
fi


if [ ! -f ${ESF_EXPENSES_STD} ]
then
        ECHO_LOG "ESF_EXPENSES_STD=${ESF_EXPENSES_STD}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_EXPENSES_STD}"

fi


if [ ! -f ${ESF_DLCUMGTAAR_MVT_AGG} ]
then
        ECHO_LOG "ESF_DLCUMGTAAR_MVT_AGG=${ESF_DLCUMGTAAR_MVT_AGG}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLCUMGTAAR_MVT_AGG}"

fi


if [ ! -f ${ESF_DLCUMGTAAR_MVT_AGG_RET} ]
then
        ECHO_LOG "ESF_DLCUMGTAAR_MVT_AGG_RET=${ESF_DLCUMGTAAR_MVT_AGG_RET}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLCUMGTAAR_MVT_AGG_RET}"

fi


if [ ! -f ${ESF_AET_DLSGTR} ]
then
        ECHO_LOG "ESF_AET_DLSGTR=${ESF_AET_DLSGTR}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_AET_DLSGTR}"

fi

if [ ! -f ${ESF_AET_DLSGTAA} ]
then
        ECHO_LOG "ESF_AET_DLSGTAA=${ESF_AET_DLSGTAA}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_AET_DLSGTAA}"

fi

if [ ! -f ${ESF_AET_DLSGTAR} ]
then
        ECHO_LOG "ESF_AET_DLSGTAR=${ESF_AET_DLSGTAR}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_AET_DLSGTAR}"

fi

if [ ! -f ${ESF_DLRGTAA} ]
then
        ECHO_LOG "ESF_DLRGTAA=${ESF_DLRGTAA}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLRGTAA}"

fi 

if [ ! -f ${ESF_DLRGTAA_NDC_INI} ]
then
        ECHO_LOG "ESF_DLRGTAA_NDC_INI=${ESF_DLRGTAA_NDC_INI}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLRGTAA_NDC_INI}"

fi

if [ ! -f ${ESF_DLRGTAA_NDC_STD} ]
then
        ECHO_LOG "ESF_DLRGTAA_NDC_STD=${ESF_DLRGTAA_NDC_STD}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLRGTAA_NDC_STD}"

fi


if [ ! -f ${ESF_DLRGTAA_LCC_INI} ]
then
        ECHO_LOG "ESF_DLRGTAA_LCC_INI=${ESF_DLRGTAA_LCC_INI}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLRGTAA_LCC_INI}"

fi
 
if [ ! -f ${ESF_DLRGTAA_DACI17} ]
then
        ECHO_LOG "ESF_DLRGTAA_DACI17=${ESF_DLRGTAA_DACI17}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_DLRGTAA_DACI17}"

fi 	


if [ "${CONTEXT_CT}" = STD ]
then
	ECHO_LOG "setup STD "  >> $FLOG
	EST_EXPENSES="${ESF_EXPENSES_STD}"
	EST_GTSII_EXPENSES_PAID=${ESF_GTSII_MAINT_EXPENSES_PAID}
	EST_GTASII_OTHER="${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3744${TYPEINV}_${CONTEXT_CT}_30_${IB}_GTASII_STD.dat" # [019]
	EST_GTRSII_OTHER="${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3744${TYPEINV}_${CONTEXT_CT}_30_${IB}_GTRSII_STD.dat" # [019]
	
#	[021] EST_ACC_NDIC="${ESF_ACC_NDIC}"
	EST_ACC_NDIC="${DFILP}/empty.dat"
	
#	[021] EST_ACC_NDIC_RET="${ESF_ACC_NDIC_RET_NP}"	
  EST_ACC_NDIC_RET="${DFILP}/empty.dat"
	EST_ACC_NDIC_RET_P_GTAR="${ESF_ACC_NDIC_RET_P_GTAR}"
	EST_ACC_NDIC_RET_P_GTR="${ESF_ACC_NDIC_RET_P_GTR}"	
        EST_FPRSMAP_TXT="${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3742${TYPEINV}_${CONTEXT_CT}_30_${IB}_SORT_FPRSMAP_TXT.dat"
else
	ECHO_LOG "setup INI "  >> $FLOG

	EST_EXPENSES="${DFILP}/empty.dat"
	EST_GTSII_EXPENSES_PAID="${DFILP}/empty.dat"
	EST_GTASII_OTHER="${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3743${TYPEINV}_${CONTEXT_CT}_50_${IB}_ESFC3741_GTASII_INI.dat"
	EST_GTRSII_OTHER="${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3743${TYPEINV}_${CONTEXT_CT}_50_${IB}_ESFC3741_GTRSII_INI.dat"
	EST_ACC_NDIC="${ESF_ACC_NDIC_INI}"
	EST_ACC_NDIC_RET="${ESF_ACC_NDIC_RET_INI}"
	EST_ACC_NDIC_RET_P_GTAR="${DFILP}/empty.dat"
        EST_ACC_NDIC_RET_P_GTR="${DFILP}/empty.dat"
        # EST_IADPERICASE_ONEROUSFUT="${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3743${TYPEINV}_${CONTEXT_CT}_17_${IB}_SORT_IADPERICASE_ONEROUSFUT.dat"
fi

NORME_SUFFIX='R'

if [  $NORME_CF = I17G ] || [  $NORME_CF = I17S ]
then
    NORME_SUFFIX='I'
else    
    if [  $NORME_CF = I17P ] 
    then 
         NORME_SUFFIX='K'
    else
        if [  $NORME_CF = I17L ] 
        then 
            NORME_SUFFIX='M'
        fi    
    fi
fi    

#[017]

if [ "${CONTEXT_CT}" = STD ]
then


#	[021]  Merge  NDC RETRO WITH PERICASE RETRO ==> Suffixe Norme   
# SORT_I6="${ESF_ACC_NDIC_RET_NP} 2000 1"

NSTEP=${NJOB}_02
# Merge  NDC RETRO WITH PERICASE RETRO ==> Suffixe Norme 
#------------------------------------------------------------------------------
LIBEL="Merge  NDC RETRO WITH PERICASE RETRO ==> Suffixe Norme ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_ACC_NDIC_RET_NP} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ACC_NDIC_RETRO.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF_F1        24:1 - 24:,  
        RETEND_NT_F1        25:1 - 25:EN,
        RETSEC_NF_F1        26:1 - 26:,
        RTY_NF_F1           27:1 - 27:,
        RETUW_NT_F1         28:1 - 28:,
        FILED_1_73_F1       1:1 - 73:,        
        CTR_NF_F2 			 	  3:1 -  3:,                   
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:      		          
/JOINKEYS RETCTR_NF_F1,
          RETSEC_NF_F1,
          RTY_NF_F1,
          RETUW_NT_F1  
/INFILE ${ESF_OIRDVPERICASE} 2000 1 "~"          
/JOINKEYS CTR_NF_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2           
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FILED_1_73_F1
exit
EOF
SORT

NSTEP=${NJOB}_02A
#Ventilation du Suffixe en fonction de la norme
#-----------------------------------------------------------------------------
LIBEL="Ventilation du Suffixe en fonction de la norme L ou P"
AWK_I="${DFILT}/${NJOB}_02_${IB}_SORT_ACC_NDIC_RETRO.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_DACC_NDIC_RETRO.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {


 { \$6=substr(\$6,1,7) "${NORME_SUFFIX}" ; print \$0; }
  if (substr(\$7,8,1) == "I")
    { \$7=substr(\$7,1,7) "${NORME_SUFFIX}" ; print \$0; }

  }
exit
EOF
AWK


#	[021]  Merge DA I17C et NDC I17  ;  ESF_DLRGTAA_NDC_STD (AI STD)  ; ESF_ACC_NDIC (NDC_ALL_STD) 
#	[022]  Merge DAC I17 Assume Interne ==> TL 
#	[027]  Prise en compte Fichier NDIC  AI TC ==> TL 


NSTEP=${NJOB}_03
#-----------------------------------------------------------------------------
LIBEL="AGREGATES ESF_DLREGTAR_DACI17 EST_ACC_NDIC ESF_DLRGTAA_NDC_STD Merge and sort files before JOIN with PERICASE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`  
SORT_I="${ESF_DLREGTAR_DACI17} 2000 1" 
SORT_I2="${ESF_ACC_NDIC}  2000 1" 
SORT_I3="${ESF_DLRGTAA_NDC_STD}  2000 1" 
SORT_I4="${ESF_DLRGTAA_DACI17}  2000 1" 
SORT_I5="${ESF_DLRGTAA_NDC_TC}  2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_DACI17_NDC_ALL_STD.dat 2000 1"   
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
/OUTFILE ${SORT_O}    	
exit
EOF
SORT

# [023] Tri du fichier par CSUE

NSTEP=${NJOB}_04
#Tri du fichier EST_IADPERICASE_STD
#-----------------------------------------------------------------------------
LIBEL="Tri de Tri du fichier EST_IADPERICASE_STD ... "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_STD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_STD_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 	CTR_NF 3:1 - 3:, 
					END_NT 4:1 - 4:EN, 
					SEC_NF 5:1 - 5:EN, 
					UWY_NF 6:1 - 6:, 
					UW_NT 7:1 - 7:EN
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

# [023]

NSTEP=${NJOB}_05
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="DAC I17 And NDC_ALL_STD Selection and TRNCOD Update"
PRG=ESFC3743
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
NORME   ${NORME_CF}
exit
EOF
export ${PRG}_PRM=${FPRM}
#export ${PRG}_I1=${EST_IADPERICASE_STD}
export ${PRG}_I1="${DFILT}/${NJOB}_04_${IB}_SORT_IADPERICASE_STD_O.dat"
#export ${PRG}_I2=${ESF_DLREGTAR_DACI17}
export ${PRG}_I2="${DFILT}/${NJOB}_03_${IB}_DACI17_NDC_ALL_STD.dat"
#export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_DLREGTAR_DACI17_${PRG}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_DACI17_NDC_ALL_STD_${PRG}.dat
EXECPRG



##[032]


NSTEP=${NJOB}_05A
# JOIN DACI17 RETRO WITH PERICASE RETRO ==> Suffixe Norme 
#------------------------------------------------------------------------------
LIBEL="JOIN DACI17 ASSUMES WITH PERICASE ==> TO DO Suffixe Norme  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_03_${IB}_DACI17_NDC_ALL_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DACI17_NDC_ALL_STD.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        FILED_1_73_F1    1:1 - 73:,        
      	CTR_NF_F2					3:1 - 3:, 
				END_NT_F2 				4:1 - 4:, 
				SEC_NF_F2 				5:1 - 5:, 
				UWY_NF_F2 				6:1 - 6:, 
				UW_NT_F2 					7:1 - 7:   		          
/JOINKEYS CTR_NF,  
          END_NT,  
          SEC_NF,  
          UWY_NF,  
          UW_NT          
/INFILE ${DFILT}/${NJOB}_04_${IB}_SORT_IADPERICASE_STD_O.dat 2000 1 "~"          
/JOINKEYS CTR_NF_F2,
          END_NT_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NT_F2           
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FILED_1_73_F1
exit
EOF
SORT

NSTEP=${NJOB}_05B
#Ventilation du Suffixe en fonction de la norme
#-----------------------------------------------------------------------------
LIBEL="Ventilation du Suffixe en fonction de la norme L ou P"
AWK_I="${DFILT}/${NJOB}_05A_${IB}_SORT_DACI17_NDC_ALL_STD.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_DACI17_NDC_ALL_STD.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {


 { \$6=substr(\$6,1,7) "${NORME_SUFFIX}" ; print \$0; }
  if (substr(\$7,8,1) == "I")
    { \$7=substr(\$7,1,7) "${NORME_SUFFIX}" ; print \$0; }

  }
exit
EOF
AWK



NSTEP=${NJOB}_06
# JOIN DACI17 RETRO WITH PERICASE RETRO ==> Suffixe Norme 
#------------------------------------------------------------------------------
LIBEL="JOIN DACI17 RETRO WITH PERICASE RETRO ==> Suffixe Norme  ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLREGTR_DACI17} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTR_DACI17.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF_F1        24:1 - 24:,  
        RETEND_NT_F1        25:1 - 25:EN,
        RETSEC_NF_F1        26:1 - 26:,
        RTY_NF_F1           27:1 - 27:,
        RETUW_NT_F1         28:1 - 28:,
        FILED_1_73_F1       1:1 - 73:,        
        CTR_NF_F2 			 	  3:1 -  3:,                   
				SEC_NF_F2 			 	  5:1 -  5:,          
				UWY_NF_F2        	 	6:1 -  6:, 
				UW_NF_F2        	 	7:1 -  7:      		          
/JOINKEYS RETCTR_NF_F1,
          RETSEC_NF_F1,
          RTY_NF_F1,
          RETUW_NT_F1  
/INFILE ${ESF_OIRDVPERICASE} 2000 1 "~"          
/JOINKEYS CTR_NF_F2,
          SEC_NF_F2,
          UWY_NF_F2,          
          UW_NF_F2           
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: FILED_1_73_F1
exit
EOF
SORT

NSTEP=${NJOB}_06A
#Ventilation du Suffixe en fonction de la norme
#-----------------------------------------------------------------------------
LIBEL="Ventilation du Suffixe en fonction de la norme L ou P"
AWK_I="${DFILT}/${NJOB}_06_${IB}_SORT_DLREGTR_DACI17.dat"
AWK_O="${DFILT}/${NSTEP}_${IB}_AWK_DLREGTR_DACI17.dat"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {


 { \$6=substr(\$6,1,7) "${NORME_SUFFIX}" ; print \$0; }
  if (substr(\$7,8,1) == "I")
    { \$7=substr(\$7,1,7) "${NORME_SUFFIX}" ; print \$0; }

  }
exit
EOF
AWK


##[032]

# [028]
NSTEP=${NJOB}_07
LIBEL="Selection contrat AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_STD} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_STD_CTR_AI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
    PER_CTR_NF       1:1 - 1:,
    PER_END_NT       2:1 - 2:,
    PER_SEC_NF       3:1 - 3:,
    PER_UWY_NF       4:1 - 4:,
    PER_UW_NT        5:1 - 5:,
    PER_CTRRET_B     20:1 - 20:EN
/KEYS
    PER_CTR_NF,
    PER_END_NT,
    PER_SEC_NF,
    PER_UWY_NF,
    PER_UW_NT
/CONDITION COND_AI ( PER_CTRRET_B = 1 )
/OUTFILE ${SORT_O} overwrite
/INCLUDE COND_AI
exit
EOF
SORT

fi

#[020] Prise en compte des AI I17

NSTEP=${NJOB}_10
LIBEL="Merge GTASII ALL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3742${TYPEINV}_${CONTEXT_CT}_40_${IB}_ESFC3742_GTASII.dat 2000 1"
SORT_I2="${EST_EXPENSES} 2000 1"
SORT_I3="${EST_GTSII_EXPENSES_PAID} 2000 1"
SORT_I5="${EST_ACC_NDIC} 2000 1"
SORT_I6="${ESF_DLDGTAA_E} 2000 1"
SORT_I7="${ESF_DLREGTARSII} 2000 1"
SORT_I8="${ESF_DLDGTARSII} 2000 1"
SORT_I9="${ESF_DLCUMGTAAR_MVT_AGG} 2000 1"
# SORT_I10="${ESF_DLCUMGTAAR_MVT_AGG_RET} 2000 1"
SORT_I10="${ESF_FTECLEDA_NTC} 2000 1"  #[051]
SORT_I11="${EST_GTASII_OTHER} 2000 1"
SORT_I12="${ESF_AET_DLSGTAA} 2000 1"
SORT_I13="${ESF_AET_DLSGTAR} 2000 1"
#SORT_I14="${EST_ACC_NDIC_RET} 2000 1"
#SORT_I15="${EST_ACC_NDIC_RET_P_GTAR} 2000 1"
if [ "${CONTEXT_CT}" = STD ]
then
	#SORT_I14="${DFILT}/${NJOB}_05_${IB}_DLREGTAR_DACI17_ESFC3743.dat 2000 1" #[017]
	SORT_I14="${DFILT}/${NJOB}_05_${IB}_DACI17_NDC_ALL_STD_ESFC3743.dat 2000 1" #[021]	
	SORT_I15="${DFILT}/${NJOB}_02A_${IB}_AWK_DACC_NDIC_RETRO.dat 2000 1" #[021]
  SORT_I16="${ESF_DLRGTAA_LCC_INI} 2000 1" 	
  SORT_I17="${ESF_DLRGTAA_NDC_INI} 2000 1"  	
fi 
 
if [ "${CONTEXT_CT}" != STD ]
then
  SORT_I18="${ESF_DLRGTAA} 2000 1"  #[030]
  SORT_I19="${ESF_DLRGTAA_NDC_TC} 2000 1"  
fi

SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:
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
/OUTFILE ${SORT_O}
exit
EOF
SORT

# [022] 
NSTEP=${NJOB}_11
LIBEL="Split GTASII ALL by TRNCODE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_GTASII_ALL.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_ALL_SPLIT.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_GTASII_ALL_OTHER.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:2 -  6:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:,
        ACMTRS3_NT       72:1 - 72:

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
        CUR_CF,
        ACMTRS3_NT DESC  

/CONDITION COND1 ( TRNCOD_CF = "112121${NORME_SUFFIX}" )
/CONDITION COND2 ( TRNCOD_CF != "112121${NORME_SUFFIX}" )

/OUTFILE ${SORT_O}
/INCLUDE COND1

/OUTFILE ${SORT_O2}
/INCLUDE COND2

exit
EOF
SORT

# [022] #[047] Ajout TRNCOD1_CF Dans cle Cumul
NSTEP=${NJOB}_11_1
LIBEL="Sum amount of Change in Estimates - Future Receivables"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_11_${IB}_GTASII_ALL_SPLIT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_ALL_SPLIT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
				TRNCOD1_CF	  		6:1 -  6:1,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,   
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        AMT_M           19:1 - 19:EN,
        RETAMT_M        35:1 - 35:EN

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
        CUR_CF,
        TRNCOD1_CF

/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_12
LIBEL="Merge GTASII ALL SPLIT + OTHER"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_11_${IB}_GTASII_ALL_OTHER.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_11_1_${IB}_GTASII_ALL_SPLIT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_ALL.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:
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

/OUTFILE ${SORT_O}
exit
EOF
SORT



if [ "${CONTEXT_CT}" != STD ]
then


NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Supression de Multiyear Contracts dans TECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_12_${IB}_GTASII_ALL.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 224:,
        PER_CTR_NF           1:1 - 1:,
        PER_END_NT           2:1 - 2:,
        PER_SEC_NF           3:1 - 3:,
        PER_UWY_NF           4:1 - 4:,
        PER_UW_NT            5:1 - 5:
/joinkeys
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT
/INFILE ${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3742${TYPEINV}_${CONTEXT_CT}_00_${IB}_TCRCONTR_CRUWY.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT


else
        # [028] Start update 
        if [[ $NORME_CF = I17G || $NORME_CF = I17S ]]
        then

        NSTEP=${NJOB}_16
        LIBEL="Sort FPRSMAP STD"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${EST_FPRSMAP_TXT} 2000 1"
        SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FPRSMAP_TXT.dat  2000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS UWD_TL  10:1 - 10:
        /KEYS   UWD_TL
        /SUMMARIZE
        /OUTFILE ${SORT_O} overwrite
        /REFORMAT UWD_TL
        exit
EOF
SORT

        NSTEP=${NJOB}_17A
        LIBEL="Split GTASII by trncode Unwind + Change EGPI/EST"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_12_${IB}_GTASII_ALL.dat 2000 1"
        SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_UWI_EGPI_EST.dat  2000 1"
        SORT_O2="${DFILT}/${NSTEP}_${IB}_GTASII_OTHER.dat  2000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS CTR_NF            8:1 -  8:,
                END_NT            9:1 -  9:EN,
                SEC_NF           10:1 - 10:EN,
                UWY_NF           11:1 - 11:,
                UW_NT            12:1 - 12:EN,
                CUR_CF           18:1 - 18:,
                RETCTR_NF        24:1 - 24:,
                RETEND_NT        25:1 - 25:,
                RETSEC_NF        26:1 - 26:,
                RTY_NF           27:1 - 27:,
                RETUW_NT         28:1 - 28:,
                PLC_NT           36:1 - 36:EN,
                SEGNAT_CT        48:1 - 48:,
                ACCRET_CF        49:1 - 49:,
                NORME_CF         50:1 - 50:,
                TRNCOD5          6:3  - 6:7
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
        /CONDITION COND ( TRNCOD5 = "42618"
        OR TRNCOD5 = "41619"
        OR TRNCOD5 = "42760"
        OR TRNCOD5 = "42750"
        OR TRNCOD5 = "12121"
        OR TRNCOD5 = "12200"
        OR TRNCOD5 = "49100"
        OR TRNCOD5 = "43667"
        OR TRNCOD5 = "46077"
        OR TRNCOD5 = "49300"
        OR TRNCOD5 = "49350"
        OR TRNCOD5 = "43062"
        OR TRNCOD5 = "43064"
        OR TRNCOD5 = "43063"
        OR TRNCOD5 = "49340"
        OR TRNCOD5 = "10121"
        OR TRNCOD5 = "12220"
        OR TRNCOD5 = "49120"
        OR TRNCOD5 = "43666"
        OR TRNCOD5 = "46075"
        OR TRNCOD5 = "49320"
        OR TRNCOD5 = "49440"
        OR TRNCOD5 = "43065"
        OR TRNCOD5 = "43067"
        OR TRNCOD5 = "43066"
        OR TRNCOD5 = "49360"
        )
        /OUTFILE ${SORT_O} overwrite
        /INCLUDE COND
        /OUTFILE ${SORT_O2} overwrite
        /OMIT COND
        exit
EOF
SORT

        NSTEP=${NJOB}_17B
        LIBEL="Select GTASII by Unwind from FPRSMAP"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_17A_${IB}_GTASII_OTHER.dat 2000 1"
        SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_UWI.dat  2000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS TRNCOD5       6:3  - 6:7,
                UWD_TL        1:1  - 1:,
                GT_ALL_COLS   1:1  - 71:
        /joinkeys
                TRNCOD5
        /INFILE ${DFILT}/${NJOB}_16_${IB}_SORT_FPRSMAP_TXT.dat 2000 1 "~"
        /joinkeys
                UWD_TL
        /OUTFILE ${SORT_O} overwrite
        /REFORMAT
                leftside :GT_ALL_COLS
        exit
EOF
SORT

        NSTEP=${NJOB}_17C
        LIBEL="Select Other GTASII"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_17A_${IB}_GTASII_OTHER.dat 2000 1"
        SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_OTHER.dat  2000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS TRNCOD5       6:3  - 6:7,
                UWD_TL        1:1  - 1:,
                GT_ALL_COLS   1:1  - 71:
        /joinkeys
                TRNCOD5
        /INFILE ${DFILT}/${NJOB}_16_${IB}_SORT_FPRSMAP_TXT.dat 2000 1 "~"
        /joinkeys
                UWD_TL
        /JOIN UNPAIRED LEFTSIDE ONLY
        /OUTFILE ${SORT_O} overwrite
        /REFORMAT
                leftside :GT_ALL_COLS
        exit
EOF
SORT

        NSTEP=${NJOB}_17
        LIBEL="Merge Unwind from FPRSMAP and Unwind + Change EGPI/EST"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_17A_${IB}_GTASII_UWI_EGPI_EST.dat 2000 1"
        SORT_I2="${DFILT}/${NJOB}_17B_${IB}_GTASII_UWI.dat 2000 1"
        SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_UWI_EGPI_EST.dat  2000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS CTR_NF            8:1 -  8:,
                END_NT            9:1 -  9:EN,
                SEC_NF           10:1 - 10:EN,
                UWY_NF           11:1 - 11:,
                UW_NT            12:1 - 12:EN,
                CUR_CF           18:1 - 18:,
                RETCTR_NF        24:1 - 24:,
                RETEND_NT        25:1 - 25:,
                RETSEC_NF        26:1 - 26:,
                RTY_NF           27:1 - 27:,
                RETUW_NT         28:1 - 28:,
                PLC_NT           36:1 - 36:EN,
                SEGNAT_CT        48:1 - 48:,
                ACCRET_CF        49:1 - 49:,
                NORME_CF         50:1 - 50:,
                TRNCOD6          6:3  - 6:7
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

        NSTEP=${NJOB}_18A
        LIBEL="Exclude contrat AI NORME ${NORME_CF}"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_17_${IB}_GTASII_UWI_EGPI_EST.dat 2000 1"
        SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_NOT_AI.dat  2000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS GT_CTR_NF       8:1 -  8:,
                GT_END_NT       9:1 -  9:,
                GT_SEC_NF       10:1 - 10:,
                GT_UWY_NF       11:1 - 11:,
                GT_UW_NT        12:1 - 12:,
                GT_ALL_COLS     1:1 - 71:,
                PER_CTR_NF      3:1 - 3:,
                PER_END_NT      4:1 - 4:,
                PER_SEC_NF      5:1 - 5:,
                PER_UWY_NF      6:1 - 6:,
                PER_UW_NT       7:1 - 7:
        /joinkeys
                GT_CTR_NF,
                GT_END_NT,
                GT_SEC_NF,
                GT_UWY_NF,
                GT_UW_NT
        /INFILE ${DFILT}/${NJOB}_07_${IB}_IADPERICASE_STD_CTR_AI.dat 2000 1 "~"
        /joinkeys
                PER_CTR_NF,
                PER_END_NT,
                PER_SEC_NF,
                PER_UWY_NF,
                PER_UW_NT
        /JOIN UNPAIRED LEFTSIDE ONLY
        /OUTFILE ${SORT_O} overwrite
        /REFORMAT
                leftside :GT_ALL_COLS
        exit
EOF
SORT
        # [033]
        # [040] remove /JOIN UNPAIRED LEFTSIDE
        NSTEP=${NJOB}_18B
        LIBEL="selection Unwind + EGPI + EST contrat AI NORME ${NORME_CF}"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_17_${IB}_GTASII_UWI_EGPI_EST.dat 2000 1"
        SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_UWI_EGPI_EST_AI.dat  2000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS GT_CTR_NF       8:1 -  8:,
                GT_END_NT       9:1 -  9:,
                GT_SEC_NF       10:1 - 10:,
                GT_UWY_NF       11:1 - 11:,
                GT_UW_NT        12:1 - 12:,
                GT_ALL_COLS     1:1 - 71:,
                PER_CTR_NF      3:1 - 3:,
                PER_END_NT      4:1 - 4:,
                PER_SEC_NF      5:1 - 5:,
                PER_UWY_NF      6:1 - 6:,
                PER_UW_NT       7:1 - 7:
        /joinkeys
                GT_CTR_NF,
                GT_END_NT,
                GT_SEC_NF,
                GT_UWY_NF,
                GT_UW_NT
        /INFILE ${DFILT}/${NJOB}_07_${IB}_IADPERICASE_STD_CTR_AI.dat 2000 1 "~"
        /joinkeys
                PER_CTR_NF,
                PER_END_NT,
                PER_SEC_NF,
                PER_UWY_NF,
                PER_UW_NT
        /OUTFILE ${SORT_O} overwrite
        /REFORMAT
                leftside :GT_ALL_COLS
        exit
EOF
SORT
        # [033] #[037] #[039]
        NSTEP=${NJOB}_18
        LIBEL="GTASII EST/EGPI/Unwind with AI (without AI assumed)"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_18B_${IB}_GTASII_UWI_EGPI_EST_AI.dat  2000 1"
        SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_UWI_EGPI_EST_FILTRED_AI.dat  2000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS TRNCOD1_CF       6:1 -  6:1,
                TRNCOD2_CF       6:2 -  6:2,
        	CTR_NF            8:1 -  8:,
                END_NT            9:1 -  9:EN,
                SEC_NF           10:1 - 10:EN,
                UWY_NF           11:1 - 11:,
                UW_NT            12:1 - 12:EN,
                CUR_CF           18:1 - 18:,
                RETCTR_NF        24:1 - 24:,
                RETEND_NT        25:1 - 25:,
                RETSEC_NF        26:1 - 26:,
                RTY_NF           27:1 - 27:,
                RETUW_NT         28:1 - 28:,
                PLC_NT           36:1 - 36:EN,
                SEGNAT_CT        48:1 - 48:,
                ACCRET_CF        49:1 - 49:,
                NORME_CF         50:1 - 50:,
                TRNCOD6          6:3  - 6:7
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
        /CONDITION ASS_WITH_RET ( ( TRNCOD1_CF EQ "1" ) and ( TRNCOD2_CF EQ "1" ) )
        /OUTFILE ${SORT_O}
        /OMIT ASS_WITH_RET
        exit
EOF
SORT
			  # [045] # [049] 
			  
        NSTEP=${NJOB}_19
        LIBEL="Retro Change/Unwind format TTECLEDR"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        ##SORT_I="${DFILT}/${NJOB}_18A_${IB}_GTASII_NOT_AI.dat 2000 1" # [049] 
        SORT_I="${DFILT}/${NJOB}_17_${IB}_GTASII_UWI_EGPI_EST.dat 2000 1"
        SORT_O="${ESF_AICHG_UWI} 2000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS BALSHEY_NF       3:1 -  3: EN,
                BALSHRMTH_NF     4:1 -  4: EN,
                TRNCOD1_CF       6:1 -  6:1,
                TRNCOD2_CF       6:2 -  6:2,                
                CTR_NF           8:1 -  8:,
                END_NT           9:1 -  9:,
                SEC_NF          10:1 - 10:,
                UWY_NF          11:1 - 11:,
                UW_NT           12:1 - 12:,
                CUR_CF          18:1 -  18:,
                RETCTR_NF       24:1 - 24:,
                RETEND_NT       25:1 - 25:,
                RETSEC_NF       26:1 - 26:,
                RTY_NF          27:1 - 27:,
                RETUW_NT        28:1 - 28:,
                PLC_NT          36:1 - 36:EN,
                SEGNAT_CT       48:1 - 48:,
                ACCRET_CF       49:1 - 49:,
                LIGNEGT          1:1 - 39:,
                RETKEY_CF       40:1 - 40:,
                SEG_NF          46:1 - 46:,
                FILLER_26_COLS  45:1 - 71:
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
                CUR_CF,
                SEG_NF
        /DERIVEDFIELD DATTRAIT "${CRE_D}~"
        /DERIVEDFIELD USER "CloP~"
        /CONDITION COND_GTAR (( TRNCOD1_CF EQ "2" ) and ( TRNCOD2_CF EQ "1" ) )
        /OUTFILE ${SORT_O}
        /INCLUDE COND_GTAR
        /REFORMAT LIGNEGT,
                RETKEY_CF,
                DATTRAIT,
                USER,
                DATTRAIT,
                USER,
                FILLER_26_COLS
        exit
EOF
SORT

        # [034]
        # [040] remove step 20A

        # [033]
        # [040] merge GTASII OTHERS + GTASII EST/EGPI/UWI without AI (ass & retro) + GTASII EST/EGPI/Unwind with AI (without AI assumed)
        NSTEP=${NJOB}_20
        LIBEL="Merge GTASII OTHERS + GTASII EST/EGPI/Unwind without AI (ass & retro) + GTASII EST/EGPI/Unwind with AI (without AI assumed)"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_17C_${IB}_GTASII_OTHER.dat 2000 1"
        SORT_I2="${DFILT}/${NJOB}_18A_${IB}_GTASII_NOT_AI.dat 2000 1"
        SORT_I3="${DFILT}/${NJOB}_18_${IB}_GTASII_UWI_EGPI_EST_FILTRED_AI.dat 2000 1"
        SORT_O="${DFILT}/${NSTEP}_${IB}_GTASII_ALL.dat  2000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS CTR_NF           8:1 -  8:,
                END_NT           9:1 -  9:,
                SEC_NF          10:1 - 10:,
                UWY_NF          11:1 - 11:,
                UW_NT           12:1 - 12:,
                CUR_CF          18:1 -  18:,
                RETCTR_NF       24:1 - 24:,
                RETEND_NT       25:1 - 25:,
                RETSEC_NF       26:1 - 26:,
                RTY_NF          27:1 - 27:,
                RETUW_NT        28:1 - 28:,
                PLC_NT          36:1 - 36:EN,
                SEGNAT_CT       48:1 - 48:,
                ACCRET_CF       49:1 - 49:,
                SEG_NF		46:1 - 46:
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
                CUR_CF,
                SEG_NF
        /OUTFILE ${SORT_O}
        exit
EOF
SORT
        # [028] End update 
        else

        NSTEP=${NJOB}_20
        LIBEL="copy file"
        EXECKSH "cp ${DFILT}/${NJOB}_12_${IB}_GTASII_ALL.dat ${DFILT}/${NJOB}_20_${IB}_GTASII_ALL.dat"

        fi
fi

#ESF_FTECLEDA

NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance Technical Ledgers File to format TTCLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_GTASII_ALL.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA.dat  2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD1_CF       6:1 -  6:1,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:,
        LIGNEGT          1:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:,
	SEG_NF		46:1 - 46:,
        FILLER_30_COLS  42:1 - 71:
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
        CUR_CF,
	SEG_NF
/CONDITION COND_GTAA0 ( TRNCOD1_CF eq "1" )
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_MC,
          FILLER_30_COLS
exit
EOF
SORT

#[041] [042] [048]

if [ "${IDF_CT}" = "I17G_SII_GLT_INI" ] || [ "${IDF_CT}" = "I17S_SII_GLT_INI" ] 
then

## Separate RETRO without Assume to Other before join with PERICASE 

NSTEP=${NJOB}_32A
# FILTER ACCEPT AND RETRO PROP ONLY
#-----------------------------------------------------------------------------
LIBEL="FILTER ON ACCEPT AND RETRO PROP ONLY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_FTECLEDA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_ASS_RET.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTECLEDA_RET.dat 2000 1"
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
/CONDITION  RETRO_SANS_ASSUME ( (CTR_NF = "") and  (END_NF = "") and (SEC_NF = "") and (UWY_NF = "") and  (TRNCOD1_CF = "2")  )                
/OUTFILE ${SORT_O}
/OMIT RETRO_SANS_ASSUME 	
/OUTFILE ${SORT_O2}
/INCLUDE RETRO_SANS_ASSUME 												  
exit
EOF
SORT

##SORT_I="${DFILT}/${NJOB}_30_${IB}_FTECLEDA.dat 2000 1"


NSTEP=${NJOB}_32
#-----------------------------------------------------------------------------
LIBEL="Join PERICASE INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_32A_${IB}_FTECLEDA_ASS_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_ASS_RET.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        PER_CTR_NF      3:1 - 3:,
        PER_END_NT      4:1 - 4:,
        PER_SEC_NF      5:1 - 5:,
        PER_UWY_NF      6:1 - 6:,
        PER_UW_NT       7:1 - 7:,
        FILLER1         1:1 - 118:,
        CTRRET_B        20:1 - 20:
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${ESF_IADPERICASE_INI} 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :FILLER1, rightside:CTRRET_B
exit
EOF
SORT





#[041] #[048]

NSTEP=${NJOB}_32B
LIBEL="Selection contrat AI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_32_${IB}_FTECLEDA_ASS_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_ASS_RET.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
    FILLER1        1:1 - 118:,
    CTRRET_B      119:1 - 119:EN,
    TRNCOD1_CT     6:1  - 6:1
/CONDITION COND_AI ( CTRRET_B = 0 or ( CTRRET_B = 1 and TRNCOD1_CT != "1" ) )
/OUTFILE ${SORT_O} overwrite
/INCLUDE COND_AI
/REFORMAT FILLER1
exit
EOF
SORT


#[041] #[048]
NSTEP=${NJOB}_33
LIBEL="Merge FTECLEDA_RET With FTECLEDA_ASS_RET"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_32B_${IB}_FTECLEDA_ASS_RET.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_32A_${IB}_FTECLEDA_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:2 -  6:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:

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



fi



NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
# Merge and sort of Retrocession files
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledgers File format TTECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3742${TYPEINV}_${CONTEXT_CT}_40_${IB}_ESFC3742_GTRSII.dat 2000 1"
SORT_I2="${EST_GTRSII_OTHER} 2000 1"
# SORT_I4="${ESF_DLREGTR} 2000 1" 
SORT_I4="${ESF_FTECLEDR_NTC} 2000 1"  #[051]
SORT_I5="${ESF_DLDGTR_E} 2000 1"
SORT_I6="${EST_ACC_NDIC_RET} 2000 1"
SORT_I7="${ESF_DLCUMGTAAR_MVT_AGG_RET} 2000 1"
SORT_I8="${ESF_AET_DLSGTR} 2000 1"
#SORT_I9="${EST_ACC_NDIC_RET_P_GTR} 2000 1"
#if [ "${NORME_CF}" = I17G  -a "${CONTEXT_CT}" = STD ]
if [ "${CONTEXT_CT}" = STD ]
then
  #SORT_I9="${ESF_DLREGTR_DACI17} 2000 1"
  SORT_I9="${DFILT}/${NJOB}_06A_${IB}_AWK_DLREGTR_DACI17.dat 2000 1"  #[032]
	SORT_I10="${DFILT}/${NJOB}_02A_${IB}_AWK_DACC_NDIC_RETRO.dat 2000 1" #[021]	

fi

SORT_O="${DFILT}/${NSTEP}_${IB}_GTRSII_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:
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
/OUTFILE ${SORT_O}
exit
EOF
SORT

# [021]
NSTEP=${NJOB}_41
LIBEL="Split GTRSII ALL by TRNCODE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_GTRSII_ALL.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTRSII_ALL_SPLIT.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_GTRSII_ALL_OTHER.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:2 -  6:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        RETCUR_CT        34:1 - 34:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:,
        ACMTRS3_NT       72:1 - 72:

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
        RETCUR_CT,
        ACMTRS3_NT DESC 

/CONDITION COND1 ( TRNCOD_CF = "112121${NORME_SUFFIX}" )
/CONDITION COND2 ( TRNCOD_CF != "112121${NORME_SUFFIX}" )

/OUTFILE ${SORT_O}
/INCLUDE COND1

/OUTFILE ${SORT_O2}
/INCLUDE COND2

exit
EOF
SORT

# [021] # [047]
NSTEP=${NJOB}_42
LIBEL="Sum amount of Change in Estimates - Future Receivables and Prime actual"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_41_${IB}_GTRSII_ALL_SPLIT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTRSII_ALL_SPLIT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
	TRNCOD1_CF	  6:1 -  6:1,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,   
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        RETCUR_CT        34:1 - 34:,
        AMT_M            19:1 - 19:EN,
        RETAMT_M         35:1 - 35:EN

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
        RETCUR_CT,
        TRNCOD1_CF

/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

# [021]
NSTEP=${NJOB}_43
LIBEL="Merge GTRSII ALL SPLIT + OTHER"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_41_${IB}_GTRSII_ALL_OTHER.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_42_${IB}_GTRSII_ALL_SPLIT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTRSII_ALL.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:
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

/OUTFILE ${SORT_O}
exit
EOF
SORT


if [ "${CONTEXT_CT}" != STD ]
then

# [031]
NSTEP=${NJOB}_44A
#-----------------------------------------------------------------------------
LIBEL="Supression de Multiyear Contracts dans TECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_GTRSII_ALL.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTRSII_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 224:,
        PER_CTR_NF           1:1 - 1:,
        PER_END_NT           2:1 - 2:,
        PER_SEC_NF           3:1 - 3:,
        PER_UWY_NF           4:1 - 4:,
        PER_UW_NT            5:1 - 5:
/joinkeys
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT
/INFILE ${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3742${TYPEINV}_${CONTEXT_CT}_00_${IB}_TCRCONTR_CRUWY.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

NSTEP=${NJOB}_44B
#-----------------------------------------------------------------------------
LIBEL="Supression de Multiyear Contracts dans ESF_DLREGTARSII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLREGTARSII} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLREGTARSII.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF    8:1 -  8:,
        GT_END_NT    9:1 -  9:,
        GT_SEC_NF    10:1 - 10:,
        GT_UWY_NF    11:1 - 11:,
        GT_UW_NT     12:1 - 12:,
        GT_ALL_COLS          1:1 - 224:,
        PER_CTR_NF           1:1 - 1:,
        PER_END_NT           2:1 - 2:,
        PER_SEC_NF           3:1 - 3:,
        PER_UWY_NF           4:1 - 4:,
        PER_UW_NT            5:1 - 5:
/joinkeys
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT
/INFILE ${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3742${TYPEINV}_${CONTEXT_CT}_00_${IB}_TCRCONTR_CRUWY.dat 2000 1 "~"
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

NSTEP=${NJOB}_44C
#-----------------------------------------------------------------------------
LIBEL="Generate DLREGTRSII FROM --> DLREGTARSII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_44B_${IB}_DLREGTARSII.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_DLREGTRSII.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CHAMPS_1A7 1:1 - 7:,
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
        CHAMPS_8A18_VIDE 8:1 - 18:,        
        AMT_M 19:1 - 19: EN 15/3,
        CHAMPS_20A23_VIDE 20:1 - 23:,
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
        CHAMPS_37A40 37:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        CHAMPS_42A57 42:1 - 57:,
        RETROAUTO_B 58:1 - 58:,
        CHAMPS_59A72 59:1 - 74:
/KEYS   
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
        TRNCOD_CF,
        RETROAUTO_B
/SUMMARIZE  TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC 0
/DERIVEDFIELD CHAMPS_20A23_VIDE_NEW 5"~"
/DERIVEDFIELD CHAMPS_8A18_VIDE_NEW 11"~"
/OUTFILE ${SORT_O}
/REFORMAT 
        CHAMPS_1A7, 
        CHAMPS_8A18_VIDE_NEW, 
        AMT_MC, 
        CHAMPS_20A23_VIDE_NEW, 
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
        CHAMPS_37A40,
        RETINTAMT_MC,
        CHAMPS_42A57,
        RETROAUTO_B,
        CHAMPS_59A72
exit
EOF
SORT

NSTEP=${NJOB}_45
LIBEL="Merge GTRSII ALL and DLREGTRSII"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_44A_${IB}_GTRSII_ALL.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_44C_${IB}_DLREGTRSII.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTRSII_ALL.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        PLC_NT           36:1 - 36:EN,
        SEGNAT_CT        48:1 - 48:,
        ACCRET_CF        49:1 - 49:,
        NORME_CF         50:1 - 50:
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
/OUTFILE ${SORT_O}
exit
EOF
SORT


else
	NSTEP=${NJOB}_45
        LIBEL="copy file"
	EXECKSH "cp ${DFILT}/${NJOB}_43_${IB}_GTRSII_ALL.dat ${DFILT}/${NJOB}_45_${IB}_GTRSII_ALL.dat"
fi


NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
# Merge and sort of the Acceptance and Retrocession files
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File format TTECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_GTRSII_ALL.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 -  3: EN,
        BALSHRMTH_NF     4:1 -  4: EN,
        TRNCOD1_CF       6:1 -  6:1,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        CUR_CF          18:1 -  18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        PLC_NT          36:1 - 36:EN,
        SEGNAT_CT       48:1 - 48:,
        ACCRET_CF       49:1 - 49:,
        LIGNEGT          1:1 - 39:,
        RETKEY_CF       40:1 - 40:,
	SEG_NF          46:1 - 46:,
        FILLER_26_COLS  45:1 - 71:
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
        CUR_CF,
	SEG_NF
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/CONDITION COND_GTAR0 ( TRNCOD1_CF EQ "2" )
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          FILLER_26_COLS
exit
EOF
SORT

#[041] [042]
if [ "${IDF_CT}" = "I17G_SII_GLT_INI" ] || [ "${IDF_CT}" = "I17S_SII_GLT_INI" ]
then

NSTEP=${NJOB}_60
# #[043] Creation d'un fichier AT INI avec TRNCOD INI
#-----------------------------------------------------------------------------
# [035] [036] [043] [044] [046] 
LIBEL="reverse TECLEDA amount by trncode contraints"
#AWK_I="${DFILT}/${NJOB}_30_${IB}_FTECLEDA.dat"
AWK_I="${DFILT}/${NJOB}_33_${IB}_FTECLEDA.dat"
AWK_O=${ESF_FTECLEDA}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( ("${CONTEXT_CT}" == "INI") \
        \&& (substr(\$6,3,5) != "10014") \
        \&& (substr(\$6,3,5) != "10018") \
        \&& (substr(\$6,3,5) != "12014") \
        \&& (substr(\$6,3,5) != "12018") \
        \&& (substr(\$6,3,5) != "12122") \
        \&& (substr(\$6,3,5) != "12128") \
        \&& (substr(\$6,3,5) != "12161") \
        \&& (substr(\$6,3,5) != "10100") \
        \&& (substr(\$6,3,5) != "10061") \
        \&& (substr(\$6,3,5) != "10062") \
        \&& (substr(\$6,3,5) != "12061") \
        \&& (substr(\$6,3,5) != "12062") \
        \&& (substr(\$6,3,5) != "12063") \
        \&& (substr(\$6,3,5) != "14061") \
        \&& (substr(\$6,3,5) != "49461") \
        \&& (substr(\$6,3,5) != "49462") \
        \&& (substr(\$6,3,5) != "43014") \
        \&& (substr(\$6,3,5) != "43024") \
        \&& (substr(\$6,3,5) != "43034") )
        {
                \$19 = sprintf("%-.3lf",-\$19 );
                \$35 = sprintf("%-.3lf",-\$35 );
                \$88 = sprintf("%-.3lf",-\$88 );
        }

        if ( ("${CONTEXT_CT}" == "INI") \&& (substr(\$6,2,6) == "A49510" ) )
        {
                \$19 = sprintf("%-.3lf",-\$19 );
                \$35 = sprintf("%-.3lf",-\$35 );
                \$88 = sprintf("%-.3lf",-\$88 );
        }

        print \$0;
  }
exit
EOF
AWK


else

NSTEP=${NJOB}_60
# #[043] Creation d'un fichier AT INI avec TRNCOD INI
#-----------------------------------------------------------------------------
# [035] [036] [043] [044] [046] 
LIBEL="reverse TECLEDA amount by trncode contraints"
AWK_I="${DFILT}/${NJOB}_30_${IB}_FTECLEDA.dat"
AWK_O=${ESF_FTECLEDA}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        if ( ("${CONTEXT_CT}" == "INI") \
        \&& (substr(\$6,3,5) != "10014") \
        \&& (substr(\$6,3,5) != "10018") \
        \&& (substr(\$6,3,5) != "12014") \
        \&& (substr(\$6,3,5) != "12018") \
        \&& (substr(\$6,3,5) != "12122") \
        \&& (substr(\$6,3,5) != "12128") \
        \&& (substr(\$6,3,5) != "12161") \
        \&& (substr(\$6,3,5) != "10100") \
        \&& (substr(\$6,3,5) != "10061") \
        \&& (substr(\$6,3,5) != "10062") \
        \&& (substr(\$6,3,5) != "12061") \
        \&& (substr(\$6,3,5) != "12062") \
        \&& (substr(\$6,3,5) != "12063") \
        \&& (substr(\$6,3,5) != "14061") \
        \&& (substr(\$6,3,5) != "49461") \
        \&& (substr(\$6,3,5) != "49462") \
        \&& (substr(\$6,3,5) != "43014") \
        \&& (substr(\$6,3,5) != "43024") \
        \&& (substr(\$6,3,5) != "43034") )
        {
                \$19 = sprintf("%-.3lf",-\$19 );
                \$35 = sprintf("%-.3lf",-\$35 );
		\$88 = sprintf("%-.3lf",-\$88 );		
        }

        if ( ("${CONTEXT_CT}" == "INI") \&& (substr(\$6,2,6) == "A49510" ) )
        {
                \$19 = sprintf("%-.3lf",-\$19 );
                \$35 = sprintf("%-.3lf",-\$35 );
                \$88 = sprintf("%-.3lf",-\$88 ); 
        }

        print \$0;     
  }
exit
EOF
AWK

fi

NSTEP=${NJOB}_70
# #[043] Creation d'un fichier AT INI avec TRNCOD INI
#-----------------------------------------------------------------------------
# [035] [036] [043] [044] [046] 
LIBEL="reverse TECLEDR amount by trncode contraints "
AWK_I=${DFILT}/${NJOB}_50_${IB}_FTECLEDR.dat
AWK_O=${ESF_FTECLEDR}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
	if ( ("${CONTEXT_CT}" == "INI") \
        \&& (substr(\$6,3,5) != "10014") \
        \&& (substr(\$6,3,5) != "10018") \
        \&& (substr(\$6,3,5) != "12014") \
        \&& (substr(\$6,3,5) != "12018") \
        \&& (substr(\$6,3,5) != "12122") \
        \&& (substr(\$6,3,5) != "12128") \
        \&& (substr(\$6,3,5) != "12161") \
        \&& (substr(\$6,3,5) != "10100") \
        \&& (substr(\$6,3,5) != "10061") \
        \&& (substr(\$6,3,5) != "10062") \
        \&& (substr(\$6,3,5) != "12061") \
        \&& (substr(\$6,3,5) != "12062") \
        \&& (substr(\$6,3,5) != "12063") \
        \&& (substr(\$6,3,5) != "14061") \
        \&& (substr(\$6,3,5) != "49461") \
        \&& (substr(\$6,3,5) != "49462") \
        \&& (substr(\$6,3,5) != "43014") \
        \&& (substr(\$6,3,5) != "43024") \
        \&& (substr(\$6,3,5) != "43034") )
        {
	   	\$19 = sprintf("%-.3lf",-\$19 );
                \$35 = sprintf("%-.3lf",-\$35 );
	}

        if ( ("${CONTEXT_CT}" == "INI") \&& (substr(\$6,2,6) == "A49510" ) )
        {
                \$19 = sprintf("%-.3lf",-\$19 );
                \$35 = sprintf("%-.3lf",-\$35 ); 
        }

	print \$0;
  }
exit
EOF
AWK



JOBEND

