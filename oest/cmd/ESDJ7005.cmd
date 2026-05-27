#=============================================================================
# Application name          : ESTIMATION LOT 28
# source file               : ESIJ7003.cmd
# revision                  : $Revision:   1.4  $
# creation date             : 01/08/97
# author                    : C.G.I. (M.NAJI)
# specifications references : ESARC01F.DOC
#-----------------------------------------------------------------------------
# description :
# JOB SET: Lot 28 -  Integration of accounts and  retro mouvements 
#                      in the daily GT 
#       Variables used by the job set (defined in ESCD9001.cmd) :
#        ${EST_FDRYTRN}
#
#-----------------------------------------------------------------------------
# Update history :
#   <dd/mm/yyyy>   <author>    <update description>
#	[001] 27/01/2016 MBO : SPOT:30095: SPIRA:44720: Soucis avec des doublons si il y a modification d'un contrat lors de 2 intraday dans la même journée.
# [002] 11/02/2016 DFI : SPOT:30095: SPIRA:44720: Ajout step dedoublonnage GTA_ID
# [003] 03/03/2016 MBO : spot:30277: Nettoyage des fichiers $DFILI
#									 Nettoyage des fichiers $DFILI
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

echo "IB=${IB}"

NSTEP=${NJOB}_010
# [003] Suppresion des fichiers precedents
#------------------------------------------------------------------------------
LIBEL="Deletion of Interm Files"
RMFIL	"`dirname ${EST_180_ESTC2040_OLD_LIFEST_O2}`/${NCHAIN}_180_ESTC2040_OLD_LIFEST_O2_*.dat
		 `dirname ${EST_GTA_ID}`/${NCHAIN}_GTA_ID_*.dat
		 `dirname ${EST_GTASW_ID}`/${NCHAIN}_GTASW_ID_*.dat
		 `dirname ${EST_GTR_ID}`/${NCHAIN}_GTR_ID_*.dat
		 `dirname ${EST_GTRSW_ID}`/${NCHAIN}_GTRSW_ID_*.dat
		 `dirname ${EST_IGTAA00_ID}`/${NCHAIN}_IGTAA00_ID_*.dat
		 `dirname ${EST_IGTR00_ID}`/${NCHAIN}_IGTR00_ID_*.dat
		 `dirname ${EST_STATGTR_ID}`/${NCHAIN}_STATGTR_ID_*.dat
		 `dirname ${EST_STATGTA_ID}`/${NCHAIN}_STATGTA_ID_*.dat"
#/[003]

SWITCH_SRV ${SRV_2}

# NSTEP=${NJOB}_010
# # Begin bcp
# #------------------------------------------------------------------------------
# LIBEL="creat work table to import contract"
# BCP_WAY="OUT"
# BCP_VER="+"
# BCP_O=${DFILT}/${NSTEP}_${IB}_TACCTRN_HISTO_LIGHT.dat
# BCP_QRY="create table BTRAVI..TACCTRN_HISTO_LIGHT (
# 		 SSD_CF USSD_CF null,
# 		 ESB_CF UESB_CF null,
# 		 CTR_NF UCTR_NF null,
# 		 UWY_NF UUWY_NF null,
# 		 SEC_NF USEC_NF null,
# 		 ACY_NF UACCYER_NF null,
# 		 SCOENDMTH_NF tinyint null,
# 		 TREATED_B bit
# )lock datarows
#  on 'default'
# partition by list(SSD_CF)(
# PACCTRN_HISTO_LIGHT_UBEU VALUES (1,2,3,4,5,6,7,8,9,12,15,16,17,18,19,23,40) on 'default',
# PACCTRN_HISTO_LIGHT_UBAM VALUES (10,11,13,14,25,26,27) on 'default',
# PACCTRN_HISTO_LIGHT_UBAS VALUES (20,22,24) on 'default')
# "
# BCP

# NSTEP=${NJOB}_040
# # Begin bcp
# #------------------------------------------------------------------------------
# LIBEL="delete of work table"
# BCP_WAY="OUT"
# BCP_VER="+"
# BCP_O=${DFILT}/${NSTEP}_${IB}_DELETE_TABBLE.dat
# BCP_QRY="drop table BTRAVI..TACCTRN_HISTO_LIGHT"
# BCP


# NSTEP=${NJOB}_020
# # Do BCPIN
# #------------------------------------------------------------------------------
# LIBEL="import contract to extract history accounts"
# BCP_WAY="IN"
# BCP_VER=""
# BCP_I=${EST_TCALL}
# BCP_TRUNCATE=YES
# BCP_PARTITION=YES
# BCP_UPDATE_INDEX_STAT=NO
# BCP_TABLE="BTRAVI..TACCTRN_HISTO_LIGHT"
# BCP

# NSTEP=${NJOB}_030
# # Begin bcp
# #------------------------------------------------------------------------------
# LIBEL="Extraction of historie accounts (creat ARCSTATGTA)"
# BCP_WAY="OUT"
# BCP_VER="+"
# BCP_O=${EST_ARCSTATGTA_ID}
# BCP_QRY="exec BSTA..PsTACCTRN_HISTO_LIGHT_ID"
# BCP

SWITCH_SRV ${SRV_DEFAULT}

NSTEP=${NJOB}_050
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Extraction of accounts mouvements (TDRYTRN ==> FDRYTRN)"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FDRYTRN_O.dat
BCP_QRY="exec BEST..PsACCTRN_01_ID '${SRV}'"
BCP

NSTEP=${NJOB}_100
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Concatenation of files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_050_${IB}_BCP_FDRYTRN_O.dat 800 1"
SORT_O="${EST_FDRYTRN_ID} APPEND"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT


#=============================================================================


NSTEP=${NJOB}_150
#[001] ajout des fichiers EST_GTASW et EST_GTRSW
#[004] ajout du fichier EST_IGTAA00
#-----------------------------------------------------------------
LIBEL="Size of files "
EXECKSH "touch ${EST_GTA_ID} ${EST_GTR_ID} ${EST_FDRYTRN_ID} ${EST_FRTOSTA_ID} ${EST_FACCTRTGT_ID} ${EST_GTASW_ID} ${EST_GTRSW_ID} ${EST_IGTAA00_ID} ${EST_STATGTR_ID} ${EST_STATGTA_ID}"
EXECKSH "wc ${EST_GTA_ID} ${EST_GTR_ID} ${EST_FDRYTRN_ID} ${EST_FRTOSTA_ID} ${EST_FACCTRTGT_ID} ${EST_GTASW_ID} ${EST_GTRSW_ID} ${EST_IGTAA00_ID} ${EST_STATGTR_ID}"

NSTEP=${NJOB}_200
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Concatenation of files ${EST_FDRYTRN_ID} and ${EST_FACCTRTGT_ID}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FACCTRTGT_ID} 800  1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FACCTRTGT_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FORMAT_STANDARD 1:1 - 41:
/DERIVEDFIELD PLUS_16_CHAMPS "~~~~~~~~~~~~~~~GTAR"
/OUTFILE ${SORT_O}
/REFORMAT FORMAT_STANDARD,PLUS_16_CHAMPS
exit
EOF
SORT

NSTEP=${NJOB}_250
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Concatenation of files ${EST_GTA_ID}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FDRYTRN_ID} 800  1"
SORT_I2="${DFILT}/${NJOB}_200_${IB}_SORT_FACCTRTGT_O.dat 800  1"
#SORT_O="${EST_GTA_ID}" #[001] APPEND en moins, plus de doublon/triple/etc.
SORT_O="${DFILT}/${NSTEP}_${IB}_GTA_ID.dat"   # [002]
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_275
# Dedoublonnage GTA_ID  [002]
#-----------------------------------------------------------------
LIBEL="Dedoublonnage GTA_ID"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_GTA_ID.dat 800 1"
SORT_O="${EST_GTA_ID}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FORMAT_STANDARD 1:1 - 57:
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_300
#[001][003] Extraction des fichiers GTASW
#-----------------------------------------------------------------------------
LIBEL="Extraction of GTASW file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FDRYTRN_ID} 1000 1"
#[002]SORT_I2="${EST_FACCTRTGT} 1000 1"
SORT_O="${EST_GTASW_ID} APPEND"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, 
        ESB_CF 2:1 - 2: EN,
        TRNCOD1_CF 6:1 - 6:1 EN
