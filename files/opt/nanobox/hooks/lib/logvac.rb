require 'faraday'

module NanoBox
  class Logvac

    def initialize(opts)
      @host = opts[:host]
      @deploy_id = opts[:deploy_id]
    end

    def post(message, level='info')
      if ! @host.nil?
        connection.post("/deploy") do |req|
          req.headers['X-Log-Level'] = level
          if @deploy_id
            req.headers['X-Deploy-ID'] = @deploy_id
          end
          req.body = message
        end
      end
    end
    alias :print :post

    def puts(message='', level='info')
      post("#{message}\n")
    end

    protected

    def connection
      @connection ||= Faraday.new(url: "http://#{@host}:5140") do |faraday|
        faraday.adapter :excon
      end
    end

  end
end
