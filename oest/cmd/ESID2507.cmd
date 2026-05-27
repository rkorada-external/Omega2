#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATES - Internal retrocession
# nom du script SHELL           : ESID2507.cmd
# revision                      : $Revision:  
# date de creation              : 12/02/2020
# auteur                        : MZM
#-----------------------------------------------------------------------------
# Description :
#  Split and send acceptance DLEIFTECLEDSII to retrocessionnaire subsidiaries
#
# job launched by ESID2550.cmd
#-----------------------------------------------------------------------------
# historiques des modifications
#[001] 12/02/2020 MZM :spira:71539 OVERRIDES COMMISSIONS Merge des fichiers  EST_DLREGTAR EST_DLREGTAR_OVR
#[002] 25/03/2020 MZM :spira 85634 PROD- No casflow on future override commission
#[003] 25/03/2020 MZM :spira:79070 APPLYING LORETROFACTOR TO EST_DLREGTAR And EST_DLREGTR
#[004] 24/06/2020 MZM :spira:79070 Probleme de tri des fichiers DLGTAR et DLGTR
#[005] 24/08/2020 MZM :spira:88354 IFRS 17 - REQ 11.07 - REtro ONE GAIN AND RETRO ONE GAIN REV
#[006] 22/09/2020 MZM :spira:90105 IFRS 17 - LO FACTOR - I17 - LO Factor - Not applied to Future positions - Tri des fichiers joints sur cle Retro Assume CSUE/LOFACTOR
#[007] 22/12/2020 : M.NAJI   :. SPIRA 91531 
#						 	 . Remplacement du mapping en dur par un mapping directement dans la table BES..TI17PERMFIL
#[008] 01/02/2021 JYP :spira:88354/91991: I17L/P should be as I17G 
#[009] 09/04/2021 MZM :spira9:92736 Utilisation du FBOPRSLNK la place du FTRSLNK
#[010] 10/06/2021 MZM :spira9:96997 TNR EBS INT Utilisation du FBOPRSLNK la place du FTRSLNK ; 
#                                   Generation du DLGTR A partir du DLGTAR Avec Application du LOFACTOR
#[011] 14/06/2021 MZM :spira:94899: IDF_CT I17(GPL)_NDC_RPO_INI Correction champ RETINT_M au step 20
#[011] 08/07/2021 MZM :spira:96997: Ajout d'une double cote fermante au step 125 
#[012] 08/09/2021 MZM :spira:98725: ANO PRD Ne pas executer step 127 Si I4I
#[013] 09/12/2021 MZM :spira:97734: DESACTIVATION LOFACTOR CAR DEPLACE DANS ESID2504
#[014] 27/12/2021 MZM :spira:101350: DESACTIVATION du "Retro Day One Gain REV    49501"
#[015] 04/07/2022 JBD :SPIRA:104778:  Build new closing for I17S norm 
#[016] 12/01/2023 HR  :SPIRA:106770: I17G - Internal assumed initial amounts to be aligned with internal retro initial amounts
#[017] 10/02/2023 HR  :SPIRA:108037: FRS17 simulation - Build new closing for I17S norm - Copy - Copy 
#[018] 21/06/2023 MZM :Spira:109430 [I17 Prod] - IO - Missing Future closing positions on Internal Assumed from Dummies :Extention aux postes Futures de la FD     
#===============================================================================
#set -x

# Call generic functions
. ${DUTI}/fctgen.cmd

