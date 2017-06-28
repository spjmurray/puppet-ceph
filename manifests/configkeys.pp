# == Class: cepg::configkeys
#
# Injects config keys into the system based on a hash of key/value pairs
#
class ceph::configkeys {

  assert_private()

  $::ceph::config_keys.each |$key, $value| {
    ceph::configkey { $key:
      value => $value,
    }
  }

}
