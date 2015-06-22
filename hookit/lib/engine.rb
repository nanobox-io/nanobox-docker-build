require 'oj'
require 'multi_json'

module NanoBox
  module Engine
    CODE_DIR    = '/mnt/code'
    BUILD_DIR   = '/data'
    CACHE_DIR   = '/mnt/cache'
    ENGINE_DIR  = '/opt/engines'
    GONANO_PATH = [
      '/data/sbin',
      '/data/bin',
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin',
      '/sbin',
      '/bin',
      '/opt/local/sbin',
      '/opt/local/bin',
      '/opt/gonano/sbin',
      '/opt/gonano/bin'
    ].join (':')

    # This payload will serialized as JSON and passed into each of the
    # engine scripts as the first and only argument. 
    def engine_payload

      data = {
        code_dir: CODE_DIR,
        build_dir: BUILD_DIR,
        cache_dir: CACHE_DIR,
        app: payload[:app],
        env: payload[:env],
        dns: payload[:dns],
        port: payload[:port],
        boxfile: payload[:boxfile],
        engine: registry('engine')
      }

      ::MultiJson.dump(data)
    end

    # Detecting a filepath in this context is a bit tricky, as the filepath
    # likely will not match a local filepath since the filepath originates
    # from the development workstation. Rather, we are just looking for
    # characters at the beginning of the path that would generally indicate
    # a filepath, such as ~, ., /, and \.
    def is_filepath?(path)
      path =~ /^[~|\.|\/|\\]/
    end
  end
end
