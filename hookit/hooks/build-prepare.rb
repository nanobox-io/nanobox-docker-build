env_vars = File.read("/etc/environment.d/nanobox")
execute "run sniff" do
  command '/var/nanobox/engines/sniff'
  cwd '/data'
  environment env_vars
  path GOPAGODA_PATH
  user 'gopagoda'
  stream true
  on_data {|data| logvac.print data}
end

execute "run prepare" do
  command '/var/nanobox/engines/prepare'
  cwd '/data'
  environment env_vars
  path GOPAGODA_PATH
  user 'gopagoda'
  stream true
  on_data {|data| logvac.print data}
end
