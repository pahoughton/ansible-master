#!/bin/bash
# 2015-06-01 (cc) <paul4hough@gmail.com>
#
# FIXME - need a lock step for renaming vm
#
[ -n "$DEBUG" ] && set -x
targs="$0 $@"
# cfg
testname=r7_jenkins_test
imgfn="`pwd`/r7test.qcow2"

function _fail {
  echo Ouch - $? - $@
  virsh shutdown $testname
  exit 1
}
#DoOrDie
function DoD {
  $@ || _fail $@
}

echo $imgfn
DoD cp /var/lib/libvirt/images/r7test-base.qcow2 "$imgfn"
DoD chmod +w "$imgfn"
sed -e "s~%imgfn%~$imgfn~g" r7test.xml.tmpl > r7test.xml
DoD virsh create r7test.xml
sleep 10
vgip=`awk -e '/r7jenkins/ {print $3}' /var/lib/libvirt/dnsmasq/default.leases`
echo $vgip
DoD cp ssh.config ~/.ssh/config
DoD chmod 600 ~/.ssh/config
echo $testname > hostname
DoD scp hostname root@$vgip:/etc/hostname
ssh root@$vgip shutdown -r now
sleep 10
DoD grep $testname /var/lib/libvirt/dnsmasq/default.leases > /dev/null
DoD scp guest.unittest.bash root@$vgip:
DoD ssh root@$vgip bash guest.unittest.bash
DoD virsh shutdown $testname
echo $targs complete.
exit 0
