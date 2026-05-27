#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des Cashflow et valeur escompte
# nom du script SHELL           : ESID3702.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/04/2012
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  :spot:23802 Calcul des Cashflow et valeur escompte
#
#-----------------------------------------------------------------------------
# historiques des modifications
#===============================================================================
#[01] 29/08/2012 R. Cassis     :spot:24041 - Modifs Solvency 2
#[02] 20/01/2013 - -=PhP=-     :spot:24698 corrections pour la conso
#[03] 20/01/2013 - -=PhP=-     :spot:24836 corrections pour la conso
#[04] 20/01/2013 - -=PhP=-     :spot:24867 corrections pour la conso
#[05] 29/05/2013 PPEZOUT       :spot:25171 Modifications Solvency
#[06] 20/01/2013 - -=PhP=-     :spot:25399 corrections pour la conso
#[07] 23/05/2014 A. Ben Jeddou :spot 26838 Corrections sur le batch solvency P&C : reprise de code suite au passage  de 2A � la 1B
#[08] 10/07/2014 C. DESPRET    :spot:xxxxx Remove Life subsidiaries 
#[09] 24/10/2013 :spot:26391 - Cyrille  - Prise en compte des fichiers GT Funds WithHeld accept et retro
#[10] 28/10/2013 :spot:26391 - Cyrille  - Ventilation par acceptation des depots GT Retro proportionnelle
#[11] 28/04/2015 :spot:26391 - Florent  - ajout condition poste 84
#[12] 04/06/2015 :spot:26391 - Roger    - Correction condition sur tri/include 'NO' en 'NON' sur condition depot step 255
#[13] 08/06/2015 :spot:26391 - Roger    - Diverses corrections sur tri steps 261 et 271
#[14] 17/06/2015 :spot:26391 - Roger    - Diverses corrections sur tri steps 255 et 261 et 18 et 50
#[15] 25/06/2015 :spot:28941 - PP/Roger - Diverses corrections pour EST49A2 EBS ULAE et Risk Management
#[16] 05/11/2015 :spot:29641 - Florent  - EBS : pb de ventilation par placements des agr�gats d�pots, step 271
#[17] 02/11/2015 :spot:29615 - P PEZOUT
#[18] 26/05/2016 S.Behague :spot:30583: Spira 41148
#[19] 10/06/2016 Roger Cassis  :spot:29629 gestion de l'allocation R�tro des NP
#[20] 28/06/2016 :spot:31251 - Florent       - spira 48151- EBS - UPR cancel - correction pour le mix of internal and external retrocessionaire: modif step 150 et 250 pour GTAA et GTAR
#                                            - ne plus mettre � z�ro le RETINTAMT_M
#[021] 23/04/2018 Roger Cassis :spira:61675 Le ICLODAT_D est ajout� au parm du ESTC8805 pour compatibilit� avec ESID2561.cmd
#[22] 31/10/2018 Rafael Vieville :spira:71038 Changement du ACMTRS 312 par 307 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
ICLODAT_D=$3
TYPEINV=$4
ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`

#The Balance Sheet month result is
MTHFIN_NF=`echo ${ICLODAT_D} | awk '{ print substr($0,5,2)}'`
#generate start month quarter=month-2
MTHDEB_NF=`echo ${MTHFIN_NF} | awk '{ hist = $0 - 2; print hist }'`
#if [ "${EST_ESPD2000_COND3}" = "Y" ]
#then
#	export EST_CURGTA=${DARCH}/`basename ${EST_CURGTA} .dat`_${ICLODAT_A}${ICLODAT_M}.arc
#fi
#
touch ${DFILT}/${NCHAIN}_vide.dat

TYPEPO=""
if [ "${TYPEINV}" != "INV" ]
then
  EST_FBOPRSLNK=${EPO_FBOPRSLNK}
  EST_DLRTFGTAR=${DFILT}/${NCHAIN}_vide.dat
  EST_DLRTCGTAR=${DFILT}/${NCHAIN}_vide.dat
  EST_DLRTGTAR=${DFILT}/${NCHAIN}_vide.dat
  EST_DLRPGTAR=${DFILT}/${NCHAIN}_vide.dat
  EST_DLRNPGTAR=${DFILT}/${NCHAIN}_vide.dat
  EST_CURGTA=${EPO_FTECLEDASO}  
  EST_DLRGTAA=${EPO_DLRGTAA}
  if [ "${TYPEINV}" = "POS" ]
  then
    EST_DLDGTAA=${EPO_DLDGTAASO}
    EST_DLSGTAA=${EPO_DLSGTAASIISO}
    EST_DLREGTAR=${EPO_DLREGTARSO}
    EST_DLREMAJGTAR=${EPO_DLREMAJGTARSO}
    EST_DLSGTAR=${EPO_DLSGTARSIISO}
    EST_DLSGTR=${EPO_DLSGTRSIISO}
    EST_FULAERAT=${EPO_FULAERATSO}        #[015]
    TYPEPO=SO
  else
    EST_DLDGTAA=${EPO_DLDGTAACO}
    EST_DLSGTAA=${EPO_DLSGTAACO}
    EST_DLREGTAR=${EPO_DLREGTARCO}
    EST_DLREMAJGTAR=${EPO_DLREMAJGTARCO}
    EST_DLSGTAR=${EPO_DLSGTARCO}
    EST_DLSGTR=${EPO_DLSGTRCO}
    EST_FULAERAT=${EPO_FULAERATCO}        #[015]
    TYPEPO=CO
  fi
  EST_IADPERICASE=${EPO_IADPERICASE}
  EST_IRDPERICASE0=${EPO_IRDPERICASE0}
  EST_FPLATXCUMALL=${EPO_FPLATXCUMALL}
  EST_FCTRGRO=${EPO_FCTRGRO}
  EST_FTRSLNK=${EPO_FTRSLNK}
  EST_FCURQUOT=${EPO_FCURQUOT}
  EST_FDETTRS=${EPO_FDETTRS}
  EST_DLCUMGTAAR=${EPO_DLCUMGTAAR}
  EST_DLCUMGTAAR_IBNR_FUTCLAIMS=${EPO_DLCUMGTAAR_IBNR_FUTCLAIMS}  #[015] 
  EST_FWHGTA=${EPO_FWHGTA}
  EST_FWHGTR=${EPO_FWHGTR}  
  EST_FLIBEL2=${DFILT}/${NCHAIN}_vide.dat
fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV........................: ${TYPEINV}"
ECHO_LOG "#===> TYPEPO.........................: ${TYPEPO}"
ECHO_LOG "#===> BALSHTYEA_NF...................: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF...................: ${BALSHTMTH_NF}"
ECHO_LOG "#===> ICLODAT_D......................: ${ICLODAT_D}"
ECHO_LOG "#===> ICLODAT_A......................: ${ICLODAT_A}"
ECHO_LOG "#===> ICLODAT_M......................: ${ICLODAT_M}"
ECHO_LOG "#===> ICLODAT_J......................: ${ICLODAT_J}"
ECHO_LOG "#===> EST_IADPERICASE................: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_IRDPERICASE0...............: ${EST_IRDPERICASE0}"
ECHO_LOG "#===> EST_FPLATXCUMALL...............: ${EST_FPLATXCUMALL}"
ECHO_LOG "#===> EST_FCTRGRO....................: ${EST_FCTRGRO}"
ECHO_LOG "#===> EST_FTRSLNK....................: ${EST_FTRSLNK}"
ECHO_LOG "#===> EST_FCURQUOT...................: ${EST_FCURQUOT}"
ECHO_LOG "#===> EST_FDETTRS....................: ${EST_FDETTRS}"
ECHO_LOG "#===> EST_DLDGTAA....................: ${EST_DLDGTAA}"
ECHO_LOG "#===> EST_DLSGTAA....................: ${EST_DLSGTAA}"
ECHO_LOG "#===> EST_DLREGTAR...................: ${EST_DLREGTAR}"
ECHO_LOG "#===> EST_DLREMAJGTAR................: ${EST_DLREMAJGTAR}"
ECHO_LOG "#===> EST_DLSGTAR....................: ${EST_DLSGTAR}"
ECHO_LOG "#===> EST_CURGTA.....................: ${EST_CURGTA}"
#[009]
ECHO_LOG "#===> EST_FWHGTA.....................: ${EST_FWHGTA}"
ECHO_LOG "#===> EST_FWHGTR.....................: ${EST_FWHGTR}"
#[010]
ECHO_LOG "#===> EST_FLIBEL2....................: ${EST_FLIBEL2}"
ECHO_LOG "#===> EST_DLCUMGTAAR_IBNR_FUTCLAIMS..: ${EST_DLCUMGTAAR_IBNR_FUTCLAIMS}"

ECHO_LOG "#===> EST_DLRGTAA....................: ${EST_DLRGTAA}"
ECHO_LOG "#===> EST_FBOPRSLNK..................: ${EST_FBOPRSLNK}"


if [ "${TYPEINV}" = "POC" ]
then
  ECHO_LOG "#===> EPO_FTECLEDASIISO................: ${EPO_FTECLEDASIISO}"
fi
ECHO_LOG "#===> EST_DLCUMGTAAR.................: ${EST_DLCUMGTAAR}"    
ECHO_LOG "#===> EST_FULAERAT...................: ${EST_FULAERAT}"    

ECHO_LOG "#========================================================================="

datej=`date '+%Y%m%d%H%M%S'`
datedel=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-1; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel1=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-2; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel2=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-3; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`

