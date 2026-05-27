#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - ANNULATION DES PNAS
# nom du script SHELL           : ESID3601.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/11/2012
# auteur                        : PHILIPPE PEZOUT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  :spot:24041 ANNULATION DES PNAS
#-----------------------------------------------------------------------------
#historique des modifications :
#[002] 20/01/2013 :spot:24698 - -=PhP=-  corrections pour la conso
#[003] 20/01/2013 :spot:24836 - -=PhP=-  corrections pour la conso
#[004] 20/02/2013 :spot:24875 - -=PhP=-  corrections pour la conso
#[004] 27/02/2013 :spot:24905 - -=PhP=-  corrections pour la conso
#[005] 10/04/2013 :spot:25096 - -=PhP=-  corrections pour la conso 
#[006] 10/06/2013 :spot:25282 - -=PhP=-  corrections pour la conso 
#[007] 23/05/2014 :spot:26838 - A. Ben Jeddou - Corrections sur le batch solvency P&C : reprise de code suite au passage  de 2A à la 1B
#[008] 27/06/2014 :spot:26956 - C.DESPRET     - Corrections sur le batch solvency P&C : reprise de code suite au passage  de 2A à la 1B
#[009] 30/06/2014 :spot:26956 - P.PEZOUT      - Corrections sur le batch solvency P&C : reprise de code suite au passage  de 2A à la 1B
#[010] 07/07/2014 :spot:27103 - C.DESPRET     - pb format du fichier DLASIIGTR formaté par le ESID3601 STEP 325
#[011] 10/07/2014 :spot:xxxxx - C.DESPRET     - Remove Life subsidiaries
#[012] 22/09/2014 :spot:27486 - R. Cassis share sort step 200 to 2 steps to avoid syncsort memory abend.
#[012] 06/10/2014 :spot:27903 - C.DESPRET     - Annulation des ES post Omega IFRS Sociales : ne pas prendre en compte les ecritures services EBS
#[013] 28/04/2015 :spot:27903 - Florent       - ajout des PNA FAC RPCC là où on annule les PNAs
#[014] 02/11/2015 :spot:29615 - P.PEZOUT EST45 gzip et maj step 100
#[015] 26/05/2016 :spot 30583 - S.Behague     - Spira 41148
#[016] 28/06/2016 :spot:31251 - Florent       - spira 48151- EBS - UPR cancel - correction pour le mix of internal and external retrocessionaire: modif step 150 et 250 pour GTAA et GTAR
#[017] 18/11/2016 :spira:57799  Florent  Mise au format à 71 colonnes pour le fichier EST_DLASIIGT*
#[018] 15/11/2017 :spira:63149  Roger    Ajout postes dans filtre du tri : 4601 et 4611 pour (POC-POS) postes ULAE
#[019] 26/02/2018 :spira:63929  Roger    Ajout postes dans filtre pour (POC-POS) postes DSC SII dans tris : 4160 et 4260 au debut et 41601 et 42601 pour la rétro générée et suppression 46010 (car doublé)
#=============================================================================
#set -x

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

touch ${DFILT}/${NCHAIN}_vide.dat

TYPEPO=""
if [ "${TYPEINV}" != "INV" ]
then
	#en input
	EST_IADPERICASE=${EPO_IADPERICASE}
	#EST_CRVPERICASE0=${EPO_CRVPERICASE0}
	EST_IRDPERICASE0=${EPO_IRDPERICASE0}
	EST_FTRSLNK=${EPO_FTRSLNK}
	EST_FBOPRSLNK=${EPO_FBOPRSLNK}
	EST_FDETTRS=${EPO_FDETTRS}
	EST_FCURQUOT=${EPO_FCURQUOT}
	EST_DLRGTAA=${EPO_DLRGTAA}
	EST_IGTAAF=${EPO_FTECLEDASO}
  EST_FPLATXCUM=${EPO_FPLATXCUM}
	if [ "${TYPEINV}" = "POS" ]
	then
		#[012] On ne prend pas les ES 
    EST_DLSGTAA=${DFILT}/${NCHAIN}_vide.dat
    EST_DLSGTAR=${DFILT}/${NCHAIN}_vide.dat
    EST_DLSGTR=${DFILT}/${NCHAIN}_vide.dat


		EST_DLDGTAA=${EPO_DLDGTAASO}
		EST_DLREGTAR=${EPO_DLREGTARSO}
		EST_DLREMAJGTAR=${EPO_DLREMAJGTARSO}
		EST_DLREGTR=${EPO_DLREGTRSO}
		EST_DLREMAJGTR=${EPO_DLREMAJGTRSO}
	else
		EST_DLSGTAA=${EPO_DLSGTAACO}
		EST_DLSGTAR=${EPO_DLSGTARCO}
		EST_DLSGTR=${EPO_DLSGTRCO}
		EST_DLDGTAA=${EPO_DLDGTAACO}
		EST_DLREGTAR=${EPO_DLREGTARCO}
		EST_DLREMAJGTAR=${EPO_DLREMAJGTARCO}
		EST_DLREGTR=${EPO_DLREGTRCO}
		EST_DLREMAJGTR=${EPO_DLREMAJGTRCO}
	fi
	#en output
	EST_DLASIIGTAA=${EPO_DLASIIGTAA}
	EST_DLASIIGTAR=${EPO_DLASIIGTAR}
	EST_DLASIIGTR=${EPO_DLASIIGTR}
fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TRIM_NF...............: ${TRIM_NF}"
ECHO_LOG "#===> TYPEINV...............: ${TYPEINV}"
ECHO_LOG "#===> ICLODAT_D.............: ${ICLODAT_D}"
ECHO_LOG "#....................INPUT.................."
ECHO_LOG "#===> EST_IADPERICASE.......: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_IRDPERICASE.......: ${EST_IRDPERICASE}"
ECHO_LOG "#===> EST_FTRSLNK...........: ${EST_FTRSLNK}"
ECHO_LOG "#===> EST_FBOPRSLNK.........: ${EST_FBOPRSLNK}"
ECHO_LOG "#===> EST_DLAGTAA...........: ${EST_DLAGTAA}"
ECHO_LOG "#===> EST_DLAGTAR...........: ${EST_DLAGTAR}"
ECHO_LOG "#===> EST_DLAGTR............: ${EST_DLAGTR}"
ECHO_LOG "#===> EST_IGTAAF............: ${EST_IGTAAF}"
ECHO_LOG "#===> EST_DLDGTAA...........: ${EST_DLDGTAA}"
ECHO_LOG "#===> EST_DLRGTAA...........: ${EST_DLRGTAA}"
ECHO_LOG "#===> EST_DLSGTAA...........: ${EST_DLSGTAA}"
ECHO_LOG "#===> EST_DLSGTAR...........: ${EST_DLSGTAR}"
ECHO_LOG "#===> EST_DLREGTAR..........: ${EST_DLREGTAR}"
ECHO_LOG "#===> EST_DLREMAJGTAR.......: ${EST_DLREMAJGTAR}"
ECHO_LOG "#===> EST_DLSGTR............: ${EST_DLSGTR}"
ECHO_LOG "#===> EST_DLREGTR...........: ${EST_DLREGTR}"
ECHO_LOG "#===> EST_DLREMAJGTR........: ${EST_DLREMAJGTR}"
ECHO_LOG "#===> EPO_FTECLEDASO........: ${EPO_FTECLEDASO}"
ECHO_LOG "#===> EST_FTRSLNK...........: ${EST_FTRSLNK}"
ECHO_LOG "#===> EST_FDETTRS...........: ${EST_FDETTRS}"
ECHO_LOG "#===> EST_FCURQUOT..........: ${EST_FCURQUOT}"
ECHO_LOG "#....................OUTPUT .................."
ECHO_LOG "#===> EST_DLASIIGTAA........: ${EST_DLASIIGTAA}"
ECHO_LOG "#===> EST_DLASIIGTAR........: ${EST_DLASIIGTAR}"
ECHO_LOG "#===> EST_DLASIIGTR.........: ${EST_DLASIIGTR}"
ECHO_LOG "#========================================================================="

# creation des fichiers vide
touch ${EST_DLASIIGTAA}
touch ${EST_DLASIIGTAR}
touch ${EST_DLASIIGTR}

datej=`date '+%Y%m%d%H%M%S'`
datedel=`echo  "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-1; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel1=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-2; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`
datedel2=`echo "$datej" | awk '{ j1 = substr($0,7,2); m1 = substr($0,5,2); if (j1 < "03") {j2 = "30"; m2 = m1-1; } else {j2 = j1-3; m2 = m1;} if (length(j2) < 2) j2 = "0" j2; if (length(m2) < 2) m2 = "0" m2; print substr($0,1,4) m2 j2;}'`

NSTEP=${NJOB}_00
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*${datedel}*.dat"
RMFIL "${DFILT}/${NJOB}*${datedel1}*.dat"
RMFIL "${DFILT}/${NJOB}*${datedel2}*.dat"


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

#[018][019]
NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
# cancelation of previous EBS lines
#-----------------------------------------------------------------------------
LIBEL="selection of previous EBS lines ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${TYPEINV}" = "INV" ]
then
	SORT_I="${EST_IGTAAF} 1000 1"
elif [ "${TYPEINV}" = "POS" ] 
then
		SORT_I="${EPO_FTECLEDASO} 1000 1"
else
		SORT_I="${EPO_FTECLEDASO} 1000 1"
		SORT_I2="${EPO_FTECLEDASIISO} 1000 1"
fi
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
        RETINTAMT_M      41:1 - 41:EN 15/3,
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
/DERIVEDFIELD PLUS_02_CHAMPS "~100~"
/DERIVEDFIELD PLUS_16_CHAMPS "750~~01~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/CONDITION ACCEPT  TRNCOD1_CF = "1" AND ( AMT_M !=0 OR RETAMT_M !=0 ) AND "AE" CT TRNCOD2_CF AND "1357" NC TRNCOD8_CF 
                   AND (TRNCOD4_CF = "1007" OR TRNCOD4_CF = "1008" OR TRNCOD4_CF = "4601" OR TRNCOD4_CF = "4611" OR
                   TRNCOD4_CF = "4260" OR TRNCOD4_CF = "4261" OR TRNCOD4_CF = "4160" OR TRNCOD4_CF = "4161")
/CONDITION RETRO   TRNCOD1_CF = "2" AND ( AMT_M !=0 OR RETAMT_M !=0 ) AND "AE" CT TRNCOD2_CF AND "1357" NC TRNCOD8_CF 
                   AND (TRNCOD4_CF = "1007" OR TRNCOD4_CF = "1008" OR TRNCOD4_CF = "4601" OR TRNCOD4_CF = "4611" OR 
                   TRNCOD4_CF = "4260" OR TRNCOD4_CF = "4261" OR TRNCOD4_CF = "4160" OR TRNCOD4_CF = "4161")
/OUTFILE ${SORT_O}
/INCLUDE ACCEPT
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW,FILLER1,SCOSTRMTH_NF_NEW,SCOSTRMTH_NF_NEW, 
          CLM_NF, CUR_CF, AMT_M,FILLER2,RETAMT_M,FILLER3,PLUS_02_CHAMPS,AMT_M,CUR_CF,PLUS_16_CHAMPS,ORICOD_LS
/OUTFILE ${SORT_O2}
/INCLUDE RETRO
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW,FILLER1,SCOSTRMTH_NF_NEW,SCOSTRMTH_NF_NEW, 
          CLM_NF, CUR_CF, AMT_M,FILLER2,RETAMT_M,FILLER3,PLUS_02_CHAMPS,RETAMT_M,RETCUR_CF,PLUS_16_CHAMPS,ORICOD_LS
/OUTFILE ${SORT_O3}
/INCLUDE RETRO
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW,TRNCOD_CF,DBLTRNCOD_CF,ZONE_ACCEPT, 
          ZONE_RETRO,RETAMT_M,FILLER3,PLUS_02_CHAMPS,RETAMT_M,RETCUR_CF,PLUS_16_CHAMPS,ORICOD_LS
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_20_${IB}_SORT_DLAGTAA_O.dat    > ${DFILT}/${NJOB}_020_DLAGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_20_${IB}_SORT_DLAGTAR_O.dat    > ${DFILT}/${NJOB}_020_DLAGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_20_${IB}_SORT_DLAGTR_O.dat     > ${DFILT}/${NJOB}_020_DLAGTR.dat.gz

#[018]
NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
# GTAa files merge
#${EPO_FTECLEDASO}
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of dGTAa files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA} 1000 1"
SORT_I2="${EST_DLSGTAA} 1000 1"
SORT_I3="${EST_DLRGTAA} 1000 1"
SORT_I4="${EST_IGTAAF} 1000 1"
if [ "${TYPEINV}" = "INV" ]
then
	SORT_I5="${EST_DLAGTAA} 1000 1"
fi
if [ "${TYPEINV}" = "POC" ]
then
	SORT_I5="${EPO_FTECLEDASIISO} 1000 1"
	#SORT_I6="${EPO_DLSGTAASIICO} 1000 1"
fi
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
                      TRNCOD3_CF = "43900" OR TRNCOD3_CF = "46110")
                      AND "14A" CT TRNCOD2_CF ) 
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

gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_DLAGTAA_O.dat    > ${DFILT}/${NJOB}_100_DLAGTAA_O.dat.gz
gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_DLAGTAA_O2.dat   > ${DFILT}/${NJOB}_100_DLAGTAA_O2.dat.gz

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
/CONDITION LOB ( LOB_CF != "30" AND LOB_CF != "31") AND ((SSD_CF=7 AND ESB_CF!=2) OR (SSD_CF=20 AND (ESB_CF != 6 AND ESB_CF != 9 AND ESB_CF != 14)) OR (SSD_CF !=4 AND SSD_CF !=7 AND SSD_CF !=8 AND SSD_CF !=9 AND SSD_CF !=14 AND SSD_CF !=16 AND SSD_CF !=18 AND SSD_CF !=19 AND SSD_CF !=20 AND SSD_CF !=23 AND SSD_CF !=24 AND SSD_CF !=25))
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

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_DLAGTAA_O.dat    > ${DFILT}/${NJOB}_100_DLAGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_120_${IB}_ESTC1051_DLADGTAA.dat > ${DFILT}/${NJOB}_120_DLAGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_125_${IB}_SORT_DLADGTAA.dat     > ${DFILT}/${NJOB}_125_SORT_DLADGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_150_${IB}_AWK_DLAGTAA.dat       > ${DFILT}/${NJOB}_150_DLAGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_160_${IB}_SORT_DLAGTAA_O.dat    > ${DFILT}/${NJOB}_160_DLAGTAA.dat.gz

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

# 2 fichiers à zipper, code à placer dans la zone existante « TRACES POUR l'ENVIRONNEMENT DE TEST »
gzip -c ${DFILT}/${NJOB}_180_${IB}_SORT_DLREGTAR.dat         > ${DFILT}/${NJOB}_180_DLSGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_190_${IB}_RETM0532_DLREGTAR.dat     > ${DFILT}/${NJOB}_190_RETM0532_DLREGTAR.dat.gz

