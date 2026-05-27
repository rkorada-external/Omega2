#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : Generation fichier Reporting pour RA
# nom du script SHELL           : ESID8111.cmd
# revision                      : 
# date de creation              : 08/04/2016
# auteur                        : Roger Cassis
# references des specifications : :spot:30475
#-----------------------------------------------------------------------------
# Description :
#  Generation d'un fichier de reporting provenant du Bresil pour un chargement dans RA
#
# Launch applicative job ESID8111
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] JJ/MM/AAAA <prog name> :spot:xxxxx - Comment
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
ORIGINE_NF=$1
BALSHTRIM_NF=$2

################################################################
#Les différentes valeurs possibles pour SPEENTNAT_CT sont : 
#1             Ecriture Service
#2             Social Ec. Serv
#3             Conso Ec. Serv.
#4             Écriture service EBS -> rien dans TACCSUP
#5             Écriture Serv. Social EBS
#6             Écriture Serv. Conso EBS
################################################################
# Format du Fichier CLS_Type
#Norme données~type inv~année/mois du trimestre
#IFRS~INV~YYYYMM    -> contains IFRS std
#IFRS~POS~YYYYMM    -> contains IFRS std + POS
#IFRS~POC~YYYYMM    -> contains IFRS POC
#EBS~POS~YYYYMM     -> contains EBS POS
#EBS~POC~YYYYMM     -> contains EBS POC
#GAAP~BRA~YYYYMM    -> contains adjustements from Brazil
################################################################

TRIM=`echo ${BALSHTRIM_NF} | awk '{trim = substr($0,5,2)/3; print trim;}'`
BALSHTYEA_NFTRIM=`echo ${BALSHTRIM_NF} | cut -c1-4` 
BALSHTMTH_NFDEB=`echo ${BALSHTRIM_NF} | awk '{mth = substr($0,5,2) - 2; print mth}'`
BALSHTMTH_NFFIN=`echo ${BALSHTRIM_NF} | cut -c5-6` 

EST_FTECLEDA=`ls -rt ${DFILI}/${ENV_PREFIX}_CNED0010_${ORIGINE_NF}_*_FTECLEDA.dat | tail -1`
EST_FTECLEDR=`ls -rt ${DFILI}/${ENV_PREFIX}_CNED0010_${ORIGINE_NF}_*_FTECLEDR.dat | tail -1`
EST_FRAADJUST=${NCHAIN}_RAAJUST_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
EST_FRRADJUST=${NCHAIN}_RRAJUST_${BALSHTYEA_NFTRIM}_${TRIM}Q_${HOST_PRDSIT}.dat
EST_CLS=${NCHAIN}_CLSTYPE_${HOST_PRDSIT}.dat
EST_FILE_LIST=${NCHAIN}_FILE_LIST_${HOST_PRDSIT}.dat

# Job Initialisation
JOBINIT

#----------------------
SPEENTNAT_CTDEFAUT=1
#----------------------
NORME=GAAP
TYPEINV=BRA

ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> EST_FTECLEDA.........: ${EST_FTECLEDA}"
ECHO_LOG "#===> EST_FTECLEDR.........: ${EST_FTECLEDR}"
ECHO_LOG "#===> EST_FRAADJUST........: ${DNZFILP}/${EST_FRAADJUST}"
ECHO_LOG "#===> EST_FRRADJUST........: ${DNZFILP}/${EST_FRRADJUST}"
ECHO_LOG "#===> EST_FTECLEDAYTD......: ${DNZFILP}/${EST_FTECLEDAYTD}"
ECHO_LOG "#===> EST_FTECLEDRYTD......: ${DNZFILP}/${EST_FTECLEDRYTD}"
ECHO_LOG "#===> EST_FILE_LIST........: ${DNZFILP}/${EST_FILE_LIST}"
ECHO_LOG "#===> EST_CLS..............: ${DNZFILP}/${EST_CLS}"
ECHO_LOG "#===> CRE_D................: ${CRE_D}"
ECHO_LOG "#===> BALSHTYEA_NF.........: ${BALSHTYEA_NF}"
ECHO_LOG "#===> BALSHTMTH_NF.........: ${BALSHTMTH_NF}"
ECHO_LOG "#===> BALSHTYEA_NFTRIM.....: ${BALSHTYEA_NFTRIM}"
ECHO_LOG "#===> BALSHTMTH_NFDEB......: ${BALSHTMTH_NFDEB}"
ECHO_LOG "#===> BALSHTMTH_NFFIN......: ${BALSHTMTH_NFFIN}"
ECHO_LOG "#===> CLODAT_D.............: ${CLODAT_D}"
ECHO_LOG "#===> TRIM.................: ${TRIM}"
ECHO_LOG "#===> TRIMP................: ${TRIMP}"
ECHO_LOG "#===> NORME................: ${NORME}"
ECHO_LOG "#===> TYPEINV..............: ${TYPEINV}"
ECHO_LOG "#===> SPEENTNAT_CTDEFAUT...: ${SPEENTNAT_CTDEFAUT}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_05
LIBEL="Erase Last Permanent files"
RMFIL "${DNZFILP}/${NCHAIN}_*.dat"

