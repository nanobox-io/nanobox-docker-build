require 'oj'
require 'multi_json'
require 'yaml'

module NanoBox
  module Engine
    SHARE_DIR       = '/share'
    MNT_DIR         = '/mnt'
    BUILD_DIR       = '/data'
    LIVE_DIR        = '/live'
    CODE_DIR        = "#{MNT_DIR}/build"
    DEPLOY_DIR      = "#{MNT_DIR}/deploy"
    CACHE_DIR       = "#{MNT_DIR}/cache"
    APP_CACHE_DIR   = "#{CACHE_DIR}/app"
    LIB_CACHE_DIR   = "#{CACHE_DIR}/lib_dirs"
    ENGINE_DIR      = '/opt/engines'
    CODE_STAGE_DIR  = '/code'
    CODE_LIVE_DIR   = "#{SHARE_DIR}/code"
    ENGINE_LIVE_DIR = "#{SHARE_DIR}/engines"
    ETC_DIR         = "#{BUILD_DIR}/etc"
    ENV_DIR         = "#{ETC_DIR}/env.d"
    GONANO_PATH     = [
      "#{BUILD_DIR}/sbin",
      "#{BUILD_DIR}/bin",
      '/opt/gonano/sbin',
      '/opt/gonano/bin',
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin',
      '/sbin',
      '/bin'
    ].join (':')

    # This payload will serialized as JSON and passed into each of the
    # engine scripts as the first and only argument.
    def engine_payload

      data = {
        code_dir: CODE_STAGE_DIR,
        deploy_dir: BUILD_DIR,
        live_dir: LIVE_DIR,
        cache_dir: APP_CACHE_DIR,
        etc_dir: ETC_DIR,
        env_dir: ENV_DIR,
        app: payload[:app],
        env: payload[:env],
        dns: payload[:dns],
        port: payload[:port],
        boxfile: payload[:boxfile] || original_boxfile,
        platform: 'local',
        run: payload[:run]
      }

      ::MultiJson.dump(data)
    end

    # takes an engine with optional version and strips the versioning
    def engine_name(name)
      name = name.gsub(/\s+/, "")

      if name =~ /=/
        return name.split('=')[0]
      end

      if name =~ /~/
        return name.split('~')[0]
      end

      if name =~ /</
        return name.split('<')[0]
      end

      if name =~ />/
        return name.split('>')[0]
      end

      return name
    end

    # Detecting a filepath in this context is a bit tricky, as the filepath
    # likely will not match a local filepath since the filepath originates
    # from the development workstation. Rather, we are just looking for
    # characters at the beginning of the path that would generally indicate
    # a filepath, such as ~, ., /, and \.
    def is_filepath?(path)
      path =~ /^[~|\.|\/|\\]/
    end

    # Extract the 'boxfile' section of the payload, which is only the
    # 'build' section of the Boxfile provided by the app
    def boxfile
      $boxfile ||= payload[:boxfile] || {}
    end

    # In the event that the boxfile was not provided in the payload,
    # we can try to extract the original boxfile from the registry
    def original_boxfile
      registry :original_boxfile || {}
    end

    # reads the engine_id attribute from the meta
    def engine_id
      release_meta[:engine_id]
    end

    # reads and parses the enginefile from the current engine
    def enginefile
      $boxfile ||= begin
        # pull the engine from the registry
        engine = registry('engine')

        # if it's not set, there's nothing we can do
        if not engine
          return {}
        end

        # use the Enginefile from the selected Engine
        enginefile = "#{ENGINE_DIR}/#{engine}/Enginefile"

        # if the Enginefile doesn't exist, then there's nothing to do
        if not ::File.exists? enginefile
          return {}
        end

        # now let's parse the Enginefile, but safely
        begin
          symbolize_keys(YAML.load(::File.read(enginefile)))
        rescue Exception
          return {}
        end
      end
    end

    def engine_boxfile
      # pull the engine from the registry
      engine = registry('engine')

      # if it's not set, there's nothing we can do
      if not engine
        return {}
      end

      boxfile_script = "#{ENGINE_DIR}/#{engine}/bin/boxfile"

      # if the boxfile binscript doesn't exist, then there's nothing to do
      if not ::File.exist? boxfile_script
        return {}
      end

      yaml = execute %Q(#{boxfile_script} '#{engine_payload}') do
        cwd "#{ENGINE_DIR}/#{engine}/bin"
        path GONANO_PATH
        user 'gonano'
        on_exit { |code| return {} if not code == 0 }
      end

      # now let's parse the response, but safely
      begin
        symbolize_keys(YAML.load(yaml))
      rescue Exception
        return {}
      end
    end

    # reads and parses the meta.json file associated with the engine's release
    def release_meta
      # pull the engine from the registry
      engine = registry('engine')

      # if it's not set, there's nothing we can do
      if not engine
        return {}
      end

      metafile = "#{ENGINE_DIR}/#{engine}/meta.json"

      # if the metafile doesn't exist, then there's nothing to do
      if not ::File.exist? metafile
        return {}
      end

      # now let's read and parse the file, safely
      begin
        ::Multijson.load(::File.read(metafile), symbolize_keys: true)
      rescue Exception
        return {}
      end
    end

    # A helper to retrieve the lib_dirs value from the Boxfile 'build' section.
    # An array will always be returned, even if the Boxfile value is empty
    def lib_dirs
      $lib_dirs ||= begin
        app_dirs = boxfile[:lib_dirs] || []
        engine_dirs = engine_boxfile[:build][:lib_dirs] || [] rescue []
        (app_dirs + engine_dirs).uniq
      end
    end

    protected

    # helper function to recursively convert hash keys from strings to symbols
    def symbolize_keys(h1)

      # if for some reason a Hash wasn't passed, let's return the original
      if not h1.is_a? Hash
        return h1
      end

      # create a new hash, to contain the symbol'ed keys
      h2 = {}

      # iterate through all of the key/value pairs and convert
      h1.each do |k, v|
        h2[k.to_sym] = begin
          if v.is_a? Hash
            symbolize_keys(v)
          else
            v
          end
        end
      end

      h2
    end

  end
end
