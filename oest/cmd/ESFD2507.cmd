#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - Internal retrocession
# nom du script SHELL           : ESFD2507.cmd
# revision                      : $Revision:  
# date de creation              : 30/12/2020
# auteur                        : MZM
#-----------------------------------------------------------------------------
# Description :
#  APPLYING LOFACTOR TO AE Transaction
#
# job launched by ESFD1800.cmd ESPD1800.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 12/01/2021 : MZM   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL 
#[002] 09/04/2021 : MZM   :  Spira 92736 Remplacer FTRSLNK par FBOPRSLNK
#[003] 14/06/2021 MZM :spira:96997 TNR EBS INT Utilisation du FBOPRSLNK la place du FTRSLNK ; 
#                                   Generation du DLGTR A partir du DLGTAR Avec Application du LOFACTOR
#[004] 23/07/2021 MZM :spira:95950 IFRS17 AE extraction - pericase issue
#[005] 12/08/2021 MZM :spira:95950 IFRS17 AE extraction - pericase issue Ano en generation des DLSGTR
#[006] 02/09/2021 MZM :spira:95950 IFRS17 AE extraction - Application Regle sur Distinction I17 STD et I17 INI (PRS 740 ACMTRS 101)
#[007] 17/06/2022 MZM :spira:104778 AJOUT COULOIR I17S
#[008] 12/07/2022 MZM :spira:105604 I17PRD - Missing AES INI retro in GLT
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get parameters
# BALSHTYEA_NF=$1
# CLODAT_D=$2
# TYPEINV=$3
# NORME=$4

# Job initialisation
JOBINIT               

#if [ "${TYPEINV}" != "INV" ]
#then
#
#	EST_FDETTRS=${EPO_FDETTRS}
#	EST_FRETTRF=${EPO_FRETTRF}
#	EST_FCES=${EPO_FCES}
#	EST_FPLC=${EPO_FPLC}
#	EST_FCURCVSNI=${EPO_FCURCVSNI}
#	EST_FCURQUOT=${EPO_FCURQUOT}
#	EST_FCURCVSN=${EPO_FCURCVSN}
#	EST_FPLACEMT0=${EPO_FPLACEMT0}
#	EST_IADVPERICASE=${EPO_IADVPERICASE}
#	EST_FTRANSCODE=${EPO_FTRANSCODE}
#	EST_FTRSLNK=${EPO_FTRSLNK}
#
#	if [ "${TYPEINV}" = "POS" ]
#	then
#		if [ "${NORME}" = "EBS" ]
#		then
#			EPO_DLSGTAR=${EPO_DLSGTARSIISO}
#			EPO_DLSGTR=${EPO_DLSGTRSIISO}							
#		else
#			EPO_DLSGTAR=${EPO_DLSGTARSO}
#			EPO_DLSGTR=${EPO_DLSGTRSO}								
#		fi
#	else
#		if [ "${NORME}" = "EBS" ]
#		then
#			EPO_DLSGTAR=${EPO_DLSGTARSIICO}						
#		else
#			EPO_DLSGTAR=${EPO_DLSGTARCO}
#			EPO_DLSGTR=${EPO_DLSGTRCO}
#								
#		fi
#	fi
#fi

#[001] ESF_FLORETFACTOR=${ESF_FLORETFACTOR}	

if [ ! -f ${EPO_DLSGTAR} ]
then
	touch ${EPO_DLSGTAR}
fi


if [ ! -f ${EPO_DLSGTR} ]
then
	touch ${EPO_DLSGTR}
fi

if [ ! -f ${ESF_FLORETFACTOR} ]
then
	touch ${ESF_FLORETFACTOR}
fi

if [ ! -f ${ESF_FLORETFACTOR_INI} ]
then
	touch ${ESF_FLORETFACTOR_INI}
fi

if [ ! -f ${ESF_DLSGTAR_INI} ]
then
	touch ${ESF_DLSGTAR_INI}
fi


if [ ! -f ${ESF_DLSGTR_INI} ]
then
	touch ${ESF_DLSGTR_INI}
fi

#[001]export ESF_FLORETFACTOR=${DFILI}/${ENV_PREFIX}_ESPD0060_FLORETFACTOR_STD_${TYPEINV}_${PARM_ICLODAT_D}.dat

## RETEST TU

#INVCONSO_D="20201231"
#CONSOYEA="2020"
#TYPEINV="POS"
#NORME="EBS"
#
#### TU END

ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV................: ${TYPEINV}"
ECHO_LOG "#===> NORME..................: ${NORME}"
ECHO_LOG "#===> NORME_CF...............: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT.................: ${IDF_CT}"
ECHO_LOG "#===> EPO_DLSGTAR....................: ${EPO_DLSGTAR}"
ECHO_LOG "#===> EPO_DLSGTR.....................: ${EPO_DLSGTR}"
ECHO_LOG "#===> ESF_DLSGTR_INI.................: ${ESF_DLSGTR_INI}"
ECHO_LOG "#===> ESF_DLSGTAR_INI................: ${ESF_DLSGTAR_INI}"
ECHO_LOG "#===> EPO_FBOPRSLNK..................: ${EPO_FBOPRSLNK}"
ECHO_LOG "#===> ESF_FTRSLNK_TXT................: ${ESF_FTPRSLNK_TXT}"
ECHO_LOG "#===> ESF_FLORETFACTOR...............: ${ESF_FLORETFACTOR}"
ECHO_LOG "#===> ESF_FLORETFACTOR_INI...........: ${ESF_FLORETFACTOR_INI}"
ECHO_LOG "#========================================================================="


########################################################################################
##                    DEB TRT EXTRACTION AE       EBS                                ###
########################################################################################

if [ ${IDF_CT} = "EBS_ESPD1800"  ]
then


NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort  DLSGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLSGTAR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_O.dat OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS   SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
        TRNCOD_CF,
        DBLTRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_20
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort DLSGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLSGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTR_O.dat OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS   SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
        TRNCOD_CF,
        DBLTRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


