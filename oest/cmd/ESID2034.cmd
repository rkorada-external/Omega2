!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION TEST
# nom du script SHELL           : ESID2034.cmd
# revision                      : $Revision: 1.10 $
# date de creation              : 
# auteur                        : Radhouane
# references des specifications : :spot:25427
#-----------------------------------------------------------------------------
# description :
#   Creation du CPLIFEST_MVT
#
#
# job launched by ESID3020.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
#
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Get input parameters
CRE_D=$1

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_10
# Tri du VLIFEST195
#------------------------------------------------------------------------------
LIBEL="Tri du VLIFEST195"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_VLIFEST195} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_LIFEST_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF           2:1 -  2:,
        SEC_NF           4:1 -  4:EN,
        UWY_NF           5:1 -  5:,
        ACY_NF           7:1 -  7:,
        CRE_D            8:1 -  8:,
        ACMTRS_NT       10:1 - 10:,
        BALSHEY_NF      11:1 - 11:,
        BALSHMTH_NF     12:1 - 12:EN,
        ORICOD_LS       31:1 - 31:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT,
      ORICOD_LS,
      BALSHEY_NF    DESCENDING,
      BALSHMTH_NF   DESCENDING,
      CRE_D         
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_20
# récupèration de la dernière version du LIFEST 
# n'ayant pas subi de modification de montant pour un ORICOD_LS
#------------------------------------------------------------------------------
LIBEL="récupèration de la dernière version du LIFEST n'ayant pas subi de modification de montant"
PRG=ESTC2043
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_LIFEST_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_LAST_LIFEST_O1.dat
EXECPRG


NSTEP=${NJOB}_30
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_1_${IB}_SORT_LIFEST_O.dat


NSTEP=${NJOB}_40
# Tri du fichier VLIFEST 
# Création du CPLIFEST_MVT pour recharger dans TLIFEST
#------------------------------------------------------------------------------
LIBEL="Tri du fichier VLIFEST Création du CPLIFEST_MVT pour recharger dans TLIFEST"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_ESTC2043_LAST_LIFEST_O1.dat 1000 1"
SORT_O="${EST_VLIFEST195} 1000 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_CPLIFEST_MVT_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF           1:1 -  1:EN,
        CTR_NF           2:1 -  2:,
        END_NT           3:1 -  3:,
        SEC_NF           4:1 -  4:,
        UWY_NF           5:1 -  5:,
        UW_NT            6:1 -  6:,
        ACY_NF           7:1 -  7:,
        CRE_D            8:1 -  8:,
        ACMTRS_NT       10:1 - 10:,
        BALSHEY_NF      11:1 - 11:,
        BALSHTMTH_NF    12:1 - 12:EN,
        CUR_CF          13:1 - 13:,
        ESTMNT_M        14:1 - 14:EN 15/3,
        INDSUP_B        30:1 - 30:,
        ORICOD_LS       31:1 - 31:,
        CREUSR_CF       32:1 - 32:,
        LSTUPD_D        33:1 - 33:,
        LSTUPDUSR_CF    34:1 - 34:,
        CRE_D2           8:1 -  8:14
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      ACY_NF,
      ACMTRS_NT DESCENDING,
      CRE_D     DESCENDING
/DERIVEDFIELD PRS_CF "500~"
/CONDITION NEWMVT ( CRE_D2 = "${CRE_D} 23:59" )
/OUTFILE   ${SORT_O}
/OUTFILE   ${SORT_O2}
/INCLUDE   NEWMVT
/REFORMAT  CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT, CRE_D, BALSHEY_NF, BALSHTMTH_NF, ACY_NF, PRS_CF, ACMTRS_NT,
           SSD_CF, CUR_CF, ESTMNT_M, INDSUP_B, ORICOD_LS, CREUSR_CF, LSTUPD_D, LSTUPDUSR_CF
exit
EOF
SORT


NSTEP=${NJOB}_50
# Inversion des montants avant le remplissage de la table TLIFEST
#-----------------------------------------------------------------------------
LIBEL="Inversion des montants avant le remplissage de la table TLIFEST"
AWK_I=${DFILT}/${NJOB}_40_${IB}_SORT_CPLIFEST_MVT_O.dat
AWK_O=${EST_CPLIFEST_MVT}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
		{ if( \$11 < "2000" ) { print \$0 }}
		{ if( \$11 > "2000" ) { \$14 = sprintf("%-.3lf",-\$14) ; print \$0 }}
exit
EOF
AWK

NSTEP=${NJOB}_55
# Begin EXECKSH
#-------------------------------------------------------------------------------
LIBEL="Save ${EST_CPLIFEST_MVT}"
EXECKSH "cp ${EST_CPLIFEST_MVT} ${DSAV}/${SVG}_${NCHAIN}_EST_CPLIFEST_MVT.dat"

NSTEP=${NJOB}_60
# Delete temporary file
#-----------------------------------------------------------------------------
LIBEL="Delete temporary file"
RMFIL ${DFILT}/${NJOB}_20_${IB}_ESTC2043_LAST_LIFEST_O1.dat

NSTEP=${NJOB}_70
# Deletion of Temporary Files
#------------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}_*_${IB}*.dat"

# Job End
JOBEND

