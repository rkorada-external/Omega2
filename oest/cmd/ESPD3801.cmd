#!/bin/ksh
#=============================================================================
# nom de l'application  : ESTIMATIONS -
#                           préparation des GTA et GTR à injecter dans l'infocentre
#                           ( ecritures Post omega)
# nom du script SHELL   :   ESPD3801.cmd
# date de creation      :   16/06/2005
# auteur                :   J. Ribot
# references des specifications	: SPOT 5085
#-----------------------------------------------------------------------------
# description:  Generation of the Acceptance and Retrocession TL files
#
# Input files
#       EPO_DLSGTAASO     	DFILP
#       EPO_DLSGTARSO     	DFILP
#       EPO_DLSGTRSO      	DFILP
#       EPO_FCPLACC		    DFILP
#       EPO_FCTRGRO		    DFILP
#       EPO_FPLC            DFILP
#       EPO_FSOBBLOB	  	DFILP
#       EPO_FSSDACTR	  	DFILP
#       EPO_FTECLEDA		DFILP
#       EPO_FTECLEDR		DFILP
#       EPO_OIADVPERICASE	DFILP
#       EPO_OIRDVPERICASE	DFILP
#
# Output files
#       EPO_FTECLEDA		DFILP
#       EPO_FTECLEDR		DFILP
#
# Launch C program ESTC8801 8802 8803
#
# launched by ESID3800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#---------------
#MODIFICATION   : [001]
#Auteur         : D.GATIBELZA
#Date           : 09/02/2011
#Version        : 11.1
#Description    : 1GL
#[002]  04/05/2011  R. CASSIS   :spot:21408 - Modification OneGL
#-----------------------------------------------------------------------------
#[003] -=Dch=-  22/09/2011      :spot:22655 - Ajout de EPO_FPLACEMT2
#[004] 22/09/2011  R. CASSIS    :spot:22648 - Le montant inverse est en colonne 88 pour Retintamt_m
#[005] 21/12/2011  R. Cassis    :spot:23089 - On ne tri plus sur la cle ZZRECONKEY_CF, les 14 champs sont remis a null.
#[006] 26/11/2012  PPEZOUT      :spot:24516 création, ECHANGES INTERNES POST OMEGA
#[007] 26/03/2013  PPEZOUT      :spot:25034 VENTILATION DES gtar PAR PLACEMENT INTERNE
#[008] 25/11/2014  R. Cassis    :spot:27847 - take care of EBS LIFE %[GH]
#[007] 07/07/2015  D. Fillinger :spot:28947 - filtrage des analystiques avant envoi 1GL
#[010] 17/03/2016  Florent      :spot:29066 - formatage du fichier GT
#[011] 09/11/2016  MMA          :spot:31463:SPIRA:041626 : Descente des suffixes G dans le GLT
#[012] 04/05/2017  Florent      :spira:60794 - EST 58 sur transaction number : plus de fusion de deux numeros d'ES !
#[013] 31/10/2018 R. Cassis     :spira:60427 Ajout archivage du fichier MTH et autres fichiers temporaires
#[014] 29/04/2019 R. Cassis     :spira:65656 - Separation fichiers IFRS/EBS
#[015] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[016] 01/04/2022 JYP/TD        :spira:103544 - DELTA posting new mode  
#[017] 15/09/2022 JYP/TD        :spira:103544 - DELTA posting new mode  
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
CRE_D=$1
#[001] AJOUTER ANNEE MOIS BILAN
CONSOYEA=$2
CONSOMTH=$3


# Job Initialisation
JOBINIT

#[001] [008] [011]
NSTEP=${NJOB}_05
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLSGTAASO} 1000 1"
SORT_I2="${EPO_DLRGTAASO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAASO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        TRNCOD2C_CF      6:2 -  6:2,
        TRNCOD2D_CF      6:8 -  6:8,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        LIGNEGT          1:1 - 39: ,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:,
        FILLER_30_COLS  42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/CONDITION COND_EBS ("AEJ" NC TRNCOD2C_CF ) AND ("H" NC TRNCOD2D_CF )
/OUTFILE ${SORT_O}
/INCLUDE COND_EBS
/REFORMAT LIGNEGT ,
          RETKEY_CF ,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_M,
          FILLER_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_06
#DLSGTARSO sort
#-----------------------------------------------------------------------------
LIBEL="DLREGTARSO SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLREGTARSO} 1000 1"
SORT_I2="${EPO_DLREMAJGTARSO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTARSO.dat 1000 1"
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

NSTEP=${NJOB}_07
# Prog affectation retro interne
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${EPO_FPLATXCUM}
export ${PRG}_I2=${DFILT}/${NJOB}_06_${IB}_SORT_DLREGTARSO.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREGTARSO.dat
EXECPRG

#[001] [011]
NSTEP=${NJOB}_10
# Merge and sort of the Acceptance and Retrocession files
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLSGTARSO} 1000 1"
SORT_I2="${DFILT}/${NJOB}_07_${IB}_RETM0532_DLREGTARSO.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTARSO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        TRNCOD2C_CF      6:2 -  6:2,
        TRNCOD2D_CF      6:8 -  6:8,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        LIGNEGT          1:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:,
        FILLER_30_COLS  42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/CONDITION COND_EBS ("AEJ" NC TRNCOD2C_CF ) AND ("H" NC TRNCOD2D_CF )
/OUTFILE ${SORT_O}
/INCLUDE COND_EBS
/REFORMAT LIGNEGT ,
          RETKEY_CF ,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_M,
          FILLER_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_12
#Double entry transaction code addition in dDVGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_DLSGTAASO_O.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAASO.dat
EXECPRG

NSTEP=${NJOB}_13
#Double entry transaction code addition in dDVGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTARSO_O.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTARSO.dat
EXECPRG

NSTEP=${NJOB}_15
# File generation in TTECLEDA table format
#-----------------------------------------------------------------------------
LIBEL="Files generation in TTECLEDA table format"
PRG=ESTC8801
export ${PRG}_I1=${EPO_OIADVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_12_${IB}_ESTM7603_DLSGTAASO.dat
export ${PRG}_I3=${EPO_FCTRGRO}
export ${PRG}_I4=${EPO_FCPLACC}
export ${PRG}_I5=${DFILT}/${NJOB}_13_${IB}_ESTM7603_DLSGTARSO.dat
export ${PRG}_I6=${EPO_FSOBBLOB}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAA_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
EXECPRG

NSTEP=${NJOB}_20
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_DLSGTAASO_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTARSO_O.dat

# [011]
NSTEP=${NJOB}_25
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledger"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLSGTRSO} 1000 1"
SORT_I2="${EPO_DLREGTRSO} 1000 1"
SORT_I3="${EPO_DLREMAJGTRSO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTRSO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF        6:1 -  6:,
        TRNCOD2C_CF      6:2 -  6:2,
        TRNCOD2D_CF      6:8 -  6:8,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        LIGNEGT          1:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        FILLER_16_COLS  56:1 - 71:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD AJOUT_11_COLS 11"~"
/CONDITION COND_EBS ("AEJ" NC TRNCOD2C_CF ) AND ("H" NC TRNCOD2D_CF )
/OUTFILE ${SORT_O}
/INCLUDE COND_EBS
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          AJOUT_11_COLS,
          FILLER_16_COLS
exit
EOF
SORT

NSTEP=${NJOB}_26
#Double entry transaction code addition in dDVGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_25_${IB}_SORT_DLSGTRSO_O.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTRSO.dat
EXECPRG

NSTEP=${NJOB}_30
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAR_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAA_O1.dat > ${DFILT}/${NJOB}_15_ESTC8801_FTECLEDAA_O1.dat.gz

NSTEP=${NJOB}_35
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAR_O2.dat

NSTEP=${NJOB}_40
# File generation in TTECLEDR table format
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8802
export ${PRG}_I1=${EPO_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDAR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_26_${IB}_ESTM7603_DLSGTRSO.dat
export ${PRG}_I4=${EPO_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_REJETE_O4.dat
EXECPRG

#[002]
NSTEP=${NJOB}_41
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8806
export ${PRG}_I1=${EPO_OIADVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
EXECPRG

gzip -c ${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDAR_O.dat > ${DFILT}/${NJOB}_30_SORT_FTECLEDAR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_25_${IB}_SORT_DLSGTRSO_O.dat  > ${DFILT}/${NJOB}_25_SORT_DLSGTRSO_O.dat

NSTEP=${NJOB}_45
#------------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_FTECLEDAR_O.dat
RMFIL ${DFILT}/${NJOB}_25_${IB}_SORT_DLSGTRSO_O.dat

NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        PLC_NT 36:1 - 36:
/KEYS RETCTR_NF,
      RTY_NF,
      PLC_NT
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_O1.dat > ${DFILT}/${NJOB}_40_ESTC8802_FTECLEDR_O1.dat.gz

NSTEP=${NJOB}_55
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDR_O1.dat

NSTEP=${NJOB}_60
# Update of SSDRTO_B ( internal retrocession )
#-----------------------------------------------------------------------------
LIBEL="Update of SSDRTO_B ( internal retrocession )"
PRG=ESTC8803
export ${PRG}_I1=${DFILT}/${NJOB}_50_${IB}_SORT_FTECLEDR_O.dat
export ${PRG}_I2=${EPO_FPLACEMT2}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O.dat
EXECPRG

gzip -c ${DFILT}/${NJOB}_50_${IB}_SORT_FTECLEDR_O.dat     > ${DFILT}/${NJOB}_050_SORT_FTECLEDR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_60_${IB}_${PRG}_FTECLEDR_O.dat   > ${DFILT}/${NJOB}_060_${PRG}_FTECLEDR_O.dat.gz

NSTEP=${NJOB}_65
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_50_${IB}_SORT_FTECLEDR_O.dat

#[002]
if [ ! -f ${EPO_FTECLEDASO_CUR} ]
then
  touch ${EPO_FTECLEDASO_CUR}
fi

#[001]
#[002]
#[005]
NSTEP=${NJOB}_66
# sauvegarder ancien EPO_FTECLEDASO_CUR sur la période en cours
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDASO_CUR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPO_FTECLEDASO_CUR.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS BALSHEY_NF       3:1 -   3:EN,
        BALSHRMTH_NF     4:1 -   4:EN,
        DEBUT            1:1 -  88:,
        FIN            103:1 - 118:
/CONDITION PERIODE BALSHEY_NF = ${CONSOYEA} AND BALSHRMTH_NF = ${CONSOMTH}
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/OUTFILE ${SORT_O}
/INCLUDE PERIODE
/REFORMAT DEBUT,PLUS_14_CHAMPS,FIN
exit
EOF
SORT

#[001]
#[002]
#[004]
NSTEP=${NJOB}_67
# si EPO_FTECLEDASO_CUR existe sur la période, Inverser tous les mouvements de la période.
#-----------------------------------------------------------------------------
LIBEL="Inversion des montant RETRO venant des CNA AUTO + DAC extraits"
AWK_I=${DFILT}/${NJOB}_66_${IB}_EPO_FTECLEDASO_CUR.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_FTECLEDA_CUR_PRECED_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { if ( \$19 != 0 ) \$19 = sprintf("%-.3lf",-\$19);
         if ( \$35 != 0 ) \$35 = sprintf("%-.3lf",-\$35);
         if ( \$88 != 0 ) \$88 = sprintf("%-.3lf",-\$88);
            ; print \$0 }
exit
EOF
AWK

#[001]
#[005]
NSTEP=${NJOB}_69
# Création du fichier EPO_FTECLEDASO_CUR
#------------------------------------------------------------------------------
LIBEL="Création du fichier EPO_FTECLEDASO_CUR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDAR_O2.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_41_${IB}_ESTC8806_FTECLEDR_FORMAT_AR_O3.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPO_FTECLEDASO_MVT.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DEBUT   1:1 -  88:,
        FIN   103:1 - 118:
/DERIVEDFIELD PLUS_14_CHAMPS 14"~"
/OUTFILE ${SORT_O}
/REFORMAT DEBUT,PLUS_14_CHAMPS,FIN
exit
EOF
SORT


# !!!!!!!!!!!!!!! !!! Voir comment summer AMT ensemble et RETAMT ensemble  !!!!!!!!!!!!!!!!!!
# !!!! sum sur la cle TTECELDA
#  CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
#
# EPO_FTECLEDASO_CUR_INVERSE
# EPO_FTECLEDASO_CUR
# forcer les 14 champs à vide
# => EPO_FTECLEDASO_MVT pour envoi 3850
#[005]
NSTEP=${NJOB}_71
# Merge FTECLEDA_CUR and FTECLEDA_MVT
#--------------------------------
LIBEL="Merge FTECLEDA_CUR and FTECLEDA_MVT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_67_${IB}_AWK_FTECLEDA_CUR_PRECED_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_69_${IB}_EPO_FTECLEDASO_MVT.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_EPO_FTECLEDASO_MVT.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	DBLTRNCOD_CF      7:1 -   7:,
	CTR_NF            8:1 -   8:,
	END_NT            9:1 -   9:,
	SEC_NF           10:1 -  10:,
	UWY_NF           11:1 -  11:,
	UW_NT            12:1 -  12:,
	OCCYEA_NF        13:1 -  13:EN,
	ACY_NF           14:1 -  14:EN,
	SCOSTRMTH_NF     15:1 -  15:EN,
	SCOENDMTH_NF     16:1 -  16:EN,
	CUR_CF           18:1 -  18:,
	AMT_M            19:1 -  19:EN 15/3,
	CED_NF           20:1 -  20:,
	RETCTR_NF        24:1 -  24:,
	RETEND_NT        25:1 -  25:,
	RETSEC_NF        26:1 -  26:,
	RTY_NF           27:1 -  27:,
	RETUW_NT         28:1 -  28:,
	RETOCCYEA_NF     29:1 -  29:EN,
	RETACY_NF        30:1 -  30:EN,
	RETSCOSTRMTH_NF  31:1 -  31:EN,
	RETSCOENDMTH_NF  32:1 -  32:EN,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 15/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
  CRE_D            41:1 -  41:,
	RETINTAMT_M      88:1 -  88:EN 15/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:
/KEYS
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
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
	CUR_CF,
	CED_NF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF,
	RETCUR_CF,
	PLC_NT,
	RTO_NF,
  CRE_D,
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0) and BALSHEY_NF > 0
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M , TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT

#[007] retirer les Analytiques du MVT
NSTEP=${NJOB}_80
#------------------------------------------------------------------------------
# Split EPO_FTECLEDASO_MVT
#-----------------------------------------------------------------------------
LIBEL="Split Analitics from EPO_FTECLEDASO_MVT "
PRG=ESTC8807
export ${PRG}_I1=${DFILT}/${NJOB}_71_${IB}_EPO_FTECLEDASO_MVT.dat
export ${PRG}_I2=${EPO_SUBTRS}
export ${PRG}_O1=${EPO_FTECLEDASO_MVT}
export ${PRG}_O2=${EPO_FTECLEDASO_MTH}
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_EPO_FTECLEDASO_REP.dat  #[007] la sortie REP ne nous interresse pas ici
EXECPRG

gzip -c ${DFILT}/${NJOB}_71_${IB}_EPO_FTECLEDASO_MVT.dat    > ${DFILT}/${NJOB}_71_EPO_FTECLEDASO_MVT.dat.gz
gzip -c ${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAA_O1.dat > ${DFILT}/${NJOB}_15_ESTC8801_FTECLEDAA_O1.dat.gz
gzip -c ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDAR_O2.da  > ${DFILT}/${NJOB}_40_ESTC8802_FTECLEDAR_O2.dat.gz

NSTEP=${NJOB}_100
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_15_${IB}_ESTC8801_FTECLEDAA_O1.dat
RMFIL ${DFILT}/${NJOB}_40_${IB}_ESTC8802_FTECLEDAR_O2.dat

NSTEP=${NJOB}_150
# Constitution of the new FTECLEDR file
#------------------------------------------------------------------------------
LIBEL="Constitution of the new FTECLEDR file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_ESTC8803_FTECLEDR_O.dat 1000 1"
SORT_I2="${EPO_FTECLEDR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        PLC_NT 36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_180
#
#-----------------------------------------------------------------------------
LIBEL="Internal reference addition in the new FTECLEDR file"
PRG=ESTC8804
export ${PRG}_I1=${DFILT}/${NJOB}_150_${IB}_MERGE_FTECLEDR_O.dat
export ${PRG}_I2=${EPO_FSSDACTR}
export ${PRG}_O1=${EPO_FTECLEDRSO}
EXECPRG

gzip -c ${DFILT}/${NJOB}_150_${IB}_MERGE_FTECLEDR_O.dat > ${DFILT}/${NJOB}_150_MERGE_FTECLEDR_O.dat.gz

#[013]
if [ "${ESPD3800_COND4}" == "Y" ]
then
	NSTEP=${NJOB}_190
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Archivage fichier ESPD3800_FTECLEDASO_MTH le jour de la Comptabilisation"
	EXECKSH_MODE=P
	gzip -c ${EPO_FTECLEDASO_MTH} > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_MTH_${CONSOYEA}${CONSOMTH}_${CRE_D}.dat.gz
fi

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_200
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
