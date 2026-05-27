#!/bin/ksh
#=============================================================================
# nom de l'application           : ESTIMATIONS - INVENTAIRE
#                                  Preparation des fichiers DTSTATGTA0 et VSTATGTA0
# nom du script SHELL            : ESID1011.cmd
# revision                       : $Revision:   1.14  $
# date de creation               : 05/09/97
# auteur                         : CGI
# references des specifications  : 
#-----------------------------------------------------------------------------
# description
#   Preparing files DTSTATGTA0 and VSTATGTA0
#
# job launched by ESID1010.cmd
# Launch C programs ESTM7606 and ESTM7615
# Out file sort   ${DFILT}/${NSTEP}_${IB}_SORT_GTA_O.dat
#     ${DFILT}/${NSTEP}_${IB}_SORT_STATGTA_O.dat
#
#-----------------------------------------------------------------------------
# historique des modifications
#[001]  1820/04/2012 Roger Cassis :spot:23802 - Modifications pour Solvency
#[002]  21/10/2015 Gwendal Bonnerue :spot:29095 - Modifictaion pour eviter la supression reciproque de fichier lors de l'intraday et l'inventaire
#[003]  07/03/2016 Merlin BONATO :30277: -pas de spira- suppression des fichiers DFILT
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
BALSHTYEA_NF=$1
BALSHTMTH_NF=$2
SSDs0=$3

if [[ ${NCHAIN} = "${ENV_PREFIX}_ESDJ7000" ]];
  then
    EST_IADVPERICASE0=${EST_IAVPERICASE0}
    EST_IRDVPERICASE0=${EST_IRVPERICASE0}
    EST_ARCSTATGTA=${EST_ARCSTATGTA_ID}
    EST_DTSTATGTAA0=${EST_DTSTATGTAA0_ID}
    EST_VTSTATGTA0=${EST_VTSTATGTA0_ID}
    EST_TSTATGTAANO=${EST_TSTATGTAANO_ID}
fi

ECHO_LOG "EST_IADVPERICASE0 ==> ${EST_IAVPERICASE0}"
ECHO_LOG "EST_IRDVPERICASE0 ==> ${EST_IRVPERICASE0}"
ECHO_LOG "EST_ARCSTATGTA    ==> ${EST_ARCSTATGTA_ID}"
ECHO_LOG "EST_DTSTATGTAA0   ==> ${EST_DTSTATGTAA0_ID}"
ECHO_LOG "EST_VTSTATGTA0    ==> ${EST_VTSTATGTA0_ID}"
ECHO_LOG "EST_TSTATGTAANO   ==> ${EST_TSTATGTAANO_ID}"

NSTEP=${NJOB}_00
#Last version of ESID1010 files deletion # [002]
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_DTSTATGTAA0}`/${NCHAIN}_DTSTATGTAA0*.dat
 `dirname ${EST_TSTATGTAANO}`/${NCHAIN}_TSTATGTAANO*.dat
 `dirname ${EST_VTSTATGTA0}`/${NCHAIN}_VTSTATGTA0*.dat"



NSTEP=${NJOB}_05
#Merge of CURGTA and GTA
#-----------------------------------------------------------------------------
LIBEL="Current merge of CURGTA of GTA ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_GTA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GTA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        BALSHEY_NF 3:1 - 3: EN,
        BALSHRMTH_NF 4:1 - 4: EN,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:
/CONDITION LIGNECPT ( ${BALSHTYEA_NF}   > BALSHEY_NF or ( ${BALSHTYEA_NF} EQ BALSHEY_NF and ${BALSHTMTH_NF} >= BALSHRMTH_NF  )) and ${EST_SORT_CONDITION}  
/INCLUDE LIGNECPT
/KEYS  RETCTR_NF,
       RETEND_NT,
       RETSEC_NF,
       RTY_NF,
       RETUW_NT,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT
exit
EOF
SORT

NSTEP=${NJOB}_06
#Sort STATGTA
#-----------------------------------------------------------------------------
LIBEL=" STATGTA "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_STATGTA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_STATGTA_O.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS SSD_CF 1:1 - 1: EN,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11:,
        UW_NT 12:1 - 12:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:
/CONDITION INVENTAIRE ${EST_SORT_CONDITION}
/INCLUDE INVENTAIRE            
/KEYS  RETCTR_NF,
       RETEND_NT,
       RETSEC_NF,
       RTY_NF,
       RETUW_NT,
       CTR_NF,
       END_NT,
       SEC_NF,
       UWY_NF,
       UW_NT
exit
EOF
SORT    


NSTEP=${NJOB}_20
#Extend GTs with acceptation LOB
#-----------------------------------------------------------------------------
LIBEL=" Extend GTs with acceptation LOB "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_ARCSTATGTA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_ALOB.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        GT_CTR_NF            8:1 -  8:
       ,GT_END_NT            9:1 -  9:
       ,GT_SEC_NF           10:1 - 10:
       ,GT_UWY_NF           11:1 - 11:
       ,GT_UW_NT            12:1 - 12:
	   ,all_cols_gt			 1:1 - 71:
	   ,PER_CTR_NF   		 3:1	-	  3:
	   ,PER_END_NT   		 4:1	-	  4:
	   ,PER_SEC_NF   		 5:1	-	  5:
	   ,PER_UWY_NF   		 6:1	-	  6:
	   ,PER_UW_NT    		 7:1	-	  7:
	   ,PER_LOB_CF  		38:1	-	38:
	   ,all_cols_per	    1:1 - 206:
/INFILE ${DFILT}/${NJOB}_05_${IB}_SORT_GTA_O.dat 1000 1 "~"
/INFILE ${DFILT}/${NJOB}_06_${IB}_SORT_STATGTA_O.dat 1000 1 "~"

/joinkeys 
        GT_CTR_NF          
       ,GT_END_NT          
       ,GT_SEC_NF          
       ,GT_UWY_NF          
       ,GT_UW_NT           
/INFILE ${EST_IADVPERICASE0}  1000 1 "~"
/joinkeys 
	    PER_CTR_NF   		
	   ,PER_END_NT   		
	   ,PER_SEC_NF   		
	   ,PER_UWY_NF   		
	   ,PER_UW_NT    		
/JOIN UNPAIRED LEFTSIDE 
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside:all_cols_gt          
	,rightside:PER_LOB_CF
exit
EOF
SORT    


NSTEP=${NJOB}_30
#Sort Extend GTs with retro LOB
#-----------------------------------------------------------------------------
LIBEL=" Extend GTs with retro LOB "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_GT_ALOB.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_GT_ALOB_RLOB.dat 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        GT_RETCTR_NF         24:1 - 24:
       ,GT_RETEND_NT         25:1 - 25:
       ,GT_RETSEC_NF         26:1 - 26:
       ,GT_RTY_NF            27:1 - 27:
       ,GT_RETUW_NT          28:1 - 28:
	   ,all_cols_gt_alob     1:1 - 72:
	   ,PER_CTR_NF   		 3:1	-	  3:
	   ,PER_END_NT   		 4:1	-	  4:
	   ,PER_SEC_NF   		 5:1	-	  5:
	   ,PER_UWY_NF   		 6:1	-	  6:
	   ,PER_UW_NT    		 7:1	-	  7:
	   ,PER_LOB_CF  		38:1	-	38:
	   ,all_cols_per	    1:1 - 206:
/joinkeys 
        GT_RETCTR_NF          
       ,GT_RETEND_NT          
       ,GT_RETSEC_NF          
       ,GT_RTY_NF          
       ,GT_RETUW_NT           
/INFILE ${EST_IRDVPERICASE0}  1000 1 "~"
/joinkeys 
	    PER_CTR_NF   		
	   ,PER_END_NT   		
	   ,PER_SEC_NF   		
	   ,PER_UWY_NF   		
	   ,PER_UW_NT    		
/JOIN UNPAIRED LEFTSIDE 
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside:all_cols_gt_alob          
	,rightside:PER_LOB_CF	 
exit
EOF
SORT    


NSTEP=${NJOB}_40
# Split GTs on ${EST_DTSTATGTAA0} , ${EST_VTSTATGTA0} and ${EST_TSTATGTAANO}"
#-----------------------------------------------------------------------------
LIBEL=" Split GTs on ${EST_DTSTATGTAA0} , ${EST_VTSTATGTA0} and ${EST_TSTATGTAANO}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_SORT_GT_ALOB_RLOB.dat 1000 1"
SORT_O="${EST_DTSTATGTAA0} 1000 1"
SORT_O2="${EST_VTSTATGTA0} 1000 1"
SORT_O3="${EST_TSTATGTAANO} 1000 1"
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 
        GT_TRNCOD1_CF        6:1 -  6:1
	   ,all_cols_gt			 1:1 - 71:
	   ,LOB_ACC   		 	72:1 - 72:
	   ,LOB_RET   		 	73:1 - 73:

/CONDITION COND_PC   ( GT_TRNCOD1_CF = "1"  AND  LOB_ACC != "30" AND LOB_ACC != "31" AND LOB_ACC != ""  )  
/OUTFILE ${SORT_O} overwrite
/INCLUDE COND_PC
/REFORMAT  all_cols_gt  

/CONDITION COND_LIFE ( LOB_ACC  = "30" OR LOB_ACC  = "31"  )  OR 
					 ( LOB_RET  = "30" OR LOB_RET  = "31"  )   
/OUTFILE ${SORT_O2} overwrite
/INCLUDE COND_LIFE
/REFORMAT  all_cols_gt  

/CONDITION COND_ANO  ( LOB_ACC = "" AND LOB_RET = ""   )
/OUTFILE ${SORT_O3} overwrite
/INCLUDE COND_ANO
/REFORMAT  all_cols_gt  

/COPY
exit
EOF
SORT    


JOBEND