# TRIE du fichier LOFACTOR sur RETCTR,RETENT, RETSEC, RTY, RETUW 

NSTEP=${NJOB}_30
# FLORETFACTOR 
#-----------------------------------------------------------------------------
LIBEL="SORT OF FLORETFACTOR BY RETCTR,RETENT, RETSEC, RTY, RETUW ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLORETFACTOR.dat 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 	CTR_NF 				  		    1:1 - 1:,
					END_NT 				          2:1 - 2:,
					SEC_NF 				          3:1 - 3:,
					UWY_NF 				          4:1 - 4:,
					UW_NT 					        5:1 - 5:,
					RETCTR_NF 			   			6:1 - 6:,
					RETEND_NT 			        7:1 - 7:,
					RETSEC_NF 			        8:1 - 8:,
					RETRTY_NF 				      9:1 - 9:,
					RETUW_NT 			          10:1 - 10:,
					LOFACTOR  			        30:1 - 30: EN 15/3
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      LOFACTOR
exit
EOF
SORT



NSTEP=${NJOB}_40
# Sort ${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR_O.dat
#-----------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, TO Join To LOFACTOR..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_DLSGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:       	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT
/SUM
/OUTFILE ${SORT_O}
exit
EOF
SORT
#



#[004]SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_DLSGTAR_O.dat 1000 1" 
NSTEP=${NJOB}_50
# Join and sort of  DLSGTAR File and FLORETFACTOR by RETCTR,RETENT, RETSEC, RTY, RETUW 
#------------------------------------------------------------------------------
LIBEL="Current DLSGTAR_O File Sort, Join and Fusion With ESF_FLORETFACTOR ..."
SORT_WDIR=${SORTWORK}
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_DLSGTAR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_FACTOR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
					CTR_NF_F2						    1:1 -  1:,
        	END_NT_F2        		    2:1 -  2:,
					SEC_NF_F2 			  	    3:1 -  3:,
					UWY_NF_F2        	      4:1 -  4:,
					RETCTR_NF_F2				    6:1 -  6:,
        	RETEND_NT_F2            7:1 -  7:,
					RETSEC_NF_F2 			      8:1 -  8:,
					RTY_NF_F2        	      9:1 -  9:,
					RETUW_NT_F2             10:1 -  10:,							
        	LOFACTOR_F2 		        30:1 - 30: EN 15/3,
					ALL_F1    			        1:1 -  72:,        	
					ALL_F2    			        1:1 - 30:				
/JOINKEYS RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT,
          CTR_NF, 
					END_NT, 
					SEC_NF, 
					UWY_NF	
/INFILE ${DFILT}/${NJOB}_30_${IB}_SORT_FLORETFACTOR.dat 1000 1 "~"
/JOINKEYS RETCTR_NF_F2,
					RETEND_NT_F2,
					RETSEC_NF_F2,
          RTY_NF_F2,
          RETUW_NT_F2,
					CTR_NF_F2,	
      		END_NT_F2, 
					SEC_NF_F2, 
					UWY_NF_F2           
/JOIN UNPAIRED LEFTSIDE                 
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: LOFACTOR_F2        
exit
EOF
SORT   


NSTEP=${NJOB}_55
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="SORT GTAR UNIQUE TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_SORT_DLSGTAR_FACTOR_O.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_FACTOR_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    	            1:1 - 73:       
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (ALL_F1 != "" )
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT



NSTEP=${NJOB}_60
# SORT UNIQUE of DLSGTAR_FACTOR 
#------------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, Join and Fusion UNIQUE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_55_${IB}_SORT_DLSGTAR_FACTOR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_FACTOR_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT_F2               36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
        	LOFACTOR      					72:1 - 72: EN 15/3        	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT,
      		PLC_NT_F2,
      		RETCUR_CF,
      		TRNCOD_CF,    		 
					LOFACTOR
/SUM
/OUTFILE ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_70
# Sort ${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTR_O.dat
#-----------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, TO Join To LOFACTOR..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_DLSGTR_O.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTR_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:       	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT
/SUM
/OUTFILE ${SORT_O}
exit
EOF
SORT


#[004]SORT_I="${DFILT}/${NJOB}_70_${IB}_SORT_DLSGTR_O.dat 1000 1" 
NSTEP=${NJOB}_80
# Join and sort of  DLSGTR File and FLORETFACTOR by RETCTR,RETENT, RETSEC, RTY, RETUW 
#------------------------------------------------------------------------------
LIBEL="Current DLSGTR_O File Sort, Join and Fusion With ESF_FLORETFACTOR ..."
SORT_WDIR=${SORTWORK}
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_DLSGTR_O.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTR_FACTOR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
					CTR_NF_F2						    1:1 -  1:,
        	END_NT_F2        		    2:1 -  2:,
					SEC_NF_F2 			  	    3:1 -  3:,
					UWY_NF_F2        	      4:1 -  4:,
					RETCTR_NF_F2				    6:1 -  6:,
        	RETEND_NT_F2            7:1 -  7:,
					RETSEC_NF_F2 			      8:1 -  8:,
					RTY_NF_F2        	      9:1 -  9:,
					RETUW_NT_F2             10:1 -  10:,							
        	LOFACTOR_F2 		        30:1 - 30: EN 15/3,
					ALL_F1    			        1:1 -  72:,        	
					ALL_F2    			        1:1 - 30:				
/JOINKEYS RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT
/INFILE ${DFILT}/${NJOB}_30_${IB}_SORT_FLORETFACTOR.dat 1000 1 "~"
/JOINKEYS RETCTR_NF_F2,
					RETEND_NT_F2,
					RETSEC_NF_F2,
          RTY_NF_F2,
          RETUW_NT_F2
/JOIN UNPAIRED LEFTSIDE                 
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: LOFACTOR_F2        
exit
EOF
SORT    


#[006]
NSTEP=${NJOB}_85
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="SORT GTR UNIQUE TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_80_${IB}_SORT_DLSGTR_FACTOR_O.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTR_FACTOR_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    	            1:1 - 73:       
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (ALL_F1 != "" )
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT


NSTEP=${NJOB}_90
# SORT UNIQUE of DLSGTR_FACTOR 
#------------------------------------------------------------------------------
LIBEL="Current GTR File Sort, Join and Fusion UNIQUE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_85_${IB}_SORT_DLSGTR_FACTOR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTR_FACTOR_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT_F2               36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
        	LOFACTOR      					72:1 - 72: EN 15/3     	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT,
      		PLC_NT_F2,
      		RETCUR_CF,
      		TRNCOD_CF,    		 
					LOFACTOR
/SUM
/OUTFILE ${SORT_O}
exit
EOF
SORT

                    

# [002] APPLYING LORETROFACTOR TO EPO_DLSGTAR AND EPO_DLSGTR
# export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat 

NSTEP=${NJOB}_100
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying Lofacactor to DLSGTAR_TCODINI..."
PRG=ESTC2308  
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_55_${IB}_SORT_DLSGTAR_FACTOR_O.dat
#export ${PRG}_I1=${DFILT}/${NJOB}_60_${IB}_SORT_DLSGTAR_FACTOR_O.dat
#export ${PRG}_I2=${EPO_FTRSLNK}
export ${PRG}_I2=${EPO_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR_O.dat
EXECPRG



# [002] APPLYING LORETROFACTOR TO  EPO_DLSGTR
# export ${PRG}_I1=${DFILT}/${NJOB}_05_${IB}_SORT_GTAA_O.dat 

NSTEP=${NJOB}_110
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying Lofacactor to DLSGTR..."
PRG=ESTC2308
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
#export ${PRG}_I1=${DFILT}/${NJOB}_90_${IB}_SORT_DLSGTR_FACTOR_O.dat
export ${PRG}_I1=${DFILT}/${NJOB}_85_${IB}_SORT_DLSGTR_FACTOR_O.dat
export ${PRG}_I2=${EPO_FBOPRSLNK}
#export ${PRG}_I2=${EPO_FTRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTR_O.dat
EXECPRG

NSTEP=${NJOB}_120
#LIBEL="Copy De la Fusion --> DLSGTAR et DLSGTR..."
	EXECKSH "cp ${DFILT}/${NJOB}_100_${IB}_ESTC2308_DLSGTAR_O.dat  ${EPO_DLSGTAR}"
#	EXECKSH "cp ${DFILT}/${NJOB}_110_${IB}_ESTC2308_DLSGTR_O.dat  ${EPO_DLSGTR}"



#[003] Generation du DLREGTR à partir du DLSGTAR

NSTEP=${NJOB}_125
LIBEL="Generate  DLREGTR FROM --> DLSGTAR e..."
##	EXECKSH "cp ${DFILT}/${NJOB}_100_${IB}_ESTC2308_DLSGTAR_O.dat  ${EPO_DLSGTAR}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_100_${IB}_ESTC2308_DLSGTAR_O.dat 500 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2308_DLSGTR_O.dat 
SORT_O="${EPO_DLSGTR} OVERWRITE"	
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CHAMPS_1A7 1:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        CHAMPS_8A18_VIDE 8:1 - 18:,        
        AMT_M 19:1 - 19: EN 15/3,
        CHAMPS_20A23_VIDE 20:1 - 23:,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        CHAMPS_37A40 37:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:,
        CHAMPS_59A72 59:1 - 72:
/KEYS   
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRNCOD_CF,
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC 0
/DERIVEDFIELD CHAMPS_20A23_VIDE_NEW 5"~"
/DERIVEDFIELD CHAMPS_8A18_VIDE_NEW 11"~"
/OUTFILE ${SORT_O}
/REFORMAT 
      CHAMPS_1A7, 
      CHAMPS_8A18_VIDE_NEW, 
      AMT_MC, 
      CHAMPS_20A23_VIDE_NEW, 
			RETCTR_NF, 
			RETEND_NT,
			RETSEC_NF,
			RTY_NF,
			RETUW_NT,
			RETOCCYEA_NF,
			RETACY_NF,
			RETSCOSTRMTH_NF,
			RETSCOENDMTH_NF,
			RCL_NF,
			RETCUR_CF,
			RETAMT_MC,
			PLC_NT,
			CHAMPS_37A40,
			RETINTAMT_MC,
			TRN_NT,
			RETROAUTO_B,
			CHAMPS_59A72
exit
EOF
SORT

fi

########################################################################################
##                    FIN TRT EXTRACTION AE       EBS                                ###
########################################################################################

##else  ## FIN AE EBS


########################################################################################
##                    DEB TRT   IFRS17 INCEPTION et STANDARD                         ###
########################################################################################

##[007]if  [ ${IDF_CT} = "I17G_AET_RPO_I17" ]  ||  [ ${IDF_CT} = "I17P_AET_RPO_I17" ] ||  [ ${IDF_CT} = "I17L_AET_RPO_I17" ] || [ ${IDF_CT} = "I17G_AET_RPO_INI" ]  ||  [ ${IDF_CT} = "I17P_AET_RPO_INI" ]  ||  [ ${IDF_CT} = "I17L_AET_RPO_INI" ] || [ ${IDF_CT} = "I17S_AET_RPO_I17" ]  ||  [ ${IDF_CT} = "I17S_AET_RPO_INI" ]

if  [ ${IDF_CT} = "I17G_AET_RPO_I17" ]  ||  [ ${IDF_CT} = "I17P_AET_RPO_I17" ] ||  [ ${IDF_CT} = "I17L_AET_RPO_I17" ] || [ ${IDF_CT} = "I17S_AET_RPO_I17" ]
then



NSTEP=${NJOB}_01
#-----------------------------------------------------------------------------
LIBEL="Filter ESF_FTRSLNK_TXT on TRNCOD_I17 ONLY "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FTRSLNK_TXT}  500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_FTRSLNK_TRNCOD_I17_STD.dat 500 1"
SORT_O2="${DFILT}/${NSTEP}_${IB}_FTRSLNK_TRNCOD_I17_INI.dat 500 1"
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS  
     PRS_CF    		    1:1 -  1:,
     ACMTRS_NT    		2:1 -  2:,
     DETTRS_CF    		3:1 -  3:,
     DETTRS8_CF    		3:8 -  3:8    
