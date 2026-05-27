#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS -
#                                  Injection des resultats des calculs solvency et IFRS17 dans l'infocentre
# nom du script SHELL            : ESFD8602.cmd
# revision                       : $Revision: 1.0 $
# date de creation               : 19/04/2024
# auteur                         : MZM
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   :spira:77079 Injection of the Acceptance and Retrocession TL files into the infocenter		
#    
#
# Input files : IFRS17 L / P
#       ESF_FTECLEDSII                 DFILP
#       ESF_FTECLEDA                   DFILP
#       ESF_FTECLEDR                   DFILP	 
#			
# Output files
#
# launched by ESFD8600.cmd 
#
#-----------------------------------------------------------------------------
#[024] 19/04/2024 MZM       :spira:111540: ESFD8600 - TTECLED tables upload in closing extended period
#[025] 13/08/2024 MZM       :spira:111851: EESFD8600 - TTECLED tables upload in closing extended period (Don't TRUNCATE before Adding POSX Datas )
#[026] 13/02/2025 MZM       :spira:112654: EESFD8600 - TTECLED tables upload in closing extended period (DELETE LINES I17L ; I17P BEFORE INSERT )
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters


###  INTEGRATION DU POSX DANS LES TABLES  TTECLEDA / TTECLER /TTECLEDSII  ####



CRE_D=${PARM_CRE_D}
BALSHTYEA_NF=${PARM_BALSHTYEA_NF}
BALSHTMTH_NF=${PARM_BALSHTMTH_NF}
SUFFTABLE=${PARM_SUFFTABLE}


CLODAT_D=${PARM_ICLODAT_D}
INVCONSO_D=${PARM_INVCONSO_D}
EST_FTECLEDSII=${EPO_FTECLEDSII}
EST_GTSII_RISKMARGIN=${EPO_GTSII_RISKMARGIN}

# Job Initialisation
JOBINIT

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV.............: ${TYPEINV}"
ECHO_LOG "#===> CLODAT_D............: ${CLODAT_D}"
ECHO_LOG "#===> INVCONSO_D..........: ${INVCONSO_D}"
ECHO_LOG "#===> SUFFTABLE...........: ${SUFFTABLE}"
ECHO_LOG "#===> BALSHTYEA_NF........: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF........: ${BALSHTMTH_NF}"
ECHO_LOG "#===> CRE_D...............: ${CRE_D}"
ECHO_LOG "#========================================================================="



TTECLEDSII=TTECLEDSII_${SUFFTABLE}
TTECLEDA=TTECLEDA_${SUFFTABLE}
TTECLEDR=TTECLEDR_${SUFFTABLE}

ECHO_LOG ""
ECHO_LOG "#========================================================================="

ECHO_LOG "#===> EST_FTECLEDA........: ${EST_FTECLEDA}"
ECHO_LOG "#===> EST_FTECLEDR........: ${EST_FTECLEDR}"

ECHO_LOG "#===> ESF_FTECLEDA_I17L............: ${ESF_FTECLEDA_I17L}"
ECHO_LOG "#===> ESF_FTECLEDR_I17L............: ${ESF_FTECLEDR_I17L}"
ECHO_LOG "#===> ESF_FTECLEDA_I17P............: ${ESF_FTECLEDA_I17P}"
ECHO_LOG "#===> ESF_FTECLEDR_I17P............: ${ESF_FTECLEDR_I17P}"


ECHO_LOG "#===> TTECLEDSII..........: ${TTECLEDSII}"
ECHO_LOG "#===> ESF_FTECLEDSII_I17L......: ${ESF_FTECLEDSII_I17L}"
ECHO_LOG "#===> ESF_FTECLEDSII_I17P......: ${ESF_FTECLEDSII_I17P}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_5
LIBEL="MANAGE UNFOUND FILES " 



if [ ! -f "${ESF_FTECLEDSII_I17L}" ]
then
    EXECKSH "touch ${ESF_FTECLEDSII_I17L}"
fi