NSTEP=${NJOB}_00
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${datedel}*.dat ${DFILT}/${NJOB}*${datedel1}*.dat ${DFILT}/${NJOB}*${datedel2}*.dat"

NSTEP=${NJOB}_05
#Comparison of period closing and segmentation perimeters
#(by the contract grouping file)
#-----------------------------------------------------------------------------
LIBEL="Extract SEG_NF information from ctrgro and put it into Pericase"
PRG=ESTM1004
export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CTRGRO_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE.dat
EXECPRG

NSTEP=${NJOB}_10
# MOD003 -  Sort of IADPERICASE
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_ESTM1004_IADPERICASE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    3:1 -  3:,
        END_NT    4:1 -  4:,
        SEC_NF    5:1 -  5:EN,
        UWY_NF    6:1 -  6:,
        UW_NT     7:1 -  7:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_11
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
GZIPM_I="${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE_O.dat"
GZIPM

NSTEP=${NJOB}_15
# MOD003 -  Sort of IRDPERICASE
#-----------------------------------------------------------------------------
LIBEL="Sort of IRDPERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    3:1 -  3:,
        END_NT    4:1 -  4:,
        SEC_NF    5:1 -  5:EN,
        UWY_NF    6:1 -  6:,
        UW_NT     7:1 -  7:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

#[009] Changement numero de step
NSTEP=${NJOB}_18
#-----------------------------------------------------------------------------
# GTAa files merge
#[006]
#[007]
#[008] Remove Life subsidiaries
#[009] Suppression des doublons Funds WithHeld : on ne conserve que ceux du fichier des Funds withheld (EST_FWHGTA)
# on supprime ceux contenus dans les autres fichiers : TRNCOD34_CF != '81' et '84' (code depot)
# on veut aussi conserver les �critures service dont le 2ieme caractere du code est G (meme pour les depots)
#[014]
#-----------------------------------------------------------------------------
LIBEL="GTA AGREGATES Merge and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA} 1000 1"
SORT_I2="${EST_DLSGTAA} 1000 1"
if [ "${TYPEINV}" = "INV" ]
then
  SORT_I3="${EST_DLAGTAA} 1000 1"
  SORT_I4="${EST_IGTAAF} 1000 1"
