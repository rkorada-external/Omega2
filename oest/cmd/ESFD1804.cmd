#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Comptabilisation des ecritures de services IFRS17 Life
#                                 ESFD1804 calculate the FWH accrual
#				  
# nom du script SHELL		: ESFD1804.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 15/01/2025
# auteur			: S.Behague
# references des specifications	: BPR-EST-920810
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#-----------------------------------------------------------------------------
# Input files
#       EST_FACCSUP       DFILI
#       EST_FCES                  DFILP
#       EST_FCURCVSNI     DFILI
#       EST_FCURQUOT              DFILP
#       EST_FDETTRS       DFILI
#       EST_FPLC                  DFILP
#       EST_FRETTRF       DFILI
#
# Output files
#       EST_DLSGTAA       DFILI
#       EST_DLSGTAR       DFILI
#       EST_DLSGTR        DFILI
#
# Job launched by ESFD1800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# [001] 15/01/2025 S.Behague : SPIRA 111434 - [OMEGA Life] FWH - Accrual adjustment
# [002] 20/05/2025 sbehague: SPIRA 113027 - FWH accrual complement issue
# [003] 30/10/2025 sbehague: US7172 - L&H- FWH accruals complement- Accounting extraction issue
# [004] 19/01/2025 sbehague: US7172 - L&H- FWH accruals complement- Accounting extraction issue
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Job Initialisation
JOBINIT


#Get input parameters
CLODAT_D=$1
BALSHEY_NF=$2
NORME=`echo $3 | cut -d"_" -f1`


if [ ! -f ${EST_FCUR} ]
then
	touch ${EST_FCUR}
fi
if [ ! -f ${EST_FTACCTRNFWH} ]
then
	touch ${EST_FTACCTRNFWH}
fi


NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="OMIT old currency"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCUR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCUR_O1.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CUREXP_D         3:1 -  3:
/CONDITION COND_EXP (CUREXP_D = "" )
/OUTFILE ${SORT_O}
/INCLUDE COND_EXP
exit
EOF
SORT


NSTEP=${NJOB}_06
#-----------------------------------------------------------------------------
LIBEL="Separate Assumed and Retro from EST_FTACCTRNFWH"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTACCTRNFWH} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EST_SRGTC_RETRO_O1.dat"
SORT_O2="${DFILT}/${NSTEP}_${IB}_EST_SRGTC_ASSUMED_O2.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ACCRET         60:1 -  60:
/CONDITION COND_RETRO (ACCRET = "R" )
/OUTFILE ${SORT_O}
/INCLUDE COND_RETRO
/OUTFILE ${SORT_O2}
/OMIT COND_RETRO
exit
EOF
SORT


NSTEP=${NJOB}_06A
#-----------------------------------------------------------------------------
LIBEL="OMIT old currency from retro "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_06_${IB}_EST_SRGTC_RETRO_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_OMIT_CUR_O1.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CUR_CF          18:1 -  18:,
        CUR_CF              1:1 -   1:,
        ALLCOLS             1:1 -  75:
/joinkeys
        GT_CUR_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_SORT_FCUR_O1.dat 2000 1 "~"
/joinkeys
        CUR_CF
/OUTFILE ${SORT_O}
/REFORMAT leftside: ALLCOLS
exit
EOF
SORT


NSTEP=${NJOB}_07
#-----------------------------------------------------------------------------
LIBEL="Keeping FWH TRNCOD from SRGTC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_06A_${IB}_SORT_SRGTC_OMIT_CUR_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_RETRO_O1.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        TRNCOD2_CF       6:3 -  6:4,
        TRNCOD5_CF       6:3 -  6:7,
        GT_ACY_NF       14:1 - 14:EN,
        BALSHYEA_NF      3:1 -  3:EN
/CONDITION COND_FWH (TRNCOD2_CF = "81" AND TRNCOD5_CF != "81430" AND TRNCOD5_CF != "81530" ) AND ( GT_ACY_NF <= ${BALSHEY_NF} )
/OUTFILE ${SORT_O}
/INCLUDE COND_FWH
exit
EOF
SORT


NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Keeping FWH TRNCOD from EST_FTACCTRNFWH"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_06_${IB}_EST_SRGTC_ASSUMED_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_ASSUMED_O1.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        TRNCOD2_CF       6:3 -  6:4,
        TRNCOD5_CF       6:3 -  6:7,
        GT_ACY_NF       14:1 - 14:EN,
        BALSHYEA_NF      3:1 -  3:EN,
        MATCH_B         74:1 - 74:,
        MATCH_D         75:1 - 75:EN
/CONDITION COND_FWH (TRNCOD2_CF = "81" AND TRNCOD5_CF != "81430" AND TRNCOD5_CF != "81530" ) AND ( MATCH_B = '0' OR MATCH_B = '1' AND MATCH_D >= ${CLODAT_D} )
/OUTFILE ${SORT_O}
/INCLUDE COND_FWH
exit
EOF
SORT


NSTEP=${NJOB}_15
#------------------------------------------------------------------------------------
LIBEL="Merge Assumed and Retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_SRGTC_ASSUMED_O1.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_07_${IB}_SORT_SRGTC_RETRO_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_O1.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        FWHCTR_NF           8:1 -   8:,
        FWHSEC_NF          10:1 -  10:,
        FWHUWY_NF          11:1 -  11:
