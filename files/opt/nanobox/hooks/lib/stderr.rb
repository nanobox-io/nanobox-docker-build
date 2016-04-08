require 'faraday'

module Nanobox
  class Stderr

    def initialize(opts)
      @log_level = level_to_int(opts[:log_level])
    end

    def level_to_int(level)
      levels = {}
      levels['trace'] = -2
      levels['debug'] = -1
      levels['info']  = 0
      levels['warn']  = 1
      levels['error'] = 2
      levels['fatal'] = 3
      return levels[level.downcase].to_i
    end

    def post(message, level='info')
      if level_to_int(level) >= log_level
        $stderr.print message
      end
    end
    alias :print :post

    def puts(message='', level='info')
      post("#{message}\n", level)
    end

  end
end
