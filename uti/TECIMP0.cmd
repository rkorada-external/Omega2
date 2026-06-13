#==============================================================================
#nom de l'application          : Transfert de fichier / impression
#nom du source                 : TECIMP0.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 24/10/1996
#auteur                        : C.G.I. ()
#------------------------------------------------------------------------------
#description :
# impression Starjet: determine si l'impression est locale ou continentale	
# et agit en consequence (lancement Starpage (continental) ou transfert FTP
# des .lis et .dae zippes vers le serveur d'impression (local))
#
#parametres :
#  $1 : Nom etat starpage a editer 
#  $2 : site continental;filiale (filiale si impression filiale ";" obligatoire
#							dans les deux cas)
#  $3 : code imprimante logique
#  $4 : prefixe du .cfg du traitement en cours
#  $5 : chemin et nom du .lis  
#  $6 : nom du .sp
#  $7 : numero filiale             
#
#variables d'environnement
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
# Fonctions communes

ENTETE () {
 echo "------------------------------------- " 
 echo $TR "\t" $LIBEL 
 date
}

BAS () {
 echo $TR "\t" Code retour $RC
}

#==============================================================================
# Nom du job
NJOB="TECIMP0"

# Variable servant a generer le fichier temporaire
SN2=`uname -n`"_"`date +"%Y%m%d%H%M%S"`"_"$$
 
#  Initialisation du code retour
RC=0

#==============================================================================

 echo 
 echo "Debut du traitement\t"$NJOB 
 date 
 echo "routage des donnees a imprimer vers le serveur destinataire" 

#==============================================================================
#  Controle de presence et recuperation des parametres 

TR="TECIMP0_05"
LIBEL="Controle nombre de parametres "
ENTETE
	if test $# -eq 7
	then
	   ETAT=$1
	   SITE=$2
	   CODIMP=$3
	   PREF=$4
	   NOMLIS=$5
	   SP=$6
	   NFIL=$7
	else
 echo "nombre de parametres incorrect " 
	   RC=9
	fi
BAS
 . $ODIRTECU/TEST_RC.cmd $RC
 
#==============================================================================
# Determination du dernier numero de fichier utilise et mise a jour ds TFILSUP

TR="TECIMP0_10"
LIBEL="Affectation du numero de fichier "
ENTETE
. $ODIRTECH/TECR001.sh -G$ODIRCFG/$PREF.cfg

DOM=sjt
isql -U$USR -P$PSWD -S$SRV << EOF >$ODIRTMP/tmp5_$SN2  
select 
convert(char(6),isnull(max(NUM_NF),0)+100001)
from BTEC..TFILSUP
where DOM_CF="$DOM"
go
EOF
sed -n -e 3p $ODIRTMP/tmp5_$SN2 | sed '1,$s/ //g' > $ODIRTMP/tmp4_$SN2
MAXNUM=`cat $ODIRTMP/tmp4_$SN2 | awk '{print substr($0,2,5)}'`

isql -U$USR -P$PSWD -S$SRV <<EOF >$ODIRTMP/tmp6_$SN2
update BTEC..TFILSUP set NUM_NF=convert(int,"$MAXNUM")
where DOM_CF="$DOM"
go
EOF
$ODIRTECU/RMFIL.cmd $ODIRTMP/tmp6_$SN2
$ODIRTECU/RMFIL.cmd $ODIRTMP/tmp5_$SN2
$ODIRTECU/RMFIL.cmd $ODIRTMP/tmp4_$SN2                 
BAS 
  
#==============================================================================
# Si il s'agit d'une impression Starpage continentale (Pas de filiale indiquee)
   TR="TECIMP0_15"
   LIBEL="Impression par Starpage "
   ENTETE
   FILIALE=`echo "$SITE" | cut -d";" -f2`
   SITE_C=`echo "$SITE" | cut -d";" -f1`
   if [ $FILIALE = $SITE_C ]
   then
   
