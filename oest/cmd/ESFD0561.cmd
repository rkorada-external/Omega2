#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Comptabilisation des ecritures de services IFRS17 Life
#				  
# nom du script SHELL		: ESFD0560.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 18/02/2021
# auteur			: S.Behague
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#         Special entries booking
#-----------------------------------------------------------------------------
#-=-=-=-=-=-=-=-=-=-=-=
# Input files
ECHO_LOG "#===> ............ INPUT ................................................."
ECHO_LOG "#===> EST_IADPERICASE0 ............: ${EST_IADPERICASE0}"
ECHO_LOG "#===> EST_IAVPERICASE0 ............: ${EST_IAVPERICASE0}"
ECHO_LOG "#===> EST_FCESSION0 ............: ${EST_FCESSION0}"
ECHO_LOG "#===> EST_FCPLACC0 ............: ${EST_FCPLACC0}"
ECHO_LOG "#===> EST_FPLACEMT0 ............: ${EST_FPLACEMT0}"
ECHO_LOG "#===> ............ OUTPUT ................................................."
# Output files
ECHO_LOG "#===> EST_IADVPERICASE ............: ${EST_IADVPERICASE}"
ECHO_LOG "#===> EST_FCESSION ............: ${EST_FCESSION}"
ECHO_LOG "#===> EST_FCPLACC ............: ${EST_FCPLACC}"
ECHO_LOG "#===> EST_FPLACEMT ............: ${EST_FPLACEMT}"
#-=-=-=-=-=-=-=-=-=-=-=
#
# Job launched by ESFD0560.cmd
#
# Launch C programs ESTC2303 ESTC2304
#
#-----------------------------------------------------------------------------
# historiques des modifications :
#
#[001] HR SPIRA 104182 : IFRS17 Life - Manage Pericase by Norm
#[002] S.Behague spira 109652 : AE SAS missing on Retro contract with sections greater than 9
#[002] 15/01/2025 S.Behague : SPIRA 111434 - [OMEGA Life] FWH - Accrual adjustment
#[003] 19/01/2025 S.Behague : US7172 - L&H- FWH accruals complement- Accounting extraction issue
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Job Initialisation
JOBINIT

CLODAT_D=$1
PSTOMGEND17_D=$2
PARM_CRE_D=$3

NSTEP=${NJOB}_05
# Mix of acceptance life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of IADPERICASE0 and IAVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0} 1000 1"
SORT_I2="${EST_IAVPERICASE0} 1000 1"
SORT_O="${EST_IADVPERICASE} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
				CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:,
        SECINC_D 78:1 - 78: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SECINC_D <= ${CLODAT_D}
/INCLUDE INVENTAIRE
exit
EOF
SORT


NSTEP=${NJOB}_10
#EST_FCPLACC screen on the subsidary
#-----------------------------------------------------------------------------
LIBEL="EST_FCPLACC0 ==> EST_FCPLACC ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCPLACC0} 1000 1"
SORT_O="${EST_FCPLACC} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_15
# EST_FCESSION0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FCESSION0 ==> EST_FCESSION ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCESSION0} 1000 1"
SORT_O="${EST_FCESSION} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 14:1 - 14: EN,
				CTR_NF 1:1 - 1:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_20
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new cession file..."
PRG=ESTC2301
export ${PRG}_I1=${EST_IADVPERICASE}
export ${PRG}_I2=${EST_FCESSION}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_CES_NEW.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETNP_SEGMENT_O.dat
EXECPRG


NSTEP=${NJOB}_30
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting new cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_20_${IB}_ESTC2301_CES_NEW.dat
SORT_O="${EST_FCES} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: ,
        SEC_NF 3:1 - 3: ,
        UWY_NF 4:1 - 4: ,
        UW_NT 5:1 - 5: ,
        RETCTR_NF 6:1 - 6:,
        RETEND_NT 7:1 - 7: ,
        RETSEC_NF 8:1 - 8: ,
        RTY_NF 9:1 - 9: ,
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
/CONDITION RETRO RETCTR_NF EQ ""
/OMIT RETRO
exit
EOF
SORT