# Get parameters
BALSHTYEA_NF=$1
CLODAT_D=$2
TYPEINV=$3
NORME=$4

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
#			EST_DLREGTAR=${EPO_DLREGTARSIISO}
#			EST_DLREGTAR_OVR=${EPO_DLREGTAR_OVRSIISO}
#			EST_DLREGTR=${EPO_DLREGTRSIISO}
#			EST_DLREGTR_OVR=${EPO_DLREGTR_OVRSIISO}	
#			EST_DLREGTAR_TCODINI=${EPO_DLREGTAR_TCODINISIISO}	
#			EST_DLREGTR_TCODINI=${EPO_DLREGTR_TCODINISIISO}								
#		else
#			EST_DLREGTAR=${EPO_DLREGTARSO}
#			EST_DLREGTAR_OVR=${EPO_DLREGTAR_OVRSO}
#			EST_DLREGTR=${EPO_DLREGTRSO}
#			EST_DLREGTR_OVR=${EPO_DLREGTR_OVRSO}	
#			EST_DLREGTAR_TCODINI=${EPO_DLREGTAR_TCODINISO}
#			EST_DLREGTR_TCODINI=${EPO_DLREGTR_TCODINISO}								
#		fi
#	else
#		if [ "${NORME}" = "EBS" ]
#		then
#			EST_DLREGTAR=${EPO_DLREGTARSIICO}
#			EST_DLREGTAR_OVR=${EPO_DLREGTAR_OVRSIICO}
#			EST_DLREGTR_TCODINI=${EPO_DLREGTRSIICO}
#			EST_DLREGTR_OVR=${EPO_DLREGTR_OVRSIICO}	
#			EST_DLREGTR_TCODINI=${EPO_DLREGTR_TCODINISIICO}
#			EST_DLREGTAR_TCODINI=${EPO_DLREGTAR_TCODINISIICO}								
#		else
#			EST_DLREGTAR=${EPO_DLREGTARCO}
#			EST_DLREGTAR_OVR=${EPO_DLREGTAR_OVRCO}
#			EST_DLREGTR=${EPO_DLREGTRCO}
#			EST_DLREGTR_OVR=${EPO_DLREGTR_OVRCO}
#			EST_DLREGTR_TCODINI=${EPO_DLREGTR_TCODINICO}
#			EST_DLREGTAR_TCODINI=${EPO_DLREGTAR_TCODINICO}									
#		fi
#	fi
#fi

if [ ! -f ${EST_DLREGTAR_OVR} ]
then
	touch ${EST_DLREGTAR_OVR}
fi

if [ ! -f ${EST_DLREGTAR} ]
then
	touch ${EST_DLREGTAR}
fi

if [ ! -f ${EST_DLREGTR_TCODINI_OVR} ]
then
	touch ${EST_DLREGTR_OVR}
fi

if [ ! -f ${EST_DLREGTR} ]
then
	touch ${EST_DLREGTR}
fi

if [ ! -f ${ESF_FLORETFACTOR} ]
then
	touch ${ESF_FLORETFACTOR}
fi

if [ ! -f ${EST_DLREGTAR_TCODINI} ]
then
	touch ${EST_DLREGTAR_TCODINI}
fi

if [ ! -f ${EST_DLREGTR_TCODINI} ]
then
	touch ${EST_DLREGTR_TCODINI}
fi


ECHO_LOG ""
ECHO_LOG "#========================================================================="
ECHO_LOG "#===> TYPEINV................: ${TYPEINV}"
ECHO_LOG "#===> NORME..................: ${NORME}"
ECHO_LOG "#===> NORME_CF...............: ${NORME_CF}"
ECHO_LOG "#===> IDF_CT.................: ${IDF_CT}"
ECHO_LOG "#===> EST_DLREGTAR_OVR.......: ${EST_DLREGTAR_OVR}"
ECHO_LOG "#===> EST_DLREGTAR...........: ${EST_DLREGTAR}"
ECHO_LOG "#===> EST_DLREGTR_OVR........: ${EST_DLREGTR_OVR}"
ECHO_LOG "#===> EST_DLREGTR............: ${EST_DLREGTR}"
ECHO_LOG "#===> ESF_FLORETFACTOR.......: ${ESF_FLORETFACTOR}"
ECHO_LOG "#===> EST_DLREGTR_TCODINI....: ${EST_DLREGTR_TCODINI}
ECHO_LOG "#===> EST_DLREGTAR_TCODINI...: ${EST_DLREGTAR_TCODINI}
ECHO_LOG "#========================================================================="


#[016] I17G_LCC_RPO_INI [017] [018]

if [ "${IDF_CT}" = "I17G_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17S_LCC_RPO_INI" ]  || [ "${IDF_CT}" = "I17L_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17P_LCC_RPO_INI" ]  
then

NSTEP=${NJOB}_02
#-----------------------------------------------------------------------------
LIBEL="Sorting new cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLREGTAR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_I17G_LCC_RPO_INI_DLREGTARSII_INI_FILTERED.dat OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD5_CF 6:3 - 6:7
/CONDITION COND ( TRNCOD5_CF = "10061" OR TRNCOD5_CF = "10062" OR TRNCOD5_CF = "12061" OR TRNCOD5_CF = "12062" OR TRNCOD5_CF = "12063" OR TRNCOD5_CF = "14061" OR TRNCOD5_CF = "49461" OR TRNCOD5_CF = "49462" OR TRNCOD5_CF = "49500" OR TRNCOD5_CF = "12161"  OR TRNCOD5_CF = "43014" OR TRNCOD5_CF = "43024" OR TRNCOD5_CF = "43034")
/OUTFILE ${SORT_O}
/INCLUDE COND
exit
EOF
SORT

NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort and Merge files DLREGTAR_OVR and DLREGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLREGTAR_OVR} 1000 1"
SORT_I2="${DFILT}/${NJOB}_02_${IB}_I17G_LCC_RPO_INI_DLREGTARSII_INI_FILTERED.dat  1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTAR_O.dat OVERWRITE"
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

else

NSTEP=${NJOB}_05
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort and Merge files DLREGTAR_OVR and DLREGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLREGTAR_OVR} 1000 1"
SORT_I2="${EST_DLREGTAR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTAR_O.dat OVERWRITE"
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

fi


#[016] I17G_LCC_RPO_INI
if [ "${IDF_CT}" = "I17G_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17S_LCC_RPO_INI" ]  || [ "${IDF_CT}" = "I17L_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17P_LCC_RPO_INI" ]  
then

NSTEP=${NJOB}_18
#-----------------------------------------------------------------------------
LIBEL="Sorting new cession file..."
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLREGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_I17G_LCC_RPO_INI_DLREGTRSII_INI_FILTERED.dat OVERWRITE"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS TRNCOD5_CF 6:3 - 6:7
/CONDITION COND ( TRNCOD5_CF = "10061" OR TRNCOD5_CF = "10062" OR TRNCOD5_CF = "12061" OR TRNCOD5_CF = "12062" OR TRNCOD5_CF = "12063" OR TRNCOD5_CF = "14061" OR TRNCOD5_CF = "49461" OR TRNCOD5_CF = "49462" OR TRNCOD5_CF = "49500" OR TRNCOD5_CF = "12161"  OR TRNCOD5_CF = "43014" OR TRNCOD5_CF = "43024" OR TRNCOD5_CF = "43034")
/OUTFILE ${SORT_O}
/INCLUDE COND
exit
EOF
SORT


#[011]

NSTEP=${NJOB}_20
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort and Merge files DLREGTAR_OVR and DLREGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLREGTR_OVR} 1000 1"
SORT_I2="${DFILT}/${NJOB}_18_${IB}_I17G_LCC_RPO_INI_DLREGTRSII_INI_FILTERED.dat"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTR_O.dat OVERWRITE"
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

else

#[011]

NSTEP=${NJOB}_20
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort and Merge files DLREGTAR_OVR and DLREGTAR"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_DLREGTR_OVR} 1000 1"
SORT_I2="${EST_DLREGTR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTR_O.dat OVERWRITE"
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

fi

# [012] 

if [ ${NORME_CF} != "I4I" ]
then

NSTEP=${NJOB}_40
#LIBEL="Copy De la Fusion --> DLREGTAR et DLREGTR..."
	EXECKSH "cp ${DFILT}/${NJOB}_05_${IB}_SORT_DLREGTAR_O.dat  ${EST_DLREGTAR}"

                       
NSTEP=${NJOB}_50
#LIBEL="Copy De la Fusion --> DLREGTAR et DLREGTR..."
	EXECKSH "cp ${DFILT}/${NJOB}_20_${IB}_SORT_DLREGTR_O.dat  ${EST_DLREGTR}"  	
	
fi

# [010] fin modif


if [ "${IDF_CT}" = "I17G_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17L_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17P_LCC_RPO_INI" ] || [ "${IDF_CT}" = "I17S_LCC_RPO_INI" ] 
then


NSTEP=${NJOB}_60
# #[005] Generate Retro ONE GAIN REV with TRNCOD '2149501X'
#-----------------------------------------------------------------------------
LIBEL=" Generate Retro ONE GAIN REV : '2149500X' --> '2149501X' "  
AWK_I=${DFILT}/${NJOB}_05_${IB}_SORT_DLREGTAR_O.dat 
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLREGTAR.dat
#AWK_O=${EST_DLREGTR_TCODINI}
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

		if (\$6 == "2149500I")	\$6 = "2149501I" ;
		if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
		if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);

    print \$0;
  }
exit
EOF
AWK

#[014] Desactivation du Retro One
### Tri et Fusion des deux fichiers  --> Fichier Retro ONE GAIN Final
NSTEP=${NJOB}_70
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort and Merge files REtro ONE GAIN AND RETRO ONE GAIN REV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_05_${IB}_SORT_DLREGTAR_O.dat 1000 1"
#[014]SORT_I2="${DFILT}/${NJOB}_60_${IB}_AWK_DLREGTAR.dat 1000 1"     # 
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTAR_ONE_O.dat OVERWRITE"
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
        LOFACTOR    72:1 - 72:
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
        RETROAUTO_B,
        LOFACTOR
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_80
# #[005] Generate Retro ONE GAIN REV with TRNCOD '2149501X'
#-----------------------------------------------------------------------------
LIBEL=" Generate Retro ONE GAIN REV : '2149500X' --> '2149501X' "        
AWK_I=${DFILT}/${NJOB}_20_${IB}_SORT_DLREGTR_O.dat       
AWK_O=${DFILT}/${NSTEP}_${IB}_AWK_DLREGTR.dat
AWK_CMD=`CFTMP`
INPUT_TEXT ${AWK_CMD} <<EOF
BEGIN{ FS="\~"; OFS="\~" }
  {

		if (\$6 == "2149500I")	\$6 = "2149501I" ;
		if (\$19  != 0) \$19 = sprintf("%-.3lf",-\$19);
		if (\$35  != 0) \$35 = sprintf("%-.3lf",-\$35);

    print \$0;
  }
exit
EOF
AWK


#[014] Desactivation du Retro One
### Tri et Fusion des deux fichiers  --> Fichier Retro ONE GAIN Final
NSTEP=${NJOB}_90
# Begin sort
#-----------------------------------------------------------------------------
LIBEL="Sort and Merge files REtro ONE GAIN AND RETRO ONE GAIN REV"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_20_${IB}_SORT_DLREGTR_O.dat 1000 1"   
#[014]SORT_I2="${DFILT}/${NJOB}_80_${IB}_AWK_DLREGTR.dat 1000 1"    
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_DLREGTR_ONE_O.dat OVERWRITE"
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
        LOFACTOR    72:1 - 72:
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
        RETROAUTO_B,
        LOFACTOR
/SUMMARIZE  TOTAL AMT_M,
            TOTAL RETAMT_M,
            TOTAL RETINTAMT_M
/OUTFILE ${SORT_O}
exit
EOF
SORT


NSTEP=${NJOB}_100
#LIBEL="Copy De la Fusion --> DLREGTAR et DLREGTR..."
	EXECKSH "cp ${DFILT}/${NJOB}_70_${IB}_SORT_DLREGTAR_ONE_O.dat  ${EST_DLREGTAR}"
	EXECKSH "cp ${DFILT}/${NJOB}_90_${IB}_SORT_DLREGTR_ONE_O.dat  ${EST_DLREGTR}"	

fi # Instance ONE GAIN


JOBEND

