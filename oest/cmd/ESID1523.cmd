#!/bin/ksh
#==============================================================================
#nom de l'application          : Job preparatoire aux editions ESP des PLAN VIE
#nom du source                 : ESID1523.cmd
#date de creation              : 22/01/2015
#auteur                        : S.Behague
#references des spicifications : Edition SCOR VIE
#------------------------------------------------------------------------------
#description :
# Cette chaine execute les steps suivants
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <JJ/MM/AAAA>   <Auteur >    <Description de la modification>
#   22/01/2015      S.Behague    Création - spot 28122 EST48
#   10/03/2015      P.Menant     :spot:28122 EST48, passage de CLODAT_D a ESTM7621
#   17/04/2015      S.Behague    :spot:28306 EST37, Creation FLIFPLN3
#   13/05/2019      B.LAGHA      :spot:75940 Ajout d'un param "EXEC_MODE" au STAM1526 
#----------------------------------------------------------------------------



# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Recupere arguments d'entree
CLODAT_D=$1
BALSHEY_NF=$2
#BALSHTYEA_NF=$4
LIF_ACY_MAX=4
LIF_ACY_MIN=4
# Initialise JOB
JOBINIT


NSTEP=${NJOB}_10
# Estimates cession amounts accumulation
#----------------------------------------------------------------------------
LIBEL="Estimates cession amounts accumulation"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FVPLACEMT} 1000 "
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FVPLACEMT_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELD  RCTR_NF     3:1 - 3:,
        RSEC_NF     5:1 - 5: EN,
        RTY_NF      6:1 - 6: EN
/KEYS RCTR_NF,RSEC_NF,RTY_NF
/COPY
/OUTFILE ${SORT_O}
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_FVPLACEMT_O.dat > ${DFILT}/${NJOB}_10_SORT_FVPLACEMT_O.dat.gz

NSTEP=${NJOB}_20
# Sort of acceptance life perimeters
#-----------------------------------
LIBEL="SORT of IAVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IARVPERICASE4} 1000"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERI_O.dat
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
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_PERI_O.dat > ${DFILT}/${NJOB}_20_SORT_PERI_O.dat.gz

NSTEP=${NJOB}_50
# Begin sort  ACCEPT
#-----------------------------------------------------------------------------
LIBEL="Sort of FLIFPLN file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FLIFPLN} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FLIFPLN_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1: EN,
        ESB_CF             2:1 - 2:,
        BALSHEY_NF         3:1 - 3:,
        BALSHRMTH_NF       4:1 - 4:,
        BALSHRDAY_NF       5:1 - 5:,
        TRNCOD_CF          6:1 - 6:,
        TRNCOD_SOUS_PREFIX 6:2 - 6:2,
        DBLTRNCOD_CF       7:1 - 7:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:,
        OCCYEA_NF         13:1 - 13:,
        ACY_NF            14:1 - 14:,
        SCOSTRMTH_NF      15:1 - 15:,
        SCOENDMTH_NF      16:1 - 16:,
        CLM_NF            17:1 - 17:,
        CUR_CF            18:1 - 18:,
        AMT_M             19:1 - 19:,
        CED_NF            20:1 - 20:,
        BRK_NF            21:1 - 21:,
        GEMPRMPAY_NF      22:1 - 22:,
        GANPAYORD_NT      23:1 - 23:,
        RETCTR_NF         24:1 - 24:,
        RETEND_NT         25:1 - 25:,
        RETSEC_NF         26:1 - 26:,
        RTY_NF            27:1 - 27:,
        RETUW_NT          28:1 - 28:,
        RETOCCYEA_NF      29:1 - 29:,
        RETACY_NF         30:1 - 30:,
        RETSCOSTRMTH_NF   31:1 - 31:,
        RETSCOENDMTH_NF   32:1 - 32:,
        RCL_NF            33:1 - 33:,
        RETCUR_CF         34:1 - 34:,
        RETAMT_M          35:1 - 35:,
        PLC_NT            36:1 - 36:,
        RTO_NF            37:1 - 37:,
        INT_NF            38:1 - 38:,
        RETPAY_NF         39:1 - 39:,
        RETKEY_CF         40:1 - 40:,
        RETINTAMT_M       41:1 - 41:EN,
        POSTBPC_B         69:1 - 69:,        
        RETAUTGEN_B       71:1 - 71:,
        ACCTYP_NF         72:1 - 72:EN,
        ACTIVEPLAN_B      73:1 - 73:
/KEYS CTR_NF, SEC_NF, UWY_NF
/CONDITION ACCEPT ACCTYP_NF = 1
/OUTFILE ${SORT_O}
/INCLUDE ACCEPT
/COPY
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_FLIFPLN_O.dat > ${DFILT}/${NJOB}_50_SORT_FLIFPLN_O.dat.gz

NSTEP=${NJOB}_80
# Begin sort  RETRO
#[006] ajout de /KEYS SSD_CF, SEC_NF, UWY_NF pour que la synchro fonctionne
#-----------------------------------------------------------------------------
LIBEL="Sort of FLIFPLN file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FLIFPLN} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FLIFPLN_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1: EN,
        ESB_CF             2:1 - 2:,
        BALSHEY_NF         3:1 - 3:,
        BALSHRMTH_NF       4:1 - 4:,
        BALSHRDAY_NF       5:1 - 5:,
        TRNCOD_CF          6:1 - 6:,
        TRNCOD_SOUS_PREFIX 6:2 - 6:2,
        DBLTRNCOD_CF       7:1 - 7:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:,
        OCCYEA_NF         13:1 - 13:,
        ACY_NF            14:1 - 14:,
        SCOSTRMTH_NF      15:1 - 15:,
        SCOENDMTH_NF      16:1 - 16:,
        CLM_NF            17:1 - 17:,
        CUR_CF            18:1 - 18:,
        AMT_M             19:1 - 19:,
        CED_NF            20:1 - 20:,
        BRK_NF            21:1 - 21:,
        GEMPRMPAY_NF      22:1 - 22:,
        GANPAYORD_NT      23:1 - 23:,
        RETCTR_NF         24:1 - 24:,
        RETEND_NT         25:1 - 25:,
        RETSEC_NF         26:1 - 26:,
        RTY_NF            27:1 - 27:,
        RETUW_NT          28:1 - 28:,
        RETOCCYEA_NF      29:1 - 29:,
        RETACY_NF         30:1 - 30:,
        RETSCOSTRMTH_NF   31:1 - 31:,
        RETSCOENDMTH_NF   32:1 - 32:,
        RCL_NF            33:1 - 33:,
        RETCUR_CF         34:1 - 34:,
        RETAMT_M          35:1 - 35:,
        PLC_NT            36:1 - 36:,
        RTO_NF            37:1 - 37:,
        INT_NF            38:1 - 38:,
        RETPAY_NF         39:1 - 39:,
        RETKEY_CF         40:1 - 40:,
        RETINTAMT_M       41:1 - 41:EN,
        POSTBPC_B         69:1 - 69:,        
        RETAUTGEN_B       71:1 - 71:,
        ACCTYP_NF         72:1 - 72:EN,
        ACTIVEPLAN_B      73:1 - 73:
/KEYS RETCTR_NF, RETSEC_NF, RTY_NF
/CONDITION RETRO (ACCTYP_NF = 2 or ACCTYP_NF = 3 or ACCTYP_NF = 4 or ACCTYP_NF = 5)
/OUTFILE ${SORT_O}
/INCLUDE RETRO
/COPY
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_FLIFPLN_O.dat > ${DFILT}/${NJOB}_80_SORT_FLIFPLN_O.dat.gz

NSTEP=${NJOB}_100
#Retrocession and Acceptance Data Exchange
#------------------------------------------------------------------------------
LIBEL="Retrocession and Acceptance Data Exchange"
PRG=ESTC2033
export ${PRG}_I1=${DFILT}/${NJOB}_80_${IB}_SORT_FLIFPLN_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FLIFPLN_O.dat
EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_FLIFPLN_O.dat > ${DFILT}/${NJOB}_100_${PRG}_FLIFPLN_O.dat.gz


NSTEP=${NJOB}_120
# SPLIT OF FLIFPLN by placement / retrocessionnaire
#----------------------------------------------------------------------------
LIBEL="Amount by retrocessionnaire"
PRG=STAM1225
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF  ${BALSHEY_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_FVPLACEMT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_100_${IB}_ESTC2033_FLIFPLN_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_FLIFPLN_O.dat 
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_STGTER10_REJET_O1.log 
EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_FLIFPLN_O.dat > ${DFILT}/${NJOB}_120_${PRG}_FLIFPLN_O.dat.gz

NSTEP=${NJOB}_140
# Begin sort  RETRO
#[006] ajout de /KEYS SSD_CF, SEC_NF, UWY_NF pour que la synchro fonctionne
#-----------------------------------------------------------------------------
LIBEL="Sort of FLIFPLN file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_120_${IB}_STAM1225_FLIFPLN_O.dat 1000"
SORT_I2="${DFILT}/${NJOB}_50_${IB}_SORT_FLIFPLN_O.dat 1000"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVPLN_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF  1:1 -  1: EN,
        CTR_NF  8:1 -  8:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        PLC_NT 36:1 - 36:
/KEYS CTR_NF, SEC_NF, UWY_NF, PLC_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_ECRSRVPLN_O.dat > ${DFILT}/${NJOB}_140_SORT_ECRSRVPLN_O.dat.gz


NSTEP=${NJOB}_180
#Introduction of Conversion and Accumulated Transaction Codes
#------------------------------------------------------------------------------
LIBEL="Introduction of Conversion and Accumulated Transaction Codes"
PRG=ESTM7621
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CLODAT_D  ${CLODAT_D}
BALSHTYEA_NF  ${BALSHEY_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORT_PERI_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_140_${IB}_SORT_ECRSRVPLN_O.dat
export ${PRG}_I3=${EST_FTRSLNK}
export ${PRG}_I4=${EST_FCURQUOT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSRVPLN_O1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSRVPLN_O2.dat
EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSRVPLN_O1.dat > ${DFILT}/${NJOB}_180_${PRG}_ECRSRVPLN_O1.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSRVPLN_O2.dat > ${DFILT}/${NJOB}_180_${PRG}_ECRSRVPLN_O2.dat.gz

NSTEP=${NJOB}_190
# Begin 
#[006] summarize de /KEYS SSD_CF, SEC_NF, UWY_NF
#-----------------------------------------------------------------------------
LIBEL="Sort of FLIFPLN file"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_180_${IB}_ESTM7621_ECRSRVPLN_O1.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FLIFPLN_O.dat
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF             1:1 - 1: EN,
        ESB_CF             2:1 - 2:,
        BALSHEY_NF         3:1 - 3:,
        BALSHRMTH_NF       4:1 - 4:,
        BALSHRDAY_NF       5:1 - 5:,
        TRNCOD_CF          6:1 - 6:,
        DETTRNCOD_CF       6:3 - 6:,
        DBLTRNCOD_CF       7:1 - 7:,
        CTR_NF             8:1 - 8:,
        END_NT             9:1 - 9:,
        SEC_NF            10:1 - 10:,
        UWY_NF            11:1 - 11:,
        UW_NT             12:1 - 12:,
        OCCYEA_NF         13:1 - 13:,
        ACY_NF            14:1 - 14:,
        SCOSTRMTH_NF      15:1 - 15:,
        SCOENDMTH_NF      16:1 - 16:,
        CLM_NF            17:1 - 17:,
        CUR_CF            18:1 - 18:,
        FILLER1           1:1  - 17:,
        FILLER2           20:1 - 33:,
        FILLER3           36:1 - 41:,
        FILLER4           44:1 - 73:,
        AMT_M             19:1 - 19:EN,
        CED_NF            20:1 - 20:,
        BRK_NF            21:1 - 21:,
        GEMPRMPAY_NF      22:1 - 22:,
        GANPAYORD_NT      23:1 - 23:,
        RETCTR_NF         24:1 - 24:,
        RETEND_NT         25:1 - 25:,
        RETSEC_NF         26:1 - 26:,
        RTY_NF            27:1 - 27:,
        RETUW_NT          28:1 - 28:,
        RETOCCYEA_NF      29:1 - 29:,
        RETACY_NF         30:1 - 30:,
        RETSCOSTRMTH_NF   31:1 - 31:,
        RETSCOENDMTH_NF   32:1 - 32:,
        RCL_NF            33:1 - 33:,
        RETCUR_CF         34:1 - 34:,
        RETAMT_M          35:1 - 35:EN,
        PLC_NT            36:1 - 36:,
        RTO_NF            37:1 - 37:,
        INT_NF            38:1 - 38:,
        RETPAY_NF         39:1 - 39:,
        RETKEY_CF         40:1 - 40:,
        RETINTAMT_M       41:1 - 41:EN,
        ESTCUR_CF         42:1 - 42:,
        ESTAMNT_M         43:1 - 43:EN,
        POSTBPC_B         69:1 - 69:,        
        RETAUTGEN_B       71:1 - 71:,
        ACCTYP_NF         72:1 - 72:EN,
        ACTIVEPLAN_B      73:1 - 73:
/KEYS BALSHEY_NF, BALSHRMTH_NF , DETTRNCOD_CF , CTR_NF, SEC_NF, UWY_NF, ACY_NF, ESTCUR_CF, RETCTR_NF , RETSEC_NF , RTY_NF, PLC_NT , RETCUR_CF, POSTBPC_B
/SUMMARIZE TOTAL AMT_M, TOTAL RETAMT_M, TOTAL ESTAMNT_M
/OUTFILE ${SORT_O}
/REFORMAT FILLER1, ESTCUR_CF, ESTAMNT_M, FILLER2, ESTCUR_CF, ESTAMNT_M, FILLER3, ESTCUR_CF, ESTAMNT_M, FILLER4
exit
EOF
SORT

gzip -c ${DFILT}/${NSTEP}_${IB}_SORT_FLIFPLN_O.dat > ${DFILT}/${NJOB}_190_SORT_FLIFPLN_O.dat.gz

NSTEP=${NJOB}_200
# Split Multigaap and propagation for cash transaction code
#------------------------------------------------------------------------------
LIBEL=" Split Multigaap and propagation for cash transaction code "
PRG=STAM1526
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
EXEC_MODE  FPLN
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_190_${IB}_SORT_FLIFPLN_O.dat
export ${PRG}_I2=${EST_SUBTRS}
export ${PRG}_O=${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSRVPLN_O1.dat
EXECPRG

gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_ECRSRVPLN_O1.dat > ${DFILT}/${NJOB}_200_${PRG}_ECRSRVPLN_O1.dat.gz

if [ -f ${EST_FLIFPLN2} ] 
then
    RMFIL ${EST_FLIFPLN2}
fi

#NSTEP=${NJOB}_220
## Begin sort
##------------------------------------------------------------------------------
#LIBEL="REFORMAT gt"
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${DFILT}/${NJOB}_200_${IB}_STAM1526_ECRSRVPLN_O1.dat 1000"
#SORT_O="${EST_FLIFPLN1} 1000"
#SORT_O2="${EST_FLIFPLN2} 1000"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS FILLER1            1:1 - 57:,
#        FILLER2           59:1 - 73:,
#        POSTBPC_B         69:1 - 69:,
#        ACTIVEPLAN_B      73:1 - 73:
#/CONDITION PLAN_ACTIF  POSTBPC_B="0" AND ACTIVEPLAN_B="1"
#/CONDITION PLAN_NON_ACTIF POSTBPC_B != "0" OR ACTIVEPLAN_B != "1"
#/DERIVEDFIELD PR_FIELD "PR~"
#/OUTFILE ${SORT_O}
#/INCLUDE PLAN_ACTIF
#/REFORMAT  FILLER1, PR_FIELD, FILLER2
#/OUTFILE ${SORT_O2}
#/INCLUDE PLAN_NON_ACTIF
#/REFORMAT  FILLER1, PR_FIELD, FILLER2
#exit
#EOF
#SORT


NSTEP=${NJOB}_220
# Begin sort
#------------------------------------------------------------------------------
LIBEL="REFORMAT gt"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_STAM1526_ECRSRVPLN_O1.dat 1000"
SORT_O="${EST_FLIFPLN1} 1000"
SORT_O2="${EST_FLIFPLN2} 1000"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1            1:1 - 57:,
        FILLER2           59:1 - 73:,
        POSTBPC_B         69:1 - 69:,
        ACTIVEPLAN_B      73:1 - 73:
/DERIVEDFIELD PR_FIELD "PR~"
/CONDITION PLAN_ACTIF  POSTBPC_B="0" AND ACTIVEPLAN_B="1"
/OUTFILE ${SORT_O}
/INCLUDE PLAN_ACTIF
/REFORMAT FILLER1, PR_FIELD, FILLER2
/OUTFILE ${SORT_O2}
/OMIT PLAN_ACTIF
exit
EOF
SORT

NSTEP=${NJOB}_225
# Begin sort
#------------------------------------------------------------------------------
LIBEL="REFORMAT gt"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_STAM1526_ECRSRVPLN_O1.dat 1000"
SORT_O="${EST_FLIFPLN3} 1000"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS FILLER1            1:1 - 57:,
        FILLER2           59:1 - 73:,
        POSTBPC_B         69:1 - 69:,
        ACTIVEPLAN_B      73:1 - 73:
/DERIVEDFIELD PR_FIELD "PR~"
/CONDITION PLAN_ACTIF  POSTBPC_B="1" AND ACTIVEPLAN_B="1"
/OUTFILE ${SORT_O}
/INCLUDE PLAN_ACTIF
/REFORMAT FILLER1, PR_FIELD, FILLER2
exit
EOF
SORT


NSTEP=${NJOB}_175
# Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}*_${IB}_SORT_FVPLACEMT_O.dat
RMFIL ${DFILT}/${NJOB}*_${IB}_SORT_PERI_O.dat
RMFIL ${DFILT}/${NJOB}*_${IB}_SORT_FLIFPLN_O.dat
RMFIL ${DFILT}/${NJOB}*_${IB}_SORT_FLIFPLN_O.dat
RMFIL ${DFILT}/${NJOB}*_${IB}_STAM1225_FLIFPLN_O.dat
RMFIL ${DFILT}/${NJOB}*_${IB}_ESTC2033_FLIFPLN_O.dat
RMFIL ${DFILT}/${NJOB}*_${IB}_SORT_ECRSRVPLN_O.dat
RMFIL ${DFILT}/${NJOB}*_${IB}_ESTM7621_ECRSRVPLN_O1.dat
RMFIL ${DFILT}/${NJOB}*_${IB}_ESTM7621_ECRSRVPLN_O2.dat
RMFIL ${DFILT}/${NJOB}*_${IB}_SORT_FLIFPLN_O.dat
RMFIL ${DFILT}/${NJOB}*_${IB}_STAM1526_ECRSRVPLN_O1.dat

JOBEND
