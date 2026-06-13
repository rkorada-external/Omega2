#exemple: check_mapping.sh ITK data

SRV=$1
root=$2



TNR_STANDART()
{
	table=$1

	echo "======================================================================================="
	echo "            	Start TNR $table  =>  $DFILT/${SRV}_${table}_diff.dat " 
	echo "======================================================================================="

	sep="~" 
	


	syncsort << endofsort
	/STATISTICS
	/workspace  ${SORTWORK}
	/FIELDS
			key_cols        1:1     -       30:
	/INFILE $DFILT/TEMPDB_${SRV}_${table}.dat   2000 1  
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
echo "Drop and create in TEMPDB"

isql -Ubatch -Pomega2-- -SDEV_TPO2 -e <<EOF
use TEMPDB
go
drop table TI17CHN
go         
drop table TI17FNC
go         
drop table TI17PERMFIL
go         
drop table TI17REQFNC
go         
drop table TI17REQ
go


select * into  TEMPDB..TI17CHN       	from BEST..TI17CHN          --where 1=2
select * into  TEMPDB..TI17FNC       	from BEST..TI17FNC          --where 1=2
select * into  TEMPDB..TI17PERMFIL   	from BEST..TI17PERMFIL      --where 1=2
select * into  TEMPDB..TI17REQFNC    	from BEST..TI17REQFNC       --where 1=2
select * into  TEMPDB..TI17REQ       	from BEST..TI17REQ          --where 1=2
go

EOF

DIR=`dirname $0`


echo "---------------------------------------------------------------------------------------------------------------"
echo "Load  ${SRV}_{tables} in BTRAV of DEV"


for f in `ls ${root}/MAP*.sql`
do
                bn=`basename $f| cut -d. -f1`
                l=`expr length $bn`
                if [ "${l}" -eq  "16" ]
                then
                        echo $f
                        sed -e s/BEST[.][.]/TEMPDB../g  $f  > $DFILT/${bn}.sql
                        isql -Ubatch -Pomega2-- -SDEV_TPO2 -e -i$DFILT/${bn}.sql  -o$DFILT/${bn}.out
                fi
done


#set -x
echo 
echo "---------------------------------------------------------------------------------------------------------------"
echo "Extract $1 tables" 
echo 
bcp BEST..TI17CHN        out $DFILT/${SRV}_TI17CHN.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17FNC        out $DFILT/${SRV}_TI17FNC.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17PERMFIL    out $DFILT/${SRV}_TI17PERMFIL.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17REQFNC     out $DFILT/${SRV}_TI17REQFNC.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17REQ        out $DFILT/${SRV}_TI17REQ.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 

echo 
echo "---------------------------------------------------------------------------------------------------------------"
echo "Extract  $1 TEMPDB  tables"
echo 

bcp TEMPDB..TI17CHN        out $DFILT/TEMPDB_${SRV}_TI17CHN.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp TEMPDB..TI17FNC        out $DFILT/TEMPDB_${SRV}_TI17FNC.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp TEMPDB..TI17PERMFIL    out $DFILT/TEMPDB_${SRV}_TI17PERMFIL.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp TEMPDB..TI17REQFNC     out $DFILT/TEMPDB_${SRV}_TI17REQFNC.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp TEMPDB..TI17REQ        out $DFILT/TEMPDB_${SRV}_TI17REQ.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 


echo "---------------------------------------------------------------------------------------------------------------"
echo "TNR "



TNR_STANDART TI17CHN       
TNR_STANDART TI17FNC       
TNR_STANDART TI17PERMFIL   
TNR_STANDART TI17REQFNC    
TNR_STANDART TI17REQ       

exit 0
