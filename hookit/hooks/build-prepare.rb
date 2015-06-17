env_vars = payload[:env]
engine = registry('engine')

if engine
  execute "run sniff" do
    command "/opt/engines/#{engine}/bin/sniff"
    cwd "/opt/engines/#{engine}/bin"
    environment env_vars
    path GOPAGODA_PATH
    user 'gopagoda'
    stream true
    on_data {|data| logvac.print data}
  end
else
  # i call it rub-ash
  for engine in `ls -l /opt/engines`; do

    execute "run sniff" do
      command "/opt/engines/#{engine}/bin/sniff"
      cwd "/opt/engines/#{engine}/bin"
      environment env_vars
      path GOPAGODA_PATH
      user 'gopagoda'
      stream true
      on_data {|data| logvac.print data}
    end

  done # need to ruby-ize
end

execute "run prepare" do
  command "/opt/engines/#{engine}/bin/prepare"
  cwd "/opt/engines/#{engine}/bin"
  environment env_vars
  path GOPAGODA_PATH
  user 'gopagoda'
  stream true
  on_data {|data| logvac.print data}
end

# reset engine in registry to successfully sniffed one
