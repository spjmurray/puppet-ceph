# == Class: ceph::configkeys
#
# Configures ceph via ceph config-key
#
class ceph::configkeys {

  assert_private()

  if $::ceph::configkeys_merge {
    $_configkeys = hiera_hash('ceph::configkeys')
  } else {
    $_configkeys = $::ceph::configkeys
  }

  $_configkeys.each |String $key, String $value| {
    exec {"config-key put $key":
      command => "/usr/bin/ceph config-key put ${key} ${value}",
    }
  }

}
