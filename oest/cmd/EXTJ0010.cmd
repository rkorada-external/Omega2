#! /bin/ksh
#==============================================================================
#application name               : Extraction data from database
#source name                    : EXTJR0010.cmd
#revision                       : $Revision:   0.1  $
#extraction date                : 18/01/2019
#author                         : Lagha Belaid
#specifications reference       :
#                               :
#---------------------------------------------------------------
#description : Extract table data to compare them
#
# parameters : 
#
#---------------------------------------------------------------
# modifications chronology  :
# [01] 26/08/2021 D.TEIXEIRA : SPIRA 97731 fix bug due to change I17 -> I17G on ${EST_PARAM}
# [02] 11/15/2022 J.B-D			 : SPIRA 107644 add ESFD9001 call
#==============================================================================

# Call generic functions
#------------------------------------------------------------------------------
. ${DUTI}/fctgen.cmd

# Chain Initialization variables
#------------------------------------------------------------------------------
CHAININIT $0 $1


#MOD[02]
NJOB="ESFD9001_${IDF_CT}"
# Launch job to set context
. ${DCMD}/ESFD9001.cmd ${IDF_CT}


#------------------------------------------------------------------------------
# Preparing of I17 param file
#----------------------------
sed -n '/^I17/p' ${EST_PARAM} | sed '/^[-#]/d;s/^ *\|export *\| *I17. *~\|PARM_//g; s/~/="/g;s/ *$/"/g' > ${DTMP}/${NCHAIN}_EST_PARAM_I17.prm
sed -i '/SSDCLO_LL/s/_ */,/g; s/"'\'',\|,'\''"/"/g; s/SSDCLO,/SSDCLO_/' ${DTMP}/${NCHAIN}_EST_PARAM_I17.prm
# Preparing of EBS param file
#----------------------------
sed -n '/^EBS/p' ${EST_PARAM} | sed '/^[-#]/d;s/^ *\|export *\| *EBS *~\|PARM_//g; s/~/="/g;s/ *$/"/g' > ${DTMP}/${NCHAIN}_EST_PARAM_EBS.prm
sed -i '/SSDCLO_LL/s/_ */,/g; s/"'\'',\|,'\''"/"/g; s/SSDCLO,/SSDCLO_/' ${DTMP}/${NCHAIN}_EST_PARAM_EBS.prm
# Preparing of I4I param file
#----------------------------
sed -n '/^I4I/p' ${EST_PARAM} | sed '/^[-#]/d;s/^ *\|export *\| *I4I *~\|PARM_//g; s/~/="/g;s/ *$/"/g' > ${DTMP}/${NCHAIN}_EST_PARAM_I4I.prm
sed -i '/SSDCLO_LL/s/_ */,/g; s/"'\'',\|,'\''"/"/g; s/SSDCLO,/SSDCLO_/' ${DTMP}/${NCHAIN}_EST_PARAM_I4I.prm


#------------------------------------------------------------------------------
# Get the parameters
#-------------------
IF17CLODAT_D="`GETV ${DTMP}/${NCHAIN}_EST_PARAM_I17.prm ICLODAT_D`"
IF4CLODAT_D="`GETV ${DTMP}/${NCHAIN}_EST_PARAM_I4I.prm PARM0_ICLODAT_D`"
if [ "${IF17CLODAT_D}" == "" ]; then
	IF17CLODAT_D="`GETV ${DTMP}/${NCHAIN}_EST_PARAM_EBS.prm ICLODAT_D`"
fi


# check if rextr and extrqry... directory exist, create them if not
#------------------------------------------------------------------
if [ ! -d ${DSRCQ} ]; then
   ECHO_LOG "# ${DSRCQ}/ not found"
fi
if [ ! -d ${DREXTR} ]; then
   ECHO_LOG "# ${DREXTR}/ not found"
fi


export PARM_FILE=""
if [ -s ${DTMP}/${NCHAIN}_EST_PARAM_EBS.prm ]; then
	PARM_FILE=${DTMP}/${NCHAIN}_EST_PARAM_EBS.prm
fi
if [ -s ${DTMP}/${NCHAIN}_EST_PARAM_I17.prm ]; then
	PARM_FILE=${DTMP}/${NCHAIN}_EST_PARAM_I17.prm
fi


if [ "${PARM_FILE}" != "" ]; then
NJOB="EXTJ0011"
#------------------------------------------------------------------------------
# Launch applicative job EXTJ0011 for IFRS17 / EBS 
#-------------------------------------------------
${DCMD}/EXTJ0011.cmd ${DSRCQ} ${IF17CLODAT_D} "${PARM_FILE}" ${IFRS17} 2>&1 | ${TEE}
fi

if [ -s ${DTMP}/${NCHAIN}_EST_PARAM_I4I.prm ]; then
NJOB="EXTJ0011"
#------------------------------------------------------------------------------
# Launch applicative job EXTJ0011 for IFRS4
#-------------------------------------------
${DCMD}/EXTJ0011.cmd ${DSRCQ} ${IF4CLODAT_D} "${DTMP}/${NCHAIN}_EST_PARAM_I4I.prm" ${IFRS4} 2>&1 | ${TEE}
fi


# Launch applicative job EXTJ0012
NJOB="EXTJ0012"
${DCMD}/EXTJ0012.cmd 2>&1 | ${TEE}

#------------------------------------------------------------------------------
# Delete temporary files
#-----------------------
rm ${DTMP}/${NCHAIN}_EST_PARAM.prm 2>1&>/dev/null

# Create a flag for TNR REPORT
#-----------------------------
touch ${DFILI}/GO_TNR_REPORT


#------------------------------------------------------------------------------
# End of chain
#--------------
CHAINEND

