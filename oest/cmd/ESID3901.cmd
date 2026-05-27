#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS
#                                  Generation of a perimeter file
# nom du script SHELL            : ESID3901.cmd
# revision                       : $Revision: 1.1.1.1 $
# date de creation               : 13/07/1999
# auteur                         : ASCOTT
# references des specifications  :
#-----------------------------------------------------------------------------
# description
#
# Input files
#       EST_ARCSTATGTA		DFILP
#       EST_FBSEGEST		DFILP
#       EST_FCESANT		DFILP
#       EST_FCESSION	DFILI
#       EST_FCPLACC		DFILP
#       EST_FCTRGROBO	DFILI
#       EST_FCTRULT	DFILI
#       EST_FCURQUOT		DFILP
#       EST_FDETTRS	DFILI
#       EST_FPLACEMT	DFILI
#       EST_FSOBBLOB		DFILP
#       EST_FPLCANT		DFILP
#       EST_FUNDSTA0	DFILI
#       EST_FTRSLNK	DFILI
#       EST_IADPERICASE		DFILP
#       EST_IADPERIFCT	DFILI
#       EST_TOTGTAA	DFILI
#
# Output files
#       EST_FCTRSTAT		DFILP
#       EST_FSEGSTAT		DFILP
#
# Launch C program ESTC2301 ESTC3601 3603 3604 3605 3606
#
# job launched by ESID3900.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#
#   01/ 06 / 04 J. Ribot ajout test sur COND2 pour garder ou pas les enregistrements
#                        des filiales non presentes dans l'inventaire (SOPT 4935)
#_________________
#MODIFICATION    [002]
#Auteur:         D.GATIBELZA
#Date:           31/01/2011
#Version:        10.2
#Description:    les contrats clos sont automatiquement "supprimés / exclus" de l'univers BO SAR
#                - dans la section SCI - 5 ans après la cloture du dit contrat ==> passer à 20 ans
#[003] 18/04/2012 Roger Cassis :spot:23802 - Mises a jour pour Solvency et [005]
#[004] 05/07/2012 JFVDV :[23390] - SOLVENCY II (correction syntaxe $[CONDGTA}
#[005] 18/04/2012 Roger Cassis :spot:23802 - Solvency
#[006] 04/09/2012 Roger Cassis :spot:24041 - Solvency 2 - gestion parametre SEGTYP_CT
#[007] 21/01/2013 Roger Cassis :spot:24698 - Suppression des fichiers en 1er step
#[008] 06/02/2013 Ph. Pezout   :spot:24818 - Modifications Solvency 2
#[009] 09/12/2013 Roger Cassis :spot:25937 - Modifications Solvency ajout cle bilan dans tri step 107
#[010] 08/12/2014 Florent      :spot:27747 - OM2C ajout trace en gzip
#[011] 18/01/2016 Florent      :spot:29066 formatage du fichier GT
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
OPTION=$1
CRE_D=$2
BALSHTYEA_NF=$3
BALSHTMTH_NF=$4
CLODAT_D=$5
# [003] NORME TAUX = R (Book:IFRS) / T (Best:EBS)
NORME=$6

#[002]
export LIMITINF_D=$((${CRE_D}-200000))

#[003] Affestation nom des fichiers selon la valeur du taux
#[005]
#[006]
if [ "${NORME}" = "IFRS" ]
then
	PRS=710
	EST_FCTRSTAT_OUT=${EST_FCTRSTAT_IFRS}
	EST_FSEGSTAT=${EST_FSEGSTAT_IFRS}
	#CONDGTA=EBSGTA
	CONDGTA='ORICOD_LS != "EBSGTA"'  # and ORICOD_LS != "BESTGTA"'
	SEGTYP_CT=A
else
	PRS=730
	EST_FCTRSTAT_OUT=${EST_FCTRSTAT_EBS}
	EST_FSEGSTAT=${EST_FSEGSTAT_EBS}
	#CONDGTA=rien
	CONDGTA='ORICOD_LS != "BESTGTA"'
	SEGTYP_CT=S
fi  

