#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#				  Format IFRS17 Accounting	
# nom du script SHELL		: ESFD4037.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 07/06/2021
# auteur			: Linh DOAN
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
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Job Initialisation
JOBINIT

EST_FTECLEDA=${1}
EST_FTECLEDR=${2}

#[012]
NSTEP=${NJOB}_01
#-----------------------------------------------------------------------------
LIBEL="Collecting Life Assumed"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${DFILT}/${NSTEP}_${IB}_PERICASE_LIFE_ASSUMED.dat"
BCP_QRY="select distinct s.SSD_CF, s.CTR_NF,s.END_NT, s.SEC_NF, s.UWY_NF, s.UW_NT  ,c.CTRSTS_CT , s.LOB_CF from BTRT..TSECTION s, BTRT..TCONTR c, bref..tbatchssd z where s.CTR_NF = c.CTR_NF and s.UWY_NF = c.UWY_NF and s.LOB_CF in ('30','31') and s.SSD_CF = z.SSD_CF and z.batchuser_cf= suser_name()
union
select distinct s.SSD_CF, s.CTR_NF,s.END_NT, s.SEC_NF, s.UWY_NF, s.UW_NT  ,c.CTRSTS_CT , s.LOB_CF from BFAC..TSECTION s, BFAC..TCONTR c, bref..tbatchssd z where s.CTR_NF = c.CTR_NF and s.UWY_NF = c.UWY_NF and s.LOB_CF in ('30','31') and s.SSD_CF = z.SSD_CF and z.batchuser_cf= suser_name()"
BCP

NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Collecting Life retro contracts"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${DFILT}/${NSTEP}_${IB}_PERICASE_LIFE_RETRO.dat"
BCP_QRY="select distinct s.SSD_CF, s.RETCTR_NF,0 as RETEND_NT, s.RETSEC_NF, s.RTY_NF, 1 as RETUW_NT,c.RETCTRSTS_CT , s.LOB_CF from BRET..TRETSEC s, BRET..TRETCTR c, bref..tbatchssd z where s.RETCTR_NF = c.RETCTR_NF and s.RTY_NF = c.RTY_NF and s.LOB_CF in ('30','31') and s.SSD_CF = z.SSD_CF and z.batchuser_cf= suser_name()"
BCP



NSTEP=${NJOB}_10
#ESF_FCTRGRO0 screen
#-----------------------------------------------------------------------------
LIBEL="ESF_FCTRGRO0 ==> ESF_FCTRGRO ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCTRGRO0} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FCTRGRO.dat 2000 1 OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 5:1 - 5: EN, 
        CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF    21:1 - 21:,
       	SEGTYP_CT 6:1 - 6:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Merge of OADVPERICASE and IADVPERICASE Files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_IADVPERICASE.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT
exit
EOF
SORT

## [005] MERGE PERICASE I17_INI et I17_STD



NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="Merge of ORDVPERICASE0 and IRDVPERICASE0 Files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IRDVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_IRDVPERICASE.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
  SORT




NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Files generation in TTECLEDA table format"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDAA.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDAR.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
	TRNCOD1_CF  6:1 -  6:1
/KEYS CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT
/CONDITION COND_GTAR ( TRNCOD1_CF EQ "2"  OR TRNCOD1_CF EQ "4")
/OUTFILE ${SORT_O}
/OMIT COND_GTAR
/OUTFILE ${SORT_O2}       	
/INCLUDE COND_GTAR
exit
EOF
SORT


NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Remove Life Contracts in TECLEDAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_O_FTECLEDAA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDAA.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
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
/INFILE ${DFILT}/${NJOB}_01_${IB}_PERICASE_LIFE_ASSUMED.dat 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT


NSTEP=${NJOB}_35A
#-----------------------------------------------------------------------------
LIBEL="Generate Only Life Contracts in TECLEDAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_O_FTECLEDAA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDAA_LIFE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
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
/INFILE ${DFILT}/${NJOB}_01_${IB}_PERICASE_LIFE_ASSUMED.dat 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

