#==============================================================================
#nom de l'application          : Transfert de fichier avec verification
#nom du source                 : TECCALL3.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 4/12/1996
#auteur                        : C.G.I. ()
#references des specifications : 
#------------------------------------------------------------------------------
#description : apres les modules de formatage des fichiers d'extraction Access ce module appelle le shell d'appel du transfert FTP des donnees vers le serveur Bureautique
# I
#
# 	
#
#parametres :
#  $1 : code utilisateur 
#  $2 : PREF prefixe du traitement en cours (ex : clim0002A)
#  $3 : Nom .dat (avec chemin)
#  $4 : Nom du .txt (avec chemin)
#
#variables d'environnement
#  $ODIRFIC=/home/scordev/otec/1.0/work/commun/fic
#  $ODIRTECU=/home/scordev/otec/0.1/work/commun/sh
#  $ODIRSTAR pour le domaine demandeur
#  $ODIRSQR pour le domaine demandeur
#------------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
#

#==============================================================================
# Trace Unix
#set -x

#==============================================================================
# Fonctions communes
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

# Initialisation des variables

#==============================================================================
# Nom du job
NJOB="TECCALL3"

# Variable servant a generer le fichier temporaire
SN1=`uname -n`"_"`date +"%Y%m%d%H%M%S"`"_"$$ 

#  Initialisation du code retour
RC=0

# Stockage des parametres recus

#==============================================================================

 echo "Debut du traitement\t"$NJOB 
 date 
 echo "determination du code site geographique et du code site continental" 

#==============================================================================
#  recuperation des parametres 

LIBEL="Controle nombre de parametre "
ENTETE

if test $# -eq 4
then
   CODUSER=$1
   PREF=$2
   NOMDAT=$3
   NOMTXT=$4
else
   RC=9
fi

BAS
 . $ODIRTECU/TEST_RC.cmd $RC 

#==============================================================================
# Appel du shell de recup des variables d'acces a SYBASE a partir du .cfg
# Ramene dans le shell les variables $USR $PSWD $SRV
#==============================================================================
. $ODIRTECH/TECR001.sh -G$ODIRCFG/$PREF.cfg
#==============================================================================
# Determination par isql des codes site continental et site filiale
#==============================================================================

 isql -U$USER -P$MP -S$SRV << EOF > $ODIRTMP/tmp1_$SN1 
select "export GEOSIT=",'"',a.GEOSIT_CF,'"',";export PRDSIT=",'"',b.PRDSIT_CF,'"'
from BREF..TUSR a, BREF..TSUBSID b
where a.USR_CF= '$CODUSER'
and   a.SSD_CF=b.SSD_CF
go
EOF

#=================================================
# formatage du fichier de commande cree en isql

sed -n -e 3p $ODIRTMP/tmp1_$SN1 > $ODIRTMP/tmp2_$SN1
sed '1,$ s/      //g' $ODIRTMP/tmp2_$SN1 > $ODIRTMP/tmp1_$SN1
sed '1,$ s/ " /"/g' $ODIRTMP/tmp1_$SN1 > $ODIRTMP/tmp2_$SN1

#=============================================================
# execution et effacement des fichiers de commande temporaires

. $ODIRTMP/tmp2_$SN1
$ODIRTECU/RMFIL.cmd $ODIRTMP/tmp1_$SN1 
$ODIRTECU/RMFIL.cmd $ODIRTMP/tmp2_$SN1 
#==============================================================================
# Appel du shell de routage des impressions
#==============================================================================

$ODIRTECU/TECIMP3.cmd  $CODUSER "$PRDSIT;$GEOSIT" $PREF $NOMDAT $NOMTXT
RC=$?
 . $ODIRTECU/TEST_RC.cmd $RC 

 echo "Fin du traitement\t"$NJOB 
 echo "-------------------------------------" 
