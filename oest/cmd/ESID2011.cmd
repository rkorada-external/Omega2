#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
# nom du script SHELL          : ESID2001.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 25/08/1997 - 26/01/2012
# auteur                       : CGI puis Roger Cassis
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 )
#
# Job launched by ESID2000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#      23/05/2005  M.DJELLOULI SPOT 11172-11175
#                              Ajout STEP 67 : ReFormatage du PERICASE avec nouveaux Champs Attendus par ESTC1015
#                                                    (Constitué avec Nouveaux Champs de TFAMCHG)
#                              Ajout STEP 68 : Tri Fichier Temporaire STEP 67
#                              Ajout STEP 69 : PGM ESTM7003.c - Liaison PERICASE Reformaté et EST_TFAMCHG
#                              Modif STEP 70 : Suppression IADPERICASE Temporaire STEP 67 & STEP 68
#                              Modif STEP 320 : Nouveau PERICASE Etendu en Entrée. (STEP 69)
#                              Modif STEP 325 : Suppression Fichier ESTM7003_IADPERICASE_O2 du STEP 69
#      28/07/2005  M.DJELLOULI SPOT 11171 - Calcul Burning Cost - Minimum Premium
#                              Modif STEP 320 : Intégration de FCURQUOT dans le Calcul Burning Cost - Minimum Premium
#      06/04/2006 J Ribot      SPOT 12670  Ajout step115 omit affaires decennales hors France sur le perimetre pour ESTC1010.c
#      07/04/2006 J Ribot      SPOT 11507  Ajout step62 et step156  Fichier GT des mvts comptables pour calcul pb traités terminés
#      18/05/2006 J Ribot      SPOT 11175  Ajout step315 tri Fichier Perimetre etendu
#      19/05/2006 J Ribot      suite SPOT 12670  Ajout I2 step115
#                                            Ajout step122 123 124
#      03/05/2007 J Ribot      SPOT 13142 Modif criteres de selection du sort step115 suppression du test sur PCPRSKTRY_CF = 'FRA'
#      07/01/2010 JF VDV       [16778] - Ajout d'un tri STEP92 sur le fichier SAISPERICASE I7 du step95
#[009] 02/04/2010 D.GATIBELZA  ESTDOM18961 French Cat Nat Levy  the use of the code Fac Reinstatement premiums to record our Cat Nat Premiums in order that we can pay the Levy properly
#[010] 21/05/2010 D.GATIBELZA  ESTDOM19486 Mauvaise imputation des charges sur les Non prop type=3 en cas de PNA
#[011] 27/09/2010 D.GATIBELZA  ESTDOM17226 V10 Bug Commission Estimates
#                              le fichier *NPSAIS_O4.dat passe à *NPSAIS_O4.log pour éviter qu'il ne soit effacé en fin de job
#[006] 17/01/2011 D.GATIBELZA  ESTDOM16142 V10 CALCUL ESTIMATION PNA/ FAR ; correction sur les années de compte inférieures à l'exercice
#[007] 07/02/2011 D.GATIBELZA  1GL
#[008] 16/03/2011 R. Cassis    :spot:21408 pas de zip du fichier EST_IGTAA
#[009] 15/11/2011 Florent      :spot:22890 utilisation de EST_MVTPNAC au step 50
#[010] 18/04/2012 Roger Cassis :spot:23802 - Modifications pour Solvency
#[011] 03/09/2012 Roger Cassis :spot:24041 - Modifications pour Solvency 2 - ajout 14 colonnes
#[012] 19/11/2014 R. Cassis :spot:27747 - OM2C Add 39 columns for multicurrency and future life needs
#===========================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

# Parameters
CRE_D=$1
BALSHTYEA_NF=$2
CLOTYP_CT=$3
SEGTYP_CT=$4
ICLODAT_D=$5
SSDs=$6
SSDVRS_LL=$7
LSTCLODAT_LL=$8
SSDDEL_LL=$9

NSTEP=${NJOB}_05
#Last version of ESID2000 files deletion
#-----------------------------------------------------------------------------
RMFIL "
 `dirname ${EST_FT}`/${NCHAIN}_FT*.dat*
 `dirname ${EST_PERICASESNEM}`/${NCHAIN}_PERICASESNEM*.dat
 `dirname ${EST_DSUMGTAASNEM}`/${NCHAIN}_DSUMGTAASNEM*.dat
 `dirname ${EST_DLCUMGTAAS}`/${NCHAIN}_DLCUMGTAAS*.dat*
 `dirname ${EST_CTRULT02}`/${NCHAIN}_CTRULT02*.dat*
 `dirname ${EST_PERIANO}`/${NCHAIN}_PERIANO*.dat"

#[010]
NSTEP=${NJOB}_10
# Touch fichiers
#------------------------------------------------------------------------------
LIBEL="Touch fichiers DLDGTAA"
EXECKSH_MODE=P
EXECKSH "touch ${EST_DLDGTAA_EBS}"              
EXECKSH "touch ${EST_DLDGTAA_IFRS}"
EXECKSH "touch ${EST_DLDGTAA_E_TRNCODBEST}"
EXECKSH "touch ${EST_DLDGTAA_E_TRNCODEBS}"


############################################
# Recovering premium estimates and Fac UPR #
############################################

#[007] suppression génération fichier PNA FAC
NSTEP=${NJOB}_20
# Split of EST_MVTPNA on accounting transaction code
#[009] Ajout "11104102" pour le fichier *DLGTAFACPRE_O3.dat
#-----------------------------------------------------------------------------
LIBEL="Split of EST_MVTPNA on accounting transaction code"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_MVTPNA}"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLGTAFACPNAE_O1.dat"
SORT_O2="${EST_DLGTAAFPRE} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF   6:1 - 6:,
        CTR_NF      8:1 - 8:,
        END_NT      9:1 - 9:,
        SEC_NF     10:1 - 10:,
        UWY_NF     11:1 - 11:,
        UW_NT      12:1 - 12:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION PNAE TRNCOD_CF EQ "11410002"
/CONDITION PRE TRNCOD_CF EQ "11104002" OR TRNCOD_CF EQ "11107002" OR TRNCOD_CF EQ "11104102"
/OUTFILE ${SORT_O}
/INCLUDE PNAE
/OUTFILE ${SORT_O2}
/INCLUDE PRE
exit
EOF
SORT

#####################
# Perimeters screen #
#####################

NSTEP=${NJOB}_30
#IADPERICASE Perimeter filtering in order to eliminate the internal
# retrocession contracts
#-----------------------------------------------------------------------------
LIBEL="IADPERICASE perimeter filtering in progress ..."
PRG=ESTM1002
export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE_TERM_O.dat
EXECPRG

############################################################
# Comparison of period closing and segmentation perimeters #
############################################################

NSTEP=${NJOB}_40
#Comparison of period closing and segmentation perimeters
#(by the contract grouping file)
#-----------------------------------------------------------------------------
LIBEL="Comparison of period closing process and segmentation perimeters ..."
PRG=ESTM1004
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_ESTM1002_IADPERICASE_O.dat
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_O1=${EST_FCTRGRO1}
export ${PRG}_O2=${EST_PERIANO}
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE.dat
EXECPRG

##############################################################################
# Addition of accumulation transactions codes, complete accounts, interval
# and conversion into the EGPI currency
##############################################################################

NSTEP=${NJOB}_50
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Merge and Sort of EST_DTSTATGTAA and DLGTAFACPNAC"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DTSTATGTAA} 500 1"
SORT_I2="${EST_MVTPNAC} 500 1" #[009]
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DTSTATGTAAF_O.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF          8:1 -  8:,
        END_NT          9:1 -  9:,
        SEC_NF         10:1 - 10:,
        UWY_NF         11:1 - 11:,
        UW_NT          12:1 - 12:,
        ACY_NF         14:1 - 14:,
        SCOSTRMTH_NF   15:1 - 15: EN,
        SCOENDMTH_NF   16:1 - 16: EN,
        OCCYEA_NF      13:1 - 13:,
        CLM_NF         17:1 - 17:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACY_NF, SCOENDMTH_NF, SCOSTRMTH_NF, OCCYEA_NF, CLM_NF
exit
EOF
SORT

NSTEP=${NJOB}_55
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers"
EXECKSH_MODE=P
RMFIL "${EST_DTSTATGTAA}.gz"
EXECKSH "gzip ${EST_DTSTATGTAA}"

NSTEP=${NJOB}_57
LIBEL="Erase DLGTAFACPNAC temporary file"
RMFIL "${DFILT}/${NJOB}_20_${IB}_SORT_DLGTAFACPNAC_O2.dat"

NSTEP=${NJOB}_60
#Introduction of accumulation transactions, complete accounts, and conversion
#in EGPI currency    (spot11507)
#-----------------------------------------------------------------------------
LIBEL="Introduction of accumulation transaction, complete accounting and \
conversion in EGPI currency"
PRG=ESTC1005
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_ESTM1002_IADPERICASE_TERM_O.dat
export ${PRG}_I2=${EST_IADPERIPRMD}
export ${PRG}_I3=${DFILT}/${NJOB}_50_${IB}_SORT_DTSTATGTAAF_O.dat
export ${PRG}_I4=${EST_FCPLACC}
export ${PRG}_I5=${EST_FTRSLNK}
export ${PRG}_I6=${EST_FCURQUOT}
export ${PRG}_I7=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DSUMGTAA_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERIPRMD_O3.dat
export ${PRG}_O4=${EST_PERICASESNEM}
export ${PRG}_O5=${DFILT}/${NSTEP}_${IB}_${PRG}_DSUMGTAASNEM_O5.dat
export ${PRG}_O6=${DFILT}/${NSTEP}_${IB}_${PRG}_DSUMGTAAREC.dat
EXECPRG

NSTEP=${NJOB}_70
#Amount accumulations by contract/endorsement/section/UW year/sequence number/
#transaction code
#-----------------------------------------------------------------------------
LIBEL="Accumulation of acceptation amount by contract"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_60_${IB}_ESTC1005_DSUMGTAA_O1.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAA_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        BALSHEY_NF       3:1 -  3:,
        BALSHRMTH_NF     4:1 -  4:,
        BALSHRDAY_NF     5:1 -  5:,
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
        AMT_M           19:1 - 19:,
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
        RETINTAMT_M     41:1 - 41:,
        ACMTRS_NT       42:1 - 42:,
        ACMAMT_M        43:1 - 43: EN 15/3,
        ACMCUR_CF       44:1 - 44:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, ACMTRS_NT
/SUMMARIZE  TOTAL ACMAMT_M
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
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
          CLM_NF,
          CUR_CF,
          AMT_M,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_M,
          ACMTRS_NT,
          ACMAMT_MC,
          ACMCUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_80
#Introduction of accumulation transactions, complete accounts, and conversion
#in EGPI currency
#-----------------------------------------------------------------------------
LIBEL="Introduction of accumulation transaction, complete accounting and \
conversion in EGPI currency"
PRG=ESTC1005
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_ESTM1002_IADPERICASE_O.dat
export ${PRG}_I2=${EST_IADPERIPRMD}
export ${PRG}_I3=${DFILT}/${NJOB}_50_${IB}_SORT_DTSTATGTAAF_O.dat
export ${PRG}_I4=${EST_FCPLACC}
export ${PRG}_I5=${EST_FTRSLNK}
export ${PRG}_I6=${EST_FCURQUOT}
export ${PRG}_I7=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DSUMGTAA_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERIPRMD_O3.dat
export ${PRG}_O4=${EST_PERICASESNEM}
export ${PRG}_O5=${DFILT}/${NSTEP}_${IB}_${PRG}_DSUMGTAASNEM_O5.dat
export ${PRG}_O6=${DFILT}/${NSTEP}_${IB}_${PRG}_DSUMGTAAREC.dat
EXECPRG

#[012]
NSTEP=${NJOB}_90
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat ESTC1005_PERICASE Extended with TFAMCHG_O"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTC1005_IADPERICASE_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O2.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER1 1:1 - 206:
/DERIVEDFIELD SEPARATEUR13  13"~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,
          SEPARATEUR13
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_100
#Tri du fichier ESTC1005_PERICASE Extended with TFAMCHG_O
#-----------------------------------------------------------------------------
LIBEL="Tri de ESTC1005_PERICASE Extended ... "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_SORT_IADPERICASE_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O2.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS	CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5: EN, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_110
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Liaison Extended_Pericase avec TFAMCHG"
PRG=ESTM7003
export ${PRG}_I1=${EST_FTFAMCHG}
export ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_SORT_IADPERICASE_O2.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE_O2.dat
EXECPRG

NSTEP=${NJOB}_115
# Deletion of temporary files
#-----------------------------------------------------------------------------
LIBEL="Deletion of temporary files"
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_DTSTATGTAAF_O.dat
RMFIL ${DFILT}/${NJOB}_30_${IB}_ESTM1002_IADPERICASE_O.dat

