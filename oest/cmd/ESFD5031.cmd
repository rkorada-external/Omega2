#!/bin/ksh
#=================================================================================
# nom de l'application          : IRFS17 night closing
# nom du script SHELL           : ESFD5031.cmd
# revision                      : $Revision:   1.0 $
# date de creation              : 28\09\2022
# auteur                        : Florian CULIOLI
#---------------------------------------------------------------------------------
# description
# Onerous Q+1
#  Generation of a row a pericase INI INV/POS
#
#---------------------------------------------------------------------------------
# Fix ITK ISSU on step _30
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
ECHO_LOG "#===> QUARTER_END_FOUND..................................................: ${QUARTER_END_FOUND}"
ECHO_LOG "#===> PARM_IS_TRN........................................................: ${PARM_IS_TRN}"
ECHO_LOG "#====================================INPUT FILE=========================="
ECHO_LOG "#===> EST_FCURQUOT.......................................................: ${EST_FCURQUOT}"
ECHO_LOG "#====================================OUTPUT FILE=========================="
ECHO_LOG "#===> EST_IADPERICASE_INI................................................: ${EST_IADPERICASE_INI}"
ECHO_LOG "#===> EST_IADPERICASE0_INI...............................................: ${EST_IADPERICASE0_INI}"
ECHO_LOG "#========================================================================="

# comments to delete
#Step 10                       >> Step 40  > EST_IADPERICASE_DUMMY_INI to delete
#Step 15 >> Step 20 >> Step 35 >> Step 40
#Step 25 >> Step 30 >> Step 35 >> Step 40
#                              >> Step 40 >> Step 45 > EST_IADPERICASE0_INI
#                                         >> Step 45 >> Step 50 >> Step 55 > EST_IADPERICASE_INI



NSTEP=${NJOB}_05

# START CONCURRENT STEPS
#--------------------------
PARALLEL_INIT  2
#

NSTEP=${NJOB}_10
#Download to the file, the fields necessary to the
#facultatives ini perimeter 
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Facs Ini Perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_INI_FAC_O_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat
BCP_QRY="execute BEST..PsPeriFacIni_02 '${PARM_ICLODAT_D}', ${X_DAYS}, '${PARM_SEGTYP_CT}', '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}' with recompile"
PARALLEL BCP


NSTEP=${NJOB}_15
#Download to the file, the fields necessary to the
#Treaty perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Treaties Ini Perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_INI_TRT_O_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat
BCP_QRY="execute BEST..PsPeriTrtIni_02 '${PARM_ICLODAT_D}', ${X_DAYS}, '${PARM_SEGTYP_CT}', '${NORME_CF}', '${QUARTER_END_FOUND}', '${PARM_IS_TRN}' with recompile"
PARALLEL BCP

# END CONCURRENT STEPS
# -------------------------
PARALLEL_END

NSTEP=${NJOB}_20
#Treaties Perimeter File Sort by Contract/Endorsement/UW Year
#-----------------------------------------------------------------------------
LIBEL="Current Sort of Treaties perimeter file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_BCP_PERICASE_INI_TRT_O_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORTED_BCP_PERICASE_INI_TRT_O_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat 1000 1"
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

NSTEP=${NJOB}_25
#Download to the file of charges reiterated without date condition and used for the CTBCOM_B
#Field Calculation for future treaties.
#-----------------------------------------------------------------------------
LIBEL="Current Generation of reiterated Charges file without date condition..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FAMCHG2FUTURE_O.dat
BCP_QRY="execute BEST..PsSECTION_future_02 '${PARM_ICLODAT_D}'"
BCP

NSTEP=${NJOB}_30
#Sort of reiterated charges file by Contract/Endorsement/UW Year
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Reiterated charges file Sort..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_BCP_FAMCHG2FUTURE_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORTED_BCP_FAMCHG2FUTURE_O.dat 1000 1"
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
/OUTFILE  ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_35
#Field CTBCOM_B first part Calculation for Treaties Perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Calculation of field CTBCOM_B 1/2 of Treaties perimeter..."
PRG=ESTC0104
export ${PRG}_I1=${DFILT}/${NJOB}_20_${IB}_SORTED_BCP_PERICASE_INI_TRT_O_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat
export ${PRG}_I2=${DFILT}/${NJOB}_30_${IB}_SORTED_BCP_FAMCHG2FUTURE_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASE_INI_TRT_O_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat
EXECPRG

NSTEP=${NJOB}_40
#Merge and Sort of FAC and TRT perimeter files by Contract/Endorsement/Section/UW Year/UW_NT
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Fusion..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_BCP_PERICASE_INI_FAC_O_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_35_${IB}_ESTC0104_PERICASE_INI_TRT_O_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_INI_O_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat 1000 1"
SORT_O2="${EST_IADPERICASE_DUMMY_INI} 1000 1"
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
/CONDITION  CTR_DUMMY UWORG_CF = "248"
/OUTFILE  ${SORT_O}
/OUTFILE  ${SORT_O2} OVERWRITE
/INCLUDE CTR_DUMMY

exit
EOF
SORT

NSTEP=${NJOB}_45
#Perimeter Fields Update
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters Fields Update..."
PRG=ESTC0103
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_PERICASE_INI_O_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat
export ${PRG}_I2=${EST_FCURQUOT}
export ${PRG}_O1=${EST_IADPERICASE0_INI}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_IAVPERICASE_INI_ENTIER0_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat
EXECPRG

NSTEP=${NJOB}_50
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Creation du fichier perimetre Non Vie : "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0_INI} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR1_NF      3:1 -  3:1,
        CTR3_NF      3:3 -  3:3,
        SECSTS_CT   79:1 - 79:,
        CTRSTS_CT   99:1 - 99:,
       LOB_CF      38:1 - 38:
/CONDITION ANCIEN_PERIMETRE ( ( ( CTR3_NF >= "A" and CTR3_NF <= "M" ) OR CTR1_NF = "F" )  or 
                              ( ( CTR3_NF >= "N" and CTR3_NF <= "Z" ) OR CTR1_NF = "T" )
                            )
/OUTFILE ${SORT_O}
/INCLUDE ANCIEN_PERIMETRE
exit
EOF
SORT

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> EST_SORT_CONDITION.................................................: ${EST_SORT_CONDITION}"
ECHO_LOG "#========================================================================="

NSTEP=${NJOB}_55
# perimeter screen for the subsidary and the section incoming date
#-----------------------------------------------------------------------------
LIBEL="IADPERICASE perimeter ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_IADPERICASE_${NORME_CF}_${PARM_ICLODAT_D}_${TYPEINV}.dat 1000 1"
SORT_O="${EST_IADPERICASE_INI} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        SSD_CF 1:1 - 1: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/OUTFILE ${SORT_O}
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE
exit
EOF
SORT


JOBEND
