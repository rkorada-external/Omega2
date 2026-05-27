#!/bin/ksh
#=============================================================================
# nom de l'application	       : ESTIMATIONS - INVENTAIRE
#                                split file
# nom du script SHELL          : SPLITFL01.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 12/07/2019
# auteur                       : M.NAJI
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#   Split file 
#
# Job launched by SPLITFL1.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#=============================================================================
#set -x
# Call generic functions
. ${DUTI}/fctgen.cmd


file=$1
nb_splits=$2





JOBINIT

NSTEP=${NJOB}_10
# Begin  Split
#--------------------------------------------------------------------------
LIBEL="split file $file on $nb_split parts"
EXECKSH "export siz=`cat $file | wc -l | cut -f1`"
EXECKSH "export size_split=`expr $siz / $nb_splits + 1`"
EXECKSH "split -d -l $size_split $file $file"

JOBEND
