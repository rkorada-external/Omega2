#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Mise a jour des previsions ecritures post omega
# nom du script SHELL           : ESPD8833.cmd
# revision                      : $Revision: 1.1.1.1 $
# date de creation              : 07/07/2005
# auteur                        : J. Ribot
# references des specifications : spot 5085
#-----------------------------------------------------------------------------
# description
#   Update estimates
#
# job launched by ESPD88300.cmd
#-----------------------------------------------------------------------------
# historique des modifications
# 02/06/2006   step25 ajout tri du fichier STATGTA au lieu du /COPY  SPOT 12888
# 02/11/2006   SPOT 13321 ajout parametres
#                         ajout steps 10 a 20 et modif des fichiers entr�es steps 25 et 35
#                         ajout nouveaux steps 40 a 45 et modif du fichier entr�e steps 45
#                         conditionnement des steps 01 a 32, pas d'execution si traitement annuel
#  30/12/2009   JF VDV  [18718] - Positionner le fichier ARCSTATGTA en I1 , car les 2 autres fichiers si vides , font planter la chaine (STEP75)
#_________________
#MODIFICATION    [004]
#Auteur:         D.GATIBELZA
#Date:           21/04/2011
#Version:        11.1
#Description:    ESTDOM21408 OneLedger
#_________________
#[005]  18/05/2011  R. CASSIS     :spot:21408 - Modification OneGL
#---------------
#MODIFICATION    [006]
#Auteur          D.Chetboul
#Date            19.08.2011
#Version         11.1
#Description     1GL
#SPOT 			 22435 	: Suppression des fichiers FTECLEDASO_CUR/MVT en booking postOmega
#
#    update #PLANNING set COND1="Y" where CHAINE =    "ESPD8830" and     @IsEpo =  'Y'                      -- JR 01/07/2005  MOD10
#                                                                and     @IsEpo31_12 = 'Y'                  -- JR 01/07/2005  MOD10
#                                                                and     @IsEpoComptaRequestF = 'Y'            -- MDJ 22/07/2005
#    update #PLANNING set COND2="Y" where CHAINE =    "ESPD8830" and     @nb_NoEBS > 0
#---------------
#[07] R. Cassis   13/07/2012 :spot:23802 - SOLVENCY - Gestion des archivages de fichiers
#[08] P. Pezout   27/11/2012 :spot:24041 - Solvency 2
#[09] 20/01/2013 :spot:24836 - -=PhP=-  corrections pour la conso
#[10] 20/02/2013 :spot:24875 - -=PhP=-  corrections pour la conso
#[11] 06/06/2013 R. Cassis   :spot:25282 Utilisation du FTECLEDRSO
#[12] 31/07/2013 R. Cassis   :spot:25416 Utilisation du FTECLEDASO_CUR et des DL..
#[13] 18/09/2013 R. Cassis   :spot:25522 Remise a zero des fichiers post-omega
#[14] 29/01/2014 R. Cassis   :spot:26189 Affectation noms de fichiers selon type inventaire
#[15] 18/09/2014 C. Despret  :spot:27476 Ajout du fichier DLDSIIGTR pour prendre en compte les ecritures EBS dans le CURGTR
#[16] 18/03/2015 Roger Cassis :spot:28088 le 8eme caractere du poste comptable ne doit plus etre numerique
#[17] 18/03/2016 Florent  :spot:29066 GT � 71 colonnes
#[18] 04/05/2016 Florent  :spot:30535 exec PuSOLVENCY_02 en POS EBS uniquement
#[19] 27/06/2016 R. Cassis :spot:30713  Archivage FTECLEDSIISO
#[20] 06/10/2016 R. Cassis :spot:31302  Archivage GTSII_RISKMARGINSO
#[21] 03/08/2017 R. Cassis :spira:63164 Le fichier GTEP a un nom specifique pour chaque type d'inventaire post-omega.
#[22] 29/03/2018 R. Cassis :spira:68016 Remise en ordre du shell - Affectation de ce shell pour le POS IFRS uniquement
#[23] 26/04/2018 R. Cassis :spira:68514 Correction d'un commentaire en fin de job qui a des une double cote en trop.
#[24] 29/04/2019 R. Cassis :spira:65656 rename fichier EPO_DLRGTAA en EPO_DLRGTAASO
#[25] 29/11/2019 R. Cassis :spira:81496 Mise a jour de l'etablissement dans FTECLEDASO sur FTECLEDASO_EBS a partir de Pericase
#[26] 27/12/2019 R. Cassis :spira:80329 Archivage fichiers ajoutes dans CURGTx
#[27] 14/05/2020 R. Cassis :spira:87041 On ne force pas l'etablissement a partir du Pericase si poste retro
#[28] 16/12/2020 R. Cassis :spira:92262 Mise a jour de l'ARCSTATGTAR a partir du CURGTA et de l'ancien
#[29] 22/12/2020 : M.NAJI   :. SPIRA 91531 et correction double cote en trop
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[30] 04/08/2021 R.CASSIS : SPIRA 91532 gestion archivage de fichiers
#[31] 12/10/2021 A.RUFFAULT :spira:99072 EST - IFRS17/EBS- Isolate pattern renewal procees in dedicated batch chain
#[32] 19/07/2023 D.TEIXEIRA :spira:110067 Saved or Restored if relaunch
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters

# Job Initialisation
JOBINIT

# Parameters
CONSOYEA=$1
CONSOMTH=$2
INVCONSO_D=$3
CRE_D=$4

#EPO_FTECLEDASO=${EPO_FTECLEDASO_CUR}  NON ! RC
#EPO_GTEP=${EPO_GTEPSO}

