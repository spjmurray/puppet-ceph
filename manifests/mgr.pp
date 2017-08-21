# == Class: ceph::mgr
#
# Manages the installation of a ceph manager on a monitor node
#
class ceph::mgr {

  assert_private()

  if $::ceph::mon {

    File {
      owner   => $::ceph::user,
      group   => $::ceph::group,
      seltype => $::ceph::seltype,
    }

    file { [
      '/var/lib/ceph/mgr',
      "/var/lib/ceph/mgr/ceph-${::ceph::mon_id}",
    ]:
      ensure => directory,
      mode   => '0755',
    } ->

    exec { 'mgr keyring create':
      command => "/usr/bin/ceph --name client.bootstrap-mgr --keyring /var/lib/ceph/bootstrap-mgr/ceph.keyring auth get-or-create mgr.${::ceph::mon_id} mon 'allow profile mgr' osd 'allow *' mds 'allow *' -o /var/lib/ceph/mgr/ceph-${::ceph::mon_id}/keyring",
      creates => "/var/lib/ceph/mgr/ceph-${::ceph::mon_id}/keyring",
      user    => $::ceph::user,
    } ->

    service { 'ceph-mgr.target':
      ensure => running,
      enable => true,
    } ->

    service { "ceph-mgr@${::ceph::mon_id}":
      ensure => running,
      enable => true,
    }

    $::ceph::modules.each |$module| {
      Service["ceph-mgr@${::ceph::mon_id}"] ->

      exec { "mgr module enable ${module}":
        command => "/usr/bin/ceph mgr module enable ${module}",
        unless  => "/usr/bin/ceph mgr module ls | grep -w ${module}",
      }
    }

  }

}
