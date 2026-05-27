#!/bin/ksh
#=============================================================================
# nom de l'application          : Reinsurance Analytics
# nom du script SHELL           : ESID2045.cmd
# revision                      : $Revision: 1.10 $
# date de creation              : 18/07/2016
# auteur                        : MMA
# SPOT                          : 30985
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#   Rassurance Analitique - RA impact Inventaire
#       Creation de fichiers Pour RA :
#           Split des fichiers SRGTE & SRGTEF en partie allant dans le GLT ou dans SRV
#
# Input files
#       EST_DLVGTAR              DFILP
#       EST_DLVGTAR              DFILP
#       EST_SRGTE          DFILI
#       EST_SRGTEF         DFILI
#
#  Output file
#       EST_SRGTE_SRV_PA         DFILI
#       EST_SRGTE_SRV_PA         DFILI
#       EST_SRGTEF_SRV_PC        DFILI
#       EST_SRGTEF_SRV_PC        DFILI
#
#
#   Job launched by ESID2040.cmd
#
#-----------------------------------------------------------------------------
# historique des modifications :
# <[n°]>  <jj/mm/aaaa>   <auteur>  <SPOT/SPIRA>  <description de la modification>
#[001] 13/01/2016 spira #57931 R. cassis Refonte du shell
#[002] 13/01/2016 spira #59564 R. cassis Prog STAM1225 remplacé par STAM1226 - modofication du awk step 130
#[003] 06/05/2019  SBE :spira:70044  Evolution quarterly
#[004] 17/02/2022  SBE :spira:98141  IFRS17 FWH Bookings
#[005] 25/05/2022  SBE :spira:104651: IFRS 17 - FWH - Don't generate on specific TC FWH
#[006] 05/01/2023  SBE :spira:108254: IFRS17 FWH : Si annulation ( mêmes données en tout point identiques), la ligne n'est pas dans RA
#[007] 12/01/2023  SBE :spira:108251: IFRS17 FWH : Exclure du traitement accrual FWH I17 certains TC flaggés "Dépots" dans RFR
#[008] 10/02/2023  SBE :spira:108254: IFRS17 FWH : Si annulation ( mêmes données en tout point identiques), la ligne n'est pas dans RA
#[009] 29/03/2024  SBE :spira:108250: IFRS17 FWH : Exclure les traités non IFRS17 ( IAS39, Rattachement, ...)
#==============================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CLODAT_D=$3
CRE_D=$4
MTHCNA_NF=$5
MODE=$6
LIF_ACY_MAX=4
LIF_ACY_MIN=4

# Job Initialisation
JOBINIT

#Surcharge mapping
. ${DCMD}/ESFD9001_MAPPING.cmd

if [ ${MODE} == "PA" ]
then
    SRGTE_SRV_FIC=${EST_SRGTE_SRV_PA}
    SRGTEF_SRV_FIC=${EST_SRGTEF_SRV_PA}
    EST_SRGTE=${EST_SRGTE_PA}
    EST_SRGTEF=${EST_SRGTEF_PA}
    #EST_DLVGTAA=`ls -rt ${DFILP}/*_ESID2040_DLVGTAA_PC${IT}_*${CRE_D}.dat`  # pour prendre le AAAAMMJJ courant et non ..1231
    #EST_DLVGTAR=`ls -rt ${DFILP}/*_ESID2040_DLVGTAR_PC${IT}_*${CRE_D}.dat`  # pour prendre le AAAAMMJJ courant et non ..1231
    EST_DLVGTAA=${EST_DLVGTAA_PC}
    EST_DLVGTAR=${EST_DLVGTAR_PC}
else
    SRGTE_SRV_FIC=${EST_SRGTE_SRV_PC}
    SRGTEF_SRV_FIC=${EST_SRGTEF_SRV_PC}
    EST_SRGTE=${EST_SRGTE_PC}
    EST_SRGTEF=${EST_SRGTEF_PC}
    EST_DLVGTAA=${EST_DLVGTAA_PC}
    EST_DLVGTAR=${EST_DLVGTAR_PC}
fi

ECHO_LOG ""
ECHO_LOG "#===============================    ${MODE}      =============================="
ECHO_LOG "#===============================    PARAMETRES   =============================="
ECHO_LOG "#===> BALSHTYEA_NF.......: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF.......: ${BALSHTMTH_NF}"
ECHO_LOG "#===> ICLODAT_D..........: ${CLODAT_D}"
ECHO_LOG "#===> CRE_D..............: ${CRE_D}"
ECHO_LOG "#===> MTHCNA_NF..........: ${MTHCNA_NF}"
ECHO_LOG "#===============================    IMPUT FILES   =============================="
ECHO_LOG "#===> EST_SRGTEF ...........: ${EST_SRGTEF}"
ECHO_LOG "#===> EST_SRGTE ............: ${EST_SRGTE}"
ECHO_LOG "#===> EST_DLVGTAA ..........: ${EST_DLVGTAA}"
ECHO_LOG "#===> EST_DLVGTAR ..........: ${EST_DLVGTAR}"
ECHO_LOG "#===> EST_FVPLACEMT ........: ${EST_FVPLACEMT}"
ECHO_LOG "#=============================  OUTPUT FILES    ================================"
ECHO_LOG "#===> EST_SRGTE_SRV_PA.........: ${EST_SRGTE_SRV_PA}"
ECHO_LOG "#===> EST_SRGTEF_SRV_PA..........: ${EST_SRGTEF_SRV_PA}"
ECHO_LOG "#===> EST_SRGTE_SRV_PC........: ${EST_SRGTE_SRV_PC}"
ECHO_LOG "#===> EST_SRGTEF_SRV_PC........: ${EST_SRGTEF_SRV_PC}"
ECHO_LOG "#=============================================================================="
ECHO_LOG ""

NSTEP=${NJOB}_010
# SORT of FVPLACEMT
#----------------------------------------------------------------------------
LIBEL="SORT of FVPLACEMT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#set -x
SORT_I="${EST_FVPLACEMT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FVPLACEMT_O.dat 1000 1"
#set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  RCTR_NF     3:1 - 3:,
        RSEC_NF     5:1 - 5: EN,
        RTY_NF      6:1 - 6: EN
/KEYS RCTR_NF,RSEC_NF,RTY_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[002]
NSTEP=${NJOB}_015
# SORT of FVPLACEMT
#----------------------------------------------------------------------------
LIBEL="SORT of FVPLACEMT for CTR/UWY only"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#set -x
SORT_I="${EST_FVPLACEMT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FVPLACEMTUWY_O.dat 1000 1"
#set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  RCTR_NF     3:1 - 3:,
        RTY_NF      6:1 - 6: EN
/KEYS RCTR_NF,RTY_NF
/SUM
/OUTFILE ${SORT_O}
/REFORMAT RCTR_NF,RTY_NF
exit
EOF
SORT

NSTEP=${NJOB}_020
#----------------------------------------------------------------------------
LIBEL="Transfert du montant du fichier SRGTE et SRGTEF pour RA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#set -x
SORT_I="${EST_SRGTE} 1000 1"
SORT_I2="${EST_SRGTEF} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTE.dat 1000 1"
#set +x
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        TRNCOD2_CF       6:3 -  6:4,
        TRNCOD3_CF       6:3 -  6:8,
        TRNCOD8_CF       6:8 -  6:8,
        AMT_M           19:1 - 19:EN 15/3,
        ESTAMT_M        43:1 - 43:EN 15/3,
        SRGTE_1          1:1 - 18:,
        SRGTE_2         20:1 - 70:
/CONDITION SRGTE ((TRNCOD2_CF = "81" AND TRNCOD8_CF = "2") OR TRNCOD3_CF = "43200A" OR TRNCOD3_CF = "43300A" OR 
                  TRNCOD3_CF = "43500A" OR TRNCOD3_CF = "43600A" OR TRNCOD3_CF = "43800A" OR TRNCOD3_CF = "43900A")
/DERIVEDFIELD AMT2_M if SRGTE then ESTAMT_M else AMT_M
/OUTFILE ${SORT_O}
/REFORMAT SRGTE_1, AMT2_M, SRGTE_2
exit
EOF
SORT

