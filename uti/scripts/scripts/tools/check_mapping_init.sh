
SRV=$1



TNR_STANDART()
{
	table=$1

	echo "======================================================================================="
	echo "            	Start TNR $table $SRV2  =>  $DFILT/${SRV}_${table}_diff.dat " 
	echo "======================================================================================="

	sep="~" 
	


	syncsort << endofsort
	/STATISTICS
	/workspace  ${SORTWORK}
	/FIELDS
			key_cols        1:1     -       30:
	/INFILE $DFILT/BTRAV_${SRV}_${table}.dat   2000 1  
	/joinkeys
			 key_cols
	/INFILE  $DFILT/${SRV}_${table}.dat   2000 1 
	/joinkeys
			 key_cols
	/JOIN UNPAIRED  ONLY
	/OUTFILE $DFILT/${SRV}_${table}_diff.dat overwrite
	/REFORMAT
			leftside:key_cols, rightside:key_cols
endofsort
}

echo "---------------------------------------------------------------------------------------------------------------"
echo "Extract $1 tables" 
bcp BEST..TI17CHN        out $DFILT/${SRV}_TI17CHN.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17FNC        out $DFILT/${SRV}_TI17FNC.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17PERMFIL    out $DFILT/${SRV}_TI17PERMFIL.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17REQFNC     out $DFILT/${SRV}_I17REQFNC.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17REQ        out $DFILT/${SRV}_TI17REQ.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 


echo "---------------------------------------------------------------------------------------------------------------"
echo "Drop and create ${SRV}_{tables}"

isql -Ubatch -Pomega2-- -SDEV_TPO2 -e <<EOF
use BTRAV
go
drop table ${SRV}_TI17CHN
go         
drop table ${SRV}_TI17FNC
go         
drop table ${SRV}_TI17PERMFIL
go         
drop table ${SRV}_TI17REQFNC
go         
drop table ${SRV}_TI17REQ
go


select * into  BTRAV..${SRV}_TI17CHN       	from BEST..TI17CHN           where 1=2
select * into  BTRAV..${SRV}_TI17FNC       	from BEST..TI17FNC           where 1=2
select * into  BTRAV..${SRV}_TI17PERMFIL   	from BEST..TI17PERMFIL       where 1=2
select * into  BTRAV..${SRV}_TI17REQFNC    	from BEST..TI17REQFNC        where 1=2
select * into  BTRAV..${SRV}_TI17REQ       	from BEST..TI17REQ           where 1=2
go

EOF

DIR=`dirname $0`


echo "---------------------------------------------------------------------------------------------------------------"
echo "Extract  ${SRV}_{tables} $DIR/extractMappingData.py"

$DIR/extractMapping.py  ${SRV} INIT $DFILT
sed -e s/BEST[.][.]/BTRAV..${SRV}_/g $DFILT/ALL_MAPPING.sql > $DFILT/EXTRACT_MAPPING_TABLES_${SRV}.sql


echo "---------------------------------------------------------------------------------------------------------------"
echo "Load  ${SRV}_{tables} in BTRAV of DEV"

isql -Ubatch -Pomega2-- -SDEV_TPO2 -e -i$DFILT/EXTRACT_MAPPING_TABLES_${SRV}.sql -o$DFILT/EXTRACT_MAPPING_TABLES_${SRV}.out


 
echo "---------------------------------------------------------------------------------------------------------------"
echo "bcpout  ${SRV}_{tables}"

bcp BTRAV..${SRV}_TI17CHN        out $DFILT/BTRAV_${SRV}_TI17CHN.dat  -Ubatch -SDEV_TPO2 -c -Jiso_1 -Pomega2-- -t"~" -r"\n" 
bcp BTRAV..${SRV}_TI17FNC        out $DFILT/BTRAV_${SRV}_TI17FNC.dat  -Ubatch -SDEV_TPO2 -c -Jiso_1 -Pomega2-- -t"~" -r"\n" 
bcp BTRAV..${SRV}_TI17PERMFIL    out $DFILT/BTRAV_${SRV}_TI17PERMFIL.dat  -Ubatch -SDEV_TPO2 -c -Jiso_1 -Pomega2-- -t"~" -r"\n" 
bcp BTRAV..${SRV}_TI17REQFNC     out $DFILT/BTRAV_${SRV}_TI17REQFNC.dat  -Ubatch -SDEV_TPO2 -c -Jiso_1 -Pomega2-- -t"~" -r"\n" 
bcp BTRAV..${SRV}_TI17REQ        out $DFILT/BTRAV_${SRV}_TI17REQ.dat  -Ubatch -SDEV_TPO2 -c -Jiso_1 -Pomega2-- -t"~" -r"\n" 
#bcp BTRAV..${SRV}_TI17REQJOB     out $DFILT/BTRAV_${SRV}_TI17REQJOB.dat  -Ubatch -SDEV_TPO2 -c -Jiso_1 -Pomega2-- -t"~" -r"\n" 
#bcp BTRAV..${SRV}_TI17REQJOBPLAN out $DFILT/BTRAV_${SRV}_TI17REQJOBPLAN.dat  -Ubatch -SDEV_TPO2 -c -Jiso_1 -Pomega2-- -t"~" -r"\n" 


echo "---------------------------------------------------------------------------------------------------------------"
echo "TNR "



TNR_STANDART TI17CHN       
TNR_STANDART TI17FNC       
TNR_STANDART TI17PERMFIL   
TNR_STANDART TI17REQFNC    
TNR_STANDART TI17REQ       
#TNR_STANDART TI17REQJOB    
#TNR_STANDART TI17REQJOBPLAN

exit 0
