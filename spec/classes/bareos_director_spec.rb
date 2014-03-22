require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'bareos::director' do

  let(:title) { 'bareos::director' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) do
    {
      :manage_director => 'true',
      :operatingsystem => 'Debian',
      :ipaddress => '10.42.42.42'
    }
  end
  describe 'Test standard Centos installation' do
    it { should contain_package('bareos-director').with_ensure('present') }
    it { should contain_file('bareos-dir.conf').with_ensure('present') }
    it { should contain_file('bareos-dir.conf').with_path('/etc/bareos/bareos-dir.conf') }
    it { should contain_file('bareos-dir.conf').without_content }
    it { should contain_file('bareos-dir.conf').without_source }
    it { should contain_service('bareos-dir').with_ensure('running') }
    it { should contain_service('bareos-dir').with_enable('true') }
  end

  describe 'Test service autorestart' do
    it 'should automatically restart the service, by default' do
      should contain_file('bareos-dir.conf').with_notify('Service[bareos-dir]')
    end
  end

  describe 'Test customizations - provide source' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_director_source  => 'puppet:///modules/bareos/bareos.source'
      }
    end
    it { should contain_file('bareos-dir.conf').with_path('/etc/bareos/bareos-dir.conf') }
    it { should contain_file('bareos-dir.conf').with_source('puppet:///modules/bareos/bareos.source') }
  end

  describe 'Test customizations - default_password' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_director_name => 'master_director',
        :bareos_default_password => 'master_pass',
        :bareos_director_template => 'bareos/bareos-dir.conf.erb'
      }
    end
    it { should contain_file('bareos-dir.conf').with_content(/Password = "master_pass".*Password = "master_pass"/m) }
  end

  describe 'Test customizations - provided template - most parameters' do
    let(:facts) do
      {
        :operatingsystem => 'Centos',
        :bareos_director_name => 'here_director',
        :bareos_default_password => 'default_pass',
        :bareos_director_password => 'director_pass',
        :bareos_director_port => '4242',
        :bareos_director_address => '10.42.42.42',
        :bareos_director_template => 'bareos/bareos-dir.conf.erb'
      }
    end
    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

# Define the Director name, password used for authenticating the Console program.
Director {
  Name = "here_director"
  DirPort = 4242
  QueryFile = /etc/bareos/scripts/query.sql
  WorkingDirectory = /var/lib/bareos
  MaximumConcurrentJobs = 30
  Password = "director_pass"
  Messages = "standard"
  DirAddress = 10.42.42.42
  HeartbeatInterval = 1 minute
}

# Restricted Console, used by tray-monitor for Director status.
Console {
  Name = "rspec.example42.com-mon"
  Password = "default_pass"
  CommandACL = status, .status
}

# Include split config files. Remember to bconsole "reload" after modifying a config file.
@|"find /etc/bareos/director.d -name \'*.conf\' -type f -exec echo @{} \\;"

# Read client directory for config files. Remember to bconsole "reload" after adding a client.
@|"find /etc/bareos/clients.d -name \'*.conf\' -type f -exec echo @{} \\;"
'
    end
    it 'should create a valid config file' do
      should contain_file('bareos-dir.conf').with_content(expected)
    end
  end

  describe 'Test customizations - custom template' do
    let(:facts) do
      {
        :operatingsystem => 'Centos',
        :bareos_director_template => 'bareos/spec.erb',
        :options => { 'opt_a' => 'value_a' }
      }
    end
    it { should contain_file('bareos-dir.conf').without_source }
    it 'should generate a valid template' do
      should contain_file('bareos-dir.conf').with_content(/fqdn: rspec.example42.com/)
    end
    it 'should generate a template that uses custom options' do
      should contain_file('bareos-dir.conf').with_content(/value_a/)
    end
  end

  describe 'Test Centos decommissioning - absent' do
    let(:facts) { {:bareos_absent => true, :operatingsystem => 'Centos'} }
    it 'should remove Package[bareos-director] and related' do
      should contain_package('bareos-director').with_ensure('absent')
      should contain_file('bareos-dir.conf').with_ensure('absent')
    end
    it 'should stop Service[bareos-dir]' do
      should contain_service('bareos-dir').with_ensure('stopped')
    end
    it 'should not enable at boot Service[bareos-dir]' do
      should contain_service('bareos-dir').with_enable('false')
    end
  end

  describe 'Test decommissioning - disable' do
    let(:facts) { {:bareos_disable => true, :operatingsystem => 'Debian'} }
    it { should contain_package('bareos-director').with_ensure('present') }
    it 'should stop Service[bareos-dir]' do
      should contain_service('bareos-dir').with_ensure('stopped')
    end
    it 'should not enable at boot Service[bareos-dir]' do
      should contain_service('bareos-dir').with_enable('false')
    end
  end

  describe 'Test decommissioning - disableboot' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_disableboot => true,
        :bareos_monitor_target => '10.42.42.42',
        :director_pid_file =>  'some.pid.file',
        :monitor => true
      }
    end
    it { should contain_package('bareos-director').with_ensure('present') }
    it { should_not contain_service('bareos-dir').with_ensure('present') }
    it { should_not contain_service('bareos-dir').with_ensure('absent') }
    it 'should not enable at boot Service[bareos-dir]' do
      should contain_service('bareos-dir').with_enable('false')
    end
    it { should contain_monitor__process('bareos_director_process').with_enable('false') }
  end

  describe 'Test noops mode' do
    let(:facts) do
      { 
        :operatingsystem => 'Debian',
        :bareos_noops => true,
        :bareos_monitor_target => '10.42.42.42',
        :director_pid_file =>  'some.pid.file',
        :monitor => true
      }
    end
    it { should contain_package('bareos-director').with_noop('true') }
    it { should contain_service('bareos-dir').with_noop('true') }
    it { should contain_monitor__process('bareos_director_process').with_noop('true') }
  end
end
