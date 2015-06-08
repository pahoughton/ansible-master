#!/bin/bash
# 2015-06-05 (cc) <paul4hough@gmail.com>
#
[ -n "$DEBUG" ] && set -x
targs="$0 $@"
# cfg

function _fail {

  echo Ouch - $? - $@
  virsh shutdown $testname
  exit 1
}
#DoOrDie
function DoD {
  $@ || _fail $@
  echo " pass :)"
}

function Test {
  tname=$1;
  shift;
  echo -n testing: $tname
  DoD $@
}

Test simple true

echo $targs complete.
exit 0
