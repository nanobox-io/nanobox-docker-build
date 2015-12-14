# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

# user-defined packages
if boxfile[:packages]
  logtap.print(bullet("Packages declared, installing now..."), 'debug')

  execute "install packages" do
    command "pkgin -y in #{[boxfile[:packages]].join(' ')}"
    path GONANO_PATH
    stream true
    on_data {|data| logtap.print(data, 'debug')}
  end
end

# user prepare
logtap.print(bullet("Running user prepare hook..."), 'debug')

if boxfile[:prepare]
  logtap.print(bullet("'Prepare' detected, running now..."), 'debug')

  execute "prepare code" do
    command boxfile[:prepare]
    cwd "#{CODE_DIR}"
    path GONANO_PATH
    user 'gonano'
    stream true
    on_data {|data| logtap.print data}
  end
end


logtap.print(bullet("Running prepare hook..."), 'debug')

# By this point, engine should be set in the registry
engine = registry('engine')

if not ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/prepare"
  logtap.print fatal('Prepare script is required, but missing')
  exit Hookit::Exit::ABORT
end

logtap.print(bullet("Prepare script detected, running now..."), 'debug')

execute "prepare code and environment" do
  command %Q(#{ENGINE_DIR}/#{engine}/bin/prepare '#{engine_payload}')
  cwd "#{ENGINE_DIR}/#{engine}/bin"
  path GONANO_PATH
  user 'gonano'
  stream true
  on_data {|data| logtap.print data}
end
