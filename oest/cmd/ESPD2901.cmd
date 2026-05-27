#!/bin/ksh
#=============================================================================
# nom de l'application         : ESTIMATIONS - INVENTAIRE
#                                Rejets / Reconduction (ecritures post omega)
# nom du script SHELL          : ESPD2901.cmd
# revision                     : $Revision: 1.5 $
# date de creation             : 21/06/2005
# auteur                       : J. Ribot
# references des specifications: SPOT 5085
#-----------------------------------------------------------------------------
# description
#   Retrocession reversal and carried forward entries generation
#
# job launched by ESPD2900.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#   02/11/2006   J. Ribot  SPOT 13321 remplace le parametre BOOKING_D par INVCONSO_D
#   02/02/2010   JF VDV [18853] - Ajout d'un tri en entree du programme ESTM7602.c (prise en compte de l'etablissement )
#                                 nouveaux step 02, 07 & 09
#[03] 26/11/2012 R. Cassis :spot:24041 - Solvency 2
#[04] 20/01/2013 :spot:24698 - -=PhP=-  corrections pour la conso 
#[05] 20/02/2013 :spot:24867 - -=PhP=-  corrections pour la conso 
#[06] 10/04/2013 :spot:25096 - -=PhP=-  corrections pour la conso 
#[07] 27/02/2015 R. Cassis :spot:28088 - Add file EPO_DLRLGTAA as input for Acceptation and archive critical files and correct files formating
#[08] 14/03/2016 Florent   :spot:29066 GLT à 71 cols
#[09] 01/08/2016 R. Cassis :spot:30152 - Add step for Double entry transaction code addition et DLRLGTAA renomme en DLRIGTAA - omit EBS when IFRS processed
#[10] 18/10/2016 Florent   :spot:31344 - Maj pour mettre les échanges internes avec EPO_DLRGTAA et ajout EPO_DLREGT* et EPO_DLREMAJGT* pour l'IFRS
#[11] 21/06/2017 R. Cassis :spira:60427 ESPD2901 is used for POS IFRS only
#[12] 08/03/2018 R. Cassis :spira:60427 Ajout execution RETM0532 en compta POSI pour Information du No de placement et du retrocessionnaire pour les fichiers de la retro interne.
#[13] 29/04/2019 R. Cassis :spira:65656 rename fichier EPO_DLRGTAA en EPO_DLRGTAASO
#[14] 22/10/2020 R. cassis :spira:66261 - Add SSD_CF key in SORT process
#[15] 28/01/2022 R.CASSIS  :spira:98240 Ajout colonnes TRN_NT, I17PRDCOD_CT, GAAPCOD_NT et RETARDRETINT_B dans clé de tri
#[16] 26/06/2023 JYP:spira 109764 : update NEWCOLS1_NF=empty 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
INVCONSO_D=$1
CONSOMTH=$2

NORME="IFRS"

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME.............: ${NORME}"
ECHO_LOG "#===> EPO_DLRGTAASO.....: ${EPO_DLRGTAASO}"
ECHO_LOG "#===> EPO_DLREGTARSO....: ${EPO_DLREGTARSO}"
ECHO_LOG "#===> EPO_DLREGTRSO.....: ${EPO_DLREGTRSO}"
ECHO_LOG "#===> EPO_DLREMAJGTARSO.: ${EPO_DLREMAJGTARSO}"
ECHO_LOG "#===> EPO_DLREMAJGTRSO..: ${EPO_DLREMAJGTRSO}"
ECHO_LOG "#===> EPO_DLSGTARSO.....: ${EPO_DLSGTARSO}"
ECHO_LOG "#===> EPO_DLSGTAASO.....: ${EPO_DLSGTAASO}"
ECHO_LOG "#===> EPO_DLSGTRSO......: ${EPO_DLSGTRSO}"
ECHO_LOG "#===> EPO_DLREJGTAASO...: ${EPO_DLREJGTAASO}"
ECHO_LOG "#===> EPO_DLREJGTARSO...: ${EPO_DLREJGTARSO}"
ECHO_LOG "#===> EPO_DLREJGTRSO....: ${EPO_DLREJGTRSO}"
ECHO_LOG "#===> INVCONSO_D........: ${INVCONSO_D}"
ECHO_LOG "#===> CONSOMTH..........: ${CONSOMTH}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_00
#-----------------------------------------------------------------
LIBEL="Last version of ESID2900 files deletion"
RMFIL "${EPO_DLREJGTAASO} ${EPO_DLREJGTARSO} ${EPO_DLREJGTRSO}"

#[007][013]
NSTEP=${NJOB}_01AA
#-----------------------------------------------------------------------------
LIBEL="Current sort file GTAA and Omit EBS data"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLRGTAASO} 1000 1"
SORT_I2="${EPO_DLSGTAASO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAASO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF     6:1 -  6:,
        TRNCOD2C_CF   6:2 -  6:2
/CONDITION COND_IFRS ("AEJ" NC TRNCOD2C_CF )
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS
/COPY
exit
EOF
SORT

#[12]
NSTEP=${NJOB}_01AR1
#-----------------------------------------------------------------------------
LIBEL="Current sort file GTAR for RETM0532 and Omit EBS data"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLREGTARSO} 1000 1"
SORT_I2="${EPO_DLREMAJGTARSO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTARSO_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD2C_CF   6:2 -  6:2,
        RETCTR_NF    24:1 - 24:,
        RETSEC_NF    26:1 - 26:EN,
        RTY_NF       27:1 - 27:,
        PLC_NT       36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
/CONDITION COND_IFRS ("AEJ" NC TRNCOD2C_CF )
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS
exit
EOF
SORT

#[12]
NSTEP=${NJOB}_01AR2
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne for POSI Accounting"
PRG=RETM0532
export ${PRG}_I1=${EPO_FPLATXCUM}
export ${PRG}_I2=${DFILT}/${NJOB}_01AR1_${IB}_SORT_DLREGTARSO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREGTARSO_O.dat
EXECPRG

NSTEP=${NJOB}_01RR
#-----------------------------------------------------------------------------
LIBEL="Current sort file GTR and Omit EBS data"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLREGTRSO} 1000 1"
SORT_I2="${EPO_DLREMAJGTRSO} 1000 1"
SORT_I3="${EPO_DLSGTRSO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTRSO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF     6:1 -  6:,
        TRNCOD2C_CF   6:2 -  6:2
/CONDITION COND_IFRS ("AEJ" NC TRNCOD2C_CF )
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS
/COPY
exit
EOF
SORT

#[14]
NSTEP=${NJOB}_02
#-----------------------------------------------------------------------------
LIBEL="Current sort file GTAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01AA_${IB}_SORT_DLSGTAASO_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAASO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        TRN_NT     56:1 - 56:,
        RETARDRETINT_B 61:1 - 61:,
        GAAPCOD_NT  64:1 - 64:,
        I17PRDCOD_CT 65:1 - 65:
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
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
exit
EOF
SORT

NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Acceptance retrocession reversal and carried forward in progress ..."
PRG=ESTM7602
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${INVCONSO_D}
BALSHTMTH_NF ${CONSOMTH}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_02_${IB}_SORT_DLSGTAASO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJGTAASO_O.dat
EXECPRG

#[09]
NSTEP=${NJOB}_05B
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTA in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_ESTM7602_DLREJGTAASO_O.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJGTAASO_O.dat
EXECPRG

#[007]
NSTEP=${NJOB}_06
#-----------------------------------------------------------------------------
LIBEL="DLSGTAASO SORT , blank NEWCOLS1_NF ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05B_${IB}_ESTM7603_DLREJGTAASO_O.dat 1000 1"
SORT_O="${EPO_DLREJGTAASO} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF    27:1 - 27:,
        PLC_NT    36:1 - 36:EN,
        FILLER01   1:1 - 56:,
        FILLER58to62    58:1 - 62:,
		COLS_END        64:1 - 71: 			
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
/DERIVEDFIELD ORICOD_LS "${NORME}GTA~"
/DERIVEDFIELD NEWCOLS1_NF "~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER01, ORICOD_LS,  FILLER58to62,NEWCOLS1_NF,COLS_END
exit
EOF
SORT

#[14]
NSTEP=${NJOB}_07
#-----------------------------------------------------------------------------
LIBEL="Current sort file GTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01AR2_${IB}_RETM0532_DLREGTARSO_O.dat 1000 1"
SORT_I2="${EPO_DLSGTARSO} 1000 1"   #[12]
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSREGTARSO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 - 1: EN,
        ESB_CF           2:1 - 2:,
        BALSHEY_NF       3:1 - 3: EN,
        BALSHRMTH_NF     4:1 - 4: EN,
        TRNCOD_CF        6:1 - 6:,
        TRNCOD1_CF       6:1 - 6:1,
        CTR_NF           8:1 - 8:,
        END_NT           9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOENDMTH_NF    16:1 - 16:,
        SCOSTRMTH_NF    15:1 - 15:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        PLC_NT          36:1 - 36:,
        TRN_NT          56:1 - 56:,
        RETARDRETINT_B  61:1 - 61:,
        GAAPCOD_NT      64:1 - 64:,
        I17PRDCOD_CT    65:1 - 65:
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
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
exit
EOF
SORT

gzip -c ${DFILT}/${NJOB}_07_${IB}_SORT_DLSREGTARSO_O.dat    > ${DFILT}/${NJOB}_07_SORT_DLSREGTARSO_O.dat.gz

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Acceptance retrocession reversal and carried forward in progress ..."
PRG=ESTM7602
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${INVCONSO_D}
BALSHTMTH_NF ${CONSOMTH}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_07_${IB}_SORT_DLSREGTARSO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJGTARSO_O.dat  #[007]
EXECPRG

#[09]
NSTEP=${NJOB}_10B
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTAR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_ESTM7602_DLREJGTARSO_O.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJGTARSO_O.dat
EXECPRG

#[007]
NSTEP=${NJOB}_11
#-----------------------------------------------------------------------------
LIBEL="Update oricod_ls to IFRSGTA and add columns from 42 to 57, blank NEWCOLS1_NF "
AWK_I=${DFILT}/${NJOB}_10B_${IB}_ESTM7603_DLREJGTARSO_O.dat
AWK_O=${EPO_DLREJGTARSO}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
	\$42 = "";
	\$43 = "";
	\$57 = "IFRSGTA";
	\$63 = "";
	print \$0;
}
exit
EOF
AWK

#[14]
NSTEP=${NJOB}_12
#-----------------------------------------------------------------------------
LIBEL="Current sort file GTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_01RR_${IB}_SORT_DLSGTRSO_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTRSO_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        TRN_NT          56:1 - 56:,
        RETARDRETINT_B  61:1 - 61:,
        GAAPCOD_NT      64:1 - 64:,
        I17PRDCOD_CT    65:1 - 65:
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
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
exit
EOF
SORT

NSTEP=${NJOB}_15
#-----------------------------------------------------------------------------
LIBEL="Retrocession retrocession reversal and carried forward of previous balance sheet in the book in progress ..."
PRG=ESTM7602
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${INVCONSO_D}
BALSHTMTH_NF ${CONSOMTH}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_12_${IB}_SORT_DLSGTRSO_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREJGTRSO_O.dat
EXECPRG

#[09]
NSTEP=${NJOB}_15B
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_15_${IB}_ESTM7602_DLREJGTRSO_O.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${EPO_DLREJGTRSO}
EXECPRG

#[007]
ECHO_LOG "--> Archivage des fichiers"
gzip -c ${EPO_DLRGTAASO}     > ${DARCH}/${ENV_PREFIX}_ESPD2550_DLRGTAASO_${NORME}_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLREGTARSO}    > ${DARCH}/${ENV_PREFIX}_ESPD2500_DLREGTARSO_${NORME}_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLREGTRSO}     > ${DARCH}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_${NORME}_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLREMAJGTARSO} > ${DARCH}/${ENV_PREFIX}_ESPD2500_DLREMAJGTARSO_${NORME}_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLREMAJGTRSO}  > ${DARCH}/${ENV_PREFIX}_ESPD2500_DLREMAJGTRSO_${NORME}_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLSGTAASO}     > ${DARCH}/${ENV_PREFIX}_ESPD1800_DLSGTAASO_${NORME}_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLSGTARSO}     > ${DARCH}/${ENV_PREFIX}_ESPD1800_DLSGTARSO_${NORME}_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLSGTRSO}      > ${DARCH}/${ENV_PREFIX}_ESPD1800_DLSGTRSO_${NORME}_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLREJGTAASO}   > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTAASO_${NORME}_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLREJGTARSO}   > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTARSO_${NORME}_${INVCONSO_D}.dat.gz
gzip -c ${EPO_DLREJGTRSO}    > ${DARCH}/${ENV_PREFIX}_ESPD2900_DLREJGTRSO_${NORME}_${INVCONSO_D}.dat.gz


JOBEND
