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
#[01] 02/11/2015 P PEZOUT :spot:29615 EST45 gestion des doubles bouclettes RETRO et D�connexion de l'EBS en variante 3 en INV
#[02] 22/01/2016 Florent  :spot:30087 prise en compte de 4 versions des ES dans EST_DLSGTR
#[03] 17/11/2016 Florent  :spot:31263 :spira:57394 Correction car les ES �taient mise 2 fois dans un SORT pour le POC EBS
#[04] 17/04/2019 R. Cassis :spira:65656 Normalisation fichiers entre IFRS et EBS
#[05] 01/10/2020 JYP :spira:83609 : microAOC : add IB into DFILT files
#[06] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[07] 21/06/2021  M.NAJI   : Spira 95833  remplacment de EST_ESPD2550_COND2 par NORME_CF
#[08] 24/03/2023  MZM   : SPIRA 108791 PROD - Missing Internal Assumed generated from AE booked on Internal Retro /  Prise en compte du fichier des AE 
#[09] 17/04/2024 M.NAJI	  :Spira 111511 Optimisation ESFD2550
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

let BOUCLE1=BOUCLE-1

EST_DLDVGTR=${DFILT}/${NCHAIN}_ESFD2663_${BOUCLE}_35_${IB}_SORT_DVGTR_O.dat
EST_DLDVGTR_SAVE=${DFILT}/${NCHAIN}_ESFD2663_${BOUCLE1}_35_${IB}_SORT_DVGTR_O.dat


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> BALSHTYEA_NF.............: ${BALSHTYEA_NF}"
ECHO_LOG "#===> NORBALSHTMTH_NFME........: ${BALSHTMTH_NF}"
ECHO_LOG "#===> CLODAT_D.................: ${CLODAT_D}"
ECHO_LOG "#===> CRE_D....................: ${CRE_D}"
ECHO_LOG "#===> TYPEINV..................: ${TYPEINV}"
ECHO_LOG "#===> NORME....................: ${TYNORMEPEINV}"
ECHO_LOG "#===> BOUCLE...................: ${BOUCLE}"
ECHO_LOG "#===> BOUCLE1..................: ${BOUCLE1}"
ECHO_LOG "#===> EST_DLDVGTR..............: ${EST_DLDVGTR}"
ECHO_LOG "#===> EST_DLDVGTR_SAVE.........: ${EST_DLDVGTR_SAVE}"
ECHO_LOG "#========================================================================="


if [[ ${BOUCLE} -eq 1 ]] ; then
  NSTEP=${NJOB}_01
  #-----------------------------------------------------------------
  LIBEL="Fichier cr�er dans ce job avant suppression de EST_DLDVGTR  ${EST_DLDVGTR}"
  RMFIL "${EST_DLDVGTR2}"
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
#SORT_I3="${EST_DLSGTR} 1000 1"
#SORT_I4="${ESF_DLSGTR_AE}  1000 1"
#SORT_I5="${DFILT}/${NJOB}_15_${IB}_ESTM2567_DLGTRSNEM_O.dat 1000 1"
#if [ "${TYPEINV}" = "INV" ]
#then
#  SORT_I6="${EST_DLVGTR} 1000 1"
#  SORT_I7="${EST_DLRTCGTR} 1000 1"
#  SORT_I8="${EST_DLRTGTR} 1000 1"
#  SORT_I9="${EST_DLRPGTR} 1000 1"
#  SORT_I10="${EST_DLRNPGTR} 1000 1"
#  SORT_I11="${EST_DLRTFGTR} 1000 1"
#  #SORT_I11="${EST_DLASIIGTR} 1000 1" #�tait pour l'EBS en INV
#fi
## inventaire solvency EBS, [01] plus d'EBS en variante 3 en INV
##[007]
##if [ "${EST_ESPD2550_COND2}" = "Y" -a "${TYPEINV}" != "INV" ]
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

##on conserve l'ancien fichier du passage � partir de la premi�re boucle
#if [[ ${BOUCLE} -gt 1 ]] ; then
#  NSTEP=${NJOB}_34
#  LIBEL="Save the EST_DLDVGTR2 from the loop ${BOUCLE}"
#  EXECKSH_MODE=P
#  EXECKSH "cp ${EST_DLDVGTR} ${EST_DLDVGTR}_SAV"
#fi

NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_18_${IB}_SORT_DVGTR_O.dat
export ${PRG}_I2=${EST_FDETTRS}
#export ${PRG}_O1=${EST_DLDVGTR}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_SORT_DVGTR_O.dat
EXECPRG

#gzip -c ${EST_DLDVGTR} > ${DFILT}/${NJOB}_035_${IB}_ESTM7603_DVGTR.dat.gz

#sortie de la boucle et de la cha�ne si le fichier est le m�me
if [[ ${BOUCLE} -gt 1 ]] ; then
  #if [[ $(cmp --silent ${EST_DLDVGTR} ${EST_DLDVGTR}_SAV; echo $?) -eq 0 ]] ; then
  ECHO_LOG"compare si ${EST_DLDVGTR} ${EST_DLDVGTR_SAVE}  sont identiques"
  if [[ $(cmp --silent ${EST_DLDVGTR} ${EST_DLDVGTR_SAVE}; echo $?) -eq 0 ]] ; then
    NSTEP=${NJOB}_36
    LIBEL="Fin boucle ${BOUCLE}, fichiers ${EST_DLDVGTR} ${EST_DLDVGTR_SAVE} identiques"
    #RMFIL "${EST_DLDVGTR}_SAV"
    echo "fin boucle EST_DLDVGTR ${BOUCLE}" > ${ARRET_BOUCLE}
  fi
fi

export EST_DLDVGTR_SAVE=${EST_DLDVGTR}

JOBEND
