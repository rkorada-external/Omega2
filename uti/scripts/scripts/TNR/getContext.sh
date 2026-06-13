#!/bin/ksh
set -x

if [ "$#" -ne 3 ]; then
  echo
  echo "#arg error"
  echo "Usage: " >&2
  echo '$1: server ( aeninto2batch, aenuato2batch , aenprdo2batch , aencnvo2batch or aenitko2batch ) ' >&2
  echo '$2: site ( as , am or eu) ' >&2
  echo '$3: PCH Prefix  ' >&2
  echo '$4: env (ITK,UAT,CNV, PRD , UAT )  ' >&2
  echo
  return 1
fi
server=$1
site=$2
PCH=$3
env=$4


export ENV_PREFIX=${PCH}
export XDFILP=/scordata_${server}/ub${site}/perm
export XDFILI=/scordata_${server}/ub${site}/INTERM

#$DCMD/ESFJ0000.cmd = $TI17PERMFIL

#set -x
#cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PLAN_I17L.dat		$DFILP/${PCH}_ESFJ0000_PLAN_I17L.dat
#cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PLAN_I17.dat         $DFILP/${PCH}_ESFJ0000_PLAN_I17.dat
#cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_TI17PERMFIL.dat      $DFILP/${PCH}_ESFJ0000_TI17PERMFIL.dat
#cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PLAN_IFRS17.dat      $DFILP/${PCH}_ESFJ0000_PLAN_IFRS17.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PERM_EPO.dat         $DFILP/${PCH}_ESFJ0000_PERM_EPO.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PARM.dat             $DFILP/${PCH}_ESFJ0000_PARM.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN0.dat				$DFILP/${PCH}_ESCJ0000_PLAN0.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN1.dat                $DFILP/${PCH}_ESCJ0000_PLAN1.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN3.dat                $DFILP/${PCH}_ESCJ0000_PLAN3.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN4.dat                $DFILP/${PCH}_ESCJ0000_PLAN4.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN2.dat                $DFILP/${PCH}_ESCJ0000_PLAN2.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN_EPO.dat             $DFILP/${PCH}_ESCJ0000_PLAN_EPO.dat
#cp /scordata_${server}/ub${site}/perm/${PCH}_ESFJ0000_PLAN_I17G.dat            $DFILP/${PCH}ESFJ0000_PLAN_I17G.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_IFRS17_PLAN0.dat         $DFILP/${PCH}_ESCJ0000_IFRS17_PLAN0.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PARM0.dat                $DFILP/${PCH}_ESCJ0000_PARM0.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN0.dat                $DFILP/${PCH}_ESCJ0000_PLAN0.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PARM1.dat                $DFILP/${PCH}_ESCJ0000_PARM1.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN1.dat                $DFILP/${PCH}_ESCJ0000_PLAN1.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PARM3.dat                $DFILP/${PCH}_ESCJ0000_PARM3.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN3.dat                $DFILP/${PCH}_ESCJ0000_PLAN3.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PARM4.dat                $DFILP/${PCH}_ESCJ0000_PARM4.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN4.dat                $DFILP/${PCH}_ESCJ0000_PLAN4.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PARM2.dat                $DFILP/${PCH}_ESCJ0000_PARM2.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN2.dat                $DFILP/${PCH}_ESCJ0000_PLAN2.dat
cp /scordata_${server}/ub${site}/perm/${PCH}_ESCJ0000_PLAN_EPO.dat             $DFILP/${PCH}_ESCJ0000_PLAN_EPO.dat
#cp /scordata_${server}/ub${site}/prm/ESCJ0000.prm					  $DPRM/ESCJ0000.prm


