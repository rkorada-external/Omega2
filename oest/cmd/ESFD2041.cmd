#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESID2041.cmd
# revision                      : $Revision: 1.10 $
# date de creation              : 26/05/97
# auteur                        : C.G.I. (C.Chavatte)
# references des specifications :
#-----------------------------------------------------------------------------
# description :
#   ESTIMATES UPDATE
#

# Input files
#       EST_CPLIFDRI       DFILI
#       EST_DLVGTAR              DFILP
#       EST_FCPLACC              DFILP
#       EST_FCURQUOT             DFILP
#       EST_FVPLACEMT      DFILI
#       EST_IAVPERICASE    DFILI
#       EST_IRVPERICASE    DFILI
#       EST_SRGTC          DFILI
#       EST_SRGTE          DFILI
#       EST_SRGTEF         DFILI
#       EST_VLIFEST195     DFILI
#
#  Output file
#       EST_DLVGTAA              DFILP
#       EST_DLVGTAR              DFILP
#       EST_DLVGTR               DFILP
#       EST_SIGNANO        DFILI
#       EST_SRGTE          DFILI
#       EST_SRGTEF         DFILI
#
#   Launch C programs ESTC2131,2136,2137,2138,2139,2140,2142,2143,2144,2145
#                     ESTC2146,2152,2153
#
#   Job launched by ESID2040.cmd
#
#-----------------------------------------------------------------------------
# historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
#   05/12/2002     O. Arik    ne plus ventiler les estimations sur les traités rattachés.(step 775)
#   21/08/2003     J. Ribot   ajout 5è parametre pour gestion CNA
#   12/02/2004     J. Ribot   modif criteres de selection tri step90
#   23/08/2004     J. Ribot   TEST variable NCHAIN pour prise en compte
#   17/12/2004     J. Ribot   modif prise en compte du fichier en entrée selon NCHAIN
#   28/02/2008     J. Ribot   Spot14307 modif trimestrialisation sur les traites non renouvelés (ajout step07)
#_________________
#MODIFICATION    [007]
#Auteur:         D.GATIBELZA
#Date:           26/07/2010
#Version:        10.1
#Description:    ESTVIE19177 V10 Mettre en place un calcul spécial de DAC pour Köln
#                automatic DAC calculation taking into account the fanancing commission, the technical result, the interest on deposit
#[008]  20/04/2011  Roger Cassis      :spot:21655 - tris pas en numerique sur la section.
#_________________
#MODIFICATION    [009]
#Auteur:         D.GATIBELZA
#Date:           27/04/2011
#Version:        11.1
#Description:    ESTDOM21408 OneLedger
#==============================================================================
#[009]  14/02/2012  Roger Cassis      :spot:xxxxy - Ajout de traces
#[010]  31/07/2012  Lalatiana Rakotozafy :spot24056:
#[011]  21/08/2012  Roger Cassis      :spot:24041 Filtre Pour omettre les filiales Tare dans GLT placé dans tri SRGTE et .zip en .gz
#[012]  01/02/2013  Roger Cassis      :spot:24790 - Renommage du prog ESTC2131bis en ESTC2151 et diverses modifs de Philippe
#[013]  04/03/2014  Roger Cassis      :spot:25427 - Touch fichier SRGTE.. copie si pas existant
#[014]  11/06/2014  MECHRI Mariem     Modification de tri 
#[015]  19/06/2014  Roger Cassis      :spot:24790 - Il faut donc rajouter à cette liste l’entité KC qui est filiale 14 établissement 15. 
#[016]  15/07/2014  ABJ :spot:25773   Modification du tri du SRGTC ( ajout du TRNCOD) et limitation d' annee ( -4 ACY +4 )
#[017]  17/07/2014  ABJ :spot:25773   Ajout du fichier SUBTRSESBPROP
#[018]  26/08/2014  ABJ :spot:25773   Ajout de test pour les Gaap 2,3,4 et 5
#[019]  26/08/2014  ABJ :spot:25773   Ajout du spimod pour la ventilation
#[020]  27/08/2014  ABJ :spot:25773   Modification du Tri pour le VLIFEST
#[021]  28/08/2014  ABJ :spot:25773   Suppression de la Credate au niveau du summ
#[022]  29/08/2014  ABJ :spot:25773   Ajout de fichiers pour le pg ESTC213
#[023]  30/08/2014  ABJ :spot:25773   Changement du Tri 
#[024]  05/09/2014  ABJ :spot:25773   Ajout du fichier FSUBTRSASSO pour le pg ESTC2166
#[025]  05/09/2014  ABJ :spot:25773   Modification de la condition de test
#[026]  13/09/2014  ABJ :spot:25773   Ajout du pericase pour le ESTC2166
#[027]  30/09/2014  ABJ :spot:25773   Augmentation taille fichier
#[028]  30/09/2014  ABJ :spot:25773   Traitement des constit et liberation sur les 1010  et 1140
#[029]  28/10/2014  SBE :spot:25773   Changement KEYS step 110
#[030]  05/12/2014  SBE :spot:25773   Ajout des Tris concernant les 1363/1364
#[031]  30/03/2015  SAS :spot:28512   Ajout du fichier SUBTRS pour le programme 2136, dans le cadre de la prise en charge des comptes analytiques
#[032]  16/04/2015  PGA :spot:28559   Ajout output au programme ESTC2146 et programme ESTC3701 dans le but de reconstruire le GT
#[033]  13/08/2015  R. Cassis :spot:29216 Pour MUTRE, on omet les postes comptables se terminant par C ou G
#[034]  11/08/2015  SAS :spot:29185   Ajout de la filaiale 27
#[035]  16/12/2015  RBE :spot:29894   correction de calcul du gaapdiff
#[036]  15/02/2016  Florent :spot:29066 GT à 71 colonnes
#[037]  15/02/2016  DFI :spot:30195   time shifted, traitement mode PC et PA (+retrait code obsolete specifique ESID1530)
#[038]  04/05/2016  DFI :spot:        EST27 time shifted, traitement mode PC et PA pour ESTC2137
#[039]  09/05/2016  MBO :spot:30579   pas de spira : correction des soucis de fin du fichier de sortie du EST2136
#[040]  16/08/2016  DFI :spot:30939   spira 52445 differentiation des sorties ESID2040 PA et PC
#[041]  13/09/2018  SBE :spira:70063  [Apolo - QE] - Life Closing: Management of exlcuded contracts for the estimates process
#[042]  09/01/2019  SBE :spira:74478  [TNR] Calcul des Compléments / Accrual Calculation
#[043]  26/04/2019  SBE :spira:70044  Evolution quarterly
#[044]  14/10/2019 SBE  spira:78597: APOLO QE : TLIFSTAREP current, annual and photo plan estimations are wrong
#[045]  12/11/2019 SBE  spira:81819: Apolo QE: feeding of SCOSTRMTH_NF and SCOENDMTH_NF in TTECLEDA
#[046]  16/12/2019 SBE  spira:81946: Apolo QE: Trimestrialisation des compléments Distinction poste cash et reserve
#==============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CLODAT_D=$3
CRE_D=$4
MTHCNA_NF=$5
MODE=$6           #[037]
LIF_ACY_MAX=4
LIF_ACY_MIN=4

# Job Initialisation
JOBINIT

# [040] differentiation PA/PC
if [ ${MODE} = "PA" ]
then
  EST_SRGTE=${EST_SRGTE_PA}
  EST_SRGTEF=${EST_SRGTEF_PA}
  EST_CMPCALC=${EST_CMPCALC_PA}
  EST_DLVGTAA=${EST_DLVGTAA_PA}
  EST_DLVGTAR=${EST_DLVGTAR_PA}
  EST_DLVGTR=${EST_DLVGTR_PA}
else
  EST_SRGTE=${EST_SRGTE_PC}
  EST_SRGTEF=${EST_SRGTEF_PC}
  EST_CMPCALC=${EST_CMPCALC_PC}
  EST_DLVGTAA=${EST_DLVGTAA_PC}
  EST_DLVGTAR=${EST_DLVGTAR_PC}
  EST_DLVGTR=${EST_DLVGTR_PC}
fi

if [ ${NCHAIN} = "${PCH}ESDJ8040" ]
then
    EST_LIFTRANSFR=$EST_VLIFEST195
fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="

ECHO_LOG "#===> BALSHTYEA_NF......: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF......: ${BALSHTMTH_NF}"
ECHO_LOG "#===> ICLODAT_D.........: ${CLODAT_D}"
ECHO_LOG "#===> CRE_D.............: ${CRE_D}"
ECHO_LOG "#===> MTHCNA_NF.........: ${MTHCNA_NF}"
ECHO_LOG "#===> IAVPERICASE.......: ${EST_IAVPERICASE}"
ECHO_LOG "#===> IRVPERICASE.......: ${EST_IRVPERICASE}"
ECHO_LOG "#===> LIFTRANSFR........: ${EST_LIFTRANSFR}"
ECHO_LOG "#===> SRGTE.............: ${EST_SRGTE}"
ECHO_LOG "#===> SRGTEF............: ${EST_SRGTEF}"
ECHO_LOG "#===> CMPCALC...........: ${EST_CMPCALC}"
ECHO_LOG "#===> DLVGTAA...........: ${EST_DLVGTAA}"
ECHO_LOG "#===> DLVGTAR...........: ${EST_DLVGTAR}"
ECHO_LOG "#===> DLVGTR............: ${EST_DLVGTR}"