#[012][018]
##-----------------------------------------------------------------------------
NSTEP=${NJOB}_199
#-----------------------------------------------------------------------------
# GTAR files merge
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of dGTAR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${TYPEINV}" = "INV" ]
then
	SORT_I="${EST_DLAGTAR} 1000 1"
	SORT_I1="${EST_DLRTCGTAR} 1000 1"
	SORT_I2="${EST_DLRTGTAR} 1000 1"
	SORT_I3="${EST_DLRPGTAR} 1000 1"
	SORT_I4="${EST_DLRNPGTAR} 1000 1"
	SORT_I5="${EST_DLRTFGTAR} 1000 1"
	SORT_I6="${EST_IGTAR} 1000 1"
else
	SORT_I="${EPO_FTECLEDASO} 1000 1"
	if [ "${TYPEINV}" = "POC" ]
	then
		SORT_I2="${EPO_FTECLEDASIISO} 1000 1"
		#SORT_I6="${EPO_DLSGTARSIICO} 1000 1"
	fi
fi
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
        RETINTAMT1_M     41:1 - 41:EN 15/3,
        FILLER1           6:1 - 14:,
        FILLER2          20:1 - 30:,
        FILLER2a         33:1 - 34:,
        FILLER3          36:1 - 40:,
        LOBRET_CF        46:1 - 46:,
        RETINTAMT2_M     88:1 - 88:EN 15/3
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
                      TRNCOD3_CF = "43900" OR TRNCOD3_CF = "46110")
                      AND "14A" CT TRNCOD2_CF ) 
                    OR 
                    ((TRNCOD3_CF = "41101" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43701" ) AND "14A" CT TRNCOD2_CF AND "246" CT TRNCOD8_CF) 
                       )
/OUTFILE ${SORT_O}
/INCLUDE POSTES

exit
EOF
SORT

#[012][018][019]
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
        RETINTAMT1_M     41:1 - 41:EN 15/3,
        FILLER1           6:1 - 14:,
        FILLER2          20:1 - 30:,
        FILLER2a         33:1 - 34:,
        FILLER3          36:1 - 40:,
        LOBRET_CF        46:1 - 46:,
        RETINTAMT2_M     88:1 - 88:EN 15/3
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
/CONDITION LOBRET_E LOBRET_CF != ""
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/DERIVEDFIELD RETINTAMT_M if LOBRET_E then RETINTAMT2_M else RETINTAMT1_M
/CONDITION POSTES  TRNCOD1_CF = "2" AND "1357" NC TRNCOD8_CF 
                   AND ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) 
                   AND (
                    ((TRNCOD3_CF = "41000" OR TRNCOD3_CF = "41100" OR TRNCOD3_CF = "41700" OR TRNCOD3_CF = "41800" OR TRNCOD3_CF = "41900" OR 
                      TRNCOD3_CF = "43000" OR TRNCOD3_CF = "43100" OR TRNCOD3_CF = "43600" OR TRNCOD3_CF = "43700" OR TRNCOD3_CF = "43800" OR 
                      TRNCOD3_CF = "43900" OR TRNCOD3_CF = "46010" OR TRNCOD3_CF = "46110" OR TRNCOD3_CF = "41601" OR TRNCOD3_CF = "42601")
                      AND "14A" CT TRNCOD2_CF ) 
                    OR 
                    ((TRNCOD3_CF = "41101" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43701" ) AND "14A" CT TRNCOD2_CF AND "246" CT TRNCOD8_CF) 
                       )
/OUTFILE ${SORT_O}
/INCLUDE POSTES
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW, BALSHRMTH_NF_NEW, BALSHRDAY_NF_NEW, FILLER1,SCOSTRMTH_NF_NEW, SCOSTRMTH_NF_NEW, CLM_NF, CUR_CF, AMT_MC, 
          FILLER2,SCOSTRMTH_NF_NEW,SCOSTRMTH_NF_NEW,FILLER2a,RETAMT_MC,FILLER3,RETINTAMT_M,PLUS_16_CHAMPS,ORICOD_LS

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
      ,RETCUR_CF
      ,TRNCOD3_CF
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

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_IRDPERICASE_O.dat > ${DFILT}/${NJOB}_10_SORT_IRDPERICASE_O.dat.gz
gzip -c ${DFILT}/${NJOB}_200_${IB}_SORT_DLAGTAR_O.dat    > ${DFILT}/${NJOB}_200_SORT_DLAGTAR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_220_${IB}_ESTC1051_DLAGTAR.dat  > ${DFILT}/${NJOB}_220_ESTC1051_DLAGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_225_${IB}_SORT_DLAGTAR.dat      > ${DFILT}/${NJOB}_225_SORT_DLAGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_250_${IB}_AWK_DLAGTAR.dat       > ${DFILT}/${NJOB}_250_AWK_DLAGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_260_${IB}_SORT_DLAGTAR_O.dat    > ${DFILT}/${NJOB}_260_SORT_DLAGTAR_O.dat.gz

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
#[010] Reformat [018]
LIBEL="Merge and sort of dGTR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLSGTR} 1000 1"
SORT_I2="${EST_DLREGTR} 1000 1"
SORT_I3="${EST_DLREMAJGTR} 1000 1"
if [ "${TYPEINV}" = "INV" ]
then
	SORT_I4="${EST_DLAGTR} 1000 1"
	SORT_I5="${EST_DLRTCGTR} 1000 1"
	SORT_I6="${EST_DLRTGTR} 1000 1"
	SORT_I7="${EST_DLRPGTR} 1000 1"
	SORT_I8="${EST_DLRNPGTR} 1000 1"
	SORT_I9="${EST_DLRTFGTR} 1000 1"
	SORT_I10="${EST_IGTR} 1000 1"
else
	SORT_I4="${EPO_FTECLEDRSO} 1000 1"
	if [ "${TYPEINV}" = "POC" ]
	then
		SORT_I5="${EPO_FTECLEDRSIISO} 1000 1"
		#SORT_I6="${EPO_DLSGTRSIICO} 1000 1"
	fi
fi
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
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD PLUS_16_CHAMPS0 "~0~~~~~~~~~~~~~~~"
/DERIVEDFIELD PLUS_16_CHAMPS "~~~~~~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/CONDITION POSTES  TRNCOD1_CF = "2" AND "1357" NC TRNCOD8_CF 
                   AND ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} )
                   AND (
                    ((TRNCOD3_CF = "41000" OR TRNCOD3_CF = "41100" OR TRNCOD3_CF = "41700" OR TRNCOD3_CF = "41800" OR TRNCOD3_CF = "41900" OR 
                      TRNCOD3_CF = "43000" OR TRNCOD3_CF = "43100" OR TRNCOD3_CF = "43600" OR TRNCOD3_CF = "43700" OR TRNCOD3_CF = "43800" OR 
                      TRNCOD3_CF = "43900" OR TRNCOD3_CF = "46110")
                      AND "14A" CT TRNCOD2_CF ) 
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

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_300_${IB}_SORT_DLAGTR_O.dat    > ${DFILT}/${NJOB}_300_SORT_DLAGTR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_320_${IB}_ESTC1051_DLADGTR.dat > ${DFILT}/${NJOB}_320_ESTC1051_DLADGTR.dat.gz
gzip -c ${DFILT}/${NJOB}_325_${IB}_SORT_DLAGTR.dat      > ${DFILT}/${NJOB}_325_SORT_DLAGTR.dat.gz
gzip -c ${DFILT}/${NJOB}_350_${IB}_AWK_DLAGTR.dat       > ${DFILT}/${NJOB}_350_AWK_DLAGTR.dat.gz
gzip -c ${DFILT}/${NJOB}_360_${IB}_SORT_DLAGTR.dat      > ${DFILT}/${NJOB}_360_SORT_DLAGTR.dat.gz

NSTEP=${NJOB}_370
# Double entry transaction code addition in  GT
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition DLAGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_360_${IB}_SORT_DLAGTR.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${EST_DLASIIGTR}
EXECPRG

NSTEP=${NJOB}_450
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND
