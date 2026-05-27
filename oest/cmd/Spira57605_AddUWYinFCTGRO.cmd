#!/bin/ksh
#=============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

CHAININIT CNLD0030 CNLD0030.env

NJOB=${ENV_PREFIX}_CNLD0030_CNLD0031

# Initialization of the Job
JOBINIT

echo $FLOG

echo  "Starting $0 ... " > $FLOG
date >> $FLOG


awk 'BEGIN{FS="~"; } {if ( NF == 20 ) print $0"~0"}'  $DFILP/${ENV_PREFIX}_ESPT0000_FCTRGRO1.dat > $DFILT/${ENV_PREFIX}_ESPT0000_FCTRGRO1.dat_tmp
awk 'BEGIN{FS="~"; } {if ( NF == 20 ) print $0"~0"}'  $DFILP/${ENV_PREFIX}_ESPT0000_FCTRGRO.dat > $DFILT/${ENV_PREFIX}_ESPT0000_FCTRGRO.dat_tmp
awk 'BEGIN{FS="~"; } {if ( NF == 20 ) print $0"~0"}'  $DFILP/${ENV_PREFIX}_ESID7000_FCTRGRO.dat > $DFILT/${ENV_PREFIX}_ESID7000_FCTRGRO.dat_tmp



if [ -s $DFILT/${ENV_PREFIX}_ESPT0000_FCTRGRO1.dat_tmp ]
then
	cp $DFILP/${ENV_PREFIX}_ESPT0000_FCTRGRO1.dat $DFILP/${ENV_PREFIX}_ESPT0000_FCTRGRO1.dat_sav
	cp $DFILT/${ENV_PREFIX}_ESPT0000_FCTRGRO1.dat_tmp $DFILP/${ENV_PREFIX}_ESPT0000_FCTRGRO1.dat
fi

if [ -s $DFILT/${ENV_PREFIX}_ESPT0000_FCTRGRO.dat_tmp ]
then
	cp $DFILP/${ENV_PREFIX}_ESPT0000_FCTRGRO.dat $DFILP/${ENV_PREFIX}_ESPT0000_FCTRGRO.dat_sav
	cp $DFILT/${ENV_PREFIX}_ESPT0000_FCTRGRO.dat_tmp $DFILP/${ENV_PREFIX}_ESPT0000_FCTRGRO.dat
fi

if [ -s $DFILT/${ENV_PREFIX}_ESID7000_FCTRGRO.dat_tmp ]
then
	cp $DFILP/${ENV_PREFIX}_ESID7000_FCTRGRO.dat $DFILP/${ENV_PREFIX}_ESID7000_FCTRGRO.dat_sav
	cp $DFILT/${ENV_PREFIX}_ESID7000_FCTRGRO.dat_tmp $DFILP/${ENV_PREFIX}_ESID7000_FCTRGRO.dat
fi

echo "End $0 status=$? " >> $FLOG