NSTEP=${NJOB}_37A
#-----------------------------------------------------------------------------
LIBEL="Generate Only Life Cancellables Assumes Contracts in TECLEDAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35A_${IB}_SORT_O_FTECLEDAA_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDAA_LIFE.dat 2000 1"
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


NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="Remove Life Contracts in TECLEDAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_O_FTECLEDAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDAR.dat 2000 1"
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
/INFILE ${DFILT}/${NJOB}_05_${IB}_PERICASE_LIFE_RETRO.dat 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

#[009]/JOIN UNPAIRED RIGHTSIDE ONLY

NSTEP=${NJOB}_40A
#-----------------------------------------------------------------------------
LIBEL="Generate Only  Cancellable Life Contracts in TECLEDAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_O_FTECLEDAR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDAR_LIFE.dat 2000 1"
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
/INFILE ${DFILT}/${NJOB}_05_${IB}_PERICASE_LIFE_RETRO.dat 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT



NSTEP=${NJOB}_45A
#-----------------------------------------------------------------------------
LIBEL="Generate Only  Cancellable Life Contracts in TECLEDAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40A_${IB}_SORT_O_FTECLEDAR_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDAR_LIFE.dat 2000 1"
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


##------------------------

NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledger to format TTCLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDR} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDR.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        TRNCOD1_CF       6:1 -  6:1,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        LIGNEGT          1:1 - 39: ,
        RETKEY_CF       40:1 - 40:,
        FILLER_16_COLS  56:1 - 71:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_55
#-----------------------------------------------------------------------------
LIBEL="Remove Life Contracts in TECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_O_FTECLEDR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDR.dat 2000 1"
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
        GT_ALL_COLS      1:1 - 71:,
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
/INFILE ${DFILT}/${NJOB}_05_${IB}_PERICASE_LIFE_RETRO.dat 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT

## [006] [009] /JOIN UNPAIRED RIGHTSIDE ONLY

NSTEP=${NJOB}_55A
#-----------------------------------------------------------------------------
LIBEL="Generate only Life Contracts in TECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_O_FTECLEDR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDR_LIFE.dat 2000 1"
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
        GT_ALL_COLS      1:1 - 71:,
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
/INFILE ${DFILT}/${NJOB}_05_${IB}_PERICASE_LIFE_RETRO.dat 2000 1 "~"
/joinkeys
        LIF_CTR_NF ,
        LIF_END_NT ,
        LIF_SEC_NF ,
        LIF_UWY_NF ,
        LIF_UW_NT
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside :GT_ALL_COLS
exit
EOF
SORT



NSTEP=${NJOB}_58A
#-----------------------------------------------------------------------------
LIBEL="Generate Only  Cancellable Life Contracts in TECLEDR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55A_${IB}_SORT_O_FTECLEDR_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_O_FTECLEDR_LIFE.dat 2000 1"
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
				ORICOD_LS       57:1 - 57:,	        
        GT_ANNUL_OPNG   67:1 - 67:,        
        GT_ALL_COLS      1:1 - 71:,
        FILLER_1_66      1:1 - 66:,
        FILLER_68_71     68:1 - 71:                      
/CONDITION ANNU_OPNG  (GT_ANNUL_OPNG = "A" or GT_ANNUL_OPNG = "O")
/OUTFILE ${SORT_O} overwrite
/INCLUDE ANNU_OPNG
exit
EOF
SORT


NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
# File generation in TTECLEDA table format
#-----------------------------------------------------------------------------
LIBEL="Files generation in TTECLEDA table format"
PRG=ESTC8801
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_O_IADVPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_35_${IB}_SORT_O_FTECLEDAA.dat
export ${PRG}_I3=${DFILT}/${NJOB}_10_${IB}_SORT_O_FCTRGRO.dat
export ${PRG}_I4=${ESF_FCPLACC}
export ${PRG}_I5=${DFILT}/${NJOB}_40_${IB}_SORT_O_FTECLEDAR.dat
export ${PRG}_I6=${ESF_FSOBBLOB}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SORT_FTECLEDA_01.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_SORT_FTECLEDAR_02.dat
EXECPRG


NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESTC8801_SORT_FTECLEDAR_02.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDAR_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25:,
        RETSEC_NF   26:1 - 26:,
        RTY_NF      27:1 - 27:,
        RETUW_NT    28:1 - 28:,
	LOBRET_CF   46:1 - 46:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION VIE ( LOBRET_CF="30" OR LOBRET_CF="31")
/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
exit
EOF
SORT



NSTEP=${NJOB}_75
#------------------------------------------------------------------------------
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESTC8801_SORT_FTECLEDA_01.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25:,
        RETSEC_NF   26:1 - 26:,
        RTY_NF      27:1 - 27:,
        RETUW_NT    28:1 - 28:,
        LOBACC_CF   45:1 - 45:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION VIE ( LOBACC_CF="30" OR LOBACC_CF="31")
/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
exit
EOF
SORT


NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
# File generation in TTECLEDR and TTECLEDA tables format
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8802
export ${PRG}_I1=${DFILT}/${NJOB}_25_${IB}_SORT_O_IRDVPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_70_${IB}_SORT_FTECLEDAR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_55_${IB}_SORT_O_FTECLEDR.dat
export ${PRG}_I4=${ESF_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_REJETE_O4.dat
EXECPRG


NSTEP=${NJOB}_85
#------------------------------------------------------------------------------
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTC8802_FTECLEDAR_O2.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDAR_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25:,
        RETSEC_NF   26:1 - 26:,
        RTY_NF      27:1 - 27:,
        RETUW_NT    28:1 - 28:,
        LOBRET_CF   46:1 - 46:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION VIE ( LOBRET_CF="30" OR LOBRET_CF="31")
/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
exit
EOF
SORT



## export ${PRG}_I3=${DFILT}/${NJOB}_55A_${IB}_SORT_O_FTECLEDR_LIFE.dat

NSTEP=${NJOB}_90
#------------------------------------------------------------------------------
# Merge des fichiers
#------------------------------------------------------------------------------
LIBEL="Merge des fichiers"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_SORT_FTECLEDA_O.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_85_${IB}_FTECLEDAR_O.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_37A_${IB}_SORT_O_FTECLEDAA_LIFE.dat 2000 1"
SORT_I4="${DFILT}/${NJOB}_45A_${IB}_SORT_O_FTECLEDAR_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA.dat"
#SORT_O="${EST_FTECLEDA}"
INPUT_TEXT ${SORT_CMD} <<EOF

exit
EOF
SORT

#007 #014
NSTEP=${NJOB}_95A
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLATXCUM}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUM.dat
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

#007 #008
#007 #008 #[010]


NSTEP=${NJOB}_95B
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Summarizing GTAR TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_FTECLEDA.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_SANS_REJ_OPNG.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_AVEC_REJ_OPNG.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:EN,
        RTY_NF 27:1 - 27:,
		    PLC_NT 36:1 - 36:EN 15/3,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        TRNCOD_CF 6:1 - 6:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:EN,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        RETAMT_M 35:1 - 35:EN 15/3,
        RETINTAMT_M 88:1 - 88:EN 15/3,
				ORICOD_LS 104:1 - 104:,        
        GT_ANNUL_OPNG   114:1 - 114:,
				FILLER_1_113    1:1 - 113:,
				FILLER_115_118  115:1 -118:                      
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
        CUR_CF,
        TRNCOD_CF                      
/CONDITION ANNU_OPNG  (GT_ANNUL_OPNG = "A" or GT_ANNUL_OPNG = "O")
/OUTFILE ${SORT_O} overwrite
/OMIT ANNU_OPNG
/OUTFILE ${SORT_O2} overwrite
/INCLUDE ANNU_OPNG
exit
EOF
SORT