#[007]
NSTEP=${NJOB}_01
#Last version of ESID2000 files deletion
#-----------------------------------------------------------------------------
RMFIL " 
 `dirname ${EST_FSEGSTAT}`/${NCHAIN}_FSEGSTAT_${NORME}*.dat*
 `dirname ${EST_FCTRSTAT}`/${NCHAIN}_FCTRSTAT_${NORME}*.dat*"

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> PRS..............: ${PRS}"
ECHO_LOG "#===> EST_FCTRSTAT.....: ${EST_FCTRSTAT}"
ECHO_LOG "#===> EST_FCTRSTAT_OUT.: ${EST_FCTRSTAT_OUT}"
ECHO_LOG "#===> EST_FSEGSTAT.....: ${EST_FSEGSTAT}"
ECHO_LOG "#===> CONDGTA..........: ${CONDGTA}"
ECHO_LOG "#========================================================================="

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
SORT_I=${EST_FPLACEMT}
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
SORT_I="${EST_IADPERICASE} 1000 1"
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
/CONDITION CLOSEACC (SECACCSTS_CT EQ "9" AND CRTVRSINC_D >= "${LIMITINF_D}") OR SECACCSTS_CT != "9"
/OUTFILE ${SORT_O}
   /INCLUDE CLOSEACC
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCESSION}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCESSION_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      UW_NT
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
/FIELDS RETCTR_NF 6:1 - 6:,
        RETEND_NT 7:1 - 7: EN,
        RETSEC_NF 8:1 - 8: EN,
        RTY_NF 9:1 - 9: EN,
        RETUW_NT 10:1 - 10: EN
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
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
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: EN,
        SEC_NF 3:1 - 3: EN,
        UWY_NF 4:1 - 4: EN,
        UW_NT 5:1 - 5: EN,
        SHARERI_R 6:1 - 6: EN 1/8,
        SHARERE_R 7:1 - 7: EN 1/8
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
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

NSTEP=${NJOB}_65
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort of cession file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCESANT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCESANT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 6:1 - 6:,
        RETEND_NT 7:1 - 7: EN,
        RETSEC_NF 8:1 - 8: EN,
        RTY_NF 9:1 - 9: EN,
        RETUW_NT 10:1 - 10: EN
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
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
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: EN,
        SEC_NF 3:1 - 3: EN,
        UWY_NF 4:1 - 4: EN,
        UW_NT 5:1 - 5: EN,
        SHARERI_R 6:1 - 6: EN 1/8,
        SHARERE_R 7:1 - 7: EN 1/8
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/SUMMARIZE TOTAL SHARERI_R, TOTAL SHARERE_R
exit
EOF
SORT

NSTEP=${NJOB}_85
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_70_${IB}_ESTC3601_FSHARE_O.dat

NSTEP=${NJOB}_90
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERIFCT perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_IADPERIFCT}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFCT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: EN,
        SEC_NF 3:1 - 3: EN,
        UWY_NF 4:1 - 4: EN,
        UW_NT 5:1 - 5: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_95
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4: EN,
        SEC_NF 5:1 - 5: EN,
        UWY_NF 6:1 - 6: EN,
        UW_NT 7:1 - 7: EN,
        SECACCSTS_CT 77:1 - 77:,
        CRTVRSINC_D 159:1 - 159:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION CLOSEACC (SECACCSTS_CT EQ "9" AND CRTVRSINC_D >= "${LIMITINF_D}") OR SECACCSTS_CT != "9"
/OUTFILE ${SORT_O}
   /INCLUDE CLOSEACC
exit
EOF
SORT

NSTEP=${NJOB}_100
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of the ultimates file"
PRG=ESTC3603
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
OPTION ${OPTION}
SEGTYP_CT ${SEGTYP_CT}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_95_${IB}_SORT_IADPERICASE_O.dat
export ${PRG}_I2=${EST_FBSEGEST}
export ${PRG}_I3=${EST_FCTRGROBO}
export ${PRG}_I4=${EST_FUNDSTA0}
export ${PRG}_I5=${EST_FCTRULT}
export ${PRG}_I6=${EST_FAPR}
export ${PRG}_I7=${EST_FAMPROT}
export ${PRG}_I8=${DFILT}/${NJOB}_90_${IB}_SORT_IADPERIFCT_O.dat
export ${PRG}_I9=${DFILT}/${NJOB}_50_${IB}_SORT_FCEDBIL_O.dat
export ${PRG}_I10=${DFILT}/${NJOB}_80_${IB}_SORT_FCEDANT_O.dat
export ${PRG}_I11=${EST_FSOBBLOB}
export ${PRG}_I12=${EST_FCURQUOT}
export ${PRG}_I13=${EST_FCPLACC}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FULTIMATES_O.dat
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_95_${IB}_SORT_IADPERICASE_O.dat    > ${DFILT}/SAUVEGARDE_${NCHAIN}_95_SORT_IADPERICASE_O.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_SORT_IADPERIFCT_O.dat     > ${DFILT}/SAUVEGARDE_${NCHAIN}_90_SORT_IADPERIFCT_O.dat.gz
gzip -c ${DFILT}/${NJOB}_50_${IB}_SORT_FCEDBIL_O.dat        > ${DFILT}/SAUVEGARDE_${NCHAIN}_50_SORT_FCEDBIL_O.dat.gz
gzip -c ${DFILT}/${NJOB}_80_${IB}_SORT_FCEDANT_O.dat        > ${DFILT}/SAUVEGARDE_${NCHAIN}_80_SORT_FCEDANT_O.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC3603_FULTIMATES_O.dat   > ${DFILT}/SAUVEGARDE_${NCHAIN}_ESTC3603_FULTIMATES_O.dat.gz