NSTEP=${NJOB}_10
# summarize TTECLEDA
#--------------------------------
LIBEL="Summarize TTECLEDA : ${EST_FTECLEDA} sur ${DNZFILP}/${EST_FRAADJUST}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA} 1000 1"
SORT_O="${DNZFILP}/${EST_FRAADJUST} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -   1:EN,
	ESB_CF            2:1 -   2:EN,
	BALSHEY_NF        3:1 -   3:EN,
	BALSHRMTH_NF      4:1 -   4:EN,
	TRNCOD_CF         6:1 -   6:,
	TRNCOD2_CF        6:2 -   6:2,
	TRNCOD8_CF        6:8 -   6:8,
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
	AMT_M            19:1 -  19:EN 15/3,
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
	RETAMT_M         35:1 -  35:EN 15/3,
	PLC_NT           36:1 -  36:,
	RTO_NF           37:1 -  37:,
	RETINTAMT_M      88:1 -  88:EN 15/3,
	ZZRECONKEY_CF   102:1 - 102:,
	TRN_NT          103:1 - 103:,
	ORICOD_LS       104:1 - 104:,
	RETROAUTO_B     105:1 - 105:,
	SPEENTNAT_CT    106:1 - 106:,
	EVT_NF          107:1 - 107:,
	REVT_NF         108:1 - 108:,
	RETARDRETINT_B  109:1 - 109:,
   DEBCOLS1          1:1 -   3:,
   DEBCOLS2          5:1 - 105:,
   FINCOLS2        107:1 - 118:
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
	ZZRECONKEY_CF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B

/CONDITION RESTRICTION ( AMT_M NE 0 OR RETAMT_M NE 0 OR RETINTAMT_M NE 0) and BALSHEY_NF > 0
                         and BALSHRMTH_NF >= ${BALSHTMTH_NFDEB} and BALSHRMTH_NF <= ${BALSHTMTH_NFFIN}
/CONDITION SPEENTNAT ("ABDEGHIJKL" CT TRNCOD2_CF OR "GH" CT TRNCOD8_CF) AND "${SPEENTNAT_CTDEFAUT}" != "6"
/DERIVEDFIELD BALSHRMTH_NFC BALSHRMTH_NF COMPRESS
/DERIVEDFIELD SPEENTNAT_CT2 if SPEENTNAT then "5~" else "${SPEENTNAT_CTDEFAUT}~"
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT DEBCOLS1, BALSHRMTH_NFC, DEBCOLS2, SPEENTNAT_CT2, FINCOLS2
exit
EOF
SORT

