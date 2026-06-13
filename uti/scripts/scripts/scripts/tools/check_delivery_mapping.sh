SRV=$1
dest=$2 

isql -Udom_gen_ro -PscorRO -SITK_TPO2 -e <<EOF
use TEMPDB
go

IF OBJECT_ID('CHECK_TI17CHN') IS NOT NULL     DROP TABLE CHECK_TI17CHN
go         

IF OBJECT_ID('CHECK_TI17FNC') IS NOT NULL     DROP TABLE CHECK_TI17FNC
go         

IF OBJECT_ID('CHECK_TI17PERMFIL') IS NOT NULL     DROP TABLE CHECK_TI17PERMFIL
go         

IF OBJECT_ID('CHECK_TI17TRAPERMFIL') IS NOT NULL     DROP TABLE CHECK_TI17TRAPERMFIL
go         

IF OBJECT_ID('CHECK_TI17REQFNC') IS NOT NULL     DROP TABLE CHECK_TI17REQFNC
go         

IF OBJECT_ID('CHECK_TI17REQ') IS NOT NULL     DROP TABLE CHECK_TI17REQ
go

select * into  TEMPDB..CHECK_TI17CHN       	from BEST..TI17CHN           where 1=2
select * into  TEMPDB..CHECK_TI17FNC       	from BEST..TI17FNC           where 1=2
select * into  TEMPDB..CHECK_TI17PERMFIL   	from BEST..TI17PERMFIL       where 1=2
select * into  TEMPDB..CHECK_TI17TRAPERMFIL   	from BEST..TI17TRAPERMFIL       where 1=2
select * into  TEMPDB..CHECK_TI17REQFNC    	from BEST..TI17REQFNC        where 1=2
select * into  TEMPDB..CHECK_TI17REQ       	from BEST..TI17REQ           where 1=2
go

EOF


#sed -e s/BEST[.][.]/TEMPDB..CHECK_/g  $map_sql  > tmp.sql
#isql -w1000 -Udom_gen_ro -PscorRO -SITK_TPO2 -e -itmp.sql  -otmp.out
#
#sed -e s/BEST[.][.]/TEMPDB..CHECK_/g  $map_sql_tra  > tmp.sql
#isql -w1000  -Udom_gen_ro -PscorRO -SITK_TPO2 -e -itmp.sql  -otmp.out

#for f in `ls data/all/MAP*.sql`
for f in `ls ${dest}/MAP*.sql`
do
		bn=`basename $f| cut -d. -f1`
		l=`expr length $bn`
		if [ "${l}" -eq  "16" ]
		then
			echo $f
			sed -e s/BEST[.][.]/TEMPDB..CHECK_/g  $f  > ${bn}.sql
			isql -Udom_gen_ro -PscorRO -SITK_TPO2 -e -i${bn}.sql  -o${bn}.out
		fi
done



TNR_STANDART()
{
	table=$1

	echo "======================================================================================="
	echo "            	Start TNR $table $SRV  =>  $DFILT/${table}_diff.dat" 
	echo "======================================================================================="

	sep="~" 
	


	syncsort << endofsort
	/STATISTICS
	/workspace  ${SORTWORK}
	/FIELDS
			key_cols        1:1     -       4:
	/INFILE $DFILT/CHECK_${table}.dat    2000 1  "~" 
	/joinkeys
			 key_cols
	/INFILE  $DFILT/${table}.dat    2000 1  "~"
	/joinkeys
			 key_cols
	/JOIN UNPAIRED  ONLY
	/OUTFILE $DFILT/${table}_diff.dat overwrite
	/REFORMAT
			leftside:key_cols, rightside:key_cols
endofsort
}


bcp BEST..TI17CHN        out $DFILT/TI17CHN.dat -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17FNC        out $DFILT/TI17FNC.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17PERMFIL  out $DFILT/TI17PERMFIL.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17TRAPERMFIL  out $DFILT/TI17TRAPERMFIL.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17REQFNC     out $DFILT/TI17REQFNC.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp BEST..TI17REQ        out $DFILT/TI17REQ.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 




bcp TEMPDB..CHECK_TI17CHN        out $DFILT/CHECK_TI17CHN.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp TEMPDB..CHECK_TI17FNC        out $DFILT/CHECK_TI17FNC.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp TEMPDB..CHECK_TI17PERMFIL    out $DFILT/CHECK_TI17PERMFIL.dat -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp TEMPDB..CHECK_TI17TRAPERMFIL    out $DFILT/CHECK_TI17TRAPERMFIL.dat -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 
bcp TEMPDB..CHECK_TI17REQFNC     out $DFILT/CHECK_TI17REQFNC.dat  -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n"  
bcp TEMPDB..CHECK_TI17REQ        out $DFILT/CHECK_TI17REQ.dat -Udom_gen_ro -S${SRV}_TPO2 -c -Jiso_1 -PscorRO -t"~" -r"\n" 




TNR_STANDART TI17CHN       
TNR_STANDART TI17FNC       
TNR_STANDART TI17PERMFIL   
TNR_STANDART TI17TRAPERMFIL   
TNR_STANDART TI17REQFNC    
TNR_STANDART TI17REQ       

exit 0
isql -W1000 -Udom_gen_ro -PscorRO -SITK_TPO2 -e <<EOF
select count(*) from TEMPDB..CHECK_TI17PERMFIL 
select count(*) from TEMPDB..CHECK_TI17TRAPERMFIL 
use TEMPDB
go
drop table CHECK_TI17CHN
go         
drop table CHECK_TI17FNC
go         
drop table CHECK_TI17PERMFIL
go         
drop table CHECK_TI17REQFNC
go         
drop table CHECK_TI17REQ
go
EOF
