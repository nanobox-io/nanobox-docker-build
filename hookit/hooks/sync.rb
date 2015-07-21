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

execute "copy raw code into staging directory" do
  command <<-EOF
    rsync \
      -v \
      -a \
      --delete \
      --exclude='.git/' \
      #{CODE_LIVE_DIR}/ \
      #{CODE_STAGE_DIR}
  EOF
  stream true
  on_data { |data| logtap.print subtask_info(data), 'debug' }
end

logtap.print(process_end, 'debug')

# 3)
logtap.print(bullet('Chowning code'), 'debug')

execute "ensure gonano owns code" do
  command "chown -R gonano #{CODE_STAGE_DIR}"
end
