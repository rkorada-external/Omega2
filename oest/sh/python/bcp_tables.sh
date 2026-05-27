 
 BCP()
{
	table=$1
	bcp  BTRAV..${table} out data/${table}.dat batch -Ubatch -Pomega2-- -SDEV_TPO2  -c -b10000 -t'~'   -e${table}.err -Jiso_1
}

BCP TCLOS_REPORT
BCP TLOG_INFO_CHAIN
BCP TPLANS