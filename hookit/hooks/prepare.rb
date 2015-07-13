# import some logic/helpers from lib/engine.rb
include NanoBox::Engine

# By this point, engine should be set in the registry
engine = registry('engine')

if not ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/prepare"
  logtap.print fatal('prepare script is required, but missing')
  exit HOOKIT::EXIT::ABORT
end

logtap.print bullet('prepare script detected, running now'), 'debug'

execute "prepare code and environment" do
  command %Q(#{ENGINE_DIR}/#{engine}/bin/prepare '#{engine_payload}')
  cwd "#{ENGINE_DIR}/#{engine}/bin"
  path GONANO_PATH
  user 'gonano'
  stream true
  on_data {|data| logtap.print data}
end
