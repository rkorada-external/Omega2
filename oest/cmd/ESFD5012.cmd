#!/bin/ksh
#=============================================================================
# nom de l'application          : EBS
# nom du script SHELL           : ESFD5012.cmd
# revision                      : $Revision:   1.0  $
# date de creation              : 18\05\2021
# auteur                        : Arnaud RUFFAULT
# references des specifications :
#-----------------------------------------------------------------------------
# Description
# If TYPEINV = INV => simply rename an IFRS4/EBS pericase.
#	If TYPEINV = POS => merge of IFRS4/EBS INV pericase with the contracts added during POS period from an IFRS4/EBS POS pericase
#-----------------------------------------------------------------------------
#===============================================================================
#[001] 31/05/2022 R.CASSIS :spira:104409 Gestion de la mise � jour de BEST..TCTRGRO pour EBS/POS
#[002] 08/11/2022 DAD  :spira:107518 Generate IADPERICASE DUMMY STD
#[003] 25/11/2022 MZM  :spira:107518 Generate IADPERICASE DUMMY STD Fix oubli - "_" sur ITK
#[004] 12/06/2023 DAD  :spira:109759 Generate FCESSION1 use for ratio
#[005] 20/02/2025 MZM : spira 112299 Change in comm/tax/reinst prem should have no impact in POS
#[006] 02/03/2026 MZM/Manish US 7046 CUT OFF : Move FCTRGRO FROM ESFD5012 TO ESFD5015
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT


# Get input parameters
ECHO_LOG "#============================================================================"
ECHO_LOG "#===> NORME_CF...............................................................: ${NORME_CF}"
ECHO_LOG "#===> TYPEINV................................................................: ${TYPEINV}"
ECHO_LOG "#===> PARM_TYPEINV2..........................................................: ${PARM_TYPEINV2}"
ECHO_LOG "#===> PARM_SEQ_MODE..........................................................: ${PARM_SEQ_MODE}"