/CONDITION LIGNESSDESB ( SSD_CF=18 and ESB_CF=3 and TRNCOD1_CF!=2 and TRNCOD1_CF!=4 ) 
/INCLUDE LIGNESSDESB
exit
EOF
SORT

NSTEP=${NJOB}_350
#[005] ajout du fichier EST_IGTAA00
#-----------------------------------------------------------------
LIBEL="Save FACCTRTGT before delete"
EXECKSH "cp ${EST_FACCTRTGT_ID} ${DSAVE}/${SVG}_RTCJ0501_FACCTRTGT.dat"
EXECKSH "gzip ${DSAVE}/${SVG}_RTCJ0501_FACCTRTGT.dat"

NSTEP=${NJOB}_400
#-----------------------------------------------------------------
LIBEL="delete of files ${EST_FDRYTRN_ID} ${EST_FRTOSTA_ID}"
RMFIL "${EST_FDRYTRN_ID}"
RMFIL "${EST_FACCTRTGT_ID}"

NSTEP=${NJOB}_450
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Concatenation of files ${EST_GTR_ID}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FRTOSTA_ID} 800  1"
SORT_O="${EST_GTR_ID} APPEND"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_500
#[001] Extraction des fichiers GTRSW
#-----------------------------------------------------------------------------
LIBEL="Extraction of GTRSW file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FRTOSTA_ID} 1000 1"
SORT_O="${EST_GTRSW_ID} APPEND"
INPUT_TEXT ${SORT_CMD_ID} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, 
        ESB_CF 2:1 - 2: EN
/CONDITION LIGNESSDESB ( SSD_CF=18 and ESB_CF=3 ) 
/INCLUDE LIGNESSDESB
exit
EOF
SORT

NSTEP=${NJOB}_550
#[005] ajout du fichier EST_IGTAA00
#-----------------------------------------------------------------
LIBEL="Save FRTOSTA before delete"
EXECKSH "cp ${EST_FRTOSTA_ID} ${DSAVE}/${SVG}_RTCJ0501_FRTOSTA.dat"
EXECKSH "gzip ${DSAVE}/${SVG}_RTCJ0501_FRTOSTA.dat"

NSTEP=${NJOB}_600
#-----------------------------------------------------------------
LIBEL="delete of file ${EST_FRTOSTA_ID}"
RMFIL "${EST_FRTOSTA_ID}"

NSTEP=${NJOB}_650
#[007] forcer "CURGTA" comme ORICOD_LS des lignes de EST_CURGTA
#-----------------------------------------------------------------
LIBEL="Set ORICOD_LS=CURGTA when EBSGTA in file EST_CURGTA"
sed s/EBSGTA/CURGTA/g ${EST_CURGTA_ID} > ${DFILT}/${NSTEP}_${IB}_CURGTA.dat

gzip -c ${EST_CURGTA_ID}                       > ${DFILT}/SAUVEGARDE_ESIJ7005_EST_CURGTA.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_CURGTA.dat  > ${DFILT}/SAUVEGARDE_ESIJ7005_SED_CURGTA.dat.gz
echo ${EST_IGTAA00_ID}
echo ${EST_GTA_ID}
#[004]
#[005]
NSTEP=${NJOB}_700
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Création fichier Permanent: IGTAA00"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTA_ID} 800  1"
SORT_I2="${DFILT}/${NJOB}_650_${IB}_CURGTA.dat 800  1" #[007]
SORT_O="${EST_IGTAA00_ID}"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

#[006]
NSTEP=${NJOB}_750
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Création fichier Permanent: IGTAA00"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_STATGTR_ID} 800  1"
SORT_I2="${EST_GTR_ID} 800  1"
SORT_O="${EST_IGTR00_ID}"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_800
#-----------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat" #[003]

JOBEND
