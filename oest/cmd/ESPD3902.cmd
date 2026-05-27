#!/bin/ksh
#=============================================================================
# nom de l'application       : ESTIMATIONS
#                              Ecritures post omega CONSO ou EBS
# nom du script SHELL        : ESPD3902.cmd
# revision                   : $Revision:   1.3  $
# date de creation           : 20/06/2005
# auteur                     : J. R
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#
# Input files
#       EPO_IADPERICASE	DFILP
#       EPO_DLSGTAASO 	DFILI
#       EPO_FTRSLNK    	DFILP
#       EPO_FCURQUOT   	DFILP
#       EPO_FCPLACC    	DFILP
#       EPO_FDETTRS     DFILP
#       EPO_FCTRSTAT  	DFILP
#       EPO_FSEGSTAT		DFILP
#
# Output files
#       EPO_FCTRSTATSO		DFILI
#       EPO_FSEGSTATSO		DFILI
#
# Launch C program ESP01001 ESTC3606 ESPO1003 ESTC3604 ESTC3605
#
# job launched by ESPD3900.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 31/10/2012 R. Cassis :spot:24041 - Solvency 2
#[002] 26/11/2012 PPEZOUT   :spot:24516 création, ECHANGES INTERNES POST OMEGA
#[003] 04/12/2012 PPEZOUT   :spot:24041 Solvency step 1B,2,3,16 et 20
#[004] 14/11/2013 R. Cassis :spot:25427 - modifs centralization des bases
#[005] 25/11/2014 R. Cassis :spot:27847 - Prise en compte des postes EBS LIFE %[GH]
#[006] 31/03/2016 Florent   :spot:29066 - le GLT fait 71 colonnes, modif step 4
#[007] 06/06/2016 Roger     :spot:30351 - shell non livré dans la spot 29066 + ajout comptage de lignes.
#[008] 05/10/2018 JYP       :IFRS req 10.6 extract new loss ratios types V W X 
#[009] 17/04/2019 R. Cassis :Spira:65656 Normalisation des fichiers pour separation IFRS/EBS
#[010] 03/12/2019 SPIRA 81496: Roger/JYP:  Mise a jour de l'etablissement dans FTECLEDASO sur FTECLEDASO_EBS a partir de Pericase
#[011] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[012] 07/03/2023 : MZM     :. SPIRA 99999 : Fix CNV EU : Generation d'un fichier Vide si EPO_FSEGSTAT et EPO_FCTRSTAT non renseignés
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
OPTION=$1
CRE_D=$2
CONSOYEA=$3
ICLODAT_D=$4
NORME=$5

