#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : Filtre des fichier IFRS4 et EBS et les fusionner avec les fichier I17S
# nom du script SHELL           : ESFD8102.cmd
# revision                      : 
# date de creation              : 18/10/2023
# auteur                        : M.NAJI
# references des specifications : spot 110480
#-----------------------------------------------------------------------------
# description
#  Filtre des fichier IFRS4 et EBS et les fusionner avec les fichier I17S
#
# Launch applicative job ESFD8102
#
#-----------------------------------------------------------------------------
# historiques des modifications:
#[001] 18/10/2023 M.NAJI       :spira 110480 I17S- Change in RA interface
#[002] 10/11/2023 M.NAJI 	   :spira 110830 I17S- Change in RA interface - Copy
#============================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd


if [ ! -f ${ESF_GTSII_RISKMARGIN_CLOSING} ]
then
        ECHO_LOG "ESF_GTSII_RISKMARGIN_CLOSING =${ESF_GTSII_RISKMARGIN_CLOSING}  does not exist, take an empty file"            >> $FLOG
        ESF_GTSII_RISKMARGIN_CLOSING="${DFILP}/empty.dat"
fi

# Job Initialisation
JOBINIT
NSTEP=${NJOB}_05
# Filter FTECLEDA IFRS4 and EBS
#-------------------------------
LIBEL="Filter ${EST_FTECLEDA_I4} and ${EST_FTECLEDA_EBS} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDA_I4} 2000 1"
SORT_I2="${EST_FTECLEDA_EBS} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_I4_EBS.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	GAAPCOD             111:1 -   111:
/CONDITION RESTRICTION GAAPCOD MT /1$/ OR GAAPCOD MT  /1.{7}$/
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_08
#------------------------------------------------------------------------------
LIBEL="filter extended ESB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_FTECLEDA_I4_EBS.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDA_I4_EBS.dat "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF			1:1 - 1:,
	ESB_CF			2:1 - 2:,
	ALL_FIELDS      1:1  - 118:1,
	CLOPER_SSD_CF   1:1  - 1:,
	CLOPER_ESB_CF   2:1  - 2:
/joinkeys
        SSD_CF,
        ESB_CF
		
/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
/joinkeys
        CLOPER_SSD_CF,
        CLOPER_ESB_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_FIELDS
exit
EOF
SORT


NSTEP=${NJOB}_10
# Merge FTECLEDAs
#--------------------------------
LIBEL="Merge FTECLEDAs"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDA_CLOSING} 2000 1"
SORT_I2="${DFILT}/${NJOB}_08_${IB}_FTECLEDA_I4_EBS.dat 2000 1"
SORT_O="${ESF_FTECLEDA} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_15
# Filter TTECLEDR IFRS4 EBS
#--------------------------------
LIBEL="Filter ${EST_FTECLEDR_I4} and ${EST_FTECLEDR_EBS} "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDR_I4} 2000 1"
SORT_I2="${EST_FTECLEDR_EBS} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_I4_EBS.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	GAAPCOD             64:1 -   64:
/CONDITION RESTRICTION GAAPCOD MT /1$/ OR GAAPCOD MT  /1.{7}$/
/OUTFILE ${SORT_O}
/INCLUDE RESTRICTION
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_18
#------------------------------------------------------------------------------
LIBEL="filter extended ESB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_15_${IB}_FTECLEDR_I4_EBS.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTECLEDR_I4_EBS.dat "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF			1:1 - 1:,
	ESB_CF			2:1 - 2:,
	ALL_FIELDS      1:1  - 71:1,
	CLOPER_SSD_CF   1:1  - 1:,
	CLOPER_ESB_CF   2:1  - 2:
/joinkeys
        SSD_CF,
        ESB_CF
		
/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
/joinkeys
        CLOPER_SSD_CF,
        CLOPER_ESB_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_FIELDS
exit
EOF
SORT

NSTEP=${NJOB}_20
# sMerge FTECLEDRs
#--------------------------------
LIBEL="Merge FTECLEDRs"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDR_CLOSING} 2000 1"
SORT_I2="${DFILT}/${NJOB}_18_${IB}_FTECLEDR_I4_EBS.dat 2000 1"
SORT_O="${ESF_FTECLEDR} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_25
# Filter FTECLEDSII EBS
#--------------------------------
LIBEL="Filter $EST_FTECLEDSII_EBS "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLEDSII_EBS} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TECLEDSII_EBS.dat 2000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	PATCAT_CT           33:1 	-   33:,
    PATTYP_CT        	34:1 	- 	34:,
	COL1-29				1:1 	- 	29:,
	NORME_CF			30:1	-	30:,
	COL31-106			31:1	-	106:
/DERIVEDFIELD NORME_CFC NORME_CF COMPRESS
/DERIVEDFIELD NORME_I17S "I17S~"
/CONDITION RESTRICTION  ((PATCAT_CT = "CSF" OR PATCAT_CT = "ICR") AND (NORME_CFC = "" OR (NORME_CFC= "ALLNO"  AND PATTYP_CT != "INF")) ) OR 
						( PATCAT_CT ="BDT" AND PATTYP_CT = "RMNTP")
/OUTFILE ${SORT_O}
/REFORMAT
        COL1-29	,
        NORME_I17S,
        COL31-106
/INCLUDE RESTRICTION
/COPY
exit
EOF
SORT

NSTEP=${NJOB}_28
#------------------------------------------------------------------------------
LIBEL="filter extended ESB"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_25_${IB}_TECLEDSII_EBS.dat  2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_TECLEDSII_EBS.dat  "
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS
	SSD_CF			1:1 - 1:,
	ESB_CF			2:1 - 2:,
	ALL_FIELDS      1:1  - 106:,
	CLOPER_SSD_CF   1:1  - 1:,
	CLOPER_ESB_CF   2:1  - 2:
/joinkeys
        SSD_CF,
        ESB_CF
		
/INFILE ${ESF_FI17CLOPER} 2000 1 "~"
/joinkeys
        CLOPER_SSD_CF,
        CLOPER_ESB_CF
/OUTFILE ${SORT_O} overwrite
/REFORMAT
        leftside:ALL_FIELDS
exit
EOF
SORT

NSTEP=${NJOB}_30
# MERGE FTECLEDSIIs
#--------------------------------
LIBEL="Merge FTECLEDSIIs"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTECLEDSII_CLOSING} 2000 1"
SORT_I2="${DFILT}/${NJOB}_28_${IB}_TECLEDSII_EBS.dat 2000 1"
SORT_O="${ESF_FTECLEDSII} 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
exit
EOF
SORT


JOBEND
 