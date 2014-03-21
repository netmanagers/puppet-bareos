require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'bareos::client' do

  let(:title) { 'bareos::client' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) do
    { 
      :operatingsystem => 'Debian',
      :ipaddress => '10.42.42.42',
      :service_autorestart => true 
    }
  end

  describe 'Test standard Centos installation' do
    it { should contain_package('bareos-filedaemon').with_ensure('present') }
    it { should contain_file('bareos-fd.conf').with_ensure('present') }
    it { should contain_service('bareos-fd').with_ensure('running') }
    it { should contain_service('bareos-fd').with_enable('true') }
  end

  describe 'Test standard Debian installation' do
    it { should contain_package('bareos-filedaemon').with_ensure('present') }
    it { should contain_file('bareos-fd.conf').with_ensure('present') }
    it { should contain_file('bareos-fd.conf').with_path('/etc/bareos/bareos-fd.conf') }
    it { should contain_file('bareos-fd.conf').without_content }
    it { should contain_file('bareos-fd.conf').without_source }
    it { should contain_service('bareos-fd').with_ensure('running') }
    it { should contain_service('bareos-fd').with_enable('true') }
  end

  describe 'Test service autorestart' do
    it 'should automatically restart the service, by default' do
      should contain_file('bareos-fd.conf').with_notify('Service[bareos-fd]')
    end
  end

  describe 'Test customizations - provide source' do
    let(:facts) do
      {
        :operatingsystem => 'Centos',
        :bareos_client_source  => 'puppet:///modules/bareos/bareos.source'
      }
    end
    it { should contain_file('bareos-fd.conf').with_path('/etc/bareos/bareos-fd.conf') }
    it { should contain_file('bareos-fd.conf').with_source('puppet:///modules/bareos/bareos.source') }
  end

  describe 'Test customizations - master_password' do
    let(:facts) do
      {
        :operatingsystem => 'Centos',
        :bareos_client_name => 'master_client',
        :bareos_default_password => 'abcdefg',
        :bareos_client_template => 'bareos/bareos-fd.conf.erb'
      }
    end
    it { should contain_file('bareos-fd.conf').with_content(/Password = "abcdefg".*Password = "abcdefg"/m) }
  end

  describe 'Test customizations - provided template' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_director_name => 'here_director',
        :bareos_default_password => 'testing',
        :bareos_client_password => 'client_pass',
        :bareos_client_name => 'this_client',
        :bareos_client_port => '4242',
        :bareos_working_directory => '/some/dir',
        :bareos_heartbeat_interval => '1 week',
        :bareos_client_address => '10.42.42.42',
        :bareos_client_template => 'bareos/bareos-fd.conf.erb'
      }
    end
    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

# Directors who are permitted to contact this File daemon.
Director {
  Name = "here_director"
  Password = "client_pass"
}

# Restricted Director, used by tray-monitor for File daemon status.
Director {
  Name = "rspec.example42.com-mon"
  Password = "testing"
  Monitor = Yes
}

# "Global" File daemon configuration specifications.
FileDaemon {
  Name = "this_client"
  FDport = 4242
  WorkingDirectory = /some/dir
  FDAddress = 10.42.42.42
  Heartbeat Interval = 1 week
}

Messages {
  Name = "standard"
  Director = here_director = all, !skipped, !restored
}
'
    end
    it 'should create a valid config file' do
      should contain_file('bareos-fd.conf').with_content(expected)
    end
  end

  describe 'Test customizations - custom template' do
    let(:facts) do
      {
        :operatingsystem => 'Centos',
        :bareos_client_template => 'bareos/spec.erb',
        :options => { 'opt_a' => 'value_a' }
      }
    end
    it { should contain_file('bareos-fd.conf').without_source }
    it 'should generate a valid template' do
      should contain_file('bareos-fd.conf').with_content(/fqdn: rspec.example42.com/)
    end
    it 'should generate a template that uses custom options' do
      should contain_file('bareos-fd.conf').with_content(/value_a/)
    end
  end

  describe 'Test standard installation with monitoring and firewalling' do
    let(:facts) do
      {
        :operatingsystem       => 'Debian',
        :monitor               => 'true',
        :bareos_monitor_target => '10.42.42.42',
        :firewall              => 'true',
        :bareos_protocol       => 'tcp',
        :bareos_client_service => 'bareos-fd',
        :bareos_client_port    => '9102',
        :concat_basedir        => '/var/lib/puppet/concat',
      }
    end
    it { should contain_package('bareos-filedaemon').with_ensure('present') }
    it { should contain_service('bareos-fd').with_ensure('running') }
    it { should contain_service('bareos-fd').with_enable(true) }
    it { should contain_file('bareos-fd.conf').with_ensure('present') }
    it { should contain_monitor__process('bareos_client_process').with_enable(true) }
    it { should contain_monitor__port('monitor_bareos_client_tcp_9102').with_enable(true) }
    it { should contain_firewall('firewall_bareos_client_tcp_9102').with_enable(true) }
  end

  describe 'Test Centos decommissioning - absent' do
    let(:facts) { {:bareos_absent => true, :operatingsystem => 'Centos'} }
    it 'should remove Package[bareos-filedaemon]' do
      should contain_package('bareos-filedaemon').with_ensure('absent')
      should contain_file('bareos-fd.conf').with_ensure('absent')
    end
    it 'should stop Service[bareos-fd]' do
      should contain_service('bareos-fd').with_ensure('stopped')
    end
    it 'should not enable at boot Service[bareos-fd]' do
      should contain_service('bareos-fd').with_enable('false')
    end
  end

  describe 'Test Debian decommissioning - absent' do
    let(:facts) { {:bareos_absent => true, :operatingsystem => 'Debian'} }
    it 'should remove Package[bareos-fd]' do
      should contain_package('bareos-filedaemon').with_ensure('absent')
    end
    it 'should stop Service[bareos-fd]' do
      should contain_service('bareos-fd').with_ensure('stopped')
    end
    it 'should not enable at boot Service[bareos-fd]' do
      should contain_service('bareos-fd').with_enable('false')
    end
  end

  describe 'Test decommissioning - disable' do
    let(:facts) { {:bareos_disable => true, :operatingsystem => 'Debian'} }
    it { should contain_package('bareos-filedaemon').with_ensure('present') }
    it 'should stop Service[bareos-fd]' do
      should contain_service('bareos-fd').with_ensure('stopped')
    end
    it 'should not enable at boot Service[bareos-fd]' do
      should contain_service('bareos-fd').with_enable('false')
    end
  end

  describe 'Test decommissioning - disableboot' do
    let(:facts) { {:bareos_disableboot => true, :operatingsystem => 'Debian'} }
    it { should contain_package('bareos-filedaemon').with_ensure('present') }
    it { should_not contain_service('bareos-fd').with_ensure('present') }
    it { should_not contain_service('bareos-fd').with_ensure('absent') }
    it 'should not enable at boot Service[bareos-fd]' do
      should contain_service('bareos-fd').with_enable('false')
    end
  end

  describe 'Test noops mode' do
    let(:facts) { {:bareos_noops => true, :operatingsystem => 'Centos'} }
    it { should contain_package('bareos-filedaemon').with_noop('true') }
    it { should contain_file('bareos-fd.conf').with_noop('true') }
    it { should contain_service('bareos-fd').with_noop('true') }
  end
end
