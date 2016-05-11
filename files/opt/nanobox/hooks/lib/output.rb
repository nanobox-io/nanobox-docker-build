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
    # + Updating pkg database ----------------------------------------------------- >
    def process_start(label)
      max_len = 80
      left = label.length + 3
      right = 2
      middle = max_len - (left + right)

      res = "+ "

      # print label
      res << label

      # print a space
      res << " "

      # print middle column
      middle.times { res << '-'}

      # print the right column
      res << " >"

      # end with a newline
      res << "\n"

      res
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
      "+ #{message}\n"
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
    # ! DEPLOY STREAM DISCONNECTED !
    #
    # Oh snap the deploy stream just disconnected. No worries, you can
    # visit the dashboard to view the complete output stream.
    def fatal(title, message=nil)
      res = "\n! #{title.upcase} !\n"

      if message
        res << format_block(message)
      end

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

  end
end