#[[001]
NSTEP=${NJOB}_30
# Mix of retrocession life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of IRDPERICASE0 and IRVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0} 1000 1"
SORT_I2="${EST_IRVPERICASE0} 1000 1"
SORT_O="${EST_IRDVPERICASE0} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_35
#EST_IRDVPERICASE0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_IRDVPERICASE0 ==> EST_IRDVPERICASE ..."
# [009] Exclusion des contrats Retro Clos
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_IRDVPERICASE0 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        TERCTR_B 192:1 - 192:
/CONDITION CONTRATCLOS (TERCTR_B != "1")
/INCLUDE CONTRATCLOS
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_40
#EST_IRDVPERICASE0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_IRDVPERICASE0 ==> EST_IRDVPERICASE ..."
# [009] [011] Exclusion des contrats Retro Clos
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_SORT_IRDVPERICASE0 1000 1"
SORT_O="${EST_IRDVPERICASE} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_45
#-----------------------------------------------------------------------------
LIBEL="EST_FPLACEMT0 ==> EST_FPLACEMT..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMT0} 1000 1"
SORT_O="${EST_FPLACEMT} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4: ,
        RETSEC_NF 5:1 - 5: ,
        RTY_NF 6:1 - 6: ,
        RETUW_NT 7:1 - 7:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
exit
EOF
SORT


NSTEP=${NJOB}_50
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new placement file..."
PRG=ESTC2302
export ${PRG}_I1=${EST_IRDVPERICASE}
export ${PRG}_I2=${EST_FPLACEMT}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PLC_O.dat
EXECPRG


NSTEP=${NJOB}_55
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting new placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_50_${IB}_ESTC2302_PLC_O.dat
SORT_O="${EST_FPLC} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4: ,
        RETSEC_NF 5:1 - 5: ,
        RTY_NF 6:1 - 6: ,
        RETUW_NT 7:1 - 7: ,
        PLC_NT 8:1 - 8:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT,
      PLC_NT
exit
EOF
SORT

ECHO_LOG "#===> PARM_PSTOMGEND17_D............................: ${PARM_PSTOMGEND17_D}"
ECHO_LOG "#===> PSTOMGEND17_D.................................: ${PSTOMGEND17_D}"
ECHO_LOG "#===> PARM_REQCOD_CT................................: ${PARM_REQCOD_CT}"
ECHO_LOG "#===> PARM_CRE_D....................................: ${PARM_CRE_D}"

#[001] step 60 to 95
NSTEP=${NJOB}_60
# Extracting data from Table TI17CLOPER Parent
#------------------------------------------------------------------------------
LIBEL="Extracting data from Table TI17CLOPER Parent"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TI17CLOPER_I17P.dat
BCP_QRY="execute BEST..PsTI17CLOPER_02 'I17P', '${PSTOMGEND17_D}', '${PARM_REQCOD_CT}', '${PARM_CRE_D}'"
BCP

NSTEP=${NJOB}_70
# Extracting data from Table TI17CLOPER Local
#------------------------------------------------------------------------------
LIBEL="Extracting data from Table TI17CLOPER Local"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TI17CLOPER_I17L.dat
BCP_QRY="execute BEST..PsTI17CLOPER_02 'I17L', '${PSTOMGEND17_D}', '${PARM_REQCOD_CT}', '${PARM_CRE_D}'"
BCP

NSTEP=${NJOB}_80
# FILTER PERIMETER WITH TI17CLOPER Parent
#------------------------------------------------------------------------------
LIBEL="FILTER IADVPERICASE PERIMETER WITH TI17CLOPER Parent"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE} 1000 1"
SORT_O="${EST_IADVPERICASE_I17P} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        SSD_NF                                  1:1 - 1:,
        ESB_CF                                  2:1 - 2:,
        CP_SSD_NF                               1:1 - 1:,
        CP_ACCESB_CF                            8:1 - 8:,
        IADVPERICASE                            1:1 - 206:
/joinkeys
        CP_SSD_NF,
        CP_ACCESB_CF
