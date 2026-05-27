#!/bin/ksh
#=============================================================================
# nom de l'application    : ESTIMATIONS - INVENTAIRE
#                                 Fusion des GT retrocession
#                                 Ajout du poste de contrepartie
# nom du script SHELL : ESID2563.cmd
# revision            :
# date de creation    : 14/10/2015
# auteur              : Philippe PEZOUT
# references des specifications : :spot:
#-----------------------------------------------------------------------------
# description
#   Retrocession merge
#   Double entry transaction code addition
#
# Input files
#       EST_DLDVGTR                 DFILI
#       EST_DLGTRSNEM               DFILI
#       EST_DLREGTR                 DFILP
#       EST_DLREMAJGTR              DFILP
#       EST_DLRNPGTR                DFILP
#       EST_DLRPGTR                 DFILP
#       EST_DLRTCGTR                DFILP
#       EST_DLRTFGTR                DFILP
#       EST_DLRTGTR                 DFILP
#       EST_DLSGTR                  DFILI
#       EST_DLVGTR                  DFILP
#       EST_FDETTRS                 DFILI
#       EST_IRDVPERICASE            DFILP
#
# Output files
#       EST_DLDVGTR       DFILI
#
# Launch C program ESTM2561 ESTM7603
#
# job launched by ESID4000.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#_________________
#[01] 02/11/2015 P PEZOUT :spot:29615 EST45 gestion des doubles bouclettes RETRO et Déconnexion de l'EBS en variante 3 en INV
#[02] 22/01/2016 Florent  :spot:30087 prise en compte de 4 versions des ES dans EST_DLSGTR
#[03] 17/11/2016 Florent  :spot:31263 :spira:57394 Correction car les ES étaient mise 2 fois dans un SORT pour le POC EBS
#[04] 17/04/2019 R. Cassis :spira:65656 Normalisation fichiers entre IFRS et EBS
#[05] 01/10/2020 JYP :spira:83609 : microAOC : add IB into DFILT files
#[06] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[07] 21/06/2021  M.NAJI   : Spira 95833  remplacment de EST_ESPD2550_COND2 par NORME_CF
#[07] 24/03/2023  MZM   : SPIRA 108791 PROD - Missing Internal Assumed generated from AE booked on Internal Retro /  Prise en compte du fichier des AE 
#=================================================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters

BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
CLODAT_D=$3
CRE_D=$4
TYPEINV=$5
NORME=$6
BOUCLE=$7

##[04]
#if [ "${TYPEINV}" != "INV" ]
#then
##  EST_DLDVGTR=${EPO_DLDVGTR}
#  EST_FDETTRS=${EPO_FDETTRS}
#  EST_IRDVPERICASE=${EPO_OIRDVPERICASE}
#
#  EST_DLDVGTR=${EPO_DLDVGTRSO}
#  EST_DLDSIIGTR=${EPO_DLDSIIGTRSO}
#  EST_DLREGTR=${EPO_DLREGTRSO}
#  EST_DLREMAJGTR=${EPO_DLREMAJGTRSO}
#	EST_DLSGTR=${EPO_DLSGTRSO}
#
#  if [ "${TYPEINV}" = "POC" ]
#  then
#	  EST_DLDVGTR=${EPO_DLDVGTRCO}
#    EST_DLREGTR=${EPO_DLREGTRCO}
#    EST_DLREMAJGTR=${EPO_DLREMAJGTRCO}
#    EST_DLDSIIGTR=${EPO_DLDSIIGTRCO}
#		EST_DLSGTR=${EPO_DLSGTRCO}
#  fi
#  if [ "${NORME}" = "EBS" ]
#  then
#    if [ "${TYPEINV}" = "POS" ]
#    then
#		  EST_DLDVGTR=${EPO_DLDVGTRSIISO}
#      EST_DLSGTR=${EPO_DLSGTRSIISO}
#			EST_DLREGTR=${EPO_DLREGTRSIISO}
#			EST_DLREMAJGTR=${EPO_DLREMAJGTRSIISO}
#    else
#		  EST_DLDVGTR=${EPO_DLDVGTRSIICO}
#      EST_DLSGTR=${EPO_DLSGTRSIICO}
#			EST_DLREGTR=${EPO_DLREGTRSIICO}
#			EST_DLREMAJGTR=${EPO_DLREMAJGTRSIICO}
#    fi    
#  fi
#fi


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV..................: ${TYPEINV}"
ECHO_LOG "#===> NORME....................: ${NORME}"
ECHO_LOG "#===> BALSHTYEA_NF.............: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF.............: ${BALSHTMTH_NF}"
ECHO_LOG "#===> CLODAT_D.................: ${CLODAT_D}"
ECHO_LOG "#===> CRE_D....................: ${CRE_D}"
ECHO_LOG "#===> EST_FDETTRS..............: ${EST_FDETTRS}"
ECHO_LOG "#===> EST_DLDVGTR..............: ${EST_DLDVGTR}"
ECHO_LOG "#===> EST_DLREGTR..............: ${EST_DLREGTR}"
ECHO_LOG "#===> EST_DLREMAJGTR...........: ${EST_DLREMAJGTR}"
ECHO_LOG "#===> EST_DLSGTR...............: ${EST_DLSGTR}"
ECHO_LOG "#===> ESF_DLSGTR_AE............: ${ESF_DLSGTR_AE}"
ECHO_LOG "#===> EST_IRDVPERICASE.........: ${EST_IRDVPERICASE}"
if [ "${TYPEINV}" = "INV" ]
then
  ECHO_LOG "#===> EST_DLVGTR...............: ${EST_DLVGTR}"
  ECHO_LOG "#===> EST_DLRTCGTR.............: ${EST_DLRTCGTR}"
  ECHO_LOG "#===> EST_DLRTGTR..............: ${EST_DLRTGTR}"
  ECHO_LOG "#===> EST_DLRPGTR..............: ${EST_DLRPGTR}"
  ECHO_LOG "#===> EST_DLRNPGTR.............: ${EST_DLRNPGTR}"
  ECHO_LOG "#===> EST_DLRTFGTR.............: ${EST_DLRTFGTR}"
  ECHO_LOG "#===> EST_DLGTRSNEM............: ${EST_DLGTRSNEM}"
else
  if [ "${NORME}" = "EBS" ]
  then
    ECHO_LOG "#===> EST_DLDSIIGTR............: ${EST_DLDSIIGTR}"
  fi
fi
ECHO_LOG "#========================================================================="

if [[ ${BOUCLE} -eq 1 ]] ; then
  NSTEP=${NJOB}_01
  #-----------------------------------------------------------------
  LIBEL="Fichier créer dans ce job avant suppression de EST_DLDVGTR  ${EST_DLDVGTR}"
  RMFIL "${EST_DLDVGTR}"
fi

NSTEP=${NJOB}_02
#-----------------------------------------------------------------------------
LIBEL="Tri de ${EST_IRDVPERICASE} Extended with TFAMCHG_O"
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

if [ "${EST_ESID2560_COND1}" = "Y" -a "${TYPEINV}" = "INV" ]
then
  NSTEP=${NJOB}_12
  #-----------------------------------------------------------------------------
  LIBEL="Merging and sorting acceptance TL SNEM files..."
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I=${EST_DLGTRSNEM}
  SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_DLGTRSNEM_O.dat
  INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF     1:1 - 1:EN,
        TRNCOD_CF  6:1 - 6:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF    27:1 - 27:,
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

    NSTEP=${NJOB}_15
    #----------------------------------------------------------------------------
    LIBEL="DLGTRSNEM  treatment"
    PRG=ESTM2567
    export ${PRG}_I1=${DFILT}/${NJOB}_02_${IB}_SORT_IRDVPERICASE_O.dat
    export ${PRG}_I2=${DFILT}/${NJOB}_12_${IB}_SORT_DLGTRSNEM_O.dat
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLGTRSNEM_O.dat
    EXECPRG
else
    NSTEP=${NJOB}_15
    #----------------------------------------------------------------------------
    LIBEL="touch files _DLGTRSNEM_O"
    EXECKSH_MODE=P
    EXECKSH "touch ${DFILT}/${NJOB}_15_${IB}_ESTM2567_DLGTRSNEM_O.dat"
fi

###############################################
# Merge of dVGTR (set 21) and dDVGTR (lot 23) #
###############################################

NSTEP=${NJOB}_18
#-----------------------------------------------------------------------------
LIBEL="Fusion des GT retrocession"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_NOINFILE=YES
SORT_I="${EST_DLREGTR} 1000 1"
SORT_I2="${EST_DLREMAJGTR} 1000 1"
SORT_I3="${EST_DLSGTR} 1000 1"
SORT_I4="${ESF_DLSGTR_AE}  1000 1"
SORT_I5="${DFILT}/${NJOB}_15_${IB}_ESTM2567_DLGTRSNEM_O.dat 1000 1"
if [ "${TYPEINV}" = "INV" ]
then
  SORT_I6="${EST_DLVGTR} 1000 1"
  SORT_I7="${EST_DLRTCGTR} 1000 1"
  SORT_I8="${EST_DLRTGTR} 1000 1"
  SORT_I9="${EST_DLRPGTR} 1000 1"
  SORT_I10="${EST_DLRNPGTR} 1000 1"
  SORT_I11="${EST_DLRTFGTR} 1000 1"
  #SORT_I11="${EST_DLASIIGTR} 1000 1" #était pour l'EBS en INV
fi
# inventaire solvency EBS, [01] plus d'EBS en variante 3 en INV
#[007]
#if [ "${EST_ESPD2550_COND2}" = "Y" -a "${TYPEINV}" != "INV" ]
if [ "${NORME_CF}" = "EBS"  ]
then
  SORT_I12="${EST_DLDSIIGTR} 1000 1"
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DVGTR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF    6:1 -  6:,
        ORICOD_LS   57:1 - 57:,
        RETRO       24:1 - 34:,
        PLCRTO      36:1 - 37:
/KEYS TRNCOD_CF
/OUTFILE ${SORT_O}
exit
EOF
SORT

#on conserve l'ancien fichier du passage à partir de la première boucle
if [[ ${BOUCLE} -gt 1 ]] ; then
  NSTEP=${NJOB}_34
  LIBEL="Save the EST_DLDVGTR from the loop ${BOUCLE}"
  EXECKSH_MODE=P
  EXECKSH "cp ${EST_DLDVGTR} ${EST_DLDVGTR}_SAV"
fi

NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_18_${IB}_SORT_DVGTR_O.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${EST_DLDVGTR}
EXECPRG

gzip -c ${EST_DLDVGTR} > ${DFILT}/${NJOB}_035_${IB}_ESTM7603_DVGTR.dat.gz

#sortie de la boucle et de la chaîne si le fichier est le même
if [[ ${BOUCLE} -gt 1 ]] ; then
  if [[ $(cmp --silent ${EST_DLDVGTR} ${EST_DLDVGTR}_SAV; echo $?) -eq 0 ]] ; then
    NSTEP=${NJOB}_36
    LIBEL="Fin boucle ${BOUCLE}, fichiers ${EST_DLDVGTR} ${EST_DLDVGTR}_SAV identiques"
    RMFIL "${EST_DLDVGTR}_SAV"
    echo "fin boucle EST_DLDVGTR ${BOUCLE}" > ${ARRET_BOUCLE}
  fi
fi

NSTEP=${NJOB}_50
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
