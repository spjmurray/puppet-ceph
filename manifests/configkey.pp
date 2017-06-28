# == Define: ceph::configkey
#
# Injects config keys into the system if they don't already exist or have
# the wrong value
#
define ceph::configkey (
  $value,
) {

  assert_private()

  exec { "ceph::configkey ${name}":
    command => "/usr/bin/ceph config-key put ${name} ${value}",
    unless  => "/usr/bin/ceph config-key get ${name} 2> /dev/null | grep ^${value}\$",
  }

}