#COND1="Y" where @IsEpo =  'Y' and @IsEpo31_12 = 'Y' and @IsEpoComptaRequestF = 'Y' -- comptabilisation annuelle
#COND2="Y" where @nb_NoEBS > 0

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> CONSOYEA................: ${CONSOYEA}"
ECHO_LOG "#===> CONSOMTH................: ${CONSOMTH}"
ECHO_LOG "#===> INVCONSO_D..............: ${INVCONSO_D}"
ECHO_LOG "#===> CRE_D...................: ${CRE_D}"
ECHO_LOG "#===> COND1..COMPTA ANNUELLE..: ${EST_ESPD8830_COND1}"

ECHO_LOG "#===> EPO_FTECLEDASO..........: ${EPO_FTECLEDASO}"
ECHO_LOG "#===> EPO_FTECLEDASO_CUR......: ${EPO_FTECLEDASO_CUR}"
ECHO_LOG "#===> EPO_DLSGTRSO............: ${EPO_DLSGTRSO}"
ECHO_LOG "#===> EPO_DLREJGTAASO.........: ${EPO_DLREJGTAASO}"
ECHO_LOG "#===> EPO_DLREJGTARSO.........: ${EPO_DLREJGTARSO}"
ECHO_LOG "#===> EPO_DLREJGTRSO..........: ${EPO_DLREJGTRSO}"
ECHO_LOG "#===> EPO_DLREGTRSO...........: ${EPO_DLREGTRSO}"
ECHO_LOG "#===> EPO_DLREMAJGTRSO........: ${EPO_DLREMAJGTRSO}"

ECHO_LOG "#===> EST_CURGTA..............: ${EST_CURGTA}"
ECHO_LOG "#===> EST_CURGTR..............: ${EST_CURGTR}"
ECHO_LOG "#===> EST_STATGTA.............: ${EST_STATGTA}"
ECHO_LOG "#===> EST_STATGTR.............: ${EST_STATGTR}"
ECHO_LOG "#===> EST_ARCSTATGTA..........: ${EST_ARCSTATGTA}"
ECHO_LOG "#===> EST_ARCSTATGTR..........: ${EST_ARCSTATGTR}"
ECHO_LOG "#===> EST_GTA.................: ${EST_GTA}"
ECHO_LOG "#===> EST_GTR.................: ${EST_GTR}"
ECHO_LOG "#===> EPO_GTEP................: ${EPO_GTEP}"
ECHO_LOG "#===> EPO_CRVPERICASE0........: ${EPO_CRVPERICASE0}"
ECHO_LOG "#========================================================================="


#[32]
if [ -f ${DSAV}/${ENV_PREFIX}_ESPD8830_CURGTA_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz ]
then
  ECHO_LOG "#############################################################"
  ECHO_LOG "######           Restored because relaunched           ######"

  gunzip -c ${DSAV}/${ENV_PREFIX}_ESPD8830_CURGTA_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz > ${EST_CURGTA}
  gunzip -c ${DSAV}/${ENV_PREFIX}_ESPD8830_CURGTR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz > ${EST_CURGTR}
  gunzip -c ${DSAV}/${ENV_PREFIX}_ESPD8830_STATGTA_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz > ${EST_STATGTA}
  gunzip -c ${DSAV}/${ENV_PREFIX}_ESPD8830_STATGTR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz > ${EST_STATGTR}
  gunzip -c ${DSAV}/${ENV_PREFIX}_ESPD8830_ARCSTATGTA_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz > ${EST_ARCSTATGTA}
  gunzip -c ${DSAV}/${ENV_PREFIX}_ESPD8830_ARCSTATGTR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz > ${EST_ARCSTATGTR}
  gunzip -c ${DSAV}/${ENV_PREFIX}_ESPD8830_ARCSTATGTAR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz > ${EST_ARCSTATGTAR}
  gunzip -c ${DSAV}/${ENV_PREFIX}_ESPD8830_GTA_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz > ${EST_GTA}
  gunzip -c ${DSAV}/${ENV_PREFIX}_ESPD8830_GTR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz > ${EST_GTR}

  ECHO_LOG "###### ${EST_CURGTA}"
  ECHO_LOG "###### ${EST_CURGTR}"
  ECHO_LOG "###### ${EST_STATGTA}"
  ECHO_LOG "###### ${EST_STATGTR}"
  ECHO_LOG "###### ${EST_ARCSTATGTA}"
  ECHO_LOG "###### ${EST_ARCSTATGTR}"
  ECHO_LOG "###### ${EST_ARCSTATGTAR}"
  ECHO_LOG "###### ${EST_GTA}"
  ECHO_LOG "###### ${EST_GTR}"
  ECHO_LOG "#############################################################"
fi

#[32]
ECHO_LOG "#############################################################"
ECHO_LOG "######                Saved if relaunch                ######"

gzip -c ${EST_CURGTA} > ${DSAV}/${ENV_PREFIX}_ESPD8830_CURGTA_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz
gzip -c ${EST_CURGTR} > ${DSAV}/${ENV_PREFIX}_ESPD8830_CURGTR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz
gzip -c ${EST_STATGTA} > ${DSAV}/${ENV_PREFIX}_ESPD8830_STATGTA_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz
gzip -c ${EST_STATGTR} > ${DSAV}/${ENV_PREFIX}_ESPD8830_STATGTR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz
gzip -c ${EST_ARCSTATGTA} > ${DSAV}/${ENV_PREFIX}_ESPD8830_ARCSTATGTA_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz
gzip -c ${EST_ARCSTATGTR} > ${DSAV}/${ENV_PREFIX}_ESPD8830_ARCSTATGTR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz
gzip -c ${EST_ARCSTATGTAR} > ${DSAV}/${ENV_PREFIX}_ESPD8830_ARCSTATGTAR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz
gzip -c ${EST_GTA} > ${DSAV}/${ENV_PREFIX}_ESPD8830_GTA_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz
gzip -c ${EST_GTR} > ${DSAV}/${ENV_PREFIX}_ESPD8830_GTR_${NORME_CF}_${PARM_ICLODAT_D}.dat.gz

