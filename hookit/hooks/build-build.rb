env_vars = payload[:env]
engine = registry('engine')

execute "run build" do
  command "/opt/engines/#{engine}/bin/build"
  cwd "/opt/engines/#{engine}/bin"
  environment env_vars
  path GOPAGODA_PATH
  user 'gopagoda'
  stream true
  on_data {|data| logvac.print data}
end
