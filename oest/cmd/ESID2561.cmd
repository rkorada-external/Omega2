#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                                 Fusion des GT retrocession
#                                 Ajout du poste de contrepartie
# nom du script SHELL		: ESID2561.cmd
# revision			: $Revision: 1.9 $
# date de creation		: 08/09/1997
# auteur			: CGI
# references des specifications	: ESCOM2F.doc
#-----------------------------------------------------------------------------
# description
#   Retrocession merge
#   Double entry transaction code addition
#
# Input files
#       EST_DLAGTAR                 DFILP
#       EST_DLAGTR                  DFILP
#       EST_DLDVGTAR                DFILI
#       EST_DLDVGTR                 DFILI
#       EST_DLGTARSNEM              DFILI
#       EST_DLGTRSNEM               DFILI
#       EST_DLREGTAR                DFILP
#       EST_DLREGTR                 DFILP
#       EST_DLREMAJGTAR             DFILP
#       EST_DLREMAJGTR              DFILP
#       EST_DLRNPGTAR               DFILP
#       EST_DLRNPGTR                DFILP
#       EST_DLRPGTAR                DFILP
#       EST_DLRPGTR                 DFILP
#       EST_DLRTCGTAR               DFILP
#       EST_DLRTCGTR                DFILP
#       EST_DLRTFGTAR               DFILP
#       EST_DLRTFGTR                DFILP
#       EST_DLRTGTAR                DFILP
#       EST_DLRTGTR                 DFILP
#       EST_DLSGTAR                 DFILI
#       EST_DLSGTR                  DFILI
#       EST_DLTOTGTAR               DFILP
#       EST_DLTOTGTR                DFILP
#       EST_DLVGTAR                 DFILP
#       EST_DLVGTR                  DFILP
#       EST_FDETTRS                 DFILI
#       EST_IGTAR                   DFILP
#       EST_IGTR                    DFILP
#       EST_OIRDVPERICASE           DFILI
#       EST_IRDVPERICASE            DFILP
#       EST_IADVPERICASE_ENTIER     DFILP   [018]
#
# Output files
#       EST_DLDVGTAR      DFILI
#       EST_DLTOTGTAR     DFILP
#       EST_DLTOTGTR      DFILP
#       EST_TOTGTAR       DFILI
#       EST_TOTGTR        DFILI
#
# Launch C program ESTM2561 ESTM7603
#
# job launched by ESID2560.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
# 	Modifs du 10/06/98 - M.HA-THUC ( rajout des GT des SNEM au step 05 et 10 )
# 	Modifs du 05/08/98 - M.HA-THUC ( rajout des GT des RP FAC )
#-----------------------------------------------------------------------------
#historique des modifications :
# J. Ribot      24/01/03   ajout colonne montant retro interne dans les formats GT ()
#                  modif   ajout step13  a  22 pour insertion montant retro interne
#
#   31/ 01 / 03 J. Ribot ajout gestion colonne retintamt_m sur autres step (tri)
#   11/ 08 / 04 M. DJELLOULI - Integration Ventilation Non Prop - MOD003
#                      Ajout des STEPS :
#                                        NSTEP=17       Tri TVENTNP
#                                        NSTEP=27       Tri IRDVPERICASE
#                                        NSTEP=37       Tri DLTOTGTAR
#                                        NSTEP=39       Tri Temp IGTAR1 (Extraction Mouvement Cedantes Sans L0)
#                                        NSTEP=41       Tri Temp IGTAR2 (Extraction Mouvement Ouverture Avec L0)
#                                        NSTEP=47       Ventilation ESTC8805 - DLTOTGTAR
#                                        NSTEP=49       Ventilation ESTC8805 - IGTAR1
#                                        NSTEP=53       Ventilation ESTC8805 - IGTAR2
#                                        NSTEP=57       Reconstitution IGTAR : IGTAR1 + IGTAR2 -> IGTAR
#                      Modification des STEPS :
#                                        NSTEP=55       Concatenation DLTOTGTAR + IGTAR1 + IGTAR2 > TOTGTAR
#   27/09/2004 M. DJELLOULI - Integration Ventilation Non Prop - MOD003
#                      Modification des STEPS :
#                                        NSTEP=87      Remplacer
#                                                   SORT_I="${DFILT}/${NJOB}_35_${IB}_SORT_DLTOTGTAR_O.dat 1000 1"
#                                                         par   ${DFILT}/${NJOB}_53_${IB}_ESTC8805_DLTOTGTAR_O.dat 1000 1
#
#   22/11/2004  J. Ribot       ajout I2 step80      ${EST_DLTOTITGTAR}
#   07/02/2005 M. DJELLOULI - Modification Ventilation Non Prop - MOD005
#                                         Remplacer EST_FTRSLNK par EST_FTRSLNK7
#                                         Ajout Step 18 Tri du Fichier  EST_FVENTNPANT
#                                         Modif STEP 47, 49 ,53 : Remplacer EST_FVENTNPANT et EST_FVENTNP par Fichier Trié
#   23/05/2005 M. DJELLOULI - Ajout Type de Postes d'Ouvertures en plus du L0 (Suffixe = "10") ajout de Prefix = "27"
#   01/08/2005 M. DJELLOULI - Summarize du Fichier IGTAR avant Utilisation pour Suppression Double Lignes
#                                        Ajout STEP 36 : Sum and Keep Unique Line Sort IGTAR
#                                        Ajout STEP 38 : Sum and Keep Unique Line DLTTOTGTAR
#                                        Modification STEP 39 : Remplacer ${EST_IGTAR}  par ${DFILT}/${NJOB}_38_${IB}_SORT_SUM_IGTAR.dat
#                                        Modification STEP 41 : Remplacer ${EST_IGTAR}  par ${DFILT}/${NJOB}_38_${IB}_SORT_SUM_IGTAR.dat
#                                        Modification STEP 37 : Remplacer ${DFILT}/${NJOB}_35_${IB}_SORT_DLTOTGTAR_O.dat par ${DFILT}/${NJOB}_36_${IB}_SORT_SUM_DLTOTGTAR_O.dat
#   21/12/2005 M. DJELLOULI - Modification STEP 100 : Ajout du Fichier ${EST_DLTOTITGTAR} dans le Fichier EST_TOTGTR
#   04/01/2006 JM HOFFMANN - Annulation modification STEP 100 +suppression ajout EST_DLTOTITGTAR dans EST_TOTGTAR au step 80
#   04/01/2006 JM HOFFMANN - Annulation modification STEP 100 +suppression ajout EST_DLTOTITGTAR dans EST_TOTGTAR au step 80
#   02/03/2006 M.DJELLOULI - SPOT 12055 - Génération Anomalie Intégration Fichies des Langues EST_FLIBEL2
#   26/03/07 - J. Ribot SPOT13142 ajout steps 02 05 07 12 15 pour exclure les affaires  filiales 2,3,12 et TRNCOD_CF = '21423002'
#   20/11/2009 JF VDV - [17953] Ajout test si fichier perimetre vide ne pas executer le programme ESTC8805.c (step 47)
#   24/11/2009 JF VDV - [17953] Test si fichier perimetre vide a appliquer sur les 3 step 47,49 et 53 qui lance le prog ESTC8805.c - ajout step 50 & 54
#_________________
#MODIFICATION    [017]
#Auteur:         D.GATIBELZA
#Date:           29/03/2010
#Version:        10.1
#Description:    ESTDOM19222 Interface Retro Omega PeopleSoft
#_________________
#MODIFICATION    [018]
#Auteur:         D.GATIBELZA
#Date:           29/04/2010
#Version:        10.1
#Description:    ESTVIE18710 Alimentation du MGTAR lors de la comptabilisation de l'arrêté pour la réallocation asie
#_________________
#   09/09/2010 JF VDV - [19210] - Ecart GTA/GTR Suppression des postes financiers et depots (step120)
#   15/10/2010 JF VDV - [19210] - Suppression du filtre des postes financiers et depots dans la condition du tri au step120
#                                 Remplacer par un nouveau filtre dans le programme ESTM2562.c (step 125)
#_________________
#MODIFICATION    [021]
#Auteur:         D.GATIBELZA
#Date:           14/12/2010
#Version:        10.2
#Description:    ESTDOM19204 V10  Optimisation des nuits batch  Optimisation des tests (environnements pour la non regression)
#                Sauvegarde et Zip des fichiers en entrée du batch.
#_________________
#MODIFICATION    [022]
#Auteur:         D.GATIBELZA
#Date:           17/01/2011
#Version:        10.2
#Description:    ESTDOM21224 Périmetre de l'interface pour Madrid ; ne pas filtrer par statut du contrat
#[23] 16/03/2011 R. CASSIS     :spot:21408 Gestion 16 champs supplementaires
#[24] 09/07/2012 R. CASSIS     :spot:23802 Solvency
#[25] 14/09/2012 R. Cassis     :spot:24182 Correction tri sur cle de reconciliation
#[26] 21/08/2012 Roger Cassis  :spot:24041 Filtre Pour omettre les filiales Tare dans GLT placé dans tri DLTOTGTAA
#[27] 09/09/2013 Roger Cassis  :spot:25498 Remet a blanc les 14 cols pour legale Italie - :spot:25427 - remise à niveau sur derniere version prod
#[28] 25/09/2014 Roger Cassis  :spot:25036 Trncod 1__4 updated to 1__2 for balshey 2014
#[29] 08/10/2014 Gaelle Legay  :spot:25036 Trncod 2__4 updated to 2__2 for balshey 2014 and balshday 14
#[30] 02/11/2015 P PEZOUT      :spot:29615 EST45 gestion des doubles bouclettes RETRO et Déconnexion de l'EBS en variante 3
#[31] 01/03/2016 Florent       :spot:29066 GT à 71 colonnes
#[32] 10/06/2016 Roger Cassis  :spot:29629 gestion de l'allocation Rétro des NP
#[033] 23/04/2018 Roger Cassis :spira:61675 On recoit la CLODAT_D et on l'ajoute au parm du ESTC8805.
#[034] 24/01/2020 KBagwe  	   :spira:79904 STEP 47,49,53
#[035] 25/01/2021 Belaid  	   :spira:91085 STEP 65(A/B/C/D/E), 80A
#[036] 25/02/2022 S.Behague    :spira:102706 IAS 39 Retro - Opening accruals on 31/03
#[037] 16/06/2023 S.Behague    :spira:102706 IAS39 retro accounting transaction codes for IFRS and PG GAAP not reverse
#[038] 21/07/2023 S.Behague    :spira:109913 IAS 39 Process
#=================================================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
ICLODAT_D=$3
CRE_D=$4
CLODAT_D=$5

