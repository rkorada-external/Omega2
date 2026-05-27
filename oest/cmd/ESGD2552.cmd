#!/bin/ksh
#==============================================================================
#nom de l'application          : Technical Job for inter-site transfer
#nom du source                 : TEFJ0013.cmd
#revision                      : $Revision: 1.1 $
# revision                      : $Revision:   1.2  $
# date de creation              : 05/05/2025
# auteur                        : M.NAJI
# references des specifications : 
#-----------------------------------------------------------------------------
# description
#   SPIRA 111672  Evolution SERQ : Merge  files
#==============================================================================
#set -x

. ${DUTI}/fctgen.cmd

# Job initialization
JOBINIT





export FILE_SITE=`eval echo '$'${RIGHT_FILE}`
export FILE_FILTER=`eval echo '$'${LEFT_FILE}`



FILE_AS=`echo  ${FILE_SITE} | sed -e s/ub../ubas/`
FILE_EU=`echo  ${FILE_SITE} | sed -e s/ub../ubeu/`
FILE_AM=`echo  ${FILE_SITE} | sed -e s/ub../ubam/`



[ "$DEFAULT_SQL_LOGIN" = "ubas" ] && FILE_AS=$DFILP/empty.dat
[ "$DEFAULT_SQL_LOGIN" = "ubeu" ] && FILE_EU=$DFILP/empty.dat
[ "$DEFAULT_SQL_LOGIN" = "ubam" ] && FILE_AM=$DFILP/empty.dat


ECHO_LOG ">> =============================================================================="
ECHO_LOG ">> ==> Name RIGHT_FILE ..... :  $RIGHT_FILE                 "
ECHO_LOG ">>>==> LEFT_FILE ........... :  $FILE_FILTER                 "
ECHO_LOG ">> ==> RIGHT_FILE........... :  $FILE_SITE                 "
ECHO_LOG ">> ==> FILE_AS ............. :  ${FILE_AS}                 "
ECHO_LOG ">> ==> FILE_AM ............. :  ${FILE_AM}                 "
ECHO_LOG ">> ==> FILE_EU ............. :  ${FILE_EU}                 "
ECHO_LOG ">> ==> LEFT_FIELDS ......... :  $LEFT_FIELDS                 "
ECHO_LOG ">> ==> LEFT_KEYS ........... :  $LEFT_KEYS                 "
ECHO_LOG ">> ==> RIGHT_FIELDS ........ :  $RIGHT_FIELDS                 "
ECHO_LOG ">> ==> RIGHT_KEYS .......... :  $RIGHT_KEYS                 "
ECHO_LOG ">> ==> FIELDS_SORT ......... :  $FIELDS_SORT                 "
ECHO_LOG ">> ==> KEYS_SORT ........... :  $KEYS_SORT                 "




NSTEP=${NJOB}_10
# Begin test
#------------------------------------------------------------------------------
 LIBEL="test $FILE_SITE exists"

if ! test -f "$FILE_SITE"; then 

        ECHO_LOG "#==============================================================="
        ECHO_LOG "#======>  $FILE_SITE not find"
        ECHO_LOG "#==============================================================="

        STEPEND 10
fi
if [[ "$RIGHT_FILE" == EST_FCES* ]] && [ -f "$ESF_FCES_SERQ" ];  then
    ECHO_LOG ">> ==> ESF_FCES_SERQ ....... :   ${ESF_FCES_SERQ}                 "
fi

if [[ "$RIGHT_FILE" == ESF_FLORETFACTOR* ]] && [ -f "$ESF_FLORETFACTOR_SERQ" ]; then
    ECHO_LOG ">> ==> ESF_FLORETFACTOR_SERQ :${ESF_FLORETFACTOR_SERQ}                 "
