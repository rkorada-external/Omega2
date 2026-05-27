#!/bin/ksh
#=============================================================================
# nom de l'application    : ESTIMATIONS - INVENTAIRE
#                           Generation de EST_DLRGTAA apres recup retro interne
# nom du script SHELL     : ESID4001.cmd
# revision                : $Revision:   1.1  $
# date de creation        : 12/02/2001
# auteur                  : O.GIRAUX
# references des specifications  :
#-----------------------------------------------------------------------------
# description
#   Filtering files
#
#   Output file sort ${EST_DLRGTAA}
#
# job launched by ESID4000.cmd
#-----------------------------------------------------------------------------
# historique des modifications
# [02] 26/11/2012 PPEZOUT :spot:24516 cr�ation, ECHANGES INTERNES POST OMEGA
#[03] 29/05/2013 PPEZOUT :spot:25171 Modifications Solvency
#[04] 20/11/2014 G. Legay :spot:27821 Suppression du filtre sur le jour bilan pour la g�n�ration du DLRGTAA
#[05] 02/11/2015 P PEZOUT :spot:29615 EST45 gestion des doubles bouclettes RETRO
#[06] 18/01/2016 Florent  :spot:29066 formatage du fichier GT
#[07] 26/08/2016 MBO      :spot:31117:pas de spira: ajout de colonne en plus TRN_NT, SPEENNAT_CT, EVT_NF, REVT_NF
#[08] 03/08/2017 R. Cassis :spira:63164 Le fichier GTEP a un nom specifique pour chaque type d'inventaire post-omega.
#[09] 08/02/2018 S.ROCH    :spira:64246 Ajout TSUBTRS pour ES filter GAAP
#[10] 17/04/2019 R. Cassis :spira:65656 Remise a niveau des fichiers DLR..
#[11] 18/06/2020 JYP : spira 84283 : exclude DISCOUNT t.codes EBS (already managed in ESPD3620) 
#[12] 01/10/2020 JYP :spira:83609 : microAOC : add IB into DFILT files
#[13] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[14] 24/02/2023 MZM :Spira : 106770 I17G - Internal assumed initial amounts to be aligned with internal retro initial amounts : Generation des AI pour les postes de discount step_100
#[15] 06/01/2025 MZM :SPIRA 111435/Activation mirroring pour Life : Tri du fichier PERICASE sur Cle CSUE avant appel du ESTM7604 (Pour Ano Test I17P/L Life)
#[16] 16/06/2025 M.NAJI : SPIRA 111672  Evolution SERQS
#[17] 18/03/2026 MANISH_MZM : US 8220 IO RETRO PLAN MIssing : Add Sort On Key CSUE on Input Files because We have more than 10 Section
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT
# Get parameters
CRE_D=$1
TYPEINV=$2
BOUCLE=$3
NORME=$4

##[08] [09]
#if [ "${TYPEINV}" != "INV" ]
#then
##	EST_DLRIGTAA=${EPO_DLRIGTAA}
##	EST_DLRGTAA=${EPO_DLRGTAA}
#	EST_FDETTRS=${EPO_FDETTRS}
#	EST_IADVPERICASE=${EPO_IADVPERICASE}
#	EST_IADVPERICASE0=${EPO_IADVPERICASE}
#	EST_DLRIGTAANOS=${EPO_DLRIGTAANOS}
#	EST_SUBTRS=${EPO_FSUBTRS}
#	if [ "${TYPEINV}" = "POS" ]
#	then
#		EST_GTEP=${EPO_GTEPSO}
#		EST_DLRIGTAA=${EPO_DLRIGTAASO}
#		EST_DLRGTAA=${EPO_DLRGTAASO}
#		if [ "${NORME}" = "EBS" ]
#		then
#			EST_GTEP=${EPO_GTEPSIISO}
#			EST_DLRIGTAA=${EPO_DLRIGTAASIISO}
#			EST_DLRGTAA=${EPO_DLRGTAASIISO}
#		fi
#	else
#		EST_GTEP=${EPO_GTEPCO}
#		EST_DLRIGTAA=${EPO_DLRIGTAACO}
#		EST_DLRGTAA=${EPO_DLRGTAACO}
#		if [ "${NORME}" = "EBS" ]
#		then
#			EST_GTEP=${EPO_GTEPSIICO}
#			EST_DLRIGTAA=${EPO_DLRIGTAASIICO}
#			EST_DLRGTAA=${EPO_DLRGTAASIICO}
#		fi
#	fi
#fi

touch ${EST_DLRIGTAANOS}

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> CRE _D...................: ${CRE_D}"
ECHO_LOG "#===> TYPEINV..................: ${TYPEINV}"
ECHO_LOG "#===> NORME....................: ${NORME}"
ECHO_LOG "#===> BOUCLE...................: ${BOUCLE}"
ECHO_LOG "#===> EST_GTEP.................: ${EST_GTEP}"
ECHO_LOG "#===> EST_DLRIGTAA.............: ${EST_DLRIGTAA}"
ECHO_LOG "#===> EST_DLRGTAA..............: ${EST_DLRGTAA}"
ECHO_LOG "#===> EST_FDETTRS..............: ${EST_FDETTRS}"
ECHO_LOG "#===> EST_IADVPERICASE.........: ${EST_IADVPERICASE}"
ECHO_LOG "#===> EST_IADVPERICASE0........: ${EST_IADVPERICASE0}"
ECHO_LOG "#===> EST_DLRIGTAANOS..........: ${EST_DLRIGTAANOS}"
ECHO_LOG "#===> EST_SUBTRS...............: ${EST_SUBTRS}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_05
# EST_GTEP screen on the subsidary and closing process date
# (EST_GTEP = TL file received from retrocessionnaire subsidiaries)
#-----------------------------------------------------------------------------
# [07]
LIBEL="EST_GTEP + EST_DLRIGTAA ==> EST_DLRGTAA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLRIGTAA}"
if [ "${NORME_CF}" = "I4I" ] && [ "${VSERQS_I4I}" != "YES" ] 
then
        SORT_I2="${EST_GTEP}"
fi
if [ "${NORME_CF}" = "EBS" ] && [ "${VSERQS_EBS}" != "YES" ] 
then
        SORT_I2="${EST_GTEP}"
fi

if [ "${NORME_CF}" = "I17G" ] && [ "${VSERQS_I17G}" != "YES" ] 
then
        SORT_I2="${EST_GTEP}"
fi

if [ "${NORME_CF}" = "I17P" ] && [ "${VSERQS_I17P}" != "YES" ] 
then
        SORT_I2="${EST_GTEP}"
fi


if [ "${NORME_CF}" = "I17L" ] && [ "${VSERQS_I17L}" != "YES" ] 
then
        SORT_I2="${EST_GTEP}"
fi


SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_GTAA_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF       8:1 - 8:,
      END_NT         9:1 - 9:,
      SEC_NF        10:1 - 10:,
      UWY_NF        11:1 - 11:,
      UW_NT         12:1 - 12:,
      FILLER1        1:1 - 40:,
      FILLER2        3:1 - 40:,
      TRN_NT        45:1 - 45:,
      SPEENTNAT_CT  46:1 - 46:,
      EVT_NF        47:1 - 47:,
      REVT_NF       48:1 - 48:
/KEYS CTR_NF,
    END_NT,
    SEC_NF,
    UWY_NF,
    UW_NT,
    FILLER2
/DERIVEDFIELD ZERO "0.000~" CHAR 5
/DERIVEDFIELD AJOUT14COLS 15"~"
/DERIVEDFIELD ORICOD_LS "OIGTA~"
/DERIVEDFIELD RETROAUTO_B "~"
/DERIVEDFIELD AJOUT10COLS 9"~"
/OUTFILE ${SORT_O}
/REFORMAT  FILLER1, ZERO, AJOUT14COLS, TRN_NT, ORICOD_LS, RETROAUTO_B, SPEENTNAT_CT, EVT_NF, REVT_NF, AJOUT10COLS
exit
EOF
SORT

NSTEP=${NJOB}_08
# Double entry transaction code addition in  GT
#-----------------------------------------------------------------------------
LIBEL="Double entry transaction code addition GTA in progress ..."
PRG=ESTM7603
export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat
export ${PRG}_I2=${EST_FDETTRS}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTM7603_GTAA.dat
EXECPRG

##[017] begin

NSTEP=${NJOB}_08A
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting ${DFILT}/${NJOB}_08_${IB}_ESTM7603_GTAA.dat file"
        SORT_WDIR=${SORTWORK}
        SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_08_${IB}_ESTM7603_GTAA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTAA.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF       8:1 - 8:,
      END_NT         9:1 - 9:,
      SEC_NF        10:1 - 10:EN,
      UWY_NF        11:1 - 11:,
      UW_NT         12:1 - 12:

/KEYS
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT



##[15] TRi du fichier IADVPERICASE Que pour I17L/P/G_AEL_RPO_LIF Pour eviter toute regression 

##if  [ "${IDF_CT}" = "I17G_AEL_RPO_LIF" ]  || [ "${IDF_CT}" = "I17P_AEL_RPO_LIF" ] || [ "${IDF_CT}" = "I17L_AEL_RPO_LIF" ] 
##then	

NSTEP=${NJOB}_09
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting ${EST_IADVPERICASE0} file"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE0.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        CTR_NF        3:1 - 3:,
        END_NT        4:1 - 4:,
        SEC_NF        5:1 - 5:EN,
        UWY_NF        6:1 - 6:,
        UW_NT         7:1 - 7:
/KEYS 
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

##else


##EXECKSH "cp  ${EST_IADVPERICASE0}  ${DFILT}/${NJOB}_09_${IB}_SORT_IADVPERICASE0.dat "

##fi

NSTEP=${NJOB}_10
# Adding establishment code in Technical Ledger
#-----------------------------------------------------------------------------
LIBEL="Current adding establishment code in TL ..."
PRG=ESTM7604
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
##export ${PRG}_I1=${DFILT}/${NJOB}_08_${IB}_ESTM7603_GTAA.dat
export ${PRG}_I1=${DFILT}/${NJOB}_08A_${IB}_SORT_GTAA.dat
export ${PRG}_I2=${DFILT}/${NJOB}_09_${IB}_SORT_IADVPERICASE0.dat
##export ${PRG}_I2=${EST_IADVPERICASE0}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRGTAA.dat
#export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ANOS_O.dat
export ${PRG}_O2=${EST_DLRIGTAANOS}
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_DLEIGTAA.dat
EXECPRG

##[017] end

gzip -c ${DFILT}/${NJOB}_10_${IB}_ESTM7604_DLRGTAA.dat   > ${DFILT}/${NJOB}_010_${IB}_ESTM7604_DLRGTAA.dat.gz
gzip -c ${DFILT}/${NJOB}_10_${IB}_ESTM7604_DLEIGTAA.dat  > ${DFILT}/${NJOB}_010_${IB}_ESTM7604_DLEITAA.dat.gz
gzip -c ${EST_DLRIGTAANOS}                               > ${DFILT}/${NJOB}_010_${IB}_ESTM7604_ANOS_O.dat.gz

NSTEP=${NJOB}_30
# Begin Sort
	#-----------------------------------------------------------------------------
LIBEL="Sorting DLRGTAA TL file"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_ESTM7604_DLRGTAA.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLRGTAA.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        BALSHEY_NF     3:1 -  3:,
        BALSHRMTH_NF   4:1 -  4:,
        TRNCOD_CF      6:1 -  6:,
        CTR_NF         8:1 -  8:,
        END_NT         9:1 -  9:,
        SEC_NF        10:1 - 10:,
        UWY_NF        11:1 - 11:,
        UW_NT         12:1 - 12:,
        ACY_NF        13:1 - 13:
/KEYS 
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        ACY_NF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        TRNCOD_CF
exit
EOF
SORT

NSTEP=${NJOB}_50
# MAJ DLRGTAA with ES
#-----------------------------------------------------------------------------
LIBEL="MAJ DLRGTAA with ES FILTER GAAP 3 TO 5"
PRG=ESTC3701
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_DLRGTAA.dat
export ${PRG}_I2=${EST_IADVPERICASE0}
export ${PRG}_I3=${EST_SUBTRS}                                                                                                  #[09] 
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRGTAA.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_DLRGTAA_3_4_5.dat
EXECPRG

gzip -c ${DFILT}/${NJOB}_50_${IB}_${PRG}_DLRGTAA_3_4_5.dat > ${DFILT}/${NJOB}_050_${IB}_ESTC3701_DLRGTAA_GAAP_OMIS.dat.gz
gzip -c ${DFILT}/${NJOB}_50_${IB}_${PRG}_DLRGTAA.dat       > ${DFILT}/${NJOB}_050_${IB}_ESTC3701_DLRIGTAA.dat.gz
 


#NSTEP=${NJOB}_80
## Begin sort
##-----------------------------------------------------------------------------
#LIBEL="DLRGTAA OUT OF SCOPE OF CLOSING"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_NOINFILE=YES
#SORT_I="${EST_DLRGTAA} 1000 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLRGTAA_O.dat"
#INPUT_TEXT $SORT_CMD <<EOF
#/FIELDS SSD_CF 1:1 - 1: EN
#/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
#/OMIT INVENTAIRE
#/COPY
#exit
#EOF
#SORT

## [14] Reintegration des Discount pour I17
## ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" AND TRNCOD3_CF != "1008" )	  

if [ "$NORME_CF" = "I17G" ] || [ "$NORME_CF" = "I17S" ] || [ "$NORME_CF" = "I17L" ] || [ "$NORME_CF" = "I17P" ] 
then

## 
NSTEP=${NJOB}_100A
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file ==> DLRGTAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_80_${IB}_SORT_DLRGTAA_O.dat 1000 1"
SORT_I="${DFILT}/${NJOB}_50_${IB}_${PRG}_DLRGTAA.dat 1000 1"
SORT_O="${EST_DLRGTAA}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        TRNCOD3_CF 6:3 -  6:6,
        CTR_NF   8:1 -  8:,
        END_NT   9:1 -  9:,
        SEC_NF  10:1 - 10:,
        UWY_NF  11:1 - 11:,
        UW_NT   12:1 - 12:,
        DEBUT    1:1 - 41:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

else

# ajout step pour reintegrer les enregistrements des filiales non presentes dans l'inventaire
#  JR 01/06/2004
NSTEP=${NJOB}_100
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Reformat of TL file ==> DLRGTAA"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_80_${IB}_SORT_DLRGTAA_O.dat 1000 1"
SORT_I="${DFILT}/${NJOB}_50_${IB}_${PRG}_DLRGTAA.dat 1000 1"
SORT_O="${EST_DLRGTAA}"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
        TRNCOD3_CF 6:3 -  6:6,
        CTR_NF   8:1 -  8:,
        END_NT   9:1 -  9:,
        SEC_NF  10:1 - 10:,
        UWY_NF  11:1 - 11:,
        UW_NT   12:1 - 12:,
        DEBUT    1:1 - 41:
/KEYS 
      CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION DISCOUNT ( TRNCOD3_CF != "4160" AND TRNCOD3_CF != "4161" AND TRNCOD3_CF != "4260" AND TRNCOD3_CF != "4261" AND TRNCOD3_CF != "1007" AND TRNCOD3_CF != "1008" )	  
/OUTFILE ${SORT_O}
/INCLUDE DISCOUNT
exit
EOF
SORT

fi


NSTEP=${NJOB}_120
# Delete temporary files of the job
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}_*.dat"


JOBEND
