#!/bin/ksh
#=============================================================================
# nom de l'application          : ESTIMATION - INVENTAIRE
#                                 Deletion of permanent files
# nom du script SHELL           : ESID0069.cmd
# revision                      : $Revision:   1.1  $
# date de creation              : 17/03/98
# auteur                        : CGI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   Extracting tables.
#-----------------------------------------------------------------------------
# historique des modifications
#---------------
#MODIFICATION   : [001]
#Auteur         : D.GATIBELZA
#Date           : 11/05/2011
#Version        : 11.1
#Description    : 1GL
#[002] 25/03/2015 R. Cassis :spot:28483 Generation of Estimates and retro account files to chain ESID0110 instead of ESID0060 for Vtom optimisation
#                                       Then no rmfile of EST_FLIFEST0 and EST_FACCTRAA0 into this job
# [003] 26/02/2021 M.NAJI Spira 91531  commenter les suppression des fichier permanents  
#===============================================================================

# Call generic functions
. ${DUTI}/fctgen.cmd

# Job Initialization
JOBINIT

#[002]
NSTEP=${NJOB}_00
#Last version of ESID0060 files deletion
#[001] ESID0060_MVTPNA0*.dat passe à ESID0070_MVTPNA0*.dat
#-----------------------------------------------------------------
RMFIL "  `dirname ${EST_FACCPAR0}`/${PCH}ESID0060_FACCPAR0*.dat
 `dirname ${EST_FACCTRAI0}`/${PCH}ESID0060_FACCTRAI0*.dat
 `dirname ${EST_FCMUSPLI0}`/${PCH}ESID0060_FCMUSPLI0*.dat
 `dirname ${EST_FCMUSPLIT0}`/${PCH}ESID0060_FCMUSPLIT0*.dat
 `dirname ${EST_FCTREST0}`/${PCH}ESID0060_FCTREST0*.dat
 `dirname ${EST_FDEPOSIT0}`/${PCH}ESID0060_FDEPOSIT0*.dat
 `dirname ${EST_FINTWIT}`/${PCH}ESID0060_FINTWIT*.dat
 `dirname ${EST_FLABOCY0}`/${PCH}ESID0060_FLABOCY0*.dat
 `dirname ${EST_FLSTMTH}`/${PCH}ESID0060_FLSTMTH*.dat
 `dirname ${EST_FOUTTRAA0}`/${PCH}ESID0060_FOUTTRAA0*.dat
 `dirname ${EST_FOUTTRAI0}`/${PCH}ESID0060_FOUTTRAI0*.dat
 `dirname ${EST_FPFUNWIT0}`/${PCH}ESID0060_FPFUNWIT0*.dat
 `dirname ${EST_FPINTWIT0}`/${PCH}ESID0060_FPINTWIT0*.dat
 `dirname ${EST_FSEGEST0}`/${PCH}ESID0060_FSEGEST0*.dat
 `dirname ${EST_IADPERIFCI0}`/${PCH}ESID0060_IADPERIFCI0*.dat
 `dirname ${EST_IADPERIFR0}`/${PCH}ESID0060_IADPERIFR0*.dat
 `dirname ${EST_IADPERIPRMD0}`/${PCH}ESID0060_IADPERIPRMD0*.dat
 `dirname ${EST_OADPERICASE0}`/${PCH}ESID0060_OADPERICASE0*.dat
 `dirname ${EST_OAVPERICASE0}`/${PCH}ESID0060_OAVPERICASE0*.dat
 `dirname ${EST_ORDPERICASE0}`/${PCH}ESID0060_ORDPERICASE0*.dat
 `dirname ${EST_ORVPERICASE0}`/${PCH}ESID0060_ORVPERICASE0*.dat
 `dirname ${EST_MVTPNA0}`/${PCH}ESID0070_MVTPNA0*.dat"

 # [003]`dirname ${EST_FCURCVSNI}`/${PCH}ESID0060_FCURCVSNI*.dat
 # [003]`dirname ${EST_IRDPERICASE0}`/${PCH}ESID0060_IRDPERICASE0*.dat
 # [003]`dirname ${EST_IRVPERICASE0}`/${PCH}ESID0060_IRVPERICASE0*.dat
JOBEND
