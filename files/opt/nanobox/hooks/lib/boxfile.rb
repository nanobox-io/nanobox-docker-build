require 'yaml'

module Nanobox
  module Boxfile

    BOXFILE_DATA_DEFAULTS = {
      config:         {type: :hash, default: {}},
      image:          {type: :string, default: nil}
    }

    BOXFILE_BUILD_DEFAULTS = {
      config:         {type: :hash, default: {}},
      engine:         {type: :string, default: nil},
      image:          {type: :string, default: nil},
      lib_dirs:       {type: :array, of: :folders, default: []},

      before_setup:   {type: :array, of: :string, default: []},
      after_setup:    {type: :array, of: :string, default: []},
      before_prepare: {type: :array, of: :string, default: []},
      after_prepare:  {type: :array, of: :string, default: []},
      before_compile:   {type: :array, of: :string, default: []},
      after_compile:    {type: :array, of: :string, default: []}
    }

    BOXFILE_DEPLOY_DEFAULTS = {
      transform:      {type: :array, of: :string, default: []},
      before_deploy_all: {type: :hash, default: {}},
      after_deploy_all: {type: :hash, default: {}},
      before_deploy:  {type: :hash, default: {}},
      after_deploy:   {type: :hash, default: {}}
    }

    BOXFILE_DEV_DEFAULTS = {
      # TODO: something should be in here
    }

    BOXFILE_WEB_DEFAULTS = {
      image:          {type: :string, default: nil},
      start:          {type: :string, default: nil},
      # start:          {type: :hash, of: :string, default: {}},
      routes:         {type: :array, of: :string, default: []},
      ports:          {type: :array, of: :string, default: []},
    }

    BOXFILE_WORKER_DEFAULTS = {
      image:          {type: :string, default: nil},
      start:          {type: :string, default: nil}
      # start:          {type: :string_or_hash, of: :string, default: {}},
    }

    # Simple getter to retrieve the boxfile from the registry
    # the boxfile is set in the registry as the hooks progress
    def boxfile
      registry('boxfile') || {}
    end

    # Create validations for before/after deploy hooks since they're a hash
    def boxfile_deploy_hooks_defaults(boxfile)
      $boxfile_deploy_hooks_defaults ||= begin
        template = {}
        boxfile.keys.each do |key|
          case key
          when /^web\./
            template[key] = {type: :array, of: :string, default: []}
          when /^worker\./
            template[key] = {type: :array, of: :string, default: []}
          end

        end
        template
      end
    end

    # Helper to converge a boxfile
    def converge_boxfile(original)
      boxfile = {}
      original.keys.each do |key|
        case key
        when /^data\./
          boxfile[key] = converge( BOXFILE_DATA_DEFAULTS, original[key] )
        when /^code\.build$/
          boxfile[key] = converge( BOXFILE_BUILD_DEFAULTS, original[key] )
        when /^code\.deploy$/
          boxfile[key] = converge( BOXFILE_DEPLOY_DEFAULTS, original[key] )
          boxfile[key][:before_deploy]     = converge(boxfile_deploy_hooks_defaults(original), boxfile[key][:before_deploy])
          boxfile[key][:before_deploy_all] = converge(boxfile_deploy_hooks_defaults(original), boxfile[key][:before_deploy_all])
          boxfile[key][:after_deploy]      = converge(boxfile_deploy_hooks_defaults(original), boxfile[key][:after_deploy])
          boxfile[key][:after_deploy_all]  = converge(boxfile_deploy_hooks_defaults(original), boxfile[key][:after_deploy_all])
        when /^dev$/
          boxfile[key] = converge( BOXFILE_DEV_DEFAULTS, original[key] )
        when /^web\./
          boxfile[key] = converge( BOXFILE_WEB_DEFAULTS, original[key] )
        when /^worker\./
          boxfile[key] = converge( BOXFILE_WORKER_DEFAULTS, original[key] )
        end
      end
      boxfile
    end

  end
end
