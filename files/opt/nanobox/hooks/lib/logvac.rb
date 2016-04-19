require 'faraday'

# todo: move this into code hooks
module Nanobox
  class Logvac

    def initialize(opts)
      @logvac = opts[:logvac]
      @build  = opts[:build]
      @token  = opts[:token]
    end

    def post(message, level='info')
      connection.post("/") do |req|
        req.headers['X-AUTH-TOKEN'] = @token
        body = {}
        body[:message] = message
        body[:type] = "build"
        body[:level] = level
        body[:id] = @build
        req.body = body.to_json
      end
    end
    alias :print :post

    def puts(message='', level='info')
      post("#{message}\n", level)
    end

    protected

    def connection
      @connection ||= Faraday.new(url: "http://#{@logvac}:6361") do |faraday|
        faraday.adapter :excon
      end
    end

  end
end