NSTEP=${NJOB}_00
#Last version of ESID2560 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_DLDVGTAR}`/${PCH}ESID2560_DLDVGTAR*.dat
 `dirname ${EST_DLTOTGTAR}`/${PCH}ESID2560_DLTOTGTAR*.dat
 `dirname ${EST_DLTOTGTR}`/${PCH}ESID2560_DLTOTGTR*.dat
 `dirname ${EST_TOTGTAR}`/${PCH}ESID2560_TOTGTAR*.dat
 `dirname ${EST_TOTGTR}`/${PCH}ESID2560_TOTGTR*.dat"

# SPOT 13142 nouveaux STEPS

NSTEP=${NJOB}_02
#Tri du fichier ESTC1005_PERICASE Extended with TFAMCHG_O
#-----------------------------------------------------------------------------
LIBEL="Tri de ESTC1005_PERICASE Extended ... "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDVPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Merging and sorting acceptance TL files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_DLGTARSNEM}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTARSNEM_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        TRNCOD_CF 6:1 - 6:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25: ,
        RETSEC_NF 26:1 - 26: ,
        RTY_NF    27:1 - 27: ,
        RETUW_NT  28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION DECENNALE ((TRNCOD_CF = '21423002' OR TRNCOD_CF = '21494102') AND (SSD_CF = 2 OR SSD_CF = 3 OR SSD_CF = 12))
/OUTFILE ${SORT_O}
/OMIT DECENNALE
exit
EOF
SORT

NSTEP=${NJOB}_07
#---------------------------------------------------------------------------
if [ "${EST_ESID2560_COND1}" = "Y" ]
then
    LIBEL="  DLGTARSNEM  treatment"
    PRG=ESTM2567
    export ${PRG}_I1=${DFILT}/${NJOB}_02_${IB}_SORT_IRDVPERICASE_O.dat
    export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_SORT_DLGTARSNEM_O.dat
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTARSNEM_O.dat
    EXECPRG
else
    LIBEL="touch files _DLGTARSNEM_O"
    EXECKSH_MODE=P
    EXECKSH "touch ${DFILT}/${NJOB}_07_${IB}_ESTM2567_DLGTARSNEM_O.dat"
fi
# SPOT 13142 fin nouveaux STEPS

#-----------------------------------------------
#[021] Sauvegarde des fichiers
#-----------------------------------------------
NSTEP=${NJOB}_08
#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${EST_DLVGTAR}      >  ${DFILT}/${NJOB}_EST_DLVGTAR.gz
gzip -c ${EST_DLRTCGTAR}    >  ${DFILT}/${NJOB}_EST_DLRTCGTAR.gz
gzip -c ${EST_DLRTGTAR}     >  ${DFILT}/${NJOB}_EST_DLRTGTAR.gz
gzip -c ${EST_DLREGTAR}     >  ${DFILT}/${NJOB}_EST_DLREGTAR.gz
gzip -c ${EST_DLREMAJGTAR}  >  ${DFILT}/${NJOB}_EST_DLREMAJGTAR.gz
gzip -c ${EST_DLRPGTAR}     >  ${DFILT}/${NJOB}_EST_DLRPGTAR.gz
gzip -c ${EST_DLRNPGTAR}    >  ${DFILT}/${NJOB}_EST_DLRNPGTAR.gz
gzip -c ${EST_DLSGTAR}      >  ${DFILT}/${NJOB}_EST_DLSGTAR.gz
gzip -c ${EST_DLRTFGTAR}    >  ${DFILT}/${NJOB}_EST_DLRTFGTAR.gz
gzip -c ${EST_DLGTARSNEM}   >  ${DFILT}/${NJOB}_EST_DLGTARSNEM.gz
gzip -c ${EST_DLVGTR}       >  ${DFILT}/${NJOB}_EST_DLVGTR.gz
gzip -c ${EST_DLRTCGTR}     >  ${DFILT}/${NJOB}_EST_DLRTCGTR.gz
gzip -c ${EST_DLRTGTR}      >  ${DFILT}/${NJOB}_EST_DLRTGTR.gz
gzip -c ${EST_DLREGTR}      >  ${DFILT}/${NJOB}_EST_DLREGTR.gz
gzip -c ${EST_DLREMAJGTR}   >  ${DFILT}/${NJOB}_EST_DLREMAJGTR.gz
gzip -c ${EST_DLRPGTR}      >  ${DFILT}/${NJOB}_EST_DLRPGTR.gz
gzip -c ${EST_DLRNPGTR}     >  ${DFILT}/${NJOB}_EST_DLRNPGTR.gz
gzip -c ${EST_DLSGTR}       >  ${DFILT}/${NJOB}_EST_DLSGTR.gz
gzip -c ${EST_DLRTFGTR}     >  ${DFILT}/${NJOB}_EST_DLRTFGTR.gz
gzip -c ${EST_FTVENTNP}     >  ${DFILT}/${NJOB}_EST_FTVENTNP.gz
gzip -c ${EST_FPLATXCUM}    >  ${DFILT}/${NJOB}_EST_FPLATXCUM.gz
gzip -c ${EST_IGTAR}        >  ${DFILT}/${NJOB}_EST_IGTAR.gz
gzip -c ${EST_DLAGTR}       >  ${DFILT}/${NJOB}_EST_DLAGTR.gz



