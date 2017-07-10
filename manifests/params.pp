# == Class: ceph::params
#
# Static platform differences
#
class ceph::params {

  case $::facts['os']['name'] {
    'Ubuntu': {
      $radosgw_package = 'radosgw'
      $prerequisites = []
    }
    'RedHat', 'Centos': {
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