NSTEP=${NJOB}_117
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers"
EXECKSH_MODE=P
RMFIL "${EST_IADPERIPRMD}.gz"
EXECKSH "gzip ${EST_IADPERIPRMD}"

NSTEP=${NJOB}_120
#Introduction of special SNEM Accumulations
#-----------------------------------------------------------------------------
LIBEL="Introduction of special SNEM Accumulations"
PRG=ESTM1010
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_ESTC1005_DSUMGTAASNEM_O5.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DSUMGTAASNEM_O.dat
EXECPRG

NSTEP=${NJOB}_125
# Deletion of temporary files
#-----------------------------------------------------------------------------
LIBEL="Deletion of temporary files"
RMFIL ${DFILT}/${NJOB}_80_${IB}_ESTC1005_DSUMGTAASNEM_O5.dat

##############################################################################
# Calculation of premiums and PPE to be booked - Determination of PPE
# acquisition
##############################################################################

NSTEP=${NJOB}_130
#Tri du fichier FCTRULT par contrat/avenant/section/exercice/numero d'ordre
#-----------------------------------------------------------------------------
LIBEL="FCTRULT file sort in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCTRULT}
SORT_O="${EST_CTRULT02} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF	1:1 - 1:,
        END_NT	2:1 - 2:,
        SEC_NF	3:1 - 3:,
        UWY_NF	4:1 - 4:,
        UW_NT	5:1 - 5:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_140
#Tri du fichier EST_SAISPERICASE par contrat/avenant/section(en char)/exercice/numero d'ordre
#-----------------------------------------------------------------------------
LIBEL="EST_SAISPERICASE file sort in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_SAISPERICASE}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SAISPERICASE_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF	2:1 - 2:,
        END_NT	3:1 - 3:,
        SEC_NF	4:1 - 4:,
        UWY_NF	5:1 - 5:,
        UW_NT	6:1 - 6:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_150
# Calculation of premiums and PPE to be booked
# Determination of PPE acquisition
#[010] ajout du *PNA_O5 en sortie
#[011]
#-----------------------------------------------------------------------------
LIBEL="Generation of work file in progress..."
PRG=ESTM1007
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_ESTC1005_IADPERICASE_O2.dat
export ${PRG}_I2=${DFILT}/${NJOB}_80_${IB}_ESTC1005_DSUMGTAA_O1.dat
export ${PRG}_I3=${DFILT}/${NJOB}_80_${IB}_ESTC1005_IADPERIPRMD_O3.dat
export ${PRG}_I4=${EST_CTRULT02}
export ${PRG}_I5=${EST_DLGTAAFPRE}
export ${PRG}_I6=${DFILT}/${NJOB}_20_${IB}_SORT_DLGTAFACPNAE_O1.dat
export ${PRG}_I7=${DFILT}/${NJOB}_140_${IB}_SORT_SAISPERICASE_O.dat
export ${PRG}_O1=${EST_DLGTAAPRE}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTTR_O2.dat
export ${PRG}_O3=${EST_FTFAC}
export ${PRG}_O4=${DFILI}/${NSTEP}_${IB}_${PRG}_NPSAIS_O4.log
export ${PRG}_O5=${DFILT}/${NSTEP}_${IB}_${PRG}_PNA_O5.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_80_${IB}_ESTC1005_IADPERICASE_O2.dat   > ${DFILT}/SAUVEGARDE_ESID2000_I1_ESTC1005_IADPERICASE_O2.gz
gzip -c ${DFILT}/${NJOB}_80_${IB}_ESTC1005_DSUMGTAA_O1.dat      > ${DFILT}/SAUVEGARDE_ESID2000_I2_ESTC1005_DSUMGTAA_O1.gz
gzip -c ${DFILT}/${NJOB}_80_${IB}_ESTC1005_IADPERIPRMD_O3.dat   > ${DFILT}/SAUVEGARDE_ESID2000_I3_ESTC1005_IADPERIPRMD_O3.gz
gzip -c ${DFILT}/${NJOB}_20_${IB}_SORT_DLGTAFACPNAE_O1.dat      > ${DFILT}/SAUVEGARDE_ESID2000_I6_SORT_DLGTAFACPNAE_O1.gz
gzip -c ${DFILT}/${NJOB}_150_${IB}_${PRG}_DLGTAAPRE_O1.dat       > ${DFILT}/SAUVEGARDE_ESID2000_O1_DLGTAAPRE_O1.gz
gzip -c ${DFILT}/${NJOB}_150_${IB}_${PRG}_FTTR_O2.dat            > ${DFILT}/SAUVEGARDE_ESID2000_O2_FTTR_O2.gz
gzip -c ${DFILI}/${NJOB}_150_${IB}_${PRG}_NPSAIS_O4.log          > ${DFILT}/SAUVEGARDE_ESID2000_O4_NPSAIS_O4log.gz
gzip -c ${DFILT}/${NJOB}_150_${IB}_${PRG}_PNA_O5.dat             > ${DFILT}/SAUVEGARDE_ESID2000_O5_PNA_O5.gz
## ----------------------------------------
## FIN TRACES POUR l'ENVIRONNEMENT DE TEST
## ----------------------------------------

NSTEP=${NJOB}_155
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers"
EXECKSH_MODE=P
RMFIL "${EST_SAISPERICASE}.gz"
EXECKSH "gzip ${EST_SAISPERICASE}"

NSTEP=${NJOB}_157
#Deletion of temporary files
#----------------------------------------------------------------------------
LIBEL="Deletion of temporary files"
RMFIL ${DFILT}/${NJOB}_80_${IB}_ESTC1005_IADPERIPRMD_O3.dat

NSTEP=${NJOB}_160
#Calculation of the first virtual U/W year
#-----------------------------------------------------------------------------
LIBEL="Calculation of the first virtual U/W year in progress..."
PRG=ESTM1008
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_ESTC1005_IADPERICASE_O2.dat
export ${PRG}_I2=${DFILT}/${NJOB}_150_${IB}_ESTM1007_FTTR_O2.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTTR_O1.dat
EXECPRG

NSTEP=${NJOB}_170
#Merge and sort of work file
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of work file in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_160_${IB}_ESTM1008_FTTR_O1.dat
SORT_I2=${DFILT}/${NJOB}_150_${IB}_ESTM1007_FTTR_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTTR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF	2:1 - 2:,
        END_NT	3:1 - 3:,
        SEC_NF	4:1 - 4:,
        UWY_NF	5:1 - 5:,
        UW_NT	6:1 - 6:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_175