################################################
# Merge of dVGTAr (set 21) and dDGTAr (set 23) #
################################################

#[026]
NSTEP=${NJOB}_09
#Merge of dVGTAr and dDGTAr
#-----------------------------------------------------------------------------
LIBEL="Merge of dVGTAr and dDVGTAr in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLVGTAR} 1000 1"
SORT_I2="${EST_DLRTCGTAR} 1000 1"
SORT_I3="${EST_DLRTGTAR} 1000 1"
SORT_I4="${EST_DLREGTAR} 1000 1"
SORT_I5="${EST_DLREMAJGTAR} 1000 1"
SORT_I6="${EST_DLRPGTAR} 1000 1"
SORT_I7="${EST_DLRNPGTAR} 1000 1"
SORT_I8="${EST_DLSGTAR} 1000 1"
SORT_I9="${EST_DLRTFGTAR} 1000 1"
SORT_I10="${DFILT}/${NJOB}_07_${IB}_ESTM2567_DLGTARSNEM_O.dat 1000 1"
#[30] plus d'EBS en variante 3
#if [ "${EST_ESID2560_COND2}" = "Y" ]
#then
#	SORT_I11="${EST_DLDSIIGTAR} 1000 1"
#		if [ "${EST_DLASIIGTAR}" != "" ]
#		then
#			SORT_I12="${EST_DLASIIGTAR} 1000 1"
#		fi
#fi
# inventaire solvency EBS
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DVGTAR_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF    6:1 -  6:,
        ORICOD_LS   57:1 - 57:
/KEYS TRNCOD_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

#################################
# Double entry transaction code #
#################################

NSTEP=${NJOB}_20
#Double entry transaction code addition in dDVGTAr
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTAr in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_09_${IB}_SORT_DVGTAR_O.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DVGTAR_O.dat
#export ${PRG}_O1=${EST_DLDVGTAR}
EXECPRG

NSTEP=${NJOB}_22
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
gzip -c ${DFILT}/${NJOB}_09_${IB}_SORT_DVGTAR_O.dat       >  ${DFILT}/${NJOB}_09_DVGTAR.gz
gzip -c ${DFILT}/${NJOB}_20_${IB}_ESTM7603_DVGTAR_O.dat   >  ${DFILT}/${NJOB}_20_DVGTAR.gz
RMFIL ${DFILT}/${NJOB}_09_${IB}_SORT_DVGTAR_O.dat


NSTEP=${NJOB}_25
#GTR merge and sort
#-----------------------------------------------------------------------------
LIBEL="GTR merge and sort and sort in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_ESTM7603_DVGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DVGTAR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF 27:1 - 27:,
        PLC_NT 36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT

exit
EOF
SORT

NSTEP=${NJOB}_27
# MOD003 - Sort of FTVENTNP
#-----------------------------------------------------------------------------
LIBEL="Sort of EST_FTVENTNP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTVENTNP} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTVENTNP_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RTY_NF 2:1 - 2:,
        RETSEC_NF 3:1 - 3:
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

if test -s ${EST_FVENTNPANT}
then
NSTEP=${NJOB}_28
# MOD004 - Tri de EST_FVENTNPANT
#-----------------------------------------------------------------------------
LIBEL="Sort of EST_FVENTNPANT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FVENTNPANT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FVENTNPANT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RTY_NF 2:1 - 2:,
        RETSEC_NF 3:1 - 3:
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT
fi


NSTEP=${NJOB}_30
# Prog affectation retro interne
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${EST_FPLATXCUM}
export ${PRG}_I2=${DFILT}/${NJOB}_25_${IB}_SORT_DVGTAR_O.dat
export ${PRG}_O1=${EST_DLDVGTAR}
EXECPRG



#-----------------------------------------------
#[021] Sauvegarde des fichiers
#-----------------------------------------------
NSTEP=${NJOB}_31
#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_25_${IB}_SORT_DVGTAR_O.dat   >  ${DFILT}/SAUVEGARDE_RETM0532_SORT_DVGTAR_O.dat.gz
gzip -c ${EST_DLDVGTAR}                               >  ${DFILT}/SAUVEGARDE_RETM0532_DLDVGTAR.gz



NSTEP=${NJOB}_32
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_15_${IB}_SORT_DVGTAR_O.dat

NSTEP=${NJOB}_36
# MOD003 -  Sort of IRDVPERICASE
#-----------------------------------------------------------------------------
LIBEL="Sort of IRDVPERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDVPERICASE_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
            RTY_NF 6:1 - 6:EN,
            RETSEC_NF 5:1 - 5:EN,
            RETCTRCAT_CF 107:1 - 107:
/KEYS RETCTR_NF, RTY_NF, RETSEC_NF
/CONDITION NONPROP RETCTRCAT_CF = "02" OR  RETCTRCAT_CF = "2"
/INCLUDE NONPROP
exit
EOF
SORT

NSTEP=${NJOB}_37
#Temporary file deletion
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_07_${IB}_SORT_DVGTR_O.dat



###############################################################################
# Closing period process, special entries, cancellation TL files merge
###############################################################################

NSTEP=${NJOB}_38
# dGTAr merge
#-----------------------------------------------------------------------------
LIBEL="dGTAr merge in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDVGTAR} 1000 1"
SORT_I2="${EST_DLAGTAR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLTOTGTAR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

# [023]
NSTEP=${NJOB}_39
# MOD003 - Sort of DLTOTGTAR
#-----------------------------------------------------------------------------
LIBEL="Keep only Unique Line and Summarize for DLTOTGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_38_${IB}_SORT_DLTOTGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SUM_DLTOTGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15: EN,
        SCOENDMTH_NF 16:1 - 16: EN,
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
        TRN_NT          56:1 - 56:,
        RETROAUTO_B     58:1 - 58:
/KEYS SSD_CF,
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
        AMT_M,
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
        RETAMT_M,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        RETINTAMT_M,
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
exit
EOF
SORT