ECHO_LOG "#===> ............ INPUT ...................................................."
ECHO_LOG "#===> EST_IADPERICASE_5010...................................................: ${EST_IADPERICASE_5010}"
ECHO_LOG "#===> EST_IADPERICASE_I4.....................................................: ${EST_IADPERICASE_I4}"
ECHO_LOG "#===> EST_IRDPERICASE0_5010..................................................: ${EST_IRDPERICASE0_5010}"
ECHO_LOG "#===> EST_IRDPERICASE0_I4....................................................: ${EST_IRDPERICASE0_I4}"
ECHO_LOG "#===> EST_IRDVPERICASE_5010..................................................: ${EST_IRDVPERICASE_5010}"
ECHO_LOG "#===> EST_IRDVPERICASE_I4....................................................: ${EST_IRDVPERICASE_I4}"
ECHO_LOG "#===> EST_OIRDVPERICASE_5010.................................................: ${EST_OIRDVPERICASE_5010}"
ECHO_LOG "#===> EST_OIRDVPERICASE_I4...................................................: ${EST_OIRDVPERICASE_I4}"
ECHO_LOG "#===> EST_IADVPERICASE_5010..................................................: ${EST_IADVPERICASE_5010}"
ECHO_LOG "#===> EST_IADVPERICASE_I4....................................................: ${EST_IADVPERICASE_I4}"
ECHO_LOG "#===> EST_CADVPERIESB0_5010..................................................: ${EST_CADVPERIESB0_5010}"
ECHO_LOG "#===> EST_CADVPERIESB0_I4....................................................: ${EST_CADVPERIESB0_I4}"
ECHO_LOG "#===> EST_CRVPERICASE0_5010..................................................: ${EST_CRVPERICASE0_5010}"
ECHO_LOG "#===> EST_CRVPERICASE0_I4....................................................: ${EST_CRVPERICASE0_I4}"
ECHO_LOG "#===> EST_CTRULT02_5010......................................................: ${EST_CTRULT02_5010}"
ECHO_LOG "#===> EST_CTRULT02_I4........................................................: ${EST_CTRULT02_I4}"
ECHO_LOG "#===> EST_FCES_5010..........................................................: ${EST_FCES_5010}"
ECHO_LOG "#===> EST_FCES_I4............................................................: ${EST_FCES_I4}"
##ECHO_LOG "#===> EST_FCTRGRO0_5010......................................................: ${EST_FCTRGRO0_5010}"
##ECHO_LOG "#===> EST_FCTRGRO0_I4........................................................: ${EST_FCTRGRO0_I4}"
##ECHO_LOG "#===> EST_FCTRGRO_5010.......................................................: ${EST_FCTRGRO_5010}"
##ECHO_LOG "#===> EST_FCTRGRO_I4.........................................................: ${EST_FCTRGRO_I4}"
##ECHO_LOG "#===> EST_FCTRGRO1_5010......................................................: ${EST_FCTRGRO1_5010}"
##ECHO_LOG "#===> EST_FCTRGRO1_I4........................................................: ${EST_FCTRGRO1_I4}"
##ECHO_LOG "#===> EST_FCTRGROLESII_5010..................................................: ${EST_FCTRGROLESII_5010}"
##ECHO_LOG "#===> EST_FCTRGROLESII_I4....................................................: ${EST_FCTRGROLESII_I4}"
ECHO_LOG "#===> EST_FCTRULT_5010.......................................................: ${EST_FCTRULT_5010}"
ECHO_LOG "#===> EST_FCTRULT_I4.........................................................: ${EST_FCTRULT_I4}"
ECHO_LOG "#===> EST_FPLACEMT0_5010.....................................................: ${EST_FPLACEMT0_5010}"
ECHO_LOG "#===> EST_FPLACEMT0_I4.......................................................: ${EST_FPLACEMT0_I4}"
ECHO_LOG "#===> EST_FPLACEMT1_5010.....................................................: ${EST_FPLACEMT1_5010}"
ECHO_LOG "#===> EST_FPLACEMT1_I4.......................................................: ${EST_FPLACEMT1_I4}"
ECHO_LOG "#===> EST_FPLACEMT2_5010.....................................................: ${EST_FPLACEMT2_5010}"
ECHO_LOG "#===> EST_FPLACEMT2_I4.......................................................: ${EST_FPLACEMT2_I4}"
ECHO_LOG "#===> EST_FPLATXCUM0_5010....................................................: ${EST_FPLATXCUM0_5010}"
ECHO_LOG "#===> EST_FPLATXCUM0_I4......................................................: ${EST_FPLATXCUM0_I4}"
ECHO_LOG "#===> EST_FPLATXCUM_5010.....................................................: ${EST_FPLATXCUM_5010}"
ECHO_LOG "#===> EST_FPLATXCUM_I4.......................................................: ${EST_FPLATXCUM_I4}"
ECHO_LOG "#===> EST_FPLATXCUMALL0_5010.................................................: ${EST_FPLATXCUMALL0_5010}"
ECHO_LOG "#===> EST_FPLATXCUMALL0_I4...................................................: ${EST_FPLATXCUMALL0_I4}"
ECHO_LOG "#===> EST_FPLC_5010..........................................................: ${EST_FPLC_5010}"
ECHO_LOG "#===> EST_FPLC_I4............................................................: ${EST_FPLC_I4}"
ECHO_LOG "#===> EST_FPLCCOM_5010.......................................................: ${EST_FPLCCOM_5010}"
ECHO_LOG "#===> EST_FPLCCOM_I4.........................................................: ${EST_FPLCCOM_I4}"
ECHO_LOG "#===> EST_FSSDACTR_TXT_5010..................................................: ${EST_FSSDACTR_TXT_5010}"
ECHO_LOG "#===> EST_FSSDACTR_TXT_I4....................................................: ${EST_FSSDACTR_TXT_I4}"
ECHO_LOG "#===> EST_FTVENTNP_5010......................................................: ${EST_FTVENTNP_5010}"
ECHO_LOG "#===> EST_FTVENTNP_I4........................................................: ${EST_FTVENTNP_I4}"
ECHO_LOG "#===> EST_IADPERIFCI_5010....................................................: ${EST_IADPERIFCI_5010}"
ECHO_LOG "#===> EST_IADPERIFCI_I4......................................................: ${EST_IADPERIFCI_I4}"
ECHO_LOG "#===> EST_IADPERIFCT_5010....................................................: ${EST_IADPERIFCT_5010}"
ECHO_LOG "#===> EST_IADPERIFCT_I4......................................................: ${EST_IADPERIFCT_I4}"
ECHO_LOG "#===> EST_IADPERIFR_5010.....................................................: ${EST_IADPERIFR_5010}"
ECHO_LOG "#===> EST_IADPERIFR_I4.......................................................: ${EST_IADPERIFR_I4}"
ECHO_LOG "#===> EST_IADPERICASE_ENTIER0_5010...........................................: ${EST_IADPERICASE_ENTIER0_5010}"
ECHO_LOG "#===> EST_IADPERICASE_ENTIER0_I4.............................................: ${EST_IADPERICASE_ENTIER0_I4}"
ECHO_LOG "#===> EST_IADPERICASE0_5010..................................................: ${EST_IADPERICASE0_5010}"
ECHO_LOG "#===> EST_IADPERICASE0_I4....................................................: ${EST_IADPERICASE0_I4}"
ECHO_LOG "#===> EST_IARVPERICASE0_5010.................................................: ${EST_IARVPERICASE0_5010}"
ECHO_LOG "#===> EST_IARVPERICASE0_I4...................................................: ${EST_IARVPERICASE0_I4}"
ECHO_LOG "#===> EST_FCESSION0_5010.....................................................: ${EST_FCESSION0_5010}"
ECHO_LOG "#===> EST_FCESSION0_I4.......................................................: ${EST_FCESSION0_I4}"
ECHO_LOG "#===> EST_FCESSION1_5010.....................................................: ${EST_FCESSION1_5010}"
ECHO_LOG "#===> EST_FCESSION1_I4.......................................................: ${EST_FCESSION1_I4}"
ECHO_LOG "#===> EST_IADPERICASE_DUMMY_5010.............................................: ${EST_IADPERICASE_DUMMY_5010}"
ECHO_LOG "#===> EST_IADPERICASE_DUMMY_I4...............................................: ${EST_IADPERICASE_DUMMY_I4}"
ECHO_LOG "#===> ............ OUTPUT ..................................................."
ECHO_LOG "#===> EST_IADPERICASE........................................................: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_IADPERICASE_DELTA_POS..............................................: ${EST_IADPERICASE_DELTA_POS}"
ECHO_LOG "#===> EST_IRDPERICASE0.......................................................: ${EST_IRDPERICASE0}"
ECHO_LOG "#===> EST_IRDVPERICASE.......................................................: ${EST_IADPERICASE}"
ECHO_LOG "#===> EST_OIRDVPERICASE......................................................: ${EST_OIRDVPERICASE}"
ECHO_LOG "#===> EST_IADVPERICASE.......................................................: ${EST_IADVPERICASE}"
ECHO_LOG "#===> EST_CADVPERIESB0.......................................................: ${EST_CADVPERIESB0}"
ECHO_LOG "#===> EST_CRVPERICASE0.......................................................: ${EST_CRVPERICASE0}"
ECHO_LOG "#===> EST_CTRULT02...........................................................: ${EST_CTRULT02}"
ECHO_LOG "#===> EST_FCES...............................................................: ${EST_FCES}"
##ECHO_LOG "#===> EST_FCTRGRO0...........................................................: ${EST_FCTRGRO0}"
##ECHO_LOG "#===> EST_FCTRGRO............................................................: ${EST_FCTRGRO}"
##ECHO_LOG "#===> EST_FCTRGRO1...........................................................: ${EST_FCTRGRO1}"
##ECHO_LOG "#===> EST_FCTRGROLESII.......................................................: ${EST_FCTRGROLESII}"
ECHO_LOG "#===> EST_FCTRULT............................................................: ${EST_FCTRULT}"
ECHO_LOG "#===> EST_FPLACEMT0..........................................................: ${EST_FPLACEMT0}"
ECHO_LOG "#===> EST_FPLACEMT1..........................................................: ${EST_FPLACEMT1}"
ECHO_LOG "#===> EST_FPLACEMT2..........................................................: ${EST_FPLACEMT2}"
ECHO_LOG "#===> EST_FPLATXCUM0.........................................................: ${EST_FPLATXCUM0}"
ECHO_LOG "#===> EST_FPLATXCUM..........................................................: ${EST_FPLATXCUM}"
ECHO_LOG "#===> EST_FPLATXCUMALL0......................................................: ${EST_FPLATXCUMALL0}"
ECHO_LOG "#===> EST_FPLC...............................................................: ${EST_FPLC}"
ECHO_LOG "#===> EST_FPLCCOM............................................................: ${EST_FPLCCOM}"
ECHO_LOG "#===> EST_FSSDACTR_TXT.......................................................: ${EST_FSSDACTR_TXT}"
ECHO_LOG "#===> EST_FTVENTNP...........................................................: ${EST_FTVENTNP}"
ECHO_LOG "#===> EST_FVENTNPANT.........................................................: ${EST_FVENTNPANT}"
ECHO_LOG "#===> EST_IADPERIFCI.........................................................: ${EST_IADPERIFCI}"
ECHO_LOG "#===> EST_IADPERIFCT.........................................................: ${EST_IADPERIFCT}"
ECHO_LOG "#===> EST_IADPERIFR..........................................................: ${EST_IADPERIFR}"
ECHO_LOG "#===> EST_IADPERICASE_ENTIER0................................................: ${EST_IADPERICASE_ENTIER0}"
ECHO_LOG "#===> EST_IADPERICASE0.......................................................: ${EST_IADPERICASE0}"
ECHO_LOG "#===> EST_IARVPERICASE0......................................................: ${EST_IARVPERICASE0}"
ECHO_LOG "#===> EST_FCESSION0..........................................................: ${EST_FCESSION0}"
ECHO_LOG "#===> EST_FCESSION1..........................................................: ${EST_FCESSION1}"
ECHO_LOG "#===> EST_IADPERICASE_DUMMY..................................................: ${EST_IADPERICASE_DUMMY}"
ECHO_LOG "#============================================================================"


## [003] AJOUT touch pour creer fichier Vide


if [ ! -f ${EST_IADPERICASE_DUMMY_5010} ]
then
	touch ${EST_IADPERICASE_DUMMY_5010}
fi


if [ ! -f ${EST_IADPERICASE_DUMMY_I4} ]
then
	touch ${EST_IADPERICASE_DUMMY_I4}
fi

#[004]
if [ ! -f ${EST_FCESSION1_5010} ]
then
        touch ${EST_FCESSION1_5010}
fi
#[004]
if [ ! -f ${EST_FCESSION1_I4} ]
then
	touch ${EST_FCESSION1_I4}
fi


#[001] Fait dans ESCJ0662 maintenant
#NSTEP=${NJOB}_05
## GENERATE IADPERICASE DELTA POS 
##------------------------------------------------------------------------------
#LIBEL="GENERATE IADPERICASE DELTA POS"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_IADPERICASE_I4} 2000 1"
#SORT_O="${EST_IADPERICASE_DELTA_POS} 2000 1"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS
#	CTR_NF 					3:1 - 3:,
#	SEC_NF  				4:1 - 4:,
#	UWY_NF 				5:1 - 5:,
#	UW_NT  			6:1 - 6:,
#	END_NT  			7:1 - 7:,
#	FULL_PERICASE				1:1 - 206:
#/joinkeys
#	CTR_NF,
#	SEC_NF,
#	UWY_NF,
#	UW_NT,
#	END_NT
#/INFILE ${EST_IADPERICASE_5010} 1000 1 "~"
#/joinkeys 
#	CTR_NF ,
#	SEC_NF,
#	UWY_NF,
#	UW_NT,
#	END_NT
#/join unpaired leftside only
#/OUTFILE ${SORT_O}
#/REFORMAT 
#	leftside: FULL_PERICASE
#exit
#EOF
#SORT

