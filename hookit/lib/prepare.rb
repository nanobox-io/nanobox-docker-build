module NanoBox
  module Prepare
    # Extracts the contents of 'config_files' from the Boxfile
    # and will return the list of files that actually exist.
    def config_files
      $config_files ||= begin
        files = boxfile[:config_files] || []

        # if a string was provided, just create a
        # single item array
        if files.is_a?(String)
          files=[files]
        end

        # reject the files that don't exist
        files.keep_if do |file|
          ::File.exist? "/mnt/build/#{file}"
        end
      end
    end

    def config_mount_message
      <<-END
+> The following files were generated for your convenience and will be mounted
   on top of your source code for the duration of this session:
#{config_files_list}

   Please refer to the docs if you would like to change this behavior.
      END
    end

    def config_copy_message
      <<-END
+> The following files were generated for your convenience and will be copied
   on top of your source code:
#{config_files_list}

   Please refer to the docs if you would like to change this behavior.
      END
    end

    def config_files_list
      config_files.inject("") do |msg, file|
        msg << "     - #{file}\n"; msg
      end
    end

  end
end
