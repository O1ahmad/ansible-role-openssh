title "OpenSSH ssh-agent service management integrated test file"

describe file('/home/kitchen/.config/systemd/user/ssh-agent.service') do
  it { should exist }
  its('mode') { should cmp '0644' }
end

describe service('ssh-agent') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
