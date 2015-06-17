env_vars = payload[:env]
engine = registry('engine')

execute "run cleanup" do
  command "/opt/engines/#{engine}/bin/clean"
  cwd "/opt/engines/#{engine}/bin"
  environment env_vars
  path GOPAGODA_PATH
  user 'gopagoda'
  stream true
  on_data {|data| logvac.print data}
end

execute "Cache downloads" do
  command 'mv /data/var/db/pkgin/. /var/nanobox/cache/'
  environment env_vars
  path GOPAGODA_PATH
  user 'gopagoda'
  stream true
  on_data {|data| logvac.print data}
end
