#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - INVENTAIRE
#              			        : Fusion des fichiers FTECLEDA_CUR et _MVT dans FTECLEDA
# nom du script SHELL           : ESID8701.cmd
# revision                      : 
# date de creation              : 15/03/2011
# auteur                        : R. Cassis
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#  :spot:21408 - Fusion des fichiers FTECLEDA_CUR et FTECLEDA_MVT dans FTECLEDA final
#
#-----------------------------------------------------------------------------
# historiques des modifications
#[001]  08/09/2011  Roger Cassis   :spot:22435 - Suppression du step de delete du FTECLEDA_CUR.
#[002]  30/06/2015  DFI            :spot:28947 - filtre des analytiques dans la generation de l'interface 1GL
#[003]	07/09/2016	MMA			   :SPOT:31161 - SPIRA 53727 & 53733 : Verification des Poste analytique afin de les écarter
#[004]	19/08/2019	M.NAJI  	   :SPIRA ??? : optimisation changer les fichier binaire par des fichiers textes
#[005] 30/10/2019 M. NAJI       :spot:81838 - ajout d'un filtre sur les LOB 30 et 31 pour avoir que du PC dans FTECLEDA et FTECLEDR dans la branche PC
#[006] 16/06/2022 JYP/Flo       :spira:104337 - update ESB for retro 
#[007] 03/10/2022 JYP/Flo       :spira:104337 - update ESB for retro , pericase issue
#[008] 03/11/2022 MZM/JYP       :SPIRA 107336: optimisation rename DFILT file ".dat" for zipping
#[009] 17/11/2022 JYP/Flo/TD    :spira:104337 - REVERT update ESB, should NOT impact I4I
#======================================================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd
. ${DUTI}/fctprint.cmd

# No input parameters

# Job Initialisation
JOBINIT


EST_FTECLED_CUR=$1
EST_FTECLED_MVT=$2
EST_FTECLED_MTH=$3
EST_FTECLED_REP=$4
EST_FTECLED=$5
NB_COLS=$6


ECHO_LOG "#===> EST_FTECLED_CUR ................ ${EST_FTECLED_CUR}"
ECHO_LOG "#===> EST_FTECLED_MVT ................ ${EST_FTECLED_MVT}"
ECHO_LOG "#===> EST_FTECLED_MTH ................ ${EST_FTECLED_MTH}"
ECHO_LOG "#===> EST_FTECLED_REP ................ ${EST_FTECLED_REP}"
ECHO_LOG "#===> EST_FTECLED .................... ${EST_FTECLEDA}"
ECHO_LOG "#===> EST_SUBTRSESBPROP_TXT .......... ${EST_SUBTRSESBPROP_TXT}"
ECHO_LOG "#===> EST_SUBTRS_TXT ................. ${EST_SUBTRS_TXT}"
ECHO_LOG "#===> EST_FTECLEDR_CUR ............... ${EST_FTECLEDR_CUR}"
ECHO_LOG "#===> EST_FTECLEDR_MVT ............... ${EST_FTECLEDR_MVT}"
ECHO_LOG "#===> EST_OIADVPERICASE .............. ${EST_OIADVPERICASE}"
ECHO_LOG "#===> NB_COLS           .............. ${NB_COLS}"






NSTEP=${NJOB}_05
# Merge FTECLEDA_CUR and FTECLEDA_MVT and extend whith SUBTRS_CF
#--------------------------------
LIBEL="Merge FTECLED_CUR and FTECLED_MVT and extend whith SUBTRS_CF"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_SUBTRS_TXT} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_SUBTRS_SUBTRSEBSPROP.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	 PCPTRS_CF 1:1 - 1:
    ,TRS_CF 2:1 - 2:
    ,SUBTRS_CF 3:1 - 3:
	,SUBTRS_TRSNATURE_CT 10:1 - 10:
	,SUBTRSESBPROP_PCPTRS_CF 1:1 - 1:
    ,SUBTRSESBPROP_TRS_CF 2:1 - 2:
    ,SUBTRSESBPROP_SUBTRS_CF 3:1 - 3:
	,SUBTRSESBPROP_SSD_CF 4:1 - 4:
	,SUBTRSESBPROP_ESB_CF 5:1 - 5:
	,SUBTRSESBPROP_GLTFEEDING_B 6:1 - 6:
/joinkeys 
	 PCPTRS_CF
    ,TRS_CF
    ,SUBTRS_CF
/INFILE ${EST_SUBTRSESBPROP_TXT}  1000 1 "~"
/joinkeys 
     PCPTRS_CF
    ,TRS_CF 
    ,SUBTRS_CF
/JOIN UNPAIRED  
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside:PCPTRS_CF
    ,leftside:TRS_CF
    ,leftside:SUBTRS_CF
	,rightside:SUBTRSESBPROP_SSD_CF
	,rightside:SUBTRSESBPROP_ESB_CF
	,leftside:SUBTRS_TRSNATURE_CT
	,rightside:SUBTRSESBPROP_GLTFEEDING_B
exit
EOF
SORT


NSTEP=${NJOB}_10
# Extend FTECLEDA whith TRSNATURE and GLTFEEDING_B
#--------------------------------
LIBEL="Extend  FTECLEDA whith TRSNATURE and GLTFEEDING_B"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${EST_FTECLED_CUR} 1000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_SORT_FTECLED_SUBTRS_SUBTRSEBSPROP.dat 1000 1"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS 
	SSD_CF 1:1 - 1:
	,ESB_CF 2:1 - 2:
	,DBLTRNCOD_CF 7:1 - 7:
	,DBLTRNCOD_CF_34 7:3 - 7:4
	,DBLTRNCOD_CF_5 7:5 - 7:5
	,DBLTRNCOD_CF_67 7:6 - 7:7
	,all_cols_TECLEDA	    1:1 - ${NB_COLS}:
	,SUBTRS_SUBTRSEBSPROP_PCPTRS_CF 1:1 - 1:
    ,SUBTRS_SUBTRSEBSPROP_TRS_CF 2:1 - 2:
    ,SUBTRS_SUBTRSEBSPROP_SUBTRS_CF 3:1 - 3:
	,SUBTRS_SUBTRSEBSPROP_SSD_CF  4:1 - 4:
	,SUBTRS_SUBTRSEBSPROP_ESB_CF 5:1 - 5:
	,SUBTRS_SUBTRSEBSPROP_TRSNATURE_CT 6:1 - 6:
	,SUBTRS_SUBTRSEBSPROP_GLTFEEDING_B 7:1 - 7:
/INFILE ${EST_FTECLED_MVT} 1000 1 "~"
/INFILE ${EST_FTECLED_MTH} 1000 1 "~"
/INFILE ${EST_FTECLED_REP} 1000 1 "~"
/joinkeys 
	DBLTRNCOD_CF_34,
	DBLTRNCOD_CF_5 ,
	DBLTRNCOD_CF_67,
	SSD_CF,
	ESB_CF
/INFILE ${DFILT}/${NJOB}_05_${IB}_SORT_SUBTRS_SUBTRSEBSPROP.dat   1000 1 "~"
/joinkeys 
     SUBTRS_SUBTRSEBSPROP_PCPTRS_CF
    ,SUBTRS_SUBTRSEBSPROP_TRS_CF 
    ,SUBTRS_SUBTRSEBSPROP_SUBTRS_CF
	,SUBTRS_SUBTRSEBSPROP_SSD_CF
	,SUBTRS_SUBTRSEBSPROP_ESB_CF
/JOIN UNPAIRED LEFTSIDE 
/OUTFILE ${SORT_O}
/REFORMAT 
	 leftside:all_cols_TECLEDA          
	,rightside:SUBTRS_SUBTRSEBSPROP_TRSNATURE_CT 
	,rightside:SUBTRS_SUBTRSEBSPROP_GLTFEEDING_B 
exit
EOF
SORT




NSTEP=${NJOB}_20
#-----------------------------------------------------------------------------
LIBEL="Create ${EST_FTECLED}"
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_10_${IB}_SORT_FTECLED_SUBTRS_SUBTRSEBSPROP.dat 1000 1"
SORT_O="${EST_FTECLED}"
SORT_O2=${DFILT}/${NSTEP}_${IB}_TECLED_03_ERR.dat
INPUT_TEXT ${SORT_CMD} << EOF
/FIELDS 	
	 LOBACC_CF	45:1 	- 45: 
	,LOBRET_CF	46:1	-	46:
	,SUBTRS_TRSNATURE_CT 119:1 - 119:
	,SUBTRSESBPROP_GLTFEEDING_B 120:1 - 120:
	,all_cols_TECLEDA   1:1 - ${NB_COLS}:
/CONDITION COND_NOT_WRITE_TECLED 	(SUBTRS_TRSNATURE_CT != "2" or SUBTRSESBPROP_GLTFEEDING_B != "0" ) AND 
					( "${IDF_CT}" !=  "I4_PC___"  OR
					  ( "${IDF_CT}" = "I4_PC___"  AND  LOBRET_CF != '30' and  LOBRET_CF !='31' and LOBACC_CF != '30' and  LOBACC_CF !='31' )
					)

/OUTFILE ${SORT_O}
/INCLUDE COND_NOT_WRITE_TECLED
/REFORMAT all_cols_TECLEDA
/OUTFILE ${SORT_O2}
/OMIT COND_NOT_WRITE_TECLED
exit
EOF
SORT

# COND_WRITE_TECLEDA : old code ESTC8701.c
#	 //si il existe un paramétrage 
#    if ( result_subtrs != (-1))
#    {
#        //si c'est un poste analytique
#        if ( SubTrsLigne.TRSNATURE_CT == 2 )
#        {
#            //pour le poste/Filiale/Etablissement on vérifie le paramémetrage d'alimentation du GLT
#            result_bprop = n_RechSUBTRSESBPROP(&SubTrsEsBprop, c_dettrncod, ptb_InRec_Cur[GT_SSD_CF], ptb_InRec_Cur[GT_ESB_CF]);
#            if (result_bprop !=(-1))
#            {
#                if ( SubTrsEsBprop.GLTFEEDING_B != 0 )
#                    n_WriteCols(Kp_TecledaOFil,ptb_InRec_Cur,SEPARATEUR,0);
#                else
#                    n_WriteCols(Kp_TecledaErrFil,ptb_InRec_Cur,SEPARATEUR,0);
#            }
#            else
#                n_WriteCols(Kp_TecledaOFil,ptb_InRec_Cur,SEPARATEUR,0);
#        }
#        else 
#            n_WriteCols(Kp_TecledaOFil,ptb_InRec_Cur,SEPARATEUR,0);
#    }
#    else
#        n_WriteCols(Kp_TecledaOFil,ptb_InRec_Cur,SEPARATEUR,0);
#
#    RETURN_VAL (0);



JOBEND

