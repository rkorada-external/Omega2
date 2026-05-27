#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESCJ0662.cmd
# revision                      : 
# date de creation              : 06/09/2021
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Extraction quatidienne des  fichiers
#
# job launched by ESCJ0000.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Creation	    : 
#Auteur         : M.NAJI
#Date           : 06/09/2021
#Version        : 1.0
#Description    :Extraction quatidienne des  fichiers
#===============================================================================
#[001] 06/09/2021  :spira:91532 Création
#[002] 31/05/2022 RC  :spira:104409 Gestion de la mise à jour de BEST..TCTRGRO pour EBS/POS
#[003] 06/07/2022 MZM  :spira:104409 Fix Issu Step 250
#[004] 24/08/2022 J.B-D  :spira:105393 add PRS filter step 200
#[005] 08/11/2022 DAD  :spira:107518 Generate IADPERICASE DUMMY STD
#[006] 17/11/2022 JYP  :spira:107588 regression IFRS4 ratio from spira 104409
#[007] 11/04/2023 DAD  :spira:108809 Generate SSDS for CTRGRO Onerous
#[008] 18/06/2024 JYP  :spira:111723 use parameter U to update TSEGEST
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

ICLODAT_D=$1


NSTEP=${NJOB}_05
#EST_FPLACEMT0 screen
#-----------------------------------------------------------------------------
LIBEL="EST_FPLATXCUM0 ==> EST_FPLATXCUM..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FPLATXCUM0} 1000 1"
SORT_O="${EST_FPLATXCUM} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS RETCTR_NF 1:1 - 1:,
        RETSEC_NF 2:1 - 2: EN,
        RTY_NF    3:1 - 3:,
        PLC_NF    4:1 - 4:
/KEYS RETCTR_NF,
      RTY_NF,
      RETSEC_NF,
      PLC_NF
exit
EOF
SORT


# Processing for Treaties Perimeter

NSTEP=${NJOB}_10
#Treaties Perimeter File Sort by Contract/Endorsement/UW Year
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Sort of Treaties perimeter file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESCJ0661_095_${IB}_BCP_PERICASETRT_O.dat 1000 1"
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



NSTEP=${NJOB}_20
#Sort of reiterated charges file by Contract/Endorsement/UW Year
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Reiterated charges file Sort..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NCHAIN}_ESCJ0661_115_${IB}_BCP_FAMCHG2_O.dat
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

NSTEP=${NJOB}_30
#Field CTBCOM_B first part Calculation for Treaties Perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Calculation of field CTBCOM_B 1/2 of Treaties perimeter..."
PRG=ESTC0104
export ${PRG}_I1=${DFILT}/${NJOB}_10_${IB}_SORT_PERICASETRT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_20_${IB}_SORT_FAMCHG2_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASETRT_O.dat
EXECPRG


#[005]
NSTEP=${NJOB}_40
#Merge and Sort of perimeter files by Contract/Endorsement/UW Year
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Fusion..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_ESTC0104_PERICASETRT_O.dat 1000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESCJ0661_190_${IB}_BCP_PERICASEFAC_O.dat 1000 1"
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



NSTEP=${NJOB}_55
#Perimeter Fields Update
#[001]${EST_IADPERICASE0} et ${EST_IAVPERICASE0} devient le perimetre complet.
#[003]
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters Fields Update..."
PRG=ESTC0103
export ${PRG}_I1=${DFILT}/${NJOB}_40_${IB}_SORT_PERICASE_O.dat
export ${PRG}_I2=${EST_FCURQUOT}
export ${PRG}_O1=${EST_IADPERICASE_ENTIER0}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_SORT_IAVPERICASE0_O.dat
EXECPRG

#[001] Le vrai fichier perimetre est cr▒▒ dans le ESID1001 en concat▒nant les EST_IAVPERICASE0 et EST_IADPERICASE0.
#[005]
NSTEP=${NJOB}_60
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Creation du fichier perimetre Non Vie : "
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

#[001] Le vrai fichier perimetre est cr▒▒ dans le ESID1001 en concat▒nant les EST_IAVPERICASE0 et EST_IADPERICASE0.
#[003]
NSTEP=${NJOB}_65
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Creation du fichier perimetre Vie : "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_SORT_IAVPERICASE0_O.dat 1000 1"
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


NSTEP=${NJOB}_70
# Mix of acceptance life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of IADPERICASE0 and IAVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0} 1000 1"
SORT_I2="${EST_IAVPERICASE0} 1000 1"
SORT_O="${EST_IADVPERICASE} OVERWRITE 1000 1"
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


NSTEP=${NJOB}_75
#Merge and Sort of perimeter files by Contract/Endorsement/Section/UW Year
# and UW Year sequence number
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Fusion..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESCJ0661_125_${IB}_BCP_PERICASETRT_O.dat 1000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESCJ0661_130_${IB}_BCP_PERICASEFAC_O.dat 1000 1"
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_O.dat
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:, UWORG_CF 119:1 - 119:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
/CONDITION  CTR_NOT_DUMMY UWORG_CF != "248"
/OUTFILE  ${SORT_O}
/INCLUDE CTR_NOT_DUMMY
exit
EOF
SORT

NSTEP=${NJOB}_80
#Perimeter Fields Update
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters Fields Update..."
PRG=ESTC0103
export ${PRG}_I1=${DFILT}/${NJOB}_75_${IB}_SORT_PERICASE_O.dat
export ${PRG}_I2=${EST_FCURQUOT}
export ${PRG}_O1=${EST_OADPERICASE0}
export ${PRG}_O2=${EST_OAVPERICASE0}
EXECPRG



NSTEP=${NJOB}_85
# Mix of acceptance life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of IADPERICASE0 and IAVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_OADPERICASE0} 1000 1"
SORT_I2="${EST_OAVPERICASE0} 1000 1"
SORT_O="${EST_OADVPERICASE0} OVERWRITE 1000 1"
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




#[[001]
NSTEP=${NJOB}_90
# Mix of retrocession life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of IRDPERICASE0 and IRVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDPERICASE0} 1000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESCJ0661_135_${IB}_BCP_PERICASE_O.dat 1000 1"
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


NSTEP=${NJOB}_92
# Mix of retrocession life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of IRDPERICASE0 and IRVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE0} 1000 1"
SORT_O="${EST_IRDVPERICASE} OVERWRITE 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        TERCTR_B 192:1 - 192:
/CONDITION CONTRATCLOS (TERCTR_B != "1")
/INCLUDE CONTRATCLOS
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_95
# Mix of retrocession life and non-life perimeters
#-----------------------------------------------------------------------------
LIBEL="Current mix of ORDPERICASE0 and ORVPERICASE0 perimeters ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESCJ0661_150_${IB}_BCP_PERICASE_O.dat 1000 1"
SORT_I2="${DFILT}/${NCHAIN}_ESCJ0661_155_${IB}_BCP_PERICASE_O.dat 1000 1"
SORT_O="${EST_ORDVPERICASE0} OVERWRITE 1000 1"
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

NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="Merge of ORDVPERICASE0 and IRDVPERICASE0 Files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IRDVPERICASE} 1000 1"
SORT_I2="${EST_ORDVPERICASE0} OVERWRITE 1000 1"
SORT_O="${EST_OIRDVPERICASE} OVERWRITE 1000 1"
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
exit
EOF
SORT




NSTEP=${NJOB}_105
#IADPERICASE perimeter screen for the subsidary and the section incoming date
#-----------------------------------------------------------------------------
LIBEL="IADPERICASE perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE0} 1000 1"
SORT_O="${EST_IADPERICASE} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        END_NT 4:1 - 4:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:,
        UW_NT 7:1 - 7:,
        SSD_CF 1:1 - 1: EN,
        SECINC_D 78:1 - 78: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
/CONDITION SECINC_COND  SECINC_D <= ${ICLODAT_D}
/INCLUDE SECINC_COND
exit
EOF
SORT



