#!/bin/ksh
#==================================================================================
# nom de l'application          : ESTIMATIONS 
# nom du script SHELL           : CMDLIST
# revision                      : $Revision: 1.0 $
# date de creation              : 11/09/2020
# auteur                        : JYP
#-----------------------------------------------------------------------------
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

ARGV2=$2

cat  <<EOF > $DFILT/TNRPLAN0.env

export NCHAIN=${ENV_PREFIX}_TNRPLAN0

#[001] 30/06/2008 Roger Cassis   :spot:16588 - Chaine de d'execution de fichiers de commandes AWK, UNIX
#[002] 21/10/2011 Roger Cassis   :spot:22752 - Ajout serveur infocentre

export SRV=${PRD_SRV}

export SRV_2=${INF_SRV}

export BASE=BREF

unset LANG


EOF


cat  <<EOF > $DFILT/exclude_chain.lst

BTID0050~
BTID0090~
DWED0010~
DWPD0010~
DWPD0020~
DWPD1430~
DWUD0010~
DWUD0030~
DWUJ0070~
ESDJ5040~
ESED0300~
ESID1600~
ESID2010~
ESID2600~
ESID2900~
ESID3020~
ESID4000~
ESID4010~
ESID7200~
ESPD2500~
ESRD0000~
ESRD0010~
ESRD0020~
ESRD2530~
STAD1290~
~ESEJ0200
~ESEJ0210
~ESEJ0220
~ESEJ0230
~ESEJ0240
~ESPD2900
~ESPD3800
~ESPD8830
~ESPD9990
~STPD0020
ESPD2000~
ESPD2010~
ESPD8050~
ESPD3700~
DWMD0000~

EOF


cat  << EOF > $DFILT/plan_chaine.lst
PLAN0~DWUJ0070
PLAN0~ESCJ0000
PLAN0~ESCJ0060
PLAN0~ESCJ8990
PLAN0~ESDJ0110
PLAN0~ESDJ1010
PLAN0~ESDJ5020
PLAN0~ESDJ5040
PLAN0~ESDJ7000
PLAN0~ESDJ7010
PLAN0~ESDJ8040
PLAN0~ESEJ0000
PLAN0~ESEJ0200
PLAN0~ESEJ0210
PLAN0~ESEJ0220
PLAN0~ESEJ0230
PLAN0~ESEJ0240
PLAN0~ESEJ1000
PLAN0~ESIJ1000
PLAN0~ESIJ2000
PLAN0~ESED0300
PLAN0~ESEH1100
PLAN0~ESEH1110
PLAN0~ESEH1200
PLAN0~ESID1000
PLAN0~ESID1010
PLAN0~ESID1500
PLAN0~ESID1600
PLAN0~ESID1900
PLAN0~ESID2030
PLAN0~ESID2070
PLAN0~ESID3020
PLAN0~ESIJ0010
PLAN0~ESRD0020
PLAN0~ESIJ0090
PLAN0~ESIJ7000
PLAN0~ESID0060
PLAN0~ESID0070
PLAN0~ESID0080
PLAN0~ESID0110
PLAN0~ESID0120
PLAN0~ESID0130
PLAN0~ESID8030
PLAN0~ESID7000
PLAN0~ESID7050
PLAN0~ESID7200
PLAN0~ESID7550
PLAN0~ESID8060
PLAN0~ESID8100
PLAN0~ESID8120
PLAN0~ESID8500
PLAN0~ESID8830
PLAN0~STAD1290
PLAN0~ESID9990
PLAN0~DWUD0010
PLAN0~DWUD0030
PLAN0~BTID0050
PLAN0~BTID0090
PLAN0~DWUD0130
PLAN0~DWUD9130
PLAN0~ESPT0000
PLAN1~ESID0560
PLAN1~ESID1520
PLAN1~ESID1530
PLAN1~ESID1550
PLAN1~ESID1800
PLAN1~ESID2000
PLAN1~ESID2010
PLAN1~ESID2020
PLAN1~ESID2040
PLAN1~ESID2080
PLAN1~ESID2050
PLAN1~ESID4000
PLAN1~ESID4010
PLAN1~ESID2100
PLAN1~ESID2060
PLAN1~ESID2090
PLAN1~ESID2500
PLAN1~ESID2530
PLAN1~ESRD2530
PLAN1~ESID2550
PLAN1~ESID2560
PLAN1~ESID2590
PLAN1~ESID2600
PLAN1~ESID2800
PLAN1~ESID2900
PLAN1~ESID3600
PLAN1~ESID3700
PLAN1~ESID3800
PLAN1~ESID3810
PLAN1~ESID3850
PLAN1~ESID3860
PLAN1~ESID3900
PLAN1~ESID8000
PLAN1~ESID8040
PLAN1~ESID8050
PLAN1~ESID8530
PLAN1~ESID8600
PLAN1~ESID8700
PLAN1~ESID8800
PLAN1~DWED0010
PLAN1~ESID8900
PLAN1~STAD1200
PLAN1~STAD1220
PLAN1~STAD1280
PLAN1~STAD1500
PLAN1~STAD1530
PLAN1~STAD1540
PLAN1~STAD1550
PLAN1~ESRD0000
PLAN1~ESRD0010
PLAN2~DWMD0000
PLAN2~DWPD0010
PLAN2~DWPD0020
PLAN2~DWPD1430
PLAN2~ESPD0060
PLAN2~ESPJ0090
PLAN2~ESPD1520
PLAN2~ESPD1800
PLAN2~ESPD2000
PLAN2~ESPD2010
PLAN2~ESPD2050
PLAN2~ESPD2500
PLAN2~ESPD2900
PLAN2~ESPD2550
PLAN2~ESPD2570
PLAN2~ESPD3700
PLAN2~ESPD3710
PLAN2~ESPD8600
PLAN2~ESPD3800
PLAN2~ESPD3850
PLAN2~ESPD3860
PLAN2~ESPD3900
PLAN2~ESPD4000
PLAN2~ESPD7000
PLAN2~ESPD8000
PLAN2~ESPD8050
PLAN2~ESPD8100
PLAN2~ESPD8700
PLAN2~ESPD8800
PLAN2~ESPD8830
PLAN2~ESPD8900
PLAN2~ESPJ8990
PLAN2~ESPD9990
PLAN2~STPD0020
PLAN2~STPD1200
PLAN2~STPD1280
PLAN2~STPD1500
PLAN3~ESLD1800
PLAN3~ESLD1900
PLAN3~ESLD2900
PLAN3~ESLD3800
PLAN3~ESLD3850
PLAN3~ESLD3860
PLAN3~ESLD8100
PLAN3~ESLD8700
PLAN3~ESLD8830
PLAN3~ESLJ0090
PLAN3~ESLJ8990
EOF

CHAININIT TNRPLAN0.cmd $DFILT/TNRPLAN0.env


NJOB=${ENV_PREFIX}_TNRPLAN0_TNRPLAN1

# Initialization of the Job
JOBINIT


export ret="" 
get_param()
{
        lig=$1
        var=$2
		log=$3
        ret=`grep "$var" $log |sed  -n ${lig},${lig}p| cut -d"=" -f2| sed 's/ //g'`

}

get_param1()
{
        lig=$1
        var=$2
		log=$3
        ret=`grep "^$var" $log | sed -n 1,1p | awk 'BEGIN{}{print $2}'`
}



get_parms()
{
	lig=$1
	log=$2
	plan=`expr $lig - 1`
	get_param $lig "export EST_VARIANTE"			$log	;VARIANTE=$ret                     
	get_param $lig "export EST_LASTPOBOOKING"		$log	;LASTPOBOOKING=$ret                
	get_param $lig "export p_CONSOMTH"				$log	;CONSOMTH=$ret                     
	get_param $lig "export p_CONSOYEA=2020"         $log    ;CONSOYEA=$ret                     
	get_param $lig "export ComptaSocialIFRSDone=1"  $log    ;ComptaSocialIFRSDone=$ret         
	get_param $lig "export ComptaSocialEBSDone=0"   $log    ;ComptaSocialEBSDone=$ret          
	get_param $lig "export IsEpo=N"                 $log    ;IsEpo=$ret                        
	get_param $lig "export TypePOST="               $log    ;TypePOST=$ret                     
	get_param $lig "export EBS  nb_NoEBS=0"         $log    ;nb_NoEBS=$ret                     
	get_param $lig "export IsEpoComptaRequestF="    $log    ;IsEpoComptaRequestF=$ret          
	get_param1 $lig "SSDCLO_LL"        				$log	;SSDCLO_LL=$ret                    
	get_param1 $lig "BLCSHTYEA_NF"        			$log	;BLCSHTYEA_NF=$ret                 
	get_param1 $lig "BLCSHTYEA_NF"					$log	;BLCSHTYEA_NF=$ret
	get_param1 $lig "BLCSHTMTH_NF"                   $log    ;BLCSHTMTH_NF=$ret
	get_param1 $lig "CRE_D"                          $log    ;CRE_D=$ret
	get_param1 $lig "DBCLO_D"                        $log    ;DBCLO_D=$ret
	get_param1 $lig "CLODAT_D"                       $log    ;CLODAT_D=$ret
	get_param1 $lig "SPCEND_D"                       $log    ;SPCEND_D=$ret
	get_param1 $lig "SEGTYPCLO_CT"                   $log    ;SEGTYPCLO_CT=$ret
	get_param1 $lig "PERTYP_CT"                      $log    ;PERTYP_CT=$ret
	get_param1 $lig "ACCOUNT_D"                      $log	;ACCOUNT_D=$ret

												   

	echo "PLAN${plan}~${VARIANTE}~${LASTPOBOOKING}~${CONSOMTH}~${CONSOYEA}~${ComptaSocialIFRSDone}~${ComptaSocialEBSDone}~${IsEpo}~${TypePOST}~${nb_NoEBS}~${IsEpoComptaRequestF}~${SSDCLO_LL}~${BLCSHTYEA_NF}~${BLCSHTYEA_NF}~${BLCSHTMTH_NF}~${CRE_D}~${DBCLO_D}~${CLODAT_D}~${SPCEND_D}~${SEGTYPCLO_CT}~${PERTYP_CT}~${ACCOUNT_D}"
}


test_fct2 ()
{
	export JB=${HOSTNAME}_`date +"%Y%m%d%H%M%S"`
	export IB=${HOSTNAME}_`date +"%Y%m%d%H%M%S"`_$$
	export FLOG=${DLOG}/${NCHAIN}_${JR}.log
	dt=$1
	REQCOD_CT0=$2
	dt0=$3
	site=${HOST_PRDSIT}
		
	NSTEP=${NJOB}_$dt
	LIBEL="purge "

	if [ "$dt" = ""  ] 
	then   
		exit 1 
	fi 
	
	${BCPPDIR}/bcpmulti BIDON out REQCODD_CT_${dt}.dat -U$USR -S$SRV -c to $DFILT -Jiso_1 -P$PSWD -t'~' -r'\n' -d0 -M0 -Q "
	select REQCOD_CT from BEST..TI17REQJOBPLAN j where  convert(char(8),j.dbclo_d,112) =  '${dt}' and site_cf ='${site}' and LAUNCH_D =NULL"
	
	REQCOD_CT=`cat $DFILT/REQCODD_CT_${dt}.dat.1 `
	VNORME=`cat $DFILT/REQCODD_CT_${dt}.dat.1 | cut -c1-3`


	$DCMD/ESFJ0000.cmd =


	cat $DFILP/${ENV_PREFIX}_ESFJ0000_PLAN.dat | cut -d_ -f3 > $DFILT/${REQCOD_CT}_${dt}_GONOGO_NEW.dat

	${SORTDIR}/syncsort  << endofsort
	/STATISTICS
	/workspace  ${SORTWORK}
	/FIELDS
			IDF_CT  2:1 - 2 :,
			IDF_CT_I17  1:1 - 1 :
	/INFILE $DFILT/${REQCOD_CT0}_${dt0}_GONOGO.dat 2000 1  "~"
	/joinkeys
					IDF_CT
	/INFILE $DFILT/${REQCOD_CT}_${dt}_GONOGO_NEW.dat 2001 "~"
	/joinkeys
					IDF_CT_I17
	/JOIN UNPAIRED  ONLY
	/OUTFILE  ${DFILT}/${REQCOD_CT}_${dt}_diff0.dat overwrite
	 /REFORMAT
				leftside:IDF_CT,
				rightside:IDF_CT_I17
endofsort


	${SORTDIR}/syncsort << endofsort
	/STATISTICS
	/workspace  ${SORTWORK}
	/FIELDS
			chainL  1:1 - 1 :, 
			chainR  2:1 - 2 :
	/INFILE ${DFILT}/${REQCOD_CT}_${dt}_diff0.dat 2000 1  "~"
	/joinkeys
					chainL,
					chainR
	/INFILE $DFILT/exclude_chain.lst 2001 "~"
	/joinkeys
					chainL,
					chainR
	/JOIN UNPAIRED  LEFT ONLY
	/OUTFILE  ${DFILT}/TRNPLAN0_${REQCOD_CT}_${dt}_diff.dat overwrite
	/REFORMAT
				leftside:chainL,
				leftside:chainR
endofsort


	echo
	echo "-----------------"
	echo "REQCOD_CT:" $REQCOD_CT
	echo "VNORME:" $VNORME
	echo
	echo "-----------------"
	echo "Ecarts: "
	sort ${DFILT}/TRNPLAN0_${REQCOD_CT}_${dt}_diff.dat
	echo "-----------------"
	echo 

}

test_fct ()
{
	export JB=${HOSTNAME}_`date +"%Y%m%d%H%M%S"`
	export IB=${HOSTNAME}_`date +"%Y%m%d%H%M%S"`_$$
	export FLOG=${DLOG}/${NCHAIN}_${JR}.log
	dt=$1
	site=${HOST_PRDSIT}
		
	NSTEP=${NJOB}_$dt
	LIBEL="purge "

	if [ "$dt" = ""  ] 
	then   
		exit 1 
	fi 
	
	${BCPPDIR}/bcpmulti BIDON out REQCODD_CT_${dt}.dat -U$USR -S$SRV -c to $DFILT -Jiso_1 -P$PSWD -t'~' -r'\n' -d0 -M0 -Q "
	select REQCOD_CT from BEST..TI17REQJOBPLAN j where  convert(char(8),j.dbclo_d,112) =  '${dt}' and site_cf ='${site}' and LAUNCH_D =NULL"
	
	REQCOD_CT=`cat $DFILT/REQCODD_CT_${dt}.dat.1 `
	VNORME=`cat $DFILT/REQCODD_CT_${dt}.dat.1 | cut -c1-3`


	cat  <<EOF > $DFILT/update_treqjob_${dt}.sql
	delete   best..treqjob     where dbclo_d >=  "$dt" and site_cf ="${site}"
	update   best..treqjob set   LAUNCH_D="$dt"     where dbclo_d <  "$dt"  and LAUNCH_D = NULL and site_cf ="${site}"
	update   best..treqjobplan set   LAUNCH_D="$dt"     where dbclo_d <  "$dt" and LAUNCH_D = NULL and site_cf ="${site}"
	update   best..treqjobplan set   LAUNCH_D=null , start_d=null, end_d=null    where dbclo_d >=  "$dt" and site_cf ="${site}"
	if "$dt" = "20201101"
	begin
		delete best..treqjob  where DBCLO_D  < '20201031' and site_cf ="SGP1"
		insert into best..treqjob (SSD_CF,BALSHEYEA_NF,BALSHTMTH_NF,CLODAT_D,REQCOD_CT,CRE_D,DBCLO_D,LAUNCH_D,CLOPER_LS,VRS_NF,UPDUSR_CF,SITE_CF)
		values (99,2020,9,"20200930","B","20200905 13:02:11","20201031",'20201031',"A_20_22_24_",20200930,"Q20 ","SGP1")
		select * from best..treqjob  where dbclo_d ="20201031" and site_cf ="${site}"
	end 
go 

EOF
	${SYBASE}/${SYBASE_OCS}/bin/isql -H${NSTEP} -U$USR -S$SRV -i$DFILT/update_treqjob_${dt}.sql -o$DFILT/update_treqjob_${dt}.log -Jiso_1 -w1024 -P$PSWD  >/dev/null

	chmod 777 $DFILT/update_treqjob.log

	$DCMD/ESCJ0000.cmd = "$dt" P

	$DCMD/ESFJ0000.cmd =


	grep 'GONOGO="Y"' $DFILP/${ENV_PREFIX}_ESCJ0000_PLAN[0-4].dat | sed s'/.dat:export /_/' | rev | cut -d'_' -f2,4 |rev | sed s'/_/~/'| sort -u > $DFILT/${REQCOD_CT}_${dt}_GONOGO.dat

	cat $DFILP/${ENV_PREFIX}_ESFJ0000_PLAN.dat | cut -d_ -f3 > $DFILT/${REQCOD_CT}_${dt}_GONOGO_NEW.dat



	${BCPPDIR}/bcpmulti BIDON out PLAN_TI17REQJOBPLAN_${dt}.dat -U$USR -S$SRV  -c to $DFILT -Jiso_1 -P$PSWD -t'~' -r'\n' -d0 -M0 -Q "
	select r.REQCOD_CT, j.CLOTYP_CT , rc.CHAIN_CT, rc.IDF_CT,j.NORME_CF
	from BEST..TI17REQ r
	JOIN BEST..TI17REQJOBPLAN j on r.REQCOD_CT = j.REQCOD_CT and convert(char(8),j.dbclo_d,112) =  '${dt}' and site_cf ='${site}' and LAUNCH_D =NULL
	LEFT outer JOIN  BEST..TI17REQCHN rc on ( r.REQCOD_CT = rc.REQCOD_CT or rc.REQCOD_CT = 'ALL' )  where CHAIN_CT != null  order by 1 " 



	${SORTDIR}/syncsort  << endofsort
	/STATISTICS
	/workspace  ${SORTWORK}
	/FIELDS
			IDF_CT  2:1 - 2 :,
			IDF_CT_I17  1:1 - 1 :
	/INFILE $DFILT/${REQCOD_CT}_${dt}_GONOGO.dat 2000 1  "~"
	/joinkeys
					IDF_CT
	/INFILE $DFILT/${REQCOD_CT}_${dt}_GONOGO_NEW.dat 2001 "~"
	/joinkeys
					IDF_CT_I17
	/JOIN UNPAIRED  ONLY
	/OUTFILE  ${DFILT}/${REQCOD_CT}_${dt}_diff0.dat overwrite
	 /REFORMAT
				leftside:IDF_CT,
				rightside:IDF_CT_I17
endofsort


	${SORTDIR}/syncsort << endofsort
	/STATISTICS
	/workspace  ${SORTWORK}
	/FIELDS
			chainL  1:1 - 1 :, 
			chainR  2:1 - 2 :
	/INFILE ${DFILT}/${REQCOD_CT}_${dt}_diff0.dat 2000 1  "~"
	/joinkeys
					chainL,
					chainR
	/INFILE $DFILT/exclude_chain.lst 2001 "~"
	/joinkeys
					chainL,
					chainR
	/JOIN UNPAIRED  LEFT ONLY
	/OUTFILE  ${DFILT}/TRNPLAN0_${REQCOD_CT}_${dt}_diff.dat overwrite
	/REFORMAT
				leftside:chainL,
				leftside:chainR
endofsort


	LOG_CHAIN=`ls $DLOG/${ENV_PREFIX}_ESCJ0000* | tail -1`
	echo $LOG_CHAIN >> $FLOG
	echo "PLAN~VARIANTE~LASTPOBOOKING~CONSOMTH~CONSOYEA~ComptaSocialIFRSDone~ComptaSocialEBSDone~IsEpo~TypePOST~nb_NoEBS~IsEpoComptaRequestF~SSDCLO_LL~BLCSHTYEA_NF~BLCSHTYEA_NF~BLCSHTMTH_NF~CRE_D~DBCLO_D~CLODAT_D~SPCEND_D~SEGTYPCLO_CT~PERTYP_CT~ACCOUNT_D"  > ${DFILT}/${REQCOD_CT}_${dt}_params.dat 
	get_parms 1  $LOG_CHAIN >> ${DFILT}/${REQCOD_CT}_${dt}_params.dat 
	get_parms 2  $LOG_CHAIN >> ${DFILT}/${REQCOD_CT}_${dt}_params.dat 
	get_parms 3  $LOG_CHAIN >> ${DFILT}/${REQCOD_CT}_${dt}_params.dat 
	get_parms 4  $LOG_CHAIN >> ${DFILT}/${REQCOD_CT}_${dt}_params.dat 
	cat ${DFILT}/${REQCOD_CT}_${dt}_params.dat   2>&1 | ${TEE}

	${SORTDIR}/syncsort  << endofsort
	/STATISTICS
	/workspace  ${SORTWORK}
	/FIELDS
			plan  1:1 - 1 :,
			all_left  1:1 - 2 :,
			all_right 2:1 - 22 :
	/INFILE $DFILT/plan_chaine.lst 2001 "~"
	/joinkeys
					plan
	/INFILE ${DFILT}/${REQCOD_CT}_${dt}_params.dat  2000 1  "~"
	/joinkeys
					plan
	/OUTFILE  ${DFILT}/${REQCOD_CT}_${dt}_chain_params.dat overwrite
	 /REFORMAT
				leftside:all_left,
				rightside:all_right
endofsort

	echo
	echo "-----------------"
	echo "REQCOD_CT:" $REQCOD_CT
	echo "VNORME:" $VNORME
	echo
	echo "-----------------"
	echo "Ecarts: "
	sort ${DFILT}/TRNPLAN0_${REQCOD_CT}_${dt}_diff.dat
	echo "-----------------"
	echo 

}




#----DEV

rm 	${DFILT}/TRNPLAN0_*_diff.dat  >&1 | ${TEE}

case ${HOSTNAME} in 
   "dcvdevobbatch")
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201101" ] ;then test_fct 20201101     I4IMINV      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201109" ] ;then test_fct 20201109     I4IMINVB     >&1 | ${TEE} ;fi;
		
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201201" ] ;then test_fct 20201201     I4IYINV      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201207" ] ;then test_fct 20201207     I4IYINVB     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201208" ] ;then test_fct 20201208     I4IYPOS      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201209" ] ;then test_fct 20201209     I4IYPOSB     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201212" ] ;then test_fct 20201212     I4IYPOC      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210101" ] ;then test_fct 20210101     EBSEYPOS     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210106" ] ;then test_fct 20210106     EBSEYPOSB    >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210108" ] ;then test_fct 20210108     EBSEYPOC     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210111" ] ;then test_fct 20210111     I4IYPOCB     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210205" ] ;then test_fct 20210205     EBSEYPOCB    >&1 | ${TEE} ;fi;

		if [ "$ARGV2" = "" -o "$ARGV2" = "20210301" ] ;then test_fct 20210301	  I4IQINV	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210308" ] ;then test_fct 20210308	  I4IQINVB	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210309" ] ;then test_fct 20210309	  I4IQPOS	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210310" ] ;then test_fct 20210310	  I4IQPOSB	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210401" ] ;then test_fct 20210401	  I4IQPOC	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210402" ] ;then test_fct 20210402	  EBSEQPOS	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210407" ] ;then test_fct 20210407	  EBSEQPOSB	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210408" ] ;then test_fct 20210408	  EBSEQPOC	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210412" ] ;then test_fct 20210412	  I4IQPOCB	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210507" ] ;then test_fct 20210507	  EBSEQPOCB	   >&1 | ${TEE} ;fi;
   ;;

   "dcvcnvobbatch")
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201101" ] ;then test_fct 20201101     I4IMINV      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201109" ] ;then test_fct 20201109     I4IMINVB     >&1 | ${TEE} ;fi;
		
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201201" ] ;then test_fct 20201201     I4IYINV      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201207" ] ;then test_fct 20201207     I4IYINVB     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201208" ] ;then test_fct 20201208     I4IYPOS      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201209" ] ;then test_fct 20201209     I4IYPOSB     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201212" ] ;then test_fct 20201212     I4IYPOC      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210101" ] ;then test_fct 20210101     EBSEYPOS     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210106" ] ;then test_fct 20210106     EBSEYPOSB    >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210108" ] ;then test_fct 20210108     EBSEYPOC     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210111" ] ;then test_fct 20210111     I4IYPOCB     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210205" ] ;then test_fct 20210205     EBSEYPOCB    >&1 | ${TEE} ;fi;

		if [ "$ARGV2" = "" -o "$ARGV2" = "20210301" ] ;then test_fct 20210301	  I4IQINV	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210308" ] ;then test_fct 20210308	  I4IQINVB	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210309" ] ;then test_fct 20210309	  I4IQPOS	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210310" ] ;then test_fct 20210310	  I4IQPOSB	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210401" ] ;then test_fct 20210401	  I4IQPOC	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210402" ] ;then test_fct 20210402	  EBSEQPOS	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210407" ] ;then test_fct 20210407	  EBSEQPOSB	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210408" ] ;then test_fct 20210408	  EBSEQPOC	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210412" ] ;then test_fct 20210412	  I4IQPOCB	   >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210507" ] ;then test_fct 20210507	  EBSEQPOCB	   >&1 | ${TEE} ;fi;
  "dcvcnvobbatch")
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201101" ] ;then test_fct 20201101     I4IMINV      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201109" ] ;then test_fct 20201109     I4IMINVB     >&1 | ${TEE} ;fi;
		
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201201" ] ;then test_fct 20201201     I4IYINV      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201207" ] ;then test_fct 20201207     I4IYINVB     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201208" ] ;then test_fct 20201208     I4IYPOS      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201209" ] ;then test_fct 20201209     I4IYPOSB     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20201212" ] ;then test_fct 20201212     I4IYPOC      >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210101" ] ;then test_fct 20210101     EBSEYPOS     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210106" ] ;then test_fct 20210106     EBSEYPOSB    >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210108" ] ;then test_fct 20210108     EBSEYPOC     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210111" ] ;then test_fct 20210111     I4IYPOCB     >&1 | ${TEE} ;fi;
		if [ "$ARGV2" = "" -o "$ARGV2" = "20210205" ] ;then test_fct 20210205     EBSEYPOCB    >&1 | ${TEE} ;fi;

	"dcvtsto2db02")
		if [ "$ARGV2" != "" ]
		then
			test_fct $ARGV2
		fi
      ;; 
   *)  
      ;; 
esac 

${SYBASE}/${SYBASE_OCS}/bin/isql -H${NSTEP} -U$USR -S$SRV  -o$DFILT/ADD_NEW_REQUESTS.log -Jiso_1 -w1024 -P$PSWD <<EOF

	     delete BEST..TI17REQCHN where reqcod_ct  = 'EBSEMINV'
      --insert into BEST..TI17REQCHN select   'EBSEMINV', CHAIN_CT, IDF_CT, REQST_CHAIN_LL fromBEST..TI17REQCHN where reqcod_ct  = '??'
        
        delete BEST..TI17REQCHN where reqcod_ct  = 'EBSEMINVB'
      --insert into BEST..TI17REQCHN select   'EBSEMINVB', CHAIN_CT, IDF_CT, REQST_CHAIN_LL from BEST..TI17REQCHN where reqcod_ct  = '??'
        
        
        
        delete BEST..TI17REQCHN where reqcod_ct  = 'EBSEYINV'
        insert into BEST..TI17REQCHN select   'EBSEYINV', CHAIN_CT, IDF_CT, REQST_CHAIN_LL from BEST..TI17REQCHN where reqcod_ct  = 'EBSEYPOS'
        
        delete BEST..TI17REQCHN where reqcod_ct  = 'EBSEYINVB'
        insert into BEST..TI17REQCHN select   'EBSEYINVB', CHAIN_CT, IDF_CT, REQST_CHAIN_LL from BEST..TI17REQCHN where reqcod_ct  = 'EBSEYPOSB'
        
        delete BEST..TI17REQCHN where reqcod_ct  = 'EBSEQINV'
        insert into BEST..TI17REQCHN select   'EBSEQINV', CHAIN_CT, IDF_CT, REQST_CHAIN_LL from BEST..TI17REQCHN where reqcod_ct  = 'EBSEQPOS'
        
        delete BEST..TI17REQCHN where reqcod_ct  = 'EBSEQINVB'
        insert into BEST..TI17REQCHN select   'EBSEQINVB', CHAIN_CT, IDF_CT, REQST_CHAIN_LL from BEST..TI17REQCHN where reqcod_ct  = 'EBSEQPOSB'
go
EOF
 
wc -l 	${DFILT}/TRNPLAN0_*_diff.dat  >&1 | ${TEE}

echo "END TNR:" $? >> $FLOG


JOBEND


