#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESFD5061.cmd
# revision                      : 
# date de creation              : 31/03/2025
# auteur                        : MZM
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Extraction quatidienne des  fichiers
#
# job launched by ESFD5060.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Description    :Extraction quatidienne des  fichiers
#===============================================================================
#[001] 31/03/2025 MZM :Spira 111945 BBNI - GENERATION PERICASES 
#[002] 30/06/2025 MZM :Spira 113086 BBNI TNR 4G - Regression - missing AE IO EBS and next retro loop
#[003] 18/09/2025 MZM : US 6269 BNI - TTECLEDA fields LOBACC_CF etc should be filled (Merge Pericase BBNI with Pericase EBS STD)	
#[004] 09/10/2025 MZM : US 5637 EBS INI - LORETFACTOR EBS INI (Extract)
#[005] 13/10/2025 MZM : US 5637 EBS INI - AE BBNI SONT DEPLACES DANS ESPD0061
#[005] 03/02/2026 MZM : US 7847 EBS INI - 
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT



if [ ! -f ${ESF_EPOSOCI_BBNI} ]
then
        ECHO_LOG "ESF_EPOSOCI_BBNI=${ESF_EPOSOCI_BBNI}  does not exist, take an empty file"
         >> $FLOG
        EXECKSH "touch ${ESF_EPOSOCI_BBNI}"

fi


ECHO_LOG "#====================================INPUT FILES====================="
ECHO_LOG "#===> EST_IADVPERICASE...............................................: ${EST_IADVPERICASE}"
ECHO_LOG "#===> EPO_OIADVPERICASE..............................................: ${EPO_OIADVPERICASE}"



ECHO_LOG "#========================================================================="
ECHO_LOG "#====================================INPUT PARAMETERS====================="
ECHO_LOG "#===> PARM_ICLODAT_D.....................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> NORME_CF...........................................................: ${NORME_CF}"
ECHO_LOG "#===> TYPEINV............................................................: ${TYPEINV}"
ECHO_LOG "#===> X_DAYS.............................................................: ${X_DAYS}"
ECHO_LOG "#===> QUARTER_END_FOUND..................................................: ${QUARTER_END_FOUND}"
ECHO_LOG "#========================================================================="
ECHO_LOG "#====================================OUTPUT FILES====================="
ECHO_LOG "#===> ESF_IRDPERICASE_BBNI...............................................: ${ESF_IRDPERICASE_BBNI}"
ECHO_LOG "#===> ESF_IADPERICASE_BBNI...............................................: ${ESF_IADPERICASE_BBNI}"
ECHO_LOG "#===> ESF_IADPERICASE_MRG................................................: ${ESF_IADPERICASE_MRG}"
ECHO_LOG "#===> ESF_IADPERIFCT_BBNI................................................: ${ESF_IADPERIFCT_BBNI}"
ECHO_LOG "#===> ESF_IADPERIFCI_BBNI................................................: ${ESF_IADPERIFCI_BBNI}"
ECHO_LOG "#===> ESF_IADPERIFR_BBNI.................................................: ${ESF_IADPERIFR_BBNI}"
ECHO_LOG "#===> ESF_OIADVPERICASE_MRG..............................................: ${ESF_OIADVPERICASE_MRG}"
ECHO_LOG "#===> ESF_IADPERIFACACCEPT_BBNI..........................................: ${ESF_IADPERIFACACCEPT_BBNI}"

ECHO_LOG "#===> ESF_IRDPERICASE_INI...............................................: ${ESF_IRDPERICASE_INI}"
ECHO_LOG "#===> ESF_IADPERICASE_INI...............................................: ${ESF_IADPERICASE_INI}"
ECHO_LOG "#===> ESF_IADPERIFCT_INI................................................: ${ESF_IADPERIFCT_INI}"
ECHO_LOG "#===> ESF_IADPERIFCI_INI................................................: ${ESF_IADPERIFCI_INI}"
ECHO_LOG "#===> ESF_IADPERIFR_INI.................................................: ${ESF_IADPERIFR_INI}"
ECHO_LOG "#===> ESF_OIADVPERICASE_MRG_ALL.........................................: ${ESF_OIADVPERICASE_MRG_ALL}"
ECHO_LOG "#===> ESF_IADPERIFACACCEPT_INI..........................................: ${ESF_IADPERIFACACCEPT_INI}"

