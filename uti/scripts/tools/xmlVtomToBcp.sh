function createTCHK_CHAINS_JOBS()
{
	isql -Ubatch -Pomega2-- -SDEV_TPO2 <<EOF

		USE BTRAV                             
go                                     
		IF OBJECT_ID('TCHK_CHAINS_JOBS') IS NOT NULL
		BEGIN                                  
			DROP TABLE TCHK_CHAINS_JOBS               
		END                                    
go                                     
											
		create table TCHK_CHAINS_JOBS                 
		(                                      
			env	 varchar(30) not null,     
			CHAIN	varchar(100) not null ,
			JOB	varchar(50) not null 
		)                                      
go
EOF
}


function creatTableTCHK_VTOM()
{
	isql -Ubatch -Pomega2-- -SDEV_TPO2 <<EOF
	USE BTRAV                               
go                                      
	IF OBJECT_ID('TCHK_VTOM') IS NOT NULL  
	BEGIN                                 
	    DROP TABLE TCHK_VTOM       
	END                                   
go                                    
	                                      
	                                      
	create table TCHK_VTOM         
	(                                     
	    env       	varchar(50) null,     
	    Application	varchar(64) null,     
	    Title  		varchar(64) null,     
	    CHAIN	        varchar(64) null, 
	    PARAMS       	varchar(64) null, 
	    IDF_CT       	varchar(64) null, 
	    NORME       	varchar(64) null, 
	    VTYPEAOC      varchar(16) null,   
	    LABEL  		varchar(512) null
	 )                                     
go                                       
EOF
}

function chargeTCHK_CHAINS_JOBS()
{
	env=$1
	if [ "$env" = "dev" ]
	then
		cd $DCMD
	else
		cd /scoromega_runnable_aen${env}o2batch/cmd/
	fi
	pwd
	grep '${*DCMD}*/' *0.cmd | sed -e s'/:\s*/:/' | sed -e s'/:\.\s*/:/' | grep -v ':#' | sed -e s'/:.*DCMD}*\//;/' -e s'/.cmd//g' | cut -d" " -f1 > $DFILT/tt
	
	grep -v NJOB $DFILT/tt > $DFILT/chainsJobs.dat
	grep NJOB $DFILT/tt > $DFILT/tt2
	for ch in `cut -d";" -f1 $DFILT/tt2`
	do
		 
		 for job in `grep '^\s*NJOB'  $ch.cmd | cut -d= -f2 | sed -e s'/\"//'g`
		 do
			echo $ch";"$job >> $DFILT/chainsJobs.dat
		 done
	done
	

	rm $DFILT/TCHK_CHAINS_JOBS.dat
	for ch in `cat  $DFILT/chainsJobs.dat`
	do
		echo "uat;"$ch >> $DFILT/TCHK_CHAINS_JOBS.dat
	done



	bcp  BTRAV..TCHK_CHAINS_JOBS in $DFILT/TCHK_CHAINS_JOBS.dat -Ubatch -Pomega2-- -SDEV_TPO2  -c -b10000 -t';'   -e$DFILT/TCHK_CHAINS_JOBS.err -Jiso_1

}
function chargeTCHK_VTOM()
{
	
	bcp  BTRAV..TCHK_VTOM in $DFILT/vtom.dat  -Ubatch -Pomega2-- -SDEV_TPO2  -c -b10000 -t'~'   -e$DFILT/TCHK_VTOM.err -Jiso_1
}


creatTableTCHK_VTOM
xmlVtomToBcp.py
chargeTCHK_VTOM
