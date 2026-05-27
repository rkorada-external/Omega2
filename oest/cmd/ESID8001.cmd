#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Restitution d'inventaire acceptation
# nom du script SHELL           : ESID8001.cmd
# revision                      : $Revision:   1.12  $
# date de creation              : 02/09/1997
# auteur                        : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description
#    Acceptance closing period restitution
#
# job launched by ESID8000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#---------------
#MODIFICATION   : [001]
#Auteur         : D.GATIBELZA
#Date           : 09/05/2011
#Version        : 11.1
#Description    : ESTDOM21408 OneLedger
#[002] 18/04/2012 Roger Cassis  :spot:23802 - Ajout colonne PRS_CF pour Solvency
#[003] 30/08/2013 Roger Cassis  :spot:25465 - La gestion de Tconpar ne passe qu'en annuel - :spot:25427 - Remise à niveau sur derniere version prod
#[004] 02/12/2013 Florent       :spot:25427 - maj partition
#[005] 31/01/2014 Roger cassis  :spot:25427 - Ajout commit dans delete tprmloa
#[006] 22/05/2017 Roger Cassis  :Spira:42211 Ajout test de condition 2 sur ESID8000 pour la gestion de TCONPAR en mode trimestriel
#[007] 21/09/2018 Roger Cassis  :spira:70467 - On recharge dans TCTREST uniquement la dernière version historique de chaque trimestre
#[008] 21/11/2018 Mr JYP        :spira:73134 - suite de la précédente modif 70467, modif pour historiser les lignes F
#[009] 08/04/2019 R. Cassis     :spira:65656 - Remplacement du truncate par delete dans TCTREST sur PRS_CF egal a 710 avant rechargement
#[010] 09/04/2020 R. Cassis     :spira:86503:86536 - Gestion du chargement TCTREST avec unicite de records et ancien CRE_D de ligne 'F' restauré
#[011] 12/06/2020 R. CASSIS     :spira:86536 - Remplacement awk par tris STABLE et revue gestion CTREST
#===============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT


#[007]
# Parameters
BALSHTYEA_NF=$1

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME.........................: ${NORME}"
ECHO_LOG "#===> TYPEINV.......................: ${TYPEINV}"
ECHO_LOG "#===> PARM_CRE_D....................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM0_ICLODAT_D...............: ${PARM0_ICLODAT_D}"
ECHO_LOG "#===> PRS_CF........................: ${PRS_CF}"
ECHO_LOG "#===> EST_FCTREST0..................: ${EST_FCTREST0}"
ECHO_LOG "#===> EST_FCTREST1..................: ${EST_FCTREST1}"
ECHO_LOG "#===> EST_FCTRESTA..................: ${EST_FCTRESTA}"
ECHO_LOG "#===> EST_FCTRESTF..................: ${EST_FCTRESTF}"
ECHO_LOG "#===> EST_FCTRESTF0.................: ${EST_FCTRESTF0}"
ECHO_LOG "#========================================================================="

################
# Tables purge #
################

#[003]
NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="deletion of the tables TIPPORT, TCALPRE, TEARIPP, TLOARAT, TRESSUM"
ISQL_BASE="BEST"
ISQL_QRY="delete BEST..TRESSUM where ${EST_SORT_CONDITION}
          delete BEST..TIPPORT where ${EST_SORT_CONDITION}
          delete BEST..TCALPRE where ${EST_SORT_CONDITION}
          delete BEST..TEARIPP where ${EST_SORT_CONDITION}
          delete BEST..TLOARAT where ${EST_SORT_CONDITION}"
ISQL

NSTEP=${NJOB}_07
# Begin isql
#------------------------------------------------------------------------------
LIBEL="deletion of the table TPRMLOA"
ISQL_BASE="BEST"
ISQL_QRY="
	declare @my_rowcount int,
	        @my_error int,
	        @max_delete int

	select @max_delete = 200000        -- 200000 max par boucle
	select @my_rowcount = @max_delete

	while @my_rowcount = @max_delete
	begin
		set rowcount @max_delete
		begin tran
		delete BEST..TPRMLOA where ${EST_SORT_CONDITION}
		select @my_rowcount = @@rowcount, @my_error = @@error
		set rowcount 0
		
		if @my_error != 0
		begin
			raiserror 30000 'Erreur sur Update'
			return
		end
		else
		begin
			commit tran
			print '%1! rows deleted', @my_rowcount
		end
	end
