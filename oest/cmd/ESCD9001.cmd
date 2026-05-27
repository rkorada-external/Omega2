#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS -
# nom du script SHELL           : ESCD9001.cmd
# revision                      : 
# date de creation              : 24/07/2018
# auteur                        : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description:
#  witch between ESCD9001_IFRS4.cmd and ESCD9001_IFRS17.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#_________________
#CREATION
#Auteur:         Rm.NAJI
#Date:           27/07/2018
#Version:        0.1
#Description:    
#
# historiques des modifications
#[01] 28/11/2019 M.NAJI  : SPIRA 76850 redirection vers le job ESFD9001
#[02] 14/05/2021 M.NAJI  : SPIRA 91531 force calcul du EST_SORT_CONDITIOn ppour les chaines IFRS4 non migrees
##======================================================================================================================
#set -x


#------------------------------------------------------------------------------
# Preparation of screen condition on the subsidaries for the SORT
# with SSDs( = _F1_F2_F3_...)
#------------------------------------------------------------------------------
SSDs=$1
export EST_SORT_CONDITION=`echo ${SSDs} | awk 'BEGIN{FS="_";first="Y"}\
        {  printf("(");\
           for(i=1;i<=NF;i++)\
                if($i != "")\
                {       if(first=="N") printf(" OR ") ;\
                        printf(" SSD_CF=%s",$i);\
                        first="N"\
                } \
           printf(")");\
        }'`


#==-    [043]   D.Ch 02.08.2011 ==-

if [ "$EST_SORT_CONDITION" = "()" ]
then
    export EST_SORT_CONDITION="(1=1)"
fi

#[104]
echo "#"     >> ${FLOG}
echo "EST_SORT_CONDITION: ${EST_SORT_CONDITION}"     >> ${FLOG}
echo "#"     >> ${FLOG}


export IS_ESCD9001="Y"
. ${DCMD}/ESFD9001.cmd $1 $2 $3 $4 $5 $6 $7 $8

