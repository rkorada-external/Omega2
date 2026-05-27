#!/bin/ksh
#=============================================================================
# nom de l'application          :  Fxtraction only of the file mapping 
# nom du script SHELL           : ESFJ0002.cmd
# revision                      : 
# date de creation              : 27/01/2021
# auteur                        : ASCOTT(M.NAJI)
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Preparing parametrs files and planning executions
#
# job launched by ESFMAP001.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#Creation	    : 
#Auteur         : M.NAJI
#Date           : 27/01/2021
#Version        : 1.0
#Description    : Fxtraction only of the file mapping 
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

touch $DFILP/${ENV_PREFIX}_ESFJ0000_COND.dat
touch $DFILP/${ENV_PREFIX}_ESFJ0000_PLAN.dat



NSTEP=${NJOB}_05
#---------------------------------------------------------------
LIBEL="extract  BEST..TIFRS17PERM table  "
BCP_WAY="OUT"
BCP_VER="+"
BCP_O=${DFILP}/${NCHAIN}_TI17PERMFIL.dat
BCP_QRY="  declare @mode varchar(20)
  select @mode = '${TI17PERMFIL}'
  select p.* from BEST..TI17PERMFIL p
  LEFT OUTER JOIN BEST..TI17TRAPERMFIL tr on    p.IDF_CT = tr.IDF_CT and
                                                p.PERMFIL_CT = tr.PERMFIL_CT  and
                                                'TI17TRAPERMFIL' = @mode
  where tr.IDF_CT = NULL
  UNION
  select *  from BEST..TI17TRAPERMFIL
  WHERE 'TI17TRAPERMFIL' = @mode
  order by 1 , 2"
BCP



# End of Job
JOBEND