#Deletion of FTTR temporary files"
#-----------------------------------------------------------------------------
LIBEL="Deletion of FTTR temporary files"
RMFIL ${DFILT}/${NJOB}_150_${IB}_ESTM1007_FTTR_O2.dat
RMFIL ${DFILT}/${NJOB}_160_${IB}_ESTM1008_FTTR_O1.dat

NSTEP=${NJOB}_180
#IADPERICASE perimeter 01=omit  02=include decennale (SPOT 12670)
#-----------------------------------------------------------------------------
LIBEL="IADPERICASE perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTC1005_IADPERICASE_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_DECENNALE_O2.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        LOB_CF 38:1 - 38:,
        PCPRSKTRY_CF 52:1 - 52:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION DECENNALE (LOB_CF = '04' AND (SSD_CF = 2 OR SSD_CF = 3 OR SSD_CF = 12))
/OUTFILE ${SORT_O}
/OMIT DECENNALE
/OUTFILE ${SORT_O2}
/INCLUDE DECENNALE
exit
EOF
SORT

#PLG 19/10/2009 - Fiche Spot n° 16778: Ajout du fichier des taux de sinistralité des traités non proportionnels
#                                      On retire les traités type comptable 3 du fichier périmètre utilisé dans le
#                                      calcul des PNAs (ESTC1010)
NSTEP=${NJOB}_190
#IADPERICASE perimeter omit ACCADMTYP_CT = 3
#-----------------------------------------------------------------------------
LIBEL="IADPERICASE perimeter ACCADMTYP_CT = 3 AND NAT_CF > 29"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_180_${IB}_SORT_IADPERICASE_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_NP_TYPE3_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        ACCADMTYP_CT 97:1 - 97: EN,
        NAT_CF 49:1 - 49: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION NP_TYPE3 (ACCADMTYP_CT = 3 AND NAT_CF > 29)
/OUTFILE ${SORT_O}
/OMIT NP_TYPE3
/OUTFILE ${SORT_O2}
/INCLUDE NP_TYPE3
exit
EOF
SORT
#Fin PLG 19/10/2009

NSTEP=${NJOB}_200
#UPR Calculation
#-----------------------------------------------------------------------------
LIBEL="UPR calculation in progress..."
PRG=ESTC1010
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_190_${IB}_SORT_IADPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_170_${IB}_SORT_FTTR_O.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAATRPNAE_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAAEPPE_O2.dat
export ${PRG}_O3=${EST_DLGTAARPPE}
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FTTR_O4.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# [006]-------------------------------
gzip -c ${DFILT}/${NJOB}_190_${IB}_SORT_IADPERICASE_O.dat        > ${DFILT}/SAUVEGARDE_ESID2000_I1_SORT_IADPERICASE_O.gz
gzip -c ${DFILT}/${NJOB}_170_${IB}_SORT_FTTR_O.dat               > ${DFILT}/SAUVEGARDE_ESID2000_I2_SORT_FTTR_O.gz
gzip -c ${DFILT}/${NJOB}_200_${IB}_ESTC1010_DLGTAATRPNAE_O1.dat  > ${DFILT}/SAUVEGARDE_ESID2000_ESTC1010_DLGTAATRPNAE_O1.gz
gzip -c ${DFILT}/${NJOB}_200_${IB}_ESTC1010_DLGTAAEPPE_O2.dat    > ${DFILT}/SAUVEGARDE_ESID2000_ESTC1010_DLGTAAEPPE_O2.gz
gzip -c ${DFILT}/${NJOB}_200_${IB}_ESTC1010_FTTR_O4.dat          > ${DFILT}/SAUVEGARDE_ESID2000_ESTC1010_FTTR_O4.gz

#PLG 19/10/2009 - Fiche Spot n° 16778: Ajout du fichier des taux de sinistralité des traités non proportionnels
#                                      On extraie les primes estimées et PNAs calculées pour les traités de type 3
NSTEP=${NJOB}_210
#Synchro FTTR & IADPERICASE DECENNALE
#-----------------------------------------------------------------------------
LIBEL="Synchro FTTR & IADPERICASE_NP_TYPE3"
PRG=ESTC1013
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_190_${IB}_SORT_IADPERICASE_NP_TYPE3_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_170_${IB}_SORT_FTTR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTTR_NP_TYPE3_O.dat
EXECPRG
#Fin PLG 19/10/2009

NSTEP=${NJOB}_220
#Synchro FTTR & IADPERICASE DECENNALE
#-----------------------------------------------------------------------------
LIBEL="Synchro FTTR & IADPERICASE_DECENNALE"
PRG=ESTC1013
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_180_${IB}_SORT_IADPERICASE_DECENNALE_O2.dat
export ${PRG}_I2=${DFILT}/${NJOB}_170_${IB}_SORT_FTTR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTTR_DECENNALE_O1.dat
EXECPRG

NSTEP=${NJOB}_230
#Merge and sort of work file
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of work file in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_200_${IB}_ESTC1010_FTTR_O4.dat
SORT_I2=${DFILT}/${NJOB}_220_${IB}_ESTC1013_FTTR_DECENNALE_O1.dat
#PLG 19/10/2009 - Fiche Spot n° 16778: Ajout du fichier des taux de sinistralité des traités non proportionnels
SORT_I3=${DFILT}/${NJOB}_210_${IB}_ESTC1013_FTTR_NP_TYPE3_O.dat
#Fin PLG 19/10/2009
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTTR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF	2:1 - 2:,
        END_NT	3:1 - 3:,
        SEC_NF	4:1 - 4:,
        UWY_NF	5:1 - 5:,
        UW_NT	6:1 - 6:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_235
#Deletion of FTTR temporary file"
RMFIL ${DFILT}/${NJOB}_180_${IB}_SORT_IADPERICASE_O.dat
RMFIL ${DFILT}/${NJOB}_180_${IB}_SORT_IADPERICASE_DECENNALE_O2.dat
RMFIL ${DFILT}/${NJOB}_200_${IB}_ESTC1010_FTTR_O4.dat
RMFIL ${DFILT}/${NJOB}_220_${IB}_ESTC1013_FTTR_DECENNALE_O1.dat
RMFIL ${DFILT}/${NJOB}_190_${IB}_SORT_IADPERICASE_O.dat
RMFIL ${DFILT}/${NJOB}_190_${IB}_SORT_IADPERICASE_NP_TYPE3_O.dat

