#!/bin/bash

mode=$1

# source the ciop functions (e.g. ciop-log)
[ "${mode}" != "test" ] && source ${ciop_job_include}

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
ERR_WRONG_POINT=60
ERR_WRONG_EXTENT=65
ERR_MISSION_MASTER=35
ERR_GETDATA=15

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
    ${ERR_MISSION_MASTER}) msg="Failed to retrieve mission from master";;
    ${ERR_TRACK}) msg="Master and slave have mismatching tracks";;
    ${ERR_ADORE}) msg="Failed during ADORE execution";;
    ${ERR_PUBLISH_RES}) msg="Failed results publish";;
    *|${ERR_UNKNOWN}) msg="Unknown error";;
  esac

  [ "${retval}" != "0" ] && ciop-log "ERROR" \
    "Error ${retval} - ${msg}, processing aborted" || ciop-log "INFO" "${msg}"
  [ -n "${TMPDIR}" ] && rm -rf ${TMPDIR}

  [ "${mode}" == "test" ] && return ${retval} || exit ${retval}

}
trap cleanExit EXIT

is_numeric() {
  re='^[0-9]+([.][0-9]+)?$'
  [[ $1 =~ ${re} ]] && return 0 || return 1
}

get_separator() {
  local sep
  sep=$( echo $1 | sed 's/[0-9]*//g' )
  [ ${#sep} -gt 1 ] && return 1 || echo $sep
}

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
  local x_extent
  local y_extent
  local mx_extent
  local my_extent
  local sx_extent
  local sy_extent
  local ext_settings
  local settings
  
  #set default values
  rs_dbow_geo="0 0 0 0"
  m_dbow_geo="0 0 0 0"
  s_dbow_geo="0 0 0 0"
  
  point="$( ciop-getparam poi )" 
  extent="$( ciop-getparam extent )"
  settings="$( ciop-getparam settings )"

  ciop-log "DEBUG" "checking user provided settings"
 
  [ -n "${settings}" ] && {
    ciop-log "DEBUG" "got settings"
    [ -z "$( echo "${settings}" | tr ',' '\n' | grep "_dbow_geo" )"  ] && {
      #checking point and extent were provided
      ciop-log "DEBUG" "got no dbow"
      [ -n "${point}" ] && [ -n "${extent}"  ] && {
        ciop-log "DEBUG" "point and extent provided [${point} ${extent}]"

        IFS=' ' read -r lon lat <<< $( echo "${point}" | sed "s#POINT(##" | sed "s/)//" )
    
        separator=$( get_separator "${extent}") 
        [ $? -eq 1 ] && return ${ERR_WRONG_EXTENT}

        IFS="$separator" read -r x_extent y_extent <<< "${extent}"

        ciop-log "DEBUG" "x_e ${x_extent}"
        ciop-log "DEBUG" "y_e ${y_extent}"
        is_numeric ${x_extent} || return ${ERR_WRONG_EXTENT}
        is_numeric ${y_extent} || return ${ERR_WRONG_EXTENT}       
 
        # checking lon lat consistency
        [ $( echo "${lon}>=-180" | bc -l ) -eq 1 ] && [ $( echo "${lon}<=180" | bc -l ) -eq 1 ] || return ${ERR_WRONG_POINT}
        [ $( echo "${lat}>=-90" | bc -l ) -eq 1 ] && [ $( echo "${lat}<=90" | bc -l ) -eq 1 ] || return ${ERR_WRONG_POINT}     

        mx_extent=$( printf %.$2f $( echo "scale=0; ${x_extent} * 1.1" | bc ))
        my_extent=$( printf %.$2f $( echo "scale=0; ${y_extent} * 1.1" | bc ))

        sx_extent=$( printf %.$2f $( echo "scale=0; ${x_extent} * 1.2" | bc ))
        sy_extent=$( printf %.$2f $( echo "scale=0; ${y_extent} * 1.2" | bc ))

        rs_dbow_geo="${lat} ${lon} ${x_extent} ${y_extent}"
        m_dbow_geo="${lat} ${lon} ${mx_extent} ${my_extent}"
        s_dbow_geo="${lat} ${lon} ${sx_extent} ${sy_extent}"

        ext_settings="rs_dbow_geo=\"${rs_dbow_geo}\",m_dbow_geo=\"${m_dbow_geo}\",s_dbow_geo=\"${s_dbow_geo}\","
      }  
    } 
    echo "${ext_settings}${settings}" \
      | tr "," "\n" \
      | sed 's/^/settings apply -r -q /' > ${TMPDIR}/user.set
  } || echo "rs_dbow_geo=\"${rs_dbow_geo}\",m_dbow_geo=\"${m_dbow_geo}\",s_dbow_geo=\"${s_dbow_geo}\"" \
        | tr "," "\n" \
        | sed 's/^/settings apply -r -q /' > ${TMPDIR}/user.set
    
}

get_data() {
  local ref=$1
  local target=$2
  local local_file
  local enclosure
  local res

  enclosure="$( opensearch-client -f atom -p do=terradue "${ref}" enclosure)"
  # opensearh client doesn't deal with local paths
  res=$?
  [ $res -eq 0 ] && [ -z "${enclosure}" ] && return ${ERR_GETDATA}
  [ $res -ne 0 ] && enclosure=${ref}
  
  enclosure=$(echo "${enclosure}" | tail -1)
  local_file="$( echo ${enclosure} | ciop-copy -f -U -O ${target} - 2> /dev/null )"
  res=$?

  [ ${res} -ne 0 ] && return ${res}
  echo ${local_file}
}

publish_result() {
  local extension="$1"
  local count

  count=$( ls -1 *.${extension} 2>/dev/null | wc -l )

  [ ${count} -ne 0 ] && { 
    cd $TMPDIR/..
    ciop-publish -b $TMPDIR/.. -m $( echo ${TMPDIR} | sed 's#.*/\(.*\)#\1#g' )/*.${extension}
    [ $? -ne 0 ] && return ${ERR_PUBLISH_RES}
  }
  cd $TMPDIR
  return 0
}

main() {
  local res
  # creates the adore directory structure
  ciop-log "INFO" "creating the directory structure"
  set_env

  master_ref="$( ciop-getparam master )"
  slave_ref="$1"

  ciop-log "INFO" "Retrieving master ${master_ref} ${TMPDIR}"  
  master=$( get_data ${master_ref} ${TMPDIR} )
  [ $? -ne 0 ] && return ${ERR_MASTER}

  ciop-log "INFO" "Retrieving slave"
  slave=$( get_data ${slave_ref} ${TMPDIR} )
  [ $? -ne 0 ] && return ${ERR_SLAVE}

  mission=$( get_mission $master | tr "A-Z" "a-z" )
  [ $? -ne 0 ] && return ${ERR_MISSION_MASTER}

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

  ciop-log "INFO" "Additional settings for adore"
  set_app_pars

  ciop-log "INFO" "Launching adore for ${mission}"
  cd $TMPDIR
  adore "p ${_CIOP_APPLICATION_PATH}/adore/libexec/ifg.adr ${_CIOP_APPLICATION_PATH}/adore/etc/${mission}.steps ${mission}"
  [ $? -ne 0 ] && return ${ERR_ADORE}


dirResVal=$(basename $TMPDIR)
hdfs dfs -mkdir -p ${nameNode}/ciop/run/${CIOP_WF_RUN_ID}/_results/${dirResVal}
hdfs dfs -chmod 777 ${nameNode}/ciop/run/${CIOP_WF_RUN_ID}/_results
hdfs dfs -chmod 777 ${nameNode}/ciop/run/${CIOP_WF_RUN_ID}/_results/${dirResVal}


  publish_result int || return $?
 
  publish_result png || return $?
  
  publish_result tiff || return $?

  publish_result log || return $?

  publish_result pars || return $?  
 
}

while read slave; do
  main "${slave}"
  res=$?
  [ ${res} -ne 0 ] && exit ${res}
done

[ "$mode" != "test" ] && exit 0
