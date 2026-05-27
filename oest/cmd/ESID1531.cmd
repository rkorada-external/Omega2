#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESID1530.cmd
# revision                      : $Revision:   1.24  $
# date de creation              : 20/01/05
# auteur                        : J. RIBOT
# references des specifications : SPOT-5075
#-----------------------------------------------------------------------------
# description :
#   Predictions Update
#   Launch C programs ESTC7610
#
#   Output file sort
#          ${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat
#
#
# job launched by ESID2030.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
#[001]  20/04/2011  Roger Cassis    :spot:21655 - tris pas en numerique sur la section.
#[002]  12/06/2014  Mariem MECHRI   :           - modification de condition de tri de fichier CPLIFEST pour synchroniser avec le perimètre.
#[003]   7/08/2014  JBG             :spot:25773 - Correction using program ESTC7610
#[004]  19/09/2014  M.MECHRI        :spot:25773 - suppression des lignes en double de fichier LIFMOD et FLIFPEN
#[005]   6/10/2014  ABJ             :spot:25773 - Ajout du DETTRNCOD au tri pour le pg ESTC7610
#[006]  13/11/2015  NES             :spot:29658 - Ajout Webservice pour EST23a
#[007]  07/01/2016  S.Behague       :spot:29658 - Ajout appel Procédure PuLIFMOD_03
#[008]  11/01/2016  MBO             :spot:29658 - spira:43105 - Permet la continuité des tests en cas de crash du webService
#[009]  16/02/2016  MBO             :spot:30205 - spira:45724 - Correction, emploie de l'année de compte au lieu de l'année d'exercice pour les Notifications
#[010]  14/03/2016  MBO             :spot:30205 - spira:44606 - Ajout de toutes les sections d'un contrat à la fiche notif
#[011]	31/05/2016	MMA						  :spot 30679 - spira:50414 - Correction des notifications : 1/ On notifie uniquement le CTR/SEC/ACY impactés. 2/ Correction de l'ACY retourné
#[012]  20/04/2021  S.Behague :spira:89086 - APOLO QE : Compte complet yearly sur traité quaterly
#[013]  28/07/2022  S.Behague :spira:99820 Fiche mouvement - écart entre le calcul GUI et le calcul batch
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd


# Get input parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CRE_D=$3

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_01
#----------------------------------------------------------------------------
LIBEL="Launch BEST..PuLIFMOD_03"
ISQL_BASE="BEST"
ISQL_QRY="exec BEST..PuLIFMOD_03 '${CRE_D}', ${BALSHTYEA_NF}, ${BALSHTMTH_NF}"
ISQL

NSTEP=${NJOB}_05
# Delete internal retro for dbclo periode for CPLIFEST
#[002]
#------------------------------------------------------------------------------
LIBEL="Delete internal retro for dbclo periode for CPLIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CPLIFEST} 1000 1"
SORT_I2="${EST_CPLIFESTQ} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        CRE_D 6:1 - 6:,
        BALSHTMTH_NF 8:1 - 8:EN,
        ACY_NF 9:1 - 9:EN,
        ACMTRS_NT 14:1 - 14:,
        DETTRNCOD_CF    11:1 - 11:,
        GAAP_NF      10:1 - 10:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      GAAP_NF,
      BALSHTMTH_NF,
      CRE_D
/OUTFILE ${SORT_O}
/CONDITION ACY (( ACY_NF <=  `expr ${BALSHTYEA_NF} + 4`
        AND ACY_NF >= `expr ${BALSHTYEA_NF} - 4 ` ))
/INCLUDE ACY
exit
EOF
SORT

NSTEP=${NJOB}_07
#Syncro perimetre / ESTIMATION
#------------------------------------------------------------------------------
LIBEL="Syncro perimeter file / ESTIMATION"
PRG=ESTC7611
export ${PRG}_I1=${EST_IARVPERICASE0}
export ${PRG}_I2=${DFILT}/${NJOB}_05_${IB}_SORT_LIFEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LIFEST_O.dat
EXECPRG

