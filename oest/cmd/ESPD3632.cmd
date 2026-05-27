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

#[021]
NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
# GTAa files merge
#${EPO_FTECLEDA}
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=" ${EST_DLDGTAA} 1000 1"
SORT_I2="${EST_DLSGTAA} 1000 1"
SORT_I3="${EST_DLRGTAA} 1000 1"
SORT_I4="${EST_IGTAAF} 1000 1"
#SORT_I5="${EST_DLAGTAA} 1000 1"
#SORT_I5="${EST_FTECLEDASII} 1000 1" [22]
SORT_I5="${DFILT}/${NCHAIN}_ESPD3631${TYPEINV}_15_${IB}_SORT_FTECLEDASIISOFormatGTA_O1.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_O.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_O2.dat
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
                          TRNCOD3_CF = "43900" OR TRNCOD3_CF = "46010" OR TRNCOD3_CF = "46110" OR TRNCOD3_CF = "43020" OR TRNCOD3_CF = "43010") AND "14A" CT TRNCOD2_CF) 
                        OR 
                        ((TRNCOD3_CF = "41101" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43701" ) AND "14A" CT TRNCOD2_CF AND "246" CT TRNCOD8_CF) 
                        OR TRNCOD4_CF = "4160" OR TRNCOD4_CF = "4260"
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

NSTEP=${NJOB}_100A
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_SORT_DLAGTAA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_RATE.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS SSD_CF           1:1 -  1:,
        UWY_NF          11:1 - 11:,
        CUR_CF          18:1 - 18:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 51:

/joinkeys
      SSD_CF
           ,CUR_CF
/INFILE ${DFILT}/${NCHAIN}_ESPD3631${TYPEINV}_30_${IB}_FCURQUOT_${ICLODAT_A}.dat 1000 1 "~"
/joinkeys
      CURQUOT_SSD_CF
           ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
           leftside:all_cols
          ,rightside:CURQUOT_RATE

exit
EOF
SORT



NSTEP=${NJOB}_100B
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100A_${IB}_SORT_DLAGTAA_RATE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_RATE_RETRATE.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS SSD_CF            1:1 -  1:,
        RTY_NF           27:1 - 27:,
        RETCUR_CF        34:1 - 34:,
        CURQUOT_SSD_CF   1:1 -  1:,
        CURQUOT_CUR_CF   2:1 -  2:,
        CURQUOT_UWY_NF   3:1 -  3:,
        CURQUOT_RATE     4:1 -  4:,
        all_cols         1:1  - 52:

/joinkeys
      SSD_CF
           ,RETCUR_CF
/INFILE ${DFILT}/${NCHAIN}_ESPD3631${TYPEINV}_30_${IB}_FCURQUOT_${ICLODAT_A}.dat 1000 1 "~"
/joinkeys
      CURQUOT_SSD_CF
           ,CURQUOT_CUR_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
           leftside:all_cols
          ,rightside:CURQUOT_RATE

exit
EOF
SORT



NSTEP=${NJOB}_100C
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100B_${IB}_SORT_DLAGTAA_RATE_RETRATE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_RATE_RETRATE_EBS.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS TRNCOD_CF         6:1 -  6:,
        DETTRS_CF        3:1 -  3:,
        ACMTRS_NT        2:1 -  2:,
        all_cols         1:1  - 53:
/joinkeys
       TRNCOD_CF
/INFILE ${DFILT}/${NCHAIN}_ESPD3631${TYPEINV}_40_${IB}_FTRSLNK_EBS.dat   1000 1 "~"
/joinkeys
       DETTRS_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
      leftside:all_cols
     ,rightside:ACMTRS_NT

exit
EOF
SORT



NSTEP=${NJOB}_100D
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100C_${IB}_SORT_DLAGTAA_RATE_RETRATE_EBS.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_RATE_RETRATE_EBS_FBOPRSLNK.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS
        TRNCOD_CF                       6:1 -  6:,
                FBOPRSLNK_ACMTRSL2_NT     4:1 -  4:,
                FBOPRSLNK_ACMTRSL3_NT     5:1 -  5:,
                FBOPRSLNK_DETTRS_CF       9:1 -  9:,
                FBOPRSLNK_TRNTYP_CT      14:1 - 14:,
                all_cols                              1:1  - 54:
/joinkeys
       TRNCOD_CF
/INFILE ${EST_FBOPRSLNK_TXT} 1000 1 "~"
/joinkeys
       FBOPRSLNK_DETTRS_CF
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT
         leftside:all_cols
        ,rightside:FBOPRSLNK_ACMTRSL2_NT
        ,rightside:FBOPRSLNK_ACMTRSL3_NT
        ,rightside:FBOPRSLNK_TRNTYP_CT

exit
EOF
SORT


NSTEP=${NJOB}_100E
#------------------------------------------------------------------------------
LIBEL="Sort ${SORT_O}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100D_${IB}_SORT_DLAGTAA_RATE_RETRATE_EBS_FBOPRSLNK.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_RATE_RETRATE_EBS_FBOPRSLNK.dat 1000 1 "
INPUT_TEXT ${SORT_CMD} << EOF

/FIELDS
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        RETCTR_NF        24:1 - 24:,
        RETEND_NT        25:1 - 25:EN,
        RETSEC_NF        26:1 - 26:EN,
        RTY_NF           27:1 - 27:,
        RETUW_NT         28:1 - 28:EN,
        PLC_NT           36:1 - 36:,
        all_cols          1:1  - 57:
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

exit
EOF
SORT


NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
LIBEL="Add cols data to GT format"
PRG=ESTC1051B
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT A
BALSHTYEA_NF ${ICLODAT_A}
PRS_CF 750
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NCHAIN}_ESPD3631${TYPEINV}_70_${IB}_IADPERICASE_PCP_EGP.dat         # PHP mettre ici un fichier dans DFILI
export ${PRG}_I2=${DFILT}/${NJOB}_100E_${IB}_SORT_DLAGTAA_RATE_RETRATE_EBS_FBOPRSLNK.dat
#export ${PRG}_I3=${EST_FTRSLNK}
#export ${PRG}_I4=${EST_FCURQUOT}
#export ${PRG}_I5=${EST_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLADGTAA.dat
EXECPRG

#[011] Remove Life SSD
NSTEP=${NJOB}_125
#-----------------------------------------------------------------------------
LIBEL="ANNULATION PNA : EXCLUSION DES LOB 30 ET 31 et Ajout 16 champs ET SUMMARIZE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_ESTC1051B_DLADGTAA.dat 1000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESPD3631${TYPEINV}_20_${IB}_SORT_DLAGTAA_O.dat 1000 1"
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


JOBEND