/KEYS   FWHCTR_NF, FWHSEC_NF, FWHUWY_NF
exit
EOF
SORT


NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Mapping LVL1 FWH TRNCOD from SRGTC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_SRGTC_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_MAPPED_LVL1.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        TRNCOD3_CF       6:3 -  6:5,
        FILLED_1_75      1:1 - 75:
/CONDITION COND_FWH_81000 (TRNCOD3_CF = "810" OR TRNCOD3_CF = "811" OR TRNCOD3_CF = "812" OR TRNCOD3_CF = "813")
/DERIVEDFIELD FWH_81000 if COND_FWH_81000 then "81000" else "81400"
/DERIVEDFIELD SEPARATEUR "~"
/OUTFILE ${SORT_O}
/REFORMAT FILLED_1_75, SEPARATEUR, FWH_81000
exit
EOF
SORT


NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="Mapping LVL2 FWH TRNCOD from SRGTC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_SRGTC_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_LVL2_LICLRC.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF           8:1 -  8:,
        GT_SEC_NF          10:1 -  10:,
        GT_UWY_NF          11:1 -  11:,
        MODCTR_NF           1:1 -   1:,
        MODSEC_NF           2:1 -   2:,
        MODUWY_NF           3:1 -   3:,
        MODTYPE             4:1 -   4:,
        ALLCOLS             1:1 -  75:
/joinkeys
        GT_CTR_NF,
        GT_SEC_NF,
        GT_UWY_NF
/INFILE ${EST_MODELINGTYPE} 2000 1 "~"
/joinkeys
        MODCTR_NF,
        MODSEC_NF,
        MODUWY_NF
/OUTFILE ${SORT_O}
/REFORMAT leftside: ALLCOLS, rightside: MODTYPE
exit
EOF
SORT


NSTEP=${NJOB}_25A
#-----------------------------------------------------------------------------
LIBEL="Add TRNCOD depending of TRNCOD IN SRGTC LVL2"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_SORT_SRGTC_LVL2_LICLRC.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_MAPPED_LVL2.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        TRNCOD3_CF       6:3 -  6:5,
        MODTYPE         76:1 - 76:,
        FILLED_1_76      1:1 - 76:
/CONDITION COND_FWH_81400 (TRNCOD3_CF = "814" OR TRNCOD3_CF = "815") AND (MODTYPE = "LIC")
/DERIVEDFIELD FWH_81400 if COND_FWH_81400 then "81400" else "81000"
/DERIVEDFIELD SEPARATEUR "~"
/OUTFILE ${SORT_O}
/REFORMAT FILLED_1_76, FWH_81400
exit
EOF
SORT


NSTEP=${NJOB}_28
#-----------------------------------------------------------------------------
LIBEL="Sort by UWY to keep the more recent UWY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_SRGTC_MAPPED_LVL1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_MAPPED_LVL1_SORT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        CUR_CF          18:1 -  18:
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF DESCENDING,
        CUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_28A
#-----------------------------------------------------------------------------
LIBEL="Sort by UWY to keep the more recent UWY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25A_${IB}_SORT_SRGTC_MAPPED_LVL2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_MAPPED_LVL2_SORT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        CUR_CF          18:1 -  18:
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF DESCENDING,
        CUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_30 
#-----------------------------------------------------------------------------
LIBEL="Aggregate FWH TRNCOD from SRGTC LVL1"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_28_${IB}_SORT_SRGTC_MAPPED_LVL1_SORT.dat 1000 1"
SORT_O="${EST_SRGTC_LVL1}"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_AGGREGATED_LVL1.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        SEC_NF          10:1 -  10:,
        CUR_CF          18:1 -  18:,
        TRNCOD5_CF      77:1 -  77:,
        AMT_M           19:1 -  19:EN 15/3,
        ESTAMT_M        43:1 -  43:EN 15/3
/KEYS   CTR_NF,
        SEC_NF,
        CUR_CF,
        TRNCOD5_CF
/SUMMARIZE TOTAL AMT_M, TOTAL ESTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Aggregate FWH TRNCOD from SRGTC LVL2"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_28A_${IB}_SORT_SRGTC_MAPPED_LVL2_SORT.dat 1000 1"
SORT_O="${EST_SRGTC_LVL2}"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTC_AGGREGATED_LVL2.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        SEC_NF          10:1 -  10:,
        CUR_CF          18:1 -  18:,
        TRNCOD5_CF      77:1 -  77:,
        AMT_M           19:1 -  19:EN 15/3,
        ESTAMT_M        43:1 -  43:EN 15/3
/KEYS   CTR_NF,
        SEC_NF,
        CUR_CF,
        TRNCOD5_CF
/SUMMARIZE TOTAL AMT_M, TOTAL ESTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="Keeping FWH TRNCOD from FUNDWITHHELD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FUNDWITHHELD_I17_PC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FUNDWITHHELD.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        TRNCOD2_CF       6:3 -  6:4,
        TRNCOD5_CF       6:3 -  6:7,
        BALSHYEA_NF      3:1 -  3:EN
