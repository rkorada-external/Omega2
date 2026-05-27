#!/bin/ksh
#====================================================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 11.2 : MAINTENANCE EXPENSES PAID CALCULATION 
# Nom du script SHELL           : ESID3741.cmd
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
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#	[001] 		07/03/2019 	L.ELFAHIM 	SPIRA : 71570 		Maintenance Expenses Paid calculation
#       [002]           24/07/2019      L.DOAN          SPIRA : 77079           Generating IFRS 17 Group TL file
#	[003]  		02/01/2020      L.DOAN       	SPIRA : 79100 		REQ21.9- Manage retro dummy contracts in closing
#  [004]    03/06/2020      L.DOAN          SPIRA : 79070           Add contre partie
#  [005]    09/07/2020      L.DOAN          SPIRA : 85208           add GTL REQ11.1 of ESFD3630
#  [006]		29/09/2020      L.DOAN					SPIRA : 79100 		dummy review	
#  [007]    14/10/2020      L.DOAN          SPIRA : 88514           Unwind amount is set to zero under recognized dates contraints
#  [008]    26/10/2020      L.DOAN          SPIRA : 90921 add LKI and UWD for DAC IFRS17
#  [009]    12/01/2021      L.DOAN          SPIRA : 92866 remove LKI and UWD for DAC IFRS17
#  [010]    19/02/2021      N.DOAN          SPIRA : 85522 technical cashflow flux
#  [011]    22/02/2021      N.DOAN          SPIRA : 90091 Multiyear changes on GLT transformation
#  [012]    17/02/2021      MZM             SPIRA : 100372 Error in unwind booking for some transactions
#  [013]    18/02/2021      MZM             SPIRA : 101440 MultiYear Formules MAJ
#  [014]    07/03/2021      MZM             SPIRA : 101440 MultiYear Formules MAJ et R03-09 (Rollback)
#  [015]    20/05/2022      DaD             SPIRA : 104362 fix bug MultiYear for INI
#  [016]    22/12/2022      DaD             SPIRA : 108136 fix bug - convert RECOD_D in condition querie sql 
#  [017]    03/05/2023      MZM             SPIRA : 109505 I17 - Retro P - Recognition of assumed contracts covered by assumed dummies (New Update R03-06 )
#====================================================================================================
#set -x


##  ******************************************************************************************************************  ###
##  ************************************[ R03-06 : Rule Update ]******************************************************  ###

##  If the retro contract has already been incepted in a previous quarter (retro first closing date < begin of quarter and inception status = "2- Booked")  
##     AND Assumed contracts are not dummies (portfolio origin different from 248)
##     and are initialized during the current quarter  
##              (and first closing date <= closing date and inception status = "1 - pending") 


##  ******************************************************************************************************************  ###
##  ************************************[ Retro For MultiYear : Rule ]************************************************  ###

##   If the retro contract has already been recognized in previous quarter (retro recognition date < begin of quarter)  
##    AND Assumed contracts recognized during the current quarter  (begin of quarter <= assumed recognition date<=closing Date)  then
##    Unwind (Pattern type = FWD):
##    No TL generation
##    IFRS17 revenue (REQ11.6)
##    Override Change in EGPI TL data generation rules defined in R03-04 (Excel matrix) as follows:
##    Case grouping 751= 1051
##    Change in EGPI (DSC)= EXP / EGPXX (DSC)
##    Case grouping 751<>1051
##    Change in EGPI (DSC)= (-1)* EXP / EGPXX (DSC)
##    Change in EGPI (RAD)= (-1)* EXP / EGPXX (RAD)
##    Change in EGPI (BDT)= (-1)* EXP / EGPXX (BDT)   
##  ******************************************************************************************************************  ###

# Call generic functions
. ${DUTI}/fctgen.cmd


CLODAT_D=${PARM_ICLODAT_D}

#TODO date to be defined
#POS_BOOKING_X_DT="20190823"   

NORME="${NORME_CF}"

# Get input parameters


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES " 


if [ ! -f ${ESF_GTSII_CASHFLOW} ]
then
        ECHO_LOG "ESF_GTSII_CASHFLOW=${ESF_GTSII_CASHFLOW}  does not exist, take an empty file"            >> $FLOG
        EXECKSH "touch ${ESF_GTSII_CASHFLOW}"

fi



if [ ! -f "${ESF_IADPERICASE_INI}" ]
then
    EXECKSH "touch ${ESF_IADPERICASE_INI}"

