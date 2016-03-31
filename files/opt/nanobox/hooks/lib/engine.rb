# Hook order:
#   1 - configure
#   2 - fetch
#   3 - sniff
#   4 - setup
#   5 - boxfile
#   6 - prepare
#   7 - build
#   8 - pack
#   9 - publish

module Nanobox
  module Engine
    # The BUILD_DIR is the pkgsrc build root. This is where pkgsrc is
    # bootstrapped and contains a fully chrooted environment that packages can
    # be installed into and binaries can be linked.
    BUILD_DIR = '/data'

    # The ETC_DIR contains configuration for runtimes such as apache or nginx
    # that are required for the live environment.
    ETC_DIR = "#{BUILD_DIR}/etc"

    # The ENV_DIR contains environment variables available to the
    # application in the live environment
    ENV_DIR = "#{BUILD_DIR}/env.d"

    # The DEPLOY_DIR contains the environment (binaries, runtimes,
    # configurations) into which the application is deployed.
    #
    # NOTE: In the final web/worker container, the contents of this directory
    # will actually be extracted into the BUILD_DIR. After the build process
    # is complete, the contents of BUILD_DIR will be rsynced into this directory
    # excluding much of the unecessary fluff.
    #
    # This directory is not managed or manipulated by the engine. It is used
    # internally for the build process. Ultimately, this directory is tar'ed
    # and shipped to the warehouse.
    DEPLOY_DIR = '/deploy'

    # The location of the raw code that the engine and boxfile.yml
    # does transformations against.
    #
    # NOTE: In the final web/worker containers, the contents of the live
    # directory will actually be here. This is necessary since some languages
    # (like python) generate virtual environments which will contain shebangs
    # with absolute paths to this location. Since this is the absolute location
    # during the transformation/compilation process, this needs to be the path
    # used to run the app in production.
    CODE_DIR = '/code'

    # The directory that contains the final application after
    # any transformations or compilation process. The engine is responsible
    # for copying the final application or whatever is needed to
    # run the compiled application into this directory.
    #
    # Ultimately, this directory is tar'ed and shipped to the warehouse.
    LIVE_DIR = '/live'

    # The contents of the cache directory persist between deploys. After each
    # build, this directory is tar'ed and shipped to the warehouse.
    CACHE_DIR = '/cache'
    # The app cache directory is the directory exposed to the engine
    # for general use
    APP_CACHE_DIR = "#{CACHE_DIR}/app"
    # The lib_dirs cache dir is an internal directory whose purpose is to
    # facilitate the storage/retrieval of lib_dirs like ruby's gems
    LIB_CACHE_DIR = "#{CACHE_DIR}/lib_dirs"

    # The ENGINE_DIR contains all of the installed and soon-to-be
    # installed engines
    ENGINE_DIR = '/opt/nanobox/engines'

    # The LOCAL_* directories represent source and destination directories
    # that are used only for when nanobox is run locally.

    # The LOCAL_CODE_SRC_DIR is a directory mounted from the user's workstation
    # machine. This is the live source code and should never be modified,
    # only copied
    LOCAL_CODE_SRC_DIR = '/share/code'

    # The LOCAL_ENGINE_SRC_DIR is a directory mounted from the user's
    # workstation machine. This is the live engine source and should never be
    # modified, only copied
    LOCAL_ENGINE_SRC_DIR = '/share/engine'

    # When running nanobox locally, the LIVE_DIR will not be uploaded to
    # warehouse, but instead copied into the LOCAL_LIVE_DEST_DIR which will
    # ultimately be mounted into the web/worker containers directly.
    LOCAL_LIVE_DEST_DIR = '/mnt/build'

    # When running nanobox locally, the DEPLOY_DIR will not be uploaded to
    # warehouse, but instead copied into the LOCAL_DEPLOY_DEST_DIR which
    # will ultimately be mounted into the web/worker containers directly.
    LOCAL_DEPLOY_DEST_DIR = '/mnt/deploy'

    # When running nanobox locally, the CACHE_DIR will not be uploaded to
    # warehouse, but instead copied into the LOCAL_CACHE_DEST_DIR, which can be
    # re-used through subsequent local builds.
    LOCAL_CACHE_DEST_DIR = '/mnt/cache'

    GONANO_PATH = [
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

    # Extract the 'env' section of the payload, which is only the
    # 'env' section of the Boxfile provided by the app
    def env
      $env ||= payload[:env] || {}
    end

    # This payload will serialized as JSON and passed into each of the
    # engine scripts as the first and only argument.
    def engine_payload
      {
        code_dir: CODE_DIR,
        deploy_dir: BUILD_DIR,
        live_dir: LIVE_DIR,
        cache_dir: APP_CACHE_DIR,
        etc_dir: ETC_DIR,
        env_dir: ENV_DIR,
        app: payload[:app],
        evars: payload[:evars],
        dns: payload[:dns],
        config: env[:config] || {},
        platform: payload[:platform]
      }.to_json
    end

    # When an engine is provided, determine the type of url which will
    # inform the hook of how to fetch the engine
    def engine_url_type(engine)
      case engine
      when /.+\.git($|#.+$)/
        'git'
      when /^[\w\-]+\/[\w\-]+($|#\w+$)/
        'github'
      when /^http.+(\.tar\.gz|\.tgz)/
        'tarball'
      when /^[~|\.|\/|\\]/
        'filepath'
      end
    end

    # If a git repo is provided for an engine, extract the commit point
    def engine_git_commitish(engine)
      match = engine.match(/^.+#(\w+$)/)
      if match
        match[1]
      else
        'master'
      end
    end

  end
end