"
ISQL

##################################################
# Update of closing period tables for premiums   #
##################################################

#[002]
NSTEP=${NJOB}_10
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Accumulation amount by Contract, Endorsement, Section, UWYear, UWNumber, UWYear Display, AC Year, AC Period, Accumulation Transaction"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FT}
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTP_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CLODAT_D        1:1 -  1:,
        CTR_NF          2:1 -  2:,
        END_NT          3:1 -  3:,
        SEC_NF          4:1 -  4:,
        UWY_NF          5:1 -  5:,
        UW_NT           6:1 -  6:,
        ACY_NF          7:1 -  7:,
        SCOSTRMTH_NF    8:1 -  8:EN,
        SCOENDMTH_NF    9:1 -  9:EN,
        UWYDIS_NF      10:1 - 10:,
        SSD_CF         11:1 - 11:,
        WFCODE_NT      12:1 - 12:,
        WFTYP_CF       13:1 - 13:,
        EGPCUR_CF      14:1 - 14:,
        PRM_M          15:1 - 15:EN 15/3,
        PPNAC_M        16:1 - 16:EN 15/3,
        PPNAEA_M       17:1 - 17:EN 15/3,
        RPPC_M         18:1 - 18:EN 15/3,
        RPPEA_M        19:1 - 19:EN 15/3,
        LPPNAC_M       20:1 - 20:EN 15/3,
        EPPC_M         21:1 - 21:EN 15/3,
        EPPEA_M        22:1 - 22:EN 15/3,
        RECC_M         23:1 - 23:EN 15/3,
        RECE_M         24:1 - 24:EN 15/3,
        BCC_M          25:1 - 25:EN 15/3,
        BCE_M          26:1 - 26:EN 15/3,
        SHR_R          27:1 - 27:,
        ACCADMTYP_CT   28:1 - 28:,
        PRS_CF         29:1 - 29:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWYDIS_NF,
      UW_NT,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      WFCODE_NT,
      WFTYP_CF,
      PRS_CF
/SUMMARIZE TOTAL PRM_M,
           TOTAL PPNAC_M,
           TOTAL PPNAEA_M,
           TOTAL RPPC_M,
           TOTAL RPPEA_M,
           TOTAL LPPNAC_M,
           TOTAL EPPC_M,
           TOTAL EPPEA_M,
           TOTAL RECC_M,
           TOTAL RECE_M,
           TOTAL BCC_M,
           TOTAL BCE_M
/DERIVEDFIELD PRM_MC    PRM_M	   COMPRESS
/DERIVEDFIELD PPNAC_MC  PPNAC_M	   COMPRESS
/DERIVEDFIELD PPNAEA_MC PPNAEA_M   COMPRESS
/DERIVEDFIELD RPPC_MC   RPPC_M	   COMPRESS
/DERIVEDFIELD RPPEA_MC  RPPEA_M	   COMPRESS
/DERIVEDFIELD LPPNAC_MC LPPNAC_M   COMPRESS
/DERIVEDFIELD EPPC_MC   EPPC_M	   COMPRESS
/DERIVEDFIELD EPPEA_MC  EPPEA_M	   COMPRESS
/DERIVEDFIELD RECC_MC   RECC_M	   COMPRESS
/DERIVEDFIELD RECE_MC   RECE_M	   COMPRESS
/DERIVEDFIELD BCC_MC    BCC_M	   COMPRESS
/DERIVEDFIELD BCE_MC    BCE_M	   COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT CLODAT_D,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          ACY_NF,
          SCOSTRMTH_NF,
          SCOENDMTH_NF,
          UWYDIS_NF,
          SSD_CF,
          WFCODE_NT,
          WFTYP_CF,
          EGPCUR_CF,
          PRM_MC,
          PPNAC_MC,
          PPNAEA_MC,
          RPPC_MC,
          RPPEA_MC,
          LPPNAC_MC,
          EPPC_MC,
          EPPEA_MC,
          RECC_MC,
          RECE_MC,
          BCC_MC,
          BCE_MC,
          SHR_R,
          ACCADMTYP_CT,
          PRS_CF
