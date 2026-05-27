#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - CONTROLE DES ESTIMATIONS
#                                redeclenchement de la mise a jour des ultimes
# nom du script SHELL		: ESIJ1001.cmd
# revision			        : $Revision: 1.4 $
# date de creation		    : 14/01/03
# auteur			        : J. Ribot
#-----------------------------------------------------------------------------
# description               : redeclenchement de la mise a jour des ultimes lors d'inventaire
# Job launched by           : ESIJ1000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
# Modifié par  M. DJELLOULI  10-03-2004
#                           Ajout des STEP=01, STEP=03 et STEP=33
#               STEP=01 Le traitement ESIJ1001.cmd est conditionné de la manière suivante :
#                   SI  [Max(LSTUPD_D) de BREF..TCURQUOT (SSD_CF = 99)]
#                       est différente de   [LAUNCH_D de BEST..TREQJOB (REQCOD_CT = 'M')]
#                   ALORS [EXECUTION DU TRAITEMENT ESIJ1001] et [Nouvelle MAJ de LAUNCH_D]
#                   SINON [RIEN]
#
#               STEP=03 Contrôle de DATES
#
#               STEP=33 Mise a jour de la date de traitement dans BEST..TREQJOB (REQCOD_CT = 'M')
#===============================================================================
#MODIFICATION
#Auteur:   J. Ribot
#Date      30 06 2009
#     SPOT17640 dans le ESIJ1000, pas de redeclenchement de MAJ des utimes après mise à jour des taux de change
#
#---------------
# MODIFICATION   : [002]
# Auteur         : D.GATIBELZA
# Date           : 11/12/2009
# Version        : 9.1
# Description    : ESTVIE17640 pas de redeclenchement de MAJ des utimes après mise à jour des taux de change (ESIJ1000)
#[003] 08/08/2013 Florent :spot:25427 Centralisation des bases (filiales)
#[004] 26/03/2014 Roger   :spot:25427 - Omega2 - Gestion test du type de contrat (trt ou fac)
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3
DBCLO_D=$4
CLODAT_D=$5

# Job Initialisation
JOBINIT


NSTEP=${NJOB}_01
# Begin  isql
#----------------------------------------------------------------------------
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_O1.dat
BCP_QRY="execute BEST..PsCURQUOT_02"
BCP


NSTEP=${NJOB}_03
DATE_CHGCOURS=`cat ${DFILT}/${NJOB}_01_${IB}_BCP_O1.dat`
if [ ${DATE_CHGCOURS} -eq 1 ]
then
    JOBEND
fi


NSTEP=${NJOB}_05
# Bcp out of TFAMLIA in file
#------------------------------------------------------------------------------
LIBEL=" Bcp out of TFAMLIA in file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TFAMLIA_O.dat
BCP_QRY="exec BEST..PsFAMLIA_04"
BCP

NSTEP=${NJOB}_10
# Bcp out of TCTRACC in file
#------------------------------------------------------------------------------
LIBEL=" Bcp out of TCTRACC in file"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TCTRACC_0.dat
BCP_QRY="SELECT CTR_NF,END_NT,SEC_NF,UW_NT,UWY_NF
         FROM BEST..TCTRACC a
 where exists(select 1 from BTRT..TCONTR b, BREF..TBATCHSSD c where a.CTR_NF=b.CTR_NF and a.UWY_NF=b.UWY_NF and a.UW_NT=b.UW_NT and a.END_NT=b.END_NT and b.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())
    or exists(select 1 from BFAC..TCONTR d, BREF..TBATCHSSD e where a.CTR_NF=d.CTR_NF and a.UWY_NF=d.UWY_NF and a.UW_NT=d.UW_NT and a.END_NT=d.END_NT and d.SSD_CF=e.SSD_CF and e.BATCHUSER_CF=suser_name())"
BCP


NSTEP=${NJOB}_15
#Merge of CURGTA and GTA
# [002] simplification [004]
#-----------------------------------------------------------------------------
LIBEL="Current merge of CURGTA of GTA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTA} 1000 1"
SORT_I2="${EST_CURGTA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTA_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD3_CF  6:3 -  6:3,
        TRNCOD4_CF  6:4 -  6:4,
        CTR1_NF     8:1 -  8:1,
        CTR3_NF     8:3 -  8:3
/CONDITION LIGNECPT ( ( TRNCOD3_CF EQ "1"  and TRNCOD4_CF EQ "0" ) AND ( CTR3_NF > 'M' OR CTR1_NF = "T" ) )
/OUTFILE ${SORT_O}
/INCLUDE LIGNECPT
exit
EOF
SORT


NSTEP=${NJOB}_17
#Merge of CURGTA and GTA
# [002] changement de l'ordre du tri, et format EN pour les champs numériques
#-----------------------------------------------------------------------------
LIBEL="Current merge of CURGTA of GTA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_SORT_GTA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTA_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF  8:1 -  8:,
        END_NT  9:1 -  9: EN,
        SEC_NF 10:1 - 10: EN,
        UWY_NF 11:1 - 11: EN,
        UW_NT  12:1 - 12: EN,
        CUR_CF 18:1 - 18:
/KEYS CTR_NF,
      UWY_NF,
      SEC_NF,
      END_NT,
      UW_NT,
      CUR_CF
/SUM
/OUTFILE ${SORT_O}
/REFORMAT CTR_NF,
          UWY_NF,
          SEC_NF,
          END_NT,
          UW_NT,
          CUR_CF
exit
EOF
SORT


NSTEP=${NJOB}_20
# Taking into Account Annual Estimates Statistical Expiries
#------------------------------------------------------------------------------
LIBEL="Taking into Account Balance sheet premium booked"
PRG=ESTC1040
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_BCP_TFAMLIA_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_17_${IB}_SORT_GTA_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTC1040_TCTRACC_O1.dat
EXECPRG


NSTEP=${NJOB}_25
#Merge of NEW TCTRACC and OLD TCTRACC
# [002] ajout EN pour les champs numériques
#-----------------------------------------------------------------------------
LIBEL="Current merge of TCTRACC ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_10_${IB}_BCP_TCTRACC_0.dat
SORT_I2=${DFILT}/${NJOB}_20_${IB}_ESTC1040_TCTRACC_O1.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TCTRACC_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF 1:1 - 1:,
	    END_NT 2:1 - 2: EN,
        SEC_NF 3:1 - 3: EN,
	    UW_NT  4:1 - 4: EN,
	    UWY_NF 5:1 - 5: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UW_NT,
      UWY_NF
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_29
#------------------------------------------------------------------------------
LIBEL="delete TCTRACC in file"
ISQL_QRY="delete BEST..TCTRACC FROM BEST..TCTRACC a
 where exists(select 1 from BTRT..TCONTR b, BREF..TBATCHSSD c where a.CTR_NF=b.CTR_NF and a.UWY_NF=b.UWY_NF and a.UW_NT=b.UW_NT and a.END_NT=b.END_NT and b.SSD_CF=c.SSD_CF and c.BATCHUSER_CF=suser_name())
    or exists(select 1 from BFAC..TCONTR d, BREF..TBATCHSSD e where a.CTR_NF=d.CTR_NF and a.UWY_NF=d.UWY_NF and a.UW_NT=d.UW_NT and a.END_NT=d.END_NT and d.SSD_CF=e.SSD_CF and e.BATCHUSER_CF=suser_name())"
ISQL_BASE="BEST"
ISQL

NSTEP=${NJOB}_30
# Begin BCP IN
#-----------------------------------------------------------------
LIBEL=" and BCP IN into BEST..TCTRACC"
BCP_WAY="IN"; BCP_VER=""
BCP_I=${DFILT}/${NJOB}_25_${IB}_SORT_TCTRACC_O.dat
BCP_TABLE="BEST..TCTRACC"
BCP

NSTEP=${NJOB}_33
# MOD01 Mise a jour de la date de traitement LAUNCH_D dans BEST..TREQJOB (REQCOD_CT = 'M')
#-----------------------------------------------------------------
LIBEL="Mise a jour de la date de traitement LAUNCH_D dans BEST..TREQJOB (REQCOD_CT = 'M')"
ISQL_QRY="EXECUTE BEST..PuREQJOB_04 ${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}', '${DBCLO_D}', '${CLODAT_D}'"
ISQL_BASE="BEST"
ISQL


NSTEP=${NJOB}_35
#Delete temporary files
#----------------------------------------------------------------------------
LIBEL="Delete Temporary file"
RMFIL "${DFILT}/${NJOB}_*_${IB}_*.dat"

JOBEND
