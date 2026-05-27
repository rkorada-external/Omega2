#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION LOT 21
# nom du script SHELL           : ESEH1103.cmd
# revision                      : 1.0
# date de creation              : 21/07/2015
# auteur                        : Paul GARNIER
# references des specifications : EST26a, EST26b, EST38, EST52
#-----------------------------------------------------------------------------
# description :
# Création  PERICASE
# Job intra-day
#
# Job launched by ESDJ1010.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
# [001] 21/07/2015 PGA Spot 29095 : Creation du fichier
# [002]     MBO     03/03/2016  spot30277:  Nettoyage des fichiers $DFILT
#                                           Nettoyage des fichiers $DFILI
# [003] 06/09/2016 MMA Spot 30898 : Génération du FACCPAR0
# [004] M.NAJI 10/09/2018 add UWY_NF in TCTRGRO , spira 57605
# [005] 26/02/2021 M.NAJI Spira 91531  commenter les suppression des fichier permanents  
#===============================================================================

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd
. ${DUTI}/fctws.cmd

# Get input parameters
SSD_CF="00"
SEGTYP_CT=$1
BALSHTYEA_NF=$2
BALSHTMTH_NF=$3
CRE_D=$4
CLODAT_D=$5
OPTION=$6

# Job Initialisation
JOBINIT

ECHO_LOG "#===> EST_FACCPAR0 ................ ${EST_FACCPAR0}"
ECHO_LOG "#===> EST_IRVPERICASE0 ................ ${EST_IRVPERICASE0}"
ECHO_LOG "#===> EST_IAVPERICASE0 ................ ${EST_IAVPERICASE0}"
ECHO_LOG "#===> EST_FSEGPAR ................ ${EST_FSEGPAR}"
ECHO_LOG "#===> EST_FCTRFIC ................ ${EST_FCTRFIC}"
ECHO_LOG "#===> EST_SEGRATANO ................ ${EST_SEGRATANO}"
ECHO_LOG "#===> EST_FVCTRGRO ................ ${EST_FVCTRGRO}"
ECHO_LOG "#===> EST_IARVPERICASE4 ................ ${EST_IARVPERICASE4}"

############################################
# SUPPRESSION DES FICHIERS DFILI REDONDANT #
############################################
NSTEP=${NJOB}_05

