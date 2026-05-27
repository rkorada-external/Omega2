#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - ANNULATION DES PNAS
# nom du script SHELL           : ESID3601A.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/11/2012
# auteur                        : PHILIPPE PEZOUT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  :spot:24041 ANNULATION DES PNAS
#-----------------------------------------------------------------------------
#historique des modifications :
#[02] 20/01/2013 :spot:24698 - -=PhP=-  corrections pour la conso
#[03] 20/01/2013 :spot:24836 - -=PhP=-  corrections pour la conso
#[04] 20/02/2013 :spot:24875 - -=PhP=-  corrections pour la conso
#[04] 27/02/2013 :spot:24905 - -=PhP=-  corrections pour la conso
#[05] 10/04/2013 :spot:25096 - -=PhP=-  corrections pour la conso 
#[06] 10/06/2013 :spot:25282 - -=PhP=-  corrections pour la conso 
#[07] 23/05/2014 :spot:26838 - A. Ben Jeddou - Corrections sur le batch solvency P&C : reprise de code suite au passage  de 2A à la 1B
#[08] 27/06/2014 :spot:26956 - C.DESPRET     - Corrections sur le batch solvency P&C : reprise de code suite au passage  de 2A à la 1B
#[09] 30/06/2014 :spot:26956 - P.PEZOUT      - Corrections sur le batch solvency P&C : reprise de code suite au passage  de 2A à la 1B
#[10] 07/07/2014 :spot:27103 - C.DESPRET     - pb format du fichier DLASIIGTR formaté par le ESID3601 STEP 325
#[11] 10/07/2014 :spot:xxxxx - C.DESPRET     - Remove Life subsidiaries
#[12] 22/09/2014 :spot:27486 - R. Cassis share sort step 200 to 2 steps to avoid syncsort memory abend.
#[12] 06/10/2014 :spot:27903 - C.DESPRET     - Annulation des ES post Omega IFRS Sociales : ne pas prendre en compte les ecritures services EBS
#[13] 28/04/2015 :spot:27903 - Florent       - ajout des PNA FAC RPCC là où on annule les PNAs
#[14] 02/11/2015 :spot:29615 - P.PEZOUT EST45 gzip et maj step 100
#[15] 26/05/2016 :spot 30583 - S.Behague     - Spira 41148
#[16] 28/06/2016 :spot:31251 - Florent       - spira 48151- EBS - UPR cancel - correction pour le mix of internal and external retrocessionaire: modif step 150 et 250 pour GTAA et GTAR
#[17] 18/11/2016 :spira:57799  Florent  Mise au format à 71 colonnes pour le fichier EST_DLASIIGT*
#[18] 15/11/2017 :spira:63149  Roger    Ajout postes dans filtre du tri : 4601 et 4611 pour (POC-POS) postes ULAE
#[19] 13/12/2017 :spira:63929  MZA      Ajout des postes comptables du tri : "41601" et "42601" pour POC-POS
#[20] 29/12/2018 :spira:69426  JYP      nouvelle version copie de ESID3601.cmd et mise a niveau architecture IFRS17 
#[21] 12/06/2019 :spira:73977  Roger    Ajout filtre sur poste 43020 DAC qui n'est pas pris en compte dans les tris et ne génère pas de cloture EBS.
#[22] 17/09/2019 :spira:79427  Roger    Ajout tri pour reformatage du fichier FTECLEDASIISO en format GT pour le POCE et maj postes DSC 4160 4260 dans tris
#[23] 10/11/2020 :M.NAJI   :spira: 91420 Optimisatin , split en 4 jobs et // 3 jobs
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
CRE_D=$1
ICLODAT_D=$2
TYPEINV=$3

# Job Initialisation
JOBINIT

TRIM_NF=`echo ${ICLODAT_D} | cut -c5-6 | awk '{ if ($0==3) print "1"; if ($0==6) print "2"; if ($0==9) print "3"; if ($0==12) print "4" }'`
ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`

ICLODAT_J="03"


TYPEPO=""
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV ...................: ${TYPEINV}"
ECHO_LOG "#===> NORME .....................: ${NORME}"
ECHO_LOG "#===> param_Request_id ..........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id ..........: ${param_Context_id}  "
ECHO_LOG "#===> TRIM_NF ..............: ${TRIM_NF}"
ECHO_LOG "#===> ICLODAT_D ............: ${ICLODAT_D}"
ECHO_LOG "#===> ICLODAT_J ............: ${ICLODAT_J}"

ECHO_LOG "# ...................INPUT.................."
ECHO_LOG "#===> EST_IADPERICASE ......: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_IRDPERICASE0 .....: ${EST_IRDPERICASE0}"
ECHO_LOG "#===> EST_FTRSLNK ..........: ${EST_FTRSLNK}"
ECHO_LOG "#===> EST_FBOPRSLNK ........: ${EST_FBOPRSLNK}"
ECHO_LOG "#===> EST_DLAGTR ...........: ${EST_DLAGTR}"
ECHO_LOG "#===> EST_IGTAAF ...........: ${EST_IGTAAF}"
ECHO_LOG "#===> EST_DLDGTAA ..........: ${EST_DLDGTAA}"
ECHO_LOG "#===> EST_DLRGTAA ..........: ${EST_DLRGTAA}"
ECHO_LOG "#===> EST_DLSGTAA ..........: ${EST_DLSGTAA}"
ECHO_LOG "#===> EST_DLSGTAR ..........: ${EST_DLSGTAR}"
ECHO_LOG "#===> EST_DLREGTAR .........: ${EST_DLREGTAR}"
ECHO_LOG "#===> EST_DLREMAJGTAR ......: ${EST_DLREMAJGTAR}"
ECHO_LOG "#===> EST_DLSGTR ...........: ${EST_DLSGTR}"
ECHO_LOG "#===> EST_DLREGTR ..........: ${EST_DLREGTR}"
ECHO_LOG "#===> EST_DLREMAJGTR .......: ${EST_DLREMAJGTR}"
ECHO_LOG "#===> EST_FTRSLNK ..........: ${EST_FTRSLNK}"
ECHO_LOG "#===> EST_FDETTRS ..........: ${EST_FDETTRS}"
ECHO_LOG "#===> EST_FCURQUOT .........: ${EST_FCURQUOT}"
ECHO_LOG "#===> EST_DLRTCGTR .........: ${EST_DLRTCGTR}"
ECHO_LOG "#===> EST_FPLATXCUM ........: ${EST_FPLATXCUM}"
ECHO_LOG "#===> EST_FTECLEDASII ......: ${EST_FTECLEDASII}"
ECHO_LOG "#===> EST_FTECLEDASO .......: ${EST_FTECLEDASO} "
ECHO_LOG "#===> EST_FTECLEDASIISO  ...: ${EST_FTECLEDASIISO} "
ECHO_LOG "#===> EPO_FTECLEDRSO .......: ${EPO_FTECLEDRSO} "

ECHO_LOG "# ...................OUTPUT .................."
ECHO_LOG "#===> EST_DLASIIGTAA .......: ${EST_DLASIIGTAA}"
ECHO_LOG "#===> EST_DLASIIGTAR .......: ${EST_DLASIIGTAR}"
ECHO_LOG "#===> EST_DLASIIGTR ........: ${EST_DLASIIGTR}"
ECHO_LOG "#========================================================================="


# creation des fichiers vide
touch ${EST_DLASIIGTAA}
touch ${EST_DLASIIGTAR}
touch ${EST_DLASIIGTR}

datej=`date '+%Y%m%d%H%M%S'`
datedel=`echo  "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-1; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel1=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-2; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel2=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-3; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`


NSTEP=${NJOB}_05
# MOD003 -  Sort of IADPERICASE
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE} 1000 1"
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

#NSTEP=${NJOB}_10
## MOD003 -  Sort of IRDPERICASE
##-----------------------------------------------------------------------------
#LIBEL="Sort of IRDPERICASE"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_IRDPERICASE0} 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDPERICASE_O.dat 1000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS CTR_NF    3:1 -  3:,
#        END_NT    4:1 -  4:,
#        SEC_NF    5:1 -  5:EN,
#        UWY_NF    6:1 -  6:,
#        UW_NT     7:1 -  7:
#/KEYS   CTR_NF,
#        END_NT,
#        SEC_NF,
#        UWY_NF,
#        UW_NT
#exit
#EOF
#SORT

#[22]
if [ -s ${EST_FTECLEDASII} ]
then

  NSTEP=${NJOB}_15
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Formatage du ${EST_FTECLEDASII} en format type GTA (cas du POCE)"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_FTECLEDASII} 2000  1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDASIISOFormatGTA_O1.dat
  INPUT_TEXT $SORT_CMD << EOF
/FIELDS FORMAT_STANDARD     1:1 -  40:,
        RETINTAMT_M        88:1 -  88:,
        PLUS_13_CHAMPS     89:1 - 101:,
        KeyReconciliation 102:1 - 102:,
        TRN_NT            103:1 - 103:,
        ORICOD_LS         104:1 - 104:,
        FILLER_14_COLS    105:1 - 118:
/DERIVEDFIELD  PLUS_14_CHAMPS 14"~"
/OUTFILE ${SORT_O}
/REFORMAT FORMAT_STANDARD,RETINTAMT_M,PLUS_14_CHAMPS,TRN_NT,ORICOD_LS,FILLER_14_COLS
exit
EOF
SORT

else

  NSTEP=${NJOB}_16
  # Create an empty file for later use
  #------------------------------------------------------------------------------
  LIBEL="touch ${DFILT}/${NJOB}_15_${IB}_SORT_FTECLEDASIISOFormatGTA_O1.dat"
  EXECKSH_MODE=P
  EXECKSH "touch ${DFILT}/${NJOB}_15_${IB}_SORT_FTECLEDASIISOFormatGTA_O1.dat"

fi

#[18]
NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
# cancelation of previous EBS lines
#-----------------------------------------------------------------------------
LIBEL="selection of previous EBS lines ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IGTAAF} 1000 1"
SORT_I2="${EST_FTECLEDASII} 1000 1"
#SORT_I2="${DFILT}/${NJOB}_15_${IB}_SORT_FTECLEDASIISOFormatGTA_O1.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_O.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAR_O.dat
SORT_O3=${DFILT}/${NSTEP}_${IB}_SORT_DLAGTR_O.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:,
        ESB_CF            2:1 -  2:,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:7,
        TRNCOD4_CF        6:3 -  6:6,
        TRNCOD8_CF        6:8 -  6:8,
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
        RETCUR_CF        34:1 - 34:,
        RETAMT_M         35:1 - 35:EN 15/3,
        RETINTAMT_M      88:1 - 88:EN 15/3,
        FILLER1           6:1 - 14:,
        FILLER2          20:1 - 34:,
        FILLER3          36:1 - 40:,
        ZONE_ACCEPT       8:1 - 23:,
        ZONE_RETRO       24:1 - 34:
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
      ,TRNCOD_CF
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD SCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD PLUS_01_CHAMPS "100~"
/DERIVEDFIELD PLUS_02_CHAMPS "~100~"
/DERIVEDFIELD PLUS_16_CHAMPS "750~~01~~~~~~~~~~"
/DERIVEDFIELD PLUS_15_CHAMPS "750~~01~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/CONDITION ACCEPT  TRNCOD1_CF = "1" AND ( AMT_M !=0 OR RETAMT_M !=0 ) AND "AE" CT TRNCOD2_CF AND "1357" NC TRNCOD8_CF 
                   AND (TRNCOD4_CF = "1007" OR TRNCOD4_CF = "1008" OR TRNCOD4_CF = "4601" OR TRNCOD4_CF = "4611" OR
                   TRNCOD4_CF = "4260" OR TRNCOD4_CF = "4261" OR TRNCOD4_CF = "4160" OR TRNCOD4_CF = "4161" ) 
/CONDITION RETRO   TRNCOD1_CF = "2" AND ( AMT_M !=0 OR RETAMT_M !=0 ) AND "AE" CT TRNCOD2_CF AND "1357" NC TRNCOD8_CF 
                   AND (TRNCOD4_CF = "1007" OR TRNCOD4_CF = "1008" OR TRNCOD4_CF = "4601" OR TRNCOD4_CF = "4611" OR 
                   TRNCOD4_CF = "4260" OR TRNCOD4_CF = "4261" OR TRNCOD4_CF = "4160" OR TRNCOD4_CF = "4161" ) 
/OUTFILE ${SORT_O}
/INCLUDE ACCEPT
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW,FILLER1,SCOSTRMTH_NF_NEW,SCOSTRMTH_NF_NEW, 
          CLM_NF, CUR_CF, AMT_M,FILLER2,RETAMT_M,FILLER3,PLUS_02_CHAMPS,AMT_M,CUR_CF,PLUS_16_CHAMPS,ORICOD_LS
