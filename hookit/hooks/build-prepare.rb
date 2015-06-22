# import some logic/helpers from lib/engine.rb
include NanoBox::Engine

# By this point, engine should be set in the registry
# if an engine is specified in the Boxfile
engine = registry('engine')

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
      command %Q(#{e}/bin/sniff "#{CODE_DIR}")
      cwd "#{e}/bin"
      path GONANO_PATH
      user 'gonano'
      stream true
      on_data {|data| logvac.print data}
      on_exit { |code| engine = basename if code == 0 }
    end
  end

  if engine
    # set the engine in the registry for later use
    registry('engine', engine)
    # todo: display a message indicating an engine was selected
  else
    # todo: if we don't have an engine at this point, we need to log an error
    exit HOOKIT::ABORT
  end
end

if ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/prepare"
  execute "prepare" do
    command %Q(#{ENGINE_DIR}/#{engine}/bin/prepare "#{engine_payload}")
    cwd "#{ENGINE_DIR}/#{engine}/bin"
    path GONANO_PATH
    user 'gonano'
    stream true
    on_data {|data| logvac.print data}
  end
end
