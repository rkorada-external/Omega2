#!/bin/ksh
#==============================================================================
#nom de l'application          : Lancement generique d'impression batch 
#nom du source                 : TECDLIMP.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 17/10/1996
#auteur                        : C.G.I. 
#references des specifications : 
#------------------------------------------------------------------------------
#description :
#	Lance une chaine d'edition en bouclant par filiale
#	Positionne le code filiale, l'imprimante par defaut et le
#	code sitecontinentatl/site geographique
# 	
#------------------------------------------------------------------------------
#parametres :
# 
#------------------------------------------------------------------------------
#fichiers necessaires :
#
#------------------------------------------------------------------------------
#Cas d'arret anormal
#
#
#------------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>

#==============================================================================
# Trace Unix
# set -x

#==============================================================================
# Fonctions communes

# test d'existence du parametre permettant de positionner les variables d'execution
if [ $# -lt 2 ]
then
	echo " Il faut preciser le script et le fichier d'environnement "
        exit 12
fi
CHAINE_ENV="${DENV}/"$2

if test ! -f ${CHAINE_ENV}
        then  echo "  fichier d'environnement "${CHAINE_ENV}" inconnu "
        exit 12
fi
. ${CHAINE_ENV}   

# Initialise la variable de reprise
RP="$3" ; export RP   

# Variable servant a generer le fichier de log
JR=`uname -n`"_"`date +"%Y%m%d"`
LOG=$ODIRLOG/$NCHAINE"_"$JR".log" 

# Affectation de la table code filiale / libelle
set -A LIBFIL "Transfert continental" "uk"  "re" "sa" "vie" "deu" "ita" "7" "8" "9" "us" "canada" "colombus" "13" "14" "15" "16" "17" "18" "19" "asie" "madrid"

# Affectation du couple site continental / site geographique cible
# ==> Impression unix : pas de valeur pour le site geographique
set -A GEO "0" "FRA1;GBR1" "FRA1;FRA1" "FRA1;FRA1" "FRA1;FRA1" "FRA1;DEU1" "FRA1;ITA1" "7" "8" "9" "USA1;USA1" "USA1;CAN1"  "FRA1;FRA1" "13" "14" "15" "16" "17" "18" "19" "SGP1;SGP1" "FRA1;ESP1"

# Imprimante des traitements batchs
#
#                 #   LONDRES  # #  SCOR RE   # #  SCOR SA   # #  SCOR VIE  # #  HANOVRE   # #    MILAN   #										              #   MADRID   #
#
set -A IMPDEF "0" "CLMQ1       " "EXPLOITATION" "EXPLOITATION" "EXPLOITATION" "DE-HP-5-SI  " "IT-HP-5-SI  " "7" "8" "9" "IMPUS" "IMPCAN"  "EXPLOITATION" "13" "14" "15" "16" "17" "18" "19" "IMPASIE" "ES-HP5-SERVE"
echo " " | tee $LOG


# ligne de commande pour paris
# for FIL in "02" "03" "04" "05" "06" "12"

# remise en route traitement pour filiale 01 (scor UK) le 14/08/97
for FIL in "01" "02" "03" "04" "05" "06" "12"
do
	echo "debut de traitement pour la filiale n " $FIL | tee -a $LOG
	${ODIRUTI}/$1 $2 $FIL ${IMPDEF[$FIL]} ${GEO[$FIL]}
done
