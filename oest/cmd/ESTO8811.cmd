#!/bin/ksh
#=============================================================================
# nom de l'application		: ESTIMATIONS 
#                                 Remontee sous BO ( Ouverture 98 )
# nom du script SHELL		: ESTO8811.cmd
# revision			: $Revision:   1.0  $
# date de creation		: 26/10/98
# auteur			: CGI
# references des specifications	: 
#-----------------------------------------------------------------------------
# description
#   
#
# job launched by ESTO8810.cmd
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

# ESTO2910_FTECLEDR_1997


###########################
# MAJ DE TABLE TTECLEDR_B #
###########################

NSTEP=${NJOB}_05
# Filter of the FTECLEDR file
#------------------------------------------------------------------------------
LIBEL="Delete of non estimates writing"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILP}/F_ESTO2910_FTECLEDR_1997.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLEDR_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS SSD_CF 1:1 - 1: EN, TRNCOD_2PREFIX 6:2 - 6:2, TRNCOD_SUFIX 6:8 - 6:8
/CONDITION COND1 ( SSD_CF = 2 and ( TRNCOD_SUFIX > "1" or TRNCOD_2PREFIX > "3" )) or SSD_CF = 3 or SSD_CF = 4 or SSD_CF = 12 or SSD_CF = 6
/COPY
/OUTFILE ${SORT_O}
	/INCLUDE COND1
exit
EOF
SORT

NSTEP=${NJOB}_07
# summarize TTECLEDR by BALSHTDAY/MTH
#--------------------------------
LIBEL="Summarize TTECLEDR by BALSHTDAY/MTH"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_FTECLEDR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_TECLEDR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        TRNCOD_CF 6:1 - 6:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:
/KEYS
        BALSHEY_NF,
        TRNCOD_CF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT
/SUMMARIZE  TOTAL RETAMT_M
exit
EOF
SORT           

NSTEP=${NJOB}_10
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="BSTA..TTECLEDR_B table clear"
ISQL_BASE="BSTA"
ISQL_QRY="truncate table BSTA..TTECLEDR_B"
ISQL  

NSTEP=${NJOB}_30
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

NSTEP=${NJOB}_35
# filling TTECLEDR_B table
#--------------------------------
LIBEL="filling TTECLEDR_B table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILT}/${NJOB}_07_${IB}_SORT_TECLEDR_O.dat
BCP_TABLE="BSTA..TTECLEDR_B"
BCP

NSTEP=${NJOB}_40
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

NSTEP=${NJOB}_45
LIBEL="Deletion of temporary files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"


JOBEND
