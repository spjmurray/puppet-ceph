# == Class: ceph::service
#
# Configure and global services
#
class ceph::service {

  service { 'ceph.target':
    ensure => running,
    enable => true,
  }

}
