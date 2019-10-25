title "Client configuration integrated test file"

describe command('which ssh') do
  its('exit_status') { should eq 0 }
end

describe file('/etc/ssh/ssh_config') do
  it { should exist }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  its('mode') { should cmp '0644' }

  its('content') { should match("Managed by Ansible") }
  its('content') { should match("ansible-role-openssh") }
  its('content') { should match("Host *") }
end

describe file('/home/kitchen/.ssh/config') do
  it { should exist }
  its('owner') { should eq 'kitchen' }
  its('group') { should eq 'kitchen' }
  its('mode') { should cmp '0644' }

  its('content') { should match("Managed by Ansible") }
  its('content') { should match("ansible-role-openssh") }
  its('content') { should match("Match host") }
end
