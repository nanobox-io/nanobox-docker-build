env_vars = File.read("/etc/environment.d/nanobox")
execute "run build" do
  command '/var/nanobox/engines/build'
  cwd '/data'
  environment env_vars
  path GOPAGODA_PATH
  user 'gopagoda'
  stream true
  on_data {|data| logvac.print data}
end
