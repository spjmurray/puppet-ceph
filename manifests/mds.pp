# == Class: ceph::mds
#
# Install a ceph metadata server
#
class ceph::mds {

  assert_private()

  if $::ceph::mds {

    File {
      owner   => $::ceph::user,
      group   => $::ceph::group,
      seltype => $::ceph::seltype,
    }

    file { [
      '/var/lib/ceph/mds',
      "/var/lib/ceph/mds/ceph-${::ceph::mds_id}",
    ]:
      ensure => directory,
      mode   => '0755',
    } ->

    file { "/var/lib/ceph/mds/ceph-${::ceph::mds_id}/done":
      ensure => file,
      mode   => '0644',
    } ->

    exec { 'mds keyring create':
      command => "/usr/bin/ceph --name client.bootstrap-mds --keyring /var/lib/ceph/bootstrap-mds/ceph.keyring auth get-or-create mds.${::ceph::mds_id} mon 'allow profile mds' osd 'allow rwx' mds allow -o /var/lib/ceph/mds/ceph-${::ceph::mds_id}/keyring",
      creates => "/var/lib/ceph/mds/ceph-${::ceph::mds_id}/keyring",
      user    => $::ceph::user,
    } ->

    service { 'ceph-mds.target':
      ensure => running,
      enable => true,
    } ->

    service { "ceph-mds@${::ceph::mds_id}":
      ensure => running,
      enable => true,
    }

  }

}
