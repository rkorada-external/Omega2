#!/bin/ksh
#=======================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des Cashflow et valeur escompte
# nom du script SHELL           : ESID3701.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/04/2012
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  :spot:23802 Calcul des Cashflow et valeur escompte
#
#-----------------------------------------------------------------------------
# historiques des modifications
#========================================
#[001] 29/08/2012 R. Cassis :spot:24041 - Modifs Solvency 2
#[002] 14/11/2013 R. Cassis :spot:25427 - modifs centralization des bases
#========================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
ICLODAT_D=$3
TYPEINV=$4

datej=`date '+%Y%m%d%H%M%S'`
datedel=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-1; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`

if [ "${EST_ESPD2000_COND3}" = "Y" ]
then
	export EST_CURGTA=${DARCH}/`basename ${EST_CURGTA} .dat`_${ICLODAT_A}${ICLODAT_M}.arc
fi

if [ "${TYPEINV}" != "INV" ]
then
	if [ "${TYPEINV}" = "POS" ]
	then
		#en entrée
		EST_DLDGTAA=${EPO_DLDGTAASO}
		EST_DLREGTAR=${EPO_DLREGTARSO}
		EST_DLREMAJGTAR=${EPO_DLREMAJGTARSO}
		EST_DLSGTAA=${EPO_DLSGTAASIISO}
		EST_DLSGTAR=${EPO_DLSGTARSIISO}
		EST_DLSGTR=${EPO_DLSGTRSIISO}
		EST_CURGTA=${EPO_FTECLEDASO}		
		#en sortie
		EST_TOTSAPGTAA=${EPO_TOTSAPGTAASO}
		EST_TOTSAPGTAR=${EPO_TOTSAPGTARSO}
		TYPEPO=SO
	else
		EST_DLDGTAA=${EPO_DLDGTAACO}
		EST_DLREGTAR=${EPO_DLREGTARCO}
		EST_DLREMAJGTAR=${EPO_DLREMAJGTARCO}
		EST_TOTSAPGTAA=${EPO_TOTSAPGTAACO}
		EST_TOTSAPGTAR=${EPO_TOTSAPGTARCO}
		EST_DLSGTAA=${EPO_DLSGTAASIICO}
		EST_DLSGTAR=${EPO_DLSGTARSIICO}
		EST_DLSGTR=${EPO_DLSGTRSIISCO}
		EST_CURGTA=${EPO_FTECLEDASIISO}
		#en sortie
		EST_TOTSAPGTAA=${EPO_TOTSAPGTAASO}
		EST_TOTSAPGTAR=${EPO_TOTSAPGTARSO}
		TYPEPO=CO
	fi
fi

NSTEP=${NJOB}_00
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${datedel}*.dat"

if [ "${TYPEINV}" = "INV" ]
then
	NSTEP=${NJOB}_04
	# Copie fichiers
	#------------------------------------------------------------------------------
	LIBEL="cat ${EST_DLRTFGTAR} ${EST_IGTAR} > ${DFILT}/${NSTEP}_${IB}_KSH_IGTAR_O.dat"
	EXECKSH_MODE=P
	EXECKSH "cat ${EST_DLRTFGTAR} ${EST_IGTAR} > ${DFILT}/${NSTEP}_${IB}_KSH_IGTAR_O.dat"

	NSTEP=${NJOB}_05
	#-----------------------------------------------------------------------------
	# GT files merge
	#-----------------------------------------------------------------------------
	LIBEL="Merge and sort of dGT files ..."
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	#SORT_I4=${EST_DLRGTAA}
	SORT_I="${EST_DLDGTAA} 1000 1"
	SORT_I2=${EST_DLSGTAA}
	SORT_I3=${EST_DLAGTAA}
	SORT_I4=${EST_IGTAAF}
	SORT_I5=${EST_DLAGTAR}
	SORT_I6=${EST_DLRTCGTAR}
	SORT_I7=${EST_DLRTGTAR}
	SORT_I8=${EST_DLREGTAR}
	SORT_I9=${EST_DLREMAJGTAR}
	SORT_I10=${EST_DLRPGTAR}
	SORT_I11=${EST_DLRNPGTAR}
	SORT_I12=${EST_DLSGTAR}
	SORT_I13="${DFILT}/${NJOB}_04_${IB}_KSH_IGTAR_O.dat 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGT_O.dat 1000 1"
	INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        AMT_M            19:1 - 19:EN 15/3,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS  TRNCOD1_CF
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,CUR_CF
      ,RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RTY_NF
      ,RETUW_NT
      ,RETCUR_CF
      ,PLC_NT
      ,RTO_NF
      ,TRNCOD_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
exit
EOF
	SORT

else
# /* aller chercher les lignes du trimestre dans CURGTA (accept + retro) */
	NSTEP=${NJOB}_06
	#-----------------------------------------------------------------------------
	# GT files merge
	#-----------------------------------------------------------------------------
	LIBEL="Merge and sort of dGT files ..."
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_CURGTA} 1000 1"
	SORT_I2="${EST_DLSGTAA} 1000 1"
	SORT_I3="${EST_DLSGTAR} 1000 1"
#	SORT_I3="${EST_DLDGTAA} 1000 1"
#	SORT_I4="${EST_DLREGTAR} 1000 1"
#	SORT_I5="${EST_DLREMAJGTAR} 1000 1"
	SORT_O="${DFILT}/${NJOB}_05_${IB}_SORT_DLSIIGT_O.dat 1000 1"
	INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        FILLER1           6:1 - 18:,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
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
        FILLER2          20:1 - 34:,
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
        FILLER3          36:1 - 40:,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS   TRNCOD1_CF
       ,CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,PLC_NT
       ,TRNCOD_CF
/CONDITION TRIMCOUR ( BALSHEY_NF EQ ${ICLODAT_A} AND BALSHRMTH_NF EQ ${ICLODAT_M} )
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD BALSHEY_NF_NEW "$ICLODAT_A~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "$ICLODAT_M~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "$ICLODAT_J~"
/OUTFILE ${SORT_O}
/INCLUDE TRIMCOUR
/REFORMAT
  SSD_CF
  ,ESB_CF
  ,BALSHEY_NF_NEW
  ,BALSHRMTH_NF_NEW
  ,BALSHRDAY_NF_NEW
  ,FILLER1
  ,AMT_MC
  ,FILLER2
  ,RETAMT_MC
  ,FILLER3
  ,RETINTAMT_MC
exit
EOF
	SORT

fi

NSTEP=${NJOB}_07
# exec awk
#-----------------------------------------------------------------------------
LIBEL="Add 16 cols if not exist"
AWK_I=${DFILT}/${NJOB}_05_${IB}_SORT_DLSIIGT_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLSIIGT_O.dat
#AWK_O=${EST_TOTGTAARSAP}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{	if ( NF < 57 ) print \$0 "~~~~~~~~~~~~~~~~GTAR";
		else print \$0;
	}
exit
EOF
AWK

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
# GT files include PNA + SAP
#[007]
#-----------------------------------------------------------------------------
LIBEL="GT files include PNA + SAP ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_07_${IB}_AWK_DLSIIGT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSAPGTAAR_O1.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLPNAGTAAR_O1.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        AMT_M            19:1 - 19:EN 15/3,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,CUR_CF
      ,TRNCOD_CF
      ,RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RTY_NF
      ,RETUW_NT
      ,RETCUR_CF
      ,PLC_NT
      ,RTO_NF
/CONDITION SAP_ACR
          ( TRNCOD_CF = "11102500" OR TRNCOD_CF = "11103500" OR TRNCOD_CF = "11102100" OR TRNCOD_CF = "11103100" OR TRNCOD_CF = "11102300" OR TRNCOD_CF = "11102400" OR TRNCOD_CF = "11103400" OR
            TRNCOD_CF = "11102000" OR TRNCOD_CF = "11103000" OR TRNCOD_CF = "11102200" OR TRNCOD_CF = "11103200" OR TRNCOD_CF = "11141000" OR TRNCOD_CF = "11142000" OR TRNCOD_CF = "11450000" OR
            TRNCOD_CF = "11451000" OR TRNCOD_CF = "11480200" OR TRNCOD_CF = "11481200" OR TRNCOD_CF = "11480100" OR TRNCOD_CF = "11487000" OR TRNCOD_CF = "11480000" OR TRNCOD_CF = "11440000" OR
            TRNCOD_CF = "11441000" OR TRNCOD_CF = "11481100" OR TRNCOD_CF = "11481000" OR TRNCOD_CF = "11420000" OR TRNCOD_CF = "11420500" OR TRNCOD_CF = "11421500" OR TRNCOD_CF = "11420600" OR
            TRNCOD_CF = "11421600" OR TRNCOD_CF = "11421000" OR TRNCOD_CF = "11420400" OR TRNCOD_CF = "11421400" OR TRNCOD_CF = "11427000" OR TRNCOD_CF = "11428000" OR
            TRNCOD_CF = "11427900" OR TRNCOD_CF = "11420900" OR TRNCOD_CF = "11421900" OR TRNCOD_CF = "11423000" OR TRNCOD_CF = "11424000" OR TRNCOD_CF = "11492200" OR TRNCOD_CF = "11493200" OR
            TRNCOD_CF = "11460200" OR TRNCOD_CF = "11461200" OR
            TRNCOD_CF = "21102500" OR TRNCOD_CF = "21103500" OR TRNCOD_CF = "21102100" OR TRNCOD_CF = "21103100" OR TRNCOD_CF = "21102300" OR TRNCOD_CF = "21102400" OR TRNCOD_CF = "21103400" OR
            TRNCOD_CF = "21102000" OR TRNCOD_CF = "21103000" OR TRNCOD_CF = "21102200" OR TRNCOD_CF = "21103200" OR TRNCOD_CF = "21141000" OR TRNCOD_CF = "21142000" OR TRNCOD_CF = "21450000" OR
            TRNCOD_CF = "21451000" OR TRNCOD_CF = "21480200" OR TRNCOD_CF = "21481200" OR TRNCOD_CF = "21480100" OR TRNCOD_CF = "21487000" OR TRNCOD_CF = "21480000" OR TRNCOD_CF = "21440000" OR
            TRNCOD_CF = "21441000" OR TRNCOD_CF = "21481100" OR TRNCOD_CF = "21481000" OR TRNCOD_CF = "21420000" OR TRNCOD_CF = "21420500" OR TRNCOD_CF = "21421500" OR TRNCOD_CF = "21420600" OR
            TRNCOD_CF = "21421600" OR TRNCOD_CF = "21421000" OR TRNCOD_CF = "21420400" OR TRNCOD_CF = "21421400" OR TRNCOD_CF = "21427000" OR TRNCOD_CF = "21428000" OR
            TRNCOD_CF = "21427900" OR TRNCOD_CF = "21420900" OR TRNCOD_CF = "21421900" OR TRNCOD_CF = "21423000" OR TRNCOD_CF = "21424000" OR TRNCOD_CF = "21492200" OR TRNCOD_CF = "21493200" OR
            TRNCOD_CF = "21460200" OR TRNCOD_CF = "21461200" )
/CONDITION PNA_FAR
          ( TRNCOD_CF = "11410000" OR TRNCOD_CF = "11410002" OR TRNCOD_CF = "11410006" OR TRNCOD_CF = "11411000" OR TRNCOD_CF = "11411002" OR TRNCOD_CF = "11411012" OR TRNCOD_CF = "11418000" OR
            TRNCOD_CF = "11418002" OR TRNCOD_CF = "11419000" OR TRNCOD_CF = "11419002" OR TRNCOD_CF = "11430000" OR TRNCOD_CF = "11430002" OR TRNCOD_CF = "11430006" OR TRNCOD_CF = "11431000" OR
            TRNCOD_CF = "11431002" OR TRNCOD_CF = "11431012" OR TRNCOD_CF = "11436000" OR TRNCOD_CF = "11436002" OR TRNCOD_CF = "11436006" OR TRNCOD_CF = "11437000" OR TRNCOD_CF = "11437002" OR
            TRNCOD_CF = "11437012" OR
            TRNCOD_CF = "21410000" OR TRNCOD_CF = "21410002" OR TRNCOD_CF = "21410006" OR TRNCOD_CF = "21411000" OR TRNCOD_CF = "21411002" OR TRNCOD_CF = "21411012" OR TRNCOD_CF = "21418000" OR
            TRNCOD_CF = "21418002" OR TRNCOD_CF = "21419000" OR TRNCOD_CF = "21419002" OR TRNCOD_CF = "21430000" OR TRNCOD_CF = "21430002" OR TRNCOD_CF = "21430006" OR TRNCOD_CF = "21431000" OR
            TRNCOD_CF = "21431002" OR TRNCOD_CF = "21431012" OR TRNCOD_CF = "21436000" OR TRNCOD_CF = "21436002" OR TRNCOD_CF = "21436006" OR TRNCOD_CF = "21437000" OR TRNCOD_CF = "21437002" OR
            TRNCOD_CF = "21437012" OR TRNCOD_CF = "21410004" OR TRNCOD_CF = "21430004" OR
            TRNCOD_CF = "14410000" OR TRNCOD_CF = "14410002" OR TRNCOD_CF = "14411000" OR TRNCOD_CF = "14411002" OR TRNCOD_CF = "14430000" OR TRNCOD_CF = "14430002" OR TRNCOD_CF = "14431000" OR
            TRNCOD_CF = "14431002" OR TRNCOD_CF = "14433000" OR TRNCOD_CF = "14433002" OR TRNCOD_CF = "14434000" OR TRNCOD_CF = "14434002" OR TRNCOD_CF = "14436000" OR TRNCOD_CF = "14436002" OR
            TRNCOD_CF = "14437002" OR
            TRNCOD_CF = "24410000" OR TRNCOD_CF = "24410002" OR TRNCOD_CF = "24411000" OR TRNCOD_CF = "24411002" OR TRNCOD_CF = "24430000" OR TRNCOD_CF = "24430002" OR TRNCOD_CF = "24431000" OR
            TRNCOD_CF = "24431002" OR TRNCOD_CF = "24433000" OR TRNCOD_CF = "24433002" OR TRNCOD_CF = "24434000" OR TRNCOD_CF = "24434002" OR TRNCOD_CF = "24436000" OR TRNCOD_CF = "24436002" OR
            TRNCOD_CF = "24437002" OR
            TRNCOD_CF = "1A410000" OR TRNCOD_CF = "1A410002" OR TRNCOD_CF = "1A410006" OR TRNCOD_CF = "1A411000" OR TRNCOD_CF = "1A411002" OR TRNCOD_CF = "1A411012" OR TRNCOD_CF = "1A418000" OR
            TRNCOD_CF = "1A418002" OR TRNCOD_CF = "1A419000" OR TRNCOD_CF = "1A419002" OR TRNCOD_CF = "1A430000" OR TRNCOD_CF = "1A430002" OR TRNCOD_CF = "1A430006" OR TRNCOD_CF = "1A431000" OR
            TRNCOD_CF = "1A431002" OR TRNCOD_CF = "1A431012" OR TRNCOD_CF = "1A436000" OR TRNCOD_CF = "1A436002" OR TRNCOD_CF = "1A436006" OR TRNCOD_CF = "1A437000" OR TRNCOD_CF = "1A437002" OR
            TRNCOD_CF = "1A437012" OR
            TRNCOD_CF = "2A410000" OR TRNCOD_CF = "2A410002" OR TRNCOD_CF = "2A410006" OR TRNCOD_CF = "2A411000" OR TRNCOD_CF = "2A411002" OR TRNCOD_CF = "2A411012" OR TRNCOD_CF = "2A418000" OR
            TRNCOD_CF = "2A418002" OR TRNCOD_CF = "2A419000" OR TRNCOD_CF = "2A419002" OR TRNCOD_CF = "2A430000" OR TRNCOD_CF = "2A430002" OR TRNCOD_CF = "2A430006" OR TRNCOD_CF = "2A431000" OR
            TRNCOD_CF = "2A431002" OR TRNCOD_CF = "2A431012" OR TRNCOD_CF = "2A436000" OR TRNCOD_CF = "2A436002" OR TRNCOD_CF = "2A436006" OR TRNCOD_CF = "2A437000" OR TRNCOD_CF = "2A437002" OR
            TRNCOD_CF = "2A437012" )
/OUTFILE ${SORT_O}
/INCLUDE SAP_ACR
/OUTFILE ${SORT_O2}
/INCLUDE PNA_FAR
exit
EOF
SORT

NSTEP=${NJOB}_15
# exec awk
#-----------------------------------------------------------------------------
LIBEL="Update oricod_ls to EBSGTA for trn EBS"
AWK_I=${DFILT}/${NJOB}_10_${IB}_SORT_DLSAPGTAAR_O1.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLSAPGTAAR_O1.dat
#AWK_O=${EST_TOTGTAARSAP}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{	post = substr(\$6,2,1);
		if ( post == "A" || post == "B" || post == "D" || post == "E" || post == "G" ||
		     post == "H" || post == "J" || post == "K" || post == "L" )
		{
			if ( NF == 57 )
			{
				\$57 = "EBSGTA";
				print \$0;
			}
			else print \$0 "~~~~~~~~~~~~~~~~EBSGTA";
		}
		else
		{
			if ( NF != 57 ) print \$0 "~~~~~~~~~~~~~~~~GTAR";
			else print \$0;
		}
	}
exit
EOF
AWK

NSTEP=${NJOB}_16
#-----------------------------------------------------------------------------
LIBEL="Omit zero amounts and separate EBS and BEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_AWK_DLSAPGTAAR_O1.dat 1000 1"
SORT_O="${EST_TOTSAPGTAA} OVERWRITE"
SORT_O2="${EST_TOTSAPGTAR} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        AMT_M            19:1 - 19:EN 15/3,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,CUR_CF
      ,TRNCOD_CF
      ,RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RTY_NF
      ,RETUW_NT
      ,RETCUR_CF
      ,PLC_NT
      ,RTO_NF
/CONDITION EBS_GTAA TRNCOD1_CF='1' AND (AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0)
/CONDITION EBS_GTAR TRNCOD1_CF='2' AND (AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0)
/OUTFILE ${SORT_O}
/INCLUDE EBS_GTAA
/OUTFILE ${SORT_O2}
/INCLUDE EBS_GTAR
exit
EOF
SORT

##
###[005]
##NSTEP=${NJOB}_20
### Inversion of amounts to DAC records
###-----------------------------------------------------------------------------
##LIBEL="Inversion of amounts to PNA/DAC Accept records"
##AWK_I=${DFILT}/${NJOB}_10_${IB}_SORT_DLPNAGTAAR_O1.dat
##AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLPNAGTAAR.dat
##AWK_CMD=`CFTMP`
##INPUT_TEXT ${AWK_CMD} <<EOF
##BEGIN{ FS="\~"; OFS="\~" }
##	{
##				\$19 = sprintf("%-.3lf",-\$19);
##				\$35 = sprintf("%-.3lf",-\$35);
##				\$41 = sprintf("%-.3lf",-\$41);
##				print \$0;
##	}
##exit
##EOF
##AWK
##
##	NSTEP=${NJOB}_30
##	#-----------------------------------------------------------------------------
##	# GT SPLIT
##	#[007]
##	#-----------------------------------------------------------------------------
##	LIBEL="1GL: Merge and sort of dGTAa files ..."
##	SORT_WDIR=${SORTWORK}
##	SORT_CMD=`CFTMP`
##	SORT_I="${DFILT}/${NJOB}_20_${IB}_AWK_DLPNAGTAAR.dat 1000 1"
##	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLPNAGTAAR_IFRS.dat 1000 1"
##	SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLPNAGTAAR_EBS.dat 1000 1"
##	INPUT_TEXT ${SORT_CMD} << EOF
##/FIELDS SSD_CF           1:1 -  1:EN,
##        ESB_CF           2:1 -  2:EN,
##        BALSHEY_NF       3:1 -  3:EN,
##        BALSHRMTH_NF     4:1 -  4:EN,
##        BALSHRDAY_NF     5:1 -  5:EN,
##        TRNCOD_CF        6:1 -  6:,
##        TRNCOD2_CF       6:2 -  6:2,
##        TRNCOD8_CF       6:8 -  6:8,
##        CTR_NF           8:1 -  8:,
##        END_NT           9:1 -  9:EN,
##        SEC_NF          10:1 - 10:EN,
##        UWY_NF          11:1 - 11:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      TRNCOD_CF
##/CONDITION COND_EBS ( TRNCOD2_CF = "A" OR TRNCOD2_CF = "E" OR TRNCOD2_CF = "J" )
##/OUTFILE ${SORT_O}
##/OMIT COND_EBS
##/OUTFILE ${SORT_O2}
##/INCLUDE COND_EBS
##exit
##EOF
##	SORT
##
##if [ ! -s ${DFILT}/${NJOB}_30_${IB}_SORT_DLPNAGTAAR_EBS.dat ]
##then
##	#[005]
##	NSTEP=${NJOB}_31
##	#------------------------------------------------------------------------------
##	#-----------------------------------------------------------------------------
##	LIBEL="touch ${DFILT}/${NJOB}_30_${IB}_SORT_DLPNAGTAAR_EBS.dat"
##	echo "1~1~2012~12~31~11410002~12410002~01F000000~1~1~1998~1~1998~2012~12~12~~GBP~0.000~11876~12010~10970~A ~~~~~~~~~~~~-0.000~~~~~~0.000~~~~~~~~~~~~~~~16336227~" > ${DFILT}/${NJOB}_30_${IB}_SORT_DLPNAGTAAR_EBS.dat
##fi
##
##NSTEP=${NJOB}_32
### exec awk
###-----------------------------------------------------------------------------
##LIBEL="update 2nd col trncod EBS to old codes"
##AWK_I=${DFILT}/${NJOB}_30_${IB}_SORT_DLPNAGTAAR_EBS.dat
##AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLPNAGTAAR_EBS.dat
##AWK_CMD=`CFTMP`
##INPUT_TEXT ${AWK_CMD} <<EOF
##BEGIN{ FS="\~"; OFS="\~" }
##	{	post = substr(\$6,2,1);
##		if ( post == "A" || post == "E" || post == "J" )
##		{
##			if ( post == "A" ) post2 = "1";
##			if ( post == "E" ) post2 = "4";
##			if ( post == "J" ) post2 = "7";
##			\$6 = substr(\$6,1,1) post2 substr(\$6,3,6);
##		}
##		print \$0;
##	}
##exit
##EOF
##AWK
##
###[005]
##NSTEP=${NJOB}_40
### Begin C program
###-----------------------------------------------------------------------------
##LIBEL="Create Ecart Data for EBS and BEST Trncod from full Accept file"
##PRG=ESTC1054
##FPRM=`CFTMP`
##INPUT_TEXT ${FPRM} << EOF
##ICLODAT_D ${ICLODAT_D}
##ACCRET_CT A
##exit
##EOF
##export ${PRG}_PRM=${FPRM}
##export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_DLPNAGTAAR_IFRS.dat
##export ${PRG}_I2=${DFILT}/${NJOB}_32_${IB}_AWK_DLPNAGTAAR_EBS.dat
##export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAAR_E_EBSBEST.dat
##EXECPRG
##
##NSTEP=${NJOB}_50
### exec awk
###-----------------------------------------------------------------------------
##LIBEL="Update oricod_ls to EBSGTA for trn EBS"
##AWK_I=${DFILT}/${NJOB}_40_${IB}_ESTC1054_DLDGTAAR_E_EBSBEST.dat
##AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLDGTAAR_E_EBSBEST.dat
##AWK_CMD=`CFTMP`
##INPUT_TEXT ${AWK_CMD} <<EOF
##BEGIN{ FS="\~"; OFS="\~" }
##	{	post = substr(\$6,2,1);
##		if ( post == "A" || post == "B" || post == "D" || post == "E" || post == "G" ||
##		     post == "H" || post == "J" || post == "K" || post == "L" )
##		{
##			if ( NF == 57 )
##			{
##				\$57 = "EBSGTA";
##				print \$0;
##			}
##			else print \$0 "~~~~~~~~~~~~~~~~EBSGTA";
##		}
##		else
##		{
##			if ( NF != 57 ) print \$0 "~~~~~~~~~~~~~~~~GTAR";
##			else print \$0;
##		}
##	}
##exit
##EOF
##AWK
##
##NSTEP=${NJOB}_60
###-----------------------------------------------------------------------------
##LIBEL="Omit zero amounts and separate EBS and BEST"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${DFILT}/${NJOB}_50_${IB}_AWK_DLDGTAAR_E_EBSBEST.dat 1000 1"
##SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_E_EBSBEST.dat 1000 1"
##SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAR_E_EBSBEST.dat 1000 1"
##INPUT_TEXT ${SORT_CMD} <<EOF
##/FIELDS TRNCOD_CF        6:1 -  6:,
##        TRNCOD1_CF       6:1 -  6:1,
##        TRNCOD2_CF       6:2 -  6:2,
##        CTR_NF           8:1 -  8:,
##        END_NT           9:1 -  9:EN,
##        SEC_NF          10:1 - 10:EN,
##        UWY_NF          11:1 - 11:,
##        UW_NT           12:1 - 12:EN,
##        ACY_NF          14:1 - 14:,
##        SCOENDMTH_NF    16:1 - 16:EN,
##        SCOSTRMTH_NF    15:1 - 15:EN,
##        OCCYEA_NF       13:1 - 13:,
##        CLM_NF          17:1 - 17:,
##        CUR_CF          18:1 - 18:,
##        AMT_M           19:1 - 19:EN 15/3,
##        RETCTR_NF       24:1 - 24:,
##        RETEND_NT       25:1 - 25:EN,
##        RETSEC_NF       26:1 - 26:EN,
##        RTY_NF          27:1 - 27:,
##        RETUW_NT        28:1 - 28:EN,
##        RETACY_NF       30:1 - 30:,
##        RETSCOENDMTH_NF 32:1 - 32:EN,
##        RETSCOSTRMTH_NF 31:1 - 31:EN,
##        RETOCCYEA_NF    29:1 - 29:,
##        RCL_NF          33:1 - 33:,
##        RETCUR_CF       34:1 - 34:,
##        RETAMT_M        35:1 - 35:EN 15/3,
##        PLC_NT          36:1 - 36:EN,
##        RETINTAMT_M     41:1 - 41:EN 15/3,
##        ORICOD_LS       57:1 - 57:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT,
##      ACY_NF,
##      SCOENDMTH_NF,
##      SCOSTRMTH_NF,
##      OCCYEA_NF,
##      CLM_NF,
##      CUR_CF,
##      TRNCOD_CF
##/CONDITION EBS_GTAA  ORICOD_LS = 'EBSGTA' AND TRNCOD1_CF='1' AND (AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0)
##/CONDITION EBS_GTAR  ORICOD_LS = 'EBSGTA' AND TRNCOD1_CF='2' AND (AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0)
##/OUTFILE ${SORT_O}
##/INCLUDE EBS_GTAA
##/OUTFILE ${SORT_O2}
##/INCLUDE EBS_GTAR
##exit
##EOF
##SORT
##
########################
# Erase temporary files #
########################

NSTEP=${NJOB}_100
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers"
EXECKSH_MODE=P
#EXECKSH "gzip ${EST_XXXXX}"
#EXECKSH "gzip ${EST_XXXXX}"

NSTEP=${NJOB}_120
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
