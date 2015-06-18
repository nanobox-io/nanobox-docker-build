# import some logic/helpers from lib/engine.rb
include NanoBox::Engine

# By this point, engine should be set in the registry
engine = registry('engine')

if not ::File.exist? "/opt/engines/#{engine}/bin/build"
  # todo: log a message explaining that the build script is required
  exit HOOKIT::ABORT
end

execute "build code" do
  command %Q(/opt/local/engines/#{engine}/bin/build "#{engine_payload}")
  cwd "/opt/engines/#{engine}/bin"
  path GONANO_PATH
  user 'gonano'
  stream true
  on_data {|data| logvac.print data}
end
