#!/bin/ksh
#clear

disk_file=/tmp/disk.$LOGNAME.$$.out
usage_file=/tmp/usage.$LOGNAME.$$.out
pass_file=/tmp/passwd.$LOGNAME.$$.out

topn=$2
[ -n "$topn" ] || topn=15

find $1 -type f -ls 2>&- | awk '{print $5":"$7":"$11}' | sed -e's/[ ]\{1,\}/ /g' -e"s#$1##g" | sort -k1,1 -k2,2  > $disk_file
find /scor/home -type f -ls 2>&- | awk '{print $5":"$7":"$11}' | sed -e's/[ ]\{1,\}/ /g' -e"s#$1##g" | sort -k1,1 -k2,2  >> $disk_file


(
cat $disk_file | awk -F: '{print $1}' | sort -u | while read user ;do
        printf "$user:"
        grep "$user:" $disk_file | awk -F: '{sum +=$2} END {print int(sum/(1024*1024)) "M"}'
done
) | sort -t: -k1,1 > $usage_file

sort -t: -k1,1 /etc/passwd | awk 'BEGIN {FS=":"; OFS=":"} { $5=$1" "$5;} { print ; } ' > $pass_file

echo ""

echo "$1, top $topn of disk space usage by user"
echo ""
echo "  Usage  | User"
echo "---------+--------------------------------------------------"
join -t:  -1 1 -2 1 -o 1.2,2.5 $usage_file $pass_file |
sort -t: -k1n | sort -rn |awk -F: '{printf " %-8.8s|%s\n",$1,$2}' | head -$topn

echo ""

echo "$1, top $topn biggest files (please compress them if you can !!)"
echo ""
echo "  Size   | Owner              | Filename"
echo "---------+--------------------+--------------------------------------------------------------------------------------------"
join -t:  -1 1 -2 1 -o 1.2,2.5,1.3 $disk_file $pass_file |
sort -t: -k1n | sort -rn |awk -F: '{printf " %-8.8s|%-20.20s|%s\n",int($1/(1024*1024))"M",$2,$3}' | head -$topn

echo ""
echo "To redisplay this: $0 $1 $topn"
echo ""

rm $disk_file $usage_file $pass_file
#rm  $pass_file
