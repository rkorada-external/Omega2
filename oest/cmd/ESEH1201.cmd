#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS Update of Infocenter tables
# nom du script SHELL            : ESEH1201.cmd
# revision                       : $Revision: 1.2 $
# date de creation               : 05/10/1998
# auteur                         : CGI
# references des specifications  :
#-----------------------------------------------------------------------------
# description
#	Generation of the Infocenter tables : TULTIMATES and TULTHIST
#
# job launched by ESEH1200.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#  10-07-2009      JFVDV - Ajout DROP & CREATE de l'index de la table TULTIMATES
#_________________
#MODIFICATION    [002]
#Auteur:         D.GATIBELZA
#Date:           21/07/2009
#Version:        9.1
#Description:    ESTDOM17755 ESEH1200  drop et recréation de l'index de bsar..tultimates
#[003] 15/06/2012 Roger Cassis :spot:23802 - Modifications pour Solvency - ajout sortie ESTC2301
#[004] 04/09/2012 Roger Cassis :spot:24041 - Solvency 2 - gestion parametre SEGTYP_CT
#[005] 12/08/2013 Paul Coppin  :spot:25427 - Ajout jointure table bref..tbatchssd pour Omega2.
#                 Florent                  - maj partition step 115,125
#[006] 26/09/2014 Roger Cassis :spot:27527 - Add 3 columns to extract tctrult data
#[007] 08/12/2014 Florent      :spot:27747 - OM2C ajout trace en gzip
#[008] 04/04/2017 R. Cassis    :spira:60188 Sauvegarde de la FULTIMATES IFRS dasn DFILI pour generation FULTIMATES EBS
#[009] M.NAJI 10/09/2018 add UWY_NF in TCTRGRO , spira 57605
#===============================================================================
#set -x 

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
OPTION=$1
SEGTYP_CT=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CLODAT_D=$5
CRE_D=$6

export LIMITINF_D=$((${CRE_D}-50000))

#[008]
NSTEP=${NJOB}_00
# Suppression fichiers
#----------------------------------------------------------------------------
RMFIL "${DFILI}/${NCHAIN}_FULTIMATES_*"

################################
# Compute of placed share rate #
################################

# Bilan en cours
################

NSTEP=${NJOB}_05
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLACEMT0}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FPLACUMUL_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4: EN,
        RETSEC_NF 5:1 - 5: EN,
        RTY_NF 6:1 - 6: EN,
        RETUW_NT 7:1 - 7: EN,
        SSDRTO_B 15:1 - 15:,
        RETSIGSHA_R 16:1 - 16:EN 1/8
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      SSDRTO_B
/SUMMARIZE TOTAL RETSIGSHA_R
exit
EOF
SORT

NSTEP=${NJOB}_10
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort of perimeter file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        SECACCSTS_CT 77:1 - 77:,
        CRTVRSINC_D 159:1 - 159:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION CLOSEDACC (SECACCSTS_CT EQ "9" AND CRTVRSINC_D >= "${LIMITINF_D}") or SECACCSTS_CT != "9"
/OUTFILE ${SORT_O}
   /INCLUDE CLOSEDACC
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCESSION0}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCESSION_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:, SEC_NF 3:1 - 3:, UWY_NF 4:1 - 4:, UW_NT 5:1 - 5:
/KEYS CTR_NF, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new cession file..."
PRG=ESTC2301
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_15_${IB}_SORT_FCESSION_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FCES_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETNP_SEGMENT_O.dat   #[003]
EXECPRG

NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE_O.dat
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_FCESSION_O.dat

NSTEP=${NJOB}_30
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_20_${IB}_ESTC2301_FCES_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCES_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 6:1 - 6:, RETEND_NT 7:1 - 7: EN, RETSEC_NF 8:1 - 8: EN, RTY_NF 9:1 - 9: EN, RETUW_NT 10:1 - 10: EN
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_20_${IB}_ESTC2301_FCES_O.dat

NSTEP=${NJOB}_40
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Synchro between cessions and placements files"
PRG=ESTC3601
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_FPLACUMUL_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_FCES_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSHARE_O.dat
EXECPRG

NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_FPLACUMUL_O.dat
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_FCES_O.dat

NSTEP=${NJOB}_50
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_40_${IB}_ESTC3601_FSHARE_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCEDBIL_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2: EN, SEC_NF 3:1 - 3: EN, UWY_NF 4:1 - 4: EN, UW_NT 5:1 - 5: EN, SHARERI_R 6:1 - 6: EN 1/8, SHARERE_R 7:1 - 7: EN 1/8
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/SUMMARIZE TOTAL SHARERI_R, TOTAL SHARERE_R
exit
EOF
SORT

NSTEP=${NJOB}_55
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC3601_FSHARE_O.dat

# Bilan anterieurs
##################

NSTEP=${NJOB}_60
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLCANT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FPLACUMUL_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 3:1 - 3:, RETEND_NT 4:1 - 4: EN, RETSEC_NF 5:1 - 5: EN, RTY_NF 6:1 - 6: EN, RETUW_NT 7:1 - 7: EN, SSDRTO_B 15:1 - 15:, RETSIGSHA_R 16:1 - 16:EN 1/8
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, SSDRTO_B
/SUMMARIZE TOTAL RETSIGSHA_R
exit
EOF
SORT

