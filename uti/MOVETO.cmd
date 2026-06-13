#==============================================================================
#nom de l'application          : Transfert de fichier avec verification
#nom du source                 : MOVETO.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 25/07/1996
#auteur                        : S.C.O.R.
#references des specifications : 
#------------------------------------------------------------------------------
#description :
#	Copie les fichiers a transferer dans les repertoires correspondants 
#	a chaque site continental ou satellite
#	
#Variables utilisees : elles sont positionnées par le script appelant
# $LOG
# $FICCHAINE
#------------------------------------------------------------------------------
#parametres :
#   
#  &1 code application (tr pour traites cl pour client )
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
echo "\nfin de traitement \t"$NJOB 2>&1  
echo "------------------------------------- "  
date 2>&1  
echo "\n" 2>&1  
}

# Initialisation des variables

DD="svg_"`date +"%Y%m%d"`"_"
# Nom du job
NJOB="MOVETO"
# Répertoire
ENT="/nfsprod1/scorftp"

echo "\ndébut de traitement \t"$NJOB 2>&1  
echo "------------------------------------- "  
date 2>&1  

for FIL in "001" "002" "003" "004" "005" "006"
do
	echo "filiale "$FIL  
	echo "domaine "$1  
#  
	case $FIL in
		"001") REP=london;;
		"002") REP=mvs;;
		"003") REP=mvs;;
		"004") REP=mvs;;
		"005") REP=hanover;;
		"006") REP=milan;;
		*) echo "destination inconnue !! " $FIL  ;FIN;;
	esac
# 
	echo " "
	echo "mouvement des fichiers de" $ENT/$REP"/to vers "$ENT/$REP"/tosave"  
	for DSN in `ls $ENT/$REP/to/*$FIL$1*`
		do
			echo $DSN  
			mv $DSN "$ENT/$REP/tosave/"$DD`basename $DSN `
		done
	echo " "
# 
	echo "mouvement des fichiers de" $FICCHAINE"/DIA_"$FIL$1"* vers "$ENT/$REP"/to"  
	mv  $FICCHAINE/DIA*$FIL$1* $ENT/$REP/to
	echo $FICCHAINE/DIA*$FIL$1*  
done
# 


FIN

