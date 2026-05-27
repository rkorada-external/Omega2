#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS Controle des operations internes
#                                 DELTA
# nom du script SHELL		: ESRD0022.cmd
# revision			:
# date de creation		: 15/12/00
# auteur			: S Llorente
# references des specifications	:
#-----------------------------------------------------------------------------
# Traitement effectue a la demande (Q20)
# Lecture des fichiers a utiliser dans ${DPERM}/ESRD0020.prm
# Dezippage des fichiers dans ${DFILT}
# Concatenation des fichiers et mise en base (BSAR..TCTRLIO) des différences
# GTA-GTR detectees
#-----------------------------------------------------------------------------
# historique des modifications
# NB pour l'instant TCTRLIO et TBOPAR sont dans BSTA
# a terme ---> BSAR : FAIT le 7-2-2001
#[002] Florent      12/09/2013  :spot:25427 Closing batches adaptation for centralization, maj step 35
#===============================================================================


# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT


# Parameters
EST_GTAINIO_FRA1=$1
EST_GTRINIO_FRA1=$2
EST_GTAINIO_SGP1=$3
EST_GTRINIO_SGP1=$4
EST_GTAINIO_USA1=$5
EST_GTRINIO_USA1=$6

echo "EST_GTAINIO_FRA1 "$1
echo "EST_GTRINIO_FRA1 "$2
echo "EST_GTAINIO_SGP1 "$3
echo "EST_GTRINIO_SGP1 "$4
echo "EST_GTAINIO_USA1 "$5
echo "EST_GTRINIO_USA1 "$6



NSTEP=${NJOB}_10
# UNZIP EST_GTAIN files
#----------------------------------------------------------------------------
LIBEL="UNZIP EST_GTAIN data files or create empty default file"

 for PRDSITE in ${LISTE_SITES}
 do
   if [ -f "$(eval echo \${DFILI}/\${EST_GTAINIO_${PRDSITE}}.Z.zip)" ]
	then
	    ZIP_IDIR=${DFILI}
	    ZIP_ODIR=${DFILT}
	    ZIP_I="$(eval echo \${EST_GTAINIO_${PRDSITE}}).Z.zip"
	    ZIP_OPT=""
	    ZIP_MODE="U"
	    ZIP
   else
       EXECKSH "touch $(eval echo \${DFILT}/\${EST_GTAINIO_${PRDSITE}})"
   fi
 done


NSTEP=${NJOB}_15
# ZIP EST_GTRIN files
#----------------------------------------------------------------------------
LIBEL="UNZIP EST_GTRIN data files or create empty default file"


 for PRDSITE in ${LISTE_SITES}
 do
   if [ -f "$(eval echo \${DFILI}/\${EST_GTRINIO_${PRDSITE}}.Z.zip)" ]
	then
	    ZIP_IDIR=${DFILI}
	    ZIP_ODIR=${DFILT}
	    ZIP_I="$(eval echo \${EST_GTRINIO_${PRDSITE}}).Z.zip"
	    ZIP_O="$(eval echo \${EST_GTRINIO_${PRDSITE}})"
	    ZIP_MODE="U"
	    ZIP
   else
         EXECKSH "touch $(eval echo \${DFILT}/\${EST_GTRINIO_${PRDSITE}})"

   fi
 done




NSTEP=${NJOB}_20
# Begin SORT
#----------------------------------------------------------------------------
LIBEL="Merge and Sort of CLEDR files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${EST_GTRINIO_FRA1} 1000 1"
SORT_I1="${DFILT}/${EST_GTRINIO_USA1} 1000 1"
SORT_I2="${DFILT}/${EST_GTRINIO_SGP1} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_MERGE_FTECLEDR_INIO.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
   SSD_CF 1:1 - 1:,
   SSD_CF_R 2:1 - 2:,
   RETAMT_M 3:1 - 3: EN,
   ACMTRS_CF 4:1 - 4:,
   TYPMNT_CT 5:1 - 5:,
   RETCUR_CF 6:1 - 6:,
   CTR_NF 7:1 - 7:,
   END_NT 8:1 - 8:,
   SEC_NF 9:1 - 9:,
   UWY_NF 10:1 - 10:,
   UW_NT 11:1 - 11:
/KEYS
   CTR_NF,
   END_NT,
   SEC_NF,
   UWY_NF,
   UW_NT,
   ACMTRS_CF,
   RETCUR_CF,
   TYPMNT_CT,
   SSD_CF,
   SSD_CF_R
/OUTFILE ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_25
# Begin SORT
#----------------------------------------------------------------------------
LIBEL="Merge and Sort of CLEDA files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${EST_GTAINIO_FRA1} 1000 1"
SORT_I1="${DFILT}/${EST_GTAINIO_USA1} 1000 1"
SORT_I2="${DFILT}/${EST_GTAINIO_SGP1} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_MERGE_FTECLEDA_INIO.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
   SSD_CF 1:1 - 1:,
   RETAMT_M 2:1 - 2: EN,
   ACMTRS_CF 3:1 - 3:,
   TYPMNT_CT 4:1 - 4:,
   RETCUR_CF 5:1 - 5:,
   CTR_NF 6:1 - 6:,
   END_NT 7:1 - 7:,
   SEC_NF 8:1 - 8:,
   UWY_NF 9:1 - 9:,
   UW_NT 10:1 - 10:,
   SSDS_CF 11:1 - 11:
/KEYS
   CTR_NF,
   END_NT,
   SEC_NF,
   UWY_NF,
   UW_NT,
   ACMTRS_CF,
   RETCUR_CF,
   TYPMNT_CT,
   SSD_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_30
# Begin C program
#----------------------------------------------------------------------------
LIBEL="Generation of the differences file between GTAINIO and GTRINIO files"
PRG=ESTC0013
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_MERGE_FTECLEDR_INIO.dat
export ${PRG}_I2=${DFILT}/${NJOB}_25_${IB}_MERGE_FTECLEDA_INIO.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DIFGTRGTA.dat
EXECPRG


NSTEP=${NJOB}_35
# Begin SORT
#----------------------------------------------------------------------------
LIBEL="Sort of DIFGTRGTA file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC0013_DIFGTRGTA.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DIFGTRGTA.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
   SSD_CF 1:1 - 1:,
   CTR_NF 2:1 - 2:,
   END_NT 3:1 - 3:,
   SEC_NF 4:1 - 4:,
   UWY_NF 5:1 - 5:,
   UW_NT  6:1 - 6:,
   ACMTRS_CF 7:1 - 7:,
   TYPMNT_CT 8:1 - 8:,
   CUR_CF 9:1 - 9:,
   RETAMT_M 10:1 - 10:,
   AMT_M 11:1 - 11:,
   SSDS_CF 12:1 - 12:

/KEYS
   SSD_CF,
   CTR_NF,
   END_NT,
   SEC_NF,
   UWY_NF,
   UW_NT,
   ACMTRS_CF,
   TYPMNT_CT,
   CUR_CF

/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_40
# Begin C program
#----------------------------------------------------------------------------
LIBEL="Summarize differences on the TCTRLIO table index"
PRG=ESTC0014
export ${PRG}_I1=${DFILT}/${NJOB}_35_${IB}_SORT_DIFGTRGTA.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DIFGTRGTA.dat
EXECPRG

#Switch on INFO CENTER server defined in the environment file
#----------------------------------------------------------------
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_45
# Begin BCP IN
#----------------------------------------------------------------------------
LIBEL="BCP in BSAR..TCTRLIO"
BCP_WAY="IN";
BCP_VER=""
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TRUNCATE=YES
BCP_I=${DFILT}/${NJOB}_40_${IB}_ESTC0014_DIFGTRGTA.dat
BCP_TABLE="BSAR..TCTRLIO"
BCP

NSTEP=${NJOB}_50
# Begin  isql
#----------------------------------------------------------------------------
LIBEL="BSAR..TBOPAR : TCTRLIO LSTUPD_D update"
ISQL_BASE="BSAR"
ISQL_QRY=`CFTMP`
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O1.dat
INPUT_TEXT ${ISQL_QRY} << EOF
update BSAR..TBOPAR
set LSTUPD_D = getdate()
where TAB_CF = 'TCTRLIO'
go
exit
EOF
ISQL

NSTEP=${NJOB}_55
# Delete GTR non zipped files
#----------------------------------------------------------------------------
LIBEL="Delete GTR and GTA non zipped files"
for PRDSITE in ${LISTE_SITES}
  do
	EXECKSH "rm $(eval echo \${DFILT}/\${EST_GTAINIO_${PRDSITE}})"
	EXECKSH "rm $(eval echo \${DFILT}/\${EST_GTRINIO_${PRDSITE}})"
  done

NSTEP=${NJOB}_60
# Begin RMFIL
#--------------------------------------------------------------------------
LIBEL="Remove of temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}_*.dat"

JOBEND
