#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#                               : Controle Period
# nom du script SHELL           : ESID8102.cmd
# revision                      : 
# date de creation              : 11/12/2015
# auteur                        : David Teixeira
# references des specifications : :spot:104403
#-----------------------------------------------------------------------------
# description
#   Controle Period and Closing type if file SII
#
# Launch applicative job ESID8102
#
#-----------------------------------------------------------------------------
# historiques des modifications:
#[001]  28/06/2022  DaD  Spira : 104403  - Conrole Period and Closing type
#[002]  28/07/2022  DaD  Spira : 104403  - Less strict conrol
#===============================================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd


# Get input parameters
NORME=$1

if [ "${DNZFILP}" = "" ]
then
	DNZFILP=${DFILP}
fi

# Job Initialisation
JOBINIT

if [[ $NORME == 'I4I' ]]
then
    EST_FTECLEDARA=$EST_FTECLEDARA
    EST_FTECLEDRRA=$EST_FTECLEDRRA
    EST_FTECLEDSIIRA=''
    EST_CLS=$EST_CLS
elif [[ $NORME == 'EBS' ]]
then
    EST_FTECLEDARA=$EST_FTECLEDARA
    EST_FTECLEDRRA=$EST_FTECLEDRRA
    EST_FTECLEDSIIRA=$EST_FTECLEDSIIRA
    EST_CLS=$EST_CLS
else
    EST_FTECLEDARA=$ESF_FTECLEDARA
    EST_FTECLEDRRA=$ESF_FTECLEDRRA
    EST_FTECLEDSIIRA=$ESF_FTECLEDSIIRA
    EST_CLS=$ESF_CLS
fi


ECHO_LOG "#"
ECHO_LOG "#-------------------------- PARAMETERS -----------------------------------"
ECHO_LOG "#"
ECHO_LOG "#===> NORME.....................: ${NORME}"
ECHO_LOG "#"
ECHO_LOG "#---------------------------- INPUT --------------------------------------"
ECHO_LOG "#"
ECHO_LOG "#===> EST_FTECLEDARA............: ${DNZFILP}/${EST_FTECLEDARA}"
ECHO_LOG "#===> EST_FTECLEDRRA............: ${DNZFILP}/${EST_FTECLEDRRA}"
ECHO_LOG "#===> ESF_FTECLEDSIIRA..........: ${DNZFILP}/${EST_FTECLEDSIIRA}"
ECHO_LOG "#===> EST_CLS...................: ${DNZFILP}/${EST_CLS}"
ECHO_LOG "#"
ECHO_LOG "#---------------------------- OUTPUT -------------------------------------"
ECHO_LOG "#"

# ECHO_LOG "#-------------------------------------------------------------------------"


PERIOD_FILENAME=''
PERIOD_TECLEDA=''
PERIOD_TECLEDR=''
PERIOD_TECLEDSII=''
PERIOD_CLSTYPE=''

NSTEP=${NJOB}_01
LIBEL="Collect Periode from files"
STEPSTART 

if [[ "${NORME}" =~ I17(G|L|P|S) ]]
then
    QTR_FILENAME=`echo ${EST_FTECLEDARA} | cut -d_ -f10`
    YEARS_FILENAME=`echo ${EST_FTECLEDARA} | cut -d_ -f9`
else
    QTR_FILENAME=`echo ${EST_FTECLEDARA} | cut -d_ -f6`
    YEARS_FILENAME=`echo ${EST_FTECLEDARA} | cut -d_ -f5`
fi

# ECHO_LOG "#-------------------------------------------------------------------------"
ECHO_LOG "# Récupération de la période en fonction du nom du fichier"
ECHO_LOG "#"

MONTHS_FILENAME=''
case $QTR_FILENAME in
  1Q ) MONTHS_FILENAME='03';;
  2Q ) MONTHS_FILENAME='06';;
  3Q ) MONTHS_FILENAME='09';;
  4Q ) MONTHS_FILENAME='12';;
  *) MONTHS_FILENAME='';;
esac
PERIOD_FILENAME="${YEARS_FILENAME}${MONTHS_FILENAME}"

# 
ECHO_LOG "# Récupération de la période en fonction des lignes du fichier ${EST_CLS}"
ECHO_LOG "#"
PERIOD_CLSTYPE=`cut -d~ -f3 ${DNZFILP}/${EST_CLS}`

# Si EST_FTECLEDSIIRA existe (EBS|I17G|L|P)
if [[ $EST_FTECLEDSIIRA != '' ]]
then
    ECHO_LOG "# Récupération de la période en fonction des lignes du fichier ${EST_FTECLEDSIIRA}"
    ECHO_LOG "#"
    PERIOD_TECLEDSII=`cut -d~ -f3 ${DNZFILP}/${EST_FTECLEDSIIRA} | sort -u | cut -c1-6`
fi


ECHO_LOG "# Récupération de la période en fonction des lignes du fichier ${EST_FTECLEDARA}"
ECHO_LOG "#"

REF_PERIOD=''
PERIOD=''
WARN=0
CMD=`cut -d~ -f3,4 ${DNZFILP}/${EST_FTECLEDARA} | sort -ur`
for i in $CMD
do
    YEARS=`echo ${i} | cut -d~ -f1`
    MONTHS=`echo ${i} | cut -d~ -f2`

    case $MONTHS in
    1 | 2 | 3 | 01 | 02 | 03) M='03';;
    4 | 5 | 6 | 04 | 05 | 06) M='06';;
    7 | 8 | 9 | 07 | 08 | 09) M='09';;
    10 | 11 | 12) M='12';;
    *) M='';;
    esac

    if [[ $PERIOD == '' ]]
    then
        REF_PERIOD="${YEARS}${M}"
        ECHO_LOG "# Period List : ${CMD}"
        ECHO_LOG "# Period Ref  : ${REF_PERIOD}"
    fi

    PERIOD="${YEARS}${M}"

    # if [[ $YEARS != $Y || $PERIODE_MONTHS != $M ]]
    if [[ $REF_PERIOD != $PERIOD  ]]
    then
        if [[ $WARN == 0 ]]
        then
            ECHO_LOG "#"
            ECHO_LOG "#  ========================================================"
            ECHO_LOG "#  WARNING : Différence de trimestre"
            ECHO_LOG "#  File : ${DFILT}/${NSTEP}_${IB}_FTECLEDARA_WARNING.dat"
            ECHO_LOG "#  ========================================================"
            ECHO_LOG "#"
        fi
        WARN=1

        # on stock les lignes avec une période différent de la période de référance
        grep ".~.~${YEARS}~${MONTHS}~." ${DNZFILP}/${EST_FTECLEDARA} >> ${DFILT}/${NSTEP}_${IB}_FTECLEDARA_WARNING.dat
    fi 
done
PERIOD_TECLEDA=$REF_PERIOD


ECHO_LOG "# Récupération de la période en fonction des lignes du fichier ${EST_FTECLEDRRA}"
ECHO_LOG "#"