#[002]
RMFIL "`dirname ${EST_FRATTACHEVOL}`/${NCHAIN}_FRATTACHEVOL_*.dat
       `dirname ${EST_FVCTRGRO}`/${NCHAIN}_FVCTRGRO_*.dat
       `dirname ${EST_FVCTRGRO0}`/${NCHAIN}_FVCTRGRO0_*.dat
       `dirname ${EST_IARVPERICASE0}`/${NCHAIN}_IARVPERICASE0_*.dat
       `dirname ${EST_OADPERICASE0}`/${NCHAIN}_OADPERICASE0_*.dat
       `dirname ${EST_OAVPERICASE0}`/${NCHAIN}_OAVPERICASE0_*.dat
       `dirname ${EST_ORDPERICASE0}`/${NCHAIN}_ORDPERICASE0_*.dat
       `dirname ${EST_ORVPERICASE0}`/${NCHAIN}_ORVPERICASE0_*.dat
       `dirname ${EST_SEGRATANO}`/${NCHAIN}_SEGRATANO_*.dat
       `dirname ${EST_IARVPERICASE4}`/${NCHAIN}_IARVPERICASE4_*.dat
       `dirname ${EST_31_SORT_R_IAVPERICASE_O}`/*ESDJ1010_31_SORT_R_IAVPERICASE_O*.dat"
       # [005]`dirname ${EST_IRDPERICASE0}`/${NCHAIN}_IRDPERICASE0_*.dat
       # [005]`dirname ${EST_IRVPERICASE0}`/${NCHAIN}_IRVPERICASE0_*.dat
#\[002]

NSTEP=${NJOB}_010
# Begin BCP
#-----------------------------------------------------------------------------
LIBEL="Download of BEST..TCTRGROlife table"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FVCTRGRO0}
BCP_QRY="execute BEST..PsFVCTRGRO_01 '${OPTION}', '${SEGTYP_CT}'"
BCP


NSTEP=${NJOB}_030
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
/CONDITION INVENTAIRE ${EST_SORT_CONDITION} AND SEGTYP_CT = "A"
/INCLUDE INVENTAIRE
exit
EOF
SORT


NSTEP=${NJOB}_050
#Generation of IRVPERICASE Perimeter File
#-----------------------------------------------------------------------------
LIBEL="Current Generation of IRVPERICASE Perimeter File..."
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_PERICASE_O.dat
BCP_QRY="execute BEST..PsSECTION_21 '${SEGTYP_CT}', ${SSD_CF}"
BCP

NSTEP=${NJOB}_60
#[003]
# Génération du FACCPAR0 par execution de BEST..PsACCPAR_02
#------------------------------------------------------------------------------
LIBEL="Génération du fichier FACCPAR0 par execution du BEST..PsACCPAR_02"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${EST_FACCPAR0}                                   
BCP_QRY="execute BEST..PsACCPAR_02"
BCP

NSTEP=${NJOB}_070
#-----------------------------------------------------------------------------
LIBEL="Current Sort of IRVPERICASE Perimeter File..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_050_${IB}_BCP_PERICASE_O.dat 1000 1"
SORT_O="${EST_IRVPERICASE0} OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS CTR_NF 3:1 - 3:, END_NT 4:1 - 4:, SEC_NF 5:1 - 5:, UWY_NF 6:1 - 6:, UW_NT 7:1 - 7:
/KEYS CTR_NF, END_NT, SEC_NF, UWY_NF, UW_NT
exit
EOF
SORT


NSTEP=${NJOB}_100
#-----------------------------------------------------------------------------
LIBEL="Creation of empty Perimeter Files"
EXECKSH "touch ${EST_OADPERICASE0}"
EXECKSH "touch ${EST_OAVPERICASE0}"
EXECKSH "touch ${EST_IRDPERICASE0}"
EXECKSH "touch ${EST_ORDPERICASE0}"
EXECKSH "touch ${EST_ORVPERICASE0}"


NSTEP=${NJOB}_150
# Merging of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_IAVPERICASE0} 1000 1"
SORT_I2="${EST_IRVPERICASE0} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_IARV_PERICASE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF DESCENDING
/CONDITION NONVIE (SSD_CF = 5 OR SSD_CF = 6)
/OMIT NONVIE
/OUTFILE  ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_200
# Update underwriting data with the data of the last underwriting year
#------------------------------------------------------------------------------
LIBEL="Update underwriting data"
PRG=ESTC2041
export ${PRG}_I1=${DFILT}/${NJOB}_150_${IB}_IARV_PERICASE.dat
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IARV_PERICASE.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_MAJ_SECACCSTS_UWY_PREC.log
EXECPRG


NSTEP=${NJOB}_250
# Merging and Filtering of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_200_${IB}_ESTC2041_IARV_PERICASE.dat 1000 1 "
SORT_O="${DFILT}/${NSTEP}_${IB}_IAV_PERICASE.dat"
SORT_O1="${DFILT}/${NSTEP}_${IB}_IRV_PERICASE.dat"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SEGTYP_CT  2:1 -  2:,
        CTR_NF     3:1 -  3:,
        SEC_NF     5:1 -  5:,
        UWY_NF     6:1 -  6:,
        ESTCRB_CT 24:1 - 24:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
/CONDITION ACCEP SEGTYP_CT NE ""
/OUTFILE ${SORT_O1}
/OMIT ACCEP
/OUTFILE ${SORT_O}
/INCLUDE ACCEP
exit
EOF
SORT


NSTEP=${NJOB}_300
# Refreshing Fictitious Treaties and Analysis segments
## rechercher la section du traité de R qui correspond a la lob des Traité NC
#------------------------------------------------------------------------------
LIBEL="Refreshing Fictitious Treaties and Analysis segments"
PRG=ESTC2032
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_PRM=${FPRM}       
export ${PRG}_I1=${DFILT}/${NJOB}_250_${IB}_IAV_PERICASE.dat
export ${PRG}_I2=${EST_FSEGPAR}
export ${PRG}_I3=${EST_FCTRFIC}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_IAV_PERICASE.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_${PRG}_FRATTACHEVOL.dat
export ${PRG}_O3=${EST_SEGRATANO}
export ${PRG}_O4=${DFILT}/${NSTEP}_${IB}_${PRG}_RATTACHEMENT.log
EXECPRG

# ------------------------------------
gzip -c ${DFILT}/${NJOB}_250_${IB}_IAV_PERICASE.dat        > ${DFILT}/${NJOB}_250_IAV_PERICASE.dat.gz
gzip -c ${DFILT}/${NJOB}_250_${IB}_IRV_PERICASE.dat        > ${DFILT}/${NJOB}_250_IRV_PERICASE.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_IAV_PERICASE.dat   > ${DFILT}/${NJOB}_300_ESTC2032_IAV_PERICASE.dat.gz
gzip -c ${DFILT}/${NSTEP}_${IB}_${PRG}_FRATTACHEVOL.dat   > ${DFILT}/${NJOB}_300_ESTC2032_FRATTACHEVOL.dat.gz
# ----------------------------------------


NSTEP=${NJOB}_350
#------------------------------------------------------------------------------
LIBEL="creating IADPERICASE from EST_FVCTRGRO"
PRG=ESTM1004
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
CRE_D ${CRE_D}
exit
EOF
export ${PRG}_I1=${DFILT}/${NJOB}_300_${IB}_ESTC2032_IAV_PERICASE.dat
export ${PRG}_I2=${EST_FVCTRGRO}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_FVCTRGRO1.dat
export ${PRG}_O2=${DFILT}/${NSTEP}_${IB}_PERIANO.dat
export ${PRG}_O3=${DFILT}/${NSTEP}_${IB}_${PRG}_IAV_PERICASE.dat
EXECPRG


NSTEP=${NJOB}_400
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_300_${IB}_ESTC2032_FRATTACHEVOL.dat 1000 1" 
SORT_O="${EST_FRATTACHEVOL}"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN,
            CTR_NF 2:1 - 2:,
            UWY_NF 3:1 - 3:,
            UW_NT  4:1 - 4:,
            SEC_NF 5:1 - 5:,
            END_NT 6:1 - 6:
/KEYS SSD_CF,
      CTR_NF,
      UWY_NF,
      UWY_NF,
      SEC_NF,
      END_NT     
/CONDITION RATTACH SSD_CF != 7
/OUTFILE ${SORT_O}
/INCLUDE RATTACH
exit
EOF
SORT


NSTEP=${NJOB}_450
#Sort of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Sort of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_350_${IB}_ESTM1004_IAV_PERICASE.dat 1000 1"
SORT_I2="${DFILT}/${NJOB}_250_${IB}_IRV_PERICASE.dat 1000 1"
SORT_O="${EST_IARVPERICASE0} OVERWRITE"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF 3:1 - 3:,
        SEC_NF 5:1 - 5:,
        UWY_NF 6:1 - 6:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
exit
EOF
SORT


NSTEP=${NJOB}_500
# Merging and Filtering of life A+R perimeter
#------------------------------------------------------------------------------
LIBEL="Merging and Filtering of life A+R perimeter"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_350_${IB}_ESTM1004_IAV_PERICASE.dat 1000 1" 
SORT_O="${EST_31_SORT_R_IAVPERICASE_O} 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS CTR_NF     3:1 -  3:,
        SEC_NF     5:1 -  5:,
        UWY_NF     6:1 -  6:,
        ESTCRB_CT 24:1 - 24:
/KEYS CTR_NF,
      SEC_NF,
      UWY_NF
/CONDITION RATTACH ESTCRB_CT EQ "R"
/OUTFILE ${SORT_O}
/INCLUDE RATTACH
exit
EOF
SORT


NSTEP=${NJOB}_550
# Fichier Pericase contenant tous les exercices jusqu'a Année de bilan + 4
#----------------------------------------------------------------------------
LIBEL="Fichier Pericase contenant tous les exercices jusqu'a Année de bilan + 4"
PRG=STAM1550
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} <<EOF
BALSHTYEA_NF ${BALSHTYEA_NF}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${EST_IARVPERICASE0}
export ${PRG}_O1=${EST_IARVPERICASE4}
EXECPRG


CLOD=`echo ${CLODAT_D} | cut -c1-6`
if [ ! -f $DFILI/${NCHAIN}_IARVPERICASE4_${BALSHTYEA_NF}1231_${CLOD}_${CRE_D}_${CRE_D}.dat ]
then
    NSTEP=${NJOB}_600
    # Fichier Pericase Copie du fichier PERICASE4 au 3112
    #----------------------------------------------------------------------------
    LIBEL="Fichier Pericase Copie du fichier PERICASE4 au 3112"
    EXECKSH "cp ${EST_IARVPERICASE4} $DFILI/${NCHAIN}_IARVPERICASE4_${BALSHTYEA_NF}1231_${CLOD}_${CRE_D}_${CRE_D}.dat"
fi

# [002]
NSTEP=${NJOB}_560
#-----------------------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"
# \[002]

JOBEND