/CONDITION COND_FWH (TRNCOD2_CF = "81" AND TRNCOD5_CF != "81430" AND TRNCOD5_CF != "81530" ) 
/OUTFILE ${SORT_O}
/INCLUDE COND_FWH
exit
EOF
SORT


NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="Mapping LVL2 FWH TRNCOD from FUNDWITHHELD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_FUNDWITHHELD.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FUNDWITHHELD_LVL2_LICLRC.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF           8:1 -  8:,
        GT_SEC_NF          10:1 -  10:,
        GT_UWY_NF          11:1 -  11:,
        MODCTR_NF           1:1 -   1:,
        MODSEC_NF           2:1 -   2:,
        MODUWY_NF           3:1 -   3:,
        MODTYPE             4:1 -   4:,
        ALLCOLS             1:1 -  75:
/joinkeys
        GT_CTR_NF,
        GT_SEC_NF,
        GT_UWY_NF
/INFILE ${EST_MODELINGTYPE} 2000 1 "~"
/joinkeys
        MODCTR_NF,
        MODSEC_NF,
        MODUWY_NF
/OUTFILE ${SORT_O}
/REFORMAT leftside: ALLCOLS, rightside: MODTYPE
exit
EOF
SORT


NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="Mapping LVL1 FWH TRNCOD from FUNDWITHHELD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_SORT_FUNDWITHHELD_LVL2_LICLRC.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FUNDWITHHELD_MAPPED_LVL1.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        TRNCOD3_CF       6:3 -  6:5,
        MODTYPE         76:1 - 76:,
        FILLED_1_75      1:1 - 75:
/CONDITION COND_FWH_81000 (TRNCOD3_CF = "810" OR TRNCOD3_CF = "811" OR TRNCOD3_CF = "812" OR TRNCOD3_CF = "813")
/DERIVEDFIELD FWH_81000 if COND_FWH_81000 then "81000" else "81400"
/DERIVEDFIELD SEPARATEUR "~"
/OUTFILE ${SORT_O}
/REFORMAT FILLED_1_75, SEPARATEUR, FWH_81000, SEPARATEUR, MODTYPE
exit
EOF
SORT


NSTEP=${NJOB}_55A
#-----------------------------------------------------------------------------
LIBEL="Add TRNCOD depending of TRNCOD IN FUNDWITHHELD LVL2"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_SORT_FUNDWITHHELD_LVL2_LICLRC.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FUNDWITHHELD_MAPPED_LVL2.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        TRNCOD3_CF       6:3 -  6:5,
        MODTYPE         76:1 - 76:,
        FILLED_1_76      1:1 - 76:
/CONDITION COND_FWH_81400 (TRNCOD3_CF = "814" OR TRNCOD3_CF = "815") AND (MODTYPE = "LIC")
/DERIVEDFIELD FWH_81400 if COND_FWH_81400 then "81400" else "81000"
/DERIVEDFIELD SEPARATEUR "~"
/OUTFILE ${SORT_O}
/REFORMAT FILLED_1_76, FWH_81400
exit
EOF
SORT


NSTEP=${NJOB}_58
#-----------------------------------------------------------------------------
LIBEL="Sort by UWY to keep the more recent UWY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_FUNDWITHHELD_MAPPED_LVL1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FUNDWITHHELD_MAPPED_LVL1_SORT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        CUR_CF          18:1 -  18:
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF DESCENDING,
        CUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_58A
#-----------------------------------------------------------------------------
LIBEL="Sort by UWY to keep the more recent UWY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55A_${IB}_SORT_FUNDWITHHELD_MAPPED_LVL2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FUNDWITHHELD_MAPPED_LVL2_SORT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        SEC_NF          10:1 -  10:,
        UWY_NF          11:1 -  11:,
        CUR_CF          18:1 -  18:
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF DESCENDING,
        CUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_60 
#-----------------------------------------------------------------------------
LIBEL="Aggregate FWH TRNCOD from FUNDWITHHELD LVL1"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_58_${IB}_SORT_FUNDWITHHELD_MAPPED_LVL1_SORT.dat 1000 1"
SORT_O="${EST_FUNDWITHHELD_LVL1}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        SEC_NF          10:1 -  10:,
        CUR_CF          18:1 -  18:,
        TRNCOD5_CF      77:1 -  77:,
        AMT_M           19:1 -  19:EN 15/3,
        ESTAMT_M        43:1 -  43:EN 15/3
/KEYS   CTR_NF,
        SEC_NF,
        CUR_CF,
        TRNCOD5_CF
/SUMMARIZE TOTAL AMT_M, TOTAL ESTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_65
#-----------------------------------------------------------------------------
LIBEL="Aggregate FWH TRNCOD from FUNDWITHHELD LVL2"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_58A_${IB}_SORT_FUNDWITHHELD_MAPPED_LVL2_SORT.dat 1000 1"
SORT_O="${EST_FUNDWITHHELD_LVL2}"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FUNDWITHHELD_AGGREGATED_LVL2.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:,
        SEC_NF          10:1 -  10:,
        CUR_CF          18:1 -  18:,
        TRNCOD5_CF      77:1 -  77:,
        AMT_M           19:1 -  19:EN 15/3,
        ESTAMT_M        43:1 -  43:EN 15/3