#gzip -c ${EST_VLIFEST195} > ${DFILT}/${NCHAIN}_Avant_VLIFEST195${IT}.dat.sgz

### -------------------------- ###
#   SI ON EST DANS LE ESID2040   #
### -------------------------- ###
#[020]
NSTEP=${NJOB}_05
#Syncro perimetre / retro interne
# ABJ:  Creation de constite a montant =0 pour chaque liberation
#[024]
#[026]
#------------------------------------------------------------------------------
LIBEL="Syncro perimeter file / estimation"
PRG=ESTC2166
export ${PRG}_I=${EST_VLIFEST195}
export ${PRG}_I2=${EST_SUBTRSASSO}
export ${PRG}_I3=${EST_IARVPERICASE0}
export ${PRG}_O=${DFILT}/${NSTEP}_${IB}_ESTC2166_LIFEST_O${IT}.dat
EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2166_LIFEST_O${IT}.dat     > ${DFILT}/${NCHAIN}_005_LIFEST_O_${ICLODAT_MTH}${IT}.sgz

NSTEP=${NJOB}_06
# Most Recent Estimates
#[014]
#[021]
#------------------------------------------------------------------------------
LIBEL="Most Recent Estimates"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_ESTC2166_LIFEST_O${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:,
    CTR_NF           2:1 -  2:,
    END_NT           3:1 -  3:,
    SEC_NF           4:1 -  4:,
    UWY_NF           5:1 -  5:,
    UW_NT            6:1 -  6:,
    ACY_NF           7:1 -  7:,
    ACM_NF          25:1 -  25:EN,
    CRE_D            8:1 -  8:,
    ACMTRS_NT       10:1 - 10:,
    BALSHEY_NF      11:1 - 11:,
    BALSHTMTH_NF    12:1 - 12:EN,
    CUR_CF          13:1 - 13:,
    ESTMNT_M        14:1 - 14:EN 15/3,
    DETTRNCOD_CF    20:1 - 20:,
    GAAP_NF         22:1 - 22:,
    GAAPDIFF_M      23:1 - 23:EN 15/3,
    FILLER1          1:1 - 13:,
    FILLER2         15:1 - 22:,
    FILLER3         24:1 - 54:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      BALSHEY_NF,
      ACY_NF,
      ACM_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/SUMMARIZE TOTAL ESTMNT_M, TOTAL GAAPDIFF_M
/DERIVEDFIELD ESTMNT_MC ESTMNT_M COMPRESS
/DERIVEDFIELD GAAPDIFF_MC GAAPDIFF_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,ESTMNT_MC, FILLER2, GAAPDIFF_MC, FILLER3 
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat     > ${DFILT}/${NCHAIN}_006_LIFEST_O_${ICLODAT_MTH}${IT}.sgz   
  
NSTEP=${NJOB}_07
# Most Recent Estimates
#[014]
#------------------------------------------------------------------------------
LIBEL="Most Recent Estimates"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_06_${IB}_SORT_LIFEST_O${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:EN,
        ACM_NF 25:1 -  25:EN,
        CRE_D  8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        DETTRNCOD_CF 20:1 - 20:,
        GAAP_NF      22:1 - 22:,
        FILLER 1:1 - 54:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      GAAP_NF,
      ACY_NF,
      ACM_NF
/OUTFILE ${SORT_O}
/REFORMAT FILLER,ACMTRS_NT
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat     > ${DFILT}/${NCHAIN}_007_LIFEST_O_${ICLODAT_MTH}${IT}.sgz   

   
NSTEP=${NJOB}_08
# update le champ ACCRET
#[15]
#-----------------------------------------------------------------------------
LIBEL="construction du nouveau champs pour le tri"
PRG=ESTC2056
FPRM=`CFTMP`
export ${PRG}_I=${DFILT}/${NJOB}_07_${IB}_SORT_LIFEST_O${IT}.dat
export ${PRG}_I1=${EST_SUBTRSASSO}
export ${PRG}_O=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O${IT}.dat
EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O${IT}.dat     > ${DFILT}/${NCHAIN}_${PRG}_008_LIFEST_O_${ICLODAT_MTH}${IT}.sgz


NSTEP=${NJOB}_09
# Most Recent Estimates
#[014]
#[023]
#[027]
#------------------------------------------------------------------------------
LIBEL="Most Recent Estimates"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_08_${IB}_ESTC2056_LIFEST_O${IT}.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:EN,
        ACM_NF 25:1 -  25:EN,
        CRE_D  8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        DETTRNCOD_CF 20:1 - 20:,
        GAAP_NF      22:1 - 22:,
        FILLER1       1:1 - 54:,
        FILLER       55:1 - 55:        
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      FILLER,
      GAAP_NF,
      CRE_D DESCENDING
/OUTFILE ${SORT_O}
exit
EOF
    SORT

gzip -c ${DFILT}/${NJOB}_09_${IB}_SORT_LIFEST_O${IT}.dat       > ${DFILT}/${NCHAIN}_09_LIFEST_O_${ICLODAT_MTH}${IT}.sgz


 
#[020]
NSTEP=${NJOB}_10
#Syncro perimetre / retro interne
# ABJ:  determiner si le contrat a ete renouvelé pour l'exercice egale a l'annee d'inventaire 
#------------------------------------------------------------------------------
LIBEL="Syncro perimeter file / estimation"
PRG=ESTC7608
export ${PRG}_I1=${EST_IARVPERICASE0}
export ${PRG}_I2=${DFILT}/${NJOB}_09_${IB}_SORT_LIFEST_O${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTC7608_LIFEST_O${IT}.dat
EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC7608_LIFEST_O${IT}.dat     > ${DFILT}/${NCHAIN}_010_ESTC7608_LIFEST_O_${ICLODAT_MTH}.sgz


NSTEP=${NJOB}_10_b
# Most Recent Estimates
#[014]
#[023]
#[027]
#------------------------------------------------------------------------------
LIBEL="Most Recent Estimates"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTC7608_LIFEST_O${IT}.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:EN,
        ACM_NF 25:1 -  25:EN,
        CRE_D  8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        DETTRNCOD_CF 20:1 - 20:,
        GAAP_NF      22:1 - 22:,
        FILLER1       1:1 - 54:,
        FILLER       55:1 - 55:        
/KEYS CTR_NF,
      SEC_NF,
      GAAP_NF,
      UWY_NF,
      ACY_NF,
      ACM_NF,
      FILLER,     
      CRE_D DESCENDING
/OUTFILE ${SORT_O}     
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O${IT}.dat.sgz

NSTEP=${NJOB}_11  
if [ "X${IT}" == "XY" ]
then
  # Determining Intermediary Estimates  #[037]
  #------------------------------------------------------------------------------
  LIBEL="Determining Intermediary Estimates"
  PRG=ESTC2136
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} << EOF
  BALSHTYEA_NF ${BALSHTYEA_NF}
  BALSHTMTH_NF ${BALSHTMTH_NF}
  CLODAT_D ${CLODAT_D}
  MODE ${MODE}
  exit
EOF
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_I1=${DFILT}/${NJOB}_10_b_${IB}_SORT_LIFEST_O${IT}.dat
  export ${PRG}_I2=${EST_FACCPAR0}
  export ${PRG}_I3=${EST_SUBTRSASSO}
  export ${PRG}_I4=${EST_SUBTRS}
  export ${PRG}_I5=${EST_IARVPERICASE4}  #[037]
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O_tmp${IT}.dat
  EXECPRG

  gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O_tmp${IT}.dat > ${DFILT}/${NSTEP}_${PRG}_LIFEST_O_tmp${IT}.dat.gz

else
  # Pour mode quarterly - on cumule les estimations trimestrielles
  NSTEP=${NJOB}_11_b
  #------------------------------------------------------------------------------
  LIBEL="Most Recent Estimates"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_10_b_${IB}_SORT_LIFEST_O${IT}.dat 2000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat 1000 1"
  INPUT_TEXT ${SORT_CMD} <<EOF
  /FIELDS CTR_NF 2:1 - 2:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:EN,
        ACM_NF 25:1 -  25:EN,
        CRE_D  8:1 - 8:,
        ACMTRS_NT 10:1 - 10:,
        DETTRNCOD_CF 20:1 - 20:,
        GAAP_NF      22:1 - 22:,
        FILLER1       1:1 - 54:,
        FILLER       55:1 - 55:        
  /KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      DETTRNCOD_CF,
      GAAP_NF,
      ACM_NF
  /OUTFILE ${SORT_O}     
  exit
EOF
  SORT

  NSTEP=${NJOB}_15
  #------------------------------------------------------------------------------
  LIBEL="Calculate quarterly estimation to use in complement"
  PRG=ESTC2141
  FPRM=`CFTMP`
  INPUT_TEXT ${FPRM} << EOF
  CLODAT_D ${CLODAT_D}
  exit
EOF
  export ${PRG}_PRM=${FPRM}
  export ${PRG}_I1=${DFILT}/${NJOB}_11_b_${IB}_SORT_LIFEST_O${IT}.dat
  export ${PRG}_I2=${EST_SUBTRS}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O_${IT}.dat
  EXECPRG

  mv ${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O_${IT}.dat ${DFILT}/${NJOB}_11_${IB}_ESTC2136_LIFEST_O_tmp${IT}.dat
fi

#[039]
NSTEP=${NJOB}_20
LIBEL="Suppression lignes mal formatées dans la sortie de l'ESTC2136"
AWK_I=${DFILT}/${NJOB}_11_${IB}_ESTC2136_LIFEST_O_tmp${IT}.dat
AWK_O=${DFILT}/${NJOB}_11_${IB}_ESTC2136_LIFEST_O${IT}.dat

awk -F~ -v NBF=`head -n1 ${AWK_I} | sed 's/[^~]//g' | wc -m` '{if (NF == NBF) { print $0 }}' ${AWK_I} > ${AWK_O}
#![039]


gzip -c ${DFILT}/${NJOB}_10_b_${IB}_SORT_LIFEST_O${IT}.dat     >   ${DFILT}/${NCHAIN}_011_ESTC2136_LIFEST.dat_I_${ICLODAT_MTH}_${MODE}${IT}.gz #[038]
gzip -c ${DFILT}/${NJOB}_11_${IB}_ESTC2136_LIFEST_O${IT}.dat   >   ${DFILT}/${NCHAIN}_011_ESTC2136_LIFEST.dat_O_${ICLODAT_MTH}_${MODE}${IT}.gz #[038]

cp ${DFILT}/${NCHAIN}_011_ESTC2136_LIFEST.dat_I_${ICLODAT_MTH}${IT}.gz ${DFILT}/${NCHAIN}_011_ESTC2136_LIFEST.dat_I_${ICLODAT_MTH}_${MODE}${IT}.gz  #[037]
cp ${DFILT}/${NCHAIN}_011_ESTC2136_LIFEST.dat_O_${ICLODAT_MTH}${IT}.gz ${DFILT}/${NCHAIN}_011_ESTC2136_LIFEST.dat_O_${ICLODAT_MTH}_${MODE}${IT}.gz  #[037]

NSTEP=${NJOB}_15
# Delete temporary file

#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_LIFEST_O${IT}.dat
RMFIL ${DFILT}/${NJOB}_07_${IB}_ESTC7608_LIFEST_O${IT}.dat

NSTEP=${NJOB}_102
# move ESTC2136_LIFEST_O.dat ==> DFILT SORT_VLIFEST195_O.dat
#------------------------------------------------------------------------------
LIBEL="move ESTC2136_LIFEST_O.dat ==> DFILT SORT_VLIFEST195_O.dat"
EXECKSH "mv ${DFILT}/${NJOB}_11_${IB}_ESTC2136_LIFEST_O${IT}.dat ${DFILT}/${NJOB}_100_${IB}_SORT_VLIFEST195_O${IT}.dat"


#[016]
NSTEP=${NJOB}_105
# Estimates Sort
#------------------------------------------------------------------------------
LIBEL="Estimates Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_SORT_VLIFEST195_O${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER 1:1 - 53:,
        CTR_NF 2:1 - 2:,
        END_NT 3:1 - 3:,
        SEC_NF 4:1 - 4:,
        UWY_NF 5:1 - 5:,
        ACY_NF 7:1 - 7:EN,
        ACM_NF 25:1 -  25:EN,
        ACMTRS_NT 10:1 - 10:,
        DETTRNCOD_CF 20:1 - 20:,
        GAAP_NF      22:1 - 22:,
        ADJCOD_CT 40:1 - 40: EN
/KEYS CTR_NF,
      SEC_NF,
      ACY_NF,
      ACM_NF,
      UWY_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/CONDITION CODGENER (( ADJCOD_CT EQ 1) AND ( ACY_NF <= `expr ${BALSHTYEA_NF} + ${LIF_ACY_MAX}`  AND ACY_NF >= `expr ${BALSHTYEA_NF} - ${LIF_ACY_MIN}` ))
/INCLUDE CODGENER
/OUTFILE ${SORT_O}
exit
EOF
SORT
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O${IT}.dat          >${DFILT}/${NCHAIN}_105_LIFEST_O.dat_O_${ICLODAT_MTH}${IT}.gz


NSTEP=${NJOB}_106
# Loader programs V2
#-----------------------------------------------------------------------------
LIBEL="SORT du fichier LIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_105_${IB}_SORT_LIFEST_O${IT}.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_LIFEST_TRIE_O1${IT}.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF        2:1 -  2:,
        SEC_NF        4:1 -  4:,
        UWY_NF        5:1 -  5:,
        ACY_NF        7:1 -  7:,
        ACM_NF        25:1 -  25:EN,
        CRE_D         8:1 -  8:,
        ACMTRS_NT     10:1 - 10:,
        DETTRNCOD_CF  20:1 - 20:
/KEYS   CTR_NF,
        SEC_NF,
        UWY_NF,
        ACY_NF,
        ACM_NF,
        ACMTRS_NT,
        DETTRNCOD_CF
/SUM
/STABLE
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_LIFEST_TRIE_O1${IT}.dat > ${DFILT}/${NSTEP}_LIFEST_TRIE_O1.dat${IT}.gz


NSTEP=${NJOB}_107
#Multiplicate LIFEST in all 5 gaap
#----------------------------------------------------------------------------
LIBEL="Multiplicate LIFEST in all 5 gaap"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_106_${IB}_LIFEST_TRIE_O1${IT}.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O1${IT}.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O2${IT}.dat
SORT_O3=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O3${IT}.dat
SORT_O4=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O4${IT}.dat
SORT_O5=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O5${IT}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS  ZONE1       1: - 13:,
        ZONE2      15: - 21:,
        ZONE3      23: - 54:
/DERIVEDFIELD MNT "0.000~"
/DERIVEDFIELD GAAP1 "1~"
/DERIVEDFIELD GAAP2 "2~"
/DERIVEDFIELD GAAP3 "3~"
/DERIVEDFIELD GAAP4 "4~"
/DERIVEDFIELD GAAP5 "5~"
/COPY
/OUTFILE ${SORT_O}
/REFORMAT ZONE1,MNT, ZONE2,GAAP1,ZONE3
/OUTFILE ${SORT_O2}
/REFORMAT ZONE1,MNT, ZONE2,GAAP2,ZONE3
/OUTFILE ${SORT_O3}
/REFORMAT ZONE1,MNT, ZONE2,GAAP3,ZONE3
/OUTFILE ${SORT_O4}
/REFORMAT ZONE1,MNT, ZONE2,GAAP4,ZONE3
/OUTFILE ${SORT_O5}
/REFORMAT ZONE1,MNT, ZONE2,GAAP5,ZONE3
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O1${IT}.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O1${IT}.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O2${IT}.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O2${IT}.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O3${IT}.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O3${IT}.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O4${IT}.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O4${IT}.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O5${IT}.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_O5${IT}.dat.gz

NSTEP=${NJOB}_108
#Multiplicate LIFEST in all 5 gaap
#----------------------------------------------------------------------------
LIBEL="Multiplicate LIFEST in all 5 gaap"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_105_${IB}_SORT_LIFEST_O${IT}.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_107_${IB}_SORT_LIFEST_O1${IT}.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_107_${IB}_SORT_LIFEST_O2${IT}.dat 1000 1"
SORT_I4="${DFILT}/${NJOB}_107_${IB}_SORT_LIFEST_O3${IT}.dat 1000 1"
SORT_I5="${DFILT}/${NJOB}_107_${IB}_SORT_LIFEST_O4${IT}.dat 1000 1"
SORT_I6="${DFILT}/${NJOB}_107_${IB}_SORT_LIFEST_O5${IT}.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_ALL_GAAP_O1${IT}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF        2:1 -  2:,
        SEC_NF        4:1 -  4:,
        UWY_NF        5:1 -  5:,
        ACY_NF        7:1 -  7:,
        ACM_NF        25:1 -  25:EN,
        CRE_D         8:1 -  8:,
        ACMTRS_NT     10:1 - 10:,
        ESTMNT_M      14:1 - 14:EN 15/3,
        DETTRNCOD_CF  20:1 - 20:,
        GAAP_NF       22:1 - 22:,
        GAAPDIFF_M    23:1 - 23:EN 15/3
/KEYS CTR_NF,
      SEC_NF,
      ACY_NF,
      ACM_NF,
      UWY_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF
/SUMMARIZE TOTAL ESTMNT_M, TOTAL GAAPDIFF_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_ALL_GAAP_O1${IT}.dat > ${DFILT}/${NSTEP}_SORT_LIFEST_ALL_GAAP_O1${IT}.dat.gz


NSTEP=${NJOB}_109
# Grouping Accounting Transactions by SyncSort
#------------------------------------------------------------------------------
# Tri du fichier SRGTC pour garder la période scor la plus récente  dans le step suivant
LIBEL="Grouping Accounting Transactions by SyncSort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SRGTC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT230_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_DBLTRNCOD    1:1 -  7:,
        TRNCOD5_CF       6:3 -  6:7,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        ACY_NF          14:1 - 14:EN,
        SCOMTH          15:1 - 15:EN,
        SCOENDMTH       16:1 - 16:EN,
        ACMTRS_NT       45:1 - 45:,
        QUART_NF		    75:1 - 75:EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      QUART_NF,
      ACMTRS_NT,
      TRNCOD5_CF,
      SCOMTH DESCENDING,
      SCOENDMTH DESCENDING

exit
EOF
SORT

#[016]
#[019]
#[029]
NSTEP=${NJOB}_110
# Grouping Accounting Transactions by SyncSort
#------------------------------------------------------------------------------
#         ACM_NF          75:1 - 75:EN,
#         ACM_NF,
# Pas de cumul par trimestre pour la compta. pour correspondre aux estimation cumulés sur les 1er trimestres
LIBEL="Grouping Accounting Transactions by SyncSort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_109_${IB}_SORT_GT230_O${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT230_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_DBLTRNCOD    1:1 -  7:,
        TRNCOD_CF        6:1 -  6:,
        TRNCOD5_CF       6:3 -  6:7,
        BALSHEY_NF       3:1 -  3:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:EN,
        SCOMTH          15:1 - 15:EN,
        SCOENDMTH       16:1 - 16:EN,
        SCOSTR_CUR      15:1 - 18:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        CED_ESTCUR      20:1 - 41:,
        ESTCUR_CF       42:1 - 42:,
        ESTAMT_M        43:1 - 43:EN 15/3,
        NAT_CF          44:1 - 44:,
        ACMTRS_NT       45:1 - 45:,
        ESTCTR_NF       46:1 - 46:,
        ESTSEC_NF       47:1 - 47:,
        LOB_CF          48:1 - 48:,
        SCOEGP_M        49:1 - 49:EN 15/3,
        ESTCRB_CT       50:1 - 50:,
        QUART_NF		    75:1 - 75:EN,
        ESTCRB_UWGRP    50:1 - 75:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      QUART_NF,
      ACMTRS_NT,
      TRNCOD5_CF,
      ESTCUR_CF    
/SUM TOTAL ESTAMT_M
/DERIVEDFIELD ESTAMT_MC ESTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD SCOEGP_MC SCOEGP_M COMPRESS
/DERIVEDFIELD CHAMPVID "~"
/OUTFILE ${SORT_O}
/REFORMAT SSD_DBLTRNCOD, CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTR_CUR, AMT_MC,
          CED_ESTCUR, ESTCUR_CF, ESTAMT_MC, NAT_CF, ACMTRS_NT, ESTCTR_NF, ESTSEC_NF, LOB_CF, SCOEGP_MC, ESTCRB_UWGRP  
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_GT230_O${IT}.dat   > ${DFILT}/${NCHAIN}_110_SORT_GT230_O${IT}.dat.sgz


NSTEP=${NJOB}_125
# Accounting Transaction Screen
#------------------------------------------------------------------------------
LIBEL="Accounting Transaction Screen"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_SORT_GT230_O${IT}.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT230_O${IT}.dat 1000 1"
SORT_O1="${DFILT}/${NSTEP}_${IB}_SORT_GT232_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       8:1 -  8:,
        END_NT       9:1 - 9:,  
        SEC_NF      10:1 - 10:,
        UWY_NF      11:1 - 11:,
        UW_NF       12:1 - 12:,
        BALSHEY_NF   3:1 - 3:, 
        BALSHTMTH_NF 4:1 - 4:,
        ACY_NF      14:1 - 14:,
        ACM_NF      75:1 - 75:EN,
        ACMTRS_NT   45:1 - 45:,
        TRNCOD5_CF   6:3 -  6:7,
        ESTCRB_CT   50:1 - 50:,
        ADJCOD_CT   57:1 - 57:,
        COMACC_B    56:1 - 56: EN,
        QUART_NF		    75:1 - 75:EN
/KEYS CTR_NF, SEC_NF, ACY_NF, QUART_NF, UWY_NF, ACMTRS_NT, TRNCOD5_CF
/CONDITION CODADJ ( ADJCOD_CT EQ "1" and ESTCRB_CT NE "N" )
/CONDITION CRICOM ESTCRB_CT EQ "N" and COMACC_B = 0
/OUTFILE  ${SORT_O1}
/INCLUDE CODADJ
/OUTFILE  ${SORT_O}
/INCLUDE CRICOM
exit
EOF
SORT
# Ajout de DETTRNCOD pour pouvoir l utiliser au 2137

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_GT230_O${IT}.dat   > ${DFILT}/${NCHAIN}_125_SORT_GT230_O${IT}.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_GT232_O${IT}.dat   > ${DFILT}/${NCHAIN}_125_SORT_GT232_O${IT}.dat.gz


NSTEP=${NJOB}_128
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_110_${IB}_SORT_GT230_O${IT}.dat

NSTEP=${NJOB}_130
# Screen and code conversion
#------------------------------------------------------------------------------
LIBEL="Screen and code conversion"
PRG=ESTC2145
export ${PRG}_I1=${DFILT}/${NJOB}_125_${IB}_SORT_GT230_O${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CONVERT_GT275_O${IT}.dat
EXECPRG
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_CONVERT_GT275_O${IT}.dat   > ${DFILT}/${NCHAIN}_130_ESTC2145_CONVERT_GT275_O${IT}.dat.sgz


NSTEP=${NJOB}_135
# Creation of Estimates Complements
# [038] ajout parametre MODE (PA ou PC)
#------------------------------------------------------------------------------
LIBEL="Creation of Estimates Complements"
PRG=ESTC2137
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CHAINE_CT    2040
CLODAT_D ${CLODAT_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
MODE ${MODE}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_125_${IB}_SORT_GT232_O${IT}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_108_${IB}_SORT_LIFEST_ALL_GAAP_O1${IT}.dat
export ${PRG}_I3=${EST_CPLIFDRI}
export ${PRG}_I4=${EST_SUBTRS}
export ${PRG}_I5=${EST_SUBTRSASSO}
export ${PRG}_I6=${EST_FTRSLNK}
export ${PRG}_I7=${EST_SUBTRSESBPROP}
export ${PRG}_I8=${EST_IARVPERICASE4}  #[037]
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT235_O1${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTEF_O2${IT}.dat
export ${PRG}_O3=${EST_SIGNANO}
export ${PRG}_O4=${EST_CMPCALC}
export ${PRG}_O5=${DFILT}/${NSTEP}_${IB}_${PRG}_GT235_ESTCRB_EXCLUS${IT}.dat
EXECPRG


# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_125_${IB}_SORT_GT232_O${IT}.dat            > ${DFILT}/${NCHAIN}_125_I1_ESTC2137_SORT_GT232_O_${ICLODAT_MTH}_${MODE}${IT}.dat.gz  #[038]
gzip -c ${DFILT}/${NJOB}_105_${IB}_SORT_LIFEST_O${IT}.dat           > ${DFILT}/${NCHAIN}_105_I2_ESTC2137_SORT_LIFEST_O_${ICLODAT_MTH}_${MODE}${IT}.dat.gz #[038]
gzip -c ${DFILT}/${NJOB}_108_${IB}_SORT_LIFEST_ALL_GAAP_O1${IT}.dat > ${DFILT}/${NCHAIN}_108_I2_ESTC2137_SORT_LIFEST_O_${ICLODAT_MTH}_${MODE}${IT}.dat.gz #[038]
gzip -c ${DFILT}/${NJOB}_135_${IB}_ESTC2137_GT235_O1${IT}.dat       > ${DFILT}/${NCHAIN}_135_O1_ESTC2137_GT235_O1_${ICLODAT_MTH}_${MODE}${IT}.dat.gz      #[038]
gzip -c ${DFILT}/${NJOB}_135_${IB}_ESTC2137_SRGTEF_O2${IT}.dat      > ${DFILT}/${NCHAIN}_135_O2_ESTC2137_SRGTEF_O2_${ICLODAT_MTH}_${MODE}${IT}.dat.gz     #[038]
gzip -c ${EST_SIGNANO}                                         > ${DFILT}/${NCHAIN}_135_O3_ESTC2137_SIGNANO_${ICLODAT_MTH}_${MODE}${IT}.dat.gz       #[038]
gzip -c ${EST_CMPCALC}                                         > ${DFILT}/${NCHAIN}_135_O4_ESTC2137_CMPCALC_${ICLODAT_MTH}_${MODE}${IT}.dat.gz       #[038]
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_GT235_ESTCRB_EXCLUS${IT}.dat > ${DFILT}/${NCHAIN}_135_O5_ESTC2137_GT235_ESTCRB_EXCLUS_${MODE}${IT}.dat.gz
# ----------------------------------------
# FIN TRACES POUR l'ENVIRONNEMENT DE TEST
# ----------------------------------------


# Fin du traitement pour l'intra-day
if [ ${NCHAIN} = "${PCH}ESDJ8040" ]
then
  NSTEP=${NJOB}_999
  # Delete temporary & permanent files
  #------------------------------------------------------------------------------
  LIBEL="Delete temporary & permanent files"
  RMFIL "${DFILT}/${NJOB}*_${IB}_*${IT}.dat"
  JOBEND
fi

#[009] le step 795 est déplacé en STEP 136
NSTEP=${NJOB}_136
# Sort of placement file
#------------------------------------------------------------------------------
LIBEL="Sort of placement file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FVPLACEMT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PLACEMT_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF    3:1 -  3:,
        RETEND_NT    4:1 -  4:,
        RETSEC_NF    5:1 -  5:,
        RTY_NF       6:1 -  6:,
        RETUW_NT     7:1 -  7:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF

SORT


#[009] le step 795 est déplacé en STEP 136
#[041] Suppression test SSD_CD et ESB_CF
NSTEP=${NJOB}_136_7
# Sort of placement file
#[010] Pezout : Pas d’estimation pour la rétro pour les filiales 14 établissement 7,8,9,10,11,12 et pour les filiales 25 ET 26 tous établissements. Je te devais cette réponse depuis un moment.
#[015] Rajout etablissement 15
#[018]
#[025] 
#[034]
#[041][042] Suppression test SSD_CD et ESB_CF - Changement Test suffixe pour exclusion de tous les complements suite aux tests 3E sur INT
#------------------------------------------------------------------------------
LIBEL="Sort of SRGTEF file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_135_${IB}_ESTC2137_SRGTEF_O2${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2137_SRGTEF_O2${IT}.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_ESTC2137_SRGTEF_O2_EXCLUS${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF     1:1 -  1:EN,
        ESB_CF     2:1 -  2:EN,
        TRNCOD2_CF 6:2 -  6:2,
        TRNCOD8_CF 6:8 -  6:8,
        CTR_NF     8:1 -  8:,
        END_NT     9:1 -  9:,
        SEC_NF    10:1 - 10:,
        UWY_NF    11:1 - 11:,
        UW_NT     12:1 - 12:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION SSDESB "${MTHCNA_NF}" != "12" AND "Z" CT TRNCOD8_CF  AND "123" CT TRNCOD2_CF
/OUTFILE ${SORT_O}
/OMIT SSDESB
/OUTFILE ${SORT_O2}
/INCLUDE SSDESB
exit
EOF
SORT
# 
#AND TRNCOD8_CF = "2" AND "123" CT TRNCOD2_CF
gzip -c ${DFILT}/${NJOB}_136_7_${IB}_ESTC2137_SRGTEF_O2_EXCLUS${IT}.dat  > ${DFILT}/${NJOB}_136_7_SRGTEF_O2_EXCLUS_${ICLODAT_MTH}${IT}.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2137_SRGTEF_O2${IT}.dat              > ${DFILT}/${NJOB}_136_7_SRGTEF_O2_${ICLODAT_MTH}${IT}.dat.gz


##[009] Faire appel au périmetre complet pour retirer les complements sur les terminés comptables:
## si traité ACC/RETRO terminés comptables : pas de complements
# Accès pour les contrats de retro (postes 2% ou 4% ) pour filtrer les enregistrements qui ne sont pas dans PLACEMENT:
NSTEP=${NJOB}_137
# Selection of the last contract record
#------------------------------------------------------------------------------
LIBEL="Selection of the last contract record"
PRG=ESTC2151
export ${PRG}_I1=${DFILT}/${NJOB}_136_7_${IB}_ESTC2137_SRGTEF_O2${IT}.dat
export ${PRG}_I2=${EST_IAVPERICASE}
export ${PRG}_I3=${EST_IRVPERICASE}
export ${PRG}_I4=${DFILT}/${NJOB}_136_${IB}_SORT_PLACEMT_O${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTEF_O1${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_TERMINE_COMPTABLE_O2${IT}.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_RETRO_PAS_PLACEMENT_O3_${ICLODAT_MTH}${IT}.log
EXECPRG


cp ${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTEF_O1${IT}.dat ${DFILT}/V_137_SORT_DVGTAA_O.trace${IT}.dat

#[009] le step 795 est déplacé en STEP 136
#[011] Le filtre pour filiales Tare est replace ici
#[015] Rajout etablissement 15
#[018]
#[025] 
#[034]
#[041][042] Suppression test SSD_CD et ESB_CF - Changement Test suffixe pour exclusion de tous les complements suite aux tests 3E sur INT
NSTEP=${NJOB}_136_8
# Sort of placement file
#------------------------------------------------------------------------------
LIBEL="Sort of GT235 file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_135_${IB}_ESTC2137_GT235_O1${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2137_GT235_O1${IT}.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_ESTC2137_GT235_O2_EXCLUS${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF     1:1 -  1:EN,
        ESB_CF     2:1 -  2:EN,
        TRNCOD2_CF 6:2 -  6:2,
        TRNCOD8_CF 6:8 -  6:8,
        CTR_NF     8:1 -  8:,
        END_NT     9:1 -  9:,
        SEC_NF    10:1 - 10:,
        UWY_NF    11:1 - 11:,
        UW_NT     12:1 - 12:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION SSDESB "${MTHCNA_NF}" != "12" AND "Z" CT TRNCOD8_CF  AND "123" CT TRNCOD2_CF
/OUTFILE ${SORT_O}
/OMIT SSDESB
/OUTFILE ${SORT_O2}
/INCLUDE SSDESB
exit
EOF
SORT
#AND TRNCOD8_CF = "2" AND "123" CT TRNCOD2_CF
gzip -c ${DFILT}/${NJOB}_136_8_${IB}_ESTC2137_GT235_O2_EXCLUS${IT}.dat  > ${DFILT}/${NJOB}_136_8_MOIS_${MTHCNA_NF}_GT235_O2_EXCLUS_${ICLODAT_MTH}${IT}.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_ESTC2137_GT235_O1${IT}.dat              > ${DFILT}/${NJOB}_136_8_MOIS_${MTHCNA_NF}_GT235_O1_${ICLODAT_MTH}${IT}.dat.gz



NSTEP=${NJOB}_138
# Selection of the last contract record
#------------------------------------------------------------------------------
LIBEL="Selection of the last contract record"
PRG=ESTC2151
export ${PRG}_I1=${DFILT}/${NJOB}_136_8_${IB}_ESTC2137_GT235_O1${IT}.dat
export ${PRG}_I2=${EST_IAVPERICASE}
export ${PRG}_I3=${EST_IRVPERICASE}
export ${PRG}_I4=${DFILT}/${NJOB}_136_${IB}_SORT_PLACEMT_O${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT235_O1${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_TERMINE_COMPTABLE_O2${IT}.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_RETRO_PAS_PLACEMENT_O3_${ICLODAT_MTH}${IT}.log
EXECPRG


#[009]
gzip -c ${DFILT}/${NJOB}_137_${IB}_ESTC2151_SRGTEF_O1${IT}.dat  > ${DFILT}/${NJOB}_137_O1_ESTC2151_SRGTEF_O1_${ICLODAT_MTH}${IT}.dat.gz
gzip -c ${DFILT}/${NJOB}_138_${IB}_ESTC2151_GT235_O1${IT}.dat  > ${DFILT}/${NJOB}_138_O1_ESTC2151_GT235_O1_${ICLODAT_MTH}${IT}.dat.gz



NSTEP=${NJOB}_140
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_125_${IB}_SORT_GT232_O${IT}.dat
RMFIL ${DFILT}/${NJOB}_105_${IB}_SORT_LIFEST_O${IT}.dat
RMFIL ${DFILT}/${NJOB}_120_${IB}_SORT_LIFEST_O${IT}.dat

NSTEP=${NJOB}_141
# Sort of Transactions File
#------------------------------------------------------------------------------
LIBEL="Sort of Transactions File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_125_${IB}_SORT_GT230_O${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_NCRIBLE_GT237_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     8:1 -  8:,
        SEC_NF    10:1 - 10:,
        UWY_NF    11:1 - 11:,
        ESTCTR_NF 46:1 - 46:,
        ESTSEC_NF 47:1 - 47:
/KEYS ESTCTR_NF,
      ESTSEC_NF,
      CTR_NF,
      SEC_NF,
      UWY_NF
exit
EOF
SORT




NSTEP=${NJOB}_142
# Complete Accounts Screen and Sort
#------------------------------------------------------------------------------
LIBEL="Complete Accounts Screen and Sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCPLACC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCPLACC_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           2:1 -  2:,
        SCOENDMTH_NF     5:1 -  5: EN
/KEYS CTR_NF
/CONDITION DECEMBRE SCOENDMTH_NF EQ 12
/INCLUDE DECEMBRE
exit
EOF
SORT

################################
#                              #
#       VENTILATION            #
#                              #
################################


#############  DEBUT WHILE  ########################################


ITERATION=4
while [ ${ITERATION} -ge 0 ]
do
#[018] ICI ESTC2151
    NSTEP=${NJOB}_145
    # Sort of Fictitious Treaties Complements
    #-------------------------------------------------------------------------
    LIBEL="Sort of Fictitious Treaties Complements"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_137_${IB}_ESTC2151_SRGTEF_O1${IT}.dat"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT245_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS CTR_NF       8:1 -  8:,
            SEC_NF      10:1 - 10:,
            UWY_NF      11:1 - 11:,
            ACY_NF      14:1 - 14: EN,
            ACMTRS_NT   45:1 - 45:
    /KEYS CTR_NF,
          SEC_NF,
          UWY_NF,
          ACMTRS_NT
    /CONDITION BILAN_MOINS_QUATRE ACY_NF = `expr ${BALSHTYEA_NF} - ${ITERATION}`
    /INCLUDE BILAN_MOINS_QUATRE
    exit
EOF
    SORT


    NSTEP=${NJOB}_153
    # Creation of the split pilot file
    #------------------------------------------------------------------------------
    LIBEL="Creation of the split pilot file"
    PRG=ESTC2152
    export ${PRG}_I1=${DFILT}/${NJOB}_145_${IB}_SORT_GT245_O${IT}.dat
    export ${PRG}_I2=${DFILT}/${NJOB}_141_${IB}_SORT_NCRIBLE_GT237_O${IT}.dat
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT_O${IT}.dat
    EXECPRG
     
    

    NSTEP=${NJOB}_154
    # Sort of the split pilot file
    #------------------------------------------------------------------------------
    LIBEL="Sort of the split pilot file"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_153_${IB}_ESTC2152_GT_O${IT}.dat 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS CTR_NF 8:1 - 8:
    /KEYS CTR_NF
    exit
EOF
    SORT


    NSTEP=${NJOB}_155
    # Split of the pilot file by mode
    #------------------------------------------------------------------------------
    LIBEL="Split of the pilot file by mode"
    PRG=ESTC2153
    export ${PRG}_I1=${DFILT}/${NJOB}_154_${IB}_SORT_GT_O${IT}.dat
    export ${PRG}_I2=${DFILT}/${NJOB}_142_${IB}_SORT_FCPLACC_O${IT}.dat
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_MODE1_GT250_O1${IT}.dat
    export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_MODE34_GT255_O2${IT}.dat
    export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_MODE5_GT260_O3${IT}.dat
    EXECPRG
     
     
    NSTEP=${NJOB}_160
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL ${DFILT}/${NJOB}_125_${IB}_SORT_GT230_O${IT}.dat
    RMFIL ${DFILT}/${NJOB}_145_${IB}_SORT_GT245_O${IT}.dat


    NSTEP=${NJOB}_165
    # Sort of Attachment File, methods 1 & 2
    #------------------------------------------------------------------------------
    LIBEL="Sort of Attachment File, methods 1 & 2"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_155_${IB}_ESTC2153_MODE1_GT250_O1${IT}.dat 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT265_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS ACMTRS_NT   45:1 - 45:,
            ESTCTR_NF   46:1 - 46:,
            ESTSEC_NF   47:1 - 47:,
            ESTUWY_NF   61:1 - 61:
    /KEYS ESTCTR_NF,
          ESTSEC_NF,
          ESTUWY_NF,
          ACMTRS_NT
    exit
EOF
    SORT


    NSTEP=${NJOB}_170
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL ${DFILT}/${NJOB}_155_${IB}_ESTC2153_MODE1_GT250_O1${IT}.dat


    NSTEP=${NJOB}_175
    # Breakdown, Processing of methods 1 & 2
    #------------------------------------------------------------------------------
    LIBEL="Breakdown, Processing of methods 1 & 2"
    PRG=ESTC2139
    FPRM=`CFTMP`
    INPUT_TEXT ${FPRM} << EOF
    BALSHTYEA_NF  ${BALSHTYEA_NF}
    CLODAT_D ${CLODAT_D}
    exit
EOF
    export ${PRG}_PRM=${FPRM}
    export ${PRG}_I1=${DFILT}/${NJOB}_165_${IB}_SORT_GT265_O${IT}.dat
    export ${PRG}_I2=${EST_FCURQUOT}
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_${ITERATION}_GT270_O${IT}.dat
    EXECPRG


    NSTEP=${NJOB}_180
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL ${DFILT}/${NJOB}_165_${IB}_SORT_GT265_O${IT}.dat


    NSTEP=${NJOB}_187
    # Sort
    #------------------------------------------------------------------------------
    LIBEL="Sort"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_130_${IB}_ESTC2145_CONVERT_GT275_O${IT}.dat 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CONVERT_GT275_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS CTR_NF       8:1 -  8:,
            SEC_NF      10:1 - 10:,
            UWY_NF      11:1 - 11:,
            ACY_NF      14:1 - 14:,
            QUART_NF		75:1 - 75:EN,
            ACMTRS_NT   45:1 - 45:
    /KEYS CTR_NF,
          SEC_NF,
          UWY_NF,
          ACY_NF,
          QUART_NF,
          ACMTRS_NT
    exit
EOF
    SORT


    NSTEP=${NJOB}_190
    # Sort of Attachment File, methods 3 & 4
    #------------------------------------------------------------------------------
    LIBEL="Sort of Attachment File, methods 3 & 4"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_155_${IB}_ESTC2153_MODE34_GT255_O2${IT}.dat 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT280_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS CTR_NF       8:1 -  8:,
            SEC_NF      10:1 - 10:,
            UWY_NF      11:1 - 11:,
            ACY_NF      14:1 - 14:,
            QUART_NF		75:1 - 75:EN,
            ACMTRS_NT   45:1 - 45:
    /KEYS CTR_NF,
          SEC_NF,
          UWY_NF,
          ACY_NF,
          QUART_NF,
          ACMTRS_NT
    exit
EOF
    SORT


    NSTEP=${NJOB}_195
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL ${DFILT}/${NJOB}_55_${IB}_ESTC2153_MODE34_GT255_O2${IT}.dat


    NSTEP=${NJOB}_200
    # Breakdown, Processing of methods 3 & 4
    #------------------------------------------------------------------------------
    LIBEL="Breakdown, Processing of methods 3 & 4"
    PRG=ESTC2144
    export ${PRG}_I1=${DFILT}/${NJOB}_190_${IB}_SORT_GT280_O${IT}.dat
    export ${PRG}_I2=${DFILT}/${NJOB}_187_${IB}_SORT_CONVERT_GT275_O${IT}.dat
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT285_O${IT}.dat
    EXECPRG


    NSTEP=${NJOB}_205
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL ${DFILT}/${NJOB}_190_${IB}_SORT_GT280_O${IT}.dat


    NSTEP=${NJOB}_210
    # Sort
    #------------------------------------------------------------------------------
    LIBEL="Sort"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_200_${IB}_ESTC2144_GT285_O${IT}.dat 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT285_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS ACMTRS_NT 45:1 - 45:,
            ESTCTR_NF 46:1 - 46:,
            ESTSEC_NF 47:1 - 47:,
            ESTUWY_NF 61:1 - 61:
    /KEYS ESTCTR_NF,
          ESTSEC_NF,
          ESTUWY_NF,
          ACMTRS_NT
    exit
EOF
    SORT


    NSTEP=${NJOB}_215
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL ${DFILT}/${NJOB}_200_${IB}_ESTC2144_GT285_O${IT}.dat


    NSTEP=${NJOB}_220
    # Breakdown, Processing of methods 3 & 4: liberation creation
    #------------------------------------------------------------------------------
    LIBEL="Breakdown, Processing of methods 3 & 4: liberation creation"
    PRG=ESTC2140
    FPRM=`CFTMP`
    INPUT_TEXT ${FPRM} << EOF
    BALSHTYEA_NF  ${BALSHTYEA_NF}
    CLODAT_D ${CLODAT_D}
    exit
EOF
    export ${PRG}_PRM=${FPRM}
    export ${PRG}_I1=${DFILT}/${NJOB}_210_${IB}_SORT_GT285_O${IT}.dat
    export ${PRG}_I2=${EST_FCURQUOT}
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_${ITERATION}_GT290_O${IT}.dat
    EXECPRG


    NSTEP=${NJOB}_225
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL ${DFILT}/${NJOB}_210_${IB}_SORT_GT285_O${IT}.dat


    NSTEP=${NJOB}_230
    # Screen and Code Conversion of Complements, methods 3 and 4
    #------------------------------------------------------------------------------
    LIBEL="Screen and Code Conversion of Complements"
    PRG=ESTC2145
    export ${PRG}_I1=${DFILT}/${NJOB}_220_${IB}_ESTC2140_${ITERATION}_GT290_O${IT}.dat
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT295_O${IT}.dat
    EXECPRG


    NSTEP=${NJOB}_235
    # Screen and Code Conversion of Transactions
    #------------------------------------------------------------------------------
    LIBEL="Screen and Code Conversion of Transactions"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_130_${IB}_ESTC2145_CONVERT_GT275_O${IT}.dat 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT277_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS CTR_NF       8:1 -  8:,
          END_NT       9:1 -  9:,
          SEC_NF      10:1 - 10:,
          UWY_NF      11:1 - 11:,
          UW_NT       12:1 - 12:,
            ACY_NF      14:1 - 14:,
            QUART_NF		75:1 - 75:EN,
            AMT_M       19:1 - 19:EN 15/3,
            FILLER1      1:1 - 44:,
            ACMTRS_NT   45:1 - 45:EN,
            FILLER2     46:1 - 66:
    /KEYS CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          ACY_NF,
          QUART_NF
    /SUM TOTAL AMT_M
    /CONDITION SELECT_CODE ACMTRS_NT EQ 1303 OR ACMTRS_NT EQ 1323
    /INCLUDE SELECT_CODE
    /DERIVEDFIELD NEWCODE "1340~"
    /OUTFILE ${SORT_O}
    /REFORMAT FILLER1, NEWCODE, FILLER2
    exit
EOF
    SORT


    NSTEP=${NJOB}_240
    # Sort of Transactions
    #------------------------------------------------------------------------------
    LIBEL="Sort of Transactions"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_235_${IB}_SORT_GT277_O${IT}.dat 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT278_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS CTR_NF       8:1 -  8:,
            SEC_NF      10:1 - 10:,
            UWY_NF      11:1 - 11:,
            ACY_NF      14:1 - 14:,
            QUART_NF		75:1 - 75:EN,
            ACMTRS_NT   45:1 - 45:
    /KEYS CTR_NF,
          SEC_NF,
          UWY_NF,
          ACY_NF,
          QUART_NF,
          ACMTRS_NT
    exit
EOF
    SORT


    NSTEP=${NJOB}_245
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL ${DFILT}/${NJOB}_235_${IB}_SORT_GT277_O${IT}.dat


    NSTEP=${NJOB}_250
    # Sort of Attachment File, method 5
    #------------------------------------------------------------------------------
    LIBEL="Sort of Attachment File, method 5"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_155_${IB}_ESTC2153_MODE5_GT260_O3${IT}.dat 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT300_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS CTR_NF       8:1 -  8:,
            SEC_NF      10:1 - 10:,
            UWY_NF      11:1 - 11:,
            ACY_NF      14:1 - 14:,
            QUART_NF		75:1 - 75:EN,
            ACMTRS_NT   45:1 - 45:
    /KEYS CTR_NF,
          SEC_NF,
          UWY_NF,
          ACY_NF,
          QUART_NF,
          ACMTRS_NT
    exit
EOF
    SORT


    NSTEP=${NJOB}_255
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL ${DFILT}/${NJOB}_155_${IB}_ESTC2153_MODE5_GT260_O3${IT}.dat


    NSTEP=${NJOB}_260
    # Breakdown, Processing of method 5
    #------------------------------------------------------------------------------
    LIBEL="Breakdown, Processing of method 5"
    PRG=ESTC2144
    export ${PRG}_I1=${DFILT}/${NJOB}_250_${IB}_SORT_GT300_O${IT}.dat
    export ${PRG}_I2=${DFILT}/${NJOB}_240_${IB}_SORT_GT278_O${IT}.dat
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GT305_O${IT}.dat
    EXECPRG


    NSTEP=${NJOB}_265
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL ${DFILT}/${NJOB}_250_${IB}_SORT_GT300_O${IT}.dat
    RMFIL ${DFILT}/${NJOB}_240_${IB}_SORT_GT278_O${IT}.dat


    NSTEP=${NJOB}_270
    # Sort
    #------------------------------------------------------------------------------
    LIBEL="Sort"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_260_${IB}_ESTC2144_GT305_O${IT}.dat 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT305_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS ACMTRS_NT 45:1 - 45:,
            ESTCTR_NF 46:1 - 46:,
            ESTSEC_NF 47:1 - 47:,
            ESTUWY_NF 61:1 - 61:
    /KEYS ESTCTR_NF,
          ESTSEC_NF,
          ESTUWY_NF,
          ACMTRS_NT
    exit
EOF
    SORT


    NSTEP=${NJOB}_275
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL ${DFILT}/${NJOB}_260_${IB}_ESTC2144_GT305_O${IT}.dat


    NSTEP=${NJOB}_280
    # Breakdown, Processing of method 5: liberation creation
    #------------------------------------------------------------------------------
    LIBEL="Breakdown, Processing of method 5: liberation creation"
    PRG=ESTC2140
    FPRM=`CFTMP`
    INPUT_TEXT ${FPRM} << EOF
    BALSHTYEA_NF  ${BALSHTYEA_NF}
    CLODAT_D ${CLODAT_D}
    exit
EOF
    export ${PRG}_PRM=${FPRM}
    export ${PRG}_I1=${DFILT}/${NJOB}_270_${IB}_SORT_GT305_O${IT}.dat
    export ${PRG}_I2=${EST_FCURQUOT}
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_${ITERATION}_GT310_O${IT}.dat
    EXECPRG


    NSTEP=${NJOB}_285
    # Delete temporary file
    #-----------------------------------------------------------------------------
    LIBEL="Delete temporary file"
    RMFIL "${DFILT}/${NJOB}_270_${IB}_SORT_GT305_O${IT}.dat"
    
    NSTEP=${NJOB}_290
    if [ ${ITERATION} -ne 0 ]
    then
        # Screen of Transactions
        #------------------------------------------------------------------------------
        LIBEL="Screen of Transactions"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_130_${IB}_ESTC2145_CONVERT_GT275_O${IT}.dat 1000 1"
        SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT320${IT}.dat 1000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS ACY_NF    14:1 - 14: EN
        /CONDITION BILAN_MOINS_QUATRE ACY_NF = `expr ${BALSHTYEA_NF} - ${ITERATION}`
        /INCLUDE BILAN_MOINS_QUATRE
        /COPY
        exit
EOF
        SORT


        NSTEP=${NJOB}_295
        # Merge of Transactions
        #------------------------------------------------------------------------------
        LIBEL="Merge of Transactions"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
        SORT_I="${DFILT}/${NJOB}_290_${IB}_SORT_GT320${IT}.dat 1000 1"
        SORT_I2="${DFILT}/${NJOB}_230_${IB}_ESTC2145_GT295_O${IT}.dat 1000 1"
        SORT_O="${DFILT}/${NJOB}_130_${IB}_ESTC2145_CONVERT_GT275_O${IT}.dat 1000 1"
        INPUT_TEXT ${SORT_CMD} <<EOF
        /FIELDS CTR_NF     8:1 -  8:,
                SEC_NF    10:1 - 10:,
                UWY_NF    11:1 - 11:,
                ESTCTR_NF 46:1 - 46:,
                ESTSEC_NF 47:1 - 47:
        /KEYS ESTCTR_NF,
              ESTSEC_NF,
              CTR_NF,
              SEC_NF,
              UWY_NF
        exit
EOF
        SORT


        NSTEP=${NJOB}_300
        # Delete temporary file
        #-----------------------------------------------------------------------------
        LIBEL="Delete temporary file"
        RMFIL ${DFILT}/${NJOB}_290_${IB}_SORT_GT320${IT}.dat
    fi

    RMFIL ${DFILT}/${NJOB}_230_${IB}_ESTC2145_GT295_O${IT}.dat

    ITERATION=`expr ${ITERATION} - 1`
done
##END WHILE
##FIN VENTILATION


#[018] ICI ESTC2151
NSTEP=${NJOB}_775
# Merge of Complements files
#------------------------------------------------------------------------------
LIBEL="Merge of Complements files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_138_${IB}_ESTC2151_GT235_O1${IT}.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SRGTE_O${IT}.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT


#[018] ICI ESTC2151
#[033]
if [ "${HOST_PRDSIT}" != "FRAM" ]
then

  NSTEP=${NJOB}_782
  # Merge of SRGTE and SRGTEF.
  #------------------------------------------------------------------------------
  LIBEL="Merge of SRGTE and SRGTEF"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_775_${IB}_SORT_SRGTE_O${IT}.dat"
  SORT_I2="${DFILT}/${NJOB}_137_${IB}_ESTC2151_SRGTEF_O1${IT}.dat"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGT_O${IT}.dat 1000 1"
  INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 -  1: EN,
        TRNCOD1_CF   6:1 -  6:1,
        ACY_NF      14:1 - 14: EN
/CONDITION SSDACY ( (SSD_CF EQ 6 AND ACY_NF LE 1995) OR
                    ((TRNCOD1_CF EQ "4" OR TRNCOD1_CF EQ "2") AND ACY_NF LT 1994 ))
/OMIT SSDACY
/COPY
exit
EOF
  SORT

else

  NSTEP=${NJOB}_783
  # Merge of SRGTE and SRGTEF for Mutre
  #------------------------------------------------------------------------------
  LIBEL="Merge of SRGTE and SRGTEF for Mutre"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_775_${IB}_SORT_SRGTE_O${IT}.dat"
  SORT_I2="${DFILT}/${NJOB}_137_${IB}_ESTC2151_SRGTEF_O1${IT}.dat"
  SORT_O="${DFILT}/${NJOB}_782_${IB}_SORT_SRGT_O${IT}.dat 1000 1"
  INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 -  1: EN,
        TRNCOD1_CF   6:1 -  6:1,
        TRNCOD8_CF   6:8 -  6:8,
        ACY_NF      14:1 - 14: EN
/CONDITION SSDACY ( (SSD_CF EQ 6 AND ACY_NF LE 1995) OR
                    ((TRNCOD1_CF EQ "4" OR TRNCOD1_CF EQ "2") AND ACY_NF LT 1994 ) OR
                    (TRNCOD8_CF EQ "C" OR TRNCOD8_CF EQ "G"))
/OMIT SSDACY
/COPY
exit
EOF
  SORT

fi

NSTEP=${NJOB}_785
# Putting Complements into TL format
#------------------------------------------------------------------------------
LIBEL="Putting Complements into TL format"
PRG=ESTC2142
export ${PRG}_I1=${DFILT}/${NJOB}_782_${IB}_SORT_SRGT_O${IT}.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DVGTAA_O1${IT}.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DVGTAR_O2${IT}.dat
EXECPRG

gzip -c ${DFILT}/${NJOB}_782_${IB}_SORT_SRGT_O${IT}.dat  > ${DFILT}/${NCHAIN}_782_SORT_SRGT_O_${ICLODAT_MTH}${IT}.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_DVGTAA_O1${IT}.dat > ${DFILT}/${NCHAIN}_785_DVGTAA_O1${ICLODAT_MTH}${IT}.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_DVGTAR_O2${IT}.dat > ${DFILT}/${NCHAIN}_785_DVGTAR_O2${ICLODAT_MTH}${IT}.dat.gz
 
NSTEP=${NJOB}_790
# Sort of TL file
#------------------------------------------------------------------------------
LIBEL="Sort of retro TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_785_${IB}_ESTC2142_DVGTAR_O2${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DVGTAR_O3${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  RETCTR_NF  24:1 - 24:,
         RETEND_NT  25:1 - 25:,
         RETSEC_NF  26:1 - 26:,
         RTY_NF     27:1 - 27:,
         RETUW_NT   28:1 - 28:,
         FILLER_41_COLS 1:1 - 41:
/OUTFILE ${SORT_O}
/DERIVEDFIELD AJOUT_30_COLS 29"~"
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/REFORMAT FILLER_41_COLS,AJOUT_30_COLS
exit
EOF
SORT


NSTEP=${NJOB}_792
# Delete internal retro
#------------------------------------------------------------------------------
LIBEL="Delete internal retro"
PRG=ESTC2143
export ${PRG}_I1=${EST_IRVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_790_${IB}_SORT_DVGTAR_O3${IT}.dat
export ${PRG}_I3=${EST_SUBTRSESBPROP}
export ${PRG}_O1=${EST_DLVGTAR}
export ${PRG}_O2=${DFILI}/${NSTEP}_${IB}_SORT_Ano${IT}.dat
EXECPRG


NSTEP=${NJOB}_794
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_790_${IB}_SORT_DVGTAR_O3${IT}.dat
RMFIL ${DFILT}/${NJOB}_782_${IB}_SORT_SRGT_O${IT}.dat


NSTEP=${NJOB}_805
# Selection of the last contract record
#------------------------------------------------------------------------------
LIBEL="Selection of the last contract record"
PRG=ESTC2131
export ${PRG}_I1=${DFILT}/${NJOB}_136_${IB}_SORT_PLACEMT_O${IT}.dat
export ${PRG}_I2=${EST_DLVGTAR}
export ${PRG}_O1=${EST_DLVGTR}
EXECPRG


NSTEP=${NJOB}_810
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL "${DFILT}/${NJOB}_136_${IB}_SORT_PLACEMT_O${IT}.dat"



NSTEP=${NJOB}_815
# Sort of DVGTAA file
#------------------------------------------------------------------------------
LIBEL="Sort of DVGTAA file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_785_${IB}_ESTC2142_DVGTAA_O1${IT}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DVGTAA_O${IT}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        ESB_CF           2:1 -  2:EN,
        BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:EN,
        BALSHRDAY_NF     5:1 -  5:EN,
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
        RETKEY_CF       40:1 - 40:
/OUTFILE ${SORT_O}
/DERIVEDFIELD ZERO "0.000" CHAR 5
/DERIVEDFIELD AJOUT_30_COLS 30"~"
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
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
          ZERO,
          AJOUT_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_820
# Delete internal retro
#------------------------------------------------------------------------------
LIBEL="Delete internal retro"
PRG=ESTC2146
export ${PRG}_I1=${EST_IAVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_815_${IB}_SORT_DVGTAA_O${IT}.dat
export ${PRG}_I3=${EST_SUBTRSESBPROP}
export ${PRG}_O1=${EST_DLVGTAA}
export ${PRG}_O2=${DFILI}/${NSTEP}_${IB}_SORT_Ano${IT}.dat
EXECPRG

#if [ ${ICLODAT_MTH} = 12 ]  #[037]
if [ ${MODE} == "PA" ]       #[037]
then
    # No Filtration of Estimates
    NSTEP=${NJOB}_823
    # REFORMAT SRGTE
    #------------------------------------------------------------------------------
    LIBEL="REFORMAT SRGTE"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_775_${IB}_SORT_SRGTE_O${IT}.dat 1000 1"
    SORT_I2="${DFILT}/${NJOB}_138_${IB}_ESTC2151_TERMINE_COMPTABLE_O2${IT}.dat 1000 1"
    SORT_O="${EST_SRGTE}"
    INPUT_TEXT $SORT_CMD <<EOF
    /FIELDS SSD_DBLTRNCOD    1:1 -  2:,
            BALSHEY_NF       3:1 -  3:,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        FILLER1          8:1 - 40:,
                    FILLER2         41:1 - 67:
    /COPY
    /CONDITION NONVIE ( TRNCOD_CF = "")
    /OMIT NONVIE
    /OUTFILE ${SORT_O}
    exit
EOF
    SORT

#[018] ICI ESTC2151
    NSTEP=${NJOB}_825
    # REFORMAT SRGTEF
    #------------------------------------------------------------------------------
    LIBEL="REFORMAT SRGTEF"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_137_${IB}_ESTC2151_SRGTEF_O1${IT}.dat 1000 1"
    SORT_I2="${DFILT}/${NJOB}_137_${IB}_ESTC2151_TERMINE_COMPTABLE_O2${IT}.dat 1000 1"
    SORT_O="${EST_SRGTEF}"
    INPUT_TEXT $SORT_CMD <<EOF
    /FIELDS SSD_DBLTRNCOD    1:1 -  2:,
        BALSHEY_NF       3:1 -  3:,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        FILLER1          8:1 - 40:,
                    FILLER2         41:1 - 67:
    /COPY
    /CONDITION NONVIE ( TRNCOD_CF = "")
    /OMIT NONVIE
    /OUTFILE ${SORT_O}
    exit
EOF
    SORT

else
    NSTEP=${NJOB}_830
    # Sort of SRGTE file
    #------------------------------------------------------------------------------
    LIBEL="Sort of SRGTE file"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_775_${IB}_SORT_SRGTE_O${IT}.dat"
    SORT_I2="${DFILT}/${NJOB}_138_${IB}_ESTC2151_TERMINE_COMPTABLE_O2${IT}.dat 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTE_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS CTR_NF  8:1 -  8:,
            END_NT  9:1 -  9:,
            SEC_NF 10:1 - 10:,
            UWY_NF 11:1 - 11:,
            UW_NT  12:1 - 12:
    /KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
    exit
EOF
    SORT

#[018] ICI ESTC2151
    NSTEP=${NJOB}_835
    # Sort of SRGTEF file
    #------------------------------------------------------------------------------
    LIBEL="Sort of SRGTEF file"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_137_${IB}_ESTC2151_SRGTEF_O1${IT}.dat"
    SORT_I2="${DFILT}/${NJOB}_137_${IB}_ESTC2151_TERMINE_COMPTABLE_O2${IT}.dat 1000 1"
    SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SRGTEF_O${IT}.dat 1000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
    /FIELDS CTR_NF  8:1 -  8:,
            END_NT  9:1 -  9:,
            SEC_NF 10:1 - 10:,
            UWY_NF 11:1 - 11:,
            UW_NT  12:1 - 12:
    /KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
    exit
EOF
    SORT
gzip -c ${DFILT}/${NJOB}_137_${IB}_ESTC2151_SRGTEF_O1${IT}.dat  > ${DFILT}/${NCHAIN}_137_ESTC2151_SRGTEF_O1_${ICLODAT_MTH}${IT}.dat.gz


    NSTEP=${NJOB}_840
    # Filtration of Estimates
    #------------------------------------------------------------------------------
    #LIBEL="Filtration of Estimates"
    PRG=ESTC2154
    FPRM=`CFTMP`
    INPUT_TEXT ${FPRM} << EOF
    CLODAT_D ${CLODAT_D}
    BALSHTYEA_NF ${BALSHTYEA_NF}
    exit
EOF
    export ${PRG}_PRM=${FPRM}
    export ${PRG}_I1=${EST_IARVPERICASE0}
    export ${PRG}_I2=${DFILT}/${NJOB}_830_${IB}_SORT_SRGTE_O${IT}.dat
    export ${PRG}_I3=${DFILT}/${NJOB}_835_${IB}_SORT_SRGTEF_O${IT}.dat
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTE_O1${IT}.dat
    export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTEF_O2${IT}.dat
    EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_SRGTEF_O2${IT}.dat  > ${DFILT}/${NCHAIN}_${PRG}_SRGTEF_O2_${ICLODAT_MTH}${IT}.dat.gz

    NSTEP=${NJOB}_842
    # REFORMAT SRGTE
    #------------------------------------------------------------------------------
    LIBEL="REFORMAT SRGTE"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_840_${IB}_ESTC2154_SRGTE_O1${IT}.dat 1000 1"
    SORT_O="${EST_SRGTE}"
    INPUT_TEXT $SORT_CMD <<EOF
    /FIELDS SSD_DBLTRNCOD    1:1 -  2:,
        BALSHEY_NF       3:1 -  3:,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        FILLER1          8:1 - 40:,
        FILLER2         41:1 - 67:
    /COPY
    /CONDITION NONVIE ( TRNCOD_CF = "")
    /OMIT NONVIE
    /OUTFILE ${SORT_O}
    exit
EOF
    SORT

    NSTEP=${NJOB}_845
    # REFORMAT SRGTEF
    #------------------------------------------------------------------------------
    LIBEL="REFORMAT SRGTEF"
    SORT_WDIR=${SORTWORK}
    SORT_CMD=`CFTMP`
    SORT_I="${DFILT}/${NJOB}_840_${IB}_ESTC2154_SRGTEF_O2${IT}.dat 1000 1"
    SORT_O="${EST_SRGTEF}"
    INPUT_TEXT $SORT_CMD <<EOF
    /FIELDS SSD_DBLTRNCOD    1:1 -  2:,
        BALSHEY_NF       3:1 -  3:,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        FILLER1          8:1 - 40:,
        FILLER2         41:1 - 67:
    /COPY
    /CONDITION NONVIE ( TRNCOD_CF = "")
    /OMIT NONVIE
    /OUTFILE ${SORT_O}
    exit
EOF
    SORT
fi

NSTEP=${NJOB}_990
# Delete temporary & permanent files
#------------------------------------------------------------------------------
LIBEL="Delete temporary & permanent files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*${IT}.dat"

# Job End
JOBEND
