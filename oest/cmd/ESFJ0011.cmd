#!/bin/ksh
#=============================================================================
# nom de l'application	       : ESTIMATIONS - PREREQUIS OPTIMISATION ESFD2220.cmd
#                                split AECSTATGTA 
# nom du script SHELL          : ESFJ0011.cmd
# revision                     : $Revision: 1.8 $
# date de creation             : 12/07/2019
# auteur                       : M.NAJI
# reference des specifications :
#-----------------------------------------------------------------------------
# Description :
#    split AECSTATGTA ; convert BInary to TET
#
# Job launched by ESFJ0010.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
# [001] 26/09/2019 MZM  :spira:70537 :Ajout du SPIT ARCSTATGTA pour gestion a INCEPTION
#=============================================================================
#set -x
# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

file=$1
nb_splits=$2

NSTEP=${NJOB}_10
# Begin  Split
#--------------------------------------------------------------------------
LIBEL="split file $file on $nb_split parts"
EXECKSH "export siz=`cat $file | wc -l | cut -f1`"
EXECKSH "export size_split=`expr $siz / $nb_splits + 1`"
EXECKSH "split -d -l $size_split $file $file"


#[001]
NSTEP=${NJOB}_20
#  CREATE empty.dat00, empty.dat01, empty.dat02, empty.dat03
#--------------------------------------------------------------------------
LIBEL="CREATE empty.dat00, empty.dat01, empty.dat02, empty.dat03 for ARCSTATGTA"
EXECKSH "touch $DFILP/empty.dat00"
EXECKSH "touch $DFILP/empty.dat01"
EXECKSH "touch $DFILP/empty.dat02"
EXECKSH "touch $DFILP/empty.dat03"

JOBEND
