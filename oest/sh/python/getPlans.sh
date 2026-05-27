#!/bin/ksh
export DPKL="data/analyse/pkl"


for server  in aenitko2batch aenuato2batch aenprdo2batch
do
	export SERVER=$server
	
	for site  in as am eu
	do
		export SITE=$site
		export DSAVE="/scordata_"${SERVER}"/ub"${site}"/save"
		echo 
		echo "Get plans and Perms:" $SERVER $SITE 
		echo

		for f in ${DSAVE}/svg_*ESCJ0000_PARM0.dat.gz
		do
			date=`echo $f | cut -d"_" -f3 | cut -c 1-8`
			plan="PLANS"

			getPlans.py $date $plan
		done

		for f in ${DSAVE}/svg_*ESFJ0000_PARM.dat.gz
		do
			date=`echo $f | cut -d"_" -f3 | cut -c 1-8`
			plan="PLAN_IFRS17"

			getPlans.py $date $plan
		done

		for f in ${DSAVE}/svg_*ESFJ0000_TI17PERMFIL.dat.gz
		do
			date=`echo $f | cut -d"_" -f3 | cut -c 1-8`
			plan="TI17PERMFIL"
			getPlans.py $date $plan
		done
	done
done