/INFILE ${DFILT}/${NJOB}_60_${IB}_BCP_TI17CLOPER_I17P.dat 2000 1 "~"
/joinkeys
        SSD_NF,
        ESB_CF
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: IADVPERICASE
exit
EOF
SORT

NSTEP=${NJOB}_85
# FILTER IADVPERICASE PERIMETER WITH TI17CLOPER Local
#------------------------------------------------------------------------------
LIBEL="FILTER IADVPERICASE PERIMETER WITH TI17CLOPER Local"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE} 1000 1"
SORT_O="${EST_IADVPERICASE_I17L} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        SSD_NF                                  1:1 - 1:,
        ESB_CF                                  2:1 - 2:,
        CP_SSD_NF                               1:1 - 1:,
        CP_ACCESB_CF                            8:1 - 8:,
        IADVPERICASE                            1:1 - 206:
/joinkeys
        CP_SSD_NF,
        CP_ACCESB_CF
/INFILE ${DFILT}/${NJOB}_70_${IB}_BCP_TI17CLOPER_I17L.dat 2000 1 "~"
/joinkeys
        SSD_NF,
        ESB_CF
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: IADVPERICASE
exit
EOF
SORT

NSTEP=${NJOB}_90
# FILTER IRDVPERICASE PERIMETER WITH TI17CLOPER Parent
#------------------------------------------------------------------------------
LIBEL="FILTER PERIMETER WITH TI17CLOPER Parent"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE} 2000 1"
SORT_O="${EST_IRDVPERICASE_I17P} OVERWRITE 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        SSD_NF                                  1:1 - 1:,
        ESB_CF                                  2:1 - 2:,
        CP_SSD_NF                               1:1 - 1:,
        CP_ACCESB_CF                            8:1 - 8:,
        IRDVPERICASE                            1:1 - 206:
/joinkeys
        CP_SSD_NF,
        CP_ACCESB_CF
/INFILE ${DFILT}/${NJOB}_60_${IB}_BCP_TI17CLOPER_I17P.dat 2000 1 "~"
/joinkeys
        SSD_NF,
        ESB_CF
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: IRDVPERICASE
exit
EOF
SORT

NSTEP=${NJOB}_95
# FILTER IRDVPERICASE PERIMETER WITH TI17CLOPER Local
#------------------------------------------------------------------------------
LIBEL="FILTER IRDVPERICASE PERIMETER WITH TI17CLOPER Local"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE} 2000 1"
SORT_O="${EST_IRDVPERICASE_I17L} OVERWRITE 2000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        SSD_NF                                  1:1 - 1:,
        ESB_CF                                  2:1 - 2:,
        CP_SSD_NF                               1:1 - 1:,
        CP_ACCESB_CF                            8:1 - 8:,
        IRDVPERICASE                            1:1 - 206:
/joinkeys
        CP_SSD_NF,
        CP_ACCESB_CF
/INFILE ${DFILT}/${NJOB}_70_${IB}_BCP_TI17CLOPER_I17L.dat 2000 1 "~"
/joinkeys
        SSD_NF,
        ESB_CF
/OUTFILE ${SORT_O}
/REFORMAT
        leftside: IRDVPERICASE
exit
EOF
SORT


NSTEP=${NJOB}_100
#---------------------------------------------------------------
LIBEL="Extraction of modeling type for contracts"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_MODELINGTYPE}
BCP_QRY="exec BEST..PsTSECTIONDYNVAL_01 "
BCP


NSTEP=${NJOB}_110
#---------------------------------------------------------------
LIBEL="Extraction of TCUR table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCUR}
BCP_QRY="exec BEST..PsTCUR_01"
BCP


NSTEP=${NJOB}_120
#---------------------------------------------------------------
LIBEL="Extraction of TACCTRN table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FTACCTRNFWH}
BCP_QRY="exec BCTA..PsTACCTRNFWH_01"
BCP


NSTEP=${NJOB}_195
# Rm of temporary files
#-----------------------------------------------------------------------------
LIBEL="Erase temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND

