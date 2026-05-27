#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des discounts 
# nom du script SHELL           : ESPD3627.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 20/04/2020
# auteur                        : Roger Cassis
# references des specifications :
#-----------------------------------------------------------------------------
# description
#		DISCOUNT CALCULATION (extracted from old ESID3703.cmd) 
#-----------------------------------------------------------------------------
#     historiques des modifications
#
#[02] 27/07/2012 :spot:23937 -=Dch=-   Ajout de touch pour crâ..ation des fichiers vides en dâ..but de job, puis vâ..rification en sortie de ESTC1056 : si fichier vide : fin du job
#[03] 02/08/2012 :spot:24041 -=Dch=-   Remplacement de MPPINC par MNAUTO dans la jointure ( segment)
#[04] 28/08/2012 :spot:24041 -=JFVDV=- Amâ..nagements (comment out / undo comment out)
#[05] 03/09/2012 :spot:24041 R. Cassis Reformat tri pour format FTECLEDSII
#[06] 07/09/2012 :spot:24041 Florent   modif email Philippe de ce jour
#[07] 14/09/2012 :spot:24041 -=Dch=-   Modif des awk pour le fichier GTCUMUL ( step 5) avant traitement ESTC1056 et suivant et ajout des pivots dans EST1057 et 58
#[07] 19/09/2012 :spot:24041 -=Dch=-   Ajout des premium reserve et modification des fichiers GTAASII et GTARSII dans les tri-fusion
#[08] 20/01/2013 :spot:24698 -=PhP=-   corrections pour la conso
#[09] 20/01/2013 :spot:24864 -=PhP=-   corrections pour la conso
#[10] 14/11/2013 :spot:25427 R. Cassis modifs centralization des bases
# Restauration ancienne version
#[11] 28/04/2014 :spot:26653 PPEZOUT   Echanges internes Solvency
#[12] 28/05/2014 :spot:26838 Benjeddou Echanges internes Solvency
#[13] 21/10/2013 :spot:26391 Cyrille   Application du pattern ICR (Incurred Incremental) pour les IBNR. Doit etre identique â.. l'application du pattern CSF (cash flow) pour les Paid and Premium Cumulatives
#[14] 17/02/2015 :spot:26391 Cyrille   Ajout du retrocessionaire a la cle dur fichier RMNTP
#[15] 01/06/2015 :spot:26391 Roger     On ne prend pas les postes 2A4261.. dont le montant râ..tro est positif
#[16] 02/06/2015 :spot:26391 Roger     Correction sur fichier en entrâ..e.
#[17] 25/06/2015 :spot:28941 PP/Roger  Diverses corrections pour EST49A2 EBS ULAE et Risk Management - refonte du shell
#[18] 03/09/2015 :spot:28941 Philippe  ajout code â..tablissement dans les echanges internes SII
#[19] 02/11/2015 :spot:29615 P PEZOUT
#[20] 03/06/2016 :spot:30543 Florent   on passe â.. 65 annâ..es et ce fichier devient la râ..fâ..rences pour les PAATERNSII !
#[21] 18/11/2016 :spira:57799 Florent  Mise au format â.. 71 colonnes pour les fichiers EST_DLDSIIGT*
#[22] 13/11/2017 :spira:64660 Roger    gestion du RTO et PLC dans le fichier Râ..tro EST_DLDSIIGTR et EST_DLDSIIGTAR
#[23] 28/06/2018 :spira:69426 JYP      part of discount calculation extracted from ESID3703.cmd
#[024] 14/09/2018 :spira:62219 Roger    Omission des mouvements BDT avec retrocessionnaire interne
#[025] 03/09/2018 Charles Socie : EXT-IFRS17-903121  REQ 10.02 Cash flow: more detailed granularity ( split between variable and fixed premiums)
#[026] 13/11/2018 :JYP: revert spira:62219 Roger Omission des mouvements BDT avec retrocessionnaire interne
#[027] 07/12/2018 :spira:62219 Roger    Omission des mouvements BDT avec retrocessionnaire interne 
#[028] 05/02/2018 Quentin Desmettre EXT-IFRS17-903121  REQ 10.09-10 : Funds Held Modelling: Investment Income Modelling
#[029] 02/09/2019 :spira:79910: JYP:  many bugfix currencies
#[030] 11/12/2019 RC  :spira:81496 Mise a jour de l'etablissement dans fichier DLDSIIGTAR a partir de PERICASE
#[031] 18/12/2019 RC  :spira:81791 Correction du tri Step269 pour fichier GTSII_ESCOMPTE_CLM - probleme de devise
#[032] 26/12/2019 JYP :spira:82679 Bugfix cumul par currency step 269
#[033] 18/11/2019 Charles Socie SPIRA : 77191 IFRS17 Bad debt management : discount at lock in rate (REQ11.4) and unwind calculation (REQ11.5) delete step 150 and 160
#[034] 04/03/2020 Charles Socie SPIRA : 83091 Use IFRS 17 discount batch chain for EBS discount
#[035] 18/03/2020 R. Cassis :spira:85448 Correction du tri Step269 Devise CUR_CF affectee pour ACCRET = RI egalement -> non retour arriere
#[036] 20/04/2020 M.NAJI :SPIRA 86220 optimisation ESPD3620, découpage ESID3703B en plusieurs jobs
#===============================================================================

# Call generic functions 
. ${DUTI}/fctgen.cmd


# Get input parameters
CRE_D=$1
ICLODAT_D=$2
TYPEINV=$3


# Job Initialisation
JOBINIT


#[22]
NSTEP=${NJOB}_325
# Begin Merge and Sort
#-----------------------------------------------------------------------------
LIBEL="Creation DLDSIIGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESPD3623${TYPEINV}_320_${IB}_ESTM7603_DLDGTA_.dat 1000 1"
SORT_O="${EST_DLDSIIGTAR} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
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
        RETINTAMT_M      41:1 - 41: EN 15/3,
        FILLER1           1:1 - 35:,
        FILLER2          38:1 - 71:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RTO_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCUR_CF,
      CUR_CF,
      TRNCOD_CF
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/CONDITION MONTANTNONNUL ( AMT_M !=0 OR RETAMT_M !=0)
/OUTFILE ${SORT_O}
/INCLUDE MONTANTNONNUL
exit
EOF
SORT

#[22]
NSTEP=${NJOB}_330
#-----------------------------------------------------------------------------
LIBEL="Creation fichier DLDSIIGTR a partir du DLDSIIGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESPD3623${TYPEINV}_320_${IB}_ESTM7603_DLDGTA_.dat 1000 1"
SORT_O="${EST_DLDSIIGTR} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS DEBUT1            1:1 -  7:,
        TRNCOD_CF         6:1 -  6:,
        AMT_M            19:1 - 19:EN 18/3,
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
        RETAMT_M         35:1 - 35:EN 18/3,
        PLC_NT           36:1 - 36:EN,
        RTO_NF           37:1 - 37:,
        INT_NF           38:1 - 38:,
        RETPAY_NF        39:1 - 39:,
        RETKEY_CF        40:1 - 40:,
        RETINTAMT_M      41:1 - 41:EN 18/3,
        FIN1             42:1 - 56:,
        FIN2             58:1 - 71:
/SUMMARIZE  TOTAL RETAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD AMT_MC "0.000~"
/DERIVEDFIELD RETINTAMT_MC "0.000~"
/DERIVEDFIELD VIDES11 11"~"
/DERIVEDFIELD VIDES04  4"~"
/DERIVEDFIELD ORICOD_LS2  "EBSGTA~"
/KEYS RETCTR_NF,
      RETEND_NT,
      RETCUR_CF,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      TRNCOD_CF
/OUTFILE ${SORT_O}
/REFORMAT DEBUT1,
          VIDES11,
          AMT_MC,
          VIDES04,
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
          FIN1,
          ORICOD_LS2,
          FIN2
exit
EOF
SORT


NSTEP=${NJOB}_340
LIBEL="Fusion des fichiers GTSII et eclatement en retro et accept"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESPD3624${TYPEINV}_320_${IB}_ESTM7603_DLDGTA_.dat 2000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESPD3625${TYPEINV}_320_${IB}_ESTM7603_DLDGTA_.dat 2000 1"
SORT_O="${EST_DLDSIIGTAA}"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT
JOBEND

