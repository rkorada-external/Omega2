#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS -
# nom du script SHELL           : ESCD9001.cmd
# revision                      : $Revision: 1.44 $
# date de creation              : 26/05/1997
# auteur                        : CGI
# references des specifications :
#-----------------------------------------------------------------------------
# description:
#  links between logical and physical names of permanent files
#-----------------------------------------------------------------------------
# historiques des modifications
#======================================================================================================================
#set -x

if [ "${JOB_NOECHO}" != "YES" ]
then
    echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
    echo '# Begin of initialization job    : ' ${NJOB} " Date : " `date +"%Y/%m/%d %H:%M:%S"`  2>&1 | ${TEE}
    echo "# Main Working Directories :"   2>&1 | ${TEE}
    echo "#   DLOG : " ${DLOG}  2>&1 | ${TEE}
    echo "#   DUTI : " ${DUTI}  2>&1 | ${TEE}
    echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
fi

#Parameters
SSDs0=$1
SSDs=$2
BALSHTYEA=$3
BALSHTMTH=$4
CRE_D=$5
DBCLO=$6
CLODAT=$7
ICLODAT=$8
#[037]
tempsRETANT=-1



#[037]
function RecupereTempsRESTANT
{
    echo "RecupereTempsRESTANT : debut"

    if test -f $DFILP/EST_ESCD9001_TEMPS_BATCH.dat
    then
        SHORT_NCHAIN=`echo ${NCHAIN} | cut -d_ -f2-`
        tps=`grep ${HOSTNAME} $DFILP/EST_ESCD9001_TEMPS_BATCH.dat | grep ${SHORT_NCHAIN} | cut -d~ -f2`
        if [ "${tps}" != "" ]
        then
            tempsRETANT=$tps
        fi
    else
        echo "-------------------------------------------------------"
        echo "- EST_ESCD9001_TEMPS_BATCH.dat non present dans DFILP -"
        echo "-------------------------------------------------------"
    fi

  echo "RecupereTempsRESTANT : ok"
  return 0
}


# Closing period
#------------------------------------------------------------------------------
export CLOPRD=`printf "%04d%02d" ${BALSHTYEA} ${BALSHTMTH}`

# Deconcatenation of closing period date
#------------------------------------------------------------------------------
export ICLODAT_YEA=`echo ${ICLODAT} | cut -c1-4`
export ICLODAT_MTH=`echo ${ICLODAT} | cut -c5-6`
export ICLODAT_DAY=`echo ${ICLODAT} | cut -c7-8`

export FIL_ALLCLO=FACMTRSH_FBANTECL_FCTRFIC_FCURCVSNI_FCURQUOT_FDETTRS_FGRP_FINTWIT_FLIBEL1_FLIBEL2_FLIFDRI_FLSTMTH_FRETPAR_FRETTRF_FSEGPAR_FSSDACTR_FSUBSID_FTRSLNK_FURRDAC_FSOBBLOB_FSEGMENT_CPLIFDRI_CPLIFDRIN_CRIBLEANO_FVPLACEMT_SEGRATANO_SRGTC_SRGTCB1_VLIFEST195_IARVPERICASE0_LIFESTNOACC_LIFESTANA_CPLIFEST_FRATTACHEVOL_FUNDSTA0_FBSEGEST_FCLIENT_FBOPRSLNK_FTVENTNP_FVENTNPANT_LIFTRANSFR_DLRLIFEP_FLIFPEN_FLIFTHR_FLIFMOD_FLIFMOD2_FTRSLNK7_FTFAMCHG_FCURCVSN_FTVENTNPHIS_SAISPERICASE_FFAMCNA_FLIFEST1_FCURSII_FRATINGRTO_FSEGPATTERN_BDT_FSEGPATTERN_CSF_FSEGPATTERN_DSC_FTRANSCODE_LIFENDCPT_VENTNP_TRIMPREV_VENTNP_TRIMCUR_FVPLACEMT2


#------------------------------------------------------------------------------
# Preparation of screen condition on the subsidaries for the SORT
# with SSDs( = _F1_F2_F3_...)
#------------------------------------------------------------------------------

export EST_SORT_CONDITION=`echo ${SSDs} | awk 'BEGIN{FS="_";first="Y"}\
        {  printf("(");\
           for(i=1;i<=NF;i++)\
                if($i != "")\
                {       if(first=="N") printf(" OR ") ;\
                        printf(" SSD_CF=%s",$i);\
                        first="N"\
                } \
           printf(")");\
        }'`



if [ "$EST_SORT_CONDITION" = "()" ]
then
    export EST_SORT_CONDITION="(1=1)"
fi

#[104]
echo "#"     >> ${FLOG}
echo "EST_SORT_CONDITION: ${EST_SORT_CONDITION}"     >> ${FLOG}
echo "#"     >> ${FLOG}



#---------------------------------------------------------------------------
# FUNCTION: EST_FCT_GONOGO
#
# 1 input parameter
#
# - Chain name file
#
# Subject: Elle permet de lancer lancer ou non la chaine ( parametre de la
#          fonction) en fonction d'un d'un plan genere par la chaine
#          ESCJ0000.cmd.
#          si la variable EST_${NCHAIN}_GONOGO n'est pas positinnee a "Y",
#          la chaine n'est pas lancee
#
#--------------------------------------------------------------------------
EST_FCT_GONOGO()
{

    #CHAIN_NAME=`echo $1 | awk '{print substr($0,length($0)-7)}'`
    CHAIN_NAME=`echo $1 | cut -d"_" -f2- `

    export GONOGO_VAR=`eval echo '$'EST_${CHAIN_NAME}_GONOGO`


    if [ "${GONOGO_VAR}" != "Y" ]
    then
        if [ "${JOB_NOECHO}" != "YES" ]
        then
            echo '#------------------------------------------'  2>&1 | ${TEE}
            echo "# ${CHAIN_NAME}: NO GO "  2>&1 | ${TEE}
            echo '#------------------------------------------'  2>&1 | ${TEE}
        fi

        return 1
    fi
}



#------------------------------------------------------------------------------
# [037] Trace de la chaine en cours
#------------------------------------------------------------------------------
function EST_TRACE {

    echo "${NCHAIN}  Debut : " `date +"%Y/%m/%d %H:%M:%S"`  >> $DFILI/LOG_CHAINE_ESTIMATION.dat

    return 0
}


#------------------------------------------------------------------------------
# [037] Mise à jour de la date de fin prévue dans TREQJOBPLAN
#------------------------------------------------------------------------------
function EST_TREQJOBPLAN_END {
#set -x
echo "EST_TREQJOBPLAN_END : debut"
    if [ "${tempsRETANT}" != "-1" ]
    then
    NSTEP=${NJOB}_10
    # Begin isql
    #---------------------------------------------------------------
    LIBEL="Mise à jour du temps restant dans TREQJOB"
    ISQL_BASE="BEST"
    ISQL_QRY="
              declare @cre_d  datetime
              declare @site_cf        varchar(10)
                            declare @suser_Name     varchar(20)
                            select  @suser_Name = suser_Name()
                            Execute BEST..PsSITE_01 @suser_Name,'0',@site_cf output
              select @cre_d = '${CRE_D}'

              select @cre_d = dateadd(HH, ${tempsRETANT}, convert(datetime, convert(char(8), getdate(), 112)))

              update BEST..TREQJOBPLAN
                 set END_D=@cre_d
              where LAUNCH_D is null
                and START_D is not null
                and DBCLO_D <= '${CRE_D}'
                and SITE_CF  = @site_cf
                and REQCOD_CT in ('D', 'I', 'J', 'A', 'L' )
             "
    ISQL_O=${DFILT}/${NCHAIN}_${NSTEP}_${IB}_SQL_O1.log
    ISQL
    fi

echo "EST_TREQJOBPLAN_END : ok"
    return 0
}

# Launch plannig
#-----------------------------------------------------------------
. ${EST_PLAN_IFRS4}
. ${EST_PLAN}


ECHO_LOG "#===> CLOPRD.........................: ${CLOPRD}"
ECHO_LOG "#===> CLODAT.........................: ${CLODAT}"
ECHO_LOG "#===> ICLODAT........................: ${ICLODAT}"
ECHO_LOG "#===> PREV_CLODAT....................: ${PREV_CLODAT}"
ECHO_LOG "#===> CUR_CLODAT.....................: ${CUR_CLODAT}"
ECHO_LOG "#===> TYPEINV........................: ${TYPEINV}"
ECHO_LOG "#===> NORME..........................: ${NORME}"

ECHO_LOG "#===> param_Demande..................: ${param_Demande}"
ECHO_LOG "#===> param_Closing_B................: ${param_Closing_B}"
ECHO_LOG "#===> param_nb_NoLife................: ${param_nb_NoLife}"
ECHO_LOG "#===> param_nb_Life..................: ${param_nb_Life}"
ECHO_LOG "#===> param_IsEpo....................: ${param_IsEpo}"
ECHO_LOG "#===> param_ComptaSocialIFRSDone.....: ${param_ComptaSocialIFRSDone}"
ECHO_LOG "#===> param_ComptaSocialEBSDone......: ${param_ComptaSocialEBSDone}"
ECHO_LOG "#===> param_IsEpoComptaRequestF......: ${param_IsEpoComptaRequestF}"
ECHO_LOG "#===> param_nb_NoEBS.................: ${param_nb_NoEBS}"
ECHO_LOG "#===> param_Request_id...............: ${param_Request_id}"


# 
# Launch Permanent files
#-----------------------------------------------------------------
. ${EST_PERM}

#ret de la chaine si elle ne figure pas dans le plan d'execution
#-----------------------------------------------------------------
EST_FCT_GONOGO ${NCHAIN}

if [ $? != 0 ]
then
	CHAINEND
fi



if [ "${JOB_NOECHO}" != "YES" ]
then
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
   echo '# End of initialization job    : ' ${NJOB} " Date : " `date +"%Y/%m/%d %H:%M:%S"`  2>&1 | ${TEE}
   echo '#-------------------------------------------------------------------------'  2>&1 | ${TEE}
fi

EST_TRACE
EST_TREQJOBPLAN_END

