# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

# By this point, engine should be set in the registry
engine = registry('engine')

boxfile = begin
  if ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/boxfile"

    logtap.print bullet('boxfile script detected, running now'), 'debug'

    execute "generating boxfile" do
      command %Q(#{ENGINE_DIR}/#{engine}/bin/boxfile '#{engine_payload}')
      cwd "#{ENGINE_DIR}/#{engine}/bin"
      path GONANO_PATH
      user 'gonano'
    end
  end
end

# todo: sanitize and validate

# return boxfile to nanobox
puts boxfile
