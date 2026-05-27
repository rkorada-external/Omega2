#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                Inventaire acceptation dommages
# nom du script SHELL          : ESID2003.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 31/05/2012
# auteur                       : CGI puis Roger Cassis
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Non-life acceptance closing period process ( set 10 )
#
# Job launched by ESID2000.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 18/04/2012 Roger Cassis :spot:23802 - Modifications pour Solvency
#[002] 31/07/2012 Lalatiana Rakotozafy  :spot:24041  - Modifications pour Solvency
#[003] 02/08/2012 -=Dch=-  :spot:24041 - Modifs techniques Solvency
#[004] 31/08/2012 R. Cassis meme spot  - Modifs techniques Solvency
#[005] 02/08/2012 -=Dch=-  :spot:24041 - Modifs techniques Solvency Ajout du paramètre ICLODAT_D pour ESTC1054
#                                        Autres modifs
#[006] 25/10/2012 JF VDV : [24041] - Modifications pour Solvency
#[008] 20/01/2013 -=PhP=-   :spot:24698 -   corrections pour la conso
#[009] 13/02/2013 -=PHP=-   :spot:24836  Corrections solvency 2
#[010] 30/09/2015 -=PHP=-   :spot:28941  Corrections postes Solvency créés à tort
#[011] 22/03/2016 Florent   :spot:29066  Formatage du fichier GLT
#[012] 14/04/2016 -=Dch=-   :spot:30465  Ajout pour le ESID8050 (Futures EBS)
#[013] 04/05/2016  SAS      :spot:30534  EBS - Futures Premiums (42511) & Charges(42512)
#[014] 26/05/2016 S.Behague :spot 30583: Spira 41148
#[015] 14/06/2016 S.ASKRI   :spot 30534: Spira 42512 Futures charges
#[016] 21/06/2016 -=Dch=-   :spot:30534  Modification des conditions du step 90
#[017] 07/07/2016 Florent   :spot:30890  EBS - Correction sur le calcul des futures pour traités NP
#[018] 07/04/2016 Florent   :spira:38697 ajustement pour écart entre IFRS et EBS programme ESTC1054
#=============================================================================
#set -x

# ***************************************************************************************
# ***************************************************************************************
#
# PHP rajouter fusion des EBS et IFRS pour fichiers FPRMLOA, FLOARAT et FT
#
# ESPT0000_DLDGTAA_IFRS  EN SORTIE DU ESID2000/ESID2002I   EPO_DLDGTAA taux 'A'
# ESPT0000_DLDGTAA_EBS   EN SORTIE DU ESID2000/ESID2002E
#
# ESPD2000_DLDGTAA_EBS  EN SORTIE DU ESPD2000/ESID2002E    EPO_DLDGTAA_EBSSO
# ESPD2000_DLDGTAA      EN SORTIE DU ESPD2000/ESID2003     EPO_DLDGTAASO
#
# ***************************************************************************************
# ***************************************************************************************

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialization of the Job
JOBINIT

# Parameters
TYPEINV=$1
ICLODAT_D=$2

ICLODAT_A=`echo ${ICLODAT_D} | awk '{print substr($0,1,4)}'`
ICLODAT_M=`echo ${ICLODAT_D} | awk '{print substr($0,5,2)}'`
ICLODAT_J=`echo ${ICLODAT_D} | awk '{print substr($0,7,8)}'`

UWY_MIN=2

MIN_ICLODAT_A=`expr ${ICLODAT_A} - ${UWY_MIN}`


if [ "${TYPEINV}" != "INV" ]
then
  if [ "${TYPEINV}" = "POS" ]
  then
    # en sortie du espd2003
    EST_DLDGTAA_E_TRNCODEBS=${EPO_DLDGTAASO}
    # en sortie du espd2002
    EST_DLDGTAA_CUMULS_COUR=${EPO_DLDGTAA_EBSSO}
    EST_FSEGEST_SOLVENCY=${EPO_FSEGEST_SOLVENCYSO}
    EST_DLDGTAA_CUMULS_PREC=${EPO_FTECLEDASO}
    EST_CURGTA=${EPO_FTECLEDASO}
  else
    # en sortie du espd2003
    EST_DLDGTAA_E_TRNCODEBS=${EPO_DLDGTAACO}
    # en sortie du espd2002
    EST_DLDGTAA_CUMULS_COUR=${EPO_DLDGTAA_EBSCO}
    EST_FSEGEST_SOLVENCY=${EPO_FSEGEST_SOLVENCYCO}
    EST_DLDGTAA_CUMULS_PREC=${EPO_FTECLEDASIISO}
    EST_CURGTA=${EPO_FTECLEDASIISO}
  fi
  EST_FCLIENT=${EPO_FCLIENT}
  EST_FCTRGRO=${EPO_FCTRGRO}
  EST_IADPERICASE=${EPO_IADPERICASE}
  EST_DLGTAAPNAE=${EPO_DLGTAAPNAE}
  EST_DLGTAAPRE=${EPO_DLGTAAPRE}
  EST_FDETTRS=${EPO_FDETTRS}
  EST_FTRSLNK=${EPO_FTRSLNK}
  EST_FBOPRSLNK=${EPO_FBOPRSLNK}
  EST_FCURQUOT=${EPO_FCURQUOT}
  EST_FCPLACC=${EPO_FCPLACC}
  EST_FUTURE_EBS=${EPO_FUTURE_EBS}
else
  # en sortie du espd2002
  EST_DLDGTAA_CUMULS_PREC=${EST_DLDGTAA_IFRS}
  EST_DLDGTAA_CUMULS_COUR=${EST_DLDGTAA_EBS}
  # en sortie du espd2003
  EST_DLDGTAA_E_TRNCODEBS=${EST_DLDGTAA_E_TRNCODEBS}
  EST_FUTURE_EBS=${EST_FUTURE_EBS}
fi

if [ "${TYPEINV}" = "POC" ]
then
  NSTEP=${NJOB}_00
  # ajout du delta ${EPO_FTECLEDASIISO} a ${EPO_FTECLEDASO} pour constituer les cumuls precedents
  #------------------------------------------------------------------------------
  LIBEL="cat ${EPO_FTECLEDASO} ${EPO_FTECLEDASIISO} > ${DFILT}/${NSTEP}_${IB}_FTECLEDASIISO.dat"
  EXECKSH_MODE=P
  EXECKSH "cat ${EPO_FTECLEDASO} ${EPO_FTECLEDASIISO} > ${DFILT}/${NSTEP}_${IB}_FTECLEDASIISO.dat"
  EST_DLDGTAA_CUMULS_PREC=${DFILT}/${NSTEP}_${IB}_FTECLEDASIISO.dat
  gzip -c ${DFILT}/${NSTEP}_${IB}_FTECLEDASIISO.dat > ${DFILT}/${NJOB}_000_FTECLEDASIISO.dat.gz
fi

if [ "${TYPEINV}" != "INV" ]
then
  NSTEP=${NJOB}_00${TYPEINV}
  #------------------------------------------------------------------------------
  LIBEL="Format GLT for EST_DLDGTAA_CUMULS_PREC ${EST_DLDGTAA_CUMULS_PREC}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_DLDGTAA_CUMULS_PREC} 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_CUMULS_PREC_O.dat 1000 1"
  INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
  DEBUT         1:1 -  40:,
  RETINTAMT_M  88:1 -  88:,
  FIN         103:1 - 118:
/COPY
/REFORMAT
  DEBUT,RETINTAMT_M,FIN
exit
EOF
SORT

  EST_DLDGTAA_CUMULS_PREC=${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_CUMULS_PREC_O.dat
fi

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> EST_DLDGTAA_E_TRNCODEBS....: ${EST_DLDGTAA_E_TRNCODEBS}"
ECHO_LOG "#===> EST_DLDGTAA_CUMULS_COUR....: ${EST_DLDGTAA_CUMULS_COUR}"
ECHO_LOG "#===> EST_DLDGTAA_CUMULS_PREC....: ${EST_DLDGTAA_CUMULS_PREC}"
ECHO_LOG "#===> EST_DLGTAAPNAE.............: ${EST_DLGTAAPNAE}"
ECHO_LOG "#===> EST_DLGTAAPRE..............: ${EST_DLGTAAPRE}"
ECHO_LOG "#===> EST_IADPERICASE............: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_FSEGEST_SOLVENCY.......: ${EST_FSEGEST_SOLVENCY}"
ECHO_LOG "#===> EST_FDETTRS................: ${EST_FDETTRS}"
ECHO_LOG "#===> EST_FTRSLNK................: ${EST_FTRSLNK}"
ECHO_LOG "#===> EST_FBOPRSLNK..............: ${EST_FBOPRSLNK}"
ECHO_LOG "#===> EST_FCURQUOT...............: ${EST_FCURQUOT}"
ECHO_LOG "#===> EST_CURGTA.................: ${EST_CURGTA}"
ECHO_LOG "#===> EST_FCLIENT................: ${EST_FCLIENT}"
ECHO_LOG "#===> ICLODAT_A..................: ${ICLODAT_A}"
ECHO_LOG "#===> ICLODAT_M..................: ${ICLODAT_M}"
ECHO_LOG "#===> ICLODAT_J..................: ${ICLODAT_J}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_01
#-----------------------------------------------------------------------------
# GTAa REJET DES DSI/BDT
#-----------------------------------------------------------------------------
LIBEL="SELECTION OF PREVIOUS EBS from EST_DLDGTAA_CUMULS_PREC ...include mvt <= bilan, accept EBS from ${EST_DLDGTAA_CUMULS_PREC} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA_CUMULS_PREC} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLA_DSI_GTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:EN,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:6,
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
        RETINTAMT_M      41:1 - 41:EN 15/3
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD1_CF,
      TRNCOD3_CF,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CLM_NF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/CONDITION COND_TRNCOD ( BALSHEY_NF = ${ICLODAT_A} AND BALSHRMTH_NF <= ${ICLODAT_M} ) AND ("AEJ" CT TRNCOD2_CF AND TRNCOD1_CF = "1") AND
                       ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" )
/OUTFILE ${SORT_O}
/INCLUDE COND_TRNCOD
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_01_${IB}_SORT_DLA_DSI_GTAA_O.dat > ${DFILT}/${NJOB}_001_SORT_DLA_DSI_GTAA_O.dat.gz

NSTEP=${NJOB}_03
#-----------------------------------------------------------------------------
LIBEL="Current cancellation of the previous EBS from the same closing period in IGTAa..."
AWK_I=${DFILT}/${NJOB}_01_${IB}_SORT_DLA_DSI_GTAA_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLAGTAA_EBS.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       {  if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
          if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
          if ( substr(\$6,2,1)=="1" ) \$6=substr(\$6,1,1) "A" substr(\$6,3,6);
          if ( substr(\$6,2,1)=="4" ) \$6=substr(\$6,1,1) "E" substr(\$6,3,6);
          if ( substr(\$6,2,1)=="7" ) \$6=substr(\$6,1,1) "J" substr(\$6,3,6);
          if ( substr(\$7,2,1)=="2" ) \$7=substr(\$7,1,1) "B" substr(\$7,3,6);
          if ( substr(\$7,2,1)=="5" ) \$7=substr(\$7,1,1) "G" substr(\$7,3,6);
          \$5="02";
          \$41=0;
          print \$0
       }
exit
EOF
AWK

#[002] ajout de SORT_I3
#[003]
#[004]
NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Filling segmentation perimeters in IADPERICASE ..."
PRG=ESTM1004
export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_I2=${EST_FCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FCTRGRO1.dat  # plus utilise
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_PERIANO.dat   # plus utilise
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE.dat
EXECPRG

NSTEP=${NJOB}_20
# MOD003 -  Sort of IRDPERICASE
#-----------------------------------------------------------------------------
LIBEL="Sort of IADPERICASE + on Omet les mouvements de retro interne du Pericase"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTM1004_IADPERICASE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF      3:1 -  3:,
        END_NT      4:1 -  4:EN,
        SEC_NF      5:1 -  5:EN,
        UWY_NF      6:1 -  6:,
        UW_NT       7:1 -  7:EN,
        CTRRET_B   20:1 - 20:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/CONDITION RETINT CTRRET_B = "0"
/INCLUDE RETINT
exit
EOF
SORT

NSTEP=${NJOB}_25
#-----------------------------------------------------------------------------
LIBEL="CUMULS_PREC selection of accept and balshey "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA_CUMULS_PREC} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_PREC_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD2_CF        6:2 -  6:2,
        TRNCOD3_CF        6:3 -  6:8,
        TRNCOD4_CF        6:1 -  6:4,
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
        FILLER1           1:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD_CF,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CLM_NF
/CONDITION POSTES ( TRNCOD1_CF = "1" AND "1A" CT TRNCOD2_CF AND BALSHEY_NF = "${ICLODAT_A}" AND (TRNCOD4_CF !="1A41" AND TRNCOD4_CF !="1A43") )
/OUTFILE ${SORT_O}
/INCLUDE POSTES
/REFORMAT FILLER1
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_25_${IB}_SORT_DLDGTAA_PREC_O.dat     > ${DFILT}/${NJOB}_025_SORT_DLDGTAA_PREC_O.dat.gz

NSTEP=${NJOB}_28
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1Axxxxx2' en '11xxxxx2' "
AWK_I=${DFILT}/${NJOB}_25_${IB}_SORT_DLDGTAA_PREC_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLDGTAA_PREC_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
    if (\$6 != "1A100012" && \$6 != "1A494302" && \$6 != "1A120012") {
      if ( substr(\$6,2,1)=="A" ) \$6=substr(\$6,1,1) "1" substr(\$6,3,6);
      if ( substr(\$6,2,1)=="E" ) \$6=substr(\$6,1,1) "4" substr(\$6,3,6);
      if ( substr(\$6,2,1)=="J" ) \$6=substr(\$6,1,1) "7" substr(\$6,3,6);
    }
    print \$0;
  }
exit
EOF
AWK

#[23390] - modif 002 12/06/2012
#[010] correction pour enlever les dates des montants de retro interne
NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="Sort AND summarize of PREVIOUS files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_28_${IB}_AWK_DLDGTAA_PREC_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_PREC_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD3_CF        6:3 -  6:8,
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
        FIN              42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD_CF,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CLM_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD PLUS_30_CHAMPS 29"~"
/DERIVEDFIELD CHAMPS_ZERO "0~"
/CONDITION MONTANT ( AMT_MC !=0 )
/OUTFILE ${SORT_O}
/INCLUDE MONTANT
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
          CHAMPS_ZERO,
          PLUS_30_CHAMPS
exit
EOF
SORT


NSTEP=${NJOB}_40
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Sort and summarize current PLAS file ${EST_DLDGTAA_CUMULS_COUR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDGTAA_CUMULS_COUR} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_COUR.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD3_CF        6:3 -  6:8,
        TRNCOD4_CF        6:1 -  6:4,
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
        CED_NF           20:1 - 20:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD_CF,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CLM_NF
/SUMMARIZE  TOTAL AMT_M
/CONDITION POSTES ( TRNCOD1_CF = "1" AND BALSHEY_NF = "${ICLODAT_A}" AND (TRNCOD4_CF !="1A41" AND TRNCOD4_CF !="1A43") )
/OUTFILE ${SORT_O}
/INCLUDE POSTES
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_40_${IB}_SORT_DLDGTAA_COUR.dat    > ${DFILT}/${NJOB}_040_DLDGTAA_COUR.dat.gz

NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="PLAS :  Create Ecart Data for CURRENT (EBS) - PREVIOUS (IFRS) file"
PRG=ESTC1054
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
ACCRET_CT A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_DLDGTAA_COUR.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_DLDGTAA_PREC_O.dat
export ${PRG}_I3=${EST_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAA_E.dat   # oricod EBSGTA postes transformés
EXECPRG

gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC1054_DLDGTAA_E.dat    > ${DFILT}/${NJOB}_050_ESTC1054_DLDGTAA_DELTA.dat.gz

#-----------------------------------------------------------------------------
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
NSTEP=${NJOB}_60
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : Selection of movements ('1' CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND '13579' NC TRNCOD8_CF ) "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
if [ "${TYPEINV}" != "INV" ]
then
  SORT_I="${EST_DLDGTAA_CUMULS_PREC} 1000 1"
else
  SORT_I="${EST_CURGTA} 1000 1"
  SORT_I2="${EST_MVTPNAC} 1000 1"
  SORT_I3="${EST_DLGTAAPNAE} 1000 1"
  SORT_I4="${EST_DLGTAAPRE} 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        ESB_CF           2:1 -  2:EN,
        BALSHEY_NF       3:1 -  3:EN,
        BALSHRMTH_NF     4:1 -  4:,
        BALSHRDAY_NF     5:1 -  5:,
        TRNCOD_CF        6:1 -  6:,
        TRNCOD1_CF       6:1 -  6:1,
        TRNCOD2_CF       6:2 -  6:2,
        TRNCOD4_CF       6:1 -  6:4,
        TRNCOD8_CF       6:8 -  6:8,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:EN,
        SEC_NF          10:1 - 10:EN,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:EN,
        AMT_M           19:1 - 19:EN 15/3,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:EN,
        RETSEC_NF       26:1 - 26:EN,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:EN,
        RETAMT_M        35:1 - 35:EN 15/3,
        FILLER          1:1 - 41:
/KEYS   CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
/CONDITION ACCEPT ("1" CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND "13579" NC TRNCOD8_CF AND (TRNCOD4_CF !="1A41" AND TRNCOD4_CF !="1A43") )
/OUTFILE ${SORT_O}
/INCLUDE ACCEPT
/REFORMAT FILLER
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_60_${IB}_SORT_DLDGTAA.dat > ${DFILT}/${NJOB}_060_SORT_DLDGTAA.dat.gz

NSTEP=${NJOB}_70
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1Axxxxx2' en '11xxxxx2' "
AWK_I=${DFILT}/${NJOB}_60_${IB}_SORT_DLDGTAA.dat
AWK_O=${DFILT}/${NJOB}_70_${IB}_SORT_DLDGTAA.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {
    if ( substr(\$6,2,1)=="A" ) \$6=substr(\$6,1,1) "1" substr(\$6,3,6);
    if ( substr(\$6,2,1)=="E" ) \$6=substr(\$6,1,1) "4" substr(\$6,3,6);
    if ( substr(\$6,2,1)=="J" ) \$6=substr(\$6,1,1) "7" substr(\$6,3,6);
    print \$0;
  }
exit
EOF
AWK

NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : AJOUT CODE REGROUPEMENT + LOB + CONVERSION DES MONTANTS DANS DEVISE ALIMENT "
PRG=ESTC1051
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ACCRET_CT A
BALSHTYEA_NF ${ICLODAT_A}
PRS_CF 713
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_IADPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_70_${IB}_SORT_DLDGTAA.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAA.dat
EXECPRG

NSTEP=${NJOB}_90
#[012]
#[015]
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : EXCLUSION DES LOB 30 ET 31 et Ajout 16 champs ET AUTRES POSTES DIFFERENTS DE PRM PNA CHARGES"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTC1051_DLDGTAA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_OMIT.dat 1000 1"
SORT_O3="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_EBSACC.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN
       ,ESB_CF            2:1 -  2:EN
       ,BALSHEY_NF        3:1 -  3:EN
       ,BALSHRMTH_NF      4:1 -  4:EN
       ,BALSHRDAY_NF      5:1 -  5:
       ,TRNCOD_CF         6:1 -  6:
       ,TRNCOD1_CF        6:1 -  6:1
       ,TRNCOD2_CF        6:2 -  6:2
       ,TRNCOD8_CF        6:8 -  6:8
       ,DBLTRNCOD_CF      7:1 -  7:
       ,CTR_NF            8:1 -  8:
       ,END_NT            9:1 -  9:EN
       ,SEC_NF           10:1 - 10:EN
       ,UWY_NF           11:1 - 11:EN
       ,UW_NT            12:1 - 12:EN
       ,OCCYEA_NF        13:1 - 13:
       ,ACY_NF           14:1 - 14:
       ,SCOSTRMTH_NF     15:1 - 15:EN
       ,SCOENDMTH_NF     16:1 - 16:EN
       ,CLM_NF           17:1 - 17:
       ,FILLER1           1:1 - 17:
       ,CUR_CF           18:1 - 18:
       ,AMT_M            19:1 - 19:EN 15/3
       ,FILLER2          20:1 - 33:
       ,RETCUR_CF        34:1 - 34:
       ,RETAMT_M         35:1 - 35:EN 15/3
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
/DERIVEDFIELD PLUS_16_CHAMPS 15"~"
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/DERIVEDFIELD PLUS_30_CHAMPS 30"~"
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
/CONDITION LOB  ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "" ) AND "1" CT TRNCOD1_CF AND BALSHEY_NF = ${ICLODAT_A} AND
                ( ACMTRS_NT='10000' OR ACMTRS_NT='10010' OR ACMTRS_NT='10020' OR ACMTRS_NT='10030' OR ACMTRS_NT='10100' OR ACMTRS_NT='10400' OR ACMTRS_NT='22000' OR ACMTRS_NT ='23000') AND
                ( ( TRNCOD8_CF="0" AND ("${TYPEINV}" = "INV" OR "${ICLODAT_M}" != "12") ) OR TRNCOD8_CF !="0" ) AND ACMAMT_M !=0
/CONDITION ESTM ( LOB_CF != "30" AND LOB_CF != "31" AND LOB_CF != "" ) AND (
				("1" CT TRNCOD1_CF AND BALSHEY_NF = ${ICLODAT_A} AND ( ACMTRS_NT='10000' OR ACMTRS_NT='10030' ) AND 
				( "246" CT TRNCOD8_CF OR TRNCOD_CF="11410000" ) AND ACMAMT_M !=0 ) OR  (NAT_CF = "N" and UWY_NF > ${MIN_ICLODAT_A} ))   
/CONDITION PREMIUM (ACMTRS_NT='10000') 
/CONDITION PREMPTF (ACMTRS_NT= '10010' OR ACMTRS_NT= '10020')
/CONDITION PNA     (ACMTRS_NT='10030')
/CONDITION CHARGES (ACMTRS_NT='10100' OR ACMTRS_NT='10400' OR ACMTRS_NT='22000' OR ACMTRS_NT ='23000')
/DERIVEDFIELD RETACMAMT_M if PNA then ACMAMT_M else 0
/DERIVEDFIELD ORICOD_LS "EBSACC"
/DERIVEDFIELD ORICOD_LS2 "EBSPRM"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD TRNCOD_CF_NEW if PREMIUM then "1A110002~" else if PREMPTF then "1A110003~" else if PNA then "1A100002~" else if CHARGES then "1A120002~" else "1A130002~"
/DERIVEDFIELD STRVIDE "~"
/SUMMARIZE TOTAL ACMAMT_M
/OUTFILE ${SORT_O}
/INCLUDE LOB
/REFORMAT SSD_CF
         ,ESB_CF
         ,BALSHEY_NF
         ,BALSHRMTH_NF_NEW
         ,BALSHRDAY_NF_NEW
         ,TRNCOD_CF
         ,DBLTRNCOD_CF
         ,CTR_NF
         ,END_NT
         ,SEC_NF
         ,UWY_NF
         ,UW_NT
         ,OCCYEA_NF
         ,ACY_NF
         ,SCOSTRMTH_NF
         ,SCOENDMTH_NF
         ,CLM_NF
         ,ACMCUR_CF
         ,ACMAMT_M
         ,FILLER2
         ,STRVIDE
         ,STRVIDE
         ,FILLER3
         ,STRVIDE
         ,PLUS_16_CHAMPS
         ,ORICOD_LS2
         ,PLUS_14_CHAMPS
         ,BALSHEY_NF_NEW
         ,BALSHRMTH_NF_NEW
         ,BALSHRDAY_NF_NEW
         ,TRNCOD_CF_NEW
         ,ACMTRS_NT
