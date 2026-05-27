#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS
# nom du script SHELL           : COPY
# revision                      : $Revision: 1.0 $
# date de creation              : 08/03/2021
# auteur                        : MZM
#-----------------------------------------------------------------------------
# description : 
#               Copie de fichiers sur ITK AZ
#               executé par DBATOOLS/CNLD0030
#-----------------------------------------------------------------------------
#

# Call generic functions

#!/bin/ksh

. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

CHAININIT CNLD0030 $DENV/CNLD0030.env

NJOB=${ENV_PREFIX}_CNLD0030_CNLD0031

# Initialization of the Job
JOBINIT

#set -x
echo "Starting $0 $1" >> $FLOG


echo "PREFIX COURANT ${ENV_PREFIX}"

NSTEP=${NCHAIN}_${NJOB}_05
LIBEL="Clean empty"


## PERM


EXECKSH "cp $DFILP/${ENV_PREFIX}_ESCJ0060_FTRSLNK_INV_20210331.dat 			$DFILP/${ENV_PREFIX}_ESCJ0060_FTRSLNK_POS_20201231.dat"
EXECKSH "cp $DFILP/${ENV_PREFIX}_ESCJ0060_FBOPRSLNK_INV_20210331.dat 		$DFILP/${ENV_PREFIX}_ESCJ0060_FBOPRSLNK_POS_20201231.dat"         
EXECKSH "cp $DFILP/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_INV_20210331.dat 	$DFILP/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_POS_20201231.dat"         
EXECKSH "cp $DFILP/${ENV_PREFIX}_ESCJ0060_FCURQUOT_INV_20210331.dat 		$DFILP/${ENV_PREFIX}_ESCJ0060_FCURQUOT_POS_20201231.dat"         
EXECKSH "cp $DFILP/${ENV_PREFIX}_ESCJ0060_FDETTRS_INV_20210331.dat   		$DFILP/${ENV_PREFIX}_ESCJ0060_FDETTRS_POS_20201231.dat" 

EXECKSH "cp $DFILP/${ENV_PREFIX}_ESCJ0060_FTRSLNK_TXT_INV_20210331.dat 			$DFILP/${ENV_PREFIX}_ESCJ0060_FTRSLNK_TXT_POS_20201231.dat"
EXECKSH "cp $DFILP/${ENV_PREFIX}_ESCJ0060_FBOPRSLNK_TXT_INV_20210331.dat 		$DFILP/${ENV_PREFIX}_ESCJ0060_FBOPRSLNK_TXT_POS_20201231.dat"         
##EXECKSH "cp $DFILP/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_TXT_INV_20210331.dat 	$DFILP/${ENV_PREFIX}_ESCJ0060_FTRANSCODE_TXT_POS_20201231.dat"         
EXECKSH "cp $DFILP/${ENV_PREFIX}_ESCJ0060_FCURQUOT_TXT_INV_20210331.dat 		$DFILP/${ENV_PREFIX}_ESCJ0060_FCURQUOT_TXT_POS_20201231.dat"         
EXECKSH "cp $DFILP/${ENV_PREFIX}_ESCJ0060_FDETTRS_TXT_INV_20210331.dat   		$DFILP/${ENV_PREFIX}_ESCJ0060_FDETTRS_TXT_POS_20201231.dat" 

        
##EXECKSH "cp $DFILP/${ENV_PREFIX}_ESCJ0060_FTRSLNK_INV_20210331.dat $DFILP/${ENV_PREFIX}_ESCJ0060_FTRSLNK_20201231.dat"         

echo $? >> $FLOG


set +x

JOBEND

