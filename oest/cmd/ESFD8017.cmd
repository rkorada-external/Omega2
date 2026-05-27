## 12/10/2021 A.RUFFAULT :spira:99072 EST - IFRS17/EBS- Isolate pattern renewal procees in dedicated batch chain
###!/bin/ksh
###=============================================================================
### nom de l'application          : IFRS17 Booking
### nom du script SHELL           : ESF8017.cmd
### revision                      : 
### date de creation              : 18/02/2020
### auteur                        : Charles SOCIE
### references des specifications :
###-----------------------------------------------------------------------------
### description
###  Spira 70380 REQ 1000.07 - Patterns, RA ratio and IFRS 17 expenses ratio automatic renewal
###-----------------------------------------------------------------------------
### [01] Charles SOCIE spira 70380 add norme_cf
###===============================================================================
##
### Call generic functions
##. ${DUTI}/fctgen.cmd
##
### Job Initialisation
##JOBINIT
##
##ECHO_LOG "#========================================================================="
##ECHO_LOG "#===> ........................ INPUTS ....................................."
##ECHO_LOG "#===> CLOSING_DATE.......................................: ${PARM_ICLODAT_D}"
##ECHO_LOG "#===> CRE_DATE...........................................: ${PARM_CRE_D}"
##ECHO_LOG "#===> TYPEINV............................................: ${TYPEINV}"
##ECHO_LOG "#===> NORME_CF...........................................: ${NORME_CF}"
##ECHO_LOG "#========================================================================="
##
##NSTEP=${NJOB}_05
###------------------------------------------------------------------------------
##LIBEL="Update table BRET..TEXPRAT and BEST..TRARAT"
##ISQL_BASE="BREF"
##ISQL_O=${DFILT}/${NSTEP}_${IB}_ISQL.log
##ISQL_QRY="exec BEST..PuRenewalI17 '${PARM_ICLODAT_D}', '${PARM_CRE_D}', '${TYPEINV}', '${NORME_CF}'"
##ISQL
##
##
##
##JOBEND