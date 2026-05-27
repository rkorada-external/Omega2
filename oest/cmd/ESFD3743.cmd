#!/bin/ksh
#====================================================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 IFRS17 req 8.1 : GLT Transformation 
# Nom du script SHELL           : ESFD3743.cmd
# Revision                      : $Revision:   1.0  $
# Date de creation              : 10/08/2020
# Auteur                        : Linh DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Description
# spira 77079           Generating IFRS 17 Group TL file 
# spira 87876		REQ08.01- Discount accounting rules review
#
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#       [001]           10/08/2020      L.DOAN          SPIRA : 87876           REQ08.01- Discount accounting rules review
#	[002]           26/08/2020      L.DOAN          SPIRA : 88354		REQ11.7.2 Retro P- Assumed components LC cession
#	[003]           28/08/2020      MZM             SPIRA : 88986		IFRS 17 inception accounting- Exclude future profitable contrat   
#	[004]           08/10/2020      MZM             SPIRA : 85522		IFRS 17 Extract ONEROUS CONTRACTS AT INI and copy to STD Closing          
# [004]           	09/10/2020      L.DOAN          SPIRA : 90571 		Missing transcodes at inception	
#	[005]           12/10/2020      L.DOAN          SPIRA : 90514           reverse the sign for all INI transactions except 10014, 12014, 12018, 12122, 12128, 10100
# [006]           30/11/2020      L.DOAN          SPIRA : 91706		REQ 11.06- Errors for some contracts in "Change in Estimates" TL data generation
# [007]           19/02/2021      N.DOAN          SPIRA : 85522 		technical cashflow flux
# [008]           09/03/2021      N.DOAN          SPIRA : 91488           future profitable filtre
# [009]           09/09/2021      N.DOAN          SPIRA : 90514           reverse the sign of RETINTAMT_M
# [010]           03/03/2022      HR              SPIRA : 101545          REQ 21.05 - I17 Local Retro P - No initial net gain bookings
# [011]           16/06/2022      DaD             SPIRA : 99814           Exclude future Onerous contrat
# [012] 					04/07/2022 			JBD						 	SPIRA : 104778 	Build new closing for I17S norm 
# [013]           04/08/2022      DAD             SPIRA:  105382          exclude future profitable and onerous for STD and INI
# [014]           20/04/2023      MZM             SPIRA:  109492  R03-05 should not be applied on internal assumed contracts on Group norm
# [015]           14/05/2024      HR              SPIRA:  111106 Calculate unwind & LC accretion on Onerous Q+1 & retro dummy contracts
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd


#CLODAT_D=${PARM_ICLODAT_D}


#TODO date to be defined
#POS_BOOKING_X_DT="20190823"   

NORME="${NORME_CF}"

# Get input parameters


# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
LIBEL="MANAGE UNFOUND FILES " 


if [ ! -f "${ESF_DLDGTAASII_LC}" ]
then
    EXECKSH "touch ${ESF_DLDGTAASII_LC}"

fi