#[004]
export LIMITINF_D=$((${CRE_D}-50000))
ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`
TRIM_NF=`echo ${ICLODAT_D} | cut -c5-6 | awk '{ if ($0==3) print "1"; if ($0==6) print "2"; if ($0==9) print "3"; if ($0==12) print "4" }'`

#if [ "${NORME}" = "EBS" ]
#then
#  PRS_CF=730
#  EPO_FSEGSTAT=${EPO_FSEGSTATSO}
#  EPO_FCTRSTAT=${EPO_FCTRSTATSO}
#  EPO_FSEGSTATSO=${EPO_FSEGSTATSOSII}
#  EPO_FCTRSTATSO=${EPO_FCTRSTATSOSII}
#  EST_CURGTA=${EPO_FTECLEDASO_EBS}
#  EPO_DLRGTAA=${EPO_DLRGTAASIISO}
#else
#  PRS_CF=710
#  EPO_DLRGTAA=${EPO_DLRGTAASO}
##	EPO_FSEGSTAT=${EPO_FSEGSTAT}
##	EPO_FCTRSTAT=${EPO_FCTRSTAT}
##	EPO_FSEGSTATSO=${EPO_FSEGSTATSO}
##	EPO_FCTRSTATSO=${EPO_FCTRSTATSO}
#fi

#if [ "${EST_ESPD2000_COND3}" = "Y" ]
#then
#	export EST_CURGTA=${DARCH}/`basename ${EST_CURGTA} .dat`_${ICLODAT_A}${ICLODAT_M}.arc
#fi

## 

if [ ! -f ${EPO_FSEGSTAT} ]
then
	touch ${EPO_FSEGSTAT}
fi

if [ ! -f ${EPO_FCTRSTAT} ]
then
	touch ${EPO_FCTRSTAT}
fi

#
ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> CONSOYEA..........: ${CONSOYEA}"
ECHO_LOG "#===> CRE_D.............: ${CRE_D}"
ECHO_LOG "#===> OPTION............: ${OPTION}"
ECHO_LOG "#===> NORME.............: ${NORME}"
ECHO_LOG "#===> PRS_CF............: ${PRS_CF}"
ECHO_LOG "#===> TRIM_NF...........: ${TRIM_NF}"
ECHO_LOG "#===> PO4T..............: ${PO4T}"
ECHO_LOG "#===> ICLODAT_D.........: ${ICLODAT_D}"
ECHO_LOG "#===> EPO_FSEGSTAT......: ${EPO_FSEGSTAT}"
ECHO_LOG "#===> EPO_FCTRSTAT......: ${EPO_FCTRSTAT}"
ECHO_LOG "#===> EPO_FSEGSTATSO....: ${EPO_FSEGSTATSO}"
ECHO_LOG "#===> EPO_FCTRSTATSO....: ${EPO_FCTRSTATSO}"
ECHO_LOG "#===> EST_CURGTA........: ${EST_CURGTA}"
ECHO_LOG "#===> EPO_DLRGTAA.......: ${EPO_DLRGTAA}"
ECHO_LOG "#===> EPO_DLSGTAASIISO..: ${EPO_DLSGTAASIISO}"
ECHO_LOG "#===> EPO_FTECLEDASO_EBS..: ${EPO_FTECLEDASO_EBS}"
ECHO_LOG "#===> EPO_DLDGTAASO.....: ${EPO_DLDGTAASIISO}"
ECHO_LOG "#========================================================================="

#[001]
NSTEP=${NJOB}_01
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Split of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CURGTA} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAASO_01.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF        1:1 -  1:,
        ESB_CF        2:1 -  2:,
        BALSHEY       3:1 -  3:EN,
        BALSHTMTH     4:1 -  4:EN,
        TRNCOD_CF     6:1 -  6:,
        TRNCOD1_CF    6:1 -  6:1,
        TRNCOD2_CF    6:2 -  6:2,
        TRNCOD8_CF    6:8 -  6:8,
        CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION TRNCOD ( TRNCOD1_CF = "1" AND ( BALSHEY = ${ICLODAT_A} AND BALSHTMTH <= ${ICLODAT_M} ) AND "1357" NC TRNCOD8_CF )
/OUTFILE ${SORT_O}
/INCLUDE TRNCOD
exit
EOF
SORT
#AND "AEJ" NC TRNCOD2_CF
NSTEP=${NJOB}_02
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Split of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01_${IB}_SORT_DLSGTAASO_01.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAASO_01.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAASO_02.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF     6:1 -  6:,
        TRNCOD1_CF    6:1 -  6:1,
        TRNCOD8_CF    6:8 -  6:8,
        CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION TRNCOD ( ${TRIM_NF} != 4 OR "246" CT TRNCOD8_CF )
/OUTFILE ${SORT_O}
/INCLUDE TRNCOD
/OUTFILE ${SORT_O2}
/OMIT TRNCOD
exit
EOF
SORT

#[005]
NSTEP=${NJOB}_03
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Split of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLRGTAA} 1000 1"
SORT_I2="${EPO_DLSGTAASIISO} 1000 1"
SORT_I3="${EPO_DLDGTAASIISO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLGTAASO_01.dat  1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF        1:1 -  1:,
        ESB_CF        2:1 -  2:,
        BALSHEY       3:1 -  3:EN,
        BALSHTMTH     4:1 -  4:EN,
        TRNCOD_CF     6:1 -  6:,
        TRNCOD1_CF    6:1 -  6:1,
        TRNCOD2_CF    6:2 -  6:2,
        TRNCOD4_CF    6:3 -  6:6,
        TRNCOD3_CF    6:3 -  6:7,
        TRNCOD8_CF    6:8 -  6:8,
        CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION POSTE (TRNCOD3_CF = "41000" OR TRNCOD3_CF = "41100" OR TRNCOD3_CF = "41101" OR TRNCOD3_CF = "41800" OR TRNCOD3_CF = "41900" OR
                  TRNCOD3_CF = "43000" OR TRNCOD3_CF = "43100" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43600" OR TRNCOD3_CF = "43700" OR
                  TRNCOD3_CF = "43701" OR TRNCOD3_CF = "43800" OR TRNCOD3_CF = "43900" OR
                  TRNCOD4_CF = "4160" AND TRNCOD4_CF = "4161" AND TRNCOD4_CF = "4260" AND TRNCOD4_CF = "4261" AND TRNCOD4_CF = "1007" ) AND
                  ("AEJ" CT TRNCOD2_CF OR "GH" CT TRNCOD8_CF)
/OUTFILE ${SORT_O}
/OMIT POSTE
exit
EOF
SORT

#-----------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_01_${IB}_SORT_DLSGTAASO_01.dat > ${DFILT}/${NJOB}_01_SORT_DLSGTAASO_01.dat.gz
gzip -c ${DFILT}/${NJOB}_02_${IB}_SORT_DLSGTAASO_01.dat > ${DFILT}/${NJOB}_02_SORT_DLSGTAASO_01.dat.gz
gzip -c ${DFILT}/${NJOB}_02_${IB}_SORT_DLSGTAASO_02.dat > ${DFILT}/${NJOB}_02_SORT_DLSGTAASO_02.dat.gz
#-----------------------------------------------------------

#[009]
NSTEP=${NJOB}_04
# exec awk
#-----------------------------------------------------------------------------
LIBEL="Update oricod_ls to EBSGTA for trn EBS"
AWK_I=${DFILT}/${NJOB}_03_${IB}_SORT_DLGTAASO_01.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLDGTAA.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  { post = substr(\$6,2,1);
    if ( post == "A" || post == "B" || post == "D" || post == "E" || post == "G" ||
         post == "H" || post == "J" || post == "K" || post == "L" )
    {
      \$57 = "EBSGTA";
    }
    else
    {
      \$57 = "IFRSGTA";
    }
    print \$0;
  }
exit
EOF
AWK

#[007]
ECHO_LOG "#===> nb lignes ${DFILT}/${NJOB}_04_${IB}_AWK_DLDGTAA.dat"
wc -l ${DFILT}/${NJOB}_04_${IB}_AWK_DLDGTAA.dat

NSTEP=${NJOB}_05
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme IFRS : '1Axxxxx2' en '11xxxxx2' "
AWK_I=${DFILT}/${NJOB}_04_${IB}_AWK_DLDGTAA.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLDGTAA.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
    if ( substr(\$6,1,2)=="1A" ) \$6="11" substr(\$6,3,6);
    if ( substr(\$6,1,2)=="1E" ) \$6="14" substr(\$6,3,6);
    if ( substr(\$6,1,2)=="1J" ) \$6="17" substr(\$6,3,6);
    if ( substr(\$7,1,2)=="1B" ) \$7="12" substr(\$7,3,6);
    if ( substr(\$7,1,2)=="1G" ) \$7="15" substr(\$7,3,6);
    print \$0;
  }
exit
EOF
AWK

#[007]
ECHO_LOG "#===> nb lignes ${DFILT}/${NJOB}_05_${IB}_AWK_DLDGTAA.dat"
wc -l ${DFILT}/${NJOB}_05_${IB}_AWK_DLDGTAA.dat

#-----------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_05_${IB}_AWK_DLDGTAA.dat > ${DFILT}/${NJOB}_05_AWK_DLDGTAA.dat.gz
#-----------------------------------------------------------

NSTEP=${NJOB}_08
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Merge and Sort of GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_AWK_DLDGTAA.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_02_${IB}_SORT_DLSGTAASO_01.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAASO_01.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        FILLER1           2:1 -  5:,
        TRNCOD_CF         6:1 -  6:,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:,
        SEC_NF           10:1 - 10:,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:,
        FILLER2          13:1 - 17:,
        OCCYEA_NF        13:1 - 13:,
        ACY_NF           14:1 - 14:,
        SCOSTRMTH_NF     15:1 - 15:,
        SCOENDMTH_NF     16:1 - 16:,
        CLM_NF           17:1 - 17:,
        CUR_CF           18:1 - 18:,
        AMT_M            19:1 - 19:EN 15/3,
        FIN              20:1 - 56:,
        ORICOD_LS        57:1 - 57:
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
      TRNCOD_CF
/SUMMARIZE  TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
          FILLER1,
          TRNCOD_CF,
          DBLTRNCOD_CF,
          CTR_NF,
          END_NT,
          SEC_NF,
          UWY_NF,
          UW_NT,
          FILLER2,
          CUR_CF,
          AMT_MC,
          FIN,
          ORICOD_LS
exit
EOF
SORT

#[005]
NSTEP=${NJOB}_08B
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Split of TL file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_08_${IB}_SORT_DLSGTAASO_01.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAASO_01.dat  1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF        1:1 -  1:,
        ESB_CF        2:1 -  2:,
        BALSHEY       3:1 -  3:EN,
        BALSHTMTH     4:1 -  4:EN,
        TRNCOD_CF     6:1 -  6:,
        TRNCOD1_CF    6:1 -  6:1,
        TRNCOD2_CF    6:2 -  6:2,
        TRNCOD3_CF    6:3 -  6:7,
        TRNCOD4_CF    6:3 -  6:6,
        TRNCOD8_CF    6:8 -  6:8,
        CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION POSTE (TRNCOD3_CF = "41000" OR TRNCOD3_CF = "41100" OR TRNCOD3_CF = "41101" OR TRNCOD3_CF = "41800" OR TRNCOD3_CF = "41900" OR
                  TRNCOD3_CF = "43000" OR TRNCOD3_CF = "43100" OR TRNCOD3_CF = "43101" OR TRNCOD3_CF = "43600" OR TRNCOD3_CF = "43700" OR
                  TRNCOD3_CF = "43701" OR TRNCOD3_CF = "43800" OR TRNCOD3_CF = "43900" OR
                  TRNCOD4_CF = "4160" AND TRNCOD4_CF = "4161" AND TRNCOD4_CF = "4260" AND TRNCOD4_CF = "4261" AND TRNCOD4_CF = "1007" ) AND
                  ("AEJ" CT TRNCOD2_CF OR "GH" CT TRNCOD8_CF)
/OUTFILE ${SORT_O}
/OMIT POSTE
exit
EOF
SORT

#-----------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_08_${IB}_SORT_DLSGTAASO_01.dat  > ${DFILT}/${NJOB}_08_SORT_DLSGTAASO_01.dat.gz
gzip -c ${DFILT}/${NJOB}_08B_${IB}_SORT_DLSGTAASO_01.dat > ${DFILT}/${NJOB}_08B_SORT_DLSGTAASO_01.dat.gz
#-----------------------------------------------------------

NSTEP=${NJOB}_09
#---------------------------------------------------------------------------
LIBEL="Sort old FCTRSTAT file by KEY and PRS descending"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FCTRSTAT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_OLD_FCTRSTAT.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF   1:1 - 1:,
        END_NT   2:1 - 2:,
        SEC_NF   3:1 - 3:,
        UWY_NF   4:1 - 4:,
        UW_NT    5:1 - 5:,
        PRS_CF 206:1 - 206:
/KEYS CTR_NF,
  END_NT,
  SEC_NF,
  UWY_NF,
  UW_NT,
  PRS_CF DESCENDING
exit
EOF
SORT

NSTEP=${NJOB}_10
# SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Sort old FCTRSTAT file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_09_${IB}_SORT_OLD_FCTRSTAT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_OLD_FCTRSTAT.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF   1:1 - 1:,
        END_NT   2:1 - 2:,
        SEC_NF   3:1 - 3:,
        UWY_NF   4:1 - 4:,
        UW_NT    5:1 - 5:,
        FILLER   1:1 - 205:,
        PRS_CF 206:1 - 206:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD PRS_NEW "${PRS_CF}"
/SUM
/STABLE
/OUTFILE ${SORT_O}
/REFORMAT FILLER, PRS_NEW
exit
EOF
SORT

#-----------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_OLD_FCTRSTAT.dat > ${DFILT}/${NJOB}_10_SORT_OLD_FCTRSTAT.dat.gz
#-----------------------------------------------------------

NSTEP=${NJOB}_15
# Sort old FCTRSTAT file
#------------------------------------------------------------------------------x
LIBEL="Sort old FCTRSTAT file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FCTRSTAT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IFRS_FCTRSTAT.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_EBSINV_FCTRSTAT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF   1:1 - 1:,
        END_NT   2:1 - 2:,
        SEC_NF   3:1 - 3:,
        UWY_NF   4:1 - 4:,
        UW_NT    5:1 - 5:,
        DEBUT    1:1 - 205:,
        PRS_CF 206:1 - 206:
/KEYS CTR_NF,
  END_NT,
  SEC_NF,
  UWY_NF,
  UW_NT
/DERIVEDFIELD PRS_CF_NEW "720"
/CONDITION COND_IFRS (PRS_CF = "710" )
/CONDITION COND_EBS  (PRS_CF = "730" )
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS
/OUTFILE ${SORT_O2}
/INCLUDE COND_EBS
/REFORMAT DEBUT, PRS_CF_NEW
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Introduction of accumulation code, ..."
PRG=ESTC3604
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${CONSOYEA}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EPO_IADPERICASE}
export ${PRG}_I2=${EST_ARCSTATGTA}
export ${PRG}_I3=${DFILT}/${NJOB}_08B_${IB}_SORT_DLSGTAASO_01.dat
export ${PRG}_I4=${EPO_FTRSLNK}
export ${PRG}_I5=${EPO_FCURQUOT}
export ${PRG}_I6=${EPO_FCPLACC}
export ${PRG}_I7=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSTAT_O.dat
EXECPRG

#-----------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_20_${IB}_ESTC3604_FSTAT_O.dat > ${DFILT}/${NJOB}_20_ESTC3604_FSTAT_O.datt.gz
#-----------------------------------------------------------

NSTEP=${NJOB}_25
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount of intermediary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_20_${IB}_ESTC3604_FSTAT_O.dat
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

NSTEP=${NJOB}_30
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of FCTRSTAT file"
PRG=ESTC3605
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_OLD_FCTRSTAT.dat
export ${PRG}_I2=${DFILT}/${NJOB}_25_${IB}_SORT_FSTAT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSTAT_O.dat
EXECPRG


NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL ${DFILT}/${NJOB}_01_${IB}_SORT_DLSGTAASO_01.dat
RMFIL ${DFILT}/${NJOB}_08_${IB}_SORT_DLSGTAASO_01.dat


NSTEP=${NJOB}_40
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount of intermediary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC3605_FSTAT_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_NEW_FCTRSTAT.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF  1:1 -   1:,
        END_NT  2:1 -   2:,
        SEC_NF  3:1 -   3:,
        UWY_NF  4:1 -   4:,
        UW_NT   5:1 -   5:,
        DEBUT   1:1 - 205:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD PRS_CF "${PRS_CF}"
/OUTFILE ${SORT_O}
/REFORMAT DEBUT, PRS_CF
exit
EOF
SORT

# [008]

NSTEP=${NJOB}_50
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="${SORT_I} file sort in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_FSEGEST_SOLVENCYSO}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SEGEST_SOLVENCY_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF    1:1 - 1:EN
       ,SEG_NF    2:1 - 2:
       ,UWY_NF    3:1 - 3:
       ,AMORAT_CT 8:1 - 8:
       ,SEGTYP_CT 9:1 - 9:
/KEYS SSD_CF
     ,SEG_NF
     ,UWY_NF
/CONDITION BOOK ( AMORAT_CT = "R" AND SEGTYP_CT != "V" AND SEGTYP_CT != "W" AND SEGTYP_CT != "X" ) 
/INCLUDE BOOK
exit
EOF
SORT

#[03]
NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="Generation of FCTRSTAT file"
PRG=ESPO1003
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_NEW_FCTRSTAT.dat
export ${PRG}_I2=${DFILT}/${NJOB}_50_${IB}_SORT_SEGEST_SOLVENCY_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_NEW_FCTRSTAT.dat
EXECPRG

NSTEP=${NJOB}_70
# Merge of TL files
#------------------------------------------------------------------------------
LIBEL="Merge of FCTRSTAT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESPO1003_NEW_FCTRSTAT.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_15_${IB}_SORT_IFRS_FCTRSTAT.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_15_${IB}_SORT_EBSINV_FCTRSTAT.dat 2000 1"
SORT_O="${EPO_FCTRSTATSO} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF   1:1 - 1:,
        END_NT   2:1 - 2:,
        SEC_NF   3:1 - 3:,
        UWY_NF   4:1 - 4:,
        UW_NT    5:1 - 5:,
        PRS_CF 206:1 - 206:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      PRS_CF
exit
EOF
SORT

NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
gzip -c ${DFILT}/${NJOB}_30_${IB}_ESTC3605_FSTAT_O.dat      > ${DFILT}/${NJOB}_30_ESTC3605_FSTAT_O.dat.gz
gzip -c ${DFILT}/${NJOB}_10_${IB}_SORT_OLD_FCTRSTAT.dat     > ${DFILT}/${NJOB}_10_SORT_OLD_FCTRSTAT.dat.gz
gzip -c ${DFILT}/${NJOB}_40_${IB}_SORT_NEW_FCTRSTAT.dat     > ${DFILT}/${NJOB}_40_SORT_NEW_FCTRSTAT.dat.gz
gzip -c ${DFILT}/${NJOB}_60_${IB}_ESPO1003_NEW_FCTRSTAT.dat > ${DFILT}/${NJOB}_60_ESPO1003_NEW_FCTRSTAT.dat.gz

RMFIL ${DFILT}/${NJOB}_15_${IB}_ESPO1001_FSTAT_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_OLD_FCTRSTAT.dat
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_NEW_FCTRSTAT.dat

NSTEP=${NJOB}_100
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sort of FCTRSTAT file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESPO1003_NEW_FCTRSTAT.dat 3000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FCTRSTAT_O.dat 3000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS UWY_NF         4:1 -   4:,
        SSD_CF         6:1 -   6:,
        ESB_CF         7:1 -   7:,
        SECACCSTS_CT  39:1 -  39:,
        EGPCUR_CF     62:1 -  62:,
        SEG_NF       101:1 - 101:,
        PRS_CF       206:1 - 206:
/KEYS SSD_CF,
      ESB_CF,
      SEG_NF,
      UWY_NF,
      EGPCUR_CF,
      PRS_CF
/CONDITION CLOSEACC SECACCSTS_CT != "9" AND (PRS_CF = "${PRS_CF}" )
/OUTFILE ${SORT_O}
/INCLUDE CLOSEACC
exit
EOF
SORT

NSTEP=${NJOB}_120
# Begin C Program
#------------------------------------------------------------------------------
LIBEL="Generation of FSEGSTAT file"
PRG=ESTC3606
export ${PRG}_I1=${DFILT}/${NJOB}_100_${IB}_SORT_FCTRSTAT_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSEGSTAT_O.dat
EXECPRG

NSTEP=${NJOB}_140
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Fusionne les fichiers EST_FSEGSTAT_EBS avec EST_FSEGSTAT_IFRS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FSEGSTAT} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IFRS_FSEGSTAT.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_EBSINV_FSEGSTAT.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF     1:1 -   1:,
        ESB_CF     2:1 -   2:,
        SEG_NF     3:1 -   3:,
        UWY_NF     4:1 -   4:,
        EGPCUR_CF  5:1 -   5:,
        DEBUT      1:1 - 105:,
        PRS_CF   106:1 - 106:
/KEYS SSD_CF,
      ESB_CF,
      SEG_NF,
      UWY_NF,
      EGPCUR_CF,
      PRS_CF
/DERIVEDFIELD PRS_CF_NEW "720"
/CONDITION COND_IFRS (PRS_CF = "710" )
/CONDITION COND_EBS  (PRS_CF = "730" )
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS
/REFORMAT DEBUT, PRS_CF
/OUTFILE ${SORT_O2}
/INCLUDE COND_EBS
/REFORMAT DEBUT, PRS_CF_NEW
exit
EOF
SORT

NSTEP=${NJOB}_160
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Fusionne les fichiers EST_FSEGSTAT_EBS avec EST_FSEGSTAT_IFRS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_ESTC3606_FSEGSTAT_O.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_140_${IB}_SORT_IFRS_FSEGSTAT.dat 2000 1"
SORT_I3="${DFILT}/${NJOB}_140_${IB}_SORT_EBSINV_FSEGSTAT.dat 2000 1"
SORT_O="${EPO_FSEGSTATSO} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF     1:1 -   1:,
        ESB_CF     2:1 -   2:,
        SEG_NF     3:1 -   3:,
        UWY_NF     4:1 -   4:,
        EGPCUR_CF  5:1 -   5:,
        PRS_CF   106:1 - 106:
/KEYS SSD_CF,
      ESB_CF,
      SEG_NF,
      UWY_NF,
      EGPCUR_CF,
      PRS_CF
exit
EOF
SORT

#-----------------------------------------------------------
gzip -c ${DFILT}/${NJOB}_120_${IB}_ESTC3606_FSEGSTAT_O.dat  > ${DFILT}/${NJOB}_120_ESTC3606_FSEGSTAT_O.dat.gz
gzip -c ${DFILT}/${NJOB}_140_${IB}_SORT_IFRS_FSEGSTAT.dat   > ${DFILT}/${NJOB}_140_SORT_IFRS_FSEGSTAT.dat.gz
gzip -c ${DFILT}/${NJOB}_140_${IB}_SORT_EBSINV_FSEGSTAT.dat > ${DFILT}/${NJOB}_140_SORT_EBSINV_FSEGSTAT.dat.gz
#-----------------------------------------------------------

NSTEP=${NJOB}_300
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat"

JOBEND