/OUTFILE ${SORT_O2}
/OMIT LOB
/OUTFILE ${SORT_O3}
/INCLUDE ESTM
/REFORMAT FILLER1
         ,ACMCUR_CF
         ,ACMAMT_M
         ,FILLER2
         ,ACMCUR_CF
         ,RETACMAMT_M
         ,FILLER3
         ,STRVIDE
         ,PLUS_30_CHAMPS
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_80_${IB}_ESTC1051_DLDGTAA.dat    > ${DFILT}/${NJOB}_080_SORT_DLGTAAPREPNAE_O.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_SORT_DLDGTAA.dat        > ${DFILT}/${NJOB}_090_SORT_DLGTAAPREPNAE_O.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_SORT_DLDGTAA_OMIT.dat   > ${DFILT}/${NJOB}_090_SORT_DLGTAAPREPNAE_OMIT.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_SORT_DLDGTAA_EBSACC.dat > ${DFILT}/${NJOB}_090_SORT_DLGTAAPREPNAE_EBSACC.dat.gz


NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : creation d une ligne temoin par contrat / sec/uwy avec ORICOD = EBSACC "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_SORT_DLDGTAA_EBSACC.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_EBSACC.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN
       ,ESB_CF           2:1 -  2:EN
       ,BALSHEY_NF       3:1 -  3:
       ,BALSHRMTH_NF     4:1 -  4:EN
       ,BALSHRDAY_NF     5:1 -  5:EN
       ,TRNCOD_CF        6:1 -  6:
       ,DBLTRNCOD_CF     7:1 -  7:
       ,CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:EN
       ,SEC_NF          10:1 - 10:EN
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:EN
       ,OCCYEA_NF       13:1 - 13:
       ,ACY_NF          14:1 - 14:
       ,SCOSTRMTH_NF    15:1 - 15:EN
       ,SCOENDMTH_NF    16:1 - 16:EN
       ,CLM_NF          17:1 - 17:
       ,CUR_CF          18:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,CED_NF          20:1 - 20:
       ,BRK_NF          21:1 - 21:
       ,PAY_NF          22:1 - 22:
       ,KEY_NF          23:1 - 23:
       ,RETCTR_NF       24:1 - 24:
       ,RETEND_NT       25:1 - 25:EN
       ,RETSEC_NF       26:1 - 26:EN
       ,RTY_NF          27:1 - 27:
       ,RETUW_NT        28:1 - 28:EN
       ,RETOCCYEA_NF    29:1 - 29:
       ,RETACY_NF       30:1 - 30:
       ,RETSCOSTRMTH_NF 31:1 - 31:EN
       ,RETSCOENDMTH_NF 32:1 - 32:EN
       ,RCL_NF          33:1 - 33:
       ,RETCUR_CF       34:1 - 34:
       ,RETAMT_M        35:1 - 35:EN 15/3
       ,PLC_NT          36:1 - 36:
       ,RTO_NF          37:1 - 37:
       ,INT_NF          38:1 - 38:
       ,RETPAY_NF       39:1 - 39:
       ,RETKEY_CF       40:1 - 40:
       ,RETINTAMT_M     41:1 - 41:EN 15/3
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M
/DERIVEDFIELD AJOUT15COL 15"~"
/DERIVEDFIELD ORICOD_LS "EBSACC"
/DERIVEDFIELD AJOUT14COL 14"~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
/OUTFILE ${SORT_O}
/REFORMAT
   SSD_CF
  ,ESB_CF
  ,BALSHEY_NF
  ,BALSHRMTH_NF
  ,BALSHRDAY_NF
  ,TRNCOD_CF
  ,DBLTRNCOD_CF
  ,CTR_NF
  ,END_NT
  ,SEC_NF
  ,UWY_NF
  ,UW_NT
  ,OCCYEA_NF
  ,ACY_NF
  ,SCOSTRMTH_NF
  ,SCOENDMTH_NF
  ,CLM_NF
  ,CUR_CF
  ,AMT_MC
  ,CED_NF
  ,BRK_NF
  ,PAY_NF
  ,KEY_NF
  ,RETCTR_NF
  ,RETEND_NT
  ,RETSEC_NF
  ,RTY_NF
  ,RETUW_NT
  ,RETOCCYEA_NF
  ,RETACY_NF
  ,RETSCOSTRMTH_NF
  ,RETSCOENDMTH_NF
  ,RCL_NF
  ,RETCUR_CF
  ,RETAMT_MC
  ,PLC_NT
  ,RTO_NF
  ,INT_NF
  ,RETPAY_NF
  ,RETKEY_CF
  ,RETINTAMT_M
  ,AJOUT15COL
  ,ORICOD_LS
  ,AJOUT14COL
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_DLDGTAA_EBSACC.dat     > ${DFILT}/${NJOB}_100_SORT_DLDGTAA_EBSACC.dat.gz

#[010] filtrer également les lignes où tous les montants sont à zero
NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : creation DU FICHIER DES ECRITURES INPUT "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90_${IB}_SORT_DLDGTAA.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_50_${IB}_ESTC1054_DLDGTAA_E.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLGTAAPREPNAE.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN
       ,ESB_CF           2:1 -  2:EN
       ,BALSHEY_NF       3:1 -  3:EN
       ,BALSHRMTH_NF     4:1 -  4:
       ,BALSHRDAY_NF     5:1 -  5:
       ,TRNCOD_CF        6:1 -  6:
       ,TRNCOD1_CF       6:1 -  6:1
       ,TRNCOD3_CF       6:3 -  6:7
       ,TRNCOD8_CF       6:8 -  6:8
       ,DBLTRNCOD_CF     7:1 -  7:
       ,CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:
       ,SEC_NF          10:1 - 10:
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:
       ,OCCYEA_NF       13:1 - 13:
       ,ACY_NF          14:1 - 14:
       ,SCOSTRMTH_NF    15:1 - 15:EN
       ,SCOENDMTH_NF    16:1 - 16:EN
       ,CLM_NF          17:1 - 17:
       ,CUR_CF          18:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,CED_NF          20:1 - 20:
       ,BRK_NF          21:1 - 21:
       ,PAY_NF          22:1 - 22:
       ,KEY_NF          23:1 - 23:
       ,RETCTR_NF       24:1 - 24:
       ,RETEND_NT       25:1 - 25:EN
       ,RETSEC_NF       26:1 - 26:EN
       ,RTY_NF          27:1 - 27:
       ,RETUW_NT        28:1 - 28:EN
       ,RETOCCYEA_NF    29:1 - 29:
       ,RETACY_NF       30:1 - 30:
       ,RETSCOSTRMTH_NF 31:1 - 31:EN
       ,RETSCOENDMTH_NF 32:1 - 32:EN
       ,RCL_NF          33:1 - 33:
       ,RETCUR_CF       34:1 - 34:
       ,RETAMT_M        35:1 - 35:EN 15/3
       ,PLC_NT          36:1 - 36:
       ,RTO_NF          37:1 - 37:
       ,INT_NF          38:1 - 38:
       ,RETPAY_NF       39:1 - 39:
       ,RETKEY_CF       40:1 - 40:
       ,RETINTAMT_M     41:1 - 41:EN 15/3
/CONDITION ACCEPT0 ("1" CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND "1357" NC TRNCOD8_CF )
/CONDITION ACCEPT  "1" CT TRNCOD1_CF AND BALSHEY_NF <= ${ICLODAT_A} AND "1357" NC TRNCOD8_CF AND ( ( TRNCOD8_CF="0" AND ("${TYPEINV}" = "INV" OR "${ICLODAT_M}" != "12") ) OR TRNCOD8_CF !="0" )
                   and (AMT_M!=0 OR RETAMT_M!=0 OR RETINTAMT_M  !=0)
/CONDITION BILANCOUR (BALSHEY_NF=${ICLODAT_A})
/DERIVEDFIELD BALSMTH_NF2 if BILANCOUR then BALSHRMTH_NF else "12"
/DERIVEDFIELD BALSDAY_NF2 if BILANCOUR then BALSHRDAY_NF else "28"
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD AMT_M_NEW AMT_M COMPRESS
/DERIVEDFIELD AJOUT15COL 15"~"
/DERIVEDFIELD ORICOD_LS "EBSPRM~"
/DERIVEDFIELD AJOUT14COL 14"~"
/DERIVEDFIELD STRVIDE "~"
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,ACY_NF
      ,SCOENDMTH_NF
      ,SCOSTRMTH_NF
      ,OCCYEA_NF
      ,CLM_NF
      ,CUR_CF
      ,TRNCOD_CF
      ,BALSHEY_NF
      ,BALSMTH_NF2
      ,BALSDAY_NF2
/SUMMARIZE TOTAL AMT_M
/OUTFILE ${SORT_O}
/INCLUDE ACCEPT
/REFORMAT
   SSD_CF
  ,ESB_CF
  ,BALSHEY_NF
  ,BALSMTH_NF2
  ,BALSDAY_NF2
  ,TRNCOD_CF
  ,DBLTRNCOD_CF
  ,CTR_NF
  ,END_NT
  ,SEC_NF
  ,UWY_NF
  ,UW_NT
  ,OCCYEA_NF
  ,ACY_NF
  ,SCOSTRMTH_NF
  ,SCOENDMTH_NF
  ,CLM_NF
  ,CUR_CF
  ,AMT_M_NEW
  ,CED_NF
  ,BRK_NF
  ,PAY_NF
  ,KEY_NF
  ,RETCTR_NF
  ,RETEND_NT
  ,RETSEC_NF
  ,RTY_NF
  ,RETUW_NT
  ,RETOCCYEA_NF
  ,RETACY_NF
  ,RETSCOSTRMTH_NF
  ,RETSCOENDMTH_NF
  ,RCL_NF
  ,RETCUR_CF
  ,RETAMT_M
  ,PLC_NT
  ,RTO_NF
  ,INT_NF
  ,RETPAY_NF
  ,RETKEY_CF
  ,RETINTAMT_M
  ,AJOUT15COL
  ,ORICOD_LS
  ,AJOUT14COL
  ,BALSHEY_NF_NEW
  ,BALSHRMTH_NF_NEW
  ,BALSHRDAY_NF_NEW
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_110_${IB}_SORT_DLGTAAPREPNAE.dat     > ${DFILT}/${NJOB}_110_SORT_DLGTAAPREPNAE.dat.gz

NSTEP=${NJOB}_125
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : calculation of fstat avec arcstatgta"
PRG=ESTC3604
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
BALSHTYEA_NF ${ICLODAT_A}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IADPERICASE}
export ${PRG}_I2=${EST_ARCSTATGTA}
export ${PRG}_I3=${DFILT}/${NJOB}_110_${IB}_SORT_DLGTAAPREPNAE.dat
export ${PRG}_I4=${EST_FTRSLNK}
export ${PRG}_I5=${EST_FCURQUOT}
export ${PRG}_I6=${EST_FCPLACC}
export ${PRG}_I7=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FSTAT_O.dat
EXECPRG

gzip -c ${DFILT}/${NJOB}_125_${IB}_ESTC3604_FSTAT_O.dat       > ${DFILT}/${NJOB}_125_SORT_DLCGTAA.dat.gz

NSTEP=${NJOB}_130
#[012]
#[015]
#-----------------------------------------------------------------------------
LIBEL="Accumulation amount of intermediary file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_125_${IB}_ESTC3604_FSTAT_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF         1:1 -  1:,
        END_NT         2:1 -  2:,
        SEC_NF         3:1 -  3:,
        UWY_NF         4:1 -  4:,
        UW_NT          5:1 -  5:,
        ACMTRS_NT      6:1 -  6:,
        COD_CT         7:1 -  7:,
        AMT_M          8:1 -  8:EN 15/3,
        CUR_CF         9:1 -  9:,
        SSD_CF        10:1 - 10:,
        ESB_CF        11:1 - 11:,
        BALSHEY_NF    12:1 - 12:,
        CED_NF        13:1 - 13:,
        BRK_NF        14:1 - 14:,
        PAY_NF        15:1 - 15:,
        KEY_NF        16:1 - 16:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACMTRS_NT
/SUMMARIZE TOTAL AMT_M
/CONDITION PREMIUM (ACMTRS_NT='10000')
/CONDITION PREMPTF (ACMTRS_NT='10010' OR ACMTRS_NT= '10020')
/CONDITION PNA     (ACMTRS_NT='10030')
/CONDITION CHARGES (ACMTRS_NT='10100' OR ACMTRS_NT='10400' OR ACMTRS_NT='22000' OR ACMTRS_NT ='23000')
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD STRVIDE "~"
/DERIVEDFIELD OCCYEA_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD ACY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD SCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD SCOENDMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD FILLER18 18"~"
/DERIVEDFIELD FILLER15 15"~"
/DERIVEDFIELD ORICOD_LS "EBSPRM"
/DERIVEDFIELD AJOUT14COL 14"~"
/DERIVEDFIELD TRNCOD_CF_NEW if PREMIUM then "1A110002~" else if PREMPTF then "1A110003~" else if PNA then "1A100002~" else if CHARGES then "1A120002~" else "1A130002~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/CONDITION ACMTRS_FUTURES (ACMTRS_NT='10000' OR ACMTRS_NT='10010' OR ACMTRS_NT='10020' OR ACMTRS_NT='10030' OR ACMTRS_NT='10100' OR ACMTRS_NT='10400' OR ACMTRS_NT='22000' OR ACMTRS_NT ='23000')
/OUTFILE ${SORT_O}
/INCLUDE ACMTRS_FUTURES
/REFORMAT
   SSD_CF
  ,ESB_CF
  ,BALSHEY_NF_NEW
  ,BALSHRMTH_NF_NEW
  ,BALSHRDAY_NF_NEW
  ,TRNCOD_CF_NEW
  ,STRVIDE
  ,CTR_NF
  ,END_NT
  ,SEC_NF
  ,UWY_NF
  ,UW_NT
  ,OCCYEA_NF_NEW
  ,ACY_NF_NEW
  ,SCOSTRMTH_NF_NEW
  ,SCOENDMTH_NF_NEW
  ,STRVIDE
  ,CUR_CF
  ,AMT_MC
  ,CED_NF
  ,BRK_NF
  ,PAY_NF
  ,KEY_NF
  ,FILLER18
  ,FILLER15
  ,ORICOD_LS
  ,AJOUT14COL
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_130_${IB}_SORT_DLDGTAA.dat           > ${DFILT}/${NJOB}_130_SORT_DLCGTAA.dat.gz

NSTEP=${NJOB}_150
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : Fusion des EBSACC et DLDGTAA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_SORT_DLDGTAA_EBSACC.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_130_${IB}_SORT_DLDGTAA.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAA.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:
       ,CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:EN
       ,SEC_NF          10:1 - 10:EN
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:EN
       ,CUR_CF          18:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,ORICOD_LS       57:1 - 57:
       ,FILLER1          1:1 - 18:
       ,FILLER2         20:1 - 71:
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,ORICOD_LS
      ,TRNCOD_CF
      ,CUR_CF
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT FILLER1
         ,AMT_MC
         ,FILLER2
exit
EOF
SORT

NSTEP=${NJOB}_160
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="FUTURES PREPARATION : FSEGEST_SOLVENCY file sort in progress... EST_FSEGEST_SOLVENCY:${EST_FSEGEST_SOLVENCY} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FSEGEST_SOLVENCY}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SEGEST_SOLVENCY_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF    1:1 - 1:EN
       ,SEG_NF    2:1 - 2:
       ,UWY_NF    3:1 - 3:
       ,AMORAT_CT 8:1 - 8:
/KEYS SSD_CF
     ,SEG_NF
     ,UWY_NF
/CONDITION BOOK AMORAT_CT = "R"
/INCLUDE BOOK
exit
EOF
SORT

NSTEP=${NJOB}_170
#------------------------------------------------------------------------------
LIBEL="FUTURES CALCULATIONS :  Calcul of future premium and charges and claim premium..."
PRG=ESTC1064
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
MIN_ICLODAT_A ${MIN_ICLODAT_A}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_IADPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_150_${IB}_SORT_DLGTAA.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${DFILT}/${NJOB}_160_${IB}_SORT_SEGEST_SOLVENCY_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAA.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAA_ANO.log
export ${PRG}_O3=${EST_FUTURE_EBS}
EXECPRG

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC1064 "
ECHO_LOG "#===> Nombre de lignes futures generees "
wc -l ${DFILT}/${NJOB}_170_${IB}_ESTC1064_DLGTAA.dat
ECHO_LOG "#===> Nombre de lignes PLAS generees "
wc -l ${EST_DLDGTAA_CUMULS_COUR}
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_180
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="PLAS + FUTURES :  Merge and Sort of PLAS + FUTURES GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLDGTAA_CUMULS_COUR}
SORT_I2="${DFILT}/${NJOB}_170_${IB}_ESTC1064_DLGTAA.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_NEW_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD3_CF        6:3 -  6:8,
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
        FIN              42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      CUR_CF,
      TRNCOD_CF,
      OCCYEA_NF,
      ACY_NF,
      SCOSTRMTH_NF,
      SCOENDMTH_NF,
      CLM_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
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
          FIN
exit
EOF
SORT

NSTEP=${NJOB}_190
#-----------------------------------------------------------------------------
LIBEL="PLAS + FUTURES :  Create Ecart Data for EBS - IFRS file"
PRG=ESTC1054
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
ACCRET_CT A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_180_${IB}_SORT_DLDGTAA_NEW_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_DLDGTAA_PREC_O.dat
export ${PRG}_I3=${EST_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAA_E.dat   # oricod EBSGTA postes transformés
EXECPRG

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> ESTC1054 "
ECHO_LOG "#===> Nombre de lignes ecart pour le GLT generees "
wc -l ${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAA_E.dat
ECHO_LOG "#===> Nombre de lignes annulation des postes EBS précédents "
wc -l ${DFILT}/${NJOB}_03_${IB}_AWK_DLAGTAA_EBS.dat
ECHO_LOG "#========================================================================="

#gzip -c ${DFILT}/${NJOB}_180_${IB}_SORT_DLDGTAA_NEW_O.dat        > ${DFILT}/${NJOB}_180_SORT_DLDGTAA_NEW_O.dat.gz

NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
LIBEL="PLAS + FUTURES : Creation of DLDGTAA_E file from GTA files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_190_${IB}_ESTC1054_DLDGTAA_E.dat 1000 1"
#annulation des postes EBS précédents
#SORT_I2="${DFILT}/${NJOB}_03_${IB}_AWK_DLAGTAA_EBS.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_E.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF        1:1 -  1:EN
       ,ESB_CF        2:1 -  2:EN
       ,BALSHEY_NF    3:1 -  3:
       ,BALSHRMTH_NF  4:1 -  4:EN
       ,BALSHRDAY_NF  5:1 -  5:EN
       ,TRNCOD_CF     6:1 -  6:
       ,DBLTRNCOD_CF  7:1 -  7:
       ,CTR_NF        8:1 -  8:
       ,END_NT        9:1 -  9:EN
       ,SEC_NF       10:1 - 10:EN
       ,UWY_NF       11:1 - 11:
       ,UW_NT        12:1 - 12:EN
       ,OCCYEA_NF    13:1 - 13:
       ,ACY_NF       14:1 - 14:
       ,SCOSTRMTH_NF 15:1 - 15:EN
       ,SCOENDMTH_NF 16:1 - 16:EN
       ,CLM_NF       17:1 - 17:
       ,CUR_CF       18:1 - 18:
       ,AMT_M        19:1 - 19:EN 15/3
       ,FILLER52     20:1 - 71:
/KEYS  SSD_CF
      ,ESB_CF
      ,BALSHEY_NF
      ,BALSHRMTH_NF
      ,BALSHRDAY_NF
      ,TRNCOD_CF
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,CUR_CF
/SUMMARIZE TOTAL AMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/CONDITION MVTZERO ( AMT_M != 0 )
/OUTFILE ${SORT_O}
/INCLUDE MVTZERO
/REFORMAT
   SSD_CF
  ,ESB_CF
  ,BALSHEY_NF
  ,BALSHRMTH_NF
  ,BALSHRDAY_NF
  ,TRNCOD_CF
  ,DBLTRNCOD_CF
  ,CTR_NF
  ,END_NT
  ,SEC_NF
  ,UWY_NF
  ,UW_NT
  ,OCCYEA_NF
  ,ACY_NF
  ,SCOSTRMTH_NF
  ,SCOENDMTH_NF
  ,CLM_NF
  ,CUR_CF
  ,AMT_MC
  ,FILLER52
exit
EOF
SORT

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------
gzip -c ${DFILT}/${NJOB}_03_${IB}_AWK_DLAGTAA_EBS.dat         > ${DFILT}/${NJOB}_003_AWK_DLAGTAA_EBS.dat.gz
gzip -c ${DFILT}/${NJOB}_20_${IB}_SORT_IADPERICASE.dat        > ${DFILT}/${NJOB}_020_IADPERICASE.dat.gz
gzip -c ${DFILT}/${NJOB}_30_${IB}_SORT_DLDGTAA_PREC_O.dat     > ${DFILT}/${NJOB}_030_DLDGTAA_PREC.dat.gz
gzip -c ${DFILT}/${NJOB}_150_${IB}_SORT_DLGTAA.dat            > ${DFILT}/${NJOB}_150__SORT_DLGTAA_INPUT_FUTURE.dat.gz
gzip -c ${DFILT}/${NJOB}_160_${IB}_SORT_SEGEST_SOLVENCY_O.dat > ${DFILT}/${NJOB}_160_SEGEST.dat.gz
gzip -c ${DFILT}/${NJOB}_170_${IB}_ESTC1064_DLGTAA.dat        > ${DFILT}/${NJOB}_170_ESTC1064_DLGTAA_FUTURES.dat.gz
gzip -c ${DFILT}/${NJOB}_180_${IB}_SORT_DLDGTAA_NEW_O.dat     > ${DFILT}/${NJOB}_180_SORT_DLDGTAA_NEW_FUTURES_PLAS.dat.gz
gzip -c ${DFILT}/${NJOB}_190_${IB}_ESTC1054_DLDGTAA_E.dat     > ${DFILT}/${NJOB}_190__ESTC1054_DLDGTAA_DELTA_EBS.dat.gz
gzip -c ${DFILT}/${NJOB}_200_${IB}_SORT_DLDGTAA_E.dat         > ${DFILT}/${NJOB}_200_MVT_DLDGTAA_E.dat.gz

#[004]
NSTEP=${NJOB}_210
#Double entry transaction code addition in dDVGTAr
#-----------------------------------------------------------------------------
LIBEL="PLAS + FUTURES : Double entry transaction code addition in dDVGTAr in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_200_${IB}_SORT_DLDGTAA_E.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${EST_DLDGTAA_E_TRNCODEBS}
EXECPRG


#########################
# Erase temporary files #
#########################

NSTEP=${NJOB}_300
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
