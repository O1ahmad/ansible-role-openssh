title "OpenSSH authorized_keys configuration integrated test file"

describe file('/home/test/.ssh/authorized_keys') do
  it { should exist }
  its('mode') { should cmp '0644' }

  its('content') { should match("Managed by Ansible") }
  its('content') { should match("ansible-role-openssh") }
  its('content') { should match("NAME=value") }
  its('content') { should match("test.example.net") }
end