NSTEP=${NJOB}_15
#
#Tri
#[005]
#------------------------------------------------------------------------------
LIBEL="Tri CPLIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_07_${IB}_ESTC7611_LIFEST_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        CRE_D 6:1 - 6:,
        BALSHEY_NF 7:1 - 7:,
        BALSHTMTH_NF 8:1 - 8:EN,
        ACY_NF 9:1 - 9:EN,
        PRS_CF 13:1 - 13:,
        ACMTRS_NT 14:1 - 14:,
        SSD_CF 15:1 - 15:,
        CUR_CF 16:1 - 16:,
        ESTMNT_M 17:1 - 17:EN 15/3,
        INDSUP_B 18:1 - 18:,
        ORICOD_LS 19:1 - 19:,
        CREUSR_CF 20:1 - 20:,
        LSTUPD_D 21:1 - 21:,
        LSTUPDUSR_CF 22:1 - 22:,
        DETTRNCOD_CF 11:1 - 11:,
        GAAP_NF      10:1 - 10:EN,
        ESB_CF       30:1 - 30:EN
/KEYS GAAP_NF,
      CTR_NF,
      END_NT,
      SEC_NF,
      ACY_NF,
      ESTMNT_M,
      UWY_NF,
      ACMTRS_NT,
      DETTRNCOD_CF,
      BALSHTMTH_NF,
      CRE_D
/OUTFILE ${SORT_O}
exit
EOF
SORT


ECHO_LOG "#===> EST_FLIFTHR...: ${EST_FLIFTHR}"

NSTEP=${NJOB}_20
# Estimates Calculations
#------------------------------------------------------------------------------
#[003]
LIBEL="Estimates Seuil Calculations"
PRG=ESTC7610
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_15_${IB}_SORT_LIFEST_O.dat
export ${PRG}_I2=${EST_FCURQUOT}
export ${PRG}_I3=${EST_CPLIFDRI}
export ${PRG}_I4=${EST_FLIFTHR}
export ${PRG}_I5=${EST_SUBTRSBASE}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FLIFMOD_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FLIFMOD2_O.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FLIFPEN_O.dat
EXECPRG


NSTEP=${NJOB}_25
#
#Tri
#------------------------------------------------------------------------------
LIBEL="Tri CPLIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_ESTC7610_FLIFMOD2_O.dat 1000 1"
SORT_O="${EST_FLIFMOD2}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        SEC_NF 2:1 - 2:,
        CRE_D 3:1 - 3:,
        BALSHTMTH_NF 5:1 - 5:EN,
        ACY_NF 6:1 - 6:EN,
        GAAP_NF      20:1 - 20:EN
/KEYS CTR_NF,
      SEC_NF,
      BALSHTMTH_NF,
      ACY_NF,
      GAAP_NF,
      CRE_D
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_30
#delete duplicate ligne from LIFMOD
#[004]
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_ESTC7610_FLIFMOD_O.dat 1000 1"
SORT_O=${EST_FLIFMOD}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER      1:1 - 5:
/KEYS FILLER
/SUM
/STABLE
exit
EOF
SORT

NSTEP=${NJOB}_35
#delete duplicate ligne from FLIFPLN
#[004]
#---------------------------------------------------------------------------
LIBEL="Summarizing file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_ESTC7610_FLIFPEN_O.dat 1000 1"
SORT_O=${EST_FLIFPEN}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS FILLER      1:1 - 5:
/KEYS FILLER
/SUM
/STABLE
exit
EOF
SORT


NSTEP=${NJOB}_40
#[011]
# Synchronisation des FIchiers LIFMOD et LIFMOD2
# On recherche les comptes complets:
#    - COMACC_B = 1 dans LIFMOD2
#    - ORICOD_LS = ARRETE_STAT , TYPMOD2_CT = 200 et DISPLAY_B = 1, dans LIFMOD 
# Pour chaque comptes complets, on retourne CTR/ACY/SEC
#-----------------------------------------------------------------------------
LIBEL="Extrait le plus recent Compte Complet, pour un CTR/SEC/ACY"
#FCT_DEBUG="YES"
AWK_I="${EST_FLIFMOD} ${EST_FLIFMOD2}"
AWK_O=${DFILT}/${NJOB}_CPLACC_NOTIF.dat
AWK_PARAM="-F~"
AWK_CMD=$(CFTMP)
INPUT_TEXT ${AWK_CMD} <<EOF
FNR==NR {
	if (\$7 == 200)
		{
			LIFMOD[\$1 FS \$2] = \$7
		}
	next
}
{
		if (\$7 == 1 && LIFMOD[\$1 FS \$2] == 200)
		{
			print \$1 FS \$6 FS \$2
		}
}
exit
EOF
AWK

NSTEP=${NJOB}_45
#[011]
# Trie et dédoublonnage de la liste de Comptes Complets sur la clé CTR/ACY/SEC
#------------------------------------------------------------------------------
LIBEL="Tri le fichier de notification "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_CPLACC_NOTIF.dat
SORT_O=${DFILT}/${NJOB}_${IB}_CPLACC_NOTIF_SORT.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
		ACY_NF 2:1 - 2: EN,
		SEC_NF 3:1 - 3: EN
/KEYS 	CTR_NF,
		ACY_NF,
		SEC_NF
/SUM
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_50
#[011]
#On retourne, pour le dernier update de la clé CTR/ACY, les champs CTR/ACY/USR
#-----------------------------------------------------------------------------
LIBEL="Extrait le plus recent Compte Complet, pour un CTR/ACY"
AWK_I=${EST_FCPLACC}
AWK_O=${DFILT}/${NJOB}_MAX_LIGHT_FCPLACC.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="~"; OFS="~"; print "Mémorisation de votre fichier"}
	{
		if (a[\$2 FS \$3] < \$6){
			a[\$2 FS \$3] = \$6;
			ACC[\$2 FS \$3] = \$8
		}
		next
	}
END{
	print "ENDJOB";
	for(x in ACC)print x FS ACC[x]
}
exit
EOF
AWK

NSTEP=${NJOB}_55
#[011]
#Trie de la liste de FCPLACC light
#------------------------------------------------------------------------------
LIBEL="Tri le fichier de notification "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_MAX_LIGHT_FCPLACC.dat
SORT_O=${DFILT}/${NJOB}_${IB}_MAX_LIGHT_FCPLACC_SORT.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 			1:1 - 1:,
		ACY_NF 			2:1 - 2: EN,
		LSTUPDUSR_CF	3:1 - 3:
/KEYS 	CTR_NF,
		ACY_NF
/SUM
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_60

#[011]
# Merge des fichiers CPLACC_NOTIF et FLIFMOD_LIGHT_MAX_UWY
# Merge le deux fichiers en fonction de CTR_NF/ACY
# On retourne en sortie un fichier au format CTR/SEC/ACY/"1"/"0"/USR
#-----------------------------------------------------------------------------
LIBEL="Merge de CPLACC_NOTIF et FLIFMOD_LIGHT_MAX_UWY"
AWK_I="${DFILT}/${NJOB}_${IB}_MAX_LIGHT_FCPLACC_SORT.dat ${DFILT}/${NJOB}_${IB}_CPLACC_NOTIF_SORT.dat"
AWK_O=${DFILT}/${NJOB}_${IB}_NOTIFICATION.dat
AWK_PARAM="-F~"
AWK_CMD=$(CFTMP)
INPUT_TEXT ${AWK_CMD} <<EOF
FNR==NR{a[\$1,\$2]=\$3; next}{print \$1 FS \$3 FS \$2 FS "1" FS "0" FS a[\$1,\$2]}
exit
EOF
AWK

grep -v "~$" ${DFILT}/${NJOB}_${IB}_NOTIFICATION.dat > ${DFILT}/${NSTEP}_${IB}_NOTIFICATION_ACCEPT.dat
grep "~$" ${DFILT}/${NJOB}_${IB}_NOTIFICATION.dat > ${DFILT}/${NSTEP}_${IB}_NOTIFICATION.ANO

gzip -c ${DFILT}/${NSTEP}_${IB}_NOTIFICATION_ACCEPT.dat > ${DFILT}/${NSTEP}_${IB}_NOTIFICATION.dat.gz 

    
NSTEP=${NJOB}_70
#Calling Webservice EST23a
#[006]
#----------------------------------------------------------------------------
LIBEL="Calling Webservice"
WS_BATCH_NAME=EST817820  # Nom du prog JAVA
WS_PARAMS_TEXT <<EOF
INPUT_FILE     ${DFILT}/${NJOB}_${IB}_NOTIFICATION_ACCEPT.dat
EOF
    WS_OUTPUT_FILE=${DFILT}/${NSTEP}_${IB}_${WS_BATCH_NAME}_O.dat
    #[008] MBO
    EXCEPTION_PROCESS="ON"
    STEPEND_CONTINUE="NO"
    WARNING="YES"
    #[008] !MBO
    WS_BATCH
NSTEP=${NJOB}_60
# Deletion of Temporary Files
#------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_*.dat"
echo "delete file tmp"
# Job End
JOBEND
