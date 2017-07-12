# == Class: ceph::mgr
#
# Manages the installation of a ceph manager on a monitor node
#
class ceph::mgr {

  if $::ceph::mon {

    service { 'ceph-mgr.target':
      ensure => running,
      enable => true,
    } ->

    service { "ceph-mgr@${::ceph::mon_id}":
      ensure => running,
      enable => true,
    }

  }

}