NSTEP=${NJOB}_07
# Merge EST_IADPERICASE_INV with EST_IADPERICASE_DELTA_POS
#------------------------------------------------------------------------------
LIBEL="Merge EST_IADPERICASE_INV with EST_IADPERICASE_DELTA_POS"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_5010} 2000 1"
SORT_I2="${EST_IADPERICASE_DELTA_POS} 2000 1"
SORT_O="${EST_IADPERICASE} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------
# Merge EST_IRDPERICASE0_5010 with EST_IRDPERICASE0_I4 without duplicate key from EST_IRDPERICASE0_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IRDPERICASE0 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0_5010} 1000 1"
SORT_I2="${EST_IRDPERICASE0_I4} 1000 1"
SORT_O="${EST_IRDPERICASE0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_15
#------------------------------------------------------------------------------
# Merge EST_IRDVPERICASE_INV with EST_PROTO_IRDVPERICASE_POS without duplicate key from EST_IRDVPERICASE_INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IRDVPERICASE when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE_5010} 1000 1"
SORT_I2="${EST_IRDVPERICASE_I4} 1000 1"
SORT_O="${EST_IRDVPERICASE} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_20
#------------------------------------------------------------------------------
# Merge EST_OIRDVPERICASE_INV with EST_PROTO_OIRDVPERICASE_POS without duplicate key from EST_OIRDVPERICASE_INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_OIRDVPERICASE when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_OIRDVPERICASE_5010} 1000 1"
SORT_I2="${EST_OIRDVPERICASE_I4} 1000 1"
SORT_O="${EST_OIRDVPERICASE} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_25
#------------------------------------------------------------------------------
# Merge EST_IADVPERICASE_INV with EST_PROTO_IADVPERICASE_POS without duplicate key from EST_IADVPERICASE_INV
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADVPERICASE when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE_5010} 1000 1"
SORT_I2="${EST_IADVPERICASE_I4} 1000 1"
SORT_O="${EST_IADVPERICASE} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

##NSTEP=${NJOB}_35
###------------------------------------------------------------------------------
### Merge EST_FCTRGROLESII_5010 with EST_FCTRGROLESII_I4 without duplicate key from EST_FCTRGROLESII_5010
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_FCTRGROLESII when TYPEINV=POS and IS_SEQ_MODE=0"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_FCTRGROLESII_5010} 1000 1"
##SORT_I2="${EST_FCTRGROLESII_I4} 1000 1"
##SORT_O="${EST_FCTRGROLESII} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##								END_NT 2:1 - 2:,
##								SEC_NF 3:1 - 3:,
##								UWY_NF 4:1 - 4:,
##        UW_NT 5:1 - 5:
##/KEYS CTR_NF,
##      END_NT,
##						SEC_NF,
##      UWY_NF,
##      UW_NT
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT

NSTEP=${NJOB}_40
#------------------------------------------------------------------------------
# Merge EST_CADVPERIESB0_5010 with EST_CADVPERIESB0_I4 without duplicate key from EST_CADVPERIESB0_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_CADVPERIESB0 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CADVPERIESB0_5010} 1000 1"
SORT_I2="${EST_CADVPERIESB0_I4} 1000 1"
SORT_O="${EST_CADVPERIESB0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
								END_NT 2:1 - 2:,
								UWY_NF 3:1 - 3:,
        UW_NT 4:1 - 4:
/KEYS CTR_NF,
      END_NT,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_60
#------------------------------------------------------------------------------
# Merge EST_CRVPERICASE0_5010 with EST_CRVPERICASE0_I4 without duplicate key from EST_CRVPERICASE0_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_CRVPERICASE0 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CRVPERICASE0_5010} 1000 1"
SORT_I2="${EST_CRVPERICASE0_I4} 1000 1"
SORT_O="${EST_CRVPERICASE0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
								END_NT 4:1 - 4:,
								SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
								UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
						UWY_NF,
						UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_70
#------------------------------------------------------------------------------
# Merge EST_CTRULT02_5010 with EST_CTRULT02_I4 without duplicate key from EST_CTRULT02_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_CTRULT02 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_CTRULT02_5010} 1000 1"
SORT_I2="${EST_CTRULT02_I4} 1000 1"
SORT_O="${EST_CTRULT02} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_75
#------------------------------------------------------------------------------
# Merge EST_FCES_5010 with EST_FCES_I4 without duplicate key from EST_FCES_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCES when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCES_5010} 1000 1"
SORT_I2="${EST_FCES_I4} 1000 1"
SORT_O="${EST_FCES} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
								RETCTR_NF 6:1 - 6:,
        RETEND_NT 7:1 - 7:,
        RETSEC_NF 8:1 - 8:,
        RTY_NF 9:1 - 9:,
        RETUW_NT 10:1 - 10:
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
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

