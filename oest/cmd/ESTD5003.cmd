#!/bin/ksh
#==============================================================================
#nom de l'application: RETRO 
#nom du source: ESTD5003.cmd 
#revision: $Revision:   1.1  $
#date de creation: 07/2001
#auteur:  O.GIRAUX
#description:  Suppression Mutre et CMR dans BCTA ( 1h40 sur MAIP07 )
#
#    Dans l'ordre:
#       - BRET
#       - BEST
#       - BCTA
#       - BTRT
#
#------------------------------------------------------------------------------

#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# JOB initialization
JOBINIT



NSTEP=${NJOB}_05
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TACCNUM"
ISQL_BASE="BCTA"
ISQL_QRY="delete TACCNUM where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_10
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TACCTRN"
ISQL_BASE="BCTA"
ISQL_QRY="delete TACCTRN where ctr_nf like '08%' or ctr_nf like '09%'"
ISQL

NSTEP=${NJOB}_15
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TAPD"
ISQL_BASE="BCTA"
ISQL_QRY="delete TAPD  where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_20
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TAPR"
ISQL_BASE="BCTA"
ISQL_QRY="delete TAPR  where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_25
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TATHADM"
ISQL_BASE="BCTA"
ISQL_QRY="delete TATHADM  where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_30
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TBAL"
ISQL_BASE="BCTA"
ISQL_QRY="delete TBAL where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_35
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TBLCSHTD"
ISQL_BASE="BCTA"
ISQL_QRY="delete TBLCSHTD where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_40
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TBRKTRS"
ISQL_BASE="BCTA"
ISQL_QRY="delete TBRKTRS where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_45
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TCPLACC"
ISQL_BASE="BCTA"
ISQL_QRY="delete TCPLACC where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_50
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TCSHCALD"
ISQL_BASE="BCTA"
ISQL_QRY="delete TCSHCALD where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_55
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TCURTRS"
ISQL_BASE="BCTA"
ISQL_QRY="delete TCURTRS where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_60
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TDOC"
ISQL_BASE="BCTA"
ISQL_QRY="delete TDOC where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_65
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TDRYTRN"
ISQL_BASE="BCTA"
ISQL_QRY="delete TDRYTRN where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_70
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TESTPAR"
ISQL_BASE="BCTA"
ISQL_QRY="delete TESTPAR where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_75
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TFMT"
ISQL_BASE="BCTA"
ISQL_QRY="delete TFMT where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_80
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TFNCTRN"
ISQL_BASE="BCTA"
ISQL_QRY="delete TFNCTRN where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_85
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TINTERF"
ISQL_BASE="BCTA"
ISQL_QRY="delete TINTERF where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_90
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TLSTQUOT"
ISQL_BASE="BCTA"
ISQL_QRY="delete TLSTQUOT where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_95
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TMADPAY "
ISQL_BASE="BCTA"
ISQL_QRY="delete TMADPAY where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_100
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TME"
ISQL_BASE="BCTA"
ISQL_QRY="delete TME where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_105
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TPARAM"
ISQL_BASE="BCTA"
ISQL_QRY="delete TPARAM where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_110
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TPAYACC"
ISQL_BASE="BCTA"
ISQL_QRY="delete TPAYACC where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_115
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TPRFLOS"
ISQL_BASE="BCTA"
ISQL_QRY="delete TPRFLOS where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_120
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TPRGACC"
ISQL_BASE="BCTA"
ISQL_QRY="delete TPRGACC where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_125
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TRCVPAY"
ISQL_BASE="BCTA"
ISQL_QRY="delete TRCVPAY where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_130
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TREB"
ISQL_BASE="BCTA"
ISQL_QRY="delete TREB where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_135
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TRGNUMB"
ISQL_BASE="BCTA"
ISQL_QRY="delete TRGNUMB where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_140
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TRQTAPR"
ISQL_BASE="BCTA"
ISQL_QRY="delete TRQTAPR where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_145
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TSPRDET"
ISQL_BASE="BCTA"
ISQL_QRY="delete TSPRDET where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_150
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TSPRHDR"
ISQL_BASE="BCTA"
ISQL_QRY="delete TSPRHDR where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_155
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TSPRTRS"
ISQL_BASE="BCTA"
ISQL_QRY="delete TSPRTRS where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_160
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTPACOMED"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTPACOMED where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_165
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTPAOCEP"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTPAOCEP where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_170
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTPAPAYBP"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTPAPAYBP where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_175
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTPAPYEBP"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTPAPYEBP where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_180
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTPASUM"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTPASUM where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_185
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTPAUIP"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTPAUIP where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_190
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTRDPAY"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTRDPAY where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_195
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTRDPYE"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTRDPYE where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_200
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTRDUW"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTRDUW where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_205
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTRNFMT"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTRNFMT where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_210
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTRSHTZ"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTRSHTZ where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_215
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BCTA..TTRTRQT"
ISQL_BASE="BCTA"
ISQL_QRY="delete TTRTRQT where ssd_cf in (8, 9)"
ISQL

JOBEND
