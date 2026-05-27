#!/bin/ksh
#=============================================================================
# nom de l'application          : Création Retro Auto
# nom du script SHELL           : ESID3027.cmd
# revision                      : $Revision: 1.0 $
# date de creation              : 23/03/2015
# auteur                        : Julien FONTANA
# references des specifications : SPOT 28559
#-----------------------------------------------------------------------------
# description :
# Création Retro Auto
#
# 2 Passages :
#   Passage N°1 : grille local + RI interserveur
#   Passage N°2 : RI intraserveur suite a closing
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
# [001] 23/03/2015 J.FONTANA : Spot#28559 -> EST24BT
# [002] 31/08/2015 SAS : spot#29283 : perte de previsions dans la grille, et plus de positions cloture dans le GLT
# [003] 13/11/2015 M.MECHRI  :spot:296650:Pool retro
# [004] 12/01/2015 RBE  :spot:30025 Correction Pool retro selon type comptable Retro
# [005] 10/11/2015 R.BEN EZZINE  :spot:29579 Impact Retro EST
# [006] 10/05/2016 R.BEN EZZINE  :spot: : Optimisation ESID2030
# [007] 12/04/2018 S.Behague :spira:60657: Estimations retro dans le cadre de la retro auto : le calcul de la grille doit être mis à jour à chaque traitement closing
# [008] 30/04/2018 H.H Huynh :spira 6027: ajout de la compression de fichier de sortie dans les jobs 95,100,154 pour mieux suivre la trace des fichiers de sortie
# [009] 03/05/2018 H.H Huynh :spira 6027: ajout de la compression de fichier de sortie dans les jobs 153 
# [010] 21/02/2019 S.Behague :REQ.L.02.05: Evolution quarterly
# [011] 15/04/2020 BEL       :spira:86072: Estimation retro - ecrire dans TLIFEST que si y a des changements.
# [012] 30/06/2020 BEL       :spira:88060: Pris en compte de l'assumed family dans le calcul de la retro auto.
# [013] 30/06/2020 BEL       :spira:88060: Ajout des liberations des postes (reserve,ASSTYP=5,Assumed family) pour le calcul de retro auto.
# [014] 05/07/2021 BEL       :spira:82673: Retro intern (Auto) - ecrire dans TLIFEST que si y a des changement.
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3
PASS=$4
CLODAT_D=$5
LIF_ACY_MIN=5
LIF_ACY_MAX=4

# Job Initialisation
JOBINIT

echo "#      ###  PASSAGE ${PASS} ${NJOB} ###"

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> BALSHTYEA_NF.............: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF.............: ${BALSHTMTH_NF}"
ECHO_LOG "#===> CLODAT_D.................: ${CLODAT_D}"
ECHO_LOG "#===> CRE_D....................: ${CRE_D}"
ECHO_LOG "#========================================================================="

# NSTEP=${NJOB}_010
# # Sauvegarde VLIFEST - Used for DEBUG. Comment me before putting me on SVN
# #---------------------------------------------------------------------------
# LIBEL="Save VLIFEST195"
# #gzip -c ${EST_VLIFEST195}   >     ${DFILI}/${NSTEP}_VLIFEST_START_3027_${PASS}${IT}.dat.gz


#premier passge VLIFEST
#deuxieme passage DLRLIFEI
NSTEP=${NJOB}_050
# Splitting VLIFEST in old and new RA 
#------------------------------------------------------------------------------
LIBEL="Splitting VLIFEST in old and new RA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_I2="${EST_LIFESTNOACC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_VLIFEST_woRA${IT}.dat"
SORT_O2="${DFILT}/${NSTEP}_${IB}_VLIFEST_OLD_RA${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ACY_NF        7:1 - 7:,
        ACM_NF        25:1 - 25:EN,
        CRE_D         8:1 - 8:,
        ACMTRS_NT     10:1 - 10:,
        BALSHEY_NF    11:1 - 11:,
        BALSHTMTH_NF  12:1 - 12:EN,
        ORICOD_LS     16:1 - 16:,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/CONDITION RETRO_AUTO ORICOD_LS = "RETRO AUTO"
/OUTFILE ${SORT_O}
/OMIT RETRO_AUTO
/OUTFILE ${SORT_O2}
/INCLUDE RETRO_AUTO
exit
EOF
SORT

#################################################

NSTEP=${NJOB}_85
# Merging of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRV_PERICASE_O${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF 
/OUTFILE  ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_90
# Placements File Sort
#------------------------------------------------------------------------------
LIBEL="Placements File Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FVPLACEMT2} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VPLACEMT_O${IT}.dat"

INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        RETCTR_NF 3:1 - 3:,
        RETSEC_NF 5:1 - 5:,
        RTY_NF    6:1 - 6:,
        CTR_NF    21:1 - 21:,
        SEC_NF    23:1 - 23:,
        UWY_NF    24:1 - 24:
/KEYS 
      RETCTR_NF, 
      RETSEC_NF, 
      RTY_NF
exit
EOF
SORT

NSTEP=${NJOB}_95
# Ajout CTRNAT et ACCTYP dans EST_FVPLACEMT2
#------------------------------------------------------------------------------
LIBEL="Ajout CTRNAT et ACCTYP dans FVPLACEMT2"
PRG=ESTC2098
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_90_${IB}_SORT_VPLACEMT_O${IT}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_85_${IB}_SORT_IRV_PERICASE_O${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FVPLACEMT2_O${IT}.dat
EXECPRG

#gzip -c  ${DFILT}/${NSTEP}_${IB}_${PRG}_FVPLACEMT2_O${IT}.dat  >  ${DFILT}/${NSTEP}_${IB}_${PRG}_FVPLACEMT2_O_${IT}.dat.gz

NSTEP=${NJOB}_100
# Placements File Sort
#------------------------------------------------------------------------------
LIBEL="Placements File Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_ESTC2098_FVPLACEMT2_O${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_VPLACEMT2_O${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF  21:1 - 21:,
        END_NT  22:1 - 22:,
        SEC_NF  23:1 - 23:,
        UWY_NF  24:1 - 24:,
        UW_NT   25:1 - 25:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT 

#gzip -c  ${DFILT}/${NSTEP}_${IB}_SORT_VPLACEMT2_O${IT}.dat  >  ${DFILT}/${NSTEP}_SORT_VPLACEMT2_O_${IT}.dat.gz
#################################################



NSTEP=${NJOB}_150
# ADD END ACCount to VLIFEST
#------------------------------------------------------------------------------
LIBEL="Splitting VLIFEST in old and new RA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE="YES"
SORT_I="${DFILT}/${NJOB}_050_${IB}_VLIFEST_woRA${IT}.dat 1000 1"
SORT_I2="${EST_LIFENDCPT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_VLIFEST_woRA${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ACY_NF        7:1 - 7:,
        ACM_NF        25:1 - 25:EN,
        CRE_D         8:1 - 8:,
        ACMTRS_NT     10:1 - 10:,
        BALSHEY_NF    11:1 - 11:,
        BALSHTMTH_NF  12:1 - 12:EN,
        ORICOD_LS     16:1 - 16:,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/OUTFILE ${SORT_O}

exit
EOF
SORT

####################################################################################

NSTEP=${NJOB}_151
# Creation des lignes pour les bases de calcul 
#------------------------------------------------------------------------------
LIBEL="Creation base de calculs"
PRG=ESTC2099
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_FTRSLNKVRET}
if [[ ${PASS} -eq 1 ]];
then
  export ${PRG}_I2=${DFILT}/${NJOB}_150_${IB}_VLIFEST_woRA${IT}.dat
else
  export ${PRG}_I2=${EST_DLRLIFEP}
fi 
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_VLIFEST_BASES_CALCUL${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_VLIFEST_BASES_INEXISTANT${IT}.dat
EXECPRG

#gzip -c ${DFILT}/${NSTEP}_${IB}_VLIFEST_BASES_CALCUL${IT}.dat > ${DFILT}/${NSTEP}_VLIFEST_BASES_CALCUL_${IT}.dat.gz
#gzip -c ${DFILT}/${NSTEP}_${IB}_VLIFEST_BASES_INEXISTANT${IT}.dat > ${DFILT}/${NSTEP}_VLIFEST_BASES_INEXISTANT_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_150_${IB}_VLIFEST_woRA${IT}.dat > ${DFILT}/${NJOB}_150_VLIFEST_woRA_${IT}.dat.gz

NSTEP=${NJOB}_152
# SUMMARIZE sur le regroupement de la base de calcul
#------------------------------------------------------------------------------
LIBEL="SUMMARIZE sur le regroupement de la base de calcul"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_151_${IB}_VLIFEST_BASES_CALCUL${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_VLIFEST_BASES_CALCUL_SUM${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ACY_NF        7:1 - 7:,
        ACM_NF       25:1 - 25:EN,
        ACMTRS_NT    10:1 - 10:,
        BALSHEY_NF   11:1 - 11:,
        ESTMNT_M     14:1 - 14:EN 15/3,
        GAAP_NF      22:1 - 22:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      BALSHEY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      GAAP_NF
/SUMMARIZE TOTAL ESTMNT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_153
# Splitting VLIFEST in old and new RA 
#------------------------------------------------------------------------------
LIBEL="Splitting VLIFEST in old and new RA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [[ ${PASS} -eq 1 ]];
then
  SORT_I="${DFILT}/${NJOB}_150_${IB}_VLIFEST_woRA${IT}.dat 1000 1"
else
  SORT_I="${EST_DLRLIFEP} 1000 1"
fi 
SORT_I2="${DFILT}/${NJOB}_152_${IB}_VLIFEST_BASES_CALCUL_SUM${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_VLIFEST_woRA_BASE_CALCUL${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ACY_NF        7:1 - 7:,
        ACM_NF        25:1 - 25:EN,
        CRE_D         8:1 - 8:,
        ACMTRS_NT     10:1 - 10:,
        BALSHEY_NF    11:1 - 11:,
        BALSHTMTH_NF  12:1 - 12:EN,
        ORICOD_LS     16:1 - 16:,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT
#gzip -c  ${DFILT}/${NSTEP}_${IB}_VLIFEST_woRA_BASE_CALCUL${IT}.dat  >  ${DFILT}/${NSTEP}_${IB}_VLIFEST_woRA_BASE_CALCUL_${IT}.dat.gz
####################################################################################

#--------------------------#
# [013] START MODIFICATION #
#--------------------------#
# Un cas particulier : calcul des liberations des postes reserve, Assumed family,
# et type association est un 5 pour la retro auto (transformation de poste)
#------------------------------------------------------------------------------
NSTEP=${NJOB}_154A
# filtrer les postes reserve, assumed family, et de ASSOTYPE = 5
#------------------------------------------------------------------------------
LIBEL="Select TRNCOD which are reserve, assumed family and ASSOTYPE == 5"
PRG=ESTC2170
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_SORT_VPLACEMT2_O${IT}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_153_${IB}_VLIFEST_woRA_BASE_CALCUL${IT}.dat
export ${PRG}_I3=${EST_SUBTRSASSO}
export ${PRG}_I4=${EST_SUBTRS}
export ${PRG}_I5=${EST_FTRANSCODE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_woRA_BASE_CALCUL_ASSFA_RESERVE_ASSOTYP5.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_woRA_BASE_CALCUL_notASSFA_RESERVE_ASSOTYP5.dat
EXECPRG


NSTEP=${NJOB}_154B
# Suppression des espaces dans ESTMNT_M
#-----------------------------------------------------------------------------
LIBEL="Supressing white spaces in ESTMNT_M from VLIFEST"
AWK_I=${DFILT}/${NJOB}_154A_${IB}_ESTC2170_VLIFEST_woRA_BASE_CALCUL_ASSFA_RESERVE_ASSOTYP5.dat
AWK_O=${DFILT}/${NJOB}_154B_${IB}_ESTC2170_VLIFEST_woRA_BASE_CALCUL_ASSFA_RESERVE_ASSOTYP5_noSPACE.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
        { gsub(\/ \/,"",\$14); print \$0 }
exit
EOF
AWK


NSTEP=${NJOB}_154C
# Tri du VLIFEST
#------------------------------------------------------------------------------
LIBEL="Sorting \${DFILT}/${NJOB}_154B_${IB}_ESTC2170_is_ASSFA_RESERVE_ASSOTYP5_NO_SPACE.dat for ESTC2164"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_154B_${IB}_ESTC2170_VLIFEST_woRA_BASE_CALCUL_ASSFA_RESERVE_ASSOTYP5_noSPACE.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_VLIFEST_woRA_BASE_CALCUL_ASSFA_RESERVE_ASSOTYP5_noSPACE_SORT.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:EN,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:,
        ACMTRS_NT       10:1 - 10:,
        DETTRNCOD_CF    20:1 - 20:,
        GAAP_NF         22:1 - 22:,
        ACM_NF          25:1 - 25:EN
/KEYS
    CTR_NF,
    END_NT,
    SEC_NF,
    ACY_NF,
    ACM_NF,
    ACMTRS_NT,
    DETTRNCOD_CF,
    UWY_NF,
    UW_NT,
    GAAP_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_154D
# Calcul des liberations de notre scop VLIFEST
#------------------------------------------------------------------------------
LIBEL="Calculation of beginning for selected VLIFEST scop"
PRG=ESTC2164
EMPTY_LIFESTLIB=`CFTMP`
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D $CRE_D
BALSHTYEA $BALSHTYEA_NF
BALSHTMTH_NF $BALSHTMTH_NF
ACY_MIN $LIF_ACY_MIN
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_154C_${IB}_VLIFEST_woRA_BASE_CALCUL_ASSFA_RESERVE_ASSOTYP5_noSPACE_SORT.dat
export ${PRG}_I2=${EMPTY_LIFESTLIB}
export ${PRG}_I3=${EST_SUBTRS}
export ${PRG}_I4=${EST_SUBTRSASSO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFESTLIB${IT}_MAJ.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}${IT}_LOG.dat
EXECPRG


NSTEP=${NJOB}_154E
# Merge and sort VLIFEST, LIFESTLIB
#------------------------------------------------------------------------------
LIBEL="Merge and sort VLIFEST, LIFESTLIB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_153_${IB}_VLIFEST_woRA_BASE_CALCUL${IT}.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_154D_${IB}_ESTC2164_LIFESTLIB${IT}_MAJ.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_VLIFEST_woRA_BASE_CALCUL_LIFESTLIB_SORT${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ACY_NF        7:1 - 7:,
        ACM_NF        25:1 - 25:EN,
        CRE_D         8:1 - 8:,
        ACMTRS_NT     10:1 - 10:,
        BALSHEY_NF    11:1 - 11:,
        BALSHTMTH_NF  12:1 - 12:EN,
        ORICOD_LS     16:1 - 16:,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:
/KEYS
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT
#---------------------------#
# [013] END OF MODIFICATION #
#---------------------------#

NSTEP=${NJOB}_154
# passage 1: Splitting VLIFEST_woRA depending on Syncro
# passage 2: Splitting DLRLIFEP_woRA depending on Syncro
#------------------------------------------------------------------------------
LIBEL="Splitting VLIFEST_woRA depending on Syncro"
PRG=ESTC2135
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
CRE_D ${CRE_D}
BALSHTMTH_NF ${BALSHTMTH_NF}
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_SORT_VPLACEMT2_O${IT}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_154E_${IB}_VLIFEST_woRA_BASE_CALCUL_LIFESTLIB_SORT${IT}.dat
export ${PRG}_I3=${EST_FCURQUOT}
export ${PRG}_I4=${EST_CPLIFDRI}
export ${PRG}_I5=${EST_FACCPAR0}
export ${PRG}_I6=${EST_SUBTRSASSO}
export ${PRG}_I7=${EST_SUBTRSESBPROP}
export ${PRG}_I8=${EST_SUBTRS}
export ${PRG}_I9=${EST_FTRANSCODE} # [012]
export ${PRG}_I10=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_NEW_RA${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_NON_SYCHRO${IT}.dat
EXECPRG

#gzip -c ${DFILT}/${NJOB}_154_${IB}_ESTC2135_VLIFEST_NEW_RA${IT}.dat > ${DFILT}/${NJOB}_154_ESTC2135_VLIFEST_NEW_RA_${PASS}_${IT}.dat.gz
#gzip -c ${EST_LIFENDCPT}                                       > ${DFILT}/${NJOB}_VLIFEST_75_ESTC2035_END_LIFEST_${PASS}_${IT}.dat.gz
#gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_NON_SYCHRO${IT}.dat  > ${DFILT}/${NJOB}_154_ESTC2135_VLIFEST_NON_SYCHRO_${PASS}_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_VPLACEMT2_O${IT}.dat > ${DFILT}/${NJOB}_100_SORT_VPLACEMT2_O_${PASS}_${IT}.dat.gz
#gzip -c ${DFILT}/${NJOB}_153_${IB}_VLIFEST_woRA_BASE_CALCUL${IT}.dat > ${DFILT}/${NJOB}_153_VLIFEST_woRA_BASE_CALCUL_${PASS}_${IT}.dat.gz

NSTEP=${NJOB}_155
# Sorting VLIFEST_woRA into VLIFEST_NEW_RA
#[002]  ajout de la CRE_D
#------------------------------------------------------------------------------
LIBEL="Sorting VLIFEST_woRA into VLIFEST_NEW_RA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_154_${IB}_ESTC2135_VLIFEST_NEW_RA${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_VLIFEST_NO_BASE_CALCUL${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ACY_NF        7:1 - 7:,
        ACM_NF        25:1 - 25:EN,
        CRE_D         8:1 - 8:,
        PRS_CF        9:1 -  9:,
        ACMTRS_NT     10:1 - 10:,
        BALSHEY_NF    11:1 - 11:,
        BALSHTMTH_NF  12:1 - 12:EN,
        ORICOD_LS     16:1 - 16:,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/CONDITION BASE_CALCUL PRS_CF = "50"
/OUTFILE ${SORT_O}
/OMIT BASE_CALCUL
exit
EOF
SORT

NSTEP=${NJOB}_200
# Sorting VLIFEST_woRA into VLIFEST_NEW_RA
#[002]  ajout de la CRE_D
#------------------------------------------------------------------------------
LIBEL="Sorting VLIFEST_woRA into VLIFEST_NEW_RA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_155_${IB}_VLIFEST_NO_BASE_CALCUL${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_VLIFEST_NEW_RA${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ACY_NF        7:1 - 7:,
        ACM_NF        25:1 - 25:EN,
        CRE_D         8:1 - 8:,
        ACMTRS_NT    10:1 - 10:,
        BALSHEY_NF   11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        ESTMNT_M     14:1 - 14:EN 15/3,
        DETTRNCOD_CF 20:1 - 20:,
        GAAP_NF      22:1 - 22:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/SUMMARIZE TOTAL ESTMNT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

#gzip -c ${DFILT}/${NJOB}_200_${IB}_VLIFEST_NEW_RA${IT}.dat > ${DFILT}/${NJOB}_200_VLIFEST_NEW_RA_${PASS}_${IT}.dat.gz


NSTEP=${NJOB}_210
# MAJ VLIFEST_RA
#[002]  deplacement de la step
#------------------------------------------------------------------------------
LIBEL="MAJ VLIFEST_RA"
PRG=ESTC2129
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
CRE_D ${CRE_D}
BALSHTMTH_NF ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_200_${IB}_VLIFEST_NEW_RA${IT}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_050_${IB}_VLIFEST_OLD_RA${IT}.dat
export ${PRG}_I3=${EST_IARVPERICASE4}
export ${PRG}_O=${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_RA_MAJ${IT}.dat
EXECPRG

#gzip -c ${DFILT}/${NJOB}_210_${IB}_${PRG}_VLIFEST_RA_MAJ${IT}.dat > ${DFILT}/${NJOB}_210_VLIFEST_RA_MAJ_${PASS}_${IT}.dat.gz

NSTEP=${NJOB}_220
# [002] 
#------------------------------------------------------------------------------
LIBEL="Sorting VLIFEST_woRA into VLIFEST_NEW_RA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_210_${IB}_ESTC2129_VLIFEST_RA_MAJ${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORTVLIFEST_NEW_RA${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ACY_NF        7:1 - 7:,
        ACM_NF        25:1 - 25:EN,
        CRE_D         8:1 - 8:,
        ACMTRS_NT    10:1 - 10:,
        BALSHEY_NF   11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        ESTMNT_M     14:1 - 14:EN 15/3,
        DETTRNCOD_CF 20:1 - 20:,
        GAAP_NF      22:1 - 22:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/SUMMARIZE TOTAL ESTMNT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_240
# Test UWY depending on ACY
#[002]  deplacement de la step
#------------------------------------------------------------------------------
LIBEL="Test UWY depending on ACY"
PRG=ESTC2127
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHTYEA_NF}
CRE_D ${CRE_D}
BALSHTMTH_NF ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IRVPERICASE0}
export ${PRG}_I2=${DFILT}/${NJOB}_200_${IB}_VLIFEST_NEW_RA${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_VLIFEST_NEW_RA${IT}.dat
EXECPRG

#gzip -c ${DFILT}/${NJOB}_240_${IB}_${PRG}_VLIFEST_NEW_RA${IT}.dat > ${DFILT}/${NJOB}_240_VLIFEST_NEW_RA_${PASS}_${IT}.dat.gz

NSTEP=${NJOB}_250
# [002]  
#------------------------------------------------------------------------------
LIBEL="Sorting VLIFEST_woRA into VLIFEST_NEW_RA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_240_${IB}_ESTC2127_VLIFEST_NEW_RA${IT}.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_220_${IB}_SORTVLIFEST_NEW_RA${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_VLIFEST_NEW_RA${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        ACY_NF        7:1 - 7:,
        ACM_NF        25:1 - 25:EN,
        CRE_D         8:1 - 8:,
        ACMTRS_NT    10:1 - 10:,
        BALSHEY_NF   11:1 - 11:,
        BALSHTMTH_NF 12:1 - 12:EN,
        ESTMNT_M     14:1 - 14:EN 15/3,
        DETTRNCOD_CF 20:1 - 20:,
        GAAP_NF      22:1 - 22:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CRE_D,
      BALSHEY_NF,
      BALSHTMTH_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/SUMMARIZE TOTAL ESTMNT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[007], [011]
if [[ ${PASS} -eq 1 ]];
then
NSTEP=${NJOB}_350
# Launching cleaning chain ESID0002
#------------------------------------------------------------------------------
LIBEL="Launching cleaning chain ESID0002"
IBC=${IB}
INPUT_FILE1="${DFILT}/${NJOB}_250_${IB}_VLIFEST_NEW_RA${IT}.dat"
INPUT_FILE2="${DFILT}/${NJOB}_050_${IB}_VLIFEST_OLD_RA${IT}.dat"
OUTPUT_FILE_NAME="${DFILT}/${NSTEP}_${IB}_ESID0002_VLIFEST_NEW${IT}.dat"
OUTPUT_FILE_NAME_DIFF="${DFILT}/${NSTEP}_${IB}_ESID0002_OLD_VLIFEST${IT}.dat"
#on sauvegarde la variable NJOB qui est modifiée dans le ESID0002 avec le JOBINIT
SAVINGJOB=${NJOB}
NJOB=${NSTEP}_ESID0002
${DCMD}/ESID0002.cmd ${IBC} ${OUTPUT_FILE_NAME} ${OUTPUT_FILE_NAME_DIFF} ${INPUT_FILE1} ${INPUT_FILE2} 2>&1 | ${TEE}
IB=${IBC}
NJOB=${SAVINGJOB}

#[007], [011]
NSTEP=${NJOB}_400
# passage 1: Ajout au VLIFEST de la RA mise a jour.
# passage 2: Ajout du DLRLIFEI au VLIFEST en plus de la RA mise a jour
#------------------------------------------------------------------------------
LIBEL="Merging VLIFEST without RA and old VLIFEST_NEW to rebuilt it"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_350_${IB}_ESID0002_VLIFEST_NEW${IT}.dat 1000 1"
#SORT_I="${DFILT}/${NJOB}_250_${IB}_VLIFEST_NEW_RA${IT}.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_050_${IB}_VLIFEST_woRA${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_LIFEST_O2${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        GAAP_NF       22:1 - 22:,
        ACCSTS_CT     31:1 - 31:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      GAAP_NF
/CONDITION END_VLIFEST ACCSTS_CT = "9"
/OUTFILE ${SORT_O}
/OMIT END_VLIFEST
exit
EOF
SORT
else
NSTEP=${NJOB}_350
# Launching cleaning chain ESID0002
#------------------------------------------------------------------------------
LIBEL="Launching cleaning chain ESID0002"
IBC=${IB}
INPUT_FILE1="${DFILT}/${NJOB}_250_${IB}_VLIFEST_NEW_RA${IT}.dat"
INPUT_FILE2="${DFILT}/${NJOB}_050_${IB}_VLIFEST_OLD_RA${IT}.dat"
OUTPUT_FILE_NAME="${DFILT}/${NSTEP}_${IB}_ESID0002_VLIFEST_NEW${IT}.dat"
OUTPUT_FILE_NAME_DIFF="${DFILT}/${NSTEP}_${IB}_ESID0002_OLD_VLIFEST${IT}.dat"
#on sauvegarde la variable NJOB qui est modifiée dans le ESID0002 avec le JOBINIT
SAVINGJOB=${NJOB}
NJOB=${NSTEP}_ESID0002
${DCMD}/ESID0002.cmd ${IBC} ${OUTPUT_FILE_NAME} ${OUTPUT_FILE_NAME_DIFF} ${INPUT_FILE1} ${INPUT_FILE2} 2>&1 | ${TEE}
IB=${IBC}
NJOB=${SAVINGJOB}

#[007]
NSTEP=${NJOB}_400
# passage 1: Ajout au VLIFEST de la RA mise a jour.
# passage 2: Ajout du DLRLIFEI au VLIFEST en plus de la RA mise a jour
#------------------------------------------------------------------------------
LIBEL="Merging VLIFEST without RA and old VLIFEST_NEW to rebuilt it"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_350_${IB}_ESID0002_VLIFEST_NEW${IT}.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_050_${IB}_VLIFEST_woRA${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_LIFEST_O2${IT}.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 
        CTR_NF        2:1 - 2:,
        END_NT        3:1 - 3:,
        SEC_NF        4:1 - 4:,
        UWY_NF        5:1 - 5:,
        UW_NT         6:1 - 6:,
        GAAP_NF       22:1 - 22:,
        ACCSTS_CT     31:1 - 31:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      GAAP_NF
/CONDITION END_VLIFEST ACCSTS_CT = "9"
/OUTFILE ${SORT_O}
/OMIT END_VLIFEST
exit
EOF
SORT

fi


# [014]
NSTEP=${NJOB}_450
#------------------------------------------------------------------------------
LIBEL="Launching spliting chain ESID0003"
INPUT_FILE1="${DFILT}/${NJOB}_400_${IB}_LIFEST_O2${IT}.dat"
OUTPUT_FILE_NAME_1="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O1${IT}.dat"
OUTPUT_FILE_NAME_2="${EST_LIFESTNOACC}"
${DCMD}/ESID0003.cmd ${OUTPUT_FILE_NAME_1} ${OUTPUT_FILE_NAME_2} ${INPUT_FILE1} ${BALSHTYEA_NF} 2>&1 | ${TEE}


NSTEP=${NJOB}_460
# Launching cleaning chain ESID0002
#------------------------------------------------------------------------------
LIBEL="Launching cleaning chain ESID0002"
IBC=${IB}
INPUT_FILE1="${DFILT}/${NJOB}_450_${IB}_SORT_LIFEST_O1${IT}.dat"
OUTPUT_FILE_NAME="${EST_VLIFEST195}"
OUTPUT_FILE_NAME_DIFF="${DFILT}/${NSTEP}_${IB}_SORT_VLIFEST195${IT}_OLD.dat"
${DCMD}/ESID0002.cmd ${IBC} ${OUTPUT_FILE_NAME} ${OUTPUT_FILE_NAME_DIFF} ${INPUT_FILE1} 2>&1 | ${TEE}   # ${INPUT_FILE2}
IB=${IBC}


# #gzip fichiers temporaires
#------------------------------------------------------------------------------ 
#gzip -c  ${EST_VLIFEST195}  > ${DFILT}/${NJOB}_460_VLIFEST_${PASS}_${IT}.dat.gz
#gzip -c  ${EST_LIFESTNOACC} > ${DFILT}/${NJOB}_450_LIFESTNOACC_${PASS}_${IT}.dat.gz


NSTEP=${NJOB}_470
# Deletion of Temporary Files
#------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*${IT}.dat"


# Job End
JOBEND
