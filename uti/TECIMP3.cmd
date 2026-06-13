#==============================================================================
#nom de l'application          : Transfert de fichiers / extraction access
#nom du source                 : TECIMP3.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 4/12/1996
#auteur                        : C.G.I. ()
#------------------------------------------------------------------------------
#description :
#  Transfert vers un serveur bureautique d'un fichier d'extraction pour
#  Access et d'un fichier .dae d'ordre au daemon du serveur Bureautique
#  apres envoi par ftp
#parametres :
#  $1 : code Utilisateur
#  $2 : site continental;filiale (filiale si impression filiale ";" obligatoire
#							dans les deux cas)
#  $3 : prefixe du .cfg du traitement en cours
#  $4 : nom du .dat (avec chemin)
#  $5 : nom du .txt (avec chemin)
#
#variables d'environnement
#  $ODIRTAB=/home/scordev/otec/1.0/work/commun/fic
#  $ODIRSTAR pour le domaine demandeur
#  $ODIRSQR pour le domaine demandeur
#------------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
#

#==============================================================================
# Trace Unix
# set -x


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
NJOB="TECIMP3"

# Variable servant a generer le fichier temporaire
SN2=`uname -n`"_"`date +"%Y%m%d%H%M%S"`"_"$$ 

#  Initialisation du code retour
RC=0

# Stockage des parametres recus

#==============================================================================

 echo 
 echo "Debut du traitement\t"$NJOB 
 date 
 echo "routage des donnees pour l'extraction access vers le serveur destinataire" 

#==============================================================================
#  Controle de presence et recuperation des parametres 

LIBEL="Controle nombre de parametre "
ENTETE
if test $# -eq 5
then
   CODUSER=$1
   SITE=$2
   PREF=$3
   NOMDAT=$4
   NOMTXT=$5
else
 echo "nombre de parametres incorrect " 
	   RC=9
fi
BAS
 . $ODIRTECU/TEST_RC.cmd $RC 
#==============================================================================
# Traitement d'une extraction Access
#==============================================================================

#==============================================================================
# On lit l'adresse IP de la machine distante puis le code user et le password

      ADR=`grep "$SITE" $ODIRTAB/taddip.1 | cut -d";" -f6 | cut -d" " -f1`
      USR=`grep "$SITE" $ODIRTAB/taddip.1 | cut -d";" -f7 | cut -d" " -f1` 
     PSWD=`grep "$SITE" $ODIRTAB/taddip.1 | cut -d";" -f8 | cut -d" " -f1` 
   ENDREP=`grep "$SITE" $ODIRTAB/taddip.1 | cut -d";" -f9 | cut -d" " -f1` 
    MVREP=`grep "$SITE" $ODIRTAB/taddip.1 | cut -d";" -f15 | cut -d" " -f1` 
    CDFTP=`grep "$SITE" $ODIRTAB/taddip.1 | cut -d";" -f16 | cut -d" " -f1`

#==============================================================================
# Controle de presence des parametres adresse du site d'impression

      LIBEL="Controle de presence de l'adresse du site d'impression"
      ENTETE
if [ -z "$ADR" ] || [ -z "$USR" ] || [ -z "$ENDREP" ] || [ -z "$CDFTP" ] || [ -z "$MVREP" ]
then 
  echo "il manque un ou des parametres d'adressage dans le fichier taddip.1 pour le serveur bureautique"
  RC=12
fi 
. $ODIRTECU/TEST_RC.cmd
BAS 

#==============================================================================
# Determination du nom des fichiers sans le chemin

SHORTNOMDAT=`basename $NOMDAT`
SHORTNOMTXT=`basename $NOMTXT`
CHEMIN=`dirname $NOMDAT` 

#==============================================================================
# Constitution du fichier d'ordre pour le demon


      LIBEL="Ecriture Fichier d'ordre daemon"
      ENTETE
      PREFIXDAT=`echo "$SHORTNOMDAT" | cut -d"." -f1`
      SHORTNOMDAE="$PREFIXDAT".dae
      MVREP2=$MVREP; echo $MVREP2
      MVREP1=` echo "$MVREP"  | sed '1,$ s/\\\\/\\\\\\\\/g'`
      ENDREP1=`echo "$ENDREP" | sed '1,$ s/\\\\/\\\\\\\\/g'`

 echo "Movefile,$PREFIXDAT $ENDREP1 $MVREP2" >$CHEMIN/$SHORTNOMDAE
 echo "$CODUSER" >>$CHEMIN/$SHORTNOMDAE 
 cat $NOMTXT >>$CHEMIN/$SHORTNOMDAE

 ${ODIREXE}/TECMDOS.exe ${CHEMIN}/${SHORTNOMDAT}
 ${ODIREXE}/TECMDOS.exe ${CHEMIN}/${SHORTNOMDAE}

#==============================================================================
# Zip des fichiers

	SHORTNOMZIP="$PREFIXDAT".zip
	${PKZIPDIR}/pkzip ${CHEMIN}/${SHORTNOMZIP} -pmex ${CHEMIN}/${SHORTNOMDAE} ${CHEMIN}/${SHORTNOMDAT}

 echo "MoveZipFile,$PREFIXDAT $ENDREP1 $MVREP1 $PREFIXDAT" >$CHEMIN/$SHORTNOMDAE
##==============================================================================
# Transfert par FTP des fichiers .dat et .dae

      LIBEL="transfert Ftp lis et dae " 
      ENTETE

      CDFTP1=`echo "$CDFTP" | sed '1,$ s/\\\\/\\\\\\\\/g'`
      cd $CHEMIN
      timex ftp -n $ADR << EOF
user $USR $PSWD
cd $CDFTP1
binary
verbose
put $SHORTNOMZIP
put $SHORTNOMDAE
quit
EOF

      RC=$?
      BAS
 . $ODIRTECU/TEST_RC.cmd 
 
$ODIRTECU/RMFIL.cmd $CHEMIN/$SHORTNOMZIP
$ODIRTECU/RMFIL.cmd $CHEMIN/$SHORTNOMTXT
$ODIRTECU/RMFIL.cmd $CHEMIN/$SHORTNOMDAE

echo "Fin du traitement\t"$NJOB 
return $RC
