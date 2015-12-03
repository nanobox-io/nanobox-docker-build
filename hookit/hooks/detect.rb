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
  logtap.print(bullet('Detecting app language & engine'))

  ::Dir.glob("#{ENGINE_DIR}/*").select { |f| ::File.directory?(f) }.sort.each do |e|

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
      on_exit { |code| engine = basename if code == 0 }
    end
  end

  if engine
    # set the engine in the registry for later use
    registry('engine', engine)
  else
    logtap.print(no_engine)
    exit Hookit::Exit::ABORT
  end
end

info = engine_info(
  engine_id, 
  enginefile[:name], 
  enginefile[:language], 
  enginefile[:generic]
)

logtap.print info