if [ ! -f "${ESF_FTECLEDA_I17P}" ]
then
    EXECKSH "touch ${ESF_FTECLEDA_I17P}"
fi

if [ ! -f "${ESF_FTECLEDA_I17L}" ]
then
    EXECKSH "touch ${ESF_FTECLEDA_I17L}"
fi



if [ ! -f "${ESF_FTECLEDR_I17P}" ]
then
    EXECKSH "touch ${ESF_FTECLEDR_I17P}"
fi

if [ ! -f "${ESF_FTECLEDR_I17L}" ]
then
    EXECKSH "touch ${ESF_FTECLEDR_I17L}"
fi

load=n

if [ -s "${ESF_FTECLEDA_I17L}" ] ||  [ -s "${ESF_FTECLEDA_I17P}" ] || [  -s "${ESF_FTECLEDR_I17L}" ] ||  [  -s "${ESF_FTECLEDSII_I17P}" ] || [  -s "${ESF_FTECLEDSII_I17L}" ] 
then
	load=y

fi




if [ "${load}" = "n" ]
then
	ECHO_LOG "#========================================================================="
	ECHO_LOG "#===> Pas de fichier à charger car pas de données pour ${INVCONSO_D} - Arret"
	ECHO_LOG "#========================================================================="
	JOBEND
fi

  

NSTEP=${NJOB}_220

LIBEL="Merge TECLESSII from IFRS17L AND IFRS17P "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDSII_I17L} 2000 1"
SORT_I2="${ESF_FTECLEDSII_I17P} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        SSD_CF            1:1 -  1:EN,
        ESB_CF            2:1 -  2:EN,
        BALSHEY_NF        3:1 -  3:,
        BALSHRMTH_NF      4:1 -  4:EN,
        BALSHRDAY_NF      5:1 -  5:EN,
        DBLTRNCOD_CF      7:1 -  7:,
        CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN,
        NORME_CF         30:1 - 30:
/KEYS 	CTR_NF,
	END_NT,  
	SEC_NF,
	UWY_NF,
	UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT    
    

NSTEP=${NJOB}_221
#-----------------------------------------------------------------------------
LIBEL="TRUNCATE SEG_NF"
AWK_I=${DFILT}/${NJOB}_220_${IB}_${TTECLEDSII}.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_${TTECLEDSII}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       {  if ( length(\$25) > 10 ) \$25 = substr(\$25,1,10);
          print \$0
       }
exit
EOF
AWK


NSTEP=${NJOB}_225
# Switch to infocentre server ${SRV_2}
# ${SRV_2} is already defined in the environnement file
#--------------------------------------------------------------------------
LIBEL="Switch to infocentre server ${SRV_2}"
SWITCH_SRV ${SRV_2}

#[026]

NSTEP=${NJOB}_230
#------------------------------------------------------------------------------
# Vider la Table des postes I17L ; I17P a partir du TRNCOD
LIBEL="Supprime de la Table des postes I17L ; I17P a partir de NORME_CFD"
ISQL_QRY="DELETE FROM BSAR..${TTECLEDSII} WHERE ( norme_cf = 'I17P')  OR ( norme_cf = 'I17L' )	"
ISQL_BASE='BSAR'
ISQL


NSTEP=${NJOB}_235
#--------------------------------
LIBEL="BCP in ${TTECLEDSII} table"
BCP_WAY="IN"
BCP_VER=""
##[025]BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_RMINFILE=NO
BCP_I=${DFILT}/${NJOB}_221_${IB}_${TTECLEDSII}.dat
BCP_TABLE="BSAR..${TTECLEDSII}"
BCP



NSTEP=${NJOB}_250

##------------------------------------------------------------------------------
#LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDSII','${CLODAT_D}',${BALSHTYEA_NF},${BALSHTMTH_NF},'${CRE_D}','CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL


if [ "${load}" = "y" ]
then
	gzip -c ${DFILT}/${NJOB}_220_${IB}_${TTECLEDSII}.dat > ${DARCH}/${ENV_PREFIX}_ESFD8600_FTECLEDSII_${INVCONSO_D}_${CRE_D}.dat.gz
fi



########################################################################################################################
#Addition steps to fill TTECLEDA and TTECLEDR tables
########################################################################################################################



NSTEP=${NJOB}_260
# summarize TTECLEDA by BALSHTDAY
#--------------------------------
LIBEL="Summarize TTECLEDA by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_I17L} 2000 1"
SORT_I2="${ESF_FTECLEDA_I17P} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDA_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	DBLTRNCOD_CF      7:1 -   7:,
	CTR_NF            8:1 -   8:,
	END_NT            9:1 -   9:,
	SEC_NF           10:1 -  10:,
	UWY_NF           11:1 -  11:,
	UW_NT            12:1 -  12:,
	OCCYEA_NF        13:1 -  13:EN,
	ACY_NF           14:1 -  14:EN,
	SCOSTRMTH_NF     15:1 -  15:EN,
	SCOENDMTH_NF     16:1 -  16:EN,
	CUR_CF           18:1 -  18:,
	AMT_M            19:1 -  19:EN 18/3,
	CED_NF           20:1 -  20:,
	RETCTR_NF        24:1 -  24:,
	RETEND_NT        25:1 -  25:,
	RETSEC_NF        26:1 -  26:,
	RTY_NF           27:1 -  27:,
	RETUW_NT         28:1 -  28:,
	RETOCCYEA_NF     29:1 -  29:EN,
	RETACY_NF        30:1 -  30:EN,
	RETSCOSTRMTH_NF  31:1 -  31:EN,
	RETSCOENDMTH_NF  32:1 -  32:EN,
	RETCUR_CF        34:1 -  34:,
	RETAMT_M         35:1 -  35:EN 18/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
  	CRE_D            41:1 -  41:,
	RETINTAMT_M      88:1 -  88:EN 18/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:
/KEYS
	SSD_CF,
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
	RTO_NF,
	CRE_D,
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0 ) and BALSHEY_NF > 0
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT


NSTEP=${NJOB}_270
# Sort of the FTECLEDA File on TTECLEDA_X index key
#------------------------------------------------------------------------------
LIBEL="Sort of FTECLEDA File on index key"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_260_${IB}_SORT_TECLEDA_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 - 1: EN,
        ESB_CF       2:1 - 2: EN,
        TRNCOD_CF    6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF,
      ESB_CF
exit
EOF
SORT

NSTEP=${NJOB}_280
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_260_${IB}_SORT_TECLEDA_O.dat



NSTEP=${NJOB}_290
#-------------------------------------------
LIBEL="Summarize TTECLEDR by BALSHTDAY"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR_I17L} 2000 1"
SORT_I2="${ESF_FTECLEDR_I17P} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDR_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,
	ESB_CF            2:1 -  2:EN,
	BALSHEY_NF        3:1 -  3:EN,
	BALSHRMTH_NF      4:1 -  4:EN,
	TRNCOD_CF         6:1 -  6:,
	DBLTRNCOD_CF      7:1 -  7:,
	CTR_NF            8:1 -   8:,
	END_NT            9:1 -   9:,
	SEC_NF           10:1 -  10:,
	UWY_NF           11:1 -  11:,
	UW_NT            12:1 -  12:,
	OCCYEA_NF        13:1 -  13:EN,
	ACY_NF           14:1 -  14:EN,
	SCOSTRMTH_NF     15:1 -  15:EN,
	SCOENDMTH_NF     16:1 -  16:EN,
	CUR_CF           18:1 -  18:,
	CED_NF           20:1 -  20:,
	RETCTR_NF        24:1 - 24:,
	RETEND_NT        25:1 - 25:,
	RETSEC_NF        26:1 - 26:,
	RTY_NF           27:1 - 27:,
	RETUW_NT         28:1 - 28:,
	RETOCCYEA_NF     29:1 - 29:EN,
	RETACY_NF        30:1 - 30:EN,
	RETSCOSTRMTH_NF  31:1 - 31:EN,
	RETSCOENDMTH_NF  32:1 - 32:EN,
	RETCUR_CF        34:1 - 34:,
	RETAMT_M         35:1 - 35:EN 18/3,
	PLC_NT           36:1 - 36:,
	RTO_NF           37:1 - 37:,
	TRN_NT           56:1 - 56:,
	ORICOD_LS        57:1 - 57:,
	RETROAUTO_B      58:1 - 58:,
	SPEENTNAT_CT     59:1 - 59:,
	EVT_NF           60:1 - 60:,
	REVT_NF          61:1 - 61:,
	RETARDRETINT_B   62:1 - 62:
/KEYS
	SSD_CF,
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
	RTO_NF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/CONDITION RESTRICTION RETAMT_M NE 0 and BALSHEY_NF > 0
/SUMMARIZE TOTAL RETAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
exit
EOF
SORT



NSTEP=${NJOB}_300
# Sort of the FTECLEDR File on TTECLEDR_X index key
#------------------------------------------------------------------------------
LIBEL="Sort of FTECLEDR File on index key"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_290_${IB}_SORT_TECLEDR_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF       1:1 - 1: EN,
        ESB_CF       2:1 - 2: EN,
        TRNCOD_CF    6:1 - 6:
/KEYS TRNCOD_CF,
      SSD_CF,
      ESB_CF
exit
EOF
SORT



NSTEP=${NJOB}_320
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_290_${IB}_SORT_TECLEDR_O.dat
 

## DELETE FROM "BSAR..${TTECLEDA}" WHERE (trncod_cf like '%M' OR trncod_cf like '%K') --  in '' and uwy_nf in '' and trncod_cf in '()')

#[026]

NSTEP=${NJOB}_325
#------------------------------------------------------------------------------
# Vider la Table des postes I17L ; I17P a partir du TRNCOD
LIBEL="Supprime de la Table des postes I17L ; I17P a partir du TRNCOD"
ISQL_QRY="DELETE FROM BSAR..${TTECLEDA} WHERE ( trncod_cf like '%M')  OR ( trncod_cf like '%K' )	"
ISQL_BASE='BSAR'
ISQL



NSTEP=${NJOB}_330
#--------------------------------
LIBEL="filling ${TTECLEDA} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_270_${IB}_SORT_FTECLEDA_O.dat
##[025]BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TTECLEDA}"
BCP



NSTEP=${NJOB}_340
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDA', '${INVCONSO_D}',
		${PARM_CONSOYEA}, ${PARM_CONSOMTH}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

NSTEP=${NJOB}_350
#deletion of temporary file
#--------------------------------------------------
LIBEL="Deletion of temporary file"
RMFIL ${DFILT}/${NJOB}_270_${IB}_SORT_FTECLEDA_O.dat

#[026]

NSTEP=${NJOB}_355
#------------------------------------------------------------------------------
# Vider la Table des postes I17L ; I17P a partir du TRNCOD
LIBEL="Supprime de la Table des postes I17L ; I17P a partir du TRNCOD"
ISQL_QRY="DELETE FROM BSAR..${TTECLEDR} WHERE ( trncod_cf like '%M')  OR ( trncod_cf like '%K' )	"
ISQL_BASE='BSAR'
ISQL


NSTEP=${NJOB}_360
# filling TTECLEDR table
#--------------------------------
LIBEL="filling ${TTECLEDR} table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_300_${IB}_SORT_FTECLEDR_O.dat
##[025]BCP_TRUNCATE=YES
BCP_PARTITION=YES
BCP_UPDATE_INDEX_STAT=YES
BCP_TABLE="BSAR..${TTECLEDR}"
BCP



NSTEP=${NJOB}_380
# Update TBOPAR
#------------------------------------------------------------------------------
LIBEL="Update LSTUPD_D in TBOPAR"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_QRY="execute PuTBOPAR_01 'EST', 'TTECLEDR', '${INVCONSO_D}',
		${PARM_CONSOYEA}, ${PARM_CONSOMTH}, '${CRE_D}', 'CP'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL

NSTEP=${NJOB}_400
#------------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

### FIN MODIF   ####



JOBEND
 