REF_PERIOD=''
PERIOD=''
WARN=0
CMD=`cut -d~ -f3,4 ${DNZFILP}/${EST_FTECLEDRRA} | sort -ur`
for i in $CMD
do
    YEARS=`echo ${i} | cut -d~ -f1`
    MONTHS=`echo ${i} | cut -d~ -f2`

    case $MONTHS in
    1 | 2 | 3 | 01 | 02 | 03) M='03';;
    4 | 5 | 6 | 04 | 05 | 06) M='06';;
    7 | 8 | 9 | 07 | 08 | 09) M='09';;
    10 | 11 | 12) M='12';;
    *) M='';;
    esac

    if [[ $PERIOD == '' ]]
    then
        REF_PERIOD="${YEARS}${M}"
        ECHO_LOG "# Period List : ${CMD}"
        ECHO_LOG "# Period Ref  : ${REF_PERIOD}"
    fi

    PERIOD="${YEARS}${M}"

    # if [[ $YEARS != $Y || $PERIODE_MONTHS != $M ]]
    if [[ $REF_PERIOD != $PERIOD  ]]
    then
        if [[ $WARN == 0 ]]
        then
            ECHO_LOG "#"
            ECHO_LOG "#  ========================================================"
            ECHO_LOG "#  WARNING : Différence de trimestre"
            ECHO_LOG "#  File : ${DFILT}/${NSTEP}_${IB}_FTECLEDRRA_WARNING.dat"
            ECHO_LOG "#  ========================================================"
            ECHO_LOG "#"
        fi
        WARN=1

        # on stock les lignes avec une période différent de la période de référance
        grep ".~.~${YEARS}~${MONTHS}~." ${DNZFILP}/${EST_FTECLEDRRA} >> ${DFILT}/${NSTEP}_${IB}_FTECLEDRRA_WARNING.dat
    fi 
done
PERIOD_TECLEDR=$REF_PERIOD

ECHO_LOG "#"
STEPEND 0



# Conrole 1 : Cohérence de période
NSTEP=${NJOB}_10
LIBEL="CONTROLE : Cohérence de période"
STEPSTART 

ECHO_LOG "# PERIOD_FILENAME    = ${PERIOD_FILENAME}"
ECHO_LOG "# PERIOD_TECLEDA     = ${PERIOD_TECLEDA}"
ECHO_LOG "# PERIOD_TECLEDR     = ${PERIOD_TECLEDR}"
if [[ $EST_FTECLEDSIIRA != '' ]]
then
ECHO_LOG "# PERIOD_TECLEDSII   = ${PERIOD_TECLEDSII}"
fi
ECHO_LOG "# PERIOD_CLSTYPE     = ${PERIOD_CLSTYPE}"
ECHO_LOG "#"

ERROR=0
if [[ $EST_FTECLEDSIIRA != '' && $PERIOD_FILENAME != $PERIOD_TECLEDSII && $PERIOD_TECLEDSII != "" ]]
then
    ERROR=1
fi

# if [[ $PERIOD_TECLEDA != $PERIOD_FILENAME || $PERIOD_TECLEDA != $PERIOD_TECLEDR || $PERIOD_TECLEDA != $PERIOD_CLSTYPE ]]
if [[ $PERIOD_FILENAME != $PERIOD_CLSTYPE  ]]
then
    ERROR=1
fi 

if [[ $PERIOD_FILENAME != $PERIOD_TECLEDA  && $PERIOD_TECLEDA != "" ]]
then
    ERROR=1
fi

if [[ $PERIOD_FILENAME != $PERIOD_TECLEDR  && $PERIOD_TECLEDR != "" ]]
then
    ERROR=1
fi
STEPEND $ERROR


# Controle 2 : Contrôle Closing type, si on a un fichier SII
if [[ $EST_FTECLEDSIIRA != '' ]]
then
    NSTEP=${NJOB}_20
    LIBEL="CONTROLE : Closing type"
    STEPSTART 

    ERROR=0

    TYPE_CLS=`cut -d~ -f2 ${DNZFILP}/${EST_CLS}`
    TYPE_TECLEDSII=`cut -d~ -f4 ${DNZFILP}/${EST_FTECLEDSIIRA} | grep ${TYPE_CLS} | sort -u`


    ECHO_LOG "# TYPE_CLS           = ${TYPE_CLS}"
    ECHO_LOG "# TYPE_TECLEDSII     = ${TYPE_TECLEDSII}"
    ECHO_LOG "#"

    if [[ $TYPE_CLS != $TYPE_TECLEDSII  && $TYPE_TECLEDSII != "" ]]
    then
        ERROR=1
    fi 

    STEPEND $ERROR
fi


JOBEND