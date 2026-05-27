#!/bin/ksh
#=============================================================================
# Nom de l'application          : ESTIMATIONS - INVENTAIRE
#                                 EBS : Spira 88638
# Revision                      : $Revision:   1.0  $
# Date de creation              : 06/10/2020
# Auteur                        : Linh.DOAN
# References des specifications :
#----------------------------------------------------------------------------------------------------
# Historique des modifications
#====================================================================================================
# 	<indice>	<jj/mm/aaaa>   	<auteur>   	<spira> 		<description de la modification>
#       [001]           06/10/2020      L.DOAN         SPIRA : 88638  		SAP feedback 
#       [002]           25/02/2022      M.NAJI         SPIRA : 96405 et 96768   commenter touch EPO_FTECLEDA_RMN
#       [003]           28/03/2022      MZM            SPIRA : 103324  Ajout Fichiers des OPNG et Annulations
#       [004]           08/30/2022      JBD            SPIRA : 105393  O2/SAP remove 900-100
#====================================================================================================
#set -x


# Call generic functions
. ${DUTI}/fctgen.cmd


#CLODAT_D=${PARM_ICLODAT_D}
CLODAT_D=${PARM_CRE_D}

# Job Initialisation
JOBINIT




#EPO_FTECLEDA_MVT="${DFILP}/${ENV_PREFIX}_ESPD3960_FTECLEDA_EBS_MVT_${PARM_ICLODAT_D}.dat"
#EPO_FTECLEDA_RMN="${DFILP}/${ENV_PREFIX}_ESPD3910_FTECLEDA_EBS_RMN_${PARM_ICLODAT_D}.dat"
#EPO_FTECLEDA="${DFILP}/${ENV_PREFIX}_ESPD3970_FTECLEDA${TYPEINV0}_EBS_${PARM_ICLODAT_D}.dat"

NSTEP=${NJOB}_01
#------------------------------------------------------------------------------------
LIBEL="MANAGE UNFOUND FILES "

if [ ! -f ${EPO_FTECLEDA_MVT} ]
then
        ECHO_LOG "EPO_FTECLEDA_MVT=${EPO_FTECLEDA_MVT}  does not exist, take an empty file" >> $FLOG
        EXECKSH "touch ${EPO_FTECLEDA_MVT}"

fi

if [ ! -f ${ESF_FTECLEDR} ]                                                                           
then                                                                                                      
        ECHO_LOG "ESF_FTECLEDR=${ESF_FTECLEDR}  does not exist, take an empty file" >> $FLOG      
        EXECKSH "touch ${ESF_FTECLEDR}"                                                               
                                                                                                          
fi 

if [ ! -f ${ESF_FTECLEDR_REJ} ]                                                                           
then                                                                                                      
        ECHO_LOG "ESF_FTECLEDR_REJ=${ESF_FTECLEDR_REJ}  does not exist, take an empty file" >> $FLOG      
        EXECKSH "touch ${ESF_FTECLEDR_REJ}"                                                               
                                                                                                          
fi

if [ ! -f ${ESF_OPNG_EBS_RET} ]                                                                           
then                                                                                                      
        ECHO_LOG "ESF_OPNG_EBS_RET=${ESF_OPNG_EBS_RET}  does not exist, take an empty file" >> $FLOG      
        EXECKSH "touch ${ESF_OPNG_EBS_RET}"                                                               
                                                                                                          
fi                                                                                                       


#if [ ! -f ${EPO_FTECLEDA_RMN} ]
#then
#        ECHO_LOG "EPO_FTECLEDA_RMN=${EPO_FTECLEDA_RMN}  does not exist, take an empty file" >> $FLOG
#        EXECKSH "touch ${EPO_FTECLEDA_RMN}"
#
#fi

NSTEP=${NJOB}_10
#------------------------------------------------------------------------------------
LIBEL="Merge MVT and RMN"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EPO_FTECLEDA_MVT} 2000 1"
SORT_I2="${EPO_FTECLEDA_RMN} 2000 1"
SORT_O="${EPO_FTECLEDA} 2000 1"

INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS CTR_NF            8:1 -  8:,
        END_NT            9:1 -  9:EN,
        SEC_NF           10:1 - 10:EN,
        UWY_NF           11:1 - 11:,
        UW_NT            12:1 - 12:EN
/KEYS   CTR_NF,
        END_NT,
        SEC_NF,
        UWY_NF,
        UW_NT
/COPY
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

#[004]
if [  ${NORME_CF} = "EBS" ]
then
# [002]
NSTEP=${NJOB}_20
#------------------------------------------------------------------------------------
LIBEL="Merge ESF_FTECLEDR OPNG AND REJ"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`                                                              
SORT_I="${ESF_FTECLEDR} 2000 1"                                                   
SORT_I2="${ESF_FTECLEDR_REJ} 2000 1"                                                  
SORT_I3="${ESF_OPNG_EBS_RET} 2000 1"                                                  
SORT_O="${ESF_FTECLEDR_MRG} 2000 1"

INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
	SSD_CF            1:1 -  1:EN,
	ESB_CF            2:1 -  2:EN,
	BALSHEY_NF        3:1 -  3:EN,
	BALSHRMTH_NF      4:1 -  4:EN,
	TRNCOD_CF         6:1 -  6:,
	DBLTRNCOD_CF      7:1 -  7:,
	CTR_NF            8:1 -   8:,
	END_NT            9:1 -   9:,
	SEC_NF           10:1 -  10:,
	UWY_NF           11:1 -  11:,
	UW_NT            12:1 -  12:,
	OCCYEA_NF        13:1 -  13:EN,
	ACY_NF           14:1 -  14:EN,
	SCOSTRMTH_NF     15:1 -  15:EN,
	SCOENDMTH_NF     16:1 -  16:EN,
	CUR_CF           18:1 -  18:,
	CED_NF           20:1 -  20:,
	RETCTR_NF        24:1 - 24:,
	RETEND_NT        25:1 - 25:,
	RETSEC_NF        26:1 - 26:,
	RTY_NF           27:1 - 27:,
	RETUW_NT         28:1 - 28:,
	RETOCCYEA_NF     29:1 - 29:EN,
	RETACY_NF        30:1 - 30:EN,
	RETSCOSTRMTH_NF  31:1 - 31:EN,
	RETSCOENDMTH_NF  32:1 - 32:EN,
	RETCUR_CF        34:1 - 34:,
	RETAMT_M         35:1 - 35:EN 18/3,
	PLC_NT           36:1 - 36:,
	RTO_NF           37:1 - 37:,
	TRN_NT           56:1 - 56:,
	ORICOD_LS        57:1 - 57:,
	RETROAUTO_B      58:1 - 58:,
	SPEENTNAT_CT     59:1 - 59:,
	EVT_NF           60:1 - 60:,
	REVT_NF          61:1 - 61:,
	RETARDRETINT_B   62:1 - 62:
/KEYS
	SSD_CF,
	ESB_CF,
	BALSHEY_NF,
	BALSHRMTH_NF,
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
	CUR_CF,
	CED_NF,
	RETCTR_NF,
	RETEND_NT,
	RETSEC_NF,
	RTY_NF,
	RETUW_NT,
	RETOCCYEA_NF,
	RETACY_NF,
	RETSCOSTRMTH_NF,
	RETSCOENDMTH_NF,
	RETCUR_CF,
	PLC_NT,
	RTO_NF,
	TRN_NT,
	RETROAUTO_B,
	SPEENTNAT_CT,
	EVT_NF,
	REVT_NF,
	RETARDRETINT_B
/COPY
/OUTFILE ${SORT_O} OVERWRITE
exit
EOF
SORT

fi

JOBEND
