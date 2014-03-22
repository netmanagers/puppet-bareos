require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'bareos::storage' do

  let(:title) { 'bareos::storage' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) do
    {
      :operatingsystem => 'Debian',
      :manage_storage => 'true',
      :ipaddress => '10.42.42.42',
      :service_autorestart => true
    }
  end
  describe 'Test standard Centos installation' do
    let(:facts) { {  :operatingsystem => 'Centos' } } 
    it { should contain_package('bareos-storage').with_ensure('present') }
    it { should contain_file('bareos-sd.conf').with_ensure('present') }
    it { should contain_file('bareos-sd.conf').with_path('/etc/bareos/bareos-sd.conf') }
    it { should contain_file('bareos-sd.conf').without_content }
    it { should contain_file('bareos-sd.conf').without_source }
    it { should contain_service('bareos-sd').with_ensure('running') }
    it { should contain_service('bareos-sd').with_enable('true') }
  end

  describe 'Test standard Debian installation' do
    let(:facts) { {  :operatingsystem => 'Debian' } }
    it { should contain_package('bareos-storage').with_ensure('present') }
  end

  describe 'Test service autorestart' do
    it 'should automatically restart the service, by default' do
      should contain_file('bareos-sd.conf').with_notify('Service[bareos-sd]')
    end
  end

  describe 'Test customizations - provide source' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_storage_source  => 'puppet:///modules/bareos/bareos.source'
      }
    end
    it { should contain_file('bareos-sd.conf').with_path('/etc/bareos/bareos-sd.conf') }
    it { should contain_file('bareos-sd.conf').with_source('puppet:///modules/bareos/bareos.source') }
  end

  describe 'Test customizations - default_password' do
    let(:facts) do
      {
        :operatingsystem => 'CentOS',
        :bareos_storage_name => 'storage_master',
        :bareos_default_password => 'master_pass',
        :bareos_storage_template => 'bareos/bareos-sd.conf.erb'
      }
    end
    it { should contain_file('bareos-sd.conf').with_content(/Password = "master_pass".*Password = "master_pass"/m) }
  end

  describe 'Test customizations - provided template' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_storage_name => 'here_storage',
        :bareos_default_password => 'stuvwxyz',
        :bareos_storage_password => 'storage_pass',
        :bareos_storage_port => '4242',
        :bareos_storage_address => '10.42.42.42',
        :bareos_storage_template => 'bareos/bareos-sd.conf.erb',
        :bareos_heartbeat_interval => 'some interval'
      }
    end
    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

# Note: use external director address for clients to connect.
Storage {
  Name = "here_storage"
  SDAddress = 10.42.42.42
  SDPort = 4242
  WorkingDirectory = /var/lib/bareos
  Maximum Concurrent Jobs = 30
  Heartbeat Interval = some interval
}

# Director who is permitted to contact this Storage daemon.
Director {
  Name = "rspec.example42.com-dir"
  Password = "storage_pass"
}

# Storage devices.
# Read storage directory for config files. Remember to bconsole "reload" after adding a client.
@|"sh -c \'cat /etc/bareos/storage.d/*.conf\'"

# Restricted Director, used by tray-monitor for Storage daemon status.
Director {
  Name = "rspec.example42.com-mon"
  Password = "stuvwxyz"
  Monitor = Yes
}

Messages {
  Name = "standard"
  Director = rspec.example42.com-dir = all, !skipped, !restored
}
'
    end
    it 'should create a valid config file' do
      should contain_file('bareos-sd.conf').with_content(expected)
    end
  end

  describe 'Test customizations - custom template' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_storage_template => 'bareos/spec.erb',
        :options => { 'opt_a' => 'value_a' }
      }
    end
    it { should contain_file('bareos-sd.conf').without_source }
    it 'should generate a valid template' do
      should contain_file('bareos-sd.conf').with_content(/fqdn: rspec.example42.com/)
    end
    it 'should generate a template that uses custom options' do
      should contain_file('bareos-sd.conf').with_content(/value_a/)
    end
  end


  describe 'Test Centos decommissioning - absent' do
    let(:facts) do
      { 
        :operatingsystem => 'CentOS',
        :bareos_absent => true,
        :bareos_monitor_target => '10.42.42.42',
        :storage_pid_file =>  'some.pid.file',
        :operatingsystem => 'Centos',
        :monitor => true
      }
    end
    it 'should remove Package[bareos-storage]' do should contain_package('bareos-storage').with_ensure('absent') end
    it 'should stop Service[bareos-sd]' do should contain_service('bareos-sd').with_ensure('stopped') end
    it 'should not enable at boot Service[bareos-sd]' do should contain_service('bareos-sd').with_enable('false') end
  end

  describe 'Test Debian decommissioning - absent' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_absent => true,
        :bareos_monitor_target => '10.42.42.42',
        :storage_pid_file =>  'some.pid.file',
        :operatingsystem => 'Debian',
        :monitor => true
      }
    end
    it 'should remove Package[bareos-storage]' do should contain_package('bareos-storage').with_ensure('absent') end
    it 'should stop Service[bareos-sd]' do should contain_service('bareos-sd').with_ensure('stopped') end
    it 'should not enable at boot Service[bareos-sd]' do should contain_service('bareos-sd').with_enable('false') end
  end

  describe 'Test decommissioning - disable' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_disable => true,
        :bareos_monitor_target => '10.42.42.42',
        :storage_pid_file =>  'some.pid.file',
        :monitor => true
      }
    end
    it { should contain_package('bareos-storage').with_ensure('present') }
    it 'should stop Service[bareos-sd]' do should contain_service('bareos-sd').with_ensure('stopped') end
    it 'should not enable at boot Service[bareos-sd]' do should contain_service('bareos-sd').with_enable('false') end
  end

  describe 'Test decommissioning - disableboot' do
    let(:facts) do
      { 
        :operatingsystem => 'Debian',
        :bareos_disableboot => true,
        :bareos_monitor_target => '10.42.42.42',
        :storage_pid_file =>  'some.pid.file',
        :monitor => true 
      }
    end
    it { should contain_package('bareos-storage').with_ensure('present') }
    it { should_not contain_service('bareos-sd').with_ensure('present') }
    it { should_not contain_service('bareos-sd').with_ensure('absent') }
    it 'should not enable at boot Service[bareos-sd]' do should contain_service('bareos-sd').with_enable('false') end
    it { should contain_monitor__process('bareos_storage_process').with_enable('false') }
  end

  describe 'Test noops mode' do
    let(:facts) do
      { 
        :operatingsystem => 'Debian',
        :bareos_noops => true,
        :bareos_monitor_target => '10.42.42.42',
        :storage_pid_file =>  'some.pid.file',
        :monitor => true 
      }
    end
    it { should contain_package('bareos-storage').with_noop('true') }
    it { should contain_service('bareos-sd').with_noop('true') }
    it { should contain_monitor__process('bareos_storage_process').with_noop('true') }
    it { should contain_monitor__process('bareos_storage_process').with_noop('true') }
  end
end
