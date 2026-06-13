#!/bin/ksh


if [ "$#" -ne 3 ]; then
  echo
  echo "#arg error"
  echo "Usage: " >&2
  echo '$1: env ( uat , itk, cnv , ... ) ' >&2
  echo '$2: site ( as , am or eu) ' >&2
  echo '$3: Prefix destination ' >&2
  echo
  exit 1
fi
env=$1
site=$2
pref_dest=$3
PCH=T

server=aen${env}o2batch
if [ "$env" = "cnv" ]; then
        PCH=C
fi

if [ "$env" = "prd" ]; then
        PCH=P
fi



set -x

cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_COND.dat          		$DFILP/${pref_dest}ESFJ0000_COND.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_SUFFTABLE.dat          	$DFILP/${pref_dest}ESFJ0000_SUFFTABLE.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PARM.dat          		$DFILP/${pref_dest}ESFJ0000_PARM.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PARM_O.dat          		$DFILP/${pref_dest}ESFJ0000_PARM_O.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PARM_GLOBAL.dat          	$DFILP/${pref_dest}ESFJ0000_PARM_GLOBAL.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PLAN_IFRS17.dat          	$DFILP/${pref_dest}ESFJ0000_PLAN_IFRS17.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_TI17PERMFIL.dat          	$DFILP/${pref_dest}ESFJ0000_TI17PERMFIL.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PLAN.dat          		$DFILP/${pref_dest}ESFJ0000_PLAN.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PARM_I4I.dat          	$DFILP/${pref_dest}ESFJ0000_PARM_I4I.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PARM_I17L.dat          	$DFILP/${pref_dest}ESFJ0000_PARM_I17L.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PARM_I17P.dat          	$DFILP/${pref_dest}ESFJ0000_PARM_I17P.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PARM_EBS.dat          	$DFILP/${pref_dest}ESFJ0000_PARM_EBS.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PARM_I17G.dat          	$DFILP/${pref_dest}ESFJ0000_PARM_I17G.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_MODE.dat          		$DFILP/${pref_dest}ESCJ0000_MODE.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLANCTL.dat          		$DFILP/${pref_dest}ESCJ0000_PLANCTL.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PARM0.dat          		$DFILP/${pref_dest}ESCJ0000_PARM0.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN0.dat          		$DFILP/${pref_dest}ESCJ0000_PLAN0.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PARM1.dat          		$DFILP/${pref_dest}ESCJ0000_PARM1.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN1.dat          		$DFILP/${pref_dest}ESCJ0000_PLAN1.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PARM3.dat          		$DFILP/${pref_dest}ESCJ0000_PARM3.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN3.dat          		$DFILP/${pref_dest}ESCJ0000_PLAN3.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PARM4.dat          		$DFILP/${pref_dest}ESCJ0000_PARM4.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN4.dat          		$DFILP/${pref_dest}ESCJ0000_PLAN4.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PARM2.dat          		$DFILP/${pref_dest}ESCJ0000_PARM2.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN2.dat          		$DFILP/${pref_dest}ESCJ0000_PLAN2.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_EST_LASTPOBOOKING.dat     $DFILP/${pref_dest}ESCJ0000_EST_LASTPOBOOKING.dat

cp /scordata_${server}/ub${site}/prm/ESCJ0000.prm                              	$DPRM/ESCJ0000.prm


