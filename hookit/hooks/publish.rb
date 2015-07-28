# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

logtap.print(bullet('Running publish hook...'), 'debug')

# 1)
# copy the staged code into the final code dir
logtap.print(bullet('Copying staged code into final build...'))
logtap.print(process_start('Copy staged code into final place'), 'debug')

execute "copy staged code into final directory" do
  command <<-EOF
    rsync \
      -v \
      -a \
      --delete \
      #{LIVE_DIR}/ \
      #{CODE_DIR}
  EOF
  stream true
  on_data { |data| logtap.print subtask_info(data), 'debug' }
end

logtap.print(process_end, 'debug')
