#!/bin/ksh
#=============================================================================
# nom de l'application    : ESTIMATIONS -
#                           pr�paration des GTA et GTR � injecter dans l'infocentre ( ecritures Post omega CONSO )
# nom du script SHELL     : ESPD3802.cmd
# revision                : $Revision:   1.2  $
# date de creation        : 16/06/2005
# auteur                  : J. Ribot
# references des specifications	: SPOT 5085
#-----------------------------------------------------------------------------
# description
#   Generation of the Acceptance and Retrocession TL files
#   Utilise pour generer le SOCIAL EBS ou le CONSO IFRS ou le CONSO EBS
#
# Input files
#       EPO_DLSGTAACO     DFILI
#       EPO_DLSGTARCSO     DFILI
#       EPO_DLSGTRCSO      DFILI
#       EPO_FCPLACC		  	DFILP
#       EPO_FCTRGRO		  	DFILP
#       EPO_FPLC			    DFILP
#       EPO_FSOBBLOB		  DFILI
#       EPO_FSSDACTR		  DFILI
#       EPO_FTECLEDA			DFILP
#       EPO_FTECLEDR			DFILP
#       EPO_OIADVPERICASE	DFILI
#       EPO_OIRDVPERICASE	DFILI
#
# Output files
#       EPO_FTECLEDA			DFILP
#       EPO_FTECLEDR			DFILP
#
# Launch C program ESTC8801 8802 8803
#
# launched by ESID3800.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#[01]  04/05/2011  R. CASSIS     :spot:21408 - Modification OneGL
#[02]  31/07/2012  L. RAKOTOZAFY :spot:24041 Solvency II, corrections techniques
#[03]  01/08/2012  L. RAKOTOZAFY :spot:24041 Solvency II, corrections techniques
#[04] 26/11/2012 PPEZOUT :spot:24516 cr�ation, ECHANGES INTERNES POST OMEGA
#[05] 20/01/2013 :spot:24836 - -=PhP=-  corrections pour la conso
#[06] 20/01/2013 :spot:24855 - -=PhP=-  corrections pour la conso
#[07] 20/01/2013 :spot:24864 - -=PhP=-  corrections pour la conso
#[08] 20/01/2013 :spot:24867 - -=PhP=-  corrections pour la conso
#[09] 26/03/2013 PPEZOUT :spot:25034 VENTILATION DES gtar PAR PLACEMENT INTERNE
#[10] 29/05/2013 PPEZOUT :spot:25171 Modifications Solvency
#[11] 07/06/2013 R.Cassis :spot:25282 Modifications tri - pas de SUM
#[12] 25/11/2014 R. Cassis  :spot:27847 - Prise en compte des postes EBS LIFE %[GH]
#[13] 02/11/2015 P PEZOUT  :spot:29615
#[14] 18/03/2016 Florent  :spot:29066 GT � 71 colonnes
#[15] 20/09/2016 Florent  :spot:31251 spira 48151- EBS - UPR cancel - correction pour le mix of internal and external retrocessionaire
#[16] 21/09/2016 R. Cassis :spot:31263  Modifications pour traitement des annulations et ouvertures du CONSO EBS et IFRS
#[17] 24/02/2017 R. Cassis :spira:59429 Gestion des annulations CONSO IFRS et EBS
#[18] 12/07/2017 R. Cassis :spira:63001 Positionnement du speentnat_ct sur les fichiers d'annulations Social et Conso
#[19] 28/03/2018 MZM       :spira:64943: inconsitency RATECSII - RATECCLO : Ventilation d'un montant de r�tro (GTAR) entre retrocessionaire interne 
#                                       (de fa�on individuel si on avait plusieurs retro interne) et un global retro externe)
#																				Le step 09 est supprim� et le fichier en entr�e de ce step est positionn� en entr�e du step _10
#[20] 26/04/2018 MZM       :spira:65651: Generation du fichier de Ventilation des NP EPO_VENTNPSIISO et EPO_VENTNPSIICO au step _10
#[21] 09/05/2018 HHH       :spira:65651: Generation du fichier de Ventilation des NP EPO_VENTNPSIISO et EPO_VENTNPSIICO au step _10 : maj suite ABNORMAL END OF STEP 10  suite �
#										 (inversion entre EPO_VENTNPSIICO et EPO_VENTNPSIISO) ->JOB name T_ESPD3800_ESPD3802EBS - identifier dcvtsto2db02_20180508151425_16125,
#											ERROR: Step T_ESPD3800_ESPD3802EBS_10 has failed with return Code:9, error detail : Input file SORT_I5 not found: 1000
#[22] 21/08/2018 R. Cassis :spira:62219 Omission des postes ACMTRSL3 1018,1019,1022,1032,3087,3097 avec retro interne par prog ESTC1080
#[23] 13/11/2018 JYP revert: R. Cassis :spira:62219 Omission des postes ACMTRSL3 1018,1019,1022,1032,3087,3097 avec retro interne par prog ESTC1080
#[24] 07/12/2018 R. Cassis :spira:62219 Omission des postes ACMTRSL3 1018,1019,1022,1032,3087,3097 avec retro interne par prog ESTC1080
#[25] 07/01/2019 JYP : bugfix filename DLDGTAA EBS
#[26] 22/03/2019 MZM :spira:70671:Future premium for retro NP contracts : Ajout du fichier EPO_DLDGTR_E des future Premiums and Claims : Correction negation [26]
#[27] 13/03/2019 JYP :spira:71317: IFRS17 req 11.1 : send EXPENSES amounts to BO (excluding Paid expenses)
#[28] 17/04/2019 R. Cassis :Spira:65656 68628 Normalisation des fichiers pour separation IFRS/EBS et correction sur EPO_DLSGTAACO
#[29] 17/07/2019 R. Cassis :Spira:80029 Correction sur nom de fichier DLREGTAR et DLREMAJGTAR et ajout test norme EBS au step 60 
#[30] 07/08/2019 MZM :spira:79796:Future premium for retro NP contracts : Ajout du fichier EPO_DLDGTAR_E des future Premiums and Claims : pendant AR du DLDGTR_E
#[32] 20/01/2020 MZM :spira:71539:Future FUTURE RETRO OVERRIDES Ajout Fichiers : DLREGTAR_OVR et DLREGTR_OVR 
#[33] 14/02/2020 MZM :spira:71539:Future FUTURE RETRO OVERRIDES Suppression des Fichiers : DLREGTAR_OVR et DLREGTR_OVR
#[35] 02/04/2020 R. Cassis :Spira:85726 Omit BDT Assumed for EBS Tcode ..4161.. and ..4261.. and ..1008.. step 06 et suppression commandes gzip
#[36] 03/08/2020 R. Cassis :Spira:79427 L'omit des postes comptables avec retro interne est gere avec le fichier FPLATXCUM maintenant pour etre en accord avec le prog RETM0532
#[37] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[38] 07/07/2021 : M.NAJI   :. SPIRA 95833  remplacment des EST_COND_* - 2eme modif PARMA_IS_COMPTA remplace par PARM_IS_COMPTA - gestion speentnat INVE a 4
#[39] 03/08/2021 R. Cassis  :Spira:91532 Gestion des fichiers d'annulation au cas ou le POC du trimestre precedent n'est pas pass� et repositionnement du SPEENTNAT_CT
#[40] 23/08/2021 R. Cassis  :Spira:90957 Positionnement du SPEENTNAT_CT automatiquement
#[41] 10/01/2022 HR  :Spira:101272 EBS - Life calculation undue
#[42] 28/01/2022 R. Cassis  :Spira:91532 On met des double cotes dans les "if" pour �viter des messages d'erreur
#[43] 20/04/2022 R. Cassis  :Spira:103888 On retire une ligne parasite avant instruction "then" :param_IsEpoComptaRequestF=Y
#[44] 01/06/2022 D.REIXEIRA  :Spira:100702 Overwrite RETAMT & RETINTAMT for TRNCOD = 1XXXXXXXX
#-----------------------------------------------------------------------------
# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
CRE_D=$1
TYPEINV=$2
NORME=$3
ICLODAT_D=$4
CONSOYEA=$5
CONSOMTH=$6

moisbilan=`echo ${ICLODAT_D} | cut -c5-6`
# Ajout d'un trimestre au trimestre Post-omega
if [ "${CONSOMTH}" = "12" ]
then
	anmax=`expr ${CONSOYEA} + 1`
	moismax=01
	jourmax=31
else
	anmax=${CONSOYEA}
	moismax=`echo ${CONSOMTH} | awk '{ $0 = $0+3; if ($0 <12) print "0" $0; else print $0}'`
	jourmax=`echo ${moismax} | awk '{ if ($0 == 6 || $0 == 9) print "30"; else print "31"}'`
