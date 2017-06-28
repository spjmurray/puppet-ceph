# == Class: ceph::mgr
#
# Manages the installation of a ceph manager on a monitor node
#
class ceph::mgr {

  if $::ceph::mon {

    case $::ceph::service_provider {
      'systemd': {
        exec { 'mgr target enable':
          command => '/bin/systemctl enable ceph-mgr.target',
          unless  => '/bin/systemctl is-enabled ceph-mgr.target',
        } ->

        exec { 'mgr service enable':
          command => "/bin/systemctl enable ceph-mgr@${::ceph::mon_id}",
          unless  => "/bin/systemctl is-enabled ceph-mgr@${::ceph::mon_id}",
        } ~>

        # The monitor (via systemctl) will start the manager.  In order to configure
        # the manager we need the monitor, configuration and keys to be installed.
        # As a result to pickup config-keys we need to restart the manger once all
        # that has been done
        exec { 'mgr service start':
          command     => "/bin/systemctl restart ceph-mgr@${::ceph::mon_id}",
          refreshonly => true,
        }
      }
      default: {
        crit('Unsupported service provider')
      }
    }


  }

}
