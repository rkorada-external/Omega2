#!/bin/ksh
#=============================================================================
# nom de l'application		    : ESTIMATIONS - INVENTAIRE
#                                 Rejets / Reconduction
# nom du script SHELL		    : ESID2901.cmd
# revision			            : $Revision:   1.1  $
# date de creation		        : 08/09/1997
# auteur			            : CGI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#   Retrocession reversal and carried forward entries generation
#
# job launched by ESID2090.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#   02/02/2010   JF VDV [18853] - Ajout d'un tri en entree du programme ESTM7602.c (prise en compte de l'etablissement )
#                                 nouveaux step 02, 07 & 09
#[002] 14/03/2011 R. CASSIS :spot:21408 - modification des fichiers au format GT 41 col. + 14 vides
#[003] 26/09/2011 R. CASSIS :spot:22672 - Ajout taille du record a 1000 en entree dans les tris
#[004] 28/02/2012 R. Cassis :spot:23466 - Ajout identifiant GTAR dans mouvements annuels ouv/clo
#[005] 12/10/2016 Florent   :spot:31344 - mise au format GLT 71 colonnes
#[006] 01/09/2020 R. Cassis :spira:88186 - Omission des postes EBS dans mouvements annuels ouv/clo car ils sont traites dans ESPD2900
#[007] 09/09/2020 R. cassis :spira:66261 - Add SSD_CF key in SORT process
#[008] 27/01/2022 R. cassis :spira:98240 - ajout colonnes TRN_NT, GAAPCOD_NT, I17PRDCOD_CT et RETARDRETINT_B dans clé de tri
#[009] 27/06/2023 JYP/TD    :spira 109764 - update NEWCOLS1_NF=empty 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT

# Parameters
CLODAT_D=$1
BALSHTMTH_NF=$2


NSTEP=${NJOB}_00
#Last version of ESID2900 files deletion
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_DLREJGTAA}`/${PCH}ESID2900_DLREJGTAA*${CLODAT_D}*.dat
 `dirname ${EST_DLREJGTAR}`/${PCH}ESID2900_DLREJGTAR*${CLODAT_D}*.dat
 `dirname ${EST_DLREJGTR}`/${PCH}ESID2900_DLREJGTR*${CLODAT_D}*.dat"

# [002]
# [004] [006] [007]
NSTEP=${NJOB}_02
#-----------------------------------------------------------------------------
LIBEL="Current sort file ${EST_TOTGTAA}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TOTGTAA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        TRNCOD2C_CF   6:2 - 6:2,
	      CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        FORMAT_41  1:1 - 41:,
        TRN_NT     56:1 - 56:,
        RETARDRETINT_B 61:1 - 61:,
        GAAPCOD_NT  64:1 - 64:,
        I17PRDCOD_CT 65:1 - 65:,
        FILLER14COLS 58:1 - 71:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
/DERIVEDFIELD BLANK_14_CHAMPS 14"~"
/DERIVEDFIELD ORIDCOD_LS "GTAR~"      
/CONDITION COND_IFRS ("AEJ" NC TRNCOD2C_CF )      
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS
/REFORMAT FORMAT_41,BLANK_14_CHAMPS,TRN_NT,ORIDCOD_LS,FILLER14COLS
exit
EOF
SORT

NSTEP=${NJOB}_05
#-----------------------------------------------------------------------------
LIBEL="Acceptance retrocession reversal and carried forward in progress ..."
PRG=ESTM7602
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
BALSHTMTH_NF ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_02_${IB}_SORT_TOTGTAA_O.dat
export ${PRG}_O1=${DFILT}/${NJOB}_05_${IB}_SORT_TOTGTAA_O.dat
EXECPRG


NSTEP=${NJOB}_06
#-----------------------------------------------------------------------------
LIBEL="blank NEWCOLS1_NF "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_TOTGTAA_O.dat 1000 1"
SORT_O="${EST_DLREJGTAA} 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 24:1 - 24:,
        RETSEC_NF 26:1 - 26: EN,
        RTY_NF    27:1 - 27:,
        PLC_NT    36:1 - 36:EN,
        FILLER01   1:1 - 62:,
		COLS_END  64:1 - 71: 
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NT
/DERIVEDFIELD  NEWCOLS1_NF "~"
/OUTFILE ${SORT_O}
/REFORMAT FILLER01,NEWCOLS1_NF, COLS_END
exit
EOF
SORT



# [002]
# [004] [006] [007]
NSTEP=${NJOB}_07
#-----------------------------------------------------------------------------
LIBEL="Current sort file ${EST_TOTGTAR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TOTGTAR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTAR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        TRNCOD2C_CF   6:2 - 6:2,
	    CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        FORMAT_41  1:1 - 41:,
        TRN_NT     56:1 - 56:,
        RETARDRETINT_B 61:1 - 61:,
        GAAPCOD_NT  64:1 - 64:,
        I17PRDCOD_CT 65:1 - 65:,
        FILLER5COLS 58:1 - 62:,
		COLS_END  64:1 - 71: 
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
/DERIVEDFIELD BLANK_14_CHAMPS 14"~"
/DERIVEDFIELD  NEWCOLS1_NF "~"
/DERIVEDFIELD ORIDCOD_LS "GTAR~"
/CONDITION COND_IFRS ("AEJ" NC TRNCOD2C_CF )      
/OUTFILE ${SORT_O}
/INCLUDE COND_IFRS
/REFORMAT FORMAT_41,BLANK_14_CHAMPS,TRN_NT,ORIDCOD_LS,FILLER5COLS, NEWCOLS1_NF,COLS_END
exit
EOF
SORT

NSTEP=${NJOB}_10
#-----------------------------------------------------------------------------
LIBEL="Acceptance retrocession reversal and carried forward in progress ..."
PRG=ESTM7602
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D $CLODAT_D
BALSHTMTH_NF $BALSHTMTH_NF
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_07_${IB}_SORT_TOTGTAR_O.dat
export ${PRG}_O1=${EST_DLREJGTAR}
EXECPRG

#[06] [007]
NSTEP=${NJOB}_12
#-----------------------------------------------------------------------------
LIBEL="Current sort file ${EST_TOTGTR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_TOTGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TOTGTR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        TRNCOD2C_CF   6:2 - 6:2,
	      CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        ACY_NF 14:1 - 14:,
        SCOENDMTH_NF 16:1 - 16:,
        SCOSTRMTH_NF 15:1 - 15:,
        OCCYEA_NF 13:1 - 13:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETACY_NF 30:1 - 30:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETOCCYEA_NF 29:1 - 29:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        PLC_NT 36:1 - 36:,
        TRNCOD_CF 6:1 - 6:,
        TRNCOD1_CF 6:1 - 6:1,
        TRN_NT     56:1 - 56:,
        RETARDRETINT_B 61:1 - 61:,
        GAAPCOD_NT  64:1 - 64:,
        I17PRDCOD_CT 65:1 - 65:
       
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT,
      ACY_NF,
      SCOENDMTH_NF,
      SCOSTRMTH_NF,
      OCCYEA_NF,
      CLM_NF,
      CUR_CF,
      RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      RETACY_NF,
      RETSCOENDMTH_NF,
      RETSCOSTRMTH_NF,
      RETOCCYEA_NF,
      RCL_NF,
      RETCUR_CF,
      PLC_NT,
      SSD_CF,
      ESB_CF,
      TRNCOD_CF,
      TRN_NT,
      RETARDRETINT_B,
      GAAPCOD_NT,
      I17PRDCOD_CT
/CONDITION COND_IFRS ("AEJ" NC TRNCOD2C_CF )      
/INCLUDE COND_IFRS
exit
EOF
SORT

NSTEP=${NJOB}_15
#Retrocession Retrocession reversal and carried forward of previous balance sheet in the book
#-----------------------------------------------------------------------------
LIBEL="Retrocession retrocession reversal and carried forward in progress ..."
PRG=ESTM7602
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
BALSHTMTH_NF ${BALSHTMTH_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_12_${IB}_SORT_TOTGTR_O.dat
export ${PRG}_O1=${EST_DLREJGTR}
EXECPRG

JOBEND
