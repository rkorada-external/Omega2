#==============================================================================
#nom de l'application          :  technique
#nom du source                 : TEST_RC.sh
#revision                      : $Revision: 1.1 $
#date de creation              : 22/12/1995
#auteur                        : C.G.I. ()
#references des specifications : #################
#squelette de base             :
#------------------------------------------------------------------------------
#description : fonction banalisee de test de code retour
# 
#------------------------------------------------------------------------------
#historique des modifications :
#   <jj/mm/aaaa>   <auteur>    <description de la modification>
#

#------------------------------------------------------------------------------
# fonction de test du code retour
#------------------------------------------------------------------------------
#TEST_RC ()
if test -z $RC
then
	RC=$1
fi
if      test $RC -ne 0
then   
# trace du dernier point de reprise passe

   echo
   echo "           ============================================="
   echo "            Dernier point de reprise passe : $TR"
   echo "            Code retour de la step         : $RC"
   echo "\n                    FIN ANORMALE DE LA STEP \n"
   echo "           ============================================="
   echo

   exit $RC
# else
#   echo "           ============================================="
#   echo "                    FIN NORMALE DE LA STEP "
#   echo "           ============================================="
fi