ECHO_LOG "#===> ESF_FLORETFACTOR_INI...............................................: ${ESF_FLORETFACTOR_INI}"
ECHO_LOG "#========================================================================="

# Extract LOFACTOR I17 : Generation Fichier INV /POS

# Borne Inferieure DATE_DEB en fonction type de closing

if  [ "${TYPEINV}" = "INV" ]
then
     if [ "${NORME_CF}" = "EBS" ] || [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
     then
                PARM_DATE_DEB_D="${PARM_BOOKING_D}"
                PARM_DATE_FIN_D="${PARM_BOOKINGNEXT_D}"
     fi
fi


if  [ "${TYPEINV}" = "POS" ]
then
     if [ "${NORME_CF}" = "EBS" ] || [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
     then
                PARM_DATE_DEB_D="${PARM_BOOKING_D}"
                PARM_DATE_FIN_D="${PARM_PSTOMGEND17_D}"
     fi
fi

ECHO_LOG "#===> PARM_PSTOMGEND17_D..............................................: ${PARM_PSTOMGEND17_D}"
ECHO_LOG "#===> PARM_BOOKINGNEXT_D..............................................: ${PARM_BOOKINGNEXT_D}"
ECHO_LOG "#===> PARM_BOOKING_D..................................................: ${PARM_BOOKING_D}"
ECHO_LOG "#===> PARM_DATE_FIN_D.................................................: ${PARM_DATE_FIN_D}"

ECHO_LOG "#===> PARM_ICLODAT_D..................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PARM_DATE_DEB_D.................................................: ${PARM_DATE_DEB_D}"



# Parameters
CRE_D=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
ICLODAT_D=$4
CLODAT_D=$5
OPTION=Q
SSD_CF=00
SEGTYP_CT=A

PARALLEL_INIT 50


NSTEP=${NJOB}_05
#Call PsLORETFACTOR_I17_01
#-----------------------------------------------------------------------------
LIBEL="Generation of Retro Loss Occuring File ESF_FLORETFACTOR AT INI EBS"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FLORETFACTOR_INI}
BCP_QRY="execute BEST..PsLORETFACTOR_INI_01   '${PARM_ICLODAT_D}', '${PARM_ICLODAT_D}', '${PARM_DATE_FIN_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' "
BCP
PARALLEL BCP



##[012]

NSTEP=${NJOB}_10
#Generation of BBNI TRT Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of BBNI Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERITRT_BBNI_O.dat
BCP_QRY="execute BEST..PsPeriTRT_BBNI_01 '${SEGTYP_CT}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_20
#Generation of BBNI FAC Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of BBNI FAC Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIFAC_BBNI_O.dat
BCP_QRY="execute BEST..PsPeriFAC_BBNI_01  '${SEGTYP_CT}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_25
#Generation of BBNI RETRO Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of BBNI RETRO Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
##BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIRetBBNI_O.dat
BCP_O=${ESF_IRDPERICASE_BBNI}
BCP_QRY="execute BEST..PsPeriRetBBNI_01  '${SEGTYP_CT}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP



NSTEP=${NJOB}_50
#Download to the XADPERIFCI Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCI Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_IADPERIFCI_BBNI}
BCP_QRY="execute BEST..PsPeriFCI_BBNI_04 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}',  '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_60
#Download to the XADPERIFCT Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCT perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_IADPERIFCT_BBNI} 
BCP_QRY="execute BEST..PsPeriFCT_BBNI_05 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}',  '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_70
#Download to the XADPERIFR Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFR Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_IADPERIFR_BBNI} 
BCP_QRY="execute BEST..PsPeriFR_BBNI_03 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}',  '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_80
#Generation of EBS INI TRT Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of EBS INI Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERITRT_EBS_INI_O.dat
BCP_QRY="execute BEST..PsPeriTRT_EBS_INI_01 '${SEGTYP_CT}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_90
#Generation of EBS INI FAC Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of EBS INI FAC Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIFAC_EBS_INI_O.dat
BCP_QRY="execute BEST..PsPeriFAC_EBS_INI_01  '${SEGTYP_CT}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_100
#Generation of EBS INI RETRO Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of EBS INI RETRO Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
##BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIRet_EBS_INI_O.dat
BCP_O=${ESF_IRDPERICASE_INI}
BCP_QRY="execute BEST..PsPeriRet_EBS_INI_01  '${SEGTYP_CT}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP



NSTEP=${NJOB}_110
#Download to the XADPERIFCI EBS INI Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCI EBS INI Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_IADPERIFCI_INI}
BCP_QRY="execute BEST..PsPeriFCI_EBS_INI_04 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}',  '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_120
#Download to the XADPERIFCT EBS INI Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCT EBS INI perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_IADPERIFCT_INI} 
BCP_QRY="execute BEST..PsPeriFCT_EBS_INI_05 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}',  '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_130
#Download to the XADPERIFREBS INI  Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFR EBS INI Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_IADPERIFR_INI} 
BCP_QRY="execute BEST..PsPeriFR_EBS_INI_03 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}',  '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
PARALLEL BCP
		


##[012]

PARALLEL_END

if [ ${TYPEINV} = "POS" ]
then

NSTEP=${NJOB}_275
#Generation of BBNI FAC ACCEPT Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of BBNI FAC ACCEPT  Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_IADPERIFACACCEPT_BBNI}
##BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIFACACCEPT_BBNI_O.dat
BCP_QRY="execute BEST..PsPeriFACACCEPT_BBNI_01_02  '${SEGTYP_CT}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"

else

touch ${ESF_IADPERIFACACCEPT_BBNI}

fi

NSTEP=${NJOB}_280
#Merge and Sort of perimeter files by Contract/Endorsement/Section/UW Year
# and UW Year sequence number
#-----------------------------------------------------------------------------
LIBEL="Current BBNI Perimeters File Sort and Fusion..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_BCP_PERITRT_BBNI_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_20_${IB}_BCP_PERIFAC_BBNI_O.dat 1000 1"
##SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_BBNI_O.dat
SORT_O="${ESF_IADPERICASE_BBNI} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:, UWORG_CF 119:1 - 119:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/OUTFILE  ${SORT_O}
exit
EOF
SORT

## RETRO P  / RETRO NP BBNI

NSTEP=${NJOB}_285
#------------------------------------------------------------------------------------
LIBEL=" RETRO NP AND RETRO PROP from ESF_IRDPERICASE_BBNI"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IRDPERICASE_BBNI} 2000 1"  
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETRO_NP.dat 2000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETPROP.dat 2000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS
        RETCTR_NF        3:1 -   3:,
        RETEND_NF        4:1 -   4:,
        RETSEC_NF        5:1 -   5:,
        RTY_NF           6:1 -   6:,
        RETUW_NT         7:1 -   7:,    
        NATRET_CF        49:1 - 49:               

