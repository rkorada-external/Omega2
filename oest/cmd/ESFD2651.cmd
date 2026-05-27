#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - Internal retrocession
# nom du script SHELL           : ESID2551.cmd
# revision                      : $Revision:   1.4  $
# date de creation              : 03/10/1997
# auteur                        : CGI
# references des specifications : ESTIEI23.doc
#-----------------------------------------------------------------------------
# description
#  Generation of acceptance Technical Ledger for retrocessionnaire subsidiaries
#  (EST_DLEIGTAA)
#
# Input files

#       EST_DLDVGTR    DFILI
#       EST_FDETTRS    DFILI
#       EST_FPLC       DFILP
#       EST_FSSDACTR   DFILI
#
# Output files
#       EST_DLEIGTAA   DFILI
#
# Launch C program ESTC2315
#
# job launched by ESID2550.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] 08/10/2012 JF VDV   : [24327] - Reformattage a 41 colonnes du fichier ${EST_DLDVGTR} en sortie du tri
#[02] 26/11/2012 PPEZOUT  :spot:24516 cr�ation, ECHANGES INTERNES POST OMEGA
#[03] 29/05/2013 PPEZOUT  :spot:25171 Modifications Solvency
#[04] 25/06/2014 CDESPRET :spot:26956 Ajout du SUMMURIZE pour supprimer les lignes en doublon
#[05] 02/11/2015 PPEZOUT :spot:29615 EST45 gestion des doubles bouclettes RETRO
#[06] 17/04/2019 R. Cassis :spira:65656 Normalisation fichiers entre IFRS et EBS
#[07] 01/10/2020 JYP :spira:83609 : microAOC : add IB into DFILT files
#[08] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[08] 26/07/2021 : M.NAJI   :. SPIRA 91532  ajout de 100 1 pour le sort du step 10 
#[09] 14/02/2023 :. SPIRA 108791 PROD - Missing Internal Assumed generated from AE booked on Internal Retro /  Prise en compte du fichier des AE  
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job initialisation
JOBINIT

# Get parameters
RETTHRESHOLD=$1
CRE_D=$2
DBCLO_D=$3
TYPEINV=$4
NORME=$5
BOUCLE=$6

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV..................: ${TYPEINV}"
ECHO_LOG "#===> NORME....................: ${NORME}"
ECHO_LOG "#===> RETTHRESHOLD.............: ${RETTHRESHOLD}"
ECHO_LOG "#===> CRE_D....................: ${CRE_D}"
ECHO_LOG "#===> DBCLO_D..................: ${DBCLO_D}"
ECHO_LOG "#===> BOUCLE...................: ${BOUCLE}"
ECHO_LOG "#========================================================================="


RMFIL ${EST_DLEIGTAA}
RMFIL ${EST_DLRIGTAA}

EST_DLDVGTR=${DFILT}/${NCHAIN}_ESFD2663_${BOUCLE}_35_${IB}_SORT_DVGTR_O.dat

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV................: ${TYPEINV}"
ECHO_LOG "#===> NORME..................: ${NORME}"
ECHO_LOG "#===> CLOPRD_D...............: ${CLOPRD}"
ECHO_LOG "#===> DBCLO_D................: ${DBCLO_D}"
ECHO_LOG "#===> CRE_D..................: ${CRE_D}"
ECHO_LOG "#===> EST_DLDVGTR............: ${EST_DLDVGTR}"
ECHO_LOG "#===> EST_DLEIGTAA...........: ${EST_DLEIGTAA}"
ECHO_LOG "#===> EST_DLRIGTAA...........: ${EST_DLRIGTAA}"
ECHO_LOG "#===> EST_FDETTRS............: ${EST_FDETTRS}"
ECHO_LOG "#===> EST_FSSDACTR...........: ${EST_FSSDACTR}"
ECHO_LOG "#===> EST_FPLC...............: ${EST_FPLC}"
ECHO_LOG "#===> EST_IADVPERICASE.......: ${EST_IADVPERICASE}"
ECHO_LOG "#===> ESF_DLSGTR_AE..........: ${ESF_DLSGTR_AE}"
ECHO_LOG "#========================================================================="

#[09] 



NSTEP=${NJOB}_10
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sorting DLDVGTR TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDVGTR}  1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 - 6 :,
        TRNCOD3_CF       6:3 - 6 :6,
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
        PLC_NT          36:1 - 36:
/KEYS RETCTR_NF,
      RETSEC_NF,
      RTY_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_15
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Computing acceptance TL from retrocessionaire subsidiaries...DLDVGTR => DLEIGTAA"
PRG=ESTC2315
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLOPRD_D ${CLOPRD}
DBCLO_D ${DBCLO_D}
CRE_D ${CRE_D}
TYPETRT_CT GT_STD
NORME_CF ${NORME_CF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_GTR_O.dat
export ${PRG}_I2=${EST_FPLC}
export ${PRG}_I3=${EST_FSSDACTR}
export ${PRG}_I4=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLEILGTAA_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O.dat
EXECPRG

gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_GTR_O.dat            > ${DFILT}/${NJOB}_010_${IB}_ESTC2315_GTR.dat.gz
gzip -c ${DFILT}/${NJOB}_15_${IB}_ESTC2315_DLEILGTAA_O.dat  > ${DFILT}/${NJOB}_015_${IB}_ESTC2315_DLEILGTAA_O.dat.gz

NSTEP=${NJOB}_20
# Begin Sort
# [004] Add SUMMARIZE
# [005]
#       Output file need to be SORT by CTR, END, SEC, UWY and UW
#-----------------------------------------------------------------------------
LIBEL="Sorting input DLEILGTAA file + summarize"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_15_${IB}_ESTC2315_DLEILGTAA_O.dat
SORT_I2=${ESF_DLEILGTAA0}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLEILGTAA_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF       8:1 - 8:,
        END_NT       9:1 - 9:,
        SEC_NF      10:1 - 10:,
        UWY_NF      11:1 - 11:,
        UW_NT       12:1 - 12:,
        FILLER1      1:1 - 18:,
        AMT_M       19:1 - 19:EN 18/3,
        FILLER2     20:1 - 48:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      FILLER1,
      FILLER2
/SUMMARIZE  TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FILLER1, AMT_MC, FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_30
# Adding establishment code in Technical Ledger
# NB : it is assumed that the perimeter file is already sorted according to
# contract/endorsement number/section/underwriting year/underwriting order
#-----------------------------------------------------------------------------
LIBEL="Current adding establishment code in TL ...SPLIT DLEIGTAA / DLRIGTAA"
PRG=ESTM7604
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_DLEILGTAA_O.dat
export ${PRG}_I2=${EST_IADVPERICASE}
export ${PRG}_O1=${EST_DLRIGTAA}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_{PRG}_ANOS_O.log
export ${PRG}_O3=${EST_DLEIGTAA}
EXECPRG



cp ${EST_DLEIGTAA}    ${DFILT}/${NSTEP}_${IB}_DLEIGTAA.dat
cp ${EST_DLRIGTAA}    ${DFILT}/${NSTEP}_${IB}_DLRIGTAA.dat

#
#ECHO_LOG ""
#ECHO_LOG "#========================================================================="
#ECHO_LOG "#===> DLRIGTAA Echanges Internes  (OI IntraServers) "
#ECHO_LOG "#===> Nombre de lignes OI total "
#wc -l ${DFILT}/${NJOB}_20_${IB}_SORT_DLEILGTAA_O.dat
#ECHO_LOG "#===> Nombre de lignes OI Intraserveurs "
#wc -l ${EST_DLRIGTAA}
#ECHO_LOG "#===> Nombre de lignes OI Interserveurs "
#wc -l ${EST_DLEIGTAA}
#ECHO_LOG "#========================================================================="
#
#########################
## Erase temporary files #
#########################
#
#NSTEP=${NJOB}_100
#LIBEL="Erase temporary files"
#RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
