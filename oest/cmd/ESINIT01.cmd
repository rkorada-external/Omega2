# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

REF_SPOT=${1}

# Job Initialisation
JOBINIT

# 
. $DFILP/${ENV_PREFIX}_ESINIT00_${REF_SPOT}.dat

gzip $DFILP/${ENV_PREFIX}_ESINIT00_${REF_SPOT}.dat


JOBEND