/KEYS   RETCTR_NF,
				RETEND_NF,    
				RETSEC_NF,
				RTY_NF,   
				RETUW_NT 				
/CONDITION  RETRO_NP ( (NATRET_CF = "30") OR (NATRET_CF = "31") OR (NATRET_CF = "32") OR (NATRET_CF = "40") OR (NATRET_CF = "41")  ) 
/OUTFILE ${SORT_O} OVERWRITE
/INCLUDE RETRO_NP
/OUTFILE ${SORT_O2} OVERWRITE
/OMIT RETRO_NP
exit
EOF
SORT


##  DEPLACEMENT DE la GENERATION des AE BBNI dans ESPD0060
###
#####[044] Filter EPO_EPOSOCI ON BBNI CONTRATS ==> ESF_EPOSOCI_BBNI  
###
###
###ECHO_LOG "#===> ESF_IADPERICASE_BBNI..DEBUG.....00......: ${ESF_IADPERICASE_BBNI}   "
###
###NSTEP=${NJOB}_310
####-----------------------------------------------------------------------------
###LIBEL="Split contrat assmued and retro "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${ESF_EPOSOCI}  2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS.dat 2000 1"
###SORT_O2="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RET.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS TRNCOD1_CF       6:1 -  6:1,
###        CTR_NF           8:1 -  8:,
###        END_NT           9:1 -  9:,
###        SEC_NF          10:1 - 10:,
###        UWY_NF          11:1 - 11:,
###        UW_NT           12:1 - 12:,
###	      CUR_CF          18:1 -  18:,
###        RETCTR_NF       24:1 - 24:,
###        RETEND_NT       25:1 - 25:,
###        RETSEC_NF       26:1 - 26:,
###        RTY_NF          27:1 - 27:,
###        RETUW_NT        28:1 - 28:,
###        PLC_NT          36:1 - 36:EN,
###        SEGNAT_CT       48:1 - 48:,
###        ACCRET_CF       49:1 - 49:  
###/KEYS   CTR_NF,
###        END_NT,
###        SEC_NF,
###        UWY_NF,
###        UW_NT,
###        RETCTR_NF,
###        RETEND_NT,
###        RETSEC_NF,
###        RTY_NF,
###        RETUW_NT,
###        ACCRET_CF,
###        SEGNAT_CT,
###        PLC_NT,
###        CUR_CF
###/CONDITION COND_GTAA ( TRNCOD1_CF EQ "1" OR TRNCOD1_CF EQ "3" )
###/OUTFILE ${SORT_O} OVERWRITE
###/INCLUDE COND_GTAA
###/OUTFILE ${SORT_O2} OVERWRITE
###/OMIT COND_GTAA
###exit
###EOF
###SORT
###
###ECHO_LOG "#===> ESF_IADPERICASE_BBNI..DEBUG....001.......: ${ESF_IADPERICASE_BBNI}   "
###
###
###
###ECHO_LOG "#===> ESF_IADPERICASE_BBNI..DEBUG....003.......: ${ESF_IADPERICASE_BBNI}   "
###
###
###ECHO_LOG "#===> ESF_IADPERIFACACCEPT_BBNI..DEBUG....003.......: ${ESF_IADPERIFACACCEPT_BBNI}   "
###
###
###NSTEP=${NJOB}_320
####-----------------------------------------------------------------------------
###LIBEL="Extract AE for BBNI Contracts RETRO NP "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_310_${IB}_EPOSOCI_RET.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS GT_RETCTR_NF    24:1 -  24:,
###        GT_RETEND_NT    25:1 -  25:,
###        GT_RETSEC_NF    26:1 - 26:,
###        GT_RTY_NF       27:1 - 27:,
###        GT_RETUW_NT     28:1 - 28:,
###        GT_ALL_COLS          1:1 - 49:,
###        PER_CTR_NF           3:1 - 3:,
###        PER_END_NT           4:1 - 4:,
###        PER_SEC_NF           5:1 - 5:,
###        PER_UWY_NF           6:1 - 6:,
###        PER_UW_NT            7:1 - 7:
###/joinkeys 
###        GT_RETCTR_NF  ,
###        GT_RETEND_NT  ,
###        GT_RETSEC_NF  ,
###        GT_RTY_NF     ,
###        GT_RETUW_NT  
###/INFILE ${DFILT}/${NJOB}_285_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETRO_NP.dat 2000 1 "~"
###/joinkeys 
###        PER_CTR_NF ,
###        PER_END_NT ,
###        PER_SEC_NF ,
###        PER_UWY_NF ,
###        PER_UW_NT
###/OUTFILE ${SORT_O} overwrite
###/REFORMAT
###        leftside :GT_ALL_COLS
###exit
###EOF
###SORT
###
###
###
###NSTEP=${NJOB}_325
####-----------------------------------------------------------------------------
###LIBEL="Extract AE for BBNI Contracts RETRO PROP "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_310_${IB}_EPOSOCI_RET.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_RETPROP.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS GT_RETCTR_NF    24:1 -  24:,
###        GT_RETEND_NT    25:1 -  25:,
###        GT_RETSEC_NF    26:1 - 26:,
###        GT_RTY_NF       27:1 - 27:,
###        GT_RETUW_NT     28:1 - 28:,
###        GT_ALL_COLS          1:1 - 49:,
###        PER_CTR_NF           3:1 - 3:,
###        PER_END_NT           4:1 - 4:,
###        PER_SEC_NF           5:1 - 5:,
###        PER_UWY_NF           6:1 - 6:,
###        PER_UW_NT            7:1 - 7:
###/joinkeys 
###        GT_RETCTR_NF  ,
###        GT_RETEND_NT  ,
###        GT_RETSEC_NF  ,
###        GT_RTY_NF     ,
###        GT_RETUW_NT  
###/INFILE ${DFILT}/${NJOB}_285_${IB}_SORT_ESF_IRDPERICASE_BBNI_RETPROP.dat 2000 1 "~"
###/joinkeys 
###        PER_CTR_NF ,
###        PER_END_NT ,
###        PER_SEC_NF ,
###        PER_UWY_NF ,
###        PER_UW_NT
###/OUTFILE ${SORT_O} overwrite
###/REFORMAT
###        leftside :GT_ALL_COLS
###exit
###EOF
###SORT
###
###
###
##### ALL ASS AND RETRTO PROP BBNI
###
###NSTEP=${NJOB}_330
####-----------------------------------------------------------------------------
###LIBEL="MERGE  AE BBNI ASS and RETRO PROP Contracts  "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_310_${IB}_EPOSOCI_ASS.dat 2000 1"
###SORT_I2="${DFILT}/${NJOB}_325_${IB}_EPOSOCI_RETPROP.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS_RETPROP.dat  2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS CTR_NF           8:1 -  8:,
###        END_NT           9:1 -  9:,
###        SEC_NF          10:1 - 10:,
###        UWY_NF          11:1 - 11:,
###        UW_NT           12:1 - 12:,
###	      CUR_CF          18:1 -  18:,
###        RETCTR_NF       24:1 - 24:,
###        RETEND_NT       25:1 - 25:,
###        RETSEC_NF       26:1 - 26:,
###        RTY_NF          27:1 - 27:,
###        RETUW_NT        28:1 - 28:,
###        PLC_NT          36:1 - 36:EN,
###        SEGNAT_CT       48:1 - 48:,
###        ACCRET_CF       49:1 - 49:
###        
###/KEYS   CTR_NF,
###        END_NT,
###        SEC_NF,
###        UWY_NF,
###        UW_NT,
###        RETCTR_NF,
###        RETEND_NT,
###        RETSEC_NF,
###        RTY_NF,
###        RETUW_NT
###/OUTFILE ${SORT_O} OVERWRITE
###exit
###EOF
###SORT
###
###
###NSTEP=${NJOB}_340
####-----------------------------------------------------------------------------
###LIBEL="Extract AE for BBNI Contracts ASS "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_330_${IB}_EPOSOCI_ASS_RETPROP.dat 2000 1"
###SORT_O="${DFILT}/${NSTEP}_${IB}_EPOSOCI_ASS_RETPROP.dat 2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS GT_CTR_NF    8:1 -  8:,
###        GT_END_NT    9:1 -  9:,
###        GT_SEC_NF    10:1 - 10:,
###        GT_UWY_NF    11:1 - 11:,
###        GT_UW_NT     12:1 - 12:,
###        GT_ALL_COLS          1:1 - 49:,
###        PER_CTR_NF           3:1 - 3:,
###        PER_END_NT           4:1 - 4:,
###        PER_SEC_NF           5:1 - 5:,
###        PER_UWY_NF           6:1 - 6:,
###        PER_UW_NT            7:1 - 7:
###/joinkeys 
###        GT_CTR_NF ,
###        GT_END_NT ,
###        GT_SEC_NF ,
###        GT_UWY_NF ,
###        GT_UW_NT
###/INFILE ${ESF_IADPERICASE_BBNI} 2000 1 "~"
###/joinkeys 
###        PER_CTR_NF ,
###        PER_END_NT ,
###        PER_SEC_NF ,
###        PER_UWY_NF ,
###        PER_UW_NT
###/OUTFILE ${SORT_O} overwrite
###/REFORMAT
###        leftside :GT_ALL_COLS
###exit
###EOF
###SORT
###
###NSTEP=${NJOB}_350
####-----------------------------------------------------------------------------
###LIBEL="MERGE  AE BBNI ASS and RETRO Contracts  "
###SORT_WDIR=${SORTWORK}
###SORT_CMD=`CFTMP`
###SORT_I="${DFILT}/${NJOB}_340_${IB}_EPOSOCI_ASS_RETPROP.dat 2000 1"
###SORT_I2="${DFILT}/${NJOB}_320_${IB}_EPOSOCI_RETRO_NP.dat 2000 1"
###SORT_O="${ESF_EPOSOCI_BBNI}  2000 1"
###INPUT_TEXT ${SORT_CMD} <<EOF
###/FIELDS CTR_NF           8:1 -  8:,
###        END_NT           9:1 -  9:,
###        SEC_NF          10:1 - 10:,
###        UWY_NF          11:1 - 11:,
###        UW_NT           12:1 - 12:,
###	      CUR_CF          18:1 -  18:,
###        RETCTR_NF       24:1 - 24:,
###        RETEND_NT       25:1 - 25:,
###        RETSEC_NF       26:1 - 26:,
###        RTY_NF          27:1 - 27:,
###        RETUW_NT        28:1 - 28:,
###        PLC_NT          36:1 - 36:EN,
###        SEGNAT_CT       48:1 - 48:,
###        ACCRET_CF       49:1 - 49:
###        
###/KEYS   CTR_NF,
###        END_NT,
###        SEC_NF,
###        UWY_NF,
###        UW_NT,
###        RETCTR_NF,
###        RETEND_NT,
###        RETSEC_NF,
###        RTY_NF,
###        RETUW_NT
###/OUTFILE ${SORT_O} OVERWRITE
###exit
###EOF
###SORT



## MERGE PERICASE EBS STD and EBS BBNI




NSTEP=${NJOB}_370
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-INI not in pericase STD : MRG EBS BBNI AND EBS STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADPERICASE_BBNI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_BBNI_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       3:1 -  3:, 
		END_NT       4:1 -  4:, 
		SEC_NF       5:1 -  5:, 
		UWY_NF       6:1 -  6:, 
		UW_NT        7:1 -  7:, 
		STD_CTR_NF   3:1 -  3:, 
		STD_END_NT   4:1 -  4:, 
		STD_SEC_NF   5:1 -  5:, 
		STD_UWY_NF   6:1 -  6:, 
		STD_UW_NT    7:1 -  7:,
		ALL_COLS     1:1 -  252: 
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EST_IADVPERICASE} 2000 1 "~"
/joinkeys
        STD_CTR_NF,
        STD_END_NT,
        STD_SEC_NF,
        STD_UWY_NF,
        STD_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT

	


NSTEP=${NJOB}_375
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT PERICASE INI And STD "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_370_${IB}_SORT_IADVPERICASE_BBNI_O.dat 2000 1"
SORT_I2="${EST_IADVPERICASE} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_MERGE_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       3:1 -  3:, 
        		END_NT       4:1 -  4:, 
        		SEC_NF       5:1 -  5:, 
       		  UWY_NF       6:1 -  6:, 
        		UW_NT        7:1 -  7: 
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_380
#------------------------------------------------------------------------------
LIBEL=" SORT PERICASE MERGE  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_375_${IB}_SORT_IADVPERICASE_MERGE_O.dat 2000 1"
SORT_O="${ESF_IADPERICASE_MRG} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       3:1 -  3:, 
        		END_NT       4:1 -  4:, 
        		SEC_NF       5:1 -  5:, 
       		  UWY_NF       6:1 -  6:, 
        		UW_NT        7:1 -  7: 
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

##[003] ## MERGE PERICASE EBS OIADV and EBS BBNI 


NSTEP=${NJOB}_400
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-BBNI not in pericase STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADPERICASE_BBNI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_BBNI_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       3:1 -  3:, 
		END_NT       4:1 -  4:, 
		SEC_NF       5:1 -  5:, 
		UWY_NF       6:1 -  6:,
		UW_NT        7:1 -  7:, 
		STD_CTR_NF   3:1 -  3:, 
		STD_END_NT   4:1 -  4:, 
		STD_SEC_NF   5:1 -  5:, 
		STD_UWY_NF   6:1 -  6:, 
		STD_UW_NT    7:1 -  7:,
		ALL_COLS     1:1 -  252: 		
/joinkeys
       			 CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EPO_OIADVPERICASE} 2000 1 "~"
/joinkeys
        STD_CTR_NF,
        STD_END_NT,
        STD_SEC_NF,
        STD_UWY_NF,
        STD_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT


NSTEP=${NJOB}_410
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT PERICASE BBNI And STD "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_400_${IB}_SORT_IADPERICASE_BBNI_O.dat 2000 1"
SORT_I2="${EPO_OIADVPERICASE} 2000 1"
SORT_O="${ESF_OIADVPERICASE_MRG} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       3:1 -  3:, 
        		END_NT       4:1 -  4:, 
        		SEC_NF       5:1 -  5:, 
       		  UWY_NF       6:1 -  6:, 
        		UW_NT        7:1 -  7:    		
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

###

NSTEP=${NJOB}_450
#Merge and Sort of perimeter files by Contract/Endorsement/Section/UW Year
# and UW Year sequence number
#-----------------------------------------------------------------------------
LIBEL="Current INI Perimeters File Sort and Fusion..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_BCP_PERITRT_EBS_INI_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_90_${IB}_BCP_PERIFAC_EBS_INI_O.dat 1000 1"
##SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_EBS_INI_O.dat
SORT_O="${ESF_IADPERICASE_INI} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:, UWORG_CF 119:1 - 119:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/OUTFILE  ${SORT_O}
exit
EOF
SORT


##[003] ## MERGE PERICASE EBS STD and EBS INI 


NSTEP=${NJOB}_460
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-INI not in pericase STD"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_IADPERICASE_INI} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERICASE_INI_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       3:1 -  3:, 
		END_NT       4:1 -  4:, 
		SEC_NF       5:1 -  5:, 
		UWY_NF       6:1 -  6:,
		UW_NT        7:1 -  7:, 
		STD_CTR_NF   3:1 -  3:, 
		STD_END_NT   4:1 -  4:, 
		STD_SEC_NF   5:1 -  5:, 
		STD_UWY_NF   6:1 -  6:, 
		STD_UW_NT    7:1 -  7:,
		ALL_COLS     1:1 -  252: 		
/joinkeys
       			 CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EPO_OIADVPERICASE} 2000 1 "~"
/joinkeys
        STD_CTR_NF,
        STD_END_NT,
        STD_SEC_NF,
        STD_UWY_NF,
        STD_UW_NT
/JOIN UNPAIRED LEFTSIDE ONLY
/OUTFILE ${SORT_O} overwrite
/REFORMAT LEFTSIDE:ALL_COLS
exit
EOF
SORT


NSTEP=${NJOB}_470
#------------------------------------------------------------------------------
LIBEL="MERGE AND SORT PERICASE INI And STD "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_460_${IB}_SORT_IADPERICASE_INI_O.dat 2000 1"
SORT_I2="${EPO_OIADVPERICASE} 2000 1"
SORT_O="${ESF_IADPERICASE_MRG_INI} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       3:1 -  3:, 
        		END_NT       4:1 -  4:, 
        		SEC_NF       5:1 -  5:, 
       		  UWY_NF       6:1 -  6:, 
        		UW_NT        7:1 -  7:    		
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

##
##NSTEP=${NJOB}_500
###------------------------------------------------------------------------------
##LIBEL="Generation of the file FPATTERNEBS_INI for all type of Pattern"
##BCP_WAY="OUT"
##BCP_VER="+"
##BCP_O=${ESF_FSEGPATTERNDSCf17}
##BCP_QRY="execute BEST..PsFPATTERNSII_F17_02 '${PARM_CRE_D}', '${PATCAT_CT}', ${PARM_BLCSHTYEA_NF}, '${TYPEINV}', '${PARM_ICLODAT_D}', '${NORME_CF}'"
##BCP


JOBEND
