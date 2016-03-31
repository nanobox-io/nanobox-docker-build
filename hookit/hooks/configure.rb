# hook order:
# configure [all]
# detect    [all]
# sync      [all]
# setup     [all]
# boxfile   [all]
# prepare   [all]
# build     [run]
# publish   [run]
# cleanup   [all]

# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

# store the original boxfile for later use if needed (this may not be needed forever)
registry(:original_boxfile, boxfile)

logtap.print(bullet('Running configure hook...'), 'debug')

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

  # if the engine has been shared with us, then let's copy it over
  if ::File.exist?(path)

    logtap.print(bullet("Detected engine from local workstation..."))

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

  engine = engine_name(boxfile[:engine])

  # remove any official engine that may be in the way
  directory "#{ENGINE_DIR}/#{engine}" do
    action :delete
  end

  # ensure a directory for this engine exists
  directory "#{ENGINE_DIR}/#{engine}" do
    recursive true
  end

  logtap.print(process_start("Fetch #{boxfile[:engine]}"))

  execute "fetching #{engine}" do
    command <<-EOF
      nanobox engine fetch \
        #{boxfile[:engine]} \
          | tar \
            -xzf - \
            -C #{ENGINE_DIR}/#{engine}
    EOF
    stream true
    on_stderr { |data| logtap.print subtask_info(data) }
  end

  logtap.print(process_end)

  registry('engine', engine)
end

# 3)
# make sure required directories exist and are owned by gonano
logtap.print(bullet('ensuring all directories required for build exist'), 'debug')

[
  "#{BUILD_DIR}",
  "#{BUILD_DIR}/sbin",
  "#{BUILD_DIR}/bin",
  "#{LIVE_DIR}",
  "#{ETC_DIR}",
  "#{ENV_DIR}",
  "#{CODE_DIR}",
  "#{APP_CACHE_DIR}",
  "#{LIB_CACHE_DIR}"
].each do |dir|
  directory dir do
    recursive true
  end

  execute "chown gonano #{dir}"
end

# 4)
# move the pkgin cache into place if this is a subsequent deploy
if ::File.exist? "#{CACHE_DIR}/pkgin"

  directory "#{BUILD_DIR}/var/db/pkgin/cache" do
    owner 'gonano'
    group 'gonano'
    recursive true
  end

  logtap.print(process_start('Extract pkgin cache...'), 'debug')

  # fetch the pkgin cache & db from cache for a quick deploy
  execute "extract pkgin packages from cache for quick access" do
    command <<-EOF
      rsync \
        -v \
        -a \
        #{CACHE_DIR}/pkgin/ \
        #{BUILD_DIR}/var/db/pkgin/cache
    EOF
    stream true
    on_data { |data| logtap.print subtask_info(data), 'debug' }
  end

  logtap.print process_end, 'debug'
end

# 5)
# update pkgin packages db
logtap.print(process_start('Updating pkgin database...'), 'debug')

execute "update pkgin packages" do
  command <<-EOF
    rm -f #{BUILD_DIR}/var/db/pkgin/pkgin.db && \
    #{BUILD_DIR}/bin/pkgin -y up
  EOF
  user 'gonano'
  stream true
  on_data { |data| logtap.print subtask_info(data), 'debug' }
end

logtap.print process_end, 'debug'