ECHO_LOG "###### ${EST_CURGTA}"
ECHO_LOG "###### ${EST_CURGTR}"
ECHO_LOG "###### ${EST_STATGTA}"
ECHO_LOG "###### ${EST_STATGTR}"
ECHO_LOG "###### ${EST_ARCSTATGTA}"
ECHO_LOG "###### ${EST_ARCSTATGTR}"
ECHO_LOG "###### ${EST_ARCSTATGTAR}"
ECHO_LOG "###### ${EST_GTA}"
ECHO_LOG "###### ${EST_GTR}"
ECHO_LOG "#############################################################"


#[004][005]
NSTEP=${NJOB}_00
# Begin Sort
#-----------------------------------------------------------------
LIBEL="reformat du ${EPO_FTECLEDASO_CUR} en fichier CURGTA - Donn�es du trimestre POSI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDASO_CUR} 1000  1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O1.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FORMAT_STANDARD      1:1 -  40:,
        PLUS_16_CHAMPS      88:1 - 103:,
        FILLER_14_COLS     105:1 - 118:
/DERIVEDFIELD ORICOD_LS "CURGTA_PO~"
/OUTFILE ${SORT_O}
/REFORMAT FORMAT_STANDARD, PLUS_16_CHAMPS, ORICOD_LS, FILLER_14_COLS
exit
EOF
SORT

##########################################################################
# Pr�paration du STATGTA - debut
##########################################################################

#[004] [016] [28]
NSTEP=${NJOB}_10
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Split DLSGTAASO + DLSGTARSO ==>  GTAA, GTAAR pour STATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_00_${IB}_SORT_CURGTA_O1.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O1.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O2.dat
SORT_O3=${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTAR_O3.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF       1:1 - 1:,
        BALSHEY      3:1 - 3: EN,
        BALSHTMTH    4:1 - 4: EN,
        TRNCOD_CF    6:1 - 6:,
        TRNCOD1_CF   6:1 - 6:1,
        TRNCOD2C_CF  6:2 - 6:2,
        TRNCOD8_CF   6:8 - 6:8
/CONDITION AVANT_PERIODE_ACC ( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH}) AND
                             ( TRNCOD1_CF = "1" or TRNCOD1_CF = "3") AND
                             ( TRNCOD8_CF  = "0" or TRNCOD8_CF  = "1" )
/CONDITION AVANT_PERIODE_RETRO ( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH}) AND
                               ( TRNCOD1_CF = "2" or TRNCOD1_CF = "4") AND
                               ( TRNCOD8_CF  = "0" or TRNCOD8_CF  = "1" )
/CONDITION ARCSTATGTAR ( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH}) AND
                         TRNCOD1_CF = "2" and TRNCOD8_CF = "0" 
/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE_ACC

/OUTFILE ${SORT_O2}
/INCLUDE AVANT_PERIODE_RETRO

/OUTFILE ${SORT_O3}
/INCLUDE ARCSTATGTAR

/COPY
exit
EOF
SORT

NSTEP=${NJOB}_20
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Sort CURGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_GTAR_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O1.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS RETCTR_NF   24:1 - 24:,
        RETEND_NT   25:1 - 25:,
        RETSEC_NF   26:1 - 26:,
        RTY_NF      27:1 - 27:,
        RETUW_NT    28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF ,
      RETUW_NT
exit
EOF
SORT

NSTEP=${NJOB}_30
#Dividing of STATGTR in retrocession by acceptance life and non-life
#-----------------------------------------------------------------------------
LIBEL="Eliminating Non-life transactions of GTAR"
PRG=ESTM7606
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_GTAR_O1.dat
export ${PRG}_I2=${EPO_CRVPERICASE0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DGTR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O2.dat
export ${PRG}_O3=${EPO_GTRANO}
EXECPRG

NSTEP=${NJOB}_35
# Omit EBS trncod
#-----------------------------------------------------------------------------
LIBEL="Omit EBS trncod on ${EPO_DLREGTRSO}"
AWK_I=${EPO_DLREGTRSO}
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLREGTRSO.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
    {
    	if (substr(\$6,2,1) != "A" && substr(\$6,2,1) != "E" && substr(\$6,2,1) != "J" && substr(\$6,2,1) != "G" && 
    		  substr(\$6,8,1) != "G" && substr(\$6,8,1) != "H")
    		print \$0;
    }
exit
EOF
AWK

##########################################################################
# Pr�paration du STATGTA - fin
##########################################################################

if [ "${PARM_IS_YEARLY}" = "N" ]
then

	##########################################################################
  ECHO_LOG "#===> COMPTABILISATION TRIMESTRIELLE NON ANNUELLE POS IFRS"
	##########################################################################

  #[004]
  NSTEP=${NJOB}_40
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_CURGTA} + Donn�es du trimestre -> CURGTA"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_CURGTA} 1000 1"
  SORT_I2="${DFILT}/${NJOB}_00_${IB}_SORT_CURGTA_O1.dat 1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_CURGTA_O.dat
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
  SORT

  #[011] [012] [015]
  NSTEP=${NJOB}_50
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_CURGTR} ... -> CURGTR"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_CURGTR}  1000 1"
  SORT_I2="${EPO_DLSGTRSO} 1000 1"
  SORT_I3="${DFILT}/${NJOB}_35_${IB}_AWK_DLREGTRSO.dat  1000 1"
  SORT_I4="${EPO_DLREMAJGTRSO}  1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_CURGTR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FIELD1       1:1 - 40:,
        FIN_COLS    42:1 - 71:
