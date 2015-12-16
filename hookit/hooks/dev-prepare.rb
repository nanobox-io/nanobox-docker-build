# import some logic/helpers from lib/*.rb
include NanoBox::Engine
include NanoBox::Output
include NanoBox::Prepare

logtap.print(bullet("Running dev-prepare hook..."), 'debug')

# By this point, engine should be set in the registry
engine = registry('engine')

case payload[:dev_config]
when 'none'
  logtap.print(bullet("Config 'none' detected, exiting now..."), 'debug')
  exit 0
when 'mount'
  logtap.print(bullet("Config 'mount' detected, running now..."), 'debug')

  # ensure boxfile[:config_files] is not empty AND at least
  # one of the files listed exists in the build
  if boxfile[:config_files] && (config_files = existing_files(boxfile[:config_files])).any?

    # inform user
    logtap.print  <<-END
+> The following files were generated for your convenience and will be mounted
   on top of your source code for the duration of this session:
END

    # look for the 'config_files' node within the 'boxfile' payload, and
    # bind mount each of the entries
    config_files.each do |file|
      logtap.print("     - #{file}"))
      execute "mount #{file}" do
        command %Q(mount --bind /mnt/build/#{file} /code/#{file})
      end
    end

   logtap.print '   Please refer to the docs if you would like to change this behavior.'
  end

when 'copy'
  logtap.print(bullet("Config 'copy' detected, running now..."), 'debug')

  # ensure boxfile[:config_files] is not empty AND at least
  # one of the files listed exists in the build
  if boxfile[:config_files] && (config_files = existing_files(boxfile[:config_files])).any?

    # inform user
    logtap.print  <<-END
+> The following files were generated for your convenience and will be copied
   on top of your source code:
END

    # copy each of the values in the 'config_files' node into the raw source
    config_files.each do |file|
      logtap.print("     - #{file}"))
      execute "copy #{file}" do
        command %Q(cp -f /mnt/build/#{file} /code/#{file})
      end
    end

   logtap.print '   Please refer to the docs if you would like to change this behavior.'
  end

else
  logtap.print(bullet("Bad dev_config detected, exiting now..."), 'debug')
  exit Hookit::Exit::ABORT
end
