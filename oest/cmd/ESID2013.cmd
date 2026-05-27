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
#[007] 26/05/2016 S.Behague :spot:30583: Spira 41148
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

if [ "${TYPEINV}" != "INV" ]
then
	if [ "${TYPEINV}" = "POS" ]
	then
		# en sortie du espd2003
		EST_DLDGTAA_E_TRNCODEBS=${EPO_DLDGTAASO}
#		EST_DLDGTAA_E_TRNCODBEST=${EPO_DLDGTAA_BESTSO}
		# en sortie du espd2002
		EST_DLDGTAA_CUMULS_COUR=${EPO_DLDGTAA_EBSSO}
		EST_FSEGEST_SOLVENCY=${EPO_FSEGEST_SOLVENCYSO}
		EST_DLDGTAA_CUMULS_PREC=${EPO_DLDGTAA}
	else
		# en sortie du espd2003
		EST_DLDGTAA_E_TRNCODEBS=${EPO_DLDGTAACO}
#		EST_DLDGTAA_E_TRNCODBEST=${EPO_DLDGTAA_BESTCO}
		# en sortie du espd2002
		EST_DLDGTAA_CUMULS_COUR=${EPO_DLDGTAA_EBSCO}
		EST_FSEGEST_SOLVENCY=${EPO_FSEGEST_SOLVENCYCO}
		EST_DLDGTAA_CUMULS_PREC=${EPO_DLDGTAAINVPOS}
	fi
	EST_FCTRGRO=${EPO_FCTRGRO}
	EST_IADPERICASE=${EPO_IADPERICASE}
	EST_DLGTAAPNAE=${EPO_DLGTAAPNAE}
	EST_DLGTAATFPNAE=${EPO_DLGTAATFPNAE}
	EST_FDETTRS=${EPO_FDETTRS}
	EST_DLCUMGTAA=${EPO_DLCUMGTAA}
	EST_DLGTAAPRE=${EPO_DLGTAAPRE}
	EST_FTRSLNK=${EPO_FTRSLNK}
	EST_FBOPRSLNK=${EPO_FBOPRSLNK}
	EST_FCURQUOT=${EPO_FCURQUOT}
	EST_MVTPNA0=${EPO_MVTPNA0}
else
	# en sortie du espd2002
	EST_DLDGTAA_CUMULS_PREC=${EST_DLDGTAA_IFRS}
	EST_DLDGTAA_CUMULS_COUR=${EST_DLDGTAA_EBS}
	# en sortie du espd2003
	EST_DLDGTAA_E_TRNCODEBS=${EST_DLDGTAA_E_TRNCODEBS}
fi

if [ "${EST_ESPD2000_COND3}" = "Y" ]
then
	export EST_CURGTA=${DARCH}/`basename ${EST_CURGTA} .dat`_${ICLODAT_A}${ICLODAT_M}.arc
fi


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> EST_DLDGTAA_E_TRNCODBEST...: ${EST_DLDGTAA_E_TRNCODBEST}"
ECHO_LOG "#===> EST_DLDGTAA_E_TRNCODEBS....: ${EST_DLDGTAA_E_TRNCODEBS}"
ECHO_LOG "#===> EST_DLDGTAA_CUMULS_COUR....: ${EST_DLDGTAA_CUMULS_COUR}"
ECHO_LOG "#===> EST_DLDGTAA_CUMULS_PREC....: ${EST_DLDGTAA_CUMULS_PREC}"
ECHO_LOG "#===> EST_DLGTAAPNAE.............: ${EST_DLGTAAPNAE}"
ECHO_LOG "#===> EST_DLGTAATFPNAE...........: ${EST_DLGTAATFPNAE}"
ECHO_LOG "#===> EST_FDETTRS................: ${EST_FDETTRS}"
ECHO_LOG "#===> EST_DLCUMGTAA..............: ${EST_DLCUMGTAA}"
ECHO_LOG "#===> EST_DLGTAAPRE..............: ${EST_DLGTAAPRE}"
ECHO_LOG "#===> EST_IADPERICASE............: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_FSEGEST_SOLVENCY.......: ${EST_FSEGEST_SOLVENCY}"
ECHO_LOG "#===> EST_FTRSLNK................: ${EST_FTRSLNK}"
ECHO_LOG "#===> EST_FBOPRSLNK..............: ${EST_FBOPRSLNK}"
ECHO_LOG "#===> EST_FCURQUOT...............: ${EST_FCURQUOT}"
ECHO_LOG "#===> EST_MVTPNA0................: ${EST_MVTPNA0}"
ECHO_LOG "#===> EST_CURGTA........;........: ${EST_CURGTA}"
ECHO_LOG "#========================================================================="


