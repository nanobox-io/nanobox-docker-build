# 'dev' hook order:
#   1 - user
#   2 - configure
#   3 - fetch
#   4 - setup
#   5 - boxfile
#   6 - prepare
#   7 - pack-build

# 'build' hook order:
#   1  - user
#   2  - configure
#   3  - fetch
#   4  - setup
#   5  - boxfile
#   6  - prepare
#   7  - compile
#   8  - pack-app
#   8  - pack-build
#   9  - clean
#   10 - pack-deploy

# 'publish' hook order:
#   1 - boxfile
#   2 - publish

module Nanobox
  module Engine
    # The DATA_DIR is the pkgsrc build root. This is where pkgsrc is
    # bootstrapped and contains a fully chrooted environment that packages can
    # be installed into and binaries can be linked.
    DATA_DIR = '/data'

    # The ETC_DIR contains configuration for runtimes such as apache or nginx
    # that are required for the live environment.
    ETC_DIR = "#{DATA_DIR}/etc"

    # The ENV_DIR contains environment variables available to the
    # application in the live environment
    ENV_DIR = "#{DATA_DIR}/etc/env.d"

    # The BUILD_DIR contains the environment (binaries, runtimes,
    # configurations) that are required to build the application.
    #
    # This directory is not managed or manipulated by the engine. It is used
    # internally for the build process. Ultimately, this directory is tar'ed
    # and shipped to the warehouse.
    BUILD_DIR = '/mnt/build'

    # The DEPLOY_DIR container the environment (binaries, runtimes,
    # configurations) that are required for the compiled app to run.
    #
    # This directory should not contain any binary or runtime that is not
    # needed to run the app. The engine 'clean' bin script should remove
    # any package or runtime that won't be needed.
    #
    # In the final running web and worker components, this directory will
    # be mounted at the location of the DATA_DIR.
    #
    # This directory will be a neutered pkgsrc bootstrap and will not have
    # the necessary bits to install new packages, but will include ONLY what
    # is needed to run the app.
    DEPLOY_DIR = '/mnt/deploy'

    # The location of the raw code that the engine and boxfile.yml
    # does transformations against.
    #
    # In the final web/worker/dev containers, the contents of the live
    # directory will actually be here. This is necessary since some languages
    # (like python) generate virtual environments which will contain shebangs
    # with absolute paths to this location. Since this is the absolute location
    # during the transformation/compilation process, this needs to be the path
    # used to run the app in production.
    CODE_DIR = '/app'

    # The directory that contains the final application after
    # any transformations or compilation process. The engine is responsible
    # for copying the final application or whatever is needed to
    # run the compiled application into this directory.
    #
    # Ultimately, this directory is tar'ed and shipped to the warehouse.
    APP_DIR = '/mnt/app'

    # The contents of the cache directory persist between builds. After each
    # build, this directory is stored for the next build.
    CACHE_DIR = '/mnt/cache'
    # The app cache directory is the directory exposed to the engine
    # for general use
    APP_CACHE_DIR = "#{CACHE_DIR}/app"
    # The lib_dirs cache dir is an internal directory whose purpose is to
    # facilitate the storage/retrieval of lib_dirs like ruby's gems
    LIB_CACHE_DIR = "#{CACHE_DIR}/lib_dirs"

    # The NANOBOX_DIR is a parent directory which contains engines, hooks, and
    # other utilities
    NANOBOX_DIR = '/opt/nanobox'

    # The ENGINE_DIR contains the installed engine
    ENGINE_DIR = "#{NANOBOX_DIR}/engine"

    # The LOCAL_CODE_SRC_DIR is a directory mounted from the user's workstation
    # machine. This is the live source code and should never be modified,
    # only copied
    LOCAL_CODE_SRC_DIR = '/share/code'

    # The LOCAL_ENGINE_SRC_DIR is a directory mounted from the user's
    # workstation machine. This is the live engine source and should never be
    # modified, only copied
    LOCAL_ENGINE_SRC_DIR = '/share/engine'

    GONANO_PATH = [
      "#{DATA_DIR}/sbin",
      "#{DATA_DIR}/bin",
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
        data_dir: DATA_DIR,
        app_dir: APP_DIR,
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
