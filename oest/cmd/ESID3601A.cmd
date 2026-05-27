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
#[23] 03/12/2020 :spira:92015  Roger    Les postes 4160, 4260 DSC et 4601, 4611 ULAE ne doivent pas etre annulés ici car maintenant c'est fait dans le programme de delta ESTC1054
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

NSTEP=${NJOB}_10
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

#[021] [23]
NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
# GTAa files merge
#${EPO_FTECLEDA}
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA} 1000 1"
SORT_I2="${EST_DLSGTAA} 1000 1"
SORT_I3="${EST_DLRGTAA} 1000 1"
SORT_I4="${EST_IGTAAF} 1000 1"
#SORT_I5="${EST_DLAGTAA} 1000 1"
#SORT_I5="${EST_FTECLEDASII} 1000 1" [22]
SORT_I5="${DFILT}/${NJOB}_15_${IB}_SORT_FTECLEDASIISOFormatGTA_O1.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_O.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_O2.dat		# fichier plus utilisé  ???? pour controle  ????
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
        RETAMT_M         35:1 - 35:EN 15/3,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           6:1 - 14:,
        FILLER2          20:1 - 34:,
        FILLER3          36:1 - 40:
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
/DERIVEDFIELD PLUS_16_CHAMPS "~0~~~~~~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/CONDITION POSTES  TRNCOD1_CF = "1" AND "1357" NC TRNCOD8_CF 
                   AND ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) AND ( AMT_M !=0 OR RETAMT_M !=0 )
                   AND (
                        ((TRNCOD3_CF = "41000" OR TRNCOD3_CF = "41100" OR TRNCOD3_CF = "41700" OR TRNCOD3_CF = "41800" OR TRNCOD3_CF = "41900" OR 
                          TRNCOD3_CF = "43000" OR TRNCOD3_CF = "43100" OR TRNCOD3_CF = "43600" OR TRNCOD3_CF = "43700" OR TRNCOD3_CF = "43800" OR 
                          TRNCOD3_CF = "43900" OR TRNCOD3_CF = "43020" OR TRNCOD3_CF = "43010") AND "14A" CT TRNCOD2_CF) 
                        OR 
                        ((TRNCOD3_CF = "41101" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43701" ) AND "14A" CT TRNCOD2_CF AND "246" CT TRNCOD8_CF) 
                       )
/OUTFILE ${SORT_O}
/INCLUDE POSTES
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW,FILLER1,SCOSTRMTH_NF_NEW,SCOSTRMTH_NF_NEW, 
          CLM_NF, CUR_CF, AMT_M,FILLER2,RETAMT_M,FILLER3,PLUS_16_CHAMPS,ORICOD_LS
/OUTFILE ${SORT_O2}
/OMIT POSTES
exit
EOF
SORT


NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
LIBEL="Add cols data to GT format"
PRG=ESTC1051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT A
BALSHTYEA_NF ${ICLODAT_A}
PRS_CF 750
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_IADPERICASE_O.dat         # PHP mettre ici un fichier dans DFILI
export ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_SORT_DLAGTAA_O.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLADGTAA.dat
EXECPRG

#[011] Remove Life SSD
NSTEP=${NJOB}_125
#-----------------------------------------------------------------------------
LIBEL="ANNULATION PNA : EXCLUSION DES LOB 30 ET 31 et Ajout 16 champs ET SUMMARIZE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_ESTC1051_DLADGTAA.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_20_${IB}_SORT_DLAGTAA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLADGTAA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN
       ,ESB_CF            2:1 -  2:EN
       ,TRNCOD_CF         6:1 -  6:
       ,DBLTRNCOD_CF      7:1 -  7:
       ,CTR_NF            8:1 -  8:
       ,END_NT            9:1 -  9:EN
       ,SEC_NF           10:1 - 10:EN
       ,UWY_NF           11:1 - 11:
       ,UW_NT            12:1 - 12:EN
       ,FILLER1           1:1 - 17:
       ,CUR_CF           18:1 - 18:
       ,AMT_M            19:1 - 19:EN 15/3
       ,FILLER2          20:1 - 40:
       ,ACMTRS_NT        42:1 - 42:
       ,ACMAMT_M         43:1 - 43:EN 15/3
       ,ACMCUR_CF        44:1 - 44:
       ,PRS_CF           45:1 - 45:
       ,SEG_NF           46:1 - 46:
       ,LOB_CF           47:1 - 47:
       ,NAT_CF           48:1 - 48:
       ,TYP_CT           49:1 - 49:
       ,PATTYP_CF        50:1 - 50:
       ,SEGLOB_CF        51:1 - 51:
/DERIVEDFIELD AJOUT30COLS 29"~"
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,TRNCOD_CF
      ,CUR_CF
/CONDITION LOB ( LOB_CF != "30" AND LOB_CF != "31") AND 
               ((SSD_CF =7 AND ESB_CF!=2) OR 
                (SSD_CF =20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR 
                (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND 
                 SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
/SUMMARIZE TOTAL ACMAMT_M, TOTAL AMT_M
/OUTFILE ${SORT_O}
/INCLUDE LOB
/REFORMAT FILLER1
         ,CUR_CF
         ,AMT_M
         ,FILLER2
         ,ACMAMT_M
         ,AJOUT30COLS
exit
EOF
SORT

NSTEP=${NJOB}_150
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the GTAA..."
AWK_I=${DFILT}/${NJOB}_125_${IB}_SORT_DLADGTAA.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLAGTAA.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { 	if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
					if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
					if ( \$41 != 0 ) \$41 = sprintf("%-.3lf",-\$41);
					if ( substr(\$6,2,1)=="1" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="4" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="7" ) \$6=substr(\$6,1,1) "J" substr(\$6,3,5) "2";
					if ( substr(\$7,2,1)=="2" ) \$7=substr(\$7,1,1) "B" substr(\$7,3,5) "2";
					if ( substr(\$7,2,1)=="5" ) \$7=substr(\$7,1,1) "G" substr(\$7,3,5) "2";
					\$57 = "EBSGTA";
					print \$0;
       }
exit
EOF
AWK

NSTEP=${NJOB}_160
#-----------------------------------------------------------------------------
LIBEL="DLAGTAA file suumarize ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_150_${IB}_AWK_DLAGTAA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
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
        RETAMT_M         35:1 - 35:EN 15/3,
        FILLER1           1:1 - 17:,
        FILLER2          20:1 - 71:
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
      ,TRNCOD_CF
/SUMMARIZE  TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/CONDITION MONTANT ( AMT_MC !=0 )
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
/REFORMAT FILLER1,CUR_CF,AMT_MC,FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_170
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition DLAGTAA in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_160_${IB}_SORT_DLAGTAA_O.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${EST_DLASIIGTAA}
EXECPRG

# ----------------------------------------------------------------------------------------------------------
# ANNULATION GTAR
# ----------------------------------------------------------------------------------------------------------

NSTEP=${NJOB}_180
#-----------------------------------------------------------------------------
LIBEL="Merge EST_DLREGTAR and EST_DLREMAJGTAR files before applying internal retrocession"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLREGTAR} 1000 1"
SORT_I2="${EST_DLREMAJGTAR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTAR.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26:EN,
        RTY_NF    27:1 - 27:,
        PLC_NT    36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_190
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${EST_FPLATXCUM}
export ${PRG}_I2=${DFILT}/${NJOB}_180_${IB}_SORT_DLREGTAR.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREGTAR.dat
EXECPRG

#[012]
#[019] [021] [22] [23]
##-----------------------------------------------------------------------------
NSTEP=${NJOB}_199
#-----------------------------------------------------------------------------
# GTAR files merge
#-----------------------------------------------------------------------------
LIBEL="Merge and sort FTECLED data and convert to GTAR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_DLAGTAR} 1000 1"
#SORT_I1="${EST_DLRTCGTAR} 1000 1"
#SORT_I2="${EST_DLAGTAA} 1000 1"
#SORT_I3="${EST_DLRPGTAR} 1000 1"
#SORT_I4="${EST_DLRNPGTAR} 1000 1"
#SORT_I5="${EST_DLRTFGTAR} 1000 1"
#SORT_I6="${EST_IGTAR} 1000 1"
SORT_I="${EST_FTECLEDASO} 1000 1"
SORT_I2="${EST_FTECLEDASII} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FORMAT_STANDARD    1:1  -  40:,
        SSD_CF             1:1  -  1:EN,
        ESB_CF             2:1  -  2:EN,
        BALSHEY_NF         3:1  -  3:EN,
        BALSHRMTH_NF       4:1  -  4:EN,
        BALSHRDAY_NF       5:1  -  5:EN,
        TRNCOD_CF          6:1  -  6:,
        TRNCOD1_CF         6:1  -  6:1,
        TRNCOD2_CF         6:2  -  6:2,
        TRNCOD3_CF         6:3  -  6:7,
        TRNCOD4_CF         6:3  -  6:6,
        TRNCOD8_CF         6:8  -  6:8,
        DBLTRNCOD_CF       7:1  -  7:,
        CTR_NF             8:1  -  8:,
        END_NT             9:1  -  9:EN,
        SEC_NF            10:1  - 10:EN,
        UWY_NF            11:1  - 11:,
        UW_NT             12:1  - 12:EN,
        OCCYEA_NF         13:1  - 13:,
        ACY_NF            14:1  - 14:,
        SCOSTRMTH_NF      15:1  - 15:EN,
        SCOENDMTH_NF      16:1  - 16:EN,
        CLM_NF            17:1  - 17:,
        CUR_CF            18:1  - 18:,
        AMT_M             19:1  - 19:EN 15/3,
        RETCTR_NF         24:1  - 24:,
        RETEND_NT         25:1  - 25:,
        RETSEC_NF         26:1  - 26:EN,
        RTY_NF            27:1  - 27:,
        RETUW_NT          28:1  - 28:,
        RETOCCYEA_NF      29:1  - 29:,
        RETACY_NF         30:1  - 30:,
        RETSCOSTRMTH_NF   31:1  - 31:EN,
        RETSCOENDMTH_NF   32:1  - 32:EN,
        RCL_NF            33:1  - 33:,
        RETCUR_CF         34:1  - 34:,
        RETAMT_M          35:1  - 35:EN 15/3,
        PLC_NT            36:1  - 36:EN,
        RTO_NF            37:1  - 37:,
        INT_NF            38:1  - 38:,
        RETPAY_NF         39:1  - 39:,
        RETKEY_CF         40:1  - 40:,
        FILLER1            6:1  - 14:,
        FILLER2           20:1  - 30:,
        FILLER2a          33:1  - 34:,
        FILLER3           36:1  - 40:,
        RETINTAMT_M       88:1  - 88:EN 15/3,
        TRN_NT            103:1 - 103:,
        ORICOD_LS         104:1 - 104:,
        FILLER_14_COLS    105:1 - 118:
/KEYS  RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RTY_NF
      ,RETCUR_CF
      ,TRNCOD_CF
      ,PLC_NT
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
/CONDITION POSTES  TRNCOD1_CF = "2" AND "1357" NC TRNCOD8_CF 
                   AND ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) 
                   AND (
                        ((TRNCOD3_CF = "41000" OR TRNCOD3_CF = "41100" OR TRNCOD3_CF = "41700" OR TRNCOD3_CF = "41800" OR TRNCOD3_CF = "41900" OR 
                          TRNCOD3_CF = "43000" OR TRNCOD3_CF = "43100" OR TRNCOD3_CF = "43600" OR TRNCOD3_CF = "43700" OR TRNCOD3_CF = "43800" OR 
                          TRNCOD3_CF = "43900" OR TRNCOD3_CF = "43020" OR TRNCOD3_CF = "43010") AND "14A" CT TRNCOD2_CF)
                        OR 
                        ((TRNCOD3_CF = "41101" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43701" ) AND "14A" CT TRNCOD2_CF AND "246" CT TRNCOD8_CF) 
                       )
/DERIVEDFIELD  PLUS_14_CHAMPS 14"~"
/OUTFILE ${SORT_O}
/INCLUDE POSTES
/REFORMAT FORMAT_STANDARD,RETINTAMT_M,PLUS_14_CHAMPS,TRN_NT,ORICOD_LS,FILLER_14_COLS
exit
EOF
SORT

#[012] [021] [23]
##-----------------------------------------------------------------------------
NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
# GTAR files merge
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of dGTAR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLSGTAR} 1000 1"
SORT_I2="${DFILT}/${NJOB}_190_${IB}_RETM0532_DLREGTAR.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_199_${IB}_SORT_DLAGTAR_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
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
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           6:1 - 14:,
        FILLER2          20:1 - 30:,
        FILLER2a         33:1 - 34:,
        FILLER3          36:1 - 40:
/KEYS  RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RTY_NF
      ,RETCUR_CF
      ,TRNCOD_CF
      ,PLC_NT
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD SCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD PLUS_16_CHAMPS "~~~~~~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/CONDITION POSTES  TRNCOD1_CF = "2" AND "1357" NC TRNCOD8_CF 
                   AND ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) 
                   AND (
                        ((TRNCOD3_CF = "41000" OR TRNCOD3_CF = "41100" OR TRNCOD3_CF = "41700" OR TRNCOD3_CF = "41800" OR TRNCOD3_CF = "41900" OR 
                          TRNCOD3_CF = "43000" OR TRNCOD3_CF = "43100" OR TRNCOD3_CF = "43600" OR TRNCOD3_CF = "43700" OR TRNCOD3_CF = "43800" OR 
                          TRNCOD3_CF = "43900" OR TRNCOD3_CF = "43020" OR TRNCOD3_CF = "43010") AND "14A" CT TRNCOD2_CF) 
                        OR 
                        ((TRNCOD3_CF = "41101" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43701" ) AND "14A" CT TRNCOD2_CF AND "246" CT TRNCOD8_CF) 
                       )
/OUTFILE ${SORT_O}
/INCLUDE POSTES
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW, BALSHRMTH_NF_NEW, BALSHRDAY_NF_NEW, FILLER1,SCOSTRMTH_NF_NEW, SCOSTRMTH_NF_NEW, CLM_NF, CUR_CF, AMT_MC, 
          FILLER2,SCOSTRMTH_NF_NEW,SCOSTRMTH_NF_NEW,FILLER2a,RETAMT_MC,FILLER3,RETINTAMT_MC,PLUS_16_CHAMPS,ORICOD_LS

exit
EOF
SORT

NSTEP=${NJOB}_220
#------------------------------------------------------------------------------
LIBEL="Add cols data to GT format"
PRG=ESTC1051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${ICLODAT_A}
PRS_CF 750
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_IRDPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_200_${IB}_SORT_DLAGTAR_O.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLAGTAR.dat
EXECPRG

NSTEP=${NJOB}_225
# Begin Merge and Sort
#[007]
#-----------------------------------------------------------------------------
LIBEL="EXCLUSION DES LOB 30 ET 31 et Ajout 16 champs + SUMMARIZE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_220_${IB}_ESTC1051_DLAGTAR.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_20_${IB}_SORT_DLAGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1           1:1 - 23:
       ,SSD_CF            1:1 -  1:EN
       ,ESB_CF            2:1 -  2:EN
       ,BALSHEY_NF        3:1 -  3:EN
       ,BALSHRMTH_NF      4:1 -  4:EN
       ,BALSHRDAY_NF      5:1 -  5:EN
       ,TRNCOD_CF         6:1 -  6:
       ,TRNCOD3_CF        6:3 -  6:7
       ,DBLTRNCOD_CF      7:1 -  7:
       ,CTR_NF            8:1 -  8:
       ,END_NT            9:1 -  9:EN
       ,SEC_NF           10:1 - 10:EN
       ,UWY_NF           11:1 - 11:
       ,UW_NT            12:1 - 12:EN
       ,OCCYEA_NF        13:1 - 13:
       ,ACY_NF           14:1 - 14:
       ,SCOSTRMTH_NF     15:1 - 15:EN
       ,SCOENDMTH_NF     16:1 - 16:EN
       ,CLM_NF           17:1 - 17:
       ,FILLER1a          1:1 - 17:
       ,CUR_CF           18:1 - 18:
       ,AMT_M            19:1 - 19:EN 15/3
       ,FILLER1b         20:1 - 23:
       ,RETCTR_NF        24:1 - 24:
       ,RETEND_NT        25:1 - 25:
       ,RETSEC_NF        26:1 - 26:EN
       ,RTY_NF           27:1 - 27:
       ,RETUW_NT         28:1 - 28:
       ,RETOCCYEA_NF     29:1 - 29:
       ,RETACY_NF        30:1 - 30:
       ,RETSCOSTRMTH_NF  31:1 - 31:EN
       ,RETSCOENDMTH_NF  32:1 - 32:EN
       ,FILLER2          29:1 - 33:
       ,RETCUR_CF        34:1 - 34:
       ,RETAMT_M         35:1 - 35:EN 15/3
       ,PLC_NT           36:1 - 36:EN
       ,FILLER3          36:1 - 40:
       ,RETINTAMT_M      41:1 - 41:EN 15/3
       ,ACMTRS_NT        42:1 - 42:
       ,ACMAMT_M         43:1 - 43:EN 15/3
       ,ACMCUR_CF        44:1 - 44:
       ,PRS_CF           45:1 - 45:
       ,SEG_NF           46:1 - 46:
       ,LOB_CF           47:1 - 47:
       ,NAT_CF           48:1 - 48:
       ,TYP_CT           49:1 - 49:
       ,PATTYP_CF        50:1 - 50:
       ,SEGLOB_CF        51:1 - 51:
/DERIVEDFIELD AJOUT30COLS 29"~"
/KEYS  RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RTY_NF
      ,RETUW_NT
      ,TRNCOD3_CF
      ,RETACY_NF
      ,RETSCOSTRMTH_NF
      ,RETSCOENDMTH_NF
      ,RETCUR_CF
      ,PLC_NT
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/CONDITION LOB ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "" )
/OUTFILE ${SORT_O}
/INCLUDE LOB
/REFORMAT FILLER1a
         ,CUR_CF
         ,AMT_M
         ,FILLER1b
         ,RETCTR_NF
         ,RETEND_NT
         ,RETSEC_NF
         ,RTY_NF
         ,RETUW_NT
         ,FILLER2
         ,RETCUR_CF
         ,RETAMT_M
         ,FILLER3
         ,RETINTAMT_M
         ,AJOUT30COLS
exit
EOF
SORT

NSTEP=${NJOB}_250
#Cancellation of the previous closing period in IGTAR
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closing period in GTAR..."
AWK_I=${DFILT}/${NJOB}_225_${IB}_SORT_DLAGTAR.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLAGTAR.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { 	if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
					if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
					if ( \$41 != 0 ) \$41 = sprintf("%-.3lf",-\$41);
					if ( substr(\$6,2,1)=="1" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="4" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="7" ) \$6=substr(\$6,1,1) "J" substr(\$6,3,5) "2";
					if ( substr(\$7,2,1)=="2" ) \$7=substr(\$7,1,1) "B" substr(\$7,3,5) "2";
					if ( substr(\$7,2,1)=="5" ) \$7=substr(\$7,1,1) "G" substr(\$7,3,5) "2";
					\$57 = "EBSGTA";
					print \$0;
       }
exit
EOF
AWK

NSTEP=${NJOB}_260
#-----------------------------------------------------------------------------
LIBEL="DLAGTAR file summarize to GLT format 71 cols"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_250_${IB}_AWK_DLAGTAR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        AMT_M            19:1 - 19:EN 15/3,
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
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 18:,
        FILLER2          20:1 - 34:,
        FILLER3          36:1 - 40:,
        FILLER4          42:1 - 71:
/KEYS  RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RTY_NF
      ,RETCUR_CF
      ,TRNCOD_CF
      ,PLC_NT
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION MONTANT ( AMT_MC !=0 OR RETAMT_MC !=0 OR RETINTAMT_MC !=0 )
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
/REFORMAT FILLER1,AMT_MC,FILLER2,RETAMT_MC,FILLER3,RETINTAMT_MC,FILLER4
exit
EOF
SORT

NSTEP=${NJOB}_270
# Double entry transaction code addition in  GT
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition DLAGTAA in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_260_${IB}_SORT_DLAGTAR_O.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${EST_DLASIIGTAR}
EXECPRG

# ----------------------------------------------------------------------------------------------------------
# ANNULATION GTR
# ----------------------------------------------------------------------------------------------------------
NSTEP=${NJOB}_300
#-----------------------------------------------------------------------------
# GTR files merge
#-----------------------------------------------------------------------------
#[010] Reformat [021]
LIBEL="Merge and sort of dGTR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLSGTR} 1000 1"
SORT_I2="${EST_DLREGTR} 1000 1"
SORT_I3="${EST_DLREMAJGTR} 1000 1"
#SORT_I4="${EST_DLAGTR} 1000 1"
#SORT_I5="${EST_DLRTCGTR} 1000 1"
#SORT_I6="${EST_DLRTGTR} 1000 1"
#SORT_I7="${EST_DLRPGTR} 1000 1"
#SORT_I8="${EST_DLRNPGTR} 1000 1"
#SORT_I9="${EST_DLRTFGTR} 1000 1"
#SORT_I10="${EST_IGTR} 1000 1"

# mofif par Mehdi a confirmer
#SORT_I11="${EST_DLRTCGTR} 1000 1"
#SORT_I4="${EST_DLAGTR} 1000 1"
#SORT_I5="${EST_DLRTCGTR} 1000 1"

SORT_I4="${EPO_FTECLEDRSO} 1000 1"
SORT_I5="${EST_FTECLEDASIISO} 1000 1"
# fin mofif par Mehdi a confirmer

SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLAGTR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
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
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        AMT_M            19:1 - 19:EN 15/3,
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
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        FILLER1           6:1 - 14:,
        FILLER2          20:1 - 30:,
        FILLER2a         33:1 - 34:,
        FILLER3          36:1 - 55:
/KEYS  RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RTY_NF
      ,RETCUR_CF
      ,TRNCOD_CF
      ,PLC_NT
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD SCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/CONDITION POSTES  TRNCOD1_CF = "2" AND "1357" NC TRNCOD8_CF 
                   AND ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} )
                   AND (
                    ((TRNCOD3_CF = "41000" OR TRNCOD3_CF = "41100" OR TRNCOD3_CF = "41700" OR TRNCOD3_CF = "41800" OR TRNCOD3_CF = "41900" OR 
                      TRNCOD3_CF = "43000" OR TRNCOD3_CF = "43100" OR TRNCOD3_CF = "43600" OR TRNCOD3_CF = "43700" OR TRNCOD3_CF = "43800" OR 
                      TRNCOD3_CF = "43900" OR TRNCOD3_CF = "43020" OR TRNCOD3_CF = "43010") AND "14A" CT TRNCOD2_CF) 
                    OR 
                    ((TRNCOD3_CF = "41101" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43701" ) AND "14A" CT TRNCOD2_CF AND "246" CT TRNCOD8_CF) 
                       )
/OUTFILE ${SORT_O}
/INCLUDE POSTES
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW, BALSHRMTH_NF_NEW, BALSHRDAY_NF_NEW, FILLER1,SCOSTRMTH_NF_NEW, SCOSTRMTH_NF_NEW, CLM_NF, CUR_CF, AMT_MC,
          FILLER2,SCOSTRMTH_NF_NEW,SCOSTRMTH_NF_NEW,FILLER2a,RETAMT_MC,FILLER3,ORICOD_LS
exit
EOF
SORT

#NSTEP=${NJOB}_320
## Split between LIFE and NON-LIFE GTR in progress ESTM7606 ...
##-----------------------------------------------------------------------------
#LIBEL="Split between LIFE and NON-LIFE GTR in progress ESTM7606 ..."
#PRG=ESTM7606
#export ${PRG}_I1="${DFILT}/${NJOB}_300_${IB}_SORT_DLAGTR_O.dat"
#export ${PRG}_I2="${DFILT}/${NJOB}_10_${IB}_SORT_IRDPERICASE_O.dat"
#export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_DLADGTR.dat"
#export ${PRG}_O2="${DFILT}/${NSTEP}_${IB}_${PRG}_DLAVGTR.dat"
#export ${PRG}_O3="${DFILT}/${NSTEP}_${IB}_${PRG}_DLAGTR_ANO.dat"
#EXECPRG

NSTEP=${NJOB}_320
#------------------------------------------------------------------------------
LIBEL="Add cols data to GT format"
PRG=ESTC1051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT R
BALSHTYEA_NF ${ICLODAT_A}
PRS_CF 750
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_IRDPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_300_${IB}_SORT_DLAGTR_O.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLADGTR.dat
EXECPRG

NSTEP=${NJOB}_325
#[007]
#[010]
#-----------------------------------------------------------------------------
LIBEL="ANNULATION PNA GTR : EXCLUSION DES LOB 30 ET 31 et Ajout 16 champs + SUMMARIZE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_320_${IB}_ESTC1051_DLADGTR.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_20_${IB}_SORT_DLAGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1           1:1 - 23:
       ,SSD_CF            1:1 -  1:EN
       ,ESB_CF            2:1 -  2:EN
       ,BALSHEY_NF        3:1 -  3:EN
       ,BALSHRMTH_NF      4:1 -  4:EN
       ,BALSHRDAY_NF      5:1 -  5:EN
       ,TRNCOD_CF         6:1 -  6:
       ,TRNCOD3_CF        6:3 -  6:7
       ,CTR_NF            8:1 -  8:
       ,END_NT            9:1 -  9:EN
       ,SEC_NF           10:1 - 10:EN
       ,UWY_NF           11:1 - 11:
       ,UW_NT            12:1 - 12:EN
       ,FILLER1a          1:1 - 17:
       ,CUR_CF           18:1 - 18:
       ,AMT_M            19:1 - 19:EN 15/3
       ,FILLER1b         20:1 - 23:
       ,RETCTR_NF        24:1 - 24:
       ,RETEND_NT        25:1 - 25:
       ,RETSEC_NF        26:1 - 26:EN
       ,RETUWY_NF        27:1 - 27:
       ,RETUW_NT         28:1 - 28:
       ,RETOCCYEA_NF     29:1 - 29:
       ,RETACY_NF        30:1 - 30:
       ,FILLER2          29:1 - 33:
       ,RETCUR_CF        34:1 - 34:
       ,RETAMT_M         35:1 - 35:EN 15/3
       ,PLC_NT           36:1 - 36:EN
       ,FILLER3          36:1 - 55:
       ,ACMTRS_NT        42:1 - 42:
       ,ACMAMT_M         43:1 - 43:EN 15/3
       ,ACMCUR_CF        44:1 - 44:
       ,PRS_CF           45:1 - 45:
       ,SEG_NF           46:1 - 46:
       ,LOB_CF           47:1 - 47:
       ,NAT_CF           48:1 - 48:
       ,TYP_CT           49:1 - 49:
       ,PATTYP_CF        50:1 - 50:
       ,SEGLOB_CF        51:1 - 51:
/KEYS  RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RETUWY_NF
      ,RETUW_NT
      ,RETOCCYEA_NF
      ,RETACY_NF
      ,RETCUR_CF
      ,TRNCOD3_CF
      ,PLC_NT
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
      ,ACMCUR_CF
/CONDITION LOB ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "" )
/SUMMARIZE TOTAL ACMAMT_M, TOTAL AMT_M, TOTAL RETAMT_M
/OUTFILE ${SORT_O}
/INCLUDE LOB
/REFORMAT FILLER1a
         ,CUR_CF
         ,AMT_M 
         ,FILLER1b
         ,RETCTR_NF
         ,RETEND_NT
         ,RETSEC_NF
         ,RETUWY_NF
         ,RETUW_NT
         ,FILLER2
         ,RETCUR_CF
         ,RETAMT_M
         ,FILLER3
exit
EOF
SORT

NSTEP=${NJOB}_350
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closing period in IGTR..."
AWK_I=${DFILT}/${NJOB}_325_${IB}_SORT_DLAGTR.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLAGTR.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { 	if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
					if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
					if ( \$43 != 0 ) \$43 = sprintf("%-.3lf",-\$43);
					if ( substr(\$6,2,1)=="1" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="4" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="7" ) \$6=substr(\$6,1,1) "J" substr(\$6,3,5) "2";
					if ( substr(\$7,2,1)=="2" ) \$7=substr(\$7,1,1) "B" substr(\$7,3,5) "2";
					if ( substr(\$7,2,1)=="5" ) \$7=substr(\$7,1,1) "G" substr(\$7,3,5) "2";
					\$57 = "EBSGTA";
					print \$0;
       }
exit
EOF
AWK
	
NSTEP=${NJOB}_360
#-----------------------------------------------------------------------------
LIBEL="DLAGTR file suumarize to format GLT 71 cols"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_350_${IB}_AWK_DLAGTR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        CUR_CF           18:1 - 18:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        AMT_M            19:1 - 19:EN 15/3,
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
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 18:,
        FILLER2          20:1 - 34:,
        FILLER3          36:1 - 40:,
        ORICOD_LS        57:1 - 57:
/KEYS  RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RTY_NF
      ,RETCUR_CF
      ,TRNCOD_CF
      ,PLC_NT
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD AJOUT15COLS 15"~"
/DERIVEDFIELD AJOUT14COLS 13"~"
/CONDITION MONTANT ( AMT_MC !=0 OR RETAMT_MC !=0 )
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
/REFORMAT FILLER1,AMT_MC,FILLER2,RETAMT_MC,FILLER3,RETINTAMT_MC,AJOUT15COLS,ORICOD_LS,AJOUT14COLS
exit
EOF
SORT

NSTEP=${NJOB}_370
# Double entry transaction code addition in  GT
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition DLAGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_360_${IB}_SORT_DLAGTR.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${EST_DLASIIGTR}
EXECPRG

JOBEND