/DERIVEDFIELD RETINTAMT "0.000~"
/OUTFILE ${SORT_O}
/REFORMAT FIELD1,RETINTAMT,FIN_COLS
exit
EOF
  SORT

  NSTEP=${NJOB}_60
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation & SORT of files ${EST_STATGTA}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_GTAA_O1.dat 512 1"
  SORT_I2="${DFILT}/${NJOB}_30_${IB}_ESTM7606_GTAR_O2.dat 512 1"
  SORT_I3="${EST_STATGTA} 512 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_STATGTA_O.dat 512 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
  CTR_NF 8:1 - 8:,
  END_NT 9:1 - 9:,
  SEC_NF 10:1 - 10:,
  UWY_NF 11:1 - 11:,
  UW_NT 12:1 - 12:,
  OCCYEA_NF 13:1 - 13:,
  ACY_NF 14:1 - 14:,
  SCOSTRMTH_NF 15:1 - 15:,
  SCOENDMTH_NF 16:1 - 16:,
  CLM_NF 17:1 - 17:,
  CUR_CF 18:1 - 18:,
  RETCTR_NF 24:1 - 24:,
  RETEND_NT 25:1 - 25:,
  RETSEC_NF 26:1 - 26:,
  RTY_NF 27:1 - 27:,
  RETUW_NT 28:1 - 28:
/KEYS
        CTR_NF ,
        END_NT ,
        SEC_NF ,
        UWY_NF ,
        UW_NT ,
        OCCYEA_NF ,
        ACY_NF ,
        SCOSTRMTH_NF ,
        SCOENDMTH_NF ,
        CLM_NF,
        CUR_CF
exit
EOF
  SORT

  #[011] [012] [015]
  NSTEP=${NJOB}_70
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_STATGTR} with DLSGTRSO, DLREGTRSO, DLREMAJGTRSO"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_STATGTR}  1000 1"
  SORT_I2="${EPO_DLSGTRSO} 1000 1"
  SORT_I3="${DFILT}/${NJOB}_35_${IB}_AWK_DLREGTRSO.dat  1000 1"
  SORT_I4="${EPO_DLREMAJGTRSO}  1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_STATGTR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FIELD1       1:1 - 40:,
        FIN_COLS    42:1 - 71:
/DERIVEDFIELD RETINTAMT "0.000~"
/OUTFILE ${SORT_O}
/REFORMAT FIELD1, RETINTAMT, FIN_COLS
exit
EOF
  SORT

  NSTEP=${NJOB}_80
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_CURGTA + DLSGTAxSO ==> EST_CURGTA"
  EXECKSH "mv ${DFILT}/${NJOB}_40_${IB}_CURGTA_O.dat ${EST_CURGTA}"

  NSTEP=${NJOB}_90
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_CURGTR + ${DFILT}/${NJOB}_50_${IB}_CURGTR_O.dat ==> EST_CURGTR"
  EXECKSH "mv ${DFILT}/${NJOB}_50_${IB}_CURGTR_O.dat ${EST_CURGTR}"

  NSTEP=${NJOB}_100
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_STATGTA + DLSGTAxSO ==> EST_STATGTA"
  EXECKSH "mv ${DFILT}/${NJOB}_60_${IB}_STATGTA_O.dat ${EST_STATGTA}"

  NSTEP=${NJOB}_110
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_STATGTR + ${DFILT}/${NJOB}_70_${IB}_STATGTR_O.dat ==> EST_STATGTR"
  EXECKSH "mv ${DFILT}/${NJOB}_70_${IB}_STATGTR_O.dat ${EST_STATGTR}"
  
	#[26]
	##########################################################################
  ECHO_LOG "#===> Sauvegarde fchiers ajoutes dans CURGTx"
	##########################################################################
	gzip -c ${DFILT}/${NJOB}_00_${IB}_SORT_CURGTA_O1.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTA_AjoutDuPOSI_${INVCONSO_D}_${CRE_D}.dat.gz
	cat ${EPO_DLSGTRSO} ${DFILT}/${NJOB}_35_${IB}_AWK_DLREGTRSO.dat ${EPO_DLREMAJGTRSO} > ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_AjoutDuPOSI_${INVCONSO_D}_${CRE_D}.dat
	gzip -c ${DFILT}/${ENV_PREFIX}_ESIX7000_CURGTR_AjoutDuPOSI_${INVCONSO_D}_${CRE_D}.dat > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_AjoutDuPOSI_${INVCONSO_D}_${CRE_D}.dat.gz

fi