#[010]



NSTEP=${NJOB}_95C
# Affectation par placement
#-----------------------------------------------------------------------------
LIBEL=" AGREGATES retro Affectation MVT par placement "
PRG=ESTC1052B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
FPLATXCUM CUM
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NJOB}_95A_${IB}_FPLATXCUM.dat"
export ${PRG}_I2="${DFILT}/${NJOB}_95B_${IB}_SORT_FTECLEDA_SANS_REJ_OPNG.dat"
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDA_SANS_REJ_OPNG.dat"
#export ${PRG}_O1=${EST_FTECLEDA}
EXECPRG


## [010] [014]


## MERGE DU FPLATCUMALL et ${DFILT}/${NJOB}_95B_${IB}_SORT_FTECLEDA_SANS_REJ_OPNG.dat

## KEY RETCTR_NF~RETSEC_NF~RTY_NF~PLC_NT 

##[015] Vider la Colonne _67 Si ORICOD_LS = "RECLASSP" ou "RECLASSL"      


NSTEP=${NJOB}_95D
#------------------------------------------------------------------------------
# Merge des fichiers
#------------------------------------------------------------------------------
LIBEL="Merge des fichiers et cumul sur Cle"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95C_${IB}_ESTC1052B_FTECLEDA_SANS_REJ_OPNG.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_95B_${IB}_SORT_FTECLEDA_AVEC_REJ_OPNG.dat 2000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA.dat"
SORT_O="${EST_FTECLEDA}"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	DBLTRNCOD_CF      7:1 -   7:,
	CTR_NF            8:1 -   8:,
	END_NT            9:1 -   9:,
	SEC_NF           10:1 -  10:,
	UWY_NF           11:1 -  11:,
	UW_NT            12:1 -  12:,
	OCCYEA_NF        13:1 -  13:EN,
	ACY_NF           14:1 -  14:EN,
	SCOSTRMTH_NF     15:1 -  15:EN,
	SCOENDMTH_NF     16:1 -  16:EN,
	CUR_CF           18:1 -  18:,
	AMT_M            19:1 -  19:EN 18/3,
	CED_NF           20:1 -  20:,
	RETCTR_NF        24:1 -  24:,
	RETEND_NT        25:1 -  25:,
	RETSEC_NF        26:1 -  26:,
	RTY_NF           27:1 -  27:,
	RETUW_NT         28:1 -  28:,
	RETOCCYEA_NF     29:1 -  29:EN,
	RETACY_NF        30:1 -  30:EN,
	RETSCOSTRMTH_NF  31:1 -  31:EN,
	RETSCOENDMTH_NF  32:1 -  32:EN,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 18/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
  	CRE_D            41:1 -  41:,
	RETINTAMT_M      88:1 -  88:EN 18/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:,       
  GT_ANNUL_OPNG   114:1 - 114:,
	FILLER_1_113    1:1 - 113:,
	FILLER_115_118  115:1 - 118:		
/KEYS
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
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
	CUR_CF,
	CED_NF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF,
	RETCUR_CF,
	PLC_NT,
	RTO_NF,
	CRE_D,
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B,
	GT_ANNUL_OPNG
/CONDITION VIDER_NEWCOLS5  (ORICOD_LS = "RECLASSP" or ORICOD_LS = "RECLASSL")        
/DERIVEDFIELD GT_ANNUL_OPNG_NEW if VIDER_NEWCOLS5 then "" else GT_ANNUL_OPNG   	
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT FILLER_1_113, GT_ANNUL_OPNG_NEW, FILLER_115_118
exit
EOF
SORT


#----------------------------------------
# FTECLEDR
#----------------------------------------

 
NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTC8802_FTECLEDR_O1.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25: EN,
        RETSEC_NF   26:1 - 26: EN,
        RTY_NF      27:1 - 27: EN,
        RETUW_NT    28:1 - 28: EN,
        PLC_NT      36:1 - 36: EN,
	LOBRET_CF   45:1 - 45:
	
