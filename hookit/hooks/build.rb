# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

# By this point, engine should be set in the registry
engine = registry('engine')

if not ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/build"
  logtap.print fatal('build script is required, but missing')
  exit HOOKIT::EXIT::ABORT
end

logtap.print bullet('build script detected, running now'), 'debug'

execute "build code" do
  command %Q(#{ENGINE_DIR}/#{engine}/bin/build '#{engine_payload}')
  cwd "#{ENGINE_DIR}/#{engine}/bin"
  path GONANO_PATH
  user 'gonano'
  stream true
  on_data {|data| logtap.print data}
end
