#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - ANNULATION DES PNAS
# nom du script SHELL           : ESID3705.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/11/2012
# auteur                        : PHILIPPE PEZOUT
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  :spot:24041 ANNULATION DES PNAS
#
#[002] 14/11/2013 R. Cassis :spot:25427 - modifs centralization des bases
#[014] 26/05/2016 S.Behague :spot:30583: Spira 41148
#===============================================================================
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
	EST_DLDGTAA=${EPO_DLDGTAASO}
	EST_DLRGTAA=${EPO_DLRGTAA}
	EST_DLREGTAR=${EPO_DLREGTARSO}
	EST_DLREMAJGTAR=${EPO_DLREMAJGTARSO}
	EST_DLREGTR=${EPO_DLREGTRSO}
	EST_DLREMAJGTR=${EPO_DLREMAJGTRSO}
	if [ "${TYPEINV}" != "INV" ]
	then
		EST_IGTAAF=${EPO_FTECLEDASO}
		EST_CURGTA=${EPO_FTECLEDASO}
		EST_DLSGTAA=${EPO_DLSGTAASIISO}
		EST_DLSGTAR=${EPO_DLSGTARSIISO}
		EST_DLSGTR=${EPO_DLSGTRSIISO}
	else
		EST_IGTAAF=${EPO_FTECLEDASIISO}
		EST_CURGTA=${EPO_FTECLEDASIISO}
		EST_DLSGTAA=${EPO_DLSGTAASIICO}
		EST_DLSGTAR=${EPO_DLSGTARSIICO}
		EST_DLSGTR=${EPO_DLSGTRSIISCO}
	fi
	#en output
	EST_DLASIIGTAA=${EPO_DLASIIGTAA}
	EST_DLASIIGTAR=${EPO_DLASIIGTAR}
	EST_DLASIIGTR=${EPO_DLASIIGTR}
fi

if [ "${EST_ESPD2000_COND3}" = "Y" ]
then
#	export EST_CURGTA=${DARCH}/`basename ${EST_CURGTA} .dat`_${ICLODAT_A}${ICLODAT_M}.arc
	export EST_CURGTR=${DARCH}/`basename ${EST_CURGTR} .dat`_${ICLODAT_A}${ICLODAT_M}.arc
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
ECHO_LOG "#===> EST_CURGTA............: ${EST_CURGTA}"
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
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAA_O.dat
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
                    ((TRNCOD3_CF = "41000" OR TRNCOD3_CF = "41100" OR TRNCOD3_CF = "41800" OR TRNCOD3_CF = "41900" OR 
                      TRNCOD3_CF = "43000" OR TRNCOD3_CF = "43100" OR TRNCOD3_CF = "43600" OR TRNCOD3_CF = "43700" OR TRNCOD3_CF = "43800" OR TRNCOD3_CF = "43900" ) AND "14A" CT TRNCOD2_CF ) 
                    OR 
                    ((TRNCOD3_CF = "41101" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43701" ) AND "14A" CT TRNCOD2_CF AND TRNCOD8_CF="2") 
                       )
/OUTFILE ${SORT_O}
/INCLUDE POSTES
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW,BALSHRMTH_NF_NEW,BALSHRDAY_NF_NEW,FILLER1,SCOSTRMTH_NF_NEW,SCOSTRMTH_NF_NEW, 
          CLM_NF, CUR_CF, AMT_M,FILLER2,RETAMT_M,FILLER3,PLUS_16_CHAMPS,ORICOD_LS
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_DLAGTAA_O.dat    > ${DFILT}/${NJOB}_100_DLAGTAA.dat.gz

NSTEP=${NJOB}_120
# Begin programme C
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

NSTEP=${NJOB}_125
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="ANNULATION PNA : EXCLUSION DES LOB 30 ET 31 et Ajout 16 champs ET SUMMARIZE "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_ESTC1051_DLADGTAA.dat 1000 1"
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
/DERIVEDFIELD PLUS_16_CHAMPS "0~~~~~~~~~~~~~~~"
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,TRNCOD_CF
/CONDITION LOB ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "" AND ACMAMT_M !=0 )
/SUMMARIZE TOTAL ACMAMT_M
/OUTFILE ${SORT_O}
/INCLUDE LOB
/REFORMAT FILLER1
         ,ACMCUR_CF
         ,ACMAMT_M
         ,FILLER2
         ,ACMCUR_CF
         ,PLUS_16_CHAMPS
