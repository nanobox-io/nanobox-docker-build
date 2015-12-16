# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output
include NanoBox::Prepare

logtap.print(bullet("Running dev-prepare hook..."), 'debug')

# By this point, engine should be set in the registry
engine = registry('engine')

# During the build process, engines can generate config
# files that will allow the application to auto-connect
# to services that were detected and provisioned. In dev
# mode, those files need to be mounted or copied into
# place.

case payload[:dev_config]
when 'none'
  logtap.print(bullet("Config 'none' detected, exiting now..."), 'debug')

when 'mount'
  logtap.print(bullet("Config 'mount' detected, running now..."), 'debug')

  # ensure boxfile[:config_files] is not empty AND at least
  # one of the files listed exists in the build
  if config_files.any?

    # inform user
    logtap.print config_mount_message

    # look for the 'config_files' node within the 'boxfile' payload, and
    # bind mount each of the entries
    config_files.each do |file|
      execute "mount #{file}" do
        command %Q(mount --bind /mnt/build/#{file} /code/#{file})
      end
    end
  end

when 'copy'
  logtap.print(bullet("Config 'copy' detected, running now..."), 'debug')

  # ensure boxfile[:config_files] is not empty AND at least
  # one of the files listed exists in the build
  if config_files.any?

    # inform user
    logtap.print config_copy_message

    # copy each of the values in the 'config_files' node into the raw source
    config_files.each do |file|
      execute "copy #{file}" do
        command %Q(cp -f /mnt/build/#{file} /code/#{file})
      end
    end
  end

else
  logtap.print(bullet("Bad dev_config detected, exiting now..."), 'debug')
  exit Hookit::Exit::ABORT
end
