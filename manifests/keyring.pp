# == Define: ceph::keyring
#
# Installs a keyring to the specified location. If set on
# a monitor node the key will be injected into the auth
# database
#
# === Parameters
#
# [*name*]
#   User the key belongs to e.g. client.admin
#
# [*key*]
#   Key as generated by ceph-authtool (16 bytes, base 64 encoding)
#
# [*caps*]
#   Hash of component capabilities
#
# [*path*]
#   Absolute path of the keyring e.g. /etc/ceph/ceph.client.admin.keyring'
#
# [*owner*]
#   Keyring file owner
#
# [*group*]
#   Keyring file group
#
# [*mode*]
#   Keyring file mode
#
define ceph::keyring (
  $key,
  $caps = {},
  $path = undef,
  $owner = $::ceph::user,
  $group = $::ceph::group,
  $mode = '0644',
) {

  assert_private()

  $_content = template('ceph/keyring.erb')

  if $path {

    # Note: puppet appears to run matchpathcon before ceph is installed and breaks idempotency
    if $path =~ /^\/var\/lib\/ceph/ {
      File {
        seltype => $::ceph::seltype,
      }
    }

    file { $path:
      ensure  => file,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      content => $_content,
    }

  }

  if $ceph::mon {

    include ::ceph::mon

    $mon_name = 'mon.'
    $mon_key = "/var/lib/ceph/mon/ceph-${ceph::mon_id}/keyring"

    exec { "keyring inject ${name}":
      command => "/bin/echo '${_content}' | /usr/bin/ceph -n ${mon_name} -k ${mon_key} auth import -i -",
      unless  => "/usr/bin/ceph -n ${mon_name} -k ${mon_key} auth list | grep ${key}",
    }

  }

}