if [ ${PARM_IS_YEARLY} = "Y" ]
then

	##########################################################################
  ECHO_LOG "#===> COMPTABILISATION ANNUELLE POS IFRS"
	##########################################################################

  NSTEP=${NJOB}_120  
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files GTAx"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_GTAA_O1.dat 512 1"
  SORT_I2="${DFILT}/${NJOB}_30_${IB}_ESTM7606_GTAR_O2.dat 512 1"
  SORT_I3="${EST_ARCSTATGTA} 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTA_O.dat 1000 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
  SSD_CF 1:1 - 1:,
  ESB_CF 2:1 - 2:,
  BALSHEY_NF 3:1 - 3:,
  BALSHRMTH_NF 4:1 - 4:,
  BALSHRDAY_NF 5:1 - 5:,
  TRNCOD_CF 6:1 - 6:,
  TRNCOD1_CF 6:1 - 6:1,
  TRNCOD8_CF 6:8 - 6:8 EN ,
  DBLTRNCOD_CF 7:1 - 7:,
  CTR_NF 8:1 - 8:,
  END_NT 9:1 - 9:,
  SEC_NF 10:1 - 10:,
  UWY_NF 11:1 - 11:,
  UW_NT 12:1 - 12:,
  OCCYEA_NF 13:1 - 13:,
  ACY_NF 14:1 - 14:,
  SCOSTRMTH_NF 15:1 - 15:,
  SCOENDMTH_NF 16:1 - 16:,
  CLM_NF 17:1 - 17:,
  CUR_CF 18:1 - 18:,
  AMT_M 19:1 - 19:EN 15/3,
  CED_NF 20:1 - 20:,
  BRK_NF 21:1 - 21:,
  PAY_NF 22:1 - 22:,
  KEY_NF 23:1 - 23:,
  RETCTR_NF 24:1 - 24:,
  RETEND_NT 25:1 - 25:,
  RETSEC_NF 26:1 - 26:,
  RTY_NF 27:1 - 27:,
  RETUW_NT 28:1 - 28:,
  RETOCCYEA_NF 29:1 - 29:,
  RETACY_NF 30:1 - 30:,
  RETSCOSTRMTH_NF 31:1 - 31:,
  RETSCOENDMTH_NF 32:1 - 32:,
  RCL_NF 33:1 - 33:,
  RETCUR_CF 34:1 - 34:,
  RETAMT_M 35:1 - 35:EN 15/3,
  PLC_NT 36:1 - 36:,
  RTO_NF 37:1 - 37:,
  INT_NF 38:1 - 38:,
  RETPAY_NF 39:1 - 39:,
  RETKEY_CF 40:1 - 40:,
  RETINTAMT_M 41:1 - 41:EN 15/3
/KEYS
  CTR_NF ,
  END_NT ,
  SEC_NF ,
  UWY_NF ,
  UW_NT ,
  OCCYEA_NF ,
  ACY_NF ,
  SCOSTRMTH_NF ,
  SCOENDMTH_NF ,
  CLM_NF,
  CUR_CF,
  RETCTR_NF,
  RETEND_NT,
  RETSEC_NF,
  RTY_NF ,
  RETUW_NT,
  SSD_CF ,
  ESB_CF ,
  BALSHEY_NF,
  TRNCOD_CF,
  DBLTRNCOD_CF ,
  CED_NF ,
  BRK_NF ,
  PAY_NF ,
  KEY_NF ,
  RETOCCYEA_NF ,
  RETACY_NF ,
  RETSCOSTRMTH_NF ,
  RETSCOENDMTH_NF ,
  RCL_NF ,
  RETCUR_CF ,
  PLC_NT ,
  RTO_NF ,
  INT_NF ,
  RETPAY_NF ,
  RETKEY_CF
exit
EOF
  SORT

  #[011] [012] [015] [016]
  NSTEP=${NJOB}_130  
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="${EPO_FTECLEDRSO} ==> CURGTR"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EPO_DLSGTRSO} 1000 1"
  SORT_I2="${DFILT}/${NJOB}_35_${IB}_AWK_DLREGTRSO.dat  1000 1"
  SORT_I3="${EPO_DLREMAJGTRSO}  1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTR_O.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY      3:1 -  3: EN,
        BALSHTMTH    4:1 -  4: EN,
        TRNCOD_CF    6:1 -  6:,
        TRNCOD1_CF   6:1 -  6:1,
        TRNCOD2C_CF  6:2 -  6:2,
        TRNCOD8_CF   6:8 -  6:8,
        FIELD1       1:1 - 40:,
        FIN_COLS    42:1 - 71:
/CONDITION AVANT_PERIODE  ( BALSHEY = ${CONSOYEA} and BALSHTMTH <= ${CONSOMTH})
/DERIVEDFIELD RETINTAMT "0.000~"
/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE
/REFORMAT FIELD1, RETINTAMT, FIN_COLS
/COPY
exit
EOF
  SORT

  NSTEP=${NJOB}_140  
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="SORT GTR "
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_130_${IB}_SORT_CURGTR_O.dat 1000 1"
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTR_O.dat"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF    27:1 - 27:,
        RETUW_NT  28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF ,
      RETUW_NT
exit
EOF
  SORT

  NSTEP=${NJOB}_150
  #Dividing of STATGTR in retrocession by acceptance life and non-life
  #-----------------------------------------------------------------------------
  LIBEL="Eliminating Non-life transactions of GTR"
  PRG=ESTM7606
  export ${PRG}_I1=${DFILT}/${NJOB}_140_${IB}_SORT_GTR_O.dat
  export ${PRG}_I2=${EPO_CRVPERICASE0}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DGTR_O1.dat
  export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O2.dat
  export ${PRG}_O3=${EPO_GTRANO}
  EXECPRG

  NSTEP=${NJOB}_160
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_ARCSTATGTR} ${EPO_FTECLEDR}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${DFILT}/${NJOB}_150_${IB}_ESTM7606_GTR_O2.dat 1000 1"
  SORT_I2="${EST_ARCSTATGTR} 1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS
  RETCTR_NF 24:1 - 24:,
  RETEND_NT 25:1 - 25:,
  RETSEC_NF 26:1 - 26:,
  RTY_NF 27:1 - 27:,
  RETUW_NT 28:1 - 28:
/KEYS
  RETCTR_NF,
  RETEND_NT,
  RETSEC_NF,
  RTY_NF ,
  RETUW_NT
exit
EOF
  SORT

  NSTEP=${NJOB}_170
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_GTA} ${EPO_DLREJGTAASO} ${EPO_DLREJGTARSO}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_GTA} 1000 1"
  SORT_I2="${EPO_DLREJGTAASO} 1000 1"
  SORT_I3="${EPO_DLREJGTARSO} 1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_GTA_O.dat
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
  SORT

  NSTEP=${NJOB}_180
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_GTR} ${EPO_DLREJGTRSO}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EPO_DLREJGTRSO} 1000 1"
  SORT_I2="${EST_GTR}  1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_GTR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
  SORT

	#[28]
	NSTEP=${NJOB}_185
	# Accumulation of GATR amounts and merge with ARCSTATGTAR
	#------------------------------------------------------------------------------
	LIBEL="Accumulation of GTAR amounts and merge with old ARCSTATGTAR"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_ARCSTATGTAR_O3.dat 800 1"
	SORT_I2="${EST_ARCSTATGTAR} 800 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTAR_O.dat 800 1"
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
  SSD_CF 1:1 - 1:,
  ESB_CF 2:1 - 2:,
  BALSHEY_NF 3:1 - 3:,
  BALSHRMTH_NF 4:1 - 4:,
  BALSHRDAY_NF 5:1 - 5:,
  TRNCOD_CF 6:1 - 6:,
  TRNCOD1_CF 6:1 - 6:1,
  TRNCOD8_CF 6:8 - 6:8,
  DBLTRNCOD_CF 7:1 - 7:,
  CTR_NF 8:1 - 8:,
  END_NT 9:1 - 9:,
  SEC_NF 10:1 - 10:,
  UWY_NF 11:1 - 11:,
  UW_NT 12:1 - 12:,
  OCCYEA_NF 13:1 - 13:,
  ACY_NF 14:1 - 14:,
  SCOSTRMTH_NF 15:1 - 15:,
  SCOENDMTH_NF 16:1 - 16:,
  CLM_NF 17:1 - 17:,
  CUR_CF 18:1 - 18:,
  AMT_M 19:1 - 19:EN 15/3,
  CED_NF 20:1 - 20:,
  BRK_NF 21:1 - 21:,
  PAY_NF 22:1 - 22:,
  KEY_NF 23:1 - 23:,
  RETCTR_NF 24:1 - 24:,
  RETEND_NT 25:1 - 25:,
  RETSEC_NF 26:1 - 26:,
  RTY_NF 27:1 - 27:,
  RETUW_NT 28:1 - 28:,
  RETOCCYEA_NF 29:1 - 29:,
  RETACY_NF 30:1 - 30:,
  RETSCOSTRMTH_NF 31:1 - 31:,
  RETSCOENDMTH_NF 32:1 - 32:,
  RCL_NF 33:1 - 33:,
  RETCUR_CF 34:1 - 34:,
  RETAMT_M 35:1 - 35:EN 15/3,
  PLC_NT 36:1 - 36:,
  RTO_NF 37:1 - 37:,
  INT_NF 38:1 - 38:,
  RETPAY_NF 39:1 - 39:,
  RETKEY_CF 40:1 - 40:,
  RETINTAMT_M 41:1 - 41:EN 15/3,
  cols1  1:1 -  3:,
  cols2  6:1 - 18:,
  cols3 20:1 - 34:,
  cols4 36:1 - 40:,
  cols5 42:1 - 71:
/KEYS
  SSD_CF ,
  ESB_CF ,
  BALSHEY_NF,
  TRNCOD_CF,
  DBLTRNCOD_CF ,
  CTR_NF ,
  END_NT ,
  SEC_NF ,
  UWY_NF ,
  UW_NT ,
  OCCYEA_NF ,
  ACY_NF ,
  SCOSTRMTH_NF ,
  SCOENDMTH_NF ,
  CLM_NF ,
  CUR_CF ,
  CED_NF ,
  BRK_NF ,
  PAY_NF ,
  KEY_NF ,
  RETCTR_NF ,
  RETEND_NT ,
  RETSEC_NF ,
  RTY_NF ,
  RETUW_NT ,
  RETOCCYEA_NF ,
  RETACY_NF ,
  RETSCOSTRMTH_NF ,
  RETSCOENDMTH_NF ,
  RCL_NF ,
  RETCUR_CF ,
  PLC_NT ,
  RTO_NF ,
  INT_NF ,
  RETPAY_NF ,
  RETKEY_CF
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
/CONDITION AR TRNCOD1_CF = "2" and TRNCOD8_CF = "0"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD MONTH "12~31~"
/OUTFILE ${SORT_O}
/INCLUDE AR
/REFORMAT cols1, MONTH, cols2, AMT_MC, cols3, RETAMT_MC, cols4, RETINTAMT_MC, cols5
exit
EOF
	SORT

  NSTEP=${NJOB}_190
  # Begin sort
  #----------------------------------------------------------------------------
  LIBEL="move EST_ARCSTATGTA + DLSGTAxSO ==> EST_ARCSTATGTA"
  EXECKSH "mv ${DFILT}/${NJOB}_120_${IB}_SORT_ARCSTATGTA_O.dat ${EST_ARCSTATGTA}"

  NSTEP=${NJOB}_200
  # Begin sort
  #----------------------------------------------------------------------------
  LIBEL="move EST_ARCSTATGTR + DLSGTRSO ==> EST_ARCSTATGTR"
  EXECKSH "mv ${DFILT}/${NJOB}_160_${IB}_SORT_ARCSTATGTR_O.dat ${EST_ARCSTATGTR}"

	#[28]
  NSTEP=${NJOB}_205
  # Begin sort
  #----------------------------------------------------------------------------
  LIBEL="move EST_ARCSTATGTAR + CURGTA ==> EST_ARCSTATGTAR"
  EXECKSH "mv ${DFILT}/${NJOB}_185_${IB}_SORT_ARCSTATGTAR_O.dat ${EST_ARCSTATGTAR}"

  NSTEP=${NJOB}_210
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_GTA + DLREJGTAxSO ==> EST_GTA"
  EXECKSH "mv ${DFILT}/${NJOB}_170_${IB}_GTA_O.dat ${EST_GTA}"

  NSTEP=${NJOB}_220
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_GTR + EPO_DLREJGTRSO ==> EST_GTR"
  EXECKSH "mv ${DFILT}/${NJOB}_180_${IB}_GTR_O.dat ${EST_GTR}"

