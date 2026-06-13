#==============================================================================
#nom de l'application          : Mise a jour de  ttaskqueue
#nom du source                 : TECANSW.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 4/12/1996
#auteur                        : C.G.I. ()
#references des specifications : 
#------------------------------------------------------------------------------
#description : Ce shell permet de renseigner la table ttaskqueue sur le nom du fichier de sortie cree par un programme lance en asynchrone par PowerBuilder
# 
#
# 	
#
#parametres :
#  $1 : code utilisateur 
#  $2 : prefixe du.cfg associe au traitement
#  $2 : nom du job
#  $3 : date de lancement
#  $4 : texte a envoyer
#
#variables d'environnement
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
NJOB="TECANSW"

# Variable servant a generer le fichier temporaire
SN1=`uname -n`"_"`date +"%Y%m%d%H%M%S"`"_"$$ 

#  Initialisation du code retour
RC=0

# Stockage des parametres recus

#==============================================================================

 echo "Debut du traitement\t"$NJOB 
 date 
 echo "Mise a jour de ttaskqueue"

#==============================================================================
#  recuperation des parametres 

LIBEL="Controle nombre de parametre "
ENTETE

if test $# -eq 5
then
   CODUSER=$1
   PREF=$2
   JOBID=$3
   DATELANC=$4
   TEXT=$5
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
#  Mise a jour de ttaskqueue
#==============================================================================

 isql -U$USER -P$MP -S$SRV << EOF > $ODIRTMP/tmp1_$SN1 

declare @return varchar(64),
	 @return2 int

exec @return2=BTEC..Putaskqueue_01 '$JOBID','$DATELANC','$CODUSER',
'$TEXT',@return

select @return
go
EOF

#=================================================
# formatage du fichier de reponse cree en isql

sed -n -e 1p $ODIRTMP/tmp1_$SN1 > $ODIRTMP/tmp2_$SN1
ITSOK=`cat $ODIRTMP/tmp2_$SN1 | nawk '{print substr($0,1,19)}'` 
sed -n -e 4p $ODIRTMP/tmp1_$SN1 > $ODIRTMP/tmp3_$SN1

#=============================================================
# effacement des fichiers temporaires
$ODIRTECU/RMFIL.cmd $ODIRTMP/tmp1_$SN1 
$ODIRTECU/RMFIL.cmd $ODIRTMP/tmp2_$SN1 

if test "$ITSOK" = "(return status = 0)"
then 
   RC=0
   $ODIRTECU/RMFIL.cmd $ODIRTMP/tmp3_$SN1 
   exit $RC 
else
   RC=9
   cat $ODIRTMP/tmp3_$SN1
   $ODIRTECU/RMFIL.cmd $ODIRTMP/tmp3_$SN1 
   exit $RC
fi
 echo "Fin du traitement\t"$NJOB 