##NSTEP=${NJOB}_80
###------------------------------------------------------------------------------
### Merge EST_FCTRGRO_5010 with EST_FCTRGRO_I4 without duplicate key from EST_FCTRGRO_5010
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_FCTRGRO when TYPEINV=POS and IS_SEQ_MODE=0"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_FCTRGRO_5010} 1000 1"
##SORT_I2="${EST_FCTRGRO_I4} 1000 1"
##SORT_O="${EST_FCTRGRO} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##								END_NT 2:1 - 2:,
##								SEC_NF 3:1 - 3:,
##        UWY_NF 21:1 - 21:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT
##
##NSTEP=${NJOB}_85
###------------------------------------------------------------------------------
### Merge EST_FCTRGRO0_5010 with EST_FCTRGRO0_I4 without duplicate key from EST_FCTRGRO0_5010
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_FCTRGRO0 when TYPEINV=POS and IS_SEQ_MODE=0"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_FCTRGRO0_5010} 1000 1"
##SORT_I2="${EST_FCTRGRO0_I4} 1000 1"
##SORT_O="${EST_FCTRGRO0} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##								END_NT 2:1 - 2:,
##								SEC_NF 3:1 - 3:,
##        UWY_NF 21:1 - 21:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT
##
##NSTEP=${NJOB}_90
###------------------------------------------------------------------------------
### Merge EST_FCTRGRO1_5010 with EST_FCTRGRO1_I4 without duplicate key from EST_FCTRGRO1_5010
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_FCTRGRO1 when TYPEINV=POS and IS_SEQ_MODE=0"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_FCTRGRO1_5010} 1000 1"
##SORT_I2="${EST_FCTRGRO1_I4} 1000 1"
##SORT_O="${EST_FCTRGRO1} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##								END_NT 2:1 - 2:,
##								SEC_NF 3:1 - 3:,
##        UWY_NF 21:1 - 21:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT
##
NSTEP=${NJOB}_100
#------------------------------------------------------------------------------
# Merge EST_FCTRULT_5010 with EST_FCTRULT_I4 without duplicate key from EST_FCTRULT_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCTRULT when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCTRULT_5010} 1000 1"
SORT_I2="${EST_FCTRULT_I4} 1000 1"
SORT_O="${EST_FCTRULT} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
								END_NT 2:1 - 2:,
								SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
								UW_NT	 5:1 - 5:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
						UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_105
#------------------------------------------------------------------------------
# Merge EST_FPLACEMT0_5010 with EST_FPLACEMT0_I4 without duplicate key from EST_FPLACEMT0_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FPLACEMT0 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMT0_5010} 1000 1"
SORT_I2="${EST_FPLACEMT0_I4} 1000 1"
SORT_O="${EST_FPLACEMT0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
								RETEND_NT 4:1 - 4:,
								RETSEC_NF 5:1 - 5:,
        RTY_NF 6:1 - 6:,
								RETUW_NT	 7:1 - 7:,
								PLC_NT	 8:1 - 8:
/KEYS RETCTR_NF,
						RETEND_NT,
						RETSEC_NF,
      RTY_NF,
						RETUW_NT,
						PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_107
#------------------------------------------------------------------------------
# Merge EST_FPLACEMT1_5010 with EST_FPLACEMT1_I4 without duplicate key from EST_FPLACEMT1_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FPLACEMT1 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMT1_5010} 1000 1"
SORT_I2="${EST_FPLACEMT1_I4} 1000 1"
SORT_O="${EST_FPLACEMT1} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
								RETEND_NT 4:1 - 4:,
								RETSEC_NF 5:1 - 5:,
        RTY_NF 6:1 - 6:,
								RETUW_NT	 7:1 - 7:,
								PLC_NT	 8:1 - 8:
/KEYS RETCTR_NF,
						RETEND_NT,
						RETSEC_NF,
      RTY_NF,
						RETUW_NT,
						PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_110
#------------------------------------------------------------------------------
# Merge EST_FPLACEMT2_5010 with EST_FPLACEMT2_I4 without duplicate key from EST_FPLACEMT2_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FPLACEMT2 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMT2_5010} 1000 1"
SORT_I2="${EST_FPLACEMT2_I4} 1000 1"
SORT_O="${EST_FPLACEMT2} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
								UWY_NF 2:1 - 2:,
								PLC_NT 3:1 - 3:
/KEYS CTR_NF,
						UWY_NF,
						PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_115
#------------------------------------------------------------------------------
# Merge EST_FPLATXCUM_5010 with EST_FPLATXCUM_I4 without duplicate key from EST_FPLATXCUM_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FPLATXCUM when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLATXCUM_5010} 1000 1"
SORT_I2="${EST_FPLATXCUM_I4} 1000 1"
SORT_O="${EST_FPLATXCUM} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
								SEC_NF 2:1 - 2:,
								UWY_NF 3:1 - 3:,
								PLC_NT 4:1 - 4:
/KEYS CTR_NF,
						SEC_NF,
						UWY_NF,
						PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_120
#------------------------------------------------------------------------------
# Merge EST_FPLATXCUMALL0_5010 with EST_FPLATXCUMALL0_I4 without duplicate key from EST_FPLATXCUMALL0_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FPLATXCUMALL0 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLATXCUMALL0_5010} 1000 1"
SORT_I2="${EST_FPLATXCUMALL0_I4} 1000 1"
SORT_O="${EST_FPLATXCUMALL0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
								SEC_NF 2:1 - 2:,
								UWY_NF 3:1 - 3:,
								PLC_NT 4:1 - 4:
/KEYS CTR_NF,
						SEC_NF,
						UWY_NF,
						PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_125
#------------------------------------------------------------------------------
# Merge EST_FPLC_5010 with EST_FPLC_I4 without duplicate key from EST_FPLC_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FPLC when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLC_5010} 1000 1"
SORT_I2="${EST_FPLC_I4} 1000 1"
SORT_O="${EST_FPLC} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
								END_NT 4:1 - 4:,
								SEC_NF 5:1 - 5:,
								UWY_NF 6:1 - 6:,
								UW_NT 7:1 - 7:,
								PLC_NT 8:1 - 8:
/KEYS CTR_NF,
						END_NT,
						SEC_NF,
						UWY_NF,
						UW_NT,
						PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_130
#------------------------------------------------------------------------------
# Merge EST_FPLCCOM_5010 with EST_FPLCCOM_I4 without duplicate key from EST_FPLCCOM_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FPLCCOM when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLCCOM_5010} 1000 1"
SORT_I2="${EST_FPLCCOM_I4} 1000 1"
SORT_O="${EST_FPLCCOM} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
								END_NT 4:1 - 4:,
								SEC_NF 5:1 - 5:,
								UWY_NF 6:1 - 6:,
								UW_NT 7:1 - 7:,
								PLC_NT 8:1 - 8:
/KEYS CTR_NF,
						END_NT,
						SEC_NF,
						UWY_NF,
						UW_NT,
						PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_135
#------------------------------------------------------------------------------
# Merge EST_FSSDACTR_TXT_5010 with EST_FSSDACTR_TXT_I4 without duplicate key from EST_FSSDACTR_TXT_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FSSDACTR_TXT when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FSSDACTR_TXT_5010} 1000 1"
SORT_I2="${EST_FSSDACTR_TXT_I4} 1000 1"
SORT_O="${EST_FSSDACTR_TXT} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
								RTY_NT 2:1 - 2:,
								PLC_NT 3:1 - 3:,
        RETSEC_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        CTR_NF 6:1 - 6:,
        UWY_NF 7:1 - 7:,
								SEC_NF 8:1 - 8:,
								END_NT 9:1 - 9:
/KEYS RETCTR_NF,
      RTY_NT,
      PLC_NT,
      RETSEC_NF,
      UW_NT,
						CTR_NF,
						UWY_NF,
						SEC_NF,
						END_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_145
#------------------------------------------------------------------------------
# Merge EST_FTVENTNP_5010 with EST_FTVENTNP_I4 without duplicate key from EST_FTVENTNP_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FTVENTNP when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTVENTNP_5010} 1000 1"
SORT_I2="${EST_FTVENTNP_I4} 1000 1"
SORT_O="${EST_FTVENTNP} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
								RTY_NT 2:1 - 2:,
								RETSEC_NF 3:1 - 3:,
        CTR_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
								END_NT 8:1 - 8:,
								SEC_NF 9:1 - 9:
/KEYS RETCTR_NF,
      RTY_NT,
      RETSEC_NF,
      RETSEC_NF,
      CTR_NF,
						UWY_NF,
						UW_NT,
						END_NT,
						SEC_NF
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_150
#-----------------------------------------------------------------------------
# Copy EST_FTVENTNP into EST_FVENTNPANT
#-----------------------------------------------------------------------------
LIBEL="Copy  EST_FVENTNPANT"
EXECKSH "cp ${EST_FTVENTNP} ${EST_FVENTNPANT}"

#[005]

##NSTEP=${NJOB}_165
###------------------------------------------------------------------------------
### Merge EST_IADPERIFCI_5010 with EST_IADPERIFCI_I4 without duplicate key from EST_IADPERIFCI_5010
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_IADPERIFCI when TYPEINV=POS and IS_SEQ_MODE=0"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_IADPERIFCI_5010} 1000 1"
##SORT_I2="${EST_IADPERIFCI_I4} 1000 1"
##SORT_O="${EST_IADPERIFCI} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##								END_NT 2:1 - 2:,
##								SEC_NF 3:1 - 3:,
##        UWY_NF 4:1 - 4:,
##        UW_NT 5:1 - 5:,
##								CHGLIN_NT 6:1 - 6:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT,
##						CHGLIN_NT
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT


##### ! EST_IADPERIFCI_I4 Fichier Frais Issu du ESCJ0660

