# Hook order:
#   1 - user
#   2 - configure
#   3 - fetch
#   4 - setup
#   5 - boxfile
#   6 - prepare
#   7 - build
#   8 - pack
#   9 - publish

module Nanobox
  module Engine
    # The DEPLOY_DIR is the pkgsrc build root. This is where pkgsrc is
    # bootstrapped and contains a fully chrooted environment that packages can
    # be installed into and binaries can be linked.
    DEPLOY_DIR = '/data'

    # The ETC_DIR contains configuration for runtimes such as apache or nginx
    # that are required for the live environment.
    ETC_DIR = "#{DEPLOY_DIR}/etc"

    # The ENV_DIR contains environment variables available to the
    # application in the live environment
    ENV_DIR = "#{DEPLOY_DIR}/etc/env.d"

    # The BUILD_DIR contains the environment (binaries, runtimes,
    # configurations) into which the application is deployed.
    #
    # NOTE: In the final web/worker container, the contents of this directory
    # will actually be extracted into the DEPLOY_DIR. After the build process
    # is complete, the contents of DEPLOY_DIR will be rsynced into this directory
    # excluding much of the unecessary fluff.
    #
    # This directory is not managed or manipulated by the engine. It is used
    # internally for the build process. Ultimately, this directory is tar'ed
    # and shipped to the warehouse.
    BUILD_DIR = '/mnt/build'

    # The location of the raw code that the engine and boxfile.yml
    # does transformations against.
    #
    # NOTE: In the final web/worker/dev containers, the contents of the live
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
    LIVE_DIR = '/mnt/live'

    # The contents of the cache directory persist between builds. After each
    # build, this directory is stored for the next build.
    CACHE_DIR = '/mnt/cache'
    # The app cache directory is the directory exposed to the engine
    # for general use
    APP_CACHE_DIR = "#{CACHE_DIR}/app"
    # The lib_dirs cache dir is an internal directory whose purpose is to
    # facilitate the storage/retrieval of lib_dirs like ruby's gems
    LIB_CACHE_DIR = "#{CACHE_DIR}/lib_dirs"

    # The ENGINE_DIR contains all of the installed and soon-to-be
    # installed engines
    ENGINE_DIR = '/opt/nanobox/engines'

    # The LOCAL_CODE_SRC_DIR is a directory mounted from the user's workstation
    # machine. This is the live source code and should never be modified,
    # only copied
    LOCAL_CODE_SRC_DIR = '/share/code'

    # The LOCAL_ENGINE_SRC_DIR is a directory mounted from the user's
    # workstation machine. This is the live engine source and should never be
    # modified, only copied
    LOCAL_ENGINE_SRC_DIR = '/share/engine'

    GONANO_PATH = [
      "#{DEPLOY_DIR}/sbin",
      "#{DEPLOY_DIR}/bin",
      '/opt/gonano/sbin',
      '/opt/gonano/bin',
      '/usr/local/sbin',
      '/usr/local/bin',
      '/usr/sbin',
      '/usr/bin',
      '/sbin',
      '/bin'
    ].join (':')

    # Extract the 'code.build' section of the payload, which is only the
    # 'code.build' section of the Boxfile provided by the app
    def build
      boxfile[:"code.build"] || {}
    end

    # extract engine from the env payload
    def engine
      $engine ||= build[:engine]
    end

    # This payload will serialized as JSON and passed into each of the
    # engine scripts as the first and only argument.
    def engine_payload
      {
        code_dir: CODE_DIR,
        deploy_dir: DEPLOY_DIR,
        live_dir: LIVE_DIR,
        cache_dir: APP_CACHE_DIR,
        etc_dir: ETC_DIR,
        env_dir: ENV_DIR,
        config: build[:config] || {}
      }.to_json
    end

    # When an engine is provided, determine the type of url which will
    # inform the hook of how to fetch the engine
    def engine_url_type(engine)
      case engine
      when /^(\w+)($|#[\w|\/|-]+$)/
        'nanobox'
      when /.+\.git($|#.+$)/
        'git'
      when /^[\w\-]+\/[\w\-]+($|#[\w|\/|-]+$)/
        'github'
      when /^http.+(\.tar\.gz|\.tgz)/
        'tarball'
      when /^[~|\.|\/|\\]/
        'filepath'
      end
    end

    # If a git repo is provided for an engine, extract the commit point
    def engine_git_commitish(engine)
      match = engine.match(/^.+#([\w|\/|-]+$)/)
      if match
        match[1]
      end
    end

    # If a commit point is provided for a repo, strip it off to return just
    # the repo location
    def engine_git_url(engine)
      match = engine.match(/^(.+)#[\w|\/|-]+$/)
      if match
        match[1]
      else
        engine
      end
    end

    # generate a full github clone url from a nanobox engine ie: 'python'
    def engine_nanobox_url(engine)
      match = engine.match(/^(\w+)($|#[\w|\/|-]+$)/)
      if match
        "https://github.com/nanobox-io/nanobox-engine-#{match[1]}.git"
      end
    end

  end
end