/CONDITION IS_TRNCOD_I17_STD ( DETTRS8_CF = "I" OR DETTRS8_CF = "J" OR DETTRS8_CF = "K" OR DETTRS8_CF = "L"  OR DETTRS8_CF = "M" OR DETTRS8_CF = "N") AND (PRS_CF != "740" OR ACMTRS_NT != "101")
/CONDITION IS_TRNCOD_I17_INI ( DETTRS8_CF = "I" OR DETTRS8_CF = "J" OR DETTRS8_CF = "K" OR DETTRS8_CF = "L"  OR DETTRS8_CF = "M" OR DETTRS8_CF = "N") AND (PRS_CF= "740" AND ACMTRS_NT = "101")
/OUTFILE $SORT_O
/INCLUDE IS_TRNCOD_I17_STD
/OUTFILE $SORT_O2
/INCLUDE IS_TRNCOD_I17_INI
/COPY
exit
EOF
SORT


##|006] /INFILE ${DFILT}/${NJOB}_01_${IB}_FTRSLNK_TRNCOD_I17.dat 500 1 "~" 

NSTEP=${NJOB}_05I
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort  DLSGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLSGTAR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_I17_INI_O.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:,
			  PRS_CF_F2           1:1  - 1:,
			  ACMTRS_NT_F2				2:1  - 2:,
			  DETTRS_CF_F2				3:1  - 3:,
			  all_cols_F1		 		  1:1  - 72:
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_01_${IB}_FTRSLNK_TRNCOD_I17_INI.dat 500 1 "~" 
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:all_cols_F1
	,rightside:PRS_CF_F2   
	,rightside:ACMTRS_NT_F2    	
exit
EOF
SORT

##/INFILE ${ESF_FTRSLNK_TXT} 500 1 "~" 

NSTEP=${NJOB}_10I
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort  DLSGTAA AND JOIN TO FTRSLNK_TXT"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLSGTAA} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA_I17_INI_O.dat "
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:,
			  PRS_CF_F2           1:1  - 1:,
			  ACMTRS_NT_F2				2:1  - 2:,
			  DETTRS_CF_F2				3:1  - 3:,
			  all_cols_F1		 		  1:1  - 72:
/joinkeys 
       TRNCOD_CF
/INFILE ${DFILT}/${NJOB}_01_${IB}_FTRSLNK_TRNCOD_I17_INI.dat 500 1 "~"       
/joinkeys 
       DETTRS_CF_F2
/JOIN UNPAIRED LEFTSIDE
/OUTFILE ${SORT_O}
/REFORMAT 
	leftside:all_cols_F1
	,rightside:PRS_CF_F2   
	,rightside:ACMTRS_NT_F2   
exit
EOF
SORT

##[006] /CONDITION  IS_PRS_I17_STD ( PRS_CF_F2 != "740"  or (ACMTRS_NT_F2 != "101") ) AND TRNCOD_CF (NOT EXIST (TTRSLNK_740))

NSTEP=${NJOB}_15I
# Sort ${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAA_O.dat
#-----------------------------------------------------------------------------
LIBEL="Current GTAA File Sort FILTER INI AND STD ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10I_${IB}_SORT_DLSGTAA_I17_INI_O.dat 500 1"
SORT_O="${ESF_DLSGTAA_INI}"
#SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA_I17_INI_O.dat 500 1" 
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAA_I17_STD_O.dat 500 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	PRS_CF_F2               73:1 - 73:,
        	ACMTRS_NT_F2            74:1 - 74:,        	
        	FILLER_13_COLS 					59:1 - 74:       	
/KEYS 		CTR_NF,
      		END_NT,
      		SEC_NF,
      		UWY_NF,
      		UW_NT
/CONDITION  IS_PRS_I17_INI ( PRS_CF_F2 = "740"  and ACMTRS_NT_F2 = "101") 
/OUTFILE ${SORT_O}
/INCLUDE IS_PRS_I17_INI  
/OUTFILE ${SORT_O2}
/OMIT IS_PRS_I17_INI   
exit
EOF
SORT



NSTEP=${NJOB}_17I
LIBEL="Generate  EPO_DLSGTAA  FROM --> DLSGTAA_I17_INI AND DLSGTAA_I17_STD "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLSGTAA_INI} 500 1"
SORT_I2="${DFILT}/${NJOB}_15I_${IB}_SORT_DLSGTAA_I17_STD_O.dat 500 1" 
SORT_O="${EPO_DLSGTAA}"	
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CHAMPS_1A7 1:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        CHAMPS_8A18_VIDE 8:1 - 18:,        
        AMT_M 19:1 - 19: EN 15/3,
        CHAMPS_20A23_VIDE 20:1 - 23:,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        CHAMPS_37A40 37:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:,
        CHAMPS_59A72 59:1 - 74:
/KEYS   
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/OUTFILE ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_20I
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort DLSGTR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_DLSGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTR_O.dat OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        AMT_M 19:1 - 19: EN 15/3,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35: EN 15/3,
        PLC_NT 36:1 - 36 :,
        RETINTAMT_M 41:1 - 41: EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:
/KEYS   SSD_CF,
        ESB_CF,
        BALSHEY_NF,
        BALSHRMTH_NF,
        BALSHRDAY_NF,
        TRNCOD_CF,
        DBLTRNCOD_CF,
        CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT,
        OCCYEA_NF,
        ACY_NF,
        SCOSTRMTH_NF,
        SCOENDMTH_NF,
        CLM_NF,
        CUR_CF,
        CED_NF,
        BRK_NF,
        PAY_NF,
        KEY_NF,
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRN_NT,
        RETROAUTO_B
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT



# TRIE du fichier LOFACTOR sur RETCTR,RETENT, RETSEC, RTY, RETUW 

NSTEP=${NJOB}_30
# FLORETFACTOR 
#-----------------------------------------------------------------------------
LIBEL="SORT OF FLORETFACTOR BY RETCTR,RETENT, RETSEC, RTY, RETUW ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLORETFACTOR.dat 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 	CTR_NF 				  		    1:1 - 1:,
					END_NT 				          2:1 - 2:,
					SEC_NF 				          3:1 - 3:,
					UWY_NF 				          4:1 - 4:,
					UW_NT 					        5:1 - 5:,
					RETCTR_NF 			   			6:1 - 6:,
					RETEND_NT 			        7:1 - 7:,
					RETSEC_NF 			        8:1 - 8:,
					RETRTY_NF 				      9:1 - 9:,
					RETUW_NT 			          10:1 - 10:,
					LOFACTOR  			        30:1 - 30: EN 15/3
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      LOFACTOR
exit
EOF
SORT

# TRIE du fichier LOFACTOR sur RETCTR,RETENT, RETSEC, RTY, RETUW 

NSTEP=${NJOB}_30I
# FLORETFACTOR 
#-----------------------------------------------------------------------------
LIBEL="SORT OF FLORETFACTOR_INI BY RETCTR,RETENT, RETSEC, RTY, RETUW ..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_FLORETFACTOR_INI} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FLORETFACTOR_INI.dat 1000 1" 
INPUT_TEXT ${SORT_CMD} <<EOF
/FIELDS 	CTR_NF 				  		    1:1 - 1:,
					END_NT 				          2:1 - 2:,
					SEC_NF 				          3:1 - 3:,
					UWY_NF 				          4:1 - 4:,
					UW_NT 					        5:1 - 5:,
					RETCTR_NF 			   			6:1 - 6:,
					RETEND_NT 			        7:1 - 7:,
					RETSEC_NF 			        8:1 - 8:,
					RETRTY_NF 				      9:1 - 9:,
					RETUW_NT 			          10:1 - 10:,
					LOFACTOR  			        30:1 - 30: EN 15/3
/KEYS RETCTR_NF,
      RETEND_NT,
      RETSEC_NF,
      RETRTY_NF,
      RETUW_NT,
      LOFACTOR
exit
EOF
SORT


##[006]

NSTEP=${NJOB}_40I
# Sort ${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR_O.dat
#-----------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, TO Join To LOFACTOR..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05I_${IB}_SORT_DLSGTAR_I17_INI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_I17_INI_O.dat 1000 1" 
SORT_O2="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_I17_STD_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	PRS_CF_F2               73:1 - 73:,
        	ACMTRS_NT_F2            74:1 - 74:,        	
        	FILLER_13_COLS 					59:1 - 74:       	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT
/CONDITION  IS_PRS_I17_INI ( PRS_CF_F2 = "740"  and ACMTRS_NT_F2 = "101")  
/OUTFILE ${SORT_O}
/INCLUDE IS_PRS_I17_INI  
/OUTFILE ${SORT_O2}
/OMIT IS_PRS_I17_INI   
exit
EOF
SORT
#



#[004]SORT_I="${DFILT}/${NJOB}_40_${IB}_SORT_DLSGTAR_O.dat 1000 1" 
NSTEP=${NJOB}_45I
# Join and sort of  DLSGTAR_I17_INI File and FLORETFACTOR_INI by RETCTR,RETENT, RETSEC, RTY, RETUW 
#------------------------------------------------------------------------------
LIBEL="Current DLSGTAR_I17_INI_O File Sort, Join and Fusion With ESF_FLORETFACTOR_INI ..."
SORT_WDIR=${SORTWORK}
SORT_I="${DFILT}/${NJOB}_40I_${IB}_SORT_DLSGTAR_I17_INI_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_I17_INI_FACTOR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
					CTR_NF_F2						    1:1 -  1:,
        	END_NT_F2        		    2:1 -  2:,
					SEC_NF_F2 			  	    3:1 -  3:,
					UWY_NF_F2        	      4:1 -  4:,
					RETCTR_NF_F2				    6:1 -  6:,
        	RETEND_NT_F2            7:1 -  7:,
					RETSEC_NF_F2 			      8:1 -  8:,
					RTY_NF_F2        	      9:1 -  9:,
					RETUW_NT_F2             10:1 -  10:,							
        	LOFACTOR_F2 		        30:1 - 30: EN 15/3,
					ALL_F1    			        1:1 -  72:,        	
					ALL_F2    			        1:1 - 30:				
/JOINKEYS RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT,
          CTR_NF, 
					END_NT, 
					SEC_NF, 
					UWY_NF	
/INFILE ${DFILT}/${NJOB}_30I_${IB}_SORT_FLORETFACTOR_INI.dat 1000 1 "~"
/JOINKEYS RETCTR_NF_F2,
					RETEND_NT_F2,
					RETSEC_NF_F2,
          RTY_NF_F2,
          RETUW_NT_F2,
					CTR_NF_F2,	
      		END_NT_F2, 
					SEC_NF_F2, 
					UWY_NF_F2           
/JOIN UNPAIRED LEFTSIDE                 
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: LOFACTOR_F2        
exit
EOF
SORT   


NSTEP=${NJOB}_50I
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="SORT GTAR UNIQUE TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_45I_${IB}_SORT_DLSGTAR_I17_INI_FACTOR_O.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_I17_INI_FACTOR_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    	            1:1 - 74:       
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (ALL_F1 != "" )
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT


#[008] 

NSTEP=${NJOB}_55I
# SORT UNIQUE of DLSGTAR_FACTOR_INI 
#------------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, Join and Fusion UNIQUE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50I_${IB}_SORT_DLSGTAR_I17_INI_FACTOR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_I17_INI_FACTOR_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT_F2               36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
        	LOFACTOR      					72:1 - 72: EN 15/3        	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT,
      		PLC_NT_F2,
      		RETCUR_CF,
      		TRNCOD_CF,    		 
					LOFACTOR
/OUTFILE ${SORT_O}
exit
EOF
SORT

                   

# [002] APPLYING LORETROFACTOR TO EPO_DLSGTAR_I17_INI

NSTEP=${NJOB}_60I
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying Lofacactor INI to DLSGTAR_I17_INI..."
PRG=ESTC2308  
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_55I_${IB}_SORT_DLSGTAR_I17_INI_FACTOR_O.dat
export ${PRG}_I2=${EPO_FBOPRSLNK}
#export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR_I17_INI_FACTOR_O.dat
export ${PRG}_O1="${ESF_DLSGTAR_INI}"
EXECPRG


# Generation du ESF_DLREGTR_INI à partir du ESF_DLSGTAR_INI
#SORT_I="${DFILT}/${NJOB}_60I_${IB}_DLSGTAR_I17_INI_FACTOR_O.dat 500 1"
#SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2308_DLSGTR_I17_INI_FACTOR_O.dat"
##	EXECKSH "cp ${DFILT}/${NJOB}_60_${IB}_DLSGTAR_I17_INI_FACTOR_O.dat  ${EPO_DLSGTAR}"

NSTEP=${NJOB}_65I
LIBEL="Generate  DLREGTR FROM --> DLSGTAR e..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLSGTAR_INI} 500 1" 
SORT_O="${ESF_DLSGTR_INI}"	
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CHAMPS_1A7 1:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        CHAMPS_8A18_VIDE 8:1 - 18:,        
        AMT_M 19:1 - 19: EN 15/3,
        CHAMPS_20A23_VIDE 20:1 - 23:,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        CHAMPS_37A40 37:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
			  CHAMPS_42A57 42:1 - 57:,
        RETROAUTO_B 58:1 - 58:,
        CHAMPS_59A72 59:1 - 74:
/KEYS   
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRNCOD_CF,
        RETROAUTO_B
/SUMMARIZE  TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC 0
/DERIVEDFIELD CHAMPS_20A23_VIDE_NEW 5"~"
/DERIVEDFIELD CHAMPS_8A18_VIDE_NEW 11"~"
/OUTFILE ${SORT_O}
/REFORMAT 
      CHAMPS_1A7, 
      CHAMPS_8A18_VIDE_NEW, 
      AMT_MC, 
      CHAMPS_20A23_VIDE_NEW, 
			RETCTR_NF, 
			RETEND_NT,
			RETSEC_NF,
			RTY_NF,
			RETUW_NT,
			RETOCCYEA_NF,
			RETACY_NF,
			RETSCOSTRMTH_NF,
			RETSCOENDMTH_NF,
			RCL_NF,
			RETCUR_CF,
			RETAMT_MC,
			PLC_NT,
			CHAMPS_37A40,
			RETINTAMT_MC,
			CHAMPS_42A57,
			RETROAUTO_B,
			CHAMPS_59A72
exit
EOF
SORT



NSTEP=${NJOB}_70I
# Join and sort of  DLSGTAR_I17_STD File and FLORETFACTOR_STD by RETCTR,RETENT, RETSEC, RTY, RETUW 
#------------------------------------------------------------------------------
LIBEL="Current DLSGTAR_I17_STD_O File Sort, Join and Fusion With ESF_FLORETFACTOR_STD ..."
SORT_WDIR=${SORTWORK}
SORT_I="${DFILT}/${NJOB}_40I_${IB}_SORT_DLSGTAR_I17_STD_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_I17_STD_FACTOR_O.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT                  36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
					CTR_NF_F2						    1:1 -  1:,
        	END_NT_F2        		    2:1 -  2:,
					SEC_NF_F2 			  	    3:1 -  3:,
					UWY_NF_F2        	      4:1 -  4:,
					RETCTR_NF_F2				    6:1 -  6:,
        	RETEND_NT_F2            7:1 -  7:,
					RETSEC_NF_F2 			      8:1 -  8:,
					RTY_NF_F2        	      9:1 -  9:,
					RETUW_NT_F2             10:1 -  10:,							
        	LOFACTOR_F2 		        30:1 - 30: EN 15/3,
					ALL_F1    			        1:1 -  72:,        	
					ALL_F2    			        1:1 - 30:				
/JOINKEYS RETCTR_NF,
					RETEND_NT,
					RETSEC_NF,
          RETRTY_NF,
          RETUW_NT,
          CTR_NF, 
					END_NT, 
					SEC_NF, 
					UWY_NF	
/INFILE ${DFILT}/${NJOB}_30_${IB}_SORT_FLORETFACTOR.dat 1000 1 "~"
/JOINKEYS RETCTR_NF_F2,
					RETEND_NT_F2,
					RETSEC_NF_F2,
          RTY_NF_F2,
          RETUW_NT_F2,
					CTR_NF_F2,	
      		END_NT_F2, 
					SEC_NF_F2, 
					UWY_NF_F2           
/JOIN UNPAIRED LEFTSIDE                 
/OUTFILE ${SORT_O}
/REFORMAT LEFTSIDE: ALL_F1, RIGHTSIDE: LOFACTOR_F2        
exit
EOF
SORT   


