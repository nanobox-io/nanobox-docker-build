# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

logtap.print(bullet('Running sync hook...'), 'debug')

# 1)
# ensure the code staging directory exists
directory "#{CODE_STAGE_DIR}" do
  recursive true
end

# 2)
# copy the read-only mounted code into the code stage dir
logtap.print(bullet('Copying raw code into staging directory...'))
logtap.print(process_start('Copy raw code into place'), 'debug')

excludes = (lib_dirs + %w(.git)).inject("") do |result, exclude|
  result << "--exclude='#{exclude}' "
end

execute "copy raw code into staging directory" do
  command <<-EOF
    rsync \
      -v \
      -a \
      --delete \
      #{excludes} \
      #{CODE_LIVE_DIR}/ \
      #{CODE_STAGE_DIR}
  EOF
  stream true
  on_data { |data| logtap.print subtask_info(data), 'debug' }
end

logtap.print(process_end, 'debug')

# move the lib_dirs into place if this is a subsequent deploy
lib_dirs.each do |dir|
  if not ::File.exist? "#{CODE_STAGE_DIR}/dir" and ::File.exist? "#{CACHE_DIR}/#{dir}"

    # ensure the directory exists
    logtap.print(bullet("Extracting #{dir} from cache..."), 'debug')

    directory "#{CODE_STAGE_DIR}/#{dir}" do
      recursive true
    end

    # copy (and remove) the lib dir for quick subsequent deploys
    logtap.print(process_start("Extract #{dir}"), 'debug')

    execute "extract #{dir} from cache for quick access" do
      command <<-EOF
        rsync \
          -v \
          -a \
          #{CACHE_DIR}/#{dir}/ \
          #{CODE_STAGE_DIR}/#{dir}
      EOF
      stream true
      on_data { |data| logtap.print subtask_info(data), 'debug' }
    end

    logtap.print(process_end, 'debug')
  end
end

# 3)
logtap.print(bullet('Chowning code'), 'debug')

execute "ensure gonano owns code" do
  command "chown -R gonano #{CODE_STAGE_DIR}"
end
