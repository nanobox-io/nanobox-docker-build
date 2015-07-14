require 'faraday'

module NanoBox
  class Logtap
    
    def initialize(opts)
      @uri = opts[:uri]
    end

    def post(message, level='info')
      connection.post("/deploy") do |req|
        req.headers['X-Log-Level'] = level
        req.body = message
      end
    end
    alias :print :post

    def puts(message='', level='info')
      post("#{message}\n")
    end

    protected

    def connection
      @connection ||= Faraday.new(url: "http://#{@uri}") do |faraday|
        faraday.adapter :excon
      end
    end

  end
end