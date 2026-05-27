#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS -  
#                                 Extract files to merge 
#				  Batch quotidien
# nom du script SHELL		: ESGD2561.cmd
# revision
# date de creation		: 16/07/2025
# auteur			: M.NAJI
# references des specifications	:
#-----------------------------------------------------------------------------
# description
#
# launched by ESGD2560.cmd
#-----------------------------------------------------------------------------
# historiques des modifications :
#
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get input parameters

# Job Initialisation
JOBINIT

SSD_CF=00
SEGTYP_CT=A


NSTEP=${NJOB}_085
#Download to the XADPERIFCT Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCT perimeter File... ESCJ0661_085"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_IADPERIFCT0}
BCP_QRY="execute BEST..PsSECTION_05 '${SEGTYP_CT}', ${SSD_CF}, '${PARM_CRE_D}' with recompile"
BCP

#-------------------------------------------------------------------------------------------------------------------------
#----------------------------------------- EST_IADVPERICASE
#-------------------------------------------------------------------------------------------------------------------------



NSTEP=${NJOB}_010
#Download to the file, the fields necessary to the
#facultatives perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Facs Perimeter...  ESCJ0661_190"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASEFAC_O.dat
# [005]
if [ ${TYPEINV} = "POS" ]
then
  BCP_QRY="execute BEST..PsPERIFAC_02 '${SEGTYP_CT}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
else
  BCP_QRY="execute BEST..PsPERIFAC_02 '${SEGTYP_CT}' with recompile"
fi
BCP


NSTEP=${NJOB}_020
#Constituting treaty perimeter file with BTRT database fields
#In case of subsidary 00, all the subsidaries are taken into account
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Treaties perimeter... ESCJ0661_095"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASETRT_O.dat
# [005]
if [ ${TYPEINV} = "POS" ]
then
#[009]
  BCP_QRY="execute BEST..PsPERITRT_02 '${SEGTYP_CT}', '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}', '${TYPEINV}' with recompile"
else
  BCP_QRY="execute BEST..PsPERITRT_02 '${SEGTYP_CT}' with recompile"
fi
BCP


NSTEP=${NJOB}_030
#Treaties Perimeter File Sort by Contract/Endorsement/UW Year
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Sort of Treaties perimeter file... ESCJ0662_10"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_020_${IB}_BCP_PERICASETRT_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASETRT_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      END_NT,
      UWY_NF,
      UW_NT,
      SEC_NF
/OUTFILE  ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_040
#Download to the file of charges reiterated and used for the CTBCOM_B
#Field Calculation for treaties.
#-----------------------------------------------------------------------------
LIBEL="Current Generation of reiterated Charges file... ESCJ0661_115"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FAMCHG2_O.dat
BCP_QRY="execute BEST..PsSECTION_09 ${SSD_CF}, '${CRE_D}'"
BCP




NSTEP=${NJOB}_050
#Sort of reiterated charges file by Contract/Endorsement/UW Year
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Reiterated charges file Sort... ESCJ0662_20"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_040_${IB}_BCP_FAMCHG2_O.dat
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_FAMCHG2_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        CHGLIN_NT 6:1 - 6:
/KEYS CTR_NF,
      END_NT,
      UWY_NF,
      UW_NT,
      SEC_NF,
      CHGLIN_NT
exit
EOF
SORT






NSTEP=${NJOB}_060
#Field CTBCOM_B first part Calculation for Treaties Perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Calculation of field CTBCOM_B 1/2 of Treaties perimeter..."
PRG=ESTC0104
export ${PRG}_I1=${DFILT}/${NJOB}_030_${IB}_SORT_PERICASETRT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_050_${IB}_SORT_FAMCHG2_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASETRT_O.dat
EXECPRG




NSTEP=${NJOB}_070
#Merge and Sort of perimeter files by Contract/Endorsement/UW Year
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Fusion... ESCJ0662_40"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_060_${IB}_ESTC0104_PERICASETRT_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_010_${IB}_BCP_PERICASEFAC_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_O.dat 1000 1"
SORT_O2="${EST_IADPERICASE_DUMMY} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4: EN,
        SEC_NF 5:1 - 5: EN,
        UWY_NF 6:1 - 6: EN,
        UW_NT 7:1 - 7: EN,
        UWORG_CF 119:1 - 119:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION  CTR_NOT_DUMMY UWORG_CF != "248"
