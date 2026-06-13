#==============================================================================
#nom de l'application          :  technique
#nom du source                 : TECADD.cmd
#revision                      : $Revision:   1.0  $
#date de creation              : 22/09/1996
#auteur                        : C.G.I. ()
#references des specifications : #################
#squelette de base             :
#------------------------------------------------------------------------------
#description : Dechargement table BREF..TADDIP
# 		Ce script est utilisé seul, 
#               il n'a donc pas de fichier d'environnement
#------------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
#
unset LANG
ODIRFICN=${DUTI}/tab
ODIRLOG=${DLOG}
USR=demon
PSWD=marginata
SRV=PRDP03_SRV

bcp BREF..TADDIP out ${ODIRFICN}/taddip.1 -c -t\; -r\\n -e ${ODIRLOG}/TECADD_bcp.err -U${USR} -P${PSWD} -S${SRV}

