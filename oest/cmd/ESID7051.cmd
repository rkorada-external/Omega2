#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE - Generation des fichiers CMGT
# nom du script SHELL           : ESID7051.cmd
# revision                      : $Revision: 1.8 $
# date de creation              : 08/03/2011
# auteur                        : P.PEZOUT
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   :spot:21408 - Update estimates
#
# job launched by ESID7050.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
#[001]  14/12/2011  R. CASSIS     :spot:22862 - On ne prend plus IGTA et IGTR en entree mais GTA et GTR et les DLT..
#[002]  06/02/2012  Roger Cassis  :spot:23329 - Archivage des fichiers CMGT..
#[003]  25/06/2012  Roger Cassis  :spot:23802 - On ne prend pas les EBSGTA
#[004]  25/06/2012  Ph Pezout     :spot:24904 - On ne prend pas les EBSGTA (filtre sur "AEJ"
#[005]  19/01/2016  Roger Cassis  :spot:30061 - Agrandissement de la taille des tris partout
#===================================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters
BALSHEYEA=$1
BALSHTMTH=$2

# Job Initialisation
JOBINIT

export BALSHEYEAS=$((${BALSHEYEA}+1))

if [ ${EST_ESID7050_COND1} = "Y" ]
then
#[001]
#[003]
## COMPTABILISATION TRIMESTRIELLE
	NSTEP=${NJOB}_05
	# Begin Sort
	#-----------------------------------------------------------------
	LIBEL="Concatenation of files ${EST_GTA} ${EST_DLTOTGTAA} ${EST_DLTOTGTAR}"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_DLTOTGTAA} 800 1"
	SORT_I2="${EST_DLTOTGTAR} 800 1"
	SORT_I3="${EST_GTA} 800 1"
#	SORT_O=${EST_IGTA}
	SORT_O="${DFILT}/${NSTEP}_${IB}_GTA_O.dat 800 1"
INPUT_TEXT $SORT_CMD << EOF
/FIELDS ORICOD_LS    57:1 - 57:
/CONDITION ANNULEBS  ORICOD_LS != 'EBSGTA'
/OUTFILE ${SORT_O}
/INCLUDE ANNULEBS
exit
EOF
	SORT
	NSTEP=${NJOB}_15
	# Begin Sort
	#-----------------------------------------------------------------
	LIBEL="Concatenation of files ${EST_GTR} ${EST_DLTOTGTR}"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_DLTOTGTR} 800 1"
	SORT_I2="${EST_GTR} 800 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_GTR_O.dat 800 1"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
	SORT

else

	NSTEP=${NJOB}_20
	# Begin sort
	#------------------------------------------------------------------------------
	LIBEL="copy GTA + DLTOTGTA:R ==> DFILT/GTA EST_GTR + DLTOTGTR ==> DFILT/GTR"
	EXECKSH "cp ${EST_GTA} ${DFILT}/${NJOB}_05_${IB}_GTA_O.dat "
	EXECKSH "cp ${EST_GTR} ${DFILT}/${NJOB}_15_${IB}_GTR_O.dat "

fi

if [ ${EST_ESID7050_COND2} = "Y" ]
then
## COMPTABILISATION ANNUELLE
#[001]
	NSTEP=${NJOB}_30
	# Begin Sort
	#-----------------------------------------------------------------
	LIBEL="Concatenation of files ${EST_GTA} ${EST_DLREJGTAA} ${EST_DLREJGTAR}"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_DLREJGTAA} 800 1"
	SORT_I2="${EST_DLREJGTAR} 800 1"
#	SORT_I3="${EST_IGTA}"
	SORT_I3="${DFILT}/${NJOB}_05_${IB}_GTA_O.dat 800 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_GTA_O.dat 800 1"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
	SORT
#[001]	
	NSTEP=${NJOB}_40
	# Begin Sort
	#-----------------------------------------------------------------
	LIBEL="Concatenation of files ${EST_GTR} ${EST_DLREJGTR}"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_DLREJGTR} 800  1"
#	SORT_I2="${EST_IGTR}"
	SORT_I2="${DFILT}/${NJOB}_15_${IB}_GTR_O.dat 800 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_GTR_O.dat 800 1"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF
	SORT

else

	NSTEP=${NJOB}_40
	# Begin Sort
	#-----------------------------------------------------------------
	LIBEL="copy GTA + DLTOTGTA:R ==> DFILT/GTA EST_GTR + DLTOTGTR ==> DFILT/GTR"
	EXECKSH "mv ${DFILT}/${NJOB}_05_${IB}_GTA_O.dat ${DFILT}/${NJOB}_30_${IB}_GTA_O.dat"
	EXECKSH "mv ${DFILT}/${NJOB}_15_${IB}_GTR_O.dat ${DFILT}/${NJOB}_40_${IB}_GTR_O.dat"
	
fi

NSTEP=${NJOB}_60
# Begin sort
#[008] Ajout filiale 22
#[009]
#[001]
#----------------------------------------------------------------------------
LIBEL="Split GTA + CURGTA ==> CMGTAA et CMGTAR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_IGTA} 1000 1"
SORT_I="${DFILT}/${NJOB}_30_${IB}_GTA_O.dat 1000 1"
SORT_O="${EST_CMGTAA} OVERWRITE 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_CMGTAR_O2.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF       1:1 - 1:EN,
        ESB_CF       2:1 - 2:,
        BALSHEY      3:1 - 3: EN,
        BALSHTMTH    4:1 - 4: EN,
        TRNCOD_CF    6:1 - 6:,
        TRNCOD1_CF   6:1 - 6:1,
        TRNCOD2C_CF  6:2 - 6:2,
        TRNCOD3      6:3 - 6:3,
        TRNCOD8_CF   6:8 - 6:8 EN,
        CHAMPS_41    1:1 - 41:1
/CONDITION COND_CMGTAA (   BALSHEY = ${BALSHEYEA} and BALSHTMTH <= ${BALSHTMTH} ) AND ( "AEJ" NC TRNCOD2C_CF ) AND ( TRNCOD1_CF = "1" or TRNCOD1_CF = "3" )
/CONDITION COND_CMGTAR ( ( BALSHEY = ${BALSHEYEA} and BALSHTMTH <= ${BALSHTMTH} ) AND ( "AEJ" NC TRNCOD2C_CF ) AND ( TRNCOD1_CF EQ "4" OR TRNCOD1_CF EQ "2") AND
                         ( SSD_CF EQ 2 OR SSD_CF EQ 4 OR SSD_CF EQ 20 OR SSD_CF EQ 22 ) )
/OUTFILE ${SORT_O}
/INCLUDE COND_CMGTAA
/REFORMAT CHAMPS_41
/OUTFILE ${SORT_O2}
/INCLUDE COND_CMGTAR
/REFORMAT CHAMPS_41
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_70
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Sort of CMGTAR_O"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_SORT_CMGTAR_O2.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CMGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF       1:1 - 1:,
        ESB_CF       2:1 - 2:,
        BALSHEY_NF   3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF    6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7:,
        CTR_NF       8:1 - 8:,
        END_NT       9:1 - 9:,
        SEC_NF      10:1 - 10:,
        UWY_NF      11:1 - 11:,
        UW_NT       12:1 - 12:
/KEYS CTR_NF,
      END_NT,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_80
# Begin C Program
#----------------------------------------------------------------------------
LIBEL="CMGTAR  modifications - Interface Madrid"
PRG=ESTM2563
#export ${PRG}_I1=${EST_IADVPERICASE0}
export ${PRG}_I1=${EST_CADVPERIESB0}
export ${PRG}_I2=${DFILT}/${NJOB}_70_${IB}_SORT_CMGTAR_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTM2563_CMGTAR_O.dat
#export ${PRG}_O1=${EST_CMGTAR}
EXECPRG

NSTEP=${NJOB}_85
#Temporary Files Deletion
LIBEL="Temporary Files Deletion"
#-----------------------------------------------------------------
# RMFIL ${EST_CADVPERIESB0}

NSTEP=${NJOB}_90
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Split GTA + DLTOTGTAR ==> MGTAR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_ESTM2563_CMGTAR_O.dat 1000 1"
SORT_O="${EST_CMGTAR} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
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
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
       	CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19:,
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
        RETAMT_M 35:1 - 35:,
        PLC_NT 36:1 - 36:,
        RTO_NF 37:1 - 37:,
        INT_NF 38:1 - 38:,
        RETPAY_NF 39:1 - 39:,
        RETKEY_CF 40:1 - 40:,
        RETINTAMT_M 41:1 - 41:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF,
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
             RETKEY_CF
exit
EOF
SORT

#[001]
NSTEP=${NJOB}_95
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Split GTR ==> CMGTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
#SORT_I="${EST_IGTR} 1000 1"
SORT_I="${DFILT}/${NJOB}_40_${IB}_GTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CMGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS BALSHEY      3:1 - 3: EN,
        BALSHTMTH    4:1 - 4: EN,
        TRNCOD_CF    6:1 - 6:,
        TRNCOD1_CF   6:1 - 6:1,
        TRNCOD2C_CF  6:2 - 6:2 ,
        TRNCOD8_CF   6:8 - 6:8 EN
/CONDITION AVANT_PERIODE	( BALSHEY = ${BALSHEYEA} and BALSHTMTH <= ${BALSHTMTH}) AND ( "AEJ" NC TRNCOD2C_CF ) 
/OUTFILE ${SORT_O}
/INCLUDE AVANT_PERIODE
/COPY
exit
EOF

SORT

# ajout step debut
NSTEP=${NJOB}_100
# Begin sort
#------------------------------------------------------------------------------
LIBEL="SORT CURGTR "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_95_${IB}_SORT_CMGTR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_CMGTR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF           1:1 -  1:,
        ESB_CF           2:1 -  2:,
        BALSHEY_NF       3:1 -  3:,
        BALSHRMTH_NF     4:1 -  4:,
        BALSHRDAY_NF     5:1 -  5:,
        TRNCOD_CF        6:1 -  6:,
        DBLTRNCOD_CF     7:1 -  7:,
        CTR_NF           8:1 -  8:,
        END_NT           9:1 -  9:,
        SEC_NF          10:1 - 10:,
        UWY_NF          11:1 - 11:,
        UW_NT           12:1 - 12:,
        OCCYEA_NF       13:1 - 13:,
        ACY_NF          14:1 - 14:,
        SCOSTRMTH_NF    15:1 - 15:,
        SCOENDMTH_NF    16:1 - 16:,
        CLM_NF          17:1 - 17:,
        CUR_CF          18:1 - 18:,
        AMT_M           19:1 - 19:,
        CED_NF          20:1 - 20:,
        BRK_NF          21:1 - 21:,
        PAY_NF          22:1 - 22:,
        KEY_NF          23:1 - 23:,
        RETCTR_NF       24:1 - 24:,
        RETEND_NT       25:1 - 25:,
        RETSEC_NF       26:1 - 26:,
        RTY_NF          27:1 - 27:,
        RETUW_NT        28:1 - 28:,
        RETOCCYEA_NF    29:1 - 29:,
        RETACY_NF       30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF          33:1 - 33:,
        RETCUR_CF       34:1 - 34:,
        RETAMT_M        35:1 - 35:,
        PLC_NT          36:1 - 36:,
        RTO_NF          37:1 - 37:,
        INT_NF          38:1 - 38:,
        RETPAY_NF       39:1 - 39:,
        RETKEY_CF       40:1 - 40:,
        RETINTAMT_M     41:1 - 41:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
/REFORMAT SSD_CF, ESB_CF, BALSHEY_NF, BALSHRMTH_NF, BALSHRDAY_NF, TRNCOD_CF, DBLTRNCOD_CF, CTR_NF,
          END_NT, SEC_NF, UWY_NF, UW_NT, OCCYEA_NF, ACY_NF, SCOSTRMTH_NF, SCOENDMTH_NF, CLM_NF, CUR_CF,
          AMT_M, CED_NF, BRK_NF, PAY_NF, KEY_NF, RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF, RETUW_NT, 
          RETOCCYEA_NF, RETACY_NF, RETSCOSTRMTH_NF, RETSCOENDMTH_NF, RCL_NF, RETCUR_CF, RETAMT_M, PLC_NT,
          RTO_NF, INT_NF, RETPAY_NF, RETKEY_CF
exit
EOF
SORT

NSTEP=${NJOB}_105
# Begin sort
#------------------------------------------------------------------------------
LIBEL="copy to People Soft"
EXECKSH "cp ${DFILT}/${NJOB}_100_${IB}_SORT_CMGTR_O.dat  ${EST_CMGTR}"

#[002]
# Extrait noms des fichiers CMGT
ficaa=`echo ${EST_CMGTAA} | awk -v envp="${ENV_PREFIX}_" '{i1 = match($0,envp) ; print substr($0,i1) }'`
ficar=`echo ${EST_CMGTAR} | awk -v envp="${ENV_PREFIX}_" '{i1 = match($0,envp) ; print substr($0,i1) }'`
ficr=`echo ${EST_CMGTR} | awk -v envp="${ENV_PREFIX}_" '{i1 = match($0,envp) ; print substr($0,i1) }'`

#[002]
NSTEP=${NJOB}_110
# ARCHIVAGE
#----------------------------------------------------------------------------
LIBEL="Archive CMGT.. files to DARCH"
EXECKSH_MODE=P
EXECKSH "cp ${EST_CMGTAA} $DARCH"
EXECKSH "cp ${EST_CMGTAR} $DARCH"
EXECKSH "cp ${EST_CMGTR} $DARCH"

NSTEP=${NJOB}_120
LIBEL="Erase gzip CMGT..files before gzipping"
RMFIL "${DARCH}/${ficaa}.gz"
RMFIL "${DARCH}/${ficar}.gz"
RMFIL "${DARCH}/${ficr}.gz"

#[002]
NSTEP=${NJOB}_115
# Zip files
#----------------------------------------------------------------------------
LIBEL="Gzip CMGT.. files to DARCH"
EXECKSH_MODE=P
EXECKSH "gzip ${DARCH}/${ficaa}"
EXECKSH "gzip ${DARCH}/${ficar}"
EXECKSH "gzip ${DARCH}/${ficr}"

########################
# Erase temporary files #
########################

NSTEP=${NJOB}_120
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

JOBEND