NSTEP=${NJOB}_125
# EST_FVCTRGRO0
#-----------------------------------------------------------------------------
LIBEL="EST_FVCTRGRO0 ==> EST_FVCTRGRO"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FVCTRGRO0} 1000 1"
SORT_O="${EST_FVCTRGRO} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
        SSD_CF    5:1 - 5: EN,
        CTR_NF    1:1 - 1:,
        END_NT    2:1 - 2:,
        SEC_NF    3:1 - 3:,
        UWY_NF    21:1 - 21:,
        SEGTYP_CT 6:1 - 6:
/KEYS
      CTR_NF,
      END_NT,
      SEC_NF,
          UWY_NF
/CONDITION INVENTAIRE  SEGTYP_CT = "A"
/INCLUDE INVENTAIRE
exit
EOF
SORT




NSTEP=${NJOB}_135
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting commuted placement file ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLACEMTCOM}
SORT_O=${DFILT}/${NSTEP}_${IB}_SORT_PLCCOM_O.dat
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


NSTEP=${NJOB}_150
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new placement file..."
PRG=ESTC2302
export ${PRG}_I1=${EST_OIRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_135_${IB}_SORT_PLCCOM_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PLCCOM_O.dat
EXECPRG




NSTEP=${NJOB}_155
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting new placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_150_${IB}_ESTC2302_PLCCOM_O.dat
SORT_O="${EST_FPLCCOM} OVERWRITE"
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


# filte EST_IADPERICASE COND_UWORG != 253, 255 and 13
NSTEP=${NJOB}_160
#-----------------------------------------------------------------------------
LIBEL="filte EST_IADPERICASE COND_UWORG != 253, 255 and 13"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERICASE} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IADPERICASE_O2.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
                PER_SSD_CF                                              1:1 - 1: ,
        PER_CTR_NF                                              3:1 - 3:,
        PER_END_NT                                              4:1 - 4:,
        PER_SEC_NF                                              5:1 - 5:,
        PER_UWY_NF                                              6:1 - 6:,
        PER_UW_NT                                               7:1 - 7:,
                PER_CED_NF                                              12:1 - 12:,
                PER_PCPRSKTRY_CF                                52:1 - 52:,
                PER_LOB_CF                                              38:1 - 38:,
        PER_EGPCUR_CF                           23:1 - 23:,
                PER_CTRRET_B                                    20:1 - 20: ,
        PER_NAT_CF                                              49:1 - 49:  ,
                PER_SECACCSTS_CT                        77:1 - 77:,
                PER_CTRNAT_CT                                   85:1 - 85:,
                PER_UWORG_CF                                    119:1 - 119: ,
        BEFORE_PER_LOSCOREXI_B                  1:1 -  38:,
                PER_LOSCOREXI_B                         39:1 -  39:,
                AFTER_PER_LOSCOREXI_B                   40:1 -  206:,
                all_cols      
				1:1  - 206:
			
/CONDITION COND_PERM2 ( ( PER_UWORG_CF != "253" AND PER_UWORG_CF != "255" AND PER_UWORG_CF != "13")
                                          ) AND
                                          PER_SECACCSTS_CT != "9"
/CONDITION COND_PERM_TERM  ( ( PER_UWORG_CF != "253" AND PER_UWORG_CF != "255" AND PER_UWORG_CF != "13")
                                          ) AND
                                          PER_SECACCSTS_CT = "9"

/DERIVEDFIELD PER_LOSCOREXI_B_NEW if COND_PERM_TERM then "0" else PER_LOSCOREXI_B
/OUTFILE ${SORT_O}
/INCLUDE COND_PERM2
/REFORMAT
        BEFORE_PER_LOSCOREXI_B
        ,PER_LOSCOREXI_B_NEW
        ,AFTER_PER_LOSCOREXI_B
/COPY
exit
EOF
SORT


##[002] deplace dans ESCJ0663
#NSTEP=${NJOB}_165
##EST_FCTRGRO0 screen
##-----------------------------------------------------------------------------
#LIBEL="EST_FCTRGRO0 ==> EST_FCTRGRO ..."
#SORT_WDIR=${SORTWORK}
#SORT_CMD=`CFTMP`
#SORT_I="${EST_FCTRGRO0} 1000 1"
#SORT_O="${EST_FCTRGRO} OVERWRITE"
#INPUT_TEXT ${SORT_CMD} <<EOF
#/FIELDS SSD_CF 5:1 - 5: EN,
#        CTR_NF 1:1 - 1:,
#        END_NT 2:1 - 2:,
#        SEC_NF 3:1 - 3:,
#        UWY_NF 21:1 - 21:,
#        SEGTYP_CT 6:1 - 6:
#/KEYS CTR_NF,
#      END_NT,
#      SEC_NF,
#        UWY_NF
#/CONDITION INVENTAIRE ${EST_SORT_CONDITION} and SEGTYP_CT = "A"
#/INCLUDE INVENTAIRE
#exit
#EOF
#SORT
#
#
##[002] deplace dans ESCJ0663
#############################################################
## Comparison of period closing and segmentation perimeters #
#############################################################
#NSTEP=${NJOB}_170
##Comparison of period closing and segmentation perimeters
##(by the contract grouping file)
##-----------------------------------------------------------------------------
#LIBEL="Comparison of period closing process and segmentation perimeters ..."
#PRG=ESTM1004
#export ${PRG}_I1="${DFILT}/${NJOB}_160_${IB}_IADPERICASE_O2.dat"
#export ${PRG}_I2=${EST_FCTRGRO}
#export ${PRG}_O1=${EST_FCTRGRO1}
#export ${PRG}_O2=${EST_PERIANO}
#export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IADPERICASE.dat
#EXECPRG



NSTEP=${NJOB}_175
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="Sorting placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FPLACEMT0} 
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


NSTEP=${NJOB}_180
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Computing new placement file..."
PRG=ESTC2302
export ${PRG}_I1=${EST_IRDVPERICASE}
export ${PRG}_I2=${DFILT}/${NJOB}_175_${IB}_SORT_PLC_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PLC_O.dat
EXECPRG


NSTEP=${NJOB}_185
# Begin Sort
# Warning : do not remove this step!!!
# All other steps using the file EST_FPLC assume that it is already
# sorted according to retctr_nf/retend_nt/retsec_nf/rty_nf/retuw_nt/plc_nt
#-----------------------------------------------------------------------------
LIBEL="Sorting new placement file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_180_${IB}_ESTC2302_PLC_O.dat
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


NSTEP=${NJOB}_190
#-----------------------------------------------------------------------------
LIBEL="Current Sort of IRVPERICASE Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESCJ0661_045_${IB}_BCP_CRVPERICASE0_O.dat 1000 1"
SORT_O=${EST_CRVPERICASE0}
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS RETCTR_NF 3:1 - 3:, RETEND_NT 4:1 - 4:, RETSEC_NF 5:1 - 5:, RTY_NF 6:1 - 6:
/KEYS RETCTR_NF, RETEND_NT, RETSEC_NF, RTY_NF
exit
EOF
SORT


NSTEP=${NJOB}_195
#Tri du fichier FCTRULT par contrat/avenant/section/exercice/numero d'ordre
#-----------------------------------------------------------------------------
LIBEL="FCTRULT file sort in progress..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${EST_FCTRULT}
SORT_O="${EST_CTRULT02} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF  1:1 - 1:,
        END_NT  2:1 - 2:,
        SEC_NF  3:1 - 3:,
        UWY_NF  4:1 - 4:,
        UW_NT 5:1 - 5:
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_200
#[004]
#------------------------------------------------------------------------------
LIBEL="Split ${EST_FTRSLNK_TXT} and ${EST_FTRSLNK_640_TXT}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NCHAIN}_ESCJ0661_215_${IB}_FTRSLNK_TXT.dat 2000 1"
SORT_O="${EST_FTRSLNK_TXT} 2000 1 "
SORT_O2="${EST_FTRSLNK_640_TXT} 2000 1 "
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS PRS_CF       1:1 -  1:,
        ACMTRS_NT        2:1 -  2:,
        DETTRS_CF        3:1 -  3:
/KEYS
        PRS_CF,
        ACMTRS_NT,
        DETTRS_CF
/CONDITION IS_640 ( PRS_CF = "640" OR PRS_CF = "900" )
/OUTFILE ${SORT_O} OVERWRITE
/OMIT IS_640
/OUTFILE ${SORT_O2} OVERWRITE
/INCLUDE IS_640
exit
EOF
SORT

NSTEP=${NJOB}_205
# Bin to text FCURQUOT file
#--------------------------------------------------------------------------
LIBEL="Bin to texte FCURQUOT file"

FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
TYPE_NAME T_TCURQUOT
exit
EOF

DESC=$DFILT/${NSTEP}_${IB}_FCURQUOT_TXT.dat
INPUT_TEXT ${DESC} << EOF
char;c_ssd;1
char;sz_cur;4
short;s_uwy;1
double;d_quot;1
exit
EOF

PRG=BINTOTXT
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DESC}
export ${PRG}_I2=${EST_FCURQUOT}
export ${PRG}_O1=${EST_FCURQUOT_TXT}
EXECPRG

NSTEP=${NJOB}_210
#-----------------------------------------------------------------------------
LIBEL="Merge of OADVPERICASE and IADVPERICASE Files..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADVPERICASE} 1000 1"
SORT_I2="${EST_OADVPERICASE0} OVERWRITE 1000 1"
SORT_O="${EST_OIADVPERICASE} OVERWRITE 1000 1"
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
exit
EOF
SORT

NSTEP=${NJOB}_220
#-----------------------------------------------------------------------------
LIBEL="IADPERIFCT perimeter screen in progress ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IADPERIFCT0} 1000 1"
SORT_O="${EST_IADPERIFCT} OVERWRITE 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2:,
        SEC_NF 3:1 - 3:,
        UWY_NF 4:1 - 4:,
        UW_NT 5:1 - 5:,
        SSD_CF 7:1 - 7: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT


#[002] Step provenant de ESFD5012

if [ "${NORME_CF}" = "EBS" ] &&
	 [ "${TYPEINV}" = "POS" -o "${TYPEINV}" = "POC" ]
then
	NSTEP=${NJOB}_230
	# GENERATE IADPERICASE DELTA POS 
	#------------------------------------------------------------------------------
	LIBEL="GENERATE IADPERICASE DELTA POS"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${EST_IADPERICASE} 2000 1"
	SORT_O="${EST_IADPERICASE_DELTA_POS} 2000 1"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	CTR_NF 					3:1 - 3:,
	SEC_NF  				4:1 - 4:,
	UWY_NF 				5:1 - 5:,
	UW_NT  			6:1 - 6:,
	END_NT  			7:1 - 7:,
	FULL_PERICASE				1:1 - 209:
/joinkeys
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/INFILE ${EST_IADPERICASE_5010} 1000 1 "~"
/joinkeys 
	CTR_NF ,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/join unpaired leftside only
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside: FULL_PERICASE
exit
EOF
	SORT

    #[007]
    if [ ! -f ${EST_ONE_CTRGRO_POS} ]
    then
        NSTEP=${NJOB}_231
        LIBEL="MANAGE UNFOUND FILES" 
        ECHO_LOG "EST_ONE_CTRGRO_POS=${EST_ONE_CTRGRO_POS}  does not exist, take an empty file"
        EXECKSH "touch ${EST_ONE_CTRGRO_POS}"
    fi

    #[007]
    NSTEP=${NJOB}_235
    #-----------------------------------------------------------------------------
    LIBEL="Extract CTRGRO Onerous ${param_site_cf}"
    BCP_WAY="OUT"; BCP_VER="+"
    BCP_O=${DFILT}/${NSTEP}_${IB}_BEST_CTRGRO_ONE_BCP_O.dat
    BCP_QRY="exec BEST..PsTCTRGRO_ONE '${param_site_cf}'"
    BCP

    #[007]
    NSTEP=${NJOB}_236
	LIBEL="GENERATE CTRGRO ONE DELTA POS"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NJOB}_235_${IB}_BEST_CTRGRO_ONE_BCP_O.dat 2000 1"
	SORT_O="${DFILT}/${NSTEP}_${IB}_CTRGRO_ONE_DELTA_POS.dat 2000 1"
	INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF 		1:1 - 1:,
	CTR_NF 		3:1 - 3:,
	SEC_NF  	4:1 - 4:,
	UWY_NF 		5:1 - 5:,
	UW_NT  		6:1 - 6:,
	END_NT      7:1 - 7:,
	FULL		1:1 - 7:
