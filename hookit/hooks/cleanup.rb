# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

logtap.print(bullet("Running cleanup hook..."), 'debug')

# By this point, engine should be set in the registry
engine = registry('engine')

if ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/cleanup"

  logtap.print(bullet("Cleanup script detected, running now..."), 'debug')

  execute "cleanup code" do
    command %Q(#{ENGINE_DIR}/#{engine}/bin/cleanup '#{engine_payload}')
    cwd "#{ENGINE_DIR}/#{engine}/bin"
    path GONANO_PATH
    user 'gonano'
    stream true
    on_data {|data| logtap.print data}
  end

end

# copy /data (current build) to /mnt/deploy for host access
logtap.print(process_start('Copy build into place'), 'debug')

execute "copy build into place" do
  command <<-EOF
    rsync \
      -v \
      -a \
      --delete \
      --exclude-from=/var/nanobox/build-excludes.txt \
      #{BUILD_DIR}/ \
      #{DEPLOY_DIR}
  EOF
  stream true
  on_data {|data| logtap.print data, 'debug'}
end

logtap.print(process_end('Copy build into place'), 'debug')

if ::File.exist? "#{BUILD_DIR}/var/db/pkgin"

  # ensure the directory exists for pkgin cache
  logtap.print(bullet('Ensuring the pkgin cache dir exists...'), 'debug')

  directory "#{CACHE_DIR}/pkgin" do
    recursive true
  end

  # copy (and remove) the pkgin cache & db for quick subsequent deploys
  logtap.print(process_start('Copy pkgin cache'), 'debug')

  execute "stash pkgin packages into cache for quick access" do
    command <<-EOF
      rsync \
        -v \
        -a \
        #{BUILD_DIR}/var/db/pkgin/ \
        #{CACHE_DIR}/pkgin
    EOF
    stream true
    on_data { |data| logtap.print data, 'debug' }
  end

  logtap.print(process_end('Copy pkgin cache'), 'debug')

end
