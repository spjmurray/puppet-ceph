# == Class: ceph::mon
#
# Installs a ceph monitor on the host
# 
class ceph::mon {

  assert_private()

  if $::ceph::mon {

    File {
      owner   => $::ceph::user,
      group   => $::ceph::group,
      seltype => $::ceph::seltype,
    }

    # Create the monitor filesystem
    exec { 'mon create':
      command => "/usr/bin/ceph-mon --mkfs -i ${::ceph::mon_id} --key ${::ceph::mon_key}",
      creates => "/var/lib/ceph/mon/ceph-${::ceph::mon_id}",
      user    => $::ceph::user,
      group   => $::ceph::group,
    } ->

    # Enable managament by init/upstart
    file { "/var/lib/ceph/mon/ceph-${::ceph::mon_id}/done":
      ensure => file,
      mode   => '0644',
    } ->

    # Prevent ceph-create-keys from adding in defaults on monitor startup
    exec { 'mon inhibit create client.admin':
      command => '/usr/bin/touch /etc/ceph/ceph.client.admin.keyring',
      creates => '/etc/ceph/ceph.client.admin.keyring',
    } ->
    exec { 'mon inhibit create client.bootstrap-osd':
      command => '/usr/bin/touch /var/lib/ceph/bootstrap-osd/ceph.keyring',
      creates => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
    } ->
    exec { 'mon inhibit create client.bootstrap-mds':
      command => '/usr/bin/touch /var/lib/ceph/bootstrap-mds/ceph.keyring',
      creates => '/var/lib/ceph/bootstrap-mds/ceph.keyring',
    } ->
    exec { 'mon inhibit create client.bootstrap-rgw':
      command => '/usr/bin/touch /var/lib/ceph/bootstrap-rgw/ceph.keyring',
      creates => '/var/lib/ceph/bootstrap-rgw/ceph.keyring',
    } ->

    Exec['mon service start']

    exec { 'mon target enable':
      command => '/bin/systemctl enable ceph-mon.target',
      unless  => '/bin/systemctl is-enabled ceph-mon.target',
    } ->

    exec { 'mon service enable':
      command => "/bin/systemctl enable ceph-mon@${::ceph::mon_id}",
      unless  => "/bin/systemctl is-enabled ceph-mon@${::ceph::mon_id}",
    } ->

    exec { 'mon service start':
      command => "/bin/systemctl start ceph-mon@${::ceph::mon_id}",
      unless  => "/bin/systemctl status ceph-mon@${::ceph::mon_id}",
    }

  }

}