#PLG 19/10/2009 - Fiche Spot n° 16778: Ajout du fichier des taux de sinistralité des traités non proportionnels
#[011]
NSTEP=${NJOB}_240
# Filter void subsidiaries and units from treaties UPR file
#-----------------------------------------------------------------------------
LIBEL="Filter void subsidiaries and units from treaties UPR file in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_200_${IB}_ESTC1010_DLGTAATRPNAE_O1.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAATRPNAE_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAATRPNAE_O2.log
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF  1:1 - 1:,
        ESB_CF  2:1 - 2:,
        CTR_NF	8:1 - 8:,
        END_NT	9:1 - 9:,
        SEC_NF	10:1 - 10:,
        UWY_NF	11:1 - 11:,
        UW_NT	12:1 - 12:,
        DEBUT   1:1 - 41:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD AJOUT14COLS "~~~~~~~~~~~~~~~GTA"
/CONDITION FILIALE_ETAB_NUL (SSD_CF EQ "0" OR ESB_CF EQ "0")
/OUTFILE ${SORT_O}
/REFORMAT DEBUT, AJOUT14COLS
/OMIT FILIALE_ETAB_NUL
/OUTFILE ${SORT_O2}
/INCLUDE FILIALE_ETAB_NUL
exit
EOF
SORT

NSTEP=${NJOB}_250
# Filter void subsidiaries and units from treaties PPE file
#-----------------------------------------------------------------------------
LIBEL="Filter void subsidiaries and units from treaties PPE file in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_200_${IB}_ESTC1010_DLGTAAEPPE_O2.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAAEPPE_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAAEPPE_O2.log
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF  1:1 - 1:,
        ESB_CF  2:1 - 2:,
        CTR_NF	8:1 - 8:,
        END_NT	9:1 - 9:,
        SEC_NF	10:1 - 10:,
        UWY_NF	11:1 - 11:,
        UW_NT	12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION FILIALE_ETAB_NUL (SSD_CF EQ "0" OR ESB_CF EQ "0")
/OUTFILE ${SORT_O}
/OMIT FILIALE_ETAB_NUL
/OUTFILE ${SORT_O2}
/INCLUDE FILIALE_ETAB_NUL
exit
EOF
SORT

NSTEP=${NJOB}_260
# Filter void subsidiaries and units from treaties PPW file
#-----------------------------------------------------------------------------
LIBEL="Filter void subsidiaries and units from treaties PPW file in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLGTAARPPE}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAARPPE_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAARPPE_O2.log
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF  1:1 - 1:,
        ESB_CF  2:1 - 2:,
        CTR_NF	8:1 - 8:,
        END_NT	9:1 - 9:,
        SEC_NF	10:1 - 10:,
        UWY_NF	11:1 - 11:,
        UW_NT	12:1 - 12:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION FILIALE_ETAB_NUL (SSD_CF EQ "0" OR ESB_CF EQ "0")
/OUTFILE ${SORT_O}
/OMIT FILIALE_ETAB_NUL
/OUTFILE ${SORT_O2}
/INCLUDE FILIALE_ETAB_NUL
exit
EOF
SORT

NSTEP=${NJOB}_270
#Fin PLG 19/10/2009
#Calculation of the Actual & Estimated Premium for SNEM Perimeter
#-----------------------------------------------------------------------------
LIBEL="Calculation of the Actual & Estimated Premium for SNEM Perimeter..."
PRG=ESTC1011
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_PERICASESNEM}
export ${PRG}_I2=${DFILT}/${NJOB}_120_${IB}_ESTM1010_DSUMGTAASNEM_O.dat
export ${PRG}_I3=${EST_DLGTAAPRE}
export ${PRG}_I4=${DFILT}/${NJOB}_250_${IB}_SORT_DLGTAAEPPE_O1.dat
export ${PRG}_I5=${DFILT}/${NJOB}_260_${IB}_SORT_DLGTAARPPE_O1.dat
export ${PRG}_O1=${EST_DSUMGTAASNEM}
EXECPRG

NSTEP=${NJOB}_275
#Deletion of FTTR temporary file"
#-----------------------------------------------------------------------------
LIBEL="Deletion of FTTR temporary file"
RMFIL ${DFILT}/${NJOB}_120_${IB}_ESTM1010_DSUMGTAASNEM_O.dat
RMFIL ${DFILT}/${NJOB}_170_${IB}_SORT_FTTR_O.dat
RMFIL ${DFILT}/${NJOB}_200_${IB}_ESTC1010_DLGTAAEPPE_O2.dat

NSTEP=${NJOB}_280
#Filter of DLGTAFACPNAE
#-----------------------------------------------------------------------------
LIBEL="Filter of DLGTAFACPNAE"
PRG=ESTC1027
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_ESTC1005_IADPERICASE_O2.dat
export ${PRG}_I2=${DFILT}/${NJOB}_20_${IB}_SORT_DLGTAFACPNAE_O1.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAFACPNAE_O1.dat
EXECPRG

#[011]
NSTEP=${NJOB}_290
# Add OneGL 14 columns
#-----------------------------------------------------------------------------
LIBEL="Add OneGL 14 columns"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_150_${IB}_ESTM1007_PNA_O5.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PNA_O5.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DEBUT   1:1 - 41:
/DERIVEDFIELD AJOUT14COLS "~~~~~~~~~~~~~~~GTA"
/OUTFILE ${SORT_O}
/COPY
/REFORMAT DEBUT, AJOUT14COLS
exit
EOF
SORT

#[011]
NSTEP=${NJOB}_300
# merge for facultatives & treaties UPR files
#[010] Ajout fichier I3
#-----------------------------------------------------------------------------
LIBEL="TL merge for facultatives & treaties UPR in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_280_${IB}_ESTC1027_DLGTAFACPNAE_O1.dat
SORT_I2=${DFILT}/${NJOB}_240_${IB}_SORT_DLGTAATRPNAE_O1.dat
SORT_I3=${DFILT}/${NJOB}_290_${IB}_SORT_PNA_O5.dat
SORT_O="${EST_DLGTAATFPNAE} OVERWRITE"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF  8:1 -  8:,
        END_NT  9:1 -  9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT  12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_305
#Deletion of temporary files
#----------------------------------------------------------------------------
LIBEL="Deletion of DLGTAFACPNAE temporary file"
RMFIL ${DFILT}/${NJOB}_20_${IB}_SORT_DLGTAFACPNAE_O1.dat
RMFIL ${DFILT}/${NJOB}_280_${IB}_ESTC1027_DLGTAFACPNAE_O1.dat


#####################################
# Determination of earned premium   #
#####################################