#[002] ajout de SORT_I3
#[003]
#[004]
NSTEP=${NJOB}_10
#Comparison of period closing and segmentation perimeters
#(by the contract grouping file)
#-----------------------------------------------------------------------------
LIBEL="Comparison of period closing process and segmentation perimeters ..."
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
LIBEL="Sort of IADPERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTM1004_IADPERICASE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF    3:1 -  3:,
        END_NT    4:1 -  4:EN,
        SEC_NF    5:1 -  5:EN,
        UWY_NF    6:1 -  6:,
        UW_NT     7:1 -  7:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_30
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Merge and Sort of GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I=${DFILT}/${NJOB}_10_${IB}_AWK_DLDGTAA.dat
SORT_I=${EST_DLDGTAA_CUMULS_PREC}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD3_CF        6:3 -  6:7,
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
        FIN              42:1 - 57:
/KEYS SSD_CF,
      CTR_NF,
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
      CLM_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION POSTES (TRNCOD3_CF != "41000" AND TRNCOD3_CF != "41100" AND TRNCOD3_CF != "41101" AND TRNCOD3_CF != "41800" AND TRNCOD3_CF != "41900" AND
                   TRNCOD3_CF != "43000" AND TRNCOD3_CF != "43100" AND TRNCOD3_CF != "43101" AND TRNCOD3_CF != "43600" AND TRNCOD3_CF != "43700" AND TRNCOD3_CF != "43701")
/OUTFILE ${SORT_O}
/INCLUDE POSTES
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

NSTEP=${NJOB}_40
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Extrait postes 1141% exepté le 11410002 du EST_CURGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CURGTA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_MVTPNA.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1          1:1 - 18:,
        TRNCOD_CF        6:1 -  6:,
        TRNCOD4_CF       6:1 -  6:4,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:EN,
        SEC_NF          10:1 - 10:EN,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:EN,
        AMT_M           19:1 - 19:EN 15/3,
        FILLER2         20:1 - 34:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:EN,
        RETSEC_NF       26:1 - 26:EN,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:EN,
        RETAMT_M        35:1 - 35:EN 15/3,
        FILLER3         36:1 - 41:,
        FILLER4         42:1 - 57:
/KEYS   CTR_NF
       ,END_NT
       ,SEC_NF
       ,UWY_NF
       ,UW_NT
/CONDITION POSTES TRNCOD_CF = "11410000"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC AMT_M COMPRESS
/OUTFILE ${SORT_O}
/INCLUDE POSTES
/REFORMAT FILLER1
         ,AMT_MC
         ,FILLER2
         ,RETAMT_MC
         ,FILLER3
exit
EOF
SORT

