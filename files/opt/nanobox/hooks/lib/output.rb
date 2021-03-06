require 'yaml'
require 'ya2yaml'

module Nanobox
  module Output

    def logger
      $logger ||= ::Nanobox::Stderr.new(log_level: payload[:log_level])
    end

    # process_start
    #
    # Print a header indicating the start of a process.
    #
    # Example:
    #
    # process_start "Updating pkg database"
    #
    # would produce:
    # - Updating pkg database :
    def process_start(label)
      "- #{label} :\n"
    end

    # process_end
    #
    # Creates a hard delineation after a process
    def process_end
      "\n"
    end

    # bullet
    #
    # Print a line item in the form of a bullet point
    #
    # Example:
    #
    # bullet "Language Detected : Ruby"
    #
    # would produce:
    # + Language Detected : Ruby
    def bullet(message)
      "- #{message}\n"
    end

    # bullet_info
    #
    # Print a line item in the form of a bullet point
    #
    # Example:
    #
    # bullet_info "Language Detected : Ruby"
    #
    # would produce:
    #  Language Detected : Ruby
    def bullet_info(message)
      "  #{message}"
    end

    # bullet_sub
    #
    # Print a line item in the form of a bullet point
    #
    # Example:
    #
    # bullet_sub "Language Detected : Ruby"
    #
    # would produce:
    #  - Language Detected : Ruby
    def bullet_sub(message)
      "  - #{message}"
    end

    # warning
    #
    # Print a warning message, formatted to an 80 character block paragraph
    #
    # Example:
    #
    # warning "We've detected you may be using... (abbreviated for clarity)"
    #
    # would produce:
    # -----------------------------  WARNING  -----------------------------
    # We've detected you may be using sessions in a way that could cause
    # unexpected behavior. Feel free to review the following guide for
    # more information : bit.ly/2sA9b
    def warning(message)
      res = "\n----------------------------------  WARNING  ----------------------------------\n"

      res << format_block(message)

      res
    end

    # fatal
    #
    # Example:
    #
    # fatal "deploy stream disconnected", "Oh snap... (abbreviated for clarity)"
    #
    # would produce:
    # 
    # ::::::::::::::::::::::::::::::::::::::::::::::::: DEPLOY STREAM DISCONNECTED !!!
    # 
    # Oh snap the deploy stream just disconnected. No worries, you can visit
    # the dashboard to view the complete output stream.
    # 
    # ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    # 
    def fatal(title, message=nil)
      # add a newline add the beginning of the message
      res = "\n"
      
      # add the left padding
      (75 - title.length).times { res << ':' }

      # add the title
      res << " #{title.upcase} !!!\n"
      
      # add an empty line between the header and the message
      res << "\n"
      
      # add the message
      res << message
      
      # add an empty line between the message and the footer
      res << "\n"
      
      # add the footer
      80.times { res << ':' }

      # add a double newline to finish the message
      res << "\n\n"

      res
    end

    # format_block
    #
    # Print a message formatted as a block of text, wrapped at 70 characters
    #
    # Example:
    #
    # block "We've detected you may be using... (abbreviated for clarity)"
    #
    # would produce:
    # We've detected you may be using sessions in a way that could cause
    # unexpected behavior. Feel free to review the following guide for
    # more information : bit.ly/2sA9b
    def format_block(message)
      max_line_len = 80
      res = ""
      word = ""
      j = 0

      message.length.times do |i|
        char = message[i]

        if char == " "
          if j <= max_line_len
            # terminate the current line
            res << "\n"
            res << "#{word} "
            j = word.length + 1
            word = ""
          else
            res << "#{word} "
            word = ""
          end
        elsif i == message.length - 1
          if j <= max_line_len
            # terminate the current line
            res << "\n"
          end
          res << word
        else
          word << char
        end
      end

      res << "\n"

      res
    end

    # When a boxfile.yml is missing this function can be called to inform
    # of the requirements, and also suggest an engine to start with
    def missing_boxfile
      message = <<-END
Nanobox is looking for a boxfile.yml config file. You might want to 
check out our getting-started guide on configuring your app:

https://guides.nanobox.io/
      END

      fatal "missing boxfile.yml", message
    end

    # If a boxfile.yaml is provided but fails to parse, this function can
    # be called to print the error and inform the user of the next step
    def unparseable_boxfile
      message = <<-END
Nanobox had an issue trying to parse the boxfile.yml config file. Please
ensure that it is valid yaml. Please refer to the guides for help:

https://guides.nanobox.io/
      END
      fatal "unparseable boxfile.yml", message
    end
    
    # If a boxfile.yml is provided but fails validation, this function can
    # be called to print the errors and inform the user of next steps
    def invalid_boxfile(errors)
      failure = errors
        .deep_stringify_keys
        .ya2yaml(:syck_compatible => true)
      
      message = <<-END
Oops, it looks like a few issues need to be resolved in your boxfile.yml
before we can continue. Please correct the following issues and try again:

#{failure}
      END
      
      fatal "invalid boxfile.yml", message
    end

    # If a boxfile fails validation after merging with the engine boxfile
    # we can print this message to clarify the issue
    def invalid_merged_boxfile(errors)
      failure = errors
        .deep_stringify_keys
        .ya2yaml(:syck_compatible => true)
        
      message = <<-END
Uh oh... it appears that the engine injected bad configuration into
your boxfile.yml configuration. This is not your fault, but you should
probably find a different engine or at least let the author of your
current engine know what happened.

If you're curious, here are the issues:

#{failure}
      END
    end
    
    # If a boxfile.yml contains legacy configuration, this function can
    # be called to print the errors and inform the user of next steps
    def legacy_boxfile
      message = <<-END
We have been working on some exciting changes! It looks like you need to
upgrade to take advantage of the new workflow and simpler configuration.
      
Check out this guide to walk you through this quick upgrade:

https://gist.github.com/tylerflint/3262228c3e8a29addd382f53de9aa2ea
      END
      
      fatal "legacy boxfile.yml", message
    end

    def invalid_engine(engine)
      message = <<-END
Uh oh, the engine provided is not something we can retrieve. You might
want to check out our getting-started guide on specifying an engine:

https://docs.nanobox.io/boxfile/run-config/
      END
      
      fatal "invalid engine", message
    end
  end
end