#gzip -c ${DFILT}/${NJOB}_020_${IB}_SORT_SRGTE.dat > ${DFILT}/${NJOB}_020_SORT_SRGTE.dat.gz

if [ ${MODE} == "PA" ]
then
	NSTEP=${NJOB}_030
	# Generate cancellations 
	#-----------------------------------------------------------------------------
	LIBEL="Update CLODAT_D to blcshtd"
	AWK_I=${DFILT}/${NJOB}_020_${IB}_SORT_SRGTE.dat
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_SRGTE.dat
	AWK_PARAM=" -v clodat=${CLODAT_D}"
	AWK_CMD=`CFTMP`
	INPUT_TEXT ${AWK_CMD} <<EOF
	BEGIN{ FS="\~"; OFS="\~" }
	{
		if (\$4 == 12 && \$5 == 31)
		{
			\$4 = substr(clodat,5,2)
			\$5 = substr(clodat,7,2)
			print \$0
		}
	}
	exit
EOF
	AWK
else
	NSTEP=${NJOB}_120
	#----------------------------------------------------------------------------
	LIBEL="Touch sur ${SRGTEF_SRV_FIC}"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILT}/${NJOB}_020_${IB}_SORT_SRGTE.dat ${DFILT}/${NJOB}_030_${IB}_AWK_SRGTE.dat"
fi

NSTEP=${NJOB}_040
#------------------------------------------------------------------------------
LIBEL="Putting Complements into TL format"
PRG=ESTC2142
export ${PRG}_I1=${EST_DLVGTAR}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_NULL_FIC.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DVGTAR_O2.dat
EXECPRG

NSTEP=${NJOB}_050
#------------------------------------------------------------------------------
LIBEL="Tri descendant sur bilan et ajout 30 colonnes"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_040_${IB}_ESTC2142_DVGTAR_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_I_DVGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        ESB_CF           2:1 -  2:EN,
        BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        BALSHRDAY_NF     5:1 -  5:EN,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        CED_NF          20:1 - 20:,
        BRK_NF          21:1 - 21:,
        PAY_NF          22:1 - 22:,
        KEY_NF          23:1 - 23:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        INT_NF          38:1 - 38:,
        RETPAY_NF       39:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        GTAR_FULL        1:1 - 41:
/KEYS CTR_NF,
    SEC_NF,
    UWY_NF,
    ACY_NF,
    TRNCOD_CF,
    END_NT,
    UW_NT,
    BALSHEY_NF DESCENDING,
    BALSHRMTH_NF DESCENDING,
    RETCTR_NF,
    RETSEC_NF,
    RETEND_NT,
    RETUW_NT,
    RETACY_NF
/DERIVEDFIELD AJOUT_30_COLS 29"~"
/OUTFILE ${SORT_O}
/REFORMAT GTAR_FULL, AJOUT_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_060
#------------------------------------------------------------------------------
LIBEL="Tri et ajout de l'inverse de Montant"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLVGTAA} 1000 1"
SORT_I2="${DFILT}/${NJOB}_050_${IB}_SORT_I_DVGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MSI_DLVGTA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        ESB_CF           2:1 -  2:EN,
        BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        BALSHRDAY_NF     5:1 -  5:EN,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        CED_NF          20:1 - 20:,
        BRK_NF          21:1 - 21:,
        PAY_NF          22:1 - 22:,
        KEY_NF          23:1 - 23:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        INT_NF          38:1 - 38:,
        RETPAY_NF       39:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        ACMTRS_NT       45:1 - 45:,
        GTAA_FULL1       1:1 - 18:,
        GTAA_FULL2      20:1 - 44:,
        GTAA_FULL3      46:1 - 70:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      TRNCOD_CF,
      END_NT,
      UW_NT,
      BALSHEY_NF DESCENDING,
      BALSHRMTH_NF DESCENDING,
      RETCTR_NF,
      RETSEC_NF,
      RETEND_NT,
      RETUW_NT,
      RETACY_NF,
      ESTAMT_M ,
      ACMTRS_NT
/DERIVEDFIELD D_ACMTRS_NT "0000"
/DERIVEDFIELD AMT_MC2 -AMT_M EN 20 15/3
/DERIVEDFIELD separateur "~"
/OUTFILE ${SORT_O}
/REFORMAT GTAA_FULL1, AMT_MC2, separateur, GTAA_FULL2, D_ACMTRS_NT, separateur, GTAA_FULL3
exit
EOF
SORT

#gzip -c ${DFILT}/${NJOB}_060_${IB}_MSI_DLVGTA_O.dat > ${DFILT}/${NJOB}_060_MSI_DLVGTA_O.dat.gz

NSTEP=${NJOB}_070
#------------------------------------------------------------------------------
LIBEL="Trie Descendant SRGTE et DLVGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_030_${IB}_AWK_SRGTE.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_060_${IB}_MSI_DLVGTA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SRGTE_SRV.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        ESB_CF           2:1 -  2:EN,
        BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        BALSHRDAY_NF     5:1 -  5:EN,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        CED_NF          20:1 - 20:,
        BRK_NF          21:1 - 21:,
        PAY_NF          22:1 - 22:,
        KEY_NF          23:1 - 23:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        INT_NF          38:1 - 38:,
        RETPAY_NF       39:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        ACMTRS_NT       45:1 - 45:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      ACY_NF,
      CUR_CF,
      ACMTRS_NT DESCENDING
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_080
# Generate cancellations 
#-----------------------------------------------------------------------------
LIBEL="Update mandatory values into SRGTE file ORICOD, ACCRET and GAAP"
AWK_I=${DFILT}/${NJOB}_070_${IB}_SRGTE_SRV.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_SRGTE_SRV.dat
AWK_PARAM=" -v cle1sav=x"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
	cle1 = \$1 \$2 \$6 \$8 \$9 \$10 \$11 \$12 \$14 \$18
	if (\$45 != "")	
	{
		cle2 = ""
		for (i=42; i<71; i++) cle2 = cle2 "~" \$i;
	}
	if (cle1sav == cle1)
	{
		if (\$45 == "")
		{
			s0 = ""
			for (i=1; i<42; i++) s0 = s0 "~" \$i;
			s1 = substr(s0,2)
			\$0 = s1 cle2
			\$43 = "0"
			print \$0
			next
		}
	}
	else 
	{
		cle1sav = cle1
	}
	print \$0
}
exit
EOF
AWK

#gzip -c ${DFILT}/${NJOB}_070_${IB}_SRGTE_SRV.dat > ${DFILT}/${NJOB}_070_SRGTE_SRV.dat.gz
#gzip -c ${DFILT}/${NJOB}_080_${IB}_AWK_SRGTE_SRV.dat > ${DFILT}/${NJOB}_080_AWK_SRGTE_SRV.dat.gz

NSTEP=${NJOB}_090
#----------------------------------------------------------------------------------------------------------
LIBEL="Somme du SRGTE et et du DLVGTA pour creer le fichier SRV a destination de RA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#set -x
SORT_I="${DFILT}/${NJOB}_080_${IB}_AWK_SRGTE_SRV.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SRGTE_SRV.dat 1000 1"
#set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        ESB_CF           2:1 -  2:EN,
        BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        BALSHRDAY_NF     5:1 -  5:EN,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        CED_NF          20:1 - 20:,
        BRK_NF          21:1 - 21:,
        PAY_NF          22:1 - 22:,
        KEY_NF          23:1 - 23:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        INT_NF          38:1 - 38:,
        RETPAY_NF       39:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        ACMTRS_NT       45:1 - 45:EN,
        SRGTE_SRV1       1:1 - 18:,
        SRGTE_SRV2      20:1 - 70:
