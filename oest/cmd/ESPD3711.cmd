#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS - INVENTAIRE
#                           Allocation NP pour EBS
#                           Cree a partir du shell ESID2561
# nom du script SHELL           : ESPD3711.cmd
# revision                      : 
# date de creation              : 01/03/2018
# auteur                        : MZM
# references des specifications : :spira:65651  
#-----------------------------------------------------------------------------
# description
#   Gestion de l'allocation NP EBS
#
# Input files
#       EPO_FTVENTNP                DFILP
#       EPO_FVENTNPANT              DFILP
#       EPO_DLDSIIGTAR              DFILP  ===> DLDSIIGTAR pour implementer NP EBS
#       EPO_DLDSIIGTARSO            DFILP
#       EPO_DLDSIIGTARCO            DFILP
#       EPO_IRDVPERICASE            DFILP
#
# Output files
#       EPO_VENTNPSIISO      DFILP
#       EPO_VENTNPSIICO      DFILP
#       EPO_DLDSIIGTAR               DFILP ==> DLDSIIGTAR1_0  + DLDSIIGTAR2_0
#
# Launch C program ESTM2561 ESTM7603 --> Modifier les programmes ESTC8805 et ESTM7603 pour prendre en compte les postes EBS
#
# job launched by ESPD3700.cmd
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 11/07/2019 Roger     :spira:68628  DLDSIIGTAR normalise
#[002] 24/01/2020 KBagwe  :spira:79904 STEP269
#[004] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#	 		 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[005] 22/06/2021 : M.NAJI   : SPIRA 97241  remplacer EPO_FTRSLNK par EPO_FTRSLNK8 dans le step 70
#-----------------------------------------------------------------------------
#
#=================================================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT
set -x
# Parameters
CRE_D=$1
ICLODAT_D=$2
TYPEINV=$3
BALSHTYEA_NF=$4
BALSHTMTH_NF=$5
ICLODAT_D=$6
set +x

#TYPEINV0=""
#if [ "${TYPEINV}" != "INV" ]
#then
#    EPO_FTRSLNK=${EPO_FTRSLNK8} # Fichier de correspondance commun EBS et IFRS genere par la Proc Stockee PsTRSLNK_05 de generation de postes comptable 720 
#  if [ "${TYPEINV}" = "POS" ]
#  then
#    EST_DLDSIIGTAR=${EST_DLDSIIGTARSO}
#    EPO_DLDSIIGTAR=${EPO_DLDSIIGTARSO}
#    EPO_VENTNPSII=${EPO_VENTNPSIISO}
#    TYPEINV0=SO
#  else
#    EST_DLDSIIGTAR=${EST_DLDSIIGTARCO}
#    EPO_DLDSIIGTAR=${EPO_DLDSIIGTARCO}
#    EPO_VENTNPSII=${EPO_VENTNPSIICO}
#    TYPEINV0=CO
#  fi
#  EST_IRDVPERICASE=${EPO_IRDVPERICASE}
#fi

ECHO_LOG "#========================================================================="
ECHO_LOG "-> CRE_D .................: ${CRE_D}"
ECHO_LOG "-> ICLODAT_D .............: ${ICLODAT_D}"
ECHO_LOG "-> TYPEINV ...............: ${TYPEINV}"
ECHO_LOG "-> BALSHTYEA_NF ..........: ${BALSHTYEA_NF}"
ECHO_LOG "-> BALSHTMTH_NF ..........: ${BALSHTMTH_NF}"
ECHO_LOG "-> EST_DLDSIIGTAR ........: ${EST_DLDSIIGTAR}"
ECHO_LOG "-> EPO_DLDSIIGTAR ........: ${EPO_DLDSIIGTAR}"
ECHO_LOG "-> EPO_VENTNPSII .........: ${EPO_VENTNPSII}"
ECHO_LOG "-> EPO_FTRSLNK ...........: ${EPO_FTRSLNK}"
ECHO_LOG "-> TYPEINV0 ..............: ${TYPEINV}"
ECHO_LOG "#========================================================================="


NSTEP=${NJOB}_00
#Last version of ESID3711 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EPO_DLDSIIGTAR}`/${PCH}ESID3711_DLDSIIGTAR*.dat"


NSTEP=${NJOB}_10
# MOD003 - Sort of FTVENTNP
#-----------------------------------------------------------------------------
LIBEL="Sort of EPO_FTVENTNP"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTVENTNP} 1000 1"
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

if test -s ${EPO_FVENTNPANT}
then
NSTEP=${NJOB}_20
# MOD004 - Tri de EPO_FVENTNPANT
#-----------------------------------------------------------------------------
LIBEL="Sort of EPO_FVENTNPANT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FVENTNPANT} 1000 1"
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
# MOD003 -  Sort of IRDVPERICASE
#-----------------------------------------------------------------------------
LIBEL="Sort of IRDVPERICASE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_IRDVPERICASE} 1000 1"
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

gzip -c ${EST_DLDSIIGTAR} > ${DFILT}/${NJOB}_DLDSIIGTAR_avant_${TYPEINV0}.dat.gz


NSTEP=${NJOB}_40
# EST_IGTAR Reconstitution --> IGTAR ==> DLDSIIGTAR
#-----------------------------------------------------------------------------
LIBEL="Keep only Unique Line and Summarize for DLDSIIGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLDSIIGTAR} 1000 1" 
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_SUM_DLDSIIGTAR.dat
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

#[002]
if [ -s ${DFILT}/${NJOB}_30_${IB}_SORT_IRDVPERICASE_O.dat ]
then
    NSTEP=${NJOB}_70
    # MOD003 - File generation Ventilation Retro Non Prop DLDSIIGTAR 1
    #-----------------------------------------------------------------------------
    LIBEL="File generation Ventilation Retro Non Prop DLDSIIGTAR 1"
    PRG=ESTC8805
    FPRM=`CFTMP`
    INPUT_TEXT ${FPRM} << EOF
    ICLODAT_D ${ICLODAT_D}
    BALSHTYEA_NF ${BALSHTYEA_NF}
    BALSHTMTH_NF ${BALSHTMTH_NF}
    TYPE_EDITION 1
    CRE_D ${ICLODAT_D}
    ICLODAT_D ${ICLODAT_D}
	CUR_B F
    exit
EOF
    export ${PRG}_PRM=${FPRM}
    export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_SUM_DLDSIIGTAR.dat
    export ${PRG}_I2=${DFILT}/${NJOB}_10_${IB}_SORT_FTVENTNP_O.dat
    export ${PRG}_I3=${EPO_FTRSLNK8}         
    export ${PRG}_I4=${DFILT}/${NJOB}_30_${IB}_SORT_IRDVPERICASE_O.dat
    export ${PRG}_I5=${EPO_FLIBEL2}
    export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIGTAR1_O.dat
    export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLDSIIGTAR1_O.ano
    export ${PRG}_O3=${EPO_VENTNPSII}
    EXECPRG
else
    NSTEP=${NJOB}_80
    # Begin execksh
    #-----------------------------------------------------------------
    LIBEL="touch files DLDSIIGTAR1"
    EXECKSH_MODE=P
    EXECKSH "mv ${DFILT}/${NJOB}_40_${IB}_SORT_SUM_DLDSIIGTAR.dat ${DFILT}/${NJOB}_70_${IB}_ESTC8805_DLDSIIGTAR1_O.dat"
    EXECKSH "touch ${EPO_VENTNPSII}"
fi


###############################################
# ------------------------- Fin   MOD003 --Integration Ventilation NP
###############################################


#-----------------------------------------------
#[021] Sauvegarde des fichiers
#-----------------------------------------------
NSTEP=${NJOB}_90_ZIP
#Sauvegarde des fichiers
#-----------------------------------------------------------------------------
LIBEL="Sauvegarde des fichiers"
gzip -c ${DFILT}/${NJOB}_40_${IB}_SORT_SUM_DLDSIIGTAR.dat             >  ${DFILT}/${NJOB}_40_SORT_SUM_DLDSIIGTAR.dat.gz
gzip -c ${DFILT}/${NJOB}_50_${IB}_SORT_DLDSIIGTAR1_O.dat              >  ${DFILT}/${NJOB}_50_SORT_DLDSIIGTAR1_O.dat.gz
#gzip -c ${DFILT}/${NJOB}_60_${IB}_SORT_DLDSIIGTAR2_O.dat              >  ${DFILT}/${NJOB}_60_SORT_DLDSIIGTAR2_O.dat.gz
gzip -c ${DFILT}/${NJOB}_70_${IB}_ESTC8805_DLDSIIGTAR1_O.dat     >  ${DFILT}/${NJOB}_70_ESTC8805_DLDSIIGTAR1_O.dat.gz
gzip -c ${DFILT}/${NJOB}_70_${IB}_ESTC8805_VENTNPSII.dat    > ${DFILT}/${NJOB}_70_ESTC8805_VENTNPSII${TYPEINV0}.dat.gz

##############################################################################g
# All balance sheet year Retrocession by Acceptance and Retrocession TL files merge
###############################################################################

	
# Traite l'allocation des NP
gzip -c ${EPO_VENTNPSII} > ${DARCH}/${NCHAIN}_VENTNPSII${TYPEINV0}_${ICLODAT_D}.dat.gz

NSTEP=${NJOB}_100
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Add NP Ventilations to DLDSIIGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70_${IB}_ESTC8805_DLDSIIGTAR1_O.dat 1000 1"
SORT_I2="${EPO_VENTNPSII} 1000 1"
SORT_O="${EPO_DLDSIIGTAR} OVERWRITE 1000 1"
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

gzip -c ${DFILT}/${NJOB}_70_${IB}_ESTC8805_DLDSIIGTAR1_O.dat > ${DFILT}/${NJOB}_ESTC8805_DLDSIIGTAR1_O_${TYPEINV0}.dat.gz


########################
# Erase temporary files #
########################
NSTEP=${NJOB}_120
LIBEL="Erase temporary & permanent files"
RMFIL "${DFILT}/${NCHAIN}*_${IB}_*.dat"
########################

JOBEND