NSTEP=${NJOB}_105
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_FCEDBIL_O.dat
RMFIL ${DFILT}/${NJOB}_80_${IB}_SORT_FCEDANT_O.dat
RMFIL ${DFILT}/${NJOB}_90_${IB}_SORT_IADPERIFCT_O.dat
RMFIL ${DFILT}/${NJOB}_95_${IB}_SORT_IADPERICASE_O.dat


#[003] [009]
NSTEP=${NJOB}_107
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Generation du Delta entre le EST_DLGTAAIBNR_IFRS et le EST_DLGTAAIBNR_EBS = postes non transformés"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TOTGTAA} 500"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O.dat 500"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1:,
        ESB_CF             2:1 - 2:,
        BALSHEY_NF         3:1 - 3:,
        BALSHRMTH_NF       4:1 - 4:,
        BALSHRDAY_NF       5:1 - 5:,
        TRNCOD_CF          6:1 - 6:,
        DBLTRNCOD_CF       7:1 - 7:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:,
        OCCYEA_NF         13:1 - 13:,
        ACY_NF            14:1 - 14:,
        SCOSTRMTH_NF      15:1 - 15:,
        SCOENDMTH_NF      16:1 - 16:,
        CLM_NF            17:1 - 17:,
        CUR_CF            18:1 - 18:,
        AMT_M             19:1 - 19:EN 15/3,
        CED_NF            20:1 - 20:,
        BRK_NF            21:1 - 21:,
        PAY_NF            22:1 - 22:,
        KEY_NF            23:1 - 23:,
        RETCTR_NF         24:1 - 24:,
        RETEND_NT         25:1 - 25:,
        RETSEC_NF         26:1 - 26:,
        RTY_NF            27:1 - 27:,
        RETUW_NT          28:1 - 28:,
        RETOCCYEA_NF      29:1 - 29:,
        RETACY_NF         30:1 - 30:,
        RETSCOSTRMTH_NF   31:1 - 31:,
        RETSCOENDMTH_NF   32:1 - 32:,
        RCL_NF            33:1 - 33:,
        RETCUR_CF         34:1 - 34:,
        RETAMT_M          35:1 - 35:EN 15/3,
        PLC_NT            36:1 - 36:,
        RTO_NF            37:1 - 37:,
        INT_NF            38:1 - 38:,
        RETPAY_NF         39:1 - 39:,
        RETKEY_CF         40:1 - 40:,
        RETINTAMT_M       41:1 - 41:EN 15/3,
        ORICOD_LS         57:1 - 57:,
        FIN               42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      TRNCOD_CF,
      BALSHEY_NF
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION TOTGTAA ${CONDGTA}
/OUTFILE ${SORT_O}
/INCLUDE TOTGTAA
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
          RETAMT_MC,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF,
          RETINTAMT_MC,
          FIN
exit
EOF
SORT

#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_107_${IB}_SORT_TOTGTAA_O.dat  >  ${DFILT}/SAUVEGARDE_${NCHAIN}_107_SORT_TOTGTAA_O_${NORME}.gz
#-----------------------------------------------------------------------------

#[003]
NSTEP=${NJOB}_110
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Introduction of accumulation code, ..."
PRG=ESTC3604
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_I2=${EST_ARCSTATGTA}
export ${PRG}_I3=${DFILT}/${NJOB}_107_${IB}_SORT_TOTGTAA_O.dat
export ${PRG}_I4=${EST_FTRSLNK}
export ${PRG}_I5=${EST_FCURQUOT}
export ${PRG}_I6=${EST_FCPLACC}
export ${PRG}_I7=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSTAT_O.dat
EXECPRG

NSTEP=${NJOB}_115
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort of Ultimates file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_ESTC3603_FULTIMATES_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FULTIMATES_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_100_${IB}_ESTC3603_FULTIMATES_O.dat

