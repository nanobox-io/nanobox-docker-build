# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

logtap.print(bullet("Running detect hook..."), 'debug')

# By this point, engine should be set in the registry
# if an engine is specified in the Boxfile
engine = registry('engine')

# If an engine is not already specified, we need to iterate through the
# installed engines calling the "sniff" script until one of them exits with 0
if not engine

  logtap.print(bullet('Engine is not specified, attempting to find an engine...'), 'debug')

  ::Dir.glob("#{ENGINE_DIR}/*").select { |f| ::File.directory?(f) }.each do |e|

    # once engine is set, we can stop looping
    break if engine

    # make sure we have a sniff script
    next if not ::File.exist? "#{e}/bin/sniff"

    # for convenience, we only want the engine name
    basename = ::File.basename(e)

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
    logtap.print(bullet("Engine found : #{engine}"), 'debug')
    # set the engine in the registry for later use
    registry('engine', engine)
    # todo: display a message indicating an engine was selected
  else
    logtap.print(fatal('Unable to find a compatible engine'))
    # todo: if we don't have an engine at this point, we need to log an error
    exit Hookit::Exit::ABORT
  end
end

# todo: log engine detected and provide information about it