fi

##[31]
##NSTEP=${NJOB}_230
###-----------------------------------------------------------------------------
##LIBEL="table TPATSEGSII CLOSING_D update"
##ISQL_BASE="BEST"
##ISQL_QRY="exec PuSOLVENCY_02 '${INVCONSO_D}', '${CRE_D}', 'INV'"
##ISQL

NSTEP=${NJOB}_240
#----------------------------------------------------------------------------
LIBEL="Connect on the infocenter server"
SWITCH_SRV ${SRV_2}

##[31]
##NSTEP=${NJOB}_250
###-----------------------------------------------------------------------------
##LIBEL="table TPATSEGSII CLOSING_D update"
##ISQL_BASE="BEST"
##ISQL_QRY="exec PuSOLVENCY_02 '${INVCONSO_D}', '${CRE_D}', 'INV'"
##ISQL

##[25]
#NSTEP=${NJOB}_260
##------------------------------------------------------------------------------
#LIBEL="Get ESB from Pericase for FTECLEDASO"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EPO_FTECLEDASO} 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDASO.dat 1000 1 "
#INPUT_TEXT ${SORT_CMD} << EOF
#/FIELDS SSD_CF           1:1 -  1:,
#        ESB_CF           2:1 -  2:,
#        CTR_NF           8:1 -  8:,
#        END_NT           9:1 -  9:,
#        SEC_NF          10:1 - 10:,
#        UWY_NF          11:1 - 11:,
#        UW_NT           12:1 - 12:,
#        all_cols1        1:1 - 118:,
#        PER_SSD_CF       1:1 -  1:,
#        PER_CTR_NF       3:1 -  3:,
#        PER_END_NT       4:1 -  4:,
#        PER_SEC_NF       5:1 -  5:,
#        PER_UWY_NF       6:1 -  6:,
#        PER_UW_NT        7:1 -  7:,
#        PER_ESB_CF       8:1 -  8:
#/joinkeys
#        CTR_NF
#       ,END_NT
#       ,SEC_NF
#       ,UWY_NF
#       ,UW_NT 
#/INFILE ${EPO_OIADVPERICASE} 1000 1 "~"
#/joinkeys
#        PER_CTR_NF
#       ,PER_END_NT
#       ,PER_SEC_NF
#       ,PER_UWY_NF
#       ,PER_UW_NT 
#/JOIN UNPAIRED LEFTSIDE
#/OUTFILE   ${SORT_O}
#/REFORMAT
#        leftside:all_cols1
#       ,rightside:PER_ESB_CF
#exit
#EOF
#SORT
#
##[25] [27]
#NSTEP=${NJOB}_270
##------------------------------------------------------------------------------
#LIBEL="Replace ESB from Pericase to FTECLEDASO Cumul"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_260_${IB}_SORT_FTECLEDASO.dat 1000 1 "
#SORT_O="${EPO_FTECLEDASO_EBS} 1000 1"
#INPUT_TEXT ${SORT_CMD} << EOF
#/FIELDS SSD_CF           1:1 -   1:,
#        ESB_CF           2:1 -   2:,
#        TRNCOD1_CF       6:1 -   6:1,
#        CTR_NF           8:1 -   8:,
#        END_NT           9:1 -   9:,
#        SEC_NF          10:1 -  10:,
#        UWY_NF          11:1 -  11:,
#        UW_NT           12:1 -  12:,
#        all_cols1        3:1 - 118:,
#        PER_ESB_CF     119:1 - 119:
#/CONDITION blanc PER_ESB_CF = "" OR TRNCOD1_CF = "2" OR TRNCOD1_CF = "4"
#/DERIVEDFIELD PER2_ESB_CF if blanc then ESB_CF else PER_ESB_CF
#/OUTFILE   ${SORT_O}
#/REFORMAT SSD_CF, PER2_ESB_CF, all_cols1
#exit
#EOF
#SORT

########################
# save files #
########################

#[007] [20] [25]
NSTEP=${NJOB}_280
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree"
EXECKSH_MODE=P
#[19]
#(gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO.dat     > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_${INVCONSO_D}_${CRE_D}.dat.gz
#(gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO.dat     > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDRSO_${INVCONSO_D}_${CRE_D}.dat.gz
#(gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3900_FCTRSTATSO.dat     > ${DARCH}/${ENV_PREFIX}_ESPD3900_FCTRSTATSO_${INVCONSO_D}_${CRE_D}.dat.gz
#(gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3900_FSEGSTATSO.dat     > ${DARCH}/${ENV_PREFIX}_ESPD3900_FSEGSTATSO_${INVCONSO_D}_${CRE_D}.dat.gz
#(gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_CUR.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_CUR_${INVCONSO_D}_${CRE_D}.dat.gz
#(gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_MVT.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_MVT_${INVCONSO_D}_${CRE_D}.dat.gz
#(gzip -c ${DFILP}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_EBS.dat > ${DARCH}/${ENV_PREFIX}_ESPD3800_FTECLEDASO_EBS_${INVCONSO_D}_${CRE_D}.dat.gz

#[29]
gzip -c  ${EPO_FTECLEDASO} 	>> `echo ${EPO_FTECLEDASO} 	| sed s/perm/arch/`.gz
gzip -c  ${EPO_FTECLEDRSO} 	>> `echo ${EPO_FTECLEDRSO} 	| sed s/perm/arch/`.gz
gzip -c  ${EPO_FCTRSTATSO} 	>> `echo ${EPO_FCTRSTATSO} 	| sed s/perm/arch/`.gz
gzip -c  ${EPO_FSEGSTATSO} 	>> `echo ${EPO_FSEGSTATSO} 	| sed s/perm/arch/`.gz
gzip -c  ${EPO_FTECLEDASO_CUR}  >> `echo ${EPO_FTECLEDASO_CUR} | sed s/perm/arch/`.gz
gzip -c  ${EPO_FTECLEDASO_MVT}  >> `echo ${EPO_FTECLEDASO_MVT} | sed s/perm/arch/`.gz
gzip -c  ${EPO_FTECLEDASO_EBS}  >> `echo ${EPO_FTECLEDASO_EBS} | sed s/perm/arch/`.gz


#[013]
RMFIL "${EPO_FTECLEDASO_CUR}"
EXECKSH "touch ${EPO_FTECLEDASO_CUR}"

#[012] [21] [28]
#gzip -c ${EPO_DLSGTRSO}     > ${DARCH}/${ENV_PREFIX}_ESPD1800_DLSGTRSO_${INVCONSO_D}_${CRE_D}.dat.gz
#gzip -c ${EPO_DLREGTRSO}    > ${DARCH}/${ENV_PREFIX}_ESPD2500_DLREGTRSO_${INVCONSO_D}_${CRE_D}.dat.gz
#gzip -c ${EPO_DLREMAJGTRSO} > ${DARCH}/${ENV_PREFIX}_ESPD2500_DLREMAJGTRSO_${INVCONSO_D}_${CRE_D}.dat.gz
#gzip -c ${EPO_GTEP}         > ${DARCH}/${ENV_PREFIX}_ESPD4000_GTEPSO_${INVCONSO_D}_${CRE_D}.dat.gz
#gzip -c ${EPO_DLEIGTAA}     > ${DARCH}/${ENV_PREFIX}_ESPD2550_DLEIGTAA_${INVCONSO_D}_${CRE_D}.dat.gz
#gzip -c ${EPO_DLRGTAASO}    > ${DARCH}/${ENV_PREFIX}_ESPD2550_DLRGTAASO_${INVCONSO_D}_${CRE_D}.dat.gz
#gzip -c ${EPO_CRVPERICASE0} > ${DARCH}/${ENV_PREFIX}_ESID7000_CRVPERICASE0_${INVCONSO_D}_${CRE_D}.dat.gz

#[29]
#gzip -c  ${EPO_DLSGTRSO}     	>> `echo ${EPO_DLSGTRSO}     	| sed s/perm/arch/`.gz
#gzip -c  ${EPO_DLREGTRSO}    	>> `echo ${EPO_DLREGTRSO}    	| sed s/perm/arch/`.gz
#gzip -c  ${EPO_DLREMAJGTRSO} 	>> `echo ${EPO_DLREMAJGTRSO} 	| sed s/perm/arch/`.gz
#gzip -c  ${EPO_GTEP}         	>> `echo ${EPO_GTEP}         	| sed s/perm/arch/`.gz
#gzip -c  ${EPO_DLEIGTAA}     	>> `echo ${EPO_DLEIGTAA}     	| sed s/perm/arch/`.gz
#gzip -c  ${EPO_DLRGTAASO}    	>> `echo ${EPO_DLRGTAASO}    	| sed s/perm/arch/`.gz
#gzip -c  ${EPO_CRVPERICASE0} 	>> `echo ${EPO_CRVPERICASE0} 	| sed s/perm/arch/`.gz

gzip -c  ${EPO_DLSGTRSO}     	> ${EPO_DLSGTRSO_ARC}    
gzip -c  ${EPO_DLREGTRSO}    	> ${EPO_DLREGTRSO_ARC}   
gzip -c  ${EPO_DLREMAJGTRSO} 	> ${EPO_DLREMAJGTRSO_ARC}
gzip -c  ${EPO_GTEP}         	> ${EPO_GTEP_ARC}        
gzip -c  ${EPO_DLEIGTAA}     	> ${EPO_DLEIGTAA_ARC}    
gzip -c  ${EPO_DLRGTAASO}    	> ${EPO_DLRGTAASO_ARC}   
gzip -c  ${EPO_CRVPERICASE0} 	> ${EPO_CRVPERICASE0_ARC}

RMFIL ${EPO_GTEP}
RMFIL ${EPO_DLEIGTAA}
RMFIL ${EPO_DLRGTAASO}

touch ${EPO_GTEP}
touch ${EPO_DLEIGTAA}
touch ${EPO_DLRGTAASO}

NSTEP=${NJOB}_300
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
