# == Class: ceph
#
# Install ceph
#
# === Parameters
#
# [*mon*]
#   Install a monitor
#
# [*osd*]
#   Install osds
#
# [*rgw*]
#   Install an object gateway
#
# [*mds*]
#   Install a metadata server
#
# [*manage_repo*]
#   Whether this module should install custom repos
#
# [*repo_mirror*]
#   Local mirror to source the repo from
#
# [*repo_version*]
#   Ceph version to install the repo for
#
# [*package_ensure*]
#   Ceph version to install
#
# [*package_options*]
#   install_options for the Ceph package
#
# [*user*]
#   Username ceph runs as
#
# [*group*]
#   Group ceph runs as
#
# [*seltype*]
#   SELinux type for var data
#
# [*conf_merge*]
#   Ignore the value bound to ceph::conf and perform a
#   hiera_hash call to merge config fragments together
#
# [*conf*]
#   Hash of ceph config file
#
# [*mon_id*]
#   Human readable monitor name, defaults to hostname
#
# [*mon_key*]
#   mon. authentication key shared between monitors
#
# [*keys_merge*]
#   Ignore the value bound to ceph::keys and perform a
#   hiera_hash call to merge keys together
#
# [*keys*]
#   Hash of ceph::keyring resources to be created
#
# [*modules*]
#   List of manager modules to enable
#
# [*disks*]
#   Hash of osd resources to create
#
# [*prerequisites*]
#   List for packages required for operation
#
class ceph (
  # Install component
  Boolean $mon = false,
  Boolean $osd = false,
  Boolean $rgw = false,
  Boolean $mds = false,
  # Package management
  Boolean $manage_repo = true,
  String $repo_mirror = 'eu.ceph.com',
  String $repo_version = 'luminous',
  # Package management
  String $package_ensure = 'installed',
  String $package_options = 'undef',
  # User management
  String $user = 'ceph',
  String $group = 'ceph',
  # Security
  String $seltype = 'ceph_var_lib_t',
  # Global configuration
  Boolean $conf_merge = false,
  Ceph::Conf $conf = {
    'global'                => {
      'fsid'                      => '62ed9bd6-adf4-11e4-8fb5-3c970ebb2b86',
      'mon_initial_members'       => 'mon0',
      'mon_host'                  => '127.0.0.1',
      'public_network'            => '127.0.0.0/8',
      'cluster_network'           => '127.0.0.0/8',
      'auth_supported'            => 'cephx',
      'filestore_xattr_use_omap'  => true,
      'osd_crush_chooseleaf_type' => 0,
    },
    'mgr'                   => {
      'mgr modules' => 'dashboard',
    },
    'osd'                   => {
      'osd_journal_size' => 100,
    },
    'client.rgw.puppet'     => {
      'rgw frontends' => '"civetweb port=7480"'
    },
  },
  Ceph::ConfigKeys $config_keys = {
    'mgr/dashboard/server_addr' => '0.0.0.0',
    'mgr/dashboard/server_port' => 7000,
  },
  # Monitor configuration
  String $mon_id = $::hostname,
  String $mon_key = 'AQA7yNlUMy3sFhAA62XHf57L0QhSI44qqqOVXA==',
  # Key management
  Boolean $keys_merge = false,
  Ceph::Keys $keys = {
    'client.admin'         => {
      'key'  => 'AQBAyNlUmO09CxAA2u2p6s38wKkBXaLWFeD7bA==',
      'caps' => {
        'mon' => 'allow *',
        'osd' => 'allow *',
        'mds' => 'allow',
        'mgr' => 'allow *',
      },
      'path'     => '/etc/ceph/ceph.client.admin.keyring',
    },
    'client.bootstrap-mgr' => {
      'key'  => 'AQC82ppZVlWnABAAPCihMcu7yoTtyjGiCwycDA==',
      'caps' => {
        'mon' => 'allow profile bootstrap-mgr',
      },
      'path' => '/var/lib/ceph/bootstrap-mgr/ceph.keyring',
    },
    'client.bootstrap-rgw' => {
      'key'  => 'AQD+zXZVDljeKRAAKA30V/QvzbI9oUtcxAchog==',
      'caps' => {
        'mon' => 'allow profile bootstrap-rgw',
      },
      'path' => '/var/lib/ceph/bootstrap-rgw/ceph.keyring',
    },
    'client.bootstrap-osd' => {
      'key'  => 'AQDLGtpUdYopJxAAnUZHBu0zuI0IEVKTrzmaGg==',
      'caps' => {
        'mon' => 'allow profile bootstrap-osd',
      },
      'path' => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
    },
    'client.bootstrap-mds' => {
      'key'  => 'AQDLGtpUlWDNMRAAVyjXjppZXkEmULAl93MbHQ==',
      'caps' => {
        'mon' => 'allow profile bootstrap-mds',
      },
      'path' => '/var/lib/ceph/bootstrap-mds/ceph.keyring',
    },
  },
  # MGR management
  Ceph::Modules $modules = [
    'status',
    'dashboard',
    'restful',
  ],
  # OSD management
  Ceph::Disks $disks = {
    '2:0:0:0' => {
      'journal' => '5:0:0:0',
      'params'  => {
        'fs-type' => 'xfs',
      },
    },
    '3:0:0:0' => {
      'journal' => '5:0:0:0',
      'params'  => {
        'fs-type' => 'xfs',
      },
    },
    '4:0:0:0' => {
      'journal' => '5:0:0:0',
      'params'  => {
        'fs-type' => 'xfs',
      },
    },
  },
  # RGW management
  Ceph::RgwID $rgw_id = "rgw.${::hostname}",
  # MDS management
  String $mds_id = $::hostname,
  # Parameters
  String $radosgw_package = $::ceph::params::radosgw_package,
  Ceph::Packages $prerequisites = $::ceph::params::prerequisites,
) inherits ceph::params {

  contain ::ceph::repo
  contain ::ceph::install
  contain ::ceph::config
  contain ::ceph::service
  contain ::ceph::mon
  contain ::ceph::auth
  contain ::ceph::configkeys
  contain ::ceph::mgr
  contain ::ceph::osd
  contain ::ceph::rgw
  contain ::ceph::mds

  Class['::ceph::repo'] ->
  Class['::ceph::install'] ->
  Class['::ceph::config'] ->
  Class['::ceph::service'] ->
  Class['::ceph::mon'] ->
  Class['::ceph::auth'] ->
  Class['::ceph::configkeys'] ->
  Class['::ceph::mgr'] ->
  Class['::ceph::osd'] ->
  Class['::ceph::rgw'] ->
  Class['::ceph::mds']

}