NSTEP=${NJOB}_65
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort of cession file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCESANT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCESANT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 6:1 - 6:, RETEND_NT 7:1 - 7: EN, RETSEC_NF 8:1 - 8: EN, RTY_NF 9:1 - 9: EN, RETUW_NT 10:1 - 10: EN
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_70
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Synchro between cessions and placements files"
PRG=ESTC3601
export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_FPLACUMUL_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_65_${IB}_SORT_FCESANT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSHARE_O.dat
EXECPRG

NSTEP=${NJOB}_75
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_FPLACUMUL_O.dat
RMFIL ${DFILT}/${NJOB}_65_${IB}_SORT_FCESANT_O.dat

NSTEP=${NJOB}_80
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation of placed share"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_70_${IB}_ESTC3601_FSHARE_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCEDANT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:, END_NT 2:1 - 2: EN, SEC_NF 3:1 - 3: EN, UWY_NF 4:1 - 4: EN, UW_NT 5:1 - 5: EN, SHARERI_R 6:1 - 6: EN 1/8, SHARERE_R 7:1 - 7: EN 1/8
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/SUMMARIZE TOTAL SHARERI_R, TOTAL SHARERE_R
exit
EOF
SORT

NSTEP=${NJOB}_85
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_70_${IB}_ESTC3601_FSHARE_O.dat


###############################################
# Generation of ultimates and accounting file #
###############################################

#[004]
NSTEP=${NJOB}_90
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of the ultimates file"
PRG=ESTC3603
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
OPTION ${OPTION}
SEGTYP_CT A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IADPERICASE0}
export ${PRG}_I2=${EST_FBSEGEST}
export ${PRG}_I3=${EST_FCTRGRO0}
export ${PRG}_I4=${EST_FUNDSTA0}
export ${PRG}_I5=${EST_FCTRULT0}
export ${PRG}_I6=${EST_FAPR0}
export ${PRG}_I7=${EST_FAMPROT0}
export ${PRG}_I8=${EST_IADPERIFCT0}
export ${PRG}_I9=${DFILT}/${NJOB}_50_${IB}_SORT_FCEDBIL_O.dat
export ${PRG}_I10=${DFILT}/${NJOB}_80_${IB}_SORT_FCEDANT_O.dat
export ${PRG}_I11=${EST_FSOBBLOB}
export ${PRG}_I12=${EST_FCURQUOT}
export ${PRG}_I13=${EST_FCPLACC0}
export ${PRG}_O1=${EST_FULTIMATES}  #${DFILT}/${NSTEP}_${IB}_${PRG}_FULTIMATES_O.dat #[008]
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_50_${IB}_SORT_FCEDBIL_O.dat  > ${DFILT}/SAUVEGARDE_${NCHAIN}_50_SORT_FCEDBIL_O.dat.gz
gzip -c ${DFILT}/${NJOB}_80_${IB}_SORT_FCEDANT_O.dat  > ${DFILT}/SAUVEGARDE_${NCHAIN}_80_SORT_FCEDANT_O.dat.gz

NSTEP=${NJOB}_95
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_FCEDBIL_O.dat
RMFIL ${DFILT}/${NJOB}_80_${IB}_SORT_FCEDANT_O.dat

#########################################
# Generation of ultimates historic file #
#########################################

#Modif [005]
#[006]
NSTEP=${NJOB}_100
#--------------------------------
LIBEL="Download of BEST..TCTRULT"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FULTHIST_O.dat
BCP_QRY="SELECT
    A.CTR_NF       ,
    A.END_NT       ,
    A.SEC_NF       ,
    A.UWY_NF       ,
    A.UW_NT        ,
    CRE_D=convert(char(26),A.CRE_D,109),
    A.SSD_CF       ,
    A.DIV_NT       ,
    A.CUR_CF       ,
    A.CALAMTPRM_M  ,
    A.ENTAMTPRM_M  ,
    A.RETAMTPRM_M  ,
    A.ADMMODPRM_CT ,
    A.RESPRM_M     ,
    A.CALAMTCLM_M  ,
    A.ENTAMTCLM_M  ,
    A.RETAMTCLM_M  ,
    A.ADMMODCLM_CT ,
    A.ORICOD_LS    ,
    A.UPDUSR_CF    ,
    A.CREUSR_CF    ,
    A.LSTUPD_D     ,
    A.LSTUPDUSR_CF ,
    A.EGPILRMODIF_CF,
    A.CMTLR_NT     ,
    A.CMTWP_NT
FROM BEST..TCTRULT A, BREF..TBATCHSSD B
WHERE A.SSD_CF = B.SSD_CF
and   B.BATCHUSER_CF = suser_name()"
BCP

########################
# Update of Infocenter #
########################

NSTEP=${NJOB}_105
# Switch server
#------------------------------------------------------------------------------
LIBEL="Switch in Infocenter server"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_115
#--------------------------------
LIBEL="filling BSAR..TULTHIST table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_100_${IB}_BCP_FULTHIST_O.dat
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..TULTHIST"
BCP

NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TULTHIST"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TULTHIST', '${CLODAT_D}',
		${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}', 'WEEKLY'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

NSTEP=${NJOB}_125
#--------------------------------
LIBEL="filling BSAR..TULTIMATES table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EST_FULTIMATES}  #${DFILT}/${NJOB}_90_${IB}_ESTC3603_FULTIMATES_O.dat  #[008]
BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..TULTIMATES"
BCP

NSTEP=${NJOB}_130
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TULTIMATES"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TULTIMATES', '${CLODAT_D}',
		${BALSHTYEA_NF}, ${BALSHTMTH_NF}, '${CRE_D}', 'WEEKLY'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

NSTEP=${NJOB}_135
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
