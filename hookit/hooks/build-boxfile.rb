env_vars = File.read("/etc/environment.d/nanobox")
execute "run boxfile" do
  command '/var/nanobox/engines/boxfile'
  cwd '/data'
  environment env_vars
  path GOPAGODA_PATH
  user 'gopagoda'
  stream true
  on_data {|data| logvac.print data}
end
