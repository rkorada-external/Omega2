
export DPKL="/scor/home/frdev11/3J_DEV/oest/sh/python/data/analyse/pkl"
export DCSV="/scor/home/frdev11/3J_DEV/oest/sh/python/data/analyse/csv"
export HOST_DB="ITK" 


#for server  in aenitko2batch aenuato2batch aenprdo2batch
#do
#	export SERVER=$server
#	
#	for site  in as am eu
#	do
#		export SITE=$site
#		export DSAVE="/scordata_"${SERVER}"/ub"${site}"/save"
#		echo 
#		echo "Get plans and Perms:" $SERVER $SITE 
#		echo
#
#		for f in ${DSAVE}/svg_*ESCJ0000_PARM0.dat.gz
#		do
#			date=`echo $f | cut -d"_" -f3 | cut -c 1-8`
#			plan="PLANS"
#
#			/scor/home/frdev11/3J_DEV/oest/sh/python/getPlans.py $date $plan
#		done
#
#		for f in ${DSAVE}/svg_*ESFJ0000_PARM.dat.gz
#		do
#			date=`echo $f | cut -d"_" -f3 | cut -c 1-8`
#			plan="PLAN_IFRS17"
#
#			/scor/home/frdev11/3J_DEV/oest/sh/python/getPlans.py $date $plan
#		done
#
#		for f in ${DSAVE}/svg_*ESFJ0000_TI17PERMFIL.dat.gz
#		do
#			date=`echo $f | cut -d"_" -f3 | cut -c 1-8`
#			plan="TI17PERMFIL"
#			/scor/home/frdev11/3J_DEV/oest/sh/python/getPlans.py $date $plan
#		done
#	done
#done
#
#

#
#for server  in aenitko2batch aenuato2batch aenprdo2batch
#do
#	export SERVER=$server
#	for site  in as am eu
#	do
#		export SITE=$site
#		export DSAVE="/scordata_"${SERVER}"/ub"${site}"/save"
#		for f in `ls $DSAVE/svg_*ESCJ0000_PARM0*`
#		do
#				dat=`echo $f  | cut -d"_" -f3 | cut -c 1-8`
#				echo -----------------------------------------------------------
#				echo --------------- $dat $SERVER $SITE  
#				echo -----------------------------------------------------------
#				export DPERM="/scordata_"$SERVER"/ub"$SITE
#				export DLOG="/scordata_"$SERVER"/ub"$SITE"/log"
#				/scor/home/frdev11/3J_DEV/oest/sh/python/getClosingReport.py $dat "*"
#				#insertReport.py $server $dbclo $site > log
#		done
#	done
#done

#rm /scor/home/frdev11/3J_DEV/oest/sh/python/data/analyse/log
#for f in `ls /scor/home/frdev11/3J_DEV/oest/sh/python/data/analyse/csv/closingStatus_*.csv`
#do
#    dbclo=`echo $f  |  sed -e s'/.*closingStatus_//' | cut -d'_' -f1`
#    server=`echo $f  |  sed -e s'/.*closingStatus_//' | cut -d'_' -f2`
#	site=`echo $f  |  sed -e s'/.*closingStatus_//' | cut -d'_' -f3 | cut -d. -f1`
#
#	
#	echo $server $dbclo $site
#	/scor/home/frdev11/3J_DEV/oest/sh/python/insertReport.py $server $dbclo $site >> /scor/home/frdev11/3J_DEV/oest/sh/python/data/analyse/log
#done

export SERVER=aenprdo2batch
export SITE=eu
export DSAVE="/scordata_"${SERVER}"/ub"${site}"/save"
export DPERM="/scordata_"$SERVER"/ub"$SITE
export DLOG="/scordata_"$SERVER"/ub"$SITE"/log"
/scor/home/frdev11/3J_DEV/oest/sh/python/getClosingReport.py aenprdo2batch "202104*" 