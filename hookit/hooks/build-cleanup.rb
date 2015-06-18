# import some logic/helpers from lib/engine.rb
include NanoBox::Engine

# By this point, engine should be set in the registry
engine = registry('engine')

if ::File.exist? "/opt/engines/#{engine}/bin/cleanup"

  execute "cleanup code" do
    command %Q(/opt/local/engines/#{engine}/bin/cleanup "#{engine_payload}")
    cwd "/opt/engines/#{engine}/bin"
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

# copy the pkgin cache & db for quick subsequent deploys
execute "stash pkgin packages into cache for quick access" do
  command 'cp -r /data/var/db/pkgin/ /mnt/cache/pkgin'
end
