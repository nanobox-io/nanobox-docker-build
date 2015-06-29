# import some logic/helpers from lib/engine.rb
include NanoBox::Engine

# By this point, engine should be set in the registry
# if an engine is specified in the Boxfile
engine = registry('engine')

# 1)
# If an engine is not already specified, we need to iterate through the
# installed engines calling the "sniff" script until one of them exits with 0
if not engine
  ::Dir.glob("#{ENGINE_DIR}/*").select { |f| ::File.directory?(f) }.each do |e|

    # once engine is set, we can stop looping
    break if engine

    # make sure we have a sniff script
    next if not ::File.exist? "#{e}/bin/sniff"

    # for convenience, we only want the engine name
    basename = ::File.basename(e)

    # todo: we need to think about logging and if we want to wire-up the stdout
    # from the sniff script into the deploy stream

    # execute 'sniff' to see if we qualify
    execute 'sniff' do
      command %Q(#{e}/bin/sniff "#{CODE_LIVE_DIR}")
      cwd "#{e}/bin"
      path GONANO_PATH
      user 'gonano'
      stream true
      # on_data {|data| logvac.print data}
      on_data {|data| print data}
      on_exit { |code| engine = basename if code == 0 }
    end
  end

  if engine
    # set the engine in the registry for later use
    registry('engine', engine)
    # todo: display a message indicating an engine was selected
  else
    # todo: if we don't have an engine at this point, we need to log an error
    exit HOOKIT::EXIT::ABORT
  end
end

# 2)
# todo: parse the selected engine's Enginefile and see if they want a minimal base
# ie: not a pkgsrc bootstrap
if true
  
else
  # move the pkgin cache into place if this is a subsequent deploy
  if ::File.exist? "#{CACHE_DIR}/pkgin"
    # fetch the pkgin cache & db from cache for a quick deploy
    execute "extrace pkgin packages from cache for quick access" do
      command "cp -r #{CACHE_DIR}/pkgin/* #{BUILD_DIR}/var/db/pkgin"
    end
  end
end

# 3)
# make sure required directories exist
[
  "#{BUILD_DIR}/sbin",
  "#{BUILD_DIR}/bin",
  "#{ETC_DIR}",
  "#{ENV_DIR}",
  "#{CODE_DIR}"
].each do |dir|
  directory dir do
    recursive true
  end
end

# 4)
# copy the read-only mounted code into the build
execute "copy code into build" do
  command "cp -r #{CODE_LIVE_DIR}/* #{CODE_DIR}"
end

execute "ensure gonano owns code" do
  command "chown -R gonano #{CODE_DIR}"
end

# 5)
if ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/prepare"
  execute "prepare" do
    command %Q(#{ENGINE_DIR}/#{engine}/bin/prepare '#{engine_payload}')
    cwd "#{ENGINE_DIR}/#{engine}/bin"
    path GONANO_PATH
    user 'gonano'
    stream true
    # on_data {|data| logvac.print data}
    on_data {|data| print data}
  end
end
