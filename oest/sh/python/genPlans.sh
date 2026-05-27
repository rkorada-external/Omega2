#!/bin/ksh

for  params in "20210517 I4IQINV"
do
	echo $params | set
	genPlan.py $1 $2
done