NSTEP=${NJOB}_125
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount of intermediary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_110_${IB}_ESTC3604_FSTAT_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FSTAT_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        ACMTRS_NT 6:1 - 6:,
        COD_CT 7:1 - 7:,
        AMT_M 8:1 - 8: EN 30/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACMTRS_NT,
      COD_CT
/SUMMARIZE TOTAL AMT_M
exit
EOF
SORT

#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_110_${IB}_ESTC3604_FSTAT_O.dat  >  ${DFILT}/SAUVEGARDE_${NCHAIN}_110_ESTC3604_FSTAT_O_${NORME}.gz
gzip -c ${DFILT}/${NJOB}_125_${IB}_SORT_FSTAT_O.dat      >  ${DFILT}/SAUVEGARDE_${NCHAIN}_125_SORT_FSTAT_O_${NORME}.gz
#-----------------------------------------------------------------------------

NSTEP=${NJOB}_130
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_110_${IB}_ESTC3604_FSTAT_O.dat

NSTEP=${NJOB}_135
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of FCTRSTAT file"
PRG=ESTC3605
export ${PRG}_I1=${DFILT}/${NJOB}_115_${IB}_SORT_FULTIMATES_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_125_${IB}_SORT_FSTAT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FCTRSTAT_O.dat
EXECPRG

NSTEP=${NJOB}_140
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_115_${IB}_SORT_FULTIMATES_O.dat
RMFIL ${DFILT}/${NJOB}_125_${IB}_SORT_FSTAT_O.dat

if [ ${EST_ESID3900_COND2} = "Y" ]
then

	NSTEP=${NJOB}_144
	#-----------------------------------------------------------------------------
	LIBEL="Creation of empty SORT_FCTRSTAT Files"
	EXECKSH "touch ${DFILT}/${NJOB}_145_${IB}_SORT_FCTRSTAT_O.dat"

else

	NSTEP=${NJOB}_145
	# Filter of the FCTRSTAT File
	#------------------------------------------------------------------------------
	LIBEL="Filter of FCTRSTAT file on subsidiaries without closing period demand"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_NOINFILE="YES"
	SORT_I="${EST_FCTRSTAT} 2000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRSTAT_O.dat 2000 1"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF   6:1 -   6:EN, 
        PRS_CF 206:1 - 206:
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} OR ( PRS_CF != "${PRS}" )
/OMIT INVENTAIRE
/COPY
exit
EOF
	SORT

fi

#[003]
NSTEP=${NJOB}_150
# Merge of TL files
#------------------------------------------------------------------------------
LIBEL="Merge of Technical Ledgers files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_135_${IB}_ESTC3605_FCTRSTAT_O.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_145_${IB}_SORT_FCTRSTAT_O.dat 2000 1"
SORT_O="${EST_FCTRSTAT_OUT} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF  1:1 -   1:,
        END_NT  2:1 -   2:,
        SEC_NF  3:1 -   3:,
        UWY_NF  4:1 -   4:,
        UW_NT   5:1 -   5:,
        DEBUT   1:1 - 205:
/KEYS	CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD PRS_CF "${PRS}"
/OUTFILE ${SORT_O}
/REFORMAT DEBUT, PRS_CF
exit
EOF
SORT

NSTEP=${NJOB}_155
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_135_${IB}_ESTC3605_FCTRSTAT_O.dat
RMFIL ${DFILT}/${NJOB}_145_${IB}_SORT_FCTRSTAT_O.dat

NSTEP=${NJOB}_160
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort of FCTRSTAT file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRSTAT_OUT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRSTAT_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 6:1 - 6:,
        ESB_CF 7:1 - 7:,
        SEG_NF 101:1 - 101:,
        UWY_NF 4:1 - 4:,
        EGPCUR_CF 62:1 - 62:,
        SECACCSTS_CT 39:1 - 39:
/KEYS SSD_CF,
      ESB_CF,
      SEG_NF,
      UWY_NF,
      EGPCUR_CF
/CONDITION CLOSEACC SECACCSTS_CT != "9"
/OUTFILE ${SORT_O}
/INCLUDE CLOSEACC
exit
EOF
SORT

#[003]
NSTEP=${NJOB}_165
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of FSEGSTAT file"
PRG=ESTC3606
export ${PRG}_I1=${DFILT}/${NJOB}_160_${IB}_SORT_FCTRSTAT_O.dat
export ${PRG}_O1=${EST_FSEGSTAT}
EXECPRG


NSTEP=${NJOB}_180
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat"

JOBEND
