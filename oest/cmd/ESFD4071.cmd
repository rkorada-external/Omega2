#!/bin/ksh
#=============================================================================
# nom de l'application          : GAAP Transformation REQ 20.1
# nom du script SHELL           : ESFD4071.cmd
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


NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Collecting Life Assumed"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${ESF_FSOBBLOB_TXT}"
BCP_QRY="select LOB_CF, SOB_CF, PRDCOD_CT  from    BREF..TSOBBLOB "
BCP

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Collecting Life Assumed"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${ESF_IADVPERICASE_LIFE_ASSUMED}"
BCP_QRY="select distinct s.SSD_CF, s.CTR_NF,s.END_NT, s.SEC_NF, s.UWY_NF, s.UW_NT  ,c.CTRSTS_CT , s.LOB_CF 
		 from BTRT..TSECTION s, BTRT..TCONTR c, bref..tbatchssd z 
		 where s.CTR_NF = c.CTR_NF and s.UWY_NF = c.UWY_NF and s.LOB_CF in ('30','31') and s.SSD_CF = z.SSD_CF and z.batchuser_cf= suser_name()
		 union
		 select distinct s.SSD_CF, s.CTR_NF,s.END_NT, s.SEC_NF, s.UWY_NF, s.UW_NT  ,c.CTRSTS_CT , s.LOB_CF 
		 from BFAC..TSECTION s, BFAC..TCONTR c, bref..tbatchssd z 
		 where s.CTR_NF = c.CTR_NF and s.UWY_NF = c.UWY_NF and s.LOB_CF in ('30','31') and 
		 s.SSD_CF = z.SSD_CF and z.batchuser_cf= suser_name()"
BCP

NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="Collecting Life Assumed"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${ESF_IADVPERICASE_LIFE_RETRO}"
BCP_QRY="select distinct s.SSD_CF, s.RETCTR_NF,0 as RETEND_NT, s.RETSEC_NF, s.RTY_NF, 1 as RETUW_NT,c.RETCTRSTS_CT , s.LOB_CF
		 from BRET..TRETSEC s, BRET..TRETCTR c, bref..tbatchssd z 
		 where 	s.RETCTR_NF = c.RETCTR_NF and s.RTY_NF = c.RTY_NF and s.LOB_CF in ('30','31') and 
		 		s.SSD_CF = z.SSD_CF and z.batchuser_cf=  suser_name()"
BCP


#NSTEP=${NJOB}_20
##-----------------------------------------------------------------------------
#LIBEL="sort ${ESF_FCPLACC} "
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${ESF_FCPLACC} 2000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB 2000 1"
#INPUT_TEXT $SORT_CMD <<EOF
#/FIELDS
#    CMP_CTR_NF      2:1 - 2:,
#    CMP_ACY_NF      3:1 - 3:EN,
#    CMP_SCOSTRMTH_NF 4:1    - 4:EN,
#    CMP_SCOENDMTH_NF 5:1    -   5:EN,
#    CMP_LSTUPD_D    6:1 - 6:
#/KEYS  CMP_CTR_NF , 
#	CMP_ACY_NF , 
#	CMP_SCOSTRMTH_NF ,
#	CMP_SCOENDMTH_NF 
#exit
#EOF
#SORT



NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="min CMP_SCOSTRMTH_NF, CMP_SCOENDMTH_NF  ${ESF_FCPLACC} /CTR,ACY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_20_${IB}_FCPLACC_SORT.dat 2000 1"
SORT_I="${ESF_FCPLACC} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCPLACC_SORT.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
    CMP_CTR_NF      2:1 - 2:,
    CMP_ACY_NF      3:1 - 3:EN
/KEYS  CMP_CTR_NF,CMP_ACY_NF
/STABLE
/SUM
exit
EOF
SORT



NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Sort  ${ESF_FCPLACC}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_FCPLACC_SORT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCPLACC_SORT.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
    CMP_CTR_NF      2:1 - 2:,
    CMP_ACY_NF      3:1 - 3:EN,
    CMP_LSTUPD_D    6:1 - 6:
/KEYS  CMP_CTR_NF , 
		CMP_ACY_NF DESCENDING
exit
EOF
SORT

NSTEP=${NJOB}_40
#-----------------------------------------------------------------------------
LIBEL="max ACY ${ESF_FCPLACC} /CTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_FCPLACC_SORT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCPLACC_SORT.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
    CMP_CTR_NF      2:1 - 2:
/KEYS  CMP_CTR_NF
/STABLE
/SUM
exit
EOF
SORT


NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="filtre  CTRGRO_UWY_NF of ${ESF_FCTRGRO0} ==> ${ESF_FCTRGRO0_EMPTY}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FCTRGRO0} 2000 1"
SORT_O="${ESF_FCTRGRO0_EMPTY} "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
    CTRGRO_UWY_NF      21:1 - 21:
/CONDITION COND_UWY_NF CTRGRO_UWY_NF = "" OR CTRGRO_UWY_NF ="0"
/INCLUDE COND_UWY_NF
exit
EOF
SORT

NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="Extend IADVPERICASE IADVPERICASE with CPLACC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADVPERICASE_CPLACC.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    PER_CTR_NF      3:1 - 3:,
    PER_ALL         1:1 - 206:,
    CMP_CTR_NF      2:1 - 2:,
    CMP_ACY_NF      3:1 - 3:,
    CMP_LSTUPD_D    6:1 - 6:
/joinkeys
    PER_CTR_NF 
/INFILE ${DFILT}/${NJOB}_40_${IB}_FCPLACC_SORT.dat 2000 1 "~"
/joinkeys
    CMP_CTR_NF  
/JOIN UNPAIRED leftside 
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:PER_ALL,
	rightside:CMP_ACY_NF,
	rightside:CMP_LSTUPD_D

exit
EOF
SORT


NSTEP=${NJOB}_70
#-----------------------------------------------------------------------------
LIBEL="Extend IADVPERICASE IADVPERICASE with CTRGRO_VRS_NF,CTRGRO_SEG_NF off CTRGRO_UWY_NF is empty (default SEG_NF) "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_IADVPERICASE_CPLACC.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADVPERICASE_CPLACC_SEG0.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
    PER_CTR_NF 3:1 - 3:,
    PER_END_NT 4:1 - 4:,
    PER_SEC_NF 5:1 - 5:,
    PER_UWY_NF 6:1 - 6:,
    PER_UW_NT 7:1 - 7:,
    PER_ALL         1:1 - 208:,

    CTRGRO_CTR_NF 1:1 - 1:,
    CTRGRO_END_NT 2:1 - 2:,
    CTRGRO_SEC_NF 3:1 - 3:,
    CTRGRO_UWY_NF    21:1 - 21:,
    CTRGRO_SEG_NF 7:1 - 7:,
    CTRGRO_VRS_NF    4:1    - 4: 
/joinkeys
    PER_CTR_NF ,
    PER_END_NT ,
    PER_SEC_NF 
/INFILE ${ESF_FCTRGRO0_EMPTY} 2000 1 "~"
/joinkeys
    CTRGRO_CTR_NF ,
    CTRGRO_END_NT ,
    CTRGRO_SEC_NF 
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}
/REFORMAT
    leftside :PER_ALL,rightside:CTRGRO_VRS_NF,rightside:CTRGRO_SEG_NF
exit
EOF
SORT



NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Extend IADVPERICASE IADVPERICASE with CTRGRO_VRS_NF,CTRGRO_SEG_NF WHEoffN CTRGRO_UWY_NF not empty "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_IADVPERICASE_CPLACC_SEG0.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADVPERICASE_CPLACC_SEG0_SEG.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
  PER_CTR_NF 3:1 - 3:,
    PER_END_NT 4:1 - 4:,
    PER_SEC_NF 5:1 - 5:,
    PER_UWY_NF 6:1 - 6:,
    PER_UW_NT 7:1 - 7:,
    PER_ALL         1:1 - 210:,

    CTRGRO_CTR_NF 1:1 - 1:,
    CTRGRO_END_NT 2:1 - 2:,
    CTRGRO_SEC_NF 3:1 - 3:,
    CTRGRO_UWY_NF    21:1 - 21:,
    CTRGRO_SEG_NF 7:1 - 7:,
    CTRGRO_VRS_NF    4:1    - 4: 
/joinkeys
    PER_CTR_NF ,
    PER_END_NT ,
    PER_SEC_NF,
    PER_UWY_NF 
/INFILE ${ESF_FCTRGRO0} 2000 1 "~"
/joinkeys
    CTRGRO_CTR_NF ,
    CTRGRO_END_NT ,
    CTRGRO_SEC_NF ,
    CTRGRO_UWY_NF 
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}
/REFORMAT
    leftside :PER_ALL,rightside:CTRGRO_VRS_NF,rightside:CTRGRO_SEG_NF

exit
EOF
SORT

NSTEP=${NJOB}_90
#-----------------------------------------------------------------------------
LIBEL="Extend IADVPERICASE IADVPERICASE with PRDCOD_CT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_IADVPERICASE_CPLACC_SEG0_SEG.dat 2000 1"
SORT_O="${ESF_IADVPERICASE_CPLACC_SEG0_SEG_PRDCOD}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
   PER_LOB_CF  38:1 - 38:,
    PER_SOB_CF  81:1 - 81:,
    PER_CTRNAT_CT		85	:1	 -	85	:,
    PER_ALL     1:1 - 212:,
    LOB_CF      1:1 - 1:,
    SOB_CF      2:1 - 2:,
    PRDCOD_CT   3:1 - 3: 
/DERIVEDFIELD FAC  "F" 
/joinkeys
    PER_LOB_CF ,
    PER_SOB_CF ,
    PER_CTRNAT_CT	

/INFILE ${ESF_FSOBBLOB_TXT} 2000 1 "~"
/joinkeys
    LOB_CF ,
    SOB_CF ,
    FAC
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}
/REFORMAT
    leftside :PER_ALL,rightside:PRDCOD_CT

exit
EOF
SORT


JOBEND
