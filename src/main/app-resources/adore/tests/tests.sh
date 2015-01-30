#!/bin/env bash
export ciop_job_include="tests/void.sh"
. ../run.sh "test" < /dev/null

setUp() {

  export old_path=$PATH

  export PATH=$(dirname $0)/bin:$PATH
  # load include to test
  export _ROOT=$(dirname $0)
  mkdir -p $_ROOT/runtime
  export _TEST=$_ROOT/runtime
  export _ARTIFACT=$_ROOT/artifacts
  export TMPDIR=$_TEST
}

tearDown() {

  [ -d $_TEST ] && rm -fr $_TEST
  export PATH=$old_path
}

test_set_app_pars_1() {
  
  export POI="POINT(0.0 0.0)"
  export EXTENT="2000,2000"
  export SETTINGS='cc_winsize="128 128",m_dbow_geo="37.755 14.995 12200 12200",rs_dbow_geo="37.755 14.995 12000 12000"'
  
  set_app_pars
  res=$(diff ${_TEST}/user.set ${_ARTIFACT}/1)
  assertEquals "" "$res"

}

test_set_app_pars_2() {

  export POI="POINT(0.0 0.0)"
  export EXTENT="2000,2000"
  export SETTINGS='cc_winsize="128 128"'

  set_app_pars
  res=$(diff ${_TEST}/user.set ${_ARTIFACT}/2)
  assertEquals "" "$res"

}

test_set_app_pars_3() {

  export POI="POINT(0.0 0.0)"
  export EXTENT="2000;;;;2000"
  export SETTINGS='cc_winsize="128 128"'

  out=$(set_app_pars)
  res=$?
  assertEquals "65" "$res"

}

test_set_app_pars_4() {

  export POI="POINT(0.0 0.0)"
  export EXTENT="-2000;2000"
  export SETTINGS='cc_winsize="128 128"'

  out=$(set_app_pars)
  res=$?
  assertEquals "65" "$res"

}

test_set_app_pars_5() {

  export POI=
  export EXTENT=
  export SETTINGS='cc_winsize="64 64"'

  set_app_pars
  res=$(diff ${_TEST}/user.set ${_ARTIFACT}/5)
  assertEquals "" "$res"

}

test_set_app_pars_6() {

  export POI=
  export EXTENT=
  export SETTINGS=

  set_app_pars
  res=$(diff ${_TEST}/user.set ${_ARTIFACT}/6)
  assertEquals "" "$res"

}

# load shunit2
. $SHUNIT2_HOME/shunit2
