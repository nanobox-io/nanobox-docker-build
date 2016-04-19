# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

logtap.print(bullet("Running setup hook..."), 'debug')

# By this point, engine should be set in the registry
engine = registry('engine')

if ::File.exist? "#{ENGINE_DIR}/#{registry('engine')}/bin/setup"

  logtap.print(bullet("Setup script detected, running now..."), 'debug')

  execute "setup environment" do
    command %Q(#{ENGINE_DIR}/#{registry('engine')}/bin/setup '#{engine_payload}')
    cwd "#{ENGINE_DIR}/#{registry('engine')}/bin"
    path GONANO_PATH
    user 'gonano'
    stream true
    on_data {|data| logtap.print data}
  end
end
