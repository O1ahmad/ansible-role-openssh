title "Default role integrated test file"

describe file('/etc/ssh/sshd_config') do
  it { should exist }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should cmp '0644' }
end

describe service('sshd') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