fi

	
ECHO_LOG ">> "
ECHO_LOG ">> "
ECHO_LOG ">> $FILE_FILTER  X                 "
ECHO_LOG ">> ("
ECHO_LOG ">>    ${FILE_AS} "
ECHO_LOG ">>    ${FILE_EU} " 
ECHO_LOG ">>    ${FILE_AM} "
ECHO_LOG ">> ) "
ECHO_LOG ">> + $FILE_SITE"
if [[ "$RIGHT_FILE" == EST_FCES* ]] && [ -f "$ESF_FCES_SERQ" ];  then
    ECHO_LOG ">> + $ESF_FCES_SERQ"
fi


if [[ "$RIGHT_FILE" == ESF_FLORETFACTOR* ]] && [ -f "$ESF_FLORETFACTOR_SERQ" ]; then
    ECHO_LOG ">> + $ESF_FLORETFACTOR_SERQ"
fi


NSTEP=${NJOB}_12
# Begin sort
#------------------------------------------------------------------------------
LIBEL="Save $FILE_SITE to ${FILE_SITE}_BEFORE "
EXECKSH "cp $FILE_SITE ${FILE_SITE}_BEFORE"

if [[ "$DEFAULT_SQL_LOGIN" != "ubas" && -f "${FILE_AS}"_BEFORE ]]; then
    NSTEP=${NJOB}_15_AS
    # Begin sort
    #------------------------------------------------------------------------------
    LIBEL="Save $FILE_SITE8AS to ${FILE_SITE}_MERGE AND copy ${FILE_AS}_BEFORE ${FILE_AS}"
    EXECKSH "mv ${FILE_AS} ${FILE_AS}_MERGE"
    EXECKSH "cp  ${FILE_AS}_BEFORE ${FILE_AS} "
fi

if [[ "$DEFAULT_SQL_LOGIN" != "ubeu" && -f "${FILE_EU}"_BEFORE ]]; then
    NSTEP=${NJOB}_15_EU
    # Begin sort
    #------------------------------------------------------------------------------
    LIBEL="Save $FILE_SITE8AS to ${FILE_SITE}_MERGE AND copy ${FILE_EU}_BEFORE ${FILE_EU}"
    EXECKSH "mv ${FILE_EU} ${FILE_EU}_MERGE"
    EXECKSH "cp  ${FILE_EU}_BEFORE ${FILE_EU} "
fi

if [[ "$DEFAULT_SQL_LOGIN" != "ubam" && -f "${FILE_AM}"_BEFORE ]]; then
    NSTEP=${NJOB}_15_AM
    # Begin sort
    #------------------------------------------------------------------------------
    LIBEL="Save $FILE_SITE8AS to ${FILE_SITE}_MERGE AND copy ${FILE_AM}_BEFORE ${FILE_AM}"
    EXECKSH "mv ${FILE_AM} ${FILE_AM}_MERGE"
    EXECKSH "cp  ${FILE_AM}_BEFORE ${FILE_AM} "
fi

NSTEP=${NJOB}_20
# Begin C program
#------------------------------------------------------------------------------
LIBEL="Computing acceptance TL from retrocessionaire subsidiaries...DLDVGTR => DLEIGTAA"


FPRM=`CFTMP`
head  ${FILE_AS} | awk -F~ '{print NF}' | sort -u > $FPRM
head  ${FILE_EU} | awk -F~ '{print NF}' | sort -u >> $FPRM
head  ${FILE_AM} | awk -F~ '{print NF}' | sort -u >> $FPRM
if test -s "$FPRM"; then
        FILES_SIZE=`head  -1 $FPRM ` 
    else
        echo "files "$file" empty "
        return 1
fi


NSTEP=${NJOB}_30
# filter 
#------------------------------------------------------------------------------
LIBEL="Filter  $LEFT_KEYS X $RIGHT_KEYS  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${FILE_FILTER} 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_OTHER_SITES_O.dat"
INPUT_TEXT $SORT_CMD <<EOF
/FIELDS
    $LEFT_FIELDS,
    $RIGHT_FIELDS,
    ALL_COLS 1:1 - $FILES_SIZE:
/joinkeys  $LEFT_KEYS
/INFILE    ${FILE_AS}     2000 1 "~"
/INFILE    ${FILE_EU}     2000 1 "~"
/INFILE    ${FILE_AM}     2000 1 "~"
/JOINKEYS  $RIGHT_KEYS 

/OUTFILE  ${SORT_O}
/REFORMAT
    rightside :ALL_COLS
exit
EOF
SORT



NSTEP=${NJOB}_40
# filter 
#------------------------------------------------------------------------------
LIBEL="Filter  $KEYS_LEFT_JOIN X $KEYS_OTHER  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_30_${IB}_OTHER_SITES_O.dat 2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_OTHER_SITES_O.dat 2000 1"
INPUT_TEXT $SORT_CMD <<EOF
/SUM
/OUTFILE  ${SORT_O}
exit
EOF
SORT

NSTEP=${NJOB}_50
# filter 
#------------------------------------------------------------------------------
LIBEL="merge Filter  $KEYS_LEFT_JOIN X $KEYS_OTHER  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_40_${IB}_OTHER_SITES_O.dat 2000 1"
SORT_I2="$FILE_SITE   2000 1"
SORT_O="${DFILT}/${NSTEP}_${IB}_OTHER_SITES_O.dat"
INPUT_TEXT $SORT_CMD <<EOF
/COPY
/OUTFILE  ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_60
# filter 
#------------------------------------------------------------------------------
LIBEL="Filter  $KEYS_LEFT_JOIN X $KEYS_OTHER  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_50_${IB}_OTHER_SITES_O.dat 2000 1"

if [[ "$RIGHT_FILE" == EST_FCES* ]] && [ -f "$ESF_FCES_SERQ" ];  then
	SORT_I2="${ESF_FCES_SERQ} 2000 1"
fi


if [[ "$RIGHT_FILE" == ESF_FLORETFACTOR* ]] && [ -f "$ESF_FLORETFACTOR_SERQ" ]; then
	SORT_I2="${ESF_FLORETFACTOR_SERQ} 2000 1"
fi




SORT_O="${DFILT}/${NSTEP}_${IB}_NOT_DOUBLONS_O.dat"
INPUT_TEXT $SORT_CMD <<EOF
/SUM
/OUTFILE  ${SORT_O}
exit
EOF
SORT



NSTEP=${NJOB}_70
# filter 
#------------------------------------------------------------------------------
LIBEL="Filter  $KEYS_LEFT_JOIN X $KEYS_OTHER  "
SORT_WDIR=${SORTWORK}
SORT_CMD=`CFTMP`
SORT_I="${DFILT}/${NJOB}_60_${IB}_NOT_DOUBLONS_O.dat 2000 1"
SORT_O="$FILE_SITE"
INPUT_TEXT $SORT_CMD <<EOF
$FIELDS_SORT
$KEYS_SORT 
exit
EOF
SORT

if [[ "$DEFAULT_SQL_LOGIN" != "ubas" && -f "${FILE_AS}_BEFORE" ]]; then
    NSTEP=${NJOB}_15_AS
    # Begin sort
    #------------------------------------------------------------------------------
    LIBEL="Restore merged  ${FILE_AS}"
    EXECKSH "mv  ${FILE_AS}_MERGE ${FILE_AS}"
fi

if [[ "$DEFAULT_SQL_LOGIN" != "ubeu" && -f "${FILE_EU}_BEFORE" ]]; then
    NSTEP=${NJOB}_15_EU
    # Begin sort
    #------------------------------------------------------------------------------
    LIBEL="Restore merged  ${FILE_EU}"
    EXECKSH "mv ${FILE_EU}_MERGE ${FILE_EU} "
fi

if [[ "$DEFAULT_SQL_LOGIN" != "ubam" && -f "${FILE_AM}_BEFORE" ]]; then
    NSTEP=${NJOB}_15_AM
    # Begin sort
    #------------------------------------------------------------------------------
    LIBEL="restore merged  ${FILE_AM}"
    EXECKSH "mv ${FILE_AM}_MERGE ${FILE_AM} "
fi

# End of the Job
JOBEND
