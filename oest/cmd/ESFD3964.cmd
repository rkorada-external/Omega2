#!/bin/ksh
#=============================================================================
# nom de l'application     : ESTIMATIONS - checks SAP return files
# nom du script SHELL      : ESFD3964.cmd
# date de creation         : 12/04/2023
# auteur                   : JYP
#-----------------------------------------------------------------------------
# historiques des modifications :
#===============================================================================
#[001] 06/04/2023 JYP/TD :spira:109178 SAP checks return files
#[002] 23/05/2023 JYP/TD :spira:109816 add parameters ${BALSHTYEA_NF}  ${BALSHTMTH_NF} for ESFD3964 
#[003] 18/09/2023 JYP    :spira:110487 : remove retro warnings into ESDC0010 mail
#[004] 24/04/2024 JYP    :spira 111359 : manage SIMU IFRS4 and EBS, do not block the closing
#[005] 05/08/2024 JYP    :spira 112004 : bugfix manage SIMU IFRS4 and EBS, do not block the closing
#[006] 20/08/2024 JYP    :spira 112007 : activate check for 27-11
#-----------------------------------------------------------------------------

# Call generic functions
. ${DUTI}/fctgen.cmd

FLAG_RETRO_SIGN=$1
FLAG_ERR_WARN=$2
BALSHTYEA=$3
GAAP_PRD_RULE=$5
if [ "${NORME_CF}" = "I4I" ]
then 
	BALSHTMTH=`echo "$4" | awk '{ if (length($0) < 2) print "0" $0; else print $0;}'`
else
	BALSHTMTH=$4
fi 

# Job Initialisation
JOBINIT


#--- keys to check amounts 
if [ "$GAAP_PRD_RULE" = "Y" ]
then
  GAAP_PRD_KEYS=",GAAPCOD_NF, I17PRDCOD_CT"
else 
  GAAP_PRD_KEYS=""
fi 



ECHO_LOG "#========================================================================="
ECHO_LOG "-> CRE_D ......................: ${PARM_CRE_D}"
ECHO_LOG "-> INVCONSO_D .................: ${PARM_INVCONSO_D}"
ECHO_LOG "-> BALSHTYEA ..................: ${BALSHTYEA}"
ECHO_LOG "-> BALSHTMTH ..................: ${BALSHTMTH}"
ECHO_LOG "-> GAAP_PRD_RULE ..............: ${GAAP_PRD_RULE}"
ECHO_LOG "-> ESF_FTECLEDA_MVT_TMP .......: ${ESF_FTECLEDA_MVT_TMP}"
ECHO_LOG "-> ESF_FTECLEDA_MVT_PREV ......: ${ESF_FTECLEDA_MVT_PREV}"
ECHO_LOG "-> FLAG_RETRO_SIGN ............: ${FLAG_RETRO_SIGN}"
ECHO_LOG "-> FLAG_ERR_WARN ..............: ${FLAG_ERR_WARN}"
ECHO_LOG "-> GAAP_PRD_KEYS ..............: ${GAAP_PRD_KEYS}"
ECHO_LOG "-> SAP Interface (0=NO/1=YES)..: ${ENV_SAP}"
ECHO_LOG "-> SAP MODE (4=SIMU/1=COMPTA)..: ${MODE}"
ECHO_LOG "#========================================================================="



NSTEP=${NJOB}_03
#-----------------------------------------------------------------
LIBEL="initialize file ESF_SAP_RETURN_CHECKS=${ESF_SAP_RETURN_CHECKS}"
EXECKSH_MODE=P
EXECKSH "> $ESF_SAP_RETURN_CHECKS "

wc -l $ESF_FTECLEDA_MVT_TMP    >> $FLOG
wc -l $ESF_FTECLEDA_MVT_PREV   >> $FLOG


#[010] debut des controles
NSTEP=${NJOB}_31
#------------------------------------------------------------------------------
LIBEL="Somme de controle des montants : FTECLEDA avant OneGL"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_MVT_PREV} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESFDMVT.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF

/FIELDS
	SSD_CF           1:1 -   1:EN,
	ESB_CF           2:1 -   2:EN,
	AN               3:1 -   3:EN,
	MOIS             4:1 -   4:EN,
	JOUR             5:1 -   5:EN,
	TRNCOD_CF        6:1 -   6:,
	TRNCOD1_CF       6:1 -   6:1,
	TRNCOD2_CF       6:3 -   6:4,
	CTR_NF           8:1 -   8:,
	SEC_NF          10:1 -  10:EN,
	UWY_NF          11:1 -  11:EN,
	AMT_M           19:1 -  19:EN 18/3,
	RETCTR_NF       24:1 -  24:,
	RTY_NF          27:1 -  27:,
	CUR_CF          34:1 -  34:,
	RETAMT_M        35:1 -  35:EN 18/3,
	RETINTAMT_M     88:1 -  88:EN 18/3,
	KEY_CF         101:1 - 101:,
	GAAPCOD_NF      111:1 - 111:,
	I17PRDCOD_CT	112:1 - 112:	
/KEYS	SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF $GAAP_PRD_KEYS
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF $GAAP_PRD_KEYS ,AMT_MC,RETAMT_MC,RETINTAMT_MC
exit
EOF
SORT

NSTEP=${NJOB}_32
#------------------------------------------------------------------------------
LIBEL="Somme de controle des montants : FTECLEDA apres Onegl"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_MVT_TMP} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_OTGLMVT.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF           1:1 -   1:EN,
	ESB_CF           2:1 -   2:EN,
	AN               3:1 -   3:EN,
	MOIS             4:1 -   4:EN,
	JOUR             5:1 -   5:EN,
	TRNCOD_CF        6:1 -   6:,
	TRNCOD1_CF       6:1 -   6:1,
	TRNCOD2_CF       6:3 -   6:4,
	CTR_NF           8:1 -   8:,
	SEC_NF          10:1 -  10:EN,
	UWY_NF          11:1 -  11:EN,
	AMT_M           19:1 -  19:EN 18/3,
	RETCTR_NF       24:1 -  24:,
	RTY_NF          27:1 -  27:,
	CUR_CF          34:1 -  34:,
	RETAMT_M        35:1 -  35:EN 18/3,
	RETINTAMT_M     88:1 -  88:EN 18/3,
	KEY_CF         101:1 - 101:,
	GAAPCOD_NF      111:1 - 111:,
    I17PRDCOD_CT    112:1 - 112:
	
/KEYS	SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF $GAAP_PRD_KEYS
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF $GAAP_PRD_KEYS ,AMT_MC,RETAMT_MC,RETINTAMT_MC
exit
EOF
SORT

NSTEP=${NJOB}_33
# Inverse montants pour compare
#-----------------------------------------------------------------------------
LIBEL="Inverse montants pour compare GAAP_PRD_RULE=$GAAP_PRD_RULE "
AWK_I=${DFILT}/${NJOB}_32_${IB}_OTGLMVT.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_OTGLMVT.dat
AWK_PARAM=" -v GAAP_PRD_RULE=$GAAP_PRD_RULE "
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{
		    if ( GAAP_PRD_RULE == "Y" ) 
			{
			if (\$11  != 0) \$11   = sprintf("%-.3lf",-\$11 );
			if (\$12  != 0) \$12  = sprintf("%-.3lf",-\$12);
			if (\$13  != 0) \$13  = sprintf("%-.3lf",-\$13);
			}
			else 
			{
			if (\$9  != 0) \$9   = sprintf("%-.3lf",-\$9 );
			if (\$10  != 0) \$10  = sprintf("%-.3lf",-\$10);
			if (\$11  != 0) \$11  = sprintf("%-.3lf",-\$11);			
			}
			print \$0;
		}
exit
EOF
AWK
 

NSTEP=${NJOB}_34
#------------------------------------------------------------------------------
LIBEL="Somme de controle des montants : GAAP_PRD_RULE=$GAAP_PRD_RULE "
if [ "$GAAP_PRD_RULE" = "Y" ]
then 
  LAST_FIELDS="	GAAPCOD_NF       9:1 -   9:,\
    I17PRDCOD_CT    10:1 -  10:,\
	AMT_M           11:1 -  11:EN 18/3,\
	RETAMT_M        12:1 -  12:EN 18/3,\
	RETINTAMT_M     13:1 -  13:EN 18/3 "
