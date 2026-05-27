for f in `ls /scor/OmegaDomain/exportVTOM/*_N*.xml`
do
		bn=`basename $f| cut -d. -f1`
		env=`echo $bn| cut -d_ -f1`
		echo  $f $env $bn
		convertXmlVtom.py $f
		sed -e s/TEMPDB/BTRAV/g  -e s/VTOM_CLOS/${env}_VTOM_CLOS/g  $DFILT/${bn}.sql > $DFILT/${bn}_DEV.sql
        isql -Ubatch -Pomega2-- -SDEV_TPO2 -e -i$DFILT/${bn}_DEV.sql  -o$DFILT/${bn}_DEV.log
done



#select * from BTRAV..UAT_VTOM_CLOS
#select * from BTRAV..ITK_VTOM_CLOS
#select * from BTRAV..MAI_VTOM_CLOS
#select * from BTRAV..DEV_VTOM_CLOS
#select * from BTRAV..CNV_VTOM_CLOS
#select * from BTRAV..INT_VTOM_CLOS
#select * from BTRAV..IN2_VTOM_CLOS
#select * from BTRAV..PRD_VTOM_CLOS