exit
EOF
SORT

#NSTEP=${NJOB}_140
## Begin Merge and Sort [23390] - modif 002 12/06/2012
##-----------------------------------------------------------------------------
#LIBEL="Transforme TRNCOD en Norme EBS : '11xxxxx2' en '1Axxxxx2' "
#AWK_I=${DFILT}/${NJOB}_125_${IB}_SORT_DLADGTAA.dat
#AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLAGTAA.dat
#AWK_CMD=`CFTMP`
#INPUT_TEXT ${AWK_CMD} <<EOF
#BEGIN{ FS="\~"; OFS="\~" }
#	{
#		if ( substr(\$6,2,1)=="1" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
#		if ( substr(\$6,2,1)=="4" ) \$6=substr(\$6,1,1) "E" substr(\$6,3,5) "2";
#		if ( substr(\$6,2,1)=="7" ) \$6=substr(\$6,1,1) "J" substr(\$6,3,5) "2";
#		if ( substr(\$7,2,1)=="2" ) \$7=substr(\$7,1,1) "B" substr(\$7,3,5) "2";
#		if ( substr(\$7,2,1)=="5" ) \$7=substr(\$7,1,1) "G" substr(\$7,3,5) "2";
#		print \$0;
#	}
#exit
#EOF
#AWK
#
NSTEP=${NJOB}_150
#Cancellation of the previous closing period in IGTAa
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the GTAA..."
#PRG=ESTM7601
#FPRM=`CFTMP`
#INPUT_TEXT ${FPRM} << EOF
#CLODAT_D ${ICLODAT_D}
#exit
#EOF
#export ${PRG}_PRM=${FPRM}
#export ${PRG}_I1="${DFILT}/${NJOB}_140_${IB}_AWK_DLAGTAA.dat"
#export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_DLAGTAA.dat"
#EXECPRG
#
AWK_I=${DFILT}/${NJOB}_125_${IB}_SORT_DLADGTAA.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLAGTAA.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { 	if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
					if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
					if ( \$41 != 0 ) \$41 = sprintf("%-.3lf",-\$41);
					if ( substr(\$6,2,1)=="1" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="4" ) \$6=substr(\$6,1,1) "E" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="7" ) \$6=substr(\$6,1,1) "J" substr(\$6,3,5) "2";
					if ( substr(\$7,2,1)=="2" ) \$7=substr(\$7,1,1) "B" substr(\$7,3,5) "2";
					if ( substr(\$7,2,1)=="5" ) \$7=substr(\$7,1,1) "G" substr(\$7,3,5) "2";
					\$41=0;
					\$57 = "EBSGTA";
					print \$0;
       }
exit
EOF
AWK

NSTEP=${NJOB}_160
#-----------------------------------------------------------------------------
# DLAGTAA file suumarize
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
        CUR_CF           18:1 - 18:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:EN,
        SCOENDMTH_NF     16:1 - 16:EN,
        CLM_NF           17:1 - 17:,
        AMT_M            19:1 - 19:EN 15/3,
        RETAMT_M         35:1 - 35:EN 15/3,
        RETINTAMT_M      41:1 - 41:EN 15/3,
        FILLER1           1:1 - 18:,
        FILLER2          20:1 - 34:,
        FILLER3          36:1 - 40:,
        FILLER4          42:1 - 57:
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
      ,TRNCOD_CF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION MONTANT ( AMT_MC !=0 OR RETAMT_MC !=0 )
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
/REFORMAT FILLER1,AMT_MC,FILLER2,RETAMT_MC,FILLER3,RETINTAMT_MC,FILLER4
exit
EOF
SORT

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_DLAGTAA_O.dat    > ${DFILT}/${NJOB}_100_DLAGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_120_${IB}_ESTC1051_DLADGTAA.dat > ${DFILT}/${NJOB}_120_DLDGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_125_${IB}_SORT_DLADGTAA.dat     > ${DFILT}/${NJOB}_125_SORT_DLADGTAA.dat.gz
#gzip -c ${DFILT}/${NJOB}_140_${IB}_AWK_DLAGTAA.dat       > ${DFILT}/${NJOB}_140_DLDGTAA_PNAFARDSI_AA.dat.gz
gzip -c ${DFILT}/${NJOB}_150_${IB}_AWK_DLAGTAA.dat       > ${DFILT}/${NJOB}_150_DLDGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_160_${IB}_SORT_DLAGTAA_O.dat    > ${DFILT}/${NJOB}_160_DLDGTAA.dat.gz

