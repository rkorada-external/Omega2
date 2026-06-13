#==============================================================================
#nom de l'application          : recuperation du chemin et mot de passe vers une
#				imprimante
#nom du source                 : SEARCH1.sh
#revision                      : $Revision: 1.1 $
#date de creation              : /1996
#auteur                        : C.G.I. ()
#references des specifications : 
#------------------------------------------------------------------------------
#description : ce programme determine a l'aide d'une requete isql 
# les caracteristiques d'une imprimante
# --EXESRV adresse novell
# --LOGEXE user novell
# --PWDEXE Password novell
# --NOVQUEUE code queue Novell
# --CODIMPUNIX
#
#parametres :
#  $1 : site continental;filiale 
#  $2 : code impromante logique
#  $3 : prefixe du point cfg du programme appelant la chaine
#------------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
#

#==============================================================================
# Trace Unix
# set -x

#==============================================================================
#initialisation du nom do .log herite du progamme appelant
	   SN1=$4

#==============================================================================
# Fonctions communnes

ENTETE () {
 echo " " 
 echo "------------------------------------- " 
 echo $TR "\t" $LIBEL 
}

BAS () {
 echo " " 
 echo $TR "\t" $RC 
 echo "------------------------------------- " 
}

#==============================================================================
# Nom du job
NJOB="TECSEARCH"

# Variable servant a generer le fichier temporaire
SN3=`uname -n`"_"`date +"%Y%m%d%H%M%S"`"_"$$ 

#  Initialisation du code retour
RC=0

# Stockage des parametres recus

#==============================================================================

 echo "Debut du traitement\t"$NJOB 
 date 
 echo "recuperation de l'addresse et du code Queue Novell de l'imprimante" 

#==============================================================================
#  Controle de presence et recuperation des parametres 
#==============================================================================

ID=$1
CP=$2
PR=$3

 echo $ID > $ODIRTMP/tmp1_$SN3
PRDSIT=`cut -d";" -f1 $ODIRTMP/tmp1_$SN3`
GEOSIT=`cut -d";" -f2 $ODIRTMP/tmp1_$SN3`

. $ODIRTECH/TECR001.sh -G$ODIRCFG/$PR.cfg

 isql -U$USR -P$PSWD -S$SRV <<EOF >$ODIRTMP/tmp3_$SN3 2>&1
select EXESRV_CF,
LOGEXE_CF,
PASEXE_CF,
NOVQUEUE_CF,
UNIXPRT_CF

from BREF..TPRINTER
where GEOSIT_CF="$GEOSIT"
and   PRDSIT_CF="$PRDSIT"
and   PRT_CF="$CP"
go
EOF

#=========================================================================
# Teste si un imprimante a ete trouvee

sed -n -e 7p $ODIRTMP/tmp3_$SN3 >$ODIRTMP/tmp2_$SN3
EXISTANCE=`cat $ODIRTMP/tmp2_$SN3 | awk '{print substr($0,1,17)}' | cut -d" " -f1`

if test "$EXISTANCE" = "(0 rows affected)"
then
   RC=9
   echo "imprimante \n site continental : $PRDSIT, \n site geographique : $GEOSIT,\n code imprimante logique : $CP\nnon repertoriee" 
   return RC
fi

#=========================================================================
# affecte les valeurs recherchees

sed -n -e 7p $ODIRTMP/tmp3_$SN3 >$ODIRTMP/tmp2_$SN3
EXESRV=`cat $ODIRTMP/tmp2_$SN3 | awk '{print substr($0,2,32)}' | cut -d" " -f1`
LOGEXE=`cat $ODIRTMP/tmp2_$SN3 | awk '{print substr($0,35,16)}' | cut -d" " -f1` 
PWDEXE=`cat $ODIRTMP/tmp2_$SN3 | awk '{print substr($0,52,16)}' | cut -d" " -f1`
sed -n -e 8p $ODIRTMP/tmp3_$SN3 >$ODIRTMP/tmp2_$SN3
NOVQUEUE=`cat $ODIRTMP/tmp2_$SN3 | awk '{print substr($0,3,50)}' | cut -d" " -f1`

sed -n -e 9p $ODIRTMP/tmp3_$SN3 >$ODIRTMP/tmp4_$SN3
CODIMPUNIX=`cat $ODIRTMP/tmp4_$SN3 | awk '{print substr($0,3,10)}' | cut -d" " -f1`
#===========================================================================
# supression des fichiers temporaires

$ODIRTECU/RMFIL.cmd $ODIRTMP/tmp2_$SN3 2>/dev/null
$ODIRTECU/RMFIL.cmd $ODIRTMP/tmp3_$SN3 2>/dev/null
$ODIRTECU/RMFIL.cmd $ODIRTMP/tmp1_$SN3 2>/dev/null
$ODIRTECU/RMFIL.cmd $ODIRTMP/tmp4_$SN3 2>/dev/null

 echo "Fin du traitement\t"$NJOB
 