else
  SORT_I3="${EST_CURGTA} 1000 1"
  if [ "${TYPEINV}" = "POC" ]
  then
    SORT_I4="${EPO_DLSGTAASIICO} 1000 1"
    SORT_I5="${EPO_FTECLEDASIISO} 1000 1"
  fi
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        AMT_M            19:1 - 19:EN 15/3,
        RETAMT_M         35:1 - 35:EN 15/3,
        FILLER1           1:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF
/CONDITION COND_TRNCOD TRNCOD1_CF = "1" AND "1357" NC TRNCOD8_CF
                   AND ( BALSHEY_NF = "${ICLODAT_A}" AND BALSHRMTH_NF <= ${ICLODAT_M} )
                   AND ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" AND TRNCOD3_CF != "1008" )
                   AND ( TRNCOD4_CF != "49413" AND TRNCOD4_CF != "46000" AND TRNCOD4_CF != "20053" AND TRNCOD4_CF != "20910" AND TRNCOD4_CF != "46002")
                   AND ( ("246" CT TRNCOD8_CF AND "1A" CT TRNCOD2_CF) OR "4EG" CT TRNCOD2_CF OR
                          ( TRNCOD_CF = "11102000" OR TRNCOD_CF = "11102100" OR TRNCOD_CF = "11102200" OR TRNCOD_CF = "11102300" OR TRNCOD_CF = "11102400" OR TRNCOD_CF = "11102500" OR
                            TRNCOD_CF = "11103000" OR TRNCOD_CF = "11103100" OR TRNCOD_CF = "11103200" OR TRNCOD_CF = "11103300" OR TRNCOD_CF = "11103400" OR TRNCOD_CF = "11103500" OR
                            TRNCOD_CF = "11141000" OR TRNCOD_CF = "11142000" OR TRNCOD_CF = "11420000" OR TRNCOD_CF = "11420100" OR TRNCOD_CF = "11420200" OR TRNCOD_CF = "11420300" OR
                            TRNCOD_CF = "11420400" OR TRNCOD_CF = "11420500" OR TRNCOD_CF = "11420600" OR TRNCOD_CF = "11420800" OR TRNCOD_CF = "11420900" OR TRNCOD_CF = "11421000" OR
                            TRNCOD_CF = "11421100" OR TRNCOD_CF = "11421200" OR TRNCOD_CF = "11421300" OR TRNCOD_CF = "11421400" OR TRNCOD_CF = "11421500" OR TRNCOD_CF = "11421600" OR
                            TRNCOD_CF = "11421800" OR TRNCOD_CF = "11421900" OR TRNCOD_CF = "11423000" OR TRNCOD_CF = "11424000" OR TRNCOD_CF = "11427000" OR TRNCOD_CF = "11427900" OR
                            TRNCOD_CF = "11428000" OR TRNCOD_CF = "11428900" OR TRNCOD_CF = "11440000" OR TRNCOD_CF = "11441000" OR TRNCOD_CF = "11450000" OR TRNCOD_CF = "11450100" OR
                            TRNCOD_CF = "11451000" OR TRNCOD_CF = "11451100" OR TRNCOD_CF = "11460000" OR TRNCOD_CF = "11460100" OR TRNCOD_CF = "11460200" OR TRNCOD_CF = "11461000" OR
                            TRNCOD_CF = "11461100" OR TRNCOD_CF = "11461200" OR TRNCOD_CF = "11480000" OR TRNCOD_CF = "11480100" OR TRNCOD_CF = "11480200" OR TRNCOD_CF = "11481000" OR
                            TRNCOD_CF = "11481100" OR TRNCOD_CF = "11481200" OR TRNCOD_CF = "11487000" OR TRNCOD_CF = "11488000" OR TRNCOD_CF = "11492000" OR TRNCOD_CF = "11492100" OR
                            TRNCOD_CF = "11492200" OR TRNCOD_CF = "11493000" OR TRNCOD_CF = "11493100" OR TRNCOD_CF = "11493200" OR TRNCOD_CF = "11494000" OR TRNCOD_CF = "11494100" OR
                            TRNCOD_CF = "11495000" OR TRNCOD_CF = "11495100"
                          )
                       )
                   AND ((SSD_CF=7 AND ESB_CF!=2) OR (SSD_CF=20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
                   AND ( (TRNCOD34_CF != '81' AND TRNCOD34_CF != '84' ) or ( TRNCOD2_CF="G" AND (TRNCOD34_CF = '81' OR TRNCOD34_CF = '84' ))  )
/DERIVEDFIELD PLUS_15_CHAMPS "~~~~~~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
/REFORMAT FILLER1,PLUS_15_CHAMPS,ORICOD_LS
exit
EOF
SORT

NSTEP=${NJOB}_18B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichier"
GZIPM_I="${DFILT}/${NJOB}_18_${IB}_SORT_DLSIIGTAA_O.dat"
GZIPM

#[009]
NSTEP=${NJOB}_19
#-----------------------------------------------------------------------------
# GTAa Funds Withheld
#-----------------------------------------------------------------------------
LIBEL="GTAa Funds Withheld"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FWHGTA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FWHGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        AMT_M            19:1 - 19:EN 15/3,
        RETAMT_M         35:1 - 35:EN 15/3,
        FILLER1           1:1 - 41:,
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF
/CONDITION COND_TRNCOD TRNCOD1_CF = "1"
                   AND ((SSD_CF=7 AND ESB_CF!=2) OR (SSD_CF=20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
                   AND (TRNCOD34_CF = '81' OR TRNCOD34_CF = '84')                                             
/DERIVEDFIELD PLUS_15_CHAMPS "~~~~~~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
/REFORMAT FILLER1,PLUS_15_CHAMPS,ORICOD_LS
exit
EOF
SORT

#[009]
NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
# GTAa files merge
#-----------------------------------------------------------------------------
LIBEL="GTA AGREGATES Merge with FWHGTA and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_18_${IB}_SORT_DLSIIGTAA_O.dat 1000 1"
#[009] Prise en compte du fichier GT des Funds WithHeld accept
SORT_I2="${DFILT}/${NJOB}_19_${IB}_SORT_FWHGTAA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGTAA_O.dat"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD2_CF        6:2 -  6:2,        
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        FILLER1           1:1 - 40:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

ECHO_LOG "#===> ICLODAT_A.........: ${ICLODAT_A}"

NSTEP=${NJOB}_50
#Accumulation of acceptation and retrocession amount by ACMTRS_NT
#[006]
#[007]
#[008] Remove Life subsidiaries
#[009] Suppression des doublons Funds WithHeld : on ne conserve que ceux du fichier des Funds withheld (EST_FWHGTR)
# on supprime ceux contenus dans les autres fichiers : TRNCOD34_CF != '81' et '84'(code depot)
# on veut aussi conserver les �critures service dont le 2ieme caractere du code est G (meme pour les depots)
#[014]
#-----------------------------------------------------------------------------
LIBEL="GTAR AGREGATES Merge and sort of dGTAR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${TYPEINV}" = "INV" ]
then
  SORT_I="${EST_IGTAR}    1000 1"
  SORT_I2="${EST_DLRTFGTAR} 1000 1"
  SORT_I3="${EST_DLAGTAR}   1000 1"
  SORT_I4="${EST_DLRTCGTAR} 1000 1"
  SORT_I5="${EST_DLRTGTAR}  1000 1"
  SORT_I6="${EST_DLRPGTAR}  1000 1"
  SORT_I7="${EST_DLRNPGTAR} 1000 1"
  SORT_I8="${EST_DLREGTAR} 1000 1"
  SORT_I9="${EST_DLREMAJGTAR} 1000 1"
  SORT_I10="${EST_DLSGTAR} 1000 1"
else
  SORT_I="${EST_CURGTA} 1000 1"
  SORT_I2="${EST_DLREGTAR} 1000 1"
  SORT_I3="${EST_DLREMAJGTAR} 1000 1"
  SORT_I4="${EST_DLSGTAR} 1000 1"
  if [ "${TYPEINV}" = "POC" ]
  then
    SORT_I5="${EPO_FTECLEDASIISO} 1000 1"
    SORT_I6="${EPO_DLSGTARSIICO} 1000 1"
  fi
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 35:,
        FILLER2          38:1 - 40:
/KEYS   RETCTR_NF,
        RETEND_NT,
        RTY_NF,
        RETUW_NT,
        RETSEC_NF,
        TRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CUR_CF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RETCUR_CF,
        PLC_NT,
        RTO_NF
/CONDITION COND_TRNCOD TRNCOD1_CF = "2" AND "1357" NC TRNCOD8_CF
                   AND ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} )
                   AND ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" AND TRNCOD3_CF != "1008" )
                   AND ( TRNCOD4_CF != "49413" AND TRNCOD4_CF != "46000" AND TRNCOD4_CF != "20053" AND TRNCOD4_CF != "20910" AND TRNCOD4_CF != "46002")
                   AND ( ("246" CT TRNCOD8_CF AND "1A" CT TRNCOD2_CF) OR "4EG" CT TRNCOD2_CF OR
                          ( TRNCOD_CF = "21102000" OR TRNCOD_CF = "21102100" OR TRNCOD_CF = "21102200" OR TRNCOD_CF = "21102300" OR TRNCOD_CF = "21102400" OR TRNCOD_CF = "21102500" OR
                            TRNCOD_CF = "21103000" OR TRNCOD_CF = "21103100" OR TRNCOD_CF = "21103200" OR TRNCOD_CF = "21103300" OR TRNCOD_CF = "21103400" OR TRNCOD_CF = "21103500" OR
                            TRNCOD_CF = "21141000" OR TRNCOD_CF = "21142000" OR TRNCOD_CF = "21420000" OR TRNCOD_CF = "21420100" OR TRNCOD_CF = "21420200" OR TRNCOD_CF = "21420300" OR
                            TRNCOD_CF = "21420400" OR TRNCOD_CF = "21420500" OR TRNCOD_CF = "21420600" OR TRNCOD_CF = "21420800" OR TRNCOD_CF = "21420900" OR TRNCOD_CF = "21421000" OR
                            TRNCOD_CF = "21421100" OR TRNCOD_CF = "21421200" OR TRNCOD_CF = "21421300" OR TRNCOD_CF = "21421400" OR TRNCOD_CF = "21421500" OR TRNCOD_CF = "21421600" OR
                            TRNCOD_CF = "21421800" OR TRNCOD_CF = "21421900" OR TRNCOD_CF = "21423000" OR TRNCOD_CF = "21424000" OR TRNCOD_CF = "21427000" OR TRNCOD_CF = "21427900" OR
                            TRNCOD_CF = "21428000" OR TRNCOD_CF = "21428900" OR TRNCOD_CF = "21440000" OR TRNCOD_CF = "21441000" OR TRNCOD_CF = "21450000" OR TRNCOD_CF = "21450100" OR
                            TRNCOD_CF = "21450200" OR TRNCOD_CF = "21451000" OR TRNCOD_CF = "21451100" OR TRNCOD_CF = "21451200" OR TRNCOD_CF = "21460200" OR TRNCOD_CF = "21461200" OR
                            TRNCOD_CF = "21480000" OR TRNCOD_CF = "21480100" OR TRNCOD_CF = "21480200" OR TRNCOD_CF = "21481000" OR TRNCOD_CF = "21481100" OR TRNCOD_CF = "21481200" OR
                            TRNCOD_CF = "21487000" OR TRNCOD_CF = "21488000" OR TRNCOD_CF = "21492000" OR TRNCOD_CF = "21492100" OR TRNCOD_CF = "21492200" OR TRNCOD_CF = "21493000" OR
                            TRNCOD_CF = "21493100" OR TRNCOD_CF = "21493200" OR TRNCOD_CF = "21494100" OR TRNCOD_CF = "21495100"
                           )
                       )
                   AND ((SSD_CF=7 AND ESB_CF!=2) OR (SSD_CF=20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
                   AND ( (TRNCOD34_CF != '81' AND TRNCOD34_CF != '84' ) or ( TRNCOD2_CF="G" AND (TRNCOD34_CF = '81' OR TRNCOD34_CF = '84' ))  )                                                               
/DERIVEDFIELD PLUS_16_CHAMPS "~P~~~~~~~~~~~~~~~"
/DERIVEDFIELD PLUS_02_CHAMPS "~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
/REFORMAT FILLER1,PLUS_02_CHAMPS,FILLER2,PLUS_16_CHAMPS,ORICOD_LS
exit
EOF
SORT





NSTEP=${NJOB}_80
#Accumulation of acceptation and retrocession amount by ACMTRS_NT
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES Accumulation of retrocession amount by ACMTRS_NT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_DLSIIGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 18:,
        FILLER2          20:1 - 34:,
        FILLER3          36:1 - 40:,
        FILLER4          42:1 - 56:
/KEYS   RETCTR_NF,
        RTY_NF,
        RETSEC_NF,
        PLC_NT,
        RETEND_NT,
        RETUW_NT,
        RETCUR_CF,
        RTO_NF,
        TRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        CUR_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION MONTANT ( AMT_MC !=0 OR RETAMT_MC !=0 )
/CONDITION COND_ORIGINE ( "AEJ" CT TRNCOD2_CF )
/DERIVEDFIELD VAL_ORIGINE if COND_ORIGINE then "EBSGTA" else "GTAR"
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
/REFORMAT FILLER1,AMT_MC,FILLER2,RETAMT_MC,FILLER3,RETINTAMT_MC,FILLER4,VAL_ORIGINE
exit
EOF
SORT


NSTEP=${NJOB}_130
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLATXCUMALL}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUMALL.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 2:1 - 2:EN,
        RETRTY_NF 3:1 - 3:,
        PLC_NT    4:1 - 4:EN
/KEYS RETCTR_NF, RETRTY_NF, RETSEC_NF, PLC_NT
/SUM
/STABLE
exit
EOF
SORT

NSTEP=${NJOB}_130B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichier"
GZIPM_I="${DFILT}/${NJOB}_130_${IB}_FPLATXCUMALL.dat"
GZIPM

NSTEP=${NJOB}_150
# Affectation par placement
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES retro Affectation par placement"
PRG=ESTC1052
export ${PRG}_I1=${DFILT}/${NJOB}_130_${IB}_FPLATXCUMALL.dat
export ${PRG}_I2=${DFILT}/${NJOB}_80_${IB}_SORT_DLSIIGTAR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSIIGTAR.dat
EXECPRG

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC1052 "
ECHO_LOG "#===> Nombre de lignes RETRO total "
wc -l ${DFILT}/${NJOB}_80_${IB}_SORT_DLSIIGTAR_O.dat
ECHO_LOG "#===> Nombre de lignes RETRO ventilees par placement "
wc -l ${DFILT}/${NJOB}_150_${IB}_ESTC1052_DLSIIGTAR.dat
ECHO_LOG "#===> Nombre de lignes ACCEPT "
wc -l ${DFILT}/${NJOB}_20_${IB}_SORT_DLSIIGTAA_O.dat
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_180
#Accumulation of acceptation and retrocession
#-----------------------------------------------------------------------------
LIBEL="GTA + GTAR AGREGATES Accumulation of acceptation and retrocession"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_DLSIIGTAA_O.dat  1000 1"
SORT_I2="${DFILT}/${NJOB}_150_${IB}_ESTC1052_DLSIIGTAR.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSIIGTAAR_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 41:
/KEYS   CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,PLC_NT
/DERIVEDFIELD PLUS_15_CHAMPS "~~~~~~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1,PLUS_15_CHAMPS,ORICOD_LS
exit
EOF
SORT

NSTEP=${NJOB}_180B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_20_${IB}_SORT_DLSIIGTAA_O.dat ${DFILT}/${NJOB}_50_${IB}_SORT_DLSIIGTAR_O.dat ${DFILT}/${NJOB}_80_${IB}_SORT_DLSIIGTAR_O.dat ${DFILT}/${NJOB}_150_${IB}_ESTC1052_DLSIIGTAR.dat ${DFILT}/${NJOB}_180_${IB}_SORT_DLSIIGTAAR_O.dat"
GZIPM

NSTEP=${NJOB}_200
#------------------------------------------------------------------------------
LIBEL="CSF AGREGATES 1051 ACCEPT Add cols data to GT format ACMTRS/LOB/CUR + CONVERSION "
PRG=ESTC1051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT A
BALSHTYEA_NF ${BALSHTYEA_NF}
PRS_CF 750
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_180_${IB}_SORT_DLSIIGTAAR_O.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTESTCUMUL1_ACCRET.dat
EXECPRG

NSTEP=${NJOB}_200B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_200_${IB}_ESTC1051_GTESTCUMUL1_ACCRET.dat"
GZIPM

NSTEP=${NJOB}_220
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES 1051 SORT OF retrocession"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_ESTC1051_GTESTCUMUL1_ACCRET.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD3_CF        6:3 -  6:6,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:
/KEYS   RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,PLC_NT
       ,CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
/CONDITION LOB ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "") OR TYP_CT != "A"
/OUTFILE ${SORT_O}
/INCLUDE LOB
exit
EOF
SORT

NSTEP=${NJOB}_220B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_220_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat"
GZIPM

NSTEP=${NJOB}_250
#------------------------------------------------------------------------------
LIBEL="CSF AGREGATES 1051 RETROCESSION Add cols data to GT format ACMTRS/LOB/CUR + CONVERSION "
PRG=ESTC1051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${BALSHTYEA_NF}
PRS_CF 750
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_15_${IB}_SORT_IRDPERICASE_O.dat # Perimetre Accept ou retro selon valeur ACCRET
#export ${PRG}_I2=${DFILT}/${NJOB}_240_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_220_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTESTCUMUL1_ACCRET.dat # Sortie Accept ou retro selon valeur ACCRET
EXECPRG

NSTEP=${NJOB}_250B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_250_${IB}_ESTC1051_GTESTCUMUL1_ACCRET.dat"
GZIPM

# --------------------------------------------
# [010] Begin
# Allocate Retro Funds withheld by acceptation
# --------------------------------------------

#[010] [012] [014]
NSTEP=${NJOB}_255
# FWH Retro : Allocation key : Get and summarize proportionnal retrocession
# i.e. : 
#  Proportionnal retro is Retrocession with acceptation : TYP_CT = 'R' (retro) and CTR_NF != '' (there is an accept contract)
#  For P&C : LOB != 30 or 31
#  Don't get Funds withheld : they are amounts that will be allocated
#
# Sum amounts by retro / ctr to have the allocation key. Don't use PLC
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : Allocation key : Get and summarize proportionnal retrocession"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_ESTC1051_GTESTCUMUL1_ACCRET.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        TRNCOD3_CF        6:3 -  6:6,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        CTR2_NF           8:1 -  8:1,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:
/KEYS   RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT       
       ,ACMCUR_CF       
       ,CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT       
/CONDITION  COND_DEPOT (ACMTRS_NT='902' AND TRNCOD34_CF='84') OR ACMTRS_NT='702'
/DERIVEDFIELD DEPOT IF COND_DEPOT THEN 'YES' ELSE 'NON' CHAR 3
/CONDITION  RETACC ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "") AND (TYP_CT = "R" AND CTR_NF != '' AND CTR2_NF != ' ') AND DEPOT='NON'
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RETACC
exit
EOF
SORT

NSTEP=${NJOB}_255B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_255_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat"
GZIPM

#[010]
NSTEP=${NJOB}_256
LIBEL="FWH Retro : Allocation key : Compute acceptation ratio per retro contract"
#------------------------------------------------------------------------------
LIBEL="FWH Retro : Allocation key : Compute acceptation ratio per retro contract"
PRG=ESTC1055
FPRM=`CFTMP`
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_255_${IB}_SORT_GTESTCUMUL1_ACCRET_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_ALLOC_KEY_O.dat
EXECPRG

NSTEP=${NJOB}_256B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_256_${IB}_ESTC1055_GTAR_ALLOC_KEY_O.dat"
GZIPM

#[010]
NSTEP=${NJOB}_260
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWHGTR : Filter funds for EBS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FWHGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FWHGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
        TRNCOD34_CF       6:3 -  6:4,        
        TRNCOD4_CF        6:3 -  6:7,
        TRNCOD8_CF        6:8 -  6:8,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 40:
/KEYS   RETCTR_NF,
        RETEND_NT,
        RTY_NF,
        RETUW_NT,
        RETSEC_NF,
        TRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CUR_CF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RETCUR_CF,
        PLC_NT,
        RTO_NF
/CONDITION COND_TRNCOD TRNCOD1_CF = "2"
                   AND ((SSD_CF=7 AND ESB_CF!=2) OR (SSD_CF=20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
                   AND TRNCOD34_CF = '81' OR TRNCOD34_CF = '84'                                           
/DERIVEDFIELD PLUS_16_CHAMPS "~P~~~~~~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
/REFORMAT FILLER1,PLUS_16_CHAMPS,ORICOD_LS
exit
EOF
SORT

NSTEP=${NJOB}_260B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_260_${IB}_SORT_FWHGTR_O.dat"
GZIPM

#[010] [013] [014] [015]
NSTEP=${NJOB}_261
# FWH Retro : FWHGTR : Summarize EBS funds CSU / RCSU / PLC / TRNCOD
# AMT is set to RETAMT to be re-allocated by "accept / RSCU" allocation key
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWHGTR : Summarize EBS funds CSU / RCSU / PLC / TRNCOD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_260_${IB}_SORT_FWHGTR_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SUM_FWHGTR_O.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_SUM_FWHGTR_O2.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD34_CF 6:3 -  6:4,
        DBLTRNCOD_CF 7:1 - 7:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        FILLER1   1:1 - 17:,
        FILLER2  20:1 - 55:
/KEYS RETCTR_NF,
      RETEND_NT,
      RTY_NF,
      RETUW_NT,
      RETSEC_NF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      RETCUR_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      TRNCOD34_CF
/CONDITION RETAMT RETAMT_M != 0
/CONDITION RETAMT0 RETAMT_M = 0
/SUMMARIZE  TOTAL RETAMT_M
/DERIVEDFIELD PLUS_10_CHAMPS "~~~~~~~~~~"
/DERIVEDFIELD zero1 "01~"
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/OUTFILE ${SORT_O}
/INCLUDE RETAMT
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, zero1, TRNCOD_CF, DBLTRNCOD_CF, PLUS_10_CHAMPS, RETCUR_CF, RETAMT_M, FILLER2
/OUTFILE ${SORT_O2}
/INCLUDE RETAMT0
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, zero1, TRNCOD_CF, DBLTRNCOD_CF, PLUS_10_CHAMPS, RETCUR_CF, RETAMT_M, FILLER2
exit
EOF
SORT

#[014]
NSTEP=${NJOB}_261B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_261_${IB}_SORT_SUM_FWHGTR_O.dat ${DFILT}/${NJOB}_261_${IB}_SORT_SUM_FWHGTR_O2.dat"
GZIPM

#[010]
NSTEP=${NJOB}_262
# FWH Retro : FWHGTR : Sort EBS funds by RCSU
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWHGTR : Sort EBS funds by RCSU"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_261_${IB}_SORT_SUM_FWHGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SUM_FWHGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RTY_NF 27:1 - 27:EN,
        RETSEC_NF 26:1 - 26:EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_CF_SUFIX 6:7 - 6:8,
        TRNCOD_CF_PREFIX 6:1 - 6:2
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      TRNCOD_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[010] Liste des codes depot dans le fichier FWHGTR
NSTEP=${NJOB}_265
# FWH Retro : FWH GTR->GTAR : Get TRSLNK for EBS funds
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTR->GTAR : Get TRSLNK for EBS funds"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_262_${IB}_SORT_SUM_FWHGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TRSLNK_FWHGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:
/KEYS   TRNCOD_CF
/SUM
/STABLE
/DERIVEDFIELD PRS_CF "750~"
/DERIVEDFIELD ACMTRS_NT "31~"
/OUTFILE ${SORT_O}
/REFORMAT PRS_CF, ACMTRS_NT, TRNCOD_CF
exit
EOF
SORT

NSTEP=${NJOB}_265B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_265_${IB}_TRSLNK_FWHGTR_O.dat"
GZIPM

#[010]
NSTEP=${NJOB}_266
# FWH Retro : FWH GTR->GTAR : Sort pericase
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTR->GTAR : Sort pericase"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDVPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
            RTY_NF 6:1 - 6:EN,
            RETSEC_NF 5:1 - 5:EN,
            RETCTRCAT_CF 107:1 - 107:
/KEYS RETCTR_NF, RTY_NF, RETSEC_NF
exit
EOF
SORT

NSTEP=${NJOB}_266B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_266_${IB}_SORT_IRDVPERICASE_O.dat"
GZIPM

#[015]
NSTEP=${NJOB}_269
#-----------------------------------------------------------------------------
LIBEL="Sort of ESTC1055_GTAR_ALLOC_KEY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_256_${IB}_ESTC1055_GTAR_ALLOC_KEY_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTVENTNP_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RTY_NF    2:1 - 2:EN,
        RETSEC_NF 3:1 - 3:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[021]
NSTEP=${NJOB}_270
# FWH Retro : FWH GTR->GTAR : Allocate acceptation per retro contract
#-----------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTR->GTAR : Allocate acceptation per retro contract"
PRG=ESTC8805
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
BALSHTMTH_NF ${BALSHTMTH_NF}
TYPE_EDITION 1
CRE_D ${ICLODAT_D}
ICLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_262_${IB}_SORT_SUM_FWHGTR_O.dat 
export ${PRG}_I2=${DFILT}/${NJOB}_269_${IB}_SORT_FTVENTNP_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_265_${IB}_TRSLNK_FWHGTR_O.dat
export ${PRG}_I4=${DFILT}/${NJOB}_266_${IB}_SORT_IRDVPERICASE_O.dat
export ${PRG}_I5=${EST_FLIBEL2}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FWHGTARR.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FWHGTARR.ano
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_VENTNPGTAR_vide.dat   #[19]
EXECPRG

NSTEP=${NJOB}_270B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_270_${IB}_ESTC8805_FWHGTARR.dat"
GZIPM

#[010] [013] [015]
NSTEP=${NJOB}_271
#------------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTARR : Sort by CSU / RCSU"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_270_${IB}_ESTC8805_FWHGTARR.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FWHGTARR.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        AMT_M            19:1 - 19:EN 15/3,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:
/KEYS   CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
       ,RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,RETCUR_CF
       ,TRNCOD34_CF
       ,PLC_NT
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M
/CONDITION NONNULL (AMT_M != 0 OR RETAMT_M != 0)
/OUTFILE ${SORT_O}
/INCLUDE NONNULL
exit
EOF
SORT

#[010]
NSTEP=${NJOB}_272
#------------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTARR : Fill ACMTRS, currencies, segmentaion for Retro"
PRG=ESTC1051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT A
BALSHTYEA_NF ${BALSHTYEA_NF}
PRS_CF 750
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_IADPERICASE_O.dat       
export ${PRG}_I2=${DFILT}/${NJOB}_271_${IB}_SORT_FWHGTARR.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FWHGTARR.dat
EXECPRG

NSTEP=${NJOB}_272B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_272_${IB}_ESTC1051_FWHGTARR.dat"
GZIPM


#[010]
NSTEP=${NJOB}_273
#------------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTARR : Sort by RCSU / CSU"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_272_${IB}_ESTC1051_FWHGTARR.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FWHGTARR.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        PLC_NT           36:1 - 36:        
/KEYS   RETCTR_NF
       ,RETEND_NT
       ,RETSEC_NF
       ,RTY_NF
       ,RETUW_NT
       ,PLC_NT
       ,CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


#[010]
NSTEP=${NJOB}_274
#------------------------------------------------------------------------------
LIBEL="FWH Retro : FWH GTARR : Fill ACMTRS, currencies, segmentation for Retro"
PRG=ESTC1051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${BALSHTYEA_NF}
PRS_CF 750
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_15_${IB}_SORT_IRDPERICASE_O.dat # Perimetre Accept ou retro selon valeur ACCRET
export ${PRG}_I2=${DFILT}/${NJOB}_273_${IB}_SORT_FWHGTARR.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FWHGTARR.dat # Sortie Accept ou retro selon valeur ACCRET
EXECPRG

NSTEP=${NJOB}_274B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_274_${IB}_ESTC1051_FWHGTARR.dat "
GZIPM

# --------------------------------------------
# [010] End
# Allocate Retro Funds withheld by acceptation
# --------------------------------------------

#[015]
NSTEP=${NJOB}_400
#[009] Ajout du ACMTRS 702 = Funds No life a prendre en compte
#[22] Changement du ACMTRS 312 par 307
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES Accumulation of acceptation and retrocession amount by ACMTRS_NT, TYP ==> file agregate"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_ESTC1051_GTESTCUMUL1_ACCRET.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_274_${IB}_ESTC1051_FWHGTARR.dat 500 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_GTESTCUMUL1_ACCRET.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT
/CONDITION COND_TRNCOD ( ACMTRS_NT = "101" OR ACMTRS_NT = "105" OR ACMTRS_NT = "201" OR ACMTRS_NT = "205" OR 
                         ACMTRS_NT = "301" OR ACMTRS_NT = "303" OR ACMTRS_NT = "309" OR ACMTRS_NT = "311" OR ACMTRS_NT = "307" OR ACMTRS_NT = "316" OR ACMTRS_NT = "320" OR 
                         ACMTRS_NT = "702" OR (ACMTRS_NT = "902" AND TRNCOD34_CF = "84") ) AND
                         ( LOB_CF != "30" AND LOB_CF != "31" ) AND ACMAMT_M != 0
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD ACMAMT_MC ACMAMT_M COMPRESS
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
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
          ACMTRS_NT,
          ACMAMT_MC,
          ACMCUR_CF,
          PRS_CF,
          SEG_NF,
          LOB_CF,
          NAT_CF,
          TYP_CT,
          PATTYP_CF,
          SEGLOB_CF
exit
EOF
SORT

NSTEP=${NJOB}_400B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_400_${IB}_GTESTCUMUL1_ACCRET.dat"
GZIPM

#[015]
#[22] Changement du ACMTRS 312 par 307
NSTEP=${NJOB}_500
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES ULAE extraction"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_400_${IB}_GTESTCUMUL1_ACCRET.dat 500 1"
SORT_O="${EST_DLCUMGTAAR_IBNR_FUTCLAIMS} 500 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_GTESTCUMUL1_ACCRET_ULAE.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT
/CONDITION COND_IBNR_FUTURECLAIMS ( ACMTRS_NT = "309" OR  ACMTRS_NT = "320" )  
/CONDITION COND_ULAE_FUTURECLAIMS TYP_CT= "A" AND 
                                 (ACMTRS_NT = "301" OR ACMTRS_NT = "303" OR ACMTRS_NT = "309" OR ACMTRS_NT = "307" OR ACMTRS_NT = "316" OR ACMTRS_NT = "320" ) 
/OUTFILE ${SORT_O}
/INCLUDE COND_IBNR_FUTURECLAIMS
/OUTFILE ${SORT_O2}
/INCLUDE COND_ULAE_FUTURECLAIMS
exit
EOF
SORT

NSTEP=${NJOB}_500B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_500_${IB}_GTESTCUMUL1_ACCRET_ULAE.dat"
GZIPM

NSTEP=${NJOB}_520
#-----------------------------------------------------------------------------
LIBEL="SORT FULAERAT by ledger"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FULAERAT}"
SORT_O="${DFILT}/${NSTEP}_${IB}_FULAERAT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:
/KEYS SSD_CF,
      ESB_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_530
#-----------------------------------------------------------------------------
LIBEL="SORT GTESTCUMUL1_ACCRET_ULAE by ledger"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_500_${IB}_GTESTCUMUL1_ACCRET_ULAE.dat 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_GTESTCUMUL1_ACCRET_ULAE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:
/KEYS SSD_CF,
      ESB_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_530B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_530_${IB}_GTESTCUMUL1_ACCRET_ULAE.dat"
GZIPM

NSTEP=${NJOB}_550
#------------------------------------------------------------------------------
LIBEL="ULAE AGREGATES CALCULATION "
PRG=ESTC1070
export ${PRG}_I1=${DFILT}/${NJOB}_530_${IB}_GTESTCUMUL1_ACCRET_ULAE.dat # Perimetre Accept ou retro selon valeur ACCRET
export ${PRG}_I2=${DFILT}/${NJOB}_520_${IB}_FULAERAT.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_GTESTCUMUL1_ACCRET_ULAE.dat # ULAE aggregates (aggregates x ratio)
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_LEDGER_wo_ULAE.dat # log missing ledger rates
EXECPRG

NSTEP=${NJOB}_550B
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde de fichiers"
GZIPM_I="${DFILT}/${NJOB}_550_${IB}_ESTC1070_GTESTCUMUL1_ACCRET_ULAE.dat ${DFILT}/${NJOB}_550_${IB}_ESTC1070_LEDGER_wo_ULAE.dat"
GZIPM

NSTEP=${NJOB}_800
#-----------------------------------------------------------------------------
LIBEL="CSF AGREGATES TOTAL GENERAL+ULAE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_400_${IB}_GTESTCUMUL1_ACCRET.dat 500 1"
SORT_I2="${DFILT}/${NJOB}_550_${IB}_ESTC1070_GTESTCUMUL1_ACCRET_ULAE.dat 500 1"
SORT_O="${EST_DLCUMGTAAR} 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD34_CF       6:3 -  6:4,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        CED_NF           20:1 - 20:,
        BRK_NF           21:1 - 21:,
        PAY_NF           22:1 - 22:,
        KEY_NF           23:1 - 23:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        RETOCCYEA_NF     29:1 - 29:,
        RETACY_NF        30:1 - 30:,
        RETSCOSTRMTH_NF  31:1 - 31:EN,
        RETSCOENDMTH_NF  32:1 - 32:EN,
        RCL_NF           33:1 - 33:,
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        PLC_NT           36:1 - 36:,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        ACMTRS_NT        42:1 - 42:,
        ACMAMT_M         43:1 - 43:EN 15/3,
        ACMCUR_CF        44:1 - 44:,
        PRS_CF           45:1 - 45:,
        SEG_NF           46:1 - 46:,
        LOB_CF           47:1 - 47:,
        NAT_CF           48:1 - 48:,
        TYP_CT           49:1 - 49:,
        PATTYP_CF        50:1 - 50:,
        SEGLOB_CF        51:1 - 51:
/KEYS SSD_CF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      ACMCUR_CF,
      ACMTRS_NT,
      TYP_CT
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M, TOTAL ACMAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_920
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
