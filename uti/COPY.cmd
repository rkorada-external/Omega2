#==============================================================================
#nom de l'application          : copie de fichiers
#nom du source                 : COPY.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 16/01/97
#auteur                        : S.C.O.R.
#references des specifications : 
#------------------------------------------------------------------------------
#description :
#	Copie les fichiers à sauvegarder pour une reprise éventuelle après 
#       plantage
#	
#Variables utilisees : elles sont positionnées par le script appelant
# $NCHAINE
# $FICCHAINE
#------------------------------------------------------------------------------
#parametres :
#   
#  $1 nom avec le path du fichier origine  OBLIGATOIRE
#  $2 path du fichier en sortie             OBLIGATOIRE
#  $3 prefix du fichier de sauvegarde
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
FIN () {
echo "\nfin de traitement \t"$NJOB   
echo "------------------------------------- "  
date   
echo "\n"   
}

# Initialisation des variables
# path en sortie + prefix eventuel + date de sauvegarde
DD=$2/$3_`date +"%Y%m%d"`"_"
# Nom du job
NJOB="COPY"
# fichier en entrée
ENT=$1

echo "\ndébut de traitement \t"$NJOB   
echo "------------------------------------- "  
date   
 
if [ $# -lt 2 ]
then
  echo ""
  echo "  Usage : COPY.cmd  <fichier en entrée> <path en sortie> <prefix eventuel>  "
  echo ""
 fi

if test -f $ENT
then
	
	echo " "
	echo copie du fichier  $ENT vers $DD`basename $ENT`
	cp $ENT $DD`basename $ENT `
else
	echo fichier $ENT inexistant
fi

FIN
exit 0