exit
EOF
SORT

#[002]
NSTEP=${NJOB}_15
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Accumulation amount by contract, accounting periods undistinguished"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FTP_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FIPPORT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       2:1 -  2:,
        END_NT       3:1 -  3:,
        SEC_NF       4:1 -  4:,
        UW_NT        6:1 -  6:,
        UWYDIS_NF   10:1 - 10:,
        EGPCUR_CF   14:1 - 14:,
        EPPC_M      21:1 - 21:EN 15/3,
        EPPEA_M     22:1 - 22:EN 15/3,
        SHR_R       27:1 - 27:,
        SSD_CF      11:1 - 11:,
        PRS_CF      29:1 - 29:
/KEYS CTR_NF, END_NT, SEC_NF, UWYDIS_NF, UW_NT, PRS_CF
/SUMMARIZE TOTAL EPPC_M, TOTAL EPPEA_M
/DERIVEDFIELD EPPC_MC  EPPC_M	   COMPRESS
/DERIVEDFIELD EPPEA_MC  EPPEA_M	   COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT CTR_NF,
          END_NT,
          SEC_NF,
          UWYDIS_NF,
          UW_NT,
          SSD_CF,
          EGPCUR_CF,
          EPPC_MC,
          EPPEA_MC,
          SHR_R,
          PRS_CF
exit
EOF
SORT

#[002]
NSTEP=${NJOB}_20
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Reformating of premium working file records "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FTP_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTP_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF         2:1 -  2:,
        END_NT         3:1 -  3:,
        SEC_NF         4:1 -  4:,
        UW_NT          6:1 -  6:,
        ACY_NF         7:1 -  7:,
        SCOSTRMTH_NF   8:1 -  8:,
        SCOENDMTH_NF   9:1 -  9:,
        UWYDIS_NF     10:1 - 10:,
        WFCOD_NT      12:1 - 12:,
        PRS_CF        29:1 - 29:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWYDIS_NF,
      UW_NT,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      WFCOD_NT,
      PRS_CF
exit
EOF
SORT

NSTEP=${NJOB}_25
# Deletion of temporary file
#----------------------------------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_FTP_O.dat

NSTEP=${NJOB}_30
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Calculated premiums file and Earning Incoming prm portfolio file generation"
PRG=ESTC1020
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_FTP_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FEARIPP_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FCALPRE_O.dat
EXECPRG

NSTEP=${NJOB}_35
# Deletion of temporary file
#----------------------------------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_FTP_O.dat

NSTEP=${NJOB}_40
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Update of Incoming premium portfolio table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_15_${IB}_SORT_FIPPORT_O.dat
BCP_TABLE="BEST..TIPPORT"
BCP

NSTEP=${NJOB}_45
# Deletion of temporary file
#----------------------------------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_FIPPORT_O.dat

NSTEP=${NJOB}_50
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Update of Earning Incoming prm portfolio table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_30_${IB}_ESTC1020_FEARIPP_O.dat
BCP_TABLE="BEST..TEARIPP"
BCP

NSTEP=${NJOB}_55
# Deletion of temporary file
#----------------------------------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTC1020_FEARIPP_O.dat

NSTEP=${NJOB}_60
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Update of calculated premium table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_30_${IB}_ESTC1020_FCALPRE_O.dat
BCP_TABLE="BEST..TCALPRE"
BCP

NSTEP=${NJOB}_65
# Deletion of temporary file
#----------------------------------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTC1020_FCALPRE_O.dat

#################################################################
# Update of closing period restitution tables for claims        #
#################################################################