NSTEP=${NJOB}_310
#TL Merge and Sort for facultatives & treaties UPR, PPE and PPW
#-----------------------------------------------------------------------------
LIBEL="TL Merge & Sort for facultatives & treaties UPR, \
PPE and PPW in progress"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLGTAATFPNAE}
SORT_I2=${DFILT}/${NJOB}_250_${IB}_SORT_DLGTAAEPPE_O1.dat
SORT_I3=${DFILT}/${NJOB}_260_${IB}_SORT_DLGTAARPPE_O1.dat
SORT_O=${EST_DLGTAAPNAE}
INPUT_TEXT ${SORT_CMD} <<EOF

/FIELDS	CTR_NF	8:1 - 8:,
	END_NT	9:1 - 9:,
	SEC_NF	10:1 - 10:,
	UWY_NF	11:1 - 11:,
	UW_NT	12:1 - 12:

/KEYS	CTR_NF,
	END_NT,
	SEC_NF,
	UWY_NF,
	UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_320
#Amount accumulations by contract/endorsement/section/UW year/sequence number/
#transaction code
#-----------------------------------------------------------------------------
LIBEL="Accumulation of acceptation amount by contract"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_80_${IB}_ESTC1005_DSUMGTAA_O1.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAA_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF		1:1 - 1:,
        ESB_CF		2:1 - 2:,
        BALSHEY_NF	3:1 - 3:,
        BALSHRMTH_NF	4:1 - 4:,
        BALSHRDAY_NF	5:1 - 5:,
        TRNCOD_CF	6:1 - 6:,
        DBLTRNCOD_CF	7:1 - 7:,
        CTR_NF		8:1 - 8:,
        END_NT		9:1 - 9:,
        SEC_NF		10:1 - 10:,
        UWY_NF		11:1 - 11:,
        UW_NT		12:1 - 12:,
        OCCYEA_NF	13:1 - 13:,
        ACY_NF		14:1 - 14:,
        SCOSTRMTH_NF	15:1 - 15:,
        SCOENDMTH_NF	16:1 - 16:,
        CLM_NF		17:1 - 17:,
        CUR_CF		18:1 - 18:,
        AMT_M		19:1 - 19:,
        CED_NF		20:1 - 20:,
        BRK_NF		21:1 - 21:,
        PAY_NF		22:1 - 22:,
        KEY_NF		23:1 - 23:,
        RETCTR_NF	24:1 - 24:,
        RETEND_NT	25:1 - 25:,
        RETSEC_NF	26:1 - 26:,
        RTY_NF		27:1 - 27:,
        RETUW_NT	28:1 - 28:,
        RETOCCYEA_NF	29:1 - 29:,
        RETACY_NF	30:1 - 30:,
        RETSCOSTRMTH_NF	31:1 - 31:,
        RETSCOENDMTH_NF	32:1 - 32:,
        RCL_NF		33:1 - 33:,
        RETCUR_CF	34:1 - 34:,
        RETAMT_M	35:1 - 35:,
        PLC_NT		36:1 - 36:,
        RTO_NF		37:1 - 37:,
        INT_NF		38:1 - 38:,
        RETPAY_NF	39:1 - 39:,
        RETKEY_CF	40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        ACMTRS_NT	42:1 - 42:,
        ACMAMT_M	43:1 - 43: EN 15/3,
        ACMCUR_CF	44:1 - 44:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACMTRS_NT
/SUMMARIZE  TOTAL ACMAMT_M
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
         ESB_CF,
         BALSHEY_NF,
         BALSHRMTH_NF,
         BALSHRDAY_NF,
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
         CLM_NF,
         CUR_CF,
         AMT_M,
         CED_NF,
         BRK_NF,
         PAY_NF,
         KEY_NF,
         RETCTR_NF,
         RETEND_NT,
         RETSEC_NF,
         RTY_NF,
         RETUW_NT,
         RETOCCYEA_NF,
         RETACY_NF,
         RETSCOSTRMTH_NF,
         RETSCOENDMTH_NF,
         RCL_NF,
         RETCUR_CF,
         RETAMT_M,
         PLC_NT,
         RTO_NF,
         INT_NF,
         RETPAY_NF,
         RETKEY_CF,
         RETINTAMT_M,
         ACMTRS_NT,
         ACMAMT_MC,
         ACMCUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_330
#Amount accumulations by contract/endorsement/section/UW year/sequence number/
#transaction code
#-----------------------------------------------------------------------------
LIBEL="Accumulation of acceptation amount by contract (REC)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_320_${IB}_SORT_DLCUMGTAA_O.dat
SORT_I2=${DFILT}/${NJOB}_70_${IB}_SORT_DLCUMGTAA_O.dat
SORT_O="${EST_DLCUMGTAA} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 - 1:,
        ESB_CF           2:1 - 2:,
        BALSHEY_NF       3:1 - 3:,
        BALSHRMTH_NF     4:1 - 4:,
        BALSHRDAY_NF     5:1 - 5:,
        TRNCOD_CF        6:1 - 6:,
        DBLTRNCOD_CF     7:1 - 7:,
        CTR_NF           8:1 - 8:,
        END_NT           9:1 - 9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:,
        SCOENDMTH_NF     16:1 - 16:,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:,
        RETSCOENDMTH_NF  32:1 - 32:,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43: EN 15/3,
        ACMCUR_CF        44:1 - 44:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACMTRS_NT
exit
EOF
SORT

NSTEP=${NJOB}_340
#Amount accumulations by contract/endorsement/section/UW year/sequence number/
#transaction code
#-----------------------------------------------------------------------------
LIBEL="Accumulation of acceptation amount by contract (REC)"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_80_${IB}_ESTC1005_DSUMGTAAREC.dat
SORT_O="${EST_DLCGTAAREC} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF

/FIELDS SSD_CF		1:1 - 1:,
        ESB_CF		2:1 - 2:,
        BALSHEY_NF	3:1 - 3:,
        BALSHRMTH_NF	4:1 - 4:,
        BALSHRDAY_NF	5:1 - 5:,
        TRNCOD_CF	6:1 - 6:,
        DBLTRNCOD_CF	7:1 - 7:,
        CTR_NF		8:1 - 8:,
        END_NT		9:1 - 9:,
        SEC_NF		10:1 - 10:,
        UWY_NF		11:1 - 11:,
        UW_NT		12:1 - 12:,
        OCCYEA_NF	13:1 - 13:,
        ACY_NF		14:1 - 14:,
        SCOSTRMTH_NF	15:1 - 15:,
        SCOENDMTH_NF	16:1 - 16:,
        CLM_NF		17:1 - 17:,
        CUR_CF		18:1 - 18:,
        AMT_M		19:1 - 19:,
        CED_NF		20:1 - 20:,
        BRK_NF		21:1 - 21:,
        PAY_NF		22:1 - 22:,
        KEY_NF		23:1 - 23:,
        RETCTR_NF	24:1 - 24:,
        RETEND_NT	25:1 - 25:,
        RETSEC_NF	26:1 - 26:,
        RTY_NF		27:1 - 27:,
        RETUW_NT	28:1 - 28:,
        RETOCCYEA_NF	29:1 - 29:,
        RETACY_NF	30:1 - 30:,
        RETSCOSTRMTH_NF	31:1 - 31:,
        RETSCOENDMTH_NF	32:1 - 32:,
        RCL_NF		33:1 - 33:,
        RETCUR_CF	34:1 - 34:,
        RETAMT_M	35:1 - 35:,
        PLC_NT		36:1 - 36:,
        RTO_NF		37:1 - 37:,
        INT_NF		38:1 - 38:,
        RETPAY_NF	39:1 - 39:,
        RETKEY_CF	40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        ACMTRS_NT	42:1 - 42:,
        ACMAMT_M	43:1 - 43: EN 15/3,
        ACMCUR_CF	44:1 - 44:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACMTRS_NT
/SUMMARIZE  TOTAL ACMAMT_M
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
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
          CLM_NF,
          CUR_CF,
          AMT_M,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_M,
          ACMTRS_NT,
          ACMAMT_MC,
          ACMCUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_350
#Composition of a file of all the identifiers in order to calculate
#the Earned Premium
#-----------------------------------------------------------------------------
LIBEL="recovering of all the keys for the calculation of earned premium"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_320_${IB}_SORT_DLCUMGTAA_O.dat
SORT_I2=${EST_DLGTAAPRE}
SORT_I3=${EST_DLGTAAPNAE}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_IDENT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS	CTR_NF	8:1 - 8:,
         END_NT	9:1 - 9:,
         SEC_NF	10:1 - 10:,
         UWY_NF	11:1 - 11:,
         UW_NT	12:1 - 12:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/SUM
/REFORMAT CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_360
#Calculation of the Earned Premium
#-----------------------------------------------------------------------------
LIBEL="Calculation of the Earned Premium in progress..."
PRG=ESTM1006
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_350_${IB}_SORT_IDENT_O.dat
export ${PRG}_I2=${EST_DLGTAAPRE}
export ${PRG}_I3=${EST_DLGTAAPNAE}
export ${PRG}_I4=${DFILT}/${NJOB}_320_${IB}_SORT_DLCUMGTAA_O.dat
export ${PRG}_O1=${EST_DLGTAAPA}
EXECPRG


#############################################################
# Calculation of losses and IBNR ( Set 6 encapsulation  )   #
#############################################################

