if [ "$#" -ne 2 ]; then
	echo -e "#\n#\n"
 	echo "# the arguments env & domain are mandatory "
	echo "# example to set env of domain << oest >> and environment << 3F_DEV >>:"
	echo "#		. /scor/livraison/uti/envTools/setLocalEnv.sh 3F_DEV oest"
	echo -e "#\n#\n"
	exit

fi

LOCAL_ENV=$1
ROOT_DIR=~/${LOCAL_ENV}/$2
export DNZDFILP=$DFILP
export DNZDFILP=$DFILP
export DCMD="${ROOT_DIR}/cmd"
export DPRM="${ROOT_DIR}/prm"
export DENV="${ROOT_DIR}/env"
export DSC="${ROOT_DIR}/sc"
export DSH="${ROOT_DIR}/sh"
export DPRC="${ROOT_DIR}/sql/proc/PRD"
export DDDL="${ROOT_DIR}/sql/ddl/PRD"
export DDML="${ROOT_DIR}/sql/dml/PRD"
export DEXE="${ROOT_DIR}/../exe"
alias gocmd="cd $DCMD"
alias gocmdp='cd    /scoromega_runnable_dcvprdobbatch/cmd;'
alias gocmdu='cd    /scoromega_runnable_dcvuatobbatch/cmd'
alias gocmdi='cd    /scoromega_runnable_dcvintobbatch/cmd'
alias gocmd2='cd    /scoromega_runnable_dcvin2obbatch/cmd'
alias gocmdm='cd    /scoromega_runnable_dcvmaiobbatch/cmd'
alias gocmdc='cd    /scoromega_runnable_dcvcnvobbatch/cmd;'
alias gocmdk='cd    /scoromega_runnable_dcvtsto2db02/cmd;'
alias goprm="cd $DPRMM"
alias gosc="cd $DSC"
alias goproc="cd $DPRC"
alias goenv="cd $DENV"
alias goddl="cd $DDDL"
alias godml="cd $DDML"
alias gosh="cd $DSH"
alias goftp="cd $DTRANSFER"
alias gouti="cd $DUTI"
alias goexe="cd $DEXE"
alias ll="ls -lrt"
export PS1="${LOCAL_ENV}>> "

