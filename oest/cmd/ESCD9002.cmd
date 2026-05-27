#!/bin/ksh
#==============================================================================
#nom de l'application          : Decoupage d'un fichier d'edition
#nom du source                 : ESID9002.cmd
#revision                      : $Revision:   1.2  $
#date de creation              : 16/01/1998
#auteur                        : C.G.I. ()
#references des specifications :
#------------------------------------------------------------------------------
#historique des modifications :
#
#------------------------------------------------------------------------------


#----------------------------------------------------------------------------
# FUNCTION: EST_WLP
#
# WLP as Write Last Page
#
# parameters must be previously defined:
# Fichiers
#  Input :
#   FWLP_I: Input Report before max page is included
#  Output
#   FWLP_O: Output Report before max page is included
#
# Subject: This function adds the max page number after the current page number
#
#------------------------------------------------------------------------------
EST_WLP () {
#set -x
if [ "${RP}" = ""  -o "${RP}" = "${NSTEP}" -o "${ADT}" != "" ]
then ADT="${NSTEP}"
        STEP_PRG=EST_WLP
        STEPSTART

if [ ! -s "${FWLP_I}" ]
then
   echo "#Warning No input file"
   STEPEND 0
   return 0
fi

# Get the number of pages associated to the input file
#-----------------------------------------------------
AWK_I=${FWLP_I}
AWK_PARAM=""
AWK_O=`CFTMP`
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN { PAGE_NUMBER = 1;
}
{
   if (match(\$0, "\")!=0)  {
      PAGE_NUMBER +=1
  
      if (NF == 1 && length($NF) == 1)
         CTL_EMPTY=1;
      else
         CTL_EMPTY=0;
   }
   else
     CTL_EMPTY=0;
}
END { 
   if (CTL_EMPTY==1)  PAGE_NUMBER -- ;
   print PAGE_NUMBER 
}
exit
EOF

STEP_NOECHO="YES"
AWK


#Adds the max page number for each page
#------------------------------------------
AWK_I=${FWLP_I}
AWK_PARAM="MAX_PAGE="`cat ${AWK_O}`
AWK_O=${FWLP_O}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN { FS="¤"; OFS="¤"; PAGE_NUMBER = 1; LINE_NUMBER=0;
# MAX_PAGE is a input parameter
}

{
   if (match(\$0, "\")!=0) {
      PAGE_NUMBER +=1
      LINE_NUMBER=0
   }

   LINE_NUMBER+=1
   if (LINE_NUMBER == 2 && \$NF != "") {

      btrim=0;
      Pos=length(\$NF);
      if (Pos >1)
      {
         while (substr (\$NF, Pos, 1) == " ") {
            Pos --;
            btrim=1;
         }
      }
      if (btrim == 1)
        \$NF= substr (\$NF, 1, Pos);

     \$NF=\$NF"/"MAX_PAGE
   }
   print \$0
}

exit
EOF

STEP_NOECHO="YES"
AWK

STEPEND $?
fi
}
