# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

# before
logtap.print(bullet("Running before hook..."), 'debug')

if boxfile[:before]
  logtap.print(bullet("'Before' detected, running now..."), 'debug')

  if boxfile[:before].is_a?(String)
    boxfile[:before]=[boxfile[:before]]
  end

  boxfile[:before].each_with_index do |before_hook, i|
    logtap.print subtask_start "Running before hook #{i}"
    logtap.print subtask_info  "$ #{before_hook}"

    execute "before code" do
      command before_hook
      cwd "#{CODE_DIR}"
      path GONANO_PATH
      user 'gonano'
      stream true
      on_data {|data| logtap.print data}
      on_exit { |code| logtap.print code == 0 ? subtask_success : subtask_fail }
    end

  end
end


# build
logtap.print(bullet("Running build hook..."), 'debug')

# By this point, engine should be set in the registry
engine = registry('engine')

if not ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/build"
  logtap.print fatal('Build script is required, but missing')
  exit Hookit::Exit::ABORT
end

logtap.print(bullet("Build script detected, running now..."), 'debug')

execute "build code" do
  command %Q(#{ENGINE_DIR}/#{engine}/bin/build '#{engine_payload}')
  cwd "#{ENGINE_DIR}/#{engine}/bin"
  path GONANO_PATH
  user 'gonano'
  stream true
  on_data {|data| logtap.print data}
end


# after
logtap.print(bullet("Running after hook..."), 'debug')

if boxfile[:after]
  logtap.print(bullet("'After' detected, running now..."), 'debug')

  if boxfile[:after].is_a?(String)
    boxfile[:after]=[boxfile[:after]]
  end

  boxfile[:after].each_with_index do |after_hook, i|
    logtap.print subtask_start "Running after hook #{i}"
    logtap.print subtask_info  "$ #{after_hook}"

    execute "after code" do
      command after_hook
      cwd "#{CODE_DIR}"
      path GONANO_PATH
      user 'gonano'
      stream true
      on_data {|data| logtap.print data}
      on_exit { |code| logtap.print code == 0 ? subtask_success : subtask_fail }
    end

  end
end
