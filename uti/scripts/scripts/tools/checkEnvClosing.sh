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
			env	 char(30) not null,     
			CHAIN	varchar(100) not null ,
			JOB	varchar(50) not null 
		)             
go
		GRANT REFERENCES ON dbo.TCHK_CHAINS_JOBS TO GDBBATCH
		GRANT SELECT ON dbo.TCHK_CHAINS_JOBS TO GCONSULT
		GRANT SELECT ON dbo.TCHK_CHAINS_JOBS TO GDBBATCH
		GRANT INSERT ON dbo.TCHK_CHAINS_JOBS TO GDBBATCH
		GRANT DELETE ON dbo.TCHK_CHAINS_JOBS TO GDBBATCH
		GRANT UPDATE ON dbo.TCHK_CHAINS_JOBS TO GDBBATCH
		GRANT DELETE STATISTICS ON dbo.TCHK_CHAINS_JOBS TO GDBBATCH
		GRANT TRUNCATE TABLE ON dbo.TCHK_CHAINS_JOBS TO GDBBATCH
		GRANT UPDATE STATISTICS ON dbo.TCHK_CHAINS_JOBS TO GDBBATCH
		GRANT TRANSFER TABLE ON dbo.TCHK_CHAINS_JOBS TO GDBBATCH
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
		GRANT REFERENCES ON dbo.TCHK_VTOM TO GDBBATCH
		GRANT SELECT ON dbo.TCHK_VTOM TO GCONSULT
		GRANT SELECT ON dbo.TCHK_VTOM TO GDBBATCH
		GRANT INSERT ON dbo.TCHK_VTOM TO GDBBATCH
		GRANT DELETE ON dbo.TCHK_VTOM TO GDBBATCH
		GRANT UPDATE ON dbo.TCHK_VTOM TO GDBBATCH
		GRANT DELETE STATISTICS ON dbo.TCHK_VTOM TO GDBBATCH
		GRANT TRUNCATE TABLE ON dbo.TCHK_VTOM TO GDBBATCH
		GRANT UPDATE STATISTICS ON dbo.TCHK_VTOM TO GDBBATCH
		GRANT TRANSFER TABLE ON dbo.TCHK_VTOM TO GDBBATCH
go
EOF
}

function creatTableTCHK_VTOM()
{
	isql -Ubatch -Pomega2-- -SDEV_TPO2 <<EOF
	USE BTRAV                               
go                                      
	                                      
	IF OBJECT_ID('TCHK_LOG_CHAIN') IS NULL  
	BEGIN                                 
		create table TCHK_LOG_CHAIN                                    
		( 
			env		    varchar(5) null, 
			site        varchar(20) null,
			CHAIN_CT    varchar(10) null,   
			IDF_CT      varchar(30) null,  
			CRE_D       varchar(30) null,  
			STATUS_CT   varchar(30) null,  
			START_D     varchar(30) null,  
			END_D       varchar(30) null,  
			GONOGO      varchar(30) null,  
			VNORME      varchar(30) null,  
			EST_PLAN    	varchar(30) null,  
			VERSION_9001	varchar(30) null,  
			ICLODAT     	varchar(30) null,  
			TYPEINV     varchar(30) null,  
			NORME_CF    varchar(30) null,  
			PLAN_CT     varchar(30) null,  
			flog    	varchar(512) null
		)
	END                                   
go 
		GRANT REFERENCES ON dbo.TCHK_LOG_CHAIN TO GDBBATCH
		GRANT SELECT ON dbo.TCHK_LOG_CHAIN TO GCONSULT
		GRANT SELECT ON dbo.TCHK_LOG_CHAIN TO GDBBATCH
		GRANT INSERT ON dbo.TCHK_LOG_CHAIN TO GDBBATCH
		GRANT DELETE ON dbo.TCHK_LOG_CHAIN TO GDBBATCH
		GRANT UPDATE ON dbo.TCHK_LOG_CHAIN TO GDBBATCH
		GRANT DELETE STATISTICS ON dbo.TCHK_LOG_CHAIN TO GDBBATCH
		GRANT TRUNCATE TABLE ON dbo.TCHK_LOG_CHAIN TO GDBBATCH
		GRANT UPDATE STATISTICS ON dbo.TCHK_LOG_CHAIN TO GDBBATCH
		GRANT TRANSFER TABLE ON dbo.TCHK_LOG_CHAIN TO GDBBATCH
go
EOF
}


function extract_CHAINS_JOBS()
{
	#set -x
	env=$1
	masq=$2
	if [ "$env" = "dev" ]
	then
		cd "/scor/scoromega/runnable/cmd/"
	else
		cd /scoromega_runnable_aen${env}o2batch/cmd/  
	fi
	echo
	echo "-------------------------------- extract_CHAINS_JOBS -----------------------------------"
	pwd
	#set -x
	grep -H '${*DCMD}*/' ${masq} | sed -e s'/:\s*/:/' | sed -e s'/:\.\s*/:/' | grep -v ':#' | sed -e s'/:.*DCMD}*\//;/' -e s'/.cmd//g' -e s'/PARALLEL_JOB\s*\"//' | cut -d" " -f1 > $DFILT/tt
	#set +x
	
	grep -v NJOB $DFILT/tt |  awk -v env=${env}  '{print env";"$0}' >> $DFILT/chainsJobs_${env}.dat
	grep NJOB $DFILT/tt > $DFILT/tt2
	
	for ch in `cut -d";" -f1 $DFILT/tt2`
	do
		 
		 for job in `grep '^\s*NJOB'  $ch.cmd | cut -d= -f2 | sed -e s'/\"//'g`
		 do
			echo ${env}";"$ch";"$job >> $DFILT/chainsJobs_${env}.dat
		 done
	done
	
	rm $DFILT/TCHK_CHAINS_JOBS.dat
	for ch in `cat  $DFILT/chainsJobs_${env}.dat`
	do
		echo ${ch} >> $DFILT/TCHK_CHAINS_JOBS.dat
	done

	cd -
}

function chargeTCHK_CHAINS_JOBS()
{
	env=$1
	extract_CHAINS_JOBS "$env" '*0.cmd'
	bcp  BTRAV..TCHK_CHAINS_JOBS in $DFILT/TCHK_CHAINS_JOBS.dat -Ubatch -Pomega2-- -SDEV_TPO2  -c -b10000 -t';'   -e$DFILT/TCHK_CHAINS_JOBS.err -Jiso_1
}

function chargeTCHK_VTOM()
{
	bcp  BTRAV..TCHK_VTOM in $DFILT/vtom.dat  -Ubatch -Pomega2-- -SDEV_TPO2  -c -b10000 -t'~'   -e$DFILT/TCHK_VTOM.err -Jiso_1
}

pathScript=`dirname $0`
rm $DFILT/chainsJobs_*.dat
if [ "$1" = "INIT" ]
then
	createTCHK_CHAINS_JOBS
	chargeTCHK_CHAINS_JOBS dev
	chargeTCHK_CHAINS_JOBS uat
	chargeTCHK_CHAINS_JOBS int
	chargeTCHK_CHAINS_JOBS mai
	chargeTCHK_CHAINS_JOBS prd
	chargeTCHK_CHAINS_JOBS in2
	chargeTCHK_CHAINS_JOBS cnv
	chargeTCHK_CHAINS_JOBS itk

	creatTableTCHK_VTOM
	${pathScript}/xmlVtomToBcp.py
	chargeTCHK_VTOM
else
	env=$1
	chain=$2
	extract_CHAINS_JOBS "$env" ${chain}.cmd
	${pathScript}/xmlVtomToBcp.py "$env" ${chain}
fi