fi

##  [012] & #  [013] deb

##NSTEP=${NJOB}_00
###-----------------------------------------------------------------------------
##LIBEL="Collecting Multiyear contracts"
##BCP_WAY="OUT"
##BCP_VER="+"
##BCP_O="${DFILT}/${NSTEP}_${IB}_TCRCONTR_CRUWY.dat"
##BCP_QRY="select c.CTR_NF,c.END_NT, c.SEC_NF, c.UWY_NF,c.UW_NT, cntr.MULTUWY_NF, CONVERT(VARCHAR(8),cntr.SCOINC_D,112) as SCOINC_D, CONVERT(VARCHAR(8),cntr.SCOEXP_D,112) as SCOEXP_D , tcr.CRUWY_NF FROM BTRT..TSECIFRS a , BREF..TBATCHSSD b, BTRT..TSECTION c,BTRT..TCONTR cntr , BTRT..tcrcontr tc , BTRT..TCR tcr
##where b.BATCHUSER_CF = suser_name()
## AND b.SSD_CF = cntr.SSD_CF 
##AND a.CTR_NF = cntr.CTR_NF 
##AND a.UWY_NF = cntr.UWY_NF 
##AND a.UW_NT  = cntr.UW_NT 
##AND a.END_NT = cntr.END_NT  
##AND a.CTR_NF = c.CTR_NF AND a.UWY_NF = c.UWY_NF AND   a.UW_NT  = c.UW_NT   AND  a.END_NT = c.END_NT 
##AND a.SEC_NF  = C.SEC_NF 
##AND c.LOB_CF != '30' AND c.LOB_CF != '31' 
##AND c.SECSTS_CT IN (14, 16, 17, 19) 
##AND cntr.MULTUWY_NF is not null  
##AND a.CTR_NF=tc.CTR_NF 
##AND a.END_NT=tc.END_NT 
##AND a.UWY_NF=tc.UWY_NF 
##AND a.UW_NT =tc.UW_NT 
##AND tc.CR_NF  = tcr.CR_NF 
##AND tc.CRUWY_NF   = tcr.CRUWY_NF 
##and tc.CRUW_NT    = tcr.CRUW_NT 
##and tcr.CRUWY_NF  != a.UWY_NF 
##union 
##select c.CTR_NF,c.END_NT, c.SEC_NF, c.UWY_NF,c.UW_NT, cntr.MULTUWY_NF, CONVERT(VARCHAR(8),cntr.SCOINC_D,112) as SCOINC_D, CONVERT(VARCHAR(8),cntr.SCOEXP_D,112) as SCOEXP_D , tcr.CRUWY_NF
##FROM BFAC..TSECIFRS a , BREF..TBATCHSSD b, BFAC..TSECTION c,BFAC..TCONTR cntr , BFAC..tcrcontr tc , BFAC..TCR tcr
##where b.BATCHUSER_CF = suser_name()
##AND b.SSD_CF = cntr.SSD_CF
##AND a.CTR_NF = cntr.CTR_NF
##AND a.UWY_NF = cntr.UWY_NF
##AND a.UW_NT  = cntr.UW_NT
##AND a.END_NT = cntr.END_NT
##AND a.CTR_NF = c.CTR_NF AND a.UWY_NF = c.UWY_NF AND   a.UW_NT  = c.UW_NT    AND  a.END_NT = c.END_NT
##AND a.SEC_NF  = C.SEC_NF
##AND c.LOB_CF != '30' AND c.LOB_CF != '31'
##AND c.SECSTS_CT IN (14, 16, 17, 19)
##AND cntr.MULTUWY_NF is not null
##AND a.CTR_NF=tc.CTR_NF
##AND a.END_NT=tc.END_NT
##AND a.UWY_NF=tc.UWY_NF
##AND a.UW_NT =tc.UW_NT
##AND tc.CR_NF      = tcr.CR_NF
##AND tc.CRUWY_NF   = tcr.CRUWY_NF
##and tc.CRUW_NT    = tcr.CRUW_NT
##and tcr.CRUWY_NF  != a.UWY_NF"
##BCP

if [ ! -f "${EST_IADPERICASE_STD}" ]
then
    EXECKSH "touch ${EST_IADPERICASE_STD}"

fi

##

