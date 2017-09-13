require 'spec_helper'

CONF = <<EOS.gsub(/^\s+\|/, '')
  |[main]
  |  fsid = 12345
  |[osd]
  |  osd_journal_size = 12345
EOS

KEY = <<EOS.gsub(/^\s+\|/, '')
  |[client.admin]
  |  key = AQBAyNlUmO09CxAA2u2p6s38wKkBXaLWFeD7bA==
  |  caps mds = "allow"
  |  caps mon = "allow *"
  |  caps osd = "allow *"
EOS

describe 'ceph', :type => :class do
  let :params do
    {
      :mon => true,
      :osd => true,
      :rgw => true,
      :mds => true,
      :mon_id => 'test',
      :mon_key => 'monkey',
      :rgw_id => 'rgw.test',
      :mds_id => 'test',
      :manage_repo => true,
      :repo_mirror => 'eu.ceph.com',
      :repo_version => 'jewel',
      :package_ensure => '10.2.3',
      :conf => {
        'main' => {
          'fsid' => '12345'
        },
        'osd' => {
          'osd_journal_size' => 12_345
        }
      },
      :user => 'mickey',
      :group => 'mouse',
      :disks => {
        'defaults' => {
          'params' => {
            'fs-type'   => 'xfs',
            'bluestore' => :undef
          }
        },
        '2:0:0:0' => {
          'journal' => '/dev/nvme0n1'
        },
        'Slot 01' => {
          'journal' => 'DISK00'
        }
      },
      :keys => {
        'client.admin' => {
          'key'  => 'AQBAyNlUmO09CxAA2u2p6s38wKkBXaLWFeD7bA==',
          'caps' => {
            'mon' => 'allow *',
            'osd' => 'allow *',
            'mds' => 'allow'
          },
          'path' => '/etc/ceph/ceph.client.admin.keyring'
        }
      },
      :config_keys => {
        'kermit' => 'frog'
      }
    }
  end

  context 'on an ubuntu xenial system' do
    let :facts do
      {
        :osfamily => 'Debian',
        :os => {
          :family => 'Debian',
          :name => 'Ubuntu',
          :release => {
            :full => '16.04'
          },
          :distro => {
            :codename => 'xenial'
          }
        }
      }
    end

    context 'ceph' do
      it 'compiles and all dependencies are satisfied' do
        is_expected.to compile.with_all_deps
      end

      it 'imports params' do
        is_expected.to contain_class('ceph::params')
      end

      it 'creates the repository before installing packages' do
        is_expected.to contain_class('ceph::repo').that_comes_before('Class[ceph::install]')
      end

      it 'installs the packages before configuring e.g. creates /etc/ceph' do
        is_expected.to contain_class('ceph::install').that_comes_before('Class[ceph::config]')
      end

      it 'configures ceph before installing a monitor' do
        is_expected.to contain_class('ceph::config').that_comes_before('Class[ceph::mon]')
      end

      it 'configures ceph before installing an osd' do
        is_expected.to contain_class('ceph::config').that_comes_before('Class[ceph::osd]')
      end

      it 'configures ceph before installing a rgw ' do
        is_expected.to contain_class('ceph::config').that_comes_before('Class[ceph::rgw]')
      end

      it 'configures ceph before installing a mds' do
        is_expected.to contain_class('ceph::config').that_comes_before('Class[ceph::mds]')
      end

      it 'configures ceph before installing a mgr' do
        is_expected.to contain_class('ceph::config').that_comes_before('Class[ceph::mgr]')
      end

      it 'configures systemd to enable the ceph target' do
        is_expected.to contain_class('ceph::service')
      end

      it 'configures a monitor before installing keys' do
        is_expected.to contain_class('ceph::mon').that_comes_before('Class[ceph::auth]')
      end

      it 'configures a monitor before configuring config-keys' do
        is_expected.to contain_class('ceph::mon').that_comes_before('Class[ceph::configkeys]')
      end

      it 'configures config-keys before configuring a mgr' do
        is_expected.to contain_class('ceph::configkeys').that_comes_before('Class[ceph::mgr]')
      end

      it 'installs the manager before installing an osd' do
        is_expected.to contain_class('ceph::mgr').that_comes_before('Class[ceph::osd]')
      end

      it 'installs the manager before installing a rgw' do
        is_expected.to contain_class('ceph::mgr').that_comes_before('Class[ceph::rgw]')
      end

      it 'installs the manager before installing a mds' do
        is_expected.to contain_class('ceph::mgr').that_comes_before('Class[ceph::mds]')
      end

      it 'installs bootstrap keys before installing an osd' do
        is_expected.to contain_class('ceph::auth').that_comes_before('Class[ceph::osd]')
      end

      it 'installs bootstrap keys before installing a rgw' do
        is_expected.to contain_class('ceph::auth').that_comes_before('Class[ceph::rgw]')
      end

      it 'installs bootstrap keys before installing a mds' do
        is_expected.to contain_class('ceph::auth').that_comes_before('Class[ceph::mds]')
      end

      it 'installs osds before installing a rgw' do
        is_expected.to contain_class('ceph::osd').that_comes_before('Class[ceph::rgw]')
      end

      it 'installs osds before installing a mds' do
        is_expected.to contain_class('ceph::osd').that_comes_before('Class[ceph::mds]')
      end

      it 'installs a rgw' do
        is_expected.to contain_class('ceph::rgw')
      end

      it 'installs a mds' do
        is_expected.to contain_class('ceph::mds')
      end
    end

    context 'ceph::repo' do
      it 'contains a source repository with the correct parameters' do
        is_expected.to contain_apt__source('ceph').with(
          'location' => 'http://eu.ceph.com/debian-jewel',
          'release' => 'xenial'
        )
      end

      it 'contains a pin to override the OS defaults, cloud archive etc' do
        is_expected.to contain_apt__pin('ceph').with(
          'packages' => '*',
          'origin' => 'eu.ceph.com',
          'priority' => '600'
        )
      end

      it 'contains a dependency between apt updating and the ceph package installing' do
        is_expected.to contain_class('apt').that_comes_before('Package[ceph]')
      end
    end

    context 'ceph::install' do
      it 'contains the ceph package with the version specified' do
        is_expected.to contain_package('ceph').with('ensure' => '10.2.3')
      end

      it 'reloads udev on a systemd system' do
        is_expected.to contain_exec('ceph::install udev reload').with(
          'command' => '/bin/systemctl restart udev',
          'refreshonly' => 'true'
        ).that_subscribes_to('Package[ceph]')
      end
    end

    context 'ceph::config' do
      it 'contains ceph configuration correctly formatted for the input' do
        is_expected.to contain_file('/etc/ceph/ceph.conf').with(
          'owner' => 'mickey',
          'group' => 'mouse',
          'mode' => '0644',
          'content' => CONF
        )
      end
    end

    context 'ceph::service' do
      it 'enables the ceph target on a systemd system' do
        is_expected.to contain_service('ceph.target').with(
          'ensure' => 'running',
          'enable' => true
        )
      end
    end

    context 'ceph::mon' do
      it 'creates the monitor as the ceph user' do
        is_expected.to contain_exec('mon create').with(
          'command' => '/usr/bin/ceph-mon --mkfs -i test --key monkey',
          'creates' => '/var/lib/ceph/mon/ceph-test',
          'user' => 'mickey',
          'group' => 'mouse'
        )
      end

      it 'creates the monitor before starting the service' do
        is_expected.to contain_exec('mon create').that_comes_before('Service[ceph-mon@test]')
      end

      it 'creates the monitor before creating the init flags' do
        is_expected.to contain_exec('mon create').that_comes_before('File[/var/lib/ceph/mon/ceph-test/done]')
      end

      it 'creates a monitor done file' do
        is_expected.to contain_file('/var/lib/ceph/mon/ceph-test/done').with(
          'owner' => 'mickey',
          'group' => 'mouse',
          'mode' => '0644'
        ).that_comes_before('Service[ceph-mon@test]')
      end

      it 'creates client.admin keyring to stop ceph-create-keys from injecting new values' do
        is_expected.to contain_exec('mon inhibit create client.admin').with(
          'command' => '/usr/bin/touch /etc/ceph/ceph.client.admin.keyring',
          'creates' => '/etc/ceph/ceph.client.admin.keyring'
        ).that_comes_before('Service[ceph-mon@test]')
      end

      it 'creates client.bootstrap-osd keyring to stop ceph-create-keys from injecting new values' do
        is_expected.to contain_exec('mon inhibit create client.bootstrap-osd').with(
          'command' => '/usr/bin/touch /var/lib/ceph/bootstrap-osd/ceph.keyring',
          'creates' => '/var/lib/ceph/bootstrap-osd/ceph.keyring'
        ).that_comes_before('Service[ceph-mon@test]')
      end

      it 'creates client.bootstrap-mds keyring to stop ceph-create-keys from injecting new values' do
        is_expected.to contain_exec('mon inhibit create client.bootstrap-mds').with(
          'command' => '/usr/bin/touch /var/lib/ceph/bootstrap-mds/ceph.keyring',
          'creates' => '/var/lib/ceph/bootstrap-mds/ceph.keyring'
        ).that_comes_before('Service[ceph-mon@test]')
      end

      it 'creates client.bootstrap-rgw keyring to stop ceph-create-keys from injecting new values' do
        is_expected.to contain_exec('mon inhibit create client.bootstrap-rgw').with(
          'command' => '/usr/bin/touch /var/lib/ceph/bootstrap-rgw/ceph.keyring',
          'creates' => '/var/lib/ceph/bootstrap-rgw/ceph.keyring'
        ).that_comes_before('Service[ceph-mon@test]')
      end

      it 'enables and starts the target on a systemd system' do
        is_expected.to contain_service('ceph-mon.target').with(
          'ensure' => 'running',
          'enable' => true
        ).that_comes_before('Service[ceph-mon@test]')
      end

      it 'enables and starts the service on a systemd system' do
        is_expected.to contain_service('ceph-mon@test').with(
          'ensure' => 'running',
          'enable' => true
        )
      end
    end

    context 'ceph::auth' do
      it 'populates keyrings correctly' do
        is_expected.to contain_ceph__keyring('client.admin').with(
          'key'  => 'AQBAyNlUmO09CxAA2u2p6s38wKkBXaLWFeD7bA==',
          'caps' => {
            'mon' => 'allow *',
            'osd' => 'allow *',
            'mds' => 'allow'
          },
          'path' => '/etc/ceph/ceph.client.admin.keyring'
        )
      end
    end

    context 'ceph::keyring' do
      it 'creates the keyring' do
        is_expected.to contain_file('/etc/ceph/ceph.client.admin.keyring').with(
          'owner' => 'mickey',
          'group' => 'mouse',
          'mode' => '0644',
          'content' => KEY
        )
      end

      it 'injects the keyring on a monitor' do
        is_expected.to contain_exec('keyring inject client.admin').with(
          'command' => "/bin/echo '#{KEY}' | /usr/bin/ceph -n mon. -k /var/lib/ceph/mon/ceph-test/keyring auth import -i -",
          'unless' => '/usr/bin/ceph -n mon. -k /var/lib/ceph/mon/ceph-test/keyring auth list | grep AQBAyNlUmO09CxAA2u2p6s38wKkBXaLWFeD7bA=='
        )
      end
    end

    context 'ceph::osd' do
      it 'populates osds correctly' do
        is_expected.to contain_osd('2:0:0:0').with(
          'journal' => '/dev/nvme0n1',
          'params' => {
            'fs-type' => 'xfs',
            'bluestore' => :undef
          }
        )

        is_expected.to contain_osd('Slot 01').with(
          'journal' => 'DISK00',
          'params' => {
            'fs-type' => 'xfs',
            'bluestore' => :undef
          }
        )
      end
    end

    context 'ceph::rgw' do
      it 'contains the rgw package with the correct version before starting the service' do
        is_expected.to contain_package('radosgw').with(
          'ensure' => '10.2.3'
        ).that_comes_before('Service[ceph-radosgw@rgw.test]')
      end

      it 'creates the rgw directory' do
        is_expected.to contain_file('/var/lib/ceph/radosgw').with(
          'ensure' => 'directory',
          'owner' => 'mickey',
          'group' => 'mouse',
          'mode' => '0755'
        ).that_comes_before('File[/var/lib/ceph/radosgw/ceph-rgw.test]')
      end

      it 'creates the rgw instance directory' do
        is_expected.to contain_file('/var/lib/ceph/radosgw/ceph-rgw.test').with(
          'ensure' => 'directory',
          'owner' => 'mickey',
          'group' => 'mouse',
          'mode' => '0755'
        ).that_comes_before([
          'File[/var/lib/ceph/radosgw/ceph-rgw.test/done]',
          'Exec[rgw keyring create]'
        ])
      end

      it 'creates an rgw done file before stating the service' do
        is_expected.to contain_file('/var/lib/ceph/radosgw/ceph-rgw.test/done').that_comes_before('Service[ceph-radosgw@rgw.test]')
      end

      it 'creates the keyring before starting the service' do
        is_expected.to contain_exec('rgw keyring create').with(
          'command' => "/usr/bin/ceph --name client.bootstrap-rgw --keyring /var/lib/ceph/bootstrap-rgw/ceph.keyring auth get-or-create client.rgw.test mon 'allow rw' osd 'allow rwx' -o /var/lib/ceph/radosgw/ceph-rgw.test/keyring",
          'creates' => '/var/lib/ceph/radosgw/ceph-rgw.test/keyring',
          'user' => 'mickey'
        ).that_comes_before('Service[ceph-radosgw@rgw.test]')
      end

      it 'enables the target on a systemd system' do
        is_expected.to contain_service('ceph-radosgw.target').with(
          'ensure' => 'running',
          'enable' => true
        ).that_comes_before('Service[ceph-radosgw@rgw.test]')
      end

      it 'enables and starts the service' do
        is_expected.to contain_service('ceph-radosgw@rgw.test').with(
          'ensure' => 'running',
          'enable' => true
        )
      end
    end

    context 'ceph::mds' do
      it 'creates the mds directory' do
        is_expected.to contain_file('/var/lib/ceph/mds').with(
          'ensure' => 'directory',
          'owner' => 'mickey',
          'group' => 'mouse',
          'mode' => '0755'
        ).that_comes_before('File[/var/lib/ceph/mds/ceph-test]')
      end

      it 'creates the mds instance directory' do
        is_expected.to contain_file('/var/lib/ceph/mds/ceph-test').with(
          'ensure' => 'directory',
          'owner' => 'mickey',
          'group' => 'mouse',
          'mode' => '0755'
        ).that_comes_before([
          'File[/var/lib/ceph/mds/ceph-test/done]',
          'Exec[mds keyring create]'
        ])
      end

      it 'creates an mds done file before stating the service' do
        is_expected.to contain_file('/var/lib/ceph/mds/ceph-test/done').that_comes_before('Service[ceph-mds@test]')
      end

      it 'creates the keyring before starting the service' do
        is_expected.to contain_exec('mds keyring create').with(
          'command' => "/usr/bin/ceph --name client.bootstrap-mds --keyring /var/lib/ceph/bootstrap-mds/ceph.keyring auth get-or-create mds.test mon 'allow profile mds' osd 'allow rwx' mds allow -o /var/lib/ceph/mds/ceph-test/keyring",
          'creates' => '/var/lib/ceph/mds/ceph-test/keyring',
          'user' => 'mickey'
        ).that_comes_before('Service[ceph-mds@test]')
      end

      it 'enables the target on a systemd system' do
        is_expected.to contain_service('ceph-mds.target').with(
          'ensure' => 'running',
          'enable' => true
        ).that_comes_before('Service[ceph-mds@test]')
      end

      it 'enables and starts the service' do
        is_expected.to contain_service('ceph-mds@test').with(
          'ensure' => 'running',
          'enable' => true
        )
      end
    end

    context 'ceph::configkeys' do
      it 'creates config key' do
        is_expected.to contain_ceph__configkey('kermit').with(
          'value' => 'frog'
        )
      end
    end

    context 'ceph::configkey' do
      it 'creates or updates the key' do
        is_expected.to contain_exec('ceph::configkey kermit').with(
          'command' => '/usr/bin/ceph config-key put kermit frog',
          'unless'  => '/usr/bin/ceph config-key get kermit 2> /dev/null | grep ^frog$'
        ).that_notifies('Class[ceph::mgr]')
      end
    end

    context 'ceph::mgr' do
      it 'enables the target on a systemd system' do
        is_expected.to contain_service('ceph-mgr.target').with(
          'ensure' => 'running',
          'enable' => true
        ).that_comes_before('Service[ceph-mgr@test]')
      end

      it 'enables and starts the service' do
        is_expected.to contain_service('ceph-mgr@test').with(
          'ensure' => 'running',
          'enable' => true
        )
      end
    end
  end

  context 'on a centos 7 system' do
    let :facts do
      {
        :os => {
          :family => 'RedHat',
          :name => 'Centos'
        }
      }
    end

    context 'ceph' do
      it 'compiles and all dependencies are satisfied' do
        is_expected.to compile.with_all_deps
      end
    end

    context 'ceph::repo' do
      it 'installs a source repository with the correct parameters' do
        is_expected.to contain_yumrepo('ceph').with('baseurl' => 'http://download.ceph.com/rpm-jewel/el$releasever/x86_64')
      end
    end

    context 'ceph::install' do
      it 'installs prerequisite packages' do
        is_expected.to contain_package('python-setuptools.noarch')
        is_expected.to contain_package('redhat-lsb-core')
      end
    end

    context 'ceph::rgw' do
      it 'contains the rgw package with the correct version before starting the service' do
        is_expected.to contain_package('ceph-radosgw').with('ensure' => '10.2.3').that_comes_before('Service[ceph-radosgw@rgw.test]')
      end
    end
  end
end
