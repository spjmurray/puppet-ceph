# == Class: ceph::fs
#
# Install FUSE (File system in USErspace) client for CephFS.
#
# === Parameters
#
# [*package_names*]
#   Ceph packages to install
#
# [*package_ensure*]
#   Ceph Fuse version to install
#
# [*mounts*]
#   Hash of ceph::fs::mount resources to be created
#
class ceph::fs (
  $package_names  = ['ceph-fs-common', 'ceph-fuse'],
  $package_ensure = 'installed',
  $mounts         = {}) {

  include ::ceph

  package { $package_names: ensure => $package_ensure, }

  create_resources('::ceph::fs::mount', $mounts)

  Class['::ceph'] -> Class['::ceph::fs']
}