#et de le réduire aux Multi year d’ex <> CR uwy qui sont à leur first closing avec les conditions suivantes
#
#CR_CRUWY_NF (247) <> UWY_NF (5)
#et
#Si @norme = I17G:     SECIFRS_GRPINISTS_CT is null or SECIFRS_GRPINISTS_CT = 1 or (SECIFRS_GRPINISTS_CT = 2 and SECIFRS_GRPFIRCLO_D = @closing date)
#Si @norme = I17P:     SECIFRS_PARINISTS_CT is null or SECIFRS_ PARINISTS _CT = 1 or (SECIFRS_ PARINISTS _CT = 2 and SECIFRS_PARFIRCLO_D = @closing date)
#Si @norme = I17L:     SECIFRS_LOCINISTS_CT is null or SECIFRS_ LOCINISTS _CT = 1 or (SECIFRS_ LOCINISTS _CT = 2 and SECIFRS_LOCFIRCLO_D = @closing date)



NSTEP=${NJOB}_00
###-----------------------------------------------------------------------------
LIBEL="Collecting Multiyear contracts Extract From Pericase ${CONTEXT_CT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ ${CONTEXT_CT} = STD ] 
then
SORT_I="${EST_IADPERICASE_STD} 2000 1"
else
SORT_I="${ESF_IADPERICASE_INI} 2000 1" # [015]
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_TCRCONTR_CRUWY.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	   CTR_NF 													3:1 - 3:,
	   END_NT							  						4:1 - 4:,
	   SEC_NF							  						5:1 - 5:,
	   UWY_NF							  						6:1 - 6:,
	   UW_NT 							  						7:1 - 7:,
	   EXP_D                            28:1 - 28:,	   
	   SCOINC_D                         76:1 - 76:,
           CTRNAT_CT                        85:1 - 85:,
	   SECIFRS_GRPFIRCLO_D							216:1 - 216:,
	   SECIFRS_PARFIRCLO_D							220:1 - 220:,
	   SECIFRS_LOCFIRCLO_D 							224:1 - 224:,	   
	   SECIFRS_GRPINISTS_CT 						228:1 - 228:,
	   SECIFRS_PARINISTS_CT 						229:1 - 229:,
	   SECIFRS_LOCINISTS_CT							230:1 - 230:,
	   CR_CRUWY_NF							        248:1 - 248:	
/CONDITION MULTIYEAR  		(CR_CRUWY_NF != UWY_NF)  	   
/CONDITION MULTIYEAR_BY_NORME (CR_CRUWY_NF != UWY_NF) AND (CR_CRUWY_NF != "") AND (   ( (("$NORME_CF" = "I17G") or ("$NORME_CF" = "I17S"))  AND  ((SECIFRS_GRPINISTS_CT = "")  or (SECIFRS_GRPINISTS_CT = "1") or ((SECIFRS_GRPINISTS_CT = "2") and (SECIFRS_GRPFIRCLO_D = "${PARM_ICLODAT_D}") ) ) )
                                                           or ( ("$NORME_CF" = "I17P") AND  ((SECIFRS_PARINISTS_CT = "")  or (SECIFRS_PARINISTS_CT = "1") or ((SECIFRS_PARINISTS_CT = "2") and (SECIFRS_PARFIRCLO_D = "${PARM_ICLODAT_D}") ) ) )
                                                           or ( ("$NORME_CF" = "I17L") AND  ((SECIFRS_LOCINISTS_CT = "")  or (SECIFRS_LOCINISTS_CT = "1") or ((SECIFRS_LOCINISTS_CT = "2") and (SECIFRS_LOCFIRCLO_D = "${PARM_ICLODAT_D}") ) ) )
                                                           )
                                                
/DERIVEDFIELD BOOLMULTIYEAR_NEW if MULTIYEAR then "Y~" else "N~"                                                          
/OUTFILE ${SORT_O}
/INCLUDE MULTIYEAR_BY_NORME
/REFORMAT
	CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, BOOLMULTIYEAR_NEW, SCOINC_D, EXP_D, SECIFRS_GRPFIRCLO_D, SECIFRS_PARFIRCLO_D, SECIFRS_LOCFIRCLO_D, SECIFRS_GRPINISTS_CT, SECIFRS_PARINISTS_CT, SECIFRS_LOCINISTS_CT, CR_CRUWY_NF, CTRNAT_CT
exit
EOF
SORT 


## [012] & #  [013](PATCAT_CT="DSC" or (PATCAT_CT="RAD")) Filtre que sur le PATTYP_CT

