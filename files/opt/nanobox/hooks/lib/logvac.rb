require 'faraday'

module Nanobox
  class Logvac

    def initialize(opts)
      @logvac = opts[:logvac]
      @build  = opts[:build]
    end

    def post(message, level='info')
      $stdout.print message
      # if ! @host.nil?
      #   connection.post("/deploy") do |req|
      #     req.headers['X-Log-Level'] = level
      #     if @deploy_id
      #       req.headers['X-Deploy-ID'] = @deploy_id
      #     end
      #     req.body = message
      #   end
      # end
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