fi

#[40]
# POCI par defaut
SPEENTNAT_CT=3
if [ "${NORME}" = "EBS" ]
then
	if [ "${TYPEINV}" = "POC" ]
	then
		# POCE
		SPEENTNAT_CT=6
	else
		if [ "${TYPEINV}" = "POS" ]
		then
			# POSE
			SPEENTNAT_CT=5
		else
			# INVE
			SPEENTNAT_CT=4
		fi
	fi
fi

#	ESF_EXPENSES=$ESF_EXPENSES_POC
#else
#   if [ "${TYPEINV}" = "POS" ]
#   then
#	ESF_EXPENSES=$ESF_EXPENSES_POS
#   else
#	ESF_EXPENSES=$ESF_EXPENSES_INV
#   fi
#fi
#
## Ce job ne tourne que pour POCI, POCE, POSE
#
#if [ "${NORME}" = "EBS" ]
#then
#  if [ "${TYPEINV}" = "POS" ]
#  then
#    # POSE
#    EPO_DLSGTR=${EPO_DLSGTRSIISO}
#		EPO_DLREGTAR=${EPO_DLREGTARSIISO}
#		EPO_DLREGTR=${EPO_DLREGTRSIISO}
#		EPO_DLREMAJGTAR=${EPO_DLREMAJGTARSIISO}
#		EPO_DLREMAJGTR=${EPO_DLREMAJGTRSIISO}
#		EPO_DLRGTAA=${EPO_DLRGTAASIISO}
#		EPO_DLASIIGTR=${EPO_DLASIIGTRSO}
#		EPO_DLASIIGTAR=${EPO_DLASIIGTARSO}
#		EPO_DLASIIGTAA=${EPO_DLASIIGTAASO}
#		EPO_DLDSIIGTR=${EPO_DLDSIIGTRSO}
#		EPO_DLDGTR_E=${EPO_DLDGTRSIISO_E}
#		EPO_DLDGTAR_E=${EPO_DLDGTARSIISO_E}		
#    EPO_FTECLEDACO=${EPO_FTECLEDASIISO}
#    EPO_FTECLEDRCO=${EPO_FTECLEDRSIISO}   
#    EPO_GTSII_RISKMARGINCO=${EPO_GTSII_RISKMARGINSO}
#    EPO_GTSII_RISKMARGINCO_ARC=${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGINSO_${ICLODAT_D}_${CRE_D}.dat.gz
#    SPEENTNAT_CT=5
#  else
#    # POCE
#    EPO_DLSGTR=${EPO_DLSGTRSIICO}
#		EPO_DLREGTAR=${EPO_DLREGTARSIICO}
#		EPO_DLREGTR=${EPO_DLREGTRSIICO}
#		EPO_DLREMAJGTAR=${EPO_DLREMAJGTARSIICO}
#		EPO_DLREMAJGTR=${EPO_DLREMAJGTRSIICO}
#		EPO_DLRGTAA=${EPO_DLRGTAASIICO}
#		EPO_DLASIIGTR=${EPO_DLASIIGTRCO}
#		EPO_DLASIIGTAR=${EPO_DLASIIGTARCO}
#		EPO_DLASIIGTAA=${EPO_DLASIIGTAACO}
#		EPO_DLDSIIGTR=${EPO_DLDSIIGTRCO}
#		EPO_DLDGTR_E=${EPO_DLDGTRSIICO_E}
#		EPO_DLDGTAR_E=${EPO_DLDGTARSIICO_E}		
#    EPO_FTECLEDACO=${EPO_FTECLEDASIICO}
#    EPO_FTECLEDRCO=${EPO_FTECLEDRSIICO}    
#    EPO_GTSII_RISKMARGINCO_ARC=${ENV_PREFIX}_ESPD3700_GTSII_RISKMARGINCO_${ICLODAT_D}_${CRE_D}.dat.gz
#    SPEENTNAT_CT=6
#  fi
#else
##[29]
#	EPO_DLSGTR=${EPO_DLSGTRCO}
#	EPO_DLRGTAA=${EPO_DLRGTAACO}
#	EPO_DLREGTR=${EPO_DLREGTRCO}
#	EPO_DLREMAJGTR=${EPO_DLREMAJGTRCO}
#	EPO_DLREGTAR=${EPO_DLREGTARCO}
#	EPO_DLREMAJGTAR=${EPO_DLREMAJGTARCO}	
#fi

# Job Initialisation
JOBINIT

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME.........................: ${NORME}"
ECHO_LOG "#===> TYPEINV.......................: ${TYPEINV}"
ECHO_LOG "#===> anmax.........................: ${anmax}"
ECHO_LOG "#===> moismax.......................: ${moismax}"
ECHO_LOG "#===> jourmax.......................: ${jourmax}"
ECHO_LOG "#===> SPEENTNAT_CT..................: ${SPEENTNAT_CT}"
ECHO_LOG "#===> EPO_DLSGTAASIISO..............: ${EPO_DLSGTAASIISO}"
ECHO_LOG "#===> EPO_DLDGTAASO (not used)......: ${EPO_DLDGTAASO}"
ECHO_LOG "#===> EPO_DLDGTAASIISO..............: ${EPO_DLDGTAASIISO}"
ECHO_LOG "#===> EPO_DLDGTAASIICO..............: ${EPO_DLDGTAASIICO}"
ECHO_LOG "#===> EPO_DLDSIIGTAASO..............: ${EPO_DLDSIIGTAASO}"
ECHO_LOG "#===> EPO_DLSGTARSIISO..............: ${EPO_DLSGTARSIISO}"
ECHO_LOG "#===> EPO_DLRGTAA...................: ${EPO_DLRGTAA}"
ECHO_LOG "#===> EPO_DLREGTAR..................: ${EPO_DLREGTAR}"
ECHO_LOG "#===> EPO_DLREMAJGTAR...............: ${EPO_DLREMAJGTAR}"
ECHO_LOG "#===> EPO_DLDSIIGTARSO..............: ${EPO_DLDSIIGTARSO}"
ECHO_LOG "#===> EPO_DLSGTAASIICO..............: ${EPO_DLSGTAASIICO}"
ECHO_LOG "#===> EPO_DLDGTAACO (not used)......: ${EPO_DLDGTAACO}"
ECHO_LOG "#===> EPO_DLDSIIGTAACO..............: ${EPO_DLDSIIGTAACO}"
ECHO_LOG "#===> EPO_DLSGTARSIICO..............: ${EPO_DLSGTARSIICO}"
ECHO_LOG "#===> EPO_DLREGTARSIICO.............: ${EPO_DLREGTARSIICO}"
ECHO_LOG "#===> EPO_DLASIIGTR.................: ${EPO_DLASIIGTR}"
ECHO_LOG "#===> EPO_DLREGTR...................: ${EPO_DLREGTR}"
ECHO_LOG "#===> EPO_DLSGTR....................: ${EPO_DLSGTR}"
ECHO_LOG "#===> EPO_DLREMAJGTR................: ${EPO_DLREMAJGTR}"
ECHO_LOG "#===> EPO_DLDSIIGTR.................: ${EPO_DLDSIIGTR}"
ECHO_LOG "#===> EPO_DLREJGTAASIICO............: ${EPO_DLREJGTAASIICO}"
ECHO_LOG "#===> EPO_DLREJGTARSIICO............: ${EPO_DLREJGTARSIICO}"
ECHO_LOG "#===> EPO_DLREJGTRSIICO.............: ${EPO_DLREJGTRSIICO}"
ECHO_LOG "#===> EPO_DLSGTAACO.................: ${EPO_DLSGTAACO}"
ECHO_LOG "#===> EPO_DLSGTARCO.................: ${EPO_DLSGTARCO}"
ECHO_LOG "#===> EPO_FTECLEDACO................: ${EPO_FTECLEDACO}"
ECHO_LOG "#===> EPO_FTECLEDRCO................: ${EPO_FTECLEDRCO}"
ECHO_LOG "#===> EPO_FTECLEDASIICO_ANNULMVT....: ${EPO_FTECLEDASIICO_ANNULMVT}"
ECHO_LOG "#===> EPO_FTECLEDRSIICO_ANNULMVT....: ${EPO_FTECLEDRSIICO_ANNULMVT}"
ECHO_LOG "#===> EPO_FTECLEDACO_ANNULMVT.......: ${EPO_FTECLEDACO_ANNULMVT}"
ECHO_LOG "#===> EPO_FTECLEDRCO_ANNULMVT.......: ${EPO_FTECLEDRCO_ANNULMVT}"
ECHO_LOG "#===> EPO_OIADVPERICASE.............: ${EPO_OIADVPERICASE}"
ECHO_LOG "#===> EPO_FCTRGRO...................: ${EPO_FCTRGRO}"
ECHO_LOG "#===> EPO_FCPLACC...................: ${EPO_FCPLACC}"
ECHO_LOG "#===> EPO_FSOBBLOB..................: ${EPO_FSOBBLOB}"
ECHO_LOG "#===> EPO_FCLIENT...................: ${EPO_FCLIENT}"
ECHO_LOG "#===> EPO_VENTNPSIISO...............: ${EPO_VENTNPSIISO}"
ECHO_LOG "#===> EPO_VENTNPSIICO...............: ${EPO_VENTNPSIICO}"
ECHO_LOG "#===> EPO_DLDGTR_E..................: ${EPO_DLDGTR_E}"
ECHO_LOG "#===> EPO_DLDGTAR_E.................: ${EPO_DLDGTAR_E}"
ECHO_LOG "#===> ESF_EXPENSES .................: ${ESF_EXPENSES} "
# [41]
ECHO_LOG "#===> EPO_FESB .....................: ${EPO_FESB} "
ECHO_LOG "#========================================================================="

