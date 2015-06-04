require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe 'bareos::director::schedule' do

  let(:title) { 'bareos::director::schedule' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) do
    {
      :ipaddress       => '10.42.42.42',
      :operatingsystem => 'Debian',
      :service_autorestart => true,
      :bareos_director_service => 'bareos-dir',
      :schedules_configs_dir => '/etc/bareos/director.d',
    }
  end

  describe 'Test schedules.conf is created with no options' do
    let(:params) do
      {
        :name => 'sample1',
      }
    end
    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

Schedule {
  Name = "sample1"
}
'
    end
    it { should contain_file('schedule-sample1.conf').with_path('/etc/bareos/director.d/schedule-sample1.conf').with_content(expected) }
  end

  describe 'Test schedules.conf is created with all main options' do
    let(:params) do
      {
        :name => 'sample2',
        :run_spec => [['Full','sun','22:00']],
      }
    end

    let(:expected) do
'# This file is managed by Puppet. DO NOT EDIT.

Schedule {
  Name = "sample2"
  Run = Level=Full sun at 22:00
}
'
    end
    it { should contain_file('schedule-sample2.conf').with_path('/etc/bareos/director.d/schedule-sample2.conf').with_content(expected) }

    it 'should automatically restart the service, by default' do
      should contain_file('schedule-sample2.conf').with_notify('Service[bareos-dir]')
    end
  end

end