#==============================================================================
# on lit le code imprimante UNIX de la machine a atteindre

. $ODIRTECU/TECSEARCH.cmd $SITE $CODIMP $PREF $SN1

if test -z "$CODIMPUNIX"
then 
  echo "code imprimante unix non recupere"
  RC=12
fi

 . $ODIRTECU/TEST_RC.cmd $RC 
   BAS
#==============================================================================
# Rename et Sauvegarde du fichier .lis 
      
      TR="TECIMP0_20"
      LIBEL="Sauvegarde du fichier lis " 
      ENTETE      
    mv ${NOMLIS} ${ODIRTMP}/sjt${MAXNUM}.lis
    NOMLIS=${ODIRTMP}/sjt${MAXNUM}.lis  
    ${ODIRTECU}/COPY.cmd ${NOMLIS} ${DLST} ${NCHAINE}_${FILIALE}_${NFIL}_${ETAT}
      BAS
      

#==============================================================================
# Ordre d'imprimer le document directement par starpage

      cd $ODIRSTAR
      PRN_FMT=`basename $SP .sp`
      $STARDIR/starpage -c$ODIRSTAR"/"$SP -d$CODIMPUNIX -oufile=${NCHAINE} -oujob=${PRN_FMT} $NOMLIS
      RC=$?
      cd $OLDPWD
      if test $RC -gt 1
      then
      . $ODIRTECU/TEST_RC.cmd $RC
      else
       RC=0
      fi
      BAS
       
      $ODIRTECU/RMFIL.cmd $NOMLIS
      
#==============================================================================
# Si il s'agit d'une impression Starpage dans une filiale

   else

#==============================================================================
# mouvement du .lis a envoyer dans un fichier temporaire

NEWNOMLIS=sjt$MAXNUM.lis
NOMDAE=sjt$MAXNUM.dae
mv $NOMLIS $ODIRTMP/$NEWNOMLIS

#==============================================================================
# On lit le code imprimante NOVELL  le user le password, et le code QUEUENOVELL
# de la machine a atteindre

 . $ODIRTECU/TECSEARCH.cmd $SITE $CODIMP $PREF $SN1

if [ -z "$EXESRV" ] || [ -z "$LOGEXE" ] || [ -z "$NOVQUEUE" ]
then 
  echo "il manque un ou des parametres d'adressage dans TPRINTER pour l'imprimante demandee"
  RC=12
fi

 . $ODIRTECU/TEST_RC.cmd $RC 

# Verif de la table taddip
#-------------------------
	grep -l "$SITE" $ODIRTAB/taddip.1
	RC=$?
	. $ODIRTECU/TEST_RC.cmd 

#==============================================================================
# On lit l'adresse IP de la machine distante puis le code user et le password

      ADR=`grep "$SITE" $ODIRTAB/taddip.1 | cut -d";" -f10 | cut -d" " -f1`
      USR=`grep "$SITE" $ODIRTAB/taddip.1 | cut -d";" -f11 | cut -d" " -f1` 
     PSWD=`grep "$SITE" $ODIRTAB/taddip.1 | cut -d";" -f12 | cut -d" " -f1` 
   ENDREP=`grep "$SITE" $ODIRTAB/taddip.1 | cut -d";" -f13 | cut -d" " -f1` 
    CDFTP=`grep "$SITE" $ODIRTAB/taddip.1 | cut -d";" -f14 | cut -d" " -f1`

if [ -z "$ADR" ] || [ -z "$USR" ] || [ -z "$ENDREP" ] || [ -z "$CDFTP" ]
then 
  echo "il manque un ou des parametres d'adressage dans taddip.1 pour le serveur d'impression"
  RC=12
fi 
. $ODIRTECU/TEST_RC.cmd
BAS
#==============================================================================
# Constitution du fichier d'ordre pour le demon

      TR="TECIMP0_25"
      LIBEL="Ecriture Fichier d'ordre daemon"
      ENTETE
      BSTAR='&'starjet
      BSP='&'"$SP"
      BNEWNOMLIS='&'"$NEWNOMLIS"

# H. GUIHEUX le 31/07/2000
# Prise en compte demande de correction de G. Balabanian
      # Building dae file for starjet
      SJTID=$MAXNUM
      ERRREP="c:\\daemon\\temp\\error\\"

# H. GUIHEUX le 19/06/2000
# Prise en compte demande de correction de G. Balabanian
#
#echo "Starjet,/cc:$BSTAR$BSP /d\"\$PRINTERQUEUE=$NOVQUEUE\$\" $ENDREP$BNEWNOMLIS,,NW312=$EXESRV;$LOGEXE;$PWDEXE" >$ODIRTMP/1_$NOMDAE 

printf "Starpage,/sFile=%s%s /cc:%s%s /d\"%s\" %s%s,,NW312=%s;%s;%s\n" ${ERRREP} "sjt${SJTID}.log" ${BSTAR} ${BSP} ${NOVQUEUE} ${ENDREP} ${BNEWNOMLIS} ${EXESRV} ${LOGEXE} ${PWDEXE}> $ODIRTMP/1_$NOMDAE

	cat $ODIRTMP/1_$NOMDAE | sed '1,$ s/&/\\/g' > $ODIRTMP/2_$NOMDAE
      mv $ODIRTMP/2_$NOMDAE $ODIRTMP/$NOMDAE
      RC=$?
            . $ODIRTECU/TEST_RC.cmd 

      $ODIRTECU/RMFIL.cmd $ODIRTMP/1_$NOMDAE 2>/dev/null
      BAS
#==============================================================================
# Sauvegarde des fichiers .lis et .dae

      TR="TECIMP0_30"
      LIBEL="Sauvegarde des fichiers lis et dae " 
      ENTETE
    ${ODIRTECU}/COPY.cmd ${ODIRTMP}/${NEWNOMLIS} ${DLST} ${NCHAINE}_${FILIALE}_${NFIL}_${ETAT}  
    ${ODIRTECU}/COPY.cmd ${ODIRTMP}/${NOMDAE} ${DLST} ${NCHAINE}_${FILIALE}_${NFIL}_${ETAT}      
      BAS
      
# #############################################################################      
# pour ne pas envoyer le report FACR076B a hanovre
# #############################################################################

# if [ ${FILIALE} != "DEU1" ] || [ ${ETAT} != "FACR076B" ]
#	then
	
# #############################################################################
	      
##==============================================================================
# Transfert par FTP des fichiers .lis et .dae

      TR="TECIMP0_35"
      LIBEL="transfert Ftp lis et dae " 
      ENTETE
      CDFTP1=`echo "$CDFTP" | sed '1,$ s/\\\\/\\\\\\\\/g'`
      cd $ODIRTMP
        ftp -n $ADR << EOF
user $USR $PSWD
cd $CDFTP1
ascii
verbose
put $NEWNOMLIS
put $NOMDAE
quit
EOF

      RC=$?
   . $ODIRTECU/TEST_RC.cmd 
      BAS
# fi

##==============================================================================
# Test (impression a Paris des impressions envoyées aux filiales)
#	cd $ODIRSTAR
#	$STARDIR/starpage -c$ODIRSTAR"/"$SP -dimp0 $ODIRTMP/$NEWNOMLIS
#	RC=$?
#	echo "Code retour :" $RC
#	if test $RC -eq 1
#	then
#	    RC=0
#	fi
#	cd $OLDPWD
#
#==============================================================================	
  
 $ODIRTECU/RMFIL.cmd $ODIRTMP/$NOMDAE
 $ODIRTECU/RMFIL.cmd $ODIRTMP/$NEWNOMLIS
 
fi 

#==============================================================================
# Fin de traitement
 echo "Fin du traitement "$NJOB
 echo "-------------------------------------" 
 echo "\t\n " 
return $RC