#[012][028]
NSTEP=${NJOB}_05
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLRGTAA} 1000 1"
SORT_I2="${EPO_DLASIIGTAA}"
SORT_I3="${EPO_DLDSIIGTAA}"
SORT_I4="${EPO_DLSGTAASII}"
SORT_I5="${EPO_DLDGTAASII}"
if [ -f "${ESF_EXPENSES}" ]
then
   SORT_I7="${ESF_EXPENSES}" 
fi
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAAIFRS_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAAEBS_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF     6:1 -  6:,
        TRNCOD2C_CF   6:2 -  6:2,
        TRNCOD2D_CF   6:8 -  6:8,
        TRNCOD5_CF    6:3 -  6:7,
        CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:,
        LIGNEGT       1:1 - 39:,
        RETKEY_CF    40:1 - 40:,
        RETINTAMT_M 41:1 - 41:,
        FILLER_30_COLS 42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/CONDITION COND_IFRS ("AEJ" NC TRNCOD2C_CF ) AND ("GH" NC TRNCOD2D_CF )
/CONDITION COND_EBS ( ("AEJG" CT TRNCOD2C_CF ) OR ("GH" CT TRNCOD2D_CF ) ) AND TRNCOD5_CF != "43614" AND TRNCOD5_CF != "46074"
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS
/REFORMAT LIGNEGT ,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_M,
          FILLER_30_COLS
/OUTFILE ${SORT_O2}
/INCLUDE COND_EBS
/REFORMAT LIGNEGT ,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_M,
          FILLER_30_COLS
exit
EOF
SORT

#[35]
NSTEP=${NJOB}_06
# Merge and sort of the Acceptance file
#------------------------------------------------------------------------------
LIBEL="Omit BDT Internal retro"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_DLSGTAAEBS_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAAEBS_O.dat OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF      6:1 -   6:,
        TRNCOD2_CF     6:3 -   6:6,
        CTR_NF         8:1 -   8:,
        END_NT         9:1 -   9:,
        SEC_NF        10:1 -  10:,
        UWY_NF        11:1 -  11:,
        UW_NT         12:1 -  12:,
        ORICOD_LS    104:1 - 104:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION COND_EBS ORICOD_LS = "OIGTA" AND (TRNCOD2_CF = "4161" OR TRNCOD2_CF = "4261" OR TRNCOD2_CF = "1008")
/OMIT COND_EBS
exit
EOF
SORT

NSTEP=${NJOB}_07
#Double entry transaction code addition in dDVGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in _DLSGTAA in progress ..."
PRG=ESTM7603
if [ "${NORME}" = "EBS" ]
then
  export ${PRG}_I1=${DFILT}/${NJOB}_06_${IB}_SORT_DLSGTAAEBS_O.dat  #[35]
else
  export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_DLSGTAAIFRS_O.dat
fi
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAA.dat
EXECPRG

NSTEP=${NJOB}_08
#DLSGTARSO sort
#-----------------------------------------------------------------------------
LIBEL="DLREGTARSO SORT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLREGTAR} 1000 1"
SORT_I2="${EPO_DLREMAJGTAR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTARSCO.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26:EN,
        RTY_NF    27:1 - 27:,
        PLC_NT    36:1 - 36:EN
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
exit
EOF
SORT

##[019]
##[011]
#NSTEP=${NJOB}_09
## Prog affectation retro interne
##-----------------------------------------------------------------------------
#LIBEL="Prog affectation retro interne"
#PRG=RETM0532
#export ${PRG}_I1=${EPO_FPLATXCUM}
#export ${PRG}_I2=${DFILT}/${NJOB}_08_${IB}_SORT_DLREGTARSCO.dat
#export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLREGTARSCO.dat
#EXECPRG
##[019] Fin  

#[012] [030] [032]
NSTEP=${NJOB}_10
# Merge and sort of the Acceptance and Retrocession files
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#[019] SORT_I="${DFILT}/${NJOB}_09_${IB}_RETM0532_DLREGTARSCO.dat 1000 1"
SORT_I="${DFILT}/${NJOB}_08_${IB}_SORT_DLREGTARSCO.dat 1000 1"
if [ "${TYPEINV}" = "POC" ]
then
	SORT_I2="${EPO_DLSGTARCO} 1000 1"
	if [ "${NORME}" = "EBS" ]
	then
		SORT_I2="${EPO_DLDSIIGTARCO} 1000 1"
		SORT_I3="${EPO_DLSGTARSIICO} 1000 1"
		SORT_I4="${EPO_VENTNPSIICO} 1000 1"		# [21]
	fi
else
	if [ "${NORME}" = "EBS" ]
	then
		SORT_I2="${EPO_DLDSIIGTARSO} 1000 1"
		SORT_I3="${EPO_DLSGTARSIISO} 1000 1"
		SORT_I4="${EPO_VENTNPSIISO} 1000 1"		#  [21]
	fi
fi
if [ -s ${EPO_DLDGTAR_E} -a "${NORME}" = "EBS" ]
then
	SORT_I5="${EPO_DLDGTAR_E} 1000 1"      # [030]
fi

SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTARIFRS_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAREBS_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF     6:1 -  6:,
        TRNCOD2C_CF   6:2 -  6:2,
        TRNCOD2D_CF   6:8 -  6:8,
        CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:,
        LIGNEGT       1:1 - 39:,
        RETCTR_NF    24:1 - 24:,
        RETEND_NT    25:1 - 25:EN,
        RETSEC_NF    26:1 - 26:EN,
        RTY_NF       27:1 - 27:,
        RETUW_NT     28:1 - 28:EN,
        PLC_NT       36:1 - 36:EN,
        RETKEY_CF    40:1 - 40:,
        RETINTAMT_M  41:1 - 41:,
        FILLER_30_COLS 42:1 - 71:
/KEYS RETCTR_NF,
      RTY_NF,	
      RETSEC_NF,
      PLC_NT,
     RETEND_NT,
      RETUW_NT,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF
/CONDITION COND_IFRS ("AEJ" NC TRNCOD2C_CF ) AND ("GH" NC TRNCOD2D_CF )
/CONDITION COND_EBS ("AEJG" CT TRNCOD2C_CF ) OR ("GH" CT TRNCOD2D_CF )
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS
/OUTFILE ${SORT_O2}
/INCLUDE COND_EBS
exit
EOF
SORT

NSTEP=${NJOB}_11
#------------------------------------------------------------------------------
if [ "${NORME}" = "EBS" ]; then
  LIBEL="Sort & filter EBS for ${EPO_DLASIIGTAR}"
  SORT_WDIR=${SORTWORK}
  SORT_I="${EPO_DLASIIGTAR} 1000 1"
  SORT_CMD=`CFTMP`
  SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLASIIGTAR_O.dat 1000 1"
  INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF     6:1 -  6:,
        TRNCOD2C_CF   6:2 -  6:2,
        TRNCOD2D_CF   6:8 -  6:8,
        CTR_NF        8:1 -  8:,
        END_NT        9:1 -  9:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:,
        LIGNEGT       1:1 - 39:,
        RETCTR_NF    24:1 - 24:,
        RETEND_NT    25:1 - 25:EN,
        RETSEC_NF    26:1 - 26:EN,
        RTY_NF       27:1 - 27:,
        RETUW_NT     28:1 - 28:EN,
        PLC_NT       36:1 - 36:EN,
        RETKEY_CF    40:1 - 40:,
        RETINTAMT_M  41:1 - 41:,
        FILLER_30_COLS 42:1 - 71:
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT,
     RETEND_NT,
      RETUW_NT,
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      TRNCOD_CF
/CONDITION COND_EBS ("AEJG" CT TRNCOD2C_CF ) OR ("GH" CT TRNCOD2D_CF )
/OUTFILE ${SORT_O}
/INCLUDE COND_EBS
exit
EOF
SORT
else
  touch ${DFILT}/${NSTEP}_${IB}_SORT_DLASIIGTAR_O.dat
fi

NSTEP=${NJOB}_20
# Explanations on SUM and STABLE options choice :
# SUM will take only one record according the key
# STABLE will allow to take the first input record from the records having the same key.
#---------------------------------------------------------------------------
LIBEL="Sort of EPO_FPLATXCUM"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EPO_FPLATXCUM}
SORT_O=${DFILT}/${NSTEP}_${IB}_FPLATXCUM.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:, 
        RETSEC_NF 2:1 - 2:EN, 
        RETRTY_NF 3:1 - 3:,
        PLC_NT    4:1 - 4:EN
/KEYS RETCTR_NF, RETRTY_NF, RETSEC_NF, PLC_NT
/SUM
/STABLE
exit
EOF
SORT

NSTEP=${NJOB}_40
# Prog affectation retro interne
#-----------------------------------------------------------------------------
LIBEL="Prog affectation retro interne"
PRG=RETM0532
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_FPLATXCUM.dat
if [ "${NORME}" = "EBS" ]
then
  export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAREBS_O.dat
else
  export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTARIFRS_O.dat
fi
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR.dat
EXECPRG

NSTEP=${NJOB}_45
# Merge and sort of the Acceptance and Retrocession files
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_RETM0532_DLSGTAR.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_11_${IB}_SORT_DLASIIGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF     6:1 - 6:,
        TRNCOD2C_CF   6:2 - 6:2,
        CTR_NF        8:1 - 8:,
        END_NT        9:1 - 9:,
        SEC_NF       10:1 - 10:,
        UWY_NF       11:1 - 11:,
        UW_NT        12:1 - 12:,
        LIGNEGT       1:1 - 39:,
        RETKEY_CF    40:1 - 40:,
        RETINTAMT_M  41:1 - 41:,
        FILLER_30_COLS 42:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD SEPARATEUR44  43"~"
/OUTFILE ${SORT_O}
/REFORMAT LIGNEGT ,
          RETKEY_CF ,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          SEPARATEUR44,
          RETINTAMT_M,
          FILLER_30_COLS
exit
EOF
SORT

NSTEP=${NJOB}_50
#Double entry transaction code addition in dDVGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_45_${IB}_SORT_DLSGTAR_O.dat
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR.dat
EXECPRG

NSTEP=${NJOB}_55
# File generation in TTECLEDA table format
#-----------------------------------------------------------------------------
LIBEL="Files generation in TTECLEDA table format"
PRG=ESTC8801
export ${PRG}_I1=${EPO_OIADVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_07_${IB}_ESTM7603_DLSGTAA.dat
export ${PRG}_I3=${EPO_FCTRGRO}
export ${PRG}_I4=${EPO_FCPLACC}
export ${PRG}_I5=${DFILT}/${NJOB}_50_${IB}_ESTM7603_DLSGTAR.dat
export ${PRG}_I6=${EPO_FSOBBLOB}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAA_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
EXECPRG

NSTEP=${NJOB}_58
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_DLSGTAAIFRS_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTARIFRS_O.dat
RMFIL ${DFILT}/${NJOB}_05_${IB}_SORT_DLSGTAAEBS_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_DLSGTAREBS_O.dat
RMFIL ${DFILT}/${NJOB}_07_${IB}_ESTM7603_DLSGTAA.dat
RMFIL ${DFILT}/${NJOB}_50_${IB}_ESTM7603_DLSGTAR.dat

#[011] [012] [26] [29] [32]
NSTEP=${NJOB}_60
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledger"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLSGTR} 1000 1"
SORT_I2="${EPO_DLREGTR} 1000 1"
SORT_I3="${EPO_DLREMAJGTR} 1000 1"  
if [ "${NORME}" = "EBS" ]
then
	SORT_I4="${EPO_DLDSIIGTR} 1000 1"
	SORT_I5="${EPO_DLASIIGTR} 1000 1"
fi
if [ -s ${EPO_DLDGTR_E} -a "${NORME}" = "EBS" ]
then
	SORT_I7="${EPO_DLDGTR_E} 1000 1"
fi

SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTRCO_O.dat 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTREBS_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS TRNCOD_CF     6:1 -  6:,
        TRNCOD2C_CF   6:2 -  6:2,
        TRNCOD2D_CF   6:8 -  6:8,
        RETCTR_NF    24:1 - 24:,
        RETEND_NT    25:1 - 25:,
        RETSEC_NF    26:1 - 26:,
        RTY_NF       27:1 - 27:,
        RETUW_NT     28:1 - 28:,
        PLC_NT       36:1 - 36:EN,
        LIGNEGT       1:1 - 39:,
        RETKEY_CF    40:1 - 40:,
        FILLER_16_COLS  56:1 - 71:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT,
      TRNCOD_CF
/DERIVEDFIELD DATTRAIT "${CRE_D}~"
/DERIVEDFIELD USER "CloP~"
/DERIVEDFIELD AJOUT_11_COLS 11"~"
/CONDITION COND_IFRS ("AEJ" NC TRNCOD2C_CF ) AND ("GH" NC TRNCOD2D_CF )
/CONDITION COND_EBS ("AEJG" CT TRNCOD2C_CF ) OR ("GH" CT TRNCOD2D_CF )
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          AJOUT_11_COLS,
          FILLER_16_COLS
/OUTFILE ${SORT_O2}
/INCLUDE COND_EBS
/REFORMAT LIGNEGT,
          RETKEY_CF,
          DATTRAIT,
          USER,
          DATTRAIT,
          USER,
          AJOUT_11_COLS,
          FILLER_16_COLS
exit
EOF
SORT

NSTEP=${NJOB}_70
#Double entry transaction code addition in dDVGTR
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition in dDVGTR in progress ..."
PRG=ESTM7603
if [ "${NORME}" = "EBS" ]
then
	export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_DLSGTREBS_O.dat
else
	export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_DLSGTRCO_O.dat
fi
export ${PRG}_I2=${EPO_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTR.dat
EXECPRG

NSTEP=${NJOB}_80
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Acceptance - Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_ESTC8801_FTECLEDAR_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDAR_O.dat 1000 1"
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
exit
EOF
SORT

NSTEP=${NJOB}_90
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_55_${IB}_ESTC8801_FTECLEDAR_O2.dat

NSTEP=${NJOB}_100
# File generation in TTECLEDR table format
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8802
export ${PRG}_I1=${EPO_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_80_${IB}_SORT_FTECLEDAR_O.dat
export ${PRG}_I3=${DFILT}/${NJOB}_70_${IB}_ESTM7603_DLSGTR.dat
export ${PRG}_I4=${EPO_FCLIENT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_O2.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDAR_REJETE_O4.dat
EXECPRG

#[001]
NSTEP=${NJOB}_110
#-----------------------------------------------------------------------------
LIBEL="File generation in TTECLEDR and TTECLEDA tables format"
PRG=ESTC8806
export ${PRG}_I1=${EPO_OIADVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_ESTC8802_FTECLEDR_FORMAT_AR_O3.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_FORMAT_AR_O3.dat
EXECPRG

NSTEP=${NJOB}_120
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_80_${IB}_SORT_FTECLEDAR_O.dat
RMFIL ${DFILT}/${NJOB}_60_${IB}_SORT_DLSGTRCO_O.dat

NSTEP=${NJOB}_130
# Sort of the Retrocession File
#------------------------------------------------------------------------------
LIBEL="Sort of Retrocession Technical Ledgers File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_ESTC8802_FTECLEDR_O1.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF    27:1 - 27:,
        RETUW_NT  28:1 - 28:,
        PLC_NT    36:1 - 36:
/KEYS RETCTR_NF,
      RTY_NF,
      PLC_NT
exit
EOF
SORT

NSTEP=${NJOB}_140
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_100_${IB}_ESTC8802_FTECLEDR_O1.dat


NSTEP=${NJOB}_160
# Update of SSDRTO_B ( internal retrocession )
#[001] remplacement du fichier ${PRG}_I2=${EST_FPLC} par export ${PRG}_I2=${EPO_FCLIENT}
#-----------------------------------------------------------------------------
LIBEL="Update of SSDRTO_B ( internal retrocession )"
PRG=ESTC8803
export ${PRG}_I1=${DFILT}/${NJOB}_130_${IB}_SORT_FTECLEDR_O.dat
#export ${PRG}_I2=${EPO_FCLIENT}
export ${PRG}_I2=${EPO_FPLACEMT2}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FTECLEDR_O.dat
EXECPRG

NSTEP=${NJOB}_165
#Temporary file deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_130_${IB}_SORT_FTECLEDR_O.dat

#[001]
if [ ! -f ${EPO_FTECLEDACO} ]
then
	touch ${EPO_FTECLEDACO}
fi

#[16]
NSTEP=${NJOB}_175
# Merge of TL files
#[003] ajout REFORMAT
#------------------------------------------------------------------------------
LIBEL="Merge of Technical Ledgers files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_ESTC8801_FTECLEDAA_O1.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_100_${IB}_ESTC8802_FTECLEDAR_O2.dat 1000 1"
SORT_I3="${DFILT}/${NJOB}_110_${IB}_ESTC8806_FTECLEDR_FORMAT_AR_O3.dat 1000 1"
#SORT_O="${EPO_FTECLEDACO} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat 1000 1"  #[24]
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
  ESB_CF 2:1 - 2:,
  BALSHEY_NF 3:1 - 3:,
  BALSHRMTH_NF 4:1 - 4:,
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
  CUR_CF 18:1 - 18:,
  AMT_M 19:1 - 19:EN 15/3,
  CED_NF 20:1 - 20:,
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
  PLC_NT 36:1 - 36:EN,
  RTO_NF 37:1 - 37:EN,
  RETINTAMT_M 88:1 - 88:EN 15/3,
  DEBUT   1:1 - 88:
/KEYS
  ESB_CF,
  BALSHEY_NF,
  BALSHRMTH_NF,
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
  CUR_CF,
  CED_NF,
  RETCTR_NF,
  RETEND_NT,
  RETSEC_NF,
  RTY_NF,
  RETUW_NT,
  RETOCCYEA_NF,
  RETACY_NF,
  RETSCOSTRMTH_NF,
  RETSCOENDMTH_NF,
  RETCUR_CF,
  PLC_NT,
  RTO_NF
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[24]
if [ "${NORME}" != "EBS" ]
then
	NSTEP=${NJOB}_176
	# RENAME GLT file
	#----------------------------------------------------------------------------
	LIBEL="rename GLT ${DFILT}/${NJOB}_175_${IB}_SORT_FTECLEDA_O.dat to ${EPO_FTECLEDACO}"
	EXECKSH_MODE=P
	EXECKSH "mv ${DFILT}/${NJOB}_175_${IB}_SORT_FTECLEDA_O.dat ${EPO_FTECLEDACO}"
else
#	NSTEP=${NJOB}_177
#	# Omit ACMTRS codes into FTECLEDA
#	#-----------------------------------------------------------------------------
#	LIBEL="Omit ACMTRS codes into FTECLEDA"
#	PRG=ESTC1080
#	export ${PRG}_I1=${DFILT}/${NJOB}_175_${IB}_SORT_FTECLEDA_O.dat
#	export ${PRG}_I2=${EPO_FCLIENT}
#	export ${PRG}_I3=${EPO_FBOPRSLNK}
#	export ${PRG}_O1=${EPO_FTECLEDACO}
#	EXECPRG

	#############################
	# [036] debut 1
	NSTEP=${NJOB}_177A
	# Filter first record of EPO_FPLATXCUM ctr keys
	#---------------------------------------------------------------------------
	LIBEL="Filter first record of EPO_FPLATXCUM ctr keys"
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

	NSTEP=${NJOB}_177B
	# Filter T.codes from EPO_FBOPRSLNK keys
	#---------------------------------------------------------------------------
	LIBEL="Filter T.codes from EPO_FBOPRSLNK keys"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I=${EPO_FBOPRSLNK_TXT}
	SORT_O=${DFILT}/${NSTEP}_${IB}_FBOPRSLNK.dat
	INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ACMTRSL3_NT  5:1 -  5:EN
       ,DETTRS_CF    9:1 -  9:
       ,TRNTYP_CT   14:1 - 14:EN
/CONDITION dettrs (ACMTRSL3_NT = 1018 OR ACMTRSL3_NT = 1019 OR ACMTRSL3_NT = 1022 OR 
                   ACMTRSL3_NT = 1032 OR ACMTRSL3_NT = 3087 OR ACMTRSL3_NT = 3097)
                   AND TRNTYP_CT > 100
/KEYS DETTRS_CF
/SUM
/INCLUDE dettrs
/REFORMAT DETTRS_CF
exit
EOF
	SORT

	NSTEP=${NJOB}_178A
	# Get internal Retro info by Join
	#------------------------------------------------------------------------------
	LIBEL="Get internal Retro info by Join"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_175_${IB}_SORT_FTECLEDA_O.dat 500 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat OVERWRITE 500 1 "
	INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF    24:1 -  24:,
        RETSEC_NF    26:1 -  26:,
        RTY_NF       27:1 -  27:,
        RTO_NF       37:1 -  37:,
        COLS1         1:1 - 118:,
        F_RETCTR_NF   1:1 -  1:,
        F_RETSEC_NF   2:1 -  2:,
        F_RTY_NF      3:1 -  3:,
        F_RTO_NF      4:1 -  4:
/joinkeys
         RETCTR_NF   
        ,RETSEC_NF   
        ,RTY_NF   
        ,RTO_NF    
/INFILE ${DFILT}/${NJOB}_177A_${IB}_FPLATXCUM.dat 100 1 "~"
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

	NSTEP=${NJOB}_178B
	# Get T. code from FBOPRSLNK info by Join
	#------------------------------------------------------------------------------
	LIBEL="Get T. code from FBOPRSLNK info by Join"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_178A_${IB}_SORT_FTECLEDA_O.dat 500 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat OVERWRITE 500 1 "
	INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF    6:1 -   6:
       ,F_TRNCOD_CF  1:1 -   1:
       ,COLS1        1:1 - 119:
/joinkeys
         TRNCOD_CF   
/INFILE ${DFILT}/${NJOB}_177B_${IB}_FBOPRSLNK.dat 100 1 "~"
/joinkeys
         F_TRNCOD_CF   
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:COLS1
       ,rightside:F_TRNCOD_CF
exit
EOF
	SORT

                #[41] LIFE and NON-LIFE
                NSTEP=${NJOB}_178C
                #------------------------------------------------------------------------------
                #filter of FESB life and non-life
                #-----------------------------------------------------------------------------
                LIBEL="Filter of FESB LIFE and NON-LIFE"
                SORT_WDIR=${DFILT}
                SORT_CMD=`CFTMP`
                SORT_I="${EPO_FESB} 500 1"
                SORT_O="${DFILT}/${NSTEP}_${IB}_FESB_LIFE.dat OVERWRITE 500 1"
                SORT_O2="${DFILT}/${NSTEP}_${IB}_FESB_NONLIFE.dat OVERWRITE 500 1"
                INPUT_TEXT ${SORT_CMD} << EOF
                /FIELDS LIFE_CF        9:1 -   9:
                /CONDITION COND_LIFE LIFE_CF EQ "1"
                /OUTFILE ${SORT_O}
                /INCLUDE COND_LIFE
                /OUTFILE ${SORT_O2}
                /OMIT COND_LIFE
exit
EOF
                SORT


                NSTEP=${NJOB}_178D
                #------------------------------------------------------------------------------
                #Sort-join and filter of EPO_FTECLEDACO LIFE
                #-----------------------------------------------------------------------------
                LIBEL="Sort-join and filter of EPO_FTECLEDACO LIFE"
                SORT_WDIR=${DFILT}
                SORT_CMD=`CFTMP`
                SORT_I="${DFILT}/${NJOB}_178B_${IB}_SORT_FTECLEDA_O.dat 500 1"
                SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat OVERWRITE 500 1"
                INPUT_TEXT ${SORT_CMD} << EOF
                /FIELDS SSD_CF           1:1 -   1:,
                        ESB_CF           2:1 -   2:,
                        F_SSD_CF         1:1 -   1:,
                        F_ESB_CF         2:1 -   2:,
                        ALL_COLS         1:1 -  120:
                /joinkeys
                        SSD_CF,
                        ESB_CF
                /INFILE ${DFILT}/${NJOB}_178C_${IB}_FESB_NONLIFE.dat 500 1 "~"
                /joinkeys
                         F_SSD_CF,
                         F_ESB_CF
                /OUTFILE ${SORT_O}
                /REFORMAT
                        leftside:ALL_COLS
exit
EOF
                SORT


                NSTEP=${NJOB}_178E
                #------------------------------------------------------------------------------
                #Sort-join and filter of EPO_FTECLEDACO NON-LIFE
                #-----------------------------------------------------------------------------
                LIBEL="Sort-join and filter of EPO_CTECLEDACO NON-LIFE"
                SORT_WDIR=${DFILT}
                SORT_CMD=`CFTMP`
                SORT_I="${DFILT}/${NJOB}_178B_${IB}_SORT_FTECLEDA_O.dat 500 1"
                SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDAL_O.dat OVERWRITE 500 1"
                INPUT_TEXT ${SORT_CMD} << EOF
                /FIELDS SSD_CF           1:1 -   1:,
                        ESB_CF           2:1 -   2:,
                        F_SSD_CF         1:1 -   1:,
                        F_ESB_CF         2:1 -   2:,
                        ALL_COLS         1:1 -  120:
                /joinkeys
                        SSD_CF,
                        ESB_CF
                /INFILE ${DFILT}/${NJOB}_178C_${IB}_FESB_LIFE.dat 500 1 "~"
                /joinkeys
                        F_SSD_CF,
                        F_ESB_CF
                /OUTFILE ${SORT_O}
                /REFORMAT
                        leftside:ALL_COLS
exit
EOF
                SORT

	#[40] [41]
	NSTEP=${NJOB}_179
	# Reformat FTECLEDA to standard nb cols and Omit internal retro for ACMTRSL3 codes
	#---------------------------------------------------------------------------
	LIBEL="Reformat FTECLEDA to standard nb cols and Omit internal retro for ACMTRSL3 codes"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	#SORT_I="${DFILT}/${NJOB}_178B_${IB}_SORT_FTECLEDA_O.dat 500 1"
	SORT_I="${DFILT}/${NJOB}_178D_${IB}_SORT_FTECLEDA_O.dat 500 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat OVERWRITE 500 1"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RTO_NF     119:1   - 119:
,DETTRS_CF  120:1   - 120:
,COLS1        1:1   - 105:
,COLS2      107:1   - 118:
/CONDITION toKeep RTO_NF = "" OR DETTRS_CF = ""
/DERIVEDFIELD SPEENTNAT "${SPEENTNAT_CT}~"
/COPY
/OUTFILE ${SORT_O}
/INCLUDE toKeep
/REFORMAT COLS1,SPEENTNAT,COLS2
exit
EOF
    SORT

# [44]
NSTEP=${NJOB}_180
LIBEL="Overwrite RETAMT & RETINTAMT for TRNCOD = 1XXXXXXXX"
AWK_I="${DFILT}/${NJOB}_179_${IB}_SORT_FTECLEDA_O.dat"
AWK_O="${EPO_FTECLEDACO}"
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
{
    if (substr(\$6, 1, 1) == "1" ) {
        \$35=0;
        \$88=0;
    }
    print \$0;
}
exit
EOF
AWK

	# [036] fin 1
	#############################
fi
	
NSTEP=${NJOB}_185
#------------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_55_${IB}_ESTC8801_FTECLEDAA_O1.dat
RMFIL ${DFILT}/${NJOB}_100_${IB}_ESTC8802_FTECLEDAR_O2.dat

NSTEP=${NJOB}_190
# Constitution of the new FTECLEDR file
#------------------------------------------------------------------------------
LIBEL="Constitution of the new FTECLEDR file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_160_${IB}_ESTC8803_FTECLEDR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_MERGE_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        PLC_NT 36:1 - 36:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT
exit
EOF
SORT

#[16]
if [ -s ${DFILT}/${NJOB}_190_${IB}_MERGE_FTECLEDR_O.dat ]
then
  NSTEP=${NJOB}_195
  #
  #-----------------------------------------------------------------------------
  LIBEL="Internal reference addition in the new FTECLEDR file"
  PRG=ESTC8804
  export ${PRG}_I1=${DFILT}/${NJOB}_190_${IB}_MERGE_FTECLEDR_O.dat
  export ${PRG}_I2=${EPO_FSSDACTR}
#  export ${PRG}_O1=${EPO_FTECLEDRCO}
  export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat
  EXECPRG
	#[24]
	if [ "${NORME}" != "EBS" ]
	then
		NSTEP=${NJOB}_196
		# RENAME GLT file
		#----------------------------------------------------------------------------
		LIBEL="rename GLT ${DFILT}/${NJOB}_195_${IB}_SORT_FTECLEDR_O.dat to ${EPO_FTECLEDACO}"
		EXECKSH_MODE=P
		EXECKSH "mv ${DFILT}/${NJOB}_195_${IB}_SORT_FTECLEDR_O.dat ${EPO_FTECLEDRCO}"
	else
#		NSTEP=${NJOB}_197
#		# Omit ACMTRS codes into FTECLEDA
#		#-----------------------------------------------------------------------------
#		LIBEL="Omit ACMTRS codes into FTECLEDA"
#		PRG=ESTC1080
#		export ${PRG}_I1=${DFILT}/${NJOB}_195_${IB}_SORT_FTECLEDR_O.dat
#		export ${PRG}_I2=${EPO_FCLIENT}
#		export ${PRG}_I3=${EPO_FBOPRSLNK}
#		export ${PRG}_O1=${EPO_FTECLEDRCO}
#		EXECPRG

		#############################
		# [036] debut 2
		NSTEP=${NJOB}_197A
		# Get internal Retro info by Join
		#------------------------------------------------------------------------------
		LIBEL="Get internal Retro info by Join"
		SORT_WDIR=${SORTWORK}
		SORT_CMD=`CFTMP`
		SORT_I="${DFILT}/${NJOB}_195_${IB}_SORT_FTECLEDR_O.dat 500 1"
		SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat OVERWRITE 500 1 "
		INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS RETCTR_NF    24:1 -  24:,
        RETSEC_NF    26:1 -  26:,
        RTY_NF       27:1 -  27:,
        RTO_NF       37:1 -  37:,
        COLS1         1:1 -  71:,
        F_RETCTR_NF   1:1 -  1:,
        F_RETSEC_NF   2:1 -  2:,
        F_RTY_NF      3:1 -  3:,
        F_RTO_NF      4:1 -  4:
/joinkeys
         RETCTR_NF   
        ,RETSEC_NF   
        ,RTY_NF   
        ,RTO_NF    
/INFILE ${DFILT}/${NJOB}_177A_${IB}_FPLATXCUM.dat 100 1 "~"
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

		NSTEP=${NJOB}_197B
		# Get T. code from FBOPRSLNK info by Join
		#------------------------------------------------------------------------------
		LIBEL="Get T. code from FBOPRSLNK info by Join"
		SORT_WDIR=${SORTWORK}
		SORT_CMD=`CFTMP`
		SORT_I="${DFILT}/${NJOB}_197A_${IB}_SORT_FTECLEDR_O.dat 500 1"
		SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat OVERWRITE 500 1 "
		INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS TRNCOD_CF    6:1 -   6:
       ,F_TRNCOD_CF  1:1 -   1:
       ,COLS1        1:1 -  72:
/joinkeys
         TRNCOD_CF   
/INFILE ${DFILT}/${NJOB}_177B_${IB}_FBOPRSLNK.dat 100 1 "~"
/joinkeys
         F_TRNCOD_CF   
/JOIN UNPAIRED leftside
/OUTFILE ${SORT_O}
/REFORMAT
        leftside:COLS1
       ,rightside:F_TRNCOD_CF
exit
EOF
		SORT

                #[41] LIFE and NON-LIFE
                NSTEP=${NJOB}_197C
                #------------------------------------------------------------------------------
                #filter of FESB life and non-life
                #-----------------------------------------------------------------------------
                LIBEL="Filter of FESB LIFE and NON-LIFE"
                SORT_WDIR=${DFILT}
                SORT_CMD=`CFTMP`
                SORT_I="${EPO_FESB} 500 1"
                SORT_O="${DFILT}/${NSTEP}_${IB}_FESB_LIFE.dat OVERWRITE 500 1"
                SORT_O2="${DFILT}/${NSTEP}_${IB}_FESB_NONLIFE.dat OVERWRITE 500 1"
                INPUT_TEXT ${SORT_CMD} << EOF
                /FIELDS LIFE_CF        9:1 -   9:
                /CONDITION COND_LIFE LIFE_CF EQ "1"
                /OUTFILE ${SORT_O}
                /INCLUDE COND_LIFE
                /OUTFILE ${SORT_O2}
                /OMIT COND_LIFE
exit
EOF
                SORT


                NSTEP=${NJOB}_197D
                #------------------------------------------------------------------------------
                #Sort-join and filter of EPO_FTECLEDRCO LIFE
                #-----------------------------------------------------------------------------
                LIBEL="Sort-join and filter of EPO_FTECLEDRCO LIFE"
                SORT_WDIR=${DFILT}
                SORT_CMD=`CFTMP`
                SORT_I="${DFILT}/${NJOB}_197B_${IB}_SORT_FTECLEDR_O.dat 500 1"
                SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat OVERWRITE 500 1"
                INPUT_TEXT ${SORT_CMD} << EOF
                /FIELDS SSD_CF           1:1 -   1:,
                        ESB_CF           2:1 -   2:,
                        F_SSD_CF         1:1 -   1:,
                        F_ESB_CF         2:1 -   2:,
                        ALL_COLS         1:1 -  73:
                /joinkeys
                        SSD_CF,
                        ESB_CF
                /INFILE ${DFILT}/${NJOB}_197C_${IB}_FESB_NONLIFE.dat 500 1 "~"
                /joinkeys
                         F_SSD_CF,
                         F_ESB_CF
                /OUTFILE ${SORT_O}
                /REFORMAT
                        leftside:ALL_COLS
exit
EOF
                SORT


                NSTEP=${NJOB}_197E
                #------------------------------------------------------------------------------
                #Sort-join and filter of EPO_FTECLEDRCO NON-LIFE
                #-----------------------------------------------------------------------------
                LIBEL="Sort-join and filter of EPO_FTECLEDRCO NON-LIFE"
                SORT_WDIR=${DFILT}
                SORT_CMD=`CFTMP`
                SORT_I="${DFILT}/${NJOB}_197B_${IB}_SORT_FTECLEDR_O.dat 500 1"
                SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDRL_O.dat OVERWRITE 500 1"
                INPUT_TEXT ${SORT_CMD} << EOF
                /FIELDS SSD_CF           1:1 -   1:,
                        ESB_CF           2:1 -   2:,
                        F_SSD_CF         1:1 -   1:,
                        F_ESB_CF         2:1 -   2:,
                        ALL_COLS         1:1 -  73:
                /joinkeys
                        SSD_CF,
                        ESB_CF
                /INFILE ${DFILT}/${NJOB}_197C_${IB}_FESB_LIFE.dat 500 1 "~"
                /joinkeys
                        F_SSD_CF,
                        F_ESB_CF
                /OUTFILE ${SORT_O}
                /REFORMAT
                        leftside:ALL_COLS
exit
EOF
                SORT


		#[40] [41]
		NSTEP=${NJOB}_198
		# Reformat FTECLEDR to standard nb cols and Omit internal retro for ACMTRSL3 codes
		#---------------------------------------------------------------------------
		LIBEL="Reformat FTECLEDR to standard nb cols and Omit internal retro for ACMTRSL3 codes"
		SORT_WDIR=${SORTWORK}
		SORT_CMD=`CFTMP`
		#SORT_I="${DFILT}/${NJOB}_197B_${IB}_SORT_FTECLEDR_O.dat 500 1"
		SORT_I="${DFILT}/${NJOB}_197D_${IB}_SORT_FTECLEDR_O.dat 500 1"
		SORT_O=${EPO_FTECLEDRCO}
		INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RTO_NF      72:1  -  72:
       ,DETTRS_CF   73:1  -  73:
       ,COLS1        1:1  -  58:
       ,COLS2       60:1  -  71:
/CONDITION toKeep RTO_NF = "" OR DETTRS_CF = ""
/DERIVEDFIELD SPEENTNAT "${SPEENTNAT_CT}~"
/COPY
/OUTFILE ${SORT_O}
/INCLUDE toKeep
/REFORMAT COLS1,SPEENTNAT,COLS2
exit
EOF
		SORT
		# [036] fin 2
		#############################
	
	fi
else
  NSTEP=${NJOB}_200
  LIBEL="Erase temporary files"
  RMFIL "${EPO_FTECLEDRCO}"

  NSTEP=${NJOB}_210
  # Copie fichiers
  #------------------------------------------------------------------------------
  LIBEL="touch ${EPO_FTECLEDRCO}"
  EXECKSH_MODE=P
  EXECKSH "touch ${EPO_FTECLEDRCO}"
fi

############################################################################
# [39] Gestion du fichier d'annulation s'il n'est pas du trimestre trait�, alors on le vide pour ne pas recharger un trimestre anterieur
############################################################################
if [ -s ${EPO_FTECLEDACO_ANNULMVT} ]
then
	anPOC=`head -1 ${EPO_FTECLEDACO_ANNULMVT} | cut -d~ -f3`
	moisPOC=`head -1 ${EPO_FTECLEDACO_ANNULMVT} | cut -d~ -f4`
	if [ ${moisPOC} -eq 1 ]
	then
		moisPOC=3
	fi
	echo "moisPOC=${moisPOC} - CONSOMTH=${CONSOMTH}"
	if [ ${CONSOYEA} -ne ${anPOC} -o ${CONSOMTH} -ne ${moisPOC} ]
	then
	  NSTEP=${NJOB}_220
	  LIBEL="Erase ${EPO_FTECLEDACO_ANNULMVT} ${EPO_FTECLEDRCO_ANNULMVT}"
	  RMFIL "${EPO_FTECLEDACO_ANNULMVT} ${EPO_FTECLEDRCO_ANNULMVT}"
		
	  NSTEP=${NJOB}_230
	  LIBEL="touch ${EPO_FTECLEDACO_ANNULMVT} ${EPO_FTECLEDRCO_ANNULMVT}"
	  EXECKSH_MODE=P
	  EXECKSH "touch ${EPO_FTECLEDACO_ANNULMVT} ${EPO_FTECLEDRCO_ANNULMVT}"
	fi
fi
	

############################################################################
#[16] Gestion POC IFRS Annulations ou ouvertures annuelles
############################################################################
#if [ ${EST_ESPD3800_COND1} = "N" -a ${EST_ESPD3800_COND2} = "N" -a ${EST_ESPD3800_COND3} = "Y" ]
#[38]
if [ "${NORME_CF}" = "I4I" -a "${TYPEINV}" = "POC" ]
then

	# mode CONSO - Norme IFRS - La Compta SOC IFRS faite
	#if [ ${EST_ESPD3800_COND4} = "Y" ]  # Flag Compta POC
	if [ "${PARM_IS_COMPTA}" = "Y" ]  # Flag Compta POC
	then

		########################
		# Type POC IFRS Booking
		########################

		if [ "${moisbilan}" != "12" ]
		then

			# Process quaterly not annual booking
			########################

			# Generate cancellations for RA
			########################
			NSTEP=${NJOB}_300
			# Generate cancellations 
			#-----------------------------------------------------------------------------
			LIBEL="Generate cancellations for Acceptation POC ${NORME} ${ICLODAT_D}"
			AWK_I=${EPO_FTECLEDACO}
			AWK_O=${EPO_FTECLEDACO_ANNULMVT}
			AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
			AWK_CMD=`CFTMP`
			INPUT_TEXT ${AWK_CMD} <<EOF
			BEGIN{ FS="\~"; OFS="\~" }
				{
					if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
					if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
					if (\$88  != 0) \$88 = sprintf("%-.3lf",-\$88);
					\$3 = an
					\$4 = mois
					\$5 = jour
					\$44 = "POST"
					\$106 = speentnat_ct
					print \$0;
				}
			exit
EOF
			AWK

			NSTEP=${NJOB}_310
			# Generate cancellations 
			#-----------------------------------------------------------------------------
			LIBEL="Generate cancellations for Retrocession POC ${NORME} ${ICLODAT_D}"
			AWK_I=${EPO_FTECLEDRCO}
			AWK_O=${EPO_FTECLEDRCO_ANNULMVT}
			AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
			AWK_CMD=`CFTMP`
			INPUT_TEXT ${AWK_CMD} <<EOF
			BEGIN{ FS="\~"; OFS="\~" }
				{
					\$3 = an
					\$4 = mois
					\$5 = jour
					if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
					if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
					\$44 = "POST"
					\$59 = speentnat_ct
					print \$0;
				}
			exit
EOF
			AWK	
	
		else
	
			# Process annual booking
			########################

			# Generate cancellations for RA
			########################

			NSTEP=${NJOB}_320
			# Generate cancellations 
			#-----------------------------------------------------------------------------
			LIBEL="Generate RA annual cancellations for Acceptation POC ${NORME} ${ICLODAT_D}"
			AWK_I=${EPO_FTECLEDACO}
			AWK_O=${EPO_FTECLEDACO_ANNULMVT}
			AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
			AWK_CMD=`CFTMP`
			INPUT_TEXT ${AWK_CMD} <<EOF
			BEGIN{ FS="\~"; OFS="\~" }
			{
				if (substr(\$6,2,1) == "4")
				{
					\$3 = an
					\$4 = mois
					\$5 = jour
					if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
					if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
					if (\$88  != 0) \$88 = sprintf("%-.3lf",-\$88);
					\$6 = substr(\$6,1,1) "7" substr(\$6,3,6)
					\$44 = "POST"
					\$106 = speentnat_ct
					print \$0
				}
			}
			exit
EOF
			AWK

			NSTEP=${NJOB}_330
			# Generate cancellations 
			#-----------------------------------------------------------------------------
			LIBEL="Generate RA annual cancellations for Retrocession POC ${NORME} ${ICLODAT_D}"
			AWK_I=${EPO_FTECLEDRCO}
			AWK_O=${EPO_FTECLEDRCO_ANNULMVT}
			AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
			AWK_CMD=`CFTMP`
			INPUT_TEXT ${AWK_CMD} <<EOF
			BEGIN{ FS="\~"; OFS="\~" }
			{
				if (substr(\$6,2,1) == "4")
				{
					\$3 = an
					\$4 = mois
					\$5 = jour
					if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
					if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
					\$6 = substr(\$6,1,1) "7" substr(\$6,3,6)
					\$44 = "POST"
					\$59 = speentnat_ct
					print \$0
				}
			}
			exit
EOF
			AWK
	
		fi
		
		# Archive Files
		########################

		NSTEP=${NJOB}_340
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDACO} to DARCH"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDACO} > ${EPO_FTECLEDACO_ARC}"

		NSTEP=${NJOB}_350
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDRCO} to DARCH"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDRCO} > ${EPO_FTECLEDRCO_ARC}"

		NSTEP=${NJOB}_360
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDACO_ANNULMVT} to DARCH"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDACO_ANNULMVT} > ${EPO_FTECLEDACO_ANNULMVT_ARC}"

		NSTEP=${NJOB}_370
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDRCO_ANNULMVT} to DARCH"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDRCO_ANNULMVT} > ${EPO_FTECLEDRCO_ANNULMVT_ARC}"

	else

		# Archivage cas non compta POC
		NSTEP=${NJOB}_380
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDACO} to DARCH"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDACO} > ${EPO_FTECLEDACO_ARC}"

		NSTEP=${NJOB}_390
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDRCO} to DARCH"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDRCO} > ${EPO_FTECLEDRCO_ARC}"

	fi
fi

############################################################################
#[16] Gestion POC EBS Annulations ou ouvertures annuelles
############################################################################
#if [ ${EST_ESPD3800_COND1} = "N" -a ${EST_ESPD3800_COND2} = "Y" -a ${EST_ESPD3800_COND5} = "Y" ]
#[38]
if [ "${NORME_CF}" = "EBS" -a "${TYPEINV}" = "POC" ]
then
	
	# mode Conso - EBS - Compta Soc EBS done
	#if [ ${EST_ESPD3800_COND4} = "Y" ]  # Flag Compta POC
	if [ "${PARM_IS_COMPTA}" = "Y" ]  # Flag Compta POC
	then

		########################
		# Type POC EBS Booking
		########################

		if [ "${moisbilan}" != "12" ]
		then

			# Process quaterly not annual booking
			########################

			# Generate cancellations for RA
			########################
			NSTEP=${NJOB}_400
			# Generate cancellations 
			#-----------------------------------------------------------------------------
			LIBEL="Generate cancellations for Acceptation POC ${NORME} ${ICLODAT_D}"
			AWK_I=${EPO_FTECLEDASIICO}
			AWK_O=${EPO_FTECLEDASIICO_ANNULMVT}
			AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
			AWK_CMD=`CFTMP`
			INPUT_TEXT ${AWK_CMD} <<EOF
			BEGIN{ FS="\~"; OFS="\~" }
				{
					if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
					if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
					if (\$88  != 0) \$88 = sprintf("%-.3lf",-\$88);
					\$3 = an
					\$4 = mois
					\$5 = jour
					\$44 = "POST"
					\$106 = speentnat_ct
					print \$0;
				}
			exit
EOF
			AWK

			NSTEP=${NJOB}_410
			# Generate cancellations 
			#-----------------------------------------------------------------------------
			LIBEL="Generate cancellations for Retrocession POC ${NORME} ${ICLODAT_D}"
			AWK_I=${EPO_FTECLEDRSIICO}
			AWK_O=${EPO_FTECLEDRSIICO_ANNULMVT}
			AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
			AWK_CMD=`CFTMP`
			INPUT_TEXT ${AWK_CMD} <<EOF
			BEGIN{ FS="\~"; OFS="\~" }
				{
					if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
					if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
					\$3 = an
					\$4 = mois
					\$5 = jour
					\$44 = "POST"
					\$59 = speentnat_ct
					print \$0;
				}
			exit
EOF
			AWK	
	
		else
	
			# Process annual booking
			########################

			# Generate cancellations for RA
			########################

			NSTEP=${NJOB}_420
			# Generate cancellations 
			#-----------------------------------------------------------------------------
			LIBEL="Generate annual cancellations for Acceptation POC ${NORME} ${ICLODAT_D}"
			AWK_I=${EPO_FTECLEDASIICO}
			AWK_O=${EPO_FTECLEDASIICO_ANNULMVT}
			AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
			AWK_CMD=`CFTMP`
			INPUT_TEXT ${AWK_CMD} <<EOF
			BEGIN{ FS="\~"; OFS="\~" }
			{
				if ((substr(\$6,2,1) == "A" && substr(\$6,8,1) == "2") || substr(\$6,2,1) == "E")
				{
					if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
					if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
					if (\$88  != 0) \$88 = sprintf("%-.3lf",-\$88);
					\$3 = an
					\$4 = mois
					\$5 = jour
					\$44 = "POST"
					\$106 = speentnat_ct
					if (substr(\$6,2,1) == "A" && substr(\$6,8,1) == "2") \$6 = substr(\$6,1,7) "3";
					if (substr(\$6,2,1) == "E") \$6 = substr(\$6,1,1) "J" substr(\$6,3,6);
					print \$0;
				}
			}
			exit
EOF
			AWK

			NSTEP=${NJOB}_430
			# Generate cancellations 
			#-----------------------------------------------------------------------------
			LIBEL="Generate annual cancellations for Retrocession POC ${NORME} ${ICLODAT_D}"
			AWK_I=${EPO_FTECLEDRSIICO}
			AWK_O=${EPO_FTECLEDRSIICO_ANNULMVT}
			AWK_PARAM=" -v an=${anmax} -v mois=${moismax} -v jour=${jourmax} -v speentnat_ct=${SPEENTNAT_CT}"
			AWK_CMD=`CFTMP`
			INPUT_TEXT ${AWK_CMD} <<EOF
			BEGIN{ FS="\~"; OFS="\~" }
			{
				if ((substr(\$6,2,1) == "A" && substr(\$6,8,1) == "2") || substr(\$6,2,1) == "E")
				{
					if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
					if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);
					\$3 = an
					\$4 = mois
					\$5 = jour
					\$44 = "POST"
					\$59 = speentnat_ct
					if (substr(\$6,2,1) == "A" && substr(\$6,8,1) == "2") \$6 = substr(\$6,1,7) "3";
					if (substr(\$6,2,1) == "E") \$6 = substr(\$6,1,1) "J" substr(\$6,3,6);
					print \$0;
				}
			}
			exit
EOF
			AWK
	
		fi
		
		# Archive Files
		########################

		NSTEP=${NJOB}_440
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDASIICO} to DARCH"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDASIICO} > ${EPO_FTECLEDASIICO_ARC}"

		NSTEP=${NJOB}_450
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDRSIICO} to DARCH"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDRSIICO} > ${EPO_FTECLEDRSIICO_ARC}"

		NSTEP=${NJOB}_460
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDASIICO_ANNULMVT} to DARCH"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDASIICO_ANNULMVT} > ${EPO_FTECLEDASIICO_ANNULMVT_ARC}"

		NSTEP=${NJOB}_470
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_FTECLEDRSIICO_ANNULMVT} to DARCH"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_FTECLEDRSIICO_ANNULMVT} > ${EPO_FTECLEDRSIICO_ANNULMVT_ARC}"

		NSTEP=${NJOB}_480
		# ARCHIVAGE
		#----------------------------------------------------------------------------
		LIBEL="Archive ${EPO_GTSII_RISKMARGINCO} to DARCH"
		EXECKSH_MODE=P
		EXECKSH "gzip -c ${EPO_GTSII_RISKMARGINCO} > ${EPO_GTSII_RISKMARGINCO_ARC}"

	fi
fi

JOBEND
