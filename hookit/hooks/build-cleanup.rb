# import some logic/helpers from lib/engine.rb
include NanoBox::Engine

# By this point, engine should be set in the registry
engine = registry('engine')

if ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/cleanup"

  execute "cleanup code" do
    command %Q(#{ENGINE_DIR}/#{engine}/bin/cleanup "#{engine_payload}")
    cwd "#{ENGINE_DIR}/#{engine}/bin"
    path GONANO_PATH
    user 'gonano'
    stream true
    on_data {|data| logvac.print data}
  end

end

# copy /data (current build) to /mnt/deploy for host access
execute "copy build into place" do
  command 'cp -r /data/ /mnt/deploy'
end

# ensure the directory exists for pkgin cache
directory "/mnt/cache/pkgin" do
  recursive true
end

# copy (and remove) the pkgin cache & db for quick subsequent deploys
execute "stash pkgin packages into cache for quick access" do
  command 'mv /data/var/db/pkgin/. /mnt/cache/pkgin'
end
