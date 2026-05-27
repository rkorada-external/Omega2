#!/bin/ksh
#=============================================================================
# nom de l'application          : 11.04
#                                 Discount at current and locked in rates
# nom du script SHELL           : ESFD1131.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 13/03/2019
# auteur                        : Charles SOCIE
# references des specifications :
#-----------------------------------------------------------------------------
# description
#  : SPIRA 70378  : REQ 11.04 - IFRS17- Closing schedule : Discount at current and locked in rates
#
# Asynchronous Job launched by the TP
#-----------------------------------------------------------------------------
# historiques des modifications
#
#===============================================================================
#[001] 19/09/2019 : SPIRA 70537 : JYP : generate file ESF_FRERETFACCTR_INI, closing at inception
#[002] 26/09/2019 : SPIRA 70537 : JYP : new version to extract ESF_FRERETFACCTR_INI, closing at inception
#[003] 19/11/2020 : SPIRA 90059 : JYP : merge RateIndex INI+STD into ESF_TRERETFACCTR
#[004] 11/02/2021 : Spira 84719 : CAS : Extract TSECIFRS and TCR data by norm in interne file for the new IFRS Pericase file
#[005] 23/03/2021 : Spira 93745 : AGD : Extract TI17CLOPER data
#[006] 25/03/2021 : Spira 94906 : CAS : Delete NCB generation
#[007] 23/09/2021 : SPIRA 97283 : JYP : Illiquidity rules
#[008] 04/11/2021 : SPIRA 98300 : MZM : Generate ESF_FRERETFACCTR_TRN_STD For Transition
#[009] 04/07/2022 : SPIRA 104778: JBD : Build new closing for I17S norm
#[010] 17/10/2022 : SPIRA 102482: MZM : IFRS17 Onerous Q+1 - additional scope
#[011] 17/08/2023 : SPIRA 108961: M.Naji: P&C and Life- Closing output during local extended period
#===============================================================================

# set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV....................: ${TYPEINV}"
ECHO_LOG "#===> NORME......................: ${NORME}"
ECHO_LOG "#===> param_Request_id...........: ${param_Request_id}  "
ECHO_LOG "#===> param_Context_id...........: ${param_Context_id}  "
ECHO_LOG "#===> CONTEXT_CT.................: ${CONTEXT_CT}  "

ECHO_LOG "#===> PARM_ICLODAT_D.............: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> PATCAT_CT..................: ${PATCAT_CT}"
ECHO_LOG "#===> PARM_CRE_D.................: ${PARM_CRE_D}"
ECHO_LOG "#===> PARM_BLCSHTYEA_NF..........: ${PARM_BLCSHTYEA_NF}"
ECHO_LOG "#===> NORME_CF...................: ${NORME_CF}"
ECHO_LOG "#===> PARM_PSTOMGEND17_D.........: ${PARM_PSTOMGEND17_D}"
ECHO_LOG "#===> PARM_REQCOD_CT.............: ${PARM_REQCOD_CT}"

ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> ESF_ILL_BUCKET ............: ${ESF_ILL_BUCKET}"

ECHO_LOG "#===> ............ OUTPUT ................................................."
ECHO_LOG "#===> ESF_FRERETFACCTR_INI .................: ${ESF_FRERETFACCTR_INI}"
ECHO_LOG "#===> ESF_FSEGPATTERNDSCf17.................: ${ESF_FSEGPATTERNDSCf17}"
ECHO_LOG "#===> ESF_TRERETFACCTR......................: ${ESF_TRERETFACCTR}"
ECHO_LOG "#===> ESF_SECIFRS_CR_EXTRACT................: ${ESF_SECIFRS_CR_EXTRACT}"
ECHO_LOG "#===> ESF_FRERETFACCTR_TRN_STD .............: ${ESF_FRERETFACCTR_TRN_STD}"
ECHO_LOG "#========================================================================="



## AJOUT Extraction des DATES BOOKING ET NEXT BOOKING :

if  [ "${TYPEINV}" = "INV" ] 
then  
     if [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
     then 
     		PARM_DATE_DEB_D="${PARM_BOOKING_D}"
     		PARM_DATE_FIN_D="${PARM_BOOKINGNEXT_D}"     		
     fi         
fi


if  [ "${TYPEINV}" = "POS" ] 
then  
     if [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
     then 
     		PARM_DATE_DEB_D="${PARM_BOOKING_D}"
     		PARM_DATE_FIN_D="${PARM_PSTOMGEND17_D}"     		
     fi              
fi

##if [ "${TYPEINV}" = "POC" ] 
##then 
## 		if  [ "${NORME_CF}" = "I4I" ] 
## 		then 
## 			PARM_DATE_DEB_D=   "${PARM_PSTOMGEN_D}" 
##     	PARM_DATE_FIN_D=   "${PARM_PSTOMGCONEND_D}"   			
## 		fi
## 		
## 		if  [ "${NORME_CF}" = "EBS" ]
## 		then
##			PARM_DATE_DEB_D=  "${PARM_EBSPSTOMGEND_D}" 
##			PARM_DATE_FIN_D=  "${PARM_EBSPSTOMGCONEND_D}" 			
##		fi	
##			
## 		if  [ "${NORME_CF}" = "I17G" ] || [ "${NORME_CF}" = "I17L" ] || [ "${NORME_CF}" = "I17P" ] || [ "${NORME_CF}" = "I17S" ]
## 		then
##			PARM_DATE_DEB_D=  "${PARM_PSTOMGEND17_D}" 	
##			PARM_DATE_FIN_D=  "${PARM_PSTOMGCONEND17_D}" 													
## 		fi
##fi

ECHO_LOG "#===> PARM_BOOKING_D...........................: ${PARM_BOOKING_D}"
ECHO_LOG "#===> PARM_BOOKINGNEXT_D.......................: ${PARM_BOOKINGNEXT_D}"
ECHO_LOG "#===> PARM_DATE_FIN_D..........................: ${PARM_DATE_FIN_D}"
ECHO_LOG "#===> PARM_DATE_DEB_D..........................: ${PARM_DATE_DEB_D}"
ECHO_LOG "#===> TYPEINV..................................: ${TYPEINV}"


## 


NSTEP=${NJOB}_05
#------------------------------------------------------------------------------
LIBEL="Generation of the file FPATTERNF17 for all type of Pattern"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FSEGPATTERNDSCf17}
BCP_QRY="execute BEST..PsFPATTERNSII_F17_02 '${PARM_CRE_D}', '${PATCAT_CT}', ${PARM_BLCSHTYEA_NF}, '${TYPEINV}', '${PARM_ICLODAT_D}', '${NORME_CF}'"
BCP


NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
LIBEL="Extract RateIndex STD"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=$DFILT/${NSTEP}_${IB}_FRERETFACCTR_STD.dat
BCP_QRY="execute BEST..PsFetchCTRRatInd '${NORME_CF}', '${TYPEINV}'"
BCP

#[008] New Proc PsFetchCTRRatTrnInd FOR TRANSITION

if [ "${PARM_IS_TRN}" == 'YES' ]
then

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
LIBEL="Extract RateIndex For Transition AT STD"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FRERETFACCTR_TRN_STD}
BCP_QRY="execute BEST..PsFetchCTRRatTrnInd '${NORME_CF}', '${PARM_DATE_DEB_D}', '${PARM_DATE_FIN_D}', '${TYPEINV}'"
BCP

fi

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
LIBEL="Generation of the file ESF_FRERETFACCTR_INI for Closing at Inception"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=$DFILT/${NSTEP}_${IB}_FRERETFACCTR_INI.dat
BCP_QRY="execute BEST..PsFetchCTRRatIndIni '${NORME_CF}' , '${PARM_CRE_D}', 'DSC', 'LKI', ${PARM_BLCSHTYEA_NF},'${TYPEINV}', '${PARM_ICLODAT_D}'"
BCP

wc -l $DFILT/${NSTEP}_${IB}_FRERETFACCTR_INI.dat

NSTEP=${NJOB}_23
#------------------------------------------------------------------------------
LIBEL="add illiquidity segment"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_20_${IB}_FRERETFACCTR_INI.dat 2000 1"
SORT_O="$DFILT/${NJOB}_23_${IB}_FRERETFACCTR_INI_ILL.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF         	1:1 - 1:,
	END_NT			2:1 - 2:,
	SEC_NF			3:1 - 3:,
	UWY_NF			4:1 - 4:,
	UW_NT			5:1 - 5:,
	GRPRATEINDEX_CT	6:1 - 6:,
	PARRATEINDEX_CT	7:1 - 7:,
	LOCRATEINDEX_CT	8:1 - 8:,
	CTR_TYPE		9:1 - 9:,
	SSD_CF			10:1 - 10:,
	ESB_CF			11:1 - 11:,
	GRPINISTS_CT	12:1 - 12:,
	PARINISTS_CT	13:1 - 13:,
	LOCINISTS_CT	14:1 - 14:,
	GRPFIRCLO_D 	15:1 - 15:,
	PARFIRCLO_D 	16:1 - 16:,
	LOCFIRCLO_D 	17:1 - 17:,
	GRPIFRSTRA_CT	18:1 - 18:,
	PARIFRSTRA_CT	19:1 - 19:,
	LOCIFRSTRA_CT	20:1 - 20:,
	ALL_FIELDS		1:1 - 20:1,
	NORME_CF        1:1 - 1:1 ,
	ILL_CTR_NF		1:1 - 1:,
	ILL_END_NT		2:1 - 2:,
	ILL_SEC_NF		3:1 - 3:,
	ILL_UWY_NF		4:1 - 4:,
	ILL_UW_NT		5:1 - 5:,
	SGMT_LS			8:1 - 8:
/joinkeys
        CTR_NF,
        SEC_NF,
        UWY_NF,
        END_NT,
        UW_NT
/INFILE $ESF_ILL_BUCKET 2000 1 "~"
/joinkeys
        ILL_CTR_NF,
        ILL_SEC_NF,
        ILL_UWY_NF,
        ILL_END_NT,
        ILL_UW_NT
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_FIELDS,rightside:SGMT_LS
exit
EOF
SORT

NSTEP=${NJOB}_24
#------------------------------------------------------------------------------
LIBEL="INCEPTION rateIndex : Sort by CSUOE"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_23_${IB}_FRERETFACCTR_INI_ILL.dat 2000 1"
SORT_O="$DFILT/${NJOB}_24_${IB}_FRERETFACCTR_INI_ILL_SORTED.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF         	1:1 - 1:,
	END_NT			2:1 - 2:,
	SEC_NF			3:1 - 3:,
	UWY_NF			4:1 - 4:,
	UW_NT			5:1 - 5:
/KEYS
	CTR_NF ,
	END_NT ,
	SEC_NF ,
	UWY_NF ,
	UW_NT
exit
EOF
SORT



NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
LIBEL="IFRS17 req 11.7: select random first CSUOE/index , concat RateIndex+illiquidity segment"
AWK_I=$DFILT/${NJOB}_24_${IB}_FRERETFACCTR_INI_ILL_SORTED.dat
AWK_O=$DFILT/${NJOB}_25_${IB}_FRERETFACCTR_INI.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="~"; OFS="~"; prev_key=""; curr_key=""; norme="$NORME_CF"; }
{

if ( norme == "I17G")
    \$6=\$6\$21;
if ( norme == "I17S")
    \$6=\$6\$21;
if ( norme == "I17P")
    \$7=\$7\$21;
if ( norme == "I17L")
    \$8=\$8\$21;

NF-=1;

if (prev_key == "")
  { prev_key=\$1 \$2 \$3 \$4 \$5;
    print \$0;
  }
  else { curr_key=\$1 \$2 \$3 \$4 \$5;
         if ( curr_key != prev_key )
           { print \$0;
             prev_key = curr_key; }
        }
}
exit
EOF
AWK


