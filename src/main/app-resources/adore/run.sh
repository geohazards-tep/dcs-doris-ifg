#!/bin/bash
set -x 
# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

# define the exit codes
SUCCESS=0
ERR_MASTER=10
ERR_SLAVE=20
ERR_EXTRACT=30
ERR_ADORE=40
ERR_PUBLISH_RES=50
ERR_PUBLISH_PNG=60

# add a trap to exit gracefully
cleanExit () { 

  local retval=$?
  local msg
  msg=""
	
  case "${retval}" in
    ${SUCCESS}) msg="Processing successfully concluded";;
		${ERR_MASTER}) msg="Failed to retrieve the master product";;
    ${ERR_SLAVE}) msg="Failed to retrieve the slave product";;
    ${ERR_EXTRACT}) msg="Failed to retrieve the extract the vol and lea";;
		${ERR_ADORE}) msg="Failed during ADORE execution";;
		${ERR_PUBLISH_RES}) msg="Failed results publish";;
		${ERR_PUBLISH_PNG}) msg="Failed results publish quicklooks";;
		*) msg="Unknown error";;
  esac

  [ "${retval}" != "0" ] && ciop-log "ERROR" \
    "Error ${retval} - ${msg}, processing aborted" || ciop-log "INFO" "${msg}"
#  rm -rf $TMPDIR	
  exit ${retval}
}
trap cleanExit EXIT

set_env() {
  export SAR_HELPERS_HOME=/opt/sar-helpers/lib/
  . ${SAR_HELPERS_HOME}/sar-helpers.sh
  
  export ADORESCR=/opt/adore/scr
  export PATH=/usr/local/bin:/opt/adore/scr:${PATH}

  # shorter temp path 
  export TMPDIR=/tmp/$( uuidgen )
  mkdir -p ${TMPDIR}/process
  return $?
}

set_app_pars() {
  settings="$( ciop-getparam settings )"
  [ ! -z "${settings}" ] && echo "${settings}" \
    | tr "," "\n" \
    | sed 's/^/settings apply -r -q /' > ${TMPDIR}/process/settings.app
}

get_data() {
  local ref=$1
  local target=$2
  local local_file
  local res
  local_file="`echo ${ref} | ciop-copy -U -O ${target} -`"
  res=$?

  [ $res -ne 0 ] && return $res
  echo ${local_file}
}

main() {
  # creates the adore directory structure
  ciop-log "INFO" "creating the directory structure"
  set_env

  ciop-log "INFO" "Additional settings for adore"
  set_app_pars

  master_ref="$( ciop-getparam master )"
  slave_ref="$( cat )"

  ciop-log "INFO" "Retrieving master"  
  master=$( get_data ${master_ref} ${TMPDIR} )
  [ $? -ne 0 ] && return ${ERR_MASTER}

  ciop-log "INFO" "Retrieving slave"
  slave=$( get_data ${slave_ref} ${TMPDIR} )
  [ $? -ne 0 ] && return ${ERR_SLAVE}

  ciop-log "INFO" "Create environment for Adore"
  create_env_adore ${master} ${slave} ${TMPDIR}/process
  [ $? -ne 0 ] && return ${ERR_EXTRACT}

  mission=$( get_mission $master | tr "A-Z" "a-z" )  

  ciop-log "INFO" "Launching adore for ${mission}"
  cd $TMPDIR/process
  adore "p ${_CIOP_APPLICATION_PATH}/adore/libexec/ifg.adr ${_CIOP_APPLICATION_PATH}/adore/etc/${mission}.steps ${mission}"
  [ $? -ne 0 ] && return ${ERR_ADORE}

  ciop-publish -m ${TMPDIR}/process/*.int
  [ $? -ne 0 ] && return ${ERR_PUBLISH_RES}

  ciop-publish -m ${TMPDIR}/process/adore.list

  ciop-publish -m ${TMPDIR}/process/*.png
  [ $? -ne 0 ] && return ${ERR_PUBLISH_PNG}
  
  ciop-publish -m ${TMPDIR}/process/*.log
}

cat | main

[ $? -ne 0 ] && exit 55
 
ciop-log "INFO" "Done"
