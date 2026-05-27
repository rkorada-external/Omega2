#!/bin/ksh
# export DSAVE="/scordata_aenitko2batch/ubas/save"
# export SERVER="aenitko2batch"
# export SITE="as"
export DCSV="data/analyse/csv"
export DPKL="data/analyse/pkl"
export DSQL="data/analyse/sql"

insert="no"
d=$1
for param in $*
do
    echo "Argument : ${param}"
    if [ $param = '-i' ]
    then
        insert="yes"
        d=$2
    fi
done

for server  in aenitko2batch aenuato2batch aenprdo2batch
do
	export SERVER=$server
	
	for site  in as am eu
	do
    	export SITE=$site
		export DSAVE="/scordata_"${SERVER}"/ub"${site}"/save"
		echo "---------------------------------------------"
		echo "Get plans:" $SERVER $SITE 
        #echo "Remove File pkl"
        #echo
        #rm ${DPKL}/PLANS_*.pkl

        for f in ${DSAVE}/*${d}*ESCJ0000_PLAN[0-4].dat.gz
        do
            date=`ls $f | cut -d_ -f3|   cut -c1-10`
            PLAN=`ls $f | cut -d_ -f6 | cut -d. -f1`
            CRE_D=`zgrep CRE_D ${DSAVE}/*${date}*ESCJ0000_PARM0.dat.gz | cut -d" " -f4`
            echo $f $date $PLAN $CRE_D
            ./getPlansGZ.py $f $date $PLAN $CRE_D
        done

        for f in ${DSAVE}/*${d}*ESFJ0000_PLAN.dat.gz
        do
            date=`ls $f | cut -d_ -f3 | cut -c1-10`
            PLAN=`ls $f | cut -d_ -f6 | cut -d. -f1`
            #CRE_D=`zgrep I17~PARM_CRE_D ${DSAVE}/*${date}*ESFJ0000_PARM.dat.gz | cut -d"~" -f3`
            CRE_D=`zgrep PARM_CRE_D ${DSAVE}/*${date}*ESFJ0000_PARM.dat.gz | cut -d"=" -f2`
            echo $f $date $PLAN $CRE_D
            ./getPlansGZ.py $f $date $PLAN $CRE_D
        done

        echo "Insert File sql"
        echo
        for f in ${DPKL}/PLANS_*.pkl
        do
            date=`ls $f |  sed -e s'/.*PLAN//' |  cut -d_ -f4 | cut -d. -f1 | cut -c1-10`
             echo $f $date
            ./insertPlansGZ.py $f $date $insert
        done

	done
done

