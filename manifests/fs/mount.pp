# == Define: ceph::fs::mount
#
# Mounts a ceph file system at the specific mount point
#
# === Parameters
#
# [*ensure*]
#   Mountpoint state. Valid options: 'present', 'mounted', 'absent', and 'unmounted'. Default: 'mounted'.
#
# [*owner*]
#   Mountpoint owner. Default: 'root'.
#
# [*group*]
#   Mountpoint group. Default: 'root'.
#
# [*mode*]
#   Mountpoint permission mode. Default: '0755'.
#
# [*device*]
#   The device providing the mount. Default: 'conf=/etc/ceph/ceph.conf,id=admin,client_mountpoint=/'
#
# [*mountpoint*]
#   The local mount path for the mount. Default: '$title'.
#
# [*fstype*]
#   The mount type. Default: 'fuse.ceph'
#
# [*options*]
#   A single string containing options for the mount, as they would appear in '/etc/fstab'. Default: '_netdev,defaults'.
#
# [*dump*]
#   Whether to dump the mount. Default: '0'.
#
# [*pass*]
#   The pass in which the mount is checked. Default: '0'.
#
# [*remounts*]
#   Whether the mount can be remounted. Default: 'false'.
#
define ceph::fs::mount (
  $ensure     = 'mounted',
  $owner      = 'root',
  $group      = 'root',
  $mode       = '0755',
  $device     = 'conf=/etc/ceph/ceph.conf,id=admin,client_mountpoint=/',
  $mountpoint = $title,
  $fstype     = 'fuse.ceph',
  $options    = '_netdev,defaults',
  $dump       = '0',
  $pass       = '0',
  $remounts   = false) {

  include ::ceph::fs

  Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }

  # Create the mount point if it doesn't exist.
  #
  # If Fuse ever looses its connection to the
  # NameNode, it seems that the mount will be
  # left in a weird state.  When the NameNode
  # comes back online, the mount will be just fine.
  # However, during the period that the NameNode
  # is offline, puppet will fail if we were to
  # try to ensure => 'directory' on $mountpoint
  # as a File resource.  If we were to require
  # this as a File resource, puppet would never
  # attempt to remount after a NameNode failure,
  # because the File resource would fail until
  # the mount is remounted.
  #
  # We can't even use unless => "test -d ${mountpoint}"
  # in an exec, because that will fail too.
  # Instead, we parse the output of ls. :(
  #
  # Solution adapted from:
  # https://github.com/wikimedia/puppet-cdh/blob/master/manifests/hadoop/mount.pp

  exec { "ceph::mount::mkdir_${mountpoint}":
    command => "mkdir -p -m ${mode} ${mountpoint}",
    unless  => "ls $(dirname ${mountpoint}) 2> /dev/null | grep -q $(basename ${mountpoint})",
    user    => $owner,
    group   => $group,
  }

  mount { "ceph::mount::${mountpoint}":
    ensure   => $ensure,
    device   => $device,
    name     => $mountpoint,
    fstype   => $fstype,
    options  => $options,
    dump     => $dump,
    pass     => $pass,
    remounts => $remounts,
  }

  exec { "ceph::mount::fix_perms::${mountpoint}":
     command     => "chown ${owner}:${group} ${mountpoint} ; chmod ${mode} ${mountpoint}",
     refreshonly => true,
     user        => 'root',
     group       => 'root',
  }

  Package[$::ceph::fs::package_names] -> Mount["ceph::mount::${mountpoint}"]
  Exec["ceph::mount::mkdir_${mountpoint}"] -> Mount["ceph::mount::${mountpoint}"] ~> Exec["ceph::mount::fix_perms::${mountpoint}"]
}