NSTEP=${NJOB}_01A
#------------------------------------------------------------------------------------
LIBEL="Split GTSII to DSC/FWD  and Other"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_CASHFLOW} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTSII_DSC_FWD_SORT.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_GTSII_OTHER.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:3,
        PATTYP_CT        53:1 - 53:3,
        RETCTR_NF        24:1 - 24:,
        TYP_CT1          49:1 - 49:1
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION DSC_FWD ( (PATTYP_CT="FWD") or "${CONTEXT_CT}" = "INI" )
/OUTFILE ${SORT_O}
/INCLUDE DSC_FWD
/OUTFILE ${SORT_O2}
/OMIT DSC_FWD
exit
EOF
SORT

#  [012] fin

#  [014] #SORT_I="${DFILT}/${NJOB}_01A_${IB}_GTSII_DSC_FWD_SORT.dat 2000 1" 

NSTEP=${NJOB}_01B
#-----------------------------------------------------------------------------
LIBEL="Supression de Multiyear Contracts dans TECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01A_${IB}_GTSII_DSC_FWD_SORT.dat 2000 1" 
# SORT_I="${DFILT}/${NJOB}_01A_${IB}_GTSII_OTHER.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTSII_DSC_MUWY.dat 2000 1"
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
/INFILE ${DFILT}/${NJOB}_00_${IB}_TCRCONTR_CRUWY.dat 2000 1 "~"
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

NSTEP=${NJOB}_01
#------------------------------------------------------------------------------------
LIBEL="Merge to principal flux"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01B_${IB}_GTSII_DSC_MUWY.dat  2000 1"
SORT_I2="${DFILT}/${NJOB}_01A_${IB}_GTSII_OTHER.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FULL_GTSII_NO_MUWY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:3,
        PATTYP_CT        53:1 - 53:3,
        RETCTR_NF        24:1 - 24:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_02

LIBEL="Filter with ${NORME_CF} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01_${IB}_FULL_GTSII_NO_MUWY.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII.dat 2000 1"
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
        ACCRET_CF       49:1 - 49:,
        NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:,
        PATCAT3_CT       52:1 - 52:3,
        PATTYP_CT        53:1 - 53:
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

/CONDITION COND_I17 ( NORME_CF = "${NORME_CF}" or "${CONTEXT_CT}" != "STD" )
/OUTFILE ${SORT_O}
/INCLUDE COND_I17
exit
EOF
SORT

EST_PRSMAP_INPUT=${DFILT}/${NJOB}_02_${IB}_SORT_GTSII.dat

if [ ${CONTEXT_CT} = STD ] 
then
	#spira 88514

##NSTEP=${NJOB}_03
###-----------------------------------------------------------------------------
##LIBEL="Collecting recognized date Retro"
##BCP_WAY="OUT"
##BCP_VER="+"
##BCP_O="$DFILT/${NSTEP}_${IB}_FTRETIFRS_RECOD_O.dat"
##BCP_QRY="select RETCTR_NF,RTY_NF,CONVERT(VARCHAR(8),RETRECOD_D,112) as RETRECOD_D from BRET..TRETIFRS where CONVERT(VARCHAR(8),RETRECOD_D,112) <= '${PARM_PREV_ICLODAT_D}'"
##BCP

# [016] # [017]
##NSTEP=${NJOB}_04
###-----------------------------------------------------------------------------
##LIBEL="Collecting recognized date Assumed"
##BCP_WAY="OUT"
##BCP_VER="+"
##BCP_O="$DFILT/${NSTEP}_${IB}_FSECIFRS_RECOD_O.dat"
##BCP_QRY="select CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF,CONVERT(VARCHAR(8),RECOD_D,112) as RECOD_D from BTRT..TSECIFRS where RECOD_D > '${PARM_PREV_ICLODAT_D}' and CONVERT(VARCHAR(8),RECOD_D,112) <= '${PARM_ICLODAT_D}' union select CTR_NF, UWY_NF, UW_NT, END_NT, SEC_NF,CONVERT(VARCHAR(8),RECOD_D,112) as RECOD_D from BFAC..TSECIFRS where RECOD_D > '${PARM_PREV_ICLODAT_D}' and CONVERT(VARCHAR(8),RECOD_D,112) <= '${PARM_ICLODAT_D}'"
##BCP

## [017] R03-06