/CONDITION  CTR_DUMMY UWORG_CF = "248"
/OUTFILE  ${SORT_O}
/INCLUDE CTR_NOT_DUMMY
/OUTFILE  ${SORT_O2}
/INCLUDE CTR_DUMMY
exit
EOF
SORT


NSTEP=${NJOB}_080
#Perimeter Fields Update
#[001]${EST_IADPERICASE0} et ${EST_IAVPERICASE0} devient le perimetre complet.
#[003]
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters Fields Update... ESCJ0662_55"
PRG=ESTC0103
export ${PRG}_I1=${DFILT}/${NJOB}_070_${IB}_SORT_PERICASE_O.dat
export ${PRG}_I2=${EST_FCURQUOT}
export ${PRG}_O1=${EST_IADPERICASE_ENTIER0}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_SORT_IAVPERICASE0_O.dat
EXECPRG


NSTEP=${NJOB}_100
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Creation du fichier perimetre Non Vie : ESCJ0662_60 "

SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE_ENTIER0} 1000 1"
SORT_O=${EST_IADPERICASE0}
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR1_NF      3:1 -  3:1,
        CTR3_NF      3:3 -  3:3,
        SECSTS_CT   79:1 - 79:,
        CTRSTS_CT   99:1 - 99:,
       LOB_CF      38:1 - 38:
/CONDITION ANCIEN_PERIMETRE ( ( ( CTR3_NF >= "A" and CTR3_NF <= "M" ) OR CTR1_NF = "F" )  or
                              ( ( ( CTR3_NF >= "N" and CTR3_NF <= "Z" ) OR CTR1_NF = "T" )  and
                                ( ( ( SECSTS_CT = "14" or SECSTS_CT = "16" or SECSTS_CT = "17" or SECSTS_CT = "19" ) or
                                    ( SECSTS_CT = "14" and ( LOB_CF = "30" or LOB_CF = "31" ) ) )    and
                                  ( ( CTRSTS_CT = "14" or CTRSTS_CT = "16" or CTRSTS_CT = "17" or CTRSTS_CT = "19" ) or
                                    ( CTRSTS_CT = "14" and ( LOB_CF = "30" or LOB_CF = "31" ) ) ) ) ) )
/OUTFILE ${SORT_O}
/INCLUDE ANCIEN_PERIMETRE
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_110
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Creation du fichier perimetre Vie : ESCJ0662_65 "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_080_${IB}_SORT_IAVPERICASE0_O.dat 1000 1"
SORT_O=${EST_IAVPERICASE0}
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR3_NF      3:3 -  3:3,
        SECSTS_CT   79:1 - 79:,
        CTRSTS_CT   99:1 - 99:,
       LOB_CF      38:1 - 38:
/CONDITION ANCIEN_PERIMETRE ( SECSTS_CT = "14" or SECSTS_CT = "16" or SECSTS_CT = "17" or SECSTS_CT = "19" or SECSTS_CT = "23" )
/OUTFILE ${SORT_O}
/INCLUDE ANCIEN_PERIMETRE
/COPY
exit
EOF
SORT


NSTEP=${NJOB}_120
# Mix of acceptance life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of IADPERICASE0 and IAVPERICASE0 perimeters ... ESCJ0662_70"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0} 1000 1"
SORT_I2="${EST_IAVPERICASE0} 1000 1"
SORT_O="${EST_IADVPERICASE} OVERWRITE 1000 1"
SORT_O="${EST_IADVPERICASE0} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
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




#-------------------------------------------------------------------------------------------------------------------------
#----------------------------------------- EST_FCES
#-------------------------------------------------------------------------------------------------------------------------


NSTEP=${NJOB}_130
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession Cessions File ESCJ0661_205"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FCESSION0}
BCP_QRY="execute BEST..PsCESSION_01"
BCP

NSTEP=${NJOB}_140
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting acceptance perimeter file... ESCJ0663_5"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE0} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_IADVPERICASE_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT




NSTEP=${NJOB}_150
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting cession file... ESCJ0663_10"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FCESSION0} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_CES_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT





NSTEP=${NJOB}_160
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new cession file... ESCJ0663_10"
PRG=ESTC2301
export ${PRG}_I1=${DFILT}/${NJOB}_140_${IB}_SORT_IADVPERICASE_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_150_${IB}_SORT_CES_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_ESTC2301_CES_O.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_RETNP_SEGMENT_O.dat    #[001]
EXECPRG




NSTEP=${NJOB}_170
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting new cession file... ESCJ0663_30"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_160_${IB}_ESTC2301_CES_O.dat 1000 1"
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


#-------------------------------------------------------------------------------------------------------------------------
#----------------------------------------- EST_FPLC
#-------------------------------------------------------------------------------------------------------------------------


NSTEP=${NJOB}_180
# Begin Bcp
#------------------------------------------------------------------------------
LIBEL="Generation of Retrocession placements File ESCJ0661_025"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FPLACEMT0}
BCP_QRY="execute BEST..PsPLACEMT_01"
BCP



NSTEP=${NJOB}_190
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting placement file... ESCJ0662_175"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLACEMT0} 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PLC_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:,
        RETEND_NT 4:1 - 4: ,
        RETSEC_NF 5:1 - 5: ,
        RTY_NF 6:1 - 6: ,
        RETUW_NT 7:1 - 7:
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RTY_NF,
      RETUW_NT
exit
EOF
SORT


NSTEP=${NJOB}_193
#Generation of IRVPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRVPERICASE Perimeter File... ESCJ0661.cmd _135"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_O.dat
BCP_QRY="execute BEST..PsSECTION_21 '${SEGTYP_CT}', ${SSD_CF}"
BCP

NSTEP=${NJOB}_195
#Generation of IRDPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRDPERICASE Perimeter File... ESCJ0661.cmd _100"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE0_O.dat
# [005]
if [ ${TYPEINV} = "POS" ]
then
  BCP_QRY="execute BEST..PsSECTION_08 '${SEGTYP_CT}', ${SSD_CF}, '${PARM_ICLODAT_D}', ${X_DAYS}, '${NORME_CF}', '${QUARTER_END_FOUND}'"
else
  BCP_QRY="execute BEST..PsSECTION_08 '${SEGTYP_CT}', ${SSD_CF}, '${PARM_ICLODAT_D}'"
fi
BCP

NSTEP=${NJOB}_197
# Mix of retrocession life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of IRDPERICASE0 and IRVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_193_${IB}_BCP_PERICASE_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_195_${IB}_BCP_PERICASE0_O.dat 1000 1"
SORT_O="${EST_IRDVPERICASE} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT  7:1 - 7:,
        TERCTR_B 192:1 - 192:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION CONTRATCLOS (TERCTR_B != "1")
/INCLUDE CONTRATCLOS
exit
EOF
SORT


NSTEP=${NJOB}_200
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new placement file... ESCJ0662_180"
PRG=ESTC2302
export ${PRG}_I1=${EST_IRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_190_${IB}_SORT_PLC_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PLC_O.dat
EXECPRG



NSTEP=${NJOB}_210
# Begin Sort
# Warning : do not remove this step!!!
# All other steps using the file EST_FPLC assume that it is already
# sorted according to retctr_nf/retend_nt/retsec_nf/rty_nf/retuw_nt/plc_nt
#-----------------------------------------------------------------------------
LIBEL="Sorting new placement file... ESCJ0662_185"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_ESTC2302_PLC_O.dat 1000 1"
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




#### [037] [039] Desact ==>
##
NSTEP=${NJOB}_240
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Extraction des donn�es pour l'application de la Taxe Retro Management ESPD0061.cmd _295 "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${ESF_TAXRETMGNT}
BCP_QRY="execute BEST..PsTAXRETMGT  '${PARM_ICLODAT_D}' "
BCP

JOBEND