NSTEP=${NJOB}_75I
# Begin Sort
#-----------------------------------------------------------------------------
LIBEL="SORT GTAR UNIQUE TL file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_70I_${IB}_SORT_DLSGTAR_I17_STD_FACTOR_O.dat 1000 1" 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_I17_STD_FACTOR_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS ALL_F1    	            1:1 - 74:       
/KEYS   ALL_F1
/CONDITION NODUPLICATEKEY (ALL_F1 != "" )
/SUM 
/OUTFILE ${SORT_O}
/INCLUDE NODUPLICATEKEY
exit
EOF
SORT


#[008]  Suppression du /SUM

NSTEP=${NJOB}_80I
# SORT UNIQUE of DLSGTAR_FACTOR_STD 
#------------------------------------------------------------------------------
LIBEL="Current GTAR File Sort, Join and Fusion UNIQUE..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_75I_${IB}_SORT_DLSGTAR_I17_STD_FACTOR_O.dat 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLSGTAR_I17_STD_FACTOR_O.dat 1000 1" 
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 	SSD_CF 							    1:1 - 1:,
					ESB_CF 				          2:1 - 2:,
					BALSHEY_NF 		          3:1 - 3:,
					BALSHRMTH_NF 	          4:1 - 4:,
					BALSHRDAY_NF 	          5:1 - 5:,
					TRNCOD_CF 			        6:1 - 6:,
					DBLTRNCOD_CF 	          7:1 - 7:,
					CTR_NF 				          8:1 - 8:,
					END_NT 				          9:1 - 9:,
					SEC_NF 				          10:1 - 10:,
					UWY_NF 				          11:1 - 11:,
					UW_NT 					        12:1 - 12:,
					OCCYEA_NF 			        13:1 - 13:,
					ACY_NF 				          14:1 - 14:,
					SCOSTRMTH_NF 	          15:1 - 15:,
					SCOENDMTH_NF 	          16:1 - 16:,
					CLM_NF 				          17:1 - 17:,
					CUR_CF 				          18:1 - 18:,
					AMT_M 					        19:1 - 19: EN 15/3,
					CED_NF 				          20:1 - 20:,
					BRK_NF 				          21:1 - 21:,
					PAY_NF 				          22:1 - 22:,
					KEY_NF 				          23:1 - 23:,
					RETCTR_NF 			        24:1 - 24:,
					RETEND_NT 			        25:1 - 25:,
					RETSEC_NF 			        26:1 - 26:,
					RETRTY_NF 				      27:1 - 27:,
					RETUW_NT 			          28:1 - 28:,
					RETOCCYEA_NF 	          29:1 - 29:,
					RETACY_NF 			        30:1 - 30:,
					RETSCOSTRMTH_NF         31:1 - 31:,
					RETSCOENDMTH_NF         32:1 - 32:,
					RCL_NF 				          33:1 - 33:,
					RETCUR_CF 			        34:1 - 34:,
					RETAMT_M 			          35:1 - 35: EN 15/3,
					PLC_NT_F2               36:1 - 36 :,
          RTO_NF 									37:1 - 37:,
          INT_NF 									38:1 - 38:,
          RETPAY_NF 							39:1 - 39:,
          RETKEY_CF 							40:1 - 40:,
          RETINTAMT_M 						41:1 - 41:EN 15/3,			
         	FILLER_14_COLS 					42:1 - 55:,
        	TRN_NT 									56:1 - 56:,
        	FILLER_1_COLS 					57:1 - 57:,
        	RETROAUTO_B 						58:1 - 58:,
        	FILLER_13_COLS 					59:1 - 71:,
        	LOFACTOR      					72:1 - 72: EN 15/3        	
/KEYS 		RETCTR_NF,
      		RETEND_NT,
      		RETSEC_NF,
      		RETRTY_NF,
      		RETUW_NT,
      		PLC_NT_F2,
      		RETCUR_CF,
      		TRNCOD_CF,    		 
					LOFACTOR
/OUTFILE ${SORT_O}
exit
EOF
SORT

                   

# [002] APPLYING LORETROFACTOR TO EPO_DLSGTAR_I17_STD

NSTEP=${NJOB}_90I
# Begin C program
#-----------------------------------------------------------------------------
LIBEL="Applying Lofacactor STD to DLSGTAR_I17_STD..."
PRG=ESTC2308  
FPRM=`CFTMP`
INPUT_TEXT ${FPRM} << EOF
CLODAT_D ${CLODAT_D}
exit
EOF
export ${PRG}_PRM=${FPRM}
export ${PRG}_I1=${DFILT}/${NJOB}_80I_${IB}_SORT_DLSGTAR_I17_STD_FACTOR_O.dat
export ${PRG}_I2=${EPO_FBOPRSLNK}
export ${PRG}_O1=${DFILT}/${NSTEP}_${IB}_${PRG}_DLSGTAR_I17_STD_FACTOR_O.dat
#export ${PRG}_O1="${ESF_DLSGTAR_STD} OVERWRITE"
EXECPRG


NSTEP=${NJOB}_100I
LIBEL="Generate  DLREGTR_I17_STD FROM --> DLREGTAR_I17_STD..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_90I_${IB}_ESTC2308_DLSGTAR_I17_STD_FACTOR_O.dat 500 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_ESTC2308_DLSGTR_I17_STD_FACTOR_O.dat 500 1"	
##SORT_I="${ESF_DLSGTAR_STD} 500 1"
##SORT_O="${ESF_DLSGTR_STD} 500 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CHAMPS_1A7 1:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        CHAMPS_8A18_VIDE 8:1 - 18:,        
        AMT_M 19:1 - 19: EN 15/3,
        CHAMPS_20A23_VIDE 20:1 - 23:,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        CHAMPS_37A40 37:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        CHAMPS_42A57 42:1 - 57:,        
        RETROAUTO_B 58:1 - 58:,
        CHAMPS_59A72 59:1 - 72:
/KEYS   
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRNCOD_CF,
        RETROAUTO_B