/OUTFILE ${SORT_O2}
/INCLUDE RETRO
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW,FILLER1,SCOSTRMTH_NF_NEW,SCOSTRMTH_NF_NEW, 
          CLM_NF, CUR_CF, AMT_M,FILLER2,RETAMT_M,FILLER3,RETINTAMT_M,PLUS_01_CHAMPS,AMT_M,RETCUR_CF,PLUS_16_CHAMPS,ORICOD_LS
/OUTFILE ${SORT_O3}
/INCLUDE RETRO
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW,TRNCOD_CF,DBLTRNCOD_CF,ZONE_ACCEPT, 
          ZONE_RETRO,RETAMT_M,FILLER3,PLUS_02_CHAMPS,RETAMT_M,RETCUR_CF,PLUS_16_CHAMPS,ORICOD_LS
exit
EOF
SORT


NSTEP=${NJOB}_30
#------------------------------------------------------------------------------
LIBEL="Extract CUR of  BALSHTYEA=${ICLODAT_A}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCURQUOT_TXT}  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCURQUOT_${ICLODAT_A}.dat  1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CURQUOT_UWY_NF   3:1 -  3:
/CONDITION IS_BALSHTYEA ( CURQUOT_UWY_NF = "${ICLODAT_A}" )
/INCLUDE IS_BALSHTYEA
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTRSLNK_TXT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_EBS.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS PRS_CF       1:1 -  1:
                ,all_cols       1:1  - 3:
/CONDITION IS_EBS ( PRS_CF = "713" )
/INCLUDE IS_EBS
/COPY
exit
EOF
SORT



NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Extend IADPERICASE with CURQUOT_RATE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_IADPERICASE_O.dat  1000 1"

SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols                 1:1  - 205:
/joinkeys
       SSD_CF
      ,PCPCUR_CF
/INFILE ${DFILT}/${NJOB}_30_${IB}_FCURQUOT_${ICLODAT_A}.dat 1000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols
       ,rightside:CURQUOT_RATE

exit
EOF
SORT



NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="Extend IADPERICASE with EGPCUR_RATE, PCPCUR and EGPCUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_IADPERICASE_PCP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP_EGP_O.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        EGPCUR_CF        23:1 - 23:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
                all_cols                 1:1  - 206:
/joinkeys
       SSD_CF
      ,EGPCUR_CF
/INFILE ${DFILT}/${NJOB}_30_${IB}_FCURQUOT_${ICLODAT_A}.dat 1000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:all_cols
        ,rightside:CURQUOT_RATE
        ,leftside:PCPCUR_CF
        ,leftside:EGPCUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_IADPERICASE_PCP_EGP_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_PCP_EGP.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

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


NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
LIBEL="Extend IRDPERICASE with CURQUOT_RATE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0}  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_PCP.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
                all_cols                 1:1  - 205:
/joinkeys
       SSD_CF
      ,PCPCUR_CF
/INFILE ${DFILT}/${NJOB}_30_${IB}_FCURQUOT_${ICLODAT_A}.dat 1000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE   ${SORT_O}
/REFORMAT
        leftside:all_cols
       ,rightside:CURQUOT_RATE

exit
EOF
SORT



NSTEP=${NJOB}_90
#------------------------------------------------------------------------------
LIBEL="Extend IADPERICASE with EGPCUR_RATE, PCPCUR and EGPCUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_IRDPERICASE_PCP.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_PCP_EGP_O.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF           6:1 - 6:,
        EGPCUR_CF        23:1 - 23:,
        PCPCUR_CF        51:1 - 51:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
                all_cols                 1:1  - 206:
/joinkeys
       SSD_CF
      ,EGPCUR_CF
/INFILE ${DFILT}/${NJOB}_30_${IB}_FCURQUOT_${ICLODAT_A}.dat 1000 1 "~"
/joinkeys
        CURQUOT_SSD_CF
       ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:all_cols
        ,rightside:CURQUOT_RATE
        ,leftside:PCPCUR_CF
        ,leftside:EGPCUR_CF
exit
EOF
SORT

NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_IRDPERICASE_PCP_EGP_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IRDPERICASE_PCP_EGP.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

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



JOBEND
