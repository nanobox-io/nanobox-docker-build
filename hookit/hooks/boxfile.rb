require 'yaml'

# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

logtap.print(bullet('Running boxfile hook...'), 'debug')

# By this point, engine should be set in the registry
engine = registry('engine')

boxfile = ''

if ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/boxfile"

  logtap.print bullet('Boxfile script detected, running now'), 'debug'

  execute "generating boxfile" do
    command %Q(#{ENGINE_DIR}/#{engine}/bin/boxfile '#{engine_payload}')
    cwd "#{ENGINE_DIR}/#{engine}/bin"
    path GONANO_PATH
    user 'gonano'
    stream true
    on_stderr {|edata| logtap.print edata}
    on_stdout {|odata| boxfile << odata}
  end
end

# print the generated Boxfile for debug
logtap.print header("Generated Boxfile"), 'debug'
logtap.print boxfile, 'debug'

# sanitize and validate
begin
  # try to parse the YAML
  YAML.load(boxfile)
  # return boxfile to nanobox
  puts boxfile
rescue Exception => e
  logtap.print fatal('invalid yaml', e.message)
  # exit non-zero
  exit Hookit::Exit::ABORT
end
