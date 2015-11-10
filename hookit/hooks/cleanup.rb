# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

logtap.print(bullet("Running cleanup hook..."), 'debug')

# By this point, engine should be set in the registry
engine = registry('engine')

if ::File.exist? "#{ENGINE_DIR}/#{engine}/bin/cleanup"

  logtap.print(bullet("Cleanup script detected, running now..."), 'debug')

  execute "cleanup environment" do
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
      -a \
      --delete \
      --exclude-from=/var/nanobox/build-excludes.txt \
      #{BUILD_DIR}/ \
      #{DEPLOY_DIR}
  EOF
  stream true
  on_data {|data| logtap.print subtask_info(data), 'debug'}
end

logtap.print(process_end, 'debug')

# copy lib_dirs into cache
lib_dirs.each do |dir|
  if ::File.exist? "#{CODE_STAGE_DIR}/#{dir}"

    # ensure the directory exists
    logtap.print(bullet("Ensuring the #{dir} dir exists..."), 'debug')

    directory "#{LIB_CACHE_DIR}/#{dir}" do
      recursive true
    end

    # copy (and remove) the lib dir for quick subsequent deploys
    logtap.print(process_start("Copy #{dir}"), 'debug')

    execute "stash #{dir} into cache for quick access" do
      command <<-EOF
        rsync \
          -a \
          #{CODE_STAGE_DIR}/#{dir}/ \
          #{LIB_CACHE_DIR}/#{dir}
      EOF
      stream true
      on_data { |data| logtap.print subtask_info(data), 'debug' }
    end

    logtap.print(process_end, 'debug')

  end
end

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
        -a \
        #{BUILD_DIR}/var/db/pkgin/cache/ \
        #{CACHE_DIR}/pkgin
    EOF
    stream true
    on_data { |data| logtap.print subtask_info(data), 'debug' }
  end

  logtap.print(process_end, 'debug')

end