NSTEP=${NJOB}_50
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
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_IADPERICASE.dat         # PHP mettre ici un fichier dans DFILI
export ${PRG}_I2=${DFILT}/${NJOB}_40_${IB}_SORT_MVTPNA.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${EST_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_MVTPNA.dat
EXECPRG

NSTEP=${NJOB}_60
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Ajout 16 champs dans EST_DLGTAAPRE + Oricod"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_ESTC1051_MVTPNA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_MVTPNA.dat 1000 1"
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
       ,FILLER2          20:1 - 33:
       ,RETCUR_CF        34:1 - 34:
       ,RETAMT_M         35:1 - 35:EN 15/3
       ,FILLER3          36:1 - 41:
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
/DERIVEDFIELD PLUS_16_CHAMPS "~~~~~~~~~~~~~~~"
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
/CONDITION LOB ( LOB_CF != "30" AND LOB_CF != "31" )
/SUMMARIZE TOTAL ACMAMT_M
/OUTFILE ${SORT_O}
/INCLUDE LOB
/REFORMAT FILLER1
         ,ACMCUR_CF
         ,ACMAMT_M
         ,FILLER2
         ,ACMCUR_CF
         ,ACMAMT_M
         ,FILLER3
         ,PLUS_16_CHAMPS
exit
EOF
SORT

NSTEP=${NJOB}_70
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Extrait EST_DLGTAAPNAE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLGTAAPNAE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLGTAAPNAE.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1          1:1 - 18:
       ,TRNCOD_CF        6:1 -  6:
       ,TRNCOD4_CF       6:1 -  6:
       ,AMT_M           19:1 - 19:EN 15/3
       ,FILLER2         20:1 - 34:
       ,RETAMT_M        35:1 - 35:EN 15/3
       ,FILLER3         36:1 - 41:
       ,FILLER4         42:1 - 57:
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC AMT_M COMPRESS
/DERIVEDFIELD PLUS_16_CHAMPS "~~~~~~~~~~~~~~~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER1
         ,AMT_MC
         ,FILLER2
         ,RETAMT_MC
         ,FILLER3
         ,PLUS_16_CHAMPS
exit
EOF
SORT

NSTEP=${NJOB}_80
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Extrait EST_DLGTAAPRE sur selection de postes"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLGTAAPRE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLGTAAPRE.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1          1:1 - 18:
       ,TRNCOD_CF        6:1 -  6:
       ,TRNCOD3_CF       6:3 -  6:7
       ,AMT_M           19:1 - 19:EN 15/3
       ,FILLER2         20:1 - 35:
       ,FILLER3         36:1 - 41:
       ,FILLER4         42:1 - 57:
/CONDITION PREMIUM (TRNCOD3_CF='10000' OR TRNCOD3_CF='10010' OR TRNCOD3_CF='10020' OR TRNCOD3_CF='10100' OR TRNCOD3_CF='10110' OR TRNCOD3_CF='10140' OR
                    TRNCOD3_CF='10400' OR TRNCOD3_CF='10410')
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD PLUS_16_CHAMPS "~~~~~~~~~~~~~~~"
/OUTFILE ${SORT_O}
/INCLUDE PREMIUM
/REFORMAT FILLER1
         ,AMT_MC
         ,FILLER2
         ,FILLER3
         ,PLUS_16_CHAMPS
exit
EOF
SORT

NSTEP=${NJOB}_90
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Merge and Sort of GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_MVTPNA.dat 1000 1"
SORT_I2=${DFILT}/${NJOB}_70_${IB}_SORT_DLGTAAPNAE.dat
SORT_I3=${DFILT}/${NJOB}_80_${IB}_SORT_DLGTAAPRE.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAAPREPNAE_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   DEBUT  1:1 - 41:
/DERIVEDFIELD PLUS_16_CHAMPS "~~~~~~~~~~~~~~~"
/OUTFILE ${SORT_O}
/REFORMAT DEBUT,PLUS_16_CHAMPS
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_60_${IB}_SORT_MVTPNA.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_60_SORT_MVTPNA.dat.gz
gzip -c ${DFILT}/${NJOB}_70_${IB}_SORT_DLGTAAPNAE.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_70_SORT_DLGTAAPNAE.gz
gzip -c ${DFILT}/${NJOB}_80_${IB}_SORT_DLGTAAPRE.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_80_SORT_DLGTAAPRE.dat.gz
gzip -c ${DFILT}/${NJOB}_90_${IB}_SORT_DLGTAAPREPNAE_O.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_90_SORT_DLGTAAPREPNAE_O.dat.gz

NSTEP=${NJOB}_100
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Ajout 16 champs dans EST_DLGTAAPRE + Oricod"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_MVTPNA.dat 1000 1"
SORT_I2=${DFILT}/${NJOB}_70_${IB}_SORT_DLGTAAPNAE.dat
SORT_I3=${DFILT}/${NJOB}_80_${IB}_SORT_DLGTAAPRE.dat
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLGTAAPREPNAE.dat 1000 1"
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
/CONDITION AMT (AMT_M > 1 OR AMT_M < -1 OR AMT_M > 1 OR RETAMT_M < -1)
/DERIVEDFIELD FILLER15 "~~~~~~~~~~~~~~~"
/DERIVEDFIELD ORICOD_LS "EBSACC"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
/OUTFILE ${SORT_O}
/INCLUDE AMT
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
  ,FILLER15
  ,ORICOD_LS
exit
EOF
SORT

NSTEP=${NJOB}_110
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Ajout 16 champs dans EST_DLGTAAPRE + Oricod"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_SORT_DLGTAAPREPNAE.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLGTAAPREPNAE.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           8:1 -  8:
       ,END_NT           9:1 -  9:EN
       ,SEC_NF          10:1 - 10:EN
       ,UWY_NF          11:1 - 11:
       ,UW_NT           12:1 - 12:EN
       ,TRNCOD_CF        6:1 -  6:
       ,AMT_M           19:1 - 19:EN 15/3
       ,RETAMT_M        35:1 - 35:EN 15/3
/CONDITION AMT (AMT_M > 1 OR AMT_M < -1 OR AMT_M > 1 OR RETAMT_M < -1)
/KEYS  CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,TRNCOD_CF
/OUTFILE ${SORT_O}
/INCLUDE AMT
exit
EOF
SORT

NSTEP=${NJOB}_120
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="MERGE PNA+PREMIUM ESTIMATES + CHARGES PLAS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_MVTPNA.dat 1000 1"
SORT_I2=${DFILT}/${NJOB}_70_${IB}_SORT_DLGTAAPNAE.dat
SORT_I3=${DFILT}/${NJOB}_80_${IB}_SORT_DLGTAAPRE.dat
SORT_I4="${EST_DLDGTAA_CUMULS_COUR} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN
       ,ESB_CF           2:1 -  2:EN
       ,BALSHEY_NF       3:1 -  3:
       ,BALSHRMTH_NF     4:1 -  4:EN
       ,BALSHRDAY_NF     5:1 -  5:EN
       ,TRNCOD_CF        6:1 -  6:
       ,TRNCOD3_CF       6:3 -  6:7
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
/CONDITION PREMIUM (TRNCOD3_CF='10000' OR TRNCOD3_CF='10010' OR TRNCOD3_CF='10020' OR TRNCOD3_CF='10100' OR TRNCOD3_CF='10110' OR TRNCOD3_CF='10140' OR
                    TRNCOD3_CF='10400' OR TRNCOD3_CF='10410' OR TRNCOD3_CF='30000' OR TRNCOD3_CF='30010' OR TRNCOD3_CF='30100' OR TRNCOD3_CF='30110')
/CONDITION PNA     (TRNCOD3_CF='41000')
/CONDITION CHARGES (TRNCOD3_CF='12000' OR TRNCOD3_CF='12010' OR TRNCOD3_CF='12020' OR TRNCOD3_CF='12030' OR TRNCOD3_CF='12040' OR TRNCOD3_CF='12100' OR TRNCOD3_CF='12120' OR
                    TRNCOD3_CF='12200' OR TRNCOD3_CF='12210' OR TRNCOD3_CF='12240' OR TRNCOD3_CF='12250' OR TRNCOD3_CF='12270' OR TRNCOD3_CF='12300' OR TRNCOD3_CF='13000' OR
                    TRNCOD3_CF='14000' OR TRNCOD3_CF='14010' OR TRNCOD3_CF='15100' OR TRNCOD3_CF='15110' OR TRNCOD3_CF='31000' OR TRNCOD3_CF='31010' OR TRNCOD3_CF='31020' OR
                    TRNCOD3_CF='31030' OR TRNCOD3_CF='31100' OR TRNCOD3_CF='31110' OR TRNCOD3_CF='31200' OR TRNCOD3_CF='31210' OR TRNCOD3_CF='31300' OR TRNCOD3_CF='31310')
/DERIVEDFIELD BALSHEY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "${ICLODAT_J}~"
/DERIVEDFIELD TRNCOD_CF_NEW if PREMIUM then "1A110002~" else if PNA then "1A100002~" else if CHARGES then "1A120002~" else "1A130002~"
/DERIVEDFIELD OCCYEA_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD ACY_NF_NEW "${ICLODAT_A}~"
/DERIVEDFIELD SCOSTRMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD SCOENDMTH_NF_NEW "${ICLODAT_M}~"
/DERIVEDFIELD AMT_M_NEW AMT_M COMPRESS
/DERIVEDFIELD FILLER15 "~~~~~~~~~~~~~~~"
/DERIVEDFIELD CUR_CF_NEW CUR_CF
/DERIVEDFIELD ORICOD_LS "EBSPRM"
/DERIVEDFIELD ZERO "0.000~" CHAR 5
/DERIVEDFIELD STRVIDE "~"
/KEYS  SSD_CF
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,TRNCOD_CF_NEW
      ,CUR_CF_NEW
/OUTFILE ${SORT_O}
/REFORMAT
   SSD_CF
  ,ESB_CF
  ,BALSHEY_NF_NEW
  ,BALSHRMTH_NF_NEW
  ,BALSHRDAY_NF_NEW
  ,TRNCOD_CF_NEW
  ,DBLTRNCOD_CF
  ,CTR_NF
  ,END_NT
  ,SEC_NF
  ,UWY_NF
  ,UW_NT
  ,OCCYEA_NF_NEW
  ,ACY_NF_NEW
  ,SCOSTRMTH_NF_NEW
  ,SCOENDMTH_NF_NEW
  ,CLM_NF
  ,CUR_CF_NEW
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
  ,FILLER15
  ,ORICOD_LS
exit
EOF
SORT

NSTEP=${NJOB}_130
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Recherche des primes emises et des charges"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLCUMGTAA}
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLCGTAA.dat 1000 1"
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
       ,ACMTRS_NT       42:1 - 42:
       ,ACMAMT_M        43:1 - 43:EN 15/3
       ,ACMCUR_CF       44:1 - 44:
/CONDITION POSTES (  ACMTRS_NT = "10000" or ACMTRS_NT = "10010" or ACMTRS_NT = "10020"
                  or ACMTRS_NT = "10030"
                  or ACMTRS_NT = "10100" or ACMTRS_NT = "10110" or ACMTRS_NT = "10120" or ACMTRS_NT = "10200" or ACMTRS_NT = "10300"
                  or ACMTRS_NT = "10310" or ACMTRS_NT = "10320" or ACMTRS_NT = "10400" or ACMTRS_NT = "10401" or ACMTRS_NT = "10410"
                  or ACMTRS_NT = "10420" )
/CONDITION PREMIUM  (ACMTRS_NT = "10000" or ACMTRS_NT = "10010" or ACMTRS_NT = "10020")
/CONDITION PNA      (ACMTRS_NT = "10030")
/CONDITION CHARGES  (ACMTRS_NT = "10100" or ACMTRS_NT = "10110" or ACMTRS_NT = "10120" or ACMTRS_NT = "10200" or ACMTRS_NT = "10300"
                  or ACMTRS_NT = "10310" or ACMTRS_NT = "10320" or ACMTRS_NT = "10400" or ACMTRS_NT = "10401" or ACMTRS_NT = "10410"
                  or ACMTRS_NT = "10420")
/DERIVEDFIELD FILLER15 "~~~~~~~~~~~~~~~"
/DERIVEDFIELD CUR_CF_NEW ACMCUR_CF
/DERIVEDFIELD ORICOD_LS "EBSPRM"
/DERIVEDFIELD BALSHEY_NF_NEW "$ICLODAT_A~"
/DERIVEDFIELD BALSHRMTH_NF_NEW "$ICLODAT_M~"
/DERIVEDFIELD BALSHRDAY_NF_NEW "$ICLODAT_J~"
/DERIVEDFIELD TRNCOD_CF_NEW if PREMIUM then "1A110002~" else if PNA then "1A100002~" else if CHARGES then "1A120002~" else "1A130002~"
/DERIVEDFIELD OCCYEA_NF_NEW "$ICLODAT_A~"
/DERIVEDFIELD ACY_NF_NEW "$ICLODAT_A~"
/DERIVEDFIELD SCOSTRMTH_NF_NEW "$ICLODAT_M~"
/DERIVEDFIELD SCOENDMTH_NF_NEW "$ICLODAT_M~"
/DERIVEDFIELD AMT_M_NEW ACMAMT_M COMPRESS
/KEYS  SSD_CF
      ,CTR_NF
      ,END_NT
      ,SEC_NF
      ,UWY_NF
      ,UW_NT
      ,TRNCOD_CF_NEW
      ,CUR_CF_NEW
/OUTFILE ${SORT_O}
/INCLUDE POSTES
/REFORMAT
   SSD_CF
  ,ESB_CF
  ,BALSHEY_NF_NEW
  ,BALSHRMTH_NF_NEW
  ,BALSHRDAY_NF_NEW
  ,TRNCOD_CF_NEW
  ,DBLTRNCOD_CF
  ,CTR_NF
  ,END_NT
  ,SEC_NF
  ,UWY_NF
  ,UW_NT
  ,OCCYEA_NF_NEW
  ,ACY_NF_NEW
  ,SCOSTRMTH_NF_NEW
  ,SCOENDMTH_NF_NEW
  ,CLM_NF
  ,CUR_CF_NEW
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
  ,FILLER15
  ,ORICOD_LS
exit
EOF
SORT

if [ ${TYPEINV} != "INV" ]
then
	NSTEP=${NJOB}_140
	# Begin Merge and Sort
	#-----------------------------------------------------------------------------
	LIBEL="Fusion des EST_DLGTAAPRE et EST_DLCUMGTAA"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I=${DFILT}/${NJOB}_130_${IB}_SORT_DLCGTAA.dat
	SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLCGTAA.dat
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN
       ,TRNCOD_CF        6:1 -  6:
/CONDITION PNA (TRNCOD_CF = "1A100002")
/OUTFILE ${SORT_O}
/OMIT PNA
exit
EOF
	SORT
else
	EXECKSH "cp ${DFILT}/${NJOB}_130_${IB}_SORT_DLCGTAA.dat ${DFILT}/${NJOB}_140_${IB}_SORT_DLCGTAA.dat "
fi

NSTEP=${NJOB}_150
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Fusion des EST_DLGTAAPRE et EST_DLCUMGTAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_110_${IB}_SORT_DLGTAAPREPNAE.dat 1000 1"
SORT_I2=${DFILT}/${NJOB}_140_${IB}_SORT_DLCGTAA.dat
SORT_I3=${DFILT}/${NJOB}_120_${IB}_SORT_DLDGTAA.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTAA.dat
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
       ,FILLER1          1:1 - 18:
       ,AMT_M           19:1 - 19:EN 15/3
       ,FILLER2         20:1 - 57:
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
       ,ORICOD_LS       57:1 - 57:
/KEYS  SSD_CF
      ,CTR_NF
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
LIBEL="${EST_FSEGEST_SOLVENCY0} file sort in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FSEGEST_SOLVENCY}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SEGEST_SOLVENCY_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF    1:1 - 1:EN
       ,SEG_NF    2:1 - 2:
       ,UWY_NF    3:1 - 3:
       ,AMORAT_CT 8:1 - 8:
/KEYS	SSD_CF
     ,SEG_NF
     ,UWY_NF
/CONDITION BOOK AMORAT_CT = "R"
/INCLUDE BOOK
exit
EOF
SORT

NSTEP=${NJOB}_170
# Begin programme C
#------------------------------------------------------------------------------
LIBEL="Calcul of future premium and charges and claim premium"
PRG=ESTC1064
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_IADPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_150_${IB}_SORT_DLGTAA.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_I5=${DFILT}/${NJOB}_160_${IB}_SORT_SEGEST_SOLVENCY_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAA.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTAA_ANO.dat
EXECPRG

NSTEP=${NJOB}_180
# Begin Merge and Sort [23390] - modif 002 12/06/2012
#-----------------------------------------------------------------------------
LIBEL="Merge and Sort of GT files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLDGTAA_CUMULS_COUR}
SORT_I2="${DFILT}/${NJOB}_170_${IB}_ESTC1064_DLGTAA.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        TRNCOD_CF         6:1 -  6:,
        TRNCOD1_CF        6:1 -  6:1,
        TRNCOD3_CF        6:3 -  6:7,
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
        FIN              42:1 - 57:
/KEYS SSD_CF,
      CTR_NF,
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
      CLM_NF
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION POSTES (TRNCOD3_CF != "41000" AND TRNCOD3_CF != "41100" AND TRNCOD3_CF != "41101" AND TRNCOD3_CF != "41800" AND TRNCOD3_CF != "41900" AND
                   TRNCOD3_CF != "43000" AND TRNCOD3_CF != "43100" AND TRNCOD3_CF != "43101" AND TRNCOD3_CF != "43600" AND TRNCOD3_CF != "43700" AND TRNCOD3_CF != "43701")
/OUTFILE ${SORT_O}
/INCLUDE POSTES
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
#/CONDITION POSTES (TRNCOD_CF != "11410002" AND TRNCOD_CF != "11410006" AND TRNCOD_CF != "11411002" AND TRNCOD_CF != "11411012" AND TRNCOD_CF != "11418002" AND
#                   TRNCOD_CF != "11419002" AND TRNCOD_CF != "11430002" AND TRNCOD_CF != "11430006" AND TRNCOD_CF != "11431002" AND TRNCOD_CF != "11431012" AND
#                   TRNCOD_CF != "11436002" AND TRNCOD_CF != "11436006" AND TRNCOD_CF != "11437002" AND TRNCOD_CF != "11437012")
#
NSTEP=${NJOB}_190
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Create Ecart Data for EBS and BEST Trncod from full file"
PRG=ESTC1054
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
ACCRET_CT A
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_180_${IB}_SORT_DLDGTAA_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_DLDGTAA_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAA_E.dat   # oricod EBSGTA postes transformés
EXECPRG

# ------------------------------------
# TRACES POUR l'ENVIRONNEMENT DE TEST
# ------------------------------------

gzip -c ${DFILT}/${NJOB}_40_${IB}_SORT_MVTPNA.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_15_SORT_MVTPNA.dat.gz
gzip -c ${DFILT}/${NJOB}_50_${IB}_ESTC1051_MVTPNA.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_50_ESTC1051_MVTPNA.dat.gz
gzip -c ${DFILT}/${NJOB}_100_${IB}_SORT_DLGTAAPREPNAE.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_100_SORT_DLGTAAPREPNAE.dat.gz
gzip -c ${DFILT}/${NJOB}_110_${IB}_SORT_DLGTAAPREPNAE.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_110_SORT_DLGTAAPREPNAE.dat.gz
gzip -c ${DFILT}/${NJOB}_120_${IB}_SORT_DLDGTAA.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_120_SORT_DLDGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_130_${IB}_SORT_DLCGTAA.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_130_SORT_DLCGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_140_${IB}_SORT_DLCGTAA.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_140_SORT_DLCGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_150_${IB}_SORT_DLGTAA.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_150_SORT_DLGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_160_${IB}_SORT_SEGEST_SOLVENCY_O.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_160_SORT_SEGEST_SOLVENCY_O.dat.gz
gzip -c ${DFILT}/${NJOB}_170_${IB}_ESTC1064_DLGTAA.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_170_ESTC1064_DLGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_170_${IB}_ESTC1064_DLGTAA_ANO.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_170_ESTC1064_DLGTAA_ANO.dat.gz
gzip -c ${DFILT}/${NJOB}_180_${IB}_SORT_DLDGTAA_O.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_35_SORT_DLDGTAA_O.dat.gz
gzip -c ${DFILT}/${NJOB}_190_${IB}_ESTC1054_DLDGTAA_E.dat > ${DFILT}/SAUVEGARDE_${NCHAIN}_190_ESTC1054_DLDGTAA_E.dat.gz

NSTEP=${NJOB}_200
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Creation of DLDGTAA_E_EBSBEST file from GTA files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_190_${IB}_ESTC1054_DLDGTAA_E.dat
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
       ,FILLER38     20:1 - 57:
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
  ,FILLER38
exit
EOF
SORT

#[004]
NSTEP=${NJOB}_210
#Double entry transaction code addition in dDVGTAr
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTAr in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_200_${IB}_SORT_DLDGTAA_E.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDGTAA_E.dat
EXECPRG

#[004]
NSTEP=${NJOB}_220
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Omit zerro amounts and separate EBS and BEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_210_${IB}_ESTM7603_DLDGTAA_E.dat 1000 1"
SORT_O="${EST_DLDGTAA_E_TRNCODEBS} OVERWRITE"
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_DLDGTAA_E_TRNCODBEST.dat
#SORT_O2="${EST_DLDGTAA_E_TRNCODBEST} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:EN,
        SEC_NF          10:1 - 10:EN,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:EN,
        ACY_NF          14:1 - 14:,
        SCOENDMTH_NF    16:1 - 16:EN,
        SCOSTRMTH_NF    15:1 - 15:EN,
        OCCYEA_NF       13:1 - 13:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:EN 15/3,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:EN,
        RETSEC_NF       26:1 - 26:EN,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:EN,
        RETACY_NF       30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:EN,
        RETSCOSTRMTH_NF 31:1 - 31:EN,
        RETOCCYEA_NF    29:1 - 29:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:EN 15/3,
        PLC_NT          36:1 - 36:,
        RETINTAMT_M     41:1 - 41:EN 15/3,
        ORICOD_LS       57:1 - 57:
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
/CONDITION ANNULEBS  (ORICOD_LS = 'EBSGTA' OR ORICOD_LS = 'EBSPRM') AND (AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0)
/CONDITION ANNULBEST ORICOD_LS = 'BESTGTA' AND (AMT_M != 0 OR RETAMT_M != 0 OR RETINTAMT_M != 0)
/OUTFILE ${SORT_O}
/INCLUDE ANNULEBS
/OUTFILE ${SORT_O2}
/INCLUDE ANNULBEST
exit
EOF
SORT


#########################
# Erase temporary files #
#########################

NSTEP=${NJOB}_300
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND