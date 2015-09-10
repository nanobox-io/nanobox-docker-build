# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

logtap.print(bullet('Running boxfile hook'), 'debug')

# By this point, engine should be set in the registry
engine = registry('engine')

boxfile = begin
  if ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/boxfile"

    logtap.print bullet('Boxfile script detected, running now'), 'debug'

    execute "generating boxfile" do
      command %Q(#{ENGINE_DIR}/#{engine}/bin/boxfile '#{engine_payload}')
      cwd "#{ENGINE_DIR}/#{engine}/bin"
      path GONANO_PATH
      user 'gonano'
    end
  end
end

# print the generated Boxfile for debug
logtap.print header("Generated Boxfile"), 'debug'
logtap.print boxfile, 'debug'

# todo: sanitize and validate


# return boxfile to nanobox
puts boxfile
