#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS
# date de creation              : 17/08/2021
# auteur                        : Mr JYP
#-----------------------------------------------------------------------------
# [001] 17/08/2021 JYP: SPIRA 92591 : script to initialize T.codes mappings for AE-INI into CSF
# [002] 01/10/2021 JYP: SPIRA 92591 : add grouping and bugfix
# [003 10/10/2024 MZM: SPIRA 112186 :I17 - AE on ini overrider not properly taken into account in cashflows : update digit 112122 ==> 112128
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd

CHAININIT CNLD0030 $DENV/CNLD0030.env

JOB=${ENV_PREFIX}_CNLD0030_CNLD0031

# Initialization of the Job
JOBINIT

echo "Starting $0 $1 $FLOG "
echo "Starting $0 $1" >> $FLOG
date >> $FLOG


NSTEP=${NCHAIN}_${NJOB}_05
LIBEL="IFRS17 INCEPTION : init t.codes mapping for AE into CSF"

#AE 5 digit ~ EBS assumed ~ EBS retro
echo "10014~1A100012~2A100012~1151" >  $DFILP/${ENV_PREFIX}_ESFD3610_AEPRSMAP.dat
echo "10015~1A100022~2A100022~1152" >> $DFILP/${ENV_PREFIX}_ESFD3610_AEPRSMAP.dat
echo "12014~1A120012~2A120012~2151" >> $DFILP/${ENV_PREFIX}_ESFD3610_AEPRSMAP.dat
echo "12015~1A120022~2A120022~2152" >> $DFILP/${ENV_PREFIX}_ESFD3610_AEPRSMAP.dat
echo "12019~1A120022~2A120022~2152" >> $DFILP/${ENV_PREFIX}_ESFD3610_AEPRSMAP.dat
echo "12016~1A120062~2A120062~2153" >> $DFILP/${ENV_PREFIX}_ESFD3610_AEPRSMAP.dat
echo "12128~1A121212~2A121212~2154" >> $DFILP/${ENV_PREFIX}_ESFD3610_AEPRSMAP.dat
echo "49431~1A494302~2A494302~3221" >> $DFILP/${ENV_PREFIX}_ESFD3610_AEPRSMAP.dat
echo "20071~1A200712~2A200712~3222" >> $DFILP/${ENV_PREFIX}_ESFD3610_AEPRSMAP.dat

EXECKSH_MODE=P
EXECKSH "ls -ltr $DFILP/${ENV_PREFIX}_ESFD3610_AEPRSMAP.dat "


JOBEND
CHAINEND
