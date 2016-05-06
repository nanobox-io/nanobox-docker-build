module Nanobox
  module Hook

    # strategy:
    # 1- escape the escapes
    # 2- escape quotes
    # 3- escape dollar signs
    def escape(cmd)
      cmd.gsub!(/\\/, "\\\\\\")
      cmd.gsub!(/"/, "\\\"")
      cmd.gsub!(/\$/, "\\$")
      cmd
    end
  end
end
