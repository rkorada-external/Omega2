#!/bin/ksh
#=============================================================================
# Application name          : ESTIMATION LOT 28
# source file               : ESIJ7003.cmd
# revision                  : $Revision:   1.4  $
# creation date             : 01/08/97
# author                    : C.G.I. (M.NAJI)
# specifications references : ESARC01F.DOC
#-----------------------------------------------------------------------------
# description :
# JOB SET: Lot 28 -  Integration of accounts and  retro mouvements 
#                      in the daily GT 
#       Variables used by the job set (defined in ESCD9001.cmd) :
#        ${EST_FDRYTRN}
#
#-----------------------------------------------------------------------------
# Update history :
#   <dd/mm/yyyy>   <author>    <update description>
#=============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

NSTEP=${NJOB}_05
# Begin bcp
#------------------------------------------------------------------------------
LIBEL="Extraction of accounts mouvements (TDRYTRN ==> FDRYTRN)"
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_FDRYTRN_O.dat
BCP_QRY="exec BEST..PsACCTRN_01 '${SRV}'"
BCP

NSTEP=${NJOB}_10
# Begin Sort
#-----------------------------------------------------------------
LIBEL="Concatenation of files"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_BCP_FDRYTRN_O.dat 800 1"
SORT_O="${EST_FDRYTRN} APPEND"
INPUT_TEXT $SORT_CMD << EOF
/COPY
exit
EOF

SORT

NSTEP=${NJOB}_15
#-----------------------------------------------------------------
LIBEL="Deletion of Temporary Files"
RMFIL "${DFILT}/${NJOB}*_${IB}_*.dat"

JOBEND
