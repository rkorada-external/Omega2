#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD5032.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 28\09\2022
# auteur                        : Florian CULIOLI
#---------------------------------------------------------------------------------
# description
# Onerous Q+1
#  Generation of a row a pericase INI INV/POS
#
#---------------------------------------------------------------------------------
#=================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ECHO_LOG "#========================================================================="
ECHO_LOG "#====================================INPUT PARAMETERS====================="
ECHO_LOG "#===> PARM_ICLODAT_D.....................................................: ${PARM_ICLODAT_D}"
ECHO_LOG "#===> NORME_CF...........................................................: ${NORME_CF}"
ECHO_LOG "#===> TYPEINV............................................................: ${TYPEINV}"
ECHO_LOG "#===> X_DAYS.............................................................: ${X_DAYS}"
ECHO_LOG "#===> PARM_CRE_D.........................................................: ${PARM_CRE_D}"
ECHO_LOG "#===> ICLODAT_MTH........................................................: ${ICLODAT_MTH}"
ECHO_LOG "#===> PARM_SEGTYP_CT.....................................................: ${PARM_SEGTYP_CT}"
ECHO_LOG "#===> PARM_DBCLO_D.......................................................: ${PARM_DBCLO_D}"
ECHO_LOG "#===> PARM_BALSHTYEA_NF..................................................: ${PARM_BALSHTYEA_NF}"
ECHO_LOG "#===> QUARTER_END_FOUND..................................................: ${QUARTER_END_FOUND}"
ECHO_LOG "#===> PARM_IS_TRN........................................................: ${PARM_IS_TRN}"
ECHO_LOG "#====================================INPUT FILE=========================="
ECHO_LOG "#===> EST_IADPERICASE0_INI...............................................: ${EST_IADPERICASE0_INI}"
ECHO_LOG "#===> EST_FCURQUOT.......................................................: ${EST_FCURQUOT}"
ECHO_LOG "#====================================OUTPUT FILE=========================="
ECHO_LOG "#===> ESF_FCES...........................................................: ${ESF_FCES}"
ECHO_LOG "#===> ESF_IADPERIFCI.....................................................: ${ESF_IADPERIFCI}"
ECHO_LOG "#===> ESF_IADPERIFCT.....................................................: ${ESF_IADPERIFCT}"
ECHO_LOG "#===> ESF_IADPERIFR......................................................: ${ESF_IADPERIFR}"
ECHO_LOG "#========================================================================="

# comments to delete
#Step 40 1 ligne >> Step 140 >> ESF_IADPERIFCI
#Step 45 0 ligne >> Step 145 >> ESF_IADPERIFCT
#Step 50 0 ligne >> Step 150 >> ESF_IADPERIFR
#Step 80             >> Step 90 >> Step 95 >> ESF_FCES >> Step 165                          
#Step 05 0 lignes  >> Step 85  >> Step 90 >> Step 95 >> ESF_FCES >> Step 165

NSTEP=${NJOB}_05
#Call PsCESSIONI17_02
#-----------------------------------------------------------------------------
LIBEL="PsCESSIONI17_02"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FCESSION0.dat
BCP_QRY="execute BEST..PsCESSIONI17_02 '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP



NSTEP=${NJOB}_40
#Call PsSECTIONI17_08
#-----------------------------------------------------------------------------
LIBEL="PsSECTIONI17_08"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_IADPERIFCI0.dat
BCP_QRY="execute BEST..PsSECTIONI17_08  '${PARM_SEGTYP_CT}', '${PARM_CRE_D}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP

NSTEP=${NJOB}_45
#Call PsSECTIONI17_09
#-----------------------------------------------------------------------------
LIBEL="PsSECTIONI17_09"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_IADPERIFCT0.dat
BCP_QRY="execute BEST..PsSECTIONI17_09  '${PARM_SEGTYP_CT}', '${PARM_DBCLO_D}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}' with recompile"
BCP

NSTEP=${NJOB}_50
#Call PsSECTIONI17_11
#-----------------------------------------------------------------------------
LIBEL="PsSECTIONI17_11"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_IADPERIFR0.dat
BCP_QRY="execute BEST..PsSECTIONI17_11  '${PARM_SEGTYP_CT}', '${PARM_CRE_D}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}'"
BCP



NSTEP=${NJOB}_80
#-----------------------------------------------------------------------------
LIBEL="Convertion of  ${EST_IADPERICASE0_INI} into PERICASE by region "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0_INI} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
		CTR_NF 3:1 - 3:,
		      END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_85
#-----------------------------------------------------------------------------
LIBEL="Convertion of  ${ESF_FCESSION0} into FCESSION file by region"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_FCESSION0.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FCESSION.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT  5:1 - 5:,
		SSD_CF 14:1 - 14: EN
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      UW_NT
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_90
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new cession file"
PRG=ESTC2301
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_IADPERICASE.dat
export ${PRG}_I2=${DFILT}/${NJOB}_85_${IB}_FCESSION.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FCES_NEW.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETNP_SEGMENT_NOT_USE.dat
EXECPRG

NSTEP=${NJOB}_95
#-----------------------------------------------------------------------------
LIBEL="Sorting new cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_90_${IB}_ESTC2301_FCES_NEW.dat
SORT_O="${ESF_FCES} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF    1:1 - 1:,
        END_NT    2:1 - 2: ,
        SEC_NF    3:1 - 3: ,
        UWY_NF    4:1 - 4: ,
        UW_NT     5:1 - 5: ,
        RETCTR_NF 6:1 - 6:,
        RETEND_NT 7:1 - 7: ,
        RETSEC_NF 8:1 - 8: ,
        RTY_NF    9:1 - 9: ,
        RETUW_NT  10:1 - 10:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION RETRO RETCTR_NF EQ ""
/OMIT RETRO
exit
EOF
SORT


NSTEP=${NJOB}_140
#-----------------------------------------------------------------------------
LIBEL="Sorting of XADPERIFCI Perimeter File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_BCP_IADPERIFCI0.dat 1000 1"
SORT_O="${ESF_IADPERIFCI} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
		END_NT 2:1 - 2:,
		SEC_NF 3:1 - 3:,
		UWY_NF 4:1 - 4:,
		UW_NT  5:1 - 5:,
		SSD_CF 14:1 - 14: EN
/KEYS 	CTR_NF,
		END_NT,
		SEC_NF,
		UWY_NF,
		UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_145
#-----------------------------------------------------------------------------
LIBEL="SORTING of XADPERIFCT Perimeter File "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_45_${IB}_BCP_IADPERIFCT0.dat
SORT_O="${ESF_IADPERIFCT} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: EN,
        SEC_NF 3:1 - 3: EN,
        UWY_NF 4:1 - 4: EN,
        UW_NT  5:1 - 5: EN,
		SSD_CF 7:1 - 7: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_150
#-----------------------------------------------------------------------------
LIBEL="SORTING of IADPERIFR Perimeter File"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_BCP_IADPERIFR0.dat 1000 1"
SORT_O="${ESF_IADPERIFR} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF  1:1 - 1:,
		END_NT  2:1 - 2:,
		SEC_NF  3:1 - 3:,
		UWY_NF  4:1 - 4:,
		UW_NT   5:1 - 5:,
		 SSD_CF 12:1 - 12: EN
/KEYS 	CTR_NF,
		END_NT,
		SEC_NF,
		UWY_NF,
		UW_NT
exit
EOF
SORT 


NSTEP=${NJOB}_165
#-----------------------------------------------------------------------------
LIBEL="Sort of cession file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${ESF_FCES}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FCESANT_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 6:1 - 6:,
		RETEND_NT 7:1 - 7: EN,
		RETSEC_NF 8:1 - 8: EN,
		RTY_NF    9:1 - 9: EN,
		RETUW_NT  10:1 - 10: EN
/KEYS 	RETCTR_NF,
		RETEND_NT,
		RETSEC_NF,
		RTY_NF, 
		RETUW_NT
/SUM
exit
EOF
SORT



JOBEND