# import some logic/helpers from lib/engine.rb
include NanoBox::Engine

# 'payload' is a helper function within the hookit framework that will parse
# input provided as JSON into a hash with symbol keys.
# https://github.com/pagodabox/hookit/blob/master/lib/hookit/hook.rb#L7-L17
# 
# Now we extract the 'boxfile' section of the payload, which is only the
# 'build' section of the Boxfile provided by the app
boxfile = payload[:boxfile] || {}

# If a plugin is specified, an engine must also be
if boxfile[:plugin] and not boxfile[:engine]
  # todo: log
  exit HOOKIT::ABORT
end

# 1)
# If an engine or plugin is mounted from the workstation,
# let's put those in place first. This process will replace any default engine
# if the names collide.
if boxfile[:engine] and is_filepath?(boxfile[:engine])

  basename = ::File.basename(boxfile[:engine])
  path     = "/share/engines/#{basename}"

  # if the engine has been shared with us, then let's copy it over
  if ::File.exist?(path)

    # remove any official engine that may be in the way
    directory "/opt/engines/#{basename}" do
      action :delete
    end

    # copy the mounted engine into place
    execute 'move engine into place' do
      command "cp -r /share/engines/#{basename} /opt/engines/"
    end
  end

  # now let's set the engine in the registry for later consumption
  registry('engine', basename)
end

if boxfile[:plugin] and is_filepath?(boxfile[:plugin])

  basename = ::File.basename(boxfile[:plugin])
  path     = "/share/plugins/#{basename}"

  # if the plugin has been shared with us, then let's copy it over
  if ::File.exist?(path)

    # remove any official plugin that may be in the way
    directory "/opt/plugins/#{basename}" do
      action :delete
    end

    # ensure we have a parent directory for the plugin
    directory "/opt/engines/#{engine}/plugins" do
      recursive true
    end

    # copy the mounted plugin into place
    execute 'move plugin into place' do
      command "cp -r /share/plugins/#{basename} /opt/engines/#{engine}/plugins/"
    end
  end

  # now let's set the plugin in the registry for later consumption
  registry('plugin', basename)
end

# 2)
# If a custom engine or plugin is specified, and is not mounted from
# the workstation, let's fetch those from warehouse.nanobox.io. 
# This process will replace any default engine if the names collide.
if boxfile[:engine] and not is_filepath?(boxfile[:engine])
  # todo: wait until nanobox-cli can fetch engine
end

if boxfile[:plugin] and not is_filepath?(boxfile[:plugin])
  # todo: wait until nanobox-cli can fetch plugin
end

# 3)
# Finally, let's move the pkgin cache into place if this is a subsequent deploy
# todo: mv might not be safe in case the deploy fails, it will be gone
if ::File.exist? '/mnt/cache/pkgin'
  # fetch the pkgin cache & db from cache for a quick deploy
  execute "extrace pkgin packages from cache for quick access" do
    command 'cp -r /mnt/cache/pkgin/. /data/var/db/pkgin'
  end
end
