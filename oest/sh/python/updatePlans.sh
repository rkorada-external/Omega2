


export DSAVE="/scordata_aenitko2batch/ubas/save"
export SERVER="aenitko2batch"
export SITE="as"
export DCSV="data/analyse/csv/"
export DPKL="data/analyse/pkl/"


for f in `ls $DSAVE/svg_*20210413111916*ESCJ0000_PARM0*`
do
        dat=`echo $f  | cut -d"_" -f3 | cut -c 1-8`
        server=`echo $f  | cut -d_ -f3`
		site=`echo $f  | cut -d_ -f4 | cut -d. -f1`
		echo $dat $server $site
		csvPlans.py $dat
		csvPlan.py $dat
		#insertReport.py $server $dbclo $site > log
done
