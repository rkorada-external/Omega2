#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - CONTROLE DE COHERENCE
#                                 des ecritures de service ( fichier .txt utilisateur )
# nom du script SHELL           : ESID0801.cmd
# revision                      : $Revision:   1.5  $
# date de creation              : 22/10/97
# auteur                        : C.G.I. (M.HA-THUC)
# references des specifications :
#-----------------------------------------------------------------------------
# description
#   Conformity control of special entries
#
# Job launched by ESID0800.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
# 26/04/05  M.DJELLOULI : SPOT 5084 - MOD03 
#                                    Ajout de la Zone SPEENTTYP_CF
#                                    Modification du STEP 12
# 27/04/05  M.DJELLOULI : SPOT 11445 - STEP 35
#                                                      EST_ESID0801_TESTUTISUP remplace TESTUTISUP
#                                    Modification du STEP 05
#                                    Modification du STEP 10
#                                    Modification du STEP 25
# 24/06/05  M.DJELLOULI : SPOT 5085
#                                    Ajout de la Zone SPEENTNAT_CT de TACCSUP
#                                    Modification du STEP 12
# 23/02/15  Sonal Bhombe : :spot:28328  R. cassis
#                                    Modification at STEP 12-Added EVT_NF,REVT_NF fields
#                                    Modification at STEP 20
# 22/07/15  Kbagwe:		defect 38110 -Load AE file - Life entries on non life treaty
#						modifed input parameter $3 and $4
#------------------------------------------------------------------------------------------
#   24/01/2017   JFVDV        : [31752] -  Ajout Test sur fichier d'anomalies
#[007] 23/08/2017 R. Cassis :spira:56031 Ajout sauvegarde du fichier utilisateur
#[008] 06/03/2018 R. Cassis :spira:67627 Suffixe du fichier gzip en .gz
#[009] 30/08/2018 R. Cassis :spira:69063 Gere les montants avec plus de 3 decimales
#[010] 28/02/2023 M. NAJI :spira:67739 File upload : Secure AE Up Load
#[011] 6/02/2023  M.NAJI : spira 108028 refonte de la proc PiACCSUP_02 vers PiACCSUP_04
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

#Recupere arguments d'entree
SSD_CF=$3
USR_CF=$4
LNCH_DATE_TIME="$5 $6"
 

#TP = st if you want to have extended log trace
#export TP=st

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Delete of old special entries"
ISQL_BASE="BTRAV"
ISQL_QRY="delete BTRAV..EST_ESID0801_TESTUTISUP
          where SSD_CF=${SSD_CF} and LSTUPDUSR_CF = '${USR_CF}'
		  UPDATE BEST..TLOADEST SET STATUS_CF = 1 WHERE FILENO_NT = (SELECT  MAX(FILENO_NT)
																	FROM BEST..TLOADEST 
																	WHERE FILETYPE_NT = 5 
																	AND SSD_CF = $SSD_CF 
																	AND ESB_CF = 0  
																	AND CREUSR_CF = '$USR_CF' )
	"		  
ISQL

NSTEP=${NJOB}_07
#Exec Ksh to Rename the IBNR file
#-----------------------------------------------------------------------------
if test -s ${DIBNR}/${PCH}ESID0801_${SSD_CF}_${USR_CF}*.dat
then
  LIBEL=" Exec Ksh to Rename the IBNR file "
  dos2unix ${DIBNR}/${PCH}ESID0801_${SSD_CF}_${USR_CF}.dat
  EXECKSH " mv "${DIBNR}/${PCH}ESID0801_${SSD_CF}_${USR_CF}.dat"
                                      ${DFILT}/${NSTEP}_${IB}_ESID0801_${SSD_CF}_${USR_CF}.dat"
  gzip -c ${DFILT}/${NSTEP}_${IB}_ESID0801_${SSD_CF}_${USR_CF}.dat > ${DFILT}/${SVG}_${NSTEP}_${IB}_ESID0801_${SSD_CF}_${USR_CF}.dat.gz  #[008] 
fi

NSTEP=${NJOB}_10
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="Selection of the largest TRN_NT from BTRAV..EST_ESID0801_TESTUTISUP"
ISQL_BASE="BTRAV"
ISQL_QRY="select max(TRN_NT) from BTRAV..EST_ESID0801_TESTUTISUP"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_ISQLRES_O.dat
ISQL_RES

#The largest TRN_NT is affected to TRNMAX_NT
TRNMAX_NT=`cat ${ISQL_FRES} | sed -e s/\ //g`

# Init de la var pour le comptage des lignes
NBL_NT=0

#[009]
NSTEP=${NJOB}_11
# Manage amounts with decimales up to 3 digits
#-----------------------------------------------------------------------------
LIBEL="Manage amounts with decimales up to 3 digits"
AWK_I=${DFILT}/${NJOB}_07_${IB}_ESID0801_${SSD_CF}_${USR_CF}.dat
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_${SSD_CF}_${USR_CF}.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
       { if ( \$21 != 0 ) \$21 = sprintf("%.3lf",\$21);
         if ( \$35 != 0 ) \$35 = sprintf("%.3lf",\$35);
            ; print \$0 }
exit
EOF
AWK

#[005]
NSTEP=${NJOB}_12
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="REFORMAT OF ESID0801_SSD_USR file to BTRAV..EST_ESID0801_TESTUTISUP FORMAT" 
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I=${DFILT}/${NJOB}_07_${IB}_ESID0801_${SSD_CF}_${USR_CF}.dat
SORT_I=${DFILT}/${NJOB}_11_${IB}_AWK_${SSD_CF}_${USR_CF}.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_${SSD_CF}_${USR_CF}.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        BALSHEY_NF 2:1 - 2:,
        BALSHRMTH_NF 3:1 - 3:,
        BALSHRDAY_NF 4:1 - 4:,
        VALPERY_NF 5:1 - 5:,
        VALPERMTH_NF 6:1 - 6:,
        TRNCOD_CF 7:1 - 7:,
        RETAUTGEN_B 8:1 - 8:,
        CTR_NF 9:1 - 9:,
        END_NT 10:1 - 10:,
        SEC_NF 11:1 - 11:,
        UWY_NF 12:1 - 12:,
        UW_NT 13:1 - 13:,
        OCCYEA_NF 14:1 - 14:,
        ACY_NF 15:1 - 15:,
        SCOSTRMTH_NF 16:1 - 16:,
        SCOENDMTH_NF 17:1 - 17:,
        CLM_NF 18:1 - 18:,
        EVT_NF 19:1 - 19:,
        CUR_CF 20:1 - 20:,
        AMT_M 21:1 - 21:,
        RETCTR_NF 22:1 - 22:,
        RETEND_NT 23:1 - 23:,
        RETSEC_NF 24:1 - 24:,
        RTY_NF 25:1 - 25:,
        RETUW_NT 26:1 - 26:,
        PLC_NT 27:1 - 27:,
        RETOCCYEA_NF 28:1 - 28:,
        RETACY_NF 29:1 - 29:,
        RETSCOSTRMTH_NF 30:1 - 30:,
        RETSCOENDMTH_NF 31:1 - 31:,
        RCL_NF 32:1 - 32:,
        REVT_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:,
        COMAC_LL 36:1 - 36:,
        SPEENTTYP_CF 37:1 - 37:,
        SPEENTNAT_CT 38:1 - 38:
/DERIVEDFIELD SEPA "~"
/COPY
/OUTFILE ${SORT_O}
   /REFORMAT SEPA,
             SSD_CF,
             SEPA,
             SEPA,
             SEPA,
             BALSHEY_NF,
             BALSHRMTH_NF,
             BALSHRDAY_NF,
             VALPERY_NF,
             VALPERMTH_NF,
             TRNCOD_CF,
             SEPA,
             RETAUTGEN_B,
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
             SEPA,
             SEPA,
             SEPA,
             SEPA,
             RETCTR_NF,
             RETEND_NT,
             RETSEC_NF,
             RTY_NF,
             RETUW_NT,
             PLC_NT,
             RETOCCYEA_NF,
             RETACY_NF,
             RETSCOSTRMTH_NF,
             RETSCOENDMTH_NF,
             RCL_NF,
             RETCUR_CF,
             RETAMT_M,
             SEPA,
             SEPA,
             SEPA,
             SEPA,
             SEPA,
             COMAC_LL,
             SEPA,
             SEPA,
             SEPA,
             SEPA,
             SEPA,
             SPEENTTYP_CF,
             SPEENTNAT_CT,
             EVT_NF,
             REVT_NF

exit
EOF
SORT


NSTEP=${NJOB}_15
# Delete temporary file
#----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_10_${IB}_ISQL_O.dat
RMFIL ${DFILT}/${NJOB}_10_${IB}_ISQLRES_O.dat

NSTEP=${NJOB}_20
# Introduction of TRN_NT and LSTUPDUSR_CF in the Special Entries File
#----------------------------------------------------------------------------
LIBEL="Introduction of TRN_NT and LSTUPDUSR_CF and lines numbers in the Special Entries File"
AWK_I=${DFILT}/${NJOB}_12_${IB}_SORT_${SSD_CF}_${USR_CF}.dat
AWK_PARAM=" TRNMAX=${TRNMAX_NT}  USR=${USR_CF} NBL=${NBL_NT}"
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_SVC_O.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN {
 FS="~"
 OFS="~"
}
{
   TRNMAX=TRNMAX+1;
   NBL=NBL+1;
   \$1=TRNMAX"~"\$1;
   \$52=USR;
   \$53=NBL;

   print \$0;
}
exit
EOF
AWK

NSTEP=${NJOB}_25
#  BCP IN in BTRAV..EST_ESID0801_TESTUTISUP
#------------------------------------------------------------------------------
LIBEL="BCP IN of the special entries file in BTRAV..EST_ESID0801_TESTUTISUP"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_20_${IB}_AWK_SVC_O.dat
BCP_TABLE="BTRAV..EST_ESID0801_TESTUTISUP"
BCP


NSTEP=${NJOB}_35
# Begin isql
#------------------------------------------------------------------------------
LIBEL="Conformity control of special entries"
ISQL_BASE="BEST"
ISQL_QRY="exec PiACCSUP_04 ${SSD_CF}, '${USR_CF}'
			IF  ( select count(*) from BEST..TCTRANO  where SSD_CF=${SSD_CF} and SEGTYP_CT = 'A' and SEG_NF = '${USR_CF}' and NUMLINE_NT != 0 and ANO_CT != 1 ) > 0
				 BEGIN
					UPDATE BEST..TLOADEST 
					SET STATUS_CF = 10 
					WHERE FILENO_NT = (SELECT  MAX(FILENO_NT)
										FROM BEST..TLOADEST 
										WHERE FILETYPE_NT = 5 
										AND SSD_CF = $SSD_CF 
										AND ESB_CF = 0  
										AND CREUSR_CF = '$USR_CF' )	

						UPDATE BEST..TLOADEST
						SET NBANO_NT = (SELECT count (DISTINCT ANO_CT) FROM best..TCTRANO
										WHERE SEGTYP_CT = 'A' AND SSD_CF = $SSD_CF AND SEG_NF = '$USR_CF' )
						WHERE FILENO_NT = (SELECT MAX (FILENO_NT) FROM BEST..TLOADEST
											WHERE     FILETYPE_NT = 5
											AND SSD_CF = $SSD_CF
											AND ESB_CF = 0
											AND CREUSR_CF = '$USR_CF' )

					UPDATE BEST..TLOADEST
					SET NBLINESKO_NT =( SELECT count (DISTINCT NUMLINE_NT)FROM best..TCTRANO
										WHERE SEGTYP_CT = 'A' AND SSD_CF = $SSD_CF AND SEG_NF = '$USR_CF' )
					WHERE FILENO_NT =(	SELECT MAX (FILENO_NT) FROM BEST..TLOADEST
										WHERE     FILETYPE_NT = 5
										AND SSD_CF = $SSD_CF
										AND ESB_CF = 0
										AND CREUSR_CF = '$USR_CF' )

				END				  
			ELSE 

				  UPDATE BEST..TLOADEST 
				  SET STATUS_CF = 2 
				  WHERE FILENO_NT = (SELECT  MAX(FILENO_NT)
									FROM BEST..TLOADEST 
									WHERE FILETYPE_NT = 5 
									AND SSD_CF = $SSD_CF 
									AND ESB_CF = 0  
									AND CREUSR_CF = '$USR_CF' 
									)	
		"
ISQL

#-- [31752] 
NSTEP=${NJOB}_37
# Begin isql
#------------------------------------------------------------------------------
LIBEL="research lines in best..TCTRANO to USR_CF and SSD_CF"
ISQL_BASE="BEST"
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_SELECT_TCTRANO.log 
ISQL_QRY="select count(*) from BEST..TCTRANO 
          where SSD_CF=${SSD_CF} and SEGTYP_CT = 'A' and SEG_NF = '${USR_CF}' and NUMLINE_NT != 0 and ANO_CT != 1"
ISQL_FRES=${DFILT}/${NSTEP}_${IB}_FRES_O1.dat         

ISQL_RES

ERRORLine=`cat ${ISQL_FRES} | cut -d_ -f1| sed -e s/\ //g`
JOB_ID='best05a'

echo 'ERRORLine      = ' ${ERRORLine}
echo 'JOB_ID         = ' ${JOB_ID}
echo 'USR_CF         = ' ${USR_CF}
echo 'SSD_CF         = ' ${SSD_CF}
echo 'LNCH_DATE_TIME = ' ${LNCH_DATE_TIME}
 
# If exists lines into table best..TCTRANO, created a warning message and updated TASKQUEUE.
#----------------------------------------------------------------------------------------------
if [ "${ERRORLine}" != '0' ]  
then
    NSTEP=${NJOB}_38
    # Begin isql
    #------------------------------------------------------------------------------
    LIBEL="UPDATE btec_TTASKQUEUE to USR_CF and SSD_CF"
    ISQL_BASE="BTEC"
    ISQL_QRY="exec sp_upd_tkq_6 '${JOB_ID}','${USR_CF}','${LNCH_DATE_TIME}'	"
    ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_UPDATE_TTASKQUEUE.log 
    ISQL

LOGWRITE 1 '!!!! ERRORS detected in table best..TCTRANO  !!!!'

STEPWARNING 10

fi

NSTEP=${NJOB}_40
# Erase temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
