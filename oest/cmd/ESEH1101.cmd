#!/bin/ksh
#=============================================================================
# nom de l'application  : ESTIMATIONS
#                             Creation du perimetre IADPERICASE
# nom du script SHELL   : ESEH1101.cmd
# revision              : $Revision: 1.5 $
# date de creation    : 09/09/1998
# auteur                : CGI
# references des specifications : ESTSEG01.DOC
#-----------------------------------------------------------------------------
# description:      Perimeter files generation for all subsidiaries.
# job launched by:  ESEH1100.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#_________________
#MODIFICATION    [001]
#Auteur:         D.GATIBELZA
#Date:           23/04/2010
#Version:        10.1
#Description:    ESTVIE18710 Alimentation du MGTAR lors de la comptabilisation de l'arrêté pour la réallocation asie
#_________________
#[002]  01/06/2010   Roger Cassis    :spot:19204 - Optimisation ESEH1100 par parallélisation et découpage en 2 chaines 1100+1110
#[003]  09/09/2011   Roger Cassis    :spot:22571 - Ajout tri du fichier Vie comme non Vie : EST_IAVPERICASE0
#[004]  03/05/2012   Roger Cassis    :spot:23699 - Suppression des fichiers EST_IADPERICASE_ENTIER0
#[005]  26/03/2014   Roger Cassis    :spot:25427 - Omega2 - Gestion test du type de contrat (trt ou fac)
#[006]  16/09/2015   DFI             :spot:29095 - EST26A correction de la step 00 pour l'evocard26
#[007]  28/10/2019   NLD	     	 :spira 81840 - Exclue dummy pericase 	
#[008]  02/01/2020   NLD	     	 :spira 79100 - REQ21.9- Manage retro dummy contracts in closing	
#[009]  21/12/2020   Linh  DOAN      :spira:91536 - Pericase INI ALL
#[010]  30/04/2021	 CAS		 	 :spira#94872 - Clean ESEH1100
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctpar.cmd

# Initialisation of the Job
JOB_LOG_OUTPUT=TEE
JOBINIT
# Parameters
SEGTYP_CT=$1
CRE_D=$2

# SSD_CF=00, used for all subsidiaries
SSD_CF=00


###################
# Tables Download #
###################

NSTEP=${NJOB}_00

# START CONCURRENT STEPS
# -------------------------
PARALLEL_INIT  3
#

NSTEP=${NJOB}_05
#Constituting treaty perimeter file with BTRT database fields
#In case of subsidary 00, all the subsidaries are taken into account
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Treaties perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASETRT_O.dat
BCP_QRY="execute BEST..PsPERITRT_02 '${SEGTYP_CT}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_10
#Download to the file, the fields necessary to the
#facultatives perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Generation of Facs Perimeter..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASEFAC_O.dat
BCP_QRY="execute BEST..PsPERIFAC_02 '${SEGTYP_CT}' with recompile"
PARALLEL BCP

NSTEP=${NJOB}_15
#Download to the XADPERIFCT Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of XADPERIFCT perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERIFCT_O.dat
BCP_QRY="execute BEST..PsSECTION_05 '${SEGTYP_CT}', ${SSD_CF}, '${CRE_D}' with recompile"
PARALLEL BCP

# END CONCURRENT STEPS
# -------------------------
PARALLEL_END

NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Current Sort of XADPERIFCT Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_15_${IB}_BCP_PERIFCT_O.dat
SORT_O="${EST_IADPERIFCT0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 1:1 - 1:,
        END_NT 2:1 - 2: EN,
        SEC_NF 3:1 - 3: EN,
        UWY_NF 4:1 - 4: EN,
        UW_NT 5:1 - 5: EN
/KEYS CTR_NF,
      END_NT,
      SEC_NF,
      UWY_NF,
      UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_25
#Temporary file deletion
LIBEL="Temporary file deletion"
RMFIL ${DFILT}/${NJOB}_130_${IB}_BCP_PERIFCT_O.dat

# Processing for Treaties Perimeter

NSTEP=${NJOB}_30
#Treaties Perimeter File Sort by Contract/Endorsement/UW Year
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Sort of Treaties perimeter file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_PERICASETRT_O.dat 1000 1"
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

NSTEP=${NJOB}_35
#Temporary file deletion
LIBEL="PERICASETRT temporary file deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_BCP_PERICASETRT_O.dat

NSTEP=${NJOB}_40
#Download to the file of charges reiterated and used for the CTBCOM_B
#Field Calculation for treaties.
#-----------------------------------------------------------------------------
LIBEL="Current Generation of reiterated Charges file..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FAMCHG2_O.dat
BCP_QRY="execute BEST..PsSECTION_09 ${SSD_CF}, '${CRE_D}'"
BCP

NSTEP=${NJOB}_45
#Sort of reiterated charges file by Contract/Endorsement/UW Year
#/Sequence Number/ascending section
#-----------------------------------------------------------------------------
LIBEL="Current Reiterated charges file Sort..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I=${DFILT}/${NJOB}_40_${IB}_BCP_FAMCHG2_O.dat
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

NSTEP=${NJOB}_50
#Temporary file deletion
LIBEL="FAMCHG2 temporary file deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_BCP_FAMCHG2_O.dat

NSTEP=${NJOB}_55
#Field CTBCOM_B first part Calculation for Treaties Perimeter
#-----------------------------------------------------------------------------
LIBEL="Current Calculation of field CTBCOM_B 1/2 of Treaties perimeter..."
PRG=ESTC0104
export ${PRG}_I1=${DFILT}/${NJOB}_30_${IB}_SORT_PERICASETRT_O.dat
export ${PRG}_I2=${DFILT}/${NJOB}_45_${IB}_SORT_FAMCHG2_O.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_PERICASETRT_O.dat
EXECPRG

NSTEP=${NJOB}_60
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_30_${IB}_SORT_PERICASETRT_O.dat
RMFIL ${DFILT}/${NJOB}_45_${IB}_SORT_FAMCHG2_O.dat

NSTEP=${NJOB}_65
#Merge and Sort of perimeter files by Contract/Endorsement/UW Year
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters File Sort and Fusion..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_ESTC0104_PERICASETRT_O.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_10_${IB}_BCP_PERICASEFAC_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_PERICASE_O.dat 1000 1"
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
/OUTFILE  ${SORT_O}
/INCLUDE CTR_NOT_DUMMY
exit
EOF
SORT

NSTEP=${NJOB}_70
#Temporary files deletion
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_65_${IB}_ESTC0104_PERICASETRT_O.dat

NSTEP=${NJOB}_75
#Perimeter Fields Update
#[001]${EST_IADPERICASE0} et ${EST_IAVPERICASE0} devient le perimetre complet.
#[003]
#-----------------------------------------------------------------------------
LIBEL="Current Perimeters Fields Update..."
PRG=ESTC0103
export ${PRG}_I1=${DFILT}/${NJOB}_65_${IB}_SORT_PERICASE_O.dat
export ${PRG}_I2=${EST_FCURQUOT}
export ${PRG}_O1=${EST_IADPERICASE_ENTIER0}
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_SORT_IAVPERICASE0_O.dat
EXECPRG

#[001] Le vrai fichier perimetre est créé dans le ESID1001 en concaténant les EST_IAVPERICASE0 et EST_IADPERICASE0.
#[005]
NSTEP=${NJOB}_80
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

#[001] Le vrai fichier perimetre est créé dans le ESID1001 en concaténant les EST_IAVPERICASE0 et EST_IADPERICASE0.
#[003]
NSTEP=${NJOB}_85
# Begin sort
#----------------------------------------------------------------------------
LIBEL="Creation du fichier perimetre Vie : "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75_${IB}_SORT_IAVPERICASE0_O.dat 1000 1"
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


JOBEND