NSTEP=${NJOB}_170
# Double entry transaction code addition in  GT
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

##-----------------------------------------------------------------------------
NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
# GTAR files merge
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of dGTAR files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLSGTAR} 1000 1"
SORT_I2="${EST_DLREGTAR} 1000 1"
SORT_I3="${EST_DLREMAJGTAR} 1000 1"
if [ "${TYPEINV}" = "INV" ]
then
	SORT_I4="${EST_DLAGTAR} 1000 1"
	SORT_I5="${EST_DLRTCGTAR} 1000 1"
	SORT_I6="${EST_DLRTGTAR} 1000 1"
	SORT_I7="${EST_DLRPGTAR} 1000 1"
	SORT_I8="${EST_DLRNPGTAR} 1000 1"
	SORT_I9="${EST_DLRTFGTAR} 1000 1"
	SORT_I10="${EST_IGTAR} 1000 1"
else
	SORT_I4="${EST_CURGTA} 1000 1"
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
/DERIVEDFIELD PLUS_16_CHAMPS "~0~~~~~~~~~~~~~~~"
/DERIVEDFIELD ACCEPT_VIDE 16"~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/CONDITION POSTES  TRNCOD1_CF = "2" AND "1357" NC TRNCOD8_CF 
                   AND ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) AND ( AMT_M !=0 OR RETAMT_M !=0 )
                   AND (
                    ((TRNCOD3_CF = "41000" OR TRNCOD3_CF = "41100" OR TRNCOD3_CF = "41800" OR TRNCOD3_CF = "41900" OR 
                      TRNCOD3_CF = "43000" OR TRNCOD3_CF = "43100" OR TRNCOD3_CF = "43600" OR TRNCOD3_CF = "43700" OR TRNCOD3_CF = "43800" OR TRNCOD3_CF = "43900" ) AND "14A" CT TRNCOD2_CF ) 
                    OR 
                    ((TRNCOD3_CF = "41101" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43701" ) AND "14A" CT TRNCOD2_CF AND TRNCOD8_CF="2") 
                       )
/OUTFILE ${SORT_O}
/INCLUDE POSTES
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW, BALSHRMTH_NF_NEW, BALSHRDAY_NF_NEW, FILLER1,SCOSTRMTH_NF_NEW, SCOSTRMTH_NF_NEW, CLM_NF, CUR_CF, AMT_M,
          FILLER2,SCOSTRMTH_NF_NEW,SCOSTRMTH_NF_NEW,FILLER2a,RETAMT_M,FILLER3,PLUS_16_CHAMPS,ORICOD_LS

exit
EOF
SORT

NSTEP=${NJOB}_220
# Begin programme C
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
#-----------------------------------------------------------------------------
LIBEL="EXCLUSION DES LOB 30 ET 31 et Ajout 16 champs + SUMMARIZE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_220_${IB}_ESTC1051_DLAGTAR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTAR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1           1:1 -  7:
       ,TRNCOD_CF         6:1 -  6:
       ,RETCTR_NF        24:1 - 24:
       ,RETEND_NT        25:1 - 25:
       ,RETSEC_NF        26:1 - 26:EN
       ,RTY_NF           27:1 - 27:
       ,RETUW_NT         28:1 - 28:
       ,FILLER2          29:1 - 33:
       ,RETCUR_CF        34:1 - 34:
       ,RETAMT_M         35:1 - 35:EN 15/3
       ,PLC_NT           36:1 - 36:EN
       ,FILLER3          36:1 - 40:
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
/DERIVEDFIELD PLUS_16_CHAMPS "0~~~~~~~~~~~~~~~"
/DERIVEDFIELD ACCEPT_VIDE 16"~"
/DERIVEDFIELD ZERO "0.000~"  CHAR 6
/KEYS  RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RTY_NF
      ,RETUW_NT
      ,TRNCOD_CF
      ,PLC_NT
      ,ACMCUR_CF
/CONDITION LOB ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "" AND ACMAMT_M !=0 )
/SUMMARIZE TOTAL ACMAMT_M
/OUTFILE ${SORT_O}
/INCLUDE LOB
/REFORMAT FILLER1
         ,ACCEPT_VIDE
         ,RETCTR_NF
         ,RETEND_NT
         ,RETSEC_NF
         ,RTY_NF
         ,RETUW_NT
         ,FILLER2
         ,ACMCUR_CF
         ,ACMAMT_M
         ,FILLER3
         ,PLUS_16_CHAMPS
exit
EOF
SORT

#NSTEP=${NJOB}_240
##-----------------------------------------------------------------------------
#LIBEL="Transforme TRNCOD en Norme EBS : '21xxxxx2' en '2Axxxxx2' "
#AWK_I=${DFILT}/${NJOB}_225_${IB}_SORT_DLAGTAR.dat
#AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLAGTAR.dat
#AWK_CMD=`CFTMP`
#INPUT_TEXT ${AWK_CMD} <<EOF
#BEGIN{ FS="\~"; OFS="\~" }
#	{
#		if ( substr(\$6,2,1)=="1" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
#		if ( substr(\$6,2,1)=="4" ) \$6=substr(\$6,1,1) "E" substr(\$6,3,5) "2";
#		if ( substr(\$6,2,1)=="7" ) \$6=substr(\$6,1,1) "J" substr(\$6,3,5) "2";
#		if ( substr(\$7,2,1)=="2" ) \$7=substr(\$7,1,1) "B" substr(\$7,3,5) "2";
#		if ( substr(\$7,2,1)=="5" ) \$7=substr(\$7,1,1) "G" substr(\$7,3,5) "2";
#		print \$0;
#	}
#exit
#EOF
#AWK
#
NSTEP=${NJOB}_250
#Cancellation of the previous closing period in IGTAR
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closing period in GTAR..."
#PRG=ESTM7601
#FPRM=`CFTMP`
#INPUT_TEXT ${FPRM} << EOF
#CLODAT_D ${ICLODAT_D}
#exit
#EOF
#export ${PRG}_PRM=${FPRM}
#export ${PRG}_I1="${DFILT}/${NJOB}_240_${IB}_AWK_DLAGTAR.dat"
#export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_DLAGTAR.dat"
#EXECPRG
#
#AWK_I=${DFILT}/${NJOB}_240_${IB}_AWK_DLAGTAR.dat
AWK_I=${DFILT}/${NJOB}_225_${IB}_SORT_DLAGTAR.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLAGTAR.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { 	if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
					if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
					if ( \$41 != 0 ) \$41 = sprintf("%-.3lf",-\$41);
					if ( substr(\$6,2,1)=="1" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="4" ) \$6=substr(\$6,1,1) "E" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="7" ) \$6=substr(\$6,1,1) "J" substr(\$6,3,5) "2";
					if ( substr(\$7,2,1)=="2" ) \$7=substr(\$7,1,1) "B" substr(\$7,3,5) "2";
					if ( substr(\$7,2,1)=="5" ) \$7=substr(\$7,1,1) "G" substr(\$7,3,5) "2";
					\$41=0;
					\$57 = "EBSGTA";
					print \$0;
       }
