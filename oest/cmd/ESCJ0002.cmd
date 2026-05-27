#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATIONS - COMMUNS
# nom du script SHELL           : ESCJ0002.cmd
# date de creation              : 23/08/2010
# auteur                        : D.GATIBELZA
#-----------------------------------------------------------------------------
# description:  les demandes postées dans la tables TREQJOBPLAN sont copiées dans la TREQJOB
#
# job launched by ESCJ0000.cmd
#-----------------------------------------------------------------------------
# Modification Records
#---------------
#MODIFICATION   :
#[100] 30/09/2013 P. Pezout   :spot:25427  - Modifications pour omega2 -1b sur treqjob et treqjobplan
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialisation
JOBINIT

# Parameters
CRE_D=$1


# Initialisation de la TRACE DE LA CHAINE EN COURS ( pour le ESCD9001 )
echo "${NCHAIN} [${CRE_D}]  Debut : " `date +"%Y/%m/%d %H:%M:%S"`  > $DFILI/LOG_CHAINE_ESTIMATION.dat

NSTEP=${NJOB}_10
# Begin isql
#---------------------------------------------------------------
LIBEL="Recopie le traitement du jour de TREQJOBPLAN vers TREQJOB"
ISQL_BASE="BEST"
ISQL_QRY="execute BEST..PtREQJOBPLAN_01 '${CRE_D}'"
ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
ISQL


#
#for DEMANDE in `echo "A L"`
#do
#
#    ## on éclate les demandes A multifiliales en multidemandes dans TREQJOB
#    NSTEP=${NJOB}_20${DEMANDE}
#    # Begin isql
#    #---------------------------------------------------------------
#    LIBEL="Extraction des filiales des demandes ${DEMANDE} multi"
#    BCP_WAY="OUT"; BCP_VER="+"
#    BCP_O=${DFILT}/${NSTEP}_${IB}_BCP_TREQJOB_O1.dat
#    BCP_QRY="select CLOPER_LS
#              from BEST..TREQJOB
#              where REQCOD_CT = '${DEMANDE}'
#                and LAUNCH_D is NULL
#                and CLOPER_LS is not null 
#                and SITE_CF = substring(suser_Name(),3,2) "
#    BCP
#
#
#    for ssd in `cat ${DFILT}/${NJOB}_20${DEMANDE}_${IB}_BCP_TREQJOB_O1.dat | sed 's/,/ /'g`
#    do
#        echo "Filiale demandee: ${ssd}"
#
#        NSTEP=${NJOB}_30
#        # Begin isql
#        #---------------------------------------------------------------
#        LIBEL="Supprime et recrée la demande ${DEMANDE} sur la filiale ${ssd}"
#        ISQL_BASE="BEST"
#        ISQL_QRY="delete from BEST..TREQJOB
#                  where REQCOD_CT = '${DEMANDE}'
#                    and LAUNCH_D is null
#                    and SSD_CF = ${ssd}
#                    and CLOPER_LS is null
#                    and SITE_CF = substring(suser_Name(),3,2)
#
#                  insert BEST..TREQJOB
#                  select distinct ${ssd},
#                                  BALSHEYEA_NF,
#                                  BALSHTMTH_NF,
#                                  CLODAT_D,
#                                  REQCOD_CT,
#                                  convert(char(8), CRE_D, 112),
#                                  convert(char(8), DBCLO_D, 112),
#                                  null 'LAUNCH_D',
#                                  null 'CLOPER_LS',
#                                  VRS_NF,
#                                  'DBO',
#                                  substring(suser_Name(),3,2),
#                                  suser_Name(),
#                                  ID_NF
#                  from BEST..TREQJOB
#                  where REQCOD_CT = '${DEMANDE}'
#                    and LAUNCH_D is NULL
#                    and CLOPER_LS is not null
#                    and UPDUSR_CF !='DBO'
#                    and SITE_CF = substring(suser_Name(),3,2)
#                  "
#        ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
#        ISQL
#    done
#
#
#    NSTEP=${NJOB}_40${DEMANDE}
#    # Begin isql
#    #---------------------------------------------------------------
#    LIBEL="On Toppe la demande ${DEMANDE} Multi"
#    ISQL_BASE="BEST"
#    ISQL_QRY="update BEST..TREQJOB
#                 set LAUNCH_D = '${CRE_D}'
#              where REQCOD_CT = '${DEMANDE}'
#                and LAUNCH_D is NULL
#                and CLOPER_LS is not null
#                and UPDUSR_CF !='DBO'
#                and SITE_CF = substring(suser_Name(),3,2)
#              "
#    ISQL_O=${DFILT}/${NSTEP}_${IB}_SQL_O1.log
#    ISQL
#
#done
#

# End of Job
JOBEND

