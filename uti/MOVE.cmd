#==============================================================================
#nom de l'application          : move de fichier avec rename ou pas
#nom du source                 : MOVE.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 06/10/1997
#auteur                        : S.C.O.R.
#references des specifications : 
#------------------------------------------------------------------------------
#description :
#	move les fichiers dans le repertoire passé en parametre 
#	et change son nom d'apres la variable PREFIX
#	
#Variables utilisees : elles sont positionnées par le script appelant
# $ENT		Nom ou debut de nom du fichier a deplacer
# $PREFIX	nouveau prefix
# $MOVE_PATH	nouveau repertoire
#------------------------------------------------------------------------------
#fichiers necessaires :
#
#------------------------------------------------------------------------------
#Cas d'arret anormal
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
#

#==============================================================================
# Trace Unix
# set -x
#
# Initialisation des variables
ENT=$1
PREFIX=$2
MOVE_PATH=$3

. ${DUTI}/fctgen.cmd
# Job initialisation
JOBINIT


DD="svg_"`date +"%Y%m%d"`"_"
NSTEP=${NJOB}_05
#==============================================================================
LIBEL="Move of Files"
# set -x
for FIL in `ls ${ENT}* `
do
	echo "mouvement du fichier de $FIL vers ${MOVE_PATH}"
	mv $FIL ${MOVE_PATH}/${PREFIX}_`basename ${FIL}`
	STEPEND $?
done
# else
#	echo pas de fichiers trouvés a deplacer
#	STEPEND 1
# fi
# End of Job
JOBEND 