/KEYS   CTR_NF         ,
        END_NT         ,
        SEC_NF         ,
        UWY_NF         ,
        UW_NT          ,
        SSD_CF         ,        
        ESB_CF         ,
        BALSHEY_NF     ,
        BALSHRMTH_NF   ,
        BALSHRDAY_NF   ,
        TRNCOD_CF      ,
        DBLTRNCOD_CF   ,
        OCCYEA_NF      ,
        ACY_NF         ,
        SCOSTRMTH_NF   ,
        SCOENDMTH_NF   ,
        CLM_NF         ,
        CUR_CF         ,
        CED_NF         ,
        BRK_NF         ,
        PAY_NF         ,
        KEY_NF         ,
        RETCTR_NF      ,
        RETEND_NT      ,
        RETSEC_NF      ,
        RTY_NF         ,
        RETUW_NT       ,
        RETOCCYEA_NF   ,
        RETACY_NF      ,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF         
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M EN 20 15/3 COMPRESS
/DERIVEDFIELD separateur "~"
/CONDITION COND_SRV AMT_M != 0.000
/OUTFILE ${SORT_O}
/INCLUDE COND_SRV
/REFORMAT SRGTE_SRV1, AMT_MC, separateur, SRGTE_SRV2
exit
EOF
SORT

#gzip -c ${DFILT}/${NJOB}_090_${IB}_SRGTE_SRV.dat > ${DFILT}/${NJOB}_090_SRGTE_SRV.dat.gz

NSTEP=${NJOB}_100
#  Estimate acceptation and cession data separation
#----------------------------------------------------------------------------
LIBEL="Estimate acceptation and cession data separation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#set -x
SORT_I="${DFILT}/${NJOB}_090_${IB}_SRGTE_SRV.dat"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SRGTER_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_SRGTEA_O2.dat
#set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  TRNCOD1_CF    6:1 - 6:1,
        CTR_NF        8:1 - 8:,
        UWY_NF       11:1 - 11: EN,
        SEC_NF       10:1 - 10: EN,
        ACY_NF       14:1 - 14: EN
/KEYS CTR_NF,SEC_NF,UWY_NF, ACY_NF
/CONDITION ACCEPT_ACY ((TRNCOD1_CF = '1' OR TRNCOD1_CF = '3') AND (ACY_NF <= ${BALSHTYEA_NF}))
/CONDITION RETRO_ACY ((TRNCOD1_CF = '2' OR TRNCOD1_CF = '4') AND (ACY_NF <= ${BALSHTYEA_NF}))
/OUTFILE ${SORT_O}
/INCLUDE RETRO_ACY
/OUTFILE ${SORT_O2}
/INCLUDE ACCEPT_ACY
exit
EOF
SORT

#[002]
NSTEP=${NJOB}_110
# Ventilation par placement de EST_SRGTE
#------------------------------------------------------------------------------
LIBEL="Amount by retrocessionnaire"
PRG="STAM1226"
#set -x
export ${PRG}_I1=${DFILT}/${NJOB}_010_${IB}_SORT_FVPLACEMT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_SORT_SRGTER_O1.dat
export ${PRG}_I3=${DFILT}/${NJOB}_015_${IB}_SORT_FVPLACEMTUWY_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTER_VENTIL.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTER_REJET_O1.log
#set +x
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
# cd $DEXE
# #Pour lancer DBX
# debugV2 ${PRG}
EXECPRG

#gzip -c ${DFILT}/${NJOB}_010_${IB}_SORT_FVPLACEMT_O.dat > ${DFILT}/${NJOB}_010_SORT_FVPLACEMT_O.dat.gz
#gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_SRGTER_O1.dat   > ${DFILT}/${NJOB}_100_SORT_SRGTER_O1.dat.gz
#gzip -c ${DFILT}/${NJOB}_110_${IB}_STAM1226_SRGTER_VENTIL.dat    > ${DFILT}/${NJOB}_110_STAM1226_SRGTER_VENTIL.dat.gz

NSTEP=${NJOB}_120
#  Merge estimate acceptation and cession data
#----------------------------------------------------------------------------
LIBEL="Regroupement des données ESTIMATION acceptation et retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#set -x
SORT_I="${DFILT}/${NJOB}_100_${IB}_SORT_SRGTEA_O2.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_110_${IB}_STAM1226_SRGTER_VENTIL.dat 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SRGTE_VENTIL.dat 500 1"
#set +x
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  CTR_NF        8:1 -  8:,
        AMT_M        19:1 - 19:EN 15/3,
        UWY_NF       11:1 - 11: EN,
        SEC_NF       10:1 - 10: EN,
        ACY_NF       14:1 - 14: EN
/KEYS CTR_NF,SEC_NF,UWY_NF, ACY_NF
/CONDITION mt (AMT_M LT 0.1 AND AMT_M GT -0.1)
/OUTFILE ${SORT_O}
/OMIT mt
exit
EOF
SORT

#[002]
NSTEP=${NJOB}_130
# Generate cancellations 
#-----------------------------------------------------------------------------
LIBEL="Update mandatory values into SRGTE file ORICOD, ACCRET and GAAP"
AWK_I=${DFILT}/${NJOB}_120_${IB}_SRGTE_VENTIL.dat
AWK_O=${SRGTE_SRV_FIC}
#AWK_O=${EST_SRGTE_SRV}
AWK_PARAM=" -v mode=${MODE}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
	\$58 = mode
	if (substr(\$6,1,1) == "2" || substr(\$6,1,1) == "4")
	{
		if (mode == "PC" && substr(\$45,4,1) == "4" ) next
		\$60 = "R" 
		if (mode == "PA" && substr(\$45,4,1) == "4" ) \$58 = "PAPC"
		if (substr(\$6,3,3) == "433" && substr(\$45,4,1) == "4") \$6 = substr(\$6,1,4) "5" substr(\$6,6,3)
	}
	else	{ \$60 = "A" }
	\$65 = "1"
	# update GAAP
	if (substr(\$6,8,1) == "A" || substr(\$6,8,1) == "B") { \$65 = "2" }
	if (substr(\$6,8,1) == "C" || substr(\$6,8,1) == "D") { \$65 = "3" }
	if (substr(\$6,8,1) == "E" || substr(\$6,8,1) == "F") { \$65 = "4" }
	if (substr(\$6,8,1) == "G" || substr(\$6,8,1) == "H") { \$65 = "5" }
	\$45 = ""		
	print \$0
}
exit
EOF
AWK

if [ ${MODE} == "PC" ]
then
  NSTEP=${NJOB}_133
  #------------------------------------------------------------------------------
  LIBEL="Spira 108250 - Filter on ASSFINANCE_CT"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_IARVPERICASE4} 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_IARVPERICASE4_FILTERED_${IT}.dat"
  INPUT_TEXT ${SORT_CMD} <<EOF
  /FIELDS 
     ASSFINANCE_CT 167:1 - 167:,
     CTR_NF        3:1 - 3:,
     SEC_NF        5:1 - 5:,
     UWY_NF        6:1 - 6:
  /KEYS CTR_NF,
        SEC_NF,
        UWY_NF
/CONDITION ASSFINANCE ( ASSFINANCE_CT = "2" )
/OMIT ASSFINANCE
/OUTFILE ${SORT_O}
exit
EOF
SORT

  NSTEP=${NJOB}_134
  #----------------------------------------------------------------------------
  LIBEL="Spira 108250 - Filter on ASSFINANCE_CT"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${SRGTE_SRV_FIC} 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SRGTE_SRV_FIC_FILTERED_${IT}.dat"
  INPUT_TEXT ${SORT_CMD} << EOF
  /FIELDS
     CTR1_NF        8:1 -  8:,
     SEC1_NF       10:1 - 10:,
     UWY1_NF       11:1 - 11:,
     CTR2_NF        3:1 - 3:,
     SEC2_NF        5:1 - 5:,
     UWY2_NF        6:1 - 6:,
     FIELD_1_70_F1  1:1 - 70:
  /JOINKEYS
        CTR1_NF, SEC1_NF, UWY1_NF
  /INFILE ${DFILT}/${NJOB}_133_${IB}_IARVPERICASE4_FILTERED_${IT}.dat 1000 1 "~"
  /JOINKEYS
        CTR2_NF, SEC2_NF, UWY2_NF
  /OUTFILE ${SORT_O} OVERWRITE
  /REFORMAT LEFTSIDE:FIELD_1_70_F1
  exit
EOF
  SORT

	NSTEP=${NJOB}_135
 	#Generation of EST_FUNDWITHHELD_I17X files
	#------------------------------------------------------------------------------
	LIBEL="Generation of EST_FUNDWITHHELD_I17X files"
	PRG="ESTC2160"
	FPRM=`CFTMP`
	INPUT_TEXT ${FPRM} << EOF
	BALSHTMTH_NF ${MTHCNA_NF}
	exit
EOF
	export ${PRG}_PRM=${FPRM}
	export ${PRG}_I1=${DFILT}/${NJOB}_134_${IB}_SRGTE_SRV_FIC_FILTERED_${IT}.dat
	export ${PRG}_I2=${EST_SUBTRS}
	export ${PRG}_I3=${EST_SUBTRSBLOCKLIFEST}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FWHI17G_O1.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FWHI17P_O2.dat
  export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FWHI17L_O3.dat
	EXECPRG
    

NSTEP=${NJOB}_140
#------------------------------------------------------------------------------------
LIBEL="Exclude poste I17G"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_135_${IB}_${PRG}_FWHI17G_O1.dat 2000 1"
SORT_O="${EST_FUNDWITHHELD_I17G_PC} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
                CTR_NF            6:1 -   6:,
                CTR2_NF           3:1 -   3:,
                FIELD_1_70_F1     1:1 -  70:
/JOINKEYS
        CTR_NF
/INFILE ${EST_FTRSLNK_TXT} 2000 1 "~"
/JOINKEYS
        CTR2_NF
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:FIELD_1_70_F1
exit
EOF
SORT

NSTEP=${NJOB}_150
#------------------------------------------------------------------------------------
LIBEL="Exclude poste I17P"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_135_${IB}_${PRG}_FWHI17P_O2.dat 2000 1"
SORT_O="${EST_FUNDWITHHELD_I17P_PC} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
                CTR_NF            6:1 -   6:,
                CTR2_NF           3:1 -   3:,
                FIELD_1_70_F1     1:1 -  70:
/JOINKEYS
        CTR_NF
/INFILE ${EST_FTRSLNK_TXT} 2000 1 "~"
/JOINKEYS
        CTR2_NF
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:FIELD_1_70_F1
exit
EOF
SORT

NSTEP=${NJOB}_160
#------------------------------------------------------------------------------------
LIBEL="Exclude poste I17L"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_135_${IB}_${PRG}_FWHI17L_O3.dat 2000 1"
SORT_O="${EST_FUNDWITHHELD_I17L_PC} 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
                CTR_NF            6:1 -   6:,
                CTR2_NF           3:1 -   3:,
                FIELD_1_70_F1     1:1 -  70:
/JOINKEYS
        CTR_NF
/INFILE ${EST_FTRSLNK_TXT} 2000 1 "~"
/JOINKEYS
        CTR2_NF
/OUTFILE ${SORT_O} OVERWRITE
/REFORMAT LEFTSIDE:FIELD_1_70_F1
exit
EOF
SORT

fi

NSTEP=${NJOB}_200
#----------------------------------------------------------------------------
LIBEL="Touch sur ${EST_SRGTEF_SRV}"
EXECKSH_MODE=P
EXECKSH "touch ${SRGTEF_SRV_FIC}"
#EXECKSH "touch ${EST_SRGTEF_SRV}"


echo " "
echo " "
echo "############  VERIFICATION GENERALE SRGTE-EF  ##########"
echo "====> VOLUMETRIE SERGTE-EF"
wc ${EST_SRGTE} ${EST_SRGTEF}
echo "-------------------------------------------------"
wc ${EST_SRGTE_SRV} ${EST_SRGTEF_SRV}
echo "-------------------------------------------------"
echo "######################################################"
echo " "
echo "+"


NSTEP=${NJOB}_300
# Suppression des fichiers Temporaires
#------------------------------------------------------------------------------
LIBEL="Delete temporary files"
RMFIL "${DFILT}/${NJOB}*_*.dat"

JOBEND