/joinkeys
	SSD_CF,
	CTR_NF,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/INFILE ${EST_ONE_CTRGRO_POS} 1000 1 "~"
/joinkeys
	SSD_CF,
	CTR_NF ,
	SEC_NF,
	UWY_NF,
	UW_NT,
	END_NT
/join unpaired leftside only
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside: FULL
exit
EOF
	SORT

	#[002] Ajout mise a jour TCTRGRO / filiale
	#[003] 
	NSTEP=${NJOB}_240
	# cp ${DFILP}/empty.dat ${DFILT}/${NCHAIN}_IADPERICASE_DELTA_POS_SSDS_TCTRGRO.dat
	#------------------------------------------------------------------------------
	LIBEL="cp ${DFILP}/empty.dat ${DFILT}/${NCHAIN}_IADPERICASE_DELTA_POS_SSDS_TCTRGRO.dat"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILP}/empty.dat ${DFILT}/${NCHAIN}_IADPERICASE_DELTA_POS_SSDS_TCTRGRO.dat"

    #[007]
    NSTEP=${NJOB}_240_1
    LIBEL="cp ${DFILP}/empty.dat ${DFILT}/${NCHAIN}_IADPERICASE_DELTA_POS_SSDS.dat"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILP}/empty.dat ${DFILT}/${NCHAIN}_IADPERICASE_DELTA_POS_SSDS.dat"

    #[007]
    NSTEP=${NJOB}_240_2
    LIBEL="cp ${DFILP}/empty.dat ${DFILT}/${NCHAIN}_CTRGRO_ONE_DELTA_POS_SSDS.dat"
	EXECKSH_MODE=P
	EXECKSH "cp ${DFILP}/empty.dat ${DFILT}/${NCHAIN}_CTRGRO_ONE_DELTA_POS_SSDS.dat"

    #[007]
    if [ -s ${EST_IADPERICASE_DELTA_POS} ]
	then
        cut -d~ -f1 ${EST_IADPERICASE_DELTA_POS} | sort -u > ${DFILT}/${NCHAIN}_IADPERICASE_DELTA_POS_SSDS.dat
    fi
    #[007]
    if [ -s ${DFILT}/${NJOB}_236_${IB}_CTRGRO_ONE_DELTA_POS.dat ]
	then
        cut -d~ -f1 ${DFILT}/${NJOB}_236_${IB}_CTRGRO_ONE_DELTA_POS.dat | sort -u > ${DFILT}/${NCHAIN}_CTRGRO_ONE_DELTA_POS_SSDS.dat
        
        NSTEP=${NJOB}_241
        LIBEL="${DFILT}/${NJOB}_236_${IB}_CTRGRO_ONE_DELTA_POS.dat ${EST_ONE_CTRGRO_POS}"
        EXECKSH_MODE=P
        EXECKSH "cp ${DFILT}/${NJOB}_236_${IB}_CTRGRO_ONE_DELTA_POS.dat ${EST_ONE_CTRGRO_POS}"
    fi

    #[007]
    NSTEP=${NJOB}_245
	LIBEL="Merge IADPERICASE DELTA POS SSDS and CTRGRO ONE DELTA POS SSDS"
	SORT_WDIR=${SORTWORK}
	SORT_CMD=`CFTMP`
	SORT_I="${DFILT}/${NCHAIN}_IADPERICASE_DELTA_POS_SSDS.dat 2000 1"
	SORT_I2="${DFILT}/${NCHAIN}_CTRGRO_ONE_DELTA_POS_SSDS.dat 2000 1"
    SORT_O="${DFILT}/${NCHAIN}_DELTA_POS_SSDS.dat 2000 1"
    INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF 		1:1 - 1:EN
/KEYS 
    SSD_CF
/SUMMARIZE
/OUTFILE ${SORT_O}
exit
EOF
	SORT

    #[007]
	if [ -s ${DFILT}/${NCHAIN}_DELTA_POS_SSDS.dat ]
	then
		# cut -d~ -f1 ${EST_IADPERICASE_DELTA_POS} | sort -u > ${DFILT}/${NCHAIN}_DELTA_POS_SSDS.dat
		ssd_cf=`head -1 ${DFILT}/${NCHAIN}_DELTA_POS_SSDS.dat`
	
		for ssd in `cat ${DFILT}/${NCHAIN}_DELTA_POS_SSDS.dat`
		do
			ssd_cf=${ssd_cf},$ssd
		done
		ECHO_LOG "*** Traitement ssd_cf = $ssd_cf"
		
		NSTEP=${NJOB}_250
		# Begin bcp
		#------------------------------------------------------------------------------
		LIBEL="Current Generation of data from BEST..TVERSION for ESED0401"
		BCP_WAY="OUT"; BCP_VER="+"
		BCP_O=${DFILT}/${NCHAIN}_IADPERICASE_DELTA_POS_SSDS_TCTRGRO.dat
		BCP_QRY="select SSD_CF,SEGTYP_CT,USR_CF='dbo',USR_LAG='E',SGT_NT,VRS_NF from best..tversion
		         where VRSCLO_D = (select max(VRSCLO_D) from best..tversion where VRSSTS_CT = 'CO' and SSD_CF in (${ssd_cf}) and SGT_NT is not null and SGT_NT != -1)
		         and SSD_Cf in (${ssd_cf})
		         and SGT_NT is not null
		         and SGT_NT != -1 "		         
		BCP
	
		for TCTRGRO_data in `cat ${DFILT}/${NCHAIN}_IADPERICASE_DELTA_POS_SSDS_TCTRGRO.dat`
		do
			# Commands taken from ESED0401.cmd
			ECHO_LOG "Process : ${TCTRGRO_data}"
			SSD_CF=`echo "${TCTRGRO_data}" | cut -d~ -f1`
			SEGTYP_CT=`echo "${TCTRGRO_data}" | cut -d~ -f2`
			#USR_CF=`echo "${TCTRGRO_data}" | cut -d~ -f3`
			#USR_LAG=`echo "${TCTRGRO_data}" | cut -d~ -f4`
			SGT_NT=`echo "${TCTRGRO_data}" | cut -d~ -f5`
			VRS_NF=`echo "${TCTRGRO_data}" | cut -d~ -f6`
			ECHO_LOG "SSD_CF    = $SSD_CF"
			ECHO_LOG "SEGTYP_CT = $SEGTYP_CT"
			#ECHO_LOG "USR_CF    = $USR_CF"
			#ECHO_LOG "USR_LAG   = $USR_LAG"
			ECHO_LOG "SGT_NT    = $SGT_NT"
			ECHO_LOG "VRS_NF    = $VRS_NF"

	    NSTEP=${NJOB}_01
	    #-----------------------------------------------------------------------------
	    LIBEL="SWITCH to infocentre ${SRV_2}"
	    SWITCH_SRV ${SRV_2}
	
	    NSTEP=${NJOB}_03
	    #-----------------------------------------------------------------------------
	    LIBEL="Extract run data for result to snapshot ${SSD_CF},${SEGTYP_CT},${SGT_NT} from BSEG"
	    BCP_WAY="OUT"; BCP_VER="+"
	    BCP_O=${DFILT}/${NSTEP}_${IB}_BSEG_CTRGRO_BCP_O.dat
	    BCP_QRY="exec BSAR..PsTCTRGRO_SEG '${SSD_CF}','${SEGTYP_CT}','${SGT_NT}','${VRS_NF}', '${TYPEINV}'"
	    BCP
	
	    NSTEP=${NJOB}_05
	    #-----------------------------------------------------------------------------
	    LIBEL="SWITCH back to default TP ${SRV_DEFAULT}"
	    SWITCH_SRV ${SRV_DEFAULT}

      if [ -s ${DFILT}/${NJOB}_03_${IB}_BSEG_CTRGRO_BCP_O.dat ]
      then
        #----------------------------------------------------------------------------
        # Executing ISQL procedure to delete data in the table TCTRGRO
        #----------------------------------------------------------------------------
        NSTEP=${NJOB}_81
        LIBEL="Executing ISQL procedure to delete data from the table TCTRGRO"
        ISQL_BASE=BEST
        ISQL_QRY="delete BEST..TCTRGRO 
                  where SSD_CF=${SSD_CF} 
                  and VRS_NF=${VRS_NF} 
                  and ('${SEGTYP_CT}' = 'A' AND SEGTYP_CT IN ('A', 'V')) 
                  OR  ('${SEGTYP_CT}' = 'T' AND SEGTYP_CT IN ('T', 'W')) 
                  OR  ('${SEGTYP_CT}' = 'U' AND SEGTYP_CT IN ('U', 'X')) 
                  OR  ('${SEGTYP_CT}' = 'E' AND SEGTYP_CT IN ('E')) 
                  OR  ('${SEGTYP_CT}' = 'S' AND SEGTYP_CT IN ('S')) "
        ISQL

        NSTEP=${NJOB}_82_CUT
        #--------------------------------
        LIBEL="Take out the last field to have the same format as BEST..TCTRGRO"
        EXECKSH_MODE=P
        EXECKSH "cut -d~ -f 1-20,22 ${DFILT}/${NJOB}_03_${IB}_BSEG_CTRGRO_BCP_O.dat > ${DFILT}/${NJOB}_82_CUT_${IB}_BSEG_CTRGRO_O.dat"

        #----------------------------------------------------------------------------
        # Execution of the BCP IN TCTRGRO
        #----------------------------------------------------------------------------
        NSTEP=${NJOB}_83
        LIBEL="Beginning of a BCP IN TCTRGRO"
        BCP_WAY=IN
        BCP_VER=""
        BCP_SPECIAL_OPT=""
        BCP_I=${DFILT}/${NJOB}_82_CUT_${IB}_BSEG_CTRGRO_O.dat
        BCP_TABLE="BEST..TCTRGRO"
        BCP
        
		
		    #-------------------------------------------------------------------------------------------------
		    # Executing ISQL procedure to create and loadind contracts which are not include in the portfolio
		    #-------------------------------------------------------------------------------------------------
		    NSTEP=${NJOB}_107
		    LIBEL="Executing ISQL procedure to create a false segment with unaffected contracts"
		    ISQL_BASE="BEST"
		    ISQL_QRY="execute PiSEGBA_01 ${SSD_CF},'${SEGTYP_CT}', ${VRS_NF} , 'C' "
		    ISQL
		
		    #-------------------------------------------------------------------------------------------------
		    # Executing ISQL procedure to create to add the number fo the subsidiary in name of the segment
		    #-------------------------------------------------------------------------------------------------
		    NSTEP=${NJOB}_108
		    LIBEL="add SSD_CF to the name of the segment, insert BEST..TSEGEST / TSEGMENT from BTRAV..EST_ESED0401_TSEGEST"
		    ISQL_BASE="BEST"
		    ISQL_QRY="execute PuESTSEG_01 ${SSD_CF},'${SEGTYP_CT}', ${VRS_NF} , 'C' "
		    ISQL
        
      fi
		done
	fi
fi	

JOBEND 