else 
  LAST_FIELDS="	AMT_M           9:1 -  9:EN 18/3,\
	RETAMT_M        10:1 -  10:EN 18/3,\
	RETINTAMT_M     11:1 -  11:EN 18/3 "
fi
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_31_${IB}_ESFDMVT.dat 2000 1"
SORT_I2="${DFILT}/${NJOB}_33_${IB}_AWK_OTGLMVT.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CUMMVT.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF           1:1 -   1:EN,
	AN               2:1 -   2:EN,
	MOIS             3:1 -   3:EN,
	CTR_NF           4:1 -   4:,
	UWY_NF           5:1 -   5:EN,
	SEC_NF           6:1 -   6:EN,
	TRNCOD_CF        7:1 -   7:,
	RETCTR_NF        8:1 -   8:,
$LAST_FIELDS
/KEYS	SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF $GAAP_PRD_KEYS
/SUMMARIZE  TOTAL AMT_M, TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD AMT_MC AMT_M COMPRESS
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,AN,MOIS,CTR_NF,UWY_NF,SEC_NF,TRNCOD_CF,RETCTR_NF $GAAP_PRD_KEYS ,AMT_MC,RETAMT_MC,RETINTAMT_MC

exit
EOF
SORT


NSTEP=${NJOB}_35
# Liste differences sur montants
#-----------------------------------------------------------------------------
LIBEL="Liste differences sur montants : GAAP_PRD_RULE=$GAAP_PRD_RULE "
AWK_I=${DFILT}/${NJOB}_34_${IB}_SORT_CUMMVT.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DIFFMVT_MONTANTS.log
AWK_PARAM=" -v GAAP_PRD_RULE=$GAAP_PRD_RULE "
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{
	  if ( GAAP_PRD_RULE == "Y" ) 
	  {
			if ( \$11 > 1 || \$11 < -1 || \$12 > 1 || \$12 < -1 || \$13 > 1 || \$13 < -1) print \$0;
	  }
	  else 
	  {
			if ( \$9 > 1 || \$9 < -1 || \$10 > 1 || \$10 < -1 || \$11 > 1 || \$11 < -1) print \$0;	  
	  }
	}
exit
EOF
AWK


NSTEP=${NJOB}_36
# Liste differences sur signe montant retro
#-----------------------------------------------------------------------------
LIBEL="Liste differences sur signe montant retro"
AWK_I=${ESF_FTECLEDA_MVT_TMP}
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
	{
		if (((\$88 < 0 && \$35 > 0) || (\$88 > 0 && \$35 < 0)) && \$88 != "" && \$88 != 0) print \$0;
	}
exit
EOF
AWK


NSTEP=${NJOB}_37
# Controle Contrats Europe et identifiant
#-----------------------------------------------------------------------------
LIBEL="Liste mouvements sans identifiants : an=${BALSHTYEA} mois=${BALSHTMTH} "
AWK_I=${ESF_FTECLEDA_MVT_TMP}
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DIFFMVT_IDENTIFIANT.log
AWK_PARAM=" -v an=${BALSHTYEA} -v mois=${BALSHTMTH} "
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{
			if ( ! ((\$24 == "17P000028" || \$24 == "17P000037" || \$24 == "17P000038" || \$24 == "17P000039" || \$24 == "17P000052" || \$24 == "17P000055" ||
			         \$24 == "17P000056" || \$24 == "17P000058" || \$24 == "17P000059" || \$24 == "17P000060" || \$8  == "17ZF35062" || \$8  == "17ZF41634" ||
			         \$8  == "17ZF41638" || \$8  == "17ZF41639" || \$8  == "17ZF41640" || \$8  == "17ZF41641" || \$8  == "17ZF41644" || \$8  == "17ZF41645" ||
			         \$8  == "17ZF41646" || \$8  == "17ZF41647" || \$8  == "17ZF41653" || \$8  == "17ZF41654" || \$8  == "17ZF41787" || \$8  == "17ZF47945" ||
			         \$8  == "17ZF47946") ||
			        (substr(\$6,8,1)  == "C" || substr(\$6,8,1)  == "E") ||
			        (\$1 ==  5 && \$2 == 10) || 
			        (\$1 == 16 && \$2 == 1 ) || 
			        (\$1 == 19 && \$2 == 2 ) ||
			        (\$1 == 14 && \$2 == 1 ) ||
			        (\$1 == 14 && \$2 == 10) ||
			        (\$1 == 14 && \$2 == 11) ||
			        (\$1 == 14 && \$2 == 12) ||
			        (\$1 == 14 && \$2 == 13) ||
			        (\$1 == 14 && \$2 == 3 ) ||
			        (\$1 == 14 && \$2 == 4 ) ||
			        (\$1 == 14 && \$2 == 5 ) ||
			        (\$1 == 14 && \$2 == 6 ) ||
			        (\$1 == 14 && \$2 == 7 ) ||
			        (\$1 == 14 && \$2 == 8 ) ||
			        (\$1 == 14 && \$2 == 9 ) ||
			        (\$1 == 25 && \$2 == 1 ) ||
			        (\$1 == 10 && \$2 == 12 ) ||
			        (\$1 == 10 && \$2 == 15 ) ||
			        (\$1 == 10 && \$2 == 1 ) ||
			        (\$1 == 10 && \$2 == 7 ) ||
			        (\$1 == 10 && \$2 == 8 ) ||
			        (\$1 == 11 && \$2 == 1 ) ||
			        (\$1 == 4  && \$2 == 11 ) ||
			        (\$1 == 6  && \$2 == 1 ) ||
					(\$1 == 17 && \$2 == 3 ) ||
			        (\$1 == 2  && \$2 == 4 ) ||					
			        (\$1 == 26 ) ||					
			        (\$1 == 27 && \$2 != 11 ) || 
			        (\$6 == \$7 ) ) )
			{
				if (\$102 == "" && (\$19 > 1 || \$19 < -1) && (\$35 > 1 || \$35 < -1) && \$3 == an && \$4 == mois)
					print \$0;
			}
		}
exit
EOF
AWK


if [ -s ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log ] ||
   [ -s ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log -a "$FLAG_RETRO_SIGN" = "Y" ] ||   
   [ -s ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log ]
then
	
	ECHO_LOG "#==========================================================================="
	ECHO_LOG "#===> Erreurs rencontr�es dans le controle du Fichier MVT provenant de ONEGL"
	ECHO_LOG "#===> Arret ou Warning."
	ECHO_LOG "#==========================================================================="
	wc -l ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log
	wc -l ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log
	wc -l ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log


	ECHO_LOG "complete ESF_SAP_RETURN_CHECKS files for reporting ESDC0010 "		
    wc -l ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log            >> $ESF_SAP_RETURN_CHECKS
	cat ${DFILT}/${NJOB}_35_${IB}_AWK_DIFFMVT_MONTANTS.log              >> $ESF_SAP_RETURN_CHECKS
    #wc -l ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log   >> $ESF_SAP_RETURN_CHECKS
	#cat ${DFILT}/${NJOB}_36_${IB}_AWK_DIFFMVT_MONTANTRETROSIGNE.log     >> $ESF_SAP_RETURN_CHECKS
    wc -l ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log	        >> $ESF_SAP_RETURN_CHECKS
	cat ${DFILT}/${NJOB}_37_${IB}_AWK_DIFFMVT_IDENTIFIANT.log	        >> $ESF_SAP_RETURN_CHECKS
		
	
	if [ "${FLAG_ERR_WARN}" = "E" ]
	then
		ECHO_LOG "#==========================================================================="
		ECHO_LOG "# DELTA BOOKING call, we should stop all "
		ECHO_LOG "#==========================================================================="
		STEPEND 1
	else
		echo "WARNING" > ${DFILT}/${NSTEP}_${IB}_CTLONEGL.wng
		ECHO_LOG "WARNING , check file $ESF_SAP_RETURN_CHECKS " 
	fi

fi	



NSTEP=${NJOB}_130
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND

