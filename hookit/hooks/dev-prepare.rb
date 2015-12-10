# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

logtap.print(bullet("Running dev-prepare hook..."), 'debug')

# By this point, engine should be set in the registry
engine = registry('engine')

case payload[:dev_config]
when 'none'
  logtap.print(bullet("Config 'none' detected, exiting now..."), 'debug')
  exit 0
when 'mount'
  logtap.print(bullet("Config 'mount' detected, running now..."), 'debug')

  # look for the 'config_files' node within the 'boxfile' payload, and
  # bind mount each of the entries
  execute "bind mount configs" do
    command %Q(#{ENGINE_DIR}/#{engine}/bin/dev-mount '#{engine_payload}')
    cwd "#{ENGINE_DIR}/#{engine}/bin"
    path GONANO_PATH
    user 'gonano'
    stream true
    on_data {|data| logtap.print data}
  end
when 'copy'
  logtap.print(bullet("Config 'copy' detected, running now..."), 'debug')

  # copy each of the values in the 'config_files' node into the raw source
  execute "copy configs" do
    command %Q(#{ENGINE_DIR}/#{engine}/bin/dev-copy '#{engine_payload}')
    cwd "#{ENGINE_DIR}/#{engine}/bin"
    path GONANO_PATH
    user 'gonano'
    stream true
    on_data {|data| logtap.print data}
  end
else
  logtap.print(bullet("Config not detected, exiting now..."), 'debug')
  exit 0
end
