module NanoBox
  module File
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
          ::File.exist? "#{BUILD_DIR}/#{file}"
        end
      end
    end

    # Extracts the contents of 'interpolate_files' from the Boxfile
    # and will return the list of files that actually exist.
    def interpolate_files
      $interpolate_files ||= begin
        files = boxfile[:interpolate_files] || []

        # if a string was provided, just create a
        # single item array
        if files.is_a?(String)
          files=[files]
        end

        # reject the files that don't exist
        files.keep_if do |file|
          ::File.exist? "#{CODE_STAGE_DIR}/#{file}"
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

    def interpolate_message
      <<-END
+> The following files were parsed for your convenience and variables will be 
   interpolated:
#{interpolated_files_list}
      END
    end

    def interpolated_files_list
      interpolate_files.inject("") do |msg, file|
        msg << "     - #{file}\n"; msg
      end
    end

  end
end
