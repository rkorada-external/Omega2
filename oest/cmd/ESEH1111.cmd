#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS - Descente de table en fichiers permanents
# nom du script SHELL            : ESEH1111.cmd
# revision                       : $Revision: 1.2 $
# date de creation               : 05/10/1998
# auteur                         : CGI
# references des specifications  :
#-----------------------------------------------------------------------------
# description
#   	Table Download into permanent files.
#
# job launched by ESEH1110
#-----------------------------------------------------------------------------
# historiques des modifications
#
#  J. Ribot ajout step12 appel BEST..PsPLACEMT_03 pour creation fichier EST_FPLACEMT1 (SPOT 11167)
#  01/06/2010   Roger Cassis    :spot:19204 - Optimisation ESEH1100 par parallélisation et découpage en 2 chaines 1100+1110
#_________________
#MODIFICATION    [002]
#Auteur:         D.GATIBELZA
#Date:           23/07/2010
#Version:        10.1
#Description:    suite au mail PPEZOUT: Oui, juste le dernier; en fait les supprimer tous en début de traitement eseh1100
#_________________
#MODIFICATION    [003]
#Auteur:         D.GATIBELZA
#Date:           03/05/2011
#Version:        11.1
#Description:    ESTDOM21408 OneLedger
#[004] 12/06/2015 SAS, spot: 28694 ajout du step 31 et 70 pour charger la table TCTRGRO pour la vie
#_________________
#MODIFICATION    [005]
#Auteur:         HH.Huynh
#Date:           15/03/2018
#Version:        12.1
#Description:    Prise en compte des limites définies par les champs (BLCSHTSTR_D et BLCSHTEND_D) dans TCESSIONS pour grille Retro estimate
#
# [006] M.NAJI 10/09/2018 add UWY_NF in TCTRGRO , spira 57605 
# [007] MZGM   24/02/2020 Spira:79070 REQ11. Generate RETRO LOSS OCCURING FILE 
# [008] R. Cassis 28/02/2020 Spira:79070 REQ11. Generate RETRO LOSS OCCURING FILE  -> je mets en commentaire le step car ça plante
# [010] 26/02/2021 M.NAJI Spira 91531  commenter les suppression des fichier permanents  
# [011] 14/04/2022 Dad spira : 103830 fix PARALLEL_INIT parameter
# [012] 04/20/2022 JBD spira : 102774 update cessh_r to 0
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd

# Initialisation of the Job
JOB_LOG_OUTPUT=TEE
JOBINIT

# Parameters
OPTION=$1
CLODAT_D=$2
SEGTYP_CT=$3

NSTEP=${NJOB}_00
#Last version of ESEH1110 files deletion
#[002] ajout EST_SAISPERICASE
#-----------------------------------------------------------------
echo "DEBUT RMFIL"
RMFIL "  `dirname ${EST_FUNDSTA0}`/${PCH}ESEH1110_FUNDSTA0*.dat
 `dirname ${EST_FCTRULT0}`/${PCH}ESEH1110_FCTRULT0*.dat
 `dirname ${EST_FVCTRGRO0}`/${PCH}ESEH1110_FVCTRGRO0*.dat
 `dirname ${EST_FCESSION1}`/${PCH}ESEH1110_FCESSION1*.dat
 `dirname ${EST_FPLACEMTCOM0}`/${PCH}ESEH1110_FPLACEMTCOM0*.dat
 `dirname ${EST_FAMPROT0}`/${PCH}ESEH1110_FAMPROT0*.dat
 `dirname ${EST_FAPR0}`/${PCH}ESEH1110_FAPR0*.dat
 `dirname ${EST_FBSEGEST}`/${PCH}ESEH1110_FBSEGEST*.dat
 `dirname ${EST_SAISPERICASE}`/${PCH}ESEH1110_SAISPERICASE*.dat"
 # [010]`dirname ${EST_FCTRGRO0}`/${PCH}ESEH1110_FCTRGRO0*.dat
 # [010]`dirname ${EST_FCESSION0}`/${PCH}ESEH1110_FCESSION0*.dat
 # [010]`dirname ${EST_FCPLACC0}`/${PCH}ESEH1110_FCPLACC0*.dat
 # [010]`dirname ${EST_FPLACEMT0}`/${PCH}ESEH1110_FPLACEMT0*.dat
echo "FIN RMFIL"
# START CONCURRENT STEPS
# -------------------------
#[003] 3 -> 4
PARALLEL_INIT  6
#

###################
# Tables Download #
###################

NSTEP=${NJOB}_05
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession Cessions File"
BCP_WAY="OUT"
BCP_VER="+"
if [ "X${PARM_ICLODAT_QTR}" = "X4" ] & [ "X${PARM_ICLODAT_YEA}" = "X2021" ]
then
    BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_EST_FCESSION0.dat
else
    BCP_O=${EST_FCESSION0}
fi
BCP_QRY="execute BEST..PsCESSION_01"
PARALLEL BCP

NSTEP=${NJOB}_08
# Begin Bcp
#------------------------------------------------------------------------------
# [005]
LIBEL="Generation of Retrocession Cessions File"
BCP_WAY="OUT"
BCP_VER="+"
if [ "X${PARM_ICLODAT_QTR}" = "X4" ] & [ "X${PARM_ICLODAT_YEA}" = "X2021" ]
then
    BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_EST_FCESSION1.dat
else
    BCP_O=${EST_FCESSION1}
fi
BCP_QRY="execute BEST..PsCESSION_03"
PARALLEL BCP


NSTEP=${NJOB}_10
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMT0}
BCP_QRY="execute BEST..PsPLACEMT_01"
PARALLEL BCP

NSTEP=${NJOB}_12
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMT1}
BCP_QRY="execute BEST..PsPLACEMT_03"
PARALLEL BCP

#[003]
NSTEP=${NJOB}_13
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMT2}
BCP_QRY="execute BEST..PsPLACEMT_05"
PARALLEL BCP


NSTEP=${NJOB}_15
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of statistic amounts table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FUNDSTA0}
BCP_QRY="execute BEST..PsUNDSTA_01"
PARALLEL BCP




# END CONCURRENT STEPS
# -------------------------
PARALLEL_END

#MOD[012]
if [ "X${PARM_ICLODAT_QTR}" = "X4" ] & [ "X${PARM_ICLODAT_YEA}" = "X2021" ]
then

NSTEP=${NJOB}_17
# Begin Sort
#------------------------------------------------------------------------------
LIBEL="Update CESSH_R to 0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_EST_FCESSION0.dat 2000 1"
SORT_O="${EST_FCESSION0} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF       6:1 -  6:3,
                                CESSH_R                 13:1 - 13:,
                                ZONE_1                  1: - 12:,
                                ZONE_2                  14: - 25:
/CONDITION COND_UPDATE(RETCTR_NF = "RPH" OR RETCTR_NF = "RNA")
/DERIVEDFIELD NEW_CESSH_R IF COND_UPDATE then "0.00000000" ELSE CESSH_R
/COPY
/OUTFILE ${SORT_O}
/REFORMAT ZONE_1, NEW_CESSH_R, ZONE_2
exit
EOF
SORT


NSTEP=${NJOB}_19
# Begin Sort
#------------------------------------------------------------------------------
LIBEL="Update CESSH_R to 0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_08_${IB}_BCP_EST_FCESSION1.dat 2000 1"
SORT_O="${EST_FCESSION1} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF       6:1 -  6:3,
                                CESSH_R                 13:1 - 13:,
                                ZONE_1                  1: - 12:,
                                ZONE_2                  14: - 25:
/CONDITION COND_UPDATE(RETCTR_NF = "RPH" OR RETCTR_NF = "RNA")
/DERIVEDFIELD NEW_CESSH_R IF COND_UPDATE then "0.00000000" ELSE CESSH_R
/COPY
/OUTFILE ${SORT_O}
/REFORMAT ZONE_1, NEW_CESSH_R, ZONE_2
exit
EOF
SORT

fi


NSTEP=${NJOB}_25
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Research of active versions for each subsidiary"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PsVERSION_03 '${OPTION}'"
ISQL

# START CONCURRENT STEPS
# -------------------------
PARALLEL_INIT  6
#

NSTEP=${NJOB}_20
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Selection of the last ultimates by contract"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCTRULT0}
BCP_QRY="execute BEST..PsCTRULT_01 '${OPTION}'"
PARALLEL BCP

NSTEP=${NJOB}_30
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BEST..TCTRGRO table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCTRGRO0}
BCP_QRY="execute BEST..PsSECTION_10 '${OPTION}', '${SEGTYP_CT}'"
PARALLEL BCP

#[004]
NSTEP=${NJOB}_31
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BEST..TCTRGROlife table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FVCTRGRO0}
BCP_QRY="execute BEST..PsFVCTRGRO_01 '${OPTION}', '${SEGTYP_CT}'"
PARALLEL BCP

NSTEP=${NJOB}_35
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Current Generation of Complete Accounts Files"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCPLACC0}
BCP_QRY="execute BEST..PsCPLACC_02 '${CLODAT_D}'"
PARALLEL BCP

NSTEP=${NJOB}_40
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BCTA..TAPR table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FAPR0}
BCP_QRY="execute BEST..PsAPR_01 '${OPTION}'"
PARALLEL BCP

NSTEP=${NJOB}_45
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BFAC..TFAMPROT table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FAMPROT0}
BCP_QRY="execute BEST..PsFAMPROT_01"
PARALLEL BCP

# END CONCURRENT STEPS
# -------------------------
PARALLEL_END

NSTEP=${NJOB}_50
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of binary format Files"
PRG=ESTX3602
export ${PRG}_O1=${EST_FBSEGEST}
EXECPRG

NSTEP=${NJOB}_55
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession commuted placements File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMTCOM0}
BCP_QRY="execute BEST..PsPLACEMT_10"
BCP

#PLG 19/10/2009 - Fiche Spot n° 16778: Ajout du fichier des taux de sinistralité des traités non proportionnels
NSTEP=${NJOB}_60
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation des taux lies a la saisonnalite des traites non proportionnels"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_SAISPERICASE}
BCP_QRY="execute BEST..PsPERITRTSAIS_01"
BCP
#Fin PLG 19/10/2009

#[004]
NSTEP=${NJOB}_70
# EST_FVCTRGRO0
#-----------------------------------------------------------------------------
LIBEL="EST_FVCTRGRO0 ==> EST_FVCTRGRO ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FVCTRGRO0} 1000 1"
SORT_O="${EST_FVCTRGRO} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        SSD_CF    5:1 - 5: EN,
        CTR_NF    1:1 - 1:,
        END_NT    2:1 - 2:,
        SEC_NF    3:1 - 3:,
        UWY_NF    21:1 - 21:,
        SEGTYP_CT 6:1 - 6:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
	  UWY_NF
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SEGTYP_CT = "A"
/INCLUDE INVENTAIRE
exit
EOF
SORT


# [007]
NSTEP=${NJOB}_75
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retro Loss Occuring File"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FLORETFACTOR}
BCP_QRY="execute BEST..PsLORETFACTOR_01  '${CLODAT_D}'"
#BCP

JOBEND