EST_IADPERICASE_MY=${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3742${TYPEINV}_${CONTEXT_CT}_00_${IB}_TCRCONTR_CRUWY.dat
EST_GTSII_ALL_INI=${DFILT}/${ENV_PREFIX}_ESFD3740_ESFD3742${TYPEINV}_${CONTEXT_CT}_01_${IB}_FULL_GTSII_NO_MUWY.dat 


NSTEP=${NJOB}_05
#------------------------------------------------------------------------------------
LIBEL="Split GTSII at INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTSII_ALL_INI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_CSM_CSU_INI.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_OTHER_INI.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        NORME_CF         50:1 - 50:,
        PATCAT_CT        52:1 - 52:3,
        PATTYP_CT        53:1 - 53:3,
	RETCTR_NF	 24:1 - 24:,
        FIELD01          1:1  - 49:,
        FIELD02          51:1 - 124:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION PURE_CSM_CSU (NORME_CF ="${NORME}" and PATCAT_CT="CSM" and PATTYP_CT="LKI" )
/OUTFILE ${SORT_O}
/INCLUDE PURE_CSM_CSU
/OUTFILE ${SORT_O2}
/OMIT PURE_CSM_CSU
exit
EOF
SORT

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="Split GTSII at INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTSII_CSM_CSU_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_CSM_CSU_INI.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_CSM_CSU_INI_RETRO.dat 2000 1"
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
/CONDITION PURE_RETRO (TYP_CT1 = "R")
/OUTFILE ${SORT_O}
/OMIT PURE_RETRO
/OUTFILE ${SORT_O2}
/INCLUDE PURE_RETRO
exit
EOF
SORT


NSTEP=${NJOB}_12
#------------------------------------------------------------------------------------
LIBEL="sort SECIFRS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FSECIFRS} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FSECIFRS.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            1:1 - 1:,
        END_NT            4:1 - 4:EN,
        SEC_NF            5:1 - 5:EN,
        UWY_NF            2:1 - 2:,
        UW_NT             3:1 - 3:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT

/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_14
#------------------------------------------------------------------------------------
LIBEL="Pericase INI + SECIFRS join"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADPERICASE_INI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_SECIFRS.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS PER_CTR_NF           3:1 - 3:,
        PER_END_NT           4:1 - 4:,
        PER_SEC_NF           5:1 - 5:,
        PER_UWY_NF           6:1 - 6:,
        PER_UW_NT            7:1 - 7:,
	PER_CTRINC_D	 19:1 - 19:,
	PER_CTRSTS_CT	 99:1 - 99:EN,
	PER_GRPINIPRO_CF 218:1 - 218:,
	PER_PARINIPRO_CF 222:1 - 222:,
	PER_LOCINIPRO_CF 226:1 - 226:,
	PER_ALL 	 1:1 - 206:,
	SECIFRS_ALL	 6:1 - 36:,
	CTR_NF       	 1:1 - 1:,
        END_NT		 4:1 - 4:,
        SEC_NF		 5:1 - 5:,	
        UWY_NF		 2:1 - 2:,	
        UW_NT 		 3:1 - 3:,	
	GRPFIRCLO_D  	 15:1 - 15:,
	PARFIRCLO_D  	 19:1 - 19:,
	LOCFIRCLO_D  	 23:1 - 23:,
	GRPINISTS_CT 	 27:1 - 27:EN,
	PARINISTS_CT 	 28:1 - 28:EN,
	LOCINISTS_CT 	 29:1 - 29:EN
/JOINKEYS   PER_CTR_NF,
        PER_END_NT,
        PER_SEC_NF,
        PER_UWY_NF,
        PER_UW_NT
/INFILE ${DFILT}/${NJOB}_12_${IB}_SORT_FSECIFRS.dat  2000 1 "~"
/JOINKEYS   CTR_NF,
	    END_NT,
            SEC_NF,
            UWY_NF,
            UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
	leftside : PER_ALL, rightside : SECIFRS_ALL, leftside : PER_GRPINIPRO_CF, leftside : PER_PARINIPRO_CF, leftside : PER_LOCINIPRO_CF
exit
EOF
SORT

# [013]
NSTEP=${NJOB}_14A
#-----------------------------------------------------------------------------
LIBEL="Pericase INI selection with contrat Multi Years"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_14_${IB}_SORT_IADPERICASE_SECIFRS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_SECIFRS_MY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PER_CTR_NF       3:1 - 3:,
        PER_END_NT       4:1 - 4:,
        PER_SEC_NF       5:1 - 5:,
        PER_UWY_NF       6:1 - 6:,
        PER_UW_NT        7:1 - 7:,
        MY_CTR_NF        1:1 - 1:,
        MY_END_NT        2:1 - 2:,
        MY_SEC_NF        3:1 - 3:,
        MY_UWY_NF        4:1 - 4:,
        MY_UW_NT         5:1 - 5:,
        PER_ALL_COLS     1:1 - 240:
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/INFILE ${EST_IADPERICASE_MY} 2000 1 "~"
/joinkeys
        MY_CTR_NF ,
        MY_END_NT ,
        MY_SEC_NF ,
        MY_UWY_NF ,
        MY_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :PER_ALL_COLS
exit
EOF
SORT

# [013]
NSTEP=${NJOB}_14B
#-----------------------------------------------------------------------------
LIBEL="Pericase INI selection with contrat not Multi Years"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_14_${IB}_SORT_IADPERICASE_SECIFRS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_SECIFRS_NOT_MY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PER_CTR_NF       3:1 - 3:,
        PER_END_NT       4:1 - 4:,
        PER_SEC_NF       5:1 - 5:,
        PER_UWY_NF       6:1 - 6:,
        PER_UW_NT        7:1 - 7:,
        MY_CTR_NF        1:1 - 1:,
        MY_END_NT        2:1 - 2:,
        MY_SEC_NF        3:1 - 3:,
        MY_UWY_NF        4:1 - 4:,
        MY_UW_NT         5:1 - 5:,
        PER_ALL_COLS     1:1 - 240:
/joinkeys
        PER_CTR_NF ,
        PER_END_NT ,
        PER_SEC_NF ,
        PER_UWY_NF ,
        PER_UW_NT
/INFILE ${EST_IADPERICASE_MY} 2000 1 "~"
/joinkeys
        MY_CTR_NF ,
        MY_END_NT ,
        MY_SEC_NF ,
        MY_UWY_NF ,
        MY_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY 
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :PER_ALL_COLS
exit
EOF
SORT


NSTEP=${NJOB}_15
#------------------------------------------------------------------------------------
LIBEL="Pericase  INI selection"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_14_${IB}_SORT_IADPERICASE_SECIFRS.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_INI.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           3:1 - 3:,
        END_NT           4:1 - 4:,
        SEC_NF           5:1 - 5:,
        UWY_NF           6:1 - 6:,
        UW_NT            7:1 - 7:,
        CTRINC_D     19:1 - 19:,
        CTRSTS_CT    99:1 - 99:EN,
        GRPFIRCLO_D      216:1 - 216:,
        PARFIRCLO_D      221:1 - 221:,
        LOCFIRCLO_D      226:1 - 226:,
        GRPINISTS_CT     234:1 - 234:EN,
        PARINISTS_CT     235:1 - 235:EN,
        LOCINISTS_CT     236:1 - 236:EN,
	GRPINIPRO_CF	 219:1 - 219:,
	PARINIPRO_CF	 224:1 - 224:,
	LOCINIPRO_CF	 229:1 - 229:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION COND_I17G (( "${NORME_CF}" = "I17G" ) or ( "${NORME_CF}" = "I17S" ))  and ( GRPFIRCLO_D = "" or  GRPINISTS_CT = 1 )
/CONDITION COND_I17L ( "${NORME_CF}" = "I17L" ) and ( LOCFIRCLO_D = "" or  LOCINISTS_CT = 1 )
/CONDITION COND_I17P ( "${NORME_CF}" = "I17P" ) and ( PARFIRCLO_D = "" or  PARINISTS_CT = 1 )
/CONDITION COND_CTR ( CTRSTS_CT = 14 or CTRSTS_CT = 16)
/CONDITION COND_CSM ((("${NORME_CF}" = "I17G") or ( "${NORME_CF}" = "I17S" ))  and ( GRPFIRCLO_D = "" or  GRPINISTS_CT = 1) and ( CTRINC_D <= "${PARM_ICLODAT_D}" and ((GRPINIPRO_CF = "2") or (GRPINIPRO_CF ="3"))) or (GRPINIPRO_CF = "1")) or ( "${NORME_CF}" = "I17L"  and ( LOCFIRCLO_D = "" or  LOCINISTS_CT = 1 ) and ( CTRINC_D <= "${PARM_ICLODAT_D}" and ((LOCINIPRO_CF = "2") or (LOCINIPRO_CF ="3"))) or (LOCINIPRO_CF = "1")) 
or ( "${NORME_CF}" = "I17P"  and ( PARFIRCLO_D = "" or  PARINISTS_CT = 1 ) and ( CTRINC_D <= "${PARM_ICLODAT_D}" and ((PARINIPRO_CF = "2") or (PARINIPRO_CF ="3"))) or (PARINIPRO_CF = "1")) and ( CTRSTS_CT=14 or CTRSTS_CT=16 or CTRSTS_CT=17 or CTRSTS_CT=19)
/OUTFILE ${SORT_O} 
/INCLUDE COND_CSM
exit
EOF
SORT

# [013]
#Pericase future profitabless
NSTEP=${NJOB}_16A
#------------------------------------------------------------------------------------
LIBEL="Pericase  INI selection future profitable with contrat not MultiYears"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_14B_${IB}_SORT_IADPERICASE_SECIFRS_NOT_MY.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_PROFUT_NOT_MY.dat 2000 1"
# SORT_O="${ESF_IADPERICASE_PROFUT} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           3:1 - 3:,
        END_NT           4:1 - 4:,
        SEC_NF           5:1 - 5:,
        UWY_NF           6:1 - 6:,
        UW_NT            7:1 - 7:,
        CTRINC_D         19:1 - 19:,
        CTRSTS_CT        99:1 - 99:EN,
        GRPFIRCLO_D      216:1 - 216:,
        PARFIRCLO_D      221:1 - 221:,
        LOCFIRCLO_D      226:1 - 226:,
        GRPINISTS_CT     234:1 - 234:EN,
        PARINISTS_CT     235:1 - 235:EN,
        LOCINISTS_CT     236:1 - 236:EN,
        GRPINIPRO_CF     219:1 - 219:,
        PARINIPRO_CF     224:1 - 224:,
        LOCINIPRO_CF     229:1 - 229:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION COND_FUT_PROFIT ( CTRINC_D > "${PARM_ICLODAT_D}") and ( ((( "${NORME_CF}" = "I17G") or ( "${NORME_CF}" = "I17S" ))  and ( GRPFIRCLO_D = "" or  GRPINISTS_CT = 1 ) and (GRPINIPRO_CF  != "1") ) or ( "${NORME_CF}" = "I17L"  and ( LOCFIRCLO_D = "" or  LOCINISTS_CT = 1 ) and (LOCINIPRO_CF  != "1" )) or ( "${NORME_CF}" = "I17P"  and ( PARFIRCLO_D = "" or  PARINISTS_CT = 1 ) and (PARINIPRO_CF != "1" ) ))
/OUTFILE ${SORT_O}
/INCLUDE COND_FUT_PROFIT
exit
EOF
SORT


# [013]
NSTEP=${NJOB}_16B
#------------------------------------------------------------------------------------
LIBEL="Pericase  INI selection future profitable with contrat Multi Years"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_14A_${IB}_SORT_IADPERICASE_SECIFRS_MY.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_PROFUT_MY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           3:1 - 3:,
        END_NT           4:1 - 4:,
        SEC_NF           5:1 - 5:,
        UWY_NF           6:1 - 6:,
        UW_NT            7:1 - 7:,
        CTRINC_D         19:1 - 19:,
        CTRSTS_CT        99:1 - 99:EN,
        GRPFIRCLO_D      216:1 - 216:,
        PARFIRCLO_D      221:1 - 221:,
        LOCFIRCLO_D      226:1 - 226:,
        GRPINISTS_CT     234:1 - 234:EN,
        PARINISTS_CT     235:1 - 235:EN,
        LOCINISTS_CT     236:1 - 236:EN,
        GRPINIPRO_CF     238:1 - 238:,
        PARINIPRO_CF     239:1 - 239:,
        LOCINIPRO_CF     240:1 - 240:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION COND_FUT_PROFIT ( CTRINC_D > "${PARM_ICLODAT_D}") and ( ((( "${NORME_CF}" = "I17G") or ( "${NORME_CF}" = "I17S" ))  and ( GRPFIRCLO_D = "" or  GRPINISTS_CT = 1 ) and (GRPINIPRO_CF  != "1") ) or ( "${NORME_CF}" = "I17L"  and ( LOCFIRCLO_D = "" or  LOCINISTS_CT = 1 ) and (LOCINIPRO_CF  != "1" )) or ( "${NORME_CF}" = "I17P"  and ( PARFIRCLO_D = "" or  PARINISTS_CT = 1 ) and (PARINIPRO_CF != "1" ) ))
/OUTFILE ${SORT_O}
/INCLUDE COND_FUT_PROFIT
exit
EOF
SORT

# [013]
# [014] COND_FUT_PROFIT_R03_05

 
NSTEP=${NJOB}_16
#------------------------------------------------------------------------------------
LIBEL="Pericase  INI selection future profitable"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_16A_${IB}_SORT_IADPERICASE_PROFUT_NOT_MY.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_16B_${IB}_SORT_IADPERICASE_PROFUT_MY.dat 2000 1"
SORT_O="${ESF_IADPERICASE_PROFUT} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           3:1 - 3:,
        END_NT           4:1 - 4:,
        SEC_NF           5:1 - 5:,
        UWY_NF           6:1 - 6:,
        UW_NT            7:1 - 7:,
        CTRRET_B         20:1 - 20:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION COND_FUT_PROFIT_R03_05 ( (CTRRET_B = "0" ) and ( ( "${NORME_CF}" = "I17G") or ( "${NORME_CF}" = "I17S" ) ) ) or ( ( "${NORME_CF}" = "I17P") or ( "${NORME_CF}" = "I17L" ) )
/OUTFILE ${SORT_O}
/INCLUDE COND_FUT_PROFIT_R03_05
exit
EOF
SORT



# [013]
# [011] Pericase Future Onerous
# [015]
NSTEP=${NJOB}_17A
#------------------------------------------------------------------------------------
LIBEL="Pericase INI with contrat not MultiYears"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_14B_${IB}_SORT_IADPERICASE_SECIFRS_NOT_MY.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_ALL_NOT_MY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           3:1 - 3:,
        END_NT           4:1 - 4:,
        SEC_NF           5:1 - 5:,
        UWY_NF           6:1 - 6:,
        UW_NT            7:1 - 7:,
        CTRINC_D         19:1 - 19:,
        CTRSTS_CT        99:1 - 99:EN,
        GRPFIRCLO_D      216:1 - 216:,
        PARFIRCLO_D      221:1 - 221:,
        LOCFIRCLO_D      226:1 - 226:,
        GRPINISTS_CT     234:1 - 234:EN,
        PARINISTS_CT     235:1 - 235:EN,
        LOCINISTS_CT     236:1 - 236:EN,
        GRPINIPRO_CF     219:1 - 219:,
        PARINIPRO_CF     224:1 - 224:,
        LOCINIPRO_CF     229:1 - 229:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

# [013] [015]
NSTEP=${NJOB}_17B
#------------------------------------------------------------------------------------
LIBEL="Pericase INI with contrat MultiYears"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_14A_${IB}_SORT_IADPERICASE_SECIFRS_MY.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_ALL_MY.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           3:1 - 3:,
        END_NT           4:1 - 4:,
        SEC_NF           5:1 - 5:,
        UWY_NF           6:1 - 6:,
        UW_NT            7:1 - 7:,
        CTRINC_D         19:1 - 19:,
        CTRSTS_CT        99:1 - 99:EN,
        GRPFIRCLO_D      216:1 - 216:,
        PARFIRCLO_D      221:1 - 221:,
        LOCFIRCLO_D      226:1 - 226:,
        GRPINISTS_CT     234:1 - 234:EN,
        PARINISTS_CT     235:1 - 235:EN,
        LOCINISTS_CT     236:1 - 236:EN,
        GRPINIPRO_CF     238:1 - 238:,
        PARINIPRO_CF     239:1 - 239:,
        LOCINIPRO_CF     240:1 - 240:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

# [013] [015]
NSTEP=${NJOB}_17
#------------------------------------------------------------------------------------
LIBEL="Pericase INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_17A_${IB}_SORT_IADPERICASE_ALL_NOT_MY.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_17B_${IB}_SORT_IADPERICASE_ALL_MY.dat 2000 1"
SORT_O="${ESF_IADPERICASE_ONEFUT} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           3:1 - 3:,
        END_NT           4:1 - 4:,
        SEC_NF           5:1 - 5:,
        UWY_NF           6:1 - 6:,
        UW_NT            7:1 - 7:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="CSM/LC transaction INI selection"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_IADPERICASE_INI.dat 2000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_IFRS17_CSM_ESCOMPTE.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS GT_CTR_NF            8:1 -  8:,
        GT_END_NT            9:1 -  9:,
        GT_SEC_NF           10:1 - 10:,
        GT_UWY_NF           11:1 - 11:,
        GT_UW_NT            12:1 - 12:,
	GT_ALL_COLS	     1:1 - 124:,
        CTR_NF              3:1 - 3:,
        END_NT              4:1 - 4:,
        SEC_NF              5:1 - 5:,
        UWY_NF              6:1 - 6:,
        UW_NT               7:1 - 7:,
	GRPINIPRO_CF     219:1 - 219:,
        PARINIPRO_CF     224:1 - 224:,
        LOCINIPRO_CF     229:1 - 229:

/joinkeys 
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT
/INFILE ${DFILT}/${NJOB}_10_${IB}_SORT_GTSII_CSM_CSU_INI.dat 2000 1 "~"
/joinkeys 
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT

/OUTFILE ${SORT_O}  overwrite
/REFORMAT 
	 rightside :GT_ALL_COLS, leftside:GRPINIPRO_CF,leftside:PARINIPRO_CF,leftside:LOCINIPRO_CF 
exit
EOF
SORT


NSTEP=${NJOB}_30

LIBEL="Sort GTSII INI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_GTSII_OTHER_INI.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_20_${IB}_SORT_GTSII_IFRS17_CSM_ESCOMPTE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_ALL_INI.dat 2000 1"
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
        SEGNAT_CT	48:1 - 48:,
	ACCRET_CF 	49:1 - 49:
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



NSTEP=${NJOB}_46

LIBEL="Merge des fichiers GTSII INI CSU+ AUTRES"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_GTSII_ALL_INI.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_10_${IB}_SORT_GTSII_CSM_CSU_INI_RETRO.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTSII_INI.dat 2000 1"
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
        ACCRET_CF       49:1 - 49:
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



NSTEP=${NJOB}_50

LIBEL="Generation TL des fichiers INI"
PRG=ESFC3741
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT ${PARM_ICLODAT_D} 
NORME_CF ${NORME_CF}
exit
EOF

export ${PRG}_LOG=${DFILT}/${PRG}.log
export ${PRG}_ANO=${DFILT}/${PRG}.ano
#export ${PRG}_SRV=''
#export ${PRG}_USR=''
#export ${PRG}_PSWD=''

export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_46_${IB}_SORT_GTSII_INI.dat
export ${PRG}_I2=${ESF_FDETTRS}
export ${PRG}_O1=${DFILT}/${NJOB}_50_${IB}_${PRG}_GTASII_INI.dat
export ${PRG}_O2=${DFILT}/${NJOB}_50_${IB}_${PRG}_GTRSII_INI.dat
export ${PRG}_O3=${DFILT}/${NJOB}_50_${IB}_${PRG}_ANO_INI.dat
EXECPRG
#gdb $DEXE/$PRG.exe


#[010]
if [ ${NORME_CF} = "I17P" ]; then

NSTEP=${NJOB}_55

LIBEL="Creation of CSM LC to  ESFD2550"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESFC3741_GTASII_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAASII_LC.dat 2000 1"
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
        TRNCOD_CT        6:1 -  6:
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
        PLC_NT,
        CUR_CF
/CONDITION CSM_LC (TRNCOD_CT="1149500K" )
/OUTFILE ${SORT_O}
/INCLUDE CSM_LC
exit
EOF
SORT
fi

#[010]
if [ ${NORME_CF} = "I17L" ]; then

NSTEP=${NJOB}_55

LIBEL="Creation of CSM LC to  ESFD2550"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESFC3741_GTASII_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAASII_LC.dat 2000 1"
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
        TRNCOD_CT        6:1 -  6:
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
        PLC_NT,
        CUR_CF
/CONDITION CSM_LC (TRNCOD_CT="1149500M" )
/OUTFILE ${SORT_O}
/INCLUDE CSM_LC
exit
EOF
SORT
fi

#[010]
if [ ${NORME_CF} = "I17G" ] ||   [ ${NORME_CF} = "I17S" ]; then

NSTEP=${NJOB}_55

LIBEL="Creation of CSM LC to  ESFD2550"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESFC3741_GTASII_INI.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAASII_LC.dat 2000 1"
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
        TRNCOD_CT        6:1 -  6:
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
        PLC_NT,
        CUR_CF
/CONDITION CSM_LC (TRNCOD_CT="1149500I" )
/OUTFILE ${SORT_O}
/INCLUDE CSM_LC
exit
EOF
SORT
fi


NSTEP=${NJOB}_60

#-----------------------------------------------------------------------------
LIBEL="Reverse of CSM LC to  ESFD2550"
AWK_I="${DFILT}/${NJOB}_55_${IB}_SORT_DLDGTAASII_LC.dat"
AWK_O="${ESF_DLDGTAASII_LC}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
        \$19 = sprintf("%-.3lf",-\$19 );
        \$35 = sprintf("%-.3lf",-\$35 );
	\$41 = sprintf("%-.3lf",-\$41 );

        print \$0;
  }
exit
EOF
AWK

JOBEND


