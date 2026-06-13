
check_chain (){
shell=$(echo $1 |sed 's/.cmd$//g')
env=$2
site=$3
EBSCLO=$4

PARAM=(`grep "#----> IDF_CT" /*data*$env*/$site/log/*$shell* 2>/dev/null | cut -d":" -f3| cut -d" " -f2 |sed "s/^/'/g" |sed "s/$/'/g"  |sort -u |grep -v "="`)

#echo "${PARAM[@]}"

for cmd in `grep DCMD /*run*$env*/cmd/$shell.cmd |grep -v 9001 |cut -d"/" -f2 |cut -d" " -f1`
do

  #echo -e "$cmd : "

#FILE_LIST=(`grep "_I" /*run*$env*/cmd/$cmd  |grep '\${' |grep '}' |grep -v DCMD |grep -v PARM_INVCONSO_D |grep -v 'DFILT\|EXECKSH\|DFILI' |grep -v '^#' |grep -v '^wc' |grep -v '^/' |grep -v DFILP |grep -v PARALLEL |grep -v ECHO_LOG |grep -v CLODAT | grep -v if |cut -d= -f2 | sed 's/\.*"*${\|}"*.*//g' |sort -u`) 

FILE_LIST=(`sed -n '/_I[0-9]*=\|\/INFILE\|\/infile/p' /*run*$env*/cmd/$cmd 2>/dev/null |\
            grep -v 'DFILT\|DFILI\|DFILP\|ECHO_LOG\|INPUT\|DESC' |grep -v '^#\|^echo' | \
            sed 's/\/INFILE */\/INFILE=/g' | cut -d= -f2 | sed 's/\.*"*\${\|}"*.*//g' | \
            cut -d' ' -f1   |sort -u`)


	for IDF_CT in ${PARAM[@]} 
	do
	
	#echo -e " $IDF_CT"

		for FILE in ${FILE_LIST[@]} 
		do
		IDF_CT=`echo $IDF_CT | sed "s/^'//g" | sed "s/'$//g"`
		FILE=`echo $FILE |rev |cut -d"$" -f1 |rev`

		if [ "${IDF_CT}" = "" ]; then
			IDF_CT=${shell}_${EBSCLO}
		fi

		
	
		echo -n "$shell | $cmd : $IDF_CT : $FILE --> "
			
		res=`cat /*data*$env*/$site/perm/*_ESFJ0000_TI17PERMFIL.dat |grep "~$FILE~"|grep $IDF_CT`
		if [ "$res" = "" ]; then
			echo "file not found"
		else
			echo -e "\n$res"
		fi
		echo -e "\n"
		done


	done


done
}

env=$2
site=$3
EBSCLO=$4

if [ "$1" = "ALL" ]; then


 for i in `ls -tr /*run*$env*/cmd/ES?????0.cmd |rev | cut -d"/" -f1 |rev|sort -u`
 do
	check_chain $i $env $site $EBSCLO
 done

else

 check_chain $1 $env $site

fi
