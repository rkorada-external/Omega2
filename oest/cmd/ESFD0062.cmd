#!/bin/ksh
#==================================================================================
#nom de l'application          : CHAIN EXTRACTION MARKET : BSBO..TUWSEC
#nom du source                 : ESFD0062.cmd
#revision                      : $Revision:   1.0  $
#date de creation              : 14/03/2019
#auteur                        : L.ELFAHIM
#-----------------------------------------------------------------------------
# modifications chronology:
# [001] 13/08/2019 JYP : spira 70377 : EXTRACT ESF_FRARAT
# [002] 18/09/2019 LEL : SPIRA 81087 : EXTRACT TABLE BREF..TPRSMAP TXT MODE
# [003] 18/09/2019 LEL : SPIRA 81087 : CLEAN env file to manage TP and DW2
# [004] 20/09/2019 LEL : SPIRA 81087 : GENEREATE ESF_FBOPRSLNK_TXT
# [005] 10/09/2019 AGD : SPIRA 77475 : Added extraction of table TUOASII
# [006] 12/11/2019 JYP : SPIRA 81988 : extract table TUWRETSEC
# [007] 27/01/2020 LEL : SPIRA 83904 : MAPING FILES MANAGEMENT
# [008] 28/02/2020 MZM : Spira:79070 REQ11. Generate RETRO LOSS OCCURING FILE AT INI 
# [009] 23/03/2019 JYP : SPIRA 81988 : extract table TUWRETSEC
# [010] 27/03/2019 LEL : SPIRA 79102 : extract table TEXPRAT for RETRO NP Ratios
# [011] 01/09/2020 JYP : SPIRA 83614 : granularity : extract FI17PRODUCT and FCTRI17PRD
# [012] 11/09/2020 JYP : SPIRA 83614 : granularity : extract FI17PRODUCT by site
# [013] 28/09/2020 MZM : Spira:90120 : REQ11. Generate RETRO LOSS OCCURING FILE AT Closing --> Deplace dans ESPD0061.cmd
# [014] 02/03/2020 MZM : Spira:92592 : EXtraction AE I17 --> Génération ESF_EPOSOCI
# [015] 21/07/2021 JYP : SPIRA:94896 : extraction TRETIFRS retro for granularity
# [016] 23/08/2021 MZM : Spira:95950 : EXtraction AE I17 --> Génération ESF_EPOSOCI MAJ PARM_PSTOMGEN_D --> PARM_ICLODAT_D
# [017] 23/08/2021 MiS : Spira 98007 : Desactivation écriture FPRSMAP 
# [018] 06/09/2021 LEL : Spira 97351 : ACF/PCA: Expenses calculation 
# [019] 15/12/2021 HR  : Spira 99667 : EBS/IFRS17 AE extraction during INV and POS
# [020] 02/02/2022 JYP : SPIRA 101782: revert granularity 
# [021] 20/04/2022 RC  : SPIRA 103840: Add balance sheet params at PiESTACCSUP_05I process
# [022] 04/26/2022 JBD : SPIRA 103672: Add getdate/bcp from ESFD4031
# [023] 05/07/2022 JBD : SPIRA 104778: Build new closing for I17S norm 
# [024] 08/11/2022 SBE : SPIRA 107049: IFRS17 LIFE - IFRS4 Reversal
# [025] 03/02/2023 MZM : Spira 108727: EBS/IFRS17 AE extraction on INV : Utilisation des PARMETRES PARM_CONSOMTH et PARM_CONSOYEA
# [026] 11/03/2023 MZM : Spira 111234: I17P/I17L extended- AE not extracted in the closing : Utilisation du PARM_PSTOMGEND17_POSX_D (nouveau) 
# [027] 19/03/2023 MZM : Spira 99999: I17P/I17L extended- AE not extracted in the closing : Utilisation du PARM_PSTOMGEND17_POSX_D Fix IN2 
#==================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

# Extraction AE I17
# SPEENTNAT_CT=9,10,11

# Parameters
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> NORME..........................................: ${NORME}"
ECHO_LOG "#===> param_Request_id...............................: ${param_Request_id}"
ECHO_LOG "#===> param_Context_id...............................: ${param_Context_id}"
ECHO_LOG "#===> PARM_CRE_D.....................................: $PARM_CRE_D"
ECHO_LOG "#===> PARM_CLODAT_D..................................: $PARM_CLODAT_D"
ECHO_LOG "#===> NORME_CF.......................................: ${NORME_CF}"
ECHO_LOG "#===> PARM_ICLODAT_D.................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PARM_BOOKING_D.................................: ${PARM_BOOKING_D}"
ECHO_LOG "#===> PARM_PSTOMGEN_D................................: ${PARM_PSTOMGEN_D}"
ECHO_LOG "#===> PARM_BOOKINGNEXT_D.............................: ${PARM_BOOKINGNEXT_D}"
ECHO_LOG "#===> PARM_PSTOMGEND17_D.............................: ${PARM_PSTOMGEND17_D}"
ECHO_LOG "#===> PARM_PSTOMGCONEND17_D..........................: ${PARM_PSTOMGCONEND17_D}"
ECHO_LOG "#===> PARM_PSTOMGEND17_PREV_D........................: ${PARM_PSTOMGEND17_PREV_D}" 
ECHO_LOG "#===> PARM_PSTOMGEND17_POSX_D........................: ${PARM_PSTOMGEND17_POSX_D}"

ECHO_LOG "#===> PARM_CONSOYEA........................: ${PARM_CONSOYEA}"
ECHO_LOG "#===> PARM_CONSOMTH........................: ${PARM_CONSOMTH}"

ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> SPEENTNAT_CT...............: ${SPEENTNAT_CT}"
ECHO_LOG "#===>     -------- input ----------"
ECHO_LOG "#===>            none       		 "
ECHO_LOG "#===>     -------- output ---------"
ECHO_LOG "#===> ESF_FEXPRAT................: $ESF_FEXPRAT"
ECHO_LOG "#===> ESF_FRARAT.................: $ESF_FRARAT"
ECHO_LOG "#===> ESF_FPRSMAP_TXT............: $ESF_FPRSMAP_TXT"
ECHO_LOG "#===> ESF_FUOASII................: $ESF_FUOASII"
ECHO_LOG "#===> ESF_FUWRETSEC .............: $ESF_FUWRETSEC "
ECHO_LOG "#===> ESF_RET_FEXPRAT ...........: $ESF_RET_FEXPRAT "
ECHO_LOG "#===> ESF_EPOSOCI ...............: $ESF_EPOSOCI "
ECHO_LOG "#===> ESF_FSEG_TSECIFRS_I17 .....: $ESF_FSEG_TSECIFRS_I17 "
ECHO_LOG "#===> ESF_GAAPMAP ...............: $ESF_GAAPMAP "
ECHO_LOG "#========================================================================="



PARM_DATE_DEB_D="$PARM_BOOKING_D}"
PARM_DATE_FIN_D="${PARM_CLODAT_D}"


if [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ] 
then  
     ##[019]
     #if [ "${TYPEINV}" = "INV" ] || [ "${TYPEINV}" = "POS" ]   
     if [ "${TYPEINV}" = "INV" ]    
     then 
     		PARM_DATE_DEB_D="${PARM_BOOKING_D}"
                SPEENTNAT_CT="9"
     fi
     
     ##[019]
     if [ "${TYPEINV}" = "POS" ]   
     then 
     		PARM_DATE_DEB_D="${PARM_PSTOMGEND17_PREV_D}"
                SPEENTNAT_CT="9,10"
     fi

     if [ "${TYPEINV}" = "POC" ]   
     then 
     		PARM_DATE_DEB_D="${PARM_PSTOMGEND17_D}"
                SPEENTNAT_CT="11"
     fi     
fi

ECHO_LOG "#===> SPEENTNAT_CT...............: ${SPEENTNAT_CT}"

if [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
then  
     if [ "${TYPEINV}" = "INV" ]   
     then 
     		PARM_DATE_FIN_D="${PARM_BOOKINGNEXT_D}"
     fi
	
## [026]  "${PARM_REQCOD_CT}" = "I17PYPOSX" ] || [ "${PARM_REQCOD_CT}" = "I17LYPOSX" ] 
## [026] AVANT PARM_DATE_FIN_D="${PARM_PSTOMGEND17_D}"
## [027] "if I17S" PARM_DATE_FIN_D="${PARM_PSTOMGEND17_D}"
     
     if [ "${TYPEINV}" = "POS" ] 
     then 
     		PARM_DATE_FIN_D="${PARM_PSTOMGEND17_POSX_D}"
     fi  
     
     if [ "${TYPEINV}" = "POS" ] && [ "${NORME_CF}" = "I17S" ]
     then 
     		PARM_DATE_FIN_D="${PARM_PSTOMGEND17_D}"
     fi  
         
     
     if [ "${TYPEINV}" = "POC" ]   
     then 
     		PARM_DATE_FIN_D="${PARM_PSTOMGCONEND17_D}"
     fi     
fi

###################################################################################################
###   DEB EXTRACTION DES DATES POUR LES PROC DES AE EN FONCTION DU TYPEINV et NORME_CF         ####
###################################################################################################

ECHO_LOG "#BORNE DATE_DEB ===> PARM_BOOKING_D..................: -- INV IFRS17     : ${PARM_BOOKING_D} "
#ECHO_LOG "#BORNE DATE_DEB ===> PARM_BOOKING_D.................: -- POS IFRS17     : ${PARM_BOOKING_D} "
ECHO_LOG "#BORNE DATE_DEB===>  PARM_PSTOMGEND17_D..............: -- POC IFRS17     : ${PARM_PSTOMGEND17_D} "
ECHO_LOG "#BORNE DATE_DEB===> PARM_PSTOMGEND17_PREV_D..........: -- POS IFRS17     : ${PARM_PSTOMGEND17_PREV_D} "

ECHO_LOG "#BORNE DATE_FIN ===> PARM_BOOKINGNEXT_D..............: -- INV IFRS17     : ${PARM_BOOKINGNEXT_D} "

if [ "${PARM_POSX}" != "_POSX" ]
then
	ECHO_LOG "#BORNE DATE_FIN ===> PARM_PSTOMGEND17_D..............: -- POS IFRS17     : ${PARM_PSTOMGEND17_D} "
else
	ECHO_LOG "#BORNE DATE_FIN POSX===> PARM_PSTOMGEND17_POSX_D.....: -- POSX IFRS17     : ${PARM_PSTOMGEND17_POSX_D} "
fi

ECHO_LOG "#BORNE DATE_FIN ===> PARM_PSTOMGCONEND17_D.............: -- POC IFRS17     : ${PARM_PSTOMGCONEND17_D} "
ECHO_LOG "#SPEENTNAT_CT   ===> SPEENTNAT_CT......................:                   : ${SPEENTNAT_CT} "

###################################################################################################
###   FIN EXTRACTION DES DATES POUR LES PROC DES AE EN FONCTION DU TYPEINV et NORME_CF         ####
###################################################################################################

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="extract table TEXPRAT into perm file ESF_FEXPRAT "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FEXPRAT}
BCP_QRY="execute BSEG..PsTEXPRAT_01 '${NORME_CF}','${PARM_ICLODAT_D}','${TYPEINV}' "
BCP

NSTEP=${NJOB}_20
#extraction of TRARAT
#-----------------------------------------------------------------------------
LIBEL="extract table TRARAT into perm file ESF_FRARAT "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O="${ESF_FRARAT}"
BCP_QRY="execute BSEG..PsTRARAT_01 '${NORME_CF}','${PARM_ICLODAT_D}','${TYPEINV}' "  
BCP

NSTEP=${NJOB}_30
#-----------------------------------------------------------------------------
LIBEL="EXTRACTION de la table BSBO..TUWSEC to Permanent file ESF_FMARKET_O..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FMARKET}
BCP_QRY="execute BSAR..PsGetMARKET_01"
BCP

NSTEP=${NJOB}_32
#-----------------------------------------------------------------------------
LIBEL="EXTRACTION of file ESF_FUWRETSEC ..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FUWRETSEC}
BCP_QRY="execute BSAR..PsTUWRETSEC_01"
BCP

NSTEP=${NJOB}_35
#-----------------------------------------------------------------------------
LIBEL="SWITCH to standart ${SRV_2}"
SWITCH_SRV ${SRV_2}

#[017]

NSTEP=${NJOB}_40
# Extraction  date in T_TMAPPING table  (text format)
#------------------------------------------------------------------------------
#LIBEL="Extraction  date in T_TMAPPING table (text format) "
#BCP_WAY="OUT"
#BCP_VER="+"
#BCP_O=${ESF_FPRSMAP_TXT}
#BCP_QRY="exec BREF..PsTMAPPING_01"
#BCP

NSTEP=${NJOB}_45
#extraction of TUOASII in TXT mode
#-----------------------------------------------------------------------------
LIBEL="extract table TUOASII into perm file ESF_FUOASII "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FUOASII}
BCP_QRY="execute BEST..PsUOASII_01"
BCP

# # [013]
##NSTEP=${NJOB}_50
### Begin Bcp
###------------------------------------------------------------------------------
##LIBEL="Generation of Retro Loss Occuring File ESF_FLORETFACTOR"
##BCP_WAY="OUT"
##BCP_VER="+"
##BCP_O=${ESF_FLORETFACTOR_STD}
##BCP_QRY="execute BEST..PsLORETFACTOR_02  '${PARM_ICLODAT_D}'"
##BCP
##
### [008]
##NSTEP=${NJOB}_55
### Begin Bcp
###------------------------------------------------------------------------------
##LIBEL="Generation of Retro Loss Occuring File ESF_FLORETFACTOR"
##BCP_WAY="OUT"
##BCP_VER="+"
##BCP_O=${ESF_FLORETFACTOR_INI}
##BCP_QRY="execute BEST..PsLORETFACTOR_01  '${PARM_ICLODAT_D}'"
##BCP


NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
LIBEL="extract TEXPRAT table for RETRO NP Ratios"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_RET_FEXPRAT}
BCP_QRY="execute BEST..PsTEXPRAT_RETRO_01 '${NORME_CF}','${PARM_ICLODAT_D}','${TYPEINV}'"
BCP

## [014]
## [016] PARM_PSTOMGEN_D --> PARM_ICLODAT_D  BCP_QRY="exec BEST..PiESTACCSUP_05I  '${PARM_BOOKING_D}', '${PARM_PSTOMGEN_D}', '${NORME_CF}'"
## [019] "exec BEST..PiESTACCSUP_05I  '${PARM_DATE_DEB_D}', '${PARM_DATE_FIN_D}', '${NORME_CF}'"
## [025] "exec BEST..PiESTACCSUP_05I  '${PARM_DATE_DEB_D}', '${PARM_DATE_FIN_D}', '${NORME_CF}', '${SPEENTNAT_CT}', ${PARM_BALSHEYEA_NF}, ${PARM_BALSHTMTH_NF}"  
  
NSTEP=${NJOB}_90_${TYPEINV}_${NORME_CF}
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Selection of service writings and update of service writings table I17 for ${TYPEINV}_${NORME_CF}"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_EPOSOCI}
BCP_QRY="exec BEST..PiESTACCSUP_05I  '${PARM_DATE_DEB_D}', '${PARM_DATE_FIN_D}', '${NORME_CF}', '${SPEENTNAT_CT}', ${PARM_CONSOYEA}, ${PARM_CONSOMTH}"  
BCP

NSTEP=${NJOB}_120
#-----------------------------------------------------------------------------
LIBEL="extract table TEXPRAT into perm file ESF_FEXPRAT "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_RATIO_TEXPRAT}
BCP_QRY="execute BEST..PsTEXPRAT_02 '${NORME_CF}','${PARM_ICLODAT_D}','${TYPEINV}' "
BCP

NSTEP=${NJOB}_130
#-----------------------------------------------------------------------------
LIBEL="extract SEG_NF TSECIFRS into perm file ESF_FSEG_TSECIFRS_I17 "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FSEG_TSECIFRS_I17}
BCP_QRY="execute BEST..PsGetSegment_01 '${NORME_CF}' "
BCP

NSTEP=${NJOB}_133
# Switch to TP server
#----------------------------------------------------------------------------
LIBEL="Switch to TP DB server ${SRV_2}"
SWITCH_SRV ${SRV_2}

NSTEP=${NJOB}_135
#------------------------------------------------------------------------------
LIBEL="Generation of the file ESF_GAAPMAP using Norme"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_GAAPMAP}
BCP_QRY="execute BREF..PsGAAPMAP_01 '${NORME_CF}', '${PARM_CRE_D}'"
BCP

NSTEP=${NJOB}_135A
#------------------------------------------------------------------------------
LIBEL="Generation of the file ESF_GAAPMAP using Norme"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_GAAPMAPLIF}
BCP_QRY="execute BREF..PsGAAPMAP_LIFE_01 '${NORME_CF}', '${PARM_CRE_D}'"
BCP

NSTEP=${NJOB}_137
# Switch to DW server
#----------------------------------------------------------------------------
LIBEL="Switch to datawharehouse server ${SRV}"
SWITCH_SRV ${SRV}

JOBEND
