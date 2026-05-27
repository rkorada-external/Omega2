#! /bin/ksh
#===============================================================================
# application name               : Compare data already extracted by EXTJ0010
# source name                    : ESDC1001.cmd
# revision                       : $Revision:   0.1  $
# extraction date                : 27/01/2020
# author                         : Lagha Belaid
# specifications reference       :
#                                :
#-------------------------------------------------------------------------------
# description                    : aCompare data already extracted by EXTJ0010
#
# parameters                     :
#   1. FPARM - File containes parametres of comparaison
#
#-------------------------------------------------------------------------------
# modifications chronology       :
# [01] 16/07/2021 D.DASILVATEIXEIRA : SPIRA 99999 fix bug compare faile and update code structure
# [02] 25/08/2021 D.DASILVATEIXEIRA : SPIRA 97731 fix bug
#===============================================================================

# call generic functions
#------------------------------------------------------------------------------
. ${DUTI}/fctgen.cmd
. ${DUTI}/functions/fctgen/GETSTRUCT
. ${DUTI}/functions/fctgen/COMPARE


# Job Initialization variables
#----------------------------------------------------------------------------
FPARM=$1

# Job Initialisation
#-------------------
JOBINIT


NSTEP=${NJOB}_${i}
#
#------------------------------------------------------------------------------
LENV=$(GETV ${FPARM} LENV)
RENV=$(GETV ${FPARM} RENV)
LDATE=$(GETV ${FPARM} LDATE | sed -e 's/ *//g' |  sed -e 's/\///g')
RDATE=$(GETV ${FPARM} RDATE | sed -e 's/ *//g' |  sed -e 's/\///g')
FILE_N=$(GETV ${FPARM} LEFT_TYPE)

LFILE_CHECK=""
RFILE_CHECK=""


if [ "$LDATE" != "" ]; then
    LFILE_CHECK=`ls ${LENV_INTERM}/*${FILE_N}-EXFP*${LDATE}* 2>/dev/null`
fi
if [ "$RDATE" != "" ]; then
    RFILE_CHECK=`ls ${RENV_INTERM}/*${FILE_N}-EXFP*${RDATE}* 2>/dev/null`
fi

FN_COMP_ERROR(){
    echo "#"
    echo "#========================================================================="
    echo "# Comparison : FAILE"
    echo "#"
    echo "# No such file"
    echo "# ENV : $1"
    echo "# Source Directory : $2"
    echo "#========================================================================="
    echo "#"
}

if [ "$LFILE_CHECK" == "" ]; then
    FN_COMP_ERROR $LENV $LENV_INTERM
elif [ "$RFILE_CHECK" == "" ]; then
    FN_COMP_ERROR $RENV $RENV_INTERM
else
    LIBEL="DATACMP running ..."
    COMP_FPRM=${FPARM}
    COMPARE
fi

# echo $STEPEND_CONTINUE
# END Of Job
#------------------------------------------------------------------------------
JOBEND

