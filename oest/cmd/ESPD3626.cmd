#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 SOLVENCY - Calcul des discounts 
# nom du script SHELL           : ESPD3626.cmd
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
#[024] 14/09/2018 :spira:62219 Roger    Omission des mouvements BDT avec retrocessionnaire internespira
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
#[037] 04/08/2020 R. Cassis :spira: 79427  Remplacement du ESTC1081 par des tris et utilisation du fichier FPLATXCUM a la place du fichier FCLIENT pour l'info RI.
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd


# Get input parameters
CRE_D=$1
ICLODAT_D=$2
TYPEINV=$3


# Job Initialisation
JOBINIT





NSTEP=${NJOB}_269
LIBEL="Fusion des fichiers GTSII et eclatement en retro et accept"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESPD3621A${TYPEINV}_269_${IB}_SORT_FTECLEDSII.dat 2000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESPD3622A${TYPEINV}_269_${IB}_SORT_FTECLEDSII.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDSII.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_269a
LIBEL="Fusion des fichiers GTSII et eclatement en retro et accept"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESPD3621A${TYPEINV}_269_${IB}_SORT_GTSII_ESCOMPTE_CLM.dat 2000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESPD3622A${TYPEINV}_269_${IB}_SORT_GTSII_ESCOMPTE_CLM.dat 2000 1"
SORT_O="${EST_GTSII_ESCOMPTE_CLM} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_269z
#-----------------------------------------------------------------------------
LIBEL="Generation des lignes GT supplementaires pour Accept"
PRG=ESTC1075
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_269_${IB}_SORT_FTECLEDSII.dat
#export ${PRG}_O1=${EST_FTECLEDSII}  # [006]
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDSII.dat  # [006] [027]
EXECPRG

#####################################
#[037] debut

##[027]
#NSTEP=${NJOB}_269z0
## Omit records with PATCAT_CT BDT and internal retrocessionaire 
##-----------------------------------------------------------------------------
#LIBEL="Omit records with PATCAT_CT BDT and internal retrocessionaire"
#PRG=ESTC1081
#export ${PRG}_I1=${DFILT}/${NJOB}_269z_${IB}_ESTC1075_FTECLEDSII.dat
#export ${PRG}_I2=${EST_FCLIENT}
#export ${PRG}_O1=${EST_FTECLEDSII}
#EXECPRG

NSTEP=${NJOB}_269z01
# Filter T.code on ACMTRSL3_NT values
#---------------------------------------------------------------------------
LIBEL="Filter T.code on ACMTRSL3_NT values"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_FPLATXCUM}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUM.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:
       ,RETSEC_NF 2:1 - 2:EN
       ,RETRTY_NF 3:1 - 3:
       ,RTO_NF    8:1 - 8:
/CONDITION rto RTO_NF != ""        
/KEYS RETCTR_NF, RETSEC_NF, RETRTY_NF, RTO_NF
/SUM
/INCLUDE rto
/REFORMAT RETCTR_NF, RETSEC_NF, RETRTY_NF, RTO_NF
exit
EOF
SORT

NSTEP=${NJOB}_269z02
# Get internal Retro info by Join with FPLATXCUM
#------------------------------------------------------------------------------
LIBEL="Get internal Retro info by Join with FPLATXCUM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_269z_${IB}_ESTC1075_FTECLEDSII.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDSII_O.dat OVERWRITE 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF    13:1 -  13:,
        RETSEC_NF    15:1 -  15:,
        RTY_NF       16:1 -  16:,
        RTO_NF       19:1 -  19:,
        COLS1         1:1 - 106:,
        F_RETCTR_NF   1:1 -   1:,
        F_RETSEC_NF   2:1 -   2:,
        F_RTY_NF      3:1 -   3:,
        F_RTO_NF      4:1 -   4:
/joinkeys
         RETCTR_NF   
        ,RETSEC_NF   
        ,RTY_NF   
        ,RTO_NF    
/INFILE ${DFILT}/${NJOB}_269z01_${IB}_FPLATXCUM.dat 100 1 "~"
/joinkeys
         F_RETCTR_NF   
        ,F_RETSEC_NF   
        ,F_RTY_NF   
        ,F_RTO_NF    
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:COLS1
       ,rightside:F_RTO_NF
exit
EOF
SORT

NSTEP=${NJOB}_269z03
# Reformat FTECLEDSII to standard nb cols and Omit records with internal retro and PATCAT_CT = BDT
#---------------------------------------------------------------------------
LIBEL="Reformat FTECLEDSII to standard nb cols and Omit records with internal retro and PATCAT_CT = BDT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_269z02_${IB}_SORT_FTECLEDSII_O.dat 2000 1"
SORT_O=${EST_FTECLEDSII}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS PATCAT_CT   33:1 -  33:
       ,RTO_NF     107:1 - 107:
       ,COLS1        1:1 - 106:
/CONDITION toKeep RTO_NF = "" OR PATCAT_CT != "BDT"
/COPY
/INCLUDE toKeep
/REFORMAT COLS1
exit
EOF
SORT

#[037] fin
#####################################


JOBEND