if [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17S" ]
then
    RQ="select RETCTR_NF,RTY_NF,CONVERT(VARCHAR(8),RETRECOD_D,112) as RETRECOD_D from BRET..TRETIFRS 	where ( CONVERT(VARCHAR(8),GRPFSTCLO_D,112) <= '${PARM_PREV_ICLODAT_D}' and GRPINISTS_CT=2  )	"
fi

if [ "${NORME_CF}" = "I17P" ]
then
    RQ="select RETCTR_NF,RTY_NF,CONVERT(VARCHAR(8),RETRECOD_D,112) as RETRECOD_D from BRET..TRETIFRS 	where  ( CONVERT(VARCHAR(8),PARFSTCLO_D,112) <= '${PARM_PREV_ICLODAT_D}' and PARINISTS_CT=2 ) " 
fi

if [ "${NORME_CF}" = "I17L" ]
then
    RQ="select RETCTR_NF,RTY_NF,CONVERT(VARCHAR(8),RETRECOD_D,112) as RETRECOD_D from BRET..TRETIFRS 	where  ( CONVERT(VARCHAR(8),LCLFSTCLO_D,112) <= '${PARM_PREV_ICLODAT_D}' and LOCINISTS_CT=2 ) "
fi


# # [017] Mise à jour R03-06 RETRO
NSTEP=${NJOB}_03
#-----------------------------------------------------------------------------
LIBEL="Collecting R03-06  date Retro"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="$DFILT/${NSTEP}_${IB}_FTRETIFRS_RECOD_O.dat"
BCP_QRY="${RQ}"
BCP



###  [017]
NSTEP=${NJOB}_04
###-----------------------------------------------------------------------------
LIBEL="Collecting R03-06 NEW"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_STD} 2000 1"
SORT_O="$DFILT/${NSTEP}_${IB}_IADPERICASE_STD_SANS_DUMMY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
	   CTR_NF 													3:1 - 3:,
	   END_NT							  						4:1 - 4:,
	   SEC_NF							  						5:1 - 5:,
	   UWY_NF							  						6:1 - 6:,
	   UW_NT 							  						7:1 - 7:,   
	   EXP_D                            28:1 - 28:,	   
	   SCOINC_D                         76:1 - 76:,
     CTRNAT_CT                        85:1 - 85:,
		 UWORG_CF 							  			  119:1 - 119:,      
	   SECIFRS_GRPFIRCLO_D							216:1 - 216:,
	   SECIFRS_PARFIRCLO_D							220:1 - 220:,
	   SECIFRS_LOCFIRCLO_D 							224:1 - 224:,	   
	   SECIFRS_GRPINISTS_CT 						228:1 - 228:,
	   SECIFRS_PARINISTS_CT 						229:1 - 229:,
	   SECIFRS_LOCINISTS_CT							230:1 - 230:,
	   CR_CRUWY_NF							        248:1 - 248: 	   
/CONDITION NEW_R03_08  (UWORG_CF != "248" ) AND (   ( (("$NORME_CF" = "I17G") or ("$NORME_CF" = "I17S"))  AND   (SECIFRS_GRPINISTS_CT = "1")   )
                                                  or ( ("$NORME_CF" = "I17P") AND     (SECIFRS_PARINISTS_CT = "1")   )
                                                  or ( ("$NORME_CF" = "I17L") AND     (SECIFRS_LOCINISTS_CT = "1")   )
                               									)                                                        
/OUTFILE ${SORT_O}
/INCLUDE NEW_R03_08
/REFORMAT 
	CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, UWORG_CF, SCOINC_D, EXP_D, SECIFRS_GRPFIRCLO_D, SECIFRS_PARFIRCLO_D, SECIFRS_LOCFIRCLO_D, SECIFRS_GRPINISTS_CT, SECIFRS_PARINISTS_CT, SECIFRS_LOCINISTS_CT, CR_CRUWY_NF, CTRNAT_CT
exit
EOF
SORT 



### FIN [017]                                   


NSTEP=${NJOB}_06
#------------------------------------------------------------------------------------
LIBEL="Split GTSII to DSC/FWD Retro and Other"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_PRSMAP_INPUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FWD_RET.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_OTHER_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:3,
        PATTYP_CT        53:1 - 53:3,
        RETCTR_NF        24:1 - 24:,
        TYP_CT1          49:1 - 49:1
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION PURE_RETRO_FWD (TYP_CT1 = "R" and (PATCAT_CT="DSC" or PATCAT_CT="BDT" or PATCAT_CT="RAD"  ) and PATTYP_CT="FWD" and RETCTR_NF != "")
/OUTFILE ${SORT_O}
/INCLUDE PURE_RETRO_FWD
/OUTFILE ${SORT_O2}
/OMIT PURE_RETRO_FWD
exit
EOF
SORT

#enrichi regcognise date retro
NSTEP=${NJOB}_07
#------------------------------------------------------------------------------------
LIBEL="enrichi regcognise date retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_06_${IB}_SORT_FWD_RET.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FWD_RET_O.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS GT_CTR_NF            8:1 -  8:,
        GT_END_NT            9:1 -  9:,
        GT_SEC_NF           10:1 - 10:,
        GT_UWY_NF           11:1 - 11:,
        GT_UW_NT            12:1 - 12:,
        GT_RETCTR_NF       24:1 - 24:,
        GT_RETSEC_NF       26:1 - 26:,
        GT_RTY_NF          27:1 - 27:,
        GT_ALL_COLS          1:1 - 124:,
        RETCTR_NF           1:1 -  1:,
        RTY_NF              2:1 -  2:,
        RETRECOD_D          3:1 -  3:
/joinkeys
        GT_RETCTR_NF ,
        GT_RTY_NF
/INFILE $DFILT/${NJOB}_03_${IB}_FTRETIFRS_RECOD_O.dat 2000 1 "~"
/joinkeys
        RETCTR_NF ,
        RTY_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}  overwrite
/REFORMAT
        leftside:GT_ALL_COLS, rightside:RETRECOD_D
exit
EOF
SORT

#enrichi regcognise date assumed

# [017]

NSTEP=${NJOB}_08
#------------------------------------------------------------------------------------
LIBEL="enrichi regcognise date assumed"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_07_${IB}_SORT_FWD_RET_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FWD_RET_O2.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS GT_CTR_NF            8:1 -  8:,
        GT_END_NT            9:1 -  9:,
        GT_SEC_NF           10:1 - 10:,
        GT_UWY_NF           11:1 - 11:,
        GT_UW_NT            12:1 - 12:,
        GT_RETCTR_NF       24:1 - 24:,
        GT_RETSEC_NF       26:1 - 26:,
        GT_RTY_NF          27:1 - 27:,
        GT_ALL_COLS_RETRECOD         1:1 - 125:,
        CTR_NF           1:1 -  1:,
        END_NT           2:1 -  2:,
        SEC_NF           3:1 -  3:,
        UWY_NF           4:1 -  4:,
        UW_NT            5:1 -  5:,
        RECOD_D          6:1 -  6:
/joinkeys
        GT_CTR_NF,
        GT_END_NT,
        GT_SEC_NF,
        GT_UWY_NF,
        GT_UW_NT
/INFILE $DFILT/${NJOB}_04_${IB}_IADPERICASE_STD_SANS_DUMMY.dat 2000 1 "~"
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}  overwrite
/REFORMAT
        leftside:GT_ALL_COLS_RETRECOD, rightside:RECOD_D
exit
EOF
SORT


NSTEP=${NJOB}_09a
#------------------------------------------------------------------------------------
LIBEL="reset DSC/FWD to zero retro using recognised date contraints"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_08_${IB}_SORT_FWD_RET_O2.dat 2000 1"
SORT_O="${ESF_GTSII_FWD_DEL} 2000 1"
SORT_O2="${ESF_GTSII_FWD_RET} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS GT_CTR_NF            8:1 -  8:,
        GT_END_NT            9:1 -  9:,
        GT_SEC_NF           10:1 - 10:,
        GT_UWY_NF           11:1 - 11:,
        GT_UW_NT            12:1 - 12:,
        GT_RETCTR_NF       24:1 - 24:,
        GT_RETSEC_NF       26:1 - 26:,
        GT_RTY_NF          27:1 - 27:,
        GT_ALL_COLS        1:1 - 124:,
        RETRECOD_D         125:1 - 125:,
        RECOD_D             126:1 -  126:
/CONDITION DATE_RECOD ( RETRECOD_D !="" and RECOD_D !="" )
/OUTFILE ${SORT_O} overwrite
/INCLUDE DATE_RECOD
/OUTFILE ${SORT_O2} overwrite
/OMIT DATE_RECOD
exit
EOF
SORT

NSTEP=${NJOB}_09
#------------------------------------------------------------------------------------
LIBEL="Merge FWD retro and assumed"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_GTSII_FWD_RET} 2000 1"
SORT_I2="${DFILT}/${NJOB}_06_${IB}_SORT_GTSII_OTHER_STD.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_FWD_OTHER_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/OUTFILE ${SORT_O}
exit
EOF
SORT

	EST_PRSMAP_INPUT="${DFILT}/${NJOB}_09_${IB}_SORT_GTSII_FWD_OTHER_STD.dat"
fi

#end #spira 88514

NSTEP=${NJOB}_20

LIBEL="Split GTSII with PATCAT=DSC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_PRSMAP_INPUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_OTHER.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_DSC.dat 2000 1"
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
        ACCRET_CF       49:1 - 49:,
        NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:,
        PATCAT3_CT       52:1 - 52:3,
        PATTYP3_CT        53:1 - 53:3
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

/CONDITION COND_DSC ( PATCAT3_CT="DSC" and ( PATTYP3_CT="DSI" or PATTYP3_CT="LKI" or PATTYP3_CT="FWD"))
/OUTFILE ${SORT_O}
/OMIT COND_DSC
/OUTFILE ${SORT_O2}
/INCLUDE COND_DSC


exit
EOF
SORT


if [ ${CONTEXT_CT} = STD ]
then


NSTEP=${NJOB}_30
#------------------------------------------------------------------------------------
LIBEL="sort FPRSMAP STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FPRSMAP_TXT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FPRSMAP_TXT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS PRS_CF            1:1 - 1:,
                ACMTRS_NT        4:1 - 4:,
                ACMTRS3_NT       5:1 - 5:,
                LKI              8:1 - 8:,
                DSI              9:1 - 9:,
        	      FWD              10:1 - 10:
/KEYS   ACMTRS_NT,
        ACMTRS3_NT,
        LKI,
        DSI,
        FWD
/SUMMARIZE
/CONDITION PRSMAP_COND (PRS_CF="751")
/OUTFILE ${SORT_O}
/INCLUDE PRSMAP_COND
exit
EOF
SORT

else

NSTEP=${NJOB}_30A
#------------------------------------------------------------------------------------
LIBEL="sort FPRSMAP INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FPRSMAP_TXT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FPRSMAP_TXT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 	PRS_CF            1:1 - 1:,
                ACMTRS_NT        4:1 - 4:,
                ACMTRS3_NT       5:1 - 5:,
                LKI              7:1 - 7:
/KEYS   ACMTRS_NT,
        ACMTRS3_NT,
        LKI
/SUMMARIZE
/CONDITION PRSMAP_COND (PRS_CF="751" and LKI !="")
/OUTFILE ${SORT_O}
/INCLUDE PRSMAP_COND
exit
EOF
SORT


NSTEP=${NJOB}_30
#------------------------------------------------------------------------------------
LIBEL="sort FPRSMAP INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30A_${IB}_SORT_FPRSMAP_TXT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FPRSMAP_TXT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS         ALL_6            1:1 - 6:,
		LKI              7:1 - 7:
/DERIVEDFIELD BLANK_2_CHAMPS 2"~"
/DERIVEDFIELD INI_CHAMPS "INI~"
/OUTFILE ${SORT_O}
/REFORMAT ALL_6, INI_CHAMPS,LKI,BLANK_2_CHAMPS
exit
EOF
SORT


fi

cat ${DFILT}/${NSTEP}_${IB}_SORT_FPRSMAP_TXT.dat

echo "-----------------------------------------------"
#cat ${DFILT}/${NSTEP}_${IB}_SORT_STD_FPRSMAP_TXT.dat




NSTEP=${NJOB}_40

LIBEL="Generation TL des fichiers"
PRG=ESFC3742
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT ${CLODAT_D}
NORME_CF ${NORME_CF}
exit
EOF

export ${PRG}_LOG=${DFILT}/${PRG}.log
export ${PRG}_ANO=${DFILT}/${PRG}.ano
#export ${PRG}_SRV=''
#export ${PRG}_USR=''
#export ${PRG}_PSWD=''

export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_GTSII_DSC.dat
export ${PRG}_I2=${ESF_FDETTRS}
export ${PRG}_I3=${DFILT}/${NJOB}_30_${IB}_SORT_FPRSMAP_TXT.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTASII.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTRSII.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_ANO.dat
EXECPRG
#gdb $DEXE/$PRG.exe

JOBEND

