#!/bin/ksh
#==============================================================================
#nom de l'application          : Decoupage d'un fichier d'edition
#nom du source                 : split.awk.cmd
#revision                      : $Revision: 1.1 $
#date de creation              : 13/03/1997
#auteur                        : C.G.I. ()
#references des specifications :
#------------------------------------------------------------------------------
#historique des modifications :
#   <27/03/1997>   <le Gouvello>   <Fusion des maquettes>
#   <10/04/1997>   <le Gouvello>   <correction des deux fonctions splits d'etat>
#   <15/04/1997>   < Guilheux  >   <split fichier sur un critere>
#   <21/04/1997>   <le Gouvello>   <split fichier sur deux criteres>
#
#------------------------------------------------------------------------------



#----------------------------------------------------------------------------

# Functions directory
DFUNCTION=${DUTI}/functions/fctsplit

   . $DFUNCTION/SPLIT_FILE
   . $DFUNCTION/SPLIT_FILE_2
   . $DFUNCTION/SPLIT_SSDESB
   . $DFUNCTION/SPLIT_SSD
   . $DFUNCTION/LINK_REPORT