/KEYS   CTR_NF,
        SEC_NF,
        CUR_CF,
        TRNCOD5_CF
/SUMMARIZE TOTAL AMT_M, TOTAL ESTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="Check if CTR from Projection file is LIC or LRC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SAS_PROJECTION} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROJECTION_LICLRC.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PROJCTR_NF         12:1 -  12:,
        PROJSEC_NF         13:1 -  13:,
        PROJUWY_NF         14:1 -  14:,
        MODCTR_NF           1:1 -   1:,
        MODSEC_NF           2:1 -   2:,
        MODUWY_NF           3:1 -   3:,
        MODTYPE             4:1 -   4:,
        ALLCOLS             1:1 -  24:
/joinkeys
        PROJCTR_NF,
        PROJSEC_NF,
        PROJUWY_NF
/INFILE ${EST_MODELINGTYPE} 2000 1 "~"
/joinkeys
        MODCTR_NF,
        MODSEC_NF,
        MODUWY_NF
/OUTFILE ${SORT_O}
/REFORMAT leftside: ALLCOLS, rightside: MODTYPE
exit
EOF
SORT


NSTEP=${NJOB}_71
#-----------------------------------------------------------------------------
LIBEL="Check if CTR from Projection file is LIC or LRC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SAS_PROJECTION} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROJECTION_LICLRC.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PROJCTR_NF         12:1 -  12:,
        PROJSEC_NF         13:1 -  13:,
        PROJUWY_NF         14:1 -  14:,
        MODCTR_NF           1:1 -   1:,
        MODSEC_NF           2:1 -   2:,
        MODUWY_NF           3:1 -   3:,
        MODTYPE             4:1 -   4:,
        ALLCOLS             1:1 -  24:
/joinkeys
        PROJCTR_NF,
        PROJSEC_NF,
        PROJUWY_NF
/INFILE ${EST_MODELINGTYPE} 2000 1 "~"
/joinkeys
        MODCTR_NF,
        MODSEC_NF,
        MODUWY_NF
/JOIN UNPAIRED ONLY LEFTSIDE
/OUTFILE ${SORT_O}
/DERIVEDFIELD MOD "LIC"
/REFORMAT
        leftside: ALLCOLS, MOD
exit
EOF
SORT


NSTEP=${NJOB}_72
#-----------------------------------------------------------------------------
LIBEL="Check if CTR from Projection file is LIC or LRC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_PROJECTION_LICLRC.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_71_${IB}_PROJECTION_LICLRC.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROJECTION_LICLRC.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF           8:1 -  8:,
        GT_SEC_NF          10:1 -  10:,
        GT_UWY_NF          11:1 -  11:
/KEYS
GT_CTR_NF,
GT_SEC_NF,
GT_UWY_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Add TRNCOD depending of POSITION CODE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_72_${IB}_PROJECTION_LICLRC.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROJECTION_LICLRC_TRNCOD.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PROJCTR_NF         12:1 -  12:,
        PROJSEC_NF         13:1 -  13:,
        PROJCUR_CF         19:1 - 19:,
        PROJPOSITION_CODE  18:1 - 18:,
        MODTYPE            25:1 - 25:,
        FILLED_1_25         1:1 - 25:
/CONDITION COND_FWH_81400 (PROJPOSITION_CODE = "CHANGE_IBNP_DEP") AND (MODTYPE = "LIC")
/DERIVEDFIELD FWH_81400 if COND_FWH_81400 then "81400" else "81000"
/DERIVEDFIELD SEPARATEUR "~"
/OUTFILE ${SORT_O}
/REFORMAT FILLED_1_25, FWH_81400
exit
EOF
SORT


NSTEP=${NJOB}_88
#-----------------------------------------------------------------------------
LIBEL="Sort by UWY to keep the more recent UWY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_PROJECTION_LICLRC_TRNCOD.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROJECTION_LICLRC_TRNCOD_SORT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PROJCTR_NF         12:1 -  12:,
        PROJSEC_NF         13:1 -  13:,
        PROJUWY_NF         14:1 -  14:,
        PROJCUR_CF         19:1 -  19:
/KEYS   PROJCTR_NF,
        PROJSEC_NF,
        PROJUWY_NF DESCENDING,
        PROJCUR_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="Aggregate Projection level 2"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_88_${IB}_PROJECTION_LICLRC_TRNCOD_SORT.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROJECTION_LICLRC_TRNCOD_AGGREGATED.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PROJCTR_NF         12:1 -  12:,
        PROJSEC_NF         13:1 -  13:,
        PROJCUR_CF         19:1 -  19:,
        PROJAMT_M          20:1 -  20:EN 15/3,
        PROJTRNCOD5        26:1 -  26:
/KEYS   PROJCTR_NF,
        PROJSEC_NF,
        PROJCUR_CF,
        PROJTRNCOD5
/SUMMARIZE TOTAL PROJAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_95
#-----------------------------------------------------------------------------
LIBEL="Aggregate Projection level 2"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_PROJECTION_LICLRC_TRNCOD_AGGREGATED.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_PROJECTION_LICLRC_TRNCOD_AGGREGATED.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PROJCTR_NF         12:1 -  12:,
        PROJSEC_NF         13:1 -  13:,
        PROJCUR_CF         19:1 -  19:,
        PROJAMT_M          20:1 -  20:EN 15/3,
        PROJTRNCOD5        26:1 -  26:,
        FILLED1             1:1 -  19:,
        FILLED2            21:1 -  26:
/KEYS   PROJCTR_NF,
        PROJSEC_NF,
        PROJCUR_CF,
        PROJTRNCOD5
/DERIVEDFIELD AMT PROJAMT_M
/REFORMAT FILLED1, AMT, FILLED2
/OUTFILE ${SORT_O}
exit
EOF
SORT

	
NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="Get File of Asia specific contracts"
if [ -s ${DTRANSFER}/${REMOTE_SITE}/from/${ENV_PREFIX}_ESFD1800_FWH_ASIATRT_${CLODAT_D}_*.dat ]
then
	EXECKSH "cp ${DTRANSFER}/${REMOTE_SITE}/from/${ENV_PREFIX}_ESFD1800_FWH_ASIATRT_${CLODAT_D}_*.dat ${EST_ASIA_CONTRACTS}"
	EXECKSH "mv ${DTRANSFER}/${REMOTE_SITE}/from/${ENV_PREFIX}_ESFD1800_FWH_ASIATRT_${CLODAT_D}_*.dat ${DTRANSFER}/${REMOTE_SITE}/fromsave/"
else
  if [ ! -f ${EST_ASIA_CONTRACTS} ]
  then 
    touch ${EST_ASIA_CONTRACTS}
  fi
fi


NSTEP=${NJOB}_105
#------------------------------------------------------------------------------
LIBEL="Get File of Mastered specific contracts"
if [ -s ${DTRANSFER}/${REMOTE_SITE}/from/${ENV_PREFIX}_ESFD1800_FWH_MASTER_${CLODAT_D}_*.dat ]
then
	EXECKSH "cp ${DTRANSFER}/${REMOTE_SITE}/from/${ENV_PREFIX}_ESFD1800_FWH_MASTER_${CLODAT_D}_*.dat ${EST_MASTERED_CONTRACTS}"
	EXECKSH "mv ${DTRANSFER}/${REMOTE_SITE}/from/${ENV_PREFIX}_ESFD1800_FWH_MASTER_${CLODAT_D}_*.dat ${DTRANSFER}/${REMOTE_SITE}/fromsave/"
else
  if [ ! -f ${EST_MASTERED_CONTRACTS} ]
  then 
    touch ${EST_MASTERED_CONTRACTS}
  fi
fi


NSTEP=${NJOB}_108
#------------------------------------------------------------------------------
LIBEL="Merge omega files FWH and SRGTC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FUNDWITHHELD_LVL1} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FUNDWITHHELD_LVL1_SORT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF           8:1 -  8:,
        GT_SEC_NF          10:1 -  10:,
        GT_CUR_CF          18:1 -  18:,
        GT_TRNCOD5_CF      77:1 -  77:,
        ALLCOLS             1:1 -  78:
/KEYS   GT_CTR_NF,
        GT_SEC_NF,
        GT_CUR_CF,
        GT_TRNCOD5_CF
/OUTFILE ${SORT_O}
/DERIVEDFIELD SEPARATEUR "~~~~"
/REFORMAT ALLCOLS, SEPARATEUR
exit
EOF
SORT


NSTEP=${NJOB}_109
#------------------------------------------------------------------------------
LIBEL="Merge omega files FWH and SRGTC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTC_LVL1} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SRGTC_LVL1_SORT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS GT_CTR_NF           8:1 -  8:,
        GT_SEC_NF          10:1 -  10:,
        GT_CUR_CF          18:1 -  18:,
        GT_TRNCOD5_CF      77:1 -  77:,
        ALLCOLS             1:1 -  77:
/KEYS   GT_CTR_NF,
        GT_SEC_NF,
        GT_CUR_CF,
        GT_TRNCOD5_CF
/OUTFILE ${SORT_O}
/DERIVEDFIELD SEPARATEUR "~~~~~"
/REFORMAT ALLCOLS, SEPARATEUR
exit
EOF
SORT


NSTEP=${NJOB}_110
#------------------------------------------------------------------------------
LIBEL="Generation of Gobal file"
PRG="ESTC2171"
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_108_${IB}_FUNDWITHHELD_LVL1_SORT.dat
export ${PRG}_I2=${DFILT}/${NJOB}_109_${IB}_SRGTC_LVL1_SORT.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GLOBAL_FILE.dat
EXECPRG


NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
LIBEL="Merge omega files FWH and SRGTC and ASIA file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC2171_GLOBAL_FILE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GLOBAL_FILE_ASIA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 - 10:,
        ASIA_CTR_NF         1:1 -  1:,
        ASIA_SEC_NF         2:1 -  2:,
        ALLCOLS             1:1 - 83:
/joinkeys
        FWHCTR_NF,
        FWHSEC_NF
/INFILE ${EST_ASIA_CONTRACTS} 2000 1 "~"
/joinkeys
        ASIA_CTR_NF,
        ASIA_SEC_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/CONDITION ASIA ( ASIA_CTR_NF NE "" AND ASIA_SEC_NF NE "")
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD FLAGASIA IF ASIA THEN 1 ELSE 0
/REFORMAT
        leftside: ALLCOLS, rightside: FLAGASIA
exit
EOF
SORT


NSTEP=${NJOB}_125
#------------------------------------------------------------------------------
LIBEL="Merge omega files FWH and SRGTC and Mastered file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_GLOBAL_FILE_ASIA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GLOBAL_FILE_ASIA_MASTRT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 - 10:,
        FWHASIA_NF         82:1 - 82:,
        MSTRT_CTR_NF        1:1 -  1:,
        MSTRT_SEC_NF        2:1 -  2:,
        ALLCOLS             1:1 - 84:
/joinkeys
        FWHCTR_NF,
        FWHSEC_NF
/INFILE ${EST_MASTERED_CONTRACTS} 2000 1 "~"
/joinkeys
        MSTRT_CTR_NF,
        MSTRT_SEC_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/CONDITION MASTRT ( MSTRT_CTR_NF NE "" AND MSTRT_SEC_NF NE "")
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD FLAGMASTRT IF MASTRT THEN 1 ELSE 0
/REFORMAT
        leftside: ALLCOLS, rightside: FLAGMASTRT
exit
EOF
SORT




NSTEP=${NJOB}_130
#------------------------------------------------------------------------------
LIBEL="Sort file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_125_${IB}_GLOBAL_FILE_ASIA_MASTRT.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GLOBAL_FILE_ASIA_MASTRT_SORT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 -  10:,
        FWHCUR_CF          18:1 -  18:,
        FWHTRNCOD5_CF      77:1 -  77:
/KEYS   FWHCTR_NF,
        FWHSEC_NF,
        FWHCUR_CF,
        FWHTRNCOD5_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_135
#------------------------------------------------------------------------------
LIBEL="Sort file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_130_${IB}_GLOBAL_FILE_ASIA_MASTRT_SORT.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GLOBAL_FILE_ASIA_MASTRT_US_SORT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHSSD_CF           1:1 -  1:,
				FWHESB_CF           2:1 -  2:,
        FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 -  10:,
        FWHCUR_CF          18:1 -  18:,
        FWHTRNCOD5_CF      77:1 -  77:,
        ALLCOLS             1:1 -  85:
/KEYS   FWHCTR_NF,
        FWHSEC_NF,
        FWHCUR_CF,
        FWHTRNCOD5_CF
/OUTFILE ${SORT_O}
/CONDITION US ( FWHSSD_CF = "27" OR FWHSSD_CF = "10" AND FWHESB_CF = "14" )
/DERIVEDFIELD FLAGUS IF US THEN 1 ELSE 0
/REFORMAT
        ALLCOLS, FLAGUS
exit
EOF
SORT


NSTEP=${NJOB}_140
#------------------------------------------------------------------------------
LIBEL="Generation of Gobal file"
PRG="ESTC2162"
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_135_${IB}_GLOBAL_FILE_ASIA_MASTRT_US_SORT.dat
export ${PRG}_I2=${DFILT}/${NJOB}_95_${IB}_PROJECTION_LICLRC_TRNCOD_AGGREGATED.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GLOBAL_FILE.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ONLY_PROJECTION.dat
EXECPRG


NSTEP=${NJOB}_140Bis
#------------------------------------------------------------------------------
LIBEL="Generation of Gobal file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_PROJECTION_LICLRC_TRNCOD_AGGREGATED.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ONLY_PROJECTION.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PROJ_CTR_NF          12:1 - 12:,
				PROJ_SEC_NF          13:1 - 13:,
				PROJ_UWY_NF          14:1 - 14:,
				PROJ_CUR_CF          19:1 - 19:,
				PROJ_TRNCOD5_CF      26:1 - 26:,
				PROJ_LICLRC          25:1 - 25:,
				PROJ_AMT_M           20:1 - 20:,
        GT_CTR_NF             8:1 -  8:
/joinkeys
        PROJ_CTR_NF
/INFILE ${DFILT}/${NJOB}_135_${IB}_GLOBAL_FILE_ASIA_MASTRT_US_SORT.dat 2000 1 "~"
/joinkeys
        GT_CTR_NF
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O}
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD ZERO "0.000"
/DERIVEDFIELD ISAMT "1"
/REFORMAT
            SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, leftside: PROJ_CTR_NF, SEPARATEUR, leftside: PROJ_SEC_NF, leftside: PROJ_UWY_NF, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, leftside: PROJ_CUR_CF, ZERO, 
            SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, 
            leftside: PROJ_CUR_CF, ZERO, 
            SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, 
            SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR,  
            leftside: PROJ_TRNCOD5_CF, leftside: PROJ_LICLRC, ZERO, SEPARATEUR, ZERO, SEPARATEUR, leftside: PROJ_AMT_M, SEPARATEUR, leftside: PROJ_UWY_NF, SEPARATEUR, SEPARATEUR, SEPARATEUR

exit
EOF
SORT
            

NSTEP=${NJOB}_142
#------------------------------------------------------------------------------
LIBEL="Merge omega files ONLY Projection and ASIA file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140Bis_${IB}_ONLY_PROJECTION.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ONLY_PROJECTION.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 - 10:,
        ASIA_CTR_NF         1:1 -  1:,
        ASIA_SEC_NF         2:1 -  2:,
        ALLCOLS             1:1 - 83:
/joinkeys
        FWHCTR_NF,
        FWHSEC_NF
/INFILE ${EST_ASIA_CONTRACTS} 2000 1 "~"
/joinkeys
        ASIA_CTR_NF,
        ASIA_SEC_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/CONDITION ASIA ( ASIA_CTR_NF NE "" AND ASIA_SEC_NF NE "")
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD FLAGASIA IF ASIA THEN 1 ELSE 0
/REFORMAT
        leftside: ALLCOLS, rightside: FLAGASIA
exit
EOF
SORT


NSTEP=${NJOB}_144
#------------------------------------------------------------------------------
LIBEL="Merge omega files ONLY Projection and Mastered file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_142_${IB}_ONLY_PROJECTION.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ONLY_PROJECTION.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 - 10:,
        FWHASIA_NF         82:1 - 82:,
        MSTRT_CTR_NF        1:1 -  1:,
        MSTRT_SEC_NF        2:1 -  2:,
        ALLCOLS             1:1 - 84:
/joinkeys
        FWHCTR_NF,
        FWHSEC_NF
/INFILE ${EST_MASTERED_CONTRACTS} 2000 1 "~"
/joinkeys
        MSTRT_CTR_NF,
        MSTRT_SEC_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/CONDITION MASTRT ( MSTRT_CTR_NF NE "" AND MSTRT_SEC_NF NE "")
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD FLAGMASTRT IF MASTRT THEN 1 ELSE 0
/REFORMAT
        leftside: ALLCOLS, rightside: FLAGMASTRT
exit
EOF
SORT


NSTEP=${NJOB}_146
#------------------------------------------------------------------------------
LIBEL="Sort file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_144_${IB}_ONLY_PROJECTION.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ONLY_PROJECTION.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHSSD_CF           1:1 -  1:,
				FWHESB_CF           2:1 -  2:,
        FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 -  10:,
        FWHCUR_CF          18:1 -  18:,
        FWHTRNCOD5_CF      77:1 -  77:,
        ALLCOLS             1:1 -  85:
/KEYS   FWHCTR_NF,
        FWHSEC_NF,
        FWHCUR_CF,
        FWHTRNCOD5_CF
/OUTFILE ${SORT_O}
/CONDITION US ( FWHSSD_CF = "27" OR FWHSSD_CF = "10" AND FWHESB_CF = "14" )
/DERIVEDFIELD FLAGUS IF US THEN 1 ELSE 0
/DERIVEDFIELD ISAMT "~1"
/REFORMAT
        ALLCOLS, FLAGUS, ISAMT
exit
EOF
SORT


NSTEP=${NJOB}_150
#------------------------------------------------------------------------------
LIBEL="Sort file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_140_${IB}_ESTC2162_GLOBAL_FILE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GLOBAL_FILE_SORT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 -  10:,
        FWHCUR_CF          18:1 -  18:,
        FWHTRNCOD5_CF      77:1 -  77:
/KEYS   FWHCTR_NF,
        FWHSEC_NF,
        FWHCUR_CF,
        FWHTRNCOD5_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_155
#------------------------------------------------------------------------------
LIBEL="Check if there is an amount different of 0 for projection for each CTR/SEC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_150_${IB}_GLOBAL_FILE_SORT.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_CTRSEC_WITH_AMOUNT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 - 10:,
        FWHAMTPROJ         81:1 - 81:EN 15/3
/CONDITION AMTPROJ ( FWHAMTPROJ != 0 )
/OUTFILE ${SORT_O}
/INCLUDE AMTPROJ
/REFORMAT
        FWHCTR_NF, FWHSEC_NF, FWHAMTPROJ
exit
EOF
SORT


NSTEP=${NJOB}_155A
#------------------------------------------------------------------------------
LIBEL="Check if there is an amount different of 0 for projection for each CTR/SEC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_150_${IB}_GLOBAL_FILE_SORT.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2162_GLOBAL_FILE_SORT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 - 10:,
        CTR_NF              1:1 -  1:,
        SEC_NF              2:1 -  2:,
        ALLCOLS             1:1 - 86:
/joinkeys
        FWHCTR_NF,
        FWHSEC_NF
/INFILE ${DFILT}/${NJOB}_155_${IB}_CTRSEC_WITH_AMOUNT.dat 2000 1 "~"
/joinkeys
        CTR_NF,
        SEC_NF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/CONDITION AMT ( CTR_NF NE "" AND SEC_NF NE "")
/DERIVEDFIELD SEPARATEUR "~"
/DERIVEDFIELD FLAGAMT IF AMT THEN 1 ELSE 0
/REFORMAT
        leftside: ALLCOLS, rightside: FLAGAMT
exit
EOF
SORT