#[002]
#[001] le fichier en entrée passe à un maxi de 1000 caractères au lieu de 256 par défaut.
NSTEP=${NJOB}_70
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Accumulation amount by contract, accounting periods undistinguished"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TOTGTAA} 1000 1"
#SORT_I2="${EST_DLDGTAA_E_TRNCODBEST} 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O.dat
#SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_BEST_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF    6:1 -  6:,
        CTR_NF       8:1 -  8:,
        END_NT       9:1 -  9:,
        SEC_NF      10:1 - 10:,
        UWY_NF      11:1 - 11:,
        UW_NT       12:1 - 12:,
        OCCYEA_NF   13:1 - 13:,
        CUR_CF      18:1 - 18:,
        AMT_M       19:1 - 19:EN 15/3,
        ORICOD_LS   57:1 - 57:
/CONDITION TOTGTAA ORICOD_LS != "EBSGTA"
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF,
      TRNCOD_CF,
      CUR_CF
/SUMMARIZE TOTAL AMT_M
/OUTFILE ${SORT_O}
/INCLUDE TOTGTAA
exit
EOF
SORT

NSTEP=${NJOB}_80
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Result summary file generation"
PRG=ESTC1021
export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_70_${IB}_SORT_TOTGTAA_O.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_RESSUM_TOTGTAA.dat
EXECPRG

#[002]
# Attention si ca marche avec fichier vide supprimer cond
NSTEP=${NJOB}_85
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Result summary file generation"
PRG=ESTC1021
export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_I2=${EST_TOTGTAA}
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_RESSUM_DLDGTAA_EBS.dat
EXECPRG

#[002]
NSTEP=${NJOB}_86
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Accumulation amount by contract, accounting periods undistinguished"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTC1021_RESSUM_TOTGTAA.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_RESSUM_TOTGTAA.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DEBUT       1:1 - 18:
/DERIVEDFIELD PRS_CF "710"
/OUTFILE ${SORT_O}
/REFORMAT DEBUT, PRS_CF
exit
EOF
SORT

#[002]
NSTEP=${NJOB}_87
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Accumulation amount by contract, accounting periods undistinguished"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_85_${IB}_ESTC1021_RESSUM_DLDGTAA_EBS.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_RESSUM_DLDGTAA_EBS.dat
SORT_NOINFILE=YES
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DEBUT       1:1 - 18:
/DERIVEDFIELD PRS_CF "730"
/OUTFILE ${SORT_O}
/REFORMAT DEBUT, PRS_CF
exit
EOF
SORT

#[002]
NSTEP=${NJOB}_90
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Accumulation amount by contract for IFRS and EBS to RESSUM and add PRS_CF col"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_86_${IB}_SORT_RESSUM_TOTGTAA.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_87_${IB}_SORT_RESSUM_DLDGTAA_EBS.dat 500 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_RESSUM_O.dat
SORT_NOINFILE=YES
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1 :1 -  1:,
        END_NT     2 :1 -  2:,
        SEC_NF     3 :1 -  3:,
        UWY_NF     4 :1 -  4:,
        UW_NT      5 :1 -  5:,
        SSD_CF     6 :1 -  6:,
        CUR_CF     7 :1 -  7:,
        PRM_M      8 :1 -  8:EN 15/3,
        UNEPRM_M   9 :1 -  9:EN 15/3,
        LOADIN_M  10 :1 - 10:EN 15/3,
        DACOST_M  11 :1 - 11:EN 15/3,
        LOSSES_M  12 :1 - 12:EN 15/3,
        OSIBNR_M  13 :1 - 13:EN 15/3,
        BROKER_M  14 :1 - 14:EN 15/3,
        DIFBRO_M  15 :1 - 15:EN 15/3,
        PROCOM_M  16 :1 - 16:EN 15/3,
        LOSCOM_M  17 :1 - 17:EN 15/3,
        IBNR_M    18 :1 - 18:EN 15/3,
        PRS_CF    19 :1 - 19:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF
/SUMMARIZE TOTAL PRM_M,TOTAL UNEPRM_M,TOTAL LOADIN_M,TOTAL DACOST_M,TOTAL LOSSES_M,TOTAL OSIBNR_M,
           TOTAL BROKER_M,TOTAL DIFBRO_M,TOTAL PROCOM_M,TOTAL LOSCOM_M,TOTAL IBNR_M
exit
EOF
SORT