NSTEP=${NJOB}_164
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-POS not in pericase INV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFCI_I4} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFCI_POS_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       1:1 - 1:,   
		END_NT       2:1 - 2:,   
		SEC_NF       3:1 - 3:,   
		UWY_NF       4:1 - 4:,   
		UW_NT        5:1 - 5:,   
		STD_CTR_NF   1:1 - 1:,   
		STD_END_NT   2:1 - 2:,   
		STD_SEC_NF   3:1 - 3:,   
		STD_UWY_NF   4:1 - 4:,   
		STD_UW_NT    5:1 - 5:,  
		ALL_COLS     1:1 - 15: 
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EST_IADPERIFCI_5010} 2000 1 "~"
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


#"Generate EST_IADPERIFCI when TYPEINV=POS and IS_SEQ_MODE=0"

NSTEP=${NJOB}_165
#------------------------------------------------------------------------------
LIBEL="Generate EST_IADPERIFCI when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_164_${IB}_SORT_IADPERIFCI_POS_O.dat 2000 1"
SORT_I2="${EST_IADPERIFCI_5010} 2000 1"
SORT_O="${EST_IADPERIFCI} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       1:1 - 1:,   
        		END_NT       2:1 - 2:,   
        		SEC_NF       3:1 - 3:,   
       		  UWY_NF       4:1 - 4:,   
        		UW_NT        5:1 - 5:
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
##NSTEP=${NJOB}_170
###------------------------------------------------------------------------------
### Merge EST_IADPERIFCT_5010 with EST_IADPERIFCT_I4 without duplicate key from EST_IADPERIFCT_5010
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_IADPERIFCT when TYPEINV=POS and IS_SEQ_MODE=0"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_IADPERIFCT_5010} 1000 1"
##SORT_I2="${EST_IADPERIFCT_I4} 1000 1"
##SORT_O="${EST_IADPERIFCT} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##								END_NT 2:1 - 2:,
##								SEC_NF 3:1 - 3:,
##        UWY_NF 4:1 - 4:,
##        UW_NT 5:1 - 5:,
##								TAXLIN_NT 9:1 - 9:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT,
##						TAXLIN_NT
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT

## ! EST_IADPERIFCT_I4 Fichier Frai ESCJ0660

NSTEP=${NJOB}_168
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-POS not in pericase INV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFCT_I4} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFCT_POS_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       1:1 - 1:,   
		END_NT       2:1 - 2:,   
		SEC_NF       3:1 - 3:,   
		UWY_NF       4:1 - 4:,   
		UW_NT        5:1 - 5:,   
		STD_CTR_NF   1:1 - 1:,   
		STD_END_NT   2:1 - 2:,   
		STD_SEC_NF   3:1 - 3:,   
		STD_UWY_NF   4:1 - 4:,   
		STD_UW_NT    5:1 - 5:,  
		ALL_COLS     1:1 -  12: 
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EST_IADPERIFCT_5010} 2000 1 "~"
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


# Generate EST_IADPERIFCT when TYPEINV=POS and IS_SEQ_MODE=0

NSTEP=${NJOB}_170
#------------------------------------------------------------------------------
LIBEL="Generate EST_IADPERIFCT when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_168_${IB}_SORT_IADPERIFCT_POS_O.dat 2000 1"
SORT_I2="${EST_IADPERIFCT_5010} 2000 1"
SORT_O="${EST_IADPERIFCT} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       1:1 - 1:,   
        		END_NT       2:1 - 2:,   
        		SEC_NF       3:1 - 3:,   
       		  UWY_NF       4:1 - 4:,   
        		UW_NT        5:1 - 5: 
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT



##NSTEP=${NJOB}_175
###------------------------------------------------------------------------------
### Merge EST_IADPERIFR_5010 with EST_IADPERIFR_I4 without duplicate key from EST_IADPERIFR_5010
###-----------------------------------------------------------------------------
##LIBEL="Generate EST_IADPERIFR when TYPEINV=POS and IS_SEQ_MODE=0"
##SORT_WDIR=${SORTWORK}
##SORT_CMD=`CFTMP`
##SORT_I="${EST_IADPERIFR_5010} 1000 1"
##SORT_I2="${EST_IADPERIFR_I4} 1000 1"
##SORT_O="${EST_IADPERIFR} 1000 1"
##INPUT_TEXT $SORT_CMD <<EOF
##/FIELDS CTR_NF 1:1 - 1:,
##								END_NT 2:1 - 2:,
##								SEC_NF 3:1 - 3:,
##        UWY_NF 4:1 - 4:,
##        UW_NT 5:1 - 5:,
##								CHGLIN_NT 6:1 - 6:
##/KEYS CTR_NF,
##      END_NT,
##      SEC_NF,
##      UWY_NF,
##      UW_NT,
##						CHGLIN_NT
##/STABLE
##/SUMMARIZE
##/OUTFILE ${SORT_O}
##exit
##EOF
##SORT

##### ! EST_IADPERIFR_I4 Fichier Frais Issu du ESCJ0660

NSTEP=${NJOB}_173
#-----------------------------------------------------------------------------
LIBEL="get CSUOE-POS not in pericase INV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFR_I4} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IADPERIFR_POS_O.dat 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS   	
		CTR_NF       1:1 - 1:,   
		END_NT       2:1 - 2:,   
		SEC_NF       3:1 - 3:,   
		UWY_NF       4:1 - 4:,   
		UW_NT        5:1 - 5:,   
		STD_CTR_NF   1:1 - 1:,   
		STD_END_NT   2:1 - 2:,   
		STD_SEC_NF   3:1 - 3:,   
		STD_UWY_NF   4:1 - 4:,   
		STD_UW_NT    5:1 - 5:,  
		ALL_COLS     1:1 -  15: 
/joinkeys
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/INFILE ${EST_IADPERIFR_5010} 2000 1 "~"
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


# Generate EST_IADPERIFR when TYPEINV=POS and IS_SEQ_MODE=0

NSTEP=${NJOB}_175
#------------------------------------------------------------------------------
LIBEL="Generate EST_IADPERIFR when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_173_${IB}_SORT_IADPERIFR_POS_O.dat 2000 1"
SORT_I2="${EST_IADPERIFR_5010} 2000 1"
SORT_O="${EST_IADPERIFR} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS   	CTR_NF       1:1 - 1:,   
        		END_NT       2:1 - 2:,   
        		SEC_NF       3:1 - 3:,   
       		  UWY_NF       4:1 - 4:,   
        		UW_NT        5:1 - 5: 
/KEYS CTR_NF, 
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT



#[005]

NSTEP=${NJOB}_180
#------------------------------------------------------------------------------
# Merge EST_FPLATXCUM0_5010 with EST_FPLATXCUM0_I4 without duplicate key from EST_FPLATXCUM0_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FPLATXCUM0 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLATXCUM0_5010} 1000 1"
SORT_I2="${EST_FPLATXCUM0_I4} 1000 1"
SORT_O="${EST_FPLATXCUM0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
								SEC_NF 2:1 - 2:,
								UWY_NF 3:1 - 3:,
								PLC_NT 4:1 - 4:
/KEYS CTR_NF,
						SEC_NF,
						UWY_NF,
						PLC_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_185
#------------------------------------------------------------------------------
# Merge EST_IADPERICASE_ENTIER0_5010 with EST_IADPERICASE_ENTIER0_I4 without duplicate key from EST_IADPERICASE_ENTIER0_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADPERICASE_ENTIER0 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_ENTIER0_5010} 1000 1"
SORT_I2="${EST_IADPERICASE_ENTIER0_I4} 1000 1"
SORT_O="${EST_IADPERICASE_ENTIER0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_190
#------------------------------------------------------------------------------
# Merge EST_IADPERICASE0_5010 with EST_IADPERICASE0_I4 without duplicate key from EST_IADPERICASE0_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IADPERICASE0 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0_5010} 1000 1"
SORT_I2="${EST_IADPERICASE0_I4} 1000 1"
SORT_O="${EST_IADPERICASE0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_195
#------------------------------------------------------------------------------
# Merge EST_IARVPERICASE0_5010 with EST_IARVPERICASE0_I4 without duplicate key from EST_IARVPERICASE0_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_IARVPERICASE0 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IARVPERICASE0_5010} 1000 1"
SORT_I2="${EST_IARVPERICASE0_I4} 1000 1"
SORT_O="${EST_IARVPERICASE0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_200
#------------------------------------------------------------------------------
# Merge EST_FCESSION0_5010 with EST_FCESSION0_I4 without duplicate key from EST_FCESSION0_5010
#-----------------------------------------------------------------------------
LIBEL="Generate EST_FCESSION0 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCESSION0_5010} 1000 1"
SORT_I2="${EST_FCESSION0_I4} 1000 1"
SORT_O="${EST_FCESSION0} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
								RETCTR_NF 6:1 - 6:,
        RETEND_NT 7:1 - 7:,
        RETSEC_NF 8:1 - 8:,
        RTY_NF 9:1 - 9:,
        RETUW_NT 10:1 - 10:
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
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
SORT

#[002]
NSTEP=${NJOB}_205
# Merge EST_IADPERICASE_5010 with EST_IADPERICASE_I4 without duplicate key from EST_IADPERICASE_5010
#------------------------------------------------------------------------------
LIBEL="Generate EST_IADPERICASE_DUMMY when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_DUMMY_5010} 2000 1"
SORT_I2="${EST_IADPERICASE_DUMMY_I4} 2000 1"
SORT_O="${EST_IADPERICASE_DUMMY} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT


#[004]
NSTEP=${NJOB}_210
# Merge EST_FCESSION1_5010 with EST_FCESSION1_I4 without duplicate key from EST_FCESSION1
#------------------------------------------------------------------------------
LIBEL="Generate EST_FCESSION1 when TYPEINV=POS and IS_SEQ_MODE=0"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCESSION1_5010} 2000 1"
SORT_I2="${EST_FCESSION1_I4} 2000 1"
SORT_O="${EST_FCESSION1} 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        RETCTR_NF 6:1 - 6:,
        RETEND_NT 7:1 - 7:,
        RETSEC_NF 8:1 - 8:,
        RTY_NF 9:1 - 9:,
        RETUW_NT 10:1 - 10:
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT
/STABLE
/SUMMARIZE
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

JOBEND
