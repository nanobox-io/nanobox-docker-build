
# ensure the gonano .ssh directory exists
directory "/home/gonano/.ssh" do
  recursive true
  mode 700
  owner 'gonano'
  group 'gonano'
end

# set custom ssh configuration
hook_file "/home/gonano/.ssh/config" do
  source 'ssh/config'
  mode 600
  owner 'gonano'
  group 'gonano'
end

# create file for each file passed in
payload[:ssh_files].each do |name, body|

  file "/home/gonano/.ssh/#{name}" do
    content body
    mode 600
    owner 'gonano'
    group 'gonano'
  end

end
