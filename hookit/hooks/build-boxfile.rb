# import some logic/helpers from lib/engine.rb
include NanoBox::Engine

# By this point, engine should be set in the registry
engine = registry('engine')

boxfile = begin
  if ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/boxfile"
    execute "generating boxfile" do
      command %Q(#{ENGINE_DIR}/#{engine}/bin/boxfile "#{engine_payload}")
      cwd "#{ENGINE_DIR}/#{engine}/bin"
      path GONANO_PATH
      user 'gonano'
    end
  end
end

# todo: sanitize and validate

# return boxfile to nanobox
puts boxfile
