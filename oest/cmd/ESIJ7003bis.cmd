#!/bin/ksh
#=============================================================================
# Application name          : ESTIMATION
# source file               : ESIJ7003bis.cmd
# revision                  : 10.2
# creation date             : 09/12/2010
# author                    : D.GATIBELZA
#-----------------------------------------------------------------------------
# description : Integration des mouvements compta dans le GT
#               ESTDOM20828: mouvements comptables non venus dans GLT  sur exercices ou numero ordre  FACULTATIVE  supprimé
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
BCP_QRY="exec BEST..PsACCTRN_01bis"
BCP


echo "FICHIER EST_FDRYTRN: ${EST_FDRYTRN}"

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
