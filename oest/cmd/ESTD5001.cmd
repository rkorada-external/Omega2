#!/bin/ksh
#==============================================================================
#nom de l'application: RETRO 
#nom du source: ESTD5001.cmd 
#revision: $Revision:   1.1  $
#date de creation: 07/2001
#auteur:  O.GIRAUX
#description:  Suppression Mutre et CMR dans BRET ( 3' sur MAIP07)
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
LIBEL="Deletion of lines in BRET..TCESSION"
ISQL_BASE="BRET"
ISQL_QRY="delete  TCESSION where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_10
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TCURCVSN"
ISQL_BASE="BRET"
ISQL_QRY="delete  TCURCVSN where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_15
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TDEPOSIT"
ISQL_BASE="BRET"
ISQL_QRY="delete  TDEPOSIT where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_20
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TEDISSD"
ISQL_BASE="BRET"
ISQL_QRY="delete  TEDISSD where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_25
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TFACEDI"
ISQL_BASE="BRET"
ISQL_QRY="delete  TFACEDI where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_30
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TFACOCAL"
ISQL_BASE="BRET"
ISQL_QRY="delete  TFACOCAL where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_35
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TFUNINTM"
ISQL_BASE="BRET"
ISQL_QRY="delete  TFUNINTM where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_40
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TINTPLCT"
ISQL_BASE="BRET"
ISQL_QRY="delete  TINTPLCT where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_45
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TINTWIT"
ISQL_BASE="BRET"
ISQL_QRY="delete  TINTWIT where retctr_nf like '08%' or retctr_nf like '09%'"
ISQL

NSTEP=${NJOB}_50
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TOUTTRAA"
ISQL_BASE="BRET"
ISQL_QRY="delete  TOUTTRAA where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_55
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TOUTTRAI"
ISQL_BASE="BRET"
ISQL_QRY="delete  TOUTTRAI where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_60
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TPFUNWIT"
ISQL_BASE="BRET"
ISQL_QRY="delete  TPFUNWIT where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_65
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TPINTWIT"
ISQL_BASE="BRET"
ISQL_QRY="delete  TPINTWIT where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_70
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TPLACEMT"
ISQL_BASE="BRET"
ISQL_QRY="delete  TPLACEMT where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_75
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TPLACEN"
ISQL_BASE="BRET"
ISQL_QRY="delete  TPLACEN where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_80
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TPNFAMPO"
ISQL_BASE="BRET"
ISQL_QRY="delete  TPNFAMPO where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_85
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TPPFAMPO"
ISQL_BASE="BRET"
ISQL_QRY="delete  TPPFAMPO where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_90
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRACCCOND"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRACCCOND where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_95
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRACCSEN"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRACCSEN where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_100
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRACCSET"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRACCSET where ssd_cf in (8, 9)"
ISQL


NSTEP=${NJOB}_105
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRACCSET"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRACCSET where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_110
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRCESREQ"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRCESREQ where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_115
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRCESRET"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRCESRET where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_120
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRCESRUL"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRCESRUL where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_125
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRCLMREI"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRCLMREI where ssd_cf in (8, 9)"
ISQL


NSTEP=${NJOB}_130
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TREINSSD"
ISQL_BASE="BRET"
ISQL_QRY="delete  TREINSSD where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_135
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRETCTR"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRETCTR where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_140
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRETCUR"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRETCUR where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_145
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRETPGM"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRETPGM where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_150
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRETSEC"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRETSEC where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_155
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRETTER"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRETTER where retctr_nf like '08%' or retctr_nf like '09%'"
ISQL

NSTEP=${NJOB}_160
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRFAMLI"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRFAMLI where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_165
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRFAMMIS"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRFAMMIS where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_170
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRFAMPRE"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRFAMPRE where retctr_nf like '08%' or retctr_nf like '09%'"
ISQL

NSTEP=${NJOB}_175
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRFAMPRM"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRFAMPRM where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_180
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRFAMRI "
ISQL_BASE="BRET"
ISQL_QRY="delete  TRFAMRI where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_185
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRGPI"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRGPI where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_190
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TROJTRT"
ISQL_BASE="BRET"
ISQL_QRY="delete  TROJTRT where retctr_nf like '08%' or retctr_nf like '09%'"
ISQL

NSTEP=${NJOB}_195
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRTONUMB"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRTONUMB where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_200
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRTRTLOB"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRTRTLOB where retctr_nf like '08%' or retctr_nf like '09%'"
ISQL

NSTEP=${NJOB}_205
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TRVALMSG"
ISQL_BASE="BRET"
ISQL_QRY="delete  TRVALMSG where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_210
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TSAMACCT"
ISQL_BASE="BRET"
ISQL_QRY="delete  TSAMACCT where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_215
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TSSDACTR"
ISQL_BASE="BRET"
ISQL_QRY="delete  TSSDACTR where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_220
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TTFACOCAL"
ISQL_BASE="BRET"
ISQL_QRY="delete  TTFACOCAL where ssd_cf in (8, 9)"
ISQL

NSTEP=${NJOB}_225
# Begin isql
#-----------------------------------------------------------------
LIBEL="Deletion of lines in BRET..TUKNTRDP"
ISQL_BASE="BRET"
ISQL_QRY="delete  TUKNTRDP where ssd_cf in (8, 9)"
ISQL

JOBEND
