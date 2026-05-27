#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS 
#                                 Remontee sous BO ( Ouverture 98 )
# nom du script SHELL		: ESTO8821.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 07/04/98
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   
#
# job launched by ESTO8800.cmd
#-----------------------------------------------------------------------------
# historiques des modifications 
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Initialisation of the Job
JOBINIT


###############
# Input files #
###############

# EST_FTECLEDA_1997
# EST_FTECLEDR_1997

#Descente des tables 

NSTEP=${NJOB}_05
# Begin bcp out
#------------------------------------------------------------------------------
LIBEL="Bcp out of TTECLEDA_B table"
BCP_WAY="OUT"
BCP_VER=""
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FTECLEDA_O.dat
BCP_TABLE="BSTA..TTECLEDA_B"
BCP

NSTEP=${NJOB}_10
# Begin sort
#-----------------------------------------------------------------------------
LIBEL=" sort of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_FTECLEDA_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDA_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION FILIALE SSD_CF = 6
/OMIT FILIALE
exit
EOF
SORT

NSTEP=${NJOB}_15
#Temporary files deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_05_${IB}_BCP_FTECLEDA_O.dat

NSTEP=${NJOB}_30
# Merge of FTECLEDA files  on the ftecleda index
#-----------------------------------------------------------------------------
LIBEL="Merge of FTECLEDA files  on the ftecleda index"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FTECLEDA_O.dat 1000 1"
SORT_I2="${DFILP}/${PCH}ESTO2920_FTECLEDA_1997.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ALLFTECLEDA_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:, SSD_CF 1:1 - 1:, ESB_CF 2:1 - 2:
/KEYS TRNCOD_CF,SSD_CF,ESB_CF
exit
EOF
SORT

NSTEP=${NJOB}_31
#Temporary files deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_10_${IB}_SORT_FTECLEDA_O.dat



NSTEP=${NJOB}_35
# Begin bcp out
#------------------------------------------------------------------------------
LIBEL="Bcp of ftecledr table"
BCP_WAY="OUT"
BCP_VER=""
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FTECLEDR_O.dat
BCP_TABLE="BSTA..TTECLEDR_B"
BCP

NSTEP=${NJOB}_40
# Begin sort
#-----------------------------------------------------------------------------
LIBEL=" sort of TL files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_35_${IB}_BCP_FTECLEDR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1: EN
/CONDITION FILIALE SSD_CF = 6
/OMIT FILIALE
exit
EOF
SORT

NSTEP=${NJOB}_45
#Temporary files deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_35_${IB}_BCP_FTECLEDR_O.dat

NSTEP=${NJOB}_50
# Merge of FTECLEDR files  on the ftecledr index
#-----------------------------------------------------------------------------
LIBEL="Merge of FTECLEDR files  on the ftecledr index"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_FTECLEDR_O.dat 1000 1"
SORT_I2="${DFILP}/${PCH}ESTO2920_FTECLEDR_1997.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_ALLFTECLEDR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD_CF 6:1 - 6:, SSD_CF 1:1 - 1:, ESB_CF 2:1 - 2:
/KEYS TRNCOD_CF,SSD_CF,ESB_CF
exit
EOF
SORT

NSTEP=${NJOB}_51
#Temporary files deletion
#-----------------------------------------------------------------------------
LIBEL="Temporary files deletion"
RMFIL ${DFILT}/${NJOB}_40_${IB}_SORT_FTECLEDR_O.dat




###########################################
# MAJ DES TABLES TTECLEDA_B ET TTECLEDR_B #
###########################################


NSTEP=${NJOB}_55
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="BSTA..TTECLEDA_B table clear"
ISQL_BASE="BSTA"
ISQL_QRY="truncate table BSTA..TTECLEDA_B"
ISQL 

NSTEP=${NJOB}_60
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="BSTA..TTECLEDR_B table clear"
ISQL_BASE="BSTA"
ISQL_QRY="truncate table BSTA..TTECLEDR_B"
ISQL 

NSTEP=${NJOB}_65
# Drop index on BSTA..TTECLEDA_B
#------------------------------------------------------------------------------
LIBEL="Drop index on BSTA..TTECLEDA_B"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BSTA
go
IF EXISTS (SELECT NULL
	from sysindexes ind, sysobjects obj 
	where ind.name = 'ITECLEDA_B_00' and obj.name='TTECLEDA_B' AND ind.id=obj.id
	)
BEGIN
   DROP INDEX TTECLEDA_B.ITECLEDA_B_00
   PRINT '<<< DROPPED INDEX ITECLEDA_B_00 >>>'
END
go
exit
EOF
ISQL

NSTEP=${NJOB}_70
# filling TTECLEDA_B table
#--------------------------------
LIBEL="filling TTECLEDA_B table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_30_${IB}_SORT_ALLFTECLEDA_O.dat
BCP_TABLE="BSTA..TTECLEDA_B"
BCP

NSTEP=${NJOB}_75
# Create index on BSTA..TTECLEDA_B
#------------------------------------------------------------------------------
LIBEL="Create index on BSTA..TTECLEDA_B"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BSTA
go
CREATE INDEX ITECLEDA_B_00
 ON dbo.TTECLEDA_B(TRNCOD_CF,SSD_CF,ESB_CF) 

IF EXISTS (SELECT NULL
	from sysindexes ind, sysobjects obj 
	where ind.name = 'ITECLEDA_B_00' and obj.name='TTECLEDA_B' AND ind.id=obj.id
	)
BEGIN
    PRINT '<<< INDEX ITECLEDA_B_00 CREATED >>>'

END
go
exit
EOF
ISQL  

NSTEP=${NJOB}_80
# Drop index on BSTA..TTECLEDR_B
#------------------------------------------------------------------------------
LIBEL="Drop index on BSTA..TTECLEDR_B"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BSTA
go
IF EXISTS (SELECT NULL
	from sysindexes ind, sysobjects obj 
	where ind.name = 'ITECLEDR_B_00' and obj.name='TTECLEDR_B' AND ind.id=obj.id
	)
BEGIN
   DROP INDEX TTECLEDR_B.ITECLEDR_B_00
   PRINT '<<< DROPPED INDEX ITECLEDR_B_00 >>>'
END
go
exit
EOF
ISQL            

NSTEP=${NJOB}_85
# filling TTECLEDR_B table
#--------------------------------
LIBEL="filling TTECLEDR_B table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_50_${IB}_SORT_ALLFTECLEDR_O.dat
BCP_TABLE="BSTA..TTECLEDR_B"
BCP

NSTEP=${NJOB}_90
# Create index on BSTA..TTECLEDR_B
#------------------------------------------------------------------------------
LIBEL="Create index on BSTA..TTECLEDR_B"
ISQL_QRY=`CFTMP`
ISQL_BASE=BSTA
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.dat
INPUT_TEXT ${ISQL_QRY} <<EOF
USE BSTA
go
CREATE INDEX ITECLEDR_B_00
 ON dbo.TTECLEDR_B(TRNCOD_CF,SSD_CF,ESB_CF) 

IF EXISTS (SELECT NULL
	from sysindexes ind, sysobjects obj 
	where ind.name = 'ITECLEDR_B_00' and obj.name='TTECLEDR_B' AND ind.id=obj.id
	)
BEGIN
    PRINT '<<< INDEX ITECLEDR_B_00 CREATED >>>'

END
go
exit
EOF
ISQL 

###############################
# Deletion of temporary files #
###############################

NSTEP=${NJOB}_95
LIBEL="Deletion of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND
