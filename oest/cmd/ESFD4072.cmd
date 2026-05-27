#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Transformation REQ 20.1
# nom du script SHELL           : ESFD4072.cmd
# revision                      : $Revision:   1.0  $
# date de creation				: 17/01/2024
# auteur						: Mehdi NAJI
# references ds specifications	: 
#-----------------------------------------------------------------------------
# description
#       IFRS17 Accouting Update
#-----------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------
# historiques des modifications :
# [001] 07/06/2021 Linh DOAN : SPIRA 92996 GLT IFRS17- Missing field in TTECLEDA and TTECLEDR format
# [001] 07/06/2021 Linh DOAN : SPIRA 97737 REQ20.1 - Exclude Life contracts
# [003] 21/02/2022 MZM : SPIRA 102371 : I17 Filtrer les fichiers I17 Par Normes (Ajout jointures avec les fichiers Pericases)  
# [004] 25/04/2022 MZM : SPIRA 103892: : Remise des champs GT de 73 a 118  pour Assume et de 73 a 71 pour Retro
# [005] 06/05/2022 MZM : SPIRA 85522:  : ONEROUS : Filtre  a partir des PERICASE :  Annulation et deplacement dans ESFD4033 et ESFD4035
# [006] 21/06/2022 MZM : SPIRA 105171:  :Ajout des ANNULATIONS LIFE en sortie du ESFD4030
# [007] 08/08/2022 HR : SPIRA 105449: INI RTO Missing (RA View)
# [008] 29/08/2022 MZ : SPIRA 105449: INI RTO Missing (RA View) Retrait de la SUM au _95B
# [009] 12/09/2022 MZM : SPIRA 106718 IFRS 17 - Annulations Life manquantes MAJ du step _55A
# [010] 17/10/2022 MZM : SPIRA 107357 IFRS 17 - RTO- Do not update opening and cancelation (Ajout Step _95D)
# [011] 10/19/2022 JBD : SPIRA 105609 IO contract info -> Update CSUOE if NOT RI line (step 120/130)
# [012] 16/11/2022 MZM : SPIRA 107725 IFRS 17 P&C closing - Exclusion of all Life treaties
# [013] 14/02/2023 MZM : SPIRA 108737 INT - Missing Retrocessionaire in RR view for I17 transactions : Mise à jour EST_FPLATXCUMALL ==> EST_FPLATXCUM
# [014] 13/03/2023 MZM : SPIRA 108587 Mixed retro : AEs are wrong in RA view : Variabilisation du Fichier FPLATXCUM (ALL ou CUM) en entree du ESTC1052B 
# [015] 12/10/2023 MZM : SPIRA 110675   20.1 - I17 - REQ 20.1 - remove content of NEWCOLS5_NF on reclass transactions
# [016] 08/01/2024 MZM : SPIRA 111009   OPTIM   
# [017] 17/01/2024 M.NAJI: SPIRA 111009   OPTIM : get data de l'ancien ESFD4037 à mettre le plus hat dans VTOM et en //   
#======================================================================================================================

#set -x



# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

EST_BASE=`basename ${ESF_FTECLEDA_OUT%.*}`

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="SPLIT FTECLEDA ==> FTECLEDAA, FTECLEDAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NCHAIN}_ESFD4033_5ALL_${NORME_CF}_120_${IB}_${EST_BASE}_ALL.dat 2000 1"
SORT_I="${ESF_FTECLEDA_OUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDAA.dat "
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTECLEDAR.dat "
COND_REJ="(TRNCOD34_CF != '82' AND  TRNCOD34_CF != '83' AND  TRNCOD345_CF != '841' AND TRNCOD345_CF != '842' AND  TRNCOD34_CF != '85' AND TRNCOD345_CF != '110' AND TRNCOD345_CF != '111' AND TRNCOD345_CF != '907' )" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
	    TRNCOD1_CF  6:1 -  6:1,
        TRNCOD34_CF  6:3 -  6:4,
        TRNCOD345_CF  6:3 -  6:5
/KEYS CTR_NF,
       END_NT,

       SEC_NF,
       UWY_NF,
       UW_NT
/CONDITION COND_GTAR ( TRNCOD1_CF EQ "2"  OR TRNCOD1_CF EQ "4") AND ${COND_REJ}
/CONDITION COND_GTAA  ( TRNCOD1_CF != "2"  AND TRNCOD1_CF != "4")
/OUTFILE ${SORT_O}
/INCLUDE COND_GTAA
/OUTFILE ${SORT_O2}  
/INCLUDE COND_GTAR      
exit
EOF
SORT



NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="remove Life rows of FTECLEDAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_FTECLEDAA.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDAA.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS GT_CTR_NF        8:1 -  8:,
        GT_END_NT        9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_RETCTR_NF    24:1 - 24:,
        GT_RETEND_NT    25:1 - 25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS      1:1 - 118:,
        LIF_CTR_NF       2:1 - 2:,
        LIF_END_NT       3:1 - 3:,
        LIF_SEC_NF       4:1 - 4:,
        LIF_UWY_NF       5:1 - 5:,
        LIF_UW_NT        6:1 - 6:
/joinkeys
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT
/INFILE ${ESF_IADVPERICASE_LIFE_ASSUMED} 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT


NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="filter Life rows of FTECLEDAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_FTECLEDAA.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDAA_LIFE.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS GT_CTR_NF        8:1 -  8:,
        GT_END_NT        9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_RETCTR_NF    24:1 - 24:,
        GT_RETEND_NT    25:1 - 25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS      1:1 - 118:,
        LIF_CTR_NF       2:1 - 2:,
        LIF_END_NT       3:1 - 3:,
        LIF_SEC_NF       4:1 - 4:,
        LIF_UWY_NF       5:1 - 5:,
        LIF_UW_NT        6:1 - 6:
/joinkeys
        GT_CTR_NF ,
        GT_END_NT ,
        GT_SEC_NF ,
        GT_UWY_NF ,
        GT_UW_NT
/INFILE ${ESF_IADVPERICASE_LIFE_ASSUMED} 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/OUTFILE ${SORT_O}
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Generate Only Life Cancellables Assumes Contracts in TECLEDAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_FTECLEDAA_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDAA_LIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        GT_CTR_NF        8:1 -  8:,
        GT_END_NT        9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_RETCTR_NF    24:1 - 24:,
        GT_RETEND_NT    25:1 - 25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ANNUL_OPNG   114:1 - 114:,        
        GT_ALL_COLS      1:1 - 118:
/CONDITION ANNU_OPNG  (GT_ANNUL_OPNG = "A" or GT_ANNUL_OPNG = "O")
/OUTFILE ${SORT_O} overwrite
/INCLUDE ANNU_OPNG
exit
EOF
SORT


NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="filter life rows of FTECLEDAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_FTECLEDAR.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDAR_LIFE.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        GT_CTR_NF        8:1 -  8:,
        GT_END_NT        9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_RETCTR_NF    24:1 - 24:,
        GT_RETEND_NT    25:1 - 25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS      1:1 - 118:,
        LIF_CTR_NF       2:1 - 2:,
        LIF_END_NT       3:1 - 3:,
        LIF_SEC_NF       4:1 - 4:,
        LIF_UWY_NF       5:1 - 5:,
        LIF_UW_NT        6:1 - 6:
/joinkeys
        GT_RETCTR_NF ,
        GT_RETEND_NT ,
        GT_RETSEC_NF ,
        GT_RTY_NF ,
        GT_RETUW_NT
/INFILE ${ESF_IADVPERICASE_LIFE_RETRO} 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/OUTFILE ${SORT_O}
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT



NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="Generate Only  Cancellable Life Contracts in TECLEDAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_FTECLEDAR_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDAR_LIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        GT_CTR_NF        8:1 -  8:,
        GT_END_NT        9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_RETCTR_NF    24:1 - 24:,
        GT_RETEND_NT    25:1 - 25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ANNUL_OPNG   114:1 - 114:,        
        GT_ALL_COLS      1:1 - 118:
/CONDITION ANNU_OPNG  (GT_ANNUL_OPNG = "A" or GT_ANNUL_OPNG = "O")
/OUTFILE ${SORT_O} overwrite
/INCLUDE ANNU_OPNG
exit
EOF
SORT



NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="remove life rows of FTECLEDAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_FTECLEDAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDAR.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        GT_CTR_NF        8:1 -  8:,
        GT_END_NT        9:1 -  9:,
        GT_SEC_NF       10:1 - 10:,
        GT_UWY_NF       11:1 - 11:,
        GT_UW_NT        12:1 - 12:,
        GT_RETCTR_NF    24:1 - 24:,
        GT_RETEND_NT    25:1 - 25:,
        GT_RETSEC_NF    26:1 - 26:,
        GT_RTY_NF       27:1 - 27:,
        GT_RETUW_NT     28:1 - 28:,
        GT_ALL_COLS      1:1 - 118:,
        LIF_CTR_NF       2:1 - 2:,
        LIF_END_NT       3:1 - 3:,
        LIF_SEC_NF       4:1 - 4:,
        LIF_UWY_NF       5:1 - 5:,
        LIF_UW_NT        6:1 - 6:
/joinkeys
        GT_RETCTR_NF ,
        GT_RETEND_NT ,
        GT_RETSEC_NF ,
        GT_RTY_NF ,
        GT_RETUW_NT
/INFILE ${ESF_IADVPERICASE_LIFE_RETRO} 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O}
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT



NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="Extend FTECLEDAR with CLI_NF"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_FTECLEDAR.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDAR_CLI.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    FTTECLEDAR_RTO_NF  37:1 - 37:,
    FTTECLEDAR_ALL     1:1 - 118:,
    CLI_NF      1:1 - 1: 
/joinkeys
    FTTECLEDAR_RTO_NF 
/INFILE ${ESF_CLIEN_TXT} 2000 1 "~"
/joinkeys
    CLI_NF
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}
/REFORMAT
    leftside :FTTECLEDAR_ALL,rightside:CLI_NF
exit
EOF
SORT



JOBEND
