#!/bin/bash

# source the ciop functions (e.g. ciop-log)
source ${ciop_job_include}

# define the exit codes
SUCCESS=0
ERR_MASTER=10
ERR_SLAVE=20
ERR_EXTRACT=30
ERR_MISSION=31
ERR_TRACK=32
ERR_ADORE=40
ERR_PUBLISH_RES=50
ERR_UNKNOWN=55

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
    ${ERR_MISSION}) msg="Master and slave have mismatching missions";;
    ${ERR_TRACK}) msg="Master and slave have mismatching tracks";;
		${ERR_ADORE}) msg="Failed during ADORE execution";;
		${ERR_PUBLISH_RES}) msg="Failed results publish";;
		*|${ERR_UNKNOWN}) msg="Unknown error";;
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
  mkdir -p ${TMPDIR}
  return $?
}

set_app_pars() {
  settings="$( ciop-getparam settings )"
  [ ! -z "${settings}" ] && echo "${settings}" \
    | tr "," "\n" \
    | sed 's/^/settings apply -r -q /' > ${TMPDIR}/settings.app
}

get_data() {
  local ref=$1
  local target=$2
  local local_file
  local res
  local_file="`echo ${ref} | ciop-copy -f -U -O ${target} -`"
  res=$?

  [ $res -ne 0 ] && return $res
  echo ${local_file}
}

publish_result() {
  local extension="$1"
  local count

  count=$( ls -1 *.${extension} 2>/dev/null | wc -l )
  
  [ ${count} -ne 0 ] && { 
    ciop-publish -m ${TMPDIR}/*.${extension}
    [ $? -ne 0 ] && return ${ERR_PUBLISH_RES}
  }
  return 0
}

main() {
  local res
  # creates the adore directory structure
  ciop-log "INFO" "creating the directory structure"
  set_env

  ciop-log "INFO" "Additional settings for adore"
  set_app_pars

  master_ref="$( ciop-getparam master )"
  slave_ref="$1"

  ciop-log "INFO" "Retrieving master"  
  master=$( get_data ${master_ref} ${TMPDIR} )
  [ $? -ne 0 ] && return ${ERR_MASTER}

  ciop-log "INFO" "Retrieving slave"
  slave=$( get_data ${slave_ref} ${TMPDIR} )
  [ $? -ne 0 ] && return ${ERR_SLAVE}

  ciop-log "INFO" "Create environment for Adore"
  TMPDIR=$( create_env_adore ${master} ${slave} ${TMPDIR} )
  res=$?

  case $res in
    0) ciop-log "INFO" "Successfully created environment for Adore";;
    1) return ${ERR_MISSION};; 
    2) return ${ERR_TRACK};;
    3) return ${ERR_ADORE_ENV};;  
    *) return ${ERR_UNKNOWN};;
  esac

  mission=$( get_mission $master | tr "A-Z" "a-z" )  

  ciop-log "INFO" "Launching adore for ${mission}"
  cd $TMPDIR
  adore "p ${_CIOP_APPLICATION_PATH}/adore/libexec/ifg.adr ${_CIOP_APPLICATION_PATH}/adore/etc/${mission}.steps ${mission}"
  [ $? -ne 0 ] && return ${ERR_ADORE}

  publish_result int || return $?
 
  publish_result png || return $?
  
  publish_result tiff || return $?

  publish_result log || return $?

  # publish the settings 
  ciop-publish -m ${TMPDIR}/adore.list
 
}

cat | while read myslave; do
  main $myslave
  res=$?
  [ $res -ne 0 ] && exit $res
done

ciop-log "INFO" "Done"