#[002]
NSTEP=${NJOB}_95
# Deletion of temporary files
#----------------------------------------------------------------------------
LIBEL="Deletion of temporary files"
RMFIL ${DFILT}/${NJOB}_80_${IB}_ESTC1021_RESSUM_TOTGTAA.dat
RMFIL ${DFILT}/${NJOB}_85_${IB}_ESTC1021_RESSUM_DLDGTAA_EBS.dat
RMFIL ${DFILT}/${NJOB}_86_${IB}_SORT_RESSUM_TOTGTAA.dat
RMFIL ${DFILT}/${NJOB}_87_${IB}_SORT_RESSUM_DLDGTAA_EBS.dat

#[002]
NSTEP=${NJOB}_100
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Update of Result summary table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_90_${IB}_SORT_RESSUM_O.dat
BCP_TABLE="BEST..TRESSUM"
BCP

########################################
# Update of TPRMLOA and TLOARAT tables #
########################################

NSTEP=${NJOB}_101
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Update of Loading rates table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EST_FLOARAT}
BCP_TABLE="BEST..TLOARAT"
BCP

NSTEP=${NJOB}_102
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Update of Premium and loading table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${EST_FPRMLOA}
BCP_TABLE="BEST..TPRMLOA"
BCP


########################
##    Manage FCTREST   #
########################

#########################################################
#[011] Start

NSTEP=${NJOB}_110
# FCTREST1 extract types 'A' and 'F' order by CRE_D DESC
#-----------------------------------------------------------------------------
LIBEL="FCTREST1 extract types 'A' and 'F' order by CRE_D DESC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTREST1} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTREST1F_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_FCTREST1A_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:,
        LSTUPD_D  20:1 - 20:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      CRE_D DESC
/CONDITION ADMMODF ADMMOD_CT = "F" AND CLODAT_D = "${PARM0_ICLODAT_D}"
/CONDITION ADMMODA ADMMOD_CT = "A" AND CLODAT_D = "${PARM0_ICLODAT_D}"
/OUTFILE ${SORT_O}
/INCLUDE ADMMODF
/OUTFILE ${SORT_O2}
/INCLUDE ADMMODA
exit
EOF
SORT

NSTEP=${NJOB}_120F
# We keep only the most recent CRE_D record for type 'F'
#-----------------------------------------------------------------------------
LIBEL="We keep only the most recent CRE_D record for type 'F'"
SORT_I=${DFILT}/${NJOB}_110_${IB}_SORT_FCTREST1F_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTFLast_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT
/STABLE
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_130F
# Replace original CRE_D and users info on record type 'F' to generate data to be loaded
#------------------------------------------------------------------------------
LIBEL="Replace original CRE_D and users info on record type 'F' to generate data to be loaded"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120F_${IB}_SORT_FCTRESTFLast_O.dat 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTFLast1_O.dat OVERWRITE 500 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           1:1 -  1:,
        END_NT           2:1 -  2:,
        SEC_NF           3:1 -  3:,
        UWY_NF           4:1 -  4:,
        UW_NT            5:1 -  5:,
        CRE_D            6:1 -  6:,
        PRS_CF           7:1 -  7:,
        ACMTRS_NT        8:1 -  8:,
        SSD_CF           9:1 -  9:,
        ENTAMT_M        13:1 - 13:,
        ADMMOD_CT       15:1 - 15:,
        CLODAT_D        16:1 - 16:,
        F_CTR_NF         1:1 -  1:,       
        F_END_NT         2:1 -  2:,       
        F_SEC_NF         3:1 -  3:,       
        F_UWY_NF         4:1 -  4:,       
        F_UW_NT          5:1 -  5:,       
        F_CRE_D          6:1 -  6:,       
        F_PRS_CF         7:1 -  7:,       
        F_ACMTRS_NT      8:1 -  8:,       
        F_SSD_CF         9:1 -  9:,
        F_CALAMT_M      12:1 - 12:,
        F_RETAMT_M      14:1 - 14:,
        F_ADMMOD_CT     15:1 - 15:,       
        F_CLODAT_D      16:1 - 16:,
        F_ORICOD_LS     17:1 - 17:,
        F_UPDUSR_CF     18:1 - 18:,
        F_CREUSR_CF     19:1 - 19:,
        F_LSTUPD_D      20:1 - 20:,
        F_LSTUPDUSR_CF  21:1 - 21:,
        F_CMT_NT        22:1 - 22:,
        F_INCURREDCI_M  23:1 - 23:,
        COLS1            1:1 -  5:,
        COLS2            7:1 - 11:,
        COLS3           13:1 - 13:,
        COLS4           15:1 - 16:,
        COLS5           18:1 - 18:,
        COLS6           20:1 - 20:,
        COLS7           23:1 - 23:
/joinkeys
         CTR_NF   
        ,END_NT   
        ,SEC_NF   
        ,UWY_NF   
        ,UW_NT    
        ,PRS_CF   
        ,ACMTRS_NT
        ,SSD_CF
        ,ADMMOD_CT
        ,CLODAT_D
/INFILE ${EST_FCTRESTF} 500 1 "~"
/joinkeys
         F_CTR_NF   
        ,F_END_NT   
        ,F_SEC_NF   
        ,F_UWY_NF   
        ,F_UW_NT    
        ,F_PRS_CF   
        ,F_ACMTRS_NT
        ,F_SSD_CF
        ,F_ADMMOD_CT
        ,F_CLODAT_D
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:COLS1
       ,rightside:F_CRE_D
       ,leftside:COLS2
       ,rightside:F_CALAMT_M
       ,leftside:COLS3
       ,rightside:F_RETAMT_M
       ,leftside:COLS4
       ,rightside:F_ORICOD_LS
       ,leftside:COLS5
       ,rightside:F_CREUSR_CF
       ,leftside:COLS6
       ,rightside:F_LSTUPDUSR_CF
       ,rightside:F_CMT_NT
       ,leftside:COLS7
exit
EOF
SORT

NSTEP=${NJOB}_140F
# Sort on lstupd_d desc for type 'F'
#-----------------------------------------------------------------------------
LIBEL="Sort on lstupd_d desc for type 'F'"
SORT_I=${DFILT}/${NJOB}_130F_${IB}_SORT_FCTRESTFLast1_O.dat
SORT_I2=${EST_FCTRESTF0}
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTFLast2_O.dat OVERWRITE 500 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:,
        LSTUPD_D  20:1 - 20: 
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      CRE_D,
      LSTUPD_D DESC
exit
EOF
SORT

NSTEP=${NJOB}_150F
# We keep all history CRE_D distinct record for type 'F'
#-----------------------------------------------------------------------------
LIBEL="We keep all history CRE_D distinct record for type 'F'"
SORT_I=${DFILT}/${NJOB}_140F_${IB}_SORT_FCTRESTFLast2_O.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTFNew_O.dat OVERWRITE 500 1 "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        CLODAT_D  16:1 - 16:,
        ADMMOD_CT 15:1 - 15:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      CRE_D
/STABLE
/SUM
exit
EOF
SORT

NSTEP=${NJOB}_160A
# Get old record type 'A' losted because of new record type 'F'
#------------------------------------------------------------------------------
LIBEL="Get old record type 'A' losted because of new record type 'F'"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTREST0}"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTALast1_O.dat OVERWRITE 500 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF           1:1 -  1:,
        END_NT           2:1 -  2:,
        SEC_NF           3:1 -  3:,
        UWY_NF           4:1 -  4:,
        UW_NT            5:1 -  5:,
        CRE_D            6:1 -  6:,
        PRS_CF           7:1 -  7:,
        ACMTRS_NT        8:1 -  8:,
        SSD_CF           9:1 -  9:,
        ADMMOD_CT       15:1 - 15:,
        CLODAT_D        16:1 - 16:,
        F_CTR_NF         1:1 -  1:,       
        F_END_NT         2:1 -  2:,       
        F_SEC_NF         3:1 -  3:,       
        F_UWY_NF         4:1 -  4:,       
        F_UW_NT          5:1 -  5:,       
        F_CRE_D          6:1 -  6:,       
        F_PRS_CF         7:1 -  7:,       
        F_ACMTRS_NT      8:1 -  8:,       
        F_SSD_CF         9:1 -  9:,
        F_ADMMOD_CT     15:1 - 15:,       
        F_CLODAT_D      16:1 - 16:,
        COLS1            1:1 - 23:
/joinkeys
         CTR_NF   
        ,END_NT   
        ,SEC_NF   
        ,UWY_NF   
        ,UW_NT    
        ,PRS_CF   
        ,ACMTRS_NT
        ,SSD_CF
        ,CLODAT_D
/INFILE ${EST_FCTRESTF} 500 1 "~"
/joinkeys
         F_CTR_NF   
        ,F_END_NT   
        ,F_SEC_NF   
        ,F_UWY_NF   
        ,F_UW_NT    
        ,F_PRS_CF   
        ,F_ACMTRS_NT
        ,F_SSD_CF
        ,F_CLODAT_D
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:COLS1
exit
EOF
SORT

NSTEP=${NJOB}_170A
# Get only old type 'A' record
#-----------------------------------------------------------------------------
LIBEL="Get only old type 'A' record"
SORT_I=${DFILT}/${NJOB}_160A_${IB}_SORT_FCTRESTALast1_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTRESTALast_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS ADMMOD_CT 15:1 - 15:
/CONDITION typeA ADMMOD_CT = "A"
/INCLUDE typeA
exit
EOF
SORT

NSTEP=${NJOB}_175A
# sort on CRE_D DESC
#-----------------------------------------------------------------------------
LIBEL="sort on CRE_D DESC"
SORT_I=${DFILT}/${NJOB}_110_${IB}_SORT_FCTREST1A_O.dat
SORT_I2=${DFILT}/${NJOB}_170A_${IB}_SORT_FCTRESTALast_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTREST_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        CRE_D      6:1 -  6:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        ADMMOD_CT 15:1 - 15:,
        CLODAT_D  16:1 - 16:
/KEYS CLODAT_D,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      ADMMOD_CT,
      CLODAT_D,
      CRE_D DESC
exit
EOF
SORT

NSTEP=${NJOB}_180
# Distinct to have only one CRE_D by key
#-----------------------------------------------------------------------------
LIBEL="Distinct to have only one CRE_D by key"
SORT_I=${DFILT}/${NJOB}_175A_${IB}_SORT_FCTREST_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCTREST_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     1:1 -  1:,
        END_NT     2:1 -  2:,
        SEC_NF     3:1 -  3:,
        UWY_NF     4:1 -  4:,
        UW_NT      5:1 -  5:,
        PRS_CF     7:1 -  7:,
        ACMTRS_NT  8:1 -  8:,
        SSD_CF     9:1 -  9: EN,
        ADMMOD_CT 15:1 - 15:,
        CLODAT_D  16:1 - 16:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF,
      ACMTRS_NT,
      ADMMOD_CT,
      CLODAT_D
/STABLE
/SUM
exit
EOF
SORT

if [ -s ${DFILT}/${NJOB}_150F_${IB}_SORT_FCTRESTFNew_O.dat ]
then

	# Il y a des lignes type 'F' à charger par update

	NSTEP=${NJOB}_190
	# Create Table BTRAV..EST_ESID8000_TCTREST
	#------------------------------------------------------------------------------
	LIBEL='Create Table BTRAV..EST_ESID8000_TCTREST'
	ISQL_BASE=BTRAV
	ISQL_O=${DFILT}/${NSTEP}_${IB}_TAB_EST_ESID8000_TCTREST.log
	ISQL_QRY=${DDDL}/BTRAV_EST_ESID8000_TCTREST.tab
	ISQL
	
	NSTEP=${NJOB}_200
	# BCP in table BTRAV..EST_ESID8000_TCTREST
	#------------------------------------------------------------------------------
	LIBEL="BCP in table BTRAV..EST_ESID8000_TCTREST"
	BCP_WAY="IN"
	BCP_VER=""
	BCP_I=${DFILT}/${NJOB}_150F_${IB}_SORT_FCTRESTFNew_O.dat
	BCP_TABLE="BTRAV..EST_ESID8000_TCTREST"
	BCP

	NSTEP=${NJOB}_210
	# Delete and Insert into TCTREST for type 'F'
	#------------------------------------------------------------------------------
	LIBEL="Delete and Insert into TCTREST for type 'F'"
	ISQL_BASE="BEST"
	ISQL_QRY="delete BEST..TCTREST 
	          from BEST..TCTREST a, BTRAV..EST_ESID8000_TCTREST b
	          where a.CTR_NF = b.CTR_NF
	          and   a.END_NT = b.END_NT
	          and   a.SEC_NF = b.SEC_NF
	          and   a.UWY_NF = b.UWY_Nf
	          and   a.UW_NT  = b.UW_NT
	          and   a.PRS_CF = b.PRS_CF
	          and   a.ACMTRS_NT = b.ACMTRS_NT
	          and   a.SSD_CF = b.SSD_CF
	          and   a.CLODAT_D = b.CLODAT_D
	          and   a.ADMMOD_CT = b.ADMMOD_CT
	          and   convert(varchar, a.CRE_D, 21) = convert(varchar, b.CRE_D, 21)
	          insert BEST..TCTREST
	          select * from BTRAV..EST_ESID8000_TCTREST"
	ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log          
	ISQL

	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===> Save FCTREST Updated"
	gzip -c ${DFILT}/${NJOB}_150F_${IB}_SORT_FCTRESTFNew_O.dat > ${DARCH}/${NCHAIN}_FCTRESTF_${PARM_CRE_D}_updated.dat.gz
	ECHO_LOG "#========================================================================="

fi

#[011] End
#########################################################

#[009]
NSTEP=${NJOB}_220
# Begin isql
#------------------------------------------------------------------------------
LIBEL="delete into TCTREST for PRS_CF 710 type 'A'"
ISQL_BASE="BEST"
ISQL_QRY="delete BEST..TCTREST 
          from BEST..TCTREST a,  BREF..TBATCHSSD b
          where a.SSD_CF=b.SSD_CF
          and   b.BATCHUSER_CF = suser_name()
          and   a.PRS_CF = 710
          and   a.ADMMOD_CT = 'A'
          and   a.clodat_d = '${PARM0_ICLODAT_D}'"  #[010]
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log          
ISQL

#[009]
NSTEP=${NJOB}_230
# Begin bcp par paquets de 100000 lignes
#------------------------------------------------------------------------------
LIBEL="BCP in table BEST..TCTREST"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_180_${IB}_SORT_FCTREST_O.dat
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BEST..TCTREST"
BCPIN_SPECIAL_OPT="-b100000"
BCP

#[009]
NSTEP=${NJOB}_240
# Save loaded data for trace
#---------------------------------------------------------------
LIBEL="Save loaded data for trace"
EXECKSH_MODE=P
gzip -c ${DFILT}/${NJOB}_180_${IB}_SORT_FCTREST_O.dat > ${DSAV}/${SVG}_${NCHAIN}_FCTREST_loaded.dat.gz
gzip -c ${EST_FCTREST0} > ${DSAV}/${SVG}_ESID0060_FCTREST0_IFRS4.dat.gz

#####################
# Update of TCONPAR #
#####################

#[003]
if [ "${EST_ESID8000_COND2}" = "Y" ]
then
	NSTEP=${NJOB}_250
	# Begin isql
	#------------------------------------------------------------------------------
	LIBEL="deletion of the table TCONPAR"
	ISQL_BASE="BEST"
	ISQL_QRY="delete BEST..TCONPAR where ${EST_SORT_CONDITION}"
	ISQL
	
	NSTEP=${NJOB}_260
	# Begin bcp
	#------------------------------------------------------------------------------
	LIBEL="Update table TCONPAR"
	BCP_WAY="IN"
	BCP_VER=""
	BCP_I=${EST_FBESTCONPAR}
	BCP_TABLE="BEST..TCONPAR"
	BCP
	
	NSTEP=${NJOB}_270
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Gzip fichier TCONPAR"
	EXECKSH_MODE=P
	gzip -c ${EST_FBESTCONPAR} > ${DARCH}/${ENV_PREFIX}_ESID8000_FTCONPAR_${PARM0_ICLODAT_D}.dat.gz
fi

JOBEND