exit
EOF
AWK

NSTEP=${NJOB}_260
#-----------------------------------------------------------------------------
# DLAGTAA file suumarize
#-----------------------------------------------------------------------------
LIBEL="DLAGTAR file suumarize ..."
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
        FILLER4          42:1 - 57:
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
/CONDITION MONTANT ( AMT_MC !=0 OR RETAMT_MC !=0 )
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
gzip -c ${DFILT}/${NJOB}_200_${IB}_SORT_DLAGTAR_O.dat    > ${DFILT}/${NJOB}_200_DLAGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_220_${IB}_ESTC1051_DLAGTAR.dat  > ${DFILT}/${NJOB}_220_DLAGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_225_${IB}_SORT_DLAGTAR.dat      > ${DFILT}/${NJOB}_225_DLAGTAR.dat.gz
#gzip -c ${DFILT}/${NJOB}_240_${IB}_AWK_DLAGTAR.dat       > ${DFILT}/${NJOB}_240_DLAGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_250_${IB}_AWK_DLAGTAR.dat       > ${DFILT}/${NJOB}_250_DLAGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_260_${IB}_SORT_DLAGTAR_O.dat    > ${DFILT}/${NJOB}_260_DLAGTAR.dat.gz

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
	SORT_I4="${EST_CURGTR} 1000 1"
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
        RETSEC_NF        26:1 - 26:,
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
/DERIVEDFIELD PLUS_16_CHAMPS "~0~~~~~~~~~~~~~~~"
/CONDITION TRNCOD2_A TRNCOD2_CF = "A"
/DERIVEDFIELD ORICOD_LS if TRNCOD2_A then "EBSGTA" else "CURGTA"
/CONDITION POSTES  TRNCOD1_CF = "2" AND "1357" NC TRNCOD8_CF 
                   AND ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) AND ( AMT_M !=0 OR RETAMT_M !=0 )
                   AND (
                    ((TRNCOD3_CF = "41000" OR TRNCOD3_CF = "41100" OR TRNCOD3_CF = "41800" OR TRNCOD3_CF = "41900" OR 
                      TRNCOD3_CF = "43000" OR TRNCOD3_CF = "43100" OR TRNCOD3_CF = "43600" OR TRNCOD3_CF = "43700" OR TRNCOD3_CF = "43800" OR TRNCOD3_CF = "43900" ) AND "14A" CT TRNCOD2_CF ) 
                    OR 
                    ((TRNCOD3_CF = "41101" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43701" ) AND "14A" CT TRNCOD2_CF AND TRNCOD8_CF="2") 
                       )
/OUTFILE ${SORT_O}
/INCLUDE POSTES
/REFORMAT SSD_CF,ESB_CF,BALSHEY_NF_NEW, BALSHRMTH_NF_NEW, BALSHRDAY_NF_NEW, FILLER1,SCOSTRMTH_NF_NEW, SCOSTRMTH_NF_NEW, CLM_NF, CUR_CF, AMT_M,
          FILLER2,SCOSTRMTH_NF_NEW,SCOSTRMTH_NF_NEW,FILLER2a,RETAMT_M,FILLER3,PLUS_16_CHAMPS,ORICOD_LS
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
# Begin programme C
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
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : EXCLUSION DES LOB 30 ET 31 et Ajout 16 champs + SUMMARIZE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_320_${IB}_ESTC1051_DLADGTR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLAGTR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1           1:1 -  7:
       ,TRNCOD_CF         6:1 -  6:
       ,RETCTR_NF        24:1 - 24:
       ,RETEND_NT        25:1 - 25:
       ,RETSEC_NF        26:1 - 26:EN
       ,RETUWY_NF        27:1 - 27:
       ,RETUW_NT         28:1 - 28:
       ,FILLER2          29:1 - 33:
       ,RETCUR_CF        34:1 - 34:
       ,RETAMT_M         35:1 - 35:EN 15/3
       ,PLC_NT           36:1 - 36:EN
       ,FILLER3          36:1 - 40:
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
/DERIVEDFIELD PLUS_16_CHAMPS "0~~~~~~~~~~~~~~~"
/DERIVEDFIELD ACCEPT_VIDE 16"~"
/KEYS  RETCTR_NF
      ,RETEND_NT
      ,RETSEC_NF
      ,RETUWY_NF
      ,RETUW_NT
      ,TRNCOD_CF
      ,PLC_NT
      ,ACMCUR_CF
/CONDITION LOB ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "" AND ACMAMT_M !=0)
/SUMMARIZE TOTAL ACMAMT_M
/OUTFILE ${SORT_O}
/INCLUDE LOB
/REFORMAT FILLER1 
         ,ACCEPT_VIDE
         ,RETCTR_NF
         ,RETEND_NT
         ,RETSEC_NF
         ,RETUWY_NF
         ,RETUW_NT
         ,FILLER2
         ,ACMCUR_CF
         ,ACMAMT_M
         ,FILLER3
         ,PLUS_16_CHAMPS
exit
EOF
SORT

#NSTEP=${NJOB}_340
##-----------------------------------------------------------------------------
#LIBEL="Transforme TRNCOD en Norme EBS : '21xxxxx2' en '2Axxxxx2' "
##AWK_I=${DFILT}/${NJOB}_320_${IB}_ESTM7606_DLADGTR.dat
#AWK_I=${DFILT}/${NJOB}_325_${IB}_SORT_DLAGTR.dat
#AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLAGTR.dat
#AWK_CMD=`CFTMP`
#INPUT_TEXT ${AWK_CMD} <<EOF
#BEGIN{ FS="\~"; OFS="\~" }
#	{
#		if ( substr(\$6,2,1)=="1" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
#		if ( substr(\$6,2,1)=="4" ) \$6=substr(\$6,1,1) "E" substr(\$6,3,5) "2";
#		if ( substr(\$6,2,1)=="7" ) \$6=substr(\$6,1,1) "J" substr(\$6,3,5) "2";
#		if ( substr(\$7,2,1)=="2" ) \$7=substr(\$7,1,1) "B" substr(\$7,3,5) "2";
#		if ( substr(\$7,2,1)=="5" ) \$7=substr(\$7,1,1) "G" substr(\$7,3,5) "2";
#		print \$0;
#	}
#exit
#EOF
#AWK
#
NSTEP=${NJOB}_350
#Cancellation of the previous closing period in IGTR
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous closing period in IGTR..."
#PRG=ESTM7601
#FPRM=`CFTMP`
#INPUT_TEXT ${FPRM} << EOF
#CLODAT_D ${ICLODAT_D}
#exit
#EOF
#export ${PRG}_PRM=${FPRM}
#export ${PRG}_I1="${DFILT}/${NJOB}_340_${IB}_AWK_DLAGTR.dat"
#export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_DLAGTR.dat"
#EXECPRG
#
AWK_I=${DFILT}/${NJOB}_325_${IB}_SORT_DLAGTR.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLAGTR.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { 	if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
					if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
					if ( \$41 != 0 ) \$41 = sprintf("%-.3lf",-\$41);
					if ( substr(\$6,2,1)=="1" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="4" ) \$6=substr(\$6,1,1) "E" substr(\$6,3,5) "2";
					if ( substr(\$6,2,1)=="7" ) \$6=substr(\$6,1,1) "J" substr(\$6,3,5) "2";
					if ( substr(\$7,2,1)=="2" ) \$7=substr(\$7,1,1) "B" substr(\$7,3,5) "2";
					if ( substr(\$7,2,1)=="5" ) \$7=substr(\$7,1,1) "G" substr(\$7,3,5) "2";
					\$41=0;
					\$57 = "EBSGTA";
					print \$0;
       }
exit
EOF
AWK

NSTEP=${NJOB}_360
#-----------------------------------------------------------------------------
# DLAGTR file suumarize
#-----------------------------------------------------------------------------
LIBEL="DLAGTR file suumarize ..."
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
        FILLER4          42:1 - 57:
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
/CONDITION MONTANT ( AMT_MC !=0 OR RETAMT_MC !=0 )
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
/REFORMAT FILLER1,AMT_MC,FILLER2,RETAMT_MC,FILLER3,RETINTAMT_MC,FILLER4
exit
EOF
SORT

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_300_${IB}_SORT_DLAGTR_O.dat    > ${DFILT}/${NJOB}_300_DLAGTR.dat.gz
gzip -c ${DFILT}/${NJOB}_320_${IB}_ESTC1051_DLADGTR.dat > ${DFILT}/${NJOB}_320_DLAGTR.dat.gz
gzip -c ${DFILT}/${NJOB}_325_${IB}_SORT_DLAGTR.dat      > ${DFILT}/${NJOB}_325_DLAGTR.dat.gz
#gzip -c ${DFILT}/${NJOB}_340_${IB}_AWK_DLAGTR.dat      > ${DFILT}/${NJOB}_340_DLAGTR.dat.gz
gzip -c ${DFILT}/${NJOB}_350_${IB}_AWK_DLAGTR.dat       > ${DFILT}/${NJOB}_350_DLAGTR.dat.gz
gzip -c ${DFILT}/${NJOB}_360_${IB}_SORT_DLAGTR.dat      > ${DFILT}/${NJOB}_360_DLAGTR.dat.gz

NSTEP=${NJOB}_370
# Double entry transaction code addition in  GT
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition DLAGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_360_${IB}_SORT_DLAGTR.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${EST_DLASIIGTR}
EXECPRG

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_400
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers"
EXECKSH_MODE=P
#EXECKSH "gzip ${EST_XXXXX}"

NSTEP=${NJOB}_450
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND