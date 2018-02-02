# == Class: ceph::install
#
class ceph::install {

  assert_private()

  package { 'ceph':
    ensure          => $::ceph::package_ensure,
    install_options => $::ceph::package_options,
  }

  if $::facts['os']['name'] == 'Ubuntu' {
    Package['ceph'] ~>

    # Oddly I've seen OSD udev rules not applying on Xenial which are
    # fixed with a reload
    exec { 'ceph::install udev reload':
      command     => '/bin/systemctl restart udev',
      refreshonly => true,
    }
  }

  ensure_packages($::ceph::prerequisites)
}
