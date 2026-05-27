#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Mise a jour des previsions
# nom du script SHELL           : ESID7001.cmd
# revision                      : $Revision: 1.8 $
# date de creation              : 26/05/97
# auteur                        : M.NAJI
# references des specifications : ESARC02F.doc
#-----------------------------------------------------------------------------
# description
#   Update estimates
#
# job launched by ESID7000.cmd
#-----------------------------------------------------------------------------
# historique des modifications
#     14/05/98  Par Mehdi NAJI
#     11/02/03  Par J. ribot gestion colonne retintamt_m
#                            ajout step70 107
#                            modif step80 110
#     05/01/04  Par M. DJELLOULI
#                            Maj des Ultimes par Creation Compte Complet
#                            Ajout du STEP 157
#     12/08/04  Par M. DJELLOULI
#                            Modification Ventilation Non Prop - STEP 155
#     20/02/2006  M.DJELLOULI   SPOT 12055 - Integration TVENTNPHIS
#                            Ajout STEP_02 -  REformat EST_FTVENTNPHIS avec BALSHEYEA et BALSHTMTH
#                            Ajout STEP_03 -  BCP in de EST_FTVENTNPHIS dans BRET..TVENTNPHIS
#                            Modification STEP_25 -  RMFIL "${EST_FTVENTNPHIS}"
#     26/12/2007  J. Ribot   SPOT 14784 modif sur alimentation Du MGTAR
#                            Ajout test SSD_CF EQ "20" sur cond du CMGTAR STEP55
#_________________
#MODIFICATION    [007]
#Auteur:         D.GATIBELZA
#Date:           29/03/2010
#Version:        10.1
#Description:    ESTVIE18710 Alimentation du MGTAR lors de la comptabilisation de l'arrêté pour la réallocation asie
#_________________
#MODIFICATION    [008]
#Auteur:         D.GATIBELZA
#Date:           29/03/2010
#Version:        10.1
#Description:    ESTDOM19222 Interface Retro Omega PeopleSoft
#_________________
#   09/09/2010 - JF VDV - [19210] - Ecart GTA/GTR Suppression des postes financiers et depots
#                                 step55 CONDITION COND_CMGTAR
#   21/09/2010 - D.GATIBELZA - Correction bug
#   15/10/2010 - JF VDV - [19210] - Suppression du filtre des postes financiers et depots dans la condition du tri au step55
#                                   Remplacer par un nouveau filtre dans le programme ESTM2563.c (step 60)
#[012]  09/03/2011  R. CASSIS     :spot:21408 - Modification du Ftecleda par FTECLEDA_MVT
#                	                               Déplacement des steps 2 à 51 dans ESID7051.
#[013]  30/11/2011  R. CASSIS     :spot:22859 - Archivage fichiers CURGTACTL et STATGTACTL
#[014]  14/12/2011  R. CASSIS     :spot:22862 - On ne prend plus IGTA et IGTR en entree mais GTA et GTR et les DLT..
#[015]  14/11/2012  P. PEZOUT     :spot:24041 - Ajout des lignes EBS lors de la comptabilisation STEP 60..
#[016]  25/06/2012  Ph Pezout     :spot:24904 - correction du step 61
#[017]  18/06/2014  R. Cassis     :spot:27172 - Archivage de fichiers GT..
#[018]  18/06/2014  R. Cassis     :spot:27172 - Archivage de fichiers GT..
#[019]  07/10/2014  R. Cassis     :spot:27568 - sort on non numeric trncod suffix to consider solvency alpha suffix
#[020]  30/06/2015  DFI           :spot:28947 - filtre des analytiques dans la generation de l'interface 1GL
#[021]  09/12/2016  E. CHATAIN    :spot:29066 - formatage du fichier GT
#[022]  27/05/2016  R. cassis     :spot:30635 - Correction syntaxe commande
#[023]  18/07/2016  R. cassis     :spot:29629 - gestion de l'allocation Rétro des NP
#[024]  18/08/2016  R. cassis     :spot:30152 - En comptabilisation IFRS annuelle, les ouvertures EBS ne doivent pas etre reconduites ici.
#[025]  23/05/2017  R. Cassis     :Spira:60187 Ajout Test de condition 3 sur ESID7000 (compta trimestrielle) pour fichiers EST_VENTNP
#[026]  07/12/2017  R. Cassis     :spira:66334 Les fichiers perimetre ES Local sont maintenant générés dans le ESID7000
#[027]  07/12/2017  R. Cassis     :spira:66334 Les fichiers perimetre ES Local sont nommés ESL_ sont maintenant générés dans le ESID7000
#[028]  04/01/2021  R. Cassis     :spira:92262 Mise a jour de l'ARCSTATGTAR a partir du CURGTA et de l'ancien. Archivage _MTH - suppression affectations en fin de job
#===================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
BALSHEYEA=$1
BALSHTMTH=$2

# Job Initialisation
JOBINIT

export BALSHEYEAS=$((${BALSHEYEA}+1))
BALSHTMTH2=`echo "${BALSHTMTH}" | awk '{ if (length($0) < 2) print "0" $0; else print $0;}'`
datej=`date '+%Y%m%d%H%M%S'`

NSTEP=${NJOB}_55
# Begin sort
#[008] Ajout filiale 22
#[009]
#[014]
#[019]
#----------------------------------------------------------------------------
LIBEL="Split GTA + CURGTA ==> delta(CURGTA), DLTOTGTAAC, DLTOGTARC, GTA-CURGTA, GTAA, GTAAR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_IGTA} 800 1"
SORT_I="${EST_GTA} 800 1"
if [ ${EST_ESID7000_COND1} = "Y" ]
then
    # COMPTA TRIMESTRIELLE
    SORT_I2="${EST_DLTOTGTAA} 800  1"
    SORT_I3="${EST_DLTOTGTAR} 800  1"
fi
if [ ${EST_ESID7000_COND2} = "Y" ]
then
  # COMPTA ANNUELLE
    SORT_I4="${EST_DLREJGTAA} 800  1"
    SORT_I5="${EST_DLREJGTAR} 800  1"
fi
SORT_O="${EST_DLTOTGTAAC} OVERWRITE"
SORT_O2="${EST_DLTOTGTARC} OVERWRITE"
SORT_O3=${DFILT}/${NSTEP}_${IB}_SORT_GTA_O4.dat
SORT_O4="${EST_ANOBALSHEYGT} APPEND"
SORT_O5="${EST_GTACTL} OVERWRITE"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF       1:1 - 1:,
        ESB_CF       2:1 - 2:,
        BALSHEY      3:1 - 3: EN,
        BALSHTMTH    4:1 - 4: EN,
        TRNCOD_CF    6:1 - 6:,
        TRNCOD1_CF   6:1 - 6:1,
        TRNCOD2C_CF  6:2 - 6:2,
        TRNCOD3      6:3 - 6:3,
        TRNCOD8_CF   6:8 - 6:8
/CONDITION ANO                  BALSHEY < ${BALSHEYEA}
/CONDITION APRES_PERIODE      BALSHEY > ${BALSHEYEA}      or
                                ( BALSHEY = ${BALSHEYEA}    and     BALSHTMTH > ${BALSHTMTH} )
/CONDITION COND_DLTOGTAAC       ( ( BALSHEY = ${BALSHEYEAS} and     BALSHTMTH = 1 )     OR
                                  ( BALSHEY = ${BALSHEYEA}  and     BALSHTMTH <= ${BALSHTMTH} ) )   AND
                                ( TRNCOD8_CF  > "1"         or      "SCORITAEJ456789" CT TRNCOD2C_CF ) AND
                                ( TRNCOD1_CF  = "1"         or      TRNCOD1_CF  = "3" )
/CONDITION COND_DLTOGTARC       ( ( BALSHEY = ${BALSHEYEAS} and     BALSHTMTH = 1 )     OR
                                  ( BALSHEY = ${BALSHEYEA}  and     BALSHTMTH <= ${BALSHTMTH} ) )   AND
                                ( TRNCOD8_CF  > "1"         or      "SCORITAEJ456789" CT TRNCOD2C_CF ) AND
                                ( TRNCOD1_CF = "2"          or      TRNCOD1_CF  = "4" )

/OUTFILE ${SORT_O}
/INCLUDE COND_DLTOGTAAC

/OUTFILE ${SORT_O2}
/INCLUDE COND_DLTOGTARC

/OUTFILE ${SORT_O3}
/INCLUDE APRES_PERIODE

/OUTFILE ${SORT_O4}
/INCLUDE ANO

/OUTFILE ${SORT_O5}

/COPY
exit
EOF
SORT

