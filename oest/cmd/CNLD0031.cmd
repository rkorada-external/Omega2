
#===============================================================
#application name               : Checkers-Loaders : Execution d'un fichier de commandes Unix et Awk
#source name                    : CNLD0031.cmd
#revision                       : $Revision:   1.0  $
#creation date                  : 09/12/2008
#author                         : Roger Cassis
#specifications reference       :
#---------------------------------------------------------------
#description :
#  :spot:16588 - Ce job permet d'exécuter un fichier de commandes Unix et (ou) awk
#  Le fichier doit etre transféré par FTP sous ce nom ${DFILT}/${NCHAIN}_${SOURCE}_CMDAWK.dat.
#  SOURCE = nom personnalisé
#parameters :
#     Nom du SOURCE par parametre dans la ligne de commande
#
#---------------------------------------------------------------
#modifications chronology  :
#[001] 21/10/2011 Roger Cassis   :spot:22752 - Affinage du nom de fichier parametre
#[002] 21/02/2013 Roger Cassis   :spot:24846 - Version 2 : Ajout extraction du fichier de commandes par ftp
#[003] 09/04/2013 Roger Cassis   :spot:25108 - Gestion fichier de commandes sur repertoire conversion (TST_NYK_CNV)
#[004] 01/08/2013 Roger Cassis   :spot:25176 - Adaptations a PROD O2
#[005] 08/11/2013 Roger Cassis   :spot:25772 - Adaptations a PROD O2 - UAT 1B - INT 1B
#[006] 03/04/2014 Roger Cassis   :spot:25427 - Adaptations a PROD O2 - 1B - utilisation du DEFAULT_SQL_LOGIN au lieu du logname
#[007] 20/08/2014 Roger Cassis   :spot:25773 - Adaptations to 2B, add CNLD0030.prm for server names
#[008] 17/04/2015 Roger Cassis   :spot:28638 - Adaptation configuration to new dbatools server adress
#[009] 27/05/2016 Roger Cassis   :spot:28469 - Ajout serveur Conversion 2 et mutre
#[010] 02/06/2021 Roger Cassis   :spira:90500 - Changement nom du serveur
#===============================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# No Entry parameters
SOURCE=$1

# Recherche repertoire origine du fichier
# Defaut pour serveurs non definis
case ${HOST_PRDSIT} in
	FRA1)
		site1=PAR
		break
		;;
	USA1)
		site1=NYK
		break
		;;
	SGP1)
		site1=SGP
		break
		;;
esac

serveur=`uname -n`

env1=`grep ${serveur} ${DPRM}/CNLD0030.prm | cut -d";" -f2`

#[007]
env2="UBEU"
if [ "${DEFAULT_SQL_LOGIN}" = "ubam" ]
then
	env2="UBAM"
fi
if [ "${DEFAULT_SQL_LOGIN}" = "ubas" ]
then
	env2="UBAS"
fi
if [ "${DEFAULT_SQL_LOGIN}" = "ubgl" ]
then
	env2="UBGL"
fi
if [ "${env1}" != "" ]
then
	chsource=${env1}_O2_${env2}
else
	chsource=TST_${site1}
fi

#[009]
if [ "${HOST_PRDSIT}" = "FRAM" ]
then
	chsource=${env1}
fi

if [ "${SOURCE}" != "" ]
then
	ECHO_LOG "=================================================================================="
	ECHO_LOG "==> Fichier a traiter   : ${DFILT}/${NCHAIN}_${SOURCE}.dat"
	ECHO_LOG "==> serveur             : ${serveur}"
	ECHO_LOG "==> Chemin d'extraction : /scor/livraison/tmp/${chsource}"
	ECHO_LOG "=================================================================================="
else
	ECHO_LOG "=================================================================================="
	ECHO_LOG "==> Manque parametre SOURCE, partie du nom du fichier - ARRET"
	ECHO_LOG "==> Syntaxe de lancement : CNLD0030.cmd = SOURCE"
	ECHO_LOG "==> Le fichier de commandes doit se trouver sur dcvdevobbatch sous ce format:"
	ECHO_LOG "==> /scor/livraison/tmp/${chsource}/${NCHAIN}_${SOURCE}.dat"
	ECHO_LOG "==> SOURCE étant un nom personnalisé qui identifie le fichier"
	ECHO_LOG "=================================================================================="
	JOBEND
fi

# Job Initialization
JOBINIT

#[008]
# Extraction du fichier de commandes par ftp
srvdev=AENDEVO2BATCH.AZURE.SCOR.COM
log1=frdev14
pass1=Urantia100
fic=${NCHAIN}_${SOURCE}.dat

cd ${DFILT}
rm -f ${DFILT}/${fic}

ftp -n -i ${srvdev} <<EOF
user ${log1} ${pass1}
ascii
prompt
cd /scor/livraison/tmp/${chsource}
get ${fic}
bye
EOF

cd ${DCMD}

if [ ! -s ${DFILT}/${NCHAIN}_${SOURCE}.dat ]
then

	ECHO_LOG "=================================================================================="
	ECHO_LOG "==>  Fichier de commandes UNIX non trouvé ${DFILT}/${NCHAIN}_${SOURCE}.dat"
	ECHO_LOG "==>  Serveur : ${serveur}"
	ECHO_LOG "==>  Il n'a pas ete depose ici : /scor/livraison/tmp/${chsource} - Arret"
	ECHO_LOG "=================================================================================="
	JOBEND

else
	
	ECHO_LOG "=================================================================================="
	ECHO_LOG "==> Liste des commandes du fichier a traiter"
	ECHO_LOG "=================================================================================="
	more	${DFILT}/${NCHAIN}_${SOURCE}.dat
	ECHO_LOG "=================================================================================="
	ECHO_LOG "==> Fin de la Liste des commandes du fichier a traiter"
	ECHO_LOG "=================================================================================="
	# Extrait fichiers
	ftp -n -i ${srvdev} <<EOF
user ${log1} ${pass1}
ascii
prompt
cd /scor/livraison/tmp/${chsource}
delete ${fic}
bye
EOF

fi

chmod a+wx ${DFILT}/${NCHAIN}_${SOURCE}.dat

ECHO_LOG "=========================================="
ECHO_LOG "==> Execution du traitement"
ECHO_LOG "=========================================="

${DFILT}/${NCHAIN}_${SOURCE}.dat

NSTEP=${NJOB}_10
# Begin RMFIL
#------------------------------------------------------------------------------
LIBEL="Delete of temporary files"
#RMFIL "${DFILT}/${NCHAIN}_${SOURCE}.dat"

# End of Job
JOBEND