NSTEP=${NJOB}_30
#-----------------------------------------------------------------
LIBEL="overwrite ESF_FRERETFACCTR_INI=$ESF_FRERETFACCTR_INI "
EXECKSH "cp -p $DFILT/${NJOB}_25_${IB}_FRERETFACCTR_INI.dat ${ESF_FRERETFACCTR_INI} "

wc -l ${ESF_FRERETFACCTR_INI}


NSTEP=${NJOB}_35
# Extracting data from Table TI17CLOPER
#------------------------------------------------------------------------------
LIBEL="Extracting data from Table TI17CLOPER"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_FI17CLOPER}
if [ "$VSERQS_I17G" = "YES" ]
then
	BCP_QRY="execute BEST..PsTI17CLOPER_SERQ_02 '${NORME_CF}', '${PARM_PSTOMGEND17_D}', '${PARM_REQCOD_CT}', '${PARM_CRE_D}'"
else
	BCP_QRY="execute BEST..PsTI17CLOPER_02 '${NORME_CF}', '${PARM_PSTOMGEND17_D}', '${PARM_REQCOD_CT}', '${PARM_CRE_D}'"
fi 

BCP

if [ "${PARM_POSX}" = "_POSX" ] 
then 

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
LIBEL="filter extended ESB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FRERETFACCTR_INI} 2000 1"
SORT_O="$DFILT/${NSTEP}_${IB}_FRERETFACCTR_STD.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF			10:1 - 10:,
	ESB_CF			11:1 - 11:,
	ALL_FIELDS      1:1  - 20:1,
	CLOPER_SSD_CF   1:1  - 1:,
	CLOPER_ESB_CF   2:1  - 2:
	
/INFILE $DFILT/${NJOB}_10_${IB}_FRERETFACCTR_STD.dat 2000 1 "~"
/joinkeys
        SSD_CF,
        ESB_CF
		
/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
/joinkeys
        CLOPER_SSD_CF,
        CLOPER_ESB_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_FIELDS
exit
EOF
SORT

NSTEP=${NJOB}_45
#------------------------------------------------------------------------------
LIBEL="Sort $ESF_TRERETFACCTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="$DFILT/${NJOB}_40_${IB}_FRERETFACCTR_STD.dat 1000 1"
SORT_O="${ESF_TRERETFACCTR} overwrite"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        CTR_NF      1:1     -  1:,
        END_NT      2:1     -  2:,
        SEC_NF      3:1     -  3:,
        UWY_NF      4:1     -  4:,
        UW_NT       5:1     -  5:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT


else

NSTEP=${NJOB}_50
#------------------------------------------------------------------------------
LIBEL="Merge INI+STD RateIndex into $ESF_TRERETFACCTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FRERETFACCTR_INI} 1000 1"
SORT_I2="$DFILT/${NJOB}_10_${IB}_FRERETFACCTR_STD.dat 1000 1"
SORT_O="${ESF_TRERETFACCTR} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        CTR_NF      1:1     -  1:,
        END_NT      2:1     -  2:,
        SEC_NF      3:1     -  3:,
        UWY_NF      4:1     -  4:,
        UW_NT       5:1     -  5:
		
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
exit
EOF
SORT

fi

NSTEP=${NJOB}_55
# Extracting TCR and TSECIFRS data from BFAC and BTRT for standard perimeter by norm
#------------------------------------------------------------------------------
LIBEL="Extracting TCR and TSECIFRS data from BFAC and BTRT for standard perimeter by norm"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_SECIFRS_CR_EXTRACT}
BCP_QRY="execute BEST..PsSECIFRS_CR_01 '${NORME_CF}'"
BCP



JOBEND
