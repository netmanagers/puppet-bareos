require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'bareos::console' do

  let(:title) { 'bareos::console' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42', :operatingsystem => 'Debian' } }

  describe 'Test standard Centos installation' do
    let(:facts) { { :operatingsystem => 'Centos' } }
    it { should contain_package('bareos-bconsole').with_ensure('present') }
    it { should contain_file('bconsole.conf').with_ensure('present') }
  end

  describe 'Test customizations - provide source' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_console_source  => 'puppet:///modules/bareos/bconsole.source'
      }
    end
    it { should contain_file('bconsole.conf').with_path('/etc/bareos/bconsole.conf') }
    it { should contain_file('bconsole.conf').with_source('puppet:///modules/bareos/bconsole.source') }
  end

  describe 'Test customizations - master_password' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_console_name => 'master_console',
        :bareos_default_password => 'abcdefg',
        :bareos_console_template => 'bareos/bconsole.conf.erb'
      }
    end
    it { should contain_file('bconsole.conf').with_content(/Password = "abcdefg"/) }
  end

  describe 'Test customizations - provided template' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_director_name => 'here_director',
        :bareos_director_address => '10.42.42.42',
        :bareos_default_password => 'testing',
        :bareos_console_password => 'console_pass',
        :bareos_console_template => 'bareos/bconsole.conf.erb'
      }
    end
    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

# Bareos User Agent "Console" (bconsole).
Director {
  Name = "here_director"
  DIRPort = 9101
  Address = 10.42.42.42
  Password = "console_pass"
}
'
    end
    it 'should create a valid config file' do
      should contain_file('bconsole.conf').with_content(expected)
    end
  end

  describe 'Test customizations - custom template' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :bareos_console_template => 'bareos/spec.erb',
        :options => { 'opt_a' => 'value_a' }
      }
    end
    it { should contain_file('bconsole.conf').without_source }
    it 'should generate a valid template' do
      should contain_file('bconsole.conf').with_content(/fqdn: rspec.example42.com/)
    end
    it 'should generate a template that uses custom options' do
      should contain_file('bconsole.conf').with_content(/value_a/)
    end
  end

  describe 'Test Centos decommissioning - absent' do
    let(:facts) { {:bareos_absent => true, :operatingsystem => 'Centos'} }
    it 'should remove Package[bareos-bconsole]' do
      should contain_package('bareos-bconsole').with_ensure('absent')
      should contain_file('bconsole.conf').with_ensure('absent')
    end
  end

  describe 'Test noops mode' do
    let(:facts) { {:bareos_noops => true, :operatingsystem => 'Centos'} }
    it { should contain_package('bareos-bconsole').with_noop('true') }
    it { should contain_file('bconsole.conf').with_noop('true') }
  end
end
