# == Class: ceph::config
#
# Configures ceph via ceph.conf
#
class ceph::config {

  assert_private()

  if $::ceph::conf_merge {
    $_conf = hiera_hash('ceph::conf')
  } else {
    $_conf = $::ceph::conf
  }

  file { '/etc/ceph/':
    ensure  => directory,
    owner   => $::ceph::user,
    group   => $::ceph::group,
    mode    => '0775',
  }

  file { '/etc/ceph/ceph.conf':
    ensure  => file,
    owner   => $::ceph::user,
    group   => $::ceph::group,
    mode    => '0644',
    content => template('ceph/ceph.conf.erb'),
  }

}
