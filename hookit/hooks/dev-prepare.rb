# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output

logtap.print(bullet("Running dev-prepare hook..."), 'debug')

# By this point, engine should be set in the registry
engine = registry('engine')

case payload[:dev_config]
when 'none'
  logtap.print(bullet("Config 'none' detected, exiting now..."), 'debug')
  exit 0
when 'mount'

  logtap.print(bullet("Config 'mount' detected, running now..."), 'debug')

  # look for the 'config_files' node within the 'boxfile' payload, and
  # bind mount each of the entries
  (boxfile[:config_files] || []).each do |f|
    execute "mount #{f}" do
      command %Q(mount --bind /mnt/build/#{f} /code/#{f})
    end
  end

when 'copy'

  logtap.print(bullet("Config 'copy' detected, running now..."), 'debug')

  # copy each of the values in the 'config_files' node into the raw source
  (boxfile[:config_files] || []).each do |f|
    execute "copy #{f}" do
      command %Q(cp -f /mnt/build/#{f} /code/#{f})
    end
  end

else
  logtap.print(bullet("Config not detected, exiting now..."), 'debug')
  exit Hookit::Exit::ABORT
end
