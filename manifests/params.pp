# == Class: ceph::params
#
# Static platform differences
#
class ceph::params {

  case $::facts['os']['name'] {
    'Debian': {
      if versioncmp($::facts['os']['release']['major'], '8') >= 0 {
        $service_provider = 'systemd'
      } else {
        err('This module has not been tested against Debian wheezy')
      }
      $radosgw_package = 'radosgw'
      $prerequisites = []
     }
    'Ubuntu': {
      if versioncmp($::facts['os']['release']['full'], '16.04') >= 0 {
        $service_provider = 'systemd'
      } else {
        $service_provider = 'upstart'
      }
      $radosgw_package = 'radosgw'
      $prerequisites = []
    }
    'RedHat', 'Centos': {
      $service_provider = 'systemd'
      $radosgw_package = 'ceph-radosgw'
      $prerequisites = [
        'redhat-lsb-core',            # Broken on centos with 0.94.6
        'python-setuptools.noarch',   # Needed by /usr/bin/ceph-detect-init
      ]
    }
    default: {
      err('Unsupported operating system')
    }
  }

}