/SUMMARIZE  TOTAL RETAMT_M, TOTAL RETINTAMT_M
/DERIVEDFIELD RETAMT_MC RETAMT_M COMPRESS
/DERIVEDFIELD RETINTAMT_MC RETINTAMT_M COMPRESS
/DERIVEDFIELD AMT_MC 0
/DERIVEDFIELD CHAMPS_20A23_VIDE_NEW 5"~"
/DERIVEDFIELD CHAMPS_8A18_VIDE_NEW 11"~"
/OUTFILE ${SORT_O}
/REFORMAT 
      CHAMPS_1A7, 
      CHAMPS_8A18_VIDE_NEW, 
      AMT_MC, 
      CHAMPS_20A23_VIDE_NEW, 
			RETCTR_NF, 
			RETEND_NT,
			RETSEC_NF,
			RTY_NF,
			RETUW_NT,
			RETOCCYEA_NF,
			RETACY_NF,
			RETSCOSTRMTH_NF,
			RETSCOENDMTH_NF,
			RCL_NF,
			RETCUR_CF,
			RETAMT_MC,
			PLC_NT,
			CHAMPS_37A40,
			RETINTAMT_MC,
			CHAMPS_42A57,
			RETROAUTO_B,
			CHAMPS_59A72
exit
EOF
SORT


#[003] Generation du DLREGTR à partir du DLSGTR_INI et du DLSGTR_STD

NSTEP=${NJOB}_110I
LIBEL="Generate  EPO_DLSGTR  FROM --> DLSGTR_I17_INI AND DLSGTR_I17_STD e..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLSGTR_INI} 500 1"
SORT_I2="${DFILT}/${NJOB}_100I_${IB}_ESTC2308_DLSGTR_I17_STD_FACTOR_O.dat 500 1"   
SORT_O="${EPO_DLSGTR}"	
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CHAMPS_1A7 1:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        CHAMPS_8A18_VIDE 8:1 - 18:,        
        AMT_M 19:1 - 19: EN 15/3,
        CHAMPS_20A23_VIDE 20:1 - 23:,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        CHAMPS_37A40 37:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
			  CHAMPS_42A57 42:1 - 57:,
        RETROAUTO_B 58:1 - 58:,
        CHAMPS_59A72 59:1 - 72:
/KEYS   
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRNCOD_CF,
        RETROAUTO_B
/OUTFILE ${SORT_O}
exit
EOF
SORT



#[003] Generation du DLREGTAR à partir du DLSGTAR_INI et du DLSGTAR_STD

NSTEP=${NJOB}_125I
LIBEL="Generate  EPO_DLSGTAR  FROM --> DLSGTR_I17_INI AND DLSGTR_I17_STD e..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${ESF_DLSGTAR_INI} 500 1"
SORT_I2="${DFILT}/${NJOB}_90I_${IB}_ESTC2308_DLSGTAR_I17_STD_FACTOR_O.dat 500 1" 
SORT_O="${EPO_DLSGTAR}"	
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS SSD_CF 1:1 - 1:,
        ESB_CF 2:1 - 2:,
        BALSHEY_NF 3:1 - 3:,
        BALSHRMTH_NF 4:1 - 4:,
        BALSHRDAY_NF 5:1 - 5:,
        TRNCOD_CF 6:1 - 6:,
        DBLTRNCOD_CF 7:1 - 7: ,
        CHAMPS_1A7 1:1 - 7:,
        CTR_NF 8:1 - 8:,
        END_NT 9:1 - 9:,
        SEC_NF 10:1 - 10:,
        UWY_NF 11:1 - 11: ,
        UW_NT 12:1 - 12:,
        OCCYEA_NF 13:1 - 13:,
        ACY_NF 14:1 - 14:,
        SCOSTRMTH_NF 15:1 - 15:,
        SCOENDMTH_NF 16:1 - 16:,
        CLM_NF 17:1 - 17:,
        CUR_CF 18:1 - 18:,
        CHAMPS_8A18_VIDE 8:1 - 18:,        
        AMT_M 19:1 - 19: EN 15/3,
        CHAMPS_20A23_VIDE 20:1 - 23:,
        CED_NF 20:1 - 20:,
        BRK_NF 21:1 - 21:,
        PAY_NF 22:1 - 22:,
        KEY_NF 23:1 - 23:,
        RETCTR_NF 24:1 - 24:,
        RETEND_NT 25:1 - 25:,
        RETSEC_NF 26:1 - 26:,
        RTY_NF 27:1 - 27:,
        RETUW_NT 28:1 - 28:,
        RETOCCYEA_NF 29:1 - 29:,
        RETACY_NF 30:1 - 30:,
        RETSCOSTRMTH_NF 31:1 - 31:,
        RETSCOENDMTH_NF 32:1 - 32:,
        RCL_NF 33:1 - 33:,
        RETCUR_CF 34:1 - 34:,
        RETAMT_M 35:1 - 35:EN 15/3,
        PLC_NT 36:1 - 36:EN 15/3,
        CHAMPS_37A40 37:1 - 40:,
        RETINTAMT_M 41:1 - 41:EN 15/3,
        TRN_NT 56:1 - 56:,
        RETROAUTO_B 58:1 - 58:,
        CHAMPS_59A72 59:1 - 74:
/KEYS   
        RETCTR_NF,
        RETEND_NT,
        RETSEC_NF,
        RTY_NF,
        RETUW_NT,
        RETOCCYEA_NF,
        RETACY_NF,
        RETSCOSTRMTH_NF,
        RETSCOENDMTH_NF,
        RCL_NF,
        RETCUR_CF,
        PLC_NT,
        TRNCOD_CF,
        TRN_NT,
        RETROAUTO_B
/OUTFILE ${SORT_O}
exit
EOF
SORT


fi

########################################################################################
##                    FIN TRT   IFRS17 INCEPTION et STANDARD                         ###
########################################################################################

# [003] fin modif


JOBEND

