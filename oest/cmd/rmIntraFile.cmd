#!/bin/ksh
#===============================================================
#application name               : Cleaning_Script
#source name                    : Cleaning_Script.sh
#revision                       : $Revision:   1.0  $
#creation date                  : 02/03/2016
#author                         : M MARTHELY (MMA), M BONATO (MBO)
#specifications reference       :
#SPOT							: 30654
#---------------------------------------------------------------
#description :
# Clean the intraday's files in Temp, Interm and Perm
#
#parameter :
# 	1 : -v or -V or --verbose or --help
#---------------------------------------------------------------
#modifications chronology:
#

#JOBINIT

Verbose=false

if [[ $# == 1 && ($1 == -v || $1 == -V || $1 == "--verbose") ]]
then
	Verbose=true
# elif [[ $# > 1 || ($# == 1 && ($1 == "--help" || ($1 != -v && $1 != -V && $1 != "--verbose"))) ]]
# then
# 	echo "Usage : $0 [option]"
# 	echo "Options list :"
# 	echo "	-v | -V		active verbose mod		--verbose"
# 	echo "	--help		show Usage"
# 	echo ""
# 	echo "Description :"
# 	echo "Clean the intraday's files in Temp, Interm and Perm"
# 	exit 0
fi

######################
# Cleanning Function #
######################

function Clean_File
{
	End_Message=`du -s $@ | awk '{ total+=$1 ; nb+=1 } END { print total " Ko removed (" nb " file(s))" }'`

	for File in $@
	do
		if [[ $Verbose = 'true' ]]
		then
			rm -fv $File
			#echo $File
		else
			rm -f $File
			#echo -n ""
		fi
	done
	echo $End_Message
	echo
	cd - > /dev/null
}

################
# Main Program #
################

cd $DFILT
echo "Clean-up of : $DFILT :"
Clean_File `ls *ESDJ1010*.dat *ESDJ7000*.dat *ESDJ8040*.dat *ESDJ5020*.dat *ESID8040*.dat 2> /dev/null`

cd $DFILP
echo "Clean-up of : $DFILP :"
Clean_File `ls --ignore=*LIFSTAREP_PLAN* --ignore=*OPENNING* *ESDJ1010*.dat *ESDJ7000*.dat *ESDJ8040*.dat *ESID8040*.dat 2> /dev/null`

cd $DFILI
echo "Clean-up of : $DFILI :"
Clean_File `ls *ESDJ1010*.dat *ESDJ7000*.dat *ESDJ8040*.dat *ESDJ5020*.dat *ESID8040*.dat 2> /dev/null`

exit 0

#JOBEND