NSTEP=${NJOB}_155B
#------------------------------------------------------------------------------------
LIBEL="Check if there is an amount different of 0 for projection for each CTR/SEC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_155A_${IB}_ESTC2162_GLOBAL_FILE_SORT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2162_GLOBAL_FILE_SORT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        FWHCTR_NF           8:1 -   8:,
        FWHSEC_NF          10:1 -  10:,
        FWHUWY_NF          11:1 -  11:,
        FWHCUR_CF          18:1 -  18:,
        FWHTRNCOD5_CF      77:1 -  77:,
        FWHLRCLIC          78:1 -  78:,
        FWHAMT_GT          79:1 -  79:,
        FWHAMT_FWHOMEGA    80:1 -  80:,
        FWHAMTPROJ         81:1 -  81:,
        UWY_GT             82:1 -  82:,
        UWY_PROJ           83:1 -  83:,
        FWHASIE            84:1 -  84:,
        FWHMSTR            85:1 -  85:,
        FWHUS              86:1 -  86:,
        FWHAMT             87:1 -  87:
/KEYS   FWHCTR_NF, FWHSEC_NF, FWHUWY_NF, FWHCUR_CF, FWHTRNCOD5_CF, FWHLRCLIC, FWHAMT_GT, FWHAMT_FWHOMEGA, FWHAMTPROJ, UWY_GT, UWY_PROJ, FWHASIE, FWHMSTR, FWHUS, FWHAMT
/SUM
/STABLE
exit
EOF
SORT


NSTEP=${NJOB}_155C
#------------------------------------------------------------------------------------
LIBEL="Check if there is an amount different of 0 for projection for each CTR/SEC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_155B_${IB}_ESTC2162_GLOBAL_FILE_SORT.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_146_${IB}_ONLY_PROJECTION.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2162_GLOBAL_FILE_SORT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        FWHCTR_NF           8:1 -   8:,
        FWHSEC_NF          10:1 -  10:,
        FWHUWY_NF          11:1 -  11:
/KEYS   FWHCTR_NF, FWHSEC_NF, FWHUWY_NF
exit
EOF
SORT


NSTEP=${NJOB}_158
#-----------------------------------------------------------------------------
LIBEL="Merge PERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE} 1000 1"
SORT_I2="${EST_IRDVPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IARDVPERICASE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS PER_SSD_CF          1:1 -   1:,
        PER_CTR_NF          3:1 -   3:,
        PER_SEC_NF          5:1 -   5:,
        PER_UWY_NF          6:1 -   6:,
        PER_ESB_CF          8:1 -   8:
/KEYS   PER_CTR_NF,
        PER_SEC_NF,
        PER_UWY_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_160
#------------------------------------------------------------------------------
LIBEL="Calculation of FWH Accrual"
PRG="ESTC2163"
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
NORME    ${NORME}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_155C_${IB}_ESTC2162_GLOBAL_FILE_SORT.dat
export ${PRG}_I2=${DFILT}/${NJOB}_158_${IB}_SORT_IARDVPERICASE.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GLOBAL_FILE_CALCULATED.dat
EXECPRG


NSTEP=${NJOB}_170
#------------------------------------------------------------------------------
LIBEL="Make Global file FWH"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_160_${IB}_ESTC2163_GLOBAL_FILE_CALCULATED.dat 1000 1"
SORT_O="${EST_FWHGLOBALFILE} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 -  10:,
        FWHUWY_NF          11:1 -  11:,
        FWHSSD_CF           1:1 -  1:,
        FWHESB_CF           2:1 -  2:,
        FWHAMT_M           19:1 -  19:,
        FWHLRCLIC          78:1 -  78:,
        FWHMSTR            85:1 -  85:,
        FWHASIE            84:1 -  84:,
        FWHUS              86:1 -  86:,
        FWHCUR_CF          18:1 -  18:,
        FWHTRNCOD5_CF      77:1 -  77:,
        FWHAMT_GT          79:1 -  79:,
        FWHAMT_FWHOMEGA    80:1 -  80:,
        FWHAMTPROJ         81:1 -  81:,
        UWY_GT             82:1 -  82:,
        UWY_PROJ           83:1 -  83:
/KEYS   FWHCTR_NF,
        FWHSEC_NF,
        FWHUWY_NF,
        FWHCUR_CF,
        FWHTRNCOD5_CF
/OUTFILE ${SORT_O}
/REFORMAT
         FWHCTR_NF, FWHSEC_NF, FWHUWY_NF, FWHSSD_CF, FWHESB_CF, FWHLRCLIC, FWHMSTR, FWHASIE, FWHUS, FWHTRNCOD5_CF, FWHCUR_CF, FWHAMT_GT, UWY_GT, FWHAMT_FWHOMEGA, FWHUWY_NF, FWHAMTPROJ, UWY_PROJ, FWHAMT_M
exit
EOF
SORT


NSTEP=${NJOB}_180
#------------------------------------------------------------------------------
LIBEL="Merge FWH calculated with FWH omega"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_160_${IB}_ESTC2163_GLOBAL_FILE_CALCULATED.dat 1000 1"
SORT_I2="${EST_FUNDWITHHELD_I17_PC} 10000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FWH_MERGED_SORT.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FWHCTR_NF           8:1 -  8:,
        FWHSEC_NF          10:1 -  10:,
        FILLED_1_75      1:1 - 75:
/KEYS   FWHCTR_NF,
        FWHSEC_NF
/OUTFILE ${SORT_O}
/REFORMAT
         FILLED_1_75
exit
EOF
SORT

JOBEND

