env_vars = payload[:env]
engine = registry('engine')

boxfile = execute "run boxfile" do
  command "/opt/engines/#{engine}/bin/boxfile"
  cwd "/opt/engines/#{engine}/bin"
  environment env_vars
  path GOPAGODA_PATH
  user 'gopagoda'
end

# sanitize and validate
# return boxfile to nanobox
puts boxfile.to_json