NSTEP=${NJOB}_370
#TL merge and sort between earned premium et accumulation transactions at
# contract/endorsement/section/UW year/sequence number/occurence year
#-----------------------------------------------------------------------------
LIBEL="TL merge and sort in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_80_${IB}_ESTC1005_DSUMGTAA_O1.dat
SORT_I2=${EST_DLGTAAPA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTFUSION_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS	CTR_NF		8:1 - 8:,
         END_NT		9:1 - 9:,
         SEC_NF		10:1 - 10:,
         UWY_NF		11:1 - 11:,
         UW_NT		12:1 - 12:,
         OCCYEA_NF	13:1 - 13:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      OCCYEA_NF
exit
EOF
SORT

NSTEP=${NJOB}_375
# DSUMGTAA temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="DSUMGTAA temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_80_${IB}_ESTC1005_DSUMGTAA_O1.dat
RMFIL ${DFILT}/${NJOB}_70_${IB}_SORT_DLCUMGTAA_O.dat

NSTEP=${NJOB}_380
#Accumulation of TL work file on ACY_NF, SCOSTRMTH_NF et SCOSTRMTH_NF of
#accumulation transactions 20000, -20000, -20030 and 01002 with segment
#addition
#-----------------------------------------------------------------------------
LIBEL="Accumulation of TL amounts in progress..."
PRG=ESTC0601
export ${PRG}_I1=${DFILT}/${NJOB}_370_${IB}_SORT_GTFUSION_O.dat
export ${PRG}_I2=${EST_FCTRGRO1}
export ${PRG}_O1=${EST_DLCGTAA}
EXECPRG

NSTEP=${NJOB}_385
# GTFUSION temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="GTFUSION temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_370_${IB}_SORT_GTFUSION_O.dat

NSTEP=${NJOB}_390
#FLABOCY file sort by Segment/UW Year/Occurence Year
#-----------------------------------------------------------------------------
LIBEL="FLABOCY file sort in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FLABOCY}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LABOCY_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SEG_NF		4:1 - 4:,
        UWY_NF		5:1 - 5:,
        OCCYEA_NF	7:1 - 7:
/KEYS	SEG_NF,
      UWY_NF,
      OCCYEA_NF
exit
EOF
SORT

NSTEP=${NJOB}_395
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers"
EXECKSH_MODE=P
RMFIL ${EST_FLABOCY}.gz
EXECKSH "gzip ${EST_FLABOCY}"

NSTEP=${NJOB}_400
#GTCUMUL file sort by Segment/UW Year/Occurence Year/CTR/END/SEC/UW
#-----------------------------------------------------------------------------
LIBEL="GTCUMUL file sort in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLCGTAA}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTCUMUL_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SEG_NF		10:1 - 10:,
        UWY_NF		4:1 - 4:,
        OCCYEA_NF	6:1 - 6:
/KEYS	SEG_NF,
      UWY_NF,
      OCCYEA_NF
exit
EOF
SORT

NSTEP=${NJOB}_410
#Calculation of accounting claim by Segment/UW year/OCC year/
#-----------------------------------------------------------------------------
LIBEL="Calculation of accounting claim by Segment/UW Year/OCC year in progress..."
PRG=ESTC0608
export ${PRG}_I1=${DFILT}/${NJOB}_400_${IB}_SORT_GTCUMUL_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_390_${IB}_SORT_LABOCY_O.dat
export ${PRG}_O1=${EST_LABOCY1}
EXECPRG

NSTEP=${NJOB}_415
# LABOCY temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="LABOCY temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_390_${IB}_SORT_LABOCY_O.dat

NSTEP=${NJOB}_420
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort of working file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_230_${IB}_SORT_FTTR_O.dat
SORT_O="${EST_FTTR_PRM} OVERWRITE"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF		2:1 - 2:,
        END_NT		3:1 - 3:,
        SEC_NF		4:1 - 4:,
        UWYDIS_NF	10:1 - 10:,
        UW_NT		6:1 - 6:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWYDIS_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_425
# FTTR temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="FTTR temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_230_${IB}_SORT_FTTR_O.dat

NSTEP=${NJOB}_430
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Contract selection on claim, accounting periods undistinguished"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_320_${IB}_SORT_DLCUMGTAA_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLCUMGTAAS_O.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS ACMTRS_NT 42:1 - 42:
/CONDITION POSTESCUM ACMTRS_NT EQ "20000" or ACMTRS_NT EQ "-20000" or
		     ACMTRS_NT EQ "-20030"
/INCLUDE POSTESCUM
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_440
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Contract selection on claim, accounting periods undistinguished"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_430_${IB}_SORT_DLCUMGTAAS_O.dat
SORT_O="${EST_DLCUMGTAAS} OVERWRITE"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        ACMTRS_NT 42:1 - 42:,
        ACMAMT_M 43:1 - 43:EN 15/3,
        ACMCUR_CF 44:1 - 44:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/SUMMARIZE TOTAL ACMAMT_M
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
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
          CLM_NF,
          CUR_CF,
          AMT_M,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_M,
          ACMTRS_NT,
          ACMAMT_MC,
          ACMCUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_445
# DLCUMGTAAS temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="DLCUMGTAAS temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_430_${IB}_SORT_DLCUMGTAAS_O.dat

# Supprime car plus utilise
#NSTEP=${NJOB}_315
#NSTEP=${NJOB}_450
##Tri du fichier ESTC1005_PERICASE Extended with TFAMCHG_O
##-----------------------------------------------------------------------------
#LIBEL="Tri de ESTC1005_PERICASE Extended ... "
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_110_${IB}_ESTM7003_IADPERICASE_O2.dat 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O2.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS	CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
#/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
#exit
#EOF
#SORT

NSTEP=${NJOB}_455
# IADPERIFR perimeter deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion ..."
RMFIL ${DFILT}/${NJOB}_110_${IB}_ESTM7003_IADPERICASE_O2.dat

#PHP ce step doit être dans le ESID2001, puisque le step 155 est dans le ESID2001
NSTEP=${NJOB}_460
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Selection TL records with loading accumulation transaction"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NCHAIN}_ESID2001_320_${IB}_SORT_DLCUMGTAA_O.dat
SORT_O="${EST_DCGTAALOA} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS	CTR_NF          8:1 -  8:,
         END_NT          9:1 -  9:,
         SEC_NF         10:1 - 10:,
         UWY_NF         11:1 - 11:,
         UW_NT          12:1 - 12:,
         ACMTRS_NT      42:1 - 42:,
         ACMTRS2_NT     42:3 - 42:3,
         ACMTRS5_NT     42:5 - 42:5
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION POSTECUM
	(
	  (
	    ACMTRS2_NT EQ "1" or ACMTRS2_NT EQ "2" or
	    ACMTRS2_NT EQ "3" or ACMTRS2_NT EQ "4"
	  ) and
	  ACMTRS5_NT EQ "0"
	) or ACMTRS_NT EQ "19000"
/INCLUDE POSTECUM
exit
EOF
SORT

NSTEP=${NJOB}_470
# PHP ce step devrait être dans le ESID2001
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount by contract and accounting period"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_250_${IB}_SORT_DLGTAAEPPE_O1.dat
SORT_O="${EST_DLCGTAAEPPE} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS	SSD_CF		1:1 - 1:,
         ESB_CF		2:1 - 2:,
         BALSHEY_NF	3:1 - 3:,
         BALSHRMTH_NF	4:1 - 4:,
         BALSHRDAY_NF	5:1 - 5:,
         TRNCOD_CF	6:1 - 6:,
         DBLTRNCOD_CF	7:1 - 7:,
         CTR_NF		8:1 - 8:,
         END_NT		9:1 - 9:,
         SEC_NF		10:1 - 10:,
         UWY_NF		11:1 - 11:,
         UW_NT		12:1 - 12:,
         OCCYEA_NF	13:1 - 13:,
         ACY_NF		14:1 - 14:,
         SCOSTRMTH_NF	15:1 - 15:,
         SCOENDMTH_NF	16:1 - 16:,
         CLM_NF		17:1 - 17:,
         CUR_CF		18:1 - 18:,
         AMT_M		19:1 - 19:EN 15/3,
         CED_NF		20:1 - 20:,
         BRK_NF		21:1 - 21:,
         PAY_NF		22:1 - 22:,
         KEY_NF		23:1 - 23:,
         RETCTR_NF	24:1 - 24:,
         RETEND_NT	25:1 - 25:,
         RETSEC_NF	26:1 - 26:,
         RTY_NF		27:1 - 27:,
         RETUW_NT	28:1 - 28:,
         RETOCCYEA_NF	29:1 - 29:,
         RETACY_NF	30:1 - 30:,
         RETSCOSTRMTH_NF	31:1 - 31:,
         RETSCOENDMTH_NF	32:1 - 32:,
         RCL_NF		33:1 - 33:,
         RETCUR_CF	34:1 - 34:,
         RETAMT_M	35:1 - 35:,
         PLC_NT		36:1 - 36:,
         RTO_NF		37:1 - 37:,
         INT_NF		38:1 - 38:,
         RETPAY_NF	39:1 - 39:,
         RETKEY_CF	40:1 - 40:,
         RETINTAMT_M 41:1 - 41:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      TRNCOD_CF
/SUMMARIZE  TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          ESB_CF,
          BALSHEY_NF,
          BALSHRMTH_NF,
          BALSHRDAY_NF,
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
          CLM_NF,
          CUR_CF,
          AMT_MC,
          CED_NF,
          BRK_NF,
          PAY_NF,
          KEY_NF,
          RETCTR_NF,
          RETEND_NT,
          RETSEC_NF,
          RTY_NF,
          RETUW_NT,
          RETOCCYEA_NF,
          RETACY_NF,
          RETSCOSTRMTH_NF,
          RETSCOENDMTH_NF,
          RCL_NF,
          RETCUR_CF,
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_M
exit
EOF
SORT

#########################
# Erase temporary files #
#########################

NSTEP=${NJOB}_500
LIBEL="Erase temporary files"
#RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