NSTEP=${NJOB}_40
# MOD003 - Sort of DLTOTGTAR
#-----------------------------------------------------------------------------
LIBEL="Sort of DLTOTGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_39_${IB}_SORT_SUM_DLTOTGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLTOTGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RTY_NF 27:1 - 27:EN,
        RETSEC_NF 26:1 - 26:EN,
        TRNCOD_CF 6:1 - 6:
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      TRNCOD_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[025]
NSTEP=${NJOB}_41
# EST_IGTAR Reconstitution
#-----------------------------------------------------------------------------
LIBEL="Keep only Unique Line and Summarize for IGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IGTAR} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SUM_IGTAR.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15: EN,
        SCOENDMTH_NF 16:1 - 16: EN,
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
        ZZRECONKEY_CF 55:1 - 55:,
        TRN_NT          56:1 - 56:,
        RETROAUTO_B     58:1 - 58:
/KEYS SSD_CF,
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
        AMT_M,
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
        RETAMT_M,
        PLC_NT,
        RTO_NF,
        INT_NF,
        RETPAY_NF,
        RETKEY_CF,
        RETINTAMT_M,
        ZZRECONKEY_CF,
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_42
# MOD003 -  Sort of IGTAR1
#-----------------------------------------------------------------------------
LIBEL="Sort of IGTAR 1"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_41_${IB}_SORT_SUM_IGTAR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IGTAR1_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RTY_NF 27:1 - 27:EN,
        RETSEC_NF 26:1 - 26:EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_CF_SUFIX 6:7 - 6:8,
        TRNCOD_CF_PREFIX 6:1 - 6:2
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      TRNCOD_CF
/CONDITION NONOUVERTURE (TRNCOD_CF_SUFIX NE "10" AND TRNCOD_CF_PREFIX NE "27")
/INCLUDE NONOUVERTURE
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_43
# MOD003 -  Sort of IGTAR2
#-----------------------------------------------------------------------------
LIBEL="Sort of IGTAR 2"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_41_${IB}_SORT_SUM_IGTAR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IGTAR2_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RTY_NF 27:1 - 27:EN,
        RETSEC_NF 26:1 - 26:EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_CF_SUFIX 6:7 - 6:8,
        TRNCOD_CF_PREFIX 6:1 - 6:2
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      TRNCOD_CF
/CONDITION OUVERTURE (TRNCOD_CF_SUFIX EQ "10" OR TRNCOD_CF_PREFIX EQ "27")
/INCLUDE OUVERTURE
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_45
#GTR merge and sort
#-----------------------------------------------------------------------------
LIBEL="GTR merge and sort and sort in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDVGTR} 1000 1"
SORT_I2="${EST_DLAGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLTOTGTR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

#[033]
#[034]
if [ -s ${DFILT}/${NJOB}_36_${IB}_SORT_IRDVPERICASE_O.dat ];
then
    NSTEP=${NJOB}_47
    # MOD003 - File generation Ventilation Retro Non Prop IGTAR 1
    #-----------------------------------------------------------------------------
    LIBEL="File generation Ventilation Retro Non Prop IGTAR 1"
    PRG=ESTC8805
    FPRM=`CFTMP`
    INPUT_TEXT ${FPRM} << EOF
    ICLODAT_D ${ICLODAT_D}
    BALSHTYEA_NF ${BALSHTYEA_NF}
    BALSHTMTH_NF ${BALSHTMTH_NF}
    TYPE_EDITION 1
    CRE_D ${CRE_D}
    CLODAT_D ${CLODAT_D}
    CUR_B F		
    exit
EOF
    export ${PRG}_PRM=${FPRM}
    export ${PRG}_I1=${DFILT}/${NJOB}_42_${IB}_SORT_IGTAR1_O.dat
    export ${PRG}_I2=${DFILT}/${NJOB}_27_${IB}_SORT_FTVENTNP_O.dat
    export ${PRG}_I3=${EST_FTRSLNK7}
    export ${PRG}_I4=${DFILT}/${NJOB}_36_${IB}_SORT_IRDVPERICASE_O.dat
    export ${PRG}_I5=${EST_FLIBEL2}
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SORT_IGTAR1_O.dat
    export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_SORT_IGTAR1_O.ano
    export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_VENTNP_TRIMCUR_O.dat   #[32]
    EXECPRG
else
    NSTEP=${NJOB}_48
    # Begin execksh
    #-----------------------------------------------------------------
    LIBEL="touch files IGTAR1"
    EXECKSH_MODE=P
    EXECKSH "touch ${DFILT}/${NJOB}_47_${IB}_ESTC8805_SORT_IGTAR1_O.dat"
fi

#[034]
if test -s ${EST_FVENTNPANT} && test -s ${DFILT}/${NJOB}_36_${IB}_SORT_IRDVPERICASE_O.dat
then
    NSTEP=${NJOB}_49
    # MOD003 - File generation Ventilation Retro Non Prop IGTAR 2 Ouvertures - L0
    #-----------------------------------------------------------------------------
    LIBEL="File generation Ventilation Retro Non Prop IGTAR 2"
    PRG=ESTC8805
    FPRM=`CFTMP`
    INPUT_TEXT ${FPRM} << EOF
    ICLODAT_D ${ICLODAT_D}
    BALSHTYEA_NF ${BALSHTYEA_NF}
    BALSHTMTH_NF ${BALSHTMTH_NF}
    TYPE_EDITION 2
    CRE_D ${CRE_D}
    CLODAT_D ${CLODAT_D}
    CUR_B F
    exit
EOF
    export ${PRG}_PRM=${FPRM}
    export ${PRG}_I1=${DFILT}/${NJOB}_43_${IB}_SORT_IGTAR2_O.dat
    export ${PRG}_I2=${DFILT}/${NJOB}_28_${IB}_SORT_FVENTNPANT_O.dat
    export ${PRG}_I3=${EST_FTRSLNK7}
    export ${PRG}_I4=${DFILT}/${NJOB}_36_${IB}_SORT_IRDVPERICASE_O.dat
    export ${PRG}_I5=${EST_FLIBEL2}
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_SORT_IGTAR2_O.dat
    export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_SORT_IGTAR2_O.ano
    export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_VENTL0_vide.dat   #[32]
    EXECPRG
else
    NSTEP=${NJOB}_50
    # Begin execksh
    #-----------------------------------------------------------------
    LIBEL="touch files IGTAR2"
    EXECKSH_MODE=P
    EXECKSH "touch ${DFILT}/${NJOB}_49_${IB}_ESTC8805_SORT_IGTAR2_O.dat"
fi

#[034]
if [ -s ${DFILT}/${NJOB}_36_${IB}_SORT_IRDVPERICASE_O.dat ];
then
    NSTEP=${NJOB}_53
    # MOD003 - File generation Ventilation Retro Non Prop TOTGTAR
    #-----------------------------------------------------------------------------
    LIBEL="File generation Ventilation Retro Non Prop TOTGTAR"
    PRG=ESTC8805
    FPRM=`CFTMP`
    INPUT_TEXT ${FPRM} << EOF
    ICLODAT_D ${ICLODAT_D}
    BALSHTYEA_NF ${BALSHTYEA_NF}
    BALSHTMTH_NF ${BALSHTMTH_NF}
    TYPE_EDITION 3
    CRE_D ${CRE_D}
    CLODAT_D ${CLODAT_D}
    CUR_B F
    exit
EOF
    export ${PRG}_PRM=${FPRM}
    export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_DLTOTGTAR_O.dat
    export ${PRG}_I2=${DFILT}/${NJOB}_27_${IB}_SORT_FTVENTNP_O.dat
    export ${PRG}_I3=${EST_FTRSLNK7}
    export ${PRG}_I4=${DFILT}/${NJOB}_36_${IB}_SORT_IRDVPERICASE_O.dat
    export ${PRG}_I5=${EST_FLIBEL2}
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLTOTGTAR_O.dat
    export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLTOTGTAR_O.ano
    export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_VENTNPGTAR_vide.dat   #[32]
    EXECPRG
else

  NSTEP=${NJOB}_54
    # Begin execksh
    #-----------------------------------------------------------------
    LIBEL="touch files DLTOTGTAR"
    EXECKSH_MODE=P
    EXECKSH "touch ${DFILT}/${NJOB}_53_${IB}_ESTC8805_DLTOTGTAR_O.dat"
fi
###############################################
# ------------------------- Fin   MOD003 --Integration Ventilation NP
###############################################


#-----------------------------------------------
#[021] Sauvegarde des fichiers
#-----------------------------------------------
NSTEP=${NJOB}_54_ZIP
#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_40_${IB}_SORT_DLTOTGTAR_O.dat                  >  ${DFILT}/${NJOB}_40_SORT_DLTOTGTAR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_41_${IB}_SORT_SUM_IGTAR.dat                    >  ${DFILT}/${NJOB}_41_SORT_SUM_IGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_42_${IB}_SORT_IGTAR1_O.dat                     >  ${DFILT}/${NJOB}_42_SORT_IGTAR1_O.dat.gz
gzip -c ${DFILT}/${NJOB}_43_${IB}_SORT_IGTAR2_O.dat                     >  ${DFILT}/${NJOB}_43_SORT_IGTAR2_O.dat.gz
gzip -c ${DFILT}/${NJOB}_47_${IB}_ESTC8805_SORT_IGTAR1_O.dat            >  ${DFILT}/${NJOB}_47_ESTC8805_SORT_IGTAR1_O.dat.gz
gzip -c ${DFILT}/${NJOB}_49_${IB}_ESTC8805_SORT_IGTAR2_O.dat            >  ${DFILT}/${NJOB}_49_ESTC8805_SORT_IGTAR2_O.dat.gz
gzip -c ${DFILT}/${NJOB}_53_${IB}_ESTC8805_DLTOTGTAR_O.dat              >  ${DFILT}/${NJOB}_53_ESTC8805_DLTOTGTAR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_47_${IB}_ESTC8805_VENTNP_TRIMCUR_O.dat > ${DFILT}/${NJOB}_47_ESTC8805_VENTNP_TRIMCUR_O.dat.gz


##############################################################################g
# All balance sheet year Retrocession by Acceptance and Retrocession TL files merge
###############################################################################

#NSTEP=${NJOB}_55
## All balance sheet year Retrocession by Acceptance TL files merge and sort
##-----------------------------------------------------------------------------
#LIBEL="Merge and sort of balance sheet year GTAr files in progress ..."
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_35_${IB}_SORT_DLTOTGTAR_O.dat 1000 1"
#SORT_I2="${EST_IGTAR} 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAR_O.dat 1000 1"
#INPUT_TEXT $SORT_CMD <<EOF


#[32]
if [ -s ${DFILT}/${NJOB}_47_${IB}_ESTC8805_VENTNP_TRIMCUR_O.dat ]
then

	if [ ! -f ${EST_VENTNP_TRIMPREV} ]
	then
		touch ${EST_VENTNP_TRIMPREV}
	fi
	
	# Traite l'allocation des NP
	gzip -c ${EST_VENTNP_TRIMCUR} > ${DSAV}/${SVG}_${NJOB}_VENTNP_TRIMCUR_O.dat.gz

	NSTEP=${NJOB}_55A
	# Invert NP Amounts on PREV file
	#-----------------------------------------------------------------------------
	LIBEL="Invert NP Amounts on PREV file"
	AWK_I=${EST_VENTNP_TRIMPREV}
	AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_VENTNP_TRIMPREV_annul.dat
	AWK_PARAM=" -v ICLODAT_D=${ICLODAT_D} "
	AWK_CMD=`CFTMP`
	INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{
			if (\$19  != 0) \$19  = sprintf("%-.3lf",-\$19 );
			if (\$35  != 0) \$35  = sprintf("%-.3lf",-\$35);
			if (\$41  != 0) \$41  = sprintf("%-.3lf",-\$41);
			\$3 = substr(ICLODAT_D,1,4);
			\$4 = substr(ICLODAT_D,5,2);
			\$5 = substr(ICLODAT_D,7,2);
			print \$0;
		}
exit
EOF
	AWK

	NSTEP=${NJOB}_55B
	# Begin sort
	#-----------------------------------------------------------------------------
	LIBEL="Sum Previous Ventilation NP with Current Ventilation"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_VENTNP_TRIMPREV} 1000 1"
	SORT_I2="${DFILT}/${NJOB}_55A_${IB}_AWK_VENTNP_TRIMPREV_annul.dat 1000 1"
	SORT_I3="${DFILT}/${NJOB}_47_${IB}_ESTC8805_VENTNP_TRIMCUR_O.dat 1000 1"
	SORT_O="${EST_VENTNP_TRIMCUR} 1000 1"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
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
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RETRTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M        35:1 - 35:EN 15/3,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        RETINTAMT_M     41:1 - 41: EN 15/3,
        TRN_NT          56:1 - 56:,
        RETROAUTO_B     58:1 - 58:,
        REC1             1:1 - 18:,
        REC2            20:1 - 34:,
        REC3            36:1 - 40:,
        FILLER_30_COL   42:1 - 71:
/KEYS REC1,
      REC2,
      REC3,
      FILLER_30_COL
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0)
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT REC1, AMT_MC, REC2, RETAMT_MC, REC3, RETINTAMT_MC, FILLER_30_COL
exit
EOF
	SORT

	NSTEP=${NJOB}_55C
	# Begin sort
	#-----------------------------------------------------------------------------
	LIBEL="Add NP Ventilations to GTAR"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_47_${IB}_ESTC8805_SORT_IGTAR1_O.dat 1000 1"
	SORT_I2="${EST_VENTNP_TRIMCUR} 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IGTAR1_O.dat 1000 1"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RTY_NF 27:1 - 27:EN,
        RETSEC_NF 26:1 - 26:EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_CF_SUFIX 6:7 - 6:8,
        TRNCOD_CF_PREFIX 6:1 - 6:2
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      TRNCOD_CF
exit
EOF
	SORT

	gzip -c ${DFILT}/${NJOB}_55C_${IB}_SORT_IGTAR1_O.dat > ${DFILT}/${NJOB}_55C_SORT_IGTAR1_O.dat.gz

	NSTEP=${NJOB}_55D
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="mv ${DFILT}/${NJOB}_55C_${IB}_SORT_IGTAR1_O.dat ${DFILT}/${NJOB}_55F_${IB}_ESTC8805_SORT_IGTAR1_O.dat"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${NJOB}_55C_${IB}_SORT_IGTAR1_O.dat ${DFILT}/${NJOB}_55F_${IB}_ESTC8805_SORT_IGTAR1_O.dat"

else

	NSTEP=${NJOB}_55E
	# MOD003 -  Sort of IGTAR1
	#-----------------------------------------------------------------------------
	LIBEL="Add NP Ventilations to GTAR"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_47_${IB}_ESTC8805_SORT_IGTAR1_O.dat 1000 1"
	SORT_I2="${EST_VENTNP_TRIMPREV} 1000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IGTAR1_O.dat 1000 1"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RTY_NF 27:1 - 27:EN,
        RETSEC_NF 26:1 - 26:EN,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD_CF_SUFIX 6:7 - 6:8,
        TRNCOD_CF_PREFIX 6:1 - 6:2
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      TRNCOD_CF
exit
EOF
	SORT

	gzip -c ${DFILT}/${NJOB}_55E_${IB}_SORT_IGTAR1_O.dat > ${DFILT}/${NJOB}_55E_SORT_IGTAR1_O.dat.gz

	NSTEP=${NJOB}_55F
	# Begin execksh
	#-----------------------------------------------------------------
	LIBEL="mv ${DFILT}/${NJOB}_55E_${IB}_SORT_IGTAR1_O.dat ${DFILT}/${NJOB}_55F_${IB}_ESTC8805_SORT_IGTAR1_O.dat"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${NJOB}_55E_${IB}_SORT_IGTAR1_O.dat ${DFILT}/${NJOB}_55F_${IB}_ESTC8805_SORT_IGTAR1_O.dat"

fi

gzip -c ${DFILT}/${NJOB}_55F_${IB}_ESTC8805_SORT_IGTAR1_O.dat > ${DFILT}/${NJOB}_55F_ESTC8805_SORT_IGTAR1_O.dat.gz

NSTEP=${NJOB}_55
# MOD003 - All balance sheet year Retrocession by Acceptance TL files merge and sort
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of balance sheet year GTAr files in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_53_${IB}_ESTC8805_DLTOTGTAR_O.dat 1000 1"
#SORT_I2="${DFILT}/${NJOB}_47_${IB}_ESTC8805_SORT_IGTAR1_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_55F_${IB}_ESTC8805_SORT_IGTAR1_O.dat 1000 1" #[32]
if test -s ${EST_FVENTNPANT}
then
	SORT_I3="${DFILT}/${NJOB}_49_${IB}_ESTC8805_SORT_IGTAR2_O.dat 1000 1"
else
	SORT_I3="${DFILT}/${NJOB}_43_${IB}_SORT_IGTAR2_O.dat 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
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
        TRNCOD1_CF 6:1 - 6:1
/KEYS RETCTR_NF,
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
      TRNCOD_CF
exit
EOF
SORT

NSTEP=${NJOB}_57
# EST_IGTAR Reconstitution
#-----------------------------------------------------------------------------
LIBEL="IGTAR1_0  + IGTAR2_0 ==> EST_IGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_47_${IB}_ESTC8805_SORT_IGTAR1_O.dat 1000 1"
SORT_I="${DFILT}/${NJOB}_55F_${IB}_ESTC8805_SORT_IGTAR1_O.dat 1000 1" #[32]
if test -s ${EST_FVENTNPANT}
then
	SORT_I2="${DFILT}/${NJOB}_49_${IB}_ESTC8805_SORT_IGTAR2_O.dat 1000 1"
else
	SORT_I2="${DFILT}/${NJOB}_43_${IB}_SORT_IGTAR2_O.dat 1000 1"
fi
SORT_O="${EST_IGTAR} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_60
# All balance sheet year Retrocession TL files merge and sort
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of balance sheet year GTR files in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_SORT_DLTOTGTR_O.dat 1000 1"
SORT_I2="${EST_IGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
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
        TRNCOD1_CF 6:1 - 6:1
/KEYS RETCTR_NF,
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
      TRNCOD_CF
exit
EOF
SORT

##################################
##  [MODIF 035] :IAS39 - START  ##
##################################
#The Balance Sheet month result
MTHFIN_NF=`echo ${ICLODAT_D} | awk '{ print substr($0,5,2)}'`
#generate start month quarter = month-2
MTHDEB_NF=`echo ${MTHFIN_NF} | awk '{ hist = $0 - 2; print hist }'`

NSTEP=${NJOB}_65A
# Sort and filter of IGTAR file 
#------------------------------------------------------------------------------
LIBEL="Sort and filter of IGTAR file ...."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_41_${IB}_SORT_SUM_IGTAR.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY_NF    3:1 -  3:EN,
        BALSHRMTH_NF  4:1 -  4:EN,
        TRNCOD_CF     6:1 -  6:,
        TRNCOD2_CF    6:2 -  6:2,
        TRNCOD8_CF    6:8 -  6:8,
        RETCTR_NF    24:1 - 24:,
        RETEND_NT    25:1 - 25:,
        RETSEC_NF    26:1 - 26:,
        RTY_NF       27:1 - 27:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      TRNCOD_CF
/CONDITION COND_TRIM ((BALSHEY_NF != ${BALSHTYEA_NF} OR (BALSHRMTH_NF > ${MTHFIN_NF} OR BALSHRMTH_NF < ${MTHDEB_NF}))) OR
                     ((TRNCOD2_CF = "1" OR TRNCOD2_CF = "2" OR TRNCOD2_CF = "3" OR TRNCOD2_CF = "4" ) AND (TRNCOD8_CF != "0" AND TRNCOD8_CF != "1")) AND
                     ( TRNCOD8_CF != "0" AND TRNCOD8_CF != "1")
/OMIT COND_TRIM
exit
EOF
SORT
#                      OR
#                      ((TRNCOD2_CF = "1" OR TRNCOD2_CF = "2" OR TRNCOD2_CF = "3") AND (TRNCOD8_CF != "0" AND TRNCOD8_CF != "1")))

NSTEP=${NJOB}_65B
#-----------------------------------------------------------------------------
# GTAr files merge
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of dGTAr files ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDVGTAR} 1000 1"
#SORT_I="${DFILT}/${NJOB}_20_${IB}_ESTM7603_DVGTAR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_65A_${IB}_SORT_IGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IFRSGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF    27:1 - 27:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF
exit
EOF
SORT

NSTEP=${NJOB}_65C
#-----------------------------------------------------------------------------
# traitement IAS39 (IFRS)
#----------------------------------------------------------------------------
LIBEL="IFRS  treatment"
PRG=ESTM2569
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${ICLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_02_${IB}_SORT_IRDVPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_65B_${IB}_SORT_IFRSGTR_O.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IFRS_GTR_O.dat
EXECPRG

NSTEP=${NJOB}_65D
#-----------------------------------------------------------------------------
# Sort of IFRSGTR file 
#-----------------------------------------------------------------------------
LIBEL="Sort of IFRSGTR file .... "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_65C_${IB}_ESTM2569_IFRS_GTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IFRS_GTR_O.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF    27:1 - 27:,
        RETUW_NT  28:1 - 28:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_65E
#-----------------------------------------------------------------------------
#Suppression des traites model IAS39
#-----------------------------------------------------------------------------
LIBEL="Delete of model and AS39 tratys ...."
PRG=ESTM2557
export ${PRG}_I1=${DFILT}/${NJOB}_65D_${IB}_SORT_IFRS_GTR_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_02_${IB}_SORT_IRDVPERICASE_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_IFRS_GTR_O.dat
EXECPRG

##################################
##  [MODIF 035] :IAS39 - END    ##
##################################


NSTEP=${NJOB}_70
# Begin programme C
# Current ACY transactions blanking for italian TOTGTAR only
#------------------------------------------------------------------------------
LIBEL="Current ACY transactions blanking for italian TOTGTAR only"
PRG=ESTM2561
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
ICLODAT_D ${ICLODAT_D}
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1="${DFILT}/${NJOB}_55_${IB}_SORT_TOTGTAR_O.dat"
export ${PRG}_I2="${EST_OIRDVPERICASE}"
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TOTGTAR_O1.dat
EXECPRG

#-----------------------------------------------
#[021] Sauvegarde des fichiers
#-----------------------------------------------
NSTEP=${NJOB}_70_ZIP
#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers 70"
gzip -c ${DFILT}/${NJOB}_55_${IB}_SORT_TOTGTAR_O.dat      >  ${DFILT}/${NJOB}_55_SORT_TOTGTAR_O.dat.gz
gzip -c ${DFILT}/${NJOB}_70_${IB}_ESTM2561_TOTGTAR_O1.dat >  ${DFILT}/${NJOB}_70_ESTM2561_TOTGTAR_O1.dat.gz

#-----------------------------------------------------------------------------
# Begin sort : italian blanking accumulation
#------------------------------------------------------------------------------
#[027]
NSTEP=${NJOB}_80
LIBEL="italian TOTGTAR blanking accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_ESTM2561_TOTGTAR_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
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
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RETRTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M        35:1 - 35:EN 15/3,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        RETINTAMT_M     41:1 - 41: EN 15/3,
        TRN_NT          56:1 - 56:,
        RETROAUTO_B     58:1 - 58:,
        REC1             1:1 - 18:,
        REC2            20:1 - 34:,
        REC3            36:1 - 40:,
        FILLER_15_COL   42:1 - 56:,
        FILLER_14_COL   58:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETCUR_CF,
      PLC_NT,
      RTO_NF,
      TRNCOD_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      TRN_NT,
      RETROAUTO_B
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD ORICOD_LS "GTA~"
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT REC1, AMT_MC, REC2, RETAMT_MC, REC3, RETINTAMT_MC, FILLER_15_COL, ORICOD_LS, FILLER_14_COL
exit
EOF
SORT

#-----------------------------------------------
#[021] Sauvegarde des fichiers
#-----------------------------------------------
NSTEP=${NJOB}_80_ZIP
#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers 80"
gzip -c ${DFILT}/${NJOB}_80_${IB}_SORT_TOTGTAR_O.dat      >  ${DFILT}/${NJOB}_80_SORT_TOTGTAR_O.dat.gz


#-----------------------------------------------------------------------------
# Begin sort : italian blanking accumulation and IFRS 
#------------------------------------------------------------------------------
NSTEP=${NJOB}_80A
LIBEL="italian TOTGTAR blanking accumulation + IFRS .... "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_SORT_TOTGTAR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_65E_${IB}_IFRS_GTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
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
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RETRTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M        35:1 - 35:EN 15/3,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        RETINTAMT_M     41:1 - 41: EN 15/3,
        TRN_NT          56:1 - 56:,
        RETROAUTO_B     58:1 - 58:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETCUR_CF,
      PLC_NT,
      RTO_NF,
      TRNCOD_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      BALSHRDAY_NF,
      TRN_NT,
      RETROAUTO_B
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_81
#Double entry transaction code addition in TOTGTAR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in TOTGTAR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_80A_${IB}_SORT_TOTGTAR_O.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_TOTGTAR_O.dat
EXECPRG

NSTEP=${NJOB}_83
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_80_${IB}_SORT_TOTGTAR_O.dat

#[024]
NSTEP=${NJOB}_85
#-------------------------------------------------------------------------
LIBEL="Merge and sort of balance sheet year GTAR files in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_SORT_TOTGTAR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_81_${IB}_ESTM7603_TOTGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
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
        TRNCOD1_CF 6:1 - 6:1
/KEYS  CTR_NF,
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
       TRNCOD_CF
exit
EOF
SORT

#[024]
NSTEP=${NJOB}_86
# exec awk
#-----------------------------------------------------------------------------
LIBEL="Update oricod_ls to EBSGTA for trn EBS"
AWK_I=${DFILT}/${NJOB}_85_${IB}_SORT_TOTGTAR_O.dat
AWK_O=${EST_TOTGTAR}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  { post = substr(\$6,2,1);
    if ( post == "A" || post == "B" || post == "D" || post == "E" || post == "G" ||
         post == "H" || post == "J" || post == "K" || post == "L" )
    {
      \$57 = "EBSGTA";
    }
    print \$0
  }
exit
EOF
AWK

#-----------------------------------------------
#[021] Sauvegarde des fichiers
#-----------------------------------------------
NSTEP=${NJOB}_53_ZIP
#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers 53"
gzip -c ${DFILT}/${NJOB}_53_${IB}_ESTC8805_DLTOTGTAR_O.dat      >  ${DFILT}/${NJOB}_53_ESTC8805_DLTOTGTAR_O.dat.gz

#[024]
NSTEP=${NJOB}_87
# All balance sheet year Retrocession by Acceptance TL files merge and sort
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of balance sheet year GTAr files in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_53_${IB}_ESTC8805_DLTOTGTAR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_81_${IB}_ESTM7603_TOTGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLTOTGTAR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
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
        TRNCOD1_CF 6:1 - 6:1
/KEYS RETCTR_NF,
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
      TRNCOD_CF
exit
EOF
SORT

#[025]
#[029]
NSTEP=${NJOB}_87B
# Begin Awk
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1xxxxxx4' en '1xxxxxx2' pour bilan 2014"
AWK_I=${DFILT}/${NJOB}_87_${IB}_SORT_DLTOTGTAR_O.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLTOTGTAR_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN { FS="\~"; OFS="\~" }
    {
      if (substr(\$6,1,1) == "2" && substr(\$6,8,1) == "4" && \$3 == 2014 && \$5 == 14)
      {
        \$6 = substr(\$6,1,7) "2";
        \$7 = substr(\$7,1,7) "2";
      }
      print \$0;
    }
exit
EOF
AWK

#[024]
NSTEP=${NJOB}_88
# exec awk
#-----------------------------------------------------------------------------
LIBEL="Update oricod_ls to EBSGTA for trn EBS"
AWK_I=${DFILT}/${NJOB}_87B_${IB}_AWK_DLTOTGTAR_O.dat
AWK_O=${EST_DLTOTGTAR}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  { post = substr(\$6,2,1);
    if ( post == "A" || post == "B" || post == "D" || post == "E" || post == "G" ||
         post == "H" || post == "J" || post == "K" || post == "L" )
    {
      \$57 = "EBSGTA";
    }
    print \$0
  }
exit
EOF
AWK

NSTEP=${NJOB}_89
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_35_${IB}_SORT_DLTOTGTAR_O.dat
RMFIL ${DFILT}/${NJOB}_55_${IB}_SORT_TOTGTAR_O.dat
RMFIL ${DFILT}/${NJOB}_81_${IB}_ESTM7603_TOTGTAR_O.dat

NSTEP=${NJOB}_100
#
#-----------------------------------------------------------------------------
# Begin sort  : italian blanking accumulation
#------------------------------------------------------------------------------
LIBEL="italian TOTGTR blanking accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_ESTM2561_TOTGTAR_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_65E_${IB}_IFRS_GTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
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
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT          56:1 - 56:,
        RETROAUTO_B     58:1 - 58:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      RETACY_NF,
      RETCUR_CF,
      TRNCOD_CF,
      BALSHEY_NF,
      BALSHRMTH_NF,
      TRN_NT,
      RETROAUTO_B
/SUMMARIZE TOTAL RETAMT_M,
           TOTAL RETINTAMT_M
exit
EOF
SORT

NSTEP=${NJOB}_105
#Double entry transaction code addition in TOTGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in TOTGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1="${DFILT}/${NJOB}_100_${IB}_SORT_TOTGTR_O.dat"
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1="${DFILT}/${NSTEP}_${IB}_${PRG}_TOTGTR_O.dat"
EXECPRG

NSTEP=${NJOB}_109
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion in progress"
RMFIL ${DFILT}/${NJOB}_100_${IB}_SORT_TOTGTR_O.dat

NSTEP=${NJOB}_110
# All balance sheet year Retrocession TL files merge and sort
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of balance sheet year GTR files in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_TOTGTR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_105_${IB}_ESTM7603_TOTGTR_O.dat 1000 1"
SORT_O="${EST_TOTGTR} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
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
        TRNCOD1_CF 6:1 - 6:1
/KEYS RETCTR_NF,
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
      TRNCOD_CF
exit
EOF
SORT

NSTEP=${NJOB}_113
# All balance sheet year Retrocession TL files merge and sort
#-----------------------------------------------------------------------------
LIBEL="Merge and sort of balance sheet year GTR files in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45_${IB}_SORT_DLTOTGTR_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_105_${IB}_ESTM7603_TOTGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLTOTGTR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 8:1 - 8:,
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
        TRNCOD1_CF 6:1 - 6:1
/KEYS RETCTR_NF,
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
      TRNCOD_CF
exit
EOF
SORT

#[025]
#[029]
NSTEP=${NJOB}_113B
# Begin Awk
#-----------------------------------------------------------------------------
LIBEL="Transforme TRNCOD en Norme EBS : '1xxxxxx4' en '1xxxxxx2' pour bilan 2014"
AWK_I=${DFILT}/${NJOB}_113_${IB}_SORT_DLTOTGTR_O.dat
AWK_O=${EST_DLTOTGTR}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN { FS="\~"; OFS="\~" }
    {
      if (substr(\$6,1,1) == "2" && substr(\$6,8,1) == "4" && \$3 == 2014 && \$5 == 14)
      {
        \$6 = substr(\$6,1,7) "2";
        \$7 = substr(\$7,1,7) "2";
      }
      print \$0;
    }
exit
EOF
AWK

NSTEP=${NJOB}_115
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Split GTR + DLTOTGTR ==> MGTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTR} 1000 1"
SORT_I2="${EST_DLTOTGTR} 800  1"
SORT_O=${EST_MGTR}
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY      3:1 - 3: EN,
        BALSHTMTH    4:1 - 4: EN
/CONDITION AVANT_PERIODE ( BALSHEY = ${BALSHTYEA_NF} and BALSHTMTH <= ${BALSHTMTH_NF})
/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_120
# Begin sort
#[017] ajout filiale 20 et 22
#[022] inversion de l'ordre du tri: SEC/UWY/UW passe à UWY/UW/SEC pour synchroniser avec le périmetre
#------------------------------------------------------------------------------
LIBEL="Split GTA + DLTOTGTAR ==> MGTAR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTA} 1000 1"
SORT_I2="${EST_DLTOTGTAR} 800  1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_MGTAR_O.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF           1:1 - 1:,
        ESB_CF           2:1 - 2:,
        BALSHEY_NF       3:1 - 3:EN,
        BALSHRMTH_NF     4:1 - 4:EN,
        BALSHRDAY_NF     5:1 - 5:EN,
        TRNCOD_CF        6:1 - 6:,
        TRNCOD1_CF       6:1 - 6:1,
        TRNCOD2          6:2 - 6:2,
        TRNCOD3          6:3 - 6:3,
        DBLTRNCOD_CF     7:1 - 7:,
        CTR_NF           8:1 - 8:,
        END_NT           9:1 - 9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:,
        CED_NF          20:1 - 20:,
        BRK_NF          21:1 - 21:,
        PAY_NF          22:1 - 22:,
        KEY_NF          23:1 - 23:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        INT_NF          38:1 - 38:,
        RETPAY_NF       39:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:
/KEYS CTR_NF,
      END_NT,
      UWY_NF,
      UW_NT,
      SEC_NF
/CONDITION EXTRAC ( ( BALSHEY_NF = ${BALSHTYEA_NF} and BALSHRMTH_NF <= ${BALSHTMTH_NF}) AND
                    ( TRNCOD1_CF EQ "4" OR TRNCOD1_CF EQ "2") AND
                    ( SSD_CF EQ "2" OR SSD_CF EQ "4" OR SSD_CF EQ "20" OR SSD_CF EQ "22" ) )
/OUTFILE ${SORT_O}
/INCLUDE EXTRAC
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
          AMT_M,
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
          RETAMT_M,
          PLC_NT,
          RTO_NF,
          INT_NF,
          RETPAY_NF,
          RETKEY_CF
exit
EOF
SORT


#[022] remplacé par en dessous
#[022] remplacé par en dessous NSTEP=${NJOB}_125
#[022] remplacé par en dessous #
#[022] remplacé par en dessous #----------------------------------------------------------------------------
#[022] remplacé par en dessous #[018] ${EST_IADVPERICASE} devient ${EST_IADVPERICASE_ENTIER}
#[022] remplacé par en dessous LIBEL="  MGTAR  treatment"
#[022] remplacé par en dessous PRG=ESTM2562
#[022] remplacé par en dessous export ${PRG}_I1=${EST_IADVPERICASE_ENTIER}
#[022] remplacé par en dessous export ${PRG}_I2=${DFILT}/${NJOB}_120_${IB}_SORT_MGTAR_O.dat
#[022] remplacé par en dessous export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_MGTAR_O.dat
#[022] remplacé par en dessous #export ${PRG}_O1=${EST_MGTAR}
#[022] remplacé par en dessous EXECPRG

NSTEP=${NJOB}_125
# Begin C Program
#----------------------------------------------------------------------------
LIBEL="  CMGTAR  modifications"
PRG=ESTM2563
export ${PRG}_I1=${EST_CADVPERIESB0}
export ${PRG}_I2=${DFILT}/${NJOB}_120_${IB}_SORT_MGTAR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_MGTAR_O.dat
EXECPRG



NSTEP=${NJOB}_130
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Split GTA + DLTOTGTAR ==> MGTAR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_125_${IB}_ESTM2563_MGTAR_O.dat 1000 1"
SORT_O="${EST_MGTAR}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
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
        AMT_M 19:1 - 19:,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
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
             AMT_M,
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
             RETAMT_M,
             PLC_NT,
             RTO_NF,
             INT_NF,
             RETPAY_NF,
             RETKEY_CF
exit
EOF
SORT

########################
# Erase temporary files #
########################
NSTEP=${NJOB}_135
LIBEL="Erase temporary & permanent files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat"
########################

JOBEND
