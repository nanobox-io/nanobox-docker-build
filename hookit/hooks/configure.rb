# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

logtap.print(bullet('Running configure hook...'), 'debug')

# 'payload' is a helper function within the hookit framework that will parse
# input provided as JSON into a hash with symbol keys.
# https://github.com/pagodabox/hookit/blob/master/lib/hookit/hook.rb#L7-L17
# 
# Now we extract the 'boxfile' section of the payload, which is only the
# 'build' section of the Boxfile provided by the app
boxfile = payload[:boxfile] || {}

# 0) temporary
logtap.print(bullet("Ensuring the engine dir exists..."), 'debug')

# ensure engine dir exists
directory "#{ENGINE_DIR}" do
  recursive true
end

# 1)
# If an engine is mounted from the workstation, let's put those in place first.
# This process will replace any default engine if the names collide.
if boxfile[:engine] and is_filepath?(boxfile[:engine])

  basename = ::File.basename(boxfile[:engine])
  path     = "#{SHARE_DIR}/engines/#{basename}"

  logtap.print(bullet("Detecting engine from local workstation..."))

  # if the engine has been shared with us, then let's copy it over
  if ::File.exist?(path)

    # remove any official engine that may be in the way
    directory "#{ENGINE_DIR}/#{basename}" do
      action :delete
    end

    logtap.print(bullet("Copying engine from workstation into build container..."))

    # copy the mounted engine into place
    logtap.print(process_start('copy mounted engine'), 'debug')

    execute 'move engine into place' do
      command <<-EOF
        rsync \
          -v \
          -a \
          --exclude='.git/' \
          #{ENGINE_LIVE_DIR}/#{basename} \
          #{ENGINE_DIR}/
      EOF
      stream true
      on_data { |data| logtap.print subtask_info(data), 'debug' }
    end

    logtap.print(process_end, 'debug')
  end

  # now let's set the engine in the registry for later consumption
  registry('engine', basename)
end

# 2)
# If a custom engine is specified, and is not mounted from
# the workstation, let's fetch it from warehouse.nanobox.io. 
# This process will replace any default engine if the names collide.
if boxfile[:engine] and not is_filepath?(boxfile[:engine])
  # todo: wait until nanobox-cli can fetch engine
end

# 3)
# move the pkgin cache into place if this is a subsequent deploy
if ::File.exist? "#{CACHE_DIR}/pkgin"

  logtap.print(process_start('Extract pkgin cache'), 'debug')

  # fetch the pkgin cache & db from cache for a quick deploy
  execute "extract pkgin packages from cache for quick access" do
    command <<-EOF
      rsync \
        -v \
        -a \
        #{CACHE_DIR}/pkgin/ \
        #{BUILD_DIR}/var/db/pkgin
    EOF
    stream true
    on_data { |data| logtap.print subtask_info(data), 'debug' }
  end

  logtap.print process_end, 'debug'
end

# 4)
# make sure required directories exist
logtap.print(bullet('ensuring all directories required for build exist'), 'debug')

[
  "#{BUILD_DIR}/sbin",
  "#{BUILD_DIR}/bin",
  "#{ETC_DIR}",
  "#{ENV_DIR}",
  "#{CODE_DIR}",
  "#{APP_CACHE_DIR}"
].each do |dir|
  directory dir do
    recursive true
  end
end

# 5)
# ensure app cache dir is owned by gonano
logtap.print(bullet("Chowning cache data..."), 'debug')

execute "ensure gonano owns app cache" do
  command "chown gonano #{APP_CACHE_DIR}"
end

# 6)
# copy the read-only mounted code into the code dir
logtap.print(process_start('Copy raw code into place'), 'debug')

execute "copy raw code into place" do
  command <<-EOF
    rsync \
      -v \
      -a \
      --delete \
      --exclude='.git/' \
      #{CODE_LIVE_DIR}/ \
      #{CODE_DIR}
  EOF
  stream true
  on_data { |data| logtap.print subtask_info(data), 'debug' }
end

logtap.print(process_end, 'debug')

# 7)
logtap.print(bullet('Chowning cache data'), 'debug')

execute "ensure gonano owns code" do
  command "chown -R gonano #{CODE_DIR}"
end
