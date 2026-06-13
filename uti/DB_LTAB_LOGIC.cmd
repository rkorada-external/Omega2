#!/bin/ksh
#==============================================================================
#nom de l'application          :  
#nom du source                 : DB_LTAB_LOGIC.cmd
#revision                      : $Revision:   1.1  $
#date de creation              : 23/07/98
#auteur                        : SCOR V.CHERY
#references des specifications : 
#------------------------------------------------------------------------------
# description : 
# restauration logique par SQL/BT des tables indiquees dans le .prm
# dont le nom est deduit du nom du .env
# à partir des sauvegardes physiques de la base
# Le serveur et la base sont indiques dans le .env
# NPRM est le numero du fichier de parametre. Il faut le preciser lors du lancement
# DB_LTAB_LOGIC.cmd "nom du .env" numero
#------------------------------------------------------------------------------
#parametres :
#  $1 : Fichier d'initialisation des variables d'environnements
#    
#===============================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

NPRM=$2
FPRM=`basename $1 .env`_${NPRM}.prm

# Chain Initialization variable
CHAININIT $0 $1
# All variables are set into the environment file

# job de load logiques  
NJOB="LTAB_LOGIC"
for tab in `cat ${DPRM}/${FPRM}`
do
	${DUTI}/DB_LOAD_LOGIC.cmd P ${SRV} ${DB} ${tab} ${SRV_T} ${DB_T}  2>&1 | ${TEE}
done

CHAINEND