NSTEP=${NJOB}_20
# summarize TTECLEDR
#-------------------------------------------
LIBEL="Summarize TTECLEDR : ${EST_FTECLEDR} sur ${DNZFILP}/${EST_FRRADJUST}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDR} 1000 1"
SORT_O="${DNZFILP}/${EST_FRRADJUST} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,
	ESB_CF            2:1 -  2:EN,
	BALSHEY_NF        3:1 -  3:EN,
	BALSHRMTH_NF      4:1 -  4:EN,
	TRNCOD_CF         6:1 -  6:,
	TRNCOD2_CF        6:2 -  6:2,
	TRNCOD8_CF        6:8 -  6:8,
	DBLTRNCOD_CF      7:1 -  7:,
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
	RETAMT_M         35:1 - 35:EN 15/3,
	PLC_NT           36:1 - 36:,
	RTO_NF           37:1 - 37:,
	TRN_NT           56:1 - 56:,
	ORICOD_LS        57:1 - 57:,
	RETROAUTO_B      58:1 - 58:,
	SPEENTNAT_CT     59:1 - 59:,
	EVT_NF           60:1 - 60:,
	REVT_NF          61:1 - 61:,
	RETARDRETINT_B   62:1 - 62:,
   DEBCOLS1          1:1 -  3:,
   DEBCOLS2          5:1 - 58:,
   FINCOLS2         60:1 - 71:
/KEYS
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
	TRNCOD_CF,
	DBLTRNCOD_CF,
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
/CONDITION RESTRICTION RETAMT_M NE 0 and BALSHRMTH_NF >= ${BALSHTMTH_NFDEB} and BALSHRMTH_NF <= ${BALSHTMTH_NFFIN}
/CONDITION SPEENTNAT ("ABDEGHIJKL" CT TRNCOD2_CF OR "GH" CT TRNCOD8_CF) AND "${SPEENTNAT_CTDEFAUT}" != "6"
/SUMMARIZE  TOTAL RETAMT_M
/DERIVEDFIELD BALSHRMTH_NFC BALSHRMTH_NF COMPRESS
/DERIVEDFIELD SPEENTNAT_CT2 if SPEENTNAT then "5~" else "${SPEENTNAT_CTDEFAUT}~"
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/REFORMAT DEBCOLS1, BALSHRMTH_NFC, DEBCOLS2, SPEENTNAT_CT2, FINCOLS2
exit
EOF
SORT

ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Creation fichier descriptif dans ${EST_CLS}"
ECHO_LOG "#"
#------------------------------------------------------------------------------
echo "${NORME}~${TYPEINV}~${BALSHTYEA_NFTRIM}${BALSHTMTH_NFFIN}" > ${DNZFILP}/${EST_CLS}
cat ${DNZFILP}/${EST_CLS}

ECHO_LOG "#"
ECHO_LOG "#===> Creation liste des fichiers dans ${EST_FILE_LIST}"
ECHO_LOG "#"
#------------------------------------------------------------------------------
wc -l ${DNZFILP}/${NCHAIN}_*${HOST_PRDSIT}.dat |  grep -v "total" | grep -v "FILE_LIST" | awk '{split($0,tab1," "); i=split(tab1[2],tab2,"/"); print tab2[i] "~" tab1[1]}' > ${DNZFILP}/${EST_FILE_LIST}
cat ${DNZFILP}/${EST_FILE_LIST}

ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Sauvegarde des fichiers"
ECHO_LOG "#"
#------------------------------------------------------------------------------
if [ -f ${DNZFILP}/${EST_FRAADJUST} ]
then
	gzip -c ${DNZFILP}/${EST_FRAADJUST}  > ${DSAVE}/${SVG}_${EST_FRAADJUST}.gz
fi
if [ -f ${DNZFILP}/${EST_FRRADJUST} ]
then
	gzip -c ${DNZFILP}/${EST_FRRADJUST}  > ${DSAVE}/${SVG}_${EST_FRRADJUST}.gz
fi
gzip -c ${DNZFILP}/${EST_CLS}         > ${DSAVE}/${SVG}_${EST_CLS}.gz
gzip -c ${DNZFILP}/${EST_FILE_LIST}   > ${DSAVE}/${SVG}_${EST_FILE_LIST}.gz

ECHO_LOG "#"
ECHO_LOG "#"
ECHO_LOG "#===> Delete temporary file"
ECHO_LOG "#"
NSTEP=${NJOB}_100
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
