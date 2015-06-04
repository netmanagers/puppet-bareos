require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe 'bareos::director::messages' do

  let(:title) { 'bareos::director::messages' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) do
    {
      :ipaddress       => '10.42.42.42',
      :operatingsystem => 'Debian',
      :service_autorestart => true,
      :bareos_director_service => 'bareos-dir',
      :bareos_log_file => '/var/log/bareos/bareos.log'
    }
  end

  describe 'Test messages.conf is created with no options' do
    let(:params) do
      {
        :name => 'sample1',
      }
    end
    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

Messages {
  Name = "sample1"
  console = all, !skipped, !saved
  catalog = all, !skipped, !saved
  append = "/var/log/bareos/bareos.log" = all, !skipped
}
'
    end
    it 'should generate a default messages section' do
      should contain_file('messages-sample1.conf').with_path('/etc/bareos/director.d/messages-sample1.conf').with_content(expected)
    end
  end

  describe 'Test messages.conf is created with all main options' do
    let(:params) do
      {
        :name => 'sample2',
        :mail_command => '/usr/bin/bsmtp',
        :mail_host => 'localhost',
        :mail_from => 'noreply@example.com',
        :mail_to => 'destination@example.com',
      }
    end

    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

Messages {
  Name = "sample2"
  mailcommand = "/usr/bin/bsmtp -h localhost -f \"Bareos <noreply@example.com>\" -s \"Bareos: %t %e of %c %l\" %r"
  operatorcommand = "/usr/bin/bsmtp -h localhost -f \"Bareos <noreply@example.com>\" -s \"Bareos: Intervention needed for %j\" %r"
  mail = destination@example.com = all, !skipped
  operator = destination@example.com = mount
  mailonerror = destination@example.com = all
  console = all, !skipped, !saved
  catalog = all, !skipped, !saved
  append = "/var/log/bareos/bareos.log" = all, !skipped
}
'
    end
    it 'should generate a messages section with multiple options set' do
      should contain_file('messages-sample2.conf').with_path('/etc/bareos/director.d/messages-sample2.conf').with_content(expected)
    end

    it 'should automatically restart the service, by default' do
      should contain_file('messages-sample2.conf').with_notify('Service[bareos-dir]')
    end
  end

end

