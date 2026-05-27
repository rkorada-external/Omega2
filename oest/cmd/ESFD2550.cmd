#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
# nom du script SHELL           : ESFD2650.cmd
# revision                      : $Revision:   1.2  $
# date de creation              : 03/10/1997
# auteur                        : CGI
# references des specifications : ESTIEI23.doc
#-----------------------------------------------------------------------------
# description
#   Generation of the acceptance TL for retrocessionnaire subsidiaries
#-----------------------------------------------------------------------------
# historiques des modifications
#[01] 26/11/2012 PPEZOUT :spot:24516 ECHANGES INTERNES POST OMEGA
#[02] 02/11/2015 Florent :spot:29615 EST45 gestion des doubles bouclettes RETRO
#[03] 03/08/2017 R.Cassis :spira:64246 Le fichier GTEP a un nom specifique pour chaque type d'inventaire post-omega (NORME en parametre du ESID4001)
#[04] 28/11/2019 M.NAJI :spira:81838 suppresion des jobs ESID2552 et ESID2553
#[05] 17/03/2016 Roger   :spot:30151 Suppression des appels aux jobs ESID2552-53 qui sont ex�cut�s maintenant dans le ESPD2050.
#[06] 03/08/2017 R.Cassis :spira:63164 Le fichier GTEP a un nom specifique pour chaque type d'inventaire post-omega.
#[07] 12/02/2020 MZM      :spira:71539 Le fichier des OVERRIDES COMMISSION EST_DLREGTAR_OVR est merge avec le EST_DLREGTAR pour genere
#[08] 11/03/2020 MZM      :spira:79090 Retro Future Proportionnal AT Inception
#[09] 01/02/2021 JYP      :spira:88626/91991 LCC STD, I17L/P should be same as I17G
#[10] 10/03/2021 JYP      :spira:94556 manage mode EBS when microAOC
#[11] 29/03/2021 JYP      :spira:94556 manage mode EBS when microAOC 
#[12] 07/04/2021 MZM      :SPIRA:XXXXX LOFACTOR DANS BOUCLETTE
#[13] 28/02/2022 MZM      :spira:101275 OVERRINDING DANS BOUCLETTE
#[14] 01/03/2022 MZM      :spira:102508 Ajout des JOBS ESCJ0063 ; TEFJ0011 ; pour Generation fichier GTEP en fonction de l'IDF_CT (GTEP n est plus genere oar ESPD4000)
#                                                      ESID2552  pour transfert vers les filiales du fichier DLEIGTAA
#[15] 21/03/2022 MZM      :spira:101584 MODIFICATION VARIABLE NCHAIN
#[16] 06/04/2022 MZM      :spira:102507 AI NDIC INI TRANSCO en TRNCOD I17
#[17] 02/06/2022 MZM      :spira:102507 MODIFICATION VARIABLE NCHAIN Uniquement pour le JOB ESID2552
#[18] 14/06/2022 MZM      :spira:102507 Ajout pour I17G_ESFD2550 AI
#[19] 29/06/2022 MZM      :spira:104778 Ajout pour nouveau couloir I17S  AI
#[20] 06/04/2022 MZM      :spira:104856 NDIC TC
#[21] 06/04/2022 MZM      :spira:104285 NDIC TC I17G_ESFD2550_TC
#[22] 21/02/2023 MZM      :Spira:106770 I17G - Internal assumed initial amounts to be aligned with internal retro initial amounts (Filtre que sur Poste 49500)   
#[23] 17/04/2024 M.NAJI	  :Spira 111511 Optimisation ESFD2550
#[24] 26/11/2024 MZM      :spira:111435 OMEGA Life IFRS17 IO mirroring management
#===============================================================================
#set -x 

#-=-=-=-=-=-=-=-=-=-=-=
# Input files
#	EST_DLDVGTAR
#	EST_DLDVGTR
#	EST_DLEIGTAA
#	EST_FDETTRS
#	EST_FPLC
#	EST_FSSDACTR
#	EST_IRDVPERICASE
# Output files
#	EST_DLEIGTAA
#-=-=-=-=-=-=-=-=-=-=-=

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fcttransfer.cmd


# Chain Initialization variables
CHAININIT $0 $1

IDF_CT="$2"


# Launch applicative job ESCD9001
#. ${DCMD}/ESCD9001.cmd ${SSDs0} ${SSDs} ${BALSHTYEA_NF} ${BALSHTMTH_NF} ${CRE_D} ${DBCLO_D} ${CLODAT_D} ${ICLODAT_D}         
. ${DCMD}/ESFD9001.cmd "${IDF_CT}"
  

NCHAIN_PARAM=`echo ${ARG2_CHN_2} `


 ## Traitement specifique pour LCC INI  et I17S
 if [ "${IDF_CT}" = "I17G_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17L_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17P_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17S_LCC_RPO_INI" ]
 then	
			NCHAIN_PARAM=LCI
 fi 

 ## Traitement specifique pour NDC INI 
 if [ "${IDF_CT}" = "I17G_NDC_RPO_INI" ] || [ "${IDF_CT}" = "I17L_NDC_RPO_INI" ] || [ "${IDF_CT}" = "I17P_NDC_RPO_INI" ] || [ "${IDF_CT}" = "I17S_NDC_RPO_INI" ]
 then	
			NCHAIN_PARAM=NDI
 fi 
 
 ## Traitement specifique pour NTC TRNCOD INI  
 if [ "${IDF_CT}" = "I17G_NTC_RPO_INI" ] || [ "${IDF_CT}" = "I17L_NTC_RPO_INI" ] || [ "${IDF_CT}" = "I17P_NTC_RPO_INI" ] || [ "${IDF_CT}" = "I17S_NTC_RPO_INI" ]
 then	
			NCHAIN_PARAM=NTI
 fi 
 
 ## Traitement specifique pour NDC STANDARD IDF_CT = EBS_ESFD2550
 if [ "${IDF_CT}" = "EBS_ESFD2550" ]
 then	
			NCHAIN_PARAM=NDC
 fi 
 
 ## Traitement specifique pour NDC STANDARD IDF_CT = EBS_ESFD2550_TC
 if [ "${IDF_CT}" = "EBS_ESFD2550_TC" ]
 then	
			NCHAIN_PARAM=NTC
 fi 
 
 ##[21] Traitement specifiquetemporaire pour NDC STANDARD IDF_CT = I17G_ESFD2550_TC
 if [ "${IDF_CT}" = "I17G_ESFD2550_TC" ]
 then	
			NCHAIN_PARAM=NIC
 fi 
 
 ## [18] Traitement specifique pour I17G_ESFD2550 STANDARD IDF_CT = I17G_ESFD2550
 if [ "${IDF_CT}" = "I17G_ESFD2550" ]
 then	
			NCHAIN_PARAM=AAA
 fi  
 
 ## Traitement specifique pour MIC AOC
 
 if [ "${IDF_CT}" = "I17G_ESFD2550___AA0" ] 
 then	
			NCHAIN_PARAM=AA0
 fi
 
  if [ "${IDF_CT}" = "I17G_ESFD2550___AA1" ] 
 then	
			NCHAIN_PARAM=AA1
 fi
  if [ "${IDF_CT}" = "I17G_ESFD2550___AA2" ]
 then	
			NCHAIN_PARAM=AA2
 fi
  if  [ "${IDF_CT}" = "I17G_ESFD2550___AA3" ]
 then	
			NCHAIN_PARAM=AA3
 fi

#[24] 
 if  [ "${IDF_CT}" = "I17G_AEL_RPO_LIF" ]  || [ "${IDF_CT}" = "I17P_AEL_RPO_LIF" ] || [ "${IDF_CT}" = "I17L_AEL_RPO_LIF" ]
 then	
			NCHAIN_PARAM=LIF
 fi
             

export EXTCHAIN=${ENV_PREFIX}_${NCHAIN_PARAM}_${NORME_CF}
#[15] export NCHAIN=${ENV_PREFIX}_${NCHAIN_PARAM}_${NORME_CF}
export NCHAIN_SHORT=${NCHAIN_PARAM}_${NORME_CF}

	 

if [ "$NORME2" != "" ]  # mode double norme
then
   CLOSING_MODE="$NORME2"
else
   CLOSING_MODE="$NORME"
fi

BOUCLES=5
BOUCLE=1 

 if  [ "${IDF_CT}" = "I17G_AEL_RPO_LIF" ]  || [ "${IDF_CT}" = "I17P_AEL_RPO_LIF" ] || [ "${IDF_CT}" = "I17L_AEL_RPO_LIF" ] 
 then	
	BOUCLE=1 
	BOUCLES=1 
 fi

ECHO_LOG "#===> EXTCHAIN.............................: ${EXTCHAIN}"          >> $FLOG 
ECHO_LOG "#===> NCHAIN_SHORT.........................: ${NCHAIN_SHORT}"          >> $FLOG 
ECHO_LOG "#===> TYPEINV..............................: ${TYPEINV}"             >> $FLOG
ECHO_LOG "#===> NORME................................: ${NORME}"               >> $FLOG
ECHO_LOG "#===> NORME_CF.............................: ${NORME_CF}"            >> $FLOG
ECHO_LOG "#===> NORME2...............................: ${NORME2}"              >> $FLOG
ECHO_LOG "#===> CLOSING_MODE ........................: ${CLOSING_MODE}"        >> $FLOG 
ECHO_LOG "#===> PATCAT_CT    ........................: ${PATCAT_CT}"        	 >> $FLOG 
ECHO_LOG "#===> BOUCLE...............................: ${BOUCLE}"              >> $FLOG
 


#EXECKSH "cp ${EST_DLREGTR0} ${EST_DLREGTR}"




#[08]
	# Merge  du ESFD3780 et du ESFD3890 ===>  DLDGTAASII : # A CREER ESID2508.cmd
 if [ "${IDF_CT}" = "I17G_LCC_RPO_STD" ] || [ "${IDF_CT}" = "I17L_LCC_RPO_STD" ] || [ "${IDF_CT}" = "I17P_LCC_RPO_STD" ] || [ "${IDF_CT}" = "I17S_LCC_RPO_STD" ]
 then	
	NJOB="ESFD2508"
	${DCMD}/ESFD2508.cmd ${PARM_CONSOYEA} ${PARM_INVCONSO_D} ${TYPEINV}  ${IDF_CT}  2>&1 | ${TEE} 
 fi


##	#[14]
##	# g�n�ration fichier GTEP inter site en fonction de l'IDF_CT 


NJOB="TEFJ0011"
# Launch technical job TEFJ0011
# Fetching of TL files from the estimation chain ESFD2650
${DUTI}/TEFJ0011.cmd ${IDF_CT}  2>&1 | ${TEE}



# Launch applicative job ESCJ0063
# GTEP File generation
#[06] Ajout variable NORME et IDF_CT
NJOB="ESCJ0063"
${DCMD}/ESCJ0063.cmd ${TYPEINV} ${CLOSING_MODE} ${IDF_CT}  2>&1 | ${TEE} 


NJOB="ESFD2551A"
${DCMD}/ESFD2551A.cmd ${PARM_RETTHRESHOLD_R} ${PARM_CRE_D} ${PARM_DBCLO_D} ${TYPEINV} ${CLOSING_MODE} 2>&1 | ${TEE}



export ARRET_BOUCLE=${DFILT}/${NCHAIN}_${IB}_ARRET_BOUCLE.dat
while [[ ${BOUCLE} -le ${BOUCLES} ]]; do
	# g�n�ration fichier retro RR => DLDVGTR
	NJOB="ESFD2563_${BOUCLE}"
	${DCMD}/ESFD2563.cmd ${PARM_CONSOYEA} ${PARM_CONSOMTH} ${PARM_INVCONSO_D} ${PARM_CRE_D} ${TYPEINV} ${CLOSING_MODE} ${BOUCLE} 2>&1 | ${TEE}
	#arr�t boucle si EST_DLDVGTR est identique � la boucle pr�c�dente !!!!!!!!!
	if [[ -e ${ARRET_BOUCLE} ]]; then
		break
	fi

	# g�n�ration fichier accept interne AI intrasite DLRIGTAA
	NJOB="ESFD2551_${BOUCLE}"
	${DCMD}/ESFD2551.cmd ${PARM_RETTHRESHOLD_R} ${PARM_CRE_D} ${PARM_DBCLO_D} ${TYPEINV} ${CLOSING_MODE} ${BOUCLE} 2>&1 | ${TEE} 


	#[03]
	# g�n�ration fusion accept interne intrasite + GTEP intersite, enrichie => DLRGTAe 
	NJOB="ESID4001_${BOUCLE}"
	${DCMD}/ESID4001.cmd ${PARM_CRE_D} ${TYPEINV} ${BOUCLE} ${CLOSING_MODE} 2>&1 | ${TEE}

#[24]
 if [ "${IDF_CT}" != "I17G_AEL_RPO_LIF" ] &&  [ "${IDF_CT}" != "I17P_AEL_RPO_LIF" ] && [ "${IDF_CT}" != "I17L_AEL_RPO_LIF" ] && [ "${IDF_CT}" != "I17S_AEL_RPO_LIF" ] 
 then	

	# g�n�ration de la retro auto => DLRE*GTR
	NJOB="ESID2504_${BOUCLE}"
	${DCMD}/ESID2504.cmd ${PARM_CONSOYEA} ${PARM_INVCONSO_D} ${TYPEINV} ${CLOSING_MODE} ${BOUCLE} 2>&1 | ${TEE} 

  #[07] 	#[12] #[13]
	# Merge  du EST_DLREGTAR et du EST_DLREGTAR_OVR
	NJOB="ESID2507_${BOUCLE}"
	${DCMD}/ESID2507.cmd ${PARM_CONSOYEA} ${PARM_INVCONSO_D} ${TYPEINV} ${CLOSING_MODE}  2>&1 | ${TEE} 

 fi	
 
	let BOUCLE=BOUCLE+1
done



#[14] Fichiers d'emission interne envoyes aux filiales
# ENVOIS Aux Filiales du fichier DLEIGTAA


#[17] DEB

OLD_CHAIN=${NCHAIN}
export NCHAIN=${ENV_PREFIX}_${NCHAIN_PARAM}_${NORME_CF}

# Launch applicative job ESID2552 if no Request F (not  the last day of Social Post Omega)
	NJOB="ESID2552"
	${DCMD}/ESID2552.cmd ${TYPEINV} ${CLOSING_MODE} ${IDF_CT}  2>&1 | ${TEE}

export NCHAIN=${OLD_CHAIN}

#[17] FIN

	# Transcodification AT INI des TRNCODS  EBS
	#[22] Ajout Filtre sur LCC_INI : Uniquement postes 49500 dans les fichiers EST_DLREGTR et EST_DLREGTAR
	
 if [ "${IDF_CT}" = "I17G_FUT_RPO_INI" ] || [ "${IDF_CT}" = "I17S_FUT_RPO_INI" ] || [ "${IDF_CT}" = "I17L_FUT_RPO_INI" ] || [ "${IDF_CT}" = "I17P_FUT_RPO_INI" ] || 
    [ "${IDF_CT}" = "I17G_NDC_RPO_INI" ] || [ "${IDF_CT}" = "I17S_NDC_RPO_INI" ] || [ "${IDF_CT}" = "I17L_NDC_RPO_INI" ] || [ "${IDF_CT}" = "I17P_NDC_RPO_INI" ] ||
    [ "${IDF_CT}" = "I17G_NTC_RPO_INI" ] || [ "${IDF_CT}" = "I17S_NTC_RPO_INI" ] || [ "${IDF_CT}" = "I17L_NTC_RPO_INI" ] || [ "${IDF_CT}" = "I17P_NTC_RPO_INI" ] ||
    [ "${IDF_CT}" = "I17G_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17S_LCC_RPO_INI" ] 
 then	

  ECHO_LOG "#===> VERIF I17_NDC...........................: ${IDF_CT}"          >> $FLOG

	NJOB="ESFD2555"
	${DCMD}/ESFD2555.cmd ${PARM_CONSOYEA} ${PARM_INVCONSO_D} ${TYPEINV}  ${IDF_CT}  2>&1 | ${TEE} 
 
 fi

CHAINEND