/KEYS RETCTR_NF,
      RTY_NF,
      PLC_NT
/CONDITION VIE ( LOBRET_CF="30" OR LOBRET_CF="31")
/OUTFILE ${SORT_O} OVERWRITE
/OMIT VIE
exit
EOF
SORT



NSTEP=${NJOB}_105
#------------------------------------------------------------------------------
# Sort of the Retrocession File and Cancellable Life 
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledgers File AND CANCELLABLE LIFE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_SORT_FTECLEDR_O.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_58A_${IB}_SORT_O_FTECLEDR_LIFE.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O_ALL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25: EN,
        RETSEC_NF   26:1 - 26: EN,
        RTY_NF      27:1 - 27: EN,
        RETUW_NT    28:1 - 28: EN,
        PLC_NT      36:1 - 36: EN,
	LOBRET_CF   45:1 - 45:
	
/KEYS RETCTR_NF,
      RTY_NF,
      PLC_NT
exit
EOF
SORT


NSTEP=${NJOB}_110
#------------------------------------------------------------------------------
# Update of SSDRTO_B ( internal retrocession )
#[002] remplacement du fichier ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_SORT_FPLC_O.dat par ${ESF_FPLACEMT2}
#[006]export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_SORT_FTECLEDR_O.dat
#-----------------------------------------------------------------------------
LIBEL="Update of SSDRTO_B ( internal retrocession )"
PRG=ESTC8803
export ${PRG}_I1=${DFILT}/${NJOB}_105_${IB}_SORT_FTECLEDR_O_ALL.dat
export ${PRG}_I2=${ESF_FPLACEMT2}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR.dat
EXECPRG

#MOD[011]
##[015] Vider la Colonne _67 Si ORICOD_LS = "RECLASSP" ou "RECLASSL" : AND (GT_ANNUL_OPNG = "A" or GT_ANNUL_OPNG = "O")  

NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
# Remove CSUOE from FTECLEDR file
LIBEL="Remove CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTC8803_FTECLEDR.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_NO_CSUOE.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF        8:1  - 8:,
        END_NT        9:1  - 9:,
        SEC_NF        10:1 - 10:,
        UWY_NF        11:1 - 11:,
        RETCTR_NF     24:1 - 24:,
        RETEND_NT     25:1 - 25:,
        RETSEC_NF     26:1 - 26:,
        RTY_NF        27:1 - 27:,
        RETUW_NT      28:1 - 28:,
        PLC_NT        36:1 - 36:,
        LOBRET_CF     45:1 - 45:,
				ORICOD_LS       57:1 - 57:,	        
        GT_ANNUL_OPNG   67:1 - 67:,        
        GT_ALL_COLS      1:1 - 71:,        
        filler1       1:1  - 7:,
        filler2       13:1 - 66:,
        FILLER_68_71     68:1 - 71:         
/CONDITION VIDER_NEWCOLS5  (ORICOD_LS = "RECLASSP" or ORICOD_LS = "RECLASSL") 
/DERIVEDFIELD GT_ANNUL_OPNG_NEW if VIDER_NEWCOLS5 then "" else GT_ANNUL_OPNG       
/OUTFILE ${SORT_O}
/DERIVEDFIELD SEPARATEUR "~"
/REFORMAT filler1, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, SEPARATEUR, filler2, GT_ANNUL_OPNG_NEW, FILLER_68_71
exit
EOF
SORT


#MOD[011]
NSTEP=${NJOB}_130
#-----------------------------------------------------------------------------
LIBEL="ADD CSUOE for RI LINES"
PRG=ESTC8804
export ${PRG}_I1=${DFILT}/${NJOB}_120_${IB}_SORT_FTECLEDR_NO_CSUOE.dat
export ${PRG}_I2=${ESF_FSSDACTR}
export ${PRG}_O1=${EST_FTECLEDR}
EXECPRG

JOBEND

