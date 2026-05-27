#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION
# nom du script SHELL           : ESTD2531.cmd
# revision                      : $Revision:   1.24  $
# date de creation              : 22/01/04
# auteur                        : J. RIBOT
# references des specifications : SPOT-5079
#-----------------------------------------------------------------------------
# description : chargement CNA
# job launched by ESTD2530.cmd
#-----------------------------------------------------------------------------
# historique des modifications :
#
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_00
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="DELETE REPRISE CNA BEST..TLIFEST"
ISQL_BASE="BEST"
ISQL_QRY="DELETE BEST..TLIFEST where ORICOD_LS = 'REPRISE CNA'"
ISQL

NSTEP=${NJOB}_01
# filling BEST..TLIFEST table
#--------------------------------
LIBEL="filling BEST..TLIFEST table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILI}/${NCHAIN}_TRANS_CNA_LIFEST.dat
BCP_TABLE="BEST..TLIFEST"
BCP

NSTEP=${NJOB}_05
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="BTRAV..EST_ESTD2530_TCNATYP table clear"
ISQL_BASE="BTRAV"
ISQL_QRY="truncate table BTRAV..EST_ESTD2530_TCNATYP"
#ISQL

NSTEP=${NJOB}_05
# Create working tables into BTRAV before Loading data
#------------------------------------------------------------------------------
LIBEL="Create working tables into BTRAV..EST_ESTD2530_TCNATYP before Loading data"
ISQL_QRY=`CFTMP`
ISQL_BASE=${BASE}
ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL_O.log
INPUT_TEXT ${ISQL_QRY} <<EOF
use BTRAV
go

IF OBJECT_ID('dbo.EST_ESTD2530_TCNATYP') IS NOT NULL
  begin
    drop table dbo.EST_ESTD2530_TCNATYP
    PRINT '<<< drop TABLE dbo.EST_ESTD2530_TCNATYP >>>'
  end
go

CREATE TABLE dbo.EST_ESTD2530_TCNATYP
(
    CTR_NF      UCTR_NF    NOT NULL,
    UWY_NF      smallint   NOT NULL
)
LOCK ALLPAGES
go
GRANT REFERENCES ON dbo.EST_ESTD2530_TCNATYP TO GOMEGA
go
GRANT SELECT ON dbo.EST_ESTD2530_TCNATYP TO GCONSULT
go
GRANT SELECT ON dbo.EST_ESTD2530_TCNATYP TO GOMEGA
go
GRANT INSERT ON dbo.EST_ESTD2530_TCNATYP TO GOMEGA
go
GRANT DELETE ON dbo.EST_ESTD2530_TCNATYP TO GOMEGA
go
GRANT UPDATE ON dbo.EST_ESTD2530_TCNATYP TO GOMEGA
go
IF OBJECT_ID('dbo.EST_ESTD2530_TCNATYP') IS NOT NULL
    PRINT '<<< CREATED TABLE dbo.EST_ESTD2530_TCNATYP >>>'
ELSE
    PRINT '<<< FAILED CREATING TABLE dbo.EST_ESTD2530_TCNATYP >>>'
go
exit
EOF
ISQL

NSTEP=${NJOB}_10
# filling BTRAV..TCNATYP table
#--------------------------------
LIBEL="filling BTRAV..EST_ESTD2530_TCNATYP table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILI}/${NCHAIN}_TRANS_CNA_CNATYP.dat
BCP_TABLE="BTRAV..EST_ESTD2530_TCNATYP"
BCP

NSTEP=${NJOB}_15
# update cnatyp_ct BTRT..TCONTR
#------------------------------------------------------------------------------
LIBEL="update cnatyp_ct BTRT..TCONTR"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
BCP_QRY="exec BTRAV..PuCONTR_CNA_01"
BCP

NSTEP=${NJOB}_20
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="BTRT..TFAMCNA table clear"
ISQL_BASE="BTRT"
ISQL_QRY="DELETE BTRT..TFAMCNA where LSTUPDUSR_CF = 'dbo2 '"
ISQL

NSTEP=${NJOB}_22
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="BTRAV..EST_ESTD2530_TCNATYP table clear"
ISQL_BASE="BTRAV"
ISQL_QRY="truncate table BTRT..TFAMCNA"
#ISQL

NSTEP=${NJOB}_25
# filling BTRT..TFAMCNA table
#--------------------------------
LIBEL="filling BTRT..TFAMCNA table"
BCP_WAY="IN"
BCP_VER=""
BCP_I=${DFILI}/${NCHAIN}_TRANS_CNA_FAMCNA.dat
BCP_TABLE="BTRT..TFAMCNA"
BCP

NSTEP=${NJOB}_30
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="BTRAV..EST_ESTD2530_TCNATYP table clear"
ISQL_BASE="BTRAV"
ISQL_QRY="truncate table BTRAV..EST_ESTD2530_TCNATYP"
#ISQL

NSTEP=${NJOB}_30
#Begin isql
#-----------------------------------------------------------------------------
LIBEL="BTRAV..EST_ESTD2530_TCNATYP table clear"
ISQL_BASE="BTRAV"
ISQL_QRY="drop table BTRAV..EST_ESTD2530_TCNATYP"
ISQL

JOBEND