#[020] Suppression step 60 et step 61 + renommage step 62 en step60
#[012]
#[019]
NSTEP=${NJOB}_60
#Php
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Extraction des mouvements de la période comptabilisés à partir du FTECLEDA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA_MVT} 800  1"
SORT_I2="${EST_FTECLEDA_MTH} 800  1"  # [020]
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTA_O1.dat
SORT_O1=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O5.dat
SORT_O2=${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O6.dat
INPUT_TEXT $SORT_CMD << EOF
/FIELDS FORMAT_STANDARD     1:1 -  40:,
        BALSHEY             3:1 -   3: EN,
        BALSHTMTH           4:1 -   4: EN,
        BALSHTDAY           5:1 -   5: EN,
        TRNCOD_CF           6:1 -   6:,
        TRNCOD1_CF          6:1 -   6:1,
        TRNCOD8_CF          6:8 -   6:8,
        RETINTAMT_M        88:1 -  88:,
        PLUS_13_CHAMPS     89:1 - 101:,
        KeyReconciliation 102:1 - 102:,
        TRN_NT            103:1 - 103:,
        FILLER_14_COLS    105:1 - 118:
/DERIVEDFIELD  ORICOD_LS "CURGTA~"
/CONDITION CURGT
   (( TRNCOD8_CF  = "0"  or TRNCOD8_CF  = "1" )
or  ( BALSHTMTH = 1 and BALSHTDAY = 1  )
or  ( ${BALSHTMTH} = 3 or ${BALSHTMTH} = 6 or ${BALSHTMTH} = 9 or ${BALSHTMTH} = 12))
/CONDITION STATGTA
  (( TRNCOD1_CF = "1" or TRNCOD1_CF = "3" ) AND ( TRNCOD8_CF  = "0"  or TRNCOD8_CF  = "1" ))
/CONDITION STATGTAR
   (( TRNCOD1_CF = "2" or TRNCOD1_CF = "4" ) AND ( TRNCOD8_CF  = "0" or TRNCOD8_CF  = "1" ))
/OUTFILE ${SORT_O}
/INCLUDE CURGT
/REFORMAT FORMAT_STANDARD,RETINTAMT_M,PLUS_13_CHAMPS,KeyReconciliation,TRN_NT,ORICOD_LS,FILLER_14_COLS
/OUTFILE ${SORT_O1}
/INCLUDE STATGTA
/REFORMAT FORMAT_STANDARD,RETINTAMT_M,PLUS_13_CHAMPS,KeyReconciliation,TRN_NT,ORICOD_LS,FILLER_14_COLS
/OUTFILE ${SORT_O2}
/INCLUDE STATGTAR
/REFORMAT FORMAT_STANDARD,RETINTAMT_M,PLUS_13_CHAMPS,KeyReconciliation,TRN_NT,ORICOD_LS,FILLER_14_COLS
exit
EOF
SORT

#en step 62bis, mettre -1 dans KeyReconciliation si vide
gzip -c ${DFILT}/${NJOB}_60_${IB}_SORT_CURGTA_O1.dat > ${DFILT}/${NJOB}_60_SORT_CURGTA_O1.dat.gz


NSTEP=${NJOB}_65
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Sort GTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_GTAR_O6.dat 800 1"  #[020] renommage step62 en step 60
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAR_O1.dat"
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

NSTEP=${NJOB}_75
#Dividing of STATGTR in retrocession by acceptance life and non-life
#-----------------------------------------------------------------------------
LIBEL="Eliminating Non-life transactions of GTAR"
PRG=ESTM7606
export ${PRG}_I1=${DFILT}/${NJOB}_65_${IB}_SORT_GTAR_O1.dat
export ${PRG}_I2=${EST_CRVPERICASE0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DGTR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTAR_O2.dat
export ${PRG}_O3=${EST_GTRANO}
EXECPRG

#[019]
NSTEP=${NJOB}_80
# Accumulation of GTAA + GTAR amounts and merge with STATGTA
#------------------------------------------------------------------------------
LIBEL="Accumulation of GTAA + GTAR amounts and merge with STATGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_GTAA_O5.dat 800 1"
SORT_I2="${DFILT}/${NJOB}_75_${IB}_ESTM7606_GTAR_O2.dat 800 1"
SORT_I3="${EST_STATGTA} 800 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_STATGTA_O.dat
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
        PLUS_13_CHAMPS  42:1 - 54:,
        KeyReconciliation  55:1 - 55:,
        PLUS_2_CHAMPS 56:1 - 57:,
        PLUS_14_CHAMPS 58:1 - 71:
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
        RETKEY_CF,
        KeyReconciliation
/SUMMARIZE  TOTAL AMT_M , TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF, END_NT , SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF, AMT_MC, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_MC, PLC_NT, RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF, RETINTAMT_MC, PLUS_13_CHAMPS, KeyReconciliation, PLUS_2_CHAMPS, PLUS_14_CHAMPS

exit
EOF
SORT

NSTEP=${NJOB}_85
# Begin Sort
#-----------------------------------------------------------------
LIBEL="STATGTA sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_SORT_STATGTA_O.dat 800 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_STATGTA_O.dat 800 1"
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

#[014]
#[019]
NSTEP=${NJOB}_95
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Split GTR ==> delta(CURGTR), GTR-CURGTR, DLTOTGTARC "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_IGTR} 800 1"
SORT_I="${EST_GTR} 800 1"
if [ ${EST_ESID7000_COND1} = "Y" ]
then
    # COMPTA TRIMESTRIELLE
    SORT_I2="${EST_DLTOTGTR} 800  1"
fi
if [ ${EST_ESID7000_COND2} = "Y" ]
then
  # COMPTA ANNUELLE
  SORT_I3="${EST_DLREJGTR} 800  1"
fi
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CURGTR_O.dat
SORT_O2="${EST_DLTOTGTRC} OVERWRITE"
SORT_O3=${DFILT}/${NSTEP}_${IB}_SORT_GTR_O3.dat
SORT_O4="${EST_ANOBALSHEYGT} APPEND"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY  3:1 - 3: EN,
  BALSHTMTH  4:1 - 4: EN,
  TRNCOD_CF 6:1 - 6:,
    TRNCOD1_CF 6:1 - 6:1,
    TRNCOD2C_CF 6:2 - 6:2 ,
    TRNCOD8_CF 6:8 - 6:8
/CONDITION ANO      BALSHEY < ${BALSHEYEA}
/CONDITION AVANT_PERIODE  ( BALSHEY = ${BALSHEYEA} and BALSHTMTH <= ${BALSHTMTH})
/CONDITION APRES_PERIODE        (  BALSHEY = ${BALSHEYEA} and BALSHTMTH > ${BALSHTMTH}
                                OR BALSHEY > ${BALSHEYEA} )
/CONDITION COND_DLTOTGTRC       (( BALSHEY = ${BALSHEYEAS} and BALSHTMTH = 1 ) OR
                                ( BALSHEY = ${BALSHEYEA} and BALSHTMTH <= ${BALSHTMTH})) and
                                ( TRNCOD8_CF  > "1" OR "SCORIT456789" CT TRNCOD2C_CF )

/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE

/OUTFILE ${SORT_O2}
/INCLUDE COND_DLTOTGTRC

/OUTFILE ${SORT_O3}
/INCLUDE APRES_PERIODE

/OUTFILE ${SORT_O4}
/INCLUDE ANO

/COPY
exit
EOF
SORT
gzip -c ${DFILT}/${NJOB}_95_${IB}_SORT_CURGTR_O.dat > ${DFILT}/${NJOB}_95_SORT_CURGTR_O.dat.gz

NSTEP=${NJOB}_105
# Begin Sort
#-----------------------------------------------------------------
LIBEL="SORT GTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_SORT_CURGTR_O.dat 800 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTR_O.dat"
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

# ajout step debut

NSTEP=${NJOB}_115
#Dividing of STATGTR in retrocession by acceptance life and non-life
#-----------------------------------------------------------------------------
LIBEL="Eliminating Non-life transactions of GTR"
PRG=ESTM7606
export ${PRG}_I1=${DFILT}/${NJOB}_105_${IB}_SORT_GTR_O.dat
export ${PRG}_I2=${EST_CRVPERICASE0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DGTR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_GTR_O2.dat
export ${PRG}_O3=${EST_GTRANO}
EXECPRG

#[019]
NSTEP=${NJOB}_120
# Accumulation of GTR amounts and merge with STATGTR
#------------------------------------------------------------------------------
LIBEL="Accumulation of GTR amounts and merge with STATGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_115_${IB}_ESTM7606_GTR_O2.dat 800 1"
SORT_I2="${EST_STATGTR} 800 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_STATGTR_O.dat
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
  RETINTAMT_M 41:1 - 41:EN 15/3
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
exit
EOF
SORT

# ATTENTION faire un Restart a partir de ce step

NSTEP=${NJOB}_125
# Begin Sort
#-----------------------------------------------------------------
LIBEL="EST_STATGTR sort"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_SORT_STATGTR_O.dat 800 1"
SORT_O="${EST_STATGTR} OVERWRITE"
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

#[017]
NSTEP=${NJOB}_126
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichier ${EST_GTR} en entree"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_GTR} > ${DARCH}/${ENV_PREFIX}_ESIX7000_GTR_${BALSHEYEA}${BALSHTMTH2}_avant_${datej}.dat.gz"

#[017]
NSTEP=${NJOB}_127
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichier ${EST_CURGTR} en entree"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_CURGTR} > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_${BALSHEYEA}${BALSHTMTH2}_avant_${datej}.dat.gz"

#[017]
NSTEP=${NJOB}_128
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichier ${EST_CURGTA} en entree"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_CURGTA} > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTA_${BALSHEYEA}${BALSHTMTH2}_avant_${datej}.dat.gz"

#[024]
if [ "${EST_ESID7000_COND2}" = "Y" ]
then

	NSTEP=${NJOB}_130a
	# Omit EBS opening data to new GTA
	#------------------------------------------------------------------------------
	LIBEL="Omit EBS opening data to new GTR"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_95_${IB}_SORT_GTR_O3.dat 1000 1"
	SORT_O="${EST_GTR} 1000 1"
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

else

	NSTEP=${NJOB}_130b
	# Begin sort
	#----------------------------------------------------------------------------
	LIBEL="move GTR-CURGTR ==> GTR"
	EXECKSH "mv ${DFILT}/${NJOB}_95_${IB}_SORT_GTR_O3.dat ${EST_GTR}"
	
fi

#[024]
NSTEP=${NJOB}_130b
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichier ${EST_GTR} en sortie"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_GTR} > ${DARCH}/${ENV_PREFIX}_ESIX7000_GTR_${BALSHEYEA}${BALSHTMTH2}_apres_${datej}.dat.gz"

NSTEP=${NJOB}_131
# Begin sort
#----------------------------------------------------------------------------
LIBEL="move ${DFILT}/${NJOB}_85_${IB}_SORT_STATGTA_O.dat ${EST_STATGTA}"
EXECKSH "mv ${DFILT}/${NJOB}_85_${IB}_SORT_STATGTA_O.dat ${EST_STATGTA}"

NSTEP=${NJOB}_132
# Begin Sort
#-----------------------------------------------------------------
LIBEL="APPEND dans CURGTA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_CURGTA_O1.dat 800 1"
SORT_O="${EST_CURGTA} APPEND"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

#[024]
NSTEP=${NJOB}_132b
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichier ${EST_CURGTA} en sortie"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_CURGTA} > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTA_${BALSHEYEA}${BALSHTMTH2}_apres_${datej}.dat.gz"

NSTEP=${NJOB}_133
# Begin Sort
#-----------------------------------------------------------------
LIBEL="APPEND CURGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_SORT_CURGTR_O.dat 800 1"
SORT_O="${EST_CURGTR} APPEND"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
SORT

#[024]
NSTEP=${NJOB}_133b
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichier ${EST_CURGTR} en sortie"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_CURGTR} > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_${BALSHEYEA}${BALSHTMTH2}_apres_${datej}.dat.gz"

if [ ${EST_ESID7000_COND2} = "Y" ]
then

	# COMPTABILISATION ANNUELLE 4T
	
  NSTEP=${NJOB}_135
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="EST_STATGTA archive"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_STATGTA} 800  1"
  SORT_I2="${EST_ARCSTATGTA} 800 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ARCSTATGTA_O.dat
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
  RETUW_NT 28:1 - 28:,
    KeyReconciliation  55:1 - 55:
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
  KeyReconciliation
exit
EOF
  SORT

  NSTEP=${NJOB}_140
  # Begin sort
  #----------------------------------------------------------------------------
  LIBEL="move ARCSTATGTA TMP ==> ARCSTATGTA"
  EXECKSH "mv ${DFILT}/${NJOB}_135_${IB}_SORT_ARCSTATGTA_O.dat ${EST_ARCSTATGTA}"

  NSTEP=${NJOB}_145
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="EST_STATGTR sort"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_STATGTR} 800  1"
  SORT_I2="${EST_ARCSTATGTR} 800 1"
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

	#[028]
	NSTEP=${NJOB}_146
	# Accumulation of GTAR amounts and merge with ARCSTATGTAR
	#------------------------------------------------------------------------------
	LIBEL="Accumulation of GTAR amounts and merge with old ARCSTATGTAR"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_CURGTA} 800 1"
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

	#[028]
  NSTEP=${NJOB}_147
  # Begin sort
  #----------------------------------------------------------------------------
  LIBEL="move EST_ARCSTATGTAR + CURGTA ==> EST_ARCSTATGTAR"
  EXECKSH "mv ${DFILT}/${NJOB}_146_${IB}_SORT_ARCSTATGTAR_O.dat ${EST_ARCSTATGTAR}"

  NSTEP=${NJOB}_150
  # Begin sort
  #----------------------------------------------------------------------------
  LIBEL="move ARCSTATGTR TMP ==> ARCSTATGTR "
  EXECKSH "mv ${DFILT}/${NJOB}_145_${IB}_SORT_ARCSTATGTR_O.dat ${EST_ARCSTATGTR}"

  #[013] [028]
  NSTEP=${NJOB}_155
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="remove EST_STATGTx and archive EST_CURGTx"
#  export EST_ARCCURGTA=${DARCH}/`basename ${EST_CURGTA} .dat`_${BALSHEYEA}${BALSHTMTH}.arc
#  export EST_ARCCURGTR=${DARCH}/`basename ${EST_CURGTR} .dat`_${BALSHEYEA}${BALSHTMTH}.arc
  export EST_ARCCURGTACTL=${DARCH}/`basename ${EST_CURGTACTL} .dat`_${BALSHEYEA}${BALSHTMTH}.arc
# deja archive  EXECKSH "mv ${EST_CURGTA} ${EST_ARCCURGTA}"
# deja archive EXECKSH "mv ${EST_CURGTR} ${EST_ARCCURGTR}"
  EXECKSH "mv ${EST_CURGTACTL} ${EST_ARCCURGTACTL}"
  EXECKSH "cp ${EST_FPLC} ${EST_FPLCANT}"
  EXECKSH "cp ${EST_FCES} ${EST_FCESANT}"
  EXECKSH "cp ${EST_FTVENTNP} ${EST_FVENTNPANT}"
  RMFIL   "${EST_CURGTA}"
  RMFIL   "${EST_CURGTR}"
  RMFIL   "${EST_STATGTA}"
  RMFIL   "${EST_STATGTR}"
  RMFIL   "${EST_STATGTACTL}"

  EXECKSH "touch ${EST_CURGTA}"
  EXECKSH "touch ${EST_CURGTR}"
  EXECKSH "touch ${EST_CURGTACTL}"
  EXECKSH "touch ${EST_STATGTA}"
  EXECKSH "touch ${EST_STATGTR}"
  EXECKSH "touch ${EST_STATGTACTL}"
  EXECKSH "touch ${EST_FVENTNPANT}"

fi

#####################################################
# MDJ : Maj des ultimes par creation comptes complets
####################################################
NSTEP=${NJOB}_157
#Update Normal Period Table BEST..TREQJOB
#-----------------------------------------------------------------------------
LIBEL="Update Normal Period BEST..TREQJOB"
ISQL_QRY="EXECUTE PuREQJOB_03 ${BALSHEYEA}, ${BALSHTMTH}"
ISQL_BASE="BEST"
ISQL

#[017]
NSTEP=${NJOB}_158
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichier ${EST_GTA} en entree"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_GTA} > ${DARCH}/${ENV_PREFIX}_ESIX7000_GTA_${BALSHEYEA}${BALSHTMTH2}_avant_${datej}.dat.gz"

#[024]
if [ "${EST_ESID7000_COND2}" = "Y" ]
then

	NSTEP=${NJOB}_159
	# Omit EBS opening data to new GTA
	#------------------------------------------------------------------------------
	LIBEL="Omit EBS opening data to new GTA"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_55_${IB}_SORT_GTA_O4.dat 1000 1"
	SORT_O="${EST_GTA} 1000 1"
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

else

	NSTEP=${NJOB}_160
	# Begin sort
	#------------------------------------------------------------------------------
	LIBEL="move GTA-CURGTA ==> GTA"
	EXECKSH "mv ${DFILT}/${NJOB}_55_${IB}_SORT_GTA_O4.dat ${EST_GTA}"

fi

#[024]
NSTEP=${NJOB}_158
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichier ${EST_GTA} en sortie"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_GTA} > ${DARCH}/${ENV_PREFIX}_ESIX7000_GTA_${BALSHEYEA}${BALSHTMTH2}_apres_${datej}.dat.gz"


########################
# Erase temporary files #
########################

#[014]
NSTEP=${NJOB}_180
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"
#RMFIL "${EST_IGTA}"

#[017]
NSTEP=${NJOB}_181
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree ${EST_DLTOTGTAA}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_DLTOTGTAA} > ${DARCH}/${ENV_PREFIX}_ESID2060_DLTOTGTAA_${BALSHEYEA}${BALSHTMTH2}.dat.gz"

#[017]
NSTEP=${NJOB}_182
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree ${EST_DLTOTGTAR}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_DLTOTGTAR} > ${DARCH}/${ENV_PREFIX}_ESID2560_DLTOTGTAR_${BALSHEYEA}${BALSHTMTH2}.dat.gz"

#[017]
NSTEP=${NJOB}_183
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree ${EST_DLTOTGTR}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_DLTOTGTR} > ${DARCH}/${ENV_PREFIX}_ESID2560_DLTOTGTR_${BALSHEYEA}${BALSHTMTH2}.dat.gz"

#[017]
NSTEP=${NJOB}_184
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree ${EST_FTVENTNPHIS}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_FTVENTNPHIS} > ${DARCH}/${ENV_PREFIX}_ESID0060_FTVENTNPHIS_${BALSHEYEA}${BALSHTMTH2}.dat.gz"

#[017]
NSTEP=${NJOB}_185
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree ${EST_CURGTA}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_CURGTA} > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTA_${BALSHEYEA}${BALSHTMTH2}.dat.gz"

#[017]
NSTEP=${NJOB}_186
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree ${EST_CURGTR}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_CURGTR} > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_${BALSHEYEA}${BALSHTMTH2}.dat.gz"

#[028]
NSTEP=${NJOB}_186B
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree ${EST_FTECLEDA_MTH}"
EXECKSH_MODE=P
EXECKSH "gzip -c ${EST_FTECLEDA_MTH} > ${DARCH}/${ENV_PREFIX}_ESID3800_FTECLEDA_MTH_${BALSHEYEA}${BALSHTMTH2}.dat.gz"

#[025]
if [ "${EST_ESID7000_COND3}" = "Y" ]
then
	# COMPTA TRIMESTRIELLE
	#[023]
	NSTEP=${NJOB}_187
	# Remet a blanc les colonnes SAP
	#-----------------------------------------------------------------------------
	LIBEL="Remet a blanc les colonnes SAP dans fichier ${EST_VENTNP_TRIMPREV}"
	AWK_I=${EST_VENTNP_TRIMCUR}
	AWK_O=${EST_VENTNP_TRIMPREV}
	AWK_CMD=`CFTMP`
	INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{
			for (i=42; i<56; i++) \$i = "";
			print \$0
		}
exit
EOF
	AWK

	NSTEP=${NJOB}_188
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Gzip fichiers en entree ${EST_VENTNP_TRIMPREV}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_VENTNP_TRIMPREV} > ${DARCH}/${ENV_PREFIX}_ESIX7000_VENTNP_TRIMPREV_${BALSHEYEA}${BALSHTMTH2}.dat.gz"
	
	#[023]
	NSTEP=${NJOB}_189
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Gzip fichiers en entree ${EST_VENTNP_TRIMCUR}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_VENTNP_TRIMCUR} > ${DARCH}/${ENV_PREFIX}_ESIX7000_VENTNP_TRIMCUR_${BALSHEYEA}${BALSHTMTH2}.dat.gz"
fi

#[022] [023]
if [ "${EST_ESID7000_COND2}" = "Y" ]
then
	# COMPTA ANNUELLE
	#[017]
	NSTEP=${NJOB}_200
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Gzip fichiers en entree ${EST_DLREJGTAA}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_DLREJGTAA} > ${DARCH}/${ENV_PREFIX}_ESID2900_DLREJGTAA_${BALSHEYEA}${BALSHTMTH2}.dat.gz"
	
	#[017]
	NSTEP=${NJOB}_201
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Gzip fichiers en entree ${EST_DLREJGTAR}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_DLREJGTAR} > ${DARCH}/${ENV_PREFIX}_ESID2900_DLREJGTAR_${BALSHEYEA}${BALSHTMTH2}.dat.gz"
	
	#[017]
	NSTEP=${NJOB}_202
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Gzip fichiers en entree ${EST_DLREJGTR}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_DLREJGTR} > ${DARCH}/${ENV_PREFIX}_ESID2900_DLREJGTR_${BALSHEYEA}${BALSHTMTH2}.dat.gz"

	#[023][025]
	NSTEP=${NJOB}_203
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Gzip fichiers en entree ${EST_VENTNP_TRIMCUR}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_VENTNP_TRIMCUR} > ${DARCH}/${ENV_PREFIX}_ESIX7000_VENTNP_TRIMCUR_${BALSHEYEA}${BALSHTMTH2}.dat.gz"

	#[025]
	NSTEP=${NJOB}_204
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Gzip fichiers en entree ${EST_VENTNP_TRIMPREV}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_VENTNP_TRIMPREV} > ${DARCH}/${ENV_PREFIX}_ESIX7000_VENTNP_TRIMPREV_${BALSHEYEA}${BALSHTMTH2}.dat.gz"

	#[025]
	NSTEP=${NJOB}_205
	# touch fichiers
	#------------------------------------------------------------------------------
	LIBEL="Remise a zero du fichier ${EST_VENTNP_TRIMPREV} pour la nouvelle année"
	EXECKSH_MODE=P
	RMFIL "${EST_VENTNP_TRIMPREV}"
	EXECKSH "touch ${EST_VENTNP_TRIMPREV}"
fi

#[026] gestion fichiers ES Local #[027] #[028] suppression recherche derniere version de fichiers
NSTEP=${NJOB}_220
#------------------------------------------------------------------------------
LIBEL="Copy month files for ES Local"
#EST_FCES=`ls -rt ${DFILP}/*ESID2500_FCES_*.dat | tail -1`
#EST_FCPLACC=`ls -rt ${DFILP}/*_ESID0560_FCPLACC_*.dat | tail -1`
#EST_FPLATXCUM=`ls -rt ${DFILI}/*_ESID0560_FPLATXCUM_*.dat | tail -1`
#EST_FPLC=`ls -rt ${DFILP}/*_ESID2500_FPLC_*.dat | tail -1`
#EST_FCTRGRO=`ls -rt ${DFILP}/*_ESID0560_FCTRGRO_*.dat | tail -1`
#EST_IADVPERICASE=`ls ${DFILP}/*_ESID0560_IADVPERICASE_2* | head -1`
#EST_OIADVPERICASE=`ls -rt ${DFILP}/*_ESID0560_OIADVPERICASE_*.dat | tail -1`
#EST_OIRDVPERICASE=`ls -rt ${DFILP}/*_ESID0560_OIRDVPERICASE_*.dat | tail -1`
EXECKSH "cp ${EST_CRVPERICASE0}  ${ESL_CRVPERICASE0} "
EXECKSH "cp ${EST_FCES}          ${ESL_FCES}         "
EXECKSH "cp ${EST_FCLIENT}       ${ESL_FCLIENT}      "
EXECKSH "cp ${EST_FCPLACC}       ${ESL_FCPLACC}      "
EXECKSH "cp ${EST_FCTRGRO}       ${ESL_FCTRGRO}      "
EXECKSH "cp ${EST_FCURCVSN}      ${ESL_FCURCVSN}     "
EXECKSH "cp ${EST_FCURCVSNI}     ${ESL_FCURCVSNI}    "
EXECKSH "cp ${EST_FCURQUOT}      ${ESL_FCURQUOT}     "
EXECKSH "cp ${EST_FDETTRS}       ${ESL_FDETTRS}      "
EXECKSH "cp ${EST_FPLACEMT2}     ${ESL_FPLACEMT2}    "
EXECKSH "cp ${EST_FPLATXCUM}     ${ESL_FPLATXCUM}    "
EXECKSH "cp ${EST_FPLC}          ${ESL_FPLC}         "
EXECKSH "cp ${EST_FSOBBLOB}      ${ESL_FSOBBLOB}     "
EXECKSH "cp ${EST_FSSDACTR}      ${ESL_FSSDACTR}     "
EXECKSH "cp ${EST_FTRANSCODE}    ${ESL_FTRANSCODE}   "
EXECKSH "cp ${EST_FTRSLNK}       ${ESL_FTRSLNK}      "
EXECKSH "cp ${EST_IADVPERICASE}  ${ESL_IADVPERICASE} "
EXECKSH "cp ${EST_OIADVPERICASE} ${ESL_OIADVPERICASE}"
EXECKSH "cp ${EST_OIRDVPERICASE} ${ESL_OIRDVPERICASE}"
EXECKSH "cp ${EST_SUBTRS}        ${ESL_FSUBTRS}      "

NSTEP=${NJOB}_230
#-----------------------------------------------------------------
LIBEL="delete of files ${EST_DLTOTGTAA} ${EST_DLTOTGTAR} ${EST_DLTOTGTR}"
RMFIL "${EST_DLTOTGTAA}"
RMFIL "${EST_DLTOTGTAR}"
RMFIL "${EST_DLTOTGTR}"
RMFIL "${EST_FTVENTNPHIS}"

JOBEND
