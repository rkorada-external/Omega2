#
# descente d'une table
#set -x


NCHAIN=${ENV_PREFIX}_CNLD0030
NJOB=CNLD0031

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fcttransfer.cmd
. ${DUTI}/fctftp.cmd

CHAININIT $0 $DENV/CNLD0030.env

# Job Initialisation
JOBINIT

#('TR0018888','TR0018983','TR0019525','TR0019526','TR0019493')

echo "--->  sauve LIFSTAREP"
gzip -c ${DFILP}/${ENV_PREFIX}_ESPT0000_LIFSTAREP.dat > ${DSAVE}/${ENV_PREFIX}_ESPT0000_LIFSTAREP.dat.gz
gzip -c ${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat > ${DSAVE}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat.gz

grep ~18~TR00 ${DFILP}/${ENV_PREFIX}_ESPT0000_LIFSTAREP.dat
grep ~18~TR00 ${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat

#############################################################
echo "--->  Retire ctrs avec filiale 18 invalide ESPT0000_LIFSTAREP - archive"
#############################################################
grep ~18~TR00 ${DFILP}/${ENV_PREFIX}_ESPT0000_LIFSTAREP.dat > ${DARCH}/${ENV_PREFIX}_ESPT0000_LIFSTAREP_ctrsSSDInvalide.dat
#############################################################
echo "--->  Retire ctrs avec filiale 18 invalide update"
grep -v ~18~TR00 ${DFILP}/${ENV_PREFIX}_ESPT0000_LIFSTAREP.dat > ${DFILT}/${ENV_PREFIX}_ESPT0000_LIFSTAREP.dat
mv ${DFILT}/${ENV_PREFIX}_ESPT0000_LIFSTAREP.dat ${DFILP}/${ENV_PREFIX}_ESPT0000_LIFSTAREP.dat
 
#############################################################
echo "--->  Retire ctrs avec filiale 18 invalide STAD1500_LIFSTAREP - archive"
#############################################################
grep ~18~TR00 ${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat > ${DARCH}/${ENV_PREFIX}_STAD1500_LIFSTAREP_ctrsSSDInvalide.dat
#############################################################
echo "--->  Retire ctrs avec filiale 18 invalide update"
grep -v ~18~TR00 ${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat > ${DFILT}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat
mv ${DFILT}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat ${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat

grep ~18~TR00 ${DFILP}/${ENV_PREFIX}_ESPT0000_LIFSTAREP.dat
grep ~18~TR00 ${DFILP}/${ENV_PREFIX}_STAD1500_LIFSTAREP.dat

JOBEND
