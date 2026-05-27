#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 Integration des ecritures de cloture/ouverture et annulations post-omega EBS dans les fichiers GT
# nom du script SHELL           : ESPD8834.cmd
# revision                      : $Revision: 1.1.1.1 $ 
# date de creation              : 28/03/2018
# auteur                        : R. Cassis
# references des specifications : :spira:68016 Remise en ordre du shell
#-----------------------------------------------------------------------------
# description
#   Gestion des annulations trimestrielles et des ouvertures annuelles EBS et intégration dans les fichiers GTA-R et CURGTA-R
#   Mise a jour des tables EBS TCURSII, TLOBSII, TRATINGSII et des tables patterns solvency 
#   Creation des patterns POC sur le trimestre suivant a partir des patterns POS du trimestre
#
# job launched by ESPD88300.cmd
#-----------------------------------------------------------------------------
# historique des modifications:
#[001] 29/04/2019 R. Cassis :spira:65656 normalise noms de fichiers EBS
#[002] 02/08/2019 R. Cassis :spira:80329 Sauvegarde GTEPs et les remet a zero
#[003] 22/10/2019 R. Cassis :spira:81934 Sauvegarde DLEIFTECLEDSIIEP et le remet a zero
#[004] 02/12/2019 R. Cassis :spira:80329 Maintenant le FTECLEDRSIISO est pris en entrée pour générer les donnees CURGTR au lieu des fichiers du POSE - archivage CURGTx
#[005] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[006] 31/05/2021 C.SOCIE	:spira:91951 EST - ULR copy add new sp PuULR_01
#[007] 03/08/2021 R. Cassis :spira:91532 Gestion mapping archivage de fichiers
#[008] 12/10/2021 A.RUFFAULT :spira:99072 EST - IFRS17/EBS- Isolate pattern renewal procees in dedicated batch chain
#[009] 14/06/2023 F.CULIOLI :spira:91951 EST - ULR copy add new param BATCHUSER to sp PuULR_01
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
BATCHUSER=$5

#COND1="Y" where @IsEpo =  'Y' and @IsEpo31_12 = 'Y' and @IsEpoComptaRequestF = 'Y' -- comptabilisation annuelle
#COND2="Y" where @nb_NoEBS > 0


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> CONSOYEA................: ${CONSOYEA}"
ECHO_LOG "#===> CONSOMTH................: ${CONSOMTH}"
ECHO_LOG "#===> INVCONSO_D..............: ${INVCONSO_D}"
ECHO_LOG "#===> COND1..COMPTA ANNUELLE..: ${EST_ESPD8830_COND1}"
ECHO_LOG "#===> COND2..EBS..............: ${EST_ESPD8830_COND2}"

ECHO_LOG "#===> EPO_FTECLEDASIISO.......: ${EPO_FTECLEDASIISO}"
ECHO_LOG "#===> EPO_FTECLEDRSIISO.......: ${EPO_FTECLEDRSIISO}"
ECHO_LOG "#===> EPO_DLSGTRSIISO.........: ${EPO_DLSGTRSIISO}"
ECHO_LOG "#===> EPO_DLREJGTAASIISO......: ${EPO_DLREJGTAASIISO}"
ECHO_LOG "#===> EPO_DLREJGTARSIISO......: ${EPO_DLREJGTARSIISO}"
ECHO_LOG "#===> EPO_DLREJGTRSIISO.......: ${EPO_DLREJGTRSIISO}"
ECHO_LOG "#===> EPO_DLASIIGTRSO.........: ${EPO_DLASIIGTRSO}"
ECHO_LOG "#===> EPO_DLDSIIGTRSO.........: ${EPO_DLDSIIGTRSO}"
ECHO_LOG "#===> EPO_DLEIFTECLEDSIIEPSO..: ${EPO_DLEIFTECLEDSIIEPSO}"

ECHO_LOG "#===> EPO_DLREGTRSIISO........: ${EPO_DLREGTRSIISO}"
ECHO_LOG "#===> EPO_DLREMAJGTRSIISO.....: ${EPO_DLREMAJGTRSIISO}"

ECHO_LOG "#===> EST_CURGTA..............: ${EST_CURGTA}"
ECHO_LOG "#===> EST_CURGTR..............: ${EST_CURGTR}"
ECHO_LOG "#===> EST_GTA.................: ${EST_GTA}"
ECHO_LOG "#===> EST_GTR.................: ${EST_GTR}"
ECHO_LOG "#===> EPO_GTEPSIISO...........: ${EPO_GTEPSIISO}"
ECHO_LOG "#========================================================================="


if [ "${PARM_IS_YEARLY}" = "N" ]
then

	######################################################################################
	ECHO_LOG "#===> 1 COMPTABILISATION TRIMESTRIELLE NON ANNUELLE"
	######################################################################################

  # Cas d'annulations des trimestres 1-2-3 (Compta non annuelle pour IFRS et EBS)
  #[004] [005]
  NSTEP=${NJOB}_00
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="reformat du ${EPO_FTECLEDASIISO} en fichier CURGTA"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EPO_FTECLEDASIISO} 1000  1"
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

  NSTEP=${NJOB}_10
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_CURGTA} ${EPO_FTECLEDASIISO}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_CURGTA}    1000 1"
  SORT_I2="${DFILT}/${NJOB}_00_${IB}_SORT_CURGTA_O1.dat 1000 1"
  SORT_O=${DFILT}/${NSTEP}_${IB}_CURGTA_O.dat
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
  SORT

	#[004]
  NSTEP=${NJOB}_20
  # Begin Sort
  #-----------------------------------------------------------------
  LIBEL="Concatenation of files ${EST_CURGTR} ${EPO_FTECLEDRSO}"
  SORT_WDIR=${SORTWORK}
  SORT_CMD=`CFTMP`
  SORT_I="${EST_CURGTR}  1000 1"
  SORT_I2="${EPO_FTECLEDRSIISO} 1000 1"
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

  NSTEP=${NJOB}_30
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_CURGTA + DLSGTAxSO ==> EST_CURGTA"
  EXECKSH "mv ${DFILT}/${NJOB}_10_${IB}_CURGTA_O.dat ${EST_CURGTA}"

  NSTEP=${NJOB}_40
  # Begin sort
  #------------------------------------------------------------------------------
  LIBEL="move EST_CURGTR + ${EPO_FTECLEDRSIISO} ==> EST_CURGTR"
  EXECKSH "mv ${DFILT}/${NJOB}_20_${IB}_CURGTR_O.dat ${EST_CURGTR}"

fi

if [ ${PARM_IS_YEARLY} = "Y" ]
then

	######################################################################################
	ECHO_LOG "#===> 2 COMPTABILISATION ANNUELLE"
	######################################################################################

  # Cas de COMPTABILISATION ANNUELLE pour EBS
	# On ajoute directement aux CURGTx
 	NSTEP=${NJOB}_50
 	# Begin Sort
 	#-----------------------------------------------------------------
 	LIBEL="Concatenation of files ${EST_CURGTA} ${EPO_DLREJGTAASIISO} ${EPO_DLREJGTARSIISO}"
 	SORT_WDIR=${SORTWORK}
 	SORT_CMD=`CFTMP`
 	SORT_I="${EST_CURGTA}    1000 1"
 	SORT_I2="${EPO_DLREJGTAASIISO} 1000 1"
 	SORT_I3="${EPO_DLREJGTARSIISO} 1000 1"
 	SORT_O=${DFILT}/${NSTEP}_${IB}_CURGTA_O.dat
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
 	SORT

 	NSTEP=${NJOB}_60
 	# Begin Sort
 	#-----------------------------------------------------------------
 	LIBEL="Concatenation of files ${EST_CURGTR} ${EPO_DLREJGTRSIISO}"
 	SORT_WDIR=${SORTWORK}
 	SORT_CMD=`CFTMP`
 	SORT_I="${EST_CURGTR}  1000 1"
 	SORT_I2="${EPO_DLREJGTRSIISO} 1000 1"
 	SORT_O=${DFILT}/${NSTEP}_${IB}_CURGTR_O.dat
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
 	SORT

	NSTEP=${NJOB}_61
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Gzip fichiers en entree ${EST_CURGTA}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_CURGTA} > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTA_Avant_POSE_${INVCONSO_D}_${CRE_D}.dat.gz"
	
	#[017]
	NSTEP=${NJOB}_62
	# gzip fichiers
	#------------------------------------------------------------------------------
	LIBEL="Gzip fichiers en entree ${EST_CURGTR}"
	EXECKSH_MODE=P
	EXECKSH "gzip -c ${EST_CURGTR} > ${DARCH}/${ENV_PREFIX}_ESIX7000_CURGTR_Avant_POSE_${INVCONSO_D}_${CRE_D}.dat.gz"

  NSTEP=${NJOB}_70
  # Begin move
  #------------------------------------------------------------------------------
  LIBEL="move EST_GTA + DLREJGTAxSO ==> EST_CURGTA"
  EXECKSH "mv ${DFILT}/${NJOB}_50_${IB}_CURGTA_O.dat ${EST_CURGTA}"

  NSTEP=${NJOB}_80
  # Begin move
  #------------------------------------------------------------------------------
  LIBEL="move EST_GTR + EPO_DLREJGTRSIISO ==> EST_CURGTR"
  EXECKSH "mv ${DFILT}/${NJOB}_60_${IB}_CURGTR_O.dat ${EST_CURGTR}"

fi

NSTEP=${NJOB}_140
# gzip fichiers
#------------------------------------------------------------------------------
LIBEL="Gzip fichiers en entree"
EXECKSH_MODE=P

gzip -c ${EPO_FTECLEDRSO}          > ${EPO_FTECLEDRSO_ARC}       
gzip -c ${EPO_FTECLEDRSIISO}       > ${EPO_FTECLEDRSIISO_ARC}       
gzip -c ${EPO_FTECLEDASIISO}       > ${EPO_FTECLEDASIISO_ARC}       
gzip -c ${EPO_FCTRSTATSO}          > ${EPO_FCTRSTATSO_ARC}       
gzip -c ${EPO_FSEGSTATSO}          > ${EPO_FSEGSTATSO_ARC}       
gzip -c ${EST_GTSII_RISKMARGIN}    > ${EST_GTSII_RISKMARGIN_ARC}       
gzip -c ${EPO_DLSGTRSIISO}         > ${EPO_DLSGTRSIISO_ARC}       
gzip -c ${EPO_DLASIIGTRSO}         > ${EPO_DLASIIGTRSO_ARC}       
gzip -c ${EPO_DLDSIIGTRSO}         > ${EPO_DLDSIIGTRSO_ARC}       
gzip -c ${EPO_DLRGTAASIISO}        > ${EPO_DLRGTAASIISO_ARC}      
gzip -c ${EPO_DLREGTRSIISO}        > ${EPO_DLREGTRSIISO_ARC}      
gzip -c ${EPO_DLREMAJGTRSIISO}     > ${EPO_DLREMAJGTRSIISO_ARC}   
gzip -c ${EPO_GTEPSIISO}           > ${EPO_GTEPSIISO_ARC}         
gzip -c ${EPO_DLEIGTAA}            > ${EPO_DLEIGTAA_ARC}          
gzip -c ${EPO_DLEIFTECLEDSIIEPSO}  > ${EPO_DLEIFTECLEDSIIEPSO_ARC}
gzip -c ${EST_CURGTA}              > ${EST_CURGTA_Apres_POSE_ARC}
gzip -c ${EST_CURGTR}              > ${EST_CURGTR_Apres_POSE_ARC}

NSTEP=${NJOB}_141
#------------------------------------------------------------------------------
LIBEL="Erase files"
RMFIL ${EPO_GTEPSIISO}
RMFIL ${EPO_DLEIGTAA}
RMFIL ${EPO_DLRGTAASIISO}
RMFIL ${EPO_DLEIFTECLEDSIIEPSO}

touch ${EPO_GTEPSIISO}
touch ${EPO_DLEIGTAA}
touch ${EPO_DLRGTAASIISO}
touch ${EPO_DLEIFTECLEDSIIEPSO}

NSTEP=${NJOB}_200
#-----------------------------------------------------------------------------
LIBEL="table TCURSII TLOBSII TRATINGSII CLOSING_D update"
ISQL_BASE="BEST"
ISQL_QRY="exec PuSOLVENCY_01 '${INVCONSO_D}', '${CRE_D}'"
ISQL

##[008]
##NSTEP=${NJOB}_210
###-----------------------------------------------------------------------------
##LIBEL="table TPATSEGSII CLOSING_D update - Creation des patterns POC"
##ISQL_BASE="BEST"
##ISQL_QRY="exec PuSOLVENCY_02 '${INVCONSO_D}', '${CRE_D}', 'POS'"
##ISQL
##

#----------------------------------------------------------------------------
# Connect on the infocenter server
#----------------------------------------------------------------------------
NSTEP=${NJOB}_220
LIBEL="Connect on the infocenter server"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_230
#-----------------------------------------------------------------------------
LIBEL="table TCURSII TLOBSII TRATINGSII CLOSING_D update"
ISQL_BASE="BEST"
ISQL_QRY="exec PuSOLVENCY_01 '${INVCONSO_D}', '${CRE_D}'"
ISQL

##[008]
##NSTEP=${NJOB}_240
###-----------------------------------------------------------------------------
##LIBEL="table TPATSEGSII CLOSING_D update - Creation des patterns POC"
##ISQL_BASE="BEST"
##ISQL_QRY="exec PuSOLVENCY_02 '${INVCONSO_D}', '${CRE_D}', 'POS'"
##ISQL

JOBEND
